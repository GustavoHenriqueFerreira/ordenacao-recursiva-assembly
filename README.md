# EP - Ordenação em MIPS Assembly

O EP contém a implementação de dois algoritmos de ordenação: Ordenação por Inserção - Insertion Sort (O(n^2)) e Ordenação Rápida - Quicksort (O(n log n)) em C para MIPS Assembly. O programa lê um vetor de números de ponto flutuante de um arquivo e usando um dos métodos escolhidos escreve o vetor ordenado de volta no arquivo.

## Requisitos

*   Simulador MARS (MIPS Assembler and Runtime Simulator)
*   Compilador C (para os protótipos em C)

## Estrutura do Projeto

*   `ep_mips_sorting/`
    *   `README.md`: Este arquivo.
    *   `EP_Relatorio.md`: Documentação detalhada do projeto, incluindo lógica, implementação e análise.
    *   `algoritmos_ordenacao/`
        *   `insertion_sort.c`: Implementação da Ordenação por Inserção em C.
        *   `quicksort.c`: Implementação da Ordenação Rápida em C.
    *   `mips_assembly/`
        *   `ordenacao_por_insercao.asm`: Implementação da Ordenação por Inserção em MIPS Assembly.
        *   `ordenacao_rapida.asm`: Implementação da Ordenação Rápida em MIPS Assembly.
        *   `arquivo_io.asm`: Rotinas de leitura e escrita de arquivos em MIPS.
        *   `ordenar.asm`: Função `ordenar` principal em MIPS.
        *   `principal.asm`: Ponto de entrada principal do programa MIPS.
    *   `arquivos_testes/`
        *   `dadosEP2.txt`: Arquivo de entrada de exemplo (fornecido pelo professor).
        *   `saida_ordenada.txt`: Arquivo de saída gerado pelo programa.

## Como Compilar e Executar

Detalhes sobre como compilar os códigos C e executar os códigos MIPS no simulador MARS fornecidos no `EP_Relatorio.md`.