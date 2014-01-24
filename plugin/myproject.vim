" myproject.vim: 项目管理插件。有项目管理、Session管理、tags管理等功能
" Author:       加州旅客
" Email:        jiazhoulvke@gmail.com
" Blog:         http://www.jiazhoulvke.com
" Date:         2012-06-25
" Update:       2014-01-22
" Version:      0.3
"------------------------------------------------

"if exists('g:MP_Loaded')
"    finish
"endif
"let g:MP_Loaded = 1

"------------------------------------------------
" Config: 配置选项 {{{1
"------------------------------------------------

if has('win32') || has('win64')
    let g:MP_Separator = '\'
else
    let g:MP_Separator = '/'
endif

" 项目列表文件
if !exists('g:MP_ProjectList')
    let g:MP_ProjectList = globpath($HOME, '.MP_ProjectList.vim')
endif

" 项目文件名
if !exists('g:MP_ProjectFile')
    let g:MP_ProjectFile = 'project.vim'
endif

" 项目列表高度
if !exists('g:MP_Window_Height')
    let g:MP_Window_Height = '10'
endif

" 选择项目后是否自动关闭项目列表
if !exists('g:MP_Auto_Close')
    let g:MP_Auto_Close = 1
endif

" 是否启用ctags
if !exists('g:MP_Ctags_Enable')
    let g:MP_Ctags_Enable = 0
endif

" 定义ctags的路径
if !exists('g:MP_Ctags_Path')
    let g:MP_Ctags_Path = 'ctags'
endif

" 定义ctags参数
if !exists('g:MP_Ctags_Opt')
    let g:MP_Ctags_Opt = ''
endif

" 是否启用GNU global
if !exists('g:MP_Global_Enable')
    let g:MP_Global_Enable = 0
endif

" 定义GNU Global的路径
if !exists('g:MP_Global_Path')
    let g:MP_Global_Path = 'global'
endif

" 定义gtags的路径
if !exists('g:MP_Gtags_Path')
    let g:MP_Gtags_Path = 'gtags'
endif

" 是否启用cscope
if !exists('g:MP_Cscope_Enable')
    let g:MP_Cscope_Enable = 0
endif

" 定义cscope的路径
if !exists('g:MP_Cscope_Path')
    let g:MP_Cscope_Path = 'cscope'
endif

" 需要建立tags的文件后缀名,如:'c,h,cpp'
if !exists('g:MP_Source_File_Ext_Name')
    let g:MP_Source_File_Ext_Name = ''
endif

" 是否允许设置标题栏
if !exists('g:MP_ConfigTitleBar_Enable')
    let g:MP_ConfigTitleBar_Enable = 0
endif

" 标题栏字符串
if !exists('g:MP_TitleString')
    let g:MP_TitleString="%t\ %m%r\ [%{expand(\"%:~:.:h\")}]\ [ProjectPath=%{g:MP_Path}]\ -\ %{v:servername}"
endif

" 是否自动保存项目session
if !exists("g:MP_Session_AutoSave")
    let g:MP_Session_AutoSave = 0
endif

" 是否自动加载项目session
if !exists("g:MP_Session_AutoLoad")
    let g:MP_Session_AutoLoad = 0
endif

" 项目默认session文件名
if !exists("g:MP_DefaultSessionName")
    let g:MP_DefaultSessionName = 'default'
endif

" Session选项
if !exists("g:MP_Session_Opt")
    let g:MP_Session_Opt = "blank,buffers,curdir,folds,globals,options,resize,tabpages,winpos,winsize"
endif

" 项目路径
if !exists('g:MP_Path')
    let g:MP_Path = ''
endif

" 在文件写入时是否自动更新tags
if !exists('g:MP_Write_AutoUpdate')
    let g:MP_Write_AutoUpdate = 0
endif

" 读入文件时是否自动载入项目文件
if !exists('g:MP_Bufread_AutoLoad')
    let g:MP_Bufread_AutoLoad = 0
endif

let s:bname = '__MyProject_List__'

"------------------------------------------------
" Functions:  函数{{{1
"------------------------------------------------

