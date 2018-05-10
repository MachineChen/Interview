#AOP

## AOP是什么？

	AOP为Aspect Oriented Programming的缩写，面向切面编程，是一项在不修改源代码的情况下，通过预编译方式和运行期动态代理给程序动态统一的添加功能，实现程序功能的统一维护的技术。
	Spring中AOP允许通过分离应用的业务逻辑与系统级服务进行内聚性开发，应用对象只实现相关业务逻辑，不负责其他系统级关注点，如日志或者事务支持。系统级行为的修改不影响业务逻辑代码。
	主要功能包括：日志记录、性能统计、安全控制、事务处理、异常处理等等。

### 相关概念
	
	- 切面(Aspect):一个关注点的模块化，关注点可能会横切多个对象。Spring AOP中，切面可以给予模式或者@Aspect注解的方式来实现
	- 连接点(Joinpoint):在程序执行过程中某个特定的点，比如某方法调用的时候或者处理异常的时候。在Spring AOP中，一个连接点总是表示一个方法的执行。
	- 通知(Advice): 在切面的某个特定的连接点上执行的动作，包括“around”、“before”和“after”等不同类型的通知。许多AOP框架（包括Spring）都是以拦截器做通知模型，并维护一个以连接点为中心的拦截器链。
	- 切入点（Pointcut）：匹配连接点的断言。通知和一个切入点表达式关联，并在满足这个切入点的连接点上运行（例如，当执行某个特定名称的方法时）。切入点表达式如何和连接点匹配是AOP的核心：Spring缺省使用AspectJ切入点语法。
	- 引入（Introduction）：用来给一个类型声明额外的方法或属性（也被称为连接类型声明（inter-type declaration））。Spring允许引入新的接口（以及一个对应的实现）到任何被代理的对象。例如，你可以使用引入来使一个bean实现IsModified接口，以便简化缓存机制。
	- 目标对象（Target Object）： 被一个或者多个切面所通知的对象。也被称做被通知（advised）对象。 既然Spring AOP是通过运行时代理实现的，这个对象永远是一个被代理（proxied）对象。
	- AOP代理（AOP Proxy）：AOP框架创建的对象，用来实现切面契约（例如通知方法执行等等）。在Spring中，AOP代理可以是JDK动态代理或者CGLIB代理。
	- 织入（Weaving）：把切面连接到其它的应用程序类型或者对象上，并创建一个被通知的对象。这些可以在编译时（例如使用AspectJ编译器），类加载时和运行时完成。Spring和其他纯Java AOP框架一样，在运行时完成织入。
	
