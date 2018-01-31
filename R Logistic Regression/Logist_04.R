#library(readr)
data <- read_csv("~/R/data.csv")
View(data)

for(j in names(data)[18:ncol(data)]){
  m <- mean(data[[j]]);
  std <- sd(data[[j]]);
  
  for (i in 1:nrow(data)) { 
    data[i,j] <- (data[i,j] - m) / std
  }
}

data$BA <- as.factor(data$BA)
data$BA2 <- relevel(data$BA, ref = "0")

ind <- data[c(1:69,70)];

#library("nnet")
test <- multinom(ind$BA2 ~  . , data = ind[,-c(1:17)])
summary(test)

z <- summary(test)$coefficients/summary(test)$standard.errors
#View(z)

p <- (1 - pnorm(abs(z), 0, 1))*2
#View(p)

#p[p<0.05]
View(p[p<0.05])

View(fitted(test))

View(exp(coef(test)))

View(coef(test))

cl = 17

test2 <- multinom(ind$BA2 ~  . , data = ind[,c(25,46,50,51,57,59,64,65)])

summary(test2)

z2 <- summary(test2)$coefficients/summary(test2)$standard.errors
#View(z)

p2 <- (1 - pnorm(abs(z2), 0, 1))*2
#View(p2)

View(p2[p2<0.05])

View(fitted(test2))

View(coef(test2))


AIC(test,test2)



data$Type <- as.factor(data$Type)
data$Type2 <- relevel(data$Type, ref = "BB")


ind2 <- data[c(1:69,71)];

ind2 <- ind2[ which( ind2$Type == "BB" | ind2$Type == "BA") , ]

#library("nnet")
test_BB <- multinom(ind2$Type2 ~  . , data = ind2[,-c(1:17)])
summary(test_BB)

z_BB <- summary(test_BB)$coefficients/summary(test_BB)$standard.errors
#View(z_BB)

p_BB <- (1 - pnorm(abs(z_BB), 0, 1))*2
#View(p_BB)

View(p_BB[p_BB<0.05])

View(fitted(test_BB))


test_BB2 <- multinom(ind2$Type2 ~  . , data = ind2[,c(25,46,50,51,57,59,64,65)])

summary(test_BB2)

z_BB2 <- summary(test_BB2)$coefficients/summary(test_BB2)$standard.errors

p_BB2 <- (1 - pnorm(abs(z_BB2), 0, 1))*2

View(fitted(test_BB2))
