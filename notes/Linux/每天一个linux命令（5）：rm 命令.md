rm�ǳ��õ����������Ĺ���Ϊɾ��һ��Ŀ¼�е�һ�������ļ���Ŀ¼����Ҳ���Խ�ĳ��Ŀ¼�����µ������ļ�����Ŀ¼��ɾ�������������ļ���ֻ��ɾ�������ӣ�ԭ���ļ������ֲ��䡣

rm��һ��Σ�յ����ʹ�õ�ʱ��Ҫ�ر��ģ�����������֣���������ϵͳ�ͻ����������������/����Ŀ¼����ִ��rm * -rf�������ԣ�������ִ��rm֮ǰ�����ȷ��һ�����ĸ�Ŀ¼������Ҫɾ��ʲô����������ʱ���ָ߶����ѵ�ͷ�ԡ�

1�������ʽ��

rm [ѡ��] �ļ��� 

2������ܣ�

ɾ��һ��Ŀ¼�е�һ�������ļ���Ŀ¼�����û��ʹ��- rѡ���rm����ɾ��Ŀ¼�����ʹ�� rm ��ɾ���ļ���ͨ���Կ��Խ����ļ��ָ�ԭ״��

3�����������

    -f, --force    ���Բ����ڵ��ļ����Ӳ�������ʾ��

    -i, --interactive ���н���ʽɾ��

    -r, -R, --recursive   ָʾrm���������г���ȫ��Ŀ¼����Ŀ¼���ݹ��ɾ����

    -v, --verbose    ��ϸ��ʾ���еĲ���

       --help     ��ʾ�˰�����Ϣ���˳�

       --version  ����汾��Ϣ���˳�

4������ʵ����

ʵ��һ��ɾ���ļ�file��ϵͳ����ѯ���Ƿ�ɾ���� 

���

rm �ļ���

�����

[root@localhost test1]# ll

�ܼ� 4

-rw-r--r-- 1 root root 56 10-26 14:31 log.log

root@localhost test1]# rm log.log 

rm���Ƿ�ɾ�� һ���ļ� ��log.log��? y

root@localhost test1]# ll

�ܼ� 0[root@localhost test1]#

˵����

����rm log.log�����ϵͳ��ѯ���Ƿ�ɾ��������y��ͻ�ɾ���ļ�������ɾ��������n��

ʵ������ǿ��ɾ��file��ϵͳ������ʾ�� 

���

rm -f log1.log

�����

[root@localhost test1]# ll

�ܼ� 4

-rw-r--r-- 1 root root 23 10-26 14:40 log1.log

[root@localhost test1]# rm -f log1.log 

[root@localhost test1]# ll

�ܼ� 0[root@localhost test1]#

ʵ������ɾ���κ�.log�ļ���ɾ��ǰ��һѯ��ȷ�� 

���

rm -i *.log

�����

[root@localhost test1]# ll

�ܼ� 8

-rw-r--r-- 1 root root 11 10-26 14:45 log1.log

-rw-r--r-- 1 root root 24 10-26 14:45 log2.log

[root@localhost test1]# rm -i *.log

rm���Ƿ�ɾ�� һ���ļ� ��log1.log��? y

rm���Ƿ�ɾ�� һ���ļ� ��log2.log��? y

[root@localhost test1]# ll

�ܼ� 0[root@localhost test1]#

ʵ���ģ��� test1��Ŀ¼����Ŀ¼�����е���ɾ��

���

rm -r test1

�����

[root@localhost test]# ll

�ܼ� 24drwxr-xr-x 7 root root 4096 10-25 18:07 scf

drwxr-xr-x 2 root root 4096 10-26 14:51 test1

drwxr-xr-x 3 root root 4096 10-25 17:44 test2

drwxrwxrwx 2 root root 4096 10-25 17:46 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]# rm -r test1

rm���Ƿ����Ŀ¼ ��test1��? y

rm���Ƿ�ɾ�� һ���ļ� ��test1/log3.log��? y

rm���Ƿ�ɾ�� Ŀ¼ ��test1��? y

[root@localhost test]# ll

�ܼ� 20drwxr-xr-x 7 root root 4096 10-25 18:07 scf

drwxr-xr-x 3 root root 4096 10-25 17:44 test2

drwxrwxrwx 2 root root 4096 10-25 17:46 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]#

ʵ���壺rm -rf test2����Ὣ test2 ��Ŀ¼����Ŀ¼�����е���ɾ��,���Ҳ���һһȷ��

���

rm -rf  test2 

�����

[root@localhost test]# rm -rf test2

[root@localhost test]# ll

�ܼ� 16drwxr-xr-x 7 root root 4096 10-25 18:07 scf

drwxrwxrwx 2 root root 4096 10-25 17:46 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]#

ʵ������ɾ���� -f ��ͷ���ļ�

���

rm -- -f

�����

[root@localhost test]# touch -- -f

[root@localhost test]# ls -- -f

-f[root@localhost test]# rm -- -f

rm���Ƿ�ɾ�� һ����ļ� ��-f��? y

[root@localhost test]# ls -- -f

ls: -f: û���Ǹ��ļ���Ŀ¼

[root@localhost test]#

Ҳ����ʹ������Ĳ�������:

[root@localhost test]# touch ./-f

[root@localhost test]# ls ./-f

./-f[root@localhost test]# rm ./-f

rm���Ƿ�ɾ�� һ����ļ� ��./-f��? y

[root@localhost test]#

ʵ���ߣ��Զ������վ����

���

myrm(){ D=/tmp/$(date +%Y%m%d%H%M%S); mkdir -p $D; mv "$@" $D && echo "moved to $D ok"; }

�����

[root@localhost test]# myrm(){ D=/tmp/$(date +%Y%m%d%H%M%S); mkdir -p $D; 	mv "$@" $D && echo "moved to $D ok"; }

[root@localhost test]# alias rm='myrm'

[root@localhost test]# touch 1.log 2.log 3.log

[root@localhost test]# ll

�ܼ� 16

-rw-r--r-- 1 root root    0 10-26 15:08 1.log

-rw-r--r-- 1 root root    0 10-26 15:08 2.log

-rw-r--r-- 1 root root    0 10-26 15:08 3.log

drwxr-xr-x 7 root root 4096 10-25 18:07 scf

drwxrwxrwx 2 root root 4096 10-25 17:46 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]# rm [123].log

moved to /tmp/20121026150901 ok

[root@localhost test]# ll

�ܼ� 16drwxr-xr-x 7 root root 4096 10-25 18:07 scf

drwxrwxrwx 2 root root 4096 10-25 17:46 test3

drwxr-xr-x 2 root root 4096 10-25 17:56 test4

drwxr-xr-x 3 root root 4096 10-25 17:56 test5

[root@localhost test]# ls /tmp/20121026150901/

1.log  2.log  3.log

[root@localhost test]#

˵����

����Ĳ�������ģ���˻���վ��Ч������ɾ���ļ���ʱ��ֻ�ǰ��ļ��ŵ�һ����ʱĿ¼�У���������Ҫ��ʱ�򻹿��Իָ�������