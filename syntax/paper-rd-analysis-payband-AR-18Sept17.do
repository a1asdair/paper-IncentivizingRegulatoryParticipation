// Fundraising regulation Data

// Analysis for paper



global projpath = "C:\Users\ar34\Dropbox\Academic\Academic-Research-Projects\Fundraising-Regulator-Data"
global csvpath = "$projpath/csv"
global statapath = "$projpath/stata"
global outputpath = "$projpath/output"
global refpath = "$projpath/refreshdata"

local fdate = "12Sept17"

local numf = "%12.0fc"

use  "$statapath/frexpvol-analysis-`fdate'.dta", clear

gen frstatus = frlevystatus!=.

recode exp_vol2014 	(0/99999.99 = 0 "Non-Levy Payer")	///
					(100000/149999.99 = 1 "Levy £150")	///
					(150000/199999.99 = 2 "Levy £300")	///
					(200000/499999.99 = 3 "Levy £800")	///
					(500000/999999.99 = 4 "Levy £1,500")	///
					(1000000/1999999.99 = 5 "Levy £2,500")	///
					(2000000/4999999.99 = 6 "Levy £4,000")	///
					(5000000/9999999.99 = 7 "Levy £6,000")	///
					(10000000/19999999.99 = 8 "Levy £8,000")	///
					(20000000/49999999.99 = 9 "Levy £12,000")	///
					(50000000/9999999999999 = 10 "Levy £15,000"),	///
					gen(payband)
	
local thresh1 = 100000 
local thresh2 = 150000 
local thresh3 = 200000 
local thresh4 = 500000 
local thresh5 = 1000000 
local thresh6 = 2000000 
local thresh7 = 5000000 
local thresh8 = 10000000 
local thresh9 = 20000000 
local thresh10 = 50000000 

local pay1 = "Levy £150"
local pay2 = "Levy £300"	
local pay3 = "Levy £800"	
local pay4 = "Levy £1,500"	
local pay5 = "Levy £2,500"	
local pay6 = "Levy £4,000"	
local pay7 = "Levy £6,000"	
local pay8 = "Levy £8,000"	
local pay9 = "Levy £12,000"	
local pay10 = "Levy £15,000"


// DESCRIPTIVES

tab zoom paid
tab zoom paid, row nofreq

// Graph of fundraisig expenditure by total income

local axtcol = "gs9"
local ms = "tiny"
local tr = 80


		
// Model:Local RDD Model		
// Estimate on balanced range i.e £1 to £100k and £100k to £200k



matrix define results1 = [1, 2, 3, 4, 5]  

forvalue ii = 2(1)7 {		// Only enough observations to go to £5M (category 7)

	local lower = 0.5 * `thresh`ii''
	local upper = 1.5 * `thresh`ii''
	if `lower' <100000 {
		local lower = 100000
	}

	di "Threshold: `thresh`ii'', lower `lower' upper `upper'"
	
	local threshlabel : di %12.0fc `thresh`ii''/1000
	
	rdplot paid exp_vol2014 if exp_vol2014>=`lower' & exp_vol2014<`upper'  , c(`thresh`ii'') p(1) ///
		graph_options(		note("Threshold £`threshlabel'k at `pay`ii''")   ///
		legend(off) ///
		ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(vsmall)) yscale(lcolor(`axtcol') range(0 1))  ylabel(0(0.2)1, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(vsmall)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white)) saving("$outputpath/ffrpaythresh`ii'", replace))
		
	local graphs = `"`graphs' "$outputpath/ffrpaythresh`ii'" "'
		
	rdrobust paid exp_vol2014 if exp_vol2014>=`lower' & exp_vol2014<`upper' , c(`thresh`ii'')
 	matrix list e(beta_p_l)
	matrix lowres = e(beta_p_l)
	scalar low`ii' = lowres[1,1]
//	replace lowt = lowres[1,1] if payband==`ii'
	
	matrix list e(beta_p_r)
	matrix hires = e(beta_p_r)
	scalar hi`ii' = hires[1,1]
//	replace hit = hires[1,1] if payband==`ii'	

	
  // scalar mthresh = `ii'
  scalar tau = e(tau_cl) 
  scalar tse = e(se_tau_cl) 
  scalar tser = e(se_tau_rb) 
  scalar mn = e(N)
  matrix results1 = [results1 \ `ii' , tau , tse , tser , mn ]	
	
}

matrix list results1

graph combine `graphs', saving("$outputpath/ffrpaythresh_combined", replace) 	///
	note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8))	 ///
	scheme(s1mono) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none))   ///
	graphregion(fcolor(white))
