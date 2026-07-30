import base64
import gzip

import sublime_plugin

import sublime


class DecodeSelectedBase64Command(sublime_plugin.WindowCommand):
    def _popup_error(self, text: str):
        html = f"<div style='padding: 0 25%; border: 2px solid red'><h4>⚠️ {text}</h4></div>"
        view = self.window.active_view()
        if view is not None:
            view.show_popup(html, max_width=2048, max_height=2048)

    def _popup_ok(self, text: str):
        html = f"<div style='padding: 0 25%; border: 2px solid green'><h4>✅ {text}</h4></div>"
        view = self.window.active_view()
        if view is not None:
            view.show_popup(html, max_width=2048, max_height=2048)

    def run(self):
        if view := self.window.active_view():
            region = view.sel()[0]
            contents = view.substr(region).strip(" ").strip("\n")
            print(f"c: {contents}")
            raw = base64.decodebytes(contents.encode())
            if raw[:2] == b"\x1f\x8b":
                raw = gzip.decompress(raw)
            try:
                decoded = raw.decode()
            except UnicodeDecodeError:
                self._popup_error("Decoded bytes aren't valid UTF-8 text")
                return
            print(f"d: {decoded}")
            if decoded:
                sublime.set_clipboard(decoded)
                self._popup_ok("Decoded string copied to clipboard!")

    def is_enabled(self) -> bool:
        if view := self.window.active_view():
            selections = view.sel()
            if len(selections) == 1 and len(selections[0]):
                return True

        return False
