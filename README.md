# nextflow_rnaseq

## 1. Descarga los datos de GEO

Para descargar directamente los .fastq y que aparezcan en la carpeta data/
1. Instala sra-toolkit y pigz 

```bash
sudo apt install sra-toolkit
sudo apt install pigz
``` 
2. Desde nextflow_rnaseq/

```bash
./scripts/download_data.sh 
```

Esto descarga los fastq y los comprime. El resultado debería ser:

Data/
|__SRR*/ 
    |__SRR*_1.fastq.gz
    |__SRR*_2.fastq.gz
    |__SRR*.sra

Habría 8SRR*/ una por cada muestra