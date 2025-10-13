const express = require('express');
const cors = require('cors');
const oracledb = require('oracledb');

const app = express();
const PORT = 3001;

// CORS - allow all for development
app.use(cors());
app.use(express.json());

// Try different connection configurations
const dbConfigs = [
    {
        name: 'PDB',
        config: {
            user: 'system',
            password: 'Oracle123',
            connectString: 'localhost:1521/XEPDB1'
        }
    },
    {
        name: 'CDB', 
        config: {
            user: 'system',
            password: 'Oracle123',
            connectString: 'localhost:1521/XE'
        }
    }
];

let currentDbConfig = dbConfigs[0]; // Start with PDB

// Test database connection on startup
async function testDatabaseConnection() {
    for (let db of dbConfigs) {
        try {
            const connection = await oracledb.getConnection(db.config);
            console.log(`✅ Connected to ${db.name}`);
            
            // Test if Employees table exists
            const result = await connection.execute(
                `SELECT COUNT(*) as count FROM Employees WHERE Login_Id = 'nadine.m'`
            );
            console.log(`📊 Found ${result.rows[0][0]} matching users in ${db.name}`);
            
            await connection.close();
            currentDbConfig = db;
            return true;
        } catch (err) {
            console.log(`❌ Cannot connect to ${db.name}:`, err.message);
        }
    }
    return false;
}

// Test route
app.get('/test', (req, res) => {
    res.json({ 
        message: 'Server is running!',
        database: currentDbConfig.name,
        timestamp: new Date().toISOString()
    });
});

// Login endpoint
app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    console.log('🔐 Login attempt:', username);

    let connection;

    try {
        connection = await oracledb.getConnection(currentDbConfig.config);
        console.log('✅ Database connected to:', currentDbConfig.name);

        const result = await connection.execute(
            `SELECT Emp_Name, Emp_Role 
             FROM Employees 
             WHERE Login_Id = :username AND Emp_Password = :password`,
            { username, password },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        console.log('📊 Query returned', result.rows.length, 'rows');

        if (result.rows.length > 0) {
            console.log('✅ Login successful for:', result.rows[0].EMP_NAME);
            res.json({ 
                success: true, 
                message: 'Login successful!', 
                user: result.rows[0]
            });
        } else {
            console.log('❌ Invalid credentials for:', username);
            res.status(401).json({ 
                success: false, 
                message: 'Invalid username or password' 
            });
        }

    } catch (err) {
        console.error('💥 Database error:', err);
        res.status(500).json({ 
            success: false, 
            message: 'Database error: ' + err.message 
        });
    } finally {
        if (connection) {
            try { 
                await connection.close(); 
            } catch (err) { 
                console.error(err); 
            }
        }
    }
});

// Start server
app.listen(PORT, async () => {
    console.log(`🚀 Server running at http://localhost:${PORT}`);
    console.log('🔍 Testing database connections...');
    
    const dbConnected = await testDatabaseConnection();
    if (dbConnected) {
        console.log(`✅ Using database: ${currentDbConfig.name}`);
    } else {
        console.log('❌ No database connection available');
    }
});