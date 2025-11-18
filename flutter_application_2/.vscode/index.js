const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const jwt = require('jsonwebtoken'); //Thêm JWT
const bcrypt = require('bcrypt'); //Thêm bcrypt
const dbConfig = require('./dbconfig');
const UserService = require('./userService');

const app = express();
app.use(cors());
app.use(express.json());

// Thêm route GET / này để test trên trình duyệt
app.get('/', (req, res) => {
  res.send('Server API đang chạy. Vui lòng test bằng /api/...');
});

// ************ Cấu hình JWT ************
const JWT_SECRET = 'YOUR_SUPER_SECRET_KEY'; // THAY THẾ KHÓA NÀY BẰNG MỘT CHUỖI DÀI VÀ BÍ MẬT!
const JWT_EXPIRY = '1h'; // Thời gian hiệu lực của token

// Middleware xác thực JWT (Tương đương JwtBearer)
const authenticateToken = (req, res, next) => {
  // Lấy token từ header Authorization
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Định dạng: Bearer TOKEN

  if (token == null) {
    return res.status(401).json({ message: 'Không có token, truy cập bị từ chối.' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    // Err sẽ chứa thông tin về thời gian hết hạn (expiration) nếu token lỗi
    if (err) {
      console.error('JWT verification error:', err.message);
      return res.status(403).json({ 
        message: 'Token không hợp lệ hoặc đã hết hạn.',
        error: err.message
      });
    }

    // Gán thông tin người dùng từ token vào req
    req.user = user; 
    next();
  });
};


// Đăng ký tài khoản (Cập nhật để HASH mật khẩu)
app.post('/api/register', async (req, res) => {
  const { username, email, password, role: bodyRole } = req.body;
  try {
    let pool = await sql.connect(dbConfig);

    // Kiểm tra username hoặc email đã tồn tại
    let check = await pool.request()
      .input('username', sql.VarChar, username)
      .input('email', sql.VarChar, email)
      .query('SELECT * FROM users WHERE username = @username OR email = @email');
    if (check.recordset.length > 0) {
      return res.status(400).json({ message: 'Username hoặc email đã tồn tại' });
    }

    //Băm (Hash) mật khẩu trước khi lưu
    const hashedPassword = await UserService.hashPassword(password);
    // Tạo hashedID cho user (nếu cần)
    const hashedID = await UserService.hashPassword(username + Date.now().toString());

    // Xác định vai trò (role) – mặc định là 'user'
    const role = bodyRole && bodyRole.trim() ? bodyRole.trim() : 'user';

    // Thêm user mới
    await pool.request()
      .input('username', sql.NVarChar, username)
      .input('email', sql.NVarChar, email)
      .input('password', sql.NVarChar, hashedPassword) // Lưu mật khẩu đã hash
      .input('role', sql.NVarChar, role)
      .input('created_at', sql.DateTime, new Date())
      .query('INSERT INTO users (username, email, password, role, created_at) VALUES (@username, @email, @password, @role, @created_at)');

    res.json({ message: 'Đăng ký thành công' });
  } catch (err) {
    console.error('Registration error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Đăng nhập (Cập nhật để KIỂM TRA HASH và TẠO JWT)
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body; // username có thể là email hoặc username
  try {
    // 1. Tìm user và lấy mật khẩu đã hash
    const user = await UserService.findUserWithHash(username); 

    if (!user) {
      return res.status(400).json({ message: 'Email hoặc mật khẩu không đúng' });
    }

    // 2. So sánh mật khẩu thô với mật khẩu đã hash
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ message: 'Email hoặc mật khẩu không đúng' });
    }

    // 3. Tạo Payload cho JWT
    const payload = { 
      id: user.id, 
      username: user.username, 
      email: user.email,
      role: user.role
    };

    // 4. Ký (Sign) token
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRY });

    // 5. Trả về token cho client
    res.json({
      message: 'Đăng nhập thành công',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      },
      token: token 
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Lấy thông tin user (Bảo vệ route này bằng JWT)
app.get('/api/user/:id', authenticateToken, async (req, res) => {
  // Đảm bảo người dùng chỉ có thể truy cập thông tin của chính họ
  if (req.user.id != req.params.id) {
    return res.status(403).json({ message: 'Bạn không có quyền truy cập thông tin user này.' });
  }
  
  try {
    let pool = await sql.connect(dbConfig);
    let result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT id, username, email, avatar_url, dob, gender, phone, role FROM users WHERE id = @id'); // Loại bỏ cột password
      
    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'User không tồn tại' });
    }
    res.json(result.recordset[0]);
  } catch (err) {
    console.error('Get user info error:', err);
    res.status(500).json({ message: err.message });
  }
});


