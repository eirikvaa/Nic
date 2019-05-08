; ModuleID = 'main'
source_filename = "main"

define void @main() {
entry:
  %a = alloca i64
  store i64 30, i64* %a
  %b = alloca i1
  store i1 true, i1* %b
  ret void
}
