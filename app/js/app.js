import { Elm } from "../elm/Main.elm";
import { bind as bindStorage } from "./localStorage.js";

// App Initialization

const app = Elm.Main.init({
  node: document.getElementById("app")
});

// LocalStorage

bindStorage(app);
