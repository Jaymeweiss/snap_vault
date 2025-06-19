# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# React
pin "react", to: "https://ga.jspm.io/npm:react@18.2.0/index.js"
pin "react-dom", to: "https://ga.jspm.io/npm:react-dom@18.2.0/index.js"
pin "scheduler", to: "https://ga.jspm.io/npm:scheduler@0.23.0/index.js"

# React Router
pin "react-router", to: "https://ga.jspm.io/npm:react-router@6.8.1/index.js"
pin "react-router-dom", to: "https://ga.jspm.io/npm:react-router-dom@6.8.1/index.js"
pin "@remix-run/router", to: "https://ga.jspm.io/npm:@remix-run/router@1.3.2/index.js"
pin_all_from "app/javascript/components", under: "components"
