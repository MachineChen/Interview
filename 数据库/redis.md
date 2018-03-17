# Redis 是什么

Redis 是速度非常快的非关系型（NoSQL）内存键值数据库，可以存储键和五种不同类型的值之间的映射。

五种类型数据类型为：字符串、列表、集合、有序集合、散列表。

Redis 支持很多特性，例如将内存中的数据持久化到硬盘中，使用复制来扩展读性能，使用分片来扩展写性能。

# Redis 的五种基本类型

| 数据类型 | 可以存储的值 | 操作 |
| -- | -- | -- |
| Strings | 字符串、整数或者浮点数 | 对整个字符串或者字符串的其中一部分执行操作</br> 对整数和浮点数执行自增或者自减操作 |
| Lists | 链表 | 从两端压入或者弹出元素</br> 读取单个或者多个元素</br> 进行修剪，只保留一个范围内的元素 |
| Sets | 无序集合 | 添加、获取、移除单个元素</br> 检查一个元素是否存在于集合中</br> 计算交集、并集、差集</br> 从集合里面随机获取元素 |
| Hashs | 包含键值对的无序散列表 | 添加、获取、移除单个键值对</br> 获取所有键值对</br> 检查某个键是否存在|
| Sorted Sets | 有序集合 | 添加、获取、删除元素个元素</br> 根据分值范围或者成员来获取元素</br> 计算一个键的排名 |

# Redis常用命令

1 连接操作命令

    quit：关闭连接（connection）
    auth：简单密码认证
    help cmd： 查看cmd帮助，例如：help quit

2 持久化

    save：将数据同步保存到磁盘
    bgsave：将数据异步保存到磁盘
    lastsave：返回上次成功将数据保存到磁盘的Unix时戳
    shutdown：将数据同步保存到磁盘，然后关闭服务

3 远程服务控制

    info：提供服务器的信息和统计
    monitor：实时转储收到的请求
    slaveof：改变复制策略设置
    config：在运行时配置Redis服务器

4 对key操作的命令

    exists(key)：确认一个key是否存在
    del(key)：删除一个key
    type(key)：返回值的类型
    keys(pattern)：返回满足给定pattern的所有key
    randomkey：随机返回key空间的一个
    keyrename(oldname, newname)：重命名key
    dbsize：返回当前数据库中key的数目
    expire：设定一个key的活动时间（s）
    ttl：获得一个key的活动时间
    select(index)：按索引查询
    move(key, dbindex)：移动当前数据库中的key到dbindex数据库
    flushdb：删除当前选择数据库中的所有key
    flushall：删除所有数据库中的所有key

5 String

    set(key, value)：给数据库中名称为key的string赋予值value
    get(key)：返回数据库中名称为key的string的value
    getset(key, value)：给名称为key的string赋予上一次的value
    mget(key1, key2,…, key N)：返回库中多个string的value
    setnx(key, value)：添加string，名称为key，值为value
    setex(key, time, value)：向库中添加string，设定过期时间time
    mset(key N, value N)：批量设置多个string的值
    msetnx(key N, value N)：如果所有名称为key i的string都不存在
    incr(key)：名称为key的string增1操作
    incrby(key, integer)：名称为key的string增加integer
    decr(key)：名称为key的string减1操作
    decrby(key, integer)：名称为key的string减少integer
    append(key, value)：名称为key的string的值附加value
    substr(key, start, end)：返回名称为key的string的value的子串

6 List

    rpush(key, value)：在名称为key的list尾添加一个值为value的元素
    lpush(key, value)：在名称为key的list头添加一个值为value的 元素
    llen(key)：返回名称为key的list的长度
    lrange(key, start, end)：返回名称为key的list中start至end之间的元素
    ltrim(key, start, end)：截取名称为key的list
    lindex(key, index)：返回名称为key的list中index位置的元素
    lset(key, index, value)：给名称为key的list中index位置的元素赋值
    lrem(key, count, value)：删除count个key的list中值为value的元素
    lpop(key)：返回并删除名称为key的list中的首元素
    rpop(key)：返回并删除名称为key的list中的尾元素
    blpop(key1, key2,… key N, timeout)：lpop命令的block版本。
    brpop(key1, key2,… key N, timeout)：rpop的block版本。
    rpoplpush(srckey, dstkey)：返回并删除名称为srckey的list的尾元素，并将该元素添加到名称为dstkey的list的头部

