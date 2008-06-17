
appdir = $(kde_datadir)/ksmarttray/
app_DATA = eventsrc

iconsdir = $(appdir)/icons/hicolor/48x48/apps/
icons_DATA = ksmarttray.png

bin_PROGRAMS = ksmarttray

INCLUDES = $(all_includes)

ksmarttray_CFLAGS = $(KDE_RPATH) $(all_libraries)
ksmarttray_LDFLAGS = $(KDE_RPATH) $(all_libraries)
ksmarttray_LDADD = $(LIB_KDECORE) $(LIB_KDEUI)
ksmarttray_SOURCES = ksmarttray.h ksmarttray.cc

METASOURCES = AUTO

messages: rc.cpp
	$(XGETTEXT) *.cpp *.cc common/*.cc --keyword=_ --keyword=tr -o $(podir)/kynaptic.pot
