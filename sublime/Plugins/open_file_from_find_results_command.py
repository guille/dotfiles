import os
import re

import sublime_plugin

import sublime


class OpenFileFromFindResultsCommand(sublime_plugin.TextCommand):
    """Opens files from Find in Files/LSP diagnostic/Build output results when pressing Enter on a filename"""

    def run(self, edit):
        view = self.view
        sel = view.sel()[0]

        # Get the current line
        current_line = view.line(sel)
        # line text minus the ":" suffix
        file_path = os.path.expanduser(view.substr(current_line).strip()[:-1])
        line_num = 0

        # The line num of the first occurrence is in the next three lines at most
        current_line = view.rowcol(current_line.end())[0]
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

        if os.path.exists(file_path):
            window = view.window()
            if window:
                window.open_file(f"{file_path}:{line_num}", sublime.ENCODED_POSITION)
        else:
            sublime.status_message(f"Couldn't find file: {file_path}")

    def is_enabled(self):
        """Only enable this command when the first selection starts in a filename"""
        view = self.view
        sel = view.sel()[0]
        return self.view.match_selector(sel.a, "entity.name.filename")
