import yaml

with open("_quarto.yml", "r") as stream:
    config = yaml.load(stream, Loader=yaml.FullLoader)

with open('diff') as f:
    lines = f.read().splitlines() 

lines = [l for l in lines if l.endswith('.qmd') ]
lines += [f"content/course/{dir}/index.md" for dir in ["manipulation","visualisation","modelisation"]]

config['project']['render'] = lines

with open('_quarto.yml', 'w') as outfile:
    yaml.dump(config, outfile, default_flow_style=False)

print("Done")