## Spring AOP的实现原理--动态代理
	
	设计模式中代理模式是一种静态代理，在编译时已经确定代理类将要代理谁，而动态代理利用反射和动态编译将代理模式变成动态的，在运行时才能知道代理的目标对象是谁。
	Spring的动态代理有两种：
		1.JDK的动态代理（通过反射跟动态编译实现代理）
		2.CGLIB动态代理（通过修改字节码来实现代理）

	如下例子引用自http://www.importnew.com/21807.html，Greeting是需要被代理的目标接口，GreetingImpl是目标类。before()和after()则是业务逻辑代码执行前后的通用功能模块，比如打印日志、统计方法执行时间以便评估程序性能、开启及关闭JDBC连接等
	1. 没有引入AOP之前，代码如下：
	```
	public interface Greeting {
    	void sayHello(String name);
	}
	------------------------------------
	public class GreetingImpl implements Greeting {
 
	    @Override
	    public void sayHello(String name) {
	        before();
	        System.out.println("Hello! " + name);
	        after();
	    }
	 
	    private void before() {
	        System.out.println("Before");
	    }
	 
	    private void after() {
	        System.out.println("After");
	    }
	}
	```
	before()和after()方法被写死在sayHello()方法体中。如果有多个实现类，则每个实现类中都会重复一遍before()和after(),且这两个方法的修改很容易影响到sayHello()中的核心业务逻辑

	2. 静态代理
	把before()和after()的部分交给代理类，目标类只负责核心业务逻辑
	```
	public class GreetingProxy implements Greeting {
 
	    private GreetingImpl greetingImpl;
	 
	    public GreetingProxy(GreetingImpl greetingImpl) {
	        this.greetingImpl = greetingImpl;
	    }
	 
	    @Override
	    public void sayHello(String name) {
	        before();
	        greetingImpl.sayHello(name);
	        after();
	    }
	 
	    private void before() {
	        System.out.println("Before");
	    }
	 
	    private void after() {
	        System.out.println("After");
	    }
	}
	```
	则客户端通过代理类对象去实现完整逻辑
	```
	public class Client {
 
	    public static void main(String[] args) {
	        Greeting greetingProxy = new GreetingProxy(new GreetingImpl());
	        greetingProxy.sayHello("Jack");
	    }
	}
	```
	但是静态代理需要在编译器确定具体代理类，当XxxProxy的类越来越多时，代码依然存在大量重复

	3. JDK动态代理
	利用反射，JDK动态代理可以根据调用端传入的目标类信息在运行时动态的获取被代理类对象的引用，使得代理类只有一个。
	```
	public class JDKDynamicProxy implements InvocationHandler {
	 
	    private Object target;
	 
	    public JDKDynamicProxy(Object target) {
	        this.target = target;
	    }
	 
	    @SuppressWarnings("unchecked")
	    public <T> T getProxy() {
	        return (T) Proxy.newProxyInstance(
	            target.getClass().getClassLoader(),
	            target.getClass().getInterfaces(),
	            this
	        );
	    }
	 
	    @Override
	    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
	        before();
	        Object result = method.invoke(target, args);
	        after();
	        return result;
	    }
	 
	    private void before() {
	        System.out.println("Before");
	    }
	 
	    private void after() {
	        System.out.println("After");
	    }
	}
	```
	则客户端可以通过传入目标类的信息动态的获取代理：
	```
	public class Client {
 
	    public static void main(String[] args) {
	        Greeting greeting = new JDKDynamicProxy(new GreetingImpl()).getProxy();
	        greeting.sayHello("Jack");
	    }
	}
	```
	局限性：JDK动态代理只能代理接口，而不能代理没有接口的类。

	4. CGLIB动态代理

	开源的 CGLib 类库可以代理没有接口的类，这样就弥补了 JDK 的不足：
	```
	public class CGLibDynamicProxy implements MethodInterceptor {
 
	    private static CGLibDynamicProxy instance = new CGLibDynamicProxy();
	 
	    private CGLibDynamicProxy() {
	    }
	 
	    public static CGLibDynamicProxy getInstance() {
	        return instance;
	    }
	 
	    @SuppressWarnings("unchecked")
	    public <T> T getProxy(Class<T> cls) {
	        return (T) Enhancer.create(cls, this);
	    }
	 
	    @Override
	    public Object intercept(Object target, Method method, Object[] args, MethodProxy proxy) throws Throwable {
	        before();
	        Object result = proxy.invokeSuper(target, args);
	        after();
	        return result;
	    }
	 
	    private void before() {
	        System.out.println("Before");
	    }
	 
	    private void after() {
	        System.out.println("After");
	    }
	}
	```
	以上代码中了 Singleton 模式，那么客户端调用也更加轻松了：
	```
	public class Client {
	 
	    public static void main(String[] args) {
	        Greeting greeting = CGLibDynamicProxy.getInstance().getProxy(GreetingImpl.class);
	        greeting.sayHello("Jack");
	    }
	}
	```
	到此为止，我们能做的都做了，问题似乎全部都解决了。但事情总不会那么完美，而我们一定要追求完美！

	老罗搞出了一个 AOP 框架，能否做到完美而优雅呢？请大家继续往下看吧！

	5. Spring AOP：前置增强、后置增强、环绕增强（编程式）

	在 Spring AOP 的世界里，与 AOP 相关的术语实在太多，往往也是我们的“拦路虎”，不管是看那本书或是技术文档，在开头都要将这些术语逐个灌输给读者。我想这完全是在吓唬人了，其实没那么复杂的，大家放轻松一点。

	我们上面例子中提到的 before() 方法，在 Spring AOP 里就叫 Before Advice（前置增强）。有些人将 Advice 直译为“通知”，我想这是不太合适的，因为它根本就没有“通知”的含义，而是对原有代码功能的一种“增强”。再说，CGLib 中也有一个 Enhancer 类，它就是一个增强类。

	此外，像 after() 这样的方法就叫 After Advice（后置增强），因为它放在后面来增强代码的功能。

	如果能把 before() 与 after() 合并在一起，那就叫 Around Advice（环绕增强），就像汉堡一样，中间夹一根火腿。

	这三个概念是不是轻松地理解了呢？如果是，那就继续吧！

	我们下面要做的就是去实现这些所谓的“增强类”，让他们横切到代码中，而不是将这些写死在代码中。

	先来一个前置增强类吧：
	```
	public class GreetingBeforeAdvice implements MethodBeforeAdvice {
	 
	    @Override
	    public void before(Method method, Object[] args, Object target) throws Throwable {
	        System.out.println("Before");
	    }
	}
	```
	注意：这个类实现了 org.springframework.aop.MethodBeforeAdvice 接口，我们将需要增强的代码放入其中。

	再来一个后置增强类吧：
	```
	public class GreetingAfterAdvice implements AfterReturningAdvice {
	 
	    @Override
	    public void afterReturning(Object result, Method method, Object[] args, Object target) throws Throwable {
	        System.out.println("After");
	    }
	}
	```
	类似地，这个类实现了 org.springframework.aop.AfterReturningAdvice 接口。

	最后用一个客户端来把它们集成起来，看看如何调用吧：
	```
	public class Client {
	 
	    public static void main(String[] args) {
	        ProxyFactory proxyFactory = new ProxyFactory();     // 创建代理工厂
	        proxyFactory.setTarget(new GreetingImpl());         // 射入目标类对象
	        proxyFactory.addAdvice(new GreetingBeforeAdvice()); // 添加前置增强
	        proxyFactory.addAdvice(new GreetingAfterAdvice());  // 添加后置增强 
	 
	        Greeting greeting = (Greeting) proxyFactory.getProxy(); // 从代理工厂中获取代理
	        greeting.sayHello("Jack");                              // 调用代理的方法
	    }
	}
	```
	请仔细阅读以上代码及其注释，您会发现，其实 Spring AOP 还是挺简单的，对吗？

	当然，我们完全可以只定义一个增强类，让它同时实现 MethodBeforeAdvice 与 AfterReturningAdvice 这两个接口，如下：
	```
	public class GreetingBeforeAndAfterAdvice implements MethodBeforeAdvice, AfterReturningAdvice {
	 
	    @Override
	    public void before(Method method, Object[] args, Object target) throws Throwable {
	        System.out.println("Before");
	    }
	 
	    @Override
	    public void afterReturning(Object result, Method method, Object[] args, Object target) throws Throwable {
	        System.out.println("After");
	    }
	}
	```
	这样我们只需要使用一行代码，同时就可以添加前置与后置增强：
	```
	proxyFactory.addAdvice(new GreetingBeforeAndAfterAdvice());
	```
	刚才有提到“环绕增强”，其实这个东西可以把“前置增强”与“后置增强”的功能给合并起来，无需让我们同时实现以上两个接口。
	```
	public class GreetingAroundAdvice implements MethodInterceptor {
	 
	    @Override
	    public Object invoke(MethodInvocation invocation) throws Throwable {
	        before();
	        Object result = invocation.proceed();
	        after();
	        return result;
	    }
	 
	    private void before() {
	        System.out.println("Before");
	    }
	 
	    private void after() {
	        System.out.println("After");
	    }
	}
	```
	环绕增强类需要实现 org.aopalliance.intercept.MethodInterceptor 接口。注意，这个接口不是 Spring 提供的，它是 AOP 联盟（一个很牛逼的联盟）写的，Spring 只是借用了它。

	在客户端中同样也需要将该增强类的对象添加到代理工厂中：
	```
	proxyFactory.addAdvice(new GreetingAroundAdvice());
	```
	好了，这就是 Spring AOP 的基本用法，但这只是“编程式”而已。Spring AOP 如果只是这样，那就太傻逼了，它曾经也是一度宣传用 Spring 配置文件的方式来定义 Bean 对象，把代码中的 new 操作全部解脱出来。

	6. Spring AOP：前置增强、后置增强、环绕增强（声明式）

	先看 Spring 配置文件是如何写的吧：
	```
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	       xmlns:context="http://www.springframework.org/schema/context"
	       xsi:schemaLocation="http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans.xsd
	http://www.springframework.org/schema/context
	http://www.springframework.org/schema/context/spring-context.xsd">
	    <!-- 扫描指定包（将 @Component 注解的类自动定义为 Spring Bean） -->
	    <context:component-scan base-package="aop.demo"/>
	 
	    <!-- 配置一个代理 -->
	    <bean id="greetingProxy" class="org.springframework.aop.framework.ProxyFactoryBean">
	        <property name="interfaces" value="aop.Greeting"/> <!-- 需要代理的接口 -->
	        <property name="target" ref="greetingImpl"/>       <!-- 接口实现类 -->
	        <property name="interceptorNames">                 <!-- 拦截器名称（也就是增强类名称，Spring Bean 的 id） -->
	            <list>
	                <value>greetingAroundAdvice</value>
	            </list>
	        </property>
	    </bean>
	</beans>
	```
	一定要阅读以上代码的注释，其实使用 ProxyFactoryBean 就可以取代前面的 ProxyFactory，其实它们俩就一回事儿。我认为 interceptorNames 应该改名为 adviceNames 或许会更容易让人理解，不就是往这个属性里面添加增强类吗？

	此外，如果只有一个增强类，可以使用以下方法来简化：


	```
	    <bean id="greetingProxy" class="org.springframework.aop.framework.ProxyFactoryBean">
	        <property name="interfaces" value="aop.Greeting"/>
	        <property name="target" ref="greetingImpl"/>
	        <property name="interceptorNames" value="greetingAroundAdvice"/> <!-- 注意这行配置 -->
	    </bean>
	    ...
	```
	还需要注意的是，这里使用了 Spring 2.5+ 的特性“Bean 扫描”，这样我们就无需在 Spring 配置文件里不断地定义 <bean id=”xxx”/> 了，从而解脱了我们的双手。

	看看这是有多么的简单：
	```
	@Component
	public class GreetingImpl implements Greeting {
	 
	    ...
	}

	@Component
	public class GreetingAroundAdvice implements MethodInterceptor {
	 
	    ...
	}
	```
	最后看看客户端吧：
	```
	public class Client {
	 
	    public static void main(String[] args) {
	        ApplicationContext context = new ClassPathXmlApplicationContext("aop/demo/spring.xml"); // 获取 Spring Context
	        Greeting greeting = (Greeting) context.getBean("greetingProxy");                        // 从 Context 中根据 id 获取 Bean 对象（其实就是一个代理）
	        greeting.sayHello("Jack");                                                              // 调用代理的方法
	    }
	}
	```
	代码量确实少了，我们将配置性的代码放入配置文件，这样也有助于后期维护。更重要的是，代码只关注于业务逻辑，而将配置放入文件中。这是一条最佳实践！

	除了上面提到的那三类增强以外，其实还有两类增强也需要了解一下，关键的时候您要能想得到它们才行。

	7. Spring AOP：抛出增强

	程序报错，抛出异常了，一般的做法是打印到控制台或日志文件中，这样很多地方都得去处理，有没有一个一劳永逸的方法呢？那就是 Throws Advice（抛出增强），它确实很强，不信你就继续往下看：
	```
	@Component
	public class GreetingImpl implements Greeting {
	 
	    @Override
	    public void sayHello(String name) {
	        System.out.println("Hello! " + name);
	 
	        throw new RuntimeException("Error"); // 故意抛出一个异常，看看异常信息能否被拦截到
	    }
	}
	```
	下面是抛出增强类的代码：
	```
	@Component
	public class GreetingThrowAdvice implements ThrowsAdvice {
	 
	    public void afterThrowing(Method method, Object[] args, Object target, Exception e) {
	        System.out.println("---------- Throw Exception ----------");
	        System.out.println("Target Class: " + target.getClass().getName());
	        System.out.println("Method Name: " + method.getName());
	        System.out.println("Exception Message: " + e.getMessage());
	        System.out.println("-------------------------------------");
	    }
	}
	```
	抛出增强类需要实现 org.springframework.aop.ThrowsAdvice 接口，在接口方法中可获取方法、参数、目标对象、异常对象等信息。我们可以把这些信息统一写入到日志中，当然也可以持久化到数据库中。

	这个功能确实太棒了！但还有一个更厉害的增强。如果某个类实现了 A 接口，但没有实现 B 接口，那么该类可以调用 B 接口的方法吗？如果您没有看到下面的内容，一定不敢相信原来这是可行的！

	8. Spring AOP：引入增强

	以上提到的都是对方法的增强，那能否对类进行增强呢？用 AOP 的行话来讲，对方法的增强叫做 Weaving（织入），而对类的增强叫做 Introduction（引入）。而 Introduction Advice（引入增强）就是对类的功能增强，它也是 Spring AOP 提供的最后一种增强。建议您一开始千万不要去看《Spring Reference》，否则您一定会后悔的。因为当您看了以下的代码示例后，一定会彻底明白什么才是引入增强。

	定义了一个新接口 Apology（道歉）：
	```
	public interface Apology {
	 
	    void saySorry(String name);
	}
	```
	但我不想在代码中让 GreetingImpl 直接去实现这个接口，我想在程序运行的时候动态地实现它。因为假如我实现了这个接口，那么我就一定要改写 GreetingImpl 这个类，关键是我不想改它，或许在真实场景中，这个类有1万行代码，我实在是不敢动了。于是，我需要借助 Spring 的引入增强。这个有点意思了！
	```
	@Component
	public class GreetingIntroAdvice extends DelegatingIntroductionInterceptor implements Apology {
	 
	    @Override
	    public Object invoke(MethodInvocation invocation) throws Throwable {
	        return super.invoke(invocation);
	    }
	 
	    @Override
	    public void saySorry(String name) {
	        System.out.println("Sorry! " + name);
	    }
	}
	```
	以上定义了一个引入增强类，扩展了 org.springframework.aop.support.DelegatingIntroductionInterceptor 类，同时也实现了新定义的 Apology 接口。在类中首先覆盖了父类的 invoke() 方法，然后实现了 Apology 接口的方法。我就是想用这个增强类去丰富 GreetingImpl 类的功能，那么这个 GreetingImpl 类无需直接实现 Apology 接口，就可以在程序运行的时候调用 Apology 接口的方法了。这简直是太神奇的！

	看看是如何配置的吧：

	```
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	       xmlns:context="http://www.springframework.org/schema/context"
	       xsi:schemaLocation="http://www.springframework.org/schema/beans
	http://www.springframework.org/schema/beans/spring-beans.xsd
	http://www.springframework.org/schema/context
	http://www.springframework.org/schema/context/spring-context.xsd">
	 
	    <context:component-scan base-package="aop.demo"/>
	 
	    <bean id="greetingProxy" class="org.springframework.aop.framework.ProxyFactoryBean">
	        <property name="interfaces" value="aop.demo.Apology"/>          <!-- 需要动态实现的接口 -->
	        <property name="target" ref="greetingImpl"/>                    <!-- 目标类 -->
	        <property name="interceptorNames" value="greetingIntroAdvice"/> <!-- 引入增强 -->
	        <property name="proxyTargetClass" value="true"/>                <!-- 代理目标类（默认为 false，代理接口） -->
	    </bean>
	 
	</beans>
	```
	需要注意 proxyTargetClass 属性，它表明是否代理目标类，默认为 false，也就是代理接口了，此时 Spring 就用 JDK 动态代理。如果为 true，那么 Spring 就用 CGLib 动态代理。这简直就是太方便了！Spring 封装了这一切，让程序员不在关心那么多的细节。我们要向老罗同志致敬，您是我们心中永远的 idol！

	当您看完下面的客户端代码，一定会完全明白以上的这一切：

	```
	public class Client {
	 
	    public static void main(String[] args) {
	        ApplicationContext context = new ClassPathXmlApplicationContext("aop/demo/spring.xml");
	        GreetingImpl greetingImpl = (GreetingImpl) context.getBean("greetingProxy"); // 注意：转型为目标类，而并非它的 Greeting 接口
	        greetingImpl.sayHello("Jack");
	 
	        Apology apology = (Apology) greetingImpl; // 将目标类强制向上转型为 Apology 接口（这是引入增强给我们带来的特性，也就是“接口动态实现”功能）
	        apology.saySorry("Jack");
	    }
	}
	```
	没想到 saySorry() 方法原来是可以被 greetingImpl 对象来直接调用的，只需将其强制转换为该接口即可。

