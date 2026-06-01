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
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=48:00:00
#SBATCH --output=logs/nf_%j.out
#SBATCH --error=logs/nf_%j.err
#SBATCH --partition=general

set -euo pipefail

# ── 1. Cargar módulos ──────────────────────────────────────────────────────
# Verifica las versiones disponibles con: module avail
module load Apptainer/1.2.5        # Singularity/Apptainer para contenedores
module load Java/17                # Nextflow requiere Java >= 11
# Si nextflow no está como módulo, asegúrate de que ~/bin/nextflow está en PATH

# ── 2. Caché de imágenes Singularity (.sif) ────────────────────────────────
# Las imágenes Docker se convierten a .sif en el primer uso.
# Guardar en $HOME para que persista entre ejecuciones (FSCRATCH se purga).
export NXF_SINGULARITY_CACHEDIR="$HOME/.singularity_cache"
export SINGULARITY_CACHEDIR="$HOME/.singularity_cache"
mkdir -p "$HOME/.singularity_cache"

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
