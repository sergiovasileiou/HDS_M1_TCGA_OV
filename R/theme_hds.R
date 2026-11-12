# theme_hds.R
# Personal palette and a matching ggplot2 theme, so figures share the
# report's colours. Load with: source(here::here("R", "theme_hds.R"))

COL_BLUE  <- "#247BA0"
COL_SKY   <- "#73BFE2"
COL_CORAL <- "#F07855"
COL_SAND  <- "#D9A86C"
COL_NAVY  <- "#263746"
COL_GREY  <- "#73858C"
COL_BG    <- "#F5F4F0"
COL_ROSE  <- "#D6536D"

COL_TEXT  <- "#263746"
COL_LGREY <- "#E2E6E5"

COL_PALETTE <- c(COL_BLUE, COL_SKY, COL_CORAL, COL_SAND, COL_NAVY, COL_ROSE)

# Clean theme to match the report: light grid, navy text, no box
theme_hds <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = COL_TEXT),
      plot.title = ggplot2::element_text(face = "bold", size = base_size + 2),
      plot.subtitle = ggplot2::element_text(colour = COL_GREY),
      plot.caption = ggplot2::element_text(colour = COL_GREY, hjust = 0),
      axis.text = ggplot2::element_text(colour = COL_GREY),
      panel.grid.major = ggplot2::element_line(colour = COL_LGREY),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "top",
      legend.title = ggplot2::element_text(face = "bold")
    )
}

# Use the palette for colour and fill (up to six groups)
scale_colour_hds <- function(...) ggplot2::scale_colour_manual(values = COL_PALETTE, ...)
scale_fill_hds   <- function(...) ggplot2::scale_fill_manual(values = COL_PALETTE, ...)
