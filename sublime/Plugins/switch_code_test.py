import sublime_plugin

# if scope not in SUPPORTED_TYPES:
# source root markers:
#   [/src, /lib, ?]
# test root markers_
#   [/test, /tests/, /spec, /src/test, /src/tests]
# test file prefixes
#   [test_]
# test file suffixes
#   [_test, _spec]
# behaviour flags:
#   - try_same_dir: whether to look for file name with(/out) prefixes or suffixes in same dir
#   - assume_same_structure: if source is in /src/foo/bar.py, assume test is in /test/foo/bar_test.py
#   - feeling_lucky: stop at first result or open picker
# all configurable behaviour via args? or project settings? (per scope??)


class SwitchCodeAndTestCommand(sublime_plugin.WindowCommand):
    SUPPORTED_TYPES: "dict[str, str]" = {
        "source.ruby": "rspec_toggle_source_or_spec",
        "source.ruby.rspec": "rspec_toggle_source_or_spec",
        "source.go": "go_test_toggle_source_or_test",
        "source.elixir": "mix_test_switch_to_code_or_test",
    }

    def run(self):
        view = self.window.active_view()
        if view is None:
            return

        syntax = view.syntax()
        if syntax is None:
            return

        self.window.run_command(self.SUPPORTED_TYPES[syntax.scope])

    def is_enabled(self) -> bool:
        view = self.window.active_view()
        if view is None:
            return False

        syntax = view.syntax()
        if syntax is None:
            return False

        return syntax.scope in self.SUPPORTED_TYPES
