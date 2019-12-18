# Big Mart Sales Prediction 
The generalized linear regression is a flexible generalization of ordinary linear regression that allows for response variables that have error distribution models other than a normal distribution. Lasso regression which is the generalized linear regression via penalized maximum likelihood can avoid the overfitting issue and help in selecting variables. Lasso regression uses shrinkage, where data values are shrunk towards a central point. This project will demonstrate how generalized linear regression and generalized Lasso regression perform in big mart sales prediction.

## Data Overview
The data scientists at BigMart have collected 2013 sales data for 1559 products across 10 stores in different cities. Also, certain attributes of each product and store have been defined. The aim is to build a predictive model and find out the sales of each product at a particular store.[1] Below are the variables and its corresponding descriptions. We will use the variable name in the following paper.

## Materials and Methodology
For this research project, R is the programming language that has been
used. In the coding it is data analysis libraries that makes the coding
efficient.
● Outliers
● Stats
● Caret
● Extremevalues
● Corrplot
● MASS
● CaretEnsemble

## Data Cleaning
* Missing Data
There are some missing data for Item weight and Item visibility in the mart. Missing data imputation methodology can be performed for those sets.

* Data Correction
For the Item Fat Content we realized that there are typos in this section, where it marked “Low Fat” as “LF” and “low fat”; and marked “Regular” as “reg”. In order to solve this problem I found out all the “LF/low fat”and “reg” and replaced them with “Low Fat” and “Regular”. And then I replaced the item fact content for item type “Health and Hygiene,Household, and Others“ with “NA” since they are not food and drink.

* Data Transformation
I used the year operation instead of establishment year ( 2013 -Outlet_Establishment_Year) , which can be used as a numeric variable in the model.

## Outlier
I used histogram and qq plot to check the distribution of the sales data and then found that it was close to exponential distribtuion. So I used GetOutlier function in R to check the outliers. 
![Image of exponential](https://github.com/williamcheng200102/Big-Mart-Sales/blob/master/Image/exponential%20qq%20plot.jpg)

## Variable Selection

## Modeling

## Prediction



