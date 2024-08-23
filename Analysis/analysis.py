import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Load the dataset from the specific sheet "Cleaned dataset"
dataset_path = '../Dataset/Updated_Dataset.xlsx'
df = pd.read_excel(dataset_path, sheet_name='Cleaned dataset')

# Remove the outlier rows: 1st row (index 0), 10th row (index 9), and 14th row (index 13)
df_cleaned = df.drop([0, 9, 13])

# Reset the index after dropping rows, starting from 1
df_cleaned.reset_index(drop=True, inplace=True)
df_cleaned.index += 1

# Transform Age Group column
def transform_age_group(age_group):
    if pd.isna(age_group):
        return np.nan
    if '+' in age_group:
        min_age = int(age_group.replace('+', '').strip())
        return f"{min_age}-"
    min_age, max_age = map(int, age_group.split('-'))
    return f"{min_age}-{max_age}"

df_cleaned['Age Group'] = df_cleaned['Age Group'].apply(transform_age_group)

# Convert Duration, Registration fee, and Course fee columns to numeric
df_cleaned['Duration'] = pd.to_numeric(df_cleaned['Duration'], errors='coerce')
df_cleaned['Registration fee'] = pd.to_numeric(df_cleaned['Registration fee'], errors='coerce')
df_cleaned['Course fee'] = pd.to_numeric(df_cleaned['Course fee'], errors='coerce')

# Replace "NA" with NaN in both text and numeric columns
df_cleaned.replace("NA", np.nan, inplace=True)

# Display only the necessary columns, ensuring no extra NaN values
columns_to_display = ['Course name', 'Age Group', 'Features', 'Duration', 'Registration fee', 'Course fee', 'Payment Method for course fee', 'Delivery method']
#print(df_cleaned[columns_to_display])
 
# 1. Demographic Insight
  
# Extract minimum and maximum ages from the 'Age Group' column
df_cleaned['Min_Age'] = df_cleaned['Age Group'].str.extract(r'(\d+)', expand=False).astype(float)
df_cleaned['Max_Age'] = df_cleaned['Age Group'].str.extract(r'(\d+)\+?-(\d+)', expand=False)[1].fillna(df_cleaned['Min_Age']).astype(float)

# Get summary statistics for minimum and maximum ages
min_age_summary = df_cleaned['Min_Age'].describe()
max_age_summary = df_cleaned['Max_Age'].describe()

# Print the summary statistics
print("Summary statistics for Minimum Age:")
print(min_age_summary)
print("\nSummary statistics for Maximum Age:")
print(max_age_summary)


# Add a numeric label for each course
df_cleaned['Course_Number'] = df_cleaned.index + 1

# Determine the most common age range
most_common_min = df_cleaned['Min_Age'].mode().iloc[0]
most_common_max = df_cleaned['Max_Age'].mode().iloc[0]

# Create the plot
plt.figure(figsize=(10, 6))

# Highlight the most common age range
plt.fill_betweenx(y=[most_common_min, most_common_max], x1=0, x2=len(df_cleaned)+1, color="lightblue", alpha=0.2, label="Most Common Age Range")

# Line range from Min_Age to Max_Age for each course
plt.vlines(df_cleaned['Course_Number'], df_cleaned['Min_Age'], df_cleaned['Max_Age'], color="blue", lw=2)

# Points for Min_Age and Max_Age
plt.scatter(df_cleaned['Course_Number'], df_cleaned['Min_Age'], color="green", s=50, label="Min Age")
plt.scatter(df_cleaned['Course_Number'], df_cleaned['Max_Age'], color="red", s=50, label="Max Age")

# Horizontal lines at most common Min_Age and Max_Age
plt.axhline(most_common_min, color="black", linestyle="dashed", lw=1)
plt.axhline(most_common_max, color="black", linestyle="dashed", lw=1)

# Labels for most common Min_Age and Max_Age
plt.text(len(df_cleaned)+0.5, most_common_min, f"Min: {most_common_min}", color="purple", va="center")
plt.text(len(df_cleaned)+0.5, most_common_max, f"Max: {most_common_max}", color="purple", va="center")

# Labels and formatting
plt.xlabel("Course Number")
plt.ylabel("Age Range")
plt.title("Age Distribution of Coding Courses")
plt.xticks(df_cleaned['Course_Number'], rotation=90)
plt.legend()
plt.gca().invert_yaxis()
#plt.show()

#2.Curriculam And Features Insight

# Split Features into individual items
features_split = df_cleaned['Features'].str.split(', ', expand=True).stack()
features_df = pd.DataFrame(features_split, columns=['Feature'])
features_count = features_df['Feature'].value_counts().reset_index()
features_count.columns = ['Feature', 'Count']

# Get the top 12 most common features
top_features = features_count.head(12)

