import React, { useState } from 'react';

export default function Upload({ token, onLogout }) {
  const [file, setFile] = useState(null);
  const [message, setMessage] = useState('');
  const maxSize = 10 * 1024 * 1024;

  const handleUpload = async () => {
    if (!file) return;
    if (file.size > maxSize) {
      setMessage('File is too large');
      return;
    }

    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await fetch('/api/files', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: formData,
      });

      if (!res.ok) throw new Error('Upload failed');
      const data = await res.json();
      setMessage(`Uploaded: ${data.filename}`);
    } catch (err) {
      setMessage('Upload failed');
    }
  };

  return (
    <div className="container">
      <h2>Upload File</h2>
      <input type="file" onChange={(e) => setFile(e.target.files[0])} />
      <button onClick={handleUpload}>Upload</button>
      <button onClick={onLogout}>Logout</button>
      {message && <p>{message}</p>}
    </div>
  );
}