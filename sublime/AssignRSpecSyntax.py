import sublime
import sublime_plugin

"""
Automatically assigns rspec syntax to Ruby files ending in `_spec.rb`
"""


def assign_rspec(view):
    file = view.file_name()
    if file and file.endswith("_spec.rb"):
        view.assign_syntax("scope:source.ruby.rspec")


# On loading the plugin, run it for all open views when their windows' project has the config
def plugin_loaded():
    for window in sublime.windows():
        for view in window.views():
            assign_rspec(view)


# Assign Rails syntax when a view is loaded
class AssignRailsSyntax(sublime_plugin.EventListener):
    def on_load(self, view):
        assign_rspec(view)
