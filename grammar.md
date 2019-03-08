# Grammar for Nic

The following is the grammar for the Nic programming language:

## Variable declarations

```
variable_declaration -> var <identifier> = <variable_declaration_value>
variable_declaration_value -> <integer> | <string>
identifier -> [_a-zA-Z][_a-zA-Z0-9]*
integer -> (1-9)(0-9)*
string -> "<a-zA-Z0-9>"
```

## Function declarations

```
function_declaration -> function <identifier> ( <parameter_list> ) -> { <function_body> }
parameter_list -> (identifier : identifier)*
function_body -> (statement)*
statement -> if_statement | variable_declaration | function_call
function_call -> <identifier> ( <argument_list> )
argument_list -> variable_declaration_value | (variable_declaration_value, argument_list) | e
```
