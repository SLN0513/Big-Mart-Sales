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