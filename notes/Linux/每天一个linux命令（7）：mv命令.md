mv������move����д�����������ƶ��ļ����߽��ļ�������move (rename) files������Linuxϵͳ�³��õ�����������������ļ�����Ŀ¼��

1�������ʽ��

    mv [ѡ��] Դ�ļ���Ŀ¼ Ŀ���ļ���Ŀ¼

2������ܣ�

��mv�����еڶ����������͵Ĳ�ͬ����Ŀ���ļ�����Ŀ��Ŀ¼����mv����ļ���������������һ���µ�Ŀ¼�С����ڶ��������������ļ�ʱ��mv��������ļ�����������ʱ��Դ�ļ�ֻ����һ����Ҳ������ԴĿ¼����������������Դ�ļ���Ŀ¼������Ϊ������Ŀ���ļ��������ڶ����������Ѵ��ڵ�Ŀ¼����ʱ��Դ�ļ���Ŀ¼���������ж����mv���������ָ����Դ�ļ�������Ŀ��Ŀ¼�С��ڿ��ļ�ϵͳ�ƶ��ļ�ʱ��mv�ȿ������ٽ�ԭ���ļ�ɾ�������������ļ�������Ҳ����ʧ��

3�����������

-b �����踲���ļ����򸲸�ǰ���б��ݡ� 

-f ��force ǿ�Ƶ���˼�����Ŀ���ļ��Ѿ����ڣ�����ѯ�ʶ�ֱ�Ӹ��ǣ�

-i ����Ŀ���ļ� (destination) �Ѿ�����ʱ���ͻ�ѯ���Ƿ񸲸ǣ�

-u ����Ŀ���ļ��Ѿ����ڣ��� source �Ƚ��£��Ż����(update)

	   -t  �� --target-directory=DIRECTORY move all SOURCE arguments into DIRECTORY����ָ��mv��Ŀ��Ŀ¼����ѡ���������ƶ����Դ�ļ���һ��Ŀ¼���������ʱĿ��Ŀ¼��ǰ��Դ�ļ��ں�

4������ʵ����

ʵ��һ���ļ�����

���

mv test.log test1.txt

�����

[root@localhost test]# ll

�ܼ� 20drwxr-xr-x 6 root root 4096 10-27 01:58 scf

drwxrwxrwx 2 root root 4096 10-25 17:46 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

-rw-r--r-- 1 root root   16 10-28 06:04 test.log

[root@localhost test]# mv test.log test1.txt

[root@localhost test]# ll

�ܼ� 20drwxr-xr-x 6 root root 4096 10-27 01:58 scf

-rw-r--r-- 1 root root   16 10-28 06:04 test1.txt

drwxrwxrwx 2 root root 4096 10-25 17:46 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

˵����

���ļ�test.log������Ϊtest1.txt

ʵ�������ƶ��ļ�

���

mv test1.txt test3

�����

[root@localhost test]# ll

�ܼ� 20drwxr-xr-x 6 root root 4096 10-27 01:58 scf

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

drwxrwxrwx 2 root root 4096 10-25 17:46 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]# mv test1.txt test3

[root@localhost test]# ll

�ܼ� 16drwxr-xr-x 6 root root 4096 10-27 01:58 scf

drwxrwxrwx 2 root root 4096 10-28 06:09 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]# cd test3

[root@localhost test3]# ll

�ܼ� 4

-rw-r--r-- 1 root root 29 10-28 06:05 test1.txt

[root@localhost test3]#

˵����

��test1.txt�ļ��Ƶ�Ŀ¼test3��

ʵ���������ļ�log1.txt,log2.txt,log3.txt�ƶ���Ŀ¼test3�С� 

���

mv log1.txt log2.txt log3.txt test3

mv -t /opt/soft/test/test4/ log1.txt log2.txt 	log3.txt 

�����

[root@localhost test]# ll

�ܼ� 28

-rw-r--r-- 1 root root    8 10-28 06:15 log1.txt

-rw-r--r-- 1 root root   12 10-28 06:15 log2.txt

-rw-r--r-- 1 root root   13 10-28 06:16 log3.txt

drwxrwxrwx 2 root root 4096 10-28 06:09 test3

[root@localhost test]# mv log1.txt log2.txt log3.txt test3

[root@localhost test]# ll

�ܼ� 16drwxrwxrwx 2 root root 4096 10-28 06:18 test3

[root@localhost test]# cd test3/

[root@localhost test3]# ll

�ܼ� 16

-rw-r--r-- 1 root root  8 10-28 06:15 log1.txt

-rw-r--r-- 1 root root 12 10-28 06:15 log2.txt

