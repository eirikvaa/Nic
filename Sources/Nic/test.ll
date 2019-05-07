; ModuleID = 'main'
source_filename = "main"

define void @main() {
entry:
  %a = alloca i64
  store i64 1, i64* %a
  ret void
}
