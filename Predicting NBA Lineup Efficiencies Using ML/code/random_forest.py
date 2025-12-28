import pandas as pd
from sklearn.model_selection import GridSearchCV, KFold
from sklearn.ensemble import RandomForestRegressor
import numpy as np
from sklearn.model_selection import KFold
import joblib
from sklearn.metrics import mean_squared_error

def printScoresRegressor(learner, fold, params, test_score, tuning_score, test_mse, nsplits):
    """
    Prints regression metrics for each fold neatly.
    """
    if fold == 1:
        print("\n\nRUNNING", nsplits, "fold CV with:", learner.__class__.__name__)
    print("________________")
    print("Fold:", fold)
    print("    Best Parameters:", params)
    print("    Test Score (R^2):", test_score)
    print("    Test MSE:", test_mse)
    print("    Tuning CV Score (R^2):", tuning_score)

def runTuneTestRegressor(learner, parameters, X, y, minutes):
    """
    Runs grid search on each fold of the dataset and prints fold-level results.
    """
    nsplits = 5
    kf = KFold(n_splits=nsplits, shuffle=True, random_state=42)
    fold_scores = []

    for i, (train_idx, test_idx) in enumerate(kf.split(X), start=1):
        X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
        y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]

        grid = GridSearchCV(estimator=learner, param_grid=parameters, cv=3, scoring='r2')
        train_weights = minutes.iloc[train_idx]
        test_weights = minutes.iloc[test_idx]

        grid.fit(X_train, y_train, sample_weight=train_weights)
        best_model = grid.best_estimator_
        y_pred = best_model.predict(X_test)

        test_score = best_model.score(
            X_test,
            y_test,
            sample_weight=test_weights
        )

        test_mse = mean_squared_error(
            y_test,
            y_pred,
            sample_weight=test_weights
        )

        fold_scores.append(test_score)

        printScoresRegressor(
            learner,
            i,
            grid.best_params_,
            test_score,
            grid.best_score_,
            test_mse,
            nsplits
        )

    return fold_scores

def evaluate_fixed_model(model, X, y, minutes, nsplits=5):
    """
    Evaluates a fixed model using K-Fold cross-validation and prints weighted R^2 and MSE.
    """
    kf = KFold(n_splits=nsplits, shuffle=True, random_state=42)

    r2_scores = []
    mse_scores = []

    for fold, (train_idx, test_idx) in enumerate(kf.split(X), start=1):
        X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
        y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]
        w_train, w_test = minutes.iloc[train_idx], minutes.iloc[test_idx]

        model.fit(X_train, y_train, sample_weight=w_train)

        y_pred = model.predict(X_test)

        r2 = model.score(X_test, y_test, sample_weight=w_test)
        mse = mean_squared_error(y_test, y_pred, sample_weight=w_test)

        r2_scores.append(r2)
        mse_scores.append(mse)

        print(f"Fold {fold}")
        print(f"    Weighted R^2: {r2:.4f}")
        print(f"    Weighted MSE: {mse:.4f}")

    print("\n===== Cross-validated performance =====")
    print(f"Mean weighted R^2: {np.mean(r2_scores):.4f}")
    print(f"Std  weighted R^2: {np.std(r2_scores, ddof=1):.4f}")
    print(f"Mean weighted MSE: {np.mean(mse_scores):.4f}")
    print(f"Std  weighted MSE: {np.std(mse_scores, ddof=1):.4f}")

    return r2_scores, mse_scores


def runPipelineRegressor(csv_path):
    """
    Runs the full pipeline for Random Forest regression on the given CSV data.
    """
    df = pd.read_csv(csv_path)

    target_col = 'PlusMinus'
    minutes_col = 'Minutes'

    if target_col not in df.columns or minutes_col not in df.columns:
        raise ValueError("Required columns missing.")

    y = df[target_col]
    minutes = df[minutes_col]

    # DROP Minutes from features
    X = df.drop(
        columns=[target_col, minutes_col, 'Player', 'cluster'],
        errors='ignore'
    )

    RF = RandomForestRegressor(n_estimators=325, max_depth=7, min_samples_leaf=2, 
                               max_features="sqrt",random_state=42)
    RF.fit(X,y, sample_weight=minutes)
    joblib.dump(RF, 'models/random_forest_regressor.joblib')
    evaluate_fixed_model(RF, X, y, minutes)
    # runTuneTestRegressor(RF, X, y, minutes)

    return df


def compute_weighted_archetype_effects(
    df,
    target_col="PlusMinus",
    minutes_col="Minutes"
):
    """
    Computes weighted average plus-minus contribution per player archetype,
    weighted by lineup minutes played.

    Returns:
        pd.Series sorted by strongest archetype effect
    """
    cluster_cols = [
        col for col in df.columns
        if col not in [target_col, minutes_col]
    ]

    effects = {}

    for col in cluster_cols:
        # total weighted player-minutes for this archetype
        weighted_count = (df[col] * df[minutes_col]).sum()

        if weighted_count == 0:
            effects[col] = 0.0
            continue

        # weighted contribution
        weighted_effect = (
            df[col] * df[target_col] * df[minutes_col]
        ).sum() / weighted_count

        effects[col] = weighted_effect

    effects = (
        pd.Series(effects)
        .sort_values(ascending=False)
    )

    print("\nWeighted archetype effects (per player, minute-weighted):")
    print(effects)

    return effects


def main():
    # df = runPipelineRegressor("data/24-25/lineup/24-25_clusters_histogram.csv")
    df = runPipelineRegressor("data/25-26/lineup/25-26_clusters_histogram.csv")
    effects = compute_weighted_archetype_effects(
        df,
        target_col="PlusMinus",
        minutes_col="Minutes"
    )


if __name__ == "__main__":
    main()