const config = {
    user: 'myuser',
    password: '123456',
    server: 'localhost', // IP hoặc tên máy
    database: 'flutter_login_db',
    options: {
      encrypt: false,
      trustServerCertificate: true,
      enableArithAbort: true
    },
    port: 1433,
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
  };

module.exports = config;