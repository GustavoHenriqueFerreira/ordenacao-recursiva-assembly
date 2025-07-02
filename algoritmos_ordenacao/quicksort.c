#include <stdio.h>
#include <stdlib.h>

// Função para trocar dois elementos
void trocar(float* a, float* b) {
    float temp = *a;
    *a = *b;
    *b = temp;
}

// Função toma o último elemento como pivo, coloca o pivo em sua posição correta no vetor ordenado, 
// coloca todos os elementos menores (que o pivo) à esquerda do pivo e todos os elementos maiores à direita do pivo.
int particionar(float vetor[], int baixo, int alto) {
    float pivo = vetor[alto]; // pivo
    int i = (baixo - 1); // Indice do menor elemento

    for (int j = baixo; j <= alto - 1; j++) {
        // Se o elemento atual for menor que o pivo
        if (vetor[j] < pivo) {
            i++; // incrementa o indice do menor elemento
            trocar(&vetor[i], &vetor[j]);
        }
    }
    trocar(&vetor[i + 1], &vetor[alto]);
    return (i + 1);
}

// Ordenação Rápida (Quicksort)
void ordenacaoRapida(float vetor[], int baixo, int alto) {
    if (baixo < alto) {
        // indice_pivo é o indice de particionamento, vetor[indice_pivo] está agora no lugar certo
        int indice_pivo = particionar(vetor, baixo, alto);

        // Ordena recursivamente os elementos antes e depois da partição
        ordenacaoRapida(vetor, baixo, indice_pivo - 1);
        ordenacaoRapida(vetor, indice_pivo + 1, alto);
    }
}

// Exemplo de uso (para testes)
int main() {
    float vetor[] = {3.0, 2.1, 6.7, 8.7, 9.7, 10.7, 4.0, 7.5, 12.5, 15.5};
    int tamanho = sizeof(vetor) / sizeof(vetor[0]);

    printf("Vetor original: ");
    for (int i = 0; i < tamanho; i++) {
        printf("%.2f ", vetor[i]);
    }
    printf("\n");

    ordenacaoRapida(vetor, 0, tamanho - 1);

    printf("Vetor ordenado (Ordenação Rápida): ");
    for (int i = 0; i < tamanho; i++) {
        printf("%.2f ", vetor[i]);
    }
    printf("\n");

    return 0;
}