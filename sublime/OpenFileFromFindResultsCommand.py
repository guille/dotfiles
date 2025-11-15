import os
import re

import sublime_plugin

import sublime


class OpenFileFromFindResultsCommand(sublime_plugin.TextCommand):
    """Opens files from Find in Files results when pressing Enter on a filename"""

    def run(self, edit):
        view = self.view

        sel = view.sel()[0]
        scope = view.scope_name(sel.begin())

        # Check if we're on a filename line
        if "entity.name.filename.find-in-files" in scope:
            # Get the current line
            current_line = view.line(sel)
            line_text = view.substr(current_line).strip()

            # The line num of the first occurrence is in the next three lines at most
            line_num = 0
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

            match = re.match(r"^(.+):?$", line_text)

            if match:
                file_path = os.path.expanduser(match.group(1))

                if os.path.exists(file_path):
                    window = view.window()
                    if window:
                        window.open_file(
                            f"{file_path}:{line_num}", sublime.ENCODED_POSITION
                        )
                else:
                    sublime.status_message(f"Couldn't find file: {file_path}")
            else:
                sublime.status_message(f"Couldn't parse line: {line_text}")

    def is_enabled(self):
        """Only enable this command in Find in Files result views"""
        scope = self.view.scope_name(self.view.sel()[0].begin())
        return "text.find-in-files" in scope
