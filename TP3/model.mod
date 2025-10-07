# Ornicar - Minimiser le coût des ingrédients restants

set INGREDIENTS;
set RECETTES;

# Paramètres
param stock {INGREDIENTS} >= 0;          # kg disponible
param prix  {INGREDIENTS} >= 0;          # €/kg
param calories {INGREDIENTS} >= 0;       # kcal/kg
param pourc {INGREDIENTS,RECETTES} >= 0; # pourcentage (%) de l'ingrédient i dans la recette j

# Variables
var w {RECETTES} >= 0; # poids (kg) de chaque recette
var nombre_plats {RECETTES} integer >= 0; # nombre total de plats

# Définition : a[i,j] = proportion (kg ingrédient i / kg recette j)
param a {i in INGREDIENTS, j in RECETTES} := pourc[i,j] / 100;
param calories_per_kg {j in RECETTES} := sum {i in INGREDIENTS} a[i,j] * calories[i];
param q {j in RECETTES} := 2000 / calories_per_kg[j]; # kg recette j pour 2000 kcal

s.t. LienPoids {j in RECETTES}:
    w[j] = q[j] * nombre_plats[j];

# Contraintes
s.t. StockLimit {i in INGREDIENTS}:
    sum {j in RECETTES} a[i,j] * w[j] <= stock[i];

s.t. Diversite {j in RECETTES}:
    w[j] <= 0.4 * sum {k in RECETTES} w[k];

# Objectif : minimiser coût des restes
minimize CoutRestes:
    sum {i in INGREDIENTS} prix[i] * (stock[i] - sum {j in RECETTES} a[i,j] * w[j]);
