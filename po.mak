# rule to download .po
po/%.po-download:
	@LI=$(@:po/%.po-download=%) && cd po && wget -q -O $$LI.po.tmp http://www.iro.umontreal.ca/translation/maint/$(PACKAGE)/$$LI && if ! diff $$LI.po $$LI.po.tmp > /dev/null 2>&1; then echo "$$LI.po changed, updated"; mv $$LI.po.tmp $$LI.po; else rm $$LI.po.tmp; fi
                                                                                
# a rule to redownload po files
download-po:
	for LI in `cat po/LINGUAS`; do echo Checking $$LI.po; make po/$$LI.po-download; done
