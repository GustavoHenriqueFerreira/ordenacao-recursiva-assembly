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