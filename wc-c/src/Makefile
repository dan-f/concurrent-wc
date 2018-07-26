LIBS = -pthread
CC = gcc
CFLAGS = -O3 -std=gnu11 -Wall -Wextra -Werror -Werror-implicit-function-declaration
SOURCES=wc.c libutils.c wq.c
EXECUTABLE=wc-c

C_BIN = ../../bin/wc-c

default: $(SOURCES) $(C_BIN)
all: default

OBJECTS = $(patsubst %.c, %.o, $(wildcard *.c))
HEADERS = $(wildcard *.h)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

$(C_BIN): $(OBJECTS)
	$(CC) $(OBJECTS) $(LIBS) -o $(addprefix $(BUILD_DIR), $@)

clean:
	rm -f *.o $(EXECUTABLE)
