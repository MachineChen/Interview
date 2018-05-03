# 基础

模式定义了数据如何存储、存储什么样的数据以及数据如何分解等信息，数据库和表都有模式。

主键的值不允许修改，也不允许复用（不能使用已经删除的主键值赋给新数据行的主键）。

SQL（Structured Query Language)，标准 SQL 由 ANSI 标准委员会管理，从而称为 ANSI SQL。各个 DBMS 都有自己的实现，如 PL/SQL、Transact-SQL 等。

SQL 语句不区分大小写，但是数据库表名、列名和值是否区分依赖于具体的 DBMS 以及配置。

SQL 支持以下三种注释：

```sql
# 注释
SELECT *
FROM mytable; -- 注释
/* 注释1
   注释2 */
```

# 创建表

```sql
CREATE TABLE mytable (
  id INT NOT NULL AUTO_INCREMENT,
  col1 INT NOT NULL DEFAULT 1,
  col2 VARCHAR(45) NULL,
  col3 DATE NULL,
  PRIMARY KEY (`id`));
```

# 插入

**普通插入** 

```sql
INSERT INTO mytable(col1, col2)
VALUES(val1, val2);
```

**插入检索出来的数据** 

```sql
INSERT INTO mytable1(col1, col2)
SELECT col1, col2
FROM mytable2;
```

**将一个表的内容复制到一个新表** 

```sql
CREATE TABLE newtable AS
SELECT * FROM mytable;
```

# 更新

```sql
UPDATE mytable
SET col = val
WHERE id = 1;
```

# 删除

```sql
DELETE FROM mytable
WHERE id = 1;
```

**TRUNCATE TABLE**  可以清空表，也就是删除所有行。

使用更新和删除操作时一定要用 WHERE 子句，不然会把整张表的数据都破坏。可以先用 SELECT 语句进行测试，防止错误删除。

# 修改表

**添加列** 

```sql
ALTER TABLE mytable
ADD col CHAR(20);
```

**删除列** 

```sql
ALTER TABLE mytable
DROP COLUMN col;
```

**删除表** 

```sql
DROP TABLE mytable;
```

# 查询

**DISTINCT** 

相同值只会出现一次。它作用于所有列，也就是说所有列的值都相同才算相同。

```sql
SELECT DISTINCT col1, col2
FROM mytable;
```

**LIMIT** 

限制返回的行数。可以有两个参数，第一个参数为起始行，从 0 开始；第二个参数为返回的总行数。

返回前 5 行：

```sql
SELECT *
FROM mytable
LIMIT 5;
```

```sql
SELECT *
FROM mytable
LIMIT 0, 5;
```

返回第 3 \~ 5 行：

```sql
SELECT *
FROM mytable
LIMIT 2, 3;
```


# 排序

-  **ASC** ：升序（默认）
-  **DESC** ：降序

可以按多个列进行排序，并且为每个列指定不同的排序方式：

```sql
SELECT *
FROM mytable
ORDER BY col1 DESC, col2 ASC;
```

# 过滤

不进行过滤的数据非常大，导致通过网络传输了很多多余的数据，从而浪费了网络带宽。因此尽量使用 SQL 语句来过滤不必要的数据，而不是传输所有的数据到客户端中然后由客户端进行过滤。

```sql
SELECT *
FROM mytable
WHERE col IS NULL;
```

下表显示了 WHERE 子句可用的操作符

|  操作符 | 说明  |
| ------------ | ------------ |
| = <  >  | 等于 小于 大于 |
| <> !=  | 不等于  |
| <= !> | 小于等于 |
| >= !< | 大于等于 |
| BETWEEN | 在两个值之间 |
| IS NULL | 为NULL值 |

应该注意到，NULL 与 0 、空字符串都不同。

**AND OR**  用于连接多个过滤条件。优先处理 AND，因此当一个过滤表达式涉及到多个 AND 和 OR 时，应当使用 () 来决定优先级。

**IN**  操作符用于匹配一组值，其后也可以接一个 SELECT 子句，从而匹配子查询得到的一组值。

**NOT**  操作符用于否定一个条件。

# 通配符

通配符也是用在过滤语句中，但它只能用于文本字段。

-  **%**  匹配 >=0 个任意字符，类似于 \*；

-  **\_**  匹配 ==1 个任意字符，类似于 \.；

