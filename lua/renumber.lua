local M = {}

-- 找到完整列表邊界的輔助函數
local function find_complete_list_boundaries(cursor_line, indent)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local start_line, end_line = cursor_line, cursor_line
  local indent_pattern = indent:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

  -- 向上搜尋列表開始
  for i = cursor_line - 1, 1, -1 do
    local line = lines[i]
    if line:match("^" .. indent_pattern .. "%d+%.%s+") then
      start_line = i
    elseif not line:match("^%s*$") and not line:match("^#+%s+") then
      -- 遇到非空行且非列表項且非標題就停止
      break
    end
  end

  -- 向下搜尋列表結束
  for i = cursor_line + 1, #lines do
    local line = lines[i]
    if line:match("^" .. indent_pattern .. "%d+%.%s+") then
      end_line = i
    elseif not line:match("^%s*$") and not line:match("^#+%s+") then
      -- 遇到非空行且非列表項且非標題就停止
      break
    end
  end

  return start_line, end_line
end

-- 重新編號整個列表（當前章節）
M.renumber_entire_list = function()
  vim.notify("開始執行 renumber_entire_list", vim.log.levels.INFO)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = vim.api.nvim_get_current_line()
  vim.notify("游標位置：行 " .. cursor_pos[1] .. "，內容：" .. current_line, vim.log.levels.INFO)

  -- 檢查當前行是否在數字列表中
  local indent, num, content = current_line:match("^(%s*)(%d+)%.%s+(.*)")
  if not indent then
    vim.notify("游標不在數字列表項上", vim.log.levels.WARN)
    return
  end
  vim.notify("檢測到列表項：縮排='" .. indent .. "'，編號=" .. num, vim.log.levels.INFO)

  -- 找到整個列表的邊界
  local start_line, end_line = find_complete_list_boundaries(cursor_pos[1], indent)
  vim.notify("邊界檢測結果：start_line=" .. start_line .. "，end_line=" .. end_line, vim.log.levels.INFO)

  -- 重新編號整個列表
  local counter = 1
  local processed_count = 0
  for i = start_line, end_line do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if not line then
      vim.notify("第 " .. i .. " 行為空，跳出迴圈", vim.log.levels.WARN)
      break
    end

    vim.notify("檢查第 " .. i .. " 行：" .. line, vim.log.levels.INFO)
    -- 檢查是否為數字列表項（不限制縮排）
    local current_indent, old_num, line_content = line:match("^(%s*)(%d+)%.%s+(.*)")
    if current_indent and old_num and line_content then
      local new_line = current_indent .. counter .. ". " .. line_content
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, {new_line})
      vim.notify("更新第 " .. i .. " 行：" .. old_num .. " → " .. counter, vim.log.levels.INFO)
      counter = counter + 1
      processed_count = processed_count + 1
    else
      vim.notify("第 " .. i .. " 行非列表項，跳過", vim.log.levels.INFO)
    end
  end

  vim.notify("完成重新編號：處理 " .. processed_count .. " 個列表項", vim.log.levels.INFO)
end

-- 重新編號整個章節範圍
M.renumber_section = function(start_line, end_line)
  local counter = 1
  for i = start_line, end_line do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if line then
      local indent, old_num, content = line:match("^(%s*)(%d+)%.%s+(.*)")
      if indent and old_num and content then
        local new_line = indent .. counter .. ". " .. content
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {new_line})
        counter = counter + 1
      end
    end
  end
end

-- 重新編號所有章節（全文檔處理）
M.renumber_all_sections = function()
  vim.notify("開始處理全文檔章節重新編號", vim.log.levels.INFO)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local in_list = false
  local list_start = nil

  for i = 1, #lines do
    local line = lines[i]

    -- 遇到標題，結束前一個列表
    if line:match("^##+%s+") then
      if in_list and list_start then
        vim.notify("處理章節列表：行 " .. list_start .. " 到 " .. (i - 1), vim.log.levels.INFO)
        M.renumber_section(list_start, i - 1)
      end
      in_list = false
      list_start = nil

    -- 遇到數字列表項
    elseif line:match("^%s*%d+%.%s+") then
      if not in_list then
        list_start = i
        in_list = true
      end

    -- 遇到非列表非空行
    elseif not line:match("^%s*$") then
      if in_list and list_start then
        vim.notify("處理列表：行 " .. list_start .. " 到 " .. (i - 1), vim.log.levels.INFO)
        M.renumber_section(list_start, i - 1)
      end
      in_list = false
      list_start = nil
    end
  end

  -- 處理最後一個列表
  if in_list and list_start then
    vim.notify("處理最後列表：行 " .. list_start .. " 到 " .. #lines, vim.log.levels.INFO)
    M.renumber_section(list_start, #lines)
  end

  vim.notify("完成全文檔章節重新編號", vim.log.levels.INFO)
end

return M