# Plot the top 12 most common features
plt.figure(figsize=(10, 8))
sns.barplot(x='Count', y='Feature', data=top_features, palette='Blues_d')

# Add labels to bars
for index, value in enumerate(top_features['Count']):
    plt.text(value, index, str(value), va='center', ha='left', fontsize=10)

plt.xlabel('Count')
plt.ylabel('Features')
plt.title('Top 12 Most Common Features in Coding Courses')
#plt.show()

# Count the frequency of each feature
feature_count = features_count

# Identify unique features (appearing only once)
unique_features = feature_count[feature_count['Count'] == 1]

# Print unique features
print("Unique Features:")
print(unique_features)


# 3.Price Insight

# Calculate the hourly rate per course
df_cleaned['Hourly Rate (LKR)'] = df_cleaned['Course fee'] / df_cleaned['Duration']

# Plotting the hourly rate to gain insights
plt.figure(figsize=(12, 8))
sns.barplot(x='Course name', y='Hourly Rate (LKR)', data=df_cleaned)
plt.xticks(rotation=90)
plt.title('Hourly Rate per Course')
plt.xlabel('Course Name')
plt.ylabel('Hourly Rate (LKR)')
plt.tight_layout()
#plt.show()

 # Calculate the average hourly rate
average_hourly_rate = df_cleaned['Hourly Rate (LKR)'].mean()

# Print the average hourly rate
#print(f"The average hourly rate for the courses is: {average_hourly_rate:.2f} LKR")

# Replace 'NA' values with 0 and convert to numeric
df_cleaned['Registration fee'] = pd.to_numeric(df_cleaned['Registration fee'], errors='coerce').fillna(0)
df_cleaned['Course fee'] = pd.to_numeric(df_cleaned['Course fee'], errors='coerce').fillna(0)

# Histogram of Registration Fees
plt.figure(figsize=(10, 6))
sns.histplot(df_cleaned['Registration fee'], bins=30, color='skyblue', edgecolor='black')
plt.xlabel('Registration Fee (LKR)')
plt.ylabel('Count')
plt.title('Distribution of Registration Fees')
plt.xscale('linear')
plt.yscale('linear')
#plt.show()

# Histogram of Course Fees
plt.figure(figsize=(10, 6))
sns.histplot(df_cleaned['Course fee'], bins=30, color='lightgreen', edgecolor='black')
plt.xlabel('Course Fee (LKR)')
plt.ylabel('Count')
plt.title('Distribution of Course Fees')
plt.xscale('linear')
plt.yscale('linear')
#plt.show()

# Filter out zero values for summary statistics
non_zero_reg_fees = df_cleaned['Registration fee'][df_cleaned['Registration fee'] > 0]
non_zero_course_fees = df_cleaned['Course fee'][df_cleaned['Course fee'] > 0]

# Calculate summary statistics for Registration Fees
max_reg_fee = non_zero_reg_fees.max()
min_reg_fee = non_zero_reg_fees.min()
common_reg_fee_range = f"{non_zero_reg_fees.quantile(0.25):,.0f} - {non_zero_reg_fees.quantile(0.75):,.0f}"

# Calculate summary statistics for Course Fees
max_course_fee = non_zero_course_fees.max()
min_course_fee = non_zero_course_fees.min()
common_course_fee_range = f"{non_zero_course_fees.quantile(0.25):,.0f} - {non_zero_course_fees.quantile(0.75):,.0f}"

# Create a summary statistics table
summary_stats = pd.DataFrame({
    'Statistic': ['Max', 'Min', 'Common Range (25th-75th Percentile)'],
    'Registration Fees': [f"{max_reg_fee:,.0f}", f"{min_reg_fee:,.0f}", common_reg_fee_range],
    'Course Fees': [f"{max_course_fee:,.0f}", f"{min_course_fee:,.0f}", common_course_fee_range]
})

#print("Summary Statistics for Registration and Course Fees (excluding zeros):")
#print(summary_stats)

# 4. Duration Insight

# Convert 'Duration' to numeric
df_cleaned['Duration'] = pd.to_numeric(df_cleaned['Duration'], errors='coerce')

# Summary statistics for course duration
duration_summary = df_cleaned['Duration'].describe()
print("Summary Statistics for Course Duration:")
print(duration_summary)


# Bar plot for course duration by course name
plt.figure(figsize=(12, 8))
sns.barplot(data=df_cleaned, y='Course name', x='Duration')
plt.xlabel('Duration (hours)')
plt.ylabel('Course Name')
plt.title('Course Duration for Each Course')
#plt.show()

# Box plot for distribution of course durations
plt.figure(figsize=(10, 6))
sns.boxplot(x=df_cleaned['Duration'], color='lightblue')
plt.xlabel('Duration (hours)')
plt.title('Distribution of Course Durations')
#plt.show()

