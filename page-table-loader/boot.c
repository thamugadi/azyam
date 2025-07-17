#include <ofw.h>

void __stack_chk_fail_local()
{
}

void (*ofw)();
void __eabi();
void __eabi(void)
{
}
int main(void)
{
  ofw_interpret("blink-screen", 0, 0, 0, 0);
  asm("b $");
}
