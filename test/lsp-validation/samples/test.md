# Markdown LSP 測試檔案

這個檔案用於測試 Markdown LSP (marksman) 的各種功能。

## 標題層級測試

### 三級標題
#### 四級標題
##### 五級標題

## 連結和引用測試

### 內部連結
- [跳轉到程式碼區塊](#程式碼區塊測試)
- [跳轉到清單區域](#清單項目測試)
- [跳轉到表格](#表格測試)

### 外部連結
- [GitHub](https://github.com)
- [Markdown 語法](https://www.markdownguide.org/basic-syntax/)

## 程式碼區塊測試

```javascript
// JavaScript 程式碼區塊
function helloWorld() {
    console.log("Hello, World!");
}
```

```typescript
// TypeScript 程式碼區塊
interface User {
    name: string;
    age: number;
}

const user: User = {
    name: "Alice",
    age: 30
};
```

```bash
# Bash 指令
ls -la
cd /path/to/directory
```

## 清單項目測試

### 無序清單
- 項目一
- 項目二
  - 子項目 2.1
  - 子項目 2.2
- 項目三

### 有序清單
1. 第一項
2. 第二項
   1. 子項目 2.1
   2. 子項目 2.2
3. 第三項

### 任務清單
- [x] 已完成任務
- [ ] 待完成任務
- [ ] 另一個待完成任務

## 表格測試

| 語言 | LSP 服務器 | 狀態 |
|------|-----------|------|
| TypeScript | ts_ls | ✅ 活躍 |
| JavaScript | ts_ls | ✅ 活躍 |
| Markdown | marksman | ✅ 活躍 |
| Java | jdtls | ⚠️ 可選 |

## 強調文字測試

- **粗體文字**
- *斜體文字*
- ~~刪除線文字~~
- `行內程式碼`

## 引用區塊測試

> 這是一個引用區塊。
>
> 可以包含多行內容。
>
> > 這是嵌套引用。

## 分隔線測試

---

## 圖片測試

![測試圖片](https://via.placeholder.com/300x200)

## 腳註測試

這是一個包含腳註的段落[^1]。

另一個腳註範例[^note]。

[^1]: 這是第一個腳註的內容。
[^note]: 這是命名腳註的內容。

## 數學公式測試

行內數學：$E = mc^2$

區塊數學：
$$
\sum_{i=1}^{n} x_i = x_1 + x_2 + \cdots + x_n
$$

## HTML 標籤測試

<details>
<summary>點擊展開詳細內容</summary>

這是隱藏的內容，只有點擊上方標題才會顯示。

可以包含：
- 清單項目
- **格式化文字**
- `程式碼`

</details>

## 故意錯誤測試

以下包含一些故意的 Markdown 語法錯誤，用於測試診斷功能：

1. 無效連結：[無效連結](invalid-link)
2. 錯誤的標題：### 標題後面有多餘空格
3. 不匹配的括號：[未完成連結(missing-closing-bracket
4. 無效的程式碼區塊：
```
未指定語言的程式碼區塊
```

## 參考連結定義

[github]: https://github.com "GitHub 官網"
[markdown-guide]: https://www.markdownguide.org/ "Markdown 指南"

使用參考連結：
- 訪問 [GitHub][github]
- 查看 [Markdown 指南][markdown-guide]

---

*本檔案用於測試 Markdown LSP 的各種功能，包括但不限於：*
- *定義跳轉 (gd)*
- *引用查找 (gr)*
- *Hover 資訊 (K)*
- *診斷功能 (語法檢查)*