import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
import pca
import glob
from sklearn.metrics import silhouette_score, silhouette_samples
import matplotlib.cm as cm
import os
from sklearn.metrics import calinski_harabasz_score
import joblib

def run_kmeans(X, num_clusters):
    """
    Runs KMeans clustering on data X with specified number of clusters.
    Returns the fitted KMeans model and the cluster labels.
    """
    kmeans = KMeans(n_clusters=num_clusters)
    clustered_labels = kmeans.fit_predict(X)
    return kmeans, clustered_labels

def show_clustered_plots(X, labels, pos, k):
    """
    Plots the clustered data in 2D PCA space and saves the figure.
    """
    plt.figure(figsize=(8,6))
    plt.scatter(X[:, 0], X[:, 1], c=labels, cmap="tab10", alpha=0.7)
    plt.title(f"{pos} KMeans 2D Clusters")
    plt.xlabel("PC1")
    plt.ylabel("PC2")
    plt.tight_layout()

    os.makedirs(f"kmeans/positions/{pos}", exist_ok=True)
    plt.savefig(f"kmeans/positions/{pos}/{pos}_kmeans{k}.png")
    plt.close()

def silhouette_search_and_plot(X, pos, k_values, out_root="kmeans/metrics/silhouette_plots"):
    """
    Performs silhouette analysis for a range of k values and saves the plots.
    """
    out_dir = f"{out_root}/{pos}"
    os.makedirs(out_dir, exist_ok=True)

    best_k = None
    best_score = -1

    for k in k_values:
        kmeans = KMeans(n_clusters=k, random_state=10)
        labels = kmeans.fit_predict(X)
        sil_avg = silhouette_score(X, labels)

        if sil_avg > best_score:
            best_score = sil_avg
            best_k = k

        sample_values = silhouette_samples(X, labels)
        y_lower = 10

        fig, ax1 = plt.subplots(figsize=(8, 6))
        ax1.set_xlim([-0.1, 1])
        ax1.set_ylim([0, len(X) + (k + 1) * 10])

        for i in range(k):
            ith_vals = sample_values[labels == i]
            ith_vals.sort()

            size_i = ith_vals.shape[0]
            y_upper = y_lower + size_i

            color = cm.nipy_spectral(float(i) / k)
            ax1.fill_betweenx(
                np.arange(y_lower, y_upper),
                0,
                ith_vals,
                facecolor=color,
                edgecolor=color,
                alpha=0.7
            )

            ax1.text(-0.05, y_lower + 0.5 * size_i, str(i))
            y_lower = y_upper + 10

        ax1.axvline(x=sil_avg, color="red", linestyle="--")
        ax1.set_title(f"{pos} silhouette, k={k} (avg={sil_avg:.3f})")
        ax1.set_xlabel("Silhouette value")
        ax1.set_yticks([])

        plt.tight_layout()
        plt.savefig(f"{out_dir}/{pos}_k{k}.png")
        plt.close()

    return best_k

def ch_search(X, pos, k_values):
    """
    Performs Calinski–Harabasz score analysis for a range of k values.
    """
    best_k = None
    best_score = -1
    scores = {}

    for k in k_values:
        kmeans = KMeans(n_clusters=k, random_state=10)
        labels = kmeans.fit_predict(X)

        score = calinski_harabasz_score(X, labels)
        scores[k] = score

        print(f"{pos}: k={k}, CH score={score:.2f}")

        if score > best_score:
            best_score = score
            best_k = k

    print(f"Best k for {pos} by CH score = {best_k}")
    return best_k, scores

def plot_ch_scores(scores, pos):
    """
    Plots Calinski–Harabasz scores for different k values.
    """
    ks = list(scores.keys())
    vals = list(scores.values())

    plt.figure(figsize=(7,5))
    plt.plot(ks, vals, marker="o")
    plt.xlabel("k")
    plt.ylabel("CH Score")
    plt.title(f"Calinski–Harabasz Scores for {pos}")
    plt.tight_layout()
    os.makedirs("kmeans/metrics/CH_plots", exist_ok=True)
    plt.savefig(f"kmeans/metrics/CH_plots/{pos}_CH.png")
    plt.close()

