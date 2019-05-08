; ModuleID = 'main'
source_filename = "main"

define void @main() {
entry:
  %b = alloca i1
  store i1 true, i1* %b
  br i1 true, label %then0, label %else0

then0:                                            ; preds = %entry
  br label %merge0

else0:                                            ; preds = %entry
  br label %merge0

merge0:                                           ; preds = %else0, %then0
  %0 = phi i1 [ false, %then0 ], [ false, %else0 ]
  %a = alloca i64
  store i64 3, i64* %a
  ret void
}
