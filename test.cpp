#include <ncurses.h>

const int MAX_ROW = 22;
const int MAX_COL = 79;

int debug_line = 5;

/* Initializes the screen and sets keyboard input options. */
void initialize_gui() {
  initscr();
  cbreak();
  keypad(stdscr, TRUE);
  noecho();
  curs_set(0); /* hide cursor*/
}

void update_pos(char key, int &row, int &col) {
  switch (key) {
    case 'h':
      if (col > 0) col--; break;
    case 'l':
      if (col < MAX_COL) col++; break;
    case 'j':
      if (row < MAX_ROW) row++; break;
    case 'k':
      if (row > 0) row--;
  }
}

int main() {

  int max_row, max_col; /* size of standard screen */
  int row, col;         /* current row and column of rogue */
  int key;              /* key pressed by user */

  initialize_gui();

  /* Place rogue in his initial position. */
  row = 0;
  col = 0;
  mvaddch(row, col, '@');

  /* Move rogue based on user input. */
  while ((key = getch()) != 'q') {
    mvaddch(row, col, ' ');
    update_pos(key, row, col);
    mvaddch(row, col, '@');
    refresh();
  }

  endwin();

  return 0;
}

void println(char *msg) {
  mvprintw(debug_line, 0, msg);
  debug_line++;
}

