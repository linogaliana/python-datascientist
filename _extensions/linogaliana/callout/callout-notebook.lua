-- Liste des types de callouts et leur classe associée
local callouts_all = {
  caution   = "callout-caution", 
  important = "callout-important",
  tip       = "callout-tip", 
  note      = "callout-note", 
  warning   = "callout-warning",
  exercise  = "callout-exercise"
}

-- Fonction pour déterminer le type d’un callout à partir de ses classes
function get_callout_type(div)
  for key, class in pairs(callouts_all) do
    if div.classes:includes(class) then
      return key
    end
  end
  return nil
end

-- Applique le collapse si défini dans les métadonnées
function applyCollapse(div, type, collapse_meta)
  if collapse_meta == nil then return div end

  local collapse_val = nil
  if collapse_meta.all ~= nil then
    collapse_val = collapse_meta.all
  elseif collapse_meta[type] ~= nil then
    collapse_val = collapse_meta[type]
  end

  if collapse_val ~= nil then
    div.attributes["collapse"] = tostring(collapse_val)
  end

  return div
end

-- Création du callout stylisé
function createCallout(div, type, collapse_meta)
  local title = type:gsub("^%l", string.upper)
  -- On conserve l'identifiant du div d'origine, sinon les cross-references
  -- Quarto (ex: @tip-mon-label) ne peuvent plus être résolues une fois le
  -- callout reconstruit ci-dessous.
  local id = div.identifier

  if div.content[1] and div.content[1].t == "Header" then
    title = pandoc.utils.stringify(div.content[1])
    div.content:remove(1)
  end

  -- Appliquer collapse si spécifié
  div = applyCollapse(div, type, collapse_meta)

  if quarto.doc.is_format("ipynb") then
    if type == "exercise" then
      type = "tip"
    end

    local id_attr = (id ~= nil and id ~= "") and (" id=\"" .. id .. "\"") or ""

    local html_start = "<div class=\"callout callout-style-default callout-" .. type .. " callout-titled\"" .. id_attr .. ">\n" ..
      "<div class=\"callout-header d-flex align-content-center\">\n" ..
      "<div class=\"callout-icon-container\">\n<i class=\"callout-icon\"></i>\n</div>\n" ..
      "<div class=\"callout-title-container flex-fill\">\n" .. title .. "\n</div>\n</div>\n" ..
      "<div class=\"callout-body-container callout-body\">\n"

    local html_end = "</div>\n</div>"

    div.content:insert(1, pandoc.RawBlock("html", html_start))
    div.content:insert(pandoc.RawBlock("html", html_end))

    return div
  else
    -- quarto.Callout renvoie deux valeurs : le pointeur opaque (RawInline) à
    -- retourner dans l'AST, et la table résolue du callout (qui porte le
    -- vrai .attr.identifier utilisé par le filtre crossref). Il faut donc
    -- passer l'identifiant sur ce second objet, pas sur le RawInline.
    local raw_callout, resolved_callout = quarto.Callout({
      type = type,
      title = title,
      content = div.content,
      icon = div.attributes["icon"],
      collapse = div.attributes["collapse"] == "true"
    })

    if id ~= nil and id ~= "" and resolved_callout ~= nil then
      resolved_callout.attr.identifier = id
    end

    return raw_callout
  end
end

-- Hook principal
function Div(div)
  local callout_type = get_callout_type(div)
  if callout_type ~= nil then
    local collapse_meta = quarto.doc and quarto.doc.metadata and quarto.doc.metadata["collapse-callout"]
    return createCallout(div, callout_type, collapse_meta)
  end
end