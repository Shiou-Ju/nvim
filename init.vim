if exists('g:vscode')
    " 在 VSCode 中運行，將折疊快捷鍵綁定到 VSCode 的折疊命令
    nnoremap zc :call VSCodeNotify('editor.fold')<CR>
    nnoremap zo :call VSCodeNotify('editor.unfold')<CR>
else
    " 在普通 Neovim 中運行
    set relativenumber
    inoremap jj <Esc>
    nnoremap zc :foldclose<CR>
    nnoremap zo :foldopen<CR>
endif


