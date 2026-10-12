import subprocess
from pathlib import Path

import sublime
import sublime_plugin


def git(cwd: str, *args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=cwd, text=True).strip()


def worktrees(cwd: str) -> list[dict[str, str]]:
    """Parses `git worktree list --porcelain` into dicts, skipping the bare entry."""
    out = git(cwd, "worktree", "list", "--porcelain")
    entries: list[dict[str, str]] = []
    for block in out.split("\n\n"):
        entry: dict[str, str] = {}
        for line in block.splitlines():
            key, _, value = line.partition(" ")
            entry[key] = value
        if "bare" not in entry and "prunable" not in entry:
            entries.append(entry)
    return entries


class SwitchWorktreeCommand(sublime_plugin.WindowCommand):
    """Opens another worktree of the current repo, symlinking it to the current project file."""

    def run(self, **kwargs: sublime_plugin.Value):
        project_file = self.window.project_file_name()
        folders = self.window.folders()
        if not project_file or not folders:
            sublime.status_message("Switch worktree: no project open")
            return

        try:
            common, toplevel = git(
                folders[0], "rev-parse", "--path-format=absolute", "--git-common-dir", "--show-toplevel"
            ).splitlines()
            wts = worktrees(folders[0])
        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            sublime.status_message(f"Switch worktree: {e}")
            return

        root = Path(common).parent
        link_name = Path(project_file).name
        shared = Path(project_file).resolve()

        items: list[sublime.QuickPanelItem] = []
        current = -1
        for i, wt in enumerate(wts):
            path = Path(wt["worktree"])
            kind = sublime.KIND_AMBIGUOUS
            if path == Path(toplevel):
                current = i
                kind = (sublime.KIND_ID_NAVIGATION, "c", "Current")
            name = wt.get("branch", "").replace("refs/heads/", "", 1) or wt["HEAD"][:8]
            location = path.relative_to(root) if path.is_relative_to(root) else path
            items.append(sublime.QuickPanelItem(name, annotation=str(location), kind=kind))

        def on_done(i: int):
            if i < 0 or i == current:
                return
            project = Path(wts[i]["worktree"]) / link_name
            if not project.exists():
                project.symlink_to(shared)
            self.window.run_command(
                "open_project_or_workspace",
                {"file": str(project), "new_window": False},
            )

        self.window.show_quick_panel(items, on_done, selected_index=max(current, 0))
