# principal.asm
# Ponto de entrada principal do programa MIPS para o EP de Ordenação.
# Orquestra a leitura do arquivo, chamada da função ordenar e escrita do resultado.
# Utiliza a representação de floats como pares de inteiros.

.data
nome_arquivo_entrada: .asciiz "dadosEP2.txt" # Nome do arquivo de entrada (alterado para o arquivo fornecido)
nome_arquivo_saida: .asciiz "saida_ordenada.txt" # Nome do arquivo de saída

# Buffer para armazenar os floats lidos do arquivo
# Cada float ocupa 2 words (parte inteira, parte decimal).
# Assumimos um tamanho máximo razoável para o vetor, por exemplo, 100 elementos float.
# 100 floats * 2 words/float * 4 bytes/word = 800 bytes
buffer_vetor_float: .space 800

.text
.globl main

main:
    # --- 1. Ler o vetor do arquivo de entrada ---
    # Prepara argumentos para lerFloatsDoArquivo(nome_arquivo, ponteiro_buffer, max_elementos)
    la $a0, nome_arquivo_entrada # Carrega o endereço do nome do arquivo de entrada
    la $a1, buffer_vetor_float   # Carrega o endereço do buffer para armazenar os floats
    addi $a2, $zero, 100         # max_elementos (capacidade do buffer em número de floats)
    jal lerFloatsDoArquivo       # Chama a função de leitura
    add $s0, $v0, $zero          # $s0 = tamanho (número de elementos float lidos)

    # --- 2. Chamar a função ordenar ---
    # Prepara argumentos para ordenar(tamanho, tipo, vetor)
    add $a0, $s0, $zero          # tamanho (número de floats)
    addi $a1, $zero, 0           # tipo = 0 (Ordenação por Inserção). Mudar para 1 para Ordenação Rápida.
    la $a2, buffer_vetor_float   # vetor (ponteiro para o vetor de pares de inteiros)
    jal ordenar                  # Chama a função de ordenação
    add $s1, $v0, $zero          # $s1 = ponteiro para o vetor ordenado (será o mesmo buffer_vetor_float)

    # --- 3. Escrever o vetor ordenado no arquivo de saída ---
    # Prepara argumentos para escreverFloatsNoArquivo(nome_arquivo, ponteiro_buffer, num_elementos)
    la $a0, nome_arquivo_saida   # Carrega o endereço do nome do arquivo de saída
    add $a1, $s1, $zero          # ponteiro_buffer (vetor ordenado)
    add $a2, $s0, $zero          # num_elementos (tamanho)
    jal escreverFloatsNoArquivo  # Chama a função de escrita

    # --- 4. Encerrar o programa ---
    addi $v0, $zero, 10          # código de syscall para sair
    syscall

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

# arquivo_io.asm
# Rotinas para leitura e escrita de números de ponto flutuante em arquivos
# Implementado usando apenas instruções de inteiro e lógica manual para floats.
# Cada float é armazenado como dois inteiros: [parte_inteira, parte_decimal_multiplicada_por_1000]
# Ex: 3.14 -> 3 e 140
# Ex: 2.1 -> 2 e 100
# Ex: 12.5 -> 12 e 500
# Utiliza syscalls do MARS.

.data
_buffer_nome_arquivo: .space 256 # Buffer para o nome do arquivo
_buffer_leitura: .space 4       # Buffer para ler um byte/char por vez
_nova_linha: .asciiz "\n"       # Caractere de nova linha
_espaco: .asciiz " "         # Caractere de espaço
_msg_erro_leitura: .asciiz "Erro ao ler o arquivo!\n"
_msg_erro_escrita: .asciiz "Erro ao escrever no arquivo!\n"
_buffer_conversao_int_str: .space 12 # Buffer para converter inteiro para string (ex: "-2147483648")

.text
.globl lerFloatsDoArquivo
.globl escreverFloatsNoArquivo
.globl converterInteiroParaString

