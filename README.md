# Inflation-Forecasting-with-Random-Forest-Method-in-R
### RF (random forest) is a Blackbox Machine Learning process and it can be used as a non-parametric regression method.  This repository shares an example project for simple inflation forecasting using RF.  It is possible to improve forecasting model with additional inputs.

## Overview

This repository contains an R script for forecasting short-term inflation expectations using a Random Forest model. The process involves time series transformation, lag creation, model training, evaluation, and visualization.
The goal of this script is to predict monthly inflation rates using historical inflation data and lagged variables. It employs a machine learning-based Random Forest model to assess the importance of different lagged features (1, 3, and 6 months) in the prediction.

## İnstall and Load the required libraries:

```R
###### Load required libraries #######
#to read excel (xlsx) files: 
install.packages("readxl")
library(readxl)
#DPYLR: Grammar of DataManupilation
install.packages("dplyr")
library(dplyr)
#Required library for ggplot function: ggplot2
install.packages("ggplot2")
library(ggplot2)
#required library for lattice(TR:kafes) graph drawing: lattice
install.packages("lattice")
library(lattice)
#The required library to use the "createDataPartition" function: caret
install.packages("caret")
library(caret)
#Since we will build Prediction model with randomforest, we need it:
install.packages("randomForest")
library(randomForest)
#Since we will be dealing with a time series data:
install.packages("tseries")
library(tseries)
#To determine the appropriate number of lags: vars library
install.packages("vars")
library(vars)
```
## Dataset
Name: enftahmintam.xlsx
Description: This dataset contains historical monthly inflation rates.
Columns:
ayenf: Monthly inflation rate
Additional columns created during the script (e.g., lagged values).

```R
##### LOADING DATA ####
enftahmintam <- read_excel("enftahmintam.xlsx")
View(enftahmintam)
```
Data spans from January 2005 to November 2024 with monthly frequency.


## Getting Down to Work

### 1. Loading Libraries and Data
The script loads all necessary libraries and reads the Excel dataset.

```R
enftahmintam <- read_excel("enftahmintam.xlsx")
View(enftahmintam)
```

### 2. Time Series Preparation
Convert the inflation column ayenf to a time series format for analysis.
```R
ayenfts <- ts(enftahmintam$ayenf, start = c(2005, 1), end = c(2024, 11), frequency = 12) #be sure that start date and frequency are ok.
```
### 3. Lagged Variable Selection and Creation
Lags of 1, 3, and 6 months are generated using the dplyr package.
But the first step is to choose the appropriate number of lags:

```R
#Learning the appropriate number of lags
VARselect(ayenfts, lag.max = 12, type = "const") # 6 lag
VARselect(ayenfts, lag.max = 6, type = "const")  # 6 lag
VARselect(ayenfts, lag.max = 3, type = "const")  # 3 lag
VARselect(ayenfts, lag.max = 2, type = "const")  # 1 lag [Actually, we don't need to take 1 lag, +++
#(continue) but it would be better to take it according to the theoretical background (short-term inflation expectations).]
```
```R
## Create lagged variables: 1-3-6 
enftahmintam <- enftahmintam %>% mutate(lag_1 = lag(ayenf, 1), lag_3 = lag(ayenf, 3), lag_6 = lag(ayenf,6) )
# Remove the first 6 rows (due to missing lagged values)
data <- enftahmintam[-(1:6),]
```

Now we define lagged variables as a time series:
```R
lag_1ts <- ts(data$lag_1, start = c(2005, 7), end = c(2024, 11), frequency = 12) 
lag_3ts <- ts(data$lag_3, start = c(2005, 7), end = c(2024, 11), frequency = 12) 
lag_6ts <- ts(data$lag_6, start = c(2005, 7), end = c(2024, 11), frequency = 12) 
```

### To make ayenfts starting from 2005-07 not 2005-01:
```R
drop(ayenfts)  #this argument drop(varx) shows us the time series variable as table. 
rm(ayenfts)
ayenfts <- ts(data$ayenf, start = c(2005, 7), end = c(2024, 11), frequency = 12) 
```

### Merging time series variables as a data before data splitting:

```R
trainenf_data <- data.frame(ayenf = ayenfts, lag_1ts, lag_3ts, lag_6ts)
```

### 4. Training and Test Split
The dataset is split into 80% training and 20% testing sets.
```R
# Separating training and test data sets:
train_size <- floor(0.8 * nrow(trainenf_data))
train_data <- trainenf_data[1:train_size, ]
test_data <- trainenf_data[(train_size + 1):nrow(trainenf_data), ]
```

### 5. Model Training: Random Forest
Train a Random Forest model using caret & train().
```R
# Modelling (Random Forest = rf)
model <- train(
  ayenf ~ lag_1ts + lag_3ts + lag_6ts, 
  data = train_data, 
  method = "rf", 
  trControl = trainControl(method = "cv", number = 5)
)
```
### 6. Performance Evaluation
Predict inflation rates on the test dataset and calculate the Mean Absolute Error (MAE).

```R
# Prediction 
predictions <- predict(model, test_data)
# Performance assessment: we compare with test data
mae <- mean(abs(predictions - test_data$ayenf)) 
drop(mae)
#What happened on the top line:
# 1-abs calculates error in parentheses expression when taking absolute value.
# 2-The absolute differences are averaged. This average is called the Mean Absolute Error (MAE).
# ADD: # APPENDIX: MAE is a metric that measures how much, on average, the predicted values deviate from the true values.
```

### 7. Visualization
Compare actual vs. predicted values using a line chart:
```R
library(ggplot2) # Load ggplot2 package now, if you did not call it above.
results <- test_data %>%
  mutate(
    time = time(ayenfts)[(train_size + 1):length(ayenfts)],  # Zaman bilgisi
    predicted = predictions
  )

ggplot(results, aes(x = time)) +
  geom_line(aes(y = ayenf, color = "Actual")) +  # Actual/Realized  data
  geom_line(aes(y = predicted, color = "Predicted")) +  # Predicted values
  scale_color_manual(values = c("Actual" = "blue", "Predicted" = "red")) +  # Color settings
  labs(
    title = "Inflation Forecast: Actual and Forecast Values",
    x = "Time",
    y = "Inflation Rate",
    color = "Seri"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),  # Centering the header
    legend.position = "bottom"  # Legend positioning
  )
```

## An Important Reminder 
In the RandomForest model we cannot see the coefficients directly -Since RF is a non-parametric black-box technique. However, we can analyze how much importance the model gives to which variables.
VarImp helps to understand how much the variables contribute to the prediction.
```R
varImp <- varImp(model)
print(varImp) #The most important lag is 3.
plot(varImp, main = "Lag Variables Importance Graph - RandomForest Method")
```

