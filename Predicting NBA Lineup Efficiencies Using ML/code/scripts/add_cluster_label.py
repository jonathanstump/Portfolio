import pandas as pd
import joblib
import pca  # your existing module
import os

def assign_clusters(csv_path, pos):
    df, player_info = pca.load_data(csv_path)

    scaler = joblib.load(f"models/{pos}_scaler2.joblib")
    pca_model = joblib.load(f"models/{pos}_pca2.joblib")
    kmeans = joblib.load(f"models/{pos}_kmeans3.joblib")
    print
    """
        # drop extra columns
    df = df.drop(columns=[
        "AtRimPctBlocked",
        "ShortMidRangePctBlocked",
        "NonHeaveArc3FGM"
    ], errors="ignore")

    # add missing column with 0s
    if "LongMidRangePctBlocked" not in df.columns:
        df["LongMidRangePctBlocked"] = 0.0
    """
    x_scaled = scaler.transform(df)
    x_pca = pca_model.transform(x_scaled)
    labels = kmeans.predict(x_pca)

    player_info["cluster"] = labels

    output_dir = "data/24-25/player/clustered_positions"
    os.makedirs(output_dir, exist_ok=True)
    player_info.to_csv(f"{output_dir}/{pos}_clustered_players.csv", index=False)

    return player_info

def main():
    assign_clusters("data/24-25/player/positions/PG.csv", "PG")
    assign_clusters("data/24-25/player/positions/SG.csv", "SG")
    assign_clusters("data/24-25/player/positions/SF.csv", "SF")
    assign_clusters("data/24-25/player/positions/PF.csv", "PF")
    assign_clusters("data/24-25/player/positions/C.csv", "C")
if __name__ == "__main__":
    main()