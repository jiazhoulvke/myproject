" myproject.vim: 一个简单的项目管理插件，还是个半成品，目前实现了自动加载、更新项目tags等功能
" Author:       jiazhoulvke
" Email:        jiazhoulvke@gmail.com
" Blog:         http://jiazhoulvke.com
" Date:         2012-06-25
" Version:      0.2
"------------------------------------------------
"if exists("g:MyProject_loaded")
"    finish
"endif
"let g:MyProject_loaded=1

" 项目文件名
if !exists('g:MP_ProjectFile')
    let g:MP_ProjectFile = 'project.vim'
endif
" 是否启用ctags
if !exists('g:MP_Ctags_Enable')
    let g:MP_Ctags_Enable = 1
endif
" 是否启用cscope
if !exists('g:MP_Cscope_Enable')
    let g:MP_Cscope_Enable = 1
endif
" 定义ctags的路径
if !exists('g:MP_Ctags_Path')
    let g:MP_Ctags_Path = 'ctags'
endif
" 定义cscope的路径
if !exists('g:MP_Cscope_Path')
    let g:MP_Cscope_Path = 'cscope'
endif
" 设置grep的路径
" Tips: 如果是在windows下使用cygwin的grep的话，搜索结果中经常会出现警告，需要在系统中添加一个名叫CYGWIN，值为nodosfilewarning的环境变量
if !exists('g:MP_Grep_Path')
    let g:MP_Grep_Path = 'grep'
endif
" 定义ctags参数,比如c++项目可以在project.vim中定义"--c++-kinds=+px"
if !exists('g:MP_Ctags_Opt')
    let g:MP_Ctags_Opt = ''
endif
" 在文件写入时是否自动更新tags
if !exists('g:MP_Write_AutoUpdate')
    let g:MP_Write_AutoUpdate = 0
endif
" 读入文件时是否自动载入项目文件
if !exists('g:MP_Bufread_AutoLoad')
    let g:MP_Bufread_AutoLoad = 1
endif
" 载入buffer时是否自动载入项目文件
if !exists('g:MP_BufEnter_AutoLoad')
    let g:MP_BufEnter_AutoLoad = 0
endif
" 每次自动载入项目时，是否允许重复载入,假如是通过命令直接指定项目路径这种方式则不会受影响,如
"     :MPLoad  项目路径
if !exists('g:MP_Project_AutoLoad_Override')
    let g:MP_Project_AutoLoad_Override = 0
endif
" 是否允许更新tags(适合临时设置禁用或启用)
if !exists('g:MP_Update_Enable')
    let g:MP_Update_Enable = 1
endif
" 是否允许载入tags(适合临时设置禁用或启用)
if !exists('g:MP_Load_Enable')
    let g:MP_Load_Enable = 1
endif
" 是否允许设置标题栏
if !exists('g:MP_ConfigTitleBar_Enable')
    let g:MP_ConfigTitleBar_Enable = 0
endif
" 标题栏字符串
if !exists('g:MP_TitleString')
    "titlestring的设置和statusline的设置差不多
    let g:MP_TitleString="%t\ %m%r\ [%{expand(\"%:~:.:h\")}]\ [ProjectPath=%{g:MP_Cur_Prj}]\ -\ %{v:servername}"
endif
" 是否启用项目session
if !exists("g:MP_Session_Enable")
    let g:MP_Session_Enable = 1
endif
" 是否自动保存项目session
if !exists("g:MP_Session_AutoSave")
    let g:MP_Session_AutoSave = 1
endif
" 是否自动加载项目session
if !exists("g:MP_Session_AutoLoad")
    let g:MP_Session_AutoLoad = 1
endif
" 项目session文件名
if !exists("g:MP_SessionFile")
    let g:MP_SessionFile = 'project_session.vim'
endif
if !exists("MP_Session_Loaded")
    let g:MP_Session_Loaded = 0
endif
" Session选项
if !exists("g:MP_Session_Opt")
    let g:MP_Session_Opt = "curdir,winpos,resize,buffers,winsize"
endif
" 需要建立tags的文件后缀名(可以针对不同项目在各自的project.vim文件中定义,如果为空则表示针对所有文件)
" 如:
" let g:MP_Source_File_Ext_Name = 'c,h,cpp'
if !exists('g:MP_Source_File_Ext_Name')
    let g:MP_Source_File_Ext_Name = ''
endif
" 项目路径
if !exists('g:MP_Cur_Prj')
    let g:MP_Cur_Prj = ''
endif

python << EOA
#coding=utf-8
import vim,os

