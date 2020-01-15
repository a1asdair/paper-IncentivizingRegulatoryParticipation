// Fundraising regulation Data

// Analysis for paper


/* Alasdair paths */

global projpath = "C:\Users\ar34\Dropbox\Academic\Academic-Research-Projects\Fundraising-Regulator-Data"
global csvpath = "$projpath/csv"
global statapath = "$projpath/stata"
global outputpath = "$projpath/output"
global refpath = "$projpath/refreshdata"

/* Diarmuid paths */
/*	
	global projpath = "C:\Users\mcdonndz-local\Desktop\github\paper-fr-rdd"
	global statapath = "$projpath\statadata"
	global outputpath = "$projpath\output"
	global refpath = "$projpath\refreshdata"
*/

local fdate = "12Sept17"
local numf = "%12.0fc"

use  "$statapath\frexpvol-analysis-`fdate'.dta", clear

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
	tab payband				

// DESCRIPTIVES

tab zoom paid
tab zoom paid, row nofreq

// Graph of fundraisig expenditure by total income

local axtcol = "gs9"
local ms = "tiny"
local tr = 80

twoway 	(scatter exp_vol2014 inc_total2014 if zoom==0, msize(`ms')  mcolor(dknavy) msymbol(circle))	///
		(scatter exp_vol2014 inc_total2014 if (zoom==1 | zoom==2), msize(`ms')  mcolor(cranberry) msymbol(circle)), ///
		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
		legend(region(lwidth(none)) label(1 "Below the threshold") label(2 "Above the threshold") order(1 2) size(vsmall)) ///
		ytitle("Spend on generating voluntary income in 2014 (£s)" " ", color(`axtcol') size(small)) yscale(log lcolor(`axtcol') )  ylabel(10000 100000 1000000 10000000, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		xtitle(" " "Total Income in 2014 (£s)", color(`axtcol') size(small)) xscale(log lcolor(`axtcol')) xlabel(1000000 10000000, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white))
		
*graph export "$outputpath/fig1_LevyCharities`fdate'.png", replace width(4096)		

twoway 	(scatter exp_vol2014 inc_total2014 if zoom==0 & paid==0, msize(`ms')  mcolor(gs14) msymbol(circle))	///
		(scatter exp_vol2014 inc_total2014 if (zoom==1 | zoom==2) & paid==0, msize(`ms')  mcolor(gs14) msymbol(circle)) ///
		(scatter exp_vol2014 inc_total2014 if zoom==0 & paid==1, msize(`ms')  mcolor(dknavy) msymbol(circle))	///
		(scatter exp_vol2014 inc_total2014 if (zoom==1 | zoom==2) & paid==1, msize(`ms')  mcolor(cranberry) msymbol(circle)), ///
		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
		legend(region(lwidth(none)) label(3 "Below the threshold") label(4 "Above the threshold") order(3 4) size(vsmall)) ///
		ytitle("Spend on generating voluntary income in 2014 (£s)" " ", color(`axtcol') size(small)) yscale(log lcolor(`axtcol') )  ylabel(10000 100000 1000000 10000000, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		xtitle(" " "Total Income in 2014 (£s)", color(`axtcol') size(small)) xscale(log lcolor(`axtcol')) xlabel(1000000 10000000, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white))
		
*graph export "$outputpath/fig2_PaymentStatus`fdate'.png", replace width(4096)

// MODELLING

// Model 1: Logistic regression of treatment effect

logit paid thresh exp_vol2014, or // if exp_vol2014>=1 & exp_vol2014<5000000
capture drop prpaid1
predict prpaid1, pr

local ms = "tiny"

twoway 	(scatter prpaid1 exp_vol2014 if paid==0 & zoom==0, msize(`ms')  mcolor(gs8) msymbol(circle))		///
		(scatter prpaid1 exp_vol2014 if (zoom==1 | zoom==2) & paid==0, msize(`ms')  mcolor(erose) msymbol(circle))	///
		(scatter prpaid1 exp_vol2014 if paid==1 & zoom==0, msize(`ms')  mcolor(dknavy%`tr') msymbol(circle))		///
		(scatter prpaid1 exp_vol2014 if (zoom==1 | zoom==2) & paid==1, msize(`ms')  mcolor(cranberry%`tr') msymbol(circle))	///
		if exp_vol2014>100,		///
		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
		legend(region(lwidth(none)) label(1 "Not Paid") label(2 "Paid") order(1 2) size(vsmall)) ///
		ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(0(0.2)1, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		xtitle(" " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(log lcolor(`axtcol')) xlabel(10000 100000 1000000 10000000, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white))
		
*graph export "$outputpath/fig3_ModelOne_Logit_`fdate'.png", replace width(4096)

// Model 2: Linear Probability Model (OLS)

reg paid thresh exp_vol2014
capture drop prpaid2
predict prpaid2, 

twoway 	(scatter prpaid2 exp_vol2014 if paid==0 & zoom==0, msize(`ms')  mcolor(gs8) msymbol(circle))		///
		(scatter prpaid2 exp_vol2014 if (zoom==1 | zoom==2) & paid==0, msize(`ms')  mcolor(erose) msymbol(circle))	///
		(scatter prpaid2 exp_vol2014 if paid==1 & zoom==0, msize(`ms')  mcolor(dknavy%`tr') msymbol(circle))		///
		(scatter prpaid2 exp_vol2014 if (zoom==1 | zoom==2) & paid==1, msize(`ms')  mcolor(cranberry%`tr') msymbol(circle))	///
		if exp_vol2014>100,		///
		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
		legend(region(lwidth(none)) label(1 "Not Paid") label(2 "Paid") order(3 4) size(vsmall)) ///
		ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(0(0.2)1, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		xtitle(" " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(log lcolor(`axtcol')) xlabel(10000 100000 1000000 10000000, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white))
		
*graph export "$outputpath/fig4_ModelTwo_LinProb_`fdate'.png", replace width(4096)

// Model 3: Wide Range RDD Model
// Estimate on wide sample range £1k to £10M 
rdplot paid exp_vol2014 if exp_vol2014>=1000 & exp_vol2014<10000000  , c(100000) p(1) /// 
		graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
		legend(region(lwidth(none)) size(vsmall)) ///
		ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale( log lcolor(`axtcol')) xlabel(10000 100000 1000000 10000000, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white)))

*graph export "$outputpath/fig5_ModelThree_RDDplotwide_`fdate'.png", replace width(4096)		

rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<100000000 , c(100000) p(1)
		
// Model 4: Local RDD Model		
// Estimate on balanced range i.e £1 to £100k and £100k to £200k
rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) ///
		graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
		legend(region(lwidth(none)) size(vsmall)) ///
		ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
		scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white)))
		
*graph export "$outputpath/fig6_ModelThree_RDDplotlocal_`fdate'.png", replace width(4096)

rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000 , c(100000) p(1)
*rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000 , c(100000) p(2)
**rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000 , c(100000) p(3)
**rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000 , c(100000) p(4)



	/* RD diagnostics */
	
	/*
		Testing the assumptions and specifications of our RD design. The following checklist is adopted from Lee & Lemieux (2010):
		
			1. Histogram of assignment variable [DONE]
			2. RD graph using binned local averages [DONE]
			3. Overlay RD graph with a low-order polynomial [DONE; see Model 3]
			4. Sensitivity analysis: alternative polynomials and ranges of bandwidths [DONE]
			5. Check for discontinuties in baseline covariates
			6. Sensitivity analysis: inclusion of baseline covariates in regression
	*/
	
		/* Model 4 (Local) */
		
		// 1. Histogram of assignment variable
		
		histogram exp_vol2014, normal
			gen ln_exp_vol2014 = ln(exp_vol2014)
			histogram ln_exp_vol2014, normal
			
			// Check for clustering around £100,000
			
			histogram exp_vol2014 if exp_vol2014 >= 1 & exp_vol2014 <=200000, normal ///
				note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
				legend(region(lwidth(none)) size(vsmall)) ///
				ytitle(, color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) nogrid) 	///
				xtitle(, color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
				scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
				graphregion(fcolor(white))
			
			graph export "$outputpath/diagnostic_histexpvol_`fdate'.png", replace width(1024)
			
		// Checklist items 2, 3 & 4
		
		// 1st order polynomial
		rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) ///
			graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
			legend(region(lwidth(none)) size(vsmall)) ///
			ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
			xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
			scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
			graphregion(fcolor(white)))

		graph export "$outputpath/fig6_ModelFour_RDDplotlocal_diagnosticp1_`fdate'.png", replace width(1024)	
			
		// 2nd order polynomial
		rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(2) ///
			graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
			legend(region(lwidth(none)) size(vsmall)) ///
			ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
			xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
			scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
			graphregion(fcolor(white)))
			
		graph export "$outputpath/fig6_ModelFour_RDDplotlocal_diagnosticp2_`fdate'.png", replace width(1024)		

		// 3rd order polynomial
		rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(3) ///
			graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
			legend(region(lwidth(none)) size(vsmall)) ///
			ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
			xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
			scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
			graphregion(fcolor(white)))
			
		graph export "$outputpath/fig6_ModelFour_RDDplotlocal_diagnosticp3_`fdate'.png", replace width(1024)		
		
		// 4th order polynomial
		rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(4) ///
			graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
			legend(region(lwidth(none)) size(vsmall)) ///
			ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
			xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
			scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
			graphregion(fcolor(white)))
			
		graph export "$outputpath/fig6_ModelFour_RDDplotlocal_diagnosticp4_`fdate'.png", replace width(1024)	
		
		// Try different bandwidth selectors for first-order polynomial 'rdrobust'
		rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1)
			ereturn list
		rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) bwselect(msetwo)
			ereturn list	
		rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) bwselect(msesum)
			ereturn list	
		rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) bwselect(msecomb1)
			ereturn list	
		rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) bwselect(msecomb2)
			ereturn list	
		/*
			It is clear that we should use a first-order polynomial to model the relationship between fundraising expenditure and the
			probability of paying the fundraising levy.
			
			Estimate of treatment effect is consistent across different bandwidth selection methods.
			
			rdrobust doesn't run for 3rd and 4th-order polynomials: 'Invertibility problem: check variability of running variable around cutoff'.
		*/

		
			// Assess different bin selection procedures (using the first-order polynomial)
			
			// mimicking-variance evenly spaced method using spacing estimators;
			rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) ///
					graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
					legend(region(lwidth(none)) size(vsmall)) ///
					title("Mimicking-variance evenly spaced method using spacing estimators", size(small)) ///
					ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
					graphregion(fcolor(white)))
			graph save $outputpath\esmv_rdplot.gph, replace	
			ereturn list
			
			
			// mimicking-variance evenly spaced method using polynomial regression
			rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) binselect(esmvpr) ///
					graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
					legend(region(lwidth(none)) size(vsmall)) ///
					title("Mimicking-variance evenly spaced method using polynomial regression", size(small)) ///
					ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
					graphregion(fcolor(white)))
			graph save $outputpath\esmvpr_rdplot.gph, replace			
			ereturn list

			// mimicking-variance quantile-spaced method using spacings estimators
			rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) binselect(qsmv) ///
					graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
					legend(region(lwidth(none)) size(vsmall)) ///
					title("Mimicking-variance quantile-spaced method using spacings estimators", size(small)) ///
					ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
					graphregion(fcolor(white)))
			graph save $outputpath\qsmv_rdplot.gph, replace			
			ereturn list

			// mimicking-variance quantile-spaced method using polynomial regression
			rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) binselect(qsmvpr) ///
					graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
					legend(region(lwidth(none)) size(vsmall)) ///
					title("Mimicking-variance quantile-spaced method using polynomial regression", size(small)) ///
					ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
					graphregion(fcolor(white)))
			graph save $outputpath\qsmvpr_rdplot.gph, replace
			ereturn list

			graph combine $outputpath\esmv_rdplot.gph $outputpath\esmvpr_rdplot.gph $outputpath\qsmv_rdplot.gph $outputpath\qsmvpr_rdplot.gph, ///
				saving($outputpath\bincomparison_rdplot.gph, replace)
								
			graph export "$outputpath/diagnostic_ModelFour_RDDplot_bins1_`fdate'.png", replace width(1024)	
			
			/*
				Good, now I need to capture the information on the number of bins behind each plot. It's captured in 'ereturn list' but
				I could do with putting it in a table.
			*/
				
		
			// integrated mean squared error (IMSE)-optimal evenly spaced method using spacing estimators
			rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) binselect(es) ///
					graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
					legend(region(lwidth(none)) size(vsmall)) ///
					title("IMSE-optimal evenly spaced method using spacing estimators", size(small)) ///
					ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
					graphregion(fcolor(white)))
			graph save $outputpath\es_rdplot.gph, replace
			ereturn list

			// IMSE-optimal evenly spaced method using polynomial regression
			rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) binselect(espr) ///
					graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
					legend(region(lwidth(none)) size(vsmall)) ///
					title("IMSE-optimal evenly spaced method using polynomial regression", size(small)) ///
					ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
					graphregion(fcolor(white)))
			graph save $outputpath\espr_rdplot.gph, replace
			ereturn list

			// IMSE-optimal quantile-spaced method using spacing estimators
			rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) binselect(qs) ///
					graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
					legend(region(lwidth(none)) size(vsmall)) ///
					title("IMSE-optimal quantile-spaced method using spacing estimators", size(small)) ///
					ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
					graphregion(fcolor(white)))
			graph save $outputpath\qs_rdplot.gph, replace
			ereturn list

			// IMSE-optimal quantile-spaced method using polynomial regression
			rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) p(1) binselect(qspr) ///
					graph_options(		note("Source: Data from Charity Commission & Fundraising Regulator    Produced: $S_DATE", size(vsmall) color(gs8)) ///
					legend(region(lwidth(none)) size(vsmall)) ///
					title("IMSE-optimal quantile-spaced method using polynomial regression", size(small)) ///
					ytitle("Estimated Probability of Paying" " ", color(`axtcol') size(small)) yscale(lcolor(`axtcol') )  ylabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					xtitle(" " " " "Spend on generating voluntary income in 2014 (£s)", color(`axtcol') size(small)) xscale(lcolor(`axtcol')) xlabel(, tlcolor(`axtcol') labcolor(`axtcol') labsize(vsmall) format(%-12.0gc) nogrid) 	///
					scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
					graphregion(fcolor(white)))
			graph save $outputpath\qspr_rdplot.gph, replace
			ereturn list
			
			graph combine $outputpath\es_rdplot.gph $outputpath\espr_rdplot.gph $outputpath\qs_rdplot.gph $outputpath\qspr_rdplot.gph, ///
				saving($outputpath\bincomparisontwo_rdplot.gph, replace)
				
			graph export "$outputpath/diagnostic_ModelFour_RDDplot_bins2_`fdate'.png", replace width(1024)	
				
			
