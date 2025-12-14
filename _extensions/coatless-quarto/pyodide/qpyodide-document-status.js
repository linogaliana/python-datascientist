// Declare startupMessageqpyodide globally
globalThis.qpyodideStartupMessage = document.createElement("p");

// Function to set the button text
globalThis.qpyodideSetInteractiveButtonState = function(buttonText, enableCodeButton = true) {
  document.querySelectorAll(".qpyodide-button-run").forEach((btn) => {
    btn.innerHTML = buttonText;
    btn.disabled = !enableCodeButton;
  });
}

// Function to update the status message in non-interactive cells
globalThis.qpyodideUpdateStatusMessage = function(message) {
  document.querySelectorAll(".qpyodide-status-text.qpyodide-cell-needs-evaluation").forEach((elem) => {
    elem.innerText = message;
  });
}

// Function to update the status message
globalThis.qpyodideUpdateStatusHeader = function(message) {

  if (!qpyodideShowStartupMessage) return;

  qpyodideStartupMessage.innerHTML = message;
}

// Status header update with customized spinner message
globalThis.qpyodideUpdateStatusHeaderSpinner = function(message) {

  qpyodideUpdateStatusHeader(`
    <i class="fa-solid fa-spinner fa-spin qpyodide-icon-status-spinner"></i>
    <span>${message}</span>
  `);
}


// Function that attaches the document status message
function qpyodideDisplayStartupMessage(showStartupMessage) {
  if (!showStartupMessage) {
    return;
  }

  // Get references to header elements
  const headerHTML = document.getElementById("title-block-header");
  const headerRevealJS = document.getElementById("title-slide");

  // Create the outermost div element for metadata
  const quartoTitleMeta = document.createElement("div");
  quartoTitleMeta.classList.add("quarto-title-meta");

  // Create the first inner div element
  const firstInnerDiv = document.createElement("div");
  firstInnerDiv.setAttribute("id", "qpyodide-status-message-area");

  // Create the second inner div element for "Pyodide Status" heading and contents
  const secondInnerDiv = document.createElement("div");
  secondInnerDiv.setAttribute("id", "qpyodide-status-message-title");
  secondInnerDiv.classList.add("quarto-title-meta-heading");
  secondInnerDiv.innerText = "Pyodide Status";

  // Create another inner div for contents
  const secondInnerDivContents = document.createElement("div");
  secondInnerDivContents.setAttribute("id", "qpyodide-status-message-body");
  secondInnerDivContents.classList.add("quarto-title-meta-contents");

  // Describe the Pyodide state
  qpyodideStartupMessage.innerText = "🟡 Loading...";
  qpyodideStartupMessage.setAttribute("id", "qpyodide-status-message-text");
  // Add `aria-live` to auto-announce the startup status to screen readers
  qpyodideStartupMessage.setAttribute("aria-live", "assertive");

  // Append the startup message to the contents
  secondInnerDivContents.appendChild(qpyodideStartupMessage);

  // Combine the inner divs and contents
  firstInnerDiv.appendChild(secondInnerDiv);
  firstInnerDiv.appendChild(secondInnerDivContents);
  quartoTitleMeta.appendChild(firstInnerDiv);

  // Determine where to insert the quartoTitleMeta element
  if (headerHTML || headerRevealJS) {
    // Append to the existing "title-block-header" element or "title-slide" div
    (headerHTML || headerRevealJS).appendChild(quartoTitleMeta);
  } else {
    // If neither headerHTML nor headerRevealJS is found, insert after "Pyodide-monaco-editor-init" script
    const monacoScript = document.getElementById("qpyodide-monaco-editor-init");
    const header = document.createElement("header");
    header.setAttribute("id", "title-block-header");
    header.appendChild(quartoTitleMeta);
    monacoScript.after(header);
  }
}

qpyodideDisplayStartupMessage(qpyodideShowStartupMessage);