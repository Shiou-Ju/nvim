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
    -- 導航切換視窗 
    vim.keymap.set('n', '<leader>h', '<C-w>h', { desc = '向左切換視窗' })
    vim.keymap.set('n', '<leader>j', '<C-w>j', { desc = '向下切換視窗' })
    vim.keymap.set('n', '<leader>k', '<C-w>k', { desc = '向上切換視窗' })
    vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = '向右切換視窗' })
    -- 專門處理 terminal 的視窗
    vim.keymap.set('t', 'JKL:', '<C-\\><C-n>', { desc = '使用 JKL: 退出終端模式' })
    -- vim.keymap.set('t', 'hjkl', '<C-\\><C-n>', { desc = '使用 hjkl 退出終端模式' })
   
    
    
    -- <C-\\><C-n>: 先從終端模式退出到普通模式
    -- 使用 double leader (連續兩次空格) 作為終端導航前綴
    -- vim.keymap.set('t', '<leader><leader>h', '<C-\\><C-n><C-w>h', { desc = '從終端向左切換視窗' })
    -- vim.keymap.set('t', '<leader><leader>j', '<C-\\><C-n><C-w>j', { desc = '從終端向下切換視窗' })
    -- vim.keymap.set('t', '<leader><leader>k', '<C-\\><C-n><C-w>k', { desc = '從終端向上切換視窗' })
    -- vim.keymap.set('t', '<leader><leader>l', '<C-\\><C-n><C-w>l', { desc = '從終端向右切換視窗' })
    --

    -- (不好用)使用 Ctrl + Leader (Ctrl + 空格) 作為終端導航前綴
    -- vim.keymap.set('t', '<C-Space>h', '<C-\\><C-n><C-w>h', { desc = '從終端向左切換視窗' })
    -- vim.keymap.set('t', '<C-Space>j', '<C-\\><C-n><C-w>j', { desc = '從終端向下切換視窗' })
    -- vim.keymap.set('t', '<C-Space>k', '<C-\\><C-n><C-w>k', { desc = '從終端向上切換視窗' })
    -- vim.keymap.set('t', '<C-Space>l', '<C-\\><C-n><C-w>l', { desc = '從終端向右切換視窗' })

    -- 因為 空白鍵 在 terminal 很常用，所以不可以
    -- 所以改成 ctrl \ + leader 
    -- 這樣太複雜了，我應該選擇怎麼退出 terminal 模式才對
    -- vim.keymap.set('t', '<C-\\><leader>h', '<C-\\><C-n><C-w>h', { desc = '從終端向左切換視窗' })
    -- vim.keymap.set('t', '<C-\\><leader>j', '<C-\\><C-n><C-w>j', { desc = '從終端向下切換視窗' })
    -- vim.keymap.set('t', '<C-\\><leader>k', '<C-\\><C-n><C-w>k', { desc = '從終端向上切換視窗' })
    -- vim.keymap.set('t', '<C-\\><leader>l', '<C-\\><C-n><C-w>l', { desc = '從終端向右切換視窗' })

    -- 使用 Alt + hjkl 導航 (適用於所有模式，包括終端)
    -- 因為 ctrl + k 等，在 terminal 環境會衝突，所以改用 alt 
    -- 但是 alt 跟 mac 或是 iterm 等會互相衝突，所以暫時棄用
    -- vim.keymap.set({'n', 't'}, '<A-h>', '<C-\\><C-n><C-w>h', { desc = '向左切換視窗' })
    -- vim.keymap.set({'n', 't'}, '<A-j>', '<C-\\><C-n><C-w>j', { desc = '向下切換視窗' })
    -- vim.keymap.set({'n', 't'}, '<A-k>', '<C-\\><C-n><C-w>k', { desc = '向上切換視窗' })
    -- vim.keymap.set({'n', 't'}, '<A-l>', '<C-\\><C-n><C-w>l', { desc = '向右切換視窗' })
    -- 暫時棄用 ctrl 導航視窗
    -- vim.keymap.set('n', '<C-h>', '<C-w>h')
    -- vim.keymap.set('n', '<C-j>', '<C-w>j')
    -- vim.keymap.set('n', '<C-k>', '<C-w>k')
    -- vim.keymap.set('n', '<C-l>', '<C-w>l')

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

    -- +y 是複製到系統的剪貼簿
    vim.keymap.set('v', '<leader>y', '"+y', { desc = '複製到系統剪貼簿', noremap = true })



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

    -- 模擬 VS Code 的 Ctrl + ` 開啟終端功能 do
vim.keymap.set({'n', 'i'}, '<C-`>', function()
  -- 檢查是否已有終端視窗
  local term_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      table.insert(term_buffers, buf)
    end
  end
  
  if #term_buffers > 0 then
    -- 如果已有終端，切換到第一個終端緩衝區
    local windows = vim.api.nvim_list_wins()
    local term_found = false
    
    -- 先檢查是否有顯示終端的視窗
    for _, win in ipairs(windows) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == 'terminal' then
        vim.api.nvim_set_current_win(win)
        term_found = true
        break
      end
    end
    
    -- 如果沒有顯示終端的視窗，開啟一個新的底部終端視窗
    if not term_found then
      vim.cmd('split')
      vim.cmd('wincmd J')  -- 將視窗移到最底部
      vim.cmd('resize 23%')
      vim.cmd('buffer ' .. term_buffers[1])
      vim.cmd('startinsert')
    end
  else
    -- 如果沒有終端，創建一個新的底部終端
    vim.cmd('split')
    vim.cmd('wincmd J')  -- 將視窗移到最底部
    vim.cmd('resize 23%')
    vim.cmd('terminal')
    vim.cmd('startinsert')
  end
