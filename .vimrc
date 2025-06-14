" Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

let s:fancyterm = $TERM !~ '^vt'
let s:utf8_supported = $LANG =~ '[Uu][Tt][Ff]-\?8$'
let s:latin1_supported = $LANG =~ '[Ii][Ss][Oo]-\?8859-\?1$'

let s:indent = 4
set autoindent
set cinoptions=(1s
set expandtab
execute "set shiftwidth=" . s:indent
execute "set softtabstop=" . s:indent
execute "set tabstop=" . s:indent
if s:fancyterm
    set background=dark
endif
set number
set nowrap
set linebreak
set list
set noshowmatch
set colorcolumn=80
if s:fancyterm
    set t_Co=256
endif
set textwidth=79
set formatoptions=ql
set viminfo='100,<2000,s2000,h
set nojoinspaces
set laststatus=2
set hlsearch
if s:fancyterm
    set cursorline
endif
set wrapmargin=0
set comments-=://
set comments-=mb:*
set comments+=mb:\ *,:///,://!,://,:;
set matchpairs+=<:>
set modeline
if s:fancyterm
    set ttimeoutlen=0
endif
if s:latin1_supported
    set encoding=utf-8
    set termencoding=latin1
endif

filetype indent on
if s:fancyterm
    syntax on
    colorscheme bluegreen
endif

au FileType * call s:SetDefaultIndent()
if s:fancyterm
    au FileType * syntax sync fromstart
endif
au FileType markdown,text,gitcommit ResetIndent
au FileType make,lua TabMode
au FileType vim set comments+=:\"
au BufRead,BufNewFile *.h++ set filetype=cpp

function s:SetDefaultIndent()
    if &l:indentexpr == ""
        UseCIndent
    endif
endfunction

command ResetIndent set indentexpr=
command UseCIndent set indentexpr=s:GetCIndent()

nnoremap <Space> :noh<CR>
inoremap # <Space><Backspace>#
noremap YY :w! ~/.vimclip<CR>
noremap Yp :read ~/.vimclip<CR>
noremap YP O<Esc>:read ~/.vimclip<CR>kdd

" For monochrome displays
if s:fancyterm && $MONOCHROME != ""
    hi MatchParen ctermfg=none ctermbg=none cterm=underline
endif

if s:fancyterm
    " Highlight trailing space
    hi Ws ctermfg=243 cterm=none
    function s:HiTrailingWs()
        hi TrailingWs ctermfg=40 ctermbg=none cterm=reverse
    endfunction
    au InsertEnter * hi clear TrailingWs
    au InsertLeave * call s:HiTrailingWs()
    call s:HiTrailingWs()
    call matchadd("TrailingWs", '\s\+$', -1)
endif

au InsertEnter * execute "set listchars-=" . s:lc_normal
au InsertLeave * execute "set listchars+=" . s:lc_normal

" For files primarily indented with tabs
function s:TabMode()
    call s:ClearWsMode()
    set noexpandtab softtabstop=0
    if s:utf8_supported
        let spacechar="·"
    else
        let spacechar="`"
    endif
    let s:lc_normal = "trail:" . spacechar
    execute 'set listchars+=tab:\ \ ,lead:' . spacechar . "," . s:lc_normal
    if s:fancyterm
        call add(s:ws_ids, matchadd("Ws", '\(^\s*\)\@<= ', -2))
        call add(s:ws_ids, matchadd("Ws", ' \ze\s*$', -2))
        call add(s:ws_ids, matchadd("TrailingWs", '\(\S.*\)\@<=\t', -1))
    endif
endfunction
command TabMode call s:TabMode()

" For files primarily indented with spaces
function s:SpaceMode()
    call s:ClearWsMode()
    execute "set expandtab softtabstop=" . s:indent
    let s:lc_normal = ""
    if !s:utf8_supported
        let tabchars='\|-\|'
    elseif $HEAVY_BLOCKS != ""
        let tabchars="┣━┫"
    else
        let tabchars="├─┤"
    endif
    execute "set listchars+=tab:" . tabchars
    if s:fancyterm
        call add(s:ws_ids, matchadd("Ws", '\t', -2))
    endif
endfunction
command SpaceMode call s:SpaceMode()

let s:ws_ids = []
function s:ClearWsMode()
    set listchars=extends:$,precedes:$
    for id in s:ws_ids
        call matchdelete(id)
    endfor
    let s:ws_ids = []
endfunction
SpaceMode

function s:GetCIndent()
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
let g:python_indent.open_paren = s:indent
let g:python_indent.continue = s:indent