-  **[ ]**  可以匹配集合内的字符，例如 [ab] 将匹配字符 a 或者 b。用脱字符 ^ 可以对其进行否定，也就是不匹配集合内的字符。

使用 Like 来进行通配符匹配。

```sql
SELECT *
FROM mytable
WHERE col LIKE '[^AB]%' -- 不以 A 和 B 开头的任意文本
```
不要滥用通配符，通配符位于开头处匹配会非常慢。

# 计算字段

在数据库服务器上完成数据的转换和格式化的工作往往比客户端上快得多，并且转换和格式化后的数据量更少的话可以减少网络通信量。

计算字段通常需要使用  **AS**  来取别名，否则输出的时候字段名为计算表达式。

```sql
SELECT col1*col2 AS alias
FROM mytable
```

**Concat()**  用于连接两个字段。许多数据库会使用空格把一个值填充为列宽，因此连接的结果会出现一些不必要的空格，使用 **TRIM()** 可以去除首尾空格。

```sql
SELECT Concat(TRIM(col1), ' (', TRIM(col2), ')')
FROM mytable
```

# 函数

各个 DBMS 的函数都是不相同的，因此不可移植。

## 文本处理

| 函数  | 说明  |
| ------------ | ------------ |
|  LEFT() RIGHT() |  左边或者右边的字符 |
|  LOWER() UPPER() |  转换为小写或者大写 |
| LTRIM() RTIM() | 去除左边或者右边的空格 |
| LENGTH() | 长度 |
| SUNDEX() | 转换为语音值 |

其中， **SOUNDEX()**  是将一个字符串转换为描述其语音表示的字母数字模式的算法，它是根据发音而不是字母比较。

```sql
SELECT *
FROM mytable
WHERE SOUNDEX(col1) = SOUNDEX('apple')
```

## 日期和时间处理

- 日期格式：YYYY-MM-DD
- 时间格式：HH:MM:SS

|函 数 | 说 明|
| --- | --- |
| AddDate() | 增加一个日期（天、周等）|
| AddTime() | 增加一个时间（时、分等）|
| CurDate() | 返回当前日期 |
| CurTime() | 返回当前时间 |
| Date() |返回日期时间的日期部分|
| DateDiff() |计算两个日期之差|
| Date_Add() |高度灵活的日期运算函数|
| Date_Format() |返回一个格式化的日期或时间串|
| Day()| 返回一个日期的天数部分|
| DayOfWeek() |对于一个日期，返回对应的星期几|
| Hour() |返回一个时间的小时部分|
| Minute() |返回一个时间的分钟部分|
| Month() |返回一个日期的月份部分|
| Now() |返回当前日期和时间|
| Second() |返回一个时间的秒部分|
| Time() |返回一个日期时间的时间部分|
| Year() |返回一个日期的年份部分|

```sql
mysql> SELECT NOW();
        -> '2017-06-28 14:01:52'
```

## 数值处理

| 函数 | 说明 |
| --- | --- |
| SIN() | 正弦 |
| COS() | 余弦 |
| TAN() | 正切 |
| ABS() | 绝对值 |
| SQRT() | 平方根 |
| MOD() | 余数 |
| EXP() | 指数 |
| PI() | 圆周率 |
| RAND() | 随机数 |

## 汇总

|函 数 |说 明|
| --- | --- |
| AVG() | 返回某列的平均值 |
| COUNT() | 返回某列的行数 |
| MAX() | 返回某列的最大值 |
| MIN() | 返回某列的最小值 |
| SUM() |返回某列值之和 |

AVG() 会忽略 NULL 行。

使用 DISTINCT 可以汇总函数值汇总不同的值。

```sql
SELECT AVG(DISTINCT col1) AS avg_col
FROM mytable
```

# 分组

分组就是把具有相同的数据值的行放在同一组中。

可以对同一分组数据使用汇总函数进行处理，例如求分组数据的平均值等。

指定的分组字段除了能让数组按该字段进行分组，也可以按该字段进行排序，例如按 col 字段排序并分组数据：

```sql
SELECT col, COUNT(*) AS num
FROM mytable
GROUP BY col;
```

WHERE 过滤行，HAVING 过滤分组。行过滤应当先与分组过滤；

```sql
SELECT col, COUNT(*) AS num
FROM mytable
WHERE col > 2
GROUP BY col
HAVING COUNT(*) >= 2;
```

GROUP BY 的排序结果为分组字段，而 ORDER BY 也可以以聚集字段来进行排序。

