.section .text
.extern TOPO_HEAP
.global _setup_brk, _dismiss_brk, _memory_alloc, _memory_free 

_setup_brk:
pushq %rbp
movq %rsp, %rbp
movq $0, %rdi               # -> Retorna o valor atual
movq $12, %rax              # de brk e o armazena em
syscall                     # %rax.
popq %rbp
ret

_dismiss_brk:
pushq %rbp
movq %rsp, %rbp
movq TOPO_HEAP, %rdi        # -> Restaura o endereço de brk,
movq $12, %rax              # levando-o novamente para
syscall                     # o topo da heap.
popq %rbp
ret

_memory_alloc:
pushq %rbp
movq %rsp, %rbp
movq TOPO_HEAP, %rbx        # -> %rbx = TOPO_HEAP
call _setup_brk             # -> %rax = brk atual
__loop:
cmp %rbx, %rax              # -> Verifica se %rbx atingiu o brk atual
je __fora_loop              # (fim da seção heap).
addq $8, %rbx 
movq (%rbx), %rcx           # -> Armazena o tamanho do bloco atual em %rcx.
addq $8, %rbx
movq -16(%rbx), %r13
cmp $1, %r13                # -> Verifica se o bloco está ocupado.
je __caso_indisponivel
__teste_tamanho:
cmp 16(%rbp), %rcx          # -> Verifica se o tamanho do bloco atual é
je __caso_igual             # maior ou igual ao tamanho referente
jg __caso_maior             # à alocação desejada.
movq %rbx, %rdx
addq %rcx, %rdx             # -> %rdx é levado ao próximo bloco.
cmp %rdx, %rax              # -> Verifica se o próximo bloco existe (ou seja,
je __caso_indisponivel      # se %rdx não é igual ao brk atual), e se está
movq (%rdx), %r13           # ou não ocupado.
cmp $1, %r13
je __caso_indisponivel
addq $8, %rdx
addq $16, %rcx              # -> Adiciona no tamanho do bloco atual o tamanho do
addq (%rdx), %rcx           # bloco seguinte + 16 (8 para disp. e 8 para tam.).
jmp __teste_tamanho
__caso_maior:
movq %rcx, %rdx             # -> Compara se a diferença entre o tamanho do bloco atual
subq 16(%rbp), %rdx         # e o tamanho requisitado para a alocação é pelo menos 17
cmp $17, %rdx               # (8 para disp. 8 para tam. e pelo menos 1 para os dados).
jl __caso_igual             # Caso seja menor, não haverá como criar um novo bloco...
subq $16, %rdx              # -> Subtrai 16 do tamanho utilizavel deste novo bloco.
pushq %rax                  # -> Empilha os valores de %rax e %rdx para
pushq %rdx                  # podermos utilizar estes registradores.
movq 16(%rbp), %rcx         # -> Substitui o tamanho do bloco atual.
movq %rbx, %rdx
addq %rcx, %rdx
movq $0, (%rdx)             # -> Marca o bloco criado como disponível.
addq $8, %rdx
popq %rax
movq %rax, (%rdx)           # -> Grava o tamanho do bloco criado. 
popq %rax                   # -> Desempilha o valor do atual brk novamente em %rax.
__caso_igual:
movq $1, -16(%rbx)          # -> Marca o bloco atual como ocupado.
jmp __fim
__caso_indisponivel:
addq %rcx, %rbx             # -> Adiciona o tamanho do bloco no iterador, levando-o
jmp __loop                  # ao bloco seguinte. -> Retorna para o loop.
__fora_loop:
addq 16(%rbp), %rax         # -> Adicona em brk atual o valor referente ao tamanho da alocação.
addq $16, %rax              # -> Adiciona 8 para disp. e 8 para armazenar o tamanho.
movq %rax, %rdi             
movq $12, %rax              # -> Redefine o brk.
syscall
movq $1, (%rbx)             # -> Marca como ocupado.
addq $8, %rbx
movq (%rdx), %r13
movq 16(%rbp), %r13         # -> Grava o tamanho do bloco de dados.
addq $8, %rbx
__fim:
movq %rbx, %rax             # -> Endereço do bloco alocado agora em %rax.
popq %rbp
ret

_memory_free:
pushq %rbp
movq %rsp, %rbp
movq 16(%rbp), %rax         # -> %rax = endereço passado por parâmetro.
movq (%rax), %rbx           # -> %rbx = endereço do bloco a ser desalocado.
subq $16, %rbx
movq (%rbx), %rcx           # -> %rcx = disponibilidade do bloco.
cmp $0, %rcx                # -> Verifica se o bloco já está desalocado.
je __desalocado
movq $0, %rcx               # -> Marca como livre.
movq $0, %rax               # -> Retorna 0, indicando sucesso.
jmp __fim_desalocacao
__desalocado:
movq $1, %rax               # -> Retorna 1, indicando erro.
__fim_desalocacao:
popq %rbp
ret
