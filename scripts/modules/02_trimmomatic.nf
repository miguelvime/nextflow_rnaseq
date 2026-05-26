/*
 * modules/02_trimmomatic.nf
 * Elimina adaptadores y bases de baja calidad.
 */

process TRIMMOMATIC {

    tag "$sample_id"

    container 'quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2'

    publishDir "${params.outdir}/trimmomatic", mode: 'copy'

    input:
    tuple val(sample_id), path(r1), path(r2)

    output:
    tuple val(sample_id),
          path("${sample_id}_R1_paired.fastq.gz"),
          path("${sample_id}_R2_paired.fastq.gz"),  emit: trimmed_reads

    tuple val(sample_id),
          path("${sample_id}_R1_unpaired.fastq.gz"),
          path("${sample_id}_R2_unpaired.fastq.gz"), emit: unpaired_reads

    tuple val(sample_id),
          path("${sample_id}_trimmomatic.log"),       emit: log

    script:
    """
    trimmomatic PE \\
        -phred33 \\
        -threads ${task.cpus} \\
        ${r1} ${r2} \\
        ${sample_id}_R1_paired.fastq.gz   ${sample_id}_R1_unpaired.fastq.gz \\
        ${sample_id}_R2_paired.fastq.gz   ${sample_id}_R2_unpaired.fastq.gz \\
        ILLUMINACLIP:/usr/share/trimmomatic/TruSeq3-PE.fa:2:30:10 \\
        LEADING:3 \\
        TRAILING:3 \\
        SLIDINGWINDOW:4:15 \\
        MINLEN:36 \\
        2> ${sample_id}_trimmomatic.log
    """
}