```sql
SELECT col, COUNT(*) AS num
FROM mytable
GROUP BY col
ORDER BY num;
```

分组规定：

1. GROUP BY 子句出现在 WHERE 子句之后，ORDER BY 子句之前；
2. 除了汇总计算语句的字段外，SELECT 语句中的每一字段都必须在 GROUP BY 子句中给出；
3. NULL 的行会单独分为一组；
4. 大多数 SQL 实现不支持 GROUP BY 列具有可变长度的数据类型。

# 子查询

子查询中只能返回一个字段的数据。

可以将子查询的结果作为 WHRER 语句的过滤条件：

```
SELECT *
FROM mytable1
WHERE col1 IN (SELECT col2
                 FROM mytable2);
```

下面的语句可以检索出客户的订单数量，子查询语句会对第一个查询检索出的每个客户执行一次：

```sql
SELECT cust_name, (SELECT COUNT(*)
                   FROM Orders
                   WHERE Orders.cust_id = Customers.cust_id)
                   AS orders_num
FROM Customers
ORDER BY cust_name;
```

# 连接

连接用于连接多个表，使用 JOIN 关键字，并且条件语句使用 ON 而不是 Where。

连接可以替换子查询，并且比子查询的效率一般会更快。

可以用 AS 给列名、计算字段和表名取别名，给表名取别名是为了简化 SQL 语句以及连接相同表。

## 内连接

内连接又称等值连接，使用 INNER JOIN 关键字。

```sql
select a, b, c
from A inner join B
on A.key = B.key
```

可以不明确使用 INNER JOIN，而使用普通查询并在 WHERE 中将两个表中要连接的列用等值方法连接起来。

```sql
select a, b, c
from A, B
where A.key = B.key
```

在没有条件语句的情况下返回笛卡尔积。

## 自连接

自连接可以看成内连接的一种，只是连接的表是自身而已。

一张员工表，包含员工姓名和员工所属部门，要找出与 Jim 处在同一部门的所有员工姓名。

**子查询版本** 

```sql
select name
from employee
where department = (
      select department
      from employee
      where name = "Jim");
```

**自连接版本** 

```sql
select name
from employee as e1, employee as e2
where e1.department = e2.department
      and e1.name = "Jim";
```

连接一般比子查询的效率高。

## 自然连接

自然连接是把同名列通过等值测试连接起来的，同名列可以有多个。

内连接和自然连接的区别：内连接提供连接的列，而自然连接自动连接所有同名列。

```sql
select *
from employee natural join department;
```

## 外连接

外连接保留了没有关联的那些行。分为左外连接，右外连接以及全外连接，左外连接就是保留左表没有关联的行。

检索所有顾客的订单信息，包括还没有订单信息的顾客。

```sql
select Customers.cust_id, Orders.order_num
   from Customers left outer join Orders
   on Customers.cust_id = Orders.curt_id;
```

如果需要统计顾客的订单数，使用聚集函数。

```sql
select Customers.cust_id,
       COUNT(Orders.order_num) as num_ord
from Customers left outer join Orders
on Customers.cust_id = Orders.curt_id
group by Customers.cust_id;
```

# 组合查询

使用  **UNION**  来组合两个查询，如果第一个查询返回 M 行，第二个查询返回 N 行，那么组合查询的结果为 M+N 行。

每个查询必须包含相同的列、表达式或者聚集函数。

默认会去除相同行，如果需要保留相同行，使用 UNION ALL。

只能包含一个 ORDER BY 子句，并且必须位于语句的最后。

```sql
SELECT col
FROM mytable
WHERE col = 1
UNION
SELECT col
FROM mytable
WHERE col =2;
```

# 视图

视图是虚拟的表，本身不包含数据，也就不能对其进行索引操作。对视图的操作和对普通表的操作一样。

视图具有如下好处：

1. 简化复杂的 SQL 操作，比如复杂的联结；
2. 只使用实际表的一部分数据；
3. 通过只给用户访问视图的权限，保证数据的安全性；
4. 更改数据格式和表示。

```sql
CREATE VIEW myview AS
SELECT Concat(col1, col2) AS concat_col, col3*col4 AS count_col
FROM mytable
WHERE col5 = val;
```

# 存储过程

存储过程可以看成是对一系列 SQL 操作的批处理；

**使用存储过程的好处** 

