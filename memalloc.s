.section .data
.global TOPO_HEAP
TOPO_HEAP: .quad 0
.section .text
.global setup_brk, dismiss_brk, memory_alloc, memory_free 

# Essa função inicializa o brk e retorna o endereço
# do topo da Heap na variável TOPO_HEAP
setup_brk:
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rdi               # -> Retorna o valor atual de brk e o armazena em rax
    movq $12, %rax              
    syscall
    movq %rax, TOPO_HEAP                   
    popq %rbp
    ret

# Essa função não altera o valor do topo da heap, diferente da setup
get_brk:                    
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rdi               # -> Retorna o valor atual de brk e o armazena em rax
    movq $12, %rax              
    syscall                
    popq %rbp
    ret

# Essa função joga o brk pro topo da heap novamente
dismiss_brk:
    pushq %rbp
    movq %rsp, %rbp
    movq TOPO_HEAP, %rdi        # -> Restaura o endereço de brk, levando-o novamente para o topo
    movq $12, %rax              
    syscall                     
    popq %rbp
    ret

# Função principal de alocar blocos de memória na heap
memory_alloc:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %r15             # - > %r15 = Tamanho requisitado

    call get_brk
    movq TOPO_HEAP, %rbx        # -> %rbx = TOPO_HEAP             
    movq %rax, %r12             # -> %r12 = brk atual

__loop:
    cmp %rbx, %r12              # -> Verifica se %rbx atingiu o brk atual (fim da seção heap).
    je __fora_loop              # -> Se sim, pula pra fora do loop já.
    addq $16, %rbx
    movq -16(%rbx), %r11
    cmp $1, %r11                # -> Verifica se o bloco está ocupado.
    je __caso_indisponivel

__teste_tamanho:
    movq -8(%rbx), %r13         # -> Armazena o tamanho do bloco atual em %r13.
    cmp %r15, %r13              # -> Verifica se o tamanho do bloco atual é
    je __caso_igual             # maior ou igual ao tamanho referente
    jg __caso_maior             # à alocação desejada.
    movq %rbx, %r14
    addq %r13, %r14             # -> %r14 é levado ao próximo bloco.
    cmp %r14, %r12              # -> Verifica se o próximo bloco existe (ou seja,
    je __caso_indisponivel      # se %r14 não é igual ao brk atual), e se está
    movq (%r14), %r11           # ou não ocupado.
    cmp $1, %r11
    je __caso_indisponivel
    addq $8, %r14
    addq $16, -8(%rbx)          # -> Adiciona no tamanho do bloco atual o tamanho do
    movq (%r14), %r11           # bloco seguinte + 16 (8 para disp. e 8 para tam.).
    addq %r11, -8(%rbx)
    jmp __teste_tamanho

__caso_maior:
    movq %r13, %r14             # -> Compara se a diferença entre o tamanho do bloco atual
    subq %r15, %r14             # e o tamanho requisitado para a alocação é pelo menos 17
    cmp $17, %r14               # (8 para disp. 8 para tam. e pelo menos 1 para os dados).
    jl __caso_igual             # Caso seja menor, não haverá como criar um novo bloco...
    subq $16, %r14              # -> Subtrai 16 do tamanho utilizavel deste novo bloco.
    movq %r15, -8(%rbx)         # -> Substitui o tamanho do bloco atual.
    movq %rbx, %r10
    addq %r15, %r10
    movq $0, (%r10)             # -> Marca o bloco criado como disponível.
    addq $8, %r10
    movq %r14, (%r10)           # -> Grava o tamanho do bloco criado. 

__caso_igual:
    movq $1, -16(%rbx)          # -> Marca o bloco atual como ocupado.
    jmp __fim

__caso_indisponivel:
    addq %r13, %rbx             # -> Adiciona o tamanho do bloco no iterador, levando-o
    jmp __loop                  # ao bloco seguinte. -> Retorna para o loop.

__fora_loop:
    addq %r15, %r12             # -> Adicona em brk atual o valor referente ao tamanho da alocação.
    addq $16, %r12              # -> Adiciona 8 para disp. e 8 para armazenar o tamanho.

    movq %r12, %rdi             
    movq $12, %rax              # -> Redefine o brk.
    syscall

    movq $1, (%rbx)             # -> Marca como ocupado.
    addq $8, %rbx
    movq %r15, (%rbx)           # -> Armazena o tamanho 
    addq $8, %rbx

__fim:
    movq %rbx, %rax             # -> Endereço do bloco alocado agora em %rax.
    popq %rbp
    ret

# Função responsável por liberar espaços de memória
# de endereços requisitados
memory_free:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rbx             # -> %rbx = endereço do free requisitado
    call get_brk
    movq %rax, %r13             # -> %r13 = brk atual
    cmp %rbx, TOPO_HEAP 
    jge __erro                  # -> Verifica se o endereço está entre o TOPO_HEAP
    cmp %rbx, %r13              # e o brk_atual.
    jle __erro
    subq $16, %rbx
    movq $0, (%rbx)             # -> Marca como livre.
    movq $1, %rax               # -> Retorna 1, indicando sucesso.
    jmp __fim_erro

__erro:
    movq $0, %rax               # -> Retorna 0, indicando erro.

__fim_erro:
    popq %rbp
    ret
