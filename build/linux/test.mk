define TEST_RULE
$(1): OBJ := $(1).o
$(1): DIR := $(2)
$(1): TEST := $(3)
$(1): $(2)$(3).cpp $(TEST_OBJS) $(CPP_SRCS) $(CPP_INCS) $(TEST_INCS)
	@echo 'Building Test: $(3)'
	@echo 'Invoking: GCC C++ Compiler'
	@$(MKDIR) build/$$(DIR)
	$(G++) $(PROJ_INC) $(DEP_INC) $(CPP_DEFAULT_FLAGS) $(CPP_DEBUG_FLAGS) $(TEST_PROJECT_FLAGS) -MMD -MP -MF"$(1).d" -MT"$$(OBJ)" -o "$$(OBJ)" "$(2)$(3).cpp"
	@echo 'Invoking: GCC C++ Linker'
	$(G++) $(CPP_DEFAULT_LINK_FLAGS) $(TEST_PROJECT_LINK_FLAGS) $(TEST_PROJECT_LIB_PATHS) -o "$(1)" $(USER_OBJS) $(OBJS) $(TEST_OBJS) $$(OBJ) $(TEST_PROJECT_LIBS) $(DEP_STATICS)
	@echo 'Finished building: $(3)'
	@echo ' '

$(1).rpt: DIR := $(2)
$(1).rpt: TEST := $(3)
$(1).rpt: $(1)
	@echo 'Running Test: $(1)'
	@$(MKDIR) report/$$(DIR)
	@$(MKDIR) build/resources
	$(1) | tee report/$(2)/$(3).rpt && cp report/$$(DIR)$$(TEST).rpt $(1).rpt
	@echo 'Finished: $(1)'
	@echo ' '

$(1).valg: DIR := $(2)
$(1).valg: TEST := $(3)
$(1).valg: $(1)
	@echo 'Running Valgrind profile: $(1)'
	@$(MKDIR) report/$$(DIR)
	@$(MKDIR) build/resources
	valgrind --log-file=report/$(2)/$(3).valg --leak-check=full --show-reachable=yes --num-callers=100 --trace-children=yes --suppressions=test/resources/valgrind/suppressions.valg $(1) &&\
		test 1 -eq `grep -c '0 errors from 0 contexts' report/$$(DIR)$$(TEST).valg; echo $?` &&\
		cp report/$$(DIR)$$(TEST).valg $(1).valg
	@echo 'Finished: $(1)'
	@echo ' '
endef

test: PROJ_INC += $(TEST_INC)
test: release $(TEST_REPORTS)

valgrind: release $(VALGRIND_REPORTS)

# Test targets
$(foreach tgt,$(TEST_TARGETS),$(eval $(call TEST_RULE,$(tgt),$(subst build/,,$(dir $(tgt))),$(notdir $(tgt)))))

cppcheck: report/cppcheck.xml

report/cppcheck.xml: $(CPP_SRCS) $(CPP_INCS)
	@echo 'Running cppcheck'
	@$(MKDIR) report
	@rm -f report/cppcheck_err.xml && cppcheck --inline-suppr --xml -I public $(DEP_INC) --enable=all --suppress=missingInclude --inconclusive --xml-version=2 --std=posix . 2> report/cppcheck.xml && test 6 -eq `grep -v -e '^$$' report/cppcheck.xml | wc -l` || mv report/cppcheck.xml report/cppcheck_err.xml
	@test -f report/cppcheck.xml
	@echo 'Finished running cppcheck'
	@echo ' '

lcov: report/lcov/index.html

report/lcov/index.html: test $(TEST_TARGETS)
ifeq ($(TEST_TARGETS),)
	@echo 'Skipping test coverage report'
else
	@echo 'Generating test coverage report'
	@echo '$(CURDIR)'
	@$(MKDIR) report/lcov
	@lcov --capture --directory build --output-file report/coverage.info
	@lcov --extract report/coverage.info "$(CURDIR)*" --output-file report/coverage.info
	@lcov --remove report/coverage.info "test*" --output-file report/coverage.info
	@genhtml -p "$(CURDIR)" report/coverage.info --output-directory report/lcov
	@echo 'Finished generating test coverage report'
	@echo ' '
endif