def compute_dispersion(X, labels, centers):
    # Sum of squared distances of all points to their assigned center
    dispersion = 0
    for i, c in enumerate(centers):
        cluster_points = X[labels == i]
        dispersion += np.sum((cluster_points - c)**2)
    return dispersion

def gap_statistic(X, pos, k_values, B=10):
    """
    X: data in PCA space
    pos: string for saving plots
    k_values: iterable of k values
    B: number of bootstrap reference samples

    Returns:
        tibshirani_k: best k using Tibshirani 1-std-dev rule
        max_gap_k: k with the maximum Gap value
        gaps: list of Gap values for each k
        std_devs: list of standard deviations for each k
    """
    gaps = []
    std_devs = []

    # Bounds for generating uniform reference points
    mins = np.min(X, axis=0)
    maxs = np.max(X, axis=0)

    for k in k_values:
        # Real clustering
        kmeans = KMeans(n_clusters=k, random_state=10).fit(X)
        labels = kmeans.labels_
        real_disp = compute_dispersion(X, labels, kmeans.cluster_centers_)
        log_real = np.log(real_disp)

        # Reference dispersions
        ref_disps = []
        for _ in range(B):
            X_ref = np.random.uniform(mins, maxs, size=X.shape)
            km_ref = KMeans(n_clusters=k, random_state=10).fit(X_ref)
            ref_disp = compute_dispersion(X_ref, km_ref.labels_, km_ref.cluster_centers_)
            ref_disps.append(np.log(ref_disp))

        ref_mean = np.mean(ref_disps)
        ref_std = np.std(ref_disps)

        gap = ref_mean - log_real
        gaps.append(gap)
        std_devs.append(ref_std * np.sqrt(1 + 1/B))

        print(f"{pos}: k={k}, Gap={gap:.4f}, sd={std_devs[-1]:.4f}")

    # K with maximum Gap
    max_gap_k = k_values[np.argmax(gaps)]

    # Best k using Tibshirani 1-standard deviation rule
    tibshirani_k = k_values[0]
    for i in range(len(k_values)-1):
        if gaps[i] >= gaps[i+1] - std_devs[i+1]:
            tibshirani_k = k_values[i]
            break

    print(f"Best k for {pos} by Gap Statistic (Tibshirani rule) = {tibshirani_k}")
    print(f"K with maximum Gap value = {max_gap_k}")

    return tibshirani_k, max_gap_k, gaps, std_devs

def plot_gap(gaps, std_devs, k_values, pos):
    """
    Plots Gap Statistic values for different k values.
    """
    plt.figure(figsize=(7,5))
    plt.errorbar(k_values, gaps, yerr=std_devs, fmt='o-', capsize=5)
    plt.xlabel("k")
    plt.ylabel("Gap Statistic")
    plt.title(f"Gap Statistic for {pos}")
    plt.tight_layout()

    os.makedirs("kmeans/metrics/GAP_plots", exist_ok=True)
    plt.savefig(f"kmeans/metrics/GAP_plots/{pos}_GAP.png")
    plt.close()

def choose_k_and_plot(x_pca, label, metric="manual", k_values=range(2, 11)):
    """
    metric: "silhouette", "ch", "gap", or "manual"
    label: the position of the player, used for naming or 'labeling' a file
    """
    if metric == "silhouette":
        best_k = silhouette_search_and_plot(x_pca, label, k_values)

    elif metric == "ch":
        best_k, scores = ch_search(x_pca, label, k_values)
        plot_ch_scores(scores, label)

    elif metric == "gap":
        tibshirani_k, max_gap_k, gaps, std_devs = gap_statistic(x_pca, label, k_values)
        plot_gap(gaps, std_devs, k_values, label)
        print(f"Tibshirani k: {tibshirani_k}, Max Gap k: {max_gap_k}")
        best_k = int(round((tibshirani_k + max_gap_k)/2))

    elif metric == "manual":
        d = { "PG": 4, "SG": 5, "SF": 4, "PF": 6, "C": 6}
        best_k = d[label]

    else:
        raise ValueError("metric must be one of: 'silhouette', 'ch', or 'gap'")

    return best_k

