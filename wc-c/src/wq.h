#ifndef __WQ__
#define __WQ__

#include <pthread.h>

typedef struct wq_item {
  struct path *path;
  struct wq_item *next;
  struct wq_item *prev;
} wq_item_t;

typedef struct wq {
  size_t size;
  wq_item_t *head;
  pthread_mutex_t *mut;
  pthread_cond_t *cond;
  bool finished;
} wq_t;

void wq_init(wq_t *wq, pthread_mutex_t *mut, pthread_cond_t *cond);
void wq_push(wq_t *wq, struct path *path);
struct path *wq_pop(wq_t *wq);
void wq_cleanup(wq_t *wq);

#endif
