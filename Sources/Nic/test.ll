; ModuleID = 'main'
source_filename = "main"

define void @main() {
entry:
  %boolean = alloca i1
  store i1 true, i1* %boolean
  br i1 true, label %then0, label %else0

then0:                                            ; preds = %entry
  br label %merge0

else0:                                            ; preds = %entry
  br label %merge0

merge0:                                           ; preds = %else0, %then0
  %0 = phi i1 [ false, %then0 ], [ false, %else0 ]
  ret void
}