# --- Função lerFloatsDoArquivo(char* nome_arquivo, int* ponteiro_buffer, int max_elementos) ---
# Lê números float (como strings) de um arquivo, converte para representação de inteiros
# e os armazena em um buffer. Cada float ocupa 2 words (parte inteira, parte decimal).
# Retorna o número de elementos lidos (pares de inteiros) em $v0.
# $a0: endereço do nome do arquivo (nome_arquivo)
# $a1: endereço do buffer para armazenar os floats (ponteiro_buffer - agora int*)
# $a2: número máximo de elementos que o buffer pode conter (max_elementos)
# $s0: descritor_arquivo (fd)
# $s1: caractere_atual (byte lido)
# $s2: valor_inteiro_atual (parte inteira do float)
# $s3: valor_decimal_atual (parte decimal do float)
# $s4: num_elementos_lidos (contagem de floats lidos)
# $s5: eh_negativo (flag para números negativos)
# $s6: eh_decimal (flag para parte decimal)
# $s7: ponteiro_buffer (salvo)
# $t0-$t9: temporários

lerFloatsDoArquivo:
    # Salva registradores na pilha
    addi $sp, $sp, -40
    sw $ra, 36($sp)
    sw $s0, 32($sp)
    sw $s1, 28($sp)
    sw $s2, 24($sp)
    sw $s3, 20($sp)
    sw $s4, 16($sp)
    sw $s5, 12($sp)
    sw $s6, 8($sp)
    sw $s7, 4($sp)

    add $s7, $a1, $zero # Salva ponteiro_buffer em $s7
    add $s4, $zero, $zero # num_elementos_lidos = 0

    # Abrir arquivo para leitura (syscall 13)
    addi $v0, $zero, 13 # syscall para abrir arquivo
    add $a1, $zero, $zero # flags (0 para somente leitura)
    add $a2, $zero, $zero # modo (não usado para leitura)
    syscall
    add $s0, $v0, $zero # Salva descritor_arquivo em $s0

    slt $t0, $s0, $zero # t0 = 1 se s0 < 0
    bne $t0, $zero, erro_leitura # Se fd < 0, erro ao abrir

    # Laço para ler caracteres e construir floats
laco_leitura:
    # Verifica se atingiu o max_elementos
    sll $t0, $s4, 1     # num_elementos_lidos * 2 (pois cada float ocupa 2 words)
    slt $t1, $a2, $t0   # t1 = 1 se max_elementos < (num_elementos_lidos * 2)
    bne $t1, $zero, fim_laco_leitura_sucesso

    # Inicializa variáveis para o float atual
    add $s2, $zero, $zero # valor_inteiro_atual = 0
    add $s3, $zero, $zero # valor_decimal_atual = 0
    add $s5, $zero, $zero # eh_negativo = 0
    add $s6, $zero, $zero # eh_decimal = 0

    # Pula espaços e novas linhas antes de um número
pular_espacos_em_branco:
    addi $v0, $zero, 14 # syscall para ler do arquivo
    add $a0, $s0, $zero # descritor_arquivo
    la $a1, _buffer_leitura # endereço do buffer para ler
    addi $a2, $zero, 1  # número de caracteres a ler
    syscall
    slt $t0, $v0, $zero # t0 = 1 se v0 < 0
    bne $t0, $zero, erro_leitura # Erro de leitura
    beq $v0, $zero, fim_laco_leitura_sucesso # EOF, termina com sucesso

    lb $s1, _buffer_leitura # Carrega o byte lido em $s1

    # Verifica se é espaço ou nova linha
    addi $t0, $zero, 32 # ASCII para espaço ' '
    beq $s1, $t0, pular_espacos_em_branco
    addi $t0, $zero, 10 # ASCII para nova linha '\n'
    beq $s1, $t0, pular_espacos_em_branco

    # Verifica sinal negativo
    addi $t0, $zero, 45 # ASCII para menos '-'
    beq $s1, $t0, tratar_negativo

    # Processa dígitos e ponto decimal
processar_digito_leitura:
    addi $t0, $zero, 46 # ASCII para ponto '.'
    beq $s1, $t0, tratar_ponto_decimal

    # Converte char para int
    addi $t0, $s1, -48  # char_para_int (ASCII '0' é 48)

    # Se estiver na parte decimal, constrói a parte decimal
    bne $s6, $zero, construir_parte_decimal

    # Se não for decimal, constrói a parte inteira
    mul $s2, $s2, 10    # valor_inteiro_atual = valor_inteiro_atual * 10
    add $s2, $s2, $t0   # valor_inteiro_atual = valor_inteiro_atual + digito
    j ler_proximo_caractere

construir_parte_decimal:
    mul $s3, $s3, 10    # valor_decimal_atual = valor_decimal_atual * 10
    add $s3, $s3, $t0   # valor_decimal_atual = valor_decimal_atual + digito
    j ler_proximo_caractere

