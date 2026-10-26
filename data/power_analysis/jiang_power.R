# Poweranalysis for Jiang & Filik (2025)
library(tidyverse)
library(lmerTest)
library(lme4)
library(rempsyc)
library(simr)

full_data <- read_csv("/Users/lumikang/Documents/UCSD/26-27/26Fall/Psyc201/data/rawdata.csv")
full_data

# Data preprocessing
# Exclude the extremes for spill region 2 and 3
# [Spill2]
spill2_1 <- filter(full_data, position == "spill2")
spill2_2 <- filter(spill2_1, RT < 5000 & RT > 100)
data_spill2 <- filter(spill2_2, 
                      RT < mean(RT) + 2.5 * sd(RT) & 
                      RT > mean(RT) - 2.5 * sd(RT))

# [Spill3]
spill3_1 <- filter(full_data, position == "spill3")
spill3_2 <- filter(spill3_1, RT < 5000 & RT > 100)
data_spill3 <- filter(spill3_2, 
                      RT < mean(RT) + 2.5 * sd(RT) &
                      RT > mean(RT) - 2.5 * sd(RT))

# Prepare data for lmm analysis
# [Spill2]
data_spill2$context <- as.factor(data_spill2$context)
data_spill2$context <-relevel(data_spill2$context,
                              ref = "realistic")
contrasts(data_spill2$context) <- c(-0.5, 0.5)

data_spill2$plausibility <- as.factor(data_spill2$plausibility)
data_spill2$plausibility <- relevel(data_spill2$plausibility,
                                    ref = "plausible")
contrasts(data_spill2$plausibility) <- c(-0.5, 0.5)

data_spill2$subject <- as.factor(data_spill2$subject)
data_spill2$item <- as.factor(data_spill2$item)
data_spill2$RT <- as.numeric (data_spill2$RT)

data_spill2 <- data_spill2 %>%
  mutate(z_CL = scale(CL)) %>%
  select(subject, item, context, plausibility, z_CL, RT)

# Fit the model
# context * plausibility * z_cl + (1+plausibility|item) + (1|subject)
spill2_mdl <- lmer(log(RT) ~ 1 + context * plausibility *z_CL + (1+plausibility|item) + (1|subject),
                   data = data_spill2)
summary(spill2_mdl)

spill2_results <-
  as.data.frame(summary(spill2_mdl)$coefficients)
spill2_CI <- confint(spill2_mdl)
spill2_results<-cbind(spill2_results,
                      spill2_CI[4:11,])

spill2_results <- tibble::rownames_to_column(spill2_results, "Fixed effects")
names(spill2_results) <- c("Fixed effects",
                           "β", "SE", "df",
                           "t", "p", "CI_lower", "CI_upper")
spill2_results <- spill2_results %>%
  mutate(p = p.adjust(p, method = "bonferroni")) %>%
  select("Fixed effects",
         "β", "SE", "t",
         "p", "CI_lower", "CI_upper")

spill2_results <- nice_table(spill2_results)
print(spill2_results, preview = "docx")

data_spill2 %>% group_by(plausibility) %>%
  summarize(mean(RT))

# Power analysis
spill2_power_104 <- powerSim(spill2_mdl, test = fixed("plausibility1", method = "t"),
                             nsim = 100, alpha = 0.05, seed = 2026)
spill2_power_104

spill2_power_80 <- powerCurve(spill2_mdl, test = fixed("plausibility1", method = "t"),
                              along = "subject", breaks = 80, nsim = 100, alpha = 0.05, seed = 206)
spill2_power_80

spill2_power_small <- powerCurve(spill2_mdl, test = fixed("plausibility1", method = "t"),
                              along = "subject", breaks = c(40, 60), nsim = 100, alpha = 0.05, seed = 206)
spill2_power_small

spill2_power_50 <-powerCurve(spill2_mdl, test = fixed("plausibility1", method = "t"),
                                 along = "subject", breaks = 50, nsim = 100, alpha = 0.05, seed = 206)
spill2_power_50

# Power plot
spill2_power_curve <- tibble(
  n_total = c(40, 50, 60, 80, 104),
  power = c(.75, .83, .91, .95, .96),
  lower = c(.6534, .7418, .8360, .8740, .9007),
  upper = c(.8312, .8977, .9580, .9777, .9890)
)

spill2_power_plot <- ggplot(spill2_power_curve, aes(x = n_total, y = power)) +
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 2
  ) +
  geom_line() +
  geom_point(size = 3) +
  geom_hline(yintercept = .80, linetype = "dashed") +
  geom_hline(yintercept = .90, linetype = "dashed") +
  geom_hline(yintercept = .05, linetype = "dotted") +
  scale_y_continuous(
    labels = scales::label_percent(),
    breaks = seq(.60, 1, by = .05)
  ) +
  coord_cartesian(ylim = c(.60, 1)) +
  scale_x_continuous(breaks = c(40, 50, 60, 80, 104)) +
  labs(
    x = "Number of participants",
    y = "Estimated power",
    subtitle = "Spill2: plausibility β = 0.04954; α = .05",
    caption = "100 simulations per sample size; bars show 95% Monte Carlo intervals."
  ) +
  theme_classic()

print(spill2_power_plot)

ggsave("spill2_power_plot.png",spill2_power_plot,
       width = 10, height = 6, units = "in", dpi= 300)



### Exact number?
spill2_power_mid <- powerCurve(spill2_mdl, test = fixed("plausibility1", method = "t"),
                               along = "subject", breaks = c(48, 50, 52, 54, 56, 58, 60), nsim = 1000, alpha = 0.05, seed = 206)
