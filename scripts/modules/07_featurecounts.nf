/*
 * ******************Featurecounts module  ***********************
 *INPUT ->SAM/BAM
 *       ->GTF:an annotation file including chromosomal coordinates of features
 *
 *OUTPUT -> A file with numbers of reads assigned to features
 *       -> stat info for the overall results
 *              ->number of succesfully asigned reads
 *              ->number of reads that failed to be assigned
 */
 

process FEATURECOUNTS {
    tag "matriz_global"

    container 'quay.io/biocontainers/subread:2.0.3--h9ee0642_0'

    publishDir "${params.outdir}/featurecounts", mode: 'copy'

    input:
    path bams // Tomamos el output bam_collected del main workflow
    path genome_gtf from file(params.genome_gtf)
    
    output:
    path "featurecounts.txt", emit: matrix   
    path "featurecounts.txt.summary", emit: summary

    script:
    """
    featureCounts \\
        -a ${params.genome_gtf} \\
        -p \\
        -o ${sample_id}_featurecounts.txt \\
        ${bams}

    """
}