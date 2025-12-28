#!/usr/bin/env python3
import argparse
import os
import sys

import pandas as pd


def build_player_lookup(players_csv: str):
    """
    Build a lookup from (team_abbrev, last_name_lower) -> list of full names.

    Assumes players_csv has at least:
      - 'Name' (full name, e.g. 'Karl-Anthony Towns')
      - 'TeamAbbreviation' (e.g. 'NYK')
    """
    players = pd.read_csv(players_csv)

    required_cols = {"Name", "TeamAbbreviation"}
    missing = required_cols - set(players.columns)
    if missing:
        raise ValueError(f"Players CSV is missing required columns: {missing}")

    players["LastName"] = players["Name"].apply(extract_last_name)
    players["LastNameLower"] = players["LastName"].str.lower()
    players["TeamAbbrev"] = players["TeamAbbreviation"].astype(str)

    lookup = {}

    for _, row in players.iterrows():
        key = (row["TeamAbbrev"], row["LastNameLower"])
        lookup.setdefault(key, []).append(row["Name"])

    return lookup

def extract_last_name(full_name: str):
    suffixes = {"jr", "jr.", "sr", "sr.", "ii", "iii", "iv", "v"}

    parts = full_name.strip().split()

    if len(parts) >= 2 and parts[-1].lower() in suffixes:
        # Last name includes suffix → "Smith Jr."
        return f"{parts[-2]} {parts[-1]}"
    else:
        # Normal last name → "Brunson", "Towns"
        return parts[-1]


def resolve_full_name(team: str, last_name: str, lookup: dict):
    """
    Resolve (team, last_name) to a full name using the lookup.

    - First try exact (team, last_name)
    - If multiple matches, pick first and warn.
    - If no team match, try any team with that last name.
    - If still no match, return the original last_name.
    """
    team = str(team)
    last_key = last_name.strip().lower()

    key = (team, last_key)
    if key in lookup:
        names = lookup[key]
        if len(names) > 1:
            # Ambiguous: same last name & team; pick first but warn.
            print(
                f"Warning: multiple matches for {last_name} on team {team}: {names}. "
                f"Using first: {names[0]}",
                file=sys.stderr,
            )
        return lookup[key][0]

    # Fallback: any team with that last name
    candidates = []
    for (t, ln), names in lookup.items():
        if ln == last_key:
            for n in names:
                candidates.append((t, n))

    if len(candidates) == 1:
        return candidates[0][1]
    elif len(candidates) > 1:
        print(
            f"Warning: multiple global matches for last name {last_name}: {candidates}. "
            f"Leaving as last name.",
            file=sys.stderr,
        )
        return last_name

    # No match at all
    print(
        f"Warning: no match found for last name {last_name} on team {team}. "
        f"Leaving as last name.",
        file=sys.stderr,
    )
    return last_name


def expand_lineup_names(
    lineup_csv: str,
    players_csv: str,
    output_csv: str,
    lineup_col: str = "Lineup",
    team_col: str = "TeamAbbreviation",
):
    """
    Read lineup CSV, replace last names in the lineup column with full names
    using the players CSV + team abbreviation.

    Parameters
    ----------
    lineup_csv : str
        Path to lineup CSV. Must contain:
          - lineup_col : lineup string like "Towns, Anunoby, Hart, Bridges, Brunson"
          - team_col   : team abbreviation like "NYK"
    players_csv : str
        Path to player stats CSV containing full 'Name' and 'TeamAbbreviation'.
    output_csv : str
        Path to write updated lineup CSV.
    lineup_col : str
        Name of the column containing lineup strings.
    team_col : str
        Name of the column containing team abbreviations.
    """
    # Build lookup from player data
    lookup = build_player_lookup(players_csv)

    # Load lineup data
    lineups = pd.read_csv(lineup_csv)

    if lineup_col not in lineups.columns:
        # If the first column is the lineup string and unnamed, handle that.
        if lineups.columns[0].startswith("Unnamed"):
            lineup_col = lineups.columns[0]
        else:
            raise ValueError(
                f"Lineup CSV is missing lineup column '{lineup_col}'. "
                f"Available columns: {list(lineups.columns)}"
            )

    if team_col not in lineups.columns:
        # Try to guess an alternative like 'Team' if present
        alternatives = [c for c in lineups.columns if c.lower() in ("team", "teamabbreviation")]
        if alternatives:
            print(
                f"Info: using '{alternatives[0]}' as team column instead of '{team_col}'.",
                file=sys.stderr,
            )
            team_col = alternatives[0]
        else:
            raise ValueError(
                f"Lineup CSV is missing team column '{team_col}'. "
                f"Available columns: {list(lineups.columns)}"
            )

    def transform_lineup(row):
        lineup_str = row[lineup_col]
        team = row[team_col]

        if pd.isna(lineup_str):
            return lineup_str

        # Split lineup string on commas
        last_names = [name.strip() for name in str(lineup_str).split(",") if name.strip()]

        full_names = [
            resolve_full_name(team, ln, lookup) for ln in last_names
        ]

        return ", ".join(full_names)

    # Create a new column with full names (or overwrite existing)
    lineups[lineup_col] = lineups.apply(transform_lineup, axis=1)

    # Write result
    os.makedirs(os.path.dirname(output_csv) or ".", exist_ok=True)
    lineups.to_csv(output_csv, index=False)
    print(f"Wrote updated lineups with full names to: {output_csv}")


def main():
    parser = argparse.ArgumentParser(
        description="Replace last-name-only players in lineup CSV with full names using player stats CSV."
    )
    parser.add_argument("players_csv", help="Path to players CSV with Name and TeamAbbreviation.")
    parser.add_argument("lineup_csv", help="Path to lineup CSV (lineups use last names).")
    parser.add_argument("output_csv", help="Path to write updated lineup CSV with full names.")
    parser.add_argument(
        "--lineup-col",
        default="ShortName",
        help="Column name in lineup CSV containing lineup string. Default: Lineup",
    )
    parser.add_argument(
        "--team-col",
        default="TeamAbbreviation",
        help="Column name in lineup CSV containing team abbreviation. Default: TeamAbbreviation",
    )

    args = parser.parse_args()

    expand_lineup_names(
        lineup_csv=args.lineup_csv,
        players_csv=args.players_csv,
        output_csv=args.output_csv,
        lineup_col=args.lineup_col,
        team_col=args.team_col,
    )


if __name__ == "__main__":
    main()
