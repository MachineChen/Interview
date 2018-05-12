# redis 数据结构与存储

# 一.概述：
    Redis从大的方面来说，就是一个K-V数据库（或cache）；但是redis还提供了对复杂数据结构的操作，比如set/list/map，因此它需要具备对复杂数据的高效查询；此外它还提供了故障恢复特性，因此它需要具备数据持久化(文件操作)能力。
 
Java代码  

```
##如下为Reis顶层数据结构,redisDB实例表示为一个"database",任何K-V/expire信息均隶属一个db  
##一个redis可以有多个databse,参见配置文件  
//redis.h(源码)  
typedef struct redisDb {  
    dict *dict;                 /* The keyspace for this DB */  
    dict *expires;              /* Timeout of keys with a timeout set */  
    dict *blocking_keys;        /* Keys with clients waiting for data (BLPOP) */  
    dict *ready_keys;           /* Blocked keys that received a PUSH */  
    dict *watched_keys;         /* WATCHED keys for MULTI/EXEC CAS */  
    int id;                     /*DB 索引号*/  
} redisDb;  
```

此数据结构将会在redis与client交互中/以及后台worker中不断的调整和修改。顶层数据结构维护了K-V表/过期key集合/基于阻塞操作的Key集合/基于事务的watch-key集合等。其中K-V表就是一个hashtable，此表维护了“k-v对”集合，无论是查询还是插入，均基于HASH，HASH的默认尺寸为2,此后会根据“需要”做rehash操作(2*N),对于HASH冲突的解决（参见其他关于rehash原理），V的直接数据结构是linkedlist。dict数据结构可以参见dict.h源码

key就是简单的string，key似乎没有长度限制，不过原则上应该尽可能的短小且可读性强，无论是否基于持久存储，key在服务的整个生命周期中都会在内存中，因此减小key的尺寸可以有效的节约内存，同时也能优化key检索的效率。

value在redis中，存储层面仍然基于string，在逻辑层面，可以是string/set/list/map，不过redis为了性能考虑，使用不同的“encoding”数据结构类型来表示它们。(例如：linkedlist，ziplist等)。

Redis-server与client交互过程中以及value值的保存，使用的string称为sds：Simple Dynamic Strings，即简单动态字符串，它的实现原理和java中StringBuffer/StringBuilder如出一辙，这种结构很适合字符串长度无法预期或者允许区间操作的场景，这只是一种技巧。

key默认为“不过期”，可以通过“EXPIRE”/“PEXPIRE”来指定key过期的时间(秒/毫秒)，具有“过期”时间的key将会被添加到expires集合中，如果redis为“持久存储”，那么每个key的过期信息也将被序列化到rdb文件中；可以通过“PERSIST”来移除key的过期控制，此后key将处于“永不过期”状态。可以通过“TTL”/“PTTL”来查看key尚能“存活”的时间(剩余时间值)。

redis将过期时间转换成时间戳而保存起来，时间戳的计算将使用本地时间，对于key过期检测是通过将“过期时间”与本地时间(戳)比较，因此随意调整本地时间，将有可能导致redis对“过期控制”出现意外，比如将时间前进一天将会导致部分key直接过期；在数据恢复时，也会检测key是否过期，如果redis停机时间过久，那么会导致大量key过期，对于过期的key将直接丢弃；如果你的数据恢复文件来自其他server,且两个server的本地时间差距较大，也会导致上述问题。（参见db.c）“DEL”操作将会导致key删除，同时也会在expries集合中删除。在redis中(包括memcached)只有set/getset操作会重置“过期控制”，其他的任何读取/修改操作都不会“触及”(touch)过期时间(当然“expire”/“persist”除外).Redis对于过期检测，有2种方式，一个主动检测，一个是被动检测；在redis和client交互过程中，对于任何数据的操作，都会首先检测key是否已经过期，这是被动检测；主动检测是Redis启动的后台线程中，不间断的随机扫描一定量的key（randomKey），并对key进行过期检测。对于过期的key，将会被直接丢弃(伴生“DEL”操作)。因为slave不具备主动检测机制，master对于过期的key将会以一个“DEL”操作同步到salve中；如果采取的是AOF方式，也是以“DEL”指令append到文件中。


