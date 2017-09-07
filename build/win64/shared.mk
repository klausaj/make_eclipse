TARGETS += build/$(SHARED)

# Linker target
build/$(SHARED): $(OBJS) $(CPP_INCS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	@$(MKDIR) build
	$(G++)  $(USER_OBJS) $(OBJS) $(CPP_LIBS) $(DEP_LIBS) -link /out:"build/$(SHARED)" -DLL -MACHINE:X64 -EHsc -c -WX $(CPP_LINK_FLAGS) $(CPP_LIB_PATHS) $(DEP_LIB_PATHS) $(WIN_LIB_PATHS)
	@echo 'Finished building target: $@'
	@echo ' '
