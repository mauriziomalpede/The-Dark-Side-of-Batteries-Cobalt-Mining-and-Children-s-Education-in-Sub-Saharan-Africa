clear
capture log close
set more off
set matsize 1000

cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication"

local dta ".\data\constructed"
local data ".\data\raw"
local tabfig  ".\output"

local dhs07 ".\data\raw\DRC_2007_DHS"
local dhs14 ".\data\raw\DRC_2013-14_DHS"

local zambia_dhs07 ".\data\raw\ZAMBIA_2007_DHS"
local zambia_dhs14 ".\data\raw\ZAMBIA_2013-14_DHS"
 

	*import and save as dta dhs gps for 2007 and 2014 

import delimited "`dhs07'\DRCGE52FL\CDGE52FL_adm2.csv", delimiter(comma)
rename latnum y
rename longnum x 
save  "`dta'\dhsgps07.dta", replace

clear

import delimited "`dhs14'\DRCGE61FL\CDGE61FL_adm2.csv", delimiter(comma) 
rename latnum y
rename longnum x
save  "`dta'\dhsgps14.dta", replace
	
clear

	 *import 1st mining sites loation database in the DRC

import delimited "`data'\Mines_admn2.csv", delimiter(";")
*rename x_new x
*rename y_new y 
keep x y f_name adm2_fr adm1_fr adm1_pcode adm2_pcode

rename f_name mine

save  "`dta'\Mines_admn2.dta", replace

clear 

*import also ACLED events and compute the number of events per province 
import delimited "`data'\ACLED_buffer.csv", delimiter(",")
egen events_year = count(event_id_n), by (adm2_pcode year)

keep year admin1 admin2 admin3 adm2_pcode adm1_pcode events_year

sort year admin3 adm2_pcode events_year
quietly by year admin3 adm2_pcode events_year:  gen dup = cond(_N==1,0,_n)
drop if dup>1

keep if year<=2015
gen time=0
replace time =0 if year<=2007
replace time =1 if year>2007

collapse (sum) events_year, by(time adm2_pcode)

replace time =2007 if time ==0
replace time =2014 if time ==1

rename time year
save  "`dta'\ACLED_buffer.dta", replace

clear  

 foreach x in br cr ir kr {
use  "`dta'\dhs_`x'07.dta", clear
rename v001 dhsclust

joinby dhsclust using "`dta'\dhsgps07.dta", unmatched(both)
drop _merge
gen year =2007
order x y year dhsclust
save  "`dta'\dhs_`x'_complete07.dta", replace
}

clear


 foreach x in br cr ir kr {
use  "`dta'\dhs_`x'14.dta", clear
rename v001 dhsclust

joinby dhsclust using "`dta'\dhsgps14.dta", unmatched(both)
drop _merge
gen year =2014
order x y year dhsclust
save  "`dta'\dhs_`x'_complete14.dta", replace

 } 

 foreach x in hr pr  {
use  "`dta'\dhs_`x'07.dta", clear
rename hv001 dhsclust
rename hv002 v002
rename hv003 v003

joinby dhsclust using "`dta'\dhsgps07.dta", unmatched(both)
drop _merge
gen year =2007
order x y year dhsclust
save  "`dta'\dhs_`x'_complete07.dta", replace
}

clear

 foreach x in hr pr  {
use  "`dta'\dhs_`x'14.dta", clear
rename hv001 dhsclust
rename hv002 v002
rename hv003 v003
joinby dhsclust using "`dta'\dhsgps14.dta", unmatched(both)
drop _merge
gen year =2014
order x y year dhsclust
save  "`dta'\dhs_`x'_complete14.dta", replace

}
*/


*Now consider PR recode only and keep only relevant variables:

use  "`dta'\dhs_pr_complete07.dta", clear

* help family with farm/business
* works for someoneelse other than family
* average number of hours child spent on housework activities (non harmful child labor)
* average current school year
* average highest edu level completed 
* average wealth index
keep  x y year dhsclust adm1_pcode adm2_pcode v002 v003 hv104 hv004 hv005 hv006 hv007 hv008 hv009 hv025 hv102 hv105 sh209 sh204 sh205 sh206 sh208 hv124 hv107 hv108 hv111 hv113 hv121 hv122 hc61 hv270 hv130 hv131 hv132 ha40

save  "`dta'\dhs_pr_final07.dta", replace
clear

