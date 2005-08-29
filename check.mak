clean-local-check:
	for i in `find . -name ".libs" -type d`; do \
	  rm -rf $$i; \
	done

if HAVE_VALGRIND
# hangs spectacularly on some machines, so let's not do this by default yet
check-local-disabled:
	make valgrind
else
check-local-disabled:
	@true
endif

$(CHECK_REGISTRY).rebuild:
	-rm $(CHECK_REGISTRY)
	make $(CHECK_REGISTRY)

# run any given test by running make test.check
%.check: % $(CHECK_REGISTRY).rebuild
	@$(TESTS_ENVIRONMENT)					\
	CK_DEFAULT_TIMEOUT=20					\
	$*

# valgrind any given test by running make test.valgrind
%.valgrind: % $(CHECK_REGISTRY).rebuild
	$(REGISTRY_ENVIRONMENT)					\
	CK_DEFAULT_TIMEOUT=20					\
	libtool --mode=execute					\
	$(VALGRIND_PATH) -q --suppressions=$(SUPPRESSIONS)	\
	--tool=memcheck --leak-check=yes --trace-children=yes	\
	$* 2>&1 | tee valgrind.log
	@if grep "tely lost" valgrind.log; then			\
	    rm valgrind.log;					\
	    exit 1;						\
	fi
	@rm valgrind.log

# gdb any given test by running make test.gdb
%.gdb: % $(CHECK_REGISTRY).rebuild
	$(REGISTRY_ENVIRONMENT)					\
	CK_FORK=no						\
	libtool --mode=execute					\
	gdb $*


# valgrind all tests
valgrind: $(TESTS)
	@echo "Valgrinding tests ..."
	@failed=0;							\
	for t in $(filter-out $(VALGRIND_TESTS_DISABLE),$(TESTS)); do	\
		make $$t.valgrind;					\
		if test "$$?" -ne 0; then                               \
                        echo "Valgrind error for test $$t";		\
			failed=`expr $$failed + 1`;			\
			whicht="$$whicht $$t";				\
                fi;							\
	done;								\
	if test "$$failed" -ne 0; then					\
		echo "$$failed tests had leaks under valgrind:";	\
		echo "$$whicht";					\
		false;							\
	fi
