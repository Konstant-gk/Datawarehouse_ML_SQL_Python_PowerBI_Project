import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, roc_curve, accuracy_score, confusion_matrix, f1_score, precision_score, recall_score, precision_recall_curve
from sklearn.model_selection import train_test_split, StratifiedKFold, GridSearchCV, learning_curve
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
import warnings

# Load the data
df = pd.read_csv('Chinook_Employee_Joins_Aggregated_Nums.csv')

# Inspect data
print(df.columns, "\n")

# Convert 'Employee_HireDate' to a datetime object
df['Employee_HireDate'] = pd.to_datetime(df['Employee_HireDate'])

# Calculate tenure in years
current_date = pd.Timestamp.now()
df['Tenure'] = (current_date - df['Employee_HireDate']).dt.days / 365


# Format AvgRevenue to 2 decimal places
df['AvgRevenue'] = df['AvgRevenue'].round(2)

# Fill any remaining NaN values with 0
df[['TotalRevenue', 'AvgRevenue', 'ReportsTo']] = df[['TotalRevenue', 'AvgRevenue', 'ReportsTo']].fillna(0)
# df = df.dropna()

# Calculate the total average per year (TotalRevenue / Tenure)
df['AnnualRevenue'] = (df['TotalRevenue'] / df['Tenure']).round(2)

# Round tenure to the nearest integer
df[['Tenure', 'ReportsTo']] = df[['Tenure', 'ReportsTo']].round().astype(int)

# Create a boxplot for 'TotalRevenue'
plt.figure(figsize=(10, 6))
sns.boxplot(x=df['TotalRevenue'])
plt.title('Boxplot of Employees')
plt.xlabel('TotalRevenue')
plt.show()

# Remove outliers where 'Employee_Role' is not 'Sales Support Agent' and employeeId is 3,4,5
df2 = df[df['Employee_Role'] == 'Sales Support Agent']
df3 = df2[~df2['EmployeeId'].isin([3, 4, 5])]

features = ['EmployeeId', 'Employee_Age', 'Tenure',
            'TotalInvoices', 'TotalRevenue', 'AvgRevenue', 'AnnualRevenue']

# plt.figure(figsize=(10, 8))
sns.heatmap(df3[features].corr(), annot=True, cmap="coolwarm")
plt.title("Correlation Heatmap")
plt.show()

# Create a new DataFrame with only the required features
df4 = df3[features]

# Ensure df_final is a proper copy of the DataFrame
print(df4['TotalRevenue'].value_counts())
df_final = df4.copy()

# Define performance labels based on quantiles of 'TotalRevenue'
quantile_labels = ['Low Performer', 'Average Performer', 'High Performer']
df_final['Performance_Label'] = pd.qcut(df_final['TotalRevenue'], q=3, labels=quantile_labels, duplicates='drop')

# Create a dictionary to map labels to desired numbers
label_mapping = {'Low Performer': 0, 'Average Performer': 1, 'High Performer': 2}

# Map labels to numbers
df_final['Performance_Label_Encoded'] = df_final['Performance_Label'].map(label_mapping)

# Display the first few rows of the filtered DataFrame
print(df_final.head())

# Define X (features) and y (target)
X = df_final[['TotalInvoices', 'AvgRevenue', 'AnnualRevenue']]
y = df_final['Performance_Label_Encoded']

# Normalize the features using StandardScaler
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Create a new DataFrame with the normalized data
X_scaled_df = pd.DataFrame(X_scaled, columns=X.columns)

# Optionally, join this DataFrame back to the original or show it separately
print(X_scaled_df)
X_scaled_df.hist(figsize=(12, 8), bins=20, grid=False)
plt.suptitle('Histogram of Normalized Features')
plt.show()

# Stratified K-Fold Cross-Validation with GridSearchCV
models = {
    "SVM": (SVC(random_state=42), {'C': [0.1, 1, 10], 'kernel': ['linear', 'rbf']}),
    "Logistic Regression": (LogisticRegression(random_state=42), {'C': [0.1, 1, 10]}),
    "Decision Tree": (DecisionTreeClassifier(random_state=42), {'max_depth': [None, 10, 20]}),
    "Random Forest": (RandomForestClassifier(random_state=42), {'n_estimators': [50, 100, 200]}),
    "KNN": (KNeighborsClassifier(), {'n_neighbors': [3, 5, 7]})
}

skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
best_estimators = {}