" 创建项目 {{{2
function! <SID>MyProject_CreateProject()
    let newproject = {}
    let newproject['path'] = input("输入项目路径: ", '', 'dir')
    if !isdirectory(newproject['path'])
        let c = inputlist(["\n" . newproject['path'] . '不存在，需要创建吗?',"1.Yes","2.No"])
        echo "\n"
        if c == 1
            let r = mkdir(newproject['path'])
        else
            return
        endif
    endif
    let newproject['name'] = input("输入项目名称: ")
    echo "\n"
    let projectfile = newproject['path'] . g:MP_Separator . g:MP_ProjectFile
    let l = []
    call add(l,'" 项目名称: ' . newproject['name'])
    if writefile(l, projectfile) != 0
        echo '创建项目文件失败'
        return
    endif
    if filereadable(g:MP_ProjectList)
        let projectlist = readfile(g:MP_ProjectList)
        call add(projectlist, string(newproject))
    else
        let projectlist = [string(newproject)]
    endif
    if writefile(projectlist, g:MP_ProjectList) == 0
        echo "项目创建成功!\n"
        echo "项目名称: " . newproject['name'] . "\n"
        echo "项目路径: " . newproject['path'] . "\n"
    else
        echo "项目创建失败"
    endif
endfunction

" 载入项目 {{{2
function! <SID>MyProject_Load(...)
    if a:1 == ''
        let s:projectfilepath = findfile(g:MP_ProjectFile,'.;')
    else
        if isdirectory(a:1)
            let path = a:1
        else
            let path = strpart(a:1, 0, strridx(a:1, g:MP_Separator))
            if !isdirectory(path)
                return
            endif
        endif
        let s:projectfilepath = findfile(g:MP_ProjectFile,path.';')
    endif
    if s:projectfilepath == ''
        return
    endif
    if s:projectfilepath == g:MP_ProjectFile
        let g:MP_Path = getcwd()
    else
        let g:MP_Path = strpart(s:projectfilepath, 0, strridx(s:projectfilepath, g:MP_Separator))
        " 用findfile获取的路径有时是相对路径,所以要做一下处理
        exe 'cd ' . g:MP_Path
        let g:MP_Path = getcwd()
        let s:projectfilepath = g:MP_Path . g:MP_Separator . g:MP_ProjectFile
    endif
    " 载入项目配置
    exe 'so ' . s:projectfilepath
    exe 'cd ' . g:MP_Path
    " 载入session
    if g:MP_Session_AutoLoad == 1
        if filereadable(g:MP_Path . g:MP_Separator . g:MP_DefaultSessionName . '.session.vim')
            exe 'so ' . g:MP_Path . g:MP_Separator . g:MP_DefaultSessionName . '.session.vim'
        endif
    endif
    " 载入ctags
    if g:MP_Ctags_Enable == 1
        exe 'set tags+=' . g:MP_Path . g:MP_Separator . 'tags'
    endif
    " 载入global
    if g:MP_Global_Enable == 1
        let s:prjgtags = g:MP_Path . g:MP_Separator . 'GTAGS'
        if filereadable(s:prjgtags)
            exe 'cs add ' . s:prjgtags
        endif
    " 载入cscope
    elseif g:MP_Cscope_Enable == 1
        let s:prjcscope = g:MP_Path . g:MP_Separator . 'cscope.out'
        let s:prjncscope = g:MP_Path . g:MP_Separator . 'ncscope.out'
        if cscope_connection(1,'ncscope.out') == 0 && filereadable(s:prjncscope)
            exe 'cs add ' . s:prjncscope
        elseif cscope_connection(1,'cscope.out') == 0 && filereadable(s:prjcscope)
            exe 'cs add ' . s:prjcscope
        endif
    endif
endfunction

" 项目列表 {{{2
function! <SID>MyProject_List()
    if !filereadable(g:MP_ProjectList)
        return
    endif
    let tlist = readfile(g:MP_ProjectList)
    let s:projectlist = []
    let showlist = []
    for line in tlist
        let p = eval(line)
        call add(s:projectlist, p)
        call add(showlist, printf("[%s] %s", p['name'], p['path']))
    endfor
    let winnum = bufwinnr(s:bname)
    if winnum != -1
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
        setlocal modifiable
        silent! %delete _
    else
        let bufnum = bufnr(s:bname)
        if bufnum == -1
            let wcmd = s:bname
        else
            let wcmd = '+buffer' . bufnum
        endif
        exe 'silent! botright ' . g:MP_Window_Height . 'split ' . wcmd
    endif
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nowrap
    setlocal nobuflisted
    setlocal winfixheight
    setlocal modifiable
    silent! %delete _
    call setline(1, showlist)
    normal! gg
    setlocal nomodifiable
    call <SID>MyProject_Key_Map()
