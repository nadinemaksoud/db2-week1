const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const oracledb = require('oracledb');  // Oracle client

const app = express();
const PORT = 3001;


app.use(cors());
app.use(bodyParser.json());

// Oracle configuration (change according to your container/db setup)
const dbConfig = {
  connectString: "localhost:1521/XEPDB1", // your container's service name or DB service
};

app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  console.log('Received credentials:', { username, password });

  let connection;

  try {
    // Try connecting as the given user
    connection = await oracledb.getConnection({
      user: username,
      password: password,
      connectString: dbConfig.connectString,
    });

    // If connected successfully
    res.json({ success: true, message: 'Login successful!' });
  } catch (err) {
  let msg = 'Login failed';
  
  const errorMessage = (err.message || '').toUpperCase();

    if (errorMessage.includes('ORA-01017')) {
      msg = 'Wrong username or password';
    } else if (errorMessage.includes('ORA-28000')) {
      msg = 'Your account is locked. Please contact the administrator.';
    } else if (errorMessage.includes('ORA-01045')) {
      msg = 'You lack CREATE SESSION privilege';
    }
  res.status(401).json({ success: false, message: msg });
  } 
  
  finally {
    if (connection) {
      try {
        await connection.close();
      } catch (closeErr) {
        console.error('Error closing connection:', closeErr);
      }
    }
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
}); 