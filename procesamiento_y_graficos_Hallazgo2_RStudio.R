# =============================================================================
# Hallazgo 2. La Religión No Es Un Bloque Monolítico
# =============================================================================

# --- 0. Librerías---
required_packages <- c("ggplot2", "dplyr", "tidyr", "ggrepel", "scales", "patchwork")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# --- 1. Temas visuales ---
BG        <- "#0B1220"
PANEL_BG  <- "#0F172A"
GRID_CLR  <- "#1F2A44"
TEXT_CLR  <- "#E5E7EB"
MUTED_CLR <- "#94A3B8"
ACCENT    <- "#FBBF24"
BLUE_CLR  <- "#60A5FA"

palette_region <- c(
  "Latam"         = "#F97316",
  "Anglosfera"    = "#6366F1",
  "Europa"        = "#3B82F6",
  "Asia"          = "#10B981",
  "Africa"        = "#F59E0B",
  "Medio Oriente" = "#EC4899"
)

theme_mm <- function() {
  theme_minimal(base_size = 11) +
    theme(
      plot.background  = element_rect(fill = BG, color = NA),
      panel.background = element_rect(fill = PANEL_BG, color = NA),
      panel.grid.major = element_line(color = GRID_CLR, linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.text        = element_text(color = MUTED_CLR),
      axis.title       = element_text(color = MUTED_CLR),
      legend.text      = element_text(color = TEXT_CLR),
      legend.title     = element_text(color = MUTED_CLR),
      plot.title       = element_text(color = TEXT_CLR, size = 16, face = "bold"),
      plot.subtitle    = element_text(color = MUTED_CLR),
      plot.caption     = element_text(color = MUTED_CLR, size = 8),
      plot.margin      = margin(16,16,12,16)
    )
}

# --- 2. Datos---
df <- read.csv(
  "C:\\Users\\juans\\OneDrive\\Documentos\\Prueba Alegra- BI Sales\\religion_gdp_merged_2023.csv",
  stringsAsFactors = FALSE
)

# Limpieza clave
df <- df |>
  mutate(
    pct_pray_daily = as.numeric(pct_pray_daily),
    gap_affil_afterlife = pct_religiously_affiliated - pct_believe_life_after_death,
    is_israel = ISO3 == "ISR",
    label_country = case_when(
      Country == "U.S." ~ "EE.UU.",
      Country == "South Korea" ~ "Corea S.",
      TRUE ~ Country
    )
  )

# --- 3. PANEL 1 ---
p1 <- ggplot(df, aes(pct_religiously_affiliated, pct_believe_life_after_death)) +
  
  # diagonal
  geom_abline(slope = 1, intercept = 0,
              linetype = "dashed", color = MUTED_CLR, alpha = 0.5) +
  
  # puntos (todos los países)
  geom_point(
    aes(color = region, size = pct_pray_daily),
    alpha = 0.75
  ) +
  
  # etiquetas de países (CLAVE)
  ggrepel::geom_text_repel(
    aes(label = label_country, color = region),
    size = 2.5,
    max.overlaps = 30,
    segment.color = MUTED_CLR,
    segment.alpha = 0.5,
    box.padding = 0.3,
    point.padding = 0.2,
    show.legend = FALSE
  ) +
  
  # highlight Israel
  geom_point(
    data = filter(df, is_israel),
    color = ACCENT, size = 7, shape = 18
  ) +
  
  ggrepel::geom_text_repel(
    data = filter(df, is_israel),
    aes(label = "Israel"),
    color = ACCENT,
    size = 3,
    fontface = "bold",
    box.padding = 0.4
  ) +
  
  scale_color_manual(values = palette_region) +
  
  # 👉 eliminamos leyenda de tamaño
  scale_size_continuous(range = c(3, 9), guide = "none") +
  
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  
  labs(
    title = "Afiliación ≠ Creencia",
    subtitle = "Cada punto es un país (tamaño = % que ora a diario)",
    x = "% afiliación religiosa",
    y = "% cree en vida después de la muerte"
  ) +
  theme_mm()

# --- 4. PANEL 2 ---
df_gap <- df |>
  arrange(gap_affil_afterlife) |>
  mutate(label_country = factor(label_country, levels = label_country))

p2 <- ggplot(df_gap) +
  
  geom_segment(aes(
    x = pct_believe_life_after_death,
    xend = pct_religiously_affiliated,
    y = label_country,
    yend = label_country
  ), color = "#475569", linewidth = 1) +
  
  geom_point(
    aes(x = pct_believe_life_after_death,
        y = label_country,
        color = "Creencia en el más allá"),
    size = 2.8
  ) +
  
  geom_point(
    aes(x = pct_religiously_affiliated,
        y = label_country,
        color = "Afiliación religiosa"),
    size = 2.8
  ) +
  
  scale_color_manual(
    name = NULL,
    values = c(
      "Creencia en el más allá" = BLUE_CLR,
      "Afiliación religiosa" = ACCENT
    )
  ) +
  
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  
  labs(
    title = "La Brecha es Real",
    subtitle = "Afiliación vs creencia en el más allá",
    x = "% población",
    y = NULL
  ) +
  
  theme_mm() +
  theme(
    legend.position = "top",
    legend.direction = "horizontal"
  )

# --- 5. COMPOSICIÓN ---
final_plot <- (p1 | p2) +
  plot_annotation(
    title = "La Religión No Es Un Bloque Monolítico",
    subtitle = "Identidad religiosa, creencias y espiritualidad no siempre van juntas",
    caption = "Fuente: Elaboración propia con base a Pew Research Center utilizando Rstudio"
  )

# --- 6. EXPORT ---
ggsave(
  "graficos_hallazgo2.png",
  final_plot,
  width = 16,
  height = 13,
  dpi = 180,
  bg = BG
)

cat(" El Gráfico esta listo")