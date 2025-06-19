var Login = createReactClass({
  getInitialState: function () {
    return {
      email: "",
      password: "",
      error: null,
    };
  },

  handleEmailChange: function (e) {
    this.setState({ email: e.target.value });
  },

  handlePasswordChange: function (e) {
    this.setState({ password: e.target.value });
  },

  handleSubmit: function (e) {
    e.preventDefault();
    this.setState({ error: null });

    var self = this;

    fetch("/sessions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: JSON.stringify({
        email: this.state.email,
        password: this.state.password,
      }),
    })
      .then(function (response) {
        return response.json();
      })
      .then(function (data) {
        if (data.success) {
          self.props.onLogin(data.token);
        } else {
          self.setState({ error: data.error || "Login failed" });
        }
      })
      .catch(function (error) {
        self.setState({ error: "Network error. Please try again." });
        console.error("Login error:", error);
      });
  },

  render: function () {
    return React.createElement(
      "div",
      { className: "container" },
      React.createElement("h2", null, "Login"),
      React.createElement(
        "form",
        { onSubmit: this.handleSubmit },
        React.createElement("input", {
          type: "email",
          placeholder: "Email",
          value: this.state.email,
          onChange: this.handleEmailChange,
          required: true,
        }),
        React.createElement("input", {
          type: "password",
          placeholder: "Password",
          value: this.state.password,
          onChange: this.handlePasswordChange,
          required: true,
        }),
        React.createElement("button", { type: "submit" }, "Login"),
        this.state.error &&
          React.createElement("p", { className: "error" }, this.state.error),
      ),
    );
  },
});
