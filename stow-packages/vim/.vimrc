set shell="/bin/zsh"
set tabstop=4

nnoremap n h
nnoremap N H
nnoremap e j
nnoremap E J
nnoremap i k
nnoremap I K
nnoremap o l
nnoremap O L
nnoremap h i
nnoremap H I
nnoremap k o
nnoremap K O
nnoremap l e
nnoremap L E
nnoremap j n
nnoremap J N
nnoremap <c-n> <c-h>
nnoremap <c-e> <c-j>
"nnoremap <c-i> <c-k>
nnoremap \x33[105;5u <c-k>
nnoremap <c-o> <c-l>
nnoremap <c-h> <c-n>
nnoremap <c-j> <c-e>
nnoremap <c-k> <c-i>
nnoremap <c-l> <c-o>
vnoremap n h
vnoremap N H
vnoremap e j
vnoremap E J
vnoremap i k
vnoremap I K
vnoremap o l
vnoremap O L
vnoremap h i
vnoremap H I
vnoremap k o
vnoremap K O
vnoremap l e
vnoremap L E
vnoremap j n
vnoremap J N
vnoremap <c-n> <c-h>
vnoremap <c-e> <c-j>
"vnoremap <c-i> <c-k>
vnoremap \x33[105;5u <c-k>
vnoremap <c-o> <c-l>
vnoremap <c-h> <c-n>
vnoremap <c-j> <c-e>
vnoremap <c-k> <c-i>
vnoremap <c-l> <c-o>

" Enable true colors if available
set termguicolors
"colorscheme gruvbox

" Enable italics. Make sure this is immediately after colorscheme
" https://stackoverflow.com/questions/3494435/vimrc-make-comments-italic
highlight Comment cterm=italic gui=italic
