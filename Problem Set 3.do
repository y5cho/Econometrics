clear 
log using "/Users/yeonilcho/Desktop/PS3.smcl", replace
use "https://github.com/tvogl/econ121/raw/main/data/nlsy_deming.dta"

******************q1*********************
d
sum 
bysort head_start: sum
/*
from the summaries, some notable background differences between 
children who particpated in Head Start and children who did not are:
more than half of the particpants were black (mean of 0.52) when about 
a quarter is black among the children who did not particpate in Head Start (mean of 0.27).
not much notable differences in gender, hispanic, firstborn and surprisingly in mother's years of education as well.
about half of the children who paritcipated in Head Start were living with their 
father in ages from 0 to 3, compared to more than 70 percent of the nonparticipants were 
living with their father in ages from 0 to 3. 

not much differences in log birth weight between the groups 
however, it seems like there is some systematic differences in the test scores 
of the participants and nonparticpants as the participant group has lower means
in all the variables that capture test scores (ppvt_3, comp_score)
lastly, the participants were more likely to repeat a grade and less likely to attend college 
and not much differences in the self rated health status and learning disability status 
*/

******************q2*********************

*OLS with robust standard errors
reg comp_score_5to6 head_start, r
*OLS with clustered standard errors
reg comp_score_5to6 headstart, clustered(mom_id)
/*there is a negative association between Head Start 
*participation and age 5-6 test scores, which is intriguing. 
*If we assume that Head Start participation is exogenous, we would conclude that 
the progam has a negative effect on children's test scores as the participation 
of the program would lead to scoring about 5.84 lower on the test. 
*/

*it is not reasonable to assume that Head Start participation is exogenous 
*(having disadvantaged backgrounds was part of the qaulification for the 
*program, and thus, models that assume Head Start participation as exogenous 
*would involve omitted variable bias)

******************q3*********************

xtreg comp_score_5to6 head_start, i(mom_id) re robust 
*the estimated coefficient in the random effects model is approximately -2.53, 
*which indicates that the program leads children to score less on such tests by 2.53.

/*
the estimated coefficient under the random effects changes a lot compared with the last OLS
, and this suggest that the between-family variation and the within-family 
variation lead to different coefficients.
for this reason, the comparison makes me less confident that OLS (due to OVB) or random effects 
can shed light on the causal effect of Head Start on test scores.
(instead of focusing on variance components model, we need fixed effects model
for estimating coefficients as we need to account for the group level OVB from our estimates)
*/

******************q4*********************

xtreg comp_score_5to6 head_start, i(mom_id) fe robust
*as the coefficient gets higher, the result is consistent with downward bias 
*from between-groups variation
/*
without the pre-Head Start control variables, the estimated coefficient for Head Start 
is 7.63. This illustartes that within a household, participating in the program 
is associated with a 7.63 points higher test score compared to a nonparticipant sibiling.
*/ 

xtreg comp_score_5to6 head_start hispanic black momed male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust 
*the coefficient on head_start is lowered. 
*the group level control variables,race (black and hispanic) and momed, should be dropped 
*as they are collinear with the mother fixed effects (they do not vary within the group)
*lninc_0to3 and dadhome_0to3 are included since family income and composition may change over time

*ppvt_3 was excluded for having too many missing data 
xtreg comp_score_5to6 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw ppvt_3, i(mom_id) fe robust
xtreg comp_score_5to6 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw if e(sample), i(mom_id) fe robust 
*from the results, ppvt_3 does not seem like an important variable either

xtreg comp_score_5to6 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust 
/*
after including the correct control variables, the results imply that the 
effects of Head Start on test scores is positively associated with test scores. The estimated 
coefficient of Head Start participation: β1 = 5.65, which indicates that the program participation 
is associated with a 5.65 increase in test score.
out of all the control variables I included, male and lnbw are statistically significant with 
their coefficients being -2.811 and 6.91 respectively. Thus, being male is assoicated with a
2.811 decrease in test score, and 1 percent increase in birth weight is associated with a
6.91 increase in test score
I will list the coefficients of other variables but will not further interpret as they do not 
hold statistical significance.
β(firstborn) = 1.66, β(lninc_0to3) = 2.27, β(dadhome_0to3) = -3.26, β(lnbw) = 6.91
*/

