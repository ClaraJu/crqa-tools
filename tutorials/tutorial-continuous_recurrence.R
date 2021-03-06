#### Tutorial: Continuous recurrence ####
#
# These brief exercises will walk you through performing continuous recurrence
# and cross-recurrence quantification analysis using manual parameter searches.
#
# Code written by: A. Paxton (University of Connecticut)
# Date last modified: 07 February 2020

#### 1. Preliminaries ####

# prep the workspace  
rm(list=ls())

# load in libraries as needed
library(nonlinearTseries)
library(tseriesChaos)
library(dplyr)
library(crqa)
library(ggplot2)

# set working directory to appropriate location
setwd('./')

# read in the data
circle_x = read.table('./data/circlexML.txt') %>%
  .$V1
circle_y = read.table('./data/circleyML.txt') %>%
  .$V1

#### 2. Plotting your data ####

plot(circle_x)
plot(circle_y)

#### 3. Recurrence quantification analysis ####

######## 3a. Recurrence parameter setting ########

# decide Theiler window parameter
rec_theiler_window = 0

# target rescale type (mean or max)
rec_rescale_type = 'mean'
# rec_rescale_type = 'max'

######## 3b. Determine delay ########

# determine delay
rec_ami = mutual(circle_x,
                 lag.max = 800)

# visualize your AMI results
plot(rec_ami)

# select your delay from the AMI data
rec_chosen_delay = 180
rec_remaining_mutual_info = rec_ami[rec_chosen_delay]

######## 3c. Determine embedding parameter ########

# determine embedding
rec_max_embedding = 10
rec_fnn = false.nearest(circle_x,
                        m=rec_max_embedding,
                        d=rec_chosen_delay,
                        t=rec_theiler_window)

# visualize your FNN results
plot(rec_fnn)

# select your embedding dimension from the FNN data
rec_chosen_embedding = 6
rec_remaining_fnn = rec_fnn[,rec_chosen_embedding]

######## 3d. Select radius and run CRQA ########

# rescale your data (mean or max) -- not related to the distance matrix rescaling
if (rec_rescale_type == 'mean'){
  rescaled_circle_x = circle_x / mean(circle_x)
} else if (rec_rescale_type == 'max'){
  rescaled_circle_x = circle_x / max(circle_x)
}

# run RQA
rec_analysis = crqa(ts1 = rescaled_circle_x, 
                    ts2 = rescaled_circle_x,
                    delay = rec_chosen_delay, 
                    embed = rec_chosen_embedding, 
                    r = .1, # you can keep playing with this to find something that works
                    normalize = 0, 
                    rescale = 0, # distance matrix rescaling option -- see documentation
                    mindiagline = 2,
                    minvertline = 2, 
                    tw = rec_theiler_window, 
                    whiteline = FALSE,
                    recpt=FALSE)

######## 3e. Create the recurrence plot ########

# use the standard plotting functions
par = list(unit = 2, 
           labelx = "x-axis movement", 
           labely = "x-axis movement", 
           cols = "red", 
           pcex = 1)
plotRP(rec_analysis$RP, par)

######## 3f. Inspect the CRQA metrics ########

# take a look at the quantification metrics for CRQA across x- and y-axis movement
rec_analysis$RR # rate of recurrence
rec_analysis$DET # % determinism
rec_analysis$NRLINE # total number of lines on the plot
rec_analysis$maxL # maximum line length on plot
rec_analysis$L # average line length on plot
rec_analysis$ENTR # entropy
rec_analysis$rENTR # normalized entropy
rec_analysis$LAM # laminarity
rec_analysis$TT # trapping time

######## 3g. Visualize RP with ggplot ########

# Note: Because of the known issue for ggplot RP generation, this 
#       section is commented out by default.
# 
# 
# # convert to dataframe for easier graphing
# rqa_df = data.frame(points = rec_analysis$RP@i,
#                     loc = seq_along(rec_analysis$RP@i))
# 
# ggplot(rqa_df,aes(x=points,
#                   y=loc)) +
#   geom_point(color="red",size=.01) +
#   theme_classic() +
#   theme(legend.position="none", axis.text.x = element_blank(), axis.text.y = element_blank()) +
#   ylab("Time (in samples)") + xlab("Time (in samples)") +
#   ggtitle("Recurrence plot for x-axis movement in a circle-drawing task")

