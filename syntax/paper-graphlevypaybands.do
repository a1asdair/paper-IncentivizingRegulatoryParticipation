// Graph FR Payment Bands

global projpath = "C:\Users\ar34\Dropbox\Academic\Academic-Research-Projects\Fundraising-Regulator-Data"
global csvpath = "$projpath/csv"
global statapath = "$projpath/stata"
global outputpath = "$projpath/output"
global refpath = "$projpath/refreshdata"

clear

set obs 200000

gen expvol = _n*500

sum expvol

local count=1
local threshlist = "100000 150000 200000 500000 1000000 2000000 5000000 10000000 20000000 50000000"
foreach thr in `threshlist' {
	gen threshold`count' = `thr'
	local count = `count' + 1
	}


recode expvol	 	(0/99999.99 = 0 "Non-Levy Payer")	///
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

recode expvol	 	(0/99999.99 = 50 "Non-Levy Payer")	///
					(100000/149999.99 = 150 "Levy £150")	///
					(150000/199999.99 = 300 "Levy £300")	///
					(200000/499999.99 = 800 "Levy £800")	///
					(500000/999999.99 = 1500 "Levy £1,500")	///
					(1000000/1999999.99 = 2500 "Levy £2,500")	///
					(2000000/4999999.99 = 4000 "Levy £4,000")	///
					(5000000/9999999.99 = 6000 "Levy £6,000")	///
					(10000000/19999999.99 = 8000 "Levy £8,000")	///
					(20000000/49999999.99 = 12000 "Levy £12,000")	///
					(50000000/9999999999999 = 15000 "Levy £15,000"),	///
					gen(paylevel)
					
recode expvol	 	(50000 = 50 "Non-Levy Payer")	///
					(99500 = 50 "Non-Levy Payer")	///
					(100000 = 150 "Levy £150")	///
					(149500 = 150 "Levy £150") ///
					(150000 = 300 "Levy £300")	///
					(199500 = 300 "Levy £300") ///
					(200000 = 800 "Levy £800")	///
					(499500 = 800 "Levy £800") ///
					(500000 = 1500 "Levy £1,500")	///
					(999500 = 1500 "Levy £1,500")	///
					(1000000 = 2500 "Levy £2,500")	///
					(1999500 = 2500 "Levy £2,500")	///
					(2000000 = 4000 "Levy £4,000")	///
					(4999500 = 4000 "Levy £4,000")	///
					(5000000 = 6000 "Levy £6,000")	///
					(9999500 = 6000 "Levy £6,000")	///
					(10000000 = 8000 "Levy £8,000")	///
					(19999500 = 8000 "Levy £8,000")	///
					(20000000 = 12000 "Levy £12,000")	///
					(49999500 = 12000 "Levy £12,000")	///
					(50000000 = 15000 "Levy £15,000")	///
					(100000000 = 15000 "Levy £15,000")	///
					(* = .) ,	///
					gen(paystep)					
					
gen payperc = (paylevel/expvol) * 100

replace expvol = expvol/1000

local axtcol = "gs8"
local numf = "%12.0fc"				


gen t1 = 100

twoway  (line payperc expvol, yaxis(1) lcolor(gs2) )	///	
		(line paystep t1, yaxis(2) lcolor(gs10) lpattern(dot))	///
		(line paystep expvol, yaxis(2) lcolor(gs8) lwidth(medthick) ) ///			
		if expvol>=50, ///
		title("", color(gs2)) ///
		ytitle("Levy Fee (£)", axis(2) color(`axtcol') size(small)) yscale(axis(2) lcolor(`axtcol')) ylabel(, axis(2) labcolor(`axtcol') labsize(small) format("`numf'")) ///
		ytitle("Percentage of Fundraising Spend (%)", axis(1) color(`axtcol') size(small)) yscale(axis(1) lcolor(`axtcol')) ylabel(, axis(1) labcolor(`axtcol') labsize(small)) ///
		xtitle("Expenditure on Fundraising (£,000)", color(`axtcol')) xscale(log range() lcolor(`axtcol')) xlabel(100  1000  10000 50000, format("`numf'") noticks labcolor(`axtcol')) ///
		text(0.41 100 "Levy Payer threshold", size(vsmall) color(gs10))	///
		text(0.35 700 "Percentage of fundraising" "spend peaks for charities" "spending £200k", size(vsmall) color(gs2))		///
		text(0.29 37000 "Levy Fee" "thresholds", size(vsmall) color(gs7))			///
		legend(off)  ///								
		scheme(s1mono) bgcolor(white) plotregion(ilcolor(none) lcolor(none)) graphregion(ilcolor(none) lcolor(none)) ///
		graphregion(fcolor(white))	
		
graph export "$outputpath/fig1_graphlevypaybands_`fdate'.png", replace width(4096)
		
drop t1		
save "$statapath/paybandg.dta", replace	


				
