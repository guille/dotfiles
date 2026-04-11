import sublime_plugin

import sublime


# https://superuser.com/questions/1050447/sublime-text-escape-multiple-selections-to-last-selection-region-instead-of-fir
# Modified to make it scroll to the kept selection afterwards
class SingleLastSelectionCommand(sublime_plugin.TextCommand):
    def run(self, edit: sublime.Edit):
        view = self.view
        if len(view.sel()):
            last = view.sel()[-1]
            view.sel().clear()
            view.sel().add(last)
            view.show(last)
