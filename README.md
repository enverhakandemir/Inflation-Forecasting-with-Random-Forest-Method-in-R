# Inflation-Forecasting-with-Random-Forest-Method-in-R
 RF (random forest) is a Blackbox Machine Learning process and it can be used as a non-parametric regression method.  This repository shares an example project for simple inflation forecasting using RF.  It is possible to improve forecasting model with additional inputs.


Overview

This repository contains an R script for forecasting short-term inflation expectations using a Random Forest model. The process involves time series transformation, lag creation, model training, evaluation, and visualization.

The goal of this script is to predict monthly inflation rates using historical inflation data and lagged variables. It employs a machine learning-based Random Forest model to assess the importance of different lagged features (1, 3, and 6 months) in the prediction.

 install.packages(c("readxl", "dplyr", "ggplot2", "lattice", "caret", "randomForest", "tseries", "vars"))

```
install.packages(c("readxl", "dplyr", "ggplot2", "lattice", "caret", "randomForest", "tseries", "vars"))
```
