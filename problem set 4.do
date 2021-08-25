use "https://github.com/tvogl/econ121/raw/main/data/crime_ps4.dta"

******************q1*********************

d 
graph bar crimerate conscripted, by(birthyr)
bysort birthyr: sum crimerate conscripted

/*
There are slight differences in conscription rates and crime rate 
across birth years.
The average crime rate ranges from 0.0679 (1959) to 0.0706 (1962), and the average
conscription rate ranges from 0.4618 (1960) to 0.5764 (1958) across different 
birth years. 
*/

******************q2*********************

reg crimerate conscripted i.birthyr argentine indigenous naturalized, r
*This result illustrates that one percentage point increase in the conscription rate
*is assoicated with 0.0023 percentage point increase in the crimte rate (small effect).

/*
The results do not provide the causal effect of conscription. First of all,
the estimated return of conscripted on crimte rate is positive, which indicates that 
the conscription increases one's likelihood of committing a crime. This contradicts 
one of the proponents of requiring young men to serve in the military, "disciplining
otherwise undisciplined young men". Moreover, using OLS does not account for
possible selection bias involved in the process of drafting. 
On top of the possbile OVB, selection bias arise as the cutoff number was not randomized across different years, 
and the fact that any individual with family members dependent upon him for support were exempted 
from military service illustrates that we are omitting influential factors.
For example, people who served in the military might be more likely to 
commit crimes compared to the people who did not serve. And the reason for this 
could be that individuals who have a lot of responsibility (having people that depend on you for living)
were excluded from the lottery, and their costs of committing crimes is higher compared to the conscripted individuals
On the other hand, getting included and selected in the lottery process means that you have less weights (responsibility)
on your shoulders, and this might be correlated with one's likelihood of committing crime. 
*/

******************q3*********************

gen eligible = 0
replace eligible = 1 if (birthyr == 1958 & draftnumber >= 175)
replace eligible = 1 if (birthyr == 1959 & draftnumber >= 320)
replace eligible = 1 if (birthyr == 1960 & draftnumber >= 341)
replace eligible = 1 if (birthyr == 1961 & draftnumber >= 350)
replace eligible = 1 if (birthyr == 1962 & draftnumber >= 320)
*note that the cutoff number in 1958 is relatively lower compared to the other years

******************q4*********************

