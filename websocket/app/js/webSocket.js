/*
 * This function binds the ports defined in WebSocket.elm to
 * the browser's localStorage API.
 */
export function bind(app) {
  // Exit predictably if the ports aren't in use in Elm
  if (!app.ports || !(app.ports.toSocket && app.ports.fromSocket)) {
    console.log(
      "Could not find 'toSocket' and 'fromSocket' ports on app. They may not be in use yet."
    );
    return;
  }

  let sockets = {};

  // Handle events from Elm
  app.ports.toSocket.subscribe(message => {
    switch (message.msgType) {
      case "connect":
        openWebsocket(message.msg);
        break;
      case "sendString":
        sendString(message.msg);
        break;
    }
  });

  // Opens a new websocket it and tracks it by URL so that messages from Elm can
  // be directed to it. This may be overkill if your app only uses a single socket.
  function openWebsocket(request) {
    // Don't open the same socket twice.
    if (sockets[request.url]) {
      console.log(
        `There's already an open socket for ${request.url}, ignoring request.`
      );
      return;
    }
    let toElm = app.ports.fromSocket;
    let socket = new WebSocket(request.url, request.protocols);

    socket.onopen = openHandler.bind(null, toElm, socket, request.url);
    socket.onmessage = messageHandler.bind(null, toElm, request.url);
    socket.onerror = errorHandler.bind(null, toElm, request.url);
    socket.onclose = closeHandler.bind(null, toElm, sockets, request.url);

    sockets[request.url] = socket;
  }

  // Sends a string on a socket. The request to send from Elm should contain
  // the URL of the socket.
  function sendString(request) {
    let socket = sockets[request.url];
    if (socket) {
      socket.send(request.message);
    } else {
      console.log(
        `No open socket for: ${request.url}. Cannot send ${request.message}`
      );
    }
  }
}

// SOCKET HELPER FUNCTIONS

// When the socket opens, we send a message to Elm with some metadata
// about the negotiated connection.
function openHandler(toElm, socket, url, event) {
  toElm.send({
    msgType: "connected",
    msg: {
      url: url,
      binaryType: socket.binaryType,
      extensions: socket.extensions,
      protocol: socket.protocol
    }
  });
}

// When we get a message from the socket, we send it to Elm.
function messageHandler(toElm, url, event) {
  if (typeof event.data == "string") {
    toElm.send({
      msgType: "stringMessage",
      msg: event.data
    });
  } else {
    // We do not handle incoming binary messages.
    // It should be possible to create a `File` from a binary message
    // and send it to Elm. https://developer.mozilla.org/en-US/docs/Web/API/File/File
    // Unfortunately, there is no direct way to send binary data from Elm
    // to JS, so some sort of string encoding would have to be used
    console.log(`No binary message handling implemented`);
  }
}

// Send errors to Elm
function errorHandler(toElm, url, event) {
  toElm.send({
    msgType: "error",
    msg: {
      url: url,
      code: event.code
    }
  });
}

// Send close notifications to Elm, and stop tracking the socket. Include the
// number of bytes still unset.
function closeHandler(toElm, sockets, url, event) {
  let socket = sockets[url];
  sockets[url] = undefined;

  toElm.send({
    msgType: "closed",
    msg: {
      url: url,
      unsetBytes: socket.bufferedAmount
    }
  });
}
