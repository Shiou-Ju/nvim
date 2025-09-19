// Java LSP 測試檔案
// 用於驗證 Java LSP (jdtls) 的各種功能

import java.util.*;
import java.util.stream.Collectors;

/**
 * 用戶管理類別
 * 用於測試 Java LSP 功能
 */
public class UserManager {
    private List<User> users;
    private Map<Integer, User> userCache;

    /**
     * 建構子
     */
    public UserManager() {
        this.users = new ArrayList<>();
        this.userCache = new HashMap<>();
        initializeUsers();
    }

    /**
     * 初始化用戶資料
     */
    private void initializeUsers() {
        addUser(new User(1, "Alice", "alice@example.com", UserRole.ADMIN));
        addUser(new User(2, "Bob", "bob@example.com", UserRole.USER));
        addUser(new User(3, "Charlie", "charlie@example.com", UserRole.USER));
    }

    /**
     * 添加用戶
     * @param user 要添加的用戶
     */
    public void addUser(User user) {
        if (user != null && !users.contains(user)) {
            users.add(user);
            userCache.put(user.getId(), user);
        }
    }

    /**
     * 根據 ID 查找用戶
     * @param id 用戶 ID
     * @return 用戶對象，如果不存在則返回 null
     */
    public User findUserById(int id) {
        return userCache.get(id);
    }

    /**
     * 獲取所有活躍用戶
     * @return 活躍用戶列表
     */
    public List<User> getActiveUsers() {
        return users.stream()
                .filter(User::isActive)
                .collect(Collectors.toList());
    }

    /**
     * 根據角色獲取用戶
     * @param role 用戶角色
     * @return 指定角色的用戶列表
     */
    public List<User> getUsersByRole(UserRole role) {
        return users.stream()
                .filter(user -> user.getRole() == role)
                .collect(Collectors.toList());
    }

    /**
     * 更新用戶狀態
     * @param id 用戶 ID
     * @param active 新的活躍狀態
     * @return 是否更新成功
     */
    public boolean updateUserStatus(int id, boolean active) {
        User user = findUserById(id);
        if (user != null) {
            user.setActive(active);
            return true;
        }
        return false;
    }

    /**
     * 刪除用戶
     * @param id 要刪除的用戶 ID
     * @return 是否刪除成功
     */
    public boolean removeUser(int id) {
        User user = findUserById(id);
        if (user != null) {
            users.remove(user);
            userCache.remove(id);
            return true;
        }
        return false;
    }

    /**
     * 獲取用戶總數
     * @return 用戶數量
     */
    public int getUserCount() {
        return users.size();
    }

    /**
     * 主方法 - 測試功能
     */
    public static void main(String[] args) {
        UserManager manager = new UserManager();

        // 測試查找功能
        User user = manager.findUserById(1);
        if (user != null) {
            System.out.println("找到用戶: " + user.getName());
        }

        // 測試添加用戶
        User newUser = new User(4, "Diana", "diana@example.com", UserRole.USER);
        manager.addUser(newUser);

        // 測試獲取活躍用戶
        List<User> activeUsers = manager.getActiveUsers();
        System.out.println("活躍用戶數量: " + activeUsers.size());

        // 測試角色篩選
        List<User> admins = manager.getUsersByRole(UserRole.ADMIN);
        System.out.println("管理員數量: " + admins.size());

        // 故意的錯誤 - 測試診斷功能
        String invalidAssignment = 123; // Type mismatch
        manager.nonExistentMethod(); // Method does not exist

        System.out.println("總用戶數: " + manager.getUserCount());
    }
}

/**
 * 用戶類別
 */
class User {
    private int id;
    private String name;
    private String email;
    private UserRole role;
    private boolean active;

    /**
     * 建構子
     */
    public User(int id, String name, String email, UserRole role) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
        this.active = true;
    }

    // Getters
    public int getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public UserRole getRole() { return role; }
    public boolean isActive() { return active; }

    // Setters
    public void setName(String name) { this.name = name; }
    public void setEmail(String email) { this.email = email; }
    public void setRole(UserRole role) { this.role = role; }
    public void setActive(boolean active) { this.active = active; }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        User user = (User) obj;
        return id == user.id;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return String.format("User{id=%d, name='%s', email='%s', role=%s, active=%s}",
                id, name, email, role, active);
    }
}

/**
 * 用戶角色枚舉
 */
enum UserRole {
    ADMIN("管理員"),
    USER("一般用戶"),
    GUEST("訪客");

    private final String description;

    UserRole(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}