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


-- 確保檔案開啟時不會自動折疊所有內容
-- vim.opt.foldenable = true
-- vim.opt.foldlevelstart = 99  -- 預設展開所有折疊
-- 確保每次開啟檔案時都展開所有折疊
-- vim.api.nvim_create_autocmd("BufReadPost", {
--   callback = function()
--     vim.cmd("normal! zR")  -- 展開所有折疊
--   end
-- })




-- 保留原有的設定
if vim.g.vscode then
    vim.keymap.set('n', 'zc', ":call VSCodeNotify('editor.fold')<CR>")
    vim.keymap.set('n', 'zo', ":call VSCodeNotify('editor.unfold')<CR>")
    vim.keymap.set('i', 'jj', '<Esc>')
else
    vim.opt.relativenumber = true
    vim.keymap.set('i', 'jj', '<Esc>')
    vim.keymap.set('i', 'jk', '<Esc>')
    vim.keymap.set('i', 'kj', '<Esc>')
    vim.keymap.set('i', 'kk', '<Esc>')
    -- vim.keymap.set('n', 'zc', ':foldclose<CR>')
    -- vim.keymap.set('n', 'zo', ':foldopen<CR>')
    -- 導航切換視窗 
    vim.keymap.set('n', '<leader>h', '<C-w>h', { desc = '向左切換視窗' })
    vim.keymap.set('n', '<leader>j', '<C-w>j', { desc = '向下切換視窗' })
    vim.keymap.set('n', '<leader>k', '<C-w>k', { desc = '向上切換視窗' })
    vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = '向右切換視窗' })
    -- 專門處理 terminal 的視窗
    -- vim.keymap.set('t', 'JKL', '<C-\\><C-n>', { desc = '使用 JKL 退出終端模式' })

    -- vim.keymap.set({'i', 't'}, 'JKL', '<C-\\><C-n>', { desc = '使用 JKL 退出插入模式和終端模式' })

    vim.keymap.set({'i', 't'}, 'JKL', function()
      if vim.fn.mode() == 't' then
        return '<C-\\><C-n>'
      else
        return '<Esc>'
      end
    end, { expr = true, desc = '使用 JKL 退出插入模式和終端模式' })


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
    
    -- +x 是剪下到系統的剪貼簿
    vim.keymap.set('v', '<leader>x', '"+x', { desc = '剪下到系統剪貼簿', noremap = true })



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
-- 提取終端切換邏輯為共用函數
local function toggle_terminal()
  -- 如果在終端模式，先退出到普通模式
  if vim.api.nvim_get_mode().mode == 't' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, true, true), 'n', false)
  end

  -- 檢查是否已有終端視窗
  local term_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      table.insert(term_buffers, buf)
    end
  end
  
  -- 查找當前所有視窗，看是否有顯示終端的視窗
  local windows = vim.api.nvim_list_wins()
  local term_win = nil
  
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == 'terminal' then
      term_win = win
      break
    end
  end
  
  -- 如果找到顯示終端的視窗，處理切換邏輯
  if term_win ~= nil then
    -- 檢查當前視窗是否就是終端視窗
    local current_win = vim.api.nvim_get_current_win()
    if current_win == term_win then
      -- 如果當前已在終端視窗，則關閉它
      vim.api.nvim_win_close(term_win, false)
    else
      -- 如果終端視窗已開啟但不是當前視窗，則切換焦點到終端視窗
      vim.api.nvim_set_current_win(term_win)
      -- 如果是從非終端模式切換過來，自動進入插入模式
      if vim.api.nvim_get_mode().mode ~= 't' then
        vim.cmd('startinsert')
      end
    end
    return
  end
  
  -- 如果沒有顯示終端的視窗，則開啟/創建終端
  if #term_buffers > 0 then
    -- 如果已有終端緩衝區，開啟一個新的底部終端視窗
    vim.cmd('split')
    vim.cmd('wincmd J')  -- 將視窗移到最底部
    vim.cmd('resize 23%')
    vim.cmd('buffer ' .. term_buffers[1])
    vim.cmd('startinsert')
  else
    -- 如果沒有終端，創建一個新的底部終端
    vim.cmd('split')
    vim.cmd('wincmd J')  -- 將視窗移到最底部
    vim.cmd('resize 23%')
    vim.cmd('terminal')
    vim.cmd('startinsert')
  end
