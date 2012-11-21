EL5_PKG=epel-release-5-4.noarch.rpm
EL6_PKG=epel-release-6-7.noarch.rpm
ELREPO6_PKG=elrepo-release-6-4.el6.elrepo.noarch.rpm

all: build

build: promote-nightly.sh promote-nightly.cron build-release.sh
	
promote-nightly.sh: templates/promote-nightly.sh.in
	@sed -e 's|@REMOTE_SERVER@|$(REMOTE_SERVER)|g' \
	    -e 's|@PYTHON_VIRTENV@|$(PYTHON_VIRTENV)|g' \
		-e 's|@ARADO_HOME@|$(ARADO_HOME)|g' \
		-e 's|@NIGHTLY_PATH@|$(NIGHTLY_PATH)|g' \
		-e 's|@PRIVATE_KEY@|$(PRIVATE_KEY)|g' \
		-e 's|@KEY_PATH@|$(KEY_PATH)|g' \
		-e 's|@NOTIFY_ADDRESS@|$(NOTIFY_ADDRESS)|g' \
		templates/promote-nightly.sh.in > promote-nightly.sh
	@chmod 755 promote-nightly.sh

promote-nightly.cron: templates/promote-nightly.cron.in
	@sed -e 's|@NIGHTLY_PATH@|$(NIGHTLY_PATH)|g' \
		templates/promote-nightly.cron.in > promote-nightly.cron

build-release.sh: templates/build-release.sh.in
	@sed -e 's|@KEY_PATH@|$(KEY_PATH)|g' \
		templates/build-release.sh.in > build-release.sh

install: build
	# Install scripts
	mkdir -p $(DESTDIR)$(NIGHTLY_PATH)
	install -pm 755 promote-nightly.sh $(DESTDIR)$(NIGHTLY_PATH)
	install -pm 755 build-release.sh $(DESTDIR)$(NIGHTLY_PATH)
	install -pm 755 checkbuild.py $(DESTDIR)$(NIGHTLY_PATH)
	install -pm 755 promote-packages.py $(DESTDIR)$(NIGHTLY_PATH)
	install -pm 755 create-reprepo-repo.sh $(DESTDIR)$(NIGHTLY_PATH)
	install -pm 644 release-package.spec $(DESTDIR)$(NIGHTLY_PATH)
	# Install cronjob
	mkdir -p $(DESTDIR)/etc/cron.d
	install -pm 644 promote-nightly.cron $(DESTDIR)/etc/cron.d/promote-nightly
	# Install virtualenv and arado
	virtualenv $(DESTDIR)$(PYTHON_VIRTENV)
	$(DESTDIR)$(PYTHON_VIRTENV)/bin/pip install requests
	git clone https://github.com/mspaulding06/arado $(DESTDIR)$(ARADO_HOME)
	cp $(DESTDIR)$(ARADO_HOME)/bin/* $(DESTDIR)$(ARADO_HOME)
	# Install repository packages
	mkdir -p $(DESTDIR)$(NIGHTLY_PATH)/packages/el5
	mkdir -p $(DESTDIR)$(NIGHTLY_PATH)/packages/el6
	wget http://download.fedoraproject.org/pub/epel/5/i386/$(EL5_PKG) \
		-O $(DESTDIR)$(NIGHTLY_PATH)/packages/el5/$(EL5_PKG)
	wget http://download.fedoraproject.org/pub/epel/6/i386/$(EL6_PKG) \
		-O $(DESTDIR)$(NIGHTLY_PATH)/packages/el6/$(EL6_PKG)
	wget http://elrepo.org/$(ELREPO6_PKG) \
		-O $(DESTDIR)$(NIGHTLY_PATH)/packages/el6/$(ELREPO6_PKG)
	ln -s $(EL5_PKG) $(DESTDIR)$(NIGHTLY_PATH)/packages/el5/epel-release-5.noarch.rpm
	ln -s $(EL6_PKG) $(DESTDIR)$(NIGHTLY_PATH)/packages/el6/epel-release-6.noarch.rpm
	ln -s $(ELREPO6_PKG) $(DESTDIR)$(NIGHTLY_PATH)/packages/el6/elrepo-release-6.noarch.rpm

clean:
	rm -f promote-nightly.sh
	rm -f promote-nightly.cron
	rm -f build-release.sh

include config.mk

