/*
* STAR alignment module
*
*/

process STAR_alignment {

    tag "${sample_id}"

    container 'biocontainers/star:2.7.11b--h5ca1c30_8'

    publishDir "${params.outdir}/star_alignment/${sample_id}", mode: 'copy', pattern: "${sample_id}.*"

    input:
    tuple val(sample_id), path(reads)
    path star_index

    output:
    tuple val(sample_id), path("${sample_id}.Aligned.sortedByCoord.out.bam"), emit: bam
    tuple val(sample_id), path("${sample_id}.Log.final.out"), emit: log
    tuple val(sample_id), path("${sample_id}.SJ.out.tab"), emit: sj_out
    path "versions.yml", emit: versions

    script:
    def prefix = sample_id
    """
    STAR \\
        --runThreadN ${task.cpus} \\
        --genomeDir ${star_index} \\
        --readFilesIn ${reads} \\
        --readFilesCommand zcat \\
        --outFileNamePrefix "${prefix}." \\
        --outSAMtype BAM SortedByCoordinate

    cat <<-END_VERSIONS > versions.yml
    '${task.process}':
        star: \$(STAR --version | sed 's/STAR_//')
    END_VERSIONS
    """
}
    