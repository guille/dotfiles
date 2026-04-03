import sublime_plugin

import sublime


class RenameTabCommand(sublime_plugin.TextCommand):
    def run(self, edit: sublime.Edit):
        window = self.view.window()
        if window is None:
            return

        window.show_input_panel(
            "Tab Name:",
            self.view.name(),
            on_done=lambda x: self.view.set_name(x),
            on_change=None,
            on_cancel=None,
        )

    def is_visible(self) -> bool:
        return self.view.file_name() is None

    def is_enabled(self) -> bool:
        return self.view.file_name() is None
