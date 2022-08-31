<?xml version = "1.0" encoding="UTF-8" standalone="yes"?>
<CPLEXSolution version="1.2">
 <header
   problemName="cplex.lp"
   solutionName="incumbent"
   solutionIndex="-1"
   objectiveValue="3"
   solutionTypeValue="3"
   solutionTypeString="primal"
   solutionStatusValue="101"
   solutionStatusString="integer optimal solution"
   solutionMethodString="mip"
   primalFeasible="1"
   dualFeasible="1"
   MIPNodes="0"
   MIPIterations="8"
   writeLevel="1"/>
 <quality
   epInt="1.0000000000000001e-05"
   epRHS="9.9999999999999995e-07"
   maxIntInfeas="0"
   maxPrimalInfeas="0"
   maxX="1"
   maxSlack="0"/>
 <linearConstraints>
  <constraint name="one(1)" index="0" slack="0"/>
  <constraint name="one(2)" index="1" slack="0"/>
  <constraint name="one(3)" index="2" slack="0"/>
  <constraint name="one(4)" index="3" slack="0"/>
  <constraint name="one(5)" index="4" slack="0"/>
  <constraint name="one(6)" index="5" slack="0"/>
  <constraint name="lim(1)" index="6" slack="0"/>
  <constraint name="lim(2)" index="7" slack="0"/>
  <constraint name="lim(3)" index="8" slack="0"/>
  <constraint name="lim(4)" index="9" slack="0"/>
 </linearConstraints>
 <variables>
  <variable name="used(1)" index="0" value="1"/>
  <variable name="used(2)" index="1" value="-0"/>
  <variable name="used(3)" index="2" value="1"/>
  <variable name="used(4)" index="3" value="1"/>
  <variable name="x(1,1)" index="4" value="1"/>
  <variable name="x(1,2)" index="5" value="-0"/>
  <variable name="x(1,3)" index="6" value="-0"/>
  <variable name="x(1,4)" index="7" value="-0"/>
  <variable name="x(2,1)" index="8" value="0"/>
  <variable name="x(2,2)" index="9" value="-0"/>
  <variable name="x(2,3)" index="10" value="-0"/>
  <variable name="x(2,4)" index="11" value="1"/>
  <variable name="x(3,1)" index="12" value="-0"/>
  <variable name="x(3,2)" index="13" value="-0"/>
  <variable name="x(3,3)" index="14" value="1"/>
  <variable name="x(3,4)" index="15" value="0"/>
  <variable name="x(4,1)" index="16" value="-0"/>
  <variable name="x(4,2)" index="17" value="-0"/>
  <variable name="x(4,3)" index="18" value="1"/>
  <variable name="x(4,4)" index="19" value="0"/>
  <variable name="x(5,1)" index="20" value="1"/>
  <variable name="x(5,2)" index="21" value="-0"/>
  <variable name="x(5,3)" index="22" value="-0"/>
  <variable name="x(5,4)" index="23" value="-0"/>
  <variable name="x(6,1)" index="24" value="0"/>
  <variable name="x(6,2)" index="25" value="-0"/>
  <variable name="x(6,3)" index="26" value="-0"/>
  <variable name="x(6,4)" index="27" value="1"/>
 </variables>
 <objectiveValues>
  <objective index="0" name="obj" value="3"/>
 </objectiveValues>
</CPLEXSolution>
