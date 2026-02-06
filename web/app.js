const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
app.use(express.json());

const DB_HOST = process.env.DB_HOST || 'db';
const DB_PORT = parseInt(process.env.DB_PORT || '3306', 10);
const DB_NAME = process.env.DB_NAME || 'appdb';
const DB_USER = process.env.DB_USER || 'appuser';
const DB_PASSWORD = process.env.DB_PASSWORD || 'apppassword';

let pool;

async function initPool(retries = 10, delay = 2000) {
  for (let i = 0; i < retries; i++) {
    try {
      pool = mysql.createPool({
        host: DB_HOST,
        port: DB_PORT,
        user: DB_USER,
        password: DB_PASSWORD,
        database: DB_NAME,
        waitForConnections: true,
        connectionLimit: 10
      });
      await pool.query('SELECT 1');
      console.log('Connected to MySQL');
      return;
    } catch (err) {
      console.log(`DB not ready, retrying in ${delay / 1000}s...`);
      await new Promise(r => setTimeout(r, delay));
    }
  }
  throw new Error('Could not connect to database');
}

// Get all timesheet entries
app.get('/entries', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM timesheet ORDER BY date DESC, id DESC');
    res.json({ status: 'ok', entries: rows });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

// Add a new timesheet entry
app.post('/entries', async (req, res) => {
  try {
    const { employee_name, date, hours_worked, description } = req.body;
    if (!employee_name || !date || !hours_worked) {
      return res.status(400).json({ status: 'error', error: 'Missing required fields' });
    }
    const [result] = await pool.query(
      'INSERT INTO timesheet (employee_name, date, hours_worked, description) VALUES (?, ?, ?, ?)',
      [employee_name, date, hours_worked, description || '']
    );
    res.status(201).json({ status: 'ok', id: result.insertId });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

// Get a single entry
app.get('/entries/:id', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM timesheet WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ status: 'error', error: 'Entry not found' });
    }
    res.json({ status: 'ok', entry: rows[0] });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

// Update an entry
app.put('/entries/:id', async (req, res) => {
  try {
    const { employee_name, date, hours_worked, description } = req.body;
    const [result] = await pool.query(
      'UPDATE timesheet SET employee_name = ?, date = ?, hours_worked = ?, description = ? WHERE id = ?',
      [employee_name, date, hours_worked, description || '', req.params.id]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ status: 'error', error: 'Entry not found' });
    }
    res.json({ status: 'ok', message: 'Updated' });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

// Delete an entry
app.delete('/entries/:id', async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM timesheet WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ status: 'error', error: 'Entry not found' });
    }
    res.json({ status: 'ok', message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

// Health check
app.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT COUNT(*) AS count FROM timesheet');
    res.json({ status: 'ok', message: 'Timesheet API', total_entries: rows[0].count });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

const PORT = 5000;
initPool().then(() => {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Timesheet API running on port ${PORT}`);
  });
}).catch(err => {
  console.error(err);
  process.exit(1);
});
