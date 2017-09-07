RM := rm -rf
CP := cp -a
MKDIR := mkdir -p
PROJ_BUILDER := ../../tools/scripts/eclipse/linux/projectBuilder.sh
G++ := g++
AR := ar
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

# Assumes all projects have a public, private, linux, and test directory
SUBDIRS := public private linux $(PROJDIRS)
TESTDIRS := test $(PROJTESTDIRS)
ALLDIRS := $(SUBDIRS) $(TESTDIRS)

# All of the sources participating in the build are defined here
CPP_FIND = $(shell find $(sub)/ -type f -name *.cpp)

TESTAPP_SRCS := $(wildcard test/*_test.cpp)
CPP_SRCS := $(filter-out $(TEST_SRCS),$(foreach sub,$(SUBDIRS),$(CPP_FIND)))
TEST_SRCS := $(filter-out $(TESTAPP_SRCS),$(foreach sub,$(TESTDIRS),$(CPP_FIND)))
OBJS := $(addprefix build/,$(CPP_SRCS:.cpp=.o))
STATIC := lib$(PROJECT).a
SHARED := lib$(PROJECT).so
EXEC := $(PROJECT)
TESTAPP_OBJS := $(addprefix build/,$(TESTAPP_SRCS:.cpp=.o))
TEST_OBJS := $(addprefix build/,$(TEST_SRCS:.cpp=.o))
CPP_DEPS := $(addprefix build/,$(CPP_SRCS:.cpp=.d))
TEST_DEPS := $(addprefix build/,$(TEST_SRCS:.cpp=.d))$(addprefix build/,$(TESTAPP_SRCS:.cpp=.d))

TEST_TARGETS := $(subst .o,,$(foreach tgt,$(TESTAPP_OBJS),$(tgt)))
TEST_REPORTS := $(foreach tgt,$(TEST_TARGETS),$(tgt).rpt)
VALGRIND_REPORTS := $(foreach tgt,$(TEST_TARGETS),$(tgt).valg)

TARGETS :=

PROJ_INC := $(foreach sub,$(SUBDIRS),-I"$(PWD)/$(sub)")
TEST_INC := $(foreach sub,$(TESTDIRS),-I"$(PWD)/$(sub)")
DEP_INC := $(foreach dep,$(DEP_PROJECTS),-I"$(PWD)/../$(dep)/public")
DEP_LIB_PATHS := $(foreach dep,$(DEP_PROJECTS),-L"$(PWD)/../$(dep)/build")
DEP_LIBS := $(foreach dep,$(DEP_PROJECTS),-l$(dep))
DEP_STATICS := $(foreach dep,$(DEP_PROJECTS),$(PWD)/../$(dep)/build/lib$(dep).a)

INC_FIND = $(wildcard $(sub)/*.h)
DEP_INC_FIND = $(wildcard ../$(dep)/public/*.h)
CPP_INCS := $(foreach sub,$(SUBDIRS),$(INC_FIND)) $(foreach dep,$(DEP_PROJECTS),$(DEP_INC_FIND))
TEST_INCS := $(foreach sub,$(TESTDIRS),$(INC_FIND))
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
