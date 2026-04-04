// ── Live tab cache ────────────────────────────────────────────────────────
//
// We keep an always-up-to-date Map of tabId → tab data so that when the
// command fires we can send it immediately without any async tabs.query().

const tabCache = new Map();

function serialize(t) {
  return {
    id:         t.id,
    windowId:   t.windowId,
    title:      t.title      || "(no title)",
    url:        t.url        || "",
    favIconUrl: t.favIconUrl || "",
    active:     t.active,
    index:      t.index,
  };
}

// Populate cache on startup
browser.tabs.query({}).then((tabs) => {
  for (const t of tabs) tabCache.set(t.id, serialize(t));
});

// Keep cache in sync
browser.tabs.onCreated.addListener((t) => {
  tabCache.set(t.id, serialize(t));
});

browser.tabs.onRemoved.addListener((tabId) => {
  tabCache.delete(tabId);
});

browser.tabs.onUpdated.addListener((tabId, _changeInfo, t) => {
  tabCache.set(tabId, serialize(t));
});

browser.tabs.onActivated.addListener(({ tabId, windowId }) => {
  // Mark previously active tab in the same window as inactive
  for (const [id, t] of tabCache) {
    if (t.windowId === windowId && t.active && id !== tabId) {
      tabCache.set(id, { ...t, active: false });
    }
  }
  const t = tabCache.get(tabId);
  if (t) tabCache.set(tabId, { ...t, active: true });
});

browser.tabs.onMoved.addListener((tabId, { windowId, toIndex }) => {
  const t = tabCache.get(tabId);
  if (t) tabCache.set(tabId, { ...t, windowId, index: toIndex });
});

browser.tabs.onAttached.addListener((tabId, { newWindowId, newPosition }) => {
  const t = tabCache.get(tabId);
  if (t) tabCache.set(tabId, { ...t, windowId: newWindowId, index: newPosition });
});

// ── Command handler ───────────────────────────────────────────────────────

browser.commands.onCommand.addListener(async (command) => {
  if (command !== "open-tab-search") return;

  const [activeTab] = await browser.tabs.query({ active: true, currentWindow: true });
  if (!activeTab) return;

  const tabs = [...tabCache.values()];

  try {
    await browser.tabs.sendMessage(activeTab.id, {
      type: "OPEN_TAB_SEARCH",
      tabs,
    });
  } catch (e) {
    console.warn("Tab Finder: could not message active tab:", e.message);
  }
});

// ── Switch message ────────────────────────────────────────────────────────

browser.runtime.onMessage.addListener(async (message) => {
  if (message.type === "SWITCH_TO_TAB") {
    await browser.tabs.update(message.tabId, { active: true });
    await browser.windows.update(message.windowId, { focused: true });
  }
});
