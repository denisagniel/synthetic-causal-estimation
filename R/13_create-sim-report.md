*G*<sub>*n*</sub> comparison simulation results
================

In these simulations, I consider eight different types of possible ways of creating synthetic estimators. When *θ*<sub>0</sub> is specified, it is the DR. Lunceford and Davidian is used throughout.

-   *None*: this artificially sets the bias to 0 uniformly for all estimators.
-   *Old*: this is the original way we have always done things, using raw differences: $\\hat{\\Delta} = \\hat{\\theta}\_i - \\hat{\\theta}\_0$.
-   *Shrunk*: this uses the raw differences but scales them by *n*: $\\hat{\\Delta} = n^{-1}(\\hat{\\theta}\_i - \\hat{\\theta}\_0)$.
-   *Boot*: this replaces $\\hat{\\theta}\_i$ with the mean of its bootstrapped versions $\\bar{\\theta}^\*\_i$
-   *All\_boot*: this replaces both quantities with their bootstrapped versions: $\\hat{\\Delta} = \\bar{\\theta}^\*\_i - \\bar{\\theta}^\*\_0$
-   *Gn*: this generates data using a random forest to predict the outcome and randomly bootstrapping the covariates (and their associated predicted *y*s) and also separately bootstrapping their errors. The bias is estimated by comparing to the regression-forest-based 'true' ATE.
-   *Null*: this is the so-called tree-based method we've been using, where we remove the true treatment effect and then bootstrap, and compare to a null ATE.
-   *Hybrid\_gn*: this uses the typical bootstrap, but the bias is estimated by comparing to the true ATE. It is a hybrid of the previous two methods.

Leacy and Stuart
================

![](13_create-sim-report_files/figure-markdown_github/unnamed-chunk-1-1.png)![](13_create-sim-report_files/figure-markdown_github/unnamed-chunk-1-2.png)

