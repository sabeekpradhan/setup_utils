" Set up Vundle, and install your desired plugins.
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Manage Vundle with Vundle
Plugin 'gmarik/Vundle.vim'

" YCM, the big one!
Plugin 'ycm-core/YouCompleteMe'
" Syntax in glog files
Plugin 'Peaches491/vim-glog-syntax'
" Faster cmdt fuzzy searching
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" Handle git within vim 
Plugin 'tpope/vim-fugitive'

call vundle#end()
filetype plugin indent on

let g:ycm_global_ycm_extra_conf='~/.ycm_extra_conf.py'

" In visual mode, use Ctrl-G for the currently highlighted text.
vnoremap <C-G> y:Ggrep -l '<c-R>"'<cr>

" YCM commands
let g:ycm_goto_buffer_command = 'horizontal-split'
nnoremap <C-f> :YcmCompleter FixIt<CR>
nnoremap <C-t> :YcmCompleter GetType<CR>

" Activate GFiles search with backslash-f
nmap <leader>f :GFiles<cr>

" Fugitive options for Gblame:
" A     resize to end of author column
" C     resize to end of commit column
" D     resize to end of date/time column
" gq    close blame, then |:Gedit| to return to work
"       tree version
" <CR>  close blame, and jump to patch that added line
"       (or directly to blob for boundary commit)
" o     jump to patch or blob in horizontal split
" O     jump to patch or blob in new tab
" p     jump to patch or blob in preview window
" -     reblame at commit
" ~     reblame at [count]th first grandparent
" P     reblame at [count]th parent (like HEAD^[count]).e. backslash, i.e. 'leader')
"
" Visit https://github.com/tpope/vim-fugitive/blob/master/doc/fugitive.txt for more options.

" Convert default indentation between 2 and 4 spaces.
command! TwoSpace set shiftwidth=2 | set softtabstop=2
command! FourSpace set shiftwidth=4 | set softtabstop=4

" Use correct line endings.
set ff=unix

" Min lines above/below the cursor
set scrolloff=5

" Fold by indent
set foldmethod=indent

" Disable F1
:nnoremap <F1> :echo<CR>
:inoremap <F1> <C-o>:echo<CR>

" Show editing mode in status (-- INSERT --)
set showmode

" Disable text wrapping
set tw=0
set nowrap

" Disable backing up files on :w
set nobackup

" Show cursor position
set ruler

" Turn off modeline (for security?)
set nomodeline

" By default, use memory, not swap files
set noswapfile

" Set the directory for whatever swap files you do use
set directory=/tmp

" Don't show tab or EOL chars
set nolist

" Automatically reload files when they have changed
set autoread

" Auto Indent according to the c standard
set ai
set cindent

" Show line numbers
set nu

" Incremental search
set incsearch

" Highlight search results
set hlsearch

" Disable all existing auto-commands to avoid potentially running auto-commands twice
:autocmd!

" Disable the visual and error bell
autocmd VimEnter * set vb t_vb=

" Remove the top tool bar with visual buttons
set go-=T

" Remove the right scroll bar
set go-=r

" Set a nicer color scheme
silent! color ron

" Ignore these files during autocomplete
set wildignore=*.o,*.obj,*.bak,*.exe,*.a,*.dep

" Set default spacing parameters
set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Change active split with Ctrl-k and Ctrl-j
nnoremap <c-j> <C-w><S-w>
nnoremap <c-k> <C-w>w
nnoremap <c-j> <C-w><S-w>
nnoremap <c-k> <C-w>w

" Tab commands:
" * Ctrl-n to make a new tab
" * Ctrl-x to close tab
" * Ctrl-h to move left one tab
" * Ctrl-l to move right one tab
" * Ctrl-m Ctrl-h to move the current tab to the left
" * Ctrl-m Ctrl-l to move the current tab to the right
fun! CloseTab()
  if confirm("Close tab?", "&yes\n&no", 1) == 1
    :tabclose
  endif
endfun

