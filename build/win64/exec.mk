TARGETS += build/$(EXEC)

# Linker target
build/$(EXEC): $(OBJS) $(CPP_INCS) $(DEP_STATICS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	@$(MKDIR) build
	$(G++) $(USER_OBJS) $(OBJS) $(DEP_STATICS) $(CPP_LIBS) -link /out:"build/$(EXEC)" -MACHINE:X64 $(CPP_LINK_FLAGS) $(CPP_LIB_PATHS) $(WIN_LIB_PATHS) $(DEP_LIB_PATHS)
	@echo 'Finished building target: $@'
	@echo ' '
