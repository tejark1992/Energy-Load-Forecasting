# RTSM project
# Code for ARIMA modelling

# set working directory
setwd(dir = "D:/DA/PGDBA/IIT/MA60056_REGRESSION_AND_TIME_SERIES_MODELS/project/data/")

# load packages
#library(tseries)
library(forecast)
#library(rugarch)
library(TSA) # for "periodogram"


# Load historical prices
data_full <- read.csv(file = 'household_power_consumption.csv', header = TRUE,
                 sep = ",")
#head(data_full) # look at the data

# convert variable "Timestamp" from factor to class-"POSIXct"type
data_full$Timestamp <- as.POSIXct(x = as.character(data_full$Timestamp),
                                  format = "%Y-%m-%d")
#data$Timestamp <- as.POSIXct(x = as.character(data$Timestamp),
#                             format = "%Y-%m-%d %H:%M:%S")

# subset data as per requirement
library(dplyr)
data <- data_full %>% filter(Timestamp > '2007-03-31')

# Divide the data into Train and Test components
# First 90% of the data is Train and next 10% of the data as test
data <- data[1:1194,] # first 90% of the data
data_test <- data[1195:1327,] # 10% of the data
#10% of the data corresponds to 


tot_power <- data$Global_total_power # subset required column(s)
# Function to get periodicity of the data sorted in the order
get_perodicity <- function(dem){
  p <- periodogram(dem)
  dd <- data.frame(frequency = p$freq, amplitude = p$spec)
  order <- dd[order(-dd$amplitude),]
  order$time <- 1/order$frequency
  order
}

get_perodicity(tot_power) %>% head(10)


# Confirm yearly seasonality using "tbats" as well
ts.tot_power.yearly <- ts(tot_power, frequency = 365)
#fit <- tbats(y = ts.tot_power.yearly, use.parallel = T, num.cores = 8)
#seasonal <- !is.null(fit$seasonal)
#seasonal # if TRUE, seasonality is confirmed


# remove yearly seasonality using ts decomposition
decomposed.yearly <- decompose(ts.tot_power.yearly, "additive")
ts.tot_power.yearly <- ts.tot_power.yearly - decomposed.yearly$seasonal
get_perodicity(ts.tot_power.yearly) %>% head(10)
# yearly seasonality is removed but weekly seasonality exist

# Confirm weekly seasonality using "tbats" as well
ts.tot_power.weekly <- ts(ts.tot_power.yearly %>% as.numeric(), frequency = 7)
#fit <- tbats(y = ts.tot_power.weekly, use.parallel = T, num.cores = 8)
#seasonal <- !is.null(fit$seasonal)
#seasonal # if yes, seasonality is confirmed


# remove weekly seasonality using ts decomposition using STL
fit <- stl(ts.tot_power.weekly, s.window = 7, robust = TRUE)
temp <- ts.tot_power.weekly - fit$time.series[, 1]
get_perodicity(temp) %>% head(10) # 12hours seasonality is removed
# but 24 hours seasonality exist
# hence remove this as well


adf.test(temp) # check for stationary using dicky fuller
acf(x = temp %>% as.numeric(), main = "Auto Correlogram")
pacf(x = temp %>% as.numeric(), main = "Partial Auto Correlogram")
plot(temp, xlab = "Time", ylab = "Residuals", 
     main = "Residuals after removing seasonalities")

# ARIMA modelling 
model <- auto.arima(y = temp %>% as.numeric(), parallel = T, 
                    num.cores = 8, stepwise = F,
                    max.p = 5, max.Q = 5, D = 3, seasonal = T)

library(LSTS) # plot results of Ljung box test
Box.Ljung.Test(z = model$residuals, lag = 50)
Box.test(x = model$residuals, lag = 50, type = "Ljung")
# Breusch-Godfrey Test as well in addition to Ljung-box test
library(lmtest)
bgtest(model$residuals)

acf(model$residuals, lag.max = 50, main = "ACF plot of residuals")
pacf(model$residuals, lag.max = 50, main = "PACF of residuals")
qqnorm(model$residuals); qqline(model$residuals)
shapiro.test(model$residuals)# unable to do as number of data points are more
# than 3000, hence anderson darling test for normality
library(nortest)
ad.test(model$residuals)
# qq plot of residuals to check for normality

#histogram of residuals
hist(model$residuals, breaks = "FD", xlab = "Residuals", 
     main = "Histogram of residuals", ylim = c(0,200))

# checking if there is need for GARCH model in r
Box.Ljung.Test(model$residuals^2) # hence model volatilities 
Box.test(x = model$residuals^2, lag = 50)









#moving window
k = 1
j = 1
mwin = 1:7500
dim(mwin) = c(150,50)
for(j in 1:50){
  l = j + 149
  
  for(i  in j:l){
    mwin[,j]=ret[j:l]}}
mwin


#model = (sGARCH, eGARCH, iGARCH)
myspec <- ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1,1)),
                     mean.model = list(armaOrder = c(0,1)))
ret.forecast=1:50
dim(ret.forecast)=c(1,50)
for(t in 1:50){
  garmodel=ugarchfit(spec=myspec,data=mwin[,t],likelihood=TRUE)
  myforecast=ugarchforecast(garmodel,n.ahead=1)
  a = myforecast@forecast
  r1 = a$seriesFor
  #sig1 = a$sigmaFor
  
  ret.forecast[,t]=r1[,1]
}

ret.forecast
z=ret.forecast
y=z[1,]
write.table(y, "C:/", sep="\t")
x=10^y


act=read.csv(file.choose(), header = TRUE, sep = ",")
MSE.garch = sum((act - x)^2)/50


#anngarch
data  = read.csv(file.choose(), header = TRUE, sep = ",")
head(data)

#check missing data
apply(data,2,function(x) sum(is.na(x)))

#split data into train and test set
index = sample(1:nrow(data),round(0.75*nrow(data)))
train = data[index,]
test = data[-index,]
lm.fit = glm(returns~., data=train)
summary(lm.fit)
pr.lm = predict(lm.fit,test)
MSE.lm = sum((pr.lm - test$returns)^2)/nrow(test)

#normalization
maxs = apply(data, 2, max) 
mins = apply(data, 2, min)
scaled = as.data.frame(scale(data, center = mins, scale = maxs - mins))

train_ = scaled[index,]
test_ = scaled[-index,]


#fitting neural net
install.packages("neuralnet", dependencies = TRUE)
library(neuralnet)
n = names(train_)
f = as.formula(paste("returns~", paste(n[!n %in% "returns"], collapse = " + ")))
nn = neuralnet(f,data=train_,hidden=c(5,3),linear.output=TRUE)
summary(nn)
plot(nn)


#predict
pr.nn = compute(nn,test_[,1:3])

pr.nn_ = pr.nn$net.result*(max(data$returns)-min(data$returns))+min(data$returns)
test.r = (test_$returns)*(max(data$returns)-min(data$returns))+min(data$returns)

MSE.nn = sum((test.r - pr.nn_)^2)/nrow(test_)

print(paste(MSE.lm,MSE.nn))