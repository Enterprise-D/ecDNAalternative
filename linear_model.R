library(dplyr)

chrv = "chr7"
startv = 55000000

pos_cnv = read.table("data/lm_train_LC499/GBM39_ecDNA_LC499_cnv.txt", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
pos_ratio = read.table("data/lm_train_LC499/GBM39_ecDNA_LC499_ratio.txt", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
pos_gini = read.table("data/lm_train_LC499/GBM39_ecDNA_LC499_gini.txt", sep = "\t", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
pos_label = as.data.frame(rep(1,nrow(pos_cnv)))

neg_cnv = read.table("data/lm_train_LC499/GBM39_ecDNA_LC500_cnv.txt", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
neg_ratio = read.table("data/lm_train_LC499/GBM39_ecDNA_LC500_ratio.txt", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
neg_gini = read.table("data/lm_train_LC499/GBM39_ecDNA_LC500_gini.txt", sep = "\t", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
neg_label = as.data.frame(rep(0,nrow(neg_cnv)))

pos_set = cbind(pos_cnv,pos_ratio,pos_gini,pos_label)
neg_set = cbind(neg_cnv,neg_ratio,neg_gini,neg_label)

colnames(pos_set) = c("cnv", "ratio", "gini", "label")
colnames(neg_set) = c("cnv", "ratio", "gini", "label")

training_set = rbind(pos_set,neg_set)

remove(pos_cnv, pos_ratio, pos_gini, pos_label, neg_cnv, neg_ratio, neg_gini, neg_label, pos_set, neg_set)

training_set = training_set[training_set$cnv<=100 ,]

linear_model = glm(label ~ cnv + ratio + gini, data = training_set, family = 'binomial')

summary(linear_model)

coef = summary(linear_model)$coef
write.table(coef, file='lm_coef_model.txt', row.names=T, col.names=T, sep='\t', quote=F)

### Validation

pos_cnv = read.table("data/lm_val_LC499/GBM39_ecDNA_LC499_cnv.txt", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
pos_ratio = read.table("data/lm_val_LC499/GBM39_ecDNA_LC499_ratio.txt", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
pos_gini = read.table("data/lm_val_LC499/GBM39_ecDNA_LC499_gini.txt", sep = "\t", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
pos_label = as.data.frame(rep(1,nrow(pos_cnv)))

neg_cnv = read.table("data/lm_val_LC500/GBM39_ecDNA_LC500_cnv.txt", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
neg_ratio = read.table("data/lm_val_LC500/GBM39_ecDNA_LC500_ratio.txt", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
neg_gini = read.table("data/lm_val_LC500/GBM39_ecDNA_LC500_gini.txt", sep = "\t", header = T) %>% filter(chr == chrv & start == startv) %>% select(-chr, -start, -end) %>% t()
neg_label = as.data.frame(rep(0,nrow(neg_cnv)))

pos_set = cbind(pos_cnv,pos_ratio,pos_gini,pos_label)
neg_set = cbind(neg_cnv,neg_ratio,neg_gini,neg_label)

colnames(pos_set) = c("cnv", "ratio", "gini", "label")
colnames(neg_set) = c("cnv", "ratio", "gini", "label")

validation_set = rbind(pos_set,neg_set)

remove(pos_cnv, pos_ratio, pos_gini, pos_label, neg_cnv, neg_ratio, neg_gini, neg_label, pos_set, neg_set)

validation_set[validation_set$cnv>100 ,"cnv"] = 100

validation_set$pred = predict(linear_model, validation_set, type = "response")
validation_set$pred[is.na(validation_set$pred)] = 0

write.table(validation_set, file='test_result_lm.csv', row.names=F, col.names=F, sep=",", quote=F)