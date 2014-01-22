" myproject.vim: 项目管理插件。有项目加载、管理等功能
" Author:       加州旅客
" Email:        jiazhoulvke@gmail.com
" Blog:         http://www.jiazhoulvke.com
" Date:         2012-06-25
" Update:       2014-01-22
" Version:      0.3
"------------------------------------------------

"------------------------------------------------
" Config: 配置选项 {{{1
"------------------------------------------------

if has('win32') || has('win64')
    let g:MP_Separator = '\'
else
    let g:MP_Separator = '/'
endif

" 项目文件名
if !exists('g:MP_ProjectFile')
    let g:MP_ProjectFile = 'project.vim'
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
    let g:MP_TitleString="%t\ %m%r\ [%{expand(\"%:~:.:h\")}]\ [ProjectPath=%{g:MP_Cur_Prj}]\ -\ %{v:servername}"
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
if !exists("g:MP_SessionFile")
    let g:MP_SessionFile = 'project.session.vim'
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

"------------------------------------------------
" Functions:  函数{{{1
"------------------------------------------------

" 载入项目
function! <SID>MyProject_Load(...)
    if a:0== 0
        let s:projectfilepath = findfile(g:MP_ProjectFile,'.;')
    else
        let s:projectfilepath = findfile(g:MP_ProjectFile,a:1.';')
    endif
    if s:projectfilepath == ''
        echo '未发现项目文件' . g:MP_ProjectFile
        return
    endif
    if s:projectfilepath == g:MP_ProjectFile
        let g:MP_Path = getcwd()
    else
        let g:MP_Path = strpart(s:projectfilepath, 0, strridx(s:projectfilepath, g:MP_Separator))
    endif
    " 载入项目配置
    exe 'so ' . s:projectfilepath
    unlet s:projectfilepath
    exe 'cd ' . g:MP_Path
    " 载入session
    if g:MP_Session_AutoSave == 1
        if filereadable(g:MP_Path . g:MP_Separator . g:MP_SessionFile)
            exe 'so ' . g:MP_Path . g:MP_Separator . g:MP_SessionFile
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
        unlet s:prjgtags
    " 载入cscope
    elseif g:MP_Cscope_Enable == 1
        let s:prjcscope = g:MP_Path . g:MP_Separator . 'cscope.out'
        let s:prjncscope = g:MP_Path . g:MP_Separator . 'ncscope.out'
        if cscope_connection(1,'ncscope.out') == 0 && filereadable(s:prjncscope)
            exe 'cs add ' . s:prjncscope
        elseif cscope_connection(1,'cscope.out') == 0 && filereadable(s:prjcscope)
            exe 'cs add ' . s:prjcscope
        endif
        unlet s:prjcscope
        unlet s:prjncscope
    endif
endfunction

" 建立项目tags
function! <SID>MyProject_Build_Tags()
    if !isdirectory(g:MP_Path)
        return
    endif
    let s:opath = getcwd()
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
    exe 'cd ' . s:opath
    unlet s:fstr
    unlet s:flist
    unlet s:extlist
    unlet s:opath
endfunction

" 更新项目tags
function! <SID>MyProject_Update_Tags()
    if !isdirectory(g:MP_Path)
        return
    endif
    let s:opath = getcwd()
    exe 'cd ' . g:MP_Path
    if g:MP_Ctags_Enable == 1
        exe '!' . g:MP_Ctags_Path . ' ' . g:MP_Ctags_Opt . ' -a -f ' . expand('%:p')
    endif
    if g:MP_Global_Enable == 1
        exe '!' . g:MP_Global_Path . ' -u'
    elseif g:MP_Cscope_Enable == 1
        exe '!' . g:MP_Cscope_Path . ' -b'
    endif
    exe 'cd ' . s:opath
    unlet s:opath
endfunction

" 保存session
function! <SID>MyProject_SaveSession(...)
    if !isdirectory(g:MP_Path)
        return
    endif
    if a:0 == 0
        let s:mpsessionfile = g:MP_Path . g:MP_Separator . g:MP_SessionFile
    else
        let s:mpsessionfile = g:MP_Path . g:MP_Separator . a:1 . '.session.vim'
    endif
    let s:oldsessionopt = &sessionoptions
    let &sessionoptions = g:MP_Session_Opt
    exe "mksession! " . s:mpsessionfile
    let &sessionoptions = s:oldsessionopt
endfunction

" 载入session
function! <SID>MyProject_LoadSession(...)
    if !isdirectory(g:MP_Path)
        return
    endif
    if a:0 == 0
        let s:mpsessionfile = g:MP_Path . g:MP_Separator . g:MP_SessionFile
    else
        let s:mpsessionfile = g:MP_Path . g:MP_Separator . a:1 . '.session.vim'
    endif
    if filereadable(s:mpsessionfile)
        exe 'so ' . s:mpsessionfile
    endif
endfunction

"------------------------------------------------
" Autocmd:  自动命令{{{1
"------------------------------------------------

" 读入文件时自动载入项目
if g:MP_Bufread_AutoLoad == 1
    autocmd! Bufread * MPLoad
endif

" 保存时自动更新tags
if g:MP_Write_AutoUpdate == 1
    autocmd! BufWritePost * call <SID>MyProject_Update_Tags()
endif

" 关闭vim时自动保存项目的session
if g:MP_Session_AutoSave == 1
endif

"------------------------------------------------
" Command:  命令{{{1
"------------------------------------------------

" 载入项目
command! -nargs=? -complete=dir MPLoad call <SID>MyProject_Load(<q-args>)

" 建立Tags
command! MPBuildTags call <SID>MyProject_Build_Tags()

" 更新Tags
command! MPUpdateTags call <SID>MyProject_Update_Tags()

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
