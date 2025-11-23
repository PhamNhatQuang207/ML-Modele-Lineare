# Ornicar - Minimiser le coût des ingrédients restants (avec contraintes nutritionnelles générales)

set INGREDIENTS;
set RECETTES;
set NUTRIMENTS;

# --- Paramètres de base ---
param stock {INGREDIENTS} >= 0;          # kg disponible
param prix  {INGREDIENTS} >= 0;          # €/kg
param calories {INGREDIENTS} >= 0;       # kcal/kg
param pourc {INGREDIENTS, RECETTES} >= 0; # pourcentage (%) de l'ingrédient i dans la recette j

# --- Variables principales ---
var w {RECETTES} >= 0;                    # poids (kg) de chaque recette
var nombre_plats {RECETTES} integer >= 0; # nombre total de plats préparés

# --- Proportion d'ingrédients dans chaque recette ---
param a {i in INGREDIENTS, j in RECETTES} := pourc[i,j] / 100;

# --- Calories par kg de recette ---
param calories_per_kg {j in RECETTES} := sum {i in INGREDIENTS} a[i,j] * calories[i];

# --- Masse d’un plat (kg) pour 2000 kcal ---
param q {j in RECETTES} := 2000 / calories_per_kg[j];

# --- Lien entre le poids total et le nombre de plats ---
s.t. LienPoids {j in RECETTES}:
    w[j] = q[j] * nombre_plats[j];

# --- Contraintes de stock ---
s.t. StockLimit {i in INGREDIENTS}:
    sum {j in RECETTES} a[i,j] * w[j] <= stock[i];

# --- Diversité : aucune recette ne dépasse 40% du total cuisiné ---
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

# --- Contraintes nutritionnelles moyennes ---
s.t. Nutriment_min {n in NUTRIMENTS}:
    sum {j in RECETTES} w[j] * N_recette[j,n] >= minNutr[n] * TotalPlates;

s.t. Nutriment_max {n in NUTRIMENTS}:
    sum {j in RECETTES} w[j] * N_recette[j,n] <= maxNutr[n] * TotalPlates;

# ----------------------------- #
#          OBJECTIF             #
# ----------------------------- #

# Minimiser le coût des ingrédients restants
minimize CoutRestes:
    sum {i in INGREDIENTS} prix[i] *
        (stock[i] - sum {j in RECETTES} a[i,j] * w[j]);

# ----------------------------- #
