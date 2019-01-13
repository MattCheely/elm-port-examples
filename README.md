# localstorage-experiment

testing localstorage approaches

## Getting Started

### Install Dependencies

`npm install`

### Running Locally

`npm start`

### Running Tests

`npm test`

or

`npm run autotest`

To re-run tests when files change.

### Production build

`npm build`

### Elm Commands

Elm binaries can be found in `node_modules/.bin`, if you do not have Elm
installed globally. With the latest npm you can run:

`npx elm install <packageName>`

to install new packages. Alternatively, you could add scripts in `package.json`
and run them via `npm run ...`

## Libraries & Tools

These are the main libraries and tools used to build localstorage-experiment. If you're not
sure how something works, getting more familiar with these might help.

### [Elm](https://elm-lang.org)

Elm is a delightful language for creating reliable webapps. It guarantees no
runtime exceptions, and provides excellent performance. If you're not familiar
with it, [the official guide](https://guide.elm-lang.org) is a great place to get
started, and the folks on [Slack](https://elmlang.herokuapp.com) and
[Discourse](https://discourse.elm-lang.org) are friendly and helpful if you get
stuck.

### [Elm Test](https://package.elm-lang.org/packages/elm-exploration/test/latest)

This is the standard testing library for Elm. In addition to being useful for
traditional fixed-input unit tests, it also supports property-based testing
where random data is used to validate behavior over a large input space. It's
really useful!

### [Parcel](https://parceljs.org)

Parcel build and bundles the application's assets into individual HTML, CSS, and
JavaScript files. It also runs the live-server used during development.
