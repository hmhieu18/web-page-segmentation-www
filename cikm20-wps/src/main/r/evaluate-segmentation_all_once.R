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
    make_option("--default-segmentation", action="store_true", default=FALSE, help="Treat an algorithm segmentation with no segments like a segmentation in which the entire web page is in one segment instead of throwing an error", dest="default.segmentation"),
    make_option("--precision", type="double", default=precision.default, help=paste("Precision in pixels for intersections: decrease to 0.1 if you get non-noded intersections; default=", precision.default, sep=""))
)

options.parser <- OptionParser(option_list=option_list)
options <- parse_args(options.parser)
if (is.null(options$algo.dir)) {
  print_help(options.parser)
  stop("Missing algorithm directory", call.=FALSE)
}
if (is.null(options$algo.name)) {
  print_help(options.parser)
  stop("Missing algorithm name", call.=FALSE)
}
if (is.null(options$ids.file)) {
  print_help(options.parser)
  stop("Missing IDs file", call.=FALSE)
}
if (is.null(options$output.dir)) {
  print_help(options.parser)
  stop("Missing output directory", call.=FALSE)
}
if (is.null(options$ground.truth.dir)) {
  print_help(options.parser)
  stop("Missing ground truth directory", call.=FALSE)
}

################################################################################
## EXECUTION
################################################################################

ids <- fromJSON(options$ids.file)
size.functions <- c("pixels", "chars", "nodes", "edges-fine", "edges-coarse")

for (id in ids) {
  start <- Sys.time()
  algo.file <- file.path(options$algo.dir, paste0(id, ".json"))
  ground.truth.file <- file.path(options$ground.truth.dir, id, "ground-truth.json")
  if (!file.exists(ground.truth.file)) {
    stop(paste("Ground truth file not found for ID:", id), call.=FALSE)
  }
  
  output.file <- file.path(options$output.dir, paste0(id, ".csv"))
  # if output file already exists, skip
  if (file.exists(output.file)) {
    next
  }
  ground.truth.segmentation <- "majority-vote"
  
  task.algorithm <- subset(ReadTask(algo.file), options$algo.name)
  if (length(task.algorithm) != 1) {
    stop(paste("--algo-dir and --algo-name have to specify a single segmentation, but specified", length(task.algorithm)), call.=FALSE)
  }
  
  task.ground.truth <- subset(ReadTask(ground.truth.file), ground.truth.segmentation)
  if (length(task.ground.truth) == 0) {
    stop(paste("--ground-truth-dir and ground-truth-segmentation have to specify at least one segmentation, but specified", length(task.ground.truth)), call.=FALSE)
  }
  
  write(paste("Task", task.algorithm$id), file="")
  
  bcubed <- matrix(0, nrow=length(task.ground.truth) * length(size.functions), ncol=4)
  colnames(bcubed) <- c("size.function", "bcubed.precision", "bcubed.recall", "bcubed.f1")
  row.names <- rep("NAME", length(task.ground.truth) * length(size.functions))
  
  write(paste("Algorithm:", names(task.algorithm$segmentations), "with", length(task.algorithm$segmentations[[1]]), "segments"), file="")
  if ((length(task.algorithm$segmentations[[1]]) == 0) & (options$default.segmentation)) {
    segment <- Segment(c(0,0,task.algorithm$width,task.algorithm$width), c(0,task.algorithm$height,task.algorithm$height,0))
    write("Treating segmentation without segments as one where one segment covers the whole page", file="")
    task.algorithm$segmentations[[1]] <- list(segment)
  }
  
  for (gt in 1:length(task.ground.truth)) {
    write(paste("Ground-truth:", names(task.ground.truth$segmentations)[gt], "with", length(task.ground.truth$segmentations[[gt]]), "segments"), file="")
    
    for (size.function in size.functions) {
      task <- merge(subset(task.ground.truth, gt), task.algorithm)
      clustering <- Clustering.task(task, size.function = size.function, precision = options$precision)
      bcubed.matrix <- BCubedPrecisionMatrix(clustering)
      
      bcubed.precision <- bcubed.matrix[2,1]
      bcubed.recall <- bcubed.matrix[1,2]
      bcubed.f1 <- F1(bcubed.precision, bcubed.recall)
      
      idx <- (gt - 1) * length(size.functions) + which(size.functions == size.function)
      bcubed[idx,1] <- size.function
      bcubed[idx,2] <- bcubed.precision
      bcubed[idx,3] <- bcubed.recall
      bcubed[idx,4] <- bcubed.f1
      
      row.names[idx] <- paste(names(task.ground.truth$segmentations)[gt], size.function, sep=".")
    }
  }
    
  end <- Sys.time()
  total.time <- end - start
  print(paste("Total time:", total.time))

  rownames(bcubed) <- row.names
  
  write.csv(bcubed, file=output.file)
}
