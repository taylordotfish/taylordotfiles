" Copyright (C) 2023-2026 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

let g:fancyterm = $TERM !~ '^vt'
if $LANG =~? 'UTF-\?8$'
    let g:term_encoding = "utf8"
elseif $LANG =~? 'ISO-\?8859-\?1$'
    let g:term_encoding = "latin1"
else
    let g:term_encoding = "unknown"
endif

set autoindent
set cinoptions=(1s
set textwidth=79
set colorcolumn=+1
set shiftwidth=4
let &tabstop=&shiftwidth
set softtabstop=-1
set expandtab
set number
set nowrap
set linebreak
set noshowmatch
set formatoptions=ql
set viminfo='100,<2000,s2000,h
set nojoinspaces
set laststatus=2
set hlsearch
set comments-=://
set comments-=mb:*
set comments+=mb:\ *,:///,://!,://,:;
set matchpairs+=<:>
set modeline
set cinkeys-=0#
set indentkeys-=0#

if g:fancyterm
    set background=dark
    set t_Co=256
    set cursorline
    set ttimeoutlen=0
endif
if g:term_encoding == "latin1"
    set encoding=utf-8
    set termencoding=latin1
endif

let g:rust_edition = "latest"
"let g:rust_highlight_doc_code = 0
filetype indent on
if g:fancyterm
    syntax on
    colorscheme bluegreen
    au FileType * syntax sync fromstart
endif

au FileType vim setlocal comments+=:\" indentkeys-=0\\ indentkeys-==}
au BufRead,BufNewFile *.h++ set filetype=cpp
au FileType make,lua let g:ws_config.mode = "tab"
au FileType markdown,text,gitcommit let g:ws_config.ft_indent = 0
au FileType gitcommit setlocal textwidth=72
let g:python_indent = #{open_paren: &shiftwidth, continue: &shiftwidth}

nnoremap <Space> :noh\|echo<CR>
vnoremap YY :w! ~/.vimclip<CR>
vnoremap Yd :w! ~/.vimclip<CR>gvd
nnoremap Yp :read ~/.vimclip<CR>
nnoremap YP :execute (line(".") - 1) . "read ~/.vimclip"<CR>

" For monochrome displays
if g:fancyterm && $MONOCHROME != ""
    hi MatchParen ctermfg=none ctermbg=none cterm=underline
endif
so ~/.vim/ws.vim  " Whitespace/indent configuration
packadd! matchit  " Better % behavior
