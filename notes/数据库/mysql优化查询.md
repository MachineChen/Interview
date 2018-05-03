# 如何查看语句使用了索引

首先解释说明一下Explain命令，Explain命令在解决数据库性能上是第一推荐使用命令，大部分的性能问题可以通过此命令来简单的解决，Explain可以用来查看 SQL 语句的执行效果，可以帮助选择更好的索引和优化查询语句，写出更好的优化语句。

Explain语法：explain select … from … [where ...]

例如：explain select * from news;

输出：

+----+-------------+-------+-------+-------------------+---------+---------+-------+------+-------+
| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
+----+-------------+-------+-------+-------------------+---------+---------+-------+------+-------+

下面对各个属性进行了解：

1、id：这是SELECT的查询序列号

id列数字越大越先执行，如果说数字一样大，那么就从上往下依次执行，id列为null的就表是这是一个结果集，不需要使用它来进行查询。

2、select_type：select_type就是select的类型，可以有以下几种：

simple：表示不需要union操作或者不包含子查询的简单select查询。有连接查询时，外层的查询为simple，且只有一个

primary：一个需要union操作或者含有子查询的select，位于最外层的单位查询的select_type即为primary。且只有一个

union：union连接的两个select查询，第一个查询是dervied派生表，除了第一个表外，第二个以后的表select_type都是union

dependent union：与union一样，出现在union 或union all语句中，但是这个查询要受到外部查询的影响

union result：包含union的结果集，在union和union all语句中,因为它不需要参与查询，所以id字段为null

subquery：除了from字句中包含的子查询外，其他地方出现的子查询都可能是subquery

dependent subquery：与dependent union类似，表示这个subquery的查询要受到外部表查询的影响

derived：from字句中出现的子查询，也叫做派生表，其他数据库中可能叫做内联视图或嵌套select

3、table：显示这一行的数据是关于哪张表的

显示的查询表名，如果查询使用了别名，那么这里显示的是别名，如果不涉及对数据表的操作，那么这显示为null，如果显示为尖括号括起来的<derived N>就表示这个是临时表，后边的N就是执行计划中的id，表示结果来自于这个查询产生。如果是尖括号括起来的<union M,N>，与<derived N>类似，也是一个临时表，表示这个结果来自于union查询的id为M,N的结果集。

4、type：这列最重要，显示了连接使用了哪种类别,有无使用索引，是使用Explain命令分析性能瓶颈的关键项之一。

结果值从好到坏依次是：

system > const > eq_ref > ref > fulltext > ref_or_null > index_merge > unique_subquery > index_subquery > range > index > ALL

一般来说，得保证查询至少达到range级别，最好能达到ref，否则就可能会出现性能问题。

system：表中只有一行数据或者是空表，且只能用于myisam和memory表。如果是Innodb引擎表，type列在这个情况通常都是all或者index

const：使用唯一索引或者主键，返回记录一定是1行记录的等值where条件时，通常type是const。其他数据库也叫做唯一索引扫描

eq_ref：出现在要连接过个表的查询计划中，驱动表只返回一行数据，且这行数据是第二个表的主键或者唯一索引，且必须为not null，唯一索引和主键是多列时，只有所有的列都用作比较时才会出现eq_ref

ref：不像eq_ref那样要求连接顺序，也没有主键和唯一索引的要求，只要使用相等条件检索时就可能出现，常见与辅助索引的等值查找。或者多列主键、唯一索引中，使用第一个列之外的列作为等值查找也会出现，总之，返回数据不唯一的等值查找就可能出现。

fulltext：全文索引检索，要注意，全文索引的优先级很高，若全文索引和普通索引同时存在时，mysql不管代价，优先选择使用全文索引

ref_or_null：与ref方法类似，只是增加了null值的比较。实际用的不多。

unique_subquery：用于where中的in形式子查询，子查询返回不重复值唯一值

index_subquery：用于in形式子查询使用到了辅助索引或者in常数列表，子查询可能返回重复值，可以使用索引将子查询去重。

range：索引范围扫描，常见于使用>,<,is null,between ,in ,like等运算符的查询中。

