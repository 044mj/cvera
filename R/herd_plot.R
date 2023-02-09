#' @title herd_plot
#' @description \code{top} is a small function to not just present the first rows
#' @param df master_tb dataset
#' @param herd_no_character herd number
#' @param start_date start date of plot search. Format, '%Y-%m-%d'. Default is NULL so all years are plotted.
#' @param end_date end date of plot search. Format, '%Y-%m-%d'. Default is NULL so all years are plotted.
#' @param format date format, Default: '%Y-%m-%d'
#' @param plotly_output Decide whether plot output is static or interactive. Default is TRUE which returns interactive plotly graph.
#' @param alternative_herd_no_name If you want to change the herd_no in title to something else.
#' @return returns new column in BD dataset.
#' @details DETAILS
#'
#' @examples
#' \dontrun{
#' if(interactive()){
#' p <- herd_plot(master_tb, "x1234567")
#' p
#' p <- herd_plot(master_tb, "x1234567", start_date = "2010-01-01")
#' p
#' p <- herd_plot(master_tb, "x1234567", plotly_output = FALSE) #static plot
#' p
#' p <- herd_plot(master_tb, "x1234567", plotly_output = FALSE, alternative_herd_no_name = "other name/number")
#' p
#'  }
#' }
#' @export
#' @importFrom plotly ggplotly layout
#' @importFrom cowplot theme_cowplot background_grid
#'

