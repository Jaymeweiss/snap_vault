var TestComponent = createReactClass({
  render: function() {
    return React.createElement(
      "div",
      { style: { padding: "20px", border: "2px solid green", margin: "10px" } },
      React.createElement("h1", null, "React is Working!"),
      React.createElement("p", null, "This is a test component to verify React integration."),
      React.createElement("button", {
        onClick: function() {
          alert("React component is responding to events!");
        }
      }, "Click me to test!")
    );
  }
});
