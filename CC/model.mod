set BISCUITS;
param n ;
set SEMAINES := 1..n;

param poidsStockMax {SEMAINES} >= 0;
param poidsStockMin >= 0;
param coutStockage >= 0;
param nbEspaceStock >= 0;
param commande{BISCUITS, SEMAINES} >= 0;
param productionMax {BISCUITS, SEMAINES} >= 0;

var stockDebutS {BISCUITS, 1..n+1} >= 0;
var production {BISCUITS, SEMAINES} >= 0;
var utiliseEspaceStock {BISCUITS, SEMAINES} binary;

minimize cout_total:
    sum {b in BISCUITS, s in SEMAINES} coutStockage * stockDebutS[b,s+1] ;

s.t. equilibre_stock {b in BISCUITS, s in SEMAINES}:
    stockDebutS[b,s] + production[b,s] = stockDebutS[b,s+1] + commande[b,s];

s.t. capacite_production_max {b in BISCUITS, s in SEMAINES}:
    production[b,s] <= productionMax[b,s];

s.t. stock_init {b in BISCUITS}:
    stockDebutS[b,1] = 0;

s.t. stock_final {b in BISCUITS}:
    stockDebutS[b,n+1] = 0;

param M := 300; 

s.t. lien_stock_utilisation {b in BISCUITS, s in SEMAINES}:
    stockDebutS[b,s+1] <= M * utiliseEspaceStock[b,s];

s.t. capacite_stock_max {s in SEMAINES}:
    sum {b in BISCUITS} stockDebutS[b,s+1] <= poidsStockMax[s];

s.t. capacite_stock_min {b in BISCUITS, s in SEMAINES}:
    stockDebutS[b,s+1] >= poidsStockMin * utiliseEspaceStock[b,s];

s.t. nombre_espaces_stockage {s in SEMAINES}:
    sum {b in BISCUITS} utiliseEspaceStock[b,s] <= nbEspaceStock;