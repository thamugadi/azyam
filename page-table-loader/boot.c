#include <ofw.h>

void __stack_chk_fail_local()
{
}

void (*ofw)(void* ofw_arg);
void __eabi();
void __eabi(void)
{
}
int main(void)
{
  uint32_t addr;
  get_ofw_32bit("main-memory-paddr", &addr);
  ofw_interpret("blink-screen", 0, 0, 0, 0);
  static char cmd[0x100];
  n_to_hex(addr, cmd);
  cmd[8] = 0;
  ofw_interpret(cmd, 0, 0, 0, 0);

  ofw_interpret("true to use-console?", 0,0,0,0);
  ofw_interpret("false to ignore-output?", 0,0,0,0);
  ofw_interpret("stdout @ 0= if \" screen\" output install-console then", 0,0,0,0);
  ofw_interpret("\"hiii from the ELF\" type", 0,0,0,0);
  while(1);
}
/*

true to use-console?
false to ignore-output?
stdout @ 0= if
" screen" output
install-console
then
*/
