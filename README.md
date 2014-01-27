# MyProject #



## 功能 ##

* 管理项目
* 管理session
* 集成ctags/cscope/global
* 通过简单的配置与其他插件集成

## 使用说明 ##

### 一. 项目管理 ###

#### 1.创建项目 ####

创建项目有两种方式:

1. 在项目的根目录放一个叫 *project.vim* 的文件即可。优点是方便，缺点是没有记录到项目列表中，每次载入都需要输入项目的路径。

2. 利用插件自带的命令 *:MPCreate* 生成。MPCreate支持不带参数或者带参数运行。

    1) *MPCreate* : 自动在项目根目录新建一个 *project.vim* 文件,并将项目加入项目列表中。

    2) *MPCreate template* : 同上，但会在 *project.vim* 中加入一些被注释掉的配置项，你可以稍后自行按需开启。
    
    3) *MPCreate question* : 插件会逐个询问你是否开启某功能，你只要选择Yes或者No即可。

#### 2.载入项目 ####

载入项目有三种方式:

1. *MPLoad* 命令: 用 *"MPLoad 项目路径"* 载入项目。假如项目是通过 *MPCreate* 创建的，则可以在输入*"MPLoad "*后利用Tab自动补全路径。

2. 通过项目列表: 输入 *MPProjectList* 打开项目列表，移动光标到选中的项目上按回车即可。

3. 自动载入: 在你的vim配置文件中写上 *"let g:MP\_Bufread\_AutoLoad = 1"*，当你打开项目中的某个文件时，插件会自动将该项目载入。

#### 3.删除项目 ####

输入 *MPProjectList* 打开项目列表，移动光标到要删除的项目的，按 "d"。

### 二. Session管理 ###

一个项目可以拥有多个Session，所有Session都保存在项目的根目录，名字类似*"abc.session.vim"*。

#### 1.保存Session ####

输入 *"MPSessionSave Session名称"* 。假如不带Session名称则保存到默认Session（default.session.vim）。

#### 2.载入Session ####

输入 *"MPSessionLoad Session名称"* 。假如不带Session名称则载入默认Session（default.session.vim）。

#### 3.载入项目时自动载入默认Session ####

在vim配置文件中写上 *"let g:MP_Session_AutoLoad = 1"*

#### 4.关闭vim时自动保存默认Session ####

在vim配置文件中写上 *"let g:MP_Session_AutoSave = 1"*

### 三. Ctags/Cscope/GNU Global ###

Cscope和GNU Global只能二选其一，假如选择了GNU Global则Cscope不起作用，反之亦然。如果使用GNU Global记得在项目配置文件中写上 *"set cscopeprg=gtags-cscope"*。

通过 *MPCreate question* 生成项目的话这些都不用你再设置了，插件会自动帮你设置好。

### 四. 相关变量 ###

*g:MP\_ProjectList* 项目列表文件。默认值: globpath($HOME, '.MP_ProjectList.vim')

*g:MP\_ProjectFile* 项目文件名。默认值: 'project.vim'

*g:MP\_Window\_Height* 项目列表高度。默认值: '10'

*g:MP\_Auto\_Close* 选择项目后是否自动关闭项目列表。默认值: 1

*g:MP\_Ctags\_Enable* 是否启用ctags。默认值: 0

*g:MP\_Ctags\_Path* 定义ctags的路径。默认值: 'ctags'

*g:MP\_Ctags\_Opt* 定义ctags参数。默认值: ''

*g:MP\_Global\_Enable* 是否启用GNU global。默认值: 0

*g:MP\_Global\_Path* 定义GNU Global的路径。默认值: 'global'

*g:MP\_Gtags\_Path* 定义gtags的路径。默认值: 'gtags'

*g:MP\_Cscope\_Enable* 是否启用cscope。默认值: 0

*g:MP\_Cscope\_Path* 定义cscope的路径。默认值: 'cscope'

*g:MP\_Source\_File\_Ext\_Name* 需要建立tags的文件后缀名,如:'c,h,cpp'。默认值: ''

*g:MP\_ConfigTitleBar\_Enable* 是否允许设置标题栏。默认值: 0

*g:MP\_TitleString* 标题栏字符串。默认值: 

    %t\ %m%r\ [%{expand(\"%:~:.:h\")}]\ [ProjectPath=%{g:MP_Path}]\ -\ %{v:servername}

*g:MP\_Session\_AutoSave* 是否自动保存项目session。默认值: 0

*g:MP\_Session\_AutoLoad* 是否自动加载项目session。默认值: 0

*g:MP\_DefaultSessionName* 项目默认session文件名。默认值: 'default'

*g:MP\_Session\_Opt* Session选项。默认值: "blank,buffers,curdir,folds,globals,options,resize,tabpages,winpos,winsize"

*g:MP\_Path* 项目路径。载入项目时插件会自动修改该变量，请勿手动设置。

*g:MP\_Write\_AutoUpdate* 在文件写入时是否自动更新tags。默认值: 0

*g:MP\_Bufread\_AutoLoad* 读入文件时是否自动载入项目文件。默认值: 0
