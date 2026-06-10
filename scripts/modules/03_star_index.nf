/*
* STAR index module
*
*/

process STAR_INDEX {

    tag "$genome_fasta.baseName"

    container 'quay.io/biocontainers/star:2.7.11b--h5ca1c30_8'

    publishDir "${params.datadir}/star_index", mode: 'copy', pattern: "star_index"

    input:
    path genome_fasta
    path genome_gtf

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
        --sjdbGTFfile ${genome_gtf} \\
        --sjdbOverhang 62 \\
        --genomeSAsparseD 1

    cat <<-END_VERSIONS > versions.yml
    '${task.process}':
        star: \$(STAR --version | sed 's/STAR_//')
    END_VERSIONS
    """
}
