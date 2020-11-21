" Use ZZ (quit and save) us ZQ (quit no save)
call plug#begin('~/.local/share/nvim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
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
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'kyazdani42/nvim-web-devicons'

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
set cursorline    " Highlight current line
set scrolloff=3 " Always leave lines down
set tw=120 " Set textwidth 
set pastetoggle=<F2>
set fileencoding=utf-8
set encoding=utf-8

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

nmap <silent> J :move +1<Cr> 
nmap <silent> K :move -2<Cr> 

imap <C-s> <Esc>:w<Cr>a
nmap <C-s> :w<Cr>

" press F4 to fix indentation in whole file; overwrites marker 'q' position
noremap <F4> mqggVG=`qzz
inoremap <F4> <Esc>mqggVG=`qzza

" Navigation
"nmap <Tab> :tabnext<Cr>
"nmap <S-Tab> :tabprevious<Cr>
"nmap <Leader>f :FZF<Cr>
"nmap <Leader>g :GitFiles<Cr>
"nmap <Leader>b :Buffers<Cr>
"nmap <Leader>l :Locate 
"nmap <Leader>a :Rg<Cr>
"nmap <silent> <Leader>b :Buffers<Cr>
nnoremap <Leader>w :w !sudo tee %<Cr>

nnoremap <Leader>f <cmd>lua require'telescope.builtin'.find_files{}<CR>
nnoremap <Leader>g <cmd>lua require'telescope.builtin'.git_files{}<CR>
nnoremap <Leader>a <cmd>lua require'telescope.builtin'.live_grep{}<CR>
nnoremap <silent> gr <cmd>lua require'telescope.builtin'.lsp_references{}<CR>
"nnoremap <Leader>tb <cmd>lua require'telescope.builtin'.builtin{}<CR>
nnoremap <Leader>b <cmd>lua require'telescope.builtin'.buffers{}<CR>

nmap [[ :bp<Cr> 
nmap ]] :bn<Cr> 

let g:gutentags_file_list_command = 'rg --files'

" Switch between panes with alt
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>
nmap <silent> <A-k> :wincmd k<CR>
nmap <silent> <A-j> :wincmd j<CR>
nmap <silent> <A-h> :wincmd h<CR>
nmap <silent> <A-l> :wincmd l<CR>

set splitright " Splits pane to the right
set splitbelow " Splits pane below

set hidden " Allow switching buffers even if not written

let g:fzf_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-h': 'split',
            \ 'ctrl-v': 'vsplit' }

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" Use completion-nvim in every buffer
autocmd BufEnter * lua require'completion'.on_attach()
lua require'lspconfig'.tsserver.setup{}
lua require'lspconfig'.html.setup{}
lua require'lspconfig'.cssls.setup{}
lua require'lspconfig'.jsonls.setup{}
lua require'lspconfig'.vimls.setup{}

" TODO completion buffers fixen
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <Leader>q <cmd>lua vim.lsp.buf.code_action()<CR>

lua <<EOF
require'nvim-treesitter.configs'.setup {
    -- Modules and its options go here
    highlight = { enable = true },
    incremental_selection = { enable = true },
    refactor = {
        highlight_definitions = { enable = true },
        smart_rename = { enable = true },
        navigation = { enable = true },
    },
    textobjects = { enable = true },
}
EOF

lua <<EOF
completion_chain_complete_list = {
  { complete_items = { 'lsp' } },
  { complete_items = { 'buffers' } },
  { mode = { '<c-p>' } },
  { mode = { '<c-n>' } }
}
EOF

" Disable normal mode on exit
lua <<EOF
local actions = require('telescope.actions')

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        -- Disable the default <c-x> mapping
        ["<c-x>"] = false,

        -- Create a new <c-s> mapping
        ["<c-s>"] = actions.goto_file_selection_split,
        ["<Esc>"] = actions.close
      },
    },
  }
}
EOF

lua require'nvim-web-devicons'.setup()

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

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert

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
