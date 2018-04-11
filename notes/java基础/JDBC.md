#什么是JDBC

jdbc（javadatabaseconnection）就是java数据库链接的api，是java标准类库的扩展，用它可以应用sql访问数据库，完成对数据库的查找，更新。
与其它数据库编程环境相比，jdbc有java语言的特性，使用jdbc开发的程序可以跨平台运行，而且不受数据库供应商的限制。

它不受数据库供应商的限制的原因就在于jdbc的设计。

一、sun公司为sql访问数据库提供一套“纯”javaapi；

二、同时提供一个驱动管理器，以允许第三方驱动程序可以链接到特定的数据库，这样数据库供应商就可以提供自己的驱动程序，并插入到驱动管理器中，关键是所有的驱动程序都必须满足驱动管理器api提出的要求。

三、需要一套简单的机制，以使得第三方驱动程序可以想驱动管理器注册。


#JDBC连接数据库

•创建一个以JDBC连接数据库的程序，包含7个步骤：

1、加载JDBC驱动程序：

在连接数据库之前，首先要加载想要连接的数据库的驱动到JVM（Java虚拟机），这通过java.lang.Class类的静态方法forName(StringclassName)实现。

例如：

```
try{
//加载MySql的驱动类
Class.forName("com.mysql.jdbc.Driver");
}catch(ClassNotFoundExceptione){
System.out.println("找不到驱动程序类，加载驱动失败！");
e.printStackTrace();
}
```

成功加载后，会将Driver类的实例注册到DriverManager类中。

2、提供JDBC连接的URL

•连接URL定义了连接数据库时的协议、子协议、数据源标识。

•书写形式：协议：子协议：数据源标识

协议：在JDBC中总是以jdbc开始

子协议：是桥连接的驱动程序或是数据库管理系统名称。

数据源标识：标记找到数据库来源的地址与连接端口。

例如：（MySql的连接URL）

```
jdbc:mysql:
//localhost:3306/test?useUnicode=true&characterEncoding=gbk;
useUnicode=true：表示使用Unicode字符集。如果characterEncoding设置为
gb2312或GBK，本参数必须设置为true。characterEncoding=gbk：字符编码方式。
```

3、创建数据库的连接

•要连接数据库，需要向java.sql.DriverManager请求并获得Connection对象，该对象就代表一个数据库的连接。

•使用DriverManager的getConnectin(Stringurl,Stringusername,Stringpassword)方法传入指定的欲连接的数据库的路径、数据库的用户名和密码来获得。

例如：

```
//连接MySql数据库，用户名和密码都是root
Stringurl="jdbc:mysql://localhost:3306/test";
Stringusername="root";
Stringpassword="root";
try{
Connectioncon=
DriverManager.getConnection(url,username,password);
}catch(SQLExceptionse){
System.out.println("数据库连接失败！");
se.printStackTrace();
}
```

4、创建一个Statement

•要执行SQL语句，必须获得java.sql.Statement实例，Statement实例分为以下3
种类型：

1、执行静态SQL语句。通常通过Statement实例实现。
2、执行动态SQL语句。通常通过PreparedStatement实例实现。
3、执行数据库存储过程。通常通过CallableStatement实例实现。

具体的实现方式：

```
Statementstmt=con.createStatement();
PreparedStatementpstmt=con.prepareStatement(sql);
CallableStatementcstmt=
con.prepareCall("{CALLdemoSp(?,?)}");
```

5、执行SQL语句

Statement接口提供了三种执行SQL语句的方法：executeQuery、executeUpdate和execute

1、ResultSetexecuteQuery(StringsqlString)：执行查询数据库的SQL语句，返回一个结果集（ResultSet）对象。

2、intexecuteUpdate(StringsqlString)：用于执行INSERT、UPDATE或DELETE语句以及SQLDDL语句，如：CREATETABLE和DROPTABLE等

3、execute(sqlString):用于执行返回多个结果集、多个更新计数或二者组合的语句。

具体实现的代码：

```
ResultSetrs=stmt.executeQuery("SELECT*FROM...");
introws=stmt.executeUpdate("INSERTINTO...");
booleanflag=stmt.execute(Stringsql);
```

6、处理结果

两种情况：

1、执行更新返回的是本次操作影响到的记录数。

2、执行查询返回的结果是一个ResultSet对象。

•ResultSet包含符合SQL语句中条件的所有行，并且它通过一套get方法提供了对这些行中数据的访问。

•使用结果集（ResultSet）对象的访问方法获取数据：

```
while(rs.next()){
Stringname=rs.getString("name");
Stringpass=rs.getString(1);//此方法比较高效
}
（列是从左到右编号的，并且从列1开始）
```

7、关闭JDBC对象

操作完成以后要把所有使用的JDBC对象全都关闭，以释放JDBC资源，关闭顺序和声明顺序相反：

1、关闭记录集
2、关闭声明
3、关闭连接对象

```
if(rs!=null){//关闭记录集
try{
rs.close();
}catch(SQLExceptione){
e.printStackTrace();
}
}
if(stmt!=null){//关闭声明
try{
stmt.close();
}catch(SQLExceptione){
e.printStackTrace();
}
}
if(conn!=null){//关闭连接对象
try{
conn.close();
}catch(SQLExceptione){
e.printStackTrace();
}
}

```