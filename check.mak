clean-local-check:
	for i in `find . -name ".libs" -type d`; do \
	  rm -rf $$i; \
	done

if HAVE_VALGRIND
# hangs spectacularly on some machines, so let's not do this by default yet
check-valgrind:
	make valgrind
else
check-valgrind:
	@true
endif

LOOPS = 10

# run any given test by running make test.check
%.check: %
	@$(TESTS_ENVIRONMENT)					\
	CK_DEFAULT_TIMEOUT=20					\
	$*

# run any given test in a loop
%.torture: %
	@for i in `seq 1 $(LOOPS)`; do				\
	$(TESTS_ENVIRONMENT)					\
	CK_DEFAULT_TIMEOUT=20					\
	$*; done

# run any given test in an infinite loop
%.forever: %
	@while true; do						\
	$(TESTS_ENVIRONMENT)					\
	CK_DEFAULT_TIMEOUT=20					\
	$* || break; done

# valgrind any given test by running make test.valgrind
%.valgrind: %
	$(TESTS_ENVIRONMENT)					\
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
%.gdb: %
	$(REGISTRY_ENVIRONMENT)					\
	CK_FORK=no						\
	libtool --mode=execute					\
	gdb $*

# torture tests
torture: $(TESTS)
	@echo "Torturing tests ..."
	for i in `seq 1 $(LOOPS)`; do				\
		make check ||					\
		(echo "Failure after $$i runs"; exit 1) ||	\
		exit 1;						\
	done
	@banner="All $(LOOPS) loops passed";			\
	dashes=`echo "$$banner" | sed s/./=/g`;			\
	echo $$dashes; echo $$banner; echo $$dashes

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

help:
	@echo "make check                 -- run all checks"
	@echo "make torture               -- run all checks $(LOOPS) times"
	@echo "make (dir)/(test).check    -- run the given check once"
	@echo "make (dir)/(test).forever  -- run the given check forever"
	@echo "make (dir)/(test).torture  -- run the given check $(LOOPS) times"
	@echo
	@echo "make (dir)/(test).gdb      -- start up gdb for the given test"
	@echo
	@echo "make valgrind              -- valgrind all tests"
	@echo "make (dir)/(test).valgrind -- valgrind the given test"
