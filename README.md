# nextflow_rnaseq

Pipeline RNA-seq reproducibile en Nextflow DSL2 para el dataset GSE52778 (8 muestras paired-end).
Procesa desde el control de calidad inicial hasta el marcado de duplicados, con la intención de
integrar posteriormente featureCounts, MultiQC y el análisis exploratorio en R.

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

## 2. Ejecución

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

Ver `README.md` en la rama `picasso` para la configuración completa del clúster.

---

## 3. Pasos del pipeline

| # | Proceso | Módulo | Descripción |
|---|---------|--------|-------------|
| 1 | FASTQC (raw) | `01_fastqc.nf` | Control de calidad de lecturas crudas |
| 2 | Trimmomatic | `02_trimmomatic.nf` | Eliminación de adaptadores y bases de baja calidad |
| 3 | FastQC (trim) | `01_fastqc.nf` | Control de calidad post-trimming |
| 4 | STAR_INDEX | `03_star_index.nf` | Generación del índice STAR (una sola vez) |
| 5 | STAR_ALIGN | `04_star_align.nf` | Alineamiento al genoma humano (por muestra) |
| 6 | SAMtools | `05_samtools.nf` | Ordenación, indexado, flagstat e idxstats |
| 7 | Picard MarkDuplicates | `06_picard_markdup.nf` | Marcado de duplicados sin eliminarlos |
| 8 | featureCounts | — | *pendiente* — cuantificación por gen |
| 9 | MultiQC | — | *pendiente* — informe de QC agregado |
| 10 | R exploratorio | — | *pendiente* — boxplot + PCA |

### 3.1. FASTQC

Analiza la calidad de las lecturas FASTQ de cada muestra en paralelo.
Los `.zip` y `.html` se integran en el informe MultiQC final.

- Módulo: `scripts/modules/01_fastqc.nf`
- Imagen: `quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0`

### 3.2. Trimmomatic

Elimina adaptadores Illumina y bases de baja calidad (paired-end).
Los logs del trimming se integran en el informe MultiQC final.

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

---

## 4. Resultados

Los outputs se guardan en `results/`:

```text
results/
├── fastqc/            → informes de calidad (raw + trim)
├── trimmomatic/       → lecturas limpias y logs de trimming
├── star_alignment/    → BAM alineados, logs STAR, SJ tables
├── samtools/          → BAM ordenados, índices, flagstat, idxstats
└── picard_markdup/    → BAM con duplicados marcados, métricas
```

---

## 5. Notas importantes

- Todas las imágenes Docker usan `quay.io/biocontainers/...` con tag exacto (incluyendo hash de build de Bioconda). Ninguna usa `:latest`.
- Memoria recomendada local: mínimo 8 GB RAM.
- En Picasso: STAR_INDEX requiere 64 GB RAM, STAR_ALIGN 45 GB RAM.
- El `nextflow.config` de esta rama está configurado para **testeo local** con un genoma subset. Para ejecución completa, usar las rutas del genoma completo en la rama `main` o `picasso`.
