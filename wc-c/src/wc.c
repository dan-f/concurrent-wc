#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <dirent.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/syslimits.h>

#include "libutils.h"

void print_help() {
  fprintf(stdout, "Must supply 1 argument\n");
}

void print_time_err() {
  fprintf(stderr, "gettimeofday failed: %d: %s\n", errno, strerror(errno));
}

void print_elapsed_time(struct timeval *start, struct timeval *end) {
  uint elapsed_ms = (end->tv_usec - start->tv_usec) / 1000;
  printf("Took %dms\n", elapsed_ms);
}

void path_push(struct paths *p, char *path) {
  char *pc;
  p->num++;
  p->paths = realloc(p->paths, sizeof(struct path) * p->num);

  if (p->paths == NULL) {
    fprintf(stderr, "reallocfailed: %d: %s", errno, strerror(errno));
    exit(errno);
  }

  pc = malloc(strlen(path) + 1);
  if (pc == NULL) {
    fprintf(stderr, "malloc failed: %d: %s", errno, strerror(errno));
    exit(errno);
  }

  strcpy(pc, path);
  p->paths[p->num - 1] = (struct path){0, 0, pc};
}

struct paths *list_dir_paths(char *path) {
  struct stat sb;
  int ret;

  struct paths *paths = calloc(1, sizeof(struct paths));

  ret = stat(path, &sb);
  if (ret) {
    fprintf(stderr, "Error in stat: error %d: %s\n", errno, strerror(errno));
    exit(errno);
  } else if (S_ISDIR(sb.st_mode)) {

    struct dirent *d;
    DIR *dir = opendir(path);
    if (!dir) {
      fprintf(stderr, "Error in opendir: error %d: %s\n", errno, strerror(errno));
      exit(errno);
    }

    char p[PATH_MAX];
    while((d = readdir(dir))) {
      strcpy(p, path);
      strcat(p, d->d_name);

      memset(&sb, 0, sizeof(struct stat));
      ret = stat(p, &sb);

      if (ret) {
        if (errno == ENOENT) {
          // directory
        } else {
          fprintf(stderr, "Cannot stat path: error %d: %s\n", errno, strerror(errno));
          exit(errno);
        }
      } else {
        if (S_ISREG(sb.st_mode)) {
          path_push(paths, p);
        }
      }
    }

    closedir(dir);

  } else if (S_ISREG(sb.st_mode)) {
    path_push(paths, path);
  }

  return paths;
}

int main(int argc, char *argv[]) {
  size_t i;
  int err;
  struct timeval start_time, end_time;
  err = gettimeofday(&start_time, NULL);
  if (err) {
    print_time_err();
    exit(1);
  }
  struct paths *path_listing;
  if (argc != 2) {
    print_help();
    exit(1);
  } else {
    path_listing = list_dir_paths(argv[1]);

    count_lines(path_listing);
    for (i = 0; i < path_listing->num; i++) {
      free(path_listing->paths[i].path);
    }
    free(path_listing->paths);
    free(path_listing);
  }

  err = gettimeofday(&end_time, NULL);
  if (err) {
    print_time_err();
    exit(1);
  }
  print_elapsed_time(&start_time, &end_time);

  return 0;
}