def gather_plots(metric="manual"):
    """
    metric ∈ {"silhouette", "ch", "gap"}
    """

    root_path = "data/24-25/player/positions/"
    csvs = glob.glob(root_path + "*csv")
    kmeans_models = []

    os.makedirs("models", exist_ok=True)

    for csv in csvs:
        pos = csv.split("/")[-1].replace(".csv", "")

        # if pos != "C":
        #     continue
        print(f"Processing position: {pos}")

        stat_df, player_info = pca.load_data(csv)
        x_scaled, scaler = pca.zscore_features(stat_df)
        x_pca, pca_model = pca.run_pca(x_scaled, n_components=11)

        best_k = choose_k_and_plot(x_pca, pos, metric=metric)
        kmeans, labels = run_kmeans(x_pca, best_k)

        joblib.dump(scaler, f"models/{pos}_scaler2.joblib")
        joblib.dump(pca_model, f"models/{pos}_pca2.joblib")
        joblib.dump(kmeans, f"models/{pos}_kmeans3.joblib")

        show_clustered_plots(x_pca, labels, pos, best_k)
        analyze_cluster_insights(stat_df, labels, pos, best_k, x_pca, kmeans, player_info)

        kmeans_models.append((pos, kmeans, labels, scaler))

    # ALL POSITIONS
    # print("Processing ALL_POSITIONS")
    # new_path = "data/24-25/player/all_positions/24-25_player_stats_condensed.csv"

    # stat_df, player_info = pca.load_data(new_path)
    # stat_df = stat_df.select_dtypes(include=[np.number])
    # x_scaled, scaler = pca.zscore_features(stat_df)
    # x_pca, pca_model = pca.run_pca(x_scaled, n_components=11)

    # best_k = choose_k_and_plot(x_pca, "All_Players", metric=metric)
    # kmeans, labels = run_kmeans(x_pca, best_k)
    # show_clustered_plots(x_pca, labels, "All_Players", best_k)
    # analyze_cluster_insights(stat_df, labels, "All_Players", best_k, x_pca, kmeans)

    # kmeans_models.append(("All_Players", kmeans, scaler))

    return kmeans_models, x_pca

def analyze_clusters(stat_df, labels, pos, k, outdir="kmeans/cluster_summaries"):
    """
    stat_df: original DataFrame BEFORE scaling (raw stats)
    labels : cluster labels from KMeans
    pos    : position string
    """

    os.makedirs(outdir, exist_ok=True)

    df = stat_df.copy()
    df["cluster"] = labels

    cluster_means = df.groupby("cluster").mean()
    cluster_counts = df["cluster"].value_counts().sort_index()

    print(f"\n=== Cluster Summary for {pos} ===")
    print("Cluster sizes:")
    print(cluster_counts)
    print("\nCluster means:")
    print(cluster_means)

    # Save files
    cluster_means.to_csv(f"{outdir}/{pos}_cluster_means{k}.csv")
    cluster_counts.to_csv(f"{outdir}/{pos}_cluster_sizes{k}.csv")

    return cluster_means, cluster_counts

def cluster_feature_variance(cluster_means, top_n=5):
    """
    Identify features that vary the most across clusters.
    
    cluster_means: DataFrame of mean stats per cluster
    top_n: number of top features to return
    
    Returns:
        Series of top features with their variance
    """
    cluster_var = cluster_means.var(axis=0)  # variance across clusters
    top_features = cluster_var.sort_values(ascending=False).head(top_n)
    print("\nTop features differentiating clusters:")
    print(top_features)
    return top_features


