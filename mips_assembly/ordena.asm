# ordena.asm
# Implementação da função ordena(int tam, int tipo, float *vetor)
# $a0: tam (int)
# $a1: tipo (int)
# $a2: vetor (float*)
# Retorna em $v0: ponteiro para o vetor ordenado (float*)

.text
.globl ordena

ordena:
    # Salva registradores $s0, $s1, $s2 e $ra na pilha
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    # Salva os argumentos da função em registradores $s para uso posterior
    add $s0, $a0, $zero # $s0 = tam
    add $s1, $a1, $zero # $s1 = tipo
    add $s2, $a2, $zero # $s2 = vetor

    # Verifica o tipo de ordenação
    beq $s1, $zero, call_insertion_sort # if tipo == 0, call insertionSort
    addi $t0, $zero, 1
    beq $s1, $t0, call_quicksort      # if tipo == 1, call quickSort

    # Caso tipo inválido, retorna o vetor original (ou erro)
    add $v0, $s2, $zero # Retorna o vetor original
    j ordena_end

call_insertion_sort:
    # Prepara argumentos para insertionSort(arr, n)
    add $a0, $s2, $zero # arr = vetor
    add $a1, $s0, $zero # n = tam
    jal insertionSort   # Chama insertionSort
    add $v0, $s2, $zero # Retorna o vetor ordenado (mesmo ponteiro)
    j ordena_end

call_quicksort:
    # Prepara argumentos para quickSort(arr, low, high)
    add $a0, $s2, $zero # arr = vetor
    add $a1, $zero, $zero # low = 0
    addi $a2, $s0, -1   # high = tam - 1
    jal quickSort       # Chama quickSort
    add $v0, $s2, $zero # Retorna o vetor ordenado (mesmo ponteiro)
    j ordena_end

ordena_end:
    # Restaura registradores da pilha
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 16
    jr $ra