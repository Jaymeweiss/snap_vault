import React from "react"

export default function HelloWorld({ name = "World" }) {
  return (
    <div className="hello-world">
      <h2>Hello, {name}!</h2>
      <p>This is a React component rendered in Rails 8 with importmap!</p>
    </div>
  )
}