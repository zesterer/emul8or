#The name of the program
NAME=emul8or

VALAC=valac
VALA_SOURCES=\
\
src/main.vala \
src/application.vala \
src/renderer.vala \
src/emulator.vala \

VALA_PACKAGES=--pkg sdl --pkg sdl-gfx -X -lSDL_gfx -X -I/usr/include/SDL --Xcc=-I/usr/include/SDL -X -lm \

VALA_ADDITIONAL=-X -g
# -X -fsanitize=address

LINES_VALA=`( find src -name '*.vala' -print0 | xargs -0 cat ) | wc -l`

default: build

build: $(VALA_SOURCES)
	@echo "Building..."
	@$(VALAC) -o $(NAME) $(VALA_PACKAGES) $(VALA_ADDITIONAL) $(VALA_SOURCES)
	@echo "Built."
	@echo "Info: There are $(LINES_VALA) lines of Vala code"

install: $(NAME)
	@echo "Adding runnable flag to executable file..."
	@chmod +x $(NAME)
	@echo "Moving to install directory..."
	@sudo mv $(NAME) /usr/bin/$(NAME)
	@echo "Moved."

run: $(NAME)
	@echo "Running..."
	@./$(NAME)

buildrun:
	@make build
	@make run

help:
	@echo "To compile, run 'make build'"
	@echo "To install, run 'sudo make install'"