| j\_d                  |     n| d   | estimator   |        mse|        bias|        var|
|:----------------------|-----:|:----|:------------|----------:|-----------:|----------:|
| Outcome model correct |   500| ls  | null        |  0.0000653|   0.0036804|  0.0000519|
| Outcome model correct |   500| ls  | hybrid\_gn  |  0.0000653|   0.0036804|  0.0000519|
| Both correct          |   500| ls  | null        |  0.0000743|   0.0026890|  0.0000672|
| Both correct          |   500| ls  | hybrid\_gn  |  0.0000743|   0.0026890|  0.0000672|
| Both correct          |   500| ls  | ate\_regr   |  0.0001459|   0.0003180|  0.0001461|
| Outcome model correct |   500| ls  | ate\_regr   |  0.0001459|   0.0003180|  0.0001461|
| Both correct          |   500| ls  | shrunk      |  0.0001513|   0.0011188|  0.0001503|
| Both correct          |   500| ls  | none        |  0.0001513|   0.0011188|  0.0001503|
| Outcome model correct |   500| ls  | shrunk      |  0.0001625|   0.0020170|  0.0001588|
| Outcome model correct |   500| ls  | none        |  0.0001625|   0.0020170|  0.0001588|
| Outcome model correct |   500| ls  | all\_boot   |  0.0002228|   0.0016367|  0.0002206|
| Outcome model correct |   500| ls  | boot        |  0.0002236|   0.0016772|  0.0002213|
| Outcome model correct |   500| ls  | old         |  0.0002244|   0.0016861|  0.0002220|
| Outcome model correct |   500| ls  | gn          |  0.0002276|  -0.0023049|  0.0002227|
| Outcome model correct |   500| ls  | ate\_dr     |  0.0002951|  -0.0002303|  0.0002956|
| Both correct          |   500| ls  | boot        |  0.0003370|   0.0030215|  0.0003285|
| Both correct          |   500| ls  | old         |  0.0003409|   0.0030369|  0.0003324|
| Both correct          |   500| ls  | ate\_dr     |  0.0007516|   0.0008446|  0.0007524|
| Both correct          |   500| ls  | gn          |  0.0008138|  -0.0097653|  0.0007199|
| Both correct          |   500| ls  | all\_boot   |  0.0029911|   0.0019971|  0.0029931|
| PS model correct      |   500| ls  | gn          |  0.0171927|   0.0915372|  0.0088313|
| PS model correct      |   500| ls  | hybrid\_gn  |  0.0196327|   0.1230220|  0.0045073|
| PS model correct      |   500| ls  | null        |  0.0196327|   0.1230220|  0.0045073|
| Both models wrong     |   500| ls  | gn          |  0.0445456|   0.1916434|  0.0078341|
| Both models wrong     |   500| ls  | hybrid\_gn  |  0.0449076|   0.1954023|  0.0067390|
| Both models wrong     |   500| ls  | null        |  0.0449076|   0.1954023|  0.0067390|
| PS model correct      |   500| ls  | shrunk      |  0.0497142|   0.2083502|  0.0063170|
| PS model correct      |   500| ls  | none        |  0.0497148|   0.2083516|  0.0063171|
| Both models wrong     |   500| ls  | ate\_dr     |  0.0565212|   0.2134898|  0.0109653|
| Both correct          |   500| ls  | ate\_strat  |  0.0568946|   0.2114598|  0.0122038|
| PS model correct      |   500| ls  | ate\_strat  |  0.0568946|   0.2114598|  0.0122038|
| Both models wrong     |   500| ls  | old         |  0.0579467|   0.2236176|  0.0079578|
| Both models wrong     |   500| ls  | all\_boot   |  0.0579743|   0.2235891|  0.0079982|
| Both models wrong     |   500| ls  | boot        |  0.0580506|   0.2239310|  0.0079213|
| Both models wrong     |   500| ls  | ate\_regr   |  0.0583673|   0.2267714|  0.0069560|
| PS model correct      |   500| ls  | ate\_regr   |  0.0583673|   0.2267714|  0.0069560|
| Both models wrong     |   500| ls  | shrunk      |  0.0621722|   0.2352426|  0.0068468|
| Both models wrong     |   500| ls  | none        |  0.0621723|   0.2352428|  0.0068468|
| PS model correct      |   500| ls  | old         |  0.0662474|   0.1032067|  0.0557072|
| PS model correct      |   500| ls  | boot        |  0.0750432|   0.1036691|  0.0644248|
| PS model correct      |   500| ls  | all\_boot   |  0.1018085|   0.0816973|  0.0953247|
| Both models wrong     |   500| ls  | ate\_strat  |  0.1025978|   0.3033839|  0.0105772|
| Outcome model correct |   500| ls  | ate\_strat  |  0.1025978|   0.3033839|  0.0105772|
| Both models wrong     |   500| ls  | ate\_ipw\_2 |  0.1030700|   0.2862171|  0.0211922|
| Outcome model correct |   500| ls  | ate\_ipw\_2 |  0.1030700|   0.2862171|  0.0211922|
| PS model correct      |   500| ls  | ate\_dr     |  0.1149685|   0.0189954|  0.1148373|
| Both correct          |   500| ls  | ate\_ipw\_2 |  0.1405676|   0.0828691|  0.1339683|
| PS model correct      |   500| ls  | ate\_ipw\_2 |  0.1405676|   0.0828691|  0.1339683|
| Both correct          |  2000| ls  | null        |  0.0000124|   0.0016735|  0.0000096|
| Both correct          |  2000| ls  | hybrid\_gn  |  0.0000124|   0.0016735|  0.0000096|
| Outcome model correct |  2000| ls  | hybrid\_gn  |  0.0000141|   0.0019885|  0.0000102|
| Outcome model correct |  2000| ls  | null        |  0.0000141|   0.0019885|  0.0000102|
| Both correct          |  2000| ls  | ate\_regr   |  0.0000348|   0.0001359|  0.0000348|
| Outcome model correct |  2000| ls  | ate\_regr   |  0.0000348|   0.0001359|  0.0000348|
| Both correct          |  2000| ls  | shrunk      |  0.0000363|   0.0008352|  0.0000357|
| Both correct          |  2000| ls  | none        |  0.0000363|   0.0008352|  0.0000357|
| Outcome model correct |  2000| ls  | shrunk      |  0.0000436|   0.0017279|  0.0000407|
| Outcome model correct |  2000| ls  | none        |  0.0000436|   0.0017279|  0.0000407|
| Outcome model correct |  2000| ls  | gn          |  0.0000513|  -0.0008371|  0.0000507|
| Outcome model correct |  2000| ls  | all\_boot   |  0.0000552|   0.0009150|  0.0000545|
| Outcome model correct |  2000| ls  | old         |  0.0000552|   0.0009092|  0.0000545|
| Outcome model correct |  2000| ls  | boot        |  0.0000554|   0.0009265|  0.0000547|
| Outcome model correct |  2000| ls  | ate\_dr     |  0.0000630|   0.0000888|  0.0000631|
| Both correct          |  2000| ls  | old         |  0.0002763|   0.0019782|  0.0002729|
| Both correct          |  2000| ls  | all\_boot   |  0.0003090|   0.0019989|  0.0003056|
| Both correct          |  2000| ls  | boot        |  0.0003205|   0.0019968|  0.0003172|
| Both correct          |  2000| ls  | ate\_dr     |  0.0003552|   0.0006286|  0.0003555|
| Both correct          |  2000| ls  | gn          |  0.0008300|  -0.0116959|  0.0006946|
| PS model correct      |  2000| ls  | hybrid\_gn  |  0.0060374|   0.0640059|  0.0019445|
| PS model correct      |  2000| ls  | null        |  0.0060374|   0.0640059|  0.0019445|
| PS model correct      |  2000| ls  | gn          |  0.0067104|   0.0298332|  0.0058320|
| PS model correct      |  2000| ls  | shrunk      |  0.0378479|   0.1890340|  0.0021183|
| PS model correct      |  2000| ls  | none        |  0.0378480|   0.1890343|  0.0021183|
| Both models wrong     |  2000| ls  | hybrid\_gn  |  0.0437094|   0.2035844|  0.0022674|
| Both models wrong     |  2000| ls  | null        |  0.0437094|   0.2035844|  0.0022674|
| Both models wrong     |  2000| ls  | gn          |  0.0437300|   0.2032009|  0.0024443|
| Both models wrong     |  2000| ls  | ate\_dr     |  0.0471849|   0.2105512|  0.0028588|
| Both correct          |  2000| ls  | ate\_strat  |  0.0486622|   0.2127534|  0.0034050|
| PS model correct      |  2000| ls  | ate\_strat  |  0.0486622|   0.2127534|  0.0034050|
| Both models wrong     |  2000| ls  | old         |  0.0497730|   0.2177915|  0.0023446|
| Both models wrong     |  2000| ls  | all\_boot   |  0.0498195|   0.2179068|  0.0023408|
| Both models wrong     |  2000| ls  | boot        |  0.0498819|   0.2179959|  0.0023644|
| Both models wrong     |  2000| ls  | ate\_regr   |  0.0518647|   0.2236967|  0.0018282|
| PS model correct      |  2000| ls  | ate\_regr   |  0.0518647|   0.2236967|  0.0018282|
| Both models wrong     |  2000| ls  | shrunk      |  0.0553825|   0.2313199|  0.0018773|
| Both models wrong     |  2000| ls  | none        |  0.0553825|   0.2313200|  0.0018773|
| PS model correct      |  2000| ls  | old         |  0.0845917|   0.0388941|  0.0832454|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 |  0.0849918|   0.2831554|  0.0048244|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 |  0.0849918|   0.2831554|  0.0048244|
| PS model correct      |  2000| ls  | all\_boot   |  0.0925426|   0.0368206|  0.0913696|
| Both models wrong     |  2000| ls  | ate\_strat  |  0.0955744|   0.3050450|  0.0025270|
| Outcome model correct |  2000| ls  | ate\_strat  |  0.0955744|   0.3050450|  0.0025270|
| PS model correct      |  2000| ls  | boot        |  0.0979900|   0.0370855|  0.0968083|
| Both correct          |  2000| ls  | ate\_ipw\_2 |  0.1167775|   0.0254095|  0.1163645|
| PS model correct      |  2000| ls  | ate\_ipw\_2 |  0.1167775|   0.0254095|  0.1163645|
| PS model correct      |  2000| ls  | ate\_dr     |  0.2616693|  -0.0024377|  0.2621877|

