import os
import yaml
import argparse


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
