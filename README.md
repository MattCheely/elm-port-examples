# Elm Port Examples

Interfacing with JavaScript via ports in Elm can be challenging. Building systems
in the actor-model style is an unfamiliar task for many developers. Additionally,
it can be hard to find examples of nice port implementations for any given task.

The goal of this repo is twofold:

 1. To provide reference implementations of common use cases for ports
 2. To demonstrate successful approaches to ports that can be adapted to other problems
 
 
## Examples

[localStorage](localStorage/)
[notifications](notification/)


## What if there's no example for my use case?

Well, it's early days yet. Hopefully we'll have more examples soon. In the meantime, please share the specifics 
of your use case on the [Elm Discourse](https://discourse.elm-lang.org/). Be sure to let folks know what you've tried already and what your goals are. 

Here's a list of folks that have had nice experiences with ports and are willing to help out. You can ping them
directly in a pinch, but please be patient as folks have jobs, families, and personal commitments that may need
to be taken care of before helping internet strangers with programming. 

- [Matt Cheely](https://discourse.elm-lang.org/u/matt.cheely) 


Hopefully the community can help put together a nice example for your use case that can be added back here, or 
maybe even come up with a pure Elm solution if you're just binding to a library.

## Contributing an example

Feel free to open a PR with an example app that shows a minimal use of ports to solve
a specific problem. Some things to consider before submitting:

 - We want to show specific cases of direct interaction with JS APIs
 - Priorities for what to work on should look something like:
     1. Browser APIs not currently available in Elm
     2. Bindings to libraries/tools that wouldn't make sense to port to Elm (e.g. React, Ember, Angular)
     3. Bindings to other JS libraries. It would be better to spend time working on a replacement in Elm.
 - Avoid using a port helper library for your solution. We want developers to be able to see all of the code involved.
 - Try to create the minimal app that exercises the use case. The focus should be on the design of the port and port-adjacent code, not amazing app features. 
 - Include an explanation of the reasons for the specific approach you've taken, preferably in comments within the code.
