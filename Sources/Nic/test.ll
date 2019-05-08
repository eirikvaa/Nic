; ModuleID = 'main'
source_filename = "main"

define void @main() {
entry:
  %a = alloca i1
  store i1 true, i1* %a
  ret void
}