end

-- 原有的 Ctrl+` 快捷鍵映射（保持向後相容）
vim.keymap.set({'n', 'i', 't'}, '<C-`>', toggle_terminal, { desc = 'VS Code 風格終端開關 (Ctrl+`)' , noremap = true})

-- 新增 <leader>tt 作為 tmux 相容的終端切換快捷鍵（移除 Insert 模式避免輸入延遲）
-- TODO: 思考是否需要 n 或是改用其他的
vim.keymap.set({'n'}, '<leader>tt', toggle_terminal, { desc = 'tmux 相容終端切換 (space tt)' , noremap = true})
    -- 模擬 VS Code 的 Ctrl + ` 開啟終端功能 end


    -- Telescope 快捷鍵設定
    -- vim.keymap.set('n', '<leader>ff', function()
    --   require('telescope.builtin').find_files()
    -- end, { desc = '搜尋檔案' })
    vim.keymap.set('n', '<leader>ff', function()
      require('telescope.builtin').find_files({
        hidden = true,  -- 顯示隱藏檔案
        file_ignore_patterns = { "node_modules", "^.git/" }  -- 只忽略 .git 目錄，而非所有 .git 開頭的檔案
      })
    end, { desc = '搜尋檔案' })


    -- find recent files
    vim.keymap.set('n', '<leader>fr', function()
      require('telescope.builtin').oldfiles()
    end, { desc = '最近開啟的檔案' })

    
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

-- Git diff 面板標題改善設定
-- 設定預設 statusline 顯示 Git 分支
vim.opt.statusline = '%<%f %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%) %P'

-- 自動為 Git diff 面板加上清楚的標題 - 使用更可靠的事件組合
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "WinEnter"}, {
  pattern = "*",
  callback = function()
    -- 延遲執行以確保 buffer 完全載入
    vim.defer_fn(function()
      local bufname = vim.api.nvim_buf_get_name(0)

      -- 添加 nil 檢查防護
      if not bufname or bufname == "" then
        return
      end

      -- Debug 輸出（可查看實際 buffer 路徑格式）
      if bufname:match("fugitive://") then
        print("Fugitive Buffer: " .. bufname)
      end
      
      if bufname:match("fugitive://") then
        -- 更精確的匹配：檢查 .git 後面的部分
        if bufname:match("%.git//0/") then
          -- 確定是 Index (暫存區)
          vim.wo.statusline = "[STAGED] %f %=%l,%c %P"
          
        elseif bufname:match("%.git//HEAD/") or bufname:match("%.git//[a-f0-9]+/") then
          -- HEAD 或 commit SHA
          vim.wo.statusline = "[LAST COMMIT] %f %=%l,%c %P"
          
        elseif bufname:match("%.git//1/") then
          -- Merge conflict: 共同祖先
          vim.wo.statusline = "[BASE] %f %=%l,%c %P"
          
        elseif bufname:match("%.git//2/") then
          -- Merge conflict: 我們的版本
          vim.wo.statusline = "[OURS] %f %=%l,%c %P"
          
        elseif bufname:match("%.git//3/") then
          -- Merge conflict: 他們的版本
          vim.wo.statusline = "[THEIRS] %f %=%l,%c %P"
          
        else
          -- 其他 fugitive buffer
          vim.wo.statusline = "[GIT] %f %=%l,%c %P"
        end
        
      elseif vim.wo.diff and vim.bo.buftype == "" then
        -- 如果不是 fugitive buffer 但在 diff 模式，就是 Working File
        vim.wo.statusline = "[WORKING FILE] %f %=%l,%c %P"
      end
    end, 50)  -- 延遲 50ms 執行
  end
})

