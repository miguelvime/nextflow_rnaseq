/*
* STAR alignment module
*
*/

process STAR_ALIGN {

    tag "${sample_id}"

    container 'quay.io/biocontainers/star:2.7.11b--h5ca1c30_8'

    publishDir "${params.outdir}/star_alignment", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2) // Paired reads from TRIMMOMATIC
    path star_index // Receive the index from STAR_INDEX

    output:
    tuple val(sample_id), path("${sample_id}.Aligned.sortedByCoord.out.bam"), emit: bam
    tuple val(sample_id), path("${sample_id}.Log.final.out"), emit: log
    tuple val(sample_id), path("${sample_id}.SJ.out.tab"), emit: sj_out

    script:
    def prefix = sample_id
    """
    STAR \\
        --runThreadN ${task.cpus} \\
        --genomeDir ${star_index} \\
        --readFilesIn ${r1} ${r2} \\
        --readFilesCommand zcat \\
        --outFileNamePrefix "${prefix}." \\
        --outSAMtype BAM SortedByCoordinate
    """
}