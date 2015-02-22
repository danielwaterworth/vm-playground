# Day 2

## Day 1 retrospective

It didn't go so well. I somehow managed to miss my goal of making hello world
work! LLVM is _really_ complicated and generating it from Haskell isn't making
it much simpler.

I also looked into libraries that can compile SSA (because I don't have the
time or inclination to do register allocation or instruction encoding myself).
All I really learned from this is that I had forgotten how miserable C and C++
are.

## Future directions

The upshot of all this is that I'm changing the plan. I'm going to switch out
Haskell for Idris. I'm going to design a simple SSA-esque language that I'll be
able to reason about within Idris (with proofs) and spit out into files. It'll
have constructs for calling out to C and they'll be some mechanism for JIT
compilation (which, at this level, will just look like eval).

Now, you might think that I'll be compiling this new SSA form into LLVM IR, but
you'd be wrong (at least initially). To begin with, I'll just write an
interpreter. When stuff is working and stable, I can make a compiler for this
language. I might even make an interpreter for it using PyPy, just to play on
people's minds.

## Today

Decide what this language will look like.
