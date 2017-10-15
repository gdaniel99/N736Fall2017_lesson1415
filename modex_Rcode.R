# ===================================
# Lesson 14 - Modeling Interaction Terms
#             testing homogenity of slopes
#
# by Melinda Higgins, PhD
# dated 10/15/2017
# ===================================

library(tidyverse)
library(haven)

modex <- haven::read_spss("modex.sav")

# look at descriptive stats
# lets use the dplyr::summarize() function

mod1 <- modex %>%
  select(Endurance, Age, AgeC, Exercise, ExerciseC) 

# a custom function to collect
# descriptive stats
# see my N741 package
# https://github.com/melindahiggins2000/N741pkg 

tbl.continuous <- function(df,var,l){
  t <- dplyr::summarise(df,
                        item = l,
                        n = sum(!is.na(var)),
                        missing = sum(is.na(var)),
                        min = min(var, na.rm=TRUE),
                        avg = mean(var, na.rm=TRUE),
                        SD = sd(var, na.rm=TRUE),
                        median = median(var, na.rm=TRUE),
                        Q1 = quantile(var, 0.25, na.rm=TRUE),
                        Q3 = quantile(var, 0.75, na.rm=TRUE),
                        max = max(var, na.rm=TRUE))
  return(t)
}

t1 <- tbl.continuous(mod1,mod1$Endurance,"Endurance")
t2 <- tbl.continuous(mod1,mod1$Age,"Age")
t3 <- tbl.continuous(mod1,mod1$AgeC,"Age mean centered")
t4 <- tbl.continuous(mod1,mod1$Exercise,"Exercise")
t5 <- tbl.continuous(mod1,mod1$ExerciseC,"Exercise mean centered")
tbl <- rbind(t1,t2,t3,t4,t5)
as.data.frame(tbl)

# in rmarkdown make a table
knitr::kable(rbind(t1,t2,t3,t4,t5),
             caption = "Table of Summary Stats")

# look at means and SD
# in the output table

# run a regression of Endurance with Age

m1 <- lm(Endurance ~ Age, data=modex)
m1

# run a regression of Endurance with AgeC - mean centered Age

m2 <- lm(Endurance ~ AgeC, data=modex)
m2

# compare the slopes and interecepts
# in m2 - compare intercept to mean for Endurance

# fit a model with AgeC and ExerciseC

m3 <- lm(Endurance ~ AgeC + ExerciseC, data=modex)
m3

# fit a model also with the interaction term

m4 <- lm(Endurance ~ AgeC + ExerciseC + AgeCxExerciseC, data=modex)
m4

# I had to turn on the debug() option
# to install packages 
# a work around McAfee virus software on windows/Emory
# see https://stackoverflow.com/questions/34739681/unable-to-move-temporary-installation-when-installing-dependency-packages-in-r


#debug(utils:::unpackPkgZip)
#install.packages("car")
#install.packages("lme4")

library(car)

# compare models

car::Anova(m3, type=3)
car::Anova(m4, type=3)
anova(m3,m4)

# bring in the effects package
# install.packages("effects")
#
# learn more about this package
# https://cran.r-project.org/web/packages/effects/
# http://socserv.socsci.mcmaster.ca/jfox/Misc/effects/index.html 

# plot the interaction plot
# ExerciseC is listed first so the plot
# shows Endurance by Exercise for different Ages

library(effects)

m5 <- lm(Endurance ~ ExerciseC + AgeC + ExerciseC*AgeC, data=modex)

plot(effect("ExerciseC:AgeC", m5, 
            xlevels=list()),
     multiline=TRUE, ylab="Endurance", rug=FALSE)