7 Set

    sadd(key, member)：向名称为key的set中添加元素member
    srem(key, member) ：删除名称为key的set中的元素member
    spop(key) ：随机返回并删除名称为key的set中一个元素
    smove(srckey, dstkey, member) ：移到集合元素
    scard(key) ：返回名称为key的set的基数
    sismember(key, member) ：member是否是名称为key的set的元素
    sinter(key1, key2,…key N) ：求交集
    sinterstore(dstkey, (keys)) ：求交集并将交集保存到dstkey的集合
    sunion(key1, (keys)) ：求并集
    sunionstore(dstkey, (keys)) ：求并集并将并集保存到dstkey的集合
    sdiff(key1, (keys)) ：求差集
    sdiffstore(dstkey, (keys)) ：求差集并将差集保存到dstkey的集合
    smembers(key) ：返回名称为key的set的所有元素
    srandmember(key) ：随机返回名称为key的set的一个元素

8 Hash

    hset(key, field, value)：向名称为key的hash中添加元素field
    hget(key, field)：返回名称为key的hash中field对应的value
    hmget(key, (fields))：返回名称为key的hash中field i对应的value
    hmset(key, (fields))：向名称为key的hash中添加元素field
    hincrby(key, field, integer)：将名称为key的hash中field的value增加integer
    hexists(key, field)：名称为key的hash中是否存在键为field的域
    hdel(key, field)：删除名称为key的hash中键为field的域
    hlen(key)：返回名称为key的hash中元素个数
    hkeys(key)：返回名称为key的hash中所有键
    hvals(key)：返回名称为key的hash中所有键对应的value
    hgetall(key)：返回名称为key的hash中所有的键（field）及其对应的value


# 键的过期时间

Redis 可以为每个键设置过期时间，当键过期时，会自动删除该键。

对于散列表这种容器，只能为整个键设置过期时间（整个散列表），而不能为键里面的单个元素设置过期时间。

过期时间对于清理缓存数据非常有用。

EXPIRE key #s    将KEY的生存时间设置为#秒
PEXPIRE key #ms  将KEY的生存时间设置为#毫秒
EXPIREAT key timestamp   将KEY的生存时间设置为UNIX时间戳，单位为秒
PEXPIREAT key timestamp  将KEY的生存时间设置为UNIX时间戳，单位为毫秒

上面这4个命令只是单位和表现形式上的不同，但实际上EXPIRE、PEXPIRE以及EXPIREAT命令的执行最后都会使用PEXPIREAT来实行。

如何查看一个键的生存时间多多少呢？可以使用ttl key来获取（以秒来显示）
-2  过期且已删除
-1  没有过期时间设置，即永不过期
>0  表示距离过期还有多少秒或者毫秒
另外还有一个命令是pttl key这个是以毫秒显示
可以使用PERSIST命令移除一个键的过期时间

# 事务

Redis 最简单的事务实现方式是使用 MULTI 和 EXEC 命令将事务操作包围起来。

MULTI 和 EXEC 中的操作将会一次性发送给服务器，而不是一条一条发送，这种方式称为流水线，它可以减少客户端与服务器之间的网络通信次数从而提升性能。

# 持久化

Redis 是内存型数据库，为了保证数据在断电后不会丢失，需要将内存中的数据持久化到硬盘上。

## 1. 快照持久化

将某个时间点的所有数据都存放到硬盘上。

可以将快照复制到其它服务器从而创建具有相同数据的服务器副本。

如果系统发生故障，将会丢失最后一次创建快照之后的数据。并且如果数据量很大，保存快照的时间也会很长。