# 向上查找指定文件，如果找到则返回目录路径
def up_find(path,filename):
    returnpath=''
    cpath=os.path.abspath(path)
    while cpath!=os.path.dirname(cpath):
        mpfn=os.path.join(cpath,filename)
        if os.access(mpfn,os.F_OK):
            returnpath=cpath
            break
        cpath=os.path.dirname(cpath)
    return returnpath

# 向上查找项目路径
def get_myproject_path():
    curpath=os.getcwd()
    if vim.eval("expand('%')"):
        curpath=os.path.dirname(os.path.abspath(vim.eval("expand('%')")))
    return up_find(curpath,vim.eval("g:MP_ProjectFile"))
EOA

" 载入项目配置文件及tags
function! <SID>MyProject_Load(projectpath)
if g:MP_Load_Enable != 1
    return
endif
if isdirectory(g:MP_Cur_Prj) && g:MP_Project_AutoLoad_Override==0 && len(a:projectpath)<1
    return
endif
python << EOA
prjpath=''
if vim.eval("a:projectpath"):
    if os.access(os.path.join(vim.eval("a:projectpath"),vim.eval("g:MP_ProjectFile")),os.F_OK):
        prjpath=vim.eval("a:projectpath")
elif get_myproject_path():
        prjpath=get_myproject_path()
if prjpath:
    if vim.eval("g:MP_Session_AutoLoad")=='1' and vim.eval("g:MP_Session_Enable")=='1' and vim.eval("g:MP_Session_Loaded")=='0':
        if os.access(os.path.join(prjpath,vim.eval("g:MP_SessionFile")),os.F_OK):
            vim.command("source " + os.path.join(prjpath,vim.eval("g:MP_SessionFile")))
            vim.command("let g:MP_Session_Loaded=1")
    vim.command("let g:MP_Cur_Prj='" + prjpath + "'")
    vim.command("source " + os.path.join(prjpath,vim.eval("g:MP_ProjectFile")))
    prjtags=os.path.join(prjpath,'tags')
    prjcscope=os.path.join(prjpath,'cscope.out')
    prjncscope=os.path.join(prjpath,'ncscope.out')
    if vim.eval("g:MP_Ctags_Enable")=='1':
        if os.access(prjtags,os.F_OK):
            vim.command("set tags+=" + prjtags)
    if vim.eval("g:MP_Cscope_Enable")=='1':
        if vim.eval("cscope_connection(1,'ncscope.out')")=='0' and os.access(prjncscope,os.F_OK):
            vim.command("cs add " + prjncscope)
        elif vim.eval("cscope_connection(1,'cscope.out')")=='0' and os.access(prjcscope,os.F_OK):
            vim.command("cs add " + prjcscope)
EOA
endfunction

" 建立项目tags
function! <SID>MyProject_Build_Tags()
python << EOA
if vim.eval('g:MP_Cur_Prj'):
    prjpath=vim.eval("g:MP_Cur_Prj")
elif get_myproject_path():
    prjpath=get_myproject_path()
if os.access(prjpath,os.F_OK):
    opath=os.getcwd()
    os.chdir(prjpath)
    if vim.eval("g:MP_Ctags_Enable") == '1':
        os.popen(vim.eval("g:MP_Ctags_Path") + ' -f ' + os.path.join(prjpath,'tags') + vim.eval("g:MP_Ctags_Opt") + ' -R .')
    if vim.eval("g:MP_Cscope_Enable") == '1':
        extstr=vim.eval("g:MP_Source_File_Ext_Name")
        extlist=extstr.split(',')
        fstr=''
        if vim.eval("(has('win32') || has('win64'))")=='1':
            for i in extlist:
                fstr=fstr + ' *.' + i + ' '
            dirstr='dir /s /b ' + fstr + ' > cscope.files'
            os.popen(dirstr)
        else:
            ffirst = True
            for i in extlist:
                if ffirst:
                    fstr=' -name ' + '"*.' + i + '" '
                    ffirst = False
                else:
                    fstr=fstr + ' -or -name ' + '"*.' + i + '" '
            findstr='find . -type f -and \( ' + fstr + ' \) > cscope.files'
            os.popen(findstr)
        os.popen(vim.eval("g:MP_Cscope_Path") + ' -b')
    os.chdir(opath)
EOA
endfunction

" 更新项目tags
function! <SID>MyProject_Update_Tags()
if g:MP_Update_Enable != 1
    return
endif
let l:curbufpath=expand('%:p')
python << EOA
if vim.eval("g:MP_Cur_Prj"):
    prjpath=vim.eval("g:MP_Cur_Prj")
elif get_myproject_path():
    prjpath=get_myproject_path()
