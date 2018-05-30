#  Nic
## What is Nic?
I *just* thought of building my own programming language, and I needed a short and sweet name. I looked over at my rubber duck which had the name *Nordic* on it, and i just took the first and two last letters. Nic. Short and sweet. Not really important.

How should it look like?

```
var myVariable: String = "Eirik"
const myConstant: Int = 1

var a: Int = 1, b: String = "Eirik"

function helloWorld() -> None {
    print("Hello, world!")
}


var myUnion: String | Int = "Eirik" | 1
```

## Regular definitions
```
<var-decl> -> <var> <id> (<:> <type>)? <=> <literal>
<const-decl> -> <const> <id> (<:> <type>)? <=> <literal>
<multiple-decl> -> (<var> | <const>)(<id> (<:> <type>)? <=> <literal> <,>)* <id> (<:> <type>)? <=> <literal>
<union-decl> -> <var> <id> <:> <type> (<union-type> <type>)* <=> <literal> (<union-type> | <literal>)*
```

## What language should I write Nic in?
The smart thing would be to do this in Swift. That would make it a lot easier to get my ideas into the language. When I have a minimal product I can do it in C. Or maybe C++? That would be awesome. Then I could understand the Swift compiler a lot better.
