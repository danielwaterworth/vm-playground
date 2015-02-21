# Day 1

Today, I'm starting a new project. I want to create a virtual machine, mostly
to learn more about them. There are some features I'd really like.

 * JIT compilation - pretty standard these days, but difficult to get right,
 * Actual multi threading - no GILs here,
 * Immutable data by default - because there just isn't a good reason not to,
 * STM with retry (like Haskell) - for the times when you do need mutation,
 * GC + Regions - GC when you have to, regions when you can,
 * Dynamically typed data - The VM shouldn't constrain languages that target it

Just writing out that list is daunting, it's clear that I'm going to need to
work out an MVP for this project and concentrate on that first.

I'm going to write this in quite a novel way. I'm going to write parts of it in
C and other parts in an EDSL in Haskell that I'll compile into LLVM IR. Then
I'll link them together into an executable.

I want something that does something by the end of the day. Step one will be to
generate a hello world program.

# Interesting links

 * http://blog.reverberate.org/2012/12/hello-jit-world-joy-of-simple-jits.html
