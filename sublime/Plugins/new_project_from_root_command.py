from pathlib import Path

import sublime_plugin

import sublime


class NewProjectFromRootCommand(sublime_plugin.WindowCommand):
    """Creates a new sublime project from the opened directory and switches to it.

    This command will only be successful if all conditions are met:
    1. There is no active project
    2. Only one directory is open
    3. The directory doesn't already have a .sublime-project file with the same name
    """

    def _popup_error(self, text: str):
        html = f"<div style='padding: 0 25%; border: 2px solid red'><h4>⚠️ {text}</h4></div>"
        view = self.window.active_view()
        if view is not None:
            view.show_popup(html, max_width=2048, max_height=2048)

    def _popup_ok(self, text: str):
        html = f"<div style='padding: 0 25%; border: 2px solid green'><h4>✅ {text}</h4></div>"
        view = self.window.active_view()
        if view is not None:
            view.show_popup(html, max_width=2048, max_height=2048)

    def run(self):
        if self.window.project_file_name() or self.window.workspace_file_name():
            self._popup_error("Already in project!")
            return

        if len(self.window.folders()) > 1:
            self._popup_error("More than one folder opened!")
            return

        opened_folder = Path(self.window.folders()[0])
        project_file = opened_folder / f"{opened_folder.name}.sublime-project"

        if project_file.exists():
            self._popup_error(f"Project file {project_file.name} already exists!")
            return

        project_data = self.window.project_data()

        with open(project_file, "w") as f:
            f.write(sublime.encode_value(project_data, pretty=True))

        self.window.run_command(
            "open_project_or_workspace",
            {"file": str(project_file), "new_window": False},
        )
        # XXX: Need to turn it off and on again so it works properly(?)
        self.window.run_command("close_workspace")
        self.window.run_command(
            "open_project_or_workspace",
            {"file": str(project_file), "new_window": False},
        )
        self._popup_ok("Done!")
