# Memoria del análisis

## Índice

- [Memoria del análisis](#memoria-del-análisis)
  - [Índice](#índice)
  - [Estructura de archivos](#estructura-de-archivos)
  - [Parámetros utilizados](#parámetros-utilizados)
  - [Descripción del pipeline](#descripción-del-pipeline)
  - [Resultados](#resultados)
  - [Interpretación](#interpretación)
  - [Instrucciones de reproducción](#instrucciones-de-reproducción)
  - [Módulos y parámetros utilizados](#módulos-y-parámetros-utilizados)
    - [Índice de módulos](#índice-de-módulos)
    - [FastQC](#fastqc)
    - [Trimmomatic](#trimmomatic)
    - [STAR\_INDEX](#star_index)
    - [STAR\_ALIGN](#star_align)
    - [SAMtools](#samtools)
    - [Pickard duplicates](#pickard-duplicates)
    - [Featurecounts](#featurecounts)
    - [MultiQC](#multiqc)
    - [R](#r)

Este documento contiene la descripción del pipeline, los parámetros utilizados, resultados, interpretación e instrucciones de reproducción

## Estructura de archivos
Data/
└── SRR*/  
    ├── SRR*_1.fastq.gz
    ├── SRR*_2.fastq.gz
    └── SRR*.sra
└── genome/
    └── genome.fa

scripts/
└── assets
    └──samplesheet.csv
└──modules

## Parámetros utilizados

## Descripción del pipeline

Este pipeline puede  analizar datos de secuenciación de RNA de organismos con un genoma de referencia anotado. 
 - **Input**: la lista de muestras de un samplesheet.csv y los archivos FASTQ resultado de la secuenciación
 - **Output**: una matriz de expresión génica y un informe de control de calidad.

<<<<<<< HEAD
## Resultados

## Interpretación

## Instrucciones de reproducción

## Módulos y parámetros utilizados

### Índice de módulos
    1. FastQC
    2. Trimmomatic
    3. STAR_INDEX
    4. STAR_ALIGN
    5. SAMtools
    6. Pickard duplicates
    7. Featurecounts
    8. MultiQC
    9. R

### FastQC
- **Función:** Control de calidad de lecturas de secuenciación.

### Trimmomatic
- **Función**: Recorte de lecturas según su calidad y longitud. 

*Parámetros*

- **-phred33**: La calidad de los archivos entran en formato phred 33
- **ILUMINACLIP**: Encuentra y elimina los adaptadores de Ilumina
- **LEADING 3**: Elimina aquellas bases del inicio hasta que aparece una de calidad 3
- **TRAILING 3**: elimina aquellas bases del final de la lectura hasta la primera por encima de calidad 3
- **SLIDINGWINDOW:4:15**: Corta la lectura según una ventana de 4 bases cuando la calidad media de las lecturas en la ventana baja de 15.
- **MINLEN:36**: Elimina aquellas lecturas por debajo de 36 basees de longitud.
### STAR_INDEX

### STAR_ALIGN

### SAMtools

### Pickard duplicates

### Featurecounts

### MultiQC

### R



*//nextflow run main.nf -with-dag flowchart.htmlnextflow creo que con eso podemos crear un esquema del pipeline//*