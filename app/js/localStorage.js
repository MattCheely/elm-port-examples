/*
 * This function binds the ports defined in LocalStorage.elm to
 * the browser's localStorage API.
 */
export function bind(app) {
  // Handle events from Elm
  app.ports.toStorage.subscribe(message => {
    if (message.msgType == "save") {
      saveItem(message.msg);
    } else if (message.msgType == "request") {
      sendItem(message.msg);
    }
  });

  // Broadcast localStorage changes to Elm
  window.addEventListener("storage", function(e) {
    console.log(e);
    if (event.storageArea == localStorage) {
      // Most use cases will only need a subset of the storage event
      // data, but there's more available if you need it.
      // See: https://developer.mozilla.org/en-US/docs/Web/API/StorageEvent
      sendUpdate(e.key, e.newValue);
    }
  });

  // Utility Functions

  /*
   * Make a change to localStorage. If the provided value is null, clear
   * the entry for the key. If there's an error writing to localStorage,
   * send an error event to Elm, but also send the requested value back
   * so the app can track the update in memory if it likes.
   */
  function saveItem(msg) {
    if (msg.value == null) {
      localStorage.removeItem(msg.key);
      sendUpdate(msg.key, msg.value);
    } else {
      try {
        localStorage.setItem(msg.key, msg.value);
        sendUpdate(msg.key, msg.value);
      } catch (e) {
        sendStorageError(msg.key, msg.value, e.message);
      }
    }
  }

  /*
   * Look up a key from storage and send it to Elm.
   */
  function sendItem(key) {
    sendUpdate(key, localStorage.getItem(key));
  }

  /*
   * Send a known update for a key to Elm.
   */
  function sendUpdate(key, value) {
    app.ports.storageEvent.send({ key: key, value: value });
  }

  /*
   * Send an error writing a key to Elm.
   */
  function sendStorageError(key, value, err) {
    app.ports.storageEvent.send({ key: key, value: value, error: err });
  }
}