index_merge：表示查询使用了两个以上的索引，最后取交集或者并集，常见and ，or的条件使用了不同的索引，官方排序这个在ref_or_null之后，但是实际上由于要读取所个索引，性能可能大部分时间都不如range

index：索引全表扫描，把索引从头到尾扫一遍，常见于使用索引列就可以处理不需要读取数据文件的查询、可以使用索引排序或者分组的查询。

all：这个就是全表扫描数据文件，然后再在server层进行过滤返回符合要求的记录。

5、possible_keys：列指出MySQL能使用哪个索引在该表中找到行

查询可能使用到的索引都会在这里列出来

6、key：显示MySQL实际决定使用的键（索引）。如果没有选择索引，键是NULL

查询真正使用到的索引，select_type为index_merge时，这里可能出现两个以上的索引，其他的select_type这里只会出现一个。

7、key_len：显示MySQL决定使用的键长度。如果键是NULL，则长度为NULL。使用的索引的长度。在不损失精确性的情况下，长度越短越好

用于处理查询的索引长度，如果是单列索引，那就整个索引长度算进去，如果是多列索引，那么查询不一定都能使用到所有的列，具体使用到了多少个列的索引，这里就会计算进去，没有使用到的列，这里不会计算进去。留意下这个列的值，算一下你的多列索引总长度就知道有没有使用到所有的列了。要注意，mysql的ICP特性使用到的索引不会计入其中。另外，key_len只计算where条件用到的索引长度，而排序和分组就算用到了索引，也不会计算到key_len中。

8、ref：显示使用哪个列或常数与key一起从表中选择行。

如果是使用的常数等值查询，这里会显示const，如果是连接查询，被驱动表的执行计划这里会显示驱动表的关联字段，如果是条件使用了表达式或者函数，或者条件列发生了内部隐式转换，这里可能显示为func

9、rows：显示MySQL认为它执行查询时必须检查的行数。

这里是执行计划中估算的扫描行数，不是精确值

10、Extra：包含MySQL解决查询的详细信息，也是关键参考项之一。

这个列可以显示的信息非常多，有几十种，常用的有

A：distinct：在select部分使用了distinc关键字
B：no tables used：不带from字句的查询或者From dual查询
C：使用not in()形式子查询或not exists运算符的连接查询，这种叫做反连接。即，一般连接查询是先查询内表，再查询外表，反连接就是先查询外表，再查询内表。
D：using filesort：排序时无法使用到索引时，就会出现这个。常见于order by和group by语句中
E：using index：查询时不需要回表查询，直接通过索引就可以获取查询的数据。
F：using join buffer（block nested loop），using join buffer（batched key accss）：5.6.x之后的版本优化关联查询的BNL，BKA特性。主要是减少内表的循环数量以及比较顺序地扫描查询。
G：using sort_union，using_union，using intersect，using sort_intersection：
using intersect：表示使用and的各个索引的条件时，该信息表示是从处理结果获取交集
using union：表示使用or连接各个使用索引的条件时，该信息表示从处理结果获取并集
using sort_union和using sort_intersection：与前面两个对应的类似，只是他们是出现在用and和or查询信息量大时，先查询主键，然后进行排序合并后，才能读取记录并返回。
H：using temporary：表示使用了临时表存储中间结果。临时表可以是内存临时表和磁盘临时表，执行计划中看不出来，需要查看status变量，used_tmp_table，used_tmp_disk_table才能看出来。
I：using where：表示存储引擎返回的记录并不是所有的都满足查询条件，需要在server层进行过滤。查询条件中分为限制条件和检查条件，5.6之前，存储引擎只能根据限制条件扫描数据并返回，然后server层根据检查条件进行过滤再返回真正符合查询的数据。5.6.x之后支持ICP特性，可以把检查条件也下推到存储引擎层，不符合检查条件和限制条件的数据，直接不读取，这样就大大减少了存储引擎扫描的记录数量。extra列显示using index condition
J：firstmatch(tb_name)：5.6.x开始引入的优化子查询的新特性之一，常见于where字句含有in()类型的子查询。如果内表的数据量比较大，就可能出现这个
K：loosescan(m..n)：5.6.x之后引入的优化子查询的新特性之一，在in()类型的子查询中，子查询返回的可能有重复记录时，就可能出现这个
 
