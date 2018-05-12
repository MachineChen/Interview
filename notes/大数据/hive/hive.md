## hive - 数据仓库工具
### 定义
hive是基于Hadoop的一个数据仓库工具，可以将结构化的数据文件映射成为一张数据库表，并提供简单的sql查询功能，可以将sql语句转化为MapReduce任务进行运行。

### 原理
1. Hive是构建在静态批处理的Hadoop之上的工具，所有hive的数据都存储在Hadoop兼容的文件系统如HDFS中。
2. hive在加载数据过程中不对数据做任何修改，只是将数据移动到HDFS中Hive设定的目录下。因此Hive不支持对数据的行级更新，数据在加载时已经确定
3. hive查询过程严格遵守Hadoop MapReduce的作业执行模型，通过解释器、编译器、优化器、执行器将HiveQL语句转化为MR作业提交到Hadoop集群，集群监控作业执行过程，然后返回执行结果给用户。
4. Hadoop通常有较高延迟，且在作业提交和调度的时候需要大量的开销。因此Hive不能够在大规模数据集上实现低延迟快速查询

### 特点
- 学习成本低，可以通过类SQL语句快速实现简单的MapReduce统计，适合数据仓库的统计分析
- 支持索引，加快数据查询
- 支持不同的存储类型，如纯文本、HBase中的文件
- 将元数据（描述数据的数据，包括表名字、列、分区及属性、表属性、表数据所在目录等）保存在关系数据库中，较少查询过程中语义检查的时间
- 可以直接使用存储在Hadoop文件系统中的数据
- 内置大量用户函数UDF来操作时间、字符串、和其他数据挖掘工具，支持用户扩展UDF

### 使用场景
- 不适合低延迟快速查询的场景（联机事务处理），hive在几百MB的数据集上执行查询一般有分钟级延迟
- 不适合基于行级的数据更新操作
- 适合大数据集的批处理作业，如网络日志分析

### 数据存储
1. Hive没有专门的数据存储格式，也没有为数据建立索引，用户可以非常自由的组织Hive中的表，只需要在创建表的时候告诉Hive数据中的列分隔符和行分隔符，Hive就可以解析数据。
2. Hive中所有数据都存储在HDFS中，数据模型包含
	- 表(Table):类似数据库中的Table,在hive中都有一个相应的目录存储数据。hive-site.xml中由${hive.metastore.warehouse.dir}指定的数据仓库的目录，所有的Table数据（不包括 External Table）都保存在这个目录中。
	- 外部表(External Table):指向已经在HDFS中存在的数据，可以创建Partition.它和 Table 在元数据的组织上是相同的，而实际数据的存储则有较大的差异。
		- Table的创建过程和数据加载过程（这两个过程可以在同一个语句中完成），在加载数据的过程中，实际数据会被移动到数据仓库目录中；之后对数据对访问将会直接在数据仓库目录中完成。删除表时，表中的数据和元数据将会被同时删除。
		- External Table 只有一个过程，加载数据和创建表同时完成（CREATE EXTERNAL TABLE ……LOCATION），实际数据是存储在 LOCATION 后面指定的 HDFS 路径中，并不会移动到数据仓库目录中。当删除一个 External Table 时，仅删除元数据，表中的数据不会真正被删除。
	- 分区(Partition)：对应于数据库中的Partition列的密集索引，但是hive中和数据库中Partition的组织方式很不相同
		- hive中，一个partition对应于表下的一个目录，分区的数据都存储在对应的目录找那个，eg: pvs表中包含ds和city两个分区，对一个于ds=xxx,city=US,对应HDFS子目录为/wh/pvs/ds=xxx/city=US
	- 桶(Bucket)：对指定列就算hash,根据hash值切分数据，目的是为了并行，每一个Bucket对应一个文件。将 user 列分散至 32 个 bucket，首先对 user 列的值计算 hash，对应 hash 值为 0 的 HDFS 目录为：/wh/pvs/ds=20090801/ctry=US/part-00000；hash 值为 20 的 HDFS 目录为：/wh/pvs/ds=20090801/ctry=US/part-00020
3. 基本数据类型：支持多种不同长度的整型和浮点型数据，布尔型，无长度限制的字符串类型
4. hive中的列支持使用struct、map和array集合数据类型。（大多数关系型数据库中不支持这些集合数据类型，因为它们会破坏标准格式。关系型数据库中为实现集合数据类型是由多个表之间建立合适的外键关联来实现。）。在大数据系统中，使用集合类型的数据的好处在于提高数据的吞吐量，减少寻址次数来提高查询速度。

### Hive使用语法

### Hive优化
1. join连接时的优化：当三个或多个以上的表进行join操作时，如果每个on使用相同的字段连接时只会产生一个mapreduce。
2. join连接时的优化：当多个表进行查询时，从左到右表的大小顺序应该是从小到大。原因：hive在对每行记录操作时会把其他表先缓存起来，直到扫描最后的表进行计算
3. 在where字句中增加分区过滤器。
4. 当可以使用left semi join 语法时不要使用inner join，前者效率更高。原因：对于左表中指定的一条记录，一旦在右表中找到立即停止扫描。
5. 如果所有表中有一张表足够小，则可置于内存中，这样在和其他表进行连接的时候就能完成匹配，省略掉reduce过程。设置属性即可实现，set hive.auto.covert.join=true; 用户可以配置希望被优化的小表的大小 set hive.mapjoin.smalltable.size=2500000; 如果需要使用这两个配置可置入$HOME/.hiverc文件中。
6. 同一种数据的多种处理：从一个数据源产生的多个数据聚合，无需每次聚合都需要重新扫描一次。例如：
	
	```
	insert overwrite table student select *　from employee;
	insert overwrite table person select * from employee;
	```
	可以优化成：
	
	```
	from employee 
	insert overwrite table student select * 
	insert overwrite table person select *;
	```

7. limit调优：limit语句通常是执行整个语句后返回部分结果。
	```
	set hive.limit.optimize.enable=true;
	```
8. 开启并发执行。某个job任务中可能包含众多的阶段，其中某些阶段没有依赖关系可以并发执行，开启并发执行后job任务可以更快的完成。设置属性：
	```
	set hive.exec.parallel=true;
	```
9. hive提供的严格模式，禁止3种情况下的查询模式。
	- 当表为分区表时，where字句后没有分区字段和限制时，不允许执行。
	- 当使用order by语句时，必须使用limit字段，因为order by 只会产生一个reduce任务。
	- 限制笛卡尔积的查询。
10. 合理的设置map和reduce数量。
11. jvm重用。可在hadoop的mapred-site.xml中设置jvm被重用的次数。
