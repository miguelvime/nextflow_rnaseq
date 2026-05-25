/*
* STAR alignment module
*
*/

process STAR_index {

    tag "STAR_index"

    container 'biocontainers/star:2.7.11b--h5ca1c30_8'

    publishDir "${params.outdir}/star_index", mode: 'copy'

    input:
    path genome_fasta = 
    path gtf_file =

    output:
    path "STAR_index"

    script:
    """
    STAR \\
        --runThreadN 4 \\
        --runMode genomeGenerate \\
        --genomeDir STAR_index \\
        --genomeFastaFiles ${genome_fasta} \\
        --sjdbGTFfile ${gtf_file} \\
        --sjdbOverhang 100
    """
}
