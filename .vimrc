" Copyright (C) 2023-2024 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

let g:indent = 4
set autoindent
set cinoptions=(1s
set expandtab
execute "set shiftwidth=" . g:indent
execute "set softtabstop=" . g:indent
execute "set tabstop=" . g:indent
set background=dark
set number
set nowrap
set linebreak
set list
set noshowmatch
set colorcolumn=80
set t_Co=256
set textwidth=79
set formatoptions=ql
set viminfo='100,<2000,s2000,h
set nojoinspaces
set laststatus=2
set hlsearch
set cursorline
set wrapmargin=0
set comments-=://
set comments-=mb:*
set comments+=mb:\ *,:///,://!,://,:;
set matchpairs+=<:>
set modeline
set ttimeoutlen=0

filetype indent on
syntax on
colorscheme bluegreen

au FileType * call SetDefaultIndent()
au FileType markdown,text,gitcommit set indentexpr=
au FileType make,lua TabMode
au FileType vim set comments+=:\"
au FileType m4 call SetM4Options()
au BufRead,BufNewFile *.h++ set filetype=cpp

function SetDefaultIndent()
    if &l:indentexpr == ""
        set indentexpr=GetCIndent()
    endif
endfunction

function SetM4Options()
    set matchpairs+=`:'
    set cpoptions+=%M
    syn clear m4String
    syn region m4Str start="`" end="'" contains=m4Constants,m4Special,
        \ m4Variable,m4Paren,m4Command,m4Statement,m4Function
    syn cluster m4Top add=m4Str |
    hi def link m4Str String
endfunction

nnoremap <Space> :noh<CR>
inoremap # <Space><Backspace>#
noremap YY :w! ~/.vimclip<CR>
noremap Yp :read ~/.vimclip<CR>
noremap YP O<Esc>:read ~/.vimclip<CR>kdd

" For monochrome displays
if $MONOCHROME != ""
    hi MatchParen ctermfg=none ctermbg=none cterm=underline
endif

" Highlight trailing space
hi Ws ctermfg=243 cterm=none
function HiTrailingWs()
    hi TrailingWs ctermfg=40 ctermbg=none cterm=reverse
endfunction
au InsertEnter * hi clear TrailingWs
au InsertLeave * call HiTrailingWs()
call HiTrailingWs()
call matchadd("TrailingWs", "\\s\\+$", -1)

au InsertEnter * execute "set listchars-=" . lc_normal
au InsertLeave * execute "set listchars+=" . lc_normal

" For files primarily indented with tabs
function TabMode()
    call ClearWsMode()
    set noexpandtab softtabstop=0
    let g:lc_normal = "trail:·"
    execute "set listchars+=tab:\\ \\ ,lead:·," . g:lc_normal
    call add(g:ws_ids, matchadd("Ws", "\\(^\\s*\\)\\@<= ", -2))
    call add(g:ws_ids, matchadd("Ws", " \\ze\\s*$", -2))
    call add(g:ws_ids, matchadd("TrailingWs", "\\(\\S.*\\)\\@<=\\t", -1))
endfunction
command TabMode call TabMode()

" For files primarily indented with spaces
function SpaceMode()
    call ClearWsMode()
    execute "set expandtab softtabstop=" . g:indent
    let g:lc_normal = ""
    if $HEAVY_BLOCKS != ""
        set listchars+=tab:┣━┫
    else
        set listchars+=tab:├─┤
    endif
    call add(g:ws_ids, matchadd("Ws", "\\t", -2))
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
