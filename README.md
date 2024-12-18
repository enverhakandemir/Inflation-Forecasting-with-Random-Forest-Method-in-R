# Inflation-Forecasting-with-Random-Forest-Method-in-R
 RF (random forest) is a Blackbox Machine Learning process and it can be used as a non-parametric regression method.  This repository shares an example project for simple inflation forecasting using RF.  It is possible to improve forecasting model with additional inputs.


Overview

This repository contains an R script for forecasting short-term inflation expectations using a Random Forest model. The process involves time series transformation, lag creation, model training, evaluation, and visualization.

The goal of this script is to predict monthly inflation rates using historical inflation data and lagged variables. It employs a machine learning-based Random Forest model to assess the importance of different lagged features (1, 3, and 6 months) in the prediction.

İnstall and Load the required libraries:

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

