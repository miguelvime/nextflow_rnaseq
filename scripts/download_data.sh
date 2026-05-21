#!/bin/bash
# Script para descargar y procesar archivos SRA listados en SRR_Acc_List.txt

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
INPUT_FILE="$DATA_DIR/SRR_Acc_List.txt"

mkdir -p "$DATA_DIR"

while read -r SRR; do
    if [ -n "$SRR" ]; then
        echo "Procesando $SRR..."
        prefetch --output-directory "$DATA_DIR" "$SRR"
        if [ $? -ne 0 ]; then
            echo "Error: prefetch falló para $SRR. Saltando al siguiente."
            continue
        fi

        fasterq-dump --split-files -e 4 -O "$DATA_DIR/$SRR" "$DATA_DIR/$SRR/$SRR.sra"
        pigz "$DATA_DIR/$SRR"/*.fastq 
        echo "$SRR completado."
    fi
done < "$INPUT_FILE"