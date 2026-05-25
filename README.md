# nextflow_rnaseq

## 1. Requirements
- Descarga de datos de GEO
- Descarga del genoma de referencia

Para descargar directamente los .fastq y que aparezcan en la carpeta data/
1. Instala sra-toolkit y pigz 

```bash
sudo apt install sra-toolkit
sudo apt install pigz
``` 
2. Desde nextflow_rnaseq/

Recuerda dar permiso a los scripts con 

```bash
chmod +x scripts/download_data.sh
chmod +x scripts/prepare_genome.sh
```
Ejecuta los scripts con:

```bash
./scripts/download_data.sh 
./scripts/prepare_genome.sh
```

Esto descarga los fastq y los comprime. El resultado debería ser:

```text
Data/
└── SRR*/  
    ├── SRR*_1.fastq.gz
    ├── SRR*_2.fastq.gz
    └── SRR*.sra
|__ genome/
    └── genome.fa

```

Habría 8 carpetas SRR*/, una por cada muestra

Además descarga el genoma de referencia

### Descarga el genoma de referencia 
```bash
# 1. Ejecutar el script de descarga e indexación
bash scripts/prepare_genome.sh

```
## 2. Configuración del pipeline

El pipeline está construido en Nextflow DSL2 con Docker. 
Se ejecuta con un único comando:

```bash
nextflow run scripts/main.nf -profile docker
```

## 3. Control de calidad — FastQC

FastQC analiza la calidad de las lecturas FASTQ de cada muestra en paralelo.
Los resultados (ficheros `.zip` y `.html`) se integran en el informe MultiQC final.

- Módulo: `scripts/modules/fastqc.nf`
- Imagen Docker: `biocontainers/fastqc:0.12.1--hdfd78af_0`

## 4. Eliminación de adaptadores — Trimmomatic

Trimmomatic elimina adaptadores Illumina y bases de baja calidad de las lecturas paired-end.
Los logs se integran en el informe MultiQC final.

- Módulo: `scripts/modules/trimmomatic.nf`
- Imagen Docker: `biocontainers/trimmomatic:0.39--hdfd78af_2`

## 5. Alineamiento con STAR