*the fixed effects results are different from those in my answer from question 2 (simple OLS)
*because Head Start paritcipation is correlated with many variables that affect 
*children's test scores (for ex, given resources, learning environment, etc.). 
*The fact that the Head Start program was meant for disadvantaged children 
*illustrates many systematic differences between the participants and nonparticipants.
*And because the fixed effects model account for these systematic differences between the groups,
*the results are completly different from the results I obtained using simple OLS. 

******************q5*********************

*carrying out fixed effects analyses of test scores at later times
xtreg comp_score_7to10 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

xtreg comp_score_11to14 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
/*
the coefficients on head_start for both regressions still show positive 
associations between the program participation and test scores. However, the effects seem 
to be mitigated as β1(7to10) = 3.04, β1(11to14) =  5.14 compared β1(5to6) =  5.65.
(note that these magnitudes can't be compared directly)
*/

*comparison anaylsis 
gen sd_5to6 = (comp_score_5to6 /  22.37593) 		//making sds = 1 
gen sd_7to10 = (comp_score_7to10 /  24.12119) 
gen sd_11to14 = (comp_score_11to14 /  24.80608) 

xtreg sd_5to6 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
xtreg sd_7to10 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
xtreg sd_11to14 head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
*β1(5to6) = 0.252, β1(7to10) = 0.126, β1(11to14) = 0.207
/*
the effect of Head Start program on test scores is shown to be the largest 
during the earlier stage of children's post-participation. However, it might
be difficult to claim that the effects fade out with age. β1(5to6) represents 
0.252 stnadard deviation change in the test score, and although this is 
lowered to 0.126 standard deviation change in the test score, the effect upholds
during the later stage of children's post-paritcipation as β1(11to14) =  0.149,
which represents 0.149 standard deviation change in the test score  (showing some lasting trend).
*/

******************q6*********************

xtreg repeat head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

xtreg learndis head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

xtreg hsgrad head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

xtreg somecoll head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

xtreg idle head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

xtreg fphealth head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust 
/*
after estimating fixed effects models of the effect of Head Start on longer 
term outcomes, we see that it is likely that the program had positive effects on children's 
overall well being. 
for example, even though the results weren't significant at the 5 percent level, 
the program paritcipation is associated with a -5.6 percentage point 
change in one's likelihood of repetiting a grade. And one's paritcipation is asociated with a -1.83 percentage point change 
in the probability of having learning disability.

(These results below are significant at the 5 percent level)
the program participants are 12.99 percentage point more likely to graduate highschool compared to the non-participants
when everything else is fixed in our models. 
moreoever, the program participants are more likely to attend some college but the effect is really small and 
not significant. 
the participants are 9.1 percentage point less likely to self report themselves as 
having fair/poor health compared to the non-participants when other things fixed.
*/

******************q7*********************
gen white = 0
replace white = 1 if (hispanic == 0 & black ==0)

*bysort method: regressing on the longer term outcomes hsgrad and fphealth 
bysort male: xtreg hsgrad head_start firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

bysort white: xtreg hsgrad head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
bysort black: xtreg hsgrad head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
bysort hispanic: xtreg hsgrad head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

bysort male: xtreg fphealth head_start firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust

bysort white: xtreg fphealth head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
bysort black: xtreg fphealth head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
bysort hispanic: xtreg fphealth head_start male firstborn lninc_0to3 dadhome_0to3 lnbw, i(mom_id) fe robust
/*
from the different coefficients, we see that the effects of Head Start participation on 
longer term outcomes vary by race and sex. 
from the male-female comparison, we observe that the effect of program paritcipation for males 
is 11.6 percentage point increase in likelihood of graduating highschool, and for females, it 
has an effect of 6.4 percentage point increase in likelihood of graduating highschool. However,
in terms of self reported health, females are more benefited from the program as female 
participants are 21.5 percentage point less likely to self report themselves as having fair/poor 
health, whereas male participants are 4.5 percezntage point less likely to self report themselves. 

In order to breifly go over the race comparsion, we see that non-white participants 
experience greater benefits from the program compared to the white participants. 
(note that most of the coefficients are not statistically significant)
However, conducting seperating regressions using bysort 
does not tell us if these differences in race and sex are significant 
*/