1. 代码封装，保证了一定的安全性；
2. 代码复用；
3. 由于是预先编译，因此具有很高的性能。

**创建存储过程** 

命令行中创建存储过程需要自定义分隔符，因为命令行是以 ; 为结束符，而存储过程中也包含了分号，因此会错误把这部分分号当成是结束符，造成语法错误。

包含 in、out 和 inout 三种参数。

给变量赋值都需要用 select into 语句。

每次只能给一个变量赋值，不支持集合的操作。

```sql
delimiter //

create procedure myprocedure( out ret int )
    begin
        declare y int;
        select sum(col1)
        from mytable
        into y;
        select y*y into ret;
    end //
delimiter ;
```

```sql
call myprocedure(@ret);
select @ret;
```

# 游标

在存储过程中使用游标可以对一个结果集进行移动遍历。

游标主要用于交互式应用，其中用户需要对数据集中的任意行进行浏览和修改。

**使用游标的四个步骤：** 

1. 声明游标，这个过程没有实际检索出数据；
2. 打开游标；
3. 取出数据；
4. 关闭游标；

```sql
delimiter //
create procedure myprocedure(out ret int)
    begin
        declare done boolean default 0;

        declare mycursor cursor for
        select col1 from mytable;
        # 定义了一个continue handler，当 sqlstate '02000' 这个条件出现时，会执行 set done = 1
        declare continue handler for sqlstate '02000' set done = 1;

        open mycursor;

        repeat
            fetch mycursor into ret;
            select ret;
        until done end repeat;

        close mycursor;
    end //
 delimiter ;
```

# 触发器

触发器会在某个表执行以下语句时而自动执行：DELETE、INSERT、UPDATE

触发器必须指定在语句执行之前还是之后自动执行，之前执行使用 BEFORE 关键字，之后执行使用 AFTER 关键字。BEFORE 用于数据验证和净化。

INSERT 触发器包含一个名为 NEW 的虚拟表。

```sql
CREATE TRIGGER mytrigger AFTER INSERT ON mytable
FOR EACH ROW SELECT NEW.col;
```

DELETE 触发器包含一个名为 OLD 的虚拟表，并且是只读的。

UPDATE 触发器包含一个名为 NEW 和一个名为 OLD 的虚拟表，其中 NEW 是可以被修改地，而 OLD 是只读的。

可以使用触发器来进行审计跟踪，把修改记录到另外一张表中。

MySQL 不允许在触发器中使用 CALL 语句 ，也就是不能调用存储过程。

# 事务处理

**基本术语** 

1. 事务（transaction）指一组 SQL 语句；
2. 回退（rollback）指撤销指定 SQL 语句的过程；
3. 提交（commit）指将未存储的 SQL 语句结果写入数据库表；
4. 保留点（savepoint）指事务处理中设置的临时占位符（placeholder），你可以对它发布回退（与回退整个事务处理不同）。

不能回退 SELECT 语句，回退 SELECT 语句也没意义；也不能回退 CRETE 和 DROP 语句。

MySQL 的事务提交默认是隐式提交，也就是每执行一条语句就把这条语句当成一个事务然后进行提交。当出现 START TRANSACTION 语句时，会关闭隐式提交；当 COMMIT 或 ROLLBACK 语句执行后，事务会自动关闭，重新恢复隐式提交。

通过设置 autocommit 为 0 可以取消自动提交，直到 autocommit 被设置为 1 才会提交；autocommit 标记是针对每个连接而不是针对服务器的。

如果没有设置保留点，ROLLBACK 会回退到 START TRANSACTION 语句处；如果设置了保留点，并且在 ROLLBACK 中指定该保留点，则会回退到该保留点。

```sql
START TRANSACTION
// ...
SAVEPOINT delete1
// ...
ROLLBACK TO delete1
// ...
COMMIT
```

# 字符集

**基本术语** 

1. 字符集为字母和符号的集合；
2. 编码为某个字符集成员的内部表示；
3. 校对字符指定如何比较，主要用于排序和分组。

除了给表指定字符集和校对外，也可以给列指定：

```sql
CREATE TABLE mytable
(col VARCHAR(10) CHARACTER SET latin COLLATE latin1_general_ci )
DEFAULT CHARACTER SET hebrew COLLATE hebrew_general_ci;
```

可以在排序、分组时指定校对：

```sql
SELECT *
FROM mytable
ORDER BY col COLLATE latin1_general_ci;
```

