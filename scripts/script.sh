#!/bin/bash
###############################################################################
# script.sh — Lanzador SBATCH para el pipeline RNA-seq en Picasso (SCBI-UMA)
#
# Uso:
#   sbatch scripts/script.sh
#
# Este trabajo Slurm ejecuta el controlador de Nextflow. Cada proceso del
# pipeline (FastQC, Trimmomatic, STAR_INDEX, STAR_ALIGN×8, etc.) se envía
# como un trabajo Slurm independiente gracias al executor configurado en
# nextflow.config (profile picasso).
###############################################################################

#SBATCH --job-name=rnaseq_nf
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=logs/nf_%j.out
#SBATCH --error=logs/nf_%j.err
#SBATCH --partition=general

set -euo pipefail

# ── 1. Cargar módulos ──────────────────────────────────────────────────────
# Verifica las versiones disponibles con: module avail
module load singularity/3.7.2      # Singularity/Apptainer para contenedores
module load nextflow/25.10.4       # Pipeline orchestrator
# Java se incluye automáticamente con el módulo nextflow/25.10.4

# ── Verificación de entorno ───────────────────────────────────────────────
command -v nextflow >/dev/null 2>&1 || { echo "ERROR: nextflow no está disponible"; exit 1; }
command -v singularity >/dev/null 2>&1 || { echo "ERROR: singularity no está disponible"; exit 1; }

# ── Verificar que $FSCRATCH está definido ───────────────────────────────────
if [ -z "$FSCRATCH" ]; then
    echo "WARNING: \$FSCRATCH no está definido. Usando \$HOME para NXF_WORK."
    export FSCRATCH="$HOME"
fi

# ── 2. Caché de imágenes Singularity (.sif) ────────────────────────────────
# Las imágenes Docker se convierten a .sif en el primer uso.
# Guardar en $HOME para que persista entre ejecuciones (FSCRATCH se purga).
# IMPORTANTE: Descargar primero las imágenes en el login node con:
#   bash scripts/download_images.sh
export NXF_OFFLINE=true
export NXF_SINGULARITY_CACHEDIR="$HOME/UEM/nextflow_rnaseq/.singularity_cache"
export SINGULARITY_CACHEDIR="$HOME/UEM/nextflow_rnaseq/.singularity_cache"
mkdir -p "$NXF_SINGULARITY_CACHEDIR"

# ── Verificar que las imágenes existen (opcional pero recomendado) ───────────
# Si falta alguna imagen, el job fallará en el nodo de computación.
# El script download_images.sh debe ejecutarse una sola vez en el login node.

# ── 3. Directorio de trabajo de Nextflow (en FSCRATCH, I/O rápido) ─────────
export NXF_WORK="$FSCRATCH/nextflow_rnaseq_work"
mkdir -p "$NXF_WORK"

# ── 4. Directorio de logs (en $HOME, persiste tras purga de FSCRATCH) ──────
mkdir -p logs

# ── 5. Ejecutar pipeline ───────────────────────────────────────────────────
# Para forzar una ejecución limpia, elimina la flag -resume.
# Para reanudar una ejecución interrumpida, mantén -resume.
echo "=== Iniciando pipeline RNA-seq GSE52778 ==="
echo "NXF_WORK=$NXF_WORK"
echo "NXF_SINGULARITY_CACHEDIR=$NXF_SINGULARITY_CACHEDIR"
echo "Fecha: $(date)"

nextflow run scripts/main.nf -profile picasso -resume

echo "=== Pipeline completado ==="
echo "Fecha: $(date)"
