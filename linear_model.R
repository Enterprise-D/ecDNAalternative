library(dplyr)
library(stringi)

glm_train = function(chrv, startv, pos, neg) {
  pos_cnv = read.table(paste0("data/lm_summarized/lm_train_", pos, "/", pos, "_cnv.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_ratio = read.table(paste0("data/lm_summarized/lm_train_", pos, "/", pos, "_ratio.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_gini = read.table(paste0("data/lm_summarized/lm_train_", pos, "/", pos, "_gini.txt"), sep = "\t", header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_label = as.data.frame(rep(1, nrow(pos_cnv)))

  neg_cnv = read.table(paste0("data/lm_summarized/lm_train_", neg, "/", neg, "_cnv.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_ratio = read.table(paste0("data/lm_summarized/lm_train_", neg, "/", neg, "_ratio.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_gini = read.table(paste0("data/lm_summarized/lm_train_", neg, "/", neg, "_gini.txt"), sep = "\t", header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_label = as.data.frame(rep(0, nrow(neg_cnv)))

  pos_set = cbind(pos_cnv, pos_ratio, pos_gini, pos_label)
  neg_set = cbind(neg_cnv, neg_ratio, neg_gini, neg_label)

  colnames(pos_set) = c("cnv", "ratio", "gini", "label")
  colnames(neg_set) = c("cnv", "ratio", "gini", "label")

  training_set = rbind(pos_set, neg_set)

  remove(pos_cnv, pos_ratio, pos_gini, pos_label, neg_cnv, neg_ratio, neg_gini, neg_label, pos_set, neg_set)

  training_set = training_set[training_set$cnv <= 100,]

  linear_model = glm(label ~ cnv + ratio + gini, data = training_set, family = 'binomial')

  summary(linear_model)

  coef = summary(linear_model)$coef
  write.table(coef, file = 'lm_coef_model.txt', row.names = T, col.names = T, sep = '\t', quote = F)

  return(linear_model)
}

glm_validate = function(linear_model, chrv, startv, pos, neg) {

  pos_cnv = read.table(paste0("data/lm_summarized/lm_val_", pos, "/", pos, "_cnv.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_ratio = read.table(paste0("data/lm_summarized/lm_val_", pos, "/", pos, "_ratio.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_gini = read.table(paste0("data/lm_summarized/lm_val_", pos, "/", pos, "_gini.txt"), sep = "\t", header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  pos_label = as.data.frame(rep(1, nrow(pos_cnv)))

  neg_cnv = read.table(paste0("data/lm_summarized/lm_val_", neg, "/", neg, "_cnv.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_ratio = read.table(paste0("data/lm_summarized/lm_val_", neg, "/", neg, "_ratio.txt"), header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_gini = read.table(paste0("data/lm_summarized/lm_val_", neg, "/", neg, "_gini.txt"), sep = "\t", header = T) %>%
    filter(chr == chrv & start == startv) %>%
    select(-chr, -start, -end) %>%
    t()
  neg_label = as.data.frame(rep(0, nrow(neg_cnv)))

  pos_set = cbind(pos_cnv, pos_ratio, pos_gini, pos_label)
  neg_set = cbind(neg_cnv, neg_ratio, neg_gini, neg_label)

  colnames(pos_set) = c("cnv", "ratio", "gini", "label")
  colnames(neg_set) = c("cnv", "ratio", "gini", "label")

  validation_set = rbind(pos_set, neg_set)

  remove(pos_cnv, pos_ratio, pos_gini, pos_label, neg_cnv, neg_ratio, neg_gini, neg_label, pos_set, neg_set)

  validation_set[validation_set$cnv > 100, "cnv"] = 100

  validation_set$pred = predict(linear_model, validation_set, type = "response")
  validation_set$pred[is.na(validation_set$pred)] = 0

  ident = paste0(stri_replace(pos, fixed = "LC", replacement = ""), stri_replace(neg, fixed = "LC", replacement = ""))

  write.table(validation_set, file = paste0('data/lm_summarized/prediction_', ident, '.csv'), row.names = F, col.names = F, sep = ",", quote = F)
}

linear_model = glm_train(chrv = "chr7", startv = 55000000, pos = "LC499", neg = "LC500")

glm_validate(linear_model, chrv = "chr7", startv = 55000000, pos = "LC499", neg = "LC500")

glm_validate(linear_model, chrv = "chr8", startv = 127000000, pos = "LC729", neg = "LC730")

glm_validate(linear_model, chrv = "chr8", startv = 127000000, pos = "LC676", neg = "LC677")
