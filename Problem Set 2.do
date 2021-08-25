clear
log using "/Users/yeonilcho/Desktop/PS2.smcl", replace

******************q1*********************

use "https://github.com/tvogl/econ121/raw/main/data/nhis2000.dta"


des health
label list health_lbl
drop if health == .

gen risk = 0 
replace risk = 1 if health == 5     //risk = 1 indicates bad health status 
replace risk = 1 if health == 4
sum 

******************q2*********************

tab mort5, miss
keep if mort5 < .
reg mort5 age if risk == 1, r
reg mort5 age if risk == 0, r

*when we divide the sample by people who report being in fair to poor health  
*and people who report being in good to excellent health and estimate linear 
*regressions of mortality on age, we get that for fair-poor people, the 
*coefficient of age is 0.0101, and for good-excellent people, the 
*coefficent of age is 0.0049. From both of these results, I conclude that 
*the risk of death increases with age. 
*since this is a linear probabilty model, we can interpret 
*their coefficent as changes in the absolute probablity of the event that 
*mort5 = 1. For fair-poor individuals, an increase in age raises mortality rate by 0.01 percentage point
*, and for good-excellent individuals, an increaes in age raises mortality rate by 0.005 percentage point

twoway (lpoly mort5 age if risk == 1, degree(1) bw(1) lcolor(red)) ///
(lpoly mort5 age if risk == 0, degree(1) bw(1) lcolor(blue)) ///
,legend(label(1 "fair-poor") label(2 "good-excellent"))

*From estimating local linear regressions of mortatlity on age for two 
*separate samples, (on top of the results from estimating linear regressions), 
*we observe that people with worse self-reported health status have higher
*risk of death. In the plots, the regression line of fair-poor people (risk==1)
*is above the regression line of good-excellent people (risk==0) through
*out the interval, which illustrates that people with worse self reported 
*health status faces higher mortatlity rate. 

*(lpoly command performs a kernel-weighted local polynomial regression)
*these plots the non-parametric versions of the logit or the probit model as
*both functions take any values and resacle them to fall between 0 and 1
*(in our model: moralitly rate(probability of dying) from 0 to 100 percent)



******************q3*********************

gen wealth = .
replace wealth = 1 if faminc_20t75 == 0 | faminc_gt75 == 0 
replace wealth = 2 if faminc_20t75 == 1
replace wealth = 3 if faminc_gt75 == 1

graph bar mort5 risk, over(wealth)

*on average, individuals who are considered to belong in the lower income level 
*are more likely to die and be in bad health status(p(mort5=1 | wealth = 1) = .15)
*& p(risk = 1 | wealth = 1) = 0.29). On average, individuals who are considered to belong in the 
*middle income level are less likely to die and be in bad health status compared 
*to the lower income group, but compared to the higher income level samples, 
*they are more likely to die and face worse health status (though less differneces
*than the previous comparison) (p(mort5=1 | wealth = 2) = .058)
*& p(risk = 1 | wealth = 2) = 0.10). On average, the high income individuals are least 
*likely to die and be in bad health status as (p(mort5=1 | wealth = 3) = .03)
*& p(risk = 1 | wealth = 3) = 0.04)

gen educ =.
replace educ = 1 if (edyrs < 12 & edyrs >=0)
replace educ = 2 if edyrs == 12
replace educ = 3 if (edyrs >= 13 & edyrs <= 15)
replace educ = 4 if edyrs == 16
replace educ = 5 if (edyrs > 16 & edyrs < .)

graph bar mort5 risk, over(educ)

*from looking at the results, on avearge, individuals with less than high school completion are
*the group that is most liekly to die and face worse health status (p(mort5=1 | educ = 1) = .17)
*& p(risk = 1 | educ = 1) = 0.33). And individuals who completed highschool 
*experience relatively similar conditions to the less than high school group
*with (p(mort5=1 | educ = 2) = .10) & p(risk = 1 | educ = 2) = 0.26).
*On average, the predicted probabilty of mortality and poor health status decreases with 
*higher education attainment as (p(mort5=1 | educ = 3) = 0.07) 
* & p(risk = 1 | educ = 3) = 0.13) and (p(mort5=1 | educ = 4) = 0.03)
* & p(risk = 1 | educ = 4) = 0.05). There is one unexpected pattern which is that 
*once people reache high enough education attainment (edyrs > 16), 
*the probablity of dying increaes as (p(mort5=1 | educ = 5) = .039)
*(this might be due to the stress one experineces from their studies and research)
*but p(risk = 1 | educ = 5) = 0.045) which is the lowest of all groups.

