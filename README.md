# Big Mart Sales Prediction 
The generalized linear regression is a flexible generalization of ordinary linear regression that allows for response variables that have error distribution models other than a normal distribution. Lasso regression which is the generalized linear regression via penalized maximum likelihood can avoid the overfitting issue and help in selecting variables. Lasso regression uses shrinkage, where data values are shrunk towards a central point. This project will demonstrate how generalized linear regression and generalized Lasso regression perform in big mart sales prediction.

## Data Overview
The data scientists at BigMart have collected 2013 sales data for 1559 products across 10 stores in different cities. Also, certain attributes of each product and store have been defined. The aim is to build a predictive model and find out the sales of each product at a particular store.

## Materials and Methodology
For this research project, R is the programming language that has been
used. In the coding it is data analysis libraries that makes the coding
efficient.
* Outliers
* Stats
* Caret
* Extremevalues
* Corrplot
* MASS
* CaretEnsemble

## Data Cleaning
1. Missing Data:
There are some missing data for Item weight and Item visibility in the mart. Missing data imputation methodology can be performed for those sets.

1. Data Correction:
For the Item Fat Content we realized that there are typos in this section, where it marked “Low Fat” as “LF” and “low fat”; and marked “Regular” as “reg”. In order to solve this problem I found out all the “LF/low fat”and “reg” and replaced them with “Low Fat” and “Regular”. And then I replaced the item fact content for item type “Health and Hygiene,Household, and Others“ with “NA” since they are not food and drink.

1. Data Transformation:
I used the year operation instead of establishment year ( 2013 -Outlet_Establishment_Year) , which can be used as a numeric variable in the model.

## Outlier
I used histogram and qq plot to check the distribution of the sales data and then found that it was close to exponential distribtuion. 

![Image of histogram](https://github.com/williamcheng200102/Big-Mart-Sales/blob/master/Image/sales_diagram.jpg) ![Image of exponential](https://github.com/williamcheng200102/Big-Mart-Sales/blob/master/Image/exponential%20qq%20plot.jpg)
![Image of boxplot](https://github.com/williamcheng200102/Big-Mart-Sales/blob/master/Image/boxplot.jpg)

And I used getOutlier in R to test the outliers which give use the results saying there is no outlier. So we don’t need to remove any outliers here according to getOutliers tool.

**getOutliers(af_train_data$Item_Outlet_Sales, distribution = 'exponential')**

Below are the results from the getOutlier function performed above. 

**getOutliers:**
 Left Right 
    0     0 

## Variable Selection
I used correaltion matirx to check the correaltion between varialbes and found there are no correlation among variables. Then I used "stepwise" variable selectuon to select variables.
stepwise variable selection | 
------------ | 
model1 <- glm(Item_Outlet_Sales~
              Item_Weight
              +Item_Fat_Content
              +Item_Visibility
              +Combined_Item_Type
              +Item_MRP
              +Outlet_Location_Type
              +Outlet_Size
              +Outlet_Type
              +Years_of_Operation,
              data = af_train_data) 
              v_selection <- stepAIC(model1, direction = "both", trace = FALSE)| 





## Modeling

## Prediction



