var App = createReactClass({
  getInitialState: function () {
    return {
      token: localStorage.getItem("token"),
      currentView: "login",
    };
  },

  handleLogin: function (newToken) {
    localStorage.setItem("token", newToken);
    this.setState({
      token: newToken,
      currentView: "upload",
    });
  },

  handleLogout: function () {
    localStorage.removeItem("token");
    this.setState({
      token: null,
      currentView: "login",
    });
  },

  handleViewChange: function (view) {
    this.setState({ currentView: view });
  },

  renderNavigation: function () {
    if (!this.state.token) return null;

    return React.createElement(
      "div",
      { style: { marginBottom: "20px" } },
      React.createElement(
        "button",
        {
          onClick: () => this.handleViewChange("upload"),
          style: { marginRight: "10px" },
        },
        "Upload",
      ),
      React.createElement(
        "button",
        {
          onClick: () => this.handleViewChange("files"),
          style: { marginRight: "10px" },
        },
        "Files",
      ),
      React.createElement(
        "button",
        {
          onClick: this.handleLogout,
        },
        "Logout",
      ),
    );
  },

  render: function () {
    var content;

    if (!this.state.token) {
      content = React.createElement(Login, {
        onLogin: this.handleLogin,
      });
    } else if (this.state.currentView === "upload") {
      content = React.createElement(Upload, {
        token: this.state.token,
        onLogout: this.handleLogout,
      });
    } else if (this.state.currentView === "files") {
      content = React.createElement(FileList, {
        token: this.state.token,
        onLogout: this.handleLogout,
      });
    }

    return React.createElement("div", null, this.renderNavigation(), content);
  },
});
