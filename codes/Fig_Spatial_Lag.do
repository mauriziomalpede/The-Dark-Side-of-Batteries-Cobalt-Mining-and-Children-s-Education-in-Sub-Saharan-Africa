clear all
cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication"

local gis ".\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Analysis GIS"
local dta ".\data\constructed"
local data ".\data\raw"
local tabfig  ".\output"

set scheme s1color  

use  "`dta'\data_analysis.dta", clear

joinby using"`dta'\data_analysis_zambia.dta", unmatched(both)

* Generate the dummy variable with default value of 0
gen country = 0
* Replace with value 1 if "adm1_pcode" contains the letters "CD" (DRC)
replace country = 1 if strpos(adm1_pcode, "CD") > 0
* Replace with value 0 if "adm1_pcode" contains the letters "ZMB" (Zambia)
replace country = 0 if strpos(adm1_pcode, "ZMB") > 0

											******* LONG TERM EFFECTS ********


	*keep now only those who are not too young and not too old.
	*We keep only those individuals who were between 15 and 30 in the 2014 and 2007 DHS waves (Adult)
keep if (birthc>=1984 & birthc<=1999 & year==2014) | (birthc>=1977 & birthc<=1992 & year==2007)

    ** The pre-cobalt boom cohorts are defined as those born before 1992 (these guys were >15 years old in 2007).
	** The post-cobalt boom cohorts are defined as those born after 1992 (these guys were <15 years old in 2007).

gen pre = (birthc<=1992)
gen post = (birthc>1992)

gen cob_village=0
replace cob_village=1 if distmin_cobalt<10

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
replace cobalt_dummy= 1 if (distmin_cobalt<11)
** and the same from a artisanal-based cobalt mine
gen cobalt_art_dummy =0
gen cobalt_ch_dummy =0

** here I generate the placebo dummy on all other mines
gen mine_dummy =0
replace mine_dummy= 1 if (distmin_gold <20 | distmin_diamond <20| distmin_coal <20| distmin_silver <20)

*Genarete the interaction variable: 1 if <10km from cobalt after 2007; 0 otherwise
gen cobalt_dummy_post =cobalt_dummy*post
gen mine_dummy_post =mine_dummy*post

label variable cobalt_dummy_post "Post x Cobalt Deposit"
label variable mine_dummy_post "Post x Mine Deposit"
label variable mine_dummy "Mine within 10 km"

gen individual_id = _n

*********************** SPATIAL LAG ROBUSTNESS  *********************************


preserve

keep if distmin_cobalt <=200

** Generate bins!
gen cobalt_dummy10 =0 if (distmin_cobalt>100 & distmin_cobalt<=200)
replace cobalt_dummy10= 1 if (distmin_cobalt<11)

gen cobalt_dummy20 =0 if (distmin_cobalt>100 & distmin_cobalt<=200)
replace cobalt_dummy20= 1 if (distmin_cobalt>10 & distmin_cobalt<=30)

gen cobalt_dummy30 =0 if (distmin_cobalt>100 & distmin_cobalt<=200)
replace cobalt_dummy30= 1 if (distmin_cobalt>20 & distmin_cobalt<=30)

gen cobalt_dummy40 =0 if (distmin_cobalt>100 & distmin_cobalt<=200)
replace cobalt_dummy40= 1 if (distmin_cobalt>20 & distmin_cobalt<=50)

gen cobalt_dummy50 =0 if (distmin_cobalt>100 & distmin_cobalt<=200)
replace cobalt_dummy50= 1 if (distmin_cobalt>40 & distmin_cobalt<=70)

gen cobalt_dummy70 =0 if (distmin_cobalt>100 & distmin_cobalt<=200)
replace cobalt_dummy70= 1 if (distmin_cobalt>60 & distmin_cobalt<=80)

gen cobalt_dummy100 =0 if (distmin_cobalt>100 & distmin_cobalt<=200)
replace cobalt_dummy100= 1 if (distmin_cobalt>70 & distmin_cobalt<100)


