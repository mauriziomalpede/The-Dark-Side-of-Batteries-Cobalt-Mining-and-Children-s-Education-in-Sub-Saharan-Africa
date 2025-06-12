clear
capture log close
set more off
set matsize 1000

cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication"

local dta ".\data\constructed"
local data ".\data\raw"
local tabfig  ".\output"

use "`dta'\dhs_pr_mines_final.dta", clear
joinby using "`dta'\dhs_pr_mines_final_zambia.dta", unmatched(both)
drop _merge
gen bmi =0
replace bmi = ha40*0.01 


sort dhsclust adm1_pcode adm2_pcode v002


* Generate cluster, adm2 e adm1 groups
egen clustergroup = group(year dhsclust)
sum clustergroup

egen adm2group = group(adm2_pcode)
sum adm2group

egen adm1group = group(adm1_pcode)
sum adm1group


** Generate an indicator variable if there is a cobalt deposit within 10km from the village
gen cobalt_dummy =0
replace cobalt_dummy= 1 if distmin_cobalt<11

gen pre = (year==2007)
gen post = (year==2014)

*Genarete the interaction variable: 1 if <15km from cobalt after 2007; 0 otherwise
gen cobalt_dummy_post =cobalt_dummy*post

label variable cobalt_dummy_post "Post x Cobalt Deposit"
label variable cobalt_dummy "Cobalt Mine within 10 km"

gen individual_id = _n

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

joinby using"`dta'\data_analysis_zambia.dta", unmatched(both)

rename sh204  outside07
rename sh259 outside14

label var sh281 "Hearing diff."
label var sh288 "Speaking diff."
label var sh283 "Walking diff."

label var sh290 "Mentally backward"

gen outside = .
replace outside = outside14 if year==2014
replace outside = outside07 if year==2007


replace hv121= 1 if hv121==2

drop if (x==. & y==.)
drop if year==.

foreach x in mother_alive father_alive{
replace  `x' = . if (`x' ==9 | `x' ==8) 
}


*housework have some missing value with 9. Replace 9 with . 
foreach x in  outside wealth{
replace  `x' = . if `x' ==9
}

*same thing for houseworkhours07 and houseworkhours14 have some missing value with 99. Replace 99 with . 
foreach x in outside edu_completed current_edu wealth gender ha40{
replace `x' = . if (`x' ==99 | `x' ==98 | `x' ==999 | `x' ==9999)
}

*create various age cohorts. Pre 1992 are individuals who in 2007 were older than 16 y.o. (control). 
*Post 1991 are individuals who in 2007 were at younger than 16 (treatment)

drop if age==.


preserve

drop if  distmin_cobalt >200

eststo clear

keep if age>5 & age<12
eststo:  acreg  outside cobalt_dummy_post cobalt_dummy i.age i.year#i.dhsclust, spatial latitude(x) longitude(y) dist(100)
eststo:  acreg  outside cobalt_dummy_post cobalt_dummy i.age i.year#i.adm2group gender hv102 hv025 hv009 , spatial latitude(x) longitude(y) dist(100)
eststo:  acreg  outside cobalt_dummy_post cobalt_dummy i.age i.year#i.adm2group gender hv102 hv025 hv009 v002, spatial latitude(x) longitude(y) dist(100)

eststo:  acreg  hv121 cobalt_dummy_post cobalt_dummy i.age i.year#i.dhsclust, spatial latitude(x) longitude(y) dist(100)
eststo:  acreg  hv121 cobalt_dummy_post cobalt_dummy i.age i.year#i.adm2group gender hv102 hv025 hv009 , spatial latitude(x) longitude(y) dist(100)
eststo:  acreg  hv121 cobalt_dummy_post cobalt_dummy i.age i.year#i.adm2group gender hv102 hv025 hv009 v002, spatial latitude(x) longitude(y) dist(100)

esttab using  "`tabfig'\Tab_children_6_11.tex" , label ///
replace cells(b(star fmt(3) label(Coef.)) se(par fmt(3) label(SE))) keep(cobalt_dummy_post cobalt_dummy ) ///
starlevels(* 0.10 ** 0.05 *** 0.01) ///   
nonumbers mtitles("Employed" "Employed" "Employed" "School" "School" "School" )   ///
title(Cobalt Mining Exposure and Child Labor outcomes \label{childlabor6_11})
eststo clear

restore
 

preserve 
drop if  distmin_cobalt >200
keep if age>=12 & age<20
eststo:  acreg  outside cobalt_dummy_post cobalt_dummy i.age i.year#i.dhsclust, spatial latitude(x) longitude(y) dist(100)
eststo:  acreg  outside cobalt_dummy_post cobalt_dummy i.age i.year#i.adm2group gender hv102 hv025 hv009 , spatial latitude(x) longitude(y) dist(100)
eststo:  acreg  outside cobalt_dummy_post cobalt_dummy i.age i.year#i.adm2group gender hv102 hv025 hv009 v002, spatial latitude(x) longitude(y) dist(100)

eststo:  acreg  hv121 cobalt_dummy_post cobalt_dummy i.age i.year#i.dhsclust, spatial latitude(x) longitude(y) dist(100)
eststo:  acreg  hv121 cobalt_dummy_post cobalt_dummy i.age i.year#i.adm2group gender hv102 hv025 hv009 , spatial latitude(x) longitude(y) dist(100)
eststo:  acreg  hv121 cobalt_dummy_post cobalt_dummy i.age i.year#i.adm2group gender hv102 hv025 hv009 v002, spatial latitude(x) longitude(y) dist(100)

esttab using  "`tabfig'\Tab_children_12_20.tex" , label ///
replace cells(b(star fmt(3) label(Coef.)) se(par fmt(3) label(SE))) keep(cobalt_dummy_post cobalt_dummy ) ///
starlevels(* 0.10 ** 0.05 *** 0.01) ///   
nonumbers mtitles("Employed" "Employed" "Employed" "School" "School" "School" )   ///
title(Cobalt Mining Exposure and Child Labor outcomes \label{childlabor12_20})
eststo clear

restore
