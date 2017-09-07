# Eclipse project target
eclipse: eclipse-clean
	@echo 'Building Eclipse project: $(PROJECT)'
	@$(CP) ../../tools/templates/eclipse/projects/linux/.project .
	@$(CP) ../../tools/templates/eclipse/projects/linux/.cproject .
	@$(CP) ../../tools/templates/eclipse/projects/linux/.settings .
	@$(PROJ_BUILDER) -n $(PROJECT) -c "$(COMMENT)" -f "$(CPP_FLAGS)" -p "$(DEP_PROJECTS)" -i "$(INC_PATHS)" -s "$(SYS_INCS)"
	@echo 'Finished building Eclipse project: $(PROJECT)'
	@echo ' '

eclipse-clean:
	@echo 'Cleaning Eclipse project: $(PROJECT)'
	@$(RM) .project
	@$(RM) .cproject
	@$(RM) .settings
	@echo 'Finished cleaning Eclipse project: $(PROJECT)'
	@echo ' '
