download <- function() { 
        if (!file.exists("dataset.zip")) {
                
                fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                download.file(fileUrl, destfile = "./dataset.zip",  mode="wb")
                
                unzip("dataset.zip", exdir =".")
        }
}



project <-function() {
        # get variable names
        varnames<-as.character(unlist(read.delim("UCI HAR Dataset/features.txt", header = FALSE, sep=" ")[2]))
        
        # load testdata
        testdata<-read.table("UCI HAR Dataset/test/X_test.txt", header=FALSE,col.names = varnames, colClasses = c('numeric'))
        testactivity<-read.table("UCI HAR Dataset/test/y_test.txt")
        testsubjects<-read.table("UCI HAR Dataset//test/subject_test.txt")
        # load traindata
        traindata<-read.table("UCI HAR Dataset/train/X_train.txt", header=FALSE,col.names = varnames, colClasses = c('numeric'))
        trainactivity<-read.table("UCI HAR Dataset/train/y_train.txt")
        trainsubjects<-read.table("UCI HAR Dataset/train/subject_train.txt")
        
        # merge traindata into data
        data<-rbind(testdata, traindata)
        activity<-rbind(testactivity, trainactivity)
        colnames(activity)<-'acode'
        subjects<-rbind(testsubjects, trainsubjects)
        names(subjects)[1] <- "subject"
        
        alabels<-read.table("UCI HAR Dataset/activity_labels.txt", stringsAsFactors=FALSE)
        colnames(alabels)<-c('acode', 'activity')
        library(plyr)
        namedlabels <- join(activity, alabels, by='acode')['activity']
        
        # subset with just means and stdevs
        meanstdsubset<-data[grepl('-mean\\(\\)|-std\\(\\)', ignore.case = TRUE, varnames)]
        # fix varnames
        fixednames<-varnames[grepl('-mean\\(\\)|-std\\(\\)', ignore.case = TRUE, varnames)]
        fixednames<-sub("BodyBody", "Body", fixednames)
        fixednames<-sub("-X$", "-x", fixednames)
        fixednames<-sub("-Y$", "-y", fixednames)
        fixednames<-sub("-Z$", "-z", fixednames)
        fixednames<-sub("\\(\\)", "", fixednames)
        fixednames<-sub("(-mean|-std)(-[xyz])", "\\2\\1", fixednames)
        
        #generate codebook
        desc<-gsub("^f", "Frequency of ", fixednames)
        desc<-gsub("BodyAcc", "body acceleration ", desc)
        desc<-gsub("GravityAcc", "gravity acceleration ", desc)
        desc<-gsub("Mag", " magnitude", desc)
        desc<-gsub("BodyGyro", "gyroscope", desc)
        desc<-gsub("-mean", " (mean value)", desc)
        desc<-gsub("-std", " (Standard deviation)", desc)
        desc<-gsub("-([xyz])", " along axis \\1", desc)
        desc<-gsub("Jerk", " jerk", desc)
        desc<-gsub("  ", " ", desc)
        
        #final fix
        fixednames<-tolower(gsub("-","",fixednames))
        #codebook<-for (i in 1:61) { cat(fixednames[i], " - ", desc[i], "\n") }
        names(meanstdsubset)<-fixednames
        
        # add human readable activity name and subject ids
        reasonablyNamedmeanstdsubset<-cbind(meanstdsubset, namedlabels, subjects)
        
        # change the activity column name to 'activity'
        names(reasonablyNamedmeanstdsubset)[names(reasonablyNamedmeanstdsubset)=='V2'] <- 'activity'
        
        tidyset<-matrix('', 0, ncol(reasonablyNamedmeanstdsubset), 
                        dimnames=list(NULL, colnames(reasonablyNamedmeanstdsubset)))
        #how many variables to make the mean of?
        nvars<-ncol(reasonablyNamedmeanstdsubset)-2
        
        for (subj in sort(unique(reasonablyNamedmeanstdsubset$subject))) {
                for (act in sort(unique(reasonablyNamedmeanstdsubset[reasonablyNamedmeanstdsubset$subject == subj, 'activity']))) {
                        specificsubset<-reasonablyNamedmeanstdsubset[(reasonablyNamedmeanstdsubset$subject == subj) &
                                                                             (reasonablyNamedmeanstdsubset$activity == act), 1:nvars]
                        tidyset<-rbind(tidyset, c(colMeans(specificsubset), act, subj))
                }
        }
        
        #write the table so it's easier to paste to the project form
        write.table(tidyset, file = "tidyset.txt", row.names = FALSE)
        
        options(max.print=100000)
        tidyset
}

