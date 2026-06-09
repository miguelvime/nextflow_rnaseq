process RNASEQ_R {

    tag "exploratory_analysis"
    container 'bioconductor/bioconductor_docker:RELEASE_3_18'
    publishDir "${params.outdir}/R_exploratory", mode: 'copy'

    input:
    path counts_matrix

    output:
    path "boxplot_raw.png",        emit: boxplot_raw
    path "boxplot_normalized.png", emit: boxplot_norm
    path "pca_plot.png",           emit: pca

    script:
    """
    export R_LIBS_USER="/mnt/home/users/scbi_quantum_uma/jluque/R/libs-4.3.3"
    
    cp /mnt/home/users/scbi_quantum_uma/jluque/UEM/nextflow_rnaseq/scripts/bin/rnaseq_exploratory.R .
    Rscript rnaseq_exploratory.R
    """
}
