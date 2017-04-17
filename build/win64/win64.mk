RM := rm -rf
CP := cp -a
MKDIR := mkdir -p
PROJ_BUILDER := ../../tools/scripts/eclipse/win64/projectBuilder.sh
G++ := cl.exe
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

# Assumes all projects have a public, private, and test directory
SUBDIRS := public private win64 $(PROJDIRS)
TESTDIRS := test $(PROJTESTDIRS)
ALLDIRS := $(SUBDIRS) $(TESTDIRS)

# All of the sources participating in the build are defined here
CPP_FIND = $(wildcard $(sub)/*.cpp) $(wildcard $(sub)/*/*.cpp)

TESTAPP_SRCS := $(wildcard test/*_test.cpp)
CPP_SRCS := $(filter-out $(TEST_SRCS),$(foreach sub,$(SUBDIRS),$(CPP_FIND)))
TEST_SRCS := $(filter-out $(TESTAPP_SRCS),$(foreach sub,$(TESTDIRS),$(CPP_FIND)))
OBJS := $(addprefix build/,$(CPP_SRCS:.cpp=.obj))
TESTAPP_OBJS := $(addprefix build/,$(TESTAPP_SRCS:.cpp=.obj))
TEST_OBJS := $(addprefix build/,$(TEST_SRCS:.cpp=.obj))
CPP_DEPS := $(addprefix build/,$(CPP_SRCS:.cpp=.d))
TEST_DEPS := $(addprefix build/,$(TEST_SRCS:.cpp=.d))$(addprefix build/,$(TESTAPP_SRCS:.cpp=.d))

TEST_TARGETS := $(subst .obj,,$(foreach tgt,$(TESTAPP_OBJS),$(tgt)))
TEST_REPORTS := $(foreach tgt,$(TEST_TARGETS),$(tgt).rpt)

PROJ_INC := -I"$(MSVS_HOME)/VC/include" -I"$(WIN_SDK_INC)/ucrt" $(foreach sub,$(SUBDIRS),-I"$(PWD)/$(sub)")
TEST_INC := $(foreach sub,$(TESTDIRS),-I"$(PWD)/$(sub)")
DEP_INC := $(foreach dep,$(DEP_PROJECTS),-I"$(PWD)/../$(dep)/public")

INC_FIND = $(wildcard $(sub)/*.h)
DEP_INC_FIND = $(wildcard ../$(dep)/public/*.h)
CPP_INCS := $(foreach sub,$(SUBDIRS),$(INC_FIND)) $(foreach dep,$(DEP_PROJECTS),$(DEP_INC_FIND))
INC_PATHS := $(foreach dir,$(PROJDIRS),/$(PROJECT)/$(dir)) $(foreach dep,$(DEP_PROJECTS),/$(dep)/public)

CPP_STD := c++14
CPP_RELEASE_FLAGS :=
CPP_DEBUG_FLAGS := -DEBUG
CPP_DEFAULT_FLAGS := -EHsc -c -WX

CPP_DEFAULT_LINK_FLAGS :=

CPP_FLAGS = $(CPP_DEFAULT_FLAGS)
CPP_LINK_FLAGS = $(CPP_DEFAULT_LINK_FLAGS)

WIN_LIB_PATHS=-LIBPATH:"$(MSVS_HOME)\VC\LIB\amd64"  -LIBPATH:"$(WIN_SDK_LIB)/um/x64" -LIBPATH:"$(WIN_SDK_LIB)/ucrt/x64"

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

define SUB_RULE
build/$(1)/%.obj: $(1)/%.cpp
	@echo 'Building file: $$<'
	@echo 'Invoking: C++ Compiler'
	echo $$<.cpp
	echo build//$$<.cpp
	echo $$(dir build//$$<.cpp)
	$(MKDIR) $$(dir build/$$<.cpp)
	$(G++) $$(CPP_FLAGS) $(PROJ_INC) $(TEST_INC) $(DEP_INC) "$$<" -Fo"$$@"
	@echo 'Finished building: $$<'
	@echo ' '
endef

define TEST_RULE
$(1): OBJ := $(1).obj
$(1): DIR := $(2)
$(1): TEST := $(3)
$(1): $(2)$(3).cpp $(TEST_OBJS) $(CPP_SRCS) $(CPP_INCS)
	@echo 'Building Test: $(3)'
	@echo 'Invoking: C++ Compiler'
	@$(MKDIR) build/$$(DIR)
	$(G++) $(PROJ_INC) $(TEST_INC) $(DEP_INC) $(TEST_PROJECT_FLAGS) $(CPP_DEFAULT_FLAGS) $(CPP_PROJECT_FLAGS) $(CPP_DEBUG_FLAGS) $(DEBUG_PROJECT_FLAGS) "$(2)$(3).cpp" -Fo"$$(OBJ)"
	@echo 'Invoking: C++ Linker'
	$(G++) $(USER_OBJS) $(OBJS) $(TEST_OBJS) $$(OBJ) $(TEST_PROJECT_LIBS) -link /out:"build/test/$(3).exe" $(CPP_DEFAULT_LINK_FLAGS) $(TEST_PROJECT_LINK_FLAGS) $(TEST_PROJECT_LIB_PATHS) $(WIN_LIB_PATHS)
	@echo 'Finished building: $(3)'
	@echo ' '

$(1).rpt: DIR := $(2)
$(1).rpt: TEST := $(3)
$(1).rpt: $(1)
	@echo 'Running Test: $(1)'
	@$(MKDIR) report/$$(DIR)
	@$(MKDIR) build/resources
	$(1).exe | tee report/$(2)/$(3).rpt && cp report/$$(DIR)$$(TEST).rpt $(1).rpt
	@echo 'Finished: $(1)'
	@echo ' '
endef

# All Target
all: debug

# Build targets
release: TARGET := $(CPP_TARGET)
release: CPP_FLAGS += $(CPP_PROJECT_FLAGS) $(CPP_RELEASE_FLAGS)
release: CPP_LINK_FLAGS += $(CPP_PROJECT_LINK_FLAGS)
release: CPP_LIB_PATHS := $(WIN_LIB_PATHS) $(CPP_PROJECT_LIB_PATHS)
release: CPP_LIBS := $(CPP_PROJECT_LIBS)
release: build/$(TARGET) $(TEST_TARGETS)

debug: TARGET := $(CPP_TARGET)
debug: CPP_FLAGS += $(CPP_PROJECT_FLAGS) $(CPP_DEBUG_FLAGS) $(DEBUG_PROJECT_FLAGS)
debug: CPP_LINK_FLAGS += $(CPP_PROJECT_LINK_FLAGS) $(CPP_DEBUG_LINK_FLAGS) $(DEBUG_PROJECT_LINK_FLAGS)
debug: CPP_LIB_PATHS := $(WIN_LIB_PATHS) $(CPP_PROJECT_LIB_PATHS) $(DEBUG_PROJECT_LIB_PATHS)
debug: CPP_LIBS := $(CPP_PROJECT_LIBS) $(DEBUG_PROJECT_LIBS)
debug: build/$(TARGET) $(TEST_TARGETS)

test: release $(TEST_REPORTS)

# Linker target
build/$(TARGET): $(OBJS) $(CPP_INCS)
	@echo 'Building target: $@'
	@echo 'Invoking: C++ Linker'
	$(G++) $(USER_OBJS) $(OBJS) $(CPP_LIBS) -link /out:"build/$(TARGET)" $(CPP_LINK_FLAGS) $(CPP_LIB_PATHS)
	@echo 'Finished building target: $@'
	@echo ' '

# Subdir targets
$(foreach sub,$(ALLDIRS),$(eval $(call SUB_RULE,$(sub))))

# Test targets
$(foreach tgt,$(TEST_TARGETS),$(eval $(call TEST_RULE,$(tgt),$(subst build/,,$(dir $(tgt))),$(notdir $(tgt)))))

# Eclipse project target
eclipse: eclipse-clean
	@echo 'Building Eclipse project: $(PROJECT)'
	@$(CP) ../../tools/templates/eclipse/projects/win64/.project .
	@$(CP) ../../tools/templates/eclipse/projects/win64/.cproject .
	@$(CP) ../../tools/templates/eclipse/projects/win64/.settings .
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

# Clean target
clean:
	@echo 'Cleaning $(PROJECT)'
	@$(RM) build report
	@echo 'Finished cleaning $(PROJECT)'
	@echo ' '

.PHONY: all clean