在RDB方式下，你有两种选择，一种是手动执行持久化数据命令来让redis进行一次数据快照，另一种则是根据你所配置的配置文件 的 策略，达到策略的某些条件时来自动持久化数据。而手动执行持久化命令，你依然有两种选择，那就是save命令和bgsave命令。

save操作在Redis主线程中工作，因此会阻塞其他请求操作，应该避免使用。

（默认下，持久化到dump.rdb文件，并且在redis重启后，自动读取其中文件，据悉，通常情况下一千万的字符串类型键，1GB的快照文件，同步到内存中的 时间是20-30秒）

bgSave则是调用Fork,产生子进程，父进程继续处理请求。子进程将数据写入临时文件，并在写完后，替换原有的.rdb文件。Fork发生时，父子进程内存共享，所以为了不影响子进程做数据快照，在这期间修改的数据，将会被复制一份，而不进共享内存。所以说，RDB所持久化的数据，是Fork发生时的数据。在这样的条件下进行持久化数据，如果因为某些情况宕机，则会丢失一段时间的数据。如果你的实际情况对数据丢失没那么敏感，丢失的也可以从传统数据库中获取或者说丢失部分也无所谓，那么你可以选择RDB持久化方式。

save 900 1
save 300 10
save 60 1000

这是配置文件默认的策略，他们之间的关系是或，每隔900秒，在这期间变化了至少一个键值，做快照。或者每三百秒，变化了十个键值做快照。或者每六十秒，变化了至少一万个键值，做快照。

## 2. AOF 持久化

AOF 持久化将写命令添加到 AOF 文件（Append Only File）的末尾。

对硬盘的文件进行写入时，写入的内容首先会被存储到缓冲区，然后由操作系统决定什么时候将该内容同步到硬盘，用户可以调用 file.flush() 方法请求操作系统尽快将缓冲区存储的数据同步到硬盘。因此将写命令添加到 AOF 文件时，要根据需求来保证何时将添加的数据同步到硬盘上，有以下同步选项：

| 选项 | 同步频率 |
| -- | -- |
| always | 每个写命令都同步 |
| everysec | 每秒同步一次 |
| no | 让操作系统来决定何时同步 |

always 选项会严重减低服务器的性能；everysec 选项比较合适，可以保证系统奔溃时只会丢失一秒左右的数据，并且 Redis 每秒执行一次同步对服务器性能几乎没有任何影响；no 选项并不能给服务器性能带来多大的提升，而且也会增加系统奔溃时数据丢失的数量。

随着服务器写请求的增多，AOF 文件会越来越大；Redis 提供了一种将 AOF 重写的特性，能够去除 AOF 文件中的冗余写命令。

# 主从模式

通过使用 slaveof host port 命令来让一个服务器成为另一个服务器的从服务器。

一个从服务器只能有一个主服务器，并且不支持主主复制。

**1. 主从模式的作用** 

(1)redis主从配置，配置master 只能为写，slave只能为读，在客户端对poolconnect请求时候，,会将读请求转到slave上面，写请求转到master上面，做到读写分离。

(2)master和slave有同步功能，这就实现了（数据层）读写分离对上层（逻辑层）透明的正常逻辑。无需再通过中间件或者代码进行读写分析实现。

**2. 从服务器连接主服务器的过程** 

(1) 主服务器创建快照文件，发送给从服务器，并在发送期间使用缓冲区记录执行的写命令。快照文件发送完毕之后，开始向从服务器发送存储在缓冲区中的写命令；
(2) 从服务器丢弃所有旧数据，载入主服务器发来的快照文件，之后从服务器开始接受主服务器发来的写命令；
(3) 主服务器每执行一次写命令，就向从服务器发送相同的写命令。

**3. 主从链** 

随着负载不断上升，主服务器可能无法很快地更新所有从服务器，或者重新连接和重新同步从服务器而导致系统超载。为了解决这个问题，可以创建一个中间层来分担主服务器的复制工作。中间层的服务器是最上层服务器的从服务器，又是最下层服务器的主服务器。

