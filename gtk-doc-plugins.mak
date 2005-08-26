###########################################################################
# Everything below here is generic and you shouldn't need to change it.
###########################################################################
# thomas: except of course that we did

# thomas: copied from glib-2
# We set GPATH here; this gives us semantics for GNU make
# which are more like other make's VPATH, when it comes to
# whether a source that is a target of one rule is then
# searched for in VPATH/GPATH.
#
GPATH = $(srcdir)

# thomas: make docs parallel installable
TARGET_DIR=$(HTML_DIR)/$(DOC_MODULE)-@GST_MAJORMINOR@

EXTRA_DIST = 				\
	$(content_files)		\
	$(extra_files)			\
	$(HTML_IMAGES)			\
	$(DOC_MAIN_SGML_FILE)		\
	$(DOC_OVERRIDES)		\
	$(DOC_MODULE)-sections.txt

# we don't add inspect-build.stamp here since this is run manually
# by docs maintainers and result is commited to CVS
DOC_STAMPS =				\
	scan-build.stamp		\
	tmpl-build.stamp		\
	sgml-build.stamp		\
	html-build.stamp		\
	$(srcdir)/tmpl.stamp		\
	$(srcdir)/sgml.stamp		\
	$(srcdir)/html.stamp

SCANOBJ_FILES =				\
	$(DOC_MODULE).args		\
	$(DOC_MODULE).hierarchy		\
	$(DOC_MODULE).interfaces	\
	$(DOC_MODULE).prerequisites	\
	.libs/$(DOC_MODULE)-scan.o	\
	$(DOC_MODULE).signals

CLEANFILES = $(SCANOBJ_FILES) $(DOC_MODULE)-unused.txt $(DOC_STAMPS)

if HAVE_GTK_DOC
all-local: html-build.stamp

#### scan ####

# in the case of non-srcdir builds, the built gst directory gets added
# to gtk-doc scanning; but only then, to avoid duplicates
scan-build.stamp: $(HFILE_GLOB) $(SCANOBJ_DEPS) $(basefiles)
	@echo '*** Scanning header files ***'
	    if test x"$(srcdir)" != x. ; then				\
	        cp $(srcdir)/$(DOC_MODULE).types . ;			\
	        chmod u+w $(DOC_MODULE).types ;				\
	    fi ;							\
	    GST_PLUGIN_PATH=`cd $(top_builddir) && pwd`			\
	    GST_PLUGIN_PATH_ONLY=1					\
	    CC="$(GTKDOC_CC)" LD="$(GTKDOC_LD)" 			\
	    CFLAGS="$(GTKDOC_CFLAGS)" LDFLAGS="$(GTKDOC_LIBS)"		\
	    $(GST_DOC_SCANOBJ) --type-init-func="gst_init(NULL,NULL)"	\
	        --module=$(DOC_MODULE) ;				\
	if test "x$(top_srcdir)" != "x$(top_builddir)";			\
        then								\
          export BUILT_OPTIONS="--source-dir=$(top_builddir)/gst";	\
        fi;								\
	gtkdoc-scan							\
		$(SCAN_OPTIONS) $(EXTRA_HFILES)				\
		--module=$(DOC_MODULE)					\
		$$BUILT_OPTIONS						\
		--ignore-headers="$(IGNORE_HFILES)"
	touch scan-build.stamp

$(DOC_MODULE)-decl.txt $(SCANOBJ_FILES): scan-build.stamp
	@true

#### templates ####

### FIXME: make this error out again when docs are fixed for 0.9
tmpl-build.stamp: $(DOC_MODULE)-decl.txt $(SCANOBJ_FILES) $(DOC_MODULE)-sections.txt $(DOC_OVERRIDES)
	@echo '*** Rebuilding template files ***'
	if test x"$(srcdir)" != x. ; then \
	    cp $(srcdir)/$(DOC_MODULE)-sections.txt . ; \
	    touch $(DOC_MODULE)-decl.txt ; \
	fi
	gtkdoc-mktmpl --module=$(DOC_MODULE) | tee tmpl-build.log
	@cat $(DOC_MODULE)-unused.txt
	@if ! test -z "`grep -v GstPoptOption $(DOC_MODULE)-unused.txt`"; then \
	    true; fi # exit 1; fi
	rm -f tmpl-build.log
	touch tmpl-build.stamp

tmpl.stamp: tmpl-build.stamp
	@true

#### inspect stuff ####
# this is stuff that should be built/updated manually by people that work
# on docs

