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
data$BA2 <- relevel(data$BA, ref = "1")

ind = data;

#library("nnet")
test <- multinom(ind$BA2 ~  . , data = ind[,-c(1:17)])
summary(test)

z <- summary(test)$coefficients/summary(test)$standard.errors
View(z)

p <- (1 - pnorm(abs(z), 0, 1))*2
View(p)

#p[p<0.05]
View(p[p<0.05])

#exp(coef(test))

View(coef(test))



test2 <- multinom(ind$BA2 ~  . , data = ind[,c(25,46,50,51,57,59,64,65)])

summary(test2)

z2 <- summary(test2)$coefficients/summary(test2)$standard.errors
View(z)

p2 <- (1 - pnorm(abs(z2), 0, 1))*2
View(p2)

View(p2[p2<0.05])


View(fitted(test2))
View(fitted(test))


#library(rattle)
#rattle()


# Classification Tree with rpart
library(rpart)

# grow tree 
#fit <- rpart(ind$BA2 ~  . , method="class", data = ind[,c(25,46,50,51,57,59,64,65)] ) 

fit <- rpart(ind$BA2 ~  . , method="class", data = ind[,-c(1:17)] )

printcp(fit) # display the results 
plotcp(fit) # visualize cross-validation results 
summary(fit) # detailed summary of splits

# plot tree 
plot(fit, uniform=TRUE, 
     main="Classification Tree")

plot(fit)



