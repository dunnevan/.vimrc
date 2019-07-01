" Evan Dunn

" ===================== Debug ======================== {{{1
if &compatible | set nocompatible | endif

" let $NVIM_PYTHON_LOG_FILE="/tmp/nvim_log"
" let $NVIM_PYTHON_LOG_LEVEL="DEBUG"

" let g:python3_host_prog = '/Users/evan/.pyenv/versions/neovim3/bin/python3'

" ================ General Config ==================== {{{1
set encoding=utf-8
set nomodeline 
set mouse=a
set number
set relativenumber
set hidden
set shortmess+=c " don't give |ins-completion-menu| messages.
set signcolumn=yes " more message space
set cmdheight=2

filetype plugin on
filetype indent on
syntax enable

set spell spelllang=en_us
set spellcapcheck= " disables capitalization check
syntax spell toplevel 

"set autoindent
"set expandtab 

" =================== Key Maps ======================= {{{1
" leader b lists buffers and waits for input
nnoremap <Leader>b :ls<CR>:b<Space>
" system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>p "+p
vnoremap <leader>p "+p
" esc to exit terminal mode
tnoremap <Esc> <C-\><C-n>\|<C-W><C-P>
tnoremap <leader><Esc> <C-\><C-n>
" intuitive vim pane navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" ============== Plugin Autoinstall ================== {{{1
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ==================== Plugins ======================= {{{1

call plug#begin('~/.vim/plugged')

" === Status line
Plug 'vim-airline/vim-airline'
let g:airline_detect_spell=0
" === Search
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" === Completion
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}
let g:coc_global_extensions=['coc-snippets']
let g:coc_snippet_next = '<tab>'
" === Snippets
Plug 'kentaroi/ultisnips-swift'
Plug 'honza/vim-snippets'
" === REPL motions
Plug 'Vigemus/iron.nvim'
" === Syntax highlighting
Plug 'jph00/swift-apple'
Plug 'Zaptic/elm-vim' " not maintained elm 0.19 Plug 'elmcast/elm-vim'
" === Color Schemes
Plug 'tomasiser/vim-code-dark'
" === Environment
Plug 'lambdalisue/vim-pyenv'
let g:pyenv#auto_activate=0

call plug#end()

"" color theme config
if (has("termguicolors"))
    " set termguicolors
endif

" ================== Color Scheme ===================== {{{1
if has('nvim') && !empty(glob('~/.vim/plugged/vim-code-dark'))
    set background=dark
    colorscheme codedark
    let g:airline_theme = 'codedark'
endif

" ===================== More ========================= {{{1

"" auto install coc.nvim
if empty(glob('~/.vim/plugged/coc.nvim'))
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


"" config iron.nvim
if has('nvim') && !empty(glob('~/.vim/plugged/iron.nvim'))
    " nvim specific things
    exec 'lua require("iron").core.add_repl_definitions{python = {python = {command = {"python3"} } }, swift = {swift = {command = {"swift"} } } }'
    exec 'lua require("iron").core.set_config{repl_open_cmd = "rightbelow vsplit"}'
endif

"" tab completion config
"inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"" coc.nvim config

" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? coc#rpc#request('doKeymap', ['snippets-expand-jump','']) :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

"" BufEnter terminal
autocmd BufWinEnter,WinEnter term://* startinsert

" Modeline magic if allowed
" vim:foldmethod=marker:foldlevel=0