# only look at the plugins in this module when building inspect .xml stuff
INSPECT_REGISTRY=$(top_builddir)/docs/plugins/inspect-registry.xml
INSPECT_ENVIRONMENT=\
        GST_PLUGIN_PATH_ONLY=yes \
        GST_PLUGIN_PATH=$(top_builddir)/gst:$(top_builddir)/sys:$(top_builddir)/ext \
        GST_REGISTRY=$(INSPECT_REGISTRY)


# update the element and plugin XML descriptions; store in inspect/
inspect:
	mkdir inspect

inspect-update:
	rm inspect-build.stamp
	make inspect-build.stamp

# FIXME: inspect.timestamp should be written to by gst-xmlinspect.py
# IFF the output changed; see gtkdoc-mktmpl
inspect-build.stamp: inspect
	$(INSPECT_ENVIRONMENT) $(PYTHON) \
		$(top_srcdir)/common/gst-xmlinspect.py inspect
	$(INSPECT_ENVIRONMENT) $(PYTHON) \
		$(top_srcdir)/common/mangle-tmpl.py tmpl
	echo -n "timestamp" > inspect.stamp
	touch inspect-build.stamp

inspect.stamp: inspect-build.stamp
	@true

#### xml ####

### FIXME: make this error out again when docs are fixed for 0.9
# first convert inspect/*.xml to xml
sgml-build.stamp: tmpl.stamp inspect.stamp $(CFILE_GLOB) $(top_srcdir)/common/plugins.xsl
	@echo '*** Building XML ***'
	@-mkdir -p xml
	@for a in inspect/*.xml; do \
            xsltproc $(top_srcdir)/common/plugins.xsl $$a > xml/`basename $$a`; done
	gtkdoc-mkdb \
		--module=$(DOC_MODULE) \
		--source-dir=$(DOC_SOURCE_DIR) \
		--main-sgml-file=$(srcdir)/$(DOC_MAIN_SGML_FILE) \
		--output-format=xml \
		--ignore-files="$(IGNORE_HFILES) $(IGNORE_CFILES)" \
		$(MKDB_OPTIONS) \
		| tee sgml-build.log
	@if grep "WARNING:" sgml-build.log > /dev/null; then true; fi # exit 1; fi
	cp ../version.entities xml
	rm sgml-build.log
	touch sgml-build.stamp

sgml.stamp: sgml-build.stamp
	@true

#### html ####

html-build.stamp: sgml.stamp $(DOC_MAIN_SGML_FILE) $(content_files) $(top_srcdir)/common/plugins.xsl
	@echo '*** Building HTML ***'
	if test -d html; then rm -rf html; fi
	mkdir html
	cp $(srcdir)/$(DOC_MAIN_SGML_FILE) html
	@for f in $(content_files); do cp $(srcdir)/$$f html; done
	cp -pr xml html
	cp ../version.entities html
	cd html && gtkdoc-mkhtml $(DOC_MODULE) $(DOC_MAIN_SGML_FILE)
	rm -f html/$(DOC_MAIN_SGML_FILE)
	rm -rf html/xml
	rm -f html/version.entities
	test "x$(HTML_IMAGES)" = "x" || for i in "" $(HTML_IMAGES) ; do \
	    if test "$$i" != ""; then cp $(srcdir)/$$i html ; fi; done
	@echo '-- Fixing Crossreferences' 
	gtkdoc-fixxref --module-dir=html --html-dir=$(HTML_DIR) $(FIXXREF_OPTIONS)
	touch html-build.stamp
else
all-local:
endif

clean-local:
	rm -f *~ *.bak
	rm -rf xml html
	rm -rf .libs

maintainer-clean-local: clean
	cd $(srcdir) && rm -rf xml html $(DOC_MODULE)-decl-list.txt $(DOC_MODULE)-decl.txt

# company: don't delete .sgml and -sections.txt as they're in CVS
# FIXME : thomas added all sgml files and some other things to make
# make distcheck work
distclean-local: clean
	rm -f $(DOC_MODULE)-decl-list.txt
	rm -f $(DOC_MODULE)-decl.txt
	rm -f $(DOC_MODULE)-undocumented.txt
	rm -f $(DOC_MODULE)-unused.txt
	rm -rf tmpl/*.sgml.bak
	rm -f $(DOC_MODULE).hierarchy
	rm -f *.stamp || true
	if test x"$(srcdir)" != x. ; then \
	    rm -f $(DOC_MODULE)-docs.sgml ; \
	    rm -f $(DOC_MODULE).types ; \
	    rm -f $(DOC_MODULE).interfaces ; \
            rm -f $(DOC_MODULE)-overrides.txt ; \
	    rm -f $(DOC_MODULE).prerequisites ; \
	    rm -f $(DOC_MODULE)-sections.txt ; \
	    rm -rf tmpl/*.sgml ; \
	fi
	rm -rf *.o

# thomas: make docs parallel installable; devhelp requires majorminor too
install-data-local:
	$(mkinstalldirs) $(DESTDIR)$(TARGET_DIR) 
	(installfiles=`echo ./html/*.html`; \
	if test "$$installfiles" = './html/*.html'; \
	then echo '-- Nothing to install' ; \
	else \
	  for i in $$installfiles; do \
	    echo '-- Installing '$$i ; \
	    $(INSTALL_DATA) $$i $(DESTDIR)$(TARGET_DIR); \
	  done; \
	  pngfiles=`echo ./html/*.png`; \
	  if test "$$pngfiles" != './html/*.png'; then \
	    for i in $$pngfiles; do \
	      echo '-- Installing '$$i ; \
	      $(INSTALL_DATA) $$i $(DESTDIR)$(TARGET_DIR); \
	    done; \
	  fi; \
	  echo '-- Installing $(srcdir)/html/$(DOC_MODULE).devhelp' ; \
	  $(INSTALL_DATA) $(srcdir)/html/$(DOC_MODULE).devhelp \
	    $(DESTDIR)$(TARGET_DIR)/$(DOC_MODULE)-@GST_MAJORMINOR@.devhelp; \
	  echo '-- Installing $(srcdir)/html/index.sgml' ; \
	  $(INSTALL_DATA) $(srcdir)/html/index.sgml $(DESTDIR)$(TARGET_DIR); \
		if test -e $(srcdir)/html/style.css; then \
			echo '-- Installing $(srcdir)/html/style.css' ; \
			$(INSTALL_DATA) $(srcdir)/html/style.css $(DESTDIR)$(TARGET_DIR); \
		fi; \
	fi) 
uninstall-local:
	(installfiles=`echo ./html/*.html`; \
	if test "$$installfiles" = './html/*.html'; \
	then echo '-- Nothing to uninstall' ; \
	else \
	  for i in $$installfiles; do \
	    rmfile=`basename $$i` ; \
	    echo '-- Uninstalling $(DESTDIR)$(TARGET_DIR)/'$$rmfile ; \
	    rm -f $(DESTDIR)$(TARGET_DIR)/$$rmfile; \
	  done; \
	  pngfiles=`echo ./html/*.png`; \
	  if test "$$pngfiles" != './html/*.png'; then \
	    for i in $$pngfiles; do \
	      rmfile=`basename $$i` ; \
	      echo '-- Uninstalling $(DESTDIR)$(TARGET_DIR)/'$$rmfile ; \
	      rm -f $(DESTDIR)$(TARGET_DIR)/$$rmfile; \
	    done; \
	  fi; \
	  echo '-- Uninstalling $(DESTDIR)$(TARGET_DIR)/$(DOC_MODULE).devhelp' ; \
	  rm -f $(DESTDIR)$(TARGET_DIR)/$(DOC_MODULE)-@GST_MAJORMINOR@.devhelp; \
	  echo '-- Uninstalling $(DESTDIR)$(TARGET_DIR)/index.sgml' ; \
	  rm -f $(DESTDIR)$(TARGET_DIR)/index.sgml; \
		if test -e $(DESTDIR)$(TARGET_DIR)/style.css; then \
			echo '-- Uninstalling $(DESTDIR)$(TARGET_DIR)/style.css' ; \
			rm -f $(DESTDIR)$(TARGET_DIR)/style.css; \
		fi; \
	fi) 
	if test -d $(DESTDIR)$(TARGET_DIR); then rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(TARGET_DIR) 2>/dev/null; fi; true

#
# Require gtk-doc when making dist
#
if HAVE_GTK_DOC
dist-check-gtkdoc:
else
dist-check-gtkdoc:
	@echo "*** gtk-doc must be installed and enabled in order to make dist"
	@false
endif

dist-hook: dist-check-gtkdoc dist-hook-local
	mkdir $(distdir)/tmpl
	mkdir $(distdir)/xml
	mkdir $(distdir)/html
	-cp $(srcdir)/tmpl/*.sgml $(distdir)/tmpl
	-cp $(srcdir)/sgml/*.xml $(distdir)/xml
	-cp $(srcdir)/html/index.sgml $(distdir)/html
	-cp $(srcdir)/html/*.html $(srcdir)/html/*.css $(distdir)/html
	-cp $(srcdir)/html/$(DOC_MODULE).devhelp $(distdir)/html

	images=$(HTML_IMAGES) ;    	      \
	for i in "" $$images ; do		      \
	  if test "$$i" != ""; then cp $(srcdir)/$$i $(distdir)/html ; fi; \
	done

.PHONY : dist-hook-local