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

#ind <- data[c(1:69,70)];
ind <- data


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

#View(exp(coef(test)))

View(coef(test))

cl = 17

#test2 <- multinom(ind$BA2 ~  . , data = ind[,c(25,46,50,51,57,59,64,65)])

x <- names(p[p<0.5])
np <- gsub("`","",gsub("[[:punct:]]Intercept[[:punct:]]","",x))
np <- np[-c(1)]
test2 <- multinom(ind$BA2 ~  . , data = ind[,np])


index<-which(p<0.5)
test2 <- multinom(ind$BA2 ~  . , data = ind[,index+17])


summary(test2)$AIC
summary(test2)$deviance

summary(test2)

z2 <- summary(test2)$coefficients/summary(test2)$standard.errors
#View(z2)

p2 <- (1 - pnorm(abs(z2), 0, 1))*2
#View(p2)

View(p2[p2<0.05])

View(fitted(test2))

View(coef(test2))


AIC(test,test2)





