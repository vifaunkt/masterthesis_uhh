use datensatz_fachinger_master.dta, clear
encode countrycode, gen(country_no)
encode classifiaction, gen(incclass)
encode region, gen(region_no)
encode ERR, gen(ERR_enc)

drop region classifiaction countrycode country currency W X Y
xtset country_no year


*negative werte transformieren für log*
* Schleife über alle Variablen
foreach var in ER VIX SFL CAB FXr PI Qi GDPtotal FDI {
    * Bestimmen Sie den negativsten Wert für die Variable
    summarize `var', detail
    scalar min_`var' = r(min)

    * Verschieben der Daten durch den negativsten Wert
    gen shifted_`var' = `var' + abs(min_`var')
}


gen logER = log(shifted_ER)
gen logQi = log(shifted_Qi)
gen logSFL = log(shifted_SFL)
gen logGDP = log(shifted_GDPtotal)
gen logFXr = log(shifted_FXr)
gen logPI = log(shifted_PI)
gen logVIX = log(shifted_VIX)
gen logCAB = log(shifted_CAB)
gen logPOP = log(POP)
gen logFDI = log(shifted_FDI)
gen liq = VIX * SFL 


* für 2023 liegen kaum Beobachtungen vor
drop if year == 2023

*Zwischen 1996 und 2000 wurden POlitische Stabilität Index nur alle 2 Jahre erhoben -> daher lineare Interpolation
bysort country_no: ipolate POL year, generate (pol)
drop POL


*COSTA RICA (28)*

*Unit Root*
dfuller  ER if country_no == 28, lags(2)  
* nicht stationär *
dfuller  Qi if country_no == 28, lags(2) 
* nicht stationär *
dfuller  liq if country_no == 28, lags(2) 
* stationär *
dfuller  GDP if country_no == 28, lags(5) trend 
* nicht stationär*

dfuller  FXr if country_no == 28, lags(5)
* nicht stationär *
dfuller  PI if country_no == 28, lags (2) 
* nicht stationär*
dfuller  VIX if country_no == 28, lags (2)
* stationär *
dfuller  CAB if country_no == 28, lags (2) 
*nicht stationär* 
dfuller  POP if country_no == 28, lags(5)
*nicht stationär*

gen dGDP = d.GDPtotal
gen dER = d.ER
gen dFXr = d.FXr
gen dCAB = d.CAB
gen dPOP = d.POP
gen dQi = d.Qi
gen dPI = d.PI
gen dliq = d.liq
gen PIGDP = PI/GDP


dfuller  dER if country_no == 28,   
* nicht stationär *
dfuller  dQi if country_no == 28, 
* nicht stationär *
dfuller  dliq if country_no == 28
* stationär *
dfuller  dGDP if country_no == 28,  
* nicht stationär*

dfuller  dFXr if country_no == 28,

dfuller  dPI if country_no == 28,

dfuller  dCAB if country_no == 28, 

dfuller  dPOP if country_no == 28, 


*Full Model (4)*
*ARDL*
ardl ER logGDP FXr CAB PIGDP Qi liq  if country_no == 28, maxlags(2) aic
*ECM*
 ardl ER logGDP FXr CAB PIGDP Qi liq  if country_no == 28, lags(2 2 2 2 0 2 2) ec1

*kointegratinstest*
 estat btest
 
 *(1)*
ardl ER logGDP FXr CAB liq  if country_no == 28, maxlags(2) aic
 ardl ER logGDP FXr CAB liq  if country_no == 28, lags(2 1 2 0 0) ec1
 *mit pop und ec1*

 *kointegratinstest*
 estat btest
 
 
 *(2)*
 

ardl ER PIGDP if country_no == 28, maxlags(2) aic
 ardl ER PIGDP if country_no == 28, lags(1 1) ec1
 *mit pop und ec1*

 *kointegratinstest*
 estat btest
 
*(3)*
 
ardl ER Qi if country_no == 28, maxlags(2) aic
 ardl ER Qi if country_no == 28, lags(1 1) ec1
 *mit pop und ec1*

 *kointegratinstest*
 estat btest
 
 
 * Kenia(55)*

*Unit Root*
dfuller  ER if country_no == 55, lags(2)  
* nicht stationär *
dfuller  Qi if country_no == 55, lags(2) 
* nicht stationär *
dfuller  liq if country_no == 55, lags(2) 
* stationär *
dfuller  GDP if country_no == 55, lags(5) trend 
* nicht stationär*

dfuller  FXr if country_no == 55, lags(5)
* nicht stationär *
dfuller  PI if country_no == 55, lags (2) 
* nicht stationär*
dfuller  VIX if country_no == 55, lags (2)
* stationär *
dfuller  CAB if country_no == 55, lags (2) 
*nicht stationär* 
dfuller  POP if country_no == 55, lags(5)
*nicht stationär*

gen dGDP = d.GDPtotal
gen dER = d.ER
gen dFXr = d.FXr
gen dCAB = d.CAB
gen dPOP = d.POP
gen dQi = d.Qi
gen dPI = d.PI
gen dliq = d.liq


dfuller  dER if country_no == 55,   
* nicht stationär *
dfuller  dQi if country_no == 55, 
* nicht stationär *
dfuller  dliq if country_no == 55
* stationär *
dfuller  dGDP if country_no == 55,  
* nicht stationär*

dfuller  dFXr if country_no == 55,

dfuller  dPI if country_no == 55,

dfuller  dCAB if country_no == 55, 

dfuller  dPOP if country_no == 55, 


*Full Model (4)*
*ARDL*
ardl ER logGDP FXr CAB PI Qi liq  if country_no == 55, maxlags(2) aic
*ECM*
 ardl ER logGDP FXr CAB PI Qi liq  if country_no == 55, lags(1 2 1 2 1 1 2 2) ec1

*kointegratinstest*
 estat btest
 
 *(1)*
ardl ER logGDP FXr CAB liq  if country_no == 55, maxlags(2) aic
 ardl ER logGDP FXr CAB liq  if country_no == 55, lags(2 2 2 0 2 ) ec1
 *mit pop und ec1*

 *kointegratinstest*
 estat btest
 
 
 *(2)*
 

ardl ER PIGDP if country_no == 55, maxlags(2) aic
 ardl ER PIGDP if country_no == 55, lags(1 1) ec1
 *mit pop und ec1*

 *kointegratinstest*
 estat btest
 
*(3)*
 
ardl ER Qi if country_no == 55, maxlags(2) aic
 ardl ER Qi if country_no == 55, lags(1 1) ec1
 *mit pop und ec1*

 *kointegratinstest*
 estat btest
 