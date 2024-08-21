*Panel-Analyse*

import excel "/Users/vincentfachinger/Documents/UNI/AWG M.A./Masterarbeit/Daten Tabellen/dataonly.xlsx", sheet("Tabelle1") firstrow clear
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
*Alle Einheiten entfernen, bei denen keine einzige Beobachtung zu Portfolioinvestitionen vorliegt
drop if inlist(country_no, 1, 2, 17, 19, 26, 31, 32, 34, 35, 41, 43, 45, 47, 50, 57, 61, 71, 74, 82, 92, 96, 100, 101, 105, 106, 113, 115, 117, 120)
*Alle Einheiten entfernen, bei denen keine einzige Beobachtung zu Zinssätzen vorliegt
drop if inlist(country_no, 18, 20, 24, 28, 40, 48, 71, 74, 82)
*für 2023 liegen kaum Beobachtungen vor*
drop if year == 2023
*Zwischen 1996 und 2000 wurden POlitische Stabilität Index nur alle 2 Jahre erhoben -> daher lineare Interpolation*
bysort country_no: ipolate POL year, generate (pol)
drop POL
* Löschen aller Länder, die nicht mindestens 10 Beobachtungen für Portfolioinvestitionen haben* --> n=63
bysort country_no: egen count_pi = count(PI)
keep if count_pi >=10
drop count_pi


*Unit-Root Tests durchführen*

xtunitroot ips ER, lags(aic 2) demean 
* nicht stationär *
xtunitroot ips Qi, lags(aic 2) 
* stationär *
xtunitroot ips liq, lags(aic 2) 
* stationär *
xtunitroot ips GDP, lags(aic 5) trend 
* stationär, trend weil GDP *
xtunitroot ips FXr, lags(aic 5 )
* nicht stationär *
xtunitroot ips PI, lags (aic 2) 
* stationär*
xtunitroot ips VIX, lags (aic 2)
* stationär *
xtunitroot ips CAB, lags (aic 2) 
*nicht stationär* 
xtunitroot ips POP, lags(aic 5)
*nicht stationär*

*Unit-Root Tests mit Strucutral Breaks*

xtbunitroot GDP, trend known(13) normal csd
*nicht-stationär*
xtbunitroot Qi, known(13) normal csd
*bleibt stationär*
xtbunitroot liq, known(13) normal csd
*bleibt stationär*
xtbunitroot PI, known(13) normal csd
*bleibt stationär*
xtbunitroot VIX, known(13) normal csd
*bleibt stationär*
xtbunitroot ER, known(13) normal csd
xtbunitroot FXr, known(13) normal csd
xtbunitroot CAB, known(13) normal csd
*pop macht mit strukturbruch keinen sinn*


* Differenzieren nicht-stationärer Variablen *
gen dGDP = d.GDPtotal
gen dER = d.ER
gen dFXr = d.FXr
gen dCAB = d.CAB
gen dPOP = d.POP

* weitere URT* 
xtunitroot ips dGDP, lags(aic 2)
xtbunitroot dGDP, known(13) normal csd
xtunitroot ips dER, lags(aic 2) demean
xtbunitroot dER, known(13) normal csd
xtunitroot ips dFXr, lags(aic 2)
xtbunitroot dFXr, known(13) normal csd 
xtunitroot ips dCAB, lags(aic 2) 
xtbunitroot dCAB, known(13) normal csd
xtunitroot ips dPOP, lags(aic 5) 

*alle Variablen nun stationär*

* jetzt Kointegration
xtcointtest pedroni logER logFXr logCAB logGDP, ar(panelspecific) demean
xtcointtest pedroni logER logFXr logCAB logGDP, ar(same) demean
xtcointtest pedroni logER logFXr logCAB logGDP if incclass == 1, ar(panelspecific) demean 
*kointegration vorhanden*

*(1) mit LAGS*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB liq , lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(2)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB Qi, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(3)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(4)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI Qi liq, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 

*EINKOMMEN*

*(1) nach Einkommen  if incclass != 1*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB liq  if incclass != 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(2)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB Qi  if incclass != 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(3)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI  if incclass != 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(4)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI Qi liq  if incclass != 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames)

*(1) nach Einkommen  if incclass = 1*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB liq  if incclass == 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(2)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB Qi  if incclass == 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(3)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI  if incclass == 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(4)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI Qi liq  if incclass == 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames)



*WECHSELKURSREGIME (4= floating, 2,3,5=falling,crawling 1= gekoppelt)*
*(1) nach err *
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB liq  if ERR_enc == 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(2)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB Qi  if ERR_enc == 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(3)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI  if ERR_enc == 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(4)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI Qi liq  if ERR_enc == 1, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames)


drop if ERR_enc == 1
drop if ERR_enc == 6

*(1) mit LAGS*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB liq , lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(2)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB Qi, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(3)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 
*(4)*
xtdcce2 d.logER  d.logGDP d.logFXr d.logCAB PI Qi liq, lr(L.logER L.logFXr L.logCAB L.logGDP) p(L.logER logFXr logCAB logGDP) nocross lr_options(xtpmgnames) 

