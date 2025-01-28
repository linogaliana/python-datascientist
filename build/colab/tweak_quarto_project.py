import os
import yaml
from loguru import logger
from callout_colab import process_file


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
    Reads and logs the content of the `_quarto.yml` file.

    Args:
        file_path (str): Path to the `_quarto.yml` file.

    Returns:
        None
    """
    yaml_content = read_quarto_yaml(file_path)

    if not yaml_content:
        raise FileNotFoundError("No content to process.")

    files = yaml_content.get("project").get("render")

    return files


if __name__ == "__main__":
    
    files = list_render_files("_quarto.yml")

    for file in files:
        process_file(
            input_file_path=file,
            regex_pattern=r":::\s*\{(?:\.note|\.caution|\.warning|\.important|\.tip|\.exercise)\}([\s\S]*?):::",
            output_file_path=file,
        )
