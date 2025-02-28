import os
import yaml
import glob
import argparse
from loguru import logger
from callout_colab import process_file

parser = argparse.ArgumentParser(description="Tweak quarto project for Google colab notebooks")

parser.add_argument(
    "--overwrite",
    action="store_true",  # This makes it a boolean flag that defaults to False
    help="Enable override mode (default: False)"
)
parser.set_defaults(overwrite=False)

args = parser.parse_args()


def read_quarto_yaml(file_path):
    """
    Reads and parses a YAML file.

    Args:
        file_path (str): Path to the YAML file.

    Returns:
        dict: Parsed content of the YAML file.
    """
    if not os.path.exists(file_path):
        logger.error(f"YAML file does not exist: {file_path}")
        return None

    try:
        logger.info(f"Reading YAML file from {file_path}")
        with open(file_path, "r") as file:
            yaml_content = yaml.safe_load(file)
        logger.success(f"Successfully read YAML content from {file_path}")
        return yaml_content
    except Exception as e:
        logger.error(f"Error reading YAML file: {e}")
        return None


def list_render_files(file_path):
    """
    Reads the `_quarto.yml` file and extracts the list of files to render.

    Args:
        file_path (str): Path to the `_quarto.yml` file.

    Returns:
        list: List of file paths from `_quarto.yml`.
    """
    yaml_content = read_quarto_yaml(file_path)

    if not yaml_content:
        raise FileNotFoundError("No content to process.")

    return yaml_content.get("project", {}).get("render", [])


def find_qmd_files(directory):
    """
    Finds all `_*.qmd` files in the given directory and its subdirectories.

    Args:
        directory (str): Path to the root directory.

    Returns:
        list: List of `_*.qmd` file paths.
    """
    return glob.glob(os.path.join(directory, "**", "_*.qmd"), recursive=True)


if __name__ == "__main__":
    files = list_render_files("_quarto.yml")

    # Find all _*.qmd files in ./content/ recursively
    qmd_files = find_qmd_files("./content/")

    logger.debug(qmd_files)

    # Combine both lists and remove duplicates
    all_files = list(set(files + qmd_files))

    for file in all_files:
        process_file(
            input_file_path=file,
            regex_pattern=r":::\s*\{(?:\.note|\.caution|\.warning|\.important|\.tip|\.exercise)\}([\s\S]*?):::",
            overwrite=args.overwrite
        )
