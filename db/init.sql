CREATE DATABASE IF NOT EXISTS appdb;
USE appdb;

CREATE TABLE IF NOT EXISTS timesheet (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(100) NOT NULL,
  date DATE NOT NULL,
  hours_worked DECIMAL(4,2) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample data
INSERT INTO timesheet (employee_name, date, hours_worked, description) VALUES
  ('John Doe', '2026-02-05', 8.00, 'Project development'),
  ('Jane Smith', '2026-02-05', 7.50, 'Code review and testing'),
  ('John Doe', '2026-02-06', 6.00, 'Documentation');
