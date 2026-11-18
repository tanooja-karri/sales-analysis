import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


def clean_dataset(file_path, outlier_cols=None, factor=1.5,
                  drop_duplicates=False, bins=50):

    # 1. Load dataset
    df = pd.read_csv(file_path)

    print("DATASET LOADED SUCCESSFULLY")
    print("-" * 50)

    # 2. Initial exploration
    print("\nDataset Shape:", df.shape)

    print("\nFirst 5 Rows:")
    print(df.head())

    print("\nData Types:")
    print(df.dtypes)

    print("\nMissing Values:")
    print(df.isnull().sum())

    print("\nDuplicate Rows:")
    print(df.duplicated().sum())

    print("\nNumerical Summary:")
    print(df.describe())

    print("\nCategorical Summary:")
    print(df.describe(include="object"))

    # 3. Remove duplicates (optional)
    if drop_duplicates:
        before = len(df)
        df = df.drop_duplicates().copy()
        print(f"\nDuplicates Removed: {before - len(df)}")

    # 4. Plot original distributions
    numeric_cols = df.select_dtypes(include="number").columns.tolist()

    if numeric_cols:
        ncols = 2
        nrows = (len(numeric_cols) + ncols - 1) // ncols

        fig, axes = plt.subplots(
            nrows, ncols,
            figsize=(12, 4 * nrows)
        )

        axes = axes.flatten() if hasattr(axes, "flatten") else [axes]

        for ax, col in zip(axes, numeric_cols):
            sns.histplot(data=df, x=col, bins=bins, ax=ax)
            ax.set_title(f"Original Distribution of {col}")

        for ax in axes[len(numeric_cols):]:
            ax.set_visible(False)

        plt.tight_layout()
        plt.show()

    # 5. Remove outliers using IQR
    if outlier_cols is None:
        outlier_cols = []

    for col in outlier_cols:

        if col not in df.columns:
            print(f"\n{col}: Column not found")
            continue

        if not pd.api.types.is_numeric_dtype(df[col]):
            print(f"\n{col}: Not a numeric column")
            continue

        values = df[col].dropna()

        if values.empty:
            print(f"\n{col}: No valid values")
            continue

        Q1 = values.quantile(0.25)
        Q3 = values.quantile(0.75)

        IQR = Q3 - Q1

        lower = Q1 - factor * IQR
        upper = Q3 + factor * IQR

        before = len(df)

        df = df[
            df[col].isna() |
            df[col].between(lower, upper)
        ].copy()

        print(f"\n{col}:")
        print("Lower Bound:", lower)
        print("Upper Bound:", upper)
        print("Rows Removed:", before - len(df))

    # 6. Plot cleaned distributions
    if numeric_cols:

        valid_cols = [col for col in numeric_cols if col in df.columns]

        if valid_cols:
            nrows = (len(valid_cols) + 1) // 2

            fig, axes = plt.subplots(
                nrows, 2,
                figsize=(12, 4 * nrows)
            )

            axes = axes.flatten() if hasattr(axes, "flatten") else [axes]

            for ax, col in zip(axes, valid_cols):
                sns.histplot(data=df, x=col, bins=bins, ax=ax)
                ax.set_title(f"Cleaned Distribution of {col}")

            for ax in axes[len(valid_cols):]:
                ax.set_visible(False)

            plt.tight_layout()
            plt.show()

    # 7. Final summary
    print("\nFINAL CLEANING SUMMARY")
    print("-" * 50)

    print("Final Shape:", df.shape)
    print("Remaining Missing Values:")
    print(df.isnull().sum())

    print("\nRemaining Duplicates:", df.duplicated().sum())

    # 8. Return cleaned dataset
    return df 