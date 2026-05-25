/*
* STAR index module
*
*/

process STAR_index {

    tag "${genome_fasta.baseName}"

    container 'biocontainers/star:2.7.11b--h5ca1c30_8'

    publishDir "${params.data_dir}/star_index", mode: 'copy', pattern: "star_index"

    input:
    path genome_fasta
    path gtf_file

    output:
    path "star_index", emit: star_index
    path "versions.yml", emit: versions

    script:
    """
    STAR \\
        --runThreadN ${task.cpus} \\
        --runMode genomeGenerate \\
        --genomeDir star_index \\
        --genomeFastaFiles ${genome_fasta} \\
        --sjdbGTFfile ${gtf_file} \\
        --sjdbOverhang 100

    cat <<-END_VERSIONS > versions.yml
    '${task.process}':
        star: \$(STAR --version | sed 's/STAR_//')
    END_VERSIONS
    """
}
