// LSP 功能測試檔案 - Issue #30 TypeScript
// 測試所有核心 LSP 導航功能

export interface User {
  id: number;
  name: string;
  email: string;
  isActive?: boolean;
}

export function createUser(name: string, email: string): User {
  return {
    id: Math.random(),
    name,
    email,
    isActive: true
  };
}

export function getUserById(users: User[], id: number): User | undefined {
  return users.find(user => user.id === id);
}

export function updateUserStatus(user: User, isActive: boolean): User {
  return { ...user, isActive };
}

// === LSP 功能測試指引 ===
//
// 🎯 測試 gd (跳到定義)：
// 1. 將游標放在下面的 "createUser" 上，按 gd → 應跳到第 9 行函數定義
// 2. 將游標放在 "User" 類型上，按 gd → 應跳到第 4 行介面定義
const newUser = createUser("Alice", "alice@example.com");

// 🎯 測試 gr (顯示所有引用)：
// 1. 將游標放在 "User" 介面名稱上，按 gr → 應顯示所有使用 User 的位置
// 2. 將游標放在 "createUser" 函數名上，按 gr → 應顯示所有調用的位置
const foundUser = getUserById([newUser], newUser.id);

// 🎯 測試 K (顯示文檔)：
// 1. 將游標放在 "Math.random()" 上，按 K → 應顯示 Math.random 的 API 文檔
// 2. 將游標放在 "console.log" 上，按 K → 應顯示 console.log 的說明
console.log("User found:", foundUser?.name);

// 🎯 測試 gD (跳到宣告)：
// 1. 將游標放在變數使用處，按 gD → 應跳到最初宣告位置
const activeUser = updateUserStatus(newUser, false);

// 🎯 測試自動補全：
// 1. 輸入 "activeUser." → 應該顯示 id, name, email, isActive 屬性
// 2. 輸入 "Math." → 應該顯示 Math 物件的所有方法

// 🎯 測試錯誤診斷：
// 取消下面註解，檢查是否正確顯示類型錯誤
// const invalidUser: User = { name: "Bob" }; // 應顯示：缺少必需的 id 和 email 屬性

export { User, createUser, getUserById, updateUserStatus };