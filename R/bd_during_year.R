#' @title bd_during_year
#' @description \code{top}  Check what herds were in BD in a particular year
#' @param df BD dataset (bd_df). Created using bd_dataset_fun (bd_df <- bd_dataset_fun(master_tb))
#' @param years_to_check years to check if herd was in a BD during this time.
#' @return returns new indicator column(s) in BD dataset (0 = not in BD, 1 = in BD).
#' @details DETAILS
#'
#'
#' @examples
#' \dontrun{
#' if(interactive()){
#' newdf <- bd_during_year(bd_df, years_to_check = c(2005))
#' newdf <- bd_during_year(bd_df, years_to_check = c(2005:2006)) }
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
