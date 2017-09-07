RM := rm -rf
CP := cp -a
MKDIR := mkdir -p
PROJ_BUILDER := ../../tools/scripts/eclipse/win64/projectBuilder.sh
G++ := cl.exe
AR := lib.exe
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

# Assumes all projects have a public, private, linux, and test directory
SUBDIRS := public private win64 $(PROJDIRS)
TESTDIRS := test $(PROJTESTDIRS)
ALLDIRS := $(SUBDIRS) $(TESTDIRS)

# All of the sources participating in the build are defined here
CPP_FIND = $(shell find $(sub)/ -type f -name *.cpp)

TESTAPP_SRCS := $(wildcard test/*_test.cpp)
CPP_SRCS := $(filter-out $(TEST_SRCS),$(foreach sub,$(SUBDIRS),$(CPP_FIND)))
TEST_SRCS := $(filter-out $(TESTAPP_SRCS),$(foreach sub,$(TESTDIRS),$(CPP_FIND)))
OBJS := $(addprefix build/,$(CPP_SRCS:.cpp=.obj))
STATIC := lib$(PROJECT).lib
SHARED := lib$(PROJECT).dll
EXEC := $(PROJECT).exe
TESTAPP_OBJS := $(addprefix build/,$(TESTAPP_SRCS:.cpp=.obj))
TEST_OBJS := $(addprefix build/,$(TEST_SRCS:.cpp=.obj))
CPP_DEPS := $(addprefix build/,$(CPP_SRCS:.cpp=.d))
TEST_DEPS := $(addprefix build/,$(TEST_SRCS:.cpp=.d))$(addprefix build/,$(TESTAPP_SRCS:.cpp=.d))

TEST_TARGETS := $(subst .obj,,$(foreach tgt,$(TESTAPP_OBJS),$(tgt)))
TEST_REPORTS := $(foreach tgt,$(TEST_TARGETS),$(tgt).rpt)

TARGETS :=

PROJ_INC := -I"$(MSVS_HOME)/VC/include" -I"$(WIN_SDK_INC)/ucrt" $(foreach sub,$(SUBDIRS),-I"$(PWD)/$(sub)")
TEST_INC := $(foreach sub,$(TESTDIRS),-I"$(PWD)/$(sub)")
DEP_INC := $(foreach dep,$(DEP_PROJECTS),-I"$(PWD)/../$(dep)/public")

DEP_LIB_PATHS := $(foreach dep,$(DEP_PROJECTS),-LIBPATH:"$(PWD)/../$(dep)/build")
DEP_LIBS := $(foreach dep,$(DEP_PROJECTS),lib$(dep).lib)
DEP_STATICS := $(foreach dep,$(DEP_PROJECTS),$(PWD)/../$(dep)/build/lib$(dep).lib)

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

WIN_LIB_PATHS=-LIBPATH:"$(MSVS_HOME)\VC\LIB\amd64" -LIBPATH:"$(WIN_SDK_LIB)/um/x64" -LIBPATH:"$(WIN_SDK_LIB)/ucrt/x64"

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif
