
* make a copy to WORK;
data helpmkh;
  set library.helpmkh;
  run;

* the formatting is now applied and should work;
proc freq data=helpmkh;
  tables female;
  run;

proc freq data=helpmkh;
  table f1a;
  run;

* see contents and formatting details
  and labelling;
proc contents data=helpmkh;
run;

proc corr data=helpmkh;
  var indtot cesd;
  run;

proc reg data=helpmkh;
  model indtot = cesd;
  plot indtot * cesd / pred;
  run;

* proc glm option to get
  type I and type III SS;

proc glm data=helpmkh;
  model indtot = cesd;
  run;

* learn more
  https://stats.idre.ucla.edu/sas/webbooks/reg/chapter1/regressionwith-saschapter-1-simple-and-multiple-regression/;

* recode pss_fr into 3 group
  split based on percentiles into thirds;

proc univariate data=helpmkh noprint;
   var pss_fr;
   output out=PctlPSSfr pctlpts=33 67 pctlpre=PSSfr_;
run;

* the 33.3rd percentile = 4
  the 66.7th percentile = 9
  use this info to create 3 groups;

proc format;
   value pssfr
      0 = '0. LOW PSS-fr <=4'  
      1 = '1. MODERATE PSS-fr 4<x<=9' 
      2 = '2. HIGH PSS-fr >9';
run;

data helpmkh_addpssfr3;
  set helpmkh;
  pssfr3 = .;
  IF (pss_fr <= 4)               THEN pssfr3 = 0; 
  IF ((pss_fr > 4)&(pss_fr <=9)) THEN pssfr3 = 1;
  IF (pss_fr > 9)                THEN pssfr3 = 2;
  format pssfr3 pssfr.;
run;

proc freq data=helpmkh_addpssfr3;
  table pssfr3;
  run;

proc contents data=helpmkh_addpssfr3; run;

proc ANOVA data=helpmkh_addpssfr3;
	title Example of one-way ANOVA;
	class pssfr3;
	model indtot = pssfr3;
	means pssfr3 / bon sidak hovtest welch;
	run;

* proc glm option to get
  type I and type III SS;

proc glm data=helpmkh_addpssfr3;
  class pssfr3;
  model indtot = pssfr3;
  means pssfr3 / bon sidak hovtest welch;
  lsmeans pssfr3 / pdiff=all adjust=tukey;
  run;
