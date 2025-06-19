import React, { useEffect, useState } from 'react';

export default function FileList({ token, onLogout }) {
  const [files, setFiles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchFiles = async () => {
      try {
        const res = await fetch('/api/files', {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!res.ok) throw new Error('Failed to fetch files');
        const data = await res.json();
        setFiles(data);
      } catch (err) {
        setError('Could not load files');
      } finally {
        setLoading(false);
      }
    };

    fetchFiles();
  }, [token]);

  if (loading) return <p>Loading files...</p>;
  if (error) return <p>{error}</p>;
  if (!files.length) return <p>No files uploaded yet.</p>;

  return (
    <div className="container">
      <h2>Uploaded Files</h2>
      <button onClick={onLogout}>Logout</button>
      <ul>
        {files.map((file) => (
          <li key={file.id}>
            <p><strong>Name:</strong> {file.filename}</p>
            <p><strong>Size:</strong> {Math.round(file.size / 1024)} KB</p>
            <p><strong>Type:</strong> {file.content_type}</p>
            <p><strong>Date:</strong> {new Date(file.created_at).toLocaleString()}</p>
            <a href={file.download_url} target="_blank" rel="noopener noreferrer">Download</a>
            {file.preview_url && <div><img src={file.preview_url} alt="preview" style={{ maxWidth: '200px' }} /></div>}
          </li>
        ))}
      </ul>
    </div>
  );
}