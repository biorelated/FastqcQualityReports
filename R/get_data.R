library(rjson)
library(reshape2)
library(dplyr)

#' read a json formated fastqc data file and return a list object
#' @param filename A path to the json formatted fastqc file
#' @return A list
#' @examples
#' read.fastqc("path_to_file",format="json")
read.fastqc <- function(filename,format="json"){
  return(fromJSON(file=filename))
}

#' get basic statistics
#' This function returns the basic statics in the fastqc results module.
#' @param jsonlist A list object. The list can be derived from read.fastqc function
#' @return A dataframe
#' @examples
#' basic_stats(listobject)
basic_stats <- function(jsonlist){
  dta <- data.frame(matrix(unlist(jsonlist$`Basic Statistics`$contents), ncol = 7, byrow =T))
  dta <- dta %>%
    transmute(
      file_name  = X4,
      encoding = X2,
      file_type = X3,
      sequence_length = X5,
      poor_quality_seqs = X6,
      total_sequences = X7,
      gc_percent = X1
    )
  dta[] <- lapply(dta, as.character)
  return(dta)
}

#get the per base sequence quality
#' This function returns the per base sequence quality scores
#' @param
#' @return A dataframe
#' @examples
#' per_base_sequence_quality(jsonlist)
per_base_sequence_quality <- function(json_file){
  dta <- data.frame(matrix(unlist(json_file$`Per base sequence quality`$contents), ncol = 7, byrow =T))
  dta <- dta %>%
    transmute(
         base = X3,
         p10  = X1,
         p90  = X2,
         lower_quartile = X4,
         mean = X5,
         median = X6,
         upper_quartile = X7
         )
  dta[] <- lapply(dta, as.character)
  dta[] <- lapply(dta, as.numeric)
  return(dta)
}


#' This function returns the per base sequence information
#' @param
#' @return A dataframe
#' @examples
per_base_sequence_content <- function(json_file){
  dta <- data.frame(matrix(unlist(json_file$`Per base sequence content`$contents),ncol = 5,byrow =T))
  dta <- dta%>%
    transmute(base=X2,
              A=X1,
              C=X3,
              G=X4,
              T=X5)

  dta[] <- lapply(dta, as.character)
  dta[] <- lapply(dta, as.numeric)
  return(dta)
}


#' This function returns the count of ambiguous bases per position
#' @param a jsonfile
#' @return A dataframe of base position and count
#' @example
#' per_base_N_count(jsonfile)
per_base_N_count <- function(json_file){
  dta <- data.frame(matrix(unlist(json_file$`Per base N content`$contents), ncol = 2, byrow =T))
  dta <- dta %>%
    transmute(
      base = X1,
      N_count  = X2
    )
  dta[] <- lapply(dta, as.character)
  dta[] <- lapply(dta, as.numeric)
  return(dta)
}


#sequence duplication levels
#' Returns the duplication information as provided FastQC
#' @param
#' @return A 3 column dataframe
#' @example
#'sequence_duplication_leves(jsonfile)
sequence_duplication_levels <- function(json_file){
  dta <- data.frame(matrix(unlist(json_file$`Sequence Duplication Levels`$contents), ncol = 3, byrow =T))
  dta <- dta %>%
    transmute(
      duplication_level = X1,
      percent_deduplicated  = X2,
      percent_total = X3)
  dta[] <- lapply(dta, as.character)
  dta   <- transmute(dta,
                     duplication_level = duplication_level,
                     percent_deduplicated = as.numeric(percent_deduplicated),
                     percent_total = as.numeric(percent_total))
  dta$duplication_level <- factor(as.character( dta$duplication_level),
                                                     levels=c("1","2","3","4","5","6","7","8","9",">10",">50",">100",">500",">1k",">5k",">10k+"))
  return(dta)
}

#sequence quality scores
#' Returns the per sequence quality scores
#' @param
#' @return a dataframe
#' @example
#' per_sequence_quality_scores(jsonfile)
#'
per_sequence_quality_scores <- function(json_file){
  dta <- data.frame(matrix(unlist(json_file$`Per sequence quality scores`$contents), ncol = 2, byrow =T))
  dta <- dta %>%
    transmute(
      quality = X2,
      count  = X1
    )
  dta[] <- lapply(dta, as.character)
  dta[] <- lapply(dta, as.numeric)
  return(dta)
}

# sequence_length_distribution
#' Returns the sequence_length_distribution
#' @param
#' @return a dataframe
#' @example
#' sequence_length_distribution(jsonfile)
sequence_length_distribution <- function(json_file){
  dta <- data.frame(matrix(unlist(json_file$`Sequence Length Distribution`$contents), ncol = 2, byrow =T))
  dta <- dta %>%
    transmute(
      count  = X1,
      length = X2
    )
  dta[] <- lapply(dta, as.character)
  dta[] <- lapply(dta, as.numeric)
  return(dta)
}
