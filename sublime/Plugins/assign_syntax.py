import re
from pathlib import Path
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
        "rails": true,
        "assign_syntax": {
            "config.git": "text.git.config"
        }
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

    project_data = None
    if window := view.window():
        project_data = cast("dict[str, Any]", window.project_data())

    # Assign based on basename
    if project_data and (
        syntaxes := project_data.get("config", {}).get("assign_syntax", {})
    ):
        basename = Path(file).name
        if basename in syntaxes:
            view.assign_syntax(f"scope:{syntaxes[basename]}")
            return True

    if syntax := view.syntax():
        # RSpec/Rails
        if syntax.scope == "source.ruby":
            # RSpec package does this by default
            # if file.endswith("_spec.rb"):
            #     view.assign_syntax("scope:source.ruby.rspec")
            #     return True

            if project_data and project_data.get("config", {}).get("rails", False):
                view.assign_syntax("scope:source.ruby.rails")
                return True

        # Helm / YamlPipelines
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

            if ".github/workflows/" in file or ".github/actions/" in file:
                view.assign_syntax("scope:source.yaml.pipeline.github-actions")
                return True

            if file.endswith(".gitlab-ci.yml"):
                view.assign_syntax("scope:source.yaml.pipeline.gitlab")
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
