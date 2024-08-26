-- badges.lua

-- Helper function to generate badge HTML
function make_badge(link, image_url, alt_text)
    return string.format('<a href="%s" target="_blank" rel="noopener"><img src="%s" alt="%s"></a>', link, image_url, alt_text)
end

-- Function to create the badges
function reminder_badges(args)
    -- Get the current file path if fpath is not provided
    local sourceFile = args.fpath or quarto.doc["input_file"]
    local type = args.type or 'html'
    local split = args.split or nil
    local onyxiaOnly = args.onyxiaOnly or false
    local sspCloudService = args.sspCloudService or "python"
    local GPU = args.GPU or false
    local correction = args.correction or false

    local notebook = sourceFile:gsub("(.Rmd|.qmd)$", ".ipynb")
    if correction then
        notebook = notebook:gsub("content", "corrections")
    else
        notebook = notebook:gsub("content", "notebooks")
    end

    local githubRepoNotebooksSimplified = "github/linogaliana/python-datascientist-notebooks"
    local githubAlias = githubRepoNotebooksSimplified:gsub("github", "github.com")
    local githubRepoNotebooks = "https://" .. githubAlias

    local githubLink = githubRepoNotebooks .. "/blob/main" .. "/" .. notebook
    local githubBadge = make_badge(githubLink, "https://img.shields.io/static/v1?logo=github&label=&message=View%20on%20GitHub&color=181717", "View on GitHub")

    local section, chapter = notebook:match("([^/]+)/([^/]+)$")
    local chapterNoExtension = chapter:gsub("%.ipynb$", "")

    local onyxiaInitArgs = { section, chapterNoExtension }
    if correction then
        table.insert(onyxiaInitArgs, "correction")
    end

    local gpuSuffix = GPU and "-gpu" or ""

    local sspcloudJupyterLinkLauncher = string.format(
        "https://datalab.sspcloud.fr/launcher/ide/jupyter-%s%s?autoLaunch=true&onyxia.friendlyName=%s&init.personalInit=%s&init.personalInitArgs=%s&security.allowlist.enabled=false",
        sspCloudService, gpuSuffix, chapterNoExtension, "https%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-jupyter.sh",
        table.concat(onyxiaInitArgs, "%20")
    )

    local sspcloudJupyterBadge = make_badge(sspcloudJupyterLinkLauncher, "https://img.shields.io/badge/SSP%20Cloud-Tester_avec_Jupyter-orange?logo=Jupyter&logoColor=orange", "Onyxia")

    local sspcloudVscodeLinkLauncher = string.format(
        "https://datalab.sspcloud.fr/launcher/ide/vscode-%s%s?autoLaunch=true&onyxia.friendlyName=%s&init.personalInit=%s&init.personalInitArgs=%s&security.allowlist.enabled=false",
        sspCloudService, gpuSuffix, chapterNoExtension, "https%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-vscode.sh",
        table.concat(onyxiaInitArgs, "%20")
    )

    local sspcloudVscodeBadge = make_badge(sspcloudVscodeLinkLauncher, "https://img.shields.io/badge/SSP%20Cloud-Tester_avec_VSCode-blue?logo=visualstudiocode&logoColor=blue", "Onyxia")

    local colabLink = string.format(
        "https://colab.research.google.com/github/linogaliana/python-datascientist-notebooks/blob/main/%s",
        notebook
    )

    local colabBadge = make_badge(colabLink, "https://colab.research.google.com/assets/colab-badge.svg", "Open In Colab")

    local badges = { githubBadge, sspcloudVscodeBadge, sspcloudJupyterBadge }

    if not onyxiaOnly then
        table.insert(badges, colabBadge)
    end

    return table.concat(badges, type == "html" and "\n" or " ")
end

-- Main function to print badges
function print_badges(args)
    return reminder_badges(args)
end
