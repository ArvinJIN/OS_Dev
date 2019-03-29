#include "asm.h"
#include "memlayout.h"
#include "mmu.h"


.code16
.globl start
start:
    cli

#初始化各个段寄存器
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss

#打开A20使其可寻址的方式大于1M
seta20.1:
    inb $0x64,%al
    testb $0x2,%al
    jnz seta20.1

    movb $0xd1,%al
    outb %al,$0x64

seta20.2:
    inb $0x64,%al
    testb $0x2,%al
    jnz seta20.2

    movb $0xdf,%al
    outb %al,$0x60


#加载GDT
    lgdt gdtdesc
    movl %cr0,%eax
    orl $CR0_PE,%eax
    movl %eax,%cr0


ljmp $(SEG_KCODE<<3),$start32

#切换为32位的汇编语言
.code32
start32:
    movw $(SEG_KDATA<<3),%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0,%ax
    movw %ax,%fs
    movw %ax,%gs

    movl $start,%esp
    call bootmain

    
    movw $0x8a00,%ax
    movw %ax,%dx
    outw %ax,%dx
    movw $0x8ae0,%ax
    outw %ax,%dx
spin:
    jmp spin

.p2align 2
gdt:
    SEG_NULLASM
    SEG_ASM(STA_X|STA_R,0X0,0XFFFFFFFF)
    SEG_ASM(STA_W,0X0,0XFFFFFFFF)

gdtdesc:
    .word (gdtdesc - gdt -1)
    .long gdt
