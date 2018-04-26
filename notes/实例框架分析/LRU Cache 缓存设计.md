# 什么是Cache

Cache，即高速缓存，是介于CPU和内存之间的高速小容量存储器。在金字塔式存储体系中它位于自顶向下的第二层，仅次于CPU寄存器。其容量远小于内存，但速度却可以接近CPU的频率。

当CPU发出内存访问请求时，会先查看 Cache 内是否有请求数据。

如果存在（命中），则直接返回该数据；

如果不存在（失效），再去访问内存 —— 先把内存中的相应数据载入缓存，再将其返回处理器。

提供“高速缓存”的目的是让数据访问的速度适应CPU的处理速度，通过减少访问内存的次数来提高数据存取的速度。

# 原理

Cache 技术所依赖的原理是”程序执行与数据访问的局部性原理“，这种局部性表现在两个方面：

时间局部性：如果程序中的某条指令一旦执行，不久以后该指令可能再次执行，如果某数据被访问过，不久以后该数据可能再次被访问。

空间局部性：一旦程序访问了某个存储单元，在不久之后，其附近的存储单元也将被访问，即程序在一段时间内所访问的地址，可能集中在一定的范围之内，这是因为指令或数据通常是顺序存放的。

时间局部性是通过将近来使用的指令和数据保存到Cache中实现。空间局部性通常是使用较大的高速缓存，并将 预取机制 集成到高速缓存控制逻辑中来实现。

# 替换策略

Cache的容量是有限的，当Cache的空间都被占满后，如果再次发生缓存失效，就必须选择一个缓存块来替换掉。常用的替换策略有以下几种：

随机算法（Rand）：随机法是随机地确定替换的存储块。设置一个随机数产生器，依据所产生的随机数，确定替换块。这种方法简单、易于实现，但命中率比较低。

先进先出算法（FIFO, First In First Out）：先进先出法是选择那个最先调入的那个块进行替换。当最先调入并被多次命中的块，很可能被优先替换，因而不符合局部性规律。这种方法的命中率比随机法好些，但还不满足要求。

最久未使用算法（LRU, Least Recently Used）：LRU法是依据各块使用的情况， 总是选择那个最长时间未被使用的块替换。这种方法比较好地反映了程序局部性规律。

最不经常使用算法（LFU, Least Frequently Used）：将最近一段时期内，访问次数最少的块替换出Cache。

# 概念的扩充

如今高速缓存的概念已被扩充，不仅在CPU和主内存之间有Cache，而且在内存和硬盘之间也有Cache（磁盘缓存），乃至在硬盘与网络之间也有某种意义上的Cache──称为Internet临时文件夹或网络内容缓存等。凡是位于速度相差较大的两种硬件之间，用于协调两者数据传输速度差异的结构，均可称之为Cache。

# LRU Cache的实现

Google的一道面试题：

Design an LRU cache with all the operations to be done in O(1)O(1) .

思路分析

对一个Cache的操作无非三种：插入(insert)、替换(replace)、查找（lookup）。

为了能够快速删除最久没有访问的数据项和插入最新的数据项，我们使用 双向链表 连接Cache中的数据项，并且保证链表维持数据项从最近访问到最旧访问的顺序。

插入：当Cache未满时，新的数据项只需插到双链表头部即可。时间复杂度为O(1)O(1).
替换：当Cache已满时，将新的数据项插到双链表头部，并删除双链表的尾结点即可。时间复杂度为O(1)O(1).
查找：每次数据项被查询到时，都将此数据项移动到链表头部。

经过分析，我们知道使用双向链表可以保证插入和替换的时间复杂度是O(1)O(1)，但查询的时间复杂度是O(n)O(n)，因为需要对双链表进行遍历。为了让查找效率也达到O(1)O(1)，很自然的会想到使用 hash table 。


```
class Node{
    int key;
    int value;
    Node pre;
    Node next;
 
    public Node(int key, int value){
        this.key = key;
        this.value = value;
    }
}
```

```
public class LRUCache {
    int capacity;
    HashMap<Integer, Node> map = new HashMap<Integer, Node>();
    Node head=null;//先声明一个头结点和一个尾节点
    Node end=null;
    //初始化大小，缓存是有大小限制的，超过规定的大小时就得移除
    public LRUCache(int capacity) {
        this.capacity = capacity;
    }
    //获取一个缓存数据之后，应该把这个数据在当前位置中移除，并重新添加到头的位置，这些都是在返回数据之前完成的
    public int get(int key) {
        if(map.containsKey(key)){
            Node n = map.get(key);
            remove(n);
            setHead(n);
            return n.value;
        }
 
        return -1;
    }
    //移除元素分为，N的前边和N的后边都要看是怎么样的情况
    public void remove(Node n){
        if(n.pre!=null){
            n.pre.next = n.next;
        }else{
            head = n.next;
        }
 
        if(n.next!=null){
            n.next.pre = n.pre;
        }else{
            end = n.pre;
        }
 
    }
 
    public void setHead(Node n){
        n.next = head;//head原位置应该是指向第一个元素，现在把这个位置给n.next
        n.pre = null;
 
        if(head!=null)
            head.pre = n;
 
        head = n;
        //判断头尾是够为空
        if(end ==null)
            end = head;
    }
    //设置看原位置是否有元素，如果有的话就替换，这证明使用过了，然后将其替换为头结点的元素，若果是一个新的节点就要判断它的大小是否符合规范
    public void set(int key, int value) {
        if(map.containsKey(key)){
            Node old = map.get(key);
            old.value = value;
            remove(old);
            setHead(old);
        }else{
            Node created = new Node(key, value);
            if(map.size()>=capacity){
                map.remove(end.key);
                remove(end);
                setHead(created);
 
            }else{
                setHead(created);
            }    
 
            map.put(key, created);
        }
    }
}
```



