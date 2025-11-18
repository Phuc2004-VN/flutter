const sql = require('mssql');
const dbConfig = require('./dbconfig');
const bcrypt = require('bcrypt'); // Thêm bcrypt

const saltRounds = 10; // Số vòng lặp băm

class UserService {
  // Hàm mới: Tạo hash mật khẩu
  static async hashPassword(password) {
    return bcrypt.hash(password, saltRounds);
  }
  
  // Hàm mới: Lấy user theo identifier (username/email) và trả về mật khẩu hash
  static async findUserWithHash(loginIdentifier) {
    let pool;
    try {
      pool = await sql.connect(dbConfig);
      let result = await pool.request()
        .input('identifier', sql.VarChar, loginIdentifier)
        .query('SELECT id, username, email, password, role FROM users WHERE email = @identifier OR username = @identifier');
      return result.recordset[0]; // Trả về cả password hash
    } catch (error) {
      console.error('Error finding user for login:', error);
      throw error;
    } finally {
      if (pool) {
        try {
          await pool.close();
        } catch (err) {
          console.error('Error closing pool:', err);
        }
      }
    }
  }
  
  static async findByEmail(email) {
    let pool;
    try {
      pool = await sql.connect(dbConfig);
      let result = await pool.request()
        .input('email', sql.VarChar, email)
        .query('SELECT * FROM users WHERE email = @email');
      return result.recordset[0];
    } catch (error) {
      console.error('Error finding user by email:', error);
      throw error;
    } finally {
      if (pool) {
        try {
          await pool.close();
        } catch (err) {
          console.error('Error closing pool:', err);
        }
      }
    }
  }

  static async updateResetToken(userId, resetToken, resetTokenExpiry) {
    let pool;
    try {
      pool = await sql.connect(dbConfig);
      await pool.request()
        .input('userId', sql.Int, userId)
        .input('resetToken', sql.VarChar, resetToken)
        .input('resetTokenExpiry', sql.DateTime, resetTokenExpiry)
        .query('UPDATE users SET reset_token = @resetToken, reset_token_expiry = @resetTokenExpiry WHERE id = @userId');
    } catch (error) {
      console.error('Error updating reset token:', error);
      throw error;
    } finally {
      if (pool) {
        try {
          await pool.close();
        } catch (err) {
          console.error('Error closing pool:', err);
        }
      }
    }
  }

  // Cập nhật: Hàm changePassword (sẽ hash mật khẩu mới)
  static async changePassword(userId, newPassword) {
    let pool;
    try {
      pool = await sql.connect(dbConfig);
      // Băm mật khẩu mới trước khi lưu
      const hashedPassword = await this.hashPassword(newPassword);

      await pool.request()
        .input('userId', sql.Int, userId)
        .input('newPassword', sql.VarChar, hashedPassword) // Dùng hashedPassword
        .query('UPDATE users SET password = @newPassword WHERE id = @userId');
      return true;
    } catch (error) {
      console.error('Error changing password:', error);
      throw error;
    } finally {
      if (pool) {
        try {
          await pool.close();
        } catch (err) {
          console.error('Error closing pool:', err);
        }
      }
    }
  }

  // Cập nhật: Hàm verifyCurrentPassword (Kiểm tra bằng bcrypt)
  static async verifyCurrentPassword(userId, currentPassword) {
    let pool;
    try {
      pool = await sql.connect(dbConfig);
      let result = await pool.request()
        .input('userId', sql.Int, userId)
        .query('SELECT password FROM users WHERE id = @userId'); // Lấy mật khẩu hash
      
      if (result.recordset.length === 0) return false;

      const hashedPassword = result.recordset[0].password;
      // So sánh mật khẩu thô với mật khẩu đã hash
      return bcrypt.compare(currentPassword, hashedPassword);
    } catch (error) {
      console.error('Error verifying current password:', error);
      throw error;
    } finally {
      if (pool) {
        try {
          await pool.close();
        } catch (err) {
          console.error('Error closing pool:', err);
        }
      }
    }
  }
}

module.exports = UserService;