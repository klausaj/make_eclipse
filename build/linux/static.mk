TARGETS += build/$(STATIC)

# Library target
build/$(STATIC): $(OBJS) $(CPP_INCS)
	@echo 'Building target: $@'
	@echo 'Building static library'
	@$(MKDIR) build
	$(AR) rs "build/$(STATIC)" $(OBJS)
	@echo 'Finished building target: $@'
	@echo ' '
