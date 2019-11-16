rm(list = ls()) #clean the enviromemnt

#read data 
train <- read.csv("Train_data.csv", stringsAsFactors = FALSE, header = TRUE)
test  <- read.csv("Test_data.csv", stringsAsFactors = FALSE, header = TRUE)

test[,'Item_Outlet_Sales'] <- NA
tot_data_initial <- rbind(train, test) #combine train data and test data
tot_data <- tot_data_initial #crate the copy 

#description
summary(tot_data)
colSums(is.na(tot_data) | tot_data == "")

distinct_value <- lapply(tot_data, unique) # finding the distinct value of every column
distinct_value[3] # ***
distinct_value[9]#out_let size ****
distinct_value[7:11] 
distinct_value_len <- lengths(distinct_value) 
distinct_value_len #count the distinct value of every column

####################STEP 1. Data Cleaning 
########## column - Item_weight clean up - imputing missing data
k <- nrow(tot_data) 

library(hash)
item <- hash()
for (i in 1:k)
{
  if (!(is.na(tot_data$Item_Weight[i])))
    item[[tot_data$Item_Identifier[i]]] <- tot_data$Item_Weight[i] #dictionary
}

average_weight = mean(tot_data$Item_Weight, na.rm = TRUE)

temp <- c()
before <- summary(is.na(tot_data$Item_Weight))
before

for (i in 1:k)
{
  if ((is.na(tot_data$Item_Weight[i])) & (length(item[[tot_data$Item_Identifier[i]]])!=0)) #case 1,in dic
     {tot_data$Item_Weight[i] <- item[[tot_data$Item_Identifier[i]]]}
  
  if ((is.na(tot_data$Item_Weight[i])) & (length(item[[tot_data$Item_Identifier[i]]])==0)) #case 2, not in dic
     {temp<-c(temp,tot_data$Item_Identifier[i])
      tot_data$Item_Weight[i] <- average_weight} #replace with average value
}

after <- summary(is.na(tot_data$Item_Weight))
after

###### outlet_size column missing data imputation
distinct_value[9]

as.data.frame(table(tot_data$Outlet_Size)) #count each value before the imputation

getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v,uniqv)))]
} 

outsize_mode <- getmode(tot_data$Outlet_Size)
outsize_mode #find the mode of outlet_size column :"medium"

# imputing the missing data with "medium"
tot_data$Outlet_Size[which(tot_data$Outlet_Size=="")]<- "Medium"

as.data.frame(table(tot_data$Outlet_Size)) ##count each value after the imputation


###### value replacemnt for Iterm_Fat_Content column###########
distinct_value[3]
as.data.frame(table(tot_data$Item_Fat_Content)) #take a look before the followimg implementation

tot_data$Item_Fat_Content[which(tot_data$Item_Fat_Content == "LF" | tot_data$Item_Fat_Content == "low fat")] <- "Low Fat"
tot_data$Item_Fat_Content[which(tot_data$Item_Fat_Content == "reg")] <- "Regular"

tot_data[ which(tot_data$Item_Type == "Health and Hygiene") ,]$Item_Fat_Content <- "None"
tot_data[ which(tot_data$Item_Type == "Household") ,]$Item_Fat_Content <- "None"
tot_data[ which(tot_data$Item_Type == "Others") ,]$Item_Fat_Content <- "None"

as.data.frame(table(tot_data$Item_Fat_Content)) #check

###### item_visibility column 0 value correction
summary(tot_data$Item_Visibility)
tot_data$Item_Visibility[which(tot_data$Item_Visibility == 0)] <- NA
library(dplyr)


average_v <- tot_data %>%
             group_by(Item_Identifier) %>%
             summarize(mean_visibility = mean(Item_Visibility, na.rm = TRUE)) #mean_visibility dictionary for each product

for (i in  1:k){
  if (is.na(tot_data$Item_Visibility[i]))
     tot_data$Item_Visibility[i] <- average_v$mean_visibility[which(average_v$Item_Identifier == tot_data$Item_Identifier[i])]
}


###### create a column standing for the years of operation
tot_data[,"Years_of_Operation"] <- (2013 - tot_data$Outlet_Establishment_Year)

####### combine item tpye
distinct_value[5]
tot_data[,"Combined_Item_Type"] <- substr(tot_data$Item_Identifier,1,2)
as.data.frame(table(tot_data$Combined_Item_Type))
type_table <- distinct_at(tot_data, vars(Item_Type,Combined_Item_Type))
tot_data$Combined_Item_Type[which(tot_data$Combined_Item_Type=="FD")]<- "Food"
tot_data$Combined_Item_Type[which(tot_data$Combined_Item_Type=="DR")]<- "Drink"
tot_data$Combined_Item_Type[which(tot_data$Combined_Item_Type=="NC")]<- "Non-Consumable"

##############STEP 2. Outlier#########################
af_test_data <- tot_data %>% filter(is.na(Item_Outlet_Sales))  #test data set
af_train_data <- tot_data %>% filter(!is.na(Item_Outlet_Sales))#train data set

hist(af_train_data$Item_Outlet_Sales) #not normal distributied
qqnorm(af_train_data$Item_Outlet_Sales)

boxplot(af_train_data$Item_Outlet_Sales)

library(caret)
ggplot(af_train_data, aes(x = Outlet_Identifier,
                       y = Item_Outlet_Sales)) +
  geom_boxplot() +
  labs(title = "Sales by Outlet Identifier",
       x = "Outlet Identifier",
       y = "Item Outlet Sales") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) #overview of the potential outlier


qqplot(qexp(ppoints(length(af_train_data$Item_Outlet_Sales))), af_train_data$Item_Outlet_Sales) #check whether sales column is exponential distirbuted

library(extremevalues)
getOutliers(af_train_data$Item_Outlet_Sales, distribution = 'exponential')


###################step 3 variable selection#########
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



