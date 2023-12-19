import os
import yaml
from tweak_markdown import read_file

def process_quarto_config(quarto_config_file):
    with open(quarto_config_file, 'r', encoding='utf-8') as yml_file:
        quarto_config = yaml.safe_load(yml_file)
        
        render_files = quarto_config.get('project', {}).get('render', [])

        return render_files

def append_meta_to_file(filename):

    qmd_files = [filename, "build/_meta_info.qmd" ]
    
    combined_content = [
        read_file(qmd_file) for qmd_file in qmd_files
    ]
        
    combined_content = '\n\n'.join(combined_content)

    with open(filename, 'a', encoding='utf-8') as output:
        output.write(combined_content)

if not os.getenv("QUARTO_PROJECT_RENDER_ALL"):
    exit()


list_qmd = process_quarto_config("_quarto.yml")
list_qmd = [l for l in list_qmd if l!= "index.qmd"]
filename = list_qmd[0]