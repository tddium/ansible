#include <ruby.h>
#include <stdio.h>
#include <malloc.h>
#include <stdbool.h>

/* 
 * escape_to_html
 *
 * XXX For now, just strips all ansi escape codes
 */
VALUE escape_to_html(VALUE self, VALUE rawdata)
{
    VALUE result;

    char *dataStr = StringValueCStr(rawdata);
    size_t dataStrLen = strlen(dataStr);
    char *scratch = malloc(dataStrLen);
    bool inCode = false;
    int in_pos, scratch_pos;

    for (in_pos = 0, scratch_pos = 0; in_pos < (int)dataStrLen; in_pos++) {
        char c = dataStr[in_pos];
        if (c == '\033') {
            inCode = true;
        } else if (c == 'm') {
            if (inCode) {
                inCode = false;
            } else {
                scratch[scratch_pos++] = c;
            }
        } else if (!inCode) {
            scratch[scratch_pos++] = c;
        }
    }

    result = rb_str_new(scratch, scratch_pos);
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
