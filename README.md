# Build_Tool_For_ek-tm4c13gxl
+ 提供了一些简单的脚本用来为EK-TM4C123GXL设备生成Makefile以及其他的一些自动化操作

## 文件内容
+ tm4c_build.sh : 生成Makefile & 编译 & 烧写 & 检查更新
+ tm4c_debug.sh : 生成Makefile & 编译 & 后台启动OpenOCD & 启动GDB & 完成gdb初始化操作 & 检查更新
+ tm4c_genMakefile.sh : 生成Makefile
+ tm4c_MakefileTemplate : Makefile的模板
+ tm4c_gdbprecmdTemplate : gdb初始化操作的模板
+ tm4c_update.sh : 自动更新
+ install.sh : 初次安装使用

## 注意事项
1.	工具将会检索当前目录下所有的c文件(包括子目录)生成对应的依赖关系(目前脚本仅处理driverlib/*.h以及utils/*.h的依赖), 请务必保证当前目录下只有需要编译的c文件.
2.	默认以含有main(void)或者main()函数的c文件的文件名作为工程名, 如果检测到有多个main函数, 将以链接脚本的文件名作为工程名, 请保证链接脚本的文件名与工程名一致.
3.	在使用tm4c_Debug.sh时, OpenOCD的输出被重定向至文件openocd_log.
4.	如果移动了工程目录的路径, 那么请先使用tm4c_genMakefile.sh && make clean清空之前的编译结果, 再执行其他的操作, 否则会出现错误.
5.	如果存在libdriver.a找不到的情况,请尝试执行cd ~/ToolChain/TivaWare && make clean && make以重新编译TivaWare.

## Changelog
### [2015-01-09	V0.40]
1.	添加了自动更新的实现
2.	添加在线安装脚本

### [2015-01-09	V0.30]
>>>>>>> testing
1.	取消了大量临时文件的使用, 优化了程序流程
2.	调整了程序的运行方式, 修改为全局脚本运行
3.	添加了几种常见的main函数的识别

### [2015-01-09	V0.22]
1.	改进识别main函数的方式,将忽略掉任何注释掉的代码

### [2015-01-08	V0.21]
1.	修正grep误识别utf-8文件为二进制文件的问题

### [2015-01-07	V0.2]
1.	改进对于工程名的识别方式,当检测到多个main函数时,以ld文件名作为工程名
2.	增加对于是否需要make clean的判断,减少编译出错的可能性
3.	增加tm4c_debug的支持,轻松进入在线调试环境
4.	默认向目标文件中添加调试相关信息