-- 載入插件
require("lazy").setup({
    -- nvim-surround 插件
      -- 添加環繞 (Add surroundings)：
        -- ysiw B - 將游標所在單詞加粗
        -- ysiw I - 將游標所在單詞設為斜體
        -- ysiw S - 將游標所在單詞加上刪除線
        -- ysiw( - 將游標所在單詞用括號環繞
        -- ysiw[ - 將游標所在單詞用方括號環繞
      -- 刪除環繞 (Delete surroundings)：
        -- ds( - 刪除周圍的 ()
        -- ds[ - 刪除周圍的 []
        -- dsB - 刪除周圍的 ** (粗體)
        -- dsI - 刪除周圍的 * (斜體)
        -- dsS - 刪除周圍的 ~~ (刪除線)
        --
      -- 更改環繞 (Change surroundings)：
        --
        -- cs([ - 將 () 改為 []
        -- csBI - 將粗體改為斜體
        -- csSB - 將刪除線改為粗體
        --
      -- 在視覺模式下：
        --
        -- 選取文字 (按 v 並移動游標)
        -- 按 S 後輸入：
        --
        -- ( 或 ) - 用 () 環繞
        -- [ 或 ] - 用 [] 環繞
        -- B - 用 ** 環繞 (粗體)
        -- I - 用 * 環繞 (斜體)
        -- S - 用 ~~ 環繞 (刪除線)
  {
    "kylechui/nvim-surround",
    version = "*",  -- 使用最新的穩定版本
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        surrounds = {
          -- 粗體 (Bold)
             -- 粗體 (Bold)
          -- ["B"] = {
          ["M"] = {
            add = { "**", "**" },
            find = function()
              return require("nvim-surround.config").get_selection({ pattern = "%*%*.-%*%*" })
            end,
            delete = function()
              return require("nvim-surround.config").get_selections({
                char = "B",
                pattern = "^(%*%*)().-(%*%*)()$",
              })
            end,
          },
          -- 斜體 (Italic)
          ["I"] = {
            add = { "*", "*" },
            find = function()
              return require("nvim-surround.config").get_selection({ pattern = "%*.-%*" })
            end,
            delete = function()
              return require("nvim-surround.config").get_selections({
                char = "I",
                pattern = "^(%*)().-(%*)()$",
              })
            end,
          },
          -- 刪除線 (Strikethrough)
          -- 注意：受 nvim-surround 架構限制，單行 Visual Line 仍會強制上下行加入
          -- 詳見 Issue #22，此為嘗試性實作
             ["S"] = {
            add = function()
              local mode = vim.fn.visualmode()
              
              if mode == "V" then
                -- Visual Line 模式：檢查是否為單行
                local first_line = vim.fn.line("'<")
                local last_line = vim.fn.line("'>")
                
                if first_line == last_line then
                  -- 單行 Visual Line：期望左右加入（目前受限制無效）
                  return { "~~", "~~" }
                else
                  -- 多行 Visual Line：回歸原生跨行邏輯（有效）
                  return nil
                end
              else
                -- 字符模式：正常處理（有效）
                return { "~~", "~~" }
              end
            end,
            find = function()
              return require("nvim-surround.config").get_selection({ pattern = "~~.-~~" })
            end,
            delete = function()
              return require("nvim-surround.config").get_selections({
                char = "S",
                pattern = "^(~~)().-(~~)()$",
              })
            end,
          },
        },
        -- 默認的括號配置已經內建支援
      })
    end
  },
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
		    
		    -- 增強 Git diff 顏色對比 (Issue #18)
		    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1a4a1a", fg = "#7dcfff" })
		    vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#4a1a1a", fg = "#f7768e" })
		    vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1a1a4a", fg = "#e0af68" })
		    vim.api.nvim_set_hl(0, "DiffText", { bg = "#4a4a1a", fg = "#bb9af7" })
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
    --   defaults = {
    --     file_ignore_patterns = { "node_modules", ".git" },
    --     mappings = {
    --       i = {
    --         ["<C-j>"] = "move_selection_next",
    --         ["<C-k>"] = "move_selection_previous",
    --       },
    --     },
    --   },
    --   pickers = {
    --     find_files = {
    --       hidden = true  -- 這裡添加，使 find_files 能夠顯示隱藏檔案
    --     }
    --   }
    -- })
        defaults = {
        file_ignore_patterns = { "node_modules", ".git" },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
        sorting_strategy = "ascending",  -- 使結果從上往下排列，類似 VS Code
        layout_config = {
          horizontal = {
            prompt_position = "top",  -- 將提示放在頂部
          },
        },
      },
      pickers = {
        oldfiles = {
          prompt_title = "最近打開的檔案",  -- 自定義標題
          sort_lastused = true,  -- 按最後使用時間排序
        },
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
          "marksman", --markdown lsp
          "ts_ls"    --typescript lsp
        },
      })

      -- 設定 LSP 按鍵映射
      local on_attach = function(_, bufnr)
        -- 診斷相關快捷鍵
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = '顯示錯誤信息', buffer = bufnr })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = '前一個錯誤', buffer = bufnr })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = '下一個錯誤', buffer = bufnr })

        -- LSP 導航快捷鍵 - 使用 Telescope 優化顯示
        vim.keymap.set('n', 'gr', function()
          require('telescope.builtin').lsp_references()
        end, { desc = 'LSP: 查找所有引用 (Telescope)', buffer = bufnr })
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

      -- 配置 ts_ls
      require('lspconfig').ts_ls.setup({
        on_attach = on_attach,
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
},
  -- Git 進階操作插件
  {
    "tpope/vim-fugitive",
    config = function()
      -- 完整的 Git diff 快捷鍵配置
      vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>', { desc = '工作目錄 vs 暫存區' })
      vim.keymap.set('n', '<leader>gD', ':Gvdiffsplit HEAD<CR>', { desc = '工作目錄 vs HEAD' })
      vim.keymap.set('n', '<leader>gS', ':Gvdiffsplit :0<CR>', { desc = '暫存區 vs HEAD' })
      -- Git blame
      vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = 'Git blame' })
      -- Git log
      vim.keymap.set('n', '<leader>gl', ':Git log --oneline<CR>', { desc = 'Git log' })
    end
  },
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
    ,
      -- 添加 Live Server 功能插件
    --       {
    --   "barrett-ruth/live-server.nvim",
    --   config = function()
    --     require('live-server').setup({
    --       -- 確保設置所有必須的選項
    --       port = 8080,
    --       browser_command = nil,  -- 使用系統默認瀏覽器
    --       quiet = false,
    --       no_css_inject = false,
    --       root = nil,  -- 使用當前工作目錄
    --       mount_path = "/",
    --       -- 重要: 確保這些目錄存在
    --       server_path = vim.fn.stdpath("data") .. "/live-server",
    --       start_on_load = false,
    --     })
    --   end,
    -- }
    --
    -- 在您現有的 lazy.nvim 插件列表中添加以下內容
    {
      -- glow.nvim: 在 Vim 內預覽 Markdown
      "ellisonleao/glow.nvim",
      ft = "markdown",
      cmd = "Glow",
      config = function()
        require("glow").setup({
          border = "rounded",       -- 圓角邊框
          style = "dark",           -- 暗色主題
          width = 120,              -- 預覽視窗寬度
          height_ratio = 0.7,       -- 預覽視窗高度比例
          pager = false,            -- 禁用分頁器
        })
      end
    },
    {
      -- markdown-preview.nvim: 在瀏覽器中預覽 Markdown
      "iamcco/markdown-preview.nvim",
      ft = "markdown",
      build = function()
        -- 指定 Node.js 路徑
        vim.g.mkdp_node_path = "/Users/bamboo/.nvm/versions/node/v20.16.0/bin/node"
        vim.fn["mkdp#util#install"]()
      end,
      config = function()
        vim.g.mkdp_node_path = "/Users/bamboo/.nvm/versions/node/v20.16.0/bin/node"
        vim.g.mkdp_auto_start = 0         -- 不自動啟動預覽
        vim.g.mkdp_auto_close = 1         -- 關閉 buffer 時自動關閉預覽
        vim.g.mkdp_refresh_slow = 0       -- 即時刷新預覽
        vim.g.mkdp_command_for_global = 0 -- 僅在 markdown 檔案中啟用命令
        vim.g.mkdp_open_to_the_world = 0  -- 僅本地預覽
        vim.g.mkdp_browser = ""           -- 使用默認瀏覽器
        vim.g.mkdp_echo_preview_url = 1   -- 顯示預覽 URL
        vim.g.mkdp_page_title = '「${name}」'  -- 預覽頁面標題格式
      end,
    }
})

