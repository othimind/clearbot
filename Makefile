CC=clang++
CFLAGS=-Wall -c  #-std=c++11 
LDFLAGS=-llua -lyaml-cpp  -lsoci_sqlite3 -lsoci_core -lluabind -L./includes -lircclient
#SOURCES=includes/IRC.cpp src/main.cpp
SOURCES=$(wildcard src/*.cpp)
OBJECTS=$(SOURCES:%.cpp=%.o) 
DIRS=includes
CLEANDIRS=$(DIRS:%=clean-%)
EXECUTABLE=clearbot
all: $(DIRS) $(EXECUTABLE)

.PHONY: subdirs $(DIRS)
.PHONY: subdirs $(CLEANDIR)
#subdirs: $(DIRS)
$(DIRS):
	$(MAKE) -C $@

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)

$(OBJECTS): %.o: %.cpp
	$(CC) $(CFLAGS) $< -o $@

clean: $(CLEANDIRS) cleanmain
$(CLEANDIRS):
	$(MAKE) -C $(@:clean-%=%) clean
cleanmain:
	rm -f $(EXECUTABLE) src/*.o
#	$(MAKE) -C includes clean
.PHONY: subdirs $(CLEANDIRS)
