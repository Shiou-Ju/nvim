// JavaScript LSP 測試檔案
// 用於驗證 LSP 功能：定義跳轉、hover 資訊、引用查找、診斷

/**
 * 用戶資料處理類別
 */
class UserManager {
    constructor() {
        this.users = [];
        this.initializeData();
    }

    /**
     * 初始化用戶資料
     */
    initializeData() {
        this.users = [
            { id: 1, name: "Alice", email: "alice@test.com", active: true },
            { id: 2, name: "Bob", email: "bob@test.com", active: false },
            { id: 3, name: "Charlie", email: "charlie@test.com", active: true }
        ];
    }

    /**
     * 根據 ID 查找用戶
     * @param {number} id - 用戶 ID
     * @returns {Object|null} 用戶對象或 null
     */
    findUserById(id) {
        return this.users.find(user => user.id === id) || null;
    }

    /**
     * 獲取所有活躍用戶
     * @returns {Array} 活躍用戶列表
     */
    getActiveUsers() {
        return this.users.filter(user => user.active);
    }

    /**
     * 添加新用戶
     * @param {Object} userData - 用戶資料
     */
    addUser(userData) {
        const newUser = {
            id: Math.max(...this.users.map(u => u.id)) + 1,
            ...userData,
            active: true
        };
        this.users.push(newUser);
        return newUser;
    }

    /**
     * 更新用戶狀態
     * @param {number} id - 用戶 ID
     * @param {boolean} status - 新狀態
     */
    updateUserStatus(id, status) {
        const user = this.findUserById(id);
        if (user) {
            user.active = status;
            return true;
        }
        return false;
    }
}

// 工具函數 - 測試函數定義跳轉
function formatUserInfo(user) {
    if (!user) {
        return "用戶不存在";
    }
    return `${user.name} (${user.email}) - ${user.active ? "活躍" : "停用"}`;
}

// 驗證函數 - 測試參數和回傳值
function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// 使用範例 - 測試 go to references
const userManager = new UserManager();

// 測試查找功能
const user1 = userManager.findUserById(1);
console.log(formatUserInfo(user1));

// 測試添加用戶
const newUser = userManager.addUser({
    name: "Diana",
    email: "diana@test.com"
});

// 驗證 email
if (validateEmail(newUser.email)) {
    console.log("Email 格式正確");
}

// 測試狀態更新
userManager.updateUserStatus(2, true);

// 獲取活躍用戶
const activeUsers = userManager.getActiveUsers();
console.log("活躍用戶數量:", activeUsers.length);

// 故意的錯誤 - 測試診斷功能
const undefinedVariable = someUndefinedVar; // ReferenceError
const invalidCall = userManager.nonExistentMethod(); // TypeError

// 顯示所有用戶
activeUsers.forEach(user => {
    console.log(formatUserInfo(user));
});

// 導出供其他模組使用
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        UserManager,
        formatUserInfo,
        validateEmail
    };
}