## AOP的优势

	利用AOP可以对业务逻辑的各个部分进行隔离，从而使得业务逻辑各个部分之间的耦合度降低，提高程序的可重用性，灵活性，也提高开发效率

## AOP和OOP

### 区别

	两者是面向不同领域的两种设计思想。
	OOP是面向对象编程，是针对业务处理过程的实体及其属性、行为进行抽象封装，以获得更加清晰高效的逻辑单元划分。
	AOP则是针对业务处理过程中的切面进行提取，所面对的是处理过程中的某个步骤或阶段，以获得逻辑过程中各个部分之间低耦合性道德隔离效果。
	OOP的关注点是将需求功能划分为不同的且相对独立、封装良好的类，类之间的关系以继承、多态来定义。AOP的关注点是将通用的需求功能从不相关的类当中分离出来，使得很多类可以共享一个行为，通用行为的变化不影响各个类


### 关系
	
	AOP是OOP的补充和完善，提高代码的灵活性、可重用性和可扩展性


参考链接：
http://www.importnew.com/20748.html
https://www.cnblogs.com/Wolfmanlq/p/6036019.html
https://www.cnblogs.com/hongwz/p/5764917.html
http://www.cnblogs.com/xrq730/p/4919025.html
https://www.zhihu.com/question/24863332