% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/burdenMeta.R
\name{burdenMeta}
\alias{burdenMeta}
\title{Meta analyze burden tests from multiple studies}
\usage{
burdenMeta(..., SNPInfo = NULL, wts = 1, snpNames = "Name",
  aggregateBy = "gene", mafRange = c(0, 0.5), verbose = FALSE)
}
\arguments{
\item{...}{\code{seqMeta} objects}

\item{SNPInfo}{The SNP Info file.  This should contain the fields listed in
snpNames and aggregateBy. Only SNPs in this table will be meta analyzed, so
this may be used to restrict the analysis.}

\item{wts}{weights for the burden test, as a function of maf, or a character string specifying weights in the SNP Info file.}

\item{snpNames}{The field of SNPInfo where the SNP identifiers are found. 
Default is 'Name'}

\item{aggregateBy}{The field of SNPInfo on which the skat results were
aggregated.  Default is 'gene'. Though gene groupings are not explicitely
required for single snp analysis, it is required to find where single snp
information is stored in the seqMeta objects.}

\item{mafRange}{Range of MAF's to include in the analysis (endpoints included).  Default is all SNPs (0 <= MAF <= 0.5).}

\item{verbose}{logical. Whether progress bars should be printed.}
}
\value{
a data frame with the following columns:
  \item{gene}{the name of the gene or unit of aggregation being meta analyzed}
  \item{p}{the p-value from the burden tests}
  \item{beta}{approximate coefficient for the effect of genotype}
  \item{se}{approximate standard error for the effect of genotype}
  \item{cmafTotal}{the cumulative minor allele frequency of the gene}
  \item{cmafUsed}{the cumulative minor allele frequency of snps used in the
  analysis}
  \item{nsnpsTotal}{the number of snps in the gene}
  \item{nsnpsUsed}{the number of snps used in the analysis}
  \item{nmiss}{The number of `missing` SNPs. For a gene with a single SNP
  this is the number of individuals which do not contribute to the analysis,
  due to studies that did not report results for that SNP. For a gene with
  multiple SNPs, is totalled over the gene.}
}
\description{
Takes as input `seqMeta` objects (from the
  \code{\link{prepScores}} function), and meta-analyzes the corresponding
  burden test.
}
\details{
This function uses the scores and their variances available in a
  seqMeta object to perform burden tests. Though coefficients are reported,
  the tests are formally score tests, and the coefficients can be thought of
  as one-step approximations to those reported in a Wald test.
}
\examples{
###load example data for two studies:
### see ?seqMetaExample	
data(seqMetaExample)

####run on each cohort:
cohort1 <- prepScores(Z=Z1, y~1, SNPInfo=SNPInfo, data=pheno1)
cohort2 <- prepScores(Z=Z2, y~1, SNPInfo=SNPInfo, data=pheno2)

#### combine results:
out <- burdenMeta(cohort1, cohort2, SNPInfo = SNPInfo, mafRange=c(0,.01))
head(out)

\dontrun{
##### Compare with analysis on full data set:
bigZ <- matrix(NA,2*n,nrow(SNPInfo))
colnames(bigZ) <- SNPInfo$Name

for(gene in unique(SNPInfo$gene)) {
   snp.names <- SNPInfo$Name[SNPInfo$gene == gene]
     bigZ[1:n,SNPInfo$gene == gene][ , snp.names \\\%in\\\% colnames(Z1)] <- 
                   Z1[ , na.omit(match(snp.names,colnames(Z1)))]
     bigZ[(n+1):(2*n),SNPInfo$gene == gene][ , snp.names \\\%in\\\% colnames(Z2)] <- 
                   Z2[ , na.omit(match(snp.names,colnames(Z2)))]
}

pheno <- rbind(pheno1[, c("y","sex","bmi")],pheno2[,c("y","sex","bmi")])
burden.p <- c(by(SNPInfo$Name, SNPInfo$gene, function(snp.names) {
   inds <- match(snp.names,colnames(bigZ)) burden <- rowSums(bigZ[,na.omit(inds)],na.rm=TRUE)
   mod <- lm(y~burden + gl(2,nrow(pheno1)),data=pheno)
   summary(mod)$coef[2,4]
}))

head(cbind(out$p,burden.p))

#will be slightly different:
plot(y=out$p,x=burden.p, ylab = "burden meta p-values", xlab = "complete data p-values")
}

}
\author{
Arie Voorman, Jennifer Brody
}
\seealso{
\code{\link{skatMeta}}
\code{\link{skatOMeta}}
\code{\link{prepScores}}
}

