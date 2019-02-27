var app = {
    elm: null,
    pendingDraws: []
}

function firstPendingDraw() {
	/* 
	shift() is an obscure part of the JS
	array api. It simultaneously returns
	the first element of the array, and 
	mutates the array to no longer include
	that first element.
	*/
    return app.pendingDraws.shift() || null;
}

app.elm = Elm.Main.init();

function toElm(type, payload) {
    app.elm.ports.fromJs.send({
        type: type,
        payload: payload
    });
}

customElements.define(
    "elm-canvas",
    class extends HTMLElement {
        constructor() {
            super();
            var canvas = document.createElement("canvas");
            canvas.width = 400;
            canvas.height = 400;
            canvas.className = "drawing-canvas"
            this.appendChild(canvas);
            this.canvas = canvas;
            this.draw = this.draw.bind(this);
            var draw = this.draw;

            function onAnimationFrame() {
                draw();
                window.requestAnimationFrame(onAnimationFrame);
            }

            onAnimationFrame();
        }

        draw() {
            var nextDraw = firstPendingDraw();
            var ctx = this.canvas.getContext("2d");

            while (nextDraw !== null) {
                var pixel = ctx.createImageData(1, 1);
                var pixelsData = pixel.data

                pixelsData[0] = nextDraw.color.red;
                pixelsData[1] = nextDraw.color.green;
                pixelsData[2] = nextDraw.color.blue;
                pixelsData[3] = nextDraw.color.alpha;

                ctx.putImageData(
                    pixel,
                    nextDraw.position.x,
                    nextDraw.position.y,
                );

                nextDraw = firstPendingDraw();
            }
        }
    }
);

var actions = {
    colorPixels: function (payload) {
        app.pendingDraws = app.pendingDraws.concat(payload);
    }
}

function jsMsgHandler(msg) {
    var action = actions[msg.type];
    if (typeof action === "undefined") {
        console.log("Unrecognized js msg type ->", msg.type);
        return;
    }
    action(msg.payload);
}

app.elm.ports.toJs.subscribe(jsMsgHandler)

