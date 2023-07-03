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

# Function to recursively replace values in a dictionary
def replace_values(data):
    if isinstance(data, dict):
        for key, value in list(data.items()):
            if isinstance(value, str):
                for old, new in replacements.items():
                    value = value.replace(old, new)
                data[key] = value
            else:
                replace_values(value)
            if key in replacements:
                data[replacements[key]] = data.pop(key)
    elif isinstance(data, list):
        for i in range(len(data)):
            replace_values(data[i])

# Replace the values in the loaded data
replace_values(data)

# Write the modified data back to the YAML file
with open(file_path, 'w') as file:
    yaml.dump(data, file)