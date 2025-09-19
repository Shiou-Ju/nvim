-- LSP 自動化驗證腳本
-- 用於檢測和報告各種程式語言的 LSP 功能狀態

local M = {}

-- 測試配置
local TEST_CONFIG = {
    timeout = 5000, -- 5秒超時
    test_files = {
        typescript = "test/lsp-validation/samples/test.ts",
        javascript = "test/lsp-validation/samples/test.js",
        markdown = "test/lsp-validation/samples/test.md",
        java = "test/lsp-validation/samples/Test.java"
    },
    test_positions = {
        typescript = {
            { line = 24, col = 20, symbol = "getUserById" },    -- 方法定義
            { line = 46, col = 15, symbol = "User" },           -- 介面
            { line = 58, col = 25, symbol = "userService" }     -- 變數
        },
        javascript = {
            { line = 35, col = 20, symbol = "findUserById" },   -- 方法定義
            { line = 82, col = 15, symbol = "userManager" },    -- 變數
            { line = 95, col = 20, symbol = "formatUserInfo" }  -- 函數呼叫
        },
        markdown = {
            { line = 15, col = 10, symbol = "程式碼區塊測試" },     -- 標題連結
            { line = 35, col = 5, symbol = "helloWorld" },      -- 程式碼內容
            { line = 8, col = 25, symbol = "#程式碼區塊測試" }      -- 內部連結
        },
        java = {
            { line = 41, col = 25, symbol = "findUserById" },   -- 方法定義
            { line = 120, col = 20, symbol = "UserManager" },   -- 類別
            { line = 140, col = 15, symbol = "User" }           -- 類別實例
        }
    }
}

-- 結果記錄
local results = {
    timestamp = os.date("%Y-%m-%d %H:%M:%S"),
    nvim_version = vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
    languages = {},
    summary = {
        total = 0,
        active = 0,
        health_score = 0
    }
}

-- 工具函數：等待條件滿足
local function wait_for_condition(condition, timeout)
    local start_time = vim.loop.hrtime()
    timeout = timeout or 3000

    while (vim.loop.hrtime() - start_time) / 1000000 < timeout do
        if condition() then
            return true
        end
        vim.wait(100)
    end
    return false
end

-- 工具函數：檢查 LSP 客戶端是否活躍
local function get_active_lsp_clients(bufnr)
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    return clients
end

-- 工具函數：測試 LSP 功能
local function test_lsp_function(bufnr, line, col, test_type)
    local success = false
    local error_msg = nil

    -- 設置游標位置
    vim.api.nvim_win_set_cursor(0, { line, col })

    if test_type == "definition" then
        -- 測試 go to definition
        local params = vim.lsp.util.make_position_params()
        local results_received = false
        local has_results = false

        vim.lsp.buf_request(bufnr, "textDocument/definition", params, function(err, result)
            results_received = true
            if err then
                error_msg = err.message
            elseif result and #result > 0 then
                has_results = true
                success = true
            end
        end)

        -- 等待結果
        if wait_for_condition(function() return results_received end, 3000) then
            success = has_results
        else
            error_msg = "Timeout waiting for definition response"
        end

    elseif test_type == "hover" then
        -- 測試 hover
        local params = vim.lsp.util.make_position_params()
        local results_received = false
        local has_results = false

        vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
            results_received = true
            if err then
                error_msg = err.message
            elseif result and result.contents then
                has_results = true
                success = true
            end
        end)

        if wait_for_condition(function() return results_received end, 3000) then
            success = has_results
        else
            error_msg = "Timeout waiting for hover response"
        end

    elseif test_type == "references" then
        -- 測試 find references
        local params = vim.lsp.util.make_position_params()
        params.context = { includeDeclaration = true }
        local results_received = false
        local has_results = false

        vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, result)
            results_received = true
            if err then
                error_msg = err.message
            elseif result and #result > 0 then
                has_results = true
                success = true
            end
        end)

        if wait_for_condition(function() return results_received end, 3000) then
            success = has_results
        else
            error_msg = "Timeout waiting for references response"
        end
    end

    return success, error_msg
end

-- 工具函數：測試診斷功能
local function test_diagnostics(bufnr)
    -- 等待診斷結果
    vim.wait(2000) -- 等待 LSP 處理檔案

    local diagnostics = vim.diagnostic.get(bufnr)
    return #diagnostics > 0
end

