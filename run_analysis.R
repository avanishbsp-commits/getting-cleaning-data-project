# ==============================
# Getting and Cleaning Data Project
# ==============================

library(dplyr)

# Download dataset if not present
if(!file.exists("dataset.zip")) {
  download.file(
    "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
    destfile = "dataset.zip"
  )
  unzip("dataset.zip")
}

# Read files
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)

X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

# Assign column names
colnames(X_train) <- features$V2
colnames(X_test) <- features$V2
colnames(y_train) <- "Activity"
colnames(y_test) <- "Activity"
colnames(subject_train) <- "Subject"
colnames(subject_test) <- "Subject"

# Merge data
train <- cbind(subject_train, y_train, X_train)
test <- cbind(subject_test, y_test, X_test)
data <- rbind(train, test)

# Extract mean and std
data <- data %>%
  select(Subject, Activity, contains("mean"), contains("std"))

# Add activity names
data$Activity <- factor(data$Activity,
                        levels = activity_labels$V1,
                        labels = activity_labels$V2)

# Clean variable names
names(data) <- gsub("\\()", "", names(data))
names(data) <- gsub("-", "_", names(data))
names(data) <- gsub("^t", "Time", names(data))
names(data) <- gsub("^f", "Frequency", names(data))
names(data) <- gsub("Acc", "Acceleration", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))

# Create tidy dataset
tidy_data <- data %>%
  group_by(Subject, Activity) %>%
  summarise(across(everything(), mean), .groups = "drop")

# Save output
write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
