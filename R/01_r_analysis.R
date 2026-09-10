# 1. data validation
library(tidyverse)
opioid_deaths <- read.csv("data/analysis_opioid_deaths.csv")
glimpse(opioid_deaths) 

# 2. check the structure and missing values
summary(opioid_deaths)

# 3. prepare data for regional trend analysis
trend_data <- opioid_deaths |> dplyr::select(year, Region, published_rate)
glimpse(trend_data)

trend_complete <- trend_data |> filter(!is.na(published_rate))
nrow(trend_complete)

# 4. visualize regional opiod death rate trend
ggplot(data = trend_complete,
  aes(x = year, y = published_rate, group = Region)) + geom_line()
  # removing the decimal of the years/only 3 plots in a row/ adding labels
ggplot(
  data = trend_complete,
  aes(x = year, y = published_rate)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  facet_wrap(~ Region, ncol = 3) +
  scale_x_continuous(breaks = c(2016, 2018, 2020, 2022, 2024)) +
  labs(
    title = "Opioid Toxicity Death Rates Across Canada",
    subtitle = "Annual crude death rates by province and territory, 2016–2025",
    x = "Year",
    y = "Deaths per 100,000 population",
    caption = "Source: Public Health Agency of Canada") + theme_minimal()

# 5A.explore the shape of regional trends
ggplot(
  data = trend_complete,
  aes(x = year, y = published_rate)) +
  geom_smooth(se = FALSE) +
  geom_point(size = 1.5) +
  facet_wrap(~ Region, ncol = 3) +
  scale_x_continuous(breaks = c(2016, 2018, 2020, 2022, 2024)) +
  labs(
    title = "Opioid Toxicity Death Rates Across Canada",
    subtitle = "Annual crude death rates by province and territory, 2016–2025",
    x = "Year",
    y = "Deaths per 100,000 population",
    caption = "Source: Public Health Agency of Canada") + theme_minimal()

# 5B. segmented regression on alberta (breah point estimate)
install.packages("segmented")
library(segmented)
alberta_data <- trend_complete |> filter(Region == "Alberta")
alberta_lm <- lm(published_rate ~ year, data = alberta_data)
alberta_segmented <- segmented(alberta_lm, seg.Z = ~ year)
summary(alberta_segmented)
alberta_segmented$psi
slope(alberta_segmented)
davies.test(alberta_lm, seg.Z = ~ year)

# 6. Compare regional changes without forcing a breakpoint
regional_change <- trend_complete |>
  filter(year == 2016 | year == 2025) |>
  dplyr::select(year, Region, published_rate) |>
  pivot_wider(
    names_from = year,
    values_from = published_rate,
    names_prefix = "rate_")
regional_change
#A. make a new column for difference rate
regional_change <- regional_change |>
  mutate(
    absolute_change = rate_2025 - rate_2016,
    percent_change = ((rate_2025 - rate_2016) / rate_2016) * 100)
regional_change
#sort the regions by absolute change:
regional_change |> arrange(desc(absolute_change))
# visualization
regional_change |>
  filter(!is.na(absolute_change)) |>
  ggplot(
    aes(
      x = reorder(Region, absolute_change),
      y = absolute_change)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Change in Opioid Toxicity Death Rates Across Canada",
    subtitle = "Absolute change in crude death rate from 2016 to 2025",
    x = NULL,
    y = "Change in deaths per 100,000 population",
    caption = "Source: Public Health Agency of Canada") + theme_minimal()

# 7.Visualize the segmented regression result
# A. Add fitted values to the Alberta data
alberta_data <- alberta_data |>
  mutate(fitted_rate = fitted(alberta_segmented))
alberta_data
# B. Store the estimated breakpoint
alberta_breakpoint <- alberta_segmented$psi[1, "Est."]
alberta_breakpoint
# C. Plot
ggplot(
  data = alberta_data, aes(x = year)) +
  geom_point(aes(y = published_rate), size = 2) +
  geom_line(aes(y = fitted_rate), linewidth = 1) +
  geom_vline(xintercept = alberta_breakpoint, linetype = "dashed") +
  scale_x_continuous(breaks = 2016:2025) +
  labs(
    title = "Segmented Regression of Alberta's Opioid Toxicity Death Rate",
    subtitle = "Exploratory segmented model estimates a change in trend around 2023",
    x = "Year",
    y = "Deaths per 100,000 population",
    caption = "Source: Public Health Agency of Canada") + theme_minimal()

# 8. export final data 
regional_change_tableau <- regional_change |>
  dplyr::select(Region, rate_2016, rate_2025, absolute_change)
regional_change_tableau
 # create an output folder
dir.create("output", showWarnings = FALSE)
 #export
write_csv(regional_change_tableau,"output/regional_change.csv")
