# Incentivizing Regulatory Participation: Effectiveness of a Fundraising Levy
 
Professor ALasdair C. Rutherford (University of Stirling)  
Dr Diarmuid McDonnell (University of Birmingham)  
Dr Eddy Hogg (University of Kent)  

## Abstract
In the absence of a statutory instrument to enforce payment of a regulatory fee, regulators are reliant on a combination of ‘carrots’ and ‘sticks’ to encourage financial contribution by the bodies they oversee. In contrast to extant studies of public funding of nonprofits, we empirically evaluate the effectiveness of a government policy to rely on nonprofit funding of statutory regulation. We exploit a sharp discontinuity in the eligibility threshold for charities contributing to a new Fundraising Regulator in England &amp; Wales in order to estimate a causal effect of the levy on participation. We show that the regulator’s threat to ‘name and shame’ was very effective in incentivizing regulatory participation and generating income, but raise some concerns about the long-term viability of this approach. The results are significant at a time when many jurisdictions are considering how best to fund the regulation of nonprofits.

## Contents
This repository (will) contains the syntax and data for the paper "Incentivizing Regulatory Participation: Effectiveness of a Fundraising Levy" published in @@@@@@@@@ on dd mmm yyyy.

### Dataset
The analysis dataset for tre paper, combining charity register data (from the Charity Commission for England & Wales) and Fundraising Regulator membership status as at July 2017 (from the Fundraising Regulator). The data is available in Stata (.dta) format and delimited (.csv) format.

*frexpvol-analysis-12Sept17.dta
*frexpvol-analysis-12Sept17.csv

### Syntax
Stata syntax files are provided for the data analysis.

*paper-rd-analysis.do

Estimates and graphs different models for the paper around the Levy threshold.

*paper-rd-analysis-payband-AR-18Sept17.do

Estimates and graphs RDD models around each of the pay band thresholds

*paper-graphlevypaybands.do

Descriptive graph of the Levy pay bands, and the percentage of fundraising expenditure

*merge-dr-data-11Sept17.do

Builds the dataset for analysis from the separate files. These underlying files are not currently included in the repo.
