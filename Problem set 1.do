clear 
log using /Users/yeonilcho/Desktop/PS1.smcl, replace

/*
A surprisingly large share of the past half-century of research in labor economics has focused on the return to educatio
n: the added earnings power that an individual obtains by staying in school an extra year. In the 1970s, the late econom
ist Jacob Mincer formulated what is now seen as the standard relation between humancapital and wages:
ln(w_i) = β_0 + β_1 ed_i + β_3 exper_i + β_4 exper^2_i + ε_i 
where w_i is the hourly wage, ed_i is years of education, and exper_i is years of labor market experience. This equation
is known as the Mincerian Wage Equation. In this problem set, we will explore the difficulties that arise in estimating
the returns to education using OLS. We will use two datasets, both containing data on labor earnings and education amon
g US adults. One is a sample of working-age (25-64) adults in the Current Population Survey, a nationally-representative
monthly survey of the non-institutionalized population. This dataset is from March 2018, with data on labor market outc
omes in 2017. The other dataset comes from the National Longitudinal Survey of Youth, a study that first surveyed a samp
le of 14-21 year olds in 1979 and then re-surveyed them annually or bienially to the present. The labor market data are 
for 2007, when the cohort was aged 42-49.
*/


*********************q1*********************

*from the given Mincerian Wage Equation, 
*if one assumes that education and experience 
*are exogenous,  β1 in the Mincerian Wage Equation 
*will illustrate the effect of an extra year of 
*education on the log of hourly wage, wi. Ultimately,
*the model is trying to explain hourly wage income 
*as a function of years of schooling and potential
*experience. I believe that the equation has a squared 
*term in experience because by adding a quadratic term for 
*experience in the linear equation, one can see both 
*the effect of experience on log of hourly wage and 
*as well as if this effect is increasing or decreasing 
*depending on its coefficient, β4. 

*********************q2*********************

use https://github.com/tvogl/econ121/raw/main/data/cps_18.dta
des
sum incwage //min = 0 & max = 1609999 
count if incwage > 1000000

tab race 
des race
label list race_lbl

gen white = 0
replace white = 1 if race == 100		//almost 80 percent 
gen black = 0
replace black = 1 if race == 200
gen other = 0
replace other = 1 if (race != 100 & race != 200)

des educ
label list educ_lbl    //similar to fre command 
gen ed = .

replace ed = 0 if educ == 2 
replace ed = 2.5 if educ == 10
replace ed = 5.5 if educ == 20
replace ed = 7.5 if educ == 30
replace ed = 9 if educ == 40 
replace ed = 10 if educ == 50
replace ed = 11 if educ == 60
replace ed = 12 if educ == 71 | educ == 73
replace ed = 13 if educ == 81 
replace ed = 14 if educ == 91 | educ == 92 
replace ed = 16 if educ == 111
replace ed = 18 if educ == 123
replace ed = 20 if educ == 124 | educ == 125

tab ed

gen exper = age - ed - 5
gen exper_sq = (exper)^2

keep if uhrsworkt >= 35
keep if wkswork1 >= 50
gen annualwkhr = wkswork1*uhrsworkt
gen hourlywage = incwage / annualwkhr
gen logwage = ln(hourlywage) 

sum

*********************q3*********************

reg logwage ed exper exper_sq, r
*here, the estimated return to education describes
*an effect of addiotnal year of education on log wage,
*and since β1 = 0.129, the estimated return is increased 
*log wage by value of 0.129. 
*(about 15% increase in hourly wage)

*********************q4*********************
label list sex_lbl
gen male = 0
replace male = 1 if sex == 1
reg logwage ed exper exper_sq other black male, r
reg logwage ed exper exper_sq other white male, r
*yes, the estimated return to education changes 
*from 0.129 to 0.133 after controlling for 
*the covariates, race and sex
*(through using variables black & male)

*********************q5*********************

*the coefficents are from the same sample, so 
*I cannot assume that they have no covarience
lincom white-male
*t-statistic for the differences 
*in slopes of black-white logwage gap 
*and female-male logwage gap is 
*-6.19, which is way larger
*in absolute value than 1.96 (reject the null hypothesis)
*and this suggests that the
*coefficients are (statistically)
*significantly different from each other 

*********************q6*********************

reg logwage ed exper exper_sq other white if male == 1, r
reg logwage ed exper exper_sq other white if male == 0, r
*for male, β0 = .4500713 and β1 = .1242152
*for female, β0 = .1971826 and β1 = .1461146
*on average, women have relatively lower wage 
*compared to men, but their return to education 
*is higher (getting educated has a bigger impoact on women)
*the difference comes out to be approximately 0.022
di (.1242152 - .1461146)/sqrt(.0024582^2 + .0031423^2)
*t-statistic for the differences 
*in estimated returns of male and 
*female is -5.489141, which is 
*larger in absolute value than 1.96
*and this suggests that the 
*difference is statistically
*significant

*********************q7*********************

gen maleXed = male*ed
gen maleXexper = male*exper
gen maleXexper_sq = male*exper_sq

reg logwage ed exper exper_sq other white male male#c.ed male#c.exper male#c.exper_sq, r //alternative 
reg logwage ed exper exper_sq other white male maleXed maleXexper maleXexper_sq, r