除了这些之外，还有很多查询数据字典库，执行计划过程中就发现不可能存在结果的一些提示信息

# mysql不使用索引情况（附加示例）：

1 如果MySQL估计使用索引比全表扫描更慢，则不使用索引。例如，如果列key均匀分布在1和100之间，下面的查询使用索引就不是很好：select * from table_name where key>1 and key<90;
 
2 用or分隔开的条件，如果or前的条件中的列有索引，而后面的列没有索引，那么涉及到的索引都不会被用到，例如：select * from table_name where key1='a' or key2='b';如果在key1上有索引而在key2上没有索引，则该查询也不会走索引

3 复合索引，如果索引列不是复合索引的第一部分，则不使用索引（即不符合最左前缀），例如，复合索引为(key1,key2),则查询select * from table_name where key2='b';将不会使用索引

4 如果like是以‘%’开始的，则该列上的索引不会被使用。例如select * from table_name where key1 like '%a'；该查询即使key1上存在索引，也不会被使用

5 如果列为字符串，则where条件中必须将字符常量值加引号，否则即使该列上存在索引，也不会被使用。例如,select * from table_name where key1=1;如果key1列保存的是字符串，即使key1上有索引，也不会被使用。

6 WHERE字句的查询条件里有不等于号（WHERE column!=...）,或<>操作符，否则将引擎放弃使用索引而进行全表扫描。 

7 where 子句中对字段进行 null 值判断 where mobile = null 此查询 不会走索引

8 in 和 not in 也要慎用，否则会导致全表扫描 

9 不要在 where 子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引。

从上面可以看出，即使我们建立了索引，也不一定会被使用，那么我们如何知道我们索引的使用情况呢？？在MySQL中，有Handler_read_key和Handler_read_rnd_key两个变量，如果Handler_read_key值很高而Handler_read_rnd_key的值很低，则表明索引经常不被使用，应该重新考虑建立索引。可以通过:show status like 'Handler_read%'来查看着连个参数的值。

# MySQL中优化sql语句查询常用的方法

1.对查询进行优化，应尽量避免全表扫描，首先应考虑在 where 及 order by 涉及的列上建立索引。 

2.应尽量避免在 where 子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描。 

3.应尽量避免在 where 子句中对字段进行 null 值判断，否则将导致引擎放弃使用索引而进行全表扫描，如： 

select id from t where num is null 

可以在num上设置默认值0，确保表中num列没有null值，然后这样查询： 

select id from t where num=0 

4.应尽量避免在 where 子句中使用 or 来连接条件，否则将导致引擎放弃使用索引而进行全表扫描，如： 

select id from t where num=10 or num=20 

可以这样查询： 

select id from t where num=10 

union all 

select id from t where num=20 

5.下面的查询也将导致全表扫描： 
select id from t where name like '%abc%' 
若要提高效率，可以考虑全文检索。 

6.in 和 not in 也要慎用，否则会导致全表扫描，如： 
select id from t where num in(1,2,3) 
对于连续的数值，能用 between 就不要用 in 了： 
select id from t where num between 1 and 3 

7.如果在 where 子句中使用参数，也会导致全表扫描。因为SQL只有在运行时才会解析局部变量，但优化程序不能将访问计划的选择推迟到运行时；它必须在编译时进行选择。然而，如果在编译时建立访问计划，变量的值还是未知的，因而无法作为索引选择的输入项。如下面语句将进行全表扫描： 
select id from t where num=@num 
可以改为强制查询使用索引： 
select id from t with(index(索引名)) where num=@num 

8.应尽量避免在 where 子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如： 
select id from t where num/2=100 
应改为: 
select id from t where num=100*2 

9.应尽量避免在where子句中对字段进行函数操作，这将导致引擎放弃使用索引而进行全表扫描。如： 
select id from t where substring(name,1,3)='abc'--name以abc开头的id 
select id from t where datediff(day,createdate,'2005-11-30')=0--'2005-11-30'生成的id 
应改为: 
select id from t where name like 'abc%' 
select id from t where createdate>='2005-11-30' and createdate<'2005-12-1' 

