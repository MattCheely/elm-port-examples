# Elm Canvas Ports Example

This is an example of how to integrate an Html canvas into an Elm project using ports. [you can see it live here](http://elm-canvas-ports-experiment.surge.sh/). Altho, you should probably check out [joakin/elm-canvas](https://github.com/joakin/elm-canvas) if you really just want to do canvas stuff in Elm.


## Basic Approach

This example, like a lot of implementations of ports, utilizes whats called the "actor model". The Elm app is an actor, and it has its own state and its own channels of communication, and the canvas js code is another actor, with its own state, and its own channels of communication. 

When the Elm app wants to update the canvas, it cant just do it, it can only send a message to the canvas actor saying "please do this update". The canvas actor, listening to these requests,adds each requested update to a stack of "pending draws", which it keeps in its state. Every animation frame, the canvas checks its stack of pending draws, and if it sees any, it applies all of them to the html canvas.


Its organized in this way
```
src
├── Data
│   └── Position.elm
├── Main.elm
├── Model.elm
├── Msg.elm
├── Ports.elm
├── Style.elm
├── View.elm
└── app.js
```

Get going with
```
npm install
npm start
```
and then open up `localhost:2957`.