*for the reason above, different methods may be needed 
foreach depvar in repeat learndis hsgrad somecoll idle fphealth {
	di "Dependent variable: `depvar'; female"
	xtreg `depvar' head_start firstborn lninc_0to3 dadhome_0to3 lnbw if male==0, ///
		i(mom_id) fe robust
	sca estfemale_`depvar' = _b[head_start]
	sca varfemale_`depvar' = e(V)[1,1]
	di _new "Dependent variable: `depvar'; male"
	xtreg `depvar' head_start firstborn lninc_0to3 dadhome_0to3 lnbw if male==1, ///
		i(mom_id) fe robust
	sca estmale_`depvar' = _b[head_start]
	sca varmale_`depvar' = e(V)[1,1]
	di _new _dup(76) "*" _new
}
foreach depvar in repeat learndis hsgrad somecoll idle fphealth {
	di "Dependent variable: `depvar'"
	di "Female-male difference = " estfemale_`depvar'-estmale_`depvar'
	di "T-statistic = " (estfemale_`depvar'-estmale_`depvar')/sqrt(varfemale_`depvar'+varmale_`depvar')
	di _new _dup(76) "*" _new
}
/*
using the fact that two subsamples of male and female are independent, we can compute 
t-statistics of the estimated differences manually. After carrying this process out, we see that 
most of the longer term outcomes do not significantly vary by sex. (somecoll was an exeception)
*/

*by race 
foreach depvar in repeat learndis hsgrad somecoll idle fphealth {
	foreach race in black hispanic white {
		di "Dependent variable: `depvar'; `race' "
		xtreg `depvar' head_start firstborn lninc_0to3 dadhome_0to3 lnbw /// 
			if `race'==1, i(mom_id) fe robust
		sca est`race'_`depvar' = _b[head_start]
		sca var`race'_`depvar' = e(V)[1,1]
		di _new
	}
	di _dup(76) "*" _new
}

foreach depvar in repeat learndis hsgrad somecoll idle fphealth {
	di "Dependent variable: `depvar'"
	di "Black-White difference = " estblack_`depvar'-estwhite_`depvar'
	di "T-statistic, Black-White = " /// 
		(estblack_`depvar'-estwhite_`depvar')/sqrt(varblack_`depvar'+varwhite_`depvar')
	di "Hispanic-White difference = " esthispanic_`depvar'-estwhite_`depvar'
	di "T-statistic, Hispanic-White = " /// 
		(esthispanic_`depvar'-estwhite_`depvar')/sqrt(varhispanic_`depvar'+varwhite_`depvar')
	di "Black-Hispanic difference = " estblack_`depvar'-esthispanic_`depvar'
	di "T-statistic, Black-Hispanic = " /// 
		(estblack_`depvar'-esthispanic_`depvar')/sqrt(varblack_`depvar'+varhispanic_`depvar')
	di _new _dup(76) "*" _new
}
/* 
Similar to the race comparison, none of the longer term outcomes do not significantly vary 
by race, and thus the interpretations above do not gain any support. 
*/

*Another approach -including the interaction terms directly 
gen maleXhead = male*head_start 
gen blackXhead = black*head_start

xtreg fphealth head_start male maleXhead, i(mom_id) fe robust
xtreg fphealth head_start blackXhead, i(mom_id) fe robust

xtreg hsgrad head_start male maleXhead, i(mom_id) fe robust
xtreg hsgrad head_start blackXhead, i(mom_id) fe robust
*Again, the interaction terms are not statistically significant, which 
*indicates that the effects of Head Start on longer term outcomes do not 
*vary by race and by sex. 

******************q8*********************

/*
based on the results, the Biden's administration's position seems better 
supported by the evidence we obtained. Using the HeadStart data, the models show 
that there are many positive quality relationships assoicated with the early-childhood 
education programs, which lead to better outcomes both socially and academically,
and the fact that some effects are lasting makes such programs more important to study
and implement. 

so far, we studied the effects of Head Start participation on children using 
different outcome variables, but we did not pay much attention to the qaulity of
such programs and how improving or degrading the qaulity affects children's outcome.
For this reason, although I feel confident that expanding federal funding for early-childhood
education programs will help children in someways, I am not exactly comfortable 
using the results I found here to predict the effects of such an expansion as
what we did in the Head Start program data analysis would be better for cases where 
we predict the effects of implementation of ealry childhood programs rather than expansion. 
Moreover, even after using the fixed effects model, there may still be unobservable 
characterisitcs of either the program or the children that are correlated with both 
the participation and future outcomes.

However, if the expansion in the question means increasing the avalible slots for 
early childhood education programs, (which will also increase the number of 
participants) I would feel more comfortable using the results to predict the 
effects of such an expansion. This is because we controlled for many individual 
characteristics and group OVB in our model, so predicting the effects of the 
program on additional children is applicable. 


*/