spill2_power_mid

spill2_power_curve_mid <- tibble(
  n_total = c(48, 50, 52, 54, 56, 58, 60),
  power = c(.825, .832, .849, .859, .872, .881, .889),
  lower = c(.80, .8074, .8253, .8359, .8497, .8593, .8679),
  upper = c(.8481, .8547, .8706, .8800, .8921, .9004, .9078)
)

spill2_power_plot_mid <- ggplot(spill2_power_curve_mid, aes(x = n_total, y = power)) +
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 2
  ) +
  geom_line() +
  geom_point(size = 3) +
  geom_hline(yintercept = .80, linetype = "dashed") +
  geom_hline(yintercept = .90, linetype = "dashed") +
  geom_hline(yintercept = .05, linetype = "dotted") +
  scale_y_continuous(
    labels = scales::label_percent(),
    breaks = seq(.75, 1, by = .05)
  ) +
  coord_cartesian(ylim = c(.75, 1)) +
  scale_x_continuous(breaks = c(48, 50, 52, 54, 56, 58, 60)) +
  labs(
    x = "Number of participants",
    y = "Estimated power",
    subtitle = "Spill2: plausibility β = 0.04954; α = .05",
    caption = "1000 simulations per sample size; bars show 95% Monte Carlo intervals."
  ) +
  theme_classic()

print(spill2_power_plot_mid)

ggsave("spill2_power_plot_mid.png",spill2_power_plot_mid,
       width = 10, height = 6, units = "in", dpi= 300)

# [Spill3]
data_spill3$context <- as.factor(data_spill3$context)
data_spill3$context <-relevel(data_spill3$context,
                              ref = "realistic")
contrasts(data_spill3$context) <- c(-0.5, 0.5)

data_spill3$plausibility <- as.factor(data_spill3$plausibility)
data_spill3$plausibility <- relevel(data_spill3$plausibility,
                                    ref = "plausible")
contrasts(data_spill3$plausibility) <- c(-0.5, 0.5)

data_spill3$subject <- as.factor(data_spill3$subject)
data_spill3$item <- as.factor(data_spill3$item)
data_spill3$RT <- as.numeric(data_spill3$RT)

data_spill3 <- data_spill3 %>%
  mutate(z_CL = scale(CL)) %>%
  select(subject, item, context, plausibility, z_CL, RT)

# context * plausibility * Z_CL + (1|item) +(1|subject)
spill3_mdl <- lmer(log(RT) ~ 1 + context * plausibility * z_CL + (1|item) + (1|subject),
                   data = data_spill3,
                   control = lmerControl(optimizer = "bobyqa",
                                         optCtrl = list(maxfun = 1e6)))
summary(spill3_mdl)

spill3_results <- as.data.frame(summary(spill3_mdl)$coefficients)
spill3_CI <- confint(spill3_mdl)
spill3_results <- cbind(spill3_results, spill3_CI[4:11,])
spill3_results <- tibble::rownames_to_column(spill3_results, "Fixed effects")
names(spill3_results) <- c("Fixed effects",
                           "β", "SE", "df",
                           "t", "p", "CI_lower", "CI_upper")

spill3_results <- spill3_results %>%
  mutate(p = p.adjust(p, method = "bonferroni")) %>%
  select("Fixed effects",
         "β", "SE", "t",
         "p", "CI_lower", "CI_upper")

spill3_results <- nice_table(spill3_results)
print(spill3_results, preview = "docx")

data_spill3 %>% group_by(plausibility) %>%
  summarise(mean(RT))

# Power analysis
spill3_power_104 <- powerSim(spill3_mdl, test = fixed("plausibility1", method = "t"),
                             nsim = 100, alpha = 0.05, seed = 2026)
spill3_power_104

spill3_power_80 <- powerCurve(spill3_mdl, test = fixed("plausibility1", method = "t"),
                              along = "subject", breaks = 80, nsim = 100, alpha = 0.05, seed = 206)
spill3_power_80

spill3_power_small <- powerCurve(spill3_mdl, test = fixed("plausibility1", method = "t"),
                                 along = "subject", breaks = c(40, 60), nsim = 100, alpha = 0.05, seed = 206)
spill3_power_small

# Power plot
spill3_power_curve <- tibble(
  n_total = c(40, 60, 80, 104),
  power = c(.95, 1, 1, 1),
  lower = c(.8872, .9638, .9638, .9638),
  upper = c(.9836, 1.000, 1.000, 1.000)
)

spill3_power_plot <- ggplot(spill3_power_curve, aes(x = n_total, y = power)) +
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 2
  ) +
  geom_line() +
  geom_point(size = 3) +
  geom_hline(yintercept = .80, linetype = "dashed") +
  geom_hline(yintercept = .90, linetype = "dashed") +
  geom_hline(yintercept = .05, linetype = "dotted") +
  scale_y_continuous(
    labels = scales::label_percent(),
    breaks = seq(.75, 1, by = .05)
  ) +
  coord_cartesian(ylim = c(.75, 1)) +
  scale_x_continuous(breaks = c(40, 60, 80, 104)) +
  labs(
    x = "Number of participants",
    y = "Estimated power",
    subtitle = "Spill3: plausibility β = 0.04649; α = .05",
    caption = "100 simulations per sample size; bars show 95% Monte Carlo intervals."
  ) +
  theme_classic()

print(spill3_power_plot)

ggsave("spill3_power_plot.png",spill3_power_plot,
       width = 10, height = 6, units = "in", dpi= 300)