******************q4*********************

tab age
tab edyrs
*I am spliting the continuous variable edyrs into a series of dummies. 
*I ranked years of education by education level as I can make nice interpretations 
*associated with mortality and education. Also, by looking at the distribtuion of edyrs
*when we group individuals with less than 12 years of education into "less than high school completion", it matches 
*the number of observations with the other groups high school completion group, college group, etc.
*age is a bit more abstract to deal with so I will leave it as a continous variable 

reg mort5 age educ wealth black other hisp, r 
margins, dydx(*)
predict pmort_ols
reg risk age educ wealth black other hisp, r 
predict prisk_ols

probit mort5 age educ wealth black other hisp, r 
predict pmort_probit
margins, dydx(*)
*each unit increase in age is associated with a 0.46 percentage point change in 
*mortality, and moving up one education level (ex. going from highschool completion to graduating college)
*has a negative association with moralitly rate as it decreases the probability by 1.1 percantage point.
*controlling for other variables, moving up one income class also has a negative 
*association with moratliy rate as it decreases the probabilty by 2.2 percantage point.
*I will not comment on the relationship with race as black and other do not hold
*significant t-stat  

probit risk age educ wealth black other hisp, r 
predict prisk_probit
margins, dydx(*)
*each unit increase in age is associated with a 0.33 percentage point change in 
*the predicted probability of being in bad health status , and moving 
*up one education level (ex. going from highschool completion to graduating college)
*has a negative association with bad health status as it decreases the probability by 4.3 percantage point.
*controlling for other variables, moving up one income class also has a negative 
*association with bad health status as it decreases the probabilty by 7.4 percantage point.
*moreover, being black changes the predicted probability of having bad health status 
*by 5.1 percantage point and being other than black and white changes the 
*the predicted probablity by 3.2 percentage point. 


logit mort5 age educ wealth black other hisp, r 
predict pmort_logit 
margins, dydx(*)
*similar to the probit model, on avearge, each unit increase in age is associated with a 0.49 percentage point 
*change in mortality, and moving up one education level (ex. going from highschool completion to graduating college)
*has a negative association with moralitly rate as it decreases the probability by 1.1 percantage point.
*controlling for other variables, moving up one income class also has a negative 
*association with moratliy rate as it decreases the probabilty by 2.0 percantage point.
*race other than black holds negative association with moralitly but I will not further 
*comment on this matter since black and other do not illustrate significance
logit risk age educ wealth black other hisp, r 
predict prisk_logit
margins, dydx(*)
*each unit increase in age is associated with a 0.31 percentage point change in 
*the predicted probability of being in bad health status , and moving 
*up one education level (ex. going from highschool completion to graduating college)
*has a negative association with bad health status as it decreases the probability by 4.2 percantage point.
*controlling for other variables, moving up one income class also has a negative 
*association with bad health status as it decreases the probabilty by 7.6 percantage point.
*moreover, being black changes the predicted probability of having bad health status 
*by 5.2 percantage point and being other than black and white changes the 
*the predicted probablity by 3.1 percentage point. 

sum pmort_*
corr pmort_*

sum prisk_*
corr prisk_*

*on average, the three predicited probablites are very similar, and when 
*we look at their correlations, we see that logit and probit are 
*really close (0.99) and linear probability show some differences in
*correlation with the probit model and the logit model (corr ranging from 0.88 to 0.95)

******************q5*********************

gen race = . 
replace race = 0 if white == 1
replace race = 1 if black == 1		//for comparing race black&white
graph bar mort5 risk, over(wealth) by(race)
*from the bar graphs, we see that on average, high-income(wealth = 3) African Americans 
*have lower mortality risk than lower-income(wealth = 1) White Americans. 
*howeverm this does not tell us if these differences are significant
gen lowinc = 0
replace lowinc = 1 if wealth == 1
gen highinc = 0
replace highinc = 1 if wealth == 3

