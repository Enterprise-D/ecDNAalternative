b1 = read.table("data/processed/barcode_val_499500.txt")[,1]
b0 = stringi::stri_split(b1, fixed = "_", simplify = TRUE)[,1]
barcodes = paste0(b0, "/", b1)

for (i in seq_along(barcodes)) {
  file.copy(from = paste0("data/raw/", barcodes[i]), to = paste0("data/raw/lm_val_499500/"), recursive = TRUE)
}