nnoremap <c-n> :tabnew<cr>
nnoremap <c-x> :call CloseTab()<cr>
nnoremap <c-h> gT
nnoremap <c-l> gt
nnoremap <c-m><c-h> :tabm -1<cr>
nnoremap <c-m><c-l> :tabm +1<cr>
vnoremap <c-n> :tabnew<cr>
vnoremap <c-x> :call CloseTab()<cr>
vnoremap <c-h> gT
vnoremap <c-l> gt
vnoremap <c-m><c-h> :tabm -1<cr>
vnoremap <c-m><c-l> :tabm +1<cr>

" :Vs == :vs
cab Vs vs

" Enable filetype specific default rules
filetype plugin on

" Set FileTypes
if !exists("did_load_filetypes_custom")
  let did_load_filetypes_custom = 1

  autocmd! BufNewFile,BufReadPost *.c,*.h,*.cpp,*.cc,*.cu.cc set ft=cpp
  autocmd! BufNewFile,BufReadPost *.java set ft=java
  autocmd! BufNewFile,BufReadPost *.xul,*.html set ft=html

  autocmd! BufNewFile,BufReadPost *.txt,README,INSTALL set ft=text
  autocmd! BufNewFile,BufReadPost *.js,*.json,*.vue set ft=javascript
  autocmd! BufNewFile,BufReadPost *.py set ft=python
  autocmd! BufNewFile,BufReadPost *.xml,*.launch set ft=xml
endif

" Replace all tabs with space
autocmd! BufWinEnter *.cpp,*.cu.cc,*.cc,*.c,*.h,*.java,*.js,*.py :%s/\t/    /eg

" Highlight all lines longer than 80 characters
autocmd! BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

" Show whitespace at the end of lines, but not the current line when in insert mode.
highlight ExtraWhitespace ctermbg=lightgrey guibg=lightgrey
autocmd ColorScheme * highlight ExtraWhitespace guibg=lightgrey
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/

" Helper functions
if !exists ("did_load_helper_functions")
  let did_load_helper_functions = 1

  " Eat whitespace character
  function! EatSpace()
    let c = nr2char(getchar(0))
    return (c =~ '\s' || c =~ '\r' || c =~ '\n') ? '' : c
  endfunc

  " Eat whitespace and open bracket character
  function! EatSpaceBracket()
    let c = nr2char(getchar(0))
    return (c =~ '\s' || c =~ '\r' || c =~ '\n' || c =~ '(') ? '' : c
  endfunc

  " Context sensitive abbreviation (iab)
  " Prevent expansion within a comment, string or character
  function! MapWithContext(key, seq)
    let syn_context = synIDattr(synID(line('.'), col('.') - 1, 1), 'name')
    if syn_context =~? 'comment\|string\|character\|doxygen'
      return a:key
    else
      exe 'return "' . substitute(a:seq, '\\<\(.\{-}\)\\>', '"."\\<\1>"."', 'g') . '"'
    endif
  endfunction

  " Uses MapWithContext to add file type specific abbreviations
  function! IabForFT(ft, key, seq)
    exe 'autocmd BufEnter ' . a:ft . ' iab <silent> ' . a:key . ' <C-R>=MapWithContext("' . a:key . '", "' . a:seq . '")<CR>'
  endfunction
  autocmd BufLeave * iabclear

  " Escape seq for IabForFT
  function! E(val)
    return substitute(a:val, '<\(.\{-}\)>', '\\\\<\1\\>', 'g')
  endfunction
endif " End Helper Functions

