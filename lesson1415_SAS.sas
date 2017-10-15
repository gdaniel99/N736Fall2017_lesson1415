libname lesson 'C:\MyGithub\N736Fall2017_lesson1415' ;

* load the C07E01DT_mkh SAS7bdat dataset
  rename as modex for moderation example;

data modex;
  set lesson.C07E01DT_mkh;
  run;

* take a look at the dataset;

proc contents data=modex; run;

* the dataset has 7 variables
  SampleID - ID for tracking subjects
  Age - age of subjects
  AgeC - "mean centered" age (age - meanAge)
  Endurance - the main outcome variable
  Exercise - amount of exercise
  ExerciseC - "mean centered" Exercise (exercise - meanExercise)
  AgeCxExerciseC - the interaction term computed from
                   the two "mean centered" variables
                   AgeC * ExerciseC;

* look at stats
  pay attention to the means and standard deviations;

proc means data=modex n mean std min max;
  var Endurance Age AgeC Exercise ExerciseC AgeCxExerciseC;
  run;

* look at regression model for
  non-mean-centered age;

proc reg data=modex;
  model Endurance = Age;
  run;

* see what happens when we use the mean centered
  Age - the slope is the same BUT the intercept changed
  compare the intercept to the mean for Endurance
  in the proc means output above;

proc reg data=modex;
  model Endurance = AgeC;
  run;

* look at model without the interaction term
  suppose we were considering that we wanted
  to "adjust" for Age and look at the relationship
  between Exercise and Endurance - BUT this assumes
  that the SLOPE between Exercise and Endurance is the SAME
  for All Ages - this might not be true
  this is the "homogeneity of variances" assumption;

proc reg data=modex;
  model Endurance = AgeC ExerciseC;
  run;

* test to see if the interaction term
  is significant or not
  this tests to see if Age "MODERATES"
  the relationship between Exercise and Endurance;

proc reg data=modex;
  model Endurance = AgeC ExerciseC AgeCxExerciseC;
  run;

* we can also force this test
  adjusting for the main effects of Age and Exercise
  and THEN testing for the interaction term;

proc reg data=modex;
  model Endurance = AgeC ExerciseC AgeCxExerciseC / selection=forward include=2;
  run;

* proc glm approach
  solution provides the parameter estimates
  effectsize provides the effect size to each ANOVA table;

proc glm data=modex;
  model Endurance = AgeC|ExerciseC / solution effectsize;
run;

* quick reminder
  look at mean and standard deviation
  of mean centered Age;

proc means data=modex mean std;
  var AgeC;
  run;

* proc glm will compute the interaction 
  term on the fly automatically
  we will use the store option to
  save the model fit;

proc glm data=modex;
  model Endurance = AgeC|ExerciseC / solution;
  store glmmodel;
run;

* once you have the model fit saved or stored
  you can use this object with proc plm
  to make interaction effect plots;

* learn more at
  https://stats.idre.ucla.edu/sas/seminars/analyzing-and-visualizing-interactions/
  https://blogs.sas.com/content/iml/2016/06/22/sas-effectplot-statement.html ;

* in the statement below we are asking for the
  effectplots to be done at Ages 
       - 2 standard deviations below the mean
       - 1 SD below the mean
       - at the mean (which is 0 for AgeC)
       - at 1 SD above the mean
       - at 2 SD above the mean;

proc plm source=glmmodel;
  effectplot fit (x=ExerciseC) / at(AgeC = -20.2 -10.1 0 10.1 20.2);
run;
