import { Elm } from "../elm/Main.elm";
import { bind as bindNotification } from "./notification.js";

// App Initialization

const app = Elm.Main.init({
  node: document.getElementById("app")
});

// Notification

bindNotification(app);
