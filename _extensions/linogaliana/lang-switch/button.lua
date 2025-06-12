function RawBlock(el)
  local output_file = PANDOC_STATE.output_file or ""
  local is_english = output_file:match("^en/")

  if el.format ~= "html" then return end

  -- Code HTML du bouton avec SVG
  local label, url, flag_svg
  if is_english then
    label = "Passer à la version française"
    url = string.gsub(output_file, "^en/", "")
    flag_svg = [[
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="20" height="20" style="vertical-align: middle; margin-left: 0.5em; display: inline-block;"><mask id="circleFlagsLangFr"><circle cx="256" cy="256" r="256" fill="#fff"/></mask><g mask="url(#circleFlagsLangFr)"><path fill="#0055A4" d="M0 0h512v512H0z"/><path fill="#fff" d="M170.7 0h170.6v512H170.7z"/><path fill="#EF4135" d="M341.3 0H512v512H341.3z"/></g></svg>
    ]]
  else
    label = "Switch to English version"
    url = "en/" .. output_file
    flag_svg = [[
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="20" height="20" style="vertical-align: middle; margin-left: 0.5em; display: inline-block;"><mask id="circleFlagsLangEn"><circle cx="256" cy="256" r="256" fill="#fff"/></mask><g mask="url(#circleFlagsLangEn)"><path fill="#eee" d="M256 0L0 256v64l32 32l-32 32v128l22-8l23 8h23l54-32l54 32h32l48-32l48 32h32l54-32l54 32h68l-8-22l8-23v-23l-32-54l32-54v-32l-32-48l32-48v-32l-32-54l32-54V0z"/><path fill="#d80027" d="M224 64v64h160l64-64zm0 128l32 64l-48 48v208h96V304h208v-96H304l16-16zM0 320v64h128l-64 64H0v64h45l131-131v-45l16-16zm336 16l176 176v-45L381 336Z"/><path fill="#0052b4" d="M0 0v256h256V0zm512 68L404 176h108zM404 336l108 108V336zm-228 68L68 512h108zm160 0v108h108z"/><path fill="#eee" d="m187 243l57-41h-70l57 41l-22-67zm-81 0l57-41H93l57 41l-22-67zm-81 0l57-41H12l57 41l-22-67zm162-81l57-41h-70l57 41l-22-67zm-81 0l57-41H93l57 41l-22-67zm-81 0l57-41H12l57 41l-22-67Zm162-82l57-41h-70l57 41l-22-67zm-81 0l57-41H93l57 41l-22-67Zm-81 0l57-41H12l57 41l-22-67Z"/></g></svg>
    ]]
  end

  local button_html = string.format([[
    <div class="lang-switch-button" style="text-align:right; margin-top:1rem; margin-bottom:1rem;">
      <a href="/%s" class="button-cta">
        <button class="btn"><i class="fa fa-language"></i> %s %s</button>
      </a>
    </div>
  ]], url, label, flag_svg)

  -- Injection du bouton si le bloc contient <main id="quarto-document-content">
  if el.text:match('<main.-id="quarto%-document%-content".->') then
    return {
      el,
      pandoc.RawBlock("html", button_html)
    }
  end
end
