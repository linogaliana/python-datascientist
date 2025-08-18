import os
import yaml
import argparse
import pandas as pd


def process_yaml(yaml_content, lang):
    if lang == "english":
        if "title-en" in yaml_content:
            if "title" in yaml_content:
                yaml_content["title-fr"] = yaml_content.pop("title")
            yaml_content["title"] = yaml_content.pop("title-en")
    elif lang == "french":
        if "title-fr" in yaml_content:
            if "title" in yaml_content:
                yaml_content["title-en"] = yaml_content.pop("title")
            yaml_content["title"] = yaml_content.pop("title-fr")
    return yaml_content


def process_file(filepath, lang):
    with open(filepath, "r", encoding="utf-8") as file:
        content = file.read()

    # Separate YAML front matter from the rest of the content
    if content.startswith("---"):
        yaml_end = content.find("---", 3)
        yaml_content = yaml.safe_load(content[3:yaml_end].strip())
        modified_yaml = process_yaml(yaml_content, lang)

        # Write the modified YAML and original content back to the file
        new_content = (
            f"---\n{yaml.dump(modified_yaml, sort_keys=False)}---\n"
            + content[yaml_end + 3 :]
        )
        with open(filepath, "w", encoding="utf-8") as file:
            file.write(new_content)
        print(f"Processed: {filepath}")


def process_directory(root_dir, lang):
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith(".qmd"):
                filepath = os.path.join(subdir, file)
                process_file(filepath, lang)


def extract_yaml_header(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    if not lines or lines[0].strip() != '---':
        return None

    # Find the end of the YAML header
    try:
        end_index = lines[1:].index('---\n') + 1
    except ValueError:
        return None

    yaml_content = ''.join(lines[1:end_index])
    try:
        return yaml.safe_load(yaml_content)
    except yaml.YAMLError:
        return None


# II - LISTING CHAPTERS FOR LANDING PAGE -------------------------

def collect_qmd_metadata(directory):
    records = []

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.qmd'):
                path = os.path.join(root, file)
                yaml_data = extract_yaml_header(path)
                if yaml_data:
                    title = yaml_data.get('title', '')
                    title_en = yaml_data.get('title-en', '')
                    records.append({'path': path, 'title': title, 'title-en': title_en})

    return pd.DataFrame(records)

def extract_qmd_paths_from_quarto(quarto_yml_path):
    """Parse _quarto.yml and extract all .qmd file paths in order"""
    with open(quarto_yml_path, 'r', encoding='utf-8') as f:
        quarto_config = yaml.safe_load(f)

    qmd_paths = []
    website = quarto_config.get('website', {})
    sidebar = website.get('sidebar', [])

    for section in sidebar:
        contents = section.get('contents', [])
        for item in contents:
            if isinstance(item, str):
                qmd_paths.append(item)
            elif isinstance(item, dict) and 'href' in item:
                href = item['href']
                if href.endswith('.qmd'):
                    qmd_paths.append(href)
    return qmd_paths

def build_metadata_dataframe(quarto_yml_path):
    qmd_paths = extract_qmd_paths_from_quarto(quarto_yml_path)
    records = []

    for order, path in enumerate(qmd_paths):
        yaml_data = extract_yaml_header(path)
        records.append({
            'path': path,
            'title': yaml_data.get('title', ''),
            'title-en': yaml_data.get('title-en', ''),
            'order': order
        })

    return pd.DataFrame(records)


def generate_quarto_badges(df):
    badge_blocks = []

    for _, row in df.iterrows():
        path = row['path']

        # Only files in /content/ and not index.qmd
        if path.startswith("content/") and not os.path.basename(path).startswith("index"):
            badge_block = f'''{{{{< badges\n    fpath="/{path}"\n    printMessage="false"\n>}}}}'''
            badge_blocks.append(badge_block)

    return badge_blocks



if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Process YAML headers in Quarto .qmd files."
    )
    parser.add_argument(
        "--to",
        choices=["english", "french"],
        required=True,
        help="Specify the target language (english or french).",
    )
    parser.add_argument(
        "--root-dir",
        type=str,
        default=os.getcwd(),
        help="Root directory to start processing (default: current directory).",
    )

    args = parser.parse_args()

    process_directory(args.root_dir, args.to)
