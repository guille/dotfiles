# https://github.com/deathaxe/sublime-default-extended/blob/master/quick_panel.py
import sublime_plugin


class QuickPanelPageUpCommand(sublime_plugin.WindowCommand):
    """Simulate page-up by repeating up command multiple times"""

    def run(self, count=8):
        for i in range(count):
            self.window.run_command("move", {"by": "lines", "forward": False})


class QuickPanelPageDownCommand(sublime_plugin.WindowCommand):
    """Simulate page-down by repeating down command multiple times"""

    def run(self, count=8):
        for i in range(count):
            self.window.run_command("move", {"by": "lines", "forward": True})
