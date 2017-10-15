* Encoding: UTF-8.
* ========================================
*
* SPSS SYNTAX for lesson 14,15.
*
* for this code, use the modex.sav data file
*
* Melinda Higgins, PhD
* dated 10/15/2017
* ========================================.

* ========================================
* look at descriptive stats of the variables
* ========================================.

FREQUENCIES VARIABLES=Endurance Age AgeC Exercise ExerciseC AgeCxExerciseC
  /NTILES=4
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN
  /HISTOGRAM
  /ORDER=ANALYSIS.

* ========================================
* run a regression of Endurance by Age
* ========================================.

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT Endurance 
  /METHOD=ENTER Age.

* ========================================
* run a regression of Endurance by mean centered Age
* notice the slope is the same and the intercept has changed
* compare the intercept to the mean for Endurance in the
* descriptive stats above
* ========================================.

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT Endurance 
  /METHOD=ENTER AgeC.

* ========================================
* run a regression of Endurance - consider Exercise
* "adjusting" for Age - BUT treating Age as a "covariate"
* in this way assumes that the slope between
* Exercise and Endurance is the same for ALL Ages
* this is the homogeneity of slopes assumption
* ========================================.

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT Endurance 
  /METHOD=ENTER AgeC
  /METHOD=ENTER ExerciseC.

* ========================================
* we need to test this assumption - add the interaction 
* term to the model and see if this interaction is significant
* ========================================.

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT Endurance 
  /METHOD=ENTER AgeC ExerciseC AgeCxExerciseC.

* ========================================
* we can also force the interaction term into a separate
* step to test after adjusting for the main effects of
* age and exercise
* ========================================.

REGRESSION 
  /DESCRIPTIVES MEAN STDDEV CORR SIG N 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE ZPP 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT Endurance 
  /METHOD=ENTER AgeC ExerciseC 
  /METHOD=ENTER AgeCxExerciseC.

* ========================================
* let's make some interaction plots
* ========================================.

* create a AgeC recoded split at -1SD, 0, +1SD
* to see how the slopes change across Ages.

RECODE AgeC (Lowest thru -10.1=1) (-10.0999999999999999 thru 0=2) (0.000000000001 thru 
    10.0999999999999999=3) (10.1 thru Highest=4) INTO AgeC_1sdBins.
EXECUTE.

* Define Variable Properties.
*AgeC_1sdBins.
VALUE LABELS AgeC_1sdBins
  1.00 '1. AgeC < -10.1'
  2.00 '2. 10.1 < AgeC <= 0'
  3.00 '3. 0 < AgeC <= 10.1'
  4.00 '4. 10.1 < AgeC'.
EXECUTE.

GRAPH
  /SCATTERPLOT(BIVAR)=ExerciseC WITH Endurance
  /PANEL COLVAR=AgeC_1sdBins COLOP=CROSS
  /MISSING=LISTWISE.








