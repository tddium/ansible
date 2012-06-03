#include <stdio.h>
#include <malloc.h>
#include <stdbool.h>
#include <ruby.h>
#include <ruby/encoding.h>


#define SPAN_OPEN               "<span class='"
#define SPAN_OPEN_END           "'>"
#define SPAN_START(class)       SPAN_OPEN #class SPAN_OPEN_END
#define SPAN_CLOSE              "</span>"
#define CODE_BUF_SIZE           255
#define MAX_SPAN_SIZE           255

#ifdef DEBUG
#define DBG(...)                fprintf(stderr, __VA_ARGS__)
#else
#define DBG(...)                
#endif

int count_escapes(const char *s, size_t len)
{
    size_t in_pos;
    int num_escapes = 0;
    for (in_pos = 0; in_pos < len; in_pos++) {
        char c = s[in_pos];
        num_escapes += c == '\033' ? 1 : 0;
    }
    return num_escapes;
}

/*
 * Write into the scratch buffer, and realloc if necessary.
 * 
 * Raises a ruby out of memory exception if alloc fails
 */
void write_scratch(char *str, size_t len, char **scratch, size_t *scratch_pos, size_t *scratchLen)
{
   DBG("scratch: '%s' pos: %d\n", *scratch, *scratch_pos);
   if (*scratch_pos + len >= *scratchLen) {
       size_t newscratchLen = *scratchLen + len + 5000;
       char *newscratch = realloc(*scratch, newscratchLen);
       if (newscratch == NULL) {
           rb_raise(rb_eNoMemError, "could not allocate memory for translation");
       }

       *scratch = newscratch;
       *scratchLen = newscratchLen;
   }

   strncpy(*scratch+*scratch_pos, str, len);
   *scratch_pos += len;
}

void make_span(char *code, char *span, size_t *span_len)
{
    char *ptr = NULL;

    *span_len = 0;

    // insert a close span
    strncpy(span, SPAN_CLOSE, MAX_SPAN_SIZE);
    *span_len += sizeof(SPAN_CLOSE) - 1;
    ptr = span + *span_len;

    if (code[0] != '[') {
        size_t len = sizeof(SPAN_START(ansible_unknown))-1;
        strncpy(ptr, SPAN_START(ansible_unknown), MAX_SPAN_SIZE - *span_len);
        *span_len += len;
        ptr = span + *span_len;

        return;
    }

    code = code + 1;

    // Handle the none code
    if (!strcmp(code, "0") ||
        !strcmp(code, "")) {
        size_t len = sizeof(SPAN_START(ansible_none))-1;
        strncpy(ptr, SPAN_START(ansible_none), MAX_SPAN_SIZE - *span_len);
        *span_len += len;
        ptr = span + *span_len;
    } else {
        char *saveptr;
        char *token = NULL, *str = NULL;
        bool first = true;

        strncpy(ptr, SPAN_OPEN, MAX_SPAN_SIZE - *span_len);
        *span_len += sizeof(SPAN_OPEN) - 1;
        ptr = span + *span_len;

        for (str = code; ; str = NULL) {
            token = strtok_r(str, ";", &saveptr);
            if (token == NULL) {
                break;
            }

            // Skip 0s mixed with other codes
            if (!strcmp(token, "0")) {
                continue;
            }

            if (!first) {
                size_t len = snprintf(ptr, MAX_SPAN_SIZE - *span_len, " ");
                *span_len += len;
                ptr = span + *span_len;
            }


            size_t len = snprintf(ptr, MAX_SPAN_SIZE - *span_len, "ansible_%s", token);
            *span_len += len;
            ptr = span + *span_len;
            first = false;
        }

        strncpy(ptr, SPAN_OPEN_END, MAX_SPAN_SIZE - *span_len);
        *span_len += sizeof(SPAN_OPEN_END) - 1;
        ptr = span + *span_len;
    }
}

/*
 * Find or construct a span tag for this code.
 * Write it into the scratch buffer.
 */
void write_span(char *code, char **scratch, size_t *scratch_pos, size_t *scratchLen)
{
    size_t span_len = 0;
    char span[MAX_SPAN_SIZE];

    make_span(code, span, &span_len);

    write_scratch(span, span_len, scratch, scratch_pos, scratchLen);
}

/* 
 * escape_to_html
 */
VALUE escape_to_html(VALUE self, VALUE rawdata)
{
    VALUE result;

    if (rawdata == Qnil) {
        return rb_str_new2("");
    }

    if (TYPE(rawdata) != T_STRING) {
        rb_raise(rb_eTypeError, "invalid type for rawdata");
        return Qnil;
    }

    char *dataStr = StringValueCStr(rawdata);
    size_t dataStrLen = strlen(dataStr);
    char code[CODE_BUF_SIZE];
    bool inCode = false;
    size_t in_pos = 0, scratch_pos = 0, code_pos = 0;

    /*
     * Pre alloc scratch space that's at least as big as the input string, plus
     * some space for inserted span elements.
     *
     * Every string gets wrapped in a <span class="ansible_none"></span>
     *
     * Assume that every new escape code that's encountered will produce open
     * and close span tags that together consume 100 bytes (this allows for 3-5
     * codes per span, which is generous).  This should be good enough for
     * pretty much everything.  If it's not, we'll still notice when we run out
     * of space and try to realloc.
     */
    int spans = 1 + count_escapes(dataStr, dataStrLen);
    size_t scratchLen = dataStrLen + (spans * MAX_SPAN_SIZE);
    char *scratch = malloc(scratchLen);
    memset(scratch, 0, scratchLen);

    write_scratch((char *)SPAN_START(ansible_none),
            sizeof(SPAN_START(ansible_none))-1, &scratch, &scratch_pos,
            &scratchLen);


    for (; in_pos < dataStrLen; in_pos++) {
        char c = dataStr[in_pos];

        /*
         * Copy characters into scratch that arent within an escape code block.
         */
        if (c == '\033') {          // Enter escape code on ^[
            inCode = true;
            code_pos = 0;
        } else if (c == 'm') { 
            if (inCode) {           // Exit escape code on m
                inCode = false;
                code[code_pos] = 0;
                DBG("code: %s\n", code);
                write_span(code, &scratch, &scratch_pos, &scratchLen);
            } else {                // Copy an m that's not terminating an escape code
                write_scratch(&c, 1, &scratch, &scratch_pos, &scratchLen);
            }
        } else if (!inCode) {       // Copy everything else
            write_scratch(&c, 1, &scratch, &scratch_pos, &scratchLen);
        } else {                    // fill code buffer
           if (code_pos < sizeof(code)) {
              code[code_pos++] = c;
           }
        } 
    }

    write_scratch((char *)SPAN_CLOSE, sizeof(SPAN_CLOSE)-1, &scratch, &scratch_pos, &scratchLen);

    result = rb_enc_str_new(scratch, scratch_pos, rb_enc_find("BINARY"));
    free(scratch);

    return result;
}

VALUE an_mAnsible, an_cConverter;

void Init_ansible()
{
    an_mAnsible = rb_define_module("Ansible");
    an_cConverter = rb_define_class_under(an_mAnsible, "Converter", rb_cObject);

    rb_define_method(an_cConverter, "escape_to_html", escape_to_html, 1);
}
