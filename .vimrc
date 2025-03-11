" Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

let fancyterm = $TERM !~ '^vt'
let utf8_supported = $LANG =~ '[Uu][Tt][Ff]-\?8$'
let latin1_supported = $LANG =~ '[Ii][Ss][Oo]-\?8859-\?1$'

let indent = 4
set autoindent
set cinoptions=(1s
set expandtab
execute "set shiftwidth=" . indent
execute "set softtabstop=" . indent
execute "set tabstop=" . indent
if fancyterm
    set background=dark
endif
set number
set nowrap
set linebreak
set list
set noshowmatch
set colorcolumn=80
if fancyterm
    set t_Co=256
endif
set textwidth=79
set formatoptions=ql
set viminfo='100,<2000,s2000,h
set nojoinspaces
set laststatus=2
set hlsearch
if fancyterm
    set cursorline
endif
set wrapmargin=0
set comments-=://
set comments-=mb:*
set comments+=mb:\ *,:///,://!,://,:;
set matchpairs+=<:>
set modeline
if fancyterm
    set ttimeoutlen=0
endif
if latin1_supported
    set encoding=utf-8
    set termencoding=latin1
endif

filetype indent on
if fancyterm
    syntax on
    colorscheme bluegreen
endif

au FileType * call SetDefaultIndent()
if fancyterm
    au FileType * syntax sync fromstart
endif
au FileType markdown,text,gitcommit ResetIndent
au FileType make,lua TabMode
au FileType vim set comments+=:\"
au BufRead,BufNewFile *.h++ set filetype=cpp

function SetDefaultIndent()
    if &l:indentexpr == ""
        UseCIndent
    endif
endfunction

command ResetIndent set indentexpr=
command UseCIndent set indentexpr=GetCIndent()

nnoremap <Space> :noh<CR>
inoremap # <Space><Backspace>#
noremap YY :w! ~/.vimclip<CR>
noremap Yp :read ~/.vimclip<CR>
noremap YP O<Esc>:read ~/.vimclip<CR>kdd

" For monochrome displays
if fancyterm && $MONOCHROME != ""
    hi MatchParen ctermfg=none ctermbg=none cterm=underline
endif

if fancyterm
    " Highlight trailing space
    hi Ws ctermfg=243 cterm=none
    function HiTrailingWs()
        hi TrailingWs ctermfg=40 ctermbg=none cterm=reverse
    endfunction
    au InsertEnter * hi clear TrailingWs
    au InsertLeave * call HiTrailingWs()
    call HiTrailingWs()
    call matchadd("TrailingWs", '\s\+$', -1)
endif

au InsertEnter * execute "set listchars-=" . lc_normal
au InsertLeave * execute "set listchars+=" . lc_normal

" For files primarily indented with tabs
function TabMode()
    call ClearWsMode()
    set noexpandtab softtabstop=0
    if g:utf8_supported
        let spacechar="·"
    else
        let spacechar="`"
    endif
    let g:lc_normal = "trail:" . spacechar
    execute 'set listchars+=tab:\ \ ,lead:' . spacechar . "," . g:lc_normal
    if g:fancyterm
        call add(g:ws_ids, matchadd("Ws", '\(^\s*\)\@<= ', -2))
        call add(g:ws_ids, matchadd("Ws", ' \ze\s*$', -2))
        call add(g:ws_ids, matchadd("TrailingWs", '\(\S.*\)\@<=\t', -1))
    endif
endfunction
command TabMode call TabMode()

" For files primarily indented with spaces
function SpaceMode()
    call ClearWsMode()
    execute "set expandtab softtabstop=" . g:indent
    let g:lc_normal = ""
    if !g:utf8_supported
        let tabchars='\|-\|'
    elseif $HEAVY_BLOCKS != ""
        let tabchars="┣━┫"
    else
        let tabchars="├─┤"
    endif
    execute "set listchars+=tab:" . tabchars
    if g:fancyterm
        call add(g:ws_ids, matchadd("Ws", '\t', -2))
    endif
endfunction
command SpaceMode call SpaceMode()

let g:ws_ids = []
function ClearWsMode()
    set listchars=extends:$,precedes:$
    for id in g:ws_ids
        call matchdelete(id)
    endfor
    let g:ws_ids = []
endfunction
SpaceMode

function GetCIndent()
    let l1 = prevnonblank(v:lnum - 1)
    if l1 == 0
        return 0
    endif
    let l2 = prevnonblank(l1 - 1)
    if getline(l1) !~ '\\$'
        return cindent(v:lnum)
    endif
    if getline(l2) =~ '\\$'
        return indent(l1)
    endif
    return indent(l1) + &shiftwidth
endfunction

let g:python_indent = {}
let g:python_indent.open_paren = g:indent
let g:python_indent.continue = g:indent
