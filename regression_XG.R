


# Set working directory
setwd(dir = "D:/Academic/IIT KGP/Time Series/project")

# Load and explore the dataset
data <- read.csv("reg1.csv", header = TRUE)
str(data)
summary(data)
colnames(data)
colnames(data)[2] <- "target"

data['X']
# Check the features
#install.packages("corrplot")
library(corrplot)
corrplot.mixed(cor(data[,-c(1,2)]))
corrplot(cor(data[,-c(1,5)]), order ="hclust") #Hierarchial clustering
# What does hierarchial clustering mean?

str(data)

data$day <- as.factor(data$day)
data$month <- as.factor(data$month)
data$hour <- as.factor(data$hour)
data$year <- as.factor(data$year)

# First Model (FULL)
lmFit1 <- lm(formula = log(target) ~ . -(X), data = data)
summary(lmFit1)




# Check for heteroskedasticity
# install.packages("car")
library(car)
ncvTest(lmFit1) #p-value is 0 implies hetroscadasticity is present

data['log_target'] = log(data['target'])
lmFit2 <- lm(formula = target ~ . -(X+log_target), data = data)
summary(lmFit2)
plot(lmFit2)


library(xgboost)
library(Matrix)



dtrain = sparse.model.matrix(log(target)~.,data = (data[,-c(1,5)]), missing = NA)

head(dtrain)

xgtrain = xgb.DMatrix(dtrain, label = log(data$target))

set.seed(69)

params = list( booster = 'gbtree',max_depth = 6, subsample = 1,
               colsample_bytree = 1, eta = 0.005, lambda = 0.001,alpha = 0.01)


cv1 = xgb.cv(params = params,data = xgtrain, showsd = TRUE, metrics = list('rmse'),
             obj = NULL, nrounds = 2000,nfold = 4,
             feval = NULL, stratified = TRUE, folds = NULL, verbose = TRUE,
             print_every_n = 1L, early_stopping_rounds = 50, maximize = NULL)



cv2 = xgboost(params = params,data = xgtrain, showsd = TRUE, metrics = list('rmse'), 
              obj = NULL, nrounds = 2000,nfold = 4,
              feval = NULL, stratified = TRUE, folds = NULL, verbose = TRUE,
              print_every_n = 1L, early_stopping_rounds = NULL, maximize = NULL)


p = predict(cv2, newdata = xgtrain)

return_data$p = p

qplot(p, data$target)




dtest = sparse.model.matrix(~.,data = (test_data_2), missing = NA)

head(dtest)

xgtest = xgb.DMatrix(dtest)

test_data$return = predict(cv2, newdata = xgtest)

test_data$return = format(round(test_data$return, digits = 6) )

p = as.numeric(format(round(p,digits = 6)))

submit = test_data[,c(1,18)]

write.csv(submit, "default-sub_xgb.csv", row.names = FALSE)


# ========================================
# One-hot encoding of dataset for boosting
# ========================================
library(Matrix)
dtrain_one_hc <- model.matrix(target ~  month+1 +day+1,
                              data = data) %>% 
  data.frame(load = data$target, .)

