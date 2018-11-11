# Generate a list of testbench vvp's
TB := $(basename $(notdir $(wildcard tb/*.v)))
TB_VVP := $(addsuffix .vvp,$(TB))

# Verilog generation
VERILOG_GEN := -g2005
WARNING_LEVEL := -Wanachronisms -Wimplicit -Wportbind -Wselect-range
TARGET := vvp

CMD_DIR := cmd

# Specify that all and clean are not file targets
.PHONY: all clean

all: $(TB_VVP)

clean:
	rm -rf *.vvp
	rm -rf *.vcd

# Use this define to automatically generate the targets fo testbench vvp's by
# reading the module dependency lists from their cmd files
define TB_template =
$(1).vvp: $$($(CMD_DIR)/$(1)_cmd)
	@echo Building $(1).vvp
	@iverilog -t$(TARGET) -c  $(CMD_DIR)/$(1)_cmd $(VERILOG_GEN) $(WARNING_LEVEL) -I config_headers -o $(1).vvp
endef

# Use eval to create new make targets
$(foreach tb,$(TB),$(eval $(CMD_DIR)/$(tb)_cmd := $(shell cat $(CMD_DIR)/$(tb)_cmd)))
$(foreach tb,$(TB),$(eval $(call TB_template,$(tb))))
