# Elm External Library Ports Example

This is an example of how to integrate with an external library, such as [Plaid 
Link](https://plaid.com/docs/#integrating-with-link) or [Stripe 
Checkout](https://stripe.com/payments/checkout).

## Basic Approach

This example will build on the Plaid Link project, exploring how you can use ports to integrate with a library 
where you cannot control the UI. Either Elm or the outside world should own the state, and here we'll explore 
the Elm app owning the state but having it set by the Link component.

## Running it

You can run this example by using `elm-live`.

```
> elm-live -s index.html src/Main.elm -- --output=main.js
```

then open up [http://localhost:8000/](http://localhost:8000/) and play around.

## Development Tips

I needed to iterate the flow (the actual app has many steps, like a wizard)
so it was necessary to build in a `mockHandler` which would behave like the
real Plaid `liveHandler` but pass data via a super basic UI. It requires
a little more code & mock data, but was key to actual development.
