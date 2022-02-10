#' @importFrom magrittr %<>% %$% %>%
NULL

kDefaultMapping <- "data_mapping.yml"

fromRoot <- function(path) rprojroot::is_r_package$find_file(path)
tryReadFolderPath <- function(folder, mapping.file=NULL) {
  if (is.null(mapping.file)) {
    mapping.file <- fromRoot(kDefaultMapping)
  }

  if (!file.exists(mapping.file))
    return(fromRoot(folder))

  yml <- yaml::read_yaml(mapping.file)
  folder.info <- yml[["folders"]]
  if (!is.null(folder.info) && !is.null(folder.info[[folder]]))
    return(fromRoot(path.expand(folder.info[[folder]])))

  return(fromRoot(folder))
}

#' Path to data
#' @param ... path components (character vector)
#' @examples
#' DataPath("mysubfolder", "myfile.txt")
#'
#' @export
DataPath <- function(...) tryReadFolderPath("data") %>% file.path(...)

#' Path to meta-data
#' @inheritParams DataPath
#' @examples
#' MetadataPath("mysubfolder", "myfile.txt")
#'
#' @export
MetadataPath <- function(...) tryReadFolderPath("metadata") %>% file.path(...)

#' Path to cache
#' @inheritParams DataPath
#' @examples
#' CachePath("mysubfolder", "myfile.txt")
#'
#' @export
CachePath <- function(...) tryReadFolderPath("cache") %>% file.path(...)

#' Path to output
#' @inheritParams DataPath
#' @examples
#' OutputPath("mysubfolder", "myfile.txt")
#'
#' @export
OutputPath <- function(...) tryReadFolderPath("output") %>% file.path(...)

#' Path to dataset, specified in the data_mapping.yml
#' @param dataset.name name of the dataset
#' @inheritParams DataPath
#' @examples
#' DatasetPath("my_dataset", "mysubfolder", "myfile.txt")
#'
#' @export
DatasetPath <- function(dataset.name, ..., mapping.file=NULL) {
  if (is.null(mapping.file)) {
    mapping.file <- fromRoot(kDefaultMapping)
  }

  if (!file.exists(mapping.file))
    stop("Can't open mapping file '", mapping.file, "'")

  yml <- yaml::read_yaml(mapping.file)
  datasets <- yml[["datasets"]]
  if (length(datasets) == 0)
    stop("Datasets are empty in the mapping file '", mapping.file, "'")

  wrong.datasets <- setdiff(dataset.name, names(datasets))
  if (length(wrong.datasets) > 0)
    stop("Datasets '", wrong.datasets, "' aren't presented in the mapping file '", mapping.file, "'")

  paths <- unlist(datasets[dataset.name]) %>% path.expand()
  paths[!R.utils::isAbsolutePath(paths)] %<>% DataPath()
  paths %<>% file.path(...)

  return(setNames(paths, dataset.name))
}

#' Create folder structure for your project
#' @param force re-write README.md files in the directories
#' @examples
#' CreateFolders(force=F)
#'
#' @export
CreateFolders <- function(force=FALSE) {
  path.funcs <- c(data=DataPath, meta=MetadataPath, cache=CachePath, out=OutputPath)
  dir.descriptions <- c(
    data="This folder contains files with raw data. Please, describe in this file all steps to get this data.",
    meta="This folder contains files with meta-information about the data, such as age of the patients",
    cache="This folder contains files with intermediate files, created by some scripts to reduce amount of repeated computations",
    out="This folder contains output files, relevant for the publication, such as cell type annotation or figures")

  for (n in names(path.funcs)) {
    dir.create(path.funcs[[n]](), showWarnings=F, recursive=T)
    readme.file <- path.funcs[[n]]("README.md")
    if (file.exists(readme.file)) {
      warning("File '", readme.file, "' already exists")
      if (force) {
        cat(dir.descriptions[[n]], file=readme.file)
      }
    } else {
      cat(dir.descriptions[[n]], file=readme.file)
    }
  }

  mapping.file <- fromRoot(kDefaultMapping)
  if (file.exists(mapping.file)) {
    warning("File '", mapping.file, "' with mapping already exists")
  } else {
    cat("# folders:\n\n# datasets:\n", file=mapping.file)
  }
}

#' Read RDS file or create it if it does not exist using `create.fun()`
#' @param path path to the cached file
#' @param create.fun function to create the object if it does not exist
#' @param force force re-creating the object ignoring the existing one
#'
#' @export
ReadOrCreate <- function(path, create.fun, force=FALSE) {
  if (!force && file.exists(path))
    return(readr::read_rds(path))

  res <- create.fun()
  readr::write_rds(res, path)
  return(res)
}
