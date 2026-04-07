import sublime_plugin


class TrashFileCommand(sublime_plugin.WindowCommand):
    """Wraps the default's delete_file to call from command palette for the active view

    Prompts for confirmation when there are unsaved changes
    """

    def run(self):
        view = self.window.active_view()
        if view is None:
            return

        file_name = view.file_name()
        if file_name is None:
            return

        self.window.run_command(
            "delete_file", {"files": [file_name], "prompt": view.is_dirty()}
        )
