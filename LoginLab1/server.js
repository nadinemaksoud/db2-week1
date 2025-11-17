const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const oracledb = require('oracledb');  // Oracle client
const fs = require('fs');
const app = express();
const PORT = 3001;

app.use(cors());
app.use(bodyParser.json());

const path = require('path');
app.use(express.static(path.join(__dirname, '/')));

// Oracle configuration
const dbConfig = {
  connectString: "localhost:1521/XEPDB1", 
};

// ---------- LOGIN ----------
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  console.log('Received credentials:', { username, password });

  let connection;

  try {
    connection = await oracledb.getConnection({
      user: username,
      password: password,
      connectString: dbConfig.connectString,
    });

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
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (closeErr) {
        console.error('Error closing connection:', closeErr);
      }
    }
  }
});

// ---------- GET ALL VIEWS ----------
app.get('/views', (req, res) => {
  const viewsPath = path.join(__dirname, 'views.json');
  try {
    const data = fs.readFileSync(viewsPath, 'utf8');
    const json = JSON.parse(data);
    res.json(json);
  } catch (err) {
    console.error('Error loading views.json:', err);
    res.status(500).json({ error: 'Failed to load views.json' });
  }
});
// ---------- GET ACCESSIBLE VIEWS FOR USER ----------
app.post('/get-accessible-views', async (req, res) => {
  const { username, password } = req.body;

  let connection;
  try {
    // Connect as user
    connection = await oracledb.getConnection({
      user: username,
      password: password,
      connectString: dbConfig.connectString
    });

    // Get roles of logged-in user
    const rolesResult = await connection.execute(
    `SELECT granted_role FROM user_role_privs`
  );

    const roles = rolesResult.rows.map(r => r[0]);
    
    // Load views.json
    const data = JSON.parse(fs.readFileSync('./views.json', 'utf8'));

    // Filter views by roles
    const accessibleViews = data.views.filter(view =>
      view.roles.some(role => roles.includes(role))
    );

    res.json({ success: true, views: accessibleViews });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Failed to fetch accessible views" });
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (closeErr) {
        console.error('Error closing connection:', closeErr);
      }
    }
  }
});

// ---------- EXECUTE VIEW ----------
app.post('/execute-view', async (req, res) => {
  const { viewName, username, password } = req.body;

  try {
    const data = JSON.parse(fs.readFileSync('./views.json', 'utf8'));
    const view = data.views.find(v => v.name === viewName);

    if (!view) {
      return res.status(400).json({ error: "View not found" });
    }

    const connection = await oracledb.getConnection({
      user: username,
      password: password,
      connectString: dbConfig.connectString
    });

    const result = await connection.execute(view.sql);

    await connection.close();

    res.json({ columns: result.metaData, rows: result.rows });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "SQL execution error" });
  }
});

// ---------- SERVER ----------
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
