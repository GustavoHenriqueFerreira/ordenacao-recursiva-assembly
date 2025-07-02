# ordenacao_por_insercao.asm
# Implementação da Ordenação por Inserção em MIPS Assembly
# Assinatura da função: void ordenacaoPorInsercao(float vetor[], int tamanho)
# Registradores usados:
# $a0: ponteiro para o início do vetor (vetor)
# $a1: tamanho do vetor (tamanho)
# $t0: i (contador do laço externo)
# $t1: j (contador do laço interno)
# $f0: chave (float)
# $f2: vetor[j] (float)
# $t2: temporário para cálculo de endereço
# $t3: temporário para cálculo de endereço
# $t4: temporário para comparação

.text
.globl ordenacaoPorInsercao

ordenacaoPorInsercao:
    # Salva registradores na pilha (se necessário, para funções maiores)
    # sub $sp, $sp, 12      # Espaço para 3 registradores
    # sw $ra, 8($sp)
    # sw $s0, 4($sp)
    # sw $s1, 0($sp)

    addi $t0, $zero, 1      # i = 1 (laço começa de i=1)

inicio_laco_externo:
    slt $t4, $a1, $t0       # t4 = 1 se tamanho < i (i >= tamanho)
    bne $t4, $zero, fim_laco_externo # se i >= tamanho, vai para o fim

    # chave = vetor[i]
    sll $t2, $t0, 2         # t2 = i * 4 (deslocamento em bytes)
    add $t3, $a0, $t2       # t3 = vetor + i*4 (endereço de vetor[i])
    lwc1 $f0, 0($t3)        # f0 = vetor[i] (chave)

    addi $t1, $t0, -1       # j = i - 1

inicio_laco_interno:
    slt $t4, $t1, $zero     # t4 = 1 se j < 0
    bne $t4, $zero, fim_laco_interno # se j < 0, vai para o fim

    # Carrega vetor[j] para comparação
    sll $t2, $t1, 2         # t2 = j * 4 (deslocamento em bytes)
    add $t3, $a0, $t2       # t3 = vetor + j*4 (endereço de vetor[j])
    lwc1 $f2, 0($t3)        # f2 = vetor[j]

    # se vetor[j] > chave (c.lt.s $f0, $f2 -> chave < vetor[j])
    c.lt.s $f0, $f2         # Compara f0 (chave) < f2 (vetor[j])
    bc1f continua_laco_interno # Se chave >= vetor[j] (ou seja, vetor[j] > chave é falso), continua o laço interno

    # vetor[j + 1] = vetor[j]
    addi $t2, $t1, 1        # t2 = j + 1
    sll $t2, $t2, 2         # t2 = (j + 1) * 4 (deslocamento em bytes)
    add $t3, $a0, $t2       # t3 = vetor + (j+1)*4 (endereço de vetor[j+1])
    swc1 $f2, 0($t3)        # vetor[j+1] = vetor[j]

    addi $t1, $t1, -1       # j = j - 1
    j inicio_laco_interno # Volta para o início do laço interno

continua_laco_interno:
    # vetor[j + 1] = chave
    addi $t2, $t1, 1        # t2 = j + 1
    sll $t2, $t2, 2         # t2 = (j + 1) * 4 (deslocamento em bytes)
    add $t3, $a0, $t2       # t3 = vetor + (j+1)*4 (endereço de vetor[j+1])
    swc1 $f0, 0($t3)        # vetor[j+1] = chave

    addi $t0, $t0, 1        # i++
    j inicio_laco_externo  # Volta para o início do laço externo

fim_laco_externo:
    # Restaura registradores da pilha (se necessário)
    # lw $s1, 0($sp)
    # lw $s0, 4($sp)
    # lw $ra, 8($sp)
    # add $sp, $sp, 12

    jr $ra                  # Retorna da função