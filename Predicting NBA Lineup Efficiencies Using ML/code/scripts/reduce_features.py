import os
import argparse
import pandas as pd


REDUCED_FEATURES = [
    "Points",
    "Usage",
    "EfgPct",
    "TsPct",
    "Assists",
    "AssistPoints",
    "Turnovers",
    "FTA",
    "FG3APct",
    "Rebounds",
    "DefRebounds",
    "Blocks",
    "Steals",
    "AtRimFrequency",
    "AtRimAccuracy",
    "Avg2ptShotDistance",
    "Avg3ptShotDistance",
]

INFO_COLS = ["Name", "TeamAbbreviation"]


def process_position_csv(
    input_csv: str,
    output_csv: str,
    keep_features: list[str],
):
    df = pd.read_csv(input_csv)

    keep_cols = INFO_COLS + [c for c in keep_features if c in df.columns]

    reduced_df = df[keep_cols]

    os.makedirs(os.path.dirname(output_csv), exist_ok=True)
    reduced_df.to_csv(output_csv, index=False)

    print(f"Wrote reduced CSV -> {output_csv} ({len(keep_cols)} columns)")


def main():
    parser = argparse.ArgumentParser(
        description="Create reduced-feature position CSVs from full stat CSVs."
    )
    parser.add_argument(
        "input_root",
        help="Directory containing position CSVs (PG.csv, SG.csv, SF.csv, PF.csv, C.csv)",
    )
    parser.add_argument(
        "output_root",
        help="Directory to write reduced-feature CSVs",
    )

    args = parser.parse_args()

    print("Input root :", args.input_root)
    print("Output root:", args.output_root)
    print()

    for pos in ["PG", "SG", "SF", "PF", "C"]:
        input_csv = os.path.join(args.input_root, f"{pos}.csv")
        output_csv = os.path.join(args.output_root, f"{pos}.csv")

        if not os.path.exists(input_csv):
            print(f"Skipping {pos}: file not found ({input_csv})")
            continue

        process_position_csv(
            input_csv=input_csv,
            output_csv=output_csv,
            keep_features=REDUCED_FEATURES,
        )


if __name__ == "__main__":
    main()
