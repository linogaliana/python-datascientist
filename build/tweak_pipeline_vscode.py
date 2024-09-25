import yaml

# Load the existing YAML file
with open('_quarto-prod.yml', 'r', encoding='utf-8') as file:
    data = yaml.safe_load(file)

# Replace 'build/callout-jupyter.lua' with 'build/callout-vscode.lua' in the filters
filters = data.get('filters', [])
for i, filter_item in enumerate(filters):
    if filter_item == 'build/callout-jupyter.lua':
        filters[i] = 'build/callout-vscode.lua'

# Write the modified YAML back to a new file
with open('_quarto-prod2.yml', 'w', encoding='utf-8') as file:
    yaml.dump(data, file, allow_unicode=True, sort_keys=False)

print("YAML modification completed and saved as _quarto-prod2.yml")
