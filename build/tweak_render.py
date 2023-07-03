import os
import glob
import yaml

with open("_quarto.yml", "r") as stream:
    config = yaml.load(stream, Loader=yaml.FullLoader)

if os.path.exists('diff'):
    with open('diff') as f:
        lines = f.read().splitlines()
else:
    lines = glob.glob('content/**/*.qmd', recursive=True)

lines = [l for l in lines if l.endswith('.qmd') ]
lines += [f"content/course/{dir}/index.qmd" \
    for dir in ["manipulation", "visualisation", "modelisation", "NLP", "modern-ds"]
    ]
lines += [f"content/course/index.qmd"]
lines += [f"!content/slides/intro/index.qmd"]
lines += [f"index.qmd"]

print(lines)
config['project']['render'] = lines

with open('_quarto_temp.yml', 'w') as outfile:
    yaml.dump(config, outfile, default_flow_style=False)

print("Done")