# 权限管理

MySQL 的账户信息保存在 mysql 这个数据库中。

```sql
USE mysql;
SELECT user FROM user;
```

**创建账户** 

```sql
CREATE USER myuser IDENTIFIED BY 'mypassword';
```

新创建的账户没有任何权限。

**修改账户名** 

```sql
RENAME myuser TO newuser;
```

**删除账户** 

```sql
DROP USER myuser;
```

**查看权限** 

```sql
SHOW GRANTS FOR myuser;
```

**授予权限** 

```sql
GRANT SELECT, INSERT ON mydatabase.* TO myuser;
```

账户用 username@host 的形式定义，username@% 使用的是默认主机名。

**删除权限** 

```sql
REVOKE SELECT, INSERT ON mydatabase.* FROM myuser;
```

GRANT 和 REVOKE 可在几个层次上控制访问权限：

- 整个服务器，使用 GRANT ALL 和 REVOKE ALL；
- 整个数据库，使用 ON database.\*；
- 特定的表，使用 ON database.table；
- 特定的列；
- 特定的存储过程。

**更改密码** 

必须使用 Password() 函数

```sql
SET PASSWROD FOR myuser = Password('newpassword');
```

# 数据库状态

## show status命令含义：

aborted_clients 客户端非法中断连接次数
aborted_connects 连接mysql失败次数
com_xxx xxx命令执行次数,有很多条
connections 连接mysql的数量
Created_tmp_disk_tables 在磁盘上创建的临时表
Created_tmp_tables 在内存里创建的临时表
Created_tmp_files 临时文件数
Key_read_requests The number of requests to read a key block from the cache
Key_reads The number of physical reads of a key block from disk
Max_used_connections 同时使用的连接数
Open_tables 开放的表
Open_files 开放的文件
Opened_tables 打开的表
Questions 提交到server的查询数
Sort_merge_passes 如果这个值很大,应该增加my.cnf中的sort_buffer值
Uptime 服务器已经工作的秒数

提升性能的建议：
1.如果opened_tables太大,应该把my.cnf中的table_cache变大
2.如果Key_reads太大,则应该把my.cnf中key_buffer_size变大.可以用Key_reads/Key_read_requests计算出cache失败率
3.如果Handler_read_rnd太大,则你写的SQL语句里很多查询都是要扫描整个表,而没有发挥索引的键的作用
4.如果Threads_created太大,就要增加my.cnf中thread_cache_size的值.可以用Threads_created/Connections计算cache命中率
5.如果Created_tmp_disk_tables太大,就要增加my.cnf中tmp_table_size的值,用基于内存的临时表代替基于磁盘的
注：所以配置参数可以修改/etc/my.cnf 此文件.

## show variables命令含义：

1. back_log

指定MySQL可能的连接数量。当MySQL主线程在很短的时间内得到非常多的连接请求，该参数就起作用，之后主线程花些时间(尽管很短)检查连接并且启动一个新线程。

back_log参数的值指出在MySQL暂时停止响应新请求之前的短时间内多少个请求可以被存在堆栈中。如果系统在一个短时间内有很多连接，则需要增大 该参数的值，该参数值指定到来的TCP/IP连接的侦听队列的大小。不同的操作系统在这个队列大小上有它自己的限制。 试图设定back_log高于你的操作系统的限制将是无效的。

当观察MySQL进程列表，发现大量 264084 | unauthenticated user | xxx.xxx.xxx.xxx | NULL | Connect | NULL | login | NULL 的待连接进程时，就要加大 back_log 的值。back_log默认值为50。

2. basedir

MySQL主程序所在路径，即：–basedir参数的值。

3. bdb_cache_size

分配给BDB类型数据表的缓存索引和行排列的缓冲区大小，如果不使用DBD类型数据表，则应该在启动MySQL时加载 –skip-bdb 参数以避免内存浪费。

4.bdb_log_buffer_size

分配给BDB类型数据表的缓存索引和行排列的缓冲区大小，如果不使用DBD类型数据表，则应该将该参数值设置为0，或者在启动MySQL时加载 –skip-bdb 参数以避免内存浪费。

5.bdb_home

参见 –bdb-home 选项。

6. bdb_max_lock

指定最大的锁表进程数量(默认为10000)，如果使用BDB类型数据表，则可以使用该参数。如果在执行大型事物处理或者查询时发现 bdb: Lock table is out of available locks or Got error 12 from … 错误，则应该加大该参数值。

