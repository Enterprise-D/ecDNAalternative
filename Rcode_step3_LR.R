dat1 <- read.table('092923_input_LR_COLO_MYC.txt', head=T)
dat2 <- read.table('092923_input_LR_GBM_EGFR.txt', head=T)
nrow(dat1) # 2961
nrow(dat2) # 8752

dat1 <- dat1[ dat1$cnv<=100 ,]
dat2 <- dat2[ dat2$cnv<=100 ,]
nrow(dat1) # 2897
nrow(dat2) # 8747

dat3 <- rbind(dat1, dat2)

fit1 <- glm(outcome ~ cnv + ratio + entropy, data = dat1, family = 'binomial')
fit2 <- glm(outcome ~ cnv + ratio + entropy, data = dat2, family = 'binomial')
fit3 <- glm(outcome ~ cnv + ratio + entropy, data = dat3, family = 'binomial')

summary(fit1)
summary(fit2)
summary(fit3)

out1 <- summary(fit1)$coef
out2 <- summary(fit2)$coef

write.table(out1, file='coef_model_colon.txt', row.names=F, col.names=T, sep='\t', quote=F)
write.table(out2, file= 'coef_model_brain.txt', row.names=F, col.names=T, sep='\t', quote=F)
