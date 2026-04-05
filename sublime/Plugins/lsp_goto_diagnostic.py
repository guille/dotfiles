from LSP.plugin.core.settings import userprefs  # pyright: ignore[reportMissingImports]
from LSP.plugin.goto import (  # pyright: ignore[reportMissingImports]
    DiagnosticUriInputHandler,
    LspGotoDiagnosticCommand,
)

# (Temporary?) patch for https://github.com/sublimelsp/LSP/issues/2844


class CustomDiagnosticUriInputHandler(DiagnosticUriInputHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._max_severity = userprefs().show_diagnostics_severity_level


class CustomLspGotoDiagnosticCommand(LspGotoDiagnosticCommand):
    def is_enabled(self) -> bool:
        max_severity = userprefs().show_diagnostics_severity_level
        return any(
            any(session.diagnostics.get_diagnostics(max_severity).values())
            for session in self.sessions()
        )

    def input(self, args: dict):
        view = self.window.active_view()
        if not view:
            return None
        sessions = list(self.sessions())
        if (
            (uri := args.get("uri")) and uri != "$view_uri"
        ):  # for backwards compatibility with previous command args
            return CustomDiagnosticUriInputHandler(self.window, view, sessions, uri)
        if (uri := view.settings().get("lsp_uri")) and self._has_diagnostics(uri):
            return CustomDiagnosticUriInputHandler(self.window, view, sessions, uri)
        return CustomDiagnosticUriInputHandler(self.window, view, sessions)

    def _has_diagnostics(self, uri) -> bool:
        max_severity = userprefs().show_diagnostics_severity_level
        return any(
            session.diagnostics.get_diagnostics_for_uri(uri, max_severity)
            for session in self.sessions()
        )
