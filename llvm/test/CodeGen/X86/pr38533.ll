; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown | FileCheck %s --check-prefixes=CHECK,SSE
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=avx512f | FileCheck %s --check-prefixes=CHECK,AVX512

; This test makes sure that a vector that needs to be promoted that is bitcasted to fp16 is legalized correctly without causing a width mismatch.
define void @constant_fold_vector_to_half() {
; CHECK-LABEL: constant_fold_vector_to_half:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movw $16384, (%rax) # imm = 0x4000
; CHECK-NEXT:    retq
  store volatile half bitcast (<4 x i4> <i4 0, i4 0, i4 0, i4 4> to half), half* undef
  ret void
}

; Similarly this makes sure that the opposite bitcast of the above is also legalized without crashing.
define void @pr38533_2(half %x) {
; SSE-LABEL: pr38533_2:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rax
; SSE-NEXT:    .cfi_def_cfa_offset 16
; SSE-NEXT:    callq __gnu_f2h_ieee
; SSE-NEXT:    movw %ax, (%rax)
; SSE-NEXT:    popq %rax
; SSE-NEXT:    .cfi_def_cfa_offset 8
; SSE-NEXT:    retq
;
; AVX512-LABEL: pr38533_2:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    movw %ax, (%rax)
; AVX512-NEXT:    retq
  %a = bitcast half %x to <4 x i4>
  store volatile <4 x i4> %a, <4 x i4>* undef
  ret void
}

; This case is a bitcast from fp16 to a 16-bit wide legal vector type. In this case the result type is legal when the bitcast gets type legalized.
define void @pr38533_3(half %x) {
; SSE-LABEL: pr38533_3:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rax
; SSE-NEXT:    .cfi_def_cfa_offset 16
; SSE-NEXT:    callq __gnu_f2h_ieee
; SSE-NEXT:    movw %ax, (%rax)
; SSE-NEXT:    popq %rax
; SSE-NEXT:    .cfi_def_cfa_offset 8
; SSE-NEXT:    retq
;
; AVX512-LABEL: pr38533_3:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    movw %ax, (%rax)
; AVX512-NEXT:    retq
  %a = bitcast half %x to <16 x i1>
  store volatile <16 x i1> %a, <16 x i1>* undef
  ret void
}