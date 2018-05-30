#run_analysis.R

library(data.table)
library(reshape2)

setwd("./")

## get datapacket

link <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
datapacket <- "getdata_dataset.zip"

if (!file.exists(datapacket)){
  download.file(link, datapacket, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(datapacket) 
}


# load training and testing data

x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subjects_test <- read.table("UCI HAR Dataset/test/subject_test.txt")


# Get Feature list
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])
filterindex <- grep(".*mean.*|.*std.*", features[,2])
featuresfiltered <- features[filterindex,2]
featuresfiltered = gsub('-mean', 'Mean', featuresfiltered)
featuresfiltered = gsub('-std', 'Std', featuresfiltered)
featuresfiltered <- gsub('[-()]', '', featuresfiltered)

# get Activities
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity[,2] <- as.character(activity[,2])


# transform

master <- rbind(cbind(subjects, y_train, x_train[filterindex]), cbind(subjects_test, y_test, x_test[filterindex]))
colnames(master) <- c("subject", "activity", featuresfiltered)
master$activity <- factor(master$activity, levels = activity[,1], labels = activity[,2])
master$subject <- as.factor(master$subject)
master_trans <- melt(master, id = c("subject", "activity"))
avg <- dcast(master_trans, subject + activity ~ variable, mean)

fwrite(avg, "tidy.txt", row.names = FALSE, quote = FALSE)
