import pandas as pd
import glob
import os
import numpy as np
#import plotly.express as px
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

def load_data(csv_path: str) -> pd.DataFrame:
    """Loads the dataset from a path to a csv file.
    Returns a dataframe without player information and one only containing player information.
    """
    df = pd.read_csv(csv_path)
    info_cols = ["Name", "TeamAbbreviation"]
    player_info = df[info_cols]
    stat_df = df.drop(columns=info_cols)
    
    return stat_df, player_info

def zscore_features(df):
    """Normalizes non numeric features using z-scores"""
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(df.values)
    return X_scaled, scaler

def run_pca(X, n_components=2):
    """Runs PCA on a feature matrix X
    returns transformed data and the PCA model"""
    pca = PCA(n_components=n_components)
    X_pca = pca.fit_transform(X)
    return X_pca, pca

def plot_pca_variance(pca, pos):
    """
    Plot the explained variance of each principal component
    """
    explained = pca.explained_variance_ratio_
    cumulative = explained.cumsum()
    components = np.arange(1, len(explained) + 1)
    
    plt.figure(figsize=(10,5))
    plt.subplot(1,2,1)
    plt.bar(components, explained, alpha=0.7)
    plt.plot(components, explained, marker='x')
    plt.title(f"{pos} PCA Explained Variance")
    plt.xlabel("Principal Component")
    plt.ylabel("Variance Explained")
    
    plt.subplot(1,2,2)
    plt.plot(components, cumulative, marker='x')
    plt.title(f"{pos} Cumulative Explained Variance")
    plt.xlabel("Principal Component")
    plt.ylabel("Cumulativee Variance Explained")
    
    plt.tight_layout()
    plt.savefig(f"pca/{pos}/{pos}_pca_variance.png")

def plot_pca_2d(X_pca, player_info, pos):
    print(pos)
    
    os.makedirs(f"pca/{pos}/", exist_ok=True)
    
    pca_df = pd.DataFrame({
        "PC1": X_pca[:, 0],
        "PC2": X_pca[:, 1],
        "Name": player_info["Name"].values,
        "Team": player_info["TeamAbbreviation"].values,
    })
    
    fig = px.scatter(pca_df, x="PC1", y="PC2", hover_data=["Name","Team"])
    fig.write_html(f"pca/{pos}/{pos}_pca_2d.html")
    print(f"Saved pca/{pos}/{pos}_pca_2d.html")
    
    plt.figure(figsize=(8,6))
    plt.scatter(X_pca[:, 0], X_pca[:, 1], alpha=0.7)
    plt.title(f"{pos} PCA 2D Projection")
    plt.xlabel("Principal Component 1")
    plt.ylabel("Principal Component 2")
    plt.tight_layout()
    plt.savefig(f"pca/{pos}/{pos}_pca_2d.png")
    
    return

def main():
    root_path = "data/24-25/player/positions/"
    csvs = glob.glob(root_path + "*csv")
    pca_models = []
    for csv in csvs:
        pos = csv.split("/")[-1].replace(".csv", "")
        print(f"Processing position: {pos}")
        stat_df, player_info = load_data(csv)
        x_scaled, scaler = zscore_features(stat_df)
        x_pca, pca_model = run_pca(x_scaled, n_components=None)
        plot_pca_variance(pca_model, pos)
        plot_pca_2d(x_pca, player_info, pos)
        pca_models.append((pos, pca_model, scaler))
        
    return pca_models
        
if __name__ == "__main__":
    main()