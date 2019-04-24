# WebSocket

This is an example of using ports to work with the WebSocket API in Elm.


## How it works.

For an explanation of the approach, look at these files:

 - [WebSocket.elm](app/elm/WebSocket.elm)
 - [webSocket.js](app/js/webSocket.js)

## About Binary Messages

This demo does not handle binary messages. However, it should be possible to create a 
[File](https://developer.mozilla.org/en-US/docs/Web/API/File/File) from a binary message,
send it to Elm and extract the Bytes via [File.decoder](https://package.elm-lang.org/packages/elm/file/latest/File#decoder). 
Unfortunately, there is no direct way to send binary data from Elm
to JS, so some sort of string encoding would have to be used across the port for outbound binary
data.

## Try it out

### Install Dependencies

`npm install`

### Running Locally

`npm start`

