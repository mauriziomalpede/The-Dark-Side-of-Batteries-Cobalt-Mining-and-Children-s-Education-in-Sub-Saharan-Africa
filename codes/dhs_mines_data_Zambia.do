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
local zambia_dhs14 ".\data\raw\ZAMBIA_2013-2014_DHS"             

	*import and save as dta dhs gps for 2007 and 2014 

import delimited "`zambia_dhs07'\ZMGE52FL\ZMBGE52FL_admn2.csv", delimiter(comma)
rename latnum y
rename longnum x 
save  "`dta'\dhsgps07_zambia.dta", replace

clear

import delimited "`zambia_dhs14'\ZMGE61FL\ZMGE61FL_admn2.csv", delimiter(comma) 
rename latnum y
rename longnum x
save  "`dta'\dhsgps14_zambia.dta", replace
	
clear

	 *import 1st mining sites loation database in the DRC

import delimited "`data'\Mines_admn2_Zambia.csv", delimiter(";")
*rename x_new x
*rename y_new y 
keep x y f_name adm2_fr adm1_fr adm1_pcode adm2_pcode

rename f_name mine

save  "`dta'\Mines_admn2_Zambia.dta", replace

clear     

 
use  "`zambia_dhs07'\ZMPR51DT\ZMPR51FL.dta", clear
rename hv001 dhsclust
rename hv002 v002
rename hv003 v003
joinby dhsclust using "`dta'\dhsgps07_zambia.dta", unmatched(both)
drop _merge
gen year =2007
order x y year dhsclust
save  "`dta'\dhs_pr_complete07_Zambia.dta", replace


clear

use  "`zambia_dhs07'\ZMBR51DT\ZMBR51FL.dta", clear
rename v001 dhsclust
joinby dhsclust using "`dta'\dhsgps07_zambia.dta", unmatched(both)
drop _merge
gen year =2007
order x y year dhsclust
save  "`dta'\dhs_br_complete07_Zambia.dta", replace


clear

use  "`zambia_dhs14'\ZMPR61DT\ZMPR61FL.dta", clear
rename hv001 dhsclust
rename hv002 v002
rename hv003 v003
joinby dhsclust using "`dta'\dhsgps14_zambia.dta", unmatched(both)
drop _merge
gen year =2014
order x y year dhsclust
save  "`dta'\dhs_pr_complete14_zambia.dta", replace

clear

use  "`zambia_dhs14'\ZMBR61DT\ZMBR61FL.dta", clear
rename v001 dhsclust
joinby dhsclust using "`dta'\dhsgps14_zambia.dta", unmatched(both)
drop _merge
gen year =2014
order x y year dhsclust
save  "`dta'\dhs_br_complete14_zambia.dta", replace

clear


*Now consider PR recode only and keep only relevant variables:

use  "`dta'\dhs_pr_complete07_Zambia.dta", clear
rename  prov_code adm1_pcode 
rename  dist_code adm2_pcode
* help family with farm/business
* works for someoneelse other than family
* average number of hours child spent on housework activities (non harmful child labor)
* average current school year
* average highest edu level completed 
* average wealth index
keep  x y year dhsclust adm1_pcode adm2_pcode v002 v003 hv104 hv004 hv005 hv006 hv007 hv008 hv009 hv025 hv102 hv105 hv124 hv107 hv108 hv111 hv113 hv121 hv122 hc61 hv270 hv130 hv131 hv132 ha40

save  "`dta'\dhs_pr_final07_zambia.dta", replace
clear

use  "`dta'\dhs_pr_complete14_zambia.dta", clear
rename  prov_code adm1_pcode 
rename  dist_code adm2_pcode
*keep only relevant variables:
*help family with farm/business
*average number of hours child spent on housework activities (non harmful child labor)
*activities that require heavy loads 
* average current school year
*average highest edu level completed
* average wealth index 
*hospitalized in the last 4 weeks 
*cognitive deficiency
keep x y year dhsclust adm1_pcode adm2_pcode v002 v003 hv004 hv005 hv006 hv007 hv008 hv009 hv025 hv102 hv104 hv105 hv107 hv108 hv111 hv113 hv121 hv122 hv124 hv244 hv245 hv246 hv270 hc61 sh25* sh26* sh28* sh29*  ha40 
save  "`dta'\dhs_pr_final14_zambia.dta", replace
clear

*Append both waves (2007 and 2014) in a unique file
use "`dta'\dhs_pr_final07_zambia.dta", clear
joinby x y year dhsclust adm1_pcode adm2_pcode v002 v003 hv025 ha40 hv102 hv104 hv105 hv107 hv108 hv111 hv113 hv121 hv122 hc61 hv124 hv004 hv005 hv006 hv007 hv008 hv009  hv270 using "`dta'\dhs_pr_final14_zambia.dta", unmatched(both)
drop _merge
order x y year dhsclust adm1_pcode adm2_pcode hv105
save  "`dta'\dhs_pr_final_zambia.dta", replace


*Create a dhs-mines file in which there is the distance of each individual to the closest mine 
use  "`dta'\dhs_pr_final_zambia.dta", clear
	*match with mining locations in the DRC

joinby x y using "`dta'\Mines_admn2_Zambia.dta", unmatched(both)

geodist x y  28.191	-12.823,  gen(dist_cobalt1)
geodist x y  28.209	-12.839,  gen(dist_cobalt2)
geodist x y  27.515	-12.198,  gen(dist_cobalt3)
geodist x y  27.790	-12.321,  gen(dist_cobalt4)
geodist x y  28.045	-12.660,  gen(dist_cobalt5)

*generate a variable with the distance to the CLOSEST mine. This will be included
*in the regression

egen distmin_cobalt = rowmin(dist_cobalt*)


drop _merge
order x y year dhsclust adm1_pcode adm2_pcode v002 v003 distmin_cobalt

sort year dhsclust adm1_pcode adm2_pcode v002 v003
tostring adm2_pcode, replace format(%6.0f)
save  "`dta'\dhs_pr_mines_final_zambia.dta", replace

clear


use "`dta'\dhs_pr_mines_final_zambia.dta", clear

sort dhsclust adm1_pcode adm2_pcode v002

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


replace hv121= 1 if hv121==2

label variable edu_completed "Highest Education Year"
label variable gender "Gender"
label variable hv025 "Urban"

*some lat and long have value= 0. Drop them
drop if (x==. & y==.)
drop if year==.

*housework07 and housework14 have some missing value with 9. Replace 9 with . 
foreach x in wealth{
replace  `x' = . if `x' ==9
}

*same thing for houseworkhours07 and houseworkhours14 have some missing value with 99. Replace 99 with . 
foreach x in edu_completed current_edu wealth gender ha40{
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

tostring adm2_pcode, replace format(%6.0f)
save "`dta'\data_analysis_zambia.dta", replace 
