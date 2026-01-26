"""
Mostly nicked from
https://github.com/STealthy-and-haSTy/ScratchBuffer/

Minor changes:
- hardcode to always hide hidden syntax
- add toggle_scratch command
"""

import pathlib

import sublime_plugin

import sublime

# The list of packages that ship with Sublime can be gathered by looking for
# sublime-package files in the Packages folder that is inside of the root of
# the application install as a sibling to the running binary.
#
# Capture all such files as the na`mes of packages that are built in.
pkg_path = pathlib.Path(sublime.executable_path()).parent / "Packages"
shipped_pkgs = {
    entry.stem
    for entry in pkg_path.iterdir()
    if entry.is_file() and entry.suffix == ".sublime-package"
}

# Map the kinds of syntax files that we can display into appropriate KIND items
# for display in the list. This allows for quickly and easily looking up the
# appropriate Kind based on wether or not the source package ships with Sublime
kind_map = {
    # Packages that ship with Sublime Text
    True: (sublime.KIND_ID_COLOR_GREENISH, "S", "Ships with Sublime Text"),
    # Packages that are user installed
    False: (sublime.KIND_ID_COLOR_ORANGISH, "I", "From a user installed package"),
}


class SyntaxInputHandler(sublime_plugin.ListInputHandler):
    """
    Input handler for the syntax argument of the scratch_buffer command; allows
    for the selection of one of the available syntaxes.
    """

    def placeholder(self):
        return "Choose Scratch Buffer Syntax"

    def list_items(self) -> "list[sublime.ListInputItem]":
        result = []
        for syntax in sorted(sublime.list_syntaxes(), key=lambda e: e.name):
            path = pathlib.PurePosixPath(syntax.path)
            package = path.parts[1]

            if syntax.hidden:
                continue

            result.append(
                sublime.ListInputItem(
                    syntax.name,
                    str(path),
                    path.name,
                    package,
                    kind_map[package in shipped_pkgs],
                )
            )
        return result


class ScratchBufferCommand(sublime_plugin.WindowCommand):
    """
    Create a scratch view with the provided syntax already set.
    If `copy` is set, copies the syntax from the currently-opened view
    """

    def run(self, syntax_path: str = "", copy: bool = False):
        if copy:
            view = self.window.active_view()
            syntax = view.syntax() if view else None
        else:
            record = sublime.syntax_from_path(syntax_path)
            syntax = record.name if record else None

        if syntax is None:
            return self.window.status_message(
                "Cannot create scratch buffer; bad syntax"
            )

        view = self.window.new_file()
        view.set_name("Scratch: {}".format(syntax))

        view.set_scratch(True)
        view.assign_syntax(syntax)
        view.settings().set("is_temp_scratch", True)

    def input(self, args):
        if "syntax" not in args and "copy" not in args:
            return SyntaxInputHandler()

    def input_description(self):
        return "Create Scratch Buffer"


class ScratchBufferListener(sublime_plugin.EventListener):
    """
    When a scratch buffer is saved, turn off the scratch setting so that further
    changes do not get lost on accidental close.
    """

    def on_post_save(self, view):
        if view.is_scratch() and view.settings().get("is_temp_scratch", True):
            view.set_scratch(False)


class ToggleScratchCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        self.view.set_scratch(not self.view.is_scratch())
