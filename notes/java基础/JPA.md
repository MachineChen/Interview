# 什么是JPA

Java Persistence API：用于对象持久化的 API
Java EE 5.0 平台标准的 ORM 规范，使得应用程序以统一的方式访问持久层

JPA(Java Persistence API)是Sun官方提出的Java持久化规范。它为Java开发人员提供了一种对象/关联映射工具来管理Java应用中的关系数据。他的出现主要是为了简化现有的持久化开发工作和整合ORM技术，结束现在Hibernate，TopLink，JDO等ORM框架各自为营的局面。值得注意的是，JPA是在充分吸收了现有Hibernate，TopLink，JDO等ORM框架的基础上发展而来的，具有易于使用，伸缩性强等优点。从目前的开发社区的反应上看，JPA受到了极大的支持和赞扬，其中就包括了Spring与EJB3.0的开发团队。着眼未来几年的技术走向，JPA作为ORM领域标准化整合者的目标应该不难实现。

<div align="center"> <img src="../../../pics/JPA/JAP.png" width="800"/> </div><br>

JPA的总体思想和现有Hibernate,TopLink,JDO等ORM框架大体一致。总的来说，JPA包括以下3方面的技术：

# • ORM映射元数据

JPA支持XML和JDK5.0注释(也可译作注解)两种元数据的形式，元数据描述对象和表之间的映射关系，框架据此将实体对象持久化到数据库表中。

# • Java持久化API

用来操作实体对象，执行CRUD操作，框架在后台替我们完成所有的事情，开发者可以从繁琐的JDBC和SQL代码中解脱出来。

# • 查询语言（JPQL）

这是持久化操作中很重要的一个方面，通过面向对象而非面向数据库的查询语言查询数据，避免程序的SQL语句紧密耦合。

# JPA与hibernate的关系

JPA是一个规范，不是框架
hibernate是JPA的实现

# JPA的供应商

hibernate (JPA的始作俑者就是hibernate的作者)
OpenJPA
TopLink

提示：JPA不是一种新的ORM框架，他的出现只是用于规范现有的ORM技术，他不能取代现有的Hibernate，TopLink等ORM框架。相反，在采用JPA开发时，我们仍将使用到这些ORM框架，只是此时开发出来的应用不再依赖于某个持久化提供商。应用可以在不修改代码的情况下在任何JPA环境下运行，真正做到低耦合，可扩展的程序设计。
