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
	$(TESTS_ENVIRONMENT)					\
	libtool --mode=execute					\
	$(VALGRIND_PATH) -q --suppressions=$(SUPPRESSIONS)	\
	--tool=memcheck --leak-check=yes --trace-children=yes	\
	$*

# valgrind all tests
valgrind: $(TESTS)
	@echo "Valgrinding tests ..."
	$(TESTS_ENVIRONMENT) $(GST_TOOLS_DIR)/gst-register-@GST_MAJORMINOR@
	@failed=0;							\
	for t in $(filter-out $(VALGRIND_TESTS_DISABLE),$(TESTS)); do	\
		make $$t.valgrind;					\
		if test "$$?" -ne 0; then                               \
                        echo "Valgrind error for test $$t";		\
			failed=`expr $$failed + 1`;			\
                fi;							\
	done;								\
	if test "$$failed" -ne 0; then					\
		echo "$$failed tests had leaks under valgrind";		\
		false;							\
	fi
