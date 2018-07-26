#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include "wq.h"
#include "utlist.h"

void wq_init(wq_t *wq, pthread_mutex_t *mut, pthread_cond_t *cond) {
  wq->size = 0;
  wq->head = NULL;
  wq->mut = mut;
  wq->cond = cond;
  wq->finished = false;
}

struct path *wq_pop(wq_t *wq) {
  pthread_mutex_lock(wq->mut);

  while (wq->size == 0 && !wq->finished) {
    pthread_cond_wait(wq->cond, wq->mut);
  }

  if (wq->finished) {
    pthread_mutex_unlock(wq->mut);
    return NULL;
  }

  wq_item_t *wq_item = wq->head;
  struct path *path = wq->head->path;
  wq->size--;
  DL_DELETE(wq->head, wq->head);
  pthread_mutex_unlock(wq->mut);

  free(wq_item);
  return path;
}

void wq_push(wq_t *wq, struct path *path) {
  pthread_mutex_lock(wq->mut);

  wq_item_t *wq_item = calloc(1, sizeof(wq_item_t));
  wq_item->path = path;
  DL_APPEND(wq->head, wq_item);
  wq->size++;

  pthread_cond_broadcast(wq->cond);
  pthread_mutex_unlock(wq->mut);
}
