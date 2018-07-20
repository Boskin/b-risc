if [ "$1" != "" ]; then
    vvp "$1.vvp"
    if [[ $* == *-v* ]]; then
        gtkwave "$1.vcd"
    fi
fi
