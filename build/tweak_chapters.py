import yaml

# Specify the file to be modified
file_path = "_quarto.yml"

# Load the YAML file
with open(file_path, 'r') as file:
    data = yaml.safe_load(file)

# Define the replacement mappings
replacements = {
    "book": "website",
    "Book": "Website",
    "BOOK": "WEBSITE"
}

del data['book']['chapters']

# Write the modified data back to the YAML file
with open(file_path, 'w') as file:
    yaml.dump(data, file)