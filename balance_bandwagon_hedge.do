use "C:\Users\crrc12\Desktop\NickBarker\Data\NDI_2016_March_31.03.16_Public-nw.dta", clear

set more off

////// Weights
svyset PSU [pweight=WTIND], strata(SUBSTRATUM) fpc(NPSUSS)singleunit(certainty) || ID, fpc(NHHPSU) || _n, fpc(NADHH)


///// Variables 

/// Threat Perception (recode GEOTHREAT) Base category 02 = 'Not Russia'

recode GEOTHREAT (-1/3=2)(4=1)(5/12=2) (else=.), gen(GEOTHREAT_r) 

label var GEOTHREAT_r "Threat Perception"

label define GEOTHREAT_r 1 "Russia", modify
label define GEOTHREAT_r 2 "Not Russia", modify

label values GEOTHREAT_r GEOTHREAT_r



/// Controls: Demographic variables 

// recode SUBSTRATUM Base category 03 = Rural

recode SUBSTRATUM (1=1) (2=2) (3=3) (4=2) (5=3) (6=2) (7=3) (8=2) (9=3) (10=3) (11=2) (else=.), gen (SUBSTRATUM_r)

label var SUBSTRATUM_r "Settlement type"

label define SUBSTRATUM_r 1 "Capital", modify 
label define SUBSTRATUM_r 2 "Urban", modify 
label define SUBSTRATUM_r 3 "Rural", modify 

label values SUBSTRATUM_r SUBSTRATUM_r



// recode Education Base category 03 = Higher than secondary

recode RESPEDU (1/3=1) (4=2) (5/6=3) (else=.), gen(RESPEDU_r)

label var RESPEDU_r "Education"

label define RESPEDU_r 1 "Secondary or lower", modify
label define RESPEDU_r 2 "Vocational/technical degree", modify
label define RESPEDU_r 3 "Higher than secondary", modify 

label values RESPEDU_r RESPEDU_r 


/// Controls: Domestic political preferences/attitudes 


// Party support Base category 01 = GD

recode PARTYSUPP1 (8=1) (7=2) (18=3) (-1=3) (1/6=4) (9/17=4) (else=.), gen (PARTYSUPP1_r)

label var PARTYSUPP1_r "Party Support"

label define PARTYSUPP1_r 1 "Georgian Dream", modify
label define PARTYSUPP1_r 2 "UNM", modify
label define PARTYSUPP1_r 3 "No party/Don't know", modify
label define PARTYSUPP1_r 4 "Other party", modify

label value PARTYSUPP1_r PARTYSUPP1_r




// Political Direction Base category 02 = No Change

recode POLDIRN (1/2=1) (3=2) (4/5=3) (else=.), gen(POLDIRN_r)

label var POLDIRN_r "Political Direction"

label define POLDIRN_r 1 "Wrong Direction", modify
label define POLDIRN_r 2 "No Change", modify 		
label define POLDIRN_r 3 "Right Direction", modify

label value POLDIRN_r POLDIRN_r




/// DV: foreign policy preference (recode GEFORPOL) Base category 01 = ProWestern

recode GEFORPOL (1=1) (2=2) (3=3) (4=4) (else=.), gen(GEFORPOL_r) 

label var GEFORPOL_r "Foreign Policy Preference"

label define GEFORPOL_r 1 "Pro-Western", modify 
label define GEFORPOL_r 2 "Pro-Western, good relations with Russia", modify
label define GEFORPOL_r 3 "Pro-Russian, good relations with EU & NATO", modify
label define GEFORPOL_r 4 "Pro-Russian", modify

label values GEFORPOL_r GEFORPOL_r  



//// DV: foreign policy preference (alternative recode GEFORPOL) Base category 01 = ProWestern2  
/// Not used in the analysis

recode GEFORPOL (1=1) (2=2) (3=2) (4=3) (else=.), gen(GEFORPOL_r2) 

label var GEFORPOL_r2 "Foreign Policy Preference 2"

label define GEFORPOL_r2 1 "Pro-Western2", modify 
label define GEFORPOL_r2 2 "Hedge", modify 
label define GEFORPOL_r2 3 "Pro-Russian2", modify

label values GEFORPOL_r2 GEFORPOL_r2

 


/////// multinomial regression 


//// mlogit