**4. 主从链配置** 

修改从服务器的配置，添加主服务器的地址和端口增加一行：
slaveof ip port

# 哨兵模式

哨兵的作用：
1、监控redis进行状态，包括master和slave
2、当master down机，能自动将slave切换成master

info replication --->查看当前redis信息

# 处理故障

要用到持久化文件来恢复服务器的数据。

持久化文件可能因为服务器出错也有错误，因此要先对持久化文件进行验证和修复。对 AOF 文件就行验证和修复很容易，修复操作将第一个出错命令和其后的所有命令都删除；但是只能验证快照文件，无法对快照文件进行修复，因为快照文件进行了压缩，出现在快照文件中间的错误可能会导致整个快照文件的剩余部分无法读取。

当主服务器出现故障时，Redis 常用的做法是新开一台服务器作为主服务器，具体步骤如下：假设 A 为主服务器，B 为从服务器，当 A 出现故障时，让 B 生成一个快照文件，将快照文件发送给 C，并让 C 恢复快照文件的数据。最后，让 B 成为 C 的从服务器。

# 分片

Redis 中的分片类似于 MySQL 的分表操作，分片是将数据划分为多个部分的方法，对数据的划分可以基于键包含的 ID、基于键的哈希值，或者基于以上两者的某种组合。通过对数据进行分片，用户可以将数据存储到多台机器里面，也可以从多台机器里面获取数据，这种方法在解决某些问题时可以获得线性级别的性能提升。

假设有 4 个 Reids 实例 R0，R1，R2，R3，还有很多表示用户的键 user:1，user:2，... 等等，有不同的方式来选择一个指定的键存储在哪个实例中。最简单的方式是范围分片，例如用户 id 从 0\~1000 的存储到实例 R0 中，用户 id 从 1001\~2000 的存储到实例 R1 中，等等。但是这样需要维护一张映射范围表，维护操作代价很高。还有一种方式是哈希分片，使用 CRC32 哈希函数将键转换为一个数字，再对实例数量求模就能知道应该存储的实例。

**1. 客户端分片** 

客户端使用一致性哈希等算法决定键应当分布到哪个节点。

**2. 代理分片** 

将客户端请求发送到代理上，由代理转发请求到正确的节点上。

**3. 服务器分片** 

Redis Cluster。

# 事件

**1. 事件类型** 

(1) 文件事件：服务器有许多套接字，事件产生时会对这些套接字进行操作，服务器通过监听套接字来处理事件。常见的文件事件有：客户端的连接事件；客户端的命令请求事件；服务器向客户端返回命令结果的事件；

(2) 时间事件：又分为两类，定时事件是让一段程序在指定的时间之内执行一次；周期性时间是让一段程序每隔指定时间就执行一次。

**2. 事件的调度与执行** 

服务器需要不断监听文件事件的套接字才能得到待处理的文件事件，但是不能监听太久，否则时间事件无法在规定的时间内执行，因此监听时间应该根据距离现在最近的时间事件来决定。

事件调度与执行由 aeProcessEvents 函数负责，伪代码如下：

```python
def aeProcessEvents():

    # 获取到达时间离当前时间最接近的时间事件
    time_event = aeSearchNearestTimer()

    #计算最接近的时间事件距离到达还有多少毫秒
    remaind_ms = time_event.when - unix_ts_now()

    # 如果事件已到达，那么 remaind_ms 的值可能为负数，将它设为 0
    if remaind_ms < 0:
        remaind_ms = 0

    # 根据 remaind_ms 的值，创建 timeval
    timeval = create_timeval_with_ms(remaind_ms)

    # 阻塞并等待文件事件产生，最大阻塞时间由传入的 timeval 决定
    aeApiPoll(timeval)

    # 处理所有已产生的文件事件
    procesFileEvents()

    # 处理所有已到达的时间事件
    processTimeEvents()
```

将 aeProcessEvents 函数置于一个循环里面，加上初始化和清理函数，就构成了 Redis 服务器的主函数，伪代码如下：

