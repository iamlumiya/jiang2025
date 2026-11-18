# Visualization
library(tidyverse)
library(ggplot2)

data <- read_csv('/Users/lumikang/Documents/GitHub/-replication/data/pilot_results/analysis_data.csv')

# Data preprocessing
#[Spill2]
spill2_1 <- filter(data, position == "spill2")
spill2_2 <- filter(spill2_1, RT < 5000 & RT > 100)
data_spill2 <- filter(spill2_2,
                      RT < mean(RT) + 2.5 * sd(RT) & RT > mean(RT) - 2.5 * sd(RT))

#[Spill3]
spill3_1 <- filter(data, position == "spill3")
spill3_2 <- filter(spill3_1, RT < 5000 & RT > 100)
data_spill3 <- filter(spill3_2,
                      RT < mean(RT) + 2.5 * sd(RT) & RT > mean(RT) - 2.5 * sd(RT))

#[Spill5]
spill5_1 <- filter(data, position == "spill5")
spill5_2 <- filter(spill5_1, RT < 5000 & RT > 100)
data_spill5 <- filter(spill5_2,
                      RT < mean(RT) + 2.5 * sd(RT) & RT > mean(RT) - 2.5 * sd(RT))

# structure
region_order <- c("spill2", "spill3", "spill5")
condition_order <- c("realistic-plausible", "realistic-implausible", "unrealistic-plausible", "unrealistic-implausible")


add_condition <- function(sth) {
  sth$position <- factor(sth$position, levels = region_order)
  sth$condition <- paste(
    str_to_lower(str_trim(sth$context)),
    str_to_lower(str_trim(sth$plausibility)),
    sep = "-"
  )
  sth
}

data_spill2 <- add_condition(data_spill2)
data_spill3 <- add_condition(data_spill3)
data_spill5 <- add_condition(data_spill5)

plot_data <- bind_rows(data_spill2, data_spill3, data_spill5)

plot_summary <- plot_data |>
  mutate(condition = factor(condition, levels = condition_order)) |>
  group_by(subject, position, condition) |>
  summarise(subject_mean  = mean(RT), ,groups = "drop") |>
  group_by(position, condition) |>
  summarise(
    mean_rt = mean(subject_mean),
    n_subjects = n(),
    se = sd(subject_mean) / sqrt(n_subjects),
    .groups = "drop"
  ) |>
  mutate(
    ci_half_width = qt(0.975, df = pmax(n_subjects - 1, 1)) * se,
    ci_low = mean_rt - ci_half_width,
    ci_high = mean_rt + ci_half_width
  )

# visualization
rt_plot <- ggplot(
  plot_summary,
  aes(
    x = position, y = mean_rt, group = condition,
    color = condition, linetype = condition
  )) +
  geom_line(linewidth = 0.9) +
  geom_errorbar(
    aes(ymin = ci_low, ymax = ci_high),
    width = 0.10, linewidth = 0.65,
    linetype = "solid", na.rm = TRUE,
    show.legend = FALSE) +
  geom_point(size = 2.5) +
  scale_x_discrete(labels = c("spill2", "spill3", "spill5")) +
  scale_color_manual(
    name = "conditions",
    values = setNames(
      c("black", "black", "grey", "grey"), condition_order
    )) +
  scale_linetype_manual(
    name = "conditions",
    values = setNames(
      c("solid", "dashed", "solid", "dashed"), condition_order
    )) +
  labs(x = NULL, y = "Reading times (ms)") +
  theme_classic()

print(rt_plot)  

