if exists('g:vscode')
    " 在 VSCode 中運行，將折疊快捷鍵綁定到 VSCode 的折疊命令
    nnoremap zc :call VSCodeNotify('editor.fold')<CR>
    nnoremap zo :call VSCodeNotify('editor.unfold')<CR>
    imap <silent> jj <Esc> " 修改這一行，使 jj 在 VSCode 中也能退出插入模式
else
    " 在普通 Neovim 中運行
    set relativenumber
    inoremap jj <Esc>
    nnoremap zc :foldclose<CR>
    nnoremap zo :foldopen<CR>

    " 視窗導航映射
	nnoremap <C-h> <C-w>h
	nnoremap <C-j> <C-w>j
	nnoremap <C-k> <C-w>k
	nnoremap <C-l> <C-w>l
endif


