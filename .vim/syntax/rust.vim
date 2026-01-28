" Vim syntax file
" Language:     Rust
" Maintainer:   taylor.fish <contact@taylor.fish>
" Last Change:  2026-01-25
" Repository:   https://codeberg.org/taylordotfish/rust.vim
" License:      MIT OR Apache-2.0

" Modified from https://github.com/rust-lang/rust.vim (file 'syntax/rust.vim')

" Original header:
" Language:     Rust
" Maintainer:   Patrick Walton <pcwalton@mozilla.com>
" Maintainer:   Ben Blum <bblum@cs.cmu.edu>
" Maintainer:   Chris Morgan <me@chrismorgan.info>
" Last Change:  2023-09-11
" For bugs, patches and license go to https://github.com/rust-lang/rust.vim

" If g:rust_edition is defined, syntax highlighting will be adjusted to be most
" appropriate for the chosen edition. The variable should be set to the integer
" edition year, as in `let g:rust_edition = 2021`. It can also be set to
" 'latest' to use the latest edition supported by this file (2024).
"
" If g:rust_edition is not set, or is set to 0 or 'unknown', heuristics will be
" used to try to guess how edition-dependent syntax should be highlighted, but
" this is not perfect.
"
" If g:rust_highlight_doc_code is set to a falsy value like 0, syntax
" highlighting will not be applied to code blocks in doc comments.
"
" These variables should be set before the syntax file is loaded; i.e., before
" `syntax on`. If modified, `syn off | syn on` is required for the changes to
" take effect.

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

if !exists("g:rust_edition")
    let s:edition = 0
elseif g:rust_edition is# "latest"
    let s:edition = 2024
else
    let s:edition = +g:rust_edition
endif

" Syntax definitions {{{1
" Basic keywords {{{2
syn keyword   rustConditional match if else
syn keyword   rustRepeat loop while
syn keyword   rustRepeat for

" Highlight `for` keyword in `impl ... for ... {}` statement.
syn match     rustImpl /\<impl\>/ nextgroup=rustImplGenerics,rustImplPath skipwhite skipempty
syn match     rustImplPath /\%(::\)\?\s*\K\k*\%(\s*\%(::\)\s*\K\k*\)*/ contained contains=TOP nextgroup=rustImplGenerics,rustImplFor skipwhite skipempty
syn match     rustImplGenerics /\%(::\)\?</ contained contains=rustModPathSep,rustGenerics nextgroup=rustImplFor skipwhite skipempty
syn keyword   rustImplFor for contained

