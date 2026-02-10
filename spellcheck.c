#include "c_trencada.h"
#include <curl/curl.h>
#include "cJSON.h"

typedef struct string string;
struct string {
  char *ptr;
  size_t len;
};

static void init_string(string *s) {
  s->len = 0;
  s->ptr = malloc(s->len+1);
  if (s->ptr == NULL) {
    fprintf(stderr, "malloc() ha fallat\n");
    exit(EXIT_FAILURE);
  }
  s->ptr[0] = '\0';
}

static void append_string(string *s, const char *t) {
  size_t t_len = strlen(t);
  size_t new_len = s->len + t_len;
  s->ptr = realloc(s->ptr, new_len+1);
  if (s->ptr == NULL) {
    fprintf(stderr, "realloc() ha fallat\n");
    exit(EXIT_FAILURE);
  }
  memcpy(s->ptr+s->len, t, t_len);
  s->ptr[new_len] = '\0';
  s->len = new_len;
}

static size_t writefunc(void *ptr, size_t size, size_t nmemb, string *s) {
  size_t new_len = s->len + size*nmemb;
  s->ptr = realloc(s->ptr, new_len+1);
  if (s->ptr == NULL) {
    fprintf(stderr, "realloc() ha fallat\n");
    exit(EXIT_FAILURE);
  }
  memcpy(s->ptr+s->len, ptr, size*nmemb);
  s->ptr[new_len] = '\0';
  s->len = new_len;

  return size*nmemb;
}

void languagetool_check_tok(Token* _tok, bool comment) {
  if (opt_traidor) {
    return;
  }

  string s;
  init_string(&s);

  Token tok = *_tok;

  // Replace underscores with spaces for better checking
  if (tok.loc[0] == '_' && !comment) {
    tok.loc++;
    tok.len--;
  }

  char* name = malloc(tok.len + 1);
  for (int i = 0; i < tok.len; i++) {
    if (tok.loc[i] == '_' && !comment) {
      name[i] = ' ';
    } else {
      name[i] = tok.loc[i];
    }
  }
  name[tok.len] = '\0';

  char* args = "language=ca-ES&text=%s";
  if (!comment) {
    args = "language=ca-ES&disabledRules=PUNT_EN_ABREVIATURES,UPPERCASE_SENTENCE_START&text=%s";
  }

  char* post_fields;
  int len = snprintf(NULL, 0, args, name);
  post_fields = malloc(len + 1);
  snprintf(post_fields, len + 1, args, name);

  curl_easy_setopt(curl, CURLOPT_URL, "http://localhost:8081/v2/check");
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post_fields);
  curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writefunc);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &s);
  CURLcode res = curl_easy_perform(curl);

  if(res != CURLE_OK) {
    fprintf(stderr, "No s'ha pogut executar el corrector: \"%s\"\n", curl_easy_strerror(res));
    exit(1);
  }
  else {
    cJSON *json = cJSON_Parse(s.ptr);
    cJSON *matches = cJSON_GetObjectItemCaseSensitive(json, "matches");
    int match_count = cJSON_GetArraySize(matches);
    for (int i = 0; i < match_count; i++) {
    // if (match_count > 0) {
      cJSON *first_match = cJSON_GetArrayItem(matches, i);
      cJSON *message = cJSON_GetObjectItemCaseSensitive(first_match, "message");
      cJSON *offset = cJSON_GetObjectItemCaseSensitive(first_match, "offset");
      cJSON *length = cJSON_GetObjectItemCaseSensitive(first_match, "length");


      string suggestion_str;
      init_string(&suggestion_str);
      cJSON *replacements = cJSON_GetObjectItemCaseSensitive(first_match, "replacements");
      int repl_count = cJSON_GetArraySize(replacements);
      if (repl_count > 0) {
        if (repl_count > 5) {
          repl_count = 5;
        }
        append_string(&suggestion_str, " (");
        for (int j = 0; j < repl_count; j++) {
          cJSON *replacement = cJSON_GetArrayItem(replacements, j);
          cJSON *value = cJSON_GetObjectItemCaseSensitive(replacement, "value");
          append_string(&suggestion_str, value->valuestring);
          if (j != repl_count - 1) {
            append_string(&suggestion_str, ", ");
          }
        }
        append_string(&suggestion_str, ")");
      }


      // Token err_tok = *tok;
      char *warn_start = tok.loc + utf8_length_to_bytes(tok.loc, offset->valueint);
      int warn_len = utf8_length_to_bytes(warn_start, length->valueint);

      Token new_tok = tok;
      new_tok.loc = warn_start;
      new_tok.len = warn_len;
      warn_tok(&new_tok, "%s%s", message->valuestring, suggestion_str.ptr);
      // warn_at(warn_start, warn_len, "%s%s", message->valuestring, suggestion_str.ptr);
    }
    cJSON_Delete(json);
  }

  free(s.ptr);
}
