# Copyright 2008, Steve 'Ashcrow' Milner <smilner@redhat.com>
#
# This software may be freely redistributed under the terms of the GNU
# general public license.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

BUILD_DIR := build

# Python doc related
EPYDOC_BIN := `which epydoc`
EPYDOC_SWITCHES := --inheritance listed --graph all --html
PYTHON_DOC_DIR := python-doc
PYTHON_DIRS := ../proxy/proxy ../backend/ ../client/rhel/rhnlib/ ../client/rhel/rhn-client-tools ../client/tools/

# Java doc related
JAVA_DOC_BIN := `which javadoc`
JAVA_DOC_SRC_VERSION := 8
JAVA_DOC_SRC_PATH := ../java/code/src/
JAVA_DOC_SUBPKGS := "com"
JAVA_DOC_DIR := javadoc
JAVA_DOC_CLASSPATH := "../java/lib/*:../java/build/build-lib/*:/usr/share/java/*"
#JAVA_DOC_EXTRA_ARGS := -tag "todo:X:" -tag "xmlrpc.param:X:" -tag "xmlrpc.returntype:X:" -tag "xmlrpc.doc:X:" -tag "xmlrpc.namespace:X:" -tag "xmlrpc.ignore:X:" "-Xdoclint:none"
JAVA_DOC_EXTRA_ARGS := -tag "todo:X:" -tag "xmlrpc.param:X:" -tag "xmlrpc.returntype:X:" -tag "xmlrpc.doc:X:" -tag "xmlrpc.namespace:X:" -tag "xmlrpc.ignore:X:"

# Schema Docs
# Created with DB Schema (http://oraschemadoc.sourceforge.net/)
# Requires CX_Oracle and graphviz
ORASCHEMADOC ?= oraschemadoc.py
DSN ?= user/pass@db
SCHEMA_DOC_DIR ?= db-schema

# TARGETS
# schema is not incldued here, since you need a live db
all: python java

python:
	mkdir -p $(BUILD_DIR)/py-doc-build
	$(SHELL ulimit -n 4096)
	echo "[epydoc]" > $(BUILD_DIR)/epydoc.lst
	echo -n "modules: " >> $(BUILD_DIR)/epydoc.lst
	find $(PYTHON_DIRS) -type f -name '*.py' | grep -v test | xargs echo -n >> $(BUILD_DIR)/epydoc.lst
	$(EPYDOC_BIN) $(EPYDOC_SWITCHES) -o $(PYTHON_DOC_DIR) --config $(BUILD_DIR)/epydoc.lst

java:
	$(JAVA_DOC_BIN) -locale en -source $(JAVA_DOC_SRC_VERSION) -d $(JAVA_DOC_DIR) -sourcepath $(JAVA_DOC_SRC_PATH) -subpackages $(JAVA_DOC_SUBPKGS) -classpath $(JAVA_DOC_CLASSPATH) $(JAVA_DOC_EXTRA_ARGS) -J-Xmx512m >/dev/null

schema:
	$(ORASCHEMADOC) --dia schema.dia --syntax --pb $(DSN) \
		$(SCHEMA_DOC_DIR) "Spacewalk DB Schema"

clean:
	rm -rf build/

distclean:
	rm -rf build/ $(PYTHON_DOC_DIR) $(JAVA_DOC_DIR) $(SCHEMA_DOC_DIR)
