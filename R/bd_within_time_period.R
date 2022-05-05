#' @title bd_within_time_period
#' @description \code{top}  Check what herds were in BD in a particular year
#' @param df BD dataset (bd_df). Created using bd_dataset_fun (bd_df <- bd_dataset_fun(master_tb))
#' @param year_bd_started years to check if herd was in a BD during this time.
#' @param time_period Time period (in days) to see if herd was in BD prior to BD of interest which started in (year_bd_started).
#' @return returns new indicator column(s) in BD dataset (0 = not in BD within time_period, 1 = BD within time_period).
#' @details DETAILS
#'
#'
#' @examples
#' \dontrun{
#' if(interactive()){
#' bd_df <- bd_within_time_period(bd_df, 2015, 365)
#' bd_df <- bd_within_time_period(bd_df, 2016, 730)}
#' }
#' @export
#' @importFrom rlang :=
#'
#'



bd_within_time_period <- function(df, year_bd_started, time_period) {

  if (nchar(year_bd_started) == 4 & is.numeric(year_bd_started) & is.numeric(time_period)) {
    df <- df %>%
      group_by(herd_no) %>%
      mutate(!!paste0("previous_bd_", time_period, "_days_before", year_bd_started) :=
               ifelse(bd_start_yr == year_bd_started & time_between_bd <= time_period, 1, 0)) %>%
      ungroup() }

  else {
    stop("Year or time period is not valid or incorrect format")}

  warning("N.B. 'time_between_bd' may need to be recreated if some BDs have been removed as this is dependent on previous BD.")

  df
}


