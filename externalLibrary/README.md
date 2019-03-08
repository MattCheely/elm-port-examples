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

then open up [http://localhost:8000/] and play around.
