#!/usr/bin/env nextflow
/*
 * main.nf — Pipeline RNA-seq GSE52778
 * Por ahora: FastQC + Trimmomatic
 */

nextflow.enable.dsl = 2

// Importar módulos
include { FASTQC as FASTQC_RAW  } from './modules/01_fastqc'
include { FASTQC as FASTQC_TRIM } from './modules/01_fastqc'
include { TRIMMOMATIC           } from './modules/02_trimmomatic'

// Leer samplesheet
def parse_samplesheet(csv_path) {
    Channel
        .fromPath(csv_path, checkIfExists: true)
        .splitCsv(header: true, strip: true)
        .map { row ->
            def sid = row.sample_id
            def r1  = file(row.fastq_1, checkIfExists: true)
            def r2  = file(row.fastq_2, checkIfExists: true)
            return tuple(sid, r1, r2)
        }
}

workflow {

    // 1. Leer muestras
    reads_ch = parse_samplesheet(params.samplesheet)

    // 2. FastQC sobre lecturas crudas
    FASTQC_RAW(reads_ch)

    // 3. Trimmomatic
    TRIMMOMATIC(reads_ch)

    // 4. FastQC sobre lecturas trimadas
    FASTQC_TRIM(TRIMMOMATIC.out.trimmed_reads)
}
