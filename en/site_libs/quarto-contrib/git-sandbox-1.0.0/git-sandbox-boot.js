/* Drains the queue of exercises the Quarto filter pushed onto the page.
   Loaded after body, once, by the git-sandbox extension. */
(function () {
  if (window.GitSandboxUI && typeof window.GitSandboxUI.boot === 'function') {
    window.GitSandboxUI.boot();
  }
})();