-rw-r--r-- 1 root root 13 10-28 06:16 log3.txt

-rw-r--r-- 1 root root 29 10-28 06:05 test1.txt

[root@localhost test3]#

[root@localhost test3]# ll

�ܼ� 20

-rw-r--r-- 1 root root    8 10-28 06:15 log1.txt

-rw-r--r-- 1 root root   12 10-28 06:15 log2.txt

-rw-r--r-- 1 root root   13 10-28 06:16 log3.txt

drwxr-xr-x 2 root root 4096 10-28 06:21 logs

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

[root@localhost test3]# mv -t /opt/soft/test/test4/ log1.txt log2.txt 	log3.txt 

[root@localhost test3]# cd ..

[root@localhost test]# cd test4/

[root@localhost test4]# ll

�ܼ� 12

-rw-r--r-- 1 root root  8 10-28 06:15 log1.txt

-rw-r--r-- 1 root root 12 10-28 06:15 log2.txt

-rw-r--r-- 1 root root 13 10-28 06:16 log3.txt

[root@localhost test4]#

˵����

mv log1.txt log2.txt log3.txt test3 ���log1.txt ��log2.txt�� log3.txt �����ļ��Ƶ� test3Ŀ¼��ȥ��mv -t /opt/soft/test/test4/ log1.txt log2.txt log3.txt �����ֽ������ļ��ƶ���test4Ŀ¼��ȥ

ʵ���ģ����ļ�file1����Ϊfile2�����file2�Ѿ����ڣ���ѯ���Ƿ񸲸�

���

mv -i log1.txt log2.txt

�����

[root@localhost test4]# ll

�ܼ� 12

-rw-r--r-- 1 root root  8 10-28 06:15 log1.txt

-rw-r--r-- 1 root root 12 10-28 06:15 log2.txt

-rw-r--r-- 1 root root 13 10-28 06:16 log3.txt

[root@localhost test4]# cat log1.txt 

odfdfs

[root@localhost test4]# cat log2.txt 

ererwerwer

[root@localhost test4]# mv -i log1.txt log2.txt 

mv���Ƿ񸲸ǡ�log2.txt��? y

[root@localhost test4]# cat log2.txt 

odfdfs

[root@localhost test4]#

ʵ���壺���ļ�file1����Ϊfile2����ʹfile2���ڣ�Ҳ��ֱ�Ӹ��ǵ���

���

mv -f log3.txt log2.txt

�����

[root@localhost test4]# ll

�ܼ� 8

-rw-r--r-- 1 root root  8 10-28 06:15 log2.txt

-rw-r--r-- 1 root root 13 10-28 06:16 log3.txt

[root@localhost test4]# cat log2.txt 

odfdfs

[root@localhost test4]# cat log3

cat: log3: û���Ǹ��ļ���Ŀ¼

[root@localhost test4]# ll

�ܼ� 8

-rw-r--r-- 1 root root  8 10-28 06:15 log2.txt

-rw-r--r-- 1 root root 13 10-28 06:16 log3.txt

[root@localhost test4]# cat log2.txt 

odfdfs

[root@localhost test4]# cat log3.txt 

dfosdfsdfdss

[root@localhost test4]# mv -f log3.txt log2.txt 

[root@localhost test4]# cat log2.txt 

dfosdfsdfdss

[root@localhost test4]# ll

�ܼ� 4

-rw-r--r-- 1 root root 13 10-28 06:16 log2.txt

[root@localhost test4]#

˵����

log3.txt������ֱ�Ӹ�����log2.txt���ݣ�-f ���Ǹ�Σ�յ�ѡ�ʹ�õ�ʱ��һ��Ҫ����ͷ��������һ���������ò��ü�������

ʵ������Ŀ¼���ƶ�

���

mv dir1 dir2 

�����

[root@localhost test4]# ll

-rw-r--r-- 1 root root 13 10-28 06:16 log2.txt

[root@localhost test4]# ll

-rw-r--r-- 1 root root 13 10-28 06:16 log2.txt

[root@localhost test4]# cd ..

[root@localhost test]# ll

drwxr-xr-x 6 root root 4096 10-27 01:58 scf

drwxrwxrwx 3 root root 4096 10-28 06:24 test3

drwxr-xr-x 2 root root 4096 10-28 06:48 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]# cd test3

[root@localhost test3]# ll

drwxr-xr-x 2 root root 4096 10-28 06:21 logs

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

[root@localhost test3]# cd ..

[root@localhost test]# mv test4 test3

[root@localhost test]# ll

drwxr-xr-x 6 root root 4096 10-27 01:58 scf