tratar_negativo:
    addi $s5, $zero, 1  # eh_negativo = 1
    j ler_proximo_caractere

tratar_ponto_decimal:
    addi $s6, $zero, 1  # eh_decimal = 1
    j ler_proximo_caractere

ler_proximo_caractere:
    addi $v0, $zero, 14 # syscall para ler do arquivo
    add $a0, $s0, $zero # descritor_arquivo
    la $a1, _buffer_leitura # endereço do buffer para ler
    addi $a2, $zero, 1  # número de caracteres a ler
    syscall
    slt $t0, $v0, $zero # t0 = 1 se v0 < 0
    bne $t0, $zero, erro_leitura # Erro de leitura
    beq $v0, $zero, fim_do_numero # EOF, trata o número atual

    lb $s1, _buffer_leitura # Carrega o byte lido em $s1

    # Verifica se é dígito ou ponto decimal
    addi $t0, $zero, 48 # ASCII para '0'
    slt $t1, $s1, $t0   # t1 = 1 se s1 < '0'
    bne $t1, $zero, verificar_ponto_ou_fim # Se não for dígito, verifica se é ponto ou termina
    addi $t0, $zero, 57 # ASCII para '9'
    slt $t1, $t0, $s1   # t1 = 1 se '9' < s1
    bne $t1, $zero, verificar_ponto_ou_fim # Se não for dígito, verifica se é ponto ou termina
    j processar_digito_leitura     # É um dígito, continua processando

verificar_ponto_ou_fim:
    addi $t0, $zero, 46 # ASCII para '.'
    beq $s1, $t0, processar_digito_leitura # É ponto, continua processando
    j fim_do_numero     # Não é dígito nem ponto, termina o número

fim_do_numero:
    # Aplica o sinal negativo, se houver
    bne $s5, $zero, aplicar_negativo
    j armazenar_float_inteiros

aplicar_negativo:
    sub $s2, $zero, $s2 # Nega a parte inteira
    sub $s3, $zero, $s3 # Nega a parte decimal

armazenar_float_inteiros:
    # Armazena a parte inteira no buffer
    sll $t0, $s4, 2     # deslocamento = num_elementos_lidos * 4
    add $t1, $s7, $t0   # endereco = ponteiro_buffer + deslocamento
    sw $s2, 0($t1)      # Armazena parte inteira

    # Armazena a parte decimal no buffer (próxima word)
    addi $t0, $t0, 4    # deslocamento para a próxima word
    add $t1, $s7, $t0   # endereco = ponteiro_buffer + deslocamento
    sw $s3, 0($t1)      # Armazena parte decimal

    addi $s4, $s4, 1    # num_elementos_lidos++

    # Se o caractere que terminou o número não foi EOF, volta para pular espaços
    beq $v0, $zero, fim_laco_leitura_sucesso # Se foi EOF, termina
    j pular_espacos_em_branco   # Volta para ler o próximo número

erro_leitura:
    addi $v0, $zero, 4  # syscall para imprimir string
    la $a0, _msg_erro_leitura
    syscall
    addi $v0, $zero, 17 # syscall para sair com código de erro
    addi $a0, $zero, 1  # código de erro 1
    syscall

fim_laco_leitura_sucesso:
    # Fechar arquivo (syscall 16)
    addi $v0, $zero, 16 # syscall para fechar arquivo
    add $a0, $s0, $zero # descritor_arquivo
    syscall

    add $v0, $s4, $zero # Retorna o número de elementos lidos

    # Restaura registradores da pilha
    lw $ra, 36($sp)
    lw $s0, 32($sp)
    lw $s1, 28($sp)
    lw $s2, 24($sp)
    lw $s3, 20($sp)
    lw $s4, 16($sp)
    lw $s5, 12($sp)
    lw $s6, 8($sp)
    lw $s7, 4($sp)
    addi $sp, $sp, 40
    jr $ra


# --- Função escreverFloatsNoArquivo(char* nome_arquivo, int* ponteiro_buffer, int num_elementos) ---
# Escreve números float (representados como pares de inteiros) de um buffer para um arquivo.
# $a0: endereço do nome do arquivo (nome_arquivo)
# $a1: endereço do buffer de floats (ponteiro_buffer - agora int*)
# $a2: número de elementos a serem escritos (num_elementos)
# $s0: descritor_arquivo (fd)
# $s1: indice_atual
# $s2: ponteiro_buffer (salvo)
# $s3: num_elementos (salvo)
# $s4: parte_inteira_atual
# $s5: parte_decimal_atual

