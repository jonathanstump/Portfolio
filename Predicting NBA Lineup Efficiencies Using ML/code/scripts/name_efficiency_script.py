import pandas as pd

def main():
    input_csv = "data/25-26/lineup/25-26_lineup_fullnames.csv"
    output_csv = "data/25-26/lineup/25-26_lineup_names_and_efficiency.csv"

    # choose the two columns you want
    cols_to_keep = ["ShortName", "PlusMinus"]

    # --- PROCESS ---
    df = pd.read_csv(input_csv)

    # select only the two columns
    new_df = df[cols_to_keep]

    # write to new csv
    new_df.to_csv(output_csv, index=False)

    print("Done! Saved:", output_csv)


main()