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

  describe("Enter 鍵處理函數測試 (Mock)", function()
    local mock = require('luassert.mock')
    local stub = require('luassert.stub')

    it("應該在列表項末尾生成新項目", function()
      -- Mock vim.api 函數
      local api_mock = mock(vim.api, true)
      local defer_stub = stub(vim, 'defer_fn')

      -- 設置模擬返回值 - "2. 第二項" 長度為 12 (UTF-8)
      api_mock.nvim_get_current_line.returns("2. 第二項")
      api_mock.nvim_win_get_cursor.returns({2, 11})  -- 修正：0-indexed，11 對應字串末尾

      -- 執行函數
      local result = renumber.handle_enter_key()

      -- 驗證結果
      assert.are.equal("<CR>3. ", result)

      -- 驗證延遲函數被調用
      assert.stub(defer_stub).was.called()

      -- 清理
      mock.revert(api_mock)
      defer_stub:revert()
    end)

    it("應該在空列表項時退出列表模式", function()
      local api_mock = mock(vim.api, true)

      -- 空內容列表項
      api_mock.nvim_get_current_line.returns("2. ")
      api_mock.nvim_win_get_cursor.returns({2, 3})  -- 游標在行末

      local result = renumber.handle_enter_key()

      -- 應該返回正常換行
      assert.are.equal("<CR>", result)

      mock.revert(api_mock)
    end)

    it("應該在非列表行時正常換行", function()
      local api_mock = mock(vim.api, true)

      -- 非列表行
      api_mock.nvim_get_current_line.returns("這是普通段落")
      api_mock.nvim_win_get_cursor.returns({1, 10})

      local result = renumber.handle_enter_key()

      -- 應該返回正常換行
      assert.are.equal("<CR>", result)

      mock.revert(api_mock)
    end)

    it("應該在游標不在行末時正常換行", function()
      local api_mock = mock(vim.api, true)

      -- 列表項但游標不在末尾
      api_mock.nvim_get_current_line.returns("1. 這是一個列表項目")
      api_mock.nvim_win_get_cursor.returns({1, 5})  -- 游標在中間

      local result = renumber.handle_enter_key()

      -- 應該返回正常換行
      assert.are.equal("<CR>", result)

      mock.revert(api_mock)
    end)

    it("應該處理嵌套列表", function()
      local api_mock = mock(vim.api, true)
      local defer_stub = stub(vim, 'defer_fn')

      -- 嵌套列表項 "  1. 子項目" 長度為 14 (UTF-8)
      api_mock.nvim_get_current_line.returns("  1. 子項目")
      api_mock.nvim_win_get_cursor.returns({2, 13})  -- 修正：0-indexed，13 對應字串末尾

      local result = renumber.handle_enter_key()

      -- 驗證生成嵌套新項目
      assert.are.equal("<CR>  2. ", result)

      -- 驗證延遲函數被調用
      assert.stub(defer_stub).was.called()

      mock.revert(api_mock)
      defer_stub:revert()
    end)

    it("應該正確處理不同縮排層級", function()
      local api_mock = mock(vim.api, true)
      local defer_stub = stub(vim, 'defer_fn')

      -- 深度嵌套列表 "    3. 深度嵌套項目" 長度為 25 (UTF-8)
      api_mock.nvim_get_current_line.returns("    3. 深度嵌套項目")
      api_mock.nvim_win_get_cursor.returns({3, 24})  -- 修正：0-indexed，24 對應字串末尾

      local result = renumber.handle_enter_key()

      -- 驗證保持相同縮排層級
      assert.are.equal("<CR>    4. ", result)

      mock.revert(api_mock)
      defer_stub:revert()
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

    it("應該處理跨章節插入時避免跨章節編號累加", function()
      local input = {
        "## 教學",
        "1. 第一項",
        "2. 第二項",
        "",
        "## PM",
        "3. [新插入的項目]",  -- 這個編號 3 是錯誤的，應該是 1
        "4. 後續項目"
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 模擬在 PM 章節第一行按 Enter 後的重新編號 (第7行開始)
      renumber.renumber_list_from_insertion(7, "")

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 教學章節保持不變
      assert.are.equal("1. 第一項", result[2])
      assert.are.equal("2. 第二項", result[3])

      -- PM 章節的插入項目保持原狀
      assert.are.equal("3. [新插入的項目]", result[6])
      -- 後續項目應該接續編號，而不是跨章節累計
      assert.are.equal("4. 後續項目", result[7])
    end)

    it("應該在新章節中正確計算起始編號", function()
      local input = {
        "## 教學",
        "1. 第一項",
        "2. 第二項",
        "",
        "## PM",
        "1. 第一個 PM 項目"  -- 使用者已手動建立第一個項目
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, input)

      -- 模擬在 PM 章節 "1. 第一個 PM 項目" 後按 Enter
      -- Enter 鍵會插入新行，然後調用重新編號
      vim.api.nvim_buf_set_lines(0, 6, 6, false, {"2. [新產生的項目]"})

      -- 重新編號從新插入行的下一行開始 (第8行，但現在沒有內容)
      renumber.renumber_list_from_insertion(8, "")

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- 教學章節保持不變
      assert.are.equal("1. 第一項", result[2])
      assert.are.equal("2. 第二項", result[3])

      -- PM 章節應該正確編號
      assert.are.equal("1. 第一個 PM 項目", result[6])
      assert.are.equal("2. [新產生的項目]", result[7])
    end)
  end)
end)