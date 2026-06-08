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
    mkdir -p \$HOME/R_libs
    Rscript -e "
        .libPaths('\$HOME/R_libs')
        install.packages(c('ggplot2','tidyr','dplyr','tibble'), lib='\$HOME/R_libs', repos='https://cloud.r-project.org')
        BiocManager::install('edgeR', lib='\$HOME/R_libs', ask=FALSE, update=FALSE)
    "
    cp ${projectDir}/bin/rnaseq_exploratory.R .
    R_LIBS="\$HOME/R_libs" Rscript rnaseq_exploratory.R
    """
}