# 二.文件存储格式

如果你开启了snapshot功能，那么数据将会间歇性的同步到rdb文件中(binary文件)。

Java代码  

```
#摘自redis#  
FE 00                       # FE = code that indicates database selector. db number = 00  
----------------------------# Key-Value pair starts  
FD $unsigned int            # FD indicates "expiry time in seconds". After that, expiry time is read as a 4 byte unsigned int  
$value-type                 # 1 byte flag indicating the type of value - set, map, sorted set etc.  
$string-encoded-key         # The key, encoded as a redis string  
$encoded-value              # The value. Encoding depends on $value-type  
```

可以通过“vim”指令查看此文件，不过阅读起来不是很方便。每条数据，都以特殊的字节标记开头，数据中包括“过期时间”/“value数据类型”“key”/“value数据”；基本上可以通过有序的读取字节序列的方式，即可恢复结构化的K-V逻辑结构。K-V字节存储结构图：

Java代码  

```
##过期时间：秒  
[FD][过期时间戳：4个字节][value类型：一个字节][key字符串][value字符串]  
##过期时间：毫秒  
[FC][过期时间戳：8个字节][value类型：一个字节][key字符串][value字符串]  
##无过期  
[value类型：一个字节][key字符串][value字符串]  
  
##其中FD/FC是一个标记前缀，一个字节，16进制表示，读取数据是，如果第一个字节不是FD/FC，那么它就是一个“无过期时间”的K-V。  
```

## 1) value类型：

Java代码  

```
##摘自redis  
0 = “String Encoding”  
1 = “List Encoding”  
2 = “Set Encoding”  
3 = “Sorted Set Encoding”  
4 = “Hash Encoding”  
9 = “Zipmap Encoding”  
10 = “Ziplist Encoding”  
11 = “Intset Encoding”  
12 = “Sorted Set in Ziplist Encoding”  
13 = “Hashmap in Ziplist Encoding”  
```

value类型用来指示文件解析者，将当前“K-V”以何种数据结构来表示。在Redis中目前有这13种数据结构，稍后逐一介绍。
 
## 2) key字符串：


因为基于字节流的方式解析，所以我们需要知道key的长度(后驱偏移量)：[位计算：前缀与长度][字符串值]

可能考虑节约空间或者其他考虑，key的解析有点奇怪，首先读取一个字节，并检测此字节的前2位(bit)，这2位数据是用来标记key的长度特征：

```
    00: 此字节的剩余6位则表示“长度”
    01: 此字节的剩余6位以及下一个字节的8位，共14位来表示“长度”
    10: 此字节不参与计算，将直接读取4个字节，这4个字节表示“长度”
    11: 一种特殊格式，剩余的6位用来表示格式信息，此种情况出现在value中，表示此value为一个integer类型数据：
```

Java代码  

##如果剩余6位的值为如下：  

```
0:     8位integer  
1:     16位integer  
2:     32位integer  
```

key的特征已经分析完毕，接下来直接读取一定“长度”的字节并编码成string即可，此string就是KEY。

## 3) value字符串：

此前已经有一个字节表示value-type，那么读取value就非常简单，那照2)中读取key字符串的方式读取出value的字符串，此后就可以根据value-type对字符串进行相应的解析，并构建逻辑数据结构。
 
在redis文件解析中，有2中方式：length-encoding，string-encoding；length-encoding主要的目的就是将字节码(不可读)数据使用“字节码成帧”手段，按照“[字节长度][字节序列]”的方式，读取“字节序列”并按照“字符编码(UTF-8)”的方式转换成字符串的过程。string-encoding,是对字符串使用“格式约束”手段解析成特定逻辑API的过程，例如将“1,2,3,4”转换成一个数组{1,2,3,4}.

