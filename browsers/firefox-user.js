/* ============================================================
 * Firefox user.js — Matugen theme support
 * ============================================================ */

// Enable userChrome.css / userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Use dark theme for internal pages
user_pref("browser.theme.content-theme", 0);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.theme.windows-acrylic", true);

// Use system title bar (better GTK integration)
user_pref("browser.tabs.inTitlebar", 1);

// Enable GTK dark theme preference
user_pref("widget.content.allow-gtk-dark-theme", true);
user_pref("widget.gtk.alt-theme.dark", true);

// Smooth scrolling
user_pref("general.smoothScroll", true);
