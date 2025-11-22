set USINES;
set PAPIERS;

param cout {USINES} >= 0;
param demande {PAPIERS} >= 0;            
param production {USINES, PAPIERS} >= 0; 

#Variable
var jour{USINES} >= 0;

#Objectif
minimize frais:
    sum {u in USINES} cout[u] * jour[u];

#Constraint
s.t. besoins{p in PAPIERS}:
    sum {u in USINES} production[u,p] * jour[u] >= demande[p];
