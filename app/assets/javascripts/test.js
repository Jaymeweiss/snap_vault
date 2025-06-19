// Manual React component mounting instead of relying on react_ujs
document.addEventListener("DOMContentLoaded", function () {
  console.log("Manual React mounting script loaded");

  // Check if React is available
  if (typeof React === "undefined") {
    console.error("React is not available");
    return;
  }

  if (typeof createReactClass === "undefined") {
    console.error("createReactClass is not available");
    return;
  }

  // Find all React component containers
  var componentContainers = document.querySelectorAll("[data-react-component]");
  console.log(
    "Found",
    componentContainers.length,
    "React component containers",
  );

  componentContainers.forEach(function (container) {
    var componentName = container.getAttribute("data-react-component");
    var propsJson = container.getAttribute("data-react-props") || "{}";

    console.log("Attempting to mount component:", componentName);

    try {
      var props = JSON.parse(propsJson);

      // Check if component exists in global scope
      if (typeof window[componentName] === "undefined") {
        console.error("Component not found:", componentName);
        // Add error message to container
        container.innerHTML =
          '<div style="color: red; padding: 10px; border: 1px solid red;">Error: React component "' +
          componentName +
          '" not found</div>';
        return;
      }

      var Component = window[componentName];

      // Create React element and render it
      var element = React.createElement(Component, props);

      // Use ReactDOM.render for older versions or createRoot for newer versions
      if (ReactDOM.createRoot) {
        var root = ReactDOM.createRoot(container);
        root.render(element);
        console.log("Successfully mounted", componentName, "using createRoot");
      } else if (ReactDOM.render) {
        ReactDOM.render(element, container);
        console.log("Successfully mounted", componentName, "using render");
      } else {
        console.error("No ReactDOM render method available");
      }
    } catch (error) {
      console.error("Error mounting component", componentName, ":", error);
      container.innerHTML =
        '<div style="color: red; padding: 10px; border: 1px solid red;">Error mounting React component: ' +
        error.message +
        "</div>";
    }
  });

  // Add visual indicator that script ran
  var indicator = document.createElement("div");
  indicator.style.cssText =
    "position: fixed; top: 10px; right: 10px; background: lightgreen; padding: 10px; border: 2px solid green; z-index: 9999; font-family: Arial;";
  indicator.innerHTML =
    "React mounting script executed<br>Check console for details";
  document.body.appendChild(indicator);

  // Remove indicator after 5 seconds
  setTimeout(function () {
    if (indicator.parentNode) {
      indicator.parentNode.removeChild(indicator);
    }
  }, 5000);
});