*we observe differences in conscription rates, crimte rates, and the cutoff numbers.(cutoff numbers weren't randomized) 
*This tells us that we must include birth year indicators in our specification to account for 
*possible selection bias and OVB. Do we have to control for ethnic compostion? Not so much, but they are 
*pre-determined variables and might give us interesting insights, so I am including it. 

reg conscripted eligible i.birthyr argentine indigenous naturalized, r
*β(elig) = .6587391
*The estimate indicates that 65.9% of the eligible individuals were conscripted  //questionable 

******************q5*********************

reg crimerate eligible i.birthyr argentine indigenous naturalized, r
*this illustrates that the eligibility is positively assoicated with the crime rate.
*(being eligible increases the crime rate by 0.176 percentage point, and the estimate is 
*statistically significant. Interestingly, the estimate for the 1962 birth year is 
*statistically significant, and it is associated with a 0.169 percentage point increase in the crime rate.
*Other birth year dummies are statistically insignificant as well as the other observable covariates. 

/*
the result above does not reflect the causal effect of conscription on crimerate.
This is because although the eligbility was randomized, the treatment(conscription) 
was not fully randomized. To give an example, if one was eligible but did not pass 
the medical examination or if one was clercis, seminarians, etc, they were excluded 
from being conscripted (never takers), which means that they are "noncompliers". Furthermore, 
there could be volunteers who enlist themselves despite being ineligible (always-takers), 
which makes this case a nonperfect compliance.
Thus, in order to study the causality, we need to estimate the effect of 
conscription on crimerate through the instrument eligbility
*/

******************q6*********************

*β(fs) = .6587391
*β(reduced) = .0017597 

di .0017597/.6587391		//the result = .00267132

******************q7*********************

ivregress 2sls crimerate (conscripted = eligible) i.birthyr argentine indigenous naturalized, r 
*β(2sls) = .0026714 
*Indeed, there are differences between the 2SLS and OLS results 
/*
From the results, β(2sls) = .0026714 and β(OLS) = .0022643, the estimated effect of 
conscription is bigger when using the 2SLS method compared to the OLS method. 
Thd differences might be caused by the selection bias involved in the process of 
lottering that underestimated the effect of conscription on crimerate in our OLS method.
Moreover, it is likely that cov(conscrpited, Ui) does not equal to zero, which means that 
our outcome and independent variable are correlated with unobserved variable in the error
term. 
*/

******************q8*********************

/*
In order for the eligibility variable to be a valid instrument, it must 
satisfy these two criteria, instrument relevance and instrument exogeneity.
we know for sure that the instrument relevance is satisfied because, as mentioned earlier, eligibility
is directly associated with one's likelihood of getting conscripted (cov(elig,cons)) does not equal to 0.)
Another criteria is instrument exogeneity, and although the national IDs are assigned sequentially by such factors,
instrument exogeneity is satisfied because we know that in each year the lottery process of deciding who 
is eligible is completely random. Thus, eligbility is uncorrelated with other meaningful determinants of crime, 
which indicates that cov(elig,Ui) = 0.
*/

******************q9*********************

/*
Which sub-population's average treatment effect does it estimate? The answer to this is the eligible subpopulation that was conscripted. 
From the first stage regression, we found that eligibility is strongly predictive of conscription rate as its coefficient = .6587391 with 
the large t-statistic of 571.58. We are essentially estimating on 65.9 percent of the eligible group. 
The 2SLS regression estimates that increase in one percentage point in the conscription rate is assoicated with 0.00267 
percentage point increase in the crime rate. And as similar to the earier result, the only birth year that is statistically 
significant is the year 1962, and it is associated with a 0.163 percentage point increase in the crime rate. 
(Other covariates are statistically insignificant)

Note that compliance is not perfect here. For example, one could volunteer in the draft
despite being ineligible. Moreover, there could be also "draft avoiders". For this reason,
it makes more senese that the causal effect of conscripted on crimerate is heterogenous, which indicates that 
it is reasonable to call it a local average treatment effect rather than a treatment on the treated effect. 
For a valid causal interpretation of the IV estimand, the three assumptions must be satisfied. Let's check.
(1. independence) The veteran status of any man at risk of being drafted in the lottery was not affected by 
the status of others at risk of being drafted, and the crime rate of any such man was not affected by the draft status of others. 
(2. Exclusion restriction) Crime rate risk was not affected by eligbility status once veteran status is taken into account 
(3. Monotoncity) The monotoncity holds by the design
*/

******************q10*********************

*(a)
scatter conscripted draftnumber, by(birthyr) 	
*indeed we observe a distinctive discontinuity at a certain threshold in each birthyear
*the 1958 has the most conscrpitons out of all the other birthyears.
*(the observed discontinuity represents the effect of eligbility on conscription at the marginal level)

*(b)
gen distance = 0
replace distance = draftnumber - 175 if birthyr == 1958
replace distance = draftnumber - 320 if birthyr == 1959
replace distance = draftnumber - 341 if birthyr == 1960
replace distance = draftnumber - 350 if birthyr == 1961
replace distance = draftnumber - 320 if birthyr == 1962

drop if distance > 100
drop if distance < -100

*(c)
scatter conscripted distance, by(birthyr)
*the results suggest that crossing the cutoff does raise conscription, and this 
*is shown by the jump in conscription. To add on, the ineligible nubmers have 
*nonzero conscription rates (a sign of volunteers). 


	
*(d)
scatter crimerate distance, by(birthyr)
*We do not observe any discontinuity from the plot, which suggests that crossing 
*the cutoff does not raise crimerate. 

*(e)
twoway (scatter conscripted distance, by(birthyr)) ///
	lpoly conscripted distance, bw(100)
*when we use a bandwidth of 100, the local linear regression does not seem to have 
*a jump compared to having a bandwidth of 10. 
gen distanceXelig = distance * eligible
ivregress 2sls crimerate (conscripted = eligible) distance distanceXelig, r first 
/*
The command performs a 2SLS regression using crimerate as the outcome variable and 
estimate the effect of conscrption through the instrument variable eligible on the 
crime rate controlling for distance. Morever, including the ,first at the end shows 
the result of the first stage regression. 

In the first stage, again, we see that eligiblity is strongly associated with conscription. 
(being eligible raises one's likelihood of getting conscripted by a large amount, which is 
consistent with the result we found in part (c))
Moreover, the interaction term, distanceXelig, is statistically significant, and its 
coefficient is nonzero, which illustrates that this could be a nonperfect compliance model. 

In the second stage, all of the coefficients are statistically insignificant, and 
this confirms the results we found in part (d), which is that there are no significant
differences in crime rate around the threshold for eligbility. 
*/

*(f)
/*
the regression discontinuity results are different from the results earlier in the 
problem set because the earier IV regression illustrates the sharp discontinuity, 
whereas now, we are relying on the fuzzy regression discontinuity design. 
These differences confirm the claim I made earier, which is that the compliance is not
perfect in our model. The reason for non perfect compliance is due to sometimes a
threshold is not binding (volunteers and draft avoiders). For this reason, we should 
think of the cutoff as affecting the probability of treatement. 
*/





















