if exists('g:MP_After_Loaded')
    finish
endif
let g:MP_After_Loaded = 1

" 如果安装了NERDTree插件，则可以通过NERDTree打开项目
if exists(':NERDTree') && !exists(':MPNERDTree')
    command! MPNERDTree :exe 'NERDTree ' . g:MP_Path
endif