-- 解決 terminal 跟文件目錄不一致的問題
-- 創建一個同步目錄的命令，命名為 CdVimDirHere
vim.api.nvim_create_user_command('CdVimDirHere', function()
  -- 獲取當前緩衝區
  local buf = vim.api.nvim_get_current_buf()
  -- 檢查是否是終端緩衝區
  if vim.bo[buf].buftype == 'terminal' then
    -- 直接在終端發送 pwd 命令並讀取結果
    local job_id = vim.b[buf].terminal_job_id
    vim.fn.chansend(job_id, "pwd > /tmp/nvim_cwd && echo '目錄已同步'\n")
    -- 短暫延遲
    vim.cmd("sleep 100m")
    -- 讀取路徑並設定為 Neovim 的工作目錄
    local cwd = vim.fn.system("cat /tmp/nvim_cwd"):gsub("\n", "")
    if cwd ~= "" then
      vim.cmd("cd " .. vim.fn.fnameescape(cwd))
      print("工作目錄已更新為: " .. cwd)
    end
  else
    print("當前不在終端緩衝區")
  end
end, {})


-- 將所有 Markdown 相關設定整合到一個 autocmd 中
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- 快捷鍵設定
    -- glow.nvim：Vim 內預覽
    vim.keymap.set('n', '<leader>mp', ':Glow<CR>', { 
      desc = 'Markdown 內部預覽 (Glow)', 
      buffer = true, 
      noremap = true, 
      silent = true 
    })
    
    -- markdown-preview.nvim：瀏覽器預覽
    vim.keymap.set('n', '<leader>mb', ':MarkdownPreviewToggle<CR>', { 
      desc = 'Markdown 瀏覽器預覽', 
      buffer = true, 
      noremap = true, 
      silent = true 
    })
    
    -- 停止瀏覽器預覽服務
    vim.keymap.set('n', '<leader>ms', ':MarkdownPreviewStop<CR>', { 
      desc = '停止 Markdown 預覽服務', 
      buffer = true, 
      noremap = true, 
      silent = true 
    })
    
    -- 編輯器設定
    vim.opt_local.formatoptions = "roj1n"  -- 設定所有格式化選項一次性
    
    -- 設定 Tab 為 2 個空格
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true

    -- 設定軟換行
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    
    -- 顯示行號
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
    
    -- 設定自動遞增列表
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true


   -- TODO: 只有 enter 鍵有用，並且不支援 o , O等 
   -- 智能數字列表自動編號功能
   
   
   -- 添加數字列表快捷鍵
    vim.keymap.set('i', '<CR>', function()
      local line = vim.api.nvim_get_current_line()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      local current_col = cursor_pos[2]
      local current_line_num = cursor_pos[1]
      
      -- 檢查是否在數字列表項末尾
      local list_match = line:match("^(%s*)(%d+)%.%s+(.*)")
      if list_match and current_col >= #line then
        local indent, num, content = line:match("^(%s*)(%d+)%.%s+(.*)")
        
        -- 如果內容為空，退出列表模式
        if content == "" then
          return "<CR>"
        end
        
        -- 插入新列表項
        local next_num = tonumber(num) + 1
        local new_item = "<CR>" .. indent .. next_num .. ". "

        -- 延遲執行重新編號，讓新行先插入
        vim.defer_fn(function()
          local renumber = require('renumber')
          renumber.renumber_list_from_insertion(current_line_num + 2, indent)
        end, 10)
        
        return new_item
      end
      
      -- 正常行為
      return "<CR>"
    end, { expr = true, buffer = true })
    
    -- 添加手動重新編號快捷鍵（方案 B）
    local renumber = require('renumber')
    vim.keymap.set('n', '<leader>rn', renumber.renumber_entire_list, {
      desc = '重新編號當前數字列表',
      buffer = true,
      noremap = true,
      silent = true
    })

    -- 添加全文檔重新編號快捷鍵
    vim.keymap.set('n', '<leader>rN', renumber.renumber_all_sections, {
      desc = '重新編號所有章節列表',
      buffer = true,
      noremap = true,
      silent = true
    })
  end
})


