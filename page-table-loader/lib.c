#include <ofw.h>
void n_to_hex(uint32_t n, char* ret)
{
  char hex[] = "0123456789abcdef";
  ret[8] = 0;
  for (int i = 7; i >= 0; i--)
  {
    ret[i] = hex[n & 0b1111];
    n >>= 4;
  }
}
void memcpy(void* dst, void* src, int n)
{
  char* dst_c = dst;
  char* src_c = src;
  for (int i = 0; i < n; i++)
  {
    dst_c[i] = src_c[i];
  }
}
int strlen(char* str)
{
  int n = 0;
  while (*str++)
  {
    n++;
  }
  return n; 
}
