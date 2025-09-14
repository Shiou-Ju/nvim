-- Telescope References 功能測試腳本
-- 用於驗證 gr 快捷鍵使用 Telescope 顯示引用

local function test_telescope_references()
  print("=== Telescope References 功能測試 ===")

  -- 開啟測試檔案
  vim.cmd('edit test/lsp/issue-30/test.ts')

  -- 等待 LSP 啟動
  vim.defer_fn(function()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })

    if #clients > 0 then
      print("✅ LSP 客戶端已啟動: " .. clients[1].name)

      -- 檢查 gr 快捷鍵是否已正確設定
      local keymaps = vim.api.nvim_buf_get_keymap(0, 'n')
      local gr_found = false

      for _, keymap in ipairs(keymaps) do
        if keymap.lhs == 'gr' then
          gr_found = true
          print("✅ 'gr' 快捷鍵已設定")
          if keymap.desc and keymap.desc:match("Telescope") then
            print("✅ 'gr' 使用 Telescope 優化顯示")
          else
            print("⚠️  'gr' 可能未使用 Telescope")
          end
          break
        end
      end

      if not gr_found then
        print("❌ 'gr' 快捷鍵未找到")
      end

      -- 檢查 Telescope LSP 功能是否可用
      local telescope_status, telescope_builtin = pcall(require, 'telescope.builtin')
      if telescope_status then
        if telescope_builtin.lsp_references then
          print("✅ telescope.builtin.lsp_references 功能可用")
        else
          print("❌ telescope.builtin.lsp_references 功能不可用")
        end
      else
        print("❌ Telescope builtin 模組載入失敗")
      end

    else
      print("❌ LSP 客戶端未啟動")
    end

    print("\n=== 測試完成 ===")
    print("手動測試建議：")
    print("1. 開啟 test/lsp/issue-30/test.ts")
    print("2. 將游標放在任意函數或變數上")
    print("3. 按 'gr' 查看是否彈出 Telescope 引用列表")
    print("4. 驗證列表是否包含檔案路徑、行號和程式碼預覽")

    -- 測試完成後退出
    vim.defer_fn(function()
      vim.cmd('qall!')
    end, 1000)

  end, 3000) -- 等待 3 秒讓 LSP 啟動
end

-- 執行測試
test_telescope_references()