
#import dataset
fish <- read.table("~/R/fish.txt", quote="\"", comment.char="")

#rename columns
names(fish) <- c("time", "catch")

#detach(fish)
#attach variables in dataset to be available for use in R functions
attach(fish)

#see summary: mean,median,min,max
summary(fish)

#variance (type N-1, sample type)
var(time) # 31.99831
var(catch) # 1.162248

#standard deviation (type N-1, sample type)
sd(time) # 5.656705
sd(catch) # 1.078076

#plot histogram
#hist(time, col = "blue", breaks = seq(0,24,by=1), xlim = c(0,25) )
#hist(catch, col = "blue", breaks = seq(0,4.5,by=0.2), xlim = c(0,5) )

#get size of observations
n = as.numeric(dim(fish)[1])

#calculate bin_size for variable: time and catch 
x_bin_size = 2*(n^(-1/3))*IQR(time, na.rm = FALSE, type = 7)
y_bin_size = 2*(n^(-1/3))*IQR(catch, na.rm = FALSE, type = 7)

x_bin_size = round(x_bin_size, digits = 0)
y_bin_size = round(y_bin_size, digits = 1)

#plot histogram with calculated bin_size
hist(time, col = "blue", breaks = seq(0,24,by=x_bin_size), xlim = c(0,25)
     , xaxt='n', xlab="time of catch (hour)", main="Histogram of catch time" )
axis(1, at=seq(0,24,3), col.axis="black")

hist(catch, col = "blue", breaks = seq(0,5,by=y_bin_size), xlim = c(0,5)
     , xaxt='n', xlab="size of catch (kg)", main="Histogram of catch size")
axis(1, at=seq(0,4.8,0.6), col.axis="black")

#plot scatter graph
plot(catch ~ time , type="p", col="blue" 
     , xaxt='n', ylab="catch size (kg)", xlab="time of catch (hour)"
     , main="Scatter plot of catch size and time" )
axis(1, at=seq(0,24,3), col.axis="black")

#plot smooth scatter graph
#smoothScatter(catch ~ time, nrpoints = Inf, cex = 2, col = "red") 
#help(smoothScatter)
smoothScatter(catch ~ time, nrpoints = Inf, cex = 2, col = "red"
              , xlab="time of catch (hour)", ylab="catch size (kg)", xaxt='n'
              , main="2D Kernel density estimation") 
grid(col="black")
#help(axis)
axis(1, at=seq(0,24,3), col.axis="black", las=0)

#boxplot 
boxplot(time)
boxplot(catch)

#covariance matrix ??? maybe.
var(fish)
covarmtx <- as.matrix(var(fish))

#generate a random to check the covariance matrix
cholmtx <- chol(covarmtx)

set.seed(124)
normmtx <- matrix(c(rnorm(200, mean=mean(catch))
                    ,rnorm(200), mean=mean(time))
                  ,nrow=100,ncol=2)

scattermtx <- normmtx%*%cholmtx

plot(scattermtx[,2] ~ scattermtx[,1]  , type="p", col="blue" 
     , ylab="catch size (kg)", xlab="time of catch (hour)"
     , main="Scatter plot of catch size and time" )
###

#correlation of fish dataset
cor(fish)
cov(time, catch)/((var(time)^(1/2))*(var(catch)^(1/2)))
#-0.1282133

#Spearman correlation
cor(fish, method="spearman", use="pairwise")  
#-0.1268256

#Kendall correlation
cor(fish, method="kendall", use="pairwise") 
#-0.08848851

#Information about Y from the knowledge of X
#R-squared
cor(fish)^2  #  0.01643866
# so, X explain only 1.64% of the variance in Y.

cor(fish, method="spearman", use="pairwise")^2 # 0.01608473 # 1.6%
cor(fish, method="kendall", use="pairwise")^2 # 0.007830217 # 0.7%


#Standard Error of Mean
sem_time = sd(time)*n^(-1/2) # 0.3999894
sem_catch = sd(catch)*n^(-1/2) # 0.0762315

#see summary: mean,median,min,max
summary(fish)
#  time            catch   
# Mean   : 9.388   Mean   :1.8431 

#mean, median
mean(time) # 9.38835
mean(catch) #  1.84305

median(time)  # 8.95
median(catch)  # 1.825

#geometric mean
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
gm_mean(time)  # 6.786465
# tend to cluster on the time 6.786465
gm_mean(catch)  # 1.36948
# tend to cluster on the catch 1.36948


#skewness calculation
( mean(time) - median(time) )/sd(time)   # 0.07749211
( mean(catch) - median(catch) )/sd(catch)  # 0.01674279
#positive skewness - tend to be left

#skewness by R package
#install.packages("e1071")
library(e1071)
skewness(time)   # 0.2477339
skewness(catch)   # 0.08966
#positive skewness - tend to be left


