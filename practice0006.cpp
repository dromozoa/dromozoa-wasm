#include <unistd.h>

int main(int argc, char* []) {
  switch (argc) {
    case 0: write(1, "0\n", 2); break;
    case 1: write(1, "1\n", 2); break;
    case 2: write(1, "2\n", 2); break;
    case 3: write(1, "3\n", 2); break;
    case 4: write(1, "4\n", 2); break;
    case 5: write(1, "5\n", 2); break;
    case 6: write(1, "6\n", 2); break;
    default:
      write(1, "d\n", 2);
  }
  return 0;
}
