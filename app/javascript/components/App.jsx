import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Upload from './pages/Upload';
import FileList from './pages/FileList';

function App() {
  const [token, setToken] = React.useState(localStorage.getItem('token'));

  const handleLogin = (newToken) => {
    localStorage.setItem('token', newToken);
    setToken(newToken);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    setToken(null);
  };

  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login onLogin={handleLogin} />} />
        {token ? (
          <React.Fragment>
            <Route path="/upload" element={<Upload token={token} onLogout={handleLogout} />} />
            <Route path="/files" element={<FileList token={token} onLogout={handleLogout} />} />
            <Route path="*" element={<Navigate to="/upload" replace />} />
          </React.Fragment>
        ) : (
          <Route path="*" element={<Navigate to="/login" replace />} />
        )}
      </Routes>
    </Router>
  );
}

export default App;
