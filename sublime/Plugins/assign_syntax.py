import re
from typing import Any, cast

import sublime_plugin

import sublime


def assign_syntax(view: sublime.View) -> bool:
    """
    Automatically assigns syntaxes

    Rules (by order of precedence):
    1. Assign Bundler Lockfile for files ending in [Gg]emfile.lock
    2. Assign RSpec for Ruby files ending in `_spec.rb`
    3. Assign Rails to Ruby files when the project data has a config like:
    ```json
    {
        "folders":
        [
            {
                "path": "/path/to/root/dir"
            }
        ],
        "config": {
            "rails": true
        }
    }
    ```

    Returns True when a rule matched, False otherwise
    """
    file = view.file_name()
    if file is None:
        return False

    # Ruby stuff
    if file.endswith(("Gemfile.lock", "gemfile.lock")):
        view.assign_syntax("scope:source.gemfile.lock")
        return True

    syntax = view.syntax()
    if syntax and syntax.scope == "source.ruby":
        if file.endswith("_spec.rb"):
            view.assign_syntax("scope:source.ruby.rspec")
            return True

        window = view.window()
        if window:
            project_data = cast("dict[str, Any]", window.project_data())
            if project_data.get("config", {}).get("rails", False):
                view.assign_syntax("scope:source.ruby.rails")
                return True

    # Helm stuff
    if (syntax and syntax.scope == "source.yaml") or file.endswith(".tpl"):
        # if file.endswith("Chart.yaml"):
        #     view.assign_syntax("scope:source.yaml.go")
        #     return True

        rx = re.compile(r".*\/templates\/.*\/?[^\/]+\.(?:yml|yaml|tpl)$")
        if rx.match(file):
            view.assign_syntax("scope:source.helm")
            return True

    return False


# On loading the plugin, run it for all open views when their windows' project has the config
def plugin_loaded():
    for window in sublime.windows():
        for view in window.views():
            assign_syntax(view)


# Assign Rails syntax when a view is loaded
class AssignSyntax(sublime_plugin.EventListener):
    def on_load(self, view):
        assign_syntax(view)
