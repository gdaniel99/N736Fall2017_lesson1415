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
run;

proc contents data=help2; run;

proc freq data=help2;
  table race3;
  run;
