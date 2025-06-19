var Upload = createReactClass({
  getInitialState: function () {
    return {
      file: null,
      loading: false,
      error: "",
      success: null,
    };
  },

  maxSize: 2 * 1024 * 1024, // 2MB
  allowedTypes: [
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
    ".svg",
    ".txt",
    ".md",
    ".csv",
  ],

  validateFile: function (file) {
    if (!file) {
      return "Please select a file";
    }

    // Check file size
    if (file.size > this.maxSize) {
      return "File is too large. Maximum size allowed is 2MB.";
    }

    // Check file type by extension
    var fileName = file.name.toLowerCase();
    var extension = "." + fileName.split(".").pop();

    if (this.allowedTypes.indexOf(extension) === -1) {
      return (
        "File type not allowed. Allowed types: " + this.allowedTypes.join(", ")
      );
    }

    return null;
  },

  formatFileSize: function (bytes) {
    if (bytes === 0) return "0 Bytes";
    var k = 1024;
    var sizes = ["Bytes", "KB", "MB"];
    var i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  },

  formatTimestamp: function (timestamp) {
    return new Date(timestamp).toLocaleString();
  },

  handleFileChange: function (e) {
    var selectedFile = e.target.files[0];
    this.setState({
      file: selectedFile,
      error: "",
      success: null,
    });

    if (selectedFile) {
      var validationError = this.validateFile(selectedFile);
      if (validationError) {
        this.setState({ error: validationError });
      }
    }
  },

  handleUpload: function () {
    if (!this.state.file) {
      this.setState({ error: "Please select a file" });
      return;
    }

    var validationError = this.validateFile(this.state.file);
    if (validationError) {
      this.setState({ error: validationError });
      return;
    }

    this.setState({
      loading: true,
      error: "",
      success: null,
    });

    var formData = new FormData();
    formData.append("file", this.state.file);
    var self = this;

    fetch("/api/files", {
      method: "POST",
      headers: {
        Authorization: "Bearer " + this.props.token,
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: formData,
    })
      .then(function (response) {
        return response.json().then(function (data) {
          return { data: data, ok: response.ok };
        });
      })
      .then(function (result) {
        if (!result.ok) {
          throw new Error(result.data.error || "Upload failed");
        }

        self.setState({
          success: result.data,
          file: null,
        });

        // Reset file input
        var fileInput = document.querySelector('input[type="file"]');
        if (fileInput) fileInput.value = "";
      })
      .catch(function (error) {
        self.setState({ error: error.message || "Upload failed" });
      })
      .finally(function () {
        self.setState({ loading: false });
      });
  },

  render: function () {
    var fileInfo = null;
    if (this.state.file && !this.state.error) {
      fileInfo = React.createElement(
        "div",
        { className: "file-info" },
        React.createElement(
          "p",
          null,
          React.createElement("strong", null, "Selected: "),
          this.state.file.name,
        ),
        React.createElement(
          "p",
          null,
          React.createElement("strong", null, "Size: "),
          this.formatFileSize(this.state.file.size),
        ),
        React.createElement(
          "p",
          null,
          React.createElement("strong", null, "Type: "),
          this.state.file.type,
        ),
      );
    }

    var errorMessage = null;
    if (this.state.error) {
      errorMessage = React.createElement(
        "div",
        {
          className: "error-message",
          style: { color: "red", marginTop: "10px" },
        },
        React.createElement("strong", null, "Error: "),
        this.state.error,
      );
    }

    var successMessage = null;
    if (this.state.success) {
      successMessage = React.createElement(
        "div",
        {
          className: "success-message",
          style: { color: "green", marginTop: "10px" },
        },
        React.createElement("h3", null, "Upload Successful!"),
        React.createElement(
          "div",
          { className: "file-metadata" },
          React.createElement(
            "p",
            null,
            React.createElement("strong", null, "Filename: "),
            this.state.success.filename,
          ),
          React.createElement(
            "p",
            null,
            React.createElement("strong", null, "Content Type: "),
            this.state.success.content_type,
          ),
          React.createElement(
            "p",
            null,
            React.createElement("strong", null, "Size: "),
            this.formatFileSize(this.state.success.size),
          ),
          React.createElement(
            "p",
            null,
            React.createElement("strong", null, "Upload Timestamp: "),
            this.formatTimestamp(this.state.success.upload_timestamp),
          ),
          React.createElement(
            "p",
            null,
            React.createElement("strong", null, "File ID: "),
            this.state.success.id,
          ),
        ),
      );
    }

    var loadingIndicator = null;
    if (this.state.loading) {
      loadingIndicator = React.createElement(
        "div",
        { className: "loading-indicator", style: { marginTop: "10px" } },
        React.createElement("p", null, "Uploading file, please wait..."),
      );
    }

    return React.createElement(
      "div",
      { className: "container" },
      React.createElement("h2", null, "Upload File"),
      React.createElement(
        "div",
        { className: "upload-section" },
        React.createElement("input", {
          type: "file",
          onChange: this.handleFileChange,
          accept: this.allowedTypes.join(","),
          disabled: this.state.loading,
        }),
        fileInfo,
        React.createElement(
          "button",
          {
            onClick: this.handleUpload,
            disabled:
              this.state.loading || !this.state.file || this.state.error,
          },
          this.state.loading ? "Uploading..." : "Upload",
        ),
      ),
      errorMessage,
      successMessage,
      loadingIndicator,
      React.createElement(
        "div",
        {
          className: "file-requirements",
          style: { marginTop: "20px", fontSize: "0.9em", color: "#666" },
        },
        React.createElement("h4", null, "File Requirements:"),
        React.createElement(
          "ul",
          null,
          React.createElement("li", null, "Maximum size: 2MB"),
          React.createElement(
            "li",
            null,
            "Allowed types: " + this.allowedTypes.join(", "),
          ),
        ),
      ),
    );
  },
});
