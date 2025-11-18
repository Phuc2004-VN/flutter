// /server.js

const express = require('express');
const cors = require('cors');
const app = express();
const UserService = require('./userService');
const jwt = require('jsonwebtoken'); // Cần JWT cho Forgot Password (Nếu muốn)

// ************ Cấu hình JWT (Dùng chung với index.js nếu cần) ************
const JWT_SECRET = 'YOUR_SUPER_SECRET_KEY'; 
const JWT_EXPIRY = '1h'; 
// ****************************************

app.use(cors());
app.use(express.json());

// Endpoint quên mật khẩu
app.post('/api/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ 
        message: 'Email là bắt buộc.' 
      });
    }

    // Kiểm tra email trong database
    const user = await UserService.findByEmail(email);
    
    if (!user) {
      // Luôn trả về thông báo chung để tránh tiết lộ email nào tồn tại
      return res.json({ 
        message: 'Nếu email tồn tại, chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu.' 
      });
    }

    // ✅ Thêm logic tạo token và link reset password
    const resetToken = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '15m' });
    // TODO: Cần lưu resetToken và resetTokenExpiry vào DB bằng UserService.updateResetToken
    // TODO: Gửi email với link: http://your-app/reset-password?token=${resetToken}
    
    res.json({ 
      message: 'Nếu email tồn tại, chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu.' 
    });
  } catch (error) {
    console.error('Error in forgot-password endpoint:', error);
    
    // Phân loại lỗi để trả về message phù hợp
    if (error.code === 'ECONNREFUSED') {
      return res.status(500).json({ 
        message: 'Không thể kết nối đến database. Vui lòng thử lại sau.' 
      });
    }
    
    res.status(500).json({ 
      message: 'Đã xảy ra lỗi khi xử lý yêu cầu.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Endpoint đổi mật khẩu (Dùng UserService đã cập nhật)
app.post('/api/change-password', async (req, res) => {
  try {
    const { userId, currentPassword, newPassword } = req.body;

    if (!userId || !currentPassword || !newPassword) {
      return res.status(400).json({
        message: 'Vui lòng cung cấp đầy đủ thông tin.'
      });
    }

    // Kiểm tra mật khẩu hiện tại (dùng bcrypt trong UserService)
    const isPasswordValid = await UserService.verifyCurrentPassword(userId, currentPassword);
    if (!isPasswordValid) {
      return res.status(400).json({
        message: 'Mật khẩu hiện tại không đúng.'
      });
    }

    // Đổi mật khẩu (sẽ hash newPassword trong UserService)
    await UserService.changePassword(userId, newPassword);

    res.json({
      message: 'Đổi mật khẩu thành công.'
    });
  } catch (error) {
    console.error('Error in change-password endpoint:', error);
    res.status(500).json({
      message: 'Đã xảy ra lỗi khi đổi mật khẩu.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Thử các port khác nhau nếu port chính không khả dụng
const tryPort = (port) => {
  return new Promise((resolve, reject) => {
    const server = app.listen(port)
      .on('error', (err) => {
        if (err.code === 'EADDRINUSE') {
          console.log(`Port ${port} đang được sử dụng, thử port ${port + 1}...`);
          resolve(tryPort(port + 1));
        } else {
          reject(err);
        }
      })
      .on('listening', () => {
        console.log(`Server đang chạy tại http://localhost:${port}`);
        resolve(server);
      });
  });
};

// Bắt đầu server với port 4567, nếu không khả dụng sẽ thử các port tiếp theo
tryPort(4567).catch(err => {
  console.error('Không thể khởi động server:', err);
  process.exit(1);
});