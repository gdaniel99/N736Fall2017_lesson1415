# ===================================
# Lesson 12 - Simple Regression & ANOVA
#
# by Melinda Higgins, PhD
# dated 10/04/2017
# ===================================

library(tidyverse)
library(haven)

helpdat <- haven::read_spss("helpmkh.sav")

# create subset
# select indtot, cesd and pss_fr

h1 <- helpdat %>%
  select(indtot, cesd, pss_fr)

# find the cutpoints that break the pss_fr
# into thirds, i.e. the 33rd and 67th percentile

psscut <- quantile(h1$pss_fr, 
                   probs=c(.33,.67))

h2 <- h1 %>%
  mutate(pss3 = ifelse(pss_fr <=4, 0, 
                ifelse(pss_fr <=9, 1, 2)))

class(h2$pss3)

# let's also create a "factor" class
# variable pss3f

h2$pss3f <- factor(h2$pss3,
                   levels = c(0,1,2),
                   labels = c("0: low pss",
                              "1: moderate pss",
                              "2: high pss"))

class(h2$pss3f)

# run simple linear regression
# using the lm
# save the results in the fit1 object

fit1 <- lm(indtot ~ cesd, data=h2)

# this creates a lm object
# which has 12 components
class(fit1)

# look at a summary() of the model
summary(fit1)

# get the ANOVA for this model
# this gives you TYPE I Sums of Squares
anova(fit1)

# get diagnostic plots
par(mfrow=c(2,2))
plot(fit1)

# reset par
par(mfrow=c(1,1))

# see the coefficients
coefficients(fit1)

# ANOVA table of model fit
# base stats r anova() function
# type I sums of squares
anova(fit1)

# Anova() function from car package
# type III sums of squares
# this will be the same with only 1 predictors
# in the model, but will be important
# when we have more predictors
library(car)
car::Anova(fit1, type=3)

# use the car package to get additional diagnostics
# and plotting options

# Durbin-Watson Test for Autocorrelated Errors
car::durbinWatsonTest(fit1)

# component plus residual plots
# these are also called partial residual plots
car::crPlots(fit1)

# homoscedasticity
# look for non-constant error variance
car::ncvTest(fit1)

# also look at the spreadLevelPlot
car::spreadLevelPlot(fit1)

# this suggests a power transformation
# of almost 4, Ynew = Y^4
plot(h2$cesd, h2$indtot)
abline(lm(h2$indtot ~ h2$cesd))

plot(h2$cesd, h2$indtot^4)
abline(lm(h2$indtot^4 ~ h2$cesd))

# global test of linear model assumptions
# install gvlma package
library(gvlma)
gvmodel <- gvlma::gvlma(fit1)
summary(gvmodel)

# try with the power transformation
fit1t <- lm(indtot^4 ~ cesd, data=h2)
gvlma::gvlma(fit1t)
par(mfrow=c(2,2))
plot(fit1t)
par(mfrow=c(1,1))

# one-way ANOVA
# we can use the lm() function
# it does "dummy" coding on the fly
fit2.lm <- lm(indtot ~ pss3f, data=h2)
summary(fit2.lm)

# the aov() function
# gives the global test for the "group" effect
fit2.aov <- aov(indtot ~ pss3f, data=h2)
summary(fit2.aov)

# get a means plot using
# plotmeans() from gplots package
library(gplots)
gplots::plotmeans(indtot ~ pss3f, 
                  data=h2)

# post hoc tests
# Tukey HSD
TukeyHSD(fit2.aov)

# another plot of the 95% CI
# for the pairwise comparisons
#rotate labels
par(las=2) 
# modify margins to get labels inside margins
par(mar=c(5,12,4,2))
plot(TukeyHSD(fit2.aov))

# assess ANOVA test assumptions
# the simulate options
# if TRUE will calculate a 
# confidence interval by parametric bootstrap
car::qqPlot(fit2.aov,
            simulate=TRUE)

# barlett's test for homogenity of variances
# note: put the formula back in
bartlett.test(indtot ~ pss3f, data=h2)

# outlier test from the car package
car::outlierTest(fit2.aov)
