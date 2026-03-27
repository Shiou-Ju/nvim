#!/bin/bash
# convert-base64-images.sh
# 將 Markdown 檔案中的 base64 data URI 圖片提取為本地檔案
# 並將引用替換為相對路徑，使 image.nvim 能渲染圖片
#
# 用法：
#   convert-base64-images.sh <file.md> [file2.md ...]
#   convert-base64-images.sh /path/to/*.md

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "用法: $0 <markdown-file> [markdown-file ...]"
    echo ""
    echo "範例："
    echo "  $0 筆記.md"
    echo "  $0 /path/to/*.md"
    exit 1
fi

total_images=0
total_files=0

for md_file in "$@"; do
    if [ ! -f "$md_file" ]; then
        echo "[跳過] 找不到檔案: $md_file"
        continue
    fi

    # 取得檔案資訊
    dir="$(cd "$(dirname "$md_file")" && pwd)"
    filename="$(basename "$md_file")"
    stem="${filename%.md}"
    images_dir="${dir}/${stem}_images"
    bak_file="${dir}/${filename}.bak"

    # 檢查是否有 base64 圖片引用
    # 格式: [imageN]: <data:image/TYPE;base64,...>
    if ! grep -qE '^\[image[0-9]+\]: <data:image/' "$md_file"; then
        echo "[跳過] 無 base64 圖片引用: $md_file"
        continue
    fi

    # 備份原始檔案
    cp "$md_file" "$bak_file"
    echo "[備份] $bak_file"

    # 建立圖片目錄
    mkdir -p "$images_dir"

    file_images=0

    # 逐行處理，提取 base64 引用
    # 使用暫存檔避免在迴圈中讀寫同一檔案
    tmp_file="$(mktemp)"
    cp "$md_file" "$tmp_file"

    while IFS= read -r line || [[ -n "$line" ]]; do
        # 匹配 [imageN]: <data:image/TYPE;base64,DATA>
        if echo "$line" | grep -qE '^\[image[0-9]+\]: <data:image/'; then
            # 提取引用名稱 (例如 image1)
            ref_name="$(echo "$line" | sed -n 's/^\[\(image[0-9]*\)\]: <data:image\/.*/\1/p')"

            # 提取圖片格式 (png, jpeg, gif, webp 等)
            img_type="$(echo "$line" | sed -n 's/^\[image[0-9]*\]: <data:image\/\([^;]*\);base64,.*/\1/p')"

            # 正規化副檔名
            case "$img_type" in
                jpeg) ext="jpg" ;;
                svg+xml) ext="svg" ;;
                *) ext="$img_type" ;;
            esac

            # 提取 base64 資料（去掉 data URI 前綴和尾端 >）
            b64_data="$(echo "$line" | sed 's/^\[image[0-9]*\]: <data:image\/[^;]*;base64,//' | sed 's/>$//')"

            # 解碼並寫入檔案
            img_file="${images_dir}/${ref_name}.${ext}"
            echo "$b64_data" | base64 -D > "$img_file" 2>/dev/null

            if [ -s "$img_file" ]; then
                rel_path="${stem}_images/${ref_name}.${ext}"
                # 將 ![...][imageN] 轉為 inline 格式 ![...](path)，image.nvim 才能渲染
                sed -i '' "s|!\[\([^]]*\)\]\[${ref_name}\]|![\1](${rel_path})|g" "$tmp_file"
                # 刪除 reference 定義行
                sed -i '' "/^\[${ref_name}\]: <data:image\//d" "$tmp_file"

                file_images=$((file_images + 1))
                echo "  [提取] ${ref_name}.${ext} ($(du -h "$img_file" | cut -f1 | xargs))"
            else
                echo "  [錯誤] 解碼失敗: ${ref_name}"
                rm -f "$img_file"
            fi
        fi
    done < "$md_file"

    # 將處理結果寫回原檔
    cp "$tmp_file" "$md_file"
    rm -f "$tmp_file"

    if [ "$file_images" -gt 0 ]; then
        total_images=$((total_images + file_images))
        total_files=$((total_files + 1))
        echo "[完成] $md_file: 提取 ${file_images} 張圖片 -> ${images_dir}/"
    fi
done

echo ""
echo "=== 處理完畢 ==="
echo "處理檔案數: ${total_files}"
echo "提取圖片數: ${total_images}"
