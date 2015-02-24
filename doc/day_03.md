# Day 3

## Day 2 retrospective

I made a decision on what the SSA form should look like. First thing to note is
that there are no Phi nodes. Instead, where you'd normally use Phi nodes, you'd
do a tail call instead. This has the effect that every function is identified
with a basic block (so, instead of talking about basic blocks, I'll talk about
functions).

A function is built up of three parts: the signature, the sequence and the
terminator. Here's an example:

    define foo(a: uint32, b: uint32, result: *uint32) -> unit
      c := add a b
      store result c
      return unit
    end

The signature is what gives a function its type, its name and the names of its
arguments.

The sequence is made up of all of the instructions except for the last one.
Instructions in the sequence aren't able to do any interesting control flow
except for regular function calls (as opposed to tail calls) and `assert`.

The terminator is one of:

 * return,
 * a tail call,
 * a conditional (where each case has a tail call).

Functions and variables live in different scopes (so functions aren't first
class).

### JIT support

Bridging these scopes is the built in support for JIT compilation, which is
made up of three instructions, `jit_compile`, `jit_run` and `jit_free`.

`jit_compile` JIT compiles a function partially applied to some arguments. The
JIT will then do constant propagation (note that things that are constants at
JIT compile time aren't necessary constants at AOT compile time).

`jit_run` takes a JIT compiled function and applies it to its remaining
arguments.

Here's an example:

    f := jit_compile foo(4)
    n := alloca 1
    jit_run f(6, n)
    jit_free f

This is not, perhaps, the interface to a JIT compiler that you'd expect.
However, it has nice properties that make it easy to reason about, so I'm keen
to do it this way if at all possible. I may have to implement more than just
constant propagation to make it efficient.

Having made interpreters with PyPy, their JIT is able to lots of interesting
optimizations based on hints from the writer of the interpreter. It may become
necessary to add such hints as instructions here, but they wouldn't alter the
operational semantics of this language, so they aren't very exciting.

One of these nice properties is that I can do optimizations that are JIT aware.
In the above case, for example, since `jit_run` and `jit_compile` are within
the same function, `jit_run` can be optimized away, so that we end up with:

    f := jit_compile foo(4)
    n := alloca 1
    foo(4, 6, n)
    jit_free f

Then, we have `jit_compile` and `jit_free` used without `jit_run`, so they can
optimized out:

    n := alloca 1
    foo(4, 6, n)

Since foo doesn't branch in its terminator and since it's short, we could
probably inline the call quite safely.

    n := alloca 1
    c := add 4 6
    store n c

Constant propagation can then optimize away the `add`:

    n := alloca 1
    store n 10

As you can see, even in this toy example simple JIT aware optimizations can
potentially open things up for lots of other optimizations.

### Syntax

The above syntax is all well and good, but I said this would be an embedded DSL
within Idris. Well, it will be, I've made a decision on how the AST should be
structured. It makes programs that have type errors unrepresentable, but I
haven't decided DSL's appearance. At some point, the Idris executable will spit
out the processed SSA so that it can be compiled and that is what the syntax
above is (though I may have to add more type information to make it easier to
process).

### Proofs about program execution

I wasn't completely sure how this would work before today, but looking into
proofs by coinduction made things clear. I'll be able to define the operational
semantics of the program by making an execute function that takes the SSA and
produces an Execution (which is codata). Then to prove that the program doesn't
produce undefined behaviour, there would be a OnlyDoesWellDefinedThings type
that is also codata, where, when it is inhabited, proves that an execution is
well defined.

### Next steps

The next step is, as always, to get something simple working. Perhaps
generating output from the AST that I have decided on.
