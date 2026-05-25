#!/bin/bash
# 1. Crear el directorio donde guardaremos el genoma
mkdir -p data/genome

# 2. Descargar el archivo FASTA (Secuencia del ADN - Primary Assembly)
# Tamaño comprimido: ~880 MB | Descomprimido: ~3.1 GB
wget -P data/genome "https://ftp.ensembl.org/pub/release-111/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"

# 3. Descargar el archivo GTF (Anotación de los genes)
# Tamaño comprimido: ~50 MB | Descomprimido: ~1.2 GB
wget -P data/genome "https://ftp.ensembl.org/pub/release-111/gtf/homo_sapiens/Homo_sapiens.GRCh38.111.gtf.gz"

# 4. Descomprimir ambos archivos (STAR y otras herramientas prefieren el texto plano para indexar)
gunzip data/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz > data/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa
gunzip data/genome/Homo_sapiens.GRCh38.111.gtf.gz > data/genome/Homo_sapiens.GRCh38.111.gtf