```python
def main():

    # 初始化服务器
    init_server()

    # 一直处理事件，直到服务器关闭为止
    while server_is_not_shutdown():
        aeProcessEvents()

    # 服务器关闭，执行清理操作
    clean_server()
```

# Redis 与 Memcached 的区别

两者都是非关系型内存键值数据库。有以下主要不同：

**1. 数据类型** 

Memcached 仅支持字符串类型，而 Redis 支持五种不同种类的数据类型，使得它可以更灵活地解决问题。

**2. 数据持久化** 

Redis 支持两种持久化策略：RDB 快照和 AOF 日志，而 Memcached 不支持持久化。

**3. 分布式** 

Memcached 不支持分布式，只能通过在客户端使用像一致性哈希这样的分布式算法来实现分布式存储，这种方式在存储和查询时都需要先在客户端计算一次数据所在的节点。

Redis Cluster 实现了分布式的支持。

**4. 内存管理机制** 

在 Redis 中，并不是所有数据都一直存储在内存中，可以将一些很久没用的 value 交换到磁盘。而 Memcached 的数据则会一直在内存中。

Memcached 将内存分割成特定长度的块来存储数据，以完全解决内存碎片的问题，但是这种方式会使得内存的利用率不高，例如块的大小为 128 bytes，只存储 100 bytes 的数据，那么剩下的 28 bytes 就浪费掉了。

**5. 淘汰机制机制** 

redis中当内存超过限制时，按照配置的策略，淘汰掉相应的kv，使得内存可以继续留有足够的空间保存新的数据。redis 确定驱逐某个键值对后，会删除这个数据并将这个数据变更消息发布到本地（AOF 持久化）和从机（主从连接）。

（LRU 数据淘汰机制

在服务器配置中保存了 lru 计数器 server.lrulock，会定时（Redis 定时程序serverCorn()）更新，server.lrulock 的值是根据 server.unixtime 计算出来的。

每一个 Redis 对象都会设置相应的 lru，即最近访问的时间。可以想象的是，每一次访问数据的时候，会更新 redisObject.lru。

LRU 数据淘汰机制是这样的：在数据集中随机挑选几个键值对，取出其中 lru 最大的键值对淘汰。所以，你会发现，Redis 并不是保证取得所有数据集中最近最少使用（LRU）的键值对，而只是随机挑选的几个键值对中的。）

Memcached为每个item设置一个过期时间，但不是到期就把item从内存删除，而是访问item时，如果到了有效期，才把item从内存中删除。

当Memcached使用内存大于设置的最大内存使用时，为了腾出内存空间来存放新的数据项，Memcached会启动LRU算法淘汰旧的数据项。

# Redis 适用场景

**1. 缓存** 

适用 Redis 作为缓存，将热点数据放到内存中。

**2. 消息队列** 

Redis 的 list 类型是双向链表，很适合用于消息队列。

**3. 计数器** 

Redis 这种内存数据库才能支持计数器的频繁读写操作。

**4. 好友关系** 

使用 set 类型的交集很容易就可以知道两个用户的共同好友。

# 数据淘汰策略

可以设置内存最大使用量，当内存使用量超过时施行淘汰策略，具体有 6 种淘汰策略。

| 策略 | 描述 |
| -- | -- |
| volatile-lru | 从已设置过期时间的数据集中挑选最近最少使用的数据淘汰 |
| volatile-ttl | 从已设置过期时间的数据集中挑选将要过期的数据淘汰 |
|volatile-random | 从已设置过期时间的数据集中任意选择数据淘汰 |
| allkeys-lru | 从所有数据集中挑选最近最少使用的数据淘汰 |
| allkeys-random | 从所有数据集中任意选择数据进行淘汰 |
| no-envicition | 禁止驱逐数据 |

如果使用 Redis 来缓存数据时，要保证所有数据都是热点数据，可以将内存最大使用量设置为热点数据占用的内存量，然后启用 allkeys-lru 淘汰策略，将最近最少使用的数据淘汰。