syn keyword   rustRepeat in
syn keyword   rustTypedef type nextgroup=rustIdentifier skipwhite skipempty
syn keyword   rustStructure struct nextgroup=rustIdentifier skipwhite skipempty
syn keyword   rustStructure enum nextgroup=rustIdentifier skipwhite skipempty contained
syn region    rustEnumDecl start=/\<enum\>/ end=/\ze[;{]/ contains=@rustTop,rustStructure,rustGenerics nextgroup=rustEnumBody
syn keyword   rustUnion union nextgroup=rustIdentifier skipwhite skipempty contained
syn match     rustUnionContextual /\<union\_s*\%(\_s\K\|\%$\)/ transparent contains=rustUnion
syn keyword   rustKeyword     as

syn match     rustAssert      "\<assert\%(_\k*\)\?!" contained
syn match     rustPanic       "\<panic!" contained
" `async` was added as a keyword in edition 2018.
if s:edition == 0
    " Edition unknown: highlight only when followed by an identifier, block,
    " or closure. Use whitespace to distinguish whether |x| is a closure or
    " two binary-or operators. Assume || is a closure rather than boolean-or.
    syn match   rustAsync "\<async\>\ze\_s*\%(\K\|{\||[^ ]\)"
elseif s:edition >= 2018
    syn keyword rustAsync async
endif
syn keyword   rustKeyword     break
syn keyword   rustKeyword     box
syn keyword   rustKeyword     continue
syn keyword   rustKeyword     crate
syn keyword   rustKeyword     extern nextgroup=rustExternCrate,rustObsoleteExternMod skipwhite skipempty
syn keyword   rustKeyword     fn nextgroup=rustFuncName skipwhite skipempty
" `gen` was added as a keyword in edition 2024.
if s:edition == 0
    " Edition unknown: highlight only when followed by '{', in accordance with
    " the 'gen_blocks' feature.
    syn match   rustKeyword "\<gen\>\ze\_s*{"
elseif s:edition >= 2024
    syn match   rustKeyword "\<gen\>"
endif
syn keyword   rustKeyword     let
syn keyword   rustKeyword     macro
syn keyword   rustKeyword     pub nextgroup=rustPubScope skipwhite skipempty
syn keyword   rustKeyword     return
syn keyword   rustKeyword     yield
syn keyword   rustSuper       super
syn keyword   rustKeyword     where
syn keyword   rustUnsafeKeyword unsafe
syn match     rustKeyword     /\<safe\ze\_s\+fn\>/ " `safe fn`
syn keyword   rustKeyword     use nextgroup=rustModPath skipwhite skipempty
" FIXME: Scoped impl's name is also fallen in this category
syn keyword   rustKeyword     mod trait nextgroup=rustIdentifier skipwhite skipempty
syn keyword   rustStorage     move mut ref static const
" `&raw const` and `&raw mut`
syn match     rustStorage     /\%(&\s*\)\@<=\<raw\ze\_s\+\%(const\|mut\)\>/
syn match     rustDefault     /\<default\ze\_s\+\(impl\|fn\|type\|const\)\>/
" `await` was added as a keyword in edition 2018.
if s:edition == 0
    " Edition unknown: highlight only when the syntax would be valid in edition
    " 2018+ (preceded by '.', and not followed by parentheses).
    syn match   rustAwait /\.\s*\zsawait\%\(\s*(\)\@!\>/
elseif s:edition >= 2018
    syn keyword rustAwait await
endif
" `try` was added as a keyword in edition 2018.
if s:edition == 0
    " Edition unknown: highlight only when followed by '{', in accordance with
    " the 'try_blocks' feature.
    syn match   rustKeyword "\<try\>\ze\_s*{"
elseif s:edition >= 2018
    syn keyword rustKeyword try
endif

syn keyword rustPubScopeCrate crate contained
syn match rustPubScopeDelim /[()]/ contained
syn match rustPubScope /([^()]*)/ contained contains=rustPubScopeDelim,rustPubScopeCrate,rustSuper,rustModPath,rustModPathSep,rustSelf transparent

syn keyword   rustExternCrate crate contained nextgroup=rustIdentifier skipwhite skipempty
syn keyword   rustObsoleteExternMod mod contained nextgroup=rustIdentifier skipwhite skipempty

syn match     rustIdentifier  "\K\k*" display contained contains=@rustKeyword
syn match     rustFuncName    "\%(r#\)\=\K\k*" display contained contains=@rustKeyword

syn region rustMacroRepeat matchgroup=rustMacroRepeatDelimiters start="$(" end="),\=[*+?]" contains=TOP
syn match rustMacroVariable "$\K\k*"
syn match rustRawIdent "\<r#\K\k*"

" Reserved (but not yet used) keywords {{{2
syn keyword   rustReservedKeyword become do priv typeof unsized abstract virtual final override

" Built-in types {{{2
syn keyword   rustType        isize usize char bool u8 u16 u32 u64 u128 f32
syn keyword   rustType        f64 i8 i16 i32 i64 i128 str Self

" Things from the prelude (std::prelude) {{{2
" This section is just straight transformation of the contents of the prelude,
" to make it easy to update.

" Prelude functions {{{3
" There’s no point in highlighting these; when one writes drop( or drop::< it
" gets the same highlighting anyway, and if someone writes `let drop = …;` we
" don’t really want *that* drop to be highlighted.
"syn keyword rustFunction drop

" Prelude types and traits {{{3
syn keyword rustTrait Copy Send Sized Sync
syn keyword rustTrait Drop Fn FnMut FnOnce
syn keyword rustStruct Box
syn keyword rustTrait ToOwned
syn keyword rustTrait Clone
syn keyword rustTrait PartialEq PartialOrd Eq Ord
syn keyword rustTrait AsRef AsMut Into From
syn keyword rustTrait Default
syn keyword rustTrait Iterator Extend IntoIterator
syn keyword rustTrait DoubleEndedIterator ExactSizeIterator
syn keyword rustEnum Option
syn keyword rustEnumVariant Some None
syn keyword rustEnum Result
syn keyword rustEnumVariant Ok Err
syn keyword rustStruct String
syn keyword rustTrait ToString
syn keyword rustStruct Vec
if s:edition == 0 || s:edition >= 2021
    syn keyword rustTrait FromIterator TryFrom TryInto
endif
if s:edition == 0 || s:edition >= 2024
    syn keyword rustTrait Future IntoFuture
endif

" Other syntax {{{2
" This cluster exists because TOP can't be used as a normal group: it must be
" the first item in a `contains` or `containedin` list, and it causes
" subsequent groups to be excluded rather than included.
syn cluster   rustTop         contains=TOP
syn cluster   rustKeyword     contains=rustKeyword,rustImpl,rustAsync,rustAwait,rustReservedKeyword
syn cluster   rustPrelude     contains=rustTrait,rustEnum,rustEnumVariant,rustStruct
syn cluster   rustNoPrelude   contains=TOP,@rustPrelude

syn keyword   rustSelf        self
syn keyword   rustBoolean     true false

syn match     rustModPath     "\<\%(r#\)\?\K\k*\ze\s*::"
syn match     rustModPathSep  "::" nextgroup=rustTypeChild skipwhite
" In paths, prevent types' children from being highlighted as prelude items.
" This is mostly for enum variants, as in `let s = Shape::Box`, but also
" affects associated types. Detection of whether the parent is a type is based
" on capitalization.
syn match     rustTypeChild   /\%(\%(\k\@<!_\?[[:upper:]]\k*\s*\|>\)::\s*\)\@<=\%(r#\)\?\K\k*/ contained contains=@rustNoPrelude

syn match     rustFuncCall    "\<\%(r#\)\?\K\k*\ze\s*("
" Handle turbofish function calls (foo::<T>()). We can't match arbitrarily
" nested type parameters and const generic expressions in a regular expression.
" This pattern permits one additional level of <> or {} nesting, which should
" catch most cases. For example, `foo::<A<B, C>, { D < E }>()` is allowed.
syn match     rustFuncCall    "\<\%(r#\)\?\K\k*\ze\s*::\s*<\%([^<>{}]*\%(<[^<>{}]*>\)\?\%({[^{}]*}\)\?\)*>("

" This is merely a convention. A previous comment here said [A-Z] should be
" used instead of [[:upper:]] to avoid the effects of 'ignorecase', but syntax
" patterns aren't affected by 'ignorecase' (see ':syn case'), and [A-Z]
" normally *is* affected.
"syn match     rustCapsIdent    display "[[:upper:]]\k\+"

syn match     rustOperator     display "\%(+\|-\|/\|*\|=\|\^\|&\||\|!\|>\|<\|%\)=\?"
" This pattern matches boolean-and and -or operators. Note that if there is no
" whitespace after `&&`, the rule for rustSigil below will take precedence.
" Also note that this matches the first part of closures with no arguments
" (|| {}), but given that in closures with arguments (|x| {}), the rule above
" matches the `|` characters as rustOperator, matching `||` as rustOperator
" here should make no difference.
syn match     rustOperator     display "&&\|||"
" This one depends on consistent use of whitespace after binary-and and
" boolean-and operators, and not after borrow operators.
syn match     rustSigil        display /[&*]\+[^&*)= \t]\@=/
" This is rustArrowCharacter rather than rustArrow for the sake of matchparen,
" so it skips the ->; see http://stackoverflow.com/a/30309949 for details.
syn match     rustArrowCharacter display "->"
syn match     rustQuestionMark display "?\K\@!"
syn match     rustMacro       '\K\k*!' contains=rustAssert,rustPanic

syn match     rustEscapeError   display contained /\\./
syn match     rustEscape        display contained /\\\([nrt0\\'"]\|x\x\{2}\)/
syn match     rustEscapeUnicode display contained /\\u{\%(\x_*\)\{1,6}}/
syn match     rustStringContinuation display contained /\\\n\s*/
syn region    rustString      matchgroup=rustStringDelimiter start=+b"+ skip=+\\\\\|\\"+ end=+"+ contains=rustEscape,rustEscapeError,rustStringContinuation
syn region    rustString      matchgroup=rustStringDelimiter start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=rustEscape,rustEscapeUnicode,rustEscapeError,rustStringContinuation,@Spell
syn region    rustString      matchgroup=rustStringDelimiter start='b\?r\z(#*\)"' end='"\z1' contains=@Spell

" Match attributes with either arbitrary syntax or special highlighting for
" derives. We still highlight strings and comments inside of the attribute.
syn region    rustAttribute   matchgroup=rustAttribute start="#!\?\[" end="\]" contains=@rustAttributeContents,rustAttributeBalancedParens,rustAttributeBalancedCurly,rustAttributeBalancedBrackets,rustDerive
syn region    rustAttributeBalancedParens matchgroup=rustAttribute start="("rs=e end=")"re=s transparent contained contains=rustAttributeBalancedParens,@rustAttributeContents
syn region    rustAttributeBalancedCurly matchgroup=rustAttribute start="{"rs=e end="}"re=s transparent contained contains=rustAttributeBalancedCurly,@rustAttributeContents
syn region    rustAttributeBalancedBrackets matchgroup=rustAttribute start="\["rs=e end="\]"re=s transparent contained contains=rustAttributeBalancedBrackets,@rustAttributeContents
syn cluster   rustAttributeContents contains=rustString,rustCommentLine,rustCommentBlock,rustCommentLineDocError,rustCommentBlockDocError
syn region    rustDerive      start="derive(" end=")" contained contains=rustDeriveTrait
" This list comes from compiler/rustc_builtin_macros/src/lib.rs
syn keyword   rustDeriveTrait contained Clone Copy Debug Default Eq Hash Ord PartialEq PartialOrd ConstParamTy CoercePointee From

" `dyn` was added as a strict keyword in edition 2018. In edition 2015, it's
" a keyword only in type expressions, and only when followed by a path not
" starting with '::' or '<', a lifetime, '?', 'for', or '('.
if s:edition == 0
    " Edition unknown: highlight only when followed by an identifier, lifetime,
    " '::', or '('. In the case of '::' and '(', require a preceding space, to
    " distinguish from a pre-2018 path or function call. This makes it so most
    " uses of `dyn` as a normal variable, function, or module name are not
    " highlighted.
    syn match   rustDynKeyword /\<dyn\>\ze\s*\%(for\>\)\@!\%(\K\|'\|\s::\|\s(\)/
elseif s:edition < 2018
    " 2015 edition: highlight only when followed by an identifier or lifetime.
    syn match   rustDynKeyword /\<dyn\>\ze\s*\%(for\>\)\@!\K/
else
    syn keyword rustDynKeyword dyn
endif

" Number literals
syn match     rustDecNumber   display "\<[0-9][0-9_]*\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match     rustHexNumber   display "\<0x[a-fA-F0-9_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match     rustOctNumber   display "\<0o[0-7_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match     rustBinNumber   display "\<0b[01_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="

" Special case for numbers of the form "1." which are float literals, unless followed by
" an identifier, which makes them integer literals with a method call or field access,
" or by another ".", which makes them integer literals followed by the ".." token.
" (This must go first so the others take precedence.)
syn match     rustFloat       display "\<[0-9][0-9_]*\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\|\.\)\@!"
" To mark a number as a normal float, it must have at least one of the three things integral values don't have:
" a decimal point and more numbers; an exponent; and a type suffix.
syn match     rustFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\%([eE][+-]\=[0-9_]\+\)\=\(f32\|f64\)\="
syn match     rustFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\=\%([eE][+-]\=[0-9_]\+\)\(f32\|f64\)\="
syn match     rustFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\=\%([eE][+-]\=[0-9_]\+\)\=\(f32\|f64\)"

" For the benefit of delimitMate
syn region rustLifetimeCandidate display start=/&'\%(\([^'\\]\|\\\(['nrt0\\\"]\|x\x\{2}\|u{\%(\x_*\)\{1,6}}\)\)'\)\@!/ end=/[[:cntrl:][:space:][:punct:]]\@=\|$/ contains=rustSigil,rustLifetime
syn region rustGenericRegion display start=/<\%('\|[^[:cntrl:][:space:][:punct:]]\)\@=')\S\@=/ end=/>/ contains=rustGenericLifetimeCandidate
syn region rustGenericLifetimeCandidate display start=/\%(<\|,\s*\)\@<='/ end=/[[:cntrl:][:space:][:punct:]]\@=\|$/ contains=rustSigil,rustLifetime

"rustLifetime must appear before rustCharacter, or chars will get the lifetime highlighting
syn match     rustLifetime    display "\'\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*"
syn match     rustLabel       display "\'\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*:"
syn match     rustLabel       display "\%(\<\%(break\|continue\)\s*\)\@<=\'\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*"
syn match   rustCharacterInvalid   display contained /b\?'\zs[\n\r\t']\ze'/
" The groups negated here add up to 0-255 but nothing else (they do not seem to go beyond ASCII).
syn match   rustCharacterInvalidUnicode   display contained /b'\zs[^[:cntrl:][:graph:][:alnum:][:space:]]\ze'/
syn match   rustCharacter   /b'\([^\\]\|\\\(.\|x\x\{2}\)\)'/ contains=rustEscape,rustEscapeError,rustCharacterInvalid,rustCharacterInvalidUnicode
syn match   rustCharacter   /'\([^\\]\|\\\(.\|x\x\{2}\|u{\%(\x_*\)\{1,6}}\)\)'/ contains=rustEscape,rustEscapeUnicode,rustEscapeError,rustCharacterInvalid

syn match rustShebang /\%^#![^[].*/
syn region rustCommentLine                                                     start="//"                      end="$"   contains=rustTodo,@Spell
syn region rustCommentLineDoc                                                  start="//\%(//\@!\|!\)"         end="$"   contains=rustTodo,@Spell
syn region rustCommentLineDocError                                             start="//\%(//\@!\|!\)"         end="$"   contains=rustTodo,@Spell contained
syn region rustCommentBlock             matchgroup=rustCommentBoundary         start="/\*\%(!\|\*[*/]\@!\)\@!" end="\*/" contains=rustTodo,rustCommentBlockNest,@Spell keepend
syn region rustCommentBlockDoc          matchgroup=rustCommentBoundaryDoc      start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=rustTodo,rustCommentBlockDocNest,rustCommentBlockDocRustCode,rustCommentBlockDocNonRustCode,@Spell keepend
syn region rustCommentBlockDocError     matchgroup=rustCommentBoundaryDocError start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=rustTodo,rustCommentBlockDocNestError,@Spell keepend contained
syn region rustCommentBlockNest         matchgroup=rustCommentBoundary         start="/\*"                     end="\*/" contains=rustTodo,rustCommentBlockNest,@Spell keepend contained transparent
syn region rustCommentBlockDocNest      matchgroup=rustCommentBoundaryDoc      start="/\*"                     end="\*/" contains=rustTodo,rustCommentBlockDocNest,@Spell keepend contained transparent
syn region rustCommentBlockDocNestError matchgroup=rustCommentBoundaryDocError start="/\*"                     end="\*/" contains=rustTodo,rustCommentBlockDocNestError,@Spell keepend contained transparent

" There used to be a comment detailing a flaw in the highlighting of comments,
" where `/* foo */*` would be parsed not as a single comment followed by an
" asterisk, but as a comment containing another nested, unclosed comment. The
" fix for this is simple: make sure the 'matchgroup' of each of the above
" regions has a *different* name from the region itself, hence the
" 'rustCommentBoundary' groups. When the matchgroup is the same, a contained
" item can begin *within* the end pattern, overriding it, so `*/*` in the
" example gets parsed as `*` + `/*`, where the latter starts a nested comment.
" When the matchgroup is different, it's parsed as `*/` + `*`, where the former
" ends the comment. Note that when using a different matchgroup, the syntax
" highlighting of the region no longer applies to the start and end patterns,
" so `hi def link` should be used to link the matchgroups to the regions.

syn keyword rustTodo contained TODO FIXME XXX NB NOTE SAFETY

" asm! macro {{{2
syn region rustAsmMacro matchgroup=rustMacro start="\<asm!\s*(" end=")" contains=rustAsmDirSpec,rustAsmSym,rustAsmConst,rustAsmOptionsGroup,rustComment.*,rustString.*

" Clobbered registers
syn keyword rustAsmDirSpec in out lateout inout inlateout contained nextgroup=rustAsmReg skipwhite skipempty
syn region  rustAsmReg start="(" end=")" contained contains=rustString

" Symbol operands
syn keyword rustAsmSym sym contained nextgroup=rustAsmSymPath skipwhite skipempty
syn region  rustAsmSymPath start="\S" end=",\|)"me=s-1 contained contains=rustComment.*,rustIdentifier

" Const
syn region  rustAsmConstBalancedParens start="("ms=s+1 end=")" contained contains=@rustAsmConstExpr
syn cluster rustAsmConstExpr contains=rustComment.*,rust.*Number,rustString,rustAsmConstBalancedParens
syn region  rustAsmConst start="const" end=",\|)"me=s-1 contained contains=rustStorage,@rustAsmConstExpr

" Options
syn region  rustAsmOptionsGroup start="options\s*(" end=")" contained contains=rustAsmOptions,rustAsmOptionsKey
syn keyword rustAsmOptionsKey options contained
syn keyword rustAsmOptions pure nomem readonly preserves_flags noreturn nostack att_syntax contained

" Folding rules {{{2
" Trivial folding rules to begin with.
" FIXME: use the AST to make really good folding
syn region rustFoldBraces start="{" end="}" transparent fold

" Enum declarations {{{2
" These rules prevent enum variants from being highlighted as a prelude item,
" as in `enum Shape { Box, Sphere }`. They need to be defined here to override
" previous rules.
syn region rustEnumBody matchgroup=rustEnumBody start=/{/ end=/}/ contained contains=@rustNoPrelude,rustEnumBody,rustGenerics,rustBraces,rustParens
syn region rustGenerics matchgroup=rustOperator start=/</ end=/>/ contained contains=@rustTop,rustGenerics,rustBraces
" rustBraces doesn't need to contain itself due to rustFoldBraces
syn region rustBraces matchgroup=rustBraces start=/{/ end=/}/ contained contains=TOP
syn region rustParens matchgroup=rustParens start=/(/ end=/)/ contained contains=@rustTop,rustParens

" Fenced code blocks in doc comments {{{2
let s:highlight_doc_code = !!get(g:, "rust_highlight_doc_code", 1)
if s:highlight_doc_code
    " Currently regions marked as ```<some-other-syntax> will not get
    " highlighted at all. In the future, we can do as vim-markdown does and
    " highlight with the other syntax. But for now, let's make sure we find
    " the closing block marker so that the rules below don't interpret it as
    " the opening of a Rust code block.
    syn region rustCommentLinesDocNonRustCode matchgroup=rustCommentDocCodeFence start='^\s*\z(//[!/]\)\s*```.*' end='^\s*\z1\s*```\s*$\|^\ze\s*\%(\%(////\)\@!\z1\)\@!\S' keepend contains=rustCommentLineDoc
    syn region rustCommentBlockDocNonRustCode matchgroup=rustCommentDocCodeFence start='^\s*\z(\*\?\)\s*```'     end='^\s*\z1\s*```\s*$' transparent contained contains=NONE

    " We borrow the rules from rust’s src/librustdoc/html/markdown.rs, so that
    " we only highlight as Rust what it would perceive as Rust (almost; it’s
    " possible to trick it if you try hard, and indented code blocks aren’t
    " supported because Markdown is a menace to parse and only mad dogs and
    " Englishmen would try to handle that case correctly in this syntax file).
    let s:code_fence_lang = '\s*\%(\%(\%(.*,\s*\)\?custom[^, \t]\@!\)\@!\%(.*,\s*\)\?rust[^, \t]\@!.*\|\%(\%(should_panic\|no_run\|ignore\%(-[^, \t]*\)\?\|test_harness\|compile_fail\|standalone_crate\|edition[^, \t]*\|E\d\{4}\|{[^}]*}\|[((][^)]*)\)\%([, \t]\+\|$\)\)*$\)'
    execute 'syn region rustCommentLinesDocRustCode matchgroup=rustCommentDocCodeFence start="^\s*\z(//[!/]\)\s*```' . s:code_fence_lang . '" end="^\s*\z1\s*```\s*$\|^\ze\s*\%(\%(////\)\@!\z1\)\@!\S" keepend contains=@rustEmbeddedTop,rustCommentLineDocLeader'
    execute 'syn region rustCommentBlockDocRustCode matchgroup=rustCommentDocCodeFence start="^\s*\z(\*\?\)\s*```'   . s:code_fence_lang . '" end="^\s*\z1\s*```\s*$" keepend contains=@rustEmbeddedTop,@rustBlockDocCodeLeader contained'
    " These patterns are not perfect, but should perform reasonably well in
    " most cases. In line doc comments (/// and //!), this will highlight
    " correctly. In block doc comments (/** and /*!), this will highlight
    " correctly if every line is prefixed with '*'. If the contents of a block
    " doc comment are *not* prefixed with '*', this will highlight incorrectly
    " in the following cases:
    "
    " 1. If two adjacent lines of the code block both happen to begin with '*',
    "    the '*' in the second line will be highlighted as a comment character.
    " 2. Inside a multiline enum declaration, attribute, or macro repetition
    "    expression ($(x)*), if two adjacent lines both begin with `///`, the
    "    second line won't be highlighted as a doc comment.
    "
    " The best way to avoid these corner cases is to prefix every line with
    " '*', or use line doc comments.
    syn match rustBlockDocCodeLineStart /^/ contained nextgroup=rustCommentBlockDocStar,rustDocCodeHash

    syn match rustCommentBlockDocStar /^\%\(^\s*\*.*\n\)\@<=\s*\*/ contained nextgroup=rustDocCodeHash skipwhite
    syn match rustCommentLineDocLeader "^\s*//\(//\@!\|!\)\%(^\s*//\%(//\)\@!\1.*\n.*\)\@<=" contained nextgroup=rustDocCodeHash skipwhite
    syn match rustDocCodeLeadingHash /^\s*#[^ ]\@!/ contained contains=rustDocCodeHash
    syn match rustDocCodeHash /#[^ ]\@!/ contained

    syn cluster rustDocCodeLeader contains=rustCommentLineDocLeader,@rustBlockDocCodeLeader
    syn cluster rustBlockDocCodeLeader contains=rustCommentBlockDocStar,rustDocCodeLeadingHash
    syn cluster rustContextFreeTop contains=TOP,@rustContextSensitiveTop
    syn cluster rustEmbeddedTop contains=@rustContextFreeTop,@rustContextSensitiveTopEmbedded
endif

" Creates 'embedded' versions of various syntax groups. These are used for
" highlighting code in doc comments. The difference is that these groups ignore
" the leading `///` or `*` at the start of each line. `groups` should be a list
" of strings, consisting of the groups for which an embedded version should be
" created. The names of the embedded groups will be suffixed with 'Embedded'.
function s:CreateEmbeddedRules(groups)
    let l:state = #{counter: 1}
    let l:any_group = join(a:groups, '\|')
    let l:line_pattern = '^syn \(cluster\|match\|keyword\|region\)\s\+\('
        \ . l:any_group . '\)\>.*'
    let l:top = []
    for l:line in readfile(s:script_path)
        let l:match = matchlist(l:line, l:line_pattern)
        if empty(l:match)
            continue
        endif
        let [l:kind, l:name] = l:match[1:2]
        let l:text = l:match[0]->substitute(
            \ '\<\%(' . l:any_group . '\)\>',
            \ '\0Embedded',
            \ 'g',
        \ )->substitute(
            \ '\<contain\%(s\|edin\)=\zs\S*',
            \ { m -> s:EmbedContains(l:state, m[0]) },
            \ 'g',
        \ )
        if l:kind ==# "region" && l:text !~# '\<contains='
            let l:text .= ' contains=@rustDocCodeLeader'
        endif
        if l:kind !=# "cluster" && l:text !~# '\<contained\>'
            let l:text .= ' contained'
            call add(l:top, l:name)
        endif
        execute l:text
        if l:kind !=# "cluster"
            execute 'hi def link ' . l:name . 'Embedded ' . l:name
        endif
    endfor
    execute 'syn cluster rustContextSensitiveTop contains=' . join(l:top, ',')
    call map(l:top, { _, x -> x . 'Embedded' })
    execute 'syn cluster rustContextSensitiveTopEmbedded contains='
        \ . join(l:top, ',')
endfunction

" Transforms a `contains` or `containedin` argument of a `syn` command into an
" equivalent embedded one. Used by `s:CreateEmbeddedRules`.
function s:EmbedContains(state, contains)
    let l:list = split(a:contains, ',')
    if l:list[0] ==# "TOP" && len(l:list) > 1
        let l:cluster = 'rustEmbeddedCluster' . a:state.counter
        let a:state.counter += 1
        call add(l:list, "@rustContextSensitiveTop")
        execute 'syn cluster ' . l:cluster . ' contains=' . join(l:list, ',')
        let l:list = ['@' . l:cluster, "@rustContextSensitiveTopEmbedded"]
    else
        let l:i = l:list[0] ==# "TOP" ? 0 : index(l:list, "@rustTop")
        if l:i != -1
            let l:list[l:i] = "@rustEmbeddedTop"
        endif
    endif
    return l:list->add("@rustDocCodeLeader")->join(',')
endfunction

if s:highlight_doc_code && v:version >= 802
    let s:script_path = expand("<sfile>")
    call s:CreateEmbeddedRules([
        \ "rustEnumDecl", "rustMacroRepeat", "rustNoPrelude", "rustAttribute",
        \ "rustAttributeBalancedParens", "rustAttributeBalancedCurly",
        \ "rustAttributeBalancedBrackets", "rustAttributeContents",
        \ "rustDerive", "rustEnumBody", "rustGenerics", "rustBraces",
        \ "rustParens",
    \ ])
endif

" Default highlighting {{{1
hi def link rustDecNumber       rustNumber
hi def link rustHexNumber       rustNumber
hi def link rustOctNumber       rustNumber
hi def link rustBinNumber       rustNumber
hi def link rustTrait           rustType
hi def link rustDeriveTrait     rustTrait
" Prelude structs used to be in rustTrait. Link rustStruct to rustTrait for
" backward compatibility.
hi def link rustStruct          rustTrait

hi def link rustMacroRepeatDelimiters   Macro
hi def link rustMacroVariable Define
hi def link rustSigil         StorageClass
hi def link rustEscape        Special
hi def link rustEscapeUnicode rustEscape
hi def link rustEscapeError   Error
hi def link rustStringContinuation Special
hi def link rustString        String
hi def link rustStringDelimiter String
hi def link rustCharacterInvalid Error
hi def link rustCharacterInvalidUnicode rustCharacterInvalid
hi def link rustCharacter     Character
hi def link rustNumber        Number
hi def link rustBoolean       Boolean
hi def link rustEnum          rustType
hi def link rustEnumVariant   rustConstant
hi def link rustConstant      Constant
hi def link rustSelf          Constant
hi def link rustFloat         Float
hi def link rustArrowCharacter rustOperator
hi def link rustOperator      Operator
hi def link rustKeyword       Keyword
hi def link rustDynKeyword    rustKeyword
hi def link rustTypedef       Keyword " More precise is Typedef, but it doesn't feel right for Rust
hi def link rustStructure     Keyword " More precise is Structure
hi def link rustUnion         rustStructure
hi def link rustExistential   rustKeyword
hi def link rustPubScopeDelim Delimiter
hi def link rustPubScopeCrate rustKeyword
hi def link rustSuper         rustKeyword
hi def link rustUnsafeKeyword Exception
hi def link rustReservedKeyword Error
hi def link rustRepeat        Conditional
hi def link rustConditional   Conditional
hi def link rustIdentifier    Identifier
hi def link rustCapsIdent     rustIdentifier
hi def link rustModPath       Include
hi def link rustModPathSep    Delimiter
hi def link rustFunction      Function
hi def link rustFuncName      Function
hi def link rustFuncCall      Function
hi def link rustShebang       Comment
hi def link rustCommentLine   Comment
hi def link rustCommentLineDoc SpecialComment
hi def link rustCommentLineDocLeader rustCommentLineDoc
hi def link rustCommentLineDocError Error
hi def link rustCommentBlock  rustCommentLine
hi def link rustCommentBlockDoc rustCommentLineDoc
hi def link rustCommentBlockDocStar rustCommentBlockDoc
hi def link rustCommentBlockDocError Error
hi def link rustCommentBoundary rustCommentBlock
hi def link rustCommentBoundaryDoc rustCommentBlockDoc
hi def link rustCommentBoundaryDocError rustCommentBlockDocError
hi def link rustCommentDocCodeFence rustCommentLineDoc
hi def link rustDocCodeHash   rustCommentLineDoc
hi def link rustAssert        PreCondit
hi def link rustPanic         PreCondit
hi def link rustMacro         Macro
hi def link rustType          Type
hi def link rustTodo          Todo
hi def link rustAttribute     PreProc
hi def link rustDerive        PreProc
hi def link rustDefault       StorageClass
hi def link rustStorage       StorageClass
hi def link rustObsoleteStorage Error
hi def link rustLifetime      Special
hi def link rustLabel         Label
hi def link rustExternCrate   rustKeyword
hi def link rustObsoleteExternMod Error
hi def link rustQuestionMark  Special
hi def link rustAsync         rustKeyword
hi def link rustAwait         rustKeyword
hi def link rustAsmDirSpec    rustKeyword
hi def link rustAsmSym        rustKeyword
hi def link rustAsmOptions    rustKeyword
hi def link rustAsmOptionsKey rustAttribute
hi def link rustImpl          rustKeyword
hi def link rustImplFor       rustKeyword

" Other Suggestions:
" hi rustAttribute ctermfg=cyan
" hi rustDerive ctermfg=cyan
" hi rustAssert ctermfg=yellow
" hi rustPanic ctermfg=red
" hi rustMacro ctermfg=magenta

syn sync minlines=200
syn sync maxlines=500
syn sync linebreaks=1

let b:current_syntax = "rust"

" vim: set et sw=4 sts=4 ts=8:
