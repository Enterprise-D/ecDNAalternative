library(dplyr)
library(stringi)

prepare_dataset = function(chrv, startv, pos, neg) {
  pos_cnv = read.table(paste0("data/lm_summarized/lm_", pos, "/", pos, "_cnv.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_ratio = read.table(paste0("data/lm_summarized/lm_", pos, "/", pos, "_ratio.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_gini = read.table(paste0("data/lm_summarized/lm_", pos, "/", pos, "_gini.txt"), sep = "\t", header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_label = as.data.frame(rep(1, nrow(pos_cnv)))

  neg_cnv = read.table(paste0("data/lm_summarized/lm_", neg, "/", neg, "_cnv.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_ratio = read.table(paste0("data/lm_summarized/lm_", neg, "/", neg, "_ratio.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_gini = read.table(paste0("data/lm_summarized/lm_", neg, "/", neg, "_gini.txt"), sep = "\t", header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_label = as.data.frame(rep(0, nrow(neg_cnv)))

  pos_set = cbind(pos_cnv, pos_ratio, pos_gini, pos_label)
  neg_set = cbind(neg_cnv, neg_ratio, neg_gini, neg_label)

  colnames(pos_set) = c("cnv", "ratio", "gini", "label")
  colnames(neg_set) = c("cnv", "ratio", "gini", "label")

  training_set = rbind(pos_set, neg_set)

  training_set = training_set[training_set$cnv <= 100,]
}

prepare_dataset_temp = function(chrv, startv, pos, neg) {
  pos_cnv = read.table(paste0("data/lm_summarized/lm_", pos, "_cnv.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_ratio = read.table(paste0("data/lm_summarized/lm_", pos, "_ratio.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_gini = read.table(paste0("data/lm_summarized/lm_", pos, "_gini.txt"), sep = "\t", header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_label = as.data.frame(rep(1, nrow(pos_cnv)))

  neg_cnv = read.table(paste0("data/lm_summarized/lm_", neg, "_cnv.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_ratio = read.table(paste0("data/lm_summarized/lm_", neg, "_ratio.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_gini = read.table(paste0("data/lm_summarized/lm_", neg, "_gini.txt"), sep = "\t", header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_label = as.data.frame(rep(0, nrow(neg_cnv)))

  pos_set = cbind(pos_cnv, pos_ratio, pos_gini, pos_label)
  neg_set = cbind(neg_cnv, neg_ratio, neg_gini, neg_label)

  colnames(pos_set) = c("cnv", "ratio", "gini", "label")
  colnames(neg_set) = c("cnv", "ratio", "gini", "label")

  training_set = rbind(pos_set, neg_set)

  training_set = training_set[training_set$cnv <= 100,]
}

#dataset_1 = prepare_dataset(chrv = "chr7", startv = 55000000, pos = "LC499", neg = "LC500")
dataset_2 = prepare_dataset(chrv = "chr8", startv = 127000000, pos = "LC676", neg = "LC677")

training_set_1 = prepare_dataset_temp(chrv = "chr7", startv = 55000000, pos = "train_LC499/LC499", neg = "train_LC500/LC500")
validation_set_1 = prepare_dataset_temp(chrv = "chr7", startv = 55000000, pos = "val_LC499/LC499", neg = "val_LC500/LC500")

#val_barcode_1 = read.table("data/processed/barcode_val_499500.txt", header = F)$V1
#training_set_1 = dataset_1[!rownames(dataset_1) %in% val_barcode_1,]
#validation_set_1 = dataset_1[rownames(dataset_1) %in% val_barcode_1,]

val_barcode_2 = read.table("data/processed/barcode_val_676677.txt", header = F)$V1
training_set_2 = dataset_2[!rownames(dataset_2) %in% val_barcode_2,]
validation_set_2 = dataset_2[rownames(dataset_2) %in% val_barcode_2,]

training_set = rbind(training_set_1, training_set_2)
validation_set = rbind(validation_set_1, validation_set_2)

linear_model = glm(label ~ cnv + ratio + gini, data = training_set_1, family = 'binomial')

summary(linear_model)

coef = summary(linear_model)$coef
write.table(coef, file = 'lm_coef_model_676677.txt', row.names = T, col.names = T, sep = '\t', quote = F)

######## validation ########

validation_set[validation_set$cnv > 100, "cnv"] = 100

validation_set$pred = predict(linear_model, validation_set, type = "response")
validation_set$pred[is.na(validation_set$pred)] = 0

write.table(validation_set, file = "data/lm_summarized/prediction_all_676677.csv", row.names = F, col.names = F, sep = ",", quote = F)

######### test #########
dataset_3 = prepare_dataset(chrv = "chr8", startv = 127000000, pos = "LC729", neg = "LC730")

dataset_3[dataset_3$cnv > 100, "cnv"] = 100


dataset_3$pred = predict(linear_model, dataset_3, type = "response")
dataset_3$pred[is.na(dataset_3$pred)] = 0

write.table(dataset_3, file = "data/lm_summarized/prediction_729730_mixed.csv", row.names = F, col.names = F, sep = ",", quote = F)