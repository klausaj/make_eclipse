define SUB_RULE
build/$(1)/%.o: $(1)/%.cpp
	@echo 'Building file: $$<'
	@echo 'Invoking: GCC C++ Compiler'
	@echo $$<
	@echo build/$$<
	@echo $$(dir build/$$<)
	$(MKDIR) $$(dir build/$$<)
	$(G++) $(PROJ_INC) $(TEST_INC) $(DEP_INC) $$(CPP_FLAGS) -MMD -MP -MF"$$(@:%.o=%.d)" -MT"$$(@)" -o "$$@" "$$<"
	@echo 'Finished building: $$<'
	@echo ' '
endef

# Subdir targets
$(foreach sub,$(ALLDIRS),$(eval $(call SUB_RULE,$(sub))))
