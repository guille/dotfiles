import re
from typing import Dict, Optional

import sublime_plugin

import sublime

_WORD_ONLY = re.compile(r"\w+")

# view id -> the region this command added last, so repeated presses walk forward
# from it instead of from the bottom-most selection.
_last_added: Dict[int, sublime.Region] = {}


def _is_word_char(view: sublime.View, pt: int) -> bool:
    if pt < 0 or pt >= view.size():
        return False
    return bool(_WORD_ONLY.match(view.substr(sublime.Region(pt, pt + 1))))


def _is_whole_word(view: sublime.View, region: sublime.Region) -> bool:
    if not _WORD_ONLY.fullmatch(view.substr(region)):
        return False
    return not _is_word_char(view, region.begin() - 1) and not _is_word_char(
        view, region.end()
    )


def _anchor(view: sublime.View, sel: sublime.Selection) -> sublime.Region:
    remembered = _last_added.get(view.id())
    if remembered is not None and any(r == remembered for r in sel):
        return remembered
    return sel[len(sel) - 1]


def _next_match(
    view: sublime.View,
    text: str,
    whole_word: bool,
    start: int,
    taken: sublime.Selection,
) -> Optional[sublime.Region]:
    while start <= view.size():
        found = view.find(text, start, sublime.FindFlags.LITERAL)
        if found.begin() < 0:  # find() returns Region(-1, -1) when there is no match
            return None

        start = found.end()
        if whole_word and not _is_whole_word(view, found):
            continue
        if not any(r == found for r in taken):
            return found

    return None


class FindNextWordCommand(sublime_plugin.TextCommand):
    def run(self, edit: sublime.Edit):
        view = self.view
        sel = view.sel()
        if not len(sel):
            return

        anchor = _anchor(view, sel)
        if anchor.empty():
            view.run_command("find_under_expand")
            _last_added.pop(view.id(), None)
            return

        text = view.substr(anchor)
        whole_word = _is_whole_word(view, anchor)
        match = _next_match(view, text, whole_word, anchor.end(), sel)
        if match is None:  # wrap around
            match = _next_match(view, text, whole_word, 0, sel)
        if match is None:
            return

        sel.add(match)
        _last_added[view.id()] = match
        # Match native find_under_expand: nudge into view when it is close by,
        # animate to the centre when jumping outside the viewport.
        if match in view.visible_region():
            view.show(match, show_surrounds=False)
        else:
            view.show_at_center(match)

    def is_enabled(self) -> bool:
        return len(self.view.sel()) > 0


class FindNextWordListener(sublime_plugin.EventListener):
    def on_close(self, view: sublime.View):
        _last_added.pop(view.id(), None)
