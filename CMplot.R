library("CMplot")

count_freq_file = "LC729_sub_summary_ecDNA.txt"

a <- read.table(count_freq_file, header = T)
for (i in seq_len(nrow(a))) {
  a$chr[i] <- strsplit(as.character(a$chr[i]), split = 'chr')[[1]][2]
}

b <- as.data.frame(matrix(0, nrow = nrow(a), ncol = 4))
colnames(b) <- c('SNP', 'Chromosome', 'Position', 'Trait')
b$SNP <- 'NA'
b$Chromosome <- a$chr
b$Position <- apply(a[, 2:3], 1, mean)
b$Trait <- a$freq + 1e-8


CMplot(b, plot.type = "m", col = c("grey30", "grey60"), LOG10 = FALSE, ylim = c(0, 1), threshold = c(0.05, 0.1),
       threshold.lty = c(2, 1), threshold.lwd = c(1, 1), threshold.col = c("black", "black"), amplify = TRUE,
       chr.den.col = NULL, signal.col = c("red", "orange"), signal.cex = c(1.5, 1.5), signal.pch = c(19, 19),
       main = "LC729_sub_summary_ecDNA", ylab = 'Proportion', axis.cex = 0.7,
       file = "jpg", file.name = "LC729_sub_summary_ecDNA", dpi = 300, file.output = TRUE, verbose = TRUE, width = 14, height = 6)
