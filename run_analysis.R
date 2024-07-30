# assume 'UCI HAR Dataset' directory is relative to working directory
#otherwise setwd()
setwd('/home/jjw/src/coursera/getting_and_cleaning_data')
library(data.table)
#load features and activity labels
activityLabels <- fread(file.path("UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path("UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)
measurements <- gsub('[()]', '', measurements)
# load training set
train <- fread(file.path("UCI HAR Dataset","train","X_train.txt"))
train <- train[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path("UCI HAR Dataset","train","y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path("UCI HAR Dataset","train","subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)
# load test set
test <- fread(file.path("UCI HAR Dataset", "test","X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path("UCI HAR Dataset","test","y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path("UCI HAR Dataset","test","subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)
# merge datasets and add labels
combined <- rbind(train, test)
# Convert classLabels to activityName basically. More explicit. 
combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])
combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.csv", quote = FALSE)
