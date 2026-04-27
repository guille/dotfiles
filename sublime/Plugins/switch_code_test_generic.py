import os
from pathlib import Path

import sublime_plugin

import sublime


class SwitchCodeTestGenericCommand(sublime_plugin.WindowCommand):
    """Generic command to switch between code and test files.

    Args:
        source_root_markers: Path segments identifying source roots (e.g. ["lib", "app", "lib/host"])
        test_root_markers: Path segments identifying test roots (e.g. ["spec", "test", "tests"])
        test_file_prefixes: Prefixes added to test filenames (e.g. ["test_"])
        test_file_suffixes: Suffixes added to test file stems (e.g. ["_test", "_spec"])
        try_same_dir: If True, only look in the same directory
        feeling_lucky: If True, open first match instead of showing picker

    Markers can be multi-segment (e.g. "lib/host") to match deeper paths.
    """

    def run(
        self,
        source_root_markers: "list[str]|None" = None,
        test_root_markers: "list[str]|None" = None,
        test_file_prefixes: "list[str]|None" = None,
        test_file_suffixes: "list[str]|None" = None,
        try_same_dir: bool = False,
        feeling_lucky: bool = False,
    ):
        if (
            source_root_markers is None
            or test_root_markers is None
            or test_file_prefixes is None
            or test_file_suffixes is None
        ):
            return
        view = self.window.active_view()
        if view is None:
            return

        abs_path = view.file_name()
        if abs_path is None:
            return

        file_path = Path(abs_path)
        is_test = self._is_test_file(file_path, test_file_prefixes, test_file_suffixes)

        if is_test:
            candidates = self._find_source_candidates(
                file_path,
                source_root_markers,
                test_root_markers,
                test_file_prefixes,
                test_file_suffixes,
                try_same_dir,
            )
        else:
            candidates = self._find_test_candidates(
                file_path,
                source_root_markers,
                test_root_markers,
                test_file_prefixes,
                test_file_suffixes,
                try_same_dir,
            )

        existing = [p for p in candidates if p.is_file()]
        # deduplicate while preserving order
        seen: "set[Path]" = set()
        unique: "list[Path]" = []
        for p in existing:
            resolved = p.resolve()
            if resolved not in seen:
                seen.add(resolved)
                unique.append(p)

        self._open_candidates(unique, is_test, feeling_lucky)

    # ── Test file detection ──────────────────────────────────────────

    def _is_test_file(
        self,
        file_path: Path,
        prefixes: "list[str]",
        suffixes: "list[str]",
    ) -> bool:
        name = file_path.name
        stem = file_path.stem
        for prefix in prefixes:
            if prefix and name.startswith(prefix):
                return True
        for suffix in suffixes:
            if suffix and stem.endswith(suffix):
                return True
        return False

    def _strip_test_decorations(
        self,
        file_path: Path,
        prefixes: "list[str]",
        suffixes: "list[str]",
    ) -> "list[str]":
        """Return possible source filenames by removing one prefix or suffix."""
        name = file_path.name
        stem = file_path.stem
        ext = file_path.suffix
        results: "list[str]" = []
        for prefix in prefixes:
            if prefix and name.startswith(prefix):
                results.append(name[len(prefix) :])
        for suffix in suffixes:
            if suffix and stem.endswith(suffix):
                results.append(stem[: -len(suffix)] + ext)
        return results

    def _add_test_decorations(
        self,
        file_path: Path,
        prefixes: "list[str]",
        suffixes: "list[str]",
    ) -> "list[str]":
        """Return possible test filenames by adding one prefix or suffix (not both)."""
        name = file_path.name
        stem = file_path.stem
        ext = file_path.suffix
        results: "list[str]" = []
        for prefix in prefixes:
            if prefix:
                results.append(prefix + name)
        for suffix in suffixes:
            if suffix:
                results.append(stem + suffix + ext)
        return results

    # ── Marker helpers (support multi-segment markers like "lib/fluent") ──

    @staticmethod
    def _marker_parts(marker: str) -> "tuple[str, ...]":
        return Path(marker).parts

    def _find_marker_in_parts(
        self,
        parts: "tuple[str, ...]",
        marker: str,
    ) -> "list[int]":
        """Find all start indices where marker segments appear in parts.
        Returns indices sorted with preference for project folder boundaries."""
        mparts = self._marker_parts(marker)
        mlen = len(mparts)
        indices = [
            i for i in range(len(parts) - mlen + 1) if parts[i : i + mlen] == mparts
        ]
        if not indices:
            return []

        folders = self.window.folders()

        # Sort: prefer indices aligned with a project folder boundary
        def sort_key(idx: int) -> "tuple[int, int]":
            prefix = str(Path(*parts[:idx])) if idx > 0 else ""
            aligned = any(
                folder == prefix or folder.rstrip(os.sep) == prefix
                for folder in folders
            )
            # aligned first (0 < 1), then prefer rightmost
            return (0 if aligned else 1, -idx)

        indices.sort(key=sort_key)
        return indices

    def _replace_marker(
        self,
        parts: "tuple[str, ...]",
        start_idx: int,
        old_marker: str,
        new_marker: str,
    ) -> Path:
        """Replace old_marker segments at start_idx with new_marker segments."""
        old_len = len(self._marker_parts(old_marker))
        new_parts = self._marker_parts(new_marker)
        result = parts[:start_idx] + new_parts + parts[start_idx + old_len :]
        return Path(*result) if result else Path()

    def _parts_after_marker(
        self,
        parts: "tuple[str, ...]",
        start_idx: int,
        marker: str,
    ) -> "tuple[str, ...]":
        """Return parts after the marker (excluding the filename)."""
        mlen = len(self._marker_parts(marker))
        # Everything after marker up to but not including the last part (filename)
        after = parts[start_idx + mlen : -1]
        return after

    # ── Candidate finding ────────────────────────────────────────────

    def _find_source_candidates(
        self,
        file_path: Path,
        source_root_markers: "list[str]",
        test_root_markers: "list[str]",
        prefixes: "list[str]",
        suffixes: "list[str]",
        try_same_dir: bool,
    ) -> "list[Path]":
        source_names = self._strip_test_decorations(file_path, prefixes, suffixes)
        if not source_names:
            return []

        if try_same_dir:
            for sname in source_names:
                candidate = file_path.parent / sname
                if candidate.is_file():
                    return [candidate]
            return []

        candidates: "list[Path]" = []
        parts = file_path.parts

        for test_marker in test_root_markers:
            for idx in self._find_marker_in_parts(parts, test_marker):
                # Check if a source root marker already exists after the test marker
                # e.g. spec/lib/foo_spec.rb -> lib/foo.rb
                for source_marker in source_root_markers:
                    sm_parts = self._marker_parts(source_marker)
                    sm_len = len(sm_parts)
                    tm_len = len(self._marker_parts(test_marker))
                    remaining = parts[idx + tm_len : -1]
                    if len(remaining) >= sm_len and remaining[:sm_len] == sm_parts:
                        base = Path(*parts[:idx]) if idx > 0 else Path(os.sep)
                        rest_after_source = remaining[sm_len:]
                        rest_path = (
                            Path(*rest_after_source) if rest_after_source else Path()
                        )
                        for sname in source_names:
                            candidates.append(base / source_marker / rest_path / sname)

                # Replace test root marker with each source root marker
                for source_marker in source_root_markers:
                    replaced = self._replace_marker(
                        parts, idx, test_marker, source_marker
                    )
                    parent = replaced.parent if len(parts) > 1 else replaced
                    for sname in source_names:
                        candidates.append(parent / sname)

        return candidates

    def _find_test_candidates(
        self,
        file_path: Path,
        source_root_markers: "list[str]",
        test_root_markers: "list[str]",
        prefixes: "list[str]",
        suffixes: "list[str]",
        try_same_dir: bool,
    ) -> "list[Path]":
        test_names = self._add_test_decorations(file_path, prefixes, suffixes)
        if not test_names:
            return []

        if try_same_dir:
            for tname in test_names:
                candidate = file_path.parent / tname
                if candidate.is_file():
                    return [candidate]
            return []

        candidates: "list[Path]" = []
        parts = file_path.parts

        for source_marker in source_root_markers:
            for idx in self._find_marker_in_parts(parts, source_marker):
                after_parts = self._parts_after_marker(parts, idx, source_marker)
                after_path = Path(*after_parts) if after_parts else Path()

                for test_marker in test_root_markers:
                    base = Path(*parts[:idx]) if idx > 0 else Path(os.sep)
                    for tname in test_names:
                        # Replace source marker with test marker
                        # e.g. lib/fluent/plugin/foo.rb -> test/plugin/test_foo.rb
                        candidates.append(base / test_marker / after_path / tname)
                        # Prepend test marker (keep source marker)
                        # e.g. lib/foo.rb -> spec/lib/foo_spec.rb
                        candidates.append(
                            base / test_marker / source_marker / after_path / tname
                        )

        return candidates

    # ── Open results ─────────────────────────────────────────────────

    def _open_candidates(
        self,
        candidates: "list[Path]",
        is_test: bool,
        feeling_lucky: bool,
    ):
        if not candidates:
            kind = "source" if is_test else "test"
            self.window.status_message(
                "SwitchCodeTest: could not find the counterpart %s file." % kind
            )
            return

        if len(candidates) == 1 or feeling_lucky:
            self.window.open_file(str(candidates[0]))
            return

        project_root = self._project_root()
        window = self.window

        def on_select(i: int):
            if i >= 0:
                window.open_file(str(candidates[i]))

        items = [
            sublime.QuickPanelItem(
                trigger=str(self._relative_path(p, project_root)),
                kind=sublime.KIND_NAVIGATION,
            )
            for p in candidates
        ]
        window.show_quick_panel(items, on_select)

    def _project_root(self) -> "Path | None":
        folders = self.window.folders()
        return Path(folders[0]) if folders else None

    def _relative_path(self, path: Path, root: "Path | None") -> Path:
        if root is not None:
            try:
                return path.relative_to(root)
            except ValueError:
                pass
        return path
