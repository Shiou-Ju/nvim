-- 領導鍵（Leader Key）解釋
-- 領導鍵是 Vim/Neovim 中用於觸發一系列自定義快捷命令的特殊按鍵。它允許您創建多層次的快捷鍵組合，避免與內建命令衝突。預設的領導鍵是反斜線（\），但大多數使用者會將其設定為空格鍵，因為空格鍵位置容易按到且不常用於其他命令。
-- 例如，設定空格為領導鍵後，您可以使用 <space>ff 來啟動檔案搜尋，使用 <space>fg 來啟動內容搜尋等。


-- 設定空格鍵為領導鍵
vim.g.mapleader = " "


-- 初始化 lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 保留原有的設定
if vim.g.vscode then
    vim.keymap.set('n', 'zc', ":call VSCodeNotify('editor.fold')<CR>")
    vim.keymap.set('n', 'zo', ":call VSCodeNotify('editor.unfold')<CR>")
    vim.keymap.set('i', 'jj', '<Esc>')
else
    vim.opt.relativenumber = true
    vim.keymap.set('i', 'jj', '<Esc>')
    vim.keymap.set('n', 'zc', ':foldclose<CR>')
    vim.keymap.set('n', 'zo', ':foldopen<CR>')
    vim.keymap.set('n', '<C-h>', '<C-w>h')
    vim.keymap.set('n', '<C-j>', '<C-w>j')
    vim.keymap.set('n', '<C-k>', '<C-w>k')
    vim.keymap.set('n', '<C-l>', '<C-w>l')

    -- 縮排
    -- 在插入模式下使用 Tab 進行縮排
    vim.keymap.set('i', '<Tab>', '<C-t>', { desc = '縮排', noremap = true })

    -- 在普通模式和視覺模式下使用 Tab 進行縮排
    vim.keymap.set('n', '<Tab>', '>>', { desc = '縮排', noremap = true })
    vim.keymap.set('v', '<Tab>', '>gv', { desc = '縮排並保持選擇', noremap = true })

    -- 反縮排
    -- 在插入模式下使用 Shift+Tab 進行反縮排
    vim.keymap.set('i', '<S-Tab>', '<C-d>', { desc = '反縮排', noremap = true })

    -- 在普通模式和視覺模式下使用 Shift+Tab 進行反縮排
    vim.keymap.set('n', '<S-Tab>', '<<', { desc = '反縮排', noremap = true })
    vim.keymap.set('v', '<S-Tab>', '<gv', { desc = '反縮排並保持選擇', noremap = true })



    -- 自訂 zt 命令，保留 3 行緩衝
    vim.keymap.set(
      'n',                -- 在普通模式(normal mode)下生效
      'zt',               -- 重新定義 zt 按鍵組合
      function()          -- 定義按下 zt 時要執行的函數
        vim.cmd('normal! zt')  -- 先執行原始的 zt 命令，將當前行移到視窗頂部
             -- normal! 中的 ! 確保使用 Vim 內建命令而非用戶自定義命令
        
        vim.cmd('execute "normal! 3\\<C-y>"')  -- 向上滾動 3 行
                 -- execute 用於執行字串作為命令
                 -- 3 表示重複 <C-y> 三次
                 -- <C-y> 是 Vim 中向上滾動一行的命令
                 -- 雙反斜線 \\ 用於在 Lua 字串中逸出反斜線
      end,
      { desc = '將當前行置頂並保留 3 行緩衝' }  -- 為這個映射提供描述，方便將來查看
    )


    -- Telescope 快捷鍵設定
    vim.keymap.set('n', '<leader>ff', function()
      require('telescope.builtin').find_files()
    end, { desc = '搜尋檔案' })
    
    vim.keymap.set('n', '<leader>fg', function()
      require('telescope.builtin').live_grep()
    end, { desc = '搜尋文字內容' })
    
    vim.keymap.set('n', '<leader>fb', function()
      require('telescope.builtin').buffers()
    end, { desc = '搜尋緩衝區' })
    
    vim.keymap.set('n', '<leader>fh', function()
      require('telescope.builtin').help_tags()
    end, { desc = '搜尋幫助文檔' })

    vim.keymap.set('n', '<leader>@', function()
      require('telescope.builtin').current_buffer_fuzzy_find()
    end, { desc = '模糊搜尋當前緩衝區' })


end



-- 基本設定
vim.opt.termguicolors = true  -- 啟用終端真彩色支援
vim.cmd('syntax enable')      -- 啟用語法高亮
vim.cmd('filetype plugin indent on')  -- 啟用檔案類型偵測

