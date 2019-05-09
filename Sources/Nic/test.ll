; ModuleID = 'main'
source_filename = "main"

define void @main() {
entry:
  %test = alloca double
  store double 1.000000e+00, double* %test
  ret void
}
