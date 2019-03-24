# Grammar for Nic

The following is the grammar for the Nic programming language:

```
program                 ->  (<declaration>)*
declaration             ->  <variable_declaration> |
                            <function_declaration> |
                            <class_declaration>

variable_declaration    -> var <identifier> = <variable_value>

function_declaration    ->  function <identifier> ( <parameter_list> ) -> { <function_body> }
parameter_list          ->  (identifier : identifier)*
function_body           ->  (statement)*
statement               ->  if_statement |
                            variable_declaration | 
                            function_call
function_call           ->  <identifier> ( <argument_list> )
argument_list           ->  variable_declaration_value |
                            (variable_declaration_value, argument_list) | 
                            e
variable_value          ->  <number> |
                            <string>
identifier              ->  [_a-zA-Z][_a-zA-Z0-9]*
integer                 ->  (1-9)(0-9)*
string                  ->  "<a-zA-Z0-9>"

class_declaration       ->  class <identifier> { class_body }
class_body              ->  variable_declaration |
                            function_declaration

if_statement            ->  if <boolean_expression> { (<statement>)* }

expression              -> <boolean_expression> 
```
