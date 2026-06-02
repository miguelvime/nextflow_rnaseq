/*
 * modules/06_picard_markdup.nf
 * Marca duplicados ópticos y de PCR sin eliminarlos (REMOVE_DUPLICATES=false).
 * La tabla de métricas va a MultiQC. El BAM marcado va a featureCounts.
 */

process PICARD_MARKDUP {

    tag "$sample_id"

    container 'quay.io/biocontainers/picard:3.1.1--hdfd78af_0'

    publishDir "${params.outdir}/picard_markdup", mode: 'copy'

    input:
    tuple val(sample_id), path(sorted_bam), path(sorted_bam_bai)

    output:
    tuple val(sample_id),
          path("${sample_id}_markdup.bam"),
          path("${sample_id}_markdup.bam.bai"), emit: markdup_bam

    tuple val(sample_id),
          path("${sample_id}.markdup_metrics.txt"), emit: metrics

    script:
    // 80% de la RAM asignada se pasa al JVM; evita OOM durante el marcado de duplicados
    def avail_mem = (task.memory.mega * 0.8).intValue()
    """
    picard -Xmx${avail_mem}M MarkDuplicates \\
        --INPUT              ${sorted_bam} \\
        --OUTPUT             ${sample_id}_markdup.bam \\
        --METRICS_FILE       ${sample_id}.markdup_metrics.txt \\
        --REMOVE_DUPLICATES  false \\
        --CREATE_INDEX       true \\
        --ASSUME_SORT_ORDER  coordinate \\
        --VALIDATION_STRINGENCY LENIENT

    # Picard nombra el índice <base>.bai; renombramos a <base>.bam.bai (convención estándar)
    mv ${sample_id}_markdup.bai ${sample_id}_markdup.bam.bai
    """
}
