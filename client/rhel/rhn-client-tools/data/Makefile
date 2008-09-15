# Makefile for Update Agent
#
# $Id$

PREFIX		?= /

GLADES		= gui.glade progress.glade rh_register.glade
PUPLET_SS       = puplet-screenshot.png
KEYS		= RHNS-CA-CERT

# Directories for installation
RHNSHARE_DIR	= $(PREFIX)/usr/share/rhn
PIXMAP_DIR	= $(PREFIX)/usr/share/pixmaps
PNG16_DIR	= $(PREFIX)/usr/share/icons/hicolor/16x16/apps
PNG24_DIR	= $(PREFIX)/usr/share/icons/hicolor/24x24/apps
PNG32_DIR	= $(PREFIX)/usr/share/icons/hicolor/32x32/apps
PNG48_DIR	= $(PREFIX)/usr/share/icons/hicolor/48x48/apps
# all dirs
DIRS		= $(PIXMAP_DIR) \
		  $(PNG16_DIR) $(PNG24_DIR) $(PNG32_DIR) $(PNG48_DIR) \
		  $(RHNSHARE_DIR) $(RHNSHARE_DIR)/up2date_client \

# INSTALL scripts 
INSTALL         = install -p --verbose 
INSTALL_DIR     = $(INSTALL) -m 755 -d 
INSTALL_DATA    = $(INSTALL) -m 644 

# Handy defines 
PIXMAPS         = /usr/share/firstboot/pixmaps/
SHADOWMAN       = shadowman-round-48.png

# For subdirs, required exports 

all:
# Nothing to do

$(DIRS):
	@$(INSTALL_DIR) $@

install:: $(DIRS)
	
	$(INSTALL_DATA) $(GLADES) $(RHNSHARE_DIR)/up2date_client

	# install the hicolor theme icons for up2date
	$(INSTALL_DATA) up2date-icons/16x16/up2date.png $(PNG16_DIR)/ 
	$(INSTALL_DATA) up2date-icons/24x24/up2date.png $(PNG24_DIR)/ 
	$(INSTALL_DATA) up2date-icons/32x32/up2date.png $(PNG32_DIR)/ 
	$(INSTALL_DATA) up2date-icons/48x48/up2date.png $(PNG48_DIR)/ 

	# this is lame and should be dealt with in the code
	sed -i -e "s|$(SHADOWMAN)|$(PIXMAPS)/$(SHADOWMAN)|g" \
		$(RHNSHARE_DIR)/up2date_client/*glade
	# This sucks. We should be able to use PIXMAP_DIR, but then when making
	# an rpm prefix is set to something different than where it'll be when
	# the rpm is installed. We need a better solution.
	sed -i -e "s|$(PUPLET_SS)|/usr/share/pixmaps/$(PUPLET_SS)|g" \
		$(RHNSHARE_DIR)/up2date_client/*glade

	$(INSTALL_DATA) $(PUPLET_SS) $(PIXMAP_DIR)

	$(INSTALL_DATA) $(KEYS)  $(RHNSHARE_DIR)

clean::
	@find . -name .\#\* -exec rm -fv {} \;
	@rm -fv *.bak
	@rm -fv *.gladep
