
* make a copy to WORK;

data helpmkh;
  set library.helpmkh;
  run;

* recode race and merge other 
  with hispanic and create dummy
  variables for the 3 races;

proc format;
   value race3f
      1 = '1. Black'  
      2 = '2. White' 
      3 = '3. Other/Hispanic';
run;

data help2;
  set helpmkh;
  if      racegrp="black" then race3=1;
  else if racegrp="white" then race3=2;
  else                         race3=3;
  format race3 race3f.;
  if race3=1 then race_black=1; else race_black=0;
  if race3=2 then race_white=1; else race_white=0;
  if race3=3 then race_otherhisp=1; else race_otherhisp=0;
run;

proc contents data=help2; run;

* run frequencies to double check
  the recoding and dummy variable coding;

proc freq data=help2;
  table race3 race_black race_white race_otherhisp;
  run;

* get means and SDs for sexrisk by 
  the 3 racegroups;

proc means data=help2 n mean std min max;
  class race3;
  var sexrisk;
run;

* run a one-way ANOVA and do post hoc tests, 
  no error rate adjustment (for the moment)
  run the homogenity of variance test and
  request welch's robust test in case the 
  hov test is significant;

proc anova data=help2;
  class race3;
  model sexrisk = race3 / int;
  means race3 / hovtest welch lsd;
run;

* use regression approach with dummy variables
  to compare the 3 races for the sexrisk outcome
  for now include black and otherhisp and compare 
  to the white race as the reference category
  look at intercept term and compare to
  mean sexrisk for white race in proc means output above
  and notice the slopes for race_black and race_otherhisp
  are the differences between the groups as seen in the 
  post hoc comparisons table from proc anova above;

proc reg data=help2;
  model sexrisk = race_black race_otherhisp;
  run;

* run with otherhisp as reference category;

proc reg data=help2;
  model sexrisk = race_black race_white;
  run;

* let's also run this using proc glm
  using the CLASS option to treat
  race3 as a "factor" - this time we'll
  include pairwise error rate adjustments
  adding the solution option to the model statement
  creates the dummy coding on the fly to get the
  model coefficients;

proc glm data=help2;
  class race3;
  model sexrisk = race3 / solution;
  means race3 / lsd bon sidak hovtest welch;
  lsmeans race3 / pdiff=all adjust=tukey;
  run;

* let's run this again using a regression approach
  basically leave out the CLASS statement and
  the MEANS and LSMEANS statements;

proc glm data=help2;
  model sexrisk = race3 / solution;
  run;

