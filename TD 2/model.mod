set USINES;
set PAPIERS;
set SEMAINES;
param cout {USINES} >= 0;
param demande {SEMAINES,PAPIERS} >= 0;            
param production {USINES, PAPIERS} >= 0; 
param stock_initial {PAPIERS} >= 0;

#Variable
var jours_ouvres {SEMAINES, USINES} >= 0;
var qte_produite {SEMAINES, PAPIERS} >= 0;
var qte_stock {SEMAINES, PAPIERS} >= 0;

#Objectif
minimize frais:
    sum {s in SEMAINES} (
        sum {u in USINES} cout[u] * jours_ouvres[s,u] + 
        sum {p in PAPIERS} qte_stock[s,p] * 5
    );

#Constraint
s.t. Relation_Production {s in SEMAINES, p in PAPIERS}:
    qte_produite[s,p] = sum {u in USINES} production[u,p] * jours_ouvres[s,u];
s.t. Stock_Init {p in PAPIERS}:
   qte_stock[1, p] = stock_initial[p];
s.t. Flow_Conservation {s in 1..(3-1), p in PAPIERS}:
   qte_stock[s+1, p] = qte_stock[s,p] + qte_produite[s,p] - demande[s,p] ; 
s.t. Stock_Final_Condition {p in PAPIERS}:
    qte_stock[3,p] + qte_produite[3,p] - demande[3,p] >= stock_initial[p] ;