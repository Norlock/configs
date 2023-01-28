" Use ZZ (quit and save) us ZQ (quit no save)
call plug#begin('~/.local/share/nvim/plugged')
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'ap/vim-css-color'
Plug 'justinmk/vim-dirvish'
Plug 'justinmk/vim-sneak'
Plug 'godlygeek/tabular' " Surrounds around tabs 

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'kyazdani42/nvim-web-devicons'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" TSX
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

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
set fileencoding=utf-8
set encoding=utf-8
set wildmode=longest:full
set hidden " Allow switching buffers even if not written
set mouse=a

set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Buffers
nmap Zc <Esc>:bw<Cr>

" Clipboard
nmap <Leader>p "+
vmap <Leader>p "+

"---- Search ----
set smartcase
set ignorecase

" Clean search highlighting
nnoremap <silent> <Esc> :nohlsearch<Cr>

" Remap escape
inoremap jj <Esc>

" Quickfix
"map <C-j> :cn<CR>
"map <C-k> :cp<CR>

nmap <silent> _ :move -2<Cr> 
nmap <silent> + :move +1<Cr> 

imap <C-s> <Esc>:w<Cr>a
nmap <C-s> :w<Cr>

nmap <silent> <Leader>v :vsplit<Cr>

" set filetypes as typescriptreact
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact 

" WLSL
autocmd! BufNewFile,BufRead *.wgsl set filetype=wgsl

let g:typescript_indent_disable = 1

" Navigation
nnoremap <Leader>f <cmd>lua require'telescope.builtin'.find_files{}<CR>
nnoremap <Leader>g <cmd>lua require'telescope.builtin'.git_files{}<CR>
nnoremap <Leader>s <cmd>lua require'telescope.builtin'.git_status{}<CR>
nnoremap <Leader>a <cmd>lua require'telescope.builtin'.live_grep{}<CR>
nnoremap <Leader>l <cmd>lua require'telescope.builtin'.builtin{}<CR>
nnoremap <Leader>b <cmd>lua require'telescope.builtin'.buffers{}<CR>

" Documentation
nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>


" Switch between panes with alt
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" To use `ALT+{h,j,k,l}` to navigate windows from any mode:
tnoremap <A-Left> <C-\><C-n><C-w>h
tnoremap <A-Down> <C-\><C-n><C-w>j
tnoremap <A-Up> <C-\><C-n><C-w>k
tnoremap <A-Right> <C-\><C-n><C-w>l
inoremap <A-Left> <C-\><C-n><C-w>h
inoremap <A-Down> <C-\><C-n><C-w>j
inoremap <A-Up> <C-\><C-n><C-w>k
inoremap <A-Right> <C-\><C-n><C-w>l
nnoremap <A-Left> <C-w>h
nnoremap <A-Down> <C-w>j
nnoremap <A-Up> <C-w>k
nnoremap <A-Right> <C-w>l

set splitright " Splits pane to the right
set splitbelow " Splits pane below

lua require("custom_telescope")
lua require("nvim_cmp")

autocmd BufWinEnter,WinEnter term://* startinsert
nmap <silent> <leader>ts :vsplit<CR>:terminal<CR>i
nmap <silent> <leader>tt :tabe<CR>:terminal<CR>i
nmap <silent> <leader>tr :terminal<CR>i

tmap <leader><esc> <c-\><c-n><esc>
tmap <leader>e exit<cr>
"tmap nvim *<cr> <c-\><c-n>
nmap <leader>e i<esc>:bw<CR>

" Expand
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<Cr>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<Cr>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" possible value: 'UltiSnips', 'Neosnippet', 'vim-vsnip', 'snippets.nvim'
let g:completion_enable_snippet = 'vim-vsnip'

" Easymotion like tags
let g:sneak#label = 1

" Markdown
let g:previm_open_cmd = 'brave-browser'

" Easy nvim config
nmap <Leader>n :tabedit ~/.config/nvim/init.vim<Cr>
