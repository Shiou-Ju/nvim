// TypeScript LSP 測試檔案
// 用於驗證 LSP 功能：定義跳轉、hover 資訊、引用查找、診斷

interface User {
    id: number;
    name: string;
    email: string;
}

class UserService {
    private users: User[] = [];

    constructor() {
        this.initializeUsers();
    }

    private initializeUsers(): void {
        this.users = [
            { id: 1, name: "Alice", email: "alice@example.com" },
            { id: 2, name: "Bob", email: "bob@example.com" }
        ];
    }

    public getUserById(id: number): User | undefined {
        return this.users.find(user => user.id === id);
    }

    public addUser(user: User): void {
        this.users.push(user);
    }

    public getAllUsers(): User[] {
        return this.users;
    }

    // 故意的語法錯誤，用於測試診斷功能
    public invalidMethod(): string {
        return 123; // Type error: number is not assignable to string
    }
}

// 函數定義 - 測試 gd (go to definition)
function processUser(user: User): string {
    return `User: ${user.name} (${user.email})`;
}

// 使用範例 - 測試 gr (go to references)
const userService = new UserService();
const user = userService.getUserById(1);

if (user) {
    console.log(processUser(user));
}

// 添加新用戶
userService.addUser({
    id: 3,
    name: "Charlie",
    email: "charlie@example.com"
});

// 顯示所有用戶
const allUsers = userService.getAllUsers();
allUsers.forEach(user => {
    console.log(processUser(user));
});

// 測試 hover 功能 - 將游標停在這些符號上應該顯示類型資訊
export { User, UserService, processUser };