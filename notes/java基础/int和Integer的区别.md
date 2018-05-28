# 1 int与Integer的基本使用对比

（1）Integer是int的包装类，int是基本数据类型；
（2）Integer变量必须实例化后才能使用，int变量不需要；
（3）Integer实际是对象的引用，指向此new的Integer对象，int是直接存储数据值 ；
（4）Integer的默认值是null，int的默认值是0。
（5）int和integer(无论new否)比，都为true，因为会把Integer自动拆箱为int再去比。
（6）int是在栈里创建的，Integer是在堆里创建的。栈里创建的变量要比在堆创建的速度快得多。

# 2 int与Integer的深入对比

（1）由于Integer变量实际上是对一个Integer对象的引用，所以两个通过new生成的Integer变量永远是不相等的（因为new生成的是两个对象，其内存地址不同）。

```
Integer i = new Integer(100);
Integer j = new Integer(100);
System.out.print(i == j); //false
```

（2）Integer变量和int变量比较时，只要两个变量的值是向等的，则结果为true（因为包装类Integer和基本数据类型int比较时，java会自动拆包装为int，然后进行比较，实际上就变为两个int变量的比较）

```
Integer i = new Integer(100);
int j = 100；
System.out.print(i == j); //true
```

（3）非new生成的Integer变量和new Integer()生成的变量比较时，结果为false。（因为非new生成的Integer变量指向的是java常量池中的对象，而new Integer()生成的变量指向堆中新建的对象，两者在内存中的地址不同）

```
Integer i = new Integer(100);
Integer j = 100;
System.out.print(i == j); //false
```

（4）对于两个非new生成的Integer对象，进行比较时，如果两个变量的值在区间-128到127之间，则比较结果为true，如果两个变量的值不在此区间，则比较结果为false

```
Integer i = 100;
Integer j = 100;
System.out.print(i == j); //true

Integer i = 128;
Integer j = 128;
System.out.print(i == j); //false
```

对于第4条的原因： java在编译Integer i = 100 ;时，会翻译成为Integer i = Integer.valueOf(100)。而java API中对Integer类型的valueOf的定义如下，对于-128到127之间的数，会进行缓存，Integer i = 127时，会将127进行缓存，下次再写Integer j = 127时，就会直接从缓存中取，就不会new了。

```
public static Integer valueOf(int i){
    assert IntegerCache.high >= 127;
    if (i >= IntegerCache.low && i <= IntegerCache.high){
        return IntegerCache.cache[i + (-IntegerCache.low)];
    }
    return new Integer(i);
}
```

IntegerCache是Integer的内部类，源码如下：

```
  /**
      * 缓存支持自动装箱的对象标识语义
      * -128和127（含）。
      *
      * 缓存在第一次使用时初始化。 缓存的大小
      * 可以由-XX：AutoBoxCacheMax = <size>选项控制。
      * 在VM初始化期间，java.lang.Integer.IntegerCache.high属性
      * 可以设置并保存在私有系统属性中
     */
    private static class IntegerCache {
        static final int low = -128;
        static final int high;
        static final Integer cache[];

        static {
            // high value may be configured by property
            int h = 127;
            String integerCacheHighPropValue =
                sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
            if (integerCacheHighPropValue != null) {
                int i = parseInt(integerCacheHighPropValue);
                i = Math.max(i, 127);
                // Maximum array size is Integer.MAX_VALUE
                h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
            }
            high = h;

            cache = new Integer[(high - low) + 1];
            int j = low;
            for(int k = 0; k < cache.length; k++)
                cache[k] = new Integer(j++);
        }

        private IntegerCache() {}
    }
```

# 3 再次解读int基本数据类型与Integer包装类型的微妙关系

3.1 初始化时，int i =1;

Integer i= new Integer(1);(要把Integer 当做一个类看)；但由于有了自动装箱和拆箱(始于jdk1.5)，使得对Integer类也可使用：Integer i= 1；

int是基本数据类型（面向过程留下的痕迹，不过是对java的有益补充）,Integer是一个类，是面向对象的体现，是int的扩展，定义了很多的转换方法，提供了处理int类型时非常有用的其他一些常量和方法。
即int是基本类型,不是类,为了符合面向对象编程,后来出现了Integer类,他是对int进行封装的。

3.2 实现这种对象包装的目的主要是因为类能够提供必要的方法，用于实现基本数据类型的数值与可打印字符串之间的转换，以及一些其他的实用程序方法。   

另外，有些数据结构库类只能操作对象，而不支持基本数据类型的变量，包装类提供一种便利的方式，能够把基本数据类型转换成等价的对象，从而可以利用数据结构库类进行处理。

3.3 int是基本的数据类型，Integer是int的封装类，int和Integer都可以表示某一个数值，int和Integer不能够互用，因为他们两种不同的数据类型。

如：
(1)
ArrayList al=new ArrayList();
int n=40;
Integer nI=new Integer(n);
al.add(n);//不可以
al.add(nI);//可以

(2)并且泛型定义时也不支持int: 如：
List<Integer> list = new ArrayList<Integer>();可以  
而List<int> list = new ArrayList<int>();则不行。

(3)总而言之：如果我们定义一个int类型的数，只是用来进行一些加减乘除的运算or作为参数进行传递，那么就可以直接声明为int基本数据类型，但如果要像对象一样来进行处理，那么就要用Integer来声明一个对象，因为java是面向对象的语言，因此当声明为对象时能够提供很多对象间转换的方式与一些常用的方法。自认为java作为一门面向对象的语言，我们在声明一个变量时最好声明为对象格式，这样更有利于你对面向对象的理解。

3.4 基本类型与包装类型的异同：

(1)在Java中，一切皆对象，但八大基本数据类型却不是对象。
(2)声明方式的不同，基本类型无需通过new关键字来创建，而封装类型需new关键字。
(3)存储方式及位置的不同，基本类型是直接存储变量的值保存在堆栈中能高效的存取，封装类型需要通过引用指向实例，具体的实例保存在堆中。
(4)初始值的不同，封装类型的初始值为null，基本类型的的初始值视具体的类型而定，比如int类型的初始值为0(整数：包括int,short,byte,long ,初始值为0)，boolean类型为false，浮点型：float,double ,初始值为0.0，字符：char ,初始值为空格，即'' "，如果输出，在Console上是看不到效果的。
(5)使用方式的不同，比如与集合类合作使用时只能使用包装类型。











