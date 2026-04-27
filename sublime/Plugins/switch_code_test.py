from typing import Any, cast

import sublime_plugin


class SwitchCodeAndTestCommand(sublime_plugin.WindowCommand):
    """Dispatches to switch_code_test_generic with language-appropriate defaults.

    Configs can be overridden per-project via .sublime-project:
        {
            "config": {
                "switch_code_test": {
                    "source.ruby": { "test_file_suffixes": [".feature"] }
                }
            }
        }
    Project overrides are merged on top of the built-in defaults (per key).
    """

    SCOPE_CONFIGS: "dict[str, dict[str, Any]]" = {
        "source.go": {
            "source_root_markers": ["cmd", "internal", "pkg"],
            "test_root_markers": ["cmd", "internal", "pkg"],
            "test_file_prefixes": [],
            "test_file_suffixes": ["_test"],
            "try_same_dir": True,
        },
        "source.ruby": {
            "source_root_markers": ["lib", "app"],
            "test_root_markers": ["spec"],
            "test_file_prefixes": [],
            "test_file_suffixes": ["_spec"],
        },
        "source.ruby.rspec": {
            "source_root_markers": ["lib", "app"],
            "test_root_markers": ["spec"],
            "test_file_prefixes": [],
            "test_file_suffixes": ["_spec"],
        },
        "source.dart": {
            "source_root_markers": ["lib"],
            "test_root_markers": ["test"],
            "test_file_prefixes": [],
            "test_file_suffixes": ["_test"],
        },
        "source.python": {
            "source_root_markers": ["src", "lib"],
            "test_root_markers": ["tests", "test"],
            "test_file_prefixes": ["test_"],
            "test_file_suffixes": ["_test"],
        },
    }

    def run(self):
        view = self.window.active_view()
        if view is None:
            return

        syntax = view.syntax()
        if syntax is None:
            return

        scope = syntax.scope
        config = self._resolve_config(scope)
        if config is None:
            return

        self.window.run_command("switch_code_test_generic", config)

    def _resolve_config(self, scope: str) -> "dict[str, Any] | None":
        base = self.SCOPE_CONFIGS.get(scope)
        project_data = cast("dict[str, Any]", self.window.project_data() or {})
        overrides = (
            project_data.get("config", {}).get("switch_code_test", {}).get(scope)
        )

        if base is None and overrides is None:
            return None
        if base is None:
            return overrides
        if overrides is None:
            return dict(base)
        return {**base, **overrides}

    def is_enabled(self) -> bool:
        view = self.window.active_view()
        if view is None:
            return False

        syntax = view.syntax()
        if syntax is None:
            return False

        if syntax.scope in self.SCOPE_CONFIGS:
            return True

        # Check if project data has a config for this scope
        project_data = cast("dict[str, Any]", self.window.project_data() or {})
        overrides = project_data.get("config", {}).get("switch_code_test", {})
        return syntax.scope in overrides