#### 4. Cross-recurrence quantification analysis ####

######## 4a. Cross-recurrence parameter setting ########

# decide Theiler window parameter
cross_theiler_window = 0

# target rescale type (mean or max)
cross_rescale_type = 'mean'
# cross_rescale_type = 'max'

######## 4b. Determine delay ########

# determine delay for x
cross_ami_x = mutual(circle_x,
                     lag.max = 800)

# determine delay for y
cross_ami_y = mutual(circle_y,
                     lag.max = 800)

# visualize your AMI results
plot(cross_ami_x)
plot(cross_ami_y)

# select your delay from the AMI data
cross_chosen_delay = 180
cross_remaining_mutual_info_x = cross_ami_x[cross_chosen_delay]
cross_remaining_mutual_info_y = cross_ami_y[cross_chosen_delay]

######## 4c. Determine embedding parameter ########

# set maximum max for both
cross_max_embedding = 10

# determine embedding
cross_fnn_x = false.nearest(circle_x,
                            m = cross_max_embedding,
                            d = cross_chosen_delay,
                            t = cross_theiler_window)

# determine embedding
cross_fnn_y = false.nearest(circle_y,
                            m = cross_max_embedding,
                            d = cross_chosen_delay,
                            t = cross_theiler_window)

# visualize your FNN results
plot(cross_fnn_x)
plot(cross_fnn_y)

# select your embedding dimension from the FNN data
cross_chosen_embedding = 6
cross_remaining_fnn_x = cross_fnn_x[cross_chosen_embedding]
cross_remaining_fnn_y = cross_fnn_y[cross_chosen_embedding]

######## 4d. Select radius and run CRQA ########

# rescale your data (mean or max) -- not related to the distance matrix rescaling
if (cross_rescale_type == 'mean'){
  rescaled_circle_x = circle_x / mean(circle_x)
  rescaled_circle_y = circle_y / mean(circle_y)
} else if (cross_rescale_type == 'max'){
  rescaled_circle_x = circle_x / max(circle_x)
  rescaled_circle_y = circle_x / max(circle_y)
}

# run CRQA and grab recurrence rate (RR)
cross_rec_analysis = crqa(ts1 = rescaled_circle_x, 
                          ts2 = rescaled_circle_y,
                          delay = cross_chosen_delay, 
                          embed = cross_chosen_embedding, 
                          r = .3, # you can keep playing with this to find something that works
                          normalize = 0, 
                          rescale = 0, # distance matrix rescaling option -- see documentation
                          mindiagline = 2,
                          minvertline = 2, 
                          tw = cross_theiler_window, 
                          whiteline = FALSE,
                          recpt=FALSE)

######## 4e. Create the cross-recurrence plot ########

# use the standard plotting functions
par = list(unit = 2, 
           labelx = "x-axis movement", 
           labely = "y-axis movement", 
           cols = "red", 
           pcex = 1)
plotRP(cross_rec_analysis$RP, par)

######## 4f. Inspect the CRQA metrics ########

# take a look at the quantification metrics for CRQA across x- and y-axis movement
cross_rec_analysis$RR # rate of recurrence
cross_rec_analysis$DET # % determinism
cross_rec_analysis$NRLINE # total number of lines on the plot
cross_rec_analysis$maxL # maximum line length on plot
cross_rec_analysis$L # average line length on plot
cross_rec_analysis$ENTR # entropy
cross_rec_analysis$rENTR # normalized entropy
cross_rec_analysis$LAM # laminarity
cross_rec_analysis$TT # trapping time

######## 4g. Visualize RP with ggplot ########

# Note: Because of the known issue for ggplot RP generation, this 
#       section is commented out by default.
# 
# # convert to dataframe for easier graphing
# cross_rqa_df = data.frame(points = cross_rec_analysis$RP@i,
#                           loc = seq_along(cross_rec_analysis$RP@i))
# 
# # generate the CRP
# ggplot(cross_rqa_df,aes(x=points,
#                         y=loc)) +
#   geom_point(color="red",size=.01) +
#   theme_classic() +
#   theme(legend.position="none", axis.text.x = element_blank(), axis.text.y = element_blank()) +
#   ylab("Time for y-axis movement") + xlab("Time for x-axis movement") +
#   ggtitle("Cross-recurrence plot between\nx- and y-axis movement in a circle-drawing task")
