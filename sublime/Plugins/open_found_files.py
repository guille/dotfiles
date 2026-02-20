import sublime_plugin

# See https://github.com/STealthy-and-haSTy/SublimeScraps/blob/master/plugins/open_found_files.py


class OpenAllFoundFilesCommand(sublime_plugin.TextCommand):
    """
    Collect the names of all files from a Find in Files result and open them
    all at once, optionally in a new window.
    """

    def run(self, edit, new_window=False):
        # Collect all found filenames
        positions = self.view.find_by_selector("entity.name.filename.find-in-files")
        window = self.view.window()
        if window is None:
            return

        if len(positions) > 0:
            for position in positions:
                window.run_command("open_file", {"file": self.view.substr(position)})
        else:
            window.status_message("No find results")

    def is_enabled(self):
        return self.view.match_selector(0, "text.find-in-files")
