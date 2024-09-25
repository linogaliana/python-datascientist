import yaml
import argparse

# Set up argument parser
parser = argparse.ArgumentParser(
    description="Modify a YAML file and replace a specific filter value."
)
parser.add_argument(
    "--filename",
    default="_quarto-prod.yml",
    help="YAML file to be modified. Default is '_quarto-prod.yml'.",
)
parser.add_argument(
    "--output",
    default="_quarto-prod2.yml",
    help="Output YAML file name. Default is '_quarto-prod2.yml'.",
)

# Parse arguments
args = parser.parse_args()

# Load the existing YAML file
with open(args.filename, "r", encoding="utf-8") as file:
    data = yaml.safe_load(file)

# Replace 'build/callout-jupyter.lua' with 'build/callout-vscode.lua' in the filters
filters = data.get("filters", [])
for i, filter_item in enumerate(filters):
    if filter_item == "build/callout-jupyter.lua":
        filters[i] = "build/nice-vscode/callout-vscode.lua"

# Write the modified YAML back to the output file
with open(args.output, "w", encoding="utf-8") as file:
    yaml.dump(data, file, allow_unicode=True, sort_keys=False)

print(f"YAML modification completed and saved as {args.output}")
