VALAC =		valac
SRC =		simple-gspell
PKGS =		--pkg gtk+-3.0 --pkg gtksourceview-3.0 --pkg gspell-1

all:
	${VALAC} ${VALAC_FLAGS} ${PKGS} ${SRC}.vala

debug:
	${VALAC} ${VALAC_FLAGS} ${PKGS} ${SRC}.vala -D debug

clean:
	@rm -f ${SRC}
