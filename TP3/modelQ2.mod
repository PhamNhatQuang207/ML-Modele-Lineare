# Ornicar - Minimiser le coût des ingrédients restants

set INGREDIENTS;
set RECETTES;

# Paramètres
param stock {INGREDIENTS} >= 0;          # kg disponible
param prix  {INGREDIENTS} >= 0;          # €/kg
param percent {INGREDIENTS, RECETTES}

# Variables
var poids_recette {RECETTES} >= 0;

#Definitions
var util {i in INGREDIENTS, r in RECETTES} = (percent[i,r]/100) * poids_recette[r];

#Constraints
s.t. StockLimit {i in INGREDIENTS}:
    sum {r in RECETTES} util [i,r] <= stock[i]
s.t. Diversite {r in RECETTES}:
    poids_recette[r] <= 0.4 * sum {k in RECETTES} poids_recette[k];

#Objectif
minimize CoutReste:
    sum {i in INGREDIENTS} prix[i] * (stock[i] - sum {r in RECETTES} util[i,r]);