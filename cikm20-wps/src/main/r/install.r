packages <- c("jsonlite", "optparse", "png", "raster", "sf", "sp")

# Specify the versions for each package
package_versions <- c("jsonlite" = "1.7.2",
                      "optparse" = "1.6.6",
                      "png" = "0.1.7",
                      "raster" = "3.4.5",
                      "sf" = "0.9.6",
                      "sp" = "1.4.4")

# Install packages with specific versions
for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE) || packageVersion(pkg) != package_versions[pkg]) {
    install.packages(pkg, version = package_versions[pkg], repos = "http://cran.rstudio.com/")
  }
}

# Load the packages to confirm installation
lapply(packages, library, character.only = TRUE)