10.不要在 where 子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引。 

11.在使用索引字段作为条件时，如果该索引是复合索引，那么必须使用到该索引中的第一个字段作为条件时才能保证系统使用该索引，否则该索引将不会被使用，并且应尽可能的让字段顺序与索引顺序相一致。 

12.不要写一些没有意义的查询，如需要生成一个空表结构： 
select col1,col2 into #t from t where 1=0 
这类代码不会返回任何结果集，但是会消耗系统资源的，应改成这样： 
create table #t(...) 

13.很多时候用 exists 代替 in 是一个好的选择： 
select num from a where num in(select num from b) 
用下面的语句替换： 
select num from a where exists(select 1 from b where num=a.num) 

14.并不是所有索引对查询都有效，SQL是根据表中数据来进行查询优化的，当索引列有大量数据重复时，SQL查询可能不会去利用索引，如一表中有字段sex，male、female几乎各一半，那么即使在sex上建了索引也对查询效率起不了作用。 

15.索引并不是越多越好，索引固然可以提高相应的 select 的效率，但同时也降低了 insert 及 update 的效率，因为 insert 或 update 时有可能会重建索引，所以怎样建索引需要慎重考虑，视具体情况而定。一个表的索引数最好不要超过6个，若太多则应考虑一些不常使用到的列上建的索引是否有必要。 

16.应尽可能的避免更新 clustered 索引数据列，因为 clustered 索引数据列的顺序就是表记录的物理存储顺序，一旦该列值改变将导致整个表记录的顺序的调整，会耗费相当大的资源。若应用系统需要频繁更新 clustered 索引数据列，那么需要考虑是否应将该索引建为 clustered 索引。 

17.尽量使用数字型字段，若只含数值信息的字段尽量不要设计为字符型，这会降低查询和连接的性能，并会增加存储开销。这是因为引擎在处理查询和连接时会逐个比较字符串中每一个字符，而对于数字型而言只需要比较一次就够了。 

18.尽可能的使用 varchar/nvarchar 代替 char/nchar ，因为首先变长字段存储空间小，可以节省存储空间，其次对于查询来说，在一个相对较小的字段内搜索效率显然要高些。 

19.任何地方都不要使用 select * from t ，用具体的字段列表代替“*”，不要返回用不到的任何字段。 

20.尽量使用表变量来代替临时表。如果表变量包含大量数据，请注意索引非常有限（只有主键索引）。 

21.避免频繁创建和删除临时表，以减少系统表资源的消耗。 

22.临时表并不是不可使用，适当地使用它们可以使某些例程更有效，例如，当需要重复引用大型表或常用表中的某个数据集时。但是，对于一次性事件，最好使用导出表。 

23.在新建临时表时，如果一次性插入数据量很大，那么可以使用 select into 代替 create table，避免造成大量 log ，以提高速度；如果数据量不大，为了缓和系统表的资源，应先create table，然后insert。 

24.如果使用到了临时表，在存储过程的最后务必将所有的临时表显式删除，先 truncate table ，然后 drop table ，这样可以避免系统表的较长时间锁定。 

25.尽量避免使用游标，因为游标的效率较差，如果游标操作的数据超过1万行，那么就应该考虑改写。 

26.使用基于游标的方法或临时表方法之前，应先寻找基于集的解决方案来解决问题，基于集的方法通常更有效。 

27.与临时表一样，游标并不是不可使用。对小型数据集使用 FAST_FORWARD 游标通常要优于其他逐行处理方法，尤其是在必须引用几个表才能获得所需的数据时。在结果集中包括“合计”的例程通常要比使用游标执行的速度快。如果开发时间允许，基于游标的方法和基于集的方法都可以尝试一下，看哪一种方法的效果更好。 

28.在所有的存储过程和触发器的开始处设置 SET NOCOUNT ON ，在结束时设置 SET NOCOUNT OFF 。无需在执行存储过程和触发器的每个语句后向客户端发送 DONE_IN_PROC 消息。 

29.尽量避免向客户端返回大数据量，若数据量过大，应该考虑相应需求是否合理。 

30.尽量避免大事务操作，提高系统并发能力。