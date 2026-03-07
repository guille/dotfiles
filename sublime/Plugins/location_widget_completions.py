"""
Auto Completion for Find in Files "Where:" field

Original from https://github.com/deathaxe/sublime-default-extended/blob/master/location_widget_completions.py

Changes (@guille):
- Reorder completion list
- Default to showing only "/" and "$HOME" instead of all root subdirs at first
- Trigger autocomplete menu when entering the "Where:" element (TriggerFindInFilesLocationAutocompletionListener)
- Trigger autocomplete on more cases (eg when committing ",")
"""

from __future__ import annotations

from enum import IntEnum
from pathlib import Path

import sublime_plugin

import sublime

__all__ = [
    "FindInFilesCommitLocationCompletionCommand",
    "FindInFilesLocationCompletionListener",
    "TriggerFindInFilesLocationAutocompletionListener",
]


class LocationCompletionType(IntEnum):
    UNKNOWN = 0
    PATH = 1
    FILE = 2
    VARIABLE = 3
    PASS_THROUGH = 4


def location_completion(
    trigger: str,
    annotation="",
    completion="",
    type=LocationCompletionType.UNKNOWN,
    kind=sublime.KIND_AMBIGUOUS,
    details="",
) -> sublime.CompletionItem:
    return sublime.CompletionItem(
        trigger,
        annotation,
        sublime.format_command(
            "find_in_files_commit_location_completion",
            {"type": type, "completion": completion or trigger},
        ),
        sublime.COMPLETION_FORMAT_COMMAND,
        kind,
        details,
    )


class TriggerFindInFilesLocationAutocompletionListener(sublime_plugin.EventListener):
    def on_activated_async(self, view):
        if view.element() == "find_in_files:input:location":
            view.run_command("auto_complete")


class FindInFilesLocationCompletionListener(sublime_plugin.EventListener):
    # globally suggested everywhere
    operator_completions: list[sublime.CompletionValue] = [
        sublime.CompletionItem(
            trigger=",",
            kind=(sublime.KIND_ID_KEYWORD, "o", "Separator"),
            details="Separates patterns",
            completion=sublime.format_command(
                "find_in_files_commit_location_completion",
                {
                    "type": LocationCompletionType.PASS_THROUGH,
                    "completion": ",",
                },
            ),
            completion_format=sublime.COMPLETION_FORMAT_COMMAND,
        ),
    ]

    # suggested at beginning of patterns
    variable_completions: list[sublime.CompletionValue] = [
        sublime.CompletionItem(
            trigger="//",
            completion=sublime.format_command(
                "find_in_files_commit_location_completion",
                {
                    "type": LocationCompletionType.PATH,
                    "completion": "//",
                },
            ),
            completion_format=sublime.COMPLETION_FORMAT_COMMAND,
            kind=(sublime.KIND_ID_KEYWORD, "o", "Operator"),
            details="Match relative to project folders",
        ),
        sublime.CompletionItem(
            trigger="*/",
            kind=(sublime.KIND_ID_KEYWORD, "o", "Operator"),
            details="Match relative to any folder",
        ),
        sublime.CompletionItem(
            trigger="-",
            kind=(sublime.KIND_ID_KEYWORD, "o", "Operator"),
            details="Exclude matching patterns from search",
        ),
        location_completion(
            trigger="<open files>",
            type=LocationCompletionType.VARIABLE,
            kind=sublime.KIND_VARIABLE,
            details="Search in all open files.",
        ),
        location_completion(
            trigger="<open folders>",
            type=LocationCompletionType.VARIABLE,
            kind=sublime.KIND_VARIABLE,
            details="Search in all open folders.",
        ),
        location_completion(
            trigger="<project filters>",
            type=LocationCompletionType.VARIABLE,
            kind=(sublime.KindId.KEYWORD, "f", "filter"),
            details="Apply project specific filter settings.",
        ),
        location_completion(
            trigger="<current file>",
            type=LocationCompletionType.VARIABLE,
            kind=sublime.KIND_VARIABLE,
            details="Search in active file.",
        ),
    ]

    def on_query_completions(
        self, view: sublime.View, prefix: str, locations: list[sublime.Point]
    ) -> sublime.CompletionList | None:
        if view.element() != "find_in_files:input:location":
            # not within find in files "Where:" input
            return None
        if view.settings().get("auto_complete_disabled"):
            # auto completions are disabled by configuration
            return None
        if not view.match_selector(0, "source.file-pattern"):
            # completions rely on properly scoped location patterns
            return None

        pt = locations[0]

        completions = []

        try:
            completions += self.path_completions(view, prefix, pt)
        except OSError:
            pass

        if view.match_selector(max(0, pt - 1), "- meta.path"):
            completions += self.variable_completions
            window = view.window()
            if window:
                active_view = window.active_view()
                if active_view:
                    fname = active_view.file_name()
                    if fname:
                        completions.append(
                            location_completion(
                                trigger="<current folder>",
                                completion=str(Path(fname).parent),
                                type=LocationCompletionType.VARIABLE,
                                kind=sublime.KIND_VARIABLE,
                                details="Search in current folder",
                            )
                        )

            completions += self.file_completions(view, prefix, pt)
        completions += self.operator_completions.copy()

        return sublime.CompletionList(
            completions, sublime.AutoCompleteFlags.INHIBIT_WORD_COMPLETIONS
        )

    def file_completions(
        self, view: sublime.View, prefix: str, pt: sublime.Point
    ) -> list[sublime.CompletionValue]:
        completions = []

        # collect file extensions
        window = view.window()
        if window:
            extensions = {"*"}
            for view in window.views():
                fname = view.file_name()
                if fname:
                    _, ext = fname.rsplit(".", 1)
                    if ext:
                        extensions.add(ext)

            for ext in extensions:
                completions.append(
                    location_completion(
                        trigger=f"*.{ext}",
                        type=LocationCompletionType.FILE,
                        kind=(sublime.KindId.TYPE, "e", "extension"),
                        details=f"include <em>{ext}</em> files.",
                    )
                )

        return completions

    def path_completions(
        self, view: sublime.View, prefix: str, pt: sublime.Point
    ) -> list[sublime.CompletionValue]:
        check_pt = max(0, pt - 1)
        selector = "meta.path - punctuation.definition"
        folders = []
        if view.match_selector(check_pt, selector):
            reg = view.expand_to_scope(check_pt, selector)
            if reg:
                reg.b = pt
                path_string = view.substr(reg)
                if path_string.startswith("//"):
                    window = view.window()
                    if not window:
                        return []

                    project_folders = window.folders()
                    if not project_folders:
                        return []

                    parts = path_string[2:].replace("\\", "/").rsplit("/", 1)
                    if len(parts) < 2:
                        folders = [Path(f) for f in project_folders]
                    else:
                        path_string = parts[0]

                        folders = []
                        for root in project_folders:
                            folder = Path(root) / path_string
                            if folder.is_dir():
                                folders.append(folder)

                else:
                    folder = Path(
                        path_string.replace("\\", "/").rsplit("/", 1)[0] + "/"
                    )
                    if not folder.is_absolute():
                        # todo handle relative paths which can start everywhere
                        # in the tree of project folders
                        return []

                    folders = [folder]

        if folders:
            # deduplicate folder names
            items = {
                item.name
                for folder in folders
                for item in folder.iterdir()
                if item.is_dir()
            }
        else:
            items = {"/", Path("~").expanduser().absolute().as_posix()}

        return [
            location_completion(
                trigger=item,
                type=LocationCompletionType.PATH,
                kind=(sublime.KindId.NAMESPACE, "d", "directory"),
            )
            for item in items
        ]


