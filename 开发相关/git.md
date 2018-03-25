# github上fork了别人的项目后，再同步更新别人的提交

git remote -v #查看远程信息
git remote add upstream git@github.com:xxx/xxx.git #添加远程仓库（git remote remove xxx可以删除）
git fetch upstream #从源仓库更新代码
git merge upstream/master #更新并合并到自己的仓库代码
git push #提交代码

# git merge 出现nano编辑提交界面

这个是使用nano进行编辑提交的页面，退出方法为：

Ctrl + X然后输入y再然后回车，就可以退出了

如果你想把默认编辑器换成别的：

在GIT配置中设置 core.editor: git config --global core.editor "vim"

设置git配置: git config --global core.editor "vim"
或者
设置环境变量GIT_EDITOR: export GIT_EDITOR=vim
