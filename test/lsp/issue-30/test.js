// LSP 功能測試檔案 - Issue #30 JavaScript
// 測試 JavaScript 環境下的 LSP 導航功能

/**
 * 創建新用戶
 * @param {string} name 用戶名稱
 * @param {string} email 用戶郵箱
 * @returns {Object} 用戶物件
 */
function createUser(name, email) {
  return {
    id: Math.random(),
    name,
    email,
    isActive: true
  };
}

/**
 * 根據 ID 查找用戶
 * @param {Array} users 用戶陣列
 * @param {number} id 用戶 ID
 * @returns {Object|undefined} 找到的用戶或 undefined
 */
function getUserById(users, id) {
  return users.find(user => user.id === id);
}

/**
 * 更新用戶狀態
 * @param {Object} user 用戶物件
 * @param {boolean} isActive 是否啟用
 * @returns {Object} 更新後的用戶物件
 */
function updateUserStatus(user, isActive) {
  return { ...user, isActive };
}

// === LSP 功能測試指引 ===
//
// 🎯 測試 gd (跳到定義)：
// 1. 將游標放在下面的 "createUser" 上，按 gd → 應跳到第 7 行函數定義
// 2. 將游標放在 "getUserById" 上，按 gd → 應跳到第 19 行函數定義
const newUser = createUser("Bob", "bob@example.com");

// 🎯 測試 gr (顯示所有引用)：
// 1. 將游標放在 "createUser" 函數名上，按 gr → 應顯示所有調用的位置
// 2. 將游標放在 "newUser" 變數上，按 gr → 應顯示所有使用該變數的位置
const foundUser = getUserById([newUser], newUser.id);

// 🎯 測試 K (顯示文檔)：
// 1. 將游標放在 "Array.find" 上，按 K → 應顯示 find 方法的文檔
// 2. 將游標放在 "JSON.stringify" 上，按 K → 應顯示 JSON.stringify 的說明
console.log("User data:", JSON.stringify(foundUser, null, 2));

// 🎯 測試 gD (跳到宣告)：
// 1. 將游標放在變數使用處，按 gD → 應跳到最初宣告位置
const activeUser = updateUserStatus(newUser, false);

// 🎯 測試自動補全：
// 1. 輸入 "activeUser." → 應該顯示物件屬性
// 2. 輸入 "console." → 應該顯示 console 物件的方法

// 🎯 測試函數簽名提示：
// 1. 輸入 "createUser(" → 應該顯示參數提示
// 2. 輸入 "updateUserStatus(" → 應該顯示參數說明

module.exports = {
  createUser,
  getUserById,
  updateUserStatus
};