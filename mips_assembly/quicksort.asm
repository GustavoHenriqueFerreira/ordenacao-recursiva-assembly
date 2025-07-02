# ordenacao_rapida.asm
# Implementação da Ordenação Rápida (Quicksort) em MIPS Assembly
# Assinatura da função principal: void ordenacaoRapida(float vetor[], int baixo, int alto)
# Registradores usados:
# $a0: ponteiro para o vetor (vetor)
# $a1: baixo (índice inicial)
# $a2: alto (índice final)

.text
.globl ordenacaoRapida
.globl particionar
.globl trocar

# --- Função trocar(float* a, float* b) ---
# $a0: endereço de a
# $a1: endereço de b
# $f0: temp (float)
trocar:
    lwc1 $f0, 0($a0)    # f0 = *a
    lwc1 $f1, 0($a1)    # f1 = *b
    swc1 $f1, 0($a0)    # *a = *b
    swc1 $f0, 0($a1)    # *b = temp
    jr $ra

# --- Função particionar(float vetor[], int baixo, int alto) ---
# $a0: vetor
# $a1: baixo
# $a2: alto
# Retorna em $v0: indice_pivo (índice do pivô)
# Registradores salvos: $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $ra
# $s0: vetor
# $s1: baixo
# $s2: alto
# $s3: pivo (float)
# $s4: i
# $s5: j
# $f4: vetor[j] (float)

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
    sll $t0, $s2, 2     # t0 = alto * 4
    add $t1, $s0, $t0   # t1 = vetor + alto*4 (endereço de vetor[alto])
    lwc1 $s3, 0($t1)    # s3 = vetor[alto] (pivo)

    # i = (baixo - 1)
    addi $s4, $s1, -1   # s4 = baixo - 1

    # for (j = baixo; j <= alto - 1; j++)
    add $s5, $s1, $zero # s5 = j = baixo
    addi $t0, $s2, -1   # t0 = alto - 1

inicio_laco_particao:
    slt $t6, $t0, $s5   # t6 = 1 se alto - 1 < j (j > alto - 1)
    bne $t6, $zero, fim_laco_particao # se j > alto - 1, vai para o fim

    # se vetor[j] < pivo
    sll $t1, $s5, 2     # t1 = j * 4
    add $t2, $s0, $t1   # t2 = vetor + j*4 (endereço de vetor[j])
    lwc1 $f4, 0($t2)    # f4 = vetor[j]

    c.lt.s $f4, $s3     # Compara f4 (vetor[j]) < s3 (pivo)
    bc1f continua_laco_particao # Se vetor[j] >= pivo, continua o laço sem troca

    # i++
    addi $s4, $s4, 1

    # trocar(&vetor[i], &vetor[j])
    sll $a0, $s4, 2     # a0 = i * 4
    add $a0, $s0, $a0   # a0 = vetor + i*4 (endereço de vetor[i])
    sll $a1, $s5, 2     # a1 = j * 4
    add $a1, $s0, $a1   # a1 = vetor + j*4 (endereço de vetor[j])
    jal trocar

continua_laco_particao:
    addi $s5, $s5, 1    # j++
    j inicio_laco_particao

fim_laco_particao:
    # trocar(&vetor[i + 1], &vetor[alto])
    addi $t0, $s4, 1    # t0 = i + 1
    sll $a0, $t0, 2     # a0 = (i+1) * 4
    add $a0, $s0, $a0   # a0 = vetor + (i+1)*4 (endereço de vetor[i+1])
    sll $a1, $s2, 2     # a1 = alto * 4
    add $a1, $s0, $a1   # a1 = vetor + alto*4 (endereço de vetor[alto])
    jal trocar

    # return (i + 1)
    addi $v0, $s4, 1    # v0 = i + 1

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

# --- Função ordenacaoRapida(float vetor[], int baixo, int alto) ---
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