## windows下编辑的shell上传至linux下报错

### 问题描述：
	windows下编辑的shell文件上传至Linux后运行报错，报错原因包含 $'\r': 未找到命令，在linux下重写一个内容相同的shell运行没有问题。
### 原因分析：
	因为在dos/windows下按下回车键输入的是"回车(CR)" 和"换行(LF)",而Linux/unix下按一次回车只输入"换行(LF)",所以shell文件换行处多了CR，在Linux下运行时会报错找不到命令。
### 解决方法：
	vi模式下使用:set ff , 可以看到文件格式为：fileformat=dos
	vi模式下使用:set ff/fileformat=unix, 回车后:wq, 则文件格式修改为unix，再次执行脚本即可运行。