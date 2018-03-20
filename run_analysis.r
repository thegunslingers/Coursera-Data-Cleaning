library(dplyr)
library(purrr)
library(data.table)

### Load data
setwd("C:/Users/rodgesc/Documents/R/coursera/getting and cleaning data/project/")
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filename = "UCI HAR Dataset.zip"
folder = "UCI HAR Dataset"
download.file(url, filename)
unzip(filename)
setwd(folder)

### Read Test and Train Data
filenames = list.files(pattern="X_.*.txt", recursive = TRUE)
XTest <-  read.table(filenames[1], stringsAsFactors = FALSE, header = FALSE)
XTrain <-  read.table(filenames[2], stringsAsFactors = FALSE, header = FALSE)

### Read Activity Labels
filenames = list.files(pattern="^y_.*.txt", recursive = TRUE)
TestLabels <-  read.table(filenames[1], stringsAsFactors = FALSE, header = FALSE)
TrainLables <-  read.table(filenames[2], stringsAsFactors = FALSE, header = FALSE)

### Read Subject Labels
filenames = list.files(pattern="^subject_.*.txt", recursive = TRUE)
SubjectTest <-  read.table(filenames[1], stringsAsFactors = FALSE, header = FALSE)
SubjectTrain <-  read.table(filenames[2], stringsAsFactors = FALSE, header = FALSE)

### Read Features
features <- read.table("features.txt", stringsAsFactors = FALSE, header = FALSE)

### Read Activity Labels
activityLables <- read.table("activity_labels.txt", stringsAsFactors = FALSE, header = FALSE)

### Set Test and Train column headers
setnames(XTest,  c(features[[2]]))
setnames(XTrain, c(features[[2]]))

### Append Actitiy indentifier
XTest  <- bind_cols(XTest, TestLabels)
XTrain <- bind_cols(XTrain, TrainLables)

### Set Test and Train activity column header
setnames(XTest,  old=562, new=('activitynum'))
setnames(XTrain, old=562, new='activitynum')

### Append Subject id
XTest  <- bind_cols(XTest, SubjectTest)
XTrain <- bind_cols(XTrain, SubjectTrain)

### Set Subject ID column header
setnames(XTest,  old=563, new=('subjectid'))
setnames(XTrain, old=563, new='subjectid')

### Set Activitylabels column header
setnames(activityLables, c("activitynum", "activitylabel"))

### Join on activity name
XTest  <- left_join(XTest, activityLables, by="activitynum" )
XTrain <- left_join(XTrain, activityLables, by="activitynum" )

FullDataset <- union(XTest, XTrain)

### Subset data to only include cols with activity labels, subjectid, mean(), and std()
SubsetData <- select(FullDataset, matches("mean\\(\\)|std\\(\\)|activitylabel|subjectid"))


### Create second indpendant data set with avg of each variable for each activity by subject
SubsetData %>% group_by(subjectid, activitylabel) %>% summarise_at(vars(matches("mean\\(\\)|std\\(\\)")), list(mean)) %>% write.table("tidydata.csv", row.names = FALSE)


