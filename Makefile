# ------------------------------------------------------------------------------
RESET = \033[0m
make_std_color = \033[3$1m
make_color  = \033[38;5;$1m
ERR_COLOR = $(strip $(call make_std_color,1))
WRN_COLOR = $(strip $(call make_std_color,3))
NFO_COLOR = $(strip $(call make_std_color,4))
STD_COLOR = $(strip $(call make_color,8))
COLOR_OUTPUT = 2>&1 |                                   \
    while IFS='' read -r line; do                       \
        if  [[ $$line == *ERROR:* ]]; then         		\
            echo -e "$(ERR_COLOR)$${line}$(RESET)";     \
        elif [[ $$line == *WARNING:* ]]; then           \
            echo -e "$(WRN_COLOR)$${line}$(RESET)";     \
        elif [[ $$line == *INFO:* ]]; then              \
            echo -e "$(NFO_COLOR)$${line}$(RESET)";     \
        else                                            \
            echo -e "$(STD_COLOR)$${line}$(RESET)";     \
        fi;                                             \
    done; exit $${PIPESTATUS[0]};
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

all: check build program vio_gui

.PHONY: all check build program vio_gui

check:
	@type vivado >& /dev/null || (echo "'vivado' executable not found"; exit 1)

build:
	vivado -nojournal -nolog -mode batch -source ./scripts/build.tcl $(COLOR_OUTPUT)

program:
	vivado -nojournal -nolog -mode batch -source ./scripts/program.tcl $(COLOR_OUTPUT)

vio_gui:
	vivado -nojournal -nolog -mode gui -source ./scripts/vio_gui.tcl $(COLOR_OUTPUT)

clean:
	rm build/ .Xil/ work/ vivado* -rf
