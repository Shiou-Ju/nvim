// Telescope References 功能演示檔案
// 用於測試優化後的 gr 命令顯示效果

export interface DemoUser {
  id: number;
  name: string;
  email: string;
  isActive?: boolean;
}

// 這個函數會被多次引用，適合測試 gr 功能
export function createDemoUser(name: string, email: string): DemoUser {
  return {
    id: Math.random(),
    name,
    email,
    isActive: true
  };
}

export function updateDemoUser(user: DemoUser, updates: Partial<DemoUser>): DemoUser {
  return { ...user, ...updates };
}

export function getDemoUserById(users: DemoUser[], id: number): DemoUser | undefined {
  return users.find(user => user.id === id);
}

// === 測試用例：多個引用點 ===

// 1. createDemoUser 的多個引用
const user1 = createDemoUser("Alice", "alice@example.com");
const user2 = createDemoUser("Bob", "bob@example.com");
const user3 = createDemoUser("Charlie", "charlie@example.com");

// 2. DemoUser 介面的多個引用
const users: DemoUser[] = [user1, user2, user3];
const activeUser: DemoUser = updateDemoUser(user1, { isActive: true });

// 3. 變數引用鏈
const foundUser = getDemoUserById(users, user1.id);
const modifiedUser = updateDemoUser(foundUser || user1, { name: "Updated Name" });

// === 測試指引 ===
//
// 🎯 **Telescope References 測試步驟**：
//
// 1. **測試函數引用**：
//    - 將游標放在第 9 行的 "createDemoUser" 函數名上
//    - 按 "gr" → 應該彈出 Telescope 視窗，顯示所有引用位置
//    - 預期顯示：第 32, 33, 34 行的呼叫處
//
// 2. **測試介面引用**：
//    - 將游標放在第 4 行的 "DemoUser" 介面名上
//    - 按 "gr" → 應該顯示所有使用此介面的位置
//    - 預期顯示：函數參數、返回型別、變數宣告等處
//
// 3. **測試變數引用**：
//    - 將游標放在第 32 行的 "user1" 變數上
//    - 按 "gr" → 應該顯示 user1 被使用的所有地方
//    - 預期顯示：第 37, 40, 41 行等引用處
//
// 🌟 **Telescope 優化功能驗證**：
// - ✅ 條列式顯示：每個引用一行，包含檔案名稱和行號
// - ✅ 程式碼預覽：右側顯示引用上下文的程式碼片段
// - ✅ 快速導航：Enter 鍵跳轉，Esc 鍵取消
// - ✅ 模糊搜尋：可以輸入關鍵字過濾結果
// - ✅ 語法高亮：程式碼預覽保持語法顏色

export { DemoUser, createDemoUser, updateDemoUser, getDemoUserById };