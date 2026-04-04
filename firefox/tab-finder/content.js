(() => {
  if (document.getElementById("tab-finder-root")) return;

  let allTabs = [];
  let filtered = []; // array of { tab, score, titleIndices }
  let selectedIndex = 0;

  // ── Fuzzy search ──────────────────────────────────────────────────────────

  function fuzzyMatch(query, text) {
    const q = query.toLowerCase();
    const t = text.toLowerCase();

    if (!q) return { matched: true, score: 0, indices: [] };

    let qi = 0;
    const indices = [];
    for (let ti = 0; ti < t.length && qi < q.length; ti++) {
      if (t[ti] === q[qi]) { indices.push(ti); qi++; }
    }
    if (qi < q.length) return { matched: false, score: -Infinity, indices: [] };

    let score = 0;
    let run = 1;
    for (let i = 1; i < indices.length; i++) {
      if (indices[i] === indices[i - 1] + 1) { run++; score += run * 10; }
      else { run = 1; }
    }

    if (indices[0] === 0) score += 20;
    const boundary = /[\s\-_./\\:]/;
    for (const idx of indices) {
      if (idx === 0 || boundary.test(t[idx - 1])) score += 15;
    }

    if (t.includes(q)) score += 100;
    score -= indices[indices.length - 1];

    return { matched: true, score, indices };
  }

  // ── Highlighted HTML ──────────────────────────────────────────────────────

  function buildHighlight(text, indices) {
    if (!indices || indices.length === 0) return escapeHtml(text);
    const matchSet = new Set(indices);
    let html = "";
    for (let i = 0; i < text.length; i++) {
      const ch = escapeHtml(text[i]);
      html += matchSet.has(i) ? `<mark>${ch}</mark>` : ch;
    }
    return html.replace(/<\/mark><mark>/g, "");
  }

  // ── Favicon / letter avatar ───────────────────────────────────────────────

  const AVATAR_COLORS = [
    "#3b82f6","#8b5cf6","#ec4899","#f59e0b",
    "#10b981","#ef4444","#06b6d4","#f97316",
  ];

  function avatarColor(str) {
    let h = 0;
    for (let i = 0; i < str.length; i++) h = (h * 31 + str.charCodeAt(i)) >>> 0;
    return AVATAR_COLORS[h % AVATAR_COLORS.length];
  }

  function faviconHtml(tab) {
    const letter = (tab.title || tab.url || "?")[0].toUpperCase();
    let domain = "";
    try { domain = new URL(tab.url).hostname; } catch { domain = tab.title || ""; }
    const color = avatarColor(domain || tab.title);

    const placeholder = `<span class="tf-favicon tf-avatar" style="background:${color}">${escapeHtml(letter)}</span>`;

    if (!tab.favIconUrl || tab.favIconUrl.startsWith("chrome://") || tab.favIconUrl.startsWith("moz-extension://")) {
      return placeholder;
    }

    return `<img class="tf-favicon" src="${escapeHtml(tab.favIconUrl)}" width="16" height="16"
      data-letter="${escapeHtml(letter)}" data-color="${escapeHtml(color)}" />`;
  }

  function patchFaviconErrors(container) {
    container.querySelectorAll("img.tf-favicon").forEach((img) => {
      img.addEventListener("error", () => {
        const span = document.createElement("span");
        span.className = "tf-favicon tf-avatar";
        span.style.background = img.dataset.color || "#555";
        span.textContent = img.dataset.letter || "?";
        img.replaceWith(span);
      }, { once: true });
    });
  }

  // ── DOM ───────────────────────────────────────────────────────────────────

  function buildOverlay() {
    const root = document.createElement("div");
    root.id = "tab-finder-root";
    root.setAttribute("role", "dialog");
    root.setAttribute("aria-modal", "true");
    root.setAttribute("aria-label", "Tab search");

    root.innerHTML = `
      <div id="tf-backdrop"></div>
      <div id="tf-modal">
        <div id="tf-search-wrap">
          <span id="tf-icon">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="6.5" cy="6.5" r="4.5" stroke="currentColor" stroke-width="1.5"/>
              <line x1="10.5" y1="10.5" x2="14" y2="14" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
          </span>
          <input id="tf-input" type="text" placeholder="Search tabs…"
            autocomplete="off" spellcheck="false" />
          <span id="tf-count"></span>
        </div>
        <ul id="tf-list" role="listbox"></ul>
        <div id="tf-footer">
          <span><kbd>↑</kbd><kbd>↓</kbd> navigate</span>
          <span><kbd>PgUp</kbd><kbd>PgDn</kbd> page</span>
          <span><kbd>↵</kbd> switch</span>
          <span><kbd>Esc</kbd> close</span>
        </div>
      </div>`;

    document.body.appendChild(root);
    root.querySelector("#tf-backdrop").addEventListener("click", closeOverlay);
    root.querySelector("#tf-input").addEventListener("input", onInput);
    root.addEventListener("keydown", onKeyDown);
    return root;
  }

  // ── Rendering ─────────────────────────────────────────────────────────────

  // Full rebuild — only called when the filtered list itself changes (on input).
  function renderList() {
    const list    = document.getElementById("tf-list");
    const countEl = document.getElementById("tf-count");
    if (!list) return;

    countEl.textContent = `${filtered.length} tab${filtered.length !== 1 ? "s" : ""}`;

    if (filtered.length === 0) {
      list.innerHTML = `<li class="tf-empty">No tabs match</li>`;
      return;
    }

    list.innerHTML = filtered.map(({ tab, titleIndices }, i) => {
      const isSelected = i === selectedIndex;
      const title = buildHighlight(tab.title, titleIndices);
      const url   = escapeHtml(truncateUrl(tab.url));
      return `
        <li class="tf-item${isSelected ? " tf-selected" : ""}"
          role="option" aria-selected="${isSelected}" data-index="${i}">
          ${faviconHtml(tab)}
          <span class="tf-text">
            <span class="tf-title">${title}</span>
            <span class="tf-url">${url}</span>
          </span>
          ${tab.active ? `<span class="tf-badge">current</span>` : ""}
        </li>`;
    }).join("");

    patchFaviconErrors(list);

    list.querySelectorAll(".tf-item").forEach((el) => {
      el.addEventListener("click", () => {
        const idx = parseInt(el.dataset.index, 10);
        switchToTab(filtered[idx].tab);
      });
    });

    list.querySelector(".tf-selected")?.scrollIntoView({ block: "nearest" });
  }

  // Cheap selection move — only swaps a CSS class and scrolls, never rebuilds innerHTML.
  // Called on every arrow/page key press.
  function moveSelection(newIndex) {
    const list = document.getElementById("tf-list");
    if (!list || filtered.length === 0) return;

    newIndex = Math.max(0, Math.min(newIndex, filtered.length - 1));
    if (newIndex === selectedIndex) return;

    const prev = list.querySelector(".tf-selected");
    if (prev) {
      prev.classList.remove("tf-selected");
      prev.setAttribute("aria-selected", "false");
    }

    selectedIndex = newIndex;
    const next = list.querySelector(`[data-index="${selectedIndex}"]`);
    if (next) {
      next.classList.add("tf-selected");
      next.setAttribute("aria-selected", "true");
      next.scrollIntoView({ block: "nearest" });
    }
  }

  function pageSize() {
    const list = document.getElementById("tf-list");
    if (!list || filtered.length === 0) return 8;
    const firstItem = list.querySelector(".tf-item");
    if (!firstItem) return 8;
    return Math.max(1, Math.floor(list.clientHeight / firstItem.offsetHeight));
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  function filterTabs(query) {
    const q = query.trim();

    if (!q) {
      filtered = allTabs.map((tab) => ({
        tab, score: tab.active ? 1 : 0, titleIndices: [],
      }));
      filtered.sort((a, b) => b.score - a.score);
      return;
    }

    const results = [];
    for (const tab of allTabs) {
      const byTitle = fuzzyMatch(q, tab.title);
      const byUrl   = fuzzyMatch(q, truncateUrl(tab.url));
      if (!byTitle.matched && !byUrl.matched) continue;

      const score = Math.max(byTitle.score, byUrl.score);
      const titleIndices = byTitle.matched ? byTitle.indices : [];
      results.push({ tab, score, titleIndices });
    }

    results.sort((a, b) => b.score - a.score);
    filtered = results;
    selectedIndex = 0;
  }

  // ── Events ────────────────────────────────────────────────────────────────

  function onInput(e) {
    filterTabs(e.target.value);
    renderList();
  }

  function onKeyDown(e) {
    switch (e.key) {
      case "Escape":
        e.preventDefault();
        closeOverlay();
        break;
      case "ArrowDown":
        e.preventDefault();
        moveSelection(selectedIndex + 1);
        break;
      case "ArrowUp":
        e.preventDefault();
        moveSelection(selectedIndex - 1);
        break;
      case "PageDown":
        e.preventDefault();
        moveSelection(selectedIndex + pageSize());
        break;
      case "PageUp":
        e.preventDefault();
        moveSelection(selectedIndex - pageSize());
        break;
      case "Home":
        e.preventDefault();
        moveSelection(0);
        break;
      case "End":
        e.preventDefault();
        moveSelection(filtered.length - 1);
        break;
      case "Enter":
        e.preventDefault();
        if (filtered[selectedIndex]) switchToTab(filtered[selectedIndex].tab);
        break;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  function switchToTab(tab) {
    browser.runtime.sendMessage({ type: "SWITCH_TO_TAB", tabId: tab.id, windowId: tab.windowId });
    closeOverlay();
  }

  function closeOverlay() {
    const root = document.getElementById("tab-finder-root");
    if (root) {
      root.classList.add("tf-closing");
      root.addEventListener("animationend", () => root.remove(), { once: true });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, "&amp;").replace(/</g, "&lt;")
      .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  }

  function truncateUrl(url) {
    try {
      const u = new URL(url);
      return u.hostname + (u.pathname !== "/" ? u.pathname : "");
    } catch { return url; }
  }

  // ── Entry point ───────────────────────────────────────────────────────────

  browser.runtime.onMessage.addListener((message) => {
    if (message.type !== "OPEN_TAB_SEARCH") return;

    if (document.getElementById("tab-finder-root")) { closeOverlay(); return; }

    allTabs = message.tabs;
    filterTabs("");
    buildOverlay();
    renderList();
    requestAnimationFrame(() => document.getElementById("tf-input")?.focus());
  });
})();
