# ===================================
# Lesson 15 - Working with categorical
#             variables, dummy coding
#             anova, regression and the GLM
#
# by Melinda Higgins, PhD
# dated 10/17/2017
# ===================================

library(tidyverse)
library(haven)

helpdat <- haven::read_spss("helpmkh.sav")

# let's merge hispanic/other together for race
helpdat$race3 <- ""
helpdat$race3[helpdat$racegrp == "black"] <- "Black"
helpdat$race3[helpdat$racegrp == "white"] <- "White"
helpdat$race3[helpdat$racegrp == "hispanic"] <- "Hisp/Other"
helpdat$race3[helpdat$racegrp == "other"] <- "Hisp/Other"

table(helpdat$race3)
class(helpdat$race3)

# let's also create a numeric coded race variable

helpdat$race3num[helpdat$race3 == "Black"] <- 1
helpdat$race3num[helpdat$race3 == "White"] <- 2
helpdat$race3num[helpdat$race3 == "Hisp/Other"] <- 3

helpdat$race3numF <- factor(helpdat$race3num,
                            levels=c(1,2,3),
                            labels=c("1. Black",
                                     "2. White",
                                     "3. Hisp/Other"))

table(helpdat$race3num)
class(helpdat$race3num)

table(helpdat$race3numF)
class(helpdat$race3numF)

# get a summary table of the 
# means and SD for sexrisk by
# race3, racenum or race3numF

helpdat %>%
  select(sexrisk, race3) %>%
  group_by(race3) %>%
  summarise(mean=mean(sexrisk), 
            sd=sd(sexrisk))

helpdat %>%
  select(sexrisk, race3num) %>%
  group_by(race3num) %>%
  summarise(mean=mean(sexrisk), 
            sd=sd(sexrisk))

helpdat %>%
  select(sexrisk, race3numF) %>%
  group_by(race3numF) %>%
  summarise(mean=mean(sexrisk), 
            sd=sd(sexrisk))

# run an ANOVA for race3
# compare for the different variables
# race3, race3num and race3numF

# race3 as a character variable
aov1 <- aov(sexrisk ~ race3, data=helpdat)
aov1
summary(aov1)
model.tables(aov1)
TukeyHSD(aov1)
with(data=helpdat, 
     pairwise.t.test(sexrisk, race3, 
                     p.adj="none", paired=FALSE))
car::Anova(aov1, type=3)

# race3num as a numeric variable
aov2 <- aov(sexrisk ~ race3num, data=helpdat)
aov2
summary(aov2)
model.tables(aov2) # odd results
TukeyHSD(aov2) # not run
with(data=helpdat, 
     pairwise.t.test(sexrisk, race3num, 
                     p.adj="none", paired=FALSE)) # this works
car::Anova(aov2, type=3)

# race3numF as a Factor type/class variable
aov3 <- aov(sexrisk ~ race3numF, data=helpdat)
aov3
summary(aov3)
model.tables(aov3)
TukeyHSD(aov3)
with(data=helpdat, 
     pairwise.t.test(sexrisk, race3numF, 
                     p.adj="none", paired=FALSE))
car::Anova(aov3)

# add dummy variables
helpdat <- helpdat %>%
  mutate(race_black = race3num==1,
         race_white = race3num==2,
         race_otherhisp = race3num==3)

table(helpdat$race3num)
table(helpdat$race_black)
table(helpdat$race_white)
table(helpdat$race_otherhisp)

# use a regression approach using dummy variables
# set white as the reference category - so use
# the other 2 dummy vars
lm1 <- lm(sexrisk ~ race_black + race_otherhisp, data=helpdat)
lm1
summary(lm1)

# use a regression approach using dummy variables
# set otherhisp as the reference category - so use
# the other 2 dummy vars
lm2 <- lm(sexrisk ~ race_black + race_white, data=helpdat)
lm2
summary(lm2)

# in R when you put a FACTOR type variable
# into a model, the dummy coding happens on the fly
# this also works if the variable is character
# so R recognizes the categories and treat them
# as a factor for modeling purposes
# notice that the 1st category for black
# is used as the reference category by default

lm3f <- lm(sexrisk ~ race3numF, data=helpdat)
lm3f
summary(lm3f)
car::Anova(lm3f, type=3)

lm3c <- lm(sexrisk ~ race3, data=helpdat)
lm3c
summary(lm3c)
car::Anova(lm3c, type=3)

# but when the variable is numeric and 
# is not treated as a factor, you get
# a single coefficient and 1 slope "effect"

lm4 <- lm(sexrisk ~ race3num, data=helpdat)
lm4
summary(lm4)
car::Anova(lm4, type=3)

library(olsrr)
ols_regress(lm1)
ols_regress(lm3f)
ols_regress(lm4)

