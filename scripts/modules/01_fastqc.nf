/*
 * modules/01_fastqc.nf
 * Control de calidad de lecturas FASTQ.
 * Se ejecuta en paralelo para cada muestra.
 */

process FASTQC {

    tag "$sample_id"

    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id), path("*.zip"),  emit: zip
    tuple val(sample_id), path("*.html"), emit: html

    script:
    """
    fastqc \\
        --threads 2 \\
        --quiet \\
        --outdir . \\
        ${r1} ${r2}
    """
}
