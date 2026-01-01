
# 这是什么？
这是一个使用 prolog 编写的命令行扫雷小游戏。

# 依赖与兼容性
- 测试使用的环境为 Ubuntu 22.04.5 LTS
- 使用的 prolog 实现为 swi-prolog，版本为8.4.2 for x86_64-linux
- 其它依赖/库：暂无

# 如何开始
你可以编译代码，或是直接在 prolog 的 repl 上运行

## 通过编译的方式
编译之前，请在您的机器上安装 swi-prolog。

``` sh
$ make
$ ./build/pl-mine
```

## 直接运行的方式
运行之前，请在您的机器上安装 prolog

``` sh
$ prolog
```

``` prolog
?- ['main.pl'].
true.

?- main.
```

