; ModuleID = 'main'
source_filename = "main"

define void @main() {
entry:
  %hade = alloca i64
  store i64 3, i64* %hade
  %a = alloca i64
  store i64 10, i64* %a
  ret void
}
