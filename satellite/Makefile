NAME		= $(shell echo `awk '{ print $$1 }' name`)
VERSION		= $(shell echo `awk '{ print $$1 }' version`)
RELEASE		= $(shell echo `awk '{ print $$2 }' version`)
NEWRELEASE	= $(shell echo $$(($(RELEASE) + 1)))
NEWVERSION	= $(shell echo $$(($(VERSION) + 1)))

help:
	@echo "Run 'make rpm' to create a new rpm: $(NAME)-$(VERSION)-$(RELEASE).noarch.rpm."
	@echo "To change the name pass in NAME=<newvalue>"
	@echo ""
	@echo "   make NAME=newpkgname rpm"
	@echo ""
	@echo "To create a new release use the bumprelease target"
	@echo ""
	@echo "   make bumprelease rpm"
	@echo ""

newname:
	@echo $(NAME) > name

debug:
	@echo $(VERSION)
	@echo $(NAME)

bumprelease:
	@echo "$(VERSION) $(NEWRELEASE)" > version

clean:
	rm -rf rpm-build
	rm -rf dist

spec:
	-cp dummy.spec $(NAME).spec

maketar:
	mkdir -p dist/$(NAME)-$(VERSION)/
	cp spacewalk.spec dist/$(NAME)-$(VERSION)/
	cd dist/; tar czf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)/
	rm -rf dist/$(NAME)-$(VERSION)/
	
rpm: clean newname maketar
	mkdir -p rpm-build
	cp dist/*.gz rpm-build/
	echo "$(VERSION) $(RELEASE)" > rpm-build/version
	echo "$(NAME)" > rpm-build/name
	rpmbuild --define "_topdir %(pwd)/rpm-build" \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	--define '_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm' \
	--define "_specdir %{_topdir}" \
	--define "_sourcedir %{_topdir}" \
	-ba spacewalk.spec
