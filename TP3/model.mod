# Ornicar - Minimiser le coût des ingrédients restants

set INGREDIENTS;
set RECETTES;

# Paramètres
param stock {INGREDIENTS} >= 0;          # kg disponible
param prix  {INGREDIENTS} >= 0;          # €/kg
param pourc {INGREDIENTS,RECETTES} >= 0; # pourcentage (%) de l'ingrédient i dans la recette j

# Variables
var w {RECETTES} >= 0; # poids (kg) de chaque recette

# Définition : a[i,j] = proportion (kg ingrédient i / kg recette j)
param a {i in INGREDIENTS, j in RECETTES} := pourc[i,j] / 100;

# Contraintes
s.t. StockLimit {i in INGREDIENTS}:
    sum {j in RECETTES} a[i,j] * w[j] <= stock[i];

s.t. Diversite {j in RECETTES}:
    w[j] <= 0.4 * sum {k in RECETTES} w[k];

# Objectif : minimiser coût des restes
minimize CoutRestes:
    sum {i in INGREDIENTS} prix[i] * (stock[i] - sum {j in RECETTES} a[i,j] * w[j]);
