import os
import glob
import yaml

file_path = "_quarto.yml"

with open(file_path, "r") as stream:
    config = yaml.load(stream, Loader=yaml.FullLoader)

if os.path.exists('diff'):
    with open('diff') as f:
        lines = f.read().splitlines()
else:
    lines = glob.glob('content/**/*.qmd', recursive=True)

lines = [l for l in lines if l.endswith('.qmd') ]
lines += [f"content/{dir}/index.qmd" \
    for dir in [
        "getting-started", "manipulation",
        "visualisation", "modelisation",
        "NLP", "modern-ds"]
    ]
lines += [f"index.qmd"]

config.setdefault('book', {})['chapters'] = lines

lines2 = lines + ["!content/slides/"]


print(lines2)
config['project']['render'] = lines2

with open(file_path, 'w') as outfile:
    yaml.dump(config, outfile, default_flow_style=False)

print("Done")
