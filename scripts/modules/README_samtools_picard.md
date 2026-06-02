# Módulos SAMtools y Picard

## 05_samtools.nf — Ordenación e indexado de BAMs

### ¿Qué hace?
Procesa los BAMs de salida de STAR:
1. **Ordena** el BAM por coordenadas genómicas
2. **Indexa** el BAM (crea el `.bai`)
3. **Calcula flagstat** → métricas de alineamiento (% reads mapeados)

### Imagen Docker
`quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1`

### Salidas
- `*_sorted.bam` + `*_sorted.bam.bai` → van a Picard
- `*.flagstat.txt` → va a MultiQC


## Ejecución
Estos módulo se ejecuta automáticamente dentro del pipeline:
```bash
nextflow run scripts/main.nf -profile docker
```