reg mort5 age educ lowinc highinc if race == 1,r //separating by race instead of income makes the observations independent from each other 
reg mort5 age educ lowinc highinc if race == 0,r
di (.0044566 - .0455747)/sqrt(.0133829^2 + .00551^2)
*for high-income black, β4 = .0044566
*for low-income white,  β3 = .04557
*t-statistic for the differences 
*in estimated probability of highinc black and 
*lowinc white is -2.8410593, which is 
*larger in absolute value than 1.96
*and this suggests that the 
*difference is statistically
*significant
*in conclusion, on average, high-income(wealth = 3) African Americans 
*face lower mortality risk than low-income(wealth = 1) White Americans
*, and these differences are significant. 
******************q6*********************

*it seems unlikely that the coefficients (or marginal effects)
*on family income represent the causal effect. Family income
*and mortality risk are likely to be correlated with a number 
*of omitted variables, such as living environment, 
*relationships, family health background, etc. 
*it leaves more emphasis on the association 

******************q7*********************
*although computing for marginal effects would give me the similar results 
*for both probit and logit, for this section, I will rely on logit and add 
*bunch of covariates to our model 
label list uninsured_lbl
gen insurance = .
replace insurance = 0 if uninsured == 1
replace insurance = 1 if uninsured == 2
*major health behaviors which affect one's health 
*are smoking and drinking. 
label list smokev_lbl
gen smoke =.
replace smoke = 1 if smokev == 20
replace smoke = 0 if smokev == 10
gen drinking =.
replace drinking = 0 if alc5upyr == 0
replace drinking = 1 if (alc5upyr > 1 & alc5upyr < .)
*marriage and employment status are another interesting possible covariates
gen married = 0
replace married = 1 if marstat == 11
replace married = 1 if marstat == 12
gen employed = 0
replace employed = 1 if empstat == 11 
replace employed = 1 if empstat == 20

logit mort5 age educ wealth black hisp other smoke drinking insurance bmi married ///
	  employed cancerev cheartdiev heartattev hypertenev diabeticev
margins, dydx(*)
*after including the covariates, insurance and marriage status has null 
*effects on mortality risk as their t statistics are below the significance 
*level (< 1.96). 

*the major health behaviors which I described above have positive 
*association with mortality as smoking has a coefficent of .0276933 and 
*drinking has a coefficent of .018663. Note that these variables illustrate 
*a discrete chage in behaviors, whther individuals smoke or not and drink or not to a certain amount.  
*from computing the marginal effects, individuals who fall under the category of smoking face increase in predicted mortatlity 
*rate of 2.8 percentage point and individuals who fall under the drinking category face 
*increase in predicited mortatlity rate of 1.9 percentage points. 

*bmi and employed show us some interesting results as each unit increase in bmi
*is associated with a -0.13 percantage point chage in mortatlity rate and 
*being employed is associated with a -2.3 percentage point change in 
*mortality rate. 

*cancerev, cheartdiev, heartattev, hypertenev, diabeticev, all these variables
*which reflect one's medical conditions, show positive associatiton with 
*mortality rate (this is expected as they might be confounders of bad health status)
*the coefficents range from  .0103 to .271, increase in predicted mortatlity rate 
*of 1.03 ~ 2.7 percetnage point. 
******************q8*********************

tab health mort5, column nofreq chi
tab health mort5, row nofreq chi

*from the p-value we get (<0.001), we reject the independence 
*between health status and mortality. Morever, we can see that 
*among respondents with poor health status, nearly 32% die 
*within 5 years of survey and among respondents with fair health 
*status, nearly 20% die within 5 years of survey. These results are 
*significanlty different from the results we estimate with 
*respondents with good to excellent health status as less than 
*10% die within 5 years of survey.   
*when we look at all the people who died within 5 years of survey, 
*most of them were considered as good health status (31%) and the next 
*groups were fair (26%) and poor (15%). 
*these differences (relationship between health status and mortatlity)
*are statistically significanlty with a pavalue of 0.000. 
*in conclusion, there are higher predicted probabilities associated 
*to fair/poor health, but at the same time, majority of people 
*who actaully died within the 5 years belonged in the good health status 
*(this might be becuase when people do not know their health status in detail 
*but assume that their health is fine, (which is why such individuals categorize themsevles 
*under good health status), the assumption they make leads to the danger as it can lead 
*diseases go unnoticed and prevent them from taking care of their health. 



log close 


