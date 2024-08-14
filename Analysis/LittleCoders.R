# Load dataset
View(Dataset)

# Remove the 1st, 10th, and 14th rows (empty row and outliers)
Dataset <- Dataset[-c(1, 10, 14), ]

# Check the structure of the modified dataset to ensure the rows have been removed
str(Dataset)

# View the modified dataset
print(Dataset)
View(Dataset)

# 1. Fix the Age Group column
# Split the age group into minimum and maximum age, handle the "+" cases
Dataset$`Age Group` <- gsub("\\s*\\+\\s*", "-Inf", Dataset$`Age Group`)
Dataset$`Age Group` <- gsub("\\s*\\-\\s*", "-", Dataset$`Age Group`)
Dataset$`Age Group` <- ifelse(grepl("-", Dataset$`Age Group`), Dataset$`Age Group`, paste0(Dataset$`Age Group`, "-Inf"))

# 2. Fix the Features column
# Split the features by commas and consider each as individual features
Dataset$Features <- gsub("\\s*,\\s*", ", ", Dataset$Features)

# 3. Fix the Duration column
# Remove the 'hours' part and keep only the numeric value
Dataset$Duration <- as.numeric(gsub(" hours", "", Dataset$Duration))

# 4. Convert Registration Fee and Course Fee columns to numeric
Dataset$`Registration fee` <- as.numeric(Dataset$`Registration fee`)
Dataset$`Course fee` <- as.numeric(Dataset$`Course fee`)

# 5. Ensure the Delivery Method is treated as text
Dataset$`Delivery method` <- as.factor(Dataset$`Delivery method`)

# Check the structure of the transformed dataset to ensure changes are applied correctly
str(Dataset)




#Data Analsis

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(knitr)


# 1.Curriculum & Feature Insight

# Split Features into individual items
feature_list <- Dataset %>%
  separate_rows(Features, sep = ", ") %>%
  count(Features, sort = TRUE)

# Display the most common features
print(feature_list)


# 2.Pricing Insight

# Split Features into individual items and count occurrences
feature_list <- Dataset %>%
  separate_rows(Features, sep = ", ") %>%
  count(Features, sort = TRUE)

# Create a bar chart of the most common features
ggplot(feature_list, aes(x = reorder(Features, n), y = n)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Most Common Features in Coding Courses",
       x = "Features",
       y = "Count") +
  theme_minimal()


# Convert 'NA' to 0  
Dataset$`Registration fee`[Dataset$`Registration fee` == "NA"] <- 0
Dataset$`Course fee`[Dataset$`Course fee` == "NA"] <- 0

# Convert to numeric
Dataset$`Registration fee` <- as.numeric(Dataset$`Registration fee`)
Dataset$`Course fee` <- as.numeric(Dataset$`Course fee`)

# Summary statistics for Registration fee and Course fee
summary(Dataset$`Registration fee`)
summary(Dataset$`Course fee`)


# 3.Duration & Intensity Insight

# Summary statistics for course duration
Dataset$Duration <- as.numeric(Dataset$Duration)
summary(Dataset$Duration)

# Visualize the distribution of course durations
hist(Dataset$Duration, main="Distribution of Course Durations", xlab="Duration (hours)", col="lightblue", breaks=10)

# 4. Delivery Method Insight

# Count courses by delivery method
delivery_count <- Dataset %>%
  count(`Delivery method`, sort = TRUE)

# Display the count of each delivery method
print(delivery_count)

# Analyze the average course fee by delivery method
avg_fee_by_delivery <- Dataset %>%
  group_by(`Delivery method`) %>%
  summarise(average_fee = mean(`Course fee`, na.rm = TRUE))

# Display the average course fee by delivery method
print(avg_fee_by_delivery)

# 6. Market Positioning Insight

# Compare based on price, duration, and features
market_positioning <- Dataset %>%
  summarise(
    avg_duration = mean(Duration, na.rm = TRUE),
    avg_fee = mean(`Course fee`, na.rm = TRUE),
    unique_features = n_distinct(Features)
  )

# Display the market positioning summary
print(market_positioning)

# 7. Demographic Insight

# Split Age Group into min and max age
Dataset <- Dataset %>%
  separate(`Age Group`, into = c("Min_Age", "Max_Age"), sep = "-", convert = TRUE)

# Summary statistics for min and max age
summary(Dataset$Min_Age)
summary(Dataset$Max_Age)

# Visualize the target age groups
hist(Dataset$Min_Age, main="Distribution of Minimum Age", xlab="Minimum Age", col="lightgreen", breaks=10)
hist(Dataset$Max_Age, main="Distribution of Maximum Age", xlab="Maximum Age", col="lightcoral", breaks=10)


