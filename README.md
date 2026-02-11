# Ç — Llenguatge de Programació en Català

Ç és un llenguatge de programació dissenyat íntegrament en català.

El seu objectiu és facilitar l’aprenentatge de la programació en entorns catalanoparlants, mantenint coherència lingüística i qualitat ortogràfica.

## Característiques principals

Actualment, és un compilador de C amb totes les paraules clau traduïdes al català, i amb un corrector ortogràfic per als comentaris i noms de variables. El compilador està basat en [chibicc](https://github.com/rui314/chibicc/).

## Exemple bàsic

```ç
#inclou <est.cç>

ent principal() {
    imprimeix("Hola mon!\n");
    retorna 0;
}
```

## Paraules clau

Algunes de les paraules clau del llenguatge:

- `return` -> `retorna`
- `if` -> `si`
- `else` -> `si_no`
- `for` -> `per`
- `while` -> `mentre`
- `sizeof` -> `mida_de`
- `goto` -> `ves_a`
- `break` -> `para`
- `continue` -> `continua`
- `switch` -> `selecciona`
- `case` -> `cas`
- `default` -> `per_defecte`
- `__attribute__` -> `__atribut__`
- `asm` -> `asm`
- `void` -> `buit`
- `_Bool` -> `_Bool`
- `char` -> `car`
- `short` -> `curt`
- `int` -> `ent`
- `long` -> `llarg`
- `struct` -> `estructura`
- `union` -> `unió`
- `typedef` -> `def_tipus`
- `enum` -> `enum`
- `static` -> `estàtic`
- `extern` -> `extern`
- `_Alignas` -> `_Alinea_com`
- `_Alignof` -> `_Alineació_de`
- `signed` -> `amb_signe`
- `unsigned` -> `sense_signe`
- `const` -> `const`
- `volatile` -> `volàtil`
- `auto` -> `auto`
- `register` -> `registre`
- `restrict` -> `restringeix`
- `__restrict` -> `__restringeix`
- `__restrict__` -> `__restringeix__`
- `_Noreturn` -> `_No_retorna`
- `float` -> `flot`
- `double` -> `doble`
- `typeof` -> `tipus_de`
- `inline` -> `en_línia`
- `_Thread_local` -> `_Local_a_fil`
- `__thread` -> `__fil`
- `_Atomic` -> `_Atòmic`
- `_Generic` -> `_Genèric`

- `#if` -> `#si`
- `#ifdef` -> `#si_def`
- `#ifndef` -> `#si_no_def`
- `#else` -> `#si_no`
- `#elif` -> `#si_sino`
- `#endif` -> `#acaba_si`
- `#define` -> `#defineix`
- `#undef` -> `#elimina_def`
- `#include` -> `#inclou`
- `#error` -> `#error`
- `#pragma` -> `#pragma`
- `once` -> `una_vegada`

- `__builtin_atomic_exchange` -> `__predefinit_intercanviar_atòmic`
- `__builtin_atomic_compare_and_swap` -> `__predefinit_comparar_i_intercanviar_atòmic`
- `__builtin_reg_class` -> `__predefinit_classe_de_registre`
- `__builtin_types_compatible_p` -> `__predefinit_tipus_compatibles`



## Corrector ortogràfic

Ç incorpora un sistema de validació lingüística que:

Revisa comentaris

Revisa noms de variables i funcions

I emet avisos en cas de faltes d'ortografia

```ç
test.ç:3.5-15: Avís: Possible error ortogràfic. (principal)
ent priincipal() {
    ^~~~~~~~~~
```

## Instal·lació

```git clone https://github.com/c-trencada/c-trencada && cd c-trencada```

```make```

Perquè funcioni el compilador ha d'estar instal·lat `languagetool` i el procés s'ha d'encendre amb `languagetool --http`

## Objectius del projecte

Fomentar la programació en català

Crear eines tecnològiques lingüísticament coherents

Normalitzar l’ús del català en entorns tècnics

## Contribucions

Les contribucions són benvingudes!

Si vols participar:

Fes un fork del repositori

Crea una branca (nova-funcio)

Fes commit dels canvis

Obre una pull request

## Llicència

Aquest projecte està sota llicència MIT.
