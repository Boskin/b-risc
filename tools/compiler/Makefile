EXECUTABLE := compiler

OBJS := main.o instruction.o r_instruction.o i_instruction.o

all: $(EXECUTABLE)

clean:
	rm -rf *.o

$(EXECUTABLE): $(OBJS)
	g++ -Wall -std=c++11 -o $(EXECUTABLE) $(OBJS)

main.o: main.cpp
	g++ -c -Wall -std=c++11 -o main.o main.cpp

instruction.o: instruction.cpp instruction.hpp
	g++ -c -Wall -std=c++11 -o instruction.o instruction.cpp

r_instruction.o: r_instruction.cpp r_instruction.hpp instruction.cpp instruction.hpp
	g++ -c -Wall -std=c++11 -o r_instruction.o r_instruction.cpp

i_instruction.o: i_instruction.cpp i_instruction.hpp instruction.cpp instruction.hpp
	g++ -c -Wall -std=c++11 -o i_instruction.o i_instruction.cpp
