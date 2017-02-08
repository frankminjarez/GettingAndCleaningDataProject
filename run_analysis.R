## 1) Merges the training and the test sets to create one data set.
##
## 2) Extracts only the measurements on the mean and standard deviation for 
## each measurement.
##
## 3) Uses descriptive activity names to name the activities in the data set
##
## 4) Appropriately labels the data set with descriptive variable names.
##
## 5) From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.

## plyr: the split-apply-combine paradigm for R.
library(plyr)

## Set working directory to git project
setwd("~/GettingAndCleaningDataProject")

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile <- "dataset.zip"

## Download and unzip the dataset:
if (!file.exists(destfile)){
        download.file(url, destfile, method="curl")
}  

if (!file.exists("UCI HAR Dataset")) { 
        unzip(destfile) 
}

## load activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
names(activity_labels) <- c("level","label")

## load features and subset data on mean and standard deviation
features <- read.table("UCI HAR Dataset/features.txt")
featuresMeanStd <- grep(".*mean.*|.*std.*", features[,2])
features <- features[featuresMeanStd,]

## Tidy labels (making these all lower case is ridiculous so embrace camel 
## caps)
features[,2] <- sub("mean","Mean",features[,2])
features[,2] <- sub("std","Std",features[,2])
tidyFeatureNames <- gsub("[-()]","",features[,2])

## Load train and test datasets extracting only the measurements on the mean 
## and standard deviation for each measurement.

# load the train dataset
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresMeanStd]
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(subject_train, y_train, x_train)

# load the test dataset
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresMeanStd]
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(subject_test, y_test, x_test)

# merge train and test datasets and add labels
tidyData <- rbind(train, test)
colnames(tidyData) <- c("subject", "activity", tidyFeatureNames)

# Add descriptive activity names to the data set
# Change activity and subject to factors
tidyData$activity <- factor(tidyData$activity, 
                           levels = activity_labels$level, 
                           labels = activity_labels$label)
tidyData$subject <- as.factor(tidyData$subject)

# Take the mean of all rows subject + activity
tidyData <- ddply(tidyData, .(subject, activity), numcolwise(mean))

# Save the tidy data to tidy.txt
write.table(tidyData, "tidy.txt", row.names = FALSE, quote = FALSE)