-- 只為普通模式設定快捷鍵
vim.keymap.set('n', '<leader>cd', ':CdVimDirHere<CR>', { desc = '將 Neovim 工作目錄設為當前終端目錄' })






-- 類似 VS Code 中的 Advanced New File 功能
--
-- 創建一個名為 NewFile 的自定義命令
-- 當命令被觸發時，它使用 Telescope（一個檔案瀏覽套件）讓您選擇一個位置
-- 當您選擇一個位置後，它會提示您輸入新檔案名稱
-- 如果需要，它會自動創建所需的目錄
-- 最後，它會打開剛創建的新檔案
--
-- 註冊簡易版的新檔案創建命令 do
vim.api.nvim_create_user_command('NewFile', function()
    -- 使用 Telescope 尋找目錄
  require('telescope.builtin').find_files({
    prompt_title = "選擇檔案位置",
    attach_mappings = function(prompt_bufnr, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      
      -- 覆寫 Enter 鍵的行為，讓選擇後可以輸入新檔案名
      actions.select_default:replace(function()
        -- 獲取用戶在 Telescope 中選擇的項目路徑
        local selection = action_state.get_selected_entry()
        local path = selection and selection.path or ""
        
        -- 如果選的是檔案而不是目錄，就取其所在目錄
        if vim.fn.filereadable(path) == 1 then
          path = vim.fn.fnamemodify(path, ':h')
        end
        
        -- 關閉 Telescope 視窗
        actions.close(prompt_bufnr)
        
        -- 彈出輸入框讓用戶輸入新檔案名稱
        vim.ui.input({
          prompt = "新檔案: ",
          default = path .. '/'  -- 默認使用選擇的目錄路徑
        }, function(input)
          if input and input ~= "" then
            -- 先確保檔案的父目錄存在，如果不存在就創建
            local dir = vim.fn.fnamemodify(input, ':h')
            if dir ~= '.' and vim.fn.isdirectory(dir) == 0 then
              vim.fn.mkdir(dir, 'p')
            end
            
            -- 開啟新檔案（如果不存在會自動創建）
            vim.cmd('edit ' .. vim.fn.fnameescape(input))
          end
        end)
      end)
      
      return true  -- 返回 true 保留 Telescope 默認的其他按鍵映射
    end
  })
end, {})



-- 設定快捷鍵 <leader>nf 來觸發 NewFile 命令
vim.keymap.set('n', '<leader>nf', ':NewFile<CR>', {desc = '新建檔案'})

-- 使用 space y y 複製整行到系統剪貼簿
vim.keymap.set('n', '<leader>yy', '"+yy', { desc = '複製整行到系統剪貼簿', noremap = true })
-- 使用 space y w 複製單詞到系統剪貼簿
vim.keymap.set('n', '<leader>yiw', '"+yiw', { desc = '複製單詞到系統剪貼簿', noremap = true })

-- 使用 space x x 剪下整行到系統剪貼簿
vim.keymap.set('n', '<leader>xx', '"+dd', { desc = '剪下整行到系統剪貼簿', noremap = true })
-- 使用 space x i w 剪下單詞到系統剪貼簿
vim.keymap.set('n', '<leader>xiw', '"+diw', { desc = '剪下單詞到系統剪貼簿', noremap = true })

-- 使用 space-w 儲存檔案 (更簡潔的替代方案)
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = '儲存檔案', noremap = true })


