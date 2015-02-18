# Getting And Cleaning Data - Course Project
This describes the run_analysis.R script

The script serves to solve the course project for the Getting and Cleaning Data course at Coursera.org

The script consists of two functions - download() and project()

download() downloads and unpacks the data

project() first merges the training and the test sets for activity data, activity codes and subject ids, using the names of variables from features.txt.

Then names for activities (from activity_labels.txt) are added to the activities table.

Then a subset of the table with only the measurements on the mean and standard deviation for each measurement is created

Names of the variables are converted to the expected format - lowercased, no dashes or parentheses, duplicates removed, etc.
Now, the outcome is not something I particularly like, for myself I'd use camelcasing to make it more readable, but that's apparently not allowed here.

Then the subset is merged with the table holding codes and names of activities and with the table holding subject ids.

We create an empty matrix and looping through subjects and activities fill it with the means for each subject/activity combination.