herd_plot <- function(df, herd_no_character, start_date = NULL, end_date = NULL, format = "%Y-%m-%d",
                      plotly_output = TRUE, alternative_herd_no_name = NULL) {

  if (nchar(herd_no_character) != 8) {
    stop("Invalid herd number supplied (not equal to 8 characters in length)")} else {
      message("Correct herd number length")
    }

  if (herd_no_character %in% df$herd_no == FALSE) {
    stop("Invalid herd number supplied (herd number is not in the dataset)")} else {
      message("Herd number is contained in dataset")
    }

  #search by dates if included
  if (is.null(start_date) & is.null(end_date)) {
    herd_df <- df %>%
      filter(herd_no == herd_no_character)
  } else if (!is.null(end_date) & is.null(start_date)) {

    end_date_var <- as.Date(end_date, format = "%Y-%m-%d")

    herd_df <- df %>%
      filter(herd_no == herd_no_character) %>%
      filter(fixed_test_date <= end_date_var)

  } else if (!is.null(start_date) & is.null(end_date)) {

    start_date_var <- as.Date(start_date, format = "%Y-%m-%d")

    herd_df <- df %>%
      filter(herd_no == herd_no_character) %>%
      filter(fixed_test_date >= start_date_var)

  } else if (!is.null(start_date) & !is.null(end_date)) {

    start_date_var <- as.Date(start_date, format = "%Y-%m-%d")
    end_date_var <- as.Date(end_date, format = "%Y-%m-%d")

    herd_df <- df %>%
      filter(herd_no == herd_no_character) %>%
      filter(fixed_test_date >= start_date_var & fixed_test_date <= end_date_var)

  }

  herd_df <- herd_df %>%
    mutate(bd_yes = ifelse(is.na(bd_no), "Free", "BD"),
           indicator1 = rep(1:length(rle(bd_yes)$lengths), rle(bd_yes)$lengths))



  herd_df_bd <- herd_df %>%
    group_by(indicator1) %>%
    summarise(starts = min(fixed_test_date), ends = max(fixed_test_date), bd_yes = first(bd_yes)) %>%
    ungroup() %>%
    mutate(ends = lead(starts, default = as.Date("2022-02-18")))
  #colour_me = ifelse(bd_yes == "Free", "#6DBCC3", "#8B3A62"))

  max_no_animals <- max(herd_df$total_animals)
  # values = alpha(c("#8B3A62", "#6DBCC3"), .25),
  # labels = c("COVID-19", "Normal"),
  if (!is.null(alternative_herd_no_name)) {
    herd_number <- alternative_herd_no_name
  } else if (is.null(alternative_herd_no_name)) {
    herd_number <- herd_df$herd_no[1]
  }
  no_of_breakdowns <- max(herd_df$bd_no, na.rm = T)

  #get palette colours from ggsci
  #nejm
  #ggpubr::get_palette("nejm", 2)
  # [1] "#BC3C29FF" "#0072B5FF"

  gg <- ggplot() +
    #geom_rect has to be underneath geom_line, otherwise we can see hoover info
    geom_rect(data = herd_df_bd,
              aes(xmin = starts,
                  xmax = ends,
                  fill = bd_yes,
                  ymin = -10,
                  ymax = max_no_animals + 10),
              inherit.aes = FALSE,
              #fill = df2$colour_me,
              alpha = 0.6) +
    geom_line(data = herd_df, aes(x = fixed_test_date, y = total_animals)) +

    #geom_point added 10/01/23
    geom_point(data = herd_df, aes(x = fixed_test_date, y = total_animals, group = 1,
                                   text = paste0('Skin test date: ', skin_fixed_test_date, "<br>",
                                                 #format(skin_fixed_test_date, "%d/%m/%Y"),  "<br>",
                                                 'Skin test type: ', test_type,  "<br>",
                                                 'BD start date (fixed_test_date): ', fixed_test_date,  "<br>",
                                                 'Total animals tested: ', total_animals, "<br>",
                                                 'Total reactors: ', total_reactor_skin, "<br>",
                                                 'Total inconclusives: ', total_inconclusive, "<br>",
                                                 'Total slaughter cases: ', total_reactor_slaughter, "<br>",
                                                 'Total GIF cases: ', gif_cases, "<br>",
                                                 'GIF date: ', gif_actual_date, "<br>"))) +
    #adding in all TB cases on graph too 10/01/23, adding in buffer so data can be seen i.e. line width size
    #if statement to test to see if herd has any bTB cases
    #(if not (zero on every row, returns all NA which causes
    #Error: Discrete value supplied to continuous scale)
    {if (sum(herd_df$all_cases) > 0)
      list(
        geom_segment(data = herd_df %>%
                       mutate(all_cases = ifelse(all_cases == 0, NA, all_cases)),
                     aes(x = fixed_test_date, xend = fixed_test_date, y = 0, yend = all_cases), color = "#f4a261", size = 1),
        geom_point(data = herd_df %>%
                     mutate(all_cases = ifelse(all_cases == 0, NA, all_cases)), aes(x = fixed_test_date, y = all_cases, group = 1,
                                                                                    text = paste0('No of bTB cases: ', all_cases, "<br>")), color = "#f4a261", size = 1.5)
      )} +

    #geom_ribbon(aes(ymin = 0, ymax = total_animals, fill = bd_yes), color = NA, alpha = 0.2) +
    #ggplot2::scale_fill_brewer(name = "",#"Trading status"
    #                           palette = "Dark2") +
    geom_vline(data = herd_df, mapping = aes(xintercept = as.numeric(test_date_lab), col = "Lab positive(s)",
                                             text = paste0('Lab positive (date sample taken): ', format(test_date_lab, "%d/%m/%Y")))) +
    geom_vline(data = herd_df, mapping = aes(xintercept = as.numeric(gif_actual_date), col = "GIF positive(s)",
                                             text = paste0('GIF positive (date sample taken): ', format(gif_actual_date, "%d/%m/%Y"),  "<br>",
                                                           'Number of positive GIF cases: ', gif_cases,  "<br>"))) +
    #scale_fill_viridis_d() +
    #scale_color_manual(values = colours) +
    #scale_fill_manual(values = colours) +
    #scale_fill_viridis(option="D",discrete=T,end=0.85)+
    scale_color_manual(name = "", values = c("Lab positive(s)" = "red",
                                             "GIF positive(s)" = "blue")) +
    scale_fill_manual(name = "", values = c("Free" = "#6DBCC3",
                                            "BD"  = "#8B3A62")) +

    labs(y = "Number of animals at skin test", x = "Date of skin test/BD start date (fixed_test_date) \n(with lab/GIF positive case(s) overlaid)",
         title = paste0("Herd number: ", herd_number, #herd_number,
                        "\n Total no. of BDs: ", no_of_breakdowns)) +
    #geom_label_repel(aes(label = test_type), size = 7, max.overlaps = Inf) +
    theme_cowplot() +
    background_grid() +
    theme(axis.line.y.right = element_line(color = "#f4a261"),
          axis.ticks.y.right = element_line(color = "#f4a261"),
          axis.text.y.right = element_text(color = "#f4a261"),
          axis.title.y.right = element_text(color = "#f4a261")
    )


  #plotly or ggplot output
  if (plotly_output == TRUE) {
    plt <- ggplotly(gg)
    #extract range and tick values for yaxis2
    yaxis2_range <- plt$x$layout$yaxis$range
    yaxis2_tickvals <- plt$x$layout$yaxis$tickvals

    #create info for yaxis2
    ay <- list(
      overlaying = "y",
      side = "right",
      title = "No of bTB cases",
      color = "#f4a261",
      #add in values from above
      range = yaxis2_range,
      tickvals =  yaxis2_tickvals
    )

    myggplotly <- ggplotly(gg, tooltip = c("text"))
    for (i in 1:length(myggplotly$x$data)) {
      if (!is.null(myggplotly$x$data[[i]]$name)) {
        myggplotly$x$data[[i]]$name = gsub('^\\(|,\\d+\\)$', '', myggplotly$x$data[[i]]$name)
      }
    }
    ggplotly(myggplotly) %>%
      add_lines(x = ~fixed_test_date, y = ~total_animals, colors = NULL, yaxis = "y2",
                data = herd_df, showlegend = FALSE, inherit = FALSE) %>%
      layout(yaxis2 = ay,
             legend = list(title = list(text = "Trading status \nGIF/Lab detection")))

  } else if (plotly_output == FALSE) {
    gg
  }

  #gg
  #ggplotly(gg)
  # myggplotly <- ggplotly(gg, tooltip = c("text"))
  # #myggplotly
  # for (i in 1:length(myggplotly$x$data)){
  #   if (!is.null(myggplotly$x$data[[i]]$name)){
  #     myggplotly$x$data[[i]]$name = gsub('^\\(|,\\d+\\)$', '', myggplotly$x$data[[i]]$name)
  #   }
  # }
  #
  # ggplotly(myggplotly) %>%
  #   #config(displayModeBar = F) %>%
  #   layout(legend = list(title = list(text = "Trading status \nGIF/Lab detection")))


}

