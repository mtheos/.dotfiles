set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'tikhomirov/vim-glsl'
Plugin 'dense-analysis/ale'
Plugin 'leafgarland/typescript-vim'
Plugin 'udalov/kotlin-vim'

call vundle#end()
filetype plugin indent on

autocmd! BufNewFile,BufRead *.vs,*.fs,*.glsl set ft=glsl
set number relativenumber
set printoptions=number:y
set tabstop=2
set shiftwidth=2
set expandtab
syntax on
set background=dark
color molokai
cnoremap sudow w !sudo tee % >/dev/null