# 三.数据结构概述

1)查看value类型：

```
Java代码  
redis 127.0.0.1:6379> lpush testlist 0  
(integer) 1  
redis 127.0.0.1:6379> type testlist  
list  
redis 127.0.0.1:6379> object encoding testlist  
"ziplist"
```

"type"指令用来查看value的类型，“object encoding”用来查看value的编码类型。在Redis中type有如下几种值：

string：以简单字符串存储（简单动态字符串，SDS），对于普通的简单数据，均为string类型，包括数字(incr操作)。

list： 列表，存储线性顺序数据，通过“lpush”操作而创建的数据结构，编码类型包括：ziplist，linkedlist。默认为ziplist。

set：集合，储存散列数据且数据不可重复，通过“sadd"操作而创建的数据结构，编码类型包括：intset，hashtable。

zset：有序集合，和set区别就是它可以根据指定的“权重”进行排序，内部基于list存储而非hashtable，通过“zadd”操作创建，编码类型包括：ziplist，skiplist。

hash：存储K-V复合数据结构，通过“hset”操作创建，编码类型包括：ziplist，hashtable。

# 四.string：

string类型是redis中默认的类型，对于任何没有指定“类型”的数据结构，都是string，其中包括incr操作创建的integer等；string本身即为字符串数组，redis提供了一个“string api”列表，允许对string进行复杂的操作，有点类型java中string的方法：

APPEND key value：对将vaue值追加到原字符串之后。

GETRANGE key start end：获取start~end区间的字符串。

SETRANGE key offset value：从offset位置开始，将原字符串的值替换为value，只替换同等长度的字符串（覆盖）

STRLEN：获取当前值的字符串长度。

如果string的值可以被正确编码成integer，那么此字符串还支持INCR/DECR操作。

SDS的内部数据结构非常类似于JAVA中的StringBuffer，在为string分配内存时，空间大小为实际length的2倍，比如“hello”字符串需要5个字节，那么将会分配10个字节（其实为11个，“\0”是每个字符串的终结符），这意味着每个SDS创建后有一半的空间是“空闲的”；当SDS内容变更时，如果所需长度不超过当前buffer容量，将不会重新分配内存空间，而是直接重用，即使变更后的内容所需长度更小，SDS也不会进行“缩减”空间；如果所需的空间更大，比如将“hello”修改为”hello world,redis!”，那么此时将会重新分配新的内存空间，SDS的容量为新内容的length的2倍；之所以如此设计，Redis考虑到内存重新分配的开销，减少内存分配的次数，以提高性能。

SDS的内存重新分配时还有一点小技巧，如果字符串长度小于1M时，那么将分配的容量是实际字符串长度的2倍，即buffer中实际占用空间和空闲空间各占一半；如果字符串长度大于1M时，Redis只分配1M的空闲空间，不会再按照2倍的方式分配。

# 五.list：

list是一种最常用的线性存储结构，基于list的各种优化算法也很多，redis使用list来存储一些对插入顺序/排序有要求的数据；同时因为list是一种最轻量级的数据结构，而且当list中数据较少时，其查询复杂度接近o(1)，因此对于一些hash结构，数据较少时redis也使用了list来表示它们。

如下为list的常用的变更操作：

LREM key count value：根据指定的查找顺序，遍历list并删除和“value”相等的元素；其中count为0表示删除所有，<0表示倒序遍历，>0表示正序。

LSET key index value：将指定index的元素替换成新值。

LTRIM key start stop：移除start~stop之间的元素

LINSERT key before|after index value:在指定索引的前/后插入一个新元素。

因为list本身具备“元素插入顺序”的自然特性，因为list常常可以作为“队列”而使用，redis也提供了“队列”的功能(阻塞模式，双端队列)：

RPUSH key value：向“队列”的尾部添加数据

BLPOP key timeout：“队列”头部移除一个元素，最多阻塞timeout秒。

BRPOP key timeout：“队列”的尾部移除一个元素，最多阻塞timeout秒。
 
## 1) ziplist：编码类型，即redis对list的序列化存储的格式，redis将“逻辑上list数据结构”在文件中以“ziplist”格式存储在rdb文件中；在list数据量较小时，ziplist数据将会被完整加载到内存（格式良好的string字符串：其实为字符数组 + offset等）。（参见ziplist.c）
 
Java代码  

```
##ziplist中每条元素的结构  
typedef struct zlentry {  
    unsigned int prevrawlensize, prevrawlen;  
    unsigned int lensize, len;  
    unsigned int headersize;  
    unsigned char encoding;  
    unsigned char *p;  
} zlentry;  
```

序列化存储结构(简述)：[ziplist字节总长度:4个字节][ziplist中元素个数：4个字节]{[元素字节长度][元素数据:字符串]...}

在API级别，ziplist其实就是一个char数组，它同时也维护了list中元素的个数以及每个元素所在字符串中的offset和长度，如果想获取某个index的数据，只需要通过此index找到对应的zlentry，然后输出对应的offset +len之间的字符数组即可。

当list中元素的个数较少/每个元素的字符长度较小时，同时对list的变更操作较少时，ziplist的性能相对更加优秀(节约内存和关系维护)。此时你应该知道了ziplist其实内部是基于string对字符区间的操作，性能受制于“数组”的特性。ziplist在数据元素较少的时候，不仅节约了内存，而且也没有导致性能下降。

## 2) linkedlist：编码类型，链表，逻辑API；如果list中元素个数达到一定阀值，将会触发将ziplist重构成linkedlist(双向链表)；因为如果ziplist中元素个数很多，就意味着变更操作将是很低效率的。linkedlist实在是没什么好解释，如果你从事过java/c等任何一门编程语言的研发，都会知道如何实现一个linkedlist。（参见adlist.c）

Redis根据“redis.conf”中的配置信息选择list编码类型：

Java代码  

```
##ziplist中允许的元素个数  
list-max-ziplist-entries 64  
##ziplist元素所允许的最大字符长度  
list-max-ziplist-value 512  
```

如果在list操作中，无论是元素个数还是元素的字符串长度达到阀值，都会触发redis对ziplist重构成linkedlist。

# 六.set：

集合，常用来存储不重复数据的数据结构,底层基于hashtable；在redis中为了优化存储，set的编码类型可以为：intset，hashtable。

如下为set的常用操作（集合的“交差并”操作）：

SINTER key key.. ： 计算并获取多个set的“交集”。

SUNION key key...：计算并获取多个set的“并集”。

SCARD key：获取set中元素的个数。

SPOP key：从set中随即获取一个元素。

SISMEMBER key value：检测value在set中是否已经存在

SMEMBERS key：获取set中所有的元素（祈祷它不会太庞大）

## 1) intset：指令传递的字符串可以通过10进制编码转换成integer且set中所有的值都是integer,那么此set可以被编码为intset,主要考虑的原因是节约空间和"校验"效率.如果set中所有的元素都是integer，那么对于set中某个元素的“存在与否校验”可以使用integer本身比较即可，而非使用hashcode；intset在逻辑上是二叉树，存储基于数组（数字按小到大排序）。（参见intset.c）

intset在文件存储中结构如下：[编码属性：4个字节][元素个数：4个字节][元素内容]。

其中"编码属性”是一个4个字节的integer值，需要用来表示当前intset中每个integer使用的字节个数,可能是“2”“4”“8”三种之一，如果是“4”,则表示当前intset中所有的元素都是4个字节的integer，那么在此后的对于“元素内容”时就按照4个字节编码一个integer。

“元素个数”表示intset中有多少个integer值，“元素内容”为连续的字节序列，可以根据“编码属性”来逐个获取integer值。
 