-- 載入插件
require("lazy").setup({
  -- 顏色方案
	  {
	  "folke/tokyonight.nvim",
	  lazy = false,
	  priority = 1000,  -- 確保它先載入
	  config = function()
	    require("tokyonight").setup({
	      style = "night",
	      styles = {
		-- 禁用所有斜體樣式 do
		comments = { italic = false },
		keywords = { italic = false },
		functions = { italic = false },
		variables = { italic = false },
		-- 禁用所有斜體樣式 end
		sidebars = "dark",
		floats = "dark",
	      },
	    })
	    vim.cmd('colorscheme tokyonight-night')  -- 套用顏色方案
		-- 讓 git commit 註解變比較明顯
		vim.api.nvim_create_autocmd("ColorScheme", {
		  pattern = "*",
		  callback = function()
		    -- 設定註解的顏色（無斜體但顏色更鮮明）
		    vim.api.nvim_set_hl(0, "Comment", { fg = "#7a88cf", italic = false })
		    vim.api.nvim_set_hl(0, "gitcommitComment", { fg = "#7a88cf", italic = false })
		  end
		})
	  end,
	},
  -- Markdown 支援
  {
    "preservim/vim-markdown",
    ft = "markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_strikethrough = 1
      vim.g.vim_markdown_new_list_item_indent = 2
      vim.g.vim_markdown_toc_autofit = 1
    end,
  },
    -- Telescope - 模糊搜尋工具
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- 可選，提供檔案圖示
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git" },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })
    end,
  },
   -- LSP 基本配置
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- 設定 mason
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "jdtls" },  -- 確保安裝 Java LSP
      })

      -- 設定 LSP 按鍵映射
      local on_attach = function(_, bufnr)
        -- 顯示錯誤信息
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = '顯示錯誤信息', buffer = bufnr })
        -- 跳到下一個錯誤
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = '前一個錯誤', buffer = bufnr })
        -- 跳到上一個錯誤
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = '下一個錯誤', buffer = bufnr })
      end

      -- 配置 Java LSP
      require('lspconfig').jdtls.setup({
        on_attach = on_attach,
      })

      -- 配置錯誤顯示
      vim.diagnostic.config({
        virtual_text = true,      -- 在代碼旁邊顯示錯誤
        signs = true,             -- 在行號旁顯示錯誤標記
        underline = true,         -- 在錯誤下方加底線
        update_in_insert = false, -- 不在插入模式時更新錯誤
        severity_sort = true,     -- 按嚴重性排序錯誤
      })
    end,
  },
  -- 會顯示哪邊在 git 有變動
  {
  "lewis6991/gitsigns.nvim",
  config = function()
    require('gitsigns').setup({
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        
        -- 導航變更
        vim.keymap.set('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true, buffer=bufnr})
        
        vim.keymap.set('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true, buffer=bufnr})
        
        -- 查看變更的 diff
        vim.keymap.set('n', '<leader>gd', gs.preview_hunk, {buffer=bufnr, desc = '預覽變更'})
        
        -- 暫存和復原變更
        vim.keymap.set('n', '<leader>gs', gs.stage_hunk, {buffer=bufnr, desc = '暫存變更'})
        vim.keymap.set('n', '<leader>gr', gs.reset_hunk, {buffer=bufnr, desc = '復原變更'})
      end
    })
  end
}
})





-- ======================================================
-- 中文顯示問題解決方案（最簡配置）
-- ======================================================

-- 設定東亞寬度字符（如中文、日文、韓文）的顯示寬度為兩倍英文字符寬度
-- 原理：中文等字符在終端中通常佔用兩個字符位置，設為 double 確保編輯器正確計算字符寬度
-- 解決：防止中文字符重疊、錯位或顯示不完整的問題
vim.opt.ambiwidth = "double"  -- 處理中文字符寬度

-- 啟用文本自動換行功能，使長行文本在到達視窗邊緣時自動換行顯示
-- 原理：當文本行長度超過編輯器視窗寬度時，自動進行視覺上的換行
-- 解決：避免需要水平滾動來查看超長文本，提高閱讀舒適度
vim.opt.wrap = true           -- 啟用自動換行

-- 控制文本換行的方式，在單詞邊界處進行換行而非任意位置
-- 原理：換行優先在空格、標點等單詞邊界處發生，而不是切斷單詞中間
-- 解決：提高換行後文本的可讀性，避免單詞被隨機分割
vim.opt.linebreak = true      -- 在單詞邊界處換行

-- 設定換行標記為空，完全移除視覺上的換行標記符號
-- 原理：預設情況下，Neovim 可能在換行處顯示 ">" 等標記，表示該行是上一行的延續
-- 解決：清除這些可能造成干擾的視覺標記，讓文本顯示更加整潔
vim.opt.showbreak = ""        -- 移除換行標記符號


-- other settings
vim.opt.list = false          -- 關閉不可見字符的顯示
-- vim.opt.fillchars = "eob: "   -- 設定緩衝區末尾空行標記為空格
vim.opt.listchars = ""  -- 清空所有特殊字符的顯示符號

---- 其他有助於改善顯示的設定
-- vim.opt.display = "lastline"  -- 顯示超長行的最大部分
-- vim.opt.sidescroll = 1        -- 水平滾動時一次移動一個字符

-- 設定智能大小寫（如果搜尋詞中包含大寫字母，則變為區分大小寫）
vim.opt.ignorecase = true  -- 不區分大小寫
-- 上面那個要打開，下面才會生效
vim.opt.smartcase = true   -- 如果包含大寫字母，則自動切換為區分大小寫


---- 設定 indent
-- 設定縮排為 2 個空格
vim.opt.shiftwidth = 2

-- 設定 Tab 鍵等同的空格數
vim.opt.tabstop = 2

-- 讓 Tab 鍵產生空格而非真正的 Tab 字元
vim.opt.expandtab = true

-- 在插入模式下使用 Tab 時，插入 'shiftwidth' 指定的空格數
vim.opt.smarttab = true

-- 自動縮排，保持與上一行相同的縮排級別
vim.opt.autoindent = true


-- 設定換行時不顯示任何標記
-- vim.cmd([[autocmd VimEnter,BufEnter * set showbreak=]])
vim.cmd([[
  autocmd VimEnter,BufEnter,BufReadPost * set showbreak= nolist listchars=
]])










