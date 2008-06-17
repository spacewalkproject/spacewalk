HTMLROOT = .
POD2HTML = pod2html --htmlroot=$(HTMLROOT) --podpath=. \
		--libpods=mod_perl_cgi:mod_perl_api

POD = mod_perl_faq.pod mod_perl_cgi.pod mod_perl_api.pod
HTML = mod_perl_faq.html mod_perl_cgi.html mod_perl_api.html

.SUFFIXES: .pod .html

.pod.html:
	rm -f $*.html
	$(POD2HTML) --infile=$*.pod --outfile=$*.tmp
	sed 's/ manpage<\/A>/ FAQ<\/A>/' $*.tmp >$*.html
	rm $*.tmp

html:	$(HTML)

tar:	$(POD)
	tar cf - $(POD) mjtg-news.txt Makefile | gzip -9 >mod_perl_faq.tar.gz

clean:
	rm -f $(HTML) pod2html-*cache