# Scatter plot with regression line
plt.figure(figsize=(10, 6))
sns.scatterplot(data=df_cleaned, x='Duration', y='Course fee', color='darkgreen')
sns.regplot(data=df_cleaned, x='Duration', y='Course fee', scatter=False, color='red')
plt.xlabel('Duration (hours)')
plt.ylabel('Course Fee (LKR)')
plt.title('Course Duration vs Course Fee')
#plt.show()

# Box plot for course duration by delivery method
plt.figure(figsize=(12, 8))
sns.boxplot(data=df_cleaned, x='Delivery method', y='Duration', palette='Set2')
plt.xlabel('Delivery Method')
plt.ylabel('Duration (hours)')
plt.title('Course Duration by Delivery Method')
#plt.show()

# 5.Delivery Method Insight

# Count courses by delivery method
delivery_count = df_cleaned['Delivery method'].value_counts()

# Create a pie chart
plt.figure(figsize=(8, 8))
plt.pie(delivery_count, labels=delivery_count.index, autopct='%1.1f%%', colors=plt.cm.Paired(range(len(delivery_count))))
plt.title('Distribution of Delivery Methods')
#plt.show()

# Calculate the average course fee by delivery method
avg_fee_by_delivery = df_cleaned.groupby('Delivery method')['Course fee'].mean().reset_index()
avg_fee_by_delivery.columns = ['Delivery method', 'Average Fee']

# Count courses by delivery method (already done above)
delivery_count_df = delivery_count.reset_index()
delivery_count_df.columns = ['Delivery method', 'Number of Courses']

# Merge with the average fee data
delivery_summary = pd.merge(delivery_count_df, avg_fee_by_delivery, on='Delivery method')

# Create a stacked bar chart
plt.figure(figsize=(12, 8))
sns.barplot(data=delivery_summary, x='Delivery method', y='Number of Courses', palette='Set2', hue='Delivery method')

# Add average fee labels
for i in range(len(delivery_summary)):
    plt.text(x=i, y=delivery_summary['Number of Courses'].iloc[i] + 0.5, 
             s=f"Avg Fee: {delivery_summary['Average Fee'].iloc[i]:,.0f}", 
             ha='center', va='bottom')

plt.xlabel('Delivery Method')
plt.ylabel('Number of Courses')
plt.title('Number of Courses and Average Fee by Delivery Method')
plt.legend(title='Delivery Method', bbox_to_anchor=(1.05, 1), loc='upper left')
#plt.show()


#6.Payment Method Insight

# Count the occurrences of each payment method
payment_method_count = df_cleaned['Payment Method for course fee'].value_counts()

# Create a DataFrame for visualization
payment_method_df = payment_method_count.reset_index()
payment_method_df.columns = ['Payment Method', 'Count']

# Create a bar plot for payment methods
plt.figure(figsize=(10, 6))
sns.barplot(data=payment_method_df, x='Payment Method', y='Count', palette='viridis')

# Add labels to the bars
for index, row in payment_method_df.iterrows():
    plt.text(index, row['Count'] + 0.5, row['Count'], ha='center')

plt.xlabel('Payment Method')
plt.ylabel('Count')
plt.title('Distribution of Payment Methods for Course Fees')

# Rotate the x-axis labels and add padding
plt.xticks(rotation=45, ha='right', rotation_mode='anchor')

# Adjust layout to prevent label cut-off
plt.tight_layout()

#plt.show()


# Hypothetical Competitor

# Calculate the average hourly rate for your courses
df_cleaned['Hourly Rate'] = df_cleaned['Course fee'] / df_cleaned['Duration']
avg_hourly_rate_your_courses = df_cleaned['Hourly Rate'].mean()

# Hypothetical competitor data
competitor_data = {
    "Competitor": ["Competitor A"],
    "avg_hourly_rate": [50000 / 40]  # Competitor A's course fee divided by its duration
}

competitor_df = pd.DataFrame(competitor_data)

# Combine your data with competitor data
your_courses_data = pd.DataFrame({
    "Competitor": ["Your Courses"],
    "avg_hourly_rate": [avg_hourly_rate_your_courses]
})

combined_data = pd.concat([your_courses_data, competitor_df]).reset_index(drop=True)

# Plotting comparison for average hourly rates
plt.figure(figsize=(10, 6))
ax = sns.barplot(data=combined_data, x='Competitor', y='avg_hourly_rate', palette='coolwarm')

# Add labels to the bars
for index, row in combined_data.iterrows():
    ax.text(index, row['avg_hourly_rate'] + 20, f"{row['avg_hourly_rate']:,.2f}", ha='center')

plt.xlabel('Competitor')
plt.ylabel('Average Hourly Rate (LKR/hour)')
plt.title('Comparison of Average Hourly Rates')
plt.tight_layout()

plt.show()