if [ "$1" != "" ]; then
	vvp "$1.vvp"
	gtkwave "$1.vcd"
fi
