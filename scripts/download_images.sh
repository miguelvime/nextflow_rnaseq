#!/bin/bash
###############################################################################
# download_images.sh — Descarga imágenes Singularity en el login node
#
# Uso:
#   bash scripts/download_images.sh
#
# NOTA: Ejecutar en el nodo de login de Picasso (tiene internet), NO en sbatch.
# Las imágenes se guardan en $HOME/.singularity_cache para que los jobs de
# Slurm las encuentren offline en los nodos de computación.
###############################################################################

set -euo pipefail

# ── 1. Cargar módulos ──────────────────────────────────────────────────────
module load singularity/3.7.2

# ── 2. Configurar caché ──────────────────────────────────────────────────────
export SINGULARITY_CACHEDIR="$HOME/UEM/nextflow_rnaseq/.singularity_cache"
mkdir -p "$SINGULARITY_CACHEDIR"

echo "=== Descargando imágenes Singularity ==="
echo "Destino: $SINGULARITY_CACHEDIR"
echo ""

# ── 3. Lista de imágenes requeridas por el pipeline ─────────────────────────
# Se extraen de los módulos 01-09
IMAGES=(
    "docker://quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"
    "docker://quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2"
    "docker://quay.io/biocontainers/star:2.7.11b--h5ca1c30_8"
    "docker://quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1"
    "docker://quay.io/biocontainers/picard:3.1.1--hdfd78af_0"
    "docker://quay.io/biocontainers/subread:2.1.1--h577a1d6_0"
    "docker://quay.io/biocontainers/multiqc:1.35--pyhdfd78af_1"
    "docker://bioconductor/bioconductor_docker:RELEASE_3_18"
)

# ── 4. Descargar cada imagen (skip si ya existe) ────────────────────────────
for IMG in "${IMAGES[@]}"; do
    # Convertir URI a nombre de archivo válido
    FILENAME=$(echo "$IMG" | sed 's|docker://||g' | tr '/:' '-').img
    CACHE_FILE="$SINGULARITY_CACHEDIR/$FILENAME"

    if [ -f "$CACHE_FILE" ]; then
        echo "[SKIP] Ya existe: $FILENAME"
        continue
    fi

    echo "[DOWNLOAD] $IMG"
    singularity pull --name "$FILENAME" "$IMG"
    echo "[OK] Guardado: $CACHE_FILE"
    echo ""
done

echo "=== Descarga completada ==="
echo "Total imágenes en caché:"
ls -lh "$SINGULARITY_CACHEDIR"