*Genarate the interaction variable: 1 if <10km from cobalt after 2007; 0 otherwise
gen cobalt_dummy5_post =cobalt_dummy5*post
gen cobalt_dummy10_post =cobalt_dummy10*post
gen cobalt_dummy20_post =cobalt_dummy20*post
gen cobalt_dummy30_post =cobalt_dummy30*post
gen cobalt_dummy40_post =cobalt_dummy40*post
gen cobalt_dummy50_post =cobalt_dummy50*post
gen cobalt_dummy70_post =cobalt_dummy70*post
gen cobalt_dummy100_post =cobalt_dummy100*post


label variable cobalt_dummy5_post  "0-5   "
label variable cobalt_dummy10_post  "0-10 "
label variable cobalt_dummy20_post  "10-20"
label variable cobalt_dummy30_post  "20-30"
label variable cobalt_dummy40_post  "20-40"
label variable cobalt_dummy50_post  "40-60"
label variable cobalt_dummy70_post "60-80"
label variable cobalt_dummy100_post "80-100"

eststo clear

*edu
acreg  school_years cobalt_dummy10_post cobalt_dummy10 i.year#i.dhsclust wealth i.birthc gender hv102 hv025 i.year#i.adm2group events_year, spatial latitude(x) longitude(y) dist(30)
est store y1
acreg  school_years cobalt_dummy20_post cobalt_dummy20 i.year#i.dhsclust wealth i.birthc gender hv102 hv025 i.year#i.adm2group events_year, spatial latitude(x) longitude(y) dist(30)
est store y2
acreg  school_years cobalt_dummy40_post cobalt_dummy40 i.year#i.dhsclust wealth i.birthc gender hv102 hv025 i.year#i.adm2group events_year, spatial latitude(x) longitude(y) dist(30)
est store y4
acreg  school_years cobalt_dummy50_post cobalt_dummy50 i.year#i.dhsclust wealth i.birthc gender hv102 hv025 i.year#i.adm2group events_year, spatial latitude(x) longitude(y) dist(30)
est store y5
acreg  school_years cobalt_dummy70_post cobalt_dummy70 i.year#i.dhsclust wealth i.birthc gender hv102 hv025 i.year#i.adm2group events_year, spatial latitude(x) longitude(y) dist(30)
est store y6
acreg  school_years cobalt_dummy100_post cobalt_dummy100 i.year#i.dhsclust wealth i.birthc gender hv102 hv025 i.year#i.adm2group events_year, spatial latitude(x) longitude(y) dist(30)
est store y7

coefplot (y1, label(0-10  km) pstyle(p3)) ///
         (y2, label(10-20 km) pstyle(p3)) ///
         (y4, label(20-40 km) pstyle(p3)) ///
         (y5, label(40-60 km) pstyle(p3)) ///
         (y6, label(60-80 km) pstyle(p3)) ///
         (y7, label(80-100 km) pstyle(p3)) ///
