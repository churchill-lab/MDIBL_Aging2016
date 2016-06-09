## ----load_DOQTL,message=FALSE, results='hide', cache=TRUE----------------
source("http://bioconductor.org/biocLite.R")  
biocLite("DOQTL")

## ----library,message=FALSE, results='hide'-------------------------------
library(DOQTL)

## ----load_data,message=FALSE,results='hide'------------------------------
setwd("/Users/dgatti/Documents/DOQTL_demo")
load("DOQTL_demo.Rdata")

## ------------------------------------------------------------------------
ls()

## ------------------------------------------------------------------------
head(pheno)

## ------------------------------------------------------------------------
dim(probs)

## ----geno_plot,fig.width=8, fig.height=6---------------------------------
image(1:500, 1:ncol(probs), t(probs[1,8:1,1:500]), breaks = 0:100/100,
      col = grey(99:0/100), axes = F, xlab = "Markers", ylab = "Founders",
      main = "Founder Allele Contributions for Sample 1")
abline(h = 0:8 + 0.5, col = "grey70")
usr = par("usr")
rect(usr[1], usr[3], usr[2], usr[4])
axis(side = 1, at = 0:5 * 100, labels = 0:5 * 100)
axis(side = 2, at = 1:8, labels = LETTERS[8:1], las = 1, tick = F)

## ----snps----------------------------------------------------------------
load(url("ftp://ftp.jax.org/MUGA/muga_snps.Rdata"))

## ----kinship,message=FALSE,results='hide'--------------------------------
K = kinship.probs(probs, snps = muga_snps, bychr = TRUE)

## ----kinship_probs,fig.width=8,fig.height=8------------------------------
image(1:nrow(K[[1]]), 1:ncol(K[[1]]), K[[1]][,ncol(K[[1]]):1], xlab = "Samples", 
      ylab = "Samples", yaxt = "n", main = "Kinship between samples", 
      breaks = 0:100/100, col = grey(99:0/100))
axis(side = 2, at = 20 * 0:7, labels = 20 * 7:0, las = 1)

## ----covariates----------------------------------------------------------
addcovar = matrix(pheno$Study)
rownames(addcovar) = rownames(pheno)
colnames(addcovar) = "Study"

## ----QTL,warning=FALSE---------------------------------------------------
qtl = scanone(pheno = pheno, pheno.col = "prop.bm.MN.RET", probs = probs, K = K, 
      addcovar = addcovar, snps = muga_snps)

## ----qtl_plot,fig.width=8, fig.height=6, warning=FALSE-------------------
plot(qtl, main = "prop.bm.MN.RET")

## ----perms,message=FALSE,results='hide', warning=FALSE-------------------
perms = scanone.perm(pheno = pheno, pheno.col = "prop.bm.MN.RET", probs = probs,
        addcovar = addcovar, snps = muga_snps, nperm = 100)

## ----qtl_plot_thr,fig.width=8, fig.height=6, warning=FALSE---------------
thr = quantile(perms, c(0.95, 0.9, 0.37))
plot(qtl, sig.thr = thr, sig.col = c("red", "orange", "goldenrod"), main = "prop.bm.MN.RET")

## ----coef_plot,fig.width=8, fig.height=6---------------------------------
coefplot(qtl, chr = 10, main = "prop.bm.MN.RET")

## ----interval------------------------------------------------------------
interval = bayesint(qtl, chr = 10)
interval

## ----effect_plot,fig.width=8, fig.height=6-------------------------------
pxg.plot(pheno = pheno, pheno.col = "prop.bm.MN.RET", probs = probs, 
         snp.id = interval[2,1], snps = muga_snps)

## ----assoc_map-----------------------------------------------------------
assoc = assoc.map(pheno = pheno, pheno.col ="prop.bm.MN.RET", probs = probs, K = K[[10]],
                  addcovar = addcovar, snps = muga_snps, chr = 10, start = interval[1,3],
                  end = interval[3,3])

## ----assoc_fig,fig.width=9, fig.height=6, results='hide'-----------------
tmp = assoc.plot(assoc, thr = 10)

