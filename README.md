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
Tenemos la opción de correrlo con docker o con Singularity (si es necesario para picasso).

El pipeline está construido en Nextflow DSL2 con Docker. Si Picasso usara docker y no singularity deberíamos cambiar los recursos reservados para los módulos en @nextflow.config.

Se ejecuta con un único comando:

**opción docker**

```bash
nextflow run scripts/main.nf -profile docker
```
**opción picasso (singularity + slurm)**

```bash
nextflow run scripts/main.nf -profile picasso
```
Solo una vez, luego puedo reaunudar la ejecución añadiéndole -resume siempre que no haya borrado la carpeta work o haya forzado la interrupción 

```bash
nextflow run scripts/main.nf -profile docker -resume
```
o

```bash
nextflow run scripts/main.nf -profile picasso -resume
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

Se utiliza el genoma de referencia completo (GRCh38 primary assembly, ~3.1 GB).
El índice STAR se genera una sola vez y se reutiliza para las 8 muestras en paralelo.
En Picasso se asignan 12 CPUs y 64 GB RAM para la indexación y 45 GB RAM para el alineamiento.

## 8. SAMtools — Ordenación e indexado

SAMtools procesa los BAMs de STAR:
- Ordena por coordenadas genómicas
- Crea el índice `.bai`
- Calcula métricas de alineamiento (`flagstat`) → van a MultiQC

- Módulo: `scripts/modules/05_samtools.nf`
- Imagen Docker: `quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1`

## 6. Ejecución en Picasso (HPC)

El clúster Picasso (SCBI-UMA) usa **Singularity/Apptainer** en lugar de Docker y **Slurm** como gestor de colas.

### 6.1 Preparación del entorno

```bash
# Cargar módulos necesarios (ver versiones disponibles con: module avail)
module load Apptainer/1.2.5
module load Java/17

# Verificar que nextflow está disponible
nextflow -version
```

### 6.2 Sistema de archivos

| Ruta | Uso |
|---|---|
| `$HOME` | Repo, scripts, resultados finales, caché Singularity (.sif). Persistente. |
| `$FSCRATCH` | Directorio `work/` de Nextflow. I/O rápido. **Se purga tras ~2 meses.** |

### 6.3 Lanzar el pipeline

```bash
# Desde la raíz del repo:
sbatch scripts/script.sh
```

El script `script.sh` solicita recursos mínimos para el controlador de Nextflow (2 CPUs, 8 GB, 48 h).
Cada proceso del pipeline (FastQC, Trimmomatic, STAR_INDEX, STAR_ALIGN×8…) se envía como un **trabajo Slurm independiente** gracias al executor configurado en `nextflow.config`.

### 6.4 Reanudar una ejecución interrumpida

```bash
# Editar script.sh y añadir -resume al comando nextflow, o ejecutar directamente:
nextflow run scripts/main.nf -profile picasso -resume
```

### 6.5 Monitorizar

```bash
squeue -u $USER          # ver trabajos en cola
scancel <job_id>         # cancelar un trabajo
cat logs/nf_<job_id>.out # logs del controlador Nextflow
```

## 7. Resultados

Los resultados se guardan en `results/`:

results/
├── fastqc/       → informes de calidad de lecturas crudas y trimadas
└── trimmomatic/  → lecturas limpias y logs de trimming
└──star_alignment/ → BAM, logs, tab


## Notas importantes

- Las imágenes Docker usan `quay.io` (no `docker.io`)
- Memoria recomendada local: mínimo 8 GB RAM
- En Picasso: STAR_INDEX requiere 64 GB RAM, STAR_ALIGN 45 GB RAM
- Tiempo de ejecución aproximado en local: 1.5 horas para las 8 muestras
- En Picasso: el tiempo total depende de la cola; STAR_INDEX tarda ~30-60 min

- Memoria recomendada: mínimo 8 GB RAM
- Tiempo de ejecución aproximado: 1.5 horas para las 8 muestras