def plot_cluster_heatmap(cluster_means, pos, k, outdir="kmeans/cluster_summaries"):
    """
    Plot heatmap of standardized cluster means for interpretability.
    
    cluster_means: DataFrame of mean stats per cluster
    pos: position string
    """
    import seaborn as sns
    os.makedirs(outdir, exist_ok=True)

    # Standardize across clusters (z-score)
    cluster_means_z = (cluster_means - cluster_means.mean()) / cluster_means.std()

    plt.figure(figsize=(12,6))
    sns.heatmap(cluster_means_z, annot=True, cmap="vlag", center=0)
    plt.title(f"Standardized Cluster Means for {pos}")
    plt.tight_layout()
    plt.savefig(f"{outdir}/{pos}_cluster_heatmap{k}.png")
    plt.close()


def cluster_top_stats_per_cluster(cluster_means, top_n=10):
    """
    For each cluster, identify top N features that differ most from the other clusters.
    
    cluster_means: DataFrame of mean stats per cluster
    top_n: number of features to display per cluster
    
    Returns:
        dict: cluster -> list of top features
    """
    cluster_top_features = {}
    # Standardize features across clusters
    cluster_means_std = (cluster_means - cluster_means.mean()) / cluster_means.std()

    for cluster in cluster_means_std.index:
        other_clusters = cluster_means_std.drop(cluster)
        diff_from_others = cluster_means_std.loc[cluster] - other_clusters.mean()
        
        # Sort by absolute value but keep the sign
        top_features = diff_from_others.sort_values(key=abs, ascending=False).head(top_n)
        
        cluster_top_features[cluster] = top_features
        print(f"\nCluster {cluster} top differing stats (standardized):")
        print(top_features)

    return cluster_top_features

def print_top_players_near_centers(X, labels, player_info, kmeans_model, pos, top_n=10):
    """
    Print the players closest to each cluster center (in PCA space).

    X: PCA coordinates (same order as player_info)
    labels: cluster labels
    player_info: DataFrame with player identifiers (same indexing as X)
                 must include a player name column
    kmeans_model: fit KMeans object
    """
    centers = kmeans_model.cluster_centers_

    print(f"\n=== Closest Players to Cluster Centers for {pos} ===")

    for cluster_id in range(len(centers)):
        center = centers[cluster_id]

        # Indices of samples in this cluster
        idx = np.where(labels == cluster_id)[0]
        cluster_points = X[idx]

        # Euclidean distances
        dists = np.linalg.norm(cluster_points - center, axis=1)

        # Sort by distance
        sorted_idx = idx[np.argsort(dists)]

        # Print top-N closest players
        print(f"\nCluster {cluster_id} (top {top_n} closest):")
        for i in range(min(top_n, len(sorted_idx))):
            p_index = sorted_idx[i]
            player_row = player_info.iloc[p_index]
            name = player_row.get("Name", player_row.index[0])

            print(f"  {i+1}. {name} (distance={dists[np.argsort(dists)][i]:.4f})")

def analyze_cluster_insights(stat_df, labels, pos, k, X, kmeans_model, player_info):
    """
    Wrapper function to compute and plot all cluster interpretability metrics.
    Call this after running KMeans and getting cluster labels.
    """
    cluster_means, cluster_counts = analyze_clusters(stat_df, labels, pos, k)

    # Top overall differentiating features
    cluster_feature_variance(cluster_means)

    # Heatmap
    plot_cluster_heatmap(cluster_means, pos, k)

    # Top features per cluster
    cluster_top_stats_per_cluster(cluster_means)

    # Top players closest to the cluster center
    print_top_players_near_centers(X, labels, player_info, kmeans_model, pos)

    return cluster_means, cluster_counts

def main(metric="manual"):
    """
    metric ∈ {"silhouette", "ch", "gap"}
    """

    _, X = gather_plots(metric=metric)

        
if __name__ == "__main__":
    main()