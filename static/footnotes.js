function getFootnoteContent(index) {
    const id = "fn:" + index;
    const fn = document.getElementById(id);
    return fn.innerHTML.trim();
};

function footnotePopup(showIndex, showCloseBtn) {
    const popupWrapper = document.querySelector("#popup-wrapper");

    // Set whether to display index and/or close button. Default is true for both
    if (showIndex === undefined) {
        showIndex = true;
    }

    if (showCloseBtn === undefined) {
        showCloseBtn = true;
    }

    // Create main container that will hold footnote content
    const popupContent = popupWrapper.appendChild(document.createElement("div"));
    popupContent.id = "popup-content";

    let popupIndex = null;
    if (showIndex) {
        popupIndex = popupWrapper.insertBefore(document.createElement("div"), popupContent);
        popupIndex.id = "popup-index";
    }

    let popupCloseButton = null;
    if (showCloseBtn) {
        popupCloseButton = popupWrapper.appendChild(document.createElement("div"));
        popupCloseButton.innerHTML = "[x]";
        popupCloseButton.id = "popup-close";
    }

    // Remove redundant [return] links from footnote list (optional)
    const fnReturns = document.querySelectorAll("a.footnote-return");
    fnReturns.forEach(function(fnReturn) {
        const parent = fnReturn.parentNode;
        parent.removeChild(fnReturn);
    });

    const fnRefs = document.querySelectorAll("sup[id^='fnref:']");
    fnRefs.forEach(function(fnRef) {
        fnRef.addEventListener("click", handler("refs", fnRef));
    });

    window.addEventListener("scroll", handler("close"));

    if (showCloseBtn) {
        popupCloseButton.addEventListener("click", handler("close"));
    }

    function handler(type, node) {
        return function(event) {
            if (type === "close") {
                popupWrapper.style.display = "none";
            }

            if (type === "refs") {
                event.preventDefault();

                const index = node.id.substring(6);

                if (showIndex) {
                    popupIndex.innerHTML = index + ".";
                }

                popupContent.innerHTML = getFootnoteContent(index);
                popupWrapper.style.display = "flex";
            }
        };
    };
};

footnotePopup(true, true);