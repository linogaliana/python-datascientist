import yaml
from tweak_markdown import read_file, write_file


def process_quarto_config(quarto_config_file):
    with open(quarto_config_file, "r", encoding="utf-8") as yml_file:
        quarto_config = yaml.safe_load(yml_file)

        render_files = quarto_config.get("project", {}).get("render", [])

        return render_files


def append_meta_to_file(filename):
    qmd_files = [filename, "build/_meta_info.qmd"]

    combined_content = [read_file(qmd_file) for qmd_file in qmd_files]

    combined_content = "\n\n".join(combined_content)

    write_file(filename, combined_content)


list_qmd = process_quarto_config("_quarto.yml")
list_qmd = [fileqmd for fileqmd in list_qmd if fileqmd != "index.qmd"]
list_qmd = [fileqmd for fileqmd in list_qmd if fileqmd.startswith("_") is False]

if __name__ == "__main__":
    for files in list_qmd:
        append_meta_to_file(files)
