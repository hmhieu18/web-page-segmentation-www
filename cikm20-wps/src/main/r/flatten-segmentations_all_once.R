#!/usr/bin/env Rscript

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

option_list <- list(
    make_option("--algo-dir", type="character", default=NULL, help="Directory that contains all the algorithm segmentations", dest="algo.dir"),
    make_option("--algo-name", type="character", default=NULL, help="The name of the algorithm", dest="algo.name"),
    make_option("--ids-file", type="character", default=NULL, help="JSON file that contains all the IDs to be evaluated", dest="ids.file"),
    make_option("--output-dir", type="character", default=NULL, help="Directory to save the output", dest="output.dir"),

    make_option("--precision", type="double", default=precision.default, help=paste("Precision in pixels for intersections: decrease to 0.1 if you get non-noded intersections; default=", precision.default, sep=""))
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


if (!dir.exists(options$output.dir)) {
  dir.create(options$output.dir)
}

################################################################################
## EXECUTION
################################################################################

ids <- fromJSON(options$ids.file)

# task <- ReadTask(options$input)
# task <- subset(task, options$segmentations)
# for (name in names(task$segmentations)) {
#   geometries <- st_simplify(as.sfc.segmentation(task$segmentations[[name]]))
#   geometries <- st_snap(geometries, geometries, 0.9)
#   geometries <- st_set_precision(geometries, options$precision)
#   geometries <- geometries[st_area(geometries) >= 1]
#   intersected.polygons <- st_simplify(st_intersection(geometries))
#   intersected.polygons <- intersected.polygons[st_area(intersected.polygons) >= 1]
#   segmentation <- as.segmentation(intersected.polygons)
#   task$segmentations[[name]] <- as.segmentation(segmentation)
# }

# WriteTask(task, options$output)

for (id in ids) {
  # print progress. which is the id being processed. how many ids are there in total.
  print(paste("Processing ID:", id, "(", which(ids == id), "of", length(ids), ")"))
  
  start <- Sys.time()
  algo.file <- file.path(options$algo.dir, paste0(id, "_fitted.json"))
  
  output.file <- file.path(options$output.dir, paste0(id, "_fitted_flat.json"))
  # if output file already exists, skip
  if (file.exists(output.file)) {
    print(paste("Output file already exists for ID:", id, "Skipping..."))
    next
  }
  task <- ReadTask(algo.file)
  task <- subset(task, options$algo.name)
  for (name in names(task$segmentations)) {
    geometries <- st_simplify(as.sfc.segmentation(task$segmentations[[name]]))
    geometries <- st_snap(geometries, geometries, 0.9)
    geometries <- st_set_precision(geometries, options$precision)
    geometries <- geometries[st_area(geometries) >= 1]
    intersected.polygons <- st_simplify(st_intersection(geometries))
    intersected.polygons <- intersected.polygons[st_area(intersected.polygons) >= 1]
    segmentation <- as.segmentation(intersected.polygons)
    task$segmentations[[name]] <- as.segmentation(segmentation)
  }
  WriteTask(task, output.file)
}
