import os

import sublime_plugin

import sublime


class RelinkResourceFileListener(sublime_plugin.EventListener):
    """
    Re-links resource files. When using symlinks, sublime won't automatically reload them
    See https://github.com/sublimehq/sublime_text/issues/2419
    Credit @FichteFoll

    Extended to also relink when:
    1. The file is somewhere matching /dotfiles/
    2. There is a link at Packages/User matching the same name as the current
    """

    def on_post_save_async(self, view):
        path = view.file_name()
        if not path:
            return
        packages_path = sublime.packages_path()

        if path.startswith(packages_path) and os.path.islink(path):
            self._relink(path)
        elif "/dotfiles/" in path:  # does the job
            filename = os.path.basename(path)
            symlink_path = os.path.join(packages_path, "User", filename)
            if os.path.islink(symlink_path):
                link_target = os.path.abspath(os.readlink(symlink_path))
                if link_target == path:
                    self._relink(symlink_path)

    def _relink(self, path):
        link_path = os.readlink(path)
        print("relinking", path, link_path)
        os.unlink(path)
        os.symlink(link_path, path)
