# Data analysis adapted from Jiang & Filik (2025)
library(tidyverse)
library(lmerTest)
library(lme4)
library(rempsyc)

full_data <- read_csv("/Users/lumikang/analysis_data.csv")
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
