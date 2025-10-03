const express = require('express');
const cors = require('cors');
const oracledb = require('oracledb');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

const dbConfig = {
    user: 'system',          // use your Oracle user
    password: 'Oracle123',   // set during Docker setup
    connectString: 'localhost:1521/XEPDB1' // Docker container service
};

// POST /login route
app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    let connection;

    try {
        connection = await oracledb.getConnection(dbConfig);

        const result = await connection.execute(
            `SELECT COUNT(*) AS count FROM users WHERE username = :username AND password = :password`,
            [username, password]
        );

        if (result.rows[0][0] > 0) {
            res.json({ success: true, message: 'Login successful!' });
        } else {
            res.status(401).json({ success: false, message: 'Invalid username or password' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Server error' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (err) { console.error(err); }
        }
    }
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
