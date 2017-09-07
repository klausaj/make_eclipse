TARGETS += build/$(EXEC)

# Linker target
build/$(EXEC): $(OBJS) $(CPP_INCS) $(DEP_STATICS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	@$(MKDIR) build
	$(G++) $(CPP_LINK_FLAGS) -static-libstdc++ $(CPP_LIB_PATHS) -o "build/$(EXEC)" $(USER_OBJS) $(OBJS) $(DEP_STATICS) $(CPP_LIBS)
	@echo 'Finished building target: $@'
	@echo ' '