// Cập nhật thông tin user (Bảo vệ route này bằng JWT)
app.put('/api/user/:id', authenticateToken, async (req, res) => {
  // Kiểm tra quyền tương tự
  if (req.user.id != req.params.id) {
    return res.status(403).json({ message: 'Bạn không có quyền cập nhật user này.' });
  }
  
  try {
    let pool = await sql.connect(dbConfig);
    // Lấy dữ liệu cũ
    let oldUser = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT * FROM users WHERE id = @id');
    if (oldUser.recordset.length === 0) {
      return res.status(404).json({ message: 'User không tồn tại' });
    }
    const oldData = oldUser.recordset[0];

    // Lấy từng trường: nếu có trong body thì lấy, không thì lấy từ oldData
    const username = req.body.username !== undefined ? req.body.username : oldData.username;
    const email = req.body.email !== undefined ? req.body.email : oldData.email;
    const avatar_url = req.body.avatar_url !== undefined ? req.body.avatar_url : oldData.avatar_url;
    const dob = req.body.dob !== undefined ? req.body.dob : oldData.dob;
    const gender = req.body.gender !== undefined ? req.body.gender : oldData.gender;
    const phone = req.body.phone !== undefined ? req.body.phone : oldData.phone;

    await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('username', sql.NVarChar, username)
      .input('email', sql.NVarChar, email)
      .input('avatar_url', sql.NVarChar, avatar_url)
      .input('dob', sql.Date, dob || null)
      .input('gender', sql.NVarChar, gender)
      .input('phone', sql.NVarChar, phone)
      .query(`
        UPDATE users SET 
          username = @username, 
          email = @email, 
          avatar_url = @avatar_url, 
          dob = @dob, 
          gender = @gender, 
          phone = @phone
        WHERE id = @id
      `);
    res.json({ message: 'Cập nhật thành công' });
  } catch (err) {
    console.error('Update user info error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Đổi mật khẩu (Bảo vệ route này bằng JWT và dùng UserService)
app.put('/api/user/:id/change-password', authenticateToken, async (req, res) => {
  // Kiểm tra quyền tương tự
  if (req.user.id != req.params.id) {
    return res.status(403).json({ message: 'Bạn không có quyền đổi mật khẩu của user này.' });
  }

  const { currentPassword, newPassword } = req.body;
  try {
    // 1. Kiểm tra mật khẩu hiện tại bằng UserService
    const isPasswordValid = await UserService.verifyCurrentPassword(req.user.id, currentPassword);
    if (!isPasswordValid) {
      return res.status(400).json({ message: 'Mật khẩu hiện tại không đúng.' });
    }

    // 2. Đổi mật khẩu (UserService sẽ hash mật khẩu mới)
    await UserService.changePassword(req.user.id, newPassword);

    res.json({ message: 'Đổi mật khẩu thành công!' });
  } catch (err) {
    console.error('Change password error:', err);
    res.status(500).json({ message: err.message });
  }
});

// ============= Lịch trình (Bảo vệ toàn bộ các route này) =============
// Lấy danh sách lịch trình của user
app.get('/api/schedules/:userId', authenticateToken, async (req, res) => {
  // Chỉ cho phép user xem lịch trình của chính họ
  if (req.user.id != req.params.userId) {
    return res.status(403).json({ message: 'Bạn không có quyền truy cập lịch trình này.' });
  }
  
  try {
    let pool = await sql.connect(dbConfig);
    let result = await pool.request()
      .input('userId', sql.Int, req.params.userId)
      .query('SELECT * FROM schedules WHERE user_id = @userId ORDER BY deadline');
    res.json(result.recordset);
  } catch (err) {
    console.error('Get schedules error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Thêm lịch trình mới
app.post('/api/schedules', authenticateToken, async (req, res) => {
  const { title, description, tags, priority, deadline } = req.body;
  // Lấy user_id từ token, không phải từ body request
  const user_id = req.user.id; 
  
  try {
    let pool = await sql.connect(dbConfig);
    await pool.request()
      .input('user_id', sql.Int, user_id)
      .input('title', sql.NVarChar, title)
      .input('description', sql.NVarChar, description)
      .input('tags', sql.NVarChar, tags)
      .input('priority', sql.NVarChar, priority)
      .input('deadline', sql.DateTime, deadline)
      .query('INSERT INTO schedules (user_id, title, description, tags, priority, deadline) VALUES (@user_id, @title, @description, @tags, @priority, @deadline)');
    res.json({ message: 'Lịch trình đã được thêm thành công' });
  } catch (err) {
    console.error('Add schedule error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Cập nhật lịch trình (Phải kiểm tra quyền sở hữu)
app.put('/api/schedules/:id', authenticateToken, async (req, res) => {
  const { title, description, tags, priority, deadline, is_completed } = req.body;
  
  try {
    let pool = await sql.connect(dbConfig);
    
    // 1. Kiểm tra xem lịch trình có thuộc về user hiện tại không
    const scheduleCheck = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT user_id FROM schedules WHERE id = @id');
      
    if (scheduleCheck.recordset.length === 0) {
      return res.status(404).json({ message: 'Lịch trình không tồn tại.' });
    }
    
    if (scheduleCheck.recordset[0].user_id != req.user.id) {
      return res.status(403).json({ message: 'Bạn không có quyền chỉnh sửa lịch trình này.' });
    }
    
    // 2. Tiến hành cập nhật
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('title', sql.NVarChar, title)
      .input('description', sql.NVarChar, description)
      .input('tags', sql.NVarChar, tags)
      .input('priority', sql.NVarChar, priority)
      .input('deadline', sql.DateTime, deadline)
      .input('is_completed', sql.Bit, is_completed)
      .query('UPDATE schedules SET title = @title, description = @description, tags = @tags, priority = @priority, deadline = @deadline, is_completed = @is_completed WHERE id = @id');
    res.json({ message: 'Lịch trình đã được cập nhật thành công' });
  } catch (err) {
    console.error('Update schedule error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Xóa lịch trình (Phải kiểm tra quyền sở hữu)
app.delete('/api/schedules/:id', authenticateToken, async (req, res) => {
  try {
    let pool = await sql.connect(dbConfig);
    
    // 1. Kiểm tra xem lịch trình có thuộc về user hiện tại không
    const scheduleCheck = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT user_id FROM schedules WHERE id = @id');
      
    if (scheduleCheck.recordset.length === 0) {
      // Coi như đã xóa
      return res.json({ message: 'Lịch trình đã được xóa thành công' }); 
    }
    
    if (scheduleCheck.recordset[0].user_id != req.user.id) {
      return res.status(403).json({ message: 'Bạn không có quyền xóa lịch trình này.' });
    }
    
    // 2. Tiến hành xóa
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM schedules WHERE id = @id');
    res.json({ message: 'Lịch trình đã được xóa thành công' });
  } catch (err) {
    console.error('Delete schedule error:', err);
    res.status(500).json({ message: err.message });
  }
});


// ============= Thông báo (Bảo vệ toàn bộ các route này) =============
// Lấy danh sách thông báo của user
app.get('/api/notifications/:userId', authenticateToken, async (req, res) => {
  const requestedUserId = parseInt(req.params.userId, 10);
  if (req.user.id !== requestedUserId) {
    return res.status(403).json({ message: 'Bạn không có quyền truy cập thông báo này.' });
  }

  try {
    let pool = await sql.connect(dbConfig);
    let result = await pool.request()
      .input('userId', sql.Int, requestedUserId)
      .query(`
        SELECT id, user_id, schedule_id, title, content, priority, is_read, created_at
        FROM notifications
        WHERE user_id = @userId
        ORDER BY created_at DESC
      `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Get notifications error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Thêm hoặc cập nhật thông báo gắn với lịch trình
app.post('/api/notifications', authenticateToken, async (req, res) => {
  const { title, content, priority, scheduleId, markAsUnread } = req.body;
  const user_id = req.user.id;
  const parsedScheduleId = scheduleId ? parseInt(scheduleId, 10) : null;
  const sanitizedPriority = priority && priority.trim() ? priority.trim() : null;

  if (!title) {
    return res.status(400).json({ message: 'Tiêu đề thông báo là bắt buộc.' });
  }

  try {
    let pool = await sql.connect(dbConfig);

    if (parsedScheduleId) {
      const existing = await pool.request()
        .input('scheduleId', sql.Int, parsedScheduleId)
        .input('userId', sql.Int, user_id)
        .query('SELECT TOP 1 id FROM notifications WHERE schedule_id = @scheduleId AND user_id = @userId');

      if (existing.recordset.length > 0) {
        await pool.request()
          .input('id', sql.Int, existing.recordset[0].id)
          .input('title', sql.NVarChar, title)
          .input('content', sql.NVarChar, content || null)
          .input('priority', sql.NVarChar, sanitizedPriority)
          .input('is_read', sql.Bit, markAsUnread === true ? 0 : 0)
          .query(`
            UPDATE notifications
            SET title = @title,
                content = @content,
                priority = @priority,
                is_read = @is_read,
                created_at = GETDATE()
            WHERE id = @id
          `);
        return res.json({ message: 'Thông báo đã được cập nhật.' });
      }
    }

    await pool.request()
      .input('user_id', sql.Int, user_id)
      .input('schedule_id', sql.Int, parsedScheduleId)
      .input('title', sql.NVarChar, title)
      .input('content', sql.NVarChar, content || null)
      .input('priority', sql.NVarChar, sanitizedPriority)
      .input('created_at', sql.DateTime, new Date())
      .query(`
        INSERT INTO notifications (user_id, schedule_id, title, content, priority, created_at)
        VALUES (@user_id, @schedule_id, @title, @content, @priority, @created_at)
      `);

    res.json({ message: 'Thông báo đã được thêm thành công.' });
  } catch (err) {
    console.error('Add notification error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Cập nhật thông báo
app.put('/api/notifications/:id', authenticateToken, async (req, res) => {
  const { title, content, priority, is_read } = req.body;
  const notificationId = parseInt(req.params.id, 10);

  try {
    let pool = await sql.connect(dbConfig);
    const ownerCheck = await pool.request()
      .input('id', sql.Int, notificationId)
      .query('SELECT user_id FROM notifications WHERE id = @id');

    if (ownerCheck.recordset.length === 0) {
      return res.status(404).json({ message: 'Thông báo không tồn tại.' });
    }
    if (ownerCheck.recordset[0].user_id !== req.user.id) {
      return res.status(403).json({ message: 'Bạn không có quyền cập nhật thông báo này.' });
    }

    await pool.request()
      .input('id', sql.Int, notificationId)
      .input('title', sql.NVarChar, title || null)
      .input('content', sql.NVarChar, content || null)
      .input('priority', sql.NVarChar, priority || null)
      .input('is_read', sql.Bit, typeof is_read === 'boolean' ? (is_read ? 1 : 0) : null)
      .query(`
        UPDATE notifications
        SET 
          title = COALESCE(@title, title),
          content = COALESCE(@content, content),
          priority = COALESCE(@priority, priority),
          is_read = COALESCE(@is_read, is_read)
        WHERE id = @id
      `);
    res.json({ message: 'Thông báo đã được cập nhật.' });
  } catch (err) {
    console.error('Update notification error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Đánh dấu đã đọc / chưa đọc
app.patch('/api/notifications/:id/read', authenticateToken, async (req, res) => {
  const notificationId = parseInt(req.params.id, 10);
  const { is_read } = req.body;

  try {
    let pool = await sql.connect(dbConfig);
    const ownerCheck = await pool.request()
      .input('id', sql.Int, notificationId)
      .query('SELECT user_id FROM notifications WHERE id = @id');

    if (ownerCheck.recordset.length === 0) {
      return res.status(404).json({ message: 'Thông báo không tồn tại.' });
    }
    if (ownerCheck.recordset[0].user_id !== req.user.id) {
      return res.status(403).json({ message: 'Bạn không có quyền cập nhật thông báo này.' });
    }

    await pool.request()
      .input('id', sql.Int, notificationId)
      .input('is_read', sql.Bit, is_read ? 1 : 0)
      .query('UPDATE notifications SET is_read = @is_read WHERE id = @id');

    res.json({ message: 'Trạng thái thông báo đã được cập nhật.' });
  } catch (err) {
    console.error('Mark notification read error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Xóa thông báo
app.delete('/api/notifications/:id', authenticateToken, async (req, res) => {
  const notificationId = parseInt(req.params.id, 10);

  try {
    let pool = await sql.connect(dbConfig);
    const ownerCheck = await pool.request()
      .input('id', sql.Int, notificationId)
      .query('SELECT user_id FROM notifications WHERE id = @id');

    if (ownerCheck.recordset.length === 0) {
      return res.status(404).json({ message: 'Thông báo không tồn tại.' });
    }
    if (ownerCheck.recordset[0].user_id !== req.user.id) {
      return res.status(403).json({ message: 'Bạn không có quyền xóa thông báo này.' });
    }

    await pool.request()
      .input('id', sql.Int, notificationId)
      .query('DELETE FROM notifications WHERE id = @id');
    res.json({ message: 'Thông báo đã được xóa thành công.' });
  } catch (err) {
    console.error('Delete notification error:', err);
    res.status(500).json({ message: err.message });
  }
});

// Endpoint quên mật khẩu (Chưa hoàn thiện việc gửi email/tạo token, logic đã chuyển sang server.js)
// Tuy nhiên ta cần giữ lại vì trong server.js không có các logic khác
// Ta sẽ bỏ endpoint này khỏi index.js vì nó đã được chuyển sang server.js

// Khởi động server
const PORT = 4567;
app.listen(PORT, () => console.log(`API server running at http://localhost:${PORT}`));