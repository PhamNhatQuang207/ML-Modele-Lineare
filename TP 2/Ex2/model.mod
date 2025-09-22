set MEDIA;

param cout {MEDIA} >= 0;          # coût par unité (en milliers d'euros)
param audience {MEDIA} >= 0;      # consommateurs atteints par unité
param travail {MEDIA} >= 0;       # personnes-semaines par unité
param dispo_min {MEDIA} >= 0;     # min obligatoire (ex: 10 minutes TV)
param budget >= 0;                # budget total (en milliers d'euros)
param travailMax >= 0;            # ressources totales en personnes-semaines

var x {m in MEDIA} >= dispo_min[m];

maximize audience_totale:
    sum {m in MEDIA} audience[m] * x[m];

# contrainte budget
subject to contrainte_budget:
    sum {m in MEDIA} cout[m] * x[m] <= budget;

# contrainte travail
subject to contrainte_travail:
    sum {m in MEDIA} travail[m] * x[m] <= travailMax;