use  "`dta'\dhs_pr_complete14.dta", clear
*keep only relevant variables:
*help family with farm/business
*average number of hours child spent on housework activities (non harmful child labor)
*activities that require heavy loads 
* average current school year
*average highest edu level completed
* average wealth index 
*hospitalized in the last 4 weeks 
*cognitive deficiency
keep x y year dhsclust adm1_pcode adm2_pcode v002 v003 hv004 hv005 hv006 hv007 hv008 hv009 hv025 hv102 hv104 hv105 hv107 hv108 hv111 hv113 hv121 hv122 hv124 hv244 hv245 hv246 hv270 hc61 sh25* sh26* sh21 sh22 sh23 sh28* sh29*  ha40 
save  "`dta'\dhs_pr_final14.dta", replace
clear


*Append both waves (2007 and 2014) in a unique file
use "`dta'\dhs_pr_final07.dta", clear
joinby x y year dhsclust adm1_pcode adm2_pcode v002 v003 hv025 ha40 hv102 hv104 hv105 hv107 hv108 hv111 hv113 hv121 hv122 hc61 hv124 hv004 hv005 hv006 hv007 hv008 hv009  hv270 using "`dta'\dhs_pr_final14.dta", unmatched(both)
drop _merge
order x y year dhsclust adm1_pcode adm2_pcode hv105
save  "`dta'\dhs_pr_final.dta", replace

*/

*Create a dhs-mines file in which there is the distance of each individual to the closest mine 
use  "`dta'\dhs_pr_final.dta", clear
	*match with mining locations in the DRC

joinby x y using "`dta'\Mines_admn2.dta", unmatched(both)

	*generate geo distance between villages and cobalt and other mines 

geodist x y  25.7679999999 -10.7750000000, gen(dist_cobalt1) 
geodist x y  25.4670000002 -10.7000000001, gen(dist_cobalt2) 
geodist x y  25.3749999998 -10.7410000004, gen(dist_cobalt3)
geodist x y  26.2539999999 -10.7540000001, gen(dist_cobalt4)
geodist x y  26.1150000002 -10.7599999998, gen(dist_cobalt5) 
geodist x y  27.5809999996 -11.6339999996, gen(dist_cobalt6)
geodist x y  26.4229999999 -10.7330000002, gen(dist_cobalt7) 
geodist x y  26.4500000003 -10.6900000003, gen(dist_cobalt8)
geodist x y  26.3979999999 -10.7390000000, gen(dist_cobalt9)
geodist x y  25.9090000001 -10.6240000000, gen(dist_cobalt10)
geodist x y  26.6110000001 -10.8510000000, gen(dist_cobalt11)
geodist x y  26.5860000001 -10.8130000004, gen(dist_cobalt12)
geodist x y  25.4010000000 -10.7199999997, gen(dist_cobalt13) 
geodist x y  25.4770000000 -10.6769999998, gen(dist_cobalt14)
geodist x y  26.5669999999 -10.8330000000, gen(dist_cobalt15)
geodist x y  27.9010000003 -12.0159999997, gen(dist_cobalt16)
geodist x y  27.0989999997 -11.2559999996, gen(dist_cobalt17) 
geodist x y  27.0989999997 -11.2559999996, gen(dist_cobalt18) 
geodist x y  25.9750000003 -10.7739999997, gen(dist_cobalt19)
geodist x y  27.0080000003 -11.1669999999, gen(dist_cobalt20)
geodist x y  27.4170000000 -11.5140000002, gen(dist_cobalt21)
geodist x y  27.2630000001 -11.5989999999, gen(dist_cobalt22)
geodist x y  26.5830000002 -10.8499999998, gen(dist_cobalt23)
geodist x y  26.3480000000 -10.7250000000, gen(dist_cobalt24)
geodist x y  25.8130000003 -10.7860000000, gen(dist_cobalt25)
geodist x y  25.5049999999 -10.6500000002, gen(dist_cobalt26)
geodist x y  26.1900000001 -10.5799999998, gen(dist_cobalt27) 
geodist x y  25.6919999998 -10.7999999999, gen(dist_cobalt28)
geodist x y  27.2355559999 -11.7694439998, gen(dist_cobalt29)

geodist x y  28 -3.19,    gen(dist_gold1)
geodist x y  27.57 -4,    gen(dist_gold2)
geodist x y  29.0 -4.32,  gen(dist_gold3)
geodist x y  28.75 -2.75, gen(dist_gold4)
geodist x y  29.2 -0.21,  gen(dist_gold5)
geodist x y  29.9 1.91,   gen(dist_gold6)
geodist x y  27.85 1.81,  gen(dist_gold7)
geodist x y  30.0 3.25,   gen(dist_gold8)

geodist x y  28.97 -2.15,  gen(dist_copper1)
geodist x y  29. -1.65,    gen(dist_copper2)
geodist x y  25.78 -3.35,  gen(dist_copper3)
geodist x y  26.3 -9.0,    gen(dist_copper4)
geodist x y  28.6 -12.6,   gen(dist_copper5)
geodist x y  28.95 -13.2,  gen(dist_copper6)
geodist x y  27.94 -12.23, gen(dist_copper7)

