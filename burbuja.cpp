#include <iostream>


void imprimirArreglo(int arr[], int tamano) {
    for (int i = 0; i < tamano; i++) {
        std::cout << arr[i] << " ";
    }
    std::cout << std::endl;
}

int main() {
    
    int arreglo[5] = {64, 34, 25, 12, 22};
    int n = 5;

    std::cout << "Arreglo Original:" << std::endl;
    imprimirArreglo(arreglo, n);
    std::cout << "--------------------------" << std::endl;
    std::cout << "Iniciando Ordenamiento de Burbuja..." << std::endl;


 
    for (int i = 0; i < n - 1; i++) {
        
        std::cout << "\n--- Pasada " << i + 1 << " ---" << std::endl;

 
        for (int j = 0; j < n - i - 1; j++) {
            
  
            if (arreglo[j] > arreglo[j + 1]) {
                
                int temp = arreglo[j];
                arreglo[j] = arreglo[j + 1];
                arreglo[j + 1] = temp;
            }
   
            imprimirArreglo(arreglo, n);
        }
    }

    std::cout << "\n--------------------------" << std::endl;
    std::cout << "Arreglo Ordenado:" << std::endl;
    imprimirArreglo(arreglo, n);

    return 0;
}