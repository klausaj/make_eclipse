RM := rm -rf
CP := cp -a
MKDIR := mkdir -p
PROJ_BUILDER := ../../tools/scripts/eclipse/linux/projectBuilder.sh
G++ := g++
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

# Assumes all projects have a public, private, linux, and test directory
SUBDIRS := public private linux $(PROJDIRS)
TESTDIRS := test $(PROJTESTDIRS)
ALLDIRS := $(SUBDIRS) $(TESTDIRS)

# All of the sources participating in the build are defined here
CPP_FIND = $(wildcard $(sub)/*.cpp) $(wildcard $(sub)/*/*.cpp)

TESTAPP_SRCS := $(wildcard test/*_test.cpp)
CPP_SRCS := $(filter-out $(TEST_SRCS),$(foreach sub,$(SUBDIRS),$(CPP_FIND)))
TEST_SRCS := $(filter-out $(TESTAPP_SRCS),$(foreach sub,$(TESTDIRS),$(CPP_FIND)))
OBJS := $(addprefix build/,$(CPP_SRCS:.cpp=.o))
TESTAPP_OBJS := $(addprefix build/,$(TESTAPP_SRCS:.cpp=.o))
TEST_OBJS := $(addprefix build/,$(TEST_SRCS:.cpp=.o))
CPP_DEPS := $(addprefix build/,$(CPP_SRCS:.cpp=.d))
TEST_DEPS := $(addprefix build/,$(TEST_SRCS:.cpp=.d))$(addprefix build/,$(TESTAPP_SRCS:.cpp=.d))

TEST_TARGETS := $(subst .o,,$(foreach tgt,$(TESTAPP_OBJS),$(tgt)))
TEST_REPORTS := $(foreach tgt,$(TEST_TARGETS),$(tgt).rpt)
VALGRIND_REPORTS := $(foreach tgt,$(TEST_TARGETS),$(tgt).valg)

PROJ_INC := $(foreach sub,$(SUBDIRS),-I"$(PWD)/$(sub)")
TEST_INC := $(foreach sub,$(TESTDIRS),-I"$(PWD)/$(sub)")
DEP_INC := $(foreach dep,$(DEP_PROJECTS),-I"$(PWD)/../$(dep)/public")
DEP_LIB_PATHS := $(foreach dep,$(DEP_PROJECTS),-L"$(PWD)/../$(dep)/build")
DEP_LIBS := $(foreach dep,$(DEP_PROJECTS),-l$(dep))

INC_FIND = $(wildcard $(sub)/*.h)
DEP_INC_FIND = $(wildcard ../$(dep)/public/*.h)
CPP_INCS := $(foreach sub,$(SUBDIRS),$(INC_FIND)) $(foreach dep,$(DEP_PROJECTS),$(DEP_INC_FIND))
INC_PATHS := $(foreach dir,$(PROJDIRS),/$(PROJECT)/$(dir)) $(foreach dep,$(DEP_PROJECTS),/$(dep)/public)

CPP_STD := c++14
CPP_RELEASE_FLAGS := -O3
CPP_DEBUG_FLAGS := -O0 -g3 -DDEBUG -fprofile-arcs -ftest-coverage --coverage
CPP_DEFAULT_FLAGS := -std=$(CPP_STD) -Wpedantic -Wall -Wextra -Wconversion -Werror -c -fmessage-length=0

CPP_FLAGS = $(CPP_DEFAULT_FLAGS)
CPP_LINK_FLAGS = $(CPP_DEFAULT_LINK_FLAGS)

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

define SUB_RULE
build/$(1)/%.o: $(1)/%.cpp
	@echo 'Building file: $$<'
	@echo 'Invoking: GCC C++ Compiler'
	echo $$<.cpp
	echo build//$$<.cpp
	echo $$(dir build//$$<.cpp)
	$(MKDIR) $$(dir build/$$<.cpp)
	$(G++) $(PROJ_INC) $(TEST_INC) $(DEP_INC) $$(CPP_FLAGS) -MMD -MP -MF"$$(@:%.o=%.d)" -MT"$$(@)" -o "$$@" "$$<"
	@echo 'Finished building: $$<'
	@echo ' '
endef

define TEST_RULE
$(1): OBJ := $(1).o
$(1): DIR := $(2)
$(1): TEST := $(3)
$(1): $(2)$(3).cpp $(TEST_OBJS) $(CPP_SRCS) $(CPP_INCS)
	@echo 'Building Test: $(3)'
	@echo 'Invoking: GCC C++ Compiler'
	@$(MKDIR) build/$$(DIR)
	$(G++) $(PROJ_INC) $(DEP_INC) $(CPP_DEFAULT_FLAGS) $(CPP_DEBUG_FLAGS) $(TEST_PROJECT_FLAGS) -MMD -MP -MF"$(1).d" -MT"$$(OBJ)" -o "$$(OBJ)" "$(2)$(3).cpp"
	@echo 'Invoking: GCC C++ Linker'
	$(G++) $(CPP_DEFAULT_LINK_FLAGS) $(TEST_PROJECT_LINK_FLAGS) $(TEST_PROJECT_LIB_PATHS) -o "$(1)" $(USER_OBJS) $(OBJS) $(TEST_OBJS) $$(OBJ) $(TEST_PROJECT_LIBS) $(DEP_LIB_PATHS) $(DEP_LIBS)
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

$(1).valg: DIR := $(2)
$(1).valg: TEST := $(3)
$(1).valg: $(1)
	@echo 'Running Valgrind profile: $(1)'
	@$(MKDIR) report/$$(DIR)
	@$(MKDIR) build/resources
	valgrind --log-file=report/$(2)/$(3).valg --leak-check=full --show-reachable=yes --num-callers=100 --trace-children=yes $(1) && cp report/$$(DIR)$$(TEST).valg $(1).valg
	@echo 'Finished: $(1)'
	@echo ' '
endef

# All Target
all: debug

# Build targets
release: TARGET := $(CPP_TARGET)
release: CPP_FLAGS += $(CPP_PROJECT_FLAGS) $(CPP_RELEASE_FLAGS)
release: CPP_LINK_FLAGS += $(CPP_PROJECT_LINK_FLAGS)
release: CPP_LIB_PATHS := $(CPP_PROJECT_LIB_PATHS) $(DEP_LIB_PATHS)
release: CPP_LIBS := $(CPP_PROJECT_LIBS) $(DEP_LIBS)
release: build/$(TARGET) $(TEST_TARGETS)

debug: TARGET := $(CPP_TARGET)
debug: CPP_FLAGS += $(CPP_PROJECT_FLAGS) $(CPP_DEBUG_FLAGS) $(DEBUG_PROJECT_FLAGS)
debug: CPP_LINK_FLAGS += $(CPP_PROJECT_LINK_FLAGS) $(CPP_DEBUG_LINK_FLAGS) $(DEBUG_PROJECT_LINK_FLAGS)
debug: CPP_LIB_PATHS := $(CPP_PROJECT_LIB_PATHS) $(DEBUG_PROJECT_LIB_PATHS) $(DEP_LIB_PATHS)
debug: CPP_LIBS := $(CPP_PROJECT_LIBS) $(DEBUG_PROJECT_LIBS) $(DEP_LIBS)
debug: build/$(TARGET) $(TEST_TARGETS)

test: release $(TEST_REPORTS)

valgrind: release $(VALGRIND_REPORTS)

# Linker target
build/$(TARGET): $(OBJS) $(CPP_INCS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	$(G++) $(CPP_LINK_FLAGS) $(CPP_LIB_PATHS) -o "build/$(TARGET)" $(USER_OBJS) $(OBJS) $(CPP_LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

# Subdir targets
$(foreach sub,$(ALLDIRS),$(eval $(call SUB_RULE,$(sub))))

# Test targets
$(foreach tgt,$(TEST_TARGETS),$(eval $(call TEST_RULE,$(tgt),$(subst build/,,$(dir $(tgt))),$(notdir $(tgt)))))

cppcheck: report/cppcheck.xml
	@echo 'Running cppcheck'
	@$(MKDIR) report
	@cppcheck --inline-suppr --xml -I public $(DEP_INC) --enable=all --inconclusive --std=posix . 2> report/cppcheck.xml
	@echo 'Finished running cppcheck'
	@echo ' '

report/cppcheck.xml: $(CPP_SRCS) $(CPP_INCS)

lcov: report/lcov/index.html
ifeq ($(TEST_TARGETS),)
	@echo 'Skipping test coverage report'
else
	@echo 'Generating test coverage report'
	@$(MKDIR) report/lcov
	@lcov --capture --directory build --output-file report/coverage.info
	@lcov --remove report/coverage.info "/usr*" --output-file report/coverage.info
	@lcov --remove report/coverage.info "test*" --output-file report/coverage.info
	@genhtml report/coverage.info --output-directory report/lcov
	@echo 'Finished generating test coverage report'
	@echo ' '
endif

report/lcov/index.html: test

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

# Clean target
clean:
	@echo 'Cleaning $(PROJECT)'
	@$(RM) build report
	@echo 'Finished cleaning $(PROJECT)'
	@echo ' '

.PHONY: all clean
