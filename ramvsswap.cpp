#define _GNU_SOURCE
#include <iostream>
#include <vector>
#include <chrono>
#include <cstdlib>
#include <unistd.h>
#include <sys/mman.h>

constexpr size_t SIZE = 1000 * 1024 * 1024; // 1.5GB to exceed typical RAM

void access_memory(std::vector<int>& data) {
    volatile int sum = 0;
    for (size_t i = 0; i < data.size(); i += 4096 / sizeof(int)) {
        sum += data[i]; // Touch each page to force it into RAM or swap
    }
}

int main() {
    std::cout << "Allocating large memory block in RAM..." << std::endl;
    std::vector<int> ram_data(SIZE / sizeof(int), 1);
    mlock(ram_data.data(), ram_data.size() * sizeof(int)); // Lock to keep in RAM
    
    std::cout << "Touching RAM memory to load into RAM..." << std::endl;
    access_memory(ram_data);

    std::cout << "Measuring RAM access time..." << std::endl;
    auto start = std::chrono::high_resolution_clock::now();
    access_memory(ram_data);
    auto end = std::chrono::high_resolution_clock::now();
    std::cout << "RAM access time: "
              << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count()
              << " ms" << std::endl;

    munlock(ram_data.data(), ram_data.size() * sizeof(int)); // Allow swapping
    std::cout << "Sleeping to allow swap out..." << std::endl;
    sleep(10);

    std::cout << "Allocating large memory block in swap..." << std::endl;
    std::vector<int> swap_data(SIZE / sizeof(int), 2);
    
    std::cout << "Measuring swap access time..." << std::endl;
    start = std::chrono::high_resolution_clock::now();
    access_memory(swap_data);
    end = std::chrono::high_resolution_clock::now();
    std::cout << "Swap access time: "
              << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count()
              << " ms" << std::endl;
    
    return 0;
}