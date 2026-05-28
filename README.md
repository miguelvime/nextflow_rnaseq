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

Esto descarga los fastq y los comprime y descarga el genoma de referencia. El resultado debería ser:

```text
Data/
└── SRR*/  
    ├── SRR*_1.fastq.gz
    ├── SRR*_2.fastq.gz
    └── SRR*.sra
└── genome/
    └── Homo_sapiens.GRCh38.111.gtf
    └── Homo_sapiens.GRCh38.dna.primary_assembly.fa

```

Habría 8 carpetas SRR*/, una por cada muestra y una carpeta genome con el genoma de referencia



## 2. Configuración del pipeline
Tenemos la opción de correrlo con docker o con Singularity (para picasso).

El pipeline está construido en Nextflow DSL2 con Docker. 
Se ejecuta con un único comando:

**opción docker**

```bash
nextflow run scripts/main.nf -profile docker
```
**opción picasso (singularity)**

```bash
nextflow run scripts/main.nf -profile singularity
```
Solo una vez, luego puedo reaunudar la ejecución añadiéndole -resume siempre que no haya borrado la carpeta work o haya forzado la interrupción 

```bash
nextflow run scripts/main.nf -profile docker -resume
```
o

```bash
nextflow run scripts/main.nf -profile singularity -resume
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
    La RAM no da para hacer el paso completo, mientras estamos en fase de testeo he cortado el genoma de referencia. Cuando lo pasemos por Picasso hay que:
     - Quitar las lineas de prepare_genome.sh que recortan los cromosomas
     - Cambiar la ruta de nextflow config para que apunte a los genomas de referencia completos

## 6. Resultados

Los resultados se guardan en `results/`:

results/
├── fastqc/       → informes de calidad de lecturas crudas y trimadas
└── trimmomatic/  → lecturas limpias y logs de trimming
└──star_alignment/ → BAM, logs, tab


## Notas importantes

- Las imágenes Docker usan `quay.io` (no `docker.io`)
- Memoria recomendada: mínimo 8 GB RAM
- Tiempo de ejecución aproximado: 1.5 horas para las 8 muestras

