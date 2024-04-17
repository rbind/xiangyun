#include <R.h>

void hello(int *n){
  int i = 1;
  for(i = 0; i < *n; ++i){
    Rprintf("Hello World %d times\n", i);
  }
  *n += 1;
}
