read.vcf <- function(file, max.snps, get.info = FALSE, convert.chr = TRUE, verbose = getOption("gaston.verbose",TRUE)) {
  xx <- NULL;
  if(is.character(file)) {
    filename <- path.expand(file)
    xx <- WhopGenome::vcf_open(file)
    if(is.null(xx)) stop("File not found")
    samples <- WhopGenome::vcf_getsamples(xx) 
    which.samples <- rep(TRUE, length(samples))
    WhopGenome::vcf_selectsamples( xx, samples )
    f <- function() WhopGenome::vcf_readLineRaw(xx) 
  } else {
    samples <- WhopGenome::vcf_getselectedsamples(file)
    which.samples <- WhopGenome::vcf_getsamples(file) %in% samples
    # vcf_readLineRawFiltered doesn't deal well with filtered lines
    # -> we need this kludge to get filtered raw lines with the same
    #    behavior as vcf_readLineRaw
    f <- function() {
      a <- WhopGenome::vcf_readLineVecFiltered(file) 
      if(is.null(a)) 
        FALSE
      else
        paste(a, collapse = "\t")
    }
  }

  if(missing(max.snps)) max.snps = -1L;

  if(verbose) cat("Reading diallelic variants for", length(samples), "individuals\n");
  
  L <- .Call("gg_read_vcf2", PACKAGE = "gaston", f, which.samples, max.snps, get.info)
  if(!is.null(xx)) WhopGenome::vcf_close(xx)

  snp <- data.frame(chr = L$chr, id = L$id, dist = 0, pos = L$pos , A1 = L$A1, A2 = L$A2, 
                    quality = L$quality, filter = factor(L$filter), stringsAsFactors = FALSE)
  if(get.info) snp$info <-  L$info
  if(convert.chr) {
    chr <- as.integer(L$chr)
    chr[L$chr == "X"  | L$chr == "x"]  <- getOption("gaston.chr.x")[1]
    chr[L$chr == "Y"  | L$chr == "y"]  <- getOption("gaston.chr.y")[1]
    chr[L$chr == "MT" | L$chr == "mt"] <- getOption("gaston.chr.mt")[1]
    if(any(is.na(chr))) 
      warning("Some unknown chromosomes id's (try to set convert.chr = FALSE)")
    snp$chr <- chr
  } 

  ped <- data.frame(famid = samples, id = samples, father = 0, mother = 0, sex = 0, pheno = NA, stringsAsFactors = FALSE)
  x <- new("bed.matrix", bed = L$bed, snps = snp, ped = ped,
           p = NULL, mu = NULL, sigma = NULL, standardize_p = FALSE,
           standardize_mu_sigma = FALSE )

  if(getOption("gaston.auto.set.stats", TRUE)) x <- set.stats(x, verbose = verbose)
  x
}

read.vcf.filtered <- function(file, positions, max.snps, get.info = FALSE, convert.chr = TRUE, verbose = getOption("gaston.verbose",TRUE)) {
  xx <- NULL;
  if(is.character(file)) {
    filename <- path.expand(file)
    xx <- WhopGenome::vcf_open(file)
    if(is.null(xx)) stop("File not found")
    samples <- WhopGenome::vcf_getsamples(xx) 
    which.samples <- rep(TRUE, length(samples))
    WhopGenome::vcf_selectsamples( xx, samples )
    f <- function() WhopGenome::vcf_readLineRaw(xx) 
  } else {
    samples <- WhopGenome::vcf_getselectedsamples(file)
    which.samples <- WhopGenome::vcf_getsamples(file) %in% samples
    # vcf_readLineRawFiltered doesn't deal well with filtered lines
    # -> we need this kludge to get filtered raw lines with the same
    #    behavior as vcf_readLineRaw
    f <- function() {
      a <- WhopGenome::vcf_readLineVecFiltered(file) 
      if(is.null(a)) 
        FALSE
      else
        paste(a, collapse = "\t")
    }
  }

  if(missing(max.snps)) max.snps = -1L;

  if(verbose) cat("Reading diallelic variants for", length(samples), "individuals\n");
  
  L <- .Call("gg_read_vcf_filtered", PACKAGE = "gaston", f, positions, which.samples, max.snps, get.info)
  if(!is.null(xx)) WhopGenome::vcf_close(xx)

  snp <- data.frame(chr = L$chr, id = L$id, dist = 0, pos = L$pos , A1 = L$A1, A2 = L$A2, 
                    quality = L$quality, filter = factor(L$filter), stringsAsFactors = FALSE)
  if(get.info) snp$info <-  L$info
  if(convert.chr) {
    chr <- as.integer(L$chr)
    chr[L$chr == "X"  | L$chr == "x"]  <- getOption("gaston.chr.x")[1]
    chr[L$chr == "Y"  | L$chr == "y"]  <- getOption("gaston.chr.y")[1]
    chr[L$chr == "MT" | L$chr == "mt"] <- getOption("gaston.chr.mt")[1]
    if(any(is.na(chr))) 
      warning("Some unknown chromosomes id's (try to set convert.chr = FALSE)")
    snp$chr <- chr
  } 

  ped <- data.frame(famid = samples, id = samples, father = 0, mother = 0, sex = 0, pheno = NA, stringsAsFactors = FALSE)
  x <- new("bed.matrix", bed = L$bed, snps = snp, ped = ped,
           p = NULL, mu = NULL, sigma = NULL, standardize_p = FALSE,
           standardize_mu_sigma = FALSE )

  if(getOption("gaston.auto.set.stats", TRUE)) x <- set.stats(x, verbose = verbose)
  x
}