# VISUALIZATIONS

# 1. Demographic Insight

# Prepare the data
# Convert Min_Age and Max_Age to numeric if not already
Dataset$Min_Age <- as.numeric(Dataset$Min_Age)
Dataset$Max_Age <- as.numeric(Dataset$Max_Age)

# Add a numeric label for each course
Dataset <- Dataset %>%
  mutate(Course_Number = row_number())

# Determine the most common age range
most_common_min <- as.numeric(names(sort(table(Dataset$Min_Age), decreasing = TRUE)[1]))
most_common_max <- as.numeric(names(sort(table(Dataset$Max_Age), decreasing = TRUE)[1]))

# Create the plot
ggplot(Dataset, aes(x = Course_Number, ymin = Min_Age, ymax = Max_Age)) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = most_common_min, ymax = most_common_max), 
            fill = "lightblue", alpha = 0.2) + # Highlight the most common age range
  geom_linerange(color = "blue", size = 2) + # Create a line range from Min_Age to Max_Age for each course
  geom_point(aes(y = Min_Age), color = "green", size = 3) + # Show the Min_Age as a point
  geom_point(aes(y = Max_Age), color = "red", size = 3) + # Show the Max_Age as a point
  geom_hline(yintercept = most_common_min, linetype = "dashed", color = "purple", size = 1) + # Draw horizontal line at most common Min_Age
  geom_hline(yintercept = most_common_max, linetype = "dashed", color = "purple", size = 1) + 
  # Replace the existing geom_text lines with these:
  geom_text(aes(x = max(Course_Number) + 0.5, y = most_common_min, label = paste("Min:", most_common_min)), 
            color = "purple", vjust = 1.5) +  # Label for minimum age
  geom_text(aes(x = max(Course_Number) + 0.5, y = most_common_max, label = paste("Max:", most_common_max)), 
            color = "purple", vjust = -0.5) + # Label for maximum age
  
  labs(title = "Age Distribution of Coding Courses",
       x = "Course Number",
       y = "Age Range",
       caption = "Green point: Minimum Age, Red point: Maximum Age, Shaded: Most Common Age Range") +
  scale_x_continuous(breaks = Dataset$Course_Number, labels = Dataset$Course_Number) + # Use course numbers as labels
  theme_minimal() +
  coord_flip()  

# 2. Features and Curriculam Insight

# Split Features into individual items and count occurrences
feature_list <- Dataset %>%
  separate_rows(Features, sep = ", ") %>%
  count(Features, sort = TRUE) %>%
  top_n(12, n)

