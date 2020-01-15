// Fundraising regulation Data

// Combine released and scraped data



global projpath = "C:\Users\ar34\Dropbox\Academic\Academic-Research-Projects\Fundraising-Regulator-Data"
global csvpath = "$projpath/csv"
global statapath = "$projpath/stata"
global outputpath = "$projpath/output"
global refpath = "$projpath/refreshdata"

local fdate = "12Sept17"

local numf = "%12.0fc"


// Import the data that the Fundraising Regulator has released

import delimited "$csvpath/levyfromfr31Aug17.csv", varnames(1) clear 
rename regno charityid
gen long regno = real(charityid)
sort regno
replace regno = -(_n) if regno==.
encode outcome, gen(frlevystatus)
save "$statapath/frlevyfromfr31Aug17-`fdate'.dta", replace

// Import the scraped data

import delimited "$refpath/frcharsc-21Aug17.csv", varnames(1) clear 

tab regtype
// keep if regtype=="Levy Payer"
// keep if charityid !=""
// drop if frid=="id=0015800000XLrz8AAD"
gen long regno = real(charityid)
sum regno
tab levydate
// drop if regno==.
// gen levypayer = levydate=="31/8/2017"
// replace levypayer = 2 if (initdate!="" & initdate!=".")
// tab levypayer

keep regno frid regtype

tab regno if regno==., miss
keep if regno!=.

save "$statapath/frlevy`fdate'.dta", replace


// Get the detailed part B data

import delimited "$csvpath/extract_partb.csv", varnames(1) clear 
gen year = year(date(substr(fyend,1,10),"YMD"))
gen datefystart = date(substr(fystart,1,10),"YMD")
gen datefyend = date(substr(fyend,1,10),"YMD")
keep if year==2014 | year == 2015
gen yrl = datefyend - datefystart

duplicates tag year regno, gen(duptag)
sort duptag regno
drop if duptag ==1 & yrl<360
duplicates report year regno

keep regno yrl year inc_total exp_vol exp_total employees volunteers

reshape wide yrl inc_total exp_vol exp_total employees volunteers, i(regno) j(year)

save "$statapath/frexpvol2014.dta", replace


// Combine the datasets

merge 1:1 regno using "$statapath/frlevyfromfr31Aug17-`fdate'.dta", gen(_mfrlevy)
merge 1:1 regno using "$statapath/frlevy`fdate'.dta", keepusing(regtype frid) gen(_mfrscrape)


// Describe the datasets

tab regtype frlevystatus, miss

gen paid = (regtype=="FR Registered Charity" | regtype=="FR Registered Charity" | frlevystatus==3)
tab paid

gen thresh = exp_vol2014>=100000
tab thresh

gen zoom = .
replace zoom = 0 if thresh==0
replace zoom = 1 if thresh==1 & exp_vol2014<=200000
replace zoom = 2 if thresh==1 & exp_vol2014>200000
tab zoom

gen vertical = 100000

// Choose the analysis sample

keep if paid !=.
keep if thresh !=.
keep if exp_vol2014>0 & exp_vol2014!=.

// Ensure that the charity was still reporting in 2015
keep if exp_vol2015!=.

// Save dataset for paper analysis
save "$statapath/frexpvol-analysis-`fdate'.dta", replace


// Describe the sample

tab zoom paid
tab zoom paid, row nofreq


// Look at fluctuations around threshold across years
twoway (scatter  exp_vol2014 inc_total2014) if inc_total2014>1 & exp_vol2014>95000 & exp_vol2014<105000, xscale(log) yscale(log)
twoway (scatter  exp_vol2015 inc_total2015) if inc_total2015>1 & exp_vol2015>95000 & exp_vol2015<105000, xscale(log) yscale(log)
// twoway (scatter  exp_vol2016 inc_total2016) if inc_total2016>1 & exp_vol2016>95000 & exp_vol2016<105000, xscale(log) yscale(log)


twoway (line paid vertical) (scatter paid exp_vol2014 if paid==1, msize(tiny)) (scatter paid exp_vol2014 if paid==0, msize(tiny)) if exp_vol2014>0 & inc_total2015!=., xscale(log)






// Naive Model payment
logit paid  exp_vol2014 if exp_vol2014>=1 & exp_vol2014<5000000
capture drop prpaid1
predict prpaid1, pr

logit paid  thresh exp_vol2014 if exp_vol2014>=1 & exp_vol2014<5000000
capture drop prpaid2
predict prpaid2, pr

// Fundraising expenditure makes a big difference if the threshold is ignored
// There is clearly a discontinuity at £100k
twoway (scatter prpaid1 exp_vol2014) (scatter prpaid2 exp_vol2014) if exp_vol2014>=1 & exp_vol2014<5000000

// Linear Probability Model payment
reg paid  exp_vol2014 if exp_vol2014>=1 & exp_vol2014<5000000
capture drop prpaid1
predict prpaid1, 

reg paid  thresh exp_vol2014 if exp_vol2014>=1 & exp_vol2014<5000000
capture drop prpaid2
predict prpaid2, 

// Fundraising expenditure makes a big difference if the threshold is ignored
// There is clearly a discontinuity at £100k
twoway (scatter prpaid1 exp_vol2014) (scatter prpaid2 exp_vol2014) if exp_vol2014>=1 & exp_vol2014<5000000

// Naive Model with controls
logit paid  exp_vol2014 employees2014 volunteers2014 inc_total2014 if exp_vol2014>=1 & exp_vol2014<5000000
capture drop prpaid1
predict prpaid1, pr

logit paid  thresh exp_vol2014 employees2014 volunteers2014 inc_total2014 if exp_vol2014>=1 & exp_vol2014<5000000
capture drop prpaid2
predict prpaid2, pr

// Other measures of size are somewhat important
// But still obvious discontinuity
twoway (scatter prpaid1 exp_vol2014) (scatter prpaid2 exp_vol2014) if exp_vol2014>=1 & exp_vol2014<5000000



// Have a look at the regression discontinuity
rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<1000000  , c(100000)

// and zoomed in
rdplot paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000)

// RDD regression
rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<1000000  , c(100000) 
rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<1000000  , c(100000) covs(employees2014 volunteers2014 inc_total2014)

// RDD zoomed in
rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) 
rdrobust paid exp_vol2014 if exp_vol2014>=1 & exp_vol2014<200000  , c(100000) covs(employees2014 volunteers2014 inc_total2014)



capture drop paidprob
predict paidprob, pr

twoway (line paidprob vertical)(scatter paidprob exp_vol2014 if paid==1, msize(tiny)) (scatter paidprob exp_vol2014 if paid==0, msize(tiny)) if exp_vol2014>0 & inc_total2015!=., xscale(log)
