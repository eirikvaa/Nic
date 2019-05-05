; ModuleID = 'main'
source_filename = "main"

define void @main() {
entry:
  %a = alloca i64
  store i64 5, i64* %a
  %b = alloca i64
  store i64 5, i64* %b
  ret void
}
