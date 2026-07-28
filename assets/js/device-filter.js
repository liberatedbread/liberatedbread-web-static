/*
 * Liberated Bread — device catalogue filter.
 * DESIGN §9.4 (no-JS fallbacks) and §14.2 item 4.
 *
 * PROGRESSIVE ENHANCEMENT CONTRACT
 * --------------------------------
 * The page is complete before this file runs. Every card in _data/devices.yml
 * is already in the DOM and visible; nothing is hidden at render time. All this
 * script does is un-inert the controls that _includes/device-filter.html parked
 * inside a <template> — which the parser does not render — and then hide the
 * cards that do not match. If the file 404s, is blocked, or throws on an old
 * browser, /devices/ is still exactly the page it was before: the full catalogue.
 *
 * NO CLASSES ARE ADDED OR REMOVED HERE, and that is deliberate. Tailwind only
 * compiles classes it finds in the paths it scans, and it never scans .js — a
 * class applied only at runtime silently fails to exist in assets/tailwind.css.
 * So visibility is driven by one attribute, `data-lb-hidden`, backed by a single
 * hand-written rule in src/input.css that cannot be tree-shaken away.
 *
 * Accessibility: the controls are a native radio group, so selection semantics,
 * arrow-key roving focus and the single group tab stop come from the platform.
 * Focus never moves out from under the user — the radio they operated keeps it —
 * and the change in the visible set is announced through a polite live region.
 */
(function () {
  "use strict";

  var tpl = document.getElementById("lb-device-filter-template");
  var grid = document.querySelector("[data-lb-device-grid]");

  // `content` guards browsers that parse <template> as an ordinary element:
  // there, its children would already be on the page and cloning would double
  // them. Bailing leaves the unfiltered catalogue, which is the correct page.
  if (!tpl || !grid || !("content" in tpl)) return;

  var cards = Array.prototype.slice.call(grid.querySelectorAll("[data-device-type]"));
  if (!cards.length) return;

  var fragment = tpl.content.cloneNode(true);
  // Query the fragment before inserting it: insertion empties the fragment,
  // though the element references taken from it stay valid.
  var inputs = Array.prototype.slice.call(fragment.querySelectorAll(".lb-filter__input"));
  var summary = fragment.querySelector("[data-lb-filter-summary]");
  var announce = fragment.querySelector("[data-lb-filter-announce]");
  var empty = fragment.querySelector("[data-lb-filter-empty]");
  if (!inputs.length || !summary) return;

  var total = cards.length;

  function describe(value, label, shown) {
    if (shown === 0) return "No devices match " + label + ".";
    if (value === "all") return "Showing all " + total + (total === 1 ? " device." : " devices.");
    return "Showing " + shown + " of " + total + " devices: " + label.toLowerCase() + ".";
  }

  function apply(input, isUserChange) {
    var value = input.value;
    var label = input.getAttribute("data-label") || value;
    var shown = 0;

    cards.forEach(function (card) {
      if (value === "all" || card.getAttribute("data-device-type") === value) {
        card.removeAttribute("data-lb-hidden");
        shown++;
      } else {
        card.setAttribute("data-lb-hidden", "");
      }
    });

    var text = describe(value, label, shown);
    summary.textContent = text;

    if (empty) {
      empty.textContent = text;
      if (shown === 0) empty.removeAttribute("data-lb-hidden");
      else empty.setAttribute("data-lb-hidden", "");
    }

    // Only ever written for a change the user made. The region ships seeded
    // with a &nbsp; so VoiceOver registers it (see _includes/device-filter.html)
    // — that is not content, it is registration. Putting the summary in here at
    // insertion time gets announced by some screen readers as if something had
    // happened, and on page load nothing has.
    if (announce && isUserChange) announce.textContent = text;
  }

  inputs.forEach(function (input) {
    input.addEventListener("change", function () {
      if (input.checked) apply(input, true);
    });
  });

  tpl.parentNode.insertBefore(fragment, tpl);

  // A back/forward navigation can restore a previously checked radio, so read
  // the group rather than assuming the markup default is still the live one.
  var checked = inputs.filter(function (i) { return i.checked; })[0] || inputs[0];
  checked.checked = true;
  apply(checked, false);
})();
