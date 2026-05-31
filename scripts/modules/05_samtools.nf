/*
 * modules/05_samtools.nf
 * Ordena, indexa y calcula métricas de alineamiento.
 */

process SAMTOOLS {

    tag "$sample_id"

    container 'quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1'

    publishDir "${params.outdir}/samtools", mode: 'copy'

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id),
          path("${sample_id}_sorted.bam"),
          path("${sample_id}_sorted.bam.bai"), emit: sorted_bam

    tuple val(sample_id),
          path("${sample_id}.flagstat.txt"),   emit: flagstat

    script:
    """
    samtools sort -@ ${task.cpus} -o ${sample_id}_sorted.bam ${bam}
    samtools index ${sample_id}_sorted.bam
    samtools flagstat ${sample_id}_sorted.bam > ${sample_id}.flagstat.txt
    """
}
