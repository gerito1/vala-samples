class MyApp : Gtk.Window {
	private Gtk.SourceView text_view;
	private Gtk.SourceLanguageManager language_manager;

    private Gtk.ToggleToolButton check_spell_button;
	private Gspell.Checker checker;
	private Gspell.InlineCheckerGtv inline_checker;

	public MyApp () {
		this.title = "Gspell sample";
		this.window_position = Gtk.WindowPosition.CENTER;
		this.destroy.connect(Gtk.main_quit);
		set_default_size (600,400);

		var toolbar = new Gtk.Toolbar ();

		var open_buton = new Gtk.ToolButton (
			new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.MENU),
			null);
		toolbar.add (open_buton);
		open_buton.clicked.connect (on_open_clicked);

		check_spell_button = new Gtk.ToggleToolButton ();
        check_spell_button.set_icon_widget ( new Gtk.Image.from_icon_name ("tools-check-spelling",
			Gtk.IconSize.MENU));
		check_spell_button.toggled.connect (on_toggle_spell);
		toolbar.add (check_spell_button);

		this.text_view = new Gtk.SourceView ();
		this.text_view.hexpand = true;
		this.text_view.vexpand = true;

		this.language_manager = Gtk.SourceLanguageManager.get_default ();

		this.checker = new Gspell.Checker (null);
		unowned GLib.SList <Gspell.Language> lang_list = Gspell.Language.get_available();
		if (lang_list.length () != 0) {
			checker.set_language (lang_list.data);
			this.text_view.populate_popup.connect (on_populate_menu);
		} else {
			warning ("There's no available languages");
		}

		var scroll = new Gtk.ScrolledWindow (null, null);
		scroll.set_policy ( Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		scroll.add (text_view);

		var grid = new Gtk.Grid ();
		grid.attach (toolbar, 0, 0, 1, 1);
		grid.attach (scroll, 0, 1, 1, 1);

		this.add (grid);
	}

	private void on_open_clicked () {
		var file_chooser = new Gtk.FileChooserDialog ("Open File",
			this, Gtk.FileChooserAction.OPEN,
			"_Cancel", Gtk.ResponseType.CANCEL,
			"_Open", Gtk.ResponseType.ACCEPT);
		if (file_chooser.run() == Gtk.ResponseType.ACCEPT) {
			open_file (file_chooser.get_filename ());
		}
		file_chooser.destroy ();
	}

	private void on_toggle_spell () {
		warning ("Spell toggled");
		if (check_spell_button.active == true) {
			inline_checker = new Gspell.InlineCheckerGtv (text_view.buffer as Gtk.SourceBuffer, checker);
			inline_checker.attach_view (text_view);
		} else {
			inline_checker.detach_view (text_view);
			inline_checker = null;
		}
	}

	private void open_file (string file_name ) {
		try {
			string text;
			GLib.FileUtils.get_contents (file_name, out text);
			this.text_view.buffer.text = text;
		} catch (Error e) {
			warning ("Error: %s", e.message);
		}
	}

	private void on_populate_menu ( Gtk.Menu menu) {
		add_language_submenu (menu);
		add_highlight_submenu (menu);
		menu.show_all ();
	}

	void add_language_submenu (Gtk.Menu menu) {
		var lang_menu = new Gtk.MenuItem ();
		lang_menu.set_label ("Languages");

		var submenu = new Gtk.Menu ();
		lang_menu.set_submenu (submenu);

		unowned GLib.SList<Gtk.RadioMenuItem> group = null;
		Gtk.RadioMenuItem? item = null;

		var current_lang = this.checker.get_language ();

		unowned GLib.SList <Gspell.Language> language_list = Gspell.Language.get_available ();

		foreach (var lang in language_list) {
			var lang_name = lang.get_name ();
			if (item == null) {
				item = new Gtk.RadioMenuItem (null);
			} else {
				group = item.get_group ();
				item = new Gtk.RadioMenuItem (group);
			}
			item.set_label (lang_name);

			submenu.add (item);
			item.toggled.connect (() => {
				checker.set_language (lang);
			});

			if (current_lang == lang) {
				item.active = true;
			}
		}
		menu.add (lang_menu);
	}

	void add_highlight_submenu (Gtk.Menu menu) {
		var highlight_menu = new Gtk.MenuItem ();
		highlight_menu.set_label ("Highlight Mode");

		var submenu = new Gtk.Menu ();
		highlight_menu.set_submenu (submenu);

		unowned GLib.SList<Gtk.RadioMenuItem> group = null;
		Gtk.RadioMenuItem? item = null;

		unowned string [] language_ids = this.language_manager.get_language_ids ();

		item = new Gtk.RadioMenuItem (null);
        item.set_label ("Normal Text");
		submenu.add (item);

		item.toggled.connect (() => {
			(this.text_view.buffer as Gtk.SourceBuffer).set_language (null);
		});

		foreach (var lang_id in language_ids) {
			var lang = language_manager.get_language (lang_id);
			group = item.get_group ();
			item = new Gtk.RadioMenuItem (group);
			item.set_label (lang.name);

			submenu.add (item);
			item.toggled.connect (() => {
				(this.text_view.buffer as Gtk.SourceBuffer).set_language (lang);
			});

			if ((this.text_view.buffer as Gtk.SourceBuffer).language == lang) {
				item.active = true;
			}
		}
		menu.add (highlight_menu);
	}

	public static int main (string[] args) {
		Gtk.init (ref args);

		var window = new MyApp ();
		window.show_all ();
		Gtk.main ();
		return 0;
	}

}
