import os
import re
import markdown
import argparse
from loguru import logger

parser = argparse.ArgumentParser(description="Tweak qmd files for colab.")

parser.add_argument(
    "--overwrite",
    action="store_true",  # This makes it a boolean flag that defaults to False
    help="Enable overwrite mode (default: False)"
)
parser.add_argument(
    "--input_file_path",
    type=str,
    default="./content/getting-started/01_environment.qmd",
    help="Which file should we tweak ?"
)

args = parser.parse_args()


def create_python_snippet(title, content, callout_type):
    """
    Creates a styled HTML callout box for Jupyter Notebook.

    Args:
        title (str): The title of the callout box.
        content (str): The main content of the callout box.
        callout_type (str): The type of callout (e.g., 'note', 'caution', 'warning').

    Returns:
        str: A styled HTML snippet.
    """

    css_file_path = "./build/colab/colab.css"
    if not os.path.exists(css_file_path):
        raise FileNotFoundError(f"{css_file_path} not found. Please ensure the file exists.")

    with open(css_file_path, "r") as css_file:
        style = css_file.read()

    style = f"""
    <style>
    {style}
    </style>
    """

    # Define a dictionary mapping callout types to their respective icons
    icon_mapping = {
        "tip": '<i class="fa-solid fa-lightbulb"></i>',
        "warning": '<i class="fa-solid fa-triangle-exclamation"></i>',
        "important": '<i class="fa-solid fa-circle-exclamation"></i>',
        "caution": '<i class="fa-solid fa-circle-exclamation"></i>',
        "exercise": '<i class="fa-solid fa-pen-fancy"></i>',
    }

    # Use the dictionary to get the icon, with a default value if the type is not found
    icon = icon_mapping.get(callout_type, '<i class="fa-solid fa-comment"></i>')

    content = (
        "\n"
        .join(line for line in content.splitlines() if not line.strip().startswith("#|"))
    )

    content = (
        content
        .replace("{python}", "python")
    )

    content = re.sub(r"```(python)\n(.*?)\n```", r"~~~\1\n\2\n~~~", content, flags=re.DOTALL)

    content_html = f"""
    <div class="callout callout-{callout_type}">
        <div class="callout-header-{callout_type}">
            {icon} {title}
        </div>
        <div class="callout-body">
            {markdown.markdown(content)}
        </div>
    </div>
    """

    content_html = content_html.replace("'", "\\'")


    full_html = (
        "\n"
        "```{python}\n"
        "from IPython.display import HTML\n"
        f"style = '''\n{style}\n'''\n"
        f"content_html = '''\n{content_html}\n'''\n"
        'HTML(f\'<script src=\"https://kit.fontawesome.com/3c27c932d3.js\" crossorigin="anonymous"></script>\\n{style}\\n{content_html}\')\n'
        "\n```"
        "\n"
    )

    return full_html


def substitute_snippets(content, regex):
    """
    Substitute each matched block with a call to create_python_snippet.
    Args:
        content (str): Original text content.
        regex (re.Pattern): Compiled regex pattern to match the blocks.
    Returns:
        str: Updated content with substitutions.
    """

    def replacement(match):
        # Extract the callout type and content
        callout_type_match = re.search(r"\.(\w+)", match.group(0))
        callout_type = callout_type_match.group(1) if callout_type_match else "note"

        # Extract the content inside the block
        content_inside = match.group(1).strip()

        # Look for a title (lines starting with '##')
        title_match = re.search(r"^##\s*(.*)", content_inside, re.MULTILINE)
        if title_match:
            title = title_match.group(1).strip()
            # Remove the title from the content
            content_inside = re.sub(
                r"^##\s*.*", "", content_inside, count=1, flags=re.MULTILINE
            ).strip()
        else:
            title = callout_type.capitalize()

        # Replace with the call to `create_python_snippet`
        snippet = create_python_snippet(
            title=f"{title}", content=content_inside, callout_type=callout_type
        )
        return snippet

    return regex.sub(replacement, content)


def process_file(
    input_file_path, regex_pattern, output_file_path=None,
    overwrite: bool = False
):
    """
    Reads a file, performs snippet substitutions, and writes the updated content to a new file.

    Args:
        input_file_path (str): Path to the input file.
        regex_pattern (str): Regex pattern to identify content blocks.
        output_file_suffix (str): Suffix to append to the input file for the output.

    Returns:
        None
    """


    if overwrite is True:
        logger.debug("Since overwrite argument is True, forcing output_file_path value")
        output_file_path = input_file_path
    else:
        logger.debug("Overwrite argument is False")
        if output_file_path is None:
            output_file_path = input_file_path.replace(".qmd", "_modified.qmd")


    # Check if the input file exists
    if not os.path.exists(input_file_path):
        logger.error(f"Input file does not exist: {input_file_path}")
        return None

    # Read the content of the input file
    logger.info(f"Reading content from {input_file_path}")
    with open(input_file_path, "r") as file:
        original_content = file.read()

    # Compile the regex pattern
    filtered_div_regex = re.compile(regex_pattern, re.MULTILINE)

    # Perform the substitution
    logger.info("Performing substitution of snippets.")
    updated_content_with_snippets = substitute_snippets(
        original_content, filtered_div_regex
    )

    # Write the modified content to the output file
    logger.info(f"Writing updated content to {output_file_path}")
    with open(output_file_path, "w") as file:
        file.write(updated_content_with_snippets)

    logger.success(f"Modified content written to {output_file_path}")


# Example usage
if __name__ == "__main__":
    process_file(
        input_file_path=args.input_file_path,
        regex_pattern=r"::::\s*\{(?:\.note|\.caution|\.warning|\.important|\.tip|\.exercise)\}([\s\S]*?)::::",
        overwrite=args.overwrite
    )
    process_file(
        input_file_path=args.input_file_path,
        regex_pattern=r":::\s*\{(?:\.note|\.caution|\.warning|\.important|\.tip|\.exercise)\}([\s\S]*?):::",
        overwrite=args.overwrite
    )
