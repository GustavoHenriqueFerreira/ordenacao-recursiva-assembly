# ordenacao_por_insercao.asm
# Implementação da Ordenação por Inserção em MIPS Assembly
# Lida com números de ponto flutuante armazenados como pares de inteiros:
# [parte_inteira, parte_decimal_multiplicada_por_1000]
# Assinatura da função: void ordenacaoPorInsercao(int* vetor, int tamanho)
# Registradores usados:
# $a0: ponteiro para o início do vetor (vetor)
# $a1: número de elementos (pares de inteiros) no vetor (tamanho)
# $t0: i (contador do laço externo)
# $t1: j (contador do laço interno)
# $t2: endereço base do elemento vetor[i] (chave)
# $t3: endereço base do elemento vetor[j]
# $t4: temporário para comparação
# $s0: parte_inteira_chave
# $s1: parte_decimal_chave
# $s2: parte_inteira_vetor_j
# $s3: parte_decimal_vetor_j

.text
.globl ordenacaoPorInsercao

ordenacaoPorInsercao:
    # Salva registradores $s na pilha (caller-saved)
    addi $sp, $sp, -16
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    addi $t0, $zero, 1      # i = 1 (laço começa de i=1)

inicio_laco_externo:
    slt $t4, $a1, $t0       # t4 = 1 se tamanho < i (i >= tamanho)
    bne $t4, $zero, fim_laco_externo # se i >= tamanho, vai para o fim

    # Calcula endereço base de vetor[i] (chave)
    sll $t2, $t0, 3         # t2 = i * 8 (deslocamento em bytes, 2 words por float)
    add $t2, $a0, $t2       # t2 = vetor + i*8 (endereço base de vetor[i])

    # Carrega chave = vetor[i]
    lw $s0, 0($t2)          # s0 = parte_inteira_chave
    lw $s1, 4($t2)          # s1 = parte_decimal_chave

    addi $t1, $t0, -1       # j = i - 1

inicio_laco_interno:
    slt $t4, $t1, $zero     # t4 = 1 se j < 0
    bne $t4, $zero, fim_laco_interno # se j < 0, vai para o fim

    # Calcula endereço base de vetor[j]
    sll $t3, $t1, 3         # t3 = j * 8 (deslocamento em bytes)
    add $t3, $a0, $t3       # t3 = vetor + j*8 (endereço base de vetor[j])

    # Carrega vetor[j] para comparação
    lw $s2, 0($t3)          # s2 = parte_inteira_vetor_j
    lw $s3, 4($t3)          # s3 = parte_decimal_vetor_j

    # Compara vetor[j] > chave
    # Primeiro compara a parte inteira
    slt $t4, $s0, $s2       # t4 = 1 se parte_inteira_chave < parte_inteira_vetor_j
    bne $t4, $zero, continua_laco_interno # Se parte_inteira_chave < parte_inteira_vetor_j, então chave < vetor[j], então vetor[j] > chave é verdadeiro

    # Se partes inteiras são iguais, compara a parte decimal
    beq $s0, $s2, compara_parte_decimal
    j fim_comparacao_interno # Se parte_inteira_chave > parte_inteira_vetor_j, então chave > vetor[j], então vetor[j] > chave é falso

compara_parte_decimal:
    slt $t4, $s1, $s3       # t4 = 1 se parte_decimal_chave < parte_decimal_vetor_j
    bne $t4, $zero, continua_laco_interno # Se parte_decimal_chave < parte_decimal_vetor_j, então chave < vetor[j], então vetor[j] > chave é verdadeiro

fim_comparacao_interno:
    # Se chegou aqui, significa que vetor[j] > chave é falso (vetor[j] <= chave)
    # Então, sai do laço interno e insere a chave
    j fim_laco_interno

continua_laco_interno:
    # vetor[j + 1] = vetor[j]
    addi $t4, $t1, 1        # t4 = j + 1
    sll $t4, $t4, 3         # t4 = (j + 1) * 8 (deslocamento em bytes)
    add $t5, $a0, $t4       # t5 = vetor + (j+1)*8 (endereço base de vetor[j+1])

    sw $s2, 0($t5)          # vetor[j+1].parte_inteira = vetor[j].parte_inteira
    sw $s3, 4($t5)          # vetor[j+1].parte_decimal = vetor[j].parte_decimal

    addi $t1, $t1, -1       # j = j - 1
    j inicio_laco_interno # Volta para o início do laço interno

fim_laco_interno:
    # vetor[j + 1] = chave
    addi $t4, $t1, 1        # t4 = j + 1
    sll $t4, $t4, 3         # t4 = (j + 1) * 8 (deslocamento em bytes)
    add $t5, $a0, $t4       # t5 = vetor + (j+1)*8 (endereço base de vetor[j+1])

    sw $s0, 0($t5)          # vetor[j+1].parte_inteira = parte_inteira_chave
    sw $s1, 4($t5)          # vetor[j+1].parte_decimal = parte_decimal_chave

    addi $t0, $t0, 1        # i++
    j inicio_laco_externo  # Volta para o início do laço externo

fim_laco_externo:
    # Restaura registradores da pilha
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 16

    jr $ra                  # Retorna da função