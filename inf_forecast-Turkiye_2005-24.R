# Clear all previous variables to avoid errors 
rm(list=ls()) 


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

##### LOADING DATA ####
enftahmintam <- read_excel("C:/Users/hdemi/OneDrive/Desktop/R_enf_Tahminlemesi/enftahmintam.xlsx")
View(enftahmintam)

# Convert to time series format. Otherwise we cannot find the appropriate lag interval.
ayenfts <- ts(enftahmintam$ayenf, start = c(2005, 1), end = c(2024, 11), frequency = 12) #be sure that start date and frequency are ok.

#Learning the appropriate number of lags
VARselect(ayenfts, lag.max = 12, type = "const") # 6 lag
VARselect(ayenfts, lag.max = 6, type = "const")  # 6 lag
VARselect(ayenfts, lag.max = 3, type = "const")  # 3 lag
VARselect(ayenfts, lag.max = 2, type = "const")  # 1 lag [Actually, we don't need to take 1 lag, +++
#(continue) but it would be better to take it according to the theoretical background (short-term inflation expectations).]


## Create lagged variables: 1-3-6 
enftahmintam <- enftahmintam %>% mutate(lag_1 = lag(ayenf, 1), lag_3 = lag(ayenf, 3), lag_6 = lag(ayenf,6) )
# Remove the first 6 rows (due to missing lagged values)
data <- enftahmintam[-(1:6),]

## We need to introduce lags as time-series.
# Convert to time series format
lag_1ts <- ts(data$lag_1, start = c(2005, 7), end = c(2024, 11), frequency = 12) 
lag_3ts <- ts(data$lag_3, start = c(2005, 7), end = c(2024, 11), frequency = 12) 
lag_6ts <- ts(data$lag_6, start = c(2005, 7), end = c(2024, 11), frequency = 12) 
# make ayenfts starting from 2005-07 not 2005-01:
drop(ayenfts)  #this argument drop(varx) shows us the time series variable as table. 
rm(ayenfts)
ayenfts <- ts(data$ayenf, start = c(2005, 7), end = c(2024, 11), frequency = 12) 

# Merge time series variables as a data.
trainenf_data <- data.frame(ayenf = ayenfts, lag_1ts, lag_3ts, lag_6ts)

# Separating training and test data sets:
train_size <- floor(0.8 * nrow(trainenf_data))
train_data <- trainenf_data[1:train_size, ]
test_data <- trainenf_data[(train_size + 1):nrow(trainenf_data), ]

# Modelling (Random Forest = rf)
model <- train(
  ayenf ~ lag_1ts + lag_3ts + lag_6ts, 
  data = train_data, 
  method = "rf", 
  trControl = trainControl(method = "cv", number = 5)
)

# Prediction 
predictions <- predict(model, test_data)

# Performance assessment: we compare with test data
mae <- mean(abs(predictions - test_data$ayenf)) 
drop(mae)
#What happened on the top line:
# 1-abs calculates error in parentheses expression when taking absolute value.
# 2-The absolute differences are averaged. This average is called the Mean Absolute Error (MAE).
# ADD: # APPENDIX: MAE is a metric that measures how much, on average, the predicted values deviate from the true values.

#####  Visualization  #####
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



##### An Important Reminder #####
# In the RandomForest model we cannot see the coefficients directly -Since RF is a non-parametric black-box technique-  ++
#++ however, we can analyze how much importance the model gives to which variables.
# VarImp helps to understand how much the variables contribute to the prediction.
varImp <- varImp(model)
print(varImp) #The most important lag is 3.
plot(varImp, main = "Lag Variables Importance Graph - RandomForest Method")


######SONUC DEDERLENDD0RME####
#TCD0K verilerinegC6re AralD1k ayD1 %2,91 gelirse 2024 yD1llD1k enflasyonu %47,06 oluyor!
#TCMB Enf. Raporu IV enf. beklentisinin orta noktasD1; %44 iken C<st sD1nD1r %46 olarak aC'D1klandD1 8 KasD1m 2024'te. 