-- 測試單一語言的 LSP 功能
local function test_language_lsp(language, file_path)
    print(string.format("正在測試 %s LSP...", language))

    local lang_result = {
        status = "not_installed",
        clients = {},
        tests = {
            definition = false,
            hover = false,
            references = false,
            diagnostics = false
        },
        errors = {}
    }

    -- 檢查檔案是否存在
    local file_exists = vim.fn.filereadable(file_path) == 1
    if not file_exists then
        lang_result.errors[#lang_result.errors + 1] = "Test file not found: " .. file_path
        return lang_result
    end

    -- 開啟測試檔案
    vim.cmd("edit " .. file_path)
    local bufnr = vim.api.nvim_get_current_buf()

    -- 等待 LSP 啟動
    local lsp_attached = wait_for_condition(function()
        local clients = get_active_lsp_clients(bufnr)
        return #clients > 0
    end, 5000)

    if not lsp_attached then
        lang_result.errors[#lang_result.errors + 1] = "No LSP client attached"
        return lang_result
    end

    -- 獲取活躍的 LSP 客戶端
    local clients = get_active_lsp_clients(bufnr)
    lang_result.status = "active"

    for _, client in ipairs(clients) do
        lang_result.clients[#lang_result.clients + 1] = client.name
    end

    -- 獲取測試位置
    local positions = TEST_CONFIG.test_positions[language] or {}

    if #positions > 0 then
        local pos = positions[1] -- 使用第一個測試位置

        -- 測試各種 LSP 功能
        local def_success, def_error = test_lsp_function(bufnr, pos.line, pos.col, "definition")
        local hover_success, hover_error = test_lsp_function(bufnr, pos.line, pos.col, "hover")
        local ref_success, ref_error = test_lsp_function(bufnr, pos.line, pos.col, "references")

        lang_result.tests.definition = def_success
        lang_result.tests.hover = hover_success
        lang_result.tests.references = ref_success

        if def_error then lang_result.errors[#lang_result.errors + 1] = "Definition: " .. def_error end
        if hover_error then lang_result.errors[#lang_result.errors + 1] = "Hover: " .. hover_error end
        if ref_error then lang_result.errors[#lang_result.errors + 1] = "References: " .. ref_error end
    end

    -- 測試診斷功能
    lang_result.tests.diagnostics = test_diagnostics(bufnr)

    return lang_result
end

-- 生成人類可讀的報告
local function generate_readable_report()
    local report = {}

    table.insert(report, "=== LSP 自動化驗證報告 ===")
    table.insert(report, string.format("執行時間: %s", results.timestamp))
    table.insert(report, string.format("Neovim 版本: v%s", results.nvim_version))
    table.insert(report, "")

    -- 表格標題
    table.insert(report, "┌─────────────┬─────────┬─────┬─────┬─────┬──────────┐")
    table.insert(report, "│ Language    │ Status  │ gd  │ K   │ gr  │ Diag     │")
    table.insert(report, "├─────────────┼─────────┼─────┼─────┼─────┼──────────┤")

    -- 表格內容
    for lang, result in pairs(results.languages) do
        local status_icon = result.status == "active" and "✅ 正常" or
                           result.status == "not_installed" and "⚠️ 未裝" or "❌ 錯誤"

        local gd = result.tests.definition and "✓" or "✗"
        local hover = result.tests.hover and "✓" or "✗"
        local refs = result.tests.references and "✓" or "✗"
        local diag = result.tests.diagnostics and "✓" or "✗"

        if result.status ~= "active" then
            gd, hover, refs, diag = "-", "-", "-", "-"
        end

        table.insert(report, string.format("│ %-11s │ %-7s │ %-3s │ %-3s │ %-3s │ %-8s │",
                     lang:sub(1,11), status_icon, gd, hover, refs, diag))
    end

    table.insert(report, "└─────────────┴─────────┴─────┴─────┴─────┴──────────┘")
    table.insert(report, "")
    table.insert(report, string.format("整體健康度: %.0f%% (%d/%d 可用)",
                 results.summary.health_score * 100, results.summary.active, results.summary.total))

    -- 建議
    local suggestions = {}
    for lang, result in pairs(results.languages) do
        if result.status ~= "active" then
            table.insert(suggestions, string.format("安裝 %s LSP 以支援 %s 開發", lang, lang))
        elseif #result.errors > 0 then
            table.insert(suggestions, string.format("%s LSP 存在問題，需要檢查配置", lang))
        end
    end

    if #suggestions > 0 then
        table.insert(report, "建議:")
        for _, suggestion in ipairs(suggestions) do
            table.insert(report, "- " .. suggestion)
        end
    end

    return table.concat(report, "\n")
end

-- 生成 JSON 報告
local function generate_json_report()
    return vim.fn.json_encode(results)
end

-- 主要驗證函數
function M.run_validation(output_format)
    output_format = output_format or "readable"

    print("開始 LSP 自動化驗證...")

    -- 初始化結果
    results.languages = {}
    results.summary = { total = 0, active = 0, health_score = 0 }

    -- 測試各種語言
    for language, file_path in pairs(TEST_CONFIG.test_files) do
        results.languages[language] = test_language_lsp(language, file_path)
        results.summary.total = results.summary.total + 1

        if results.languages[language].status == "active" then
            results.summary.active = results.summary.active + 1
        end
    end

    -- 計算健康度
    if results.summary.total > 0 then
        results.summary.health_score = results.summary.active / results.summary.total
    end

    -- 生成報告
    if output_format == "json" then
        return generate_json_report()
    else
        return generate_readable_report()
    end
end

-- 命令介面
vim.api.nvim_create_user_command('LspValidate', function(opts)
    local format = opts.args and opts.args ~= "" and opts.args or "readable"
    local report = M.run_validation(format)
    print(report)
end, {
    nargs = '?',
    complete = function()
        return { 'readable', 'json' }
    end,
    desc = 'Run LSP validation and generate report'
})

return M