#include <stdint.h>

#define SERVICE(name, len, args, rets) \
        char _service[len] = name; \
        ofw_arg.service = _service; \
        ofw_arg.n_args = args; \
        ofw_arg.n_rets = rets;

typedef int32_t phandle;
typedef int32_t ihandle;

void* ofw_interpret(char* cmd, int32_t* stack_args, int n_stack_args, int n_ret_args, int32_t* retaddr);
void get_ofw_32bit(char* word, uint32_t* ret); 
void n_to_hex(uint32_t n, char* ret);
int strlen(char* str);

void memcpy(void* dst, void* src, int n);
