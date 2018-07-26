#ifndef LIBUTILS_H
#define LIBUTILS_H

struct path {
  int fd;
  int lines;
  char *path;
};

struct count {
  int result_code;
  int words;
  int lines;
  int characters;
};

struct paths {
  size_t num;
  struct path *paths;
};

void count_lines(struct paths *paths);

#endif
