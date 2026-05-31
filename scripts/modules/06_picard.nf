/*
 * modules/06_picard.nf
 * Marca duplicados de PCR sin eliminarlos.
 */

process PICARD_MARKDUPLICATES {

    tag "$sample_id"

    container 'quay.io/biocontainers/picard:3.1.1--hdfd78af_0'

    publishDir "${params.outdir}/picard", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id),
          path("${sample_id}_markdup.bam"),
          path("${sample_id}_markdup.bam.bai"), emit: markdup_bam

    tuple val(sample_id),
          path("${sample_id}_markdup_metrics.txt"), emit: metrics

    script:
    def avail_mem = task.memory ? (task.memory.toGiga() * 0.8).intValue() : 4
    """
    picard -Xmx${avail_mem}g MarkDuplicates \\
        INPUT=${bam} \\
        OUTPUT=${sample_id}_markdup.bam \\
        METRICS_FILE=${sample_id}_markdup_metrics.txt \\
        REMOVE_DUPLICATES=false \\
        VALIDATION_STRINGENCY=LENIENT \\
        CREATE_INDEX=true

    mv ${sample_id}_markdup.bai ${sample_id}_markdup.bam.bai || true
    """
}
