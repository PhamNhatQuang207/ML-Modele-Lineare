# Ornicar - Minimiser le coût des ingrédients restants (avec contraintes nutritionnelles)

set INGREDIENTS;
set RECETTES;
set NUTRIMENTS;
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
#       NUTRITIONNELLES         #
# ----------------------------- #

# nutr_percent[i,n] = proportion (%) du nutriment n dans l’ingrédient i
param nutr_percent {INGREDIENTS, NUTRIMENTS} >= 0;

# Conversion en fraction (kg nutriment / kg ingrédient)
param nutr_frac {i in INGREDIENTS, n in NUTRIMENTS} := nutr_percent[i,n] / 100;

# Nutriments (grammes par kg de recette)
param N_recette {j in RECETTES, n in NUTRIMENTS} :=
    1000 * sum {i in INGREDIENTS} a[i,j] * nutr_frac[i,n];

# Bornes min et max des nutriments (g/repas)
param minNutr {NUTRIMENTS} >= 0;
param maxNutr {NUTRIMENTS} >= 0;

# --- Nombre total de plats ---
var TotalPlates >= 0;

s.t. DefTotal:
    TotalPlates = sum {j in RECETTES} nombre_plats[j];

# Ornicar prépare 15 plats (1 par jour pendant 15 jours)
s.t. Total15Jours:
    TotalPlates = 15;

# --- Contraintes nutritionnelles moyennes ---
s.t. Nutriment_min {n in NUTRIMENTS}:
    sum {j in RECETTES} w[j] * N_recette[j,n] >= minNutr[n] * TotalPlates;

s.t. Nutriment_max {n in NUTRIMENTS}:
    sum {j in RECETTES} w[j] * N_recette[j,n] <= maxNutr[n] * TotalPlates;

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