-- 註冊簡易版的新檔案創建命令 end

-- 選取目前 code block in md 內容
vim.keymap.set('n', '<leader>vc', function()
  -- 查找代碼塊的開始位置（向上搜索）
  local start_line = vim.fn.search('```', 'bnW')
  if start_line == 0 then
    print("找不到代碼塊開始標記")
    return
  end
  
  -- 查找代碼塊的結束位置（向下搜索）
  local end_line = vim.fn.search('```', 'nW')
  if end_line == 0 then
    print("找不到代碼塊結束標記")
    return
  end
  
  -- 選取代碼塊內容（不包括開始和結束標記）
  vim.cmd(string.format('normal! %dGj', start_line))
  vim.cmd('normal! V')
  vim.cmd(string.format('normal! %dGk', end_line))
end, { desc = '選取當前代碼塊內容' })




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


-- 設定 terminal scrollback 為 50 萬行
-- vim.opt.scrollback = 500000  
-- 在 terminal 創建時設定
-- vim.api.nvim_create_autocmd("TermOpen", {
--   callback = function()
--     vim.bo.scrollback = 500000  -- 改用 vim.bo
--   end
-- })
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    -- 檢查 scrollback 選項是否存在
    if vim.fn.exists('&scrollback') == 1 then
      -- vim.cmd("setlocal scrollback=500000")
      vim.cmd("setlocal scrollback=10000")  -- 改成 1 萬行
    else
      -- 如果不存在，使用其他方法或忽略
      print("scrollback option not available")
    end
  end
})



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