class FindInFilesCommitLocationCompletionCommand(sublime_plugin.TextCommand):
    def run(self, edit: sublime.Edit, type: LocationCompletionType, completion: str):  # pyright: ignore[reportIncompatibleMethodOverride]
        sels = self.view.sel()
        if not sels:
            return

        pt = sels[0].b

        print("HI")

        if type == LocationCompletionType.FILE:
            self.commit_file(edit, pt, completion)
        elif type == LocationCompletionType.PATH:
            self.commit_path(edit, pt, completion)
        elif type == LocationCompletionType.VARIABLE:
            self.commit_variable(edit, pt, completion)
        elif type == LocationCompletionType.PASS_THROUGH:
            # Insert as-is and autocomplete again
            self.view.insert(edit, pt, completion)
            sublime.set_timeout(
                lambda: self.view.run_command("auto_complete", {"mini": True}), 10
            )

    def commit_file(self, edit, pt: sublime.Point, completion):
        # insert new file filter
        self.view.insert(edit, pt, completion)

    def commit_path(self, edit, pt, completion):
        # trim existing path
        # TODO: keep parts, valid after completion
        reg = self.view.expand_to_scope(
            max(0, pt - 1), "meta.path - punctuation.definition"
        )
        if reg:
            self.view.erase(edit, sublime.Region(pt, reg.b))
            reg.b = pt

        # determine path separator
        psep = "/"

        # Special case for / and $HOME
        if completion.startswith("/"):
            if not completion.endswith("/"):
                completion = completion + psep
            self.view.insert(edit, pt, completion)
        else:
            # prepend /
            if reg is None or reg.a == pt:
                completion = psep + completion

            # insert new path
            self.view.insert(edit, pt, completion + psep)

        # trigger auto completion
        sublime.set_timeout(
            lambda: self.view.run_command("auto_complete", {"mini": True}), 10
        )

    def commit_variable(self, edit, pt, completion):
        # replace existing, possibly incomplete <variable>
        for reg in self.view.find_all(r"<[a-z ]*>?|[a-z ]*?>"):
            if pt in reg:
                # keep leading space
                if self.view.substr(reg.a) == " ":
                    reg.a += 1
                self.view.replace(edit, reg, completion)
                return

        # insert new variable
        self.view.insert(edit, pt, completion)
