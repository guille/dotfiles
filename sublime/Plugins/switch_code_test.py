from typing import Any, cast

import sublime_plugin


class SwitchCodeAndTestCommand(sublime_plugin.WindowCommand):
    """Dispatches to specialized or generic switch commands based on scope.

    Scopes in SPECIALIZED dispatch to dedicated plugins (e.g. rspec, mix_test).
    Scopes in SCOPE_CONFIGS use the generic switch_code_test_generic command.

    Configs can be overridden/added per-project via .sublime-project:
        {
            "config": {
                "switch_code_test": {
                    "source.ruby": { "test_file_suffixes": [".feature"] }
                }
            }
        }
    Project overrides are merged on top of the built-in defaults (per key).
    """

    SPECIALIZED: "dict[str, str]" = {
        "source.ruby": "rspec_toggle_source_or_spec",
        "source.ruby.rspec": "rspec_toggle_source_or_spec",
        "source.elixir": "mix_test_switch_to_code_or_test",
    }

    SCOPE_CONFIGS: "dict[str, dict[str, Any]]" = {
        "source.go": {
            "source_root_markers": [],
            "test_root_markers": [],
            "test_file_prefixes": [],
            "test_file_suffixes": ["_test"],
            "try_same_dir": True,
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

        # Project overrides can replace a specialized scope with generic config
        project_config = self._project_override(scope)

        if project_config is None and scope in self.SPECIALIZED:
            self.window.run_command(self.SPECIALIZED[scope])
            return

        config = self._resolve_config(scope)
        if config is None:
            return

        self.window.run_command("switch_code_test_generic", config)

    def _project_override(self, scope: str) -> "dict[str, Any] | None":
        project_data = cast("dict[str, Any]", self.window.project_data() or {})
        return project_data.get("config", {}).get("switch_code_test", {}).get(scope)

    def _resolve_config(self, scope: str) -> "dict[str, Any] | None":
        base = self.SCOPE_CONFIGS.get(scope)
        overrides = self._project_override(scope)

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

        scope = syntax.scope
        if scope in self.SPECIALIZED or scope in self.SCOPE_CONFIGS:
            return True

        project_data = cast("dict[str, Any]", self.window.project_data() or {})
        overrides = project_data.get("config", {}).get("switch_code_test", {})
        return scope in overrides
