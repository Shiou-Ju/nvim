// gd vs gD 差異示例

// === 宣告 (Declaration) ===
declare function externalFunction(x: number): string;  // 只有宣告，沒有實作

// === 定義 (Definition) ===
function localFunction(x: number): string {             // 有實作的定義
  return x.toString();
}

// === 使用範例 ===
const result1 = externalFunction(42);  // 游標放這裡測試
const result2 = localFunction(42);     // 游標放這裡測試

// === 測試說明 ===
//
// 在 externalFunction 上：
// - gd (go to definition): 找不到實作，可能跳到宣告或顯示錯誤
// - gD (go to declaration): 跳到第 4 行的 declare 宣告
//
// 在 localFunction 上：
// - gd (go to definition): 跳到第 7 行的函數實作
// - gD (go to declaration): 通常與 gd 相同，因為宣告和定義在同一處