#include <ofw.h>

void __stack_chk_fail_local()
{
}
void (*ofw)(void* ofw_arg);
void __eabi();
void __eabi(void)
{
}
void puts(char* str, int len)
{
  char cmd[len + 8];
  cmd[0] = '.';
  cmd[1] = '"';
  cmd[2] = ' ';
  for (int i = 3; i < len + 3; i++)
  {
    cmd[i] = str[i - 3];
  }
  cmd[len + 3] = '"';
  cmd[len + 4] = ' ';
  cmd[len + 5] = 'c';
  cmd[len + 6] = 'r';
  cmd[len + 7] = 0;
  ofw_interpret(cmd, 0, 0, 0, 0);
}

int main(void)
{
  *(uint32_t*)0xdc000000 = 0xabcdabcd; // should raise an exception. TODO
  ofw_interpret("true to use-console?", 0,0,0,0);
  ofw_interpret("false to ignore-output?", 0,0,0,0);
  ofw_interpret("stdout @ 0= if \" screen\" output install-console then", 0,0,0,0);
  ofw_interpret("blink-screen", 0, 0, 0, 0);
  ofw_interpret(".\" hiii from the ELF\" cr", 0,0,0,0);
  while(1);
}
