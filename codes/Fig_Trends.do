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

*Genarete the interaction variable: 1 if <10km from cobalt after 2007; 0 otherwise
gen cobalt_dummy_post =cobalt_dummy*post

label variable cobalt_dummy_post "Post x Cobalt Deposit"

gen individual_id = _n


************************************** FIGURE PARALLEL TRENDS ************************

*create a dummy which takes value = 1 id distmin_cobalt>10k and value 0 otherwise
preserve

gen treat_group = 0
replace treat_group =1 if (distmin_cobalt<11) 

gen control1 = 0
replace control1 =1 if (distmin_cobalt>=11 & distmin_cobalt <=100) 

gen control2 = 0
replace control2 =1 if (distmin_gold <=11 | distmin_diamond <=11 | distmin_coal <=11 | distmin_silver <=11 )

drop if (treat_group==0 & control1==0 & control2==0)

*Group year cohorts in pairwise years
gen cohort =0

replace cohort=1980 if (birthc==1980| birthc==1981)    
replace cohort=1982 if (birthc==1982| birthc==1983)
replace cohort=1984 if (birthc==1984| birthc==1985)
replace cohort=1986 if (birthc==1985| birthc==1986)
replace cohort=1988 if (birthc==1988| birthc==1989)
replace cohort=1990 if (birthc==1990| birthc==1991)
replace cohort=1992 if (birthc==1992| birthc==1993) 
replace cohort=1994 if (birthc==1994| birthc==1995)
replace cohort=1996 if (birthc==1996| birthc==1997) 
replace cohort=1998	if (birthc==1997| birthc==1999)

drop if cohort==0
*compute the sum of total children born in each birth cohort for treat_group and control groups
drop if edu_completed==.
sort cohort treat_group control1 control2
by  cohort treat_group control1 control2: egen avgedu = mean(edu_completed)


order x y dhsclust adm1_pcode adm2_pcode birthc cohort edu_completed avgedu treat_group control1 control2 distmin_cobalt

sort cohort distmin_cobalt  dhsclust avgedu


set scheme s1color  
graph twoway ///
connected avgedu cohort if treat_group == 1 , sort xline(1992, lpattern(dash))|| ///
connected avgedu cohort if control1 == 1 , sort xline(1992, lpattern(dash))|| ///
     ,title("Average Number of Years of Education Completed") ///
      ytitle("Education years per individual") ///
	xtit("Birth Cohort", margin(medsmall) size(small)) ///
	xlab(1980 1982 1984 1986 1988 1990 1992 1994 1996 1998) ///
      legend( order(1 "Treatment (cobalt <10km)" 2 "Control 1 (<10km cobalt <100km)"))
      graph export "`tabfig'\preliminary_education.png", as(png) replace



twoway 	(lfit edu_completed cohort if treat_group == 1 & inrange(cohort, 1980, 1992), c(l) clcolor(green) sort xline(1992, lpattern(dash))) ///
		(lfit edu_completed cohort if treat_group == 1 & inrange(cohort, 1992, 1998), c(l) clcolor(green) sort xline(1992, lpattern(dash))) ///
		(lfit edu_completed cohort if control1 == 1    & inrange(cohort, 1980, 1992), c(l) clcolor(red) sort xline(1992, lpattern(dash)))   ///
	   	(lfit edu_completed cohort if control1 == 1    & inrange(cohort, 1992, 1998), c(l) clcolor(red) sort xline(1992, lpattern(dash)))  


twoway 	(lpolyci edu_completed cohort if treat_group == 1 & inrange(cohort, 1980, 1998), clcolor(green) sort xline(1992, lpattern(dash))) ///
		(lpolyci edu_completed cohort if control1  == 1 & inrange(cohort, 1980, 1998), clcolor(red) sort xline(1992, lpattern(dash)))
		 graph save A, replace

twoway 	(lpolyci edu_completed cohort if treat_group == 1 & inrange(cohort, 1980, 1998), clcolor(green) sort xline(1992, lpattern(dash))) ///
		(lpolyci edu_completed cohort if control2  == 1 & inrange(cohort, 1980, 1998), clcolor(blue) sort xline(1992, lpattern(dash)))
		 graph save B, replace
graph combine A.gph B.gph, title(Local Polynomial Smooth) subt(Control1 and Control2)
		 graph export "`tabfig'\preliminary_education_poly.png", as(png) replace

restore
