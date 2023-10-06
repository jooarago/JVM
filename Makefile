#==========================
#|       VARIABLES        |
#==========================
TARGET=jvm

CC=gcc

CFLAGS=-W
CFLAGS+=-Wall
CFLAGS+=-ansi
CFLAGS+=-pedantic
CFLAGS+=-std=c99

SRC_DIR=src
OBJ_DIR=obj

SRCS = $(shell find $(SRC_DIR) -name '*.c')
OBJS=$(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

LIB_SRCS = $(shell find $(SRC_DIR)/lib -name '*.c')
LIB_OBJS=$(LIB_SRCS:.c=.o)

TEST_SRCS=$(wildcard test/**/*.c)
TEST_SRCS+=$(wildcard test/*.c)
TEST_OBJS=$(TEST_SRCS:.c=.o)

#==========================
#           MAIN          |
#==========================
all: $(TARGET)

#==========================
#        BUILDING         |
#==========================
$(TARGET): $(OBJS)
	@echo "...Building JVM project..."
	@mkdir -p bin
	@$(CC) -o bin/$@ $^ $(CFLAGS) -O3
	@echo "...Successfully Compiled..."

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -o $@ -c $<

#==========================
#|        RUN JVM         |
#==========================
run:
	./bin/$(TARGET)

#==========================
#|       ANALYZERS        |
#==========================
asan: $(OBJS)
	@echo "...Running Address Santizer..."
	@$(CC) -o bin/$@ $^ $(CFLAGS) -fsanitize=address
	@mkdir -p bin
	@./bin/$@
	@rm bin/$@

ubsan: $(OBJS)
	@echo "...Running Undefined Behavior Santizer..."
	@$(CC) -o $@ $^ $(CFLAGS) -fsanitize=undefined
	@mkdir -p bin
	@./bin/$@
	@rm bin/$@

cppcheck-src:
	@echo "...Running CPP Check in src..."
	@cppcheck src

cppcheck-test:
	@echo "...Running CPP Check in test..."
	@cppcheck --suppress=preprocessorErrorDirective --suppress=toomanyconfigs test

cppcheck: cppcheck-src cppcheck-test

#==========================
#|       UNIT TESTS       |
#==========================

test_target: $(TEST_SRCS) $(LIB_SRCS)
	@echo "------------------------"
	@echo "< Testing JVM Project  >"
	@echo "------------------------"
	@$(CC) -o bin/$@ $^ $(CFLAGS) -Isrc
	@mkdir -p bin
	@./bin/$@
	@rm bin/$@

test: test_target

#==========================
#      CLEAN PROJECT      |
#==========================
clean:
	@rm -rf $(TARGET) $(OBJS)
mrproper: clean
	@rm -rf $(EXEC)
