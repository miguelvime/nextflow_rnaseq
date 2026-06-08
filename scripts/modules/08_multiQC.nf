/*
******** MULTIQC ********
*
* Integra todos los inputs de calidad y genera un informe de calidad agregado
* 
* INPUT: -> fastqc ZIPs
*        -> trimmomatic logs
*        -> STAR logs
*        -> samtools flagstat
*        -> featurecounts matrix
*
* OUTPUT: -> multiqc_report.html  # Informe de calidad agregado
*/

process MULTIQC {
    tag "MultiQC"

    container 'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_1'

    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
    path informes

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data", emit: data

    script:
    """
    multiqc .
    """
}