#!/bin/bash

# LSP 自動化驗證系統 - Shell 包裝腳本
# 用於執行 Neovim LSP 驗證並生成報告

set -e  # 遇到錯誤立即退出

# 腳本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_FILE="${SCRIPT_DIR}/validation.log"
REPORT_FILE="${SCRIPT_DIR}/validation_report.txt"
JSON_REPORT_FILE="${SCRIPT_DIR}/validation_report.json"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 使用說明
usage() {
    echo "LSP 自動化驗證系統"
    echo ""
    echo "用法: $0 [選項]"
    echo ""
    echo "選項:"
    echo "  -f, --format FORMAT    輸出格式 (readable|json|both) [預設: readable]"
    echo "  -o, --output FILE      輸出檔案路徑 [預設: 標準輸出]"
    echo "  -v, --verbose         詳細輸出模式"
    echo "  -h, --help            顯示此說明"
    echo ""
    echo "範例:"
    echo "  $0                     # 執行驗證並輸出可讀報告"
    echo "  $0 -f json            # 輸出 JSON 格式報告"
    echo "  $0 -f both -v         # 同時輸出兩種格式，詳細模式"
    echo "  $0 -o report.txt      # 將報告儲存到檔案"
}

# 記錄函數
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "DEBUG")
            if [[ "$VERBOSE" == "true" ]]; then
                echo -e "${BLUE}[DEBUG]${NC} $message"
            fi
            ;;
    esac

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# 檢查環境
check_environment() {
    log "INFO" "檢查環境..."

    # 檢查 Neovim
    if ! command -v nvim &> /dev/null; then
        log "ERROR" "未找到 Neovim，請先安裝 Neovim"
        exit 1
    fi

    local nvim_version=$(nvim --version | head -n1)
    log "INFO" "找到 Neovim: $nvim_version"

    # 檢查配置目錄
    if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
        log "ERROR" "Neovim 配置目錄不存在: $NVIM_CONFIG_DIR"
        exit 1
    fi

    # 檢查測試檔案
    local test_samples_dir="${SCRIPT_DIR}/samples"
    if [[ ! -d "$test_samples_dir" ]]; then
        log "ERROR" "測試樣本目錄不存在: $test_samples_dir"
        exit 1
    fi

    # 檢查 Lua 驗證腳本
    local lua_script="${SCRIPT_DIR}/validate-lsp.lua"
    if [[ ! -f "$lua_script" ]]; then
        log "ERROR" "Lua 驗證腳本不存在: $lua_script"
        exit 1
    fi

    log "INFO" "環境檢查完成"
}

# 執行 LSP 驗證
run_validation() {
    local format=$1
    local output_file=$2

    log "INFO" "開始執行 LSP 驗證..."
    log "DEBUG" "格式: $format"
    log "DEBUG" "輸出檔案: ${output_file:-'標準輸出'}"

    # 進入 Neovim 配置目錄
    cd "$NVIM_CONFIG_DIR"

    # 準備 Neovim 命令
    local nvim_cmd="nvim --headless --noplugin"
    nvim_cmd+=" -c 'set runtimepath+=${SCRIPT_DIR}'"
    nvim_cmd+=" -c 'luafile ${SCRIPT_DIR}/validate-lsp.lua'"
    nvim_cmd+=" -c 'lua print(require(\"validate-lsp\").run_validation(\"${format}\"))'"
    nvim_cmd+=" -c 'qa!'"

    log "DEBUG" "執行命令: $nvim_cmd"

    # 執行驗證並捕獲輸出
    local temp_output=$(mktemp)
    if eval "$nvim_cmd" > "$temp_output" 2>&1; then
        local validation_result=$(cat "$temp_output")

        # 輸出結果
        if [[ -n "$output_file" ]]; then
            echo "$validation_result" > "$output_file"
            log "INFO" "報告已儲存到: $output_file"
        else
            echo "$validation_result"
        fi

        log "INFO" "LSP 驗證完成"
        rm -f "$temp_output"
        return 0
    else
        log "ERROR" "LSP 驗證失敗"
        log "ERROR" "錯誤輸出:"
        cat "$temp_output" >&2
        rm -f "$temp_output"
        return 1
    fi
}

# 清理函數
cleanup() {
    log "DEBUG" "執行清理..."
    # 清理臨時檔案
    find /tmp -name "nvim*" -user "$(whoami)" -mtime +1 -delete 2>/dev/null || true
}

# 主要執行函數
main() {
    local format="readable"
    local output_file=""
    local run_both=false

    # 解析命令列參數
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--format)
                format="$2"
                if [[ "$format" == "both" ]]; then
                    run_both=true
                    format="readable"
                fi
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log "ERROR" "未知選項: $1"
                usage
                exit 1
                ;;
        esac
    done

    # 驗證格式參數
    case $format in
        readable|json)
            ;;
        *)
            log "ERROR" "無效的格式: $format (支援: readable, json, both)"
            exit 1
            ;;
    esac

    # 初始化
    log "INFO" "=== LSP 自動化驗證系統啟動 ==="
    mkdir -p "$(dirname "$LOG_FILE")"
    > "$LOG_FILE"  # 清空日誌檔案

    # 註冊清理函數
    trap cleanup EXIT

    # 執行主要流程
    check_environment

    if [[ "$run_both" == "true" ]]; then
        # 執行兩種格式
        log "INFO" "生成可讀格式報告..."
        run_validation "readable" "${REPORT_FILE}"

        log "INFO" "生成 JSON 格式報告..."
        run_validation "json" "${JSON_REPORT_FILE}"

        log "INFO" "已生成兩種格式報告:"
        log "INFO" "  - 可讀格式: ${REPORT_FILE}"
        log "INFO" "  - JSON 格式: ${JSON_REPORT_FILE}"
    else
        # 執行指定格式
        run_validation "$format" "$output_file"
    fi

    log "INFO" "=== LSP 自動化驗證系統完成 ==="
}

# 執行主函數
main "$@"