end, { desc = 'VS Code 風格終端開關 (Ctrl+`)' })
    -- 模擬 VS Code 的 Ctrl + ` 開啟終端功能 end


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
      pickers = {
        find_files = {
          hidden = true  -- 這裡添加，使 find_files 能夠顯示隱藏檔案
        }
      }
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
        ensure_installed = { 
          "jdtls" ,  --java lsp
          "marksman" --markdown lsp 
        }, 
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
      local java_home = "/opt/homebrew/Cellar/openjdk@21/21.0.6/libexec/openjdk.jdk/Contents/Home"

      -- 檢查並創建 jdtls 工作空間目錄
      local jdtls_workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace")
      local jdtls_workspace_parent = vim.fn.fnamemodify(jdtls_workspace_dir, ":h") -- 獲取父目錄
      if vim.fn.isdirectory(jdtls_workspace_dir) == 0 then
        -- 如果父目錄不存在，先創建父目錄
        if vim.fn.isdirectory(jdtls_workspace_parent) == 0 then
          vim.fn.mkdir(jdtls_workspace_parent, "p")
        end
        -- 創建工作空間目錄
        vim.fn.mkdir(jdtls_workspace_dir, "p")
      end

      -- 配置 marksman
      require('lspconfig').marksman.setup({
        on_attach = on_attach,  -- 使用您現有的 on_attach 函數
      })

      -- 配置 jdtls
      require('lspconfig').jdtls.setup({
        on_attach = on_attach,
        cmd = {
          java_home .. "/bin/java",  -- 明確指定 Java 21 路徑
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.level=ALL",
          "-Xmx1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration", vim.fn.stdpath("data") .. "/mason/packages/jdtls/config_mac",
          "-data", jdtls_workspace_dir .. vim.fn.getcwd(),
        },
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
} ,
    -- markdownlint into vim
    {
      "mfussenegger/nvim-lint",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
        require('lint').linters_by_ft = {
          markdown = {'markdownlint'}
        }
        
        -- 自動執行 lint，在檔案打開和保存時檢查
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
          callback = function()
            require("lint").try_lint()
          end,
        })
        
        -- 添加手動檢查的命令
        vim.api.nvim_create_user_command("LintCheck", function()
          require("lint").try_lint()
        end, {})
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










