#' @title bd_during_year
#' @description \code{top} is a small function to not just present the first rows
#' @param df BD dataset
#' @param years_to_check years to check if herd was in a BD during this time.
#' @return returns new column in BD dataset.
#' @details DETAILS
#'
#'
#' @examples
#' \dontrun{
#' if(interactive()){
#' newdf <- bd_during_year(bd_test, years_to_check = c(2005))
#' newdf <- bd_during_year(bd_test, years_to_check = c(2005:2006)) }
#' }
#' @export
#' @importFrom data.table between
#' @importFrom dplyr if_else
#'


bd_during_year <- function(df, years_to_check) {

  if (all(lapply(years_to_check, nchar) == 4)) {
    df[paste0("bd_during_", years_to_check)] <-
      lapply(years_to_check, function(x) dplyr::if_else(data.table::between(x, ifelse(is.na(df$bd_start_yr), df$bd_end_yr, df$bd_start_yr),
                                                                            ifelse(is.na(df$bd_end_yr), df$bd_start_yr, df$bd_end_yr),
                                                                            NAbounds = TRUE), 1, 0, as.numeric(NA)))}
  else {
    stop("Year supplied is not valid or incorrect format")}
  df
}
