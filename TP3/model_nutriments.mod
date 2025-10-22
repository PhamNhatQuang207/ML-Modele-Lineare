# Ornicar - Minimiser le coût des ingrédients restants (avec contraintes nutritionnelles)

set INGREDIENTS;
set RECETTES;

# Paramètres
param stock {INGREDIENTS} >= 0;          # kg disponible
param prix  {INGREDIENTS} >= 0;          # €/kg
param calories {INGREDIENTS} >= 0;       # kcal/kg
param pourc {INGREDIENTS,RECETTES} >= 0; # pourcentage (%) de l'ingrédient i dans la recette j

# Variables
var w {RECETTES} >= 0;                    # poids (kg) de chaque recette
var nombre_plats {RECETTES} integer >= 0; # nombre total de plats

# Définition : a[i,j] = proportion (kg ingrédient i / kg recette j)
param a {i in INGREDIENTS, j in RECETTES} := pourc[i,j] / 100;

# Calcul des calories par kg de recette
param calories_per_kg {j in RECETTES} := sum {i in INGREDIENTS} a[i,j] * calories[i];

# q[j] = kg de recette j pour 2000 kcal
param q {j in RECETTES} := 2000 / calories_per_kg[j];

# Lien entre le poids total cuisiné et le nombre de plats
s.t. LienPoids {j in RECETTES}:
    w[j] = q[j] * nombre_plats[j];

# Contraintes de stock
s.t. StockLimit {i in INGREDIENTS}:
    sum {j in RECETTES} a[i,j] * w[j] <= stock[i];

# Diversité : chaque recette < 40% du poids total
s.t. Diversite {j in RECETTES}:
    w[j] <= 0.4 * sum {k in RECETTES} w[k];

# ----------------------------- #
#        Planification          #
# ----------------------------- #

set JOURS := 1..15;

# Recette cuisinée ou non (binaire)
var y {RECETTES} binary;

# Si cuisinée, au moins 2 plats
s.t. LienCuisine {r in RECETTES}:
    nombre_plats[r] <= 15 * y[r];

s.t. MinDeuxPlats {r in RECETTES}:
    nombre_plats[r] >= 2 * y[r];

# Planification quotidienne
var x {JOURS, RECETTES} binary;

s.t. UnPlatParJour {j in JOURS}:
    sum {r in RECETTES} x[j,r] = 1;

s.t. TotalPlatsRecette {r in RECETTES}:
    sum {j in JOURS} x[j,r] = nombre_plats[r];

# Espacement d'au moins 4 jours entre deux plats identiques
s.t. Espacement {r in RECETTES, j in 1..15-4}:
    sum {t in j..j+4} x[t, r] <= 1;

# ----------------------------- #
#     Données nutritionnelles   #
# ----------------------------- #

param glucide_percent {INGREDIENTS};
param proteine_percent {INGREDIENTS};
param lipide_percent {INGREDIENTS};
param fibre_percent {INGREDIENTS};

# Conversion en fraction (kg/kg)
param glucide_frac {i in INGREDIENTS} := glucide_percent[i] / 100;
param proteine_frac {i in INGREDIENTS} := proteine_percent[i] / 100;
param lipide_frac {i in INGREDIENTS} := lipide_percent[i] / 100;
param fibre_frac {i in INGREDIENTS} := fibre_percent[i] / 100;

# Nutriments (grammes par kg de recette)
param N_glucide {j in RECETTES} := 1000 * sum {i in INGREDIENTS} a[i,j] * glucide_frac[i];
param N_proteine {j in RECETTES} := 1000 * sum {i in INGREDIENTS} a[i,j] * proteine_frac[i];
param N_lipide  {j in RECETTES} := 1000 * sum {i in INGREDIENTS} a[i,j] * lipide_frac[i];
param N_fibre   {j in RECETTES} := 1000 * sum {i in INGREDIENTS} a[i,j] * fibre_frac[i];

# Bornes min et max des nutriments (g/repas)
param min_glucide;
param max_glucide;
param min_proteine;
param max_proteine;
param min_lipide;
param max_lipide;
param min_fibre;
param max_fibre;

# Nombre total de plats
var TotalPlates >= 0;

s.t. DefTotal:
    TotalPlates = sum {j in RECETTES} nombre_plats[j];

s.t. Total15Jours:
    TotalPlates = 15;

# Contraintes nutritionnelles moyennes
s.t. Avg_glucide_low:
    sum {j in RECETTES} w[j] * N_glucide[j] >= min_glucide * TotalPlates;

s.t. Avg_glucide_high:
    sum {j in RECETTES} w[j] * N_glucide[j] <= max_glucide * TotalPlates;

s.t. Avg_proteine_low:
    sum {j in RECETTES} w[j] * N_proteine[j] >= min_proteine * TotalPlates;

s.t. Avg_proteine_high:
    sum {j in RECETTES} w[j] * N_proteine[j] <= max_proteine * TotalPlates;

s.t. Avg_lipide_low:
    sum {j in RECETTES} w[j] * N_lipide[j] >= min_lipide * TotalPlates;

s.t. Avg_lipide_high:
    sum {j in RECETTES} w[j] * N_lipide[j] <= max_lipide * TotalPlates;

s.t. Avg_fibre_low:
    sum {j in RECETTES} w[j] * N_fibre[j] >= min_fibre * TotalPlates;

s.t. Avg_fibre_high:
    sum {j in RECETTES} w[j] * N_fibre[j] <= max_fibre * TotalPlates;


# Objectif : minimiser le coût des ingrédients restants
minimize CoutRestes:
    sum {i in INGREDIENTS} prix[i] * (stock[i] - sum {j in RECETTES} a[i,j] * w[j]);
