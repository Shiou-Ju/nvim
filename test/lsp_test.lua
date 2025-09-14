-- LSP 自動化測試腳本
-- 用於測試 Issue #30 的 LSP 導航功能

local function test_lsp_functionality()
  print("=== LSP 功能測試開始 ===")

  -- 測試 TypeScript LSP
  print("\n1. 測試 TypeScript LSP")
  vim.cmd('edit test/lsp/issue-30/test.ts')

  -- 等待 LSP 啟動
  vim.defer_fn(function()
    -- 檢查 LSP 客戶端
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #clients > 0 then
      print("  ✅ LSP 客戶端已啟動:")
      for _, client in ipairs(clients) do
        print("     - " .. client.name)
      end

      -- 測試基本 LSP 功能
      print("\n  測試 LSP 功能:")

      -- 測試 textDocument/definition 能力
      if clients[1].server_capabilities.definitionProvider then
        print("  ✅ gd (go to definition) 支援")
      else
        print("  ❌ gd (go to definition) 不支援")
      end

      -- 測試 textDocument/hover 能力
      if clients[1].server_capabilities.hoverProvider then
        print("  ✅ K (hover) 支援")
      else
        print("  ❌ K (hover) 不支援")
      end

      -- 測試 textDocument/references 能力
      if clients[1].server_capabilities.referencesProvider then
        print("  ✅ gr (references) 支援")
      else
        print("  ❌ gr (references) 不支援")
      end

      -- 測試 textDocument/declaration 能力
      if clients[1].server_capabilities.declarationProvider then
        print("  ✅ gD (go to declaration) 支援")
      else
        print("  ❌ gD (go to declaration) 不支援")
      end

    else
      print("  ❌ 沒有 LSP 客戶端啟動")
    end

    -- 測試 JavaScript LSP
    print("\n2. 測試 JavaScript LSP")
    vim.cmd('edit test/lsp/issue-30/test.js')

    vim.defer_fn(function()
      local js_clients = vim.lsp.get_active_clients({ bufnr = 0 })
      if #js_clients > 0 then
        print("  ✅ JavaScript LSP 客戶端已啟動:")
        for _, client in ipairs(js_clients) do
          print("     - " .. client.name)
        end
      else
        print("  ❌ JavaScript 沒有 LSP 客戶端啟動")
      end

      -- 測試 Markdown LSP
      print("\n3. 測試 Markdown LSP")
      vim.cmd('edit test/lsp/issue-30/test.md')

      vim.defer_fn(function()
        local md_clients = vim.lsp.get_active_clients({ bufnr = 0 })
        if #md_clients > 0 then
          print("  ✅ Markdown LSP 客戶端已啟動:")
          for _, client in ipairs(md_clients) do
            print("     - " .. client.name)
          end
        else
          print("  ❌ Markdown 沒有 LSP 客戶端啟動")
        end

        print("\n=== LSP 功能測試完成 ===")

        -- 測試完成後退出
        vim.defer_fn(function()
          vim.cmd('qall!')
        end, 1000)

      end, 2000)  -- 等待 2 秒讓 Markdown LSP 啟動
    end, 2000)    -- 等待 2 秒讓 JavaScript LSP 啟動
  end, 3000)      -- 等待 3 秒讓 TypeScript LSP 啟動
end

-- 執行測試
test_lsp_functionality()