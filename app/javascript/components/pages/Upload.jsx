import React, { useState } from 'react';

export default function Upload({ token, onLogout }) {
  const [file, setFile] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(null);

  const maxSize = 2 * 1024 * 1024; // 2MB
  const allowedTypes = ['.jpg', '.jpeg', '.png', '.gif', '.svg', '.txt', '.md', '.csv'];

  const validateFile = (file) => {
    if (!file) {
      return 'Please select a file';
    }

    // Check file size
    if (file.size > maxSize) {
      return 'File is too large. Maximum size allowed is 2MB.';
    }

    // Check file type by extension
    const fileName = file.name.toLowerCase();
    const extension = '.' + fileName.split('.').pop();

    if (!allowedTypes.includes(extension)) {
      return `File type not allowed. Allowed types: ${allowedTypes.join(', ')}`;
    }

    return null;
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const formatTimestamp = (timestamp) => {
    return new Date(timestamp).toLocaleString();
  };

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    setFile(selectedFile);
    setError('');
    setSuccess(null);

    if (selectedFile) {
      const validationError = validateFile(selectedFile);
      if (validationError) {
        setError(validationError);
      }
    }
  };

  const handleUpload = async () => {
    if (!file) {
      setError('Please select a file');
      return;
    }

    const validationError = validateFile(file);
    if (validationError) {
      setError(validationError);
      return;
    }

    setLoading(true);
    setError('');
    setSuccess(null);

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

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error || 'Upload failed');
      }

      setSuccess(data);
      setFile(null);
      // Reset file input
      const fileInput = document.querySelector('input[type="file"]');
      if (fileInput) fileInput.value = '';

    } catch (err) {
      setError(err.message || 'Upload failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container">
      <h2>Upload File</h2>

      <div className="upload-section">
        <input 
          type="file" 
          onChange={handleFileChange}
          accept={allowedTypes.join(',')}
          disabled={loading}
        />

        {file && !error && (
          <div className="file-info">
            <p><strong>Selected:</strong> {file.name}</p>
            <p><strong>Size:</strong> {formatFileSize(file.size)}</p>
            <p><strong>Type:</strong> {file.type}</p>
          </div>
        )}

        <button 
          onClick={handleUpload} 
          disabled={loading || !file || error}
        >
          {loading ? 'Uploading...' : 'Upload'}
        </button>

        <button onClick={onLogout}>Logout</button>
      </div>

      {/* Error Messages */}
      {error && (
        <div className="error-message" style={{ color: 'red', marginTop: '10px' }}>
          <strong>Error:</strong> {error}
        </div>
      )}

      {/* Success Message with File Metadata */}
      {success && (
        <div className="success-message" style={{ color: 'green', marginTop: '10px' }}>
          <h3>Upload Successful!</h3>
          <div className="file-metadata">
            <p><strong>Filename:</strong> {success.filename}</p>
            <p><strong>Content Type:</strong> {success.content_type}</p>
            <p><strong>Size:</strong> {formatFileSize(success.size)}</p>
            <p><strong>Upload Timestamp:</strong> {formatTimestamp(success.upload_timestamp)}</p>
            <p><strong>File ID:</strong> {success.id}</p>
          </div>
        </div>
      )}

      {/* Loading Indicator */}
      {loading && (
        <div className="loading-indicator" style={{ marginTop: '10px' }}>
          <p>Uploading file, please wait...</p>
        </div>
      )}

      {/* File Requirements */}
      <div className="file-requirements" style={{ marginTop: '20px', fontSize: '0.9em', color: '#666' }}>
        <h4>File Requirements:</h4>
        <ul>
          <li>Maximum size: 2MB</li>
          <li>Allowed types: {allowedTypes.join(', ')}</li>
        </ul>
      </div>
    </div>
  );
}
