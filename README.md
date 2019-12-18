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
By looking at the box whisker plot,  each outlet have few potential outliers. And OUT027 has much higher potential sales outlier data. Also OUT027 has higher average sales compared to other outlets. 
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
```
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

v_selection <- stepAIC(model1, direction = "both", trace = FALSE)

```
I selected following variables in the model based on "stepAIC" function: Item MRP, Location Type Tier, Outlet Size, Outlet Type and years of operation are significant. Besides I add combined item type in the model to distinguish the product type.

## Modeling
With the selection of the variables with high significance, I built a generalized linear regression model and Lasso regression in the training dataset with 3 fold cross validation.
```
control <- trainControl(method = "repeatedcv", number = 10, repeats = 3, savePredictions = TRUE, classProbs = TRUE)
mList <- c('glm','glmnet')

fit_models <- caretList(Item_Outlet_Sales~
                        Combined_Item_Type
                        +Item_MRP
                        +Outlet_Identifier
                        +Outlet_Location_Type
                        +Outlet_Size
                        +Outlet_Type
                        +Years_of_Operation,
                        data = af_train_data,
                        trControl = control, 
                        methodList = mList)
```
The RMSE(Root Mean Square Error)  for generalized linear regression model is 1128.372. And for the glmnet model we have the optimal value for the lowest RMSE is alpha = 1 and lambda = 1.937. With the optimal value for penalty item, I have the RMSE of model equal to 1128.335 which is slightly lower than generalized linear regression model.
```
$glm
Generalized Linear Model 

  RMSE      Rsquared  MAE     
  1128.372  0.563201  837.2549

$glmnet
  alpha  lambda      RMSE      Rsquared   MAE     
  1.00     1.937018  1128.335  0.5632334  836.8594
  1.00    19.370175  1131.297  0.5617536  836.6575
  1.00   193.701751  1252.429  0.4958680  927.8833

RMSE was used to select the optimal model using the smallest 
```
## Prediction
Based on the generalized linear regression and Lasso regression built above, I used prediction function to predict the sales on test data. And I have the RMSE for glm is 1202.0354, and for the glmnet model, I have RMSE equal to 1202.3587. The fitness of two models are very close. However, Lasso model helps to reduce the model complexity and minimize the error for the quantitative response variables. Also it avoids the overfitting issue. So I would still suggest Lasso as the better prediction model.

```
glmnet_model <- caretStack(fit_models, methodList = "glmnet", trControl = trainControl(method = "repeatedcv", number = 10, repeats = 3, savePredictions = TRUE))
glmnet_model

predict_on_test <- predict(glmnet_model, newdata = af_test_data )
Predict_on_test

glm_model <- caretStack(fit_models, method = "glm", trControl = trainControl(method = "repeatedcv", number = 10, repeats = 3, savePredictions = TRUE))
glm_model

predict_on_test2 <- predict(glm_model, newdata = af_test_data )
predict_on_test2
```
## Further Discussion
In the outlier detection section, I used qq plot to distinguish the distribution of the sales data. It's close to exponential distribution. But it has some skewness  and bias, which may influence the accuracy of getOutliers function. In this case, There are some improvements can be made to the outlier detection part. 

Also, in the variable selection, we can figure out a way to combine the outlet identifier properly, which may help to reduce the model complexity and increase the model freedom degree.

## Contact
williamcheng200102@gmail.com

## References
[1]https://datahack.analyticsvidhya.com/contest/practice-problem-big-mart-sales-iii/
[2]https://www.statisticshowto.datasciencecentral.com/lasso-regression/
[3]http://statmath.wu.ac.at/courses/heather_turner/glmCourse_001.pdf
[4]https://towardsdatascience.com/understanding-boxplots-5e2df7bcbd51