Java代码  

```
##intset中允许保存的最大条目个数,如果达到阀值,intset将会被重构为hashtable  
set-max-intset-entries 64
```

## 2) hashtable：

在此需要声明，set结构在redis文件存储中，并不是hashtable，而是按照ziplist的方式存储，其实也很好理解，因为set在逻辑上为了更好的“重复检测”，使用了hashtable；但是其数据结构却很像list，因为在文件存储时，set的按照ziplist的方式序列化到文件。

六.set：

集合，常用来存储不重复数据的数据结构,底层基于hashtable；在redis中为了优化存储，set的编码类型可以为：intset，hashtable。

如下为set的常用操作（集合的“交差并”操作）：

SINTER key key.. ： 计算并获取多个set的“交集”。

SUNION key key...：计算并获取多个set的“并集”。

SCARD key：获取set中元素的个数。

SPOP key：从set中随即获取一个元素。

SISMEMBER key value：检测value在set中是否已经存在

SMEMBERS key：获取set中所有的元素（祈祷它不会太庞大）

## 1) intset：指令传递的字符串可以通过10进制编码转换成integer且set中所有的值都是integer,那么此set可以被编码为intset,主要考虑的原因是节约空间和"校验"效率.如果set中所有的元素都是integer，那么对于set中某个元素的“存在与否校验”可以使用integer本身比较即可，而非使用hashcode；intset在逻辑上是二叉树，存储基于数组（数字按小到大排序）。（参见intset.c）

intset在文件存储中结构如下：[编码属性：4个字节][元素个数：4个字节][元素内容]。

其中"编码属性”是一个4个字节的integer值，需要用来表示当前intset中每个integer使用的字节个数,可能是“2”“4”“8”三种之一，如果是“4”,则表示当前intset中所有的元素都是4个字节的integer，那么在此后的对于“元素内容”时就按照4个字节编码一个integer。

“元素个数”表示intset中有多少个integer值，“元素内容”为连续的字节序列，可以根据“编码属性”来逐个获取integer值。
 
Java代码  

```
##intset中允许保存的最大条目个数,如果达到阀值,intset将会被重构为hashtable  
set-max-intset-entries 64  
```
 
## 2) hashtable：

在此需要声明，set结构在redis文件存储中，并不是hashtable，而是按照ziplist的方式存储，其实也很好理解，因为set在逻辑上为了更好的“重复检测”，使用了hashtable；但是其数据结构却很像list，因为在文件存储时，set的按照ziplist的方式序列化到文件。
 
# 七.sortedset(zset)：

排序集合，集合中每个元素都有“权重”，zset在元素个数较少时，采取ziplist，当达到阀值之后被重构为skiplist；插入新数据，就意味着“排序”，意味着数组会被不断的调整，在元素个数较多时，性能会很低下；skiplist即为跳跃表，这种数据结构，在很多语言中都有自己的实现，当然实现方式各有差异，在此也不深入讨论redis如何“变种”skiplist，简单提一下skiplist的原理：

我们发现linkedlist具有优秀的“插入/删除”性能，但是缺少对“权重”顺序（关系）的维护；如果linkedlist中数据是严格排序之后的，那么在其中插入或者查找一条数据，最直接的算法也就是“二分法”查找：找到linkedlist的中间位置数据，然后比较.....既然我们采取了linkedlist，就意味着我们需要它存储“较多”的元素，那么提高它的查询性能是首要的任务。skiplist底层基于排序的linkedlist，并额外的增加了一种“关系维护”数据结构，这种结构的思路很像数据库的“二级索引”，我们通过“索引”来查找数据似乎更加的高效(最极端情况接近二分查找)；任何新插入的数据，都会首先计算“索引”的位置并构建“索引”。

