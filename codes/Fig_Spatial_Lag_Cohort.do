clear
capture log close
set more off
set matsize 1000

cd "C:\Users\Maurizio Malpede\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Replication"

local gis ".\OneDrive - Università degli Studi di Verona\Cobalt_DRC\Analysis GIS"
local dta ".\data\constructed"
local data ".\data\raw"
local tabfig  ".\output"

use  "`dta'\data_analysis.dta", clear

joinby using"`dta'\data_analysis_zambia.dta", unmatched(both)

* Generate the dummy variable with default value of 0
gen country = 0
* Replace with value 1 if "adm1_pcode" contains the letters "CD" (DRC)
replace country = 1 if strpos(adm1_pcode, "CD") > 0
* Replace with value 0 if "adm1_pcode" contains the letters "ZMB" (Zambia)
replace country = 0 if strpos(adm1_pcode, "ZMB") > 0
*/

											******* LONG TERM EFFECTS ********


	*keep now only those who are not too young and not too old.
	*We keep only those individuals who were above 15 in the 2014 and 2007 DHS waves (Adult)
keep if (birthc<=1999 & year==2014) | (birthc<=1999 & year==2007)

    ** The pre-cobalt boom cohorts are defined as those born before 1992 (these guys were >15 years old in 2007).
	** The post-cobalt boom cohorts are defined as those born after 1992 (these guys were <15 years old in 2007).
gen pre = (birthc<=1992)
gen post = (birthc>1992)


order  x y year age birthc pre post

** Generate cluster, adm2 e adm1 groups
egen clustergroup = group(year dhsclust)
sum clustergroup

egen adm2group = group(adm2_pcode)
sum adm2group

egen adm1group = group(adm1_pcode)
sum adm1group


** Generate an indicator variable if there is a cobalt deposit within 10km from the village
gen cobalt_dummy =0 if (distmin_cobalt>11)
replace cobalt_dummy= 1 if (distmin_cobalt<11)

*Genarete the interaction variable: 1 if <10km from cobalt after 2007; 0 otherwise
gen cobalt_dummy_post =cobalt_dummy*post


label variable cobalt_dummy_post "Post x Cobalt Deposit"


gen individual_id = _n



******************************** Cohort + Spatial Lag **********************************************

* 1) DEFINE THE COHORTS

gen cohort =0

replace cohort=1970 if (birthc==1960 | birthc==1961 | birthc==1962|birthc==1963 | birthc==1964 | birthc==1965) 
replace cohort=1973 if (birthc==1966 | birthc==1967 | birthc==1968|birthc==1969 | birthc==1970 ) 
replace cohort=1976 if (birthc==1971 | birthc==1972 | birthc==1973| birthc==1974 | birthc==1975 ) 
replace cohort=1979 if (birthc==1976 | birthc==1977 | birthc==1978 | birthc==1979 | birthc==1980)

replace cohort=1982 if (birthc==1980 | birthc==1981 | birthc==1982)

replace cohort=1985 if (birthc==1981 | birthc==1982 | birthc==1983 |birthc==1984 | birthc==1985)
replace cohort=1988 if (birthc==1986 | birthc==1987 | birthc==1988| birthc==1989 | birthc==1990)

replace cohort=1991 if (birthc==1990 | birthc==1991 | birthc==1992)

replace cohort=1993 if (birthc==1991 | birthc==1992 | birthc==1993)
replace cohort=1996 if (birthc==1994 | birthc==1995 | birthc==1996)
replace cohort=1999 if (birthc==1997 | birthc==1998 | birthc==1999)

order x y year age birthc cohort


* 2) DEFINE THE BINS FOR THE DISTANCE FROM COBALT Mines

gen cobalt_dummy10 =0 if distmin_cobalt>10
replace cobalt_dummy10= 1 if (distmin_cobalt<12)

gen cobalt_dummy20 =0 if (distmin_cobalt>80 )
replace cobalt_dummy20= 1 if (distmin_cobalt>15 & distmin_cobalt<=22)

gen cobalt_dummy30 =0 if (distmin_cobalt>80)
replace cobalt_dummy30= 1 if (distmin_cobalt>20 & distmin_cobalt<=40)

gen cobalt_dummy40 =0 if (distmin_cobalt>80 )
replace cobalt_dummy40= 1 if (distmin_cobalt>30 & distmin_cobalt<=40)

gen cobalt_dummy50 =0 if (distmin_cobalt>80 )
replace cobalt_dummy50= 1 if (distmin_cobalt>30 & distmin_cobalt<=50)

gen cobalt_dummy100 =0 if (distmin_cobalt>80 )
replace cobalt_dummy100= 1 if (distmin_cobalt>40 & distmin_cobalt<=70)


	* generate cohort effects and interactions
forvalues i = 1960/2000 {

  gen _Iindex10`i'   = (cohort==`i')*cobalt_dummy10 - (cohort==1991)*cobalt_dummy10
  gen _Iindex30`i' = (cohort==`i')*cobalt_dummy30 
  gen _Iindex50`i' = (cohort==`i')*cobalt_dummy50
  gen _Iindex70`i' = (cohort==`i')*cobalt_dummy100

	label variable _Iindex10`i' `i'
	label variable _Iindex30`i' `i'
	label variable _Iindex50`i' `i'
	label variable _Iindex70`i' `i'
}
keep if distmin_cobalt <=100

reg edu_completed  _Iindex10* gender hv102 hv025  adm2group  if cohort!=1991, cluster(clustergroup) nocons


