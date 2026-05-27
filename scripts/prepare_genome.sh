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

# 5 . Cogemos solo cromosoma 19-22 para test, esto lo debemos borrar cuando probemos en Picasso
awk -F'\t' '$1 ~ /^(chr)?(19|20|21|22)$/ || $0 ~ /^#/' data/genome/Homo_sapiens.GRCh38.111.gtf > data/genome/GRCh38_subset.gtf
awk '/^>/{if($1 ~ /^>(chr)?(19|20|21|22)$/) flag=1; else flag=0} flag' data/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa > data/genome/GRCh38_subset.fa