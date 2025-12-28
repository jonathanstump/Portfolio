import pandas as pd

# Load player cluster CSVs for each position
pg_clusters = pd.read_csv("data/25-26/player/clustered_positions/PG_clustered_players.csv")
sg_clusters = pd.read_csv("data/25-26/player/clustered_positions/SG_clustered_players.csv")
sf_clusters = pd.read_csv("data/25-26/player/clustered_positions/SF_clustered_players.csv")
pf_clusters = pd.read_csv("data/25-26/player/clustered_positions/PF_clustered_players.csv")
c_clusters = pd.read_csv("data/25-26/player/clustered_positions/C_clustered_players.csv")
# Function to add position prefix to cluster column
def add_position_prefix(df, pos):
    df = df.copy()
    df['cluster'] = df['cluster'].apply(lambda x: f"{pos}_cluster_{x}")
    return df

pg_clusters = add_position_prefix(pg_clusters, "PG")
sg_clusters = add_position_prefix(sg_clusters, "SG")
sf_clusters = add_position_prefix(sf_clusters, "SF")
pf_clusters = add_position_prefix(pf_clusters, "PF")
c_clusters = add_position_prefix(c_clusters, "C")

# Concatenate all player clusters into one DataFrame
all_players = pd.concat([pg_clusters, sg_clusters, sf_clusters, pf_clusters, c_clusters], ignore_index=True)

# Create a mapping from player name to position-specific cluster
player_to_cluster = dict(zip(all_players['Name'], all_players['cluster']))

# Load lineup file
lineups = pd.read_csv("data/25-26/lineup/25-26_lineup_names_and_efficiency.csv")

# Find all unique clusters for feature columns
all_clusters = sorted(all_players['cluster'].unique())

# Function to turn a lineup into a cluster histogram
def lineup_to_features(lineup_names):
    names = [name.strip() for name in lineup_names.split(',')]
    clusters = [player_to_cluster.get(name, None) for name in names]
    features = [clusters.count(c) for c in all_clusters]
    return features

# Apply to all lineups
features = lineups['ShortName'].apply(lineup_to_features)

# Convert features to DataFrame
feature_df = pd.DataFrame(features.tolist(), columns=all_clusters)

# Add label
feature_df['PlusMinus'] = lineups['PlusMinus']

# Save to CSV
feature_df.to_csv("data/25-26/lineup/25-26_clusters_histogram.csv", index=False)

print("Feature CSV saved with position-specific cluster features.")
