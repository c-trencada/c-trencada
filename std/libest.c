#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alloca.h>
// #include <pthread.h>

int imprimeix_va(const char* restrict fmt, va_list args) {
    return vprintf(fmt, args);
}
int imprimeix(const char* restrict fmt, ...) {
    va_list args;
    va_start(args, fmt);
    int r = imprimeix_va(fmt, args);
    va_end(args);
    return r;
}
int imprimeix_cadena_va(char* restrict cadena, const char* restrict fmt, va_list args) {
    return vsprintf(cadena, fmt, args);
}
int imprimeix_cadena(char* restrict cadena, const char* restrict fmt, ...) {
    va_list args;
    va_start(args, fmt);
    int r = imprimeix_cadena_va(cadena, fmt, args);
    va_end(args);
    return r;
}

void* assigna_mem(unsigned long mida) { return malloc(mida); }
void* reassigna_mem(void* punter, unsigned long mida) { return realloc(punter, mida); }
void allibera(void* punter) { free(punter); }

void* assigna_mem_auto(unsigned long mida) {
    return alloca(mida);
}

void* copia_mem(void* dest, void* origen, unsigned long size) { return memcpy(dest, origen, size); }
int compara_mem(void* a, void* b, unsigned long size) { return memcmp(a, b, size); }

int compara_cadenes(const char* a, const char* b) { return strcmp(a, b); }
int compara_cadenes_fins(const char* a, const char* b, unsigned long n) { return strncmp(a, b, n); }

int longitud_cadena(const char* c) { return strlen(c); }

void sortir(int codi) { exit(codi); }

// int crea_fil(pthread_t *restrict newthread, const pthread_attr_t *restrict attr, void *(*start_routine)(void *), void *restrict arg) {
//     return pthread_create(newthread, attr, start_routine, arg);
// }


