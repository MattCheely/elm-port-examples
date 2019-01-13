/*
 * This function binds the ports defined in LocalStorage.elm to
 * the browser's localStorage API.
 */
export function bind(app) {
  // Handle events from Elm
  app.ports.toStorage.subscribe(message => {
    if (message.msgType == "save") {
      saveItem(message.msg);
    }
  });

  // Broadcast localStorage changes to Elm
  window.addEventListener("storage", function(e) {
    console.log(e);
    if (event.storageArea == localStorage) {
      // Most use cases will only need a subset of the storage event
      // data, but there's more available if you need it.
      // See: https://developer.mozilla.org/en-US/docs/Web/API/StorageEvent
      sendUpdate(e.key, JSON.parse(e.newValue));
    }
  });

  // Utility Functions

  function saveItem(msg) {
    if (msg.value == null) {
      localStorage.removeItem(msg.key);
    } else {
      localStorage.setItem(msg.key, JSON.stringify(msg.value));
    }
    sendUpdate(msg.key, msg.value);
  }

  function sendUpdate(key, value) {
    app.ports.storageEvent.send({ key: key, value: value });
  }
}