, omitted vertical plotregion(style(none)) keep( cobalt_dummy10_post cobalt_dummy20_post cobalt_dummy30_post cobalt_dummy40_post cobalt_dummy50_post cobalt_dummy70_post cobalt_dummy100_post ) level(99) ///
	ytit("School Years" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	ylab(-5 -4 -3  -2  -1  0  1  2  3 4 5) ///
	xline(8) ////
	xtit("Distance from Cobalt Deposit (km)", margin(medsmall)) 

graph export "`tabfig'\Fig_Spatial_Lag.png", as(png) replace



restore

*/






*********************** SPATIAL LAG ROBUSTNESS DRC vs Zambia  *********************************
/*
preserve

keep if distmin_cobalt <=300

** Generate bins!
gen cobalt_dummy5 =0 if (distmin_cobalt>100 )
replace cobalt_dummy5= 1 if (distmin_cobalt<6)

gen cobalt_dummy10 =0 if (distmin_cobalt>100 )
replace cobalt_dummy10= 1 if (distmin_cobalt<10)


gen cobalt_dummy20 =0 if (distmin_cobalt>100 )
replace cobalt_dummy20= 1 if (distmin_cobalt>10 & distmin_cobalt<=20)


gen cobalt_dummy30 =0 if (distmin_cobalt>100 )
replace cobalt_dummy30= 1 if (distmin_cobalt>20 & distmin_cobalt<=30)


gen cobalt_dummy40 =0 if (distmin_cobalt>100 )
replace cobalt_dummy40= 1 if (distmin_cobalt>20 & distmin_cobalt<=45)


gen cobalt_dummy50 =0 if (distmin_cobalt>100 )
replace cobalt_dummy50= 1 if (distmin_cobalt>40 & distmin_cobalt<=70)


gen cobalt_dummy70 =0 if (distmin_cobalt>100 )
replace cobalt_dummy70= 1 if (distmin_cobalt>60 & distmin_cobalt<=80)


gen cobalt_dummy100 =0 if (distmin_cobalt>100 )
replace cobalt_dummy100= 1 if (distmin_cobalt>80 & distmin_cobalt<200)


*Genarate the interaction variable: 1 if <10km from cobalt after 2007; 0 otherwise
gen cobalt_dummy5_post =cobalt_dummy5*post
gen cobalt_dummy10_post =cobalt_dummy10*post
gen cobalt_dummy20_post =cobalt_dummy20*post
gen cobalt_dummy30_post =cobalt_dummy30*post
gen cobalt_dummy40_post =cobalt_dummy40*post
gen cobalt_dummy50_post =cobalt_dummy50*post
gen cobalt_dummy70_post =cobalt_dummy70*post
gen cobalt_dummy100_post =cobalt_dummy100*post

label variable cobalt_dummy5_post  "0-5   "
label variable cobalt_dummy10_post  "0-10 "
label variable cobalt_dummy20_post  "10-20"
label variable cobalt_dummy30_post  "20-30"
label variable cobalt_dummy40_post  "20-40"
label variable cobalt_dummy50_post  "40-60"
label variable cobalt_dummy70_post "60-80"
label variable cobalt_dummy100_post "80-100"

*keep if gender==1

*edu
acreg  edu_completed cobalt_dummy5_post cobalt_dummy5  wealth i.birthc gender hv102 hv025 i.year#i.adm2group, spatial latitude(x) longitude(y) dist(30)
est store y1
acreg  edu_completed cobalt_dummy10_post cobalt_dummy10  wealth i.birthc gender hv102 hv025 i.year#i.adm2group, spatial latitude(x) longitude(y) dist(30)
est store y2
acreg  edu_completed cobalt_dummy40_post cobalt_dummy40  wealth i.birthc gender hv102 hv025 i.year#i.adm2group, spatial latitude(x) longitude(y) dist(30)
est store y4
acreg  edu_completed cobalt_dummy50_post cobalt_dummy50  wealth i.birthc gender hv102 hv025 i.year#i.adm2group, spatial latitude(x) longitude(y) dist(30)
est store y5
acreg  edu_completed cobalt_dummy70_post cobalt_dummy70  wealth i.birthc gender hv102 hv025 i.year#i.adm2group, spatial latitude(x) longitude(y) dist(30)
est store y6
acreg  edu_completed cobalt_dummy100_post cobalt_dummy100  wealth i.birthc gender hv102 hv025 i.year#i.adm2group, spatial latitude(x) longitude(y) dist(30)
est store y7

coefplot (y1, label(0-10  km) pstyle(p3)) ///
         (y2, label(10-20 km) pstyle(p3)) ///
         (y4, label(20-40 km) pstyle(p3)) ///
         (y5, label(40-60 km) pstyle(p3)) ///
         (y6, label(60-80 km) pstyle(p3)) ///
         (y7, label(80-100 km) pstyle(p3)) ///
, omitted vertical keep(cobalt_dummy5_post cobalt_dummy10_post cobalt_dummy30_post cobalt_dummy40_post cobalt_dummy50_post cobalt_dummy70_post cobalt_dummy100_post  ) level(95) ///
	ytit("Education" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	ylab(-1 -0.5 0 0.5 1 ) ///
	xline(8) ////
	xtit("Distance from Cobalt Mine (km)", margin(medsmall)) ///
	subtit("Spatial Analysis: Education") 

graph export "`tabfig'\spatial_drc_zambia.png", as(png) replace



restore
