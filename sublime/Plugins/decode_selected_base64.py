import base64
import binascii
import gzip
import html
import re
import zlib

import sublime_plugin

import sublime

_WHITESPACE = re.compile(rb"\s+")
_GZIP_MAGIC = b"\x1f\x8b"


def _decode(text: str) -> str:
    data = _WHITESPACE.sub(b"", text.encode())
    data += b"=" * (-len(data) % 4)
    try:
        raw = base64.b64decode(data, validate=True)
    except binascii.Error:
        # try url-safe variant (RFC 4648)
        raw = base64.b64decode(data, altchars=b"-_", validate=True)
    if raw[:2] == _GZIP_MAGIC:
        raw = gzip.decompress(raw)
    return raw.decode()


class DecodeSelectedBase64Command(sublime_plugin.TextCommand):
    def _popup(self, text: str, ok: bool):
        color, icon = ("green", "✅") if ok else ("red", "⚠️")
        self.view.show_popup(
            f"<div style='padding: 0 25%; border: 2px solid {color}'>"
            f"<h4>{icon} {html.escape(text)}</h4></div>",
            max_width=2048,
            max_height=2048,
        )

    def run(self, edit: sublime.Edit):
        regions = [r for r in self.view.sel() if not r.empty()]
        try:
            decoded = "\n".join(_decode(self.view.substr(r)) for r in regions)
        except binascii.Error:
            self._popup("Selection isn't valid base64", ok=False)
        except (OSError, EOFError, zlib.error):
            self._popup("Selection is gzipped but corrupt", ok=False)
        except UnicodeDecodeError:
            self._popup("Decoded bytes aren't valid UTF-8 text", ok=False)
        else:
            if not decoded:
                self._popup("Decoded to an empty string", ok=False)
                return
            sublime.set_clipboard(decoded)
            self._popup("Decoded string copied to clipboard!", ok=True)

    def is_enabled(self) -> bool:
        return any(not r.empty() for r in self.view.sel())
