import sublime_plugin


# https://superuser.com/questions/1050447/sublime-text-escape-multiple-selections-to-last-selection-region-instead-of-fir
class SingleLastSelectionCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        view = self.view
        if len(view.sel()):
            last = view.sel()[-1]
            view.sel().clear()
            view.sel().add(last)
