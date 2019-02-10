var gulp = require("gulp");
var source = require("vinyl-source-stream");
var buffer = require("vinyl-buffer");
var cp = require("child_process");
var browserify = require("browserify");
var util = require("gulp-util");


var paths = {
  public: "./public",
  dist: "./dist",
  mainElm: "./src/Main.elm",
  elm: "./src/**/*.elm",
  js: "./src/*.js"
};


gulp.task("js", function () {
  return browserify("./src/app.js")
    .bundle()
    .pipe(source("app.js"))
    .pipe(buffer())
    .pipe(gulp.dest(paths.public));
});


gulp.task("elm", function () {
  util.log(util.colors.cyan("Elm"), "starting");
  cp.spawn("elm", [
    "make",
    paths.mainElm,
    "--output",
    paths.public + "/elm.js"
  ], {
      stdio: 'inherit'
    }).on("close", function (code) {
      util.log(util.colors.cyan("Elm"), "closed");
    });
});


gulp.task("server", function () {
  return require("./server")(2957, util.log);
});


gulp.task("dist", function () {
  production = true;
  gulp.task("default");

  return gulp
    .src(paths.public + "/**/*")
    .pipe(gulp.dest(paths.dist));
})


gulp.watch(paths.elm, ["elm"]);
gulp.watch(paths.js, ["js"]);


gulp.task("default", ["elm", "js", "server"]);
