#!/bin/bash
# ====================================================
# Script para compilar programas RISC-V en Linux
# Compila burbuja.cpp y SNAKEfinal.s
# Genera archivos .elf y .txt con código máquina
# ====================================================

TOOLS="/mnt/vol_NFS_rh003/Est_Digitales_2S_2025/materiales/tools_riscv/bin"

echo "=== Compilando burbuja.cpp ==="

$TOOLS/riscv32-unknown-elf-g++ -march=rv32im -mabi=ilp32 -o burbuja.elf burbuja.cpp

echo "=== Generando burbuja_hex.txt ==="
$TOOLS/riscv32-unknown-elf-objdump -d burbuja.elf > burbuja_hex.txt

echo "? burbuja.cpp compilado y convertido a burbuja_hex.txt"
echo ""

# ============================================================

echo "=== Compilando SNAKEfinal.s + constantes.s ==="

$TOOLS/riscv32-unknown-elf-as -march=rv32im -mabi=ilp32 -o snake.o MainSnake.s
$TOOLS/riscv32-unknown-elf-as -march=rv32im -mabi=ilp32 -o const.o constantes.s

$TOOLS/riscv32-unknown-elf-ld -o snake.elf snake.o const.o

echo "=== Generando snake_hex.txt ==="
$TOOLS/riscv32-unknown-elf-objdump -d snake.elf > snake_hex.txt

echo "? SNAKEfinal.s ensamblado y convertido a snake_hex.txt"
echo ""

# ============================================================

echo "=== Archivos generados ==="
ls -lh burbuja* snake*
echo ""
echo "=== PROCESO TERMINADO ==="

