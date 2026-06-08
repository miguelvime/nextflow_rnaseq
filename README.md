# nextflow_rnaseq

Pipeline RNA-seq reproducible en Nextflow DSL2 para el dataset GSE52778 (8 muestras paired-end).
Procesa desde el control de calidad inicial hasta el análisis exploratorio en R, con contenedores Docker/Singularity.

---

## 1. Requisitos previos

### Datos FASTQ

```bash
sudo apt install sra-toolkit pigz
chmod +x scripts/download_data.sh
./scripts/download_data.sh
```

### Genoma de referencia

```bash
chmod +x scripts/prepare_genome.sh
./scripts/prepare_genome.sh
```

Estructura esperada tras la descarga:

```text
data/
├── SRR*/
│   ├── SRR*_1.fastq.gz
│   └── SRR*_2.fastq.gz
└── genome/
    ├── Homo_sapiens.GRCh38.dna.primary_assembly.fa
    └── Homo_sapiens.GRCh38.111.gtf
```

---

## 2. Ejecución del pipeline

### Local (Docker)

```bash
# Ejecución completa
nextflow run scripts/main.nf -profile docker

# Reanudar una ejecución interrumpida
nextflow run scripts/main.nf -profile docker -resume
```

### HPC Picasso (Singularity + Slurm)

```bash
sbatch scripts/script.sh
```

Para reanudar una ejecución interrumpida en Picasso:
```bash
nextflow run scripts/main.nf -profile picasso -resume
```

---

## 3. Pasos del pipeline

| # | Proceso | Módulo | Descripción |
|---|---------|--------|-------------|
| 1 | FASTQC (raw) | `01_fastqc.nf` | Control de calidad de lecturas crudas |
| 2 | Trimmomatic | `02_trimmomatic.nf` | Eliminación de adaptadores y bases de baja calidad |
| 3 | FASTQC (trim) | `01_fastqc.nf` | Control de calidad post-trimming |
| 4 | STAR_INDEX | `03_star_index.nf` | Generación del índice STAR (una sola vez) |
| 5 | STAR_ALIGN | `04_star_align.nf` | Alineamiento al genoma humano (por muestra) |
| 6 | SAMtools | `05_samtools.nf` | Ordenación, indexado, flagstat e idxstats |
| 7 | Picard MarkDuplicates | `06_picard_markdup.nf` | Marcado de duplicados sin eliminarlos |
| 8 | featureCounts | `07_featurecounts.nf` | Cuantificación por gen (todos los BAMs juntos) |
| 9 | MultiQC | `08_multiqc.nf` | Informe de QC agregado |
| 10 | R exploratorio | `09_rnaseq_r.nf` | Boxplot + PCA con edgeR/ggplot2 |

### 3.1. FASTQC

Analiza la calidad de las lecturas FASTQ de cada muestra en paralelo.
Los `.zip` y `.html` se integran en el informe MultiQC final.

- Módulo: `scripts/modules/01_fastqc.nf`
- Imagen: `quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0`

### 3.2. Trimmomatic

Elimina adaptadores Illumina y bases de baja calidad (paired-end).
Los logs se integran en el informe MultiQC final.

- Módulo: `scripts/modules/02_trimmomatic.nf`
- Imagen: `quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2`

### 3.3. STAR (índice + alineamiento)

Dos procesos separados:
- **STAR_INDEX**: genera el índice una sola vez a partir del FASTA + GTF.
- **STAR_ALIGN**: alinea cada muestra en paralelo usando el índice generado.

- Módulos: `scripts/modules/03_star_index.nf`, `scripts/modules/04_star_align.nf`
- Imagen: `quay.io/biocontainers/star:2.7.11b--h5ca1c30_8`

### 3.4. SAMtools

Ordena el BAM por coordenadas, genera el índice `.bai`, y calcula métricas de alineamiento:

- **sort**: ordenación por coordenadas genómicas
- **index**: creación del `.bai`
- **flagstat**: resumen de reads mapeados, paired, etc.
- **idxstats**: estadísticas por cromosoma

Las salidas `.flagstat.txt` e `.idxstats.txt` van a MultiQC.
El BAM ordenado + índice pasan a Picard MarkDuplicates.

- Módulo: `scripts/modules/05_samtools.nf`
- Imagen: `quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1`

### 3.5. Picard MarkDuplicates

Marca duplicados ópticos y de PCR **sin eliminarlos** (`REMOVE_DUPLICATES=false`).
El BAM resultante mantiene todas las reads originales con la etiqueta `duplicate` en el FLAG.

- **Entrada**: BAM ordenado por coordenadas + índice (de SAMtools)
- **Salida**: BAM con duplicados marcados + índice → pasa a featureCounts
- **Métricas**: tabla `.markdup_metrics.txt` → pasa a MultiQC

- Módulo: `scripts/modules/06_picard_markdup.nf`
- Imagen: `quay.io/biocontainers/picard:3.1.1--hdfd78af_0`
- Memoria JVM: 80% de la RAM asignada al proceso (`-Xmx`)
- Parámetros clave: `--ASSUME_SORT_ORDER coordinate`, `--VALIDATION_STRINGENCY LENIENT`

