TB := $(basename $(notdir $(wildcard tb/*.v)))
TB_VVP := $(addsuffix .vvp,$(TB))

VERILOG_GEN := -g2005

CMD_DIR := cmd

.PHONY: all clean

all: $(TB_VVP)

clean:
	rm -rf *.vvp
	rm -rf *.vcd

define TB_template =
$(1).vvp: $$($(CMD_DIR)/$(1)_cmd)
	@echo Building $(1).vvp
	@iverilog -c $(CMD_DIR)/$(1)_cmd $(VERILOG_GEN) -I config_headers -o $(1).vvp
endef

# Use eval to create new make targets
$(foreach tb,$(TB),$(eval $(CMD_DIR)/$(tb)_cmd := $(shell cat $(CMD_DIR)/$(tb)_cmd)))
$(foreach tb,$(TB),$(eval $(call TB_template,$(tb))))