# Create a bar chart of the top 12 most common features with labels
ggplot(feature_list, aes(x = reorder(Features, n), y = n)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  geom_text(aes(label = n), hjust = -0.3, size = 3.5) +  # Add labels to bars
  coord_flip() +
  labs(title = "Top 12 Most Common Features in Coding Courses",
       x = "Features",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(hjust = 1))


# 3. Price Insight

# Replace 'NA' values with 0
Dataset$`Registration fee`[is.na(Dataset$`Registration fee`)] <- 0
Dataset$`Course fee`[is.na(Dataset$`Course fee`)] <- 0

# Convert to numeric
Dataset$`Registration fee` <- as.numeric(Dataset$`Registration fee`)
Dataset$`Course fee` <- as.numeric(Dataset$`Course fee`)


# Histogram of Registration Fees with formatted axis values
ggplot(Dataset, aes(x = `Registration fee`)) +
  geom_histogram(binwidth = 1000, fill = "skyblue", color = "black") +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Distribution of Registration Fees", x = "Registration Fee (LKR)", y = "Count") +
  theme_minimal()

# Histogram of Course Fees with formatted axis values
ggplot(Dataset, aes(x = `Course fee`)) +
  geom_histogram(binwidth = 5000, fill = "lightgreen", color = "black") +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Distribution of Course Fees", x = "Course Fee (LKR)", y = "Count") +
  theme_minimal()

# Filter out zero values for summary statistics
non_zero_reg_fees <- Dataset$`Registration fee`[Dataset$`Registration fee` > 0]
non_zero_course_fees <- Dataset$`Course fee`[Dataset$`Course fee` > 0]

# Calculate summary statistics for Registration Fees
max_reg_fee <- max(non_zero_reg_fees, na.rm = TRUE)
min_reg_fee <- min(non_zero_reg_fees, na.rm = TRUE)
common_reg_fee_range <- paste0(
  quantile(non_zero_reg_fees, probs = 0.25, na.rm = TRUE), 
  " - ", 
  quantile(non_zero_reg_fees, probs = 0.75, na.rm = TRUE)
)

# Calculate summary statistics for Course Fees
max_course_fee <- max(non_zero_course_fees, na.rm = TRUE)
min_course_fee <- min(non_zero_course_fees, na.rm = TRUE)
common_course_fee_range <- paste0(
  quantile(non_zero_course_fees, probs = 0.25, na.rm = TRUE), 
  " - ", 
  quantile(non_zero_course_fees, probs = 0.75, na.rm = TRUE)
)

# Create a summary statistics table
summary_stats <- data.frame(
  Statistic = c("Max", "Min", "Common Range (25th-75th Percentile)"),
  Registration_Fees = c(max_reg_fee, min_reg_fee, common_reg_fee_range),
  Course_Fees = c(max_course_fee, min_course_fee, common_course_fee_range)
)

# Print summary statistics table
kable(summary_stats, caption = "Summary Statistics for Registration and Course Fees (excluding zeros)")


# 4. Duration Insight

#Distribution of Course Duration
boxplot(Dataset$Duration, 
        main = "Distribution of Course Durations", 
        ylab = "Duration (hours)", 
        col = "lightblue")

#Correlation between Duration and Course Fee

plot(Dataset$Duration, Dataset$`Course fee`, 
     main = "Course Duration vs Course Fee",
     xlab = "Duration (hours)", 
     ylab = "Course Fee (LKR)", 
     col = "darkgreen", pch = 16)
abline(lm(Dataset$`Course fee` ~ Dataset$Duration), col="red")

# Comparison by Delivery Method

ggplot(Dataset, aes(x = `Delivery method`, y = Duration)) +
  geom_boxplot(aes(fill = `Delivery method`)) +
  labs(title = "Course Duration by Delivery Method", y = "Duration (hours)") +
  theme_minimal()

# Intensity Analysis
ggplot(Dataset, aes(x = reorder(`Course name`, Duration), y = Duration)) +
  geom_bar(stat = "identity", fill = "lightcoral") +
  coord_flip() +
  labs(title = "Course Duration for Each Course", x = "Course Name", y = "Duration (hours)") +
  theme_minimal()

# Highlight Courses with Extreme Durations
ggplot(Dataset, aes(x = reorder(`Course name`, Duration), y = Duration)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  geom_text(aes(label = ifelse(Duration == max(Duration) | Duration == min(Duration), `Course name`, "")),
            hjust = -0.1, vjust = 0.5, size = 3, color = "red") +
  coord_flip() +
  labs(title = "Course Duration with Annotations", x = "Course Name", y = "Duration (hours)") +
  theme_minimal()

# 5. Delivery method

# Count courses by delivery method
delivery_count <- Dataset %>%
  count(`Delivery method`)

# Create a pie chart
ggplot(delivery_count, aes(x = "", y = n, fill = `Delivery method`)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(title = "Distribution of Delivery Methods", x = "", y = "") +
  theme_void() +
  theme(legend.title = element_blank())

# Calculate the average course fee by delivery method
avg_fee_by_delivery <- Dataset %>%
  group_by(`Delivery method`) %>%
  summarise(average_fee = mean(`Course fee`, na.rm = TRUE))

# Merge with the count data
delivery_summary <- left_join(delivery_count, avg_fee_by_delivery, by = "Delivery method")

# Create a stacked bar chart
ggplot(delivery_summary, aes(x = `Delivery method`, y = n, fill = `Delivery method`)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste0("Avg Fee: ", round(average_fee, 0))), vjust = -0.5) +
  labs(title = "Number of Courses and Average Fee by Delivery Method", x = "Delivery Method", y = "Number of Courses") +
  theme_minimal() +
  theme(legend.position = "none")

# 7. Market Positioning Insight

# Calculate Average Pricing and Duration
# Summarize average course fee and duration
market_positioning <- Dataset %>%
  summarise(
    avg_duration = mean(Duration, na.rm = TRUE),
    avg_fee = mean(`Course fee`, na.rm = TRUE),
    count_courses = n()
  )

# Print the summary
print(market_positioning)

# Count the frequency of each feature
feature_count <- Dataset %>%
  separate_rows(Features, sep = ", ") %>%
  count(Features, sort = TRUE)

# Print the most common features
print(feature_count)

# Identify unique features (appearing only once)
unique_features <- feature_count %>%
  filter(n == 1)

# Print unique features
print(unique_features)

# 7. HYpothetical Competitor

# Hypothetical competitor data (replace with actual data if available)
competitor_data <- tibble(
  Competitor = c("Competitor A"),
  avg_fee = c(50000),
  avg_duration = c(40)
)

# Combine the data with competitor data
combined_data <- bind_rows(
  tibble(Competitor = "Your Courses", avg_fee = market_positioning$avg_fee, avg_duration = market_positioning$avg_duration),
  competitor_data
)


