import sublime_plugin

# Adapted from https://github.com/SublimeText/MoveTab/blob/5e371d4119971a1e068971106c920e1730b3ca21/move_tab.py


class MoveTabCommand(sublime_plugin.WindowCommand):
    def run(self, forward: bool = False) -> None:
        if not (view := self.window.active_view()):
            return
        group, index = self.window.get_view_index(view)
        if index < 0:
            return
        count = len(self.window.views_in_group(group))
        if forward:
            position = index + 1
        else:
            position = index - 1

        position = max(0, min(position, count - 1))

        # Avoid flashing tab when moving to same index
        if position != index:
            self.window.set_view_index(view, group, position)
            self.window.focus_view(view)

    def is_enabled(self) -> bool:
        if not (view := self.window.active_view()):
            return False
        (group, index) = self.window.get_view_index(view)
        return -1 not in (group, index) and len(self.window.views_in_group(group)) > 1
