## run_analysis.R
##
## Analysis tool for gathering and shaping data as defined 
## in the Human Activity Recognition Using SmartPhones Data Set
## available at:
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
## This file merges both test and training datasets and returns the mean values
## for a number of measurements for each activity as defined in the included
## readme and Codebook. Please refer to those files for more information.
## Call getData from the working directory that contains the dataset
## in order to retrieve the information in the defined format.

## Extracts a dataset from the filepath and filename defined in filename.
## Assigns the column header values as defined in column names.
extractDataFromFileWithNamedColumns <- function(filename, columnNames) {
  fileData <- read.table(filename)
  names(fileData) <- columnNames
  
  fileData
}

## Extracts a dataset from the filepath and filename defined in filename.
## Extracts a list of column names from the file defined in columnHeaderFile.
## Assigns the column header values defined in the columnHeaderFile to the dataset.
extractDataFromFileWithColumnHeaderFile <- function(filename, columnHeaderFile) {
  columnData <- read.table(columnHeaderFile)
  primaryData <- extractDataFromFileWithNamedColumns(filename, columnData$V2)
  
  primaryData
}

## Extracts a dataset from the filepath and filename defined in filename.
## Extracts a list of value/pair keys that translates the numeric data into a 
## human readable format. Performs the translation on the dataset to convert
## all numeric data into the mapped text values defined in valueKeyFile
extractDataFromFileWithValueKeyFile <- function(dataFile, valueKeyFile, keyRow) {
  primaryData <- read.table(dataFile)
  valueKeyData <- read.table(valueKeyFile)

  translatedData <- mutate(primaryData, ActivityName=factor(V1, labels = valueKeyData[,keyRow]))
  
  select(translatedData, ActivityName)
}

## Gathers data from a subfolder as defined in the data package
## The subfolder variable defines the name of the subfolder where the data resides.
gatherDataFromSubfolder <- function(subfolder) {
  ## Gather subject information into a column based form to be merged with the dataset
  sData <- extractDataFromFileWithNamedColumns(paste(subfolder,"/subject_", subfolder, ".txt", sep = ""), c("SubjectId"))

  ## Extract all columns of data and from the X dataset.
  ## Extracts column names from the defined features file and attaches them to the
  ## appropriate column.
  xData <- extractDataFromFileWithColumnHeaderFile(paste(subfolder,"/X_", subfolder, ".txt", sep = ""), "features.txt")
  
  ## Clean up our data and formatting. Feel free to modify to suit your needs.
  ## In it's current form, this gathers both time and frequency variables that
  ## contain mean and std data.
  columnKeep <- grep("^[t|f].*(std\\(|mean\\()", names(xData))
  xData <- xData[,columnKeep]
  names(xData) <- gsub("-", "", names(xData))
  names(xData) <- gsub("\\(\\)", "", names(xData))
  names(xData) <- gsub("mean", "Mean", names(xData))
  names(xData) <- gsub("std", "Std", names(xData))
  names(xData) <- gsub("^t", "Time", names(xData))
  names(xData) <- gsub("^f", "Freq", names(xData))
  
  ## Gather our activity data and translate the values into
  ## their text equivalents as defined in activity_labels.txt
  yData <- extractDataFromFileWithValueKeyFile(paste(subfolder,"/Y_", subfolder, ".txt", sep = ""), "activity_labels.txt", 2)
  subfolderData <- cbind(sData, yData)
  subfolderData <- cbind(subfolderData, xData)
  
  subfolderData
}

## Extracts data from the Human Activity Recognition Using SmartPhones Dataset.
## See the included readme and codebook for more information.
getData <- function() {
  library("plyr")
  library("dplyr")
  library("reshape2")
  
  ## Gather the data we want from each of the subfolders
  testData <- gatherDataFromSubfolder("test")
  trainData <- gatherDataFromSubfolder("train")
  
  ## Merge our test and train datasets
  mergedData <- rbind(testData, trainData)
  ## Convert our data to have a single variable observation per row
  mergedDataNames <- names(mergedData)
  lengthNames <- length(mergedDataNames)
  longData <- melt(mergedData, id=mergedDataNames[1:2], measure.vars=mergedDataNames[3:lengthNames], variable.name = "Measurement")
 
  ## Calculate the mean of each variable grouped by Subject and Activity
  meanData <- ddply(longData, .(SubjectId, ActivityName, Measurement), summarize, Mean = (mean(value)))
  
  meanData
}
