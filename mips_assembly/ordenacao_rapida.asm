# ordenacao_rapida.asm
# Implementação da Ordenação Rápida (Quicksort) em MIPS Assembly
# Lida com números de ponto flutuante armazenados como pares de inteiros:
# [parte_inteira, parte_decimal_multiplicada_por_1000]
# Assinatura da função principal: void ordenacaoRapida(int* vetor, int baixo, int alto)
# Registradores usados:
# $a0: ponteiro para o vetor (vetor)
# $a1: baixo (índice inicial)
# $a2: alto (índice final)

.text
.globl ordenacaoRapida
.globl particionar
.globl trocar

# --- Função trocar(int* a_ptr, int* b_ptr) ---
# Troca os valores de dois floats representados como pares de inteiros.
# $a0: endereço do primeiro float (parte inteira)
# $a1: endereço do segundo float (parte inteira)
# $t0: valor temporário para parte inteira
# $t1: valor temporário para parte decimal
trocar:
    lw $t0, 0($a0)      # t0 = a->parte_inteira
    lw $t1, 4($a0)      # t1 = a->parte_decimal

    lw $t2, 0($a1)      # t2 = b->parte_inteira
    lw $t3, 4($a1)      # t3 = b->parte_decimal

    sw $t2, 0($a0)      # a->parte_inteira = b->parte_inteira
    sw $t3, 4($a0)      # a->parte_decimal = b->parte_decimal

    sw $t0, 0($a1)      # b->parte_inteira = t0 (original a->parte_inteira)
    sw $t1, 4($a1)      # b->parte_decimal = t1 (original a->parte_decimal)
    jr $ra

# --- Função particionar(int* vetor, int baixo, int alto) ---
# Particiona o vetor em torno de um pivô e retorna o índice final do pivô.
# $a0: vetor
# $a1: baixo
# $a2: alto
# Retorna em $v0: indice_pivo (índice do pivô)
# Registradores salvos: $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $ra
# $s0: vetor (salvo)
# $s1: baixo (salvo)
# $s2: alto (salvo)
# $s3: pivo_parte_inteira
# $s4: pivo_parte_decimal
# $s5: i (índice do menor elemento)
# $s6: j (contador do laço)
# $t0-$t9: temporários

particionar:
    # Salva registradores na pilha
    addi $sp, $sp, -36  # Espaço para $ra, $s0-$s7
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)

    add $s0, $a0, $zero # s0 = vetor
    add $s1, $a1, $zero # s1 = baixo
    add $s2, $a2, $zero # s2 = alto

    # pivo = vetor[alto]
    sll $t0, $s2, 3     # t0 = alto * 8 (deslocamento em bytes, 2 words por float)
    add $t1, $s0, $t0   # t1 = vetor + alto*8 (endereço de vetor[alto])
    lw $s3, 0($t1)      # s3 = pivo_parte_inteira
    lw $s4, 4($t1)      # s4 = pivo_parte_decimal

    # i = (baixo - 1)
    addi $s5, $s1, -1   # s5 = baixo - 1

    # for (j = baixo; j <= alto - 1; j++)
    add $s6, $s1, $zero # s6 = j = baixo
    addi $t0, $s2, -1   # t0 = alto - 1

inicio_laco_particao:
    slt $t7, $t0, $s6   # t7 = 1 se alto - 1 < j (j > alto - 1)
    bne $t7, $zero, fim_laco_particao # se j > alto - 1, vai para o fim

    # Carrega vetor[j] para comparação
    sll $t1, $s6, 3     # t1 = j * 8
    add $t2, $s0, $t1   # t2 = vetor + j*8 (endereço de vetor[j])
    lw $t3, 0($t2)      # t3 = vetor[j].parte_inteira
    lw $t4, 4($t2)      # t4 = vetor[j].parte_decimal

    # Compara vetor[j] < pivo
    # Primeiro compara a parte inteira
    slt $t7, $t3, $s3       # t7 = 1 se vetor[j].parte_inteira < pivo_parte_inteira
    bne $t7, $zero, condicao_verdadeira # Se menor, então vetor[j] < pivo

    # Se partes inteiras são iguais, compara a parte decimal
    beq $t3, $s3, compara_decimal_particao
    j condicao_falsa        # Se vetor[j].parte_inteira > pivo_parte_inteira, então vetor[j] > pivo

