cat�������;�������ļ����׼���벢��ӡ��������������ʾ�ļ����ݣ����߽������ļ�����������ʾ�����ߴӱ�׼�����ȡ���ݲ���ʾ���������ض���������ʹ�á� 

1�������ʽ��

cat [ѡ��] [�ļ�]...

2������ܣ�

cat��Ҫ�������ܣ�

1.һ����ʾ�����ļ�:cat filename

2.�Ӽ��̴���һ���ļ�:cat > filename ֻ�ܴ������ļ�,���ܱ༭�����ļ�.

3.�������ļ��ϲ�Ϊһ���ļ�:cat file1 file2 > file

3�����������

-A, --show-all           �ȼ��� -vET

-b, --number-nonblank    �Էǿ�����б��

-e                       �ȼ��� -vE

-E, --show-ends          ��ÿ�н�������ʾ $

-n, --number     ������������б��,��1��ʼ������������������

-s, --squeeze-blank  �������������ϵĿհ��У��ʹ���Ϊһ�еĿհ��� 

-t                       �� -vT �ȼ�

-T, --show-tabs          �������ַ���ʾΪ ^I

-u                       (������)

-v, --show-nonprinting   ʹ�� ^ �� M- ���ã����� LFD �� TAB ֮��

4��ʹ��ʵ����

ʵ��һ���� log2012.log ���ļ����ݼ����кź����� log2013.log ����ļ���

���

cat -n log2012.log log2013.log 

�����

[root@localhost test]# cat log2012.log 

2012-01

2012-02

======[root@localhost test]# cat log2013.log 

2013-01

2013-02

2013-03

======[root@localhost test]# cat -n log2012.log log2013.log 

     	1  2012-01

     	2  2012-02

     	3

     	4

     	5  ======

     	6  2013-01

     	7  2013-02

     	8

     	9

    	10  2013-03

    	11  ======[root@localhost test]#

˵����

ʵ�������� log2012.log �� log2013.log ���ļ����ݼ����кţ��հ��в��ӣ�֮�����ݸ��ӵ� log.log � 

���

cat -b log2012.log log2013.log log.log

�����

[root@localhost test]# cat -b log2012.log log2013.log log.log

     1  2012-01

     2  2012-02

     3  ======

     4  2013-01

     5  2013-02

     6  2013-03

     7  ======[root@localhost test]#

ʵ�������� log2012.log ���ļ����ݼ����кź����� log.log ����ļ��� 

���

�����

[root@localhost test]# cat log.log 

[root@localhost test]# cat -n log2012.log > log.log

[root@localhost test]# cat -n log.log 

     1  2012-01

     2  2012-02

     3

     4

     5  ======

[root@localhost test]#

ʵ���ģ�ʹ��here doc�������ļ�

�����

[root@localhost test]# cat >log.txt <<EOF

> Hello

> World

> Linux

> PWD=$(pwd)

> EOF

[root@localhost test]# ls -l log.txt 

-rw-r--r-- 1 root root 37 10-28 17:07 log.txt

[root@localhost test]# cat log.txt 

Hello

World

Linux

PWD=/opt/soft/test

[root@localhost test]#

˵����

ע����岿�֣�here doc���Խ����ַ����滻��

��ע��

tac (������ʾ)

���

tac log.txt

�����

[root@localhost test]# tac log.txt 

PWD=/opt/soft/test

Linux

World

Hello

˵����

tac �ǽ� cat ��д�������������Ĺ��ܾ͸� cat �෴�� cat ���ɵ�һ�е����һ��������ʾ��өĻ�ϣ��� tac ���������һ�е���һ�з�����өĻ����ʾ������