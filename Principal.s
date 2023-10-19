.section .data
TOPO_HEAP: .quad

.section .text
.global _start

_start:
pushq %rbp
movq %rsp, %rbp
call _setup_brk
movq %rax, TOPO_HEAP 
pushq $100
pushq -8(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq $50
pushq -16(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq $25
pushq -24(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