7. bdb_logdir

指定使用BDB类型数据表提供服务时的日志存放位置。即为 –bdb-logdir 的值。

8. bdb_shared_data

如果使用 –bdb-shared-data 选项则该参数值为On。

9. bdb_tmpdir

BDB类型数据表的临时文件目录。即为 –bdb-tmpdir 的值。

10. binlog_cache_size

为binary log指定在查询请求处理过程中SQL 查询语句使用的缓存大小。如果频繁应用于大量、复杂的SQL表达式处理，则应该加大该参数值以获得性能提升。

11. bulk_insert_buffer_size

指定 MyISAM 类型数据表表使用特殊的树形结构的缓存。使用整块方式(bulk)能够加快插入操作( INSERT … SELECT, INSERT … VALUES (…), (…), …, 和 LOAD DATA INFILE) 的速度和效率。该参数限制每个线程使用的树形结构缓存大小，如果设置为0则禁用该加速缓存功能。注意：该参数对应的缓存操作只能用户向非空数据表中执行插 入操作!默认值为 8MB。

12. character_set

MySQL的默认字符集。

13. character_sets

MySQL所能提供支持的字符集。

14. concurrent_inserts

如果开启该参数，MySQL则允许在执行 SELECT 操作的同时进行 INSERT 操作。如果要关闭该参数，可以在启动 mysqld 时加载 –safe 选项，或者使用 –skip-new 选项。默认为On。

15. connect_timeout

指定MySQL服务等待应答一个连接报文的最大秒数，超出该时间，MySQL向客户端返回 bad handshake。

16. datadir

指定数据库路径。即为 –datadir 选项的值。

17. delay_key_write

该参数只对 MyISAM 类型数据表有效。有如下的取值种类：

off: 如果在建表语句中使用 CREATE TABLE … DELAYED_KEY_WRITES，则全部忽略

DELAYED_KEY_WRITES;

on: 如果在建表语句中使用 CREATE TABLE … DELAYED_KEY_WRITES，则使用该选项(默认);

all: 所有打开的数据表都将按照 DELAYED_KEY_WRITES 处理。

如果 DELAYED_KEY_WRITES 开启，对于已经打开的数据表而言，在每次索引更新时都不刷新带有

DELAYED_KEY_WRITES 选项的数据表的key buffer，除非该数据表关闭。该参数会大幅提升写入键值的速

度。如果使用该参数，则应该检查所有数据表：myisamchk –fast –force。

18.delayed_insert_limit

在插入delayed_insert_limit行后，INSERT DELAYED处理模块将检查是否有未执行的SELECT语句。如果有，在继续处理前执行允许这些语句。

19. delayed_insert_timeout

一个INSERT DELAYED线程应该在终止之前等待INSERT语句的时间。

20. delayed_queue_size

为处理INSERT DELAYED分配的队列大小(以行为单位)。如果排队满了，任何进行INSERT DELAYED的客户必须等待队列空间释放后才能继续。

21. flush

在启动MySQL时加载 –flush 参数打开该功能。

22. flush_time

如果该设置为非0值，那么每flush_time秒，所有打开的表将被关，以释放资源和sync到磁盘。注意：只建议在使用 Windows9x/Me 或者当前操作系统资源严重不足时才使用该参数!

23. ft_boolean_syntax

搜索引擎维护员希望更改允许用于逻辑全文搜索的操作符。这些则由变量 ft_boolean_syntax 控制。

24. ft_min_word_len

指定被索引的关键词的最小长度。注意：在更改该参数值后，索引必须重建!

25. ft_max_word_len

指定被索引的关键词的最大长度。注意：在更改该参数值后，索引必须重建!

26. ft_max_word_len_for_sort

指定在使用REPAIR, CREATE INDEX, or ALTER TABLE等方法进行快速全文索引重建过程中所能使用的关键词的最大长度。超出该长度限制的关键词将使用低速方式进行插入。加大该参数的值，MySQL将 会建立更大的临时文件(这会减轻CPU负载，但效率将取决于磁盘I/O效率)，并且在一个排序取内存放更少的键值。

27. ft_stopword_file

从 ft_stopword_file 变量指定的文件中读取列表。在修改了 stopword 列表后，必须重建 FULLTEXT 索引。

28. have_innodb

