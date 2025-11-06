import sublime_plugin

import sublime

"""
Allows the user to set a custom key in the *.sublime-project file to specify whether it is a Rails project
When set to true, all Ruby files will open with the extended "Ruby (Rails)" syntax
"""


def assign_rails(view):
    window = view.window()
    syntax = view.syntax()
    if syntax and syntax.scope == "source.ruby":
        if window and window.project_data().get("config", {}).get("rails", False):
            view.assign_syntax("scope:source.ruby.rails")


# On loading the plugin, run it for all open views when their windows' project has the config
def plugin_loaded():
    for window in sublime.windows():
        if not window.project_data().get("config", {}).get("rails", False):
            continue

        for view in window.views():
            assign_rails(view)


# Assign Rails syntax when a view is loaded
class AssignRailsSyntax(sublime_plugin.EventListener):
    def on_load(self, view):
        assign_rails(view)
