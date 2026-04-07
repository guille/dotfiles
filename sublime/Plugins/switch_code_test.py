import sublime_plugin


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
