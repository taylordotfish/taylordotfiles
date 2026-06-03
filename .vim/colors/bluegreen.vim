" Copyright (C) 2023, 2024, 2026 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

set background=dark
hi clear
let g:colors_name = "bluegreen"

" Describes the transparency of black and dark gray colors in the terminal.
" Possible values:
" - "none": Black and dark gray colors are fully opaque.
" - "full": Black and dark gray colors have approximately 75% opacity.
" - "background": Black and dark gray colors have approximately 75% opacity
"   when used as a background color only. When used as a foreground color, they
"   have full opacity.
let s:transparency = get(g:, "bluegreen_transparency", "none")

hi MoreMsg      ctermfg=84   ctermbg=none cterm=none
hi Question     ctermfg=84   ctermbg=none cterm=none
hi Visual       ctermfg=15   ctermbg=30   cterm=none
hi Identifier   ctermfg=74   ctermbg=none cterm=none
hi PreProc      ctermfg=74   ctermbg=none cterm=none
hi Special      ctermfg=74   ctermbg=none cterm=none
hi Title        ctermfg=74   ctermbg=none cterm=none
hi Comment      ctermfg=245  ctermbg=none cterm=none
hi Constant     ctermfg=73   ctermbg=none cterm=none
hi LineNr       ctermfg=241  ctermbg=none cterm=none
hi CursorLine   ctermfg=none ctermbg=none cterm=none
hi CursorLineNr ctermfg=74   ctermbg=none cterm=none
hi Statement    ctermfg=43   ctermbg=none cterm=none
hi Type         ctermfg=41   ctermbg=none cterm=none
hi Underlined   ctermfg=none ctermbg=none cterm=underline
hi ModeMsg      ctermfg=73   ctermbg=none cterm=none
hi WarningMsg   ctermfg=214  ctermbg=none cterm=none
hi ErrorMsg     ctermfg=203  ctermbg=none cterm=none
hi Error        ctermfg=203  ctermbg=none cterm=none
hi SpecialKey   ctermfg=43   ctermbg=none cterm=none
hi MatchParen   ctermfg=none ctermbg=240  cterm=none
hi ColorColumn  ctermfg=none ctermbg=236  cterm=none
hi Todo         ctermfg=0    ctermbg=214  cterm=none
hi Ignore       ctermfg=245  ctermbg=none cterm=none
hi StatusLine   ctermfg=none ctermbg=234  cterm=none
hi Search       ctermfg=15   ctermbg=30   cterm=none
hi NonText      ctermfg=74   ctermbg=none cterm=none
hi Folded       ctermfg=43   ctermbg=none cterm=none
hi htmlLink     ctermfg=39   ctermbg=none cterm=underline
" Defined by ws.vim.
hi Ws           ctermfg=241  ctermbg=none cterm=none
hi TrailingWs   ctermfg=0    ctermbg=40   cterm=none

if s:transparency is# "background" || s:transparency is# "full"
    hi ColorColumn ctermbg=237
    hi StatusLine  ctermbg=235
endif
if s:transparency is# "full"
    hi Comment ctermfg=246
    hi LineNr  ctermfg=243
    hi Ignore  ctermfg=246
    hi Ws      ctermfg=243
endif

hi csvCol1 ctermfg=210
hi csvCol2 ctermfg=214
hi csvCol3 ctermfg=226
hi csvCol4 ctermfg=154
hi csvCol5 ctermfg=85
hi csvCol6 ctermfg=81
hi csvCol7 ctermfg=183
hi csvCol8 ctermfg=212
