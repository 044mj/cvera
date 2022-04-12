#' @title bd_during
#' @description \code{top} Check what herds were in BD on a particular date.
#' @param df BD dataset (bd_df). Created using bd_dataset_fun (bd_df <- bd_dataset_fun(master_tb))
#' @param day_to_check date to check if herd was in a BD during this time
#' @param format date format, Default: '%Y-%m-%d'
#' @return returns new column in BD dataset.
#' @details DETAILS
#'
#'
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #bd_check <- bd_during(bd_df, "2017-02-27")
#'  }
#' }
#' @export
#' @importFrom data.table between
#' @importFrom dplyr if_else
#' @importFrom lubridate date
#'
bd_during <- function(df, day_to_check, format = "%Y-%m-%d") {

  day_var <- as.Date(day_to_check, format = "%Y-%m-%d")

  if (!is.na(day_var)) {
    day_name <- gsub("-", "_", day_to_check)
    names(day_var) <- day_name
    df[paste0("bd_during_", names(day_var))] <-
      lapply(day_var, function(x) dplyr::if_else(data.table::between(x, ifelse(is.na(df$bd_start), lubridate::date(df$bd_end), lubridate::date(df$bd_start)),
                                                                     ifelse(is.na(df$bd_end), lubridate::date(df$bd_start), lubridate::date(df$bd_end)),
                                                                     NAbounds = TRUE), 1, 0, as.numeric(NA)))}
  else {
    stop("Date supplied is not valid or incorrect format")}
  df
}

