#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/types.h>
#include <limits.h>
#include <pthread.h>

#include "libutils.h"
#include "wq.h"


#define NUM_THREADS 16
#define BUF_SIZE 5096

size_t files_counted = 0;

pthread_t threads[NUM_THREADS];
wq_t work_queue;
pthread_mutex_t mut = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;

struct paths *paths;
int total_lines;

void increment_file_count() {
  pthread_mutex_lock(work_queue.mut);
  files_counted++;

  if (files_counted == paths->num) {
    work_queue.finished = true;
    pthread_cond_broadcast(work_queue.cond);
  }
  pthread_mutex_unlock(work_queue.mut);
}

void count_lines_in_file(struct path *path) {
  FILE *f;
  size_t ret;
  size_t i;
  char b[BUF_SIZE];
  size_t lines = 0;

  f = fopen(path->path, "r");
  if (!f) {
    printf("Error opening file: %s\n", path->path);
    increment_file_count();
    return;
  }

  do {
    ret = fread(b, 1, BUF_SIZE, f);
    for (i = 0; i < ret; i++) {
      if (b[i] == 10) {
        lines++;
      }
    }
  } while (ret == BUF_SIZE);

  path->lines += lines;

  increment_file_count();

  fclose(f);
}

void *wait_and_exec(void *arg) {
  struct path *path;
  void (*counter)(struct path*) = arg;

  while (files_counted < paths->num) {
    path = wq_pop(&work_queue);
    if (path) {
      counter(path);
    }
  }

  pthread_mutex_lock(work_queue.mut);
  pthread_cond_broadcast(work_queue.cond);
  pthread_mutex_unlock(work_queue.mut);

  pthread_exit(0);
}

void init_thread_pool(void (*counter)(char*)) {
  int ret;
  size_t i;
  wq_init(&work_queue, &mut, &cond);

  for (i = 0; i < NUM_THREADS; i++) {
    ret = pthread_create(&threads[i], NULL, &wait_and_exec, counter);
    if (ret) {
      fprintf(stderr, "Failed to create a thread: error %d: %s\n", errno, strerror(errno));
      exit(errno);
    }
  }
}

static int path_comparison(const void *a, const void *b){
  const struct path *p1 = a;
  const struct path *p2 = b;
  return p1->lines < p2->lines;
}

void count_lines(struct paths *p) {
  size_t i;
  paths = p;

  total_lines = 0;

  init_thread_pool((void *)(count_lines_in_file));

  for (i = 0; i < paths->num; i++) {
    wq_push(&work_queue, &paths->paths[i]);
  }

  for (i = 0; i < NUM_THREADS; i++) {
    pthread_join(threads[i], NULL);
  }

  qsort(paths->paths, paths->num, sizeof(struct path), path_comparison);

  for (i = 0; i < paths->num; i++) {
    fprintf(stdout, "%10d %s\n", paths->paths[i].lines, paths->paths[i].path);
    total_lines += paths->paths[i].lines;

  }

  fprintf(stdout, "%10d [TOTAL]\n", total_lines);

  return;
}
