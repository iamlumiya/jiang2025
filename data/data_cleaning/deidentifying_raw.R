# Removing Personal Identifiable Infos from raw data

# Use the latest cumulative PCIbex export.
input_file <- "/Users/lumikang/Documents/GitHub/-replication/data/pilot_results/results_prod.csv"
output_file <- "results_deidentified.csv"

if (!file.exists(input_file)) {
  stop("Input file not found: ", input_file)
}

lines <- readLines(input_file, warn = FALSE, encoding = "UTF-8")

# Remove header lines that contain the export date and time.
lines <- lines[!grepl("^\\s*#\\s*Results on\\b", lines, perl = TRUE)]

# Keep the PCIbex column definitions and blank lines.
is_data <- !grepl("^\\s*(#|$)", lines, perl = TRUE)
data_lines <- lines[is_data]

if (!length(data_lines)) {
  stop("No PCIbex data rows found.")
}

# Match fields 1 through 12. Keep fields 2 through 11 and the
# surrounding commas, leaving fields 1 and 12 empty.
timestamp_pattern <- "^[^,]*(,(?:[^,]*,){10})[^,]*(,|$)"

if (!all(grepl(timestamp_pattern, data_lines, perl = TRUE))) {
  stop("At least one data row has fewer than 12 fields.")
}

lines[is_data] <- sub(
  timestamp_pattern,
  "\\1\\2",
  data_lines,
  perl = TRUE
)

# Save a separate copy and print its full path.
writeLines(lines, output_file, useBytes = TRUE)
message("Saved ", length(data_lines), " data rows to ", normalizePath(output_file))