lincom ed + maleXed //to check 
*indeed I got the same answer 
*β(maleXed) = -.0216843 with a t-stat of -5.45
*and β(ed) = .1458981
di .1458981 - .0216843
*the result is .1242152, which has the same 
*value as the coefficient of β1 in the seperated 
*regression, and maleXed has approximately the same value of 
*t-statistic as the t-stat calculated from 
*taking the difference of coefficients (5.5 = 5.5 shown above)

*the ratio of returns for women to the return for men 
*would be = β1ed_i / (β1ed_i + βmaleXed)
nlcom _b[ed] / (_b[ed] + _b[maleXed])

bootstrap ratio = (_b[ed] / (_b[ed] + _b[maleXed])), reps(99): reg logwage ed exper exper_sq other white male maleXed maleXexper maleXexper_sq, r
*from the two methods, the ratio comes out to be 
*1.174572, which means that the return on 
*education is approximately 20% higher for women 
*than men, and the ratio is significantly different 
*from 1 as both methods suggest high t statistics of 
*34.27 and 35.16

*********************q8*********************
clear
use https://github.com/tvogl/econ121/raw/main/data/nlsy79.dta 
des
//respondents = i.individuals -> iid
sum black [aw=perweight] //observations w/ 0 weight get dropped

bysort black: sum laborinc07
bysort black: sum laborinc07 [aw=perweight]

bysort hisp: sum laborinc07
bysort hisp: sum laborinc07 [aw=perweight] 

*using perweight leads to less effiency
*however, summary statistics with using 
*perweight will provide unbiased 
*estimates of the population means
*this is because sampling weights 
*allow one to form the sample as if 
*it was a random sample draw from the total
*population (US adults who were teenagers in 1979)
*meaning that the results will yield more accurate 
*population estimates for our main parameters of interest

*********************q9*********************

keep if hours07 >= 1750 //full time = 35hrs/week * 50weeks = 1750 hours
gen hourlywage = laborinc07 / hours07
gen logwage = ln(hourlywage)
tab educ //already in grade year 
gen exper = age79 - educ - 5
gen exper_sq = (exper)^2

reg logwage educ exper exper_sq black hisp male, r
//rvfplot, yline(0) //showing "some" homoscedasticity; not really
reg logwage educ exper exper_sq black hisp male [aw=perweight], r
*the use of sampling weights increases the estimated 
*coefficient of educ from 0.115 to 0.119 (about 0.5% difference). 
*my preferred method is the one with sampling weights 
*as I want more interpretable results (as they were from
*a census). For the remainder of the analysis, 
*I will only use the sampling weights method 

*********************q10*********************

*NLSY:ln(w_i) = 1.17 + .119ed_i + .005exper_i + .0006exper^2_i - .037hisp_i - .261black_i + .355male_i + ε_i 
*CPS:ln(w_i) = .375 + .133ed_i + .030exper_i - .0004exper^2_i + .007other_i - .154black_i + .273male_i + ε_i 
*from comparing these two results, the estimate of the return to 
*education from the CPS is higher than the NLSY (.133 > .119)
*considering that the CPS is more of a recent data than the 
*NLSY (2017 vs 2007) one hypothesis I can generate from the differences 
*is that "individuals' education is becoming a bigger determining factor of
*their wages". For example, as people realize more jobs (high paying ones 
*espeically) require a college degree, more people will attend college 
*and an increase in this phenomenon from 2007 to 2017 can help explain why
*such differences exist in return to education from the two results
*another thing to note is the differences in the age groups between 
*the two samples as education can have a bigger impact on one's income 
*in the earlier years of their career 

*********************q11*********************

*I would like to argue that the estimates from the methods 
*implemented during this exercise do not fully capture return 
*of education on one's hourly wage and therefore, they can 
*not be concluded as true represenation of the casual 
*effect of education. Even after controlling
*for race, sex, we are still omitting important variables, 
*such as ability, background, location, etc, and I believe that 
*they are huge factors in determining one's return of education.  
*In the presence of heterogeneous returns to schooling, the 
*estimates are rather more useful for illustrating a positive 
*correlation between  one's years of schooling and hourly wage,  
*(which is why the Mincerian Wage Equation is foundational when 
*it comes to estimating the causal effect of education on earnings)

*********************q12*********************

*datas on the cognitive test scores and the 
*measures of the childhood environment can be 
*utilized to represent "ability" and "background",
*which I mentioned above. For this reason, I think
*both of these variables would be appropriate as 
*control variables in the Mincerian Wage Equation 
*as controlling them will bring us closer to estimating 
*the true  effect of education on hourly wage β1. 
*(however note that AFQT test scores and  
*educ can share some causality)

reg logwage educ exper exper_sq black hisp male afqt81 [aw=perweight], r

//β1educ_i = 0.069

reg logwage educ exper exper_sq black hisp male afqt81 educ_dad [aw=perweight], r
//β1educ_i = 0.065

reg logwage educ exper exper_sq black hisp male afqt81 educ_dad numsibs[aw=perweight], r
//β1educ_i = 0.066

reg logwage educ exper exper_sq black hisp male afqt81 educ_dad numsibs urban14 [aw=perweight], r
//β1educ_i = 0.065
*with the changes, return to education is about 7% increase in 
*hourly wage, which is dramatically lower than the ones I observed 
*previosuly. Since the biggest change happened after controlling 
*for the AFQT scores, (although the test scores are not perfect 
*descriptions of what we call "ability") it is reaasonable to
*think that individuals' ability is a huge componenet of their income
*(it would be interesting to see how much "ability" affects one's decision
*making in education)

*translate PS1.smcl PS1.pdf, replace 
*log close
















