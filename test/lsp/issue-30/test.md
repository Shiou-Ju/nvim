# LSP 功能測試檔案 - Issue #30 Markdown
測試 Markdown LSP (marksman) 的導航功能

## 🎯 Markdown LSP 測試指引

### 測試連結跳轉功能
這裡測試內部連結和標題跳轉功能：

- [跳到用戶介紹章節](#用戶介紹)
- [跳到函數說明](#函數說明)
- [跳到測試結果](#測試結果)

### 用戶介紹
這是用戶介紹章節的內容。

#### 基本資訊
- 姓名：測試用戶
- 郵箱：test@example.com

### 函數說明

#### createUser 函數
```javascript
function createUser(name, email) {
  return { id: Math.random(), name, email };
}
```

#### getUserById 函數
```javascript
function getUserById(users, id) {
  return users.find(user => user.id === id);
}
```

### 🧪 LSP 功能驗證

**測試 gd (跳到定義)**：
1. 將游標放在上面的 [跳到用戶介紹章節](#用戶介紹) 連結上，按 gd
2. 應該跳轉到 "用戶介紹" 標題

**測試 gr (顯示引用)**：
1. 將游標放在 "## 用戶介紹" 標題上，按 gr
2. 應該顯示所有引用該標題的連結位置

**測試 K (顯示資訊)**：
1. 將游標放在連結上，按 K
2. 應該顯示連結的相關資訊

**測試自動補全**：
1. 輸入 `[連結文字](#` 應該自動補全標題列表
2. 輸入 `![圖片](` 應該提示圖片路徑

### 🔗 外部連結測試
- [GitHub](https://github.com)
- [Neovim 官網](https://neovim.io)

### 📝 代碼區塊測試

```typescript
// TypeScript 代碼區塊
interface User {
  id: number;
  name: string;
}
```

```python
# Python 代碼區塊
def hello_world():
    return "Hello, World!"
```

### 測試結果

這裡記錄測試結果：

- [ ] gd 跳轉功能
- [ ] gr 引用功能
- [ ] K 顯示資訊功能
- [ ] 自動補全功能
- [ ] 連結驗證功能

### 📚 參考資料
- [Marksman LSP 文檔](https://github.com/artempyanykh/marksman)
- [Markdown 語法指南](https://commonmark.org)