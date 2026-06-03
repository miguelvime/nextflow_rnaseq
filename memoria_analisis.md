# Memoria del análisis

## Índice

- [Descripción del pipeline](#descripción-del-pipeline)
- [Parámetros utilizados](#parámetros-utilizados)
- [Resultados](#resultados)
- [Interpretación](#interpretación)
- [Instrucciones de reproducción](#instrucciones-de-reproducción)

Este documento contiene la descripción del pipeline, los parámetros utilizados, resultados, interpretación e instrucciones de reproducción

## Descripción del pipeline

Este pipeline puede  analizar datos de secuenciación de RNA de organismos con un genoma de referencia anotado. 
 - **Input**: la lista de muestras de un samplesheet.csv y los archivos FASTQ resultado de la secuenciación
 - **Output**: una matriz de expresión génica y un informe de control de calidad.


*//nextflow run main.nf -with-dag flowchart.htmlnextflow creo que con eso podemos crear un esquema del pipeline//*