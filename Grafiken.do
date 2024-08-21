set scheme cleanplots, perm
xtset country_no year


*Grafiken*



***Durchschnittliche Kapitalmarktliberalisierung pro Jahr alle Länder***
use "/Users/vincentfachinger/Documents/UNI/AWG M.A./Masterarbeit/Grafiken/kaopen_2021.dta", clear

collapse (mean) ka_open, by(year)
twoway (line ka_open year), title() xlabel() ylabel() xtitle() ytitle()

***Durchschnittliche Kapitalmarktliberalisierung pro Jahr ohne high income***
import excel "/Users/vincentfachinger/Documents/UNI/AWG M.A./Masterarbeit/Daten Tabellen/kaopen_2021.xls", firstrow clear

encode classification, gen(incclass)
drop if incclass == 2

collapse (mean) ka_open, by(year)
twoway (line ka_open year), title() xlabel() ylabel() xtitle() ytitle()
	   
	   
*liabilities*
import excel "/Users/vincentfachinger/Documents/UNI/AWG M.A./Masterarbeit/Daten Tabellen/Datensatz_Masterarbeit_rep.xlsx", sheet("Liabilities") firstrow clear

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


* Erstellen des Line-Plots
set dp comma
twoway (line debt year) (line fdi year) (line portfolio year) (line total year), title() xtitle() ytitle()  yla(, format(%9.0fc)) legend(order(1 "Schuldverbindlichkeiten" 2 "Portfolioverbindlichkeiten" 3 "FDI-Verbindlichkeiten" 4 "Verbindlichkeiten insgesamt"))

