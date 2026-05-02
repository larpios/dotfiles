let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

nnoremap <leader>pi :PlugInstall<cr>

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" LSP related
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-vinegar'
Plug 'liuchengxu/vim-which-key'

call plug#end() 

" Catppuccin 
colorscheme catppuccin_mocha
let g:airline_theme = 'catppuccin_mocha'
let g:airline#extensions#tabline#enabled = 1

" fzf

" Initialize fzf configuraion dictionary
let g:fzf_vim = {}
nnoremap <leader>ff :Files<cr>
nnoremap <leader>gg :Rg<cr>
nnoremap <leader>fr :History<cr>

" nerdtree
nnoremap <leader>tt :NERDTreeToggle<cr>

" coc
let g:coc_disable_startup_warning = 1


" whichkey
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