endfunction

" 按键绑定 {{{2
function! <SID>MyProject_Key_Map()
    nmap <buffer> <CR> :call <SID>MyProject_Project_Load()<CR>
    nmap <buffer> q :close<CR>
    nmap <buffer> d :call <SID>MyProject_Project_Delete()<CR>
    nmap <buffer> <ESC> :close<CR>
    nmap <buffer> c :MPCreate<CR>
endfunction

" 通过项目列表载入项目 {{{2
function! <SID>MyProject_Project_Load()
    let ln = line('.')
    let project = s:projectlist[ln-1]
    call <SID>MyProject_Load(project['path'])
    if g:MP_Auto_Close == 1
        exe ':close'
    endif
endfunction

" 从项目列表中删除项目 {{{2
function! <SID>MyProject_Project_Delete()
    let ln = line('.')
    let c = inputlist(["确定要删除此项目吗?","1.Yes","2.No"])
    echo "\n"
    if c != 1
        return
    endif
    call remove(s:projectlist, ln-1)
    setlocal modifiable
    normal! dd
    setlocal nomodifiable
    let tlist = []
    for p in s:projectlist
        call add(tlist, string(p))
    endfor
    call writefile(tlist, g:MP_ProjectList)
endfunction

" MPLoad命令补全函数 {{{2
function! <SID>MyProject_MPLoad_Complete(A,L,P)
    if !filereadable(g:MP_ProjectList)
        return
    endif
    let tlist = readfile(g:MP_ProjectList)
    let resultlist = []
    for line in tlist
        let p = eval(line)
        call add(resultlist, p['path'])
    endfor
    return resultlist
endfunction

" MPSessionLoad和MPSessionSave命令补全函数 {{{2
function! <SID>MyProject_Session_Complete(A,L,P)
    if !isdirectory(g:MP_Path)
        return
    endif
    let opath = getcwd()
    exe 'cd ' . g:MP_Path
    let sessions = glob('*.session.vim')
    let sessions = substitute(sessions, '.session.vim', '', 'g')
    let sessionlist = split(sessions, "\n")
    exe 'cd ' . opath
    return sessionlist
endfunction

" 建立项目tags {{{2
function! <SID>MyProject_Build_Tags()
    if !isdirectory(g:MP_Path)
        return
    endif
    let opath = getcwd()
    exe 'cd ' . g:MP_Path
    if g:MP_Ctags_Enable == 1
        echo '开始生成tags'
        exe '!' . g:MP_Ctags_Path . ' -f ' . g:MP_Path . g:MP_Separator . 'tags' . g:MP_Ctags_Opt . ' -R . '
    endif
    if strlen(g:MP_Source_File_Ext_Name) > 0
        let s:extlist = split(g:MP_Source_File_Ext_Name, ',')
        let s:fstr = ''
        if has('win32') || has('win64')
            for s:ext in s:extlist
                let s:fstr = s:fstr . ' *.' . s:ext . ' '
            endfor
            if g:MP_Global_Enable == 1
                exe '!dir /s /b ' . s:fstr . ' > gtags.files'
            elseif g:MP_Cscope_Enable ==1
                exe '!dir /s /b ' . s:fstr . ' > cscope.files'
            endif
        else
            let s:flist = []
            for s:ext in s:extlist
                call add(s:flist, ' -name "*.' . s:ext . '" ')
            endfor
            if g:MP_Global_Enable == 1
                exe '!find . -type f -and \(' . join(s:flist, ' -or ') . '\) > gtags.files'
            elseif g:MP_Cscope_Enable ==1
                exe '!find . -type f -and \(' . join(s:flist, ' -or ') . '\) > cscope.files'
            endif
        endif
    endif
    if g:MP_Global_Enable == 1
        exe '!' . g:MP_Gtags_Path
    elseif g:MP_Cscope_Enable == 1
        exe '!' . g:MP_Cscope_Path . ' -b'
    endif
    exe 'cd ' . opath
endfunction

" 更新项目tags {{{2
function! <SID>MyProject_Update_Tags()
    if !isdirectory(g:MP_Path)
        return
    endif
    let opath = getcwd()
    exe 'cd ' . g:MP_Path
    if g:MP_Ctags_Enable == 1
        exe '!' . g:MP_Ctags_Path . ' ' . g:MP_Ctags_Opt . ' -a -f ' . expand('%:p')
    endif
    if g:MP_Global_Enable == 1
        exe '!' . g:MP_Global_Path . ' -u'
    elseif g:MP_Cscope_Enable == 1
        exe '!' . g:MP_Cscope_Path . ' -b'
    endif
    exe 'cd ' . opath
endfunction

" 保存session {{{2
function! <SID>MyProject_SessionSave(...)
    if !isdirectory(g:MP_Path)
        return
    endif
    if a:1 == ''
        let s:mpsessionfile = g:MP_Path . g:MP_Separator . g:MP_DefaultSessionName . '.session.vim'
    else
        let s:mpsessionfile = g:MP_Path . g:MP_Separator . a:1 . '.session.vim'
    endif
    let s:oldsessionopt = &sessionoptions
    let &sessionoptions = g:MP_Session_Opt
    exe "mksession! " . s:mpsessionfile
    let &sessionoptions = s:oldsessionopt
endfunction

" 载入session {{{2
function! <SID>MyProject_SessionLoad(...)
    if !isdirectory(g:MP_Path)
        return
    endif
    if a:1 == ''
        let s:mpsessionfile = g:MP_Path . g:MP_Separator . g:MP_DefaultSessionName . '.session.vim'
    else
        let s:mpsessionfile = g:MP_Path . g:MP_Separator . a:1 . '.session.vim'
    endif
    if filereadable(s:mpsessionfile)
        exe 'so ' . s:mpsessionfile
    endif
endfunction

" 读入文件时自动载入项目
function! <SID>MyProject_Project_AutoLoad()
    let path = expand('%:p:h')
    call <SID>MyProject_Load(path)
endfunction

" 自动保存session {{{2
function! <SID>MyProject_Session_AutoSave()
    if g:MP_Session_AutoSave == 1
        call <SID>MyProject_SessionSave('')
    endif
endfunction

" 保存时自动更新tags
function! <SID>MyProject_Auto_Update_Tags()
    if g:MP_Write_AutoUpdate == 1
        call <SID>MyProject_Update_Tags()
    endif
endfunction

"------------------------------------------------
" Autocmd:  自动命令{{{1
"------------------------------------------------

" 读入文件时自动载入项目
if g:MP_Bufread_AutoLoad == 1
    autocmd! Bufread * call <SID>MyProject_Project_AutoLoad()
endif

" 保存时自动更新tags
autocmd! BufWritePost * call <SID>MyProject_Auto_Update_Tags()

" 关闭vim时自动保存项目的session
autocmd! VimLeave * call <SID>MyProject_Session_AutoSave()

"------------------------------------------------
" Command:  命令{{{1
"------------------------------------------------

" 创建项目
command! MPCreate call <SID>MyProject_CreateProject()

" 项目列表
command! MPProjectList call <SID>MyProject_List()

" 载入项目
command! -nargs=? -complete=customlist,<SID>MyProject_MPLoad_Complete MPLoad call <SID>MyProject_Load(<q-args>)

" 建立Tags
command! MPBuildTags call <SID>MyProject_Build_Tags()

" 更新Tags
command! MPUpdateTags call <SID>MyProject_Update_Tags()

" 保存Session
command! -nargs=? -complete=customlist,<SID>MyProject_Session_Complete MPSessionSave call <SID>MyProject_SessionSave(<q-args>)

" 载入Session
command! -nargs=? -complete=customlist,<SID>MyProject_Session_Complete MPSessionLoad call <SID>MyProject_SessionLoad(<q-args>)


"------------------------------------------------
" Other:  其他{{{1
"------------------------------------------------

"设置vim的标题栏
if has('title')
    if g:MP_ConfigTitleBar_Enable == 1
        let g:oldtitlstring = &titlestring
        let &titlestring = g:MP_TitleString
    endif
endif

" vim: ts=4 wrap fdm=marker foldcolumn=1 filetype=vim