### 3.6. featureCounts

Cuantifica reads por gen usando todos los BAMs con duplicados marcados como entrada conjunta.
Produce una matriz de cuentas (genes en filas, muestras en columnas) y un resumen de asignación.

- **Entrada**: todos los BAMs de Picard + GTF de anotación
- **Salida**: `featurecounts.txt` (matriz) + `featurecounts.txt.summary` → pasa a MultiQC

- Módulo: `scripts/modules/07_featurecounts.nf`
- Imagen: `quay.io/biocontainers/subread:2.1.1--h577a1d6_0`

### 3.7. MultiQC

Agrega todos los informes de calidad en un único HTML interactivo:
- FastQC (raw + trim)
- Trimmomatic logs
- STAR Log.final.out
- SAMtools flagstat
- featureCounts summary

- Módulo: `scripts/modules/08_multiqc.nf`
- Imagen: `quay.io/biocontainers/multiqc:1.35--pyhdfd78af_1`

### 3.8. R exploratorio

Análisis estadístico con edgeR y ggplot2:
- **Boxplot** de distribución de expresión antes y después de normalizar (TMM)
- **PCA** no supervisado por condición (Dexamethasone vs Untreated)

- Módulo: `scripts/modules/09_rnaseq_r.nf`
- Script R: `scripts/bin/rnaseq_exploratory.R`
- Imagen: `bioconductor/bioconductor_docker:RELEASE_3_18`

---

## 4. Ejecución en Picasso (HPC)

El clúster Picasso (SCBI-UMA) usa **Singularity/Apptainer** en lugar de Docker y **Slurm** como gestor de colas.

### 4.1 Preparación del entorno

```bash
# Cargar módulos necesarios (ver versiones disponibles con: module avail)
module load Apptainer/1.2.5
module load Java/17

# Verificar que nextflow está disponible
nextflow -version
```

### 4.2 Sistema de archivos

| Ruta | Uso |
|---|---|
| `$HOME` | Repo, scripts, resultados finales, caché Singularity (.sif). Persistente. |
| `$FSCRATCH` | Directorio `work/` de Nextflow. I/O rápido. **Se purga tras ~2 meses.** |

### 4.3 Lanzar el pipeline

```bash
# Desde la raíz del repo:
sbatch scripts/script.sh
```

El script `script.sh` solicita recursos mínimos para el controlador de Nextflow (2 CPUs, 8 GB, 48 h).
Cada proceso del pipeline (FastQC, Trimmomatic, STAR_INDEX, STAR_ALIGN×8, SAMtools, Picard, featureCounts, MultiQC, R) se envía como un **trabajo Slurm independiente** gracias al executor configurado en `nextflow.config`.

### 4.4 Reanudar una ejecución interrumpida

```bash
# Editar script.sh y añadir -resume al comando nextflow, o ejecutar directamente:
nextflow run scripts/main.nf -profile picasso -resume
```

### 4.5 Monitorizar

```bash
squeue -u $USER          # ver trabajos en cola
scancel <job_id>         # cancelar un trabajo
cat logs/nf_<job_id>.out # logs del controlador Nextflow
```

---

## 5. Resultados

Los outputs se guardan en `results/`:

```text
results/
├── fastqc/            → informes de calidad (raw + trim)
├── trimmomatic/       → lecturas limpias y logs de trimming
├── star_alignment/    → BAM alineados, logs STAR, SJ tables
├── samtools/          → BAM ordenados, índices, flagstat, idxstats
├── picard_markdup/    → BAM con duplicados marcados, métricas
├── featurecounts/     → matriz de cuentas + summary
├── multiqc/           → multiqc_report.html
└── R_exploratory/     → boxplot_raw.png, boxplot_normalized.png, pca_plot.png
```

---

## 6. Entregables

Según la rúbrica de la actividad, el ZIP final debe contener:

```text
Actividad_Modulo8.zip
├── scripts/                    ← main.nf, nextflow.config, modules/, bin/, assets/
├── memoria_analisis.pdf        ← descripción, parámetros, interpretación
└── resultados/
    └── multiqc_report.html     ← informe de calidad agregado
```

**No incluir** en el ZIP: `data/`, `work/`, `results/` (solo copiar el HTML de MultiQC), archivos FASTQ, BAM, índices, ni datos genómicos.

---

## 7. Notas importantes

- Todas las imágenes Docker usan `quay.io/biocontainers/...` con tag exacto (incluyendo hash de build de Bioconda). Ninguna usa `:latest`.
- Memoria recomendada local: mínimo 8 GB RAM.
- En Picasso: STAR_INDEX requiere 64 GB RAM, STAR_ALIGN 45 GB RAM.
- Tiempo de ejecución aproximado en local: 1.5 horas para las 8 muestras.
- En Picasso: el tiempo total depende de la cola; STAR_INDEX tarda ~30-60 min.
- El `scripts/bin/rnaseq_exploratory.R` se ejecuta dentro del contenedor de Bioconductor; instala automáticamente edgeR, ggplot2, dplyr y tidyr en la primera ejecución.
