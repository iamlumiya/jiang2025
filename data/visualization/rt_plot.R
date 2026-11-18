# Visualization
library(tidyverse)
library(ggplot2)

data <- read_csv('/Users/lumikang/Documents/GitHub/-replication/data/pilot_results/analysis_data.csv')

# Data preprocessing
# [Critical]
critical_1 <- filter(data, position == "critical")
critical_2 <- filter(critical_1, RT < 5000 & RT > 100)
data_critical <- filter(critical_2,
                        RT < mean(RT) + 2.5 * sd(RT) & RT > mean(RT) - 2.5 * sd(RT))

#[Spill1]
spill1_1 <- filter(data, position == "spill1")
spill1_2 <- filter(spill1_1, RT < 5000 & RT > 100)
data_spill1 <- filter(spill1_2,
                        RT < mean(RT) + 2.5 * sd(RT) & RT > mean(RT) - 2.5 * sd(RT))

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

#[Spill4]
spill4_1 <- filter(data, position == "spill4")
spill4_2 <- filter(spill4_1, RT < 5000 & RT > 100)
data_spill4 <- filter(spill4_2,
                      RT < mean(RT) + 2.5 * sd(RT) & RT > mean(RT) - 2.5 * sd(RT))
#[Spill5]
spill5_1 <- filter(data, position == "spill5")
spill5_2 <- filter(spill5_1, RT < 5000 & RT > 100)
data_spill5 <- filter(spill5_2,
                      RT < mean(RT) + 2.5 * sd(RT) & RT > mean(RT) - 2.5 * sd(RT))

# structure
region_order <- c("critical", "spill1", "spill2", "spill3", "spill4", "spill5")

add_condition <- function(sth) {
  sth$position <- factor(sth$position, levels = region_order)
  sth$condition <- paste(
    str_to_lower(str_trim(sth$context)),
    str_to_lower(str_trim(sth$plausibility)),
    sep = "-"
  )
  sth
}

data_critical <- add_condition(data_critical)
data_spill1 <- add_condition(data_spill1)
data_spill2 <- add_condition(data_spill2)
data_spill3 <- add_condition(data_spill3)
data_spill4 <- add_condition(data_spill4)
data_spill5 <- add_condition(data_spill5)

plot_data <- bind_rows(data_critical, data_spill1, data_spill2, data_spill3, data_spill4, data_spill5)

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
  scale_y_continuous(breaks = seq(240, 340, by = 20)) +
  coord_cartesian(ylim = c(240, 340), expand = FALSE) +
  scale_x_discrete(labels = c("critical", "spill1", "spill2", "spill3", "spill4", "spill5")) +
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
