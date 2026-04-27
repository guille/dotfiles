import os
import re

import sublime_plugin

import sublime


class OpenFileFromFindResultsCommand(sublime_plugin.TextCommand):
    """Opens files from Find in Files/LSP diagnostic/Build output results when pressing Enter on a filename"""

    def run(self, edit: sublime.Edit):
        view = self.view
        sel = view.sel()[0]

        sel = view.expand_to_scope(sel.a, "entity.name.filename")
        if sel is None:
            return

        file_path = os.path.expanduser(view.substr(sel))

        line_num = 0

        # The line number will either be right after the filename... (build outputs usually)
        line_contents = view.substr(view.full_line(sel))
        if line_match := re.match(r"(?:[A-Za-z0-9_.\/ ]+rb):([0-9]+)", line_contents):
            line_num = line_match.group(1)
        else:
            # or in the next three lines at most (find in files / LSP diagnostics)
            current_line = view.rowcol(sel.end())[0]
            for i in range(1, 4):
                next_line_point = view.text_point(current_line + i, 0)
                if next_line_point < view.size():
                    next_line_region = view.line(next_line_point)
                    next_line_text = view.substr(next_line_region)

                    # Look for pattern like "    1:" or "   42:"
                    line_match = re.match(r"^\s*(\d+):", next_line_text)
                    if line_match:
                        line_num = line_match.group(1)
                        break

        window = view.window()
        if window:
            if os.path.exists(file_path):
                window.open_file(
                    f"{os.path.abspath(file_path)}:{line_num}", sublime.ENCODED_POSITION
                )
                return

            # Try relative to any open folder
            for folder in window.folders():
                candidate = os.path.join(folder, file_path)
                if os.path.exists(candidate):
                    window.open_file(
                        f"{candidate}:{line_num}", sublime.ENCODED_POSITION
                    )
                    return

            # Last-ditch: try relative to packages path
            packages_candidate = os.path.join(sublime.packages_path(), file_path)
            if os.path.exists(packages_candidate):
                window.open_file(
                    f"{packages_candidate}:{line_num}", sublime.ENCODED_POSITION
                )
                return

            sublime.status_message(f"Couldn't find file: {file_path}")

    def is_enabled(self):
        """Only enable this command when the first selection starts in a filename"""
        view = self.view
        sel = view.sel()[0]
        return self.view.match_selector(sel.a, "entity.name.filename")
