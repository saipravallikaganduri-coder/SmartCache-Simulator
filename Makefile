CXX      := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -Wpedantic -Wshadow -O2
INCLUDES := -Iinclude
TARGET   := SmartCacheSimulator
SRCDIR   := src
OBJDIR   := build/obj

SOURCES  := $(wildcard $(SRCDIR)/*.cpp)
OBJECTS  := $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/%.o, $(SOURCES))

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $^ -o $@
	@echo "Build successful → ./$(TARGET)"

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp | $(OBJDIR)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

run: all
	./$(TARGET)

clean:
	rm -rf $(OBJDIR) $(TARGET)
