" Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
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
set expandtab
set number
set nowrap
set linebreak
set list
set noshowmatch
set formatoptions=ql
set viminfo='100,<2000,s2000,h
set nojoinspaces
set laststatus=2
set hlsearch
set wrapmargin=0
set comments-=://
set comments-=mb:*
set comments+=mb:\ *,:///,://!,://,:;
set matchpairs+=<:>
set modeline
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

filetype indent on
if g:fancyterm
    syntax on
    colorscheme bluegreen
endif

if g:fancyterm
    au FileType * syntax sync fromstart
endif
au FileType vim set comments+=:\"
au BufRead,BufNewFile *.h++ set filetype=cpp

nnoremap <Space> :noh\|echo<CR>
inoremap # <Space><Backspace>#
vnoremap YY :w! ~/.vimclip<CR>
vnoremap Yd :w! ~/.vimclip<CR>gvd
nnoremap Yp :read ~/.vimclip<CR>
nnoremap YP :execute (line(".") - 1) . "read ~/.vimclip"<CR>

" For monochrome displays
if g:fancyterm && $MONOCHROME != ""
    hi MatchParen ctermfg=none ctermbg=none cterm=underline
endif

" Whitespace/indent configuration
so ~/.vim/ws.vim

" Better % behavior
packadd! matchit
