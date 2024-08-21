set scheme cleanplots, perm
xtset country_no year


*Grafiken*



***Durchschnittliche Kapitalmarktliberalisierung pro Jahr alle Länder***
use kaopen_2021.dta, clear

collapse (mean) ka_open, by(year)
twoway (line ka_open year), title() xlabel() ylabel() xtitle() ytitle()

***Durchschnittliche Kapitalmarktliberalisierung pro Jahr ohne high income***
use kaopen_2021.dta, clear

encode classification, gen(incclass)
drop if incclass == 2

collapse (mean) ka_open, by(year)
twoway (line ka_open year), title() xlabel() ylabel() xtitle() ytitle()
	   
	   
*liabilities*
use ewn_liabilities.dta, clear

drop if year == 2023
* Summieren der Verbindlichkeiten nach Jahr
collapse (sum) DebtLiabilities FDILiabilites Portfolioeqliabilites financialderivativesliabiliti Totalliabilities, by(year)

* Umbenennen der Variablen für einfacheres Handling
rename DebtLiabilities debt
rename FDILiabilites fdi
rename Portfolioeqliabilites portfolio
rename financialderivativesliabiliti derivatives
rename Totalliabilities total
*Teilen durch 1 Mrd für übersicht*

local vars debt fdi portfolio derivatives total
foreach var in `vars' {
    replace `var'= `var' / 1e9
}


* Erstellen des Line-Plots*
set dp comma
twoway (line debt year) (line fdi year) (line portfolio year) (line total year), title() xtitle() ytitle()  yla(, format(%9.0fc)) legend(order(1 "Schuldverbindlichkeiten" 2 "Portfolioverbindlichkeiten" 3 "FDI-Verbindlichkeiten" 4 "Verbindlichkeiten insgesamt"))

