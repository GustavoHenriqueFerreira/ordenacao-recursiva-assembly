# ordenar.asm
# Implementação da função ordenar(int tamanho, int tipo, int *vetor)
# Esta função agora lida com o vetor de floats representado como pares de inteiros.
# $a0: tamanho (int) - número de elementos float (não de words)
# $a1: tipo (int) - 0 para Inserção, 1 para Quicksort
# $a2: vetor (int*) - ponteiro para o início do vetor de pares de inteiros
# Retorna em $v0: ponteiro para o vetor ordenado (int*)

.text
.globl ordenar

ordenar:
    # Salva registradores $s0, $s1, $s2 e $ra na pilha
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    # Salva os argumentos da função em registradores $s para uso posterior
    add $s0, $a0, $zero # $s0 = tamanho (número de floats)
    add $s1, $a1, $zero # $s1 = tipo
    add $s2, $a2, $zero # $s2 = vetor (ponteiro para int*)

    # Verifica o tipo de ordenação
    beq $s1, $zero, chamar_ordenacao_por_insercao # se tipo == 0, chama ordenacaoPorInsercao
    addi $t0, $zero, 1
    beq $s1, $t0, chamar_ordenacao_rapida      # se tipo == 1, chama ordenacaoRapida

    # Caso tipo inválido, retorna o vetor original (ou erro)
    add $v0, $s2, $zero # Retorna o vetor original
    j fim_ordenar

chamar_ordenacao_por_insercao:
    # Prepara argumentos para ordenacaoPorInsercao(vetor, tamanho)
    add $a0, $s2, $zero # $a0 = vetor (ponteiro para int*)
    add $a1, $s0, $zero # $a1 = tamanho (número de floats)
    jal ordenacaoPorInsercao   # Chama ordenacaoPorInsercao
    add $v0, $s2, $zero # Retorna o vetor ordenado (mesmo ponteiro)
    j fim_ordenar

chamar_ordenacao_rapida:
    # Prepara argumentos para ordenacaoRapida(vetor, baixo, alto)
    add $a0, $s2, $zero # $a0 = vetor (ponteiro para int*)
    add $a1, $zero, $zero # $a1 = baixo = 0
    addi $a2, $s0, -1   # $a2 = alto = tamanho - 1
    jal ordenacaoRapida       # Chama ordenacaoRapida
    add $v0, $s2, $zero # Retorna o vetor ordenado (mesmo ponteiro)
    j fim_ordenar

fim_ordenar:
    # Restaura registradores da pilha
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 16
    jr $ra