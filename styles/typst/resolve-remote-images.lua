-- Contournement de quarto-dev/quarto-cli#7962 (partiel): Typst n'a pas
-- d'accès réseau, et la résolution interne de Quarto qui télécharge les
-- images distantes dans le mediabag pour Typst ne s'applique pas quand
-- l'image est enveloppée pour l'alignement (attribut `fig-align`, avec ou
-- sans `width`), ce qui produit `#align(...)[#box(image("https://..."))]`
-- où l'URL reste distante -> "network access is not supported" à la
-- compilation. Comme toutes les images du site sont distantes (servies
-- depuis minio, aucune copie locale dans le repo), ça peut toucher
-- n'importe quel chapitre.
--
-- On force donc, pour toute image distante et uniquement en sortie Typst,
-- le téléchargement et la réécriture vers un chemin local (relatif au
-- fichier de sortie, dans `_typst-image-cache/`), avant que Quarto ne
-- génère le code Typst. Une même URL n'est téléchargée qu'une fois par
-- rendu (les images sont dédupliquées par leur hash).

local function is_remote(src)
  return src ~= nil and src:match("^https?://") ~= nil
end

function Image(img)
  if not quarto.doc.isFormat("typst") then
    return img
  end
  if not is_remote(img.src) then
    return img
  end
  local ok, mt, contents = pcall(pandoc.mediabag.fetch, img.src)
  if not ok or not contents then
    quarto.log.warning("resolve-remote-images: échec du téléchargement de " .. img.src)
    return img
  end
  local ext = img.src:match("%.([%a%d]+)$") or "bin"
  local hash = pandoc.utils.sha1(img.src)
  local rel_dir = "_typst-image-cache"
  local rel_path = rel_dir .. "/" .. hash .. "." .. ext
  os.execute('mkdir -p "' .. rel_dir .. '"')
  local f = io.open(rel_path, "wb")
  if f then
    f:write(contents)
    f:close()
    img.src = rel_path
  else
    quarto.log.warning("resolve-remote-images: écriture impossible: " .. rel_path)
  end
  return img
end
