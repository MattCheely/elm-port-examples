import { Elm } from "../elm/Main.elm";
import { bind } from "./webSocket.js";

let app = Elm.Main.init({
  node: document.getElementById("app")
});

bind(app);
