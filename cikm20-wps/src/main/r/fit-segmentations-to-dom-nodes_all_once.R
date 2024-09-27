#!/usr/bin/env Rscript

# sample command:
# Rscript cikm20-wps/src/main/r/batch_handling/fit-segmentations-to-dom-nodes_all_once.R \
#   --algo-dir C:\Users\minhh\Downloads\webbis_results\content\webis_results \
#   --algo-name sam \
#   --ids-file success_ids.json \
#   --output-dir webis-webseg-20-fitted \
#   --ground-truth-dir C:\Users\minhh\Downloads\webis-webseg-20-selected


################################################################################
## LOADING SEGMENTATION LIBRARY
################################################################################

rscript.options <- commandArgs(trailingOnly = FALSE)
source.dir <- dirname(sub(".*=", "", rscript.options[grep("--file=", rscript.options)]))
source(paste(source.dir, "segmentations", "lib.R", sep="/"))

################################################################################
## OPTIONS
################################################################################

library("optparse")
library("jsonlite")

option_list <- list(
    make_option("--algo-dir", type="character", default=NULL, help="Directory that contains all the algorithm segmentations", dest="algo.dir"),
    make_option("--algo-name", type="character", default=NULL, help="The name of the algorithm", dest="algo.name"),
    make_option("--ids-file", type="character", default=NULL, help="JSON file that contains all the IDs to be evaluated", dest="ids.file"),
    make_option("--output-dir", type="character", default=NULL, help="Directory to save the output", dest="output.dir"),
    make_option("--ground-truth-dir", type="character", default=NULL, help="Directory that contains all the ground truth segmentations", dest="ground.truth.dir"),

    make_option("--fit-containment-threshold", type="double", default=fit.containment.threshold.default, help=paste("Fitted segments are the minimum axis-aligned rectangles that contain all elements that where contained to at least this percentage in the original rectangle; default=", fit.containment.threshold.default, sep=""), dest="fit.containment.threshold"),
    make_option("--segmentations", type="character", default=".*", help="Pattern that matches the names of the segmentations that should be fitted (default: .*)"),
    make_option("--tolerance", type="numeric", default=0, help="Tolerance for simplification; default: 0")
  )

options.parser <- OptionParser(option_list=option_list)
options <- parse_args(options.parser)
# if (is.null(options$input)) {
#   print_help(options.parser)
#   stop("Missing input file", call.=FALSE)
# }
# if (is.null(options$output)) {
#   print_help(options.parser)
#   stop("Missing output file", call.=FALSE)
# }

# if output directory does not exist, create it
if (!dir.exists(options$output.dir)) {
  dir.create(options$output.dir)
}



################################################################################
## EXECUTION
################################################################################


ids <- fromJSON(options$ids.file)

for (id in ids) {
  # print progress. which is the id being processed. how many ids are there in total.
  print(paste("Processing ID:", id, "(", which(ids == id), "of", length(ids), ")"))
  
  start <- Sys.time()
  algo.file <- file.path(options$algo.dir, paste0(id, ".json"))
  nodes.file <- file.path(options$ground.truth.dir, id, "nodes.csv")
  if (!file.exists(nodes.file)) {
    stop(paste("nodes.file not found for ID:", id), call.=FALSE)
  }
  
  output.file <- file.path(options$output.dir, paste0(id, "_fitted.json"))
  # if output file already exists, skip
  if (file.exists(output.file)) {
    print(paste("Output file already exists for ID:", id, "Skipping..."))
    next
  }
  
  task.algorithm <- subset(ReadTask(algo.file), options$algo.name)
  if (length(task.algorithm) != 1) {
    stop(paste("--algo-dir and --algo-name have to specify a single segmentation, but specified", length(task.algorithm)), call.=FALSE)
  }
    
  write(paste("Task", task.algorithm$id), file="")

  nodes <- ReadNodes(nodes.file)
  task <- FitToNodes(task.algorithm, nodes = nodes, fit.containment.threshold = options$fit.containment.threshold, tolerance = options$tolerance, write.info = TRUE)
  task <- subset(task, ".*fitted")
  WriteTask(task, output.file)

}
