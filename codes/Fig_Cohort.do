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



***********************                    Cohort Analysis           ************************************

preserve


gen cohort =0

replace cohort=1961 if (birthc==1960 | birthc==1961| birthc==1962) 
replace cohort=1964 if (birthc==1963 | birthc==1964| birthc==1965) 
replace cohort=1967 if (birthc==1966 | birthc==1967| birthc==1968) 
replace cohort=1970 if (birthc==1969 | birthc==1970| birthc==1971) 
replace cohort=1973 if (birthc==1972 | birthc==1973| birthc==1974) 
replace cohort=1976 if (birthc==1975 | birthc==1976| birthc==1977)
replace cohort=1979 if (birthc==1978 | birthc==1979| birthc==1980)
replace cohort=1982 if (birthc==1981 | birthc==1982| birthc==1983)
replace cohort=1985 if (birthc==1984 | birthc==1985| birthc==1986)
replace cohort=1988 if (birthc==1987 | birthc==1988| birthc==1989)
replace cohort=1991 if (birthc==1990 | birthc==1991| birthc==1992)
replace cohort=1993 if (birthc==1993 | birthc==1994| birthc==1995)
replace cohort=1996 if (birthc==1996 | birthc==1997)
replace cohort=1999 if (birthc==1998 | birthc==1999)  


order x y year age birthc cohort

	* generate cohort effects and interactions
forvalues i = 1961/2000 {

  gen _Ichrt`i' = (cohort==`i')*cobalt_dummy -  (cohort==1991)*cobalt_dummy 

	label variable _Ichrt`i' "`i'"

}
keep if distmin_cobalt <=200

keep if hv102 ==1
reg edu_completed  _Ichrt*  wealth gender hv102 hv025 hv009 i.year#i.adm2group, cluster(clustergroup) nocons

coefplot, omitted vertical plotregion(style(none)) keep(_Ichrt1970 _Ichrt1973 _Ichrt1976 _Ichrt1979 _Ichrt1982 _Ichrt1985 _Ichrt1988 _Ichrt1991 _Ichrt1993 _Ichrt1996 _Ichrt1999) recast(connected) level(99)  pstyle(p3) ///
	ytit("Highest Completed Education Year" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	xline(8) ////
	ylab(-3 -2 -1 0 1 2 3) ///
	xtit("Birth Cohorts", margin(medsmall)) 

graph export "`tabfig'\Fig_Cohort.png", as(png) replace

reg school_years  _Ichrt*  wealth gender hv102 hv025 hv009 i.year#i.adm2group, cluster(clustergroup) nocons

coefplot, omitted vertical plotregion(style(none)) keep(_Ichrt1970 _Ichrt1973 _Ichrt1976 _Ichrt1979 _Ichrt1982 _Ichrt1985 _Ichrt1988 _Ichrt1991 _Ichrt1993 _Ichrt1996 _Ichrt1999) recast(connected) level(99)  pstyle(p3) ///
	ytit("School Years" "Parameter Estimates", margin(medsmall)) ///
	yline(0) ///
	xline(8) ////
	ylab(-5 -4 -3 -2 -1 0 1 2 3 4 5 ) ///
	xtit("Birth Cohorts", margin(medsmall))

graph export "`tabfig'\Fig_Cohort_school_years.png", as(png) replace

restore