escreverFloatsNoArquivo:
    # Salva registradores na pilha
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)

    add $s2, $a1, $zero # Salva ponteiro_buffer em $s2
    add $s3, $a2, $zero # Salva num_elementos em $s3
    add $s1, $zero, $zero # indice_atual = 0

    # Abrir arquivo para escrita (syscall 13, flags 1 para escrita, truncar)
    addi $v0, $zero, 13 # syscall para abrir arquivo
    add $a1, $zero, 1  # flags (1 para escrita, criar, truncar)
    addi $a2, $zero, 0x1FF # modo (0x1FF = 777 octal, rwx para todos)
    syscall
    add $s0, $v0, $zero # Salva descritor_arquivo em $s0

    slt $t0, $s0, $zero # t0 = 1 se s0 < 0
    bne $t0, $zero, erro_escrita # Se fd < 0, erro ao abrir

laco_escrita:
    slt $t0, $s3, $s1   # t0 = 1 se num_elementos < indice_atual (indice_atual >= num_elementos)
    bne $t0, $zero, fim_laco_escrita_sucesso # se indice_atual >= num_elementos, vai para o fim

    # Carrega a parte inteira e decimal do float atual
    sll $t0, $s1, 3     # deslocamento = indice_atual * 8 (2 words por float)
    add $t1, $s2, $t0   # endereco = ponteiro_buffer + deslocamento
    lw $s4, 0($t1)      # Carrega parte inteira
    lw $s5, 4($t1)      # Carrega parte decimal

    # Converte parte inteira para string e escreve
    add $a0, $s4, $zero # Argumento para converterInteiroParaString
    la $a1, _buffer_conversao_int_str # Buffer para a string
    jal converterInteiroParaString

    addi $v0, $zero, 15 # syscall para escrever no arquivo
    add $a0, $s0, $zero # descritor_arquivo
    la $a1, _buffer_conversao_int_str # String do número
    add $a2, $v0, $zero # Tamanho da string (retornado por converterInteiroParaString)
    syscall

    # Escreve o ponto decimal se houver parte decimal
    bne $s5, $zero, escrever_ponto_decimal
    j escrever_espaco_apos_numero

escrever_ponto_decimal:
    addi $v0, $zero, 15 # syscall para escrever no arquivo
    add $a0, $s0, $zero # descritor_arquivo
    la $a1, _buffer_leitura # Reutiliza buffer para '.'
    addi $t0, $zero, 46 # ASCII para '.'
    sb $t0, _buffer_leitura # Armazena '.' no buffer
    addi $a2, $zero, 1  # Tamanho 1
    syscall

    # Converte parte decimal para string e escreve
    add $a0, $s5, $zero # Argumento para converterInteiroParaString
    la $a1, _buffer_conversao_int_str # Buffer para a string
    jal converterInteiroParaString

    addi $v0, $zero, 15 # syscall para escrever no arquivo
    add $a0, $s0, $zero # descritor_arquivo
    la $a1, _buffer_conversao_int_str # String do número
    add $a2, $v0, $zero # Tamanho da string
    syscall

escrever_espaco_apos_numero:
    # Escreve um espaço
    addi $v0, $zero, 15 # syscall para escrever no arquivo
    add $a0, $s0, $zero # descritor_arquivo
    la $a1, _espaco
    addi $a2, $zero, 1  # tamanho da string (1 byte para espaço)
    syscall

    addi $s1, $s1, 1    # indice_atual++
    j laco_escrita

erro_escrita:
    addi $v0, $zero, 4  # syscall para imprimir string
    la $a0, _msg_erro_escrita
    syscall
    addi $v0, $zero, 17 # syscall para sair com código de erro
    addi $a0, $zero, 2  # código de erro 2
    syscall

