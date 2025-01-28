import os
import re
import markdown

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
    style = """
    <style>
    .callout {
        border: 2px solid #d1d5db;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        margin-bottom: 20px;
        background-color: #ffffff;
        padding: 15px;
    }
    .callout-header {
        font-weight: bold;
        margin-bottom: 10px;
        color: #ffffff;
        background-color: #1d4ed8;
        padding: 10px;
        border-radius: 6px 6px 0 0;
    }
    .callout-body {
        margin: 10px 0;
    }
    </style>
    """

    content_html = f"""
    <div class="callout callout-{callout_type}">
        <div class="callout-header">
            {title}
        </div>
        <div class="callout-body">
            {markdown.markdown(content)}
        </div>
    </div>
    """

    full_html = (
        "\n"
        "```{python}\n"
        "from IPython.display import HTML\n"
        f"style = '''\n{style}\n'''\n"
        f"content_html = '''\n{content_html}\n'''\n"
        'HTML(f"{style}\\n{content_html}")\n'
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
            content_inside = re.sub(r"^##\s*.*", "", content_inside, count=1, flags=re.MULTILINE).strip()
        else:
            title = callout_type.capitalize()

        # Replace with the call to `create_python_snippet`
        snippet = create_python_snippet(
            title=f"{title}",
            content=content_inside,
            callout_type=callout_type
        )
        return snippet
    
    return regex.sub(replacement, content)



# Define file paths
input_file_path = "./content/getting-started/01_environment.qmd"
output_file_path = input_file_path.replace(".qmd", "_modified.qmd")


# Read the content of the input file
if not os.path.exists(input_file_path):
    print(f"Input file does not exist: {input_file_path}")
    exit(1)

with open(input_file_path, "r") as file:
    original_content = file.read()


filtered_div_regex = re.compile(
    r":::\s*\{(?:\.note|\.caution|\.warning|\.important|\.tip|\.exercise)\}([\s\S]*?):::",
    re.MULTILINE
)

# Perform the substitution
updated_content_with_snippets = substitute_snippets(original_content, filtered_div_regex)

# Write the modified content to the output file
with open(output_file_path, "w") as file:
    file.write(updated_content_with_snippets)

print(f"Modified content written to {output_file_path}")
