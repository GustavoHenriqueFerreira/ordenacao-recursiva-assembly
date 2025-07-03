.data
tam:        .word 6
vetor:      .float 5.2, 3.1, 6.6, 1.0, 9.3, 2.2
msg:        .asciiz "\nVetor ordenado:\n"
newline:    .asciiz "\n"

.text
.globl main

main:
    lw $a0, tam         # a0 = tamanho do vetor
    li $a1, 1           # a1 = tipo de ordenação (0 = insertion, 1 = quick)
    la $a2, vetor       # a2 = endereço do vetor
    jal ordena

    # v0 = ponteiro para vetor ordenado
    move $t2, $v0       # usar vetor retornado

    li $v0, 4
    la $a0, msg
    syscall

    li $t0, 0           # índice
    lw $t1, tam

print_loop:
    bge $t0, $t1, fim

    mul $t3, $t0, 4
    add $t4, $t2, $t3   # <- agora usando o ponteiro retornado
    l.s $f12, 0($t4)

    li $v0, 2
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    addi $t0, $t0, 1
    j print_loop

fim:
    li $v0, 10
    syscall

####################################################
# Função: ordena (tipo 0 = insertion, tipo 1 = quick)
# Assinatura: float* ordena(int tam, int tipo, float* vetor)
####################################################
ordena:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a2       # salvar ponteiro vetor

    beq $a1, 0, insertion_sort
    beq $a1, 1, quick_sort
    j fim_ordena

insertion_sort:
    li $t0, 1           # i = 1
loop_i:
    bge $t0, $a0, fim_insertion

    mul $t1, $t0, 4
    add $t2, $s0, $t1
    l.s $f2, 0($t2)     # key = vetor[i]

    addi $t3, $t0, -1   # j = i - 1

loop_j:
    blt $t3, 0, fim_j
    mul $t4, $t3, 4
    add $t5, $s0, $t4
    l.s $f4, 0($t5)

    c.le.s $f4, $f2
    bc1t fim_j

    s.s $f4, 4($t5)     # vetor[j + 1] = vetor[j]
    addi $t3, $t3, -1
    j loop_j

fim_j:
    addi $t3, $t3, 1
    mul $t6, $t3, 4
    add $t7, $s0, $t6
    s.s $f2, 0($t7)

    addi $t0, $t0, 1
    j loop_i

fim_insertion:
    j fim_ordena

quick_sort:
    move $s1, $a0       # s1 = tam
    move $s2, $a2       # s2 = vetor

    move $a0, $s2       # vetor
    li   $a1, 0         # low = 0
    addi $a2, $s1, -1   # high = tam - 1

    jal quicksort
    j fim_ordena

fim_ordena:
    move $v0, $s0       # retorna ponteiro

    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 8
    jr $ra

####################################################
# quicksort(float* vetor, int low, int high)
####################################################
quicksort:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)

    move $s0, $a0   # vetor
    move $s1, $a1   # low
    move $s2, $a2   # high

    bge $s1, $s2, quick_exit

    # pi = partition(vetor, low, high)
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal partition
    move $t0, $v0   # pi

    # quicksort(vetor, low, pi - 1)
    move $a0, $s0
    move $a1, $s1
    addi $a2, $t0, -1
    jal quicksort

    # quicksort(vetor, pi + 1, high)
    move $a0, $s0
    addi $a1, $t0, 1
    move $a2, $s2
    jal quicksort

quick_exit:
    lw $ra, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    addi $sp, $sp, 24
    jr $ra

####################################################
# partition(float* vetor, int low, int high)
# retorna índice pi em $v0
####################################################
partition:
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)

    move $s0, $a0    # vetor
    move $s1, $a1    # low
    move $s2, $a2    # high

    mul $t0, $s2, 4
    add $t0, $s0, $t0
    l.s $f0, 0($t0)  # pivot = vetor[high]

    addi $s3, $s1, -1   # i = low - 1
    move $t1, $s1       # j = low

partition_loop:
    bge $t1, $s2, partition_end

    mul $t2, $t1, 4
    add $t3, $s0, $t2
    l.s $f2, 0($t3)     # vetor[j]

    c.lt.s $f2, $f0
    bc1f skip_swap

    addi $s3, $s3, 1    # i++
    mul $t4, $s3, 4
    add $t5, $s0, $t4
    l.s $f4, 0($t5)

    s.s $f2, 0($t5)
    s.s $f4, 0($t3)

skip_swap:
    addi $t1, $t1, 1
    j partition_loop

partition_end:
    addi $s3, $s3, 1
    mul $t6, $s3, 4
    add $t7, $s0, $t6
    l.s $f6, 0($t7)

    mul $t8, $s2, 4
    add $t9, $s0, $t8
    l.s $f8, 0($t9)

    s.s $f8, 0($t7)
    s.s $f6, 0($t9)

    move $v0, $s3

    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    addi $sp, $sp, 32
    jr $ra