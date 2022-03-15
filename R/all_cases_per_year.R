#' @title all_cases_per_year
#' @description \code{top} Extracts positive bTB cases per year by skin test,
#' lab and GIF.
#' @param df master_tb dataset
#' @param drop_years years to drop e.g. c(2022) or c(2021, 2022)
#' @param return_plot_table do you want to return a plot, table version or both.
#' @return returns a table or visually plot of the number of positive bTB animals
#' @details DETAILS
#'
#'
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #cases <- all_cases_per_year(master_tb)
#'  #cases <- all_cases_per_year(master_tb, drop_years = c(2022))
#'  #cases <- all_cases_per_year(master_tb, drop_years = c(2022), return_plot_table = "plot only")
#'  #cases <- all_cases_per_year(master_tb, drop_years = c(2022), return_plot_table = "table only")
#'  }
#' }
#' @export
#' @import ggplot2
#' @rawNamespace import(dplyr, except = between)
#' @importFrom ggsci scale_color_nejm
#' @importFrom lubridate year
#' @importFrom purrr reduce
#' @importFrom tidyr pivot_longer


all_cases_per_year <- function(df, drop_years = NA, return_plot_table = c("both",
                                                                          "plot only",
                                                                          "table only")) {
  all_cases_table <-
    list(  #skin
      df %>%
        group_by(year = year(skin_fixed_test_date)) %>%
        summarise(skin_test_reactors = sum(total_reactor_skin)) %>%
        ungroup() %>%
        filter(!is.na(year)),
      #lab
      df %>%
        filter(!is.na(test_date_lab)) %>%
        group_by(year = year(test_date_lab)) %>%
        summarise(slaughter_detected = sum(total_reactor_slaughter, na.rm = T)) %>%
        ungroup(),
      #gif
      df %>%
        filter(!is.na(gif_actual_date)) %>%
        group_by(year = year(gif_actual_date)) %>%
        summarise(gif_cases = sum(gif_cases, na.rm = T)) %>%
        ungroup()) %>%
    reduce(left_join) %>%
    mutate(all_cases = rowSums(select(., -year), na.rm = T))

  if (is.na(drop_years)) {
    all_cases_table
  } else {
    all_cases_table <- all_cases_table %>%
      filter(!year  %in%  drop_years)
    all_cases_table
  }


  all_cases_plot_df <- all_cases_table %>%
    #select(wt, drat) %>%
    rename(c("Skin test cases" = "skin_test_reactors",
             "Slaughter cases" = "slaughter_detected",
             "GIF cases" = "gif_cases",
             "Total cases" = "all_cases")) %>%
    #mutate(time = row_number()) %>%
    pivot_longer(
      cols = ends_with("cases"),
      names_to = "bTB positive cases",
      values_to = "value"
    )

  if (is.na(drop_years)) {
    all_cases_plot_df
  } else {
    all_cases_plot_df <- all_cases_plot_df %>%
      filter(!year  %in%  drop_years)
    all_cases_plot_df
  }

  min_year <- min(all_cases_plot_df$year)
  max_year <- max(all_cases_plot_df$year)


  all_cases_plot <- all_cases_plot_df %>%
    ggplot(aes(year, value, color = `bTB positive cases`)) + #, shape = variable)) +
    geom_line(size = 1.5) +
    geom_point(size = 4) +
    scale_color_nejm() +
    labs(x = "Year", y = "Number of cases", title =
           paste0("bTB cases by year (", min_year, " - ", max_year, ")")) +
    theme(axis.text = element_text(size = 12, face = "bold", colour = "black"),
          axis.title = element_text(size = 14, face = "bold", colour = "black"))

  #https://stackoverflow.com/questions/4683405/function-default-arguments-and-named-values
  plot_or_table <- match.arg(return_plot_table)
  if (return_plot_table == "both") {
    return(list(all_cases_table, all_cases_plot))
  } else if (return_plot_table == "plot only") {
    return(all_cases_plot)
  } else if (return_plot_table == "table only") {
    return(all_cases_table)
  }
  #plot_or_table <- match.arg(return_plot_table)
  #return(plot_or_table)
}











