// Handle login form submission
document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value.trim();

    const errorMessage = document.getElementById('errorMessage');
    errorMessage.textContent = '';
    errorMessage.className = '';

    // Basic validation
    if (!username || !password) {
        errorMessage.textContent = 'Please enter both username and password';
        errorMessage.className = 'error';
        return;
    }

    try {
        console.log('Sending login request...', { username, password });

        const response = await fetch('http://localhost:3001/login', {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({ username, password })
        });

        console.log('Response status:', response.status);

        // Parse JSON
        const result = await response.json();
        console.log('Response result:', result);

        if (result.success) {
            errorMessage.textContent = 'Login successful! Redirecting...';
            errorMessage.className = 'success';
            alert('Login successful! Welcome ' + result.user.EMP_NAME);
            // Redirect to main POS page if needed
            // window.location.href = 'pos.html';
        } else {
            errorMessage.textContent = result.message;
            errorMessage.className = 'error';
        }
    } catch (err) {
        console.error('Login error:', err);
        errorMessage.textContent = 'Server error: ' + err.message;
        errorMessage.className = 'error';
    }
});

// Optional: Test server connection on page load
window.addEventListener('load', async () => {
    try {
        const response = await fetch('http://localhost:3001/test');
        const result = await response.json();
        console.log('Server test:', result);
    } catch (err) {
        console.error('Server connection test failed:', err);
    }
});
