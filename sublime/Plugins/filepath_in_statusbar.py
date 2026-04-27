import os
from pathlib import Path

import sublime_plugin

import sublime


def plugin_loaded():
    for window in sublime.windows():
        for view in window.views():
            show_file_path(view)


def show_file_path(view: sublime.View):
    file_name = view.file_name()
    if file_name is None:
        view.erase_status("01FilePath")
        return

    file_path = Path(file_name)

    # Try to make relative to any open folder
    if window := view.window():
        for folder in window.folders():
            try:
                rel = file_path.relative_to(folder)
                view.set_status("01FilePath", f" {rel}")
                return
            except ValueError:
                continue

    # External file: abbreviate home directory
    home = Path.home()
    try:
        display = "󰜥 " + os.sep + str(file_path.relative_to(home))
    except ValueError:
        display = str(file_path)

    view.set_status("01FilePath", display)


class FilePathInStatusbar(sublime_plugin.EventListener):
    def on_new(self, view: sublime.View):
        show_file_path(view)

    def on_load(self, view: sublime.View):
        show_file_path(view)

    def on_clone(self, view: sublime.View):
        show_file_path(view)

    def on_activated(self, view: sublime.View):
        show_file_path(view)
