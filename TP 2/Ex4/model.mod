set OBJETS;

param valeur {OBJETS} >= 0;
param poids {OBJETS} >= 0;
param volume {OBJETS} >= 0;
param dispo {OBJETS} >= 0;

param poidsMax >= 0;
param volumeMax >= 0;

# variable: nombre d'objets à acheter
var x {i in OBJETS} integer >= 0, <= dispo[i];   # par défaut linéaire, si besoin d'entiers: declare integer

maximize profit:
    sum {i in OBJETS} valeur[i] * x[i];

subject to contrainte_poids:
    sum {i in OBJETS} poids[i] * x[i] <= poidsMax;

subject to contrainte_volume:
    sum {i in OBJETS} volume[i] * x[i] <= volumeMax;
