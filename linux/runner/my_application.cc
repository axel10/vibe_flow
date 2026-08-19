#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

static void setup_app_icon_and_desktop(GtkWindow* window) {
  g_autofree gchar* exe_path = g_file_read_link("/proc/self/exe", nullptr);
  if (exe_path == nullptr) return;

  g_autofree gchar* exe_dir = g_path_get_dirname(exe_path);
  
  // Try icon-windows-and-linux.png first, fallback to icon.png
  g_autofree gchar* icon_path = g_build_filename(
      exe_dir, "data", "flutter_assets", "assets", "images", "icon-windows-and-linux.png", nullptr);

  if (!g_file_test(icon_path, G_FILE_TEST_EXISTS)) {
    g_free(icon_path);
    icon_path = g_build_filename(
        exe_dir, "data", "flutter_assets", "assets", "images", "icon.png", nullptr);
  }

  if (g_file_test(icon_path, G_FILE_TEST_EXISTS)) {
    // 1. Set GTK window icon (X11 / window title bar)
    gtk_window_set_icon_from_file(window, icon_path, nullptr);

    // 2. Register/update .desktop file in ~/.local/share/applications/ for Wayland Dock matching
    const char* home = g_get_home_dir();
    if (home != nullptr) {
      g_autofree gchar* apps_dir = g_build_filename(home, ".local", "share", "applications", nullptr);
      g_mkdir_with_parents(apps_dir, 0755);

      g_autofree gchar* desktop_path = g_build_filename(apps_dir, "io.github.axel10.vynody.desktop", nullptr);
      g_autofree gchar* content = g_strdup_printf(
          "[Desktop Entry]\n"
          "Type=Application\n"
          "Name=Vynody\n"
          "Exec=%s\n"
          "Icon=%s\n"
          "StartupWMClass=%s\n"
          "Terminal=false\n",
          exe_path, icon_path, APPLICATION_ID);

      g_file_set_contents(desktop_path, content, -1, nullptr);
    }
  }
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
  if (windows != nullptr) {
    gtk_window_present(GTK_WINDOW(windows->data));
    return;
  }

  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  setup_app_icon_and_desktop(window);

  // Enable RGBA/transparency support for the window
  GdkScreen* window_screen = gtk_widget_get_screen(GTK_WIDGET(window));
  GdkVisual* visual = gdk_screen_get_rgba_visual(window_screen);
  if (visual != nullptr && gdk_screen_is_composited(window_screen)) {
    gtk_widget_set_visual(GTK_WIDGET(window), visual);
  }

  // Set up GTK CSS provider to make the window background transparent and
  // round all four corners of the client-side decoration shadow and window background,
  // matching the 18.0px corner radius defined in Dart (lib/main.dart).
  // When maximized, tiled, or fullscreen, remove the rounded corners (set border-radius to 0).
  GtkCssProvider* provider = gtk_css_provider_new();
  gtk_css_provider_load_from_data(provider,
                                  "window, window.csd, decoration {\n"
                                  "  background-color: transparent;\n"
                                  "  border-radius: 18px;\n"
                                  "}\n"
                                  "window.maximized, window.fullscreen, window.tiled,\n"
                                  "window.tiled-top, window.tiled-right, window.tiled-bottom, window.tiled-left,\n"
                                  "window.maximized decoration, window.fullscreen decoration, window.tiled decoration,\n"
                                  "window.tiled-top decoration, window.tiled-right decoration, window.tiled-bottom decoration, window.tiled-left decoration,\n"
                                  "window.maximized window.csd, window.fullscreen window.csd, window.tiled window.csd,\n"
                                  "window.tiled-top window.csd, window.tiled-right window.csd, window.tiled-bottom window.csd, window.tiled-left window.csd {\n"
                                  "  border-radius: 0;\n"
                                  "}\n",
                                  -1, nullptr);
  gtk_style_context_add_provider_for_screen(
      window_screen,
      GTK_STYLE_PROVIDER(provider),
      GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
  g_object_unref(provider);

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Vynody");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Vynody");
  }

  gtk_window_set_default_size(window, 1280, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#00000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_FLAGS_NONE, nullptr));
}
