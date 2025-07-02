#include <stdio.h>
#include <stdlib.h>

// Função para imprimir um vetor de números de ponto flutuante
void imprimirVetor(float vetor[], int tamanho) {
    for (int i = 0; i < tamanho; i++) {
        printf("%.2f ", vetor[i]);
    }
    printf("\n");
}

// Ordenação por Inserção (Insertion Sort)
void ordenacaoPorInsercao(float vetor[], int tamanho) {
    int i, j;
    float chave;
    for (i = 1; i < tamanho; i++) {
        chave = vetor[i];
        j = i - 1;

        // Move os elementos de vetor[0..i-1], que são maiores que a chave, para uma posição à frente de sua posição atual
        while (j >= 0 && vetor[j] > chave) {
            vetor[j + 1] = vetor[j];
            j = j - 1;
        }
        vetor[j + 1] = chave;
    }
}

// Exemplo de uso (para testes)
int main() {
    float vetor[] = {3.0, 2.1, 6.7, 8.7, 9.7, 10.7, 4.0, 7.5, 12.5, 15.5};
    int tamanho = sizeof(vetor) / sizeof(vetor[0]);

    printf("Vetor original: ");
    imprimirVetor(vetor, tamanho);

    ordenacaoPorInsercao(vetor, tamanho);

    printf("Vetor ordenado (Ordenação por Inserção): ");
    imprimirVetor(vetor, tamanho);

    return 0;
}