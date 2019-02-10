(function(){function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s}return e})()({1:[function(require,module,exports){
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


},{}]},{},[1]);
