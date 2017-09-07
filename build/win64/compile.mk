define SUB_RULE
build/$(1)/%.obj: $(1)/%.cpp
	@echo 'Building file: $$<'
	@echo 'Invoking: GCC C++ Compiler'
	@echo $$<.cpp
	@echo build/$$<.cpp
	@echo $$(dir build/$$<.cpp)
	$(MKDIR) $$(dir build/$$<.cpp)
	$(G++) $$(CPP_FLAGS) $(PROJ_INC) $(TEST_INC) $(DEP_INC) "$$<" -Fo"$$@"
	@echo 'Finished building: $$<'
	@echo ' '
endef

# Subdir targets
$(foreach sub,$(ALLDIRS),$(eval $(call SUB_RULE,$(sub))))
