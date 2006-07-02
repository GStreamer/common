lcov:
	find . -name "*.gcda" -exec rm {} \;
	make -C tests/check inspect
	make -C tests/check check
	make lcov-report

lcov-report:
	@-rm -rf lcov
	mkdir lcov
	lcov --directory . --capture --output-file lcov/lcov.info
	lcov -l lcov/lcov.info | grep -v "`cd $(top_srcdir) && pwd`" | cut -d: -f1 > lcov/remove
	lcov -l lcov/lcov.info | grep "tests/check/" | cut -d: -f1 >> lcov/remove
	lcov -r lcov/lcov.info `cat lcov/remove` > lcov/lcov.cleaned.info
	rm lcov/remove
	mv lcov/lcov.cleaned.info lcov/lcov.info
	genhtml -t "$(PACKAGE_STRING)" -o lcov lcov/lcov.info
