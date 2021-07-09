// Copy to clipboard -----------------------------------------------------------
// see https://github.com/maelle/bookdown/blob/f37a91af07ad5c815809b7ce8dd5dfb5af3a0cdb/inst/resources/bs4_book/bs4_book.js

function changeTooltipMessage(element, msg) {
  var tooltipOriginalTitle=element.getAttribute('data-original-title');
  element.setAttribute('data-original-title', msg);
  $(element).tooltip('show');
  element.setAttribute('data-original-title', tooltipOriginalTitle);
}

$(document).ready(function() {
  if(ClipboardJS.isSupported()) {
    // Insert copy buttons
    var copyButton = "<div class='copy'><button type='button' class='btn btn-copy' title='Copy to clipboard' aria-label='Copy to clipboard' data-toggle='popover' data-placement='top' data-trigger='hover'><i class='bi'></i></button></div>";
    $(copyButton).prependTo("pre.code");
    // Initialize tooltips:
    $('.btn-copy').tooltip({container: 'body', boundary: 'window'});

    // Initialize clipboard:
    var clipboard = new ClipboardJS('.btn-copy', {
      text: function(trigger) {
        return trigger.parentNode.nextSibling.textContent;
      }
    });

    clipboard.on('success', function(e) {
      const btn = e.trigger;
      changeTooltipMessage(btn, 'Copied!');
      btn.classList.add('btn-copy-checked');
      setTimeout(function() {
        btn.classList.remove('btn-copy-checked');
      }, 2000);
      e.clearSelection();
    });

    clipboard.on('error', function() {
      changeTooltipMessage(e.trigger,'Press Ctrl+C or Command+C to copy');
    });
  };
});