```
Java代码  
0--------------------------------------------15->--------------N     
|                                            |  
0---------------5->--------------------------15->--------------N  
|               |                            |  
0---------------5->----------10->------------15->--------------N  
|               |             |              |  
0------3->------5->----------10->----13->----15->----18--------N(底层排序链表)  
左边界                                                         右边界  
```

底层的linkedlist就不再赘言，skiplist的“索引”部分，首先有表高,此例中表的高度为4,表的高度可以随着元素的个数增加而不断调整，调整的算法任意(比如，表的高度为元素个数的2的冪数，也可以为定高)；左边界为最小值(list中允许的最小值)，如果list中存储的都是正数，左边界可以为0,左边界为“前驱”，它的高度和表高一致，任何改变表高的操作都需要调整“左边界”；右边界设计思路和“左边界”一样。在skiplist中插入任何一个元素，都必须首先计算其“高度”，计算的方式很多，你可以使用随机算法，但是元素的“高度”不得超过表高；skiplist中任何节点都具有“下驱”指针和“右驱”指针(不包括底层linkedlist)，“下驱”指针指向表的“下一高度”，“右驱”指针指向当前“高度”的下一个节点，下一个节点的值必将比当前值大。任何一个表节点，必须和当前高度以及“低高度”的节点建立“下驱”“右驱指针”；比如5这个表节点，在高度为1~2时，都需要和10建立关系，在高度为3时和15建立关系。不过需要注意，表节点和元素是2个概念，比如5这个元素，它目前有3个表节点，节点的值指针都指向“5”,但是这3个节点的“右驱”和“下驱”信息不同，他们是3个不同的表节点。

最终，skiplist在内存中，就是一个“网”，比如查找13这个元素，那么首先从“左边界”开始，高度为4的“0节点”其右驱为15,因为大于13，以此需要降低高度，高度为3的“0节点”右驱为5,则前进（根据右驱指针），“5节点”的右驱为15,则继续降低高度（根据下驱指针），高度为2的“5节点”值为10,继续前进，高度1时，继续遍历，即可找到。

讲了半天和redis没有关系的事情，zset的文件存储结构为[value,score,value,score...]，value为字符串，score为integer。
 
Java代码  

```
##zset使用ziplist编码时，允许的元素个数  
zset-max-ziplist-entries 64  
##允许的元素字节尺寸  
zset-max-ziplist-value 512  
  
##达到阀值，将会被重构为skiplist  
    Redis操作指令：zadd score key;其中score为排序的权重。 
```

# 八.hash：

通过hset可以创建一个map，redis之所以提供map这种数据结构，可以考虑到redis本身缺乏“结构化”数据的管理；map中允许存储一定数量的k-v小数据，而且查询非常方便，这种数据结构对某些场景非常有用：比如我们需要在redis中存储大量的用户信息(user)，每个user包括多个字段属性；如果没有map，我们极有可能把user信息转换成其他结构化数据(json,xml等)存储在redis中，如果我们期望获取user的一个字段信息，那么我们也不得不把整个user全部读取然后解析，性能损耗还是非常大的；有了map之后，那么就可以把user的每个字段 + 值，作为k-v条目存储在map中，如果只想获取user的一个字段信息，直接使用redis即可，无需全部输出整个user。
   

Java代码  

```
HSET userid:100001 name zhangsan  

HSET userid:100001 age 24  
  
HGET userid:100001 name   

redis对于map的存储也非常的直观，如果map的条目个数较少，则使用ziplist，否则使用hashtable；考虑的因素仍然是基于性能。 
 
底层文件存储基于ziplist，格式为[k1,v1,k2,v2].
 
Java代码  

```
##ziplist中允许的条目个数  
hash-max-ziplist-entries 64  
##ziplist中每个条目(K-V)的V允许的最大字节数  
hash-max-ziplist-value 512  
  
