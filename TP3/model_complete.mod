# Ornicar - Minimiser le coût des ingrédients restants

set INGREDIENTS;
set RECETTES;
set NUTRIMENTS;
set JOURS = 1..15;

# Paramètres
param stock {INGREDIENTS} >= 0;          # kg disponible
param prix  {INGREDIENTS} >= 0;          # €/kg
param calories {INGREDIENTS} >= 0;
param pourc {INGREDIENTS, RECETTES} >= 0;
param nutr_percent {INGREDIENTS,NUTRIMENTS} >=0;
param minNutr {NUTRIMENTS} >= 0;
param maxNutr {NUTRIMENTS} >= 0;

# Variables
var mange{JOURS,RECETTES} binary; 
var is_cooked {RECETTES} binary;
var nombre_plats {r in RECETTES} = sum {j in JOURS} mange[j,r];
param total_plats = 15;

#Definitions
param calo_par_kg {r in RECETTES} := sum {i in INGREDIENTS} (pourc[i,r]/100)*calories[i];
var poids_recette {r in RECETTES} = nombre_plats[r] * (2000 / calo_par_kg[r]);
var util {i in INGREDIENTS, r in RECETTES} = (pourc[i,r]/100) * poids_recette[r];
var total_nutr {n in NUTRIMENTS} = sum {i in INGREDIENTS,r in RECETTES} util[i,r] * nutr_percent[i,n] * 10; 

#Constraints
s.t. StockLimit {i in INGREDIENTS}:
    sum {r in RECETTES} util [i,r] <= stock[i];
s.t. Diversite {r in RECETTES}:
    poids_recette[r] <= 0.4 * sum {k in RECETTES} poids_recette[k];
s.t. NutriMin {n in NUTRIMENTS}:
	total_nutr [n] >= minNutr[n] * total_plats;
s.t. NutriMax {n in NUTRIMENTS}:
	total_nutr [n] <= maxNutr[n] * total_plats;
s.t. UnPlatParJour {j in JOURS}:
    sum {r in RECETTES} mange[j,r] = 1;
s.t. Espacement {j in 1..(card(JOURS)-4), r in RECETTES}:
    sum {k in 0..4} mange[j+k, r] <= 1;
s.t. Min_Batch_Size {r in RECETTES}:
    nombre_plats[r] >= 2 * is_cooked[r];
s.t. Link_Cooked_Count {r in RECETTES}:
    nombre_plats[r] <= 15 * is_cooked[r];

#Objectif
minimize CoutReste:
    sum {i in INGREDIENTS} prix[i] * (stock[i] - sum {r in RECETTES} util[i,r]);
