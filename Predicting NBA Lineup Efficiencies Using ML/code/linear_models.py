import pandas as pd
from sklearn.model_selection import KFold
from sklearn.linear_model import LinearRegression, Ridge
from sklearn.metrics import r2_score, mean_squared_error


def run_weighted_linear_model(csv_path, top_k=10):
    df = pd.read_csv(csv_path)

    target_col = "PlusMinus"
    minutes_col = "Minutes"

    y = df[target_col]
    weights = df[minutes_col]

    X = df.drop(
        columns=[target_col, minutes_col, "Player", "cluster"],
        errors="ignore"
    )

    model = LinearRegression()
    name = "Weighted Linear Regression"

    kf = KFold(n_splits=5, shuffle=True, random_state=42)

    print(f"\n\nRUNNING 5 fold CV with: {name}")

    r2_scores = []
    mse_scores = []

    for fold, (train_idx, test_idx) in enumerate(kf.split(X), start=1):
        X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
        y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]
        w_train, w_test = weights.iloc[train_idx], weights.iloc[test_idx]

        model.fit(X_train, y_train, sample_weight=w_train)
        y_pred = model.predict(X_test)

        r2 = r2_score(y_test, y_pred, sample_weight=w_test)
        mse = mean_squared_error(y_test, y_pred, sample_weight=w_test)

        r2_scores.append(r2)
        mse_scores.append(mse)

        print("________________")
        print("Fold:", fold)
        print("    R^2:", r2)
        print("    MSE:", mse)

    model.fit(X, y, sample_weight=weights)

    coef_series = pd.Series(
        model.coef_,
        index=X.columns
    ).sort_values()

    print("\n=== Archetypes with strongest NEGATIVE effect ===")
    print(coef_series.head(top_k))

    print("\n=== Archetypes with strongest POSITIVE effect ===")
    print(coef_series.tail(top_k))

    print("\nMean CV R^2:", sum(r2_scores) / len(r2_scores))
    print("Mean CV MSE:", sum(mse_scores) / len(mse_scores))


if __name__ == "__main__":
    run_weighted_linear_model(
        "data/24-25/lineup/24-25_clusters_histogram.csv",
    )
    # run_weighted_linear_model(
    #     "data/25-26/lineup/25-26_clusters_histogram.csv",
    # )
