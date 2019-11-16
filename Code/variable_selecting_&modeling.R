###################step 3 variable selection#########
rm(list = ls()) #clean the enviromemnt

#read data 
train <- read.csv("Train_data.csv", stringsAsFactors = FALSE, header = TRUE)
test  <- read.csv("Test_data.csv", stringsAsFactors = FALSE, header = TRUE)

test[,'Item_Outlet_Sales'] <- NA
tot_data_initial <- rbind(train, test) #combine train data and test data
tot_data <- tot_data_initial #crate the copy 
##########correlation matrix###############
library(corrplot)
corMatrix <- cor(af_train_data[1:nrow(af_train_data),][sapply(af_train_data[1:nrow(af_train_data),], is.numeric)])
corMatrix

# a brief overview of the correlation matrix
corrplot(corMatrix, method="number", type="upper",addCoef.col = "grey")

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

library(MASS)
v_selection <- stepAIC(model1, direction = "both", trace = FALSE)
summary(v_selection)

#modeling

library(caretEnsemble)
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
fit_models

#####
glmnet_model <- caretStack(fit_models, method = "glmnet", trControl = trainControl(method = "repeatedcv", number = 10, repeats = 3, savePredictions = TRUE))
glmnet_model
predict_on_test <- predict(glmnet_model, newdata = af_test_data)
predict_on_test

ls("package:MASS")
df <- dplyr::select(af_test_data, Item_Identifier, Outlet_Identifier)
df <- cbind(df, predict_on_test)
names(df)[3] <- "Item_Outlet_Sales"

write.table(df, "results_glm.csv", quote = FALSE, sep=",", row.names = FALSE)

#####glm
glm_model <- caretStack(fit_models, method = "glm", trControl = trainControl(method = "repeatedcv", number = 10, repeats = 3, savePredictions = TRUE))
glm_model

predict_on_test2 <- predict(glm_model, newdata = af_test_data )
predict_on_test2
df2 <- dplyr::select(af_test_data, Item_Identifier, Outlet_Identifier)
df2 <- cbind(df2, predict_on_test2)
names(df2)[3] <- "Item_Outlet_Sales"

write.table(df2, "results_glmnet.csv", quote = FALSE, sep=",", row.names = FALSE)



