# Grammar for Nic
The structure and some rules are stolen shamelessly from Swift's [grammar](https://docs.swift.org/swift-book/ReferenceManual/zzSummaryOfTheGrammar.html), but obviously simplified.
There is also quite a bit of [Crafting Interpreters](http://craftinginterpreters.com/) in there.

## Lexical Structure

### Grammar for whitespace
```
whitespace                  ->  <whitespace_item> (whitespace)?
whitespace_item             ->  <linebreak> | <comment> | <multiline_comment> | U+0020 (space)

line_break                  ->  U+000A (newline, \n)

comment                     ->  "//" <comment_text> <line_break>
multiline_comment           ->  "/*" <multiline_comment_text> "*/"

comment_text                ->  <comment_text_item> (<comment_text>)?
comment_text_item           ->  All characters except for newline character

multiline_comment_text      ->  <multiline_comment_text_item> <multi_line_comment_text>
multiline_comment_text_item ->  All characters except '/*' or '*/'
```

### Grammar for identifiers
```
identifier                  ->  [_a-zA-Z][_a-zA-Z0-9]*
```

### Grammar for a type identifier
```
type_identifier             ->  [_a-ZA-Z][_a-zA-Z0-9]*
```

### Grammar for literals
```
literal                     ->  <numeric_literal> | <string_literal> | <boolean_literal>
numeric_literal             ->  (1-9)(0-9)*
string_literal              ->  "(<a-zA-Z0-9>)*"
boolean_literal             ->  "true" | "false"
```

### Grammar for operators
```
operator                    ->  "+" | "-" | "*" | "/" | "=" | "==" | "!=" | ">" | "<" | ">=" | "<="
```

## Expressions

### Grammar of an expression
```
expression                  ->  <assignment>
assignment                  ->  <or> ( ( "=" ) <assignment> )*
or                          ->  <and> ( ( "or" ) <and>  )*
and                         ->  <equality> ( ( "and" ) <equality> )*
equality                    ->  <comparison> ( ( "!=" | "==" ) <comparison> )*
compaison                   ->  <addition> ( ( ">", "<", ">=", "<=" ) <addition> )*
addition                    ->  <multiplication> ( ( "-" | "+" ) <multiplication> )*
multiplication              ->  <unary> ( ( "/" | "*" ) <unary> )*
unary                       ->  ( "!" | "-" ) <unary>
primary                     ->  <literal> | <identifier> | "(" <expression> ")"
```

## Statements

### Grammar of a statement
```
statement                   ->  <print_statement> | <declaration>;
```

### Grammar of a print statement
```
print_statement             ->  "print" <expression>
```

## Declarations

### Grammar for a declaration
```
declaration                 ->  <variable_declaration>
declaration                 ->  <constant_declaration>
```

### Grammar for top-level declarations
```
top_level_declarations      ->  (<statement>)*
```

### Grammar for a variable declaration
```
variable_declaration        ->  "var" <identifier> (":" <type_identifier>)? ("=" <expression>)?
```

### Grammar for a constant declaration
```
constant_declaration        ->  "const" <identifier> (":" <type_identifier>)? "=" <expression>
```
