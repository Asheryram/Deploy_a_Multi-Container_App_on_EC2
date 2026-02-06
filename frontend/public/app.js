// API calls go through nginx proxy to backend
const API_URL = '';

// DOM Elements
const entriesBody = document.getElementById('entries-tbody');
const entryForm = document.getElementById('entry-form');
const editModal = document.getElementById('edit-modal');
const editForm = document.getElementById('edit-form');
const cancelEditBtn = document.getElementById('cancel-edit');
const refreshBtn = document.getElementById('refresh-btn');
const themeToggle = document.getElementById('theme-toggle');
const themeIcon = document.getElementById('theme-icon');
const toast = document.getElementById('toast');

// Stats elements
const totalEntriesEl = document.getElementById('total-entries');
const totalHoursEl = document.getElementById('total-hours');
const todayHoursEl = document.getElementById('today-hours');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
  loadEntries();
  setDefaultDate();
  initTheme();
});

// Theme Management
function initTheme() {
  const savedTheme = localStorage.getItem('theme') || 'light';
  if (savedTheme === 'dark') {
    document.documentElement.classList.add('dark');
    themeIcon.textContent = '☀️';
  }
}

themeToggle.addEventListener('click', () => {
  document.documentElement.classList.toggle('dark');
  const isDark = document.documentElement.classList.contains('dark');
  localStorage.setItem('theme', isDark ? 'dark' : 'light');
  themeIcon.textContent = isDark ? '☀️' : '🌙';
});

// Set default date to today
function setDefaultDate() {
  const today = new Date().toISOString().split('T')[0];
  document.getElementById('date').value = today;
}

// Toast notifications
function showToast(message, type = 'info') {
  toast.textContent = message;
  toast.className = `toast ${type}`;
  setTimeout(() => toast.classList.add('hidden'), 3000);
}

// Load all entries
async function loadEntries() {
  try {
    const res = await fetch(`${API_URL}/entries`);
    const data = await res.json();
    
    if (data.status === 'ok') {
      renderEntries(data.entries);
      updateStats(data.entries);
    } else {
      showToast('Failed to load entries', 'error');
    }
  } catch (err) {
    console.error(err);
    entriesBody.innerHTML = `<tr><td colspan="6" class="text-center text-danger">Error connecting to API</td></tr>`;
    showToast('Error connecting to API', 'error');
  }
}

// Render entries table
function renderEntries(entries) {
  if (entries.length === 0) {
    entriesBody.innerHTML = `<tr><td colspan="6" class="text-center text-secondary">No entries yet. Add your first entry above!</td></tr>`;
    return;
  }

  entriesBody.innerHTML = entries.map(entry => `
    <tr>
      <td>${entry.id}</td>
      <td>${escapeHtml(entry.employee_name)}</td>
      <td>${formatDate(entry.date)}</td>
      <td><strong>${entry.hours_worked}h</strong></td>
      <td>${escapeHtml(entry.description || '-')}</td>
      <td>
        <div class="action-btns">
          <button class="btn btn-sm btn-secondary" onclick="openEditModal(${entry.id})">✏️</button>
          <button class="btn btn-sm btn-danger" onclick="deleteEntry(${entry.id})">🗑️</button>
        </div>
      </td>
    </tr>
  `).join('');
}

// Update statistics
function updateStats(entries) {
  const total = entries.length;
  const totalHours = entries.reduce((sum, e) => sum + parseFloat(e.hours_worked), 0);
  
  const today = new Date().toISOString().split('T')[0];
  const todayHours = entries
    .filter(e => e.date.split('T')[0] === today)
    .reduce((sum, e) => sum + parseFloat(e.hours_worked), 0);

  totalEntriesEl.textContent = total;
  totalHoursEl.textContent = totalHours.toFixed(1);
  todayHoursEl.textContent = todayHours.toFixed(1);
}

// Add new entry
entryForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const formData = new FormData(entryForm);
  const payload = {
    employee_name: formData.get('employee_name'),
    date: formData.get('date'),
    hours_worked: parseFloat(formData.get('hours_worked')),
    description: formData.get('description')
  };

  try {
    const res = await fetch(`${API_URL}/entries`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await res.json();

    if (data.status === 'ok') {
      showToast('Entry added successfully!', 'success');
      entryForm.reset();
      setDefaultDate();
      loadEntries();
    } else {
      showToast(data.error || 'Failed to add entry', 'error');
    }
  } catch (err) {
    console.error(err);
    showToast('Error adding entry', 'error');
  }
});

// Open edit modal
async function openEditModal(id) {
  try {
    const res = await fetch(`${API_URL}/entries/${id}`);
    const data = await res.json();

    if (data.status === 'ok') {
      const entry = data.entry;
      document.getElementById('edit-id').value = entry.id;
      document.getElementById('edit-employee').value = entry.employee_name;
      document.getElementById('edit-date').value = entry.date.split('T')[0];
      document.getElementById('edit-hours').value = entry.hours_worked;
      document.getElementById('edit-description').value = entry.description || '';
      editModal.classList.remove('hidden');
    }
  } catch (err) {
    showToast('Error loading entry', 'error');
  }
}

// Close edit modal
cancelEditBtn.addEventListener('click', () => {
  editModal.classList.add('hidden');
});

editModal.querySelector('.modal-backdrop').addEventListener('click', () => {
  editModal.classList.add('hidden');
});

// Save edit
editForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const id = document.getElementById('edit-id').value;
  const payload = {
    employee_name: document.getElementById('edit-employee').value,
    date: document.getElementById('edit-date').value,
    hours_worked: parseFloat(document.getElementById('edit-hours').value),
    description: document.getElementById('edit-description').value
  };

  try {
    const res = await fetch(`${API_URL}/entries/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await res.json();

    if (data.status === 'ok') {
      showToast('Entry updated!', 'success');
      editModal.classList.add('hidden');
      loadEntries();
    } else {
      showToast(data.error || 'Failed to update', 'error');
    }
  } catch (err) {
    showToast('Error updating entry', 'error');
  }
});

// Delete entry
async function deleteEntry(id) {
  if (!confirm('Are you sure you want to delete this entry?')) return;

  try {
    const res = await fetch(`${API_URL}/entries/${id}`, { method: 'DELETE' });
    const data = await res.json();

    if (data.status === 'ok') {
      showToast('Entry deleted', 'success');
      loadEntries();
    } else {
      showToast(data.error || 'Failed to delete', 'error');
    }
  } catch (err) {
    showToast('Error deleting entry', 'error');
  }
}

// Refresh button
refreshBtn.addEventListener('click', () => {
  loadEntries();
  showToast('Entries refreshed', 'info');
});

// Helper functions
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

function formatDate(dateStr) {
  const date = new Date(dateStr);
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  });
}
