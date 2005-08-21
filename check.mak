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

# run any given test by running make test.check
%.check: % $(CHECK_REGISTRY)
	@$(TESTS_ENVIRONMENT)					\
	$*

# valgrind any given test by running make test.valgrind
%.valgrind: % $(CHECK_REGISTRY)
	$(REGISTRY_ENVIRONMENT)					\
	libtool --mode=execute					\
	$(VALGRIND_PATH) -q --suppressions=$(SUPPRESSIONS)	\
	--tool=memcheck --leak-check=yes --trace-children=yes	\
	$* 2>&1 | tee valgrind.log
	@if grep "tely lost" valgrind.log; then			\
	    rm valgrind.log;					\
	    exit 1;						\
	fi
	@rm valgrind.log

# valgrind all tests
valgrind: $(TESTS) $(CHECK_REGISTRY)
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
