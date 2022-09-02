"""Generate doc of a training program for https://www.sspcloud.fr."""
import os
from os.path import dirname
import json
import urllib.parse

import frontmatter


def extract_metadata_md(md_path):
    """Extract title and abstract metadata from a Markdown file."""
    with open(md_path, "r") as md_file:
        fm = frontmatter.load(md_file)

    return fm["title"], fm["summary"]


def generate_block(name, abstract, authors, types, tags, category,
                   img_url, article_url=None, deployment_url=None):
    """Generate json documentation for a training program block.

    If both `article_url` and `deployment_url` are None, the block is assumed
    to be a container for further sub-blocks (i.e. has an "open" button).
    Otherwise, either one of or both `article_url` and `deployment_url` must
    be provided.
    """
    block = {
        "name": name,
        "abstract": abstract,
        "authors": authors,
        "types": types,
        "tags": tags,
        "category": category,
        "imageUrl": img_url
    }

    if article_url is None and deployment_url is None:
        block["parts"] = []
    if deployment_url is not None:
        block["deploymentUrl"] = deployment_url
    if article_url is not None:
        block["articleUrl"] = article_url

    return block


if __name__ == "__main__":

    # Load course metadata
    PROJECT_DIR = dirname(dirname(os.path.abspath(__file__)))
    with open(os.path.join(PROJECT_DIR, "sspcloud", "METADATA.json"), "r") as file:
        md = json.load(file)

    # Main URLs
    LAUNCHER_TMPLT = ("https://datalab.sspcloud.fr/launcher/ide/jupyter"
                      "?autoLaunch=true&onyxia.friendlyName=%C2%ABpython-datascience%C2%BB"
                      "&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-jupyter.sh%C2%BB"
                      "&init.personalInitArgs=%C2%AB{init_args}%C2%BB"
                      "&security.allowlist.enabled=false")
    COURSE_NAME_ENCODED = urllib.parse.quote(md['name'])

    # Build documentation's top block
    doc_json = generate_block(name=md["name"],
                              abstract=md["abstract"],
                              authors=md["authors"],
                              types=md["types"],
                              tags=md["tags"],
                              category=md["category"],
                              img_url=md["imageUrl"]
                              )
    for section in md["sections"].keys():
        # Build section block
        section_md = md["sections"][section]
        section_doc = generate_block(name=section_md["name"],
                                     abstract=section_md["abstract"],
                                     authors=md["authors"],
                                     types=md["types"],
                                     tags=md["tags"],
                                     category=md["category"],
                                     img_url=md["imageUrl"]
                                     )
        if section_md["chapters"]:
            for chapter in section_md["chapters"]:
                # Build chapter block if notebook exists
                MD_PATH = os.path.join(PROJECT_DIR, "content", "course", section, chapter, "index.qmd")

                if os.path.isfile(MD_PATH):
                    name, abstract = extract_metadata_md(MD_PATH)

                    init_args = urllib.parse.quote(f"{section} {chapter}")
                    launcher_url = LAUNCHER_TMPLT.format(init_args=init_args)

                    chapter_doc = generate_block(name=name,
                                                 abstract=abstract,
                                                 authors=md["authors"],
                                                 types=md["types"],
                                                 tags=md["tags"],
                                                 category=md["category"],
                                                 img_url=md["imageUrl"],
                                                 deployment_url=launcher_url
                                                 )
                    section_doc["parts"].append(chapter_doc)

                else:
                    raise FileNotFoundError(f"{MD_PATH} not found.")

        doc_json["parts"].append(section_doc)

    # Export to json
    with open(os.path.join(PROJECT_DIR, "doc.json"), "w") as json_file:
        json.dump(doc_json, json_file, indent=2, ensure_ascii=False)
