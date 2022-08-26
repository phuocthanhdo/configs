" References:
" - https://github.com/sharksforarms/neovim-rust/blob/master/neovim-init-lsp.vim
" - https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.vim

" Prerequisites:
" - neovim >= 0.7
" - rust-analyzer: https://rust-analyzer.github.io/manual.html#rust-analyzer-language-server-binary

" Steps:
" - :PlugInstall
" - Restart

call plug#begin('~/.vim/plugged')

" Collection of common configurations for the Nvim LSP client
Plug 'neovim/nvim-lspconfig'

" Extentions to built-in LSP, for example, providing type inlay hints
Plug 'nvim-lua/lsp_extensions.nvim'

" Autocompletion framework
Plug 'hrsh7th/nvim-cmp'
" cmp LSP completion
Plug 'hrsh7th/cmp-nvim-lsp'
" cmp Path completion
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
" Show fn signatures when typing
Plug 'ray-x/lsp_signature.nvim'

" Only because nvim-cmp _requires_ snippets
" Should be removed
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-vsnip'

" Rust lang
Plug 'rust-lang/rust.vim'

" GUI enhancements
Plug 'machakann/vim-highlightedyank'
Plug 'itchyny/lightline.vim'
Plug 'joshdick/onedark.vim'

" Fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'airblade/vim-gitgutter'

call plug#end()
set background=dark
colorscheme onedark

" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Avoid showing extra messages when using completion
set shortmess+=c

" have a fixed column for the diagnostics to appear in
" this removes the jitter when warnings/errors flow in
set signcolumn=yes

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300

" =============================================================================
" # Editor settings
" =============================================================================
filetype plugin indent on
set autoindent
set timeoutlen=300 " http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
set encoding=utf-8
set scrolloff=2
set noshowmode
set hidden
set nowrap
set nojoinspaces

set diffopt+=iwhite " No whitespace in vimdiff
" Make diffing better: https://vimways.org/2018/the-power-of-diff/
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic


set clipboard+=unnamedplus " Copy to system clipboard by 'yy'

" Sane splits
set splitright
set splitbelow
" =============================================================================
" # GUI settings
" =============================================================================
set ttyfast
set number
set relativenumber
set showcmd
set mouse=a
set laststatus=2

set printfont=:h10
set printencoding=utf-8
set printoptions=paper:letter
" Always draw sign column. Prevent buffer moving when adding/deleting sign.
set signcolumn=yes
" Rust format
au Filetype rust set colorcolumn=100

" =============================================================================
" # Keyboard shortcuts
" =============================================================================
let mapleader = "\<Space>"

" Keyboard shortcuts
nnoremap ; :

" Left and right can switch buffers
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>

" Open hotkeys
map <A-p> :Files<CR>
nmap <A-;> :Buffers<CR>


" =============================================================================
" # LSP Completion configuration
" =============================================================================
" https://github.com/hrsh7th/nvim-cmp#basic-configuration
lua << END
local cmp = require'cmp'
local lspconfig = require'lspconfig'

cmp.setup({
  snippet = {
    -- REQUIRED by nvim-cmp. get rid of it once we can
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    -- Enter immediately completes. Tab/S-Tab to select.
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true })
  },
  -- Sources for suggestions
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
  },
})
END

" =============================================================================
" # LSP Keyboard shortcuts
" =============================================================================
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>

nnoremap <silent> <space>D   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> <space>a   <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <space>e   <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <silent> <space>f   <cmd>lua vim.lsp.buf.formatting()<CR>

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>

command Cb ! cargo build
command Ct ! cargo test
nnoremap <Leader>ct :! cargo test<CR>
nnoremap <Leader>cb :! cargo build<CR>

" =============================================================================
" # Rust Analyzer Configuration
" =============================================================================
lua << END
local lspconfig = require'lspconfig'
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      completion = {
	postfix = {
	  enable = false,
	},
      },
    },
  },
  capabilities = capabilities,
}

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
END

" Enable type inlay hints
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }

