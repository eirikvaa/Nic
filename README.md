#  Nic

## What is Nic?

Since about halfway into my studies at the Norwegian University of Science and Technology (NTNU), I have been interested in programming languages and compilers. I have followed the fantastic guide by [Crafting Interpreters](http://craftinginterpreters.com/) for quite some time now, but the way to truly learn something is to do it yourself. That's why I want to create _my own_ programming language from scratch.

I have zero and all plans for Nic. I just want to try to create _something_ that can work. I also want it to compile to machine code and have a strong type system. These things are way over my head right now, but I'm hoping that when I learn more and more concepts, I can incorporate it into my own language. It will be a fun exercise, and something to show for other people.

## Where did the name come from?

Nic is truly a random name. I have a rubber duck at home with the name "Nordic Semiconductor", and this was at the point where I wast _just_ starting to think about my new programming language, back in January 2018. I just took the first and two last letters of the word _Nordic_, and there it was. Truly underwhelming, one might say. But the name isn't important here.

## How does Nic look right now?

Exciting things are happening now. LLVM has been incoporated in the form of [LLVM](https://github.com/llvm-swift/LLVMSwift). Only variable declarations are permitted as of now. Below is an example of the current pipeline.

```
// Source code
var helloWorld = "Hello, world!";
var hei = 1 + 1;

// After tokenization
[VAR, IDENTIFIER, EQUAL, STRING, SEMICOLON, VAR, IDENTIFIER, EQUAL, NUMBER, PLUS, NUMBER, SEMICOLON, EOF]

// Generated LLVM IR
; ModuleID = 'main'
source_filename = "main"

@helloWorld = global [14 x i8] c"Hello, world!\00", align 1
@hei = global i64 2

define void @main() {
entry:
}
```
