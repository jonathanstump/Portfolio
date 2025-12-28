## Welcome

Welcome! This repository contains all code used for the project. Please refer to this README for instructions on how to run the code and a brief description of each file.

---

## File/Folder Overview

**data/** – contains the player and lineup data for 24/25 and 25/26, including pre and post-processed files.

**kmeans/** – contains 2D visualizations of clustered positions with various k values, as well as gap statistic graphs and cluster summaries of the mean statistical features in each cluster.

**models/** – contains the necessary saved models for use across files.

**pca/** – contains PCA visualizations for each position.

**scripts/** – includes scripts run to process data into necessary files for random forests and other models.

**kmeans.py** – runs kmeans on the PCA data, giving the user the ability to choose which metric for finding an optimal k.

**linear_models.py** – runs a linear regression model on the clustered lineup data, outputting coefficients and error.

**pca.py** – runs PCA on the raw data.

**predict_eff.py** – loads a model, evaluating it and appending predictions to a CSV.

**random_forest.py** – runs a random forest model on the clustered lineup data.

**text_results.txt** – a text file containing select relevant printed output from running kmeans and cluster statistics.

---

## Setup Instructions

To setup this project, clone the repository into an editor of choice. 
To recreate the csv pipeline, see the scripts folder.

To run random forest models or linear regression:

```
python random_forest.py
python linear_models.py
```

To create new clustered groups, run:

```
python kmeans.py
```

These will be saved to the models folder. Then, run

```
python scripts/add_cluster_label.py
```

to create 5 data files, one for each position with the clusters assigned to the players in that position. Then run

```
python scripts/create_histogram_features.py
```

to output a csv with the clusters as features and the efficiency as the label, ready for random forests. This assumes that
the user has the lineup file with the names and efficiencies.

>Note: you may have to move scripts out of the scripts folder and into the main directory for relative path matching.

