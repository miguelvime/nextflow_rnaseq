#!/usr/bin/env Rscript
setwd(getwd())
# =============================================================================
# rnaseq_exploratory.R
# Análisis exploratorio RNA-seq GSE52778
# Dexamethasone vs Untreated — células HASM
#
# Produce:
#   1. boxplot_raw.png        → distribución ANTES de normalizar
#   2. boxplot_normalized.png → distribución DESPUÉS de normalizar (TMM)
#   3. pca_plot.png           → PCA no supervisado por condición
#
# Uso: Rscript rnaseq_exploratory.R counts_matrix.txt
# =============================================================================

suppressPackageStartupMessages({
  library(edgeR)
  library(ggplot2)
  library(tidyr)
  library(dplyr)
})

# ── 1. Leer matriz de cuentas de featureCounts ────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
counts_file <- "featurecounts.txt"
cat("Leyendo:", counts_file, "\n")

raw_counts <- read.table(counts_file, header=TRUE, sep="\t", skip=1,
                         row.names=1, check.names=FALSE)

# Las primeras 5 columnas son metadatos de featureCounts
counts <- raw_counts[, 6:ncol(raw_counts)]
colnames(counts) <- gsub(".*(SRR[0-9]+).*", "\\1", colnames(counts))
cat("Genes:", nrow(counts), "| Muestras:", ncol(counts), "\n")

# ── 2. Metadatos ──────────────────────────────────────────────────────────────
sample_info <- data.frame(
  sample_id = c("SRR1039508","SRR1039509","SRR1039512","SRR1039513",
                "SRR1039516","SRR1039517","SRR1039520","SRR1039521"),
  condition = c("Untreated","Dexamethasone","Untreated","Dexamethasone",
                "Untreated","Dexamethasone","Untreated","Dexamethasone"),
  donor     = c("N61311","N61311","N052611","N052611",
                "N080611","N08611","N06011","N06011"),
  stringsAsFactors = FALSE
)
rownames(sample_info) <- sample_info$sample_id
sample_info <- sample_info[colnames(counts), ]

# ── 3. Filtrado ───────────────────────────────────────────────────────────────
dge <- DGEList(counts=counts, group=sample_info$condition)
keep <- filterByExpr(dge, min.count=1, min.prop=0.5)
dge <- dge[keep, , keep.lib.sizes=FALSE]
cat("Genes tras filtrado:", sum(keep), "\n")

# ── 4. Boxplot ANTES de normalizar ────────────────────────────────────────────
log_cpm_raw <- cpm(dge, log=TRUE, prior.count=1)

df_raw <- as.data.frame(log_cpm_raw) %>%
  tibble::rownames_to_column("gene") %>%
  pivot_longer(-gene, names_to="sample", values_to="log2_CPM") %>%
  left_join(sample_info, by=c("sample"="sample_id"))

png("boxplot_raw.png", width=900, height=600, res=120)
ggplot(df_raw, aes(x=sample, y=log2_CPM, fill=condition)) +
  geom_boxplot(outlier.size=0.5) +
  scale_fill_manual(values=c("Untreated"="#4E9AF1","Dexamethasone"="#F1824E")) +
  labs(title="Expresión ANTES de normalizar", x="Muestra",
       y="log2(CPM+1)", fill="Condición") +
  theme_bw() + theme(axis.text.x=element_text(angle=45, hjust=1))
dev.off()
cat("Guardado: boxplot_raw.png\n")

# ── 5. Normalización TMM ──────────────────────────────────────────────────────
dge <- calcNormFactors(dge, method="TMM")
cat("Factores TMM:\n")
print(dge$samples[, c("lib.size","norm.factors")])

# ── 6. Boxplot DESPUÉS de normalizar ─────────────────────────────────────────
log_cpm_norm <- cpm(dge, log=TRUE, prior.count=1)

df_norm <- as.data.frame(log_cpm_norm) %>%
  tibble::rownames_to_column("gene") %>%
  pivot_longer(-gene, names_to="sample", values_to="log2_CPM") %>%
  left_join(sample_info, by=c("sample"="sample_id"))

png("boxplot_normalized.png", width=900, height=600, res=120)
ggplot(df_norm, aes(x=sample, y=log2_CPM, fill=condition)) +
  geom_boxplot(outlier.size=0.5) +
  scale_fill_manual(values=c("Untreated"="#4E9AF1","Dexamethasone"="#F1824E")) +
  labs(title="Expresión DESPUÉS de normalizar (TMM)", x="Muestra",
       y="log2(CPM+1)", fill="Condición") +
  theme_bw() + theme(axis.text.x=element_text(angle=45, hjust=1))
dev.off()
cat("Guardado: boxplot_normalized.png\n")

# ── 7. PCA no supervisado ─────────────────────────────────────────────────────
var_genes  <- apply(log_cpm_norm, 1, var)
top500     <- names(sort(var_genes, decreasing=TRUE))[1:500]
pca_result <- prcomp(t(log_cpm_norm[top500, ]), scale.=TRUE)

var_exp <- round(100 * pca_result$sdev^2 / sum(pca_result$sdev^2), 1)
cat(sprintf("PC1: %.1f%% | PC2: %.1f%%\n", var_exp[1], var_exp[2]))

pca_df <- data.frame(
  PC1       = pca_result$x[,1],
  PC2       = pca_result$x[,2],
  sample    = rownames(pca_result$x),
  condition = sample_info[rownames(pca_result$x), "condition"],
  donor     = sample_info[rownames(pca_result$x), "donor"]
)

png("pca_plot.png", width=800, height=700, res=120)
ggplot(pca_df, aes(x=PC1, y=PC2, color=condition, shape=donor, label=sample)) +
  geom_point(size=5, alpha=0.9) +
  geom_text(vjust=-0.8, size=3, show.legend=FALSE) +
  scale_color_manual(values=c("Untreated"="#4E9AF1","Dexamethasone"="#F1824E")) +
  labs(title="PCA no supervisado — GSE52778",
       x=paste0("PC1 (",var_exp[1],"%)"),
       y=paste0("PC2 (",var_exp[2],"%)"),
       color="Condición", shape="Donante") +
  theme_bw()
dev.off()
cat("Guardado: pca_plot.png\n")
cat("\n=== Análisis completado ===\n")

