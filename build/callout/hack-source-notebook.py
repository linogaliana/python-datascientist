import json

# Load the notebook file to modify it
file_path = './_site/content/getting-started/01_environment.ipynb'
with open(file_path, 'r') as f:
    notebook_data = json.load(f)

# Process each cell and replace "cell_type": "raw" with the required code block
for cell in notebook_data.get('cells', []):
    if cell.get("cell_type") == "raw" and cell.get("metadata", {}).get("raw_mimetype") == "Python":
        cell["cell_type"] = "code"
        cell["execution_count"] = 1
        cell["metadata"] = {}
        cell["outputs"] = []

# Save the modified notebook back to file
modified_file_path = './_site/content/getting-started/01_environment_modified.ipynb'
with open(modified_file_path, 'w') as f:
    json.dump(notebook_data, f, indent=2)

modified_file_path