-- 為 JSON 檔案單獨設定摺疊方法 (放在 init.lua 的適當位置)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    -- vim.opt_local.foldmethod = "syntax"  -- 使用語法摺疊
    vim.opt_local.foldmethod = "indent"  -- 改用縮排折疊

    -- 每次載入 JSON 檔案時展開所有摺疊
    vim.cmd("normal! zR")

    vim.opt_local.foldenable = true
  end
})

-- 為 TypeScript 檔案單獨設定摺疊方法
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"typescript", "typescriptreact"},
  callback = function()
    vim.opt_local.foldmethod = "indent"  -- 使用縮排方式摺疊
    vim.opt_local.foldenable = true      -- 啟用摺疊
    vim.cmd("normal! zR")  -- 展開所有折疊
    -- 確保延遲執行展開指令，以防止某些情況下未正確展開
    vim.defer_fn(function()
      vim.cmd("normal! zR")
    end, 50)  -- 50毫秒後再次展開
  end
})


-- 全域折疊設定
vim.opt.foldenable = true 
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99  -- 預設展開所有折疊

-- 自動展開全部的
-- vim.api.nvim_create_autocmd({"BufReadPost","BufNewFile"}, {
--   callback = function() vim.cmd("normal! zR") end
-- })
--
vim.api.nvim_create_autocmd({"BufReadPost","BufNewFile","BufEnter"}, {
  callback = function() vim.cmd("normal! zR") end
})





-- 設定換行時不顯示任何標記
-- vim.cmd([[autocmd VimEnter,BufEnter * set showbreak=]])
vim.cmd([[
  autocmd VimEnter,BufEnter,BufReadPost * set showbreak= nolist listchars=
]])





-- --  LiveServer 命令使用插件 API
-- vim.api.nvim_create_user_command('LiveServer', function(opts)
--   local port = opts.args ~= "" and tonumber(opts.args) or nil
--   if port then
--     require('live-server').start(port)
--   else
--     require('live-server').start()
--   end
-- end, { nargs = '?' })
--
-- -- 修改 LiveServerStop 命令使用插件 API
-- vim.api.nvim_create_user_command('LiveServerStop', function()
--   require('live-server').stop()
-- end, {})
--


