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