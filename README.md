# Replicating Jiang & Filik (2025), Experiment 2

This UC San Diego replication project asks whether a dream context changes how readers process events that are implausible in the real world. It recreates Experiment 2 of Jiang and Filik (2025) as an online, word-by-word self-paced reading task in PCIbex. The repository contains the experiment, pilot data, R scripts, and a replication report in progress.

## Study design

The study crosses **context** (realistic vs. dream) with **event plausibility** (plausible vs. implausible). Participants press the space bar to reveal one word at a time and answer occasional true/false comprehension questions. The stimulus file contains four counterbalanced lists, each with 24 critical trials, 60 fillers, and 29 comprehension questions.

Reading times are examined at the critical word and the next five words (Spill1–Spill5). The [analysis plan](writeup/Replication%20Report%20Template.qmd) specifies the main effect of plausibility at Spill3 as the primary outcome and examines the same effect at Spill2. The context-by-plausibility interaction at Spill5 is a planned secondary outcome that tests whether the plausibility effect differs between realistic and dream contexts at the end of the sentence. The current pilot model script fits the Spill2 and Spill3 models.

## Repository contents

| Path | Contents |
| --- | --- |
| [`data/PCI_bex/`](data/PCI_bex/) | PCIbex experiment code, instructions, practice trials, and [stimulus lists](data/PCI_bex/chunk_includes/experiment_full.csv). |
| [`data/pilot_results/`](data/pilot_results/) | Pilot PCIbex export, participant summaries, processed reading times, and model tables. |
| [`data/data_cleaning/`](data/data_cleaning/) | R scripts for summarizing comprehension accuracy and preparing word-level reading times. |
| [`data/data_analysis/`](data/data_analysis/) | Mixed-effects models for pilot reading times at Spill2 and Spill3. |
| [`data/visualization/`](data/visualization/) | Scripts and figures showing reading times across conditions and word positions. |
| [`data/power_analysis/`](data/power_analysis/) | Simulation-based power analysis and figures for Spill2 and Spill3 using the original study data. |
| [`original_paper/`](original_paper/) | Original article, Experiment 2 materials, data, and analysis code. |
| [`writeup/`](writeup/) | Quarto source and rendered versions of the replication report. |

## Working with the pilot data

Open the repository root as your R working directory. Install the packages used by the scripts if needed.

```r
install.packages(c("tidyverse", "lme4", "lmerTest", "rempsyc", "simr"))
```

The scripts currently contain machine-specific input paths. Replace them with paths from your checkout before running the scripts.

1. In [`demographics.R`](data/data_cleaning/demographics.R), set `files` to `"data/pilot_results/results_prod-3.csv"`. Run the script to generate `demographics.csv` in your working directory.
2. In [`data_prep.R`](data/data_cleaning/data_prep.R), use the same raw export for `files` and set `demographics_file` to the CSV from step 1. The script keeps sessions with at least 80% comprehension accuracy, extracts the six word positions, and applies the 100–5,000 ms and 2.5 SD reading-time filters. It writes `analysis_data.csv` to your working directory by default.
3. In [`analysis.R`](data/data_analysis/analysis.R) and the [plotting scripts](data/visualization/), point the input to the CSV from step 2. To start with the processed pilot data already in the repository, use [`data/pilot_results/analysis_data.csv`](data/pilot_results/analysis_data.csv) and begin here. Both plotting scripts save to `plot.png` by default, so give them distinct output filenames if you want to keep both figures.

To run the power simulations, set the input in [`jiang_power.R`](data/power_analysis/jiang_power.R) to `"original_paper/data/rawdata.csv"`.

## Original study

Jiang, C., & Filik, R. (2025). Expecting the unexpected: Examining the interplay between real-world knowledge and contextual cues during language comprehension. *Memory & Cognition, 53*, 1888–1908. [https://doi.org/10.3758/s13421-025-01689-x](https://doi.org/10.3758/s13421-025-01689-x)
