import sublime_plugin

import sublime


class PasteRepeaterCommand(sublime_plugin.TextCommand):
    def run(self, edit: sublime.Edit):
        if window := self.view.window():
            window.show_input_panel(
                "PasteRepeater: How many times? ", "", self.on_done, None, None
            )

    def on_done(self, user_input: str):
        try:
            count = int(float(user_input))
        except ValueError:
            return

        clip = sublime.get_clipboard()
        text = clip * count
        try:
            sublime.set_clipboard(text)
            self.view.run_command("paste")
        finally:
            sublime.set_clipboard(clip)