if os.access(prjpath,os.F_OK):
    opath=os.getcwd()
    os.chdir(prjpath)
    if vim.eval("g:MP_Ctags_Enable")=='1':
        os.popen(vim.eval("g:MP_Ctags_Path") + ' ' + vim.eval("g:MP_Ctags_Opt") + ' -a -f ' + os.path.join(prjpath,'tags') + ' ' + vim.eval("l:curbufpath"))
    if vim.eval("g:MP_Cscope_Enable")=='1':
        os.popen(vim.eval("g:MP_Cscope_Path") + " -b")
    os.chdir(opath)
EOA
endfunction

" 在项目中搜索
function! <SID>MyProject_Search_In_Project(...)
if !isdirectory(g:MP_Cur_Prj)
    return
endif
if a:0 > 0
    let search_pattern = a:000[0]
else
    let temp_input = input("要查找的字符串: ")
    if strlen(temp_input) < 1
        return
    else
        let search_pattern = temp_input
    endif
endif
if executable(g:MP_Grep_Path)
    let old_grepprg = &grepprg
    exe 'set grepprg=' . g:MP_Grep_Path
    exe ':grep -s -i -I -n -R ' . search_pattern . ' ' . g:MP_Cur_Prj
    let &grepprg = old_grepprg
else
    if a:0 > 1
        exe ':vimgrep ' . search_pattern . ' ' . join(map(split(a:000[1],','),'g:MP_Cur_Prj . "/**/*." . v:val'),' ')
    else
        exe ':vimgrep ' . search_pattern . ' ' . g:MP_Cur_Prj . '/**/*.*'
    endif
endif
endfunction

" 载入session
function! <SID>MyProject_LoadSession(sessionfile)
    if len(a:sessionfile)>0
        let mpsessionfile=g:MP_Cur_Prj . '/' . a:sessionfile
    else
        let mpsessionfile=g:MP_Cur_Prj . '/' . g:MP_SessionFile
    endif
    if filereadable(mpsessionfile)
        exe "source " . mpsessionfile
    endif
endfunction

" 保存session
function! <SID>MyProject_SaveSession(sessionfile)
    if !isdirectory(g:MP_Cur_Prj)
        return
    endif
    if len(a:sessionfile)>0
        let mpsessionfile=g:MP_Cur_Prj . '/' . a:sessionfile
    else
        let mpsessionfile=g:MP_Cur_Prj . '/' . g:MP_SessionFile
    endif
    if filereadable(mpsessionfile)
        let oldsessionopt=&sessionoptions
        let &sessionoptions=g:MP_Session_Opt
        exe "mksession! " . mpsessionfile
        let &sessionoptions=oldsessionopt
    endif
endfunction

" 设置vim的标题栏
if has("title")
    if g:MP_ConfigTitleBar_Enable == 1
        let &titlestring=g:MP_TitleString
    endif
endif
" 载入项目
command! -nargs=? -complete=file MPLoad call <SID>MyProject_Load(<q-args>)
" 更新项目tags
command! MPUpdateTags call <SID>MyProject_Update_Tags()
" 建立项目tags
command! MPBuildTags call <SID>MyProject_Build_Tags()
" 如果设置g:MP_Bufread_AutoLoad为1,则每次读取文件时自动载入所属项目的配置文件及tags
if g:MP_Bufread_AutoLoad == 1
    autocmd! Bufread * MPLoad
endif
" 如果设置g:MP_BufEnter_AutoLoad为1,则每次切换缓冲区时自动载入所属项目的配置文件及tags
if g:MP_BufEnter_AutoLoad == 1
    autocmd! BufEnter * MPLoad
endif
" 如果设置g:MP_Write_AutoUpdate为1，则每次保存文件时自动更新tags
if g:MP_Write_AutoUpdate == 1
    autocmd! BufWritePost * call <SID>MyProject_Update_Tags()
endif
" 如果设置g:MP_Session_AutoSave为1,则关闭vim时自动保存项目session
if g:MP_Session_AutoSave == 1 && g:MP_Session_Enable == 1
    autocmd! VimLeave * MPSaveSession
endif
" 如果安装了NERDTREE插件，则可以通过MPNERDTREE在NERDTree中打开项目
if !exists(":MPNERDTREE") && exists(":NERDTree")
    command! MPNERDTREE :exe 'NERDTree ' . g:MP_Cur_Prj
endif
" 在项目中搜索
command! -nargs=* -complete=tag MPSearchInProject call <SID>MyProject_Search_In_Project(<f-args>)
command! -nargs=? -complete=file MPSaveSession call <SID>MyProject_SaveSession(<q-args>)
command! -nargs=? -complete=file MPLoadSession call <SID>MyProject_LoadSession(<q-args>)

" vim: ts=4 fdm=marker foldcolumn=1 ft=vim
