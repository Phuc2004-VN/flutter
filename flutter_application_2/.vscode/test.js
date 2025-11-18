const sql = require('mssql');
const config = {
  user: 'myuser',
  password: '123456',
  server: 'localhost',     //Dùng IP hoặc tên máy, KHÔNG dùng \SQLEXPRESS
  port: 1433,              //Gắn rõ port
  database: 'flutter_login_db',
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

sql.connect(config).then(pool => {
  return pool.request().query('SELECT 1 as number');
}).then(result => {
  console.log(result);
  sql.close();
}).catch(err => {
  console.error('Connection error:', err);
});