" FileType Specific Abbreviations
if !exists("did_load_abbreviations")
  let did_load_abbreviations = 1

  " CPP
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'define', '#define')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'def', '#define')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'inc', '#include')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'ifdef', '#ifdef')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'ind', '#ifndef')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'ifndef', '#ifndef')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'ei', '#endif')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'endif', '#endif')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'NULL', 'nullptr')
  call IabForFT('*.h,*.cpp,*.c,*.cc,*.cu.cc', 'null', 'nullptr')

  " PY
  call IabForFT('*.py,*.ctw,*.tw,*.cinc,*.conf,*.thrift-cvalidator,*.ctest', 'while', E('while :<Left><C-R>=EatSpace()<CR>'))
  call IabForFT('*.py,*.ctw,*.tw,*.cinc,*.conf,*.thrift-cvalidator,*.ctest', 'for', E('for :<Left><C-R>=EatSpace()<CR>'))
  call IabForFT('*.py,*.ctw,*.tw,*.cinc,*.conf,*.thrift-cvalidator,*.ctest', 'if', E('if :<Left><C-R>=EatSpace()<CR>'))
  call IabForFT('*.py,*.ctw,*.tw,*.cinc,*.conf,*.thrift-cvalidator,*.ctest', 'elif', E('elif :<Left><C-R>=EatSpace()<CR>'))
  call IabForFT('*.py,*.ctw,*.tw,*.cinc,*.conf,*.thrift-cvalidator,*.ctest', 'def', E('def :<Left><C-R>=EatSpace()<CR>'))

  " Java
  call IabForFT('*.java', 'imp', 'import')

  " Comment Blocks
  call IabForFT('*.php,*.phpt,*.cpp,*.h,*.c,*.java', '///', E('////////////////////////////////////////////////////////////////////////////////<CR> <C-R>=EatSpace()<CR>'))
  call IabForFT('*.lua,*.sql', '---', E('--------------------------------------------------------------------------------<CR> <C-R>=EatSpace()<CR>'))
  call IabForFT('*.py,*.ctw,*.tw,Makefile*,TARGETS,*.sh,.bashrc,*.thrift,*.cinc,*.cconf', '###', E('################################################################################<CR># <C-R>=EatSpace()<CR>'))

endif " End file type abbreviations

" Custom indent function for cpp
function! CustomCppIndent()
  let l:cline_num = line('.')
  let l:pline_num = prevnonblank(l:cline_num - 1)
  let l:pline = getline(l:pline_num)
  let l:retv = cindent('.')
  while l:pline =~# '\(^\s*{\s*\|^\s*//\|^\s*/\*\|\*/\s*$\)'
    let l:pline_num = prevnonblank(l:pline_num - 1)
    let l:pline = getline(l:pline_num)
  endwhile

  " Don't indent after a namespace
  if l:pline =~# '^\s*namespace.*'
    let l:retv = 0
  endif

	" Only indent by one space after a public/private/protected
  if getline(l:cline_num) =~# '^\s*\(public\|private\|protected\):\s*$'
    let l:retv = 1
  endif

  return l:retv
endfunction
autocmd BufReadPre,BufNewFile *.h,*.cc,*.cu.cc,*.h,*.cpp setlocal indentexpr=CustomCppIndent()

" Python Settings
function! DoPythonSettings()
  setlocal softtabstop=4
  setlocal tabstop=4
  setlocal shiftwidth=4

  " Remove whitespace before and after brackets
  silent! %s/\([^ #]\)[ ]\+)/\1)/g
  silent! %s/([ ]\+\([^ ]\)/(\1/g
  silent! %s/\([^ #]\)[ ]\+\]/\1]/g
  silent! %s/\[[ ]\+\([^ ]\)/[\1/g

  " Fix Dictionary lint
  silent! %s/\("\|'\)[ ]\+:[ ]*\([^ ]\)/\1: \2/g
  silent! %s/\("\|'\)[ ]*: [ ]\+\([^ ]\)/\1: \2/g

  " Fix iterator lint
  silent! %s/^\([ ]*for [^ ]\+,\)\([^ ]\+ in\)/\1 \2/g

  setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

  " Re-indent file
  " silent! gg=G
  " silent! %s/    \(}\|)\|]\)/\1/g
  " silent! %s/ ??????

  " Separate Simple* charts
  " %s/\(}),\)\n\([ ]*[^ \]]\)/\1\r\r\2/g

  " Comment and uncomment
  command! -range C <line1>,<line2> s/\(.*\)/#\1/g
  command! -range U <line1>,<line2> s/\(\s*\)#\(.*\)/\1\2/g
endfunction
autocmd BufEnter *.py call DoPythonSettings()

function! DoVimSettings()
  " Comment and uncomment
  command! -range C <line1>,<line2> s/\(.*\)/"\1/g
  command! -range U <line1>,<line2> s/[ ]*"\(.*\)/\1/g
endfunction
autocmd! BufEnter *.vim,*.vimrc call DoVimSettings()

" Syntax Highlighting on
syntax on
