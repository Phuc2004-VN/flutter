const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',     // Thay đổi username của bạn
  password: '',     // Thay đổi password của bạn
  database: 'flutter_login_db', // Tên database của bạn
  waitForConnections: true, //
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool; 