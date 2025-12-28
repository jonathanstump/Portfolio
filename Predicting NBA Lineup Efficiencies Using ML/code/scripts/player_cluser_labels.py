import pandas as pd
"""
This file combines the cluster labels and the lineups and the efficiency
"""

def main():
    lineups = "/home/ltraver1/cs66/Final-Project-ltraver1-jstump2-dburger1-saird1/data/24-25/lineup/24-25_lineup_names_and_efficiency.csv"
    pg = "/home/ltraver1/cs66/Final-Project-ltraver1-jstump2-dburger1-saird1/data/24-25/player/clustered_positions/PG_clustered_players.csv"
    sg = "/home/ltraver1/cs66/Final-Project-ltraver1-jstump2-dburger1-saird1/data/24-25/player/clustered_positions/SG_clustered_players.csv"
    sf = "/home/ltraver1/cs66/Final-Project-ltraver1-jstump2-dburger1-saird1/data/24-25/player/clustered_positions/SF_clustered_players.csv"
    pf = "/home/ltraver1/cs66/Final-Project-ltraver1-jstump2-dburger1-saird1/data/24-25/player/clustered_positions/PF_clustered_players.csv"
    c = "/home/ltraver1/cs66/Final-Project-ltraver1-jstump2-dburger1-saird1/data/24-25/player/clustered_positions/C_clustered_players.csv"


    output_csv = "/home/ltraver1/cs66/Final-Project-ltraver1-jstump2-dburger1-saird1/data/24-25/lineup/24-25_names_with_clusters.csv"


    lineups = pd.read_csv(lineups)
    pg = pd.read_csv(pg)
    sg = pd.read_csv(sg)
    sf = pd.read_csv(sf)
    pf = pd.read_csv(pf)
    c = pd.read_csv(c)

    pg_dict = dict(zip(pg["Name"], pg["cluster"]))
    sg_dict = dict(zip(sg["Name"], sg["cluster"]))
    sf_dict = dict(zip(sf["Name"], sf["cluster"]))
    pf_dict = dict(zip(pf["Name"], pf["cluster"]))
    c_dict  = dict(zip(c["Name"],  c["cluster"]))

    # make output csv (for pg, sg, sf, pf, c)

    result = []

    for i in range(len(lineups)): 
        names = lineups.iloc[i][0]
        names = names.split(", ")
        efficiency = lineups.iloc[i][1]

        row = {
        "PG": None, "SG": None, "SF": None, "PF": None, "C": None,
        "PG_label": None, "SG_label": None, "SF_label": None, "PF_label": None, "C_label": None,
        "efficiency": efficiency
    }

        for name in names: 
            print(name)

            if name in pg_dict:
                cluster = pg_dict[name]
                row["PG"] = name
                row["PG_label"] = int(cluster)
            elif name in sg_dict:
                cluster = sg_dict[name]
                row["SG"] = name
                row["SG_label"] = int(cluster)
            elif name in sf_dict:
                cluster = sf_dict[name] 
                row["SF"] = name
                row["SF_label"] = int(cluster)
            elif name in pf_dict:
                cluster = pf_dict[name]
                row["PF"] = name
                row["PF_label"] = int(cluster)
            elif name in c_dict:
                cluster = c_dict[name]
                row["C"] = name
                row["C_label"] = int(cluster)
        
        result.append(row)


    result = pd.DataFrame(result)
    result.to_csv(output_csv, index=False)

main()



