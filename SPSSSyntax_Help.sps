* Encoding: UTF-8.
* ==========================================
* recode racegrp and substance variables
* from character based to numerical coding with labels
* ==========================================.

AUTORECODE VARIABLES=racegrp substance 
  /INTO racegrp_num substance_num
  /PRINT.

* ==========================================
* run a comparison to check recoding
* ==========================================.

FREQUENCIES VARIABLES=racegrp racegrp_num substance substance_num
  /ORDER=ANALYSIS.

* ==========================================
* merge hispanic (coded 2) and other (coded 3)
* and create a 3-level race group
* ==========================================.

RECODE racegrp_num (1=1) (4=3) (2 thru 3=2) INTO racegrp3.
VARIABLE LABELS  racegrp3 'Race 3 Groups'.
EXECUTE.

* ==========================================
* update labels with new numbering
* ==========================================.

* Define Variable Properties.
*racegrp3.
FORMATS  racegrp3(F8.0).
VALUE LABELS racegrp3
  1 'black'
  2 'hispanic or other'
  3 'white'.
EXECUTE.

* ==========================================
* another quick check
* ==========================================.

FREQUENCIES VARIABLES=racegrp racegrp_num racegrp3
  /ORDER=ANALYSIS.

* ==========================================
* create dummy variables for the 3 race groups
* ==========================================.

COMPUTE race_black=racegrp3 = 1.
COMPUTE race_otherhisp=racegrp3 = 2.
COMPUTE race_white=racegrp3 = 3.
EXECUTE.

* ==========================================
* get means and SDs for sexrisk by the 3 racegroups
* ==========================================.

SORT CASES  BY racegrp3.
SPLIT FILE LAYERED BY racegrp3.

FREQUENCIES VARIABLES=sexrisk
  /FORMAT=NOTABLE
  /NTILES=4
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN
  /ORDER=ANALYSIS.

SPLIT FILE OFF.

* ==========================================
* run a one-way ANOVA and do post hoc tests, 
* no error rate adjustment (for the moment)
* ==========================================.

ONEWAY sexrisk BY racegrp3
  /STATISTICS DESCRIPTIVES EFFECTS HOMOGENEITY 
  /MISSING ANALYSIS
  /POSTHOC=LSD ALPHA(0.05).

* ==========================================
* alternate code for one-way ANOVA
* ==========================================.

UNIANOVA sexrisk BY racegrp3
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /POSTHOC=racegrp3(LSD) 
  /EMMEANS=TABLES(OVERALL) 
  /EMMEANS=TABLES(racegrp3) COMPARE ADJ(LSD)
  /PRINT=ETASQ HOMOGENEITY DESCRIPTIVE
  /CRITERIA=ALPHA(.05)
  /DESIGN=racegrp3.

* ==========================================
* using dummy coding as alternate for 
* ANOVA type analyses 
*
* use race_black and race_otherhisp in model, so white
* is reference category for this model.
*
* look at intercept term and compare to mean sexrisk
* for the white race...
* ==========================================.

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT sexrisk
  /METHOD=ENTER race_black race_otherhisp
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

* ==========================================
* try with otherhisp as reference category
* so put race_black and race_white in the model
*
* look at intercept term and compare to mean sexrisk
* for the otherhisp race...
* ==========================================.

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT sexrisk
  /METHOD=ENTER race_black race_white
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

* ==========================================
* comparing the GLM framework
*
* run racegrp3 as a FACTOR
* we can manipulate how the comparisons are done
* we can run post hoc tests
* ==========================================.

* Generalized Linear Models.
GENLIN sexrisk BY racegrp3 (ORDER=ASCENDING)
  /MODEL racegrp3 INTERCEPT=YES
 DISTRIBUTION=NORMAL LINK=IDENTITY
  /CRITERIA SCALE=MLE COVB=MODEL PCONVERGE=1E-006(ABSOLUTE) SINGULAR=1E-012 ANALYSISTYPE=3(WALD) 
    CILEVEL=95 CITYPE=WALD LIKELIHOOD=FULL
  /EMMEANS TABLES=racegrp3 SCALE=ORIGINAL COMPARE=racegrp3 CONTRAST=PAIRWISE PADJUST=LSD
  /MISSING CLASSMISSING=EXCLUDE
  /PRINT CPS DESCRIPTIVES MODELINFO FIT SUMMARY SOLUTION.

* ==========================================
* run racegrp3 as a COVARIATE
* treats racegrp3 as a continuous/ordinal variable
* so the slope coefficient looks at changes from
* black to otherhisp to white which might not be what you want
* ==========================================.

* Generalized Linear Models.
GENLIN sexrisk WITH racegrp3
  /MODEL racegrp3 INTERCEPT=YES
 DISTRIBUTION=NORMAL LINK=IDENTITY
  /CRITERIA SCALE=MLE COVB=MODEL PCONVERGE=1E-006(ABSOLUTE) SINGULAR=1E-012 ANALYSISTYPE=3(WALD) 
    CILEVEL=95 CITYPE=WALD LIKELIHOOD=FULL
  /MISSING CLASSMISSING=EXCLUDE
  /PRINT CPS DESCRIPTIVES MODELINFO FIT SUMMARY SOLUTION.

* ==========================================
* compare the MAIN EFFECT for racegrp3 here 
* between these 2 models.
*
* pay attention to the degrees of freedom and the kind of 
* test that is being performed...
* ==========================================.





