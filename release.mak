# include this snippet to add a common release: target by using
# include $(top_srcdir)/common/release.mak

# make bz2 as well
AUTOMAKE_OPTIONS = dist-bzip2

release: dist
	make $(PACKAGE)-$(VERSION).tar.gz.md5
	make $(PACKAGE)-$(VERSION).tar.bz2.md5

# generate md5 sum files
%.md5: %
	md5sum $< > $@