for model_name, (model, param_grid) in models.items():
    print(f"Performing GridSearchCV for {model_name}...")
    grid_search = GridSearchCV(model, param_grid, scoring='accuracy', cv=skf, n_jobs=-1)
    grid_search.fit(X_scaled, y)
    best_estimators[model_name] = grid_search.best_estimator_
    print(f"Best parameters for {model_name}: {grid_search.best_params_}")

# Train-Test-Validation Split (80%-10%-10%)
X_train, X_temp, y_train, y_temp = train_test_split(X_scaled, y, test_size=0.2, stratify=y, random_state=42)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, stratify=y_temp, random_state=42)

# Get value counts of 'Performance_Label_Encoded'
value_counts = df_final['Performance_Label_Encoded'].value_counts()

# Extract model names and hyperparameters
model_names = list(models.keys())
hyperparameters = [", ".join(f"{k}={v}" for k, v in params.items()) for _, params in models.values()]

# Plot model initialization
plt.figure(figsize=(10, 6))
plt.barh(model_names, [len(params) for _, params in models.values()])
plt.title('Models and Number of Hyperparameters')
plt.xlabel('Number of Hyperparameters')
plt.ylabel('Model')
plt.gca().xaxis.get_major_locator().set_params(integer=True)
plt.show()

plt.figure(figsize=(10, 6))
sns.boxplot(data=pd.DataFrame(X_train, columns=X.columns))
plt.title('Boxplot of Normalized Training Features')
plt.xlabel('Features')
plt.ylabel('Normalized Values')
plt.xticks(rotation=45)
plt.show()

# Create a bar plot
plt.figure(figsize=(8, 6))
value_counts.plot(kind='bar')
plt.title('Distribution of Performance Label Encoded')
plt.xlabel('Performance Label Encoded')
plt.ylabel('Count')
plt.xticks(rotation=0)
plt.show()

# Train and Evaluate Models and perform confusion matrix
for model_name, model in best_estimators.items():
    print(f"\nEvaluating {model_name}...")
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    cm = confusion_matrix(y_test, y_pred)
    plt.figure(figsize=(6, 4))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=quantile_labels, yticklabels=quantile_labels)
    plt.title(f"Confusion Matrix for {model_name}")
    plt.xlabel("Predicted")
    plt.ylabel("Actual")
    plt.show()

    # Metrics
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='weighted')
    recall = recall_score(y_test, y_pred, average='weighted')
    f1 = f1_score(y_test, y_pred, average='weighted')

    # Print metrics
    print("\n"f"Accuracy: {accuracy:.3f}")
    print(f"Precision: {precision:.3f}")
    print(f"Recall: {recall:.3f}")
    print(f"F1 Score: {f1:.3f}")

    # Classification Report
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))

    # Feature Importance (for tree-based models)
    if hasattr(model, "feature_importances_"):
        feature_importances = model.feature_importances_
        plt.figure(figsize=(8, 6))
        sns.barplot(x=feature_importances, y=X.columns)
        plt.title(f"Feature Importance for {model_name}")
        plt.xlabel("Importance")
        plt.ylabel("Feature")
        plt.show()

    if hasattr(model, "predict_proba"):  # Ensure model supports probability predictions
        y_pred_proba = model.predict_proba(X_test)
        precision, recall, _ = precision_recall_curve(y_test, y_pred_proba[:, 1], pos_label=2)

        plt.figure(figsize=(8, 6))
        plt.plot(recall, precision, label=f"{model_name}")
        plt.title(f"Precision-Recall Curve for {model_name}")
        plt.xlabel("Recall")
        plt.ylabel("Precision")
        plt.legend(loc="upper right")
        plt.show()

# for model_name, model in best_estimators.items()
    train_sizes, train_scores, test_scores = learning_curve(model, X_scaled, y, cv=5, scoring='accuracy')
    plt.figure(figsize=(8, 6))
    plt.plot(train_sizes, train_scores.mean(axis=1), label="Training Score")
    plt.plot(train_sizes, test_scores.mean(axis=1), label="Validation Score")
    plt.title(f"Learning Curve for {model_name}")
    plt.xlabel("Training Size")
    plt.ylabel("Accuracy")
    plt.legend(loc="best")
    plt.show()

# Pair Plot
sns.pairplot(df_final[['Employee_Age', 'TotalInvoices', 'AvgRevenue', 'Performance_Label_Encoded', 'Performance_Label']], hue="Performance_Label", diag_kind="kde", palette="viridis")
plt.title("")
plt.show()


