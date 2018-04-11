# 1、传统的JDBC编程

Java程序是通过JDBC连接数据库的，因此通过SQL对数据库编程。JDBC由SUN公司提出一系列规范，只定义了规范，具体的需要各个数据库厂商去实现，每个数据库是有自己的特殊性，所以JDBC是典型的桥接模式

    使用JDBC编程需要以下步骤

    1.1使用JDBC编程需要连接数据库，注册驱动和数据库信息
    1.2操作Connection，打开Statement对象
    1.3通过Statement执行SQL，返回结果到ResultSet对象
    1.4使用ResultSet读取数据，通过代码转换为POJO对象
    1.5关闭数据库相关资源

    使用JDBC的可以解决问题，但是相对来说很复杂，操作底层大量对象，并且需要准确关闭。如果其中错误，需要进行异常捕捉处理并正确关闭资源。

# 2、 ORM

介于上面的问题，采用ORM来替代JDBC，本质上ORM是对JDBC的封装。ORM关系映射对象，把数据表和POJO对象结合映射，从而使得对数据库的操作更加面向对象。

## 2.1hibernate

建立若干个POJO通过xml或者注解提供的规则映射到数据库表上，而且hibernate是全表映射模型。

    2.1.1、配置xml文件hibernate.cfg.xml用于数据库连接信息配置
    2.1.2、创建全局对象hibernateFactory，生产session接口
    2.1.3、直接在java文件使用session对象直接操作即可

优点：

    消除代码的映射规则，分离到了xml或注解中；无需配置数据库连接；只需要操作一个session对象，并且只需关闭一个session对象。

缺点：

    全表映射不灵活，无法根据不同条件组装sql，对多表联查执行性较差，不能有有效的支持存储过程，而且HQL的性能较差，无法对SQL优化

## 2.2Mybatis

    面对hibernate的不足之处，半自动映射的框架Mybatis出现，提供手工匹配POJO，SQL和映射关系

    在使用Mybatis的过程需要自己编写SQL，配置比hibernate多，但是可以动态配置SQL，解决hibernate中数据库中随时间变化，不同条件的列名可以不一样的问题，同时可以优化SQL，而且配置可以决定映射规则，存储过程等。对于辅助的复杂和需要优化性能SQL查询使用Mybatis更方便。

    Mybatis整体上配置较多，但是使用起来灵活性比较高，尤其是针对业务服务复杂，性能要求较高的系统，Mybatis确实不错的选择！

# 总结

三种数据库连接操作的操作方式

1、传统的jdbc
2、自动映射框架hibernate
3、半自动映射框架Mybatis

传统的jdbc在连接操作上相对来说很麻烦

hibernate相对于复杂的数据库操作，很不灵活，但是整体开发工作量最少。hibernate适用于场景不复杂，要求性能不苛刻的时候使用。

mybatis半自动化，操作上灵活可变，但是配置相对复杂。相对hibernate开发工作量稍多，但是mybatis能是的sql优化发挥一定的作用，所以mybatis框架的技术也是很火爆的。