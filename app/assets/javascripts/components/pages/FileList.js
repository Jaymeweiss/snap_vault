var FileList = createReactClass({
  getInitialState: function () {
    return {
      files: [],
      loading: true,
      error: null,
    };
  },

  componentDidMount: function () {
    this.fetchFiles();
  },

  fetchFiles: function () {
    var self = this;
    console.log(
      "FileList: Starting to fetch files with token:",
      this.props.token,
    );

    fetch("/api/files", {
      headers: {
        Authorization: "Bearer " + this.props.token,
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    })
      .then(function (response) {
        console.log("FileList: API response status:", response.status);
        if (!response.ok) {
          throw new Error("Failed to fetch files - Status: " + response.status);
        }
        return response.json();
      })
      .then(function (data) {
        console.log("FileList: Received files data:", data);
        self.setState({
          files: data,
          loading: false,
        });
      })
      .catch(function (error) {
        console.error("FileList: Error fetching files:", error);
        self.setState({
          error: "Could not load files: " + error.message,
          loading: false,
        });
      });
  },

  formatFileSize: function (bytes) {
    return Math.round(bytes / 1024) + " KB";
  },

  formatDate: function (dateString) {
    return new Date(dateString).toLocaleString();
  },

  render: function () {
    console.log("FileList: Rendering with state:", this.state);

    if (this.state.loading) {
      return React.createElement("p", null, "Loading files...");
    }

    if (this.state.error) {
      return React.createElement(
        "div",
        null,
        React.createElement("p", { style: { color: "red" } }, this.state.error),
        React.createElement("button", { onClick: this.fetchFiles }, "Retry"),
      );
    }

    if (this.state.files.length === 0) {
      return React.createElement("p", null, "No files uploaded yet.");
    }

    var fileItems = this.state.files.map(function (file) {
      var previewElement = null;
      if (file.preview_url) {
        previewElement = React.createElement(
          "div",
          null,
          React.createElement("img", {
            src: file.preview_url,
            alt: "preview",
            style: { maxWidth: "200px" },
          }),
        );
      }

      return React.createElement(
        "li",
        { key: file.id },
        React.createElement(
          "p",
          null,
          React.createElement("strong", null, "Name: "),
          file.filename,
        ),
        React.createElement(
          "p",
          null,
          React.createElement("strong", null, "Size: "),
          this.formatFileSize(file.size),
        ),
        React.createElement(
          "p",
          null,
          React.createElement("strong", null, "Type: "),
          file.content_type,
        ),
        React.createElement(
          "p",
          null,
          React.createElement("strong", null, "Date: "),
          this.formatDate(file.created_at),
        ),
        React.createElement(
          "a",
          {
            href: file.download_url,
            target: "_blank",
            rel: "noopener noreferrer",
          },
          "Download",
        ),
        previewElement,
      );
    }, this);

    return React.createElement(
      "div",
      { className: "container" },
      React.createElement("h2", null, "Uploaded Files"),
      React.createElement("ul", null, fileItems),
    );
  },
});
