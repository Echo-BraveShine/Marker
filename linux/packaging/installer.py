#!/usr/bin/env python3
"""Optional GTK welcome/install window for the portable TAR distribution."""
import os
from pathlib import Path
import subprocess
import sys
import threading
import gi
from installer_i18n import TEXT, language_for_environment

gi.require_version('Gtk', '3.0')
from gi.repository import GLib, Gtk

bundle = Path(sys.argv[1]).resolve()


class Installer(Gtk.Window):
    def __init__(self):
        super().__init__()
        self.language = language_for_environment()
        self.stage = 'welcome'
        self.set_default_size(660, 370)
        self.set_resizable(False)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_icon_from_file(str(bundle / 'share/icons/hicolor/256x256/apps/marker.png'))
        self.connect('delete-event', self.on_close)
        self.busy = False
        self.done = False
        body = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(body)
        body.pack_start(Gtk.Image.new_from_file(str(bundle / 'installer-welcome.png')), False, False, 0)
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        content.set_border_width(28)
        body.pack_start(content, True, True, 0)
        self.message = Gtk.Label()
        self.message.set_xalign(0)
        self.message.set_line_wrap(True)
        content.pack_start(self.message, True, True, 0)
        destination = Gtk.Label(label=str(Path.home() / '.local/share/marker'))
        destination.set_xalign(0)
        destination.get_style_context().add_class('dim-label')
        content.pack_start(destination, False, False, 0)
        actions = Gtk.Box(spacing=12)
        content.pack_start(actions, False, False, 0)
        self.languages = Gtk.ComboBoxText()
        self.languages.append('en', 'English')
        self.languages.append('zh', '简体中文')
        self.languages.set_active_id(self.language)
        self.languages.connect('changed', self.change_language)
        actions.pack_start(self.languages, False, False, 0)
        self.spinner = Gtk.Spinner()
        actions.pack_start(self.spinner, False, False, 0)
        close = Gtk.Button()
        self.close_button = close
        close.connect('clicked', lambda _: self.close())
        actions.pack_end(close, False, False, 0)
        self.install = Gtk.Button(label='Install Marker')
        self.install.get_style_context().add_class('suggested-action')
        self.install.connect('clicked', self.on_install)
        actions.pack_end(self.install, False, False, 0)
        self.apply_language()
        css = Gtk.CssProvider()
        css.load_from_data(b'window { background: #f7f9fc; color: #102b4d; } button { border-radius: 8px; padding: 7px 16px; } button.suggested-action { background: #286c7b; color: white; border-color: #286c7b; }')
        self.get_style_context().add_provider_for_screen(self.get_screen(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    def apply_language(self):
        text = TEXT[self.language]
        self.set_title(text['title'])
        self.message.set_text(text[self.stage])
        self.close_button.set_label(text['close'])
        self.install.set_label(text['open' if self.done else 'install'])
        self.languages.set_tooltip_text(text['language'])

    def change_language(self, combo):
        self.language = combo.get_active_id()
        self.apply_language()

    def on_close(self, *_):
        if self.busy:
            return True
        Gtk.main_quit()
        return False

    def on_install(self, _):
        if self.done:
            subprocess.Popen([str(Path.home() / '.local/share/marker/marker')], start_new_session=True)
            self.close()
            return
        self.busy = True
        self.install.set_sensitive(False)
        self.close_button.set_sensitive(False)
        self.spinner.start()
        self.stage = 'working'
        self.languages.set_sensitive(False)
        self.apply_language()
        threading.Thread(target=self.perform_install, daemon=True).start()

    def perform_install(self):
        try:
            result = subprocess.run(['bash', str(bundle / 'install-user.sh'), str(bundle)], capture_output=True, text=True, encoding='utf-8', errors='replace', env=dict(os.environ, MARKER_INSTALLER_LANGUAGE=self.language))
            GLib.idle_add(self.finish, result.returncode, result.stdout + result.stderr)
        except OSError as error:
            GLib.idle_add(self.finish, 1, str(error))

    def finish(self, code, details):
        self.busy = False
        self.spinner.stop()
        self.install.set_sensitive(True)
        self.close_button.set_sensitive(True)
        self.languages.set_sensitive(True)
        if code:
            self.stage = 'failed'
            self.apply_language()
            dialog = Gtk.MessageDialog(transient_for=self, modal=True, message_type=Gtk.MessageType.ERROR, buttons=Gtk.ButtonsType.NONE, text=TEXT[self.language]['error'])
            dialog.add_button(TEXT[self.language]['close'], Gtk.ResponseType.CLOSE)
            dialog.format_secondary_text(details[-1600:])
            dialog.run()
            dialog.destroy()
        else:
            self.done = True
            self.stage = 'ready'
            self.apply_language()
        return GLib.SOURCE_REMOVE


if __name__ == '__main__':
    window = Installer()
    window.show_all()
    Gtk.main()