#kurtosis by R package
#install.packages("e1071")
#library(e1071) 
kurtosis(time)
# -0.8870124 # Platykurtic # fat-tailed distribution
kurtosis(catch) 
# -1.169334 # Platykurtic # fat-tailed distribution


#count number of observations by condition
length(catch[which (time>=0 & time <=24)])

#calculate average catch for each period of time, 3 hours per period.
avg_catch <- matrix()
for (tmax in seq(3,24,3)){
  avg_catch <- cbind(avg_catch, mean(catch[which (time>=(tmax-3) & time <=tmax)]) )
}
avg_catch <- avg_catch[,2:(1+(24/3))]

#plot distribution of avg_catch
plot(seq(3,24,3),avg_catch, type= "b", xlab="time of catch (hour)", ylab="average of catch size (kg)", col="blue")


#calculate median catch for each period of time, 3 hours per period.
med_catch <- matrix()
for (tmax in seq(3,24,3)){
  med_catch <- cbind(med_catch, median(catch[which (time>=(tmax-3) & time <=tmax)]) )
}
med_catch <- med_catch[,2:(1+(24/3))]

#plot distribution of med_catch
plot(seq(3,24,3),med_catch, type= "b", xlab="time of catch (hour)", ylab="median of catch size (kg)", col="#994477")

#calculate sum of catch for each period of time, 3 hours per period.
sum_catch <- matrix()
for (tmax in seq(3,24,3)){
  sum_catch <- cbind(sum_catch, sum(catch[which (time>=(tmax-3) & time <=tmax)]) )
}
sum_catch <- sum_catch[,2:(1+(24/3))]

#plot distribution of sum_catch
#plot(seq(3,24,3),sum_catch, type= "b", xlab="time (hour)", ylab="sum of catch size (kg)", col="#779944")
plot(seq(3,24,3),sum_catch, type= "b", xlab="time of catch (hour)"
     , ylab="sum of catch size (kg)", col="#779944", xaxt='n' )
axis(1, at=seq(0,24,3), col.axis="black")

#prepare sum_catch data into dataframe.
catch_byperiod <- rbind(sum_catch,seq(3,24,3))
catch_byperiod <- t(catch_byperiod)
catch_byperiod <- as.data.frame(catch_byperiod)
names(catch_byperiod) <- c("sum_catch","time_period")

#detach(catch_byperiod)
#attach variables in dataset to be available for use in R functions
attach(catch_byperiod)

#correlation of sum_catch or catch_byperiod
cor(catch_byperiod)
# -0.9180592

#plot line graph for sum_catch
plot(sum_catch ~ time_period, type= "b", xlab="time of catch (hour)", ylab="sum of catch size (kg)", col="#779944")
lines( lowess( sum_catch ~ time_period), col="green" )

#Fitting a simple linear model
qdlm1 <- lm( sum_catch ~ time_period )
summary( qdlm1 )

#plot line graph with fitting linear model line
plot(sum_catch ~ time_period, type= "b", xlab="time of catch (hour)", ylab="sum of catch size (kg)", col="black")
lines( predict(qdlm1) ~ time_period , col="red" )

#Fitting polynomial models
qdlm2 <- lm ( sum_catch ~ poly( time_period, 2) )
lines( predict(qdlm2) ~ time_period , col="blue" )

qdlm3 <- lm ( sum_catch ~ poly( time_period, 3) )
lines( predict(qdlm3) ~ time_period , col="green" )

#Fitting mean-line
qdlm0 <- lm ( sum_catch ~ 1 )
lines( predict(qdlm0) ~ time_period , col="gray" )

#Choosing between alternative models
AIC( qdlm0, qdlm1, qdlm2, qdlm3 )

#plot again
plot(sum_catch ~ time_period, type= "b", xlab="time of catch (hour)"
     , ylab="sum of catch size (kg)", col="darkblue", xaxt='n'
     , main="sum of catch size and period time of catch"
     )
axis(1, at=seq(0,24,3), col.axis="black")
lines( predict(qdlm0) ~ time_period , col="gray" )
lines( predict(qdlm1) ~ time_period , col="blue" )
lines( predict(qdlm2) ~ time_period , col="red" )
lines( predict(qdlm3) ~ time_period , col="green" )
title(sub=bquote(
  atop(" ",
       "sum of catch fish size (kg) in each period of 3 hours time of catch" )
))
#help(title)

#barplot
#barplot(as.vector(sum_catch))

#barplot by ggplot2 library
library(ggplot2)
# Basic barplot
catchbar <- ggplot(data=catch_byperiod, aes(x=time_period, y=sum_catch)) +
  geom_bar(stat="identity", fill="steelblue") + 
  scale_x_discrete(name ="time (hour)") +  scale_y_continuous(name ="sum of catch size (kg)") + theme_minimal()
 
#plot predicted line lm2
predict_ml2_df <- data.frame(sum_catch = predict(qdlm2),
                 time_period = time_period)

