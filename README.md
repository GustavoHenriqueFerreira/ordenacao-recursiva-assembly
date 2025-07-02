# EP - Ordenação em MIPS Assembly

Este repositório contém a implementação de dois algoritmos de ordenação, Ordenação por Inserção (O(n^2)) e Ordenação Rápida (O(n log n)), em MIPS Assembly. O programa lê um vetor de números de ponto flutuante de um arquivo, ordena-o usando um dos métodos escolhidos e escreve o vetor ordenado de volta no arquivo.

**Importante:** Devido a restrições de uso de instruções simples, os números de ponto flutuante são representados e manipulados como pares de inteiros (parte inteira e parte decimal multiplicada por 1000). Todas as operações com floats são realizadas usando lógica de inteiros.

## Requisitos

*   Simulador MARS (MIPS Assembler and Runtime Simulator)
*   Compilador C (para os protótipos em C)

## Estrutura do Projeto

*   `ep_mips_sorting/`
    *   `README.md`: Este arquivo.
    *   `EP_Relatorio.md`: Documentação detalhada do projeto, incluindo lógica, implementação e análise.
    *   `c_implementations/`
        *   `insertion_sort.c`: Implementação da Ordenação por Inserção em C.
        *   `quicksort.c`: Implementação da Ordenação Rápida em C.
    *   `mips_assembly/`
        *   `ordenacao_por_insercao.asm`: Implementação da Ordenação por Inserção em MIPS Assembly.
        *   `ordenacao_rapida.asm`: Implementação da Ordenação Rápida em MIPS Assembly.
        *   `arquivo_io.asm`: Rotinas de leitura e escrita de arquivos em MIPS.
        *   `ordenar.asm`: Função `ordenar` principal em MIPS.
        *   `principal.asm`: Ponto de entrada principal do programa MIPS.
    *   `test_files/`
        *   `dadosEP2.txt`: Arquivo de entrada de exemplo (fornecido pelo professor).
        *   `saida_ordenada.txt`: Arquivo de saída gerado pelo programa.

## Como Compilar e Executar

Detalhes sobre como compilar os códigos C e executar os códigos MIPS no simulador MARS serão fornecidos no `EP_Relatorio.md`.