fim_laco_escrita_sucesso:
    # Escreve uma nova linha no final (opcional, para formatação)
    addi $v0, $zero, 15
    add $a0, $s0, $zero
    la $a1, _nova_linha
    addi $a2, $zero, 1
    syscall

    # Fechar arquivo (syscall 16)
    addi $v0, $zero, 16 # syscall para fechar arquivo
    add $a0, $s0, $zero # descritor_arquivo
    syscall

    # Restaura registradores da pilha
    lw $ra, 24($sp)
    lw $s0, 20($sp)
    lw $s1, 16($sp)
    lw $s2, 12($sp)
    lw $s3, 8($sp)
    lw $s4, 4($sp)
    lw $s5, 0($sp)
    addi $sp, $sp, 28
    jr $ra


# --- Função converterInteiroParaString(int valor, char* buffer_str) ---
# Converte um inteiro para sua representação em string (ASCII).
# Retorna o tamanho da string em $v0.
# $a0: valor inteiro a ser convertido
# $a1: buffer para armazenar a string resultante
# $t0: valor_temp
# $t1: contador_digitos
# $t2: eh_negativo_flag
# $t3: ponteiro_atual_buffer
# $t4: digito_char
# $t5: resto

converterInteiroParaString:
    # Salva $ra na pilha
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    add $t0, $a0, $zero # valor_temp = valor
    add $t1, $zero, $zero # contador_digitos = 0
    add $t2, $zero, $zero # eh_negativo_flag = 0
    add $t3, $a1, $zero # ponteiro_atual_buffer = buffer_str

    # Trata o caso de valor ser 0
    beq $t0, $zero, trata_zero

    # Trata números negativos
    slt $t4, $t0, $zero # t4 = 1 se valor < 0
    beq $t4, $zero, nao_negativo
    addi $t2, $zero, 1 # eh_negativo_flag = 1
    sub $t0, $zero, $t0 # valor_temp = -valor
    sb $t0, 0($t3)      # Armazena '-' no início do buffer
    addi $t3, $t3, 1    # Avança o ponteiro do buffer
    addi $t1, $t1, 1    # Incrementa contador de dígitos (para o sinal)

nao_negativo:
    # Converte o número para string, armazenando os dígitos em ordem inversa
    # (do final para o início do buffer, depois inverte)
    add $t6, $a1, $zero # Salva o início do buffer para a inversão
    bne $t2, $zero, pula_sinal_na_inversao # Se for negativo, o primeiro char é o sinal
    j inicio_conversao_digitos

pula_sinal_na_inversao:
    addi $t6, $t6, 1 # Ajusta o início para a inversão se tiver sinal

inicio_conversao_digitos:
    add $t5, $zero, $zero # resto = 0
    addi $t7, $zero, 10 # Divisor 10

    # Loop para extrair dígitos
    laco_extrair_digitos:
        div $t0, $t7    # $t0 / 10
        mfhi $t5        # resto = $t0 % 10
        mflo $t0        # $t0 = $t0 / 10

        addi $t4, $t5, 48 # digito_char = resto + '0'
        sb $t4, 0($t3)    # Armazena o dígito no buffer
        addi $t3, $t3, 1  # Avança o ponteiro do buffer
        addi $t1, $t1, 1  # Incrementa contador de dígitos

        bne $t0, $zero, laco_extrair_digitos # Continua se valor_temp > 0

    # Adiciona terminador nulo
    sb $zero, 0($t3)

    # Inverte a string de dígitos (excluindo o sinal, se houver)
    add $t4, $t3, -1 # Ponteiro para o último dígito (antes do null terminator)

inicio_inversao:
    slt $t5, $t4, $t6 # t5 = 1 se t4 < t6 (ponteiro_final < ponteiro_inicial)
    bne $t5, $zero, fim_inversao

    lb $s0, 0($t6) # Carrega char do início
    lb $s1, 0($t4) # Carrega char do final

    sb $s1, 0($t6) # Escreve char do final no início
    sb $s0, 0($t4) # Escreve char do início no final

    addi $t6, $t6, 1 # Avança ponteiro do início
    addi $t4, $t4, -1 # Retrocede ponteiro do final
    j inicio_inversao

fim_inversao:
    add $v0, $t1, $zero # Retorna o tamanho da string

    # Restaura $ra da pilha
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

trata_zero:
    addi $t4, $zero, 48 # '0'
    sb $t4, 0($t3)      # Armazena '0'
    addi $t3, $t3, 1    # Avança o ponteiro do buffer
    sb $zero, 0($t3)    # Adiciona terminador nulo
    addi $v0, $zero, 1  # Retorna tamanho 1

    # Restaura $ra da pilha
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra