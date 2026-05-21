import re
from typing import Any, cast

import sublime_plugin

import sublime

HELM_VALUES_REGEX = re.compile(r".*values.*\.(?:yml|yaml)$")
HELM_TEMPLATES_REGEX = re.compile(r".*\/templates\/.*\/?[^\/]+\.(?:yml|yaml|tpl)$")

"""
Rails project config:

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
"""


def assign_syntax(view: sublime.View) -> bool:
    """
    Automatically assigns syntaxes

    Returns True when a rule matched, False otherwise
    """
    file = view.file_name()
    if file is None:
        return False

    if syntax := view.syntax():
        # RSpec/Rails
        if syntax.scope == "source.ruby":
            # RSpec package does this by default
            # if file.endswith("_spec.rb"):
            #     view.assign_syntax("scope:source.ruby.rspec")
            #     return True

            window = view.window()
            if window:
                project_data = cast("dict[str, Any]", window.project_data())
                if project_data and project_data.get("config", {}).get("rails", False):
                    view.assign_syntax("scope:source.ruby.rails")
                    return True

        # Helm
        elif syntax.scope == "source.yaml":
            # Uncomment if/when helm-ls supports these
            # if file.endswith("Chart.yaml"):
            #     view.assign_syntax("scope:source.yaml.helmvalues")
            #     return True

            if HELM_VALUES_REGEX.match(file):
                view.assign_syntax("scope:source.yaml.helmvalues")
                return True

            if HELM_TEMPLATES_REGEX.match(file):
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
    def on_load(self, view: sublime.View):
        assign_syntax(view)
