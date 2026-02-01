library("here")
source(here("R", "header.R"))

setwd(here("data"))

raw_file_paths = list.files("raw")
annotatedIDs = list.files("metadata/")

dat = sapply(
  raw_file_paths, 
  function(x) 
    read.delim(paste0("raw/", x), header = F))

dat = do.call('cbind', dat)

message("[OK] Setting environment")

rownames(dat) <- dat[,1]
dat <- dat[, dat[1, ] != "Geneid"]
names(dat) <- substr(names(dat), 1, 3)

#removing 1st Row/Last Col
dat<- dat[-1,]
dat<- dat[,-18]

# converting to numeric
dat[] = lapply(dat, as.numeric)

#Handling Missing Values 
if (any(is.na(dat))) {
  message("[FAIL] Missing entries detected")
} else {
  message("[OK] No missing entries")
}

if (all(dat %% 1 == 0)) {
  message("[OK] All data in Integers")
} else {
  message("[FAIL] Not all data in Integers")
}

message("[OK] Cleaning Data")

#Make annotations
geneID = read.delim(paste0("metadata/", annotatedIDs), header = T)
annot = data.frame(sample_name = colnames(dat))
annot = cbind(annot, condition = c(rep('Control', 8), rep('Treatment', 9)))
rownames(annot) <- colnames(dat)
message("[OK] Making Annotations")

#Write Files
out_dir <- file.path("processed")

# write processed data
write.table(
  dat,
  file.path(out_dir, "dat_processed.tsv"),
  sep = "\t",
  col.names = TRUE,
  row.names = TRUE,
  quote = FALSE
)

# write sample annotation
write.table(
  annot,
  file.path(out_dir, "sample_annotation.txt"),
  sep = "\t",
  col.names = TRUE,
  row.names = FALSE,
  quote = FALSE,
)
  
message(
  "[OK] Complete, outputs written to:",
  out_dir,
  "\n"
)

rm(list = ls())
