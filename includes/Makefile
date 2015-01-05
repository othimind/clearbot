CC=g++
CFLAGS=-c -fpic -shared
#LDFLAGS=-llua -lyaml-cpp -lsoci_sqlite3 -lsoci_core -lluabind
#SOURCES=includes/IRC.cpp src/main.cpp
SOURCES=$(wildcard *.cpp)
OBJECTS=$(SOURCES:%.cpp=%.o) 
EXECUTABLE=libircclient.so

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(OBJECTS) -shared -o $@

$(OBJECTS): %.o: %.cpp
	$(CC) $(CFLAGS) $< -o $@

install:
	cp $(EXECUTABLE) /usr/lib64/$(EXECUTABLE)

uninstall:
	rm -f /usr/lib64/$(EXECUTABLE)
clean:
	rm -f *.o $(EXECUTABLE)