geodist x y  15.3 -4.3,  gen(dist_cement1)

geodist x y  19.2 -1.64,    gen(dist_zinc1)
geodist x y  27.28 -11.87,  gen(dist_zinc2)
geodist x y  15.35 -4.35,   gen(dist_zinc3)
geodist x y  29 -4.,        gen(dist_zinc4)

geodist x y  23.9 2.72,    gen(dist_diamond1)
geodist x y  23.55 -6.15,  gen(dist_diamond2)
geodist x y  14.9 -4.3,    gen(dist_diamond3)

geodist x y  25.9 -9.42,  gen(dist_coal1)

geodist x y  28.28 -8.9,  gen(dist_silver1)

geodist x y  27.63 -11.6,  gen(dist_acid1)

*generate a variable with the distance to the CLOSEST mine. This will be included
*in the regression

egen distmin_cobalt = rowmin(dist_cobalt*)
egen distmin_gold = rowmin(dist_gold*)
egen distmin_cement = rowmin(dist_cement*)
egen distmin_zinc = rowmin(dist_zinc*)
egen distmin_diamond = rowmin(dist_diamond*)
egen distmin_coal = rowmin(dist_coal*)
egen distmin_silver = rowmin(dist_silver*)
egen distmin_copper = rowmin(dist_copper*)
egen distmin_acid = rowmin(dist_acid*)


drop _merge
order x y year dhsclust adm1_pcode adm2_pcode v002 v003 distmin_cobalt distmin_gold  distmin_cement distmin_zinc distmin_diamond  distmin_coal distmin_silver distmin_copper distmin_acid

sort year dhsclust adm1_pcode adm2_pcode v002 v003


joinby year adm2_pcode using "`dta'\ACLED_buffer.dta", unmatched(both)
drop _merge


save  "`dta'\dhs_pr_mines_final.dta", replace

clear

*select useful variables, rename them and prepare the dataset for the analysis 

/* USEFUL VARIABLES
hv270 wealth index 
hv271 ''
sh256a b c d, sh258 until  264 child labor harmful/non harmful
hv108 edu years completed
hv124 current school year
sh261a labor with dust, fumes etc..
sh261f really dangerous labor
sh28* and sh29* measures of cognitive ability/deficiency
sh23 hospitalized in the last 4 weeks
*/

local dta ".\data\constructed"
local data ".\data\raw"
local tabfig  ".\output"

local dhs07 ".\data\raw\DRC_2007_DHS"
local dhs14 ".\data\raw\DRC_2013-14_DHS"


use "`dta'\dhs_pr_mines_final.dta", clear

sort dhsclust adm1_pcode adm2_pcode v002

label var sh21 hospitalized
rename hv104 gender
rename hv105 age
rename hv270 wealth 
rename hv107 edu_completed
rename hv124 current_edu

rename hv108 school_years

rename hv111 mother_alive
rename hv113 father_alive

rename hc61 motherschool

label var hv130 sick

label var sh206 worked
rename sh208 houseworkhours
rename sh205 workhours07
rename sh258 workhours14

rename sh204  work07
rename sh256d work14

label var sh259 heavyloads
label var sh260 dang_work

label var sh282 understand
label var sh283 diff_walk
label var sh285 learn_norm
label var sh290 retard

rename sh209  housework07
rename sh256a housework14

replace hv121= 1 if hv121==2

label variable edu_completed "Highest Education Year"
label variable gender "Gender"
label variable hv025 "Urban"


replace hv122 = 0 if hv122==9

gen sec_edu = 0
replace sec_edu=1 if hv122>=2
label variable sec_edu "Secondary Education"


*some lat and long have value= 0. Drop them
drop if (x==. & y==.)
drop if year==.

*housework07 and housework14 have some missing value with 9. Replace 9 with . 
foreach x in housework14 housework07 work07 work14 wealth{
replace  `x' = . if `x' ==9
}

*same thing for houseworkhours07 and houseworkhours14 have some missing value with 99. Replace 99 with . 
foreach x in housework07 housework14 workhours07 workhours14 edu_completed current_edu wealth gender ha40{
replace `x' = . if (`x' ==99 | `x' ==98 | `x' ==999 | `x' ==9999)
}

gen bmi =0
replace bmi = ha40*0.01

*create various age cohorts. Pre 1992 are individuals who in 2007 were older than 16 y.o. (control). 
*Post 1991 are individuals who in 2007 were at younger than 16 (treatment)

drop if age==.
gen birthc=0
replace birthc=2014-age if year==2014
replace birthc=2007-age if year==2007

save "`dta'\data_analysis.dta", replace 

