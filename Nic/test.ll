; ModuleID = 'main'
source_filename = "main"

@helloWorld = global [14 x i8] c"Hello, world!\00", align 1

define void @main() {
entry:
  %compilersAreMagic = alloca i1, align 1
  store i1 false, i1* %compilersAreMagic, align 1
  %answerToLife = alloca i64, align 8
  store i64 42, i64* %answerToLife, align 4
  %computersAreCool = alloca i1, align 1
  store i1 true, i1* %computersAreCool, align 1
  br i1 true, label %then0, label %else0

then0:                                            ; preds = %entry
  br label %merge0

else0:                                            ; preds = %entry
  br label %merge0

merge0:                                           ; preds = %else0, %then0
  %0 = phi i1 [ false, %then0 ], [ false, %else0 ]
  br i1 true, label %then1, label %else1

then1:                                            ; preds = %merge0
  br label %merge1

else1:                                            ; preds = %merge0
  br label %merge1

merge1:                                           ; preds = %else1, %then1
  %1 = phi i1 [ false, %then1 ], [ false, %else1 ]
  %min = alloca double, align 8
  store double 2.000000e+00, double* %min, align 8
  %max = alloca double, align 8
  store double 4.000000e+00, double* %max, align 8
  %average = alloca double, align 8
  store double 3.000000e+00, double* %average, align 8
  ret void
}
