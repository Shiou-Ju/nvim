local renumber = require('renumber')

describe("數字列表重新編號", function()
  before_each(function()
    -- 為每個測試創建新的 buffer
    vim.cmd('enew!')
  end)

  describe("renumber_all_sections", function()
    it("應該為每個章節獨立重新編號", function()
      local input = {
        "# 日記",
        "## 教學",
        "5. tommy 16.01",
        "6. anna 17.02",
        "7. john 18.03",
        "",
        "## PM",
        "8. 聯繫 13.38",
        "9. 會議 14.00",
        "",
        "## 開發",
        "3. dev 12.45",
        "4. test 19.09"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)
      renumber.renumber_all_sections()

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 檢查教學章節從 1 開始
      assert.are.equal("1. tommy 16.01", result[3])
      assert.are.equal("2. anna 17.02", result[4])
      assert.are.equal("3. john 18.03", result[5])

      -- 檢查 PM 章節從 1 開始
      assert.are.equal("1. 聯繫 13.38", result[8])
      assert.are.equal("2. 會議 14.00", result[9])

      -- 檢查開發章節從 1 開始
      assert.are.equal("1. dev 12.45", result[12])
      assert.are.equal("2. test 19.09", result[13])
    end)

    it("應該處理嵌套列表", function()
      local input = {
        "## 主要任務",
        "5. 任務一",
        "  3. 子任務 A",
        "  4. 子任務 B",
        "6. 任務二",
        "  8. 子任務 C"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)
      renumber.renumber_all_sections()

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 主列表重新編號
      assert.are.equal("1. 任務一", result[2])
      assert.are.equal("2. 任務二", result[5])

      -- 子列表重新編號
      assert.are.equal("  1. 子任務 A", result[3])
      assert.are.equal("  2. 子任務 B", result[4])
      assert.are.equal("  1. 子任務 C", result[6])
    end)

    it("應該忽略非列表內容", function()
      local input = {
        "## 章節",
        "這是一般段落",
        "3. 列表項目一",
        "4. 列表項目二",
        "這是另一個段落",
        "7. 新列表開始",
        "8. 新列表項目"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)
      renumber.renumber_all_sections()

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 第一個列表
      assert.are.equal("1. 列表項目一", result[3])
      assert.are.equal("2. 列表項目二", result[4])

      -- 第二個列表
      assert.are.equal("1. 新列表開始", result[6])
      assert.are.equal("2. 新列表項目", result[7])

      -- 非列表內容保持不變
      assert.are.equal("這是一般段落", result[2])
      assert.are.equal("這是另一個段落", result[5])
    end)
  end)

  describe("renumber_entire_list", function()
    it("應該重新編號當前章節的列表", function()
      local input = {
        "## 測試章節",
        "5. 第一項",
        "6. 第二項",
        "7. 第三項"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)
      -- 將游標設置在第二行（第一個列表項）
      vim.api.nvim_win_set_cursor(0, {2, 0})

      renumber.renumber_entire_list()

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      assert.are.equal("1. 第一項", result[2])
      assert.are.equal("2. 第二項", result[3])
      assert.are.equal("3. 第三項", result[4])
    end)
  end)

  describe("Enter 鍵整合測試", function()
    it("應該在列表項末尾按 Enter 時自動生成新項目", function()
      local input = {
        "## 測試章節",
        "1. 第一項",
        "2. 第二項"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 將游標設置在第三行末尾（第二個列表項）
      vim.api.nvim_win_set_cursor(0, {3, #input[3]})

      -- 模擬按 Enter 鍵
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'nx', false)

      -- 等待延遲執行完成
      vim.wait(50)

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 驗證新項目生成
      assert.are.equal("## 測試章節", result[1])
      assert.are.equal("1. 第一項", result[2])
      assert.are.equal("2. 第二項", result[3])
      assert.are.equal("3. ", result[4])  -- 新生成的項目
    end)

    it("應該在空列表項按 Enter 時退出列表模式", function()
      local input = {
        "1. 第一項",
        "2. "  -- 空內容列表項
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 將游標設置在空列表項末尾
      vim.api.nvim_win_set_cursor(0, {2, #input[2]})

      -- 模擬按 Enter 鍵
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'nx', false)

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 驗證只是正常換行，沒有生成新列表項
      assert.are.equal("1. 第一項", result[1])
      assert.are.equal("2. ", result[2])
      assert.are.equal("", result[3])  -- 空行
    end)

    it("應該在非列表行按 Enter 時正常換行", function()
      local input = {
        "這是普通段落",
        "另一個段落"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 將游標設置在第一行末尾
      vim.api.nvim_win_set_cursor(0, {1, #input[1]})

      -- 模擬按 Enter 鍵
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'nx', false)

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 驗證正常換行行為
      assert.are.equal("這是普通段落", result[1])
      assert.are.equal("", result[2])  -- 新插入的空行
      assert.are.equal("另一個段落", result[3])
    end)

    it("應該在游標不在行末時正常換行", function()
      local input = {
        "1. 這是一個列表項目"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 將游標設置在行中間（不在末尾）
      vim.api.nvim_win_set_cursor(0, {1, 10})

      -- 模擬按 Enter 鍵
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'nx', false)

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 驗證在中間位置正常斷行，沒有自動編號
      assert.are.equal("1. 這是一個", result[1])
      assert.are.equal("列表項目", result[2])
    end)

    it("應該處理嵌套列表的 Enter 鍵", function()
      local input = {
        "1. 主項目",
        "  1. 子項目"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 將游標設置在子項目末尾
      vim.api.nvim_win_set_cursor(0, {2, #input[2]})

      -- 模擬按 Enter 鍵
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'nx', false)

      -- 等待延遲執行完成
      vim.wait(50)

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 驗證嵌套列表新項目生成
      assert.are.equal("1. 主項目", result[1])
      assert.are.equal("  1. 子項目", result[2])
      assert.are.equal("  2. ", result[3])  -- 新生成的子項目
    end)
  end)

  describe("renumber_list_from_insertion", function()
    it("應該重新編號插入點後的列表項", function()
      local input = {
        "1. 第一項",
        "2. 第二項",
        "3. [新插入]",
        "3. 第三項",
        "4. 第四項"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 從第4行（第三項）開始重新編號
      renumber.renumber_list_from_insertion(4, "")

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 前面不變
      assert.are.equal("1. 第一項", result[1])
      assert.are.equal("2. 第二項", result[2])
      assert.are.equal("3. [新插入]", result[3])

      -- 插入點後重新編號
      assert.are.equal("4. 第三項", result[4])
      assert.are.equal("5. 第四項", result[5])
    end)

    it("應該處理縮排列表的插入", function()
      local input = {
        "1. 主項目",
        "  1. 子項目一",
        "  2. [新插入]",
        "  2. 子項目二",
        "  3. 子項目三"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 從第4行開始重新編號子列表
      renumber.renumber_list_from_insertion(4, "  ")

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 主列表不變
      assert.are.equal("1. 主項目", result[1])

      -- 子列表前面不變
      assert.are.equal("  1. 子項目一", result[2])
      assert.are.equal("  2. [新插入]", result[3])

      -- 插入點後的子列表重新編號
      assert.are.equal("  3. 子項目二", result[4])
      assert.are.equal("  4. 子項目三", result[5])
    end)
  end)
end)