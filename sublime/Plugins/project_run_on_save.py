import subprocess
from typing import TYPE_CHECKING, Any, TypedDict, cast

import sublime_plugin

if TYPE_CHECKING:
    # 3.11 or newer
    from typing import NotRequired


import sublime

"""
Simple plugin to run commands when saving scopes, configured in the project
```json
{
    "folders":
    [
        {
            "path": "/path/to/root/dir"
        }
    ],
    "config": {
        "run_on_save": {
            "source.proto": [
                {
                    "cmd": ["protoc", "$file_path"],
                    "build_panel": true,
                },
                {
                    "cmd": ["notify-send", "saved!"],
                    "working_dir": "/tmp"
                }
            ]
        }
    }
}
```
"""


class RunOnSaveTask(TypedDict):
    cmd: "list[str]"
    working_dir: "NotRequired[str]"
    build_panel: "NotRequired[bool]"


class ProjectRunOnSaveListener(sublime_plugin.EventListener):
    def run_task(self, task: RunOnSaveTask, window: sublime.Window):
        expanded_cmd = sublime.expand_variables(task["cmd"], window.extract_variables())
        working_dir: str = cast(
            str,
            sublime.expand_variables(
                task.get("working_dir", "$project_path"),
                window.extract_variables(),
            ),
        )
        expanded_cmd = cast("list[str]", expanded_cmd)
        if task.get("build_panel", False):
            window.run_command(
                "exec",
                {"cmd": expanded_cmd, "working_dir": working_dir},
            )
        else:
            try:
                subprocess.run(expanded_cmd, check=True, cwd=working_dir)
            except subprocess.CalledProcessError:
                window.status_message(f"Error running {' '.join(expanded_cmd)}")
            except FileNotFoundError:
                window.status_message(f"Command not found {expanded_cmd[0]}")

    def on_pre_save_async(self, view: sublime.View):
        window = view.window()
        syntax = view.syntax()
        if window is None or syntax is None:
            return

        project_data = cast("dict[str, Any]", window.project_data())
        tasks: "list[RunOnSaveTask]" = (
            project_data.get("config", {}).get("run_on_save", {}).get(syntax.scope, [])
        )

        for task in tasks:
            self.run_task(task, window)
