/* ==========================================================================
   Jiyoung Yun - portfolio
   Progressive enhancement only. Every piece of content is in the HTML; this
   file adds a theme toggle and an active-section highlight. With JS disabled
   the site is fully readable and navigable.
   ========================================================================== */
(function () {
  "use strict";

  var root = document.documentElement;
  var isKorean = root.lang === "ko";

  var LABEL = isKorean
    ? { dark: "다크 모드로 전환", light: "라이트 모드로 전환" }
    : { dark: "Switch to dark theme", light: "Switch to light theme" };

  /* ----------------------------------------------------------------------
     Theme toggle
     The inline <head> bootstrap has already applied any stored preference.
     This only wires the button and keeps the ARIA state truthful.
     ---------------------------------------------------------------------- */
  function initTheme() {
    var button = document.querySelector(".theme-toggle");
    if (!button) return;

    function currentlyDark() {
      var explicit = root.getAttribute("data-theme");
      if (explicit) return explicit === "dark";
      return window.matchMedia("(prefers-color-scheme: dark)").matches;
    }

    function sync() {
      var dark = currentlyDark();
      button.setAttribute("aria-pressed", String(dark));
      /* The label names the action, not the state - that is what a screen
         reader user needs to decide whether to press it. */
      button.setAttribute("aria-label", dark ? LABEL.light : LABEL.dark);
      button.firstElementChild.innerHTML = dark ? "&#9728;" : "&#9790;";
    }

    button.addEventListener("click", function () {
      var next = currentlyDark() ? "light" : "dark";
      root.setAttribute("data-theme", next);
      try {
        localStorage.setItem("theme", next);
      } catch (e) {
        /* Private browsing and sandboxed frames throw here. The toggle still
           works for this page view; it just will not persist. */
      }
      sync();
    });

    /* Follow the OS if the visitor has never chosen explicitly. */
    var media = window.matchMedia("(prefers-color-scheme: dark)");
    var onChange = function () {
      if (!root.getAttribute("data-theme")) sync();
    };
    if (media.addEventListener) media.addEventListener("change", onChange);
    else if (media.addListener) media.addListener(onChange);

    sync();
  }

  /* ----------------------------------------------------------------------
     Scroll-spy
     IntersectionObserver rather than a scroll listener, so no layout-reading
     work runs on every scroll frame. The rootMargin brackets the viewport
     middle, so the highlighted section is the one you are actually reading.
     ---------------------------------------------------------------------- */
  function initScrollSpy() {
    var links = [].slice.call(document.querySelectorAll(".site-nav a[href^='#']"));
    if (!links.length || !("IntersectionObserver" in window)) return;

    var byId = {};
    var sections = [];

    links.forEach(function (link) {
      var id = link.getAttribute("href").slice(1);
      var section = document.getElementById(id);
      if (!section) return;
      byId[id] = link;
      sections.push(section);
    });

    function mark(id) {
      links.forEach(function (link) {
        if (link.getAttribute("href") === "#" + id) {
          link.setAttribute("aria-current", "location");
        } else {
          link.removeAttribute("aria-current");
        }
      });
    }

    var visible = {};

    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        visible[entry.target.id] = entry.isIntersecting;
      });
      for (var i = 0; i < sections.length; i++) {
        if (visible[sections[i].id]) {
          mark(sections[i].id);
          return;
        }
      }
    }, { rootMargin: "-45% 0px -50% 0px", threshold: 0 });

    sections.forEach(function (section) {
      observer.observe(section);
    });
  }

  /* Each feature is isolated so a failure in one cannot take out the other. */
  try { initTheme(); } catch (e) {}
  try { initScrollSpy(); } catch (e) {}
})();