/// Foreign policy preference GEFORPOL_r 
// Model with GEOTHREAT_r 'not Russia' as base category for threat perception


// Outcome 1 ProWestern 
// Outcome 2 ProWestern_hedge (Pro-Western, but good relations with Russia)
// Outcome 3 ProRussian_hedge (Pro-Russian, but good relations with West)
// Outcome 4 ProRussian

// Just GEOTHREAT_r
qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r, base (1)
margins, dydx(*) predict(outcome(1)) post  
estimates store ProWestern0

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r, base (1)
margins, dydx(*) predict(outcome(2)) post  
estimates store ProWestern_hedge0

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r, base (1)
margins, dydx(*) predict(outcome(3)) post  
estimates store ProRussian_hedge0

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r, base (1)
margins, dydx(*) predict(outcome(4)) post  
estimates store ProRussian0

coefplot ProWestern0 ||  ProWestern_hedge0 || ProRussian_hedge0 || ProRussian0, drop(_cons) xline(0)

// Full model
qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(1)) post  
estimates store ProWestern

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(2)) post  
estimates store ProWestern_hedge

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(3)) post  
estimates store ProRussian_hedge

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(4)) post  
estimates store ProRussian

// coefplot all variables
coefplot ProWestern ||  ProWestern_hedge || ProRussian_hedge || ProRussian, drop(_cons) xline(0)

// coefplot only threat, education, party support, country direction  
coefplot ProWestern ||  ProWestern_hedge || ProRussian_hedge || ProRussian, keep(*.GEOTHREAT_r || *.RESPEDU_r || *.PARTYSUPP1_r || *.POLDIRN_r ) xline(0) 



// Model without GEOTHREAT_r
qui svy: mlogit GEFORPOL_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(1)) post  
estimates store ProWestern_exthreat

qui svy: mlogit GEFORPOL_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(2)) post  
estimates store ProWesternHedge_exthreat

qui svy: mlogit GEFORPOL_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(3)) post  
estimates store ProRussianHedge_exthreat

qui svy: mlogit GEFORPOL_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(4)) post  
estimates store ProRussian_exthreat

coefplot ProWestern_exthreat ||  ProWesternHedge_exthreat || ProRussianHedge_exthreat || ProRussian_exthreat, drop(_cons) xline(0)



// Model without POLDIRN_r 	
qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r, base (1)
margins, dydx(*) predict(outcome(1)) post  
estimates store ProWestern_expoldirn

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r, base (1)
margins, dydx(*) predict(outcome(2)) post  
estimates store ProWesternHedge_expoldirn

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r, base (1)
margins, dydx(*) predict(outcome(3)) post  
estimates store ProRussianHedge_expoldirn

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r, base (1)
margins, dydx(*) predict(outcome(4)) post  
estimates store ProRussian_expoldirn

coefplot ProWestern_expoldirn ||  ProWesternHedge_expoldirn || ProRussianHedge_expoldirn || ProRussian_expoldirn, drop(_cons) xline(0)



// Model without PARTYSUPP1_r
qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(1)) post  
estimates store ProWestern_Expartysupp

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(2)) post  
estimates store ProWesternHedge_Expartysupp

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(3)) post  
estimates store ProRussianHedge_Expartysupp

qui svy: mlogit GEFORPOL_r b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(4)) post  
estimates store ProRussian_Expartysupp

coefplot ProWestern_Expartysupp ||  ProWesternHedge_Expartysupp || ProRussianHedge_Expartysupp || ProRussian_Expartysupp, drop(_cons) xline(0)



/// Alternative coding of DV GEFORPOL_r2 (3 categories) /// Not used in the analysis
qui svy: mlogit GEFORPOL_r2 b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(1)) post  
estimates store ProWestern2

qui svy: mlogit GEFORPOL_r2 b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(2)) post  
estimates store Hedge2

qui svy: mlogit GEFORPOL_r2 b02.GEOTHREAT_r i.RESPSEX i.AGEGROUP b01.ETHNOCODE b03.SUBSTRATUM_r b03.RESPEDU_r b01.PARTYSUPP1_r b02.POLDIRN_r, base (1)
margins, dydx(*) predict(outcome(3)) post  
estimates store ProRussian2

coefplot ProWestern2 ||  Hedge2 || ProRussian2, drop(_cons) xline(0) 



