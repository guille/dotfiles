import sublime_plugin

import sublime


class CopyRelativePathCommand(sublime_plugin.WindowCommand):
    def run(self):
        view = self.window.active_view()
        if view is None:
            return

        file_name = view.file_name()
        if file_name is None:
            return

        for folder in self.window.folders():
            if file_name.startswith(folder):
                # +1 to strip the separator
                rel = file_name[len(folder) + 1 :]
                sublime.set_clipboard(rel)
                self.window.status_message("Copied: " + rel)
                return

        # Fallback: copy absolute path
        sublime.set_clipboard(file_name)
        self.window.status_message("Copied: " + file_name)

    def is_enabled(self) -> bool:
        view = self.window.active_view()
        return view is not None and view.file_name() is not None
