/*
 * modules/09_rnaseq_r.nf
 * Análisis exploratorio en R: normalización TMM, boxplot y PCA.
 */

process RNASEQ_R {

    tag "exploratory_analysis"

    container 'quay.io/biocontainers/bioconductor-edger:3.44.0--r43hf17093f_0'

    publishDir "${params.outdir}/R_exploratory", mode: 'copy'

    input:
    path counts_matrix

    output:
    path "boxplot_raw.png",        emit: boxplot_raw
    path "boxplot_normalized.png", emit: boxplot_norm
    path "pca_plot.png",           emit: pca

    script:
    """
    Rscript ${projectDir}/bin/rnaseq_exploratory.R ${counts_matrix}
    """
}
