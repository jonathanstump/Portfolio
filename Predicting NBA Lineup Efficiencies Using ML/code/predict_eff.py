import os
import joblib
import numpy as np
import pandas as pd

from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error


def printScoresRegressor(season, test_r2, test_corr, test_mae, test_rmse, nrows):
    """
    Prints evaluation metrics neatly.
    """
    print("\n\nEVALUATING", season, "season predictions")
    print("________________")
    print("Rows evaluated:", nrows)
    print("    Weighted R^2:", test_r2)
    print("    Weighted Corr:", test_corr)
    print("    Weighted MAE:", test_mae)
    print("    Weighted RMSE:", test_rmse)


def weighted_corr(y_true, y_pred, w):
    """
    Compute weighted Pearson correlation.
    """
    y_true = np.asarray(y_true, dtype=float)
    y_pred = np.asarray(y_pred, dtype=float)
    w = np.asarray(w, dtype=float)

    w_sum = w.sum()
    if w_sum == 0:
        return np.nan

    mu_true = np.sum(w * y_true) / w_sum
    mu_pred = np.sum(w * y_pred) / w_sum

    cov = np.sum(w * (y_true - mu_true) * (y_pred - mu_pred)) / w_sum
    var_true = np.sum(w * (y_true - mu_true) ** 2) / w_sum
    var_pred = np.sum(w * (y_pred - mu_pred) ** 2) / w_sum

    if var_true <= 0 or var_pred <= 0:
        return np.nan

    return cov / np.sqrt(var_true * var_pred)


def load_model(model_path):
    """
    Loads a trained sklearn regressor (model only).
    """
    model = joblib.load(model_path)
    return model


def evaluate_season(
    model,
    feature_cols,
    csv_path,
    target_col="PlusMinus",
    minutes_col="Minutes",
    out_csv_path=None,
    season_label="25-26"
):
    """
    Loads a season lineup CSV, aligns feature columns, predicts efficiency,
    and reports minute-weighted evaluation metrics.

    Optionally writes a CSV with predictions appended.
    """
    df = pd.read_csv(csv_path)

    # Align feature matrix exactly to training
    X = df[feature_cols]
    y = df[target_col]
    minutes = df[minutes_col]

    # Predict
    y_pred = model.predict(X)

    # Weighted metrics
    test_r2 = r2_score(y, y_pred, sample_weight=minutes)
    test_corr = weighted_corr(y, y_pred, minutes)
    test_mae = mean_absolute_error(y, y_pred, sample_weight=minutes)
    test_rmse = mean_squared_error(y, y_pred, sample_weight=minutes, squared=False)

    printScoresRegressor(season_label, test_r2, test_corr, test_mae, test_rmse, len(df))

    # Append predictions
    df["Predicted_" + target_col] = y_pred
    df["Residual"] = y - y_pred

    if out_csv_path is not None:
        os.makedirs(os.path.dirname(out_csv_path) or ".", exist_ok=True)
        df.to_csv(out_csv_path, index=False)
        print("Saved predictions to:", out_csv_path)

    return df, {
        "weighted_r2": test_r2,
        "weighted_corr": test_corr,
        "weighted_mae": test_mae,
        "weighted_rmse": test_rmse,
    }


def main():
    # Update these paths to match your project
    bundle_path = "models/random_forest_regressor.joblib"
    eval_csv_path = "data/25-26/lineup/25-26_names_with_clusters_intermediate.csv"
    out_csv_path = "data/25-26/lineup/25-26_predictions.csv"

    # If your label/target differs, change here
    target_col = "PlusMinus"
    minutes_col = "Minutes"

    model = load_model(bundle_path)
    df = pd.read_csv(eval_csv_path)
    feature_cols = [c for c in df.columns if c not in [target_col, minutes_col]]
    
    evaluate_season(
        model=model,
        feature_cols=feature_cols,
        csv_path=eval_csv_path,
        target_col=target_col,
        minutes_col=minutes_col,
        out_csv_path=out_csv_path,
        season_label="25-26"
    )


if __name__ == "__main__":
    main()