YES: MySQL支持InnoDB类型数据表; DISABLE: 使用 –skip-innodb 关闭对InnoDB类型数据表的支持。

29. have_bdb

YES: MySQL支持伯克利类型数据表; DISABLE: 使用 –skip-bdb 关闭对伯克利类型数据表的支持。

30. have_raid

YES: 使MySQL支持RAID功能。

31. have_openssl

YES: 使MySQL支持SSL加密协议。

32. init_file

指定一个包含SQL查询语句的文件，该文件在MySQL启动时将被加载，文件中的SQL语句也会被执行。

33. interactive_timeout

服务器在关上它前在一个交互连接上等待行动的秒数。一个交互的客户被定义为对mysql_real_connect()使用CLIENT_INTERACTIVE选项的客户。也可见wait_timeout。

34. join_buffer_size

用于全部联合(join)的缓冲区大小(不是用索引的联结)。缓冲区对2个表间的每个全部联结分配一次缓冲区，当增加索引不可能时，增加该值可得到一个更快的全部联结。(通常得到快速联结的最佳方法是增加索引。)

35. key_buffer_size

用于索引块的缓冲区大小，增加它可得到更好处理的索引(对所有读和多重写)，到你能负担得起那样多。如果你使它太大，系统将开始变慢慢。必须为OS文件系统缓存留下一些空间。为了在写入多个行时得到更多的速度。

36. language

用户输出报错信息的语言。

37. large_file_support

开启大文件支持。

38. locked_in_memory

使用 –memlock 将mysqld锁定在内存中。

39. log

记录所有查询操作。

40. log_update

开启update log。

41. log_bin

开启 binary log。

42. log_slave_updates

如果使用链状同步或者多台Slave之间进行同步则需要开启此参数。

43. long_query_time

如果一个查询所用时间超过该参数值，则该查询操作将被记录在Slow_queries中。

44. lower_case_table_names

1: MySQL总使用小写字母进行SQL操作;

0: 关闭该功能。

注意：如果使用该参数，则应该在启用前将所有数据表转换为小写字母。

45. max_allowed_packet

一个查询语句包的最大尺寸。消息缓冲区被初始化为net_buffer_length字节，但是可在需要时增加到max_allowed_packet个字节。该值太小则会在处理大包时产生错误。如果使用大的BLOB列，必须增加该值。

46. net_buffer_length

通信缓冲区在查询期间被重置到该大小。通常不要改变该参数值，但是如果内存不足，可以将它设置为查询期望的大小。(即，客户发出的SQL语句期望的长度。如果语句超过这个长度，缓冲区自动地被扩大，直到max_allowed_packet个字节。)

47. max_binlog_cache_size

指定binary log缓存的最大容量，如果设置的过小，则在执行复杂查询语句时MySQL会出错。

48. max_binlog_size

指定binary log文件的最大容量，默认为1GB。

49. max_connections

允许同时连接MySQL服务器的客户数量。如果超出该值，MySQL会返回Too many connections错误，但通常情况下，MySQL能够自行解决。

50. max_connect_errors

对于同一主机，如果有超出该参数值个数的中断错误连接，则该主机将被禁止连接。如需对该主机进行解禁，执行：FLUSH HOST;。

51. max_delayed_threads

不要启动多于的这个数字的线程来处理INSERT DELAYED语句。如果你试图在所有INSERT DELAYED线程在用后向一张新表插入数据，行将被插入，就像DELAYED属性没被指定那样。

52. max_heap_table_size

内存表所能使用的最大容量。

53. max_join_size

如果要查询多于max_join_size个记录的联合将返回一个错误。如果要执行没有一个WHERE的语句并且耗费大量时间，且返回上百万行的联结，则需要加大该参数值。

54. max_sort_length

在排序BLOB或TEXT值时使用的字节数(每个值仅头max_sort_length个字节被使用;其余的被忽略)。

55. max_user_connections

指定来自同一用户的最多连接数。设置为0则代表不限制。

56. max_tmp_tables

(该参数目前还没有作用)。一个客户能同时保持打开的临时表的最大数量。

57. max_write_lock_count

当出现max_write_lock_count个写入锁定数量后，开始允许一些被锁定的读操作开始执行。避免写入锁定过多，读取操作处于长时间等待状态。

58. myisam_recover_options

注意：上述两个命令可以搭配like查看指定的参数名：比如 show status like "%connect%"