### Comparing the coefficients

![](13_create-sim-report_files/figure-markdown_github/unnamed-chunk-2-1.png)![](13_create-sim-report_files/figure-markdown_github/unnamed-chunk-2-2.png)

| j\_d                  |     n| d   | est         | type       |       bhat|       bvar|      b\_se|
|:----------------------|-----:|:----|:------------|:-----------|----------:|----------:|----------:|
| Both correct          |   500| ls  | ate\_dr     | all\_boot  |  0.1695679|  0.0255845|  0.1599517|
| Both correct          |  2000| ls  | ate\_dr     | all\_boot  |  0.2444078|  0.0540004|  0.2323799|
| Both correct          |   500| ls  | ate\_ipw\_2 | all\_boot  |  0.0070507|  0.0004883|  0.0220977|
| Both correct          |  2000| ls  | ate\_ipw\_2 | all\_boot  |  0.0030940|  0.0000991|  0.0099564|
| Both correct          |   500| ls  | ate\_regr   | all\_boot  |  0.7976071|  0.0266153|  0.1631419|
| Both correct          |  2000| ls  | ate\_regr   | all\_boot  |  0.7361347|  0.0519427|  0.2279093|
| Both correct          |   500| ls  | ate\_strat  | all\_boot  |  0.0257743|  0.0058952|  0.0767801|
| Both correct          |  2000| ls  | ate\_strat  | all\_boot  |  0.0163636|  0.0031161|  0.0558222|
| Both correct          |   500| ls  | ate\_dr     | boot       |  0.1567995|  0.0237924|  0.1542479|
| Both correct          |  2000| ls  | ate\_dr     | boot       |  0.2403182|  0.0523571|  0.2288168|
| Both correct          |   500| ls  | ate\_ipw\_2 | boot       |  0.0050398|  0.0001645|  0.0128238|
| Both correct          |  2000| ls  | ate\_ipw\_2 | boot       |  0.0031200|  0.0001130|  0.0106295|
| Both correct          |   500| ls  | ate\_regr   | boot       |  0.8200073|  0.0231806|  0.1522519|
| Both correct          |  2000| ls  | ate\_regr   | boot       |  0.7403309|  0.0504060|  0.2245128|
| Both correct          |   500| ls  | ate\_strat  | boot       |  0.0181535|  0.0023493|  0.0484696|
| Both correct          |  2000| ls  | ate\_strat  | boot       |  0.0162309|  0.0030698|  0.0554059|
| Both correct          |   500| ls  | ate\_dr     | gn         |  0.2763965|  0.1371385|  0.3703221|
| Both correct          |  2000| ls  | ate\_dr     | gn         |  0.3783911|  0.2077705|  0.4558185|
| Both correct          |   500| ls  | ate\_ipw\_2 | gn         |  0.0292696|  0.0051214|  0.0715637|
| Both correct          |  2000| ls  | ate\_ipw\_2 | gn         |  0.0673423|  0.0199953|  0.1414049|
| Both correct          |   500| ls  | ate\_regr   | gn         |  0.6932879|  0.1341975|  0.3663298|
| Both correct          |  2000| ls  | ate\_regr   | gn         |  0.5542666|  0.2019258|  0.4493615|
| Both correct          |   500| ls  | ate\_strat  | gn         |  0.0010460|  0.0002063|  0.0143621|
| Both correct          |  2000| ls  | ate\_strat  | gn         |  0.0000000|  0.0000000|  0.0000000|
| Both correct          |   500| ls  | ate\_dr     | hybrid\_gn |  0.0804622|  0.0196124|  0.1400444|
| Both correct          |  2000| ls  | ate\_dr     | hybrid\_gn |  0.1094567|  0.0356789|  0.1888886|
| Both correct          |   500| ls  | ate\_ipw\_2 | hybrid\_gn |  0.0032178|  0.0000456|  0.0067533|
| Both correct          |  2000| ls  | ate\_ipw\_2 | hybrid\_gn |  0.0027288|  0.0000341|  0.0058427|
| Both correct          |   500| ls  | ate\_regr   | hybrid\_gn |  0.9039263|  0.0193596|  0.1391386|
| Both correct          |  2000| ls  | ate\_regr   | hybrid\_gn |  0.8785574|  0.0348273|  0.1866207|
| Both correct          |   500| ls  | ate\_strat  | hybrid\_gn |  0.0123937|  0.0003893|  0.0197310|
| Both correct          |  2000| ls  | ate\_strat  | hybrid\_gn |  0.0092571|  0.0002124|  0.0145751|
| Both correct          |   500| ls  | ate\_dr     | none       |  0.0625935|  0.0058792|  0.0766757|
| Both correct          |  2000| ls  | ate\_dr     | none       |  0.0678315|  0.0060364|  0.0776941|
| Both correct          |   500| ls  | ate\_ipw\_2 | none       |  0.0022085|  0.0000168|  0.0040951|
| Both correct          |  2000| ls  | ate\_ipw\_2 | none       |  0.0022938|  0.0000152|  0.0038983|
| Both correct          |   500| ls  | ate\_regr   | none       |  0.9326339|  0.0060201|  0.0775893|
| Both correct          |  2000| ls  | ate\_regr   | none       |  0.9272898|  0.0060818|  0.0779862|
| Both correct          |   500| ls  | ate\_strat  | none       |  0.0025640|  0.0000182|  0.0042684|
| Both correct          |  2000| ls  | ate\_strat  | none       |  0.0025848|  0.0000173|  0.0041583|
| Both correct          |   500| ls  | ate\_dr     | null       |  0.0804622|  0.0196124|  0.1400444|
| Both correct          |  2000| ls  | ate\_dr     | null       |  0.1094567|  0.0356789|  0.1888886|
| Both correct          |   500| ls  | ate\_ipw\_2 | null       |  0.0032178|  0.0000456|  0.0067533|
| Both correct          |  2000| ls  | ate\_ipw\_2 | null       |  0.0027288|  0.0000341|  0.0058427|
| Both correct          |   500| ls  | ate\_regr   | null       |  0.9039263|  0.0193596|  0.1391386|
| Both correct          |  2000| ls  | ate\_regr   | null       |  0.8785574|  0.0348273|  0.1866207|
| Both correct          |   500| ls  | ate\_strat  | null       |  0.0123937|  0.0003893|  0.0197310|
| Both correct          |  2000| ls  | ate\_strat  | null       |  0.0092571|  0.0002124|  0.0145751|
| Both correct          |   500| ls  | ate\_dr     | old        |  0.1496288|  0.0236796|  0.1538817|
| Both correct          |  2000| ls  | ate\_dr     | old        |  0.2409891|  0.0530792|  0.2303892|
| Both correct          |   500| ls  | ate\_ipw\_2 | old        |  0.0064155|  0.0003472|  0.0186340|
| Both correct          |  2000| ls  | ate\_ipw\_2 | old        |  0.0032779|  0.0001147|  0.0107115|
| Both correct          |   500| ls  | ate\_regr   | old        |  0.8280573|  0.0224788|  0.1499295|
| Both correct          |  2000| ls  | ate\_regr   | old        |  0.7398562|  0.0507653|  0.2253115|
| Both correct          |   500| ls  | ate\_strat  | old        |  0.0158984|  0.0015790|  0.0397365|
| Both correct          |  2000| ls  | ate\_strat  | old        |  0.0158769|  0.0026272|  0.0512563|
| Both correct          |   500| ls  | ate\_dr     | shrunk     |  0.0625942|  0.0058792|  0.0766760|
| Both correct          |  2000| ls  | ate\_dr     | shrunk     |  0.0678317|  0.0060364|  0.0776941|
| Both correct          |   500| ls  | ate\_ipw\_2 | shrunk     |  0.0022085|  0.0000168|  0.0040951|
| Both correct          |  2000| ls  | ate\_ipw\_2 | shrunk     |  0.0022938|  0.0000152|  0.0038983|
| Both correct          |   500| ls  | ate\_regr   | shrunk     |  0.9326333|  0.0060201|  0.0775895|
| Both correct          |  2000| ls  | ate\_regr   | shrunk     |  0.9272897|  0.0060819|  0.0779862|
| Both correct          |   500| ls  | ate\_strat  | shrunk     |  0.0025640|  0.0000182|  0.0042684|
| Both correct          |  2000| ls  | ate\_strat  | shrunk     |  0.0025848|  0.0000173|  0.0041583|
| Both models wrong     |   500| ls  | ate\_dr     | all\_boot  |  0.3995140|  0.0600453|  0.2450415|
| Both models wrong     |  2000| ls  | ate\_dr     | all\_boot  |  0.4363188|  0.0678578|  0.2604953|
| Both models wrong     |   500| ls  | ate\_ipw\_2 | all\_boot  |  0.0417814|  0.0096461|  0.0982148|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 | all\_boot  |  0.0105658|  0.0018217|  0.0426812|
| Both models wrong     |   500| ls  | ate\_regr   | all\_boot  |  0.4764290|  0.0532952|  0.2308575|
| Both models wrong     |  2000| ls  | ate\_regr   | all\_boot  |  0.5031789|  0.0490978|  0.2215803|
| Both models wrong     |   500| ls  | ate\_strat  | all\_boot  |  0.0822756|  0.0184311|  0.1357613|
| Both models wrong     |  2000| ls  | ate\_strat  | all\_boot  |  0.0499365|  0.0117674|  0.1084775|
| Both models wrong     |   500| ls  | ate\_dr     | boot       |  0.3961491|  0.0599365|  0.2448193|
| Both models wrong     |  2000| ls  | ate\_dr     | boot       |  0.4354523|  0.0690422|  0.2627588|
| Both models wrong     |   500| ls  | ate\_ipw\_2 | boot       |  0.0418640|  0.0092498|  0.0961757|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 | boot       |  0.0112799|  0.0018303|  0.0427824|
| Both models wrong     |   500| ls  | ate\_regr   | boot       |  0.4794702|  0.0534820|  0.2312617|
| Both models wrong     |  2000| ls  | ate\_regr   | boot       |  0.5018324|  0.0506377|  0.2250282|
| Both models wrong     |   500| ls  | ate\_strat  | boot       |  0.0825167|  0.0179966|  0.1341512|
| Both models wrong     |  2000| ls  | ate\_strat  | boot       |  0.0514354|  0.0122516|  0.1106872|
| Both models wrong     |   500| ls  | ate\_dr     | gn         |  0.4598088|  0.2185495|  0.4674928|
| Both models wrong     |  2000| ls  | ate\_dr     | gn         |  0.6306907|  0.2232589|  0.4725028|
| Both models wrong     |   500| ls  | ate\_ipw\_2 | gn         |  0.0713318|  0.0529904|  0.2301964|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 | gn         |  0.0124034|  0.0111196|  0.1054494|
| Both models wrong     |   500| ls  | ate\_regr   | gn         |  0.4574692|  0.2216989|  0.4708491|
| Both models wrong     |  2000| ls  | ate\_regr   | gn         |  0.3569059|  0.2210108|  0.4701178|
| Both models wrong     |   500| ls  | ate\_strat  | gn         |  0.0113901|  0.0080715|  0.0898415|
| Both models wrong     |  2000| ls  | ate\_strat  | gn         |  0.0000000|  0.0000000|  0.0000000|
| Both models wrong     |   500| ls  | ate\_dr     | hybrid\_gn |  0.4614313|  0.2031487|  0.4507202|
| Both models wrong     |  2000| ls  | ate\_dr     | hybrid\_gn |  0.6298884|  0.2192103|  0.4681990|
| Both models wrong     |   500| ls  | ate\_ipw\_2 | hybrid\_gn |  0.0528498|  0.0341895|  0.1849040|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 | hybrid\_gn |  0.0098193|  0.0084199|  0.0917603|
| Both models wrong     |   500| ls  | ate\_regr   | hybrid\_gn |  0.4720133|  0.2060561|  0.4539341|
| Both models wrong     |  2000| ls  | ate\_regr   | hybrid\_gn |  0.3602923|  0.2168791|  0.4657028|
| Both models wrong     |   500| ls  | ate\_strat  | hybrid\_gn |  0.0137056|  0.0084492|  0.0919195|
| Both models wrong     |  2000| ls  | ate\_strat  | hybrid\_gn |  0.0000000|  0.0000000|  0.0000000|
| Both models wrong     |   500| ls  | ate\_dr     | none       |  0.2561976|  0.0460657|  0.2146291|
| Both models wrong     |  2000| ls  | ate\_dr     | none       |  0.2223630|  0.0359462|  0.1895948|
| Both models wrong     |   500| ls  | ate\_ipw\_2 | none       |  0.0439757|  0.0087442|  0.0935104|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 | none       |  0.0167344|  0.0027902|  0.0528225|
| Both models wrong     |   500| ls  | ate\_regr   | none       |  0.6072639|  0.0484168|  0.2200381|
| Both models wrong     |  2000| ls  | ate\_regr   | none       |  0.6626197|  0.0306048|  0.1749423|
| Both models wrong     |   500| ls  | ate\_strat  | none       |  0.0925628|  0.0085466|  0.0924477|
| Both models wrong     |  2000| ls  | ate\_strat  | none       |  0.0982829|  0.0088598|  0.0941265|
| Both models wrong     |   500| ls  | ate\_dr     | null       |  0.4614313|  0.2031487|  0.4507202|
| Both models wrong     |  2000| ls  | ate\_dr     | null       |  0.6298884|  0.2192103|  0.4681990|
| Both models wrong     |   500| ls  | ate\_ipw\_2 | null       |  0.0528498|  0.0341895|  0.1849040|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 | null       |  0.0098193|  0.0084199|  0.0917603|
| Both models wrong     |   500| ls  | ate\_regr   | null       |  0.4720133|  0.2060561|  0.4539341|
| Both models wrong     |  2000| ls  | ate\_regr   | null       |  0.3602923|  0.2168791|  0.4657028|
| Both models wrong     |   500| ls  | ate\_strat  | null       |  0.0137056|  0.0084492|  0.0919195|
| Both models wrong     |  2000| ls  | ate\_strat  | null       |  0.0000000|  0.0000000|  0.0000000|
| Both models wrong     |   500| ls  | ate\_dr     | old        |  0.3954713|  0.0607616|  0.2464987|
| Both models wrong     |  2000| ls  | ate\_dr     | old        |  0.4381335|  0.0682521|  0.2612509|
| Both models wrong     |   500| ls  | ate\_ipw\_2 | old        |  0.0434785|  0.0102938|  0.1014585|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 | old        |  0.0107042|  0.0017830|  0.0422250|
| Both models wrong     |   500| ls  | ate\_regr   | old        |  0.4784135|  0.0531084|  0.2304527|
| Both models wrong     |  2000| ls  | ate\_regr   | old        |  0.5018880|  0.0498551|  0.2232825|
| Both models wrong     |   500| ls  | ate\_strat  | old        |  0.0826367|  0.0176443|  0.1328319|
| Both models wrong     |  2000| ls  | ate\_strat  | old        |  0.0492744|  0.0116567|  0.1079664|
| Both models wrong     |   500| ls  | ate\_dr     | shrunk     |  0.2561992|  0.0460657|  0.2146292|
| Both models wrong     |  2000| ls  | ate\_dr     | shrunk     |  0.2223633|  0.0359462|  0.1895949|
| Both models wrong     |   500| ls  | ate\_ipw\_2 | shrunk     |  0.0439754|  0.0087441|  0.0935098|
| Both models wrong     |  2000| ls  | ate\_ipw\_2 | shrunk     |  0.0167343|  0.0027902|  0.0528224|
| Both models wrong     |   500| ls  | ate\_regr   | shrunk     |  0.6072632|  0.0484167|  0.2200379|
| Both models wrong     |  2000| ls  | ate\_regr   | shrunk     |  0.6626198|  0.0306048|  0.1749424|
| Both models wrong     |   500| ls  | ate\_strat  | shrunk     |  0.0925622|  0.0085465|  0.0924470|
| Both models wrong     |  2000| ls  | ate\_strat  | shrunk     |  0.0982826|  0.0088598|  0.0941263|
| Outcome model correct |   500| ls  | ate\_dr     | all\_boot  |  0.2949420|  0.0502841|  0.2242412|
| Outcome model correct |  2000| ls  | ate\_dr     | all\_boot  |  0.2475785|  0.0597321|  0.2444016|
| Outcome model correct |   500| ls  | ate\_ipw\_2 | all\_boot  |  0.0031531|  0.0000577|  0.0075991|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 | all\_boot  |  0.0017582|  0.0000193|  0.0043963|
| Outcome model correct |   500| ls  | ate\_regr   | all\_boot  |  0.6956148|  0.0484106|  0.2200242|
| Outcome model correct |  2000| ls  | ate\_regr   | all\_boot  |  0.7467026|  0.0580427|  0.2409204|
| Outcome model correct |   500| ls  | ate\_strat  | all\_boot  |  0.0062901|  0.0001870|  0.0136766|
| Outcome model correct |  2000| ls  | ate\_strat  | all\_boot  |  0.0039607|  0.0000533|  0.0073014|
| Outcome model correct |   500| ls  | ate\_dr     | boot       |  0.2936121|  0.0502167|  0.2240908|
| Outcome model correct |  2000| ls  | ate\_dr     | boot       |  0.2471648|  0.0611788|  0.2473435|
| Outcome model correct |   500| ls  | ate\_ipw\_2 | boot       |  0.0032969|  0.0000591|  0.0076902|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 | boot       |  0.0017621|  0.0000193|  0.0043925|
| Outcome model correct |   500| ls  | ate\_regr   | boot       |  0.6968467|  0.0483479|  0.2198816|
| Outcome model correct |  2000| ls  | ate\_regr   | boot       |  0.7470569|  0.0594480|  0.2438196|
| Outcome model correct |   500| ls  | ate\_strat  | boot       |  0.0062442|  0.0001864|  0.0136516|
| Outcome model correct |  2000| ls  | ate\_strat  | boot       |  0.0040162|  0.0000555|  0.0074522|
| Outcome model correct |   500| ls  | ate\_dr     | gn         |  0.5373635|  0.2129527|  0.4614680|
| Outcome model correct |  2000| ls  | ate\_dr     | gn         |  0.6477503|  0.2229848|  0.4722126|
| Outcome model correct |   500| ls  | ate\_ipw\_2 | gn         |  0.0046300|  0.0010485|  0.0323811|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 | gn         |  0.0000000|  0.0000000|  0.0000000|
| Outcome model correct |   500| ls  | ate\_regr   | gn         |  0.4580065|  0.2110178|  0.4593667|
| Outcome model correct |  2000| ls  | ate\_regr   | gn         |  0.3522497|  0.2229848|  0.4722126|
| Outcome model correct |   500| ls  | ate\_strat  | gn         |  0.0000000|  0.0000000|  0.0000000|
| Outcome model correct |  2000| ls  | ate\_strat  | gn         |  0.0000000|  0.0000000|  0.0000000|
| Outcome model correct |   500| ls  | ate\_dr     | hybrid\_gn |  0.1838944|  0.0633574|  0.2517089|
| Outcome model correct |  2000| ls  | ate\_dr     | hybrid\_gn |  0.1385061|  0.0555449|  0.2356796|
| Outcome model correct |   500| ls  | ate\_ipw\_2 | hybrid\_gn |  0.0047130|  0.0001293|  0.0113700|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 | hybrid\_gn |  0.0016846|  0.0000184|  0.0042837|
| Outcome model correct |   500| ls  | ate\_regr   | hybrid\_gn |  0.8020246|  0.0626518|  0.2503034|
| Outcome model correct |  2000| ls  | ate\_regr   | hybrid\_gn |  0.8540243|  0.0548296|  0.2341572|
| Outcome model correct |   500| ls  | ate\_strat  | hybrid\_gn |  0.0093680|  0.0003035|  0.0174208|
| Outcome model correct |  2000| ls  | ate\_strat  | hybrid\_gn |  0.0057850|  0.0000955|  0.0097737|
| Outcome model correct |   500| ls  | ate\_dr     | none       |  0.1553515|  0.0255136|  0.1597297|
| Outcome model correct |  2000| ls  | ate\_dr     | none       |  0.0843213|  0.0097648|  0.0988169|
| Outcome model correct |   500| ls  | ate\_ipw\_2 | none       |  0.0032839|  0.0000412|  0.0064188|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 | none       |  0.0025602|  0.0000227|  0.0047599|
| Outcome model correct |   500| ls  | ate\_regr   | none       |  0.8389582|  0.0258343|  0.1607304|
| Outcome model correct |  2000| ls  | ate\_regr   | none       |  0.9103068|  0.0099639|  0.0998195|
| Outcome model correct |   500| ls  | ate\_strat  | none       |  0.0024063|  0.0000208|  0.0045570|
| Outcome model correct |  2000| ls  | ate\_strat  | none       |  0.0028117|  0.0000237|  0.0048669|
| Outcome model correct |   500| ls  | ate\_dr     | null       |  0.1838944|  0.0633574|  0.2517089|
| Outcome model correct |  2000| ls  | ate\_dr     | null       |  0.1385061|  0.0555449|  0.2356796|
| Outcome model correct |   500| ls  | ate\_ipw\_2 | null       |  0.0047130|  0.0001293|  0.0113700|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 | null       |  0.0016846|  0.0000184|  0.0042837|
| Outcome model correct |   500| ls  | ate\_regr   | null       |  0.8020246|  0.0626518|  0.2503034|
| Outcome model correct |  2000| ls  | ate\_regr   | null       |  0.8540243|  0.0548296|  0.2341572|
| Outcome model correct |   500| ls  | ate\_strat  | null       |  0.0093680|  0.0003035|  0.0174208|
| Outcome model correct |  2000| ls  | ate\_strat  | null       |  0.0057850|  0.0000955|  0.0097737|
| Outcome model correct |   500| ls  | ate\_dr     | old        |  0.2935161|  0.0498980|  0.2233787|
| Outcome model correct |  2000| ls  | ate\_dr     | old        |  0.2489386|  0.0602520|  0.2454629|
| Outcome model correct |   500| ls  | ate\_ipw\_2 | old        |  0.0034541|  0.0000667|  0.0081687|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 | old        |  0.0017994|  0.0000203|  0.0045061|
| Outcome model correct |   500| ls  | ate\_regr   | old        |  0.6970000|  0.0480412|  0.2191831|
| Outcome model correct |  2000| ls  | ate\_regr   | old        |  0.7453318|  0.0585417|  0.2419540|
| Outcome model correct |   500| ls  | ate\_strat  | old        |  0.0060297|  0.0001776|  0.0133251|
| Outcome model correct |  2000| ls  | ate\_strat  | old        |  0.0039302|  0.0000534|  0.0073086|
| Outcome model correct |   500| ls  | ate\_dr     | shrunk     |  0.1553529|  0.0255136|  0.1597298|
| Outcome model correct |  2000| ls  | ate\_dr     | shrunk     |  0.0843214|  0.0097648|  0.0988170|
| Outcome model correct |   500| ls  | ate\_ipw\_2 | shrunk     |  0.0032838|  0.0000412|  0.0064186|
| Outcome model correct |  2000| ls  | ate\_ipw\_2 | shrunk     |  0.0025602|  0.0000227|  0.0047598|
| Outcome model correct |   500| ls  | ate\_regr   | shrunk     |  0.8389571|  0.0258343|  0.1607305|
| Outcome model correct |  2000| ls  | ate\_regr   | shrunk     |  0.9103067|  0.0099639|  0.0998195|
| Outcome model correct |   500| ls  | ate\_strat  | shrunk     |  0.0024062|  0.0000208|  0.0045568|
| Outcome model correct |  2000| ls  | ate\_strat  | shrunk     |  0.0028116|  0.0000237|  0.0048668|
| PS model correct      |   500| ls  | ate\_dr     | all\_boot  |  0.3389617|  0.0705279|  0.2655709|
| PS model correct      |  2000| ls  | ate\_dr     | all\_boot  |  0.7623701|  0.0592896|  0.2434946|
| PS model correct      |   500| ls  | ate\_ipw\_2 | all\_boot  |  0.1655272|  0.0660271|  0.2569574|
| PS model correct      |  2000| ls  | ate\_ipw\_2 | all\_boot  |  0.0755315|  0.0306964|  0.1752039|
| PS model correct      |   500| ls  | ate\_regr   | all\_boot  |  0.3517316|  0.0719562|  0.2682465|
| PS model correct      |  2000| ls  | ate\_regr   | all\_boot  |  0.1030241|  0.0161436|  0.1270575|
| PS model correct      |   500| ls  | ate\_strat  | all\_boot  |  0.1437796|  0.0384061|  0.1959749|
| PS model correct      |  2000| ls  | ate\_strat  | all\_boot  |  0.0590743|  0.0136915|  0.1170105|
| PS model correct      |   500| ls  | ate\_dr     | boot       |  0.3078676|  0.0629441|  0.2508865|
| PS model correct      |  2000| ls  | ate\_dr     | boot       |  0.7562039|  0.0589148|  0.2427237|
| PS model correct      |   500| ls  | ate\_ipw\_2 | boot       |  0.1353425|  0.0449127|  0.2119262|
| PS model correct      |  2000| ls  | ate\_ipw\_2 | boot       |  0.0746259|  0.0299779|  0.1731413|
| PS model correct      |   500| ls  | ate\_regr   | boot       |  0.4043717|  0.0689239|  0.2625336|
| PS model correct      |  2000| ls  | ate\_regr   | boot       |  0.1082675|  0.0166021|  0.1288491|
| PS model correct      |   500| ls  | ate\_strat  | boot       |  0.1524182|  0.0404143|  0.2010331|
| PS model correct      |  2000| ls  | ate\_strat  | boot       |  0.0609027|  0.0145005|  0.1204178|
| PS model correct      |   500| ls  | ate\_dr     | gn         |  0.4616448|  0.1646759|  0.4058027|
| PS model correct      |  2000| ls  | ate\_dr     | gn         |  0.8208489|  0.1149055|  0.3389771|
| PS model correct      |   500| ls  | ate\_ipw\_2 | gn         |  0.1584645|  0.0649920|  0.2549354|
| PS model correct      |  2000| ls  | ate\_ipw\_2 | gn         |  0.1343922|  0.0879804|  0.2966149|
| PS model correct      |   500| ls  | ate\_regr   | gn         |  0.2657857|  0.1172771|  0.3424574|
| PS model correct      |  2000| ls  | ate\_regr   | gn         |  0.0265094|  0.0162995|  0.1276697|
| PS model correct      |   500| ls  | ate\_strat  | gn         |  0.1141049|  0.0541138|  0.2326237|
| PS model correct      |  2000| ls  | ate\_strat  | gn         |  0.0182495|  0.0087601|  0.0935954|
| PS model correct      |   500| ls  | ate\_dr     | hybrid\_gn |  0.4069152|  0.1318035|  0.3630475|
| PS model correct      |  2000| ls  | ate\_dr     | hybrid\_gn |  0.7835226|  0.0850175|  0.2915776|
| PS model correct      |   500| ls  | ate\_ipw\_2 | hybrid\_gn |  0.1114304|  0.0327077|  0.1808528|
| PS model correct      |  2000| ls  | ate\_ipw\_2 | hybrid\_gn |  0.0705703|  0.0308443|  0.1756255|
| PS model correct      |   500| ls  | ate\_regr   | hybrid\_gn |  0.3286744|  0.1023254|  0.3198834|
| PS model correct      |  2000| ls  | ate\_regr   | hybrid\_gn |  0.0773657|  0.0260929|  0.1615329|
| PS model correct      |   500| ls  | ate\_strat  | hybrid\_gn |  0.1529801|  0.0556887|  0.2359846|
| PS model correct      |  2000| ls  | ate\_strat  | hybrid\_gn |  0.0685413|  0.0307271|  0.1752914|
| PS model correct      |   500| ls  | ate\_dr     | none       |  0.1175140|  0.0165525|  0.1286567|
| PS model correct      |  2000| ls  | ate\_dr     | none       |  0.1963232|  0.0235734|  0.1535365|
| PS model correct      |   500| ls  | ate\_ipw\_2 | none       |  0.0391034|  0.0030069|  0.0548348|
| PS model correct      |  2000| ls  | ate\_ipw\_2 | none       |  0.0213406|  0.0025115|  0.0501145|
| PS model correct      |   500| ls  | ate\_regr   | none       |  0.6949128|  0.0174020|  0.1319166|
| PS model correct      |  2000| ls  | ate\_regr   | none       |  0.6367426|  0.0161610|  0.1271259|
| PS model correct      |   500| ls  | ate\_strat  | none       |  0.1484698|  0.0055321|  0.0743779|
| PS model correct      |  2000| ls  | ate\_strat  | none       |  0.1455936|  0.0058129|  0.0762421|
| PS model correct      |   500| ls  | ate\_dr     | null       |  0.4069152|  0.1318035|  0.3630475|
| PS model correct      |  2000| ls  | ate\_dr     | null       |  0.7835226|  0.0850175|  0.2915776|
| PS model correct      |   500| ls  | ate\_ipw\_2 | null       |  0.1114304|  0.0327077|  0.1808528|
| PS model correct      |  2000| ls  | ate\_ipw\_2 | null       |  0.0705703|  0.0308443|  0.1756255|
| PS model correct      |   500| ls  | ate\_regr   | null       |  0.3286744|  0.1023254|  0.3198834|
| PS model correct      |  2000| ls  | ate\_regr   | null       |  0.0773657|  0.0260929|  0.1615329|
| PS model correct      |   500| ls  | ate\_strat  | null       |  0.1529801|  0.0556887|  0.2359846|
| PS model correct      |  2000| ls  | ate\_strat  | null       |  0.0685413|  0.0307271|  0.1752914|
| PS model correct      |   500| ls  | ate\_dr     | old        |  0.2911024|  0.0681420|  0.2610402|
| PS model correct      |  2000| ls  | ate\_dr     | old        |  0.7461405|  0.0698046|  0.2642056|
| PS model correct      |   500| ls  | ate\_ipw\_2 | old        |  0.1406659|  0.0473470|  0.2175936|
| PS model correct      |  2000| ls  | ate\_ipw\_2 | old        |  0.0830356|  0.0321703|  0.1793609|
| PS model correct      |   500| ls  | ate\_regr   | old        |  0.3923628|  0.0689841|  0.2626482|
| PS model correct      |  2000| ls  | ate\_regr   | old        |  0.1047108|  0.0166565|  0.1290599|
| PS model correct      |   500| ls  | ate\_strat  | old        |  0.1758689|  0.0474505|  0.2178315|
| PS model correct      |  2000| ls  | ate\_strat  | old        |  0.0661131|  0.0168388|  0.1297642|
| PS model correct      |   500| ls  | ate\_dr     | shrunk     |  0.1175161|  0.0165529|  0.1286580|
| PS model correct      |  2000| ls  | ate\_dr     | shrunk     |  0.1963245|  0.0235735|  0.1535368|
| PS model correct      |   500| ls  | ate\_ipw\_2 | shrunk     |  0.0391043|  0.0030069|  0.0548349|
| PS model correct      |  2000| ls  | ate\_ipw\_2 | shrunk     |  0.0213406|  0.0025115|  0.0501146|
| PS model correct      |   500| ls  | ate\_regr   | shrunk     |  0.6949088|  0.0174016|  0.1319151|
| PS model correct      |  2000| ls  | ate\_regr   | shrunk     |  0.6367417|  0.0161610|  0.1271260|
| PS model correct      |   500| ls  | ate\_strat  | shrunk     |  0.1484708|  0.0055321|  0.0743780|
| PS model correct      |  2000| ls  | ate\_strat  | shrunk     |  0.1455932|  0.0058129|  0.0762422|
