# Double-Dhall

This repository is a simple example of how Double arithmetic can be added to
[Dhall](https://github.com/dhall-lang/dhall-lang/).

It adds four functions:

* `Double/add`
* `Double/sub`
* `Double/mul`
* `Double/div`

Which can be used to do double arithmetic. [readme.dhall](readme.dhall)
contains a demo of these, which generates this very file (README.md).

Here are examples of using the Double functions:

    Double/add 2.0 3.0 = 5.0
    Double/sub 1.0 0.5 = 0.5
    Double/mul 5.5 1.5 = 8.25
    Double/div 8.0 2.0 = 4.0

Edge cases for division work as you might expect for Double:

    Double/div 1.0 0.0 = Infinity
    Double/div 0.0 0.0 = NaN

This code was adapted from [this
guide](https://github.com/dhall-lang/dhall-lang/wiki/How-to-add-a-new-built-in-function),
the main difference being it adds multiple functions instead of just one.

# Generating README.md

This README is generated by running the following command:

    cat readme.dhall | cabal run
