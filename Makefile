DESTDIR?=/usr/local

install:
	install -d $(DESTDIR)/bin
	install -d $(DESTDIR)/share/ddm/docs
	install -d $(DESTDIR)/share/ddm/examples
	install -d $(DESTDIR)/lib/ddm
	install -D -m755 ddm           $(DESTDIR)/bin
	install -D -m755 ddm-buffer    $(DESTDIR)/bin
	install -D -m755 ddm-clean     $(DESTDIR)/bin
	install -D -m755 ddm-flush-svn $(DESTDIR)/bin
	install -D -m755 ddm-move      $(DESTDIR)/bin
	install -D -m755 ddm-pull-svn  $(DESTDIR)/bin
	install -D -m755 ddm-wizard    $(DESTDIR)/bin
	install -D -m644 Examples.textile MANUAL TODO.txt $(DESTDIR)/share/ddm/docs
	cp -ax ddm-plugins              $(DESTDIR)/share/ddm/examples/
	install -D -m644 ddm-lib        $(DESTDIR)/lib/ddm/
	sed -i 's#$$DESTDIR#$(DESTDIR)#' $(DESTDIR)/bin/ddm-buffer $(DESTDIR)/bin/ddm-move

uninstall:
	rm -f $(DESTDIR)/bin/ddm      $(DESTDIR)/bin/ddm-buffer   $(DESTDIR)/bin/ddm-clean $(DESTDIR)/bin/ddm-flush-svn
	rm -f $(DESTDIR)/bin/ddm-move $(DESTDIR)/bin/ddm-pull-svn $(DESTDIR)/bin/ddm-wizard
	rm -rf $(DESTDIR)/share/ddm
	rm -rf $(DESTDIR)/lib/ddm
