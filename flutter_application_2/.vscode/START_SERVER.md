# Hướng dẫn chạy Backend Server

## Bước 1: Cài đặt Node.js (nếu chưa có)
1. Truy cập: https://nodejs.org/
2. Tải bản LTS (khuyến nghị)
3. Cài đặt và đảm bảo chọn "Add to PATH"
4. Khởi động lại PowerShell/VS Code

## Bước 2: Kiểm tra Node.js đã cài đặt
```powershell
node -v
npm -v
```

## Bước 3: Cài đặt dependencies (nếu chưa có node_modules)
```powershell
cd .vscode
npm install
```

## Bước 4: Chạy server
```powershell
node server.js
```

Hoặc sử dụng npm script:
```powershell
npm start
```

## Lưu ý:
- Đảm bảo MySQL/SQL Server đã được cấu hình đúng trong `db.js` hoặc `dbconfig.js`
- Server sẽ chạy tại http://localhost:4567 (hoặc port tiếp theo nếu 4567 đã được sử dụng)

