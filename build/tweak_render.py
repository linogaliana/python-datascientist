import yaml

with open("_quarto.yml", "r") as stream:
    config = yaml.load(stream, Loader=yaml.FullLoader)

with open('diff') as f:
    lines = f.read().splitlines() 

lines = [l for l in lines if l.endswith('.qmd') ]

if len(lines) == 0:
    print("no new file")
else:
    config['project']['render'] = lines

with open('_quarto.yml', 'w') as outfile:
    yaml.dump(config, outfile, default_flow_style=False)