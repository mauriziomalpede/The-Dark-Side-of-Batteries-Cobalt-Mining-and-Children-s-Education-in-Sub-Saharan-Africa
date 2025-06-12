clear
capture log close
set more off
set matsize 1000

cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication"

local dta ".\data\constructed"
local data ".\data\raw"
local tabfig  ".\output"

use  "`dta'\data_analysis.dta", clear
joinby using"`dta'\data_analysis_zambia.dta", unmatched(both)

                      ******* LONG TERM EFFECTS ********


  *keep now only those who are not too young and not too old.
  *We keep only those individuals who were between 15 and 30 in the 2014 and 2007 DHS waves (Adult)
keep if (birthc>=1984 & birthc<=1999 & year==2014) | (birthc>=1977 & birthc<=1992 & year==2007)

    ** The pre-cobalt boom cohorts are defined as those born before 1992 (these guys were >15 years old in 2007).
  ** The post-cobalt boom cohorts are defined as those born after 1992 (these guys were <15 years old in 2007).
gen pre = (birthc<=1992)
gen post = (birthc>1992)

gen cob_village=0
replace cob_village=1 if distmin_cobalt<11

order  x y year age birthc pre post

** Generate cluster, adm2 e adm1 groups
egen clustergroup = group(year dhsclust)
sum clustergroup

egen adm2group = group(adm2_pcode)
sum adm2group

egen adm1group = group(adm1_pcode)
sum adm1group


** Generate an indicator variable if there is a cobalt deposit within 10km from the village
gen cobalt_dummy =0
replace cobalt_dummy= 1 if (distmin_cobalt<10)

*Genarete the interaction variable: 1 if <10km from cobalt after 2007; 0 otherwise
gen cobalt_dummy_post =cobalt_dummy*post

label variable cobalt_dummy_post "Post x Cobalt Deposit"
label variable cobalt_dummy "Cobalt Mine within 10 km"

gen individual_id = _n

                                      *********REGRESSIONS____ SELECTIVE MIGRATION********
preserve 

drop if  distmin_cobalt >200
keep if hv102 ==1
drop if (distmin_cobalt>10 ) & (wealth>4 & edu_completed>4 )
drop if (distmin_cobalt<10 ) & (wealth<2 & edu_completed<1 )

mean edu_completed school_years

eststo:  acreg  school_years cobalt_dummy_post cobalt_dummy i.birthc i.year#i.dhsclust, spatial latitude(x) longitude(y) dist(50)
eststo:  acreg  school_years cobalt_dummy_post cobalt_dummy i.birthc i.year#i.adm2group wealth gender hv102 hv025 , spatial latitude(x) longitude(y) dist(50)
eststo:  acreg  school_years cobalt_dummy_post cobalt_dummy i.birthc i.year#i.adm2group wealth gender hv102 hv025 i.year#i.dhsclust, spatial latitude(x) longitude(y) dist(100)

esttab using  "`tabfig'\Tab_migration.tex" , label ///
replace cells(b(star fmt(3) label(Coef.)) se(par fmt(3) label(SE))) keep(cobalt_dummy_post cobalt_dummy) ///
starlevels(* 0.10 ** 0.05 *** 0.01) ///   
nonumbers mtitles( "School Years" "School Years" "School Years")   ///
title(Childhood Cobalt Mining Exposure and Education Attainment: Selective Migration \label{migration2})
eststo clear



restore 
