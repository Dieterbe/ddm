# packagers, set DESTDIR to your "package directory" and PREFIX to the prefix you want to have on the end-user system
# end-users who install directly, without packaging: don't care about DESTDIR, update PREFIX if you want to
PREFIX?=/usr/local
INSTALLDIR?=$(DESTDIR)$(PREFIX)
SHAREDIR?=$(INSTALLDIR)/share/ddm


install:
	install -d $(INSTALLDIR)/bin
	install -d $(INSTALLDIR)/lib/ddm
	install -d $(SHAREDIR)/docs
	install -d $(SHAREDIR)/examples
	install -D -m755 ddm           $(INSTALLDIR)/bin
	install -D -m755 ddm-buffer    $(INSTALLDIR)/bin
	install -D -m755 ddm-clean     $(INSTALLDIR)/bin
	install -D -m755 ddm-flush-svn $(INSTALLDIR)/bin
	install -D -m755 ddm-move      $(INSTALLDIR)/bin
	install -D -m755 ddm-pull-svn  $(INSTALLDIR)/bin
	install -D -m755 ddm-wizard    $(INSTALLDIR)/bin
	install -D -m644 Examples.textile MANUAL TODO.txt $(SHAREDIR)/docs
	cp -ax ddm-plugins                  $(SHAREDIR)/examples/
	install -D -m644 ddm-lib            $(INSTALLDIR)/lib/ddm/
	sed -i 's#$$PREFIX#$(PREFIX)#' $(INSTALLDIR)/bin/ddm-buffer $(INSTALLDIR)/bin/ddm-move

uninstall:
	rm -f $(INSTALLDIR)/bin/ddm      $(INSTALLDIR)/bin/ddm-buffer   $(INSTALLDIR)/bin/ddm-clean $(INSTALLDIR)/bin/ddm-flush-svn
	rm -f $(INSTALLDIR)/bin/ddm-move $(INSTALLDIR)/bin/ddm-pull-svn $(INSTALLDIR)/bin/ddm-wizard
	rm -rf $(SHAREDIR)
	rm -rf $(INSTALLDIR)/lib/ddm
