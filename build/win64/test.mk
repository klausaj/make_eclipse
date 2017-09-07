define TEST_RULE
$(1): OBJ := $(1).obj
$(1): DIR := $(2)
$(1): TEST := $(3)
$(1): $(2)$(3).cpp $(TEST_OBJS) $(CPP_SRCS) $(CPP_INCS)
	@echo 'Building Test: $(3)'
	@echo 'Invoking: GCC C++ Compiler'
	@$(MKDIR) build/$$(DIR)
	$(G++) $(PROJ_INC) $(DEP_INC) $(CPP_DEFAULT_FLAGS) $(CPP_DEBUG_FLAGS) $(CPP_PROJECT_FLAGS) $(TEST_PROJECT_FLAGS) "$(2)$(3).cpp" -Fo"$$(OBJ)"
	@echo 'Invoking: GCC C++ Linker'
	$(G++) $(USER_OBJS) $(OBJS) $(TEST_OBJS) $$(OBJ) $(TEST_PROJECT_LIBS) $(CPP_PROJECT_LIBS) $(DEP_STATICS) -link /out:"$(1).exe" -SUBSYSTEM:CONSOLE $(CPP_DEFAULT_LINK_FLAGS) $(TEST_PROJECT_LINK_FLAGS) $(TEST_PROJECT_LIB_PATHS) $(CPP_PROJECT_LIB_PATHS) $(WIN_LIB_PATHS)
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
endef

test: release $(TEST_REPORTS)

# Test targets
$(foreach tgt,$(TEST_TARGETS),$(eval $(call TEST_RULE,$(tgt),$(subst build/,,$(dir $(tgt))),$(notdir $(tgt)))))
