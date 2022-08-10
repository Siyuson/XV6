
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
    80000060:	eb478793          	addi	a5,a5,-332 # 80005f10 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77df>
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
    8000012a:	6b4080e7          	jalr	1716(ra) # 800027da <either_copyin>
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
    800001e2:	344080e7          	jalr	836(ra) # 80002522 <sleep>
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
    8000021e:	56a080e7          	jalr	1386(ra) # 80002784 <either_copyout>
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
    80000300:	534080e7          	jalr	1332(ra) # 80002830 <procdump>
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
    80000454:	258080e7          	jalr	600(ra) # 800026a8 <wakeup>
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
    80000486:	72e78793          	addi	a5,a5,1838 # 80021bb0 <devsw>
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
    800008ba:	df2080e7          	jalr	-526(ra) # 800026a8 <wakeup>
    
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
    80000954:	bd2080e7          	jalr	-1070(ra) # 80002522 <sleep>
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
    80000a38:	00026797          	auipc	a5,0x26
    80000a3c:	5e878793          	addi	a5,a5,1512 # 80027020 <end>
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
    80000b08:	00026517          	auipc	a0,0x26
    80000b0c:	51850513          	addi	a0,a0,1304 # 80027020 <end>
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
#endif    
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
    80000f00:	1f2080e7          	jalr	498(ra) # 800010ee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f04:	00002097          	auipc	ra,0x2
    80000f08:	a6c080e7          	jalr	-1428(ra) # 80002970 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f0c:	00005097          	auipc	ra,0x5
    80000f10:	044080e7          	jalr	68(ra) # 80005f50 <plicinithart>
  }

  scheduler();        
    80000f14:	00001097          	auipc	ra,0x1
    80000f18:	316080e7          	jalr	790(ra) # 8000222a <scheduler>
    consoleinit();
    80000f1c:	fffff097          	auipc	ra,0xfffff
    80000f20:	53e080e7          	jalr	1342(ra) # 8000045a <consoleinit>
    statsinit();
    80000f24:	00005097          	auipc	ra,0x5
    80000f28:	7ee080e7          	jalr	2030(ra) # 80006712 <statsinit>
    printfinit();
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	84c080e7          	jalr	-1972(ra) # 80000778 <printfinit>
    printf("\n");
    80000f34:	00007517          	auipc	a0,0x7
    80000f38:	19450513          	addi	a0,a0,404 # 800080c8 <digits+0x88>
    80000f3c:	fffff097          	auipc	ra,0xfffff
    80000f40:	656080e7          	jalr	1622(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000f44:	00007517          	auipc	a0,0x7
    80000f48:	15c50513          	addi	a0,a0,348 # 800080a0 <digits+0x60>
    80000f4c:	fffff097          	auipc	ra,0xfffff
    80000f50:	646080e7          	jalr	1606(ra) # 80000592 <printf>
    printf("\n");
    80000f54:	00007517          	auipc	a0,0x7
    80000f58:	17450513          	addi	a0,a0,372 # 800080c8 <digits+0x88>
    80000f5c:	fffff097          	auipc	ra,0xfffff
    80000f60:	636080e7          	jalr	1590(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	b80080e7          	jalr	-1152(ra) # 80000ae4 <kinit>
    kvminit();       // create kernel page table
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	488080e7          	jalr	1160(ra) # 800013f4 <kvminit>
    kvminithart();   // turn on paging
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	17a080e7          	jalr	378(ra) # 800010ee <kvminithart>
    procinit();      // process table
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	b0a080e7          	jalr	-1270(ra) # 80001a86 <procinit>
    trapinit();      // trap vectors
    80000f84:	00002097          	auipc	ra,0x2
    80000f88:	9c4080e7          	jalr	-1596(ra) # 80002948 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f8c:	00002097          	auipc	ra,0x2
    80000f90:	9e4080e7          	jalr	-1564(ra) # 80002970 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f94:	00005097          	auipc	ra,0x5
    80000f98:	fa6080e7          	jalr	-90(ra) # 80005f3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f9c:	00005097          	auipc	ra,0x5
    80000fa0:	fb4080e7          	jalr	-76(ra) # 80005f50 <plicinithart>
    binit();         // buffer cache
    80000fa4:	00002097          	auipc	ra,0x2
    80000fa8:	10e080e7          	jalr	270(ra) # 800030b2 <binit>
    iinit();         // inode cache
    80000fac:	00002097          	auipc	ra,0x2
    80000fb0:	79e080e7          	jalr	1950(ra) # 8000374a <iinit>
    fileinit();      // file table
    80000fb4:	00003097          	auipc	ra,0x3
    80000fb8:	738080e7          	jalr	1848(ra) # 800046ec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fbc:	00005097          	auipc	ra,0x5
    80000fc0:	09c080e7          	jalr	156(ra) # 80006058 <virtio_disk_init>
    userinit();      // first user process
    80000fc4:	00001097          	auipc	ra,0x1
    80000fc8:	f76080e7          	jalr	-138(ra) # 80001f3a <userinit>
    __sync_synchronize();
    80000fcc:	0ff0000f          	fence
    started = 1;
    80000fd0:	4785                	li	a5,1
    80000fd2:	00008717          	auipc	a4,0x8
    80000fd6:	02f72d23          	sw	a5,58(a4) # 8000900c <started>
    80000fda:	bf2d                	j	80000f14 <main+0x56>

0000000080000fdc <dotprinter>:

/*
 * create a direct-map page table for the kernel.
 */

void dotprinter(int level, int indexid) {
    80000fdc:	7179                	addi	sp,sp,-48
    80000fde:	f406                	sd	ra,40(sp)
    80000fe0:	f022                	sd	s0,32(sp)
    80000fe2:	ec26                	sd	s1,24(sp)
    80000fe4:	e84a                	sd	s2,16(sp)
    80000fe6:	e44e                	sd	s3,8(sp)
    80000fe8:	1800                	addi	s0,sp,48
    int dotcnt = 3 - level;
    for (int j = 0; j < dotcnt - 1; j++) {
    80000fea:	4909                	li	s2,2
    80000fec:	40a9093b          	subw	s2,s2,a0
    80000ff0:	01205f63          	blez	s2,8000100e <dotprinter+0x32>
    80000ff4:	4481                	li	s1,0
        printf(".. ");
    80000ff6:	00007997          	auipc	s3,0x7
    80000ffa:	0da98993          	addi	s3,s3,218 # 800080d0 <digits+0x90>
    80000ffe:	854e                	mv	a0,s3
    80001000:	fffff097          	auipc	ra,0xfffff
    80001004:	592080e7          	jalr	1426(ra) # 80000592 <printf>
    for (int j = 0; j < dotcnt - 1; j++) {
    80001008:	2485                	addiw	s1,s1,1
    8000100a:	ff249ae3          	bne	s1,s2,80000ffe <dotprinter+0x22>
    }
    printf("..%d: ");
    8000100e:	00007517          	auipc	a0,0x7
    80001012:	0ca50513          	addi	a0,a0,202 # 800080d8 <digits+0x98>
    80001016:	fffff097          	auipc	ra,0xfffff
    8000101a:	57c080e7          	jalr	1404(ra) # 80000592 <printf>
}
    8000101e:	70a2                	ld	ra,40(sp)
    80001020:	7402                	ld	s0,32(sp)
    80001022:	64e2                	ld	s1,24(sp)
    80001024:	6942                	ld	s2,16(sp)
    80001026:	69a2                	ld	s3,8(sp)
    80001028:	6145                	addi	sp,sp,48
    8000102a:	8082                	ret

000000008000102c <vmprinthelper>:

void vmprinthelper(pagetable_t pagetable, int level) {
    if (level < 0) {
    8000102c:	0805c663          	bltz	a1,800010b8 <vmprinthelper+0x8c>
void vmprinthelper(pagetable_t pagetable, int level) {
    80001030:	715d                	addi	sp,sp,-80
    80001032:	e486                	sd	ra,72(sp)
    80001034:	e0a2                	sd	s0,64(sp)
    80001036:	fc26                	sd	s1,56(sp)
    80001038:	f84a                	sd	s2,48(sp)
    8000103a:	f44e                	sd	s3,40(sp)
    8000103c:	f052                	sd	s4,32(sp)
    8000103e:	ec56                	sd	s5,24(sp)
    80001040:	e85a                	sd	s6,16(sp)
    80001042:	e45e                	sd	s7,8(sp)
    80001044:	e062                	sd	s8,0(sp)
    80001046:	0880                	addi	s0,sp,80
    80001048:	8b2e                	mv	s6,a1
    8000104a:	892a                	mv	s2,a0
        return;
    }

    for (int i = 0; i < 512; i++) {
    8000104c:	4481                	li	s1,0
        pte_t pte = pagetable[i];
        if ((pte & PTE_V) == 0) // invalid pte
            continue;
        dotprinter(level, i);
        // printf(" pte %p pa %p useraccessable: %d \n", pte, PTE2PA(pte), (pte & PTE_U));
        printf("pte %p pa %p\n", pte, PTE2PA(pte));
    8000104e:	00007c17          	auipc	s8,0x7
    80001052:	092c0c13          	addi	s8,s8,146 # 800080e0 <digits+0xa0>
        vmprinthelper((pagetable_t)PTE2PA(pte), level - 1);
    80001056:	fff58b9b          	addiw	s7,a1,-1
    for (int i = 0; i < 512; i++) {
    8000105a:	20000a93          	li	s5,512
    8000105e:	a029                	j	80001068 <vmprinthelper+0x3c>
    80001060:	2485                	addiw	s1,s1,1
    80001062:	0921                	addi	s2,s2,8
    80001064:	03548e63          	beq	s1,s5,800010a0 <vmprinthelper+0x74>
        pte_t pte = pagetable[i];
    80001068:	00093983          	ld	s3,0(s2)
        if ((pte & PTE_V) == 0) // invalid pte
    8000106c:	0019f793          	andi	a5,s3,1
    80001070:	dbe5                	beqz	a5,80001060 <vmprinthelper+0x34>
        dotprinter(level, i);
    80001072:	85a6                	mv	a1,s1
    80001074:	855a                	mv	a0,s6
    80001076:	00000097          	auipc	ra,0x0
    8000107a:	f66080e7          	jalr	-154(ra) # 80000fdc <dotprinter>
        printf("pte %p pa %p\n", pte, PTE2PA(pte));
    8000107e:	00a9da13          	srli	s4,s3,0xa
    80001082:	0a32                	slli	s4,s4,0xc
    80001084:	8652                	mv	a2,s4
    80001086:	85ce                	mv	a1,s3
    80001088:	8562                	mv	a0,s8
    8000108a:	fffff097          	auipc	ra,0xfffff
    8000108e:	508080e7          	jalr	1288(ra) # 80000592 <printf>
        vmprinthelper((pagetable_t)PTE2PA(pte), level - 1);
    80001092:	85de                	mv	a1,s7
    80001094:	8552                	mv	a0,s4
    80001096:	00000097          	auipc	ra,0x0
    8000109a:	f96080e7          	jalr	-106(ra) # 8000102c <vmprinthelper>
    8000109e:	b7c9                	j	80001060 <vmprinthelper+0x34>
    }
}
    800010a0:	60a6                	ld	ra,72(sp)
    800010a2:	6406                	ld	s0,64(sp)
    800010a4:	74e2                	ld	s1,56(sp)
    800010a6:	7942                	ld	s2,48(sp)
    800010a8:	79a2                	ld	s3,40(sp)
    800010aa:	7a02                	ld	s4,32(sp)
    800010ac:	6ae2                	ld	s5,24(sp)
    800010ae:	6b42                	ld	s6,16(sp)
    800010b0:	6ba2                	ld	s7,8(sp)
    800010b2:	6c02                	ld	s8,0(sp)
    800010b4:	6161                	addi	sp,sp,80
    800010b6:	8082                	ret
    800010b8:	8082                	ret

00000000800010ba <vmprint>:

void
vmprint(pagetable_t  pagetable)
{
    800010ba:	1101                	addi	sp,sp,-32
    800010bc:	ec06                	sd	ra,24(sp)
    800010be:	e822                	sd	s0,16(sp)
    800010c0:	e426                	sd	s1,8(sp)
    800010c2:	1000                	addi	s0,sp,32
    800010c4:	84aa                	mv	s1,a0
    printf("page table %p\n", pagetable);
    800010c6:	85aa                	mv	a1,a0
    800010c8:	00007517          	auipc	a0,0x7
    800010cc:	02850513          	addi	a0,a0,40 # 800080f0 <digits+0xb0>
    800010d0:	fffff097          	auipc	ra,0xfffff
    800010d4:	4c2080e7          	jalr	1218(ra) # 80000592 <printf>
    vmprinthelper(pagetable, 2);
    800010d8:	4589                	li	a1,2
    800010da:	8526                	mv	a0,s1
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	f50080e7          	jalr	-176(ra) # 8000102c <vmprinthelper>
}
    800010e4:	60e2                	ld	ra,24(sp)
    800010e6:	6442                	ld	s0,16(sp)
    800010e8:	64a2                	ld	s1,8(sp)
    800010ea:	6105                	addi	sp,sp,32
    800010ec:	8082                	ret

00000000800010ee <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010ee:	1141                	addi	sp,sp,-16
    800010f0:	e422                	sd	s0,8(sp)
    800010f2:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    800010f4:	00008797          	auipc	a5,0x8
    800010f8:	f1c7b783          	ld	a5,-228(a5) # 80009010 <kernel_pagetable>
    800010fc:	83b1                	srli	a5,a5,0xc
    800010fe:	577d                	li	a4,-1
    80001100:	177e                	slli	a4,a4,0x3f
    80001102:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001104:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001108:	12000073          	sfence.vma
  sfence_vma();
}
    8000110c:	6422                	ld	s0,8(sp)
    8000110e:	0141                	addi	sp,sp,16
    80001110:	8082                	ret

0000000080001112 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001112:	7139                	addi	sp,sp,-64
    80001114:	fc06                	sd	ra,56(sp)
    80001116:	f822                	sd	s0,48(sp)
    80001118:	f426                	sd	s1,40(sp)
    8000111a:	f04a                	sd	s2,32(sp)
    8000111c:	ec4e                	sd	s3,24(sp)
    8000111e:	e852                	sd	s4,16(sp)
    80001120:	e456                	sd	s5,8(sp)
    80001122:	e05a                	sd	s6,0(sp)
    80001124:	0080                	addi	s0,sp,64
    80001126:	84aa                	mv	s1,a0
    80001128:	89ae                	mv	s3,a1
    8000112a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000112c:	57fd                	li	a5,-1
    8000112e:	83e9                	srli	a5,a5,0x1a
    80001130:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001132:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001134:	04b7f263          	bgeu	a5,a1,80001178 <walk+0x66>
    panic("walk");
    80001138:	00007517          	auipc	a0,0x7
    8000113c:	fc850513          	addi	a0,a0,-56 # 80008100 <digits+0xc0>
    80001140:	fffff097          	auipc	ra,0xfffff
    80001144:	408080e7          	jalr	1032(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001148:	060a8663          	beqz	s5,800011b4 <walk+0xa2>
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	9d4080e7          	jalr	-1580(ra) # 80000b20 <kalloc>
    80001154:	84aa                	mv	s1,a0
    80001156:	c529                	beqz	a0,800011a0 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001158:	6605                	lui	a2,0x1
    8000115a:	4581                	li	a1,0
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	bb0080e7          	jalr	-1104(ra) # 80000d0c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001164:	00c4d793          	srli	a5,s1,0xc
    80001168:	07aa                	slli	a5,a5,0xa
    8000116a:	0017e793          	ori	a5,a5,1
    8000116e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001172:	3a5d                	addiw	s4,s4,-9
    80001174:	036a0063          	beq	s4,s6,80001194 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001178:	0149d933          	srl	s2,s3,s4
    8000117c:	1ff97913          	andi	s2,s2,511
    80001180:	090e                	slli	s2,s2,0x3
    80001182:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001184:	00093483          	ld	s1,0(s2)
    80001188:	0014f793          	andi	a5,s1,1
    8000118c:	dfd5                	beqz	a5,80001148 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000118e:	80a9                	srli	s1,s1,0xa
    80001190:	04b2                	slli	s1,s1,0xc
    80001192:	b7c5                	j	80001172 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001194:	00c9d513          	srli	a0,s3,0xc
    80001198:	1ff57513          	andi	a0,a0,511
    8000119c:	050e                	slli	a0,a0,0x3
    8000119e:	9526                	add	a0,a0,s1
}
    800011a0:	70e2                	ld	ra,56(sp)
    800011a2:	7442                	ld	s0,48(sp)
    800011a4:	74a2                	ld	s1,40(sp)
    800011a6:	7902                	ld	s2,32(sp)
    800011a8:	69e2                	ld	s3,24(sp)
    800011aa:	6a42                	ld	s4,16(sp)
    800011ac:	6aa2                	ld	s5,8(sp)
    800011ae:	6b02                	ld	s6,0(sp)
    800011b0:	6121                	addi	sp,sp,64
    800011b2:	8082                	ret
        return 0;
    800011b4:	4501                	li	a0,0
    800011b6:	b7ed                	j	800011a0 <walk+0x8e>

00000000800011b8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800011b8:	57fd                	li	a5,-1
    800011ba:	83e9                	srli	a5,a5,0x1a
    800011bc:	00b7f463          	bgeu	a5,a1,800011c4 <walkaddr+0xc>
    return 0;
    800011c0:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800011c2:	8082                	ret
{
    800011c4:	1141                	addi	sp,sp,-16
    800011c6:	e406                	sd	ra,8(sp)
    800011c8:	e022                	sd	s0,0(sp)
    800011ca:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011cc:	4601                	li	a2,0
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	f44080e7          	jalr	-188(ra) # 80001112 <walk>
  if(pte == 0)
    800011d6:	c105                	beqz	a0,800011f6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011d8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011da:	0117f693          	andi	a3,a5,17
    800011de:	4745                	li	a4,17
    return 0;
    800011e0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011e2:	00e68663          	beq	a3,a4,800011ee <walkaddr+0x36>
}
    800011e6:	60a2                	ld	ra,8(sp)
    800011e8:	6402                	ld	s0,0(sp)
    800011ea:	0141                	addi	sp,sp,16
    800011ec:	8082                	ret
  pa = PTE2PA(*pte);
    800011ee:	00a7d513          	srli	a0,a5,0xa
    800011f2:	0532                	slli	a0,a0,0xc
  return pa;
    800011f4:	bfcd                	j	800011e6 <walkaddr+0x2e>
    return 0;
    800011f6:	4501                	li	a0,0
    800011f8:	b7fd                	j	800011e6 <walkaddr+0x2e>

00000000800011fa <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800011fa:	1101                	addi	sp,sp,-32
    800011fc:	ec06                	sd	ra,24(sp)
    800011fe:	e822                	sd	s0,16(sp)
    80001200:	e426                	sd	s1,8(sp)
    80001202:	e04a                	sd	s2,0(sp)
    80001204:	1000                	addi	s0,sp,32
    80001206:	84aa                	mv	s1,a0
  uint64 off = va % PGSIZE;
    80001208:	1552                	slli	a0,a0,0x34
    8000120a:	03455913          	srli	s2,a0,0x34
  pte_t *pte;
  uint64 pa;

  // 将walk函数的第一个参数改为进程私有的内核页表  
  struct proc* p = myproc();
    8000120e:	00001097          	auipc	ra,0x1
    80001212:	904080e7          	jalr	-1788(ra) # 80001b12 <myproc>
  pte = walk(p->kernel_pagetable, va, 0);
    80001216:	4601                	li	a2,0
    80001218:	85a6                	mv	a1,s1
    8000121a:	16853503          	ld	a0,360(a0)
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	ef4080e7          	jalr	-268(ra) # 80001112 <walk>
  if(pte == 0)
    80001226:	cd11                	beqz	a0,80001242 <kvmpa+0x48>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001228:	6108                	ld	a0,0(a0)
    8000122a:	00157793          	andi	a5,a0,1
    8000122e:	c395                	beqz	a5,80001252 <kvmpa+0x58>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001230:	8129                	srli	a0,a0,0xa
    80001232:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001234:	954a                	add	a0,a0,s2
    80001236:	60e2                	ld	ra,24(sp)
    80001238:	6442                	ld	s0,16(sp)
    8000123a:	64a2                	ld	s1,8(sp)
    8000123c:	6902                	ld	s2,0(sp)
    8000123e:	6105                	addi	sp,sp,32
    80001240:	8082                	ret
    panic("kvmpa");
    80001242:	00007517          	auipc	a0,0x7
    80001246:	ec650513          	addi	a0,a0,-314 # 80008108 <digits+0xc8>
    8000124a:	fffff097          	auipc	ra,0xfffff
    8000124e:	2fe080e7          	jalr	766(ra) # 80000548 <panic>
    panic("kvmpa");
    80001252:	00007517          	auipc	a0,0x7
    80001256:	eb650513          	addi	a0,a0,-330 # 80008108 <digits+0xc8>
    8000125a:	fffff097          	auipc	ra,0xfffff
    8000125e:	2ee080e7          	jalr	750(ra) # 80000548 <panic>

0000000080001262 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001262:	715d                	addi	sp,sp,-80
    80001264:	e486                	sd	ra,72(sp)
    80001266:	e0a2                	sd	s0,64(sp)
    80001268:	fc26                	sd	s1,56(sp)
    8000126a:	f84a                	sd	s2,48(sp)
    8000126c:	f44e                	sd	s3,40(sp)
    8000126e:	f052                	sd	s4,32(sp)
    80001270:	ec56                	sd	s5,24(sp)
    80001272:	e85a                	sd	s6,16(sp)
    80001274:	e45e                	sd	s7,8(sp)
    80001276:	0880                	addi	s0,sp,80
    80001278:	8aaa                	mv	s5,a0
    8000127a:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000127c:	777d                	lui	a4,0xfffff
    8000127e:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001282:	167d                	addi	a2,a2,-1
    80001284:	00b609b3          	add	s3,a2,a1
    80001288:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000128c:	893e                	mv	s2,a5
    8000128e:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001292:	6b85                	lui	s7,0x1
    80001294:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001298:	4605                	li	a2,1
    8000129a:	85ca                	mv	a1,s2
    8000129c:	8556                	mv	a0,s5
    8000129e:	00000097          	auipc	ra,0x0
    800012a2:	e74080e7          	jalr	-396(ra) # 80001112 <walk>
    800012a6:	c51d                	beqz	a0,800012d4 <mappages+0x72>
    if(*pte & PTE_V)
    800012a8:	611c                	ld	a5,0(a0)
    800012aa:	8b85                	andi	a5,a5,1
    800012ac:	ef81                	bnez	a5,800012c4 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800012ae:	80b1                	srli	s1,s1,0xc
    800012b0:	04aa                	slli	s1,s1,0xa
    800012b2:	0164e4b3          	or	s1,s1,s6
    800012b6:	0014e493          	ori	s1,s1,1
    800012ba:	e104                	sd	s1,0(a0)
    if(a == last)
    800012bc:	03390863          	beq	s2,s3,800012ec <mappages+0x8a>
    a += PGSIZE;
    800012c0:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800012c2:	bfc9                	j	80001294 <mappages+0x32>
      panic("remap");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e4c50513          	addi	a0,a0,-436 # 80008110 <digits+0xd0>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	27c080e7          	jalr	636(ra) # 80000548 <panic>
      return -1;
    800012d4:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800012d6:	60a6                	ld	ra,72(sp)
    800012d8:	6406                	ld	s0,64(sp)
    800012da:	74e2                	ld	s1,56(sp)
    800012dc:	7942                	ld	s2,48(sp)
    800012de:	79a2                	ld	s3,40(sp)
    800012e0:	7a02                	ld	s4,32(sp)
    800012e2:	6ae2                	ld	s5,24(sp)
    800012e4:	6b42                	ld	s6,16(sp)
    800012e6:	6ba2                	ld	s7,8(sp)
    800012e8:	6161                	addi	sp,sp,80
    800012ea:	8082                	ret
  return 0;
    800012ec:	4501                	li	a0,0
    800012ee:	b7e5                	j	800012d6 <mappages+0x74>

00000000800012f0 <kvmbuild>:
{
    800012f0:	1101                	addi	sp,sp,-32
    800012f2:	ec06                	sd	ra,24(sp)
    800012f4:	e822                	sd	s0,16(sp)
    800012f6:	e426                	sd	s1,8(sp)
    800012f8:	e04a                	sd	s2,0(sp)
    800012fa:	1000                	addi	s0,sp,32
    pagetable_t  pagetable = (pagetable_t) kalloc();
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	824080e7          	jalr	-2012(ra) # 80000b20 <kalloc>
    80001304:	84aa                	mv	s1,a0
    memset(pagetable, 0, PGSIZE);
    80001306:	6605                	lui	a2,0x1
    80001308:	4581                	li	a1,0
    8000130a:	00000097          	auipc	ra,0x0
    8000130e:	a02080e7          	jalr	-1534(ra) # 80000d0c <memset>
    mappages(pagetable, UART0, PGSIZE, UART0, PTE_R | PTE_W);
    80001312:	4719                	li	a4,6
    80001314:	100006b7          	lui	a3,0x10000
    80001318:	6605                	lui	a2,0x1
    8000131a:	100005b7          	lui	a1,0x10000
    8000131e:	8526                	mv	a0,s1
    80001320:	00000097          	auipc	ra,0x0
    80001324:	f42080e7          	jalr	-190(ra) # 80001262 <mappages>
    mappages(pagetable, VIRTIO0, PGSIZE, VIRTIO0, PTE_R | PTE_W);
    80001328:	4719                	li	a4,6
    8000132a:	100016b7          	lui	a3,0x10001
    8000132e:	6605                	lui	a2,0x1
    80001330:	100015b7          	lui	a1,0x10001
    80001334:	8526                	mv	a0,s1
    80001336:	00000097          	auipc	ra,0x0
    8000133a:	f2c080e7          	jalr	-212(ra) # 80001262 <mappages>
    mappages(pagetable, PLIC, 0x400000, PLIC, PTE_R | PTE_W);
    8000133e:	4719                	li	a4,6
    80001340:	0c0006b7          	lui	a3,0xc000
    80001344:	00400637          	lui	a2,0x400
    80001348:	0c0005b7          	lui	a1,0xc000
    8000134c:	8526                	mv	a0,s1
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	f14080e7          	jalr	-236(ra) # 80001262 <mappages>
    mappages(pagetable, KERNBASE, (uint64)etext-KERNBASE, KERNBASE, PTE_R | PTE_X);
    80001356:	00007917          	auipc	s2,0x7
    8000135a:	caa90913          	addi	s2,s2,-854 # 80008000 <etext>
    8000135e:	4729                	li	a4,10
    80001360:	4685                	li	a3,1
    80001362:	06fe                	slli	a3,a3,0x1f
    80001364:	80007617          	auipc	a2,0x80007
    80001368:	c9c60613          	addi	a2,a2,-868 # 8000 <_entry-0x7fff8000>
    8000136c:	85b6                	mv	a1,a3
    8000136e:	8526                	mv	a0,s1
    80001370:	00000097          	auipc	ra,0x0
    80001374:	ef2080e7          	jalr	-270(ra) # 80001262 <mappages>
    mappages(pagetable, (uint64)etext, PHYSTOP-(uint64)etext, (uint64)etext, PTE_R | PTE_W);
    80001378:	4719                	li	a4,6
    8000137a:	86ca                	mv	a3,s2
    8000137c:	4645                	li	a2,17
    8000137e:	066e                	slli	a2,a2,0x1b
    80001380:	41260633          	sub	a2,a2,s2
    80001384:	85ca                	mv	a1,s2
    80001386:	8526                	mv	a0,s1
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	eda080e7          	jalr	-294(ra) # 80001262 <mappages>
    mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline, PTE_R | PTE_X);
    80001390:	4729                	li	a4,10
    80001392:	00006697          	auipc	a3,0x6
    80001396:	c6e68693          	addi	a3,a3,-914 # 80007000 <_trampoline>
    8000139a:	6605                	lui	a2,0x1
    8000139c:	040005b7          	lui	a1,0x4000
    800013a0:	15fd                	addi	a1,a1,-1
    800013a2:	05b2                	slli	a1,a1,0xc
    800013a4:	8526                	mv	a0,s1
    800013a6:	00000097          	auipc	ra,0x0
    800013aa:	ebc080e7          	jalr	-324(ra) # 80001262 <mappages>
}
    800013ae:	8526                	mv	a0,s1
    800013b0:	60e2                	ld	ra,24(sp)
    800013b2:	6442                	ld	s0,16(sp)
    800013b4:	64a2                	ld	s1,8(sp)
    800013b6:	6902                	ld	s2,0(sp)
    800013b8:	6105                	addi	sp,sp,32
    800013ba:	8082                	ret

00000000800013bc <kvmmap>:
{
    800013bc:	1141                	addi	sp,sp,-16
    800013be:	e406                	sd	ra,8(sp)
    800013c0:	e022                	sd	s0,0(sp)
    800013c2:	0800                	addi	s0,sp,16
    800013c4:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800013c6:	86ae                	mv	a3,a1
    800013c8:	85aa                	mv	a1,a0
    800013ca:	00008517          	auipc	a0,0x8
    800013ce:	c4653503          	ld	a0,-954(a0) # 80009010 <kernel_pagetable>
    800013d2:	00000097          	auipc	ra,0x0
    800013d6:	e90080e7          	jalr	-368(ra) # 80001262 <mappages>
    800013da:	e509                	bnez	a0,800013e4 <kvmmap+0x28>
}
    800013dc:	60a2                	ld	ra,8(sp)
    800013de:	6402                	ld	s0,0(sp)
    800013e0:	0141                	addi	sp,sp,16
    800013e2:	8082                	ret
    panic("kvmmap");
    800013e4:	00007517          	auipc	a0,0x7
    800013e8:	d3450513          	addi	a0,a0,-716 # 80008118 <digits+0xd8>
    800013ec:	fffff097          	auipc	ra,0xfffff
    800013f0:	15c080e7          	jalr	348(ra) # 80000548 <panic>

00000000800013f4 <kvminit>:
{
    800013f4:	1101                	addi	sp,sp,-32
    800013f6:	ec06                	sd	ra,24(sp)
    800013f8:	e822                	sd	s0,16(sp)
    800013fa:	e426                	sd	s1,8(sp)
    800013fc:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800013fe:	fffff097          	auipc	ra,0xfffff
    80001402:	722080e7          	jalr	1826(ra) # 80000b20 <kalloc>
    80001406:	00008797          	auipc	a5,0x8
    8000140a:	c0a7b523          	sd	a0,-1014(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000140e:	6605                	lui	a2,0x1
    80001410:	4581                	li	a1,0
    80001412:	00000097          	auipc	ra,0x0
    80001416:	8fa080e7          	jalr	-1798(ra) # 80000d0c <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000141a:	4699                	li	a3,6
    8000141c:	6605                	lui	a2,0x1
    8000141e:	100005b7          	lui	a1,0x10000
    80001422:	10000537          	lui	a0,0x10000
    80001426:	00000097          	auipc	ra,0x0
    8000142a:	f96080e7          	jalr	-106(ra) # 800013bc <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000142e:	4699                	li	a3,6
    80001430:	6605                	lui	a2,0x1
    80001432:	100015b7          	lui	a1,0x10001
    80001436:	10001537          	lui	a0,0x10001
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	f82080e7          	jalr	-126(ra) # 800013bc <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001442:	4699                	li	a3,6
    80001444:	6641                	lui	a2,0x10
    80001446:	020005b7          	lui	a1,0x2000
    8000144a:	02000537          	lui	a0,0x2000
    8000144e:	00000097          	auipc	ra,0x0
    80001452:	f6e080e7          	jalr	-146(ra) # 800013bc <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001456:	4699                	li	a3,6
    80001458:	00400637          	lui	a2,0x400
    8000145c:	0c0005b7          	lui	a1,0xc000
    80001460:	0c000537          	lui	a0,0xc000
    80001464:	00000097          	auipc	ra,0x0
    80001468:	f58080e7          	jalr	-168(ra) # 800013bc <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000146c:	00007497          	auipc	s1,0x7
    80001470:	b9448493          	addi	s1,s1,-1132 # 80008000 <etext>
    80001474:	46a9                	li	a3,10
    80001476:	80007617          	auipc	a2,0x80007
    8000147a:	b8a60613          	addi	a2,a2,-1142 # 8000 <_entry-0x7fff8000>
    8000147e:	4585                	li	a1,1
    80001480:	05fe                	slli	a1,a1,0x1f
    80001482:	852e                	mv	a0,a1
    80001484:	00000097          	auipc	ra,0x0
    80001488:	f38080e7          	jalr	-200(ra) # 800013bc <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000148c:	4699                	li	a3,6
    8000148e:	4645                	li	a2,17
    80001490:	066e                	slli	a2,a2,0x1b
    80001492:	8e05                	sub	a2,a2,s1
    80001494:	85a6                	mv	a1,s1
    80001496:	8526                	mv	a0,s1
    80001498:	00000097          	auipc	ra,0x0
    8000149c:	f24080e7          	jalr	-220(ra) # 800013bc <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800014a0:	46a9                	li	a3,10
    800014a2:	6605                	lui	a2,0x1
    800014a4:	00006597          	auipc	a1,0x6
    800014a8:	b5c58593          	addi	a1,a1,-1188 # 80007000 <_trampoline>
    800014ac:	04000537          	lui	a0,0x4000
    800014b0:	157d                	addi	a0,a0,-1
    800014b2:	0532                	slli	a0,a0,0xc
    800014b4:	00000097          	auipc	ra,0x0
    800014b8:	f08080e7          	jalr	-248(ra) # 800013bc <kvmmap>
}
    800014bc:	60e2                	ld	ra,24(sp)
    800014be:	6442                	ld	s0,16(sp)
    800014c0:	64a2                	ld	s1,8(sp)
    800014c2:	6105                	addi	sp,sp,32
    800014c4:	8082                	ret

00000000800014c6 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800014c6:	715d                	addi	sp,sp,-80
    800014c8:	e486                	sd	ra,72(sp)
    800014ca:	e0a2                	sd	s0,64(sp)
    800014cc:	fc26                	sd	s1,56(sp)
    800014ce:	f84a                	sd	s2,48(sp)
    800014d0:	f44e                	sd	s3,40(sp)
    800014d2:	f052                	sd	s4,32(sp)
    800014d4:	ec56                	sd	s5,24(sp)
    800014d6:	e85a                	sd	s6,16(sp)
    800014d8:	e45e                	sd	s7,8(sp)
    800014da:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800014dc:	03459793          	slli	a5,a1,0x34
    800014e0:	e795                	bnez	a5,8000150c <uvmunmap+0x46>
    800014e2:	8a2a                	mv	s4,a0
    800014e4:	892e                	mv	s2,a1
    800014e6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014e8:	0632                	slli	a2,a2,0xc
    800014ea:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800014ee:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014f0:	6b05                	lui	s6,0x1
    800014f2:	0735e863          	bltu	a1,s3,80001562 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800014f6:	60a6                	ld	ra,72(sp)
    800014f8:	6406                	ld	s0,64(sp)
    800014fa:	74e2                	ld	s1,56(sp)
    800014fc:	7942                	ld	s2,48(sp)
    800014fe:	79a2                	ld	s3,40(sp)
    80001500:	7a02                	ld	s4,32(sp)
    80001502:	6ae2                	ld	s5,24(sp)
    80001504:	6b42                	ld	s6,16(sp)
    80001506:	6ba2                	ld	s7,8(sp)
    80001508:	6161                	addi	sp,sp,80
    8000150a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c1450513          	addi	a0,a0,-1004 # 80008120 <digits+0xe0>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	034080e7          	jalr	52(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    8000151c:	00007517          	auipc	a0,0x7
    80001520:	c1c50513          	addi	a0,a0,-996 # 80008138 <digits+0xf8>
    80001524:	fffff097          	auipc	ra,0xfffff
    80001528:	024080e7          	jalr	36(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    8000152c:	00007517          	auipc	a0,0x7
    80001530:	c1c50513          	addi	a0,a0,-996 # 80008148 <digits+0x108>
    80001534:	fffff097          	auipc	ra,0xfffff
    80001538:	014080e7          	jalr	20(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    8000153c:	00007517          	auipc	a0,0x7
    80001540:	c2450513          	addi	a0,a0,-988 # 80008160 <digits+0x120>
    80001544:	fffff097          	auipc	ra,0xfffff
    80001548:	004080e7          	jalr	4(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    8000154c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000154e:	0532                	slli	a0,a0,0xc
    80001550:	fffff097          	auipc	ra,0xfffff
    80001554:	4d4080e7          	jalr	1236(ra) # 80000a24 <kfree>
    *pte = 0;
    80001558:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000155c:	995a                	add	s2,s2,s6
    8000155e:	f9397ce3          	bgeu	s2,s3,800014f6 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001562:	4601                	li	a2,0
    80001564:	85ca                	mv	a1,s2
    80001566:	8552                	mv	a0,s4
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	baa080e7          	jalr	-1110(ra) # 80001112 <walk>
    80001570:	84aa                	mv	s1,a0
    80001572:	d54d                	beqz	a0,8000151c <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001574:	6108                	ld	a0,0(a0)
    80001576:	00157793          	andi	a5,a0,1
    8000157a:	dbcd                	beqz	a5,8000152c <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000157c:	3ff57793          	andi	a5,a0,1023
    80001580:	fb778ee3          	beq	a5,s7,8000153c <uvmunmap+0x76>
    if(do_free){
    80001584:	fc0a8ae3          	beqz	s5,80001558 <uvmunmap+0x92>
    80001588:	b7d1                	j	8000154c <uvmunmap+0x86>

000000008000158a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000158a:	1101                	addi	sp,sp,-32
    8000158c:	ec06                	sd	ra,24(sp)
    8000158e:	e822                	sd	s0,16(sp)
    80001590:	e426                	sd	s1,8(sp)
    80001592:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001594:	fffff097          	auipc	ra,0xfffff
    80001598:	58c080e7          	jalr	1420(ra) # 80000b20 <kalloc>
    8000159c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000159e:	c519                	beqz	a0,800015ac <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800015a0:	6605                	lui	a2,0x1
    800015a2:	4581                	li	a1,0
    800015a4:	fffff097          	auipc	ra,0xfffff
    800015a8:	768080e7          	jalr	1896(ra) # 80000d0c <memset>
  return pagetable;
}
    800015ac:	8526                	mv	a0,s1
    800015ae:	60e2                	ld	ra,24(sp)
    800015b0:	6442                	ld	s0,16(sp)
    800015b2:	64a2                	ld	s1,8(sp)
    800015b4:	6105                	addi	sp,sp,32
    800015b6:	8082                	ret

00000000800015b8 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800015b8:	7179                	addi	sp,sp,-48
    800015ba:	f406                	sd	ra,40(sp)
    800015bc:	f022                	sd	s0,32(sp)
    800015be:	ec26                	sd	s1,24(sp)
    800015c0:	e84a                	sd	s2,16(sp)
    800015c2:	e44e                	sd	s3,8(sp)
    800015c4:	e052                	sd	s4,0(sp)
    800015c6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800015c8:	6785                	lui	a5,0x1
    800015ca:	04f67863          	bgeu	a2,a5,8000161a <uvminit+0x62>
    800015ce:	8a2a                	mv	s4,a0
    800015d0:	89ae                	mv	s3,a1
    800015d2:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	54c080e7          	jalr	1356(ra) # 80000b20 <kalloc>
    800015dc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800015de:	6605                	lui	a2,0x1
    800015e0:	4581                	li	a1,0
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	72a080e7          	jalr	1834(ra) # 80000d0c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015ea:	4779                	li	a4,30
    800015ec:	86ca                	mv	a3,s2
    800015ee:	6605                	lui	a2,0x1
    800015f0:	4581                	li	a1,0
    800015f2:	8552                	mv	a0,s4
    800015f4:	00000097          	auipc	ra,0x0
    800015f8:	c6e080e7          	jalr	-914(ra) # 80001262 <mappages>
  memmove(mem, src, sz);
    800015fc:	8626                	mv	a2,s1
    800015fe:	85ce                	mv	a1,s3
    80001600:	854a                	mv	a0,s2
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	76a080e7          	jalr	1898(ra) # 80000d6c <memmove>
}
    8000160a:	70a2                	ld	ra,40(sp)
    8000160c:	7402                	ld	s0,32(sp)
    8000160e:	64e2                	ld	s1,24(sp)
    80001610:	6942                	ld	s2,16(sp)
    80001612:	69a2                	ld	s3,8(sp)
    80001614:	6a02                	ld	s4,0(sp)
    80001616:	6145                	addi	sp,sp,48
    80001618:	8082                	ret
    panic("inituvm: more than a page");
    8000161a:	00007517          	auipc	a0,0x7
    8000161e:	b5e50513          	addi	a0,a0,-1186 # 80008178 <digits+0x138>
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	f26080e7          	jalr	-218(ra) # 80000548 <panic>

000000008000162a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000162a:	1101                	addi	sp,sp,-32
    8000162c:	ec06                	sd	ra,24(sp)
    8000162e:	e822                	sd	s0,16(sp)
    80001630:	e426                	sd	s1,8(sp)
    80001632:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001634:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001636:	00b67d63          	bgeu	a2,a1,80001650 <uvmdealloc+0x26>
    8000163a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000163c:	6785                	lui	a5,0x1
    8000163e:	17fd                	addi	a5,a5,-1
    80001640:	00f60733          	add	a4,a2,a5
    80001644:	767d                	lui	a2,0xfffff
    80001646:	8f71                	and	a4,a4,a2
    80001648:	97ae                	add	a5,a5,a1
    8000164a:	8ff1                	and	a5,a5,a2
    8000164c:	00f76863          	bltu	a4,a5,8000165c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001650:	8526                	mv	a0,s1
    80001652:	60e2                	ld	ra,24(sp)
    80001654:	6442                	ld	s0,16(sp)
    80001656:	64a2                	ld	s1,8(sp)
    80001658:	6105                	addi	sp,sp,32
    8000165a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000165c:	8f99                	sub	a5,a5,a4
    8000165e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001660:	4685                	li	a3,1
    80001662:	0007861b          	sext.w	a2,a5
    80001666:	85ba                	mv	a1,a4
    80001668:	00000097          	auipc	ra,0x0
    8000166c:	e5e080e7          	jalr	-418(ra) # 800014c6 <uvmunmap>
    80001670:	b7c5                	j	80001650 <uvmdealloc+0x26>

0000000080001672 <uvmalloc>:
  if(newsz < oldsz)
    80001672:	0ab66163          	bltu	a2,a1,80001714 <uvmalloc+0xa2>
{
    80001676:	7139                	addi	sp,sp,-64
    80001678:	fc06                	sd	ra,56(sp)
    8000167a:	f822                	sd	s0,48(sp)
    8000167c:	f426                	sd	s1,40(sp)
    8000167e:	f04a                	sd	s2,32(sp)
    80001680:	ec4e                	sd	s3,24(sp)
    80001682:	e852                	sd	s4,16(sp)
    80001684:	e456                	sd	s5,8(sp)
    80001686:	0080                	addi	s0,sp,64
    80001688:	8aaa                	mv	s5,a0
    8000168a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000168c:	6985                	lui	s3,0x1
    8000168e:	19fd                	addi	s3,s3,-1
    80001690:	95ce                	add	a1,a1,s3
    80001692:	79fd                	lui	s3,0xfffff
    80001694:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001698:	08c9f063          	bgeu	s3,a2,80001718 <uvmalloc+0xa6>
    8000169c:	894e                	mv	s2,s3
    mem = kalloc();
    8000169e:	fffff097          	auipc	ra,0xfffff
    800016a2:	482080e7          	jalr	1154(ra) # 80000b20 <kalloc>
    800016a6:	84aa                	mv	s1,a0
    if(mem == 0){
    800016a8:	c51d                	beqz	a0,800016d6 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800016aa:	6605                	lui	a2,0x1
    800016ac:	4581                	li	a1,0
    800016ae:	fffff097          	auipc	ra,0xfffff
    800016b2:	65e080e7          	jalr	1630(ra) # 80000d0c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800016b6:	4779                	li	a4,30
    800016b8:	86a6                	mv	a3,s1
    800016ba:	6605                	lui	a2,0x1
    800016bc:	85ca                	mv	a1,s2
    800016be:	8556                	mv	a0,s5
    800016c0:	00000097          	auipc	ra,0x0
    800016c4:	ba2080e7          	jalr	-1118(ra) # 80001262 <mappages>
    800016c8:	e905                	bnez	a0,800016f8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800016ca:	6785                	lui	a5,0x1
    800016cc:	993e                	add	s2,s2,a5
    800016ce:	fd4968e3          	bltu	s2,s4,8000169e <uvmalloc+0x2c>
  return newsz;
    800016d2:	8552                	mv	a0,s4
    800016d4:	a809                	j	800016e6 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800016d6:	864e                	mv	a2,s3
    800016d8:	85ca                	mv	a1,s2
    800016da:	8556                	mv	a0,s5
    800016dc:	00000097          	auipc	ra,0x0
    800016e0:	f4e080e7          	jalr	-178(ra) # 8000162a <uvmdealloc>
      return 0;
    800016e4:	4501                	li	a0,0
}
    800016e6:	70e2                	ld	ra,56(sp)
    800016e8:	7442                	ld	s0,48(sp)
    800016ea:	74a2                	ld	s1,40(sp)
    800016ec:	7902                	ld	s2,32(sp)
    800016ee:	69e2                	ld	s3,24(sp)
    800016f0:	6a42                	ld	s4,16(sp)
    800016f2:	6aa2                	ld	s5,8(sp)
    800016f4:	6121                	addi	sp,sp,64
    800016f6:	8082                	ret
      kfree(mem);
    800016f8:	8526                	mv	a0,s1
    800016fa:	fffff097          	auipc	ra,0xfffff
    800016fe:	32a080e7          	jalr	810(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001702:	864e                	mv	a2,s3
    80001704:	85ca                	mv	a1,s2
    80001706:	8556                	mv	a0,s5
    80001708:	00000097          	auipc	ra,0x0
    8000170c:	f22080e7          	jalr	-222(ra) # 8000162a <uvmdealloc>
      return 0;
    80001710:	4501                	li	a0,0
    80001712:	bfd1                	j	800016e6 <uvmalloc+0x74>
    return oldsz;
    80001714:	852e                	mv	a0,a1
}
    80001716:	8082                	ret
  return newsz;
    80001718:	8532                	mv	a0,a2
    8000171a:	b7f1                	j	800016e6 <uvmalloc+0x74>

000000008000171c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000171c:	7179                	addi	sp,sp,-48
    8000171e:	f406                	sd	ra,40(sp)
    80001720:	f022                	sd	s0,32(sp)
    80001722:	ec26                	sd	s1,24(sp)
    80001724:	e84a                	sd	s2,16(sp)
    80001726:	e44e                	sd	s3,8(sp)
    80001728:	e052                	sd	s4,0(sp)
    8000172a:	1800                	addi	s0,sp,48
    8000172c:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000172e:	84aa                	mv	s1,a0
    80001730:	6905                	lui	s2,0x1
    80001732:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001734:	4985                	li	s3,1
    80001736:	a821                	j	8000174e <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001738:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000173a:	0532                	slli	a0,a0,0xc
    8000173c:	00000097          	auipc	ra,0x0
    80001740:	fe0080e7          	jalr	-32(ra) # 8000171c <freewalk>
      pagetable[i] = 0;
    80001744:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001748:	04a1                	addi	s1,s1,8
    8000174a:	03248163          	beq	s1,s2,8000176c <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000174e:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001750:	00f57793          	andi	a5,a0,15
    80001754:	ff3782e3          	beq	a5,s3,80001738 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001758:	8905                	andi	a0,a0,1
    8000175a:	d57d                	beqz	a0,80001748 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000175c:	00007517          	auipc	a0,0x7
    80001760:	a3c50513          	addi	a0,a0,-1476 # 80008198 <digits+0x158>
    80001764:	fffff097          	auipc	ra,0xfffff
    80001768:	de4080e7          	jalr	-540(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    8000176c:	8552                	mv	a0,s4
    8000176e:	fffff097          	auipc	ra,0xfffff
    80001772:	2b6080e7          	jalr	694(ra) # 80000a24 <kfree>
}
    80001776:	70a2                	ld	ra,40(sp)
    80001778:	7402                	ld	s0,32(sp)
    8000177a:	64e2                	ld	s1,24(sp)
    8000177c:	6942                	ld	s2,16(sp)
    8000177e:	69a2                	ld	s3,8(sp)
    80001780:	6a02                	ld	s4,0(sp)
    80001782:	6145                	addi	sp,sp,48
    80001784:	8082                	ret

0000000080001786 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001786:	1101                	addi	sp,sp,-32
    80001788:	ec06                	sd	ra,24(sp)
    8000178a:	e822                	sd	s0,16(sp)
    8000178c:	e426                	sd	s1,8(sp)
    8000178e:	1000                	addi	s0,sp,32
    80001790:	84aa                	mv	s1,a0
  if(sz > 0)
    80001792:	e999                	bnez	a1,800017a8 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001794:	8526                	mv	a0,s1
    80001796:	00000097          	auipc	ra,0x0
    8000179a:	f86080e7          	jalr	-122(ra) # 8000171c <freewalk>
}
    8000179e:	60e2                	ld	ra,24(sp)
    800017a0:	6442                	ld	s0,16(sp)
    800017a2:	64a2                	ld	s1,8(sp)
    800017a4:	6105                	addi	sp,sp,32
    800017a6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800017a8:	6605                	lui	a2,0x1
    800017aa:	167d                	addi	a2,a2,-1
    800017ac:	962e                	add	a2,a2,a1
    800017ae:	4685                	li	a3,1
    800017b0:	8231                	srli	a2,a2,0xc
    800017b2:	4581                	li	a1,0
    800017b4:	00000097          	auipc	ra,0x0
    800017b8:	d12080e7          	jalr	-750(ra) # 800014c6 <uvmunmap>
    800017bc:	bfe1                	j	80001794 <uvmfree+0xe>

00000000800017be <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800017be:	c679                	beqz	a2,8000188c <uvmcopy+0xce>
{
    800017c0:	715d                	addi	sp,sp,-80
    800017c2:	e486                	sd	ra,72(sp)
    800017c4:	e0a2                	sd	s0,64(sp)
    800017c6:	fc26                	sd	s1,56(sp)
    800017c8:	f84a                	sd	s2,48(sp)
    800017ca:	f44e                	sd	s3,40(sp)
    800017cc:	f052                	sd	s4,32(sp)
    800017ce:	ec56                	sd	s5,24(sp)
    800017d0:	e85a                	sd	s6,16(sp)
    800017d2:	e45e                	sd	s7,8(sp)
    800017d4:	0880                	addi	s0,sp,80
    800017d6:	8b2a                	mv	s6,a0
    800017d8:	8aae                	mv	s5,a1
    800017da:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800017dc:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800017de:	4601                	li	a2,0
    800017e0:	85ce                	mv	a1,s3
    800017e2:	855a                	mv	a0,s6
    800017e4:	00000097          	auipc	ra,0x0
    800017e8:	92e080e7          	jalr	-1746(ra) # 80001112 <walk>
    800017ec:	c531                	beqz	a0,80001838 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800017ee:	6118                	ld	a4,0(a0)
    800017f0:	00177793          	andi	a5,a4,1
    800017f4:	cbb1                	beqz	a5,80001848 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800017f6:	00a75593          	srli	a1,a4,0xa
    800017fa:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800017fe:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001802:	fffff097          	auipc	ra,0xfffff
    80001806:	31e080e7          	jalr	798(ra) # 80000b20 <kalloc>
    8000180a:	892a                	mv	s2,a0
    8000180c:	c939                	beqz	a0,80001862 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000180e:	6605                	lui	a2,0x1
    80001810:	85de                	mv	a1,s7
    80001812:	fffff097          	auipc	ra,0xfffff
    80001816:	55a080e7          	jalr	1370(ra) # 80000d6c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000181a:	8726                	mv	a4,s1
    8000181c:	86ca                	mv	a3,s2
    8000181e:	6605                	lui	a2,0x1
    80001820:	85ce                	mv	a1,s3
    80001822:	8556                	mv	a0,s5
    80001824:	00000097          	auipc	ra,0x0
    80001828:	a3e080e7          	jalr	-1474(ra) # 80001262 <mappages>
    8000182c:	e515                	bnez	a0,80001858 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000182e:	6785                	lui	a5,0x1
    80001830:	99be                	add	s3,s3,a5
    80001832:	fb49e6e3          	bltu	s3,s4,800017de <uvmcopy+0x20>
    80001836:	a081                	j	80001876 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001838:	00007517          	auipc	a0,0x7
    8000183c:	97050513          	addi	a0,a0,-1680 # 800081a8 <digits+0x168>
    80001840:	fffff097          	auipc	ra,0xfffff
    80001844:	d08080e7          	jalr	-760(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    80001848:	00007517          	auipc	a0,0x7
    8000184c:	98050513          	addi	a0,a0,-1664 # 800081c8 <digits+0x188>
    80001850:	fffff097          	auipc	ra,0xfffff
    80001854:	cf8080e7          	jalr	-776(ra) # 80000548 <panic>
      kfree(mem);
    80001858:	854a                	mv	a0,s2
    8000185a:	fffff097          	auipc	ra,0xfffff
    8000185e:	1ca080e7          	jalr	458(ra) # 80000a24 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001862:	4685                	li	a3,1
    80001864:	00c9d613          	srli	a2,s3,0xc
    80001868:	4581                	li	a1,0
    8000186a:	8556                	mv	a0,s5
    8000186c:	00000097          	auipc	ra,0x0
    80001870:	c5a080e7          	jalr	-934(ra) # 800014c6 <uvmunmap>
  return -1;
    80001874:	557d                	li	a0,-1
}
    80001876:	60a6                	ld	ra,72(sp)
    80001878:	6406                	ld	s0,64(sp)
    8000187a:	74e2                	ld	s1,56(sp)
    8000187c:	7942                	ld	s2,48(sp)
    8000187e:	79a2                	ld	s3,40(sp)
    80001880:	7a02                	ld	s4,32(sp)
    80001882:	6ae2                	ld	s5,24(sp)
    80001884:	6b42                	ld	s6,16(sp)
    80001886:	6ba2                	ld	s7,8(sp)
    80001888:	6161                	addi	sp,sp,80
    8000188a:	8082                	ret
  return 0;
    8000188c:	4501                	li	a0,0
}
    8000188e:	8082                	ret

0000000080001890 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001890:	1141                	addi	sp,sp,-16
    80001892:	e406                	sd	ra,8(sp)
    80001894:	e022                	sd	s0,0(sp)
    80001896:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001898:	4601                	li	a2,0
    8000189a:	00000097          	auipc	ra,0x0
    8000189e:	878080e7          	jalr	-1928(ra) # 80001112 <walk>
  if(pte == 0)
    800018a2:	c901                	beqz	a0,800018b2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800018a4:	611c                	ld	a5,0(a0)
    800018a6:	9bbd                	andi	a5,a5,-17
    800018a8:	e11c                	sd	a5,0(a0)
}
    800018aa:	60a2                	ld	ra,8(sp)
    800018ac:	6402                	ld	s0,0(sp)
    800018ae:	0141                	addi	sp,sp,16
    800018b0:	8082                	ret
    panic("uvmclear");
    800018b2:	00007517          	auipc	a0,0x7
    800018b6:	93650513          	addi	a0,a0,-1738 # 800081e8 <digits+0x1a8>
    800018ba:	fffff097          	auipc	ra,0xfffff
    800018be:	c8e080e7          	jalr	-882(ra) # 80000548 <panic>

00000000800018c2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018c2:	c6bd                	beqz	a3,80001930 <copyout+0x6e>
{
    800018c4:	715d                	addi	sp,sp,-80
    800018c6:	e486                	sd	ra,72(sp)
    800018c8:	e0a2                	sd	s0,64(sp)
    800018ca:	fc26                	sd	s1,56(sp)
    800018cc:	f84a                	sd	s2,48(sp)
    800018ce:	f44e                	sd	s3,40(sp)
    800018d0:	f052                	sd	s4,32(sp)
    800018d2:	ec56                	sd	s5,24(sp)
    800018d4:	e85a                	sd	s6,16(sp)
    800018d6:	e45e                	sd	s7,8(sp)
    800018d8:	e062                	sd	s8,0(sp)
    800018da:	0880                	addi	s0,sp,80
    800018dc:	8b2a                	mv	s6,a0
    800018de:	8c2e                	mv	s8,a1
    800018e0:	8a32                	mv	s4,a2
    800018e2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800018e4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800018e6:	6a85                	lui	s5,0x1
    800018e8:	a015                	j	8000190c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800018ea:	9562                	add	a0,a0,s8
    800018ec:	0004861b          	sext.w	a2,s1
    800018f0:	85d2                	mv	a1,s4
    800018f2:	41250533          	sub	a0,a0,s2
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	476080e7          	jalr	1142(ra) # 80000d6c <memmove>

    len -= n;
    800018fe:	409989b3          	sub	s3,s3,s1
    src += n;
    80001902:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001904:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001908:	02098263          	beqz	s3,8000192c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000190c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001910:	85ca                	mv	a1,s2
    80001912:	855a                	mv	a0,s6
    80001914:	00000097          	auipc	ra,0x0
    80001918:	8a4080e7          	jalr	-1884(ra) # 800011b8 <walkaddr>
    if(pa0 == 0)
    8000191c:	cd01                	beqz	a0,80001934 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000191e:	418904b3          	sub	s1,s2,s8
    80001922:	94d6                	add	s1,s1,s5
    if(n > len)
    80001924:	fc99f3e3          	bgeu	s3,s1,800018ea <copyout+0x28>
    80001928:	84ce                	mv	s1,s3
    8000192a:	b7c1                	j	800018ea <copyout+0x28>
  }
  return 0;
    8000192c:	4501                	li	a0,0
    8000192e:	a021                	j	80001936 <copyout+0x74>
    80001930:	4501                	li	a0,0
}
    80001932:	8082                	ret
      return -1;
    80001934:	557d                	li	a0,-1
}
    80001936:	60a6                	ld	ra,72(sp)
    80001938:	6406                	ld	s0,64(sp)
    8000193a:	74e2                	ld	s1,56(sp)
    8000193c:	7942                	ld	s2,48(sp)
    8000193e:	79a2                	ld	s3,40(sp)
    80001940:	7a02                	ld	s4,32(sp)
    80001942:	6ae2                	ld	s5,24(sp)
    80001944:	6b42                	ld	s6,16(sp)
    80001946:	6ba2                	ld	s7,8(sp)
    80001948:	6c02                	ld	s8,0(sp)
    8000194a:	6161                	addi	sp,sp,80
    8000194c:	8082                	ret

000000008000194e <copyin>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    8000194e:	1141                	addi	sp,sp,-16
    80001950:	e406                	sd	ra,8(sp)
    80001952:	e022                	sd	s0,0(sp)
    80001954:	0800                	addi	s0,sp,16
    return copyin_new(pagetable, dst, srcva, len);
    80001956:	00005097          	auipc	ra,0x5
    8000195a:	c0a080e7          	jalr	-1014(ra) # 80006560 <copyin_new>
}
    8000195e:	60a2                	ld	ra,8(sp)
    80001960:	6402                	ld	s0,0(sp)
    80001962:	0141                	addi	sp,sp,16
    80001964:	8082                	ret

0000000080001966 <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    80001966:	1141                	addi	sp,sp,-16
    80001968:	e406                	sd	ra,8(sp)
    8000196a:	e022                	sd	s0,0(sp)
    8000196c:	0800                	addi	s0,sp,16
  return copyinstr_new(pagetable, dst, srcva, max);
    8000196e:	00005097          	auipc	ra,0x5
    80001972:	c5a080e7          	jalr	-934(ra) # 800065c8 <copyinstr_new>
}
    80001976:	60a2                	ld	ra,8(sp)
    80001978:	6402                	ld	s0,0(sp)
    8000197a:	0141                	addi	sp,sp,16
    8000197c:	8082                	ret

000000008000197e <uvm2kvm>:

void
uvm2kvm(pagetable_t pagetable, pagetable_t kpagetable, uint64 old_size, uint64 new_size)
{
    8000197e:	7139                	addi	sp,sp,-64
    80001980:	fc06                	sd	ra,56(sp)
    80001982:	f822                	sd	s0,48(sp)
    80001984:	f426                	sd	s1,40(sp)
    80001986:	f04a                	sd	s2,32(sp)
    80001988:	ec4e                	sd	s3,24(sp)
    8000198a:	e852                	sd	s4,16(sp)
    8000198c:	e456                	sd	s5,8(sp)
    8000198e:	e05a                	sd	s6,0(sp)
    80001990:	0080                	addi	s0,sp,64
    if (new_size < old_size)
    80001992:	06c6e863          	bltu	a3,a2,80001a02 <uvm2kvm+0x84>
    80001996:	89aa                	mv	s3,a0
    80001998:	8a2e                	mv	s4,a1
        panic("new size lower than old size");

    if (PGROUNDUP(new_size) >= PLIC)
    8000199a:	6a85                	lui	s5,0x1
    8000199c:	1afd                	addi	s5,s5,-1
    8000199e:	96d6                	add	a3,a3,s5
    800019a0:	7afd                	lui	s5,0xfffff
    800019a2:	0156fab3          	and	s5,a3,s5
    800019a6:	0c0007b7          	lui	a5,0xc000
    800019aa:	06faf463          	bgeu	s5,a5,80001a12 <uvm2kvm+0x94>
        panic("new size too big");

    uint64 begin = PGROUNDUP(old_size);
    800019ae:	6485                	lui	s1,0x1
    800019b0:	14fd                	addi	s1,s1,-1
    800019b2:	9626                	add	a2,a2,s1
    800019b4:	74fd                	lui	s1,0xfffff
    800019b6:	8cf1                	and	s1,s1,a2
    uint64 end = PGROUNDUP(new_size);
    // printf("begin: %x, end: %x\n", begin, end);
    for (uint64 va = begin; va < end; va += PGSIZE) {
    800019b8:	0354fb63          	bgeu	s1,s5,800019ee <uvm2kvm+0x70>
    800019bc:	6b05                	lui	s6,0x1
        pte_t* pte = walk(pagetable, va, 0);
    800019be:	4601                	li	a2,0
    800019c0:	85a6                	mv	a1,s1
    800019c2:	854e                	mv	a0,s3
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	74e080e7          	jalr	1870(ra) # 80001112 <walk>
    800019cc:	892a                	mv	s2,a0
        if (pte == 0)
    800019ce:	c931                	beqz	a0,80001a22 <uvm2kvm+0xa4>
            panic("user page table not found");
        pte_t* kpte = walk(kpagetable, va, 1);
    800019d0:	4605                	li	a2,1
    800019d2:	85a6                	mv	a1,s1
    800019d4:	8552                	mv	a0,s4
    800019d6:	fffff097          	auipc	ra,0xfffff
    800019da:	73c080e7          	jalr	1852(ra) # 80001112 <walk>
        if (kpte == 0)
    800019de:	c931                	beqz	a0,80001a32 <uvm2kvm+0xb4>
            panic("kernel page table not found");
        *kpte = (*pte) & (~PTE_U);
    800019e0:	00093783          	ld	a5,0(s2) # 1000 <_entry-0x7ffff000>
    800019e4:	9bbd                	andi	a5,a5,-17
    800019e6:	e11c                	sd	a5,0(a0)
    for (uint64 va = begin; va < end; va += PGSIZE) {
    800019e8:	94da                	add	s1,s1,s6
    800019ea:	fd54eae3          	bltu	s1,s5,800019be <uvm2kvm+0x40>
    }
}
    800019ee:	70e2                	ld	ra,56(sp)
    800019f0:	7442                	ld	s0,48(sp)
    800019f2:	74a2                	ld	s1,40(sp)
    800019f4:	7902                	ld	s2,32(sp)
    800019f6:	69e2                	ld	s3,24(sp)
    800019f8:	6a42                	ld	s4,16(sp)
    800019fa:	6aa2                	ld	s5,8(sp)
    800019fc:	6b02                	ld	s6,0(sp)
    800019fe:	6121                	addi	sp,sp,64
    80001a00:	8082                	ret
        panic("new size lower than old size");
    80001a02:	00006517          	auipc	a0,0x6
    80001a06:	7f650513          	addi	a0,a0,2038 # 800081f8 <digits+0x1b8>
    80001a0a:	fffff097          	auipc	ra,0xfffff
    80001a0e:	b3e080e7          	jalr	-1218(ra) # 80000548 <panic>
        panic("new size too big");
    80001a12:	00007517          	auipc	a0,0x7
    80001a16:	80650513          	addi	a0,a0,-2042 # 80008218 <digits+0x1d8>
    80001a1a:	fffff097          	auipc	ra,0xfffff
    80001a1e:	b2e080e7          	jalr	-1234(ra) # 80000548 <panic>
            panic("user page table not found");
    80001a22:	00007517          	auipc	a0,0x7
    80001a26:	80e50513          	addi	a0,a0,-2034 # 80008230 <digits+0x1f0>
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	b1e080e7          	jalr	-1250(ra) # 80000548 <panic>
            panic("kernel page table not found");
    80001a32:	00007517          	auipc	a0,0x7
    80001a36:	81e50513          	addi	a0,a0,-2018 # 80008250 <digits+0x210>
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	b0e080e7          	jalr	-1266(ra) # 80000548 <panic>

0000000080001a42 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001a42:	1101                	addi	sp,sp,-32
    80001a44:	ec06                	sd	ra,24(sp)
    80001a46:	e822                	sd	s0,16(sp)
    80001a48:	e426                	sd	s1,8(sp)
    80001a4a:	1000                	addi	s0,sp,32
    80001a4c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001a4e:	fffff097          	auipc	ra,0xfffff
    80001a52:	148080e7          	jalr	328(ra) # 80000b96 <holding>
    80001a56:	c909                	beqz	a0,80001a68 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001a58:	749c                	ld	a5,40(s1)
    80001a5a:	00978f63          	beq	a5,s1,80001a78 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6105                	addi	sp,sp,32
    80001a66:	8082                	ret
    panic("wakeup1");
    80001a68:	00007517          	auipc	a0,0x7
    80001a6c:	80850513          	addi	a0,a0,-2040 # 80008270 <digits+0x230>
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	ad8080e7          	jalr	-1320(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a78:	4c98                	lw	a4,24(s1)
    80001a7a:	4785                	li	a5,1
    80001a7c:	fef711e3          	bne	a4,a5,80001a5e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a80:	4789                	li	a5,2
    80001a82:	cc9c                	sw	a5,24(s1)
}
    80001a84:	bfe9                	j	80001a5e <wakeup1+0x1c>

0000000080001a86 <procinit>:
{
    80001a86:	7179                	addi	sp,sp,-48
    80001a88:	f406                	sd	ra,40(sp)
    80001a8a:	f022                	sd	s0,32(sp)
    80001a8c:	ec26                	sd	s1,24(sp)
    80001a8e:	e84a                	sd	s2,16(sp)
    80001a90:	e44e                	sd	s3,8(sp)
    80001a92:	1800                	addi	s0,sp,48
  initlock(&pid_lock, "nextpid");
    80001a94:	00006597          	auipc	a1,0x6
    80001a98:	7e458593          	addi	a1,a1,2020 # 80008278 <digits+0x238>
    80001a9c:	00010517          	auipc	a0,0x10
    80001aa0:	eb450513          	addi	a0,a0,-332 # 80011950 <pid_lock>
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	0dc080e7          	jalr	220(ra) # 80000b80 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aac:	00010497          	auipc	s1,0x10
    80001ab0:	2bc48493          	addi	s1,s1,700 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001ab4:	00006997          	auipc	s3,0x6
    80001ab8:	7cc98993          	addi	s3,s3,1996 # 80008280 <digits+0x240>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001abc:	00016917          	auipc	s2,0x16
    80001ac0:	eac90913          	addi	s2,s2,-340 # 80017968 <tickslock>
      initlock(&p->lock, "proc");
    80001ac4:	85ce                	mv	a1,s3
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	0b8080e7          	jalr	184(ra) # 80000b80 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ad0:	17048493          	addi	s1,s1,368
    80001ad4:	ff2498e3          	bne	s1,s2,80001ac4 <procinit+0x3e>
}
    80001ad8:	70a2                	ld	ra,40(sp)
    80001ada:	7402                	ld	s0,32(sp)
    80001adc:	64e2                	ld	s1,24(sp)
    80001ade:	6942                	ld	s2,16(sp)
    80001ae0:	69a2                	ld	s3,8(sp)
    80001ae2:	6145                	addi	sp,sp,48
    80001ae4:	8082                	ret

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
    80001b66:	d9e7a783          	lw	a5,-610(a5) # 80008900 <first.1700>
    80001b6a:	eb89                	bnez	a5,80001b7c <forkret+0x32>
  usertrapret();
    80001b6c:	00001097          	auipc	ra,0x1
    80001b70:	e1c080e7          	jalr	-484(ra) # 80002988 <usertrapret>
}
    80001b74:	60a2                	ld	ra,8(sp)
    80001b76:	6402                	ld	s0,0(sp)
    80001b78:	0141                	addi	sp,sp,16
    80001b7a:	8082                	ret
    first = 0;
    80001b7c:	00007797          	auipc	a5,0x7
    80001b80:	d807a223          	sw	zero,-636(a5) # 80008900 <first.1700>
    fsinit(ROOTDEV);
    80001b84:	4505                	li	a0,1
    80001b86:	00002097          	auipc	ra,0x2
    80001b8a:	b44080e7          	jalr	-1212(ra) # 800036ca <fsinit>
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
    80001bb2:	d5678793          	addi	a5,a5,-682 # 80008904 <nextpid>
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

0000000080001bd6 <proc_free_kernel_pagetable>:
{
    80001bd6:	7179                	addi	sp,sp,-48
    80001bd8:	f406                	sd	ra,40(sp)
    80001bda:	f022                	sd	s0,32(sp)
    80001bdc:	ec26                	sd	s1,24(sp)
    80001bde:	e84a                	sd	s2,16(sp)
    80001be0:	e44e                	sd	s3,8(sp)
    80001be2:	1800                	addi	s0,sp,48
    80001be4:	84aa                	mv	s1,a0
    80001be6:	892e                	mv	s2,a1
    uvmunmap(pagetable, UART0, 1, 0);
    80001be8:	4681                	li	a3,0
    80001bea:	4605                	li	a2,1
    80001bec:	100005b7          	lui	a1,0x10000
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	8d6080e7          	jalr	-1834(ra) # 800014c6 <uvmunmap>
    uvmunmap(pagetable, VIRTIO0, 1, 0);
    80001bf8:	4681                	li	a3,0
    80001bfa:	4605                	li	a2,1
    80001bfc:	100015b7          	lui	a1,0x10001
    80001c00:	8526                	mv	a0,s1
    80001c02:	00000097          	auipc	ra,0x0
    80001c06:	8c4080e7          	jalr	-1852(ra) # 800014c6 <uvmunmap>
    uvmunmap(pagetable, PLIC, 0x400000/PGSIZE, 0);
    80001c0a:	4681                	li	a3,0
    80001c0c:	40000613          	li	a2,1024
    80001c10:	0c0005b7          	lui	a1,0xc000
    80001c14:	8526                	mv	a0,s1
    80001c16:	00000097          	auipc	ra,0x0
    80001c1a:	8b0080e7          	jalr	-1872(ra) # 800014c6 <uvmunmap>
    uvmunmap(pagetable, KERNBASE, ((uint64)etext-KERNBASE)/PGSIZE, 0);
    80001c1e:	00006997          	auipc	s3,0x6
    80001c22:	3e298993          	addi	s3,s3,994 # 80008000 <etext>
    80001c26:	4681                	li	a3,0
    80001c28:	80006617          	auipc	a2,0x80006
    80001c2c:	3d860613          	addi	a2,a2,984 # 8000 <_entry-0x7fff8000>
    80001c30:	8231                	srli	a2,a2,0xc
    80001c32:	4585                	li	a1,1
    80001c34:	05fe                	slli	a1,a1,0x1f
    80001c36:	8526                	mv	a0,s1
    80001c38:	00000097          	auipc	ra,0x0
    80001c3c:	88e080e7          	jalr	-1906(ra) # 800014c6 <uvmunmap>
    uvmunmap(pagetable, (uint64)etext, (PHYSTOP-(uint64)etext)/PGSIZE, 0);
    80001c40:	4645                	li	a2,17
    80001c42:	066e                	slli	a2,a2,0x1b
    80001c44:	41360633          	sub	a2,a2,s3
    80001c48:	4681                	li	a3,0
    80001c4a:	8231                	srli	a2,a2,0xc
    80001c4c:	85ce                	mv	a1,s3
    80001c4e:	8526                	mv	a0,s1
    80001c50:	00000097          	auipc	ra,0x0
    80001c54:	876080e7          	jalr	-1930(ra) # 800014c6 <uvmunmap>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c58:	4681                	li	a3,0
    80001c5a:	4605                	li	a2,1
    80001c5c:	040005b7          	lui	a1,0x4000
    80001c60:	15fd                	addi	a1,a1,-1
    80001c62:	05b2                	slli	a1,a1,0xc
    80001c64:	8526                	mv	a0,s1
    80001c66:	00000097          	auipc	ra,0x0
    80001c6a:	860080e7          	jalr	-1952(ra) # 800014c6 <uvmunmap>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 0);
    80001c6e:	6605                	lui	a2,0x1
    80001c70:	167d                	addi	a2,a2,-1
    80001c72:	964a                	add	a2,a2,s2
    80001c74:	4681                	li	a3,0
    80001c76:	8231                	srli	a2,a2,0xc
    80001c78:	4581                	li	a1,0
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	00000097          	auipc	ra,0x0
    80001c80:	84a080e7          	jalr	-1974(ra) # 800014c6 <uvmunmap>
    freewalk(pagetable);
    80001c84:	8526                	mv	a0,s1
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	a96080e7          	jalr	-1386(ra) # 8000171c <freewalk>
}
    80001c8e:	70a2                	ld	ra,40(sp)
    80001c90:	7402                	ld	s0,32(sp)
    80001c92:	64e2                	ld	s1,24(sp)
    80001c94:	6942                	ld	s2,16(sp)
    80001c96:	69a2                	ld	s3,8(sp)
    80001c98:	6145                	addi	sp,sp,48
    80001c9a:	8082                	ret

0000000080001c9c <proc_pagetable>:
{
    80001c9c:	1101                	addi	sp,sp,-32
    80001c9e:	ec06                	sd	ra,24(sp)
    80001ca0:	e822                	sd	s0,16(sp)
    80001ca2:	e426                	sd	s1,8(sp)
    80001ca4:	e04a                	sd	s2,0(sp)
    80001ca6:	1000                	addi	s0,sp,32
    80001ca8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	8e0080e7          	jalr	-1824(ra) # 8000158a <uvmcreate>
    80001cb2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001cb4:	c121                	beqz	a0,80001cf4 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cb6:	4729                	li	a4,10
    80001cb8:	00005697          	auipc	a3,0x5
    80001cbc:	34868693          	addi	a3,a3,840 # 80007000 <_trampoline>
    80001cc0:	6605                	lui	a2,0x1
    80001cc2:	040005b7          	lui	a1,0x4000
    80001cc6:	15fd                	addi	a1,a1,-1
    80001cc8:	05b2                	slli	a1,a1,0xc
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	598080e7          	jalr	1432(ra) # 80001262 <mappages>
    80001cd2:	02054863          	bltz	a0,80001d02 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cd6:	4719                	li	a4,6
    80001cd8:	05893683          	ld	a3,88(s2)
    80001cdc:	6605                	lui	a2,0x1
    80001cde:	020005b7          	lui	a1,0x2000
    80001ce2:	15fd                	addi	a1,a1,-1
    80001ce4:	05b6                	slli	a1,a1,0xd
    80001ce6:	8526                	mv	a0,s1
    80001ce8:	fffff097          	auipc	ra,0xfffff
    80001cec:	57a080e7          	jalr	1402(ra) # 80001262 <mappages>
    80001cf0:	02054163          	bltz	a0,80001d12 <proc_pagetable+0x76>
}
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	60e2                	ld	ra,24(sp)
    80001cf8:	6442                	ld	s0,16(sp)
    80001cfa:	64a2                	ld	s1,8(sp)
    80001cfc:	6902                	ld	s2,0(sp)
    80001cfe:	6105                	addi	sp,sp,32
    80001d00:	8082                	ret
    uvmfree(pagetable, 0);
    80001d02:	4581                	li	a1,0
    80001d04:	8526                	mv	a0,s1
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	a80080e7          	jalr	-1408(ra) # 80001786 <uvmfree>
    return 0;
    80001d0e:	4481                	li	s1,0
    80001d10:	b7d5                	j	80001cf4 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d12:	4681                	li	a3,0
    80001d14:	4605                	li	a2,1
    80001d16:	040005b7          	lui	a1,0x4000
    80001d1a:	15fd                	addi	a1,a1,-1
    80001d1c:	05b2                	slli	a1,a1,0xc
    80001d1e:	8526                	mv	a0,s1
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	7a6080e7          	jalr	1958(ra) # 800014c6 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d28:	4581                	li	a1,0
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	a5a080e7          	jalr	-1446(ra) # 80001786 <uvmfree>
    return 0;
    80001d34:	4481                	li	s1,0
    80001d36:	bf7d                	j	80001cf4 <proc_pagetable+0x58>

0000000080001d38 <proc_freepagetable>:
{
    80001d38:	1101                	addi	sp,sp,-32
    80001d3a:	ec06                	sd	ra,24(sp)
    80001d3c:	e822                	sd	s0,16(sp)
    80001d3e:	e426                	sd	s1,8(sp)
    80001d40:	e04a                	sd	s2,0(sp)
    80001d42:	1000                	addi	s0,sp,32
    80001d44:	84aa                	mv	s1,a0
    80001d46:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d48:	4681                	li	a3,0
    80001d4a:	4605                	li	a2,1
    80001d4c:	040005b7          	lui	a1,0x4000
    80001d50:	15fd                	addi	a1,a1,-1
    80001d52:	05b2                	slli	a1,a1,0xc
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	772080e7          	jalr	1906(ra) # 800014c6 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d5c:	4681                	li	a3,0
    80001d5e:	4605                	li	a2,1
    80001d60:	020005b7          	lui	a1,0x2000
    80001d64:	15fd                	addi	a1,a1,-1
    80001d66:	05b6                	slli	a1,a1,0xd
    80001d68:	8526                	mv	a0,s1
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	75c080e7          	jalr	1884(ra) # 800014c6 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d72:	85ca                	mv	a1,s2
    80001d74:	8526                	mv	a0,s1
    80001d76:	00000097          	auipc	ra,0x0
    80001d7a:	a10080e7          	jalr	-1520(ra) # 80001786 <uvmfree>
}
    80001d7e:	60e2                	ld	ra,24(sp)
    80001d80:	6442                	ld	s0,16(sp)
    80001d82:	64a2                	ld	s1,8(sp)
    80001d84:	6902                	ld	s2,0(sp)
    80001d86:	6105                	addi	sp,sp,32
    80001d88:	8082                	ret

0000000080001d8a <freeproc>:
{
    80001d8a:	1101                	addi	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	1000                	addi	s0,sp,32
    80001d94:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d96:	6d28                	ld	a0,88(a0)
    80001d98:	c509                	beqz	a0,80001da2 <freeproc+0x18>
     kfree((void*)p->trapframe);
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	c8a080e7          	jalr	-886(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001da2:	0404bc23          	sd	zero,88(s1)
  if (p->kstack)
    80001da6:	60ac                	ld	a1,64(s1)
    80001da8:	e9b9                	bnez	a1,80001dfe <freeproc+0x74>
  p->kstack = 0;
    80001daa:	0404b023          	sd	zero,64(s1)
  if(p->kernel_pagetable)
    80001dae:	1684b503          	ld	a0,360(s1)
    80001db2:	c511                	beqz	a0,80001dbe <freeproc+0x34>
      proc_free_kernel_pagetable(p->kernel_pagetable,p->sz);
    80001db4:	64ac                	ld	a1,72(s1)
    80001db6:	00000097          	auipc	ra,0x0
    80001dba:	e20080e7          	jalr	-480(ra) # 80001bd6 <proc_free_kernel_pagetable>
  p->kernel_pagetable = 0;
    80001dbe:	1604b423          	sd	zero,360(s1)
  if(p->pagetable)
    80001dc2:	68a8                	ld	a0,80(s1)
    80001dc4:	c511                	beqz	a0,80001dd0 <freeproc+0x46>
    proc_freepagetable(p->pagetable, p->sz);
    80001dc6:	64ac                	ld	a1,72(s1)
    80001dc8:	00000097          	auipc	ra,0x0
    80001dcc:	f70080e7          	jalr	-144(ra) # 80001d38 <proc_freepagetable>
  p->pagetable = 0;
    80001dd0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001dd4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001dd8:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001ddc:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001de0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001de4:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001de8:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001dec:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001df0:	0004ac23          	sw	zero,24(s1)
}
    80001df4:	60e2                	ld	ra,24(sp)
    80001df6:	6442                	ld	s0,16(sp)
    80001df8:	64a2                	ld	s1,8(sp)
    80001dfa:	6105                	addi	sp,sp,32
    80001dfc:	8082                	ret
      uvmunmap(p->kernel_pagetable, p->kstack, 1, 1);
    80001dfe:	4685                	li	a3,1
    80001e00:	4605                	li	a2,1
    80001e02:	1684b503          	ld	a0,360(s1)
    80001e06:	fffff097          	auipc	ra,0xfffff
    80001e0a:	6c0080e7          	jalr	1728(ra) # 800014c6 <uvmunmap>
    80001e0e:	bf71                	j	80001daa <freeproc+0x20>

0000000080001e10 <allocproc>:
{
    80001e10:	1101                	addi	sp,sp,-32
    80001e12:	ec06                	sd	ra,24(sp)
    80001e14:	e822                	sd	s0,16(sp)
    80001e16:	e426                	sd	s1,8(sp)
    80001e18:	e04a                	sd	s2,0(sp)
    80001e1a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e1c:	00010497          	auipc	s1,0x10
    80001e20:	f4c48493          	addi	s1,s1,-180 # 80011d68 <proc>
    80001e24:	00016917          	auipc	s2,0x16
    80001e28:	b4490913          	addi	s2,s2,-1212 # 80017968 <tickslock>
    acquire(&p->lock);
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	de2080e7          	jalr	-542(ra) # 80000c10 <acquire>
    if(p->state == UNUSED) {
    80001e36:	4c9c                	lw	a5,24(s1)
    80001e38:	cf81                	beqz	a5,80001e50 <allocproc+0x40>
      release(&p->lock);
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	e88080e7          	jalr	-376(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e44:	17048493          	addi	s1,s1,368
    80001e48:	ff2492e3          	bne	s1,s2,80001e2c <allocproc+0x1c>
  return 0;
    80001e4c:	4481                	li	s1,0
    80001e4e:	a065                	j	80001ef6 <allocproc+0xe6>
  p->pid = allocpid();
    80001e50:	00000097          	auipc	ra,0x0
    80001e54:	d40080e7          	jalr	-704(ra) # 80001b90 <allocpid>
    80001e58:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	cc6080e7          	jalr	-826(ra) # 80000b20 <kalloc>
    80001e62:	892a                	mv	s2,a0
    80001e64:	eca8                	sd	a0,88(s1)
    80001e66:	cd59                	beqz	a0,80001f04 <allocproc+0xf4>
  p->pagetable = proc_pagetable(p);
    80001e68:	8526                	mv	a0,s1
    80001e6a:	00000097          	auipc	ra,0x0
    80001e6e:	e32080e7          	jalr	-462(ra) # 80001c9c <proc_pagetable>
    80001e72:	892a                	mv	s2,a0
    80001e74:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001e76:	cd51                	beqz	a0,80001f12 <allocproc+0x102>
  p->kernel_pagetable = kvmbuild();
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	478080e7          	jalr	1144(ra) # 800012f0 <kvmbuild>
    80001e80:	16a4b423          	sd	a0,360(s1)
  char *pa = kalloc();
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	c9c080e7          	jalr	-868(ra) # 80000b20 <kalloc>
    80001e8c:	86aa                	mv	a3,a0
  if(pa == 0)
    80001e8e:	cd51                	beqz	a0,80001f2a <allocproc+0x11a>
  uint64 va = KSTACK((int) (p - proc));
    80001e90:	00010797          	auipc	a5,0x10
    80001e94:	ed878793          	addi	a5,a5,-296 # 80011d68 <proc>
    80001e98:	40f487b3          	sub	a5,s1,a5
    80001e9c:	8791                	srai	a5,a5,0x4
    80001e9e:	00006717          	auipc	a4,0x6
    80001ea2:	16273703          	ld	a4,354(a4) # 80008000 <etext>
    80001ea6:	02e787b3          	mul	a5,a5,a4
    80001eaa:	2785                	addiw	a5,a5,1
    80001eac:	00d7979b          	slliw	a5,a5,0xd
    80001eb0:	04000937          	lui	s2,0x4000
    80001eb4:	197d                	addi	s2,s2,-1
    80001eb6:	0932                	slli	s2,s2,0xc
    80001eb8:	40f90933          	sub	s2,s2,a5
  mappages(p->kernel_pagetable, va, PGSIZE, (uint64)pa, PTE_R | PTE_W);
    80001ebc:	4719                	li	a4,6
    80001ebe:	6605                	lui	a2,0x1
    80001ec0:	85ca                	mv	a1,s2
    80001ec2:	1684b503          	ld	a0,360(s1)
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	39c080e7          	jalr	924(ra) # 80001262 <mappages>
  p->kstack = va;
    80001ece:	0524b023          	sd	s2,64(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001ed2:	07000613          	li	a2,112
    80001ed6:	4581                	li	a1,0
    80001ed8:	06048513          	addi	a0,s1,96
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	e30080e7          	jalr	-464(ra) # 80000d0c <memset>
  p->context.ra = (uint64)forkret;
    80001ee4:	00000797          	auipc	a5,0x0
    80001ee8:	c6678793          	addi	a5,a5,-922 # 80001b4a <forkret>
    80001eec:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001eee:	60bc                	ld	a5,64(s1)
    80001ef0:	6705                	lui	a4,0x1
    80001ef2:	97ba                	add	a5,a5,a4
    80001ef4:	f4bc                	sd	a5,104(s1)
}
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	60e2                	ld	ra,24(sp)
    80001efa:	6442                	ld	s0,16(sp)
    80001efc:	64a2                	ld	s1,8(sp)
    80001efe:	6902                	ld	s2,0(sp)
    80001f00:	6105                	addi	sp,sp,32
    80001f02:	8082                	ret
    release(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	dbe080e7          	jalr	-578(ra) # 80000cc4 <release>
    return 0;
    80001f0e:	84ca                	mv	s1,s2
    80001f10:	b7dd                	j	80001ef6 <allocproc+0xe6>
    freeproc(p);
    80001f12:	8526                	mv	a0,s1
    80001f14:	00000097          	auipc	ra,0x0
    80001f18:	e76080e7          	jalr	-394(ra) # 80001d8a <freeproc>
    release(&p->lock);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	da6080e7          	jalr	-602(ra) # 80000cc4 <release>
    return 0;
    80001f26:	84ca                	mv	s1,s2
    80001f28:	b7f9                	j	80001ef6 <allocproc+0xe6>
      panic("kalloc");
    80001f2a:	00006517          	auipc	a0,0x6
    80001f2e:	35e50513          	addi	a0,a0,862 # 80008288 <digits+0x248>
    80001f32:	ffffe097          	auipc	ra,0xffffe
    80001f36:	616080e7          	jalr	1558(ra) # 80000548 <panic>

0000000080001f3a <userinit>:
{
    80001f3a:	1101                	addi	sp,sp,-32
    80001f3c:	ec06                	sd	ra,24(sp)
    80001f3e:	e822                	sd	s0,16(sp)
    80001f40:	e426                	sd	s1,8(sp)
    80001f42:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f44:	00000097          	auipc	ra,0x0
    80001f48:	ecc080e7          	jalr	-308(ra) # 80001e10 <allocproc>
    80001f4c:	84aa                	mv	s1,a0
  initproc = p;
    80001f4e:	00007797          	auipc	a5,0x7
    80001f52:	0ca7b523          	sd	a0,202(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f56:	03400613          	li	a2,52
    80001f5a:	00007597          	auipc	a1,0x7
    80001f5e:	9b658593          	addi	a1,a1,-1610 # 80008910 <initcode>
    80001f62:	6928                	ld	a0,80(a0)
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	654080e7          	jalr	1620(ra) # 800015b8 <uvminit>
  p->sz = PGSIZE;
    80001f6c:	6785                	lui	a5,0x1
    80001f6e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001f70:	6cb8                	ld	a4,88(s1)
    80001f72:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001f76:	6cb8                	ld	a4,88(s1)
    80001f78:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f7a:	4641                	li	a2,16
    80001f7c:	00006597          	auipc	a1,0x6
    80001f80:	31458593          	addi	a1,a1,788 # 80008290 <digits+0x250>
    80001f84:	15848513          	addi	a0,s1,344
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	eda080e7          	jalr	-294(ra) # 80000e62 <safestrcpy>
  p->cwd = namei("/");
    80001f90:	00006517          	auipc	a0,0x6
    80001f94:	31050513          	addi	a0,a0,784 # 800082a0 <digits+0x260>
    80001f98:	00002097          	auipc	ra,0x2
    80001f9c:	15a080e7          	jalr	346(ra) # 800040f2 <namei>
    80001fa0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001fa4:	4789                	li	a5,2
    80001fa6:	cc9c                	sw	a5,24(s1)
  uvm2kvm(p->pagetable, p->kernel_pagetable, 0, p->sz);
    80001fa8:	64b4                	ld	a3,72(s1)
    80001faa:	4601                	li	a2,0
    80001fac:	1684b583          	ld	a1,360(s1)
    80001fb0:	68a8                	ld	a0,80(s1)
    80001fb2:	00000097          	auipc	ra,0x0
    80001fb6:	9cc080e7          	jalr	-1588(ra) # 8000197e <uvm2kvm>
  release(&p->lock);
    80001fba:	8526                	mv	a0,s1
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	d08080e7          	jalr	-760(ra) # 80000cc4 <release>
}
    80001fc4:	60e2                	ld	ra,24(sp)
    80001fc6:	6442                	ld	s0,16(sp)
    80001fc8:	64a2                	ld	s1,8(sp)
    80001fca:	6105                	addi	sp,sp,32
    80001fcc:	8082                	ret

0000000080001fce <growproc>:
{
    80001fce:	7179                	addi	sp,sp,-48
    80001fd0:	f406                	sd	ra,40(sp)
    80001fd2:	f022                	sd	s0,32(sp)
    80001fd4:	ec26                	sd	s1,24(sp)
    80001fd6:	e84a                	sd	s2,16(sp)
    80001fd8:	e44e                	sd	s3,8(sp)
    80001fda:	e052                	sd	s4,0(sp)
    80001fdc:	1800                	addi	s0,sp,48
    80001fde:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fe0:	00000097          	auipc	ra,0x0
    80001fe4:	b32080e7          	jalr	-1230(ra) # 80001b12 <myproc>
    80001fe8:	892a                	mv	s2,a0
  sz = p->sz;
    80001fea:	652c                	ld	a1,72(a0)
    80001fec:	0005899b          	sext.w	s3,a1
  if(n > 0){
    80001ff0:	02904263          	bgtz	s1,80002014 <growproc+0x46>
  } else if(n < 0){
    80001ff4:	0604c163          	bltz	s1,80002056 <growproc+0x88>
  p->sz = sz;
    80001ff8:	02099613          	slli	a2,s3,0x20
    80001ffc:	9201                	srli	a2,a2,0x20
    80001ffe:	04c93423          	sd	a2,72(s2) # 4000048 <_entry-0x7bffffb8>
  return 0;
    80002002:	4501                	li	a0,0
}
    80002004:	70a2                	ld	ra,40(sp)
    80002006:	7402                	ld	s0,32(sp)
    80002008:	64e2                	ld	s1,24(sp)
    8000200a:	6942                	ld	s2,16(sp)
    8000200c:	69a2                	ld	s3,8(sp)
    8000200e:	6a02                	ld	s4,0(sp)
    80002010:	6145                	addi	sp,sp,48
    80002012:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002014:	00048a1b          	sext.w	s4,s1
    80002018:	0134863b          	addw	a2,s1,s3
    8000201c:	1602                	slli	a2,a2,0x20
    8000201e:	9201                	srli	a2,a2,0x20
    80002020:	1582                	slli	a1,a1,0x20
    80002022:	9181                	srli	a1,a1,0x20
    80002024:	6928                	ld	a0,80(a0)
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	64c080e7          	jalr	1612(ra) # 80001672 <uvmalloc>
    8000202e:	0005099b          	sext.w	s3,a0
    80002032:	06098763          	beqz	s3,800020a0 <growproc+0xd2>
    uvm2kvm(p->pagetable, p->kernel_pagetable, sz - n, sz);
    80002036:	4149863b          	subw	a2,s3,s4
    8000203a:	02051693          	slli	a3,a0,0x20
    8000203e:	9281                	srli	a3,a3,0x20
    80002040:	1602                	slli	a2,a2,0x20
    80002042:	9201                	srli	a2,a2,0x20
    80002044:	16893583          	ld	a1,360(s2)
    80002048:	05093503          	ld	a0,80(s2)
    8000204c:	00000097          	auipc	ra,0x0
    80002050:	932080e7          	jalr	-1742(ra) # 8000197e <uvm2kvm>
    80002054:	b755                	j	80001ff8 <growproc+0x2a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002056:	0134863b          	addw	a2,s1,s3
    8000205a:	1602                	slli	a2,a2,0x20
    8000205c:	9201                	srli	a2,a2,0x20
    8000205e:	1582                	slli	a1,a1,0x20
    80002060:	9181                	srli	a1,a1,0x20
    80002062:	6928                	ld	a0,80(a0)
    80002064:	fffff097          	auipc	ra,0xfffff
    80002068:	5c6080e7          	jalr	1478(ra) # 8000162a <uvmdealloc>
    8000206c:	0005099b          	sext.w	s3,a0
    uvmunmap(p->kernel_pagetable, PGROUNDUP(sz), (-n)/PGSIZE, 0);
    80002070:	41f4d61b          	sraiw	a2,s1,0x1f
    80002074:	0146561b          	srliw	a2,a2,0x14
    80002078:	9e25                	addw	a2,a2,s1
    8000207a:	40c6561b          	sraiw	a2,a2,0xc
    8000207e:	6585                	lui	a1,0x1
    80002080:	35fd                	addiw	a1,a1,-1
    80002082:	9da9                	addw	a1,a1,a0
    80002084:	757d                	lui	a0,0xfffff
    80002086:	8de9                	and	a1,a1,a0
    80002088:	1582                	slli	a1,a1,0x20
    8000208a:	9181                	srli	a1,a1,0x20
    8000208c:	4681                	li	a3,0
    8000208e:	40c0063b          	negw	a2,a2
    80002092:	16893503          	ld	a0,360(s2)
    80002096:	fffff097          	auipc	ra,0xfffff
    8000209a:	430080e7          	jalr	1072(ra) # 800014c6 <uvmunmap>
    8000209e:	bfa9                	j	80001ff8 <growproc+0x2a>
      return -1;
    800020a0:	557d                	li	a0,-1
    800020a2:	b78d                	j	80002004 <growproc+0x36>

00000000800020a4 <fork>:
{
    800020a4:	7179                	addi	sp,sp,-48
    800020a6:	f406                	sd	ra,40(sp)
    800020a8:	f022                	sd	s0,32(sp)
    800020aa:	ec26                	sd	s1,24(sp)
    800020ac:	e84a                	sd	s2,16(sp)
    800020ae:	e44e                	sd	s3,8(sp)
    800020b0:	e052                	sd	s4,0(sp)
    800020b2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020b4:	00000097          	auipc	ra,0x0
    800020b8:	a5e080e7          	jalr	-1442(ra) # 80001b12 <myproc>
    800020bc:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800020be:	00000097          	auipc	ra,0x0
    800020c2:	d52080e7          	jalr	-686(ra) # 80001e10 <allocproc>
    800020c6:	cd6d                	beqz	a0,800021c0 <fork+0x11c>
    800020c8:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020ca:	04893603          	ld	a2,72(s2)
    800020ce:	692c                	ld	a1,80(a0)
    800020d0:	05093503          	ld	a0,80(s2)
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	6ea080e7          	jalr	1770(ra) # 800017be <uvmcopy>
    800020dc:	04054863          	bltz	a0,8000212c <fork+0x88>
  np->sz = p->sz;
    800020e0:	04893783          	ld	a5,72(s2)
    800020e4:	04f9b423          	sd	a5,72(s3)
  np->parent = p;
    800020e8:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    800020ec:	05893683          	ld	a3,88(s2)
    800020f0:	87b6                	mv	a5,a3
    800020f2:	0589b703          	ld	a4,88(s3)
    800020f6:	12068693          	addi	a3,a3,288
    800020fa:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800020fe:	6788                	ld	a0,8(a5)
    80002100:	6b8c                	ld	a1,16(a5)
    80002102:	6f90                	ld	a2,24(a5)
    80002104:	01073023          	sd	a6,0(a4)
    80002108:	e708                	sd	a0,8(a4)
    8000210a:	eb0c                	sd	a1,16(a4)
    8000210c:	ef10                	sd	a2,24(a4)
    8000210e:	02078793          	addi	a5,a5,32
    80002112:	02070713          	addi	a4,a4,32
    80002116:	fed792e3          	bne	a5,a3,800020fa <fork+0x56>
  np->trapframe->a0 = 0;
    8000211a:	0589b783          	ld	a5,88(s3)
    8000211e:	0607b823          	sd	zero,112(a5)
    80002122:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80002126:	15000a13          	li	s4,336
    8000212a:	a03d                	j	80002158 <fork+0xb4>
    freeproc(np);
    8000212c:	854e                	mv	a0,s3
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	c5c080e7          	jalr	-932(ra) # 80001d8a <freeproc>
    release(&np->lock);
    80002136:	854e                	mv	a0,s3
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	b8c080e7          	jalr	-1140(ra) # 80000cc4 <release>
    return -1;
    80002140:	54fd                	li	s1,-1
    80002142:	a0b5                	j	800021ae <fork+0x10a>
      np->ofile[i] = filedup(p->ofile[i]);
    80002144:	00002097          	auipc	ra,0x2
    80002148:	63a080e7          	jalr	1594(ra) # 8000477e <filedup>
    8000214c:	009987b3          	add	a5,s3,s1
    80002150:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002152:	04a1                	addi	s1,s1,8
    80002154:	01448763          	beq	s1,s4,80002162 <fork+0xbe>
    if(p->ofile[i])
    80002158:	009907b3          	add	a5,s2,s1
    8000215c:	6388                	ld	a0,0(a5)
    8000215e:	f17d                	bnez	a0,80002144 <fork+0xa0>
    80002160:	bfcd                	j	80002152 <fork+0xae>
  np->cwd = idup(p->cwd);
    80002162:	15093503          	ld	a0,336(s2)
    80002166:	00001097          	auipc	ra,0x1
    8000216a:	79e080e7          	jalr	1950(ra) # 80003904 <idup>
    8000216e:	14a9b823          	sd	a0,336(s3)
  uvm2kvm(np->pagetable, np->kernel_pagetable, 0, np->sz);
    80002172:	0489b683          	ld	a3,72(s3)
    80002176:	4601                	li	a2,0
    80002178:	1689b583          	ld	a1,360(s3)
    8000217c:	0509b503          	ld	a0,80(s3)
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	7fe080e7          	jalr	2046(ra) # 8000197e <uvm2kvm>
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002188:	4641                	li	a2,16
    8000218a:	15890593          	addi	a1,s2,344
    8000218e:	15898513          	addi	a0,s3,344
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	cd0080e7          	jalr	-816(ra) # 80000e62 <safestrcpy>
  pid = np->pid;
    8000219a:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    8000219e:	4789                	li	a5,2
    800021a0:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800021a4:	854e                	mv	a0,s3
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	b1e080e7          	jalr	-1250(ra) # 80000cc4 <release>
}
    800021ae:	8526                	mv	a0,s1
    800021b0:	70a2                	ld	ra,40(sp)
    800021b2:	7402                	ld	s0,32(sp)
    800021b4:	64e2                	ld	s1,24(sp)
    800021b6:	6942                	ld	s2,16(sp)
    800021b8:	69a2                	ld	s3,8(sp)
    800021ba:	6a02                	ld	s4,0(sp)
    800021bc:	6145                	addi	sp,sp,48
    800021be:	8082                	ret
    return -1;
    800021c0:	54fd                	li	s1,-1
    800021c2:	b7f5                	j	800021ae <fork+0x10a>

00000000800021c4 <reparent>:
{
    800021c4:	7179                	addi	sp,sp,-48
    800021c6:	f406                	sd	ra,40(sp)
    800021c8:	f022                	sd	s0,32(sp)
    800021ca:	ec26                	sd	s1,24(sp)
    800021cc:	e84a                	sd	s2,16(sp)
    800021ce:	e44e                	sd	s3,8(sp)
    800021d0:	e052                	sd	s4,0(sp)
    800021d2:	1800                	addi	s0,sp,48
    800021d4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021d6:	00010497          	auipc	s1,0x10
    800021da:	b9248493          	addi	s1,s1,-1134 # 80011d68 <proc>
      pp->parent = initproc;
    800021de:	00007a17          	auipc	s4,0x7
    800021e2:	e3aa0a13          	addi	s4,s4,-454 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e6:	00015997          	auipc	s3,0x15
    800021ea:	78298993          	addi	s3,s3,1922 # 80017968 <tickslock>
    800021ee:	a029                	j	800021f8 <reparent+0x34>
    800021f0:	17048493          	addi	s1,s1,368
    800021f4:	03348363          	beq	s1,s3,8000221a <reparent+0x56>
    if(pp->parent == p){
    800021f8:	709c                	ld	a5,32(s1)
    800021fa:	ff279be3          	bne	a5,s2,800021f0 <reparent+0x2c>
      acquire(&pp->lock);
    800021fe:	8526                	mv	a0,s1
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	a10080e7          	jalr	-1520(ra) # 80000c10 <acquire>
      pp->parent = initproc;
    80002208:	000a3783          	ld	a5,0(s4)
    8000220c:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	ab4080e7          	jalr	-1356(ra) # 80000cc4 <release>
    80002218:	bfe1                	j	800021f0 <reparent+0x2c>
}
    8000221a:	70a2                	ld	ra,40(sp)
    8000221c:	7402                	ld	s0,32(sp)
    8000221e:	64e2                	ld	s1,24(sp)
    80002220:	6942                	ld	s2,16(sp)
    80002222:	69a2                	ld	s3,8(sp)
    80002224:	6a02                	ld	s4,0(sp)
    80002226:	6145                	addi	sp,sp,48
    80002228:	8082                	ret

000000008000222a <scheduler>:
{
    8000222a:	715d                	addi	sp,sp,-80
    8000222c:	e486                	sd	ra,72(sp)
    8000222e:	e0a2                	sd	s0,64(sp)
    80002230:	fc26                	sd	s1,56(sp)
    80002232:	f84a                	sd	s2,48(sp)
    80002234:	f44e                	sd	s3,40(sp)
    80002236:	f052                	sd	s4,32(sp)
    80002238:	ec56                	sd	s5,24(sp)
    8000223a:	e85a                	sd	s6,16(sp)
    8000223c:	e45e                	sd	s7,8(sp)
    8000223e:	e062                	sd	s8,0(sp)
    80002240:	0880                	addi	s0,sp,80
    80002242:	8792                	mv	a5,tp
  int id = r_tp();
    80002244:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002246:	00779b13          	slli	s6,a5,0x7
    8000224a:	0000f717          	auipc	a4,0xf
    8000224e:	70670713          	addi	a4,a4,1798 # 80011950 <pid_lock>
    80002252:	975a                	add	a4,a4,s6
    80002254:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002258:	0000f717          	auipc	a4,0xf
    8000225c:	71870713          	addi	a4,a4,1816 # 80011970 <cpus+0x8>
    80002260:	9b3a                	add	s6,s6,a4
        c->proc = p;
    80002262:	079e                	slli	a5,a5,0x7
    80002264:	0000fa17          	auipc	s4,0xf
    80002268:	6eca0a13          	addi	s4,s4,1772 # 80011950 <pid_lock>
    8000226c:	9a3e                	add	s4,s4,a5
        w_satp(MAKE_SATP(p->kernel_pagetable));
    8000226e:	5bfd                	li	s7,-1
    80002270:	1bfe                	slli	s7,s7,0x3f
    for(p = proc; p < &proc[NPROC]; p++) {
    80002272:	00015997          	auipc	s3,0x15
    80002276:	6f698993          	addi	s3,s3,1782 # 80017968 <tickslock>
    8000227a:	a885                	j	800022ea <scheduler+0xc0>
        p->state = RUNNING;
    8000227c:	0154ac23          	sw	s5,24(s1)
        c->proc = p;
    80002280:	009a3c23          	sd	s1,24(s4)
        w_satp(MAKE_SATP(p->kernel_pagetable));
    80002284:	1684b783          	ld	a5,360(s1)
    80002288:	83b1                	srli	a5,a5,0xc
    8000228a:	0177e7b3          	or	a5,a5,s7
  asm volatile("csrw satp, %0" : : "r" (x));
    8000228e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80002292:	12000073          	sfence.vma
        swtch(&c->context, &p->context);
    80002296:	06048593          	addi	a1,s1,96
    8000229a:	855a                	mv	a0,s6
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	642080e7          	jalr	1602(ra) # 800028de <swtch>
        kvminithart(); // use kernel page table
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	e4a080e7          	jalr	-438(ra) # 800010ee <kvminithart>
        c->proc = 0;
    800022ac:	000a3c23          	sd	zero,24(s4)
        found = 1;
    800022b0:	4c05                	li	s8,1
      release(&p->lock);
    800022b2:	8526                	mv	a0,s1
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	a10080e7          	jalr	-1520(ra) # 80000cc4 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800022bc:	17048493          	addi	s1,s1,368
    800022c0:	01348b63          	beq	s1,s3,800022d6 <scheduler+0xac>
      acquire(&p->lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	94a080e7          	jalr	-1718(ra) # 80000c10 <acquire>
      if(p->state == RUNNABLE) {
    800022ce:	4c9c                	lw	a5,24(s1)
    800022d0:	ff2791e3          	bne	a5,s2,800022b2 <scheduler+0x88>
    800022d4:	b765                	j	8000227c <scheduler+0x52>
    if(found == 0) {
    800022d6:	000c1a63          	bnez	s8,800022ea <scheduler+0xc0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022de:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022e2:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800022e6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022ea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022ee:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022f2:	10079073          	csrw	sstatus,a5
    int found = 0;
    800022f6:	4c01                	li	s8,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800022f8:	00010497          	auipc	s1,0x10
    800022fc:	a7048493          	addi	s1,s1,-1424 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002300:	4909                	li	s2,2
        p->state = RUNNING;
    80002302:	4a8d                	li	s5,3
    80002304:	b7c1                	j	800022c4 <scheduler+0x9a>

0000000080002306 <sched>:
{
    80002306:	7179                	addi	sp,sp,-48
    80002308:	f406                	sd	ra,40(sp)
    8000230a:	f022                	sd	s0,32(sp)
    8000230c:	ec26                	sd	s1,24(sp)
    8000230e:	e84a                	sd	s2,16(sp)
    80002310:	e44e                	sd	s3,8(sp)
    80002312:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	7fe080e7          	jalr	2046(ra) # 80001b12 <myproc>
    8000231c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	878080e7          	jalr	-1928(ra) # 80000b96 <holding>
    80002326:	c93d                	beqz	a0,8000239c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002328:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000232a:	2781                	sext.w	a5,a5
    8000232c:	079e                	slli	a5,a5,0x7
    8000232e:	0000f717          	auipc	a4,0xf
    80002332:	62270713          	addi	a4,a4,1570 # 80011950 <pid_lock>
    80002336:	97ba                	add	a5,a5,a4
    80002338:	0907a703          	lw	a4,144(a5)
    8000233c:	4785                	li	a5,1
    8000233e:	06f71763          	bne	a4,a5,800023ac <sched+0xa6>
  if(p->state == RUNNING)
    80002342:	4c98                	lw	a4,24(s1)
    80002344:	478d                	li	a5,3
    80002346:	06f70b63          	beq	a4,a5,800023bc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000234a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000234e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002350:	efb5                	bnez	a5,800023cc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002352:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002354:	0000f917          	auipc	s2,0xf
    80002358:	5fc90913          	addi	s2,s2,1532 # 80011950 <pid_lock>
    8000235c:	2781                	sext.w	a5,a5
    8000235e:	079e                	slli	a5,a5,0x7
    80002360:	97ca                	add	a5,a5,s2
    80002362:	0947a983          	lw	s3,148(a5)
    80002366:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002368:	2781                	sext.w	a5,a5
    8000236a:	079e                	slli	a5,a5,0x7
    8000236c:	0000f597          	auipc	a1,0xf
    80002370:	60458593          	addi	a1,a1,1540 # 80011970 <cpus+0x8>
    80002374:	95be                	add	a1,a1,a5
    80002376:	06048513          	addi	a0,s1,96
    8000237a:	00000097          	auipc	ra,0x0
    8000237e:	564080e7          	jalr	1380(ra) # 800028de <swtch>
    80002382:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002384:	2781                	sext.w	a5,a5
    80002386:	079e                	slli	a5,a5,0x7
    80002388:	97ca                	add	a5,a5,s2
    8000238a:	0937aa23          	sw	s3,148(a5)
}
    8000238e:	70a2                	ld	ra,40(sp)
    80002390:	7402                	ld	s0,32(sp)
    80002392:	64e2                	ld	s1,24(sp)
    80002394:	6942                	ld	s2,16(sp)
    80002396:	69a2                	ld	s3,8(sp)
    80002398:	6145                	addi	sp,sp,48
    8000239a:	8082                	ret
    panic("sched p->lock");
    8000239c:	00006517          	auipc	a0,0x6
    800023a0:	f0c50513          	addi	a0,a0,-244 # 800082a8 <digits+0x268>
    800023a4:	ffffe097          	auipc	ra,0xffffe
    800023a8:	1a4080e7          	jalr	420(ra) # 80000548 <panic>
    panic("sched locks");
    800023ac:	00006517          	auipc	a0,0x6
    800023b0:	f0c50513          	addi	a0,a0,-244 # 800082b8 <digits+0x278>
    800023b4:	ffffe097          	auipc	ra,0xffffe
    800023b8:	194080e7          	jalr	404(ra) # 80000548 <panic>
    panic("sched running");
    800023bc:	00006517          	auipc	a0,0x6
    800023c0:	f0c50513          	addi	a0,a0,-244 # 800082c8 <digits+0x288>
    800023c4:	ffffe097          	auipc	ra,0xffffe
    800023c8:	184080e7          	jalr	388(ra) # 80000548 <panic>
    panic("sched interruptible");
    800023cc:	00006517          	auipc	a0,0x6
    800023d0:	f0c50513          	addi	a0,a0,-244 # 800082d8 <digits+0x298>
    800023d4:	ffffe097          	auipc	ra,0xffffe
    800023d8:	174080e7          	jalr	372(ra) # 80000548 <panic>

00000000800023dc <exit>:
{
    800023dc:	7179                	addi	sp,sp,-48
    800023de:	f406                	sd	ra,40(sp)
    800023e0:	f022                	sd	s0,32(sp)
    800023e2:	ec26                	sd	s1,24(sp)
    800023e4:	e84a                	sd	s2,16(sp)
    800023e6:	e44e                	sd	s3,8(sp)
    800023e8:	e052                	sd	s4,0(sp)
    800023ea:	1800                	addi	s0,sp,48
    800023ec:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	724080e7          	jalr	1828(ra) # 80001b12 <myproc>
    800023f6:	89aa                	mv	s3,a0
  if(p == initproc)
    800023f8:	00007797          	auipc	a5,0x7
    800023fc:	c207b783          	ld	a5,-992(a5) # 80009018 <initproc>
    80002400:	0d050493          	addi	s1,a0,208
    80002404:	15050913          	addi	s2,a0,336
    80002408:	02a79363          	bne	a5,a0,8000242e <exit+0x52>
    panic("init exiting");
    8000240c:	00006517          	auipc	a0,0x6
    80002410:	ee450513          	addi	a0,a0,-284 # 800082f0 <digits+0x2b0>
    80002414:	ffffe097          	auipc	ra,0xffffe
    80002418:	134080e7          	jalr	308(ra) # 80000548 <panic>
      fileclose(f);
    8000241c:	00002097          	auipc	ra,0x2
    80002420:	3b4080e7          	jalr	948(ra) # 800047d0 <fileclose>
      p->ofile[fd] = 0;
    80002424:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002428:	04a1                	addi	s1,s1,8
    8000242a:	01248563          	beq	s1,s2,80002434 <exit+0x58>
    if(p->ofile[fd]){
    8000242e:	6088                	ld	a0,0(s1)
    80002430:	f575                	bnez	a0,8000241c <exit+0x40>
    80002432:	bfdd                	j	80002428 <exit+0x4c>
  begin_op();
    80002434:	00002097          	auipc	ra,0x2
    80002438:	eca080e7          	jalr	-310(ra) # 800042fe <begin_op>
  iput(p->cwd);
    8000243c:	1509b503          	ld	a0,336(s3)
    80002440:	00001097          	auipc	ra,0x1
    80002444:	6bc080e7          	jalr	1724(ra) # 80003afc <iput>
  end_op();
    80002448:	00002097          	auipc	ra,0x2
    8000244c:	f36080e7          	jalr	-202(ra) # 8000437e <end_op>
  p->cwd = 0;
    80002450:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002454:	00007497          	auipc	s1,0x7
    80002458:	bc448493          	addi	s1,s1,-1084 # 80009018 <initproc>
    8000245c:	6088                	ld	a0,0(s1)
    8000245e:	ffffe097          	auipc	ra,0xffffe
    80002462:	7b2080e7          	jalr	1970(ra) # 80000c10 <acquire>
  wakeup1(initproc);
    80002466:	6088                	ld	a0,0(s1)
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	5da080e7          	jalr	1498(ra) # 80001a42 <wakeup1>
  release(&initproc->lock);
    80002470:	6088                	ld	a0,0(s1)
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	852080e7          	jalr	-1966(ra) # 80000cc4 <release>
  acquire(&p->lock);
    8000247a:	854e                	mv	a0,s3
    8000247c:	ffffe097          	auipc	ra,0xffffe
    80002480:	794080e7          	jalr	1940(ra) # 80000c10 <acquire>
  struct proc *original_parent = p->parent;
    80002484:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002488:	854e                	mv	a0,s3
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	83a080e7          	jalr	-1990(ra) # 80000cc4 <release>
  acquire(&original_parent->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	77c080e7          	jalr	1916(ra) # 80000c10 <acquire>
  acquire(&p->lock);
    8000249c:	854e                	mv	a0,s3
    8000249e:	ffffe097          	auipc	ra,0xffffe
    800024a2:	772080e7          	jalr	1906(ra) # 80000c10 <acquire>
  reparent(p);
    800024a6:	854e                	mv	a0,s3
    800024a8:	00000097          	auipc	ra,0x0
    800024ac:	d1c080e7          	jalr	-740(ra) # 800021c4 <reparent>
  wakeup1(original_parent);
    800024b0:	8526                	mv	a0,s1
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	590080e7          	jalr	1424(ra) # 80001a42 <wakeup1>
  p->xstate = status;
    800024ba:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800024be:	4791                	li	a5,4
    800024c0:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	ffffe097          	auipc	ra,0xffffe
    800024ca:	7fe080e7          	jalr	2046(ra) # 80000cc4 <release>
  sched();
    800024ce:	00000097          	auipc	ra,0x0
    800024d2:	e38080e7          	jalr	-456(ra) # 80002306 <sched>
  panic("zombie exit");
    800024d6:	00006517          	auipc	a0,0x6
    800024da:	e2a50513          	addi	a0,a0,-470 # 80008300 <digits+0x2c0>
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	06a080e7          	jalr	106(ra) # 80000548 <panic>

00000000800024e6 <yield>:
{
    800024e6:	1101                	addi	sp,sp,-32
    800024e8:	ec06                	sd	ra,24(sp)
    800024ea:	e822                	sd	s0,16(sp)
    800024ec:	e426                	sd	s1,8(sp)
    800024ee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024f0:	fffff097          	auipc	ra,0xfffff
    800024f4:	622080e7          	jalr	1570(ra) # 80001b12 <myproc>
    800024f8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	716080e7          	jalr	1814(ra) # 80000c10 <acquire>
  p->state = RUNNABLE;
    80002502:	4789                	li	a5,2
    80002504:	cc9c                	sw	a5,24(s1)
  sched();
    80002506:	00000097          	auipc	ra,0x0
    8000250a:	e00080e7          	jalr	-512(ra) # 80002306 <sched>
  release(&p->lock);
    8000250e:	8526                	mv	a0,s1
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	7b4080e7          	jalr	1972(ra) # 80000cc4 <release>
}
    80002518:	60e2                	ld	ra,24(sp)
    8000251a:	6442                	ld	s0,16(sp)
    8000251c:	64a2                	ld	s1,8(sp)
    8000251e:	6105                	addi	sp,sp,32
    80002520:	8082                	ret

0000000080002522 <sleep>:
{
    80002522:	7179                	addi	sp,sp,-48
    80002524:	f406                	sd	ra,40(sp)
    80002526:	f022                	sd	s0,32(sp)
    80002528:	ec26                	sd	s1,24(sp)
    8000252a:	e84a                	sd	s2,16(sp)
    8000252c:	e44e                	sd	s3,8(sp)
    8000252e:	1800                	addi	s0,sp,48
    80002530:	89aa                	mv	s3,a0
    80002532:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002534:	fffff097          	auipc	ra,0xfffff
    80002538:	5de080e7          	jalr	1502(ra) # 80001b12 <myproc>
    8000253c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000253e:	05250663          	beq	a0,s2,8000258a <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002542:	ffffe097          	auipc	ra,0xffffe
    80002546:	6ce080e7          	jalr	1742(ra) # 80000c10 <acquire>
    release(lk);
    8000254a:	854a                	mv	a0,s2
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	778080e7          	jalr	1912(ra) # 80000cc4 <release>
  p->chan = chan;
    80002554:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002558:	4785                	li	a5,1
    8000255a:	cc9c                	sw	a5,24(s1)
  sched();
    8000255c:	00000097          	auipc	ra,0x0
    80002560:	daa080e7          	jalr	-598(ra) # 80002306 <sched>
  p->chan = 0;
    80002564:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002568:	8526                	mv	a0,s1
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	75a080e7          	jalr	1882(ra) # 80000cc4 <release>
    acquire(lk);
    80002572:	854a                	mv	a0,s2
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	69c080e7          	jalr	1692(ra) # 80000c10 <acquire>
}
    8000257c:	70a2                	ld	ra,40(sp)
    8000257e:	7402                	ld	s0,32(sp)
    80002580:	64e2                	ld	s1,24(sp)
    80002582:	6942                	ld	s2,16(sp)
    80002584:	69a2                	ld	s3,8(sp)
    80002586:	6145                	addi	sp,sp,48
    80002588:	8082                	ret
  p->chan = chan;
    8000258a:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000258e:	4785                	li	a5,1
    80002590:	cd1c                	sw	a5,24(a0)
  sched();
    80002592:	00000097          	auipc	ra,0x0
    80002596:	d74080e7          	jalr	-652(ra) # 80002306 <sched>
  p->chan = 0;
    8000259a:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    8000259e:	bff9                	j	8000257c <sleep+0x5a>

00000000800025a0 <wait>:
{
    800025a0:	715d                	addi	sp,sp,-80
    800025a2:	e486                	sd	ra,72(sp)
    800025a4:	e0a2                	sd	s0,64(sp)
    800025a6:	fc26                	sd	s1,56(sp)
    800025a8:	f84a                	sd	s2,48(sp)
    800025aa:	f44e                	sd	s3,40(sp)
    800025ac:	f052                	sd	s4,32(sp)
    800025ae:	ec56                	sd	s5,24(sp)
    800025b0:	e85a                	sd	s6,16(sp)
    800025b2:	e45e                	sd	s7,8(sp)
    800025b4:	e062                	sd	s8,0(sp)
    800025b6:	0880                	addi	s0,sp,80
    800025b8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025ba:	fffff097          	auipc	ra,0xfffff
    800025be:	558080e7          	jalr	1368(ra) # 80001b12 <myproc>
    800025c2:	892a                	mv	s2,a0
  acquire(&p->lock);
    800025c4:	8c2a                	mv	s8,a0
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	64a080e7          	jalr	1610(ra) # 80000c10 <acquire>
    havekids = 0;
    800025ce:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800025d0:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800025d2:	00015997          	auipc	s3,0x15
    800025d6:	39698993          	addi	s3,s3,918 # 80017968 <tickslock>
        havekids = 1;
    800025da:	4a85                	li	s5,1
    havekids = 0;
    800025dc:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800025de:	0000f497          	auipc	s1,0xf
    800025e2:	78a48493          	addi	s1,s1,1930 # 80011d68 <proc>
    800025e6:	a08d                	j	80002648 <wait+0xa8>
          pid = np->pid;
    800025e8:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800025ec:	000b0e63          	beqz	s6,80002608 <wait+0x68>
    800025f0:	4691                	li	a3,4
    800025f2:	03448613          	addi	a2,s1,52
    800025f6:	85da                	mv	a1,s6
    800025f8:	05093503          	ld	a0,80(s2)
    800025fc:	fffff097          	auipc	ra,0xfffff
    80002600:	2c6080e7          	jalr	710(ra) # 800018c2 <copyout>
    80002604:	02054263          	bltz	a0,80002628 <wait+0x88>
          freeproc(np);
    80002608:	8526                	mv	a0,s1
    8000260a:	fffff097          	auipc	ra,0xfffff
    8000260e:	780080e7          	jalr	1920(ra) # 80001d8a <freeproc>
          release(&np->lock);
    80002612:	8526                	mv	a0,s1
    80002614:	ffffe097          	auipc	ra,0xffffe
    80002618:	6b0080e7          	jalr	1712(ra) # 80000cc4 <release>
          release(&p->lock);
    8000261c:	854a                	mv	a0,s2
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	6a6080e7          	jalr	1702(ra) # 80000cc4 <release>
          return pid;
    80002626:	a8a9                	j	80002680 <wait+0xe0>
            release(&np->lock);
    80002628:	8526                	mv	a0,s1
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	69a080e7          	jalr	1690(ra) # 80000cc4 <release>
            release(&p->lock);
    80002632:	854a                	mv	a0,s2
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	690080e7          	jalr	1680(ra) # 80000cc4 <release>
            return -1;
    8000263c:	59fd                	li	s3,-1
    8000263e:	a089                	j	80002680 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002640:	17048493          	addi	s1,s1,368
    80002644:	03348463          	beq	s1,s3,8000266c <wait+0xcc>
      if(np->parent == p){
    80002648:	709c                	ld	a5,32(s1)
    8000264a:	ff279be3          	bne	a5,s2,80002640 <wait+0xa0>
        acquire(&np->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	5c0080e7          	jalr	1472(ra) # 80000c10 <acquire>
        if(np->state == ZOMBIE){
    80002658:	4c9c                	lw	a5,24(s1)
    8000265a:	f94787e3          	beq	a5,s4,800025e8 <wait+0x48>
        release(&np->lock);
    8000265e:	8526                	mv	a0,s1
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	664080e7          	jalr	1636(ra) # 80000cc4 <release>
        havekids = 1;
    80002668:	8756                	mv	a4,s5
    8000266a:	bfd9                	j	80002640 <wait+0xa0>
    if(!havekids || p->killed){
    8000266c:	c701                	beqz	a4,80002674 <wait+0xd4>
    8000266e:	03092783          	lw	a5,48(s2)
    80002672:	c785                	beqz	a5,8000269a <wait+0xfa>
      release(&p->lock);
    80002674:	854a                	mv	a0,s2
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	64e080e7          	jalr	1614(ra) # 80000cc4 <release>
      return -1;
    8000267e:	59fd                	li	s3,-1
}
    80002680:	854e                	mv	a0,s3
    80002682:	60a6                	ld	ra,72(sp)
    80002684:	6406                	ld	s0,64(sp)
    80002686:	74e2                	ld	s1,56(sp)
    80002688:	7942                	ld	s2,48(sp)
    8000268a:	79a2                	ld	s3,40(sp)
    8000268c:	7a02                	ld	s4,32(sp)
    8000268e:	6ae2                	ld	s5,24(sp)
    80002690:	6b42                	ld	s6,16(sp)
    80002692:	6ba2                	ld	s7,8(sp)
    80002694:	6c02                	ld	s8,0(sp)
    80002696:	6161                	addi	sp,sp,80
    80002698:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000269a:	85e2                	mv	a1,s8
    8000269c:	854a                	mv	a0,s2
    8000269e:	00000097          	auipc	ra,0x0
    800026a2:	e84080e7          	jalr	-380(ra) # 80002522 <sleep>
    havekids = 0;
    800026a6:	bf1d                	j	800025dc <wait+0x3c>

00000000800026a8 <wakeup>:
{
    800026a8:	7139                	addi	sp,sp,-64
    800026aa:	fc06                	sd	ra,56(sp)
    800026ac:	f822                	sd	s0,48(sp)
    800026ae:	f426                	sd	s1,40(sp)
    800026b0:	f04a                	sd	s2,32(sp)
    800026b2:	ec4e                	sd	s3,24(sp)
    800026b4:	e852                	sd	s4,16(sp)
    800026b6:	e456                	sd	s5,8(sp)
    800026b8:	0080                	addi	s0,sp,64
    800026ba:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800026bc:	0000f497          	auipc	s1,0xf
    800026c0:	6ac48493          	addi	s1,s1,1708 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800026c4:	4985                	li	s3,1
      p->state = RUNNABLE;
    800026c6:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800026c8:	00015917          	auipc	s2,0x15
    800026cc:	2a090913          	addi	s2,s2,672 # 80017968 <tickslock>
    800026d0:	a821                	j	800026e8 <wakeup+0x40>
      p->state = RUNNABLE;
    800026d2:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800026d6:	8526                	mv	a0,s1
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	5ec080e7          	jalr	1516(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026e0:	17048493          	addi	s1,s1,368
    800026e4:	01248e63          	beq	s1,s2,80002700 <wakeup+0x58>
    acquire(&p->lock);
    800026e8:	8526                	mv	a0,s1
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	526080e7          	jalr	1318(ra) # 80000c10 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800026f2:	4c9c                	lw	a5,24(s1)
    800026f4:	ff3791e3          	bne	a5,s3,800026d6 <wakeup+0x2e>
    800026f8:	749c                	ld	a5,40(s1)
    800026fa:	fd479ee3          	bne	a5,s4,800026d6 <wakeup+0x2e>
    800026fe:	bfd1                	j	800026d2 <wakeup+0x2a>
}
    80002700:	70e2                	ld	ra,56(sp)
    80002702:	7442                	ld	s0,48(sp)
    80002704:	74a2                	ld	s1,40(sp)
    80002706:	7902                	ld	s2,32(sp)
    80002708:	69e2                	ld	s3,24(sp)
    8000270a:	6a42                	ld	s4,16(sp)
    8000270c:	6aa2                	ld	s5,8(sp)
    8000270e:	6121                	addi	sp,sp,64
    80002710:	8082                	ret

0000000080002712 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002712:	7179                	addi	sp,sp,-48
    80002714:	f406                	sd	ra,40(sp)
    80002716:	f022                	sd	s0,32(sp)
    80002718:	ec26                	sd	s1,24(sp)
    8000271a:	e84a                	sd	s2,16(sp)
    8000271c:	e44e                	sd	s3,8(sp)
    8000271e:	1800                	addi	s0,sp,48
    80002720:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002722:	0000f497          	auipc	s1,0xf
    80002726:	64648493          	addi	s1,s1,1606 # 80011d68 <proc>
    8000272a:	00015997          	auipc	s3,0x15
    8000272e:	23e98993          	addi	s3,s3,574 # 80017968 <tickslock>
    acquire(&p->lock);
    80002732:	8526                	mv	a0,s1
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	4dc080e7          	jalr	1244(ra) # 80000c10 <acquire>
    if(p->pid == pid){
    8000273c:	5c9c                	lw	a5,56(s1)
    8000273e:	01278d63          	beq	a5,s2,80002758 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002742:	8526                	mv	a0,s1
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	580080e7          	jalr	1408(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000274c:	17048493          	addi	s1,s1,368
    80002750:	ff3491e3          	bne	s1,s3,80002732 <kill+0x20>
  }
  return -1;
    80002754:	557d                	li	a0,-1
    80002756:	a829                	j	80002770 <kill+0x5e>
      p->killed = 1;
    80002758:	4785                	li	a5,1
    8000275a:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000275c:	4c98                	lw	a4,24(s1)
    8000275e:	4785                	li	a5,1
    80002760:	00f70f63          	beq	a4,a5,8000277e <kill+0x6c>
      release(&p->lock);
    80002764:	8526                	mv	a0,s1
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	55e080e7          	jalr	1374(ra) # 80000cc4 <release>
      return 0;
    8000276e:	4501                	li	a0,0
}
    80002770:	70a2                	ld	ra,40(sp)
    80002772:	7402                	ld	s0,32(sp)
    80002774:	64e2                	ld	s1,24(sp)
    80002776:	6942                	ld	s2,16(sp)
    80002778:	69a2                	ld	s3,8(sp)
    8000277a:	6145                	addi	sp,sp,48
    8000277c:	8082                	ret
        p->state = RUNNABLE;
    8000277e:	4789                	li	a5,2
    80002780:	cc9c                	sw	a5,24(s1)
    80002782:	b7cd                	j	80002764 <kill+0x52>

0000000080002784 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002784:	7179                	addi	sp,sp,-48
    80002786:	f406                	sd	ra,40(sp)
    80002788:	f022                	sd	s0,32(sp)
    8000278a:	ec26                	sd	s1,24(sp)
    8000278c:	e84a                	sd	s2,16(sp)
    8000278e:	e44e                	sd	s3,8(sp)
    80002790:	e052                	sd	s4,0(sp)
    80002792:	1800                	addi	s0,sp,48
    80002794:	84aa                	mv	s1,a0
    80002796:	892e                	mv	s2,a1
    80002798:	89b2                	mv	s3,a2
    8000279a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000279c:	fffff097          	auipc	ra,0xfffff
    800027a0:	376080e7          	jalr	886(ra) # 80001b12 <myproc>
  if(user_dst){
    800027a4:	c08d                	beqz	s1,800027c6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800027a6:	86d2                	mv	a3,s4
    800027a8:	864e                	mv	a2,s3
    800027aa:	85ca                	mv	a1,s2
    800027ac:	6928                	ld	a0,80(a0)
    800027ae:	fffff097          	auipc	ra,0xfffff
    800027b2:	114080e7          	jalr	276(ra) # 800018c2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027b6:	70a2                	ld	ra,40(sp)
    800027b8:	7402                	ld	s0,32(sp)
    800027ba:	64e2                	ld	s1,24(sp)
    800027bc:	6942                	ld	s2,16(sp)
    800027be:	69a2                	ld	s3,8(sp)
    800027c0:	6a02                	ld	s4,0(sp)
    800027c2:	6145                	addi	sp,sp,48
    800027c4:	8082                	ret
    memmove((char *)dst, src, len);
    800027c6:	000a061b          	sext.w	a2,s4
    800027ca:	85ce                	mv	a1,s3
    800027cc:	854a                	mv	a0,s2
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	59e080e7          	jalr	1438(ra) # 80000d6c <memmove>
    return 0;
    800027d6:	8526                	mv	a0,s1
    800027d8:	bff9                	j	800027b6 <either_copyout+0x32>

00000000800027da <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027da:	7179                	addi	sp,sp,-48
    800027dc:	f406                	sd	ra,40(sp)
    800027de:	f022                	sd	s0,32(sp)
    800027e0:	ec26                	sd	s1,24(sp)
    800027e2:	e84a                	sd	s2,16(sp)
    800027e4:	e44e                	sd	s3,8(sp)
    800027e6:	e052                	sd	s4,0(sp)
    800027e8:	1800                	addi	s0,sp,48
    800027ea:	892a                	mv	s2,a0
    800027ec:	84ae                	mv	s1,a1
    800027ee:	89b2                	mv	s3,a2
    800027f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027f2:	fffff097          	auipc	ra,0xfffff
    800027f6:	320080e7          	jalr	800(ra) # 80001b12 <myproc>
  if(user_src){
    800027fa:	c08d                	beqz	s1,8000281c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800027fc:	86d2                	mv	a3,s4
    800027fe:	864e                	mv	a2,s3
    80002800:	85ca                	mv	a1,s2
    80002802:	6928                	ld	a0,80(a0)
    80002804:	fffff097          	auipc	ra,0xfffff
    80002808:	14a080e7          	jalr	330(ra) # 8000194e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000280c:	70a2                	ld	ra,40(sp)
    8000280e:	7402                	ld	s0,32(sp)
    80002810:	64e2                	ld	s1,24(sp)
    80002812:	6942                	ld	s2,16(sp)
    80002814:	69a2                	ld	s3,8(sp)
    80002816:	6a02                	ld	s4,0(sp)
    80002818:	6145                	addi	sp,sp,48
    8000281a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000281c:	000a061b          	sext.w	a2,s4
    80002820:	85ce                	mv	a1,s3
    80002822:	854a                	mv	a0,s2
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	548080e7          	jalr	1352(ra) # 80000d6c <memmove>
    return 0;
    8000282c:	8526                	mv	a0,s1
    8000282e:	bff9                	j	8000280c <either_copyin+0x32>

0000000080002830 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002830:	715d                	addi	sp,sp,-80
    80002832:	e486                	sd	ra,72(sp)
    80002834:	e0a2                	sd	s0,64(sp)
    80002836:	fc26                	sd	s1,56(sp)
    80002838:	f84a                	sd	s2,48(sp)
    8000283a:	f44e                	sd	s3,40(sp)
    8000283c:	f052                	sd	s4,32(sp)
    8000283e:	ec56                	sd	s5,24(sp)
    80002840:	e85a                	sd	s6,16(sp)
    80002842:	e45e                	sd	s7,8(sp)
    80002844:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002846:	00006517          	auipc	a0,0x6
    8000284a:	88250513          	addi	a0,a0,-1918 # 800080c8 <digits+0x88>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	d44080e7          	jalr	-700(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002856:	0000f497          	auipc	s1,0xf
    8000285a:	66a48493          	addi	s1,s1,1642 # 80011ec0 <proc+0x158>
    8000285e:	00015917          	auipc	s2,0x15
    80002862:	26290913          	addi	s2,s2,610 # 80017ac0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002866:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002868:	00006997          	auipc	s3,0x6
    8000286c:	aa898993          	addi	s3,s3,-1368 # 80008310 <digits+0x2d0>
    printf("%d %s %s", p->pid, state, p->name);
    80002870:	00006a97          	auipc	s5,0x6
    80002874:	aa8a8a93          	addi	s5,s5,-1368 # 80008318 <digits+0x2d8>
    printf("\n");
    80002878:	00006a17          	auipc	s4,0x6
    8000287c:	850a0a13          	addi	s4,s4,-1968 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002880:	00006b97          	auipc	s7,0x6
    80002884:	ad0b8b93          	addi	s7,s7,-1328 # 80008350 <states.1740>
    80002888:	a00d                	j	800028aa <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000288a:	ee06a583          	lw	a1,-288(a3)
    8000288e:	8556                	mv	a0,s5
    80002890:	ffffe097          	auipc	ra,0xffffe
    80002894:	d02080e7          	jalr	-766(ra) # 80000592 <printf>
    printf("\n");
    80002898:	8552                	mv	a0,s4
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	cf8080e7          	jalr	-776(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028a2:	17048493          	addi	s1,s1,368
    800028a6:	03248163          	beq	s1,s2,800028c8 <procdump+0x98>
    if(p->state == UNUSED)
    800028aa:	86a6                	mv	a3,s1
    800028ac:	ec04a783          	lw	a5,-320(s1)
    800028b0:	dbed                	beqz	a5,800028a2 <procdump+0x72>
      state = "???";
    800028b2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028b4:	fcfb6be3          	bltu	s6,a5,8000288a <procdump+0x5a>
    800028b8:	1782                	slli	a5,a5,0x20
    800028ba:	9381                	srli	a5,a5,0x20
    800028bc:	078e                	slli	a5,a5,0x3
    800028be:	97de                	add	a5,a5,s7
    800028c0:	6390                	ld	a2,0(a5)
    800028c2:	f661                	bnez	a2,8000288a <procdump+0x5a>
      state = "???";
    800028c4:	864e                	mv	a2,s3
    800028c6:	b7d1                	j	8000288a <procdump+0x5a>
  }
}
    800028c8:	60a6                	ld	ra,72(sp)
    800028ca:	6406                	ld	s0,64(sp)
    800028cc:	74e2                	ld	s1,56(sp)
    800028ce:	7942                	ld	s2,48(sp)
    800028d0:	79a2                	ld	s3,40(sp)
    800028d2:	7a02                	ld	s4,32(sp)
    800028d4:	6ae2                	ld	s5,24(sp)
    800028d6:	6b42                	ld	s6,16(sp)
    800028d8:	6ba2                	ld	s7,8(sp)
    800028da:	6161                	addi	sp,sp,80
    800028dc:	8082                	ret

00000000800028de <swtch>:
    800028de:	00153023          	sd	ra,0(a0)
    800028e2:	00253423          	sd	sp,8(a0)
    800028e6:	e900                	sd	s0,16(a0)
    800028e8:	ed04                	sd	s1,24(a0)
    800028ea:	03253023          	sd	s2,32(a0)
    800028ee:	03353423          	sd	s3,40(a0)
    800028f2:	03453823          	sd	s4,48(a0)
    800028f6:	03553c23          	sd	s5,56(a0)
    800028fa:	05653023          	sd	s6,64(a0)
    800028fe:	05753423          	sd	s7,72(a0)
    80002902:	05853823          	sd	s8,80(a0)
    80002906:	05953c23          	sd	s9,88(a0)
    8000290a:	07a53023          	sd	s10,96(a0)
    8000290e:	07b53423          	sd	s11,104(a0)
    80002912:	0005b083          	ld	ra,0(a1)
    80002916:	0085b103          	ld	sp,8(a1)
    8000291a:	6980                	ld	s0,16(a1)
    8000291c:	6d84                	ld	s1,24(a1)
    8000291e:	0205b903          	ld	s2,32(a1)
    80002922:	0285b983          	ld	s3,40(a1)
    80002926:	0305ba03          	ld	s4,48(a1)
    8000292a:	0385ba83          	ld	s5,56(a1)
    8000292e:	0405bb03          	ld	s6,64(a1)
    80002932:	0485bb83          	ld	s7,72(a1)
    80002936:	0505bc03          	ld	s8,80(a1)
    8000293a:	0585bc83          	ld	s9,88(a1)
    8000293e:	0605bd03          	ld	s10,96(a1)
    80002942:	0685bd83          	ld	s11,104(a1)
    80002946:	8082                	ret

0000000080002948 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002948:	1141                	addi	sp,sp,-16
    8000294a:	e406                	sd	ra,8(sp)
    8000294c:	e022                	sd	s0,0(sp)
    8000294e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002950:	00006597          	auipc	a1,0x6
    80002954:	a2858593          	addi	a1,a1,-1496 # 80008378 <states.1740+0x28>
    80002958:	00015517          	auipc	a0,0x15
    8000295c:	01050513          	addi	a0,a0,16 # 80017968 <tickslock>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	220080e7          	jalr	544(ra) # 80000b80 <initlock>
}
    80002968:	60a2                	ld	ra,8(sp)
    8000296a:	6402                	ld	s0,0(sp)
    8000296c:	0141                	addi	sp,sp,16
    8000296e:	8082                	ret

0000000080002970 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002970:	1141                	addi	sp,sp,-16
    80002972:	e422                	sd	s0,8(sp)
    80002974:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002976:	00003797          	auipc	a5,0x3
    8000297a:	50a78793          	addi	a5,a5,1290 # 80005e80 <kernelvec>
    8000297e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002982:	6422                	ld	s0,8(sp)
    80002984:	0141                	addi	sp,sp,16
    80002986:	8082                	ret

0000000080002988 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002988:	1141                	addi	sp,sp,-16
    8000298a:	e406                	sd	ra,8(sp)
    8000298c:	e022                	sd	s0,0(sp)
    8000298e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002990:	fffff097          	auipc	ra,0xfffff
    80002994:	182080e7          	jalr	386(ra) # 80001b12 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002998:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000299c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000299e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800029a2:	00004617          	auipc	a2,0x4
    800029a6:	65e60613          	addi	a2,a2,1630 # 80007000 <_trampoline>
    800029aa:	00004697          	auipc	a3,0x4
    800029ae:	65668693          	addi	a3,a3,1622 # 80007000 <_trampoline>
    800029b2:	8e91                	sub	a3,a3,a2
    800029b4:	040007b7          	lui	a5,0x4000
    800029b8:	17fd                	addi	a5,a5,-1
    800029ba:	07b2                	slli	a5,a5,0xc
    800029bc:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029be:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029c2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029c4:	180026f3          	csrr	a3,satp
    800029c8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029ca:	6d38                	ld	a4,88(a0)
    800029cc:	6134                	ld	a3,64(a0)
    800029ce:	6585                	lui	a1,0x1
    800029d0:	96ae                	add	a3,a3,a1
    800029d2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029d4:	6d38                	ld	a4,88(a0)
    800029d6:	00000697          	auipc	a3,0x0
    800029da:	13868693          	addi	a3,a3,312 # 80002b0e <usertrap>
    800029de:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029e0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029e2:	8692                	mv	a3,tp
    800029e4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029ea:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029ee:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029f2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029f6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029f8:	6f18                	ld	a4,24(a4)
    800029fa:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029fe:	692c                	ld	a1,80(a0)
    80002a00:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a02:	00004717          	auipc	a4,0x4
    80002a06:	68e70713          	addi	a4,a4,1678 # 80007090 <userret>
    80002a0a:	8f11                	sub	a4,a4,a2
    80002a0c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002a0e:	577d                	li	a4,-1
    80002a10:	177e                	slli	a4,a4,0x3f
    80002a12:	8dd9                	or	a1,a1,a4
    80002a14:	02000537          	lui	a0,0x2000
    80002a18:	157d                	addi	a0,a0,-1
    80002a1a:	0536                	slli	a0,a0,0xd
    80002a1c:	9782                	jalr	a5
}
    80002a1e:	60a2                	ld	ra,8(sp)
    80002a20:	6402                	ld	s0,0(sp)
    80002a22:	0141                	addi	sp,sp,16
    80002a24:	8082                	ret

0000000080002a26 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a26:	1101                	addi	sp,sp,-32
    80002a28:	ec06                	sd	ra,24(sp)
    80002a2a:	e822                	sd	s0,16(sp)
    80002a2c:	e426                	sd	s1,8(sp)
    80002a2e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a30:	00015497          	auipc	s1,0x15
    80002a34:	f3848493          	addi	s1,s1,-200 # 80017968 <tickslock>
    80002a38:	8526                	mv	a0,s1
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	1d6080e7          	jalr	470(ra) # 80000c10 <acquire>
  ticks++;
    80002a42:	00006517          	auipc	a0,0x6
    80002a46:	5de50513          	addi	a0,a0,1502 # 80009020 <ticks>
    80002a4a:	411c                	lw	a5,0(a0)
    80002a4c:	2785                	addiw	a5,a5,1
    80002a4e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a50:	00000097          	auipc	ra,0x0
    80002a54:	c58080e7          	jalr	-936(ra) # 800026a8 <wakeup>
  release(&tickslock);
    80002a58:	8526                	mv	a0,s1
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	26a080e7          	jalr	618(ra) # 80000cc4 <release>
}
    80002a62:	60e2                	ld	ra,24(sp)
    80002a64:	6442                	ld	s0,16(sp)
    80002a66:	64a2                	ld	s1,8(sp)
    80002a68:	6105                	addi	sp,sp,32
    80002a6a:	8082                	ret

0000000080002a6c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a6c:	1101                	addi	sp,sp,-32
    80002a6e:	ec06                	sd	ra,24(sp)
    80002a70:	e822                	sd	s0,16(sp)
    80002a72:	e426                	sd	s1,8(sp)
    80002a74:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a76:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a7a:	00074d63          	bltz	a4,80002a94 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a7e:	57fd                	li	a5,-1
    80002a80:	17fe                	slli	a5,a5,0x3f
    80002a82:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a84:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a86:	06f70363          	beq	a4,a5,80002aec <devintr+0x80>
  }
}
    80002a8a:	60e2                	ld	ra,24(sp)
    80002a8c:	6442                	ld	s0,16(sp)
    80002a8e:	64a2                	ld	s1,8(sp)
    80002a90:	6105                	addi	sp,sp,32
    80002a92:	8082                	ret
     (scause & 0xff) == 9){
    80002a94:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a98:	46a5                	li	a3,9
    80002a9a:	fed792e3          	bne	a5,a3,80002a7e <devintr+0x12>
    int irq = plic_claim();
    80002a9e:	00003097          	auipc	ra,0x3
    80002aa2:	4ea080e7          	jalr	1258(ra) # 80005f88 <plic_claim>
    80002aa6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002aa8:	47a9                	li	a5,10
    80002aaa:	02f50763          	beq	a0,a5,80002ad8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002aae:	4785                	li	a5,1
    80002ab0:	02f50963          	beq	a0,a5,80002ae2 <devintr+0x76>
    return 1;
    80002ab4:	4505                	li	a0,1
    } else if(irq){
    80002ab6:	d8f1                	beqz	s1,80002a8a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ab8:	85a6                	mv	a1,s1
    80002aba:	00006517          	auipc	a0,0x6
    80002abe:	8c650513          	addi	a0,a0,-1850 # 80008380 <states.1740+0x30>
    80002ac2:	ffffe097          	auipc	ra,0xffffe
    80002ac6:	ad0080e7          	jalr	-1328(ra) # 80000592 <printf>
      plic_complete(irq);
    80002aca:	8526                	mv	a0,s1
    80002acc:	00003097          	auipc	ra,0x3
    80002ad0:	4e0080e7          	jalr	1248(ra) # 80005fac <plic_complete>
    return 1;
    80002ad4:	4505                	li	a0,1
    80002ad6:	bf55                	j	80002a8a <devintr+0x1e>
      uartintr();
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	efc080e7          	jalr	-260(ra) # 800009d4 <uartintr>
    80002ae0:	b7ed                	j	80002aca <devintr+0x5e>
      virtio_disk_intr();
    80002ae2:	00004097          	auipc	ra,0x4
    80002ae6:	964080e7          	jalr	-1692(ra) # 80006446 <virtio_disk_intr>
    80002aea:	b7c5                	j	80002aca <devintr+0x5e>
    if(cpuid() == 0){
    80002aec:	fffff097          	auipc	ra,0xfffff
    80002af0:	ffa080e7          	jalr	-6(ra) # 80001ae6 <cpuid>
    80002af4:	c901                	beqz	a0,80002b04 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002af6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002afa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002afc:	14479073          	csrw	sip,a5
    return 2;
    80002b00:	4509                	li	a0,2
    80002b02:	b761                	j	80002a8a <devintr+0x1e>
      clockintr();
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	f22080e7          	jalr	-222(ra) # 80002a26 <clockintr>
    80002b0c:	b7ed                	j	80002af6 <devintr+0x8a>

0000000080002b0e <usertrap>:
{
    80002b0e:	1101                	addi	sp,sp,-32
    80002b10:	ec06                	sd	ra,24(sp)
    80002b12:	e822                	sd	s0,16(sp)
    80002b14:	e426                	sd	s1,8(sp)
    80002b16:	e04a                	sd	s2,0(sp)
    80002b18:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b1a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b1e:	1007f793          	andi	a5,a5,256
    80002b22:	e3ad                	bnez	a5,80002b84 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b24:	00003797          	auipc	a5,0x3
    80002b28:	35c78793          	addi	a5,a5,860 # 80005e80 <kernelvec>
    80002b2c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b30:	fffff097          	auipc	ra,0xfffff
    80002b34:	fe2080e7          	jalr	-30(ra) # 80001b12 <myproc>
    80002b38:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b3a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b3c:	14102773          	csrr	a4,sepc
    80002b40:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b42:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b46:	47a1                	li	a5,8
    80002b48:	04f71c63          	bne	a4,a5,80002ba0 <usertrap+0x92>
    if(p->killed)
    80002b4c:	591c                	lw	a5,48(a0)
    80002b4e:	e3b9                	bnez	a5,80002b94 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002b50:	6cb8                	ld	a4,88(s1)
    80002b52:	6f1c                	ld	a5,24(a4)
    80002b54:	0791                	addi	a5,a5,4
    80002b56:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b58:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b5c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b60:	10079073          	csrw	sstatus,a5
    syscall();
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	2e0080e7          	jalr	736(ra) # 80002e44 <syscall>
  if(p->killed)
    80002b6c:	589c                	lw	a5,48(s1)
    80002b6e:	ebc1                	bnez	a5,80002bfe <usertrap+0xf0>
  usertrapret();
    80002b70:	00000097          	auipc	ra,0x0
    80002b74:	e18080e7          	jalr	-488(ra) # 80002988 <usertrapret>
}
    80002b78:	60e2                	ld	ra,24(sp)
    80002b7a:	6442                	ld	s0,16(sp)
    80002b7c:	64a2                	ld	s1,8(sp)
    80002b7e:	6902                	ld	s2,0(sp)
    80002b80:	6105                	addi	sp,sp,32
    80002b82:	8082                	ret
    panic("usertrap: not from user mode");
    80002b84:	00006517          	auipc	a0,0x6
    80002b88:	81c50513          	addi	a0,a0,-2020 # 800083a0 <states.1740+0x50>
    80002b8c:	ffffe097          	auipc	ra,0xffffe
    80002b90:	9bc080e7          	jalr	-1604(ra) # 80000548 <panic>
      exit(-1);
    80002b94:	557d                	li	a0,-1
    80002b96:	00000097          	auipc	ra,0x0
    80002b9a:	846080e7          	jalr	-1978(ra) # 800023dc <exit>
    80002b9e:	bf4d                	j	80002b50 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002ba0:	00000097          	auipc	ra,0x0
    80002ba4:	ecc080e7          	jalr	-308(ra) # 80002a6c <devintr>
    80002ba8:	892a                	mv	s2,a0
    80002baa:	c501                	beqz	a0,80002bb2 <usertrap+0xa4>
  if(p->killed)
    80002bac:	589c                	lw	a5,48(s1)
    80002bae:	c3a1                	beqz	a5,80002bee <usertrap+0xe0>
    80002bb0:	a815                	j	80002be4 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bb6:	5c90                	lw	a2,56(s1)
    80002bb8:	00006517          	auipc	a0,0x6
    80002bbc:	80850513          	addi	a0,a0,-2040 # 800083c0 <states.1740+0x70>
    80002bc0:	ffffe097          	auipc	ra,0xffffe
    80002bc4:	9d2080e7          	jalr	-1582(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bc8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bcc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bd0:	00006517          	auipc	a0,0x6
    80002bd4:	82050513          	addi	a0,a0,-2016 # 800083f0 <states.1740+0xa0>
    80002bd8:	ffffe097          	auipc	ra,0xffffe
    80002bdc:	9ba080e7          	jalr	-1606(ra) # 80000592 <printf>
    p->killed = 1;
    80002be0:	4785                	li	a5,1
    80002be2:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002be4:	557d                	li	a0,-1
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	7f6080e7          	jalr	2038(ra) # 800023dc <exit>
  if(which_dev == 2)
    80002bee:	4789                	li	a5,2
    80002bf0:	f8f910e3          	bne	s2,a5,80002b70 <usertrap+0x62>
    yield();
    80002bf4:	00000097          	auipc	ra,0x0
    80002bf8:	8f2080e7          	jalr	-1806(ra) # 800024e6 <yield>
    80002bfc:	bf95                	j	80002b70 <usertrap+0x62>
  int which_dev = 0;
    80002bfe:	4901                	li	s2,0
    80002c00:	b7d5                	j	80002be4 <usertrap+0xd6>

0000000080002c02 <kerneltrap>:
{
    80002c02:	7179                	addi	sp,sp,-48
    80002c04:	f406                	sd	ra,40(sp)
    80002c06:	f022                	sd	s0,32(sp)
    80002c08:	ec26                	sd	s1,24(sp)
    80002c0a:	e84a                	sd	s2,16(sp)
    80002c0c:	e44e                	sd	s3,8(sp)
    80002c0e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c10:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c14:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c18:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c1c:	1004f793          	andi	a5,s1,256
    80002c20:	cb85                	beqz	a5,80002c50 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c22:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c26:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c28:	ef85                	bnez	a5,80002c60 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	e42080e7          	jalr	-446(ra) # 80002a6c <devintr>
    80002c32:	cd1d                	beqz	a0,80002c70 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c34:	4789                	li	a5,2
    80002c36:	06f50a63          	beq	a0,a5,80002caa <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c3a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c3e:	10049073          	csrw	sstatus,s1
}
    80002c42:	70a2                	ld	ra,40(sp)
    80002c44:	7402                	ld	s0,32(sp)
    80002c46:	64e2                	ld	s1,24(sp)
    80002c48:	6942                	ld	s2,16(sp)
    80002c4a:	69a2                	ld	s3,8(sp)
    80002c4c:	6145                	addi	sp,sp,48
    80002c4e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c50:	00005517          	auipc	a0,0x5
    80002c54:	7c050513          	addi	a0,a0,1984 # 80008410 <states.1740+0xc0>
    80002c58:	ffffe097          	auipc	ra,0xffffe
    80002c5c:	8f0080e7          	jalr	-1808(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c60:	00005517          	auipc	a0,0x5
    80002c64:	7d850513          	addi	a0,a0,2008 # 80008438 <states.1740+0xe8>
    80002c68:	ffffe097          	auipc	ra,0xffffe
    80002c6c:	8e0080e7          	jalr	-1824(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002c70:	85ce                	mv	a1,s3
    80002c72:	00005517          	auipc	a0,0x5
    80002c76:	7e650513          	addi	a0,a0,2022 # 80008458 <states.1740+0x108>
    80002c7a:	ffffe097          	auipc	ra,0xffffe
    80002c7e:	918080e7          	jalr	-1768(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c82:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c86:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c8a:	00005517          	auipc	a0,0x5
    80002c8e:	7de50513          	addi	a0,a0,2014 # 80008468 <states.1740+0x118>
    80002c92:	ffffe097          	auipc	ra,0xffffe
    80002c96:	900080e7          	jalr	-1792(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002c9a:	00005517          	auipc	a0,0x5
    80002c9e:	7e650513          	addi	a0,a0,2022 # 80008480 <states.1740+0x130>
    80002ca2:	ffffe097          	auipc	ra,0xffffe
    80002ca6:	8a6080e7          	jalr	-1882(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002caa:	fffff097          	auipc	ra,0xfffff
    80002cae:	e68080e7          	jalr	-408(ra) # 80001b12 <myproc>
    80002cb2:	d541                	beqz	a0,80002c3a <kerneltrap+0x38>
    80002cb4:	fffff097          	auipc	ra,0xfffff
    80002cb8:	e5e080e7          	jalr	-418(ra) # 80001b12 <myproc>
    80002cbc:	4d18                	lw	a4,24(a0)
    80002cbe:	478d                	li	a5,3
    80002cc0:	f6f71de3          	bne	a4,a5,80002c3a <kerneltrap+0x38>
    yield();
    80002cc4:	00000097          	auipc	ra,0x0
    80002cc8:	822080e7          	jalr	-2014(ra) # 800024e6 <yield>
    80002ccc:	b7bd                	j	80002c3a <kerneltrap+0x38>

0000000080002cce <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cce:	1101                	addi	sp,sp,-32
    80002cd0:	ec06                	sd	ra,24(sp)
    80002cd2:	e822                	sd	s0,16(sp)
    80002cd4:	e426                	sd	s1,8(sp)
    80002cd6:	1000                	addi	s0,sp,32
    80002cd8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cda:	fffff097          	auipc	ra,0xfffff
    80002cde:	e38080e7          	jalr	-456(ra) # 80001b12 <myproc>
  switch (n) {
    80002ce2:	4795                	li	a5,5
    80002ce4:	0497e163          	bltu	a5,s1,80002d26 <argraw+0x58>
    80002ce8:	048a                	slli	s1,s1,0x2
    80002cea:	00005717          	auipc	a4,0x5
    80002cee:	7ce70713          	addi	a4,a4,1998 # 800084b8 <states.1740+0x168>
    80002cf2:	94ba                	add	s1,s1,a4
    80002cf4:	409c                	lw	a5,0(s1)
    80002cf6:	97ba                	add	a5,a5,a4
    80002cf8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cfa:	6d3c                	ld	a5,88(a0)
    80002cfc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cfe:	60e2                	ld	ra,24(sp)
    80002d00:	6442                	ld	s0,16(sp)
    80002d02:	64a2                	ld	s1,8(sp)
    80002d04:	6105                	addi	sp,sp,32
    80002d06:	8082                	ret
    return p->trapframe->a1;
    80002d08:	6d3c                	ld	a5,88(a0)
    80002d0a:	7fa8                	ld	a0,120(a5)
    80002d0c:	bfcd                	j	80002cfe <argraw+0x30>
    return p->trapframe->a2;
    80002d0e:	6d3c                	ld	a5,88(a0)
    80002d10:	63c8                	ld	a0,128(a5)
    80002d12:	b7f5                	j	80002cfe <argraw+0x30>
    return p->trapframe->a3;
    80002d14:	6d3c                	ld	a5,88(a0)
    80002d16:	67c8                	ld	a0,136(a5)
    80002d18:	b7dd                	j	80002cfe <argraw+0x30>
    return p->trapframe->a4;
    80002d1a:	6d3c                	ld	a5,88(a0)
    80002d1c:	6bc8                	ld	a0,144(a5)
    80002d1e:	b7c5                	j	80002cfe <argraw+0x30>
    return p->trapframe->a5;
    80002d20:	6d3c                	ld	a5,88(a0)
    80002d22:	6fc8                	ld	a0,152(a5)
    80002d24:	bfe9                	j	80002cfe <argraw+0x30>
  panic("argraw");
    80002d26:	00005517          	auipc	a0,0x5
    80002d2a:	76a50513          	addi	a0,a0,1898 # 80008490 <states.1740+0x140>
    80002d2e:	ffffe097          	auipc	ra,0xffffe
    80002d32:	81a080e7          	jalr	-2022(ra) # 80000548 <panic>

0000000080002d36 <fetchaddr>:
{
    80002d36:	1101                	addi	sp,sp,-32
    80002d38:	ec06                	sd	ra,24(sp)
    80002d3a:	e822                	sd	s0,16(sp)
    80002d3c:	e426                	sd	s1,8(sp)
    80002d3e:	e04a                	sd	s2,0(sp)
    80002d40:	1000                	addi	s0,sp,32
    80002d42:	84aa                	mv	s1,a0
    80002d44:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d46:	fffff097          	auipc	ra,0xfffff
    80002d4a:	dcc080e7          	jalr	-564(ra) # 80001b12 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d4e:	653c                	ld	a5,72(a0)
    80002d50:	02f4f863          	bgeu	s1,a5,80002d80 <fetchaddr+0x4a>
    80002d54:	00848713          	addi	a4,s1,8
    80002d58:	02e7e663          	bltu	a5,a4,80002d84 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d5c:	46a1                	li	a3,8
    80002d5e:	8626                	mv	a2,s1
    80002d60:	85ca                	mv	a1,s2
    80002d62:	6928                	ld	a0,80(a0)
    80002d64:	fffff097          	auipc	ra,0xfffff
    80002d68:	bea080e7          	jalr	-1046(ra) # 8000194e <copyin>
    80002d6c:	00a03533          	snez	a0,a0
    80002d70:	40a00533          	neg	a0,a0
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	64a2                	ld	s1,8(sp)
    80002d7a:	6902                	ld	s2,0(sp)
    80002d7c:	6105                	addi	sp,sp,32
    80002d7e:	8082                	ret
    return -1;
    80002d80:	557d                	li	a0,-1
    80002d82:	bfcd                	j	80002d74 <fetchaddr+0x3e>
    80002d84:	557d                	li	a0,-1
    80002d86:	b7fd                	j	80002d74 <fetchaddr+0x3e>

0000000080002d88 <fetchstr>:
{
    80002d88:	7179                	addi	sp,sp,-48
    80002d8a:	f406                	sd	ra,40(sp)
    80002d8c:	f022                	sd	s0,32(sp)
    80002d8e:	ec26                	sd	s1,24(sp)
    80002d90:	e84a                	sd	s2,16(sp)
    80002d92:	e44e                	sd	s3,8(sp)
    80002d94:	1800                	addi	s0,sp,48
    80002d96:	892a                	mv	s2,a0
    80002d98:	84ae                	mv	s1,a1
    80002d9a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d9c:	fffff097          	auipc	ra,0xfffff
    80002da0:	d76080e7          	jalr	-650(ra) # 80001b12 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002da4:	86ce                	mv	a3,s3
    80002da6:	864a                	mv	a2,s2
    80002da8:	85a6                	mv	a1,s1
    80002daa:	6928                	ld	a0,80(a0)
    80002dac:	fffff097          	auipc	ra,0xfffff
    80002db0:	bba080e7          	jalr	-1094(ra) # 80001966 <copyinstr>
  if(err < 0)
    80002db4:	00054763          	bltz	a0,80002dc2 <fetchstr+0x3a>
  return strlen(buf);
    80002db8:	8526                	mv	a0,s1
    80002dba:	ffffe097          	auipc	ra,0xffffe
    80002dbe:	0da080e7          	jalr	218(ra) # 80000e94 <strlen>
}
    80002dc2:	70a2                	ld	ra,40(sp)
    80002dc4:	7402                	ld	s0,32(sp)
    80002dc6:	64e2                	ld	s1,24(sp)
    80002dc8:	6942                	ld	s2,16(sp)
    80002dca:	69a2                	ld	s3,8(sp)
    80002dcc:	6145                	addi	sp,sp,48
    80002dce:	8082                	ret

0000000080002dd0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	1000                	addi	s0,sp,32
    80002dda:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ddc:	00000097          	auipc	ra,0x0
    80002de0:	ef2080e7          	jalr	-270(ra) # 80002cce <argraw>
    80002de4:	c088                	sw	a0,0(s1)
  return 0;
}
    80002de6:	4501                	li	a0,0
    80002de8:	60e2                	ld	ra,24(sp)
    80002dea:	6442                	ld	s0,16(sp)
    80002dec:	64a2                	ld	s1,8(sp)
    80002dee:	6105                	addi	sp,sp,32
    80002df0:	8082                	ret

0000000080002df2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002df2:	1101                	addi	sp,sp,-32
    80002df4:	ec06                	sd	ra,24(sp)
    80002df6:	e822                	sd	s0,16(sp)
    80002df8:	e426                	sd	s1,8(sp)
    80002dfa:	1000                	addi	s0,sp,32
    80002dfc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dfe:	00000097          	auipc	ra,0x0
    80002e02:	ed0080e7          	jalr	-304(ra) # 80002cce <argraw>
    80002e06:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e08:	4501                	li	a0,0
    80002e0a:	60e2                	ld	ra,24(sp)
    80002e0c:	6442                	ld	s0,16(sp)
    80002e0e:	64a2                	ld	s1,8(sp)
    80002e10:	6105                	addi	sp,sp,32
    80002e12:	8082                	ret

0000000080002e14 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e14:	1101                	addi	sp,sp,-32
    80002e16:	ec06                	sd	ra,24(sp)
    80002e18:	e822                	sd	s0,16(sp)
    80002e1a:	e426                	sd	s1,8(sp)
    80002e1c:	e04a                	sd	s2,0(sp)
    80002e1e:	1000                	addi	s0,sp,32
    80002e20:	84ae                	mv	s1,a1
    80002e22:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e24:	00000097          	auipc	ra,0x0
    80002e28:	eaa080e7          	jalr	-342(ra) # 80002cce <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e2c:	864a                	mv	a2,s2
    80002e2e:	85a6                	mv	a1,s1
    80002e30:	00000097          	auipc	ra,0x0
    80002e34:	f58080e7          	jalr	-168(ra) # 80002d88 <fetchstr>
}
    80002e38:	60e2                	ld	ra,24(sp)
    80002e3a:	6442                	ld	s0,16(sp)
    80002e3c:	64a2                	ld	s1,8(sp)
    80002e3e:	6902                	ld	s2,0(sp)
    80002e40:	6105                	addi	sp,sp,32
    80002e42:	8082                	ret

0000000080002e44 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e44:	1101                	addi	sp,sp,-32
    80002e46:	ec06                	sd	ra,24(sp)
    80002e48:	e822                	sd	s0,16(sp)
    80002e4a:	e426                	sd	s1,8(sp)
    80002e4c:	e04a                	sd	s2,0(sp)
    80002e4e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e50:	fffff097          	auipc	ra,0xfffff
    80002e54:	cc2080e7          	jalr	-830(ra) # 80001b12 <myproc>
    80002e58:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e5a:	05853903          	ld	s2,88(a0)
    80002e5e:	0a893783          	ld	a5,168(s2)
    80002e62:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e66:	37fd                	addiw	a5,a5,-1
    80002e68:	4751                	li	a4,20
    80002e6a:	00f76f63          	bltu	a4,a5,80002e88 <syscall+0x44>
    80002e6e:	00369713          	slli	a4,a3,0x3
    80002e72:	00005797          	auipc	a5,0x5
    80002e76:	65e78793          	addi	a5,a5,1630 # 800084d0 <syscalls>
    80002e7a:	97ba                	add	a5,a5,a4
    80002e7c:	639c                	ld	a5,0(a5)
    80002e7e:	c789                	beqz	a5,80002e88 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e80:	9782                	jalr	a5
    80002e82:	06a93823          	sd	a0,112(s2)
    80002e86:	a839                	j	80002ea4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e88:	15848613          	addi	a2,s1,344
    80002e8c:	5c8c                	lw	a1,56(s1)
    80002e8e:	00005517          	auipc	a0,0x5
    80002e92:	60a50513          	addi	a0,a0,1546 # 80008498 <states.1740+0x148>
    80002e96:	ffffd097          	auipc	ra,0xffffd
    80002e9a:	6fc080e7          	jalr	1788(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e9e:	6cbc                	ld	a5,88(s1)
    80002ea0:	577d                	li	a4,-1
    80002ea2:	fbb8                	sd	a4,112(a5)
  }
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	64a2                	ld	s1,8(sp)
    80002eaa:	6902                	ld	s2,0(sp)
    80002eac:	6105                	addi	sp,sp,32
    80002eae:	8082                	ret

0000000080002eb0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002eb0:	1101                	addi	sp,sp,-32
    80002eb2:	ec06                	sd	ra,24(sp)
    80002eb4:	e822                	sd	s0,16(sp)
    80002eb6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002eb8:	fec40593          	addi	a1,s0,-20
    80002ebc:	4501                	li	a0,0
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	f12080e7          	jalr	-238(ra) # 80002dd0 <argint>
    return -1;
    80002ec6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ec8:	00054963          	bltz	a0,80002eda <sys_exit+0x2a>
  exit(n);
    80002ecc:	fec42503          	lw	a0,-20(s0)
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	50c080e7          	jalr	1292(ra) # 800023dc <exit>
  return 0;  // not reached
    80002ed8:	4781                	li	a5,0
}
    80002eda:	853e                	mv	a0,a5
    80002edc:	60e2                	ld	ra,24(sp)
    80002ede:	6442                	ld	s0,16(sp)
    80002ee0:	6105                	addi	sp,sp,32
    80002ee2:	8082                	ret

0000000080002ee4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ee4:	1141                	addi	sp,sp,-16
    80002ee6:	e406                	sd	ra,8(sp)
    80002ee8:	e022                	sd	s0,0(sp)
    80002eea:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002eec:	fffff097          	auipc	ra,0xfffff
    80002ef0:	c26080e7          	jalr	-986(ra) # 80001b12 <myproc>
}
    80002ef4:	5d08                	lw	a0,56(a0)
    80002ef6:	60a2                	ld	ra,8(sp)
    80002ef8:	6402                	ld	s0,0(sp)
    80002efa:	0141                	addi	sp,sp,16
    80002efc:	8082                	ret

0000000080002efe <sys_fork>:

uint64
sys_fork(void)
{
    80002efe:	1141                	addi	sp,sp,-16
    80002f00:	e406                	sd	ra,8(sp)
    80002f02:	e022                	sd	s0,0(sp)
    80002f04:	0800                	addi	s0,sp,16
  return fork();
    80002f06:	fffff097          	auipc	ra,0xfffff
    80002f0a:	19e080e7          	jalr	414(ra) # 800020a4 <fork>
}
    80002f0e:	60a2                	ld	ra,8(sp)
    80002f10:	6402                	ld	s0,0(sp)
    80002f12:	0141                	addi	sp,sp,16
    80002f14:	8082                	ret

0000000080002f16 <sys_wait>:

uint64
sys_wait(void)
{
    80002f16:	1101                	addi	sp,sp,-32
    80002f18:	ec06                	sd	ra,24(sp)
    80002f1a:	e822                	sd	s0,16(sp)
    80002f1c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f1e:	fe840593          	addi	a1,s0,-24
    80002f22:	4501                	li	a0,0
    80002f24:	00000097          	auipc	ra,0x0
    80002f28:	ece080e7          	jalr	-306(ra) # 80002df2 <argaddr>
    80002f2c:	87aa                	mv	a5,a0
    return -1;
    80002f2e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f30:	0007c863          	bltz	a5,80002f40 <sys_wait+0x2a>
  return wait(p);
    80002f34:	fe843503          	ld	a0,-24(s0)
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	668080e7          	jalr	1640(ra) # 800025a0 <wait>
}
    80002f40:	60e2                	ld	ra,24(sp)
    80002f42:	6442                	ld	s0,16(sp)
    80002f44:	6105                	addi	sp,sp,32
    80002f46:	8082                	ret

0000000080002f48 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f48:	7179                	addi	sp,sp,-48
    80002f4a:	f406                	sd	ra,40(sp)
    80002f4c:	f022                	sd	s0,32(sp)
    80002f4e:	ec26                	sd	s1,24(sp)
    80002f50:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f52:	fdc40593          	addi	a1,s0,-36
    80002f56:	4501                	li	a0,0
    80002f58:	00000097          	auipc	ra,0x0
    80002f5c:	e78080e7          	jalr	-392(ra) # 80002dd0 <argint>
    80002f60:	87aa                	mv	a5,a0
    return -1;
    80002f62:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002f64:	0207c063          	bltz	a5,80002f84 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002f68:	fffff097          	auipc	ra,0xfffff
    80002f6c:	baa080e7          	jalr	-1110(ra) # 80001b12 <myproc>
    80002f70:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002f72:	fdc42503          	lw	a0,-36(s0)
    80002f76:	fffff097          	auipc	ra,0xfffff
    80002f7a:	058080e7          	jalr	88(ra) # 80001fce <growproc>
    80002f7e:	00054863          	bltz	a0,80002f8e <sys_sbrk+0x46>
    return -1;
  return addr;
    80002f82:	8526                	mv	a0,s1
}
    80002f84:	70a2                	ld	ra,40(sp)
    80002f86:	7402                	ld	s0,32(sp)
    80002f88:	64e2                	ld	s1,24(sp)
    80002f8a:	6145                	addi	sp,sp,48
    80002f8c:	8082                	ret
    return -1;
    80002f8e:	557d                	li	a0,-1
    80002f90:	bfd5                	j	80002f84 <sys_sbrk+0x3c>

0000000080002f92 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f92:	7139                	addi	sp,sp,-64
    80002f94:	fc06                	sd	ra,56(sp)
    80002f96:	f822                	sd	s0,48(sp)
    80002f98:	f426                	sd	s1,40(sp)
    80002f9a:	f04a                	sd	s2,32(sp)
    80002f9c:	ec4e                	sd	s3,24(sp)
    80002f9e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002fa0:	fcc40593          	addi	a1,s0,-52
    80002fa4:	4501                	li	a0,0
    80002fa6:	00000097          	auipc	ra,0x0
    80002faa:	e2a080e7          	jalr	-470(ra) # 80002dd0 <argint>
    return -1;
    80002fae:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002fb0:	06054563          	bltz	a0,8000301a <sys_sleep+0x88>
  acquire(&tickslock);
    80002fb4:	00015517          	auipc	a0,0x15
    80002fb8:	9b450513          	addi	a0,a0,-1612 # 80017968 <tickslock>
    80002fbc:	ffffe097          	auipc	ra,0xffffe
    80002fc0:	c54080e7          	jalr	-940(ra) # 80000c10 <acquire>
  ticks0 = ticks;
    80002fc4:	00006917          	auipc	s2,0x6
    80002fc8:	05c92903          	lw	s2,92(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002fcc:	fcc42783          	lw	a5,-52(s0)
    80002fd0:	cf85                	beqz	a5,80003008 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fd2:	00015997          	auipc	s3,0x15
    80002fd6:	99698993          	addi	s3,s3,-1642 # 80017968 <tickslock>
    80002fda:	00006497          	auipc	s1,0x6
    80002fde:	04648493          	addi	s1,s1,70 # 80009020 <ticks>
    if(myproc()->killed){
    80002fe2:	fffff097          	auipc	ra,0xfffff
    80002fe6:	b30080e7          	jalr	-1232(ra) # 80001b12 <myproc>
    80002fea:	591c                	lw	a5,48(a0)
    80002fec:	ef9d                	bnez	a5,8000302a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002fee:	85ce                	mv	a1,s3
    80002ff0:	8526                	mv	a0,s1
    80002ff2:	fffff097          	auipc	ra,0xfffff
    80002ff6:	530080e7          	jalr	1328(ra) # 80002522 <sleep>
  while(ticks - ticks0 < n){
    80002ffa:	409c                	lw	a5,0(s1)
    80002ffc:	412787bb          	subw	a5,a5,s2
    80003000:	fcc42703          	lw	a4,-52(s0)
    80003004:	fce7efe3          	bltu	a5,a4,80002fe2 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003008:	00015517          	auipc	a0,0x15
    8000300c:	96050513          	addi	a0,a0,-1696 # 80017968 <tickslock>
    80003010:	ffffe097          	auipc	ra,0xffffe
    80003014:	cb4080e7          	jalr	-844(ra) # 80000cc4 <release>
  return 0;
    80003018:	4781                	li	a5,0
}
    8000301a:	853e                	mv	a0,a5
    8000301c:	70e2                	ld	ra,56(sp)
    8000301e:	7442                	ld	s0,48(sp)
    80003020:	74a2                	ld	s1,40(sp)
    80003022:	7902                	ld	s2,32(sp)
    80003024:	69e2                	ld	s3,24(sp)
    80003026:	6121                	addi	sp,sp,64
    80003028:	8082                	ret
      release(&tickslock);
    8000302a:	00015517          	auipc	a0,0x15
    8000302e:	93e50513          	addi	a0,a0,-1730 # 80017968 <tickslock>
    80003032:	ffffe097          	auipc	ra,0xffffe
    80003036:	c92080e7          	jalr	-878(ra) # 80000cc4 <release>
      return -1;
    8000303a:	57fd                	li	a5,-1
    8000303c:	bff9                	j	8000301a <sys_sleep+0x88>

000000008000303e <sys_kill>:

uint64
sys_kill(void)
{
    8000303e:	1101                	addi	sp,sp,-32
    80003040:	ec06                	sd	ra,24(sp)
    80003042:	e822                	sd	s0,16(sp)
    80003044:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003046:	fec40593          	addi	a1,s0,-20
    8000304a:	4501                	li	a0,0
    8000304c:	00000097          	auipc	ra,0x0
    80003050:	d84080e7          	jalr	-636(ra) # 80002dd0 <argint>
    80003054:	87aa                	mv	a5,a0
    return -1;
    80003056:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003058:	0007c863          	bltz	a5,80003068 <sys_kill+0x2a>
  return kill(pid);
    8000305c:	fec42503          	lw	a0,-20(s0)
    80003060:	fffff097          	auipc	ra,0xfffff
    80003064:	6b2080e7          	jalr	1714(ra) # 80002712 <kill>
}
    80003068:	60e2                	ld	ra,24(sp)
    8000306a:	6442                	ld	s0,16(sp)
    8000306c:	6105                	addi	sp,sp,32
    8000306e:	8082                	ret

0000000080003070 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003070:	1101                	addi	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000307a:	00015517          	auipc	a0,0x15
    8000307e:	8ee50513          	addi	a0,a0,-1810 # 80017968 <tickslock>
    80003082:	ffffe097          	auipc	ra,0xffffe
    80003086:	b8e080e7          	jalr	-1138(ra) # 80000c10 <acquire>
  xticks = ticks;
    8000308a:	00006497          	auipc	s1,0x6
    8000308e:	f964a483          	lw	s1,-106(s1) # 80009020 <ticks>
  release(&tickslock);
    80003092:	00015517          	auipc	a0,0x15
    80003096:	8d650513          	addi	a0,a0,-1834 # 80017968 <tickslock>
    8000309a:	ffffe097          	auipc	ra,0xffffe
    8000309e:	c2a080e7          	jalr	-982(ra) # 80000cc4 <release>
  return xticks;
}
    800030a2:	02049513          	slli	a0,s1,0x20
    800030a6:	9101                	srli	a0,a0,0x20
    800030a8:	60e2                	ld	ra,24(sp)
    800030aa:	6442                	ld	s0,16(sp)
    800030ac:	64a2                	ld	s1,8(sp)
    800030ae:	6105                	addi	sp,sp,32
    800030b0:	8082                	ret

00000000800030b2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030b2:	7179                	addi	sp,sp,-48
    800030b4:	f406                	sd	ra,40(sp)
    800030b6:	f022                	sd	s0,32(sp)
    800030b8:	ec26                	sd	s1,24(sp)
    800030ba:	e84a                	sd	s2,16(sp)
    800030bc:	e44e                	sd	s3,8(sp)
    800030be:	e052                	sd	s4,0(sp)
    800030c0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030c2:	00005597          	auipc	a1,0x5
    800030c6:	4be58593          	addi	a1,a1,1214 # 80008580 <syscalls+0xb0>
    800030ca:	00015517          	auipc	a0,0x15
    800030ce:	8b650513          	addi	a0,a0,-1866 # 80017980 <bcache>
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	aae080e7          	jalr	-1362(ra) # 80000b80 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030da:	0001d797          	auipc	a5,0x1d
    800030de:	8a678793          	addi	a5,a5,-1882 # 8001f980 <bcache+0x8000>
    800030e2:	0001d717          	auipc	a4,0x1d
    800030e6:	b0670713          	addi	a4,a4,-1274 # 8001fbe8 <bcache+0x8268>
    800030ea:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030ee:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030f2:	00015497          	auipc	s1,0x15
    800030f6:	8a648493          	addi	s1,s1,-1882 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    800030fa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030fc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030fe:	00005a17          	auipc	s4,0x5
    80003102:	48aa0a13          	addi	s4,s4,1162 # 80008588 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003106:	2b893783          	ld	a5,696(s2)
    8000310a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000310c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003110:	85d2                	mv	a1,s4
    80003112:	01048513          	addi	a0,s1,16
    80003116:	00001097          	auipc	ra,0x1
    8000311a:	4ac080e7          	jalr	1196(ra) # 800045c2 <initsleeplock>
    bcache.head.next->prev = b;
    8000311e:	2b893783          	ld	a5,696(s2)
    80003122:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003124:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003128:	45848493          	addi	s1,s1,1112
    8000312c:	fd349de3          	bne	s1,s3,80003106 <binit+0x54>
  }
}
    80003130:	70a2                	ld	ra,40(sp)
    80003132:	7402                	ld	s0,32(sp)
    80003134:	64e2                	ld	s1,24(sp)
    80003136:	6942                	ld	s2,16(sp)
    80003138:	69a2                	ld	s3,8(sp)
    8000313a:	6a02                	ld	s4,0(sp)
    8000313c:	6145                	addi	sp,sp,48
    8000313e:	8082                	ret

0000000080003140 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003140:	7179                	addi	sp,sp,-48
    80003142:	f406                	sd	ra,40(sp)
    80003144:	f022                	sd	s0,32(sp)
    80003146:	ec26                	sd	s1,24(sp)
    80003148:	e84a                	sd	s2,16(sp)
    8000314a:	e44e                	sd	s3,8(sp)
    8000314c:	1800                	addi	s0,sp,48
    8000314e:	89aa                	mv	s3,a0
    80003150:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003152:	00015517          	auipc	a0,0x15
    80003156:	82e50513          	addi	a0,a0,-2002 # 80017980 <bcache>
    8000315a:	ffffe097          	auipc	ra,0xffffe
    8000315e:	ab6080e7          	jalr	-1354(ra) # 80000c10 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003162:	0001d497          	auipc	s1,0x1d
    80003166:	ad64b483          	ld	s1,-1322(s1) # 8001fc38 <bcache+0x82b8>
    8000316a:	0001d797          	auipc	a5,0x1d
    8000316e:	a7e78793          	addi	a5,a5,-1410 # 8001fbe8 <bcache+0x8268>
    80003172:	02f48f63          	beq	s1,a5,800031b0 <bread+0x70>
    80003176:	873e                	mv	a4,a5
    80003178:	a021                	j	80003180 <bread+0x40>
    8000317a:	68a4                	ld	s1,80(s1)
    8000317c:	02e48a63          	beq	s1,a4,800031b0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003180:	449c                	lw	a5,8(s1)
    80003182:	ff379ce3          	bne	a5,s3,8000317a <bread+0x3a>
    80003186:	44dc                	lw	a5,12(s1)
    80003188:	ff2799e3          	bne	a5,s2,8000317a <bread+0x3a>
      b->refcnt++;
    8000318c:	40bc                	lw	a5,64(s1)
    8000318e:	2785                	addiw	a5,a5,1
    80003190:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003192:	00014517          	auipc	a0,0x14
    80003196:	7ee50513          	addi	a0,a0,2030 # 80017980 <bcache>
    8000319a:	ffffe097          	auipc	ra,0xffffe
    8000319e:	b2a080e7          	jalr	-1238(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    800031a2:	01048513          	addi	a0,s1,16
    800031a6:	00001097          	auipc	ra,0x1
    800031aa:	456080e7          	jalr	1110(ra) # 800045fc <acquiresleep>
      return b;
    800031ae:	a8b9                	j	8000320c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031b0:	0001d497          	auipc	s1,0x1d
    800031b4:	a804b483          	ld	s1,-1408(s1) # 8001fc30 <bcache+0x82b0>
    800031b8:	0001d797          	auipc	a5,0x1d
    800031bc:	a3078793          	addi	a5,a5,-1488 # 8001fbe8 <bcache+0x8268>
    800031c0:	00f48863          	beq	s1,a5,800031d0 <bread+0x90>
    800031c4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031c6:	40bc                	lw	a5,64(s1)
    800031c8:	cf81                	beqz	a5,800031e0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031ca:	64a4                	ld	s1,72(s1)
    800031cc:	fee49de3          	bne	s1,a4,800031c6 <bread+0x86>
  panic("bget: no buffers");
    800031d0:	00005517          	auipc	a0,0x5
    800031d4:	3c050513          	addi	a0,a0,960 # 80008590 <syscalls+0xc0>
    800031d8:	ffffd097          	auipc	ra,0xffffd
    800031dc:	370080e7          	jalr	880(ra) # 80000548 <panic>
      b->dev = dev;
    800031e0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800031e4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800031e8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031ec:	4785                	li	a5,1
    800031ee:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031f0:	00014517          	auipc	a0,0x14
    800031f4:	79050513          	addi	a0,a0,1936 # 80017980 <bcache>
    800031f8:	ffffe097          	auipc	ra,0xffffe
    800031fc:	acc080e7          	jalr	-1332(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    80003200:	01048513          	addi	a0,s1,16
    80003204:	00001097          	auipc	ra,0x1
    80003208:	3f8080e7          	jalr	1016(ra) # 800045fc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000320c:	409c                	lw	a5,0(s1)
    8000320e:	cb89                	beqz	a5,80003220 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003210:	8526                	mv	a0,s1
    80003212:	70a2                	ld	ra,40(sp)
    80003214:	7402                	ld	s0,32(sp)
    80003216:	64e2                	ld	s1,24(sp)
    80003218:	6942                	ld	s2,16(sp)
    8000321a:	69a2                	ld	s3,8(sp)
    8000321c:	6145                	addi	sp,sp,48
    8000321e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003220:	4581                	li	a1,0
    80003222:	8526                	mv	a0,s1
    80003224:	00003097          	auipc	ra,0x3
    80003228:	f78080e7          	jalr	-136(ra) # 8000619c <virtio_disk_rw>
    b->valid = 1;
    8000322c:	4785                	li	a5,1
    8000322e:	c09c                	sw	a5,0(s1)
  return b;
    80003230:	b7c5                	j	80003210 <bread+0xd0>

0000000080003232 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003232:	1101                	addi	sp,sp,-32
    80003234:	ec06                	sd	ra,24(sp)
    80003236:	e822                	sd	s0,16(sp)
    80003238:	e426                	sd	s1,8(sp)
    8000323a:	1000                	addi	s0,sp,32
    8000323c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000323e:	0541                	addi	a0,a0,16
    80003240:	00001097          	auipc	ra,0x1
    80003244:	456080e7          	jalr	1110(ra) # 80004696 <holdingsleep>
    80003248:	cd01                	beqz	a0,80003260 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000324a:	4585                	li	a1,1
    8000324c:	8526                	mv	a0,s1
    8000324e:	00003097          	auipc	ra,0x3
    80003252:	f4e080e7          	jalr	-178(ra) # 8000619c <virtio_disk_rw>
}
    80003256:	60e2                	ld	ra,24(sp)
    80003258:	6442                	ld	s0,16(sp)
    8000325a:	64a2                	ld	s1,8(sp)
    8000325c:	6105                	addi	sp,sp,32
    8000325e:	8082                	ret
    panic("bwrite");
    80003260:	00005517          	auipc	a0,0x5
    80003264:	34850513          	addi	a0,a0,840 # 800085a8 <syscalls+0xd8>
    80003268:	ffffd097          	auipc	ra,0xffffd
    8000326c:	2e0080e7          	jalr	736(ra) # 80000548 <panic>

0000000080003270 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003270:	1101                	addi	sp,sp,-32
    80003272:	ec06                	sd	ra,24(sp)
    80003274:	e822                	sd	s0,16(sp)
    80003276:	e426                	sd	s1,8(sp)
    80003278:	e04a                	sd	s2,0(sp)
    8000327a:	1000                	addi	s0,sp,32
    8000327c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000327e:	01050913          	addi	s2,a0,16
    80003282:	854a                	mv	a0,s2
    80003284:	00001097          	auipc	ra,0x1
    80003288:	412080e7          	jalr	1042(ra) # 80004696 <holdingsleep>
    8000328c:	c92d                	beqz	a0,800032fe <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000328e:	854a                	mv	a0,s2
    80003290:	00001097          	auipc	ra,0x1
    80003294:	3c2080e7          	jalr	962(ra) # 80004652 <releasesleep>

  acquire(&bcache.lock);
    80003298:	00014517          	auipc	a0,0x14
    8000329c:	6e850513          	addi	a0,a0,1768 # 80017980 <bcache>
    800032a0:	ffffe097          	auipc	ra,0xffffe
    800032a4:	970080e7          	jalr	-1680(ra) # 80000c10 <acquire>
  b->refcnt--;
    800032a8:	40bc                	lw	a5,64(s1)
    800032aa:	37fd                	addiw	a5,a5,-1
    800032ac:	0007871b          	sext.w	a4,a5
    800032b0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032b2:	eb05                	bnez	a4,800032e2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032b4:	68bc                	ld	a5,80(s1)
    800032b6:	64b8                	ld	a4,72(s1)
    800032b8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032ba:	64bc                	ld	a5,72(s1)
    800032bc:	68b8                	ld	a4,80(s1)
    800032be:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032c0:	0001c797          	auipc	a5,0x1c
    800032c4:	6c078793          	addi	a5,a5,1728 # 8001f980 <bcache+0x8000>
    800032c8:	2b87b703          	ld	a4,696(a5)
    800032cc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032ce:	0001d717          	auipc	a4,0x1d
    800032d2:	91a70713          	addi	a4,a4,-1766 # 8001fbe8 <bcache+0x8268>
    800032d6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032d8:	2b87b703          	ld	a4,696(a5)
    800032dc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032de:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032e2:	00014517          	auipc	a0,0x14
    800032e6:	69e50513          	addi	a0,a0,1694 # 80017980 <bcache>
    800032ea:	ffffe097          	auipc	ra,0xffffe
    800032ee:	9da080e7          	jalr	-1574(ra) # 80000cc4 <release>
}
    800032f2:	60e2                	ld	ra,24(sp)
    800032f4:	6442                	ld	s0,16(sp)
    800032f6:	64a2                	ld	s1,8(sp)
    800032f8:	6902                	ld	s2,0(sp)
    800032fa:	6105                	addi	sp,sp,32
    800032fc:	8082                	ret
    panic("brelse");
    800032fe:	00005517          	auipc	a0,0x5
    80003302:	2b250513          	addi	a0,a0,690 # 800085b0 <syscalls+0xe0>
    80003306:	ffffd097          	auipc	ra,0xffffd
    8000330a:	242080e7          	jalr	578(ra) # 80000548 <panic>

000000008000330e <bpin>:

void
bpin(struct buf *b) {
    8000330e:	1101                	addi	sp,sp,-32
    80003310:	ec06                	sd	ra,24(sp)
    80003312:	e822                	sd	s0,16(sp)
    80003314:	e426                	sd	s1,8(sp)
    80003316:	1000                	addi	s0,sp,32
    80003318:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000331a:	00014517          	auipc	a0,0x14
    8000331e:	66650513          	addi	a0,a0,1638 # 80017980 <bcache>
    80003322:	ffffe097          	auipc	ra,0xffffe
    80003326:	8ee080e7          	jalr	-1810(ra) # 80000c10 <acquire>
  b->refcnt++;
    8000332a:	40bc                	lw	a5,64(s1)
    8000332c:	2785                	addiw	a5,a5,1
    8000332e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003330:	00014517          	auipc	a0,0x14
    80003334:	65050513          	addi	a0,a0,1616 # 80017980 <bcache>
    80003338:	ffffe097          	auipc	ra,0xffffe
    8000333c:	98c080e7          	jalr	-1652(ra) # 80000cc4 <release>
}
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	64a2                	ld	s1,8(sp)
    80003346:	6105                	addi	sp,sp,32
    80003348:	8082                	ret

000000008000334a <bunpin>:

void
bunpin(struct buf *b) {
    8000334a:	1101                	addi	sp,sp,-32
    8000334c:	ec06                	sd	ra,24(sp)
    8000334e:	e822                	sd	s0,16(sp)
    80003350:	e426                	sd	s1,8(sp)
    80003352:	1000                	addi	s0,sp,32
    80003354:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003356:	00014517          	auipc	a0,0x14
    8000335a:	62a50513          	addi	a0,a0,1578 # 80017980 <bcache>
    8000335e:	ffffe097          	auipc	ra,0xffffe
    80003362:	8b2080e7          	jalr	-1870(ra) # 80000c10 <acquire>
  b->refcnt--;
    80003366:	40bc                	lw	a5,64(s1)
    80003368:	37fd                	addiw	a5,a5,-1
    8000336a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000336c:	00014517          	auipc	a0,0x14
    80003370:	61450513          	addi	a0,a0,1556 # 80017980 <bcache>
    80003374:	ffffe097          	auipc	ra,0xffffe
    80003378:	950080e7          	jalr	-1712(ra) # 80000cc4 <release>
}
    8000337c:	60e2                	ld	ra,24(sp)
    8000337e:	6442                	ld	s0,16(sp)
    80003380:	64a2                	ld	s1,8(sp)
    80003382:	6105                	addi	sp,sp,32
    80003384:	8082                	ret

0000000080003386 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003386:	1101                	addi	sp,sp,-32
    80003388:	ec06                	sd	ra,24(sp)
    8000338a:	e822                	sd	s0,16(sp)
    8000338c:	e426                	sd	s1,8(sp)
    8000338e:	e04a                	sd	s2,0(sp)
    80003390:	1000                	addi	s0,sp,32
    80003392:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003394:	00d5d59b          	srliw	a1,a1,0xd
    80003398:	0001d797          	auipc	a5,0x1d
    8000339c:	cc47a783          	lw	a5,-828(a5) # 8002005c <sb+0x1c>
    800033a0:	9dbd                	addw	a1,a1,a5
    800033a2:	00000097          	auipc	ra,0x0
    800033a6:	d9e080e7          	jalr	-610(ra) # 80003140 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033aa:	0074f713          	andi	a4,s1,7
    800033ae:	4785                	li	a5,1
    800033b0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033b4:	14ce                	slli	s1,s1,0x33
    800033b6:	90d9                	srli	s1,s1,0x36
    800033b8:	00950733          	add	a4,a0,s1
    800033bc:	05874703          	lbu	a4,88(a4)
    800033c0:	00e7f6b3          	and	a3,a5,a4
    800033c4:	c69d                	beqz	a3,800033f2 <bfree+0x6c>
    800033c6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033c8:	94aa                	add	s1,s1,a0
    800033ca:	fff7c793          	not	a5,a5
    800033ce:	8ff9                	and	a5,a5,a4
    800033d0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033d4:	00001097          	auipc	ra,0x1
    800033d8:	100080e7          	jalr	256(ra) # 800044d4 <log_write>
  brelse(bp);
    800033dc:	854a                	mv	a0,s2
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	e92080e7          	jalr	-366(ra) # 80003270 <brelse>
}
    800033e6:	60e2                	ld	ra,24(sp)
    800033e8:	6442                	ld	s0,16(sp)
    800033ea:	64a2                	ld	s1,8(sp)
    800033ec:	6902                	ld	s2,0(sp)
    800033ee:	6105                	addi	sp,sp,32
    800033f0:	8082                	ret
    panic("freeing free block");
    800033f2:	00005517          	auipc	a0,0x5
    800033f6:	1c650513          	addi	a0,a0,454 # 800085b8 <syscalls+0xe8>
    800033fa:	ffffd097          	auipc	ra,0xffffd
    800033fe:	14e080e7          	jalr	334(ra) # 80000548 <panic>

0000000080003402 <balloc>:
{
    80003402:	711d                	addi	sp,sp,-96
    80003404:	ec86                	sd	ra,88(sp)
    80003406:	e8a2                	sd	s0,80(sp)
    80003408:	e4a6                	sd	s1,72(sp)
    8000340a:	e0ca                	sd	s2,64(sp)
    8000340c:	fc4e                	sd	s3,56(sp)
    8000340e:	f852                	sd	s4,48(sp)
    80003410:	f456                	sd	s5,40(sp)
    80003412:	f05a                	sd	s6,32(sp)
    80003414:	ec5e                	sd	s7,24(sp)
    80003416:	e862                	sd	s8,16(sp)
    80003418:	e466                	sd	s9,8(sp)
    8000341a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000341c:	0001d797          	auipc	a5,0x1d
    80003420:	c287a783          	lw	a5,-984(a5) # 80020044 <sb+0x4>
    80003424:	cbd1                	beqz	a5,800034b8 <balloc+0xb6>
    80003426:	8baa                	mv	s7,a0
    80003428:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000342a:	0001db17          	auipc	s6,0x1d
    8000342e:	c16b0b13          	addi	s6,s6,-1002 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003432:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003434:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003436:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003438:	6c89                	lui	s9,0x2
    8000343a:	a831                	j	80003456 <balloc+0x54>
    brelse(bp);
    8000343c:	854a                	mv	a0,s2
    8000343e:	00000097          	auipc	ra,0x0
    80003442:	e32080e7          	jalr	-462(ra) # 80003270 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003446:	015c87bb          	addw	a5,s9,s5
    8000344a:	00078a9b          	sext.w	s5,a5
    8000344e:	004b2703          	lw	a4,4(s6)
    80003452:	06eaf363          	bgeu	s5,a4,800034b8 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003456:	41fad79b          	sraiw	a5,s5,0x1f
    8000345a:	0137d79b          	srliw	a5,a5,0x13
    8000345e:	015787bb          	addw	a5,a5,s5
    80003462:	40d7d79b          	sraiw	a5,a5,0xd
    80003466:	01cb2583          	lw	a1,28(s6)
    8000346a:	9dbd                	addw	a1,a1,a5
    8000346c:	855e                	mv	a0,s7
    8000346e:	00000097          	auipc	ra,0x0
    80003472:	cd2080e7          	jalr	-814(ra) # 80003140 <bread>
    80003476:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003478:	004b2503          	lw	a0,4(s6)
    8000347c:	000a849b          	sext.w	s1,s5
    80003480:	8662                	mv	a2,s8
    80003482:	faa4fde3          	bgeu	s1,a0,8000343c <balloc+0x3a>
      m = 1 << (bi % 8);
    80003486:	41f6579b          	sraiw	a5,a2,0x1f
    8000348a:	01d7d69b          	srliw	a3,a5,0x1d
    8000348e:	00c6873b          	addw	a4,a3,a2
    80003492:	00777793          	andi	a5,a4,7
    80003496:	9f95                	subw	a5,a5,a3
    80003498:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000349c:	4037571b          	sraiw	a4,a4,0x3
    800034a0:	00e906b3          	add	a3,s2,a4
    800034a4:	0586c683          	lbu	a3,88(a3)
    800034a8:	00d7f5b3          	and	a1,a5,a3
    800034ac:	cd91                	beqz	a1,800034c8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ae:	2605                	addiw	a2,a2,1
    800034b0:	2485                	addiw	s1,s1,1
    800034b2:	fd4618e3          	bne	a2,s4,80003482 <balloc+0x80>
    800034b6:	b759                	j	8000343c <balloc+0x3a>
  panic("balloc: out of blocks");
    800034b8:	00005517          	auipc	a0,0x5
    800034bc:	11850513          	addi	a0,a0,280 # 800085d0 <syscalls+0x100>
    800034c0:	ffffd097          	auipc	ra,0xffffd
    800034c4:	088080e7          	jalr	136(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034c8:	974a                	add	a4,a4,s2
    800034ca:	8fd5                	or	a5,a5,a3
    800034cc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800034d0:	854a                	mv	a0,s2
    800034d2:	00001097          	auipc	ra,0x1
    800034d6:	002080e7          	jalr	2(ra) # 800044d4 <log_write>
        brelse(bp);
    800034da:	854a                	mv	a0,s2
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	d94080e7          	jalr	-620(ra) # 80003270 <brelse>
  bp = bread(dev, bno);
    800034e4:	85a6                	mv	a1,s1
    800034e6:	855e                	mv	a0,s7
    800034e8:	00000097          	auipc	ra,0x0
    800034ec:	c58080e7          	jalr	-936(ra) # 80003140 <bread>
    800034f0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034f2:	40000613          	li	a2,1024
    800034f6:	4581                	li	a1,0
    800034f8:	05850513          	addi	a0,a0,88
    800034fc:	ffffe097          	auipc	ra,0xffffe
    80003500:	810080e7          	jalr	-2032(ra) # 80000d0c <memset>
  log_write(bp);
    80003504:	854a                	mv	a0,s2
    80003506:	00001097          	auipc	ra,0x1
    8000350a:	fce080e7          	jalr	-50(ra) # 800044d4 <log_write>
  brelse(bp);
    8000350e:	854a                	mv	a0,s2
    80003510:	00000097          	auipc	ra,0x0
    80003514:	d60080e7          	jalr	-672(ra) # 80003270 <brelse>
}
    80003518:	8526                	mv	a0,s1
    8000351a:	60e6                	ld	ra,88(sp)
    8000351c:	6446                	ld	s0,80(sp)
    8000351e:	64a6                	ld	s1,72(sp)
    80003520:	6906                	ld	s2,64(sp)
    80003522:	79e2                	ld	s3,56(sp)
    80003524:	7a42                	ld	s4,48(sp)
    80003526:	7aa2                	ld	s5,40(sp)
    80003528:	7b02                	ld	s6,32(sp)
    8000352a:	6be2                	ld	s7,24(sp)
    8000352c:	6c42                	ld	s8,16(sp)
    8000352e:	6ca2                	ld	s9,8(sp)
    80003530:	6125                	addi	sp,sp,96
    80003532:	8082                	ret

0000000080003534 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003534:	7179                	addi	sp,sp,-48
    80003536:	f406                	sd	ra,40(sp)
    80003538:	f022                	sd	s0,32(sp)
    8000353a:	ec26                	sd	s1,24(sp)
    8000353c:	e84a                	sd	s2,16(sp)
    8000353e:	e44e                	sd	s3,8(sp)
    80003540:	e052                	sd	s4,0(sp)
    80003542:	1800                	addi	s0,sp,48
    80003544:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003546:	47ad                	li	a5,11
    80003548:	04b7fe63          	bgeu	a5,a1,800035a4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000354c:	ff45849b          	addiw	s1,a1,-12
    80003550:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003554:	0ff00793          	li	a5,255
    80003558:	0ae7e363          	bltu	a5,a4,800035fe <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000355c:	08052583          	lw	a1,128(a0)
    80003560:	c5ad                	beqz	a1,800035ca <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003562:	00092503          	lw	a0,0(s2)
    80003566:	00000097          	auipc	ra,0x0
    8000356a:	bda080e7          	jalr	-1062(ra) # 80003140 <bread>
    8000356e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003570:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003574:	02049593          	slli	a1,s1,0x20
    80003578:	9181                	srli	a1,a1,0x20
    8000357a:	058a                	slli	a1,a1,0x2
    8000357c:	00b784b3          	add	s1,a5,a1
    80003580:	0004a983          	lw	s3,0(s1)
    80003584:	04098d63          	beqz	s3,800035de <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003588:	8552                	mv	a0,s4
    8000358a:	00000097          	auipc	ra,0x0
    8000358e:	ce6080e7          	jalr	-794(ra) # 80003270 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003592:	854e                	mv	a0,s3
    80003594:	70a2                	ld	ra,40(sp)
    80003596:	7402                	ld	s0,32(sp)
    80003598:	64e2                	ld	s1,24(sp)
    8000359a:	6942                	ld	s2,16(sp)
    8000359c:	69a2                	ld	s3,8(sp)
    8000359e:	6a02                	ld	s4,0(sp)
    800035a0:	6145                	addi	sp,sp,48
    800035a2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800035a4:	02059493          	slli	s1,a1,0x20
    800035a8:	9081                	srli	s1,s1,0x20
    800035aa:	048a                	slli	s1,s1,0x2
    800035ac:	94aa                	add	s1,s1,a0
    800035ae:	0504a983          	lw	s3,80(s1)
    800035b2:	fe0990e3          	bnez	s3,80003592 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800035b6:	4108                	lw	a0,0(a0)
    800035b8:	00000097          	auipc	ra,0x0
    800035bc:	e4a080e7          	jalr	-438(ra) # 80003402 <balloc>
    800035c0:	0005099b          	sext.w	s3,a0
    800035c4:	0534a823          	sw	s3,80(s1)
    800035c8:	b7e9                	j	80003592 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800035ca:	4108                	lw	a0,0(a0)
    800035cc:	00000097          	auipc	ra,0x0
    800035d0:	e36080e7          	jalr	-458(ra) # 80003402 <balloc>
    800035d4:	0005059b          	sext.w	a1,a0
    800035d8:	08b92023          	sw	a1,128(s2)
    800035dc:	b759                	j	80003562 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800035de:	00092503          	lw	a0,0(s2)
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	e20080e7          	jalr	-480(ra) # 80003402 <balloc>
    800035ea:	0005099b          	sext.w	s3,a0
    800035ee:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800035f2:	8552                	mv	a0,s4
    800035f4:	00001097          	auipc	ra,0x1
    800035f8:	ee0080e7          	jalr	-288(ra) # 800044d4 <log_write>
    800035fc:	b771                	j	80003588 <bmap+0x54>
  panic("bmap: out of range");
    800035fe:	00005517          	auipc	a0,0x5
    80003602:	fea50513          	addi	a0,a0,-22 # 800085e8 <syscalls+0x118>
    80003606:	ffffd097          	auipc	ra,0xffffd
    8000360a:	f42080e7          	jalr	-190(ra) # 80000548 <panic>

000000008000360e <iget>:
{
    8000360e:	7179                	addi	sp,sp,-48
    80003610:	f406                	sd	ra,40(sp)
    80003612:	f022                	sd	s0,32(sp)
    80003614:	ec26                	sd	s1,24(sp)
    80003616:	e84a                	sd	s2,16(sp)
    80003618:	e44e                	sd	s3,8(sp)
    8000361a:	e052                	sd	s4,0(sp)
    8000361c:	1800                	addi	s0,sp,48
    8000361e:	89aa                	mv	s3,a0
    80003620:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003622:	0001d517          	auipc	a0,0x1d
    80003626:	a3e50513          	addi	a0,a0,-1474 # 80020060 <icache>
    8000362a:	ffffd097          	auipc	ra,0xffffd
    8000362e:	5e6080e7          	jalr	1510(ra) # 80000c10 <acquire>
  empty = 0;
    80003632:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003634:	0001d497          	auipc	s1,0x1d
    80003638:	a4448493          	addi	s1,s1,-1468 # 80020078 <icache+0x18>
    8000363c:	0001e697          	auipc	a3,0x1e
    80003640:	4cc68693          	addi	a3,a3,1228 # 80021b08 <log>
    80003644:	a039                	j	80003652 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003646:	02090b63          	beqz	s2,8000367c <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000364a:	08848493          	addi	s1,s1,136
    8000364e:	02d48a63          	beq	s1,a3,80003682 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003652:	449c                	lw	a5,8(s1)
    80003654:	fef059e3          	blez	a5,80003646 <iget+0x38>
    80003658:	4098                	lw	a4,0(s1)
    8000365a:	ff3716e3          	bne	a4,s3,80003646 <iget+0x38>
    8000365e:	40d8                	lw	a4,4(s1)
    80003660:	ff4713e3          	bne	a4,s4,80003646 <iget+0x38>
      ip->ref++;
    80003664:	2785                	addiw	a5,a5,1
    80003666:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003668:	0001d517          	auipc	a0,0x1d
    8000366c:	9f850513          	addi	a0,a0,-1544 # 80020060 <icache>
    80003670:	ffffd097          	auipc	ra,0xffffd
    80003674:	654080e7          	jalr	1620(ra) # 80000cc4 <release>
      return ip;
    80003678:	8926                	mv	s2,s1
    8000367a:	a03d                	j	800036a8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000367c:	f7f9                	bnez	a5,8000364a <iget+0x3c>
    8000367e:	8926                	mv	s2,s1
    80003680:	b7e9                	j	8000364a <iget+0x3c>
  if(empty == 0)
    80003682:	02090c63          	beqz	s2,800036ba <iget+0xac>
  ip->dev = dev;
    80003686:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000368a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000368e:	4785                	li	a5,1
    80003690:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003694:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003698:	0001d517          	auipc	a0,0x1d
    8000369c:	9c850513          	addi	a0,a0,-1592 # 80020060 <icache>
    800036a0:	ffffd097          	auipc	ra,0xffffd
    800036a4:	624080e7          	jalr	1572(ra) # 80000cc4 <release>
}
    800036a8:	854a                	mv	a0,s2
    800036aa:	70a2                	ld	ra,40(sp)
    800036ac:	7402                	ld	s0,32(sp)
    800036ae:	64e2                	ld	s1,24(sp)
    800036b0:	6942                	ld	s2,16(sp)
    800036b2:	69a2                	ld	s3,8(sp)
    800036b4:	6a02                	ld	s4,0(sp)
    800036b6:	6145                	addi	sp,sp,48
    800036b8:	8082                	ret
    panic("iget: no inodes");
    800036ba:	00005517          	auipc	a0,0x5
    800036be:	f4650513          	addi	a0,a0,-186 # 80008600 <syscalls+0x130>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	e86080e7          	jalr	-378(ra) # 80000548 <panic>

00000000800036ca <fsinit>:
fsinit(int dev) {
    800036ca:	7179                	addi	sp,sp,-48
    800036cc:	f406                	sd	ra,40(sp)
    800036ce:	f022                	sd	s0,32(sp)
    800036d0:	ec26                	sd	s1,24(sp)
    800036d2:	e84a                	sd	s2,16(sp)
    800036d4:	e44e                	sd	s3,8(sp)
    800036d6:	1800                	addi	s0,sp,48
    800036d8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036da:	4585                	li	a1,1
    800036dc:	00000097          	auipc	ra,0x0
    800036e0:	a64080e7          	jalr	-1436(ra) # 80003140 <bread>
    800036e4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036e6:	0001d997          	auipc	s3,0x1d
    800036ea:	95a98993          	addi	s3,s3,-1702 # 80020040 <sb>
    800036ee:	02000613          	li	a2,32
    800036f2:	05850593          	addi	a1,a0,88
    800036f6:	854e                	mv	a0,s3
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	674080e7          	jalr	1652(ra) # 80000d6c <memmove>
  brelse(bp);
    80003700:	8526                	mv	a0,s1
    80003702:	00000097          	auipc	ra,0x0
    80003706:	b6e080e7          	jalr	-1170(ra) # 80003270 <brelse>
  if(sb.magic != FSMAGIC)
    8000370a:	0009a703          	lw	a4,0(s3)
    8000370e:	102037b7          	lui	a5,0x10203
    80003712:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003716:	02f71263          	bne	a4,a5,8000373a <fsinit+0x70>
  initlog(dev, &sb);
    8000371a:	0001d597          	auipc	a1,0x1d
    8000371e:	92658593          	addi	a1,a1,-1754 # 80020040 <sb>
    80003722:	854a                	mv	a0,s2
    80003724:	00001097          	auipc	ra,0x1
    80003728:	b38080e7          	jalr	-1224(ra) # 8000425c <initlog>
}
    8000372c:	70a2                	ld	ra,40(sp)
    8000372e:	7402                	ld	s0,32(sp)
    80003730:	64e2                	ld	s1,24(sp)
    80003732:	6942                	ld	s2,16(sp)
    80003734:	69a2                	ld	s3,8(sp)
    80003736:	6145                	addi	sp,sp,48
    80003738:	8082                	ret
    panic("invalid file system");
    8000373a:	00005517          	auipc	a0,0x5
    8000373e:	ed650513          	addi	a0,a0,-298 # 80008610 <syscalls+0x140>
    80003742:	ffffd097          	auipc	ra,0xffffd
    80003746:	e06080e7          	jalr	-506(ra) # 80000548 <panic>

000000008000374a <iinit>:
{
    8000374a:	7179                	addi	sp,sp,-48
    8000374c:	f406                	sd	ra,40(sp)
    8000374e:	f022                	sd	s0,32(sp)
    80003750:	ec26                	sd	s1,24(sp)
    80003752:	e84a                	sd	s2,16(sp)
    80003754:	e44e                	sd	s3,8(sp)
    80003756:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003758:	00005597          	auipc	a1,0x5
    8000375c:	ed058593          	addi	a1,a1,-304 # 80008628 <syscalls+0x158>
    80003760:	0001d517          	auipc	a0,0x1d
    80003764:	90050513          	addi	a0,a0,-1792 # 80020060 <icache>
    80003768:	ffffd097          	auipc	ra,0xffffd
    8000376c:	418080e7          	jalr	1048(ra) # 80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003770:	0001d497          	auipc	s1,0x1d
    80003774:	91848493          	addi	s1,s1,-1768 # 80020088 <icache+0x28>
    80003778:	0001e997          	auipc	s3,0x1e
    8000377c:	3a098993          	addi	s3,s3,928 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003780:	00005917          	auipc	s2,0x5
    80003784:	eb090913          	addi	s2,s2,-336 # 80008630 <syscalls+0x160>
    80003788:	85ca                	mv	a1,s2
    8000378a:	8526                	mv	a0,s1
    8000378c:	00001097          	auipc	ra,0x1
    80003790:	e36080e7          	jalr	-458(ra) # 800045c2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003794:	08848493          	addi	s1,s1,136
    80003798:	ff3498e3          	bne	s1,s3,80003788 <iinit+0x3e>
}
    8000379c:	70a2                	ld	ra,40(sp)
    8000379e:	7402                	ld	s0,32(sp)
    800037a0:	64e2                	ld	s1,24(sp)
    800037a2:	6942                	ld	s2,16(sp)
    800037a4:	69a2                	ld	s3,8(sp)
    800037a6:	6145                	addi	sp,sp,48
    800037a8:	8082                	ret

00000000800037aa <ialloc>:
{
    800037aa:	715d                	addi	sp,sp,-80
    800037ac:	e486                	sd	ra,72(sp)
    800037ae:	e0a2                	sd	s0,64(sp)
    800037b0:	fc26                	sd	s1,56(sp)
    800037b2:	f84a                	sd	s2,48(sp)
    800037b4:	f44e                	sd	s3,40(sp)
    800037b6:	f052                	sd	s4,32(sp)
    800037b8:	ec56                	sd	s5,24(sp)
    800037ba:	e85a                	sd	s6,16(sp)
    800037bc:	e45e                	sd	s7,8(sp)
    800037be:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037c0:	0001d717          	auipc	a4,0x1d
    800037c4:	88c72703          	lw	a4,-1908(a4) # 8002004c <sb+0xc>
    800037c8:	4785                	li	a5,1
    800037ca:	04e7fa63          	bgeu	a5,a4,8000381e <ialloc+0x74>
    800037ce:	8aaa                	mv	s5,a0
    800037d0:	8bae                	mv	s7,a1
    800037d2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037d4:	0001da17          	auipc	s4,0x1d
    800037d8:	86ca0a13          	addi	s4,s4,-1940 # 80020040 <sb>
    800037dc:	00048b1b          	sext.w	s6,s1
    800037e0:	0044d593          	srli	a1,s1,0x4
    800037e4:	018a2783          	lw	a5,24(s4)
    800037e8:	9dbd                	addw	a1,a1,a5
    800037ea:	8556                	mv	a0,s5
    800037ec:	00000097          	auipc	ra,0x0
    800037f0:	954080e7          	jalr	-1708(ra) # 80003140 <bread>
    800037f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037f6:	05850993          	addi	s3,a0,88
    800037fa:	00f4f793          	andi	a5,s1,15
    800037fe:	079a                	slli	a5,a5,0x6
    80003800:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003802:	00099783          	lh	a5,0(s3)
    80003806:	c785                	beqz	a5,8000382e <ialloc+0x84>
    brelse(bp);
    80003808:	00000097          	auipc	ra,0x0
    8000380c:	a68080e7          	jalr	-1432(ra) # 80003270 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003810:	0485                	addi	s1,s1,1
    80003812:	00ca2703          	lw	a4,12(s4)
    80003816:	0004879b          	sext.w	a5,s1
    8000381a:	fce7e1e3          	bltu	a5,a4,800037dc <ialloc+0x32>
  panic("ialloc: no inodes");
    8000381e:	00005517          	auipc	a0,0x5
    80003822:	e1a50513          	addi	a0,a0,-486 # 80008638 <syscalls+0x168>
    80003826:	ffffd097          	auipc	ra,0xffffd
    8000382a:	d22080e7          	jalr	-734(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    8000382e:	04000613          	li	a2,64
    80003832:	4581                	li	a1,0
    80003834:	854e                	mv	a0,s3
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	4d6080e7          	jalr	1238(ra) # 80000d0c <memset>
      dip->type = type;
    8000383e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003842:	854a                	mv	a0,s2
    80003844:	00001097          	auipc	ra,0x1
    80003848:	c90080e7          	jalr	-880(ra) # 800044d4 <log_write>
      brelse(bp);
    8000384c:	854a                	mv	a0,s2
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	a22080e7          	jalr	-1502(ra) # 80003270 <brelse>
      return iget(dev, inum);
    80003856:	85da                	mv	a1,s6
    80003858:	8556                	mv	a0,s5
    8000385a:	00000097          	auipc	ra,0x0
    8000385e:	db4080e7          	jalr	-588(ra) # 8000360e <iget>
}
    80003862:	60a6                	ld	ra,72(sp)
    80003864:	6406                	ld	s0,64(sp)
    80003866:	74e2                	ld	s1,56(sp)
    80003868:	7942                	ld	s2,48(sp)
    8000386a:	79a2                	ld	s3,40(sp)
    8000386c:	7a02                	ld	s4,32(sp)
    8000386e:	6ae2                	ld	s5,24(sp)
    80003870:	6b42                	ld	s6,16(sp)
    80003872:	6ba2                	ld	s7,8(sp)
    80003874:	6161                	addi	sp,sp,80
    80003876:	8082                	ret

0000000080003878 <iupdate>:
{
    80003878:	1101                	addi	sp,sp,-32
    8000387a:	ec06                	sd	ra,24(sp)
    8000387c:	e822                	sd	s0,16(sp)
    8000387e:	e426                	sd	s1,8(sp)
    80003880:	e04a                	sd	s2,0(sp)
    80003882:	1000                	addi	s0,sp,32
    80003884:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003886:	415c                	lw	a5,4(a0)
    80003888:	0047d79b          	srliw	a5,a5,0x4
    8000388c:	0001c597          	auipc	a1,0x1c
    80003890:	7cc5a583          	lw	a1,1996(a1) # 80020058 <sb+0x18>
    80003894:	9dbd                	addw	a1,a1,a5
    80003896:	4108                	lw	a0,0(a0)
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	8a8080e7          	jalr	-1880(ra) # 80003140 <bread>
    800038a0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038a2:	05850793          	addi	a5,a0,88
    800038a6:	40c8                	lw	a0,4(s1)
    800038a8:	893d                	andi	a0,a0,15
    800038aa:	051a                	slli	a0,a0,0x6
    800038ac:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038ae:	04449703          	lh	a4,68(s1)
    800038b2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038b6:	04649703          	lh	a4,70(s1)
    800038ba:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038be:	04849703          	lh	a4,72(s1)
    800038c2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038c6:	04a49703          	lh	a4,74(s1)
    800038ca:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038ce:	44f8                	lw	a4,76(s1)
    800038d0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038d2:	03400613          	li	a2,52
    800038d6:	05048593          	addi	a1,s1,80
    800038da:	0531                	addi	a0,a0,12
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	490080e7          	jalr	1168(ra) # 80000d6c <memmove>
  log_write(bp);
    800038e4:	854a                	mv	a0,s2
    800038e6:	00001097          	auipc	ra,0x1
    800038ea:	bee080e7          	jalr	-1042(ra) # 800044d4 <log_write>
  brelse(bp);
    800038ee:	854a                	mv	a0,s2
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	980080e7          	jalr	-1664(ra) # 80003270 <brelse>
}
    800038f8:	60e2                	ld	ra,24(sp)
    800038fa:	6442                	ld	s0,16(sp)
    800038fc:	64a2                	ld	s1,8(sp)
    800038fe:	6902                	ld	s2,0(sp)
    80003900:	6105                	addi	sp,sp,32
    80003902:	8082                	ret

0000000080003904 <idup>:
{
    80003904:	1101                	addi	sp,sp,-32
    80003906:	ec06                	sd	ra,24(sp)
    80003908:	e822                	sd	s0,16(sp)
    8000390a:	e426                	sd	s1,8(sp)
    8000390c:	1000                	addi	s0,sp,32
    8000390e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003910:	0001c517          	auipc	a0,0x1c
    80003914:	75050513          	addi	a0,a0,1872 # 80020060 <icache>
    80003918:	ffffd097          	auipc	ra,0xffffd
    8000391c:	2f8080e7          	jalr	760(ra) # 80000c10 <acquire>
  ip->ref++;
    80003920:	449c                	lw	a5,8(s1)
    80003922:	2785                	addiw	a5,a5,1
    80003924:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003926:	0001c517          	auipc	a0,0x1c
    8000392a:	73a50513          	addi	a0,a0,1850 # 80020060 <icache>
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	396080e7          	jalr	918(ra) # 80000cc4 <release>
}
    80003936:	8526                	mv	a0,s1
    80003938:	60e2                	ld	ra,24(sp)
    8000393a:	6442                	ld	s0,16(sp)
    8000393c:	64a2                	ld	s1,8(sp)
    8000393e:	6105                	addi	sp,sp,32
    80003940:	8082                	ret

0000000080003942 <ilock>:
{
    80003942:	1101                	addi	sp,sp,-32
    80003944:	ec06                	sd	ra,24(sp)
    80003946:	e822                	sd	s0,16(sp)
    80003948:	e426                	sd	s1,8(sp)
    8000394a:	e04a                	sd	s2,0(sp)
    8000394c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000394e:	c115                	beqz	a0,80003972 <ilock+0x30>
    80003950:	84aa                	mv	s1,a0
    80003952:	451c                	lw	a5,8(a0)
    80003954:	00f05f63          	blez	a5,80003972 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003958:	0541                	addi	a0,a0,16
    8000395a:	00001097          	auipc	ra,0x1
    8000395e:	ca2080e7          	jalr	-862(ra) # 800045fc <acquiresleep>
  if(ip->valid == 0){
    80003962:	40bc                	lw	a5,64(s1)
    80003964:	cf99                	beqz	a5,80003982 <ilock+0x40>
}
    80003966:	60e2                	ld	ra,24(sp)
    80003968:	6442                	ld	s0,16(sp)
    8000396a:	64a2                	ld	s1,8(sp)
    8000396c:	6902                	ld	s2,0(sp)
    8000396e:	6105                	addi	sp,sp,32
    80003970:	8082                	ret
    panic("ilock");
    80003972:	00005517          	auipc	a0,0x5
    80003976:	cde50513          	addi	a0,a0,-802 # 80008650 <syscalls+0x180>
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	bce080e7          	jalr	-1074(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003982:	40dc                	lw	a5,4(s1)
    80003984:	0047d79b          	srliw	a5,a5,0x4
    80003988:	0001c597          	auipc	a1,0x1c
    8000398c:	6d05a583          	lw	a1,1744(a1) # 80020058 <sb+0x18>
    80003990:	9dbd                	addw	a1,a1,a5
    80003992:	4088                	lw	a0,0(s1)
    80003994:	fffff097          	auipc	ra,0xfffff
    80003998:	7ac080e7          	jalr	1964(ra) # 80003140 <bread>
    8000399c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000399e:	05850593          	addi	a1,a0,88
    800039a2:	40dc                	lw	a5,4(s1)
    800039a4:	8bbd                	andi	a5,a5,15
    800039a6:	079a                	slli	a5,a5,0x6
    800039a8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039aa:	00059783          	lh	a5,0(a1)
    800039ae:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039b2:	00259783          	lh	a5,2(a1)
    800039b6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039ba:	00459783          	lh	a5,4(a1)
    800039be:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039c2:	00659783          	lh	a5,6(a1)
    800039c6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039ca:	459c                	lw	a5,8(a1)
    800039cc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039ce:	03400613          	li	a2,52
    800039d2:	05b1                	addi	a1,a1,12
    800039d4:	05048513          	addi	a0,s1,80
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	394080e7          	jalr	916(ra) # 80000d6c <memmove>
    brelse(bp);
    800039e0:	854a                	mv	a0,s2
    800039e2:	00000097          	auipc	ra,0x0
    800039e6:	88e080e7          	jalr	-1906(ra) # 80003270 <brelse>
    ip->valid = 1;
    800039ea:	4785                	li	a5,1
    800039ec:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039ee:	04449783          	lh	a5,68(s1)
    800039f2:	fbb5                	bnez	a5,80003966 <ilock+0x24>
      panic("ilock: no type");
    800039f4:	00005517          	auipc	a0,0x5
    800039f8:	c6450513          	addi	a0,a0,-924 # 80008658 <syscalls+0x188>
    800039fc:	ffffd097          	auipc	ra,0xffffd
    80003a00:	b4c080e7          	jalr	-1204(ra) # 80000548 <panic>

0000000080003a04 <iunlock>:
{
    80003a04:	1101                	addi	sp,sp,-32
    80003a06:	ec06                	sd	ra,24(sp)
    80003a08:	e822                	sd	s0,16(sp)
    80003a0a:	e426                	sd	s1,8(sp)
    80003a0c:	e04a                	sd	s2,0(sp)
    80003a0e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a10:	c905                	beqz	a0,80003a40 <iunlock+0x3c>
    80003a12:	84aa                	mv	s1,a0
    80003a14:	01050913          	addi	s2,a0,16
    80003a18:	854a                	mv	a0,s2
    80003a1a:	00001097          	auipc	ra,0x1
    80003a1e:	c7c080e7          	jalr	-900(ra) # 80004696 <holdingsleep>
    80003a22:	cd19                	beqz	a0,80003a40 <iunlock+0x3c>
    80003a24:	449c                	lw	a5,8(s1)
    80003a26:	00f05d63          	blez	a5,80003a40 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a2a:	854a                	mv	a0,s2
    80003a2c:	00001097          	auipc	ra,0x1
    80003a30:	c26080e7          	jalr	-986(ra) # 80004652 <releasesleep>
}
    80003a34:	60e2                	ld	ra,24(sp)
    80003a36:	6442                	ld	s0,16(sp)
    80003a38:	64a2                	ld	s1,8(sp)
    80003a3a:	6902                	ld	s2,0(sp)
    80003a3c:	6105                	addi	sp,sp,32
    80003a3e:	8082                	ret
    panic("iunlock");
    80003a40:	00005517          	auipc	a0,0x5
    80003a44:	c2850513          	addi	a0,a0,-984 # 80008668 <syscalls+0x198>
    80003a48:	ffffd097          	auipc	ra,0xffffd
    80003a4c:	b00080e7          	jalr	-1280(ra) # 80000548 <panic>

0000000080003a50 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a50:	7179                	addi	sp,sp,-48
    80003a52:	f406                	sd	ra,40(sp)
    80003a54:	f022                	sd	s0,32(sp)
    80003a56:	ec26                	sd	s1,24(sp)
    80003a58:	e84a                	sd	s2,16(sp)
    80003a5a:	e44e                	sd	s3,8(sp)
    80003a5c:	e052                	sd	s4,0(sp)
    80003a5e:	1800                	addi	s0,sp,48
    80003a60:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a62:	05050493          	addi	s1,a0,80
    80003a66:	08050913          	addi	s2,a0,128
    80003a6a:	a021                	j	80003a72 <itrunc+0x22>
    80003a6c:	0491                	addi	s1,s1,4
    80003a6e:	01248d63          	beq	s1,s2,80003a88 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a72:	408c                	lw	a1,0(s1)
    80003a74:	dde5                	beqz	a1,80003a6c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a76:	0009a503          	lw	a0,0(s3)
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	90c080e7          	jalr	-1780(ra) # 80003386 <bfree>
      ip->addrs[i] = 0;
    80003a82:	0004a023          	sw	zero,0(s1)
    80003a86:	b7dd                	j	80003a6c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a88:	0809a583          	lw	a1,128(s3)
    80003a8c:	e185                	bnez	a1,80003aac <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a8e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a92:	854e                	mv	a0,s3
    80003a94:	00000097          	auipc	ra,0x0
    80003a98:	de4080e7          	jalr	-540(ra) # 80003878 <iupdate>
}
    80003a9c:	70a2                	ld	ra,40(sp)
    80003a9e:	7402                	ld	s0,32(sp)
    80003aa0:	64e2                	ld	s1,24(sp)
    80003aa2:	6942                	ld	s2,16(sp)
    80003aa4:	69a2                	ld	s3,8(sp)
    80003aa6:	6a02                	ld	s4,0(sp)
    80003aa8:	6145                	addi	sp,sp,48
    80003aaa:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003aac:	0009a503          	lw	a0,0(s3)
    80003ab0:	fffff097          	auipc	ra,0xfffff
    80003ab4:	690080e7          	jalr	1680(ra) # 80003140 <bread>
    80003ab8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003aba:	05850493          	addi	s1,a0,88
    80003abe:	45850913          	addi	s2,a0,1112
    80003ac2:	a811                	j	80003ad6 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003ac4:	0009a503          	lw	a0,0(s3)
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	8be080e7          	jalr	-1858(ra) # 80003386 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003ad0:	0491                	addi	s1,s1,4
    80003ad2:	01248563          	beq	s1,s2,80003adc <itrunc+0x8c>
      if(a[j])
    80003ad6:	408c                	lw	a1,0(s1)
    80003ad8:	dde5                	beqz	a1,80003ad0 <itrunc+0x80>
    80003ada:	b7ed                	j	80003ac4 <itrunc+0x74>
    brelse(bp);
    80003adc:	8552                	mv	a0,s4
    80003ade:	fffff097          	auipc	ra,0xfffff
    80003ae2:	792080e7          	jalr	1938(ra) # 80003270 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ae6:	0809a583          	lw	a1,128(s3)
    80003aea:	0009a503          	lw	a0,0(s3)
    80003aee:	00000097          	auipc	ra,0x0
    80003af2:	898080e7          	jalr	-1896(ra) # 80003386 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003af6:	0809a023          	sw	zero,128(s3)
    80003afa:	bf51                	j	80003a8e <itrunc+0x3e>

0000000080003afc <iput>:
{
    80003afc:	1101                	addi	sp,sp,-32
    80003afe:	ec06                	sd	ra,24(sp)
    80003b00:	e822                	sd	s0,16(sp)
    80003b02:	e426                	sd	s1,8(sp)
    80003b04:	e04a                	sd	s2,0(sp)
    80003b06:	1000                	addi	s0,sp,32
    80003b08:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b0a:	0001c517          	auipc	a0,0x1c
    80003b0e:	55650513          	addi	a0,a0,1366 # 80020060 <icache>
    80003b12:	ffffd097          	auipc	ra,0xffffd
    80003b16:	0fe080e7          	jalr	254(ra) # 80000c10 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b1a:	4498                	lw	a4,8(s1)
    80003b1c:	4785                	li	a5,1
    80003b1e:	02f70363          	beq	a4,a5,80003b44 <iput+0x48>
  ip->ref--;
    80003b22:	449c                	lw	a5,8(s1)
    80003b24:	37fd                	addiw	a5,a5,-1
    80003b26:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b28:	0001c517          	auipc	a0,0x1c
    80003b2c:	53850513          	addi	a0,a0,1336 # 80020060 <icache>
    80003b30:	ffffd097          	auipc	ra,0xffffd
    80003b34:	194080e7          	jalr	404(ra) # 80000cc4 <release>
}
    80003b38:	60e2                	ld	ra,24(sp)
    80003b3a:	6442                	ld	s0,16(sp)
    80003b3c:	64a2                	ld	s1,8(sp)
    80003b3e:	6902                	ld	s2,0(sp)
    80003b40:	6105                	addi	sp,sp,32
    80003b42:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b44:	40bc                	lw	a5,64(s1)
    80003b46:	dff1                	beqz	a5,80003b22 <iput+0x26>
    80003b48:	04a49783          	lh	a5,74(s1)
    80003b4c:	fbf9                	bnez	a5,80003b22 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b4e:	01048913          	addi	s2,s1,16
    80003b52:	854a                	mv	a0,s2
    80003b54:	00001097          	auipc	ra,0x1
    80003b58:	aa8080e7          	jalr	-1368(ra) # 800045fc <acquiresleep>
    release(&icache.lock);
    80003b5c:	0001c517          	auipc	a0,0x1c
    80003b60:	50450513          	addi	a0,a0,1284 # 80020060 <icache>
    80003b64:	ffffd097          	auipc	ra,0xffffd
    80003b68:	160080e7          	jalr	352(ra) # 80000cc4 <release>
    itrunc(ip);
    80003b6c:	8526                	mv	a0,s1
    80003b6e:	00000097          	auipc	ra,0x0
    80003b72:	ee2080e7          	jalr	-286(ra) # 80003a50 <itrunc>
    ip->type = 0;
    80003b76:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b7a:	8526                	mv	a0,s1
    80003b7c:	00000097          	auipc	ra,0x0
    80003b80:	cfc080e7          	jalr	-772(ra) # 80003878 <iupdate>
    ip->valid = 0;
    80003b84:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b88:	854a                	mv	a0,s2
    80003b8a:	00001097          	auipc	ra,0x1
    80003b8e:	ac8080e7          	jalr	-1336(ra) # 80004652 <releasesleep>
    acquire(&icache.lock);
    80003b92:	0001c517          	auipc	a0,0x1c
    80003b96:	4ce50513          	addi	a0,a0,1230 # 80020060 <icache>
    80003b9a:	ffffd097          	auipc	ra,0xffffd
    80003b9e:	076080e7          	jalr	118(ra) # 80000c10 <acquire>
    80003ba2:	b741                	j	80003b22 <iput+0x26>

0000000080003ba4 <iunlockput>:
{
    80003ba4:	1101                	addi	sp,sp,-32
    80003ba6:	ec06                	sd	ra,24(sp)
    80003ba8:	e822                	sd	s0,16(sp)
    80003baa:	e426                	sd	s1,8(sp)
    80003bac:	1000                	addi	s0,sp,32
    80003bae:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bb0:	00000097          	auipc	ra,0x0
    80003bb4:	e54080e7          	jalr	-428(ra) # 80003a04 <iunlock>
  iput(ip);
    80003bb8:	8526                	mv	a0,s1
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	f42080e7          	jalr	-190(ra) # 80003afc <iput>
}
    80003bc2:	60e2                	ld	ra,24(sp)
    80003bc4:	6442                	ld	s0,16(sp)
    80003bc6:	64a2                	ld	s1,8(sp)
    80003bc8:	6105                	addi	sp,sp,32
    80003bca:	8082                	ret

0000000080003bcc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bcc:	1141                	addi	sp,sp,-16
    80003bce:	e422                	sd	s0,8(sp)
    80003bd0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bd2:	411c                	lw	a5,0(a0)
    80003bd4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bd6:	415c                	lw	a5,4(a0)
    80003bd8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bda:	04451783          	lh	a5,68(a0)
    80003bde:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003be2:	04a51783          	lh	a5,74(a0)
    80003be6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bea:	04c56783          	lwu	a5,76(a0)
    80003bee:	e99c                	sd	a5,16(a1)
}
    80003bf0:	6422                	ld	s0,8(sp)
    80003bf2:	0141                	addi	sp,sp,16
    80003bf4:	8082                	ret

0000000080003bf6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bf6:	457c                	lw	a5,76(a0)
    80003bf8:	0ed7e863          	bltu	a5,a3,80003ce8 <readi+0xf2>
{
    80003bfc:	7159                	addi	sp,sp,-112
    80003bfe:	f486                	sd	ra,104(sp)
    80003c00:	f0a2                	sd	s0,96(sp)
    80003c02:	eca6                	sd	s1,88(sp)
    80003c04:	e8ca                	sd	s2,80(sp)
    80003c06:	e4ce                	sd	s3,72(sp)
    80003c08:	e0d2                	sd	s4,64(sp)
    80003c0a:	fc56                	sd	s5,56(sp)
    80003c0c:	f85a                	sd	s6,48(sp)
    80003c0e:	f45e                	sd	s7,40(sp)
    80003c10:	f062                	sd	s8,32(sp)
    80003c12:	ec66                	sd	s9,24(sp)
    80003c14:	e86a                	sd	s10,16(sp)
    80003c16:	e46e                	sd	s11,8(sp)
    80003c18:	1880                	addi	s0,sp,112
    80003c1a:	8baa                	mv	s7,a0
    80003c1c:	8c2e                	mv	s8,a1
    80003c1e:	8ab2                	mv	s5,a2
    80003c20:	84b6                	mv	s1,a3
    80003c22:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c24:	9f35                	addw	a4,a4,a3
    return 0;
    80003c26:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c28:	08d76f63          	bltu	a4,a3,80003cc6 <readi+0xd0>
  if(off + n > ip->size)
    80003c2c:	00e7f463          	bgeu	a5,a4,80003c34 <readi+0x3e>
    n = ip->size - off;
    80003c30:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c34:	0a0b0863          	beqz	s6,80003ce4 <readi+0xee>
    80003c38:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c3a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c3e:	5cfd                	li	s9,-1
    80003c40:	a82d                	j	80003c7a <readi+0x84>
    80003c42:	020a1d93          	slli	s11,s4,0x20
    80003c46:	020ddd93          	srli	s11,s11,0x20
    80003c4a:	05890613          	addi	a2,s2,88
    80003c4e:	86ee                	mv	a3,s11
    80003c50:	963a                	add	a2,a2,a4
    80003c52:	85d6                	mv	a1,s5
    80003c54:	8562                	mv	a0,s8
    80003c56:	fffff097          	auipc	ra,0xfffff
    80003c5a:	b2e080e7          	jalr	-1234(ra) # 80002784 <either_copyout>
    80003c5e:	05950d63          	beq	a0,s9,80003cb8 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003c62:	854a                	mv	a0,s2
    80003c64:	fffff097          	auipc	ra,0xfffff
    80003c68:	60c080e7          	jalr	1548(ra) # 80003270 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c6c:	013a09bb          	addw	s3,s4,s3
    80003c70:	009a04bb          	addw	s1,s4,s1
    80003c74:	9aee                	add	s5,s5,s11
    80003c76:	0569f663          	bgeu	s3,s6,80003cc2 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c7a:	000ba903          	lw	s2,0(s7)
    80003c7e:	00a4d59b          	srliw	a1,s1,0xa
    80003c82:	855e                	mv	a0,s7
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	8b0080e7          	jalr	-1872(ra) # 80003534 <bmap>
    80003c8c:	0005059b          	sext.w	a1,a0
    80003c90:	854a                	mv	a0,s2
    80003c92:	fffff097          	auipc	ra,0xfffff
    80003c96:	4ae080e7          	jalr	1198(ra) # 80003140 <bread>
    80003c9a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c9c:	3ff4f713          	andi	a4,s1,1023
    80003ca0:	40ed07bb          	subw	a5,s10,a4
    80003ca4:	413b06bb          	subw	a3,s6,s3
    80003ca8:	8a3e                	mv	s4,a5
    80003caa:	2781                	sext.w	a5,a5
    80003cac:	0006861b          	sext.w	a2,a3
    80003cb0:	f8f679e3          	bgeu	a2,a5,80003c42 <readi+0x4c>
    80003cb4:	8a36                	mv	s4,a3
    80003cb6:	b771                	j	80003c42 <readi+0x4c>
      brelse(bp);
    80003cb8:	854a                	mv	a0,s2
    80003cba:	fffff097          	auipc	ra,0xfffff
    80003cbe:	5b6080e7          	jalr	1462(ra) # 80003270 <brelse>
  }
  return tot;
    80003cc2:	0009851b          	sext.w	a0,s3
}
    80003cc6:	70a6                	ld	ra,104(sp)
    80003cc8:	7406                	ld	s0,96(sp)
    80003cca:	64e6                	ld	s1,88(sp)
    80003ccc:	6946                	ld	s2,80(sp)
    80003cce:	69a6                	ld	s3,72(sp)
    80003cd0:	6a06                	ld	s4,64(sp)
    80003cd2:	7ae2                	ld	s5,56(sp)
    80003cd4:	7b42                	ld	s6,48(sp)
    80003cd6:	7ba2                	ld	s7,40(sp)
    80003cd8:	7c02                	ld	s8,32(sp)
    80003cda:	6ce2                	ld	s9,24(sp)
    80003cdc:	6d42                	ld	s10,16(sp)
    80003cde:	6da2                	ld	s11,8(sp)
    80003ce0:	6165                	addi	sp,sp,112
    80003ce2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ce4:	89da                	mv	s3,s6
    80003ce6:	bff1                	j	80003cc2 <readi+0xcc>
    return 0;
    80003ce8:	4501                	li	a0,0
}
    80003cea:	8082                	ret

0000000080003cec <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cec:	457c                	lw	a5,76(a0)
    80003cee:	10d7e663          	bltu	a5,a3,80003dfa <writei+0x10e>
{
    80003cf2:	7159                	addi	sp,sp,-112
    80003cf4:	f486                	sd	ra,104(sp)
    80003cf6:	f0a2                	sd	s0,96(sp)
    80003cf8:	eca6                	sd	s1,88(sp)
    80003cfa:	e8ca                	sd	s2,80(sp)
    80003cfc:	e4ce                	sd	s3,72(sp)
    80003cfe:	e0d2                	sd	s4,64(sp)
    80003d00:	fc56                	sd	s5,56(sp)
    80003d02:	f85a                	sd	s6,48(sp)
    80003d04:	f45e                	sd	s7,40(sp)
    80003d06:	f062                	sd	s8,32(sp)
    80003d08:	ec66                	sd	s9,24(sp)
    80003d0a:	e86a                	sd	s10,16(sp)
    80003d0c:	e46e                	sd	s11,8(sp)
    80003d0e:	1880                	addi	s0,sp,112
    80003d10:	8baa                	mv	s7,a0
    80003d12:	8c2e                	mv	s8,a1
    80003d14:	8ab2                	mv	s5,a2
    80003d16:	8936                	mv	s2,a3
    80003d18:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d1a:	00e687bb          	addw	a5,a3,a4
    80003d1e:	0ed7e063          	bltu	a5,a3,80003dfe <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d22:	00043737          	lui	a4,0x43
    80003d26:	0cf76e63          	bltu	a4,a5,80003e02 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d2a:	0a0b0763          	beqz	s6,80003dd8 <writei+0xec>
    80003d2e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d30:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d34:	5cfd                	li	s9,-1
    80003d36:	a091                	j	80003d7a <writei+0x8e>
    80003d38:	02099d93          	slli	s11,s3,0x20
    80003d3c:	020ddd93          	srli	s11,s11,0x20
    80003d40:	05848513          	addi	a0,s1,88
    80003d44:	86ee                	mv	a3,s11
    80003d46:	8656                	mv	a2,s5
    80003d48:	85e2                	mv	a1,s8
    80003d4a:	953a                	add	a0,a0,a4
    80003d4c:	fffff097          	auipc	ra,0xfffff
    80003d50:	a8e080e7          	jalr	-1394(ra) # 800027da <either_copyin>
    80003d54:	07950263          	beq	a0,s9,80003db8 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d58:	8526                	mv	a0,s1
    80003d5a:	00000097          	auipc	ra,0x0
    80003d5e:	77a080e7          	jalr	1914(ra) # 800044d4 <log_write>
    brelse(bp);
    80003d62:	8526                	mv	a0,s1
    80003d64:	fffff097          	auipc	ra,0xfffff
    80003d68:	50c080e7          	jalr	1292(ra) # 80003270 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d6c:	01498a3b          	addw	s4,s3,s4
    80003d70:	0129893b          	addw	s2,s3,s2
    80003d74:	9aee                	add	s5,s5,s11
    80003d76:	056a7663          	bgeu	s4,s6,80003dc2 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d7a:	000ba483          	lw	s1,0(s7)
    80003d7e:	00a9559b          	srliw	a1,s2,0xa
    80003d82:	855e                	mv	a0,s7
    80003d84:	fffff097          	auipc	ra,0xfffff
    80003d88:	7b0080e7          	jalr	1968(ra) # 80003534 <bmap>
    80003d8c:	0005059b          	sext.w	a1,a0
    80003d90:	8526                	mv	a0,s1
    80003d92:	fffff097          	auipc	ra,0xfffff
    80003d96:	3ae080e7          	jalr	942(ra) # 80003140 <bread>
    80003d9a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d9c:	3ff97713          	andi	a4,s2,1023
    80003da0:	40ed07bb          	subw	a5,s10,a4
    80003da4:	414b06bb          	subw	a3,s6,s4
    80003da8:	89be                	mv	s3,a5
    80003daa:	2781                	sext.w	a5,a5
    80003dac:	0006861b          	sext.w	a2,a3
    80003db0:	f8f674e3          	bgeu	a2,a5,80003d38 <writei+0x4c>
    80003db4:	89b6                	mv	s3,a3
    80003db6:	b749                	j	80003d38 <writei+0x4c>
      brelse(bp);
    80003db8:	8526                	mv	a0,s1
    80003dba:	fffff097          	auipc	ra,0xfffff
    80003dbe:	4b6080e7          	jalr	1206(ra) # 80003270 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003dc2:	04cba783          	lw	a5,76(s7)
    80003dc6:	0127f463          	bgeu	a5,s2,80003dce <writei+0xe2>
      ip->size = off;
    80003dca:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003dce:	855e                	mv	a0,s7
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	aa8080e7          	jalr	-1368(ra) # 80003878 <iupdate>
  }

  return n;
    80003dd8:	000b051b          	sext.w	a0,s6
}
    80003ddc:	70a6                	ld	ra,104(sp)
    80003dde:	7406                	ld	s0,96(sp)
    80003de0:	64e6                	ld	s1,88(sp)
    80003de2:	6946                	ld	s2,80(sp)
    80003de4:	69a6                	ld	s3,72(sp)
    80003de6:	6a06                	ld	s4,64(sp)
    80003de8:	7ae2                	ld	s5,56(sp)
    80003dea:	7b42                	ld	s6,48(sp)
    80003dec:	7ba2                	ld	s7,40(sp)
    80003dee:	7c02                	ld	s8,32(sp)
    80003df0:	6ce2                	ld	s9,24(sp)
    80003df2:	6d42                	ld	s10,16(sp)
    80003df4:	6da2                	ld	s11,8(sp)
    80003df6:	6165                	addi	sp,sp,112
    80003df8:	8082                	ret
    return -1;
    80003dfa:	557d                	li	a0,-1
}
    80003dfc:	8082                	ret
    return -1;
    80003dfe:	557d                	li	a0,-1
    80003e00:	bff1                	j	80003ddc <writei+0xf0>
    return -1;
    80003e02:	557d                	li	a0,-1
    80003e04:	bfe1                	j	80003ddc <writei+0xf0>

0000000080003e06 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e06:	1141                	addi	sp,sp,-16
    80003e08:	e406                	sd	ra,8(sp)
    80003e0a:	e022                	sd	s0,0(sp)
    80003e0c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e0e:	4639                	li	a2,14
    80003e10:	ffffd097          	auipc	ra,0xffffd
    80003e14:	fd8080e7          	jalr	-40(ra) # 80000de8 <strncmp>
}
    80003e18:	60a2                	ld	ra,8(sp)
    80003e1a:	6402                	ld	s0,0(sp)
    80003e1c:	0141                	addi	sp,sp,16
    80003e1e:	8082                	ret

0000000080003e20 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e20:	7139                	addi	sp,sp,-64
    80003e22:	fc06                	sd	ra,56(sp)
    80003e24:	f822                	sd	s0,48(sp)
    80003e26:	f426                	sd	s1,40(sp)
    80003e28:	f04a                	sd	s2,32(sp)
    80003e2a:	ec4e                	sd	s3,24(sp)
    80003e2c:	e852                	sd	s4,16(sp)
    80003e2e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e30:	04451703          	lh	a4,68(a0)
    80003e34:	4785                	li	a5,1
    80003e36:	00f71a63          	bne	a4,a5,80003e4a <dirlookup+0x2a>
    80003e3a:	892a                	mv	s2,a0
    80003e3c:	89ae                	mv	s3,a1
    80003e3e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e40:	457c                	lw	a5,76(a0)
    80003e42:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e44:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e46:	e79d                	bnez	a5,80003e74 <dirlookup+0x54>
    80003e48:	a8a5                	j	80003ec0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e4a:	00005517          	auipc	a0,0x5
    80003e4e:	82650513          	addi	a0,a0,-2010 # 80008670 <syscalls+0x1a0>
    80003e52:	ffffc097          	auipc	ra,0xffffc
    80003e56:	6f6080e7          	jalr	1782(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003e5a:	00005517          	auipc	a0,0x5
    80003e5e:	82e50513          	addi	a0,a0,-2002 # 80008688 <syscalls+0x1b8>
    80003e62:	ffffc097          	auipc	ra,0xffffc
    80003e66:	6e6080e7          	jalr	1766(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e6a:	24c1                	addiw	s1,s1,16
    80003e6c:	04c92783          	lw	a5,76(s2)
    80003e70:	04f4f763          	bgeu	s1,a5,80003ebe <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e74:	4741                	li	a4,16
    80003e76:	86a6                	mv	a3,s1
    80003e78:	fc040613          	addi	a2,s0,-64
    80003e7c:	4581                	li	a1,0
    80003e7e:	854a                	mv	a0,s2
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	d76080e7          	jalr	-650(ra) # 80003bf6 <readi>
    80003e88:	47c1                	li	a5,16
    80003e8a:	fcf518e3          	bne	a0,a5,80003e5a <dirlookup+0x3a>
    if(de.inum == 0)
    80003e8e:	fc045783          	lhu	a5,-64(s0)
    80003e92:	dfe1                	beqz	a5,80003e6a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e94:	fc240593          	addi	a1,s0,-62
    80003e98:	854e                	mv	a0,s3
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	f6c080e7          	jalr	-148(ra) # 80003e06 <namecmp>
    80003ea2:	f561                	bnez	a0,80003e6a <dirlookup+0x4a>
      if(poff)
    80003ea4:	000a0463          	beqz	s4,80003eac <dirlookup+0x8c>
        *poff = off;
    80003ea8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003eac:	fc045583          	lhu	a1,-64(s0)
    80003eb0:	00092503          	lw	a0,0(s2)
    80003eb4:	fffff097          	auipc	ra,0xfffff
    80003eb8:	75a080e7          	jalr	1882(ra) # 8000360e <iget>
    80003ebc:	a011                	j	80003ec0 <dirlookup+0xa0>
  return 0;
    80003ebe:	4501                	li	a0,0
}
    80003ec0:	70e2                	ld	ra,56(sp)
    80003ec2:	7442                	ld	s0,48(sp)
    80003ec4:	74a2                	ld	s1,40(sp)
    80003ec6:	7902                	ld	s2,32(sp)
    80003ec8:	69e2                	ld	s3,24(sp)
    80003eca:	6a42                	ld	s4,16(sp)
    80003ecc:	6121                	addi	sp,sp,64
    80003ece:	8082                	ret

0000000080003ed0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ed0:	711d                	addi	sp,sp,-96
    80003ed2:	ec86                	sd	ra,88(sp)
    80003ed4:	e8a2                	sd	s0,80(sp)
    80003ed6:	e4a6                	sd	s1,72(sp)
    80003ed8:	e0ca                	sd	s2,64(sp)
    80003eda:	fc4e                	sd	s3,56(sp)
    80003edc:	f852                	sd	s4,48(sp)
    80003ede:	f456                	sd	s5,40(sp)
    80003ee0:	f05a                	sd	s6,32(sp)
    80003ee2:	ec5e                	sd	s7,24(sp)
    80003ee4:	e862                	sd	s8,16(sp)
    80003ee6:	e466                	sd	s9,8(sp)
    80003ee8:	1080                	addi	s0,sp,96
    80003eea:	84aa                	mv	s1,a0
    80003eec:	8b2e                	mv	s6,a1
    80003eee:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ef0:	00054703          	lbu	a4,0(a0)
    80003ef4:	02f00793          	li	a5,47
    80003ef8:	02f70363          	beq	a4,a5,80003f1e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003efc:	ffffe097          	auipc	ra,0xffffe
    80003f00:	c16080e7          	jalr	-1002(ra) # 80001b12 <myproc>
    80003f04:	15053503          	ld	a0,336(a0)
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	9fc080e7          	jalr	-1540(ra) # 80003904 <idup>
    80003f10:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f12:	02f00913          	li	s2,47
  len = path - s;
    80003f16:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003f18:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f1a:	4c05                	li	s8,1
    80003f1c:	a865                	j	80003fd4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f1e:	4585                	li	a1,1
    80003f20:	4505                	li	a0,1
    80003f22:	fffff097          	auipc	ra,0xfffff
    80003f26:	6ec080e7          	jalr	1772(ra) # 8000360e <iget>
    80003f2a:	89aa                	mv	s3,a0
    80003f2c:	b7dd                	j	80003f12 <namex+0x42>
      iunlockput(ip);
    80003f2e:	854e                	mv	a0,s3
    80003f30:	00000097          	auipc	ra,0x0
    80003f34:	c74080e7          	jalr	-908(ra) # 80003ba4 <iunlockput>
      return 0;
    80003f38:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f3a:	854e                	mv	a0,s3
    80003f3c:	60e6                	ld	ra,88(sp)
    80003f3e:	6446                	ld	s0,80(sp)
    80003f40:	64a6                	ld	s1,72(sp)
    80003f42:	6906                	ld	s2,64(sp)
    80003f44:	79e2                	ld	s3,56(sp)
    80003f46:	7a42                	ld	s4,48(sp)
    80003f48:	7aa2                	ld	s5,40(sp)
    80003f4a:	7b02                	ld	s6,32(sp)
    80003f4c:	6be2                	ld	s7,24(sp)
    80003f4e:	6c42                	ld	s8,16(sp)
    80003f50:	6ca2                	ld	s9,8(sp)
    80003f52:	6125                	addi	sp,sp,96
    80003f54:	8082                	ret
      iunlock(ip);
    80003f56:	854e                	mv	a0,s3
    80003f58:	00000097          	auipc	ra,0x0
    80003f5c:	aac080e7          	jalr	-1364(ra) # 80003a04 <iunlock>
      return ip;
    80003f60:	bfe9                	j	80003f3a <namex+0x6a>
      iunlockput(ip);
    80003f62:	854e                	mv	a0,s3
    80003f64:	00000097          	auipc	ra,0x0
    80003f68:	c40080e7          	jalr	-960(ra) # 80003ba4 <iunlockput>
      return 0;
    80003f6c:	89d2                	mv	s3,s4
    80003f6e:	b7f1                	j	80003f3a <namex+0x6a>
  len = path - s;
    80003f70:	40b48633          	sub	a2,s1,a1
    80003f74:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f78:	094cd463          	bge	s9,s4,80004000 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f7c:	4639                	li	a2,14
    80003f7e:	8556                	mv	a0,s5
    80003f80:	ffffd097          	auipc	ra,0xffffd
    80003f84:	dec080e7          	jalr	-532(ra) # 80000d6c <memmove>
  while(*path == '/')
    80003f88:	0004c783          	lbu	a5,0(s1)
    80003f8c:	01279763          	bne	a5,s2,80003f9a <namex+0xca>
    path++;
    80003f90:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f92:	0004c783          	lbu	a5,0(s1)
    80003f96:	ff278de3          	beq	a5,s2,80003f90 <namex+0xc0>
    ilock(ip);
    80003f9a:	854e                	mv	a0,s3
    80003f9c:	00000097          	auipc	ra,0x0
    80003fa0:	9a6080e7          	jalr	-1626(ra) # 80003942 <ilock>
    if(ip->type != T_DIR){
    80003fa4:	04499783          	lh	a5,68(s3)
    80003fa8:	f98793e3          	bne	a5,s8,80003f2e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003fac:	000b0563          	beqz	s6,80003fb6 <namex+0xe6>
    80003fb0:	0004c783          	lbu	a5,0(s1)
    80003fb4:	d3cd                	beqz	a5,80003f56 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fb6:	865e                	mv	a2,s7
    80003fb8:	85d6                	mv	a1,s5
    80003fba:	854e                	mv	a0,s3
    80003fbc:	00000097          	auipc	ra,0x0
    80003fc0:	e64080e7          	jalr	-412(ra) # 80003e20 <dirlookup>
    80003fc4:	8a2a                	mv	s4,a0
    80003fc6:	dd51                	beqz	a0,80003f62 <namex+0x92>
    iunlockput(ip);
    80003fc8:	854e                	mv	a0,s3
    80003fca:	00000097          	auipc	ra,0x0
    80003fce:	bda080e7          	jalr	-1062(ra) # 80003ba4 <iunlockput>
    ip = next;
    80003fd2:	89d2                	mv	s3,s4
  while(*path == '/')
    80003fd4:	0004c783          	lbu	a5,0(s1)
    80003fd8:	05279763          	bne	a5,s2,80004026 <namex+0x156>
    path++;
    80003fdc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fde:	0004c783          	lbu	a5,0(s1)
    80003fe2:	ff278de3          	beq	a5,s2,80003fdc <namex+0x10c>
  if(*path == 0)
    80003fe6:	c79d                	beqz	a5,80004014 <namex+0x144>
    path++;
    80003fe8:	85a6                	mv	a1,s1
  len = path - s;
    80003fea:	8a5e                	mv	s4,s7
    80003fec:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fee:	01278963          	beq	a5,s2,80004000 <namex+0x130>
    80003ff2:	dfbd                	beqz	a5,80003f70 <namex+0xa0>
    path++;
    80003ff4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003ff6:	0004c783          	lbu	a5,0(s1)
    80003ffa:	ff279ce3          	bne	a5,s2,80003ff2 <namex+0x122>
    80003ffe:	bf8d                	j	80003f70 <namex+0xa0>
    memmove(name, s, len);
    80004000:	2601                	sext.w	a2,a2
    80004002:	8556                	mv	a0,s5
    80004004:	ffffd097          	auipc	ra,0xffffd
    80004008:	d68080e7          	jalr	-664(ra) # 80000d6c <memmove>
    name[len] = 0;
    8000400c:	9a56                	add	s4,s4,s5
    8000400e:	000a0023          	sb	zero,0(s4)
    80004012:	bf9d                	j	80003f88 <namex+0xb8>
  if(nameiparent){
    80004014:	f20b03e3          	beqz	s6,80003f3a <namex+0x6a>
    iput(ip);
    80004018:	854e                	mv	a0,s3
    8000401a:	00000097          	auipc	ra,0x0
    8000401e:	ae2080e7          	jalr	-1310(ra) # 80003afc <iput>
    return 0;
    80004022:	4981                	li	s3,0
    80004024:	bf19                	j	80003f3a <namex+0x6a>
  if(*path == 0)
    80004026:	d7fd                	beqz	a5,80004014 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004028:	0004c783          	lbu	a5,0(s1)
    8000402c:	85a6                	mv	a1,s1
    8000402e:	b7d1                	j	80003ff2 <namex+0x122>

0000000080004030 <dirlink>:
{
    80004030:	7139                	addi	sp,sp,-64
    80004032:	fc06                	sd	ra,56(sp)
    80004034:	f822                	sd	s0,48(sp)
    80004036:	f426                	sd	s1,40(sp)
    80004038:	f04a                	sd	s2,32(sp)
    8000403a:	ec4e                	sd	s3,24(sp)
    8000403c:	e852                	sd	s4,16(sp)
    8000403e:	0080                	addi	s0,sp,64
    80004040:	892a                	mv	s2,a0
    80004042:	8a2e                	mv	s4,a1
    80004044:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004046:	4601                	li	a2,0
    80004048:	00000097          	auipc	ra,0x0
    8000404c:	dd8080e7          	jalr	-552(ra) # 80003e20 <dirlookup>
    80004050:	e93d                	bnez	a0,800040c6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004052:	04c92483          	lw	s1,76(s2)
    80004056:	c49d                	beqz	s1,80004084 <dirlink+0x54>
    80004058:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000405a:	4741                	li	a4,16
    8000405c:	86a6                	mv	a3,s1
    8000405e:	fc040613          	addi	a2,s0,-64
    80004062:	4581                	li	a1,0
    80004064:	854a                	mv	a0,s2
    80004066:	00000097          	auipc	ra,0x0
    8000406a:	b90080e7          	jalr	-1136(ra) # 80003bf6 <readi>
    8000406e:	47c1                	li	a5,16
    80004070:	06f51163          	bne	a0,a5,800040d2 <dirlink+0xa2>
    if(de.inum == 0)
    80004074:	fc045783          	lhu	a5,-64(s0)
    80004078:	c791                	beqz	a5,80004084 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000407a:	24c1                	addiw	s1,s1,16
    8000407c:	04c92783          	lw	a5,76(s2)
    80004080:	fcf4ede3          	bltu	s1,a5,8000405a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004084:	4639                	li	a2,14
    80004086:	85d2                	mv	a1,s4
    80004088:	fc240513          	addi	a0,s0,-62
    8000408c:	ffffd097          	auipc	ra,0xffffd
    80004090:	d98080e7          	jalr	-616(ra) # 80000e24 <strncpy>
  de.inum = inum;
    80004094:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004098:	4741                	li	a4,16
    8000409a:	86a6                	mv	a3,s1
    8000409c:	fc040613          	addi	a2,s0,-64
    800040a0:	4581                	li	a1,0
    800040a2:	854a                	mv	a0,s2
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	c48080e7          	jalr	-952(ra) # 80003cec <writei>
    800040ac:	872a                	mv	a4,a0
    800040ae:	47c1                	li	a5,16
  return 0;
    800040b0:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040b2:	02f71863          	bne	a4,a5,800040e2 <dirlink+0xb2>
}
    800040b6:	70e2                	ld	ra,56(sp)
    800040b8:	7442                	ld	s0,48(sp)
    800040ba:	74a2                	ld	s1,40(sp)
    800040bc:	7902                	ld	s2,32(sp)
    800040be:	69e2                	ld	s3,24(sp)
    800040c0:	6a42                	ld	s4,16(sp)
    800040c2:	6121                	addi	sp,sp,64
    800040c4:	8082                	ret
    iput(ip);
    800040c6:	00000097          	auipc	ra,0x0
    800040ca:	a36080e7          	jalr	-1482(ra) # 80003afc <iput>
    return -1;
    800040ce:	557d                	li	a0,-1
    800040d0:	b7dd                	j	800040b6 <dirlink+0x86>
      panic("dirlink read");
    800040d2:	00004517          	auipc	a0,0x4
    800040d6:	5c650513          	addi	a0,a0,1478 # 80008698 <syscalls+0x1c8>
    800040da:	ffffc097          	auipc	ra,0xffffc
    800040de:	46e080e7          	jalr	1134(ra) # 80000548 <panic>
    panic("dirlink");
    800040e2:	00004517          	auipc	a0,0x4
    800040e6:	6d650513          	addi	a0,a0,1750 # 800087b8 <syscalls+0x2e8>
    800040ea:	ffffc097          	auipc	ra,0xffffc
    800040ee:	45e080e7          	jalr	1118(ra) # 80000548 <panic>

00000000800040f2 <namei>:

struct inode*
namei(char *path)
{
    800040f2:	1101                	addi	sp,sp,-32
    800040f4:	ec06                	sd	ra,24(sp)
    800040f6:	e822                	sd	s0,16(sp)
    800040f8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040fa:	fe040613          	addi	a2,s0,-32
    800040fe:	4581                	li	a1,0
    80004100:	00000097          	auipc	ra,0x0
    80004104:	dd0080e7          	jalr	-560(ra) # 80003ed0 <namex>
}
    80004108:	60e2                	ld	ra,24(sp)
    8000410a:	6442                	ld	s0,16(sp)
    8000410c:	6105                	addi	sp,sp,32
    8000410e:	8082                	ret

0000000080004110 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004110:	1141                	addi	sp,sp,-16
    80004112:	e406                	sd	ra,8(sp)
    80004114:	e022                	sd	s0,0(sp)
    80004116:	0800                	addi	s0,sp,16
    80004118:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000411a:	4585                	li	a1,1
    8000411c:	00000097          	auipc	ra,0x0
    80004120:	db4080e7          	jalr	-588(ra) # 80003ed0 <namex>
}
    80004124:	60a2                	ld	ra,8(sp)
    80004126:	6402                	ld	s0,0(sp)
    80004128:	0141                	addi	sp,sp,16
    8000412a:	8082                	ret

000000008000412c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000412c:	1101                	addi	sp,sp,-32
    8000412e:	ec06                	sd	ra,24(sp)
    80004130:	e822                	sd	s0,16(sp)
    80004132:	e426                	sd	s1,8(sp)
    80004134:	e04a                	sd	s2,0(sp)
    80004136:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004138:	0001e917          	auipc	s2,0x1e
    8000413c:	9d090913          	addi	s2,s2,-1584 # 80021b08 <log>
    80004140:	01892583          	lw	a1,24(s2)
    80004144:	02892503          	lw	a0,40(s2)
    80004148:	fffff097          	auipc	ra,0xfffff
    8000414c:	ff8080e7          	jalr	-8(ra) # 80003140 <bread>
    80004150:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004152:	02c92683          	lw	a3,44(s2)
    80004156:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004158:	02d05763          	blez	a3,80004186 <write_head+0x5a>
    8000415c:	0001e797          	auipc	a5,0x1e
    80004160:	9dc78793          	addi	a5,a5,-1572 # 80021b38 <log+0x30>
    80004164:	05c50713          	addi	a4,a0,92
    80004168:	36fd                	addiw	a3,a3,-1
    8000416a:	1682                	slli	a3,a3,0x20
    8000416c:	9281                	srli	a3,a3,0x20
    8000416e:	068a                	slli	a3,a3,0x2
    80004170:	0001e617          	auipc	a2,0x1e
    80004174:	9cc60613          	addi	a2,a2,-1588 # 80021b3c <log+0x34>
    80004178:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000417a:	4390                	lw	a2,0(a5)
    8000417c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000417e:	0791                	addi	a5,a5,4
    80004180:	0711                	addi	a4,a4,4
    80004182:	fed79ce3          	bne	a5,a3,8000417a <write_head+0x4e>
  }
  bwrite(buf);
    80004186:	8526                	mv	a0,s1
    80004188:	fffff097          	auipc	ra,0xfffff
    8000418c:	0aa080e7          	jalr	170(ra) # 80003232 <bwrite>
  brelse(buf);
    80004190:	8526                	mv	a0,s1
    80004192:	fffff097          	auipc	ra,0xfffff
    80004196:	0de080e7          	jalr	222(ra) # 80003270 <brelse>
}
    8000419a:	60e2                	ld	ra,24(sp)
    8000419c:	6442                	ld	s0,16(sp)
    8000419e:	64a2                	ld	s1,8(sp)
    800041a0:	6902                	ld	s2,0(sp)
    800041a2:	6105                	addi	sp,sp,32
    800041a4:	8082                	ret

00000000800041a6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a6:	0001e797          	auipc	a5,0x1e
    800041aa:	98e7a783          	lw	a5,-1650(a5) # 80021b34 <log+0x2c>
    800041ae:	0af05663          	blez	a5,8000425a <install_trans+0xb4>
{
    800041b2:	7139                	addi	sp,sp,-64
    800041b4:	fc06                	sd	ra,56(sp)
    800041b6:	f822                	sd	s0,48(sp)
    800041b8:	f426                	sd	s1,40(sp)
    800041ba:	f04a                	sd	s2,32(sp)
    800041bc:	ec4e                	sd	s3,24(sp)
    800041be:	e852                	sd	s4,16(sp)
    800041c0:	e456                	sd	s5,8(sp)
    800041c2:	0080                	addi	s0,sp,64
    800041c4:	0001ea97          	auipc	s5,0x1e
    800041c8:	974a8a93          	addi	s5,s5,-1676 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041cc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041ce:	0001e997          	auipc	s3,0x1e
    800041d2:	93a98993          	addi	s3,s3,-1734 # 80021b08 <log>
    800041d6:	0189a583          	lw	a1,24(s3)
    800041da:	014585bb          	addw	a1,a1,s4
    800041de:	2585                	addiw	a1,a1,1
    800041e0:	0289a503          	lw	a0,40(s3)
    800041e4:	fffff097          	auipc	ra,0xfffff
    800041e8:	f5c080e7          	jalr	-164(ra) # 80003140 <bread>
    800041ec:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041ee:	000aa583          	lw	a1,0(s5)
    800041f2:	0289a503          	lw	a0,40(s3)
    800041f6:	fffff097          	auipc	ra,0xfffff
    800041fa:	f4a080e7          	jalr	-182(ra) # 80003140 <bread>
    800041fe:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004200:	40000613          	li	a2,1024
    80004204:	05890593          	addi	a1,s2,88
    80004208:	05850513          	addi	a0,a0,88
    8000420c:	ffffd097          	auipc	ra,0xffffd
    80004210:	b60080e7          	jalr	-1184(ra) # 80000d6c <memmove>
    bwrite(dbuf);  // write dst to disk
    80004214:	8526                	mv	a0,s1
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	01c080e7          	jalr	28(ra) # 80003232 <bwrite>
    bunpin(dbuf);
    8000421e:	8526                	mv	a0,s1
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	12a080e7          	jalr	298(ra) # 8000334a <bunpin>
    brelse(lbuf);
    80004228:	854a                	mv	a0,s2
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	046080e7          	jalr	70(ra) # 80003270 <brelse>
    brelse(dbuf);
    80004232:	8526                	mv	a0,s1
    80004234:	fffff097          	auipc	ra,0xfffff
    80004238:	03c080e7          	jalr	60(ra) # 80003270 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000423c:	2a05                	addiw	s4,s4,1
    8000423e:	0a91                	addi	s5,s5,4
    80004240:	02c9a783          	lw	a5,44(s3)
    80004244:	f8fa49e3          	blt	s4,a5,800041d6 <install_trans+0x30>
}
    80004248:	70e2                	ld	ra,56(sp)
    8000424a:	7442                	ld	s0,48(sp)
    8000424c:	74a2                	ld	s1,40(sp)
    8000424e:	7902                	ld	s2,32(sp)
    80004250:	69e2                	ld	s3,24(sp)
    80004252:	6a42                	ld	s4,16(sp)
    80004254:	6aa2                	ld	s5,8(sp)
    80004256:	6121                	addi	sp,sp,64
    80004258:	8082                	ret
    8000425a:	8082                	ret

000000008000425c <initlog>:
{
    8000425c:	7179                	addi	sp,sp,-48
    8000425e:	f406                	sd	ra,40(sp)
    80004260:	f022                	sd	s0,32(sp)
    80004262:	ec26                	sd	s1,24(sp)
    80004264:	e84a                	sd	s2,16(sp)
    80004266:	e44e                	sd	s3,8(sp)
    80004268:	1800                	addi	s0,sp,48
    8000426a:	892a                	mv	s2,a0
    8000426c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000426e:	0001e497          	auipc	s1,0x1e
    80004272:	89a48493          	addi	s1,s1,-1894 # 80021b08 <log>
    80004276:	00004597          	auipc	a1,0x4
    8000427a:	43258593          	addi	a1,a1,1074 # 800086a8 <syscalls+0x1d8>
    8000427e:	8526                	mv	a0,s1
    80004280:	ffffd097          	auipc	ra,0xffffd
    80004284:	900080e7          	jalr	-1792(ra) # 80000b80 <initlock>
  log.start = sb->logstart;
    80004288:	0149a583          	lw	a1,20(s3)
    8000428c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000428e:	0109a783          	lw	a5,16(s3)
    80004292:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004294:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004298:	854a                	mv	a0,s2
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	ea6080e7          	jalr	-346(ra) # 80003140 <bread>
  log.lh.n = lh->n;
    800042a2:	4d3c                	lw	a5,88(a0)
    800042a4:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042a6:	02f05563          	blez	a5,800042d0 <initlog+0x74>
    800042aa:	05c50713          	addi	a4,a0,92
    800042ae:	0001e697          	auipc	a3,0x1e
    800042b2:	88a68693          	addi	a3,a3,-1910 # 80021b38 <log+0x30>
    800042b6:	37fd                	addiw	a5,a5,-1
    800042b8:	1782                	slli	a5,a5,0x20
    800042ba:	9381                	srli	a5,a5,0x20
    800042bc:	078a                	slli	a5,a5,0x2
    800042be:	06050613          	addi	a2,a0,96
    800042c2:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800042c4:	4310                	lw	a2,0(a4)
    800042c6:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800042c8:	0711                	addi	a4,a4,4
    800042ca:	0691                	addi	a3,a3,4
    800042cc:	fef71ce3          	bne	a4,a5,800042c4 <initlog+0x68>
  brelse(buf);
    800042d0:	fffff097          	auipc	ra,0xfffff
    800042d4:	fa0080e7          	jalr	-96(ra) # 80003270 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800042d8:	00000097          	auipc	ra,0x0
    800042dc:	ece080e7          	jalr	-306(ra) # 800041a6 <install_trans>
  log.lh.n = 0;
    800042e0:	0001e797          	auipc	a5,0x1e
    800042e4:	8407aa23          	sw	zero,-1964(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    800042e8:	00000097          	auipc	ra,0x0
    800042ec:	e44080e7          	jalr	-444(ra) # 8000412c <write_head>
}
    800042f0:	70a2                	ld	ra,40(sp)
    800042f2:	7402                	ld	s0,32(sp)
    800042f4:	64e2                	ld	s1,24(sp)
    800042f6:	6942                	ld	s2,16(sp)
    800042f8:	69a2                	ld	s3,8(sp)
    800042fa:	6145                	addi	sp,sp,48
    800042fc:	8082                	ret

00000000800042fe <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042fe:	1101                	addi	sp,sp,-32
    80004300:	ec06                	sd	ra,24(sp)
    80004302:	e822                	sd	s0,16(sp)
    80004304:	e426                	sd	s1,8(sp)
    80004306:	e04a                	sd	s2,0(sp)
    80004308:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000430a:	0001d517          	auipc	a0,0x1d
    8000430e:	7fe50513          	addi	a0,a0,2046 # 80021b08 <log>
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	8fe080e7          	jalr	-1794(ra) # 80000c10 <acquire>
  while(1){
    if(log.committing){
    8000431a:	0001d497          	auipc	s1,0x1d
    8000431e:	7ee48493          	addi	s1,s1,2030 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004322:	4979                	li	s2,30
    80004324:	a039                	j	80004332 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004326:	85a6                	mv	a1,s1
    80004328:	8526                	mv	a0,s1
    8000432a:	ffffe097          	auipc	ra,0xffffe
    8000432e:	1f8080e7          	jalr	504(ra) # 80002522 <sleep>
    if(log.committing){
    80004332:	50dc                	lw	a5,36(s1)
    80004334:	fbed                	bnez	a5,80004326 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004336:	509c                	lw	a5,32(s1)
    80004338:	0017871b          	addiw	a4,a5,1
    8000433c:	0007069b          	sext.w	a3,a4
    80004340:	0027179b          	slliw	a5,a4,0x2
    80004344:	9fb9                	addw	a5,a5,a4
    80004346:	0017979b          	slliw	a5,a5,0x1
    8000434a:	54d8                	lw	a4,44(s1)
    8000434c:	9fb9                	addw	a5,a5,a4
    8000434e:	00f95963          	bge	s2,a5,80004360 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004352:	85a6                	mv	a1,s1
    80004354:	8526                	mv	a0,s1
    80004356:	ffffe097          	auipc	ra,0xffffe
    8000435a:	1cc080e7          	jalr	460(ra) # 80002522 <sleep>
    8000435e:	bfd1                	j	80004332 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004360:	0001d517          	auipc	a0,0x1d
    80004364:	7a850513          	addi	a0,a0,1960 # 80021b08 <log>
    80004368:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	95a080e7          	jalr	-1702(ra) # 80000cc4 <release>
      break;
    }
  }
}
    80004372:	60e2                	ld	ra,24(sp)
    80004374:	6442                	ld	s0,16(sp)
    80004376:	64a2                	ld	s1,8(sp)
    80004378:	6902                	ld	s2,0(sp)
    8000437a:	6105                	addi	sp,sp,32
    8000437c:	8082                	ret

000000008000437e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000437e:	7139                	addi	sp,sp,-64
    80004380:	fc06                	sd	ra,56(sp)
    80004382:	f822                	sd	s0,48(sp)
    80004384:	f426                	sd	s1,40(sp)
    80004386:	f04a                	sd	s2,32(sp)
    80004388:	ec4e                	sd	s3,24(sp)
    8000438a:	e852                	sd	s4,16(sp)
    8000438c:	e456                	sd	s5,8(sp)
    8000438e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004390:	0001d497          	auipc	s1,0x1d
    80004394:	77848493          	addi	s1,s1,1912 # 80021b08 <log>
    80004398:	8526                	mv	a0,s1
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	876080e7          	jalr	-1930(ra) # 80000c10 <acquire>
  log.outstanding -= 1;
    800043a2:	509c                	lw	a5,32(s1)
    800043a4:	37fd                	addiw	a5,a5,-1
    800043a6:	0007891b          	sext.w	s2,a5
    800043aa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043ac:	50dc                	lw	a5,36(s1)
    800043ae:	efb9                	bnez	a5,8000440c <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043b0:	06091663          	bnez	s2,8000441c <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800043b4:	0001d497          	auipc	s1,0x1d
    800043b8:	75448493          	addi	s1,s1,1876 # 80021b08 <log>
    800043bc:	4785                	li	a5,1
    800043be:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043c0:	8526                	mv	a0,s1
    800043c2:	ffffd097          	auipc	ra,0xffffd
    800043c6:	902080e7          	jalr	-1790(ra) # 80000cc4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043ca:	54dc                	lw	a5,44(s1)
    800043cc:	06f04763          	bgtz	a5,8000443a <end_op+0xbc>
    acquire(&log.lock);
    800043d0:	0001d497          	auipc	s1,0x1d
    800043d4:	73848493          	addi	s1,s1,1848 # 80021b08 <log>
    800043d8:	8526                	mv	a0,s1
    800043da:	ffffd097          	auipc	ra,0xffffd
    800043de:	836080e7          	jalr	-1994(ra) # 80000c10 <acquire>
    log.committing = 0;
    800043e2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043e6:	8526                	mv	a0,s1
    800043e8:	ffffe097          	auipc	ra,0xffffe
    800043ec:	2c0080e7          	jalr	704(ra) # 800026a8 <wakeup>
    release(&log.lock);
    800043f0:	8526                	mv	a0,s1
    800043f2:	ffffd097          	auipc	ra,0xffffd
    800043f6:	8d2080e7          	jalr	-1838(ra) # 80000cc4 <release>
}
    800043fa:	70e2                	ld	ra,56(sp)
    800043fc:	7442                	ld	s0,48(sp)
    800043fe:	74a2                	ld	s1,40(sp)
    80004400:	7902                	ld	s2,32(sp)
    80004402:	69e2                	ld	s3,24(sp)
    80004404:	6a42                	ld	s4,16(sp)
    80004406:	6aa2                	ld	s5,8(sp)
    80004408:	6121                	addi	sp,sp,64
    8000440a:	8082                	ret
    panic("log.committing");
    8000440c:	00004517          	auipc	a0,0x4
    80004410:	2a450513          	addi	a0,a0,676 # 800086b0 <syscalls+0x1e0>
    80004414:	ffffc097          	auipc	ra,0xffffc
    80004418:	134080e7          	jalr	308(ra) # 80000548 <panic>
    wakeup(&log);
    8000441c:	0001d497          	auipc	s1,0x1d
    80004420:	6ec48493          	addi	s1,s1,1772 # 80021b08 <log>
    80004424:	8526                	mv	a0,s1
    80004426:	ffffe097          	auipc	ra,0xffffe
    8000442a:	282080e7          	jalr	642(ra) # 800026a8 <wakeup>
  release(&log.lock);
    8000442e:	8526                	mv	a0,s1
    80004430:	ffffd097          	auipc	ra,0xffffd
    80004434:	894080e7          	jalr	-1900(ra) # 80000cc4 <release>
  if(do_commit){
    80004438:	b7c9                	j	800043fa <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000443a:	0001da97          	auipc	s5,0x1d
    8000443e:	6fea8a93          	addi	s5,s5,1790 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004442:	0001da17          	auipc	s4,0x1d
    80004446:	6c6a0a13          	addi	s4,s4,1734 # 80021b08 <log>
    8000444a:	018a2583          	lw	a1,24(s4)
    8000444e:	012585bb          	addw	a1,a1,s2
    80004452:	2585                	addiw	a1,a1,1
    80004454:	028a2503          	lw	a0,40(s4)
    80004458:	fffff097          	auipc	ra,0xfffff
    8000445c:	ce8080e7          	jalr	-792(ra) # 80003140 <bread>
    80004460:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004462:	000aa583          	lw	a1,0(s5)
    80004466:	028a2503          	lw	a0,40(s4)
    8000446a:	fffff097          	auipc	ra,0xfffff
    8000446e:	cd6080e7          	jalr	-810(ra) # 80003140 <bread>
    80004472:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004474:	40000613          	li	a2,1024
    80004478:	05850593          	addi	a1,a0,88
    8000447c:	05848513          	addi	a0,s1,88
    80004480:	ffffd097          	auipc	ra,0xffffd
    80004484:	8ec080e7          	jalr	-1812(ra) # 80000d6c <memmove>
    bwrite(to);  // write the log
    80004488:	8526                	mv	a0,s1
    8000448a:	fffff097          	auipc	ra,0xfffff
    8000448e:	da8080e7          	jalr	-600(ra) # 80003232 <bwrite>
    brelse(from);
    80004492:	854e                	mv	a0,s3
    80004494:	fffff097          	auipc	ra,0xfffff
    80004498:	ddc080e7          	jalr	-548(ra) # 80003270 <brelse>
    brelse(to);
    8000449c:	8526                	mv	a0,s1
    8000449e:	fffff097          	auipc	ra,0xfffff
    800044a2:	dd2080e7          	jalr	-558(ra) # 80003270 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044a6:	2905                	addiw	s2,s2,1
    800044a8:	0a91                	addi	s5,s5,4
    800044aa:	02ca2783          	lw	a5,44(s4)
    800044ae:	f8f94ee3          	blt	s2,a5,8000444a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044b2:	00000097          	auipc	ra,0x0
    800044b6:	c7a080e7          	jalr	-902(ra) # 8000412c <write_head>
    install_trans(); // Now install writes to home locations
    800044ba:	00000097          	auipc	ra,0x0
    800044be:	cec080e7          	jalr	-788(ra) # 800041a6 <install_trans>
    log.lh.n = 0;
    800044c2:	0001d797          	auipc	a5,0x1d
    800044c6:	6607a923          	sw	zero,1650(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044ca:	00000097          	auipc	ra,0x0
    800044ce:	c62080e7          	jalr	-926(ra) # 8000412c <write_head>
    800044d2:	bdfd                	j	800043d0 <end_op+0x52>

00000000800044d4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044d4:	1101                	addi	sp,sp,-32
    800044d6:	ec06                	sd	ra,24(sp)
    800044d8:	e822                	sd	s0,16(sp)
    800044da:	e426                	sd	s1,8(sp)
    800044dc:	e04a                	sd	s2,0(sp)
    800044de:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044e0:	0001d717          	auipc	a4,0x1d
    800044e4:	65472703          	lw	a4,1620(a4) # 80021b34 <log+0x2c>
    800044e8:	47f5                	li	a5,29
    800044ea:	08e7c063          	blt	a5,a4,8000456a <log_write+0x96>
    800044ee:	84aa                	mv	s1,a0
    800044f0:	0001d797          	auipc	a5,0x1d
    800044f4:	6347a783          	lw	a5,1588(a5) # 80021b24 <log+0x1c>
    800044f8:	37fd                	addiw	a5,a5,-1
    800044fa:	06f75863          	bge	a4,a5,8000456a <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044fe:	0001d797          	auipc	a5,0x1d
    80004502:	62a7a783          	lw	a5,1578(a5) # 80021b28 <log+0x20>
    80004506:	06f05a63          	blez	a5,8000457a <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000450a:	0001d917          	auipc	s2,0x1d
    8000450e:	5fe90913          	addi	s2,s2,1534 # 80021b08 <log>
    80004512:	854a                	mv	a0,s2
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	6fc080e7          	jalr	1788(ra) # 80000c10 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000451c:	02c92603          	lw	a2,44(s2)
    80004520:	06c05563          	blez	a2,8000458a <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004524:	44cc                	lw	a1,12(s1)
    80004526:	0001d717          	auipc	a4,0x1d
    8000452a:	61270713          	addi	a4,a4,1554 # 80021b38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000452e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004530:	4314                	lw	a3,0(a4)
    80004532:	04b68d63          	beq	a3,a1,8000458c <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004536:	2785                	addiw	a5,a5,1
    80004538:	0711                	addi	a4,a4,4
    8000453a:	fec79be3          	bne	a5,a2,80004530 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000453e:	0621                	addi	a2,a2,8
    80004540:	060a                	slli	a2,a2,0x2
    80004542:	0001d797          	auipc	a5,0x1d
    80004546:	5c678793          	addi	a5,a5,1478 # 80021b08 <log>
    8000454a:	963e                	add	a2,a2,a5
    8000454c:	44dc                	lw	a5,12(s1)
    8000454e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004550:	8526                	mv	a0,s1
    80004552:	fffff097          	auipc	ra,0xfffff
    80004556:	dbc080e7          	jalr	-580(ra) # 8000330e <bpin>
    log.lh.n++;
    8000455a:	0001d717          	auipc	a4,0x1d
    8000455e:	5ae70713          	addi	a4,a4,1454 # 80021b08 <log>
    80004562:	575c                	lw	a5,44(a4)
    80004564:	2785                	addiw	a5,a5,1
    80004566:	d75c                	sw	a5,44(a4)
    80004568:	a83d                	j	800045a6 <log_write+0xd2>
    panic("too big a transaction");
    8000456a:	00004517          	auipc	a0,0x4
    8000456e:	15650513          	addi	a0,a0,342 # 800086c0 <syscalls+0x1f0>
    80004572:	ffffc097          	auipc	ra,0xffffc
    80004576:	fd6080e7          	jalr	-42(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    8000457a:	00004517          	auipc	a0,0x4
    8000457e:	15e50513          	addi	a0,a0,350 # 800086d8 <syscalls+0x208>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	fc6080e7          	jalr	-58(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    8000458a:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000458c:	00878713          	addi	a4,a5,8
    80004590:	00271693          	slli	a3,a4,0x2
    80004594:	0001d717          	auipc	a4,0x1d
    80004598:	57470713          	addi	a4,a4,1396 # 80021b08 <log>
    8000459c:	9736                	add	a4,a4,a3
    8000459e:	44d4                	lw	a3,12(s1)
    800045a0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045a2:	faf607e3          	beq	a2,a5,80004550 <log_write+0x7c>
  }
  release(&log.lock);
    800045a6:	0001d517          	auipc	a0,0x1d
    800045aa:	56250513          	addi	a0,a0,1378 # 80021b08 <log>
    800045ae:	ffffc097          	auipc	ra,0xffffc
    800045b2:	716080e7          	jalr	1814(ra) # 80000cc4 <release>
}
    800045b6:	60e2                	ld	ra,24(sp)
    800045b8:	6442                	ld	s0,16(sp)
    800045ba:	64a2                	ld	s1,8(sp)
    800045bc:	6902                	ld	s2,0(sp)
    800045be:	6105                	addi	sp,sp,32
    800045c0:	8082                	ret

00000000800045c2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045c2:	1101                	addi	sp,sp,-32
    800045c4:	ec06                	sd	ra,24(sp)
    800045c6:	e822                	sd	s0,16(sp)
    800045c8:	e426                	sd	s1,8(sp)
    800045ca:	e04a                	sd	s2,0(sp)
    800045cc:	1000                	addi	s0,sp,32
    800045ce:	84aa                	mv	s1,a0
    800045d0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045d2:	00004597          	auipc	a1,0x4
    800045d6:	12658593          	addi	a1,a1,294 # 800086f8 <syscalls+0x228>
    800045da:	0521                	addi	a0,a0,8
    800045dc:	ffffc097          	auipc	ra,0xffffc
    800045e0:	5a4080e7          	jalr	1444(ra) # 80000b80 <initlock>
  lk->name = name;
    800045e4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ec:	0204a423          	sw	zero,40(s1)
}
    800045f0:	60e2                	ld	ra,24(sp)
    800045f2:	6442                	ld	s0,16(sp)
    800045f4:	64a2                	ld	s1,8(sp)
    800045f6:	6902                	ld	s2,0(sp)
    800045f8:	6105                	addi	sp,sp,32
    800045fa:	8082                	ret

00000000800045fc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045fc:	1101                	addi	sp,sp,-32
    800045fe:	ec06                	sd	ra,24(sp)
    80004600:	e822                	sd	s0,16(sp)
    80004602:	e426                	sd	s1,8(sp)
    80004604:	e04a                	sd	s2,0(sp)
    80004606:	1000                	addi	s0,sp,32
    80004608:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000460a:	00850913          	addi	s2,a0,8
    8000460e:	854a                	mv	a0,s2
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	600080e7          	jalr	1536(ra) # 80000c10 <acquire>
  while (lk->locked) {
    80004618:	409c                	lw	a5,0(s1)
    8000461a:	cb89                	beqz	a5,8000462c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000461c:	85ca                	mv	a1,s2
    8000461e:	8526                	mv	a0,s1
    80004620:	ffffe097          	auipc	ra,0xffffe
    80004624:	f02080e7          	jalr	-254(ra) # 80002522 <sleep>
  while (lk->locked) {
    80004628:	409c                	lw	a5,0(s1)
    8000462a:	fbed                	bnez	a5,8000461c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000462c:	4785                	li	a5,1
    8000462e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004630:	ffffd097          	auipc	ra,0xffffd
    80004634:	4e2080e7          	jalr	1250(ra) # 80001b12 <myproc>
    80004638:	5d1c                	lw	a5,56(a0)
    8000463a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000463c:	854a                	mv	a0,s2
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	686080e7          	jalr	1670(ra) # 80000cc4 <release>
}
    80004646:	60e2                	ld	ra,24(sp)
    80004648:	6442                	ld	s0,16(sp)
    8000464a:	64a2                	ld	s1,8(sp)
    8000464c:	6902                	ld	s2,0(sp)
    8000464e:	6105                	addi	sp,sp,32
    80004650:	8082                	ret

0000000080004652 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004652:	1101                	addi	sp,sp,-32
    80004654:	ec06                	sd	ra,24(sp)
    80004656:	e822                	sd	s0,16(sp)
    80004658:	e426                	sd	s1,8(sp)
    8000465a:	e04a                	sd	s2,0(sp)
    8000465c:	1000                	addi	s0,sp,32
    8000465e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004660:	00850913          	addi	s2,a0,8
    80004664:	854a                	mv	a0,s2
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	5aa080e7          	jalr	1450(ra) # 80000c10 <acquire>
  lk->locked = 0;
    8000466e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004672:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004676:	8526                	mv	a0,s1
    80004678:	ffffe097          	auipc	ra,0xffffe
    8000467c:	030080e7          	jalr	48(ra) # 800026a8 <wakeup>
  release(&lk->lk);
    80004680:	854a                	mv	a0,s2
    80004682:	ffffc097          	auipc	ra,0xffffc
    80004686:	642080e7          	jalr	1602(ra) # 80000cc4 <release>
}
    8000468a:	60e2                	ld	ra,24(sp)
    8000468c:	6442                	ld	s0,16(sp)
    8000468e:	64a2                	ld	s1,8(sp)
    80004690:	6902                	ld	s2,0(sp)
    80004692:	6105                	addi	sp,sp,32
    80004694:	8082                	ret

0000000080004696 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004696:	7179                	addi	sp,sp,-48
    80004698:	f406                	sd	ra,40(sp)
    8000469a:	f022                	sd	s0,32(sp)
    8000469c:	ec26                	sd	s1,24(sp)
    8000469e:	e84a                	sd	s2,16(sp)
    800046a0:	e44e                	sd	s3,8(sp)
    800046a2:	1800                	addi	s0,sp,48
    800046a4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046a6:	00850913          	addi	s2,a0,8
    800046aa:	854a                	mv	a0,s2
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	564080e7          	jalr	1380(ra) # 80000c10 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046b4:	409c                	lw	a5,0(s1)
    800046b6:	ef99                	bnez	a5,800046d4 <holdingsleep+0x3e>
    800046b8:	4481                	li	s1,0
  release(&lk->lk);
    800046ba:	854a                	mv	a0,s2
    800046bc:	ffffc097          	auipc	ra,0xffffc
    800046c0:	608080e7          	jalr	1544(ra) # 80000cc4 <release>
  return r;
}
    800046c4:	8526                	mv	a0,s1
    800046c6:	70a2                	ld	ra,40(sp)
    800046c8:	7402                	ld	s0,32(sp)
    800046ca:	64e2                	ld	s1,24(sp)
    800046cc:	6942                	ld	s2,16(sp)
    800046ce:	69a2                	ld	s3,8(sp)
    800046d0:	6145                	addi	sp,sp,48
    800046d2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046d4:	0284a983          	lw	s3,40(s1)
    800046d8:	ffffd097          	auipc	ra,0xffffd
    800046dc:	43a080e7          	jalr	1082(ra) # 80001b12 <myproc>
    800046e0:	5d04                	lw	s1,56(a0)
    800046e2:	413484b3          	sub	s1,s1,s3
    800046e6:	0014b493          	seqz	s1,s1
    800046ea:	bfc1                	j	800046ba <holdingsleep+0x24>

00000000800046ec <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046ec:	1141                	addi	sp,sp,-16
    800046ee:	e406                	sd	ra,8(sp)
    800046f0:	e022                	sd	s0,0(sp)
    800046f2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046f4:	00004597          	auipc	a1,0x4
    800046f8:	01458593          	addi	a1,a1,20 # 80008708 <syscalls+0x238>
    800046fc:	0001d517          	auipc	a0,0x1d
    80004700:	55450513          	addi	a0,a0,1364 # 80021c50 <ftable>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	47c080e7          	jalr	1148(ra) # 80000b80 <initlock>
}
    8000470c:	60a2                	ld	ra,8(sp)
    8000470e:	6402                	ld	s0,0(sp)
    80004710:	0141                	addi	sp,sp,16
    80004712:	8082                	ret

0000000080004714 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004714:	1101                	addi	sp,sp,-32
    80004716:	ec06                	sd	ra,24(sp)
    80004718:	e822                	sd	s0,16(sp)
    8000471a:	e426                	sd	s1,8(sp)
    8000471c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000471e:	0001d517          	auipc	a0,0x1d
    80004722:	53250513          	addi	a0,a0,1330 # 80021c50 <ftable>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	4ea080e7          	jalr	1258(ra) # 80000c10 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000472e:	0001d497          	auipc	s1,0x1d
    80004732:	53a48493          	addi	s1,s1,1338 # 80021c68 <ftable+0x18>
    80004736:	0001e717          	auipc	a4,0x1e
    8000473a:	4d270713          	addi	a4,a4,1234 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    8000473e:	40dc                	lw	a5,4(s1)
    80004740:	cf99                	beqz	a5,8000475e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004742:	02848493          	addi	s1,s1,40
    80004746:	fee49ce3          	bne	s1,a4,8000473e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000474a:	0001d517          	auipc	a0,0x1d
    8000474e:	50650513          	addi	a0,a0,1286 # 80021c50 <ftable>
    80004752:	ffffc097          	auipc	ra,0xffffc
    80004756:	572080e7          	jalr	1394(ra) # 80000cc4 <release>
  return 0;
    8000475a:	4481                	li	s1,0
    8000475c:	a819                	j	80004772 <filealloc+0x5e>
      f->ref = 1;
    8000475e:	4785                	li	a5,1
    80004760:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004762:	0001d517          	auipc	a0,0x1d
    80004766:	4ee50513          	addi	a0,a0,1262 # 80021c50 <ftable>
    8000476a:	ffffc097          	auipc	ra,0xffffc
    8000476e:	55a080e7          	jalr	1370(ra) # 80000cc4 <release>
}
    80004772:	8526                	mv	a0,s1
    80004774:	60e2                	ld	ra,24(sp)
    80004776:	6442                	ld	s0,16(sp)
    80004778:	64a2                	ld	s1,8(sp)
    8000477a:	6105                	addi	sp,sp,32
    8000477c:	8082                	ret

000000008000477e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000477e:	1101                	addi	sp,sp,-32
    80004780:	ec06                	sd	ra,24(sp)
    80004782:	e822                	sd	s0,16(sp)
    80004784:	e426                	sd	s1,8(sp)
    80004786:	1000                	addi	s0,sp,32
    80004788:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000478a:	0001d517          	auipc	a0,0x1d
    8000478e:	4c650513          	addi	a0,a0,1222 # 80021c50 <ftable>
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	47e080e7          	jalr	1150(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    8000479a:	40dc                	lw	a5,4(s1)
    8000479c:	02f05263          	blez	a5,800047c0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047a0:	2785                	addiw	a5,a5,1
    800047a2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047a4:	0001d517          	auipc	a0,0x1d
    800047a8:	4ac50513          	addi	a0,a0,1196 # 80021c50 <ftable>
    800047ac:	ffffc097          	auipc	ra,0xffffc
    800047b0:	518080e7          	jalr	1304(ra) # 80000cc4 <release>
  return f;
}
    800047b4:	8526                	mv	a0,s1
    800047b6:	60e2                	ld	ra,24(sp)
    800047b8:	6442                	ld	s0,16(sp)
    800047ba:	64a2                	ld	s1,8(sp)
    800047bc:	6105                	addi	sp,sp,32
    800047be:	8082                	ret
    panic("filedup");
    800047c0:	00004517          	auipc	a0,0x4
    800047c4:	f5050513          	addi	a0,a0,-176 # 80008710 <syscalls+0x240>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	d80080e7          	jalr	-640(ra) # 80000548 <panic>

00000000800047d0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047d0:	7139                	addi	sp,sp,-64
    800047d2:	fc06                	sd	ra,56(sp)
    800047d4:	f822                	sd	s0,48(sp)
    800047d6:	f426                	sd	s1,40(sp)
    800047d8:	f04a                	sd	s2,32(sp)
    800047da:	ec4e                	sd	s3,24(sp)
    800047dc:	e852                	sd	s4,16(sp)
    800047de:	e456                	sd	s5,8(sp)
    800047e0:	0080                	addi	s0,sp,64
    800047e2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047e4:	0001d517          	auipc	a0,0x1d
    800047e8:	46c50513          	addi	a0,a0,1132 # 80021c50 <ftable>
    800047ec:	ffffc097          	auipc	ra,0xffffc
    800047f0:	424080e7          	jalr	1060(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    800047f4:	40dc                	lw	a5,4(s1)
    800047f6:	06f05163          	blez	a5,80004858 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047fa:	37fd                	addiw	a5,a5,-1
    800047fc:	0007871b          	sext.w	a4,a5
    80004800:	c0dc                	sw	a5,4(s1)
    80004802:	06e04363          	bgtz	a4,80004868 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004806:	0004a903          	lw	s2,0(s1)
    8000480a:	0094ca83          	lbu	s5,9(s1)
    8000480e:	0104ba03          	ld	s4,16(s1)
    80004812:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004816:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000481a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000481e:	0001d517          	auipc	a0,0x1d
    80004822:	43250513          	addi	a0,a0,1074 # 80021c50 <ftable>
    80004826:	ffffc097          	auipc	ra,0xffffc
    8000482a:	49e080e7          	jalr	1182(ra) # 80000cc4 <release>

  if(ff.type == FD_PIPE){
    8000482e:	4785                	li	a5,1
    80004830:	04f90d63          	beq	s2,a5,8000488a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004834:	3979                	addiw	s2,s2,-2
    80004836:	4785                	li	a5,1
    80004838:	0527e063          	bltu	a5,s2,80004878 <fileclose+0xa8>
    begin_op();
    8000483c:	00000097          	auipc	ra,0x0
    80004840:	ac2080e7          	jalr	-1342(ra) # 800042fe <begin_op>
    iput(ff.ip);
    80004844:	854e                	mv	a0,s3
    80004846:	fffff097          	auipc	ra,0xfffff
    8000484a:	2b6080e7          	jalr	694(ra) # 80003afc <iput>
    end_op();
    8000484e:	00000097          	auipc	ra,0x0
    80004852:	b30080e7          	jalr	-1232(ra) # 8000437e <end_op>
    80004856:	a00d                	j	80004878 <fileclose+0xa8>
    panic("fileclose");
    80004858:	00004517          	auipc	a0,0x4
    8000485c:	ec050513          	addi	a0,a0,-320 # 80008718 <syscalls+0x248>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	ce8080e7          	jalr	-792(ra) # 80000548 <panic>
    release(&ftable.lock);
    80004868:	0001d517          	auipc	a0,0x1d
    8000486c:	3e850513          	addi	a0,a0,1000 # 80021c50 <ftable>
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	454080e7          	jalr	1108(ra) # 80000cc4 <release>
  }
}
    80004878:	70e2                	ld	ra,56(sp)
    8000487a:	7442                	ld	s0,48(sp)
    8000487c:	74a2                	ld	s1,40(sp)
    8000487e:	7902                	ld	s2,32(sp)
    80004880:	69e2                	ld	s3,24(sp)
    80004882:	6a42                	ld	s4,16(sp)
    80004884:	6aa2                	ld	s5,8(sp)
    80004886:	6121                	addi	sp,sp,64
    80004888:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000488a:	85d6                	mv	a1,s5
    8000488c:	8552                	mv	a0,s4
    8000488e:	00000097          	auipc	ra,0x0
    80004892:	372080e7          	jalr	882(ra) # 80004c00 <pipeclose>
    80004896:	b7cd                	j	80004878 <fileclose+0xa8>

0000000080004898 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004898:	715d                	addi	sp,sp,-80
    8000489a:	e486                	sd	ra,72(sp)
    8000489c:	e0a2                	sd	s0,64(sp)
    8000489e:	fc26                	sd	s1,56(sp)
    800048a0:	f84a                	sd	s2,48(sp)
    800048a2:	f44e                	sd	s3,40(sp)
    800048a4:	0880                	addi	s0,sp,80
    800048a6:	84aa                	mv	s1,a0
    800048a8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048aa:	ffffd097          	auipc	ra,0xffffd
    800048ae:	268080e7          	jalr	616(ra) # 80001b12 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048b2:	409c                	lw	a5,0(s1)
    800048b4:	37f9                	addiw	a5,a5,-2
    800048b6:	4705                	li	a4,1
    800048b8:	04f76763          	bltu	a4,a5,80004906 <filestat+0x6e>
    800048bc:	892a                	mv	s2,a0
    ilock(f->ip);
    800048be:	6c88                	ld	a0,24(s1)
    800048c0:	fffff097          	auipc	ra,0xfffff
    800048c4:	082080e7          	jalr	130(ra) # 80003942 <ilock>
    stati(f->ip, &st);
    800048c8:	fb840593          	addi	a1,s0,-72
    800048cc:	6c88                	ld	a0,24(s1)
    800048ce:	fffff097          	auipc	ra,0xfffff
    800048d2:	2fe080e7          	jalr	766(ra) # 80003bcc <stati>
    iunlock(f->ip);
    800048d6:	6c88                	ld	a0,24(s1)
    800048d8:	fffff097          	auipc	ra,0xfffff
    800048dc:	12c080e7          	jalr	300(ra) # 80003a04 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048e0:	46e1                	li	a3,24
    800048e2:	fb840613          	addi	a2,s0,-72
    800048e6:	85ce                	mv	a1,s3
    800048e8:	05093503          	ld	a0,80(s2)
    800048ec:	ffffd097          	auipc	ra,0xffffd
    800048f0:	fd6080e7          	jalr	-42(ra) # 800018c2 <copyout>
    800048f4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048f8:	60a6                	ld	ra,72(sp)
    800048fa:	6406                	ld	s0,64(sp)
    800048fc:	74e2                	ld	s1,56(sp)
    800048fe:	7942                	ld	s2,48(sp)
    80004900:	79a2                	ld	s3,40(sp)
    80004902:	6161                	addi	sp,sp,80
    80004904:	8082                	ret
  return -1;
    80004906:	557d                	li	a0,-1
    80004908:	bfc5                	j	800048f8 <filestat+0x60>

000000008000490a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000490a:	7179                	addi	sp,sp,-48
    8000490c:	f406                	sd	ra,40(sp)
    8000490e:	f022                	sd	s0,32(sp)
    80004910:	ec26                	sd	s1,24(sp)
    80004912:	e84a                	sd	s2,16(sp)
    80004914:	e44e                	sd	s3,8(sp)
    80004916:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004918:	00854783          	lbu	a5,8(a0)
    8000491c:	c3d5                	beqz	a5,800049c0 <fileread+0xb6>
    8000491e:	84aa                	mv	s1,a0
    80004920:	89ae                	mv	s3,a1
    80004922:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004924:	411c                	lw	a5,0(a0)
    80004926:	4705                	li	a4,1
    80004928:	04e78963          	beq	a5,a4,8000497a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000492c:	470d                	li	a4,3
    8000492e:	04e78d63          	beq	a5,a4,80004988 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004932:	4709                	li	a4,2
    80004934:	06e79e63          	bne	a5,a4,800049b0 <fileread+0xa6>
    ilock(f->ip);
    80004938:	6d08                	ld	a0,24(a0)
    8000493a:	fffff097          	auipc	ra,0xfffff
    8000493e:	008080e7          	jalr	8(ra) # 80003942 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004942:	874a                	mv	a4,s2
    80004944:	5094                	lw	a3,32(s1)
    80004946:	864e                	mv	a2,s3
    80004948:	4585                	li	a1,1
    8000494a:	6c88                	ld	a0,24(s1)
    8000494c:	fffff097          	auipc	ra,0xfffff
    80004950:	2aa080e7          	jalr	682(ra) # 80003bf6 <readi>
    80004954:	892a                	mv	s2,a0
    80004956:	00a05563          	blez	a0,80004960 <fileread+0x56>
      f->off += r;
    8000495a:	509c                	lw	a5,32(s1)
    8000495c:	9fa9                	addw	a5,a5,a0
    8000495e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004960:	6c88                	ld	a0,24(s1)
    80004962:	fffff097          	auipc	ra,0xfffff
    80004966:	0a2080e7          	jalr	162(ra) # 80003a04 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000496a:	854a                	mv	a0,s2
    8000496c:	70a2                	ld	ra,40(sp)
    8000496e:	7402                	ld	s0,32(sp)
    80004970:	64e2                	ld	s1,24(sp)
    80004972:	6942                	ld	s2,16(sp)
    80004974:	69a2                	ld	s3,8(sp)
    80004976:	6145                	addi	sp,sp,48
    80004978:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000497a:	6908                	ld	a0,16(a0)
    8000497c:	00000097          	auipc	ra,0x0
    80004980:	418080e7          	jalr	1048(ra) # 80004d94 <piperead>
    80004984:	892a                	mv	s2,a0
    80004986:	b7d5                	j	8000496a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004988:	02451783          	lh	a5,36(a0)
    8000498c:	03079693          	slli	a3,a5,0x30
    80004990:	92c1                	srli	a3,a3,0x30
    80004992:	4725                	li	a4,9
    80004994:	02d76863          	bltu	a4,a3,800049c4 <fileread+0xba>
    80004998:	0792                	slli	a5,a5,0x4
    8000499a:	0001d717          	auipc	a4,0x1d
    8000499e:	21670713          	addi	a4,a4,534 # 80021bb0 <devsw>
    800049a2:	97ba                	add	a5,a5,a4
    800049a4:	639c                	ld	a5,0(a5)
    800049a6:	c38d                	beqz	a5,800049c8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049a8:	4505                	li	a0,1
    800049aa:	9782                	jalr	a5
    800049ac:	892a                	mv	s2,a0
    800049ae:	bf75                	j	8000496a <fileread+0x60>
    panic("fileread");
    800049b0:	00004517          	auipc	a0,0x4
    800049b4:	d7850513          	addi	a0,a0,-648 # 80008728 <syscalls+0x258>
    800049b8:	ffffc097          	auipc	ra,0xffffc
    800049bc:	b90080e7          	jalr	-1136(ra) # 80000548 <panic>
    return -1;
    800049c0:	597d                	li	s2,-1
    800049c2:	b765                	j	8000496a <fileread+0x60>
      return -1;
    800049c4:	597d                	li	s2,-1
    800049c6:	b755                	j	8000496a <fileread+0x60>
    800049c8:	597d                	li	s2,-1
    800049ca:	b745                	j	8000496a <fileread+0x60>

00000000800049cc <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800049cc:	00954783          	lbu	a5,9(a0)
    800049d0:	14078563          	beqz	a5,80004b1a <filewrite+0x14e>
{
    800049d4:	715d                	addi	sp,sp,-80
    800049d6:	e486                	sd	ra,72(sp)
    800049d8:	e0a2                	sd	s0,64(sp)
    800049da:	fc26                	sd	s1,56(sp)
    800049dc:	f84a                	sd	s2,48(sp)
    800049de:	f44e                	sd	s3,40(sp)
    800049e0:	f052                	sd	s4,32(sp)
    800049e2:	ec56                	sd	s5,24(sp)
    800049e4:	e85a                	sd	s6,16(sp)
    800049e6:	e45e                	sd	s7,8(sp)
    800049e8:	e062                	sd	s8,0(sp)
    800049ea:	0880                	addi	s0,sp,80
    800049ec:	892a                	mv	s2,a0
    800049ee:	8aae                	mv	s5,a1
    800049f0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049f2:	411c                	lw	a5,0(a0)
    800049f4:	4705                	li	a4,1
    800049f6:	02e78263          	beq	a5,a4,80004a1a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049fa:	470d                	li	a4,3
    800049fc:	02e78563          	beq	a5,a4,80004a26 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a00:	4709                	li	a4,2
    80004a02:	10e79463          	bne	a5,a4,80004b0a <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a06:	0ec05e63          	blez	a2,80004b02 <filewrite+0x136>
    int i = 0;
    80004a0a:	4981                	li	s3,0
    80004a0c:	6b05                	lui	s6,0x1
    80004a0e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a12:	6b85                	lui	s7,0x1
    80004a14:	c00b8b9b          	addiw	s7,s7,-1024
    80004a18:	a851                	j	80004aac <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004a1a:	6908                	ld	a0,16(a0)
    80004a1c:	00000097          	auipc	ra,0x0
    80004a20:	254080e7          	jalr	596(ra) # 80004c70 <pipewrite>
    80004a24:	a85d                	j	80004ada <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a26:	02451783          	lh	a5,36(a0)
    80004a2a:	03079693          	slli	a3,a5,0x30
    80004a2e:	92c1                	srli	a3,a3,0x30
    80004a30:	4725                	li	a4,9
    80004a32:	0ed76663          	bltu	a4,a3,80004b1e <filewrite+0x152>
    80004a36:	0792                	slli	a5,a5,0x4
    80004a38:	0001d717          	auipc	a4,0x1d
    80004a3c:	17870713          	addi	a4,a4,376 # 80021bb0 <devsw>
    80004a40:	97ba                	add	a5,a5,a4
    80004a42:	679c                	ld	a5,8(a5)
    80004a44:	cff9                	beqz	a5,80004b22 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004a46:	4505                	li	a0,1
    80004a48:	9782                	jalr	a5
    80004a4a:	a841                	j	80004ada <filewrite+0x10e>
    80004a4c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a50:	00000097          	auipc	ra,0x0
    80004a54:	8ae080e7          	jalr	-1874(ra) # 800042fe <begin_op>
      ilock(f->ip);
    80004a58:	01893503          	ld	a0,24(s2)
    80004a5c:	fffff097          	auipc	ra,0xfffff
    80004a60:	ee6080e7          	jalr	-282(ra) # 80003942 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a64:	8762                	mv	a4,s8
    80004a66:	02092683          	lw	a3,32(s2)
    80004a6a:	01598633          	add	a2,s3,s5
    80004a6e:	4585                	li	a1,1
    80004a70:	01893503          	ld	a0,24(s2)
    80004a74:	fffff097          	auipc	ra,0xfffff
    80004a78:	278080e7          	jalr	632(ra) # 80003cec <writei>
    80004a7c:	84aa                	mv	s1,a0
    80004a7e:	02a05f63          	blez	a0,80004abc <filewrite+0xf0>
        f->off += r;
    80004a82:	02092783          	lw	a5,32(s2)
    80004a86:	9fa9                	addw	a5,a5,a0
    80004a88:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a8c:	01893503          	ld	a0,24(s2)
    80004a90:	fffff097          	auipc	ra,0xfffff
    80004a94:	f74080e7          	jalr	-140(ra) # 80003a04 <iunlock>
      end_op();
    80004a98:	00000097          	auipc	ra,0x0
    80004a9c:	8e6080e7          	jalr	-1818(ra) # 8000437e <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004aa0:	049c1963          	bne	s8,s1,80004af2 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004aa4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004aa8:	0349d663          	bge	s3,s4,80004ad4 <filewrite+0x108>
      int n1 = n - i;
    80004aac:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004ab0:	84be                	mv	s1,a5
    80004ab2:	2781                	sext.w	a5,a5
    80004ab4:	f8fb5ce3          	bge	s6,a5,80004a4c <filewrite+0x80>
    80004ab8:	84de                	mv	s1,s7
    80004aba:	bf49                	j	80004a4c <filewrite+0x80>
      iunlock(f->ip);
    80004abc:	01893503          	ld	a0,24(s2)
    80004ac0:	fffff097          	auipc	ra,0xfffff
    80004ac4:	f44080e7          	jalr	-188(ra) # 80003a04 <iunlock>
      end_op();
    80004ac8:	00000097          	auipc	ra,0x0
    80004acc:	8b6080e7          	jalr	-1866(ra) # 8000437e <end_op>
      if(r < 0)
    80004ad0:	fc04d8e3          	bgez	s1,80004aa0 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004ad4:	8552                	mv	a0,s4
    80004ad6:	033a1863          	bne	s4,s3,80004b06 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ada:	60a6                	ld	ra,72(sp)
    80004adc:	6406                	ld	s0,64(sp)
    80004ade:	74e2                	ld	s1,56(sp)
    80004ae0:	7942                	ld	s2,48(sp)
    80004ae2:	79a2                	ld	s3,40(sp)
    80004ae4:	7a02                	ld	s4,32(sp)
    80004ae6:	6ae2                	ld	s5,24(sp)
    80004ae8:	6b42                	ld	s6,16(sp)
    80004aea:	6ba2                	ld	s7,8(sp)
    80004aec:	6c02                	ld	s8,0(sp)
    80004aee:	6161                	addi	sp,sp,80
    80004af0:	8082                	ret
        panic("short filewrite");
    80004af2:	00004517          	auipc	a0,0x4
    80004af6:	c4650513          	addi	a0,a0,-954 # 80008738 <syscalls+0x268>
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	a4e080e7          	jalr	-1458(ra) # 80000548 <panic>
    int i = 0;
    80004b02:	4981                	li	s3,0
    80004b04:	bfc1                	j	80004ad4 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004b06:	557d                	li	a0,-1
    80004b08:	bfc9                	j	80004ada <filewrite+0x10e>
    panic("filewrite");
    80004b0a:	00004517          	auipc	a0,0x4
    80004b0e:	c3e50513          	addi	a0,a0,-962 # 80008748 <syscalls+0x278>
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	a36080e7          	jalr	-1482(ra) # 80000548 <panic>
    return -1;
    80004b1a:	557d                	li	a0,-1
}
    80004b1c:	8082                	ret
      return -1;
    80004b1e:	557d                	li	a0,-1
    80004b20:	bf6d                	j	80004ada <filewrite+0x10e>
    80004b22:	557d                	li	a0,-1
    80004b24:	bf5d                	j	80004ada <filewrite+0x10e>

0000000080004b26 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b26:	7179                	addi	sp,sp,-48
    80004b28:	f406                	sd	ra,40(sp)
    80004b2a:	f022                	sd	s0,32(sp)
    80004b2c:	ec26                	sd	s1,24(sp)
    80004b2e:	e84a                	sd	s2,16(sp)
    80004b30:	e44e                	sd	s3,8(sp)
    80004b32:	e052                	sd	s4,0(sp)
    80004b34:	1800                	addi	s0,sp,48
    80004b36:	84aa                	mv	s1,a0
    80004b38:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b3a:	0005b023          	sd	zero,0(a1)
    80004b3e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b42:	00000097          	auipc	ra,0x0
    80004b46:	bd2080e7          	jalr	-1070(ra) # 80004714 <filealloc>
    80004b4a:	e088                	sd	a0,0(s1)
    80004b4c:	c551                	beqz	a0,80004bd8 <pipealloc+0xb2>
    80004b4e:	00000097          	auipc	ra,0x0
    80004b52:	bc6080e7          	jalr	-1082(ra) # 80004714 <filealloc>
    80004b56:	00aa3023          	sd	a0,0(s4)
    80004b5a:	c92d                	beqz	a0,80004bcc <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	fc4080e7          	jalr	-60(ra) # 80000b20 <kalloc>
    80004b64:	892a                	mv	s2,a0
    80004b66:	c125                	beqz	a0,80004bc6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b68:	4985                	li	s3,1
    80004b6a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b6e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b72:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b76:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b7a:	00004597          	auipc	a1,0x4
    80004b7e:	bde58593          	addi	a1,a1,-1058 # 80008758 <syscalls+0x288>
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	ffe080e7          	jalr	-2(ra) # 80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    80004b8a:	609c                	ld	a5,0(s1)
    80004b8c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b90:	609c                	ld	a5,0(s1)
    80004b92:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b96:	609c                	ld	a5,0(s1)
    80004b98:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b9c:	609c                	ld	a5,0(s1)
    80004b9e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ba2:	000a3783          	ld	a5,0(s4)
    80004ba6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004baa:	000a3783          	ld	a5,0(s4)
    80004bae:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bb2:	000a3783          	ld	a5,0(s4)
    80004bb6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bba:	000a3783          	ld	a5,0(s4)
    80004bbe:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bc2:	4501                	li	a0,0
    80004bc4:	a025                	j	80004bec <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bc6:	6088                	ld	a0,0(s1)
    80004bc8:	e501                	bnez	a0,80004bd0 <pipealloc+0xaa>
    80004bca:	a039                	j	80004bd8 <pipealloc+0xb2>
    80004bcc:	6088                	ld	a0,0(s1)
    80004bce:	c51d                	beqz	a0,80004bfc <pipealloc+0xd6>
    fileclose(*f0);
    80004bd0:	00000097          	auipc	ra,0x0
    80004bd4:	c00080e7          	jalr	-1024(ra) # 800047d0 <fileclose>
  if(*f1)
    80004bd8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bdc:	557d                	li	a0,-1
  if(*f1)
    80004bde:	c799                	beqz	a5,80004bec <pipealloc+0xc6>
    fileclose(*f1);
    80004be0:	853e                	mv	a0,a5
    80004be2:	00000097          	auipc	ra,0x0
    80004be6:	bee080e7          	jalr	-1042(ra) # 800047d0 <fileclose>
  return -1;
    80004bea:	557d                	li	a0,-1
}
    80004bec:	70a2                	ld	ra,40(sp)
    80004bee:	7402                	ld	s0,32(sp)
    80004bf0:	64e2                	ld	s1,24(sp)
    80004bf2:	6942                	ld	s2,16(sp)
    80004bf4:	69a2                	ld	s3,8(sp)
    80004bf6:	6a02                	ld	s4,0(sp)
    80004bf8:	6145                	addi	sp,sp,48
    80004bfa:	8082                	ret
  return -1;
    80004bfc:	557d                	li	a0,-1
    80004bfe:	b7fd                	j	80004bec <pipealloc+0xc6>

0000000080004c00 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c00:	1101                	addi	sp,sp,-32
    80004c02:	ec06                	sd	ra,24(sp)
    80004c04:	e822                	sd	s0,16(sp)
    80004c06:	e426                	sd	s1,8(sp)
    80004c08:	e04a                	sd	s2,0(sp)
    80004c0a:	1000                	addi	s0,sp,32
    80004c0c:	84aa                	mv	s1,a0
    80004c0e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c10:	ffffc097          	auipc	ra,0xffffc
    80004c14:	000080e7          	jalr	ra # 80000c10 <acquire>
  if(writable){
    80004c18:	02090d63          	beqz	s2,80004c52 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c1c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c20:	21848513          	addi	a0,s1,536
    80004c24:	ffffe097          	auipc	ra,0xffffe
    80004c28:	a84080e7          	jalr	-1404(ra) # 800026a8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c2c:	2204b783          	ld	a5,544(s1)
    80004c30:	eb95                	bnez	a5,80004c64 <pipeclose+0x64>
    release(&pi->lock);
    80004c32:	8526                	mv	a0,s1
    80004c34:	ffffc097          	auipc	ra,0xffffc
    80004c38:	090080e7          	jalr	144(ra) # 80000cc4 <release>
    kfree((char*)pi);
    80004c3c:	8526                	mv	a0,s1
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	de6080e7          	jalr	-538(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    80004c46:	60e2                	ld	ra,24(sp)
    80004c48:	6442                	ld	s0,16(sp)
    80004c4a:	64a2                	ld	s1,8(sp)
    80004c4c:	6902                	ld	s2,0(sp)
    80004c4e:	6105                	addi	sp,sp,32
    80004c50:	8082                	ret
    pi->readopen = 0;
    80004c52:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c56:	21c48513          	addi	a0,s1,540
    80004c5a:	ffffe097          	auipc	ra,0xffffe
    80004c5e:	a4e080e7          	jalr	-1458(ra) # 800026a8 <wakeup>
    80004c62:	b7e9                	j	80004c2c <pipeclose+0x2c>
    release(&pi->lock);
    80004c64:	8526                	mv	a0,s1
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	05e080e7          	jalr	94(ra) # 80000cc4 <release>
}
    80004c6e:	bfe1                	j	80004c46 <pipeclose+0x46>

0000000080004c70 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c70:	7119                	addi	sp,sp,-128
    80004c72:	fc86                	sd	ra,120(sp)
    80004c74:	f8a2                	sd	s0,112(sp)
    80004c76:	f4a6                	sd	s1,104(sp)
    80004c78:	f0ca                	sd	s2,96(sp)
    80004c7a:	ecce                	sd	s3,88(sp)
    80004c7c:	e8d2                	sd	s4,80(sp)
    80004c7e:	e4d6                	sd	s5,72(sp)
    80004c80:	e0da                	sd	s6,64(sp)
    80004c82:	fc5e                	sd	s7,56(sp)
    80004c84:	f862                	sd	s8,48(sp)
    80004c86:	f466                	sd	s9,40(sp)
    80004c88:	f06a                	sd	s10,32(sp)
    80004c8a:	ec6e                	sd	s11,24(sp)
    80004c8c:	0100                	addi	s0,sp,128
    80004c8e:	84aa                	mv	s1,a0
    80004c90:	8cae                	mv	s9,a1
    80004c92:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c94:	ffffd097          	auipc	ra,0xffffd
    80004c98:	e7e080e7          	jalr	-386(ra) # 80001b12 <myproc>
    80004c9c:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004c9e:	8526                	mv	a0,s1
    80004ca0:	ffffc097          	auipc	ra,0xffffc
    80004ca4:	f70080e7          	jalr	-144(ra) # 80000c10 <acquire>
  for(i = 0; i < n; i++){
    80004ca8:	0d605963          	blez	s6,80004d7a <pipewrite+0x10a>
    80004cac:	89a6                	mv	s3,s1
    80004cae:	3b7d                	addiw	s6,s6,-1
    80004cb0:	1b02                	slli	s6,s6,0x20
    80004cb2:	020b5b13          	srli	s6,s6,0x20
    80004cb6:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004cb8:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cbc:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cc0:	5dfd                	li	s11,-1
    80004cc2:	000b8d1b          	sext.w	s10,s7
    80004cc6:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004cc8:	2184a783          	lw	a5,536(s1)
    80004ccc:	21c4a703          	lw	a4,540(s1)
    80004cd0:	2007879b          	addiw	a5,a5,512
    80004cd4:	02f71b63          	bne	a4,a5,80004d0a <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004cd8:	2204a783          	lw	a5,544(s1)
    80004cdc:	cbad                	beqz	a5,80004d4e <pipewrite+0xde>
    80004cde:	03092783          	lw	a5,48(s2)
    80004ce2:	e7b5                	bnez	a5,80004d4e <pipewrite+0xde>
      wakeup(&pi->nread);
    80004ce4:	8556                	mv	a0,s5
    80004ce6:	ffffe097          	auipc	ra,0xffffe
    80004cea:	9c2080e7          	jalr	-1598(ra) # 800026a8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cee:	85ce                	mv	a1,s3
    80004cf0:	8552                	mv	a0,s4
    80004cf2:	ffffe097          	auipc	ra,0xffffe
    80004cf6:	830080e7          	jalr	-2000(ra) # 80002522 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004cfa:	2184a783          	lw	a5,536(s1)
    80004cfe:	21c4a703          	lw	a4,540(s1)
    80004d02:	2007879b          	addiw	a5,a5,512
    80004d06:	fcf709e3          	beq	a4,a5,80004cd8 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d0a:	4685                	li	a3,1
    80004d0c:	019b8633          	add	a2,s7,s9
    80004d10:	f8f40593          	addi	a1,s0,-113
    80004d14:	05093503          	ld	a0,80(s2)
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	c36080e7          	jalr	-970(ra) # 8000194e <copyin>
    80004d20:	05b50e63          	beq	a0,s11,80004d7c <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d24:	21c4a783          	lw	a5,540(s1)
    80004d28:	0017871b          	addiw	a4,a5,1
    80004d2c:	20e4ae23          	sw	a4,540(s1)
    80004d30:	1ff7f793          	andi	a5,a5,511
    80004d34:	97a6                	add	a5,a5,s1
    80004d36:	f8f44703          	lbu	a4,-113(s0)
    80004d3a:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004d3e:	001d0c1b          	addiw	s8,s10,1
    80004d42:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004d46:	036b8b63          	beq	s7,s6,80004d7c <pipewrite+0x10c>
    80004d4a:	8bbe                	mv	s7,a5
    80004d4c:	bf9d                	j	80004cc2 <pipewrite+0x52>
        release(&pi->lock);
    80004d4e:	8526                	mv	a0,s1
    80004d50:	ffffc097          	auipc	ra,0xffffc
    80004d54:	f74080e7          	jalr	-140(ra) # 80000cc4 <release>
        return -1;
    80004d58:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004d5a:	8562                	mv	a0,s8
    80004d5c:	70e6                	ld	ra,120(sp)
    80004d5e:	7446                	ld	s0,112(sp)
    80004d60:	74a6                	ld	s1,104(sp)
    80004d62:	7906                	ld	s2,96(sp)
    80004d64:	69e6                	ld	s3,88(sp)
    80004d66:	6a46                	ld	s4,80(sp)
    80004d68:	6aa6                	ld	s5,72(sp)
    80004d6a:	6b06                	ld	s6,64(sp)
    80004d6c:	7be2                	ld	s7,56(sp)
    80004d6e:	7c42                	ld	s8,48(sp)
    80004d70:	7ca2                	ld	s9,40(sp)
    80004d72:	7d02                	ld	s10,32(sp)
    80004d74:	6de2                	ld	s11,24(sp)
    80004d76:	6109                	addi	sp,sp,128
    80004d78:	8082                	ret
  for(i = 0; i < n; i++){
    80004d7a:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004d7c:	21848513          	addi	a0,s1,536
    80004d80:	ffffe097          	auipc	ra,0xffffe
    80004d84:	928080e7          	jalr	-1752(ra) # 800026a8 <wakeup>
  release(&pi->lock);
    80004d88:	8526                	mv	a0,s1
    80004d8a:	ffffc097          	auipc	ra,0xffffc
    80004d8e:	f3a080e7          	jalr	-198(ra) # 80000cc4 <release>
  return i;
    80004d92:	b7e1                	j	80004d5a <pipewrite+0xea>

0000000080004d94 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d94:	715d                	addi	sp,sp,-80
    80004d96:	e486                	sd	ra,72(sp)
    80004d98:	e0a2                	sd	s0,64(sp)
    80004d9a:	fc26                	sd	s1,56(sp)
    80004d9c:	f84a                	sd	s2,48(sp)
    80004d9e:	f44e                	sd	s3,40(sp)
    80004da0:	f052                	sd	s4,32(sp)
    80004da2:	ec56                	sd	s5,24(sp)
    80004da4:	e85a                	sd	s6,16(sp)
    80004da6:	0880                	addi	s0,sp,80
    80004da8:	84aa                	mv	s1,a0
    80004daa:	892e                	mv	s2,a1
    80004dac:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dae:	ffffd097          	auipc	ra,0xffffd
    80004db2:	d64080e7          	jalr	-668(ra) # 80001b12 <myproc>
    80004db6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004db8:	8b26                	mv	s6,s1
    80004dba:	8526                	mv	a0,s1
    80004dbc:	ffffc097          	auipc	ra,0xffffc
    80004dc0:	e54080e7          	jalr	-428(ra) # 80000c10 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc4:	2184a703          	lw	a4,536(s1)
    80004dc8:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dcc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dd0:	02f71463          	bne	a4,a5,80004df8 <piperead+0x64>
    80004dd4:	2244a783          	lw	a5,548(s1)
    80004dd8:	c385                	beqz	a5,80004df8 <piperead+0x64>
    if(pr->killed){
    80004dda:	030a2783          	lw	a5,48(s4)
    80004dde:	ebc1                	bnez	a5,80004e6e <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004de0:	85da                	mv	a1,s6
    80004de2:	854e                	mv	a0,s3
    80004de4:	ffffd097          	auipc	ra,0xffffd
    80004de8:	73e080e7          	jalr	1854(ra) # 80002522 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dec:	2184a703          	lw	a4,536(s1)
    80004df0:	21c4a783          	lw	a5,540(s1)
    80004df4:	fef700e3          	beq	a4,a5,80004dd4 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004df8:	09505263          	blez	s5,80004e7c <piperead+0xe8>
    80004dfc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dfe:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004e00:	2184a783          	lw	a5,536(s1)
    80004e04:	21c4a703          	lw	a4,540(s1)
    80004e08:	02f70d63          	beq	a4,a5,80004e42 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e0c:	0017871b          	addiw	a4,a5,1
    80004e10:	20e4ac23          	sw	a4,536(s1)
    80004e14:	1ff7f793          	andi	a5,a5,511
    80004e18:	97a6                	add	a5,a5,s1
    80004e1a:	0187c783          	lbu	a5,24(a5)
    80004e1e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e22:	4685                	li	a3,1
    80004e24:	fbf40613          	addi	a2,s0,-65
    80004e28:	85ca                	mv	a1,s2
    80004e2a:	050a3503          	ld	a0,80(s4)
    80004e2e:	ffffd097          	auipc	ra,0xffffd
    80004e32:	a94080e7          	jalr	-1388(ra) # 800018c2 <copyout>
    80004e36:	01650663          	beq	a0,s6,80004e42 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e3a:	2985                	addiw	s3,s3,1
    80004e3c:	0905                	addi	s2,s2,1
    80004e3e:	fd3a91e3          	bne	s5,s3,80004e00 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e42:	21c48513          	addi	a0,s1,540
    80004e46:	ffffe097          	auipc	ra,0xffffe
    80004e4a:	862080e7          	jalr	-1950(ra) # 800026a8 <wakeup>
  release(&pi->lock);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	ffffc097          	auipc	ra,0xffffc
    80004e54:	e74080e7          	jalr	-396(ra) # 80000cc4 <release>
  return i;
}
    80004e58:	854e                	mv	a0,s3
    80004e5a:	60a6                	ld	ra,72(sp)
    80004e5c:	6406                	ld	s0,64(sp)
    80004e5e:	74e2                	ld	s1,56(sp)
    80004e60:	7942                	ld	s2,48(sp)
    80004e62:	79a2                	ld	s3,40(sp)
    80004e64:	7a02                	ld	s4,32(sp)
    80004e66:	6ae2                	ld	s5,24(sp)
    80004e68:	6b42                	ld	s6,16(sp)
    80004e6a:	6161                	addi	sp,sp,80
    80004e6c:	8082                	ret
      release(&pi->lock);
    80004e6e:	8526                	mv	a0,s1
    80004e70:	ffffc097          	auipc	ra,0xffffc
    80004e74:	e54080e7          	jalr	-428(ra) # 80000cc4 <release>
      return -1;
    80004e78:	59fd                	li	s3,-1
    80004e7a:	bff9                	j	80004e58 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e7c:	4981                	li	s3,0
    80004e7e:	b7d1                	j	80004e42 <piperead+0xae>

0000000080004e80 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e80:	df010113          	addi	sp,sp,-528
    80004e84:	20113423          	sd	ra,520(sp)
    80004e88:	20813023          	sd	s0,512(sp)
    80004e8c:	ffa6                	sd	s1,504(sp)
    80004e8e:	fbca                	sd	s2,496(sp)
    80004e90:	f7ce                	sd	s3,488(sp)
    80004e92:	f3d2                	sd	s4,480(sp)
    80004e94:	efd6                	sd	s5,472(sp)
    80004e96:	ebda                	sd	s6,464(sp)
    80004e98:	e7de                	sd	s7,456(sp)
    80004e9a:	e3e2                	sd	s8,448(sp)
    80004e9c:	ff66                	sd	s9,440(sp)
    80004e9e:	fb6a                	sd	s10,432(sp)
    80004ea0:	f76e                	sd	s11,424(sp)
    80004ea2:	0c00                	addi	s0,sp,528
    80004ea4:	84aa                	mv	s1,a0
    80004ea6:	dea43c23          	sd	a0,-520(s0)
    80004eaa:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004eae:	ffffd097          	auipc	ra,0xffffd
    80004eb2:	c64080e7          	jalr	-924(ra) # 80001b12 <myproc>
    80004eb6:	892a                	mv	s2,a0

  begin_op();
    80004eb8:	fffff097          	auipc	ra,0xfffff
    80004ebc:	446080e7          	jalr	1094(ra) # 800042fe <begin_op>

  if((ip = namei(path)) == 0){
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	230080e7          	jalr	560(ra) # 800040f2 <namei>
    80004eca:	c92d                	beqz	a0,80004f3c <exec+0xbc>
    80004ecc:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ece:	fffff097          	auipc	ra,0xfffff
    80004ed2:	a74080e7          	jalr	-1420(ra) # 80003942 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ed6:	04000713          	li	a4,64
    80004eda:	4681                	li	a3,0
    80004edc:	e4840613          	addi	a2,s0,-440
    80004ee0:	4581                	li	a1,0
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	fffff097          	auipc	ra,0xfffff
    80004ee8:	d12080e7          	jalr	-750(ra) # 80003bf6 <readi>
    80004eec:	04000793          	li	a5,64
    80004ef0:	00f51a63          	bne	a0,a5,80004f04 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004ef4:	e4842703          	lw	a4,-440(s0)
    80004ef8:	464c47b7          	lui	a5,0x464c4
    80004efc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f00:	04f70463          	beq	a4,a5,80004f48 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f04:	8526                	mv	a0,s1
    80004f06:	fffff097          	auipc	ra,0xfffff
    80004f0a:	c9e080e7          	jalr	-866(ra) # 80003ba4 <iunlockput>
    end_op();
    80004f0e:	fffff097          	auipc	ra,0xfffff
    80004f12:	470080e7          	jalr	1136(ra) # 8000437e <end_op>
  }
  return -1;
    80004f16:	557d                	li	a0,-1
}
    80004f18:	20813083          	ld	ra,520(sp)
    80004f1c:	20013403          	ld	s0,512(sp)
    80004f20:	74fe                	ld	s1,504(sp)
    80004f22:	795e                	ld	s2,496(sp)
    80004f24:	79be                	ld	s3,488(sp)
    80004f26:	7a1e                	ld	s4,480(sp)
    80004f28:	6afe                	ld	s5,472(sp)
    80004f2a:	6b5e                	ld	s6,464(sp)
    80004f2c:	6bbe                	ld	s7,456(sp)
    80004f2e:	6c1e                	ld	s8,448(sp)
    80004f30:	7cfa                	ld	s9,440(sp)
    80004f32:	7d5a                	ld	s10,432(sp)
    80004f34:	7dba                	ld	s11,424(sp)
    80004f36:	21010113          	addi	sp,sp,528
    80004f3a:	8082                	ret
    end_op();
    80004f3c:	fffff097          	auipc	ra,0xfffff
    80004f40:	442080e7          	jalr	1090(ra) # 8000437e <end_op>
    return -1;
    80004f44:	557d                	li	a0,-1
    80004f46:	bfc9                	j	80004f18 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f48:	854a                	mv	a0,s2
    80004f4a:	ffffd097          	auipc	ra,0xffffd
    80004f4e:	d52080e7          	jalr	-686(ra) # 80001c9c <proc_pagetable>
    80004f52:	e0a43423          	sd	a0,-504(s0)
    80004f56:	d55d                	beqz	a0,80004f04 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f58:	e6842983          	lw	s3,-408(s0)
    80004f5c:	e8045783          	lhu	a5,-384(s0)
    80004f60:	c7b5                	beqz	a5,80004fcc <exec+0x14c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f62:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f64:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    80004f66:	6c05                	lui	s8,0x1
    80004f68:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004f6c:	def43823          	sd	a5,-528(s0)
    80004f70:	a4b5                	j	800051dc <exec+0x35c>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f72:	00003517          	auipc	a0,0x3
    80004f76:	7ee50513          	addi	a0,a0,2030 # 80008760 <syscalls+0x290>
    80004f7a:	ffffb097          	auipc	ra,0xffffb
    80004f7e:	5ce080e7          	jalr	1486(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f82:	8756                	mv	a4,s5
    80004f84:	012d86bb          	addw	a3,s11,s2
    80004f88:	4581                	li	a1,0
    80004f8a:	8526                	mv	a0,s1
    80004f8c:	fffff097          	auipc	ra,0xfffff
    80004f90:	c6a080e7          	jalr	-918(ra) # 80003bf6 <readi>
    80004f94:	2501                	sext.w	a0,a0
    80004f96:	1eaa9d63          	bne	s5,a0,80005190 <exec+0x310>
  for(i = 0; i < sz; i += PGSIZE){
    80004f9a:	6785                	lui	a5,0x1
    80004f9c:	0127893b          	addw	s2,a5,s2
    80004fa0:	77fd                	lui	a5,0xfffff
    80004fa2:	01478a3b          	addw	s4,a5,s4
    80004fa6:	21997f63          	bgeu	s2,s9,800051c4 <exec+0x344>
    pa = walkaddr(pagetable, va + i);
    80004faa:	02091593          	slli	a1,s2,0x20
    80004fae:	9181                	srli	a1,a1,0x20
    80004fb0:	95ea                	add	a1,a1,s10
    80004fb2:	e0843503          	ld	a0,-504(s0)
    80004fb6:	ffffc097          	auipc	ra,0xffffc
    80004fba:	202080e7          	jalr	514(ra) # 800011b8 <walkaddr>
    80004fbe:	862a                	mv	a2,a0
    if(pa == 0)
    80004fc0:	d94d                	beqz	a0,80004f72 <exec+0xf2>
      n = PGSIZE;
    80004fc2:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004fc4:	fb8a7fe3          	bgeu	s4,s8,80004f82 <exec+0x102>
      n = sz - i;
    80004fc8:	8ad2                	mv	s5,s4
    80004fca:	bf65                	j	80004f82 <exec+0x102>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004fcc:	4901                	li	s2,0
  iunlockput(ip);
    80004fce:	8526                	mv	a0,s1
    80004fd0:	fffff097          	auipc	ra,0xfffff
    80004fd4:	bd4080e7          	jalr	-1068(ra) # 80003ba4 <iunlockput>
  end_op();
    80004fd8:	fffff097          	auipc	ra,0xfffff
    80004fdc:	3a6080e7          	jalr	934(ra) # 8000437e <end_op>
  p = myproc();
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	b32080e7          	jalr	-1230(ra) # 80001b12 <myproc>
    80004fe8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004fea:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004fee:	6b05                	lui	s6,0x1
    80004ff0:	1b7d                	addi	s6,s6,-1
    80004ff2:	995a                	add	s2,s2,s6
    80004ff4:	7b7d                	lui	s6,0xfffff
    80004ff6:	01697b33          	and	s6,s2,s6
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ffa:	6609                	lui	a2,0x2
    80004ffc:	965a                	add	a2,a2,s6
    80004ffe:	85da                	mv	a1,s6
    80005000:	e0843903          	ld	s2,-504(s0)
    80005004:	854a                	mv	a0,s2
    80005006:	ffffc097          	auipc	ra,0xffffc
    8000500a:	66c080e7          	jalr	1644(ra) # 80001672 <uvmalloc>
    8000500e:	8baa                	mv	s7,a0
  ip = 0;
    80005010:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005012:	16050f63          	beqz	a0,80005190 <exec+0x310>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005016:	75f9                	lui	a1,0xffffe
    80005018:	95aa                	add	a1,a1,a0
    8000501a:	854a                	mv	a0,s2
    8000501c:	ffffd097          	auipc	ra,0xffffd
    80005020:	874080e7          	jalr	-1932(ra) # 80001890 <uvmclear>
  stackbase = sp - PGSIZE;
    80005024:	7b7d                	lui	s6,0xfffff
    80005026:	9b5e                	add	s6,s6,s7
  for(argc = 0; argv[argc]; argc++) {
    80005028:	e0043783          	ld	a5,-512(s0)
    8000502c:	6388                	ld	a0,0(a5)
    8000502e:	c535                	beqz	a0,8000509a <exec+0x21a>
    80005030:	e8840993          	addi	s3,s0,-376
    80005034:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005038:	895e                	mv	s2,s7
    sp -= strlen(argv[argc]) + 1;
    8000503a:	ffffc097          	auipc	ra,0xffffc
    8000503e:	e5a080e7          	jalr	-422(ra) # 80000e94 <strlen>
    80005042:	2505                	addiw	a0,a0,1
    80005044:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005048:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000504c:	17696363          	bltu	s2,s6,800051b2 <exec+0x332>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005050:	e0043c03          	ld	s8,-512(s0)
    80005054:	000c3a03          	ld	s4,0(s8)
    80005058:	8552                	mv	a0,s4
    8000505a:	ffffc097          	auipc	ra,0xffffc
    8000505e:	e3a080e7          	jalr	-454(ra) # 80000e94 <strlen>
    80005062:	0015069b          	addiw	a3,a0,1
    80005066:	8652                	mv	a2,s4
    80005068:	85ca                	mv	a1,s2
    8000506a:	e0843503          	ld	a0,-504(s0)
    8000506e:	ffffd097          	auipc	ra,0xffffd
    80005072:	854080e7          	jalr	-1964(ra) # 800018c2 <copyout>
    80005076:	14054163          	bltz	a0,800051b8 <exec+0x338>
    ustack[argc] = sp;
    8000507a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000507e:	0485                	addi	s1,s1,1
    80005080:	008c0793          	addi	a5,s8,8
    80005084:	e0f43023          	sd	a5,-512(s0)
    80005088:	008c3503          	ld	a0,8(s8)
    8000508c:	c909                	beqz	a0,8000509e <exec+0x21e>
    if(argc >= MAXARG)
    8000508e:	09a1                	addi	s3,s3,8
    80005090:	fb3c95e3          	bne	s9,s3,8000503a <exec+0x1ba>
  sz = sz1;
    80005094:	8b5e                	mv	s6,s7
  ip = 0;
    80005096:	4481                	li	s1,0
    80005098:	a8e5                	j	80005190 <exec+0x310>
  sp = sz;
    8000509a:	895e                	mv	s2,s7
  for(argc = 0; argv[argc]; argc++) {
    8000509c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000509e:	00349793          	slli	a5,s1,0x3
    800050a2:	f9040713          	addi	a4,s0,-112
    800050a6:	97ba                	add	a5,a5,a4
    800050a8:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7ed8>
  sp -= (argc+1) * sizeof(uint64);
    800050ac:	00148693          	addi	a3,s1,1
    800050b0:	068e                	slli	a3,a3,0x3
    800050b2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050b6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050ba:	01697563          	bgeu	s2,s6,800050c4 <exec+0x244>
  sz = sz1;
    800050be:	8b5e                	mv	s6,s7
  ip = 0;
    800050c0:	4481                	li	s1,0
    800050c2:	a0f9                	j	80005190 <exec+0x310>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050c4:	e8840613          	addi	a2,s0,-376
    800050c8:	85ca                	mv	a1,s2
    800050ca:	e0843983          	ld	s3,-504(s0)
    800050ce:	854e                	mv	a0,s3
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	7f2080e7          	jalr	2034(ra) # 800018c2 <copyout>
    800050d8:	0e054363          	bltz	a0,800051be <exec+0x33e>
  uvmunmap(p->kernel_pagetable, 0, PGROUNDUP(oldsz)/PGSIZE, 0);
    800050dc:	6605                	lui	a2,0x1
    800050de:	167d                	addi	a2,a2,-1
    800050e0:	966a                	add	a2,a2,s10
    800050e2:	4681                	li	a3,0
    800050e4:	8231                	srli	a2,a2,0xc
    800050e6:	4581                	li	a1,0
    800050e8:	168ab503          	ld	a0,360(s5)
    800050ec:	ffffc097          	auipc	ra,0xffffc
    800050f0:	3da080e7          	jalr	986(ra) # 800014c6 <uvmunmap>
  uvm2kvm(pagetable, p->kernel_pagetable, 0, sz);
    800050f4:	86de                	mv	a3,s7
    800050f6:	4601                	li	a2,0
    800050f8:	168ab583          	ld	a1,360(s5)
    800050fc:	854e                	mv	a0,s3
    800050fe:	ffffd097          	auipc	ra,0xffffd
    80005102:	880080e7          	jalr	-1920(ra) # 8000197e <uvm2kvm>
  p->trapframe->a1 = sp;
    80005106:	058ab783          	ld	a5,88(s5)
    8000510a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000510e:	df843783          	ld	a5,-520(s0)
    80005112:	0007c703          	lbu	a4,0(a5)
    80005116:	cf11                	beqz	a4,80005132 <exec+0x2b2>
    80005118:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000511a:	02f00693          	li	a3,47
    8000511e:	a039                	j	8000512c <exec+0x2ac>
      last = s+1;
    80005120:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005124:	0785                	addi	a5,a5,1
    80005126:	fff7c703          	lbu	a4,-1(a5)
    8000512a:	c701                	beqz	a4,80005132 <exec+0x2b2>
    if(*s == '/')
    8000512c:	fed71ce3          	bne	a4,a3,80005124 <exec+0x2a4>
    80005130:	bfc5                	j	80005120 <exec+0x2a0>
  safestrcpy(p->name, last, sizeof(p->name));
    80005132:	4641                	li	a2,16
    80005134:	df843583          	ld	a1,-520(s0)
    80005138:	158a8513          	addi	a0,s5,344
    8000513c:	ffffc097          	auipc	ra,0xffffc
    80005140:	d26080e7          	jalr	-730(ra) # 80000e62 <safestrcpy>
  oldpagetable = p->pagetable;
    80005144:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005148:	e0843783          	ld	a5,-504(s0)
    8000514c:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    80005150:	057ab423          	sd	s7,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005154:	058ab783          	ld	a5,88(s5)
    80005158:	e6043703          	ld	a4,-416(s0)
    8000515c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000515e:	058ab783          	ld	a5,88(s5)
    80005162:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005166:	85ea                	mv	a1,s10
    80005168:	ffffd097          	auipc	ra,0xffffd
    8000516c:	bd0080e7          	jalr	-1072(ra) # 80001d38 <proc_freepagetable>
  if (p->pid == 1) {
    80005170:	038aa703          	lw	a4,56(s5)
    80005174:	4785                	li	a5,1
    80005176:	00f70563          	beq	a4,a5,80005180 <exec+0x300>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000517a:	0004851b          	sext.w	a0,s1
    8000517e:	bb69                	j	80004f18 <exec+0x98>
      vmprint(p->pagetable);
    80005180:	050ab503          	ld	a0,80(s5)
    80005184:	ffffc097          	auipc	ra,0xffffc
    80005188:	f36080e7          	jalr	-202(ra) # 800010ba <vmprint>
    8000518c:	b7fd                	j	8000517a <exec+0x2fa>
    8000518e:	8b4a                	mv	s6,s2
    proc_freepagetable(pagetable, sz);
    80005190:	85da                	mv	a1,s6
    80005192:	e0843503          	ld	a0,-504(s0)
    80005196:	ffffd097          	auipc	ra,0xffffd
    8000519a:	ba2080e7          	jalr	-1118(ra) # 80001d38 <proc_freepagetable>
  if(ip){
    8000519e:	d60493e3          	bnez	s1,80004f04 <exec+0x84>
  return -1;
    800051a2:	557d                	li	a0,-1
    800051a4:	bb95                	j	80004f18 <exec+0x98>
    800051a6:	8b4a                	mv	s6,s2
    800051a8:	b7e5                	j	80005190 <exec+0x310>
    800051aa:	8b4a                	mv	s6,s2
    800051ac:	b7d5                	j	80005190 <exec+0x310>
    800051ae:	8b4a                	mv	s6,s2
    800051b0:	b7c5                	j	80005190 <exec+0x310>
  sz = sz1;
    800051b2:	8b5e                	mv	s6,s7
  ip = 0;
    800051b4:	4481                	li	s1,0
    800051b6:	bfe9                	j	80005190 <exec+0x310>
  sz = sz1;
    800051b8:	8b5e                	mv	s6,s7
  ip = 0;
    800051ba:	4481                	li	s1,0
    800051bc:	bfd1                	j	80005190 <exec+0x310>
  sz = sz1;
    800051be:	8b5e                	mv	s6,s7
  ip = 0;
    800051c0:	4481                	li	s1,0
    800051c2:	b7f9                	j	80005190 <exec+0x310>
    if (sz1 >= PLIC)
    800051c4:	0c0007b7          	lui	a5,0xc000
    800051c8:	fcfb74e3          	bgeu	s6,a5,80005190 <exec+0x310>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051cc:	895a                	mv	s2,s6
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051ce:	2b85                	addiw	s7,s7,1
    800051d0:	0389899b          	addiw	s3,s3,56
    800051d4:	e8045783          	lhu	a5,-384(s0)
    800051d8:	defbdbe3          	bge	s7,a5,80004fce <exec+0x14e>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051dc:	2981                	sext.w	s3,s3
    800051de:	03800713          	li	a4,56
    800051e2:	86ce                	mv	a3,s3
    800051e4:	e1040613          	addi	a2,s0,-496
    800051e8:	4581                	li	a1,0
    800051ea:	8526                	mv	a0,s1
    800051ec:	fffff097          	auipc	ra,0xfffff
    800051f0:	a0a080e7          	jalr	-1526(ra) # 80003bf6 <readi>
    800051f4:	03800793          	li	a5,56
    800051f8:	f8f51be3          	bne	a0,a5,8000518e <exec+0x30e>
    if(ph.type != ELF_PROG_LOAD)
    800051fc:	e1042783          	lw	a5,-496(s0)
    80005200:	4705                	li	a4,1
    80005202:	fce796e3          	bne	a5,a4,800051ce <exec+0x34e>
    if(ph.memsz < ph.filesz)
    80005206:	e3843603          	ld	a2,-456(s0)
    8000520a:	e3043783          	ld	a5,-464(s0)
    8000520e:	f8f66ce3          	bltu	a2,a5,800051a6 <exec+0x326>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005212:	e2043783          	ld	a5,-480(s0)
    80005216:	963e                	add	a2,a2,a5
    80005218:	f8f669e3          	bltu	a2,a5,800051aa <exec+0x32a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000521c:	85ca                	mv	a1,s2
    8000521e:	e0843503          	ld	a0,-504(s0)
    80005222:	ffffc097          	auipc	ra,0xffffc
    80005226:	450080e7          	jalr	1104(ra) # 80001672 <uvmalloc>
    8000522a:	8b2a                	mv	s6,a0
    8000522c:	d149                	beqz	a0,800051ae <exec+0x32e>
    if(ph.vaddr % PGSIZE != 0)
    8000522e:	e2043d03          	ld	s10,-480(s0)
    80005232:	df043783          	ld	a5,-528(s0)
    80005236:	00fd77b3          	and	a5,s10,a5
    8000523a:	fbb9                	bnez	a5,80005190 <exec+0x310>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000523c:	e1842d83          	lw	s11,-488(s0)
    80005240:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005244:	f80c80e3          	beqz	s9,800051c4 <exec+0x344>
    80005248:	8a66                	mv	s4,s9
    8000524a:	4901                	li	s2,0
    8000524c:	bbb9                	j	80004faa <exec+0x12a>

000000008000524e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000524e:	7179                	addi	sp,sp,-48
    80005250:	f406                	sd	ra,40(sp)
    80005252:	f022                	sd	s0,32(sp)
    80005254:	ec26                	sd	s1,24(sp)
    80005256:	e84a                	sd	s2,16(sp)
    80005258:	1800                	addi	s0,sp,48
    8000525a:	892e                	mv	s2,a1
    8000525c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000525e:	fdc40593          	addi	a1,s0,-36
    80005262:	ffffe097          	auipc	ra,0xffffe
    80005266:	b6e080e7          	jalr	-1170(ra) # 80002dd0 <argint>
    8000526a:	04054063          	bltz	a0,800052aa <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000526e:	fdc42703          	lw	a4,-36(s0)
    80005272:	47bd                	li	a5,15
    80005274:	02e7ed63          	bltu	a5,a4,800052ae <argfd+0x60>
    80005278:	ffffd097          	auipc	ra,0xffffd
    8000527c:	89a080e7          	jalr	-1894(ra) # 80001b12 <myproc>
    80005280:	fdc42703          	lw	a4,-36(s0)
    80005284:	01a70793          	addi	a5,a4,26
    80005288:	078e                	slli	a5,a5,0x3
    8000528a:	953e                	add	a0,a0,a5
    8000528c:	611c                	ld	a5,0(a0)
    8000528e:	c395                	beqz	a5,800052b2 <argfd+0x64>
    return -1;
  if(pfd)
    80005290:	00090463          	beqz	s2,80005298 <argfd+0x4a>
    *pfd = fd;
    80005294:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005298:	4501                	li	a0,0
  if(pf)
    8000529a:	c091                	beqz	s1,8000529e <argfd+0x50>
    *pf = f;
    8000529c:	e09c                	sd	a5,0(s1)
}
    8000529e:	70a2                	ld	ra,40(sp)
    800052a0:	7402                	ld	s0,32(sp)
    800052a2:	64e2                	ld	s1,24(sp)
    800052a4:	6942                	ld	s2,16(sp)
    800052a6:	6145                	addi	sp,sp,48
    800052a8:	8082                	ret
    return -1;
    800052aa:	557d                	li	a0,-1
    800052ac:	bfcd                	j	8000529e <argfd+0x50>
    return -1;
    800052ae:	557d                	li	a0,-1
    800052b0:	b7fd                	j	8000529e <argfd+0x50>
    800052b2:	557d                	li	a0,-1
    800052b4:	b7ed                	j	8000529e <argfd+0x50>

00000000800052b6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052b6:	1101                	addi	sp,sp,-32
    800052b8:	ec06                	sd	ra,24(sp)
    800052ba:	e822                	sd	s0,16(sp)
    800052bc:	e426                	sd	s1,8(sp)
    800052be:	1000                	addi	s0,sp,32
    800052c0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052c2:	ffffd097          	auipc	ra,0xffffd
    800052c6:	850080e7          	jalr	-1968(ra) # 80001b12 <myproc>
    800052ca:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052cc:	0d050793          	addi	a5,a0,208
    800052d0:	4501                	li	a0,0
    800052d2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052d4:	6398                	ld	a4,0(a5)
    800052d6:	cb19                	beqz	a4,800052ec <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052d8:	2505                	addiw	a0,a0,1
    800052da:	07a1                	addi	a5,a5,8
    800052dc:	fed51ce3          	bne	a0,a3,800052d4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052e0:	557d                	li	a0,-1
}
    800052e2:	60e2                	ld	ra,24(sp)
    800052e4:	6442                	ld	s0,16(sp)
    800052e6:	64a2                	ld	s1,8(sp)
    800052e8:	6105                	addi	sp,sp,32
    800052ea:	8082                	ret
      p->ofile[fd] = f;
    800052ec:	01a50793          	addi	a5,a0,26
    800052f0:	078e                	slli	a5,a5,0x3
    800052f2:	963e                	add	a2,a2,a5
    800052f4:	e204                	sd	s1,0(a2)
      return fd;
    800052f6:	b7f5                	j	800052e2 <fdalloc+0x2c>

00000000800052f8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052f8:	715d                	addi	sp,sp,-80
    800052fa:	e486                	sd	ra,72(sp)
    800052fc:	e0a2                	sd	s0,64(sp)
    800052fe:	fc26                	sd	s1,56(sp)
    80005300:	f84a                	sd	s2,48(sp)
    80005302:	f44e                	sd	s3,40(sp)
    80005304:	f052                	sd	s4,32(sp)
    80005306:	ec56                	sd	s5,24(sp)
    80005308:	0880                	addi	s0,sp,80
    8000530a:	89ae                	mv	s3,a1
    8000530c:	8ab2                	mv	s5,a2
    8000530e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005310:	fb040593          	addi	a1,s0,-80
    80005314:	fffff097          	auipc	ra,0xfffff
    80005318:	dfc080e7          	jalr	-516(ra) # 80004110 <nameiparent>
    8000531c:	892a                	mv	s2,a0
    8000531e:	12050f63          	beqz	a0,8000545c <create+0x164>
    return 0;

  ilock(dp);
    80005322:	ffffe097          	auipc	ra,0xffffe
    80005326:	620080e7          	jalr	1568(ra) # 80003942 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000532a:	4601                	li	a2,0
    8000532c:	fb040593          	addi	a1,s0,-80
    80005330:	854a                	mv	a0,s2
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	aee080e7          	jalr	-1298(ra) # 80003e20 <dirlookup>
    8000533a:	84aa                	mv	s1,a0
    8000533c:	c921                	beqz	a0,8000538c <create+0x94>
    iunlockput(dp);
    8000533e:	854a                	mv	a0,s2
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	864080e7          	jalr	-1948(ra) # 80003ba4 <iunlockput>
    ilock(ip);
    80005348:	8526                	mv	a0,s1
    8000534a:	ffffe097          	auipc	ra,0xffffe
    8000534e:	5f8080e7          	jalr	1528(ra) # 80003942 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005352:	2981                	sext.w	s3,s3
    80005354:	4789                	li	a5,2
    80005356:	02f99463          	bne	s3,a5,8000537e <create+0x86>
    8000535a:	0444d783          	lhu	a5,68(s1)
    8000535e:	37f9                	addiw	a5,a5,-2
    80005360:	17c2                	slli	a5,a5,0x30
    80005362:	93c1                	srli	a5,a5,0x30
    80005364:	4705                	li	a4,1
    80005366:	00f76c63          	bltu	a4,a5,8000537e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000536a:	8526                	mv	a0,s1
    8000536c:	60a6                	ld	ra,72(sp)
    8000536e:	6406                	ld	s0,64(sp)
    80005370:	74e2                	ld	s1,56(sp)
    80005372:	7942                	ld	s2,48(sp)
    80005374:	79a2                	ld	s3,40(sp)
    80005376:	7a02                	ld	s4,32(sp)
    80005378:	6ae2                	ld	s5,24(sp)
    8000537a:	6161                	addi	sp,sp,80
    8000537c:	8082                	ret
    iunlockput(ip);
    8000537e:	8526                	mv	a0,s1
    80005380:	fffff097          	auipc	ra,0xfffff
    80005384:	824080e7          	jalr	-2012(ra) # 80003ba4 <iunlockput>
    return 0;
    80005388:	4481                	li	s1,0
    8000538a:	b7c5                	j	8000536a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000538c:	85ce                	mv	a1,s3
    8000538e:	00092503          	lw	a0,0(s2)
    80005392:	ffffe097          	auipc	ra,0xffffe
    80005396:	418080e7          	jalr	1048(ra) # 800037aa <ialloc>
    8000539a:	84aa                	mv	s1,a0
    8000539c:	c529                	beqz	a0,800053e6 <create+0xee>
  ilock(ip);
    8000539e:	ffffe097          	auipc	ra,0xffffe
    800053a2:	5a4080e7          	jalr	1444(ra) # 80003942 <ilock>
  ip->major = major;
    800053a6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800053aa:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800053ae:	4785                	li	a5,1
    800053b0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053b4:	8526                	mv	a0,s1
    800053b6:	ffffe097          	auipc	ra,0xffffe
    800053ba:	4c2080e7          	jalr	1218(ra) # 80003878 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053be:	2981                	sext.w	s3,s3
    800053c0:	4785                	li	a5,1
    800053c2:	02f98a63          	beq	s3,a5,800053f6 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800053c6:	40d0                	lw	a2,4(s1)
    800053c8:	fb040593          	addi	a1,s0,-80
    800053cc:	854a                	mv	a0,s2
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	c62080e7          	jalr	-926(ra) # 80004030 <dirlink>
    800053d6:	06054b63          	bltz	a0,8000544c <create+0x154>
  iunlockput(dp);
    800053da:	854a                	mv	a0,s2
    800053dc:	ffffe097          	auipc	ra,0xffffe
    800053e0:	7c8080e7          	jalr	1992(ra) # 80003ba4 <iunlockput>
  return ip;
    800053e4:	b759                	j	8000536a <create+0x72>
    panic("create: ialloc");
    800053e6:	00003517          	auipc	a0,0x3
    800053ea:	39a50513          	addi	a0,a0,922 # 80008780 <syscalls+0x2b0>
    800053ee:	ffffb097          	auipc	ra,0xffffb
    800053f2:	15a080e7          	jalr	346(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    800053f6:	04a95783          	lhu	a5,74(s2)
    800053fa:	2785                	addiw	a5,a5,1
    800053fc:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005400:	854a                	mv	a0,s2
    80005402:	ffffe097          	auipc	ra,0xffffe
    80005406:	476080e7          	jalr	1142(ra) # 80003878 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000540a:	40d0                	lw	a2,4(s1)
    8000540c:	00003597          	auipc	a1,0x3
    80005410:	38458593          	addi	a1,a1,900 # 80008790 <syscalls+0x2c0>
    80005414:	8526                	mv	a0,s1
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	c1a080e7          	jalr	-998(ra) # 80004030 <dirlink>
    8000541e:	00054f63          	bltz	a0,8000543c <create+0x144>
    80005422:	00492603          	lw	a2,4(s2)
    80005426:	00003597          	auipc	a1,0x3
    8000542a:	37258593          	addi	a1,a1,882 # 80008798 <syscalls+0x2c8>
    8000542e:	8526                	mv	a0,s1
    80005430:	fffff097          	auipc	ra,0xfffff
    80005434:	c00080e7          	jalr	-1024(ra) # 80004030 <dirlink>
    80005438:	f80557e3          	bgez	a0,800053c6 <create+0xce>
      panic("create dots");
    8000543c:	00003517          	auipc	a0,0x3
    80005440:	36450513          	addi	a0,a0,868 # 800087a0 <syscalls+0x2d0>
    80005444:	ffffb097          	auipc	ra,0xffffb
    80005448:	104080e7          	jalr	260(ra) # 80000548 <panic>
    panic("create: dirlink");
    8000544c:	00003517          	auipc	a0,0x3
    80005450:	36450513          	addi	a0,a0,868 # 800087b0 <syscalls+0x2e0>
    80005454:	ffffb097          	auipc	ra,0xffffb
    80005458:	0f4080e7          	jalr	244(ra) # 80000548 <panic>
    return 0;
    8000545c:	84aa                	mv	s1,a0
    8000545e:	b731                	j	8000536a <create+0x72>

0000000080005460 <sys_dup>:
{
    80005460:	7179                	addi	sp,sp,-48
    80005462:	f406                	sd	ra,40(sp)
    80005464:	f022                	sd	s0,32(sp)
    80005466:	ec26                	sd	s1,24(sp)
    80005468:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000546a:	fd840613          	addi	a2,s0,-40
    8000546e:	4581                	li	a1,0
    80005470:	4501                	li	a0,0
    80005472:	00000097          	auipc	ra,0x0
    80005476:	ddc080e7          	jalr	-548(ra) # 8000524e <argfd>
    return -1;
    8000547a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000547c:	02054363          	bltz	a0,800054a2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005480:	fd843503          	ld	a0,-40(s0)
    80005484:	00000097          	auipc	ra,0x0
    80005488:	e32080e7          	jalr	-462(ra) # 800052b6 <fdalloc>
    8000548c:	84aa                	mv	s1,a0
    return -1;
    8000548e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005490:	00054963          	bltz	a0,800054a2 <sys_dup+0x42>
  filedup(f);
    80005494:	fd843503          	ld	a0,-40(s0)
    80005498:	fffff097          	auipc	ra,0xfffff
    8000549c:	2e6080e7          	jalr	742(ra) # 8000477e <filedup>
  return fd;
    800054a0:	87a6                	mv	a5,s1
}
    800054a2:	853e                	mv	a0,a5
    800054a4:	70a2                	ld	ra,40(sp)
    800054a6:	7402                	ld	s0,32(sp)
    800054a8:	64e2                	ld	s1,24(sp)
    800054aa:	6145                	addi	sp,sp,48
    800054ac:	8082                	ret

00000000800054ae <sys_read>:
{
    800054ae:	7179                	addi	sp,sp,-48
    800054b0:	f406                	sd	ra,40(sp)
    800054b2:	f022                	sd	s0,32(sp)
    800054b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054b6:	fe840613          	addi	a2,s0,-24
    800054ba:	4581                	li	a1,0
    800054bc:	4501                	li	a0,0
    800054be:	00000097          	auipc	ra,0x0
    800054c2:	d90080e7          	jalr	-624(ra) # 8000524e <argfd>
    return -1;
    800054c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c8:	04054163          	bltz	a0,8000550a <sys_read+0x5c>
    800054cc:	fe440593          	addi	a1,s0,-28
    800054d0:	4509                	li	a0,2
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	8fe080e7          	jalr	-1794(ra) # 80002dd0 <argint>
    return -1;
    800054da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054dc:	02054763          	bltz	a0,8000550a <sys_read+0x5c>
    800054e0:	fd840593          	addi	a1,s0,-40
    800054e4:	4505                	li	a0,1
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	90c080e7          	jalr	-1780(ra) # 80002df2 <argaddr>
    return -1;
    800054ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054f0:	00054d63          	bltz	a0,8000550a <sys_read+0x5c>
  return fileread(f, p, n);
    800054f4:	fe442603          	lw	a2,-28(s0)
    800054f8:	fd843583          	ld	a1,-40(s0)
    800054fc:	fe843503          	ld	a0,-24(s0)
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	40a080e7          	jalr	1034(ra) # 8000490a <fileread>
    80005508:	87aa                	mv	a5,a0
}
    8000550a:	853e                	mv	a0,a5
    8000550c:	70a2                	ld	ra,40(sp)
    8000550e:	7402                	ld	s0,32(sp)
    80005510:	6145                	addi	sp,sp,48
    80005512:	8082                	ret

0000000080005514 <sys_write>:
{
    80005514:	7179                	addi	sp,sp,-48
    80005516:	f406                	sd	ra,40(sp)
    80005518:	f022                	sd	s0,32(sp)
    8000551a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000551c:	fe840613          	addi	a2,s0,-24
    80005520:	4581                	li	a1,0
    80005522:	4501                	li	a0,0
    80005524:	00000097          	auipc	ra,0x0
    80005528:	d2a080e7          	jalr	-726(ra) # 8000524e <argfd>
    return -1;
    8000552c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000552e:	04054163          	bltz	a0,80005570 <sys_write+0x5c>
    80005532:	fe440593          	addi	a1,s0,-28
    80005536:	4509                	li	a0,2
    80005538:	ffffe097          	auipc	ra,0xffffe
    8000553c:	898080e7          	jalr	-1896(ra) # 80002dd0 <argint>
    return -1;
    80005540:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005542:	02054763          	bltz	a0,80005570 <sys_write+0x5c>
    80005546:	fd840593          	addi	a1,s0,-40
    8000554a:	4505                	li	a0,1
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	8a6080e7          	jalr	-1882(ra) # 80002df2 <argaddr>
    return -1;
    80005554:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005556:	00054d63          	bltz	a0,80005570 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000555a:	fe442603          	lw	a2,-28(s0)
    8000555e:	fd843583          	ld	a1,-40(s0)
    80005562:	fe843503          	ld	a0,-24(s0)
    80005566:	fffff097          	auipc	ra,0xfffff
    8000556a:	466080e7          	jalr	1126(ra) # 800049cc <filewrite>
    8000556e:	87aa                	mv	a5,a0
}
    80005570:	853e                	mv	a0,a5
    80005572:	70a2                	ld	ra,40(sp)
    80005574:	7402                	ld	s0,32(sp)
    80005576:	6145                	addi	sp,sp,48
    80005578:	8082                	ret

000000008000557a <sys_close>:
{
    8000557a:	1101                	addi	sp,sp,-32
    8000557c:	ec06                	sd	ra,24(sp)
    8000557e:	e822                	sd	s0,16(sp)
    80005580:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005582:	fe040613          	addi	a2,s0,-32
    80005586:	fec40593          	addi	a1,s0,-20
    8000558a:	4501                	li	a0,0
    8000558c:	00000097          	auipc	ra,0x0
    80005590:	cc2080e7          	jalr	-830(ra) # 8000524e <argfd>
    return -1;
    80005594:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005596:	02054463          	bltz	a0,800055be <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000559a:	ffffc097          	auipc	ra,0xffffc
    8000559e:	578080e7          	jalr	1400(ra) # 80001b12 <myproc>
    800055a2:	fec42783          	lw	a5,-20(s0)
    800055a6:	07e9                	addi	a5,a5,26
    800055a8:	078e                	slli	a5,a5,0x3
    800055aa:	97aa                	add	a5,a5,a0
    800055ac:	0007b023          	sd	zero,0(a5) # c000000 <_entry-0x74000000>
  fileclose(f);
    800055b0:	fe043503          	ld	a0,-32(s0)
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	21c080e7          	jalr	540(ra) # 800047d0 <fileclose>
  return 0;
    800055bc:	4781                	li	a5,0
}
    800055be:	853e                	mv	a0,a5
    800055c0:	60e2                	ld	ra,24(sp)
    800055c2:	6442                	ld	s0,16(sp)
    800055c4:	6105                	addi	sp,sp,32
    800055c6:	8082                	ret

00000000800055c8 <sys_fstat>:
{
    800055c8:	1101                	addi	sp,sp,-32
    800055ca:	ec06                	sd	ra,24(sp)
    800055cc:	e822                	sd	s0,16(sp)
    800055ce:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055d0:	fe840613          	addi	a2,s0,-24
    800055d4:	4581                	li	a1,0
    800055d6:	4501                	li	a0,0
    800055d8:	00000097          	auipc	ra,0x0
    800055dc:	c76080e7          	jalr	-906(ra) # 8000524e <argfd>
    return -1;
    800055e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055e2:	02054563          	bltz	a0,8000560c <sys_fstat+0x44>
    800055e6:	fe040593          	addi	a1,s0,-32
    800055ea:	4505                	li	a0,1
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	806080e7          	jalr	-2042(ra) # 80002df2 <argaddr>
    return -1;
    800055f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055f6:	00054b63          	bltz	a0,8000560c <sys_fstat+0x44>
  return filestat(f, st);
    800055fa:	fe043583          	ld	a1,-32(s0)
    800055fe:	fe843503          	ld	a0,-24(s0)
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	296080e7          	jalr	662(ra) # 80004898 <filestat>
    8000560a:	87aa                	mv	a5,a0
}
    8000560c:	853e                	mv	a0,a5
    8000560e:	60e2                	ld	ra,24(sp)
    80005610:	6442                	ld	s0,16(sp)
    80005612:	6105                	addi	sp,sp,32
    80005614:	8082                	ret

0000000080005616 <sys_link>:
{
    80005616:	7169                	addi	sp,sp,-304
    80005618:	f606                	sd	ra,296(sp)
    8000561a:	f222                	sd	s0,288(sp)
    8000561c:	ee26                	sd	s1,280(sp)
    8000561e:	ea4a                	sd	s2,272(sp)
    80005620:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005622:	08000613          	li	a2,128
    80005626:	ed040593          	addi	a1,s0,-304
    8000562a:	4501                	li	a0,0
    8000562c:	ffffd097          	auipc	ra,0xffffd
    80005630:	7e8080e7          	jalr	2024(ra) # 80002e14 <argstr>
    return -1;
    80005634:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005636:	10054e63          	bltz	a0,80005752 <sys_link+0x13c>
    8000563a:	08000613          	li	a2,128
    8000563e:	f5040593          	addi	a1,s0,-176
    80005642:	4505                	li	a0,1
    80005644:	ffffd097          	auipc	ra,0xffffd
    80005648:	7d0080e7          	jalr	2000(ra) # 80002e14 <argstr>
    return -1;
    8000564c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000564e:	10054263          	bltz	a0,80005752 <sys_link+0x13c>
  begin_op();
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	cac080e7          	jalr	-852(ra) # 800042fe <begin_op>
  if((ip = namei(old)) == 0){
    8000565a:	ed040513          	addi	a0,s0,-304
    8000565e:	fffff097          	auipc	ra,0xfffff
    80005662:	a94080e7          	jalr	-1388(ra) # 800040f2 <namei>
    80005666:	84aa                	mv	s1,a0
    80005668:	c551                	beqz	a0,800056f4 <sys_link+0xde>
  ilock(ip);
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	2d8080e7          	jalr	728(ra) # 80003942 <ilock>
  if(ip->type == T_DIR){
    80005672:	04449703          	lh	a4,68(s1)
    80005676:	4785                	li	a5,1
    80005678:	08f70463          	beq	a4,a5,80005700 <sys_link+0xea>
  ip->nlink++;
    8000567c:	04a4d783          	lhu	a5,74(s1)
    80005680:	2785                	addiw	a5,a5,1
    80005682:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005686:	8526                	mv	a0,s1
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	1f0080e7          	jalr	496(ra) # 80003878 <iupdate>
  iunlock(ip);
    80005690:	8526                	mv	a0,s1
    80005692:	ffffe097          	auipc	ra,0xffffe
    80005696:	372080e7          	jalr	882(ra) # 80003a04 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000569a:	fd040593          	addi	a1,s0,-48
    8000569e:	f5040513          	addi	a0,s0,-176
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	a6e080e7          	jalr	-1426(ra) # 80004110 <nameiparent>
    800056aa:	892a                	mv	s2,a0
    800056ac:	c935                	beqz	a0,80005720 <sys_link+0x10a>
  ilock(dp);
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	294080e7          	jalr	660(ra) # 80003942 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056b6:	00092703          	lw	a4,0(s2)
    800056ba:	409c                	lw	a5,0(s1)
    800056bc:	04f71d63          	bne	a4,a5,80005716 <sys_link+0x100>
    800056c0:	40d0                	lw	a2,4(s1)
    800056c2:	fd040593          	addi	a1,s0,-48
    800056c6:	854a                	mv	a0,s2
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	968080e7          	jalr	-1688(ra) # 80004030 <dirlink>
    800056d0:	04054363          	bltz	a0,80005716 <sys_link+0x100>
  iunlockput(dp);
    800056d4:	854a                	mv	a0,s2
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	4ce080e7          	jalr	1230(ra) # 80003ba4 <iunlockput>
  iput(ip);
    800056de:	8526                	mv	a0,s1
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	41c080e7          	jalr	1052(ra) # 80003afc <iput>
  end_op();
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	c96080e7          	jalr	-874(ra) # 8000437e <end_op>
  return 0;
    800056f0:	4781                	li	a5,0
    800056f2:	a085                	j	80005752 <sys_link+0x13c>
    end_op();
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	c8a080e7          	jalr	-886(ra) # 8000437e <end_op>
    return -1;
    800056fc:	57fd                	li	a5,-1
    800056fe:	a891                	j	80005752 <sys_link+0x13c>
    iunlockput(ip);
    80005700:	8526                	mv	a0,s1
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	4a2080e7          	jalr	1186(ra) # 80003ba4 <iunlockput>
    end_op();
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	c74080e7          	jalr	-908(ra) # 8000437e <end_op>
    return -1;
    80005712:	57fd                	li	a5,-1
    80005714:	a83d                	j	80005752 <sys_link+0x13c>
    iunlockput(dp);
    80005716:	854a                	mv	a0,s2
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	48c080e7          	jalr	1164(ra) # 80003ba4 <iunlockput>
  ilock(ip);
    80005720:	8526                	mv	a0,s1
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	220080e7          	jalr	544(ra) # 80003942 <ilock>
  ip->nlink--;
    8000572a:	04a4d783          	lhu	a5,74(s1)
    8000572e:	37fd                	addiw	a5,a5,-1
    80005730:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005734:	8526                	mv	a0,s1
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	142080e7          	jalr	322(ra) # 80003878 <iupdate>
  iunlockput(ip);
    8000573e:	8526                	mv	a0,s1
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	464080e7          	jalr	1124(ra) # 80003ba4 <iunlockput>
  end_op();
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	c36080e7          	jalr	-970(ra) # 8000437e <end_op>
  return -1;
    80005750:	57fd                	li	a5,-1
}
    80005752:	853e                	mv	a0,a5
    80005754:	70b2                	ld	ra,296(sp)
    80005756:	7412                	ld	s0,288(sp)
    80005758:	64f2                	ld	s1,280(sp)
    8000575a:	6952                	ld	s2,272(sp)
    8000575c:	6155                	addi	sp,sp,304
    8000575e:	8082                	ret

0000000080005760 <sys_unlink>:
{
    80005760:	7151                	addi	sp,sp,-240
    80005762:	f586                	sd	ra,232(sp)
    80005764:	f1a2                	sd	s0,224(sp)
    80005766:	eda6                	sd	s1,216(sp)
    80005768:	e9ca                	sd	s2,208(sp)
    8000576a:	e5ce                	sd	s3,200(sp)
    8000576c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000576e:	08000613          	li	a2,128
    80005772:	f3040593          	addi	a1,s0,-208
    80005776:	4501                	li	a0,0
    80005778:	ffffd097          	auipc	ra,0xffffd
    8000577c:	69c080e7          	jalr	1692(ra) # 80002e14 <argstr>
    80005780:	18054163          	bltz	a0,80005902 <sys_unlink+0x1a2>
  begin_op();
    80005784:	fffff097          	auipc	ra,0xfffff
    80005788:	b7a080e7          	jalr	-1158(ra) # 800042fe <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000578c:	fb040593          	addi	a1,s0,-80
    80005790:	f3040513          	addi	a0,s0,-208
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	97c080e7          	jalr	-1668(ra) # 80004110 <nameiparent>
    8000579c:	84aa                	mv	s1,a0
    8000579e:	c979                	beqz	a0,80005874 <sys_unlink+0x114>
  ilock(dp);
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	1a2080e7          	jalr	418(ra) # 80003942 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057a8:	00003597          	auipc	a1,0x3
    800057ac:	fe858593          	addi	a1,a1,-24 # 80008790 <syscalls+0x2c0>
    800057b0:	fb040513          	addi	a0,s0,-80
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	652080e7          	jalr	1618(ra) # 80003e06 <namecmp>
    800057bc:	14050a63          	beqz	a0,80005910 <sys_unlink+0x1b0>
    800057c0:	00003597          	auipc	a1,0x3
    800057c4:	fd858593          	addi	a1,a1,-40 # 80008798 <syscalls+0x2c8>
    800057c8:	fb040513          	addi	a0,s0,-80
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	63a080e7          	jalr	1594(ra) # 80003e06 <namecmp>
    800057d4:	12050e63          	beqz	a0,80005910 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057d8:	f2c40613          	addi	a2,s0,-212
    800057dc:	fb040593          	addi	a1,s0,-80
    800057e0:	8526                	mv	a0,s1
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	63e080e7          	jalr	1598(ra) # 80003e20 <dirlookup>
    800057ea:	892a                	mv	s2,a0
    800057ec:	12050263          	beqz	a0,80005910 <sys_unlink+0x1b0>
  ilock(ip);
    800057f0:	ffffe097          	auipc	ra,0xffffe
    800057f4:	152080e7          	jalr	338(ra) # 80003942 <ilock>
  if(ip->nlink < 1)
    800057f8:	04a91783          	lh	a5,74(s2)
    800057fc:	08f05263          	blez	a5,80005880 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005800:	04491703          	lh	a4,68(s2)
    80005804:	4785                	li	a5,1
    80005806:	08f70563          	beq	a4,a5,80005890 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000580a:	4641                	li	a2,16
    8000580c:	4581                	li	a1,0
    8000580e:	fc040513          	addi	a0,s0,-64
    80005812:	ffffb097          	auipc	ra,0xffffb
    80005816:	4fa080e7          	jalr	1274(ra) # 80000d0c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000581a:	4741                	li	a4,16
    8000581c:	f2c42683          	lw	a3,-212(s0)
    80005820:	fc040613          	addi	a2,s0,-64
    80005824:	4581                	li	a1,0
    80005826:	8526                	mv	a0,s1
    80005828:	ffffe097          	auipc	ra,0xffffe
    8000582c:	4c4080e7          	jalr	1220(ra) # 80003cec <writei>
    80005830:	47c1                	li	a5,16
    80005832:	0af51563          	bne	a0,a5,800058dc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005836:	04491703          	lh	a4,68(s2)
    8000583a:	4785                	li	a5,1
    8000583c:	0af70863          	beq	a4,a5,800058ec <sys_unlink+0x18c>
  iunlockput(dp);
    80005840:	8526                	mv	a0,s1
    80005842:	ffffe097          	auipc	ra,0xffffe
    80005846:	362080e7          	jalr	866(ra) # 80003ba4 <iunlockput>
  ip->nlink--;
    8000584a:	04a95783          	lhu	a5,74(s2)
    8000584e:	37fd                	addiw	a5,a5,-1
    80005850:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005854:	854a                	mv	a0,s2
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	022080e7          	jalr	34(ra) # 80003878 <iupdate>
  iunlockput(ip);
    8000585e:	854a                	mv	a0,s2
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	344080e7          	jalr	836(ra) # 80003ba4 <iunlockput>
  end_op();
    80005868:	fffff097          	auipc	ra,0xfffff
    8000586c:	b16080e7          	jalr	-1258(ra) # 8000437e <end_op>
  return 0;
    80005870:	4501                	li	a0,0
    80005872:	a84d                	j	80005924 <sys_unlink+0x1c4>
    end_op();
    80005874:	fffff097          	auipc	ra,0xfffff
    80005878:	b0a080e7          	jalr	-1270(ra) # 8000437e <end_op>
    return -1;
    8000587c:	557d                	li	a0,-1
    8000587e:	a05d                	j	80005924 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005880:	00003517          	auipc	a0,0x3
    80005884:	f4050513          	addi	a0,a0,-192 # 800087c0 <syscalls+0x2f0>
    80005888:	ffffb097          	auipc	ra,0xffffb
    8000588c:	cc0080e7          	jalr	-832(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005890:	04c92703          	lw	a4,76(s2)
    80005894:	02000793          	li	a5,32
    80005898:	f6e7f9e3          	bgeu	a5,a4,8000580a <sys_unlink+0xaa>
    8000589c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058a0:	4741                	li	a4,16
    800058a2:	86ce                	mv	a3,s3
    800058a4:	f1840613          	addi	a2,s0,-232
    800058a8:	4581                	li	a1,0
    800058aa:	854a                	mv	a0,s2
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	34a080e7          	jalr	842(ra) # 80003bf6 <readi>
    800058b4:	47c1                	li	a5,16
    800058b6:	00f51b63          	bne	a0,a5,800058cc <sys_unlink+0x16c>
    if(de.inum != 0)
    800058ba:	f1845783          	lhu	a5,-232(s0)
    800058be:	e7a1                	bnez	a5,80005906 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058c0:	29c1                	addiw	s3,s3,16
    800058c2:	04c92783          	lw	a5,76(s2)
    800058c6:	fcf9ede3          	bltu	s3,a5,800058a0 <sys_unlink+0x140>
    800058ca:	b781                	j	8000580a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058cc:	00003517          	auipc	a0,0x3
    800058d0:	f0c50513          	addi	a0,a0,-244 # 800087d8 <syscalls+0x308>
    800058d4:	ffffb097          	auipc	ra,0xffffb
    800058d8:	c74080e7          	jalr	-908(ra) # 80000548 <panic>
    panic("unlink: writei");
    800058dc:	00003517          	auipc	a0,0x3
    800058e0:	f1450513          	addi	a0,a0,-236 # 800087f0 <syscalls+0x320>
    800058e4:	ffffb097          	auipc	ra,0xffffb
    800058e8:	c64080e7          	jalr	-924(ra) # 80000548 <panic>
    dp->nlink--;
    800058ec:	04a4d783          	lhu	a5,74(s1)
    800058f0:	37fd                	addiw	a5,a5,-1
    800058f2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058f6:	8526                	mv	a0,s1
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	f80080e7          	jalr	-128(ra) # 80003878 <iupdate>
    80005900:	b781                	j	80005840 <sys_unlink+0xe0>
    return -1;
    80005902:	557d                	li	a0,-1
    80005904:	a005                	j	80005924 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005906:	854a                	mv	a0,s2
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	29c080e7          	jalr	668(ra) # 80003ba4 <iunlockput>
  iunlockput(dp);
    80005910:	8526                	mv	a0,s1
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	292080e7          	jalr	658(ra) # 80003ba4 <iunlockput>
  end_op();
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	a64080e7          	jalr	-1436(ra) # 8000437e <end_op>
  return -1;
    80005922:	557d                	li	a0,-1
}
    80005924:	70ae                	ld	ra,232(sp)
    80005926:	740e                	ld	s0,224(sp)
    80005928:	64ee                	ld	s1,216(sp)
    8000592a:	694e                	ld	s2,208(sp)
    8000592c:	69ae                	ld	s3,200(sp)
    8000592e:	616d                	addi	sp,sp,240
    80005930:	8082                	ret

0000000080005932 <sys_open>:

uint64
sys_open(void)
{
    80005932:	7131                	addi	sp,sp,-192
    80005934:	fd06                	sd	ra,184(sp)
    80005936:	f922                	sd	s0,176(sp)
    80005938:	f526                	sd	s1,168(sp)
    8000593a:	f14a                	sd	s2,160(sp)
    8000593c:	ed4e                	sd	s3,152(sp)
    8000593e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005940:	08000613          	li	a2,128
    80005944:	f5040593          	addi	a1,s0,-176
    80005948:	4501                	li	a0,0
    8000594a:	ffffd097          	auipc	ra,0xffffd
    8000594e:	4ca080e7          	jalr	1226(ra) # 80002e14 <argstr>
    return -1;
    80005952:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005954:	0c054163          	bltz	a0,80005a16 <sys_open+0xe4>
    80005958:	f4c40593          	addi	a1,s0,-180
    8000595c:	4505                	li	a0,1
    8000595e:	ffffd097          	auipc	ra,0xffffd
    80005962:	472080e7          	jalr	1138(ra) # 80002dd0 <argint>
    80005966:	0a054863          	bltz	a0,80005a16 <sys_open+0xe4>

  begin_op();
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	994080e7          	jalr	-1644(ra) # 800042fe <begin_op>

  if(omode & O_CREATE){
    80005972:	f4c42783          	lw	a5,-180(s0)
    80005976:	2007f793          	andi	a5,a5,512
    8000597a:	cbdd                	beqz	a5,80005a30 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000597c:	4681                	li	a3,0
    8000597e:	4601                	li	a2,0
    80005980:	4589                	li	a1,2
    80005982:	f5040513          	addi	a0,s0,-176
    80005986:	00000097          	auipc	ra,0x0
    8000598a:	972080e7          	jalr	-1678(ra) # 800052f8 <create>
    8000598e:	892a                	mv	s2,a0
    if(ip == 0){
    80005990:	c959                	beqz	a0,80005a26 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005992:	04491703          	lh	a4,68(s2)
    80005996:	478d                	li	a5,3
    80005998:	00f71763          	bne	a4,a5,800059a6 <sys_open+0x74>
    8000599c:	04695703          	lhu	a4,70(s2)
    800059a0:	47a5                	li	a5,9
    800059a2:	0ce7ec63          	bltu	a5,a4,80005a7a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	d6e080e7          	jalr	-658(ra) # 80004714 <filealloc>
    800059ae:	89aa                	mv	s3,a0
    800059b0:	10050263          	beqz	a0,80005ab4 <sys_open+0x182>
    800059b4:	00000097          	auipc	ra,0x0
    800059b8:	902080e7          	jalr	-1790(ra) # 800052b6 <fdalloc>
    800059bc:	84aa                	mv	s1,a0
    800059be:	0e054663          	bltz	a0,80005aaa <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059c2:	04491703          	lh	a4,68(s2)
    800059c6:	478d                	li	a5,3
    800059c8:	0cf70463          	beq	a4,a5,80005a90 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059cc:	4789                	li	a5,2
    800059ce:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059d2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059d6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059da:	f4c42783          	lw	a5,-180(s0)
    800059de:	0017c713          	xori	a4,a5,1
    800059e2:	8b05                	andi	a4,a4,1
    800059e4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059e8:	0037f713          	andi	a4,a5,3
    800059ec:	00e03733          	snez	a4,a4
    800059f0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059f4:	4007f793          	andi	a5,a5,1024
    800059f8:	c791                	beqz	a5,80005a04 <sys_open+0xd2>
    800059fa:	04491703          	lh	a4,68(s2)
    800059fe:	4789                	li	a5,2
    80005a00:	08f70f63          	beq	a4,a5,80005a9e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a04:	854a                	mv	a0,s2
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	ffe080e7          	jalr	-2(ra) # 80003a04 <iunlock>
  end_op();
    80005a0e:	fffff097          	auipc	ra,0xfffff
    80005a12:	970080e7          	jalr	-1680(ra) # 8000437e <end_op>

  return fd;
}
    80005a16:	8526                	mv	a0,s1
    80005a18:	70ea                	ld	ra,184(sp)
    80005a1a:	744a                	ld	s0,176(sp)
    80005a1c:	74aa                	ld	s1,168(sp)
    80005a1e:	790a                	ld	s2,160(sp)
    80005a20:	69ea                	ld	s3,152(sp)
    80005a22:	6129                	addi	sp,sp,192
    80005a24:	8082                	ret
      end_op();
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	958080e7          	jalr	-1704(ra) # 8000437e <end_op>
      return -1;
    80005a2e:	b7e5                	j	80005a16 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a30:	f5040513          	addi	a0,s0,-176
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	6be080e7          	jalr	1726(ra) # 800040f2 <namei>
    80005a3c:	892a                	mv	s2,a0
    80005a3e:	c905                	beqz	a0,80005a6e <sys_open+0x13c>
    ilock(ip);
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	f02080e7          	jalr	-254(ra) # 80003942 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a48:	04491703          	lh	a4,68(s2)
    80005a4c:	4785                	li	a5,1
    80005a4e:	f4f712e3          	bne	a4,a5,80005992 <sys_open+0x60>
    80005a52:	f4c42783          	lw	a5,-180(s0)
    80005a56:	dba1                	beqz	a5,800059a6 <sys_open+0x74>
      iunlockput(ip);
    80005a58:	854a                	mv	a0,s2
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	14a080e7          	jalr	330(ra) # 80003ba4 <iunlockput>
      end_op();
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	91c080e7          	jalr	-1764(ra) # 8000437e <end_op>
      return -1;
    80005a6a:	54fd                	li	s1,-1
    80005a6c:	b76d                	j	80005a16 <sys_open+0xe4>
      end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	910080e7          	jalr	-1776(ra) # 8000437e <end_op>
      return -1;
    80005a76:	54fd                	li	s1,-1
    80005a78:	bf79                	j	80005a16 <sys_open+0xe4>
    iunlockput(ip);
    80005a7a:	854a                	mv	a0,s2
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	128080e7          	jalr	296(ra) # 80003ba4 <iunlockput>
    end_op();
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	8fa080e7          	jalr	-1798(ra) # 8000437e <end_op>
    return -1;
    80005a8c:	54fd                	li	s1,-1
    80005a8e:	b761                	j	80005a16 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a90:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a94:	04691783          	lh	a5,70(s2)
    80005a98:	02f99223          	sh	a5,36(s3)
    80005a9c:	bf2d                	j	800059d6 <sys_open+0xa4>
    itrunc(ip);
    80005a9e:	854a                	mv	a0,s2
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	fb0080e7          	jalr	-80(ra) # 80003a50 <itrunc>
    80005aa8:	bfb1                	j	80005a04 <sys_open+0xd2>
      fileclose(f);
    80005aaa:	854e                	mv	a0,s3
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	d24080e7          	jalr	-732(ra) # 800047d0 <fileclose>
    iunlockput(ip);
    80005ab4:	854a                	mv	a0,s2
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	0ee080e7          	jalr	238(ra) # 80003ba4 <iunlockput>
    end_op();
    80005abe:	fffff097          	auipc	ra,0xfffff
    80005ac2:	8c0080e7          	jalr	-1856(ra) # 8000437e <end_op>
    return -1;
    80005ac6:	54fd                	li	s1,-1
    80005ac8:	b7b9                	j	80005a16 <sys_open+0xe4>

0000000080005aca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005aca:	7175                	addi	sp,sp,-144
    80005acc:	e506                	sd	ra,136(sp)
    80005ace:	e122                	sd	s0,128(sp)
    80005ad0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ad2:	fffff097          	auipc	ra,0xfffff
    80005ad6:	82c080e7          	jalr	-2004(ra) # 800042fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ada:	08000613          	li	a2,128
    80005ade:	f7040593          	addi	a1,s0,-144
    80005ae2:	4501                	li	a0,0
    80005ae4:	ffffd097          	auipc	ra,0xffffd
    80005ae8:	330080e7          	jalr	816(ra) # 80002e14 <argstr>
    80005aec:	02054963          	bltz	a0,80005b1e <sys_mkdir+0x54>
    80005af0:	4681                	li	a3,0
    80005af2:	4601                	li	a2,0
    80005af4:	4585                	li	a1,1
    80005af6:	f7040513          	addi	a0,s0,-144
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	7fe080e7          	jalr	2046(ra) # 800052f8 <create>
    80005b02:	cd11                	beqz	a0,80005b1e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b04:	ffffe097          	auipc	ra,0xffffe
    80005b08:	0a0080e7          	jalr	160(ra) # 80003ba4 <iunlockput>
  end_op();
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	872080e7          	jalr	-1934(ra) # 8000437e <end_op>
  return 0;
    80005b14:	4501                	li	a0,0
}
    80005b16:	60aa                	ld	ra,136(sp)
    80005b18:	640a                	ld	s0,128(sp)
    80005b1a:	6149                	addi	sp,sp,144
    80005b1c:	8082                	ret
    end_op();
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	860080e7          	jalr	-1952(ra) # 8000437e <end_op>
    return -1;
    80005b26:	557d                	li	a0,-1
    80005b28:	b7fd                	j	80005b16 <sys_mkdir+0x4c>

0000000080005b2a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b2a:	7135                	addi	sp,sp,-160
    80005b2c:	ed06                	sd	ra,152(sp)
    80005b2e:	e922                	sd	s0,144(sp)
    80005b30:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b32:	ffffe097          	auipc	ra,0xffffe
    80005b36:	7cc080e7          	jalr	1996(ra) # 800042fe <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b3a:	08000613          	li	a2,128
    80005b3e:	f7040593          	addi	a1,s0,-144
    80005b42:	4501                	li	a0,0
    80005b44:	ffffd097          	auipc	ra,0xffffd
    80005b48:	2d0080e7          	jalr	720(ra) # 80002e14 <argstr>
    80005b4c:	04054a63          	bltz	a0,80005ba0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b50:	f6c40593          	addi	a1,s0,-148
    80005b54:	4505                	li	a0,1
    80005b56:	ffffd097          	auipc	ra,0xffffd
    80005b5a:	27a080e7          	jalr	634(ra) # 80002dd0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b5e:	04054163          	bltz	a0,80005ba0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b62:	f6840593          	addi	a1,s0,-152
    80005b66:	4509                	li	a0,2
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	268080e7          	jalr	616(ra) # 80002dd0 <argint>
     argint(1, &major) < 0 ||
    80005b70:	02054863          	bltz	a0,80005ba0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b74:	f6841683          	lh	a3,-152(s0)
    80005b78:	f6c41603          	lh	a2,-148(s0)
    80005b7c:	458d                	li	a1,3
    80005b7e:	f7040513          	addi	a0,s0,-144
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	776080e7          	jalr	1910(ra) # 800052f8 <create>
     argint(2, &minor) < 0 ||
    80005b8a:	c919                	beqz	a0,80005ba0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	018080e7          	jalr	24(ra) # 80003ba4 <iunlockput>
  end_op();
    80005b94:	ffffe097          	auipc	ra,0xffffe
    80005b98:	7ea080e7          	jalr	2026(ra) # 8000437e <end_op>
  return 0;
    80005b9c:	4501                	li	a0,0
    80005b9e:	a031                	j	80005baa <sys_mknod+0x80>
    end_op();
    80005ba0:	ffffe097          	auipc	ra,0xffffe
    80005ba4:	7de080e7          	jalr	2014(ra) # 8000437e <end_op>
    return -1;
    80005ba8:	557d                	li	a0,-1
}
    80005baa:	60ea                	ld	ra,152(sp)
    80005bac:	644a                	ld	s0,144(sp)
    80005bae:	610d                	addi	sp,sp,160
    80005bb0:	8082                	ret

0000000080005bb2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bb2:	7135                	addi	sp,sp,-160
    80005bb4:	ed06                	sd	ra,152(sp)
    80005bb6:	e922                	sd	s0,144(sp)
    80005bb8:	e526                	sd	s1,136(sp)
    80005bba:	e14a                	sd	s2,128(sp)
    80005bbc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bbe:	ffffc097          	auipc	ra,0xffffc
    80005bc2:	f54080e7          	jalr	-172(ra) # 80001b12 <myproc>
    80005bc6:	892a                	mv	s2,a0
  
  begin_op();
    80005bc8:	ffffe097          	auipc	ra,0xffffe
    80005bcc:	736080e7          	jalr	1846(ra) # 800042fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bd0:	08000613          	li	a2,128
    80005bd4:	f6040593          	addi	a1,s0,-160
    80005bd8:	4501                	li	a0,0
    80005bda:	ffffd097          	auipc	ra,0xffffd
    80005bde:	23a080e7          	jalr	570(ra) # 80002e14 <argstr>
    80005be2:	04054b63          	bltz	a0,80005c38 <sys_chdir+0x86>
    80005be6:	f6040513          	addi	a0,s0,-160
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	508080e7          	jalr	1288(ra) # 800040f2 <namei>
    80005bf2:	84aa                	mv	s1,a0
    80005bf4:	c131                	beqz	a0,80005c38 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bf6:	ffffe097          	auipc	ra,0xffffe
    80005bfa:	d4c080e7          	jalr	-692(ra) # 80003942 <ilock>
  if(ip->type != T_DIR){
    80005bfe:	04449703          	lh	a4,68(s1)
    80005c02:	4785                	li	a5,1
    80005c04:	04f71063          	bne	a4,a5,80005c44 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c08:	8526                	mv	a0,s1
    80005c0a:	ffffe097          	auipc	ra,0xffffe
    80005c0e:	dfa080e7          	jalr	-518(ra) # 80003a04 <iunlock>
  iput(p->cwd);
    80005c12:	15093503          	ld	a0,336(s2)
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	ee6080e7          	jalr	-282(ra) # 80003afc <iput>
  end_op();
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	760080e7          	jalr	1888(ra) # 8000437e <end_op>
  p->cwd = ip;
    80005c26:	14993823          	sd	s1,336(s2)
  return 0;
    80005c2a:	4501                	li	a0,0
}
    80005c2c:	60ea                	ld	ra,152(sp)
    80005c2e:	644a                	ld	s0,144(sp)
    80005c30:	64aa                	ld	s1,136(sp)
    80005c32:	690a                	ld	s2,128(sp)
    80005c34:	610d                	addi	sp,sp,160
    80005c36:	8082                	ret
    end_op();
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	746080e7          	jalr	1862(ra) # 8000437e <end_op>
    return -1;
    80005c40:	557d                	li	a0,-1
    80005c42:	b7ed                	j	80005c2c <sys_chdir+0x7a>
    iunlockput(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	f5e080e7          	jalr	-162(ra) # 80003ba4 <iunlockput>
    end_op();
    80005c4e:	ffffe097          	auipc	ra,0xffffe
    80005c52:	730080e7          	jalr	1840(ra) # 8000437e <end_op>
    return -1;
    80005c56:	557d                	li	a0,-1
    80005c58:	bfd1                	j	80005c2c <sys_chdir+0x7a>

0000000080005c5a <sys_exec>:

uint64
sys_exec(void)
{
    80005c5a:	7145                	addi	sp,sp,-464
    80005c5c:	e786                	sd	ra,456(sp)
    80005c5e:	e3a2                	sd	s0,448(sp)
    80005c60:	ff26                	sd	s1,440(sp)
    80005c62:	fb4a                	sd	s2,432(sp)
    80005c64:	f74e                	sd	s3,424(sp)
    80005c66:	f352                	sd	s4,416(sp)
    80005c68:	ef56                	sd	s5,408(sp)
    80005c6a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c6c:	08000613          	li	a2,128
    80005c70:	f4040593          	addi	a1,s0,-192
    80005c74:	4501                	li	a0,0
    80005c76:	ffffd097          	auipc	ra,0xffffd
    80005c7a:	19e080e7          	jalr	414(ra) # 80002e14 <argstr>
    return -1;
    80005c7e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c80:	0c054a63          	bltz	a0,80005d54 <sys_exec+0xfa>
    80005c84:	e3840593          	addi	a1,s0,-456
    80005c88:	4505                	li	a0,1
    80005c8a:	ffffd097          	auipc	ra,0xffffd
    80005c8e:	168080e7          	jalr	360(ra) # 80002df2 <argaddr>
    80005c92:	0c054163          	bltz	a0,80005d54 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c96:	10000613          	li	a2,256
    80005c9a:	4581                	li	a1,0
    80005c9c:	e4040513          	addi	a0,s0,-448
    80005ca0:	ffffb097          	auipc	ra,0xffffb
    80005ca4:	06c080e7          	jalr	108(ra) # 80000d0c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ca8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005cac:	89a6                	mv	s3,s1
    80005cae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cb0:	02000a13          	li	s4,32
    80005cb4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cb8:	00391513          	slli	a0,s2,0x3
    80005cbc:	e3040593          	addi	a1,s0,-464
    80005cc0:	e3843783          	ld	a5,-456(s0)
    80005cc4:	953e                	add	a0,a0,a5
    80005cc6:	ffffd097          	auipc	ra,0xffffd
    80005cca:	070080e7          	jalr	112(ra) # 80002d36 <fetchaddr>
    80005cce:	02054a63          	bltz	a0,80005d02 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005cd2:	e3043783          	ld	a5,-464(s0)
    80005cd6:	c3b9                	beqz	a5,80005d1c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cd8:	ffffb097          	auipc	ra,0xffffb
    80005cdc:	e48080e7          	jalr	-440(ra) # 80000b20 <kalloc>
    80005ce0:	85aa                	mv	a1,a0
    80005ce2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ce6:	cd11                	beqz	a0,80005d02 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ce8:	6605                	lui	a2,0x1
    80005cea:	e3043503          	ld	a0,-464(s0)
    80005cee:	ffffd097          	auipc	ra,0xffffd
    80005cf2:	09a080e7          	jalr	154(ra) # 80002d88 <fetchstr>
    80005cf6:	00054663          	bltz	a0,80005d02 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005cfa:	0905                	addi	s2,s2,1
    80005cfc:	09a1                	addi	s3,s3,8
    80005cfe:	fb491be3          	bne	s2,s4,80005cb4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d02:	10048913          	addi	s2,s1,256
    80005d06:	6088                	ld	a0,0(s1)
    80005d08:	c529                	beqz	a0,80005d52 <sys_exec+0xf8>
    kfree(argv[i]);
    80005d0a:	ffffb097          	auipc	ra,0xffffb
    80005d0e:	d1a080e7          	jalr	-742(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d12:	04a1                	addi	s1,s1,8
    80005d14:	ff2499e3          	bne	s1,s2,80005d06 <sys_exec+0xac>
  return -1;
    80005d18:	597d                	li	s2,-1
    80005d1a:	a82d                	j	80005d54 <sys_exec+0xfa>
      argv[i] = 0;
    80005d1c:	0a8e                	slli	s5,s5,0x3
    80005d1e:	fc040793          	addi	a5,s0,-64
    80005d22:	9abe                	add	s5,s5,a5
    80005d24:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d28:	e4040593          	addi	a1,s0,-448
    80005d2c:	f4040513          	addi	a0,s0,-192
    80005d30:	fffff097          	auipc	ra,0xfffff
    80005d34:	150080e7          	jalr	336(ra) # 80004e80 <exec>
    80005d38:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d3a:	10048993          	addi	s3,s1,256
    80005d3e:	6088                	ld	a0,0(s1)
    80005d40:	c911                	beqz	a0,80005d54 <sys_exec+0xfa>
    kfree(argv[i]);
    80005d42:	ffffb097          	auipc	ra,0xffffb
    80005d46:	ce2080e7          	jalr	-798(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4a:	04a1                	addi	s1,s1,8
    80005d4c:	ff3499e3          	bne	s1,s3,80005d3e <sys_exec+0xe4>
    80005d50:	a011                	j	80005d54 <sys_exec+0xfa>
  return -1;
    80005d52:	597d                	li	s2,-1
}
    80005d54:	854a                	mv	a0,s2
    80005d56:	60be                	ld	ra,456(sp)
    80005d58:	641e                	ld	s0,448(sp)
    80005d5a:	74fa                	ld	s1,440(sp)
    80005d5c:	795a                	ld	s2,432(sp)
    80005d5e:	79ba                	ld	s3,424(sp)
    80005d60:	7a1a                	ld	s4,416(sp)
    80005d62:	6afa                	ld	s5,408(sp)
    80005d64:	6179                	addi	sp,sp,464
    80005d66:	8082                	ret

0000000080005d68 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d68:	7139                	addi	sp,sp,-64
    80005d6a:	fc06                	sd	ra,56(sp)
    80005d6c:	f822                	sd	s0,48(sp)
    80005d6e:	f426                	sd	s1,40(sp)
    80005d70:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d72:	ffffc097          	auipc	ra,0xffffc
    80005d76:	da0080e7          	jalr	-608(ra) # 80001b12 <myproc>
    80005d7a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d7c:	fd840593          	addi	a1,s0,-40
    80005d80:	4501                	li	a0,0
    80005d82:	ffffd097          	auipc	ra,0xffffd
    80005d86:	070080e7          	jalr	112(ra) # 80002df2 <argaddr>
    return -1;
    80005d8a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d8c:	0e054063          	bltz	a0,80005e6c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d90:	fc840593          	addi	a1,s0,-56
    80005d94:	fd040513          	addi	a0,s0,-48
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	d8e080e7          	jalr	-626(ra) # 80004b26 <pipealloc>
    return -1;
    80005da0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005da2:	0c054563          	bltz	a0,80005e6c <sys_pipe+0x104>
  fd0 = -1;
    80005da6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005daa:	fd043503          	ld	a0,-48(s0)
    80005dae:	fffff097          	auipc	ra,0xfffff
    80005db2:	508080e7          	jalr	1288(ra) # 800052b6 <fdalloc>
    80005db6:	fca42223          	sw	a0,-60(s0)
    80005dba:	08054c63          	bltz	a0,80005e52 <sys_pipe+0xea>
    80005dbe:	fc843503          	ld	a0,-56(s0)
    80005dc2:	fffff097          	auipc	ra,0xfffff
    80005dc6:	4f4080e7          	jalr	1268(ra) # 800052b6 <fdalloc>
    80005dca:	fca42023          	sw	a0,-64(s0)
    80005dce:	06054863          	bltz	a0,80005e3e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dd2:	4691                	li	a3,4
    80005dd4:	fc440613          	addi	a2,s0,-60
    80005dd8:	fd843583          	ld	a1,-40(s0)
    80005ddc:	68a8                	ld	a0,80(s1)
    80005dde:	ffffc097          	auipc	ra,0xffffc
    80005de2:	ae4080e7          	jalr	-1308(ra) # 800018c2 <copyout>
    80005de6:	02054063          	bltz	a0,80005e06 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dea:	4691                	li	a3,4
    80005dec:	fc040613          	addi	a2,s0,-64
    80005df0:	fd843583          	ld	a1,-40(s0)
    80005df4:	0591                	addi	a1,a1,4
    80005df6:	68a8                	ld	a0,80(s1)
    80005df8:	ffffc097          	auipc	ra,0xffffc
    80005dfc:	aca080e7          	jalr	-1334(ra) # 800018c2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e00:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e02:	06055563          	bgez	a0,80005e6c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005e06:	fc442783          	lw	a5,-60(s0)
    80005e0a:	07e9                	addi	a5,a5,26
    80005e0c:	078e                	slli	a5,a5,0x3
    80005e0e:	97a6                	add	a5,a5,s1
    80005e10:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e14:	fc042503          	lw	a0,-64(s0)
    80005e18:	0569                	addi	a0,a0,26
    80005e1a:	050e                	slli	a0,a0,0x3
    80005e1c:	9526                	add	a0,a0,s1
    80005e1e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e22:	fd043503          	ld	a0,-48(s0)
    80005e26:	fffff097          	auipc	ra,0xfffff
    80005e2a:	9aa080e7          	jalr	-1622(ra) # 800047d0 <fileclose>
    fileclose(wf);
    80005e2e:	fc843503          	ld	a0,-56(s0)
    80005e32:	fffff097          	auipc	ra,0xfffff
    80005e36:	99e080e7          	jalr	-1634(ra) # 800047d0 <fileclose>
    return -1;
    80005e3a:	57fd                	li	a5,-1
    80005e3c:	a805                	j	80005e6c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e3e:	fc442783          	lw	a5,-60(s0)
    80005e42:	0007c863          	bltz	a5,80005e52 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e46:	01a78513          	addi	a0,a5,26
    80005e4a:	050e                	slli	a0,a0,0x3
    80005e4c:	9526                	add	a0,a0,s1
    80005e4e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e52:	fd043503          	ld	a0,-48(s0)
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	97a080e7          	jalr	-1670(ra) # 800047d0 <fileclose>
    fileclose(wf);
    80005e5e:	fc843503          	ld	a0,-56(s0)
    80005e62:	fffff097          	auipc	ra,0xfffff
    80005e66:	96e080e7          	jalr	-1682(ra) # 800047d0 <fileclose>
    return -1;
    80005e6a:	57fd                	li	a5,-1
}
    80005e6c:	853e                	mv	a0,a5
    80005e6e:	70e2                	ld	ra,56(sp)
    80005e70:	7442                	ld	s0,48(sp)
    80005e72:	74a2                	ld	s1,40(sp)
    80005e74:	6121                	addi	sp,sp,64
    80005e76:	8082                	ret
	...

0000000080005e80 <kernelvec>:
    80005e80:	7111                	addi	sp,sp,-256
    80005e82:	e006                	sd	ra,0(sp)
    80005e84:	e40a                	sd	sp,8(sp)
    80005e86:	e80e                	sd	gp,16(sp)
    80005e88:	ec12                	sd	tp,24(sp)
    80005e8a:	f016                	sd	t0,32(sp)
    80005e8c:	f41a                	sd	t1,40(sp)
    80005e8e:	f81e                	sd	t2,48(sp)
    80005e90:	fc22                	sd	s0,56(sp)
    80005e92:	e0a6                	sd	s1,64(sp)
    80005e94:	e4aa                	sd	a0,72(sp)
    80005e96:	e8ae                	sd	a1,80(sp)
    80005e98:	ecb2                	sd	a2,88(sp)
    80005e9a:	f0b6                	sd	a3,96(sp)
    80005e9c:	f4ba                	sd	a4,104(sp)
    80005e9e:	f8be                	sd	a5,112(sp)
    80005ea0:	fcc2                	sd	a6,120(sp)
    80005ea2:	e146                	sd	a7,128(sp)
    80005ea4:	e54a                	sd	s2,136(sp)
    80005ea6:	e94e                	sd	s3,144(sp)
    80005ea8:	ed52                	sd	s4,152(sp)
    80005eaa:	f156                	sd	s5,160(sp)
    80005eac:	f55a                	sd	s6,168(sp)
    80005eae:	f95e                	sd	s7,176(sp)
    80005eb0:	fd62                	sd	s8,184(sp)
    80005eb2:	e1e6                	sd	s9,192(sp)
    80005eb4:	e5ea                	sd	s10,200(sp)
    80005eb6:	e9ee                	sd	s11,208(sp)
    80005eb8:	edf2                	sd	t3,216(sp)
    80005eba:	f1f6                	sd	t4,224(sp)
    80005ebc:	f5fa                	sd	t5,232(sp)
    80005ebe:	f9fe                	sd	t6,240(sp)
    80005ec0:	d43fc0ef          	jal	ra,80002c02 <kerneltrap>
    80005ec4:	6082                	ld	ra,0(sp)
    80005ec6:	6122                	ld	sp,8(sp)
    80005ec8:	61c2                	ld	gp,16(sp)
    80005eca:	7282                	ld	t0,32(sp)
    80005ecc:	7322                	ld	t1,40(sp)
    80005ece:	73c2                	ld	t2,48(sp)
    80005ed0:	7462                	ld	s0,56(sp)
    80005ed2:	6486                	ld	s1,64(sp)
    80005ed4:	6526                	ld	a0,72(sp)
    80005ed6:	65c6                	ld	a1,80(sp)
    80005ed8:	6666                	ld	a2,88(sp)
    80005eda:	7686                	ld	a3,96(sp)
    80005edc:	7726                	ld	a4,104(sp)
    80005ede:	77c6                	ld	a5,112(sp)
    80005ee0:	7866                	ld	a6,120(sp)
    80005ee2:	688a                	ld	a7,128(sp)
    80005ee4:	692a                	ld	s2,136(sp)
    80005ee6:	69ca                	ld	s3,144(sp)
    80005ee8:	6a6a                	ld	s4,152(sp)
    80005eea:	7a8a                	ld	s5,160(sp)
    80005eec:	7b2a                	ld	s6,168(sp)
    80005eee:	7bca                	ld	s7,176(sp)
    80005ef0:	7c6a                	ld	s8,184(sp)
    80005ef2:	6c8e                	ld	s9,192(sp)
    80005ef4:	6d2e                	ld	s10,200(sp)
    80005ef6:	6dce                	ld	s11,208(sp)
    80005ef8:	6e6e                	ld	t3,216(sp)
    80005efa:	7e8e                	ld	t4,224(sp)
    80005efc:	7f2e                	ld	t5,232(sp)
    80005efe:	7fce                	ld	t6,240(sp)
    80005f00:	6111                	addi	sp,sp,256
    80005f02:	10200073          	sret
    80005f06:	00000013          	nop
    80005f0a:	00000013          	nop
    80005f0e:	0001                	nop

0000000080005f10 <timervec>:
    80005f10:	34051573          	csrrw	a0,mscratch,a0
    80005f14:	e10c                	sd	a1,0(a0)
    80005f16:	e510                	sd	a2,8(a0)
    80005f18:	e914                	sd	a3,16(a0)
    80005f1a:	710c                	ld	a1,32(a0)
    80005f1c:	7510                	ld	a2,40(a0)
    80005f1e:	6194                	ld	a3,0(a1)
    80005f20:	96b2                	add	a3,a3,a2
    80005f22:	e194                	sd	a3,0(a1)
    80005f24:	4589                	li	a1,2
    80005f26:	14459073          	csrw	sip,a1
    80005f2a:	6914                	ld	a3,16(a0)
    80005f2c:	6510                	ld	a2,8(a0)
    80005f2e:	610c                	ld	a1,0(a0)
    80005f30:	34051573          	csrrw	a0,mscratch,a0
    80005f34:	30200073          	mret
	...

0000000080005f3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f3a:	1141                	addi	sp,sp,-16
    80005f3c:	e422                	sd	s0,8(sp)
    80005f3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f40:	0c0007b7          	lui	a5,0xc000
    80005f44:	4705                	li	a4,1
    80005f46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f48:	c3d8                	sw	a4,4(a5)
}
    80005f4a:	6422                	ld	s0,8(sp)
    80005f4c:	0141                	addi	sp,sp,16
    80005f4e:	8082                	ret

0000000080005f50 <plicinithart>:

void
plicinithart(void)
{
    80005f50:	1141                	addi	sp,sp,-16
    80005f52:	e406                	sd	ra,8(sp)
    80005f54:	e022                	sd	s0,0(sp)
    80005f56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f58:	ffffc097          	auipc	ra,0xffffc
    80005f5c:	b8e080e7          	jalr	-1138(ra) # 80001ae6 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f60:	0085171b          	slliw	a4,a0,0x8
    80005f64:	0c0027b7          	lui	a5,0xc002
    80005f68:	97ba                	add	a5,a5,a4
    80005f6a:	40200713          	li	a4,1026
    80005f6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f72:	00d5151b          	slliw	a0,a0,0xd
    80005f76:	0c2017b7          	lui	a5,0xc201
    80005f7a:	953e                	add	a0,a0,a5
    80005f7c:	00052023          	sw	zero,0(a0)
}
    80005f80:	60a2                	ld	ra,8(sp)
    80005f82:	6402                	ld	s0,0(sp)
    80005f84:	0141                	addi	sp,sp,16
    80005f86:	8082                	ret

0000000080005f88 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f88:	1141                	addi	sp,sp,-16
    80005f8a:	e406                	sd	ra,8(sp)
    80005f8c:	e022                	sd	s0,0(sp)
    80005f8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f90:	ffffc097          	auipc	ra,0xffffc
    80005f94:	b56080e7          	jalr	-1194(ra) # 80001ae6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f98:	00d5179b          	slliw	a5,a0,0xd
    80005f9c:	0c201537          	lui	a0,0xc201
    80005fa0:	953e                	add	a0,a0,a5
  return irq;
}
    80005fa2:	4148                	lw	a0,4(a0)
    80005fa4:	60a2                	ld	ra,8(sp)
    80005fa6:	6402                	ld	s0,0(sp)
    80005fa8:	0141                	addi	sp,sp,16
    80005faa:	8082                	ret

0000000080005fac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fac:	1101                	addi	sp,sp,-32
    80005fae:	ec06                	sd	ra,24(sp)
    80005fb0:	e822                	sd	s0,16(sp)
    80005fb2:	e426                	sd	s1,8(sp)
    80005fb4:	1000                	addi	s0,sp,32
    80005fb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fb8:	ffffc097          	auipc	ra,0xffffc
    80005fbc:	b2e080e7          	jalr	-1234(ra) # 80001ae6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fc0:	00d5151b          	slliw	a0,a0,0xd
    80005fc4:	0c2017b7          	lui	a5,0xc201
    80005fc8:	97aa                	add	a5,a5,a0
    80005fca:	c3c4                	sw	s1,4(a5)
}
    80005fcc:	60e2                	ld	ra,24(sp)
    80005fce:	6442                	ld	s0,16(sp)
    80005fd0:	64a2                	ld	s1,8(sp)
    80005fd2:	6105                	addi	sp,sp,32
    80005fd4:	8082                	ret

0000000080005fd6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fd6:	1141                	addi	sp,sp,-16
    80005fd8:	e406                	sd	ra,8(sp)
    80005fda:	e022                	sd	s0,0(sp)
    80005fdc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fde:	479d                	li	a5,7
    80005fe0:	04a7cc63          	blt	a5,a0,80006038 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005fe4:	0001d797          	auipc	a5,0x1d
    80005fe8:	01c78793          	addi	a5,a5,28 # 80023000 <disk>
    80005fec:	00a78733          	add	a4,a5,a0
    80005ff0:	6789                	lui	a5,0x2
    80005ff2:	97ba                	add	a5,a5,a4
    80005ff4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005ff8:	eba1                	bnez	a5,80006048 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005ffa:	00451713          	slli	a4,a0,0x4
    80005ffe:	0001f797          	auipc	a5,0x1f
    80006002:	0027b783          	ld	a5,2(a5) # 80025000 <disk+0x2000>
    80006006:	97ba                	add	a5,a5,a4
    80006008:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    8000600c:	0001d797          	auipc	a5,0x1d
    80006010:	ff478793          	addi	a5,a5,-12 # 80023000 <disk>
    80006014:	97aa                	add	a5,a5,a0
    80006016:	6509                	lui	a0,0x2
    80006018:	953e                	add	a0,a0,a5
    8000601a:	4785                	li	a5,1
    8000601c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006020:	0001f517          	auipc	a0,0x1f
    80006024:	ff850513          	addi	a0,a0,-8 # 80025018 <disk+0x2018>
    80006028:	ffffc097          	auipc	ra,0xffffc
    8000602c:	680080e7          	jalr	1664(ra) # 800026a8 <wakeup>
}
    80006030:	60a2                	ld	ra,8(sp)
    80006032:	6402                	ld	s0,0(sp)
    80006034:	0141                	addi	sp,sp,16
    80006036:	8082                	ret
    panic("virtio_disk_intr 1");
    80006038:	00002517          	auipc	a0,0x2
    8000603c:	7c850513          	addi	a0,a0,1992 # 80008800 <syscalls+0x330>
    80006040:	ffffa097          	auipc	ra,0xffffa
    80006044:	508080e7          	jalr	1288(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80006048:	00002517          	auipc	a0,0x2
    8000604c:	7d050513          	addi	a0,a0,2000 # 80008818 <syscalls+0x348>
    80006050:	ffffa097          	auipc	ra,0xffffa
    80006054:	4f8080e7          	jalr	1272(ra) # 80000548 <panic>

0000000080006058 <virtio_disk_init>:
{
    80006058:	1101                	addi	sp,sp,-32
    8000605a:	ec06                	sd	ra,24(sp)
    8000605c:	e822                	sd	s0,16(sp)
    8000605e:	e426                	sd	s1,8(sp)
    80006060:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006062:	00002597          	auipc	a1,0x2
    80006066:	7ce58593          	addi	a1,a1,1998 # 80008830 <syscalls+0x360>
    8000606a:	0001f517          	auipc	a0,0x1f
    8000606e:	03e50513          	addi	a0,a0,62 # 800250a8 <disk+0x20a8>
    80006072:	ffffb097          	auipc	ra,0xffffb
    80006076:	b0e080e7          	jalr	-1266(ra) # 80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000607a:	100017b7          	lui	a5,0x10001
    8000607e:	4398                	lw	a4,0(a5)
    80006080:	2701                	sext.w	a4,a4
    80006082:	747277b7          	lui	a5,0x74727
    80006086:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000608a:	0ef71163          	bne	a4,a5,8000616c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000608e:	100017b7          	lui	a5,0x10001
    80006092:	43dc                	lw	a5,4(a5)
    80006094:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006096:	4705                	li	a4,1
    80006098:	0ce79a63          	bne	a5,a4,8000616c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000609c:	100017b7          	lui	a5,0x10001
    800060a0:	479c                	lw	a5,8(a5)
    800060a2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800060a4:	4709                	li	a4,2
    800060a6:	0ce79363          	bne	a5,a4,8000616c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060aa:	100017b7          	lui	a5,0x10001
    800060ae:	47d8                	lw	a4,12(a5)
    800060b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060b2:	554d47b7          	lui	a5,0x554d4
    800060b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060ba:	0af71963          	bne	a4,a5,8000616c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060be:	100017b7          	lui	a5,0x10001
    800060c2:	4705                	li	a4,1
    800060c4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060c6:	470d                	li	a4,3
    800060c8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060ca:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060cc:	c7ffe737          	lui	a4,0xc7ffe
    800060d0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd773f>
    800060d4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060d6:	2701                	sext.w	a4,a4
    800060d8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060da:	472d                	li	a4,11
    800060dc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060de:	473d                	li	a4,15
    800060e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800060e2:	6705                	lui	a4,0x1
    800060e4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060e6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060ea:	5bdc                	lw	a5,52(a5)
    800060ec:	2781                	sext.w	a5,a5
  if(max == 0)
    800060ee:	c7d9                	beqz	a5,8000617c <virtio_disk_init+0x124>
  if(max < NUM)
    800060f0:	471d                	li	a4,7
    800060f2:	08f77d63          	bgeu	a4,a5,8000618c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060f6:	100014b7          	lui	s1,0x10001
    800060fa:	47a1                	li	a5,8
    800060fc:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800060fe:	6609                	lui	a2,0x2
    80006100:	4581                	li	a1,0
    80006102:	0001d517          	auipc	a0,0x1d
    80006106:	efe50513          	addi	a0,a0,-258 # 80023000 <disk>
    8000610a:	ffffb097          	auipc	ra,0xffffb
    8000610e:	c02080e7          	jalr	-1022(ra) # 80000d0c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006112:	0001d717          	auipc	a4,0x1d
    80006116:	eee70713          	addi	a4,a4,-274 # 80023000 <disk>
    8000611a:	00c75793          	srli	a5,a4,0xc
    8000611e:	2781                	sext.w	a5,a5
    80006120:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006122:	0001f797          	auipc	a5,0x1f
    80006126:	ede78793          	addi	a5,a5,-290 # 80025000 <disk+0x2000>
    8000612a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000612c:	0001d717          	auipc	a4,0x1d
    80006130:	f5470713          	addi	a4,a4,-172 # 80023080 <disk+0x80>
    80006134:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006136:	0001e717          	auipc	a4,0x1e
    8000613a:	eca70713          	addi	a4,a4,-310 # 80024000 <disk+0x1000>
    8000613e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006140:	4705                	li	a4,1
    80006142:	00e78c23          	sb	a4,24(a5)
    80006146:	00e78ca3          	sb	a4,25(a5)
    8000614a:	00e78d23          	sb	a4,26(a5)
    8000614e:	00e78da3          	sb	a4,27(a5)
    80006152:	00e78e23          	sb	a4,28(a5)
    80006156:	00e78ea3          	sb	a4,29(a5)
    8000615a:	00e78f23          	sb	a4,30(a5)
    8000615e:	00e78fa3          	sb	a4,31(a5)
}
    80006162:	60e2                	ld	ra,24(sp)
    80006164:	6442                	ld	s0,16(sp)
    80006166:	64a2                	ld	s1,8(sp)
    80006168:	6105                	addi	sp,sp,32
    8000616a:	8082                	ret
    panic("could not find virtio disk");
    8000616c:	00002517          	auipc	a0,0x2
    80006170:	6d450513          	addi	a0,a0,1748 # 80008840 <syscalls+0x370>
    80006174:	ffffa097          	auipc	ra,0xffffa
    80006178:	3d4080e7          	jalr	980(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    8000617c:	00002517          	auipc	a0,0x2
    80006180:	6e450513          	addi	a0,a0,1764 # 80008860 <syscalls+0x390>
    80006184:	ffffa097          	auipc	ra,0xffffa
    80006188:	3c4080e7          	jalr	964(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    8000618c:	00002517          	auipc	a0,0x2
    80006190:	6f450513          	addi	a0,a0,1780 # 80008880 <syscalls+0x3b0>
    80006194:	ffffa097          	auipc	ra,0xffffa
    80006198:	3b4080e7          	jalr	948(ra) # 80000548 <panic>

000000008000619c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000619c:	7119                	addi	sp,sp,-128
    8000619e:	fc86                	sd	ra,120(sp)
    800061a0:	f8a2                	sd	s0,112(sp)
    800061a2:	f4a6                	sd	s1,104(sp)
    800061a4:	f0ca                	sd	s2,96(sp)
    800061a6:	ecce                	sd	s3,88(sp)
    800061a8:	e8d2                	sd	s4,80(sp)
    800061aa:	e4d6                	sd	s5,72(sp)
    800061ac:	e0da                	sd	s6,64(sp)
    800061ae:	fc5e                	sd	s7,56(sp)
    800061b0:	f862                	sd	s8,48(sp)
    800061b2:	f466                	sd	s9,40(sp)
    800061b4:	f06a                	sd	s10,32(sp)
    800061b6:	0100                	addi	s0,sp,128
    800061b8:	892a                	mv	s2,a0
    800061ba:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061bc:	00c52c83          	lw	s9,12(a0)
    800061c0:	001c9c9b          	slliw	s9,s9,0x1
    800061c4:	1c82                	slli	s9,s9,0x20
    800061c6:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800061ca:	0001f517          	auipc	a0,0x1f
    800061ce:	ede50513          	addi	a0,a0,-290 # 800250a8 <disk+0x20a8>
    800061d2:	ffffb097          	auipc	ra,0xffffb
    800061d6:	a3e080e7          	jalr	-1474(ra) # 80000c10 <acquire>
  for(int i = 0; i < 3; i++){
    800061da:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061dc:	4c21                	li	s8,8
      disk.free[i] = 0;
    800061de:	0001db97          	auipc	s7,0x1d
    800061e2:	e22b8b93          	addi	s7,s7,-478 # 80023000 <disk>
    800061e6:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800061e8:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800061ea:	8a4e                	mv	s4,s3
    800061ec:	a051                	j	80006270 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800061ee:	00fb86b3          	add	a3,s7,a5
    800061f2:	96da                	add	a3,a3,s6
    800061f4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800061f8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800061fa:	0207c563          	bltz	a5,80006224 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800061fe:	2485                	addiw	s1,s1,1
    80006200:	0711                	addi	a4,a4,4
    80006202:	23548d63          	beq	s1,s5,8000643c <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80006206:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006208:	0001f697          	auipc	a3,0x1f
    8000620c:	e1068693          	addi	a3,a3,-496 # 80025018 <disk+0x2018>
    80006210:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006212:	0006c583          	lbu	a1,0(a3)
    80006216:	fde1                	bnez	a1,800061ee <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006218:	2785                	addiw	a5,a5,1
    8000621a:	0685                	addi	a3,a3,1
    8000621c:	ff879be3          	bne	a5,s8,80006212 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006220:	57fd                	li	a5,-1
    80006222:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006224:	02905a63          	blez	s1,80006258 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006228:	f9042503          	lw	a0,-112(s0)
    8000622c:	00000097          	auipc	ra,0x0
    80006230:	daa080e7          	jalr	-598(ra) # 80005fd6 <free_desc>
      for(int j = 0; j < i; j++)
    80006234:	4785                	li	a5,1
    80006236:	0297d163          	bge	a5,s1,80006258 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000623a:	f9442503          	lw	a0,-108(s0)
    8000623e:	00000097          	auipc	ra,0x0
    80006242:	d98080e7          	jalr	-616(ra) # 80005fd6 <free_desc>
      for(int j = 0; j < i; j++)
    80006246:	4789                	li	a5,2
    80006248:	0097d863          	bge	a5,s1,80006258 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000624c:	f9842503          	lw	a0,-104(s0)
    80006250:	00000097          	auipc	ra,0x0
    80006254:	d86080e7          	jalr	-634(ra) # 80005fd6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006258:	0001f597          	auipc	a1,0x1f
    8000625c:	e5058593          	addi	a1,a1,-432 # 800250a8 <disk+0x20a8>
    80006260:	0001f517          	auipc	a0,0x1f
    80006264:	db850513          	addi	a0,a0,-584 # 80025018 <disk+0x2018>
    80006268:	ffffc097          	auipc	ra,0xffffc
    8000626c:	2ba080e7          	jalr	698(ra) # 80002522 <sleep>
  for(int i = 0; i < 3; i++){
    80006270:	f9040713          	addi	a4,s0,-112
    80006274:	84ce                	mv	s1,s3
    80006276:	bf41                	j	80006206 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006278:	4785                	li	a5,1
    8000627a:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000627e:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80006282:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006286:	f9042983          	lw	s3,-112(s0)
    8000628a:	00499493          	slli	s1,s3,0x4
    8000628e:	0001fa17          	auipc	s4,0x1f
    80006292:	d72a0a13          	addi	s4,s4,-654 # 80025000 <disk+0x2000>
    80006296:	000a3a83          	ld	s5,0(s4)
    8000629a:	9aa6                	add	s5,s5,s1
    8000629c:	f8040513          	addi	a0,s0,-128
    800062a0:	ffffb097          	auipc	ra,0xffffb
    800062a4:	f5a080e7          	jalr	-166(ra) # 800011fa <kvmpa>
    800062a8:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    800062ac:	000a3783          	ld	a5,0(s4)
    800062b0:	97a6                	add	a5,a5,s1
    800062b2:	4741                	li	a4,16
    800062b4:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062b6:	000a3783          	ld	a5,0(s4)
    800062ba:	97a6                	add	a5,a5,s1
    800062bc:	4705                	li	a4,1
    800062be:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800062c2:	f9442703          	lw	a4,-108(s0)
    800062c6:	000a3783          	ld	a5,0(s4)
    800062ca:	97a6                	add	a5,a5,s1
    800062cc:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062d0:	0712                	slli	a4,a4,0x4
    800062d2:	000a3783          	ld	a5,0(s4)
    800062d6:	97ba                	add	a5,a5,a4
    800062d8:	05890693          	addi	a3,s2,88
    800062dc:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    800062de:	000a3783          	ld	a5,0(s4)
    800062e2:	97ba                	add	a5,a5,a4
    800062e4:	40000693          	li	a3,1024
    800062e8:	c794                	sw	a3,8(a5)
  if(write)
    800062ea:	100d0a63          	beqz	s10,800063fe <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800062ee:	0001f797          	auipc	a5,0x1f
    800062f2:	d127b783          	ld	a5,-750(a5) # 80025000 <disk+0x2000>
    800062f6:	97ba                	add	a5,a5,a4
    800062f8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062fc:	0001d517          	auipc	a0,0x1d
    80006300:	d0450513          	addi	a0,a0,-764 # 80023000 <disk>
    80006304:	0001f797          	auipc	a5,0x1f
    80006308:	cfc78793          	addi	a5,a5,-772 # 80025000 <disk+0x2000>
    8000630c:	6394                	ld	a3,0(a5)
    8000630e:	96ba                	add	a3,a3,a4
    80006310:	00c6d603          	lhu	a2,12(a3)
    80006314:	00166613          	ori	a2,a2,1
    80006318:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000631c:	f9842683          	lw	a3,-104(s0)
    80006320:	6390                	ld	a2,0(a5)
    80006322:	9732                	add	a4,a4,a2
    80006324:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006328:	20098613          	addi	a2,s3,512
    8000632c:	0612                	slli	a2,a2,0x4
    8000632e:	962a                	add	a2,a2,a0
    80006330:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006334:	00469713          	slli	a4,a3,0x4
    80006338:	6394                	ld	a3,0(a5)
    8000633a:	96ba                	add	a3,a3,a4
    8000633c:	6589                	lui	a1,0x2
    8000633e:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80006342:	94ae                	add	s1,s1,a1
    80006344:	94aa                	add	s1,s1,a0
    80006346:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006348:	6394                	ld	a3,0(a5)
    8000634a:	96ba                	add	a3,a3,a4
    8000634c:	4585                	li	a1,1
    8000634e:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006350:	6394                	ld	a3,0(a5)
    80006352:	96ba                	add	a3,a3,a4
    80006354:	4509                	li	a0,2
    80006356:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000635a:	6394                	ld	a3,0(a5)
    8000635c:	9736                	add	a4,a4,a3
    8000635e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006362:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006366:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000636a:	6794                	ld	a3,8(a5)
    8000636c:	0026d703          	lhu	a4,2(a3)
    80006370:	8b1d                	andi	a4,a4,7
    80006372:	2709                	addiw	a4,a4,2
    80006374:	0706                	slli	a4,a4,0x1
    80006376:	9736                	add	a4,a4,a3
    80006378:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    8000637c:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006380:	6798                	ld	a4,8(a5)
    80006382:	00275783          	lhu	a5,2(a4)
    80006386:	2785                	addiw	a5,a5,1
    80006388:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000638c:	100017b7          	lui	a5,0x10001
    80006390:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006394:	00492703          	lw	a4,4(s2)
    80006398:	4785                	li	a5,1
    8000639a:	02f71163          	bne	a4,a5,800063bc <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    8000639e:	0001f997          	auipc	s3,0x1f
    800063a2:	d0a98993          	addi	s3,s3,-758 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800063a6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063a8:	85ce                	mv	a1,s3
    800063aa:	854a                	mv	a0,s2
    800063ac:	ffffc097          	auipc	ra,0xffffc
    800063b0:	176080e7          	jalr	374(ra) # 80002522 <sleep>
  while(b->disk == 1) {
    800063b4:	00492783          	lw	a5,4(s2)
    800063b8:	fe9788e3          	beq	a5,s1,800063a8 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    800063bc:	f9042483          	lw	s1,-112(s0)
    800063c0:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    800063c4:	00479713          	slli	a4,a5,0x4
    800063c8:	0001d797          	auipc	a5,0x1d
    800063cc:	c3878793          	addi	a5,a5,-968 # 80023000 <disk>
    800063d0:	97ba                	add	a5,a5,a4
    800063d2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800063d6:	0001f917          	auipc	s2,0x1f
    800063da:	c2a90913          	addi	s2,s2,-982 # 80025000 <disk+0x2000>
    free_desc(i);
    800063de:	8526                	mv	a0,s1
    800063e0:	00000097          	auipc	ra,0x0
    800063e4:	bf6080e7          	jalr	-1034(ra) # 80005fd6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800063e8:	0492                	slli	s1,s1,0x4
    800063ea:	00093783          	ld	a5,0(s2)
    800063ee:	94be                	add	s1,s1,a5
    800063f0:	00c4d783          	lhu	a5,12(s1)
    800063f4:	8b85                	andi	a5,a5,1
    800063f6:	cf89                	beqz	a5,80006410 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    800063f8:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800063fc:	b7cd                	j	800063de <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063fe:	0001f797          	auipc	a5,0x1f
    80006402:	c027b783          	ld	a5,-1022(a5) # 80025000 <disk+0x2000>
    80006406:	97ba                	add	a5,a5,a4
    80006408:	4689                	li	a3,2
    8000640a:	00d79623          	sh	a3,12(a5)
    8000640e:	b5fd                	j	800062fc <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006410:	0001f517          	auipc	a0,0x1f
    80006414:	c9850513          	addi	a0,a0,-872 # 800250a8 <disk+0x20a8>
    80006418:	ffffb097          	auipc	ra,0xffffb
    8000641c:	8ac080e7          	jalr	-1876(ra) # 80000cc4 <release>
}
    80006420:	70e6                	ld	ra,120(sp)
    80006422:	7446                	ld	s0,112(sp)
    80006424:	74a6                	ld	s1,104(sp)
    80006426:	7906                	ld	s2,96(sp)
    80006428:	69e6                	ld	s3,88(sp)
    8000642a:	6a46                	ld	s4,80(sp)
    8000642c:	6aa6                	ld	s5,72(sp)
    8000642e:	6b06                	ld	s6,64(sp)
    80006430:	7be2                	ld	s7,56(sp)
    80006432:	7c42                	ld	s8,48(sp)
    80006434:	7ca2                	ld	s9,40(sp)
    80006436:	7d02                	ld	s10,32(sp)
    80006438:	6109                	addi	sp,sp,128
    8000643a:	8082                	ret
  if(write)
    8000643c:	e20d1ee3          	bnez	s10,80006278 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006440:	f8042023          	sw	zero,-128(s0)
    80006444:	bd2d                	j	8000627e <virtio_disk_rw+0xe2>

0000000080006446 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006446:	1101                	addi	sp,sp,-32
    80006448:	ec06                	sd	ra,24(sp)
    8000644a:	e822                	sd	s0,16(sp)
    8000644c:	e426                	sd	s1,8(sp)
    8000644e:	e04a                	sd	s2,0(sp)
    80006450:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006452:	0001f517          	auipc	a0,0x1f
    80006456:	c5650513          	addi	a0,a0,-938 # 800250a8 <disk+0x20a8>
    8000645a:	ffffa097          	auipc	ra,0xffffa
    8000645e:	7b6080e7          	jalr	1974(ra) # 80000c10 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006462:	0001f717          	auipc	a4,0x1f
    80006466:	b9e70713          	addi	a4,a4,-1122 # 80025000 <disk+0x2000>
    8000646a:	02075783          	lhu	a5,32(a4)
    8000646e:	6b18                	ld	a4,16(a4)
    80006470:	00275683          	lhu	a3,2(a4)
    80006474:	8ebd                	xor	a3,a3,a5
    80006476:	8a9d                	andi	a3,a3,7
    80006478:	cab9                	beqz	a3,800064ce <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000647a:	0001d917          	auipc	s2,0x1d
    8000647e:	b8690913          	addi	s2,s2,-1146 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006482:	0001f497          	auipc	s1,0x1f
    80006486:	b7e48493          	addi	s1,s1,-1154 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000648a:	078e                	slli	a5,a5,0x3
    8000648c:	97ba                	add	a5,a5,a4
    8000648e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006490:	20078713          	addi	a4,a5,512
    80006494:	0712                	slli	a4,a4,0x4
    80006496:	974a                	add	a4,a4,s2
    80006498:	03074703          	lbu	a4,48(a4)
    8000649c:	ef21                	bnez	a4,800064f4 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000649e:	20078793          	addi	a5,a5,512
    800064a2:	0792                	slli	a5,a5,0x4
    800064a4:	97ca                	add	a5,a5,s2
    800064a6:	7798                	ld	a4,40(a5)
    800064a8:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800064ac:	7788                	ld	a0,40(a5)
    800064ae:	ffffc097          	auipc	ra,0xffffc
    800064b2:	1fa080e7          	jalr	506(ra) # 800026a8 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800064b6:	0204d783          	lhu	a5,32(s1)
    800064ba:	2785                	addiw	a5,a5,1
    800064bc:	8b9d                	andi	a5,a5,7
    800064be:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800064c2:	6898                	ld	a4,16(s1)
    800064c4:	00275683          	lhu	a3,2(a4)
    800064c8:	8a9d                	andi	a3,a3,7
    800064ca:	fcf690e3          	bne	a3,a5,8000648a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064ce:	10001737          	lui	a4,0x10001
    800064d2:	533c                	lw	a5,96(a4)
    800064d4:	8b8d                	andi	a5,a5,3
    800064d6:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800064d8:	0001f517          	auipc	a0,0x1f
    800064dc:	bd050513          	addi	a0,a0,-1072 # 800250a8 <disk+0x20a8>
    800064e0:	ffffa097          	auipc	ra,0xffffa
    800064e4:	7e4080e7          	jalr	2020(ra) # 80000cc4 <release>
}
    800064e8:	60e2                	ld	ra,24(sp)
    800064ea:	6442                	ld	s0,16(sp)
    800064ec:	64a2                	ld	s1,8(sp)
    800064ee:	6902                	ld	s2,0(sp)
    800064f0:	6105                	addi	sp,sp,32
    800064f2:	8082                	ret
      panic("virtio_disk_intr status");
    800064f4:	00002517          	auipc	a0,0x2
    800064f8:	3ac50513          	addi	a0,a0,940 # 800088a0 <syscalls+0x3d0>
    800064fc:	ffffa097          	auipc	ra,0xffffa
    80006500:	04c080e7          	jalr	76(ra) # 80000548 <panic>

0000000080006504 <statscopyin>:
  int ncopyin;
  int ncopyinstr;
} stats;

int
statscopyin(char *buf, int sz) {
    80006504:	7179                	addi	sp,sp,-48
    80006506:	f406                	sd	ra,40(sp)
    80006508:	f022                	sd	s0,32(sp)
    8000650a:	ec26                	sd	s1,24(sp)
    8000650c:	e84a                	sd	s2,16(sp)
    8000650e:	e44e                	sd	s3,8(sp)
    80006510:	e052                	sd	s4,0(sp)
    80006512:	1800                	addi	s0,sp,48
    80006514:	892a                	mv	s2,a0
    80006516:	89ae                	mv	s3,a1
  int n;
  n = snprintf(buf, sz, "copyin: %d\n", stats.ncopyin);
    80006518:	00003a17          	auipc	s4,0x3
    8000651c:	b10a0a13          	addi	s4,s4,-1264 # 80009028 <stats>
    80006520:	000a2683          	lw	a3,0(s4)
    80006524:	00002617          	auipc	a2,0x2
    80006528:	39460613          	addi	a2,a2,916 # 800088b8 <syscalls+0x3e8>
    8000652c:	00000097          	auipc	ra,0x0
    80006530:	2c2080e7          	jalr	706(ra) # 800067ee <snprintf>
    80006534:	84aa                	mv	s1,a0
  n += snprintf(buf+n, sz, "copyinstr: %d\n", stats.ncopyinstr);
    80006536:	004a2683          	lw	a3,4(s4)
    8000653a:	00002617          	auipc	a2,0x2
    8000653e:	38e60613          	addi	a2,a2,910 # 800088c8 <syscalls+0x3f8>
    80006542:	85ce                	mv	a1,s3
    80006544:	954a                	add	a0,a0,s2
    80006546:	00000097          	auipc	ra,0x0
    8000654a:	2a8080e7          	jalr	680(ra) # 800067ee <snprintf>
  return n;
}
    8000654e:	9d25                	addw	a0,a0,s1
    80006550:	70a2                	ld	ra,40(sp)
    80006552:	7402                	ld	s0,32(sp)
    80006554:	64e2                	ld	s1,24(sp)
    80006556:	6942                	ld	s2,16(sp)
    80006558:	69a2                	ld	s3,8(sp)
    8000655a:	6a02                	ld	s4,0(sp)
    8000655c:	6145                	addi	sp,sp,48
    8000655e:	8082                	ret

0000000080006560 <copyin_new>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    80006560:	7179                	addi	sp,sp,-48
    80006562:	f406                	sd	ra,40(sp)
    80006564:	f022                	sd	s0,32(sp)
    80006566:	ec26                	sd	s1,24(sp)
    80006568:	e84a                	sd	s2,16(sp)
    8000656a:	e44e                	sd	s3,8(sp)
    8000656c:	1800                	addi	s0,sp,48
    8000656e:	89ae                	mv	s3,a1
    80006570:	84b2                	mv	s1,a2
    80006572:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80006574:	ffffb097          	auipc	ra,0xffffb
    80006578:	59e080e7          	jalr	1438(ra) # 80001b12 <myproc>

  if (srcva >= p->sz || srcva+len >= p->sz || srcva+len < srcva)
    8000657c:	653c                	ld	a5,72(a0)
    8000657e:	02f4ff63          	bgeu	s1,a5,800065bc <copyin_new+0x5c>
    80006582:	01248733          	add	a4,s1,s2
    80006586:	02f77d63          	bgeu	a4,a5,800065c0 <copyin_new+0x60>
    8000658a:	02976d63          	bltu	a4,s1,800065c4 <copyin_new+0x64>
    return -1;
  memmove((void *) dst, (void *)srcva, len);
    8000658e:	0009061b          	sext.w	a2,s2
    80006592:	85a6                	mv	a1,s1
    80006594:	854e                	mv	a0,s3
    80006596:	ffffa097          	auipc	ra,0xffffa
    8000659a:	7d6080e7          	jalr	2006(ra) # 80000d6c <memmove>
  stats.ncopyin++;   // XXX lock
    8000659e:	00003717          	auipc	a4,0x3
    800065a2:	a8a70713          	addi	a4,a4,-1398 # 80009028 <stats>
    800065a6:	431c                	lw	a5,0(a4)
    800065a8:	2785                	addiw	a5,a5,1
    800065aa:	c31c                	sw	a5,0(a4)
  return 0;
    800065ac:	4501                	li	a0,0
}
    800065ae:	70a2                	ld	ra,40(sp)
    800065b0:	7402                	ld	s0,32(sp)
    800065b2:	64e2                	ld	s1,24(sp)
    800065b4:	6942                	ld	s2,16(sp)
    800065b6:	69a2                	ld	s3,8(sp)
    800065b8:	6145                	addi	sp,sp,48
    800065ba:	8082                	ret
    return -1;
    800065bc:	557d                	li	a0,-1
    800065be:	bfc5                	j	800065ae <copyin_new+0x4e>
    800065c0:	557d                	li	a0,-1
    800065c2:	b7f5                	j	800065ae <copyin_new+0x4e>
    800065c4:	557d                	li	a0,-1
    800065c6:	b7e5                	j	800065ae <copyin_new+0x4e>

00000000800065c8 <copyinstr_new>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800065c8:	7179                	addi	sp,sp,-48
    800065ca:	f406                	sd	ra,40(sp)
    800065cc:	f022                	sd	s0,32(sp)
    800065ce:	ec26                	sd	s1,24(sp)
    800065d0:	e84a                	sd	s2,16(sp)
    800065d2:	e44e                	sd	s3,8(sp)
    800065d4:	1800                	addi	s0,sp,48
    800065d6:	89ae                	mv	s3,a1
    800065d8:	8932                	mv	s2,a2
    800065da:	84b6                	mv	s1,a3
  struct proc *p = myproc();
    800065dc:	ffffb097          	auipc	ra,0xffffb
    800065e0:	536080e7          	jalr	1334(ra) # 80001b12 <myproc>
  char *s = (char *) srcva;
  
  stats.ncopyinstr++;   // XXX lock
    800065e4:	00003717          	auipc	a4,0x3
    800065e8:	a4470713          	addi	a4,a4,-1468 # 80009028 <stats>
    800065ec:	435c                	lw	a5,4(a4)
    800065ee:	2785                	addiw	a5,a5,1
    800065f0:	c35c                	sw	a5,4(a4)
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    800065f2:	cc85                	beqz	s1,8000662a <copyinstr_new+0x62>
    800065f4:	00990833          	add	a6,s2,s1
    800065f8:	87ca                	mv	a5,s2
    800065fa:	6538                	ld	a4,72(a0)
    800065fc:	00e7ff63          	bgeu	a5,a4,8000661a <copyinstr_new+0x52>
    dst[i] = s[i];
    80006600:	0007c683          	lbu	a3,0(a5)
    80006604:	41278733          	sub	a4,a5,s2
    80006608:	974e                	add	a4,a4,s3
    8000660a:	00d70023          	sb	a3,0(a4)
    if(s[i] == '\0')
    8000660e:	c285                	beqz	a3,8000662e <copyinstr_new+0x66>
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    80006610:	0785                	addi	a5,a5,1
    80006612:	ff0794e3          	bne	a5,a6,800065fa <copyinstr_new+0x32>
      return 0;
  }
  return -1;
    80006616:	557d                	li	a0,-1
    80006618:	a011                	j	8000661c <copyinstr_new+0x54>
    8000661a:	557d                	li	a0,-1
}
    8000661c:	70a2                	ld	ra,40(sp)
    8000661e:	7402                	ld	s0,32(sp)
    80006620:	64e2                	ld	s1,24(sp)
    80006622:	6942                	ld	s2,16(sp)
    80006624:	69a2                	ld	s3,8(sp)
    80006626:	6145                	addi	sp,sp,48
    80006628:	8082                	ret
  return -1;
    8000662a:	557d                	li	a0,-1
    8000662c:	bfc5                	j	8000661c <copyinstr_new+0x54>
      return 0;
    8000662e:	4501                	li	a0,0
    80006630:	b7f5                	j	8000661c <copyinstr_new+0x54>

0000000080006632 <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    80006632:	1141                	addi	sp,sp,-16
    80006634:	e422                	sd	s0,8(sp)
    80006636:	0800                	addi	s0,sp,16
  return -1;
}
    80006638:	557d                	li	a0,-1
    8000663a:	6422                	ld	s0,8(sp)
    8000663c:	0141                	addi	sp,sp,16
    8000663e:	8082                	ret

0000000080006640 <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    80006640:	7179                	addi	sp,sp,-48
    80006642:	f406                	sd	ra,40(sp)
    80006644:	f022                	sd	s0,32(sp)
    80006646:	ec26                	sd	s1,24(sp)
    80006648:	e84a                	sd	s2,16(sp)
    8000664a:	e44e                	sd	s3,8(sp)
    8000664c:	e052                	sd	s4,0(sp)
    8000664e:	1800                	addi	s0,sp,48
    80006650:	892a                	mv	s2,a0
    80006652:	89ae                	mv	s3,a1
    80006654:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    80006656:	00020517          	auipc	a0,0x20
    8000665a:	9aa50513          	addi	a0,a0,-1622 # 80026000 <stats>
    8000665e:	ffffa097          	auipc	ra,0xffffa
    80006662:	5b2080e7          	jalr	1458(ra) # 80000c10 <acquire>

  if(stats.sz == 0) {
    80006666:	00021797          	auipc	a5,0x21
    8000666a:	9b27a783          	lw	a5,-1614(a5) # 80027018 <stats+0x1018>
    8000666e:	cbb5                	beqz	a5,800066e2 <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    80006670:	00021797          	auipc	a5,0x21
    80006674:	99078793          	addi	a5,a5,-1648 # 80027000 <stats+0x1000>
    80006678:	4fd8                	lw	a4,28(a5)
    8000667a:	4f9c                	lw	a5,24(a5)
    8000667c:	9f99                	subw	a5,a5,a4
    8000667e:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    80006682:	06d05e63          	blez	a3,800066fe <statsread+0xbe>
    if(m > n)
    80006686:	8a3e                	mv	s4,a5
    80006688:	00d4d363          	bge	s1,a3,8000668e <statsread+0x4e>
    8000668c:	8a26                	mv	s4,s1
    8000668e:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    80006692:	86a6                	mv	a3,s1
    80006694:	00020617          	auipc	a2,0x20
    80006698:	98460613          	addi	a2,a2,-1660 # 80026018 <stats+0x18>
    8000669c:	963a                	add	a2,a2,a4
    8000669e:	85ce                	mv	a1,s3
    800066a0:	854a                	mv	a0,s2
    800066a2:	ffffc097          	auipc	ra,0xffffc
    800066a6:	0e2080e7          	jalr	226(ra) # 80002784 <either_copyout>
    800066aa:	57fd                	li	a5,-1
    800066ac:	00f50a63          	beq	a0,a5,800066c0 <statsread+0x80>
      stats.off += m;
    800066b0:	00021717          	auipc	a4,0x21
    800066b4:	95070713          	addi	a4,a4,-1712 # 80027000 <stats+0x1000>
    800066b8:	4f5c                	lw	a5,28(a4)
    800066ba:	014787bb          	addw	a5,a5,s4
    800066be:	cf5c                	sw	a5,28(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    800066c0:	00020517          	auipc	a0,0x20
    800066c4:	94050513          	addi	a0,a0,-1728 # 80026000 <stats>
    800066c8:	ffffa097          	auipc	ra,0xffffa
    800066cc:	5fc080e7          	jalr	1532(ra) # 80000cc4 <release>
  return m;
}
    800066d0:	8526                	mv	a0,s1
    800066d2:	70a2                	ld	ra,40(sp)
    800066d4:	7402                	ld	s0,32(sp)
    800066d6:	64e2                	ld	s1,24(sp)
    800066d8:	6942                	ld	s2,16(sp)
    800066da:	69a2                	ld	s3,8(sp)
    800066dc:	6a02                	ld	s4,0(sp)
    800066de:	6145                	addi	sp,sp,48
    800066e0:	8082                	ret
    stats.sz = statscopyin(stats.buf, BUFSZ);
    800066e2:	6585                	lui	a1,0x1
    800066e4:	00020517          	auipc	a0,0x20
    800066e8:	93450513          	addi	a0,a0,-1740 # 80026018 <stats+0x18>
    800066ec:	00000097          	auipc	ra,0x0
    800066f0:	e18080e7          	jalr	-488(ra) # 80006504 <statscopyin>
    800066f4:	00021797          	auipc	a5,0x21
    800066f8:	92a7a223          	sw	a0,-1756(a5) # 80027018 <stats+0x1018>
    800066fc:	bf95                	j	80006670 <statsread+0x30>
    stats.sz = 0;
    800066fe:	00021797          	auipc	a5,0x21
    80006702:	90278793          	addi	a5,a5,-1790 # 80027000 <stats+0x1000>
    80006706:	0007ac23          	sw	zero,24(a5)
    stats.off = 0;
    8000670a:	0007ae23          	sw	zero,28(a5)
    m = -1;
    8000670e:	54fd                	li	s1,-1
    80006710:	bf45                	j	800066c0 <statsread+0x80>

0000000080006712 <statsinit>:

void
statsinit(void)
{
    80006712:	1141                	addi	sp,sp,-16
    80006714:	e406                	sd	ra,8(sp)
    80006716:	e022                	sd	s0,0(sp)
    80006718:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    8000671a:	00002597          	auipc	a1,0x2
    8000671e:	1be58593          	addi	a1,a1,446 # 800088d8 <syscalls+0x408>
    80006722:	00020517          	auipc	a0,0x20
    80006726:	8de50513          	addi	a0,a0,-1826 # 80026000 <stats>
    8000672a:	ffffa097          	auipc	ra,0xffffa
    8000672e:	456080e7          	jalr	1110(ra) # 80000b80 <initlock>

  devsw[STATS].read = statsread;
    80006732:	0001b797          	auipc	a5,0x1b
    80006736:	47e78793          	addi	a5,a5,1150 # 80021bb0 <devsw>
    8000673a:	00000717          	auipc	a4,0x0
    8000673e:	f0670713          	addi	a4,a4,-250 # 80006640 <statsread>
    80006742:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    80006744:	00000717          	auipc	a4,0x0
    80006748:	eee70713          	addi	a4,a4,-274 # 80006632 <statswrite>
    8000674c:	f798                	sd	a4,40(a5)
}
    8000674e:	60a2                	ld	ra,8(sp)
    80006750:	6402                	ld	s0,0(sp)
    80006752:	0141                	addi	sp,sp,16
    80006754:	8082                	ret

0000000080006756 <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    80006756:	1101                	addi	sp,sp,-32
    80006758:	ec22                	sd	s0,24(sp)
    8000675a:	1000                	addi	s0,sp,32
    8000675c:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    8000675e:	c299                	beqz	a3,80006764 <sprintint+0xe>
    80006760:	0805c163          	bltz	a1,800067e2 <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    80006764:	2581                	sext.w	a1,a1
    80006766:	4301                	li	t1,0

  i = 0;
    80006768:	fe040713          	addi	a4,s0,-32
    8000676c:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    8000676e:	2601                	sext.w	a2,a2
    80006770:	00002697          	auipc	a3,0x2
    80006774:	17068693          	addi	a3,a3,368 # 800088e0 <digits>
    80006778:	88aa                	mv	a7,a0
    8000677a:	2505                	addiw	a0,a0,1
    8000677c:	02c5f7bb          	remuw	a5,a1,a2
    80006780:	1782                	slli	a5,a5,0x20
    80006782:	9381                	srli	a5,a5,0x20
    80006784:	97b6                	add	a5,a5,a3
    80006786:	0007c783          	lbu	a5,0(a5)
    8000678a:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    8000678e:	0005879b          	sext.w	a5,a1
    80006792:	02c5d5bb          	divuw	a1,a1,a2
    80006796:	0705                	addi	a4,a4,1
    80006798:	fec7f0e3          	bgeu	a5,a2,80006778 <sprintint+0x22>

  if(sign)
    8000679c:	00030b63          	beqz	t1,800067b2 <sprintint+0x5c>
    buf[i++] = '-';
    800067a0:	ff040793          	addi	a5,s0,-16
    800067a4:	97aa                	add	a5,a5,a0
    800067a6:	02d00713          	li	a4,45
    800067aa:	fee78823          	sb	a4,-16(a5)
    800067ae:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    800067b2:	02a05c63          	blez	a0,800067ea <sprintint+0x94>
    800067b6:	fe040793          	addi	a5,s0,-32
    800067ba:	00a78733          	add	a4,a5,a0
    800067be:	87c2                	mv	a5,a6
    800067c0:	0805                	addi	a6,a6,1
    800067c2:	fff5061b          	addiw	a2,a0,-1
    800067c6:	1602                	slli	a2,a2,0x20
    800067c8:	9201                	srli	a2,a2,0x20
    800067ca:	9642                	add	a2,a2,a6
  *s = c;
    800067cc:	fff74683          	lbu	a3,-1(a4)
    800067d0:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    800067d4:	177d                	addi	a4,a4,-1
    800067d6:	0785                	addi	a5,a5,1
    800067d8:	fec79ae3          	bne	a5,a2,800067cc <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    800067dc:	6462                	ld	s0,24(sp)
    800067de:	6105                	addi	sp,sp,32
    800067e0:	8082                	ret
    x = -xx;
    800067e2:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    800067e6:	4305                	li	t1,1
    x = -xx;
    800067e8:	b741                	j	80006768 <sprintint+0x12>
  while(--i >= 0)
    800067ea:	4501                	li	a0,0
    800067ec:	bfc5                	j	800067dc <sprintint+0x86>

00000000800067ee <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    800067ee:	7171                	addi	sp,sp,-176
    800067f0:	fc86                	sd	ra,120(sp)
    800067f2:	f8a2                	sd	s0,112(sp)
    800067f4:	f4a6                	sd	s1,104(sp)
    800067f6:	f0ca                	sd	s2,96(sp)
    800067f8:	ecce                	sd	s3,88(sp)
    800067fa:	e8d2                	sd	s4,80(sp)
    800067fc:	e4d6                	sd	s5,72(sp)
    800067fe:	e0da                	sd	s6,64(sp)
    80006800:	fc5e                	sd	s7,56(sp)
    80006802:	f862                	sd	s8,48(sp)
    80006804:	f466                	sd	s9,40(sp)
    80006806:	f06a                	sd	s10,32(sp)
    80006808:	ec6e                	sd	s11,24(sp)
    8000680a:	0100                	addi	s0,sp,128
    8000680c:	e414                	sd	a3,8(s0)
    8000680e:	e818                	sd	a4,16(s0)
    80006810:	ec1c                	sd	a5,24(s0)
    80006812:	03043023          	sd	a6,32(s0)
    80006816:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    8000681a:	ca0d                	beqz	a2,8000684c <snprintf+0x5e>
    8000681c:	8baa                	mv	s7,a0
    8000681e:	89ae                	mv	s3,a1
    80006820:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    80006822:	00840793          	addi	a5,s0,8
    80006826:	f8f43423          	sd	a5,-120(s0)
  int off = 0;
    8000682a:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    8000682c:	4901                	li	s2,0
    8000682e:	02b05763          	blez	a1,8000685c <snprintf+0x6e>
    if(c != '%'){
    80006832:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    80006836:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    8000683a:	02800d93          	li	s11,40
  *s = c;
    8000683e:	02500d13          	li	s10,37
    switch(c){
    80006842:	07800c93          	li	s9,120
    80006846:	06400c13          	li	s8,100
    8000684a:	a01d                	j	80006870 <snprintf+0x82>
    panic("null fmt");
    8000684c:	00001517          	auipc	a0,0x1
    80006850:	7dc50513          	addi	a0,a0,2012 # 80008028 <etext+0x28>
    80006854:	ffffa097          	auipc	ra,0xffffa
    80006858:	cf4080e7          	jalr	-780(ra) # 80000548 <panic>
  int off = 0;
    8000685c:	4481                	li	s1,0
    8000685e:	a86d                	j	80006918 <snprintf+0x12a>
  *s = c;
    80006860:	009b8733          	add	a4,s7,s1
    80006864:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006868:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    8000686a:	2905                	addiw	s2,s2,1
    8000686c:	0b34d663          	bge	s1,s3,80006918 <snprintf+0x12a>
    80006870:	012a07b3          	add	a5,s4,s2
    80006874:	0007c783          	lbu	a5,0(a5)
    80006878:	0007871b          	sext.w	a4,a5
    8000687c:	cfd1                	beqz	a5,80006918 <snprintf+0x12a>
    if(c != '%'){
    8000687e:	ff5711e3          	bne	a4,s5,80006860 <snprintf+0x72>
    c = fmt[++i] & 0xff;
    80006882:	2905                	addiw	s2,s2,1
    80006884:	012a07b3          	add	a5,s4,s2
    80006888:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    8000688c:	c7d1                	beqz	a5,80006918 <snprintf+0x12a>
    switch(c){
    8000688e:	05678c63          	beq	a5,s6,800068e6 <snprintf+0xf8>
    80006892:	02fb6763          	bltu	s6,a5,800068c0 <snprintf+0xd2>
    80006896:	0b578763          	beq	a5,s5,80006944 <snprintf+0x156>
    8000689a:	0b879b63          	bne	a5,s8,80006950 <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    8000689e:	f8843783          	ld	a5,-120(s0)
    800068a2:	00878713          	addi	a4,a5,8
    800068a6:	f8e43423          	sd	a4,-120(s0)
    800068aa:	4685                	li	a3,1
    800068ac:	4629                	li	a2,10
    800068ae:	438c                	lw	a1,0(a5)
    800068b0:	009b8533          	add	a0,s7,s1
    800068b4:	00000097          	auipc	ra,0x0
    800068b8:	ea2080e7          	jalr	-350(ra) # 80006756 <sprintint>
    800068bc:	9ca9                	addw	s1,s1,a0
      break;
    800068be:	b775                	j	8000686a <snprintf+0x7c>
    switch(c){
    800068c0:	09979863          	bne	a5,s9,80006950 <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    800068c4:	f8843783          	ld	a5,-120(s0)
    800068c8:	00878713          	addi	a4,a5,8
    800068cc:	f8e43423          	sd	a4,-120(s0)
    800068d0:	4685                	li	a3,1
    800068d2:	4641                	li	a2,16
    800068d4:	438c                	lw	a1,0(a5)
    800068d6:	009b8533          	add	a0,s7,s1
    800068da:	00000097          	auipc	ra,0x0
    800068de:	e7c080e7          	jalr	-388(ra) # 80006756 <sprintint>
    800068e2:	9ca9                	addw	s1,s1,a0
      break;
    800068e4:	b759                	j	8000686a <snprintf+0x7c>
      if((s = va_arg(ap, char*)) == 0)
    800068e6:	f8843783          	ld	a5,-120(s0)
    800068ea:	00878713          	addi	a4,a5,8
    800068ee:	f8e43423          	sd	a4,-120(s0)
    800068f2:	639c                	ld	a5,0(a5)
    800068f4:	c3b1                	beqz	a5,80006938 <snprintf+0x14a>
      for(; *s && off < sz; s++)
    800068f6:	0007c703          	lbu	a4,0(a5)
    800068fa:	db25                	beqz	a4,8000686a <snprintf+0x7c>
    800068fc:	0134de63          	bge	s1,s3,80006918 <snprintf+0x12a>
    80006900:	009b86b3          	add	a3,s7,s1
  *s = c;
    80006904:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    80006908:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    8000690a:	0785                	addi	a5,a5,1
    8000690c:	0007c703          	lbu	a4,0(a5)
    80006910:	df29                	beqz	a4,8000686a <snprintf+0x7c>
    80006912:	0685                	addi	a3,a3,1
    80006914:	fe9998e3          	bne	s3,s1,80006904 <snprintf+0x116>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    80006918:	8526                	mv	a0,s1
    8000691a:	70e6                	ld	ra,120(sp)
    8000691c:	7446                	ld	s0,112(sp)
    8000691e:	74a6                	ld	s1,104(sp)
    80006920:	7906                	ld	s2,96(sp)
    80006922:	69e6                	ld	s3,88(sp)
    80006924:	6a46                	ld	s4,80(sp)
    80006926:	6aa6                	ld	s5,72(sp)
    80006928:	6b06                	ld	s6,64(sp)
    8000692a:	7be2                	ld	s7,56(sp)
    8000692c:	7c42                	ld	s8,48(sp)
    8000692e:	7ca2                	ld	s9,40(sp)
    80006930:	7d02                	ld	s10,32(sp)
    80006932:	6de2                	ld	s11,24(sp)
    80006934:	614d                	addi	sp,sp,176
    80006936:	8082                	ret
        s = "(null)";
    80006938:	00001797          	auipc	a5,0x1
    8000693c:	6e878793          	addi	a5,a5,1768 # 80008020 <etext+0x20>
      for(; *s && off < sz; s++)
    80006940:	876e                	mv	a4,s11
    80006942:	bf6d                	j	800068fc <snprintf+0x10e>
  *s = c;
    80006944:	009b87b3          	add	a5,s7,s1
    80006948:	01a78023          	sb	s10,0(a5)
      off += sputc(buf+off, '%');
    8000694c:	2485                	addiw	s1,s1,1
      break;
    8000694e:	bf31                	j	8000686a <snprintf+0x7c>
  *s = c;
    80006950:	009b8733          	add	a4,s7,s1
    80006954:	01a70023          	sb	s10,0(a4)
      off += sputc(buf+off, c);
    80006958:	0014871b          	addiw	a4,s1,1
  *s = c;
    8000695c:	975e                	add	a4,a4,s7
    8000695e:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006962:	2489                	addiw	s1,s1,2
      break;
    80006964:	b719                	j	8000686a <snprintf+0x7c>
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
