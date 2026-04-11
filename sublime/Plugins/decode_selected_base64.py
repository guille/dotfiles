import base64

import sublime
import sublime_plugin


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
            decoded = base64.decodebytes(contents.encode()).decode()
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