##如果达到阀值，则重构为hashtable  
```
# 九.小结：

Redis.conf中为我们提供了编码方式的选择，其中“*-ziplist-entries”值是影响性能的首要条件，它比"*-ziplist-value"更加重要；在生产环境中，我们建议entries的个数应该小一些，“value”字节长度根据实际情况设定，比如：
 
Java代码  

```
list-max-ziplist-entries 64  
list-max-ziplist-value 1024  
```
你可以在链接中(比如redis-cli窗口)通过：config set list-max-ziplist-entries 128来动态调整它，以便测试。 
 
Redis为我们提供了多种数据结构，合理正确的使用它们，可以为我们解决很多“纠结”的问题。

# 十、Rehash机制

如上所述，Redis的顶层数据结构为HASH，用来存储K-V数据，随着Redis数据的不断增加，HASH的冲突也会达到factor（默认为1），为了提高HASH的存取效率，需要rehash。

## 1）根据当前HASH中已有数据的条数（used），新的hash空间大小为首个大于used * 2的2的n次方。比如used为7，首个大于7 * 的，2的n次方为16，那么新的HASH空间为16。

## 2）如果是HASH收缩操作，比如大量删除数据后，执行hash收缩，新的HASH空间为首个大于used的2的n次方；比如used为7，那么新的HASH空间为8。

## 3）此时，新旧HASH同时存在，rehash的过程就是将旧HASH中的数据重新hash到新的HASH结构中。与JAVA中的hashmap的rehash机制类似。
    4）当旧hash中的数据全部迁移完毕后，删除旧hash，释放空间。

Java代码  

```
##是否开启rehash，默认开启  
activerehashing yes  
```

在redis中，数据量较大时，比如数百万的数据，如果采用类似于JAVA的“直接rehashing”或许会带来很大问题，将可能导致redis阻塞较长的时间，而无法服务。那么redis中，采用“渐进式的rehash”，即旧HASH表中的数据分次、逐步的迁移到新的HASH表中，在此期间两个HASH共存。

旧的HASH数据结果中，有一个标识属性rehashindex，表示“是否在进行rehash”，当rehash时此值为0；在rehash期间，在对HASH进行insert、delete、get、set操作时，顺带将旧的HASH中的数据迁移到新的HASH中，每次迁移后都将rehashindex++；当旧的hash中的数据全部迁移后，rehash结束，rehashindex设置为-1。从而可见，rehash的过程分散在数据的多次操作中，而不是集中式的。

rehash期间，新旧HASH共存，所以数据操作也会在两个HASH之间同时进行，数据操作首先在旧HASH中，如果旧HASH中不存在，则在新HASH中进行；比如get操作，首先检查旧HASH中是否存在，如果存在，则对此K-V进行rehash迁移到新的HASH中（在旧HASH中移除），然后在返回，如果旧HASH中不存在，则检查新HASH中是否存在。其他的操作类似，最终确保，新的数据最终在新HASH中保存，旧的数据一旦被访问则被rehash到新HASH中。直到旧HASH中数据（keys为空）迁移完毕。
 
# 十一、过期Key的移除策略

## 1）我们可以对key设置expire属性，表示此key的TTL时间。

## 2）在get、set等数据操作时，如果此key已经过期，则执行delete操作，然后再执行此key的相关操作（比如set等）；这是延迟删除过期key的策略。

## 3）此外，redis还有一个定期删除策略，redis会间歇执行删除任务，每次删除时，选择多个databases，并从每个database中的expirekeys集合中（具有expire属性的keys），随机选择多个keys，并判断它们是否过期，如果过期则删除。
 
十二、redis客户端处理

Redis服务器是一个单进程单线程、基于IO事件的处理客户端请求的Server；这一点可能与一些多线程、actor模式的Server设计有些不同；当客户端与Redis建立连接后，Redis Server将会为此连接创建一个redisClient对象实例，实例中包括IO请求的所有状态，并且所有的redisClient会被保存在一个链表结构中，网络交互是就NIO模式，当某个连接上有数据事件时，将从链表中找到redisClient并进行相应的数据操作（网络交互，buffer，状态修改等）。

