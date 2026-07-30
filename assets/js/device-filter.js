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
 * URL HASH PERSISTENCE
 * --------------------
 * The selected filter is reflected in the URL hash: /devices/#software,
 * /devices/#hardware, /devices/#all. On page load, the hash is read and the
 * matching filter is activated. Back/forward navigation restores the
 * corresponding filter state. Changing the filter updates the hash via
 * `history.replaceState` — no new history entries are pushed, so the back
 * button leaves the /devices/ page rather than stepping through filters.
 *
 * KEYBOARD ACCESSIBILITY
 * ----------------------
 * The filter controls are native radio buttons, so arrow-key roving and a
 * single tab stop come free from the platform. This script adds Enter/Space
 * support for toggling the currently focused radio, which is already the
 * default behaviour in every browser — the explicit handler guards against
 * edge cases where a key event is consumed before the platform processes it.
 *
 * ARIA LIVE REGION
 * ----------------
 * A `role="status"` region announces filter changes to screen readers. It is
 * seeded with &nbsp; so VoiceOver registers it (see device-filter.html for the
 * full explanation). The summary paragraph is updated synchronously; the live
 * region only on user-initiated changes, so page-load restoration is silent.
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

  // Build a lookup from value -> input element for hash-based activation.
  var inputByValue = {};
  inputs.forEach(function (inp) {
    inputByValue[inp.value] = inp;
  });

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

  // ---- URL HASH PERSISTENCE ----
  // Reads the hash, maps it to a filter value, and updates the URL with
  // `replaceState` when the user changes filters. No history push — back
  // should leave /devices/, not step through filter changes.
  function readHash() {
    var raw = window.location.hash.replace(/^#/, "").toLowerCase();
    // Map known hash values to filter values. Anything unrecognised
    // (including no hash at all) falls back to "all".
    var map = { all: "all", software: "software", hardware: "hardware" };
    return map[raw] || "all";
  }

  function writeHash(value) {
    var newHash = value === "all" ? "" : "#" + value;
    var currentHash = window.location.hash;
    if (("#" + value) !== currentHash && newHash !== currentHash) {
      try {
        history.replaceState(null, "", newHash || window.location.pathname);
      } catch (_) {
        // replaceState can throw in some sandboxed environments — the
        // filter still works, the hash just won't update.
      }
    }
  }

  // Activate the input matching the given value.
  function activateFilter(value) {
    var target = inputByValue[value];
    if (!target) return;
    target.checked = true;
    apply(target, false);
  }

  // ---- KEYBOARD HANDLING ----
  // Radio groups already handle arrow keys and tab natively. We add explicit
  // Enter/Space handlers to toggle the focused radio, which is the default
  // behaviour in every browser — the explicit handler guards against edge
  // cases where a key event is consumed before platform processing.
  function onFilterKeydown(event) {
    var target = event.target;
    if (!target || !target.classList.contains("lb-filter__input")) return;

    if (event.key === "Enter" || event.key === " ") {
      // Space can scroll the page — prevent that.
      if (event.key === " ") event.preventDefault();

      // Only act if this radio isn't already checked (prevents double-fire).
      if (!target.checked) {
        target.checked = true;
        apply(target, true);
        writeHash(target.value);
      }
    }
  }

  // ---- EVENT BINDING ----
  inputs.forEach(function (input) {
    input.addEventListener("change", function () {
      if (input.checked) {
        apply(input, true);
        writeHash(input.value);
      }
    });

    input.addEventListener("keydown", onFilterKeydown);
  });

  // Handle back/forward navigation (hashchange).
  window.addEventListener("hashchange", function () {
    var value = readHash();
    activateFilter(value);
  });

  tpl.parentNode.insertBefore(fragment, tpl);

  // ---- INITIAL STATE ----
  // Restore from URL hash if present, otherwise default to "all".
  var initialValue = readHash();
  if (initialValue !== "all") {
    activateFilter(initialValue);
    writeHash(initialValue);
  } else {
    // Default: "all" is checked in the markup. But a back/forward
    // navigation could have changed the checked state via the browser's
    // own form-restoration, so read the group rather than assuming.
    var checked = inputs.filter(function (i) { return i.checked; })[0] || inputs[0];
    checked.checked = true;
    apply(checked, false);
  }
})();
