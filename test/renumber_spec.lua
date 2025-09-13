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
end)