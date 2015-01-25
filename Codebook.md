# Codebook for Getting and Cleaning Data Course Project

The included R file run_analysis.R provides an alternate, aggregated view of the dataset included in the UCI Human Activity Recognition Using Smartphones study. More information about the study can be found [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).


# Prerequisites

## Required Packages

1. Plyr
2. Dplyr
3. Reshape2

## Required Data

The data associated with the study is available [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). The data should be unzipped and placed in your working directory alongside the run_analysis.R file.

# Data Manipulation

## Data Combination

To begin the data from the X_<value> file in each subfolder is created into a dataframe and its associated value names contained in features.txt is overlaid as column headers on top of the data set.

Subject Id values included in subject_<value> are merged as an additional column to the above data set and named "SubjectId".

Activity values included in the Y_<value> file are added as an additional column to the merged data set. These activity values are also translated into their associated activity names as described in the included activity_labels.txt file. This column is named "Activity"

These actions are performed on both the test and train subfolders. Both the test and train data are then combined into a single data set and returned for selection and transformation (below).

## Data Selection
The resulting combined data set is then filtered to only include those associated with mean and standard deviation values. A simply filter on mean() and std() was run to remove columns that did not contain the filtered string. Both time and frequency space values are included in the resulting data set. 

This operation is performed in the gatherDataFromSubfolder() function and can be modified to include (or not include) other columns.

Additional information on the data can be found in the study home page listed above.

## Data Transformation

The result of the above can be retrieved from the run_analysis file by calling the getData() function. If additional, tidier transformation of the data is required, this can be retrieved through the createTidyData() method in the file.

In addition to the above, the data is further transformed so that a single measurement value and variable is included per line. Whereas the getData() analysis provides 66 measurements for each row, createTidyData() will separate each of these 66 measurements into single column values (thereby transposing the data from a wide to a long data set).

Lastly, the resulting measurements are then aggregated and averaged (mean-only) for each participant and activity in a collapsed table. The final, tidy table includes 11880 obersvations, with one mean measurement value included per row.  

The format of the resulting table is as follows:
1. SubjectId -- Designated number assigned to the participant
2. Activity -- The activity that was performed during the measurement
3. Measurement -- The name of the value that was measured (see above for more information)
4. Value -- The calculated mean of the measurement for all values associated with the subject, activity, and the particular measurement.


## Special Considerations

Note that notations for test and train data are not indicated in the resulting data set and are treated equally. 


# Resulting Tidy Data

The resulting tidy data associated with the execution is available as a return value from the createTidyData() function. In addition, the tidy data is placed in the current working folder in a file named tidyData.txt
