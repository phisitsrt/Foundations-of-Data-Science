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

ind = data;

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


cl = 17

# p < 0.5
View(p[p<0.5])

test3 <- multinom(ind$BA2 ~  . , data = ind[,c(cl+7,cl+8,cl+10,cl+14,cl+15,cl+18,cl+19,cl+24,cl+29,cl+32,cl+33,cl+34,cl+35,cl+38,cl+39,cl+40,cl+42,cl+43,cl+46,cl+47,cl+48)])

summary(test3)

View(fitted(test3))

## Residual Deviance: 0.17566 
## AIC: 44.17566 

# p < 0.1
View(p[p<0.1])

test4 <- multinom(ind$BA2 ~  . , data = ind[,c(cl+8,cl+19,cl+29,cl+33,cl+34,cl+40,cl+42,cl+46,cl+47,cl+48)])

summary(test4)

View(fitted(test4))




# p < 0.45
View(p[p<0.45])

test5 <- multinom(ind$BA2 ~  . , data = ind[,c(cl+7,cl+8,cl+10,cl+14,cl+15,cl+18,cl+19,cl+29,cl+32,cl+33,cl+34,cl+35,cl+38,cl+39,cl+40,cl+42,cl+43,cl+46,cl+47,cl+48)])

summary(test5)

View(fitted(test5))


## p < 0.45
## Residual Deviance: 2.584194 
## AIC: 44.58419


## p < 0.4
## Residual Deviance: 17.38465 
## AIC: 51.38465 