-- FIXME: 似乎無法執行哦
-- 定義 Live Server 相關函數和狀態管理
do
  -- 用於保存 Live Server 作業 ID
  local server_job_id = nil
  local server_port = 8080

  -- 啟動 Live Server
  local function start_live_server(port)
    -- 如果已有一個伺服器正在運行，先停止它
    if server_job_id ~= nil then
      vim.fn.jobstop(server_job_id)
      server_job_id = nil
      print("已停止舊的 Live Server")
    end

    -- 設置埠號
    server_port = port or server_port

    -- 獲取當前工作目錄
    local cwd = vim.fn.getcwd()
    
    -- 判斷 node.js 環境
    local live_server_cmd

        
    -- 初始化 nvm 環境
    -- local init_env = 'source ~/.zshrc && nvm use default > /dev/null 2>&1 && '
    -- 首先通過 yarn 觸發 nvm 載入
    local init_env = 'source ~/.zshrc && yarn --version > /dev/null && '

    
    -- 檢查是否安裝了 npx
    -- 檢查是否是全局安裝的 live-server
    if vim.fn.executable('npx') == 1 then
      live_server_cmd = init_env .. 'npx --yes live-server --port=' .. server_port
    elseif vim.fn.executable('live-server') == 1 then
      live_server_cmd = init_env .. 'live-server --port=' .. server_port
    else
      print("錯誤: 未找到 live-server。請先使用 npm install -g live-server 安裝。")
      return false
    end
    
    -- 啟動 live-server 作業
    server_job_id = vim.fn.jobstart(live_server_cmd, {
      cwd = cwd,
      shell = '/bin/zsh',  -- 明確使用 zsh
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          print("Live Server 非正常退出，代碼: " .. exit_code)
        end
        server_job_id = nil
      end,
      on_stdout = function(_, data)
        if data and #data > 0 then
          for _, line in ipairs(data) do
            if line and line ~= "" then
              print("LiveServer: " .. line)
            end
          end
        end
      end,
      on_stderr = function(_, data)
        if data and #data > 0 then
          for _, line in ipairs(data) do
            if line and line ~= "" then
              print("LiveServer 錯誤: " .. line)
            end
          end
        end
      end,
      detach = 1  -- 讓作業在後台運行
    })
    
    if server_job_id <= 0 then
      print("無法啟動 Live Server")
      server_job_id = nil
      return false
    end
    
    print("Live Server 已啟動 (埠:" .. server_port .. ")")
    return true
  end
  
  -- 停止 Live Server
  local function stop_live_server()
    if server_job_id ~= nil then
      vim.fn.jobstop(server_job_id)
      server_job_id = nil
      print("Live Server 已停止")
      return true
    else
      print("Live Server 未運行")
      return false
    end
  end
  
  -- 檢查 Live Server 狀態
  local function check_live_server_status()
    if server_job_id ~= nil then
      print("Live Server 正在運行 (埠:" .. server_port .. ")")
      return true
    else
      print("Live Server 未運行")
      return false
    end
  end
  
  -- 註冊命令
  vim.api.nvim_create_user_command('LiveServer', function(opts)
    local port = opts.args ~= "" and tonumber(opts.args) or 8080
    if port then
      start_live_server(port)
    else
      start_live_server(8080)
    end
  end, { nargs = '?', desc = '啟動 Live Server (可選指定埠號)' })

  vim.api.nvim_create_user_command('LiveServerStop', function()
    stop_live_server()
  end, { desc = '停止 Live Server' })

  vim.api.nvim_create_user_command('LiveServerStatus', function()
    check_live_server_status()
  end, { desc = '檢查 Live Server 狀態' })
  
  -- 可選：設置退出 Neovim 時自動關閉 Live Server
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if server_job_id ~= nil then
        stop_live_server()
      end
    end
  })
  
  -- 可選：設置快捷鍵
  vim.keymap.set('n', '<leader>ls', ':LiveServer<CR>', { desc = '啟動 Live Server', silent = true })
  vim.keymap.set('n', '<leader>lx', ':LiveServerStop<CR>', { desc = '停止 Live Server', silent = true })
end

-- ================================================================
-- 顯示器切換色彩修復系統 (Issue #36)
-- ================================================================

-- Level 0: 色彩診斷工具
vim.api.nvim_create_user_command('ColorDebug', function()
  print("=== 色彩診斷報告 ===")
  print("TERM: " .. (vim.env.TERM or "未設定"))
  print("COLORTERM: " .. (vim.env.COLORTERM or "未設定"))
  print("termguicolors: " .. tostring(vim.opt.termguicolors:get()))
  print("色彩支援: " .. (vim.fn.has('termguicolors') == 1 and "是" or "否"))
  print("tput colors: " .. (vim.fn.system('tput colors'):gsub('\n', '') or "無法檢測"))
  print("當前主題: " .. (vim.g.colors_name or "未設定"))
end, { desc = "診斷色彩環境狀態" })

-- Level 1: 強制色彩修復
local function force_color_fix()
  -- 步驟1: 強制重設終端環境變數
  vim.env.TERM = "xterm-256color"
  vim.env.COLORTERM = "truecolor"

  -- 步驟2: 強制啟用 Neovim 色彩功能
  vim.opt.termguicolors = true

  -- 步驟3: 重新載入主題
  pcall(function()
    vim.cmd('colorscheme tokyonight-night')
  end)

  -- 步驟4: 強制刷新畫面
  vim.cmd('redraw!')

  -- 步驟5: 顯示修復狀態
  print("🎨 色彩已強制修復！")
end

-- 自動觸發：當 Neovim 獲得焦點或啟動時
vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = vim.api.nvim_create_augroup("ColorFix", { clear = true }),
  callback = function()
    -- 檢查是否需要修復（避免不必要的操作）
    if vim.fn.has('termguicolors') == 0 or vim.env.TERM == "vt100" then
      force_color_fix()
    end
  end,
})

-- 手動觸發：命令
vim.api.nvim_create_user_command('ColorFix', force_color_fix, {
  desc = "強制修復色彩環境"
})






 






