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

    fetch("/api/files", {
      headers: {
        Authorization: "Bearer " + this.props.token,
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    })
      .then(function (response) {
        if (!response.ok) {
          throw new Error("Failed to fetch files");
        }
        return response.json();
      })
      .then(function (data) {
        self.setState({
          files: data,
          loading: false,
        });
      })
      .catch(function (error) {
        self.setState({
          error: "Could not load files",
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
    if (this.state.loading) {
      return React.createElement("p", null, "Loading files...");
    }

    if (this.state.error) {
      return React.createElement("p", null, this.state.error);
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
