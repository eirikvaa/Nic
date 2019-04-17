#  Parsing

Nic implements a recursive descent parser with the Visitor pattern.
There are two protocols that must be implemented if a class is to walk across the entire tree,
namely `ExprVisitor` and `StmtVisitor`. There are currently plans to implement several
such passes in the compiler:

- The `Resolver` walks the tree and resolves any variables, global and local.
- The `TypeChecker` walks the tree and checks that operations are performed on the correct types.
