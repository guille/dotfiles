import sublime_plugin

import sublime


# TODO: For some reason this works well within a command but is very clunky as a keybind??
class FindNextWordCommand(sublime_plugin.WindowCommand):
    def run(self):
        view = self.window.active_view()
        if view is None:
            return

        sel = view.sel()
        selection = sel[-1]
        print(selection)
        if selection.empty():
            self.window.run_command("find_under_expand")
            return

        selected_text = view.substr(selection)
        last = selection.end()
        next_sel = view.find(
            selected_text, start_pt=last, flags=sublime.FindFlags.WHOLEWORD
        )
        if next_sel.empty() is False:
            print(next_sel)
            sel.add(next_sel)
            view.show(next_sel)
        else:
            start = 0
            while True:
                next_sel = view.find(
                    selected_text, start_pt=start, flags=sublime.FindFlags.WHOLEWORD
                )
                if next_sel.empty():
                    break

                if not sel.contains(next_sel):
                    sel.add(next_sel)
                    view.show(next_sel)
                    break

                start = next_sel.end()
