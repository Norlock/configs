" Use ZZ (quit and save) us ZQ (quit no save)
call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'ap/vim-css-color'
Plug 'justinmk/vim-dirvish'
Plug 'justinmk/vim-sneak'
Plug 'godlygeek/tabular' " Surrounds around tabs 
Plug 'ludovicchabant/vim-gutentags'

" Snippets are separated from the engine. Add this if you want them:
Plug 'honza/vim-snippets'

" Nvim 5.0
Plug 'nvim-lua/completion-nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'kyazdani42/nvim-web-devicons'

" Vim rooter
Plug 'airblade/vim-rooter'

" Themes
Plug 'itchyny/lightline.vim'
Plug 'ayu-theme/ayu-vim' 

" Markdown
Plug 'kannokanno/previm'

" Initialize plugin system
call plug#end()

"---- Theme ----
set termguicolors
set background=dark
let ayucolor="dark" 
colorscheme ayu

let g:lightline = {
            \ 'colorscheme': 'ayu',
            \ }

" Highlight current line
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE
highlight LineNr ctermbg=NONE guibg=NONE

filetype plugin indent on
set autoindent smartindent    " turns it on
set number relativenumber " Number on the line relative number above below.
set tabstop=4 softtabstop=4 expandtab shiftwidth=4 
set noshowmode		" Hide extra line to show the curent mode
set noswapfile
set cursorline    " Highlight current line
set scrolloff=3 " Always leave lines down
set tw=120 " Set textwidth 
set pastetoggle=<F2>
set fileencoding=utf-8
set encoding=utf-8
set wildmode=longest:full
set hidden " Allow switching buffers even if not written

" Buffers
nmap Zc <Esc>:bw<Cr>

" Clipboard
nmap <Leader>p "+
vmap <Leader>p "+

"---- Search ----
set smartcase

" Clean search highlighting
nnoremap <silent> <Esc> :nohlsearch<Cr>

" Remap escape
inoremap jj <Esc> 

" Quickfix
map <C-j> :cn<CR>
map <C-k> :cp<CR>

nmap <silent> _ :move -2<Cr> 
nmap <silent> + :move +1<Cr> 

imap <C-s> <Esc>:w<Cr>a
nmap <C-s> :w<Cr>

" press F4 to fix indentation in whole file; overwrites marker 'q' position
noremap <F4> mqggVG=`qzz
inoremap <F4> <Esc>mqggVG=`qzza

nnoremap Y y$

" Navigation
nnoremap <Leader>f <cmd>lua require'telescope.builtin'.find_files{}<CR>
nnoremap <Leader>g <cmd>lua require'telescope.builtin'.git_files{}<CR>
nnoremap <Leader>s <cmd>lua require'telescope.builtin'.git_status{}<CR>
nnoremap <Leader>a <cmd>lua require'telescope.builtin'.live_grep{}<CR>
nnoremap <Leader>l <cmd>lua require'telescope.builtin'.builtin{}<CR>
nnoremap <Leader>b <cmd>lua require'telescope.builtin'.buffers{}<CR>

nnoremap <silent> gr <cmd>lua require'telescope.builtin'.lsp_references{}<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K  <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <Leader>q <cmd>lua vim.lsp.buf.code_action()<CR>

nmap [[ :bp<Cr> 
nmap ]] :bn<Cr> 

let g:gutentags_file_list_command = 'rg --files'

" Switch between panes with alt
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" To use `ALT+{h,j,k,l}` to navigate windows from any mode:
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

tmap <silent> <A-Up> <A-k>
tmap <silent> <A-Down> <A-j>
tmap <silent> <A-Left> <A-h>
tmap <silent> <A-Right> <A-l>

set splitright " Splits pane to the right
set splitbelow " Splits pane below

lua require("custom_lua")

command LSPInstall :vsplit term://sudo lua ~/.config/nvim/lua/install_lsp.lua<CR>i

autocmd BufWinEnter,WinEnter term://* startinsert
nmap <silent> <leader>ts :vsplit<CR>:terminal<CR>i
nmap <silent> <leader>tt :tabe<CR>:terminal<CR>i

tmap <leader><esc> <c-\><c-n>
tmap <leader>e i<esc>:bw!<CR>
nmap <leader>e i<esc>:bw<CR>

tmap <silent> <A-Up> <esc>:wincmd k<CR>
tmap <silent> <A-Down> <esc>:wincmd j<CR>
tmap <silent> <A-Left> <esc>:wincmd h<CR>
tmap <silent> <A-Right> <esc>:wincmd l<CR>

" Expand
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<Cr>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<Cr>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
"imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
"smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
"imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
"smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" map <c-p> to manually trigger completion
inoremap <silent><expr> <c-space> completion#trigger_completion()

" possible value: 'UltiSnips', 'Neosnippet', 'vim-vsnip', 'snippets.nvim'
let g:completion_enable_snippet = 'vim-vsnip'

" Easymotion like tags
let g:sneak#label = 1

" Markdown
let g:previm_open_cmd = 'firefox'

" Easy nvim config
nmap <Leader>n :tabedit ~/.config/nvim/init.vim<Cr>
