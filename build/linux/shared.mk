TARGETS += build/$(SHARED)

# Linker target
build/$(SHARED): $(OBJS) $(CPP_INCS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	@$(MKDIR) build
	$(G++) -shared $(CPP_LINK_FLAGS) $(CPP_LIB_PATHS) $(DEP_LIB_PATHS) -o "build/$(SHARED)" $(USER_OBJS) $(OBJS) $(CPP_LIBS) $(DEP_LIBS)
	@echo 'Finished building target: $@'
	@echo ' '
