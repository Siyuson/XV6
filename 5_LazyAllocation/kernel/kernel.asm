
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	83010113          	addi	sp,sp,-2000 # 80009830 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	cc478793          	addi	a5,a5,-828 # 80005d20 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e1878793          	addi	a5,a5,-488 # 80000ebe <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b04080e7          	jalr	-1276(ra) # 80000c10 <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	4b4080e7          	jalr	1204(ra) # 800025da <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	7aa080e7          	jalr	1962(ra) # 800008e0 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	b76080e7          	jalr	-1162(ra) # 80000cc4 <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7119                	addi	sp,sp,-128
    80000170:	fc86                	sd	ra,120(sp)
    80000172:	f8a2                	sd	s0,112(sp)
    80000174:	f4a6                	sd	s1,104(sp)
    80000176:	f0ca                	sd	s2,96(sp)
    80000178:	ecce                	sd	s3,88(sp)
    8000017a:	e8d2                	sd	s4,80(sp)
    8000017c:	e4d6                	sd	s5,72(sp)
    8000017e:	e0da                	sd	s6,64(sp)
    80000180:	fc5e                	sd	s7,56(sp)
    80000182:	f862                	sd	s8,48(sp)
    80000184:	f466                	sd	s9,40(sp)
    80000186:	f06a                	sd	s10,32(sp)
    80000188:	ec6e                	sd	s11,24(sp)
    8000018a:	0100                	addi	s0,sp,128
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8aae                	mv	s5,a1
    80000190:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	a72080e7          	jalr	-1422(ra) # 80000c10 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	89a6                	mv	s3,s1
    800001b0:	00011917          	auipc	s2,0x11
    800001b4:	71890913          	addi	s2,s2,1816 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ba:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001bc:	4da9                	li	s11,10
  while(n > 0){
    800001be:	07405863          	blez	s4,8000022e <consoleread+0xc0>
    while(cons.r == cons.w){
    800001c2:	0984a783          	lw	a5,152(s1)
    800001c6:	09c4a703          	lw	a4,156(s1)
    800001ca:	02f71463          	bne	a4,a5,800001f2 <consoleread+0x84>
      if(myproc()->killed){
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	944080e7          	jalr	-1724(ra) # 80001b12 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	144080e7          	jalr	324(ra) # 80002322 <sleep>
    while(cons.r == cons.w){
    800001e6:	0984a783          	lw	a5,152(s1)
    800001ea:	09c4a703          	lw	a4,156(s1)
    800001ee:	fef700e3          	beq	a4,a5,800001ce <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f2:	0017871b          	addiw	a4,a5,1
    800001f6:	08e4ac23          	sw	a4,152(s1)
    800001fa:	07f7f713          	andi	a4,a5,127
    800001fe:	9726                	add	a4,a4,s1
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000208:	079c0663          	beq	s8,s9,80000274 <consoleread+0x106>
    cbuf = c;
    8000020c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	f8f40613          	addi	a2,s0,-113
    80000216:	85d6                	mv	a1,s5
    80000218:	855a                	mv	a0,s6
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	36a080e7          	jalr	874(ra) # 80002584 <either_copyout>
    80000222:	01a50663          	beq	a0,s10,8000022e <consoleread+0xc0>
    dst++;
    80000226:	0a85                	addi	s5,s5,1
    --n;
    80000228:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022a:	f9bc1ae3          	bne	s8,s11,800001be <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022e:	00011517          	auipc	a0,0x11
    80000232:	60250513          	addi	a0,a0,1538 # 80011830 <cons>
    80000236:	00001097          	auipc	ra,0x1
    8000023a:	a8e080e7          	jalr	-1394(ra) # 80000cc4 <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	a78080e7          	jalr	-1416(ra) # 80000cc4 <release>
        return -1;
    80000254:	557d                	li	a0,-1
}
    80000256:	70e6                	ld	ra,120(sp)
    80000258:	7446                	ld	s0,112(sp)
    8000025a:	74a6                	ld	s1,104(sp)
    8000025c:	7906                	ld	s2,96(sp)
    8000025e:	69e6                	ld	s3,88(sp)
    80000260:	6a46                	ld	s4,80(sp)
    80000262:	6aa6                	ld	s5,72(sp)
    80000264:	6b06                	ld	s6,64(sp)
    80000266:	7be2                	ld	s7,56(sp)
    80000268:	7c42                	ld	s8,48(sp)
    8000026a:	7ca2                	ld	s9,40(sp)
    8000026c:	7d02                	ld	s10,32(sp)
    8000026e:	6de2                	ld	s11,24(sp)
    80000270:	6109                	addi	sp,sp,128
    80000272:	8082                	ret
      if(n < target){
    80000274:	000a071b          	sext.w	a4,s4
    80000278:	fb777be3          	bgeu	a4,s7,8000022e <consoleread+0xc0>
        cons.r--;
    8000027c:	00011717          	auipc	a4,0x11
    80000280:	64f72623          	sw	a5,1612(a4) # 800118c8 <cons+0x98>
    80000284:	b76d                	j	8000022e <consoleread+0xc0>

0000000080000286 <consputc>:
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e406                	sd	ra,8(sp)
    8000028a:	e022                	sd	s0,0(sp)
    8000028c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028e:	10000793          	li	a5,256
    80000292:	00f50a63          	beq	a0,a5,800002a6 <consputc+0x20>
    uartputc_sync(c);
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	564080e7          	jalr	1380(ra) # 800007fa <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	552080e7          	jalr	1362(ra) # 800007fa <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	546080e7          	jalr	1350(ra) # 800007fa <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	53c080e7          	jalr	1340(ra) # 800007fa <uartputc_sync>
    800002c6:	bfe1                	j	8000029e <consputc+0x18>

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	55a50513          	addi	a0,a0,1370 # 80011830 <cons>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	932080e7          	jalr	-1742(ra) # 80000c10 <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	334080e7          	jalr	820(ra) # 80002630 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	9b8080e7          	jalr	-1608(ra) # 80000cc4 <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	50870713          	addi	a4,a4,1288 # 80011830 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	f3c080e7          	jalr	-196(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4de78793          	addi	a5,a5,1246 # 80011830 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5487a783          	lw	a5,1352(a5) # 800118c8 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	49c70713          	addi	a4,a4,1180 # 80011830 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	48c48493          	addi	s1,s1,1164 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	ebc080e7          	jalr	-324(ra) # 80000286 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	45070713          	addi	a4,a4,1104 # 80011830 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4cf72d23          	sw	a5,1242(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e84080e7          	jalr	-380(ra) # 80000286 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	e72080e7          	jalr	-398(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	41478793          	addi	a5,a5,1044 # 80011830 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	48c7a623          	sw	a2,1164(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	48050513          	addi	a0,a0,1152 # 800118c8 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	058080e7          	jalr	88(ra) # 800024a8 <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00008597          	auipc	a1,0x8
    80000466:	bae58593          	addi	a1,a1,-1106 # 80008010 <etext+0x10>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	3c650513          	addi	a0,a0,966 # 80011830 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	70e080e7          	jalr	1806(ra) # 80000b80 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00021797          	auipc	a5,0x21
    80000486:	52e78793          	addi	a5,a5,1326 # 800219b0 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	ce470713          	addi	a4,a4,-796 # 8000016e <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	c5870713          	addi	a4,a4,-936 # 800000ec <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	b7c60613          	addi	a2,a2,-1156 # 80008040 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d60080e7          	jalr	-672(ra) # 80000286 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3807ae23          	sw	zero,924(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	abc50513          	addi	a0,a0,-1348 # 80008018 <etext+0x18>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5250513          	addi	a0,a0,-1198 # 800080c8 <digits+0x88>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	32cdad83          	lw	s11,812(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	16050263          	beqz	a0,80000744 <printf+0x1b2>
    800005e4:	4481                	li	s1,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b13          	li	s6,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00008b97          	auipc	s7,0x8
    800005f4:	a50b8b93          	addi	s7,s7,-1456 # 80008040 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2d650513          	addi	a0,a0,726 # 800118d8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	606080e7          	jalr	1542(ra) # 80000c10 <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	a1450513          	addi	a0,a0,-1516 # 80008028 <etext+0x28>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	c62080e7          	jalr	-926(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2485                	addiw	s1,s1,1
    8000062e:	009a07b3          	add	a5,s4,s1
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050763          	beqz	a0,80000744 <printf+0x1b2>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2485                	addiw	s1,s1,1
    80000640:	009a07b3          	add	a5,s4,s1
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000064c:	cfe5                	beqz	a5,80000744 <printf+0x1b2>
    switch(c){
    8000064e:	05678a63          	beq	a5,s6,800006a2 <printf+0x110>
    80000652:	02fb7663          	bgeu	s6,a5,8000067e <printf+0xec>
    80000656:	09978963          	beq	a5,s9,800006e8 <printf+0x156>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79863          	bne	a5,a4,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	0b578263          	beq	a5,s5,80000722 <printf+0x190>
    80000682:	0b879663          	bne	a5,s8,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bd0080e7          	jalr	-1072(ra) # 80000286 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	bc4080e7          	jalr	-1084(ra) # 80000286 <consputc>
    800006ca:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c9d793          	srli	a5,s3,0x3c
    800006d0:	97de                	add	a5,a5,s7
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	bb0080e7          	jalr	-1104(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0992                	slli	s3,s3,0x4
    800006e0:	397d                	addiw	s2,s2,-1
    800006e2:	fe0915e3          	bnez	s2,800006cc <printf+0x13a>
    800006e6:	b799                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	0007b903          	ld	s2,0(a5)
    800006f8:	00090e63          	beqz	s2,80000714 <printf+0x182>
      for(; *s; s++)
    800006fc:	00094503          	lbu	a0,0(s2)
    80000700:	d515                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b84080e7          	jalr	-1148(ra) # 80000286 <consputc>
      for(; *s; s++)
    8000070a:	0905                	addi	s2,s2,1
    8000070c:	00094503          	lbu	a0,0(s2)
    80000710:	f96d                	bnez	a0,80000702 <printf+0x170>
    80000712:	bf29                	j	8000062c <printf+0x9a>
        s = "(null)";
    80000714:	00008917          	auipc	s2,0x8
    80000718:	90c90913          	addi	s2,s2,-1780 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000071c:	02800513          	li	a0,40
    80000720:	b7cd                	j	80000702 <printf+0x170>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b62080e7          	jalr	-1182(ra) # 80000286 <consputc>
      break;
    8000072c:	b701                	j	8000062c <printf+0x9a>
      consputc('%');
    8000072e:	8556                	mv	a0,s5
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b56080e7          	jalr	-1194(ra) # 80000286 <consputc>
      consputc(c);
    80000738:	854a                	mv	a0,s2
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b4c080e7          	jalr	-1204(ra) # 80000286 <consputc>
      break;
    80000742:	b5ed                	j	8000062c <printf+0x9a>
  if(locking)
    80000744:	020d9163          	bnez	s11,80000766 <printf+0x1d4>
}
    80000748:	70e6                	ld	ra,120(sp)
    8000074a:	7446                	ld	s0,112(sp)
    8000074c:	74a6                	ld	s1,104(sp)
    8000074e:	7906                	ld	s2,96(sp)
    80000750:	69e6                	ld	s3,88(sp)
    80000752:	6a46                	ld	s4,80(sp)
    80000754:	6aa6                	ld	s5,72(sp)
    80000756:	6b06                	ld	s6,64(sp)
    80000758:	7be2                	ld	s7,56(sp)
    8000075a:	7c42                	ld	s8,48(sp)
    8000075c:	7ca2                	ld	s9,40(sp)
    8000075e:	7d02                	ld	s10,32(sp)
    80000760:	6de2                	ld	s11,24(sp)
    80000762:	6129                	addi	sp,sp,192
    80000764:	8082                	ret
    release(&pr.lock);
    80000766:	00011517          	auipc	a0,0x11
    8000076a:	17250513          	addi	a0,a0,370 # 800118d8 <pr>
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	556080e7          	jalr	1366(ra) # 80000cc4 <release>
}
    80000776:	bfc9                	j	80000748 <printf+0x1b6>

0000000080000778 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000778:	1101                	addi	sp,sp,-32
    8000077a:	ec06                	sd	ra,24(sp)
    8000077c:	e822                	sd	s0,16(sp)
    8000077e:	e426                	sd	s1,8(sp)
    80000780:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000782:	00011497          	auipc	s1,0x11
    80000786:	15648493          	addi	s1,s1,342 # 800118d8 <pr>
    8000078a:	00008597          	auipc	a1,0x8
    8000078e:	8ae58593          	addi	a1,a1,-1874 # 80008038 <etext+0x38>
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	3ec080e7          	jalr	1004(ra) # 80000b80 <initlock>
  pr.locking = 1;
    8000079c:	4785                	li	a5,1
    8000079e:	cc9c                	sw	a5,24(s1)
}
    800007a0:	60e2                	ld	ra,24(sp)
    800007a2:	6442                	ld	s0,16(sp)
    800007a4:	64a2                	ld	s1,8(sp)
    800007a6:	6105                	addi	sp,sp,32
    800007a8:	8082                	ret

00000000800007aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b2:	100007b7          	lui	a5,0x10000
    800007b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ba:	f8000713          	li	a4,-128
    800007be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c2:	470d                	li	a4,3
    800007c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d0:	469d                	li	a3,7
    800007d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007da:	00008597          	auipc	a1,0x8
    800007de:	87e58593          	addi	a1,a1,-1922 # 80008058 <digits+0x18>
    800007e2:	00011517          	auipc	a0,0x11
    800007e6:	11650513          	addi	a0,a0,278 # 800118f8 <uart_tx_lock>
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	396080e7          	jalr	918(ra) # 80000b80 <initlock>
}
    800007f2:	60a2                	ld	ra,8(sp)
    800007f4:	6402                	ld	s0,0(sp)
    800007f6:	0141                	addi	sp,sp,16
    800007f8:	8082                	ret

00000000800007fa <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
    80000804:	84aa                	mv	s1,a0
  push_off();
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	3be080e7          	jalr	958(ra) # 80000bc4 <push_off>

  if(panicked){
    8000080e:	00008797          	auipc	a5,0x8
    80000812:	7f27a783          	lw	a5,2034(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081a:	c391                	beqz	a5,8000081e <uartputc_sync+0x24>
    for(;;)
    8000081c:	a001                	j	8000081c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000822:	0ff7f793          	andi	a5,a5,255
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dbf5                	beqz	a5,8000081e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f793          	andi	a5,s1,255
    80000830:	10000737          	lui	a4,0x10000
    80000834:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	42c080e7          	jalr	1068(ra) # 80000c64 <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	7ba7a783          	lw	a5,1978(a5) # 80009004 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	7b672703          	lw	a4,1974(a4) # 80009008 <uart_tx_w>
    8000085a:	08f70263          	beq	a4,a5,800008de <uartstart+0x94>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000874:	00011a17          	auipc	s4,0x11
    80000878:	084a0a13          	addi	s4,s4,132 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	78848493          	addi	s1,s1,1928 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	78498993          	addi	s3,s3,1924 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	0ff77713          	andi	a4,a4,255
    80000894:	02077713          	andi	a4,a4,32
    80000898:	cb15                	beqz	a4,800008cc <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    8000089a:	00fa0733          	add	a4,s4,a5
    8000089e:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008a2:	2785                	addiw	a5,a5,1
    800008a4:	41f7d71b          	sraiw	a4,a5,0x1f
    800008a8:	01b7571b          	srliw	a4,a4,0x1b
    800008ac:	9fb9                	addw	a5,a5,a4
    800008ae:	8bfd                	andi	a5,a5,31
    800008b0:	9f99                	subw	a5,a5,a4
    800008b2:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008b4:	8526                	mv	a0,s1
    800008b6:	00002097          	auipc	ra,0x2
    800008ba:	bf2080e7          	jalr	-1038(ra) # 800024a8 <wakeup>
    
    WriteReg(THR, c);
    800008be:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008c2:	409c                	lw	a5,0(s1)
    800008c4:	0009a703          	lw	a4,0(s3)
    800008c8:	fcf712e3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008cc:	70e2                	ld	ra,56(sp)
    800008ce:	7442                	ld	s0,48(sp)
    800008d0:	74a2                	ld	s1,40(sp)
    800008d2:	7902                	ld	s2,32(sp)
    800008d4:	69e2                	ld	s3,24(sp)
    800008d6:	6a42                	ld	s4,16(sp)
    800008d8:	6aa2                	ld	s5,8(sp)
    800008da:	6121                	addi	sp,sp,64
    800008dc:	8082                	ret
    800008de:	8082                	ret

00000000800008e0 <uartputc>:
{
    800008e0:	7179                	addi	sp,sp,-48
    800008e2:	f406                	sd	ra,40(sp)
    800008e4:	f022                	sd	s0,32(sp)
    800008e6:	ec26                	sd	s1,24(sp)
    800008e8:	e84a                	sd	s2,16(sp)
    800008ea:	e44e                	sd	s3,8(sp)
    800008ec:	e052                	sd	s4,0(sp)
    800008ee:	1800                	addi	s0,sp,48
    800008f0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008f2:	00011517          	auipc	a0,0x11
    800008f6:	00650513          	addi	a0,a0,6 # 800118f8 <uart_tx_lock>
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	316080e7          	jalr	790(ra) # 80000c10 <acquire>
  if(panicked){
    80000902:	00008797          	auipc	a5,0x8
    80000906:	6fe7a783          	lw	a5,1790(a5) # 80009000 <panicked>
    8000090a:	c391                	beqz	a5,8000090e <uartputc+0x2e>
    for(;;)
    8000090c:	a001                	j	8000090c <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000090e:	00008717          	auipc	a4,0x8
    80000912:	6fa72703          	lw	a4,1786(a4) # 80009008 <uart_tx_w>
    80000916:	0017079b          	addiw	a5,a4,1
    8000091a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000091e:	01b6d69b          	srliw	a3,a3,0x1b
    80000922:	9fb5                	addw	a5,a5,a3
    80000924:	8bfd                	andi	a5,a5,31
    80000926:	9f95                	subw	a5,a5,a3
    80000928:	00008697          	auipc	a3,0x8
    8000092c:	6dc6a683          	lw	a3,1756(a3) # 80009004 <uart_tx_r>
    80000930:	04f69263          	bne	a3,a5,80000974 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000934:	00011a17          	auipc	s4,0x11
    80000938:	fc4a0a13          	addi	s4,s4,-60 # 800118f8 <uart_tx_lock>
    8000093c:	00008497          	auipc	s1,0x8
    80000940:	6c848493          	addi	s1,s1,1736 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	00008917          	auipc	s2,0x8
    80000948:	6c490913          	addi	s2,s2,1732 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000094c:	85d2                	mv	a1,s4
    8000094e:	8526                	mv	a0,s1
    80000950:	00002097          	auipc	ra,0x2
    80000954:	9d2080e7          	jalr	-1582(ra) # 80002322 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00092703          	lw	a4,0(s2)
    8000095c:	0017079b          	addiw	a5,a4,1
    80000960:	41f7d69b          	sraiw	a3,a5,0x1f
    80000964:	01b6d69b          	srliw	a3,a3,0x1b
    80000968:	9fb5                	addw	a5,a5,a3
    8000096a:	8bfd                	andi	a5,a5,31
    8000096c:	9f95                	subw	a5,a5,a3
    8000096e:	4094                	lw	a3,0(s1)
    80000970:	fcf68ee3          	beq	a3,a5,8000094c <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000974:	00011497          	auipc	s1,0x11
    80000978:	f8448493          	addi	s1,s1,-124 # 800118f8 <uart_tx_lock>
    8000097c:	9726                	add	a4,a4,s1
    8000097e:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000982:	00008717          	auipc	a4,0x8
    80000986:	68f72323          	sw	a5,1670(a4) # 80009008 <uart_tx_w>
      uartstart();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	ec0080e7          	jalr	-320(ra) # 8000084a <uartstart>
      release(&uart_tx_lock);
    80000992:	8526                	mv	a0,s1
    80000994:	00000097          	auipc	ra,0x0
    80000998:	330080e7          	jalr	816(ra) # 80000cc4 <release>
}
    8000099c:	70a2                	ld	ra,40(sp)
    8000099e:	7402                	ld	s0,32(sp)
    800009a0:	64e2                	ld	s1,24(sp)
    800009a2:	6942                	ld	s2,16(sp)
    800009a4:	69a2                	ld	s3,8(sp)
    800009a6:	6a02                	ld	s4,0(sp)
    800009a8:	6145                	addi	sp,sp,48
    800009aa:	8082                	ret

00000000800009ac <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ac:	1141                	addi	sp,sp,-16
    800009ae:	e422                	sd	s0,8(sp)
    800009b0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009b2:	100007b7          	lui	a5,0x10000
    800009b6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ba:	8b85                	andi	a5,a5,1
    800009bc:	cb91                	beqz	a5,800009d0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009be:	100007b7          	lui	a5,0x10000
    800009c2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009ca:	6422                	ld	s0,8(sp)
    800009cc:	0141                	addi	sp,sp,16
    800009ce:	8082                	ret
    return -1;
    800009d0:	557d                	li	a0,-1
    800009d2:	bfe5                	j	800009ca <uartgetc+0x1e>

00000000800009d4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009d4:	1101                	addi	sp,sp,-32
    800009d6:	ec06                	sd	ra,24(sp)
    800009d8:	e822                	sd	s0,16(sp)
    800009da:	e426                	sd	s1,8(sp)
    800009dc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009de:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e0:	00000097          	auipc	ra,0x0
    800009e4:	fcc080e7          	jalr	-52(ra) # 800009ac <uartgetc>
    if(c == -1)
    800009e8:	00950763          	beq	a0,s1,800009f6 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	8dc080e7          	jalr	-1828(ra) # 800002c8 <consoleintr>
  while(1){
    800009f4:	b7f5                	j	800009e0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f6:	00011497          	auipc	s1,0x11
    800009fa:	f0248493          	addi	s1,s1,-254 # 800118f8 <uart_tx_lock>
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	210080e7          	jalr	528(ra) # 80000c10 <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	2b2080e7          	jalr	690(ra) # 80000cc4 <release>
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a24:	1101                	addi	sp,sp,-32
    80000a26:	ec06                	sd	ra,24(sp)
    80000a28:	e822                	sd	s0,16(sp)
    80000a2a:	e426                	sd	s1,8(sp)
    80000a2c:	e04a                	sd	s2,0(sp)
    80000a2e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a30:	03451793          	slli	a5,a0,0x34
    80000a34:	ebb9                	bnez	a5,80000a8a <kfree+0x66>
    80000a36:	84aa                	mv	s1,a0
    80000a38:	00025797          	auipc	a5,0x25
    80000a3c:	5c878793          	addi	a5,a5,1480 # 80026000 <end>
    80000a40:	04f56563          	bltu	a0,a5,80000a8a <kfree+0x66>
    80000a44:	47c5                	li	a5,17
    80000a46:	07ee                	slli	a5,a5,0x1b
    80000a48:	04f57163          	bgeu	a0,a5,80000a8a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a4c:	6605                	lui	a2,0x1
    80000a4e:	4585                	li	a1,1
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	2bc080e7          	jalr	700(ra) # 80000d0c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a58:	00011917          	auipc	s2,0x11
    80000a5c:	ed890913          	addi	s2,s2,-296 # 80011930 <kmem>
    80000a60:	854a                	mv	a0,s2
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	1ae080e7          	jalr	430(ra) # 80000c10 <acquire>
  r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	24e080e7          	jalr	590(ra) # 80000cc4 <release>
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6902                	ld	s2,0(sp)
    80000a86:	6105                	addi	sp,sp,32
    80000a88:	8082                	ret
    panic("kfree");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	5d650513          	addi	a0,a0,1494 # 80008060 <digits+0x20>
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	ab6080e7          	jalr	-1354(ra) # 80000548 <panic>

0000000080000a9a <freerange>:
{
    80000a9a:	7179                	addi	sp,sp,-48
    80000a9c:	f406                	sd	ra,40(sp)
    80000a9e:	f022                	sd	s0,32(sp)
    80000aa0:	ec26                	sd	s1,24(sp)
    80000aa2:	e84a                	sd	s2,16(sp)
    80000aa4:	e44e                	sd	s3,8(sp)
    80000aa6:	e052                	sd	s4,0(sp)
    80000aa8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aaa:	6785                	lui	a5,0x1
    80000aac:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ab0:	94aa                	add	s1,s1,a0
    80000ab2:	757d                	lui	a0,0xfffff
    80000ab4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab6:	94be                	add	s1,s1,a5
    80000ab8:	0095ee63          	bltu	a1,s1,80000ad4 <freerange+0x3a>
    80000abc:	892e                	mv	s2,a1
    kfree(p);
    80000abe:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	6985                	lui	s3,0x1
    kfree(p);
    80000ac2:	01448533          	add	a0,s1,s4
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f5e080e7          	jalr	-162(ra) # 80000a24 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ace:	94ce                	add	s1,s1,s3
    80000ad0:	fe9979e3          	bgeu	s2,s1,80000ac2 <freerange+0x28>
}
    80000ad4:	70a2                	ld	ra,40(sp)
    80000ad6:	7402                	ld	s0,32(sp)
    80000ad8:	64e2                	ld	s1,24(sp)
    80000ada:	6942                	ld	s2,16(sp)
    80000adc:	69a2                	ld	s3,8(sp)
    80000ade:	6a02                	ld	s4,0(sp)
    80000ae0:	6145                	addi	sp,sp,48
    80000ae2:	8082                	ret

0000000080000ae4 <kinit>:
{
    80000ae4:	1141                	addi	sp,sp,-16
    80000ae6:	e406                	sd	ra,8(sp)
    80000ae8:	e022                	sd	s0,0(sp)
    80000aea:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aec:	00007597          	auipc	a1,0x7
    80000af0:	57c58593          	addi	a1,a1,1404 # 80008068 <digits+0x28>
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	e3c50513          	addi	a0,a0,-452 # 80011930 <kmem>
    80000afc:	00000097          	auipc	ra,0x0
    80000b00:	084080e7          	jalr	132(ra) # 80000b80 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b04:	45c5                	li	a1,17
    80000b06:	05ee                	slli	a1,a1,0x1b
    80000b08:	00025517          	auipc	a0,0x25
    80000b0c:	4f850513          	addi	a0,a0,1272 # 80026000 <end>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	f8a080e7          	jalr	-118(ra) # 80000a9a <freerange>
}
    80000b18:	60a2                	ld	ra,8(sp)
    80000b1a:	6402                	ld	s0,0(sp)
    80000b1c:	0141                	addi	sp,sp,16
    80000b1e:	8082                	ret

0000000080000b20 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b20:	1101                	addi	sp,sp,-32
    80000b22:	ec06                	sd	ra,24(sp)
    80000b24:	e822                	sd	s0,16(sp)
    80000b26:	e426                	sd	s1,8(sp)
    80000b28:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2a:	00011497          	auipc	s1,0x11
    80000b2e:	e0648493          	addi	s1,s1,-506 # 80011930 <kmem>
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	0dc080e7          	jalr	220(ra) # 80000c10 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c885                	beqz	s1,80000b6e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00011517          	auipc	a0,0x11
    80000b46:	dee50513          	addi	a0,a0,-530 # 80011930 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	178080e7          	jalr	376(ra) # 80000cc4 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b54:	6605                	lui	a2,0x1
    80000b56:	4595                	li	a1,5
    80000b58:	8526                	mv	a0,s1
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	1b2080e7          	jalr	434(ra) # 80000d0c <memset>
  return (void*)r;
}
    80000b62:	8526                	mv	a0,s1
    80000b64:	60e2                	ld	ra,24(sp)
    80000b66:	6442                	ld	s0,16(sp)
    80000b68:	64a2                	ld	s1,8(sp)
    80000b6a:	6105                	addi	sp,sp,32
    80000b6c:	8082                	ret
  release(&kmem.lock);
    80000b6e:	00011517          	auipc	a0,0x11
    80000b72:	dc250513          	addi	a0,a0,-574 # 80011930 <kmem>
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	14e080e7          	jalr	334(ra) # 80000cc4 <release>
  if(r)
    80000b7e:	b7d5                	j	80000b62 <kalloc+0x42>

0000000080000b80 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b80:	1141                	addi	sp,sp,-16
    80000b82:	e422                	sd	s0,8(sp)
    80000b84:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b86:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b88:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b8c:	00053823          	sd	zero,16(a0)
}
    80000b90:	6422                	ld	s0,8(sp)
    80000b92:	0141                	addi	sp,sp,16
    80000b94:	8082                	ret

0000000080000b96 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b96:	411c                	lw	a5,0(a0)
    80000b98:	e399                	bnez	a5,80000b9e <holding+0x8>
    80000b9a:	4501                	li	a0,0
  return r;
}
    80000b9c:	8082                	ret
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba8:	6904                	ld	s1,16(a0)
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	f4c080e7          	jalr	-180(ra) # 80001af6 <mycpu>
    80000bb2:	40a48533          	sub	a0,s1,a0
    80000bb6:	00153513          	seqz	a0,a0
}
    80000bba:	60e2                	ld	ra,24(sp)
    80000bbc:	6442                	ld	s0,16(sp)
    80000bbe:	64a2                	ld	s1,8(sp)
    80000bc0:	6105                	addi	sp,sp,32
    80000bc2:	8082                	ret

0000000080000bc4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bc4:	1101                	addi	sp,sp,-32
    80000bc6:	ec06                	sd	ra,24(sp)
    80000bc8:	e822                	sd	s0,16(sp)
    80000bca:	e426                	sd	s1,8(sp)
    80000bcc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bce:	100024f3          	csrr	s1,sstatus
    80000bd2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bdc:	00001097          	auipc	ra,0x1
    80000be0:	f1a080e7          	jalr	-230(ra) # 80001af6 <mycpu>
    80000be4:	5d3c                	lw	a5,120(a0)
    80000be6:	cf89                	beqz	a5,80000c00 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be8:	00001097          	auipc	ra,0x1
    80000bec:	f0e080e7          	jalr	-242(ra) # 80001af6 <mycpu>
    80000bf0:	5d3c                	lw	a5,120(a0)
    80000bf2:	2785                	addiw	a5,a5,1
    80000bf4:	dd3c                	sw	a5,120(a0)
}
    80000bf6:	60e2                	ld	ra,24(sp)
    80000bf8:	6442                	ld	s0,16(sp)
    80000bfa:	64a2                	ld	s1,8(sp)
    80000bfc:	6105                	addi	sp,sp,32
    80000bfe:	8082                	ret
    mycpu()->intena = old;
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	ef6080e7          	jalr	-266(ra) # 80001af6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c08:	8085                	srli	s1,s1,0x1
    80000c0a:	8885                	andi	s1,s1,1
    80000c0c:	dd64                	sw	s1,124(a0)
    80000c0e:	bfe9                	j	80000be8 <push_off+0x24>

0000000080000c10 <acquire>:
{
    80000c10:	1101                	addi	sp,sp,-32
    80000c12:	ec06                	sd	ra,24(sp)
    80000c14:	e822                	sd	s0,16(sp)
    80000c16:	e426                	sd	s1,8(sp)
    80000c18:	1000                	addi	s0,sp,32
    80000c1a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	fa8080e7          	jalr	-88(ra) # 80000bc4 <push_off>
  if(holding(lk))
    80000c24:	8526                	mv	a0,s1
    80000c26:	00000097          	auipc	ra,0x0
    80000c2a:	f70080e7          	jalr	-144(ra) # 80000b96 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c2e:	4705                	li	a4,1
  if(holding(lk))
    80000c30:	e115                	bnez	a0,80000c54 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c32:	87ba                	mv	a5,a4
    80000c34:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c38:	2781                	sext.w	a5,a5
    80000c3a:	ffe5                	bnez	a5,80000c32 <acquire+0x22>
  __sync_synchronize();
    80000c3c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	eb6080e7          	jalr	-330(ra) # 80001af6 <mycpu>
    80000c48:	e888                	sd	a0,16(s1)
}
    80000c4a:	60e2                	ld	ra,24(sp)
    80000c4c:	6442                	ld	s0,16(sp)
    80000c4e:	64a2                	ld	s1,8(sp)
    80000c50:	6105                	addi	sp,sp,32
    80000c52:	8082                	ret
    panic("acquire");
    80000c54:	00007517          	auipc	a0,0x7
    80000c58:	41c50513          	addi	a0,a0,1052 # 80008070 <digits+0x30>
    80000c5c:	00000097          	auipc	ra,0x0
    80000c60:	8ec080e7          	jalr	-1812(ra) # 80000548 <panic>

0000000080000c64 <pop_off>:

void
pop_off(void)
{
    80000c64:	1141                	addi	sp,sp,-16
    80000c66:	e406                	sd	ra,8(sp)
    80000c68:	e022                	sd	s0,0(sp)
    80000c6a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c6c:	00001097          	auipc	ra,0x1
    80000c70:	e8a080e7          	jalr	-374(ra) # 80001af6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c74:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c78:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7a:	e78d                	bnez	a5,80000ca4 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	02f05b63          	blez	a5,80000cb4 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c82:	37fd                	addiw	a5,a5,-1
    80000c84:	0007871b          	sext.w	a4,a5
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb09                	bnez	a4,80000c9c <pop_off+0x38>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00007517          	auipc	a0,0x7
    80000ca8:	3d450513          	addi	a0,a0,980 # 80008078 <digits+0x38>
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	89c080e7          	jalr	-1892(ra) # 80000548 <panic>
    panic("pop_off");
    80000cb4:	00007517          	auipc	a0,0x7
    80000cb8:	3dc50513          	addi	a0,a0,988 # 80008090 <digits+0x50>
    80000cbc:	00000097          	auipc	ra,0x0
    80000cc0:	88c080e7          	jalr	-1908(ra) # 80000548 <panic>

0000000080000cc4 <release>:
{
    80000cc4:	1101                	addi	sp,sp,-32
    80000cc6:	ec06                	sd	ra,24(sp)
    80000cc8:	e822                	sd	s0,16(sp)
    80000cca:	e426                	sd	s1,8(sp)
    80000ccc:	1000                	addi	s0,sp,32
    80000cce:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cd0:	00000097          	auipc	ra,0x0
    80000cd4:	ec6080e7          	jalr	-314(ra) # 80000b96 <holding>
    80000cd8:	c115                	beqz	a0,80000cfc <release+0x38>
  lk->cpu = 0;
    80000cda:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cde:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ce2:	0f50000f          	fence	iorw,ow
    80000ce6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	f7a080e7          	jalr	-134(ra) # 80000c64 <pop_off>
}
    80000cf2:	60e2                	ld	ra,24(sp)
    80000cf4:	6442                	ld	s0,16(sp)
    80000cf6:	64a2                	ld	s1,8(sp)
    80000cf8:	6105                	addi	sp,sp,32
    80000cfa:	8082                	ret
    panic("release");
    80000cfc:	00007517          	auipc	a0,0x7
    80000d00:	39c50513          	addi	a0,a0,924 # 80008098 <digits+0x58>
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	844080e7          	jalr	-1980(ra) # 80000548 <panic>

0000000080000d0c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d12:	ce09                	beqz	a2,80000d2c <memset+0x20>
    80000d14:	87aa                	mv	a5,a0
    80000d16:	fff6071b          	addiw	a4,a2,-1
    80000d1a:	1702                	slli	a4,a4,0x20
    80000d1c:	9301                	srli	a4,a4,0x20
    80000d1e:	0705                	addi	a4,a4,1
    80000d20:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d22:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d26:	0785                	addi	a5,a5,1
    80000d28:	fee79de3          	bne	a5,a4,80000d22 <memset+0x16>
  }
  return dst;
}
    80000d2c:	6422                	ld	s0,8(sp)
    80000d2e:	0141                	addi	sp,sp,16
    80000d30:	8082                	ret

0000000080000d32 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e422                	sd	s0,8(sp)
    80000d36:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d38:	ca05                	beqz	a2,80000d68 <memcmp+0x36>
    80000d3a:	fff6069b          	addiw	a3,a2,-1
    80000d3e:	1682                	slli	a3,a3,0x20
    80000d40:	9281                	srli	a3,a3,0x20
    80000d42:	0685                	addi	a3,a3,1
    80000d44:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d46:	00054783          	lbu	a5,0(a0)
    80000d4a:	0005c703          	lbu	a4,0(a1)
    80000d4e:	00e79863          	bne	a5,a4,80000d5e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d52:	0505                	addi	a0,a0,1
    80000d54:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d56:	fed518e3          	bne	a0,a3,80000d46 <memcmp+0x14>
  }

  return 0;
    80000d5a:	4501                	li	a0,0
    80000d5c:	a019                	j	80000d62 <memcmp+0x30>
      return *s1 - *s2;
    80000d5e:	40e7853b          	subw	a0,a5,a4
}
    80000d62:	6422                	ld	s0,8(sp)
    80000d64:	0141                	addi	sp,sp,16
    80000d66:	8082                	ret
  return 0;
    80000d68:	4501                	li	a0,0
    80000d6a:	bfe5                	j	80000d62 <memcmp+0x30>

0000000080000d6c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d6c:	1141                	addi	sp,sp,-16
    80000d6e:	e422                	sd	s0,8(sp)
    80000d70:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d72:	00a5f963          	bgeu	a1,a0,80000d84 <memmove+0x18>
    80000d76:	02061713          	slli	a4,a2,0x20
    80000d7a:	9301                	srli	a4,a4,0x20
    80000d7c:	00e587b3          	add	a5,a1,a4
    80000d80:	02f56563          	bltu	a0,a5,80000daa <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d84:	fff6069b          	addiw	a3,a2,-1
    80000d88:	ce11                	beqz	a2,80000da4 <memmove+0x38>
    80000d8a:	1682                	slli	a3,a3,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	0685                	addi	a3,a3,1
    80000d90:	96ae                	add	a3,a3,a1
    80000d92:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d94:	0585                	addi	a1,a1,1
    80000d96:	0785                	addi	a5,a5,1
    80000d98:	fff5c703          	lbu	a4,-1(a1)
    80000d9c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000da0:	fed59ae3          	bne	a1,a3,80000d94 <memmove+0x28>

  return dst;
}
    80000da4:	6422                	ld	s0,8(sp)
    80000da6:	0141                	addi	sp,sp,16
    80000da8:	8082                	ret
    d += n;
    80000daa:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000dac:	fff6069b          	addiw	a3,a2,-1
    80000db0:	da75                	beqz	a2,80000da4 <memmove+0x38>
    80000db2:	02069613          	slli	a2,a3,0x20
    80000db6:	9201                	srli	a2,a2,0x20
    80000db8:	fff64613          	not	a2,a2
    80000dbc:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000dbe:	17fd                	addi	a5,a5,-1
    80000dc0:	177d                	addi	a4,a4,-1
    80000dc2:	0007c683          	lbu	a3,0(a5)
    80000dc6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000dca:	fec79ae3          	bne	a5,a2,80000dbe <memmove+0x52>
    80000dce:	bfd9                	j	80000da4 <memmove+0x38>

0000000080000dd0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dd0:	1141                	addi	sp,sp,-16
    80000dd2:	e406                	sd	ra,8(sp)
    80000dd4:	e022                	sd	s0,0(sp)
    80000dd6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd8:	00000097          	auipc	ra,0x0
    80000ddc:	f94080e7          	jalr	-108(ra) # 80000d6c <memmove>
}
    80000de0:	60a2                	ld	ra,8(sp)
    80000de2:	6402                	ld	s0,0(sp)
    80000de4:	0141                	addi	sp,sp,16
    80000de6:	8082                	ret

0000000080000de8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000de8:	1141                	addi	sp,sp,-16
    80000dea:	e422                	sd	s0,8(sp)
    80000dec:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dee:	ce11                	beqz	a2,80000e0a <strncmp+0x22>
    80000df0:	00054783          	lbu	a5,0(a0)
    80000df4:	cf89                	beqz	a5,80000e0e <strncmp+0x26>
    80000df6:	0005c703          	lbu	a4,0(a1)
    80000dfa:	00f71a63          	bne	a4,a5,80000e0e <strncmp+0x26>
    n--, p++, q++;
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	0505                	addi	a0,a0,1
    80000e02:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e04:	f675                	bnez	a2,80000df0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e06:	4501                	li	a0,0
    80000e08:	a809                	j	80000e1a <strncmp+0x32>
    80000e0a:	4501                	li	a0,0
    80000e0c:	a039                	j	80000e1a <strncmp+0x32>
  if(n == 0)
    80000e0e:	ca09                	beqz	a2,80000e20 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e10:	00054503          	lbu	a0,0(a0)
    80000e14:	0005c783          	lbu	a5,0(a1)
    80000e18:	9d1d                	subw	a0,a0,a5
}
    80000e1a:	6422                	ld	s0,8(sp)
    80000e1c:	0141                	addi	sp,sp,16
    80000e1e:	8082                	ret
    return 0;
    80000e20:	4501                	li	a0,0
    80000e22:	bfe5                	j	80000e1a <strncmp+0x32>

0000000080000e24 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e422                	sd	s0,8(sp)
    80000e28:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e2a:	872a                	mv	a4,a0
    80000e2c:	8832                	mv	a6,a2
    80000e2e:	367d                	addiw	a2,a2,-1
    80000e30:	01005963          	blez	a6,80000e42 <strncpy+0x1e>
    80000e34:	0705                	addi	a4,a4,1
    80000e36:	0005c783          	lbu	a5,0(a1)
    80000e3a:	fef70fa3          	sb	a5,-1(a4)
    80000e3e:	0585                	addi	a1,a1,1
    80000e40:	f7f5                	bnez	a5,80000e2c <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e42:	00c05d63          	blez	a2,80000e5c <strncpy+0x38>
    80000e46:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e48:	0685                	addi	a3,a3,1
    80000e4a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e4e:	fff6c793          	not	a5,a3
    80000e52:	9fb9                	addw	a5,a5,a4
    80000e54:	010787bb          	addw	a5,a5,a6
    80000e58:	fef048e3          	bgtz	a5,80000e48 <strncpy+0x24>
  return os;
}
    80000e5c:	6422                	ld	s0,8(sp)
    80000e5e:	0141                	addi	sp,sp,16
    80000e60:	8082                	ret

0000000080000e62 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e422                	sd	s0,8(sp)
    80000e66:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e68:	02c05363          	blez	a2,80000e8e <safestrcpy+0x2c>
    80000e6c:	fff6069b          	addiw	a3,a2,-1
    80000e70:	1682                	slli	a3,a3,0x20
    80000e72:	9281                	srli	a3,a3,0x20
    80000e74:	96ae                	add	a3,a3,a1
    80000e76:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e78:	00d58963          	beq	a1,a3,80000e8a <safestrcpy+0x28>
    80000e7c:	0585                	addi	a1,a1,1
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	fff5c703          	lbu	a4,-1(a1)
    80000e84:	fee78fa3          	sb	a4,-1(a5)
    80000e88:	fb65                	bnez	a4,80000e78 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e8a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e8e:	6422                	ld	s0,8(sp)
    80000e90:	0141                	addi	sp,sp,16
    80000e92:	8082                	ret

0000000080000e94 <strlen>:

int
strlen(const char *s)
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e422                	sd	s0,8(sp)
    80000e98:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e9a:	00054783          	lbu	a5,0(a0)
    80000e9e:	cf91                	beqz	a5,80000eba <strlen+0x26>
    80000ea0:	0505                	addi	a0,a0,1
    80000ea2:	87aa                	mv	a5,a0
    80000ea4:	4685                	li	a3,1
    80000ea6:	9e89                	subw	a3,a3,a0
    80000ea8:	00f6853b          	addw	a0,a3,a5
    80000eac:	0785                	addi	a5,a5,1
    80000eae:	fff7c703          	lbu	a4,-1(a5)
    80000eb2:	fb7d                	bnez	a4,80000ea8 <strlen+0x14>
    ;
  return n;
}
    80000eb4:	6422                	ld	s0,8(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eba:	4501                	li	a0,0
    80000ebc:	bfe5                	j	80000eb4 <strlen+0x20>

0000000080000ebe <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ebe:	1141                	addi	sp,sp,-16
    80000ec0:	e406                	sd	ra,8(sp)
    80000ec2:	e022                	sd	s0,0(sp)
    80000ec4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ec6:	00001097          	auipc	ra,0x1
    80000eca:	c20080e7          	jalr	-992(ra) # 80001ae6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ece:	00008717          	auipc	a4,0x8
    80000ed2:	13e70713          	addi	a4,a4,318 # 8000900c <started>
  if(cpuid() == 0){
    80000ed6:	c139                	beqz	a0,80000f1c <main+0x5e>
    while(started == 0)
    80000ed8:	431c                	lw	a5,0(a4)
    80000eda:	2781                	sext.w	a5,a5
    80000edc:	dff5                	beqz	a5,80000ed8 <main+0x1a>
      ;
    __sync_synchronize();
    80000ede:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ee2:	00001097          	auipc	ra,0x1
    80000ee6:	c04080e7          	jalr	-1020(ra) # 80001ae6 <cpuid>
    80000eea:	85aa                	mv	a1,a0
    80000eec:	00007517          	auipc	a0,0x7
    80000ef0:	1cc50513          	addi	a0,a0,460 # 800080b8 <digits+0x78>
    80000ef4:	fffff097          	auipc	ra,0xfffff
    80000ef8:	69e080e7          	jalr	1694(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	0d8080e7          	jalr	216(ra) # 80000fd4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f04:	00002097          	auipc	ra,0x2
    80000f08:	86c080e7          	jalr	-1940(ra) # 80002770 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f0c:	00005097          	auipc	ra,0x5
    80000f10:	e54080e7          	jalr	-428(ra) # 80005d60 <plicinithart>
  }

  scheduler();        
    80000f14:	00001097          	auipc	ra,0x1
    80000f18:	12e080e7          	jalr	302(ra) # 80002042 <scheduler>
    consoleinit();
    80000f1c:	fffff097          	auipc	ra,0xfffff
    80000f20:	53e080e7          	jalr	1342(ra) # 8000045a <consoleinit>
    printfinit();
    80000f24:	00000097          	auipc	ra,0x0
    80000f28:	854080e7          	jalr	-1964(ra) # 80000778 <printfinit>
    printf("\n");
    80000f2c:	00007517          	auipc	a0,0x7
    80000f30:	19c50513          	addi	a0,a0,412 # 800080c8 <digits+0x88>
    80000f34:	fffff097          	auipc	ra,0xfffff
    80000f38:	65e080e7          	jalr	1630(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	16450513          	addi	a0,a0,356 # 800080a0 <digits+0x60>
    80000f44:	fffff097          	auipc	ra,0xfffff
    80000f48:	64e080e7          	jalr	1614(ra) # 80000592 <printf>
    printf("\n");
    80000f4c:	00007517          	auipc	a0,0x7
    80000f50:	17c50513          	addi	a0,a0,380 # 800080c8 <digits+0x88>
    80000f54:	fffff097          	auipc	ra,0xfffff
    80000f58:	63e080e7          	jalr	1598(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000f5c:	00000097          	auipc	ra,0x0
    80000f60:	b88080e7          	jalr	-1144(ra) # 80000ae4 <kinit>
    kvminit();       // create kernel page table
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	25e080e7          	jalr	606(ra) # 800011c2 <kvminit>
    kvminithart();   // turn on paging
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	068080e7          	jalr	104(ra) # 80000fd4 <kvminithart>
    procinit();      // process table
    80000f74:	00001097          	auipc	ra,0x1
    80000f78:	aa2080e7          	jalr	-1374(ra) # 80001a16 <procinit>
    trapinit();      // trap vectors
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	7cc080e7          	jalr	1996(ra) # 80002748 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	7ec080e7          	jalr	2028(ra) # 80002770 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f8c:	00005097          	auipc	ra,0x5
    80000f90:	dbe080e7          	jalr	-578(ra) # 80005d4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f94:	00005097          	auipc	ra,0x5
    80000f98:	dcc080e7          	jalr	-564(ra) # 80005d60 <plicinithart>
    binit();         // buffer cache
    80000f9c:	00002097          	auipc	ra,0x2
    80000fa0:	f54080e7          	jalr	-172(ra) # 80002ef0 <binit>
    iinit();         // inode cache
    80000fa4:	00002097          	auipc	ra,0x2
    80000fa8:	5e4080e7          	jalr	1508(ra) # 80003588 <iinit>
    fileinit();      // file table
    80000fac:	00003097          	auipc	ra,0x3
    80000fb0:	582080e7          	jalr	1410(ra) # 8000452e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb4:	00005097          	auipc	ra,0x5
    80000fb8:	eb4080e7          	jalr	-332(ra) # 80005e68 <virtio_disk_init>
    userinit();      // first user process
    80000fbc:	00001097          	auipc	ra,0x1
    80000fc0:	e20080e7          	jalr	-480(ra) # 80001ddc <userinit>
    __sync_synchronize();
    80000fc4:	0ff0000f          	fence
    started = 1;
    80000fc8:	4785                	li	a5,1
    80000fca:	00008717          	auipc	a4,0x8
    80000fce:	04f72123          	sw	a5,66(a4) # 8000900c <started>
    80000fd2:	b789                	j	80000f14 <main+0x56>

0000000080000fd4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fd4:	1141                	addi	sp,sp,-16
    80000fd6:	e422                	sd	s0,8(sp)
    80000fd8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fda:	00008797          	auipc	a5,0x8
    80000fde:	0367b783          	ld	a5,54(a5) # 80009010 <kernel_pagetable>
    80000fe2:	83b1                	srli	a5,a5,0xc
    80000fe4:	577d                	li	a4,-1
    80000fe6:	177e                	slli	a4,a4,0x3f
    80000fe8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fea:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  sfence_vma();
}
    80000ff2:	6422                	ld	s0,8(sp)
    80000ff4:	0141                	addi	sp,sp,16
    80000ff6:	8082                	ret

0000000080000ff8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ff8:	7139                	addi	sp,sp,-64
    80000ffa:	fc06                	sd	ra,56(sp)
    80000ffc:	f822                	sd	s0,48(sp)
    80000ffe:	f426                	sd	s1,40(sp)
    80001000:	f04a                	sd	s2,32(sp)
    80001002:	ec4e                	sd	s3,24(sp)
    80001004:	e852                	sd	s4,16(sp)
    80001006:	e456                	sd	s5,8(sp)
    80001008:	e05a                	sd	s6,0(sp)
    8000100a:	0080                	addi	s0,sp,64
    8000100c:	84aa                	mv	s1,a0
    8000100e:	89ae                	mv	s3,a1
    80001010:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001012:	57fd                	li	a5,-1
    80001014:	83e9                	srli	a5,a5,0x1a
    80001016:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001018:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000101a:	04b7f263          	bgeu	a5,a1,8000105e <walk+0x66>
    panic("walk");
    8000101e:	00007517          	auipc	a0,0x7
    80001022:	0b250513          	addi	a0,a0,178 # 800080d0 <digits+0x90>
    80001026:	fffff097          	auipc	ra,0xfffff
    8000102a:	522080e7          	jalr	1314(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000102e:	060a8663          	beqz	s5,8000109a <walk+0xa2>
    80001032:	00000097          	auipc	ra,0x0
    80001036:	aee080e7          	jalr	-1298(ra) # 80000b20 <kalloc>
    8000103a:	84aa                	mv	s1,a0
    8000103c:	c529                	beqz	a0,80001086 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000103e:	6605                	lui	a2,0x1
    80001040:	4581                	li	a1,0
    80001042:	00000097          	auipc	ra,0x0
    80001046:	cca080e7          	jalr	-822(ra) # 80000d0c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000104a:	00c4d793          	srli	a5,s1,0xc
    8000104e:	07aa                	slli	a5,a5,0xa
    80001050:	0017e793          	ori	a5,a5,1
    80001054:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001058:	3a5d                	addiw	s4,s4,-9
    8000105a:	036a0063          	beq	s4,s6,8000107a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000105e:	0149d933          	srl	s2,s3,s4
    80001062:	1ff97913          	andi	s2,s2,511
    80001066:	090e                	slli	s2,s2,0x3
    80001068:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000106a:	00093483          	ld	s1,0(s2)
    8000106e:	0014f793          	andi	a5,s1,1
    80001072:	dfd5                	beqz	a5,8000102e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001074:	80a9                	srli	s1,s1,0xa
    80001076:	04b2                	slli	s1,s1,0xc
    80001078:	b7c5                	j	80001058 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000107a:	00c9d513          	srli	a0,s3,0xc
    8000107e:	1ff57513          	andi	a0,a0,511
    80001082:	050e                	slli	a0,a0,0x3
    80001084:	9526                	add	a0,a0,s1
}
    80001086:	70e2                	ld	ra,56(sp)
    80001088:	7442                	ld	s0,48(sp)
    8000108a:	74a2                	ld	s1,40(sp)
    8000108c:	7902                	ld	s2,32(sp)
    8000108e:	69e2                	ld	s3,24(sp)
    80001090:	6a42                	ld	s4,16(sp)
    80001092:	6aa2                	ld	s5,8(sp)
    80001094:	6b02                	ld	s6,0(sp)
    80001096:	6121                	addi	sp,sp,64
    80001098:	8082                	ret
        return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7ed                	j	80001086 <walk+0x8e>

000000008000109e <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    8000109e:	1101                	addi	sp,sp,-32
    800010a0:	ec06                	sd	ra,24(sp)
    800010a2:	e822                	sd	s0,16(sp)
    800010a4:	e426                	sd	s1,8(sp)
    800010a6:	1000                	addi	s0,sp,32
    800010a8:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800010aa:	1552                	slli	a0,a0,0x34
    800010ac:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800010b0:	4601                	li	a2,0
    800010b2:	00008517          	auipc	a0,0x8
    800010b6:	f5e53503          	ld	a0,-162(a0) # 80009010 <kernel_pagetable>
    800010ba:	00000097          	auipc	ra,0x0
    800010be:	f3e080e7          	jalr	-194(ra) # 80000ff8 <walk>
  if(pte == 0)
    800010c2:	cd09                	beqz	a0,800010dc <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800010c4:	6108                	ld	a0,0(a0)
    800010c6:	00157793          	andi	a5,a0,1
    800010ca:	c38d                	beqz	a5,800010ec <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800010cc:	8129                	srli	a0,a0,0xa
    800010ce:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    800010d0:	9526                	add	a0,a0,s1
    800010d2:	60e2                	ld	ra,24(sp)
    800010d4:	6442                	ld	s0,16(sp)
    800010d6:	64a2                	ld	s1,8(sp)
    800010d8:	6105                	addi	sp,sp,32
    800010da:	8082                	ret
    panic("kvmpa");
    800010dc:	00007517          	auipc	a0,0x7
    800010e0:	ffc50513          	addi	a0,a0,-4 # 800080d8 <digits+0x98>
    800010e4:	fffff097          	auipc	ra,0xfffff
    800010e8:	464080e7          	jalr	1124(ra) # 80000548 <panic>
    panic("kvmpa");
    800010ec:	00007517          	auipc	a0,0x7
    800010f0:	fec50513          	addi	a0,a0,-20 # 800080d8 <digits+0x98>
    800010f4:	fffff097          	auipc	ra,0xfffff
    800010f8:	454080e7          	jalr	1108(ra) # 80000548 <panic>

00000000800010fc <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010fc:	715d                	addi	sp,sp,-80
    800010fe:	e486                	sd	ra,72(sp)
    80001100:	e0a2                	sd	s0,64(sp)
    80001102:	fc26                	sd	s1,56(sp)
    80001104:	f84a                	sd	s2,48(sp)
    80001106:	f44e                	sd	s3,40(sp)
    80001108:	f052                	sd	s4,32(sp)
    8000110a:	ec56                	sd	s5,24(sp)
    8000110c:	e85a                	sd	s6,16(sp)
    8000110e:	e45e                	sd	s7,8(sp)
    80001110:	0880                	addi	s0,sp,80
    80001112:	8aaa                	mv	s5,a0
    80001114:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001116:	777d                	lui	a4,0xfffff
    80001118:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111c:	167d                	addi	a2,a2,-1
    8000111e:	00b609b3          	add	s3,a2,a1
    80001122:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001126:	893e                	mv	s2,a5
    80001128:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112c:	6b85                	lui	s7,0x1
    8000112e:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001132:	4605                	li	a2,1
    80001134:	85ca                	mv	a1,s2
    80001136:	8556                	mv	a0,s5
    80001138:	00000097          	auipc	ra,0x0
    8000113c:	ec0080e7          	jalr	-320(ra) # 80000ff8 <walk>
    80001140:	c51d                	beqz	a0,8000116e <mappages+0x72>
    if(*pte & PTE_V)
    80001142:	611c                	ld	a5,0(a0)
    80001144:	8b85                	andi	a5,a5,1
    80001146:	ef81                	bnez	a5,8000115e <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001148:	80b1                	srli	s1,s1,0xc
    8000114a:	04aa                	slli	s1,s1,0xa
    8000114c:	0164e4b3          	or	s1,s1,s6
    80001150:	0014e493          	ori	s1,s1,1
    80001154:	e104                	sd	s1,0(a0)
    if(a == last)
    80001156:	03390863          	beq	s2,s3,80001186 <mappages+0x8a>
    a += PGSIZE;
    8000115a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115c:	bfc9                	j	8000112e <mappages+0x32>
      panic("remap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f8250513          	addi	a0,a0,-126 # 800080e0 <digits+0xa0>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3e2080e7          	jalr	994(ra) # 80000548 <panic>
      return -1;
    8000116e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001170:	60a6                	ld	ra,72(sp)
    80001172:	6406                	ld	s0,64(sp)
    80001174:	74e2                	ld	s1,56(sp)
    80001176:	7942                	ld	s2,48(sp)
    80001178:	79a2                	ld	s3,40(sp)
    8000117a:	7a02                	ld	s4,32(sp)
    8000117c:	6ae2                	ld	s5,24(sp)
    8000117e:	6b42                	ld	s6,16(sp)
    80001180:	6ba2                	ld	s7,8(sp)
    80001182:	6161                	addi	sp,sp,80
    80001184:	8082                	ret
  return 0;
    80001186:	4501                	li	a0,0
    80001188:	b7e5                	j	80001170 <mappages+0x74>

000000008000118a <kvmmap>:
{
    8000118a:	1141                	addi	sp,sp,-16
    8000118c:	e406                	sd	ra,8(sp)
    8000118e:	e022                	sd	s0,0(sp)
    80001190:	0800                	addi	s0,sp,16
    80001192:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001194:	86ae                	mv	a3,a1
    80001196:	85aa                	mv	a1,a0
    80001198:	00008517          	auipc	a0,0x8
    8000119c:	e7853503          	ld	a0,-392(a0) # 80009010 <kernel_pagetable>
    800011a0:	00000097          	auipc	ra,0x0
    800011a4:	f5c080e7          	jalr	-164(ra) # 800010fc <mappages>
    800011a8:	e509                	bnez	a0,800011b2 <kvmmap+0x28>
}
    800011aa:	60a2                	ld	ra,8(sp)
    800011ac:	6402                	ld	s0,0(sp)
    800011ae:	0141                	addi	sp,sp,16
    800011b0:	8082                	ret
    panic("kvmmap");
    800011b2:	00007517          	auipc	a0,0x7
    800011b6:	f3650513          	addi	a0,a0,-202 # 800080e8 <digits+0xa8>
    800011ba:	fffff097          	auipc	ra,0xfffff
    800011be:	38e080e7          	jalr	910(ra) # 80000548 <panic>

00000000800011c2 <kvminit>:
{
    800011c2:	1101                	addi	sp,sp,-32
    800011c4:	ec06                	sd	ra,24(sp)
    800011c6:	e822                	sd	s0,16(sp)
    800011c8:	e426                	sd	s1,8(sp)
    800011ca:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	954080e7          	jalr	-1708(ra) # 80000b20 <kalloc>
    800011d4:	00008797          	auipc	a5,0x8
    800011d8:	e2a7be23          	sd	a0,-452(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800011dc:	6605                	lui	a2,0x1
    800011de:	4581                	li	a1,0
    800011e0:	00000097          	auipc	ra,0x0
    800011e4:	b2c080e7          	jalr	-1236(ra) # 80000d0c <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011e8:	4699                	li	a3,6
    800011ea:	6605                	lui	a2,0x1
    800011ec:	100005b7          	lui	a1,0x10000
    800011f0:	10000537          	lui	a0,0x10000
    800011f4:	00000097          	auipc	ra,0x0
    800011f8:	f96080e7          	jalr	-106(ra) # 8000118a <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011fc:	4699                	li	a3,6
    800011fe:	6605                	lui	a2,0x1
    80001200:	100015b7          	lui	a1,0x10001
    80001204:	10001537          	lui	a0,0x10001
    80001208:	00000097          	auipc	ra,0x0
    8000120c:	f82080e7          	jalr	-126(ra) # 8000118a <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001210:	4699                	li	a3,6
    80001212:	6641                	lui	a2,0x10
    80001214:	020005b7          	lui	a1,0x2000
    80001218:	02000537          	lui	a0,0x2000
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	f6e080e7          	jalr	-146(ra) # 8000118a <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001224:	4699                	li	a3,6
    80001226:	00400637          	lui	a2,0x400
    8000122a:	0c0005b7          	lui	a1,0xc000
    8000122e:	0c000537          	lui	a0,0xc000
    80001232:	00000097          	auipc	ra,0x0
    80001236:	f58080e7          	jalr	-168(ra) # 8000118a <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000123a:	00007497          	auipc	s1,0x7
    8000123e:	dc648493          	addi	s1,s1,-570 # 80008000 <etext>
    80001242:	46a9                	li	a3,10
    80001244:	80007617          	auipc	a2,0x80007
    80001248:	dbc60613          	addi	a2,a2,-580 # 8000 <_entry-0x7fff8000>
    8000124c:	4585                	li	a1,1
    8000124e:	05fe                	slli	a1,a1,0x1f
    80001250:	852e                	mv	a0,a1
    80001252:	00000097          	auipc	ra,0x0
    80001256:	f38080e7          	jalr	-200(ra) # 8000118a <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000125a:	4699                	li	a3,6
    8000125c:	4645                	li	a2,17
    8000125e:	066e                	slli	a2,a2,0x1b
    80001260:	8e05                	sub	a2,a2,s1
    80001262:	85a6                	mv	a1,s1
    80001264:	8526                	mv	a0,s1
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	f24080e7          	jalr	-220(ra) # 8000118a <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000126e:	46a9                	li	a3,10
    80001270:	6605                	lui	a2,0x1
    80001272:	00006597          	auipc	a1,0x6
    80001276:	d8e58593          	addi	a1,a1,-626 # 80007000 <_trampoline>
    8000127a:	04000537          	lui	a0,0x4000
    8000127e:	157d                	addi	a0,a0,-1
    80001280:	0532                	slli	a0,a0,0xc
    80001282:	00000097          	auipc	ra,0x0
    80001286:	f08080e7          	jalr	-248(ra) # 8000118a <kvmmap>
}
    8000128a:	60e2                	ld	ra,24(sp)
    8000128c:	6442                	ld	s0,16(sp)
    8000128e:	64a2                	ld	s1,8(sp)
    80001290:	6105                	addi	sp,sp,32
    80001292:	8082                	ret

0000000080001294 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001294:	715d                	addi	sp,sp,-80
    80001296:	e486                	sd	ra,72(sp)
    80001298:	e0a2                	sd	s0,64(sp)
    8000129a:	fc26                	sd	s1,56(sp)
    8000129c:	f84a                	sd	s2,48(sp)
    8000129e:	f44e                	sd	s3,40(sp)
    800012a0:	f052                	sd	s4,32(sp)
    800012a2:	ec56                	sd	s5,24(sp)
    800012a4:	e85a                	sd	s6,16(sp)
    800012a6:	e45e                	sd	s7,8(sp)
    800012a8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012aa:	03459793          	slli	a5,a1,0x34
    800012ae:	e795                	bnez	a5,800012da <uvmunmap+0x46>
    800012b0:	8a2a                	mv	s4,a0
    800012b2:	892e                	mv	s2,a1
    800012b4:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012b6:	0632                	slli	a2,a2,0xc
    800012b8:	00b609b3          	add	s3,a2,a1
      continue;
      // panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      continue;
      //panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012bc:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012be:	6a85                	lui	s5,0x1
    800012c0:	0535e963          	bltu	a1,s3,80001312 <uvmunmap+0x7e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012c4:	60a6                	ld	ra,72(sp)
    800012c6:	6406                	ld	s0,64(sp)
    800012c8:	74e2                	ld	s1,56(sp)
    800012ca:	7942                	ld	s2,48(sp)
    800012cc:	79a2                	ld	s3,40(sp)
    800012ce:	7a02                	ld	s4,32(sp)
    800012d0:	6ae2                	ld	s5,24(sp)
    800012d2:	6b42                	ld	s6,16(sp)
    800012d4:	6ba2                	ld	s7,8(sp)
    800012d6:	6161                	addi	sp,sp,80
    800012d8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e1650513          	addi	a0,a0,-490 # 800080f0 <digits+0xb0>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	266080e7          	jalr	614(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800012ea:	00007517          	auipc	a0,0x7
    800012ee:	e1e50513          	addi	a0,a0,-482 # 80008108 <digits+0xc8>
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	256080e7          	jalr	598(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    800012fa:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800012fc:	00c79513          	slli	a0,a5,0xc
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	724080e7          	jalr	1828(ra) # 80000a24 <kfree>
    *pte = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	9956                	add	s2,s2,s5
    8000130e:	fb397be3          	bgeu	s2,s3,800012c4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001312:	4601                	li	a2,0
    80001314:	85ca                	mv	a1,s2
    80001316:	8552                	mv	a0,s4
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	ce0080e7          	jalr	-800(ra) # 80000ff8 <walk>
    80001320:	84aa                	mv	s1,a0
    80001322:	d56d                	beqz	a0,8000130c <uvmunmap+0x78>
    if((*pte & PTE_V) == 0)
    80001324:	611c                	ld	a5,0(a0)
    80001326:	0017f713          	andi	a4,a5,1
    8000132a:	d36d                	beqz	a4,8000130c <uvmunmap+0x78>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132c:	3ff7f713          	andi	a4,a5,1023
    80001330:	fb770de3          	beq	a4,s7,800012ea <uvmunmap+0x56>
    if(do_free){
    80001334:	fc0b0ae3          	beqz	s6,80001308 <uvmunmap+0x74>
    80001338:	b7c9                	j	800012fa <uvmunmap+0x66>

000000008000133a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000133a:	1101                	addi	sp,sp,-32
    8000133c:	ec06                	sd	ra,24(sp)
    8000133e:	e822                	sd	s0,16(sp)
    80001340:	e426                	sd	s1,8(sp)
    80001342:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	7dc080e7          	jalr	2012(ra) # 80000b20 <kalloc>
    8000134c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134e:	c519                	beqz	a0,8000135c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001350:	6605                	lui	a2,0x1
    80001352:	4581                	li	a1,0
    80001354:	00000097          	auipc	ra,0x0
    80001358:	9b8080e7          	jalr	-1608(ra) # 80000d0c <memset>
  return pagetable;
}
    8000135c:	8526                	mv	a0,s1
    8000135e:	60e2                	ld	ra,24(sp)
    80001360:	6442                	ld	s0,16(sp)
    80001362:	64a2                	ld	s1,8(sp)
    80001364:	6105                	addi	sp,sp,32
    80001366:	8082                	ret

0000000080001368 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001368:	7179                	addi	sp,sp,-48
    8000136a:	f406                	sd	ra,40(sp)
    8000136c:	f022                	sd	s0,32(sp)
    8000136e:	ec26                	sd	s1,24(sp)
    80001370:	e84a                	sd	s2,16(sp)
    80001372:	e44e                	sd	s3,8(sp)
    80001374:	e052                	sd	s4,0(sp)
    80001376:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001378:	6785                	lui	a5,0x1
    8000137a:	04f67863          	bgeu	a2,a5,800013ca <uvminit+0x62>
    8000137e:	8a2a                	mv	s4,a0
    80001380:	89ae                	mv	s3,a1
    80001382:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001384:	fffff097          	auipc	ra,0xfffff
    80001388:	79c080e7          	jalr	1948(ra) # 80000b20 <kalloc>
    8000138c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	00000097          	auipc	ra,0x0
    80001396:	97a080e7          	jalr	-1670(ra) # 80000d0c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000139a:	4779                	li	a4,30
    8000139c:	86ca                	mv	a3,s2
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	8552                	mv	a0,s4
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	d58080e7          	jalr	-680(ra) # 800010fc <mappages>
  memmove(mem, src, sz);
    800013ac:	8626                	mv	a2,s1
    800013ae:	85ce                	mv	a1,s3
    800013b0:	854a                	mv	a0,s2
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	9ba080e7          	jalr	-1606(ra) # 80000d6c <memmove>
}
    800013ba:	70a2                	ld	ra,40(sp)
    800013bc:	7402                	ld	s0,32(sp)
    800013be:	64e2                	ld	s1,24(sp)
    800013c0:	6942                	ld	s2,16(sp)
    800013c2:	69a2                	ld	s3,8(sp)
    800013c4:	6a02                	ld	s4,0(sp)
    800013c6:	6145                	addi	sp,sp,48
    800013c8:	8082                	ret
    panic("inituvm: more than a page");
    800013ca:	00007517          	auipc	a0,0x7
    800013ce:	d5650513          	addi	a0,a0,-682 # 80008120 <digits+0xe0>
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	176080e7          	jalr	374(ra) # 80000548 <panic>

00000000800013da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013da:	1101                	addi	sp,sp,-32
    800013dc:	ec06                	sd	ra,24(sp)
    800013de:	e822                	sd	s0,16(sp)
    800013e0:	e426                	sd	s1,8(sp)
    800013e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e6:	00b67d63          	bgeu	a2,a1,80001400 <uvmdealloc+0x26>
    800013ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ec:	6785                	lui	a5,0x1
    800013ee:	17fd                	addi	a5,a5,-1
    800013f0:	00f60733          	add	a4,a2,a5
    800013f4:	767d                	lui	a2,0xfffff
    800013f6:	8f71                	and	a4,a4,a2
    800013f8:	97ae                	add	a5,a5,a1
    800013fa:	8ff1                	and	a5,a5,a2
    800013fc:	00f76863          	bltu	a4,a5,8000140c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001400:	8526                	mv	a0,s1
    80001402:	60e2                	ld	ra,24(sp)
    80001404:	6442                	ld	s0,16(sp)
    80001406:	64a2                	ld	s1,8(sp)
    80001408:	6105                	addi	sp,sp,32
    8000140a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140c:	8f99                	sub	a5,a5,a4
    8000140e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001410:	4685                	li	a3,1
    80001412:	0007861b          	sext.w	a2,a5
    80001416:	85ba                	mv	a1,a4
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	e7c080e7          	jalr	-388(ra) # 80001294 <uvmunmap>
    80001420:	b7c5                	j	80001400 <uvmdealloc+0x26>

0000000080001422 <uvmalloc>:
  if(newsz < oldsz)
    80001422:	0ab66163          	bltu	a2,a1,800014c4 <uvmalloc+0xa2>
{
    80001426:	7139                	addi	sp,sp,-64
    80001428:	fc06                	sd	ra,56(sp)
    8000142a:	f822                	sd	s0,48(sp)
    8000142c:	f426                	sd	s1,40(sp)
    8000142e:	f04a                	sd	s2,32(sp)
    80001430:	ec4e                	sd	s3,24(sp)
    80001432:	e852                	sd	s4,16(sp)
    80001434:	e456                	sd	s5,8(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6985                	lui	s3,0x1
    8000143e:	19fd                	addi	s3,s3,-1
    80001440:	95ce                	add	a1,a1,s3
    80001442:	79fd                	lui	s3,0xfffff
    80001444:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f063          	bgeu	s3,a2,800014c8 <uvmalloc+0xa6>
    8000144c:	894e                	mv	s2,s3
    mem = kalloc();
    8000144e:	fffff097          	auipc	ra,0xfffff
    80001452:	6d2080e7          	jalr	1746(ra) # 80000b20 <kalloc>
    80001456:	84aa                	mv	s1,a0
    if(mem == 0){
    80001458:	c51d                	beqz	a0,80001486 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000145a:	6605                	lui	a2,0x1
    8000145c:	4581                	li	a1,0
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	8ae080e7          	jalr	-1874(ra) # 80000d0c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001466:	4779                	li	a4,30
    80001468:	86a6                	mv	a3,s1
    8000146a:	6605                	lui	a2,0x1
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	c8c080e7          	jalr	-884(ra) # 800010fc <mappages>
    80001478:	e905                	bnez	a0,800014a8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147a:	6785                	lui	a5,0x1
    8000147c:	993e                	add	s2,s2,a5
    8000147e:	fd4968e3          	bltu	s2,s4,8000144e <uvmalloc+0x2c>
  return newsz;
    80001482:	8552                	mv	a0,s4
    80001484:	a809                	j	80001496 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001486:	864e                	mv	a2,s3
    80001488:	85ca                	mv	a1,s2
    8000148a:	8556                	mv	a0,s5
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f4e080e7          	jalr	-178(ra) # 800013da <uvmdealloc>
      return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	70e2                	ld	ra,56(sp)
    80001498:	7442                	ld	s0,48(sp)
    8000149a:	74a2                	ld	s1,40(sp)
    8000149c:	7902                	ld	s2,32(sp)
    8000149e:	69e2                	ld	s3,24(sp)
    800014a0:	6a42                	ld	s4,16(sp)
    800014a2:	6aa2                	ld	s5,8(sp)
    800014a4:	6121                	addi	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	57a080e7          	jalr	1402(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f22080e7          	jalr	-222(ra) # 800013da <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfd1                	j	80001496 <uvmalloc+0x74>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7f1                	j	80001496 <uvmalloc+0x74>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	addi	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	addi	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a821                	j	800014fe <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ea:	0532                	slli	a0,a0,0xc
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	fe0080e7          	jalr	-32(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f8:	04a1                	addi	s1,s1,8
    800014fa:	01248863          	beq	s1,s2,8000150a <freewalk+0x3e>
    pte_t pte = pagetable[i];
    800014fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001500:	00f57793          	andi	a5,a0,15
    80001504:	ff379ae3          	bne	a5,s3,800014f8 <freewalk+0x2c>
    80001508:	b7c5                	j	800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
      // panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
    8000150a:	8552                	mv	a0,s4
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	518080e7          	jalr	1304(ra) # 80000a24 <kfree>
}
    80001514:	70a2                	ld	ra,40(sp)
    80001516:	7402                	ld	s0,32(sp)
    80001518:	64e2                	ld	s1,24(sp)
    8000151a:	6942                	ld	s2,16(sp)
    8000151c:	69a2                	ld	s3,8(sp)
    8000151e:	6a02                	ld	s4,0(sp)
    80001520:	6145                	addi	sp,sp,48
    80001522:	8082                	ret

0000000080001524 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001524:	1101                	addi	sp,sp,-32
    80001526:	ec06                	sd	ra,24(sp)
    80001528:	e822                	sd	s0,16(sp)
    8000152a:	e426                	sd	s1,8(sp)
    8000152c:	1000                	addi	s0,sp,32
    8000152e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001530:	e999                	bnez	a1,80001546 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001532:	8526                	mv	a0,s1
    80001534:	00000097          	auipc	ra,0x0
    80001538:	f98080e7          	jalr	-104(ra) # 800014cc <freewalk>
}
    8000153c:	60e2                	ld	ra,24(sp)
    8000153e:	6442                	ld	s0,16(sp)
    80001540:	64a2                	ld	s1,8(sp)
    80001542:	6105                	addi	sp,sp,32
    80001544:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001546:	6605                	lui	a2,0x1
    80001548:	167d                	addi	a2,a2,-1
    8000154a:	962e                	add	a2,a2,a1
    8000154c:	4685                	li	a3,1
    8000154e:	8231                	srli	a2,a2,0xc
    80001550:	4581                	li	a1,0
    80001552:	00000097          	auipc	ra,0x0
    80001556:	d42080e7          	jalr	-702(ra) # 80001294 <uvmunmap>
    8000155a:	bfe1                	j	80001532 <uvmfree+0xe>

000000008000155c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000155c:	ca4d                	beqz	a2,8000160e <uvmcopy+0xb2>
{
    8000155e:	715d                	addi	sp,sp,-80
    80001560:	e486                	sd	ra,72(sp)
    80001562:	e0a2                	sd	s0,64(sp)
    80001564:	fc26                	sd	s1,56(sp)
    80001566:	f84a                	sd	s2,48(sp)
    80001568:	f44e                	sd	s3,40(sp)
    8000156a:	f052                	sd	s4,32(sp)
    8000156c:	ec56                	sd	s5,24(sp)
    8000156e:	e85a                	sd	s6,16(sp)
    80001570:	e45e                	sd	s7,8(sp)
    80001572:	0880                	addi	s0,sp,80
    80001574:	8aaa                	mv	s5,a0
    80001576:	8b2e                	mv	s6,a1
    80001578:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157a:	4481                	li	s1,0
    8000157c:	a029                	j	80001586 <uvmcopy+0x2a>
    8000157e:	6785                	lui	a5,0x1
    80001580:	94be                	add	s1,s1,a5
    80001582:	0744fa63          	bgeu	s1,s4,800015f6 <uvmcopy+0x9a>
    if((pte = walk(old, i, 0)) == 0)
    80001586:	4601                	li	a2,0
    80001588:	85a6                	mv	a1,s1
    8000158a:	8556                	mv	a0,s5
    8000158c:	00000097          	auipc	ra,0x0
    80001590:	a6c080e7          	jalr	-1428(ra) # 80000ff8 <walk>
    80001594:	d56d                	beqz	a0,8000157e <uvmcopy+0x22>
      continue;
      // panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001596:	6118                	ld	a4,0(a0)
    80001598:	00177793          	andi	a5,a4,1
    8000159c:	d3ed                	beqz	a5,8000157e <uvmcopy+0x22>
      continue;
      // panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159e:	00a75593          	srli	a1,a4,0xa
    800015a2:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a6:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800015aa:	fffff097          	auipc	ra,0xfffff
    800015ae:	576080e7          	jalr	1398(ra) # 80000b20 <kalloc>
    800015b2:	89aa                	mv	s3,a0
    800015b4:	c515                	beqz	a0,800015e0 <uvmcopy+0x84>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b6:	6605                	lui	a2,0x1
    800015b8:	85de                	mv	a1,s7
    800015ba:	fffff097          	auipc	ra,0xfffff
    800015be:	7b2080e7          	jalr	1970(ra) # 80000d6c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c2:	874a                	mv	a4,s2
    800015c4:	86ce                	mv	a3,s3
    800015c6:	6605                	lui	a2,0x1
    800015c8:	85a6                	mv	a1,s1
    800015ca:	855a                	mv	a0,s6
    800015cc:	00000097          	auipc	ra,0x0
    800015d0:	b30080e7          	jalr	-1232(ra) # 800010fc <mappages>
    800015d4:	d54d                	beqz	a0,8000157e <uvmcopy+0x22>
      kfree(mem);
    800015d6:	854e                	mv	a0,s3
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	44c080e7          	jalr	1100(ra) # 80000a24 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015e0:	4685                	li	a3,1
    800015e2:	00c4d613          	srli	a2,s1,0xc
    800015e6:	4581                	li	a1,0
    800015e8:	855a                	mv	a0,s6
    800015ea:	00000097          	auipc	ra,0x0
    800015ee:	caa080e7          	jalr	-854(ra) # 80001294 <uvmunmap>
  return -1;
    800015f2:	557d                	li	a0,-1
    800015f4:	a011                	j	800015f8 <uvmcopy+0x9c>
  return 0;
    800015f6:	4501                	li	a0,0
}
    800015f8:	60a6                	ld	ra,72(sp)
    800015fa:	6406                	ld	s0,64(sp)
    800015fc:	74e2                	ld	s1,56(sp)
    800015fe:	7942                	ld	s2,48(sp)
    80001600:	79a2                	ld	s3,40(sp)
    80001602:	7a02                	ld	s4,32(sp)
    80001604:	6ae2                	ld	s5,24(sp)
    80001606:	6b42                	ld	s6,16(sp)
    80001608:	6ba2                	ld	s7,8(sp)
    8000160a:	6161                	addi	sp,sp,80
    8000160c:	8082                	ret
  return 0;
    8000160e:	4501                	li	a0,0
}
    80001610:	8082                	ret

0000000080001612 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001612:	1141                	addi	sp,sp,-16
    80001614:	e406                	sd	ra,8(sp)
    80001616:	e022                	sd	s0,0(sp)
    80001618:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000161a:	4601                	li	a2,0
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	9dc080e7          	jalr	-1572(ra) # 80000ff8 <walk>
  if(pte == 0)
    80001624:	c901                	beqz	a0,80001634 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001626:	611c                	ld	a5,0(a0)
    80001628:	9bbd                	andi	a5,a5,-17
    8000162a:	e11c                	sd	a5,0(a0)
}
    8000162c:	60a2                	ld	ra,8(sp)
    8000162e:	6402                	ld	s0,0(sp)
    80001630:	0141                	addi	sp,sp,16
    80001632:	8082                	ret
    panic("uvmclear");
    80001634:	00007517          	auipc	a0,0x7
    80001638:	b0c50513          	addi	a0,a0,-1268 # 80008140 <digits+0x100>
    8000163c:	fffff097          	auipc	ra,0xfffff
    80001640:	f0c080e7          	jalr	-244(ra) # 80000548 <panic>

0000000080001644 <lazy_alloc>:
    return -1;
  }
}

int
lazy_alloc(uint64 addr) {
    80001644:	7179                	addi	sp,sp,-48
    80001646:	f406                	sd	ra,40(sp)
    80001648:	f022                	sd	s0,32(sp)
    8000164a:	ec26                	sd	s1,24(sp)
    8000164c:	e84a                	sd	s2,16(sp)
    8000164e:	e44e                	sd	s3,8(sp)
    80001650:	1800                	addi	s0,sp,48
    80001652:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001654:	00000097          	auipc	ra,0x0
    80001658:	4be080e7          	jalr	1214(ra) # 80001b12 <myproc>
  // page-faults on a virtual memory address higher than any allocated with sbrk()
  // this should be >= not > !!!
  if (addr >= p->sz) {
    8000165c:	653c                	ld	a5,72(a0)
    8000165e:	04f4fe63          	bgeu	s1,a5,800016ba <lazy_alloc+0x76>
    80001662:	892a                	mv	s2,a0
    // printf("lazy_alloc: access invalid address");
    return -1;
  }

  if (addr < p->trapframe->sp) {
    80001664:	6d3c                	ld	a5,88(a0)
    80001666:	7b9c                	ld	a5,48(a5)
    80001668:	04f4eb63          	bltu	s1,a5,800016be <lazy_alloc+0x7a>
    // printf("lazy_alloc: access address below stack");
    return -2;
  }
  
  uint64 pa = PGROUNDDOWN(addr);
    8000166c:	757d                	lui	a0,0xfffff
    8000166e:	8ce9                	and	s1,s1,a0
  char* mem = kalloc();
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	4b0080e7          	jalr	1200(ra) # 80000b20 <kalloc>
    80001678:	89aa                	mv	s3,a0
  if (mem == 0) {
    8000167a:	c521                	beqz	a0,800016c2 <lazy_alloc+0x7e>
    // printf("lazy_alloc: kalloc failed");
    return -3;
  }
  
  memset(mem, 0, PGSIZE);
    8000167c:	6605                	lui	a2,0x1
    8000167e:	4581                	li	a1,0
    80001680:	fffff097          	auipc	ra,0xfffff
    80001684:	68c080e7          	jalr	1676(ra) # 80000d0c <memset>
  if(mappages(p->pagetable, pa, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001688:	4779                	li	a4,30
    8000168a:	86ce                	mv	a3,s3
    8000168c:	6605                	lui	a2,0x1
    8000168e:	85a6                	mv	a1,s1
    80001690:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001694:	00000097          	auipc	ra,0x0
    80001698:	a68080e7          	jalr	-1432(ra) # 800010fc <mappages>
    8000169c:	e901                	bnez	a0,800016ac <lazy_alloc+0x68>
    kfree(mem);
    return -4;
  }
  return 0;
}
    8000169e:	70a2                	ld	ra,40(sp)
    800016a0:	7402                	ld	s0,32(sp)
    800016a2:	64e2                	ld	s1,24(sp)
    800016a4:	6942                	ld	s2,16(sp)
    800016a6:	69a2                	ld	s3,8(sp)
    800016a8:	6145                	addi	sp,sp,48
    800016aa:	8082                	ret
    kfree(mem);
    800016ac:	854e                	mv	a0,s3
    800016ae:	fffff097          	auipc	ra,0xfffff
    800016b2:	376080e7          	jalr	886(ra) # 80000a24 <kfree>
    return -4;
    800016b6:	5571                	li	a0,-4
    800016b8:	b7dd                	j	8000169e <lazy_alloc+0x5a>
    return -1;
    800016ba:	557d                	li	a0,-1
    800016bc:	b7cd                	j	8000169e <lazy_alloc+0x5a>
    return -2;
    800016be:	5579                	li	a0,-2
    800016c0:	bff9                	j	8000169e <lazy_alloc+0x5a>
    return -3;
    800016c2:	5575                	li	a0,-3
    800016c4:	bfe9                	j	8000169e <lazy_alloc+0x5a>

00000000800016c6 <walkaddr>:
  if(va >= MAXVA)
    800016c6:	57fd                	li	a5,-1
    800016c8:	83e9                	srli	a5,a5,0x1a
    800016ca:	00b7f463          	bgeu	a5,a1,800016d2 <walkaddr+0xc>
    return 0;
    800016ce:	4501                	li	a0,0
}
    800016d0:	8082                	ret
{
    800016d2:	1101                	addi	sp,sp,-32
    800016d4:	ec06                	sd	ra,24(sp)
    800016d6:	e822                	sd	s0,16(sp)
    800016d8:	e426                	sd	s1,8(sp)
    800016da:	e04a                	sd	s2,0(sp)
    800016dc:	1000                	addi	s0,sp,32
    800016de:	892a                	mv	s2,a0
    800016e0:	84ae                	mv	s1,a1
  pte = walk(pagetable, va, 0);
    800016e2:	4601                	li	a2,0
    800016e4:	00000097          	auipc	ra,0x0
    800016e8:	914080e7          	jalr	-1772(ra) # 80000ff8 <walk>
  if(pte == 0 || (*pte & PTE_V) == 0) {
    800016ec:	c501                	beqz	a0,800016f4 <walkaddr+0x2e>
    800016ee:	611c                	ld	a5,0(a0)
    800016f0:	8b85                	andi	a5,a5,1
    800016f2:	e385                	bnez	a5,80001712 <walkaddr+0x4c>
    if (lazy_alloc(va) == 0) {
    800016f4:	8526                	mv	a0,s1
    800016f6:	00000097          	auipc	ra,0x0
    800016fa:	f4e080e7          	jalr	-178(ra) # 80001644 <lazy_alloc>
    800016fe:	87aa                	mv	a5,a0
      return 0;
    80001700:	4501                	li	a0,0
    if (lazy_alloc(va) == 0) {
    80001702:	ef99                	bnez	a5,80001720 <walkaddr+0x5a>
      pte = walk(pagetable, va, 0);
    80001704:	4601                	li	a2,0
    80001706:	85a6                	mv	a1,s1
    80001708:	854a                	mv	a0,s2
    8000170a:	00000097          	auipc	ra,0x0
    8000170e:	8ee080e7          	jalr	-1810(ra) # 80000ff8 <walk>
  if((*pte & PTE_U) == 0)
    80001712:	611c                	ld	a5,0(a0)
    80001714:	0107f513          	andi	a0,a5,16
    80001718:	c501                	beqz	a0,80001720 <walkaddr+0x5a>
  pa = PTE2PA(*pte);
    8000171a:	00a7d513          	srli	a0,a5,0xa
    8000171e:	0532                	slli	a0,a0,0xc
}
    80001720:	60e2                	ld	ra,24(sp)
    80001722:	6442                	ld	s0,16(sp)
    80001724:	64a2                	ld	s1,8(sp)
    80001726:	6902                	ld	s2,0(sp)
    80001728:	6105                	addi	sp,sp,32
    8000172a:	8082                	ret

000000008000172c <copyout>:
  while(len > 0){
    8000172c:	c6bd                	beqz	a3,8000179a <copyout+0x6e>
{
    8000172e:	715d                	addi	sp,sp,-80
    80001730:	e486                	sd	ra,72(sp)
    80001732:	e0a2                	sd	s0,64(sp)
    80001734:	fc26                	sd	s1,56(sp)
    80001736:	f84a                	sd	s2,48(sp)
    80001738:	f44e                	sd	s3,40(sp)
    8000173a:	f052                	sd	s4,32(sp)
    8000173c:	ec56                	sd	s5,24(sp)
    8000173e:	e85a                	sd	s6,16(sp)
    80001740:	e45e                	sd	s7,8(sp)
    80001742:	e062                	sd	s8,0(sp)
    80001744:	0880                	addi	s0,sp,80
    80001746:	8b2a                	mv	s6,a0
    80001748:	8c2e                	mv	s8,a1
    8000174a:	8a32                	mv	s4,a2
    8000174c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000174e:	7bfd                	lui	s7,0xfffff
    n = PGSIZE - (dstva - va0);
    80001750:	6a85                	lui	s5,0x1
    80001752:	a015                	j	80001776 <copyout+0x4a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001754:	9562                	add	a0,a0,s8
    80001756:	0004861b          	sext.w	a2,s1
    8000175a:	85d2                	mv	a1,s4
    8000175c:	41250533          	sub	a0,a0,s2
    80001760:	fffff097          	auipc	ra,0xfffff
    80001764:	60c080e7          	jalr	1548(ra) # 80000d6c <memmove>
    len -= n;
    80001768:	409989b3          	sub	s3,s3,s1
    src += n;
    8000176c:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000176e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001772:	02098263          	beqz	s3,80001796 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001776:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000177a:	85ca                	mv	a1,s2
    8000177c:	855a                	mv	a0,s6
    8000177e:	00000097          	auipc	ra,0x0
    80001782:	f48080e7          	jalr	-184(ra) # 800016c6 <walkaddr>
    if(pa0 == 0)
    80001786:	cd01                	beqz	a0,8000179e <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001788:	418904b3          	sub	s1,s2,s8
    8000178c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000178e:	fc99f3e3          	bgeu	s3,s1,80001754 <copyout+0x28>
    80001792:	84ce                	mv	s1,s3
    80001794:	b7c1                	j	80001754 <copyout+0x28>
  return 0;
    80001796:	4501                	li	a0,0
    80001798:	a021                	j	800017a0 <copyout+0x74>
    8000179a:	4501                	li	a0,0
}
    8000179c:	8082                	ret
      return -1;
    8000179e:	557d                	li	a0,-1
}
    800017a0:	60a6                	ld	ra,72(sp)
    800017a2:	6406                	ld	s0,64(sp)
    800017a4:	74e2                	ld	s1,56(sp)
    800017a6:	7942                	ld	s2,48(sp)
    800017a8:	79a2                	ld	s3,40(sp)
    800017aa:	7a02                	ld	s4,32(sp)
    800017ac:	6ae2                	ld	s5,24(sp)
    800017ae:	6b42                	ld	s6,16(sp)
    800017b0:	6ba2                	ld	s7,8(sp)
    800017b2:	6c02                	ld	s8,0(sp)
    800017b4:	6161                	addi	sp,sp,80
    800017b6:	8082                	ret

00000000800017b8 <copyin>:
  while(len > 0){
    800017b8:	c6bd                	beqz	a3,80001826 <copyin+0x6e>
{
    800017ba:	715d                	addi	sp,sp,-80
    800017bc:	e486                	sd	ra,72(sp)
    800017be:	e0a2                	sd	s0,64(sp)
    800017c0:	fc26                	sd	s1,56(sp)
    800017c2:	f84a                	sd	s2,48(sp)
    800017c4:	f44e                	sd	s3,40(sp)
    800017c6:	f052                	sd	s4,32(sp)
    800017c8:	ec56                	sd	s5,24(sp)
    800017ca:	e85a                	sd	s6,16(sp)
    800017cc:	e45e                	sd	s7,8(sp)
    800017ce:	e062                	sd	s8,0(sp)
    800017d0:	0880                	addi	s0,sp,80
    800017d2:	8b2a                	mv	s6,a0
    800017d4:	8a2e                	mv	s4,a1
    800017d6:	8c32                	mv	s8,a2
    800017d8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017da:	7bfd                	lui	s7,0xfffff
    n = PGSIZE - (srcva - va0);
    800017dc:	6a85                	lui	s5,0x1
    800017de:	a015                	j	80001802 <copyin+0x4a>
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017e0:	9562                	add	a0,a0,s8
    800017e2:	0004861b          	sext.w	a2,s1
    800017e6:	412505b3          	sub	a1,a0,s2
    800017ea:	8552                	mv	a0,s4
    800017ec:	fffff097          	auipc	ra,0xfffff
    800017f0:	580080e7          	jalr	1408(ra) # 80000d6c <memmove>
    len -= n;
    800017f4:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017f8:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017fa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017fe:	02098263          	beqz	s3,80001822 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001802:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001806:	85ca                	mv	a1,s2
    80001808:	855a                	mv	a0,s6
    8000180a:	00000097          	auipc	ra,0x0
    8000180e:	ebc080e7          	jalr	-324(ra) # 800016c6 <walkaddr>
    if(pa0 == 0)
    80001812:	cd01                	beqz	a0,8000182a <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001814:	418904b3          	sub	s1,s2,s8
    80001818:	94d6                	add	s1,s1,s5
    if(n > len)
    8000181a:	fc99f3e3          	bgeu	s3,s1,800017e0 <copyin+0x28>
    8000181e:	84ce                	mv	s1,s3
    80001820:	b7c1                	j	800017e0 <copyin+0x28>
  return 0;
    80001822:	4501                	li	a0,0
    80001824:	a021                	j	8000182c <copyin+0x74>
    80001826:	4501                	li	a0,0
}
    80001828:	8082                	ret
      return -1;
    8000182a:	557d                	li	a0,-1
}
    8000182c:	60a6                	ld	ra,72(sp)
    8000182e:	6406                	ld	s0,64(sp)
    80001830:	74e2                	ld	s1,56(sp)
    80001832:	7942                	ld	s2,48(sp)
    80001834:	79a2                	ld	s3,40(sp)
    80001836:	7a02                	ld	s4,32(sp)
    80001838:	6ae2                	ld	s5,24(sp)
    8000183a:	6b42                	ld	s6,16(sp)
    8000183c:	6ba2                	ld	s7,8(sp)
    8000183e:	6c02                	ld	s8,0(sp)
    80001840:	6161                	addi	sp,sp,80
    80001842:	8082                	ret

0000000080001844 <copyinstr>:
  while(got_null == 0 && max > 0){
    80001844:	c6c5                	beqz	a3,800018ec <copyinstr+0xa8>
{
    80001846:	715d                	addi	sp,sp,-80
    80001848:	e486                	sd	ra,72(sp)
    8000184a:	e0a2                	sd	s0,64(sp)
    8000184c:	fc26                	sd	s1,56(sp)
    8000184e:	f84a                	sd	s2,48(sp)
    80001850:	f44e                	sd	s3,40(sp)
    80001852:	f052                	sd	s4,32(sp)
    80001854:	ec56                	sd	s5,24(sp)
    80001856:	e85a                	sd	s6,16(sp)
    80001858:	e45e                	sd	s7,8(sp)
    8000185a:	0880                	addi	s0,sp,80
    8000185c:	8a2a                	mv	s4,a0
    8000185e:	8b2e                	mv	s6,a1
    80001860:	8bb2                	mv	s7,a2
    80001862:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001864:	7afd                	lui	s5,0xfffff
    n = PGSIZE - (srcva - va0);
    80001866:	6985                	lui	s3,0x1
    80001868:	a035                	j	80001894 <copyinstr+0x50>
        *dst = '\0';
    8000186a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000186e:	4785                	li	a5,1
  if(got_null){
    80001870:	0017b793          	seqz	a5,a5
    80001874:	40f00533          	neg	a0,a5
}
    80001878:	60a6                	ld	ra,72(sp)
    8000187a:	6406                	ld	s0,64(sp)
    8000187c:	74e2                	ld	s1,56(sp)
    8000187e:	7942                	ld	s2,48(sp)
    80001880:	79a2                	ld	s3,40(sp)
    80001882:	7a02                	ld	s4,32(sp)
    80001884:	6ae2                	ld	s5,24(sp)
    80001886:	6b42                	ld	s6,16(sp)
    80001888:	6ba2                	ld	s7,8(sp)
    8000188a:	6161                	addi	sp,sp,80
    8000188c:	8082                	ret
    srcva = va0 + PGSIZE;
    8000188e:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001892:	c8a9                	beqz	s1,800018e4 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001894:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001898:	85ca                	mv	a1,s2
    8000189a:	8552                	mv	a0,s4
    8000189c:	00000097          	auipc	ra,0x0
    800018a0:	e2a080e7          	jalr	-470(ra) # 800016c6 <walkaddr>
    if(pa0 == 0){
    800018a4:	c131                	beqz	a0,800018e8 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018a6:	41790833          	sub	a6,s2,s7
    800018aa:	984e                	add	a6,a6,s3
    if(n > max)
    800018ac:	0104f363          	bgeu	s1,a6,800018b2 <copyinstr+0x6e>
    800018b0:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018b2:	955e                	add	a0,a0,s7
    800018b4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018b8:	fc080be3          	beqz	a6,8000188e <copyinstr+0x4a>
    800018bc:	985a                	add	a6,a6,s6
    800018be:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018c0:	41650633          	sub	a2,a0,s6
    800018c4:	14fd                	addi	s1,s1,-1
    800018c6:	9b26                	add	s6,s6,s1
    800018c8:	00f60733          	add	a4,a2,a5
    800018cc:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800018d0:	df49                	beqz	a4,8000186a <copyinstr+0x26>
        *dst = *p;
    800018d2:	00e78023          	sb	a4,0(a5)
      --max;
    800018d6:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018da:	0785                	addi	a5,a5,1
    while(n > 0){
    800018dc:	ff0796e3          	bne	a5,a6,800018c8 <copyinstr+0x84>
      dst++;
    800018e0:	8b42                	mv	s6,a6
    800018e2:	b775                	j	8000188e <copyinstr+0x4a>
    800018e4:	4781                	li	a5,0
    800018e6:	b769                	j	80001870 <copyinstr+0x2c>
      return -1;
    800018e8:	557d                	li	a0,-1
    800018ea:	b779                	j	80001878 <copyinstr+0x34>
  int got_null = 0;
    800018ec:	4781                	li	a5,0
  if(got_null){
    800018ee:	0017b793          	seqz	a5,a5
    800018f2:	40f00533          	neg	a0,a5
}
    800018f6:	8082                	ret

00000000800018f8 <printwalk>:

void printwalk(pagetable_t pagetable, uint level) {
    800018f8:	715d                	addi	sp,sp,-80
    800018fa:	e486                	sd	ra,72(sp)
    800018fc:	e0a2                	sd	s0,64(sp)
    800018fe:	fc26                	sd	s1,56(sp)
    80001900:	f84a                	sd	s2,48(sp)
    80001902:	f44e                	sd	s3,40(sp)
    80001904:	f052                	sd	s4,32(sp)
    80001906:	ec56                	sd	s5,24(sp)
    80001908:	e85a                	sd	s6,16(sp)
    8000190a:	e45e                	sd	s7,8(sp)
    8000190c:	e062                	sd	s8,0(sp)
    8000190e:	0880                	addi	s0,sp,80
    80001910:	89aa                	mv	s3,a0
  char* prefix;
  if (level == 2) prefix = "..";
    80001912:	4789                	li	a5,2
    80001914:	00007b17          	auipc	s6,0x7
    80001918:	83cb0b13          	addi	s6,s6,-1988 # 80008150 <digits+0x110>
    8000191c:	00f58d63          	beq	a1,a5,80001936 <printwalk+0x3e>
  else if (level == 1) prefix = ".. ..";
    80001920:	4785                	li	a5,1
    80001922:	00007b17          	auipc	s6,0x7
    80001926:	836b0b13          	addi	s6,s6,-1994 # 80008158 <digits+0x118>
    8000192a:	00f58663          	beq	a1,a5,80001936 <printwalk+0x3e>
  else prefix = ".. .. ..";
    8000192e:	00007b17          	auipc	s6,0x7
    80001932:	832b0b13          	addi	s6,s6,-1998 # 80008160 <digits+0x120>

  for(int i = 0; i < 512; i++){
    80001936:	4901                	li	s2,0
    pte_t pte = pagetable[i];
    if(pte & PTE_V){
      uint64 pa = PTE2PA(pte);
      printf("%s%d: pte %p pa %p\n", prefix, i, pte, pa);
    80001938:	00007b97          	auipc	s7,0x7
    8000193c:	838b8b93          	addi	s7,s7,-1992 # 80008170 <digits+0x130>
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0){
        printwalk((pagetable_t)pa, level - 1);
    80001940:	fff58c1b          	addiw	s8,a1,-1
  for(int i = 0; i < 512; i++){
    80001944:	20000a93          	li	s5,512
    80001948:	a819                	j	8000195e <printwalk+0x66>
        printwalk((pagetable_t)pa, level - 1);
    8000194a:	85e2                	mv	a1,s8
    8000194c:	8552                	mv	a0,s4
    8000194e:	00000097          	auipc	ra,0x0
    80001952:	faa080e7          	jalr	-86(ra) # 800018f8 <printwalk>
  for(int i = 0; i < 512; i++){
    80001956:	2905                	addiw	s2,s2,1
    80001958:	09a1                	addi	s3,s3,8
    8000195a:	03590663          	beq	s2,s5,80001986 <printwalk+0x8e>
    pte_t pte = pagetable[i];
    8000195e:	0009b483          	ld	s1,0(s3) # 1000 <_entry-0x7ffff000>
    if(pte & PTE_V){
    80001962:	0014f793          	andi	a5,s1,1
    80001966:	dbe5                	beqz	a5,80001956 <printwalk+0x5e>
      uint64 pa = PTE2PA(pte);
    80001968:	00a4da13          	srli	s4,s1,0xa
    8000196c:	0a32                	slli	s4,s4,0xc
      printf("%s%d: pte %p pa %p\n", prefix, i, pte, pa);
    8000196e:	8752                	mv	a4,s4
    80001970:	86a6                	mv	a3,s1
    80001972:	864a                	mv	a2,s2
    80001974:	85da                	mv	a1,s6
    80001976:	855e                	mv	a0,s7
    80001978:	fffff097          	auipc	ra,0xfffff
    8000197c:	c1a080e7          	jalr	-998(ra) # 80000592 <printf>
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001980:	88b9                	andi	s1,s1,14
    80001982:	f8f1                	bnez	s1,80001956 <printwalk+0x5e>
    80001984:	b7d9                	j	8000194a <printwalk+0x52>
      }
    }
  }
}
    80001986:	60a6                	ld	ra,72(sp)
    80001988:	6406                	ld	s0,64(sp)
    8000198a:	74e2                	ld	s1,56(sp)
    8000198c:	7942                	ld	s2,48(sp)
    8000198e:	79a2                	ld	s3,40(sp)
    80001990:	7a02                	ld	s4,32(sp)
    80001992:	6ae2                	ld	s5,24(sp)
    80001994:	6b42                	ld	s6,16(sp)
    80001996:	6ba2                	ld	s7,8(sp)
    80001998:	6c02                	ld	s8,0(sp)
    8000199a:	6161                	addi	sp,sp,80
    8000199c:	8082                	ret

000000008000199e <vmprint>:

void
vmprint(pagetable_t pagetable) {
    8000199e:	1101                	addi	sp,sp,-32
    800019a0:	ec06                	sd	ra,24(sp)
    800019a2:	e822                	sd	s0,16(sp)
    800019a4:	e426                	sd	s1,8(sp)
    800019a6:	1000                	addi	s0,sp,32
    800019a8:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    800019aa:	85aa                	mv	a1,a0
    800019ac:	00006517          	auipc	a0,0x6
    800019b0:	7dc50513          	addi	a0,a0,2012 # 80008188 <digits+0x148>
    800019b4:	fffff097          	auipc	ra,0xfffff
    800019b8:	bde080e7          	jalr	-1058(ra) # 80000592 <printf>
  printwalk(pagetable, 2);
    800019bc:	4589                	li	a1,2
    800019be:	8526                	mv	a0,s1
    800019c0:	00000097          	auipc	ra,0x0
    800019c4:	f38080e7          	jalr	-200(ra) # 800018f8 <printwalk>
}
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6105                	addi	sp,sp,32
    800019d0:	8082                	ret

00000000800019d2 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800019d2:	1101                	addi	sp,sp,-32
    800019d4:	ec06                	sd	ra,24(sp)
    800019d6:	e822                	sd	s0,16(sp)
    800019d8:	e426                	sd	s1,8(sp)
    800019da:	1000                	addi	s0,sp,32
    800019dc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	1b8080e7          	jalr	440(ra) # 80000b96 <holding>
    800019e6:	c909                	beqz	a0,800019f8 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800019e8:	749c                	ld	a5,40(s1)
    800019ea:	00978f63          	beq	a5,s1,80001a08 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800019ee:	60e2                	ld	ra,24(sp)
    800019f0:	6442                	ld	s0,16(sp)
    800019f2:	64a2                	ld	s1,8(sp)
    800019f4:	6105                	addi	sp,sp,32
    800019f6:	8082                	ret
    panic("wakeup1");
    800019f8:	00006517          	auipc	a0,0x6
    800019fc:	7a050513          	addi	a0,a0,1952 # 80008198 <digits+0x158>
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	b48080e7          	jalr	-1208(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a08:	4c98                	lw	a4,24(s1)
    80001a0a:	4785                	li	a5,1
    80001a0c:	fef711e3          	bne	a4,a5,800019ee <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a10:	4789                	li	a5,2
    80001a12:	cc9c                	sw	a5,24(s1)
}
    80001a14:	bfe9                	j	800019ee <wakeup1+0x1c>

0000000080001a16 <procinit>:
{
    80001a16:	715d                	addi	sp,sp,-80
    80001a18:	e486                	sd	ra,72(sp)
    80001a1a:	e0a2                	sd	s0,64(sp)
    80001a1c:	fc26                	sd	s1,56(sp)
    80001a1e:	f84a                	sd	s2,48(sp)
    80001a20:	f44e                	sd	s3,40(sp)
    80001a22:	f052                	sd	s4,32(sp)
    80001a24:	ec56                	sd	s5,24(sp)
    80001a26:	e85a                	sd	s6,16(sp)
    80001a28:	e45e                	sd	s7,8(sp)
    80001a2a:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001a2c:	00006597          	auipc	a1,0x6
    80001a30:	77458593          	addi	a1,a1,1908 # 800081a0 <digits+0x160>
    80001a34:	00010517          	auipc	a0,0x10
    80001a38:	f1c50513          	addi	a0,a0,-228 # 80011950 <pid_lock>
    80001a3c:	fffff097          	auipc	ra,0xfffff
    80001a40:	144080e7          	jalr	324(ra) # 80000b80 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a44:	00010917          	auipc	s2,0x10
    80001a48:	32490913          	addi	s2,s2,804 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001a4c:	00006b97          	auipc	s7,0x6
    80001a50:	75cb8b93          	addi	s7,s7,1884 # 800081a8 <digits+0x168>
      uint64 va = KSTACK((int) (p - proc));
    80001a54:	8b4a                	mv	s6,s2
    80001a56:	00006a97          	auipc	s5,0x6
    80001a5a:	5aaa8a93          	addi	s5,s5,1450 # 80008000 <etext>
    80001a5e:	040009b7          	lui	s3,0x4000
    80001a62:	19fd                	addi	s3,s3,-1
    80001a64:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a66:	00016a17          	auipc	s4,0x16
    80001a6a:	d02a0a13          	addi	s4,s4,-766 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    80001a6e:	85de                	mv	a1,s7
    80001a70:	854a                	mv	a0,s2
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	10e080e7          	jalr	270(ra) # 80000b80 <initlock>
      char *pa = kalloc();
    80001a7a:	fffff097          	auipc	ra,0xfffff
    80001a7e:	0a6080e7          	jalr	166(ra) # 80000b20 <kalloc>
    80001a82:	85aa                	mv	a1,a0
      if(pa == 0)
    80001a84:	c929                	beqz	a0,80001ad6 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001a86:	416904b3          	sub	s1,s2,s6
    80001a8a:	848d                	srai	s1,s1,0x3
    80001a8c:	000ab783          	ld	a5,0(s5)
    80001a90:	02f484b3          	mul	s1,s1,a5
    80001a94:	2485                	addiw	s1,s1,1
    80001a96:	00d4949b          	slliw	s1,s1,0xd
    80001a9a:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a9e:	4699                	li	a3,6
    80001aa0:	6605                	lui	a2,0x1
    80001aa2:	8526                	mv	a0,s1
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	6e6080e7          	jalr	1766(ra) # 8000118a <kvmmap>
      p->kstack = va;
    80001aac:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab0:	16890913          	addi	s2,s2,360
    80001ab4:	fb491de3          	bne	s2,s4,80001a6e <procinit+0x58>
  kvminithart();
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	51c080e7          	jalr	1308(ra) # 80000fd4 <kvminithart>
}
    80001ac0:	60a6                	ld	ra,72(sp)
    80001ac2:	6406                	ld	s0,64(sp)
    80001ac4:	74e2                	ld	s1,56(sp)
    80001ac6:	7942                	ld	s2,48(sp)
    80001ac8:	79a2                	ld	s3,40(sp)
    80001aca:	7a02                	ld	s4,32(sp)
    80001acc:	6ae2                	ld	s5,24(sp)
    80001ace:	6b42                	ld	s6,16(sp)
    80001ad0:	6ba2                	ld	s7,8(sp)
    80001ad2:	6161                	addi	sp,sp,80
    80001ad4:	8082                	ret
        panic("kalloc");
    80001ad6:	00006517          	auipc	a0,0x6
    80001ada:	6da50513          	addi	a0,a0,1754 # 800081b0 <digits+0x170>
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	a6a080e7          	jalr	-1430(ra) # 80000548 <panic>

0000000080001ae6 <cpuid>:
{
    80001ae6:	1141                	addi	sp,sp,-16
    80001ae8:	e422                	sd	s0,8(sp)
    80001aea:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001aec:	8512                	mv	a0,tp
}
    80001aee:	2501                	sext.w	a0,a0
    80001af0:	6422                	ld	s0,8(sp)
    80001af2:	0141                	addi	sp,sp,16
    80001af4:	8082                	ret

0000000080001af6 <mycpu>:
mycpu(void) {
    80001af6:	1141                	addi	sp,sp,-16
    80001af8:	e422                	sd	s0,8(sp)
    80001afa:	0800                	addi	s0,sp,16
    80001afc:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001afe:	2781                	sext.w	a5,a5
    80001b00:	079e                	slli	a5,a5,0x7
}
    80001b02:	00010517          	auipc	a0,0x10
    80001b06:	e6650513          	addi	a0,a0,-410 # 80011968 <cpus>
    80001b0a:	953e                	add	a0,a0,a5
    80001b0c:	6422                	ld	s0,8(sp)
    80001b0e:	0141                	addi	sp,sp,16
    80001b10:	8082                	ret

0000000080001b12 <myproc>:
myproc(void) {
    80001b12:	1101                	addi	sp,sp,-32
    80001b14:	ec06                	sd	ra,24(sp)
    80001b16:	e822                	sd	s0,16(sp)
    80001b18:	e426                	sd	s1,8(sp)
    80001b1a:	1000                	addi	s0,sp,32
  push_off();
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	0a8080e7          	jalr	168(ra) # 80000bc4 <push_off>
    80001b24:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b26:	2781                	sext.w	a5,a5
    80001b28:	079e                	slli	a5,a5,0x7
    80001b2a:	00010717          	auipc	a4,0x10
    80001b2e:	e2670713          	addi	a4,a4,-474 # 80011950 <pid_lock>
    80001b32:	97ba                	add	a5,a5,a4
    80001b34:	6f84                	ld	s1,24(a5)
  pop_off();
    80001b36:	fffff097          	auipc	ra,0xfffff
    80001b3a:	12e080e7          	jalr	302(ra) # 80000c64 <pop_off>
}
    80001b3e:	8526                	mv	a0,s1
    80001b40:	60e2                	ld	ra,24(sp)
    80001b42:	6442                	ld	s0,16(sp)
    80001b44:	64a2                	ld	s1,8(sp)
    80001b46:	6105                	addi	sp,sp,32
    80001b48:	8082                	ret

0000000080001b4a <forkret>:
{
    80001b4a:	1141                	addi	sp,sp,-16
    80001b4c:	e406                	sd	ra,8(sp)
    80001b4e:	e022                	sd	s0,0(sp)
    80001b50:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	fc0080e7          	jalr	-64(ra) # 80001b12 <myproc>
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	16a080e7          	jalr	362(ra) # 80000cc4 <release>
  if (first) {
    80001b62:	00007797          	auipc	a5,0x7
    80001b66:	c8e7a783          	lw	a5,-882(a5) # 800087f0 <first.1666>
    80001b6a:	eb89                	bnez	a5,80001b7c <forkret+0x32>
  usertrapret();
    80001b6c:	00001097          	auipc	ra,0x1
    80001b70:	c1c080e7          	jalr	-996(ra) # 80002788 <usertrapret>
}
    80001b74:	60a2                	ld	ra,8(sp)
    80001b76:	6402                	ld	s0,0(sp)
    80001b78:	0141                	addi	sp,sp,16
    80001b7a:	8082                	ret
    first = 0;
    80001b7c:	00007797          	auipc	a5,0x7
    80001b80:	c607aa23          	sw	zero,-908(a5) # 800087f0 <first.1666>
    fsinit(ROOTDEV);
    80001b84:	4505                	li	a0,1
    80001b86:	00002097          	auipc	ra,0x2
    80001b8a:	982080e7          	jalr	-1662(ra) # 80003508 <fsinit>
    80001b8e:	bff9                	j	80001b6c <forkret+0x22>

0000000080001b90 <allocpid>:
allocpid() {
    80001b90:	1101                	addi	sp,sp,-32
    80001b92:	ec06                	sd	ra,24(sp)
    80001b94:	e822                	sd	s0,16(sp)
    80001b96:	e426                	sd	s1,8(sp)
    80001b98:	e04a                	sd	s2,0(sp)
    80001b9a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b9c:	00010917          	auipc	s2,0x10
    80001ba0:	db490913          	addi	s2,s2,-588 # 80011950 <pid_lock>
    80001ba4:	854a                	mv	a0,s2
    80001ba6:	fffff097          	auipc	ra,0xfffff
    80001baa:	06a080e7          	jalr	106(ra) # 80000c10 <acquire>
  pid = nextpid;
    80001bae:	00007797          	auipc	a5,0x7
    80001bb2:	c4678793          	addi	a5,a5,-954 # 800087f4 <nextpid>
    80001bb6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bb8:	0014871b          	addiw	a4,s1,1
    80001bbc:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bbe:	854a                	mv	a0,s2
    80001bc0:	fffff097          	auipc	ra,0xfffff
    80001bc4:	104080e7          	jalr	260(ra) # 80000cc4 <release>
}
    80001bc8:	8526                	mv	a0,s1
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6902                	ld	s2,0(sp)
    80001bd2:	6105                	addi	sp,sp,32
    80001bd4:	8082                	ret

0000000080001bd6 <proc_pagetable>:
{
    80001bd6:	1101                	addi	sp,sp,-32
    80001bd8:	ec06                	sd	ra,24(sp)
    80001bda:	e822                	sd	s0,16(sp)
    80001bdc:	e426                	sd	s1,8(sp)
    80001bde:	e04a                	sd	s2,0(sp)
    80001be0:	1000                	addi	s0,sp,32
    80001be2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	756080e7          	jalr	1878(ra) # 8000133a <uvmcreate>
    80001bec:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bee:	c121                	beqz	a0,80001c2e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bf0:	4729                	li	a4,10
    80001bf2:	00005697          	auipc	a3,0x5
    80001bf6:	40e68693          	addi	a3,a3,1038 # 80007000 <_trampoline>
    80001bfa:	6605                	lui	a2,0x1
    80001bfc:	040005b7          	lui	a1,0x4000
    80001c00:	15fd                	addi	a1,a1,-1
    80001c02:	05b2                	slli	a1,a1,0xc
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	4f8080e7          	jalr	1272(ra) # 800010fc <mappages>
    80001c0c:	02054863          	bltz	a0,80001c3c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c10:	4719                	li	a4,6
    80001c12:	05893683          	ld	a3,88(s2)
    80001c16:	6605                	lui	a2,0x1
    80001c18:	020005b7          	lui	a1,0x2000
    80001c1c:	15fd                	addi	a1,a1,-1
    80001c1e:	05b6                	slli	a1,a1,0xd
    80001c20:	8526                	mv	a0,s1
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	4da080e7          	jalr	1242(ra) # 800010fc <mappages>
    80001c2a:	02054163          	bltz	a0,80001c4c <proc_pagetable+0x76>
}
    80001c2e:	8526                	mv	a0,s1
    80001c30:	60e2                	ld	ra,24(sp)
    80001c32:	6442                	ld	s0,16(sp)
    80001c34:	64a2                	ld	s1,8(sp)
    80001c36:	6902                	ld	s2,0(sp)
    80001c38:	6105                	addi	sp,sp,32
    80001c3a:	8082                	ret
    uvmfree(pagetable, 0);
    80001c3c:	4581                	li	a1,0
    80001c3e:	8526                	mv	a0,s1
    80001c40:	00000097          	auipc	ra,0x0
    80001c44:	8e4080e7          	jalr	-1820(ra) # 80001524 <uvmfree>
    return 0;
    80001c48:	4481                	li	s1,0
    80001c4a:	b7d5                	j	80001c2e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c4c:	4681                	li	a3,0
    80001c4e:	4605                	li	a2,1
    80001c50:	040005b7          	lui	a1,0x4000
    80001c54:	15fd                	addi	a1,a1,-1
    80001c56:	05b2                	slli	a1,a1,0xc
    80001c58:	8526                	mv	a0,s1
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	63a080e7          	jalr	1594(ra) # 80001294 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c62:	4581                	li	a1,0
    80001c64:	8526                	mv	a0,s1
    80001c66:	00000097          	auipc	ra,0x0
    80001c6a:	8be080e7          	jalr	-1858(ra) # 80001524 <uvmfree>
    return 0;
    80001c6e:	4481                	li	s1,0
    80001c70:	bf7d                	j	80001c2e <proc_pagetable+0x58>

0000000080001c72 <proc_freepagetable>:
{
    80001c72:	1101                	addi	sp,sp,-32
    80001c74:	ec06                	sd	ra,24(sp)
    80001c76:	e822                	sd	s0,16(sp)
    80001c78:	e426                	sd	s1,8(sp)
    80001c7a:	e04a                	sd	s2,0(sp)
    80001c7c:	1000                	addi	s0,sp,32
    80001c7e:	84aa                	mv	s1,a0
    80001c80:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c82:	4681                	li	a3,0
    80001c84:	4605                	li	a2,1
    80001c86:	040005b7          	lui	a1,0x4000
    80001c8a:	15fd                	addi	a1,a1,-1
    80001c8c:	05b2                	slli	a1,a1,0xc
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	606080e7          	jalr	1542(ra) # 80001294 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c96:	4681                	li	a3,0
    80001c98:	4605                	li	a2,1
    80001c9a:	020005b7          	lui	a1,0x2000
    80001c9e:	15fd                	addi	a1,a1,-1
    80001ca0:	05b6                	slli	a1,a1,0xd
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	5f0080e7          	jalr	1520(ra) # 80001294 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cac:	85ca                	mv	a1,s2
    80001cae:	8526                	mv	a0,s1
    80001cb0:	00000097          	auipc	ra,0x0
    80001cb4:	874080e7          	jalr	-1932(ra) # 80001524 <uvmfree>
}
    80001cb8:	60e2                	ld	ra,24(sp)
    80001cba:	6442                	ld	s0,16(sp)
    80001cbc:	64a2                	ld	s1,8(sp)
    80001cbe:	6902                	ld	s2,0(sp)
    80001cc0:	6105                	addi	sp,sp,32
    80001cc2:	8082                	ret

0000000080001cc4 <freeproc>:
{
    80001cc4:	1101                	addi	sp,sp,-32
    80001cc6:	ec06                	sd	ra,24(sp)
    80001cc8:	e822                	sd	s0,16(sp)
    80001cca:	e426                	sd	s1,8(sp)
    80001ccc:	1000                	addi	s0,sp,32
    80001cce:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cd0:	6d28                	ld	a0,88(a0)
    80001cd2:	c509                	beqz	a0,80001cdc <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	d50080e7          	jalr	-688(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001cdc:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ce0:	68a8                	ld	a0,80(s1)
    80001ce2:	c511                	beqz	a0,80001cee <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ce4:	64ac                	ld	a1,72(s1)
    80001ce6:	00000097          	auipc	ra,0x0
    80001cea:	f8c080e7          	jalr	-116(ra) # 80001c72 <proc_freepagetable>
  p->pagetable = 0;
    80001cee:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cf2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cf6:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001cfa:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001cfe:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d02:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001d06:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001d0a:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001d0e:	0004ac23          	sw	zero,24(s1)
}
    80001d12:	60e2                	ld	ra,24(sp)
    80001d14:	6442                	ld	s0,16(sp)
    80001d16:	64a2                	ld	s1,8(sp)
    80001d18:	6105                	addi	sp,sp,32
    80001d1a:	8082                	ret

0000000080001d1c <allocproc>:
{
    80001d1c:	1101                	addi	sp,sp,-32
    80001d1e:	ec06                	sd	ra,24(sp)
    80001d20:	e822                	sd	s0,16(sp)
    80001d22:	e426                	sd	s1,8(sp)
    80001d24:	e04a                	sd	s2,0(sp)
    80001d26:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d28:	00010497          	auipc	s1,0x10
    80001d2c:	04048493          	addi	s1,s1,64 # 80011d68 <proc>
    80001d30:	00016917          	auipc	s2,0x16
    80001d34:	a3890913          	addi	s2,s2,-1480 # 80017768 <tickslock>
    acquire(&p->lock);
    80001d38:	8526                	mv	a0,s1
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	ed6080e7          	jalr	-298(ra) # 80000c10 <acquire>
    if(p->state == UNUSED) {
    80001d42:	4c9c                	lw	a5,24(s1)
    80001d44:	cf81                	beqz	a5,80001d5c <allocproc+0x40>
      release(&p->lock);
    80001d46:	8526                	mv	a0,s1
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	f7c080e7          	jalr	-132(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d50:	16848493          	addi	s1,s1,360
    80001d54:	ff2492e3          	bne	s1,s2,80001d38 <allocproc+0x1c>
  return 0;
    80001d58:	4481                	li	s1,0
    80001d5a:	a0b9                	j	80001da8 <allocproc+0x8c>
  p->pid = allocpid();
    80001d5c:	00000097          	auipc	ra,0x0
    80001d60:	e34080e7          	jalr	-460(ra) # 80001b90 <allocpid>
    80001d64:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d66:	fffff097          	auipc	ra,0xfffff
    80001d6a:	dba080e7          	jalr	-582(ra) # 80000b20 <kalloc>
    80001d6e:	892a                	mv	s2,a0
    80001d70:	eca8                	sd	a0,88(s1)
    80001d72:	c131                	beqz	a0,80001db6 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001d74:	8526                	mv	a0,s1
    80001d76:	00000097          	auipc	ra,0x0
    80001d7a:	e60080e7          	jalr	-416(ra) # 80001bd6 <proc_pagetable>
    80001d7e:	892a                	mv	s2,a0
    80001d80:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d82:	c129                	beqz	a0,80001dc4 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001d84:	07000613          	li	a2,112
    80001d88:	4581                	li	a1,0
    80001d8a:	06048513          	addi	a0,s1,96
    80001d8e:	fffff097          	auipc	ra,0xfffff
    80001d92:	f7e080e7          	jalr	-130(ra) # 80000d0c <memset>
  p->context.ra = (uint64)forkret;
    80001d96:	00000797          	auipc	a5,0x0
    80001d9a:	db478793          	addi	a5,a5,-588 # 80001b4a <forkret>
    80001d9e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001da0:	60bc                	ld	a5,64(s1)
    80001da2:	6705                	lui	a4,0x1
    80001da4:	97ba                	add	a5,a5,a4
    80001da6:	f4bc                	sd	a5,104(s1)
}
    80001da8:	8526                	mv	a0,s1
    80001daa:	60e2                	ld	ra,24(sp)
    80001dac:	6442                	ld	s0,16(sp)
    80001dae:	64a2                	ld	s1,8(sp)
    80001db0:	6902                	ld	s2,0(sp)
    80001db2:	6105                	addi	sp,sp,32
    80001db4:	8082                	ret
    release(&p->lock);
    80001db6:	8526                	mv	a0,s1
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	f0c080e7          	jalr	-244(ra) # 80000cc4 <release>
    return 0;
    80001dc0:	84ca                	mv	s1,s2
    80001dc2:	b7dd                	j	80001da8 <allocproc+0x8c>
    freeproc(p);
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	00000097          	auipc	ra,0x0
    80001dca:	efe080e7          	jalr	-258(ra) # 80001cc4 <freeproc>
    release(&p->lock);
    80001dce:	8526                	mv	a0,s1
    80001dd0:	fffff097          	auipc	ra,0xfffff
    80001dd4:	ef4080e7          	jalr	-268(ra) # 80000cc4 <release>
    return 0;
    80001dd8:	84ca                	mv	s1,s2
    80001dda:	b7f9                	j	80001da8 <allocproc+0x8c>

0000000080001ddc <userinit>:
{
    80001ddc:	1101                	addi	sp,sp,-32
    80001dde:	ec06                	sd	ra,24(sp)
    80001de0:	e822                	sd	s0,16(sp)
    80001de2:	e426                	sd	s1,8(sp)
    80001de4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001de6:	00000097          	auipc	ra,0x0
    80001dea:	f36080e7          	jalr	-202(ra) # 80001d1c <allocproc>
    80001dee:	84aa                	mv	s1,a0
  initproc = p;
    80001df0:	00007797          	auipc	a5,0x7
    80001df4:	22a7b423          	sd	a0,552(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001df8:	03400613          	li	a2,52
    80001dfc:	00007597          	auipc	a1,0x7
    80001e00:	a0458593          	addi	a1,a1,-1532 # 80008800 <initcode>
    80001e04:	6928                	ld	a0,80(a0)
    80001e06:	fffff097          	auipc	ra,0xfffff
    80001e0a:	562080e7          	jalr	1378(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    80001e0e:	6785                	lui	a5,0x1
    80001e10:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e12:	6cb8                	ld	a4,88(s1)
    80001e14:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e18:	6cb8                	ld	a4,88(s1)
    80001e1a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e1c:	4641                	li	a2,16
    80001e1e:	00006597          	auipc	a1,0x6
    80001e22:	39a58593          	addi	a1,a1,922 # 800081b8 <digits+0x178>
    80001e26:	15848513          	addi	a0,s1,344
    80001e2a:	fffff097          	auipc	ra,0xfffff
    80001e2e:	038080e7          	jalr	56(ra) # 80000e62 <safestrcpy>
  p->cwd = namei("/");
    80001e32:	00006517          	auipc	a0,0x6
    80001e36:	39650513          	addi	a0,a0,918 # 800081c8 <digits+0x188>
    80001e3a:	00002097          	auipc	ra,0x2
    80001e3e:	0fa080e7          	jalr	250(ra) # 80003f34 <namei>
    80001e42:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e46:	4789                	li	a5,2
    80001e48:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	e78080e7          	jalr	-392(ra) # 80000cc4 <release>
}
    80001e54:	60e2                	ld	ra,24(sp)
    80001e56:	6442                	ld	s0,16(sp)
    80001e58:	64a2                	ld	s1,8(sp)
    80001e5a:	6105                	addi	sp,sp,32
    80001e5c:	8082                	ret

0000000080001e5e <growproc>:
{
    80001e5e:	1101                	addi	sp,sp,-32
    80001e60:	ec06                	sd	ra,24(sp)
    80001e62:	e822                	sd	s0,16(sp)
    80001e64:	e426                	sd	s1,8(sp)
    80001e66:	e04a                	sd	s2,0(sp)
    80001e68:	1000                	addi	s0,sp,32
    80001e6a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e6c:	00000097          	auipc	ra,0x0
    80001e70:	ca6080e7          	jalr	-858(ra) # 80001b12 <myproc>
    80001e74:	892a                	mv	s2,a0
  sz = p->sz;
    80001e76:	652c                	ld	a1,72(a0)
    80001e78:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e7c:	00904f63          	bgtz	s1,80001e9a <growproc+0x3c>
  } else if(n < 0){
    80001e80:	0204cc63          	bltz	s1,80001eb8 <growproc+0x5a>
  p->sz = sz;
    80001e84:	1602                	slli	a2,a2,0x20
    80001e86:	9201                	srli	a2,a2,0x20
    80001e88:	04c93423          	sd	a2,72(s2)
  return 0;
    80001e8c:	4501                	li	a0,0
}
    80001e8e:	60e2                	ld	ra,24(sp)
    80001e90:	6442                	ld	s0,16(sp)
    80001e92:	64a2                	ld	s1,8(sp)
    80001e94:	6902                	ld	s2,0(sp)
    80001e96:	6105                	addi	sp,sp,32
    80001e98:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e9a:	9e25                	addw	a2,a2,s1
    80001e9c:	1602                	slli	a2,a2,0x20
    80001e9e:	9201                	srli	a2,a2,0x20
    80001ea0:	1582                	slli	a1,a1,0x20
    80001ea2:	9181                	srli	a1,a1,0x20
    80001ea4:	6928                	ld	a0,80(a0)
    80001ea6:	fffff097          	auipc	ra,0xfffff
    80001eaa:	57c080e7          	jalr	1404(ra) # 80001422 <uvmalloc>
    80001eae:	0005061b          	sext.w	a2,a0
    80001eb2:	fa69                	bnez	a2,80001e84 <growproc+0x26>
      return -1;
    80001eb4:	557d                	li	a0,-1
    80001eb6:	bfe1                	j	80001e8e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001eb8:	9e25                	addw	a2,a2,s1
    80001eba:	1602                	slli	a2,a2,0x20
    80001ebc:	9201                	srli	a2,a2,0x20
    80001ebe:	1582                	slli	a1,a1,0x20
    80001ec0:	9181                	srli	a1,a1,0x20
    80001ec2:	6928                	ld	a0,80(a0)
    80001ec4:	fffff097          	auipc	ra,0xfffff
    80001ec8:	516080e7          	jalr	1302(ra) # 800013da <uvmdealloc>
    80001ecc:	0005061b          	sext.w	a2,a0
    80001ed0:	bf55                	j	80001e84 <growproc+0x26>

0000000080001ed2 <fork>:
{
    80001ed2:	7179                	addi	sp,sp,-48
    80001ed4:	f406                	sd	ra,40(sp)
    80001ed6:	f022                	sd	s0,32(sp)
    80001ed8:	ec26                	sd	s1,24(sp)
    80001eda:	e84a                	sd	s2,16(sp)
    80001edc:	e44e                	sd	s3,8(sp)
    80001ede:	e052                	sd	s4,0(sp)
    80001ee0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ee2:	00000097          	auipc	ra,0x0
    80001ee6:	c30080e7          	jalr	-976(ra) # 80001b12 <myproc>
    80001eea:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001eec:	00000097          	auipc	ra,0x0
    80001ef0:	e30080e7          	jalr	-464(ra) # 80001d1c <allocproc>
    80001ef4:	c175                	beqz	a0,80001fd8 <fork+0x106>
    80001ef6:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ef8:	04893603          	ld	a2,72(s2)
    80001efc:	692c                	ld	a1,80(a0)
    80001efe:	05093503          	ld	a0,80(s2)
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	65a080e7          	jalr	1626(ra) # 8000155c <uvmcopy>
    80001f0a:	04054863          	bltz	a0,80001f5a <fork+0x88>
  np->sz = p->sz;
    80001f0e:	04893783          	ld	a5,72(s2)
    80001f12:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001f16:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f1a:	05893683          	ld	a3,88(s2)
    80001f1e:	87b6                	mv	a5,a3
    80001f20:	0589b703          	ld	a4,88(s3)
    80001f24:	12068693          	addi	a3,a3,288
    80001f28:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f2c:	6788                	ld	a0,8(a5)
    80001f2e:	6b8c                	ld	a1,16(a5)
    80001f30:	6f90                	ld	a2,24(a5)
    80001f32:	01073023          	sd	a6,0(a4)
    80001f36:	e708                	sd	a0,8(a4)
    80001f38:	eb0c                	sd	a1,16(a4)
    80001f3a:	ef10                	sd	a2,24(a4)
    80001f3c:	02078793          	addi	a5,a5,32
    80001f40:	02070713          	addi	a4,a4,32
    80001f44:	fed792e3          	bne	a5,a3,80001f28 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f48:	0589b783          	ld	a5,88(s3)
    80001f4c:	0607b823          	sd	zero,112(a5)
    80001f50:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001f54:	15000a13          	li	s4,336
    80001f58:	a03d                	j	80001f86 <fork+0xb4>
    freeproc(np);
    80001f5a:	854e                	mv	a0,s3
    80001f5c:	00000097          	auipc	ra,0x0
    80001f60:	d68080e7          	jalr	-664(ra) # 80001cc4 <freeproc>
    release(&np->lock);
    80001f64:	854e                	mv	a0,s3
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d5e080e7          	jalr	-674(ra) # 80000cc4 <release>
    return -1;
    80001f6e:	54fd                	li	s1,-1
    80001f70:	a899                	j	80001fc6 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f72:	00002097          	auipc	ra,0x2
    80001f76:	64e080e7          	jalr	1614(ra) # 800045c0 <filedup>
    80001f7a:	009987b3          	add	a5,s3,s1
    80001f7e:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001f80:	04a1                	addi	s1,s1,8
    80001f82:	01448763          	beq	s1,s4,80001f90 <fork+0xbe>
    if(p->ofile[i])
    80001f86:	009907b3          	add	a5,s2,s1
    80001f8a:	6388                	ld	a0,0(a5)
    80001f8c:	f17d                	bnez	a0,80001f72 <fork+0xa0>
    80001f8e:	bfcd                	j	80001f80 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001f90:	15093503          	ld	a0,336(s2)
    80001f94:	00001097          	auipc	ra,0x1
    80001f98:	7ae080e7          	jalr	1966(ra) # 80003742 <idup>
    80001f9c:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fa0:	4641                	li	a2,16
    80001fa2:	15890593          	addi	a1,s2,344
    80001fa6:	15898513          	addi	a0,s3,344
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	eb8080e7          	jalr	-328(ra) # 80000e62 <safestrcpy>
  pid = np->pid;
    80001fb2:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001fb6:	4789                	li	a5,2
    80001fb8:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001fbc:	854e                	mv	a0,s3
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	d06080e7          	jalr	-762(ra) # 80000cc4 <release>
}
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	70a2                	ld	ra,40(sp)
    80001fca:	7402                	ld	s0,32(sp)
    80001fcc:	64e2                	ld	s1,24(sp)
    80001fce:	6942                	ld	s2,16(sp)
    80001fd0:	69a2                	ld	s3,8(sp)
    80001fd2:	6a02                	ld	s4,0(sp)
    80001fd4:	6145                	addi	sp,sp,48
    80001fd6:	8082                	ret
    return -1;
    80001fd8:	54fd                	li	s1,-1
    80001fda:	b7f5                	j	80001fc6 <fork+0xf4>

0000000080001fdc <reparent>:
{
    80001fdc:	7179                	addi	sp,sp,-48
    80001fde:	f406                	sd	ra,40(sp)
    80001fe0:	f022                	sd	s0,32(sp)
    80001fe2:	ec26                	sd	s1,24(sp)
    80001fe4:	e84a                	sd	s2,16(sp)
    80001fe6:	e44e                	sd	s3,8(sp)
    80001fe8:	e052                	sd	s4,0(sp)
    80001fea:	1800                	addi	s0,sp,48
    80001fec:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fee:	00010497          	auipc	s1,0x10
    80001ff2:	d7a48493          	addi	s1,s1,-646 # 80011d68 <proc>
      pp->parent = initproc;
    80001ff6:	00007a17          	auipc	s4,0x7
    80001ffa:	022a0a13          	addi	s4,s4,34 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ffe:	00015997          	auipc	s3,0x15
    80002002:	76a98993          	addi	s3,s3,1898 # 80017768 <tickslock>
    80002006:	a029                	j	80002010 <reparent+0x34>
    80002008:	16848493          	addi	s1,s1,360
    8000200c:	03348363          	beq	s1,s3,80002032 <reparent+0x56>
    if(pp->parent == p){
    80002010:	709c                	ld	a5,32(s1)
    80002012:	ff279be3          	bne	a5,s2,80002008 <reparent+0x2c>
      acquire(&pp->lock);
    80002016:	8526                	mv	a0,s1
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	bf8080e7          	jalr	-1032(ra) # 80000c10 <acquire>
      pp->parent = initproc;
    80002020:	000a3783          	ld	a5,0(s4)
    80002024:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	c9c080e7          	jalr	-868(ra) # 80000cc4 <release>
    80002030:	bfe1                	j	80002008 <reparent+0x2c>
}
    80002032:	70a2                	ld	ra,40(sp)
    80002034:	7402                	ld	s0,32(sp)
    80002036:	64e2                	ld	s1,24(sp)
    80002038:	6942                	ld	s2,16(sp)
    8000203a:	69a2                	ld	s3,8(sp)
    8000203c:	6a02                	ld	s4,0(sp)
    8000203e:	6145                	addi	sp,sp,48
    80002040:	8082                	ret

0000000080002042 <scheduler>:
{
    80002042:	711d                	addi	sp,sp,-96
    80002044:	ec86                	sd	ra,88(sp)
    80002046:	e8a2                	sd	s0,80(sp)
    80002048:	e4a6                	sd	s1,72(sp)
    8000204a:	e0ca                	sd	s2,64(sp)
    8000204c:	fc4e                	sd	s3,56(sp)
    8000204e:	f852                	sd	s4,48(sp)
    80002050:	f456                	sd	s5,40(sp)
    80002052:	f05a                	sd	s6,32(sp)
    80002054:	ec5e                	sd	s7,24(sp)
    80002056:	e862                	sd	s8,16(sp)
    80002058:	e466                	sd	s9,8(sp)
    8000205a:	1080                	addi	s0,sp,96
    8000205c:	8792                	mv	a5,tp
  int id = r_tp();
    8000205e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002060:	00779c13          	slli	s8,a5,0x7
    80002064:	00010717          	auipc	a4,0x10
    80002068:	8ec70713          	addi	a4,a4,-1812 # 80011950 <pid_lock>
    8000206c:	9762                	add	a4,a4,s8
    8000206e:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002072:	00010717          	auipc	a4,0x10
    80002076:	8fe70713          	addi	a4,a4,-1794 # 80011970 <cpus+0x8>
    8000207a:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    8000207c:	4a89                	li	s5,2
        c->proc = p;
    8000207e:	079e                	slli	a5,a5,0x7
    80002080:	00010b17          	auipc	s6,0x10
    80002084:	8d0b0b13          	addi	s6,s6,-1840 # 80011950 <pid_lock>
    80002088:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000208a:	00015a17          	auipc	s4,0x15
    8000208e:	6dea0a13          	addi	s4,s4,1758 # 80017768 <tickslock>
    int nproc = 0;
    80002092:	4c81                	li	s9,0
    80002094:	a8a1                	j	800020ec <scheduler+0xaa>
        p->state = RUNNING;
    80002096:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    8000209a:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    8000209e:	06048593          	addi	a1,s1,96
    800020a2:	8562                	mv	a0,s8
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	63a080e7          	jalr	1594(ra) # 800026de <swtch>
        c->proc = 0;
    800020ac:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    800020b0:	8526                	mv	a0,s1
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	c12080e7          	jalr	-1006(ra) # 80000cc4 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ba:	16848493          	addi	s1,s1,360
    800020be:	01448d63          	beq	s1,s4,800020d8 <scheduler+0x96>
      acquire(&p->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	b4c080e7          	jalr	-1204(ra) # 80000c10 <acquire>
      if(p->state != UNUSED) {
    800020cc:	4c9c                	lw	a5,24(s1)
    800020ce:	d3ed                	beqz	a5,800020b0 <scheduler+0x6e>
        nproc++;
    800020d0:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    800020d2:	fd579fe3          	bne	a5,s5,800020b0 <scheduler+0x6e>
    800020d6:	b7c1                	j	80002096 <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    800020d8:	013aca63          	blt	s5,s3,800020ec <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020dc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020e0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020e4:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800020e8:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020ec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020f0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020f4:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    800020f8:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    800020fa:	00010497          	auipc	s1,0x10
    800020fe:	c6e48493          	addi	s1,s1,-914 # 80011d68 <proc>
        p->state = RUNNING;
    80002102:	4b8d                	li	s7,3
    80002104:	bf7d                	j	800020c2 <scheduler+0x80>

0000000080002106 <sched>:
{
    80002106:	7179                	addi	sp,sp,-48
    80002108:	f406                	sd	ra,40(sp)
    8000210a:	f022                	sd	s0,32(sp)
    8000210c:	ec26                	sd	s1,24(sp)
    8000210e:	e84a                	sd	s2,16(sp)
    80002110:	e44e                	sd	s3,8(sp)
    80002112:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002114:	00000097          	auipc	ra,0x0
    80002118:	9fe080e7          	jalr	-1538(ra) # 80001b12 <myproc>
    8000211c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	a78080e7          	jalr	-1416(ra) # 80000b96 <holding>
    80002126:	c93d                	beqz	a0,8000219c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002128:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000212a:	2781                	sext.w	a5,a5
    8000212c:	079e                	slli	a5,a5,0x7
    8000212e:	00010717          	auipc	a4,0x10
    80002132:	82270713          	addi	a4,a4,-2014 # 80011950 <pid_lock>
    80002136:	97ba                	add	a5,a5,a4
    80002138:	0907a703          	lw	a4,144(a5)
    8000213c:	4785                	li	a5,1
    8000213e:	06f71763          	bne	a4,a5,800021ac <sched+0xa6>
  if(p->state == RUNNING)
    80002142:	4c98                	lw	a4,24(s1)
    80002144:	478d                	li	a5,3
    80002146:	06f70b63          	beq	a4,a5,800021bc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000214a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000214e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002150:	efb5                	bnez	a5,800021cc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002152:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002154:	0000f917          	auipc	s2,0xf
    80002158:	7fc90913          	addi	s2,s2,2044 # 80011950 <pid_lock>
    8000215c:	2781                	sext.w	a5,a5
    8000215e:	079e                	slli	a5,a5,0x7
    80002160:	97ca                	add	a5,a5,s2
    80002162:	0947a983          	lw	s3,148(a5)
    80002166:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002168:	2781                	sext.w	a5,a5
    8000216a:	079e                	slli	a5,a5,0x7
    8000216c:	00010597          	auipc	a1,0x10
    80002170:	80458593          	addi	a1,a1,-2044 # 80011970 <cpus+0x8>
    80002174:	95be                	add	a1,a1,a5
    80002176:	06048513          	addi	a0,s1,96
    8000217a:	00000097          	auipc	ra,0x0
    8000217e:	564080e7          	jalr	1380(ra) # 800026de <swtch>
    80002182:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002184:	2781                	sext.w	a5,a5
    80002186:	079e                	slli	a5,a5,0x7
    80002188:	97ca                	add	a5,a5,s2
    8000218a:	0937aa23          	sw	s3,148(a5)
}
    8000218e:	70a2                	ld	ra,40(sp)
    80002190:	7402                	ld	s0,32(sp)
    80002192:	64e2                	ld	s1,24(sp)
    80002194:	6942                	ld	s2,16(sp)
    80002196:	69a2                	ld	s3,8(sp)
    80002198:	6145                	addi	sp,sp,48
    8000219a:	8082                	ret
    panic("sched p->lock");
    8000219c:	00006517          	auipc	a0,0x6
    800021a0:	03450513          	addi	a0,a0,52 # 800081d0 <digits+0x190>
    800021a4:	ffffe097          	auipc	ra,0xffffe
    800021a8:	3a4080e7          	jalr	932(ra) # 80000548 <panic>
    panic("sched locks");
    800021ac:	00006517          	auipc	a0,0x6
    800021b0:	03450513          	addi	a0,a0,52 # 800081e0 <digits+0x1a0>
    800021b4:	ffffe097          	auipc	ra,0xffffe
    800021b8:	394080e7          	jalr	916(ra) # 80000548 <panic>
    panic("sched running");
    800021bc:	00006517          	auipc	a0,0x6
    800021c0:	03450513          	addi	a0,a0,52 # 800081f0 <digits+0x1b0>
    800021c4:	ffffe097          	auipc	ra,0xffffe
    800021c8:	384080e7          	jalr	900(ra) # 80000548 <panic>
    panic("sched interruptible");
    800021cc:	00006517          	auipc	a0,0x6
    800021d0:	03450513          	addi	a0,a0,52 # 80008200 <digits+0x1c0>
    800021d4:	ffffe097          	auipc	ra,0xffffe
    800021d8:	374080e7          	jalr	884(ra) # 80000548 <panic>

00000000800021dc <exit>:
{
    800021dc:	7179                	addi	sp,sp,-48
    800021de:	f406                	sd	ra,40(sp)
    800021e0:	f022                	sd	s0,32(sp)
    800021e2:	ec26                	sd	s1,24(sp)
    800021e4:	e84a                	sd	s2,16(sp)
    800021e6:	e44e                	sd	s3,8(sp)
    800021e8:	e052                	sd	s4,0(sp)
    800021ea:	1800                	addi	s0,sp,48
    800021ec:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021ee:	00000097          	auipc	ra,0x0
    800021f2:	924080e7          	jalr	-1756(ra) # 80001b12 <myproc>
    800021f6:	89aa                	mv	s3,a0
  if(p == initproc)
    800021f8:	00007797          	auipc	a5,0x7
    800021fc:	e207b783          	ld	a5,-480(a5) # 80009018 <initproc>
    80002200:	0d050493          	addi	s1,a0,208
    80002204:	15050913          	addi	s2,a0,336
    80002208:	02a79363          	bne	a5,a0,8000222e <exit+0x52>
    panic("init exiting");
    8000220c:	00006517          	auipc	a0,0x6
    80002210:	00c50513          	addi	a0,a0,12 # 80008218 <digits+0x1d8>
    80002214:	ffffe097          	auipc	ra,0xffffe
    80002218:	334080e7          	jalr	820(ra) # 80000548 <panic>
      fileclose(f);
    8000221c:	00002097          	auipc	ra,0x2
    80002220:	3f6080e7          	jalr	1014(ra) # 80004612 <fileclose>
      p->ofile[fd] = 0;
    80002224:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002228:	04a1                	addi	s1,s1,8
    8000222a:	01248563          	beq	s1,s2,80002234 <exit+0x58>
    if(p->ofile[fd]){
    8000222e:	6088                	ld	a0,0(s1)
    80002230:	f575                	bnez	a0,8000221c <exit+0x40>
    80002232:	bfdd                	j	80002228 <exit+0x4c>
  begin_op();
    80002234:	00002097          	auipc	ra,0x2
    80002238:	f0c080e7          	jalr	-244(ra) # 80004140 <begin_op>
  iput(p->cwd);
    8000223c:	1509b503          	ld	a0,336(s3)
    80002240:	00001097          	auipc	ra,0x1
    80002244:	6fa080e7          	jalr	1786(ra) # 8000393a <iput>
  end_op();
    80002248:	00002097          	auipc	ra,0x2
    8000224c:	f78080e7          	jalr	-136(ra) # 800041c0 <end_op>
  p->cwd = 0;
    80002250:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002254:	00007497          	auipc	s1,0x7
    80002258:	dc448493          	addi	s1,s1,-572 # 80009018 <initproc>
    8000225c:	6088                	ld	a0,0(s1)
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	9b2080e7          	jalr	-1614(ra) # 80000c10 <acquire>
  wakeup1(initproc);
    80002266:	6088                	ld	a0,0(s1)
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	76a080e7          	jalr	1898(ra) # 800019d2 <wakeup1>
  release(&initproc->lock);
    80002270:	6088                	ld	a0,0(s1)
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	a52080e7          	jalr	-1454(ra) # 80000cc4 <release>
  acquire(&p->lock);
    8000227a:	854e                	mv	a0,s3
    8000227c:	fffff097          	auipc	ra,0xfffff
    80002280:	994080e7          	jalr	-1644(ra) # 80000c10 <acquire>
  struct proc *original_parent = p->parent;
    80002284:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002288:	854e                	mv	a0,s3
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	a3a080e7          	jalr	-1478(ra) # 80000cc4 <release>
  acquire(&original_parent->lock);
    80002292:	8526                	mv	a0,s1
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	97c080e7          	jalr	-1668(ra) # 80000c10 <acquire>
  acquire(&p->lock);
    8000229c:	854e                	mv	a0,s3
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	972080e7          	jalr	-1678(ra) # 80000c10 <acquire>
  reparent(p);
    800022a6:	854e                	mv	a0,s3
    800022a8:	00000097          	auipc	ra,0x0
    800022ac:	d34080e7          	jalr	-716(ra) # 80001fdc <reparent>
  wakeup1(original_parent);
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	720080e7          	jalr	1824(ra) # 800019d2 <wakeup1>
  p->xstate = status;
    800022ba:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800022be:	4791                	li	a5,4
    800022c0:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	9fe080e7          	jalr	-1538(ra) # 80000cc4 <release>
  sched();
    800022ce:	00000097          	auipc	ra,0x0
    800022d2:	e38080e7          	jalr	-456(ra) # 80002106 <sched>
  panic("zombie exit");
    800022d6:	00006517          	auipc	a0,0x6
    800022da:	f5250513          	addi	a0,a0,-174 # 80008228 <digits+0x1e8>
    800022de:	ffffe097          	auipc	ra,0xffffe
    800022e2:	26a080e7          	jalr	618(ra) # 80000548 <panic>

00000000800022e6 <yield>:
{
    800022e6:	1101                	addi	sp,sp,-32
    800022e8:	ec06                	sd	ra,24(sp)
    800022ea:	e822                	sd	s0,16(sp)
    800022ec:	e426                	sd	s1,8(sp)
    800022ee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022f0:	00000097          	auipc	ra,0x0
    800022f4:	822080e7          	jalr	-2014(ra) # 80001b12 <myproc>
    800022f8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	916080e7          	jalr	-1770(ra) # 80000c10 <acquire>
  p->state = RUNNABLE;
    80002302:	4789                	li	a5,2
    80002304:	cc9c                	sw	a5,24(s1)
  sched();
    80002306:	00000097          	auipc	ra,0x0
    8000230a:	e00080e7          	jalr	-512(ra) # 80002106 <sched>
  release(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	9b4080e7          	jalr	-1612(ra) # 80000cc4 <release>
}
    80002318:	60e2                	ld	ra,24(sp)
    8000231a:	6442                	ld	s0,16(sp)
    8000231c:	64a2                	ld	s1,8(sp)
    8000231e:	6105                	addi	sp,sp,32
    80002320:	8082                	ret

0000000080002322 <sleep>:
{
    80002322:	7179                	addi	sp,sp,-48
    80002324:	f406                	sd	ra,40(sp)
    80002326:	f022                	sd	s0,32(sp)
    80002328:	ec26                	sd	s1,24(sp)
    8000232a:	e84a                	sd	s2,16(sp)
    8000232c:	e44e                	sd	s3,8(sp)
    8000232e:	1800                	addi	s0,sp,48
    80002330:	89aa                	mv	s3,a0
    80002332:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	7de080e7          	jalr	2014(ra) # 80001b12 <myproc>
    8000233c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000233e:	05250663          	beq	a0,s2,8000238a <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	8ce080e7          	jalr	-1842(ra) # 80000c10 <acquire>
    release(lk);
    8000234a:	854a                	mv	a0,s2
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	978080e7          	jalr	-1672(ra) # 80000cc4 <release>
  p->chan = chan;
    80002354:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002358:	4785                	li	a5,1
    8000235a:	cc9c                	sw	a5,24(s1)
  sched();
    8000235c:	00000097          	auipc	ra,0x0
    80002360:	daa080e7          	jalr	-598(ra) # 80002106 <sched>
  p->chan = 0;
    80002364:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	95a080e7          	jalr	-1702(ra) # 80000cc4 <release>
    acquire(lk);
    80002372:	854a                	mv	a0,s2
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	89c080e7          	jalr	-1892(ra) # 80000c10 <acquire>
}
    8000237c:	70a2                	ld	ra,40(sp)
    8000237e:	7402                	ld	s0,32(sp)
    80002380:	64e2                	ld	s1,24(sp)
    80002382:	6942                	ld	s2,16(sp)
    80002384:	69a2                	ld	s3,8(sp)
    80002386:	6145                	addi	sp,sp,48
    80002388:	8082                	ret
  p->chan = chan;
    8000238a:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000238e:	4785                	li	a5,1
    80002390:	cd1c                	sw	a5,24(a0)
  sched();
    80002392:	00000097          	auipc	ra,0x0
    80002396:	d74080e7          	jalr	-652(ra) # 80002106 <sched>
  p->chan = 0;
    8000239a:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    8000239e:	bff9                	j	8000237c <sleep+0x5a>

00000000800023a0 <wait>:
{
    800023a0:	715d                	addi	sp,sp,-80
    800023a2:	e486                	sd	ra,72(sp)
    800023a4:	e0a2                	sd	s0,64(sp)
    800023a6:	fc26                	sd	s1,56(sp)
    800023a8:	f84a                	sd	s2,48(sp)
    800023aa:	f44e                	sd	s3,40(sp)
    800023ac:	f052                	sd	s4,32(sp)
    800023ae:	ec56                	sd	s5,24(sp)
    800023b0:	e85a                	sd	s6,16(sp)
    800023b2:	e45e                	sd	s7,8(sp)
    800023b4:	e062                	sd	s8,0(sp)
    800023b6:	0880                	addi	s0,sp,80
    800023b8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	758080e7          	jalr	1880(ra) # 80001b12 <myproc>
    800023c2:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023c4:	8c2a                	mv	s8,a0
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	84a080e7          	jalr	-1974(ra) # 80000c10 <acquire>
    havekids = 0;
    800023ce:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800023d0:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800023d2:	00015997          	auipc	s3,0x15
    800023d6:	39698993          	addi	s3,s3,918 # 80017768 <tickslock>
        havekids = 1;
    800023da:	4a85                	li	s5,1
    havekids = 0;
    800023dc:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800023de:	00010497          	auipc	s1,0x10
    800023e2:	98a48493          	addi	s1,s1,-1654 # 80011d68 <proc>
    800023e6:	a08d                	j	80002448 <wait+0xa8>
          pid = np->pid;
    800023e8:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023ec:	000b0e63          	beqz	s6,80002408 <wait+0x68>
    800023f0:	4691                	li	a3,4
    800023f2:	03448613          	addi	a2,s1,52
    800023f6:	85da                	mv	a1,s6
    800023f8:	05093503          	ld	a0,80(s2)
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	330080e7          	jalr	816(ra) # 8000172c <copyout>
    80002404:	02054263          	bltz	a0,80002428 <wait+0x88>
          freeproc(np);
    80002408:	8526                	mv	a0,s1
    8000240a:	00000097          	auipc	ra,0x0
    8000240e:	8ba080e7          	jalr	-1862(ra) # 80001cc4 <freeproc>
          release(&np->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	8b0080e7          	jalr	-1872(ra) # 80000cc4 <release>
          release(&p->lock);
    8000241c:	854a                	mv	a0,s2
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	8a6080e7          	jalr	-1882(ra) # 80000cc4 <release>
          return pid;
    80002426:	a8a9                	j	80002480 <wait+0xe0>
            release(&np->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	89a080e7          	jalr	-1894(ra) # 80000cc4 <release>
            release(&p->lock);
    80002432:	854a                	mv	a0,s2
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	890080e7          	jalr	-1904(ra) # 80000cc4 <release>
            return -1;
    8000243c:	59fd                	li	s3,-1
    8000243e:	a089                	j	80002480 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002440:	16848493          	addi	s1,s1,360
    80002444:	03348463          	beq	s1,s3,8000246c <wait+0xcc>
      if(np->parent == p){
    80002448:	709c                	ld	a5,32(s1)
    8000244a:	ff279be3          	bne	a5,s2,80002440 <wait+0xa0>
        acquire(&np->lock);
    8000244e:	8526                	mv	a0,s1
    80002450:	ffffe097          	auipc	ra,0xffffe
    80002454:	7c0080e7          	jalr	1984(ra) # 80000c10 <acquire>
        if(np->state == ZOMBIE){
    80002458:	4c9c                	lw	a5,24(s1)
    8000245a:	f94787e3          	beq	a5,s4,800023e8 <wait+0x48>
        release(&np->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	864080e7          	jalr	-1948(ra) # 80000cc4 <release>
        havekids = 1;
    80002468:	8756                	mv	a4,s5
    8000246a:	bfd9                	j	80002440 <wait+0xa0>
    if(!havekids || p->killed){
    8000246c:	c701                	beqz	a4,80002474 <wait+0xd4>
    8000246e:	03092783          	lw	a5,48(s2)
    80002472:	c785                	beqz	a5,8000249a <wait+0xfa>
      release(&p->lock);
    80002474:	854a                	mv	a0,s2
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	84e080e7          	jalr	-1970(ra) # 80000cc4 <release>
      return -1;
    8000247e:	59fd                	li	s3,-1
}
    80002480:	854e                	mv	a0,s3
    80002482:	60a6                	ld	ra,72(sp)
    80002484:	6406                	ld	s0,64(sp)
    80002486:	74e2                	ld	s1,56(sp)
    80002488:	7942                	ld	s2,48(sp)
    8000248a:	79a2                	ld	s3,40(sp)
    8000248c:	7a02                	ld	s4,32(sp)
    8000248e:	6ae2                	ld	s5,24(sp)
    80002490:	6b42                	ld	s6,16(sp)
    80002492:	6ba2                	ld	s7,8(sp)
    80002494:	6c02                	ld	s8,0(sp)
    80002496:	6161                	addi	sp,sp,80
    80002498:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000249a:	85e2                	mv	a1,s8
    8000249c:	854a                	mv	a0,s2
    8000249e:	00000097          	auipc	ra,0x0
    800024a2:	e84080e7          	jalr	-380(ra) # 80002322 <sleep>
    havekids = 0;
    800024a6:	bf1d                	j	800023dc <wait+0x3c>

00000000800024a8 <wakeup>:
{
    800024a8:	7139                	addi	sp,sp,-64
    800024aa:	fc06                	sd	ra,56(sp)
    800024ac:	f822                	sd	s0,48(sp)
    800024ae:	f426                	sd	s1,40(sp)
    800024b0:	f04a                	sd	s2,32(sp)
    800024b2:	ec4e                	sd	s3,24(sp)
    800024b4:	e852                	sd	s4,16(sp)
    800024b6:	e456                	sd	s5,8(sp)
    800024b8:	0080                	addi	s0,sp,64
    800024ba:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800024bc:	00010497          	auipc	s1,0x10
    800024c0:	8ac48493          	addi	s1,s1,-1876 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800024c4:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024c6:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800024c8:	00015917          	auipc	s2,0x15
    800024cc:	2a090913          	addi	s2,s2,672 # 80017768 <tickslock>
    800024d0:	a821                	j	800024e8 <wakeup+0x40>
      p->state = RUNNABLE;
    800024d2:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	ffffe097          	auipc	ra,0xffffe
    800024dc:	7ec080e7          	jalr	2028(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024e0:	16848493          	addi	s1,s1,360
    800024e4:	01248e63          	beq	s1,s2,80002500 <wakeup+0x58>
    acquire(&p->lock);
    800024e8:	8526                	mv	a0,s1
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	726080e7          	jalr	1830(ra) # 80000c10 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800024f2:	4c9c                	lw	a5,24(s1)
    800024f4:	ff3791e3          	bne	a5,s3,800024d6 <wakeup+0x2e>
    800024f8:	749c                	ld	a5,40(s1)
    800024fa:	fd479ee3          	bne	a5,s4,800024d6 <wakeup+0x2e>
    800024fe:	bfd1                	j	800024d2 <wakeup+0x2a>
}
    80002500:	70e2                	ld	ra,56(sp)
    80002502:	7442                	ld	s0,48(sp)
    80002504:	74a2                	ld	s1,40(sp)
    80002506:	7902                	ld	s2,32(sp)
    80002508:	69e2                	ld	s3,24(sp)
    8000250a:	6a42                	ld	s4,16(sp)
    8000250c:	6aa2                	ld	s5,8(sp)
    8000250e:	6121                	addi	sp,sp,64
    80002510:	8082                	ret

0000000080002512 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002512:	7179                	addi	sp,sp,-48
    80002514:	f406                	sd	ra,40(sp)
    80002516:	f022                	sd	s0,32(sp)
    80002518:	ec26                	sd	s1,24(sp)
    8000251a:	e84a                	sd	s2,16(sp)
    8000251c:	e44e                	sd	s3,8(sp)
    8000251e:	1800                	addi	s0,sp,48
    80002520:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002522:	00010497          	auipc	s1,0x10
    80002526:	84648493          	addi	s1,s1,-1978 # 80011d68 <proc>
    8000252a:	00015997          	auipc	s3,0x15
    8000252e:	23e98993          	addi	s3,s3,574 # 80017768 <tickslock>
    acquire(&p->lock);
    80002532:	8526                	mv	a0,s1
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	6dc080e7          	jalr	1756(ra) # 80000c10 <acquire>
    if(p->pid == pid){
    8000253c:	5c9c                	lw	a5,56(s1)
    8000253e:	01278d63          	beq	a5,s2,80002558 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	ffffe097          	auipc	ra,0xffffe
    80002548:	780080e7          	jalr	1920(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000254c:	16848493          	addi	s1,s1,360
    80002550:	ff3491e3          	bne	s1,s3,80002532 <kill+0x20>
  }
  return -1;
    80002554:	557d                	li	a0,-1
    80002556:	a829                	j	80002570 <kill+0x5e>
      p->killed = 1;
    80002558:	4785                	li	a5,1
    8000255a:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000255c:	4c98                	lw	a4,24(s1)
    8000255e:	4785                	li	a5,1
    80002560:	00f70f63          	beq	a4,a5,8000257e <kill+0x6c>
      release(&p->lock);
    80002564:	8526                	mv	a0,s1
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	75e080e7          	jalr	1886(ra) # 80000cc4 <release>
      return 0;
    8000256e:	4501                	li	a0,0
}
    80002570:	70a2                	ld	ra,40(sp)
    80002572:	7402                	ld	s0,32(sp)
    80002574:	64e2                	ld	s1,24(sp)
    80002576:	6942                	ld	s2,16(sp)
    80002578:	69a2                	ld	s3,8(sp)
    8000257a:	6145                	addi	sp,sp,48
    8000257c:	8082                	ret
        p->state = RUNNABLE;
    8000257e:	4789                	li	a5,2
    80002580:	cc9c                	sw	a5,24(s1)
    80002582:	b7cd                	j	80002564 <kill+0x52>

0000000080002584 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002584:	7179                	addi	sp,sp,-48
    80002586:	f406                	sd	ra,40(sp)
    80002588:	f022                	sd	s0,32(sp)
    8000258a:	ec26                	sd	s1,24(sp)
    8000258c:	e84a                	sd	s2,16(sp)
    8000258e:	e44e                	sd	s3,8(sp)
    80002590:	e052                	sd	s4,0(sp)
    80002592:	1800                	addi	s0,sp,48
    80002594:	84aa                	mv	s1,a0
    80002596:	892e                	mv	s2,a1
    80002598:	89b2                	mv	s3,a2
    8000259a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000259c:	fffff097          	auipc	ra,0xfffff
    800025a0:	576080e7          	jalr	1398(ra) # 80001b12 <myproc>
  if(user_dst){
    800025a4:	c08d                	beqz	s1,800025c6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025a6:	86d2                	mv	a3,s4
    800025a8:	864e                	mv	a2,s3
    800025aa:	85ca                	mv	a1,s2
    800025ac:	6928                	ld	a0,80(a0)
    800025ae:	fffff097          	auipc	ra,0xfffff
    800025b2:	17e080e7          	jalr	382(ra) # 8000172c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025b6:	70a2                	ld	ra,40(sp)
    800025b8:	7402                	ld	s0,32(sp)
    800025ba:	64e2                	ld	s1,24(sp)
    800025bc:	6942                	ld	s2,16(sp)
    800025be:	69a2                	ld	s3,8(sp)
    800025c0:	6a02                	ld	s4,0(sp)
    800025c2:	6145                	addi	sp,sp,48
    800025c4:	8082                	ret
    memmove((char *)dst, src, len);
    800025c6:	000a061b          	sext.w	a2,s4
    800025ca:	85ce                	mv	a1,s3
    800025cc:	854a                	mv	a0,s2
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	79e080e7          	jalr	1950(ra) # 80000d6c <memmove>
    return 0;
    800025d6:	8526                	mv	a0,s1
    800025d8:	bff9                	j	800025b6 <either_copyout+0x32>

00000000800025da <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025da:	7179                	addi	sp,sp,-48
    800025dc:	f406                	sd	ra,40(sp)
    800025de:	f022                	sd	s0,32(sp)
    800025e0:	ec26                	sd	s1,24(sp)
    800025e2:	e84a                	sd	s2,16(sp)
    800025e4:	e44e                	sd	s3,8(sp)
    800025e6:	e052                	sd	s4,0(sp)
    800025e8:	1800                	addi	s0,sp,48
    800025ea:	892a                	mv	s2,a0
    800025ec:	84ae                	mv	s1,a1
    800025ee:	89b2                	mv	s3,a2
    800025f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	520080e7          	jalr	1312(ra) # 80001b12 <myproc>
  if(user_src){
    800025fa:	c08d                	beqz	s1,8000261c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025fc:	86d2                	mv	a3,s4
    800025fe:	864e                	mv	a2,s3
    80002600:	85ca                	mv	a1,s2
    80002602:	6928                	ld	a0,80(a0)
    80002604:	fffff097          	auipc	ra,0xfffff
    80002608:	1b4080e7          	jalr	436(ra) # 800017b8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000260c:	70a2                	ld	ra,40(sp)
    8000260e:	7402                	ld	s0,32(sp)
    80002610:	64e2                	ld	s1,24(sp)
    80002612:	6942                	ld	s2,16(sp)
    80002614:	69a2                	ld	s3,8(sp)
    80002616:	6a02                	ld	s4,0(sp)
    80002618:	6145                	addi	sp,sp,48
    8000261a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000261c:	000a061b          	sext.w	a2,s4
    80002620:	85ce                	mv	a1,s3
    80002622:	854a                	mv	a0,s2
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	748080e7          	jalr	1864(ra) # 80000d6c <memmove>
    return 0;
    8000262c:	8526                	mv	a0,s1
    8000262e:	bff9                	j	8000260c <either_copyin+0x32>

0000000080002630 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002630:	715d                	addi	sp,sp,-80
    80002632:	e486                	sd	ra,72(sp)
    80002634:	e0a2                	sd	s0,64(sp)
    80002636:	fc26                	sd	s1,56(sp)
    80002638:	f84a                	sd	s2,48(sp)
    8000263a:	f44e                	sd	s3,40(sp)
    8000263c:	f052                	sd	s4,32(sp)
    8000263e:	ec56                	sd	s5,24(sp)
    80002640:	e85a                	sd	s6,16(sp)
    80002642:	e45e                	sd	s7,8(sp)
    80002644:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002646:	00006517          	auipc	a0,0x6
    8000264a:	a8250513          	addi	a0,a0,-1406 # 800080c8 <digits+0x88>
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	f44080e7          	jalr	-188(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002656:	00010497          	auipc	s1,0x10
    8000265a:	86a48493          	addi	s1,s1,-1942 # 80011ec0 <proc+0x158>
    8000265e:	00015917          	auipc	s2,0x15
    80002662:	26290913          	addi	s2,s2,610 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002666:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002668:	00006997          	auipc	s3,0x6
    8000266c:	bd098993          	addi	s3,s3,-1072 # 80008238 <digits+0x1f8>
    printf("%d %s %s", p->pid, state, p->name);
    80002670:	00006a97          	auipc	s5,0x6
    80002674:	bd0a8a93          	addi	s5,s5,-1072 # 80008240 <digits+0x200>
    printf("\n");
    80002678:	00006a17          	auipc	s4,0x6
    8000267c:	a50a0a13          	addi	s4,s4,-1456 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002680:	00006b97          	auipc	s7,0x6
    80002684:	bf8b8b93          	addi	s7,s7,-1032 # 80008278 <states.1706>
    80002688:	a00d                	j	800026aa <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000268a:	ee06a583          	lw	a1,-288(a3)
    8000268e:	8556                	mv	a0,s5
    80002690:	ffffe097          	auipc	ra,0xffffe
    80002694:	f02080e7          	jalr	-254(ra) # 80000592 <printf>
    printf("\n");
    80002698:	8552                	mv	a0,s4
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	ef8080e7          	jalr	-264(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026a2:	16848493          	addi	s1,s1,360
    800026a6:	03248163          	beq	s1,s2,800026c8 <procdump+0x98>
    if(p->state == UNUSED)
    800026aa:	86a6                	mv	a3,s1
    800026ac:	ec04a783          	lw	a5,-320(s1)
    800026b0:	dbed                	beqz	a5,800026a2 <procdump+0x72>
      state = "???";
    800026b2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b4:	fcfb6be3          	bltu	s6,a5,8000268a <procdump+0x5a>
    800026b8:	1782                	slli	a5,a5,0x20
    800026ba:	9381                	srli	a5,a5,0x20
    800026bc:	078e                	slli	a5,a5,0x3
    800026be:	97de                	add	a5,a5,s7
    800026c0:	6390                	ld	a2,0(a5)
    800026c2:	f661                	bnez	a2,8000268a <procdump+0x5a>
      state = "???";
    800026c4:	864e                	mv	a2,s3
    800026c6:	b7d1                	j	8000268a <procdump+0x5a>
  }
}
    800026c8:	60a6                	ld	ra,72(sp)
    800026ca:	6406                	ld	s0,64(sp)
    800026cc:	74e2                	ld	s1,56(sp)
    800026ce:	7942                	ld	s2,48(sp)
    800026d0:	79a2                	ld	s3,40(sp)
    800026d2:	7a02                	ld	s4,32(sp)
    800026d4:	6ae2                	ld	s5,24(sp)
    800026d6:	6b42                	ld	s6,16(sp)
    800026d8:	6ba2                	ld	s7,8(sp)
    800026da:	6161                	addi	sp,sp,80
    800026dc:	8082                	ret

00000000800026de <swtch>:
    800026de:	00153023          	sd	ra,0(a0)
    800026e2:	00253423          	sd	sp,8(a0)
    800026e6:	e900                	sd	s0,16(a0)
    800026e8:	ed04                	sd	s1,24(a0)
    800026ea:	03253023          	sd	s2,32(a0)
    800026ee:	03353423          	sd	s3,40(a0)
    800026f2:	03453823          	sd	s4,48(a0)
    800026f6:	03553c23          	sd	s5,56(a0)
    800026fa:	05653023          	sd	s6,64(a0)
    800026fe:	05753423          	sd	s7,72(a0)
    80002702:	05853823          	sd	s8,80(a0)
    80002706:	05953c23          	sd	s9,88(a0)
    8000270a:	07a53023          	sd	s10,96(a0)
    8000270e:	07b53423          	sd	s11,104(a0)
    80002712:	0005b083          	ld	ra,0(a1)
    80002716:	0085b103          	ld	sp,8(a1)
    8000271a:	6980                	ld	s0,16(a1)
    8000271c:	6d84                	ld	s1,24(a1)
    8000271e:	0205b903          	ld	s2,32(a1)
    80002722:	0285b983          	ld	s3,40(a1)
    80002726:	0305ba03          	ld	s4,48(a1)
    8000272a:	0385ba83          	ld	s5,56(a1)
    8000272e:	0405bb03          	ld	s6,64(a1)
    80002732:	0485bb83          	ld	s7,72(a1)
    80002736:	0505bc03          	ld	s8,80(a1)
    8000273a:	0585bc83          	ld	s9,88(a1)
    8000273e:	0605bd03          	ld	s10,96(a1)
    80002742:	0685bd83          	ld	s11,104(a1)
    80002746:	8082                	ret

0000000080002748 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002748:	1141                	addi	sp,sp,-16
    8000274a:	e406                	sd	ra,8(sp)
    8000274c:	e022                	sd	s0,0(sp)
    8000274e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002750:	00006597          	auipc	a1,0x6
    80002754:	b5058593          	addi	a1,a1,-1200 # 800082a0 <states.1706+0x28>
    80002758:	00015517          	auipc	a0,0x15
    8000275c:	01050513          	addi	a0,a0,16 # 80017768 <tickslock>
    80002760:	ffffe097          	auipc	ra,0xffffe
    80002764:	420080e7          	jalr	1056(ra) # 80000b80 <initlock>
}
    80002768:	60a2                	ld	ra,8(sp)
    8000276a:	6402                	ld	s0,0(sp)
    8000276c:	0141                	addi	sp,sp,16
    8000276e:	8082                	ret

0000000080002770 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002770:	1141                	addi	sp,sp,-16
    80002772:	e422                	sd	s0,8(sp)
    80002774:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002776:	00003797          	auipc	a5,0x3
    8000277a:	51a78793          	addi	a5,a5,1306 # 80005c90 <kernelvec>
    8000277e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002782:	6422                	ld	s0,8(sp)
    80002784:	0141                	addi	sp,sp,16
    80002786:	8082                	ret

0000000080002788 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002788:	1141                	addi	sp,sp,-16
    8000278a:	e406                	sd	ra,8(sp)
    8000278c:	e022                	sd	s0,0(sp)
    8000278e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002790:	fffff097          	auipc	ra,0xfffff
    80002794:	382080e7          	jalr	898(ra) # 80001b12 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002798:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000279c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000279e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800027a2:	00005617          	auipc	a2,0x5
    800027a6:	85e60613          	addi	a2,a2,-1954 # 80007000 <_trampoline>
    800027aa:	00005697          	auipc	a3,0x5
    800027ae:	85668693          	addi	a3,a3,-1962 # 80007000 <_trampoline>
    800027b2:	8e91                	sub	a3,a3,a2
    800027b4:	040007b7          	lui	a5,0x4000
    800027b8:	17fd                	addi	a5,a5,-1
    800027ba:	07b2                	slli	a5,a5,0xc
    800027bc:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027be:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027c2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027c4:	180026f3          	csrr	a3,satp
    800027c8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027ca:	6d38                	ld	a4,88(a0)
    800027cc:	6134                	ld	a3,64(a0)
    800027ce:	6585                	lui	a1,0x1
    800027d0:	96ae                	add	a3,a3,a1
    800027d2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027d4:	6d38                	ld	a4,88(a0)
    800027d6:	00000697          	auipc	a3,0x0
    800027da:	13868693          	addi	a3,a3,312 # 8000290e <usertrap>
    800027de:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027e0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027e2:	8692                	mv	a3,tp
    800027e4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027ea:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027ee:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027f2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027f6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027f8:	6f18                	ld	a4,24(a4)
    800027fa:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027fe:	692c                	ld	a1,80(a0)
    80002800:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002802:	00005717          	auipc	a4,0x5
    80002806:	88e70713          	addi	a4,a4,-1906 # 80007090 <userret>
    8000280a:	8f11                	sub	a4,a4,a2
    8000280c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000280e:	577d                	li	a4,-1
    80002810:	177e                	slli	a4,a4,0x3f
    80002812:	8dd9                	or	a1,a1,a4
    80002814:	02000537          	lui	a0,0x2000
    80002818:	157d                	addi	a0,a0,-1
    8000281a:	0536                	slli	a0,a0,0xd
    8000281c:	9782                	jalr	a5
}
    8000281e:	60a2                	ld	ra,8(sp)
    80002820:	6402                	ld	s0,0(sp)
    80002822:	0141                	addi	sp,sp,16
    80002824:	8082                	ret

0000000080002826 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002826:	1101                	addi	sp,sp,-32
    80002828:	ec06                	sd	ra,24(sp)
    8000282a:	e822                	sd	s0,16(sp)
    8000282c:	e426                	sd	s1,8(sp)
    8000282e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002830:	00015497          	auipc	s1,0x15
    80002834:	f3848493          	addi	s1,s1,-200 # 80017768 <tickslock>
    80002838:	8526                	mv	a0,s1
    8000283a:	ffffe097          	auipc	ra,0xffffe
    8000283e:	3d6080e7          	jalr	982(ra) # 80000c10 <acquire>
  ticks++;
    80002842:	00006517          	auipc	a0,0x6
    80002846:	7de50513          	addi	a0,a0,2014 # 80009020 <ticks>
    8000284a:	411c                	lw	a5,0(a0)
    8000284c:	2785                	addiw	a5,a5,1
    8000284e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002850:	00000097          	auipc	ra,0x0
    80002854:	c58080e7          	jalr	-936(ra) # 800024a8 <wakeup>
  release(&tickslock);
    80002858:	8526                	mv	a0,s1
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	46a080e7          	jalr	1130(ra) # 80000cc4 <release>
}
    80002862:	60e2                	ld	ra,24(sp)
    80002864:	6442                	ld	s0,16(sp)
    80002866:	64a2                	ld	s1,8(sp)
    80002868:	6105                	addi	sp,sp,32
    8000286a:	8082                	ret

000000008000286c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000286c:	1101                	addi	sp,sp,-32
    8000286e:	ec06                	sd	ra,24(sp)
    80002870:	e822                	sd	s0,16(sp)
    80002872:	e426                	sd	s1,8(sp)
    80002874:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002876:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000287a:	00074d63          	bltz	a4,80002894 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000287e:	57fd                	li	a5,-1
    80002880:	17fe                	slli	a5,a5,0x3f
    80002882:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002884:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002886:	06f70363          	beq	a4,a5,800028ec <devintr+0x80>
  }
}
    8000288a:	60e2                	ld	ra,24(sp)
    8000288c:	6442                	ld	s0,16(sp)
    8000288e:	64a2                	ld	s1,8(sp)
    80002890:	6105                	addi	sp,sp,32
    80002892:	8082                	ret
     (scause & 0xff) == 9){
    80002894:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002898:	46a5                	li	a3,9
    8000289a:	fed792e3          	bne	a5,a3,8000287e <devintr+0x12>
    int irq = plic_claim();
    8000289e:	00003097          	auipc	ra,0x3
    800028a2:	4fa080e7          	jalr	1274(ra) # 80005d98 <plic_claim>
    800028a6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028a8:	47a9                	li	a5,10
    800028aa:	02f50763          	beq	a0,a5,800028d8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800028ae:	4785                	li	a5,1
    800028b0:	02f50963          	beq	a0,a5,800028e2 <devintr+0x76>
    return 1;
    800028b4:	4505                	li	a0,1
    } else if(irq){
    800028b6:	d8f1                	beqz	s1,8000288a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028b8:	85a6                	mv	a1,s1
    800028ba:	00006517          	auipc	a0,0x6
    800028be:	9ee50513          	addi	a0,a0,-1554 # 800082a8 <states.1706+0x30>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	cd0080e7          	jalr	-816(ra) # 80000592 <printf>
      plic_complete(irq);
    800028ca:	8526                	mv	a0,s1
    800028cc:	00003097          	auipc	ra,0x3
    800028d0:	4f0080e7          	jalr	1264(ra) # 80005dbc <plic_complete>
    return 1;
    800028d4:	4505                	li	a0,1
    800028d6:	bf55                	j	8000288a <devintr+0x1e>
      uartintr();
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	0fc080e7          	jalr	252(ra) # 800009d4 <uartintr>
    800028e0:	b7ed                	j	800028ca <devintr+0x5e>
      virtio_disk_intr();
    800028e2:	00004097          	auipc	ra,0x4
    800028e6:	974080e7          	jalr	-1676(ra) # 80006256 <virtio_disk_intr>
    800028ea:	b7c5                	j	800028ca <devintr+0x5e>
    if(cpuid() == 0){
    800028ec:	fffff097          	auipc	ra,0xfffff
    800028f0:	1fa080e7          	jalr	506(ra) # 80001ae6 <cpuid>
    800028f4:	c901                	beqz	a0,80002904 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028f6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028fa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028fc:	14479073          	csrw	sip,a5
    return 2;
    80002900:	4509                	li	a0,2
    80002902:	b761                	j	8000288a <devintr+0x1e>
      clockintr();
    80002904:	00000097          	auipc	ra,0x0
    80002908:	f22080e7          	jalr	-222(ra) # 80002826 <clockintr>
    8000290c:	b7ed                	j	800028f6 <devintr+0x8a>

000000008000290e <usertrap>:
{
    8000290e:	1101                	addi	sp,sp,-32
    80002910:	ec06                	sd	ra,24(sp)
    80002912:	e822                	sd	s0,16(sp)
    80002914:	e426                	sd	s1,8(sp)
    80002916:	e04a                	sd	s2,0(sp)
    80002918:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000291e:	1007f793          	andi	a5,a5,256
    80002922:	e3ad                	bnez	a5,80002984 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002924:	00003797          	auipc	a5,0x3
    80002928:	36c78793          	addi	a5,a5,876 # 80005c90 <kernelvec>
    8000292c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002930:	fffff097          	auipc	ra,0xfffff
    80002934:	1e2080e7          	jalr	482(ra) # 80001b12 <myproc>
    80002938:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000293a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000293c:	14102773          	csrr	a4,sepc
    80002940:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002942:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002946:	47a1                	li	a5,8
    80002948:	04f71c63          	bne	a4,a5,800029a0 <usertrap+0x92>
    if(p->killed)
    8000294c:	591c                	lw	a5,48(a0)
    8000294e:	e3b9                	bnez	a5,80002994 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002950:	6cb8                	ld	a4,88(s1)
    80002952:	6f1c                	ld	a5,24(a4)
    80002954:	0791                	addi	a5,a5,4
    80002956:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002958:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000295c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002960:	10079073          	csrw	sstatus,a5
    syscall();
    80002964:	00000097          	auipc	ra,0x0
    80002968:	30a080e7          	jalr	778(ra) # 80002c6e <syscall>
  if(p->killed)
    8000296c:	589c                	lw	a5,48(s1)
    8000296e:	e3cd                	bnez	a5,80002a10 <usertrap+0x102>
  usertrapret();
    80002970:	00000097          	auipc	ra,0x0
    80002974:	e18080e7          	jalr	-488(ra) # 80002788 <usertrapret>
}
    80002978:	60e2                	ld	ra,24(sp)
    8000297a:	6442                	ld	s0,16(sp)
    8000297c:	64a2                	ld	s1,8(sp)
    8000297e:	6902                	ld	s2,0(sp)
    80002980:	6105                	addi	sp,sp,32
    80002982:	8082                	ret
    panic("usertrap: not from user mode");
    80002984:	00006517          	auipc	a0,0x6
    80002988:	94450513          	addi	a0,a0,-1724 # 800082c8 <states.1706+0x50>
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	bbc080e7          	jalr	-1092(ra) # 80000548 <panic>
      exit(-1);
    80002994:	557d                	li	a0,-1
    80002996:	00000097          	auipc	ra,0x0
    8000299a:	846080e7          	jalr	-1978(ra) # 800021dc <exit>
    8000299e:	bf4d                	j	80002950 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800029a0:	00000097          	auipc	ra,0x0
    800029a4:	ecc080e7          	jalr	-308(ra) # 8000286c <devintr>
    800029a8:	892a                	mv	s2,a0
    800029aa:	e125                	bnez	a0,80002a0a <usertrap+0xfc>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ac:	14202773          	csrr	a4,scause
  } else if (r_scause() == 13 || r_scause() == 15) {
    800029b0:	47b5                	li	a5,13
    800029b2:	00f70763          	beq	a4,a5,800029c0 <usertrap+0xb2>
    800029b6:	14202773          	csrr	a4,scause
    800029ba:	47bd                	li	a5,15
    800029bc:	00f71d63          	bne	a4,a5,800029d6 <usertrap+0xc8>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029c0:	14302573          	csrr	a0,stval
    if (lazy_alloc(addr) < 0) {
    800029c4:	fffff097          	auipc	ra,0xfffff
    800029c8:	c80080e7          	jalr	-896(ra) # 80001644 <lazy_alloc>
    800029cc:	fa0550e3          	bgez	a0,8000296c <usertrap+0x5e>
      p->killed = 1;
    800029d0:	4785                	li	a5,1
    800029d2:	d89c                	sw	a5,48(s1)
    800029d4:	a83d                	j	80002a12 <usertrap+0x104>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029d6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029da:	5c90                	lw	a2,56(s1)
    800029dc:	00006517          	auipc	a0,0x6
    800029e0:	90c50513          	addi	a0,a0,-1780 # 800082e8 <states.1706+0x70>
    800029e4:	ffffe097          	auipc	ra,0xffffe
    800029e8:	bae080e7          	jalr	-1106(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ec:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029f0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029f4:	00006517          	auipc	a0,0x6
    800029f8:	92450513          	addi	a0,a0,-1756 # 80008318 <states.1706+0xa0>
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	b96080e7          	jalr	-1130(ra) # 80000592 <printf>
    p->killed = 1;
    80002a04:	4785                	li	a5,1
    80002a06:	d89c                	sw	a5,48(s1)
    80002a08:	a029                	j	80002a12 <usertrap+0x104>
  if(p->killed)
    80002a0a:	589c                	lw	a5,48(s1)
    80002a0c:	cb81                	beqz	a5,80002a1c <usertrap+0x10e>
    80002a0e:	a011                	j	80002a12 <usertrap+0x104>
    80002a10:	4901                	li	s2,0
    exit(-1);
    80002a12:	557d                	li	a0,-1
    80002a14:	fffff097          	auipc	ra,0xfffff
    80002a18:	7c8080e7          	jalr	1992(ra) # 800021dc <exit>
  if(which_dev == 2)
    80002a1c:	4789                	li	a5,2
    80002a1e:	f4f919e3          	bne	s2,a5,80002970 <usertrap+0x62>
    yield();
    80002a22:	00000097          	auipc	ra,0x0
    80002a26:	8c4080e7          	jalr	-1852(ra) # 800022e6 <yield>
    80002a2a:	b799                	j	80002970 <usertrap+0x62>

0000000080002a2c <kerneltrap>:
{
    80002a2c:	7179                	addi	sp,sp,-48
    80002a2e:	f406                	sd	ra,40(sp)
    80002a30:	f022                	sd	s0,32(sp)
    80002a32:	ec26                	sd	s1,24(sp)
    80002a34:	e84a                	sd	s2,16(sp)
    80002a36:	e44e                	sd	s3,8(sp)
    80002a38:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a3a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a3e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a42:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a46:	1004f793          	andi	a5,s1,256
    80002a4a:	cb85                	beqz	a5,80002a7a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a50:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a52:	ef85                	bnez	a5,80002a8a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a54:	00000097          	auipc	ra,0x0
    80002a58:	e18080e7          	jalr	-488(ra) # 8000286c <devintr>
    80002a5c:	cd1d                	beqz	a0,80002a9a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a5e:	4789                	li	a5,2
    80002a60:	06f50a63          	beq	a0,a5,80002ad4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a64:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a68:	10049073          	csrw	sstatus,s1
}
    80002a6c:	70a2                	ld	ra,40(sp)
    80002a6e:	7402                	ld	s0,32(sp)
    80002a70:	64e2                	ld	s1,24(sp)
    80002a72:	6942                	ld	s2,16(sp)
    80002a74:	69a2                	ld	s3,8(sp)
    80002a76:	6145                	addi	sp,sp,48
    80002a78:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a7a:	00006517          	auipc	a0,0x6
    80002a7e:	8be50513          	addi	a0,a0,-1858 # 80008338 <states.1706+0xc0>
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	ac6080e7          	jalr	-1338(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a8a:	00006517          	auipc	a0,0x6
    80002a8e:	8d650513          	addi	a0,a0,-1834 # 80008360 <states.1706+0xe8>
    80002a92:	ffffe097          	auipc	ra,0xffffe
    80002a96:	ab6080e7          	jalr	-1354(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002a9a:	85ce                	mv	a1,s3
    80002a9c:	00006517          	auipc	a0,0x6
    80002aa0:	8e450513          	addi	a0,a0,-1820 # 80008380 <states.1706+0x108>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	aee080e7          	jalr	-1298(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aac:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ab0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ab4:	00006517          	auipc	a0,0x6
    80002ab8:	8dc50513          	addi	a0,a0,-1828 # 80008390 <states.1706+0x118>
    80002abc:	ffffe097          	auipc	ra,0xffffe
    80002ac0:	ad6080e7          	jalr	-1322(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002ac4:	00006517          	auipc	a0,0x6
    80002ac8:	8e450513          	addi	a0,a0,-1820 # 800083a8 <states.1706+0x130>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	a7c080e7          	jalr	-1412(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	03e080e7          	jalr	62(ra) # 80001b12 <myproc>
    80002adc:	d541                	beqz	a0,80002a64 <kerneltrap+0x38>
    80002ade:	fffff097          	auipc	ra,0xfffff
    80002ae2:	034080e7          	jalr	52(ra) # 80001b12 <myproc>
    80002ae6:	4d18                	lw	a4,24(a0)
    80002ae8:	478d                	li	a5,3
    80002aea:	f6f71de3          	bne	a4,a5,80002a64 <kerneltrap+0x38>
    yield();
    80002aee:	fffff097          	auipc	ra,0xfffff
    80002af2:	7f8080e7          	jalr	2040(ra) # 800022e6 <yield>
    80002af6:	b7bd                	j	80002a64 <kerneltrap+0x38>

0000000080002af8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002af8:	1101                	addi	sp,sp,-32
    80002afa:	ec06                	sd	ra,24(sp)
    80002afc:	e822                	sd	s0,16(sp)
    80002afe:	e426                	sd	s1,8(sp)
    80002b00:	1000                	addi	s0,sp,32
    80002b02:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b04:	fffff097          	auipc	ra,0xfffff
    80002b08:	00e080e7          	jalr	14(ra) # 80001b12 <myproc>
  switch (n) {
    80002b0c:	4795                	li	a5,5
    80002b0e:	0497e163          	bltu	a5,s1,80002b50 <argraw+0x58>
    80002b12:	048a                	slli	s1,s1,0x2
    80002b14:	00006717          	auipc	a4,0x6
    80002b18:	8cc70713          	addi	a4,a4,-1844 # 800083e0 <states.1706+0x168>
    80002b1c:	94ba                	add	s1,s1,a4
    80002b1e:	409c                	lw	a5,0(s1)
    80002b20:	97ba                	add	a5,a5,a4
    80002b22:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b24:	6d3c                	ld	a5,88(a0)
    80002b26:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6105                	addi	sp,sp,32
    80002b30:	8082                	ret
    return p->trapframe->a1;
    80002b32:	6d3c                	ld	a5,88(a0)
    80002b34:	7fa8                	ld	a0,120(a5)
    80002b36:	bfcd                	j	80002b28 <argraw+0x30>
    return p->trapframe->a2;
    80002b38:	6d3c                	ld	a5,88(a0)
    80002b3a:	63c8                	ld	a0,128(a5)
    80002b3c:	b7f5                	j	80002b28 <argraw+0x30>
    return p->trapframe->a3;
    80002b3e:	6d3c                	ld	a5,88(a0)
    80002b40:	67c8                	ld	a0,136(a5)
    80002b42:	b7dd                	j	80002b28 <argraw+0x30>
    return p->trapframe->a4;
    80002b44:	6d3c                	ld	a5,88(a0)
    80002b46:	6bc8                	ld	a0,144(a5)
    80002b48:	b7c5                	j	80002b28 <argraw+0x30>
    return p->trapframe->a5;
    80002b4a:	6d3c                	ld	a5,88(a0)
    80002b4c:	6fc8                	ld	a0,152(a5)
    80002b4e:	bfe9                	j	80002b28 <argraw+0x30>
  panic("argraw");
    80002b50:	00006517          	auipc	a0,0x6
    80002b54:	86850513          	addi	a0,a0,-1944 # 800083b8 <states.1706+0x140>
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	9f0080e7          	jalr	-1552(ra) # 80000548 <panic>

0000000080002b60 <fetchaddr>:
{
    80002b60:	1101                	addi	sp,sp,-32
    80002b62:	ec06                	sd	ra,24(sp)
    80002b64:	e822                	sd	s0,16(sp)
    80002b66:	e426                	sd	s1,8(sp)
    80002b68:	e04a                	sd	s2,0(sp)
    80002b6a:	1000                	addi	s0,sp,32
    80002b6c:	84aa                	mv	s1,a0
    80002b6e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	fa2080e7          	jalr	-94(ra) # 80001b12 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b78:	653c                	ld	a5,72(a0)
    80002b7a:	02f4f863          	bgeu	s1,a5,80002baa <fetchaddr+0x4a>
    80002b7e:	00848713          	addi	a4,s1,8
    80002b82:	02e7e663          	bltu	a5,a4,80002bae <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b86:	46a1                	li	a3,8
    80002b88:	8626                	mv	a2,s1
    80002b8a:	85ca                	mv	a1,s2
    80002b8c:	6928                	ld	a0,80(a0)
    80002b8e:	fffff097          	auipc	ra,0xfffff
    80002b92:	c2a080e7          	jalr	-982(ra) # 800017b8 <copyin>
    80002b96:	00a03533          	snez	a0,a0
    80002b9a:	40a00533          	neg	a0,a0
}
    80002b9e:	60e2                	ld	ra,24(sp)
    80002ba0:	6442                	ld	s0,16(sp)
    80002ba2:	64a2                	ld	s1,8(sp)
    80002ba4:	6902                	ld	s2,0(sp)
    80002ba6:	6105                	addi	sp,sp,32
    80002ba8:	8082                	ret
    return -1;
    80002baa:	557d                	li	a0,-1
    80002bac:	bfcd                	j	80002b9e <fetchaddr+0x3e>
    80002bae:	557d                	li	a0,-1
    80002bb0:	b7fd                	j	80002b9e <fetchaddr+0x3e>

0000000080002bb2 <fetchstr>:
{
    80002bb2:	7179                	addi	sp,sp,-48
    80002bb4:	f406                	sd	ra,40(sp)
    80002bb6:	f022                	sd	s0,32(sp)
    80002bb8:	ec26                	sd	s1,24(sp)
    80002bba:	e84a                	sd	s2,16(sp)
    80002bbc:	e44e                	sd	s3,8(sp)
    80002bbe:	1800                	addi	s0,sp,48
    80002bc0:	892a                	mv	s2,a0
    80002bc2:	84ae                	mv	s1,a1
    80002bc4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	f4c080e7          	jalr	-180(ra) # 80001b12 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bce:	86ce                	mv	a3,s3
    80002bd0:	864a                	mv	a2,s2
    80002bd2:	85a6                	mv	a1,s1
    80002bd4:	6928                	ld	a0,80(a0)
    80002bd6:	fffff097          	auipc	ra,0xfffff
    80002bda:	c6e080e7          	jalr	-914(ra) # 80001844 <copyinstr>
  if(err < 0)
    80002bde:	00054763          	bltz	a0,80002bec <fetchstr+0x3a>
  return strlen(buf);
    80002be2:	8526                	mv	a0,s1
    80002be4:	ffffe097          	auipc	ra,0xffffe
    80002be8:	2b0080e7          	jalr	688(ra) # 80000e94 <strlen>
}
    80002bec:	70a2                	ld	ra,40(sp)
    80002bee:	7402                	ld	s0,32(sp)
    80002bf0:	64e2                	ld	s1,24(sp)
    80002bf2:	6942                	ld	s2,16(sp)
    80002bf4:	69a2                	ld	s3,8(sp)
    80002bf6:	6145                	addi	sp,sp,48
    80002bf8:	8082                	ret

0000000080002bfa <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002bfa:	1101                	addi	sp,sp,-32
    80002bfc:	ec06                	sd	ra,24(sp)
    80002bfe:	e822                	sd	s0,16(sp)
    80002c00:	e426                	sd	s1,8(sp)
    80002c02:	1000                	addi	s0,sp,32
    80002c04:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c06:	00000097          	auipc	ra,0x0
    80002c0a:	ef2080e7          	jalr	-270(ra) # 80002af8 <argraw>
    80002c0e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c10:	4501                	li	a0,0
    80002c12:	60e2                	ld	ra,24(sp)
    80002c14:	6442                	ld	s0,16(sp)
    80002c16:	64a2                	ld	s1,8(sp)
    80002c18:	6105                	addi	sp,sp,32
    80002c1a:	8082                	ret

0000000080002c1c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c1c:	1101                	addi	sp,sp,-32
    80002c1e:	ec06                	sd	ra,24(sp)
    80002c20:	e822                	sd	s0,16(sp)
    80002c22:	e426                	sd	s1,8(sp)
    80002c24:	1000                	addi	s0,sp,32
    80002c26:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	ed0080e7          	jalr	-304(ra) # 80002af8 <argraw>
    80002c30:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c32:	4501                	li	a0,0
    80002c34:	60e2                	ld	ra,24(sp)
    80002c36:	6442                	ld	s0,16(sp)
    80002c38:	64a2                	ld	s1,8(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret

0000000080002c3e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c3e:	1101                	addi	sp,sp,-32
    80002c40:	ec06                	sd	ra,24(sp)
    80002c42:	e822                	sd	s0,16(sp)
    80002c44:	e426                	sd	s1,8(sp)
    80002c46:	e04a                	sd	s2,0(sp)
    80002c48:	1000                	addi	s0,sp,32
    80002c4a:	84ae                	mv	s1,a1
    80002c4c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	eaa080e7          	jalr	-342(ra) # 80002af8 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c56:	864a                	mv	a2,s2
    80002c58:	85a6                	mv	a1,s1
    80002c5a:	00000097          	auipc	ra,0x0
    80002c5e:	f58080e7          	jalr	-168(ra) # 80002bb2 <fetchstr>
}
    80002c62:	60e2                	ld	ra,24(sp)
    80002c64:	6442                	ld	s0,16(sp)
    80002c66:	64a2                	ld	s1,8(sp)
    80002c68:	6902                	ld	s2,0(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret

0000000080002c6e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002c6e:	1101                	addi	sp,sp,-32
    80002c70:	ec06                	sd	ra,24(sp)
    80002c72:	e822                	sd	s0,16(sp)
    80002c74:	e426                	sd	s1,8(sp)
    80002c76:	e04a                	sd	s2,0(sp)
    80002c78:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c7a:	fffff097          	auipc	ra,0xfffff
    80002c7e:	e98080e7          	jalr	-360(ra) # 80001b12 <myproc>
    80002c82:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c84:	05853903          	ld	s2,88(a0)
    80002c88:	0a893783          	ld	a5,168(s2)
    80002c8c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c90:	37fd                	addiw	a5,a5,-1
    80002c92:	4751                	li	a4,20
    80002c94:	00f76f63          	bltu	a4,a5,80002cb2 <syscall+0x44>
    80002c98:	00369713          	slli	a4,a3,0x3
    80002c9c:	00005797          	auipc	a5,0x5
    80002ca0:	75c78793          	addi	a5,a5,1884 # 800083f8 <syscalls>
    80002ca4:	97ba                	add	a5,a5,a4
    80002ca6:	639c                	ld	a5,0(a5)
    80002ca8:	c789                	beqz	a5,80002cb2 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002caa:	9782                	jalr	a5
    80002cac:	06a93823          	sd	a0,112(s2)
    80002cb0:	a839                	j	80002cce <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cb2:	15848613          	addi	a2,s1,344
    80002cb6:	5c8c                	lw	a1,56(s1)
    80002cb8:	00005517          	auipc	a0,0x5
    80002cbc:	70850513          	addi	a0,a0,1800 # 800083c0 <states.1706+0x148>
    80002cc0:	ffffe097          	auipc	ra,0xffffe
    80002cc4:	8d2080e7          	jalr	-1838(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cc8:	6cbc                	ld	a5,88(s1)
    80002cca:	577d                	li	a4,-1
    80002ccc:	fbb8                	sd	a4,112(a5)
  }
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	64a2                	ld	s1,8(sp)
    80002cd4:	6902                	ld	s2,0(sp)
    80002cd6:	6105                	addi	sp,sp,32
    80002cd8:	8082                	ret

0000000080002cda <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cda:	1101                	addi	sp,sp,-32
    80002cdc:	ec06                	sd	ra,24(sp)
    80002cde:	e822                	sd	s0,16(sp)
    80002ce0:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002ce2:	fec40593          	addi	a1,s0,-20
    80002ce6:	4501                	li	a0,0
    80002ce8:	00000097          	auipc	ra,0x0
    80002cec:	f12080e7          	jalr	-238(ra) # 80002bfa <argint>
    return -1;
    80002cf0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cf2:	00054963          	bltz	a0,80002d04 <sys_exit+0x2a>
  exit(n);
    80002cf6:	fec42503          	lw	a0,-20(s0)
    80002cfa:	fffff097          	auipc	ra,0xfffff
    80002cfe:	4e2080e7          	jalr	1250(ra) # 800021dc <exit>
  return 0;  // not reached
    80002d02:	4781                	li	a5,0
}
    80002d04:	853e                	mv	a0,a5
    80002d06:	60e2                	ld	ra,24(sp)
    80002d08:	6442                	ld	s0,16(sp)
    80002d0a:	6105                	addi	sp,sp,32
    80002d0c:	8082                	ret

0000000080002d0e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d0e:	1141                	addi	sp,sp,-16
    80002d10:	e406                	sd	ra,8(sp)
    80002d12:	e022                	sd	s0,0(sp)
    80002d14:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d16:	fffff097          	auipc	ra,0xfffff
    80002d1a:	dfc080e7          	jalr	-516(ra) # 80001b12 <myproc>
}
    80002d1e:	5d08                	lw	a0,56(a0)
    80002d20:	60a2                	ld	ra,8(sp)
    80002d22:	6402                	ld	s0,0(sp)
    80002d24:	0141                	addi	sp,sp,16
    80002d26:	8082                	ret

0000000080002d28 <sys_fork>:

uint64
sys_fork(void)
{
    80002d28:	1141                	addi	sp,sp,-16
    80002d2a:	e406                	sd	ra,8(sp)
    80002d2c:	e022                	sd	s0,0(sp)
    80002d2e:	0800                	addi	s0,sp,16
  return fork();
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	1a2080e7          	jalr	418(ra) # 80001ed2 <fork>
}
    80002d38:	60a2                	ld	ra,8(sp)
    80002d3a:	6402                	ld	s0,0(sp)
    80002d3c:	0141                	addi	sp,sp,16
    80002d3e:	8082                	ret

0000000080002d40 <sys_wait>:

uint64
sys_wait(void)
{
    80002d40:	1101                	addi	sp,sp,-32
    80002d42:	ec06                	sd	ra,24(sp)
    80002d44:	e822                	sd	s0,16(sp)
    80002d46:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d48:	fe840593          	addi	a1,s0,-24
    80002d4c:	4501                	li	a0,0
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	ece080e7          	jalr	-306(ra) # 80002c1c <argaddr>
    80002d56:	87aa                	mv	a5,a0
    return -1;
    80002d58:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d5a:	0007c863          	bltz	a5,80002d6a <sys_wait+0x2a>
  return wait(p);
    80002d5e:	fe843503          	ld	a0,-24(s0)
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	63e080e7          	jalr	1598(ra) # 800023a0 <wait>
}
    80002d6a:	60e2                	ld	ra,24(sp)
    80002d6c:	6442                	ld	s0,16(sp)
    80002d6e:	6105                	addi	sp,sp,32
    80002d70:	8082                	ret

0000000080002d72 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d72:	7179                	addi	sp,sp,-48
    80002d74:	f406                	sd	ra,40(sp)
    80002d76:	f022                	sd	s0,32(sp)
    80002d78:	ec26                	sd	s1,24(sp)
    80002d7a:	e84a                	sd	s2,16(sp)
    80002d7c:	1800                	addi	s0,sp,48
  int addr;
  int n;
  if(argint(0, &n) < 0)
    80002d7e:	fdc40593          	addi	a1,s0,-36
    80002d82:	4501                	li	a0,0
    80002d84:	00000097          	auipc	ra,0x0
    80002d88:	e76080e7          	jalr	-394(ra) # 80002bfa <argint>
    return -1;
    80002d8c:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002d8e:	02054063          	bltz	a0,80002dae <sys_sbrk+0x3c>

  struct proc *p = myproc();
    80002d92:	fffff097          	auipc	ra,0xfffff
    80002d96:	d80080e7          	jalr	-640(ra) # 80001b12 <myproc>
    80002d9a:	892a                	mv	s2,a0
  addr = p->sz;
    80002d9c:	653c                	ld	a5,72(a0)
    80002d9e:	0007849b          	sext.w	s1,a5
  p->sz += n;
    80002da2:	fdc42603          	lw	a2,-36(s0)
    80002da6:	97b2                	add	a5,a5,a2
    80002da8:	e53c                	sd	a5,72(a0)
  if(n < 0) {
    80002daa:	00064963          	bltz	a2,80002dbc <sys_sbrk+0x4a>
    p->sz = uvmdealloc(p->pagetable, addr, addr + n);
  }
  // if(growproc(n) < 0)
  //  return -1;
  return addr;
}
    80002dae:	8526                	mv	a0,s1
    80002db0:	70a2                	ld	ra,40(sp)
    80002db2:	7402                	ld	s0,32(sp)
    80002db4:	64e2                	ld	s1,24(sp)
    80002db6:	6942                	ld	s2,16(sp)
    80002db8:	6145                	addi	sp,sp,48
    80002dba:	8082                	ret
    p->sz = uvmdealloc(p->pagetable, addr, addr + n);
    80002dbc:	9e25                	addw	a2,a2,s1
    80002dbe:	85a6                	mv	a1,s1
    80002dc0:	6928                	ld	a0,80(a0)
    80002dc2:	ffffe097          	auipc	ra,0xffffe
    80002dc6:	618080e7          	jalr	1560(ra) # 800013da <uvmdealloc>
    80002dca:	04a93423          	sd	a0,72(s2)
  return addr;
    80002dce:	b7c5                	j	80002dae <sys_sbrk+0x3c>

0000000080002dd0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dd0:	7139                	addi	sp,sp,-64
    80002dd2:	fc06                	sd	ra,56(sp)
    80002dd4:	f822                	sd	s0,48(sp)
    80002dd6:	f426                	sd	s1,40(sp)
    80002dd8:	f04a                	sd	s2,32(sp)
    80002dda:	ec4e                	sd	s3,24(sp)
    80002ddc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002dde:	fcc40593          	addi	a1,s0,-52
    80002de2:	4501                	li	a0,0
    80002de4:	00000097          	auipc	ra,0x0
    80002de8:	e16080e7          	jalr	-490(ra) # 80002bfa <argint>
    return -1;
    80002dec:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dee:	06054563          	bltz	a0,80002e58 <sys_sleep+0x88>
  acquire(&tickslock);
    80002df2:	00015517          	auipc	a0,0x15
    80002df6:	97650513          	addi	a0,a0,-1674 # 80017768 <tickslock>
    80002dfa:	ffffe097          	auipc	ra,0xffffe
    80002dfe:	e16080e7          	jalr	-490(ra) # 80000c10 <acquire>
  ticks0 = ticks;
    80002e02:	00006917          	auipc	s2,0x6
    80002e06:	21e92903          	lw	s2,542(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002e0a:	fcc42783          	lw	a5,-52(s0)
    80002e0e:	cf85                	beqz	a5,80002e46 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e10:	00015997          	auipc	s3,0x15
    80002e14:	95898993          	addi	s3,s3,-1704 # 80017768 <tickslock>
    80002e18:	00006497          	auipc	s1,0x6
    80002e1c:	20848493          	addi	s1,s1,520 # 80009020 <ticks>
    if(myproc()->killed){
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	cf2080e7          	jalr	-782(ra) # 80001b12 <myproc>
    80002e28:	591c                	lw	a5,48(a0)
    80002e2a:	ef9d                	bnez	a5,80002e68 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002e2c:	85ce                	mv	a1,s3
    80002e2e:	8526                	mv	a0,s1
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	4f2080e7          	jalr	1266(ra) # 80002322 <sleep>
  while(ticks - ticks0 < n){
    80002e38:	409c                	lw	a5,0(s1)
    80002e3a:	412787bb          	subw	a5,a5,s2
    80002e3e:	fcc42703          	lw	a4,-52(s0)
    80002e42:	fce7efe3          	bltu	a5,a4,80002e20 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e46:	00015517          	auipc	a0,0x15
    80002e4a:	92250513          	addi	a0,a0,-1758 # 80017768 <tickslock>
    80002e4e:	ffffe097          	auipc	ra,0xffffe
    80002e52:	e76080e7          	jalr	-394(ra) # 80000cc4 <release>
  return 0;
    80002e56:	4781                	li	a5,0
}
    80002e58:	853e                	mv	a0,a5
    80002e5a:	70e2                	ld	ra,56(sp)
    80002e5c:	7442                	ld	s0,48(sp)
    80002e5e:	74a2                	ld	s1,40(sp)
    80002e60:	7902                	ld	s2,32(sp)
    80002e62:	69e2                	ld	s3,24(sp)
    80002e64:	6121                	addi	sp,sp,64
    80002e66:	8082                	ret
      release(&tickslock);
    80002e68:	00015517          	auipc	a0,0x15
    80002e6c:	90050513          	addi	a0,a0,-1792 # 80017768 <tickslock>
    80002e70:	ffffe097          	auipc	ra,0xffffe
    80002e74:	e54080e7          	jalr	-428(ra) # 80000cc4 <release>
      return -1;
    80002e78:	57fd                	li	a5,-1
    80002e7a:	bff9                	j	80002e58 <sys_sleep+0x88>

0000000080002e7c <sys_kill>:

uint64
sys_kill(void)
{
    80002e7c:	1101                	addi	sp,sp,-32
    80002e7e:	ec06                	sd	ra,24(sp)
    80002e80:	e822                	sd	s0,16(sp)
    80002e82:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e84:	fec40593          	addi	a1,s0,-20
    80002e88:	4501                	li	a0,0
    80002e8a:	00000097          	auipc	ra,0x0
    80002e8e:	d70080e7          	jalr	-656(ra) # 80002bfa <argint>
    80002e92:	87aa                	mv	a5,a0
    return -1;
    80002e94:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e96:	0007c863          	bltz	a5,80002ea6 <sys_kill+0x2a>
  return kill(pid);
    80002e9a:	fec42503          	lw	a0,-20(s0)
    80002e9e:	fffff097          	auipc	ra,0xfffff
    80002ea2:	674080e7          	jalr	1652(ra) # 80002512 <kill>
}
    80002ea6:	60e2                	ld	ra,24(sp)
    80002ea8:	6442                	ld	s0,16(sp)
    80002eaa:	6105                	addi	sp,sp,32
    80002eac:	8082                	ret

0000000080002eae <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002eae:	1101                	addi	sp,sp,-32
    80002eb0:	ec06                	sd	ra,24(sp)
    80002eb2:	e822                	sd	s0,16(sp)
    80002eb4:	e426                	sd	s1,8(sp)
    80002eb6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002eb8:	00015517          	auipc	a0,0x15
    80002ebc:	8b050513          	addi	a0,a0,-1872 # 80017768 <tickslock>
    80002ec0:	ffffe097          	auipc	ra,0xffffe
    80002ec4:	d50080e7          	jalr	-688(ra) # 80000c10 <acquire>
  xticks = ticks;
    80002ec8:	00006497          	auipc	s1,0x6
    80002ecc:	1584a483          	lw	s1,344(s1) # 80009020 <ticks>
  release(&tickslock);
    80002ed0:	00015517          	auipc	a0,0x15
    80002ed4:	89850513          	addi	a0,a0,-1896 # 80017768 <tickslock>
    80002ed8:	ffffe097          	auipc	ra,0xffffe
    80002edc:	dec080e7          	jalr	-532(ra) # 80000cc4 <release>
  return xticks;
}
    80002ee0:	02049513          	slli	a0,s1,0x20
    80002ee4:	9101                	srli	a0,a0,0x20
    80002ee6:	60e2                	ld	ra,24(sp)
    80002ee8:	6442                	ld	s0,16(sp)
    80002eea:	64a2                	ld	s1,8(sp)
    80002eec:	6105                	addi	sp,sp,32
    80002eee:	8082                	ret

0000000080002ef0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ef0:	7179                	addi	sp,sp,-48
    80002ef2:	f406                	sd	ra,40(sp)
    80002ef4:	f022                	sd	s0,32(sp)
    80002ef6:	ec26                	sd	s1,24(sp)
    80002ef8:	e84a                	sd	s2,16(sp)
    80002efa:	e44e                	sd	s3,8(sp)
    80002efc:	e052                	sd	s4,0(sp)
    80002efe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f00:	00005597          	auipc	a1,0x5
    80002f04:	5a858593          	addi	a1,a1,1448 # 800084a8 <syscalls+0xb0>
    80002f08:	00015517          	auipc	a0,0x15
    80002f0c:	87850513          	addi	a0,a0,-1928 # 80017780 <bcache>
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	c70080e7          	jalr	-912(ra) # 80000b80 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f18:	0001d797          	auipc	a5,0x1d
    80002f1c:	86878793          	addi	a5,a5,-1944 # 8001f780 <bcache+0x8000>
    80002f20:	0001d717          	auipc	a4,0x1d
    80002f24:	ac870713          	addi	a4,a4,-1336 # 8001f9e8 <bcache+0x8268>
    80002f28:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f2c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f30:	00015497          	auipc	s1,0x15
    80002f34:	86848493          	addi	s1,s1,-1944 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002f38:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f3a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f3c:	00005a17          	auipc	s4,0x5
    80002f40:	574a0a13          	addi	s4,s4,1396 # 800084b0 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002f44:	2b893783          	ld	a5,696(s2)
    80002f48:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f4a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f4e:	85d2                	mv	a1,s4
    80002f50:	01048513          	addi	a0,s1,16
    80002f54:	00001097          	auipc	ra,0x1
    80002f58:	4b0080e7          	jalr	1200(ra) # 80004404 <initsleeplock>
    bcache.head.next->prev = b;
    80002f5c:	2b893783          	ld	a5,696(s2)
    80002f60:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f62:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f66:	45848493          	addi	s1,s1,1112
    80002f6a:	fd349de3          	bne	s1,s3,80002f44 <binit+0x54>
  }
}
    80002f6e:	70a2                	ld	ra,40(sp)
    80002f70:	7402                	ld	s0,32(sp)
    80002f72:	64e2                	ld	s1,24(sp)
    80002f74:	6942                	ld	s2,16(sp)
    80002f76:	69a2                	ld	s3,8(sp)
    80002f78:	6a02                	ld	s4,0(sp)
    80002f7a:	6145                	addi	sp,sp,48
    80002f7c:	8082                	ret

0000000080002f7e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f7e:	7179                	addi	sp,sp,-48
    80002f80:	f406                	sd	ra,40(sp)
    80002f82:	f022                	sd	s0,32(sp)
    80002f84:	ec26                	sd	s1,24(sp)
    80002f86:	e84a                	sd	s2,16(sp)
    80002f88:	e44e                	sd	s3,8(sp)
    80002f8a:	1800                	addi	s0,sp,48
    80002f8c:	89aa                	mv	s3,a0
    80002f8e:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002f90:	00014517          	auipc	a0,0x14
    80002f94:	7f050513          	addi	a0,a0,2032 # 80017780 <bcache>
    80002f98:	ffffe097          	auipc	ra,0xffffe
    80002f9c:	c78080e7          	jalr	-904(ra) # 80000c10 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fa0:	0001d497          	auipc	s1,0x1d
    80002fa4:	a984b483          	ld	s1,-1384(s1) # 8001fa38 <bcache+0x82b8>
    80002fa8:	0001d797          	auipc	a5,0x1d
    80002fac:	a4078793          	addi	a5,a5,-1472 # 8001f9e8 <bcache+0x8268>
    80002fb0:	02f48f63          	beq	s1,a5,80002fee <bread+0x70>
    80002fb4:	873e                	mv	a4,a5
    80002fb6:	a021                	j	80002fbe <bread+0x40>
    80002fb8:	68a4                	ld	s1,80(s1)
    80002fba:	02e48a63          	beq	s1,a4,80002fee <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fbe:	449c                	lw	a5,8(s1)
    80002fc0:	ff379ce3          	bne	a5,s3,80002fb8 <bread+0x3a>
    80002fc4:	44dc                	lw	a5,12(s1)
    80002fc6:	ff2799e3          	bne	a5,s2,80002fb8 <bread+0x3a>
      b->refcnt++;
    80002fca:	40bc                	lw	a5,64(s1)
    80002fcc:	2785                	addiw	a5,a5,1
    80002fce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fd0:	00014517          	auipc	a0,0x14
    80002fd4:	7b050513          	addi	a0,a0,1968 # 80017780 <bcache>
    80002fd8:	ffffe097          	auipc	ra,0xffffe
    80002fdc:	cec080e7          	jalr	-788(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    80002fe0:	01048513          	addi	a0,s1,16
    80002fe4:	00001097          	auipc	ra,0x1
    80002fe8:	45a080e7          	jalr	1114(ra) # 8000443e <acquiresleep>
      return b;
    80002fec:	a8b9                	j	8000304a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fee:	0001d497          	auipc	s1,0x1d
    80002ff2:	a424b483          	ld	s1,-1470(s1) # 8001fa30 <bcache+0x82b0>
    80002ff6:	0001d797          	auipc	a5,0x1d
    80002ffa:	9f278793          	addi	a5,a5,-1550 # 8001f9e8 <bcache+0x8268>
    80002ffe:	00f48863          	beq	s1,a5,8000300e <bread+0x90>
    80003002:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003004:	40bc                	lw	a5,64(s1)
    80003006:	cf81                	beqz	a5,8000301e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003008:	64a4                	ld	s1,72(s1)
    8000300a:	fee49de3          	bne	s1,a4,80003004 <bread+0x86>
  panic("bget: no buffers");
    8000300e:	00005517          	auipc	a0,0x5
    80003012:	4aa50513          	addi	a0,a0,1194 # 800084b8 <syscalls+0xc0>
    80003016:	ffffd097          	auipc	ra,0xffffd
    8000301a:	532080e7          	jalr	1330(ra) # 80000548 <panic>
      b->dev = dev;
    8000301e:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003022:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003026:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000302a:	4785                	li	a5,1
    8000302c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000302e:	00014517          	auipc	a0,0x14
    80003032:	75250513          	addi	a0,a0,1874 # 80017780 <bcache>
    80003036:	ffffe097          	auipc	ra,0xffffe
    8000303a:	c8e080e7          	jalr	-882(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    8000303e:	01048513          	addi	a0,s1,16
    80003042:	00001097          	auipc	ra,0x1
    80003046:	3fc080e7          	jalr	1020(ra) # 8000443e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000304a:	409c                	lw	a5,0(s1)
    8000304c:	cb89                	beqz	a5,8000305e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000304e:	8526                	mv	a0,s1
    80003050:	70a2                	ld	ra,40(sp)
    80003052:	7402                	ld	s0,32(sp)
    80003054:	64e2                	ld	s1,24(sp)
    80003056:	6942                	ld	s2,16(sp)
    80003058:	69a2                	ld	s3,8(sp)
    8000305a:	6145                	addi	sp,sp,48
    8000305c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000305e:	4581                	li	a1,0
    80003060:	8526                	mv	a0,s1
    80003062:	00003097          	auipc	ra,0x3
    80003066:	f4a080e7          	jalr	-182(ra) # 80005fac <virtio_disk_rw>
    b->valid = 1;
    8000306a:	4785                	li	a5,1
    8000306c:	c09c                	sw	a5,0(s1)
  return b;
    8000306e:	b7c5                	j	8000304e <bread+0xd0>

0000000080003070 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	1000                	addi	s0,sp,32
    8000307a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000307c:	0541                	addi	a0,a0,16
    8000307e:	00001097          	auipc	ra,0x1
    80003082:	45a080e7          	jalr	1114(ra) # 800044d8 <holdingsleep>
    80003086:	cd01                	beqz	a0,8000309e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003088:	4585                	li	a1,1
    8000308a:	8526                	mv	a0,s1
    8000308c:	00003097          	auipc	ra,0x3
    80003090:	f20080e7          	jalr	-224(ra) # 80005fac <virtio_disk_rw>
}
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	64a2                	ld	s1,8(sp)
    8000309a:	6105                	addi	sp,sp,32
    8000309c:	8082                	ret
    panic("bwrite");
    8000309e:	00005517          	auipc	a0,0x5
    800030a2:	43250513          	addi	a0,a0,1074 # 800084d0 <syscalls+0xd8>
    800030a6:	ffffd097          	auipc	ra,0xffffd
    800030aa:	4a2080e7          	jalr	1186(ra) # 80000548 <panic>

00000000800030ae <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030ae:	1101                	addi	sp,sp,-32
    800030b0:	ec06                	sd	ra,24(sp)
    800030b2:	e822                	sd	s0,16(sp)
    800030b4:	e426                	sd	s1,8(sp)
    800030b6:	e04a                	sd	s2,0(sp)
    800030b8:	1000                	addi	s0,sp,32
    800030ba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030bc:	01050913          	addi	s2,a0,16
    800030c0:	854a                	mv	a0,s2
    800030c2:	00001097          	auipc	ra,0x1
    800030c6:	416080e7          	jalr	1046(ra) # 800044d8 <holdingsleep>
    800030ca:	c92d                	beqz	a0,8000313c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800030cc:	854a                	mv	a0,s2
    800030ce:	00001097          	auipc	ra,0x1
    800030d2:	3c6080e7          	jalr	966(ra) # 80004494 <releasesleep>

  acquire(&bcache.lock);
    800030d6:	00014517          	auipc	a0,0x14
    800030da:	6aa50513          	addi	a0,a0,1706 # 80017780 <bcache>
    800030de:	ffffe097          	auipc	ra,0xffffe
    800030e2:	b32080e7          	jalr	-1230(ra) # 80000c10 <acquire>
  b->refcnt--;
    800030e6:	40bc                	lw	a5,64(s1)
    800030e8:	37fd                	addiw	a5,a5,-1
    800030ea:	0007871b          	sext.w	a4,a5
    800030ee:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030f0:	eb05                	bnez	a4,80003120 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030f2:	68bc                	ld	a5,80(s1)
    800030f4:	64b8                	ld	a4,72(s1)
    800030f6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800030f8:	64bc                	ld	a5,72(s1)
    800030fa:	68b8                	ld	a4,80(s1)
    800030fc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030fe:	0001c797          	auipc	a5,0x1c
    80003102:	68278793          	addi	a5,a5,1666 # 8001f780 <bcache+0x8000>
    80003106:	2b87b703          	ld	a4,696(a5)
    8000310a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000310c:	0001d717          	auipc	a4,0x1d
    80003110:	8dc70713          	addi	a4,a4,-1828 # 8001f9e8 <bcache+0x8268>
    80003114:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003116:	2b87b703          	ld	a4,696(a5)
    8000311a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000311c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003120:	00014517          	auipc	a0,0x14
    80003124:	66050513          	addi	a0,a0,1632 # 80017780 <bcache>
    80003128:	ffffe097          	auipc	ra,0xffffe
    8000312c:	b9c080e7          	jalr	-1124(ra) # 80000cc4 <release>
}
    80003130:	60e2                	ld	ra,24(sp)
    80003132:	6442                	ld	s0,16(sp)
    80003134:	64a2                	ld	s1,8(sp)
    80003136:	6902                	ld	s2,0(sp)
    80003138:	6105                	addi	sp,sp,32
    8000313a:	8082                	ret
    panic("brelse");
    8000313c:	00005517          	auipc	a0,0x5
    80003140:	39c50513          	addi	a0,a0,924 # 800084d8 <syscalls+0xe0>
    80003144:	ffffd097          	auipc	ra,0xffffd
    80003148:	404080e7          	jalr	1028(ra) # 80000548 <panic>

000000008000314c <bpin>:

void
bpin(struct buf *b) {
    8000314c:	1101                	addi	sp,sp,-32
    8000314e:	ec06                	sd	ra,24(sp)
    80003150:	e822                	sd	s0,16(sp)
    80003152:	e426                	sd	s1,8(sp)
    80003154:	1000                	addi	s0,sp,32
    80003156:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003158:	00014517          	auipc	a0,0x14
    8000315c:	62850513          	addi	a0,a0,1576 # 80017780 <bcache>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	ab0080e7          	jalr	-1360(ra) # 80000c10 <acquire>
  b->refcnt++;
    80003168:	40bc                	lw	a5,64(s1)
    8000316a:	2785                	addiw	a5,a5,1
    8000316c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000316e:	00014517          	auipc	a0,0x14
    80003172:	61250513          	addi	a0,a0,1554 # 80017780 <bcache>
    80003176:	ffffe097          	auipc	ra,0xffffe
    8000317a:	b4e080e7          	jalr	-1202(ra) # 80000cc4 <release>
}
    8000317e:	60e2                	ld	ra,24(sp)
    80003180:	6442                	ld	s0,16(sp)
    80003182:	64a2                	ld	s1,8(sp)
    80003184:	6105                	addi	sp,sp,32
    80003186:	8082                	ret

0000000080003188 <bunpin>:

void
bunpin(struct buf *b) {
    80003188:	1101                	addi	sp,sp,-32
    8000318a:	ec06                	sd	ra,24(sp)
    8000318c:	e822                	sd	s0,16(sp)
    8000318e:	e426                	sd	s1,8(sp)
    80003190:	1000                	addi	s0,sp,32
    80003192:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003194:	00014517          	auipc	a0,0x14
    80003198:	5ec50513          	addi	a0,a0,1516 # 80017780 <bcache>
    8000319c:	ffffe097          	auipc	ra,0xffffe
    800031a0:	a74080e7          	jalr	-1420(ra) # 80000c10 <acquire>
  b->refcnt--;
    800031a4:	40bc                	lw	a5,64(s1)
    800031a6:	37fd                	addiw	a5,a5,-1
    800031a8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031aa:	00014517          	auipc	a0,0x14
    800031ae:	5d650513          	addi	a0,a0,1494 # 80017780 <bcache>
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	b12080e7          	jalr	-1262(ra) # 80000cc4 <release>
}
    800031ba:	60e2                	ld	ra,24(sp)
    800031bc:	6442                	ld	s0,16(sp)
    800031be:	64a2                	ld	s1,8(sp)
    800031c0:	6105                	addi	sp,sp,32
    800031c2:	8082                	ret

00000000800031c4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031c4:	1101                	addi	sp,sp,-32
    800031c6:	ec06                	sd	ra,24(sp)
    800031c8:	e822                	sd	s0,16(sp)
    800031ca:	e426                	sd	s1,8(sp)
    800031cc:	e04a                	sd	s2,0(sp)
    800031ce:	1000                	addi	s0,sp,32
    800031d0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031d2:	00d5d59b          	srliw	a1,a1,0xd
    800031d6:	0001d797          	auipc	a5,0x1d
    800031da:	c867a783          	lw	a5,-890(a5) # 8001fe5c <sb+0x1c>
    800031de:	9dbd                	addw	a1,a1,a5
    800031e0:	00000097          	auipc	ra,0x0
    800031e4:	d9e080e7          	jalr	-610(ra) # 80002f7e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031e8:	0074f713          	andi	a4,s1,7
    800031ec:	4785                	li	a5,1
    800031ee:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031f2:	14ce                	slli	s1,s1,0x33
    800031f4:	90d9                	srli	s1,s1,0x36
    800031f6:	00950733          	add	a4,a0,s1
    800031fa:	05874703          	lbu	a4,88(a4)
    800031fe:	00e7f6b3          	and	a3,a5,a4
    80003202:	c69d                	beqz	a3,80003230 <bfree+0x6c>
    80003204:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003206:	94aa                	add	s1,s1,a0
    80003208:	fff7c793          	not	a5,a5
    8000320c:	8ff9                	and	a5,a5,a4
    8000320e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003212:	00001097          	auipc	ra,0x1
    80003216:	104080e7          	jalr	260(ra) # 80004316 <log_write>
  brelse(bp);
    8000321a:	854a                	mv	a0,s2
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	e92080e7          	jalr	-366(ra) # 800030ae <brelse>
}
    80003224:	60e2                	ld	ra,24(sp)
    80003226:	6442                	ld	s0,16(sp)
    80003228:	64a2                	ld	s1,8(sp)
    8000322a:	6902                	ld	s2,0(sp)
    8000322c:	6105                	addi	sp,sp,32
    8000322e:	8082                	ret
    panic("freeing free block");
    80003230:	00005517          	auipc	a0,0x5
    80003234:	2b050513          	addi	a0,a0,688 # 800084e0 <syscalls+0xe8>
    80003238:	ffffd097          	auipc	ra,0xffffd
    8000323c:	310080e7          	jalr	784(ra) # 80000548 <panic>

0000000080003240 <balloc>:
{
    80003240:	711d                	addi	sp,sp,-96
    80003242:	ec86                	sd	ra,88(sp)
    80003244:	e8a2                	sd	s0,80(sp)
    80003246:	e4a6                	sd	s1,72(sp)
    80003248:	e0ca                	sd	s2,64(sp)
    8000324a:	fc4e                	sd	s3,56(sp)
    8000324c:	f852                	sd	s4,48(sp)
    8000324e:	f456                	sd	s5,40(sp)
    80003250:	f05a                	sd	s6,32(sp)
    80003252:	ec5e                	sd	s7,24(sp)
    80003254:	e862                	sd	s8,16(sp)
    80003256:	e466                	sd	s9,8(sp)
    80003258:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000325a:	0001d797          	auipc	a5,0x1d
    8000325e:	bea7a783          	lw	a5,-1046(a5) # 8001fe44 <sb+0x4>
    80003262:	cbd1                	beqz	a5,800032f6 <balloc+0xb6>
    80003264:	8baa                	mv	s7,a0
    80003266:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003268:	0001db17          	auipc	s6,0x1d
    8000326c:	bd8b0b13          	addi	s6,s6,-1064 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003270:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003272:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003274:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003276:	6c89                	lui	s9,0x2
    80003278:	a831                	j	80003294 <balloc+0x54>
    brelse(bp);
    8000327a:	854a                	mv	a0,s2
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	e32080e7          	jalr	-462(ra) # 800030ae <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003284:	015c87bb          	addw	a5,s9,s5
    80003288:	00078a9b          	sext.w	s5,a5
    8000328c:	004b2703          	lw	a4,4(s6)
    80003290:	06eaf363          	bgeu	s5,a4,800032f6 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003294:	41fad79b          	sraiw	a5,s5,0x1f
    80003298:	0137d79b          	srliw	a5,a5,0x13
    8000329c:	015787bb          	addw	a5,a5,s5
    800032a0:	40d7d79b          	sraiw	a5,a5,0xd
    800032a4:	01cb2583          	lw	a1,28(s6)
    800032a8:	9dbd                	addw	a1,a1,a5
    800032aa:	855e                	mv	a0,s7
    800032ac:	00000097          	auipc	ra,0x0
    800032b0:	cd2080e7          	jalr	-814(ra) # 80002f7e <bread>
    800032b4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032b6:	004b2503          	lw	a0,4(s6)
    800032ba:	000a849b          	sext.w	s1,s5
    800032be:	8662                	mv	a2,s8
    800032c0:	faa4fde3          	bgeu	s1,a0,8000327a <balloc+0x3a>
      m = 1 << (bi % 8);
    800032c4:	41f6579b          	sraiw	a5,a2,0x1f
    800032c8:	01d7d69b          	srliw	a3,a5,0x1d
    800032cc:	00c6873b          	addw	a4,a3,a2
    800032d0:	00777793          	andi	a5,a4,7
    800032d4:	9f95                	subw	a5,a5,a3
    800032d6:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032da:	4037571b          	sraiw	a4,a4,0x3
    800032de:	00e906b3          	add	a3,s2,a4
    800032e2:	0586c683          	lbu	a3,88(a3)
    800032e6:	00d7f5b3          	and	a1,a5,a3
    800032ea:	cd91                	beqz	a1,80003306 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ec:	2605                	addiw	a2,a2,1
    800032ee:	2485                	addiw	s1,s1,1
    800032f0:	fd4618e3          	bne	a2,s4,800032c0 <balloc+0x80>
    800032f4:	b759                	j	8000327a <balloc+0x3a>
  panic("balloc: out of blocks");
    800032f6:	00005517          	auipc	a0,0x5
    800032fa:	20250513          	addi	a0,a0,514 # 800084f8 <syscalls+0x100>
    800032fe:	ffffd097          	auipc	ra,0xffffd
    80003302:	24a080e7          	jalr	586(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003306:	974a                	add	a4,a4,s2
    80003308:	8fd5                	or	a5,a5,a3
    8000330a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000330e:	854a                	mv	a0,s2
    80003310:	00001097          	auipc	ra,0x1
    80003314:	006080e7          	jalr	6(ra) # 80004316 <log_write>
        brelse(bp);
    80003318:	854a                	mv	a0,s2
    8000331a:	00000097          	auipc	ra,0x0
    8000331e:	d94080e7          	jalr	-620(ra) # 800030ae <brelse>
  bp = bread(dev, bno);
    80003322:	85a6                	mv	a1,s1
    80003324:	855e                	mv	a0,s7
    80003326:	00000097          	auipc	ra,0x0
    8000332a:	c58080e7          	jalr	-936(ra) # 80002f7e <bread>
    8000332e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003330:	40000613          	li	a2,1024
    80003334:	4581                	li	a1,0
    80003336:	05850513          	addi	a0,a0,88
    8000333a:	ffffe097          	auipc	ra,0xffffe
    8000333e:	9d2080e7          	jalr	-1582(ra) # 80000d0c <memset>
  log_write(bp);
    80003342:	854a                	mv	a0,s2
    80003344:	00001097          	auipc	ra,0x1
    80003348:	fd2080e7          	jalr	-46(ra) # 80004316 <log_write>
  brelse(bp);
    8000334c:	854a                	mv	a0,s2
    8000334e:	00000097          	auipc	ra,0x0
    80003352:	d60080e7          	jalr	-672(ra) # 800030ae <brelse>
}
    80003356:	8526                	mv	a0,s1
    80003358:	60e6                	ld	ra,88(sp)
    8000335a:	6446                	ld	s0,80(sp)
    8000335c:	64a6                	ld	s1,72(sp)
    8000335e:	6906                	ld	s2,64(sp)
    80003360:	79e2                	ld	s3,56(sp)
    80003362:	7a42                	ld	s4,48(sp)
    80003364:	7aa2                	ld	s5,40(sp)
    80003366:	7b02                	ld	s6,32(sp)
    80003368:	6be2                	ld	s7,24(sp)
    8000336a:	6c42                	ld	s8,16(sp)
    8000336c:	6ca2                	ld	s9,8(sp)
    8000336e:	6125                	addi	sp,sp,96
    80003370:	8082                	ret

0000000080003372 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003372:	7179                	addi	sp,sp,-48
    80003374:	f406                	sd	ra,40(sp)
    80003376:	f022                	sd	s0,32(sp)
    80003378:	ec26                	sd	s1,24(sp)
    8000337a:	e84a                	sd	s2,16(sp)
    8000337c:	e44e                	sd	s3,8(sp)
    8000337e:	e052                	sd	s4,0(sp)
    80003380:	1800                	addi	s0,sp,48
    80003382:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003384:	47ad                	li	a5,11
    80003386:	04b7fe63          	bgeu	a5,a1,800033e2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000338a:	ff45849b          	addiw	s1,a1,-12
    8000338e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003392:	0ff00793          	li	a5,255
    80003396:	0ae7e363          	bltu	a5,a4,8000343c <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000339a:	08052583          	lw	a1,128(a0)
    8000339e:	c5ad                	beqz	a1,80003408 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800033a0:	00092503          	lw	a0,0(s2)
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	bda080e7          	jalr	-1062(ra) # 80002f7e <bread>
    800033ac:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033ae:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033b2:	02049593          	slli	a1,s1,0x20
    800033b6:	9181                	srli	a1,a1,0x20
    800033b8:	058a                	slli	a1,a1,0x2
    800033ba:	00b784b3          	add	s1,a5,a1
    800033be:	0004a983          	lw	s3,0(s1)
    800033c2:	04098d63          	beqz	s3,8000341c <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800033c6:	8552                	mv	a0,s4
    800033c8:	00000097          	auipc	ra,0x0
    800033cc:	ce6080e7          	jalr	-794(ra) # 800030ae <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033d0:	854e                	mv	a0,s3
    800033d2:	70a2                	ld	ra,40(sp)
    800033d4:	7402                	ld	s0,32(sp)
    800033d6:	64e2                	ld	s1,24(sp)
    800033d8:	6942                	ld	s2,16(sp)
    800033da:	69a2                	ld	s3,8(sp)
    800033dc:	6a02                	ld	s4,0(sp)
    800033de:	6145                	addi	sp,sp,48
    800033e0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033e2:	02059493          	slli	s1,a1,0x20
    800033e6:	9081                	srli	s1,s1,0x20
    800033e8:	048a                	slli	s1,s1,0x2
    800033ea:	94aa                	add	s1,s1,a0
    800033ec:	0504a983          	lw	s3,80(s1)
    800033f0:	fe0990e3          	bnez	s3,800033d0 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033f4:	4108                	lw	a0,0(a0)
    800033f6:	00000097          	auipc	ra,0x0
    800033fa:	e4a080e7          	jalr	-438(ra) # 80003240 <balloc>
    800033fe:	0005099b          	sext.w	s3,a0
    80003402:	0534a823          	sw	s3,80(s1)
    80003406:	b7e9                	j	800033d0 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003408:	4108                	lw	a0,0(a0)
    8000340a:	00000097          	auipc	ra,0x0
    8000340e:	e36080e7          	jalr	-458(ra) # 80003240 <balloc>
    80003412:	0005059b          	sext.w	a1,a0
    80003416:	08b92023          	sw	a1,128(s2)
    8000341a:	b759                	j	800033a0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000341c:	00092503          	lw	a0,0(s2)
    80003420:	00000097          	auipc	ra,0x0
    80003424:	e20080e7          	jalr	-480(ra) # 80003240 <balloc>
    80003428:	0005099b          	sext.w	s3,a0
    8000342c:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003430:	8552                	mv	a0,s4
    80003432:	00001097          	auipc	ra,0x1
    80003436:	ee4080e7          	jalr	-284(ra) # 80004316 <log_write>
    8000343a:	b771                	j	800033c6 <bmap+0x54>
  panic("bmap: out of range");
    8000343c:	00005517          	auipc	a0,0x5
    80003440:	0d450513          	addi	a0,a0,212 # 80008510 <syscalls+0x118>
    80003444:	ffffd097          	auipc	ra,0xffffd
    80003448:	104080e7          	jalr	260(ra) # 80000548 <panic>

000000008000344c <iget>:
{
    8000344c:	7179                	addi	sp,sp,-48
    8000344e:	f406                	sd	ra,40(sp)
    80003450:	f022                	sd	s0,32(sp)
    80003452:	ec26                	sd	s1,24(sp)
    80003454:	e84a                	sd	s2,16(sp)
    80003456:	e44e                	sd	s3,8(sp)
    80003458:	e052                	sd	s4,0(sp)
    8000345a:	1800                	addi	s0,sp,48
    8000345c:	89aa                	mv	s3,a0
    8000345e:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003460:	0001d517          	auipc	a0,0x1d
    80003464:	a0050513          	addi	a0,a0,-1536 # 8001fe60 <icache>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	7a8080e7          	jalr	1960(ra) # 80000c10 <acquire>
  empty = 0;
    80003470:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003472:	0001d497          	auipc	s1,0x1d
    80003476:	a0648493          	addi	s1,s1,-1530 # 8001fe78 <icache+0x18>
    8000347a:	0001e697          	auipc	a3,0x1e
    8000347e:	48e68693          	addi	a3,a3,1166 # 80021908 <log>
    80003482:	a039                	j	80003490 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003484:	02090b63          	beqz	s2,800034ba <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003488:	08848493          	addi	s1,s1,136
    8000348c:	02d48a63          	beq	s1,a3,800034c0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003490:	449c                	lw	a5,8(s1)
    80003492:	fef059e3          	blez	a5,80003484 <iget+0x38>
    80003496:	4098                	lw	a4,0(s1)
    80003498:	ff3716e3          	bne	a4,s3,80003484 <iget+0x38>
    8000349c:	40d8                	lw	a4,4(s1)
    8000349e:	ff4713e3          	bne	a4,s4,80003484 <iget+0x38>
      ip->ref++;
    800034a2:	2785                	addiw	a5,a5,1
    800034a4:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800034a6:	0001d517          	auipc	a0,0x1d
    800034aa:	9ba50513          	addi	a0,a0,-1606 # 8001fe60 <icache>
    800034ae:	ffffe097          	auipc	ra,0xffffe
    800034b2:	816080e7          	jalr	-2026(ra) # 80000cc4 <release>
      return ip;
    800034b6:	8926                	mv	s2,s1
    800034b8:	a03d                	j	800034e6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034ba:	f7f9                	bnez	a5,80003488 <iget+0x3c>
    800034bc:	8926                	mv	s2,s1
    800034be:	b7e9                	j	80003488 <iget+0x3c>
  if(empty == 0)
    800034c0:	02090c63          	beqz	s2,800034f8 <iget+0xac>
  ip->dev = dev;
    800034c4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034c8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034cc:	4785                	li	a5,1
    800034ce:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034d2:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800034d6:	0001d517          	auipc	a0,0x1d
    800034da:	98a50513          	addi	a0,a0,-1654 # 8001fe60 <icache>
    800034de:	ffffd097          	auipc	ra,0xffffd
    800034e2:	7e6080e7          	jalr	2022(ra) # 80000cc4 <release>
}
    800034e6:	854a                	mv	a0,s2
    800034e8:	70a2                	ld	ra,40(sp)
    800034ea:	7402                	ld	s0,32(sp)
    800034ec:	64e2                	ld	s1,24(sp)
    800034ee:	6942                	ld	s2,16(sp)
    800034f0:	69a2                	ld	s3,8(sp)
    800034f2:	6a02                	ld	s4,0(sp)
    800034f4:	6145                	addi	sp,sp,48
    800034f6:	8082                	ret
    panic("iget: no inodes");
    800034f8:	00005517          	auipc	a0,0x5
    800034fc:	03050513          	addi	a0,a0,48 # 80008528 <syscalls+0x130>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	048080e7          	jalr	72(ra) # 80000548 <panic>

0000000080003508 <fsinit>:
fsinit(int dev) {
    80003508:	7179                	addi	sp,sp,-48
    8000350a:	f406                	sd	ra,40(sp)
    8000350c:	f022                	sd	s0,32(sp)
    8000350e:	ec26                	sd	s1,24(sp)
    80003510:	e84a                	sd	s2,16(sp)
    80003512:	e44e                	sd	s3,8(sp)
    80003514:	1800                	addi	s0,sp,48
    80003516:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003518:	4585                	li	a1,1
    8000351a:	00000097          	auipc	ra,0x0
    8000351e:	a64080e7          	jalr	-1436(ra) # 80002f7e <bread>
    80003522:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003524:	0001d997          	auipc	s3,0x1d
    80003528:	91c98993          	addi	s3,s3,-1764 # 8001fe40 <sb>
    8000352c:	02000613          	li	a2,32
    80003530:	05850593          	addi	a1,a0,88
    80003534:	854e                	mv	a0,s3
    80003536:	ffffe097          	auipc	ra,0xffffe
    8000353a:	836080e7          	jalr	-1994(ra) # 80000d6c <memmove>
  brelse(bp);
    8000353e:	8526                	mv	a0,s1
    80003540:	00000097          	auipc	ra,0x0
    80003544:	b6e080e7          	jalr	-1170(ra) # 800030ae <brelse>
  if(sb.magic != FSMAGIC)
    80003548:	0009a703          	lw	a4,0(s3)
    8000354c:	102037b7          	lui	a5,0x10203
    80003550:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003554:	02f71263          	bne	a4,a5,80003578 <fsinit+0x70>
  initlog(dev, &sb);
    80003558:	0001d597          	auipc	a1,0x1d
    8000355c:	8e858593          	addi	a1,a1,-1816 # 8001fe40 <sb>
    80003560:	854a                	mv	a0,s2
    80003562:	00001097          	auipc	ra,0x1
    80003566:	b3c080e7          	jalr	-1220(ra) # 8000409e <initlog>
}
    8000356a:	70a2                	ld	ra,40(sp)
    8000356c:	7402                	ld	s0,32(sp)
    8000356e:	64e2                	ld	s1,24(sp)
    80003570:	6942                	ld	s2,16(sp)
    80003572:	69a2                	ld	s3,8(sp)
    80003574:	6145                	addi	sp,sp,48
    80003576:	8082                	ret
    panic("invalid file system");
    80003578:	00005517          	auipc	a0,0x5
    8000357c:	fc050513          	addi	a0,a0,-64 # 80008538 <syscalls+0x140>
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	fc8080e7          	jalr	-56(ra) # 80000548 <panic>

0000000080003588 <iinit>:
{
    80003588:	7179                	addi	sp,sp,-48
    8000358a:	f406                	sd	ra,40(sp)
    8000358c:	f022                	sd	s0,32(sp)
    8000358e:	ec26                	sd	s1,24(sp)
    80003590:	e84a                	sd	s2,16(sp)
    80003592:	e44e                	sd	s3,8(sp)
    80003594:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003596:	00005597          	auipc	a1,0x5
    8000359a:	fba58593          	addi	a1,a1,-70 # 80008550 <syscalls+0x158>
    8000359e:	0001d517          	auipc	a0,0x1d
    800035a2:	8c250513          	addi	a0,a0,-1854 # 8001fe60 <icache>
    800035a6:	ffffd097          	auipc	ra,0xffffd
    800035aa:	5da080e7          	jalr	1498(ra) # 80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035ae:	0001d497          	auipc	s1,0x1d
    800035b2:	8da48493          	addi	s1,s1,-1830 # 8001fe88 <icache+0x28>
    800035b6:	0001e997          	auipc	s3,0x1e
    800035ba:	36298993          	addi	s3,s3,866 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800035be:	00005917          	auipc	s2,0x5
    800035c2:	f9a90913          	addi	s2,s2,-102 # 80008558 <syscalls+0x160>
    800035c6:	85ca                	mv	a1,s2
    800035c8:	8526                	mv	a0,s1
    800035ca:	00001097          	auipc	ra,0x1
    800035ce:	e3a080e7          	jalr	-454(ra) # 80004404 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035d2:	08848493          	addi	s1,s1,136
    800035d6:	ff3498e3          	bne	s1,s3,800035c6 <iinit+0x3e>
}
    800035da:	70a2                	ld	ra,40(sp)
    800035dc:	7402                	ld	s0,32(sp)
    800035de:	64e2                	ld	s1,24(sp)
    800035e0:	6942                	ld	s2,16(sp)
    800035e2:	69a2                	ld	s3,8(sp)
    800035e4:	6145                	addi	sp,sp,48
    800035e6:	8082                	ret

00000000800035e8 <ialloc>:
{
    800035e8:	715d                	addi	sp,sp,-80
    800035ea:	e486                	sd	ra,72(sp)
    800035ec:	e0a2                	sd	s0,64(sp)
    800035ee:	fc26                	sd	s1,56(sp)
    800035f0:	f84a                	sd	s2,48(sp)
    800035f2:	f44e                	sd	s3,40(sp)
    800035f4:	f052                	sd	s4,32(sp)
    800035f6:	ec56                	sd	s5,24(sp)
    800035f8:	e85a                	sd	s6,16(sp)
    800035fa:	e45e                	sd	s7,8(sp)
    800035fc:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035fe:	0001d717          	auipc	a4,0x1d
    80003602:	84e72703          	lw	a4,-1970(a4) # 8001fe4c <sb+0xc>
    80003606:	4785                	li	a5,1
    80003608:	04e7fa63          	bgeu	a5,a4,8000365c <ialloc+0x74>
    8000360c:	8aaa                	mv	s5,a0
    8000360e:	8bae                	mv	s7,a1
    80003610:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003612:	0001da17          	auipc	s4,0x1d
    80003616:	82ea0a13          	addi	s4,s4,-2002 # 8001fe40 <sb>
    8000361a:	00048b1b          	sext.w	s6,s1
    8000361e:	0044d593          	srli	a1,s1,0x4
    80003622:	018a2783          	lw	a5,24(s4)
    80003626:	9dbd                	addw	a1,a1,a5
    80003628:	8556                	mv	a0,s5
    8000362a:	00000097          	auipc	ra,0x0
    8000362e:	954080e7          	jalr	-1708(ra) # 80002f7e <bread>
    80003632:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003634:	05850993          	addi	s3,a0,88
    80003638:	00f4f793          	andi	a5,s1,15
    8000363c:	079a                	slli	a5,a5,0x6
    8000363e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003640:	00099783          	lh	a5,0(s3)
    80003644:	c785                	beqz	a5,8000366c <ialloc+0x84>
    brelse(bp);
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	a68080e7          	jalr	-1432(ra) # 800030ae <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000364e:	0485                	addi	s1,s1,1
    80003650:	00ca2703          	lw	a4,12(s4)
    80003654:	0004879b          	sext.w	a5,s1
    80003658:	fce7e1e3          	bltu	a5,a4,8000361a <ialloc+0x32>
  panic("ialloc: no inodes");
    8000365c:	00005517          	auipc	a0,0x5
    80003660:	f0450513          	addi	a0,a0,-252 # 80008560 <syscalls+0x168>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	ee4080e7          	jalr	-284(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    8000366c:	04000613          	li	a2,64
    80003670:	4581                	li	a1,0
    80003672:	854e                	mv	a0,s3
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	698080e7          	jalr	1688(ra) # 80000d0c <memset>
      dip->type = type;
    8000367c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003680:	854a                	mv	a0,s2
    80003682:	00001097          	auipc	ra,0x1
    80003686:	c94080e7          	jalr	-876(ra) # 80004316 <log_write>
      brelse(bp);
    8000368a:	854a                	mv	a0,s2
    8000368c:	00000097          	auipc	ra,0x0
    80003690:	a22080e7          	jalr	-1502(ra) # 800030ae <brelse>
      return iget(dev, inum);
    80003694:	85da                	mv	a1,s6
    80003696:	8556                	mv	a0,s5
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	db4080e7          	jalr	-588(ra) # 8000344c <iget>
}
    800036a0:	60a6                	ld	ra,72(sp)
    800036a2:	6406                	ld	s0,64(sp)
    800036a4:	74e2                	ld	s1,56(sp)
    800036a6:	7942                	ld	s2,48(sp)
    800036a8:	79a2                	ld	s3,40(sp)
    800036aa:	7a02                	ld	s4,32(sp)
    800036ac:	6ae2                	ld	s5,24(sp)
    800036ae:	6b42                	ld	s6,16(sp)
    800036b0:	6ba2                	ld	s7,8(sp)
    800036b2:	6161                	addi	sp,sp,80
    800036b4:	8082                	ret

00000000800036b6 <iupdate>:
{
    800036b6:	1101                	addi	sp,sp,-32
    800036b8:	ec06                	sd	ra,24(sp)
    800036ba:	e822                	sd	s0,16(sp)
    800036bc:	e426                	sd	s1,8(sp)
    800036be:	e04a                	sd	s2,0(sp)
    800036c0:	1000                	addi	s0,sp,32
    800036c2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036c4:	415c                	lw	a5,4(a0)
    800036c6:	0047d79b          	srliw	a5,a5,0x4
    800036ca:	0001c597          	auipc	a1,0x1c
    800036ce:	78e5a583          	lw	a1,1934(a1) # 8001fe58 <sb+0x18>
    800036d2:	9dbd                	addw	a1,a1,a5
    800036d4:	4108                	lw	a0,0(a0)
    800036d6:	00000097          	auipc	ra,0x0
    800036da:	8a8080e7          	jalr	-1880(ra) # 80002f7e <bread>
    800036de:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036e0:	05850793          	addi	a5,a0,88
    800036e4:	40c8                	lw	a0,4(s1)
    800036e6:	893d                	andi	a0,a0,15
    800036e8:	051a                	slli	a0,a0,0x6
    800036ea:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800036ec:	04449703          	lh	a4,68(s1)
    800036f0:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036f4:	04649703          	lh	a4,70(s1)
    800036f8:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036fc:	04849703          	lh	a4,72(s1)
    80003700:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003704:	04a49703          	lh	a4,74(s1)
    80003708:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000370c:	44f8                	lw	a4,76(s1)
    8000370e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003710:	03400613          	li	a2,52
    80003714:	05048593          	addi	a1,s1,80
    80003718:	0531                	addi	a0,a0,12
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	652080e7          	jalr	1618(ra) # 80000d6c <memmove>
  log_write(bp);
    80003722:	854a                	mv	a0,s2
    80003724:	00001097          	auipc	ra,0x1
    80003728:	bf2080e7          	jalr	-1038(ra) # 80004316 <log_write>
  brelse(bp);
    8000372c:	854a                	mv	a0,s2
    8000372e:	00000097          	auipc	ra,0x0
    80003732:	980080e7          	jalr	-1664(ra) # 800030ae <brelse>
}
    80003736:	60e2                	ld	ra,24(sp)
    80003738:	6442                	ld	s0,16(sp)
    8000373a:	64a2                	ld	s1,8(sp)
    8000373c:	6902                	ld	s2,0(sp)
    8000373e:	6105                	addi	sp,sp,32
    80003740:	8082                	ret

0000000080003742 <idup>:
{
    80003742:	1101                	addi	sp,sp,-32
    80003744:	ec06                	sd	ra,24(sp)
    80003746:	e822                	sd	s0,16(sp)
    80003748:	e426                	sd	s1,8(sp)
    8000374a:	1000                	addi	s0,sp,32
    8000374c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000374e:	0001c517          	auipc	a0,0x1c
    80003752:	71250513          	addi	a0,a0,1810 # 8001fe60 <icache>
    80003756:	ffffd097          	auipc	ra,0xffffd
    8000375a:	4ba080e7          	jalr	1210(ra) # 80000c10 <acquire>
  ip->ref++;
    8000375e:	449c                	lw	a5,8(s1)
    80003760:	2785                	addiw	a5,a5,1
    80003762:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003764:	0001c517          	auipc	a0,0x1c
    80003768:	6fc50513          	addi	a0,a0,1788 # 8001fe60 <icache>
    8000376c:	ffffd097          	auipc	ra,0xffffd
    80003770:	558080e7          	jalr	1368(ra) # 80000cc4 <release>
}
    80003774:	8526                	mv	a0,s1
    80003776:	60e2                	ld	ra,24(sp)
    80003778:	6442                	ld	s0,16(sp)
    8000377a:	64a2                	ld	s1,8(sp)
    8000377c:	6105                	addi	sp,sp,32
    8000377e:	8082                	ret

0000000080003780 <ilock>:
{
    80003780:	1101                	addi	sp,sp,-32
    80003782:	ec06                	sd	ra,24(sp)
    80003784:	e822                	sd	s0,16(sp)
    80003786:	e426                	sd	s1,8(sp)
    80003788:	e04a                	sd	s2,0(sp)
    8000378a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000378c:	c115                	beqz	a0,800037b0 <ilock+0x30>
    8000378e:	84aa                	mv	s1,a0
    80003790:	451c                	lw	a5,8(a0)
    80003792:	00f05f63          	blez	a5,800037b0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003796:	0541                	addi	a0,a0,16
    80003798:	00001097          	auipc	ra,0x1
    8000379c:	ca6080e7          	jalr	-858(ra) # 8000443e <acquiresleep>
  if(ip->valid == 0){
    800037a0:	40bc                	lw	a5,64(s1)
    800037a2:	cf99                	beqz	a5,800037c0 <ilock+0x40>
}
    800037a4:	60e2                	ld	ra,24(sp)
    800037a6:	6442                	ld	s0,16(sp)
    800037a8:	64a2                	ld	s1,8(sp)
    800037aa:	6902                	ld	s2,0(sp)
    800037ac:	6105                	addi	sp,sp,32
    800037ae:	8082                	ret
    panic("ilock");
    800037b0:	00005517          	auipc	a0,0x5
    800037b4:	dc850513          	addi	a0,a0,-568 # 80008578 <syscalls+0x180>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	d90080e7          	jalr	-624(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037c0:	40dc                	lw	a5,4(s1)
    800037c2:	0047d79b          	srliw	a5,a5,0x4
    800037c6:	0001c597          	auipc	a1,0x1c
    800037ca:	6925a583          	lw	a1,1682(a1) # 8001fe58 <sb+0x18>
    800037ce:	9dbd                	addw	a1,a1,a5
    800037d0:	4088                	lw	a0,0(s1)
    800037d2:	fffff097          	auipc	ra,0xfffff
    800037d6:	7ac080e7          	jalr	1964(ra) # 80002f7e <bread>
    800037da:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037dc:	05850593          	addi	a1,a0,88
    800037e0:	40dc                	lw	a5,4(s1)
    800037e2:	8bbd                	andi	a5,a5,15
    800037e4:	079a                	slli	a5,a5,0x6
    800037e6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037e8:	00059783          	lh	a5,0(a1)
    800037ec:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037f0:	00259783          	lh	a5,2(a1)
    800037f4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037f8:	00459783          	lh	a5,4(a1)
    800037fc:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003800:	00659783          	lh	a5,6(a1)
    80003804:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003808:	459c                	lw	a5,8(a1)
    8000380a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000380c:	03400613          	li	a2,52
    80003810:	05b1                	addi	a1,a1,12
    80003812:	05048513          	addi	a0,s1,80
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	556080e7          	jalr	1366(ra) # 80000d6c <memmove>
    brelse(bp);
    8000381e:	854a                	mv	a0,s2
    80003820:	00000097          	auipc	ra,0x0
    80003824:	88e080e7          	jalr	-1906(ra) # 800030ae <brelse>
    ip->valid = 1;
    80003828:	4785                	li	a5,1
    8000382a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000382c:	04449783          	lh	a5,68(s1)
    80003830:	fbb5                	bnez	a5,800037a4 <ilock+0x24>
      panic("ilock: no type");
    80003832:	00005517          	auipc	a0,0x5
    80003836:	d4e50513          	addi	a0,a0,-690 # 80008580 <syscalls+0x188>
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	d0e080e7          	jalr	-754(ra) # 80000548 <panic>

0000000080003842 <iunlock>:
{
    80003842:	1101                	addi	sp,sp,-32
    80003844:	ec06                	sd	ra,24(sp)
    80003846:	e822                	sd	s0,16(sp)
    80003848:	e426                	sd	s1,8(sp)
    8000384a:	e04a                	sd	s2,0(sp)
    8000384c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000384e:	c905                	beqz	a0,8000387e <iunlock+0x3c>
    80003850:	84aa                	mv	s1,a0
    80003852:	01050913          	addi	s2,a0,16
    80003856:	854a                	mv	a0,s2
    80003858:	00001097          	auipc	ra,0x1
    8000385c:	c80080e7          	jalr	-896(ra) # 800044d8 <holdingsleep>
    80003860:	cd19                	beqz	a0,8000387e <iunlock+0x3c>
    80003862:	449c                	lw	a5,8(s1)
    80003864:	00f05d63          	blez	a5,8000387e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003868:	854a                	mv	a0,s2
    8000386a:	00001097          	auipc	ra,0x1
    8000386e:	c2a080e7          	jalr	-982(ra) # 80004494 <releasesleep>
}
    80003872:	60e2                	ld	ra,24(sp)
    80003874:	6442                	ld	s0,16(sp)
    80003876:	64a2                	ld	s1,8(sp)
    80003878:	6902                	ld	s2,0(sp)
    8000387a:	6105                	addi	sp,sp,32
    8000387c:	8082                	ret
    panic("iunlock");
    8000387e:	00005517          	auipc	a0,0x5
    80003882:	d1250513          	addi	a0,a0,-750 # 80008590 <syscalls+0x198>
    80003886:	ffffd097          	auipc	ra,0xffffd
    8000388a:	cc2080e7          	jalr	-830(ra) # 80000548 <panic>

000000008000388e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000388e:	7179                	addi	sp,sp,-48
    80003890:	f406                	sd	ra,40(sp)
    80003892:	f022                	sd	s0,32(sp)
    80003894:	ec26                	sd	s1,24(sp)
    80003896:	e84a                	sd	s2,16(sp)
    80003898:	e44e                	sd	s3,8(sp)
    8000389a:	e052                	sd	s4,0(sp)
    8000389c:	1800                	addi	s0,sp,48
    8000389e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038a0:	05050493          	addi	s1,a0,80
    800038a4:	08050913          	addi	s2,a0,128
    800038a8:	a021                	j	800038b0 <itrunc+0x22>
    800038aa:	0491                	addi	s1,s1,4
    800038ac:	01248d63          	beq	s1,s2,800038c6 <itrunc+0x38>
    if(ip->addrs[i]){
    800038b0:	408c                	lw	a1,0(s1)
    800038b2:	dde5                	beqz	a1,800038aa <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038b4:	0009a503          	lw	a0,0(s3)
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	90c080e7          	jalr	-1780(ra) # 800031c4 <bfree>
      ip->addrs[i] = 0;
    800038c0:	0004a023          	sw	zero,0(s1)
    800038c4:	b7dd                	j	800038aa <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038c6:	0809a583          	lw	a1,128(s3)
    800038ca:	e185                	bnez	a1,800038ea <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038cc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038d0:	854e                	mv	a0,s3
    800038d2:	00000097          	auipc	ra,0x0
    800038d6:	de4080e7          	jalr	-540(ra) # 800036b6 <iupdate>
}
    800038da:	70a2                	ld	ra,40(sp)
    800038dc:	7402                	ld	s0,32(sp)
    800038de:	64e2                	ld	s1,24(sp)
    800038e0:	6942                	ld	s2,16(sp)
    800038e2:	69a2                	ld	s3,8(sp)
    800038e4:	6a02                	ld	s4,0(sp)
    800038e6:	6145                	addi	sp,sp,48
    800038e8:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038ea:	0009a503          	lw	a0,0(s3)
    800038ee:	fffff097          	auipc	ra,0xfffff
    800038f2:	690080e7          	jalr	1680(ra) # 80002f7e <bread>
    800038f6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038f8:	05850493          	addi	s1,a0,88
    800038fc:	45850913          	addi	s2,a0,1112
    80003900:	a811                	j	80003914 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003902:	0009a503          	lw	a0,0(s3)
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	8be080e7          	jalr	-1858(ra) # 800031c4 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000390e:	0491                	addi	s1,s1,4
    80003910:	01248563          	beq	s1,s2,8000391a <itrunc+0x8c>
      if(a[j])
    80003914:	408c                	lw	a1,0(s1)
    80003916:	dde5                	beqz	a1,8000390e <itrunc+0x80>
    80003918:	b7ed                	j	80003902 <itrunc+0x74>
    brelse(bp);
    8000391a:	8552                	mv	a0,s4
    8000391c:	fffff097          	auipc	ra,0xfffff
    80003920:	792080e7          	jalr	1938(ra) # 800030ae <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003924:	0809a583          	lw	a1,128(s3)
    80003928:	0009a503          	lw	a0,0(s3)
    8000392c:	00000097          	auipc	ra,0x0
    80003930:	898080e7          	jalr	-1896(ra) # 800031c4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003934:	0809a023          	sw	zero,128(s3)
    80003938:	bf51                	j	800038cc <itrunc+0x3e>

000000008000393a <iput>:
{
    8000393a:	1101                	addi	sp,sp,-32
    8000393c:	ec06                	sd	ra,24(sp)
    8000393e:	e822                	sd	s0,16(sp)
    80003940:	e426                	sd	s1,8(sp)
    80003942:	e04a                	sd	s2,0(sp)
    80003944:	1000                	addi	s0,sp,32
    80003946:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003948:	0001c517          	auipc	a0,0x1c
    8000394c:	51850513          	addi	a0,a0,1304 # 8001fe60 <icache>
    80003950:	ffffd097          	auipc	ra,0xffffd
    80003954:	2c0080e7          	jalr	704(ra) # 80000c10 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003958:	4498                	lw	a4,8(s1)
    8000395a:	4785                	li	a5,1
    8000395c:	02f70363          	beq	a4,a5,80003982 <iput+0x48>
  ip->ref--;
    80003960:	449c                	lw	a5,8(s1)
    80003962:	37fd                	addiw	a5,a5,-1
    80003964:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003966:	0001c517          	auipc	a0,0x1c
    8000396a:	4fa50513          	addi	a0,a0,1274 # 8001fe60 <icache>
    8000396e:	ffffd097          	auipc	ra,0xffffd
    80003972:	356080e7          	jalr	854(ra) # 80000cc4 <release>
}
    80003976:	60e2                	ld	ra,24(sp)
    80003978:	6442                	ld	s0,16(sp)
    8000397a:	64a2                	ld	s1,8(sp)
    8000397c:	6902                	ld	s2,0(sp)
    8000397e:	6105                	addi	sp,sp,32
    80003980:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003982:	40bc                	lw	a5,64(s1)
    80003984:	dff1                	beqz	a5,80003960 <iput+0x26>
    80003986:	04a49783          	lh	a5,74(s1)
    8000398a:	fbf9                	bnez	a5,80003960 <iput+0x26>
    acquiresleep(&ip->lock);
    8000398c:	01048913          	addi	s2,s1,16
    80003990:	854a                	mv	a0,s2
    80003992:	00001097          	auipc	ra,0x1
    80003996:	aac080e7          	jalr	-1364(ra) # 8000443e <acquiresleep>
    release(&icache.lock);
    8000399a:	0001c517          	auipc	a0,0x1c
    8000399e:	4c650513          	addi	a0,a0,1222 # 8001fe60 <icache>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	322080e7          	jalr	802(ra) # 80000cc4 <release>
    itrunc(ip);
    800039aa:	8526                	mv	a0,s1
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	ee2080e7          	jalr	-286(ra) # 8000388e <itrunc>
    ip->type = 0;
    800039b4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039b8:	8526                	mv	a0,s1
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	cfc080e7          	jalr	-772(ra) # 800036b6 <iupdate>
    ip->valid = 0;
    800039c2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039c6:	854a                	mv	a0,s2
    800039c8:	00001097          	auipc	ra,0x1
    800039cc:	acc080e7          	jalr	-1332(ra) # 80004494 <releasesleep>
    acquire(&icache.lock);
    800039d0:	0001c517          	auipc	a0,0x1c
    800039d4:	49050513          	addi	a0,a0,1168 # 8001fe60 <icache>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	238080e7          	jalr	568(ra) # 80000c10 <acquire>
    800039e0:	b741                	j	80003960 <iput+0x26>

00000000800039e2 <iunlockput>:
{
    800039e2:	1101                	addi	sp,sp,-32
    800039e4:	ec06                	sd	ra,24(sp)
    800039e6:	e822                	sd	s0,16(sp)
    800039e8:	e426                	sd	s1,8(sp)
    800039ea:	1000                	addi	s0,sp,32
    800039ec:	84aa                	mv	s1,a0
  iunlock(ip);
    800039ee:	00000097          	auipc	ra,0x0
    800039f2:	e54080e7          	jalr	-428(ra) # 80003842 <iunlock>
  iput(ip);
    800039f6:	8526                	mv	a0,s1
    800039f8:	00000097          	auipc	ra,0x0
    800039fc:	f42080e7          	jalr	-190(ra) # 8000393a <iput>
}
    80003a00:	60e2                	ld	ra,24(sp)
    80003a02:	6442                	ld	s0,16(sp)
    80003a04:	64a2                	ld	s1,8(sp)
    80003a06:	6105                	addi	sp,sp,32
    80003a08:	8082                	ret

0000000080003a0a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a0a:	1141                	addi	sp,sp,-16
    80003a0c:	e422                	sd	s0,8(sp)
    80003a0e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a10:	411c                	lw	a5,0(a0)
    80003a12:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a14:	415c                	lw	a5,4(a0)
    80003a16:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a18:	04451783          	lh	a5,68(a0)
    80003a1c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a20:	04a51783          	lh	a5,74(a0)
    80003a24:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a28:	04c56783          	lwu	a5,76(a0)
    80003a2c:	e99c                	sd	a5,16(a1)
}
    80003a2e:	6422                	ld	s0,8(sp)
    80003a30:	0141                	addi	sp,sp,16
    80003a32:	8082                	ret

0000000080003a34 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a34:	457c                	lw	a5,76(a0)
    80003a36:	0ed7e963          	bltu	a5,a3,80003b28 <readi+0xf4>
{
    80003a3a:	7159                	addi	sp,sp,-112
    80003a3c:	f486                	sd	ra,104(sp)
    80003a3e:	f0a2                	sd	s0,96(sp)
    80003a40:	eca6                	sd	s1,88(sp)
    80003a42:	e8ca                	sd	s2,80(sp)
    80003a44:	e4ce                	sd	s3,72(sp)
    80003a46:	e0d2                	sd	s4,64(sp)
    80003a48:	fc56                	sd	s5,56(sp)
    80003a4a:	f85a                	sd	s6,48(sp)
    80003a4c:	f45e                	sd	s7,40(sp)
    80003a4e:	f062                	sd	s8,32(sp)
    80003a50:	ec66                	sd	s9,24(sp)
    80003a52:	e86a                	sd	s10,16(sp)
    80003a54:	e46e                	sd	s11,8(sp)
    80003a56:	1880                	addi	s0,sp,112
    80003a58:	8baa                	mv	s7,a0
    80003a5a:	8c2e                	mv	s8,a1
    80003a5c:	8ab2                	mv	s5,a2
    80003a5e:	84b6                	mv	s1,a3
    80003a60:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a62:	9f35                	addw	a4,a4,a3
    return 0;
    80003a64:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a66:	0ad76063          	bltu	a4,a3,80003b06 <readi+0xd2>
  if(off + n > ip->size)
    80003a6a:	00e7f463          	bgeu	a5,a4,80003a72 <readi+0x3e>
    n = ip->size - off;
    80003a6e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a72:	0a0b0963          	beqz	s6,80003b24 <readi+0xf0>
    80003a76:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a78:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a7c:	5cfd                	li	s9,-1
    80003a7e:	a82d                	j	80003ab8 <readi+0x84>
    80003a80:	020a1d93          	slli	s11,s4,0x20
    80003a84:	020ddd93          	srli	s11,s11,0x20
    80003a88:	05890613          	addi	a2,s2,88
    80003a8c:	86ee                	mv	a3,s11
    80003a8e:	963a                	add	a2,a2,a4
    80003a90:	85d6                	mv	a1,s5
    80003a92:	8562                	mv	a0,s8
    80003a94:	fffff097          	auipc	ra,0xfffff
    80003a98:	af0080e7          	jalr	-1296(ra) # 80002584 <either_copyout>
    80003a9c:	05950d63          	beq	a0,s9,80003af6 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003aa0:	854a                	mv	a0,s2
    80003aa2:	fffff097          	auipc	ra,0xfffff
    80003aa6:	60c080e7          	jalr	1548(ra) # 800030ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aaa:	013a09bb          	addw	s3,s4,s3
    80003aae:	009a04bb          	addw	s1,s4,s1
    80003ab2:	9aee                	add	s5,s5,s11
    80003ab4:	0569f763          	bgeu	s3,s6,80003b02 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ab8:	000ba903          	lw	s2,0(s7)
    80003abc:	00a4d59b          	srliw	a1,s1,0xa
    80003ac0:	855e                	mv	a0,s7
    80003ac2:	00000097          	auipc	ra,0x0
    80003ac6:	8b0080e7          	jalr	-1872(ra) # 80003372 <bmap>
    80003aca:	0005059b          	sext.w	a1,a0
    80003ace:	854a                	mv	a0,s2
    80003ad0:	fffff097          	auipc	ra,0xfffff
    80003ad4:	4ae080e7          	jalr	1198(ra) # 80002f7e <bread>
    80003ad8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ada:	3ff4f713          	andi	a4,s1,1023
    80003ade:	40ed07bb          	subw	a5,s10,a4
    80003ae2:	413b06bb          	subw	a3,s6,s3
    80003ae6:	8a3e                	mv	s4,a5
    80003ae8:	2781                	sext.w	a5,a5
    80003aea:	0006861b          	sext.w	a2,a3
    80003aee:	f8f679e3          	bgeu	a2,a5,80003a80 <readi+0x4c>
    80003af2:	8a36                	mv	s4,a3
    80003af4:	b771                	j	80003a80 <readi+0x4c>
      brelse(bp);
    80003af6:	854a                	mv	a0,s2
    80003af8:	fffff097          	auipc	ra,0xfffff
    80003afc:	5b6080e7          	jalr	1462(ra) # 800030ae <brelse>
      tot = -1;
    80003b00:	59fd                	li	s3,-1
  }
  return tot;
    80003b02:	0009851b          	sext.w	a0,s3
}
    80003b06:	70a6                	ld	ra,104(sp)
    80003b08:	7406                	ld	s0,96(sp)
    80003b0a:	64e6                	ld	s1,88(sp)
    80003b0c:	6946                	ld	s2,80(sp)
    80003b0e:	69a6                	ld	s3,72(sp)
    80003b10:	6a06                	ld	s4,64(sp)
    80003b12:	7ae2                	ld	s5,56(sp)
    80003b14:	7b42                	ld	s6,48(sp)
    80003b16:	7ba2                	ld	s7,40(sp)
    80003b18:	7c02                	ld	s8,32(sp)
    80003b1a:	6ce2                	ld	s9,24(sp)
    80003b1c:	6d42                	ld	s10,16(sp)
    80003b1e:	6da2                	ld	s11,8(sp)
    80003b20:	6165                	addi	sp,sp,112
    80003b22:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b24:	89da                	mv	s3,s6
    80003b26:	bff1                	j	80003b02 <readi+0xce>
    return 0;
    80003b28:	4501                	li	a0,0
}
    80003b2a:	8082                	ret

0000000080003b2c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b2c:	457c                	lw	a5,76(a0)
    80003b2e:	10d7e763          	bltu	a5,a3,80003c3c <writei+0x110>
{
    80003b32:	7159                	addi	sp,sp,-112
    80003b34:	f486                	sd	ra,104(sp)
    80003b36:	f0a2                	sd	s0,96(sp)
    80003b38:	eca6                	sd	s1,88(sp)
    80003b3a:	e8ca                	sd	s2,80(sp)
    80003b3c:	e4ce                	sd	s3,72(sp)
    80003b3e:	e0d2                	sd	s4,64(sp)
    80003b40:	fc56                	sd	s5,56(sp)
    80003b42:	f85a                	sd	s6,48(sp)
    80003b44:	f45e                	sd	s7,40(sp)
    80003b46:	f062                	sd	s8,32(sp)
    80003b48:	ec66                	sd	s9,24(sp)
    80003b4a:	e86a                	sd	s10,16(sp)
    80003b4c:	e46e                	sd	s11,8(sp)
    80003b4e:	1880                	addi	s0,sp,112
    80003b50:	8baa                	mv	s7,a0
    80003b52:	8c2e                	mv	s8,a1
    80003b54:	8ab2                	mv	s5,a2
    80003b56:	8936                	mv	s2,a3
    80003b58:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b5a:	00e687bb          	addw	a5,a3,a4
    80003b5e:	0ed7e163          	bltu	a5,a3,80003c40 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b62:	00043737          	lui	a4,0x43
    80003b66:	0cf76f63          	bltu	a4,a5,80003c44 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b6a:	0a0b0863          	beqz	s6,80003c1a <writei+0xee>
    80003b6e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b70:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b74:	5cfd                	li	s9,-1
    80003b76:	a091                	j	80003bba <writei+0x8e>
    80003b78:	02099d93          	slli	s11,s3,0x20
    80003b7c:	020ddd93          	srli	s11,s11,0x20
    80003b80:	05848513          	addi	a0,s1,88
    80003b84:	86ee                	mv	a3,s11
    80003b86:	8656                	mv	a2,s5
    80003b88:	85e2                	mv	a1,s8
    80003b8a:	953a                	add	a0,a0,a4
    80003b8c:	fffff097          	auipc	ra,0xfffff
    80003b90:	a4e080e7          	jalr	-1458(ra) # 800025da <either_copyin>
    80003b94:	07950263          	beq	a0,s9,80003bf8 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003b98:	8526                	mv	a0,s1
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	77c080e7          	jalr	1916(ra) # 80004316 <log_write>
    brelse(bp);
    80003ba2:	8526                	mv	a0,s1
    80003ba4:	fffff097          	auipc	ra,0xfffff
    80003ba8:	50a080e7          	jalr	1290(ra) # 800030ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bac:	01498a3b          	addw	s4,s3,s4
    80003bb0:	0129893b          	addw	s2,s3,s2
    80003bb4:	9aee                	add	s5,s5,s11
    80003bb6:	056a7763          	bgeu	s4,s6,80003c04 <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bba:	000ba483          	lw	s1,0(s7)
    80003bbe:	00a9559b          	srliw	a1,s2,0xa
    80003bc2:	855e                	mv	a0,s7
    80003bc4:	fffff097          	auipc	ra,0xfffff
    80003bc8:	7ae080e7          	jalr	1966(ra) # 80003372 <bmap>
    80003bcc:	0005059b          	sext.w	a1,a0
    80003bd0:	8526                	mv	a0,s1
    80003bd2:	fffff097          	auipc	ra,0xfffff
    80003bd6:	3ac080e7          	jalr	940(ra) # 80002f7e <bread>
    80003bda:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bdc:	3ff97713          	andi	a4,s2,1023
    80003be0:	40ed07bb          	subw	a5,s10,a4
    80003be4:	414b06bb          	subw	a3,s6,s4
    80003be8:	89be                	mv	s3,a5
    80003bea:	2781                	sext.w	a5,a5
    80003bec:	0006861b          	sext.w	a2,a3
    80003bf0:	f8f674e3          	bgeu	a2,a5,80003b78 <writei+0x4c>
    80003bf4:	89b6                	mv	s3,a3
    80003bf6:	b749                	j	80003b78 <writei+0x4c>
      brelse(bp);
    80003bf8:	8526                	mv	a0,s1
    80003bfa:	fffff097          	auipc	ra,0xfffff
    80003bfe:	4b4080e7          	jalr	1204(ra) # 800030ae <brelse>
      n = -1;
    80003c02:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003c04:	04cba783          	lw	a5,76(s7)
    80003c08:	0127f463          	bgeu	a5,s2,80003c10 <writei+0xe4>
      ip->size = off;
    80003c0c:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003c10:	855e                	mv	a0,s7
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	aa4080e7          	jalr	-1372(ra) # 800036b6 <iupdate>
  }

  return n;
    80003c1a:	000b051b          	sext.w	a0,s6
}
    80003c1e:	70a6                	ld	ra,104(sp)
    80003c20:	7406                	ld	s0,96(sp)
    80003c22:	64e6                	ld	s1,88(sp)
    80003c24:	6946                	ld	s2,80(sp)
    80003c26:	69a6                	ld	s3,72(sp)
    80003c28:	6a06                	ld	s4,64(sp)
    80003c2a:	7ae2                	ld	s5,56(sp)
    80003c2c:	7b42                	ld	s6,48(sp)
    80003c2e:	7ba2                	ld	s7,40(sp)
    80003c30:	7c02                	ld	s8,32(sp)
    80003c32:	6ce2                	ld	s9,24(sp)
    80003c34:	6d42                	ld	s10,16(sp)
    80003c36:	6da2                	ld	s11,8(sp)
    80003c38:	6165                	addi	sp,sp,112
    80003c3a:	8082                	ret
    return -1;
    80003c3c:	557d                	li	a0,-1
}
    80003c3e:	8082                	ret
    return -1;
    80003c40:	557d                	li	a0,-1
    80003c42:	bff1                	j	80003c1e <writei+0xf2>
    return -1;
    80003c44:	557d                	li	a0,-1
    80003c46:	bfe1                	j	80003c1e <writei+0xf2>

0000000080003c48 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c48:	1141                	addi	sp,sp,-16
    80003c4a:	e406                	sd	ra,8(sp)
    80003c4c:	e022                	sd	s0,0(sp)
    80003c4e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c50:	4639                	li	a2,14
    80003c52:	ffffd097          	auipc	ra,0xffffd
    80003c56:	196080e7          	jalr	406(ra) # 80000de8 <strncmp>
}
    80003c5a:	60a2                	ld	ra,8(sp)
    80003c5c:	6402                	ld	s0,0(sp)
    80003c5e:	0141                	addi	sp,sp,16
    80003c60:	8082                	ret

0000000080003c62 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c62:	7139                	addi	sp,sp,-64
    80003c64:	fc06                	sd	ra,56(sp)
    80003c66:	f822                	sd	s0,48(sp)
    80003c68:	f426                	sd	s1,40(sp)
    80003c6a:	f04a                	sd	s2,32(sp)
    80003c6c:	ec4e                	sd	s3,24(sp)
    80003c6e:	e852                	sd	s4,16(sp)
    80003c70:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c72:	04451703          	lh	a4,68(a0)
    80003c76:	4785                	li	a5,1
    80003c78:	00f71a63          	bne	a4,a5,80003c8c <dirlookup+0x2a>
    80003c7c:	892a                	mv	s2,a0
    80003c7e:	89ae                	mv	s3,a1
    80003c80:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c82:	457c                	lw	a5,76(a0)
    80003c84:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c86:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c88:	e79d                	bnez	a5,80003cb6 <dirlookup+0x54>
    80003c8a:	a8a5                	j	80003d02 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c8c:	00005517          	auipc	a0,0x5
    80003c90:	90c50513          	addi	a0,a0,-1780 # 80008598 <syscalls+0x1a0>
    80003c94:	ffffd097          	auipc	ra,0xffffd
    80003c98:	8b4080e7          	jalr	-1868(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003c9c:	00005517          	auipc	a0,0x5
    80003ca0:	91450513          	addi	a0,a0,-1772 # 800085b0 <syscalls+0x1b8>
    80003ca4:	ffffd097          	auipc	ra,0xffffd
    80003ca8:	8a4080e7          	jalr	-1884(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cac:	24c1                	addiw	s1,s1,16
    80003cae:	04c92783          	lw	a5,76(s2)
    80003cb2:	04f4f763          	bgeu	s1,a5,80003d00 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cb6:	4741                	li	a4,16
    80003cb8:	86a6                	mv	a3,s1
    80003cba:	fc040613          	addi	a2,s0,-64
    80003cbe:	4581                	li	a1,0
    80003cc0:	854a                	mv	a0,s2
    80003cc2:	00000097          	auipc	ra,0x0
    80003cc6:	d72080e7          	jalr	-654(ra) # 80003a34 <readi>
    80003cca:	47c1                	li	a5,16
    80003ccc:	fcf518e3          	bne	a0,a5,80003c9c <dirlookup+0x3a>
    if(de.inum == 0)
    80003cd0:	fc045783          	lhu	a5,-64(s0)
    80003cd4:	dfe1                	beqz	a5,80003cac <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cd6:	fc240593          	addi	a1,s0,-62
    80003cda:	854e                	mv	a0,s3
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	f6c080e7          	jalr	-148(ra) # 80003c48 <namecmp>
    80003ce4:	f561                	bnez	a0,80003cac <dirlookup+0x4a>
      if(poff)
    80003ce6:	000a0463          	beqz	s4,80003cee <dirlookup+0x8c>
        *poff = off;
    80003cea:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cee:	fc045583          	lhu	a1,-64(s0)
    80003cf2:	00092503          	lw	a0,0(s2)
    80003cf6:	fffff097          	auipc	ra,0xfffff
    80003cfa:	756080e7          	jalr	1878(ra) # 8000344c <iget>
    80003cfe:	a011                	j	80003d02 <dirlookup+0xa0>
  return 0;
    80003d00:	4501                	li	a0,0
}
    80003d02:	70e2                	ld	ra,56(sp)
    80003d04:	7442                	ld	s0,48(sp)
    80003d06:	74a2                	ld	s1,40(sp)
    80003d08:	7902                	ld	s2,32(sp)
    80003d0a:	69e2                	ld	s3,24(sp)
    80003d0c:	6a42                	ld	s4,16(sp)
    80003d0e:	6121                	addi	sp,sp,64
    80003d10:	8082                	ret

0000000080003d12 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d12:	711d                	addi	sp,sp,-96
    80003d14:	ec86                	sd	ra,88(sp)
    80003d16:	e8a2                	sd	s0,80(sp)
    80003d18:	e4a6                	sd	s1,72(sp)
    80003d1a:	e0ca                	sd	s2,64(sp)
    80003d1c:	fc4e                	sd	s3,56(sp)
    80003d1e:	f852                	sd	s4,48(sp)
    80003d20:	f456                	sd	s5,40(sp)
    80003d22:	f05a                	sd	s6,32(sp)
    80003d24:	ec5e                	sd	s7,24(sp)
    80003d26:	e862                	sd	s8,16(sp)
    80003d28:	e466                	sd	s9,8(sp)
    80003d2a:	1080                	addi	s0,sp,96
    80003d2c:	84aa                	mv	s1,a0
    80003d2e:	8b2e                	mv	s6,a1
    80003d30:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d32:	00054703          	lbu	a4,0(a0)
    80003d36:	02f00793          	li	a5,47
    80003d3a:	02f70363          	beq	a4,a5,80003d60 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d3e:	ffffe097          	auipc	ra,0xffffe
    80003d42:	dd4080e7          	jalr	-556(ra) # 80001b12 <myproc>
    80003d46:	15053503          	ld	a0,336(a0)
    80003d4a:	00000097          	auipc	ra,0x0
    80003d4e:	9f8080e7          	jalr	-1544(ra) # 80003742 <idup>
    80003d52:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d54:	02f00913          	li	s2,47
  len = path - s;
    80003d58:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003d5a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d5c:	4c05                	li	s8,1
    80003d5e:	a865                	j	80003e16 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d60:	4585                	li	a1,1
    80003d62:	4505                	li	a0,1
    80003d64:	fffff097          	auipc	ra,0xfffff
    80003d68:	6e8080e7          	jalr	1768(ra) # 8000344c <iget>
    80003d6c:	89aa                	mv	s3,a0
    80003d6e:	b7dd                	j	80003d54 <namex+0x42>
      iunlockput(ip);
    80003d70:	854e                	mv	a0,s3
    80003d72:	00000097          	auipc	ra,0x0
    80003d76:	c70080e7          	jalr	-912(ra) # 800039e2 <iunlockput>
      return 0;
    80003d7a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d7c:	854e                	mv	a0,s3
    80003d7e:	60e6                	ld	ra,88(sp)
    80003d80:	6446                	ld	s0,80(sp)
    80003d82:	64a6                	ld	s1,72(sp)
    80003d84:	6906                	ld	s2,64(sp)
    80003d86:	79e2                	ld	s3,56(sp)
    80003d88:	7a42                	ld	s4,48(sp)
    80003d8a:	7aa2                	ld	s5,40(sp)
    80003d8c:	7b02                	ld	s6,32(sp)
    80003d8e:	6be2                	ld	s7,24(sp)
    80003d90:	6c42                	ld	s8,16(sp)
    80003d92:	6ca2                	ld	s9,8(sp)
    80003d94:	6125                	addi	sp,sp,96
    80003d96:	8082                	ret
      iunlock(ip);
    80003d98:	854e                	mv	a0,s3
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	aa8080e7          	jalr	-1368(ra) # 80003842 <iunlock>
      return ip;
    80003da2:	bfe9                	j	80003d7c <namex+0x6a>
      iunlockput(ip);
    80003da4:	854e                	mv	a0,s3
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	c3c080e7          	jalr	-964(ra) # 800039e2 <iunlockput>
      return 0;
    80003dae:	89d2                	mv	s3,s4
    80003db0:	b7f1                	j	80003d7c <namex+0x6a>
  len = path - s;
    80003db2:	40b48633          	sub	a2,s1,a1
    80003db6:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003dba:	094cd463          	bge	s9,s4,80003e42 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003dbe:	4639                	li	a2,14
    80003dc0:	8556                	mv	a0,s5
    80003dc2:	ffffd097          	auipc	ra,0xffffd
    80003dc6:	faa080e7          	jalr	-86(ra) # 80000d6c <memmove>
  while(*path == '/')
    80003dca:	0004c783          	lbu	a5,0(s1)
    80003dce:	01279763          	bne	a5,s2,80003ddc <namex+0xca>
    path++;
    80003dd2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dd4:	0004c783          	lbu	a5,0(s1)
    80003dd8:	ff278de3          	beq	a5,s2,80003dd2 <namex+0xc0>
    ilock(ip);
    80003ddc:	854e                	mv	a0,s3
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	9a2080e7          	jalr	-1630(ra) # 80003780 <ilock>
    if(ip->type != T_DIR){
    80003de6:	04499783          	lh	a5,68(s3)
    80003dea:	f98793e3          	bne	a5,s8,80003d70 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003dee:	000b0563          	beqz	s6,80003df8 <namex+0xe6>
    80003df2:	0004c783          	lbu	a5,0(s1)
    80003df6:	d3cd                	beqz	a5,80003d98 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003df8:	865e                	mv	a2,s7
    80003dfa:	85d6                	mv	a1,s5
    80003dfc:	854e                	mv	a0,s3
    80003dfe:	00000097          	auipc	ra,0x0
    80003e02:	e64080e7          	jalr	-412(ra) # 80003c62 <dirlookup>
    80003e06:	8a2a                	mv	s4,a0
    80003e08:	dd51                	beqz	a0,80003da4 <namex+0x92>
    iunlockput(ip);
    80003e0a:	854e                	mv	a0,s3
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	bd6080e7          	jalr	-1066(ra) # 800039e2 <iunlockput>
    ip = next;
    80003e14:	89d2                	mv	s3,s4
  while(*path == '/')
    80003e16:	0004c783          	lbu	a5,0(s1)
    80003e1a:	05279763          	bne	a5,s2,80003e68 <namex+0x156>
    path++;
    80003e1e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e20:	0004c783          	lbu	a5,0(s1)
    80003e24:	ff278de3          	beq	a5,s2,80003e1e <namex+0x10c>
  if(*path == 0)
    80003e28:	c79d                	beqz	a5,80003e56 <namex+0x144>
    path++;
    80003e2a:	85a6                	mv	a1,s1
  len = path - s;
    80003e2c:	8a5e                	mv	s4,s7
    80003e2e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003e30:	01278963          	beq	a5,s2,80003e42 <namex+0x130>
    80003e34:	dfbd                	beqz	a5,80003db2 <namex+0xa0>
    path++;
    80003e36:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e38:	0004c783          	lbu	a5,0(s1)
    80003e3c:	ff279ce3          	bne	a5,s2,80003e34 <namex+0x122>
    80003e40:	bf8d                	j	80003db2 <namex+0xa0>
    memmove(name, s, len);
    80003e42:	2601                	sext.w	a2,a2
    80003e44:	8556                	mv	a0,s5
    80003e46:	ffffd097          	auipc	ra,0xffffd
    80003e4a:	f26080e7          	jalr	-218(ra) # 80000d6c <memmove>
    name[len] = 0;
    80003e4e:	9a56                	add	s4,s4,s5
    80003e50:	000a0023          	sb	zero,0(s4)
    80003e54:	bf9d                	j	80003dca <namex+0xb8>
  if(nameiparent){
    80003e56:	f20b03e3          	beqz	s6,80003d7c <namex+0x6a>
    iput(ip);
    80003e5a:	854e                	mv	a0,s3
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	ade080e7          	jalr	-1314(ra) # 8000393a <iput>
    return 0;
    80003e64:	4981                	li	s3,0
    80003e66:	bf19                	j	80003d7c <namex+0x6a>
  if(*path == 0)
    80003e68:	d7fd                	beqz	a5,80003e56 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e6a:	0004c783          	lbu	a5,0(s1)
    80003e6e:	85a6                	mv	a1,s1
    80003e70:	b7d1                	j	80003e34 <namex+0x122>

0000000080003e72 <dirlink>:
{
    80003e72:	7139                	addi	sp,sp,-64
    80003e74:	fc06                	sd	ra,56(sp)
    80003e76:	f822                	sd	s0,48(sp)
    80003e78:	f426                	sd	s1,40(sp)
    80003e7a:	f04a                	sd	s2,32(sp)
    80003e7c:	ec4e                	sd	s3,24(sp)
    80003e7e:	e852                	sd	s4,16(sp)
    80003e80:	0080                	addi	s0,sp,64
    80003e82:	892a                	mv	s2,a0
    80003e84:	8a2e                	mv	s4,a1
    80003e86:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e88:	4601                	li	a2,0
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	dd8080e7          	jalr	-552(ra) # 80003c62 <dirlookup>
    80003e92:	e93d                	bnez	a0,80003f08 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e94:	04c92483          	lw	s1,76(s2)
    80003e98:	c49d                	beqz	s1,80003ec6 <dirlink+0x54>
    80003e9a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e9c:	4741                	li	a4,16
    80003e9e:	86a6                	mv	a3,s1
    80003ea0:	fc040613          	addi	a2,s0,-64
    80003ea4:	4581                	li	a1,0
    80003ea6:	854a                	mv	a0,s2
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	b8c080e7          	jalr	-1140(ra) # 80003a34 <readi>
    80003eb0:	47c1                	li	a5,16
    80003eb2:	06f51163          	bne	a0,a5,80003f14 <dirlink+0xa2>
    if(de.inum == 0)
    80003eb6:	fc045783          	lhu	a5,-64(s0)
    80003eba:	c791                	beqz	a5,80003ec6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ebc:	24c1                	addiw	s1,s1,16
    80003ebe:	04c92783          	lw	a5,76(s2)
    80003ec2:	fcf4ede3          	bltu	s1,a5,80003e9c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ec6:	4639                	li	a2,14
    80003ec8:	85d2                	mv	a1,s4
    80003eca:	fc240513          	addi	a0,s0,-62
    80003ece:	ffffd097          	auipc	ra,0xffffd
    80003ed2:	f56080e7          	jalr	-170(ra) # 80000e24 <strncpy>
  de.inum = inum;
    80003ed6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eda:	4741                	li	a4,16
    80003edc:	86a6                	mv	a3,s1
    80003ede:	fc040613          	addi	a2,s0,-64
    80003ee2:	4581                	li	a1,0
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	00000097          	auipc	ra,0x0
    80003eea:	c46080e7          	jalr	-954(ra) # 80003b2c <writei>
    80003eee:	872a                	mv	a4,a0
    80003ef0:	47c1                	li	a5,16
  return 0;
    80003ef2:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ef4:	02f71863          	bne	a4,a5,80003f24 <dirlink+0xb2>
}
    80003ef8:	70e2                	ld	ra,56(sp)
    80003efa:	7442                	ld	s0,48(sp)
    80003efc:	74a2                	ld	s1,40(sp)
    80003efe:	7902                	ld	s2,32(sp)
    80003f00:	69e2                	ld	s3,24(sp)
    80003f02:	6a42                	ld	s4,16(sp)
    80003f04:	6121                	addi	sp,sp,64
    80003f06:	8082                	ret
    iput(ip);
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	a32080e7          	jalr	-1486(ra) # 8000393a <iput>
    return -1;
    80003f10:	557d                	li	a0,-1
    80003f12:	b7dd                	j	80003ef8 <dirlink+0x86>
      panic("dirlink read");
    80003f14:	00004517          	auipc	a0,0x4
    80003f18:	6ac50513          	addi	a0,a0,1708 # 800085c0 <syscalls+0x1c8>
    80003f1c:	ffffc097          	auipc	ra,0xffffc
    80003f20:	62c080e7          	jalr	1580(ra) # 80000548 <panic>
    panic("dirlink");
    80003f24:	00004517          	auipc	a0,0x4
    80003f28:	7b450513          	addi	a0,a0,1972 # 800086d8 <syscalls+0x2e0>
    80003f2c:	ffffc097          	auipc	ra,0xffffc
    80003f30:	61c080e7          	jalr	1564(ra) # 80000548 <panic>

0000000080003f34 <namei>:

struct inode*
namei(char *path)
{
    80003f34:	1101                	addi	sp,sp,-32
    80003f36:	ec06                	sd	ra,24(sp)
    80003f38:	e822                	sd	s0,16(sp)
    80003f3a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f3c:	fe040613          	addi	a2,s0,-32
    80003f40:	4581                	li	a1,0
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	dd0080e7          	jalr	-560(ra) # 80003d12 <namex>
}
    80003f4a:	60e2                	ld	ra,24(sp)
    80003f4c:	6442                	ld	s0,16(sp)
    80003f4e:	6105                	addi	sp,sp,32
    80003f50:	8082                	ret

0000000080003f52 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f52:	1141                	addi	sp,sp,-16
    80003f54:	e406                	sd	ra,8(sp)
    80003f56:	e022                	sd	s0,0(sp)
    80003f58:	0800                	addi	s0,sp,16
    80003f5a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f5c:	4585                	li	a1,1
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	db4080e7          	jalr	-588(ra) # 80003d12 <namex>
}
    80003f66:	60a2                	ld	ra,8(sp)
    80003f68:	6402                	ld	s0,0(sp)
    80003f6a:	0141                	addi	sp,sp,16
    80003f6c:	8082                	ret

0000000080003f6e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f6e:	1101                	addi	sp,sp,-32
    80003f70:	ec06                	sd	ra,24(sp)
    80003f72:	e822                	sd	s0,16(sp)
    80003f74:	e426                	sd	s1,8(sp)
    80003f76:	e04a                	sd	s2,0(sp)
    80003f78:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f7a:	0001e917          	auipc	s2,0x1e
    80003f7e:	98e90913          	addi	s2,s2,-1650 # 80021908 <log>
    80003f82:	01892583          	lw	a1,24(s2)
    80003f86:	02892503          	lw	a0,40(s2)
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	ff4080e7          	jalr	-12(ra) # 80002f7e <bread>
    80003f92:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f94:	02c92683          	lw	a3,44(s2)
    80003f98:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f9a:	02d05763          	blez	a3,80003fc8 <write_head+0x5a>
    80003f9e:	0001e797          	auipc	a5,0x1e
    80003fa2:	99a78793          	addi	a5,a5,-1638 # 80021938 <log+0x30>
    80003fa6:	05c50713          	addi	a4,a0,92
    80003faa:	36fd                	addiw	a3,a3,-1
    80003fac:	1682                	slli	a3,a3,0x20
    80003fae:	9281                	srli	a3,a3,0x20
    80003fb0:	068a                	slli	a3,a3,0x2
    80003fb2:	0001e617          	auipc	a2,0x1e
    80003fb6:	98a60613          	addi	a2,a2,-1654 # 8002193c <log+0x34>
    80003fba:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003fbc:	4390                	lw	a2,0(a5)
    80003fbe:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fc0:	0791                	addi	a5,a5,4
    80003fc2:	0711                	addi	a4,a4,4
    80003fc4:	fed79ce3          	bne	a5,a3,80003fbc <write_head+0x4e>
  }
  bwrite(buf);
    80003fc8:	8526                	mv	a0,s1
    80003fca:	fffff097          	auipc	ra,0xfffff
    80003fce:	0a6080e7          	jalr	166(ra) # 80003070 <bwrite>
  brelse(buf);
    80003fd2:	8526                	mv	a0,s1
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	0da080e7          	jalr	218(ra) # 800030ae <brelse>
}
    80003fdc:	60e2                	ld	ra,24(sp)
    80003fde:	6442                	ld	s0,16(sp)
    80003fe0:	64a2                	ld	s1,8(sp)
    80003fe2:	6902                	ld	s2,0(sp)
    80003fe4:	6105                	addi	sp,sp,32
    80003fe6:	8082                	ret

0000000080003fe8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fe8:	0001e797          	auipc	a5,0x1e
    80003fec:	94c7a783          	lw	a5,-1716(a5) # 80021934 <log+0x2c>
    80003ff0:	0af05663          	blez	a5,8000409c <install_trans+0xb4>
{
    80003ff4:	7139                	addi	sp,sp,-64
    80003ff6:	fc06                	sd	ra,56(sp)
    80003ff8:	f822                	sd	s0,48(sp)
    80003ffa:	f426                	sd	s1,40(sp)
    80003ffc:	f04a                	sd	s2,32(sp)
    80003ffe:	ec4e                	sd	s3,24(sp)
    80004000:	e852                	sd	s4,16(sp)
    80004002:	e456                	sd	s5,8(sp)
    80004004:	0080                	addi	s0,sp,64
    80004006:	0001ea97          	auipc	s5,0x1e
    8000400a:	932a8a93          	addi	s5,s5,-1742 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000400e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004010:	0001e997          	auipc	s3,0x1e
    80004014:	8f898993          	addi	s3,s3,-1800 # 80021908 <log>
    80004018:	0189a583          	lw	a1,24(s3)
    8000401c:	014585bb          	addw	a1,a1,s4
    80004020:	2585                	addiw	a1,a1,1
    80004022:	0289a503          	lw	a0,40(s3)
    80004026:	fffff097          	auipc	ra,0xfffff
    8000402a:	f58080e7          	jalr	-168(ra) # 80002f7e <bread>
    8000402e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004030:	000aa583          	lw	a1,0(s5)
    80004034:	0289a503          	lw	a0,40(s3)
    80004038:	fffff097          	auipc	ra,0xfffff
    8000403c:	f46080e7          	jalr	-186(ra) # 80002f7e <bread>
    80004040:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004042:	40000613          	li	a2,1024
    80004046:	05890593          	addi	a1,s2,88
    8000404a:	05850513          	addi	a0,a0,88
    8000404e:	ffffd097          	auipc	ra,0xffffd
    80004052:	d1e080e7          	jalr	-738(ra) # 80000d6c <memmove>
    bwrite(dbuf);  // write dst to disk
    80004056:	8526                	mv	a0,s1
    80004058:	fffff097          	auipc	ra,0xfffff
    8000405c:	018080e7          	jalr	24(ra) # 80003070 <bwrite>
    bunpin(dbuf);
    80004060:	8526                	mv	a0,s1
    80004062:	fffff097          	auipc	ra,0xfffff
    80004066:	126080e7          	jalr	294(ra) # 80003188 <bunpin>
    brelse(lbuf);
    8000406a:	854a                	mv	a0,s2
    8000406c:	fffff097          	auipc	ra,0xfffff
    80004070:	042080e7          	jalr	66(ra) # 800030ae <brelse>
    brelse(dbuf);
    80004074:	8526                	mv	a0,s1
    80004076:	fffff097          	auipc	ra,0xfffff
    8000407a:	038080e7          	jalr	56(ra) # 800030ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000407e:	2a05                	addiw	s4,s4,1
    80004080:	0a91                	addi	s5,s5,4
    80004082:	02c9a783          	lw	a5,44(s3)
    80004086:	f8fa49e3          	blt	s4,a5,80004018 <install_trans+0x30>
}
    8000408a:	70e2                	ld	ra,56(sp)
    8000408c:	7442                	ld	s0,48(sp)
    8000408e:	74a2                	ld	s1,40(sp)
    80004090:	7902                	ld	s2,32(sp)
    80004092:	69e2                	ld	s3,24(sp)
    80004094:	6a42                	ld	s4,16(sp)
    80004096:	6aa2                	ld	s5,8(sp)
    80004098:	6121                	addi	sp,sp,64
    8000409a:	8082                	ret
    8000409c:	8082                	ret

000000008000409e <initlog>:
{
    8000409e:	7179                	addi	sp,sp,-48
    800040a0:	f406                	sd	ra,40(sp)
    800040a2:	f022                	sd	s0,32(sp)
    800040a4:	ec26                	sd	s1,24(sp)
    800040a6:	e84a                	sd	s2,16(sp)
    800040a8:	e44e                	sd	s3,8(sp)
    800040aa:	1800                	addi	s0,sp,48
    800040ac:	892a                	mv	s2,a0
    800040ae:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040b0:	0001e497          	auipc	s1,0x1e
    800040b4:	85848493          	addi	s1,s1,-1960 # 80021908 <log>
    800040b8:	00004597          	auipc	a1,0x4
    800040bc:	51858593          	addi	a1,a1,1304 # 800085d0 <syscalls+0x1d8>
    800040c0:	8526                	mv	a0,s1
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	abe080e7          	jalr	-1346(ra) # 80000b80 <initlock>
  log.start = sb->logstart;
    800040ca:	0149a583          	lw	a1,20(s3)
    800040ce:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040d0:	0109a783          	lw	a5,16(s3)
    800040d4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040d6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040da:	854a                	mv	a0,s2
    800040dc:	fffff097          	auipc	ra,0xfffff
    800040e0:	ea2080e7          	jalr	-350(ra) # 80002f7e <bread>
  log.lh.n = lh->n;
    800040e4:	4d3c                	lw	a5,88(a0)
    800040e6:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040e8:	02f05563          	blez	a5,80004112 <initlog+0x74>
    800040ec:	05c50713          	addi	a4,a0,92
    800040f0:	0001e697          	auipc	a3,0x1e
    800040f4:	84868693          	addi	a3,a3,-1976 # 80021938 <log+0x30>
    800040f8:	37fd                	addiw	a5,a5,-1
    800040fa:	1782                	slli	a5,a5,0x20
    800040fc:	9381                	srli	a5,a5,0x20
    800040fe:	078a                	slli	a5,a5,0x2
    80004100:	06050613          	addi	a2,a0,96
    80004104:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004106:	4310                	lw	a2,0(a4)
    80004108:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000410a:	0711                	addi	a4,a4,4
    8000410c:	0691                	addi	a3,a3,4
    8000410e:	fef71ce3          	bne	a4,a5,80004106 <initlog+0x68>
  brelse(buf);
    80004112:	fffff097          	auipc	ra,0xfffff
    80004116:	f9c080e7          	jalr	-100(ra) # 800030ae <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    8000411a:	00000097          	auipc	ra,0x0
    8000411e:	ece080e7          	jalr	-306(ra) # 80003fe8 <install_trans>
  log.lh.n = 0;
    80004122:	0001e797          	auipc	a5,0x1e
    80004126:	8007a923          	sw	zero,-2030(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    8000412a:	00000097          	auipc	ra,0x0
    8000412e:	e44080e7          	jalr	-444(ra) # 80003f6e <write_head>
}
    80004132:	70a2                	ld	ra,40(sp)
    80004134:	7402                	ld	s0,32(sp)
    80004136:	64e2                	ld	s1,24(sp)
    80004138:	6942                	ld	s2,16(sp)
    8000413a:	69a2                	ld	s3,8(sp)
    8000413c:	6145                	addi	sp,sp,48
    8000413e:	8082                	ret

0000000080004140 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004140:	1101                	addi	sp,sp,-32
    80004142:	ec06                	sd	ra,24(sp)
    80004144:	e822                	sd	s0,16(sp)
    80004146:	e426                	sd	s1,8(sp)
    80004148:	e04a                	sd	s2,0(sp)
    8000414a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000414c:	0001d517          	auipc	a0,0x1d
    80004150:	7bc50513          	addi	a0,a0,1980 # 80021908 <log>
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	abc080e7          	jalr	-1348(ra) # 80000c10 <acquire>
  while(1){
    if(log.committing){
    8000415c:	0001d497          	auipc	s1,0x1d
    80004160:	7ac48493          	addi	s1,s1,1964 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004164:	4979                	li	s2,30
    80004166:	a039                	j	80004174 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004168:	85a6                	mv	a1,s1
    8000416a:	8526                	mv	a0,s1
    8000416c:	ffffe097          	auipc	ra,0xffffe
    80004170:	1b6080e7          	jalr	438(ra) # 80002322 <sleep>
    if(log.committing){
    80004174:	50dc                	lw	a5,36(s1)
    80004176:	fbed                	bnez	a5,80004168 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004178:	509c                	lw	a5,32(s1)
    8000417a:	0017871b          	addiw	a4,a5,1
    8000417e:	0007069b          	sext.w	a3,a4
    80004182:	0027179b          	slliw	a5,a4,0x2
    80004186:	9fb9                	addw	a5,a5,a4
    80004188:	0017979b          	slliw	a5,a5,0x1
    8000418c:	54d8                	lw	a4,44(s1)
    8000418e:	9fb9                	addw	a5,a5,a4
    80004190:	00f95963          	bge	s2,a5,800041a2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004194:	85a6                	mv	a1,s1
    80004196:	8526                	mv	a0,s1
    80004198:	ffffe097          	auipc	ra,0xffffe
    8000419c:	18a080e7          	jalr	394(ra) # 80002322 <sleep>
    800041a0:	bfd1                	j	80004174 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800041a2:	0001d517          	auipc	a0,0x1d
    800041a6:	76650513          	addi	a0,a0,1894 # 80021908 <log>
    800041aa:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800041ac:	ffffd097          	auipc	ra,0xffffd
    800041b0:	b18080e7          	jalr	-1256(ra) # 80000cc4 <release>
      break;
    }
  }
}
    800041b4:	60e2                	ld	ra,24(sp)
    800041b6:	6442                	ld	s0,16(sp)
    800041b8:	64a2                	ld	s1,8(sp)
    800041ba:	6902                	ld	s2,0(sp)
    800041bc:	6105                	addi	sp,sp,32
    800041be:	8082                	ret

00000000800041c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041c0:	7139                	addi	sp,sp,-64
    800041c2:	fc06                	sd	ra,56(sp)
    800041c4:	f822                	sd	s0,48(sp)
    800041c6:	f426                	sd	s1,40(sp)
    800041c8:	f04a                	sd	s2,32(sp)
    800041ca:	ec4e                	sd	s3,24(sp)
    800041cc:	e852                	sd	s4,16(sp)
    800041ce:	e456                	sd	s5,8(sp)
    800041d0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041d2:	0001d497          	auipc	s1,0x1d
    800041d6:	73648493          	addi	s1,s1,1846 # 80021908 <log>
    800041da:	8526                	mv	a0,s1
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	a34080e7          	jalr	-1484(ra) # 80000c10 <acquire>
  log.outstanding -= 1;
    800041e4:	509c                	lw	a5,32(s1)
    800041e6:	37fd                	addiw	a5,a5,-1
    800041e8:	0007891b          	sext.w	s2,a5
    800041ec:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041ee:	50dc                	lw	a5,36(s1)
    800041f0:	efb9                	bnez	a5,8000424e <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041f2:	06091663          	bnez	s2,8000425e <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800041f6:	0001d497          	auipc	s1,0x1d
    800041fa:	71248493          	addi	s1,s1,1810 # 80021908 <log>
    800041fe:	4785                	li	a5,1
    80004200:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004202:	8526                	mv	a0,s1
    80004204:	ffffd097          	auipc	ra,0xffffd
    80004208:	ac0080e7          	jalr	-1344(ra) # 80000cc4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000420c:	54dc                	lw	a5,44(s1)
    8000420e:	06f04763          	bgtz	a5,8000427c <end_op+0xbc>
    acquire(&log.lock);
    80004212:	0001d497          	auipc	s1,0x1d
    80004216:	6f648493          	addi	s1,s1,1782 # 80021908 <log>
    8000421a:	8526                	mv	a0,s1
    8000421c:	ffffd097          	auipc	ra,0xffffd
    80004220:	9f4080e7          	jalr	-1548(ra) # 80000c10 <acquire>
    log.committing = 0;
    80004224:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004228:	8526                	mv	a0,s1
    8000422a:	ffffe097          	auipc	ra,0xffffe
    8000422e:	27e080e7          	jalr	638(ra) # 800024a8 <wakeup>
    release(&log.lock);
    80004232:	8526                	mv	a0,s1
    80004234:	ffffd097          	auipc	ra,0xffffd
    80004238:	a90080e7          	jalr	-1392(ra) # 80000cc4 <release>
}
    8000423c:	70e2                	ld	ra,56(sp)
    8000423e:	7442                	ld	s0,48(sp)
    80004240:	74a2                	ld	s1,40(sp)
    80004242:	7902                	ld	s2,32(sp)
    80004244:	69e2                	ld	s3,24(sp)
    80004246:	6a42                	ld	s4,16(sp)
    80004248:	6aa2                	ld	s5,8(sp)
    8000424a:	6121                	addi	sp,sp,64
    8000424c:	8082                	ret
    panic("log.committing");
    8000424e:	00004517          	auipc	a0,0x4
    80004252:	38a50513          	addi	a0,a0,906 # 800085d8 <syscalls+0x1e0>
    80004256:	ffffc097          	auipc	ra,0xffffc
    8000425a:	2f2080e7          	jalr	754(ra) # 80000548 <panic>
    wakeup(&log);
    8000425e:	0001d497          	auipc	s1,0x1d
    80004262:	6aa48493          	addi	s1,s1,1706 # 80021908 <log>
    80004266:	8526                	mv	a0,s1
    80004268:	ffffe097          	auipc	ra,0xffffe
    8000426c:	240080e7          	jalr	576(ra) # 800024a8 <wakeup>
  release(&log.lock);
    80004270:	8526                	mv	a0,s1
    80004272:	ffffd097          	auipc	ra,0xffffd
    80004276:	a52080e7          	jalr	-1454(ra) # 80000cc4 <release>
  if(do_commit){
    8000427a:	b7c9                	j	8000423c <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000427c:	0001da97          	auipc	s5,0x1d
    80004280:	6bca8a93          	addi	s5,s5,1724 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004284:	0001da17          	auipc	s4,0x1d
    80004288:	684a0a13          	addi	s4,s4,1668 # 80021908 <log>
    8000428c:	018a2583          	lw	a1,24(s4)
    80004290:	012585bb          	addw	a1,a1,s2
    80004294:	2585                	addiw	a1,a1,1
    80004296:	028a2503          	lw	a0,40(s4)
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	ce4080e7          	jalr	-796(ra) # 80002f7e <bread>
    800042a2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042a4:	000aa583          	lw	a1,0(s5)
    800042a8:	028a2503          	lw	a0,40(s4)
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	cd2080e7          	jalr	-814(ra) # 80002f7e <bread>
    800042b4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042b6:	40000613          	li	a2,1024
    800042ba:	05850593          	addi	a1,a0,88
    800042be:	05848513          	addi	a0,s1,88
    800042c2:	ffffd097          	auipc	ra,0xffffd
    800042c6:	aaa080e7          	jalr	-1366(ra) # 80000d6c <memmove>
    bwrite(to);  // write the log
    800042ca:	8526                	mv	a0,s1
    800042cc:	fffff097          	auipc	ra,0xfffff
    800042d0:	da4080e7          	jalr	-604(ra) # 80003070 <bwrite>
    brelse(from);
    800042d4:	854e                	mv	a0,s3
    800042d6:	fffff097          	auipc	ra,0xfffff
    800042da:	dd8080e7          	jalr	-552(ra) # 800030ae <brelse>
    brelse(to);
    800042de:	8526                	mv	a0,s1
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	dce080e7          	jalr	-562(ra) # 800030ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042e8:	2905                	addiw	s2,s2,1
    800042ea:	0a91                	addi	s5,s5,4
    800042ec:	02ca2783          	lw	a5,44(s4)
    800042f0:	f8f94ee3          	blt	s2,a5,8000428c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042f4:	00000097          	auipc	ra,0x0
    800042f8:	c7a080e7          	jalr	-902(ra) # 80003f6e <write_head>
    install_trans(); // Now install writes to home locations
    800042fc:	00000097          	auipc	ra,0x0
    80004300:	cec080e7          	jalr	-788(ra) # 80003fe8 <install_trans>
    log.lh.n = 0;
    80004304:	0001d797          	auipc	a5,0x1d
    80004308:	6207a823          	sw	zero,1584(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	c62080e7          	jalr	-926(ra) # 80003f6e <write_head>
    80004314:	bdfd                	j	80004212 <end_op+0x52>

0000000080004316 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004316:	1101                	addi	sp,sp,-32
    80004318:	ec06                	sd	ra,24(sp)
    8000431a:	e822                	sd	s0,16(sp)
    8000431c:	e426                	sd	s1,8(sp)
    8000431e:	e04a                	sd	s2,0(sp)
    80004320:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004322:	0001d717          	auipc	a4,0x1d
    80004326:	61272703          	lw	a4,1554(a4) # 80021934 <log+0x2c>
    8000432a:	47f5                	li	a5,29
    8000432c:	08e7c063          	blt	a5,a4,800043ac <log_write+0x96>
    80004330:	84aa                	mv	s1,a0
    80004332:	0001d797          	auipc	a5,0x1d
    80004336:	5f27a783          	lw	a5,1522(a5) # 80021924 <log+0x1c>
    8000433a:	37fd                	addiw	a5,a5,-1
    8000433c:	06f75863          	bge	a4,a5,800043ac <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004340:	0001d797          	auipc	a5,0x1d
    80004344:	5e87a783          	lw	a5,1512(a5) # 80021928 <log+0x20>
    80004348:	06f05a63          	blez	a5,800043bc <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000434c:	0001d917          	auipc	s2,0x1d
    80004350:	5bc90913          	addi	s2,s2,1468 # 80021908 <log>
    80004354:	854a                	mv	a0,s2
    80004356:	ffffd097          	auipc	ra,0xffffd
    8000435a:	8ba080e7          	jalr	-1862(ra) # 80000c10 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000435e:	02c92603          	lw	a2,44(s2)
    80004362:	06c05563          	blez	a2,800043cc <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004366:	44cc                	lw	a1,12(s1)
    80004368:	0001d717          	auipc	a4,0x1d
    8000436c:	5d070713          	addi	a4,a4,1488 # 80021938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004370:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004372:	4314                	lw	a3,0(a4)
    80004374:	04b68d63          	beq	a3,a1,800043ce <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004378:	2785                	addiw	a5,a5,1
    8000437a:	0711                	addi	a4,a4,4
    8000437c:	fec79be3          	bne	a5,a2,80004372 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004380:	0621                	addi	a2,a2,8
    80004382:	060a                	slli	a2,a2,0x2
    80004384:	0001d797          	auipc	a5,0x1d
    80004388:	58478793          	addi	a5,a5,1412 # 80021908 <log>
    8000438c:	963e                	add	a2,a2,a5
    8000438e:	44dc                	lw	a5,12(s1)
    80004390:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004392:	8526                	mv	a0,s1
    80004394:	fffff097          	auipc	ra,0xfffff
    80004398:	db8080e7          	jalr	-584(ra) # 8000314c <bpin>
    log.lh.n++;
    8000439c:	0001d717          	auipc	a4,0x1d
    800043a0:	56c70713          	addi	a4,a4,1388 # 80021908 <log>
    800043a4:	575c                	lw	a5,44(a4)
    800043a6:	2785                	addiw	a5,a5,1
    800043a8:	d75c                	sw	a5,44(a4)
    800043aa:	a83d                	j	800043e8 <log_write+0xd2>
    panic("too big a transaction");
    800043ac:	00004517          	auipc	a0,0x4
    800043b0:	23c50513          	addi	a0,a0,572 # 800085e8 <syscalls+0x1f0>
    800043b4:	ffffc097          	auipc	ra,0xffffc
    800043b8:	194080e7          	jalr	404(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    800043bc:	00004517          	auipc	a0,0x4
    800043c0:	24450513          	addi	a0,a0,580 # 80008600 <syscalls+0x208>
    800043c4:	ffffc097          	auipc	ra,0xffffc
    800043c8:	184080e7          	jalr	388(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800043cc:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800043ce:	00878713          	addi	a4,a5,8
    800043d2:	00271693          	slli	a3,a4,0x2
    800043d6:	0001d717          	auipc	a4,0x1d
    800043da:	53270713          	addi	a4,a4,1330 # 80021908 <log>
    800043de:	9736                	add	a4,a4,a3
    800043e0:	44d4                	lw	a3,12(s1)
    800043e2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043e4:	faf607e3          	beq	a2,a5,80004392 <log_write+0x7c>
  }
  release(&log.lock);
    800043e8:	0001d517          	auipc	a0,0x1d
    800043ec:	52050513          	addi	a0,a0,1312 # 80021908 <log>
    800043f0:	ffffd097          	auipc	ra,0xffffd
    800043f4:	8d4080e7          	jalr	-1836(ra) # 80000cc4 <release>
}
    800043f8:	60e2                	ld	ra,24(sp)
    800043fa:	6442                	ld	s0,16(sp)
    800043fc:	64a2                	ld	s1,8(sp)
    800043fe:	6902                	ld	s2,0(sp)
    80004400:	6105                	addi	sp,sp,32
    80004402:	8082                	ret

0000000080004404 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004404:	1101                	addi	sp,sp,-32
    80004406:	ec06                	sd	ra,24(sp)
    80004408:	e822                	sd	s0,16(sp)
    8000440a:	e426                	sd	s1,8(sp)
    8000440c:	e04a                	sd	s2,0(sp)
    8000440e:	1000                	addi	s0,sp,32
    80004410:	84aa                	mv	s1,a0
    80004412:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004414:	00004597          	auipc	a1,0x4
    80004418:	20c58593          	addi	a1,a1,524 # 80008620 <syscalls+0x228>
    8000441c:	0521                	addi	a0,a0,8
    8000441e:	ffffc097          	auipc	ra,0xffffc
    80004422:	762080e7          	jalr	1890(ra) # 80000b80 <initlock>
  lk->name = name;
    80004426:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000442a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000442e:	0204a423          	sw	zero,40(s1)
}
    80004432:	60e2                	ld	ra,24(sp)
    80004434:	6442                	ld	s0,16(sp)
    80004436:	64a2                	ld	s1,8(sp)
    80004438:	6902                	ld	s2,0(sp)
    8000443a:	6105                	addi	sp,sp,32
    8000443c:	8082                	ret

000000008000443e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000443e:	1101                	addi	sp,sp,-32
    80004440:	ec06                	sd	ra,24(sp)
    80004442:	e822                	sd	s0,16(sp)
    80004444:	e426                	sd	s1,8(sp)
    80004446:	e04a                	sd	s2,0(sp)
    80004448:	1000                	addi	s0,sp,32
    8000444a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000444c:	00850913          	addi	s2,a0,8
    80004450:	854a                	mv	a0,s2
    80004452:	ffffc097          	auipc	ra,0xffffc
    80004456:	7be080e7          	jalr	1982(ra) # 80000c10 <acquire>
  while (lk->locked) {
    8000445a:	409c                	lw	a5,0(s1)
    8000445c:	cb89                	beqz	a5,8000446e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000445e:	85ca                	mv	a1,s2
    80004460:	8526                	mv	a0,s1
    80004462:	ffffe097          	auipc	ra,0xffffe
    80004466:	ec0080e7          	jalr	-320(ra) # 80002322 <sleep>
  while (lk->locked) {
    8000446a:	409c                	lw	a5,0(s1)
    8000446c:	fbed                	bnez	a5,8000445e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000446e:	4785                	li	a5,1
    80004470:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004472:	ffffd097          	auipc	ra,0xffffd
    80004476:	6a0080e7          	jalr	1696(ra) # 80001b12 <myproc>
    8000447a:	5d1c                	lw	a5,56(a0)
    8000447c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000447e:	854a                	mv	a0,s2
    80004480:	ffffd097          	auipc	ra,0xffffd
    80004484:	844080e7          	jalr	-1980(ra) # 80000cc4 <release>
}
    80004488:	60e2                	ld	ra,24(sp)
    8000448a:	6442                	ld	s0,16(sp)
    8000448c:	64a2                	ld	s1,8(sp)
    8000448e:	6902                	ld	s2,0(sp)
    80004490:	6105                	addi	sp,sp,32
    80004492:	8082                	ret

0000000080004494 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004494:	1101                	addi	sp,sp,-32
    80004496:	ec06                	sd	ra,24(sp)
    80004498:	e822                	sd	s0,16(sp)
    8000449a:	e426                	sd	s1,8(sp)
    8000449c:	e04a                	sd	s2,0(sp)
    8000449e:	1000                	addi	s0,sp,32
    800044a0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044a2:	00850913          	addi	s2,a0,8
    800044a6:	854a                	mv	a0,s2
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	768080e7          	jalr	1896(ra) # 80000c10 <acquire>
  lk->locked = 0;
    800044b0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044b4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044b8:	8526                	mv	a0,s1
    800044ba:	ffffe097          	auipc	ra,0xffffe
    800044be:	fee080e7          	jalr	-18(ra) # 800024a8 <wakeup>
  release(&lk->lk);
    800044c2:	854a                	mv	a0,s2
    800044c4:	ffffd097          	auipc	ra,0xffffd
    800044c8:	800080e7          	jalr	-2048(ra) # 80000cc4 <release>
}
    800044cc:	60e2                	ld	ra,24(sp)
    800044ce:	6442                	ld	s0,16(sp)
    800044d0:	64a2                	ld	s1,8(sp)
    800044d2:	6902                	ld	s2,0(sp)
    800044d4:	6105                	addi	sp,sp,32
    800044d6:	8082                	ret

00000000800044d8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044d8:	7179                	addi	sp,sp,-48
    800044da:	f406                	sd	ra,40(sp)
    800044dc:	f022                	sd	s0,32(sp)
    800044de:	ec26                	sd	s1,24(sp)
    800044e0:	e84a                	sd	s2,16(sp)
    800044e2:	e44e                	sd	s3,8(sp)
    800044e4:	1800                	addi	s0,sp,48
    800044e6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044e8:	00850913          	addi	s2,a0,8
    800044ec:	854a                	mv	a0,s2
    800044ee:	ffffc097          	auipc	ra,0xffffc
    800044f2:	722080e7          	jalr	1826(ra) # 80000c10 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044f6:	409c                	lw	a5,0(s1)
    800044f8:	ef99                	bnez	a5,80004516 <holdingsleep+0x3e>
    800044fa:	4481                	li	s1,0
  release(&lk->lk);
    800044fc:	854a                	mv	a0,s2
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	7c6080e7          	jalr	1990(ra) # 80000cc4 <release>
  return r;
}
    80004506:	8526                	mv	a0,s1
    80004508:	70a2                	ld	ra,40(sp)
    8000450a:	7402                	ld	s0,32(sp)
    8000450c:	64e2                	ld	s1,24(sp)
    8000450e:	6942                	ld	s2,16(sp)
    80004510:	69a2                	ld	s3,8(sp)
    80004512:	6145                	addi	sp,sp,48
    80004514:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004516:	0284a983          	lw	s3,40(s1)
    8000451a:	ffffd097          	auipc	ra,0xffffd
    8000451e:	5f8080e7          	jalr	1528(ra) # 80001b12 <myproc>
    80004522:	5d04                	lw	s1,56(a0)
    80004524:	413484b3          	sub	s1,s1,s3
    80004528:	0014b493          	seqz	s1,s1
    8000452c:	bfc1                	j	800044fc <holdingsleep+0x24>

000000008000452e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000452e:	1141                	addi	sp,sp,-16
    80004530:	e406                	sd	ra,8(sp)
    80004532:	e022                	sd	s0,0(sp)
    80004534:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004536:	00004597          	auipc	a1,0x4
    8000453a:	0fa58593          	addi	a1,a1,250 # 80008630 <syscalls+0x238>
    8000453e:	0001d517          	auipc	a0,0x1d
    80004542:	51250513          	addi	a0,a0,1298 # 80021a50 <ftable>
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	63a080e7          	jalr	1594(ra) # 80000b80 <initlock>
}
    8000454e:	60a2                	ld	ra,8(sp)
    80004550:	6402                	ld	s0,0(sp)
    80004552:	0141                	addi	sp,sp,16
    80004554:	8082                	ret

0000000080004556 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004556:	1101                	addi	sp,sp,-32
    80004558:	ec06                	sd	ra,24(sp)
    8000455a:	e822                	sd	s0,16(sp)
    8000455c:	e426                	sd	s1,8(sp)
    8000455e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004560:	0001d517          	auipc	a0,0x1d
    80004564:	4f050513          	addi	a0,a0,1264 # 80021a50 <ftable>
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	6a8080e7          	jalr	1704(ra) # 80000c10 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004570:	0001d497          	auipc	s1,0x1d
    80004574:	4f848493          	addi	s1,s1,1272 # 80021a68 <ftable+0x18>
    80004578:	0001e717          	auipc	a4,0x1e
    8000457c:	49070713          	addi	a4,a4,1168 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    80004580:	40dc                	lw	a5,4(s1)
    80004582:	cf99                	beqz	a5,800045a0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004584:	02848493          	addi	s1,s1,40
    80004588:	fee49ce3          	bne	s1,a4,80004580 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000458c:	0001d517          	auipc	a0,0x1d
    80004590:	4c450513          	addi	a0,a0,1220 # 80021a50 <ftable>
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	730080e7          	jalr	1840(ra) # 80000cc4 <release>
  return 0;
    8000459c:	4481                	li	s1,0
    8000459e:	a819                	j	800045b4 <filealloc+0x5e>
      f->ref = 1;
    800045a0:	4785                	li	a5,1
    800045a2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045a4:	0001d517          	auipc	a0,0x1d
    800045a8:	4ac50513          	addi	a0,a0,1196 # 80021a50 <ftable>
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	718080e7          	jalr	1816(ra) # 80000cc4 <release>
}
    800045b4:	8526                	mv	a0,s1
    800045b6:	60e2                	ld	ra,24(sp)
    800045b8:	6442                	ld	s0,16(sp)
    800045ba:	64a2                	ld	s1,8(sp)
    800045bc:	6105                	addi	sp,sp,32
    800045be:	8082                	ret

00000000800045c0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045c0:	1101                	addi	sp,sp,-32
    800045c2:	ec06                	sd	ra,24(sp)
    800045c4:	e822                	sd	s0,16(sp)
    800045c6:	e426                	sd	s1,8(sp)
    800045c8:	1000                	addi	s0,sp,32
    800045ca:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045cc:	0001d517          	auipc	a0,0x1d
    800045d0:	48450513          	addi	a0,a0,1156 # 80021a50 <ftable>
    800045d4:	ffffc097          	auipc	ra,0xffffc
    800045d8:	63c080e7          	jalr	1596(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    800045dc:	40dc                	lw	a5,4(s1)
    800045de:	02f05263          	blez	a5,80004602 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045e2:	2785                	addiw	a5,a5,1
    800045e4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045e6:	0001d517          	auipc	a0,0x1d
    800045ea:	46a50513          	addi	a0,a0,1130 # 80021a50 <ftable>
    800045ee:	ffffc097          	auipc	ra,0xffffc
    800045f2:	6d6080e7          	jalr	1750(ra) # 80000cc4 <release>
  return f;
}
    800045f6:	8526                	mv	a0,s1
    800045f8:	60e2                	ld	ra,24(sp)
    800045fa:	6442                	ld	s0,16(sp)
    800045fc:	64a2                	ld	s1,8(sp)
    800045fe:	6105                	addi	sp,sp,32
    80004600:	8082                	ret
    panic("filedup");
    80004602:	00004517          	auipc	a0,0x4
    80004606:	03650513          	addi	a0,a0,54 # 80008638 <syscalls+0x240>
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	f3e080e7          	jalr	-194(ra) # 80000548 <panic>

0000000080004612 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004612:	7139                	addi	sp,sp,-64
    80004614:	fc06                	sd	ra,56(sp)
    80004616:	f822                	sd	s0,48(sp)
    80004618:	f426                	sd	s1,40(sp)
    8000461a:	f04a                	sd	s2,32(sp)
    8000461c:	ec4e                	sd	s3,24(sp)
    8000461e:	e852                	sd	s4,16(sp)
    80004620:	e456                	sd	s5,8(sp)
    80004622:	0080                	addi	s0,sp,64
    80004624:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004626:	0001d517          	auipc	a0,0x1d
    8000462a:	42a50513          	addi	a0,a0,1066 # 80021a50 <ftable>
    8000462e:	ffffc097          	auipc	ra,0xffffc
    80004632:	5e2080e7          	jalr	1506(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    80004636:	40dc                	lw	a5,4(s1)
    80004638:	06f05163          	blez	a5,8000469a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000463c:	37fd                	addiw	a5,a5,-1
    8000463e:	0007871b          	sext.w	a4,a5
    80004642:	c0dc                	sw	a5,4(s1)
    80004644:	06e04363          	bgtz	a4,800046aa <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004648:	0004a903          	lw	s2,0(s1)
    8000464c:	0094ca83          	lbu	s5,9(s1)
    80004650:	0104ba03          	ld	s4,16(s1)
    80004654:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004658:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000465c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004660:	0001d517          	auipc	a0,0x1d
    80004664:	3f050513          	addi	a0,a0,1008 # 80021a50 <ftable>
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	65c080e7          	jalr	1628(ra) # 80000cc4 <release>

  if(ff.type == FD_PIPE){
    80004670:	4785                	li	a5,1
    80004672:	04f90d63          	beq	s2,a5,800046cc <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004676:	3979                	addiw	s2,s2,-2
    80004678:	4785                	li	a5,1
    8000467a:	0527e063          	bltu	a5,s2,800046ba <fileclose+0xa8>
    begin_op();
    8000467e:	00000097          	auipc	ra,0x0
    80004682:	ac2080e7          	jalr	-1342(ra) # 80004140 <begin_op>
    iput(ff.ip);
    80004686:	854e                	mv	a0,s3
    80004688:	fffff097          	auipc	ra,0xfffff
    8000468c:	2b2080e7          	jalr	690(ra) # 8000393a <iput>
    end_op();
    80004690:	00000097          	auipc	ra,0x0
    80004694:	b30080e7          	jalr	-1232(ra) # 800041c0 <end_op>
    80004698:	a00d                	j	800046ba <fileclose+0xa8>
    panic("fileclose");
    8000469a:	00004517          	auipc	a0,0x4
    8000469e:	fa650513          	addi	a0,a0,-90 # 80008640 <syscalls+0x248>
    800046a2:	ffffc097          	auipc	ra,0xffffc
    800046a6:	ea6080e7          	jalr	-346(ra) # 80000548 <panic>
    release(&ftable.lock);
    800046aa:	0001d517          	auipc	a0,0x1d
    800046ae:	3a650513          	addi	a0,a0,934 # 80021a50 <ftable>
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	612080e7          	jalr	1554(ra) # 80000cc4 <release>
  }
}
    800046ba:	70e2                	ld	ra,56(sp)
    800046bc:	7442                	ld	s0,48(sp)
    800046be:	74a2                	ld	s1,40(sp)
    800046c0:	7902                	ld	s2,32(sp)
    800046c2:	69e2                	ld	s3,24(sp)
    800046c4:	6a42                	ld	s4,16(sp)
    800046c6:	6aa2                	ld	s5,8(sp)
    800046c8:	6121                	addi	sp,sp,64
    800046ca:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046cc:	85d6                	mv	a1,s5
    800046ce:	8552                	mv	a0,s4
    800046d0:	00000097          	auipc	ra,0x0
    800046d4:	372080e7          	jalr	882(ra) # 80004a42 <pipeclose>
    800046d8:	b7cd                	j	800046ba <fileclose+0xa8>

00000000800046da <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046da:	715d                	addi	sp,sp,-80
    800046dc:	e486                	sd	ra,72(sp)
    800046de:	e0a2                	sd	s0,64(sp)
    800046e0:	fc26                	sd	s1,56(sp)
    800046e2:	f84a                	sd	s2,48(sp)
    800046e4:	f44e                	sd	s3,40(sp)
    800046e6:	0880                	addi	s0,sp,80
    800046e8:	84aa                	mv	s1,a0
    800046ea:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046ec:	ffffd097          	auipc	ra,0xffffd
    800046f0:	426080e7          	jalr	1062(ra) # 80001b12 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046f4:	409c                	lw	a5,0(s1)
    800046f6:	37f9                	addiw	a5,a5,-2
    800046f8:	4705                	li	a4,1
    800046fa:	04f76763          	bltu	a4,a5,80004748 <filestat+0x6e>
    800046fe:	892a                	mv	s2,a0
    ilock(f->ip);
    80004700:	6c88                	ld	a0,24(s1)
    80004702:	fffff097          	auipc	ra,0xfffff
    80004706:	07e080e7          	jalr	126(ra) # 80003780 <ilock>
    stati(f->ip, &st);
    8000470a:	fb840593          	addi	a1,s0,-72
    8000470e:	6c88                	ld	a0,24(s1)
    80004710:	fffff097          	auipc	ra,0xfffff
    80004714:	2fa080e7          	jalr	762(ra) # 80003a0a <stati>
    iunlock(f->ip);
    80004718:	6c88                	ld	a0,24(s1)
    8000471a:	fffff097          	auipc	ra,0xfffff
    8000471e:	128080e7          	jalr	296(ra) # 80003842 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004722:	46e1                	li	a3,24
    80004724:	fb840613          	addi	a2,s0,-72
    80004728:	85ce                	mv	a1,s3
    8000472a:	05093503          	ld	a0,80(s2)
    8000472e:	ffffd097          	auipc	ra,0xffffd
    80004732:	ffe080e7          	jalr	-2(ra) # 8000172c <copyout>
    80004736:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000473a:	60a6                	ld	ra,72(sp)
    8000473c:	6406                	ld	s0,64(sp)
    8000473e:	74e2                	ld	s1,56(sp)
    80004740:	7942                	ld	s2,48(sp)
    80004742:	79a2                	ld	s3,40(sp)
    80004744:	6161                	addi	sp,sp,80
    80004746:	8082                	ret
  return -1;
    80004748:	557d                	li	a0,-1
    8000474a:	bfc5                	j	8000473a <filestat+0x60>

000000008000474c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000474c:	7179                	addi	sp,sp,-48
    8000474e:	f406                	sd	ra,40(sp)
    80004750:	f022                	sd	s0,32(sp)
    80004752:	ec26                	sd	s1,24(sp)
    80004754:	e84a                	sd	s2,16(sp)
    80004756:	e44e                	sd	s3,8(sp)
    80004758:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000475a:	00854783          	lbu	a5,8(a0)
    8000475e:	c3d5                	beqz	a5,80004802 <fileread+0xb6>
    80004760:	84aa                	mv	s1,a0
    80004762:	89ae                	mv	s3,a1
    80004764:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004766:	411c                	lw	a5,0(a0)
    80004768:	4705                	li	a4,1
    8000476a:	04e78963          	beq	a5,a4,800047bc <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000476e:	470d                	li	a4,3
    80004770:	04e78d63          	beq	a5,a4,800047ca <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004774:	4709                	li	a4,2
    80004776:	06e79e63          	bne	a5,a4,800047f2 <fileread+0xa6>
    ilock(f->ip);
    8000477a:	6d08                	ld	a0,24(a0)
    8000477c:	fffff097          	auipc	ra,0xfffff
    80004780:	004080e7          	jalr	4(ra) # 80003780 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004784:	874a                	mv	a4,s2
    80004786:	5094                	lw	a3,32(s1)
    80004788:	864e                	mv	a2,s3
    8000478a:	4585                	li	a1,1
    8000478c:	6c88                	ld	a0,24(s1)
    8000478e:	fffff097          	auipc	ra,0xfffff
    80004792:	2a6080e7          	jalr	678(ra) # 80003a34 <readi>
    80004796:	892a                	mv	s2,a0
    80004798:	00a05563          	blez	a0,800047a2 <fileread+0x56>
      f->off += r;
    8000479c:	509c                	lw	a5,32(s1)
    8000479e:	9fa9                	addw	a5,a5,a0
    800047a0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047a2:	6c88                	ld	a0,24(s1)
    800047a4:	fffff097          	auipc	ra,0xfffff
    800047a8:	09e080e7          	jalr	158(ra) # 80003842 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800047ac:	854a                	mv	a0,s2
    800047ae:	70a2                	ld	ra,40(sp)
    800047b0:	7402                	ld	s0,32(sp)
    800047b2:	64e2                	ld	s1,24(sp)
    800047b4:	6942                	ld	s2,16(sp)
    800047b6:	69a2                	ld	s3,8(sp)
    800047b8:	6145                	addi	sp,sp,48
    800047ba:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047bc:	6908                	ld	a0,16(a0)
    800047be:	00000097          	auipc	ra,0x0
    800047c2:	418080e7          	jalr	1048(ra) # 80004bd6 <piperead>
    800047c6:	892a                	mv	s2,a0
    800047c8:	b7d5                	j	800047ac <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047ca:	02451783          	lh	a5,36(a0)
    800047ce:	03079693          	slli	a3,a5,0x30
    800047d2:	92c1                	srli	a3,a3,0x30
    800047d4:	4725                	li	a4,9
    800047d6:	02d76863          	bltu	a4,a3,80004806 <fileread+0xba>
    800047da:	0792                	slli	a5,a5,0x4
    800047dc:	0001d717          	auipc	a4,0x1d
    800047e0:	1d470713          	addi	a4,a4,468 # 800219b0 <devsw>
    800047e4:	97ba                	add	a5,a5,a4
    800047e6:	639c                	ld	a5,0(a5)
    800047e8:	c38d                	beqz	a5,8000480a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047ea:	4505                	li	a0,1
    800047ec:	9782                	jalr	a5
    800047ee:	892a                	mv	s2,a0
    800047f0:	bf75                	j	800047ac <fileread+0x60>
    panic("fileread");
    800047f2:	00004517          	auipc	a0,0x4
    800047f6:	e5e50513          	addi	a0,a0,-418 # 80008650 <syscalls+0x258>
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	d4e080e7          	jalr	-690(ra) # 80000548 <panic>
    return -1;
    80004802:	597d                	li	s2,-1
    80004804:	b765                	j	800047ac <fileread+0x60>
      return -1;
    80004806:	597d                	li	s2,-1
    80004808:	b755                	j	800047ac <fileread+0x60>
    8000480a:	597d                	li	s2,-1
    8000480c:	b745                	j	800047ac <fileread+0x60>

000000008000480e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000480e:	00954783          	lbu	a5,9(a0)
    80004812:	14078563          	beqz	a5,8000495c <filewrite+0x14e>
{
    80004816:	715d                	addi	sp,sp,-80
    80004818:	e486                	sd	ra,72(sp)
    8000481a:	e0a2                	sd	s0,64(sp)
    8000481c:	fc26                	sd	s1,56(sp)
    8000481e:	f84a                	sd	s2,48(sp)
    80004820:	f44e                	sd	s3,40(sp)
    80004822:	f052                	sd	s4,32(sp)
    80004824:	ec56                	sd	s5,24(sp)
    80004826:	e85a                	sd	s6,16(sp)
    80004828:	e45e                	sd	s7,8(sp)
    8000482a:	e062                	sd	s8,0(sp)
    8000482c:	0880                	addi	s0,sp,80
    8000482e:	892a                	mv	s2,a0
    80004830:	8aae                	mv	s5,a1
    80004832:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004834:	411c                	lw	a5,0(a0)
    80004836:	4705                	li	a4,1
    80004838:	02e78263          	beq	a5,a4,8000485c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000483c:	470d                	li	a4,3
    8000483e:	02e78563          	beq	a5,a4,80004868 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004842:	4709                	li	a4,2
    80004844:	10e79463          	bne	a5,a4,8000494c <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004848:	0ec05e63          	blez	a2,80004944 <filewrite+0x136>
    int i = 0;
    8000484c:	4981                	li	s3,0
    8000484e:	6b05                	lui	s6,0x1
    80004850:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004854:	6b85                	lui	s7,0x1
    80004856:	c00b8b9b          	addiw	s7,s7,-1024
    8000485a:	a851                	j	800048ee <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000485c:	6908                	ld	a0,16(a0)
    8000485e:	00000097          	auipc	ra,0x0
    80004862:	254080e7          	jalr	596(ra) # 80004ab2 <pipewrite>
    80004866:	a85d                	j	8000491c <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004868:	02451783          	lh	a5,36(a0)
    8000486c:	03079693          	slli	a3,a5,0x30
    80004870:	92c1                	srli	a3,a3,0x30
    80004872:	4725                	li	a4,9
    80004874:	0ed76663          	bltu	a4,a3,80004960 <filewrite+0x152>
    80004878:	0792                	slli	a5,a5,0x4
    8000487a:	0001d717          	auipc	a4,0x1d
    8000487e:	13670713          	addi	a4,a4,310 # 800219b0 <devsw>
    80004882:	97ba                	add	a5,a5,a4
    80004884:	679c                	ld	a5,8(a5)
    80004886:	cff9                	beqz	a5,80004964 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004888:	4505                	li	a0,1
    8000488a:	9782                	jalr	a5
    8000488c:	a841                	j	8000491c <filewrite+0x10e>
    8000488e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004892:	00000097          	auipc	ra,0x0
    80004896:	8ae080e7          	jalr	-1874(ra) # 80004140 <begin_op>
      ilock(f->ip);
    8000489a:	01893503          	ld	a0,24(s2)
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	ee2080e7          	jalr	-286(ra) # 80003780 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048a6:	8762                	mv	a4,s8
    800048a8:	02092683          	lw	a3,32(s2)
    800048ac:	01598633          	add	a2,s3,s5
    800048b0:	4585                	li	a1,1
    800048b2:	01893503          	ld	a0,24(s2)
    800048b6:	fffff097          	auipc	ra,0xfffff
    800048ba:	276080e7          	jalr	630(ra) # 80003b2c <writei>
    800048be:	84aa                	mv	s1,a0
    800048c0:	02a05f63          	blez	a0,800048fe <filewrite+0xf0>
        f->off += r;
    800048c4:	02092783          	lw	a5,32(s2)
    800048c8:	9fa9                	addw	a5,a5,a0
    800048ca:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048ce:	01893503          	ld	a0,24(s2)
    800048d2:	fffff097          	auipc	ra,0xfffff
    800048d6:	f70080e7          	jalr	-144(ra) # 80003842 <iunlock>
      end_op();
    800048da:	00000097          	auipc	ra,0x0
    800048de:	8e6080e7          	jalr	-1818(ra) # 800041c0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800048e2:	049c1963          	bne	s8,s1,80004934 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800048e6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048ea:	0349d663          	bge	s3,s4,80004916 <filewrite+0x108>
      int n1 = n - i;
    800048ee:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800048f2:	84be                	mv	s1,a5
    800048f4:	2781                	sext.w	a5,a5
    800048f6:	f8fb5ce3          	bge	s6,a5,8000488e <filewrite+0x80>
    800048fa:	84de                	mv	s1,s7
    800048fc:	bf49                	j	8000488e <filewrite+0x80>
      iunlock(f->ip);
    800048fe:	01893503          	ld	a0,24(s2)
    80004902:	fffff097          	auipc	ra,0xfffff
    80004906:	f40080e7          	jalr	-192(ra) # 80003842 <iunlock>
      end_op();
    8000490a:	00000097          	auipc	ra,0x0
    8000490e:	8b6080e7          	jalr	-1866(ra) # 800041c0 <end_op>
      if(r < 0)
    80004912:	fc04d8e3          	bgez	s1,800048e2 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004916:	8552                	mv	a0,s4
    80004918:	033a1863          	bne	s4,s3,80004948 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000491c:	60a6                	ld	ra,72(sp)
    8000491e:	6406                	ld	s0,64(sp)
    80004920:	74e2                	ld	s1,56(sp)
    80004922:	7942                	ld	s2,48(sp)
    80004924:	79a2                	ld	s3,40(sp)
    80004926:	7a02                	ld	s4,32(sp)
    80004928:	6ae2                	ld	s5,24(sp)
    8000492a:	6b42                	ld	s6,16(sp)
    8000492c:	6ba2                	ld	s7,8(sp)
    8000492e:	6c02                	ld	s8,0(sp)
    80004930:	6161                	addi	sp,sp,80
    80004932:	8082                	ret
        panic("short filewrite");
    80004934:	00004517          	auipc	a0,0x4
    80004938:	d2c50513          	addi	a0,a0,-724 # 80008660 <syscalls+0x268>
    8000493c:	ffffc097          	auipc	ra,0xffffc
    80004940:	c0c080e7          	jalr	-1012(ra) # 80000548 <panic>
    int i = 0;
    80004944:	4981                	li	s3,0
    80004946:	bfc1                	j	80004916 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004948:	557d                	li	a0,-1
    8000494a:	bfc9                	j	8000491c <filewrite+0x10e>
    panic("filewrite");
    8000494c:	00004517          	auipc	a0,0x4
    80004950:	d2450513          	addi	a0,a0,-732 # 80008670 <syscalls+0x278>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	bf4080e7          	jalr	-1036(ra) # 80000548 <panic>
    return -1;
    8000495c:	557d                	li	a0,-1
}
    8000495e:	8082                	ret
      return -1;
    80004960:	557d                	li	a0,-1
    80004962:	bf6d                	j	8000491c <filewrite+0x10e>
    80004964:	557d                	li	a0,-1
    80004966:	bf5d                	j	8000491c <filewrite+0x10e>

0000000080004968 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004968:	7179                	addi	sp,sp,-48
    8000496a:	f406                	sd	ra,40(sp)
    8000496c:	f022                	sd	s0,32(sp)
    8000496e:	ec26                	sd	s1,24(sp)
    80004970:	e84a                	sd	s2,16(sp)
    80004972:	e44e                	sd	s3,8(sp)
    80004974:	e052                	sd	s4,0(sp)
    80004976:	1800                	addi	s0,sp,48
    80004978:	84aa                	mv	s1,a0
    8000497a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000497c:	0005b023          	sd	zero,0(a1)
    80004980:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004984:	00000097          	auipc	ra,0x0
    80004988:	bd2080e7          	jalr	-1070(ra) # 80004556 <filealloc>
    8000498c:	e088                	sd	a0,0(s1)
    8000498e:	c551                	beqz	a0,80004a1a <pipealloc+0xb2>
    80004990:	00000097          	auipc	ra,0x0
    80004994:	bc6080e7          	jalr	-1082(ra) # 80004556 <filealloc>
    80004998:	00aa3023          	sd	a0,0(s4)
    8000499c:	c92d                	beqz	a0,80004a0e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	182080e7          	jalr	386(ra) # 80000b20 <kalloc>
    800049a6:	892a                	mv	s2,a0
    800049a8:	c125                	beqz	a0,80004a08 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800049aa:	4985                	li	s3,1
    800049ac:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049b0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049b4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049b8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049bc:	00004597          	auipc	a1,0x4
    800049c0:	cc458593          	addi	a1,a1,-828 # 80008680 <syscalls+0x288>
    800049c4:	ffffc097          	auipc	ra,0xffffc
    800049c8:	1bc080e7          	jalr	444(ra) # 80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    800049cc:	609c                	ld	a5,0(s1)
    800049ce:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049d2:	609c                	ld	a5,0(s1)
    800049d4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049d8:	609c                	ld	a5,0(s1)
    800049da:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049de:	609c                	ld	a5,0(s1)
    800049e0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049e4:	000a3783          	ld	a5,0(s4)
    800049e8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049ec:	000a3783          	ld	a5,0(s4)
    800049f0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049f4:	000a3783          	ld	a5,0(s4)
    800049f8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049fc:	000a3783          	ld	a5,0(s4)
    80004a00:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a04:	4501                	li	a0,0
    80004a06:	a025                	j	80004a2e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a08:	6088                	ld	a0,0(s1)
    80004a0a:	e501                	bnez	a0,80004a12 <pipealloc+0xaa>
    80004a0c:	a039                	j	80004a1a <pipealloc+0xb2>
    80004a0e:	6088                	ld	a0,0(s1)
    80004a10:	c51d                	beqz	a0,80004a3e <pipealloc+0xd6>
    fileclose(*f0);
    80004a12:	00000097          	auipc	ra,0x0
    80004a16:	c00080e7          	jalr	-1024(ra) # 80004612 <fileclose>
  if(*f1)
    80004a1a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a1e:	557d                	li	a0,-1
  if(*f1)
    80004a20:	c799                	beqz	a5,80004a2e <pipealloc+0xc6>
    fileclose(*f1);
    80004a22:	853e                	mv	a0,a5
    80004a24:	00000097          	auipc	ra,0x0
    80004a28:	bee080e7          	jalr	-1042(ra) # 80004612 <fileclose>
  return -1;
    80004a2c:	557d                	li	a0,-1
}
    80004a2e:	70a2                	ld	ra,40(sp)
    80004a30:	7402                	ld	s0,32(sp)
    80004a32:	64e2                	ld	s1,24(sp)
    80004a34:	6942                	ld	s2,16(sp)
    80004a36:	69a2                	ld	s3,8(sp)
    80004a38:	6a02                	ld	s4,0(sp)
    80004a3a:	6145                	addi	sp,sp,48
    80004a3c:	8082                	ret
  return -1;
    80004a3e:	557d                	li	a0,-1
    80004a40:	b7fd                	j	80004a2e <pipealloc+0xc6>

0000000080004a42 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a42:	1101                	addi	sp,sp,-32
    80004a44:	ec06                	sd	ra,24(sp)
    80004a46:	e822                	sd	s0,16(sp)
    80004a48:	e426                	sd	s1,8(sp)
    80004a4a:	e04a                	sd	s2,0(sp)
    80004a4c:	1000                	addi	s0,sp,32
    80004a4e:	84aa                	mv	s1,a0
    80004a50:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	1be080e7          	jalr	446(ra) # 80000c10 <acquire>
  if(writable){
    80004a5a:	02090d63          	beqz	s2,80004a94 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a5e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a62:	21848513          	addi	a0,s1,536
    80004a66:	ffffe097          	auipc	ra,0xffffe
    80004a6a:	a42080e7          	jalr	-1470(ra) # 800024a8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a6e:	2204b783          	ld	a5,544(s1)
    80004a72:	eb95                	bnez	a5,80004aa6 <pipeclose+0x64>
    release(&pi->lock);
    80004a74:	8526                	mv	a0,s1
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	24e080e7          	jalr	590(ra) # 80000cc4 <release>
    kfree((char*)pi);
    80004a7e:	8526                	mv	a0,s1
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	fa4080e7          	jalr	-92(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    80004a88:	60e2                	ld	ra,24(sp)
    80004a8a:	6442                	ld	s0,16(sp)
    80004a8c:	64a2                	ld	s1,8(sp)
    80004a8e:	6902                	ld	s2,0(sp)
    80004a90:	6105                	addi	sp,sp,32
    80004a92:	8082                	ret
    pi->readopen = 0;
    80004a94:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a98:	21c48513          	addi	a0,s1,540
    80004a9c:	ffffe097          	auipc	ra,0xffffe
    80004aa0:	a0c080e7          	jalr	-1524(ra) # 800024a8 <wakeup>
    80004aa4:	b7e9                	j	80004a6e <pipeclose+0x2c>
    release(&pi->lock);
    80004aa6:	8526                	mv	a0,s1
    80004aa8:	ffffc097          	auipc	ra,0xffffc
    80004aac:	21c080e7          	jalr	540(ra) # 80000cc4 <release>
}
    80004ab0:	bfe1                	j	80004a88 <pipeclose+0x46>

0000000080004ab2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ab2:	7119                	addi	sp,sp,-128
    80004ab4:	fc86                	sd	ra,120(sp)
    80004ab6:	f8a2                	sd	s0,112(sp)
    80004ab8:	f4a6                	sd	s1,104(sp)
    80004aba:	f0ca                	sd	s2,96(sp)
    80004abc:	ecce                	sd	s3,88(sp)
    80004abe:	e8d2                	sd	s4,80(sp)
    80004ac0:	e4d6                	sd	s5,72(sp)
    80004ac2:	e0da                	sd	s6,64(sp)
    80004ac4:	fc5e                	sd	s7,56(sp)
    80004ac6:	f862                	sd	s8,48(sp)
    80004ac8:	f466                	sd	s9,40(sp)
    80004aca:	f06a                	sd	s10,32(sp)
    80004acc:	ec6e                	sd	s11,24(sp)
    80004ace:	0100                	addi	s0,sp,128
    80004ad0:	84aa                	mv	s1,a0
    80004ad2:	8cae                	mv	s9,a1
    80004ad4:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004ad6:	ffffd097          	auipc	ra,0xffffd
    80004ada:	03c080e7          	jalr	60(ra) # 80001b12 <myproc>
    80004ade:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	12e080e7          	jalr	302(ra) # 80000c10 <acquire>
  for(i = 0; i < n; i++){
    80004aea:	0d605963          	blez	s6,80004bbc <pipewrite+0x10a>
    80004aee:	89a6                	mv	s3,s1
    80004af0:	3b7d                	addiw	s6,s6,-1
    80004af2:	1b02                	slli	s6,s6,0x20
    80004af4:	020b5b13          	srli	s6,s6,0x20
    80004af8:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004afa:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004afe:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b02:	5dfd                	li	s11,-1
    80004b04:	000b8d1b          	sext.w	s10,s7
    80004b08:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b0a:	2184a783          	lw	a5,536(s1)
    80004b0e:	21c4a703          	lw	a4,540(s1)
    80004b12:	2007879b          	addiw	a5,a5,512
    80004b16:	02f71b63          	bne	a4,a5,80004b4c <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004b1a:	2204a783          	lw	a5,544(s1)
    80004b1e:	cbad                	beqz	a5,80004b90 <pipewrite+0xde>
    80004b20:	03092783          	lw	a5,48(s2)
    80004b24:	e7b5                	bnez	a5,80004b90 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004b26:	8556                	mv	a0,s5
    80004b28:	ffffe097          	auipc	ra,0xffffe
    80004b2c:	980080e7          	jalr	-1664(ra) # 800024a8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b30:	85ce                	mv	a1,s3
    80004b32:	8552                	mv	a0,s4
    80004b34:	ffffd097          	auipc	ra,0xffffd
    80004b38:	7ee080e7          	jalr	2030(ra) # 80002322 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b3c:	2184a783          	lw	a5,536(s1)
    80004b40:	21c4a703          	lw	a4,540(s1)
    80004b44:	2007879b          	addiw	a5,a5,512
    80004b48:	fcf709e3          	beq	a4,a5,80004b1a <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b4c:	4685                	li	a3,1
    80004b4e:	019b8633          	add	a2,s7,s9
    80004b52:	f8f40593          	addi	a1,s0,-113
    80004b56:	05093503          	ld	a0,80(s2)
    80004b5a:	ffffd097          	auipc	ra,0xffffd
    80004b5e:	c5e080e7          	jalr	-930(ra) # 800017b8 <copyin>
    80004b62:	05b50e63          	beq	a0,s11,80004bbe <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b66:	21c4a783          	lw	a5,540(s1)
    80004b6a:	0017871b          	addiw	a4,a5,1
    80004b6e:	20e4ae23          	sw	a4,540(s1)
    80004b72:	1ff7f793          	andi	a5,a5,511
    80004b76:	97a6                	add	a5,a5,s1
    80004b78:	f8f44703          	lbu	a4,-113(s0)
    80004b7c:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b80:	001d0c1b          	addiw	s8,s10,1
    80004b84:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004b88:	036b8b63          	beq	s7,s6,80004bbe <pipewrite+0x10c>
    80004b8c:	8bbe                	mv	s7,a5
    80004b8e:	bf9d                	j	80004b04 <pipewrite+0x52>
        release(&pi->lock);
    80004b90:	8526                	mv	a0,s1
    80004b92:	ffffc097          	auipc	ra,0xffffc
    80004b96:	132080e7          	jalr	306(ra) # 80000cc4 <release>
        return -1;
    80004b9a:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004b9c:	8562                	mv	a0,s8
    80004b9e:	70e6                	ld	ra,120(sp)
    80004ba0:	7446                	ld	s0,112(sp)
    80004ba2:	74a6                	ld	s1,104(sp)
    80004ba4:	7906                	ld	s2,96(sp)
    80004ba6:	69e6                	ld	s3,88(sp)
    80004ba8:	6a46                	ld	s4,80(sp)
    80004baa:	6aa6                	ld	s5,72(sp)
    80004bac:	6b06                	ld	s6,64(sp)
    80004bae:	7be2                	ld	s7,56(sp)
    80004bb0:	7c42                	ld	s8,48(sp)
    80004bb2:	7ca2                	ld	s9,40(sp)
    80004bb4:	7d02                	ld	s10,32(sp)
    80004bb6:	6de2                	ld	s11,24(sp)
    80004bb8:	6109                	addi	sp,sp,128
    80004bba:	8082                	ret
  for(i = 0; i < n; i++){
    80004bbc:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004bbe:	21848513          	addi	a0,s1,536
    80004bc2:	ffffe097          	auipc	ra,0xffffe
    80004bc6:	8e6080e7          	jalr	-1818(ra) # 800024a8 <wakeup>
  release(&pi->lock);
    80004bca:	8526                	mv	a0,s1
    80004bcc:	ffffc097          	auipc	ra,0xffffc
    80004bd0:	0f8080e7          	jalr	248(ra) # 80000cc4 <release>
  return i;
    80004bd4:	b7e1                	j	80004b9c <pipewrite+0xea>

0000000080004bd6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004bd6:	715d                	addi	sp,sp,-80
    80004bd8:	e486                	sd	ra,72(sp)
    80004bda:	e0a2                	sd	s0,64(sp)
    80004bdc:	fc26                	sd	s1,56(sp)
    80004bde:	f84a                	sd	s2,48(sp)
    80004be0:	f44e                	sd	s3,40(sp)
    80004be2:	f052                	sd	s4,32(sp)
    80004be4:	ec56                	sd	s5,24(sp)
    80004be6:	e85a                	sd	s6,16(sp)
    80004be8:	0880                	addi	s0,sp,80
    80004bea:	84aa                	mv	s1,a0
    80004bec:	892e                	mv	s2,a1
    80004bee:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004bf0:	ffffd097          	auipc	ra,0xffffd
    80004bf4:	f22080e7          	jalr	-222(ra) # 80001b12 <myproc>
    80004bf8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bfa:	8b26                	mv	s6,s1
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	012080e7          	jalr	18(ra) # 80000c10 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c06:	2184a703          	lw	a4,536(s1)
    80004c0a:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c0e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c12:	02f71463          	bne	a4,a5,80004c3a <piperead+0x64>
    80004c16:	2244a783          	lw	a5,548(s1)
    80004c1a:	c385                	beqz	a5,80004c3a <piperead+0x64>
    if(pr->killed){
    80004c1c:	030a2783          	lw	a5,48(s4)
    80004c20:	ebc1                	bnez	a5,80004cb0 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c22:	85da                	mv	a1,s6
    80004c24:	854e                	mv	a0,s3
    80004c26:	ffffd097          	auipc	ra,0xffffd
    80004c2a:	6fc080e7          	jalr	1788(ra) # 80002322 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c2e:	2184a703          	lw	a4,536(s1)
    80004c32:	21c4a783          	lw	a5,540(s1)
    80004c36:	fef700e3          	beq	a4,a5,80004c16 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c3a:	09505263          	blez	s5,80004cbe <piperead+0xe8>
    80004c3e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c40:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004c42:	2184a783          	lw	a5,536(s1)
    80004c46:	21c4a703          	lw	a4,540(s1)
    80004c4a:	02f70d63          	beq	a4,a5,80004c84 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c4e:	0017871b          	addiw	a4,a5,1
    80004c52:	20e4ac23          	sw	a4,536(s1)
    80004c56:	1ff7f793          	andi	a5,a5,511
    80004c5a:	97a6                	add	a5,a5,s1
    80004c5c:	0187c783          	lbu	a5,24(a5)
    80004c60:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c64:	4685                	li	a3,1
    80004c66:	fbf40613          	addi	a2,s0,-65
    80004c6a:	85ca                	mv	a1,s2
    80004c6c:	050a3503          	ld	a0,80(s4)
    80004c70:	ffffd097          	auipc	ra,0xffffd
    80004c74:	abc080e7          	jalr	-1348(ra) # 8000172c <copyout>
    80004c78:	01650663          	beq	a0,s6,80004c84 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c7c:	2985                	addiw	s3,s3,1
    80004c7e:	0905                	addi	s2,s2,1
    80004c80:	fd3a91e3          	bne	s5,s3,80004c42 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c84:	21c48513          	addi	a0,s1,540
    80004c88:	ffffe097          	auipc	ra,0xffffe
    80004c8c:	820080e7          	jalr	-2016(ra) # 800024a8 <wakeup>
  release(&pi->lock);
    80004c90:	8526                	mv	a0,s1
    80004c92:	ffffc097          	auipc	ra,0xffffc
    80004c96:	032080e7          	jalr	50(ra) # 80000cc4 <release>
  return i;
}
    80004c9a:	854e                	mv	a0,s3
    80004c9c:	60a6                	ld	ra,72(sp)
    80004c9e:	6406                	ld	s0,64(sp)
    80004ca0:	74e2                	ld	s1,56(sp)
    80004ca2:	7942                	ld	s2,48(sp)
    80004ca4:	79a2                	ld	s3,40(sp)
    80004ca6:	7a02                	ld	s4,32(sp)
    80004ca8:	6ae2                	ld	s5,24(sp)
    80004caa:	6b42                	ld	s6,16(sp)
    80004cac:	6161                	addi	sp,sp,80
    80004cae:	8082                	ret
      release(&pi->lock);
    80004cb0:	8526                	mv	a0,s1
    80004cb2:	ffffc097          	auipc	ra,0xffffc
    80004cb6:	012080e7          	jalr	18(ra) # 80000cc4 <release>
      return -1;
    80004cba:	59fd                	li	s3,-1
    80004cbc:	bff9                	j	80004c9a <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cbe:	4981                	li	s3,0
    80004cc0:	b7d1                	j	80004c84 <piperead+0xae>

0000000080004cc2 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004cc2:	df010113          	addi	sp,sp,-528
    80004cc6:	20113423          	sd	ra,520(sp)
    80004cca:	20813023          	sd	s0,512(sp)
    80004cce:	ffa6                	sd	s1,504(sp)
    80004cd0:	fbca                	sd	s2,496(sp)
    80004cd2:	f7ce                	sd	s3,488(sp)
    80004cd4:	f3d2                	sd	s4,480(sp)
    80004cd6:	efd6                	sd	s5,472(sp)
    80004cd8:	ebda                	sd	s6,464(sp)
    80004cda:	e7de                	sd	s7,456(sp)
    80004cdc:	e3e2                	sd	s8,448(sp)
    80004cde:	ff66                	sd	s9,440(sp)
    80004ce0:	fb6a                	sd	s10,432(sp)
    80004ce2:	f76e                	sd	s11,424(sp)
    80004ce4:	0c00                	addi	s0,sp,528
    80004ce6:	84aa                	mv	s1,a0
    80004ce8:	dea43c23          	sd	a0,-520(s0)
    80004cec:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004cf0:	ffffd097          	auipc	ra,0xffffd
    80004cf4:	e22080e7          	jalr	-478(ra) # 80001b12 <myproc>
    80004cf8:	892a                	mv	s2,a0

  begin_op();
    80004cfa:	fffff097          	auipc	ra,0xfffff
    80004cfe:	446080e7          	jalr	1094(ra) # 80004140 <begin_op>

  if((ip = namei(path)) == 0){
    80004d02:	8526                	mv	a0,s1
    80004d04:	fffff097          	auipc	ra,0xfffff
    80004d08:	230080e7          	jalr	560(ra) # 80003f34 <namei>
    80004d0c:	c92d                	beqz	a0,80004d7e <exec+0xbc>
    80004d0e:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d10:	fffff097          	auipc	ra,0xfffff
    80004d14:	a70080e7          	jalr	-1424(ra) # 80003780 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d18:	04000713          	li	a4,64
    80004d1c:	4681                	li	a3,0
    80004d1e:	e4840613          	addi	a2,s0,-440
    80004d22:	4581                	li	a1,0
    80004d24:	8526                	mv	a0,s1
    80004d26:	fffff097          	auipc	ra,0xfffff
    80004d2a:	d0e080e7          	jalr	-754(ra) # 80003a34 <readi>
    80004d2e:	04000793          	li	a5,64
    80004d32:	00f51a63          	bne	a0,a5,80004d46 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d36:	e4842703          	lw	a4,-440(s0)
    80004d3a:	464c47b7          	lui	a5,0x464c4
    80004d3e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d42:	04f70463          	beq	a4,a5,80004d8a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d46:	8526                	mv	a0,s1
    80004d48:	fffff097          	auipc	ra,0xfffff
    80004d4c:	c9a080e7          	jalr	-870(ra) # 800039e2 <iunlockput>
    end_op();
    80004d50:	fffff097          	auipc	ra,0xfffff
    80004d54:	470080e7          	jalr	1136(ra) # 800041c0 <end_op>
  }
  return -1;
    80004d58:	557d                	li	a0,-1
}
    80004d5a:	20813083          	ld	ra,520(sp)
    80004d5e:	20013403          	ld	s0,512(sp)
    80004d62:	74fe                	ld	s1,504(sp)
    80004d64:	795e                	ld	s2,496(sp)
    80004d66:	79be                	ld	s3,488(sp)
    80004d68:	7a1e                	ld	s4,480(sp)
    80004d6a:	6afe                	ld	s5,472(sp)
    80004d6c:	6b5e                	ld	s6,464(sp)
    80004d6e:	6bbe                	ld	s7,456(sp)
    80004d70:	6c1e                	ld	s8,448(sp)
    80004d72:	7cfa                	ld	s9,440(sp)
    80004d74:	7d5a                	ld	s10,432(sp)
    80004d76:	7dba                	ld	s11,424(sp)
    80004d78:	21010113          	addi	sp,sp,528
    80004d7c:	8082                	ret
    end_op();
    80004d7e:	fffff097          	auipc	ra,0xfffff
    80004d82:	442080e7          	jalr	1090(ra) # 800041c0 <end_op>
    return -1;
    80004d86:	557d                	li	a0,-1
    80004d88:	bfc9                	j	80004d5a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d8a:	854a                	mv	a0,s2
    80004d8c:	ffffd097          	auipc	ra,0xffffd
    80004d90:	e4a080e7          	jalr	-438(ra) # 80001bd6 <proc_pagetable>
    80004d94:	8baa                	mv	s7,a0
    80004d96:	d945                	beqz	a0,80004d46 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d98:	e6842983          	lw	s3,-408(s0)
    80004d9c:	e8045783          	lhu	a5,-384(s0)
    80004da0:	c7ad                	beqz	a5,80004e0a <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004da2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004da4:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004da6:	6c85                	lui	s9,0x1
    80004da8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004dac:	def43823          	sd	a5,-528(s0)
    80004db0:	a42d                	j	80004fda <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004db2:	00004517          	auipc	a0,0x4
    80004db6:	8d650513          	addi	a0,a0,-1834 # 80008688 <syscalls+0x290>
    80004dba:	ffffb097          	auipc	ra,0xffffb
    80004dbe:	78e080e7          	jalr	1934(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004dc2:	8756                	mv	a4,s5
    80004dc4:	012d86bb          	addw	a3,s11,s2
    80004dc8:	4581                	li	a1,0
    80004dca:	8526                	mv	a0,s1
    80004dcc:	fffff097          	auipc	ra,0xfffff
    80004dd0:	c68080e7          	jalr	-920(ra) # 80003a34 <readi>
    80004dd4:	2501                	sext.w	a0,a0
    80004dd6:	1aaa9963          	bne	s5,a0,80004f88 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004dda:	6785                	lui	a5,0x1
    80004ddc:	0127893b          	addw	s2,a5,s2
    80004de0:	77fd                	lui	a5,0xfffff
    80004de2:	01478a3b          	addw	s4,a5,s4
    80004de6:	1f897163          	bgeu	s2,s8,80004fc8 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004dea:	02091593          	slli	a1,s2,0x20
    80004dee:	9181                	srli	a1,a1,0x20
    80004df0:	95ea                	add	a1,a1,s10
    80004df2:	855e                	mv	a0,s7
    80004df4:	ffffd097          	auipc	ra,0xffffd
    80004df8:	8d2080e7          	jalr	-1838(ra) # 800016c6 <walkaddr>
    80004dfc:	862a                	mv	a2,a0
    if(pa == 0)
    80004dfe:	d955                	beqz	a0,80004db2 <exec+0xf0>
      n = PGSIZE;
    80004e00:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004e02:	fd9a70e3          	bgeu	s4,s9,80004dc2 <exec+0x100>
      n = sz - i;
    80004e06:	8ad2                	mv	s5,s4
    80004e08:	bf6d                	j	80004dc2 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004e0a:	4901                	li	s2,0
  iunlockput(ip);
    80004e0c:	8526                	mv	a0,s1
    80004e0e:	fffff097          	auipc	ra,0xfffff
    80004e12:	bd4080e7          	jalr	-1068(ra) # 800039e2 <iunlockput>
  end_op();
    80004e16:	fffff097          	auipc	ra,0xfffff
    80004e1a:	3aa080e7          	jalr	938(ra) # 800041c0 <end_op>
  p = myproc();
    80004e1e:	ffffd097          	auipc	ra,0xffffd
    80004e22:	cf4080e7          	jalr	-780(ra) # 80001b12 <myproc>
    80004e26:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e28:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e2c:	6785                	lui	a5,0x1
    80004e2e:	17fd                	addi	a5,a5,-1
    80004e30:	993e                	add	s2,s2,a5
    80004e32:	757d                	lui	a0,0xfffff
    80004e34:	00a977b3          	and	a5,s2,a0
    80004e38:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e3c:	6609                	lui	a2,0x2
    80004e3e:	963e                	add	a2,a2,a5
    80004e40:	85be                	mv	a1,a5
    80004e42:	855e                	mv	a0,s7
    80004e44:	ffffc097          	auipc	ra,0xffffc
    80004e48:	5de080e7          	jalr	1502(ra) # 80001422 <uvmalloc>
    80004e4c:	8b2a                	mv	s6,a0
  ip = 0;
    80004e4e:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e50:	12050c63          	beqz	a0,80004f88 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e54:	75f9                	lui	a1,0xffffe
    80004e56:	95aa                	add	a1,a1,a0
    80004e58:	855e                	mv	a0,s7
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	7b8080e7          	jalr	1976(ra) # 80001612 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e62:	7c7d                	lui	s8,0xfffff
    80004e64:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e66:	e0043783          	ld	a5,-512(s0)
    80004e6a:	6388                	ld	a0,0(a5)
    80004e6c:	c535                	beqz	a0,80004ed8 <exec+0x216>
    80004e6e:	e8840993          	addi	s3,s0,-376
    80004e72:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004e76:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004e78:	ffffc097          	auipc	ra,0xffffc
    80004e7c:	01c080e7          	jalr	28(ra) # 80000e94 <strlen>
    80004e80:	2505                	addiw	a0,a0,1
    80004e82:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e86:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e8a:	13896363          	bltu	s2,s8,80004fb0 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e8e:	e0043d83          	ld	s11,-512(s0)
    80004e92:	000dba03          	ld	s4,0(s11)
    80004e96:	8552                	mv	a0,s4
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	ffc080e7          	jalr	-4(ra) # 80000e94 <strlen>
    80004ea0:	0015069b          	addiw	a3,a0,1
    80004ea4:	8652                	mv	a2,s4
    80004ea6:	85ca                	mv	a1,s2
    80004ea8:	855e                	mv	a0,s7
    80004eaa:	ffffd097          	auipc	ra,0xffffd
    80004eae:	882080e7          	jalr	-1918(ra) # 8000172c <copyout>
    80004eb2:	10054363          	bltz	a0,80004fb8 <exec+0x2f6>
    ustack[argc] = sp;
    80004eb6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004eba:	0485                	addi	s1,s1,1
    80004ebc:	008d8793          	addi	a5,s11,8
    80004ec0:	e0f43023          	sd	a5,-512(s0)
    80004ec4:	008db503          	ld	a0,8(s11)
    80004ec8:	c911                	beqz	a0,80004edc <exec+0x21a>
    if(argc >= MAXARG)
    80004eca:	09a1                	addi	s3,s3,8
    80004ecc:	fb3c96e3          	bne	s9,s3,80004e78 <exec+0x1b6>
  sz = sz1;
    80004ed0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ed4:	4481                	li	s1,0
    80004ed6:	a84d                	j	80004f88 <exec+0x2c6>
  sp = sz;
    80004ed8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004eda:	4481                	li	s1,0
  ustack[argc] = 0;
    80004edc:	00349793          	slli	a5,s1,0x3
    80004ee0:	f9040713          	addi	a4,s0,-112
    80004ee4:	97ba                	add	a5,a5,a4
    80004ee6:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004eea:	00148693          	addi	a3,s1,1
    80004eee:	068e                	slli	a3,a3,0x3
    80004ef0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ef4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004ef8:	01897663          	bgeu	s2,s8,80004f04 <exec+0x242>
  sz = sz1;
    80004efc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f00:	4481                	li	s1,0
    80004f02:	a059                	j	80004f88 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f04:	e8840613          	addi	a2,s0,-376
    80004f08:	85ca                	mv	a1,s2
    80004f0a:	855e                	mv	a0,s7
    80004f0c:	ffffd097          	auipc	ra,0xffffd
    80004f10:	820080e7          	jalr	-2016(ra) # 8000172c <copyout>
    80004f14:	0a054663          	bltz	a0,80004fc0 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004f18:	058ab783          	ld	a5,88(s5)
    80004f1c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f20:	df843783          	ld	a5,-520(s0)
    80004f24:	0007c703          	lbu	a4,0(a5)
    80004f28:	cf11                	beqz	a4,80004f44 <exec+0x282>
    80004f2a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f2c:	02f00693          	li	a3,47
    80004f30:	a029                	j	80004f3a <exec+0x278>
  for(last=s=path; *s; s++)
    80004f32:	0785                	addi	a5,a5,1
    80004f34:	fff7c703          	lbu	a4,-1(a5)
    80004f38:	c711                	beqz	a4,80004f44 <exec+0x282>
    if(*s == '/')
    80004f3a:	fed71ce3          	bne	a4,a3,80004f32 <exec+0x270>
      last = s+1;
    80004f3e:	def43c23          	sd	a5,-520(s0)
    80004f42:	bfc5                	j	80004f32 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f44:	4641                	li	a2,16
    80004f46:	df843583          	ld	a1,-520(s0)
    80004f4a:	158a8513          	addi	a0,s5,344
    80004f4e:	ffffc097          	auipc	ra,0xffffc
    80004f52:	f14080e7          	jalr	-236(ra) # 80000e62 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f56:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f5a:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004f5e:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f62:	058ab783          	ld	a5,88(s5)
    80004f66:	e6043703          	ld	a4,-416(s0)
    80004f6a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f6c:	058ab783          	ld	a5,88(s5)
    80004f70:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f74:	85ea                	mv	a1,s10
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	cfc080e7          	jalr	-772(ra) # 80001c72 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f7e:	0004851b          	sext.w	a0,s1
    80004f82:	bbe1                	j	80004d5a <exec+0x98>
    80004f84:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004f88:	e0843583          	ld	a1,-504(s0)
    80004f8c:	855e                	mv	a0,s7
    80004f8e:	ffffd097          	auipc	ra,0xffffd
    80004f92:	ce4080e7          	jalr	-796(ra) # 80001c72 <proc_freepagetable>
  if(ip){
    80004f96:	da0498e3          	bnez	s1,80004d46 <exec+0x84>
  return -1;
    80004f9a:	557d                	li	a0,-1
    80004f9c:	bb7d                	j	80004d5a <exec+0x98>
    80004f9e:	e1243423          	sd	s2,-504(s0)
    80004fa2:	b7dd                	j	80004f88 <exec+0x2c6>
    80004fa4:	e1243423          	sd	s2,-504(s0)
    80004fa8:	b7c5                	j	80004f88 <exec+0x2c6>
    80004faa:	e1243423          	sd	s2,-504(s0)
    80004fae:	bfe9                	j	80004f88 <exec+0x2c6>
  sz = sz1;
    80004fb0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fb4:	4481                	li	s1,0
    80004fb6:	bfc9                	j	80004f88 <exec+0x2c6>
  sz = sz1;
    80004fb8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fbc:	4481                	li	s1,0
    80004fbe:	b7e9                	j	80004f88 <exec+0x2c6>
  sz = sz1;
    80004fc0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fc4:	4481                	li	s1,0
    80004fc6:	b7c9                	j	80004f88 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fc8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fcc:	2b05                	addiw	s6,s6,1
    80004fce:	0389899b          	addiw	s3,s3,56
    80004fd2:	e8045783          	lhu	a5,-384(s0)
    80004fd6:	e2fb5be3          	bge	s6,a5,80004e0c <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fda:	2981                	sext.w	s3,s3
    80004fdc:	03800713          	li	a4,56
    80004fe0:	86ce                	mv	a3,s3
    80004fe2:	e1040613          	addi	a2,s0,-496
    80004fe6:	4581                	li	a1,0
    80004fe8:	8526                	mv	a0,s1
    80004fea:	fffff097          	auipc	ra,0xfffff
    80004fee:	a4a080e7          	jalr	-1462(ra) # 80003a34 <readi>
    80004ff2:	03800793          	li	a5,56
    80004ff6:	f8f517e3          	bne	a0,a5,80004f84 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004ffa:	e1042783          	lw	a5,-496(s0)
    80004ffe:	4705                	li	a4,1
    80005000:	fce796e3          	bne	a5,a4,80004fcc <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005004:	e3843603          	ld	a2,-456(s0)
    80005008:	e3043783          	ld	a5,-464(s0)
    8000500c:	f8f669e3          	bltu	a2,a5,80004f9e <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005010:	e2043783          	ld	a5,-480(s0)
    80005014:	963e                	add	a2,a2,a5
    80005016:	f8f667e3          	bltu	a2,a5,80004fa4 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000501a:	85ca                	mv	a1,s2
    8000501c:	855e                	mv	a0,s7
    8000501e:	ffffc097          	auipc	ra,0xffffc
    80005022:	404080e7          	jalr	1028(ra) # 80001422 <uvmalloc>
    80005026:	e0a43423          	sd	a0,-504(s0)
    8000502a:	d141                	beqz	a0,80004faa <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    8000502c:	e2043d03          	ld	s10,-480(s0)
    80005030:	df043783          	ld	a5,-528(s0)
    80005034:	00fd77b3          	and	a5,s10,a5
    80005038:	fba1                	bnez	a5,80004f88 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000503a:	e1842d83          	lw	s11,-488(s0)
    8000503e:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005042:	f80c03e3          	beqz	s8,80004fc8 <exec+0x306>
    80005046:	8a62                	mv	s4,s8
    80005048:	4901                	li	s2,0
    8000504a:	b345                	j	80004dea <exec+0x128>

000000008000504c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000504c:	7179                	addi	sp,sp,-48
    8000504e:	f406                	sd	ra,40(sp)
    80005050:	f022                	sd	s0,32(sp)
    80005052:	ec26                	sd	s1,24(sp)
    80005054:	e84a                	sd	s2,16(sp)
    80005056:	1800                	addi	s0,sp,48
    80005058:	892e                	mv	s2,a1
    8000505a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000505c:	fdc40593          	addi	a1,s0,-36
    80005060:	ffffe097          	auipc	ra,0xffffe
    80005064:	b9a080e7          	jalr	-1126(ra) # 80002bfa <argint>
    80005068:	04054063          	bltz	a0,800050a8 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000506c:	fdc42703          	lw	a4,-36(s0)
    80005070:	47bd                	li	a5,15
    80005072:	02e7ed63          	bltu	a5,a4,800050ac <argfd+0x60>
    80005076:	ffffd097          	auipc	ra,0xffffd
    8000507a:	a9c080e7          	jalr	-1380(ra) # 80001b12 <myproc>
    8000507e:	fdc42703          	lw	a4,-36(s0)
    80005082:	01a70793          	addi	a5,a4,26
    80005086:	078e                	slli	a5,a5,0x3
    80005088:	953e                	add	a0,a0,a5
    8000508a:	611c                	ld	a5,0(a0)
    8000508c:	c395                	beqz	a5,800050b0 <argfd+0x64>
    return -1;
  if(pfd)
    8000508e:	00090463          	beqz	s2,80005096 <argfd+0x4a>
    *pfd = fd;
    80005092:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005096:	4501                	li	a0,0
  if(pf)
    80005098:	c091                	beqz	s1,8000509c <argfd+0x50>
    *pf = f;
    8000509a:	e09c                	sd	a5,0(s1)
}
    8000509c:	70a2                	ld	ra,40(sp)
    8000509e:	7402                	ld	s0,32(sp)
    800050a0:	64e2                	ld	s1,24(sp)
    800050a2:	6942                	ld	s2,16(sp)
    800050a4:	6145                	addi	sp,sp,48
    800050a6:	8082                	ret
    return -1;
    800050a8:	557d                	li	a0,-1
    800050aa:	bfcd                	j	8000509c <argfd+0x50>
    return -1;
    800050ac:	557d                	li	a0,-1
    800050ae:	b7fd                	j	8000509c <argfd+0x50>
    800050b0:	557d                	li	a0,-1
    800050b2:	b7ed                	j	8000509c <argfd+0x50>

00000000800050b4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050b4:	1101                	addi	sp,sp,-32
    800050b6:	ec06                	sd	ra,24(sp)
    800050b8:	e822                	sd	s0,16(sp)
    800050ba:	e426                	sd	s1,8(sp)
    800050bc:	1000                	addi	s0,sp,32
    800050be:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050c0:	ffffd097          	auipc	ra,0xffffd
    800050c4:	a52080e7          	jalr	-1454(ra) # 80001b12 <myproc>
    800050c8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050ca:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    800050ce:	4501                	li	a0,0
    800050d0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050d2:	6398                	ld	a4,0(a5)
    800050d4:	cb19                	beqz	a4,800050ea <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050d6:	2505                	addiw	a0,a0,1
    800050d8:	07a1                	addi	a5,a5,8
    800050da:	fed51ce3          	bne	a0,a3,800050d2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050de:	557d                	li	a0,-1
}
    800050e0:	60e2                	ld	ra,24(sp)
    800050e2:	6442                	ld	s0,16(sp)
    800050e4:	64a2                	ld	s1,8(sp)
    800050e6:	6105                	addi	sp,sp,32
    800050e8:	8082                	ret
      p->ofile[fd] = f;
    800050ea:	01a50793          	addi	a5,a0,26
    800050ee:	078e                	slli	a5,a5,0x3
    800050f0:	963e                	add	a2,a2,a5
    800050f2:	e204                	sd	s1,0(a2)
      return fd;
    800050f4:	b7f5                	j	800050e0 <fdalloc+0x2c>

00000000800050f6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050f6:	715d                	addi	sp,sp,-80
    800050f8:	e486                	sd	ra,72(sp)
    800050fa:	e0a2                	sd	s0,64(sp)
    800050fc:	fc26                	sd	s1,56(sp)
    800050fe:	f84a                	sd	s2,48(sp)
    80005100:	f44e                	sd	s3,40(sp)
    80005102:	f052                	sd	s4,32(sp)
    80005104:	ec56                	sd	s5,24(sp)
    80005106:	0880                	addi	s0,sp,80
    80005108:	89ae                	mv	s3,a1
    8000510a:	8ab2                	mv	s5,a2
    8000510c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000510e:	fb040593          	addi	a1,s0,-80
    80005112:	fffff097          	auipc	ra,0xfffff
    80005116:	e40080e7          	jalr	-448(ra) # 80003f52 <nameiparent>
    8000511a:	892a                	mv	s2,a0
    8000511c:	12050f63          	beqz	a0,8000525a <create+0x164>
    return 0;

  ilock(dp);
    80005120:	ffffe097          	auipc	ra,0xffffe
    80005124:	660080e7          	jalr	1632(ra) # 80003780 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005128:	4601                	li	a2,0
    8000512a:	fb040593          	addi	a1,s0,-80
    8000512e:	854a                	mv	a0,s2
    80005130:	fffff097          	auipc	ra,0xfffff
    80005134:	b32080e7          	jalr	-1230(ra) # 80003c62 <dirlookup>
    80005138:	84aa                	mv	s1,a0
    8000513a:	c921                	beqz	a0,8000518a <create+0x94>
    iunlockput(dp);
    8000513c:	854a                	mv	a0,s2
    8000513e:	fffff097          	auipc	ra,0xfffff
    80005142:	8a4080e7          	jalr	-1884(ra) # 800039e2 <iunlockput>
    ilock(ip);
    80005146:	8526                	mv	a0,s1
    80005148:	ffffe097          	auipc	ra,0xffffe
    8000514c:	638080e7          	jalr	1592(ra) # 80003780 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005150:	2981                	sext.w	s3,s3
    80005152:	4789                	li	a5,2
    80005154:	02f99463          	bne	s3,a5,8000517c <create+0x86>
    80005158:	0444d783          	lhu	a5,68(s1)
    8000515c:	37f9                	addiw	a5,a5,-2
    8000515e:	17c2                	slli	a5,a5,0x30
    80005160:	93c1                	srli	a5,a5,0x30
    80005162:	4705                	li	a4,1
    80005164:	00f76c63          	bltu	a4,a5,8000517c <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005168:	8526                	mv	a0,s1
    8000516a:	60a6                	ld	ra,72(sp)
    8000516c:	6406                	ld	s0,64(sp)
    8000516e:	74e2                	ld	s1,56(sp)
    80005170:	7942                	ld	s2,48(sp)
    80005172:	79a2                	ld	s3,40(sp)
    80005174:	7a02                	ld	s4,32(sp)
    80005176:	6ae2                	ld	s5,24(sp)
    80005178:	6161                	addi	sp,sp,80
    8000517a:	8082                	ret
    iunlockput(ip);
    8000517c:	8526                	mv	a0,s1
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	864080e7          	jalr	-1948(ra) # 800039e2 <iunlockput>
    return 0;
    80005186:	4481                	li	s1,0
    80005188:	b7c5                	j	80005168 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000518a:	85ce                	mv	a1,s3
    8000518c:	00092503          	lw	a0,0(s2)
    80005190:	ffffe097          	auipc	ra,0xffffe
    80005194:	458080e7          	jalr	1112(ra) # 800035e8 <ialloc>
    80005198:	84aa                	mv	s1,a0
    8000519a:	c529                	beqz	a0,800051e4 <create+0xee>
  ilock(ip);
    8000519c:	ffffe097          	auipc	ra,0xffffe
    800051a0:	5e4080e7          	jalr	1508(ra) # 80003780 <ilock>
  ip->major = major;
    800051a4:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800051a8:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800051ac:	4785                	li	a5,1
    800051ae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051b2:	8526                	mv	a0,s1
    800051b4:	ffffe097          	auipc	ra,0xffffe
    800051b8:	502080e7          	jalr	1282(ra) # 800036b6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051bc:	2981                	sext.w	s3,s3
    800051be:	4785                	li	a5,1
    800051c0:	02f98a63          	beq	s3,a5,800051f4 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800051c4:	40d0                	lw	a2,4(s1)
    800051c6:	fb040593          	addi	a1,s0,-80
    800051ca:	854a                	mv	a0,s2
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	ca6080e7          	jalr	-858(ra) # 80003e72 <dirlink>
    800051d4:	06054b63          	bltz	a0,8000524a <create+0x154>
  iunlockput(dp);
    800051d8:	854a                	mv	a0,s2
    800051da:	fffff097          	auipc	ra,0xfffff
    800051de:	808080e7          	jalr	-2040(ra) # 800039e2 <iunlockput>
  return ip;
    800051e2:	b759                	j	80005168 <create+0x72>
    panic("create: ialloc");
    800051e4:	00003517          	auipc	a0,0x3
    800051e8:	4c450513          	addi	a0,a0,1220 # 800086a8 <syscalls+0x2b0>
    800051ec:	ffffb097          	auipc	ra,0xffffb
    800051f0:	35c080e7          	jalr	860(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    800051f4:	04a95783          	lhu	a5,74(s2)
    800051f8:	2785                	addiw	a5,a5,1
    800051fa:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800051fe:	854a                	mv	a0,s2
    80005200:	ffffe097          	auipc	ra,0xffffe
    80005204:	4b6080e7          	jalr	1206(ra) # 800036b6 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005208:	40d0                	lw	a2,4(s1)
    8000520a:	00003597          	auipc	a1,0x3
    8000520e:	4ae58593          	addi	a1,a1,1198 # 800086b8 <syscalls+0x2c0>
    80005212:	8526                	mv	a0,s1
    80005214:	fffff097          	auipc	ra,0xfffff
    80005218:	c5e080e7          	jalr	-930(ra) # 80003e72 <dirlink>
    8000521c:	00054f63          	bltz	a0,8000523a <create+0x144>
    80005220:	00492603          	lw	a2,4(s2)
    80005224:	00003597          	auipc	a1,0x3
    80005228:	f2c58593          	addi	a1,a1,-212 # 80008150 <digits+0x110>
    8000522c:	8526                	mv	a0,s1
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	c44080e7          	jalr	-956(ra) # 80003e72 <dirlink>
    80005236:	f80557e3          	bgez	a0,800051c4 <create+0xce>
      panic("create dots");
    8000523a:	00003517          	auipc	a0,0x3
    8000523e:	48650513          	addi	a0,a0,1158 # 800086c0 <syscalls+0x2c8>
    80005242:	ffffb097          	auipc	ra,0xffffb
    80005246:	306080e7          	jalr	774(ra) # 80000548 <panic>
    panic("create: dirlink");
    8000524a:	00003517          	auipc	a0,0x3
    8000524e:	48650513          	addi	a0,a0,1158 # 800086d0 <syscalls+0x2d8>
    80005252:	ffffb097          	auipc	ra,0xffffb
    80005256:	2f6080e7          	jalr	758(ra) # 80000548 <panic>
    return 0;
    8000525a:	84aa                	mv	s1,a0
    8000525c:	b731                	j	80005168 <create+0x72>

000000008000525e <sys_dup>:
{
    8000525e:	7179                	addi	sp,sp,-48
    80005260:	f406                	sd	ra,40(sp)
    80005262:	f022                	sd	s0,32(sp)
    80005264:	ec26                	sd	s1,24(sp)
    80005266:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005268:	fd840613          	addi	a2,s0,-40
    8000526c:	4581                	li	a1,0
    8000526e:	4501                	li	a0,0
    80005270:	00000097          	auipc	ra,0x0
    80005274:	ddc080e7          	jalr	-548(ra) # 8000504c <argfd>
    return -1;
    80005278:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000527a:	02054363          	bltz	a0,800052a0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000527e:	fd843503          	ld	a0,-40(s0)
    80005282:	00000097          	auipc	ra,0x0
    80005286:	e32080e7          	jalr	-462(ra) # 800050b4 <fdalloc>
    8000528a:	84aa                	mv	s1,a0
    return -1;
    8000528c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000528e:	00054963          	bltz	a0,800052a0 <sys_dup+0x42>
  filedup(f);
    80005292:	fd843503          	ld	a0,-40(s0)
    80005296:	fffff097          	auipc	ra,0xfffff
    8000529a:	32a080e7          	jalr	810(ra) # 800045c0 <filedup>
  return fd;
    8000529e:	87a6                	mv	a5,s1
}
    800052a0:	853e                	mv	a0,a5
    800052a2:	70a2                	ld	ra,40(sp)
    800052a4:	7402                	ld	s0,32(sp)
    800052a6:	64e2                	ld	s1,24(sp)
    800052a8:	6145                	addi	sp,sp,48
    800052aa:	8082                	ret

00000000800052ac <sys_read>:
{
    800052ac:	7179                	addi	sp,sp,-48
    800052ae:	f406                	sd	ra,40(sp)
    800052b0:	f022                	sd	s0,32(sp)
    800052b2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052b4:	fe840613          	addi	a2,s0,-24
    800052b8:	4581                	li	a1,0
    800052ba:	4501                	li	a0,0
    800052bc:	00000097          	auipc	ra,0x0
    800052c0:	d90080e7          	jalr	-624(ra) # 8000504c <argfd>
    return -1;
    800052c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052c6:	04054163          	bltz	a0,80005308 <sys_read+0x5c>
    800052ca:	fe440593          	addi	a1,s0,-28
    800052ce:	4509                	li	a0,2
    800052d0:	ffffe097          	auipc	ra,0xffffe
    800052d4:	92a080e7          	jalr	-1750(ra) # 80002bfa <argint>
    return -1;
    800052d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052da:	02054763          	bltz	a0,80005308 <sys_read+0x5c>
    800052de:	fd840593          	addi	a1,s0,-40
    800052e2:	4505                	li	a0,1
    800052e4:	ffffe097          	auipc	ra,0xffffe
    800052e8:	938080e7          	jalr	-1736(ra) # 80002c1c <argaddr>
    return -1;
    800052ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052ee:	00054d63          	bltz	a0,80005308 <sys_read+0x5c>
  return fileread(f, p, n);
    800052f2:	fe442603          	lw	a2,-28(s0)
    800052f6:	fd843583          	ld	a1,-40(s0)
    800052fa:	fe843503          	ld	a0,-24(s0)
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	44e080e7          	jalr	1102(ra) # 8000474c <fileread>
    80005306:	87aa                	mv	a5,a0
}
    80005308:	853e                	mv	a0,a5
    8000530a:	70a2                	ld	ra,40(sp)
    8000530c:	7402                	ld	s0,32(sp)
    8000530e:	6145                	addi	sp,sp,48
    80005310:	8082                	ret

0000000080005312 <sys_write>:
{
    80005312:	7179                	addi	sp,sp,-48
    80005314:	f406                	sd	ra,40(sp)
    80005316:	f022                	sd	s0,32(sp)
    80005318:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000531a:	fe840613          	addi	a2,s0,-24
    8000531e:	4581                	li	a1,0
    80005320:	4501                	li	a0,0
    80005322:	00000097          	auipc	ra,0x0
    80005326:	d2a080e7          	jalr	-726(ra) # 8000504c <argfd>
    return -1;
    8000532a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000532c:	04054163          	bltz	a0,8000536e <sys_write+0x5c>
    80005330:	fe440593          	addi	a1,s0,-28
    80005334:	4509                	li	a0,2
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	8c4080e7          	jalr	-1852(ra) # 80002bfa <argint>
    return -1;
    8000533e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005340:	02054763          	bltz	a0,8000536e <sys_write+0x5c>
    80005344:	fd840593          	addi	a1,s0,-40
    80005348:	4505                	li	a0,1
    8000534a:	ffffe097          	auipc	ra,0xffffe
    8000534e:	8d2080e7          	jalr	-1838(ra) # 80002c1c <argaddr>
    return -1;
    80005352:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005354:	00054d63          	bltz	a0,8000536e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005358:	fe442603          	lw	a2,-28(s0)
    8000535c:	fd843583          	ld	a1,-40(s0)
    80005360:	fe843503          	ld	a0,-24(s0)
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	4aa080e7          	jalr	1194(ra) # 8000480e <filewrite>
    8000536c:	87aa                	mv	a5,a0
}
    8000536e:	853e                	mv	a0,a5
    80005370:	70a2                	ld	ra,40(sp)
    80005372:	7402                	ld	s0,32(sp)
    80005374:	6145                	addi	sp,sp,48
    80005376:	8082                	ret

0000000080005378 <sys_close>:
{
    80005378:	1101                	addi	sp,sp,-32
    8000537a:	ec06                	sd	ra,24(sp)
    8000537c:	e822                	sd	s0,16(sp)
    8000537e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005380:	fe040613          	addi	a2,s0,-32
    80005384:	fec40593          	addi	a1,s0,-20
    80005388:	4501                	li	a0,0
    8000538a:	00000097          	auipc	ra,0x0
    8000538e:	cc2080e7          	jalr	-830(ra) # 8000504c <argfd>
    return -1;
    80005392:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005394:	02054463          	bltz	a0,800053bc <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005398:	ffffc097          	auipc	ra,0xffffc
    8000539c:	77a080e7          	jalr	1914(ra) # 80001b12 <myproc>
    800053a0:	fec42783          	lw	a5,-20(s0)
    800053a4:	07e9                	addi	a5,a5,26
    800053a6:	078e                	slli	a5,a5,0x3
    800053a8:	97aa                	add	a5,a5,a0
    800053aa:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800053ae:	fe043503          	ld	a0,-32(s0)
    800053b2:	fffff097          	auipc	ra,0xfffff
    800053b6:	260080e7          	jalr	608(ra) # 80004612 <fileclose>
  return 0;
    800053ba:	4781                	li	a5,0
}
    800053bc:	853e                	mv	a0,a5
    800053be:	60e2                	ld	ra,24(sp)
    800053c0:	6442                	ld	s0,16(sp)
    800053c2:	6105                	addi	sp,sp,32
    800053c4:	8082                	ret

00000000800053c6 <sys_fstat>:
{
    800053c6:	1101                	addi	sp,sp,-32
    800053c8:	ec06                	sd	ra,24(sp)
    800053ca:	e822                	sd	s0,16(sp)
    800053cc:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053ce:	fe840613          	addi	a2,s0,-24
    800053d2:	4581                	li	a1,0
    800053d4:	4501                	li	a0,0
    800053d6:	00000097          	auipc	ra,0x0
    800053da:	c76080e7          	jalr	-906(ra) # 8000504c <argfd>
    return -1;
    800053de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053e0:	02054563          	bltz	a0,8000540a <sys_fstat+0x44>
    800053e4:	fe040593          	addi	a1,s0,-32
    800053e8:	4505                	li	a0,1
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	832080e7          	jalr	-1998(ra) # 80002c1c <argaddr>
    return -1;
    800053f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053f4:	00054b63          	bltz	a0,8000540a <sys_fstat+0x44>
  return filestat(f, st);
    800053f8:	fe043583          	ld	a1,-32(s0)
    800053fc:	fe843503          	ld	a0,-24(s0)
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	2da080e7          	jalr	730(ra) # 800046da <filestat>
    80005408:	87aa                	mv	a5,a0
}
    8000540a:	853e                	mv	a0,a5
    8000540c:	60e2                	ld	ra,24(sp)
    8000540e:	6442                	ld	s0,16(sp)
    80005410:	6105                	addi	sp,sp,32
    80005412:	8082                	ret

0000000080005414 <sys_link>:
{
    80005414:	7169                	addi	sp,sp,-304
    80005416:	f606                	sd	ra,296(sp)
    80005418:	f222                	sd	s0,288(sp)
    8000541a:	ee26                	sd	s1,280(sp)
    8000541c:	ea4a                	sd	s2,272(sp)
    8000541e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005420:	08000613          	li	a2,128
    80005424:	ed040593          	addi	a1,s0,-304
    80005428:	4501                	li	a0,0
    8000542a:	ffffe097          	auipc	ra,0xffffe
    8000542e:	814080e7          	jalr	-2028(ra) # 80002c3e <argstr>
    return -1;
    80005432:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005434:	10054e63          	bltz	a0,80005550 <sys_link+0x13c>
    80005438:	08000613          	li	a2,128
    8000543c:	f5040593          	addi	a1,s0,-176
    80005440:	4505                	li	a0,1
    80005442:	ffffd097          	auipc	ra,0xffffd
    80005446:	7fc080e7          	jalr	2044(ra) # 80002c3e <argstr>
    return -1;
    8000544a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000544c:	10054263          	bltz	a0,80005550 <sys_link+0x13c>
  begin_op();
    80005450:	fffff097          	auipc	ra,0xfffff
    80005454:	cf0080e7          	jalr	-784(ra) # 80004140 <begin_op>
  if((ip = namei(old)) == 0){
    80005458:	ed040513          	addi	a0,s0,-304
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	ad8080e7          	jalr	-1320(ra) # 80003f34 <namei>
    80005464:	84aa                	mv	s1,a0
    80005466:	c551                	beqz	a0,800054f2 <sys_link+0xde>
  ilock(ip);
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	318080e7          	jalr	792(ra) # 80003780 <ilock>
  if(ip->type == T_DIR){
    80005470:	04449703          	lh	a4,68(s1)
    80005474:	4785                	li	a5,1
    80005476:	08f70463          	beq	a4,a5,800054fe <sys_link+0xea>
  ip->nlink++;
    8000547a:	04a4d783          	lhu	a5,74(s1)
    8000547e:	2785                	addiw	a5,a5,1
    80005480:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005484:	8526                	mv	a0,s1
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	230080e7          	jalr	560(ra) # 800036b6 <iupdate>
  iunlock(ip);
    8000548e:	8526                	mv	a0,s1
    80005490:	ffffe097          	auipc	ra,0xffffe
    80005494:	3b2080e7          	jalr	946(ra) # 80003842 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005498:	fd040593          	addi	a1,s0,-48
    8000549c:	f5040513          	addi	a0,s0,-176
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	ab2080e7          	jalr	-1358(ra) # 80003f52 <nameiparent>
    800054a8:	892a                	mv	s2,a0
    800054aa:	c935                	beqz	a0,8000551e <sys_link+0x10a>
  ilock(dp);
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	2d4080e7          	jalr	724(ra) # 80003780 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054b4:	00092703          	lw	a4,0(s2)
    800054b8:	409c                	lw	a5,0(s1)
    800054ba:	04f71d63          	bne	a4,a5,80005514 <sys_link+0x100>
    800054be:	40d0                	lw	a2,4(s1)
    800054c0:	fd040593          	addi	a1,s0,-48
    800054c4:	854a                	mv	a0,s2
    800054c6:	fffff097          	auipc	ra,0xfffff
    800054ca:	9ac080e7          	jalr	-1620(ra) # 80003e72 <dirlink>
    800054ce:	04054363          	bltz	a0,80005514 <sys_link+0x100>
  iunlockput(dp);
    800054d2:	854a                	mv	a0,s2
    800054d4:	ffffe097          	auipc	ra,0xffffe
    800054d8:	50e080e7          	jalr	1294(ra) # 800039e2 <iunlockput>
  iput(ip);
    800054dc:	8526                	mv	a0,s1
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	45c080e7          	jalr	1116(ra) # 8000393a <iput>
  end_op();
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	cda080e7          	jalr	-806(ra) # 800041c0 <end_op>
  return 0;
    800054ee:	4781                	li	a5,0
    800054f0:	a085                	j	80005550 <sys_link+0x13c>
    end_op();
    800054f2:	fffff097          	auipc	ra,0xfffff
    800054f6:	cce080e7          	jalr	-818(ra) # 800041c0 <end_op>
    return -1;
    800054fa:	57fd                	li	a5,-1
    800054fc:	a891                	j	80005550 <sys_link+0x13c>
    iunlockput(ip);
    800054fe:	8526                	mv	a0,s1
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	4e2080e7          	jalr	1250(ra) # 800039e2 <iunlockput>
    end_op();
    80005508:	fffff097          	auipc	ra,0xfffff
    8000550c:	cb8080e7          	jalr	-840(ra) # 800041c0 <end_op>
    return -1;
    80005510:	57fd                	li	a5,-1
    80005512:	a83d                	j	80005550 <sys_link+0x13c>
    iunlockput(dp);
    80005514:	854a                	mv	a0,s2
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	4cc080e7          	jalr	1228(ra) # 800039e2 <iunlockput>
  ilock(ip);
    8000551e:	8526                	mv	a0,s1
    80005520:	ffffe097          	auipc	ra,0xffffe
    80005524:	260080e7          	jalr	608(ra) # 80003780 <ilock>
  ip->nlink--;
    80005528:	04a4d783          	lhu	a5,74(s1)
    8000552c:	37fd                	addiw	a5,a5,-1
    8000552e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005532:	8526                	mv	a0,s1
    80005534:	ffffe097          	auipc	ra,0xffffe
    80005538:	182080e7          	jalr	386(ra) # 800036b6 <iupdate>
  iunlockput(ip);
    8000553c:	8526                	mv	a0,s1
    8000553e:	ffffe097          	auipc	ra,0xffffe
    80005542:	4a4080e7          	jalr	1188(ra) # 800039e2 <iunlockput>
  end_op();
    80005546:	fffff097          	auipc	ra,0xfffff
    8000554a:	c7a080e7          	jalr	-902(ra) # 800041c0 <end_op>
  return -1;
    8000554e:	57fd                	li	a5,-1
}
    80005550:	853e                	mv	a0,a5
    80005552:	70b2                	ld	ra,296(sp)
    80005554:	7412                	ld	s0,288(sp)
    80005556:	64f2                	ld	s1,280(sp)
    80005558:	6952                	ld	s2,272(sp)
    8000555a:	6155                	addi	sp,sp,304
    8000555c:	8082                	ret

000000008000555e <sys_unlink>:
{
    8000555e:	7151                	addi	sp,sp,-240
    80005560:	f586                	sd	ra,232(sp)
    80005562:	f1a2                	sd	s0,224(sp)
    80005564:	eda6                	sd	s1,216(sp)
    80005566:	e9ca                	sd	s2,208(sp)
    80005568:	e5ce                	sd	s3,200(sp)
    8000556a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000556c:	08000613          	li	a2,128
    80005570:	f3040593          	addi	a1,s0,-208
    80005574:	4501                	li	a0,0
    80005576:	ffffd097          	auipc	ra,0xffffd
    8000557a:	6c8080e7          	jalr	1736(ra) # 80002c3e <argstr>
    8000557e:	18054b63          	bltz	a0,80005714 <sys_unlink+0x1b6>
  printf("unlink: %s", path);
    80005582:	f3040593          	addi	a1,s0,-208
    80005586:	00003517          	auipc	a0,0x3
    8000558a:	15a50513          	addi	a0,a0,346 # 800086e0 <syscalls+0x2e8>
    8000558e:	ffffb097          	auipc	ra,0xffffb
    80005592:	004080e7          	jalr	4(ra) # 80000592 <printf>
  begin_op();
    80005596:	fffff097          	auipc	ra,0xfffff
    8000559a:	baa080e7          	jalr	-1110(ra) # 80004140 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000559e:	fb040593          	addi	a1,s0,-80
    800055a2:	f3040513          	addi	a0,s0,-208
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	9ac080e7          	jalr	-1620(ra) # 80003f52 <nameiparent>
    800055ae:	84aa                	mv	s1,a0
    800055b0:	c979                	beqz	a0,80005686 <sys_unlink+0x128>
  ilock(dp);
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	1ce080e7          	jalr	462(ra) # 80003780 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055ba:	00003597          	auipc	a1,0x3
    800055be:	0fe58593          	addi	a1,a1,254 # 800086b8 <syscalls+0x2c0>
    800055c2:	fb040513          	addi	a0,s0,-80
    800055c6:	ffffe097          	auipc	ra,0xffffe
    800055ca:	682080e7          	jalr	1666(ra) # 80003c48 <namecmp>
    800055ce:	14050a63          	beqz	a0,80005722 <sys_unlink+0x1c4>
    800055d2:	00003597          	auipc	a1,0x3
    800055d6:	b7e58593          	addi	a1,a1,-1154 # 80008150 <digits+0x110>
    800055da:	fb040513          	addi	a0,s0,-80
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	66a080e7          	jalr	1642(ra) # 80003c48 <namecmp>
    800055e6:	12050e63          	beqz	a0,80005722 <sys_unlink+0x1c4>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055ea:	f2c40613          	addi	a2,s0,-212
    800055ee:	fb040593          	addi	a1,s0,-80
    800055f2:	8526                	mv	a0,s1
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	66e080e7          	jalr	1646(ra) # 80003c62 <dirlookup>
    800055fc:	892a                	mv	s2,a0
    800055fe:	12050263          	beqz	a0,80005722 <sys_unlink+0x1c4>
  ilock(ip);
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	17e080e7          	jalr	382(ra) # 80003780 <ilock>
  if(ip->nlink < 1)
    8000560a:	04a91783          	lh	a5,74(s2)
    8000560e:	08f05263          	blez	a5,80005692 <sys_unlink+0x134>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005612:	04491703          	lh	a4,68(s2)
    80005616:	4785                	li	a5,1
    80005618:	08f70563          	beq	a4,a5,800056a2 <sys_unlink+0x144>
  memset(&de, 0, sizeof(de));
    8000561c:	4641                	li	a2,16
    8000561e:	4581                	li	a1,0
    80005620:	fc040513          	addi	a0,s0,-64
    80005624:	ffffb097          	auipc	ra,0xffffb
    80005628:	6e8080e7          	jalr	1768(ra) # 80000d0c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000562c:	4741                	li	a4,16
    8000562e:	f2c42683          	lw	a3,-212(s0)
    80005632:	fc040613          	addi	a2,s0,-64
    80005636:	4581                	li	a1,0
    80005638:	8526                	mv	a0,s1
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	4f2080e7          	jalr	1266(ra) # 80003b2c <writei>
    80005642:	47c1                	li	a5,16
    80005644:	0af51563          	bne	a0,a5,800056ee <sys_unlink+0x190>
  if(ip->type == T_DIR){
    80005648:	04491703          	lh	a4,68(s2)
    8000564c:	4785                	li	a5,1
    8000564e:	0af70863          	beq	a4,a5,800056fe <sys_unlink+0x1a0>
  iunlockput(dp);
    80005652:	8526                	mv	a0,s1
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	38e080e7          	jalr	910(ra) # 800039e2 <iunlockput>
  ip->nlink--;
    8000565c:	04a95783          	lhu	a5,74(s2)
    80005660:	37fd                	addiw	a5,a5,-1
    80005662:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005666:	854a                	mv	a0,s2
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	04e080e7          	jalr	78(ra) # 800036b6 <iupdate>
  iunlockput(ip);
    80005670:	854a                	mv	a0,s2
    80005672:	ffffe097          	auipc	ra,0xffffe
    80005676:	370080e7          	jalr	880(ra) # 800039e2 <iunlockput>
  end_op();
    8000567a:	fffff097          	auipc	ra,0xfffff
    8000567e:	b46080e7          	jalr	-1210(ra) # 800041c0 <end_op>
  return 0;
    80005682:	4501                	li	a0,0
    80005684:	a84d                	j	80005736 <sys_unlink+0x1d8>
    end_op();
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	b3a080e7          	jalr	-1222(ra) # 800041c0 <end_op>
    return -1;
    8000568e:	557d                	li	a0,-1
    80005690:	a05d                	j	80005736 <sys_unlink+0x1d8>
    panic("unlink: nlink < 1");
    80005692:	00003517          	auipc	a0,0x3
    80005696:	05e50513          	addi	a0,a0,94 # 800086f0 <syscalls+0x2f8>
    8000569a:	ffffb097          	auipc	ra,0xffffb
    8000569e:	eae080e7          	jalr	-338(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056a2:	04c92703          	lw	a4,76(s2)
    800056a6:	02000793          	li	a5,32
    800056aa:	f6e7f9e3          	bgeu	a5,a4,8000561c <sys_unlink+0xbe>
    800056ae:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056b2:	4741                	li	a4,16
    800056b4:	86ce                	mv	a3,s3
    800056b6:	f1840613          	addi	a2,s0,-232
    800056ba:	4581                	li	a1,0
    800056bc:	854a                	mv	a0,s2
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	376080e7          	jalr	886(ra) # 80003a34 <readi>
    800056c6:	47c1                	li	a5,16
    800056c8:	00f51b63          	bne	a0,a5,800056de <sys_unlink+0x180>
    if(de.inum != 0)
    800056cc:	f1845783          	lhu	a5,-232(s0)
    800056d0:	e7a1                	bnez	a5,80005718 <sys_unlink+0x1ba>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056d2:	29c1                	addiw	s3,s3,16
    800056d4:	04c92783          	lw	a5,76(s2)
    800056d8:	fcf9ede3          	bltu	s3,a5,800056b2 <sys_unlink+0x154>
    800056dc:	b781                	j	8000561c <sys_unlink+0xbe>
      panic("isdirempty: readi");
    800056de:	00003517          	auipc	a0,0x3
    800056e2:	02a50513          	addi	a0,a0,42 # 80008708 <syscalls+0x310>
    800056e6:	ffffb097          	auipc	ra,0xffffb
    800056ea:	e62080e7          	jalr	-414(ra) # 80000548 <panic>
    panic("unlink: writei");
    800056ee:	00003517          	auipc	a0,0x3
    800056f2:	03250513          	addi	a0,a0,50 # 80008720 <syscalls+0x328>
    800056f6:	ffffb097          	auipc	ra,0xffffb
    800056fa:	e52080e7          	jalr	-430(ra) # 80000548 <panic>
    dp->nlink--;
    800056fe:	04a4d783          	lhu	a5,74(s1)
    80005702:	37fd                	addiw	a5,a5,-1
    80005704:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005708:	8526                	mv	a0,s1
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	fac080e7          	jalr	-84(ra) # 800036b6 <iupdate>
    80005712:	b781                	j	80005652 <sys_unlink+0xf4>
    return -1;
    80005714:	557d                	li	a0,-1
    80005716:	a005                	j	80005736 <sys_unlink+0x1d8>
    iunlockput(ip);
    80005718:	854a                	mv	a0,s2
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	2c8080e7          	jalr	712(ra) # 800039e2 <iunlockput>
  iunlockput(dp);
    80005722:	8526                	mv	a0,s1
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	2be080e7          	jalr	702(ra) # 800039e2 <iunlockput>
  end_op();
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	a94080e7          	jalr	-1388(ra) # 800041c0 <end_op>
  return -1;
    80005734:	557d                	li	a0,-1
}
    80005736:	70ae                	ld	ra,232(sp)
    80005738:	740e                	ld	s0,224(sp)
    8000573a:	64ee                	ld	s1,216(sp)
    8000573c:	694e                	ld	s2,208(sp)
    8000573e:	69ae                	ld	s3,200(sp)
    80005740:	616d                	addi	sp,sp,240
    80005742:	8082                	ret

0000000080005744 <sys_open>:

uint64
sys_open(void)
{
    80005744:	7131                	addi	sp,sp,-192
    80005746:	fd06                	sd	ra,184(sp)
    80005748:	f922                	sd	s0,176(sp)
    8000574a:	f526                	sd	s1,168(sp)
    8000574c:	f14a                	sd	s2,160(sp)
    8000574e:	ed4e                	sd	s3,152(sp)
    80005750:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005752:	08000613          	li	a2,128
    80005756:	f5040593          	addi	a1,s0,-176
    8000575a:	4501                	li	a0,0
    8000575c:	ffffd097          	auipc	ra,0xffffd
    80005760:	4e2080e7          	jalr	1250(ra) # 80002c3e <argstr>
    return -1;
    80005764:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005766:	0c054163          	bltz	a0,80005828 <sys_open+0xe4>
    8000576a:	f4c40593          	addi	a1,s0,-180
    8000576e:	4505                	li	a0,1
    80005770:	ffffd097          	auipc	ra,0xffffd
    80005774:	48a080e7          	jalr	1162(ra) # 80002bfa <argint>
    80005778:	0a054863          	bltz	a0,80005828 <sys_open+0xe4>

  begin_op();
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	9c4080e7          	jalr	-1596(ra) # 80004140 <begin_op>

  if(omode & O_CREATE){
    80005784:	f4c42783          	lw	a5,-180(s0)
    80005788:	2007f793          	andi	a5,a5,512
    8000578c:	cbdd                	beqz	a5,80005842 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000578e:	4681                	li	a3,0
    80005790:	4601                	li	a2,0
    80005792:	4589                	li	a1,2
    80005794:	f5040513          	addi	a0,s0,-176
    80005798:	00000097          	auipc	ra,0x0
    8000579c:	95e080e7          	jalr	-1698(ra) # 800050f6 <create>
    800057a0:	892a                	mv	s2,a0
    if(ip == 0){
    800057a2:	c959                	beqz	a0,80005838 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057a4:	04491703          	lh	a4,68(s2)
    800057a8:	478d                	li	a5,3
    800057aa:	00f71763          	bne	a4,a5,800057b8 <sys_open+0x74>
    800057ae:	04695703          	lhu	a4,70(s2)
    800057b2:	47a5                	li	a5,9
    800057b4:	0ce7ec63          	bltu	a5,a4,8000588c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	d9e080e7          	jalr	-610(ra) # 80004556 <filealloc>
    800057c0:	89aa                	mv	s3,a0
    800057c2:	10050263          	beqz	a0,800058c6 <sys_open+0x182>
    800057c6:	00000097          	auipc	ra,0x0
    800057ca:	8ee080e7          	jalr	-1810(ra) # 800050b4 <fdalloc>
    800057ce:	84aa                	mv	s1,a0
    800057d0:	0e054663          	bltz	a0,800058bc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057d4:	04491703          	lh	a4,68(s2)
    800057d8:	478d                	li	a5,3
    800057da:	0cf70463          	beq	a4,a5,800058a2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057de:	4789                	li	a5,2
    800057e0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800057e4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800057e8:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800057ec:	f4c42783          	lw	a5,-180(s0)
    800057f0:	0017c713          	xori	a4,a5,1
    800057f4:	8b05                	andi	a4,a4,1
    800057f6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057fa:	0037f713          	andi	a4,a5,3
    800057fe:	00e03733          	snez	a4,a4
    80005802:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005806:	4007f793          	andi	a5,a5,1024
    8000580a:	c791                	beqz	a5,80005816 <sys_open+0xd2>
    8000580c:	04491703          	lh	a4,68(s2)
    80005810:	4789                	li	a5,2
    80005812:	08f70f63          	beq	a4,a5,800058b0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005816:	854a                	mv	a0,s2
    80005818:	ffffe097          	auipc	ra,0xffffe
    8000581c:	02a080e7          	jalr	42(ra) # 80003842 <iunlock>
  end_op();
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	9a0080e7          	jalr	-1632(ra) # 800041c0 <end_op>

  return fd;
}
    80005828:	8526                	mv	a0,s1
    8000582a:	70ea                	ld	ra,184(sp)
    8000582c:	744a                	ld	s0,176(sp)
    8000582e:	74aa                	ld	s1,168(sp)
    80005830:	790a                	ld	s2,160(sp)
    80005832:	69ea                	ld	s3,152(sp)
    80005834:	6129                	addi	sp,sp,192
    80005836:	8082                	ret
      end_op();
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	988080e7          	jalr	-1656(ra) # 800041c0 <end_op>
      return -1;
    80005840:	b7e5                	j	80005828 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005842:	f5040513          	addi	a0,s0,-176
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	6ee080e7          	jalr	1774(ra) # 80003f34 <namei>
    8000584e:	892a                	mv	s2,a0
    80005850:	c905                	beqz	a0,80005880 <sys_open+0x13c>
    ilock(ip);
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	f2e080e7          	jalr	-210(ra) # 80003780 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000585a:	04491703          	lh	a4,68(s2)
    8000585e:	4785                	li	a5,1
    80005860:	f4f712e3          	bne	a4,a5,800057a4 <sys_open+0x60>
    80005864:	f4c42783          	lw	a5,-180(s0)
    80005868:	dba1                	beqz	a5,800057b8 <sys_open+0x74>
      iunlockput(ip);
    8000586a:	854a                	mv	a0,s2
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	176080e7          	jalr	374(ra) # 800039e2 <iunlockput>
      end_op();
    80005874:	fffff097          	auipc	ra,0xfffff
    80005878:	94c080e7          	jalr	-1716(ra) # 800041c0 <end_op>
      return -1;
    8000587c:	54fd                	li	s1,-1
    8000587e:	b76d                	j	80005828 <sys_open+0xe4>
      end_op();
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	940080e7          	jalr	-1728(ra) # 800041c0 <end_op>
      return -1;
    80005888:	54fd                	li	s1,-1
    8000588a:	bf79                	j	80005828 <sys_open+0xe4>
    iunlockput(ip);
    8000588c:	854a                	mv	a0,s2
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	154080e7          	jalr	340(ra) # 800039e2 <iunlockput>
    end_op();
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	92a080e7          	jalr	-1750(ra) # 800041c0 <end_op>
    return -1;
    8000589e:	54fd                	li	s1,-1
    800058a0:	b761                	j	80005828 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800058a2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058a6:	04691783          	lh	a5,70(s2)
    800058aa:	02f99223          	sh	a5,36(s3)
    800058ae:	bf2d                	j	800057e8 <sys_open+0xa4>
    itrunc(ip);
    800058b0:	854a                	mv	a0,s2
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	fdc080e7          	jalr	-36(ra) # 8000388e <itrunc>
    800058ba:	bfb1                	j	80005816 <sys_open+0xd2>
      fileclose(f);
    800058bc:	854e                	mv	a0,s3
    800058be:	fffff097          	auipc	ra,0xfffff
    800058c2:	d54080e7          	jalr	-684(ra) # 80004612 <fileclose>
    iunlockput(ip);
    800058c6:	854a                	mv	a0,s2
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	11a080e7          	jalr	282(ra) # 800039e2 <iunlockput>
    end_op();
    800058d0:	fffff097          	auipc	ra,0xfffff
    800058d4:	8f0080e7          	jalr	-1808(ra) # 800041c0 <end_op>
    return -1;
    800058d8:	54fd                	li	s1,-1
    800058da:	b7b9                	j	80005828 <sys_open+0xe4>

00000000800058dc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058dc:	7175                	addi	sp,sp,-144
    800058de:	e506                	sd	ra,136(sp)
    800058e0:	e122                	sd	s0,128(sp)
    800058e2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058e4:	fffff097          	auipc	ra,0xfffff
    800058e8:	85c080e7          	jalr	-1956(ra) # 80004140 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058ec:	08000613          	li	a2,128
    800058f0:	f7040593          	addi	a1,s0,-144
    800058f4:	4501                	li	a0,0
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	348080e7          	jalr	840(ra) # 80002c3e <argstr>
    800058fe:	02054963          	bltz	a0,80005930 <sys_mkdir+0x54>
    80005902:	4681                	li	a3,0
    80005904:	4601                	li	a2,0
    80005906:	4585                	li	a1,1
    80005908:	f7040513          	addi	a0,s0,-144
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	7ea080e7          	jalr	2026(ra) # 800050f6 <create>
    80005914:	cd11                	beqz	a0,80005930 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	0cc080e7          	jalr	204(ra) # 800039e2 <iunlockput>
  end_op();
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	8a2080e7          	jalr	-1886(ra) # 800041c0 <end_op>
  return 0;
    80005926:	4501                	li	a0,0
}
    80005928:	60aa                	ld	ra,136(sp)
    8000592a:	640a                	ld	s0,128(sp)
    8000592c:	6149                	addi	sp,sp,144
    8000592e:	8082                	ret
    end_op();
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	890080e7          	jalr	-1904(ra) # 800041c0 <end_op>
    return -1;
    80005938:	557d                	li	a0,-1
    8000593a:	b7fd                	j	80005928 <sys_mkdir+0x4c>

000000008000593c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000593c:	7135                	addi	sp,sp,-160
    8000593e:	ed06                	sd	ra,152(sp)
    80005940:	e922                	sd	s0,144(sp)
    80005942:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	7fc080e7          	jalr	2044(ra) # 80004140 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000594c:	08000613          	li	a2,128
    80005950:	f7040593          	addi	a1,s0,-144
    80005954:	4501                	li	a0,0
    80005956:	ffffd097          	auipc	ra,0xffffd
    8000595a:	2e8080e7          	jalr	744(ra) # 80002c3e <argstr>
    8000595e:	04054a63          	bltz	a0,800059b2 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005962:	f6c40593          	addi	a1,s0,-148
    80005966:	4505                	li	a0,1
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	292080e7          	jalr	658(ra) # 80002bfa <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005970:	04054163          	bltz	a0,800059b2 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005974:	f6840593          	addi	a1,s0,-152
    80005978:	4509                	li	a0,2
    8000597a:	ffffd097          	auipc	ra,0xffffd
    8000597e:	280080e7          	jalr	640(ra) # 80002bfa <argint>
     argint(1, &major) < 0 ||
    80005982:	02054863          	bltz	a0,800059b2 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005986:	f6841683          	lh	a3,-152(s0)
    8000598a:	f6c41603          	lh	a2,-148(s0)
    8000598e:	458d                	li	a1,3
    80005990:	f7040513          	addi	a0,s0,-144
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	762080e7          	jalr	1890(ra) # 800050f6 <create>
     argint(2, &minor) < 0 ||
    8000599c:	c919                	beqz	a0,800059b2 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000599e:	ffffe097          	auipc	ra,0xffffe
    800059a2:	044080e7          	jalr	68(ra) # 800039e2 <iunlockput>
  end_op();
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	81a080e7          	jalr	-2022(ra) # 800041c0 <end_op>
  return 0;
    800059ae:	4501                	li	a0,0
    800059b0:	a031                	j	800059bc <sys_mknod+0x80>
    end_op();
    800059b2:	fffff097          	auipc	ra,0xfffff
    800059b6:	80e080e7          	jalr	-2034(ra) # 800041c0 <end_op>
    return -1;
    800059ba:	557d                	li	a0,-1
}
    800059bc:	60ea                	ld	ra,152(sp)
    800059be:	644a                	ld	s0,144(sp)
    800059c0:	610d                	addi	sp,sp,160
    800059c2:	8082                	ret

00000000800059c4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800059c4:	7135                	addi	sp,sp,-160
    800059c6:	ed06                	sd	ra,152(sp)
    800059c8:	e922                	sd	s0,144(sp)
    800059ca:	e526                	sd	s1,136(sp)
    800059cc:	e14a                	sd	s2,128(sp)
    800059ce:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059d0:	ffffc097          	auipc	ra,0xffffc
    800059d4:	142080e7          	jalr	322(ra) # 80001b12 <myproc>
    800059d8:	892a                	mv	s2,a0
  
  begin_op();
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	766080e7          	jalr	1894(ra) # 80004140 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059e2:	08000613          	li	a2,128
    800059e6:	f6040593          	addi	a1,s0,-160
    800059ea:	4501                	li	a0,0
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	252080e7          	jalr	594(ra) # 80002c3e <argstr>
    800059f4:	04054b63          	bltz	a0,80005a4a <sys_chdir+0x86>
    800059f8:	f6040513          	addi	a0,s0,-160
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	538080e7          	jalr	1336(ra) # 80003f34 <namei>
    80005a04:	84aa                	mv	s1,a0
    80005a06:	c131                	beqz	a0,80005a4a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a08:	ffffe097          	auipc	ra,0xffffe
    80005a0c:	d78080e7          	jalr	-648(ra) # 80003780 <ilock>
  if(ip->type != T_DIR){
    80005a10:	04449703          	lh	a4,68(s1)
    80005a14:	4785                	li	a5,1
    80005a16:	04f71063          	bne	a4,a5,80005a56 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a1a:	8526                	mv	a0,s1
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	e26080e7          	jalr	-474(ra) # 80003842 <iunlock>
  iput(p->cwd);
    80005a24:	15093503          	ld	a0,336(s2)
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	f12080e7          	jalr	-238(ra) # 8000393a <iput>
  end_op();
    80005a30:	ffffe097          	auipc	ra,0xffffe
    80005a34:	790080e7          	jalr	1936(ra) # 800041c0 <end_op>
  p->cwd = ip;
    80005a38:	14993823          	sd	s1,336(s2)
  return 0;
    80005a3c:	4501                	li	a0,0
}
    80005a3e:	60ea                	ld	ra,152(sp)
    80005a40:	644a                	ld	s0,144(sp)
    80005a42:	64aa                	ld	s1,136(sp)
    80005a44:	690a                	ld	s2,128(sp)
    80005a46:	610d                	addi	sp,sp,160
    80005a48:	8082                	ret
    end_op();
    80005a4a:	ffffe097          	auipc	ra,0xffffe
    80005a4e:	776080e7          	jalr	1910(ra) # 800041c0 <end_op>
    return -1;
    80005a52:	557d                	li	a0,-1
    80005a54:	b7ed                	j	80005a3e <sys_chdir+0x7a>
    iunlockput(ip);
    80005a56:	8526                	mv	a0,s1
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	f8a080e7          	jalr	-118(ra) # 800039e2 <iunlockput>
    end_op();
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	760080e7          	jalr	1888(ra) # 800041c0 <end_op>
    return -1;
    80005a68:	557d                	li	a0,-1
    80005a6a:	bfd1                	j	80005a3e <sys_chdir+0x7a>

0000000080005a6c <sys_exec>:

uint64
sys_exec(void)
{
    80005a6c:	7145                	addi	sp,sp,-464
    80005a6e:	e786                	sd	ra,456(sp)
    80005a70:	e3a2                	sd	s0,448(sp)
    80005a72:	ff26                	sd	s1,440(sp)
    80005a74:	fb4a                	sd	s2,432(sp)
    80005a76:	f74e                	sd	s3,424(sp)
    80005a78:	f352                	sd	s4,416(sp)
    80005a7a:	ef56                	sd	s5,408(sp)
    80005a7c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a7e:	08000613          	li	a2,128
    80005a82:	f4040593          	addi	a1,s0,-192
    80005a86:	4501                	li	a0,0
    80005a88:	ffffd097          	auipc	ra,0xffffd
    80005a8c:	1b6080e7          	jalr	438(ra) # 80002c3e <argstr>
    return -1;
    80005a90:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a92:	0c054a63          	bltz	a0,80005b66 <sys_exec+0xfa>
    80005a96:	e3840593          	addi	a1,s0,-456
    80005a9a:	4505                	li	a0,1
    80005a9c:	ffffd097          	auipc	ra,0xffffd
    80005aa0:	180080e7          	jalr	384(ra) # 80002c1c <argaddr>
    80005aa4:	0c054163          	bltz	a0,80005b66 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005aa8:	10000613          	li	a2,256
    80005aac:	4581                	li	a1,0
    80005aae:	e4040513          	addi	a0,s0,-448
    80005ab2:	ffffb097          	auipc	ra,0xffffb
    80005ab6:	25a080e7          	jalr	602(ra) # 80000d0c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005aba:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005abe:	89a6                	mv	s3,s1
    80005ac0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ac2:	02000a13          	li	s4,32
    80005ac6:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005aca:	00391513          	slli	a0,s2,0x3
    80005ace:	e3040593          	addi	a1,s0,-464
    80005ad2:	e3843783          	ld	a5,-456(s0)
    80005ad6:	953e                	add	a0,a0,a5
    80005ad8:	ffffd097          	auipc	ra,0xffffd
    80005adc:	088080e7          	jalr	136(ra) # 80002b60 <fetchaddr>
    80005ae0:	02054a63          	bltz	a0,80005b14 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005ae4:	e3043783          	ld	a5,-464(s0)
    80005ae8:	c3b9                	beqz	a5,80005b2e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005aea:	ffffb097          	auipc	ra,0xffffb
    80005aee:	036080e7          	jalr	54(ra) # 80000b20 <kalloc>
    80005af2:	85aa                	mv	a1,a0
    80005af4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005af8:	cd11                	beqz	a0,80005b14 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005afa:	6605                	lui	a2,0x1
    80005afc:	e3043503          	ld	a0,-464(s0)
    80005b00:	ffffd097          	auipc	ra,0xffffd
    80005b04:	0b2080e7          	jalr	178(ra) # 80002bb2 <fetchstr>
    80005b08:	00054663          	bltz	a0,80005b14 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b0c:	0905                	addi	s2,s2,1
    80005b0e:	09a1                	addi	s3,s3,8
    80005b10:	fb491be3          	bne	s2,s4,80005ac6 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b14:	10048913          	addi	s2,s1,256
    80005b18:	6088                	ld	a0,0(s1)
    80005b1a:	c529                	beqz	a0,80005b64 <sys_exec+0xf8>
    kfree(argv[i]);
    80005b1c:	ffffb097          	auipc	ra,0xffffb
    80005b20:	f08080e7          	jalr	-248(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b24:	04a1                	addi	s1,s1,8
    80005b26:	ff2499e3          	bne	s1,s2,80005b18 <sys_exec+0xac>
  return -1;
    80005b2a:	597d                	li	s2,-1
    80005b2c:	a82d                	j	80005b66 <sys_exec+0xfa>
      argv[i] = 0;
    80005b2e:	0a8e                	slli	s5,s5,0x3
    80005b30:	fc040793          	addi	a5,s0,-64
    80005b34:	9abe                	add	s5,s5,a5
    80005b36:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b3a:	e4040593          	addi	a1,s0,-448
    80005b3e:	f4040513          	addi	a0,s0,-192
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	180080e7          	jalr	384(ra) # 80004cc2 <exec>
    80005b4a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b4c:	10048993          	addi	s3,s1,256
    80005b50:	6088                	ld	a0,0(s1)
    80005b52:	c911                	beqz	a0,80005b66 <sys_exec+0xfa>
    kfree(argv[i]);
    80005b54:	ffffb097          	auipc	ra,0xffffb
    80005b58:	ed0080e7          	jalr	-304(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b5c:	04a1                	addi	s1,s1,8
    80005b5e:	ff3499e3          	bne	s1,s3,80005b50 <sys_exec+0xe4>
    80005b62:	a011                	j	80005b66 <sys_exec+0xfa>
  return -1;
    80005b64:	597d                	li	s2,-1
}
    80005b66:	854a                	mv	a0,s2
    80005b68:	60be                	ld	ra,456(sp)
    80005b6a:	641e                	ld	s0,448(sp)
    80005b6c:	74fa                	ld	s1,440(sp)
    80005b6e:	795a                	ld	s2,432(sp)
    80005b70:	79ba                	ld	s3,424(sp)
    80005b72:	7a1a                	ld	s4,416(sp)
    80005b74:	6afa                	ld	s5,408(sp)
    80005b76:	6179                	addi	sp,sp,464
    80005b78:	8082                	ret

0000000080005b7a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b7a:	7139                	addi	sp,sp,-64
    80005b7c:	fc06                	sd	ra,56(sp)
    80005b7e:	f822                	sd	s0,48(sp)
    80005b80:	f426                	sd	s1,40(sp)
    80005b82:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b84:	ffffc097          	auipc	ra,0xffffc
    80005b88:	f8e080e7          	jalr	-114(ra) # 80001b12 <myproc>
    80005b8c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b8e:	fd840593          	addi	a1,s0,-40
    80005b92:	4501                	li	a0,0
    80005b94:	ffffd097          	auipc	ra,0xffffd
    80005b98:	088080e7          	jalr	136(ra) # 80002c1c <argaddr>
    return -1;
    80005b9c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b9e:	0e054063          	bltz	a0,80005c7e <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005ba2:	fc840593          	addi	a1,s0,-56
    80005ba6:	fd040513          	addi	a0,s0,-48
    80005baa:	fffff097          	auipc	ra,0xfffff
    80005bae:	dbe080e7          	jalr	-578(ra) # 80004968 <pipealloc>
    return -1;
    80005bb2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bb4:	0c054563          	bltz	a0,80005c7e <sys_pipe+0x104>
  fd0 = -1;
    80005bb8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005bbc:	fd043503          	ld	a0,-48(s0)
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	4f4080e7          	jalr	1268(ra) # 800050b4 <fdalloc>
    80005bc8:	fca42223          	sw	a0,-60(s0)
    80005bcc:	08054c63          	bltz	a0,80005c64 <sys_pipe+0xea>
    80005bd0:	fc843503          	ld	a0,-56(s0)
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	4e0080e7          	jalr	1248(ra) # 800050b4 <fdalloc>
    80005bdc:	fca42023          	sw	a0,-64(s0)
    80005be0:	06054863          	bltz	a0,80005c50 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005be4:	4691                	li	a3,4
    80005be6:	fc440613          	addi	a2,s0,-60
    80005bea:	fd843583          	ld	a1,-40(s0)
    80005bee:	68a8                	ld	a0,80(s1)
    80005bf0:	ffffc097          	auipc	ra,0xffffc
    80005bf4:	b3c080e7          	jalr	-1220(ra) # 8000172c <copyout>
    80005bf8:	02054063          	bltz	a0,80005c18 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bfc:	4691                	li	a3,4
    80005bfe:	fc040613          	addi	a2,s0,-64
    80005c02:	fd843583          	ld	a1,-40(s0)
    80005c06:	0591                	addi	a1,a1,4
    80005c08:	68a8                	ld	a0,80(s1)
    80005c0a:	ffffc097          	auipc	ra,0xffffc
    80005c0e:	b22080e7          	jalr	-1246(ra) # 8000172c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c12:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c14:	06055563          	bgez	a0,80005c7e <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c18:	fc442783          	lw	a5,-60(s0)
    80005c1c:	07e9                	addi	a5,a5,26
    80005c1e:	078e                	slli	a5,a5,0x3
    80005c20:	97a6                	add	a5,a5,s1
    80005c22:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c26:	fc042503          	lw	a0,-64(s0)
    80005c2a:	0569                	addi	a0,a0,26
    80005c2c:	050e                	slli	a0,a0,0x3
    80005c2e:	9526                	add	a0,a0,s1
    80005c30:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c34:	fd043503          	ld	a0,-48(s0)
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	9da080e7          	jalr	-1574(ra) # 80004612 <fileclose>
    fileclose(wf);
    80005c40:	fc843503          	ld	a0,-56(s0)
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	9ce080e7          	jalr	-1586(ra) # 80004612 <fileclose>
    return -1;
    80005c4c:	57fd                	li	a5,-1
    80005c4e:	a805                	j	80005c7e <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c50:	fc442783          	lw	a5,-60(s0)
    80005c54:	0007c863          	bltz	a5,80005c64 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c58:	01a78513          	addi	a0,a5,26
    80005c5c:	050e                	slli	a0,a0,0x3
    80005c5e:	9526                	add	a0,a0,s1
    80005c60:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c64:	fd043503          	ld	a0,-48(s0)
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	9aa080e7          	jalr	-1622(ra) # 80004612 <fileclose>
    fileclose(wf);
    80005c70:	fc843503          	ld	a0,-56(s0)
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	99e080e7          	jalr	-1634(ra) # 80004612 <fileclose>
    return -1;
    80005c7c:	57fd                	li	a5,-1
}
    80005c7e:	853e                	mv	a0,a5
    80005c80:	70e2                	ld	ra,56(sp)
    80005c82:	7442                	ld	s0,48(sp)
    80005c84:	74a2                	ld	s1,40(sp)
    80005c86:	6121                	addi	sp,sp,64
    80005c88:	8082                	ret
    80005c8a:	0000                	unimp
    80005c8c:	0000                	unimp
	...

0000000080005c90 <kernelvec>:
    80005c90:	7111                	addi	sp,sp,-256
    80005c92:	e006                	sd	ra,0(sp)
    80005c94:	e40a                	sd	sp,8(sp)
    80005c96:	e80e                	sd	gp,16(sp)
    80005c98:	ec12                	sd	tp,24(sp)
    80005c9a:	f016                	sd	t0,32(sp)
    80005c9c:	f41a                	sd	t1,40(sp)
    80005c9e:	f81e                	sd	t2,48(sp)
    80005ca0:	fc22                	sd	s0,56(sp)
    80005ca2:	e0a6                	sd	s1,64(sp)
    80005ca4:	e4aa                	sd	a0,72(sp)
    80005ca6:	e8ae                	sd	a1,80(sp)
    80005ca8:	ecb2                	sd	a2,88(sp)
    80005caa:	f0b6                	sd	a3,96(sp)
    80005cac:	f4ba                	sd	a4,104(sp)
    80005cae:	f8be                	sd	a5,112(sp)
    80005cb0:	fcc2                	sd	a6,120(sp)
    80005cb2:	e146                	sd	a7,128(sp)
    80005cb4:	e54a                	sd	s2,136(sp)
    80005cb6:	e94e                	sd	s3,144(sp)
    80005cb8:	ed52                	sd	s4,152(sp)
    80005cba:	f156                	sd	s5,160(sp)
    80005cbc:	f55a                	sd	s6,168(sp)
    80005cbe:	f95e                	sd	s7,176(sp)
    80005cc0:	fd62                	sd	s8,184(sp)
    80005cc2:	e1e6                	sd	s9,192(sp)
    80005cc4:	e5ea                	sd	s10,200(sp)
    80005cc6:	e9ee                	sd	s11,208(sp)
    80005cc8:	edf2                	sd	t3,216(sp)
    80005cca:	f1f6                	sd	t4,224(sp)
    80005ccc:	f5fa                	sd	t5,232(sp)
    80005cce:	f9fe                	sd	t6,240(sp)
    80005cd0:	d5dfc0ef          	jal	ra,80002a2c <kerneltrap>
    80005cd4:	6082                	ld	ra,0(sp)
    80005cd6:	6122                	ld	sp,8(sp)
    80005cd8:	61c2                	ld	gp,16(sp)
    80005cda:	7282                	ld	t0,32(sp)
    80005cdc:	7322                	ld	t1,40(sp)
    80005cde:	73c2                	ld	t2,48(sp)
    80005ce0:	7462                	ld	s0,56(sp)
    80005ce2:	6486                	ld	s1,64(sp)
    80005ce4:	6526                	ld	a0,72(sp)
    80005ce6:	65c6                	ld	a1,80(sp)
    80005ce8:	6666                	ld	a2,88(sp)
    80005cea:	7686                	ld	a3,96(sp)
    80005cec:	7726                	ld	a4,104(sp)
    80005cee:	77c6                	ld	a5,112(sp)
    80005cf0:	7866                	ld	a6,120(sp)
    80005cf2:	688a                	ld	a7,128(sp)
    80005cf4:	692a                	ld	s2,136(sp)
    80005cf6:	69ca                	ld	s3,144(sp)
    80005cf8:	6a6a                	ld	s4,152(sp)
    80005cfa:	7a8a                	ld	s5,160(sp)
    80005cfc:	7b2a                	ld	s6,168(sp)
    80005cfe:	7bca                	ld	s7,176(sp)
    80005d00:	7c6a                	ld	s8,184(sp)
    80005d02:	6c8e                	ld	s9,192(sp)
    80005d04:	6d2e                	ld	s10,200(sp)
    80005d06:	6dce                	ld	s11,208(sp)
    80005d08:	6e6e                	ld	t3,216(sp)
    80005d0a:	7e8e                	ld	t4,224(sp)
    80005d0c:	7f2e                	ld	t5,232(sp)
    80005d0e:	7fce                	ld	t6,240(sp)
    80005d10:	6111                	addi	sp,sp,256
    80005d12:	10200073          	sret
    80005d16:	00000013          	nop
    80005d1a:	00000013          	nop
    80005d1e:	0001                	nop

0000000080005d20 <timervec>:
    80005d20:	34051573          	csrrw	a0,mscratch,a0
    80005d24:	e10c                	sd	a1,0(a0)
    80005d26:	e510                	sd	a2,8(a0)
    80005d28:	e914                	sd	a3,16(a0)
    80005d2a:	710c                	ld	a1,32(a0)
    80005d2c:	7510                	ld	a2,40(a0)
    80005d2e:	6194                	ld	a3,0(a1)
    80005d30:	96b2                	add	a3,a3,a2
    80005d32:	e194                	sd	a3,0(a1)
    80005d34:	4589                	li	a1,2
    80005d36:	14459073          	csrw	sip,a1
    80005d3a:	6914                	ld	a3,16(a0)
    80005d3c:	6510                	ld	a2,8(a0)
    80005d3e:	610c                	ld	a1,0(a0)
    80005d40:	34051573          	csrrw	a0,mscratch,a0
    80005d44:	30200073          	mret
	...

0000000080005d4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d4a:	1141                	addi	sp,sp,-16
    80005d4c:	e422                	sd	s0,8(sp)
    80005d4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d50:	0c0007b7          	lui	a5,0xc000
    80005d54:	4705                	li	a4,1
    80005d56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d58:	c3d8                	sw	a4,4(a5)
}
    80005d5a:	6422                	ld	s0,8(sp)
    80005d5c:	0141                	addi	sp,sp,16
    80005d5e:	8082                	ret

0000000080005d60 <plicinithart>:

void
plicinithart(void)
{
    80005d60:	1141                	addi	sp,sp,-16
    80005d62:	e406                	sd	ra,8(sp)
    80005d64:	e022                	sd	s0,0(sp)
    80005d66:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d68:	ffffc097          	auipc	ra,0xffffc
    80005d6c:	d7e080e7          	jalr	-642(ra) # 80001ae6 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d70:	0085171b          	slliw	a4,a0,0x8
    80005d74:	0c0027b7          	lui	a5,0xc002
    80005d78:	97ba                	add	a5,a5,a4
    80005d7a:	40200713          	li	a4,1026
    80005d7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d82:	00d5151b          	slliw	a0,a0,0xd
    80005d86:	0c2017b7          	lui	a5,0xc201
    80005d8a:	953e                	add	a0,a0,a5
    80005d8c:	00052023          	sw	zero,0(a0)
}
    80005d90:	60a2                	ld	ra,8(sp)
    80005d92:	6402                	ld	s0,0(sp)
    80005d94:	0141                	addi	sp,sp,16
    80005d96:	8082                	ret

0000000080005d98 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d98:	1141                	addi	sp,sp,-16
    80005d9a:	e406                	sd	ra,8(sp)
    80005d9c:	e022                	sd	s0,0(sp)
    80005d9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005da0:	ffffc097          	auipc	ra,0xffffc
    80005da4:	d46080e7          	jalr	-698(ra) # 80001ae6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005da8:	00d5179b          	slliw	a5,a0,0xd
    80005dac:	0c201537          	lui	a0,0xc201
    80005db0:	953e                	add	a0,a0,a5
  return irq;
}
    80005db2:	4148                	lw	a0,4(a0)
    80005db4:	60a2                	ld	ra,8(sp)
    80005db6:	6402                	ld	s0,0(sp)
    80005db8:	0141                	addi	sp,sp,16
    80005dba:	8082                	ret

0000000080005dbc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005dbc:	1101                	addi	sp,sp,-32
    80005dbe:	ec06                	sd	ra,24(sp)
    80005dc0:	e822                	sd	s0,16(sp)
    80005dc2:	e426                	sd	s1,8(sp)
    80005dc4:	1000                	addi	s0,sp,32
    80005dc6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005dc8:	ffffc097          	auipc	ra,0xffffc
    80005dcc:	d1e080e7          	jalr	-738(ra) # 80001ae6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005dd0:	00d5151b          	slliw	a0,a0,0xd
    80005dd4:	0c2017b7          	lui	a5,0xc201
    80005dd8:	97aa                	add	a5,a5,a0
    80005dda:	c3c4                	sw	s1,4(a5)
}
    80005ddc:	60e2                	ld	ra,24(sp)
    80005dde:	6442                	ld	s0,16(sp)
    80005de0:	64a2                	ld	s1,8(sp)
    80005de2:	6105                	addi	sp,sp,32
    80005de4:	8082                	ret

0000000080005de6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005de6:	1141                	addi	sp,sp,-16
    80005de8:	e406                	sd	ra,8(sp)
    80005dea:	e022                	sd	s0,0(sp)
    80005dec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dee:	479d                	li	a5,7
    80005df0:	04a7cc63          	blt	a5,a0,80005e48 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005df4:	0001d797          	auipc	a5,0x1d
    80005df8:	20c78793          	addi	a5,a5,524 # 80023000 <disk>
    80005dfc:	00a78733          	add	a4,a5,a0
    80005e00:	6789                	lui	a5,0x2
    80005e02:	97ba                	add	a5,a5,a4
    80005e04:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e08:	eba1                	bnez	a5,80005e58 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005e0a:	00451713          	slli	a4,a0,0x4
    80005e0e:	0001f797          	auipc	a5,0x1f
    80005e12:	1f27b783          	ld	a5,498(a5) # 80025000 <disk+0x2000>
    80005e16:	97ba                	add	a5,a5,a4
    80005e18:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005e1c:	0001d797          	auipc	a5,0x1d
    80005e20:	1e478793          	addi	a5,a5,484 # 80023000 <disk>
    80005e24:	97aa                	add	a5,a5,a0
    80005e26:	6509                	lui	a0,0x2
    80005e28:	953e                	add	a0,a0,a5
    80005e2a:	4785                	li	a5,1
    80005e2c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e30:	0001f517          	auipc	a0,0x1f
    80005e34:	1e850513          	addi	a0,a0,488 # 80025018 <disk+0x2018>
    80005e38:	ffffc097          	auipc	ra,0xffffc
    80005e3c:	670080e7          	jalr	1648(ra) # 800024a8 <wakeup>
}
    80005e40:	60a2                	ld	ra,8(sp)
    80005e42:	6402                	ld	s0,0(sp)
    80005e44:	0141                	addi	sp,sp,16
    80005e46:	8082                	ret
    panic("virtio_disk_intr 1");
    80005e48:	00003517          	auipc	a0,0x3
    80005e4c:	8e850513          	addi	a0,a0,-1816 # 80008730 <syscalls+0x338>
    80005e50:	ffffa097          	auipc	ra,0xffffa
    80005e54:	6f8080e7          	jalr	1784(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005e58:	00003517          	auipc	a0,0x3
    80005e5c:	8f050513          	addi	a0,a0,-1808 # 80008748 <syscalls+0x350>
    80005e60:	ffffa097          	auipc	ra,0xffffa
    80005e64:	6e8080e7          	jalr	1768(ra) # 80000548 <panic>

0000000080005e68 <virtio_disk_init>:
{
    80005e68:	1101                	addi	sp,sp,-32
    80005e6a:	ec06                	sd	ra,24(sp)
    80005e6c:	e822                	sd	s0,16(sp)
    80005e6e:	e426                	sd	s1,8(sp)
    80005e70:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e72:	00003597          	auipc	a1,0x3
    80005e76:	8ee58593          	addi	a1,a1,-1810 # 80008760 <syscalls+0x368>
    80005e7a:	0001f517          	auipc	a0,0x1f
    80005e7e:	22e50513          	addi	a0,a0,558 # 800250a8 <disk+0x20a8>
    80005e82:	ffffb097          	auipc	ra,0xffffb
    80005e86:	cfe080e7          	jalr	-770(ra) # 80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e8a:	100017b7          	lui	a5,0x10001
    80005e8e:	4398                	lw	a4,0(a5)
    80005e90:	2701                	sext.w	a4,a4
    80005e92:	747277b7          	lui	a5,0x74727
    80005e96:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e9a:	0ef71163          	bne	a4,a5,80005f7c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e9e:	100017b7          	lui	a5,0x10001
    80005ea2:	43dc                	lw	a5,4(a5)
    80005ea4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ea6:	4705                	li	a4,1
    80005ea8:	0ce79a63          	bne	a5,a4,80005f7c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005eac:	100017b7          	lui	a5,0x10001
    80005eb0:	479c                	lw	a5,8(a5)
    80005eb2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005eb4:	4709                	li	a4,2
    80005eb6:	0ce79363          	bne	a5,a4,80005f7c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005eba:	100017b7          	lui	a5,0x10001
    80005ebe:	47d8                	lw	a4,12(a5)
    80005ec0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ec2:	554d47b7          	lui	a5,0x554d4
    80005ec6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005eca:	0af71963          	bne	a4,a5,80005f7c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ece:	100017b7          	lui	a5,0x10001
    80005ed2:	4705                	li	a4,1
    80005ed4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ed6:	470d                	li	a4,3
    80005ed8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005eda:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005edc:	c7ffe737          	lui	a4,0xc7ffe
    80005ee0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005ee4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005ee6:	2701                	sext.w	a4,a4
    80005ee8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eea:	472d                	li	a4,11
    80005eec:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eee:	473d                	li	a4,15
    80005ef0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005ef2:	6705                	lui	a4,0x1
    80005ef4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ef6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005efa:	5bdc                	lw	a5,52(a5)
    80005efc:	2781                	sext.w	a5,a5
  if(max == 0)
    80005efe:	c7d9                	beqz	a5,80005f8c <virtio_disk_init+0x124>
  if(max < NUM)
    80005f00:	471d                	li	a4,7
    80005f02:	08f77d63          	bgeu	a4,a5,80005f9c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f06:	100014b7          	lui	s1,0x10001
    80005f0a:	47a1                	li	a5,8
    80005f0c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005f0e:	6609                	lui	a2,0x2
    80005f10:	4581                	li	a1,0
    80005f12:	0001d517          	auipc	a0,0x1d
    80005f16:	0ee50513          	addi	a0,a0,238 # 80023000 <disk>
    80005f1a:	ffffb097          	auipc	ra,0xffffb
    80005f1e:	df2080e7          	jalr	-526(ra) # 80000d0c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005f22:	0001d717          	auipc	a4,0x1d
    80005f26:	0de70713          	addi	a4,a4,222 # 80023000 <disk>
    80005f2a:	00c75793          	srli	a5,a4,0xc
    80005f2e:	2781                	sext.w	a5,a5
    80005f30:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005f32:	0001f797          	auipc	a5,0x1f
    80005f36:	0ce78793          	addi	a5,a5,206 # 80025000 <disk+0x2000>
    80005f3a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005f3c:	0001d717          	auipc	a4,0x1d
    80005f40:	14470713          	addi	a4,a4,324 # 80023080 <disk+0x80>
    80005f44:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005f46:	0001e717          	auipc	a4,0x1e
    80005f4a:	0ba70713          	addi	a4,a4,186 # 80024000 <disk+0x1000>
    80005f4e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005f50:	4705                	li	a4,1
    80005f52:	00e78c23          	sb	a4,24(a5)
    80005f56:	00e78ca3          	sb	a4,25(a5)
    80005f5a:	00e78d23          	sb	a4,26(a5)
    80005f5e:	00e78da3          	sb	a4,27(a5)
    80005f62:	00e78e23          	sb	a4,28(a5)
    80005f66:	00e78ea3          	sb	a4,29(a5)
    80005f6a:	00e78f23          	sb	a4,30(a5)
    80005f6e:	00e78fa3          	sb	a4,31(a5)
}
    80005f72:	60e2                	ld	ra,24(sp)
    80005f74:	6442                	ld	s0,16(sp)
    80005f76:	64a2                	ld	s1,8(sp)
    80005f78:	6105                	addi	sp,sp,32
    80005f7a:	8082                	ret
    panic("could not find virtio disk");
    80005f7c:	00002517          	auipc	a0,0x2
    80005f80:	7f450513          	addi	a0,a0,2036 # 80008770 <syscalls+0x378>
    80005f84:	ffffa097          	auipc	ra,0xffffa
    80005f88:	5c4080e7          	jalr	1476(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    80005f8c:	00003517          	auipc	a0,0x3
    80005f90:	80450513          	addi	a0,a0,-2044 # 80008790 <syscalls+0x398>
    80005f94:	ffffa097          	auipc	ra,0xffffa
    80005f98:	5b4080e7          	jalr	1460(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    80005f9c:	00003517          	auipc	a0,0x3
    80005fa0:	81450513          	addi	a0,a0,-2028 # 800087b0 <syscalls+0x3b8>
    80005fa4:	ffffa097          	auipc	ra,0xffffa
    80005fa8:	5a4080e7          	jalr	1444(ra) # 80000548 <panic>

0000000080005fac <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fac:	7119                	addi	sp,sp,-128
    80005fae:	fc86                	sd	ra,120(sp)
    80005fb0:	f8a2                	sd	s0,112(sp)
    80005fb2:	f4a6                	sd	s1,104(sp)
    80005fb4:	f0ca                	sd	s2,96(sp)
    80005fb6:	ecce                	sd	s3,88(sp)
    80005fb8:	e8d2                	sd	s4,80(sp)
    80005fba:	e4d6                	sd	s5,72(sp)
    80005fbc:	e0da                	sd	s6,64(sp)
    80005fbe:	fc5e                	sd	s7,56(sp)
    80005fc0:	f862                	sd	s8,48(sp)
    80005fc2:	f466                	sd	s9,40(sp)
    80005fc4:	f06a                	sd	s10,32(sp)
    80005fc6:	0100                	addi	s0,sp,128
    80005fc8:	892a                	mv	s2,a0
    80005fca:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fcc:	00c52c83          	lw	s9,12(a0)
    80005fd0:	001c9c9b          	slliw	s9,s9,0x1
    80005fd4:	1c82                	slli	s9,s9,0x20
    80005fd6:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005fda:	0001f517          	auipc	a0,0x1f
    80005fde:	0ce50513          	addi	a0,a0,206 # 800250a8 <disk+0x20a8>
    80005fe2:	ffffb097          	auipc	ra,0xffffb
    80005fe6:	c2e080e7          	jalr	-978(ra) # 80000c10 <acquire>
  for(int i = 0; i < 3; i++){
    80005fea:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fec:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005fee:	0001db97          	auipc	s7,0x1d
    80005ff2:	012b8b93          	addi	s7,s7,18 # 80023000 <disk>
    80005ff6:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005ff8:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005ffa:	8a4e                	mv	s4,s3
    80005ffc:	a051                	j	80006080 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005ffe:	00fb86b3          	add	a3,s7,a5
    80006002:	96da                	add	a3,a3,s6
    80006004:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006008:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000600a:	0207c563          	bltz	a5,80006034 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000600e:	2485                	addiw	s1,s1,1
    80006010:	0711                	addi	a4,a4,4
    80006012:	23548d63          	beq	s1,s5,8000624c <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80006016:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006018:	0001f697          	auipc	a3,0x1f
    8000601c:	00068693          	mv	a3,a3
    80006020:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006022:	0006c583          	lbu	a1,0(a3) # 80025018 <disk+0x2018>
    80006026:	fde1                	bnez	a1,80005ffe <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006028:	2785                	addiw	a5,a5,1
    8000602a:	0685                	addi	a3,a3,1
    8000602c:	ff879be3          	bne	a5,s8,80006022 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006030:	57fd                	li	a5,-1
    80006032:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006034:	02905a63          	blez	s1,80006068 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006038:	f9042503          	lw	a0,-112(s0)
    8000603c:	00000097          	auipc	ra,0x0
    80006040:	daa080e7          	jalr	-598(ra) # 80005de6 <free_desc>
      for(int j = 0; j < i; j++)
    80006044:	4785                	li	a5,1
    80006046:	0297d163          	bge	a5,s1,80006068 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000604a:	f9442503          	lw	a0,-108(s0)
    8000604e:	00000097          	auipc	ra,0x0
    80006052:	d98080e7          	jalr	-616(ra) # 80005de6 <free_desc>
      for(int j = 0; j < i; j++)
    80006056:	4789                	li	a5,2
    80006058:	0097d863          	bge	a5,s1,80006068 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000605c:	f9842503          	lw	a0,-104(s0)
    80006060:	00000097          	auipc	ra,0x0
    80006064:	d86080e7          	jalr	-634(ra) # 80005de6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006068:	0001f597          	auipc	a1,0x1f
    8000606c:	04058593          	addi	a1,a1,64 # 800250a8 <disk+0x20a8>
    80006070:	0001f517          	auipc	a0,0x1f
    80006074:	fa850513          	addi	a0,a0,-88 # 80025018 <disk+0x2018>
    80006078:	ffffc097          	auipc	ra,0xffffc
    8000607c:	2aa080e7          	jalr	682(ra) # 80002322 <sleep>
  for(int i = 0; i < 3; i++){
    80006080:	f9040713          	addi	a4,s0,-112
    80006084:	84ce                	mv	s1,s3
    80006086:	bf41                	j	80006016 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006088:	4785                	li	a5,1
    8000608a:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000608e:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80006092:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006096:	f9042983          	lw	s3,-112(s0)
    8000609a:	00499493          	slli	s1,s3,0x4
    8000609e:	0001fa17          	auipc	s4,0x1f
    800060a2:	f62a0a13          	addi	s4,s4,-158 # 80025000 <disk+0x2000>
    800060a6:	000a3a83          	ld	s5,0(s4)
    800060aa:	9aa6                	add	s5,s5,s1
    800060ac:	f8040513          	addi	a0,s0,-128
    800060b0:	ffffb097          	auipc	ra,0xffffb
    800060b4:	fee080e7          	jalr	-18(ra) # 8000109e <kvmpa>
    800060b8:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    800060bc:	000a3783          	ld	a5,0(s4)
    800060c0:	97a6                	add	a5,a5,s1
    800060c2:	4741                	li	a4,16
    800060c4:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060c6:	000a3783          	ld	a5,0(s4)
    800060ca:	97a6                	add	a5,a5,s1
    800060cc:	4705                	li	a4,1
    800060ce:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800060d2:	f9442703          	lw	a4,-108(s0)
    800060d6:	000a3783          	ld	a5,0(s4)
    800060da:	97a6                	add	a5,a5,s1
    800060dc:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060e0:	0712                	slli	a4,a4,0x4
    800060e2:	000a3783          	ld	a5,0(s4)
    800060e6:	97ba                	add	a5,a5,a4
    800060e8:	05890693          	addi	a3,s2,88
    800060ec:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    800060ee:	000a3783          	ld	a5,0(s4)
    800060f2:	97ba                	add	a5,a5,a4
    800060f4:	40000693          	li	a3,1024
    800060f8:	c794                	sw	a3,8(a5)
  if(write)
    800060fa:	100d0a63          	beqz	s10,8000620e <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800060fe:	0001f797          	auipc	a5,0x1f
    80006102:	f027b783          	ld	a5,-254(a5) # 80025000 <disk+0x2000>
    80006106:	97ba                	add	a5,a5,a4
    80006108:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000610c:	0001d517          	auipc	a0,0x1d
    80006110:	ef450513          	addi	a0,a0,-268 # 80023000 <disk>
    80006114:	0001f797          	auipc	a5,0x1f
    80006118:	eec78793          	addi	a5,a5,-276 # 80025000 <disk+0x2000>
    8000611c:	6394                	ld	a3,0(a5)
    8000611e:	96ba                	add	a3,a3,a4
    80006120:	00c6d603          	lhu	a2,12(a3)
    80006124:	00166613          	ori	a2,a2,1
    80006128:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000612c:	f9842683          	lw	a3,-104(s0)
    80006130:	6390                	ld	a2,0(a5)
    80006132:	9732                	add	a4,a4,a2
    80006134:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006138:	20098613          	addi	a2,s3,512
    8000613c:	0612                	slli	a2,a2,0x4
    8000613e:	962a                	add	a2,a2,a0
    80006140:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006144:	00469713          	slli	a4,a3,0x4
    80006148:	6394                	ld	a3,0(a5)
    8000614a:	96ba                	add	a3,a3,a4
    8000614c:	6589                	lui	a1,0x2
    8000614e:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80006152:	94ae                	add	s1,s1,a1
    80006154:	94aa                	add	s1,s1,a0
    80006156:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006158:	6394                	ld	a3,0(a5)
    8000615a:	96ba                	add	a3,a3,a4
    8000615c:	4585                	li	a1,1
    8000615e:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006160:	6394                	ld	a3,0(a5)
    80006162:	96ba                	add	a3,a3,a4
    80006164:	4509                	li	a0,2
    80006166:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000616a:	6394                	ld	a3,0(a5)
    8000616c:	9736                	add	a4,a4,a3
    8000616e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006172:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006176:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000617a:	6794                	ld	a3,8(a5)
    8000617c:	0026d703          	lhu	a4,2(a3)
    80006180:	8b1d                	andi	a4,a4,7
    80006182:	2709                	addiw	a4,a4,2
    80006184:	0706                	slli	a4,a4,0x1
    80006186:	9736                	add	a4,a4,a3
    80006188:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    8000618c:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006190:	6798                	ld	a4,8(a5)
    80006192:	00275783          	lhu	a5,2(a4)
    80006196:	2785                	addiw	a5,a5,1
    80006198:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000619c:	100017b7          	lui	a5,0x10001
    800061a0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800061a4:	00492703          	lw	a4,4(s2)
    800061a8:	4785                	li	a5,1
    800061aa:	02f71163          	bne	a4,a5,800061cc <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    800061ae:	0001f997          	auipc	s3,0x1f
    800061b2:	efa98993          	addi	s3,s3,-262 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800061b6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800061b8:	85ce                	mv	a1,s3
    800061ba:	854a                	mv	a0,s2
    800061bc:	ffffc097          	auipc	ra,0xffffc
    800061c0:	166080e7          	jalr	358(ra) # 80002322 <sleep>
  while(b->disk == 1) {
    800061c4:	00492783          	lw	a5,4(s2)
    800061c8:	fe9788e3          	beq	a5,s1,800061b8 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    800061cc:	f9042483          	lw	s1,-112(s0)
    800061d0:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    800061d4:	00479713          	slli	a4,a5,0x4
    800061d8:	0001d797          	auipc	a5,0x1d
    800061dc:	e2878793          	addi	a5,a5,-472 # 80023000 <disk>
    800061e0:	97ba                	add	a5,a5,a4
    800061e2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061e6:	0001f917          	auipc	s2,0x1f
    800061ea:	e1a90913          	addi	s2,s2,-486 # 80025000 <disk+0x2000>
    free_desc(i);
    800061ee:	8526                	mv	a0,s1
    800061f0:	00000097          	auipc	ra,0x0
    800061f4:	bf6080e7          	jalr	-1034(ra) # 80005de6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061f8:	0492                	slli	s1,s1,0x4
    800061fa:	00093783          	ld	a5,0(s2)
    800061fe:	94be                	add	s1,s1,a5
    80006200:	00c4d783          	lhu	a5,12(s1)
    80006204:	8b85                	andi	a5,a5,1
    80006206:	cf89                	beqz	a5,80006220 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    80006208:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000620c:	b7cd                	j	800061ee <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000620e:	0001f797          	auipc	a5,0x1f
    80006212:	df27b783          	ld	a5,-526(a5) # 80025000 <disk+0x2000>
    80006216:	97ba                	add	a5,a5,a4
    80006218:	4689                	li	a3,2
    8000621a:	00d79623          	sh	a3,12(a5)
    8000621e:	b5fd                	j	8000610c <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006220:	0001f517          	auipc	a0,0x1f
    80006224:	e8850513          	addi	a0,a0,-376 # 800250a8 <disk+0x20a8>
    80006228:	ffffb097          	auipc	ra,0xffffb
    8000622c:	a9c080e7          	jalr	-1380(ra) # 80000cc4 <release>
}
    80006230:	70e6                	ld	ra,120(sp)
    80006232:	7446                	ld	s0,112(sp)
    80006234:	74a6                	ld	s1,104(sp)
    80006236:	7906                	ld	s2,96(sp)
    80006238:	69e6                	ld	s3,88(sp)
    8000623a:	6a46                	ld	s4,80(sp)
    8000623c:	6aa6                	ld	s5,72(sp)
    8000623e:	6b06                	ld	s6,64(sp)
    80006240:	7be2                	ld	s7,56(sp)
    80006242:	7c42                	ld	s8,48(sp)
    80006244:	7ca2                	ld	s9,40(sp)
    80006246:	7d02                	ld	s10,32(sp)
    80006248:	6109                	addi	sp,sp,128
    8000624a:	8082                	ret
  if(write)
    8000624c:	e20d1ee3          	bnez	s10,80006088 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006250:	f8042023          	sw	zero,-128(s0)
    80006254:	bd2d                	j	8000608e <virtio_disk_rw+0xe2>

0000000080006256 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006256:	1101                	addi	sp,sp,-32
    80006258:	ec06                	sd	ra,24(sp)
    8000625a:	e822                	sd	s0,16(sp)
    8000625c:	e426                	sd	s1,8(sp)
    8000625e:	e04a                	sd	s2,0(sp)
    80006260:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006262:	0001f517          	auipc	a0,0x1f
    80006266:	e4650513          	addi	a0,a0,-442 # 800250a8 <disk+0x20a8>
    8000626a:	ffffb097          	auipc	ra,0xffffb
    8000626e:	9a6080e7          	jalr	-1626(ra) # 80000c10 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006272:	0001f717          	auipc	a4,0x1f
    80006276:	d8e70713          	addi	a4,a4,-626 # 80025000 <disk+0x2000>
    8000627a:	02075783          	lhu	a5,32(a4)
    8000627e:	6b18                	ld	a4,16(a4)
    80006280:	00275683          	lhu	a3,2(a4)
    80006284:	8ebd                	xor	a3,a3,a5
    80006286:	8a9d                	andi	a3,a3,7
    80006288:	cab9                	beqz	a3,800062de <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000628a:	0001d917          	auipc	s2,0x1d
    8000628e:	d7690913          	addi	s2,s2,-650 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006292:	0001f497          	auipc	s1,0x1f
    80006296:	d6e48493          	addi	s1,s1,-658 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000629a:	078e                	slli	a5,a5,0x3
    8000629c:	97ba                	add	a5,a5,a4
    8000629e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800062a0:	20078713          	addi	a4,a5,512
    800062a4:	0712                	slli	a4,a4,0x4
    800062a6:	974a                	add	a4,a4,s2
    800062a8:	03074703          	lbu	a4,48(a4)
    800062ac:	ef21                	bnez	a4,80006304 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800062ae:	20078793          	addi	a5,a5,512
    800062b2:	0792                	slli	a5,a5,0x4
    800062b4:	97ca                	add	a5,a5,s2
    800062b6:	7798                	ld	a4,40(a5)
    800062b8:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800062bc:	7788                	ld	a0,40(a5)
    800062be:	ffffc097          	auipc	ra,0xffffc
    800062c2:	1ea080e7          	jalr	490(ra) # 800024a8 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800062c6:	0204d783          	lhu	a5,32(s1)
    800062ca:	2785                	addiw	a5,a5,1
    800062cc:	8b9d                	andi	a5,a5,7
    800062ce:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800062d2:	6898                	ld	a4,16(s1)
    800062d4:	00275683          	lhu	a3,2(a4)
    800062d8:	8a9d                	andi	a3,a3,7
    800062da:	fcf690e3          	bne	a3,a5,8000629a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800062de:	10001737          	lui	a4,0x10001
    800062e2:	533c                	lw	a5,96(a4)
    800062e4:	8b8d                	andi	a5,a5,3
    800062e6:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800062e8:	0001f517          	auipc	a0,0x1f
    800062ec:	dc050513          	addi	a0,a0,-576 # 800250a8 <disk+0x20a8>
    800062f0:	ffffb097          	auipc	ra,0xffffb
    800062f4:	9d4080e7          	jalr	-1580(ra) # 80000cc4 <release>
}
    800062f8:	60e2                	ld	ra,24(sp)
    800062fa:	6442                	ld	s0,16(sp)
    800062fc:	64a2                	ld	s1,8(sp)
    800062fe:	6902                	ld	s2,0(sp)
    80006300:	6105                	addi	sp,sp,32
    80006302:	8082                	ret
      panic("virtio_disk_intr status");
    80006304:	00002517          	auipc	a0,0x2
    80006308:	4cc50513          	addi	a0,a0,1228 # 800087d0 <syscalls+0x3d8>
    8000630c:	ffffa097          	auipc	ra,0xffffa
    80006310:	23c080e7          	jalr	572(ra) # 80000548 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