coefplot, omitted vertical plotregion(style(none)) keep(_Iindex101970 _Iindex101973 _Iindex101976 _Iindex101979 _Iindex101982 _Iindex101985 _Iindex101988 _Iindex101991 _Iindex101993 _Iindex101996 _Iindex101999) recast(connected) level(95)  pstyle(p3) ///
	ytit("Education" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	ylab(-2 -1 0 1 2) ///
	xline(8) ////
	xtit("Birth Cohorts", margin(medsmall)) ///
	subtit("0-20 km") 
 graph save A, replace


reg edu_completed  _Iindex30*  gender hv102 hv025 adm2group if cohort!=1991, cluster(clustergroup) nocons

coefplot, omitted vertical plotregion(style(none)) keep(_Iindex301970 _Iindex301973 _Iindex301976 _Iindex301979 _Iindex301982 _Iindex301985 _Iindex301988 _Iindex301991 _Iindex301993 _Iindex301996 _Iindex301999) recast(connected) level(90)  pstyle(p3) ///
	ytit("Education" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	ylab(-3 -2 -1 0 1 2 3) ///
	xline(8) ////
	xtit("Birth Cohorts", margin(medsmall)) ///
	subtit("20-40 km") 
 graph save B, replace

reg edu_completed  _Iindex50*  gender hv102 hv025 adm2group if cohort!=1991, cluster(clustergroup) nocons

coefplot, omitted vertical plotregion(style(none)) keep(_Iindex501970 _Iindex501973 _Iindex501976 _Iindex501979 _Iindex501982 _Iindex501985 _Iindex501988 _Iindex501991 _Iindex501993 _Iindex501996 _Iindex501999) recast(connected) level(90)  pstyle(p3) ///
	ytit("Education" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	ylab(-3 -2 -1 0 1 2 3) ///
	xline(8) ////
	xtit("Birth Cohorts", margin(medsmall)) ///
	subtit("40-60 km") 
 graph save C, replace

reg edu_completed  _Iindex70*  gender hv102 hv025 adm2group if cohort!=1991, cluster(clustergroup) nocons

coefplot, omitted vertical plotregion(style(none)) keep(_Iindex701970 _Iindex701973 _Iindex701976 _Iindex701979 _Iindex701982 _Iindex701985 _Iindex701988 _Iindex701991 _Iindex701993 _Iindex701996 _Iindex701999) recast(connected) level(90)  pstyle(p3) ///
	ytit("Education" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	ylab(-3 -2 -1 0 1 2 3) ///
	xline(8) ////
	xtit("Birth Cohorts", margin(medsmall)) ///
	subtit("60-80 km") 
 graph save D, replace

graph combine A.gph B.gph C.gph D.gph, title()
		 graph export "`tabfig'\cohorts_spatial_edu.png", as(png) replace


reg school_years  _Iindex10* gender hv102 hv025  adm2group  if cohort!=1991, cluster(clustergroup) nocons


coefplot, omitted vertical plotregion(style(none)) keep(_Iindex101970 _Iindex101973 _Iindex101976 _Iindex101979 _Iindex101982 _Iindex101985 _Iindex101988 _Iindex101991 _Iindex101993 _Iindex101996 _Iindex101999) recast(connected) level(95)  pstyle(p3) ///
	ytit("School Years" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	xline(8) ////
	xtit("Birth Cohorts", margin(medsmall)) ///
	subtit("0-20 km") 
 graph save E, replace


reg school_years  _Iindex30*  gender hv102 hv025 adm2group if cohort!=1991, cluster(clustergroup) nocons

coefplot, omitted vertical plotregion(style(none)) keep(_Iindex301970 _Iindex301973 _Iindex301976 _Iindex301979 _Iindex301982 _Iindex301985 _Iindex301988 _Iindex301991 _Iindex301993 _Iindex301996 _Iindex301999) recast(connected) level(90)  pstyle(p3) ///
	ytit("School Years" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	xline(8) ////
	xtit("Birth Cohorts", margin(medsmall)) ///
	subtit("20-40 km") 
 graph save F, replace

reg school_years  _Iindex50*  gender hv102 hv025 adm2group if cohort!=1991, cluster(clustergroup) nocons

coefplot, omitted vertical plotregion(style(none)) keep(_Iindex501970 _Iindex501973 _Iindex501976 _Iindex501979 _Iindex501982 _Iindex501985 _Iindex501988 _Iindex501991 _Iindex501993 _Iindex501996 _Iindex501999) recast(connected) level(90)  pstyle(p3) ///
	ytit("School Years" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	xline(8) ////
	xtit("Birth Cohorts", margin(medsmall)) ///
	subtit("40-60 km") 
 graph save G, replace

reg school_years  _Iindex70*  gender hv102 hv025 adm2group if cohort!=1991, cluster(clustergroup) nocons

coefplot, omitted vertical plotregion(style(none)) keep(_Iindex701970 _Iindex701973 _Iindex701976 _Iindex701979 _Iindex701982 _Iindex701985 _Iindex701988 _Iindex701991 _Iindex701993 _Iindex701996 _Iindex701999) recast(connected) level(90)  pstyle(p3) ///
	ytit("School Years" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	xline(8) ////
	xtit("Birth Cohorts", margin(medsmall)) ///
	subtit("60-80 km") 
 graph save H, replace

graph combine E.gph F.gph G.gph H.gph, title()
		 graph export "`tabfig'\Fig_Spatial_Lag_Cohorts_school.png", as(png) replace