compara_decimal_particao:
    slt $t7, $t4, $s4       # t7 = 1 se vetor[j].parte_decimal < pivo_parte_decimal
    bne $t7, $zero, condicao_verdadeira # Se menor, então vetor[j] < pivo
    j condicao_falsa        # Se maior ou igual, então vetor[j] >= pivo

condicao_verdadeira:
    # i++
    addi $s5, $s5, 1

    # trocar(&vetor[i], &vetor[j])
    sll $a0, $s5, 3     # a0 = i * 8
    add $a0, $s0, $a0   # a0 = vetor + i*8 (endereço de vetor[i])
    sll $a1, $s6, 3     # a1 = j * 8
    add $a1, $s0, $a1   # a1 = vetor + j*8 (endereço de vetor[j])
    jal trocar

condicao_falsa:
    addi $s6, $s6, 1    # j++
    j inicio_laco_particao

fim_laco_particao:
    # trocar(&vetor[i + 1], &vetor[alto])
    addi $t0, $s5, 1    # t0 = i + 1
    sll $a0, $t0, 3     # a0 = (i+1) * 8
    add $a0, $s0, $a0   # a0 = vetor + (i+1)*8 (endereço de vetor[i+1])
    sll $a1, $s2, 3     # a1 = alto * 8
    add $a1, $s0, $a1   # a1 = vetor + alto*8 (endereço de vetor[alto])
    jal trocar

    # return (i + 1)
    addi $v0, $s5, 1    # v0 = i + 1

    # Restaura registradores da pilha
    lw $ra, 32($sp)
    lw $s0, 28($sp)
    lw $s1, 24($sp)
    lw $s2, 20($sp)
    lw $s3, 16($sp)
    lw $s4, 12($sp)
    lw $s5, 8($sp)
    lw $s6, 4($sp)
    lw $s7, 0($sp)
    addi $sp, $sp, 36
    jr $ra

# --- Função ordenacaoRapida(int* vetor, int baixo, int alto) ---
# $a0: vetor
# $a1: baixo
# $a2: alto
# Registradores salvos: $s0, $s1, $s2, $ra

ordenacaoRapida:
    # Salva registradores na pilha
    addi $sp, $sp, -16  # Espaço para $ra, $s0, $s1, $s2
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    add $s0, $a0, $zero # s0 = vetor
    add $s1, $a1, $zero # s1 = baixo
    add $s2, $a2, $zero # s2 = alto

    slt $t0, $s2, $s1   # t0 = 1 se alto < baixo (baixo >= alto)
    bne $t0, $zero, fim_ordenacao_rapida # se baixo >= alto, retorna

    # int indice_pivo = particionar(vetor, baixo, alto);
    add $a0, $s0, $zero # vetor
    add $a1, $s1, $zero # baixo
    add $a2, $s2, $zero # alto
    jal particionar
    add $t0, $v0, $zero # t0 = indice_pivo

    # ordenacaoRapida(vetor, baixo, indice_pivo - 1);
    add $a0, $s0, $zero # vetor
    add $a1, $s1, $zero # baixo
    addi $a2, $t0, -1   # indice_pivo - 1
    jal ordenacaoRapida

    # ordenacaoRapida(vetor, indice_pivo + 1, alto);
    add $a0, $s0, $zero # vetor
    addi $a1, $t0, 1    # indice_pivo + 1
    add $a2, $s2, $zero # alto
    jal ordenacaoRapida

fim_ordenacao_rapida:
    # Restaura registradores da pilha
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 16
    jr $ra