drwxrwxrwx 4 root root 4096 10-28 06:54 test3

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]# cd test3/

[root@localhost test3]# ll

drwxr-xr-x 2 root root 4096 10-28 06:21 logs

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

drwxr-xr-x 2 root root 4096 10-28 06:48 test4

[root@localhost test3]#

˵����

���Ŀ¼dir2�����ڣ���Ŀ¼dir1����Ϊdir2�����򣬽�dir1�ƶ���dir2�С�

 

ʵ��7���ƶ���ǰ�ļ����µ������ļ�����һ��Ŀ¼

���

mv * ../

�����

[root@localhost test4]# ll

-rw-r--r-- 1 root root 25 10-28 07:02 log1.txt

-rw-r--r-- 1 root root 13 10-28 06:16 log2.txt

[root@localhost test4]# mv * ../

[root@localhost test4]# ll

[root@localhost test4]# cd ..

[root@localhost test3]# ll

-rw-r--r-- 1 root root   25 10-28 07:02 log1.txt

-rw-r--r-- 1 root root   13 10-28 06:16 log2.txt

drwxr-xr-x 2 root root 4096 10-28 06:21 logs

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

drwxr-xr-x 2 root root 4096 10-28 07:02 test4

ʵ���ˣ��ѵ�ǰĿ¼��һ����Ŀ¼����ļ��ƶ�����һ����Ŀ¼��

���

mv test3/*.txt test5

�����

[root@localhost test]# ll

drwxr-xr-x 6 root root 4096 10-27 01:58 scf

drwxrwxrwx 4 root root 4096 10-28 07:02 test3

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]# cd test3

[root@localhost test3]# ll

-rw-r--r-- 1 root root   25 10-28 07:02 log1.txt

-rw-r--r-- 1 root root   13 10-28 06:16 log2.txt

drwxr-xr-x 2 root root 4096 10-28 06:21 logs

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

drwxr-xr-x 2 root root 4096 10-28 07:02 test4

[root@localhost test3]# cd ..

[root@localhost test]# mv test3/*.txt test5

[root@localhost test]# cd test5

[root@localhost test5]# ll

-rw-r--r-- 1 root root   25 10-28 07:02 log1.txt

-rw-r--r-- 1 root root   13 10-28 06:16 log2.txt

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

drwxr-xr-x 2 root root 4096 10-25 17:56 test5-1

[root@localhost test5]# 	cd ..

[root@localhost test]# cd test3/

[root@localhost test3]# ll

drwxr-xr-x 2 root root 4096 10-28 06:21 logs

drwxr-xr-x 2 root root 4096 10-28 07:02 test4

[root@localhost test3]#

ʵ���ţ��ļ�������ǰ���򵥱��ݣ�ǰ��Ӳ���-b

���

mv log1.txt -b log2.txt

�����

[root@localhost test5]# ll

-rw-r--r-- 1 root root   25 10-28 07:02 log1.txt

-rw-r--r-- 1 root root   13 10-28 06:16 log2.txt

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

drwxr-xr-x 2 root root 4096 10-25 17:56 test5-1

[root@localhost test5]# mv log1.txt -b log2.txt

mv���Ƿ񸲸ǡ�log2.txt��? y

[root@localhost test5]# ll

-rw-r--r-- 1 root root   25 10-28 07:02 log2.txt

-rw-r--r-- 1 root root   13 10-28 06:16 log2.txt~

-rw-r--r-- 1 root root   29 10-28 06:05 test1.txt

drwxr-xr-x 2 root root 4096 10-25 17:56 test5-1

[root@localhost test5]#

˵����

-b �����ܲ�����mv��ȥ��ȡ��������VERSION_CONTROL����Ϊ���ݲ��ԡ�

--backup��ѡ��ָ�����Ŀ���ļ�����ʱ�Ķ������������ֱ��ݲ��ԣ�

1.CONTROL=none��off : �����ݡ�

2.CONTROL=numbered��t�����ֱ�ŵı���

3.CONTROL=existing��nil��������������ֱ�ŵı��ݣ��������ű���m+1...n��

ִ��mv����ǰ�Ѵ��������ֱ�ŵ��ļ�log2.txt.~1~����ô�ٴ�ִ�н�����log2.txt~2~���Դ����ơ����֮ǰû�������ֱ�ŵ��ļ�����ʹ�����潲���ļ򵥱��ݡ�

4.CONTROL=simple��never��ʹ�ü򵥱��ݣ��ڱ�����ǰ�����˼򵥱��ݣ��򵥱���ֻ����һ�ݣ��ٴα�����ʱ���򵥱���Ҳ�ᱻ���ǡ