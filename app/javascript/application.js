// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// React
import React from "react"
import ReactDOM from "react-dom/client"

// Make React available globally
window.React = React
window.ReactDOM = ReactDOM

// Auto-mount React components
document.addEventListener('DOMContentLoaded', function() {
  const reactComponents = document.querySelectorAll('[data-react-component]')
  reactComponents.forEach(function(element) {
    const componentName = element.getAttribute('data-react-component')
    const props = JSON.parse(element.getAttribute('data-react-props') || '{}')

    // Import and render the component
    import(`components/${componentName}`).then(module => {
      const Component = module.default
      const root = ReactDOM.createRoot(element)
      root.render(React.createElement(Component, props))
    }).catch(error => {
      console.error(`Failed to load React component: ${componentName}`, error)
    })
  })
})