graph export "$outputpath/fig7_RDDplotwide_PayBandModels_`fdate'.png", replace width(4096)	
	
	
use "$statapath/paybandg.dta", clear		

replace expvol = expvol*1000

capture drop lowt hit
gen lowt=.
gen hit = .

local perc = 0.03



forvalues ii = 1(1)7 {
	gen pt`ii' = .

	capture drop t
	gen t = round((1 - `perc') * threshold`ii',500)
	replace lowt =  low`ii' if expvol==t
	replace pt`ii' = lowt if expvol==t
	
	capture drop t
	gen t = round((1+`perc') * threshold`ii',500)
	replace hit =  hi`ii' if expvol==t
	replace pt`ii' = hit if expvol==t

	
}

local lc = "gs15"
local lcl = "gs13"


twoway 	(line lowt threshold1, lcolor(`lc'))			///
		(line lowt threshold2, lcolor(`lc'))			///
		(line lowt threshold3, lcolor(`lc'))			///
		(line lowt threshold4, lcolor(`lc'))			///
		(line lowt threshold5, lcolor(`lc'))			///
		(line lowt threshold6, lcolor(`lc'))			///
		(line lowt threshold7, lcolor(`lc'))			///
		(scatter lowt expvol) 			///
		(scatter hit expvol) 			///
		if payband<=7 & expvol>=50000,		///
		yscale(range(0.2 0.8))				///
		legend(order(7 8))					///
		xscale(log)
		
		
local numf = "%12.0fc"
local axtcol = "gs9"
local ms = "tiny"

// This graph summarises the RDs at each payment threshold
		
twoway 	(line lowt threshold1, lcolor(`lc'))			///
		(line lowt threshold2, lcolor(`lc'))			///
		(line lowt threshold3, lcolor(`lc'))			///
		(line lowt threshold4, lcolor(`lc'))			///
		(line lowt threshold5, lcolor(`lc'))			///
		(line lowt threshold6, lcolor(`lc'))			///
		(line lowt threshold7, lcolor(`lc'))			///
		(connect pt1 expvol, lcolor(`lcl'))							///
		(connect pt2 expvol, lcolor(`lcl'))							///
		(connect pt3 expvol, lcolor(`lcl'))							///
		(connect pt4 expvol, lcolor(`lcl'))							///
		(connect pt5 expvol, lcolor(`lcl'))							///
		(connect pt6 expvol, lcolor(`lcl'))							///
		(connect pt7 expvol, lcolor(`lcl'))							///
		(scatter lowt expvol) 			///
		(scatter hit expvol) 			///
		if payband<=7 & expvol>=50000,		///
		yscale(range(0.2 0.8))				///
		legend(order(15 16))					///
		title("", color(gs2)) ///
		ytitle("Proportion", axis(1) color(`axtcol') size(small)) yscale(axis(1) lcolor(`axtcol')) ylabel(, axis(1) labcolor(`axtcol') labsize(small)) ///
		xtitle("Expenditure on Fundraising (£,000)", color(`axtcol')) xscale(log range() lcolor(`axtcol')) xlabel(100000  1000000 5000000, format("`numf'") noticks labcolor(`axtcol')) ///								
		bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white))	
	
// graph export "$outputpath/fig6_ModelThree_RDDplotlocal_`fdate'.png", replace width(4096)

// rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000 , c(100000) 
