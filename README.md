# Elm Port Examples

Interfacing with JavaScript via ports in Elm can be challenging. Building systems
in the actor-model style is an unfamiliar task for many developers. Additionally,
it can be hard to find examples of nice port implementations for any given task.

The goal of this repo is twofold:

 1. To provide reference implementations of common use cases for ports
 2. To demonstrate successful approaches to ports that can be adapted to other problems
 
 
## Examples

[localStorage](localStorage/)


## Contributing an Example

Feel free to open a PR with an example app that shows a minimal use of ports to solve
a specific problem. Some things to consider before submitting:

 - We want to show specific cases of direct interaction with JS APIs
 - Avoid using a port helper library for your solution. We want developers to be able to see all of the code involved.
 - Try to create the minimal app that exercises the use case. The focus should be on the design of the port and port-adjacent code, not amazing app features. 