pdline <- ggplot(data=predict_ml2_df, aes(x=time_period, y=sum_catch, group=1)) +
  geom_line() +
  geom_point()

#plot bar and line together
pl_barline <- ggplot(data=catch_byperiod, aes(x=(time_period-1.4), y=sum_catch)) +
  geom_bar(stat="identity", fill="steelblue") + 
  scale_x_continuous(name ="time of catch (hour)", breaks=seq(0,24,3)) +  
  scale_y_continuous(name ="sum of catch size (kg)") + 
  theme_minimal() + 
  geom_line(data=predict_ml2_df, aes(x=time_period, y=sum_catch), colour = "red") +
  geom_point(data=catch_byperiod, aes(x=(time_period), y=sum_catch),colour = "blue") +
  geom_point(data=predict_ml2_df, aes(x=time_period, y=sum_catch),colour = "red") 
pl_barline


#plot bar and line together with many prediction lines
predict_ml0_df <- data.frame(sum_catch = predict(qdlm0),
                             time_period = time_period,
                             model = "ml0")

predict_ml1_df <- data.frame(sum_catch = predict(qdlm1),
                             time_period = time_period,
                             model = "ml1")

predict_ml2_df <- data.frame(sum_catch = predict(qdlm2),
                             time_period = time_period,
                             model = "ml2")

predict_ml3_df <- data.frame(sum_catch = predict(qdlm3),
                             time_period = time_period,
                             model = "ml3")

pl_barline <- ggplot() +
  geom_bar(data=catch_byperiod, aes(x=(time_period-1.4), y=sum_catch), stat="identity", fill="steelblue") + 
  #geom_point(data=catch_byperiod, aes(x=(time_period), y=sum_catch),colour = "darkblue") +
  scale_x_continuous(name ="time of catch (hour)", breaks=seq(0,24,3)) +  
  scale_y_continuous(name ="sum of catch size (kg)") + 
  theme_minimal() + 
  geom_line(data=predict_ml0_df, aes(x=time_period, y=sum_catch, colour=model)) +
  geom_point(data=predict_ml0_df, aes(x=time_period, y=sum_catch, colour=model)) +
  geom_line(data=predict_ml1_df, aes(x=time_period, y=sum_catch, colour=model)) +
  geom_point(data=predict_ml1_df, aes(x=time_period, y=sum_catch, colour=model)) +
  geom_line(data=predict_ml2_df, aes(x=time_period, y=sum_catch, colour=model)) +
  geom_point(data=predict_ml2_df, aes(x=time_period, y=sum_catch, colour=model)) +
  geom_line(data=predict_ml3_df, aes(x=time_period, y=sum_catch, colour=model)) +
  geom_point(data=predict_ml3_df, aes(x=time_period, y=sum_catch, colour=model)) +
  scale_colour_manual(values=c("grey","blue","red","green") )
pl_barline

###
#generate a random from the covariance matrix
var(fish)
covarmtx <- as.matrix(var(fish))

cholmtx <- chol(covarmtx)

normmtx <- matrix(c(rnorm(200, mean=mean(catch))
                    ,rnorm(200), mean=mean(time))
                  ,nrow=100,ncol=2)

scattermtx <- normmtx%*%cholmtx

plot(scattermtx[,2] ~ scattermtx[,1]  , type="p", col="blue" 
     , ylab="catch size (kg)", xlab="time of catch (hour)"
     , main="Scatter plot of catch size and time" )

#calculate sum of catch of random generated data for each period of time, 3 hours per period.
sum_rand_catch <- matrix()
for (tmax in seq(3,24,3)){
  sum_rand_catch <- cbind(sum_rand_catch, sum(scattermtx[,2][which (scattermtx[,1]>=(tmax-3) & scattermtx[,1] <=tmax)]) )
}
sum_rand_catch <- sum_rand_catch[,2:(1+(24/3))]

#plot distribution of sum_catch
plot(seq(3,24,3),sum_rand_catch, type= "b", xlab="time of catch (hour)"
     , ylab="sum of catch size (kg)", col="#779944", xaxt='n' )
axis(1, at=seq(0,24,3), col.axis="black")
###


#correlation for sum of catch size and time 
cor(catch_byperiod)
# -0.9180592

cor(catch_byperiod, method="spearman", use="pairwise")  
# -0.8809524

cor(catch_byperiod, method="kendall", use="pairwise") 
# -0.7142857

#Information about Y from the knowledge of X
#R-squared
cor(catch_byperiod)^2  
#  0.8428327
# so, X explain only 84.28% of the variance in Y.

cor(catch_byperiod, method="spearman", use="pairwise")^2 
# so, X explain only 77.60% of the variance in Y.

cor(catch_byperiod, method="kendall", use="pairwise")^2 
# so, X explain only 51.02% of the variance in Y.


#standard error calculation
time_mean_error <- 1.96*sd(time)*(n^(-1/2))


