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

---

## 06_picard.nf — Marcado de duplicados

### ¿Qué hace?
Marca los duplicados de PCR en el BAM **sin eliminarlos**.
Esto es importante porque:
- Los duplicados son copias artificiales del mismo fragmento
- Marcarlos permite que featureCounts los trate correctamente
- Genera métricas de complejidad de la librería

### Imagen Docker
`quay.io/biocontainers/picard:3.1.1--hdfd78af_0`

### Parámetros clave
- `REMOVE_DUPLICATES=false` → marcar, no eliminar
- `VALIDATION_STRINGENCY=LENIENT` → tolerante a BAMs incompletos
- `CREATE_INDEX=true` → crea el índice automáticamente

### Salidas
- `*_markdup.bam` + `*_markdup.bam.bai` → van a featureCounts
- `*_markdup_metrics.txt` → va a MultiQC

---

## Ejecución
Estos módulos se ejecutan automáticamente dentro del pipeline:
```bash
nextflow run scripts/main.nf -profile docker
```
