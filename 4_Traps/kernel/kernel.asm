
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e7c78793          	addi	a5,a5,-388 # 80000f22 <main>
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
    80000110:	b68080e7          	jalr	-1176(ra) # 80000c74 <acquire>
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
    8000012a:	40a080e7          	jalr	1034(ra) # 80002530 <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00001097          	auipc	ra,0x1
    8000013a:	80e080e7          	jalr	-2034(ra) # 80000944 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	bda080e7          	jalr	-1062(ra) # 80000d28 <release>

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
    800001a2:	ad6080e7          	jalr	-1322(ra) # 80000c74 <acquire>
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
    800001d2:	874080e7          	jalr	-1932(ra) # 80001a42 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	09a080e7          	jalr	154(ra) # 80002278 <sleep>
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
    8000021e:	2c0080e7          	jalr	704(ra) # 800024da <either_copyout>
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
    8000023a:	af2080e7          	jalr	-1294(ra) # 80000d28 <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	adc080e7          	jalr	-1316(ra) # 80000d28 <release>
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
    8000029a:	5c8080e7          	jalr	1480(ra) # 8000085e <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	5b6080e7          	jalr	1462(ra) # 8000085e <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	5aa080e7          	jalr	1450(ra) # 8000085e <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	5a0080e7          	jalr	1440(ra) # 8000085e <uartputc_sync>
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
    800002e2:	996080e7          	jalr	-1642(ra) # 80000c74 <acquire>

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
    80000300:	28a080e7          	jalr	650(ra) # 80002586 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	a1c080e7          	jalr	-1508(ra) # 80000d28 <release>
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
    80000454:	fae080e7          	jalr	-82(ra) # 800023fe <wakeup>
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
    80000476:	772080e7          	jalr	1906(ra) # 80000be4 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	394080e7          	jalr	916(ra) # 8000080e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00022797          	auipc	a5,0x22
    80000486:	b2e78793          	addi	a5,a5,-1234 # 80021fb0 <devsw>
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
    800004c8:	b9460613          	addi	a2,a2,-1132 # 80008058 <digits>
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

0000000080000548 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000552:	00011497          	auipc	s1,0x11
    80000556:	38648493          	addi	s1,s1,902 # 800118d8 <pr>
    8000055a:	00008597          	auipc	a1,0x8
    8000055e:	abe58593          	addi	a1,a1,-1346 # 80008018 <etext+0x18>
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	680080e7          	jalr	1664(ra) # 80000be4 <initlock>
  pr.locking = 1;
    8000056c:	4785                	li	a5,1
    8000056e:	cc9c                	sw	a5,24(s1)
}
    80000570:	60e2                	ld	ra,24(sp)
    80000572:	6442                	ld	s0,16(sp)
    80000574:	64a2                	ld	s1,8(sp)
    80000576:	6105                	addi	sp,sp,32
    80000578:	8082                	ret

000000008000057a <backtrace>:

void
backtrace(void)
{
    8000057a:	7179                	addi	sp,sp,-48
    8000057c:	f406                	sd	ra,40(sp)
    8000057e:	f022                	sd	s0,32(sp)
    80000580:	ec26                	sd	s1,24(sp)
    80000582:	e84a                	sd	s2,16(sp)
    80000584:	e44e                	sd	s3,8(sp)
    80000586:	1800                	addi	s0,sp,48
  printf("backtrace:\n");
    80000588:	00008517          	auipc	a0,0x8
    8000058c:	a9850513          	addi	a0,a0,-1384 # 80008020 <etext+0x20>
    80000590:	00000097          	auipc	ra,0x0
    80000594:	098080e7          	jalr	152(ra) # 80000628 <printf>

static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0" : "=r" (x) );
    80000598:	84a2                	mv	s1,s0
  uint64 fp = r_fp();
  uint64 base = PGROUNDUP(fp);
    8000059a:	6905                	lui	s2,0x1
    8000059c:	197d                	addi	s2,s2,-1
    8000059e:	9926                	add	s2,s2,s1
    800005a0:	77fd                	lui	a5,0xfffff
    800005a2:	00f97933          	and	s2,s2,a5
  while(fp < base) {
    800005a6:	0324f163          	bgeu	s1,s2,800005c8 <backtrace+0x4e>
    printf("%p\n", *((uint64*)(fp - 8)));
    800005aa:	00008997          	auipc	s3,0x8
    800005ae:	a8698993          	addi	s3,s3,-1402 # 80008030 <etext+0x30>
    800005b2:	ff84b583          	ld	a1,-8(s1)
    800005b6:	854e                	mv	a0,s3
    800005b8:	00000097          	auipc	ra,0x0
    800005bc:	070080e7          	jalr	112(ra) # 80000628 <printf>
    fp = *((uint64*)(fp - 16));
    800005c0:	ff04b483          	ld	s1,-16(s1)
  while(fp < base) {
    800005c4:	ff24e7e3          	bltu	s1,s2,800005b2 <backtrace+0x38>
  }
}
    800005c8:	70a2                	ld	ra,40(sp)
    800005ca:	7402                	ld	s0,32(sp)
    800005cc:	64e2                	ld	s1,24(sp)
    800005ce:	6942                	ld	s2,16(sp)
    800005d0:	69a2                	ld	s3,8(sp)
    800005d2:	6145                	addi	sp,sp,48
    800005d4:	8082                	ret

00000000800005d6 <panic>:
{
    800005d6:	1101                	addi	sp,sp,-32
    800005d8:	ec06                	sd	ra,24(sp)
    800005da:	e822                	sd	s0,16(sp)
    800005dc:	e426                	sd	s1,8(sp)
    800005de:	1000                	addi	s0,sp,32
    800005e0:	84aa                	mv	s1,a0
  backtrace();
    800005e2:	00000097          	auipc	ra,0x0
    800005e6:	f98080e7          	jalr	-104(ra) # 8000057a <backtrace>
  pr.locking = 0;
    800005ea:	00011797          	auipc	a5,0x11
    800005ee:	3007a323          	sw	zero,774(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    800005f2:	00008517          	auipc	a0,0x8
    800005f6:	a4650513          	addi	a0,a0,-1466 # 80008038 <etext+0x38>
    800005fa:	00000097          	auipc	ra,0x0
    800005fe:	02e080e7          	jalr	46(ra) # 80000628 <printf>
  printf(s);
    80000602:	8526                	mv	a0,s1
    80000604:	00000097          	auipc	ra,0x0
    80000608:	024080e7          	jalr	36(ra) # 80000628 <printf>
  printf("\n");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	ad450513          	addi	a0,a0,-1324 # 800080e0 <digits+0x88>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	014080e7          	jalr	20(ra) # 80000628 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000061c:	4785                	li	a5,1
    8000061e:	00009717          	auipc	a4,0x9
    80000622:	9ef72123          	sw	a5,-1566(a4) # 80009000 <panicked>
  for(;;)
    80000626:	a001                	j	80000626 <panic+0x50>

0000000080000628 <printf>:
{
    80000628:	7131                	addi	sp,sp,-192
    8000062a:	fc86                	sd	ra,120(sp)
    8000062c:	f8a2                	sd	s0,112(sp)
    8000062e:	f4a6                	sd	s1,104(sp)
    80000630:	f0ca                	sd	s2,96(sp)
    80000632:	ecce                	sd	s3,88(sp)
    80000634:	e8d2                	sd	s4,80(sp)
    80000636:	e4d6                	sd	s5,72(sp)
    80000638:	e0da                	sd	s6,64(sp)
    8000063a:	fc5e                	sd	s7,56(sp)
    8000063c:	f862                	sd	s8,48(sp)
    8000063e:	f466                	sd	s9,40(sp)
    80000640:	f06a                	sd	s10,32(sp)
    80000642:	ec6e                	sd	s11,24(sp)
    80000644:	0100                	addi	s0,sp,128
    80000646:	8a2a                	mv	s4,a0
    80000648:	e40c                	sd	a1,8(s0)
    8000064a:	e810                	sd	a2,16(s0)
    8000064c:	ec14                	sd	a3,24(s0)
    8000064e:	f018                	sd	a4,32(s0)
    80000650:	f41c                	sd	a5,40(s0)
    80000652:	03043823          	sd	a6,48(s0)
    80000656:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    8000065a:	00011d97          	auipc	s11,0x11
    8000065e:	296dad83          	lw	s11,662(s11) # 800118f0 <pr+0x18>
  if(locking)
    80000662:	020d9b63          	bnez	s11,80000698 <printf+0x70>
  if (fmt == 0)
    80000666:	040a0263          	beqz	s4,800006aa <printf+0x82>
  va_start(ap, fmt);
    8000066a:	00840793          	addi	a5,s0,8
    8000066e:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000672:	000a4503          	lbu	a0,0(s4)
    80000676:	16050263          	beqz	a0,800007da <printf+0x1b2>
    8000067a:	4481                	li	s1,0
    if(c != '%'){
    8000067c:	02500a93          	li	s5,37
    switch(c){
    80000680:	07000b13          	li	s6,112
  consputc('x');
    80000684:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000686:	00008b97          	auipc	s7,0x8
    8000068a:	9d2b8b93          	addi	s7,s7,-1582 # 80008058 <digits>
    switch(c){
    8000068e:	07300c93          	li	s9,115
    80000692:	06400c13          	li	s8,100
    80000696:	a82d                	j	800006d0 <printf+0xa8>
    acquire(&pr.lock);
    80000698:	00011517          	auipc	a0,0x11
    8000069c:	24050513          	addi	a0,a0,576 # 800118d8 <pr>
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	5d4080e7          	jalr	1492(ra) # 80000c74 <acquire>
    800006a8:	bf7d                	j	80000666 <printf+0x3e>
    panic("null fmt");
    800006aa:	00008517          	auipc	a0,0x8
    800006ae:	99e50513          	addi	a0,a0,-1634 # 80008048 <etext+0x48>
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	f24080e7          	jalr	-220(ra) # 800005d6 <panic>
      consputc(c);
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bcc080e7          	jalr	-1076(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800006c2:	2485                	addiw	s1,s1,1
    800006c4:	009a07b3          	add	a5,s4,s1
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	10050763          	beqz	a0,800007da <printf+0x1b2>
    if(c != '%'){
    800006d0:	ff5515e3          	bne	a0,s5,800006ba <printf+0x92>
    c = fmt[++i] & 0xff;
    800006d4:	2485                	addiw	s1,s1,1
    800006d6:	009a07b3          	add	a5,s4,s1
    800006da:	0007c783          	lbu	a5,0(a5)
    800006de:	0007891b          	sext.w	s2,a5
    if(c == 0)
    800006e2:	cfe5                	beqz	a5,800007da <printf+0x1b2>
    switch(c){
    800006e4:	05678a63          	beq	a5,s6,80000738 <printf+0x110>
    800006e8:	02fb7663          	bgeu	s6,a5,80000714 <printf+0xec>
    800006ec:	09978963          	beq	a5,s9,8000077e <printf+0x156>
    800006f0:	07800713          	li	a4,120
    800006f4:	0ce79863          	bne	a5,a4,800007c4 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	4605                	li	a2,1
    80000706:	85ea                	mv	a1,s10
    80000708:	4388                	lw	a0,0(a5)
    8000070a:	00000097          	auipc	ra,0x0
    8000070e:	d9c080e7          	jalr	-612(ra) # 800004a6 <printint>
      break;
    80000712:	bf45                	j	800006c2 <printf+0x9a>
    switch(c){
    80000714:	0b578263          	beq	a5,s5,800007b8 <printf+0x190>
    80000718:	0b879663          	bne	a5,s8,800007c4 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000071c:	f8843783          	ld	a5,-120(s0)
    80000720:	00878713          	addi	a4,a5,8
    80000724:	f8e43423          	sd	a4,-120(s0)
    80000728:	4605                	li	a2,1
    8000072a:	45a9                	li	a1,10
    8000072c:	4388                	lw	a0,0(a5)
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	d78080e7          	jalr	-648(ra) # 800004a6 <printint>
      break;
    80000736:	b771                	j	800006c2 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000738:	f8843783          	ld	a5,-120(s0)
    8000073c:	00878713          	addi	a4,a5,8
    80000740:	f8e43423          	sd	a4,-120(s0)
    80000744:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000748:	03000513          	li	a0,48
    8000074c:	00000097          	auipc	ra,0x0
    80000750:	b3a080e7          	jalr	-1222(ra) # 80000286 <consputc>
  consputc('x');
    80000754:	07800513          	li	a0,120
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	b2e080e7          	jalr	-1234(ra) # 80000286 <consputc>
    80000760:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000762:	03c9d793          	srli	a5,s3,0x3c
    80000766:	97de                	add	a5,a5,s7
    80000768:	0007c503          	lbu	a0,0(a5)
    8000076c:	00000097          	auipc	ra,0x0
    80000770:	b1a080e7          	jalr	-1254(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000774:	0992                	slli	s3,s3,0x4
    80000776:	397d                	addiw	s2,s2,-1
    80000778:	fe0915e3          	bnez	s2,80000762 <printf+0x13a>
    8000077c:	b799                	j	800006c2 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    8000077e:	f8843783          	ld	a5,-120(s0)
    80000782:	00878713          	addi	a4,a5,8
    80000786:	f8e43423          	sd	a4,-120(s0)
    8000078a:	0007b903          	ld	s2,0(a5)
    8000078e:	00090e63          	beqz	s2,800007aa <printf+0x182>
      for(; *s; s++)
    80000792:	00094503          	lbu	a0,0(s2) # 1000 <_entry-0x7ffff000>
    80000796:	d515                	beqz	a0,800006c2 <printf+0x9a>
        consputc(*s);
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	aee080e7          	jalr	-1298(ra) # 80000286 <consputc>
      for(; *s; s++)
    800007a0:	0905                	addi	s2,s2,1
    800007a2:	00094503          	lbu	a0,0(s2)
    800007a6:	f96d                	bnez	a0,80000798 <printf+0x170>
    800007a8:	bf29                	j	800006c2 <printf+0x9a>
        s = "(null)";
    800007aa:	00008917          	auipc	s2,0x8
    800007ae:	89690913          	addi	s2,s2,-1898 # 80008040 <etext+0x40>
      for(; *s; s++)
    800007b2:	02800513          	li	a0,40
    800007b6:	b7cd                	j	80000798 <printf+0x170>
      consputc('%');
    800007b8:	8556                	mv	a0,s5
    800007ba:	00000097          	auipc	ra,0x0
    800007be:	acc080e7          	jalr	-1332(ra) # 80000286 <consputc>
      break;
    800007c2:	b701                	j	800006c2 <printf+0x9a>
      consputc('%');
    800007c4:	8556                	mv	a0,s5
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	ac0080e7          	jalr	-1344(ra) # 80000286 <consputc>
      consputc(c);
    800007ce:	854a                	mv	a0,s2
    800007d0:	00000097          	auipc	ra,0x0
    800007d4:	ab6080e7          	jalr	-1354(ra) # 80000286 <consputc>
      break;
    800007d8:	b5ed                	j	800006c2 <printf+0x9a>
  if(locking)
    800007da:	020d9163          	bnez	s11,800007fc <printf+0x1d4>
}
    800007de:	70e6                	ld	ra,120(sp)
    800007e0:	7446                	ld	s0,112(sp)
    800007e2:	74a6                	ld	s1,104(sp)
    800007e4:	7906                	ld	s2,96(sp)
    800007e6:	69e6                	ld	s3,88(sp)
    800007e8:	6a46                	ld	s4,80(sp)
    800007ea:	6aa6                	ld	s5,72(sp)
    800007ec:	6b06                	ld	s6,64(sp)
    800007ee:	7be2                	ld	s7,56(sp)
    800007f0:	7c42                	ld	s8,48(sp)
    800007f2:	7ca2                	ld	s9,40(sp)
    800007f4:	7d02                	ld	s10,32(sp)
    800007f6:	6de2                	ld	s11,24(sp)
    800007f8:	6129                	addi	sp,sp,192
    800007fa:	8082                	ret
    release(&pr.lock);
    800007fc:	00011517          	auipc	a0,0x11
    80000800:	0dc50513          	addi	a0,a0,220 # 800118d8 <pr>
    80000804:	00000097          	auipc	ra,0x0
    80000808:	524080e7          	jalr	1316(ra) # 80000d28 <release>
}
    8000080c:	bfc9                	j	800007de <printf+0x1b6>

000000008000080e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000080e:	1141                	addi	sp,sp,-16
    80000810:	e406                	sd	ra,8(sp)
    80000812:	e022                	sd	s0,0(sp)
    80000814:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000081e:	f8000713          	li	a4,-128
    80000822:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000826:	470d                	li	a4,3
    80000828:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000082c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000830:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000834:	469d                	li	a3,7
    80000836:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000083a:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000083e:	00008597          	auipc	a1,0x8
    80000842:	83258593          	addi	a1,a1,-1998 # 80008070 <digits+0x18>
    80000846:	00011517          	auipc	a0,0x11
    8000084a:	0b250513          	addi	a0,a0,178 # 800118f8 <uart_tx_lock>
    8000084e:	00000097          	auipc	ra,0x0
    80000852:	396080e7          	jalr	918(ra) # 80000be4 <initlock>
}
    80000856:	60a2                	ld	ra,8(sp)
    80000858:	6402                	ld	s0,0(sp)
    8000085a:	0141                	addi	sp,sp,16
    8000085c:	8082                	ret

000000008000085e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000085e:	1101                	addi	sp,sp,-32
    80000860:	ec06                	sd	ra,24(sp)
    80000862:	e822                	sd	s0,16(sp)
    80000864:	e426                	sd	s1,8(sp)
    80000866:	1000                	addi	s0,sp,32
    80000868:	84aa                	mv	s1,a0
  push_off();
    8000086a:	00000097          	auipc	ra,0x0
    8000086e:	3be080e7          	jalr	958(ra) # 80000c28 <push_off>

  if(panicked){
    80000872:	00008797          	auipc	a5,0x8
    80000876:	78e7a783          	lw	a5,1934(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000087a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000087e:	c391                	beqz	a5,80000882 <uartputc_sync+0x24>
    for(;;)
    80000880:	a001                	j	80000880 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000882:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000886:	0ff7f793          	andi	a5,a5,255
    8000088a:	0207f793          	andi	a5,a5,32
    8000088e:	dbf5                	beqz	a5,80000882 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000890:	0ff4f793          	andi	a5,s1,255
    80000894:	10000737          	lui	a4,0x10000
    80000898:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000089c:	00000097          	auipc	ra,0x0
    800008a0:	42c080e7          	jalr	1068(ra) # 80000cc8 <pop_off>
}
    800008a4:	60e2                	ld	ra,24(sp)
    800008a6:	6442                	ld	s0,16(sp)
    800008a8:	64a2                	ld	s1,8(sp)
    800008aa:	6105                	addi	sp,sp,32
    800008ac:	8082                	ret

00000000800008ae <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008ae:	00008797          	auipc	a5,0x8
    800008b2:	7567a783          	lw	a5,1878(a5) # 80009004 <uart_tx_r>
    800008b6:	00008717          	auipc	a4,0x8
    800008ba:	75272703          	lw	a4,1874(a4) # 80009008 <uart_tx_w>
    800008be:	08f70263          	beq	a4,a5,80000942 <uartstart+0x94>
{
    800008c2:	7139                	addi	sp,sp,-64
    800008c4:	fc06                	sd	ra,56(sp)
    800008c6:	f822                	sd	s0,48(sp)
    800008c8:	f426                	sd	s1,40(sp)
    800008ca:	f04a                	sd	s2,32(sp)
    800008cc:	ec4e                	sd	s3,24(sp)
    800008ce:	e852                	sd	s4,16(sp)
    800008d0:	e456                	sd	s5,8(sp)
    800008d2:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d4:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    800008d8:	00011a17          	auipc	s4,0x11
    800008dc:	020a0a13          	addi	s4,s4,32 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008e0:	00008497          	auipc	s1,0x8
    800008e4:	72448493          	addi	s1,s1,1828 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800008e8:	00008997          	auipc	s3,0x8
    800008ec:	72098993          	addi	s3,s3,1824 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008f0:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    800008f4:	0ff77713          	andi	a4,a4,255
    800008f8:	02077713          	andi	a4,a4,32
    800008fc:	cb15                	beqz	a4,80000930 <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    800008fe:	00fa0733          	add	a4,s4,a5
    80000902:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000906:	2785                	addiw	a5,a5,1
    80000908:	41f7d71b          	sraiw	a4,a5,0x1f
    8000090c:	01b7571b          	srliw	a4,a4,0x1b
    80000910:	9fb9                	addw	a5,a5,a4
    80000912:	8bfd                	andi	a5,a5,31
    80000914:	9f99                	subw	a5,a5,a4
    80000916:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	ae4080e7          	jalr	-1308(ra) # 800023fe <wakeup>
    
    WriteReg(THR, c);
    80000922:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80000926:	409c                	lw	a5,0(s1)
    80000928:	0009a703          	lw	a4,0(s3)
    8000092c:	fcf712e3          	bne	a4,a5,800008f0 <uartstart+0x42>
  }
}
    80000930:	70e2                	ld	ra,56(sp)
    80000932:	7442                	ld	s0,48(sp)
    80000934:	74a2                	ld	s1,40(sp)
    80000936:	7902                	ld	s2,32(sp)
    80000938:	69e2                	ld	s3,24(sp)
    8000093a:	6a42                	ld	s4,16(sp)
    8000093c:	6aa2                	ld	s5,8(sp)
    8000093e:	6121                	addi	sp,sp,64
    80000940:	8082                	ret
    80000942:	8082                	ret

0000000080000944 <uartputc>:
{
    80000944:	7179                	addi	sp,sp,-48
    80000946:	f406                	sd	ra,40(sp)
    80000948:	f022                	sd	s0,32(sp)
    8000094a:	ec26                	sd	s1,24(sp)
    8000094c:	e84a                	sd	s2,16(sp)
    8000094e:	e44e                	sd	s3,8(sp)
    80000950:	e052                	sd	s4,0(sp)
    80000952:	1800                	addi	s0,sp,48
    80000954:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80000956:	00011517          	auipc	a0,0x11
    8000095a:	fa250513          	addi	a0,a0,-94 # 800118f8 <uart_tx_lock>
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	316080e7          	jalr	790(ra) # 80000c74 <acquire>
  if(panicked){
    80000966:	00008797          	auipc	a5,0x8
    8000096a:	69a7a783          	lw	a5,1690(a5) # 80009000 <panicked>
    8000096e:	c391                	beqz	a5,80000972 <uartputc+0x2e>
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000972:	00008717          	auipc	a4,0x8
    80000976:	69672703          	lw	a4,1686(a4) # 80009008 <uart_tx_w>
    8000097a:	0017079b          	addiw	a5,a4,1
    8000097e:	41f7d69b          	sraiw	a3,a5,0x1f
    80000982:	01b6d69b          	srliw	a3,a3,0x1b
    80000986:	9fb5                	addw	a5,a5,a3
    80000988:	8bfd                	andi	a5,a5,31
    8000098a:	9f95                	subw	a5,a5,a3
    8000098c:	00008697          	auipc	a3,0x8
    80000990:	6786a683          	lw	a3,1656(a3) # 80009004 <uart_tx_r>
    80000994:	04f69263          	bne	a3,a5,800009d8 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000998:	00011a17          	auipc	s4,0x11
    8000099c:	f60a0a13          	addi	s4,s4,-160 # 800118f8 <uart_tx_lock>
    800009a0:	00008497          	auipc	s1,0x8
    800009a4:	66448493          	addi	s1,s1,1636 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009a8:	00008917          	auipc	s2,0x8
    800009ac:	66090913          	addi	s2,s2,1632 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    800009b0:	85d2                	mv	a1,s4
    800009b2:	8526                	mv	a0,s1
    800009b4:	00002097          	auipc	ra,0x2
    800009b8:	8c4080e7          	jalr	-1852(ra) # 80002278 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009bc:	00092703          	lw	a4,0(s2)
    800009c0:	0017079b          	addiw	a5,a4,1
    800009c4:	41f7d69b          	sraiw	a3,a5,0x1f
    800009c8:	01b6d69b          	srliw	a3,a3,0x1b
    800009cc:	9fb5                	addw	a5,a5,a3
    800009ce:	8bfd                	andi	a5,a5,31
    800009d0:	9f95                	subw	a5,a5,a3
    800009d2:	4094                	lw	a3,0(s1)
    800009d4:	fcf68ee3          	beq	a3,a5,800009b0 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    800009d8:	00011497          	auipc	s1,0x11
    800009dc:	f2048493          	addi	s1,s1,-224 # 800118f8 <uart_tx_lock>
    800009e0:	9726                	add	a4,a4,s1
    800009e2:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    800009e6:	00008717          	auipc	a4,0x8
    800009ea:	62f72123          	sw	a5,1570(a4) # 80009008 <uart_tx_w>
      uartstart();
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	ec0080e7          	jalr	-320(ra) # 800008ae <uartstart>
      release(&uart_tx_lock);
    800009f6:	8526                	mv	a0,s1
    800009f8:	00000097          	auipc	ra,0x0
    800009fc:	330080e7          	jalr	816(ra) # 80000d28 <release>
}
    80000a00:	70a2                	ld	ra,40(sp)
    80000a02:	7402                	ld	s0,32(sp)
    80000a04:	64e2                	ld	s1,24(sp)
    80000a06:	6942                	ld	s2,16(sp)
    80000a08:	69a2                	ld	s3,8(sp)
    80000a0a:	6a02                	ld	s4,0(sp)
    80000a0c:	6145                	addi	sp,sp,48
    80000a0e:	8082                	ret

0000000080000a10 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a10:	1141                	addi	sp,sp,-16
    80000a12:	e422                	sd	s0,8(sp)
    80000a14:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a16:	100007b7          	lui	a5,0x10000
    80000a1a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1e:	8b85                	andi	a5,a5,1
    80000a20:	cb91                	beqz	a5,80000a34 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a22:	100007b7          	lui	a5,0x10000
    80000a26:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a2a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a2e:	6422                	ld	s0,8(sp)
    80000a30:	0141                	addi	sp,sp,16
    80000a32:	8082                	ret
    return -1;
    80000a34:	557d                	li	a0,-1
    80000a36:	bfe5                	j	80000a2e <uartgetc+0x1e>

0000000080000a38 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a38:	1101                	addi	sp,sp,-32
    80000a3a:	ec06                	sd	ra,24(sp)
    80000a3c:	e822                	sd	s0,16(sp)
    80000a3e:	e426                	sd	s1,8(sp)
    80000a40:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a42:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	fcc080e7          	jalr	-52(ra) # 80000a10 <uartgetc>
    if(c == -1)
    80000a4c:	00950763          	beq	a0,s1,80000a5a <uartintr+0x22>
      break;
    consoleintr(c);
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	878080e7          	jalr	-1928(ra) # 800002c8 <consoleintr>
  while(1){
    80000a58:	b7f5                	j	80000a44 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a5a:	00011497          	auipc	s1,0x11
    80000a5e:	e9e48493          	addi	s1,s1,-354 # 800118f8 <uart_tx_lock>
    80000a62:	8526                	mv	a0,s1
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	210080e7          	jalr	528(ra) # 80000c74 <acquire>
  uartstart();
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	e42080e7          	jalr	-446(ra) # 800008ae <uartstart>
  release(&uart_tx_lock);
    80000a74:	8526                	mv	a0,s1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2b2080e7          	jalr	690(ra) # 80000d28 <release>
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6105                	addi	sp,sp,32
    80000a86:	8082                	ret

0000000080000a88 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a88:	1101                	addi	sp,sp,-32
    80000a8a:	ec06                	sd	ra,24(sp)
    80000a8c:	e822                	sd	s0,16(sp)
    80000a8e:	e426                	sd	s1,8(sp)
    80000a90:	e04a                	sd	s2,0(sp)
    80000a92:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a94:	03451793          	slli	a5,a0,0x34
    80000a98:	ebb9                	bnez	a5,80000aee <kfree+0x66>
    80000a9a:	84aa                	mv	s1,a0
    80000a9c:	00026797          	auipc	a5,0x26
    80000aa0:	56478793          	addi	a5,a5,1380 # 80027000 <end>
    80000aa4:	04f56563          	bltu	a0,a5,80000aee <kfree+0x66>
    80000aa8:	47c5                	li	a5,17
    80000aaa:	07ee                	slli	a5,a5,0x1b
    80000aac:	04f57163          	bgeu	a0,a5,80000aee <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000ab0:	6605                	lui	a2,0x1
    80000ab2:	4585                	li	a1,1
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	2bc080e7          	jalr	700(ra) # 80000d70 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000abc:	00011917          	auipc	s2,0x11
    80000ac0:	e7490913          	addi	s2,s2,-396 # 80011930 <kmem>
    80000ac4:	854a                	mv	a0,s2
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	1ae080e7          	jalr	430(ra) # 80000c74 <acquire>
  r->next = kmem.freelist;
    80000ace:	01893783          	ld	a5,24(s2)
    80000ad2:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ad4:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ad8:	854a                	mv	a0,s2
    80000ada:	00000097          	auipc	ra,0x0
    80000ade:	24e080e7          	jalr	590(ra) # 80000d28 <release>
}
    80000ae2:	60e2                	ld	ra,24(sp)
    80000ae4:	6442                	ld	s0,16(sp)
    80000ae6:	64a2                	ld	s1,8(sp)
    80000ae8:	6902                	ld	s2,0(sp)
    80000aea:	6105                	addi	sp,sp,32
    80000aec:	8082                	ret
    panic("kfree");
    80000aee:	00007517          	auipc	a0,0x7
    80000af2:	58a50513          	addi	a0,a0,1418 # 80008078 <digits+0x20>
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	ae0080e7          	jalr	-1312(ra) # 800005d6 <panic>

0000000080000afe <freerange>:
{
    80000afe:	7179                	addi	sp,sp,-48
    80000b00:	f406                	sd	ra,40(sp)
    80000b02:	f022                	sd	s0,32(sp)
    80000b04:	ec26                	sd	s1,24(sp)
    80000b06:	e84a                	sd	s2,16(sp)
    80000b08:	e44e                	sd	s3,8(sp)
    80000b0a:	e052                	sd	s4,0(sp)
    80000b0c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b0e:	6785                	lui	a5,0x1
    80000b10:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b14:	94aa                	add	s1,s1,a0
    80000b16:	757d                	lui	a0,0xfffff
    80000b18:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b1a:	94be                	add	s1,s1,a5
    80000b1c:	0095ee63          	bltu	a1,s1,80000b38 <freerange+0x3a>
    80000b20:	892e                	mv	s2,a1
    kfree(p);
    80000b22:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b24:	6985                	lui	s3,0x1
    kfree(p);
    80000b26:	01448533          	add	a0,s1,s4
    80000b2a:	00000097          	auipc	ra,0x0
    80000b2e:	f5e080e7          	jalr	-162(ra) # 80000a88 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b32:	94ce                	add	s1,s1,s3
    80000b34:	fe9979e3          	bgeu	s2,s1,80000b26 <freerange+0x28>
}
    80000b38:	70a2                	ld	ra,40(sp)
    80000b3a:	7402                	ld	s0,32(sp)
    80000b3c:	64e2                	ld	s1,24(sp)
    80000b3e:	6942                	ld	s2,16(sp)
    80000b40:	69a2                	ld	s3,8(sp)
    80000b42:	6a02                	ld	s4,0(sp)
    80000b44:	6145                	addi	sp,sp,48
    80000b46:	8082                	ret

0000000080000b48 <kinit>:
{
    80000b48:	1141                	addi	sp,sp,-16
    80000b4a:	e406                	sd	ra,8(sp)
    80000b4c:	e022                	sd	s0,0(sp)
    80000b4e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b50:	00007597          	auipc	a1,0x7
    80000b54:	53058593          	addi	a1,a1,1328 # 80008080 <digits+0x28>
    80000b58:	00011517          	auipc	a0,0x11
    80000b5c:	dd850513          	addi	a0,a0,-552 # 80011930 <kmem>
    80000b60:	00000097          	auipc	ra,0x0
    80000b64:	084080e7          	jalr	132(ra) # 80000be4 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b68:	45c5                	li	a1,17
    80000b6a:	05ee                	slli	a1,a1,0x1b
    80000b6c:	00026517          	auipc	a0,0x26
    80000b70:	49450513          	addi	a0,a0,1172 # 80027000 <end>
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	f8a080e7          	jalr	-118(ra) # 80000afe <freerange>
}
    80000b7c:	60a2                	ld	ra,8(sp)
    80000b7e:	6402                	ld	s0,0(sp)
    80000b80:	0141                	addi	sp,sp,16
    80000b82:	8082                	ret

0000000080000b84 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b8e:	00011497          	auipc	s1,0x11
    80000b92:	da248493          	addi	s1,s1,-606 # 80011930 <kmem>
    80000b96:	8526                	mv	a0,s1
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	0dc080e7          	jalr	220(ra) # 80000c74 <acquire>
  r = kmem.freelist;
    80000ba0:	6c84                	ld	s1,24(s1)
  if(r)
    80000ba2:	c885                	beqz	s1,80000bd2 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000ba4:	609c                	ld	a5,0(s1)
    80000ba6:	00011517          	auipc	a0,0x11
    80000baa:	d8a50513          	addi	a0,a0,-630 # 80011930 <kmem>
    80000bae:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	178080e7          	jalr	376(ra) # 80000d28 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bb8:	6605                	lui	a2,0x1
    80000bba:	4595                	li	a1,5
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	00000097          	auipc	ra,0x0
    80000bc2:	1b2080e7          	jalr	434(ra) # 80000d70 <memset>
  return (void*)r;
}
    80000bc6:	8526                	mv	a0,s1
    80000bc8:	60e2                	ld	ra,24(sp)
    80000bca:	6442                	ld	s0,16(sp)
    80000bcc:	64a2                	ld	s1,8(sp)
    80000bce:	6105                	addi	sp,sp,32
    80000bd0:	8082                	ret
  release(&kmem.lock);
    80000bd2:	00011517          	auipc	a0,0x11
    80000bd6:	d5e50513          	addi	a0,a0,-674 # 80011930 <kmem>
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	14e080e7          	jalr	334(ra) # 80000d28 <release>
  if(r)
    80000be2:	b7d5                	j	80000bc6 <kalloc+0x42>

0000000080000be4 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000be4:	1141                	addi	sp,sp,-16
    80000be6:	e422                	sd	s0,8(sp)
    80000be8:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bea:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bec:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bf0:	00053823          	sd	zero,16(a0)
}
    80000bf4:	6422                	ld	s0,8(sp)
    80000bf6:	0141                	addi	sp,sp,16
    80000bf8:	8082                	ret

0000000080000bfa <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bfa:	411c                	lw	a5,0(a0)
    80000bfc:	e399                	bnez	a5,80000c02 <holding+0x8>
    80000bfe:	4501                	li	a0,0
  return r;
}
    80000c00:	8082                	ret
{
    80000c02:	1101                	addi	sp,sp,-32
    80000c04:	ec06                	sd	ra,24(sp)
    80000c06:	e822                	sd	s0,16(sp)
    80000c08:	e426                	sd	s1,8(sp)
    80000c0a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c0c:	6904                	ld	s1,16(a0)
    80000c0e:	00001097          	auipc	ra,0x1
    80000c12:	e18080e7          	jalr	-488(ra) # 80001a26 <mycpu>
    80000c16:	40a48533          	sub	a0,s1,a0
    80000c1a:	00153513          	seqz	a0,a0
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret

0000000080000c28 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c32:	100024f3          	csrr	s1,sstatus
    80000c36:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c3a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c3c:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	de6080e7          	jalr	-538(ra) # 80001a26 <mycpu>
    80000c48:	5d3c                	lw	a5,120(a0)
    80000c4a:	cf89                	beqz	a5,80000c64 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c4c:	00001097          	auipc	ra,0x1
    80000c50:	dda080e7          	jalr	-550(ra) # 80001a26 <mycpu>
    80000c54:	5d3c                	lw	a5,120(a0)
    80000c56:	2785                	addiw	a5,a5,1
    80000c58:	dd3c                	sw	a5,120(a0)
}
    80000c5a:	60e2                	ld	ra,24(sp)
    80000c5c:	6442                	ld	s0,16(sp)
    80000c5e:	64a2                	ld	s1,8(sp)
    80000c60:	6105                	addi	sp,sp,32
    80000c62:	8082                	ret
    mycpu()->intena = old;
    80000c64:	00001097          	auipc	ra,0x1
    80000c68:	dc2080e7          	jalr	-574(ra) # 80001a26 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c6c:	8085                	srli	s1,s1,0x1
    80000c6e:	8885                	andi	s1,s1,1
    80000c70:	dd64                	sw	s1,124(a0)
    80000c72:	bfe9                	j	80000c4c <push_off+0x24>

0000000080000c74 <acquire>:
{
    80000c74:	1101                	addi	sp,sp,-32
    80000c76:	ec06                	sd	ra,24(sp)
    80000c78:	e822                	sd	s0,16(sp)
    80000c7a:	e426                	sd	s1,8(sp)
    80000c7c:	1000                	addi	s0,sp,32
    80000c7e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	fa8080e7          	jalr	-88(ra) # 80000c28 <push_off>
  if(holding(lk))
    80000c88:	8526                	mv	a0,s1
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	f70080e7          	jalr	-144(ra) # 80000bfa <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c92:	4705                	li	a4,1
  if(holding(lk))
    80000c94:	e115                	bnez	a0,80000cb8 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c96:	87ba                	mv	a5,a4
    80000c98:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c9c:	2781                	sext.w	a5,a5
    80000c9e:	ffe5                	bnez	a5,80000c96 <acquire+0x22>
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000ca4:	00001097          	auipc	ra,0x1
    80000ca8:	d82080e7          	jalr	-638(ra) # 80001a26 <mycpu>
    80000cac:	e888                	sd	a0,16(s1)
}
    80000cae:	60e2                	ld	ra,24(sp)
    80000cb0:	6442                	ld	s0,16(sp)
    80000cb2:	64a2                	ld	s1,8(sp)
    80000cb4:	6105                	addi	sp,sp,32
    80000cb6:	8082                	ret
    panic("acquire");
    80000cb8:	00007517          	auipc	a0,0x7
    80000cbc:	3d050513          	addi	a0,a0,976 # 80008088 <digits+0x30>
    80000cc0:	00000097          	auipc	ra,0x0
    80000cc4:	916080e7          	jalr	-1770(ra) # 800005d6 <panic>

0000000080000cc8 <pop_off>:

void
pop_off(void)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e406                	sd	ra,8(sp)
    80000ccc:	e022                	sd	s0,0(sp)
    80000cce:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cd0:	00001097          	auipc	ra,0x1
    80000cd4:	d56080e7          	jalr	-682(ra) # 80001a26 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cdc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cde:	e78d                	bnez	a5,80000d08 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ce0:	5d3c                	lw	a5,120(a0)
    80000ce2:	02f05b63          	blez	a5,80000d18 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000ce6:	37fd                	addiw	a5,a5,-1
    80000ce8:	0007871b          	sext.w	a4,a5
    80000cec:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cee:	eb09                	bnez	a4,80000d00 <pop_off+0x38>
    80000cf0:	5d7c                	lw	a5,124(a0)
    80000cf2:	c799                	beqz	a5,80000d00 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cf8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cfc:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d00:	60a2                	ld	ra,8(sp)
    80000d02:	6402                	ld	s0,0(sp)
    80000d04:	0141                	addi	sp,sp,16
    80000d06:	8082                	ret
    panic("pop_off - interruptible");
    80000d08:	00007517          	auipc	a0,0x7
    80000d0c:	38850513          	addi	a0,a0,904 # 80008090 <digits+0x38>
    80000d10:	00000097          	auipc	ra,0x0
    80000d14:	8c6080e7          	jalr	-1850(ra) # 800005d6 <panic>
    panic("pop_off");
    80000d18:	00007517          	auipc	a0,0x7
    80000d1c:	39050513          	addi	a0,a0,912 # 800080a8 <digits+0x50>
    80000d20:	00000097          	auipc	ra,0x0
    80000d24:	8b6080e7          	jalr	-1866(ra) # 800005d6 <panic>

0000000080000d28 <release>:
{
    80000d28:	1101                	addi	sp,sp,-32
    80000d2a:	ec06                	sd	ra,24(sp)
    80000d2c:	e822                	sd	s0,16(sp)
    80000d2e:	e426                	sd	s1,8(sp)
    80000d30:	1000                	addi	s0,sp,32
    80000d32:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d34:	00000097          	auipc	ra,0x0
    80000d38:	ec6080e7          	jalr	-314(ra) # 80000bfa <holding>
    80000d3c:	c115                	beqz	a0,80000d60 <release+0x38>
  lk->cpu = 0;
    80000d3e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d42:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d46:	0f50000f          	fence	iorw,ow
    80000d4a:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d4e:	00000097          	auipc	ra,0x0
    80000d52:	f7a080e7          	jalr	-134(ra) # 80000cc8 <pop_off>
}
    80000d56:	60e2                	ld	ra,24(sp)
    80000d58:	6442                	ld	s0,16(sp)
    80000d5a:	64a2                	ld	s1,8(sp)
    80000d5c:	6105                	addi	sp,sp,32
    80000d5e:	8082                	ret
    panic("release");
    80000d60:	00007517          	auipc	a0,0x7
    80000d64:	35050513          	addi	a0,a0,848 # 800080b0 <digits+0x58>
    80000d68:	00000097          	auipc	ra,0x0
    80000d6c:	86e080e7          	jalr	-1938(ra) # 800005d6 <panic>

0000000080000d70 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d70:	1141                	addi	sp,sp,-16
    80000d72:	e422                	sd	s0,8(sp)
    80000d74:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d76:	ce09                	beqz	a2,80000d90 <memset+0x20>
    80000d78:	87aa                	mv	a5,a0
    80000d7a:	fff6071b          	addiw	a4,a2,-1
    80000d7e:	1702                	slli	a4,a4,0x20
    80000d80:	9301                	srli	a4,a4,0x20
    80000d82:	0705                	addi	a4,a4,1
    80000d84:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d86:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d8a:	0785                	addi	a5,a5,1
    80000d8c:	fee79de3          	bne	a5,a4,80000d86 <memset+0x16>
  }
  return dst;
}
    80000d90:	6422                	ld	s0,8(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d9c:	ca05                	beqz	a2,80000dcc <memcmp+0x36>
    80000d9e:	fff6069b          	addiw	a3,a2,-1
    80000da2:	1682                	slli	a3,a3,0x20
    80000da4:	9281                	srli	a3,a3,0x20
    80000da6:	0685                	addi	a3,a3,1
    80000da8:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	0005c703          	lbu	a4,0(a1)
    80000db2:	00e79863          	bne	a5,a4,80000dc2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dba:	fed518e3          	bne	a0,a3,80000daa <memcmp+0x14>
  }

  return 0;
    80000dbe:	4501                	li	a0,0
    80000dc0:	a019                	j	80000dc6 <memcmp+0x30>
      return *s1 - *s2;
    80000dc2:	40e7853b          	subw	a0,a5,a4
}
    80000dc6:	6422                	ld	s0,8(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret
  return 0;
    80000dcc:	4501                	li	a0,0
    80000dce:	bfe5                	j	80000dc6 <memcmp+0x30>

0000000080000dd0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dd0:	1141                	addi	sp,sp,-16
    80000dd2:	e422                	sd	s0,8(sp)
    80000dd4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dd6:	00a5f963          	bgeu	a1,a0,80000de8 <memmove+0x18>
    80000dda:	02061713          	slli	a4,a2,0x20
    80000dde:	9301                	srli	a4,a4,0x20
    80000de0:	00e587b3          	add	a5,a1,a4
    80000de4:	02f56563          	bltu	a0,a5,80000e0e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000de8:	fff6069b          	addiw	a3,a2,-1
    80000dec:	ce11                	beqz	a2,80000e08 <memmove+0x38>
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	0685                	addi	a3,a3,1
    80000df4:	96ae                	add	a3,a3,a1
    80000df6:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	0785                	addi	a5,a5,1
    80000dfc:	fff5c703          	lbu	a4,-1(a1)
    80000e00:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e04:	fed59ae3          	bne	a1,a3,80000df8 <memmove+0x28>

  return dst;
}
    80000e08:	6422                	ld	s0,8(sp)
    80000e0a:	0141                	addi	sp,sp,16
    80000e0c:	8082                	ret
    d += n;
    80000e0e:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	da75                	beqz	a2,80000e08 <memmove+0x38>
    80000e16:	02069613          	slli	a2,a3,0x20
    80000e1a:	9201                	srli	a2,a2,0x20
    80000e1c:	fff64613          	not	a2,a2
    80000e20:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e22:	17fd                	addi	a5,a5,-1
    80000e24:	177d                	addi	a4,a4,-1
    80000e26:	0007c683          	lbu	a3,0(a5)
    80000e2a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e2e:	fec79ae3          	bne	a5,a2,80000e22 <memmove+0x52>
    80000e32:	bfd9                	j	80000e08 <memmove+0x38>

0000000080000e34 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e34:	1141                	addi	sp,sp,-16
    80000e36:	e406                	sd	ra,8(sp)
    80000e38:	e022                	sd	s0,0(sp)
    80000e3a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e3c:	00000097          	auipc	ra,0x0
    80000e40:	f94080e7          	jalr	-108(ra) # 80000dd0 <memmove>
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e422                	sd	s0,8(sp)
    80000e50:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e52:	ce11                	beqz	a2,80000e6e <strncmp+0x22>
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf89                	beqz	a5,80000e72 <strncmp+0x26>
    80000e5a:	0005c703          	lbu	a4,0(a1)
    80000e5e:	00f71a63          	bne	a4,a5,80000e72 <strncmp+0x26>
    n--, p++, q++;
    80000e62:	367d                	addiw	a2,a2,-1
    80000e64:	0505                	addi	a0,a0,1
    80000e66:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e68:	f675                	bnez	a2,80000e54 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e6a:	4501                	li	a0,0
    80000e6c:	a809                	j	80000e7e <strncmp+0x32>
    80000e6e:	4501                	li	a0,0
    80000e70:	a039                	j	80000e7e <strncmp+0x32>
  if(n == 0)
    80000e72:	ca09                	beqz	a2,80000e84 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e74:	00054503          	lbu	a0,0(a0)
    80000e78:	0005c783          	lbu	a5,0(a1)
    80000e7c:	9d1d                	subw	a0,a0,a5
}
    80000e7e:	6422                	ld	s0,8(sp)
    80000e80:	0141                	addi	sp,sp,16
    80000e82:	8082                	ret
    return 0;
    80000e84:	4501                	li	a0,0
    80000e86:	bfe5                	j	80000e7e <strncmp+0x32>

0000000080000e88 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e88:	1141                	addi	sp,sp,-16
    80000e8a:	e422                	sd	s0,8(sp)
    80000e8c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e8e:	872a                	mv	a4,a0
    80000e90:	8832                	mv	a6,a2
    80000e92:	367d                	addiw	a2,a2,-1
    80000e94:	01005963          	blez	a6,80000ea6 <strncpy+0x1e>
    80000e98:	0705                	addi	a4,a4,1
    80000e9a:	0005c783          	lbu	a5,0(a1)
    80000e9e:	fef70fa3          	sb	a5,-1(a4)
    80000ea2:	0585                	addi	a1,a1,1
    80000ea4:	f7f5                	bnez	a5,80000e90 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ea6:	00c05d63          	blez	a2,80000ec0 <strncpy+0x38>
    80000eaa:	86ba                	mv	a3,a4
    *s++ = 0;
    80000eac:	0685                	addi	a3,a3,1
    80000eae:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000eb2:	fff6c793          	not	a5,a3
    80000eb6:	9fb9                	addw	a5,a5,a4
    80000eb8:	010787bb          	addw	a5,a5,a6
    80000ebc:	fef048e3          	bgtz	a5,80000eac <strncpy+0x24>
  return os;
}
    80000ec0:	6422                	ld	s0,8(sp)
    80000ec2:	0141                	addi	sp,sp,16
    80000ec4:	8082                	ret

0000000080000ec6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ec6:	1141                	addi	sp,sp,-16
    80000ec8:	e422                	sd	s0,8(sp)
    80000eca:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ecc:	02c05363          	blez	a2,80000ef2 <safestrcpy+0x2c>
    80000ed0:	fff6069b          	addiw	a3,a2,-1
    80000ed4:	1682                	slli	a3,a3,0x20
    80000ed6:	9281                	srli	a3,a3,0x20
    80000ed8:	96ae                	add	a3,a3,a1
    80000eda:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000edc:	00d58963          	beq	a1,a3,80000eee <safestrcpy+0x28>
    80000ee0:	0585                	addi	a1,a1,1
    80000ee2:	0785                	addi	a5,a5,1
    80000ee4:	fff5c703          	lbu	a4,-1(a1)
    80000ee8:	fee78fa3          	sb	a4,-1(a5)
    80000eec:	fb65                	bnez	a4,80000edc <safestrcpy+0x16>
    ;
  *s = 0;
    80000eee:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ef2:	6422                	ld	s0,8(sp)
    80000ef4:	0141                	addi	sp,sp,16
    80000ef6:	8082                	ret

0000000080000ef8 <strlen>:

int
strlen(const char *s)
{
    80000ef8:	1141                	addi	sp,sp,-16
    80000efa:	e422                	sd	s0,8(sp)
    80000efc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000efe:	00054783          	lbu	a5,0(a0)
    80000f02:	cf91                	beqz	a5,80000f1e <strlen+0x26>
    80000f04:	0505                	addi	a0,a0,1
    80000f06:	87aa                	mv	a5,a0
    80000f08:	4685                	li	a3,1
    80000f0a:	9e89                	subw	a3,a3,a0
    80000f0c:	00f6853b          	addw	a0,a3,a5
    80000f10:	0785                	addi	a5,a5,1
    80000f12:	fff7c703          	lbu	a4,-1(a5)
    80000f16:	fb7d                	bnez	a4,80000f0c <strlen+0x14>
    ;
  return n;
}
    80000f18:	6422                	ld	s0,8(sp)
    80000f1a:	0141                	addi	sp,sp,16
    80000f1c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f1e:	4501                	li	a0,0
    80000f20:	bfe5                	j	80000f18 <strlen+0x20>

0000000080000f22 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f22:	1141                	addi	sp,sp,-16
    80000f24:	e406                	sd	ra,8(sp)
    80000f26:	e022                	sd	s0,0(sp)
    80000f28:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f2a:	00001097          	auipc	ra,0x1
    80000f2e:	aec080e7          	jalr	-1300(ra) # 80001a16 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f32:	00008717          	auipc	a4,0x8
    80000f36:	0da70713          	addi	a4,a4,218 # 8000900c <started>
  if(cpuid() == 0){
    80000f3a:	c139                	beqz	a0,80000f80 <main+0x5e>
    while(started == 0)
    80000f3c:	431c                	lw	a5,0(a4)
    80000f3e:	2781                	sext.w	a5,a5
    80000f40:	dff5                	beqz	a5,80000f3c <main+0x1a>
      ;
    __sync_synchronize();
    80000f42:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	ad0080e7          	jalr	-1328(ra) # 80001a16 <cpuid>
    80000f4e:	85aa                	mv	a1,a0
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	18050513          	addi	a0,a0,384 # 800080d0 <digits+0x78>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	6d0080e7          	jalr	1744(ra) # 80000628 <printf>
    kvminithart();    // turn on paging
    80000f60:	00000097          	auipc	ra,0x0
    80000f64:	0d8080e7          	jalr	216(ra) # 80001038 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f68:	00001097          	auipc	ra,0x1
    80000f6c:	75e080e7          	jalr	1886(ra) # 800026c6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f70:	00005097          	auipc	ra,0x5
    80000f74:	df0080e7          	jalr	-528(ra) # 80005d60 <plicinithart>
  }

  scheduler();        
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	024080e7          	jalr	36(ra) # 80001f9c <scheduler>
    consoleinit();
    80000f80:	fffff097          	auipc	ra,0xfffff
    80000f84:	4da080e7          	jalr	1242(ra) # 8000045a <consoleinit>
    printfinit();
    80000f88:	fffff097          	auipc	ra,0xfffff
    80000f8c:	5c0080e7          	jalr	1472(ra) # 80000548 <printfinit>
    printf("\n");
    80000f90:	00007517          	auipc	a0,0x7
    80000f94:	15050513          	addi	a0,a0,336 # 800080e0 <digits+0x88>
    80000f98:	fffff097          	auipc	ra,0xfffff
    80000f9c:	690080e7          	jalr	1680(ra) # 80000628 <printf>
    printf("xv6 kernel is booting\n");
    80000fa0:	00007517          	auipc	a0,0x7
    80000fa4:	11850513          	addi	a0,a0,280 # 800080b8 <digits+0x60>
    80000fa8:	fffff097          	auipc	ra,0xfffff
    80000fac:	680080e7          	jalr	1664(ra) # 80000628 <printf>
    printf("\n");
    80000fb0:	00007517          	auipc	a0,0x7
    80000fb4:	13050513          	addi	a0,a0,304 # 800080e0 <digits+0x88>
    80000fb8:	fffff097          	auipc	ra,0xfffff
    80000fbc:	670080e7          	jalr	1648(ra) # 80000628 <printf>
    kinit();         // physical page allocator
    80000fc0:	00000097          	auipc	ra,0x0
    80000fc4:	b88080e7          	jalr	-1144(ra) # 80000b48 <kinit>
    kvminit();       // create kernel page table
    80000fc8:	00000097          	auipc	ra,0x0
    80000fcc:	2a0080e7          	jalr	672(ra) # 80001268 <kvminit>
    kvminithart();   // turn on paging
    80000fd0:	00000097          	auipc	ra,0x0
    80000fd4:	068080e7          	jalr	104(ra) # 80001038 <kvminithart>
    procinit();      // process table
    80000fd8:	00001097          	auipc	ra,0x1
    80000fdc:	96e080e7          	jalr	-1682(ra) # 80001946 <procinit>
    trapinit();      // trap vectors
    80000fe0:	00001097          	auipc	ra,0x1
    80000fe4:	6be080e7          	jalr	1726(ra) # 8000269e <trapinit>
    trapinithart();  // install kernel trap vector
    80000fe8:	00001097          	auipc	ra,0x1
    80000fec:	6de080e7          	jalr	1758(ra) # 800026c6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ff0:	00005097          	auipc	ra,0x5
    80000ff4:	d5a080e7          	jalr	-678(ra) # 80005d4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ff8:	00005097          	auipc	ra,0x5
    80000ffc:	d68080e7          	jalr	-664(ra) # 80005d60 <plicinithart>
    binit();         // buffer cache
    80001000:	00002097          	auipc	ra,0x2
    80001004:	e6a080e7          	jalr	-406(ra) # 80002e6a <binit>
    iinit();         // inode cache
    80001008:	00002097          	auipc	ra,0x2
    8000100c:	4fa080e7          	jalr	1274(ra) # 80003502 <iinit>
    fileinit();      // file table
    80001010:	00003097          	auipc	ra,0x3
    80001014:	494080e7          	jalr	1172(ra) # 800044a4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001018:	00005097          	auipc	ra,0x5
    8000101c:	e50080e7          	jalr	-432(ra) # 80005e68 <virtio_disk_init>
    userinit();      // first user process
    80001020:	00001097          	auipc	ra,0x1
    80001024:	d16080e7          	jalr	-746(ra) # 80001d36 <userinit>
    __sync_synchronize();
    80001028:	0ff0000f          	fence
    started = 1;
    8000102c:	4785                	li	a5,1
    8000102e:	00008717          	auipc	a4,0x8
    80001032:	fcf72f23          	sw	a5,-34(a4) # 8000900c <started>
    80001036:	b789                	j	80000f78 <main+0x56>

0000000080001038 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001038:	1141                	addi	sp,sp,-16
    8000103a:	e422                	sd	s0,8(sp)
    8000103c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000103e:	00008797          	auipc	a5,0x8
    80001042:	fd27b783          	ld	a5,-46(a5) # 80009010 <kernel_pagetable>
    80001046:	83b1                	srli	a5,a5,0xc
    80001048:	577d                	li	a4,-1
    8000104a:	177e                	slli	a4,a4,0x3f
    8000104c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000104e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001052:	12000073          	sfence.vma
  sfence_vma();
}
    80001056:	6422                	ld	s0,8(sp)
    80001058:	0141                	addi	sp,sp,16
    8000105a:	8082                	ret

000000008000105c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000105c:	7139                	addi	sp,sp,-64
    8000105e:	fc06                	sd	ra,56(sp)
    80001060:	f822                	sd	s0,48(sp)
    80001062:	f426                	sd	s1,40(sp)
    80001064:	f04a                	sd	s2,32(sp)
    80001066:	ec4e                	sd	s3,24(sp)
    80001068:	e852                	sd	s4,16(sp)
    8000106a:	e456                	sd	s5,8(sp)
    8000106c:	e05a                	sd	s6,0(sp)
    8000106e:	0080                	addi	s0,sp,64
    80001070:	84aa                	mv	s1,a0
    80001072:	89ae                	mv	s3,a1
    80001074:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001076:	57fd                	li	a5,-1
    80001078:	83e9                	srli	a5,a5,0x1a
    8000107a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000107c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000107e:	04b7f263          	bgeu	a5,a1,800010c2 <walk+0x66>
    panic("walk");
    80001082:	00007517          	auipc	a0,0x7
    80001086:	06650513          	addi	a0,a0,102 # 800080e8 <digits+0x90>
    8000108a:	fffff097          	auipc	ra,0xfffff
    8000108e:	54c080e7          	jalr	1356(ra) # 800005d6 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001092:	060a8663          	beqz	s5,800010fe <walk+0xa2>
    80001096:	00000097          	auipc	ra,0x0
    8000109a:	aee080e7          	jalr	-1298(ra) # 80000b84 <kalloc>
    8000109e:	84aa                	mv	s1,a0
    800010a0:	c529                	beqz	a0,800010ea <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010a2:	6605                	lui	a2,0x1
    800010a4:	4581                	li	a1,0
    800010a6:	00000097          	auipc	ra,0x0
    800010aa:	cca080e7          	jalr	-822(ra) # 80000d70 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010ae:	00c4d793          	srli	a5,s1,0xc
    800010b2:	07aa                	slli	a5,a5,0xa
    800010b4:	0017e793          	ori	a5,a5,1
    800010b8:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010bc:	3a5d                	addiw	s4,s4,-9
    800010be:	036a0063          	beq	s4,s6,800010de <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010c2:	0149d933          	srl	s2,s3,s4
    800010c6:	1ff97913          	andi	s2,s2,511
    800010ca:	090e                	slli	s2,s2,0x3
    800010cc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010ce:	00093483          	ld	s1,0(s2)
    800010d2:	0014f793          	andi	a5,s1,1
    800010d6:	dfd5                	beqz	a5,80001092 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010d8:	80a9                	srli	s1,s1,0xa
    800010da:	04b2                	slli	s1,s1,0xc
    800010dc:	b7c5                	j	800010bc <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010de:	00c9d513          	srli	a0,s3,0xc
    800010e2:	1ff57513          	andi	a0,a0,511
    800010e6:	050e                	slli	a0,a0,0x3
    800010e8:	9526                	add	a0,a0,s1
}
    800010ea:	70e2                	ld	ra,56(sp)
    800010ec:	7442                	ld	s0,48(sp)
    800010ee:	74a2                	ld	s1,40(sp)
    800010f0:	7902                	ld	s2,32(sp)
    800010f2:	69e2                	ld	s3,24(sp)
    800010f4:	6a42                	ld	s4,16(sp)
    800010f6:	6aa2                	ld	s5,8(sp)
    800010f8:	6b02                	ld	s6,0(sp)
    800010fa:	6121                	addi	sp,sp,64
    800010fc:	8082                	ret
        return 0;
    800010fe:	4501                	li	a0,0
    80001100:	b7ed                	j	800010ea <walk+0x8e>

0000000080001102 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001102:	57fd                	li	a5,-1
    80001104:	83e9                	srli	a5,a5,0x1a
    80001106:	00b7f463          	bgeu	a5,a1,8000110e <walkaddr+0xc>
    return 0;
    8000110a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000110c:	8082                	ret
{
    8000110e:	1141                	addi	sp,sp,-16
    80001110:	e406                	sd	ra,8(sp)
    80001112:	e022                	sd	s0,0(sp)
    80001114:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001116:	4601                	li	a2,0
    80001118:	00000097          	auipc	ra,0x0
    8000111c:	f44080e7          	jalr	-188(ra) # 8000105c <walk>
  if(pte == 0)
    80001120:	c105                	beqz	a0,80001140 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001122:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001124:	0117f693          	andi	a3,a5,17
    80001128:	4745                	li	a4,17
    return 0;
    8000112a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000112c:	00e68663          	beq	a3,a4,80001138 <walkaddr+0x36>
}
    80001130:	60a2                	ld	ra,8(sp)
    80001132:	6402                	ld	s0,0(sp)
    80001134:	0141                	addi	sp,sp,16
    80001136:	8082                	ret
  pa = PTE2PA(*pte);
    80001138:	00a7d513          	srli	a0,a5,0xa
    8000113c:	0532                	slli	a0,a0,0xc
  return pa;
    8000113e:	bfcd                	j	80001130 <walkaddr+0x2e>
    return 0;
    80001140:	4501                	li	a0,0
    80001142:	b7fd                	j	80001130 <walkaddr+0x2e>

0000000080001144 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001144:	1101                	addi	sp,sp,-32
    80001146:	ec06                	sd	ra,24(sp)
    80001148:	e822                	sd	s0,16(sp)
    8000114a:	e426                	sd	s1,8(sp)
    8000114c:	1000                	addi	s0,sp,32
    8000114e:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001150:	1552                	slli	a0,a0,0x34
    80001152:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001156:	4601                	li	a2,0
    80001158:	00008517          	auipc	a0,0x8
    8000115c:	eb853503          	ld	a0,-328(a0) # 80009010 <kernel_pagetable>
    80001160:	00000097          	auipc	ra,0x0
    80001164:	efc080e7          	jalr	-260(ra) # 8000105c <walk>
  if(pte == 0)
    80001168:	cd09                	beqz	a0,80001182 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000116a:	6108                	ld	a0,0(a0)
    8000116c:	00157793          	andi	a5,a0,1
    80001170:	c38d                	beqz	a5,80001192 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001172:	8129                	srli	a0,a0,0xa
    80001174:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001176:	9526                	add	a0,a0,s1
    80001178:	60e2                	ld	ra,24(sp)
    8000117a:	6442                	ld	s0,16(sp)
    8000117c:	64a2                	ld	s1,8(sp)
    8000117e:	6105                	addi	sp,sp,32
    80001180:	8082                	ret
    panic("kvmpa");
    80001182:	00007517          	auipc	a0,0x7
    80001186:	f6e50513          	addi	a0,a0,-146 # 800080f0 <digits+0x98>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	44c080e7          	jalr	1100(ra) # 800005d6 <panic>
    panic("kvmpa");
    80001192:	00007517          	auipc	a0,0x7
    80001196:	f5e50513          	addi	a0,a0,-162 # 800080f0 <digits+0x98>
    8000119a:	fffff097          	auipc	ra,0xfffff
    8000119e:	43c080e7          	jalr	1084(ra) # 800005d6 <panic>

00000000800011a2 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011a2:	715d                	addi	sp,sp,-80
    800011a4:	e486                	sd	ra,72(sp)
    800011a6:	e0a2                	sd	s0,64(sp)
    800011a8:	fc26                	sd	s1,56(sp)
    800011aa:	f84a                	sd	s2,48(sp)
    800011ac:	f44e                	sd	s3,40(sp)
    800011ae:	f052                	sd	s4,32(sp)
    800011b0:	ec56                	sd	s5,24(sp)
    800011b2:	e85a                	sd	s6,16(sp)
    800011b4:	e45e                	sd	s7,8(sp)
    800011b6:	0880                	addi	s0,sp,80
    800011b8:	8aaa                	mv	s5,a0
    800011ba:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011bc:	777d                	lui	a4,0xfffff
    800011be:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011c2:	167d                	addi	a2,a2,-1
    800011c4:	00b609b3          	add	s3,a2,a1
    800011c8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011cc:	893e                	mv	s2,a5
    800011ce:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011d2:	6b85                	lui	s7,0x1
    800011d4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011d8:	4605                	li	a2,1
    800011da:	85ca                	mv	a1,s2
    800011dc:	8556                	mv	a0,s5
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	e7e080e7          	jalr	-386(ra) # 8000105c <walk>
    800011e6:	c51d                	beqz	a0,80001214 <mappages+0x72>
    if(*pte & PTE_V)
    800011e8:	611c                	ld	a5,0(a0)
    800011ea:	8b85                	andi	a5,a5,1
    800011ec:	ef81                	bnez	a5,80001204 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011ee:	80b1                	srli	s1,s1,0xc
    800011f0:	04aa                	slli	s1,s1,0xa
    800011f2:	0164e4b3          	or	s1,s1,s6
    800011f6:	0014e493          	ori	s1,s1,1
    800011fa:	e104                	sd	s1,0(a0)
    if(a == last)
    800011fc:	03390863          	beq	s2,s3,8000122c <mappages+0x8a>
    a += PGSIZE;
    80001200:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001202:	bfc9                	j	800011d4 <mappages+0x32>
      panic("remap");
    80001204:	00007517          	auipc	a0,0x7
    80001208:	ef450513          	addi	a0,a0,-268 # 800080f8 <digits+0xa0>
    8000120c:	fffff097          	auipc	ra,0xfffff
    80001210:	3ca080e7          	jalr	970(ra) # 800005d6 <panic>
      return -1;
    80001214:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001216:	60a6                	ld	ra,72(sp)
    80001218:	6406                	ld	s0,64(sp)
    8000121a:	74e2                	ld	s1,56(sp)
    8000121c:	7942                	ld	s2,48(sp)
    8000121e:	79a2                	ld	s3,40(sp)
    80001220:	7a02                	ld	s4,32(sp)
    80001222:	6ae2                	ld	s5,24(sp)
    80001224:	6b42                	ld	s6,16(sp)
    80001226:	6ba2                	ld	s7,8(sp)
    80001228:	6161                	addi	sp,sp,80
    8000122a:	8082                	ret
  return 0;
    8000122c:	4501                	li	a0,0
    8000122e:	b7e5                	j	80001216 <mappages+0x74>

0000000080001230 <kvmmap>:
{
    80001230:	1141                	addi	sp,sp,-16
    80001232:	e406                	sd	ra,8(sp)
    80001234:	e022                	sd	s0,0(sp)
    80001236:	0800                	addi	s0,sp,16
    80001238:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000123a:	86ae                	mv	a3,a1
    8000123c:	85aa                	mv	a1,a0
    8000123e:	00008517          	auipc	a0,0x8
    80001242:	dd253503          	ld	a0,-558(a0) # 80009010 <kernel_pagetable>
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f5c080e7          	jalr	-164(ra) # 800011a2 <mappages>
    8000124e:	e509                	bnez	a0,80001258 <kvmmap+0x28>
}
    80001250:	60a2                	ld	ra,8(sp)
    80001252:	6402                	ld	s0,0(sp)
    80001254:	0141                	addi	sp,sp,16
    80001256:	8082                	ret
    panic("kvmmap");
    80001258:	00007517          	auipc	a0,0x7
    8000125c:	ea850513          	addi	a0,a0,-344 # 80008100 <digits+0xa8>
    80001260:	fffff097          	auipc	ra,0xfffff
    80001264:	376080e7          	jalr	886(ra) # 800005d6 <panic>

0000000080001268 <kvminit>:
{
    80001268:	1101                	addi	sp,sp,-32
    8000126a:	ec06                	sd	ra,24(sp)
    8000126c:	e822                	sd	s0,16(sp)
    8000126e:	e426                	sd	s1,8(sp)
    80001270:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001272:	00000097          	auipc	ra,0x0
    80001276:	912080e7          	jalr	-1774(ra) # 80000b84 <kalloc>
    8000127a:	00008797          	auipc	a5,0x8
    8000127e:	d8a7bb23          	sd	a0,-618(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001282:	6605                	lui	a2,0x1
    80001284:	4581                	li	a1,0
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	aea080e7          	jalr	-1302(ra) # 80000d70 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000128e:	4699                	li	a3,6
    80001290:	6605                	lui	a2,0x1
    80001292:	100005b7          	lui	a1,0x10000
    80001296:	10000537          	lui	a0,0x10000
    8000129a:	00000097          	auipc	ra,0x0
    8000129e:	f96080e7          	jalr	-106(ra) # 80001230 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012a2:	4699                	li	a3,6
    800012a4:	6605                	lui	a2,0x1
    800012a6:	100015b7          	lui	a1,0x10001
    800012aa:	10001537          	lui	a0,0x10001
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	f82080e7          	jalr	-126(ra) # 80001230 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800012b6:	4699                	li	a3,6
    800012b8:	6641                	lui	a2,0x10
    800012ba:	020005b7          	lui	a1,0x2000
    800012be:	02000537          	lui	a0,0x2000
    800012c2:	00000097          	auipc	ra,0x0
    800012c6:	f6e080e7          	jalr	-146(ra) # 80001230 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012ca:	4699                	li	a3,6
    800012cc:	00400637          	lui	a2,0x400
    800012d0:	0c0005b7          	lui	a1,0xc000
    800012d4:	0c000537          	lui	a0,0xc000
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	f58080e7          	jalr	-168(ra) # 80001230 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012e0:	00007497          	auipc	s1,0x7
    800012e4:	d2048493          	addi	s1,s1,-736 # 80008000 <etext>
    800012e8:	46a9                	li	a3,10
    800012ea:	80007617          	auipc	a2,0x80007
    800012ee:	d1660613          	addi	a2,a2,-746 # 8000 <_entry-0x7fff8000>
    800012f2:	4585                	li	a1,1
    800012f4:	05fe                	slli	a1,a1,0x1f
    800012f6:	852e                	mv	a0,a1
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	f38080e7          	jalr	-200(ra) # 80001230 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001300:	4699                	li	a3,6
    80001302:	4645                	li	a2,17
    80001304:	066e                	slli	a2,a2,0x1b
    80001306:	8e05                	sub	a2,a2,s1
    80001308:	85a6                	mv	a1,s1
    8000130a:	8526                	mv	a0,s1
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	f24080e7          	jalr	-220(ra) # 80001230 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001314:	46a9                	li	a3,10
    80001316:	6605                	lui	a2,0x1
    80001318:	00006597          	auipc	a1,0x6
    8000131c:	ce858593          	addi	a1,a1,-792 # 80007000 <_trampoline>
    80001320:	04000537          	lui	a0,0x4000
    80001324:	157d                	addi	a0,a0,-1
    80001326:	0532                	slli	a0,a0,0xc
    80001328:	00000097          	auipc	ra,0x0
    8000132c:	f08080e7          	jalr	-248(ra) # 80001230 <kvmmap>
}
    80001330:	60e2                	ld	ra,24(sp)
    80001332:	6442                	ld	s0,16(sp)
    80001334:	64a2                	ld	s1,8(sp)
    80001336:	6105                	addi	sp,sp,32
    80001338:	8082                	ret

000000008000133a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000133a:	715d                	addi	sp,sp,-80
    8000133c:	e486                	sd	ra,72(sp)
    8000133e:	e0a2                	sd	s0,64(sp)
    80001340:	fc26                	sd	s1,56(sp)
    80001342:	f84a                	sd	s2,48(sp)
    80001344:	f44e                	sd	s3,40(sp)
    80001346:	f052                	sd	s4,32(sp)
    80001348:	ec56                	sd	s5,24(sp)
    8000134a:	e85a                	sd	s6,16(sp)
    8000134c:	e45e                	sd	s7,8(sp)
    8000134e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001350:	03459793          	slli	a5,a1,0x34
    80001354:	e795                	bnez	a5,80001380 <uvmunmap+0x46>
    80001356:	8a2a                	mv	s4,a0
    80001358:	892e                	mv	s2,a1
    8000135a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000135c:	0632                	slli	a2,a2,0xc
    8000135e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001364:	6b05                	lui	s6,0x1
    80001366:	0735e863          	bltu	a1,s3,800013d6 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000136a:	60a6                	ld	ra,72(sp)
    8000136c:	6406                	ld	s0,64(sp)
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	7942                	ld	s2,48(sp)
    80001372:	79a2                	ld	s3,40(sp)
    80001374:	7a02                	ld	s4,32(sp)
    80001376:	6ae2                	ld	s5,24(sp)
    80001378:	6b42                	ld	s6,16(sp)
    8000137a:	6ba2                	ld	s7,8(sp)
    8000137c:	6161                	addi	sp,sp,80
    8000137e:	8082                	ret
    panic("uvmunmap: not aligned");
    80001380:	00007517          	auipc	a0,0x7
    80001384:	d8850513          	addi	a0,a0,-632 # 80008108 <digits+0xb0>
    80001388:	fffff097          	auipc	ra,0xfffff
    8000138c:	24e080e7          	jalr	590(ra) # 800005d6 <panic>
      panic("uvmunmap: walk");
    80001390:	00007517          	auipc	a0,0x7
    80001394:	d9050513          	addi	a0,a0,-624 # 80008120 <digits+0xc8>
    80001398:	fffff097          	auipc	ra,0xfffff
    8000139c:	23e080e7          	jalr	574(ra) # 800005d6 <panic>
      panic("uvmunmap: not mapped");
    800013a0:	00007517          	auipc	a0,0x7
    800013a4:	d9050513          	addi	a0,a0,-624 # 80008130 <digits+0xd8>
    800013a8:	fffff097          	auipc	ra,0xfffff
    800013ac:	22e080e7          	jalr	558(ra) # 800005d6 <panic>
      panic("uvmunmap: not a leaf");
    800013b0:	00007517          	auipc	a0,0x7
    800013b4:	d9850513          	addi	a0,a0,-616 # 80008148 <digits+0xf0>
    800013b8:	fffff097          	auipc	ra,0xfffff
    800013bc:	21e080e7          	jalr	542(ra) # 800005d6 <panic>
      uint64 pa = PTE2PA(*pte);
    800013c0:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013c2:	0532                	slli	a0,a0,0xc
    800013c4:	fffff097          	auipc	ra,0xfffff
    800013c8:	6c4080e7          	jalr	1732(ra) # 80000a88 <kfree>
    *pte = 0;
    800013cc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013d0:	995a                	add	s2,s2,s6
    800013d2:	f9397ce3          	bgeu	s2,s3,8000136a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013d6:	4601                	li	a2,0
    800013d8:	85ca                	mv	a1,s2
    800013da:	8552                	mv	a0,s4
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	c80080e7          	jalr	-896(ra) # 8000105c <walk>
    800013e4:	84aa                	mv	s1,a0
    800013e6:	d54d                	beqz	a0,80001390 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013e8:	6108                	ld	a0,0(a0)
    800013ea:	00157793          	andi	a5,a0,1
    800013ee:	dbcd                	beqz	a5,800013a0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013f0:	3ff57793          	andi	a5,a0,1023
    800013f4:	fb778ee3          	beq	a5,s7,800013b0 <uvmunmap+0x76>
    if(do_free){
    800013f8:	fc0a8ae3          	beqz	s5,800013cc <uvmunmap+0x92>
    800013fc:	b7d1                	j	800013c0 <uvmunmap+0x86>

00000000800013fe <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013fe:	1101                	addi	sp,sp,-32
    80001400:	ec06                	sd	ra,24(sp)
    80001402:	e822                	sd	s0,16(sp)
    80001404:	e426                	sd	s1,8(sp)
    80001406:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001408:	fffff097          	auipc	ra,0xfffff
    8000140c:	77c080e7          	jalr	1916(ra) # 80000b84 <kalloc>
    80001410:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001412:	c519                	beqz	a0,80001420 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001414:	6605                	lui	a2,0x1
    80001416:	4581                	li	a1,0
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	958080e7          	jalr	-1704(ra) # 80000d70 <memset>
  return pagetable;
}
    80001420:	8526                	mv	a0,s1
    80001422:	60e2                	ld	ra,24(sp)
    80001424:	6442                	ld	s0,16(sp)
    80001426:	64a2                	ld	s1,8(sp)
    80001428:	6105                	addi	sp,sp,32
    8000142a:	8082                	ret

000000008000142c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000142c:	7179                	addi	sp,sp,-48
    8000142e:	f406                	sd	ra,40(sp)
    80001430:	f022                	sd	s0,32(sp)
    80001432:	ec26                	sd	s1,24(sp)
    80001434:	e84a                	sd	s2,16(sp)
    80001436:	e44e                	sd	s3,8(sp)
    80001438:	e052                	sd	s4,0(sp)
    8000143a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000143c:	6785                	lui	a5,0x1
    8000143e:	04f67863          	bgeu	a2,a5,8000148e <uvminit+0x62>
    80001442:	8a2a                	mv	s4,a0
    80001444:	89ae                	mv	s3,a1
    80001446:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001448:	fffff097          	auipc	ra,0xfffff
    8000144c:	73c080e7          	jalr	1852(ra) # 80000b84 <kalloc>
    80001450:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001452:	6605                	lui	a2,0x1
    80001454:	4581                	li	a1,0
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	91a080e7          	jalr	-1766(ra) # 80000d70 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000145e:	4779                	li	a4,30
    80001460:	86ca                	mv	a3,s2
    80001462:	6605                	lui	a2,0x1
    80001464:	4581                	li	a1,0
    80001466:	8552                	mv	a0,s4
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	d3a080e7          	jalr	-710(ra) # 800011a2 <mappages>
  memmove(mem, src, sz);
    80001470:	8626                	mv	a2,s1
    80001472:	85ce                	mv	a1,s3
    80001474:	854a                	mv	a0,s2
    80001476:	00000097          	auipc	ra,0x0
    8000147a:	95a080e7          	jalr	-1702(ra) # 80000dd0 <memmove>
}
    8000147e:	70a2                	ld	ra,40(sp)
    80001480:	7402                	ld	s0,32(sp)
    80001482:	64e2                	ld	s1,24(sp)
    80001484:	6942                	ld	s2,16(sp)
    80001486:	69a2                	ld	s3,8(sp)
    80001488:	6a02                	ld	s4,0(sp)
    8000148a:	6145                	addi	sp,sp,48
    8000148c:	8082                	ret
    panic("inituvm: more than a page");
    8000148e:	00007517          	auipc	a0,0x7
    80001492:	cd250513          	addi	a0,a0,-814 # 80008160 <digits+0x108>
    80001496:	fffff097          	auipc	ra,0xfffff
    8000149a:	140080e7          	jalr	320(ra) # 800005d6 <panic>

000000008000149e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000149e:	1101                	addi	sp,sp,-32
    800014a0:	ec06                	sd	ra,24(sp)
    800014a2:	e822                	sd	s0,16(sp)
    800014a4:	e426                	sd	s1,8(sp)
    800014a6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014a8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014aa:	00b67d63          	bgeu	a2,a1,800014c4 <uvmdealloc+0x26>
    800014ae:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014b0:	6785                	lui	a5,0x1
    800014b2:	17fd                	addi	a5,a5,-1
    800014b4:	00f60733          	add	a4,a2,a5
    800014b8:	767d                	lui	a2,0xfffff
    800014ba:	8f71                	and	a4,a4,a2
    800014bc:	97ae                	add	a5,a5,a1
    800014be:	8ff1                	and	a5,a5,a2
    800014c0:	00f76863          	bltu	a4,a5,800014d0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014c4:	8526                	mv	a0,s1
    800014c6:	60e2                	ld	ra,24(sp)
    800014c8:	6442                	ld	s0,16(sp)
    800014ca:	64a2                	ld	s1,8(sp)
    800014cc:	6105                	addi	sp,sp,32
    800014ce:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014d0:	8f99                	sub	a5,a5,a4
    800014d2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014d4:	4685                	li	a3,1
    800014d6:	0007861b          	sext.w	a2,a5
    800014da:	85ba                	mv	a1,a4
    800014dc:	00000097          	auipc	ra,0x0
    800014e0:	e5e080e7          	jalr	-418(ra) # 8000133a <uvmunmap>
    800014e4:	b7c5                	j	800014c4 <uvmdealloc+0x26>

00000000800014e6 <uvmalloc>:
  if(newsz < oldsz)
    800014e6:	0ab66163          	bltu	a2,a1,80001588 <uvmalloc+0xa2>
{
    800014ea:	7139                	addi	sp,sp,-64
    800014ec:	fc06                	sd	ra,56(sp)
    800014ee:	f822                	sd	s0,48(sp)
    800014f0:	f426                	sd	s1,40(sp)
    800014f2:	f04a                	sd	s2,32(sp)
    800014f4:	ec4e                	sd	s3,24(sp)
    800014f6:	e852                	sd	s4,16(sp)
    800014f8:	e456                	sd	s5,8(sp)
    800014fa:	0080                	addi	s0,sp,64
    800014fc:	8aaa                	mv	s5,a0
    800014fe:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001500:	6985                	lui	s3,0x1
    80001502:	19fd                	addi	s3,s3,-1
    80001504:	95ce                	add	a1,a1,s3
    80001506:	79fd                	lui	s3,0xfffff
    80001508:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000150c:	08c9f063          	bgeu	s3,a2,8000158c <uvmalloc+0xa6>
    80001510:	894e                	mv	s2,s3
    mem = kalloc();
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	672080e7          	jalr	1650(ra) # 80000b84 <kalloc>
    8000151a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000151c:	c51d                	beqz	a0,8000154a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000151e:	6605                	lui	a2,0x1
    80001520:	4581                	li	a1,0
    80001522:	00000097          	auipc	ra,0x0
    80001526:	84e080e7          	jalr	-1970(ra) # 80000d70 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000152a:	4779                	li	a4,30
    8000152c:	86a6                	mv	a3,s1
    8000152e:	6605                	lui	a2,0x1
    80001530:	85ca                	mv	a1,s2
    80001532:	8556                	mv	a0,s5
    80001534:	00000097          	auipc	ra,0x0
    80001538:	c6e080e7          	jalr	-914(ra) # 800011a2 <mappages>
    8000153c:	e905                	bnez	a0,8000156c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000153e:	6785                	lui	a5,0x1
    80001540:	993e                	add	s2,s2,a5
    80001542:	fd4968e3          	bltu	s2,s4,80001512 <uvmalloc+0x2c>
  return newsz;
    80001546:	8552                	mv	a0,s4
    80001548:	a809                	j	8000155a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000154a:	864e                	mv	a2,s3
    8000154c:	85ca                	mv	a1,s2
    8000154e:	8556                	mv	a0,s5
    80001550:	00000097          	auipc	ra,0x0
    80001554:	f4e080e7          	jalr	-178(ra) # 8000149e <uvmdealloc>
      return 0;
    80001558:	4501                	li	a0,0
}
    8000155a:	70e2                	ld	ra,56(sp)
    8000155c:	7442                	ld	s0,48(sp)
    8000155e:	74a2                	ld	s1,40(sp)
    80001560:	7902                	ld	s2,32(sp)
    80001562:	69e2                	ld	s3,24(sp)
    80001564:	6a42                	ld	s4,16(sp)
    80001566:	6aa2                	ld	s5,8(sp)
    80001568:	6121                	addi	sp,sp,64
    8000156a:	8082                	ret
      kfree(mem);
    8000156c:	8526                	mv	a0,s1
    8000156e:	fffff097          	auipc	ra,0xfffff
    80001572:	51a080e7          	jalr	1306(ra) # 80000a88 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001576:	864e                	mv	a2,s3
    80001578:	85ca                	mv	a1,s2
    8000157a:	8556                	mv	a0,s5
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	f22080e7          	jalr	-222(ra) # 8000149e <uvmdealloc>
      return 0;
    80001584:	4501                	li	a0,0
    80001586:	bfd1                	j	8000155a <uvmalloc+0x74>
    return oldsz;
    80001588:	852e                	mv	a0,a1
}
    8000158a:	8082                	ret
  return newsz;
    8000158c:	8532                	mv	a0,a2
    8000158e:	b7f1                	j	8000155a <uvmalloc+0x74>

0000000080001590 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001590:	7179                	addi	sp,sp,-48
    80001592:	f406                	sd	ra,40(sp)
    80001594:	f022                	sd	s0,32(sp)
    80001596:	ec26                	sd	s1,24(sp)
    80001598:	e84a                	sd	s2,16(sp)
    8000159a:	e44e                	sd	s3,8(sp)
    8000159c:	e052                	sd	s4,0(sp)
    8000159e:	1800                	addi	s0,sp,48
    800015a0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015a2:	84aa                	mv	s1,a0
    800015a4:	6905                	lui	s2,0x1
    800015a6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a8:	4985                	li	s3,1
    800015aa:	a821                	j	800015c2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015ac:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015ae:	0532                	slli	a0,a0,0xc
    800015b0:	00000097          	auipc	ra,0x0
    800015b4:	fe0080e7          	jalr	-32(ra) # 80001590 <freewalk>
      pagetable[i] = 0;
    800015b8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015bc:	04a1                	addi	s1,s1,8
    800015be:	03248163          	beq	s1,s2,800015e0 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015c2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c4:	00f57793          	andi	a5,a0,15
    800015c8:	ff3782e3          	beq	a5,s3,800015ac <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015cc:	8905                	andi	a0,a0,1
    800015ce:	d57d                	beqz	a0,800015bc <freewalk+0x2c>
      panic("freewalk: leaf");
    800015d0:	00007517          	auipc	a0,0x7
    800015d4:	bb050513          	addi	a0,a0,-1104 # 80008180 <digits+0x128>
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	ffe080e7          	jalr	-2(ra) # 800005d6 <panic>
    }
  }
  kfree((void*)pagetable);
    800015e0:	8552                	mv	a0,s4
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	4a6080e7          	jalr	1190(ra) # 80000a88 <kfree>
}
    800015ea:	70a2                	ld	ra,40(sp)
    800015ec:	7402                	ld	s0,32(sp)
    800015ee:	64e2                	ld	s1,24(sp)
    800015f0:	6942                	ld	s2,16(sp)
    800015f2:	69a2                	ld	s3,8(sp)
    800015f4:	6a02                	ld	s4,0(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret

00000000800015fa <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015fa:	1101                	addi	sp,sp,-32
    800015fc:	ec06                	sd	ra,24(sp)
    800015fe:	e822                	sd	s0,16(sp)
    80001600:	e426                	sd	s1,8(sp)
    80001602:	1000                	addi	s0,sp,32
    80001604:	84aa                	mv	s1,a0
  if(sz > 0)
    80001606:	e999                	bnez	a1,8000161c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001608:	8526                	mv	a0,s1
    8000160a:	00000097          	auipc	ra,0x0
    8000160e:	f86080e7          	jalr	-122(ra) # 80001590 <freewalk>
}
    80001612:	60e2                	ld	ra,24(sp)
    80001614:	6442                	ld	s0,16(sp)
    80001616:	64a2                	ld	s1,8(sp)
    80001618:	6105                	addi	sp,sp,32
    8000161a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000161c:	6605                	lui	a2,0x1
    8000161e:	167d                	addi	a2,a2,-1
    80001620:	962e                	add	a2,a2,a1
    80001622:	4685                	li	a3,1
    80001624:	8231                	srli	a2,a2,0xc
    80001626:	4581                	li	a1,0
    80001628:	00000097          	auipc	ra,0x0
    8000162c:	d12080e7          	jalr	-750(ra) # 8000133a <uvmunmap>
    80001630:	bfe1                	j	80001608 <uvmfree+0xe>

0000000080001632 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001632:	c679                	beqz	a2,80001700 <uvmcopy+0xce>
{
    80001634:	715d                	addi	sp,sp,-80
    80001636:	e486                	sd	ra,72(sp)
    80001638:	e0a2                	sd	s0,64(sp)
    8000163a:	fc26                	sd	s1,56(sp)
    8000163c:	f84a                	sd	s2,48(sp)
    8000163e:	f44e                	sd	s3,40(sp)
    80001640:	f052                	sd	s4,32(sp)
    80001642:	ec56                	sd	s5,24(sp)
    80001644:	e85a                	sd	s6,16(sp)
    80001646:	e45e                	sd	s7,8(sp)
    80001648:	0880                	addi	s0,sp,80
    8000164a:	8b2a                	mv	s6,a0
    8000164c:	8aae                	mv	s5,a1
    8000164e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001650:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001652:	4601                	li	a2,0
    80001654:	85ce                	mv	a1,s3
    80001656:	855a                	mv	a0,s6
    80001658:	00000097          	auipc	ra,0x0
    8000165c:	a04080e7          	jalr	-1532(ra) # 8000105c <walk>
    80001660:	c531                	beqz	a0,800016ac <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001662:	6118                	ld	a4,0(a0)
    80001664:	00177793          	andi	a5,a4,1
    80001668:	cbb1                	beqz	a5,800016bc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000166a:	00a75593          	srli	a1,a4,0xa
    8000166e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001672:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001676:	fffff097          	auipc	ra,0xfffff
    8000167a:	50e080e7          	jalr	1294(ra) # 80000b84 <kalloc>
    8000167e:	892a                	mv	s2,a0
    80001680:	c939                	beqz	a0,800016d6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001682:	6605                	lui	a2,0x1
    80001684:	85de                	mv	a1,s7
    80001686:	fffff097          	auipc	ra,0xfffff
    8000168a:	74a080e7          	jalr	1866(ra) # 80000dd0 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000168e:	8726                	mv	a4,s1
    80001690:	86ca                	mv	a3,s2
    80001692:	6605                	lui	a2,0x1
    80001694:	85ce                	mv	a1,s3
    80001696:	8556                	mv	a0,s5
    80001698:	00000097          	auipc	ra,0x0
    8000169c:	b0a080e7          	jalr	-1270(ra) # 800011a2 <mappages>
    800016a0:	e515                	bnez	a0,800016cc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016a2:	6785                	lui	a5,0x1
    800016a4:	99be                	add	s3,s3,a5
    800016a6:	fb49e6e3          	bltu	s3,s4,80001652 <uvmcopy+0x20>
    800016aa:	a081                	j	800016ea <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016ac:	00007517          	auipc	a0,0x7
    800016b0:	ae450513          	addi	a0,a0,-1308 # 80008190 <digits+0x138>
    800016b4:	fffff097          	auipc	ra,0xfffff
    800016b8:	f22080e7          	jalr	-222(ra) # 800005d6 <panic>
      panic("uvmcopy: page not present");
    800016bc:	00007517          	auipc	a0,0x7
    800016c0:	af450513          	addi	a0,a0,-1292 # 800081b0 <digits+0x158>
    800016c4:	fffff097          	auipc	ra,0xfffff
    800016c8:	f12080e7          	jalr	-238(ra) # 800005d6 <panic>
      kfree(mem);
    800016cc:	854a                	mv	a0,s2
    800016ce:	fffff097          	auipc	ra,0xfffff
    800016d2:	3ba080e7          	jalr	954(ra) # 80000a88 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016d6:	4685                	li	a3,1
    800016d8:	00c9d613          	srli	a2,s3,0xc
    800016dc:	4581                	li	a1,0
    800016de:	8556                	mv	a0,s5
    800016e0:	00000097          	auipc	ra,0x0
    800016e4:	c5a080e7          	jalr	-934(ra) # 8000133a <uvmunmap>
  return -1;
    800016e8:	557d                	li	a0,-1
}
    800016ea:	60a6                	ld	ra,72(sp)
    800016ec:	6406                	ld	s0,64(sp)
    800016ee:	74e2                	ld	s1,56(sp)
    800016f0:	7942                	ld	s2,48(sp)
    800016f2:	79a2                	ld	s3,40(sp)
    800016f4:	7a02                	ld	s4,32(sp)
    800016f6:	6ae2                	ld	s5,24(sp)
    800016f8:	6b42                	ld	s6,16(sp)
    800016fa:	6ba2                	ld	s7,8(sp)
    800016fc:	6161                	addi	sp,sp,80
    800016fe:	8082                	ret
  return 0;
    80001700:	4501                	li	a0,0
}
    80001702:	8082                	ret

0000000080001704 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001704:	1141                	addi	sp,sp,-16
    80001706:	e406                	sd	ra,8(sp)
    80001708:	e022                	sd	s0,0(sp)
    8000170a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000170c:	4601                	li	a2,0
    8000170e:	00000097          	auipc	ra,0x0
    80001712:	94e080e7          	jalr	-1714(ra) # 8000105c <walk>
  if(pte == 0)
    80001716:	c901                	beqz	a0,80001726 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001718:	611c                	ld	a5,0(a0)
    8000171a:	9bbd                	andi	a5,a5,-17
    8000171c:	e11c                	sd	a5,0(a0)
}
    8000171e:	60a2                	ld	ra,8(sp)
    80001720:	6402                	ld	s0,0(sp)
    80001722:	0141                	addi	sp,sp,16
    80001724:	8082                	ret
    panic("uvmclear");
    80001726:	00007517          	auipc	a0,0x7
    8000172a:	aaa50513          	addi	a0,a0,-1366 # 800081d0 <digits+0x178>
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	ea8080e7          	jalr	-344(ra) # 800005d6 <panic>

0000000080001736 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001736:	c6bd                	beqz	a3,800017a4 <copyout+0x6e>
{
    80001738:	715d                	addi	sp,sp,-80
    8000173a:	e486                	sd	ra,72(sp)
    8000173c:	e0a2                	sd	s0,64(sp)
    8000173e:	fc26                	sd	s1,56(sp)
    80001740:	f84a                	sd	s2,48(sp)
    80001742:	f44e                	sd	s3,40(sp)
    80001744:	f052                	sd	s4,32(sp)
    80001746:	ec56                	sd	s5,24(sp)
    80001748:	e85a                	sd	s6,16(sp)
    8000174a:	e45e                	sd	s7,8(sp)
    8000174c:	e062                	sd	s8,0(sp)
    8000174e:	0880                	addi	s0,sp,80
    80001750:	8b2a                	mv	s6,a0
    80001752:	8c2e                	mv	s8,a1
    80001754:	8a32                	mv	s4,a2
    80001756:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001758:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000175a:	6a85                	lui	s5,0x1
    8000175c:	a015                	j	80001780 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000175e:	9562                	add	a0,a0,s8
    80001760:	0004861b          	sext.w	a2,s1
    80001764:	85d2                	mv	a1,s4
    80001766:	41250533          	sub	a0,a0,s2
    8000176a:	fffff097          	auipc	ra,0xfffff
    8000176e:	666080e7          	jalr	1638(ra) # 80000dd0 <memmove>

    len -= n;
    80001772:	409989b3          	sub	s3,s3,s1
    src += n;
    80001776:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001778:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000177c:	02098263          	beqz	s3,800017a0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001780:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001784:	85ca                	mv	a1,s2
    80001786:	855a                	mv	a0,s6
    80001788:	00000097          	auipc	ra,0x0
    8000178c:	97a080e7          	jalr	-1670(ra) # 80001102 <walkaddr>
    if(pa0 == 0)
    80001790:	cd01                	beqz	a0,800017a8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001792:	418904b3          	sub	s1,s2,s8
    80001796:	94d6                	add	s1,s1,s5
    if(n > len)
    80001798:	fc99f3e3          	bgeu	s3,s1,8000175e <copyout+0x28>
    8000179c:	84ce                	mv	s1,s3
    8000179e:	b7c1                	j	8000175e <copyout+0x28>
  }
  return 0;
    800017a0:	4501                	li	a0,0
    800017a2:	a021                	j	800017aa <copyout+0x74>
    800017a4:	4501                	li	a0,0
}
    800017a6:	8082                	ret
      return -1;
    800017a8:	557d                	li	a0,-1
}
    800017aa:	60a6                	ld	ra,72(sp)
    800017ac:	6406                	ld	s0,64(sp)
    800017ae:	74e2                	ld	s1,56(sp)
    800017b0:	7942                	ld	s2,48(sp)
    800017b2:	79a2                	ld	s3,40(sp)
    800017b4:	7a02                	ld	s4,32(sp)
    800017b6:	6ae2                	ld	s5,24(sp)
    800017b8:	6b42                	ld	s6,16(sp)
    800017ba:	6ba2                	ld	s7,8(sp)
    800017bc:	6c02                	ld	s8,0(sp)
    800017be:	6161                	addi	sp,sp,80
    800017c0:	8082                	ret

00000000800017c2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017c2:	c6bd                	beqz	a3,80001830 <copyin+0x6e>
{
    800017c4:	715d                	addi	sp,sp,-80
    800017c6:	e486                	sd	ra,72(sp)
    800017c8:	e0a2                	sd	s0,64(sp)
    800017ca:	fc26                	sd	s1,56(sp)
    800017cc:	f84a                	sd	s2,48(sp)
    800017ce:	f44e                	sd	s3,40(sp)
    800017d0:	f052                	sd	s4,32(sp)
    800017d2:	ec56                	sd	s5,24(sp)
    800017d4:	e85a                	sd	s6,16(sp)
    800017d6:	e45e                	sd	s7,8(sp)
    800017d8:	e062                	sd	s8,0(sp)
    800017da:	0880                	addi	s0,sp,80
    800017dc:	8b2a                	mv	s6,a0
    800017de:	8a2e                	mv	s4,a1
    800017e0:	8c32                	mv	s8,a2
    800017e2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017e4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e6:	6a85                	lui	s5,0x1
    800017e8:	a015                	j	8000180c <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017ea:	9562                	add	a0,a0,s8
    800017ec:	0004861b          	sext.w	a2,s1
    800017f0:	412505b3          	sub	a1,a0,s2
    800017f4:	8552                	mv	a0,s4
    800017f6:	fffff097          	auipc	ra,0xfffff
    800017fa:	5da080e7          	jalr	1498(ra) # 80000dd0 <memmove>

    len -= n;
    800017fe:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001802:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001804:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001808:	02098263          	beqz	s3,8000182c <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000180c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001810:	85ca                	mv	a1,s2
    80001812:	855a                	mv	a0,s6
    80001814:	00000097          	auipc	ra,0x0
    80001818:	8ee080e7          	jalr	-1810(ra) # 80001102 <walkaddr>
    if(pa0 == 0)
    8000181c:	cd01                	beqz	a0,80001834 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000181e:	418904b3          	sub	s1,s2,s8
    80001822:	94d6                	add	s1,s1,s5
    if(n > len)
    80001824:	fc99f3e3          	bgeu	s3,s1,800017ea <copyin+0x28>
    80001828:	84ce                	mv	s1,s3
    8000182a:	b7c1                	j	800017ea <copyin+0x28>
  }
  return 0;
    8000182c:	4501                	li	a0,0
    8000182e:	a021                	j	80001836 <copyin+0x74>
    80001830:	4501                	li	a0,0
}
    80001832:	8082                	ret
      return -1;
    80001834:	557d                	li	a0,-1
}
    80001836:	60a6                	ld	ra,72(sp)
    80001838:	6406                	ld	s0,64(sp)
    8000183a:	74e2                	ld	s1,56(sp)
    8000183c:	7942                	ld	s2,48(sp)
    8000183e:	79a2                	ld	s3,40(sp)
    80001840:	7a02                	ld	s4,32(sp)
    80001842:	6ae2                	ld	s5,24(sp)
    80001844:	6b42                	ld	s6,16(sp)
    80001846:	6ba2                	ld	s7,8(sp)
    80001848:	6c02                	ld	s8,0(sp)
    8000184a:	6161                	addi	sp,sp,80
    8000184c:	8082                	ret

000000008000184e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000184e:	c6c5                	beqz	a3,800018f6 <copyinstr+0xa8>
{
    80001850:	715d                	addi	sp,sp,-80
    80001852:	e486                	sd	ra,72(sp)
    80001854:	e0a2                	sd	s0,64(sp)
    80001856:	fc26                	sd	s1,56(sp)
    80001858:	f84a                	sd	s2,48(sp)
    8000185a:	f44e                	sd	s3,40(sp)
    8000185c:	f052                	sd	s4,32(sp)
    8000185e:	ec56                	sd	s5,24(sp)
    80001860:	e85a                	sd	s6,16(sp)
    80001862:	e45e                	sd	s7,8(sp)
    80001864:	0880                	addi	s0,sp,80
    80001866:	8a2a                	mv	s4,a0
    80001868:	8b2e                	mv	s6,a1
    8000186a:	8bb2                	mv	s7,a2
    8000186c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000186e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001870:	6985                	lui	s3,0x1
    80001872:	a035                	j	8000189e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001874:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001878:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000187a:	0017b793          	seqz	a5,a5
    8000187e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001882:	60a6                	ld	ra,72(sp)
    80001884:	6406                	ld	s0,64(sp)
    80001886:	74e2                	ld	s1,56(sp)
    80001888:	7942                	ld	s2,48(sp)
    8000188a:	79a2                	ld	s3,40(sp)
    8000188c:	7a02                	ld	s4,32(sp)
    8000188e:	6ae2                	ld	s5,24(sp)
    80001890:	6b42                	ld	s6,16(sp)
    80001892:	6ba2                	ld	s7,8(sp)
    80001894:	6161                	addi	sp,sp,80
    80001896:	8082                	ret
    srcva = va0 + PGSIZE;
    80001898:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000189c:	c8a9                	beqz	s1,800018ee <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000189e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018a2:	85ca                	mv	a1,s2
    800018a4:	8552                	mv	a0,s4
    800018a6:	00000097          	auipc	ra,0x0
    800018aa:	85c080e7          	jalr	-1956(ra) # 80001102 <walkaddr>
    if(pa0 == 0)
    800018ae:	c131                	beqz	a0,800018f2 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018b0:	41790833          	sub	a6,s2,s7
    800018b4:	984e                	add	a6,a6,s3
    if(n > max)
    800018b6:	0104f363          	bgeu	s1,a6,800018bc <copyinstr+0x6e>
    800018ba:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018bc:	955e                	add	a0,a0,s7
    800018be:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018c2:	fc080be3          	beqz	a6,80001898 <copyinstr+0x4a>
    800018c6:	985a                	add	a6,a6,s6
    800018c8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018ca:	41650633          	sub	a2,a0,s6
    800018ce:	14fd                	addi	s1,s1,-1
    800018d0:	9b26                	add	s6,s6,s1
    800018d2:	00f60733          	add	a4,a2,a5
    800018d6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8000>
    800018da:	df49                	beqz	a4,80001874 <copyinstr+0x26>
        *dst = *p;
    800018dc:	00e78023          	sb	a4,0(a5)
      --max;
    800018e0:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018e4:	0785                	addi	a5,a5,1
    while(n > 0){
    800018e6:	ff0796e3          	bne	a5,a6,800018d2 <copyinstr+0x84>
      dst++;
    800018ea:	8b42                	mv	s6,a6
    800018ec:	b775                	j	80001898 <copyinstr+0x4a>
    800018ee:	4781                	li	a5,0
    800018f0:	b769                	j	8000187a <copyinstr+0x2c>
      return -1;
    800018f2:	557d                	li	a0,-1
    800018f4:	b779                	j	80001882 <copyinstr+0x34>
  int got_null = 0;
    800018f6:	4781                	li	a5,0
  if(got_null){
    800018f8:	0017b793          	seqz	a5,a5
    800018fc:	40f00533          	neg	a0,a5
}
    80001900:	8082                	ret

0000000080001902 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001902:	1101                	addi	sp,sp,-32
    80001904:	ec06                	sd	ra,24(sp)
    80001906:	e822                	sd	s0,16(sp)
    80001908:	e426                	sd	s1,8(sp)
    8000190a:	1000                	addi	s0,sp,32
    8000190c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000190e:	fffff097          	auipc	ra,0xfffff
    80001912:	2ec080e7          	jalr	748(ra) # 80000bfa <holding>
    80001916:	c909                	beqz	a0,80001928 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001918:	749c                	ld	a5,40(s1)
    8000191a:	00978f63          	beq	a5,s1,80001938 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    8000191e:	60e2                	ld	ra,24(sp)
    80001920:	6442                	ld	s0,16(sp)
    80001922:	64a2                	ld	s1,8(sp)
    80001924:	6105                	addi	sp,sp,32
    80001926:	8082                	ret
    panic("wakeup1");
    80001928:	00007517          	auipc	a0,0x7
    8000192c:	8b850513          	addi	a0,a0,-1864 # 800081e0 <digits+0x188>
    80001930:	fffff097          	auipc	ra,0xfffff
    80001934:	ca6080e7          	jalr	-858(ra) # 800005d6 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001938:	4c98                	lw	a4,24(s1)
    8000193a:	4785                	li	a5,1
    8000193c:	fef711e3          	bne	a4,a5,8000191e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001940:	4789                	li	a5,2
    80001942:	cc9c                	sw	a5,24(s1)
}
    80001944:	bfe9                	j	8000191e <wakeup1+0x1c>

0000000080001946 <procinit>:
{
    80001946:	715d                	addi	sp,sp,-80
    80001948:	e486                	sd	ra,72(sp)
    8000194a:	e0a2                	sd	s0,64(sp)
    8000194c:	fc26                	sd	s1,56(sp)
    8000194e:	f84a                	sd	s2,48(sp)
    80001950:	f44e                	sd	s3,40(sp)
    80001952:	f052                	sd	s4,32(sp)
    80001954:	ec56                	sd	s5,24(sp)
    80001956:	e85a                	sd	s6,16(sp)
    80001958:	e45e                	sd	s7,8(sp)
    8000195a:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000195c:	00007597          	auipc	a1,0x7
    80001960:	88c58593          	addi	a1,a1,-1908 # 800081e8 <digits+0x190>
    80001964:	00010517          	auipc	a0,0x10
    80001968:	fec50513          	addi	a0,a0,-20 # 80011950 <pid_lock>
    8000196c:	fffff097          	auipc	ra,0xfffff
    80001970:	278080e7          	jalr	632(ra) # 80000be4 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001974:	00010917          	auipc	s2,0x10
    80001978:	3f490913          	addi	s2,s2,1012 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    8000197c:	00007b97          	auipc	s7,0x7
    80001980:	874b8b93          	addi	s7,s7,-1932 # 800081f0 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001984:	8b4a                	mv	s6,s2
    80001986:	00006a97          	auipc	s5,0x6
    8000198a:	67aa8a93          	addi	s5,s5,1658 # 80008000 <etext>
    8000198e:	040009b7          	lui	s3,0x4000
    80001992:	19fd                	addi	s3,s3,-1
    80001994:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001996:	00016a17          	auipc	s4,0x16
    8000199a:	3d2a0a13          	addi	s4,s4,978 # 80017d68 <tickslock>
      initlock(&p->lock, "proc");
    8000199e:	85de                	mv	a1,s7
    800019a0:	854a                	mv	a0,s2
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	242080e7          	jalr	578(ra) # 80000be4 <initlock>
      char *pa = kalloc();
    800019aa:	fffff097          	auipc	ra,0xfffff
    800019ae:	1da080e7          	jalr	474(ra) # 80000b84 <kalloc>
    800019b2:	85aa                	mv	a1,a0
      if(pa == 0)
    800019b4:	c929                	beqz	a0,80001a06 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019b6:	416904b3          	sub	s1,s2,s6
    800019ba:	849d                	srai	s1,s1,0x7
    800019bc:	000ab783          	ld	a5,0(s5)
    800019c0:	02f484b3          	mul	s1,s1,a5
    800019c4:	2485                	addiw	s1,s1,1
    800019c6:	00d4949b          	slliw	s1,s1,0xd
    800019ca:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ce:	4699                	li	a3,6
    800019d0:	6605                	lui	a2,0x1
    800019d2:	8526                	mv	a0,s1
    800019d4:	00000097          	auipc	ra,0x0
    800019d8:	85c080e7          	jalr	-1956(ra) # 80001230 <kvmmap>
      p->kstack = va;
    800019dc:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e0:	18090913          	addi	s2,s2,384
    800019e4:	fb491de3          	bne	s2,s4,8000199e <procinit+0x58>
  kvminithart();
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	650080e7          	jalr	1616(ra) # 80001038 <kvminithart>
}
    800019f0:	60a6                	ld	ra,72(sp)
    800019f2:	6406                	ld	s0,64(sp)
    800019f4:	74e2                	ld	s1,56(sp)
    800019f6:	7942                	ld	s2,48(sp)
    800019f8:	79a2                	ld	s3,40(sp)
    800019fa:	7a02                	ld	s4,32(sp)
    800019fc:	6ae2                	ld	s5,24(sp)
    800019fe:	6b42                	ld	s6,16(sp)
    80001a00:	6ba2                	ld	s7,8(sp)
    80001a02:	6161                	addi	sp,sp,80
    80001a04:	8082                	ret
        panic("kalloc");
    80001a06:	00006517          	auipc	a0,0x6
    80001a0a:	7f250513          	addi	a0,a0,2034 # 800081f8 <digits+0x1a0>
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	bc8080e7          	jalr	-1080(ra) # 800005d6 <panic>

0000000080001a16 <cpuid>:
{
    80001a16:	1141                	addi	sp,sp,-16
    80001a18:	e422                	sd	s0,8(sp)
    80001a1a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a1c:	8512                	mv	a0,tp
}
    80001a1e:	2501                	sext.w	a0,a0
    80001a20:	6422                	ld	s0,8(sp)
    80001a22:	0141                	addi	sp,sp,16
    80001a24:	8082                	ret

0000000080001a26 <mycpu>:
mycpu(void) {
    80001a26:	1141                	addi	sp,sp,-16
    80001a28:	e422                	sd	s0,8(sp)
    80001a2a:	0800                	addi	s0,sp,16
    80001a2c:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a2e:	2781                	sext.w	a5,a5
    80001a30:	079e                	slli	a5,a5,0x7
}
    80001a32:	00010517          	auipc	a0,0x10
    80001a36:	f3650513          	addi	a0,a0,-202 # 80011968 <cpus>
    80001a3a:	953e                	add	a0,a0,a5
    80001a3c:	6422                	ld	s0,8(sp)
    80001a3e:	0141                	addi	sp,sp,16
    80001a40:	8082                	ret

0000000080001a42 <myproc>:
myproc(void) {
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	1000                	addi	s0,sp,32
  push_off();
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	1dc080e7          	jalr	476(ra) # 80000c28 <push_off>
    80001a54:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a56:	2781                	sext.w	a5,a5
    80001a58:	079e                	slli	a5,a5,0x7
    80001a5a:	00010717          	auipc	a4,0x10
    80001a5e:	ef670713          	addi	a4,a4,-266 # 80011950 <pid_lock>
    80001a62:	97ba                	add	a5,a5,a4
    80001a64:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	262080e7          	jalr	610(ra) # 80000cc8 <pop_off>
}
    80001a6e:	8526                	mv	a0,s1
    80001a70:	60e2                	ld	ra,24(sp)
    80001a72:	6442                	ld	s0,16(sp)
    80001a74:	64a2                	ld	s1,8(sp)
    80001a76:	6105                	addi	sp,sp,32
    80001a78:	8082                	ret

0000000080001a7a <forkret>:
{
    80001a7a:	1141                	addi	sp,sp,-16
    80001a7c:	e406                	sd	ra,8(sp)
    80001a7e:	e022                	sd	s0,0(sp)
    80001a80:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a82:	00000097          	auipc	ra,0x0
    80001a86:	fc0080e7          	jalr	-64(ra) # 80001a42 <myproc>
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	29e080e7          	jalr	670(ra) # 80000d28 <release>
  if (first) {
    80001a92:	00007797          	auipc	a5,0x7
    80001a96:	dae7a783          	lw	a5,-594(a5) # 80008840 <first.1671>
    80001a9a:	eb89                	bnez	a5,80001aac <forkret+0x32>
  usertrapret();
    80001a9c:	00001097          	auipc	ra,0x1
    80001aa0:	c42080e7          	jalr	-958(ra) # 800026de <usertrapret>
}
    80001aa4:	60a2                	ld	ra,8(sp)
    80001aa6:	6402                	ld	s0,0(sp)
    80001aa8:	0141                	addi	sp,sp,16
    80001aaa:	8082                	ret
    first = 0;
    80001aac:	00007797          	auipc	a5,0x7
    80001ab0:	d807aa23          	sw	zero,-620(a5) # 80008840 <first.1671>
    fsinit(ROOTDEV);
    80001ab4:	4505                	li	a0,1
    80001ab6:	00002097          	auipc	ra,0x2
    80001aba:	9cc080e7          	jalr	-1588(ra) # 80003482 <fsinit>
    80001abe:	bff9                	j	80001a9c <forkret+0x22>

0000000080001ac0 <allocpid>:
allocpid() {
    80001ac0:	1101                	addi	sp,sp,-32
    80001ac2:	ec06                	sd	ra,24(sp)
    80001ac4:	e822                	sd	s0,16(sp)
    80001ac6:	e426                	sd	s1,8(sp)
    80001ac8:	e04a                	sd	s2,0(sp)
    80001aca:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001acc:	00010917          	auipc	s2,0x10
    80001ad0:	e8490913          	addi	s2,s2,-380 # 80011950 <pid_lock>
    80001ad4:	854a                	mv	a0,s2
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	19e080e7          	jalr	414(ra) # 80000c74 <acquire>
  pid = nextpid;
    80001ade:	00007797          	auipc	a5,0x7
    80001ae2:	d6678793          	addi	a5,a5,-666 # 80008844 <nextpid>
    80001ae6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ae8:	0014871b          	addiw	a4,s1,1
    80001aec:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aee:	854a                	mv	a0,s2
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	238080e7          	jalr	568(ra) # 80000d28 <release>
}
    80001af8:	8526                	mv	a0,s1
    80001afa:	60e2                	ld	ra,24(sp)
    80001afc:	6442                	ld	s0,16(sp)
    80001afe:	64a2                	ld	s1,8(sp)
    80001b00:	6902                	ld	s2,0(sp)
    80001b02:	6105                	addi	sp,sp,32
    80001b04:	8082                	ret

0000000080001b06 <proc_pagetable>:
{
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	addi	s0,sp,32
    80001b12:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b14:	00000097          	auipc	ra,0x0
    80001b18:	8ea080e7          	jalr	-1814(ra) # 800013fe <uvmcreate>
    80001b1c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b1e:	c121                	beqz	a0,80001b5e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b20:	4729                	li	a4,10
    80001b22:	00005697          	auipc	a3,0x5
    80001b26:	4de68693          	addi	a3,a3,1246 # 80007000 <_trampoline>
    80001b2a:	6605                	lui	a2,0x1
    80001b2c:	040005b7          	lui	a1,0x4000
    80001b30:	15fd                	addi	a1,a1,-1
    80001b32:	05b2                	slli	a1,a1,0xc
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	66e080e7          	jalr	1646(ra) # 800011a2 <mappages>
    80001b3c:	02054863          	bltz	a0,80001b6c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b40:	4719                	li	a4,6
    80001b42:	05893683          	ld	a3,88(s2)
    80001b46:	6605                	lui	a2,0x1
    80001b48:	020005b7          	lui	a1,0x2000
    80001b4c:	15fd                	addi	a1,a1,-1
    80001b4e:	05b6                	slli	a1,a1,0xd
    80001b50:	8526                	mv	a0,s1
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	650080e7          	jalr	1616(ra) # 800011a2 <mappages>
    80001b5a:	02054163          	bltz	a0,80001b7c <proc_pagetable+0x76>
}
    80001b5e:	8526                	mv	a0,s1
    80001b60:	60e2                	ld	ra,24(sp)
    80001b62:	6442                	ld	s0,16(sp)
    80001b64:	64a2                	ld	s1,8(sp)
    80001b66:	6902                	ld	s2,0(sp)
    80001b68:	6105                	addi	sp,sp,32
    80001b6a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b6c:	4581                	li	a1,0
    80001b6e:	8526                	mv	a0,s1
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	a8a080e7          	jalr	-1398(ra) # 800015fa <uvmfree>
    return 0;
    80001b78:	4481                	li	s1,0
    80001b7a:	b7d5                	j	80001b5e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b7c:	4681                	li	a3,0
    80001b7e:	4605                	li	a2,1
    80001b80:	040005b7          	lui	a1,0x4000
    80001b84:	15fd                	addi	a1,a1,-1
    80001b86:	05b2                	slli	a1,a1,0xc
    80001b88:	8526                	mv	a0,s1
    80001b8a:	fffff097          	auipc	ra,0xfffff
    80001b8e:	7b0080e7          	jalr	1968(ra) # 8000133a <uvmunmap>
    uvmfree(pagetable, 0);
    80001b92:	4581                	li	a1,0
    80001b94:	8526                	mv	a0,s1
    80001b96:	00000097          	auipc	ra,0x0
    80001b9a:	a64080e7          	jalr	-1436(ra) # 800015fa <uvmfree>
    return 0;
    80001b9e:	4481                	li	s1,0
    80001ba0:	bf7d                	j	80001b5e <proc_pagetable+0x58>

0000000080001ba2 <proc_freepagetable>:
{
    80001ba2:	1101                	addi	sp,sp,-32
    80001ba4:	ec06                	sd	ra,24(sp)
    80001ba6:	e822                	sd	s0,16(sp)
    80001ba8:	e426                	sd	s1,8(sp)
    80001baa:	e04a                	sd	s2,0(sp)
    80001bac:	1000                	addi	s0,sp,32
    80001bae:	84aa                	mv	s1,a0
    80001bb0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bb2:	4681                	li	a3,0
    80001bb4:	4605                	li	a2,1
    80001bb6:	040005b7          	lui	a1,0x4000
    80001bba:	15fd                	addi	a1,a1,-1
    80001bbc:	05b2                	slli	a1,a1,0xc
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	77c080e7          	jalr	1916(ra) # 8000133a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bc6:	4681                	li	a3,0
    80001bc8:	4605                	li	a2,1
    80001bca:	020005b7          	lui	a1,0x2000
    80001bce:	15fd                	addi	a1,a1,-1
    80001bd0:	05b6                	slli	a1,a1,0xd
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	766080e7          	jalr	1894(ra) # 8000133a <uvmunmap>
  uvmfree(pagetable, sz);
    80001bdc:	85ca                	mv	a1,s2
    80001bde:	8526                	mv	a0,s1
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	a1a080e7          	jalr	-1510(ra) # 800015fa <uvmfree>
}
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret

0000000080001bf4 <freeproc>:
{
    80001bf4:	1101                	addi	sp,sp,-32
    80001bf6:	ec06                	sd	ra,24(sp)
    80001bf8:	e822                	sd	s0,16(sp)
    80001bfa:	e426                	sd	s1,8(sp)
    80001bfc:	1000                	addi	s0,sp,32
    80001bfe:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c00:	6d28                	ld	a0,88(a0)
    80001c02:	c509                	beqz	a0,80001c0c <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	e84080e7          	jalr	-380(ra) # 80000a88 <kfree>
  p->trapframe = 0;
    80001c0c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c10:	68a8                	ld	a0,80(s1)
    80001c12:	c511                	beqz	a0,80001c1e <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c14:	64ac                	ld	a1,72(s1)
    80001c16:	00000097          	auipc	ra,0x0
    80001c1a:	f8c080e7          	jalr	-116(ra) # 80001ba2 <proc_freepagetable>
  p->pagetable = 0;
    80001c1e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c22:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c26:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c2a:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c2e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c32:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c36:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c3a:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c3e:	0004ac23          	sw	zero,24(s1)
  p->alarm = 0;
    80001c42:	1604a623          	sw	zero,364(s1)
  p->duration = 0;
    80001c46:	1604a423          	sw	zero,360(s1)
  p->handler = 0;
    80001c4a:	1604b823          	sd	zero,368(s1)
  if(p->alarm_trapframe)
    80001c4e:	1784b503          	ld	a0,376(s1)
    80001c52:	c509                	beqz	a0,80001c5c <freeproc+0x68>
    kfree((void*)p->alarm_trapframe);
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	e34080e7          	jalr	-460(ra) # 80000a88 <kfree>
  p->alarm_trapframe = 0;
    80001c5c:	1604bc23          	sd	zero,376(s1)
}
    80001c60:	60e2                	ld	ra,24(sp)
    80001c62:	6442                	ld	s0,16(sp)
    80001c64:	64a2                	ld	s1,8(sp)
    80001c66:	6105                	addi	sp,sp,32
    80001c68:	8082                	ret

0000000080001c6a <allocproc>:
{
    80001c6a:	1101                	addi	sp,sp,-32
    80001c6c:	ec06                	sd	ra,24(sp)
    80001c6e:	e822                	sd	s0,16(sp)
    80001c70:	e426                	sd	s1,8(sp)
    80001c72:	e04a                	sd	s2,0(sp)
    80001c74:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c76:	00010497          	auipc	s1,0x10
    80001c7a:	0f248493          	addi	s1,s1,242 # 80011d68 <proc>
    80001c7e:	00016917          	auipc	s2,0x16
    80001c82:	0ea90913          	addi	s2,s2,234 # 80017d68 <tickslock>
    acquire(&p->lock);
    80001c86:	8526                	mv	a0,s1
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	fec080e7          	jalr	-20(ra) # 80000c74 <acquire>
    if(p->state == UNUSED) {
    80001c90:	4c9c                	lw	a5,24(s1)
    80001c92:	cf81                	beqz	a5,80001caa <allocproc+0x40>
      release(&p->lock);
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	092080e7          	jalr	146(ra) # 80000d28 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c9e:	18048493          	addi	s1,s1,384
    80001ca2:	ff2492e3          	bne	s1,s2,80001c86 <allocproc+0x1c>
  return 0;
    80001ca6:	4481                	li	s1,0
    80001ca8:	a8a9                	j	80001d02 <allocproc+0x98>
  p->pid = allocpid();
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	e16080e7          	jalr	-490(ra) # 80001ac0 <allocpid>
    80001cb2:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cb4:	fffff097          	auipc	ra,0xfffff
    80001cb8:	ed0080e7          	jalr	-304(ra) # 80000b84 <kalloc>
    80001cbc:	892a                	mv	s2,a0
    80001cbe:	eca8                	sd	a0,88(s1)
    80001cc0:	c921                	beqz	a0,80001d10 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	00000097          	auipc	ra,0x0
    80001cc8:	e42080e7          	jalr	-446(ra) # 80001b06 <proc_pagetable>
    80001ccc:	892a                	mv	s2,a0
    80001cce:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cd0:	c539                	beqz	a0,80001d1e <allocproc+0xb4>
  memset(&p->context, 0, sizeof(p->context));
    80001cd2:	07000613          	li	a2,112
    80001cd6:	4581                	li	a1,0
    80001cd8:	06048513          	addi	a0,s1,96
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	094080e7          	jalr	148(ra) # 80000d70 <memset>
  p->context.ra = (uint64)forkret;
    80001ce4:	00000797          	auipc	a5,0x0
    80001ce8:	d9678793          	addi	a5,a5,-618 # 80001a7a <forkret>
    80001cec:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cee:	60bc                	ld	a5,64(s1)
    80001cf0:	6705                	lui	a4,0x1
    80001cf2:	97ba                	add	a5,a5,a4
    80001cf4:	f4bc                	sd	a5,104(s1)
  p->alarm = 0;
    80001cf6:	1604a623          	sw	zero,364(s1)
  p->duration = 0;
    80001cfa:	1604a423          	sw	zero,360(s1)
  p->handler = 0;
    80001cfe:	1604b823          	sd	zero,368(s1)
}
    80001d02:	8526                	mv	a0,s1
    80001d04:	60e2                	ld	ra,24(sp)
    80001d06:	6442                	ld	s0,16(sp)
    80001d08:	64a2                	ld	s1,8(sp)
    80001d0a:	6902                	ld	s2,0(sp)
    80001d0c:	6105                	addi	sp,sp,32
    80001d0e:	8082                	ret
    release(&p->lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	016080e7          	jalr	22(ra) # 80000d28 <release>
    return 0;
    80001d1a:	84ca                	mv	s1,s2
    80001d1c:	b7dd                	j	80001d02 <allocproc+0x98>
    freeproc(p);
    80001d1e:	8526                	mv	a0,s1
    80001d20:	00000097          	auipc	ra,0x0
    80001d24:	ed4080e7          	jalr	-300(ra) # 80001bf4 <freeproc>
    release(&p->lock);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	ffe080e7          	jalr	-2(ra) # 80000d28 <release>
    return 0;
    80001d32:	84ca                	mv	s1,s2
    80001d34:	b7f9                	j	80001d02 <allocproc+0x98>

0000000080001d36 <userinit>:
{
    80001d36:	1101                	addi	sp,sp,-32
    80001d38:	ec06                	sd	ra,24(sp)
    80001d3a:	e822                	sd	s0,16(sp)
    80001d3c:	e426                	sd	s1,8(sp)
    80001d3e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d40:	00000097          	auipc	ra,0x0
    80001d44:	f2a080e7          	jalr	-214(ra) # 80001c6a <allocproc>
    80001d48:	84aa                	mv	s1,a0
  initproc = p;
    80001d4a:	00007797          	auipc	a5,0x7
    80001d4e:	2ca7b723          	sd	a0,718(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d52:	03400613          	li	a2,52
    80001d56:	00007597          	auipc	a1,0x7
    80001d5a:	afa58593          	addi	a1,a1,-1286 # 80008850 <initcode>
    80001d5e:	6928                	ld	a0,80(a0)
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	6cc080e7          	jalr	1740(ra) # 8000142c <uvminit>
  p->sz = PGSIZE;
    80001d68:	6785                	lui	a5,0x1
    80001d6a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d6c:	6cb8                	ld	a4,88(s1)
    80001d6e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d72:	6cb8                	ld	a4,88(s1)
    80001d74:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d76:	4641                	li	a2,16
    80001d78:	00006597          	auipc	a1,0x6
    80001d7c:	48858593          	addi	a1,a1,1160 # 80008200 <digits+0x1a8>
    80001d80:	15848513          	addi	a0,s1,344
    80001d84:	fffff097          	auipc	ra,0xfffff
    80001d88:	142080e7          	jalr	322(ra) # 80000ec6 <safestrcpy>
  p->cwd = namei("/");
    80001d8c:	00006517          	auipc	a0,0x6
    80001d90:	48450513          	addi	a0,a0,1156 # 80008210 <digits+0x1b8>
    80001d94:	00002097          	auipc	ra,0x2
    80001d98:	116080e7          	jalr	278(ra) # 80003eaa <namei>
    80001d9c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001da0:	4789                	li	a5,2
    80001da2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001da4:	8526                	mv	a0,s1
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	f82080e7          	jalr	-126(ra) # 80000d28 <release>
}
    80001dae:	60e2                	ld	ra,24(sp)
    80001db0:	6442                	ld	s0,16(sp)
    80001db2:	64a2                	ld	s1,8(sp)
    80001db4:	6105                	addi	sp,sp,32
    80001db6:	8082                	ret

0000000080001db8 <growproc>:
{
    80001db8:	1101                	addi	sp,sp,-32
    80001dba:	ec06                	sd	ra,24(sp)
    80001dbc:	e822                	sd	s0,16(sp)
    80001dbe:	e426                	sd	s1,8(sp)
    80001dc0:	e04a                	sd	s2,0(sp)
    80001dc2:	1000                	addi	s0,sp,32
    80001dc4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dc6:	00000097          	auipc	ra,0x0
    80001dca:	c7c080e7          	jalr	-900(ra) # 80001a42 <myproc>
    80001dce:	892a                	mv	s2,a0
  sz = p->sz;
    80001dd0:	652c                	ld	a1,72(a0)
    80001dd2:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dd6:	00904f63          	bgtz	s1,80001df4 <growproc+0x3c>
  } else if(n < 0){
    80001dda:	0204cc63          	bltz	s1,80001e12 <growproc+0x5a>
  p->sz = sz;
    80001dde:	1602                	slli	a2,a2,0x20
    80001de0:	9201                	srli	a2,a2,0x20
    80001de2:	04c93423          	sd	a2,72(s2)
  return 0;
    80001de6:	4501                	li	a0,0
}
    80001de8:	60e2                	ld	ra,24(sp)
    80001dea:	6442                	ld	s0,16(sp)
    80001dec:	64a2                	ld	s1,8(sp)
    80001dee:	6902                	ld	s2,0(sp)
    80001df0:	6105                	addi	sp,sp,32
    80001df2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001df4:	9e25                	addw	a2,a2,s1
    80001df6:	1602                	slli	a2,a2,0x20
    80001df8:	9201                	srli	a2,a2,0x20
    80001dfa:	1582                	slli	a1,a1,0x20
    80001dfc:	9181                	srli	a1,a1,0x20
    80001dfe:	6928                	ld	a0,80(a0)
    80001e00:	fffff097          	auipc	ra,0xfffff
    80001e04:	6e6080e7          	jalr	1766(ra) # 800014e6 <uvmalloc>
    80001e08:	0005061b          	sext.w	a2,a0
    80001e0c:	fa69                	bnez	a2,80001dde <growproc+0x26>
      return -1;
    80001e0e:	557d                	li	a0,-1
    80001e10:	bfe1                	j	80001de8 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e12:	9e25                	addw	a2,a2,s1
    80001e14:	1602                	slli	a2,a2,0x20
    80001e16:	9201                	srli	a2,a2,0x20
    80001e18:	1582                	slli	a1,a1,0x20
    80001e1a:	9181                	srli	a1,a1,0x20
    80001e1c:	6928                	ld	a0,80(a0)
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	680080e7          	jalr	1664(ra) # 8000149e <uvmdealloc>
    80001e26:	0005061b          	sext.w	a2,a0
    80001e2a:	bf55                	j	80001dde <growproc+0x26>

0000000080001e2c <fork>:
{
    80001e2c:	7179                	addi	sp,sp,-48
    80001e2e:	f406                	sd	ra,40(sp)
    80001e30:	f022                	sd	s0,32(sp)
    80001e32:	ec26                	sd	s1,24(sp)
    80001e34:	e84a                	sd	s2,16(sp)
    80001e36:	e44e                	sd	s3,8(sp)
    80001e38:	e052                	sd	s4,0(sp)
    80001e3a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e3c:	00000097          	auipc	ra,0x0
    80001e40:	c06080e7          	jalr	-1018(ra) # 80001a42 <myproc>
    80001e44:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e46:	00000097          	auipc	ra,0x0
    80001e4a:	e24080e7          	jalr	-476(ra) # 80001c6a <allocproc>
    80001e4e:	c175                	beqz	a0,80001f32 <fork+0x106>
    80001e50:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e52:	04893603          	ld	a2,72(s2)
    80001e56:	692c                	ld	a1,80(a0)
    80001e58:	05093503          	ld	a0,80(s2)
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	7d6080e7          	jalr	2006(ra) # 80001632 <uvmcopy>
    80001e64:	04054863          	bltz	a0,80001eb4 <fork+0x88>
  np->sz = p->sz;
    80001e68:	04893783          	ld	a5,72(s2)
    80001e6c:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001e70:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e74:	05893683          	ld	a3,88(s2)
    80001e78:	87b6                	mv	a5,a3
    80001e7a:	0589b703          	ld	a4,88(s3)
    80001e7e:	12068693          	addi	a3,a3,288
    80001e82:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e86:	6788                	ld	a0,8(a5)
    80001e88:	6b8c                	ld	a1,16(a5)
    80001e8a:	6f90                	ld	a2,24(a5)
    80001e8c:	01073023          	sd	a6,0(a4)
    80001e90:	e708                	sd	a0,8(a4)
    80001e92:	eb0c                	sd	a1,16(a4)
    80001e94:	ef10                	sd	a2,24(a4)
    80001e96:	02078793          	addi	a5,a5,32
    80001e9a:	02070713          	addi	a4,a4,32
    80001e9e:	fed792e3          	bne	a5,a3,80001e82 <fork+0x56>
  np->trapframe->a0 = 0;
    80001ea2:	0589b783          	ld	a5,88(s3)
    80001ea6:	0607b823          	sd	zero,112(a5)
    80001eaa:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001eae:	15000a13          	li	s4,336
    80001eb2:	a03d                	j	80001ee0 <fork+0xb4>
    freeproc(np);
    80001eb4:	854e                	mv	a0,s3
    80001eb6:	00000097          	auipc	ra,0x0
    80001eba:	d3e080e7          	jalr	-706(ra) # 80001bf4 <freeproc>
    release(&np->lock);
    80001ebe:	854e                	mv	a0,s3
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	e68080e7          	jalr	-408(ra) # 80000d28 <release>
    return -1;
    80001ec8:	54fd                	li	s1,-1
    80001eca:	a899                	j	80001f20 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ecc:	00002097          	auipc	ra,0x2
    80001ed0:	66a080e7          	jalr	1642(ra) # 80004536 <filedup>
    80001ed4:	009987b3          	add	a5,s3,s1
    80001ed8:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001eda:	04a1                	addi	s1,s1,8
    80001edc:	01448763          	beq	s1,s4,80001eea <fork+0xbe>
    if(p->ofile[i])
    80001ee0:	009907b3          	add	a5,s2,s1
    80001ee4:	6388                	ld	a0,0(a5)
    80001ee6:	f17d                	bnez	a0,80001ecc <fork+0xa0>
    80001ee8:	bfcd                	j	80001eda <fork+0xae>
  np->cwd = idup(p->cwd);
    80001eea:	15093503          	ld	a0,336(s2)
    80001eee:	00001097          	auipc	ra,0x1
    80001ef2:	7ce080e7          	jalr	1998(ra) # 800036bc <idup>
    80001ef6:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001efa:	4641                	li	a2,16
    80001efc:	15890593          	addi	a1,s2,344
    80001f00:	15898513          	addi	a0,s3,344
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	fc2080e7          	jalr	-62(ra) # 80000ec6 <safestrcpy>
  pid = np->pid;
    80001f0c:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001f10:	4789                	li	a5,2
    80001f12:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f16:	854e                	mv	a0,s3
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	e10080e7          	jalr	-496(ra) # 80000d28 <release>
}
    80001f20:	8526                	mv	a0,s1
    80001f22:	70a2                	ld	ra,40(sp)
    80001f24:	7402                	ld	s0,32(sp)
    80001f26:	64e2                	ld	s1,24(sp)
    80001f28:	6942                	ld	s2,16(sp)
    80001f2a:	69a2                	ld	s3,8(sp)
    80001f2c:	6a02                	ld	s4,0(sp)
    80001f2e:	6145                	addi	sp,sp,48
    80001f30:	8082                	ret
    return -1;
    80001f32:	54fd                	li	s1,-1
    80001f34:	b7f5                	j	80001f20 <fork+0xf4>

0000000080001f36 <reparent>:
{
    80001f36:	7179                	addi	sp,sp,-48
    80001f38:	f406                	sd	ra,40(sp)
    80001f3a:	f022                	sd	s0,32(sp)
    80001f3c:	ec26                	sd	s1,24(sp)
    80001f3e:	e84a                	sd	s2,16(sp)
    80001f40:	e44e                	sd	s3,8(sp)
    80001f42:	e052                	sd	s4,0(sp)
    80001f44:	1800                	addi	s0,sp,48
    80001f46:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f48:	00010497          	auipc	s1,0x10
    80001f4c:	e2048493          	addi	s1,s1,-480 # 80011d68 <proc>
      pp->parent = initproc;
    80001f50:	00007a17          	auipc	s4,0x7
    80001f54:	0c8a0a13          	addi	s4,s4,200 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f58:	00016997          	auipc	s3,0x16
    80001f5c:	e1098993          	addi	s3,s3,-496 # 80017d68 <tickslock>
    80001f60:	a029                	j	80001f6a <reparent+0x34>
    80001f62:	18048493          	addi	s1,s1,384
    80001f66:	03348363          	beq	s1,s3,80001f8c <reparent+0x56>
    if(pp->parent == p){
    80001f6a:	709c                	ld	a5,32(s1)
    80001f6c:	ff279be3          	bne	a5,s2,80001f62 <reparent+0x2c>
      acquire(&pp->lock);
    80001f70:	8526                	mv	a0,s1
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	d02080e7          	jalr	-766(ra) # 80000c74 <acquire>
      pp->parent = initproc;
    80001f7a:	000a3783          	ld	a5,0(s4)
    80001f7e:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f80:	8526                	mv	a0,s1
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	da6080e7          	jalr	-602(ra) # 80000d28 <release>
    80001f8a:	bfe1                	j	80001f62 <reparent+0x2c>
}
    80001f8c:	70a2                	ld	ra,40(sp)
    80001f8e:	7402                	ld	s0,32(sp)
    80001f90:	64e2                	ld	s1,24(sp)
    80001f92:	6942                	ld	s2,16(sp)
    80001f94:	69a2                	ld	s3,8(sp)
    80001f96:	6a02                	ld	s4,0(sp)
    80001f98:	6145                	addi	sp,sp,48
    80001f9a:	8082                	ret

0000000080001f9c <scheduler>:
{
    80001f9c:	715d                	addi	sp,sp,-80
    80001f9e:	e486                	sd	ra,72(sp)
    80001fa0:	e0a2                	sd	s0,64(sp)
    80001fa2:	fc26                	sd	s1,56(sp)
    80001fa4:	f84a                	sd	s2,48(sp)
    80001fa6:	f44e                	sd	s3,40(sp)
    80001fa8:	f052                	sd	s4,32(sp)
    80001faa:	ec56                	sd	s5,24(sp)
    80001fac:	e85a                	sd	s6,16(sp)
    80001fae:	e45e                	sd	s7,8(sp)
    80001fb0:	e062                	sd	s8,0(sp)
    80001fb2:	0880                	addi	s0,sp,80
    80001fb4:	8792                	mv	a5,tp
  int id = r_tp();
    80001fb6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fb8:	00779b13          	slli	s6,a5,0x7
    80001fbc:	00010717          	auipc	a4,0x10
    80001fc0:	99470713          	addi	a4,a4,-1644 # 80011950 <pid_lock>
    80001fc4:	975a                	add	a4,a4,s6
    80001fc6:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001fca:	00010717          	auipc	a4,0x10
    80001fce:	9a670713          	addi	a4,a4,-1626 # 80011970 <cpus+0x8>
    80001fd2:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fd4:	4c0d                	li	s8,3
        c->proc = p;
    80001fd6:	079e                	slli	a5,a5,0x7
    80001fd8:	00010a17          	auipc	s4,0x10
    80001fdc:	978a0a13          	addi	s4,s4,-1672 # 80011950 <pid_lock>
    80001fe0:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fe2:	00016997          	auipc	s3,0x16
    80001fe6:	d8698993          	addi	s3,s3,-634 # 80017d68 <tickslock>
        found = 1;
    80001fea:	4b85                	li	s7,1
    80001fec:	a899                	j	80002042 <scheduler+0xa6>
        p->state = RUNNING;
    80001fee:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001ff2:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001ff6:	06048593          	addi	a1,s1,96
    80001ffa:	855a                	mv	a0,s6
    80001ffc:	00000097          	auipc	ra,0x0
    80002000:	638080e7          	jalr	1592(ra) # 80002634 <swtch>
        c->proc = 0;
    80002004:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80002008:	8ade                	mv	s5,s7
      release(&p->lock);
    8000200a:	8526                	mv	a0,s1
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	d1c080e7          	jalr	-740(ra) # 80000d28 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002014:	18048493          	addi	s1,s1,384
    80002018:	01348b63          	beq	s1,s3,8000202e <scheduler+0x92>
      acquire(&p->lock);
    8000201c:	8526                	mv	a0,s1
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	c56080e7          	jalr	-938(ra) # 80000c74 <acquire>
      if(p->state == RUNNABLE) {
    80002026:	4c9c                	lw	a5,24(s1)
    80002028:	ff2791e3          	bne	a5,s2,8000200a <scheduler+0x6e>
    8000202c:	b7c9                	j	80001fee <scheduler+0x52>
    if(found == 0) {
    8000202e:	000a9a63          	bnez	s5,80002042 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002032:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002036:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000203a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000203e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002042:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002046:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000204a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000204e:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002050:	00010497          	auipc	s1,0x10
    80002054:	d1848493          	addi	s1,s1,-744 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002058:	4909                	li	s2,2
    8000205a:	b7c9                	j	8000201c <scheduler+0x80>

000000008000205c <sched>:
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000206a:	00000097          	auipc	ra,0x0
    8000206e:	9d8080e7          	jalr	-1576(ra) # 80001a42 <myproc>
    80002072:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	b86080e7          	jalr	-1146(ra) # 80000bfa <holding>
    8000207c:	c93d                	beqz	a0,800020f2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000207e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002080:	2781                	sext.w	a5,a5
    80002082:	079e                	slli	a5,a5,0x7
    80002084:	00010717          	auipc	a4,0x10
    80002088:	8cc70713          	addi	a4,a4,-1844 # 80011950 <pid_lock>
    8000208c:	97ba                	add	a5,a5,a4
    8000208e:	0907a703          	lw	a4,144(a5)
    80002092:	4785                	li	a5,1
    80002094:	06f71763          	bne	a4,a5,80002102 <sched+0xa6>
  if(p->state == RUNNING)
    80002098:	4c98                	lw	a4,24(s1)
    8000209a:	478d                	li	a5,3
    8000209c:	06f70b63          	beq	a4,a5,80002112 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020a0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020a4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020a6:	efb5                	bnez	a5,80002122 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020a8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020aa:	00010917          	auipc	s2,0x10
    800020ae:	8a690913          	addi	s2,s2,-1882 # 80011950 <pid_lock>
    800020b2:	2781                	sext.w	a5,a5
    800020b4:	079e                	slli	a5,a5,0x7
    800020b6:	97ca                	add	a5,a5,s2
    800020b8:	0947a983          	lw	s3,148(a5)
    800020bc:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020be:	2781                	sext.w	a5,a5
    800020c0:	079e                	slli	a5,a5,0x7
    800020c2:	00010597          	auipc	a1,0x10
    800020c6:	8ae58593          	addi	a1,a1,-1874 # 80011970 <cpus+0x8>
    800020ca:	95be                	add	a1,a1,a5
    800020cc:	06048513          	addi	a0,s1,96
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	564080e7          	jalr	1380(ra) # 80002634 <swtch>
    800020d8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020da:	2781                	sext.w	a5,a5
    800020dc:	079e                	slli	a5,a5,0x7
    800020de:	97ca                	add	a5,a5,s2
    800020e0:	0937aa23          	sw	s3,148(a5)
}
    800020e4:	70a2                	ld	ra,40(sp)
    800020e6:	7402                	ld	s0,32(sp)
    800020e8:	64e2                	ld	s1,24(sp)
    800020ea:	6942                	ld	s2,16(sp)
    800020ec:	69a2                	ld	s3,8(sp)
    800020ee:	6145                	addi	sp,sp,48
    800020f0:	8082                	ret
    panic("sched p->lock");
    800020f2:	00006517          	auipc	a0,0x6
    800020f6:	12650513          	addi	a0,a0,294 # 80008218 <digits+0x1c0>
    800020fa:	ffffe097          	auipc	ra,0xffffe
    800020fe:	4dc080e7          	jalr	1244(ra) # 800005d6 <panic>
    panic("sched locks");
    80002102:	00006517          	auipc	a0,0x6
    80002106:	12650513          	addi	a0,a0,294 # 80008228 <digits+0x1d0>
    8000210a:	ffffe097          	auipc	ra,0xffffe
    8000210e:	4cc080e7          	jalr	1228(ra) # 800005d6 <panic>
    panic("sched running");
    80002112:	00006517          	auipc	a0,0x6
    80002116:	12650513          	addi	a0,a0,294 # 80008238 <digits+0x1e0>
    8000211a:	ffffe097          	auipc	ra,0xffffe
    8000211e:	4bc080e7          	jalr	1212(ra) # 800005d6 <panic>
    panic("sched interruptible");
    80002122:	00006517          	auipc	a0,0x6
    80002126:	12650513          	addi	a0,a0,294 # 80008248 <digits+0x1f0>
    8000212a:	ffffe097          	auipc	ra,0xffffe
    8000212e:	4ac080e7          	jalr	1196(ra) # 800005d6 <panic>

0000000080002132 <exit>:
{
    80002132:	7179                	addi	sp,sp,-48
    80002134:	f406                	sd	ra,40(sp)
    80002136:	f022                	sd	s0,32(sp)
    80002138:	ec26                	sd	s1,24(sp)
    8000213a:	e84a                	sd	s2,16(sp)
    8000213c:	e44e                	sd	s3,8(sp)
    8000213e:	e052                	sd	s4,0(sp)
    80002140:	1800                	addi	s0,sp,48
    80002142:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002144:	00000097          	auipc	ra,0x0
    80002148:	8fe080e7          	jalr	-1794(ra) # 80001a42 <myproc>
    8000214c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000214e:	00007797          	auipc	a5,0x7
    80002152:	eca7b783          	ld	a5,-310(a5) # 80009018 <initproc>
    80002156:	0d050493          	addi	s1,a0,208
    8000215a:	15050913          	addi	s2,a0,336
    8000215e:	02a79363          	bne	a5,a0,80002184 <exit+0x52>
    panic("init exiting");
    80002162:	00006517          	auipc	a0,0x6
    80002166:	0fe50513          	addi	a0,a0,254 # 80008260 <digits+0x208>
    8000216a:	ffffe097          	auipc	ra,0xffffe
    8000216e:	46c080e7          	jalr	1132(ra) # 800005d6 <panic>
      fileclose(f);
    80002172:	00002097          	auipc	ra,0x2
    80002176:	416080e7          	jalr	1046(ra) # 80004588 <fileclose>
      p->ofile[fd] = 0;
    8000217a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000217e:	04a1                	addi	s1,s1,8
    80002180:	01248563          	beq	s1,s2,8000218a <exit+0x58>
    if(p->ofile[fd]){
    80002184:	6088                	ld	a0,0(s1)
    80002186:	f575                	bnez	a0,80002172 <exit+0x40>
    80002188:	bfdd                	j	8000217e <exit+0x4c>
  begin_op();
    8000218a:	00002097          	auipc	ra,0x2
    8000218e:	f2c080e7          	jalr	-212(ra) # 800040b6 <begin_op>
  iput(p->cwd);
    80002192:	1509b503          	ld	a0,336(s3)
    80002196:	00001097          	auipc	ra,0x1
    8000219a:	71e080e7          	jalr	1822(ra) # 800038b4 <iput>
  end_op();
    8000219e:	00002097          	auipc	ra,0x2
    800021a2:	f98080e7          	jalr	-104(ra) # 80004136 <end_op>
  p->cwd = 0;
    800021a6:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800021aa:	00007497          	auipc	s1,0x7
    800021ae:	e6e48493          	addi	s1,s1,-402 # 80009018 <initproc>
    800021b2:	6088                	ld	a0,0(s1)
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	ac0080e7          	jalr	-1344(ra) # 80000c74 <acquire>
  wakeup1(initproc);
    800021bc:	6088                	ld	a0,0(s1)
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	744080e7          	jalr	1860(ra) # 80001902 <wakeup1>
  release(&initproc->lock);
    800021c6:	6088                	ld	a0,0(s1)
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	b60080e7          	jalr	-1184(ra) # 80000d28 <release>
  acquire(&p->lock);
    800021d0:	854e                	mv	a0,s3
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	aa2080e7          	jalr	-1374(ra) # 80000c74 <acquire>
  struct proc *original_parent = p->parent;
    800021da:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021de:	854e                	mv	a0,s3
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	b48080e7          	jalr	-1208(ra) # 80000d28 <release>
  acquire(&original_parent->lock);
    800021e8:	8526                	mv	a0,s1
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	a8a080e7          	jalr	-1398(ra) # 80000c74 <acquire>
  acquire(&p->lock);
    800021f2:	854e                	mv	a0,s3
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	a80080e7          	jalr	-1408(ra) # 80000c74 <acquire>
  reparent(p);
    800021fc:	854e                	mv	a0,s3
    800021fe:	00000097          	auipc	ra,0x0
    80002202:	d38080e7          	jalr	-712(ra) # 80001f36 <reparent>
  wakeup1(original_parent);
    80002206:	8526                	mv	a0,s1
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	6fa080e7          	jalr	1786(ra) # 80001902 <wakeup1>
  p->xstate = status;
    80002210:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002214:	4791                	li	a5,4
    80002216:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000221a:	8526                	mv	a0,s1
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	b0c080e7          	jalr	-1268(ra) # 80000d28 <release>
  sched();
    80002224:	00000097          	auipc	ra,0x0
    80002228:	e38080e7          	jalr	-456(ra) # 8000205c <sched>
  panic("zombie exit");
    8000222c:	00006517          	auipc	a0,0x6
    80002230:	04450513          	addi	a0,a0,68 # 80008270 <digits+0x218>
    80002234:	ffffe097          	auipc	ra,0xffffe
    80002238:	3a2080e7          	jalr	930(ra) # 800005d6 <panic>

000000008000223c <yield>:
{
    8000223c:	1101                	addi	sp,sp,-32
    8000223e:	ec06                	sd	ra,24(sp)
    80002240:	e822                	sd	s0,16(sp)
    80002242:	e426                	sd	s1,8(sp)
    80002244:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	7fc080e7          	jalr	2044(ra) # 80001a42 <myproc>
    8000224e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	a24080e7          	jalr	-1500(ra) # 80000c74 <acquire>
  p->state = RUNNABLE;
    80002258:	4789                	li	a5,2
    8000225a:	cc9c                	sw	a5,24(s1)
  sched();
    8000225c:	00000097          	auipc	ra,0x0
    80002260:	e00080e7          	jalr	-512(ra) # 8000205c <sched>
  release(&p->lock);
    80002264:	8526                	mv	a0,s1
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	ac2080e7          	jalr	-1342(ra) # 80000d28 <release>
}
    8000226e:	60e2                	ld	ra,24(sp)
    80002270:	6442                	ld	s0,16(sp)
    80002272:	64a2                	ld	s1,8(sp)
    80002274:	6105                	addi	sp,sp,32
    80002276:	8082                	ret

0000000080002278 <sleep>:
{
    80002278:	7179                	addi	sp,sp,-48
    8000227a:	f406                	sd	ra,40(sp)
    8000227c:	f022                	sd	s0,32(sp)
    8000227e:	ec26                	sd	s1,24(sp)
    80002280:	e84a                	sd	s2,16(sp)
    80002282:	e44e                	sd	s3,8(sp)
    80002284:	1800                	addi	s0,sp,48
    80002286:	89aa                	mv	s3,a0
    80002288:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	7b8080e7          	jalr	1976(ra) # 80001a42 <myproc>
    80002292:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002294:	05250663          	beq	a0,s2,800022e0 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	9dc080e7          	jalr	-1572(ra) # 80000c74 <acquire>
    release(lk);
    800022a0:	854a                	mv	a0,s2
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	a86080e7          	jalr	-1402(ra) # 80000d28 <release>
  p->chan = chan;
    800022aa:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800022ae:	4785                	li	a5,1
    800022b0:	cc9c                	sw	a5,24(s1)
  sched();
    800022b2:	00000097          	auipc	ra,0x0
    800022b6:	daa080e7          	jalr	-598(ra) # 8000205c <sched>
  p->chan = 0;
    800022ba:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800022be:	8526                	mv	a0,s1
    800022c0:	fffff097          	auipc	ra,0xfffff
    800022c4:	a68080e7          	jalr	-1432(ra) # 80000d28 <release>
    acquire(lk);
    800022c8:	854a                	mv	a0,s2
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	9aa080e7          	jalr	-1622(ra) # 80000c74 <acquire>
}
    800022d2:	70a2                	ld	ra,40(sp)
    800022d4:	7402                	ld	s0,32(sp)
    800022d6:	64e2                	ld	s1,24(sp)
    800022d8:	6942                	ld	s2,16(sp)
    800022da:	69a2                	ld	s3,8(sp)
    800022dc:	6145                	addi	sp,sp,48
    800022de:	8082                	ret
  p->chan = chan;
    800022e0:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022e4:	4785                	li	a5,1
    800022e6:	cd1c                	sw	a5,24(a0)
  sched();
    800022e8:	00000097          	auipc	ra,0x0
    800022ec:	d74080e7          	jalr	-652(ra) # 8000205c <sched>
  p->chan = 0;
    800022f0:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022f4:	bff9                	j	800022d2 <sleep+0x5a>

00000000800022f6 <wait>:
{
    800022f6:	715d                	addi	sp,sp,-80
    800022f8:	e486                	sd	ra,72(sp)
    800022fa:	e0a2                	sd	s0,64(sp)
    800022fc:	fc26                	sd	s1,56(sp)
    800022fe:	f84a                	sd	s2,48(sp)
    80002300:	f44e                	sd	s3,40(sp)
    80002302:	f052                	sd	s4,32(sp)
    80002304:	ec56                	sd	s5,24(sp)
    80002306:	e85a                	sd	s6,16(sp)
    80002308:	e45e                	sd	s7,8(sp)
    8000230a:	e062                	sd	s8,0(sp)
    8000230c:	0880                	addi	s0,sp,80
    8000230e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	732080e7          	jalr	1842(ra) # 80001a42 <myproc>
    80002318:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000231a:	8c2a                	mv	s8,a0
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	958080e7          	jalr	-1704(ra) # 80000c74 <acquire>
    havekids = 0;
    80002324:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002326:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002328:	00016997          	auipc	s3,0x16
    8000232c:	a4098993          	addi	s3,s3,-1472 # 80017d68 <tickslock>
        havekids = 1;
    80002330:	4a85                	li	s5,1
    havekids = 0;
    80002332:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002334:	00010497          	auipc	s1,0x10
    80002338:	a3448493          	addi	s1,s1,-1484 # 80011d68 <proc>
    8000233c:	a08d                	j	8000239e <wait+0xa8>
          pid = np->pid;
    8000233e:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002342:	000b0e63          	beqz	s6,8000235e <wait+0x68>
    80002346:	4691                	li	a3,4
    80002348:	03448613          	addi	a2,s1,52
    8000234c:	85da                	mv	a1,s6
    8000234e:	05093503          	ld	a0,80(s2)
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	3e4080e7          	jalr	996(ra) # 80001736 <copyout>
    8000235a:	02054263          	bltz	a0,8000237e <wait+0x88>
          freeproc(np);
    8000235e:	8526                	mv	a0,s1
    80002360:	00000097          	auipc	ra,0x0
    80002364:	894080e7          	jalr	-1900(ra) # 80001bf4 <freeproc>
          release(&np->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	9be080e7          	jalr	-1602(ra) # 80000d28 <release>
          release(&p->lock);
    80002372:	854a                	mv	a0,s2
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	9b4080e7          	jalr	-1612(ra) # 80000d28 <release>
          return pid;
    8000237c:	a8a9                	j	800023d6 <wait+0xe0>
            release(&np->lock);
    8000237e:	8526                	mv	a0,s1
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	9a8080e7          	jalr	-1624(ra) # 80000d28 <release>
            release(&p->lock);
    80002388:	854a                	mv	a0,s2
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	99e080e7          	jalr	-1634(ra) # 80000d28 <release>
            return -1;
    80002392:	59fd                	li	s3,-1
    80002394:	a089                	j	800023d6 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002396:	18048493          	addi	s1,s1,384
    8000239a:	03348463          	beq	s1,s3,800023c2 <wait+0xcc>
      if(np->parent == p){
    8000239e:	709c                	ld	a5,32(s1)
    800023a0:	ff279be3          	bne	a5,s2,80002396 <wait+0xa0>
        acquire(&np->lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	8ce080e7          	jalr	-1842(ra) # 80000c74 <acquire>
        if(np->state == ZOMBIE){
    800023ae:	4c9c                	lw	a5,24(s1)
    800023b0:	f94787e3          	beq	a5,s4,8000233e <wait+0x48>
        release(&np->lock);
    800023b4:	8526                	mv	a0,s1
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	972080e7          	jalr	-1678(ra) # 80000d28 <release>
        havekids = 1;
    800023be:	8756                	mv	a4,s5
    800023c0:	bfd9                	j	80002396 <wait+0xa0>
    if(!havekids || p->killed){
    800023c2:	c701                	beqz	a4,800023ca <wait+0xd4>
    800023c4:	03092783          	lw	a5,48(s2)
    800023c8:	c785                	beqz	a5,800023f0 <wait+0xfa>
      release(&p->lock);
    800023ca:	854a                	mv	a0,s2
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	95c080e7          	jalr	-1700(ra) # 80000d28 <release>
      return -1;
    800023d4:	59fd                	li	s3,-1
}
    800023d6:	854e                	mv	a0,s3
    800023d8:	60a6                	ld	ra,72(sp)
    800023da:	6406                	ld	s0,64(sp)
    800023dc:	74e2                	ld	s1,56(sp)
    800023de:	7942                	ld	s2,48(sp)
    800023e0:	79a2                	ld	s3,40(sp)
    800023e2:	7a02                	ld	s4,32(sp)
    800023e4:	6ae2                	ld	s5,24(sp)
    800023e6:	6b42                	ld	s6,16(sp)
    800023e8:	6ba2                	ld	s7,8(sp)
    800023ea:	6c02                	ld	s8,0(sp)
    800023ec:	6161                	addi	sp,sp,80
    800023ee:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023f0:	85e2                	mv	a1,s8
    800023f2:	854a                	mv	a0,s2
    800023f4:	00000097          	auipc	ra,0x0
    800023f8:	e84080e7          	jalr	-380(ra) # 80002278 <sleep>
    havekids = 0;
    800023fc:	bf1d                	j	80002332 <wait+0x3c>

00000000800023fe <wakeup>:
{
    800023fe:	7139                	addi	sp,sp,-64
    80002400:	fc06                	sd	ra,56(sp)
    80002402:	f822                	sd	s0,48(sp)
    80002404:	f426                	sd	s1,40(sp)
    80002406:	f04a                	sd	s2,32(sp)
    80002408:	ec4e                	sd	s3,24(sp)
    8000240a:	e852                	sd	s4,16(sp)
    8000240c:	e456                	sd	s5,8(sp)
    8000240e:	0080                	addi	s0,sp,64
    80002410:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002412:	00010497          	auipc	s1,0x10
    80002416:	95648493          	addi	s1,s1,-1706 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000241a:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000241c:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000241e:	00016917          	auipc	s2,0x16
    80002422:	94a90913          	addi	s2,s2,-1718 # 80017d68 <tickslock>
    80002426:	a821                	j	8000243e <wakeup+0x40>
      p->state = RUNNABLE;
    80002428:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    8000242c:	8526                	mv	a0,s1
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	8fa080e7          	jalr	-1798(ra) # 80000d28 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002436:	18048493          	addi	s1,s1,384
    8000243a:	01248e63          	beq	s1,s2,80002456 <wakeup+0x58>
    acquire(&p->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	834080e7          	jalr	-1996(ra) # 80000c74 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002448:	4c9c                	lw	a5,24(s1)
    8000244a:	ff3791e3          	bne	a5,s3,8000242c <wakeup+0x2e>
    8000244e:	749c                	ld	a5,40(s1)
    80002450:	fd479ee3          	bne	a5,s4,8000242c <wakeup+0x2e>
    80002454:	bfd1                	j	80002428 <wakeup+0x2a>
}
    80002456:	70e2                	ld	ra,56(sp)
    80002458:	7442                	ld	s0,48(sp)
    8000245a:	74a2                	ld	s1,40(sp)
    8000245c:	7902                	ld	s2,32(sp)
    8000245e:	69e2                	ld	s3,24(sp)
    80002460:	6a42                	ld	s4,16(sp)
    80002462:	6aa2                	ld	s5,8(sp)
    80002464:	6121                	addi	sp,sp,64
    80002466:	8082                	ret

0000000080002468 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002468:	7179                	addi	sp,sp,-48
    8000246a:	f406                	sd	ra,40(sp)
    8000246c:	f022                	sd	s0,32(sp)
    8000246e:	ec26                	sd	s1,24(sp)
    80002470:	e84a                	sd	s2,16(sp)
    80002472:	e44e                	sd	s3,8(sp)
    80002474:	1800                	addi	s0,sp,48
    80002476:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002478:	00010497          	auipc	s1,0x10
    8000247c:	8f048493          	addi	s1,s1,-1808 # 80011d68 <proc>
    80002480:	00016997          	auipc	s3,0x16
    80002484:	8e898993          	addi	s3,s3,-1816 # 80017d68 <tickslock>
    acquire(&p->lock);
    80002488:	8526                	mv	a0,s1
    8000248a:	ffffe097          	auipc	ra,0xffffe
    8000248e:	7ea080e7          	jalr	2026(ra) # 80000c74 <acquire>
    if(p->pid == pid){
    80002492:	5c9c                	lw	a5,56(s1)
    80002494:	01278d63          	beq	a5,s2,800024ae <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002498:	8526                	mv	a0,s1
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	88e080e7          	jalr	-1906(ra) # 80000d28 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024a2:	18048493          	addi	s1,s1,384
    800024a6:	ff3491e3          	bne	s1,s3,80002488 <kill+0x20>
  }
  return -1;
    800024aa:	557d                	li	a0,-1
    800024ac:	a829                	j	800024c6 <kill+0x5e>
      p->killed = 1;
    800024ae:	4785                	li	a5,1
    800024b0:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800024b2:	4c98                	lw	a4,24(s1)
    800024b4:	4785                	li	a5,1
    800024b6:	00f70f63          	beq	a4,a5,800024d4 <kill+0x6c>
      release(&p->lock);
    800024ba:	8526                	mv	a0,s1
    800024bc:	fffff097          	auipc	ra,0xfffff
    800024c0:	86c080e7          	jalr	-1940(ra) # 80000d28 <release>
      return 0;
    800024c4:	4501                	li	a0,0
}
    800024c6:	70a2                	ld	ra,40(sp)
    800024c8:	7402                	ld	s0,32(sp)
    800024ca:	64e2                	ld	s1,24(sp)
    800024cc:	6942                	ld	s2,16(sp)
    800024ce:	69a2                	ld	s3,8(sp)
    800024d0:	6145                	addi	sp,sp,48
    800024d2:	8082                	ret
        p->state = RUNNABLE;
    800024d4:	4789                	li	a5,2
    800024d6:	cc9c                	sw	a5,24(s1)
    800024d8:	b7cd                	j	800024ba <kill+0x52>

00000000800024da <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024da:	7179                	addi	sp,sp,-48
    800024dc:	f406                	sd	ra,40(sp)
    800024de:	f022                	sd	s0,32(sp)
    800024e0:	ec26                	sd	s1,24(sp)
    800024e2:	e84a                	sd	s2,16(sp)
    800024e4:	e44e                	sd	s3,8(sp)
    800024e6:	e052                	sd	s4,0(sp)
    800024e8:	1800                	addi	s0,sp,48
    800024ea:	84aa                	mv	s1,a0
    800024ec:	892e                	mv	s2,a1
    800024ee:	89b2                	mv	s3,a2
    800024f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f2:	fffff097          	auipc	ra,0xfffff
    800024f6:	550080e7          	jalr	1360(ra) # 80001a42 <myproc>
  if(user_dst){
    800024fa:	c08d                	beqz	s1,8000251c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024fc:	86d2                	mv	a3,s4
    800024fe:	864e                	mv	a2,s3
    80002500:	85ca                	mv	a1,s2
    80002502:	6928                	ld	a0,80(a0)
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	232080e7          	jalr	562(ra) # 80001736 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000250c:	70a2                	ld	ra,40(sp)
    8000250e:	7402                	ld	s0,32(sp)
    80002510:	64e2                	ld	s1,24(sp)
    80002512:	6942                	ld	s2,16(sp)
    80002514:	69a2                	ld	s3,8(sp)
    80002516:	6a02                	ld	s4,0(sp)
    80002518:	6145                	addi	sp,sp,48
    8000251a:	8082                	ret
    memmove((char *)dst, src, len);
    8000251c:	000a061b          	sext.w	a2,s4
    80002520:	85ce                	mv	a1,s3
    80002522:	854a                	mv	a0,s2
    80002524:	fffff097          	auipc	ra,0xfffff
    80002528:	8ac080e7          	jalr	-1876(ra) # 80000dd0 <memmove>
    return 0;
    8000252c:	8526                	mv	a0,s1
    8000252e:	bff9                	j	8000250c <either_copyout+0x32>

0000000080002530 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002530:	7179                	addi	sp,sp,-48
    80002532:	f406                	sd	ra,40(sp)
    80002534:	f022                	sd	s0,32(sp)
    80002536:	ec26                	sd	s1,24(sp)
    80002538:	e84a                	sd	s2,16(sp)
    8000253a:	e44e                	sd	s3,8(sp)
    8000253c:	e052                	sd	s4,0(sp)
    8000253e:	1800                	addi	s0,sp,48
    80002540:	892a                	mv	s2,a0
    80002542:	84ae                	mv	s1,a1
    80002544:	89b2                	mv	s3,a2
    80002546:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002548:	fffff097          	auipc	ra,0xfffff
    8000254c:	4fa080e7          	jalr	1274(ra) # 80001a42 <myproc>
  if(user_src){
    80002550:	c08d                	beqz	s1,80002572 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002552:	86d2                	mv	a3,s4
    80002554:	864e                	mv	a2,s3
    80002556:	85ca                	mv	a1,s2
    80002558:	6928                	ld	a0,80(a0)
    8000255a:	fffff097          	auipc	ra,0xfffff
    8000255e:	268080e7          	jalr	616(ra) # 800017c2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002562:	70a2                	ld	ra,40(sp)
    80002564:	7402                	ld	s0,32(sp)
    80002566:	64e2                	ld	s1,24(sp)
    80002568:	6942                	ld	s2,16(sp)
    8000256a:	69a2                	ld	s3,8(sp)
    8000256c:	6a02                	ld	s4,0(sp)
    8000256e:	6145                	addi	sp,sp,48
    80002570:	8082                	ret
    memmove(dst, (char*)src, len);
    80002572:	000a061b          	sext.w	a2,s4
    80002576:	85ce                	mv	a1,s3
    80002578:	854a                	mv	a0,s2
    8000257a:	fffff097          	auipc	ra,0xfffff
    8000257e:	856080e7          	jalr	-1962(ra) # 80000dd0 <memmove>
    return 0;
    80002582:	8526                	mv	a0,s1
    80002584:	bff9                	j	80002562 <either_copyin+0x32>

0000000080002586 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002586:	715d                	addi	sp,sp,-80
    80002588:	e486                	sd	ra,72(sp)
    8000258a:	e0a2                	sd	s0,64(sp)
    8000258c:	fc26                	sd	s1,56(sp)
    8000258e:	f84a                	sd	s2,48(sp)
    80002590:	f44e                	sd	s3,40(sp)
    80002592:	f052                	sd	s4,32(sp)
    80002594:	ec56                	sd	s5,24(sp)
    80002596:	e85a                	sd	s6,16(sp)
    80002598:	e45e                	sd	s7,8(sp)
    8000259a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000259c:	00006517          	auipc	a0,0x6
    800025a0:	b4450513          	addi	a0,a0,-1212 # 800080e0 <digits+0x88>
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	084080e7          	jalr	132(ra) # 80000628 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ac:	00010497          	auipc	s1,0x10
    800025b0:	91448493          	addi	s1,s1,-1772 # 80011ec0 <proc+0x158>
    800025b4:	00016917          	auipc	s2,0x16
    800025b8:	90c90913          	addi	s2,s2,-1780 # 80017ec0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025bc:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025be:	00006997          	auipc	s3,0x6
    800025c2:	cc298993          	addi	s3,s3,-830 # 80008280 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800025c6:	00006a97          	auipc	s5,0x6
    800025ca:	cc2a8a93          	addi	s5,s5,-830 # 80008288 <digits+0x230>
    printf("\n");
    800025ce:	00006a17          	auipc	s4,0x6
    800025d2:	b12a0a13          	addi	s4,s4,-1262 # 800080e0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d6:	00006b97          	auipc	s7,0x6
    800025da:	ceab8b93          	addi	s7,s7,-790 # 800082c0 <states.1711>
    800025de:	a00d                	j	80002600 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025e0:	ee06a583          	lw	a1,-288(a3)
    800025e4:	8556                	mv	a0,s5
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	042080e7          	jalr	66(ra) # 80000628 <printf>
    printf("\n");
    800025ee:	8552                	mv	a0,s4
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	038080e7          	jalr	56(ra) # 80000628 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f8:	18048493          	addi	s1,s1,384
    800025fc:	03248163          	beq	s1,s2,8000261e <procdump+0x98>
    if(p->state == UNUSED)
    80002600:	86a6                	mv	a3,s1
    80002602:	ec04a783          	lw	a5,-320(s1)
    80002606:	dbed                	beqz	a5,800025f8 <procdump+0x72>
      state = "???";
    80002608:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260a:	fcfb6be3          	bltu	s6,a5,800025e0 <procdump+0x5a>
    8000260e:	1782                	slli	a5,a5,0x20
    80002610:	9381                	srli	a5,a5,0x20
    80002612:	078e                	slli	a5,a5,0x3
    80002614:	97de                	add	a5,a5,s7
    80002616:	6390                	ld	a2,0(a5)
    80002618:	f661                	bnez	a2,800025e0 <procdump+0x5a>
      state = "???";
    8000261a:	864e                	mv	a2,s3
    8000261c:	b7d1                	j	800025e0 <procdump+0x5a>
  }
}
    8000261e:	60a6                	ld	ra,72(sp)
    80002620:	6406                	ld	s0,64(sp)
    80002622:	74e2                	ld	s1,56(sp)
    80002624:	7942                	ld	s2,48(sp)
    80002626:	79a2                	ld	s3,40(sp)
    80002628:	7a02                	ld	s4,32(sp)
    8000262a:	6ae2                	ld	s5,24(sp)
    8000262c:	6b42                	ld	s6,16(sp)
    8000262e:	6ba2                	ld	s7,8(sp)
    80002630:	6161                	addi	sp,sp,80
    80002632:	8082                	ret

0000000080002634 <swtch>:
    80002634:	00153023          	sd	ra,0(a0)
    80002638:	00253423          	sd	sp,8(a0)
    8000263c:	e900                	sd	s0,16(a0)
    8000263e:	ed04                	sd	s1,24(a0)
    80002640:	03253023          	sd	s2,32(a0)
    80002644:	03353423          	sd	s3,40(a0)
    80002648:	03453823          	sd	s4,48(a0)
    8000264c:	03553c23          	sd	s5,56(a0)
    80002650:	05653023          	sd	s6,64(a0)
    80002654:	05753423          	sd	s7,72(a0)
    80002658:	05853823          	sd	s8,80(a0)
    8000265c:	05953c23          	sd	s9,88(a0)
    80002660:	07a53023          	sd	s10,96(a0)
    80002664:	07b53423          	sd	s11,104(a0)
    80002668:	0005b083          	ld	ra,0(a1)
    8000266c:	0085b103          	ld	sp,8(a1)
    80002670:	6980                	ld	s0,16(a1)
    80002672:	6d84                	ld	s1,24(a1)
    80002674:	0205b903          	ld	s2,32(a1)
    80002678:	0285b983          	ld	s3,40(a1)
    8000267c:	0305ba03          	ld	s4,48(a1)
    80002680:	0385ba83          	ld	s5,56(a1)
    80002684:	0405bb03          	ld	s6,64(a1)
    80002688:	0485bb83          	ld	s7,72(a1)
    8000268c:	0505bc03          	ld	s8,80(a1)
    80002690:	0585bc83          	ld	s9,88(a1)
    80002694:	0605bd03          	ld	s10,96(a1)
    80002698:	0685bd83          	ld	s11,104(a1)
    8000269c:	8082                	ret

000000008000269e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000269e:	1141                	addi	sp,sp,-16
    800026a0:	e406                	sd	ra,8(sp)
    800026a2:	e022                	sd	s0,0(sp)
    800026a4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026a6:	00006597          	auipc	a1,0x6
    800026aa:	c4258593          	addi	a1,a1,-958 # 800082e8 <states.1711+0x28>
    800026ae:	00015517          	auipc	a0,0x15
    800026b2:	6ba50513          	addi	a0,a0,1722 # 80017d68 <tickslock>
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	52e080e7          	jalr	1326(ra) # 80000be4 <initlock>
}
    800026be:	60a2                	ld	ra,8(sp)
    800026c0:	6402                	ld	s0,0(sp)
    800026c2:	0141                	addi	sp,sp,16
    800026c4:	8082                	ret

00000000800026c6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026c6:	1141                	addi	sp,sp,-16
    800026c8:	e422                	sd	s0,8(sp)
    800026ca:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026cc:	00003797          	auipc	a5,0x3
    800026d0:	5c478793          	addi	a5,a5,1476 # 80005c90 <kernelvec>
    800026d4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026d8:	6422                	ld	s0,8(sp)
    800026da:	0141                	addi	sp,sp,16
    800026dc:	8082                	ret

00000000800026de <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026de:	1141                	addi	sp,sp,-16
    800026e0:	e406                	sd	ra,8(sp)
    800026e2:	e022                	sd	s0,0(sp)
    800026e4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026e6:	fffff097          	auipc	ra,0xfffff
    800026ea:	35c080e7          	jalr	860(ra) # 80001a42 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026f8:	00005617          	auipc	a2,0x5
    800026fc:	90860613          	addi	a2,a2,-1784 # 80007000 <_trampoline>
    80002700:	00005697          	auipc	a3,0x5
    80002704:	90068693          	addi	a3,a3,-1792 # 80007000 <_trampoline>
    80002708:	8e91                	sub	a3,a3,a2
    8000270a:	040007b7          	lui	a5,0x4000
    8000270e:	17fd                	addi	a5,a5,-1
    80002710:	07b2                	slli	a5,a5,0xc
    80002712:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002714:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002718:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000271a:	180026f3          	csrr	a3,satp
    8000271e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002720:	6d38                	ld	a4,88(a0)
    80002722:	6134                	ld	a3,64(a0)
    80002724:	6585                	lui	a1,0x1
    80002726:	96ae                	add	a3,a3,a1
    80002728:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000272a:	6d38                	ld	a4,88(a0)
    8000272c:	00000697          	auipc	a3,0x0
    80002730:	13868693          	addi	a3,a3,312 # 80002864 <usertrap>
    80002734:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002736:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002738:	8692                	mv	a3,tp
    8000273a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000273c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002740:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002744:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002748:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000274c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000274e:	6f18                	ld	a4,24(a4)
    80002750:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002754:	692c                	ld	a1,80(a0)
    80002756:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002758:	00005717          	auipc	a4,0x5
    8000275c:	93870713          	addi	a4,a4,-1736 # 80007090 <userret>
    80002760:	8f11                	sub	a4,a4,a2
    80002762:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002764:	577d                	li	a4,-1
    80002766:	177e                	slli	a4,a4,0x3f
    80002768:	8dd9                	or	a1,a1,a4
    8000276a:	02000537          	lui	a0,0x2000
    8000276e:	157d                	addi	a0,a0,-1
    80002770:	0536                	slli	a0,a0,0xd
    80002772:	9782                	jalr	a5
}
    80002774:	60a2                	ld	ra,8(sp)
    80002776:	6402                	ld	s0,0(sp)
    80002778:	0141                	addi	sp,sp,16
    8000277a:	8082                	ret

000000008000277c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000277c:	1101                	addi	sp,sp,-32
    8000277e:	ec06                	sd	ra,24(sp)
    80002780:	e822                	sd	s0,16(sp)
    80002782:	e426                	sd	s1,8(sp)
    80002784:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002786:	00015497          	auipc	s1,0x15
    8000278a:	5e248493          	addi	s1,s1,1506 # 80017d68 <tickslock>
    8000278e:	8526                	mv	a0,s1
    80002790:	ffffe097          	auipc	ra,0xffffe
    80002794:	4e4080e7          	jalr	1252(ra) # 80000c74 <acquire>
  ticks++;
    80002798:	00007517          	auipc	a0,0x7
    8000279c:	88850513          	addi	a0,a0,-1912 # 80009020 <ticks>
    800027a0:	411c                	lw	a5,0(a0)
    800027a2:	2785                	addiw	a5,a5,1
    800027a4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027a6:	00000097          	auipc	ra,0x0
    800027aa:	c58080e7          	jalr	-936(ra) # 800023fe <wakeup>
  release(&tickslock);
    800027ae:	8526                	mv	a0,s1
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	578080e7          	jalr	1400(ra) # 80000d28 <release>
}
    800027b8:	60e2                	ld	ra,24(sp)
    800027ba:	6442                	ld	s0,16(sp)
    800027bc:	64a2                	ld	s1,8(sp)
    800027be:	6105                	addi	sp,sp,32
    800027c0:	8082                	ret

00000000800027c2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027c2:	1101                	addi	sp,sp,-32
    800027c4:	ec06                	sd	ra,24(sp)
    800027c6:	e822                	sd	s0,16(sp)
    800027c8:	e426                	sd	s1,8(sp)
    800027ca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027cc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027d0:	00074d63          	bltz	a4,800027ea <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027d4:	57fd                	li	a5,-1
    800027d6:	17fe                	slli	a5,a5,0x3f
    800027d8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027da:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027dc:	06f70363          	beq	a4,a5,80002842 <devintr+0x80>
  }
}
    800027e0:	60e2                	ld	ra,24(sp)
    800027e2:	6442                	ld	s0,16(sp)
    800027e4:	64a2                	ld	s1,8(sp)
    800027e6:	6105                	addi	sp,sp,32
    800027e8:	8082                	ret
     (scause & 0xff) == 9){
    800027ea:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027ee:	46a5                	li	a3,9
    800027f0:	fed792e3          	bne	a5,a3,800027d4 <devintr+0x12>
    int irq = plic_claim();
    800027f4:	00003097          	auipc	ra,0x3
    800027f8:	5a4080e7          	jalr	1444(ra) # 80005d98 <plic_claim>
    800027fc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027fe:	47a9                	li	a5,10
    80002800:	02f50763          	beq	a0,a5,8000282e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002804:	4785                	li	a5,1
    80002806:	02f50963          	beq	a0,a5,80002838 <devintr+0x76>
    return 1;
    8000280a:	4505                	li	a0,1
    } else if(irq){
    8000280c:	d8f1                	beqz	s1,800027e0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000280e:	85a6                	mv	a1,s1
    80002810:	00006517          	auipc	a0,0x6
    80002814:	ae050513          	addi	a0,a0,-1312 # 800082f0 <states.1711+0x30>
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	e10080e7          	jalr	-496(ra) # 80000628 <printf>
      plic_complete(irq);
    80002820:	8526                	mv	a0,s1
    80002822:	00003097          	auipc	ra,0x3
    80002826:	59a080e7          	jalr	1434(ra) # 80005dbc <plic_complete>
    return 1;
    8000282a:	4505                	li	a0,1
    8000282c:	bf55                	j	800027e0 <devintr+0x1e>
      uartintr();
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	20a080e7          	jalr	522(ra) # 80000a38 <uartintr>
    80002836:	b7ed                	j	80002820 <devintr+0x5e>
      virtio_disk_intr();
    80002838:	00004097          	auipc	ra,0x4
    8000283c:	a1e080e7          	jalr	-1506(ra) # 80006256 <virtio_disk_intr>
    80002840:	b7c5                	j	80002820 <devintr+0x5e>
    if(cpuid() == 0){
    80002842:	fffff097          	auipc	ra,0xfffff
    80002846:	1d4080e7          	jalr	468(ra) # 80001a16 <cpuid>
    8000284a:	c901                	beqz	a0,8000285a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000284c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002850:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002852:	14479073          	csrw	sip,a5
    return 2;
    80002856:	4509                	li	a0,2
    80002858:	b761                	j	800027e0 <devintr+0x1e>
      clockintr();
    8000285a:	00000097          	auipc	ra,0x0
    8000285e:	f22080e7          	jalr	-222(ra) # 8000277c <clockintr>
    80002862:	b7ed                	j	8000284c <devintr+0x8a>

0000000080002864 <usertrap>:
{
    80002864:	1101                	addi	sp,sp,-32
    80002866:	ec06                	sd	ra,24(sp)
    80002868:	e822                	sd	s0,16(sp)
    8000286a:	e426                	sd	s1,8(sp)
    8000286c:	e04a                	sd	s2,0(sp)
    8000286e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002870:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002874:	1007f793          	andi	a5,a5,256
    80002878:	e3ad                	bnez	a5,800028da <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000287a:	00003797          	auipc	a5,0x3
    8000287e:	41678793          	addi	a5,a5,1046 # 80005c90 <kernelvec>
    80002882:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002886:	fffff097          	auipc	ra,0xfffff
    8000288a:	1bc080e7          	jalr	444(ra) # 80001a42 <myproc>
    8000288e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002890:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002892:	14102773          	csrr	a4,sepc
    80002896:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002898:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000289c:	47a1                	li	a5,8
    8000289e:	04f71c63          	bne	a4,a5,800028f6 <usertrap+0x92>
    if(p->killed)
    800028a2:	591c                	lw	a5,48(a0)
    800028a4:	e3b9                	bnez	a5,800028ea <usertrap+0x86>
    p->trapframe->epc += 4;
    800028a6:	6cb8                	ld	a4,88(s1)
    800028a8:	6f1c                	ld	a5,24(a4)
    800028aa:	0791                	addi	a5,a5,4
    800028ac:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028b2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028b6:	10079073          	csrw	sstatus,a5
    syscall();
    800028ba:	00000097          	auipc	ra,0x0
    800028be:	33a080e7          	jalr	826(ra) # 80002bf4 <syscall>
  if(p->killed)
    800028c2:	589c                	lw	a5,48(s1)
    800028c4:	ebcd                	bnez	a5,80002976 <usertrap+0x112>
  usertrapret();
    800028c6:	00000097          	auipc	ra,0x0
    800028ca:	e18080e7          	jalr	-488(ra) # 800026de <usertrapret>
}
    800028ce:	60e2                	ld	ra,24(sp)
    800028d0:	6442                	ld	s0,16(sp)
    800028d2:	64a2                	ld	s1,8(sp)
    800028d4:	6902                	ld	s2,0(sp)
    800028d6:	6105                	addi	sp,sp,32
    800028d8:	8082                	ret
    panic("usertrap: not from user mode");
    800028da:	00006517          	auipc	a0,0x6
    800028de:	a3650513          	addi	a0,a0,-1482 # 80008310 <states.1711+0x50>
    800028e2:	ffffe097          	auipc	ra,0xffffe
    800028e6:	cf4080e7          	jalr	-780(ra) # 800005d6 <panic>
      exit(-1);
    800028ea:	557d                	li	a0,-1
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	846080e7          	jalr	-1978(ra) # 80002132 <exit>
    800028f4:	bf4d                	j	800028a6 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028f6:	00000097          	auipc	ra,0x0
    800028fa:	ecc080e7          	jalr	-308(ra) # 800027c2 <devintr>
    800028fe:	892a                	mv	s2,a0
    80002900:	c501                	beqz	a0,80002908 <usertrap+0xa4>
  if(p->killed)
    80002902:	589c                	lw	a5,48(s1)
    80002904:	c3a1                	beqz	a5,80002944 <usertrap+0xe0>
    80002906:	a815                	j	8000293a <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002908:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000290c:	5c90                	lw	a2,56(s1)
    8000290e:	00006517          	auipc	a0,0x6
    80002912:	a2250513          	addi	a0,a0,-1502 # 80008330 <states.1711+0x70>
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	d12080e7          	jalr	-750(ra) # 80000628 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000291e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002922:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002926:	00006517          	auipc	a0,0x6
    8000292a:	a3a50513          	addi	a0,a0,-1478 # 80008360 <states.1711+0xa0>
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	cfa080e7          	jalr	-774(ra) # 80000628 <printf>
    p->killed = 1;
    80002936:	4785                	li	a5,1
    80002938:	d89c                	sw	a5,48(s1)
    exit(-1);
    8000293a:	557d                	li	a0,-1
    8000293c:	fffff097          	auipc	ra,0xfffff
    80002940:	7f6080e7          	jalr	2038(ra) # 80002132 <exit>
  if(which_dev == 2){
    80002944:	4789                	li	a5,2
    80002946:	f8f910e3          	bne	s2,a5,800028c6 <usertrap+0x62>
    if(p->alarm != 0){
    8000294a:	16c4a703          	lw	a4,364(s1)
    8000294e:	cf29                	beqz	a4,800029a8 <usertrap+0x144>
      p->duration++;
    80002950:	1684a783          	lw	a5,360(s1)
    80002954:	2785                	addiw	a5,a5,1
    80002956:	0007869b          	sext.w	a3,a5
    8000295a:	16f4a423          	sw	a5,360(s1)
      if(p->duration == p->alarm){
    8000295e:	04d71063          	bne	a4,a3,8000299e <usertrap+0x13a>
        p->duration = 0;
    80002962:	1604a423          	sw	zero,360(s1)
        if(p->alarm_trapframe == 0){
    80002966:	1784b783          	ld	a5,376(s1)
    8000296a:	cb81                	beqz	a5,8000297a <usertrap+0x116>
          yield();
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	8d0080e7          	jalr	-1840(ra) # 8000223c <yield>
    80002974:	bf89                	j	800028c6 <usertrap+0x62>
  int which_dev = 0;
    80002976:	4901                	li	s2,0
    80002978:	b7c9                	j	8000293a <usertrap+0xd6>
          p->alarm_trapframe = kalloc();
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	20a080e7          	jalr	522(ra) # 80000b84 <kalloc>
    80002982:	16a4bc23          	sd	a0,376(s1)
          memmove(p->alarm_trapframe, p->trapframe, 512);
    80002986:	20000613          	li	a2,512
    8000298a:	6cac                	ld	a1,88(s1)
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	444080e7          	jalr	1092(ra) # 80000dd0 <memmove>
          p->trapframe->epc = p->handler;
    80002994:	6cbc                	ld	a5,88(s1)
    80002996:	1704b703          	ld	a4,368(s1)
    8000299a:	ef98                	sd	a4,24(a5)
    8000299c:	b72d                	j	800028c6 <usertrap+0x62>
        yield();
    8000299e:	00000097          	auipc	ra,0x0
    800029a2:	89e080e7          	jalr	-1890(ra) # 8000223c <yield>
    800029a6:	b705                	j	800028c6 <usertrap+0x62>
      yield();
    800029a8:	00000097          	auipc	ra,0x0
    800029ac:	894080e7          	jalr	-1900(ra) # 8000223c <yield>
    800029b0:	bf19                	j	800028c6 <usertrap+0x62>

00000000800029b2 <kerneltrap>:
{
    800029b2:	7179                	addi	sp,sp,-48
    800029b4:	f406                	sd	ra,40(sp)
    800029b6:	f022                	sd	s0,32(sp)
    800029b8:	ec26                	sd	s1,24(sp)
    800029ba:	e84a                	sd	s2,16(sp)
    800029bc:	e44e                	sd	s3,8(sp)
    800029be:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029c0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029c8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029cc:	1004f793          	andi	a5,s1,256
    800029d0:	cb85                	beqz	a5,80002a00 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029d6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029d8:	ef85                	bnez	a5,80002a10 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029da:	00000097          	auipc	ra,0x0
    800029de:	de8080e7          	jalr	-536(ra) # 800027c2 <devintr>
    800029e2:	cd1d                	beqz	a0,80002a20 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029e4:	4789                	li	a5,2
    800029e6:	06f50a63          	beq	a0,a5,80002a5a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029ea:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ee:	10049073          	csrw	sstatus,s1
}
    800029f2:	70a2                	ld	ra,40(sp)
    800029f4:	7402                	ld	s0,32(sp)
    800029f6:	64e2                	ld	s1,24(sp)
    800029f8:	6942                	ld	s2,16(sp)
    800029fa:	69a2                	ld	s3,8(sp)
    800029fc:	6145                	addi	sp,sp,48
    800029fe:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a00:	00006517          	auipc	a0,0x6
    80002a04:	98050513          	addi	a0,a0,-1664 # 80008380 <states.1711+0xc0>
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	bce080e7          	jalr	-1074(ra) # 800005d6 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a10:	00006517          	auipc	a0,0x6
    80002a14:	99850513          	addi	a0,a0,-1640 # 800083a8 <states.1711+0xe8>
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	bbe080e7          	jalr	-1090(ra) # 800005d6 <panic>
    printf("scause %p\n", scause);
    80002a20:	85ce                	mv	a1,s3
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	9a650513          	addi	a0,a0,-1626 # 800083c8 <states.1711+0x108>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	bfe080e7          	jalr	-1026(ra) # 80000628 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a32:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a36:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a3a:	00006517          	auipc	a0,0x6
    80002a3e:	99e50513          	addi	a0,a0,-1634 # 800083d8 <states.1711+0x118>
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	be6080e7          	jalr	-1050(ra) # 80000628 <printf>
    panic("kerneltrap");
    80002a4a:	00006517          	auipc	a0,0x6
    80002a4e:	9a650513          	addi	a0,a0,-1626 # 800083f0 <states.1711+0x130>
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	b84080e7          	jalr	-1148(ra) # 800005d6 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	fe8080e7          	jalr	-24(ra) # 80001a42 <myproc>
    80002a62:	d541                	beqz	a0,800029ea <kerneltrap+0x38>
    80002a64:	fffff097          	auipc	ra,0xfffff
    80002a68:	fde080e7          	jalr	-34(ra) # 80001a42 <myproc>
    80002a6c:	4d18                	lw	a4,24(a0)
    80002a6e:	478d                	li	a5,3
    80002a70:	f6f71de3          	bne	a4,a5,800029ea <kerneltrap+0x38>
    yield();
    80002a74:	fffff097          	auipc	ra,0xfffff
    80002a78:	7c8080e7          	jalr	1992(ra) # 8000223c <yield>
    80002a7c:	b7bd                	j	800029ea <kerneltrap+0x38>

0000000080002a7e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	e426                	sd	s1,8(sp)
    80002a86:	1000                	addi	s0,sp,32
    80002a88:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a8a:	fffff097          	auipc	ra,0xfffff
    80002a8e:	fb8080e7          	jalr	-72(ra) # 80001a42 <myproc>
  switch (n) {
    80002a92:	4795                	li	a5,5
    80002a94:	0497e163          	bltu	a5,s1,80002ad6 <argraw+0x58>
    80002a98:	048a                	slli	s1,s1,0x2
    80002a9a:	00006717          	auipc	a4,0x6
    80002a9e:	98e70713          	addi	a4,a4,-1650 # 80008428 <states.1711+0x168>
    80002aa2:	94ba                	add	s1,s1,a4
    80002aa4:	409c                	lw	a5,0(s1)
    80002aa6:	97ba                	add	a5,a5,a4
    80002aa8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002aaa:	6d3c                	ld	a5,88(a0)
    80002aac:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002aae:	60e2                	ld	ra,24(sp)
    80002ab0:	6442                	ld	s0,16(sp)
    80002ab2:	64a2                	ld	s1,8(sp)
    80002ab4:	6105                	addi	sp,sp,32
    80002ab6:	8082                	ret
    return p->trapframe->a1;
    80002ab8:	6d3c                	ld	a5,88(a0)
    80002aba:	7fa8                	ld	a0,120(a5)
    80002abc:	bfcd                	j	80002aae <argraw+0x30>
    return p->trapframe->a2;
    80002abe:	6d3c                	ld	a5,88(a0)
    80002ac0:	63c8                	ld	a0,128(a5)
    80002ac2:	b7f5                	j	80002aae <argraw+0x30>
    return p->trapframe->a3;
    80002ac4:	6d3c                	ld	a5,88(a0)
    80002ac6:	67c8                	ld	a0,136(a5)
    80002ac8:	b7dd                	j	80002aae <argraw+0x30>
    return p->trapframe->a4;
    80002aca:	6d3c                	ld	a5,88(a0)
    80002acc:	6bc8                	ld	a0,144(a5)
    80002ace:	b7c5                	j	80002aae <argraw+0x30>
    return p->trapframe->a5;
    80002ad0:	6d3c                	ld	a5,88(a0)
    80002ad2:	6fc8                	ld	a0,152(a5)
    80002ad4:	bfe9                	j	80002aae <argraw+0x30>
  panic("argraw");
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	92a50513          	addi	a0,a0,-1750 # 80008400 <states.1711+0x140>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	af8080e7          	jalr	-1288(ra) # 800005d6 <panic>

0000000080002ae6 <fetchaddr>:
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	e426                	sd	s1,8(sp)
    80002aee:	e04a                	sd	s2,0(sp)
    80002af0:	1000                	addi	s0,sp,32
    80002af2:	84aa                	mv	s1,a0
    80002af4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	f4c080e7          	jalr	-180(ra) # 80001a42 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002afe:	653c                	ld	a5,72(a0)
    80002b00:	02f4f863          	bgeu	s1,a5,80002b30 <fetchaddr+0x4a>
    80002b04:	00848713          	addi	a4,s1,8
    80002b08:	02e7e663          	bltu	a5,a4,80002b34 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b0c:	46a1                	li	a3,8
    80002b0e:	8626                	mv	a2,s1
    80002b10:	85ca                	mv	a1,s2
    80002b12:	6928                	ld	a0,80(a0)
    80002b14:	fffff097          	auipc	ra,0xfffff
    80002b18:	cae080e7          	jalr	-850(ra) # 800017c2 <copyin>
    80002b1c:	00a03533          	snez	a0,a0
    80002b20:	40a00533          	neg	a0,a0
}
    80002b24:	60e2                	ld	ra,24(sp)
    80002b26:	6442                	ld	s0,16(sp)
    80002b28:	64a2                	ld	s1,8(sp)
    80002b2a:	6902                	ld	s2,0(sp)
    80002b2c:	6105                	addi	sp,sp,32
    80002b2e:	8082                	ret
    return -1;
    80002b30:	557d                	li	a0,-1
    80002b32:	bfcd                	j	80002b24 <fetchaddr+0x3e>
    80002b34:	557d                	li	a0,-1
    80002b36:	b7fd                	j	80002b24 <fetchaddr+0x3e>

0000000080002b38 <fetchstr>:
{
    80002b38:	7179                	addi	sp,sp,-48
    80002b3a:	f406                	sd	ra,40(sp)
    80002b3c:	f022                	sd	s0,32(sp)
    80002b3e:	ec26                	sd	s1,24(sp)
    80002b40:	e84a                	sd	s2,16(sp)
    80002b42:	e44e                	sd	s3,8(sp)
    80002b44:	1800                	addi	s0,sp,48
    80002b46:	892a                	mv	s2,a0
    80002b48:	84ae                	mv	s1,a1
    80002b4a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	ef6080e7          	jalr	-266(ra) # 80001a42 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b54:	86ce                	mv	a3,s3
    80002b56:	864a                	mv	a2,s2
    80002b58:	85a6                	mv	a1,s1
    80002b5a:	6928                	ld	a0,80(a0)
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	cf2080e7          	jalr	-782(ra) # 8000184e <copyinstr>
  if(err < 0)
    80002b64:	00054763          	bltz	a0,80002b72 <fetchstr+0x3a>
  return strlen(buf);
    80002b68:	8526                	mv	a0,s1
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	38e080e7          	jalr	910(ra) # 80000ef8 <strlen>
}
    80002b72:	70a2                	ld	ra,40(sp)
    80002b74:	7402                	ld	s0,32(sp)
    80002b76:	64e2                	ld	s1,24(sp)
    80002b78:	6942                	ld	s2,16(sp)
    80002b7a:	69a2                	ld	s3,8(sp)
    80002b7c:	6145                	addi	sp,sp,48
    80002b7e:	8082                	ret

0000000080002b80 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b80:	1101                	addi	sp,sp,-32
    80002b82:	ec06                	sd	ra,24(sp)
    80002b84:	e822                	sd	s0,16(sp)
    80002b86:	e426                	sd	s1,8(sp)
    80002b88:	1000                	addi	s0,sp,32
    80002b8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	ef2080e7          	jalr	-270(ra) # 80002a7e <argraw>
    80002b94:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b96:	4501                	li	a0,0
    80002b98:	60e2                	ld	ra,24(sp)
    80002b9a:	6442                	ld	s0,16(sp)
    80002b9c:	64a2                	ld	s1,8(sp)
    80002b9e:	6105                	addi	sp,sp,32
    80002ba0:	8082                	ret

0000000080002ba2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002ba2:	1101                	addi	sp,sp,-32
    80002ba4:	ec06                	sd	ra,24(sp)
    80002ba6:	e822                	sd	s0,16(sp)
    80002ba8:	e426                	sd	s1,8(sp)
    80002baa:	1000                	addi	s0,sp,32
    80002bac:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bae:	00000097          	auipc	ra,0x0
    80002bb2:	ed0080e7          	jalr	-304(ra) # 80002a7e <argraw>
    80002bb6:	e088                	sd	a0,0(s1)
  return 0;
}
    80002bb8:	4501                	li	a0,0
    80002bba:	60e2                	ld	ra,24(sp)
    80002bbc:	6442                	ld	s0,16(sp)
    80002bbe:	64a2                	ld	s1,8(sp)
    80002bc0:	6105                	addi	sp,sp,32
    80002bc2:	8082                	ret

0000000080002bc4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bc4:	1101                	addi	sp,sp,-32
    80002bc6:	ec06                	sd	ra,24(sp)
    80002bc8:	e822                	sd	s0,16(sp)
    80002bca:	e426                	sd	s1,8(sp)
    80002bcc:	e04a                	sd	s2,0(sp)
    80002bce:	1000                	addi	s0,sp,32
    80002bd0:	84ae                	mv	s1,a1
    80002bd2:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	eaa080e7          	jalr	-342(ra) # 80002a7e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002bdc:	864a                	mv	a2,s2
    80002bde:	85a6                	mv	a1,s1
    80002be0:	00000097          	auipc	ra,0x0
    80002be4:	f58080e7          	jalr	-168(ra) # 80002b38 <fetchstr>
}
    80002be8:	60e2                	ld	ra,24(sp)
    80002bea:	6442                	ld	s0,16(sp)
    80002bec:	64a2                	ld	s1,8(sp)
    80002bee:	6902                	ld	s2,0(sp)
    80002bf0:	6105                	addi	sp,sp,32
    80002bf2:	8082                	ret

0000000080002bf4 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002bf4:	1101                	addi	sp,sp,-32
    80002bf6:	ec06                	sd	ra,24(sp)
    80002bf8:	e822                	sd	s0,16(sp)
    80002bfa:	e426                	sd	s1,8(sp)
    80002bfc:	e04a                	sd	s2,0(sp)
    80002bfe:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	e42080e7          	jalr	-446(ra) # 80001a42 <myproc>
    80002c08:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c0a:	05853903          	ld	s2,88(a0)
    80002c0e:	0a893783          	ld	a5,168(s2)
    80002c12:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c16:	37fd                	addiw	a5,a5,-1
    80002c18:	4759                	li	a4,22
    80002c1a:	00f76f63          	bltu	a4,a5,80002c38 <syscall+0x44>
    80002c1e:	00369713          	slli	a4,a3,0x3
    80002c22:	00006797          	auipc	a5,0x6
    80002c26:	81e78793          	addi	a5,a5,-2018 # 80008440 <syscalls>
    80002c2a:	97ba                	add	a5,a5,a4
    80002c2c:	639c                	ld	a5,0(a5)
    80002c2e:	c789                	beqz	a5,80002c38 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c30:	9782                	jalr	a5
    80002c32:	06a93823          	sd	a0,112(s2)
    80002c36:	a839                	j	80002c54 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c38:	15848613          	addi	a2,s1,344
    80002c3c:	5c8c                	lw	a1,56(s1)
    80002c3e:	00005517          	auipc	a0,0x5
    80002c42:	7ca50513          	addi	a0,a0,1994 # 80008408 <states.1711+0x148>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	9e2080e7          	jalr	-1566(ra) # 80000628 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c4e:	6cbc                	ld	a5,88(s1)
    80002c50:	577d                	li	a4,-1
    80002c52:	fbb8                	sd	a4,112(a5)
  }
}
    80002c54:	60e2                	ld	ra,24(sp)
    80002c56:	6442                	ld	s0,16(sp)
    80002c58:	64a2                	ld	s1,8(sp)
    80002c5a:	6902                	ld	s2,0(sp)
    80002c5c:	6105                	addi	sp,sp,32
    80002c5e:	8082                	ret

0000000080002c60 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c60:	1101                	addi	sp,sp,-32
    80002c62:	ec06                	sd	ra,24(sp)
    80002c64:	e822                	sd	s0,16(sp)
    80002c66:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c68:	fec40593          	addi	a1,s0,-20
    80002c6c:	4501                	li	a0,0
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	f12080e7          	jalr	-238(ra) # 80002b80 <argint>
    return -1;
    80002c76:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c78:	00054963          	bltz	a0,80002c8a <sys_exit+0x2a>
  exit(n);
    80002c7c:	fec42503          	lw	a0,-20(s0)
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	4b2080e7          	jalr	1202(ra) # 80002132 <exit>
  return 0;  // not reached
    80002c88:	4781                	li	a5,0
}
    80002c8a:	853e                	mv	a0,a5
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret

0000000080002c94 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c94:	1141                	addi	sp,sp,-16
    80002c96:	e406                	sd	ra,8(sp)
    80002c98:	e022                	sd	s0,0(sp)
    80002c9a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	da6080e7          	jalr	-602(ra) # 80001a42 <myproc>
}
    80002ca4:	5d08                	lw	a0,56(a0)
    80002ca6:	60a2                	ld	ra,8(sp)
    80002ca8:	6402                	ld	s0,0(sp)
    80002caa:	0141                	addi	sp,sp,16
    80002cac:	8082                	ret

0000000080002cae <sys_fork>:

uint64
sys_fork(void)
{
    80002cae:	1141                	addi	sp,sp,-16
    80002cb0:	e406                	sd	ra,8(sp)
    80002cb2:	e022                	sd	s0,0(sp)
    80002cb4:	0800                	addi	s0,sp,16
  return fork();
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	176080e7          	jalr	374(ra) # 80001e2c <fork>
}
    80002cbe:	60a2                	ld	ra,8(sp)
    80002cc0:	6402                	ld	s0,0(sp)
    80002cc2:	0141                	addi	sp,sp,16
    80002cc4:	8082                	ret

0000000080002cc6 <sys_wait>:

uint64
sys_wait(void)
{
    80002cc6:	1101                	addi	sp,sp,-32
    80002cc8:	ec06                	sd	ra,24(sp)
    80002cca:	e822                	sd	s0,16(sp)
    80002ccc:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002cce:	fe840593          	addi	a1,s0,-24
    80002cd2:	4501                	li	a0,0
    80002cd4:	00000097          	auipc	ra,0x0
    80002cd8:	ece080e7          	jalr	-306(ra) # 80002ba2 <argaddr>
    80002cdc:	87aa                	mv	a5,a0
    return -1;
    80002cde:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002ce0:	0007c863          	bltz	a5,80002cf0 <sys_wait+0x2a>
  return wait(p);
    80002ce4:	fe843503          	ld	a0,-24(s0)
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	60e080e7          	jalr	1550(ra) # 800022f6 <wait>
}
    80002cf0:	60e2                	ld	ra,24(sp)
    80002cf2:	6442                	ld	s0,16(sp)
    80002cf4:	6105                	addi	sp,sp,32
    80002cf6:	8082                	ret

0000000080002cf8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cf8:	7179                	addi	sp,sp,-48
    80002cfa:	f406                	sd	ra,40(sp)
    80002cfc:	f022                	sd	s0,32(sp)
    80002cfe:	ec26                	sd	s1,24(sp)
    80002d00:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d02:	fdc40593          	addi	a1,s0,-36
    80002d06:	4501                	li	a0,0
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	e78080e7          	jalr	-392(ra) # 80002b80 <argint>
    80002d10:	87aa                	mv	a5,a0
    return -1;
    80002d12:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002d14:	0207c063          	bltz	a5,80002d34 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002d18:	fffff097          	auipc	ra,0xfffff
    80002d1c:	d2a080e7          	jalr	-726(ra) # 80001a42 <myproc>
    80002d20:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002d22:	fdc42503          	lw	a0,-36(s0)
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	092080e7          	jalr	146(ra) # 80001db8 <growproc>
    80002d2e:	00054863          	bltz	a0,80002d3e <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d32:	8526                	mv	a0,s1
}
    80002d34:	70a2                	ld	ra,40(sp)
    80002d36:	7402                	ld	s0,32(sp)
    80002d38:	64e2                	ld	s1,24(sp)
    80002d3a:	6145                	addi	sp,sp,48
    80002d3c:	8082                	ret
    return -1;
    80002d3e:	557d                	li	a0,-1
    80002d40:	bfd5                	j	80002d34 <sys_sbrk+0x3c>

0000000080002d42 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d42:	7139                	addi	sp,sp,-64
    80002d44:	fc06                	sd	ra,56(sp)
    80002d46:	f822                	sd	s0,48(sp)
    80002d48:	f426                	sd	s1,40(sp)
    80002d4a:	f04a                	sd	s2,32(sp)
    80002d4c:	ec4e                	sd	s3,24(sp)
    80002d4e:	0080                	addi	s0,sp,64
  backtrace();
    80002d50:	ffffe097          	auipc	ra,0xffffe
    80002d54:	82a080e7          	jalr	-2006(ra) # 8000057a <backtrace>
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d58:	fcc40593          	addi	a1,s0,-52
    80002d5c:	4501                	li	a0,0
    80002d5e:	00000097          	auipc	ra,0x0
    80002d62:	e22080e7          	jalr	-478(ra) # 80002b80 <argint>
    return -1;
    80002d66:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d68:	06054563          	bltz	a0,80002dd2 <sys_sleep+0x90>
  acquire(&tickslock);
    80002d6c:	00015517          	auipc	a0,0x15
    80002d70:	ffc50513          	addi	a0,a0,-4 # 80017d68 <tickslock>
    80002d74:	ffffe097          	auipc	ra,0xffffe
    80002d78:	f00080e7          	jalr	-256(ra) # 80000c74 <acquire>
  ticks0 = ticks;
    80002d7c:	00006917          	auipc	s2,0x6
    80002d80:	2a492903          	lw	s2,676(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002d84:	fcc42783          	lw	a5,-52(s0)
    80002d88:	cf85                	beqz	a5,80002dc0 <sys_sleep+0x7e>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d8a:	00015997          	auipc	s3,0x15
    80002d8e:	fde98993          	addi	s3,s3,-34 # 80017d68 <tickslock>
    80002d92:	00006497          	auipc	s1,0x6
    80002d96:	28e48493          	addi	s1,s1,654 # 80009020 <ticks>
    if(myproc()->killed){
    80002d9a:	fffff097          	auipc	ra,0xfffff
    80002d9e:	ca8080e7          	jalr	-856(ra) # 80001a42 <myproc>
    80002da2:	591c                	lw	a5,48(a0)
    80002da4:	ef9d                	bnez	a5,80002de2 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80002da6:	85ce                	mv	a1,s3
    80002da8:	8526                	mv	a0,s1
    80002daa:	fffff097          	auipc	ra,0xfffff
    80002dae:	4ce080e7          	jalr	1230(ra) # 80002278 <sleep>
  while(ticks - ticks0 < n){
    80002db2:	409c                	lw	a5,0(s1)
    80002db4:	412787bb          	subw	a5,a5,s2
    80002db8:	fcc42703          	lw	a4,-52(s0)
    80002dbc:	fce7efe3          	bltu	a5,a4,80002d9a <sys_sleep+0x58>
  }
  release(&tickslock);
    80002dc0:	00015517          	auipc	a0,0x15
    80002dc4:	fa850513          	addi	a0,a0,-88 # 80017d68 <tickslock>
    80002dc8:	ffffe097          	auipc	ra,0xffffe
    80002dcc:	f60080e7          	jalr	-160(ra) # 80000d28 <release>
  return 0;
    80002dd0:	4781                	li	a5,0
}
    80002dd2:	853e                	mv	a0,a5
    80002dd4:	70e2                	ld	ra,56(sp)
    80002dd6:	7442                	ld	s0,48(sp)
    80002dd8:	74a2                	ld	s1,40(sp)
    80002dda:	7902                	ld	s2,32(sp)
    80002ddc:	69e2                	ld	s3,24(sp)
    80002dde:	6121                	addi	sp,sp,64
    80002de0:	8082                	ret
      release(&tickslock);
    80002de2:	00015517          	auipc	a0,0x15
    80002de6:	f8650513          	addi	a0,a0,-122 # 80017d68 <tickslock>
    80002dea:	ffffe097          	auipc	ra,0xffffe
    80002dee:	f3e080e7          	jalr	-194(ra) # 80000d28 <release>
      return -1;
    80002df2:	57fd                	li	a5,-1
    80002df4:	bff9                	j	80002dd2 <sys_sleep+0x90>

0000000080002df6 <sys_kill>:

uint64
sys_kill(void)
{
    80002df6:	1101                	addi	sp,sp,-32
    80002df8:	ec06                	sd	ra,24(sp)
    80002dfa:	e822                	sd	s0,16(sp)
    80002dfc:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002dfe:	fec40593          	addi	a1,s0,-20
    80002e02:	4501                	li	a0,0
    80002e04:	00000097          	auipc	ra,0x0
    80002e08:	d7c080e7          	jalr	-644(ra) # 80002b80 <argint>
    80002e0c:	87aa                	mv	a5,a0
    return -1;
    80002e0e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e10:	0007c863          	bltz	a5,80002e20 <sys_kill+0x2a>
  return kill(pid);
    80002e14:	fec42503          	lw	a0,-20(s0)
    80002e18:	fffff097          	auipc	ra,0xfffff
    80002e1c:	650080e7          	jalr	1616(ra) # 80002468 <kill>
}
    80002e20:	60e2                	ld	ra,24(sp)
    80002e22:	6442                	ld	s0,16(sp)
    80002e24:	6105                	addi	sp,sp,32
    80002e26:	8082                	ret

0000000080002e28 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e28:	1101                	addi	sp,sp,-32
    80002e2a:	ec06                	sd	ra,24(sp)
    80002e2c:	e822                	sd	s0,16(sp)
    80002e2e:	e426                	sd	s1,8(sp)
    80002e30:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e32:	00015517          	auipc	a0,0x15
    80002e36:	f3650513          	addi	a0,a0,-202 # 80017d68 <tickslock>
    80002e3a:	ffffe097          	auipc	ra,0xffffe
    80002e3e:	e3a080e7          	jalr	-454(ra) # 80000c74 <acquire>
  xticks = ticks;
    80002e42:	00006497          	auipc	s1,0x6
    80002e46:	1de4a483          	lw	s1,478(s1) # 80009020 <ticks>
  release(&tickslock);
    80002e4a:	00015517          	auipc	a0,0x15
    80002e4e:	f1e50513          	addi	a0,a0,-226 # 80017d68 <tickslock>
    80002e52:	ffffe097          	auipc	ra,0xffffe
    80002e56:	ed6080e7          	jalr	-298(ra) # 80000d28 <release>
  return xticks;
}
    80002e5a:	02049513          	slli	a0,s1,0x20
    80002e5e:	9101                	srli	a0,a0,0x20
    80002e60:	60e2                	ld	ra,24(sp)
    80002e62:	6442                	ld	s0,16(sp)
    80002e64:	64a2                	ld	s1,8(sp)
    80002e66:	6105                	addi	sp,sp,32
    80002e68:	8082                	ret

0000000080002e6a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e6a:	7179                	addi	sp,sp,-48
    80002e6c:	f406                	sd	ra,40(sp)
    80002e6e:	f022                	sd	s0,32(sp)
    80002e70:	ec26                	sd	s1,24(sp)
    80002e72:	e84a                	sd	s2,16(sp)
    80002e74:	e44e                	sd	s3,8(sp)
    80002e76:	e052                	sd	s4,0(sp)
    80002e78:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e7a:	00005597          	auipc	a1,0x5
    80002e7e:	68658593          	addi	a1,a1,1670 # 80008500 <syscalls+0xc0>
    80002e82:	00015517          	auipc	a0,0x15
    80002e86:	efe50513          	addi	a0,a0,-258 # 80017d80 <bcache>
    80002e8a:	ffffe097          	auipc	ra,0xffffe
    80002e8e:	d5a080e7          	jalr	-678(ra) # 80000be4 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e92:	0001d797          	auipc	a5,0x1d
    80002e96:	eee78793          	addi	a5,a5,-274 # 8001fd80 <bcache+0x8000>
    80002e9a:	0001d717          	auipc	a4,0x1d
    80002e9e:	14e70713          	addi	a4,a4,334 # 8001ffe8 <bcache+0x8268>
    80002ea2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ea6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002eaa:	00015497          	auipc	s1,0x15
    80002eae:	eee48493          	addi	s1,s1,-274 # 80017d98 <bcache+0x18>
    b->next = bcache.head.next;
    80002eb2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002eb4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002eb6:	00005a17          	auipc	s4,0x5
    80002eba:	652a0a13          	addi	s4,s4,1618 # 80008508 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002ebe:	2b893783          	ld	a5,696(s2)
    80002ec2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ec4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ec8:	85d2                	mv	a1,s4
    80002eca:	01048513          	addi	a0,s1,16
    80002ece:	00001097          	auipc	ra,0x1
    80002ed2:	4ac080e7          	jalr	1196(ra) # 8000437a <initsleeplock>
    bcache.head.next->prev = b;
    80002ed6:	2b893783          	ld	a5,696(s2)
    80002eda:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002edc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ee0:	45848493          	addi	s1,s1,1112
    80002ee4:	fd349de3          	bne	s1,s3,80002ebe <binit+0x54>
  }
}
    80002ee8:	70a2                	ld	ra,40(sp)
    80002eea:	7402                	ld	s0,32(sp)
    80002eec:	64e2                	ld	s1,24(sp)
    80002eee:	6942                	ld	s2,16(sp)
    80002ef0:	69a2                	ld	s3,8(sp)
    80002ef2:	6a02                	ld	s4,0(sp)
    80002ef4:	6145                	addi	sp,sp,48
    80002ef6:	8082                	ret

0000000080002ef8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ef8:	7179                	addi	sp,sp,-48
    80002efa:	f406                	sd	ra,40(sp)
    80002efc:	f022                	sd	s0,32(sp)
    80002efe:	ec26                	sd	s1,24(sp)
    80002f00:	e84a                	sd	s2,16(sp)
    80002f02:	e44e                	sd	s3,8(sp)
    80002f04:	1800                	addi	s0,sp,48
    80002f06:	89aa                	mv	s3,a0
    80002f08:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002f0a:	00015517          	auipc	a0,0x15
    80002f0e:	e7650513          	addi	a0,a0,-394 # 80017d80 <bcache>
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	d62080e7          	jalr	-670(ra) # 80000c74 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f1a:	0001d497          	auipc	s1,0x1d
    80002f1e:	11e4b483          	ld	s1,286(s1) # 80020038 <bcache+0x82b8>
    80002f22:	0001d797          	auipc	a5,0x1d
    80002f26:	0c678793          	addi	a5,a5,198 # 8001ffe8 <bcache+0x8268>
    80002f2a:	02f48f63          	beq	s1,a5,80002f68 <bread+0x70>
    80002f2e:	873e                	mv	a4,a5
    80002f30:	a021                	j	80002f38 <bread+0x40>
    80002f32:	68a4                	ld	s1,80(s1)
    80002f34:	02e48a63          	beq	s1,a4,80002f68 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f38:	449c                	lw	a5,8(s1)
    80002f3a:	ff379ce3          	bne	a5,s3,80002f32 <bread+0x3a>
    80002f3e:	44dc                	lw	a5,12(s1)
    80002f40:	ff2799e3          	bne	a5,s2,80002f32 <bread+0x3a>
      b->refcnt++;
    80002f44:	40bc                	lw	a5,64(s1)
    80002f46:	2785                	addiw	a5,a5,1
    80002f48:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f4a:	00015517          	auipc	a0,0x15
    80002f4e:	e3650513          	addi	a0,a0,-458 # 80017d80 <bcache>
    80002f52:	ffffe097          	auipc	ra,0xffffe
    80002f56:	dd6080e7          	jalr	-554(ra) # 80000d28 <release>
      acquiresleep(&b->lock);
    80002f5a:	01048513          	addi	a0,s1,16
    80002f5e:	00001097          	auipc	ra,0x1
    80002f62:	456080e7          	jalr	1110(ra) # 800043b4 <acquiresleep>
      return b;
    80002f66:	a8b9                	j	80002fc4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f68:	0001d497          	auipc	s1,0x1d
    80002f6c:	0c84b483          	ld	s1,200(s1) # 80020030 <bcache+0x82b0>
    80002f70:	0001d797          	auipc	a5,0x1d
    80002f74:	07878793          	addi	a5,a5,120 # 8001ffe8 <bcache+0x8268>
    80002f78:	00f48863          	beq	s1,a5,80002f88 <bread+0x90>
    80002f7c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f7e:	40bc                	lw	a5,64(s1)
    80002f80:	cf81                	beqz	a5,80002f98 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f82:	64a4                	ld	s1,72(s1)
    80002f84:	fee49de3          	bne	s1,a4,80002f7e <bread+0x86>
  panic("bget: no buffers");
    80002f88:	00005517          	auipc	a0,0x5
    80002f8c:	58850513          	addi	a0,a0,1416 # 80008510 <syscalls+0xd0>
    80002f90:	ffffd097          	auipc	ra,0xffffd
    80002f94:	646080e7          	jalr	1606(ra) # 800005d6 <panic>
      b->dev = dev;
    80002f98:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002f9c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002fa0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fa4:	4785                	li	a5,1
    80002fa6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fa8:	00015517          	auipc	a0,0x15
    80002fac:	dd850513          	addi	a0,a0,-552 # 80017d80 <bcache>
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	d78080e7          	jalr	-648(ra) # 80000d28 <release>
      acquiresleep(&b->lock);
    80002fb8:	01048513          	addi	a0,s1,16
    80002fbc:	00001097          	auipc	ra,0x1
    80002fc0:	3f8080e7          	jalr	1016(ra) # 800043b4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fc4:	409c                	lw	a5,0(s1)
    80002fc6:	cb89                	beqz	a5,80002fd8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fc8:	8526                	mv	a0,s1
    80002fca:	70a2                	ld	ra,40(sp)
    80002fcc:	7402                	ld	s0,32(sp)
    80002fce:	64e2                	ld	s1,24(sp)
    80002fd0:	6942                	ld	s2,16(sp)
    80002fd2:	69a2                	ld	s3,8(sp)
    80002fd4:	6145                	addi	sp,sp,48
    80002fd6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fd8:	4581                	li	a1,0
    80002fda:	8526                	mv	a0,s1
    80002fdc:	00003097          	auipc	ra,0x3
    80002fe0:	fd0080e7          	jalr	-48(ra) # 80005fac <virtio_disk_rw>
    b->valid = 1;
    80002fe4:	4785                	li	a5,1
    80002fe6:	c09c                	sw	a5,0(s1)
  return b;
    80002fe8:	b7c5                	j	80002fc8 <bread+0xd0>

0000000080002fea <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fea:	1101                	addi	sp,sp,-32
    80002fec:	ec06                	sd	ra,24(sp)
    80002fee:	e822                	sd	s0,16(sp)
    80002ff0:	e426                	sd	s1,8(sp)
    80002ff2:	1000                	addi	s0,sp,32
    80002ff4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ff6:	0541                	addi	a0,a0,16
    80002ff8:	00001097          	auipc	ra,0x1
    80002ffc:	456080e7          	jalr	1110(ra) # 8000444e <holdingsleep>
    80003000:	cd01                	beqz	a0,80003018 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003002:	4585                	li	a1,1
    80003004:	8526                	mv	a0,s1
    80003006:	00003097          	auipc	ra,0x3
    8000300a:	fa6080e7          	jalr	-90(ra) # 80005fac <virtio_disk_rw>
}
    8000300e:	60e2                	ld	ra,24(sp)
    80003010:	6442                	ld	s0,16(sp)
    80003012:	64a2                	ld	s1,8(sp)
    80003014:	6105                	addi	sp,sp,32
    80003016:	8082                	ret
    panic("bwrite");
    80003018:	00005517          	auipc	a0,0x5
    8000301c:	51050513          	addi	a0,a0,1296 # 80008528 <syscalls+0xe8>
    80003020:	ffffd097          	auipc	ra,0xffffd
    80003024:	5b6080e7          	jalr	1462(ra) # 800005d6 <panic>

0000000080003028 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003028:	1101                	addi	sp,sp,-32
    8000302a:	ec06                	sd	ra,24(sp)
    8000302c:	e822                	sd	s0,16(sp)
    8000302e:	e426                	sd	s1,8(sp)
    80003030:	e04a                	sd	s2,0(sp)
    80003032:	1000                	addi	s0,sp,32
    80003034:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003036:	01050913          	addi	s2,a0,16
    8000303a:	854a                	mv	a0,s2
    8000303c:	00001097          	auipc	ra,0x1
    80003040:	412080e7          	jalr	1042(ra) # 8000444e <holdingsleep>
    80003044:	c92d                	beqz	a0,800030b6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003046:	854a                	mv	a0,s2
    80003048:	00001097          	auipc	ra,0x1
    8000304c:	3c2080e7          	jalr	962(ra) # 8000440a <releasesleep>

  acquire(&bcache.lock);
    80003050:	00015517          	auipc	a0,0x15
    80003054:	d3050513          	addi	a0,a0,-720 # 80017d80 <bcache>
    80003058:	ffffe097          	auipc	ra,0xffffe
    8000305c:	c1c080e7          	jalr	-996(ra) # 80000c74 <acquire>
  b->refcnt--;
    80003060:	40bc                	lw	a5,64(s1)
    80003062:	37fd                	addiw	a5,a5,-1
    80003064:	0007871b          	sext.w	a4,a5
    80003068:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000306a:	eb05                	bnez	a4,8000309a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000306c:	68bc                	ld	a5,80(s1)
    8000306e:	64b8                	ld	a4,72(s1)
    80003070:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003072:	64bc                	ld	a5,72(s1)
    80003074:	68b8                	ld	a4,80(s1)
    80003076:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003078:	0001d797          	auipc	a5,0x1d
    8000307c:	d0878793          	addi	a5,a5,-760 # 8001fd80 <bcache+0x8000>
    80003080:	2b87b703          	ld	a4,696(a5)
    80003084:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003086:	0001d717          	auipc	a4,0x1d
    8000308a:	f6270713          	addi	a4,a4,-158 # 8001ffe8 <bcache+0x8268>
    8000308e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003090:	2b87b703          	ld	a4,696(a5)
    80003094:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003096:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000309a:	00015517          	auipc	a0,0x15
    8000309e:	ce650513          	addi	a0,a0,-794 # 80017d80 <bcache>
    800030a2:	ffffe097          	auipc	ra,0xffffe
    800030a6:	c86080e7          	jalr	-890(ra) # 80000d28 <release>
}
    800030aa:	60e2                	ld	ra,24(sp)
    800030ac:	6442                	ld	s0,16(sp)
    800030ae:	64a2                	ld	s1,8(sp)
    800030b0:	6902                	ld	s2,0(sp)
    800030b2:	6105                	addi	sp,sp,32
    800030b4:	8082                	ret
    panic("brelse");
    800030b6:	00005517          	auipc	a0,0x5
    800030ba:	47a50513          	addi	a0,a0,1146 # 80008530 <syscalls+0xf0>
    800030be:	ffffd097          	auipc	ra,0xffffd
    800030c2:	518080e7          	jalr	1304(ra) # 800005d6 <panic>

00000000800030c6 <bpin>:

void
bpin(struct buf *b) {
    800030c6:	1101                	addi	sp,sp,-32
    800030c8:	ec06                	sd	ra,24(sp)
    800030ca:	e822                	sd	s0,16(sp)
    800030cc:	e426                	sd	s1,8(sp)
    800030ce:	1000                	addi	s0,sp,32
    800030d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030d2:	00015517          	auipc	a0,0x15
    800030d6:	cae50513          	addi	a0,a0,-850 # 80017d80 <bcache>
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	b9a080e7          	jalr	-1126(ra) # 80000c74 <acquire>
  b->refcnt++;
    800030e2:	40bc                	lw	a5,64(s1)
    800030e4:	2785                	addiw	a5,a5,1
    800030e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030e8:	00015517          	auipc	a0,0x15
    800030ec:	c9850513          	addi	a0,a0,-872 # 80017d80 <bcache>
    800030f0:	ffffe097          	auipc	ra,0xffffe
    800030f4:	c38080e7          	jalr	-968(ra) # 80000d28 <release>
}
    800030f8:	60e2                	ld	ra,24(sp)
    800030fa:	6442                	ld	s0,16(sp)
    800030fc:	64a2                	ld	s1,8(sp)
    800030fe:	6105                	addi	sp,sp,32
    80003100:	8082                	ret

0000000080003102 <bunpin>:

void
bunpin(struct buf *b) {
    80003102:	1101                	addi	sp,sp,-32
    80003104:	ec06                	sd	ra,24(sp)
    80003106:	e822                	sd	s0,16(sp)
    80003108:	e426                	sd	s1,8(sp)
    8000310a:	1000                	addi	s0,sp,32
    8000310c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000310e:	00015517          	auipc	a0,0x15
    80003112:	c7250513          	addi	a0,a0,-910 # 80017d80 <bcache>
    80003116:	ffffe097          	auipc	ra,0xffffe
    8000311a:	b5e080e7          	jalr	-1186(ra) # 80000c74 <acquire>
  b->refcnt--;
    8000311e:	40bc                	lw	a5,64(s1)
    80003120:	37fd                	addiw	a5,a5,-1
    80003122:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003124:	00015517          	auipc	a0,0x15
    80003128:	c5c50513          	addi	a0,a0,-932 # 80017d80 <bcache>
    8000312c:	ffffe097          	auipc	ra,0xffffe
    80003130:	bfc080e7          	jalr	-1028(ra) # 80000d28 <release>
}
    80003134:	60e2                	ld	ra,24(sp)
    80003136:	6442                	ld	s0,16(sp)
    80003138:	64a2                	ld	s1,8(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret

000000008000313e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000313e:	1101                	addi	sp,sp,-32
    80003140:	ec06                	sd	ra,24(sp)
    80003142:	e822                	sd	s0,16(sp)
    80003144:	e426                	sd	s1,8(sp)
    80003146:	e04a                	sd	s2,0(sp)
    80003148:	1000                	addi	s0,sp,32
    8000314a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000314c:	00d5d59b          	srliw	a1,a1,0xd
    80003150:	0001d797          	auipc	a5,0x1d
    80003154:	30c7a783          	lw	a5,780(a5) # 8002045c <sb+0x1c>
    80003158:	9dbd                	addw	a1,a1,a5
    8000315a:	00000097          	auipc	ra,0x0
    8000315e:	d9e080e7          	jalr	-610(ra) # 80002ef8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003162:	0074f713          	andi	a4,s1,7
    80003166:	4785                	li	a5,1
    80003168:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000316c:	14ce                	slli	s1,s1,0x33
    8000316e:	90d9                	srli	s1,s1,0x36
    80003170:	00950733          	add	a4,a0,s1
    80003174:	05874703          	lbu	a4,88(a4)
    80003178:	00e7f6b3          	and	a3,a5,a4
    8000317c:	c69d                	beqz	a3,800031aa <bfree+0x6c>
    8000317e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003180:	94aa                	add	s1,s1,a0
    80003182:	fff7c793          	not	a5,a5
    80003186:	8ff9                	and	a5,a5,a4
    80003188:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000318c:	00001097          	auipc	ra,0x1
    80003190:	100080e7          	jalr	256(ra) # 8000428c <log_write>
  brelse(bp);
    80003194:	854a                	mv	a0,s2
    80003196:	00000097          	auipc	ra,0x0
    8000319a:	e92080e7          	jalr	-366(ra) # 80003028 <brelse>
}
    8000319e:	60e2                	ld	ra,24(sp)
    800031a0:	6442                	ld	s0,16(sp)
    800031a2:	64a2                	ld	s1,8(sp)
    800031a4:	6902                	ld	s2,0(sp)
    800031a6:	6105                	addi	sp,sp,32
    800031a8:	8082                	ret
    panic("freeing free block");
    800031aa:	00005517          	auipc	a0,0x5
    800031ae:	38e50513          	addi	a0,a0,910 # 80008538 <syscalls+0xf8>
    800031b2:	ffffd097          	auipc	ra,0xffffd
    800031b6:	424080e7          	jalr	1060(ra) # 800005d6 <panic>

00000000800031ba <balloc>:
{
    800031ba:	711d                	addi	sp,sp,-96
    800031bc:	ec86                	sd	ra,88(sp)
    800031be:	e8a2                	sd	s0,80(sp)
    800031c0:	e4a6                	sd	s1,72(sp)
    800031c2:	e0ca                	sd	s2,64(sp)
    800031c4:	fc4e                	sd	s3,56(sp)
    800031c6:	f852                	sd	s4,48(sp)
    800031c8:	f456                	sd	s5,40(sp)
    800031ca:	f05a                	sd	s6,32(sp)
    800031cc:	ec5e                	sd	s7,24(sp)
    800031ce:	e862                	sd	s8,16(sp)
    800031d0:	e466                	sd	s9,8(sp)
    800031d2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031d4:	0001d797          	auipc	a5,0x1d
    800031d8:	2707a783          	lw	a5,624(a5) # 80020444 <sb+0x4>
    800031dc:	cbd1                	beqz	a5,80003270 <balloc+0xb6>
    800031de:	8baa                	mv	s7,a0
    800031e0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031e2:	0001db17          	auipc	s6,0x1d
    800031e6:	25eb0b13          	addi	s6,s6,606 # 80020440 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ea:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031ec:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ee:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031f0:	6c89                	lui	s9,0x2
    800031f2:	a831                	j	8000320e <balloc+0x54>
    brelse(bp);
    800031f4:	854a                	mv	a0,s2
    800031f6:	00000097          	auipc	ra,0x0
    800031fa:	e32080e7          	jalr	-462(ra) # 80003028 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031fe:	015c87bb          	addw	a5,s9,s5
    80003202:	00078a9b          	sext.w	s5,a5
    80003206:	004b2703          	lw	a4,4(s6)
    8000320a:	06eaf363          	bgeu	s5,a4,80003270 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000320e:	41fad79b          	sraiw	a5,s5,0x1f
    80003212:	0137d79b          	srliw	a5,a5,0x13
    80003216:	015787bb          	addw	a5,a5,s5
    8000321a:	40d7d79b          	sraiw	a5,a5,0xd
    8000321e:	01cb2583          	lw	a1,28(s6)
    80003222:	9dbd                	addw	a1,a1,a5
    80003224:	855e                	mv	a0,s7
    80003226:	00000097          	auipc	ra,0x0
    8000322a:	cd2080e7          	jalr	-814(ra) # 80002ef8 <bread>
    8000322e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003230:	004b2503          	lw	a0,4(s6)
    80003234:	000a849b          	sext.w	s1,s5
    80003238:	8662                	mv	a2,s8
    8000323a:	faa4fde3          	bgeu	s1,a0,800031f4 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000323e:	41f6579b          	sraiw	a5,a2,0x1f
    80003242:	01d7d69b          	srliw	a3,a5,0x1d
    80003246:	00c6873b          	addw	a4,a3,a2
    8000324a:	00777793          	andi	a5,a4,7
    8000324e:	9f95                	subw	a5,a5,a3
    80003250:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003254:	4037571b          	sraiw	a4,a4,0x3
    80003258:	00e906b3          	add	a3,s2,a4
    8000325c:	0586c683          	lbu	a3,88(a3)
    80003260:	00d7f5b3          	and	a1,a5,a3
    80003264:	cd91                	beqz	a1,80003280 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003266:	2605                	addiw	a2,a2,1
    80003268:	2485                	addiw	s1,s1,1
    8000326a:	fd4618e3          	bne	a2,s4,8000323a <balloc+0x80>
    8000326e:	b759                	j	800031f4 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003270:	00005517          	auipc	a0,0x5
    80003274:	2e050513          	addi	a0,a0,736 # 80008550 <syscalls+0x110>
    80003278:	ffffd097          	auipc	ra,0xffffd
    8000327c:	35e080e7          	jalr	862(ra) # 800005d6 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003280:	974a                	add	a4,a4,s2
    80003282:	8fd5                	or	a5,a5,a3
    80003284:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003288:	854a                	mv	a0,s2
    8000328a:	00001097          	auipc	ra,0x1
    8000328e:	002080e7          	jalr	2(ra) # 8000428c <log_write>
        brelse(bp);
    80003292:	854a                	mv	a0,s2
    80003294:	00000097          	auipc	ra,0x0
    80003298:	d94080e7          	jalr	-620(ra) # 80003028 <brelse>
  bp = bread(dev, bno);
    8000329c:	85a6                	mv	a1,s1
    8000329e:	855e                	mv	a0,s7
    800032a0:	00000097          	auipc	ra,0x0
    800032a4:	c58080e7          	jalr	-936(ra) # 80002ef8 <bread>
    800032a8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032aa:	40000613          	li	a2,1024
    800032ae:	4581                	li	a1,0
    800032b0:	05850513          	addi	a0,a0,88
    800032b4:	ffffe097          	auipc	ra,0xffffe
    800032b8:	abc080e7          	jalr	-1348(ra) # 80000d70 <memset>
  log_write(bp);
    800032bc:	854a                	mv	a0,s2
    800032be:	00001097          	auipc	ra,0x1
    800032c2:	fce080e7          	jalr	-50(ra) # 8000428c <log_write>
  brelse(bp);
    800032c6:	854a                	mv	a0,s2
    800032c8:	00000097          	auipc	ra,0x0
    800032cc:	d60080e7          	jalr	-672(ra) # 80003028 <brelse>
}
    800032d0:	8526                	mv	a0,s1
    800032d2:	60e6                	ld	ra,88(sp)
    800032d4:	6446                	ld	s0,80(sp)
    800032d6:	64a6                	ld	s1,72(sp)
    800032d8:	6906                	ld	s2,64(sp)
    800032da:	79e2                	ld	s3,56(sp)
    800032dc:	7a42                	ld	s4,48(sp)
    800032de:	7aa2                	ld	s5,40(sp)
    800032e0:	7b02                	ld	s6,32(sp)
    800032e2:	6be2                	ld	s7,24(sp)
    800032e4:	6c42                	ld	s8,16(sp)
    800032e6:	6ca2                	ld	s9,8(sp)
    800032e8:	6125                	addi	sp,sp,96
    800032ea:	8082                	ret

00000000800032ec <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800032ec:	7179                	addi	sp,sp,-48
    800032ee:	f406                	sd	ra,40(sp)
    800032f0:	f022                	sd	s0,32(sp)
    800032f2:	ec26                	sd	s1,24(sp)
    800032f4:	e84a                	sd	s2,16(sp)
    800032f6:	e44e                	sd	s3,8(sp)
    800032f8:	e052                	sd	s4,0(sp)
    800032fa:	1800                	addi	s0,sp,48
    800032fc:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032fe:	47ad                	li	a5,11
    80003300:	04b7fe63          	bgeu	a5,a1,8000335c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003304:	ff45849b          	addiw	s1,a1,-12
    80003308:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000330c:	0ff00793          	li	a5,255
    80003310:	0ae7e363          	bltu	a5,a4,800033b6 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003314:	08052583          	lw	a1,128(a0)
    80003318:	c5ad                	beqz	a1,80003382 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000331a:	00092503          	lw	a0,0(s2)
    8000331e:	00000097          	auipc	ra,0x0
    80003322:	bda080e7          	jalr	-1062(ra) # 80002ef8 <bread>
    80003326:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003328:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000332c:	02049593          	slli	a1,s1,0x20
    80003330:	9181                	srli	a1,a1,0x20
    80003332:	058a                	slli	a1,a1,0x2
    80003334:	00b784b3          	add	s1,a5,a1
    80003338:	0004a983          	lw	s3,0(s1)
    8000333c:	04098d63          	beqz	s3,80003396 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003340:	8552                	mv	a0,s4
    80003342:	00000097          	auipc	ra,0x0
    80003346:	ce6080e7          	jalr	-794(ra) # 80003028 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000334a:	854e                	mv	a0,s3
    8000334c:	70a2                	ld	ra,40(sp)
    8000334e:	7402                	ld	s0,32(sp)
    80003350:	64e2                	ld	s1,24(sp)
    80003352:	6942                	ld	s2,16(sp)
    80003354:	69a2                	ld	s3,8(sp)
    80003356:	6a02                	ld	s4,0(sp)
    80003358:	6145                	addi	sp,sp,48
    8000335a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000335c:	02059493          	slli	s1,a1,0x20
    80003360:	9081                	srli	s1,s1,0x20
    80003362:	048a                	slli	s1,s1,0x2
    80003364:	94aa                	add	s1,s1,a0
    80003366:	0504a983          	lw	s3,80(s1)
    8000336a:	fe0990e3          	bnez	s3,8000334a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000336e:	4108                	lw	a0,0(a0)
    80003370:	00000097          	auipc	ra,0x0
    80003374:	e4a080e7          	jalr	-438(ra) # 800031ba <balloc>
    80003378:	0005099b          	sext.w	s3,a0
    8000337c:	0534a823          	sw	s3,80(s1)
    80003380:	b7e9                	j	8000334a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003382:	4108                	lw	a0,0(a0)
    80003384:	00000097          	auipc	ra,0x0
    80003388:	e36080e7          	jalr	-458(ra) # 800031ba <balloc>
    8000338c:	0005059b          	sext.w	a1,a0
    80003390:	08b92023          	sw	a1,128(s2)
    80003394:	b759                	j	8000331a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003396:	00092503          	lw	a0,0(s2)
    8000339a:	00000097          	auipc	ra,0x0
    8000339e:	e20080e7          	jalr	-480(ra) # 800031ba <balloc>
    800033a2:	0005099b          	sext.w	s3,a0
    800033a6:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033aa:	8552                	mv	a0,s4
    800033ac:	00001097          	auipc	ra,0x1
    800033b0:	ee0080e7          	jalr	-288(ra) # 8000428c <log_write>
    800033b4:	b771                	j	80003340 <bmap+0x54>
  panic("bmap: out of range");
    800033b6:	00005517          	auipc	a0,0x5
    800033ba:	1b250513          	addi	a0,a0,434 # 80008568 <syscalls+0x128>
    800033be:	ffffd097          	auipc	ra,0xffffd
    800033c2:	218080e7          	jalr	536(ra) # 800005d6 <panic>

00000000800033c6 <iget>:
{
    800033c6:	7179                	addi	sp,sp,-48
    800033c8:	f406                	sd	ra,40(sp)
    800033ca:	f022                	sd	s0,32(sp)
    800033cc:	ec26                	sd	s1,24(sp)
    800033ce:	e84a                	sd	s2,16(sp)
    800033d0:	e44e                	sd	s3,8(sp)
    800033d2:	e052                	sd	s4,0(sp)
    800033d4:	1800                	addi	s0,sp,48
    800033d6:	89aa                	mv	s3,a0
    800033d8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800033da:	0001d517          	auipc	a0,0x1d
    800033de:	08650513          	addi	a0,a0,134 # 80020460 <icache>
    800033e2:	ffffe097          	auipc	ra,0xffffe
    800033e6:	892080e7          	jalr	-1902(ra) # 80000c74 <acquire>
  empty = 0;
    800033ea:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800033ec:	0001d497          	auipc	s1,0x1d
    800033f0:	08c48493          	addi	s1,s1,140 # 80020478 <icache+0x18>
    800033f4:	0001f697          	auipc	a3,0x1f
    800033f8:	b1468693          	addi	a3,a3,-1260 # 80021f08 <log>
    800033fc:	a039                	j	8000340a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033fe:	02090b63          	beqz	s2,80003434 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003402:	08848493          	addi	s1,s1,136
    80003406:	02d48a63          	beq	s1,a3,8000343a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000340a:	449c                	lw	a5,8(s1)
    8000340c:	fef059e3          	blez	a5,800033fe <iget+0x38>
    80003410:	4098                	lw	a4,0(s1)
    80003412:	ff3716e3          	bne	a4,s3,800033fe <iget+0x38>
    80003416:	40d8                	lw	a4,4(s1)
    80003418:	ff4713e3          	bne	a4,s4,800033fe <iget+0x38>
      ip->ref++;
    8000341c:	2785                	addiw	a5,a5,1
    8000341e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003420:	0001d517          	auipc	a0,0x1d
    80003424:	04050513          	addi	a0,a0,64 # 80020460 <icache>
    80003428:	ffffe097          	auipc	ra,0xffffe
    8000342c:	900080e7          	jalr	-1792(ra) # 80000d28 <release>
      return ip;
    80003430:	8926                	mv	s2,s1
    80003432:	a03d                	j	80003460 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003434:	f7f9                	bnez	a5,80003402 <iget+0x3c>
    80003436:	8926                	mv	s2,s1
    80003438:	b7e9                	j	80003402 <iget+0x3c>
  if(empty == 0)
    8000343a:	02090c63          	beqz	s2,80003472 <iget+0xac>
  ip->dev = dev;
    8000343e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003442:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003446:	4785                	li	a5,1
    80003448:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000344c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003450:	0001d517          	auipc	a0,0x1d
    80003454:	01050513          	addi	a0,a0,16 # 80020460 <icache>
    80003458:	ffffe097          	auipc	ra,0xffffe
    8000345c:	8d0080e7          	jalr	-1840(ra) # 80000d28 <release>
}
    80003460:	854a                	mv	a0,s2
    80003462:	70a2                	ld	ra,40(sp)
    80003464:	7402                	ld	s0,32(sp)
    80003466:	64e2                	ld	s1,24(sp)
    80003468:	6942                	ld	s2,16(sp)
    8000346a:	69a2                	ld	s3,8(sp)
    8000346c:	6a02                	ld	s4,0(sp)
    8000346e:	6145                	addi	sp,sp,48
    80003470:	8082                	ret
    panic("iget: no inodes");
    80003472:	00005517          	auipc	a0,0x5
    80003476:	10e50513          	addi	a0,a0,270 # 80008580 <syscalls+0x140>
    8000347a:	ffffd097          	auipc	ra,0xffffd
    8000347e:	15c080e7          	jalr	348(ra) # 800005d6 <panic>

0000000080003482 <fsinit>:
fsinit(int dev) {
    80003482:	7179                	addi	sp,sp,-48
    80003484:	f406                	sd	ra,40(sp)
    80003486:	f022                	sd	s0,32(sp)
    80003488:	ec26                	sd	s1,24(sp)
    8000348a:	e84a                	sd	s2,16(sp)
    8000348c:	e44e                	sd	s3,8(sp)
    8000348e:	1800                	addi	s0,sp,48
    80003490:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003492:	4585                	li	a1,1
    80003494:	00000097          	auipc	ra,0x0
    80003498:	a64080e7          	jalr	-1436(ra) # 80002ef8 <bread>
    8000349c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000349e:	0001d997          	auipc	s3,0x1d
    800034a2:	fa298993          	addi	s3,s3,-94 # 80020440 <sb>
    800034a6:	02000613          	li	a2,32
    800034aa:	05850593          	addi	a1,a0,88
    800034ae:	854e                	mv	a0,s3
    800034b0:	ffffe097          	auipc	ra,0xffffe
    800034b4:	920080e7          	jalr	-1760(ra) # 80000dd0 <memmove>
  brelse(bp);
    800034b8:	8526                	mv	a0,s1
    800034ba:	00000097          	auipc	ra,0x0
    800034be:	b6e080e7          	jalr	-1170(ra) # 80003028 <brelse>
  if(sb.magic != FSMAGIC)
    800034c2:	0009a703          	lw	a4,0(s3)
    800034c6:	102037b7          	lui	a5,0x10203
    800034ca:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034ce:	02f71263          	bne	a4,a5,800034f2 <fsinit+0x70>
  initlog(dev, &sb);
    800034d2:	0001d597          	auipc	a1,0x1d
    800034d6:	f6e58593          	addi	a1,a1,-146 # 80020440 <sb>
    800034da:	854a                	mv	a0,s2
    800034dc:	00001097          	auipc	ra,0x1
    800034e0:	b38080e7          	jalr	-1224(ra) # 80004014 <initlog>
}
    800034e4:	70a2                	ld	ra,40(sp)
    800034e6:	7402                	ld	s0,32(sp)
    800034e8:	64e2                	ld	s1,24(sp)
    800034ea:	6942                	ld	s2,16(sp)
    800034ec:	69a2                	ld	s3,8(sp)
    800034ee:	6145                	addi	sp,sp,48
    800034f0:	8082                	ret
    panic("invalid file system");
    800034f2:	00005517          	auipc	a0,0x5
    800034f6:	09e50513          	addi	a0,a0,158 # 80008590 <syscalls+0x150>
    800034fa:	ffffd097          	auipc	ra,0xffffd
    800034fe:	0dc080e7          	jalr	220(ra) # 800005d6 <panic>

0000000080003502 <iinit>:
{
    80003502:	7179                	addi	sp,sp,-48
    80003504:	f406                	sd	ra,40(sp)
    80003506:	f022                	sd	s0,32(sp)
    80003508:	ec26                	sd	s1,24(sp)
    8000350a:	e84a                	sd	s2,16(sp)
    8000350c:	e44e                	sd	s3,8(sp)
    8000350e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003510:	00005597          	auipc	a1,0x5
    80003514:	09858593          	addi	a1,a1,152 # 800085a8 <syscalls+0x168>
    80003518:	0001d517          	auipc	a0,0x1d
    8000351c:	f4850513          	addi	a0,a0,-184 # 80020460 <icache>
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	6c4080e7          	jalr	1732(ra) # 80000be4 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003528:	0001d497          	auipc	s1,0x1d
    8000352c:	f6048493          	addi	s1,s1,-160 # 80020488 <icache+0x28>
    80003530:	0001f997          	auipc	s3,0x1f
    80003534:	9e898993          	addi	s3,s3,-1560 # 80021f18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003538:	00005917          	auipc	s2,0x5
    8000353c:	07890913          	addi	s2,s2,120 # 800085b0 <syscalls+0x170>
    80003540:	85ca                	mv	a1,s2
    80003542:	8526                	mv	a0,s1
    80003544:	00001097          	auipc	ra,0x1
    80003548:	e36080e7          	jalr	-458(ra) # 8000437a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000354c:	08848493          	addi	s1,s1,136
    80003550:	ff3498e3          	bne	s1,s3,80003540 <iinit+0x3e>
}
    80003554:	70a2                	ld	ra,40(sp)
    80003556:	7402                	ld	s0,32(sp)
    80003558:	64e2                	ld	s1,24(sp)
    8000355a:	6942                	ld	s2,16(sp)
    8000355c:	69a2                	ld	s3,8(sp)
    8000355e:	6145                	addi	sp,sp,48
    80003560:	8082                	ret

0000000080003562 <ialloc>:
{
    80003562:	715d                	addi	sp,sp,-80
    80003564:	e486                	sd	ra,72(sp)
    80003566:	e0a2                	sd	s0,64(sp)
    80003568:	fc26                	sd	s1,56(sp)
    8000356a:	f84a                	sd	s2,48(sp)
    8000356c:	f44e                	sd	s3,40(sp)
    8000356e:	f052                	sd	s4,32(sp)
    80003570:	ec56                	sd	s5,24(sp)
    80003572:	e85a                	sd	s6,16(sp)
    80003574:	e45e                	sd	s7,8(sp)
    80003576:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003578:	0001d717          	auipc	a4,0x1d
    8000357c:	ed472703          	lw	a4,-300(a4) # 8002044c <sb+0xc>
    80003580:	4785                	li	a5,1
    80003582:	04e7fa63          	bgeu	a5,a4,800035d6 <ialloc+0x74>
    80003586:	8aaa                	mv	s5,a0
    80003588:	8bae                	mv	s7,a1
    8000358a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000358c:	0001da17          	auipc	s4,0x1d
    80003590:	eb4a0a13          	addi	s4,s4,-332 # 80020440 <sb>
    80003594:	00048b1b          	sext.w	s6,s1
    80003598:	0044d593          	srli	a1,s1,0x4
    8000359c:	018a2783          	lw	a5,24(s4)
    800035a0:	9dbd                	addw	a1,a1,a5
    800035a2:	8556                	mv	a0,s5
    800035a4:	00000097          	auipc	ra,0x0
    800035a8:	954080e7          	jalr	-1708(ra) # 80002ef8 <bread>
    800035ac:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035ae:	05850993          	addi	s3,a0,88
    800035b2:	00f4f793          	andi	a5,s1,15
    800035b6:	079a                	slli	a5,a5,0x6
    800035b8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035ba:	00099783          	lh	a5,0(s3)
    800035be:	c785                	beqz	a5,800035e6 <ialloc+0x84>
    brelse(bp);
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	a68080e7          	jalr	-1432(ra) # 80003028 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035c8:	0485                	addi	s1,s1,1
    800035ca:	00ca2703          	lw	a4,12(s4)
    800035ce:	0004879b          	sext.w	a5,s1
    800035d2:	fce7e1e3          	bltu	a5,a4,80003594 <ialloc+0x32>
  panic("ialloc: no inodes");
    800035d6:	00005517          	auipc	a0,0x5
    800035da:	fe250513          	addi	a0,a0,-30 # 800085b8 <syscalls+0x178>
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	ff8080e7          	jalr	-8(ra) # 800005d6 <panic>
      memset(dip, 0, sizeof(*dip));
    800035e6:	04000613          	li	a2,64
    800035ea:	4581                	li	a1,0
    800035ec:	854e                	mv	a0,s3
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	782080e7          	jalr	1922(ra) # 80000d70 <memset>
      dip->type = type;
    800035f6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035fa:	854a                	mv	a0,s2
    800035fc:	00001097          	auipc	ra,0x1
    80003600:	c90080e7          	jalr	-880(ra) # 8000428c <log_write>
      brelse(bp);
    80003604:	854a                	mv	a0,s2
    80003606:	00000097          	auipc	ra,0x0
    8000360a:	a22080e7          	jalr	-1502(ra) # 80003028 <brelse>
      return iget(dev, inum);
    8000360e:	85da                	mv	a1,s6
    80003610:	8556                	mv	a0,s5
    80003612:	00000097          	auipc	ra,0x0
    80003616:	db4080e7          	jalr	-588(ra) # 800033c6 <iget>
}
    8000361a:	60a6                	ld	ra,72(sp)
    8000361c:	6406                	ld	s0,64(sp)
    8000361e:	74e2                	ld	s1,56(sp)
    80003620:	7942                	ld	s2,48(sp)
    80003622:	79a2                	ld	s3,40(sp)
    80003624:	7a02                	ld	s4,32(sp)
    80003626:	6ae2                	ld	s5,24(sp)
    80003628:	6b42                	ld	s6,16(sp)
    8000362a:	6ba2                	ld	s7,8(sp)
    8000362c:	6161                	addi	sp,sp,80
    8000362e:	8082                	ret

0000000080003630 <iupdate>:
{
    80003630:	1101                	addi	sp,sp,-32
    80003632:	ec06                	sd	ra,24(sp)
    80003634:	e822                	sd	s0,16(sp)
    80003636:	e426                	sd	s1,8(sp)
    80003638:	e04a                	sd	s2,0(sp)
    8000363a:	1000                	addi	s0,sp,32
    8000363c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000363e:	415c                	lw	a5,4(a0)
    80003640:	0047d79b          	srliw	a5,a5,0x4
    80003644:	0001d597          	auipc	a1,0x1d
    80003648:	e145a583          	lw	a1,-492(a1) # 80020458 <sb+0x18>
    8000364c:	9dbd                	addw	a1,a1,a5
    8000364e:	4108                	lw	a0,0(a0)
    80003650:	00000097          	auipc	ra,0x0
    80003654:	8a8080e7          	jalr	-1880(ra) # 80002ef8 <bread>
    80003658:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000365a:	05850793          	addi	a5,a0,88
    8000365e:	40c8                	lw	a0,4(s1)
    80003660:	893d                	andi	a0,a0,15
    80003662:	051a                	slli	a0,a0,0x6
    80003664:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003666:	04449703          	lh	a4,68(s1)
    8000366a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000366e:	04649703          	lh	a4,70(s1)
    80003672:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003676:	04849703          	lh	a4,72(s1)
    8000367a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000367e:	04a49703          	lh	a4,74(s1)
    80003682:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003686:	44f8                	lw	a4,76(s1)
    80003688:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000368a:	03400613          	li	a2,52
    8000368e:	05048593          	addi	a1,s1,80
    80003692:	0531                	addi	a0,a0,12
    80003694:	ffffd097          	auipc	ra,0xffffd
    80003698:	73c080e7          	jalr	1852(ra) # 80000dd0 <memmove>
  log_write(bp);
    8000369c:	854a                	mv	a0,s2
    8000369e:	00001097          	auipc	ra,0x1
    800036a2:	bee080e7          	jalr	-1042(ra) # 8000428c <log_write>
  brelse(bp);
    800036a6:	854a                	mv	a0,s2
    800036a8:	00000097          	auipc	ra,0x0
    800036ac:	980080e7          	jalr	-1664(ra) # 80003028 <brelse>
}
    800036b0:	60e2                	ld	ra,24(sp)
    800036b2:	6442                	ld	s0,16(sp)
    800036b4:	64a2                	ld	s1,8(sp)
    800036b6:	6902                	ld	s2,0(sp)
    800036b8:	6105                	addi	sp,sp,32
    800036ba:	8082                	ret

00000000800036bc <idup>:
{
    800036bc:	1101                	addi	sp,sp,-32
    800036be:	ec06                	sd	ra,24(sp)
    800036c0:	e822                	sd	s0,16(sp)
    800036c2:	e426                	sd	s1,8(sp)
    800036c4:	1000                	addi	s0,sp,32
    800036c6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800036c8:	0001d517          	auipc	a0,0x1d
    800036cc:	d9850513          	addi	a0,a0,-616 # 80020460 <icache>
    800036d0:	ffffd097          	auipc	ra,0xffffd
    800036d4:	5a4080e7          	jalr	1444(ra) # 80000c74 <acquire>
  ip->ref++;
    800036d8:	449c                	lw	a5,8(s1)
    800036da:	2785                	addiw	a5,a5,1
    800036dc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800036de:	0001d517          	auipc	a0,0x1d
    800036e2:	d8250513          	addi	a0,a0,-638 # 80020460 <icache>
    800036e6:	ffffd097          	auipc	ra,0xffffd
    800036ea:	642080e7          	jalr	1602(ra) # 80000d28 <release>
}
    800036ee:	8526                	mv	a0,s1
    800036f0:	60e2                	ld	ra,24(sp)
    800036f2:	6442                	ld	s0,16(sp)
    800036f4:	64a2                	ld	s1,8(sp)
    800036f6:	6105                	addi	sp,sp,32
    800036f8:	8082                	ret

00000000800036fa <ilock>:
{
    800036fa:	1101                	addi	sp,sp,-32
    800036fc:	ec06                	sd	ra,24(sp)
    800036fe:	e822                	sd	s0,16(sp)
    80003700:	e426                	sd	s1,8(sp)
    80003702:	e04a                	sd	s2,0(sp)
    80003704:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003706:	c115                	beqz	a0,8000372a <ilock+0x30>
    80003708:	84aa                	mv	s1,a0
    8000370a:	451c                	lw	a5,8(a0)
    8000370c:	00f05f63          	blez	a5,8000372a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003710:	0541                	addi	a0,a0,16
    80003712:	00001097          	auipc	ra,0x1
    80003716:	ca2080e7          	jalr	-862(ra) # 800043b4 <acquiresleep>
  if(ip->valid == 0){
    8000371a:	40bc                	lw	a5,64(s1)
    8000371c:	cf99                	beqz	a5,8000373a <ilock+0x40>
}
    8000371e:	60e2                	ld	ra,24(sp)
    80003720:	6442                	ld	s0,16(sp)
    80003722:	64a2                	ld	s1,8(sp)
    80003724:	6902                	ld	s2,0(sp)
    80003726:	6105                	addi	sp,sp,32
    80003728:	8082                	ret
    panic("ilock");
    8000372a:	00005517          	auipc	a0,0x5
    8000372e:	ea650513          	addi	a0,a0,-346 # 800085d0 <syscalls+0x190>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	ea4080e7          	jalr	-348(ra) # 800005d6 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000373a:	40dc                	lw	a5,4(s1)
    8000373c:	0047d79b          	srliw	a5,a5,0x4
    80003740:	0001d597          	auipc	a1,0x1d
    80003744:	d185a583          	lw	a1,-744(a1) # 80020458 <sb+0x18>
    80003748:	9dbd                	addw	a1,a1,a5
    8000374a:	4088                	lw	a0,0(s1)
    8000374c:	fffff097          	auipc	ra,0xfffff
    80003750:	7ac080e7          	jalr	1964(ra) # 80002ef8 <bread>
    80003754:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003756:	05850593          	addi	a1,a0,88
    8000375a:	40dc                	lw	a5,4(s1)
    8000375c:	8bbd                	andi	a5,a5,15
    8000375e:	079a                	slli	a5,a5,0x6
    80003760:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003762:	00059783          	lh	a5,0(a1)
    80003766:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000376a:	00259783          	lh	a5,2(a1)
    8000376e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003772:	00459783          	lh	a5,4(a1)
    80003776:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000377a:	00659783          	lh	a5,6(a1)
    8000377e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003782:	459c                	lw	a5,8(a1)
    80003784:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003786:	03400613          	li	a2,52
    8000378a:	05b1                	addi	a1,a1,12
    8000378c:	05048513          	addi	a0,s1,80
    80003790:	ffffd097          	auipc	ra,0xffffd
    80003794:	640080e7          	jalr	1600(ra) # 80000dd0 <memmove>
    brelse(bp);
    80003798:	854a                	mv	a0,s2
    8000379a:	00000097          	auipc	ra,0x0
    8000379e:	88e080e7          	jalr	-1906(ra) # 80003028 <brelse>
    ip->valid = 1;
    800037a2:	4785                	li	a5,1
    800037a4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037a6:	04449783          	lh	a5,68(s1)
    800037aa:	fbb5                	bnez	a5,8000371e <ilock+0x24>
      panic("ilock: no type");
    800037ac:	00005517          	auipc	a0,0x5
    800037b0:	e2c50513          	addi	a0,a0,-468 # 800085d8 <syscalls+0x198>
    800037b4:	ffffd097          	auipc	ra,0xffffd
    800037b8:	e22080e7          	jalr	-478(ra) # 800005d6 <panic>

00000000800037bc <iunlock>:
{
    800037bc:	1101                	addi	sp,sp,-32
    800037be:	ec06                	sd	ra,24(sp)
    800037c0:	e822                	sd	s0,16(sp)
    800037c2:	e426                	sd	s1,8(sp)
    800037c4:	e04a                	sd	s2,0(sp)
    800037c6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037c8:	c905                	beqz	a0,800037f8 <iunlock+0x3c>
    800037ca:	84aa                	mv	s1,a0
    800037cc:	01050913          	addi	s2,a0,16
    800037d0:	854a                	mv	a0,s2
    800037d2:	00001097          	auipc	ra,0x1
    800037d6:	c7c080e7          	jalr	-900(ra) # 8000444e <holdingsleep>
    800037da:	cd19                	beqz	a0,800037f8 <iunlock+0x3c>
    800037dc:	449c                	lw	a5,8(s1)
    800037de:	00f05d63          	blez	a5,800037f8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037e2:	854a                	mv	a0,s2
    800037e4:	00001097          	auipc	ra,0x1
    800037e8:	c26080e7          	jalr	-986(ra) # 8000440a <releasesleep>
}
    800037ec:	60e2                	ld	ra,24(sp)
    800037ee:	6442                	ld	s0,16(sp)
    800037f0:	64a2                	ld	s1,8(sp)
    800037f2:	6902                	ld	s2,0(sp)
    800037f4:	6105                	addi	sp,sp,32
    800037f6:	8082                	ret
    panic("iunlock");
    800037f8:	00005517          	auipc	a0,0x5
    800037fc:	df050513          	addi	a0,a0,-528 # 800085e8 <syscalls+0x1a8>
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	dd6080e7          	jalr	-554(ra) # 800005d6 <panic>

0000000080003808 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003808:	7179                	addi	sp,sp,-48
    8000380a:	f406                	sd	ra,40(sp)
    8000380c:	f022                	sd	s0,32(sp)
    8000380e:	ec26                	sd	s1,24(sp)
    80003810:	e84a                	sd	s2,16(sp)
    80003812:	e44e                	sd	s3,8(sp)
    80003814:	e052                	sd	s4,0(sp)
    80003816:	1800                	addi	s0,sp,48
    80003818:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000381a:	05050493          	addi	s1,a0,80
    8000381e:	08050913          	addi	s2,a0,128
    80003822:	a021                	j	8000382a <itrunc+0x22>
    80003824:	0491                	addi	s1,s1,4
    80003826:	01248d63          	beq	s1,s2,80003840 <itrunc+0x38>
    if(ip->addrs[i]){
    8000382a:	408c                	lw	a1,0(s1)
    8000382c:	dde5                	beqz	a1,80003824 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000382e:	0009a503          	lw	a0,0(s3)
    80003832:	00000097          	auipc	ra,0x0
    80003836:	90c080e7          	jalr	-1780(ra) # 8000313e <bfree>
      ip->addrs[i] = 0;
    8000383a:	0004a023          	sw	zero,0(s1)
    8000383e:	b7dd                	j	80003824 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003840:	0809a583          	lw	a1,128(s3)
    80003844:	e185                	bnez	a1,80003864 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003846:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000384a:	854e                	mv	a0,s3
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	de4080e7          	jalr	-540(ra) # 80003630 <iupdate>
}
    80003854:	70a2                	ld	ra,40(sp)
    80003856:	7402                	ld	s0,32(sp)
    80003858:	64e2                	ld	s1,24(sp)
    8000385a:	6942                	ld	s2,16(sp)
    8000385c:	69a2                	ld	s3,8(sp)
    8000385e:	6a02                	ld	s4,0(sp)
    80003860:	6145                	addi	sp,sp,48
    80003862:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003864:	0009a503          	lw	a0,0(s3)
    80003868:	fffff097          	auipc	ra,0xfffff
    8000386c:	690080e7          	jalr	1680(ra) # 80002ef8 <bread>
    80003870:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003872:	05850493          	addi	s1,a0,88
    80003876:	45850913          	addi	s2,a0,1112
    8000387a:	a811                	j	8000388e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    8000387c:	0009a503          	lw	a0,0(s3)
    80003880:	00000097          	auipc	ra,0x0
    80003884:	8be080e7          	jalr	-1858(ra) # 8000313e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003888:	0491                	addi	s1,s1,4
    8000388a:	01248563          	beq	s1,s2,80003894 <itrunc+0x8c>
      if(a[j])
    8000388e:	408c                	lw	a1,0(s1)
    80003890:	dde5                	beqz	a1,80003888 <itrunc+0x80>
    80003892:	b7ed                	j	8000387c <itrunc+0x74>
    brelse(bp);
    80003894:	8552                	mv	a0,s4
    80003896:	fffff097          	auipc	ra,0xfffff
    8000389a:	792080e7          	jalr	1938(ra) # 80003028 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000389e:	0809a583          	lw	a1,128(s3)
    800038a2:	0009a503          	lw	a0,0(s3)
    800038a6:	00000097          	auipc	ra,0x0
    800038aa:	898080e7          	jalr	-1896(ra) # 8000313e <bfree>
    ip->addrs[NDIRECT] = 0;
    800038ae:	0809a023          	sw	zero,128(s3)
    800038b2:	bf51                	j	80003846 <itrunc+0x3e>

00000000800038b4 <iput>:
{
    800038b4:	1101                	addi	sp,sp,-32
    800038b6:	ec06                	sd	ra,24(sp)
    800038b8:	e822                	sd	s0,16(sp)
    800038ba:	e426                	sd	s1,8(sp)
    800038bc:	e04a                	sd	s2,0(sp)
    800038be:	1000                	addi	s0,sp,32
    800038c0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038c2:	0001d517          	auipc	a0,0x1d
    800038c6:	b9e50513          	addi	a0,a0,-1122 # 80020460 <icache>
    800038ca:	ffffd097          	auipc	ra,0xffffd
    800038ce:	3aa080e7          	jalr	938(ra) # 80000c74 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038d2:	4498                	lw	a4,8(s1)
    800038d4:	4785                	li	a5,1
    800038d6:	02f70363          	beq	a4,a5,800038fc <iput+0x48>
  ip->ref--;
    800038da:	449c                	lw	a5,8(s1)
    800038dc:	37fd                	addiw	a5,a5,-1
    800038de:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800038e0:	0001d517          	auipc	a0,0x1d
    800038e4:	b8050513          	addi	a0,a0,-1152 # 80020460 <icache>
    800038e8:	ffffd097          	auipc	ra,0xffffd
    800038ec:	440080e7          	jalr	1088(ra) # 80000d28 <release>
}
    800038f0:	60e2                	ld	ra,24(sp)
    800038f2:	6442                	ld	s0,16(sp)
    800038f4:	64a2                	ld	s1,8(sp)
    800038f6:	6902                	ld	s2,0(sp)
    800038f8:	6105                	addi	sp,sp,32
    800038fa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038fc:	40bc                	lw	a5,64(s1)
    800038fe:	dff1                	beqz	a5,800038da <iput+0x26>
    80003900:	04a49783          	lh	a5,74(s1)
    80003904:	fbf9                	bnez	a5,800038da <iput+0x26>
    acquiresleep(&ip->lock);
    80003906:	01048913          	addi	s2,s1,16
    8000390a:	854a                	mv	a0,s2
    8000390c:	00001097          	auipc	ra,0x1
    80003910:	aa8080e7          	jalr	-1368(ra) # 800043b4 <acquiresleep>
    release(&icache.lock);
    80003914:	0001d517          	auipc	a0,0x1d
    80003918:	b4c50513          	addi	a0,a0,-1204 # 80020460 <icache>
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	40c080e7          	jalr	1036(ra) # 80000d28 <release>
    itrunc(ip);
    80003924:	8526                	mv	a0,s1
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	ee2080e7          	jalr	-286(ra) # 80003808 <itrunc>
    ip->type = 0;
    8000392e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003932:	8526                	mv	a0,s1
    80003934:	00000097          	auipc	ra,0x0
    80003938:	cfc080e7          	jalr	-772(ra) # 80003630 <iupdate>
    ip->valid = 0;
    8000393c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003940:	854a                	mv	a0,s2
    80003942:	00001097          	auipc	ra,0x1
    80003946:	ac8080e7          	jalr	-1336(ra) # 8000440a <releasesleep>
    acquire(&icache.lock);
    8000394a:	0001d517          	auipc	a0,0x1d
    8000394e:	b1650513          	addi	a0,a0,-1258 # 80020460 <icache>
    80003952:	ffffd097          	auipc	ra,0xffffd
    80003956:	322080e7          	jalr	802(ra) # 80000c74 <acquire>
    8000395a:	b741                	j	800038da <iput+0x26>

000000008000395c <iunlockput>:
{
    8000395c:	1101                	addi	sp,sp,-32
    8000395e:	ec06                	sd	ra,24(sp)
    80003960:	e822                	sd	s0,16(sp)
    80003962:	e426                	sd	s1,8(sp)
    80003964:	1000                	addi	s0,sp,32
    80003966:	84aa                	mv	s1,a0
  iunlock(ip);
    80003968:	00000097          	auipc	ra,0x0
    8000396c:	e54080e7          	jalr	-428(ra) # 800037bc <iunlock>
  iput(ip);
    80003970:	8526                	mv	a0,s1
    80003972:	00000097          	auipc	ra,0x0
    80003976:	f42080e7          	jalr	-190(ra) # 800038b4 <iput>
}
    8000397a:	60e2                	ld	ra,24(sp)
    8000397c:	6442                	ld	s0,16(sp)
    8000397e:	64a2                	ld	s1,8(sp)
    80003980:	6105                	addi	sp,sp,32
    80003982:	8082                	ret

0000000080003984 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003984:	1141                	addi	sp,sp,-16
    80003986:	e422                	sd	s0,8(sp)
    80003988:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000398a:	411c                	lw	a5,0(a0)
    8000398c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000398e:	415c                	lw	a5,4(a0)
    80003990:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003992:	04451783          	lh	a5,68(a0)
    80003996:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000399a:	04a51783          	lh	a5,74(a0)
    8000399e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039a2:	04c56783          	lwu	a5,76(a0)
    800039a6:	e99c                	sd	a5,16(a1)
}
    800039a8:	6422                	ld	s0,8(sp)
    800039aa:	0141                	addi	sp,sp,16
    800039ac:	8082                	ret

00000000800039ae <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039ae:	457c                	lw	a5,76(a0)
    800039b0:	0ed7e863          	bltu	a5,a3,80003aa0 <readi+0xf2>
{
    800039b4:	7159                	addi	sp,sp,-112
    800039b6:	f486                	sd	ra,104(sp)
    800039b8:	f0a2                	sd	s0,96(sp)
    800039ba:	eca6                	sd	s1,88(sp)
    800039bc:	e8ca                	sd	s2,80(sp)
    800039be:	e4ce                	sd	s3,72(sp)
    800039c0:	e0d2                	sd	s4,64(sp)
    800039c2:	fc56                	sd	s5,56(sp)
    800039c4:	f85a                	sd	s6,48(sp)
    800039c6:	f45e                	sd	s7,40(sp)
    800039c8:	f062                	sd	s8,32(sp)
    800039ca:	ec66                	sd	s9,24(sp)
    800039cc:	e86a                	sd	s10,16(sp)
    800039ce:	e46e                	sd	s11,8(sp)
    800039d0:	1880                	addi	s0,sp,112
    800039d2:	8baa                	mv	s7,a0
    800039d4:	8c2e                	mv	s8,a1
    800039d6:	8ab2                	mv	s5,a2
    800039d8:	84b6                	mv	s1,a3
    800039da:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039dc:	9f35                	addw	a4,a4,a3
    return 0;
    800039de:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039e0:	08d76f63          	bltu	a4,a3,80003a7e <readi+0xd0>
  if(off + n > ip->size)
    800039e4:	00e7f463          	bgeu	a5,a4,800039ec <readi+0x3e>
    n = ip->size - off;
    800039e8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ec:	0a0b0863          	beqz	s6,80003a9c <readi+0xee>
    800039f0:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039f6:	5cfd                	li	s9,-1
    800039f8:	a82d                	j	80003a32 <readi+0x84>
    800039fa:	020a1d93          	slli	s11,s4,0x20
    800039fe:	020ddd93          	srli	s11,s11,0x20
    80003a02:	05890613          	addi	a2,s2,88
    80003a06:	86ee                	mv	a3,s11
    80003a08:	963a                	add	a2,a2,a4
    80003a0a:	85d6                	mv	a1,s5
    80003a0c:	8562                	mv	a0,s8
    80003a0e:	fffff097          	auipc	ra,0xfffff
    80003a12:	acc080e7          	jalr	-1332(ra) # 800024da <either_copyout>
    80003a16:	05950d63          	beq	a0,s9,80003a70 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003a1a:	854a                	mv	a0,s2
    80003a1c:	fffff097          	auipc	ra,0xfffff
    80003a20:	60c080e7          	jalr	1548(ra) # 80003028 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a24:	013a09bb          	addw	s3,s4,s3
    80003a28:	009a04bb          	addw	s1,s4,s1
    80003a2c:	9aee                	add	s5,s5,s11
    80003a2e:	0569f663          	bgeu	s3,s6,80003a7a <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a32:	000ba903          	lw	s2,0(s7)
    80003a36:	00a4d59b          	srliw	a1,s1,0xa
    80003a3a:	855e                	mv	a0,s7
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	8b0080e7          	jalr	-1872(ra) # 800032ec <bmap>
    80003a44:	0005059b          	sext.w	a1,a0
    80003a48:	854a                	mv	a0,s2
    80003a4a:	fffff097          	auipc	ra,0xfffff
    80003a4e:	4ae080e7          	jalr	1198(ra) # 80002ef8 <bread>
    80003a52:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a54:	3ff4f713          	andi	a4,s1,1023
    80003a58:	40ed07bb          	subw	a5,s10,a4
    80003a5c:	413b06bb          	subw	a3,s6,s3
    80003a60:	8a3e                	mv	s4,a5
    80003a62:	2781                	sext.w	a5,a5
    80003a64:	0006861b          	sext.w	a2,a3
    80003a68:	f8f679e3          	bgeu	a2,a5,800039fa <readi+0x4c>
    80003a6c:	8a36                	mv	s4,a3
    80003a6e:	b771                	j	800039fa <readi+0x4c>
      brelse(bp);
    80003a70:	854a                	mv	a0,s2
    80003a72:	fffff097          	auipc	ra,0xfffff
    80003a76:	5b6080e7          	jalr	1462(ra) # 80003028 <brelse>
  }
  return tot;
    80003a7a:	0009851b          	sext.w	a0,s3
}
    80003a7e:	70a6                	ld	ra,104(sp)
    80003a80:	7406                	ld	s0,96(sp)
    80003a82:	64e6                	ld	s1,88(sp)
    80003a84:	6946                	ld	s2,80(sp)
    80003a86:	69a6                	ld	s3,72(sp)
    80003a88:	6a06                	ld	s4,64(sp)
    80003a8a:	7ae2                	ld	s5,56(sp)
    80003a8c:	7b42                	ld	s6,48(sp)
    80003a8e:	7ba2                	ld	s7,40(sp)
    80003a90:	7c02                	ld	s8,32(sp)
    80003a92:	6ce2                	ld	s9,24(sp)
    80003a94:	6d42                	ld	s10,16(sp)
    80003a96:	6da2                	ld	s11,8(sp)
    80003a98:	6165                	addi	sp,sp,112
    80003a9a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a9c:	89da                	mv	s3,s6
    80003a9e:	bff1                	j	80003a7a <readi+0xcc>
    return 0;
    80003aa0:	4501                	li	a0,0
}
    80003aa2:	8082                	ret

0000000080003aa4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aa4:	457c                	lw	a5,76(a0)
    80003aa6:	10d7e663          	bltu	a5,a3,80003bb2 <writei+0x10e>
{
    80003aaa:	7159                	addi	sp,sp,-112
    80003aac:	f486                	sd	ra,104(sp)
    80003aae:	f0a2                	sd	s0,96(sp)
    80003ab0:	eca6                	sd	s1,88(sp)
    80003ab2:	e8ca                	sd	s2,80(sp)
    80003ab4:	e4ce                	sd	s3,72(sp)
    80003ab6:	e0d2                	sd	s4,64(sp)
    80003ab8:	fc56                	sd	s5,56(sp)
    80003aba:	f85a                	sd	s6,48(sp)
    80003abc:	f45e                	sd	s7,40(sp)
    80003abe:	f062                	sd	s8,32(sp)
    80003ac0:	ec66                	sd	s9,24(sp)
    80003ac2:	e86a                	sd	s10,16(sp)
    80003ac4:	e46e                	sd	s11,8(sp)
    80003ac6:	1880                	addi	s0,sp,112
    80003ac8:	8baa                	mv	s7,a0
    80003aca:	8c2e                	mv	s8,a1
    80003acc:	8ab2                	mv	s5,a2
    80003ace:	8936                	mv	s2,a3
    80003ad0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ad2:	00e687bb          	addw	a5,a3,a4
    80003ad6:	0ed7e063          	bltu	a5,a3,80003bb6 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ada:	00043737          	lui	a4,0x43
    80003ade:	0cf76e63          	bltu	a4,a5,80003bba <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ae2:	0a0b0763          	beqz	s6,80003b90 <writei+0xec>
    80003ae6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003aec:	5cfd                	li	s9,-1
    80003aee:	a091                	j	80003b32 <writei+0x8e>
    80003af0:	02099d93          	slli	s11,s3,0x20
    80003af4:	020ddd93          	srli	s11,s11,0x20
    80003af8:	05848513          	addi	a0,s1,88
    80003afc:	86ee                	mv	a3,s11
    80003afe:	8656                	mv	a2,s5
    80003b00:	85e2                	mv	a1,s8
    80003b02:	953a                	add	a0,a0,a4
    80003b04:	fffff097          	auipc	ra,0xfffff
    80003b08:	a2c080e7          	jalr	-1492(ra) # 80002530 <either_copyin>
    80003b0c:	07950263          	beq	a0,s9,80003b70 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b10:	8526                	mv	a0,s1
    80003b12:	00000097          	auipc	ra,0x0
    80003b16:	77a080e7          	jalr	1914(ra) # 8000428c <log_write>
    brelse(bp);
    80003b1a:	8526                	mv	a0,s1
    80003b1c:	fffff097          	auipc	ra,0xfffff
    80003b20:	50c080e7          	jalr	1292(ra) # 80003028 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b24:	01498a3b          	addw	s4,s3,s4
    80003b28:	0129893b          	addw	s2,s3,s2
    80003b2c:	9aee                	add	s5,s5,s11
    80003b2e:	056a7663          	bgeu	s4,s6,80003b7a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b32:	000ba483          	lw	s1,0(s7)
    80003b36:	00a9559b          	srliw	a1,s2,0xa
    80003b3a:	855e                	mv	a0,s7
    80003b3c:	fffff097          	auipc	ra,0xfffff
    80003b40:	7b0080e7          	jalr	1968(ra) # 800032ec <bmap>
    80003b44:	0005059b          	sext.w	a1,a0
    80003b48:	8526                	mv	a0,s1
    80003b4a:	fffff097          	auipc	ra,0xfffff
    80003b4e:	3ae080e7          	jalr	942(ra) # 80002ef8 <bread>
    80003b52:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b54:	3ff97713          	andi	a4,s2,1023
    80003b58:	40ed07bb          	subw	a5,s10,a4
    80003b5c:	414b06bb          	subw	a3,s6,s4
    80003b60:	89be                	mv	s3,a5
    80003b62:	2781                	sext.w	a5,a5
    80003b64:	0006861b          	sext.w	a2,a3
    80003b68:	f8f674e3          	bgeu	a2,a5,80003af0 <writei+0x4c>
    80003b6c:	89b6                	mv	s3,a3
    80003b6e:	b749                	j	80003af0 <writei+0x4c>
      brelse(bp);
    80003b70:	8526                	mv	a0,s1
    80003b72:	fffff097          	auipc	ra,0xfffff
    80003b76:	4b6080e7          	jalr	1206(ra) # 80003028 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003b7a:	04cba783          	lw	a5,76(s7)
    80003b7e:	0127f463          	bgeu	a5,s2,80003b86 <writei+0xe2>
      ip->size = off;
    80003b82:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003b86:	855e                	mv	a0,s7
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	aa8080e7          	jalr	-1368(ra) # 80003630 <iupdate>
  }

  return n;
    80003b90:	000b051b          	sext.w	a0,s6
}
    80003b94:	70a6                	ld	ra,104(sp)
    80003b96:	7406                	ld	s0,96(sp)
    80003b98:	64e6                	ld	s1,88(sp)
    80003b9a:	6946                	ld	s2,80(sp)
    80003b9c:	69a6                	ld	s3,72(sp)
    80003b9e:	6a06                	ld	s4,64(sp)
    80003ba0:	7ae2                	ld	s5,56(sp)
    80003ba2:	7b42                	ld	s6,48(sp)
    80003ba4:	7ba2                	ld	s7,40(sp)
    80003ba6:	7c02                	ld	s8,32(sp)
    80003ba8:	6ce2                	ld	s9,24(sp)
    80003baa:	6d42                	ld	s10,16(sp)
    80003bac:	6da2                	ld	s11,8(sp)
    80003bae:	6165                	addi	sp,sp,112
    80003bb0:	8082                	ret
    return -1;
    80003bb2:	557d                	li	a0,-1
}
    80003bb4:	8082                	ret
    return -1;
    80003bb6:	557d                	li	a0,-1
    80003bb8:	bff1                	j	80003b94 <writei+0xf0>
    return -1;
    80003bba:	557d                	li	a0,-1
    80003bbc:	bfe1                	j	80003b94 <writei+0xf0>

0000000080003bbe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bbe:	1141                	addi	sp,sp,-16
    80003bc0:	e406                	sd	ra,8(sp)
    80003bc2:	e022                	sd	s0,0(sp)
    80003bc4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bc6:	4639                	li	a2,14
    80003bc8:	ffffd097          	auipc	ra,0xffffd
    80003bcc:	284080e7          	jalr	644(ra) # 80000e4c <strncmp>
}
    80003bd0:	60a2                	ld	ra,8(sp)
    80003bd2:	6402                	ld	s0,0(sp)
    80003bd4:	0141                	addi	sp,sp,16
    80003bd6:	8082                	ret

0000000080003bd8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bd8:	7139                	addi	sp,sp,-64
    80003bda:	fc06                	sd	ra,56(sp)
    80003bdc:	f822                	sd	s0,48(sp)
    80003bde:	f426                	sd	s1,40(sp)
    80003be0:	f04a                	sd	s2,32(sp)
    80003be2:	ec4e                	sd	s3,24(sp)
    80003be4:	e852                	sd	s4,16(sp)
    80003be6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003be8:	04451703          	lh	a4,68(a0)
    80003bec:	4785                	li	a5,1
    80003bee:	00f71a63          	bne	a4,a5,80003c02 <dirlookup+0x2a>
    80003bf2:	892a                	mv	s2,a0
    80003bf4:	89ae                	mv	s3,a1
    80003bf6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf8:	457c                	lw	a5,76(a0)
    80003bfa:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bfc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bfe:	e79d                	bnez	a5,80003c2c <dirlookup+0x54>
    80003c00:	a8a5                	j	80003c78 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c02:	00005517          	auipc	a0,0x5
    80003c06:	9ee50513          	addi	a0,a0,-1554 # 800085f0 <syscalls+0x1b0>
    80003c0a:	ffffd097          	auipc	ra,0xffffd
    80003c0e:	9cc080e7          	jalr	-1588(ra) # 800005d6 <panic>
      panic("dirlookup read");
    80003c12:	00005517          	auipc	a0,0x5
    80003c16:	9f650513          	addi	a0,a0,-1546 # 80008608 <syscalls+0x1c8>
    80003c1a:	ffffd097          	auipc	ra,0xffffd
    80003c1e:	9bc080e7          	jalr	-1604(ra) # 800005d6 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c22:	24c1                	addiw	s1,s1,16
    80003c24:	04c92783          	lw	a5,76(s2)
    80003c28:	04f4f763          	bgeu	s1,a5,80003c76 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c2c:	4741                	li	a4,16
    80003c2e:	86a6                	mv	a3,s1
    80003c30:	fc040613          	addi	a2,s0,-64
    80003c34:	4581                	li	a1,0
    80003c36:	854a                	mv	a0,s2
    80003c38:	00000097          	auipc	ra,0x0
    80003c3c:	d76080e7          	jalr	-650(ra) # 800039ae <readi>
    80003c40:	47c1                	li	a5,16
    80003c42:	fcf518e3          	bne	a0,a5,80003c12 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c46:	fc045783          	lhu	a5,-64(s0)
    80003c4a:	dfe1                	beqz	a5,80003c22 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c4c:	fc240593          	addi	a1,s0,-62
    80003c50:	854e                	mv	a0,s3
    80003c52:	00000097          	auipc	ra,0x0
    80003c56:	f6c080e7          	jalr	-148(ra) # 80003bbe <namecmp>
    80003c5a:	f561                	bnez	a0,80003c22 <dirlookup+0x4a>
      if(poff)
    80003c5c:	000a0463          	beqz	s4,80003c64 <dirlookup+0x8c>
        *poff = off;
    80003c60:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c64:	fc045583          	lhu	a1,-64(s0)
    80003c68:	00092503          	lw	a0,0(s2)
    80003c6c:	fffff097          	auipc	ra,0xfffff
    80003c70:	75a080e7          	jalr	1882(ra) # 800033c6 <iget>
    80003c74:	a011                	j	80003c78 <dirlookup+0xa0>
  return 0;
    80003c76:	4501                	li	a0,0
}
    80003c78:	70e2                	ld	ra,56(sp)
    80003c7a:	7442                	ld	s0,48(sp)
    80003c7c:	74a2                	ld	s1,40(sp)
    80003c7e:	7902                	ld	s2,32(sp)
    80003c80:	69e2                	ld	s3,24(sp)
    80003c82:	6a42                	ld	s4,16(sp)
    80003c84:	6121                	addi	sp,sp,64
    80003c86:	8082                	ret

0000000080003c88 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c88:	711d                	addi	sp,sp,-96
    80003c8a:	ec86                	sd	ra,88(sp)
    80003c8c:	e8a2                	sd	s0,80(sp)
    80003c8e:	e4a6                	sd	s1,72(sp)
    80003c90:	e0ca                	sd	s2,64(sp)
    80003c92:	fc4e                	sd	s3,56(sp)
    80003c94:	f852                	sd	s4,48(sp)
    80003c96:	f456                	sd	s5,40(sp)
    80003c98:	f05a                	sd	s6,32(sp)
    80003c9a:	ec5e                	sd	s7,24(sp)
    80003c9c:	e862                	sd	s8,16(sp)
    80003c9e:	e466                	sd	s9,8(sp)
    80003ca0:	1080                	addi	s0,sp,96
    80003ca2:	84aa                	mv	s1,a0
    80003ca4:	8b2e                	mv	s6,a1
    80003ca6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ca8:	00054703          	lbu	a4,0(a0)
    80003cac:	02f00793          	li	a5,47
    80003cb0:	02f70363          	beq	a4,a5,80003cd6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cb4:	ffffe097          	auipc	ra,0xffffe
    80003cb8:	d8e080e7          	jalr	-626(ra) # 80001a42 <myproc>
    80003cbc:	15053503          	ld	a0,336(a0)
    80003cc0:	00000097          	auipc	ra,0x0
    80003cc4:	9fc080e7          	jalr	-1540(ra) # 800036bc <idup>
    80003cc8:	89aa                	mv	s3,a0
  while(*path == '/')
    80003cca:	02f00913          	li	s2,47
  len = path - s;
    80003cce:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003cd0:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cd2:	4c05                	li	s8,1
    80003cd4:	a865                	j	80003d8c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003cd6:	4585                	li	a1,1
    80003cd8:	4505                	li	a0,1
    80003cda:	fffff097          	auipc	ra,0xfffff
    80003cde:	6ec080e7          	jalr	1772(ra) # 800033c6 <iget>
    80003ce2:	89aa                	mv	s3,a0
    80003ce4:	b7dd                	j	80003cca <namex+0x42>
      iunlockput(ip);
    80003ce6:	854e                	mv	a0,s3
    80003ce8:	00000097          	auipc	ra,0x0
    80003cec:	c74080e7          	jalr	-908(ra) # 8000395c <iunlockput>
      return 0;
    80003cf0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cf2:	854e                	mv	a0,s3
    80003cf4:	60e6                	ld	ra,88(sp)
    80003cf6:	6446                	ld	s0,80(sp)
    80003cf8:	64a6                	ld	s1,72(sp)
    80003cfa:	6906                	ld	s2,64(sp)
    80003cfc:	79e2                	ld	s3,56(sp)
    80003cfe:	7a42                	ld	s4,48(sp)
    80003d00:	7aa2                	ld	s5,40(sp)
    80003d02:	7b02                	ld	s6,32(sp)
    80003d04:	6be2                	ld	s7,24(sp)
    80003d06:	6c42                	ld	s8,16(sp)
    80003d08:	6ca2                	ld	s9,8(sp)
    80003d0a:	6125                	addi	sp,sp,96
    80003d0c:	8082                	ret
      iunlock(ip);
    80003d0e:	854e                	mv	a0,s3
    80003d10:	00000097          	auipc	ra,0x0
    80003d14:	aac080e7          	jalr	-1364(ra) # 800037bc <iunlock>
      return ip;
    80003d18:	bfe9                	j	80003cf2 <namex+0x6a>
      iunlockput(ip);
    80003d1a:	854e                	mv	a0,s3
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	c40080e7          	jalr	-960(ra) # 8000395c <iunlockput>
      return 0;
    80003d24:	89d2                	mv	s3,s4
    80003d26:	b7f1                	j	80003cf2 <namex+0x6a>
  len = path - s;
    80003d28:	40b48633          	sub	a2,s1,a1
    80003d2c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003d30:	094cd463          	bge	s9,s4,80003db8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d34:	4639                	li	a2,14
    80003d36:	8556                	mv	a0,s5
    80003d38:	ffffd097          	auipc	ra,0xffffd
    80003d3c:	098080e7          	jalr	152(ra) # 80000dd0 <memmove>
  while(*path == '/')
    80003d40:	0004c783          	lbu	a5,0(s1)
    80003d44:	01279763          	bne	a5,s2,80003d52 <namex+0xca>
    path++;
    80003d48:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d4a:	0004c783          	lbu	a5,0(s1)
    80003d4e:	ff278de3          	beq	a5,s2,80003d48 <namex+0xc0>
    ilock(ip);
    80003d52:	854e                	mv	a0,s3
    80003d54:	00000097          	auipc	ra,0x0
    80003d58:	9a6080e7          	jalr	-1626(ra) # 800036fa <ilock>
    if(ip->type != T_DIR){
    80003d5c:	04499783          	lh	a5,68(s3)
    80003d60:	f98793e3          	bne	a5,s8,80003ce6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d64:	000b0563          	beqz	s6,80003d6e <namex+0xe6>
    80003d68:	0004c783          	lbu	a5,0(s1)
    80003d6c:	d3cd                	beqz	a5,80003d0e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d6e:	865e                	mv	a2,s7
    80003d70:	85d6                	mv	a1,s5
    80003d72:	854e                	mv	a0,s3
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	e64080e7          	jalr	-412(ra) # 80003bd8 <dirlookup>
    80003d7c:	8a2a                	mv	s4,a0
    80003d7e:	dd51                	beqz	a0,80003d1a <namex+0x92>
    iunlockput(ip);
    80003d80:	854e                	mv	a0,s3
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	bda080e7          	jalr	-1062(ra) # 8000395c <iunlockput>
    ip = next;
    80003d8a:	89d2                	mv	s3,s4
  while(*path == '/')
    80003d8c:	0004c783          	lbu	a5,0(s1)
    80003d90:	05279763          	bne	a5,s2,80003dde <namex+0x156>
    path++;
    80003d94:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d96:	0004c783          	lbu	a5,0(s1)
    80003d9a:	ff278de3          	beq	a5,s2,80003d94 <namex+0x10c>
  if(*path == 0)
    80003d9e:	c79d                	beqz	a5,80003dcc <namex+0x144>
    path++;
    80003da0:	85a6                	mv	a1,s1
  len = path - s;
    80003da2:	8a5e                	mv	s4,s7
    80003da4:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003da6:	01278963          	beq	a5,s2,80003db8 <namex+0x130>
    80003daa:	dfbd                	beqz	a5,80003d28 <namex+0xa0>
    path++;
    80003dac:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003dae:	0004c783          	lbu	a5,0(s1)
    80003db2:	ff279ce3          	bne	a5,s2,80003daa <namex+0x122>
    80003db6:	bf8d                	j	80003d28 <namex+0xa0>
    memmove(name, s, len);
    80003db8:	2601                	sext.w	a2,a2
    80003dba:	8556                	mv	a0,s5
    80003dbc:	ffffd097          	auipc	ra,0xffffd
    80003dc0:	014080e7          	jalr	20(ra) # 80000dd0 <memmove>
    name[len] = 0;
    80003dc4:	9a56                	add	s4,s4,s5
    80003dc6:	000a0023          	sb	zero,0(s4)
    80003dca:	bf9d                	j	80003d40 <namex+0xb8>
  if(nameiparent){
    80003dcc:	f20b03e3          	beqz	s6,80003cf2 <namex+0x6a>
    iput(ip);
    80003dd0:	854e                	mv	a0,s3
    80003dd2:	00000097          	auipc	ra,0x0
    80003dd6:	ae2080e7          	jalr	-1310(ra) # 800038b4 <iput>
    return 0;
    80003dda:	4981                	li	s3,0
    80003ddc:	bf19                	j	80003cf2 <namex+0x6a>
  if(*path == 0)
    80003dde:	d7fd                	beqz	a5,80003dcc <namex+0x144>
  while(*path != '/' && *path != 0)
    80003de0:	0004c783          	lbu	a5,0(s1)
    80003de4:	85a6                	mv	a1,s1
    80003de6:	b7d1                	j	80003daa <namex+0x122>

0000000080003de8 <dirlink>:
{
    80003de8:	7139                	addi	sp,sp,-64
    80003dea:	fc06                	sd	ra,56(sp)
    80003dec:	f822                	sd	s0,48(sp)
    80003dee:	f426                	sd	s1,40(sp)
    80003df0:	f04a                	sd	s2,32(sp)
    80003df2:	ec4e                	sd	s3,24(sp)
    80003df4:	e852                	sd	s4,16(sp)
    80003df6:	0080                	addi	s0,sp,64
    80003df8:	892a                	mv	s2,a0
    80003dfa:	8a2e                	mv	s4,a1
    80003dfc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dfe:	4601                	li	a2,0
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	dd8080e7          	jalr	-552(ra) # 80003bd8 <dirlookup>
    80003e08:	e93d                	bnez	a0,80003e7e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e0a:	04c92483          	lw	s1,76(s2)
    80003e0e:	c49d                	beqz	s1,80003e3c <dirlink+0x54>
    80003e10:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e12:	4741                	li	a4,16
    80003e14:	86a6                	mv	a3,s1
    80003e16:	fc040613          	addi	a2,s0,-64
    80003e1a:	4581                	li	a1,0
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	b90080e7          	jalr	-1136(ra) # 800039ae <readi>
    80003e26:	47c1                	li	a5,16
    80003e28:	06f51163          	bne	a0,a5,80003e8a <dirlink+0xa2>
    if(de.inum == 0)
    80003e2c:	fc045783          	lhu	a5,-64(s0)
    80003e30:	c791                	beqz	a5,80003e3c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e32:	24c1                	addiw	s1,s1,16
    80003e34:	04c92783          	lw	a5,76(s2)
    80003e38:	fcf4ede3          	bltu	s1,a5,80003e12 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e3c:	4639                	li	a2,14
    80003e3e:	85d2                	mv	a1,s4
    80003e40:	fc240513          	addi	a0,s0,-62
    80003e44:	ffffd097          	auipc	ra,0xffffd
    80003e48:	044080e7          	jalr	68(ra) # 80000e88 <strncpy>
  de.inum = inum;
    80003e4c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e50:	4741                	li	a4,16
    80003e52:	86a6                	mv	a3,s1
    80003e54:	fc040613          	addi	a2,s0,-64
    80003e58:	4581                	li	a1,0
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	c48080e7          	jalr	-952(ra) # 80003aa4 <writei>
    80003e64:	872a                	mv	a4,a0
    80003e66:	47c1                	li	a5,16
  return 0;
    80003e68:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e6a:	02f71863          	bne	a4,a5,80003e9a <dirlink+0xb2>
}
    80003e6e:	70e2                	ld	ra,56(sp)
    80003e70:	7442                	ld	s0,48(sp)
    80003e72:	74a2                	ld	s1,40(sp)
    80003e74:	7902                	ld	s2,32(sp)
    80003e76:	69e2                	ld	s3,24(sp)
    80003e78:	6a42                	ld	s4,16(sp)
    80003e7a:	6121                	addi	sp,sp,64
    80003e7c:	8082                	ret
    iput(ip);
    80003e7e:	00000097          	auipc	ra,0x0
    80003e82:	a36080e7          	jalr	-1482(ra) # 800038b4 <iput>
    return -1;
    80003e86:	557d                	li	a0,-1
    80003e88:	b7dd                	j	80003e6e <dirlink+0x86>
      panic("dirlink read");
    80003e8a:	00004517          	auipc	a0,0x4
    80003e8e:	78e50513          	addi	a0,a0,1934 # 80008618 <syscalls+0x1d8>
    80003e92:	ffffc097          	auipc	ra,0xffffc
    80003e96:	744080e7          	jalr	1860(ra) # 800005d6 <panic>
    panic("dirlink");
    80003e9a:	00005517          	auipc	a0,0x5
    80003e9e:	89e50513          	addi	a0,a0,-1890 # 80008738 <syscalls+0x2f8>
    80003ea2:	ffffc097          	auipc	ra,0xffffc
    80003ea6:	734080e7          	jalr	1844(ra) # 800005d6 <panic>

0000000080003eaa <namei>:

struct inode*
namei(char *path)
{
    80003eaa:	1101                	addi	sp,sp,-32
    80003eac:	ec06                	sd	ra,24(sp)
    80003eae:	e822                	sd	s0,16(sp)
    80003eb0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003eb2:	fe040613          	addi	a2,s0,-32
    80003eb6:	4581                	li	a1,0
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	dd0080e7          	jalr	-560(ra) # 80003c88 <namex>
}
    80003ec0:	60e2                	ld	ra,24(sp)
    80003ec2:	6442                	ld	s0,16(sp)
    80003ec4:	6105                	addi	sp,sp,32
    80003ec6:	8082                	ret

0000000080003ec8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ec8:	1141                	addi	sp,sp,-16
    80003eca:	e406                	sd	ra,8(sp)
    80003ecc:	e022                	sd	s0,0(sp)
    80003ece:	0800                	addi	s0,sp,16
    80003ed0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ed2:	4585                	li	a1,1
    80003ed4:	00000097          	auipc	ra,0x0
    80003ed8:	db4080e7          	jalr	-588(ra) # 80003c88 <namex>
}
    80003edc:	60a2                	ld	ra,8(sp)
    80003ede:	6402                	ld	s0,0(sp)
    80003ee0:	0141                	addi	sp,sp,16
    80003ee2:	8082                	ret

0000000080003ee4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ee4:	1101                	addi	sp,sp,-32
    80003ee6:	ec06                	sd	ra,24(sp)
    80003ee8:	e822                	sd	s0,16(sp)
    80003eea:	e426                	sd	s1,8(sp)
    80003eec:	e04a                	sd	s2,0(sp)
    80003eee:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ef0:	0001e917          	auipc	s2,0x1e
    80003ef4:	01890913          	addi	s2,s2,24 # 80021f08 <log>
    80003ef8:	01892583          	lw	a1,24(s2)
    80003efc:	02892503          	lw	a0,40(s2)
    80003f00:	fffff097          	auipc	ra,0xfffff
    80003f04:	ff8080e7          	jalr	-8(ra) # 80002ef8 <bread>
    80003f08:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f0a:	02c92683          	lw	a3,44(s2)
    80003f0e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f10:	02d05763          	blez	a3,80003f3e <write_head+0x5a>
    80003f14:	0001e797          	auipc	a5,0x1e
    80003f18:	02478793          	addi	a5,a5,36 # 80021f38 <log+0x30>
    80003f1c:	05c50713          	addi	a4,a0,92
    80003f20:	36fd                	addiw	a3,a3,-1
    80003f22:	1682                	slli	a3,a3,0x20
    80003f24:	9281                	srli	a3,a3,0x20
    80003f26:	068a                	slli	a3,a3,0x2
    80003f28:	0001e617          	auipc	a2,0x1e
    80003f2c:	01460613          	addi	a2,a2,20 # 80021f3c <log+0x34>
    80003f30:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f32:	4390                	lw	a2,0(a5)
    80003f34:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f36:	0791                	addi	a5,a5,4
    80003f38:	0711                	addi	a4,a4,4
    80003f3a:	fed79ce3          	bne	a5,a3,80003f32 <write_head+0x4e>
  }
  bwrite(buf);
    80003f3e:	8526                	mv	a0,s1
    80003f40:	fffff097          	auipc	ra,0xfffff
    80003f44:	0aa080e7          	jalr	170(ra) # 80002fea <bwrite>
  brelse(buf);
    80003f48:	8526                	mv	a0,s1
    80003f4a:	fffff097          	auipc	ra,0xfffff
    80003f4e:	0de080e7          	jalr	222(ra) # 80003028 <brelse>
}
    80003f52:	60e2                	ld	ra,24(sp)
    80003f54:	6442                	ld	s0,16(sp)
    80003f56:	64a2                	ld	s1,8(sp)
    80003f58:	6902                	ld	s2,0(sp)
    80003f5a:	6105                	addi	sp,sp,32
    80003f5c:	8082                	ret

0000000080003f5e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f5e:	0001e797          	auipc	a5,0x1e
    80003f62:	fd67a783          	lw	a5,-42(a5) # 80021f34 <log+0x2c>
    80003f66:	0af05663          	blez	a5,80004012 <install_trans+0xb4>
{
    80003f6a:	7139                	addi	sp,sp,-64
    80003f6c:	fc06                	sd	ra,56(sp)
    80003f6e:	f822                	sd	s0,48(sp)
    80003f70:	f426                	sd	s1,40(sp)
    80003f72:	f04a                	sd	s2,32(sp)
    80003f74:	ec4e                	sd	s3,24(sp)
    80003f76:	e852                	sd	s4,16(sp)
    80003f78:	e456                	sd	s5,8(sp)
    80003f7a:	0080                	addi	s0,sp,64
    80003f7c:	0001ea97          	auipc	s5,0x1e
    80003f80:	fbca8a93          	addi	s5,s5,-68 # 80021f38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f84:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f86:	0001e997          	auipc	s3,0x1e
    80003f8a:	f8298993          	addi	s3,s3,-126 # 80021f08 <log>
    80003f8e:	0189a583          	lw	a1,24(s3)
    80003f92:	014585bb          	addw	a1,a1,s4
    80003f96:	2585                	addiw	a1,a1,1
    80003f98:	0289a503          	lw	a0,40(s3)
    80003f9c:	fffff097          	auipc	ra,0xfffff
    80003fa0:	f5c080e7          	jalr	-164(ra) # 80002ef8 <bread>
    80003fa4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fa6:	000aa583          	lw	a1,0(s5)
    80003faa:	0289a503          	lw	a0,40(s3)
    80003fae:	fffff097          	auipc	ra,0xfffff
    80003fb2:	f4a080e7          	jalr	-182(ra) # 80002ef8 <bread>
    80003fb6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fb8:	40000613          	li	a2,1024
    80003fbc:	05890593          	addi	a1,s2,88
    80003fc0:	05850513          	addi	a0,a0,88
    80003fc4:	ffffd097          	auipc	ra,0xffffd
    80003fc8:	e0c080e7          	jalr	-500(ra) # 80000dd0 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fcc:	8526                	mv	a0,s1
    80003fce:	fffff097          	auipc	ra,0xfffff
    80003fd2:	01c080e7          	jalr	28(ra) # 80002fea <bwrite>
    bunpin(dbuf);
    80003fd6:	8526                	mv	a0,s1
    80003fd8:	fffff097          	auipc	ra,0xfffff
    80003fdc:	12a080e7          	jalr	298(ra) # 80003102 <bunpin>
    brelse(lbuf);
    80003fe0:	854a                	mv	a0,s2
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	046080e7          	jalr	70(ra) # 80003028 <brelse>
    brelse(dbuf);
    80003fea:	8526                	mv	a0,s1
    80003fec:	fffff097          	auipc	ra,0xfffff
    80003ff0:	03c080e7          	jalr	60(ra) # 80003028 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ff4:	2a05                	addiw	s4,s4,1
    80003ff6:	0a91                	addi	s5,s5,4
    80003ff8:	02c9a783          	lw	a5,44(s3)
    80003ffc:	f8fa49e3          	blt	s4,a5,80003f8e <install_trans+0x30>
}
    80004000:	70e2                	ld	ra,56(sp)
    80004002:	7442                	ld	s0,48(sp)
    80004004:	74a2                	ld	s1,40(sp)
    80004006:	7902                	ld	s2,32(sp)
    80004008:	69e2                	ld	s3,24(sp)
    8000400a:	6a42                	ld	s4,16(sp)
    8000400c:	6aa2                	ld	s5,8(sp)
    8000400e:	6121                	addi	sp,sp,64
    80004010:	8082                	ret
    80004012:	8082                	ret

0000000080004014 <initlog>:
{
    80004014:	7179                	addi	sp,sp,-48
    80004016:	f406                	sd	ra,40(sp)
    80004018:	f022                	sd	s0,32(sp)
    8000401a:	ec26                	sd	s1,24(sp)
    8000401c:	e84a                	sd	s2,16(sp)
    8000401e:	e44e                	sd	s3,8(sp)
    80004020:	1800                	addi	s0,sp,48
    80004022:	892a                	mv	s2,a0
    80004024:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004026:	0001e497          	auipc	s1,0x1e
    8000402a:	ee248493          	addi	s1,s1,-286 # 80021f08 <log>
    8000402e:	00004597          	auipc	a1,0x4
    80004032:	5fa58593          	addi	a1,a1,1530 # 80008628 <syscalls+0x1e8>
    80004036:	8526                	mv	a0,s1
    80004038:	ffffd097          	auipc	ra,0xffffd
    8000403c:	bac080e7          	jalr	-1108(ra) # 80000be4 <initlock>
  log.start = sb->logstart;
    80004040:	0149a583          	lw	a1,20(s3)
    80004044:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004046:	0109a783          	lw	a5,16(s3)
    8000404a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000404c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004050:	854a                	mv	a0,s2
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	ea6080e7          	jalr	-346(ra) # 80002ef8 <bread>
  log.lh.n = lh->n;
    8000405a:	4d3c                	lw	a5,88(a0)
    8000405c:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000405e:	02f05563          	blez	a5,80004088 <initlog+0x74>
    80004062:	05c50713          	addi	a4,a0,92
    80004066:	0001e697          	auipc	a3,0x1e
    8000406a:	ed268693          	addi	a3,a3,-302 # 80021f38 <log+0x30>
    8000406e:	37fd                	addiw	a5,a5,-1
    80004070:	1782                	slli	a5,a5,0x20
    80004072:	9381                	srli	a5,a5,0x20
    80004074:	078a                	slli	a5,a5,0x2
    80004076:	06050613          	addi	a2,a0,96
    8000407a:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000407c:	4310                	lw	a2,0(a4)
    8000407e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004080:	0711                	addi	a4,a4,4
    80004082:	0691                	addi	a3,a3,4
    80004084:	fef71ce3          	bne	a4,a5,8000407c <initlog+0x68>
  brelse(buf);
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	fa0080e7          	jalr	-96(ra) # 80003028 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004090:	00000097          	auipc	ra,0x0
    80004094:	ece080e7          	jalr	-306(ra) # 80003f5e <install_trans>
  log.lh.n = 0;
    80004098:	0001e797          	auipc	a5,0x1e
    8000409c:	e807ae23          	sw	zero,-356(a5) # 80021f34 <log+0x2c>
  write_head(); // clear the log
    800040a0:	00000097          	auipc	ra,0x0
    800040a4:	e44080e7          	jalr	-444(ra) # 80003ee4 <write_head>
}
    800040a8:	70a2                	ld	ra,40(sp)
    800040aa:	7402                	ld	s0,32(sp)
    800040ac:	64e2                	ld	s1,24(sp)
    800040ae:	6942                	ld	s2,16(sp)
    800040b0:	69a2                	ld	s3,8(sp)
    800040b2:	6145                	addi	sp,sp,48
    800040b4:	8082                	ret

00000000800040b6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040b6:	1101                	addi	sp,sp,-32
    800040b8:	ec06                	sd	ra,24(sp)
    800040ba:	e822                	sd	s0,16(sp)
    800040bc:	e426                	sd	s1,8(sp)
    800040be:	e04a                	sd	s2,0(sp)
    800040c0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040c2:	0001e517          	auipc	a0,0x1e
    800040c6:	e4650513          	addi	a0,a0,-442 # 80021f08 <log>
    800040ca:	ffffd097          	auipc	ra,0xffffd
    800040ce:	baa080e7          	jalr	-1110(ra) # 80000c74 <acquire>
  while(1){
    if(log.committing){
    800040d2:	0001e497          	auipc	s1,0x1e
    800040d6:	e3648493          	addi	s1,s1,-458 # 80021f08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040da:	4979                	li	s2,30
    800040dc:	a039                	j	800040ea <begin_op+0x34>
      sleep(&log, &log.lock);
    800040de:	85a6                	mv	a1,s1
    800040e0:	8526                	mv	a0,s1
    800040e2:	ffffe097          	auipc	ra,0xffffe
    800040e6:	196080e7          	jalr	406(ra) # 80002278 <sleep>
    if(log.committing){
    800040ea:	50dc                	lw	a5,36(s1)
    800040ec:	fbed                	bnez	a5,800040de <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040ee:	509c                	lw	a5,32(s1)
    800040f0:	0017871b          	addiw	a4,a5,1
    800040f4:	0007069b          	sext.w	a3,a4
    800040f8:	0027179b          	slliw	a5,a4,0x2
    800040fc:	9fb9                	addw	a5,a5,a4
    800040fe:	0017979b          	slliw	a5,a5,0x1
    80004102:	54d8                	lw	a4,44(s1)
    80004104:	9fb9                	addw	a5,a5,a4
    80004106:	00f95963          	bge	s2,a5,80004118 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000410a:	85a6                	mv	a1,s1
    8000410c:	8526                	mv	a0,s1
    8000410e:	ffffe097          	auipc	ra,0xffffe
    80004112:	16a080e7          	jalr	362(ra) # 80002278 <sleep>
    80004116:	bfd1                	j	800040ea <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004118:	0001e517          	auipc	a0,0x1e
    8000411c:	df050513          	addi	a0,a0,-528 # 80021f08 <log>
    80004120:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004122:	ffffd097          	auipc	ra,0xffffd
    80004126:	c06080e7          	jalr	-1018(ra) # 80000d28 <release>
      break;
    }
  }
}
    8000412a:	60e2                	ld	ra,24(sp)
    8000412c:	6442                	ld	s0,16(sp)
    8000412e:	64a2                	ld	s1,8(sp)
    80004130:	6902                	ld	s2,0(sp)
    80004132:	6105                	addi	sp,sp,32
    80004134:	8082                	ret

0000000080004136 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004136:	7139                	addi	sp,sp,-64
    80004138:	fc06                	sd	ra,56(sp)
    8000413a:	f822                	sd	s0,48(sp)
    8000413c:	f426                	sd	s1,40(sp)
    8000413e:	f04a                	sd	s2,32(sp)
    80004140:	ec4e                	sd	s3,24(sp)
    80004142:	e852                	sd	s4,16(sp)
    80004144:	e456                	sd	s5,8(sp)
    80004146:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004148:	0001e497          	auipc	s1,0x1e
    8000414c:	dc048493          	addi	s1,s1,-576 # 80021f08 <log>
    80004150:	8526                	mv	a0,s1
    80004152:	ffffd097          	auipc	ra,0xffffd
    80004156:	b22080e7          	jalr	-1246(ra) # 80000c74 <acquire>
  log.outstanding -= 1;
    8000415a:	509c                	lw	a5,32(s1)
    8000415c:	37fd                	addiw	a5,a5,-1
    8000415e:	0007891b          	sext.w	s2,a5
    80004162:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004164:	50dc                	lw	a5,36(s1)
    80004166:	efb9                	bnez	a5,800041c4 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004168:	06091663          	bnez	s2,800041d4 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000416c:	0001e497          	auipc	s1,0x1e
    80004170:	d9c48493          	addi	s1,s1,-612 # 80021f08 <log>
    80004174:	4785                	li	a5,1
    80004176:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004178:	8526                	mv	a0,s1
    8000417a:	ffffd097          	auipc	ra,0xffffd
    8000417e:	bae080e7          	jalr	-1106(ra) # 80000d28 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004182:	54dc                	lw	a5,44(s1)
    80004184:	06f04763          	bgtz	a5,800041f2 <end_op+0xbc>
    acquire(&log.lock);
    80004188:	0001e497          	auipc	s1,0x1e
    8000418c:	d8048493          	addi	s1,s1,-640 # 80021f08 <log>
    80004190:	8526                	mv	a0,s1
    80004192:	ffffd097          	auipc	ra,0xffffd
    80004196:	ae2080e7          	jalr	-1310(ra) # 80000c74 <acquire>
    log.committing = 0;
    8000419a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000419e:	8526                	mv	a0,s1
    800041a0:	ffffe097          	auipc	ra,0xffffe
    800041a4:	25e080e7          	jalr	606(ra) # 800023fe <wakeup>
    release(&log.lock);
    800041a8:	8526                	mv	a0,s1
    800041aa:	ffffd097          	auipc	ra,0xffffd
    800041ae:	b7e080e7          	jalr	-1154(ra) # 80000d28 <release>
}
    800041b2:	70e2                	ld	ra,56(sp)
    800041b4:	7442                	ld	s0,48(sp)
    800041b6:	74a2                	ld	s1,40(sp)
    800041b8:	7902                	ld	s2,32(sp)
    800041ba:	69e2                	ld	s3,24(sp)
    800041bc:	6a42                	ld	s4,16(sp)
    800041be:	6aa2                	ld	s5,8(sp)
    800041c0:	6121                	addi	sp,sp,64
    800041c2:	8082                	ret
    panic("log.committing");
    800041c4:	00004517          	auipc	a0,0x4
    800041c8:	46c50513          	addi	a0,a0,1132 # 80008630 <syscalls+0x1f0>
    800041cc:	ffffc097          	auipc	ra,0xffffc
    800041d0:	40a080e7          	jalr	1034(ra) # 800005d6 <panic>
    wakeup(&log);
    800041d4:	0001e497          	auipc	s1,0x1e
    800041d8:	d3448493          	addi	s1,s1,-716 # 80021f08 <log>
    800041dc:	8526                	mv	a0,s1
    800041de:	ffffe097          	auipc	ra,0xffffe
    800041e2:	220080e7          	jalr	544(ra) # 800023fe <wakeup>
  release(&log.lock);
    800041e6:	8526                	mv	a0,s1
    800041e8:	ffffd097          	auipc	ra,0xffffd
    800041ec:	b40080e7          	jalr	-1216(ra) # 80000d28 <release>
  if(do_commit){
    800041f0:	b7c9                	j	800041b2 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f2:	0001ea97          	auipc	s5,0x1e
    800041f6:	d46a8a93          	addi	s5,s5,-698 # 80021f38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041fa:	0001ea17          	auipc	s4,0x1e
    800041fe:	d0ea0a13          	addi	s4,s4,-754 # 80021f08 <log>
    80004202:	018a2583          	lw	a1,24(s4)
    80004206:	012585bb          	addw	a1,a1,s2
    8000420a:	2585                	addiw	a1,a1,1
    8000420c:	028a2503          	lw	a0,40(s4)
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	ce8080e7          	jalr	-792(ra) # 80002ef8 <bread>
    80004218:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000421a:	000aa583          	lw	a1,0(s5)
    8000421e:	028a2503          	lw	a0,40(s4)
    80004222:	fffff097          	auipc	ra,0xfffff
    80004226:	cd6080e7          	jalr	-810(ra) # 80002ef8 <bread>
    8000422a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000422c:	40000613          	li	a2,1024
    80004230:	05850593          	addi	a1,a0,88
    80004234:	05848513          	addi	a0,s1,88
    80004238:	ffffd097          	auipc	ra,0xffffd
    8000423c:	b98080e7          	jalr	-1128(ra) # 80000dd0 <memmove>
    bwrite(to);  // write the log
    80004240:	8526                	mv	a0,s1
    80004242:	fffff097          	auipc	ra,0xfffff
    80004246:	da8080e7          	jalr	-600(ra) # 80002fea <bwrite>
    brelse(from);
    8000424a:	854e                	mv	a0,s3
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	ddc080e7          	jalr	-548(ra) # 80003028 <brelse>
    brelse(to);
    80004254:	8526                	mv	a0,s1
    80004256:	fffff097          	auipc	ra,0xfffff
    8000425a:	dd2080e7          	jalr	-558(ra) # 80003028 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425e:	2905                	addiw	s2,s2,1
    80004260:	0a91                	addi	s5,s5,4
    80004262:	02ca2783          	lw	a5,44(s4)
    80004266:	f8f94ee3          	blt	s2,a5,80004202 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000426a:	00000097          	auipc	ra,0x0
    8000426e:	c7a080e7          	jalr	-902(ra) # 80003ee4 <write_head>
    install_trans(); // Now install writes to home locations
    80004272:	00000097          	auipc	ra,0x0
    80004276:	cec080e7          	jalr	-788(ra) # 80003f5e <install_trans>
    log.lh.n = 0;
    8000427a:	0001e797          	auipc	a5,0x1e
    8000427e:	ca07ad23          	sw	zero,-838(a5) # 80021f34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004282:	00000097          	auipc	ra,0x0
    80004286:	c62080e7          	jalr	-926(ra) # 80003ee4 <write_head>
    8000428a:	bdfd                	j	80004188 <end_op+0x52>

000000008000428c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000428c:	1101                	addi	sp,sp,-32
    8000428e:	ec06                	sd	ra,24(sp)
    80004290:	e822                	sd	s0,16(sp)
    80004292:	e426                	sd	s1,8(sp)
    80004294:	e04a                	sd	s2,0(sp)
    80004296:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004298:	0001e717          	auipc	a4,0x1e
    8000429c:	c9c72703          	lw	a4,-868(a4) # 80021f34 <log+0x2c>
    800042a0:	47f5                	li	a5,29
    800042a2:	08e7c063          	blt	a5,a4,80004322 <log_write+0x96>
    800042a6:	84aa                	mv	s1,a0
    800042a8:	0001e797          	auipc	a5,0x1e
    800042ac:	c7c7a783          	lw	a5,-900(a5) # 80021f24 <log+0x1c>
    800042b0:	37fd                	addiw	a5,a5,-1
    800042b2:	06f75863          	bge	a4,a5,80004322 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042b6:	0001e797          	auipc	a5,0x1e
    800042ba:	c727a783          	lw	a5,-910(a5) # 80021f28 <log+0x20>
    800042be:	06f05a63          	blez	a5,80004332 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800042c2:	0001e917          	auipc	s2,0x1e
    800042c6:	c4690913          	addi	s2,s2,-954 # 80021f08 <log>
    800042ca:	854a                	mv	a0,s2
    800042cc:	ffffd097          	auipc	ra,0xffffd
    800042d0:	9a8080e7          	jalr	-1624(ra) # 80000c74 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800042d4:	02c92603          	lw	a2,44(s2)
    800042d8:	06c05563          	blez	a2,80004342 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800042dc:	44cc                	lw	a1,12(s1)
    800042de:	0001e717          	auipc	a4,0x1e
    800042e2:	c5a70713          	addi	a4,a4,-934 # 80021f38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042e6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800042e8:	4314                	lw	a3,0(a4)
    800042ea:	04b68d63          	beq	a3,a1,80004344 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800042ee:	2785                	addiw	a5,a5,1
    800042f0:	0711                	addi	a4,a4,4
    800042f2:	fec79be3          	bne	a5,a2,800042e8 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042f6:	0621                	addi	a2,a2,8
    800042f8:	060a                	slli	a2,a2,0x2
    800042fa:	0001e797          	auipc	a5,0x1e
    800042fe:	c0e78793          	addi	a5,a5,-1010 # 80021f08 <log>
    80004302:	963e                	add	a2,a2,a5
    80004304:	44dc                	lw	a5,12(s1)
    80004306:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004308:	8526                	mv	a0,s1
    8000430a:	fffff097          	auipc	ra,0xfffff
    8000430e:	dbc080e7          	jalr	-580(ra) # 800030c6 <bpin>
    log.lh.n++;
    80004312:	0001e717          	auipc	a4,0x1e
    80004316:	bf670713          	addi	a4,a4,-1034 # 80021f08 <log>
    8000431a:	575c                	lw	a5,44(a4)
    8000431c:	2785                	addiw	a5,a5,1
    8000431e:	d75c                	sw	a5,44(a4)
    80004320:	a83d                	j	8000435e <log_write+0xd2>
    panic("too big a transaction");
    80004322:	00004517          	auipc	a0,0x4
    80004326:	31e50513          	addi	a0,a0,798 # 80008640 <syscalls+0x200>
    8000432a:	ffffc097          	auipc	ra,0xffffc
    8000432e:	2ac080e7          	jalr	684(ra) # 800005d6 <panic>
    panic("log_write outside of trans");
    80004332:	00004517          	auipc	a0,0x4
    80004336:	32650513          	addi	a0,a0,806 # 80008658 <syscalls+0x218>
    8000433a:	ffffc097          	auipc	ra,0xffffc
    8000433e:	29c080e7          	jalr	668(ra) # 800005d6 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004342:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004344:	00878713          	addi	a4,a5,8
    80004348:	00271693          	slli	a3,a4,0x2
    8000434c:	0001e717          	auipc	a4,0x1e
    80004350:	bbc70713          	addi	a4,a4,-1092 # 80021f08 <log>
    80004354:	9736                	add	a4,a4,a3
    80004356:	44d4                	lw	a3,12(s1)
    80004358:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000435a:	faf607e3          	beq	a2,a5,80004308 <log_write+0x7c>
  }
  release(&log.lock);
    8000435e:	0001e517          	auipc	a0,0x1e
    80004362:	baa50513          	addi	a0,a0,-1110 # 80021f08 <log>
    80004366:	ffffd097          	auipc	ra,0xffffd
    8000436a:	9c2080e7          	jalr	-1598(ra) # 80000d28 <release>
}
    8000436e:	60e2                	ld	ra,24(sp)
    80004370:	6442                	ld	s0,16(sp)
    80004372:	64a2                	ld	s1,8(sp)
    80004374:	6902                	ld	s2,0(sp)
    80004376:	6105                	addi	sp,sp,32
    80004378:	8082                	ret

000000008000437a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000437a:	1101                	addi	sp,sp,-32
    8000437c:	ec06                	sd	ra,24(sp)
    8000437e:	e822                	sd	s0,16(sp)
    80004380:	e426                	sd	s1,8(sp)
    80004382:	e04a                	sd	s2,0(sp)
    80004384:	1000                	addi	s0,sp,32
    80004386:	84aa                	mv	s1,a0
    80004388:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000438a:	00004597          	auipc	a1,0x4
    8000438e:	2ee58593          	addi	a1,a1,750 # 80008678 <syscalls+0x238>
    80004392:	0521                	addi	a0,a0,8
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	850080e7          	jalr	-1968(ra) # 80000be4 <initlock>
  lk->name = name;
    8000439c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043a4:	0204a423          	sw	zero,40(s1)
}
    800043a8:	60e2                	ld	ra,24(sp)
    800043aa:	6442                	ld	s0,16(sp)
    800043ac:	64a2                	ld	s1,8(sp)
    800043ae:	6902                	ld	s2,0(sp)
    800043b0:	6105                	addi	sp,sp,32
    800043b2:	8082                	ret

00000000800043b4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043b4:	1101                	addi	sp,sp,-32
    800043b6:	ec06                	sd	ra,24(sp)
    800043b8:	e822                	sd	s0,16(sp)
    800043ba:	e426                	sd	s1,8(sp)
    800043bc:	e04a                	sd	s2,0(sp)
    800043be:	1000                	addi	s0,sp,32
    800043c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043c2:	00850913          	addi	s2,a0,8
    800043c6:	854a                	mv	a0,s2
    800043c8:	ffffd097          	auipc	ra,0xffffd
    800043cc:	8ac080e7          	jalr	-1876(ra) # 80000c74 <acquire>
  while (lk->locked) {
    800043d0:	409c                	lw	a5,0(s1)
    800043d2:	cb89                	beqz	a5,800043e4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043d4:	85ca                	mv	a1,s2
    800043d6:	8526                	mv	a0,s1
    800043d8:	ffffe097          	auipc	ra,0xffffe
    800043dc:	ea0080e7          	jalr	-352(ra) # 80002278 <sleep>
  while (lk->locked) {
    800043e0:	409c                	lw	a5,0(s1)
    800043e2:	fbed                	bnez	a5,800043d4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043e4:	4785                	li	a5,1
    800043e6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043e8:	ffffd097          	auipc	ra,0xffffd
    800043ec:	65a080e7          	jalr	1626(ra) # 80001a42 <myproc>
    800043f0:	5d1c                	lw	a5,56(a0)
    800043f2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043f4:	854a                	mv	a0,s2
    800043f6:	ffffd097          	auipc	ra,0xffffd
    800043fa:	932080e7          	jalr	-1742(ra) # 80000d28 <release>
}
    800043fe:	60e2                	ld	ra,24(sp)
    80004400:	6442                	ld	s0,16(sp)
    80004402:	64a2                	ld	s1,8(sp)
    80004404:	6902                	ld	s2,0(sp)
    80004406:	6105                	addi	sp,sp,32
    80004408:	8082                	ret

000000008000440a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000440a:	1101                	addi	sp,sp,-32
    8000440c:	ec06                	sd	ra,24(sp)
    8000440e:	e822                	sd	s0,16(sp)
    80004410:	e426                	sd	s1,8(sp)
    80004412:	e04a                	sd	s2,0(sp)
    80004414:	1000                	addi	s0,sp,32
    80004416:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004418:	00850913          	addi	s2,a0,8
    8000441c:	854a                	mv	a0,s2
    8000441e:	ffffd097          	auipc	ra,0xffffd
    80004422:	856080e7          	jalr	-1962(ra) # 80000c74 <acquire>
  lk->locked = 0;
    80004426:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000442a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000442e:	8526                	mv	a0,s1
    80004430:	ffffe097          	auipc	ra,0xffffe
    80004434:	fce080e7          	jalr	-50(ra) # 800023fe <wakeup>
  release(&lk->lk);
    80004438:	854a                	mv	a0,s2
    8000443a:	ffffd097          	auipc	ra,0xffffd
    8000443e:	8ee080e7          	jalr	-1810(ra) # 80000d28 <release>
}
    80004442:	60e2                	ld	ra,24(sp)
    80004444:	6442                	ld	s0,16(sp)
    80004446:	64a2                	ld	s1,8(sp)
    80004448:	6902                	ld	s2,0(sp)
    8000444a:	6105                	addi	sp,sp,32
    8000444c:	8082                	ret

000000008000444e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000444e:	7179                	addi	sp,sp,-48
    80004450:	f406                	sd	ra,40(sp)
    80004452:	f022                	sd	s0,32(sp)
    80004454:	ec26                	sd	s1,24(sp)
    80004456:	e84a                	sd	s2,16(sp)
    80004458:	e44e                	sd	s3,8(sp)
    8000445a:	1800                	addi	s0,sp,48
    8000445c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000445e:	00850913          	addi	s2,a0,8
    80004462:	854a                	mv	a0,s2
    80004464:	ffffd097          	auipc	ra,0xffffd
    80004468:	810080e7          	jalr	-2032(ra) # 80000c74 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000446c:	409c                	lw	a5,0(s1)
    8000446e:	ef99                	bnez	a5,8000448c <holdingsleep+0x3e>
    80004470:	4481                	li	s1,0
  release(&lk->lk);
    80004472:	854a                	mv	a0,s2
    80004474:	ffffd097          	auipc	ra,0xffffd
    80004478:	8b4080e7          	jalr	-1868(ra) # 80000d28 <release>
  return r;
}
    8000447c:	8526                	mv	a0,s1
    8000447e:	70a2                	ld	ra,40(sp)
    80004480:	7402                	ld	s0,32(sp)
    80004482:	64e2                	ld	s1,24(sp)
    80004484:	6942                	ld	s2,16(sp)
    80004486:	69a2                	ld	s3,8(sp)
    80004488:	6145                	addi	sp,sp,48
    8000448a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000448c:	0284a983          	lw	s3,40(s1)
    80004490:	ffffd097          	auipc	ra,0xffffd
    80004494:	5b2080e7          	jalr	1458(ra) # 80001a42 <myproc>
    80004498:	5d04                	lw	s1,56(a0)
    8000449a:	413484b3          	sub	s1,s1,s3
    8000449e:	0014b493          	seqz	s1,s1
    800044a2:	bfc1                	j	80004472 <holdingsleep+0x24>

00000000800044a4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044a4:	1141                	addi	sp,sp,-16
    800044a6:	e406                	sd	ra,8(sp)
    800044a8:	e022                	sd	s0,0(sp)
    800044aa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044ac:	00004597          	auipc	a1,0x4
    800044b0:	1dc58593          	addi	a1,a1,476 # 80008688 <syscalls+0x248>
    800044b4:	0001e517          	auipc	a0,0x1e
    800044b8:	b9c50513          	addi	a0,a0,-1124 # 80022050 <ftable>
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	728080e7          	jalr	1832(ra) # 80000be4 <initlock>
}
    800044c4:	60a2                	ld	ra,8(sp)
    800044c6:	6402                	ld	s0,0(sp)
    800044c8:	0141                	addi	sp,sp,16
    800044ca:	8082                	ret

00000000800044cc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044cc:	1101                	addi	sp,sp,-32
    800044ce:	ec06                	sd	ra,24(sp)
    800044d0:	e822                	sd	s0,16(sp)
    800044d2:	e426                	sd	s1,8(sp)
    800044d4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044d6:	0001e517          	auipc	a0,0x1e
    800044da:	b7a50513          	addi	a0,a0,-1158 # 80022050 <ftable>
    800044de:	ffffc097          	auipc	ra,0xffffc
    800044e2:	796080e7          	jalr	1942(ra) # 80000c74 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044e6:	0001e497          	auipc	s1,0x1e
    800044ea:	b8248493          	addi	s1,s1,-1150 # 80022068 <ftable+0x18>
    800044ee:	0001f717          	auipc	a4,0x1f
    800044f2:	b1a70713          	addi	a4,a4,-1254 # 80023008 <ftable+0xfb8>
    if(f->ref == 0){
    800044f6:	40dc                	lw	a5,4(s1)
    800044f8:	cf99                	beqz	a5,80004516 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044fa:	02848493          	addi	s1,s1,40
    800044fe:	fee49ce3          	bne	s1,a4,800044f6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004502:	0001e517          	auipc	a0,0x1e
    80004506:	b4e50513          	addi	a0,a0,-1202 # 80022050 <ftable>
    8000450a:	ffffd097          	auipc	ra,0xffffd
    8000450e:	81e080e7          	jalr	-2018(ra) # 80000d28 <release>
  return 0;
    80004512:	4481                	li	s1,0
    80004514:	a819                	j	8000452a <filealloc+0x5e>
      f->ref = 1;
    80004516:	4785                	li	a5,1
    80004518:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000451a:	0001e517          	auipc	a0,0x1e
    8000451e:	b3650513          	addi	a0,a0,-1226 # 80022050 <ftable>
    80004522:	ffffd097          	auipc	ra,0xffffd
    80004526:	806080e7          	jalr	-2042(ra) # 80000d28 <release>
}
    8000452a:	8526                	mv	a0,s1
    8000452c:	60e2                	ld	ra,24(sp)
    8000452e:	6442                	ld	s0,16(sp)
    80004530:	64a2                	ld	s1,8(sp)
    80004532:	6105                	addi	sp,sp,32
    80004534:	8082                	ret

0000000080004536 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004536:	1101                	addi	sp,sp,-32
    80004538:	ec06                	sd	ra,24(sp)
    8000453a:	e822                	sd	s0,16(sp)
    8000453c:	e426                	sd	s1,8(sp)
    8000453e:	1000                	addi	s0,sp,32
    80004540:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004542:	0001e517          	auipc	a0,0x1e
    80004546:	b0e50513          	addi	a0,a0,-1266 # 80022050 <ftable>
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	72a080e7          	jalr	1834(ra) # 80000c74 <acquire>
  if(f->ref < 1)
    80004552:	40dc                	lw	a5,4(s1)
    80004554:	02f05263          	blez	a5,80004578 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004558:	2785                	addiw	a5,a5,1
    8000455a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000455c:	0001e517          	auipc	a0,0x1e
    80004560:	af450513          	addi	a0,a0,-1292 # 80022050 <ftable>
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	7c4080e7          	jalr	1988(ra) # 80000d28 <release>
  return f;
}
    8000456c:	8526                	mv	a0,s1
    8000456e:	60e2                	ld	ra,24(sp)
    80004570:	6442                	ld	s0,16(sp)
    80004572:	64a2                	ld	s1,8(sp)
    80004574:	6105                	addi	sp,sp,32
    80004576:	8082                	ret
    panic("filedup");
    80004578:	00004517          	auipc	a0,0x4
    8000457c:	11850513          	addi	a0,a0,280 # 80008690 <syscalls+0x250>
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	056080e7          	jalr	86(ra) # 800005d6 <panic>

0000000080004588 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004588:	7139                	addi	sp,sp,-64
    8000458a:	fc06                	sd	ra,56(sp)
    8000458c:	f822                	sd	s0,48(sp)
    8000458e:	f426                	sd	s1,40(sp)
    80004590:	f04a                	sd	s2,32(sp)
    80004592:	ec4e                	sd	s3,24(sp)
    80004594:	e852                	sd	s4,16(sp)
    80004596:	e456                	sd	s5,8(sp)
    80004598:	0080                	addi	s0,sp,64
    8000459a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000459c:	0001e517          	auipc	a0,0x1e
    800045a0:	ab450513          	addi	a0,a0,-1356 # 80022050 <ftable>
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	6d0080e7          	jalr	1744(ra) # 80000c74 <acquire>
  if(f->ref < 1)
    800045ac:	40dc                	lw	a5,4(s1)
    800045ae:	06f05163          	blez	a5,80004610 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045b2:	37fd                	addiw	a5,a5,-1
    800045b4:	0007871b          	sext.w	a4,a5
    800045b8:	c0dc                	sw	a5,4(s1)
    800045ba:	06e04363          	bgtz	a4,80004620 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045be:	0004a903          	lw	s2,0(s1)
    800045c2:	0094ca83          	lbu	s5,9(s1)
    800045c6:	0104ba03          	ld	s4,16(s1)
    800045ca:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045ce:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045d2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045d6:	0001e517          	auipc	a0,0x1e
    800045da:	a7a50513          	addi	a0,a0,-1414 # 80022050 <ftable>
    800045de:	ffffc097          	auipc	ra,0xffffc
    800045e2:	74a080e7          	jalr	1866(ra) # 80000d28 <release>

  if(ff.type == FD_PIPE){
    800045e6:	4785                	li	a5,1
    800045e8:	04f90d63          	beq	s2,a5,80004642 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045ec:	3979                	addiw	s2,s2,-2
    800045ee:	4785                	li	a5,1
    800045f0:	0527e063          	bltu	a5,s2,80004630 <fileclose+0xa8>
    begin_op();
    800045f4:	00000097          	auipc	ra,0x0
    800045f8:	ac2080e7          	jalr	-1342(ra) # 800040b6 <begin_op>
    iput(ff.ip);
    800045fc:	854e                	mv	a0,s3
    800045fe:	fffff097          	auipc	ra,0xfffff
    80004602:	2b6080e7          	jalr	694(ra) # 800038b4 <iput>
    end_op();
    80004606:	00000097          	auipc	ra,0x0
    8000460a:	b30080e7          	jalr	-1232(ra) # 80004136 <end_op>
    8000460e:	a00d                	j	80004630 <fileclose+0xa8>
    panic("fileclose");
    80004610:	00004517          	auipc	a0,0x4
    80004614:	08850513          	addi	a0,a0,136 # 80008698 <syscalls+0x258>
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	fbe080e7          	jalr	-66(ra) # 800005d6 <panic>
    release(&ftable.lock);
    80004620:	0001e517          	auipc	a0,0x1e
    80004624:	a3050513          	addi	a0,a0,-1488 # 80022050 <ftable>
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	700080e7          	jalr	1792(ra) # 80000d28 <release>
  }
}
    80004630:	70e2                	ld	ra,56(sp)
    80004632:	7442                	ld	s0,48(sp)
    80004634:	74a2                	ld	s1,40(sp)
    80004636:	7902                	ld	s2,32(sp)
    80004638:	69e2                	ld	s3,24(sp)
    8000463a:	6a42                	ld	s4,16(sp)
    8000463c:	6aa2                	ld	s5,8(sp)
    8000463e:	6121                	addi	sp,sp,64
    80004640:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004642:	85d6                	mv	a1,s5
    80004644:	8552                	mv	a0,s4
    80004646:	00000097          	auipc	ra,0x0
    8000464a:	372080e7          	jalr	882(ra) # 800049b8 <pipeclose>
    8000464e:	b7cd                	j	80004630 <fileclose+0xa8>

0000000080004650 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004650:	715d                	addi	sp,sp,-80
    80004652:	e486                	sd	ra,72(sp)
    80004654:	e0a2                	sd	s0,64(sp)
    80004656:	fc26                	sd	s1,56(sp)
    80004658:	f84a                	sd	s2,48(sp)
    8000465a:	f44e                	sd	s3,40(sp)
    8000465c:	0880                	addi	s0,sp,80
    8000465e:	84aa                	mv	s1,a0
    80004660:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004662:	ffffd097          	auipc	ra,0xffffd
    80004666:	3e0080e7          	jalr	992(ra) # 80001a42 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000466a:	409c                	lw	a5,0(s1)
    8000466c:	37f9                	addiw	a5,a5,-2
    8000466e:	4705                	li	a4,1
    80004670:	04f76763          	bltu	a4,a5,800046be <filestat+0x6e>
    80004674:	892a                	mv	s2,a0
    ilock(f->ip);
    80004676:	6c88                	ld	a0,24(s1)
    80004678:	fffff097          	auipc	ra,0xfffff
    8000467c:	082080e7          	jalr	130(ra) # 800036fa <ilock>
    stati(f->ip, &st);
    80004680:	fb840593          	addi	a1,s0,-72
    80004684:	6c88                	ld	a0,24(s1)
    80004686:	fffff097          	auipc	ra,0xfffff
    8000468a:	2fe080e7          	jalr	766(ra) # 80003984 <stati>
    iunlock(f->ip);
    8000468e:	6c88                	ld	a0,24(s1)
    80004690:	fffff097          	auipc	ra,0xfffff
    80004694:	12c080e7          	jalr	300(ra) # 800037bc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004698:	46e1                	li	a3,24
    8000469a:	fb840613          	addi	a2,s0,-72
    8000469e:	85ce                	mv	a1,s3
    800046a0:	05093503          	ld	a0,80(s2)
    800046a4:	ffffd097          	auipc	ra,0xffffd
    800046a8:	092080e7          	jalr	146(ra) # 80001736 <copyout>
    800046ac:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046b0:	60a6                	ld	ra,72(sp)
    800046b2:	6406                	ld	s0,64(sp)
    800046b4:	74e2                	ld	s1,56(sp)
    800046b6:	7942                	ld	s2,48(sp)
    800046b8:	79a2                	ld	s3,40(sp)
    800046ba:	6161                	addi	sp,sp,80
    800046bc:	8082                	ret
  return -1;
    800046be:	557d                	li	a0,-1
    800046c0:	bfc5                	j	800046b0 <filestat+0x60>

00000000800046c2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046c2:	7179                	addi	sp,sp,-48
    800046c4:	f406                	sd	ra,40(sp)
    800046c6:	f022                	sd	s0,32(sp)
    800046c8:	ec26                	sd	s1,24(sp)
    800046ca:	e84a                	sd	s2,16(sp)
    800046cc:	e44e                	sd	s3,8(sp)
    800046ce:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046d0:	00854783          	lbu	a5,8(a0)
    800046d4:	c3d5                	beqz	a5,80004778 <fileread+0xb6>
    800046d6:	84aa                	mv	s1,a0
    800046d8:	89ae                	mv	s3,a1
    800046da:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046dc:	411c                	lw	a5,0(a0)
    800046de:	4705                	li	a4,1
    800046e0:	04e78963          	beq	a5,a4,80004732 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046e4:	470d                	li	a4,3
    800046e6:	04e78d63          	beq	a5,a4,80004740 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046ea:	4709                	li	a4,2
    800046ec:	06e79e63          	bne	a5,a4,80004768 <fileread+0xa6>
    ilock(f->ip);
    800046f0:	6d08                	ld	a0,24(a0)
    800046f2:	fffff097          	auipc	ra,0xfffff
    800046f6:	008080e7          	jalr	8(ra) # 800036fa <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046fa:	874a                	mv	a4,s2
    800046fc:	5094                	lw	a3,32(s1)
    800046fe:	864e                	mv	a2,s3
    80004700:	4585                	li	a1,1
    80004702:	6c88                	ld	a0,24(s1)
    80004704:	fffff097          	auipc	ra,0xfffff
    80004708:	2aa080e7          	jalr	682(ra) # 800039ae <readi>
    8000470c:	892a                	mv	s2,a0
    8000470e:	00a05563          	blez	a0,80004718 <fileread+0x56>
      f->off += r;
    80004712:	509c                	lw	a5,32(s1)
    80004714:	9fa9                	addw	a5,a5,a0
    80004716:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004718:	6c88                	ld	a0,24(s1)
    8000471a:	fffff097          	auipc	ra,0xfffff
    8000471e:	0a2080e7          	jalr	162(ra) # 800037bc <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004722:	854a                	mv	a0,s2
    80004724:	70a2                	ld	ra,40(sp)
    80004726:	7402                	ld	s0,32(sp)
    80004728:	64e2                	ld	s1,24(sp)
    8000472a:	6942                	ld	s2,16(sp)
    8000472c:	69a2                	ld	s3,8(sp)
    8000472e:	6145                	addi	sp,sp,48
    80004730:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004732:	6908                	ld	a0,16(a0)
    80004734:	00000097          	auipc	ra,0x0
    80004738:	418080e7          	jalr	1048(ra) # 80004b4c <piperead>
    8000473c:	892a                	mv	s2,a0
    8000473e:	b7d5                	j	80004722 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004740:	02451783          	lh	a5,36(a0)
    80004744:	03079693          	slli	a3,a5,0x30
    80004748:	92c1                	srli	a3,a3,0x30
    8000474a:	4725                	li	a4,9
    8000474c:	02d76863          	bltu	a4,a3,8000477c <fileread+0xba>
    80004750:	0792                	slli	a5,a5,0x4
    80004752:	0001e717          	auipc	a4,0x1e
    80004756:	85e70713          	addi	a4,a4,-1954 # 80021fb0 <devsw>
    8000475a:	97ba                	add	a5,a5,a4
    8000475c:	639c                	ld	a5,0(a5)
    8000475e:	c38d                	beqz	a5,80004780 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004760:	4505                	li	a0,1
    80004762:	9782                	jalr	a5
    80004764:	892a                	mv	s2,a0
    80004766:	bf75                	j	80004722 <fileread+0x60>
    panic("fileread");
    80004768:	00004517          	auipc	a0,0x4
    8000476c:	f4050513          	addi	a0,a0,-192 # 800086a8 <syscalls+0x268>
    80004770:	ffffc097          	auipc	ra,0xffffc
    80004774:	e66080e7          	jalr	-410(ra) # 800005d6 <panic>
    return -1;
    80004778:	597d                	li	s2,-1
    8000477a:	b765                	j	80004722 <fileread+0x60>
      return -1;
    8000477c:	597d                	li	s2,-1
    8000477e:	b755                	j	80004722 <fileread+0x60>
    80004780:	597d                	li	s2,-1
    80004782:	b745                	j	80004722 <fileread+0x60>

0000000080004784 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004784:	00954783          	lbu	a5,9(a0)
    80004788:	14078563          	beqz	a5,800048d2 <filewrite+0x14e>
{
    8000478c:	715d                	addi	sp,sp,-80
    8000478e:	e486                	sd	ra,72(sp)
    80004790:	e0a2                	sd	s0,64(sp)
    80004792:	fc26                	sd	s1,56(sp)
    80004794:	f84a                	sd	s2,48(sp)
    80004796:	f44e                	sd	s3,40(sp)
    80004798:	f052                	sd	s4,32(sp)
    8000479a:	ec56                	sd	s5,24(sp)
    8000479c:	e85a                	sd	s6,16(sp)
    8000479e:	e45e                	sd	s7,8(sp)
    800047a0:	e062                	sd	s8,0(sp)
    800047a2:	0880                	addi	s0,sp,80
    800047a4:	892a                	mv	s2,a0
    800047a6:	8aae                	mv	s5,a1
    800047a8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047aa:	411c                	lw	a5,0(a0)
    800047ac:	4705                	li	a4,1
    800047ae:	02e78263          	beq	a5,a4,800047d2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047b2:	470d                	li	a4,3
    800047b4:	02e78563          	beq	a5,a4,800047de <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047b8:	4709                	li	a4,2
    800047ba:	10e79463          	bne	a5,a4,800048c2 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047be:	0ec05e63          	blez	a2,800048ba <filewrite+0x136>
    int i = 0;
    800047c2:	4981                	li	s3,0
    800047c4:	6b05                	lui	s6,0x1
    800047c6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800047ca:	6b85                	lui	s7,0x1
    800047cc:	c00b8b9b          	addiw	s7,s7,-1024
    800047d0:	a851                	j	80004864 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800047d2:	6908                	ld	a0,16(a0)
    800047d4:	00000097          	auipc	ra,0x0
    800047d8:	254080e7          	jalr	596(ra) # 80004a28 <pipewrite>
    800047dc:	a85d                	j	80004892 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047de:	02451783          	lh	a5,36(a0)
    800047e2:	03079693          	slli	a3,a5,0x30
    800047e6:	92c1                	srli	a3,a3,0x30
    800047e8:	4725                	li	a4,9
    800047ea:	0ed76663          	bltu	a4,a3,800048d6 <filewrite+0x152>
    800047ee:	0792                	slli	a5,a5,0x4
    800047f0:	0001d717          	auipc	a4,0x1d
    800047f4:	7c070713          	addi	a4,a4,1984 # 80021fb0 <devsw>
    800047f8:	97ba                	add	a5,a5,a4
    800047fa:	679c                	ld	a5,8(a5)
    800047fc:	cff9                	beqz	a5,800048da <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    800047fe:	4505                	li	a0,1
    80004800:	9782                	jalr	a5
    80004802:	a841                	j	80004892 <filewrite+0x10e>
    80004804:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004808:	00000097          	auipc	ra,0x0
    8000480c:	8ae080e7          	jalr	-1874(ra) # 800040b6 <begin_op>
      ilock(f->ip);
    80004810:	01893503          	ld	a0,24(s2)
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	ee6080e7          	jalr	-282(ra) # 800036fa <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000481c:	8762                	mv	a4,s8
    8000481e:	02092683          	lw	a3,32(s2)
    80004822:	01598633          	add	a2,s3,s5
    80004826:	4585                	li	a1,1
    80004828:	01893503          	ld	a0,24(s2)
    8000482c:	fffff097          	auipc	ra,0xfffff
    80004830:	278080e7          	jalr	632(ra) # 80003aa4 <writei>
    80004834:	84aa                	mv	s1,a0
    80004836:	02a05f63          	blez	a0,80004874 <filewrite+0xf0>
        f->off += r;
    8000483a:	02092783          	lw	a5,32(s2)
    8000483e:	9fa9                	addw	a5,a5,a0
    80004840:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004844:	01893503          	ld	a0,24(s2)
    80004848:	fffff097          	auipc	ra,0xfffff
    8000484c:	f74080e7          	jalr	-140(ra) # 800037bc <iunlock>
      end_op();
    80004850:	00000097          	auipc	ra,0x0
    80004854:	8e6080e7          	jalr	-1818(ra) # 80004136 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004858:	049c1963          	bne	s8,s1,800048aa <filewrite+0x126>
        panic("short filewrite");
      i += r;
    8000485c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004860:	0349d663          	bge	s3,s4,8000488c <filewrite+0x108>
      int n1 = n - i;
    80004864:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004868:	84be                	mv	s1,a5
    8000486a:	2781                	sext.w	a5,a5
    8000486c:	f8fb5ce3          	bge	s6,a5,80004804 <filewrite+0x80>
    80004870:	84de                	mv	s1,s7
    80004872:	bf49                	j	80004804 <filewrite+0x80>
      iunlock(f->ip);
    80004874:	01893503          	ld	a0,24(s2)
    80004878:	fffff097          	auipc	ra,0xfffff
    8000487c:	f44080e7          	jalr	-188(ra) # 800037bc <iunlock>
      end_op();
    80004880:	00000097          	auipc	ra,0x0
    80004884:	8b6080e7          	jalr	-1866(ra) # 80004136 <end_op>
      if(r < 0)
    80004888:	fc04d8e3          	bgez	s1,80004858 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    8000488c:	8552                	mv	a0,s4
    8000488e:	033a1863          	bne	s4,s3,800048be <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004892:	60a6                	ld	ra,72(sp)
    80004894:	6406                	ld	s0,64(sp)
    80004896:	74e2                	ld	s1,56(sp)
    80004898:	7942                	ld	s2,48(sp)
    8000489a:	79a2                	ld	s3,40(sp)
    8000489c:	7a02                	ld	s4,32(sp)
    8000489e:	6ae2                	ld	s5,24(sp)
    800048a0:	6b42                	ld	s6,16(sp)
    800048a2:	6ba2                	ld	s7,8(sp)
    800048a4:	6c02                	ld	s8,0(sp)
    800048a6:	6161                	addi	sp,sp,80
    800048a8:	8082                	ret
        panic("short filewrite");
    800048aa:	00004517          	auipc	a0,0x4
    800048ae:	e0e50513          	addi	a0,a0,-498 # 800086b8 <syscalls+0x278>
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	d24080e7          	jalr	-732(ra) # 800005d6 <panic>
    int i = 0;
    800048ba:	4981                	li	s3,0
    800048bc:	bfc1                	j	8000488c <filewrite+0x108>
    ret = (i == n ? n : -1);
    800048be:	557d                	li	a0,-1
    800048c0:	bfc9                	j	80004892 <filewrite+0x10e>
    panic("filewrite");
    800048c2:	00004517          	auipc	a0,0x4
    800048c6:	e0650513          	addi	a0,a0,-506 # 800086c8 <syscalls+0x288>
    800048ca:	ffffc097          	auipc	ra,0xffffc
    800048ce:	d0c080e7          	jalr	-756(ra) # 800005d6 <panic>
    return -1;
    800048d2:	557d                	li	a0,-1
}
    800048d4:	8082                	ret
      return -1;
    800048d6:	557d                	li	a0,-1
    800048d8:	bf6d                	j	80004892 <filewrite+0x10e>
    800048da:	557d                	li	a0,-1
    800048dc:	bf5d                	j	80004892 <filewrite+0x10e>

00000000800048de <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048de:	7179                	addi	sp,sp,-48
    800048e0:	f406                	sd	ra,40(sp)
    800048e2:	f022                	sd	s0,32(sp)
    800048e4:	ec26                	sd	s1,24(sp)
    800048e6:	e84a                	sd	s2,16(sp)
    800048e8:	e44e                	sd	s3,8(sp)
    800048ea:	e052                	sd	s4,0(sp)
    800048ec:	1800                	addi	s0,sp,48
    800048ee:	84aa                	mv	s1,a0
    800048f0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048f2:	0005b023          	sd	zero,0(a1)
    800048f6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048fa:	00000097          	auipc	ra,0x0
    800048fe:	bd2080e7          	jalr	-1070(ra) # 800044cc <filealloc>
    80004902:	e088                	sd	a0,0(s1)
    80004904:	c551                	beqz	a0,80004990 <pipealloc+0xb2>
    80004906:	00000097          	auipc	ra,0x0
    8000490a:	bc6080e7          	jalr	-1082(ra) # 800044cc <filealloc>
    8000490e:	00aa3023          	sd	a0,0(s4)
    80004912:	c92d                	beqz	a0,80004984 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004914:	ffffc097          	auipc	ra,0xffffc
    80004918:	270080e7          	jalr	624(ra) # 80000b84 <kalloc>
    8000491c:	892a                	mv	s2,a0
    8000491e:	c125                	beqz	a0,8000497e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004920:	4985                	li	s3,1
    80004922:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004926:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000492a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000492e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004932:	00004597          	auipc	a1,0x4
    80004936:	da658593          	addi	a1,a1,-602 # 800086d8 <syscalls+0x298>
    8000493a:	ffffc097          	auipc	ra,0xffffc
    8000493e:	2aa080e7          	jalr	682(ra) # 80000be4 <initlock>
  (*f0)->type = FD_PIPE;
    80004942:	609c                	ld	a5,0(s1)
    80004944:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004948:	609c                	ld	a5,0(s1)
    8000494a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000494e:	609c                	ld	a5,0(s1)
    80004950:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004954:	609c                	ld	a5,0(s1)
    80004956:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000495a:	000a3783          	ld	a5,0(s4)
    8000495e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004962:	000a3783          	ld	a5,0(s4)
    80004966:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000496a:	000a3783          	ld	a5,0(s4)
    8000496e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004972:	000a3783          	ld	a5,0(s4)
    80004976:	0127b823          	sd	s2,16(a5)
  return 0;
    8000497a:	4501                	li	a0,0
    8000497c:	a025                	j	800049a4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000497e:	6088                	ld	a0,0(s1)
    80004980:	e501                	bnez	a0,80004988 <pipealloc+0xaa>
    80004982:	a039                	j	80004990 <pipealloc+0xb2>
    80004984:	6088                	ld	a0,0(s1)
    80004986:	c51d                	beqz	a0,800049b4 <pipealloc+0xd6>
    fileclose(*f0);
    80004988:	00000097          	auipc	ra,0x0
    8000498c:	c00080e7          	jalr	-1024(ra) # 80004588 <fileclose>
  if(*f1)
    80004990:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004994:	557d                	li	a0,-1
  if(*f1)
    80004996:	c799                	beqz	a5,800049a4 <pipealloc+0xc6>
    fileclose(*f1);
    80004998:	853e                	mv	a0,a5
    8000499a:	00000097          	auipc	ra,0x0
    8000499e:	bee080e7          	jalr	-1042(ra) # 80004588 <fileclose>
  return -1;
    800049a2:	557d                	li	a0,-1
}
    800049a4:	70a2                	ld	ra,40(sp)
    800049a6:	7402                	ld	s0,32(sp)
    800049a8:	64e2                	ld	s1,24(sp)
    800049aa:	6942                	ld	s2,16(sp)
    800049ac:	69a2                	ld	s3,8(sp)
    800049ae:	6a02                	ld	s4,0(sp)
    800049b0:	6145                	addi	sp,sp,48
    800049b2:	8082                	ret
  return -1;
    800049b4:	557d                	li	a0,-1
    800049b6:	b7fd                	j	800049a4 <pipealloc+0xc6>

00000000800049b8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049b8:	1101                	addi	sp,sp,-32
    800049ba:	ec06                	sd	ra,24(sp)
    800049bc:	e822                	sd	s0,16(sp)
    800049be:	e426                	sd	s1,8(sp)
    800049c0:	e04a                	sd	s2,0(sp)
    800049c2:	1000                	addi	s0,sp,32
    800049c4:	84aa                	mv	s1,a0
    800049c6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	2ac080e7          	jalr	684(ra) # 80000c74 <acquire>
  if(writable){
    800049d0:	02090d63          	beqz	s2,80004a0a <pipeclose+0x52>
    pi->writeopen = 0;
    800049d4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049d8:	21848513          	addi	a0,s1,536
    800049dc:	ffffe097          	auipc	ra,0xffffe
    800049e0:	a22080e7          	jalr	-1502(ra) # 800023fe <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049e4:	2204b783          	ld	a5,544(s1)
    800049e8:	eb95                	bnez	a5,80004a1c <pipeclose+0x64>
    release(&pi->lock);
    800049ea:	8526                	mv	a0,s1
    800049ec:	ffffc097          	auipc	ra,0xffffc
    800049f0:	33c080e7          	jalr	828(ra) # 80000d28 <release>
    kfree((char*)pi);
    800049f4:	8526                	mv	a0,s1
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	092080e7          	jalr	146(ra) # 80000a88 <kfree>
  } else
    release(&pi->lock);
}
    800049fe:	60e2                	ld	ra,24(sp)
    80004a00:	6442                	ld	s0,16(sp)
    80004a02:	64a2                	ld	s1,8(sp)
    80004a04:	6902                	ld	s2,0(sp)
    80004a06:	6105                	addi	sp,sp,32
    80004a08:	8082                	ret
    pi->readopen = 0;
    80004a0a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a0e:	21c48513          	addi	a0,s1,540
    80004a12:	ffffe097          	auipc	ra,0xffffe
    80004a16:	9ec080e7          	jalr	-1556(ra) # 800023fe <wakeup>
    80004a1a:	b7e9                	j	800049e4 <pipeclose+0x2c>
    release(&pi->lock);
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffc097          	auipc	ra,0xffffc
    80004a22:	30a080e7          	jalr	778(ra) # 80000d28 <release>
}
    80004a26:	bfe1                	j	800049fe <pipeclose+0x46>

0000000080004a28 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a28:	7119                	addi	sp,sp,-128
    80004a2a:	fc86                	sd	ra,120(sp)
    80004a2c:	f8a2                	sd	s0,112(sp)
    80004a2e:	f4a6                	sd	s1,104(sp)
    80004a30:	f0ca                	sd	s2,96(sp)
    80004a32:	ecce                	sd	s3,88(sp)
    80004a34:	e8d2                	sd	s4,80(sp)
    80004a36:	e4d6                	sd	s5,72(sp)
    80004a38:	e0da                	sd	s6,64(sp)
    80004a3a:	fc5e                	sd	s7,56(sp)
    80004a3c:	f862                	sd	s8,48(sp)
    80004a3e:	f466                	sd	s9,40(sp)
    80004a40:	f06a                	sd	s10,32(sp)
    80004a42:	ec6e                	sd	s11,24(sp)
    80004a44:	0100                	addi	s0,sp,128
    80004a46:	84aa                	mv	s1,a0
    80004a48:	8cae                	mv	s9,a1
    80004a4a:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004a4c:	ffffd097          	auipc	ra,0xffffd
    80004a50:	ff6080e7          	jalr	-10(ra) # 80001a42 <myproc>
    80004a54:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004a56:	8526                	mv	a0,s1
    80004a58:	ffffc097          	auipc	ra,0xffffc
    80004a5c:	21c080e7          	jalr	540(ra) # 80000c74 <acquire>
  for(i = 0; i < n; i++){
    80004a60:	0d605963          	blez	s6,80004b32 <pipewrite+0x10a>
    80004a64:	89a6                	mv	s3,s1
    80004a66:	3b7d                	addiw	s6,s6,-1
    80004a68:	1b02                	slli	s6,s6,0x20
    80004a6a:	020b5b13          	srli	s6,s6,0x20
    80004a6e:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004a70:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a74:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a78:	5dfd                	li	s11,-1
    80004a7a:	000b8d1b          	sext.w	s10,s7
    80004a7e:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a80:	2184a783          	lw	a5,536(s1)
    80004a84:	21c4a703          	lw	a4,540(s1)
    80004a88:	2007879b          	addiw	a5,a5,512
    80004a8c:	02f71b63          	bne	a4,a5,80004ac2 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004a90:	2204a783          	lw	a5,544(s1)
    80004a94:	cbad                	beqz	a5,80004b06 <pipewrite+0xde>
    80004a96:	03092783          	lw	a5,48(s2)
    80004a9a:	e7b5                	bnez	a5,80004b06 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004a9c:	8556                	mv	a0,s5
    80004a9e:	ffffe097          	auipc	ra,0xffffe
    80004aa2:	960080e7          	jalr	-1696(ra) # 800023fe <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004aa6:	85ce                	mv	a1,s3
    80004aa8:	8552                	mv	a0,s4
    80004aaa:	ffffd097          	auipc	ra,0xffffd
    80004aae:	7ce080e7          	jalr	1998(ra) # 80002278 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ab2:	2184a783          	lw	a5,536(s1)
    80004ab6:	21c4a703          	lw	a4,540(s1)
    80004aba:	2007879b          	addiw	a5,a5,512
    80004abe:	fcf709e3          	beq	a4,a5,80004a90 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ac2:	4685                	li	a3,1
    80004ac4:	019b8633          	add	a2,s7,s9
    80004ac8:	f8f40593          	addi	a1,s0,-113
    80004acc:	05093503          	ld	a0,80(s2)
    80004ad0:	ffffd097          	auipc	ra,0xffffd
    80004ad4:	cf2080e7          	jalr	-782(ra) # 800017c2 <copyin>
    80004ad8:	05b50e63          	beq	a0,s11,80004b34 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004adc:	21c4a783          	lw	a5,540(s1)
    80004ae0:	0017871b          	addiw	a4,a5,1
    80004ae4:	20e4ae23          	sw	a4,540(s1)
    80004ae8:	1ff7f793          	andi	a5,a5,511
    80004aec:	97a6                	add	a5,a5,s1
    80004aee:	f8f44703          	lbu	a4,-113(s0)
    80004af2:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004af6:	001d0c1b          	addiw	s8,s10,1
    80004afa:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004afe:	036b8b63          	beq	s7,s6,80004b34 <pipewrite+0x10c>
    80004b02:	8bbe                	mv	s7,a5
    80004b04:	bf9d                	j	80004a7a <pipewrite+0x52>
        release(&pi->lock);
    80004b06:	8526                	mv	a0,s1
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	220080e7          	jalr	544(ra) # 80000d28 <release>
        return -1;
    80004b10:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004b12:	8562                	mv	a0,s8
    80004b14:	70e6                	ld	ra,120(sp)
    80004b16:	7446                	ld	s0,112(sp)
    80004b18:	74a6                	ld	s1,104(sp)
    80004b1a:	7906                	ld	s2,96(sp)
    80004b1c:	69e6                	ld	s3,88(sp)
    80004b1e:	6a46                	ld	s4,80(sp)
    80004b20:	6aa6                	ld	s5,72(sp)
    80004b22:	6b06                	ld	s6,64(sp)
    80004b24:	7be2                	ld	s7,56(sp)
    80004b26:	7c42                	ld	s8,48(sp)
    80004b28:	7ca2                	ld	s9,40(sp)
    80004b2a:	7d02                	ld	s10,32(sp)
    80004b2c:	6de2                	ld	s11,24(sp)
    80004b2e:	6109                	addi	sp,sp,128
    80004b30:	8082                	ret
  for(i = 0; i < n; i++){
    80004b32:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004b34:	21848513          	addi	a0,s1,536
    80004b38:	ffffe097          	auipc	ra,0xffffe
    80004b3c:	8c6080e7          	jalr	-1850(ra) # 800023fe <wakeup>
  release(&pi->lock);
    80004b40:	8526                	mv	a0,s1
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	1e6080e7          	jalr	486(ra) # 80000d28 <release>
  return i;
    80004b4a:	b7e1                	j	80004b12 <pipewrite+0xea>

0000000080004b4c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b4c:	715d                	addi	sp,sp,-80
    80004b4e:	e486                	sd	ra,72(sp)
    80004b50:	e0a2                	sd	s0,64(sp)
    80004b52:	fc26                	sd	s1,56(sp)
    80004b54:	f84a                	sd	s2,48(sp)
    80004b56:	f44e                	sd	s3,40(sp)
    80004b58:	f052                	sd	s4,32(sp)
    80004b5a:	ec56                	sd	s5,24(sp)
    80004b5c:	e85a                	sd	s6,16(sp)
    80004b5e:	0880                	addi	s0,sp,80
    80004b60:	84aa                	mv	s1,a0
    80004b62:	892e                	mv	s2,a1
    80004b64:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b66:	ffffd097          	auipc	ra,0xffffd
    80004b6a:	edc080e7          	jalr	-292(ra) # 80001a42 <myproc>
    80004b6e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b70:	8b26                	mv	s6,s1
    80004b72:	8526                	mv	a0,s1
    80004b74:	ffffc097          	auipc	ra,0xffffc
    80004b78:	100080e7          	jalr	256(ra) # 80000c74 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b7c:	2184a703          	lw	a4,536(s1)
    80004b80:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b84:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b88:	02f71463          	bne	a4,a5,80004bb0 <piperead+0x64>
    80004b8c:	2244a783          	lw	a5,548(s1)
    80004b90:	c385                	beqz	a5,80004bb0 <piperead+0x64>
    if(pr->killed){
    80004b92:	030a2783          	lw	a5,48(s4)
    80004b96:	ebc1                	bnez	a5,80004c26 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b98:	85da                	mv	a1,s6
    80004b9a:	854e                	mv	a0,s3
    80004b9c:	ffffd097          	auipc	ra,0xffffd
    80004ba0:	6dc080e7          	jalr	1756(ra) # 80002278 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ba4:	2184a703          	lw	a4,536(s1)
    80004ba8:	21c4a783          	lw	a5,540(s1)
    80004bac:	fef700e3          	beq	a4,a5,80004b8c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bb0:	09505263          	blez	s5,80004c34 <piperead+0xe8>
    80004bb4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bb6:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004bb8:	2184a783          	lw	a5,536(s1)
    80004bbc:	21c4a703          	lw	a4,540(s1)
    80004bc0:	02f70d63          	beq	a4,a5,80004bfa <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bc4:	0017871b          	addiw	a4,a5,1
    80004bc8:	20e4ac23          	sw	a4,536(s1)
    80004bcc:	1ff7f793          	andi	a5,a5,511
    80004bd0:	97a6                	add	a5,a5,s1
    80004bd2:	0187c783          	lbu	a5,24(a5)
    80004bd6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bda:	4685                	li	a3,1
    80004bdc:	fbf40613          	addi	a2,s0,-65
    80004be0:	85ca                	mv	a1,s2
    80004be2:	050a3503          	ld	a0,80(s4)
    80004be6:	ffffd097          	auipc	ra,0xffffd
    80004bea:	b50080e7          	jalr	-1200(ra) # 80001736 <copyout>
    80004bee:	01650663          	beq	a0,s6,80004bfa <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bf2:	2985                	addiw	s3,s3,1
    80004bf4:	0905                	addi	s2,s2,1
    80004bf6:	fd3a91e3          	bne	s5,s3,80004bb8 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bfa:	21c48513          	addi	a0,s1,540
    80004bfe:	ffffe097          	auipc	ra,0xffffe
    80004c02:	800080e7          	jalr	-2048(ra) # 800023fe <wakeup>
  release(&pi->lock);
    80004c06:	8526                	mv	a0,s1
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	120080e7          	jalr	288(ra) # 80000d28 <release>
  return i;
}
    80004c10:	854e                	mv	a0,s3
    80004c12:	60a6                	ld	ra,72(sp)
    80004c14:	6406                	ld	s0,64(sp)
    80004c16:	74e2                	ld	s1,56(sp)
    80004c18:	7942                	ld	s2,48(sp)
    80004c1a:	79a2                	ld	s3,40(sp)
    80004c1c:	7a02                	ld	s4,32(sp)
    80004c1e:	6ae2                	ld	s5,24(sp)
    80004c20:	6b42                	ld	s6,16(sp)
    80004c22:	6161                	addi	sp,sp,80
    80004c24:	8082                	ret
      release(&pi->lock);
    80004c26:	8526                	mv	a0,s1
    80004c28:	ffffc097          	auipc	ra,0xffffc
    80004c2c:	100080e7          	jalr	256(ra) # 80000d28 <release>
      return -1;
    80004c30:	59fd                	li	s3,-1
    80004c32:	bff9                	j	80004c10 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c34:	4981                	li	s3,0
    80004c36:	b7d1                	j	80004bfa <piperead+0xae>

0000000080004c38 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c38:	df010113          	addi	sp,sp,-528
    80004c3c:	20113423          	sd	ra,520(sp)
    80004c40:	20813023          	sd	s0,512(sp)
    80004c44:	ffa6                	sd	s1,504(sp)
    80004c46:	fbca                	sd	s2,496(sp)
    80004c48:	f7ce                	sd	s3,488(sp)
    80004c4a:	f3d2                	sd	s4,480(sp)
    80004c4c:	efd6                	sd	s5,472(sp)
    80004c4e:	ebda                	sd	s6,464(sp)
    80004c50:	e7de                	sd	s7,456(sp)
    80004c52:	e3e2                	sd	s8,448(sp)
    80004c54:	ff66                	sd	s9,440(sp)
    80004c56:	fb6a                	sd	s10,432(sp)
    80004c58:	f76e                	sd	s11,424(sp)
    80004c5a:	0c00                	addi	s0,sp,528
    80004c5c:	84aa                	mv	s1,a0
    80004c5e:	dea43c23          	sd	a0,-520(s0)
    80004c62:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c66:	ffffd097          	auipc	ra,0xffffd
    80004c6a:	ddc080e7          	jalr	-548(ra) # 80001a42 <myproc>
    80004c6e:	892a                	mv	s2,a0

  begin_op();
    80004c70:	fffff097          	auipc	ra,0xfffff
    80004c74:	446080e7          	jalr	1094(ra) # 800040b6 <begin_op>

  if((ip = namei(path)) == 0){
    80004c78:	8526                	mv	a0,s1
    80004c7a:	fffff097          	auipc	ra,0xfffff
    80004c7e:	230080e7          	jalr	560(ra) # 80003eaa <namei>
    80004c82:	c92d                	beqz	a0,80004cf4 <exec+0xbc>
    80004c84:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c86:	fffff097          	auipc	ra,0xfffff
    80004c8a:	a74080e7          	jalr	-1420(ra) # 800036fa <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c8e:	04000713          	li	a4,64
    80004c92:	4681                	li	a3,0
    80004c94:	e4840613          	addi	a2,s0,-440
    80004c98:	4581                	li	a1,0
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	fffff097          	auipc	ra,0xfffff
    80004ca0:	d12080e7          	jalr	-750(ra) # 800039ae <readi>
    80004ca4:	04000793          	li	a5,64
    80004ca8:	00f51a63          	bne	a0,a5,80004cbc <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004cac:	e4842703          	lw	a4,-440(s0)
    80004cb0:	464c47b7          	lui	a5,0x464c4
    80004cb4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cb8:	04f70463          	beq	a4,a5,80004d00 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cbc:	8526                	mv	a0,s1
    80004cbe:	fffff097          	auipc	ra,0xfffff
    80004cc2:	c9e080e7          	jalr	-866(ra) # 8000395c <iunlockput>
    end_op();
    80004cc6:	fffff097          	auipc	ra,0xfffff
    80004cca:	470080e7          	jalr	1136(ra) # 80004136 <end_op>
  }
  return -1;
    80004cce:	557d                	li	a0,-1
}
    80004cd0:	20813083          	ld	ra,520(sp)
    80004cd4:	20013403          	ld	s0,512(sp)
    80004cd8:	74fe                	ld	s1,504(sp)
    80004cda:	795e                	ld	s2,496(sp)
    80004cdc:	79be                	ld	s3,488(sp)
    80004cde:	7a1e                	ld	s4,480(sp)
    80004ce0:	6afe                	ld	s5,472(sp)
    80004ce2:	6b5e                	ld	s6,464(sp)
    80004ce4:	6bbe                	ld	s7,456(sp)
    80004ce6:	6c1e                	ld	s8,448(sp)
    80004ce8:	7cfa                	ld	s9,440(sp)
    80004cea:	7d5a                	ld	s10,432(sp)
    80004cec:	7dba                	ld	s11,424(sp)
    80004cee:	21010113          	addi	sp,sp,528
    80004cf2:	8082                	ret
    end_op();
    80004cf4:	fffff097          	auipc	ra,0xfffff
    80004cf8:	442080e7          	jalr	1090(ra) # 80004136 <end_op>
    return -1;
    80004cfc:	557d                	li	a0,-1
    80004cfe:	bfc9                	j	80004cd0 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d00:	854a                	mv	a0,s2
    80004d02:	ffffd097          	auipc	ra,0xffffd
    80004d06:	e04080e7          	jalr	-508(ra) # 80001b06 <proc_pagetable>
    80004d0a:	8baa                	mv	s7,a0
    80004d0c:	d945                	beqz	a0,80004cbc <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d0e:	e6842983          	lw	s3,-408(s0)
    80004d12:	e8045783          	lhu	a5,-384(s0)
    80004d16:	c7ad                	beqz	a5,80004d80 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d18:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d1a:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004d1c:	6c85                	lui	s9,0x1
    80004d1e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d22:	def43823          	sd	a5,-528(s0)
    80004d26:	a42d                	j	80004f50 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d28:	00004517          	auipc	a0,0x4
    80004d2c:	9b850513          	addi	a0,a0,-1608 # 800086e0 <syscalls+0x2a0>
    80004d30:	ffffc097          	auipc	ra,0xffffc
    80004d34:	8a6080e7          	jalr	-1882(ra) # 800005d6 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d38:	8756                	mv	a4,s5
    80004d3a:	012d86bb          	addw	a3,s11,s2
    80004d3e:	4581                	li	a1,0
    80004d40:	8526                	mv	a0,s1
    80004d42:	fffff097          	auipc	ra,0xfffff
    80004d46:	c6c080e7          	jalr	-916(ra) # 800039ae <readi>
    80004d4a:	2501                	sext.w	a0,a0
    80004d4c:	1aaa9963          	bne	s5,a0,80004efe <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004d50:	6785                	lui	a5,0x1
    80004d52:	0127893b          	addw	s2,a5,s2
    80004d56:	77fd                	lui	a5,0xfffff
    80004d58:	01478a3b          	addw	s4,a5,s4
    80004d5c:	1f897163          	bgeu	s2,s8,80004f3e <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004d60:	02091593          	slli	a1,s2,0x20
    80004d64:	9181                	srli	a1,a1,0x20
    80004d66:	95ea                	add	a1,a1,s10
    80004d68:	855e                	mv	a0,s7
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	398080e7          	jalr	920(ra) # 80001102 <walkaddr>
    80004d72:	862a                	mv	a2,a0
    if(pa == 0)
    80004d74:	d955                	beqz	a0,80004d28 <exec+0xf0>
      n = PGSIZE;
    80004d76:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004d78:	fd9a70e3          	bgeu	s4,s9,80004d38 <exec+0x100>
      n = sz - i;
    80004d7c:	8ad2                	mv	s5,s4
    80004d7e:	bf6d                	j	80004d38 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d80:	4901                	li	s2,0
  iunlockput(ip);
    80004d82:	8526                	mv	a0,s1
    80004d84:	fffff097          	auipc	ra,0xfffff
    80004d88:	bd8080e7          	jalr	-1064(ra) # 8000395c <iunlockput>
  end_op();
    80004d8c:	fffff097          	auipc	ra,0xfffff
    80004d90:	3aa080e7          	jalr	938(ra) # 80004136 <end_op>
  p = myproc();
    80004d94:	ffffd097          	auipc	ra,0xffffd
    80004d98:	cae080e7          	jalr	-850(ra) # 80001a42 <myproc>
    80004d9c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d9e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004da2:	6785                	lui	a5,0x1
    80004da4:	17fd                	addi	a5,a5,-1
    80004da6:	993e                	add	s2,s2,a5
    80004da8:	757d                	lui	a0,0xfffff
    80004daa:	00a977b3          	and	a5,s2,a0
    80004dae:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004db2:	6609                	lui	a2,0x2
    80004db4:	963e                	add	a2,a2,a5
    80004db6:	85be                	mv	a1,a5
    80004db8:	855e                	mv	a0,s7
    80004dba:	ffffc097          	auipc	ra,0xffffc
    80004dbe:	72c080e7          	jalr	1836(ra) # 800014e6 <uvmalloc>
    80004dc2:	8b2a                	mv	s6,a0
  ip = 0;
    80004dc4:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dc6:	12050c63          	beqz	a0,80004efe <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004dca:	75f9                	lui	a1,0xffffe
    80004dcc:	95aa                	add	a1,a1,a0
    80004dce:	855e                	mv	a0,s7
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	934080e7          	jalr	-1740(ra) # 80001704 <uvmclear>
  stackbase = sp - PGSIZE;
    80004dd8:	7c7d                	lui	s8,0xfffff
    80004dda:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004ddc:	e0043783          	ld	a5,-512(s0)
    80004de0:	6388                	ld	a0,0(a5)
    80004de2:	c535                	beqz	a0,80004e4e <exec+0x216>
    80004de4:	e8840993          	addi	s3,s0,-376
    80004de8:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004dec:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	10a080e7          	jalr	266(ra) # 80000ef8 <strlen>
    80004df6:	2505                	addiw	a0,a0,1
    80004df8:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dfc:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e00:	13896363          	bltu	s2,s8,80004f26 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e04:	e0043d83          	ld	s11,-512(s0)
    80004e08:	000dba03          	ld	s4,0(s11)
    80004e0c:	8552                	mv	a0,s4
    80004e0e:	ffffc097          	auipc	ra,0xffffc
    80004e12:	0ea080e7          	jalr	234(ra) # 80000ef8 <strlen>
    80004e16:	0015069b          	addiw	a3,a0,1
    80004e1a:	8652                	mv	a2,s4
    80004e1c:	85ca                	mv	a1,s2
    80004e1e:	855e                	mv	a0,s7
    80004e20:	ffffd097          	auipc	ra,0xffffd
    80004e24:	916080e7          	jalr	-1770(ra) # 80001736 <copyout>
    80004e28:	10054363          	bltz	a0,80004f2e <exec+0x2f6>
    ustack[argc] = sp;
    80004e2c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e30:	0485                	addi	s1,s1,1
    80004e32:	008d8793          	addi	a5,s11,8
    80004e36:	e0f43023          	sd	a5,-512(s0)
    80004e3a:	008db503          	ld	a0,8(s11)
    80004e3e:	c911                	beqz	a0,80004e52 <exec+0x21a>
    if(argc >= MAXARG)
    80004e40:	09a1                	addi	s3,s3,8
    80004e42:	fb3c96e3          	bne	s9,s3,80004dee <exec+0x1b6>
  sz = sz1;
    80004e46:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e4a:	4481                	li	s1,0
    80004e4c:	a84d                	j	80004efe <exec+0x2c6>
  sp = sz;
    80004e4e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e50:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e52:	00349793          	slli	a5,s1,0x3
    80004e56:	f9040713          	addi	a4,s0,-112
    80004e5a:	97ba                	add	a5,a5,a4
    80004e5c:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004e60:	00148693          	addi	a3,s1,1
    80004e64:	068e                	slli	a3,a3,0x3
    80004e66:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e6a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e6e:	01897663          	bgeu	s2,s8,80004e7a <exec+0x242>
  sz = sz1;
    80004e72:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e76:	4481                	li	s1,0
    80004e78:	a059                	j	80004efe <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e7a:	e8840613          	addi	a2,s0,-376
    80004e7e:	85ca                	mv	a1,s2
    80004e80:	855e                	mv	a0,s7
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	8b4080e7          	jalr	-1868(ra) # 80001736 <copyout>
    80004e8a:	0a054663          	bltz	a0,80004f36 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004e8e:	058ab783          	ld	a5,88(s5)
    80004e92:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e96:	df843783          	ld	a5,-520(s0)
    80004e9a:	0007c703          	lbu	a4,0(a5)
    80004e9e:	cf11                	beqz	a4,80004eba <exec+0x282>
    80004ea0:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004ea2:	02f00693          	li	a3,47
    80004ea6:	a029                	j	80004eb0 <exec+0x278>
  for(last=s=path; *s; s++)
    80004ea8:	0785                	addi	a5,a5,1
    80004eaa:	fff7c703          	lbu	a4,-1(a5)
    80004eae:	c711                	beqz	a4,80004eba <exec+0x282>
    if(*s == '/')
    80004eb0:	fed71ce3          	bne	a4,a3,80004ea8 <exec+0x270>
      last = s+1;
    80004eb4:	def43c23          	sd	a5,-520(s0)
    80004eb8:	bfc5                	j	80004ea8 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004eba:	4641                	li	a2,16
    80004ebc:	df843583          	ld	a1,-520(s0)
    80004ec0:	158a8513          	addi	a0,s5,344
    80004ec4:	ffffc097          	auipc	ra,0xffffc
    80004ec8:	002080e7          	jalr	2(ra) # 80000ec6 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ecc:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004ed0:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004ed4:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ed8:	058ab783          	ld	a5,88(s5)
    80004edc:	e6043703          	ld	a4,-416(s0)
    80004ee0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ee2:	058ab783          	ld	a5,88(s5)
    80004ee6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eea:	85ea                	mv	a1,s10
    80004eec:	ffffd097          	auipc	ra,0xffffd
    80004ef0:	cb6080e7          	jalr	-842(ra) # 80001ba2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ef4:	0004851b          	sext.w	a0,s1
    80004ef8:	bbe1                	j	80004cd0 <exec+0x98>
    80004efa:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004efe:	e0843583          	ld	a1,-504(s0)
    80004f02:	855e                	mv	a0,s7
    80004f04:	ffffd097          	auipc	ra,0xffffd
    80004f08:	c9e080e7          	jalr	-866(ra) # 80001ba2 <proc_freepagetable>
  if(ip){
    80004f0c:	da0498e3          	bnez	s1,80004cbc <exec+0x84>
  return -1;
    80004f10:	557d                	li	a0,-1
    80004f12:	bb7d                	j	80004cd0 <exec+0x98>
    80004f14:	e1243423          	sd	s2,-504(s0)
    80004f18:	b7dd                	j	80004efe <exec+0x2c6>
    80004f1a:	e1243423          	sd	s2,-504(s0)
    80004f1e:	b7c5                	j	80004efe <exec+0x2c6>
    80004f20:	e1243423          	sd	s2,-504(s0)
    80004f24:	bfe9                	j	80004efe <exec+0x2c6>
  sz = sz1;
    80004f26:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f2a:	4481                	li	s1,0
    80004f2c:	bfc9                	j	80004efe <exec+0x2c6>
  sz = sz1;
    80004f2e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f32:	4481                	li	s1,0
    80004f34:	b7e9                	j	80004efe <exec+0x2c6>
  sz = sz1;
    80004f36:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f3a:	4481                	li	s1,0
    80004f3c:	b7c9                	j	80004efe <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f3e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f42:	2b05                	addiw	s6,s6,1
    80004f44:	0389899b          	addiw	s3,s3,56
    80004f48:	e8045783          	lhu	a5,-384(s0)
    80004f4c:	e2fb5be3          	bge	s6,a5,80004d82 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f50:	2981                	sext.w	s3,s3
    80004f52:	03800713          	li	a4,56
    80004f56:	86ce                	mv	a3,s3
    80004f58:	e1040613          	addi	a2,s0,-496
    80004f5c:	4581                	li	a1,0
    80004f5e:	8526                	mv	a0,s1
    80004f60:	fffff097          	auipc	ra,0xfffff
    80004f64:	a4e080e7          	jalr	-1458(ra) # 800039ae <readi>
    80004f68:	03800793          	li	a5,56
    80004f6c:	f8f517e3          	bne	a0,a5,80004efa <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004f70:	e1042783          	lw	a5,-496(s0)
    80004f74:	4705                	li	a4,1
    80004f76:	fce796e3          	bne	a5,a4,80004f42 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004f7a:	e3843603          	ld	a2,-456(s0)
    80004f7e:	e3043783          	ld	a5,-464(s0)
    80004f82:	f8f669e3          	bltu	a2,a5,80004f14 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f86:	e2043783          	ld	a5,-480(s0)
    80004f8a:	963e                	add	a2,a2,a5
    80004f8c:	f8f667e3          	bltu	a2,a5,80004f1a <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f90:	85ca                	mv	a1,s2
    80004f92:	855e                	mv	a0,s7
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	552080e7          	jalr	1362(ra) # 800014e6 <uvmalloc>
    80004f9c:	e0a43423          	sd	a0,-504(s0)
    80004fa0:	d141                	beqz	a0,80004f20 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80004fa2:	e2043d03          	ld	s10,-480(s0)
    80004fa6:	df043783          	ld	a5,-528(s0)
    80004faa:	00fd77b3          	and	a5,s10,a5
    80004fae:	fba1                	bnez	a5,80004efe <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fb0:	e1842d83          	lw	s11,-488(s0)
    80004fb4:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fb8:	f80c03e3          	beqz	s8,80004f3e <exec+0x306>
    80004fbc:	8a62                	mv	s4,s8
    80004fbe:	4901                	li	s2,0
    80004fc0:	b345                	j	80004d60 <exec+0x128>

0000000080004fc2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fc2:	7179                	addi	sp,sp,-48
    80004fc4:	f406                	sd	ra,40(sp)
    80004fc6:	f022                	sd	s0,32(sp)
    80004fc8:	ec26                	sd	s1,24(sp)
    80004fca:	e84a                	sd	s2,16(sp)
    80004fcc:	1800                	addi	s0,sp,48
    80004fce:	892e                	mv	s2,a1
    80004fd0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004fd2:	fdc40593          	addi	a1,s0,-36
    80004fd6:	ffffe097          	auipc	ra,0xffffe
    80004fda:	baa080e7          	jalr	-1110(ra) # 80002b80 <argint>
    80004fde:	04054063          	bltz	a0,8000501e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fe2:	fdc42703          	lw	a4,-36(s0)
    80004fe6:	47bd                	li	a5,15
    80004fe8:	02e7ed63          	bltu	a5,a4,80005022 <argfd+0x60>
    80004fec:	ffffd097          	auipc	ra,0xffffd
    80004ff0:	a56080e7          	jalr	-1450(ra) # 80001a42 <myproc>
    80004ff4:	fdc42703          	lw	a4,-36(s0)
    80004ff8:	01a70793          	addi	a5,a4,26
    80004ffc:	078e                	slli	a5,a5,0x3
    80004ffe:	953e                	add	a0,a0,a5
    80005000:	611c                	ld	a5,0(a0)
    80005002:	c395                	beqz	a5,80005026 <argfd+0x64>
    return -1;
  if(pfd)
    80005004:	00090463          	beqz	s2,8000500c <argfd+0x4a>
    *pfd = fd;
    80005008:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000500c:	4501                	li	a0,0
  if(pf)
    8000500e:	c091                	beqz	s1,80005012 <argfd+0x50>
    *pf = f;
    80005010:	e09c                	sd	a5,0(s1)
}
    80005012:	70a2                	ld	ra,40(sp)
    80005014:	7402                	ld	s0,32(sp)
    80005016:	64e2                	ld	s1,24(sp)
    80005018:	6942                	ld	s2,16(sp)
    8000501a:	6145                	addi	sp,sp,48
    8000501c:	8082                	ret
    return -1;
    8000501e:	557d                	li	a0,-1
    80005020:	bfcd                	j	80005012 <argfd+0x50>
    return -1;
    80005022:	557d                	li	a0,-1
    80005024:	b7fd                	j	80005012 <argfd+0x50>
    80005026:	557d                	li	a0,-1
    80005028:	b7ed                	j	80005012 <argfd+0x50>

000000008000502a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000502a:	1101                	addi	sp,sp,-32
    8000502c:	ec06                	sd	ra,24(sp)
    8000502e:	e822                	sd	s0,16(sp)
    80005030:	e426                	sd	s1,8(sp)
    80005032:	1000                	addi	s0,sp,32
    80005034:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	a0c080e7          	jalr	-1524(ra) # 80001a42 <myproc>
    8000503e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005040:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd80d0>
    80005044:	4501                	li	a0,0
    80005046:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005048:	6398                	ld	a4,0(a5)
    8000504a:	cb19                	beqz	a4,80005060 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000504c:	2505                	addiw	a0,a0,1
    8000504e:	07a1                	addi	a5,a5,8
    80005050:	fed51ce3          	bne	a0,a3,80005048 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005054:	557d                	li	a0,-1
}
    80005056:	60e2                	ld	ra,24(sp)
    80005058:	6442                	ld	s0,16(sp)
    8000505a:	64a2                	ld	s1,8(sp)
    8000505c:	6105                	addi	sp,sp,32
    8000505e:	8082                	ret
      p->ofile[fd] = f;
    80005060:	01a50793          	addi	a5,a0,26
    80005064:	078e                	slli	a5,a5,0x3
    80005066:	963e                	add	a2,a2,a5
    80005068:	e204                	sd	s1,0(a2)
      return fd;
    8000506a:	b7f5                	j	80005056 <fdalloc+0x2c>

000000008000506c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000506c:	715d                	addi	sp,sp,-80
    8000506e:	e486                	sd	ra,72(sp)
    80005070:	e0a2                	sd	s0,64(sp)
    80005072:	fc26                	sd	s1,56(sp)
    80005074:	f84a                	sd	s2,48(sp)
    80005076:	f44e                	sd	s3,40(sp)
    80005078:	f052                	sd	s4,32(sp)
    8000507a:	ec56                	sd	s5,24(sp)
    8000507c:	0880                	addi	s0,sp,80
    8000507e:	89ae                	mv	s3,a1
    80005080:	8ab2                	mv	s5,a2
    80005082:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005084:	fb040593          	addi	a1,s0,-80
    80005088:	fffff097          	auipc	ra,0xfffff
    8000508c:	e40080e7          	jalr	-448(ra) # 80003ec8 <nameiparent>
    80005090:	892a                	mv	s2,a0
    80005092:	12050f63          	beqz	a0,800051d0 <create+0x164>
    return 0;

  ilock(dp);
    80005096:	ffffe097          	auipc	ra,0xffffe
    8000509a:	664080e7          	jalr	1636(ra) # 800036fa <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000509e:	4601                	li	a2,0
    800050a0:	fb040593          	addi	a1,s0,-80
    800050a4:	854a                	mv	a0,s2
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	b32080e7          	jalr	-1230(ra) # 80003bd8 <dirlookup>
    800050ae:	84aa                	mv	s1,a0
    800050b0:	c921                	beqz	a0,80005100 <create+0x94>
    iunlockput(dp);
    800050b2:	854a                	mv	a0,s2
    800050b4:	fffff097          	auipc	ra,0xfffff
    800050b8:	8a8080e7          	jalr	-1880(ra) # 8000395c <iunlockput>
    ilock(ip);
    800050bc:	8526                	mv	a0,s1
    800050be:	ffffe097          	auipc	ra,0xffffe
    800050c2:	63c080e7          	jalr	1596(ra) # 800036fa <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050c6:	2981                	sext.w	s3,s3
    800050c8:	4789                	li	a5,2
    800050ca:	02f99463          	bne	s3,a5,800050f2 <create+0x86>
    800050ce:	0444d783          	lhu	a5,68(s1)
    800050d2:	37f9                	addiw	a5,a5,-2
    800050d4:	17c2                	slli	a5,a5,0x30
    800050d6:	93c1                	srli	a5,a5,0x30
    800050d8:	4705                	li	a4,1
    800050da:	00f76c63          	bltu	a4,a5,800050f2 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800050de:	8526                	mv	a0,s1
    800050e0:	60a6                	ld	ra,72(sp)
    800050e2:	6406                	ld	s0,64(sp)
    800050e4:	74e2                	ld	s1,56(sp)
    800050e6:	7942                	ld	s2,48(sp)
    800050e8:	79a2                	ld	s3,40(sp)
    800050ea:	7a02                	ld	s4,32(sp)
    800050ec:	6ae2                	ld	s5,24(sp)
    800050ee:	6161                	addi	sp,sp,80
    800050f0:	8082                	ret
    iunlockput(ip);
    800050f2:	8526                	mv	a0,s1
    800050f4:	fffff097          	auipc	ra,0xfffff
    800050f8:	868080e7          	jalr	-1944(ra) # 8000395c <iunlockput>
    return 0;
    800050fc:	4481                	li	s1,0
    800050fe:	b7c5                	j	800050de <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005100:	85ce                	mv	a1,s3
    80005102:	00092503          	lw	a0,0(s2)
    80005106:	ffffe097          	auipc	ra,0xffffe
    8000510a:	45c080e7          	jalr	1116(ra) # 80003562 <ialloc>
    8000510e:	84aa                	mv	s1,a0
    80005110:	c529                	beqz	a0,8000515a <create+0xee>
  ilock(ip);
    80005112:	ffffe097          	auipc	ra,0xffffe
    80005116:	5e8080e7          	jalr	1512(ra) # 800036fa <ilock>
  ip->major = major;
    8000511a:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000511e:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005122:	4785                	li	a5,1
    80005124:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005128:	8526                	mv	a0,s1
    8000512a:	ffffe097          	auipc	ra,0xffffe
    8000512e:	506080e7          	jalr	1286(ra) # 80003630 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005132:	2981                	sext.w	s3,s3
    80005134:	4785                	li	a5,1
    80005136:	02f98a63          	beq	s3,a5,8000516a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000513a:	40d0                	lw	a2,4(s1)
    8000513c:	fb040593          	addi	a1,s0,-80
    80005140:	854a                	mv	a0,s2
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	ca6080e7          	jalr	-858(ra) # 80003de8 <dirlink>
    8000514a:	06054b63          	bltz	a0,800051c0 <create+0x154>
  iunlockput(dp);
    8000514e:	854a                	mv	a0,s2
    80005150:	fffff097          	auipc	ra,0xfffff
    80005154:	80c080e7          	jalr	-2036(ra) # 8000395c <iunlockput>
  return ip;
    80005158:	b759                	j	800050de <create+0x72>
    panic("create: ialloc");
    8000515a:	00003517          	auipc	a0,0x3
    8000515e:	5a650513          	addi	a0,a0,1446 # 80008700 <syscalls+0x2c0>
    80005162:	ffffb097          	auipc	ra,0xffffb
    80005166:	474080e7          	jalr	1140(ra) # 800005d6 <panic>
    dp->nlink++;  // for ".."
    8000516a:	04a95783          	lhu	a5,74(s2)
    8000516e:	2785                	addiw	a5,a5,1
    80005170:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005174:	854a                	mv	a0,s2
    80005176:	ffffe097          	auipc	ra,0xffffe
    8000517a:	4ba080e7          	jalr	1210(ra) # 80003630 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000517e:	40d0                	lw	a2,4(s1)
    80005180:	00003597          	auipc	a1,0x3
    80005184:	59058593          	addi	a1,a1,1424 # 80008710 <syscalls+0x2d0>
    80005188:	8526                	mv	a0,s1
    8000518a:	fffff097          	auipc	ra,0xfffff
    8000518e:	c5e080e7          	jalr	-930(ra) # 80003de8 <dirlink>
    80005192:	00054f63          	bltz	a0,800051b0 <create+0x144>
    80005196:	00492603          	lw	a2,4(s2)
    8000519a:	00003597          	auipc	a1,0x3
    8000519e:	57e58593          	addi	a1,a1,1406 # 80008718 <syscalls+0x2d8>
    800051a2:	8526                	mv	a0,s1
    800051a4:	fffff097          	auipc	ra,0xfffff
    800051a8:	c44080e7          	jalr	-956(ra) # 80003de8 <dirlink>
    800051ac:	f80557e3          	bgez	a0,8000513a <create+0xce>
      panic("create dots");
    800051b0:	00003517          	auipc	a0,0x3
    800051b4:	57050513          	addi	a0,a0,1392 # 80008720 <syscalls+0x2e0>
    800051b8:	ffffb097          	auipc	ra,0xffffb
    800051bc:	41e080e7          	jalr	1054(ra) # 800005d6 <panic>
    panic("create: dirlink");
    800051c0:	00003517          	auipc	a0,0x3
    800051c4:	57050513          	addi	a0,a0,1392 # 80008730 <syscalls+0x2f0>
    800051c8:	ffffb097          	auipc	ra,0xffffb
    800051cc:	40e080e7          	jalr	1038(ra) # 800005d6 <panic>
    return 0;
    800051d0:	84aa                	mv	s1,a0
    800051d2:	b731                	j	800050de <create+0x72>

00000000800051d4 <sys_dup>:
{
    800051d4:	7179                	addi	sp,sp,-48
    800051d6:	f406                	sd	ra,40(sp)
    800051d8:	f022                	sd	s0,32(sp)
    800051da:	ec26                	sd	s1,24(sp)
    800051dc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051de:	fd840613          	addi	a2,s0,-40
    800051e2:	4581                	li	a1,0
    800051e4:	4501                	li	a0,0
    800051e6:	00000097          	auipc	ra,0x0
    800051ea:	ddc080e7          	jalr	-548(ra) # 80004fc2 <argfd>
    return -1;
    800051ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051f0:	02054363          	bltz	a0,80005216 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800051f4:	fd843503          	ld	a0,-40(s0)
    800051f8:	00000097          	auipc	ra,0x0
    800051fc:	e32080e7          	jalr	-462(ra) # 8000502a <fdalloc>
    80005200:	84aa                	mv	s1,a0
    return -1;
    80005202:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005204:	00054963          	bltz	a0,80005216 <sys_dup+0x42>
  filedup(f);
    80005208:	fd843503          	ld	a0,-40(s0)
    8000520c:	fffff097          	auipc	ra,0xfffff
    80005210:	32a080e7          	jalr	810(ra) # 80004536 <filedup>
  return fd;
    80005214:	87a6                	mv	a5,s1
}
    80005216:	853e                	mv	a0,a5
    80005218:	70a2                	ld	ra,40(sp)
    8000521a:	7402                	ld	s0,32(sp)
    8000521c:	64e2                	ld	s1,24(sp)
    8000521e:	6145                	addi	sp,sp,48
    80005220:	8082                	ret

0000000080005222 <sys_read>:
{
    80005222:	7179                	addi	sp,sp,-48
    80005224:	f406                	sd	ra,40(sp)
    80005226:	f022                	sd	s0,32(sp)
    80005228:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000522a:	fe840613          	addi	a2,s0,-24
    8000522e:	4581                	li	a1,0
    80005230:	4501                	li	a0,0
    80005232:	00000097          	auipc	ra,0x0
    80005236:	d90080e7          	jalr	-624(ra) # 80004fc2 <argfd>
    return -1;
    8000523a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000523c:	04054163          	bltz	a0,8000527e <sys_read+0x5c>
    80005240:	fe440593          	addi	a1,s0,-28
    80005244:	4509                	li	a0,2
    80005246:	ffffe097          	auipc	ra,0xffffe
    8000524a:	93a080e7          	jalr	-1734(ra) # 80002b80 <argint>
    return -1;
    8000524e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005250:	02054763          	bltz	a0,8000527e <sys_read+0x5c>
    80005254:	fd840593          	addi	a1,s0,-40
    80005258:	4505                	li	a0,1
    8000525a:	ffffe097          	auipc	ra,0xffffe
    8000525e:	948080e7          	jalr	-1720(ra) # 80002ba2 <argaddr>
    return -1;
    80005262:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005264:	00054d63          	bltz	a0,8000527e <sys_read+0x5c>
  return fileread(f, p, n);
    80005268:	fe442603          	lw	a2,-28(s0)
    8000526c:	fd843583          	ld	a1,-40(s0)
    80005270:	fe843503          	ld	a0,-24(s0)
    80005274:	fffff097          	auipc	ra,0xfffff
    80005278:	44e080e7          	jalr	1102(ra) # 800046c2 <fileread>
    8000527c:	87aa                	mv	a5,a0
}
    8000527e:	853e                	mv	a0,a5
    80005280:	70a2                	ld	ra,40(sp)
    80005282:	7402                	ld	s0,32(sp)
    80005284:	6145                	addi	sp,sp,48
    80005286:	8082                	ret

0000000080005288 <sys_write>:
{
    80005288:	7179                	addi	sp,sp,-48
    8000528a:	f406                	sd	ra,40(sp)
    8000528c:	f022                	sd	s0,32(sp)
    8000528e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005290:	fe840613          	addi	a2,s0,-24
    80005294:	4581                	li	a1,0
    80005296:	4501                	li	a0,0
    80005298:	00000097          	auipc	ra,0x0
    8000529c:	d2a080e7          	jalr	-726(ra) # 80004fc2 <argfd>
    return -1;
    800052a0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052a2:	04054163          	bltz	a0,800052e4 <sys_write+0x5c>
    800052a6:	fe440593          	addi	a1,s0,-28
    800052aa:	4509                	li	a0,2
    800052ac:	ffffe097          	auipc	ra,0xffffe
    800052b0:	8d4080e7          	jalr	-1836(ra) # 80002b80 <argint>
    return -1;
    800052b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052b6:	02054763          	bltz	a0,800052e4 <sys_write+0x5c>
    800052ba:	fd840593          	addi	a1,s0,-40
    800052be:	4505                	li	a0,1
    800052c0:	ffffe097          	auipc	ra,0xffffe
    800052c4:	8e2080e7          	jalr	-1822(ra) # 80002ba2 <argaddr>
    return -1;
    800052c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052ca:	00054d63          	bltz	a0,800052e4 <sys_write+0x5c>
  return filewrite(f, p, n);
    800052ce:	fe442603          	lw	a2,-28(s0)
    800052d2:	fd843583          	ld	a1,-40(s0)
    800052d6:	fe843503          	ld	a0,-24(s0)
    800052da:	fffff097          	auipc	ra,0xfffff
    800052de:	4aa080e7          	jalr	1194(ra) # 80004784 <filewrite>
    800052e2:	87aa                	mv	a5,a0
}
    800052e4:	853e                	mv	a0,a5
    800052e6:	70a2                	ld	ra,40(sp)
    800052e8:	7402                	ld	s0,32(sp)
    800052ea:	6145                	addi	sp,sp,48
    800052ec:	8082                	ret

00000000800052ee <sys_close>:
{
    800052ee:	1101                	addi	sp,sp,-32
    800052f0:	ec06                	sd	ra,24(sp)
    800052f2:	e822                	sd	s0,16(sp)
    800052f4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052f6:	fe040613          	addi	a2,s0,-32
    800052fa:	fec40593          	addi	a1,s0,-20
    800052fe:	4501                	li	a0,0
    80005300:	00000097          	auipc	ra,0x0
    80005304:	cc2080e7          	jalr	-830(ra) # 80004fc2 <argfd>
    return -1;
    80005308:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000530a:	02054463          	bltz	a0,80005332 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000530e:	ffffc097          	auipc	ra,0xffffc
    80005312:	734080e7          	jalr	1844(ra) # 80001a42 <myproc>
    80005316:	fec42783          	lw	a5,-20(s0)
    8000531a:	07e9                	addi	a5,a5,26
    8000531c:	078e                	slli	a5,a5,0x3
    8000531e:	97aa                	add	a5,a5,a0
    80005320:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005324:	fe043503          	ld	a0,-32(s0)
    80005328:	fffff097          	auipc	ra,0xfffff
    8000532c:	260080e7          	jalr	608(ra) # 80004588 <fileclose>
  return 0;
    80005330:	4781                	li	a5,0
}
    80005332:	853e                	mv	a0,a5
    80005334:	60e2                	ld	ra,24(sp)
    80005336:	6442                	ld	s0,16(sp)
    80005338:	6105                	addi	sp,sp,32
    8000533a:	8082                	ret

000000008000533c <sys_fstat>:
{
    8000533c:	1101                	addi	sp,sp,-32
    8000533e:	ec06                	sd	ra,24(sp)
    80005340:	e822                	sd	s0,16(sp)
    80005342:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005344:	fe840613          	addi	a2,s0,-24
    80005348:	4581                	li	a1,0
    8000534a:	4501                	li	a0,0
    8000534c:	00000097          	auipc	ra,0x0
    80005350:	c76080e7          	jalr	-906(ra) # 80004fc2 <argfd>
    return -1;
    80005354:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005356:	02054563          	bltz	a0,80005380 <sys_fstat+0x44>
    8000535a:	fe040593          	addi	a1,s0,-32
    8000535e:	4505                	li	a0,1
    80005360:	ffffe097          	auipc	ra,0xffffe
    80005364:	842080e7          	jalr	-1982(ra) # 80002ba2 <argaddr>
    return -1;
    80005368:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000536a:	00054b63          	bltz	a0,80005380 <sys_fstat+0x44>
  return filestat(f, st);
    8000536e:	fe043583          	ld	a1,-32(s0)
    80005372:	fe843503          	ld	a0,-24(s0)
    80005376:	fffff097          	auipc	ra,0xfffff
    8000537a:	2da080e7          	jalr	730(ra) # 80004650 <filestat>
    8000537e:	87aa                	mv	a5,a0
}
    80005380:	853e                	mv	a0,a5
    80005382:	60e2                	ld	ra,24(sp)
    80005384:	6442                	ld	s0,16(sp)
    80005386:	6105                	addi	sp,sp,32
    80005388:	8082                	ret

000000008000538a <sys_link>:
{
    8000538a:	7169                	addi	sp,sp,-304
    8000538c:	f606                	sd	ra,296(sp)
    8000538e:	f222                	sd	s0,288(sp)
    80005390:	ee26                	sd	s1,280(sp)
    80005392:	ea4a                	sd	s2,272(sp)
    80005394:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005396:	08000613          	li	a2,128
    8000539a:	ed040593          	addi	a1,s0,-304
    8000539e:	4501                	li	a0,0
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	824080e7          	jalr	-2012(ra) # 80002bc4 <argstr>
    return -1;
    800053a8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053aa:	10054e63          	bltz	a0,800054c6 <sys_link+0x13c>
    800053ae:	08000613          	li	a2,128
    800053b2:	f5040593          	addi	a1,s0,-176
    800053b6:	4505                	li	a0,1
    800053b8:	ffffe097          	auipc	ra,0xffffe
    800053bc:	80c080e7          	jalr	-2036(ra) # 80002bc4 <argstr>
    return -1;
    800053c0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053c2:	10054263          	bltz	a0,800054c6 <sys_link+0x13c>
  begin_op();
    800053c6:	fffff097          	auipc	ra,0xfffff
    800053ca:	cf0080e7          	jalr	-784(ra) # 800040b6 <begin_op>
  if((ip = namei(old)) == 0){
    800053ce:	ed040513          	addi	a0,s0,-304
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	ad8080e7          	jalr	-1320(ra) # 80003eaa <namei>
    800053da:	84aa                	mv	s1,a0
    800053dc:	c551                	beqz	a0,80005468 <sys_link+0xde>
  ilock(ip);
    800053de:	ffffe097          	auipc	ra,0xffffe
    800053e2:	31c080e7          	jalr	796(ra) # 800036fa <ilock>
  if(ip->type == T_DIR){
    800053e6:	04449703          	lh	a4,68(s1)
    800053ea:	4785                	li	a5,1
    800053ec:	08f70463          	beq	a4,a5,80005474 <sys_link+0xea>
  ip->nlink++;
    800053f0:	04a4d783          	lhu	a5,74(s1)
    800053f4:	2785                	addiw	a5,a5,1
    800053f6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053fa:	8526                	mv	a0,s1
    800053fc:	ffffe097          	auipc	ra,0xffffe
    80005400:	234080e7          	jalr	564(ra) # 80003630 <iupdate>
  iunlock(ip);
    80005404:	8526                	mv	a0,s1
    80005406:	ffffe097          	auipc	ra,0xffffe
    8000540a:	3b6080e7          	jalr	950(ra) # 800037bc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000540e:	fd040593          	addi	a1,s0,-48
    80005412:	f5040513          	addi	a0,s0,-176
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	ab2080e7          	jalr	-1358(ra) # 80003ec8 <nameiparent>
    8000541e:	892a                	mv	s2,a0
    80005420:	c935                	beqz	a0,80005494 <sys_link+0x10a>
  ilock(dp);
    80005422:	ffffe097          	auipc	ra,0xffffe
    80005426:	2d8080e7          	jalr	728(ra) # 800036fa <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000542a:	00092703          	lw	a4,0(s2)
    8000542e:	409c                	lw	a5,0(s1)
    80005430:	04f71d63          	bne	a4,a5,8000548a <sys_link+0x100>
    80005434:	40d0                	lw	a2,4(s1)
    80005436:	fd040593          	addi	a1,s0,-48
    8000543a:	854a                	mv	a0,s2
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	9ac080e7          	jalr	-1620(ra) # 80003de8 <dirlink>
    80005444:	04054363          	bltz	a0,8000548a <sys_link+0x100>
  iunlockput(dp);
    80005448:	854a                	mv	a0,s2
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	512080e7          	jalr	1298(ra) # 8000395c <iunlockput>
  iput(ip);
    80005452:	8526                	mv	a0,s1
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	460080e7          	jalr	1120(ra) # 800038b4 <iput>
  end_op();
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	cda080e7          	jalr	-806(ra) # 80004136 <end_op>
  return 0;
    80005464:	4781                	li	a5,0
    80005466:	a085                	j	800054c6 <sys_link+0x13c>
    end_op();
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	cce080e7          	jalr	-818(ra) # 80004136 <end_op>
    return -1;
    80005470:	57fd                	li	a5,-1
    80005472:	a891                	j	800054c6 <sys_link+0x13c>
    iunlockput(ip);
    80005474:	8526                	mv	a0,s1
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	4e6080e7          	jalr	1254(ra) # 8000395c <iunlockput>
    end_op();
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	cb8080e7          	jalr	-840(ra) # 80004136 <end_op>
    return -1;
    80005486:	57fd                	li	a5,-1
    80005488:	a83d                	j	800054c6 <sys_link+0x13c>
    iunlockput(dp);
    8000548a:	854a                	mv	a0,s2
    8000548c:	ffffe097          	auipc	ra,0xffffe
    80005490:	4d0080e7          	jalr	1232(ra) # 8000395c <iunlockput>
  ilock(ip);
    80005494:	8526                	mv	a0,s1
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	264080e7          	jalr	612(ra) # 800036fa <ilock>
  ip->nlink--;
    8000549e:	04a4d783          	lhu	a5,74(s1)
    800054a2:	37fd                	addiw	a5,a5,-1
    800054a4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054a8:	8526                	mv	a0,s1
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	186080e7          	jalr	390(ra) # 80003630 <iupdate>
  iunlockput(ip);
    800054b2:	8526                	mv	a0,s1
    800054b4:	ffffe097          	auipc	ra,0xffffe
    800054b8:	4a8080e7          	jalr	1192(ra) # 8000395c <iunlockput>
  end_op();
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	c7a080e7          	jalr	-902(ra) # 80004136 <end_op>
  return -1;
    800054c4:	57fd                	li	a5,-1
}
    800054c6:	853e                	mv	a0,a5
    800054c8:	70b2                	ld	ra,296(sp)
    800054ca:	7412                	ld	s0,288(sp)
    800054cc:	64f2                	ld	s1,280(sp)
    800054ce:	6952                	ld	s2,272(sp)
    800054d0:	6155                	addi	sp,sp,304
    800054d2:	8082                	ret

00000000800054d4 <sys_unlink>:
{
    800054d4:	7151                	addi	sp,sp,-240
    800054d6:	f586                	sd	ra,232(sp)
    800054d8:	f1a2                	sd	s0,224(sp)
    800054da:	eda6                	sd	s1,216(sp)
    800054dc:	e9ca                	sd	s2,208(sp)
    800054de:	e5ce                	sd	s3,200(sp)
    800054e0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054e2:	08000613          	li	a2,128
    800054e6:	f3040593          	addi	a1,s0,-208
    800054ea:	4501                	li	a0,0
    800054ec:	ffffd097          	auipc	ra,0xffffd
    800054f0:	6d8080e7          	jalr	1752(ra) # 80002bc4 <argstr>
    800054f4:	18054163          	bltz	a0,80005676 <sys_unlink+0x1a2>
  begin_op();
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	bbe080e7          	jalr	-1090(ra) # 800040b6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005500:	fb040593          	addi	a1,s0,-80
    80005504:	f3040513          	addi	a0,s0,-208
    80005508:	fffff097          	auipc	ra,0xfffff
    8000550c:	9c0080e7          	jalr	-1600(ra) # 80003ec8 <nameiparent>
    80005510:	84aa                	mv	s1,a0
    80005512:	c979                	beqz	a0,800055e8 <sys_unlink+0x114>
  ilock(dp);
    80005514:	ffffe097          	auipc	ra,0xffffe
    80005518:	1e6080e7          	jalr	486(ra) # 800036fa <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000551c:	00003597          	auipc	a1,0x3
    80005520:	1f458593          	addi	a1,a1,500 # 80008710 <syscalls+0x2d0>
    80005524:	fb040513          	addi	a0,s0,-80
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	696080e7          	jalr	1686(ra) # 80003bbe <namecmp>
    80005530:	14050a63          	beqz	a0,80005684 <sys_unlink+0x1b0>
    80005534:	00003597          	auipc	a1,0x3
    80005538:	1e458593          	addi	a1,a1,484 # 80008718 <syscalls+0x2d8>
    8000553c:	fb040513          	addi	a0,s0,-80
    80005540:	ffffe097          	auipc	ra,0xffffe
    80005544:	67e080e7          	jalr	1662(ra) # 80003bbe <namecmp>
    80005548:	12050e63          	beqz	a0,80005684 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000554c:	f2c40613          	addi	a2,s0,-212
    80005550:	fb040593          	addi	a1,s0,-80
    80005554:	8526                	mv	a0,s1
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	682080e7          	jalr	1666(ra) # 80003bd8 <dirlookup>
    8000555e:	892a                	mv	s2,a0
    80005560:	12050263          	beqz	a0,80005684 <sys_unlink+0x1b0>
  ilock(ip);
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	196080e7          	jalr	406(ra) # 800036fa <ilock>
  if(ip->nlink < 1)
    8000556c:	04a91783          	lh	a5,74(s2)
    80005570:	08f05263          	blez	a5,800055f4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005574:	04491703          	lh	a4,68(s2)
    80005578:	4785                	li	a5,1
    8000557a:	08f70563          	beq	a4,a5,80005604 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000557e:	4641                	li	a2,16
    80005580:	4581                	li	a1,0
    80005582:	fc040513          	addi	a0,s0,-64
    80005586:	ffffb097          	auipc	ra,0xffffb
    8000558a:	7ea080e7          	jalr	2026(ra) # 80000d70 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000558e:	4741                	li	a4,16
    80005590:	f2c42683          	lw	a3,-212(s0)
    80005594:	fc040613          	addi	a2,s0,-64
    80005598:	4581                	li	a1,0
    8000559a:	8526                	mv	a0,s1
    8000559c:	ffffe097          	auipc	ra,0xffffe
    800055a0:	508080e7          	jalr	1288(ra) # 80003aa4 <writei>
    800055a4:	47c1                	li	a5,16
    800055a6:	0af51563          	bne	a0,a5,80005650 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055aa:	04491703          	lh	a4,68(s2)
    800055ae:	4785                	li	a5,1
    800055b0:	0af70863          	beq	a4,a5,80005660 <sys_unlink+0x18c>
  iunlockput(dp);
    800055b4:	8526                	mv	a0,s1
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	3a6080e7          	jalr	934(ra) # 8000395c <iunlockput>
  ip->nlink--;
    800055be:	04a95783          	lhu	a5,74(s2)
    800055c2:	37fd                	addiw	a5,a5,-1
    800055c4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055c8:	854a                	mv	a0,s2
    800055ca:	ffffe097          	auipc	ra,0xffffe
    800055ce:	066080e7          	jalr	102(ra) # 80003630 <iupdate>
  iunlockput(ip);
    800055d2:	854a                	mv	a0,s2
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	388080e7          	jalr	904(ra) # 8000395c <iunlockput>
  end_op();
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	b5a080e7          	jalr	-1190(ra) # 80004136 <end_op>
  return 0;
    800055e4:	4501                	li	a0,0
    800055e6:	a84d                	j	80005698 <sys_unlink+0x1c4>
    end_op();
    800055e8:	fffff097          	auipc	ra,0xfffff
    800055ec:	b4e080e7          	jalr	-1202(ra) # 80004136 <end_op>
    return -1;
    800055f0:	557d                	li	a0,-1
    800055f2:	a05d                	j	80005698 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055f4:	00003517          	auipc	a0,0x3
    800055f8:	14c50513          	addi	a0,a0,332 # 80008740 <syscalls+0x300>
    800055fc:	ffffb097          	auipc	ra,0xffffb
    80005600:	fda080e7          	jalr	-38(ra) # 800005d6 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005604:	04c92703          	lw	a4,76(s2)
    80005608:	02000793          	li	a5,32
    8000560c:	f6e7f9e3          	bgeu	a5,a4,8000557e <sys_unlink+0xaa>
    80005610:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005614:	4741                	li	a4,16
    80005616:	86ce                	mv	a3,s3
    80005618:	f1840613          	addi	a2,s0,-232
    8000561c:	4581                	li	a1,0
    8000561e:	854a                	mv	a0,s2
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	38e080e7          	jalr	910(ra) # 800039ae <readi>
    80005628:	47c1                	li	a5,16
    8000562a:	00f51b63          	bne	a0,a5,80005640 <sys_unlink+0x16c>
    if(de.inum != 0)
    8000562e:	f1845783          	lhu	a5,-232(s0)
    80005632:	e7a1                	bnez	a5,8000567a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005634:	29c1                	addiw	s3,s3,16
    80005636:	04c92783          	lw	a5,76(s2)
    8000563a:	fcf9ede3          	bltu	s3,a5,80005614 <sys_unlink+0x140>
    8000563e:	b781                	j	8000557e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005640:	00003517          	auipc	a0,0x3
    80005644:	11850513          	addi	a0,a0,280 # 80008758 <syscalls+0x318>
    80005648:	ffffb097          	auipc	ra,0xffffb
    8000564c:	f8e080e7          	jalr	-114(ra) # 800005d6 <panic>
    panic("unlink: writei");
    80005650:	00003517          	auipc	a0,0x3
    80005654:	12050513          	addi	a0,a0,288 # 80008770 <syscalls+0x330>
    80005658:	ffffb097          	auipc	ra,0xffffb
    8000565c:	f7e080e7          	jalr	-130(ra) # 800005d6 <panic>
    dp->nlink--;
    80005660:	04a4d783          	lhu	a5,74(s1)
    80005664:	37fd                	addiw	a5,a5,-1
    80005666:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000566a:	8526                	mv	a0,s1
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	fc4080e7          	jalr	-60(ra) # 80003630 <iupdate>
    80005674:	b781                	j	800055b4 <sys_unlink+0xe0>
    return -1;
    80005676:	557d                	li	a0,-1
    80005678:	a005                	j	80005698 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000567a:	854a                	mv	a0,s2
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	2e0080e7          	jalr	736(ra) # 8000395c <iunlockput>
  iunlockput(dp);
    80005684:	8526                	mv	a0,s1
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	2d6080e7          	jalr	726(ra) # 8000395c <iunlockput>
  end_op();
    8000568e:	fffff097          	auipc	ra,0xfffff
    80005692:	aa8080e7          	jalr	-1368(ra) # 80004136 <end_op>
  return -1;
    80005696:	557d                	li	a0,-1
}
    80005698:	70ae                	ld	ra,232(sp)
    8000569a:	740e                	ld	s0,224(sp)
    8000569c:	64ee                	ld	s1,216(sp)
    8000569e:	694e                	ld	s2,208(sp)
    800056a0:	69ae                	ld	s3,200(sp)
    800056a2:	616d                	addi	sp,sp,240
    800056a4:	8082                	ret

00000000800056a6 <sys_open>:

uint64
sys_open(void)
{
    800056a6:	7131                	addi	sp,sp,-192
    800056a8:	fd06                	sd	ra,184(sp)
    800056aa:	f922                	sd	s0,176(sp)
    800056ac:	f526                	sd	s1,168(sp)
    800056ae:	f14a                	sd	s2,160(sp)
    800056b0:	ed4e                	sd	s3,152(sp)
    800056b2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056b4:	08000613          	li	a2,128
    800056b8:	f5040593          	addi	a1,s0,-176
    800056bc:	4501                	li	a0,0
    800056be:	ffffd097          	auipc	ra,0xffffd
    800056c2:	506080e7          	jalr	1286(ra) # 80002bc4 <argstr>
    return -1;
    800056c6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056c8:	0c054163          	bltz	a0,8000578a <sys_open+0xe4>
    800056cc:	f4c40593          	addi	a1,s0,-180
    800056d0:	4505                	li	a0,1
    800056d2:	ffffd097          	auipc	ra,0xffffd
    800056d6:	4ae080e7          	jalr	1198(ra) # 80002b80 <argint>
    800056da:	0a054863          	bltz	a0,8000578a <sys_open+0xe4>

  begin_op();
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	9d8080e7          	jalr	-1576(ra) # 800040b6 <begin_op>

  if(omode & O_CREATE){
    800056e6:	f4c42783          	lw	a5,-180(s0)
    800056ea:	2007f793          	andi	a5,a5,512
    800056ee:	cbdd                	beqz	a5,800057a4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056f0:	4681                	li	a3,0
    800056f2:	4601                	li	a2,0
    800056f4:	4589                	li	a1,2
    800056f6:	f5040513          	addi	a0,s0,-176
    800056fa:	00000097          	auipc	ra,0x0
    800056fe:	972080e7          	jalr	-1678(ra) # 8000506c <create>
    80005702:	892a                	mv	s2,a0
    if(ip == 0){
    80005704:	c959                	beqz	a0,8000579a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005706:	04491703          	lh	a4,68(s2)
    8000570a:	478d                	li	a5,3
    8000570c:	00f71763          	bne	a4,a5,8000571a <sys_open+0x74>
    80005710:	04695703          	lhu	a4,70(s2)
    80005714:	47a5                	li	a5,9
    80005716:	0ce7ec63          	bltu	a5,a4,800057ee <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	db2080e7          	jalr	-590(ra) # 800044cc <filealloc>
    80005722:	89aa                	mv	s3,a0
    80005724:	10050263          	beqz	a0,80005828 <sys_open+0x182>
    80005728:	00000097          	auipc	ra,0x0
    8000572c:	902080e7          	jalr	-1790(ra) # 8000502a <fdalloc>
    80005730:	84aa                	mv	s1,a0
    80005732:	0e054663          	bltz	a0,8000581e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005736:	04491703          	lh	a4,68(s2)
    8000573a:	478d                	li	a5,3
    8000573c:	0cf70463          	beq	a4,a5,80005804 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005740:	4789                	li	a5,2
    80005742:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005746:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000574a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000574e:	f4c42783          	lw	a5,-180(s0)
    80005752:	0017c713          	xori	a4,a5,1
    80005756:	8b05                	andi	a4,a4,1
    80005758:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000575c:	0037f713          	andi	a4,a5,3
    80005760:	00e03733          	snez	a4,a4
    80005764:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005768:	4007f793          	andi	a5,a5,1024
    8000576c:	c791                	beqz	a5,80005778 <sys_open+0xd2>
    8000576e:	04491703          	lh	a4,68(s2)
    80005772:	4789                	li	a5,2
    80005774:	08f70f63          	beq	a4,a5,80005812 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005778:	854a                	mv	a0,s2
    8000577a:	ffffe097          	auipc	ra,0xffffe
    8000577e:	042080e7          	jalr	66(ra) # 800037bc <iunlock>
  end_op();
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	9b4080e7          	jalr	-1612(ra) # 80004136 <end_op>

  return fd;
}
    8000578a:	8526                	mv	a0,s1
    8000578c:	70ea                	ld	ra,184(sp)
    8000578e:	744a                	ld	s0,176(sp)
    80005790:	74aa                	ld	s1,168(sp)
    80005792:	790a                	ld	s2,160(sp)
    80005794:	69ea                	ld	s3,152(sp)
    80005796:	6129                	addi	sp,sp,192
    80005798:	8082                	ret
      end_op();
    8000579a:	fffff097          	auipc	ra,0xfffff
    8000579e:	99c080e7          	jalr	-1636(ra) # 80004136 <end_op>
      return -1;
    800057a2:	b7e5                	j	8000578a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800057a4:	f5040513          	addi	a0,s0,-176
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	702080e7          	jalr	1794(ra) # 80003eaa <namei>
    800057b0:	892a                	mv	s2,a0
    800057b2:	c905                	beqz	a0,800057e2 <sys_open+0x13c>
    ilock(ip);
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	f46080e7          	jalr	-186(ra) # 800036fa <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057bc:	04491703          	lh	a4,68(s2)
    800057c0:	4785                	li	a5,1
    800057c2:	f4f712e3          	bne	a4,a5,80005706 <sys_open+0x60>
    800057c6:	f4c42783          	lw	a5,-180(s0)
    800057ca:	dba1                	beqz	a5,8000571a <sys_open+0x74>
      iunlockput(ip);
    800057cc:	854a                	mv	a0,s2
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	18e080e7          	jalr	398(ra) # 8000395c <iunlockput>
      end_op();
    800057d6:	fffff097          	auipc	ra,0xfffff
    800057da:	960080e7          	jalr	-1696(ra) # 80004136 <end_op>
      return -1;
    800057de:	54fd                	li	s1,-1
    800057e0:	b76d                	j	8000578a <sys_open+0xe4>
      end_op();
    800057e2:	fffff097          	auipc	ra,0xfffff
    800057e6:	954080e7          	jalr	-1708(ra) # 80004136 <end_op>
      return -1;
    800057ea:	54fd                	li	s1,-1
    800057ec:	bf79                	j	8000578a <sys_open+0xe4>
    iunlockput(ip);
    800057ee:	854a                	mv	a0,s2
    800057f0:	ffffe097          	auipc	ra,0xffffe
    800057f4:	16c080e7          	jalr	364(ra) # 8000395c <iunlockput>
    end_op();
    800057f8:	fffff097          	auipc	ra,0xfffff
    800057fc:	93e080e7          	jalr	-1730(ra) # 80004136 <end_op>
    return -1;
    80005800:	54fd                	li	s1,-1
    80005802:	b761                	j	8000578a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005804:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005808:	04691783          	lh	a5,70(s2)
    8000580c:	02f99223          	sh	a5,36(s3)
    80005810:	bf2d                	j	8000574a <sys_open+0xa4>
    itrunc(ip);
    80005812:	854a                	mv	a0,s2
    80005814:	ffffe097          	auipc	ra,0xffffe
    80005818:	ff4080e7          	jalr	-12(ra) # 80003808 <itrunc>
    8000581c:	bfb1                	j	80005778 <sys_open+0xd2>
      fileclose(f);
    8000581e:	854e                	mv	a0,s3
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	d68080e7          	jalr	-664(ra) # 80004588 <fileclose>
    iunlockput(ip);
    80005828:	854a                	mv	a0,s2
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	132080e7          	jalr	306(ra) # 8000395c <iunlockput>
    end_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	904080e7          	jalr	-1788(ra) # 80004136 <end_op>
    return -1;
    8000583a:	54fd                	li	s1,-1
    8000583c:	b7b9                	j	8000578a <sys_open+0xe4>

000000008000583e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000583e:	7175                	addi	sp,sp,-144
    80005840:	e506                	sd	ra,136(sp)
    80005842:	e122                	sd	s0,128(sp)
    80005844:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	870080e7          	jalr	-1936(ra) # 800040b6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000584e:	08000613          	li	a2,128
    80005852:	f7040593          	addi	a1,s0,-144
    80005856:	4501                	li	a0,0
    80005858:	ffffd097          	auipc	ra,0xffffd
    8000585c:	36c080e7          	jalr	876(ra) # 80002bc4 <argstr>
    80005860:	02054963          	bltz	a0,80005892 <sys_mkdir+0x54>
    80005864:	4681                	li	a3,0
    80005866:	4601                	li	a2,0
    80005868:	4585                	li	a1,1
    8000586a:	f7040513          	addi	a0,s0,-144
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	7fe080e7          	jalr	2046(ra) # 8000506c <create>
    80005876:	cd11                	beqz	a0,80005892 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	0e4080e7          	jalr	228(ra) # 8000395c <iunlockput>
  end_op();
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	8b6080e7          	jalr	-1866(ra) # 80004136 <end_op>
  return 0;
    80005888:	4501                	li	a0,0
}
    8000588a:	60aa                	ld	ra,136(sp)
    8000588c:	640a                	ld	s0,128(sp)
    8000588e:	6149                	addi	sp,sp,144
    80005890:	8082                	ret
    end_op();
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	8a4080e7          	jalr	-1884(ra) # 80004136 <end_op>
    return -1;
    8000589a:	557d                	li	a0,-1
    8000589c:	b7fd                	j	8000588a <sys_mkdir+0x4c>

000000008000589e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000589e:	7135                	addi	sp,sp,-160
    800058a0:	ed06                	sd	ra,152(sp)
    800058a2:	e922                	sd	s0,144(sp)
    800058a4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058a6:	fffff097          	auipc	ra,0xfffff
    800058aa:	810080e7          	jalr	-2032(ra) # 800040b6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058ae:	08000613          	li	a2,128
    800058b2:	f7040593          	addi	a1,s0,-144
    800058b6:	4501                	li	a0,0
    800058b8:	ffffd097          	auipc	ra,0xffffd
    800058bc:	30c080e7          	jalr	780(ra) # 80002bc4 <argstr>
    800058c0:	04054a63          	bltz	a0,80005914 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800058c4:	f6c40593          	addi	a1,s0,-148
    800058c8:	4505                	li	a0,1
    800058ca:	ffffd097          	auipc	ra,0xffffd
    800058ce:	2b6080e7          	jalr	694(ra) # 80002b80 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058d2:	04054163          	bltz	a0,80005914 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800058d6:	f6840593          	addi	a1,s0,-152
    800058da:	4509                	li	a0,2
    800058dc:	ffffd097          	auipc	ra,0xffffd
    800058e0:	2a4080e7          	jalr	676(ra) # 80002b80 <argint>
     argint(1, &major) < 0 ||
    800058e4:	02054863          	bltz	a0,80005914 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058e8:	f6841683          	lh	a3,-152(s0)
    800058ec:	f6c41603          	lh	a2,-148(s0)
    800058f0:	458d                	li	a1,3
    800058f2:	f7040513          	addi	a0,s0,-144
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	776080e7          	jalr	1910(ra) # 8000506c <create>
     argint(2, &minor) < 0 ||
    800058fe:	c919                	beqz	a0,80005914 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	05c080e7          	jalr	92(ra) # 8000395c <iunlockput>
  end_op();
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	82e080e7          	jalr	-2002(ra) # 80004136 <end_op>
  return 0;
    80005910:	4501                	li	a0,0
    80005912:	a031                	j	8000591e <sys_mknod+0x80>
    end_op();
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	822080e7          	jalr	-2014(ra) # 80004136 <end_op>
    return -1;
    8000591c:	557d                	li	a0,-1
}
    8000591e:	60ea                	ld	ra,152(sp)
    80005920:	644a                	ld	s0,144(sp)
    80005922:	610d                	addi	sp,sp,160
    80005924:	8082                	ret

0000000080005926 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005926:	7135                	addi	sp,sp,-160
    80005928:	ed06                	sd	ra,152(sp)
    8000592a:	e922                	sd	s0,144(sp)
    8000592c:	e526                	sd	s1,136(sp)
    8000592e:	e14a                	sd	s2,128(sp)
    80005930:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005932:	ffffc097          	auipc	ra,0xffffc
    80005936:	110080e7          	jalr	272(ra) # 80001a42 <myproc>
    8000593a:	892a                	mv	s2,a0
  
  begin_op();
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	77a080e7          	jalr	1914(ra) # 800040b6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005944:	08000613          	li	a2,128
    80005948:	f6040593          	addi	a1,s0,-160
    8000594c:	4501                	li	a0,0
    8000594e:	ffffd097          	auipc	ra,0xffffd
    80005952:	276080e7          	jalr	630(ra) # 80002bc4 <argstr>
    80005956:	04054b63          	bltz	a0,800059ac <sys_chdir+0x86>
    8000595a:	f6040513          	addi	a0,s0,-160
    8000595e:	ffffe097          	auipc	ra,0xffffe
    80005962:	54c080e7          	jalr	1356(ra) # 80003eaa <namei>
    80005966:	84aa                	mv	s1,a0
    80005968:	c131                	beqz	a0,800059ac <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	d90080e7          	jalr	-624(ra) # 800036fa <ilock>
  if(ip->type != T_DIR){
    80005972:	04449703          	lh	a4,68(s1)
    80005976:	4785                	li	a5,1
    80005978:	04f71063          	bne	a4,a5,800059b8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000597c:	8526                	mv	a0,s1
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	e3e080e7          	jalr	-450(ra) # 800037bc <iunlock>
  iput(p->cwd);
    80005986:	15093503          	ld	a0,336(s2)
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	f2a080e7          	jalr	-214(ra) # 800038b4 <iput>
  end_op();
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	7a4080e7          	jalr	1956(ra) # 80004136 <end_op>
  p->cwd = ip;
    8000599a:	14993823          	sd	s1,336(s2)
  return 0;
    8000599e:	4501                	li	a0,0
}
    800059a0:	60ea                	ld	ra,152(sp)
    800059a2:	644a                	ld	s0,144(sp)
    800059a4:	64aa                	ld	s1,136(sp)
    800059a6:	690a                	ld	s2,128(sp)
    800059a8:	610d                	addi	sp,sp,160
    800059aa:	8082                	ret
    end_op();
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	78a080e7          	jalr	1930(ra) # 80004136 <end_op>
    return -1;
    800059b4:	557d                	li	a0,-1
    800059b6:	b7ed                	j	800059a0 <sys_chdir+0x7a>
    iunlockput(ip);
    800059b8:	8526                	mv	a0,s1
    800059ba:	ffffe097          	auipc	ra,0xffffe
    800059be:	fa2080e7          	jalr	-94(ra) # 8000395c <iunlockput>
    end_op();
    800059c2:	ffffe097          	auipc	ra,0xffffe
    800059c6:	774080e7          	jalr	1908(ra) # 80004136 <end_op>
    return -1;
    800059ca:	557d                	li	a0,-1
    800059cc:	bfd1                	j	800059a0 <sys_chdir+0x7a>

00000000800059ce <sys_exec>:

uint64
sys_exec(void)
{
    800059ce:	7145                	addi	sp,sp,-464
    800059d0:	e786                	sd	ra,456(sp)
    800059d2:	e3a2                	sd	s0,448(sp)
    800059d4:	ff26                	sd	s1,440(sp)
    800059d6:	fb4a                	sd	s2,432(sp)
    800059d8:	f74e                	sd	s3,424(sp)
    800059da:	f352                	sd	s4,416(sp)
    800059dc:	ef56                	sd	s5,408(sp)
    800059de:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059e0:	08000613          	li	a2,128
    800059e4:	f4040593          	addi	a1,s0,-192
    800059e8:	4501                	li	a0,0
    800059ea:	ffffd097          	auipc	ra,0xffffd
    800059ee:	1da080e7          	jalr	474(ra) # 80002bc4 <argstr>
    return -1;
    800059f2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059f4:	0c054a63          	bltz	a0,80005ac8 <sys_exec+0xfa>
    800059f8:	e3840593          	addi	a1,s0,-456
    800059fc:	4505                	li	a0,1
    800059fe:	ffffd097          	auipc	ra,0xffffd
    80005a02:	1a4080e7          	jalr	420(ra) # 80002ba2 <argaddr>
    80005a06:	0c054163          	bltz	a0,80005ac8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005a0a:	10000613          	li	a2,256
    80005a0e:	4581                	li	a1,0
    80005a10:	e4040513          	addi	a0,s0,-448
    80005a14:	ffffb097          	auipc	ra,0xffffb
    80005a18:	35c080e7          	jalr	860(ra) # 80000d70 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a1c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a20:	89a6                	mv	s3,s1
    80005a22:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a24:	02000a13          	li	s4,32
    80005a28:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a2c:	00391513          	slli	a0,s2,0x3
    80005a30:	e3040593          	addi	a1,s0,-464
    80005a34:	e3843783          	ld	a5,-456(s0)
    80005a38:	953e                	add	a0,a0,a5
    80005a3a:	ffffd097          	auipc	ra,0xffffd
    80005a3e:	0ac080e7          	jalr	172(ra) # 80002ae6 <fetchaddr>
    80005a42:	02054a63          	bltz	a0,80005a76 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005a46:	e3043783          	ld	a5,-464(s0)
    80005a4a:	c3b9                	beqz	a5,80005a90 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a4c:	ffffb097          	auipc	ra,0xffffb
    80005a50:	138080e7          	jalr	312(ra) # 80000b84 <kalloc>
    80005a54:	85aa                	mv	a1,a0
    80005a56:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a5a:	cd11                	beqz	a0,80005a76 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a5c:	6605                	lui	a2,0x1
    80005a5e:	e3043503          	ld	a0,-464(s0)
    80005a62:	ffffd097          	auipc	ra,0xffffd
    80005a66:	0d6080e7          	jalr	214(ra) # 80002b38 <fetchstr>
    80005a6a:	00054663          	bltz	a0,80005a76 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005a6e:	0905                	addi	s2,s2,1
    80005a70:	09a1                	addi	s3,s3,8
    80005a72:	fb491be3          	bne	s2,s4,80005a28 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a76:	10048913          	addi	s2,s1,256
    80005a7a:	6088                	ld	a0,0(s1)
    80005a7c:	c529                	beqz	a0,80005ac6 <sys_exec+0xf8>
    kfree(argv[i]);
    80005a7e:	ffffb097          	auipc	ra,0xffffb
    80005a82:	00a080e7          	jalr	10(ra) # 80000a88 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a86:	04a1                	addi	s1,s1,8
    80005a88:	ff2499e3          	bne	s1,s2,80005a7a <sys_exec+0xac>
  return -1;
    80005a8c:	597d                	li	s2,-1
    80005a8e:	a82d                	j	80005ac8 <sys_exec+0xfa>
      argv[i] = 0;
    80005a90:	0a8e                	slli	s5,s5,0x3
    80005a92:	fc040793          	addi	a5,s0,-64
    80005a96:	9abe                	add	s5,s5,a5
    80005a98:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a9c:	e4040593          	addi	a1,s0,-448
    80005aa0:	f4040513          	addi	a0,s0,-192
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	194080e7          	jalr	404(ra) # 80004c38 <exec>
    80005aac:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aae:	10048993          	addi	s3,s1,256
    80005ab2:	6088                	ld	a0,0(s1)
    80005ab4:	c911                	beqz	a0,80005ac8 <sys_exec+0xfa>
    kfree(argv[i]);
    80005ab6:	ffffb097          	auipc	ra,0xffffb
    80005aba:	fd2080e7          	jalr	-46(ra) # 80000a88 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005abe:	04a1                	addi	s1,s1,8
    80005ac0:	ff3499e3          	bne	s1,s3,80005ab2 <sys_exec+0xe4>
    80005ac4:	a011                	j	80005ac8 <sys_exec+0xfa>
  return -1;
    80005ac6:	597d                	li	s2,-1
}
    80005ac8:	854a                	mv	a0,s2
    80005aca:	60be                	ld	ra,456(sp)
    80005acc:	641e                	ld	s0,448(sp)
    80005ace:	74fa                	ld	s1,440(sp)
    80005ad0:	795a                	ld	s2,432(sp)
    80005ad2:	79ba                	ld	s3,424(sp)
    80005ad4:	7a1a                	ld	s4,416(sp)
    80005ad6:	6afa                	ld	s5,408(sp)
    80005ad8:	6179                	addi	sp,sp,464
    80005ada:	8082                	ret

0000000080005adc <sys_pipe>:

uint64
sys_pipe(void)
{
    80005adc:	7139                	addi	sp,sp,-64
    80005ade:	fc06                	sd	ra,56(sp)
    80005ae0:	f822                	sd	s0,48(sp)
    80005ae2:	f426                	sd	s1,40(sp)
    80005ae4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ae6:	ffffc097          	auipc	ra,0xffffc
    80005aea:	f5c080e7          	jalr	-164(ra) # 80001a42 <myproc>
    80005aee:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005af0:	fd840593          	addi	a1,s0,-40
    80005af4:	4501                	li	a0,0
    80005af6:	ffffd097          	auipc	ra,0xffffd
    80005afa:	0ac080e7          	jalr	172(ra) # 80002ba2 <argaddr>
    return -1;
    80005afe:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b00:	0e054063          	bltz	a0,80005be0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b04:	fc840593          	addi	a1,s0,-56
    80005b08:	fd040513          	addi	a0,s0,-48
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	dd2080e7          	jalr	-558(ra) # 800048de <pipealloc>
    return -1;
    80005b14:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b16:	0c054563          	bltz	a0,80005be0 <sys_pipe+0x104>
  fd0 = -1;
    80005b1a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b1e:	fd043503          	ld	a0,-48(s0)
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	508080e7          	jalr	1288(ra) # 8000502a <fdalloc>
    80005b2a:	fca42223          	sw	a0,-60(s0)
    80005b2e:	08054c63          	bltz	a0,80005bc6 <sys_pipe+0xea>
    80005b32:	fc843503          	ld	a0,-56(s0)
    80005b36:	fffff097          	auipc	ra,0xfffff
    80005b3a:	4f4080e7          	jalr	1268(ra) # 8000502a <fdalloc>
    80005b3e:	fca42023          	sw	a0,-64(s0)
    80005b42:	06054863          	bltz	a0,80005bb2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b46:	4691                	li	a3,4
    80005b48:	fc440613          	addi	a2,s0,-60
    80005b4c:	fd843583          	ld	a1,-40(s0)
    80005b50:	68a8                	ld	a0,80(s1)
    80005b52:	ffffc097          	auipc	ra,0xffffc
    80005b56:	be4080e7          	jalr	-1052(ra) # 80001736 <copyout>
    80005b5a:	02054063          	bltz	a0,80005b7a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b5e:	4691                	li	a3,4
    80005b60:	fc040613          	addi	a2,s0,-64
    80005b64:	fd843583          	ld	a1,-40(s0)
    80005b68:	0591                	addi	a1,a1,4
    80005b6a:	68a8                	ld	a0,80(s1)
    80005b6c:	ffffc097          	auipc	ra,0xffffc
    80005b70:	bca080e7          	jalr	-1078(ra) # 80001736 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b74:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b76:	06055563          	bgez	a0,80005be0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005b7a:	fc442783          	lw	a5,-60(s0)
    80005b7e:	07e9                	addi	a5,a5,26
    80005b80:	078e                	slli	a5,a5,0x3
    80005b82:	97a6                	add	a5,a5,s1
    80005b84:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b88:	fc042503          	lw	a0,-64(s0)
    80005b8c:	0569                	addi	a0,a0,26
    80005b8e:	050e                	slli	a0,a0,0x3
    80005b90:	9526                	add	a0,a0,s1
    80005b92:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b96:	fd043503          	ld	a0,-48(s0)
    80005b9a:	fffff097          	auipc	ra,0xfffff
    80005b9e:	9ee080e7          	jalr	-1554(ra) # 80004588 <fileclose>
    fileclose(wf);
    80005ba2:	fc843503          	ld	a0,-56(s0)
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	9e2080e7          	jalr	-1566(ra) # 80004588 <fileclose>
    return -1;
    80005bae:	57fd                	li	a5,-1
    80005bb0:	a805                	j	80005be0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005bb2:	fc442783          	lw	a5,-60(s0)
    80005bb6:	0007c863          	bltz	a5,80005bc6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005bba:	01a78513          	addi	a0,a5,26
    80005bbe:	050e                	slli	a0,a0,0x3
    80005bc0:	9526                	add	a0,a0,s1
    80005bc2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005bc6:	fd043503          	ld	a0,-48(s0)
    80005bca:	fffff097          	auipc	ra,0xfffff
    80005bce:	9be080e7          	jalr	-1602(ra) # 80004588 <fileclose>
    fileclose(wf);
    80005bd2:	fc843503          	ld	a0,-56(s0)
    80005bd6:	fffff097          	auipc	ra,0xfffff
    80005bda:	9b2080e7          	jalr	-1614(ra) # 80004588 <fileclose>
    return -1;
    80005bde:	57fd                	li	a5,-1
}
    80005be0:	853e                	mv	a0,a5
    80005be2:	70e2                	ld	ra,56(sp)
    80005be4:	7442                	ld	s0,48(sp)
    80005be6:	74a2                	ld	s1,40(sp)
    80005be8:	6121                	addi	sp,sp,64
    80005bea:	8082                	ret

0000000080005bec <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80005bec:	1101                	addi	sp,sp,-32
    80005bee:	ec06                	sd	ra,24(sp)
    80005bf0:	e822                	sd	s0,16(sp)
    80005bf2:	1000                	addi	s0,sp,32
  int ticks;
  uint64 handler;
  if(argint(0, &ticks) < 0)
    80005bf4:	fec40593          	addi	a1,s0,-20
    80005bf8:	4501                	li	a0,0
    80005bfa:	ffffd097          	auipc	ra,0xffffd
    80005bfe:	f86080e7          	jalr	-122(ra) # 80002b80 <argint>
    return -1;
    80005c02:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80005c04:	02054d63          	bltz	a0,80005c3e <sys_sigalarm+0x52>
  if(argaddr(1, &handler) < 0)
    80005c08:	fe040593          	addi	a1,s0,-32
    80005c0c:	4505                	li	a0,1
    80005c0e:	ffffd097          	auipc	ra,0xffffd
    80005c12:	f94080e7          	jalr	-108(ra) # 80002ba2 <argaddr>
    return -1;
    80005c16:	57fd                	li	a5,-1
  if(argaddr(1, &handler) < 0)
    80005c18:	02054363          	bltz	a0,80005c3e <sys_sigalarm+0x52>
  
  struct proc* p = myproc();
    80005c1c:	ffffc097          	auipc	ra,0xffffc
    80005c20:	e26080e7          	jalr	-474(ra) # 80001a42 <myproc>
  p->alarm = ticks;
    80005c24:	fec42783          	lw	a5,-20(s0)
    80005c28:	16f52623          	sw	a5,364(a0)
  p->handler = handler;
    80005c2c:	fe043783          	ld	a5,-32(s0)
    80005c30:	16f53823          	sd	a5,368(a0)
  p->duration = 0;
    80005c34:	16052423          	sw	zero,360(a0)
  p->alarm_trapframe = 0;
    80005c38:	16053c23          	sd	zero,376(a0)
  return 0;
    80005c3c:	4781                	li	a5,0
}
    80005c3e:	853e                	mv	a0,a5
    80005c40:	60e2                	ld	ra,24(sp)
    80005c42:	6442                	ld	s0,16(sp)
    80005c44:	6105                	addi	sp,sp,32
    80005c46:	8082                	ret

0000000080005c48 <sys_sigreturn>:

uint64
sys_sigreturn(void)
{
    80005c48:	1101                	addi	sp,sp,-32
    80005c4a:	ec06                	sd	ra,24(sp)
    80005c4c:	e822                	sd	s0,16(sp)
    80005c4e:	e426                	sd	s1,8(sp)
    80005c50:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    80005c52:	ffffc097          	auipc	ra,0xffffc
    80005c56:	df0080e7          	jalr	-528(ra) # 80001a42 <myproc>
  if(p->alarm_trapframe != 0){
    80005c5a:	17853583          	ld	a1,376(a0)
    80005c5e:	c18d                	beqz	a1,80005c80 <sys_sigreturn+0x38>
    80005c60:	84aa                	mv	s1,a0
    memmove(p->trapframe, p->alarm_trapframe, 512);
    80005c62:	20000613          	li	a2,512
    80005c66:	6d28                	ld	a0,88(a0)
    80005c68:	ffffb097          	auipc	ra,0xffffb
    80005c6c:	168080e7          	jalr	360(ra) # 80000dd0 <memmove>
    kfree(p->alarm_trapframe);
    80005c70:	1784b503          	ld	a0,376(s1)
    80005c74:	ffffb097          	auipc	ra,0xffffb
    80005c78:	e14080e7          	jalr	-492(ra) # 80000a88 <kfree>
    p->alarm_trapframe = 0;
    80005c7c:	1604bc23          	sd	zero,376(s1)
  }
  return 0;
}
    80005c80:	4501                	li	a0,0
    80005c82:	60e2                	ld	ra,24(sp)
    80005c84:	6442                	ld	s0,16(sp)
    80005c86:	64a2                	ld	s1,8(sp)
    80005c88:	6105                	addi	sp,sp,32
    80005c8a:	8082                	ret
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
    80005cd0:	ce3fc0ef          	jal	ra,800029b2 <kerneltrap>
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
    80005d6c:	cae080e7          	jalr	-850(ra) # 80001a16 <cpuid>
  
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
    80005da4:	c76080e7          	jalr	-906(ra) # 80001a16 <cpuid>
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
    80005dcc:	c4e080e7          	jalr	-946(ra) # 80001a16 <cpuid>
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
    80005df4:	0001e797          	auipc	a5,0x1e
    80005df8:	20c78793          	addi	a5,a5,524 # 80024000 <disk>
    80005dfc:	00a78733          	add	a4,a5,a0
    80005e00:	6789                	lui	a5,0x2
    80005e02:	97ba                	add	a5,a5,a4
    80005e04:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e08:	eba1                	bnez	a5,80005e58 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005e0a:	00451713          	slli	a4,a0,0x4
    80005e0e:	00020797          	auipc	a5,0x20
    80005e12:	1f27b783          	ld	a5,498(a5) # 80026000 <disk+0x2000>
    80005e16:	97ba                	add	a5,a5,a4
    80005e18:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005e1c:	0001e797          	auipc	a5,0x1e
    80005e20:	1e478793          	addi	a5,a5,484 # 80024000 <disk>
    80005e24:	97aa                	add	a5,a5,a0
    80005e26:	6509                	lui	a0,0x2
    80005e28:	953e                	add	a0,a0,a5
    80005e2a:	4785                	li	a5,1
    80005e2c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e30:	00020517          	auipc	a0,0x20
    80005e34:	1e850513          	addi	a0,a0,488 # 80026018 <disk+0x2018>
    80005e38:	ffffc097          	auipc	ra,0xffffc
    80005e3c:	5c6080e7          	jalr	1478(ra) # 800023fe <wakeup>
}
    80005e40:	60a2                	ld	ra,8(sp)
    80005e42:	6402                	ld	s0,0(sp)
    80005e44:	0141                	addi	sp,sp,16
    80005e46:	8082                	ret
    panic("virtio_disk_intr 1");
    80005e48:	00003517          	auipc	a0,0x3
    80005e4c:	93850513          	addi	a0,a0,-1736 # 80008780 <syscalls+0x340>
    80005e50:	ffffa097          	auipc	ra,0xffffa
    80005e54:	786080e7          	jalr	1926(ra) # 800005d6 <panic>
    panic("virtio_disk_intr 2");
    80005e58:	00003517          	auipc	a0,0x3
    80005e5c:	94050513          	addi	a0,a0,-1728 # 80008798 <syscalls+0x358>
    80005e60:	ffffa097          	auipc	ra,0xffffa
    80005e64:	776080e7          	jalr	1910(ra) # 800005d6 <panic>

0000000080005e68 <virtio_disk_init>:
{
    80005e68:	1101                	addi	sp,sp,-32
    80005e6a:	ec06                	sd	ra,24(sp)
    80005e6c:	e822                	sd	s0,16(sp)
    80005e6e:	e426                	sd	s1,8(sp)
    80005e70:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e72:	00003597          	auipc	a1,0x3
    80005e76:	93e58593          	addi	a1,a1,-1730 # 800087b0 <syscalls+0x370>
    80005e7a:	00020517          	auipc	a0,0x20
    80005e7e:	22e50513          	addi	a0,a0,558 # 800260a8 <disk+0x20a8>
    80005e82:	ffffb097          	auipc	ra,0xffffb
    80005e86:	d62080e7          	jalr	-670(ra) # 80000be4 <initlock>
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
    80005ee0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
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
    80005f12:	0001e517          	auipc	a0,0x1e
    80005f16:	0ee50513          	addi	a0,a0,238 # 80024000 <disk>
    80005f1a:	ffffb097          	auipc	ra,0xffffb
    80005f1e:	e56080e7          	jalr	-426(ra) # 80000d70 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005f22:	0001e717          	auipc	a4,0x1e
    80005f26:	0de70713          	addi	a4,a4,222 # 80024000 <disk>
    80005f2a:	00c75793          	srli	a5,a4,0xc
    80005f2e:	2781                	sext.w	a5,a5
    80005f30:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005f32:	00020797          	auipc	a5,0x20
    80005f36:	0ce78793          	addi	a5,a5,206 # 80026000 <disk+0x2000>
    80005f3a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005f3c:	0001e717          	auipc	a4,0x1e
    80005f40:	14470713          	addi	a4,a4,324 # 80024080 <disk+0x80>
    80005f44:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005f46:	0001f717          	auipc	a4,0x1f
    80005f4a:	0ba70713          	addi	a4,a4,186 # 80025000 <disk+0x1000>
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
    80005f7c:	00003517          	auipc	a0,0x3
    80005f80:	84450513          	addi	a0,a0,-1980 # 800087c0 <syscalls+0x380>
    80005f84:	ffffa097          	auipc	ra,0xffffa
    80005f88:	652080e7          	jalr	1618(ra) # 800005d6 <panic>
    panic("virtio disk has no queue 0");
    80005f8c:	00003517          	auipc	a0,0x3
    80005f90:	85450513          	addi	a0,a0,-1964 # 800087e0 <syscalls+0x3a0>
    80005f94:	ffffa097          	auipc	ra,0xffffa
    80005f98:	642080e7          	jalr	1602(ra) # 800005d6 <panic>
    panic("virtio disk max queue too short");
    80005f9c:	00003517          	auipc	a0,0x3
    80005fa0:	86450513          	addi	a0,a0,-1948 # 80008800 <syscalls+0x3c0>
    80005fa4:	ffffa097          	auipc	ra,0xffffa
    80005fa8:	632080e7          	jalr	1586(ra) # 800005d6 <panic>

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
    80005fda:	00020517          	auipc	a0,0x20
    80005fde:	0ce50513          	addi	a0,a0,206 # 800260a8 <disk+0x20a8>
    80005fe2:	ffffb097          	auipc	ra,0xffffb
    80005fe6:	c92080e7          	jalr	-878(ra) # 80000c74 <acquire>
  for(int i = 0; i < 3; i++){
    80005fea:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fec:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005fee:	0001eb97          	auipc	s7,0x1e
    80005ff2:	012b8b93          	addi	s7,s7,18 # 80024000 <disk>
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
    80006018:	00020697          	auipc	a3,0x20
    8000601c:	00068693          	mv	a3,a3
    80006020:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006022:	0006c583          	lbu	a1,0(a3) # 80026018 <disk+0x2018>
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
    80006068:	00020597          	auipc	a1,0x20
    8000606c:	04058593          	addi	a1,a1,64 # 800260a8 <disk+0x20a8>
    80006070:	00020517          	auipc	a0,0x20
    80006074:	fa850513          	addi	a0,a0,-88 # 80026018 <disk+0x2018>
    80006078:	ffffc097          	auipc	ra,0xffffc
    8000607c:	200080e7          	jalr	512(ra) # 80002278 <sleep>
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
    8000609e:	00020a17          	auipc	s4,0x20
    800060a2:	f62a0a13          	addi	s4,s4,-158 # 80026000 <disk+0x2000>
    800060a6:	000a3a83          	ld	s5,0(s4)
    800060aa:	9aa6                	add	s5,s5,s1
    800060ac:	f8040513          	addi	a0,s0,-128
    800060b0:	ffffb097          	auipc	ra,0xffffb
    800060b4:	094080e7          	jalr	148(ra) # 80001144 <kvmpa>
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
    800060fe:	00020797          	auipc	a5,0x20
    80006102:	f027b783          	ld	a5,-254(a5) # 80026000 <disk+0x2000>
    80006106:	97ba                	add	a5,a5,a4
    80006108:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000610c:	0001e517          	auipc	a0,0x1e
    80006110:	ef450513          	addi	a0,a0,-268 # 80024000 <disk>
    80006114:	00020797          	auipc	a5,0x20
    80006118:	eec78793          	addi	a5,a5,-276 # 80026000 <disk+0x2000>
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
    800061ae:	00020997          	auipc	s3,0x20
    800061b2:	efa98993          	addi	s3,s3,-262 # 800260a8 <disk+0x20a8>
  while(b->disk == 1) {
    800061b6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800061b8:	85ce                	mv	a1,s3
    800061ba:	854a                	mv	a0,s2
    800061bc:	ffffc097          	auipc	ra,0xffffc
    800061c0:	0bc080e7          	jalr	188(ra) # 80002278 <sleep>
  while(b->disk == 1) {
    800061c4:	00492783          	lw	a5,4(s2)
    800061c8:	fe9788e3          	beq	a5,s1,800061b8 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    800061cc:	f9042483          	lw	s1,-112(s0)
    800061d0:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    800061d4:	00479713          	slli	a4,a5,0x4
    800061d8:	0001e797          	auipc	a5,0x1e
    800061dc:	e2878793          	addi	a5,a5,-472 # 80024000 <disk>
    800061e0:	97ba                	add	a5,a5,a4
    800061e2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061e6:	00020917          	auipc	s2,0x20
    800061ea:	e1a90913          	addi	s2,s2,-486 # 80026000 <disk+0x2000>
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
    8000620e:	00020797          	auipc	a5,0x20
    80006212:	df27b783          	ld	a5,-526(a5) # 80026000 <disk+0x2000>
    80006216:	97ba                	add	a5,a5,a4
    80006218:	4689                	li	a3,2
    8000621a:	00d79623          	sh	a3,12(a5)
    8000621e:	b5fd                	j	8000610c <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006220:	00020517          	auipc	a0,0x20
    80006224:	e8850513          	addi	a0,a0,-376 # 800260a8 <disk+0x20a8>
    80006228:	ffffb097          	auipc	ra,0xffffb
    8000622c:	b00080e7          	jalr	-1280(ra) # 80000d28 <release>
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
    80006262:	00020517          	auipc	a0,0x20
    80006266:	e4650513          	addi	a0,a0,-442 # 800260a8 <disk+0x20a8>
    8000626a:	ffffb097          	auipc	ra,0xffffb
    8000626e:	a0a080e7          	jalr	-1526(ra) # 80000c74 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006272:	00020717          	auipc	a4,0x20
    80006276:	d8e70713          	addi	a4,a4,-626 # 80026000 <disk+0x2000>
    8000627a:	02075783          	lhu	a5,32(a4)
    8000627e:	6b18                	ld	a4,16(a4)
    80006280:	00275683          	lhu	a3,2(a4)
    80006284:	8ebd                	xor	a3,a3,a5
    80006286:	8a9d                	andi	a3,a3,7
    80006288:	cab9                	beqz	a3,800062de <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000628a:	0001e917          	auipc	s2,0x1e
    8000628e:	d7690913          	addi	s2,s2,-650 # 80024000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006292:	00020497          	auipc	s1,0x20
    80006296:	d6e48493          	addi	s1,s1,-658 # 80026000 <disk+0x2000>
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
    800062c2:	140080e7          	jalr	320(ra) # 800023fe <wakeup>
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
    800062e8:	00020517          	auipc	a0,0x20
    800062ec:	dc050513          	addi	a0,a0,-576 # 800260a8 <disk+0x20a8>
    800062f0:	ffffb097          	auipc	ra,0xffffb
    800062f4:	a38080e7          	jalr	-1480(ra) # 80000d28 <release>
}
    800062f8:	60e2                	ld	ra,24(sp)
    800062fa:	6442                	ld	s0,16(sp)
    800062fc:	64a2                	ld	s1,8(sp)
    800062fe:	6902                	ld	s2,0(sp)
    80006300:	6105                	addi	sp,sp,32
    80006302:	8082                	ret
      panic("virtio_disk_intr status");
    80006304:	00002517          	auipc	a0,0x2
    80006308:	51c50513          	addi	a0,a0,1308 # 80008820 <syscalls+0x3e0>
    8000630c:	ffffa097          	auipc	ra,0xffffa
    80006310:	2ca080e7          	jalr	714(ra) # 800005d6 <panic>
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
