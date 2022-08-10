
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
    80000060:	e4478793          	addi	a5,a5,-444 # 80005ea0 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	fe278793          	addi	a5,a5,-30 # 80001088 <main>
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
    80000110:	cce080e7          	jalr	-818(ra) # 80000dda <acquire>
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
    8000012a:	668080e7          	jalr	1640(ra) # 8000278e <either_copyin>
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
    80000152:	d40080e7          	jalr	-704(ra) # 80000e8e <release>

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
    800001a2:	c3c080e7          	jalr	-964(ra) # 80000dda <acquire>
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
    800001d2:	af8080e7          	jalr	-1288(ra) # 80001cc6 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	2f8080e7          	jalr	760(ra) # 800024d6 <sleep>
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
    8000021e:	51e080e7          	jalr	1310(ra) # 80002738 <either_copyout>
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
    8000023a:	c58080e7          	jalr	-936(ra) # 80000e8e <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	c42080e7          	jalr	-958(ra) # 80000e8e <release>
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
    800002e2:	afc080e7          	jalr	-1284(ra) # 80000dda <acquire>

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
    80000300:	4e8080e7          	jalr	1256(ra) # 800027e4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	b82080e7          	jalr	-1150(ra) # 80000e8e <release>
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
    80000454:	20c080e7          	jalr	524(ra) # 8000265c <wakeup>
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
    80000472:	00001097          	auipc	ra,0x1
    80000476:	8d8080e7          	jalr	-1832(ra) # 80000d4a <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00041797          	auipc	a5,0x41
    80000486:	54678793          	addi	a5,a5,1350 # 800419c8 <devsw>
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
    8000060e:	7d0080e7          	jalr	2000(ra) # 80000dda <acquire>
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
    80000772:	720080e7          	jalr	1824(ra) # 80000e8e <release>
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
    80000798:	5b6080e7          	jalr	1462(ra) # 80000d4a <initlock>
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
    800007ee:	560080e7          	jalr	1376(ra) # 80000d4a <initlock>
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
    8000080a:	588080e7          	jalr	1416(ra) # 80000d8e <push_off>

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
    8000083c:	5f6080e7          	jalr	1526(ra) # 80000e2e <pop_off>
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
    800008ba:	da6080e7          	jalr	-602(ra) # 8000265c <wakeup>
    
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
    800008fe:	4e0080e7          	jalr	1248(ra) # 80000dda <acquire>
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
    80000954:	b86080e7          	jalr	-1146(ra) # 800024d6 <sleep>
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
    80000998:	4fa080e7          	jalr	1274(ra) # 80000e8e <release>
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
    80000a04:	3da080e7          	jalr	986(ra) # 80000dda <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	47c080e7          	jalr	1148(ra) # 80000e8e <release>
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <acquire_refcnt>:
  return (pa - KERNBASE) / PGSIZE;
}

inline
void
acquire_refcnt(){
    80000a24:	1141                	addi	sp,sp,-16
    80000a26:	e406                	sd	ra,8(sp)
    80000a28:	e022                	sd	s0,0(sp)
    80000a2a:	0800                	addi	s0,sp,16
  acquire(&refcnt.lock);
    80000a2c:	00011517          	auipc	a0,0x11
    80000a30:	f2450513          	addi	a0,a0,-220 # 80011950 <refcnt>
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	3a6080e7          	jalr	934(ra) # 80000dda <acquire>
}
    80000a3c:	60a2                	ld	ra,8(sp)
    80000a3e:	6402                	ld	s0,0(sp)
    80000a40:	0141                	addi	sp,sp,16
    80000a42:	8082                	ret

0000000080000a44 <release_refcnt>:

inline
void
release_refcnt(){
    80000a44:	1141                	addi	sp,sp,-16
    80000a46:	e406                	sd	ra,8(sp)
    80000a48:	e022                	sd	s0,0(sp)
    80000a4a:	0800                	addi	s0,sp,16
  release(&refcnt.lock);
    80000a4c:	00011517          	auipc	a0,0x11
    80000a50:	f0450513          	addi	a0,a0,-252 # 80011950 <refcnt>
    80000a54:	00000097          	auipc	ra,0x0
    80000a58:	43a080e7          	jalr	1082(ra) # 80000e8e <release>
}
    80000a5c:	60a2                	ld	ra,8(sp)
    80000a5e:	6402                	ld	s0,0(sp)
    80000a60:	0141                	addi	sp,sp,16
    80000a62:	8082                	ret

0000000080000a64 <refcnt_setter>:

void
refcnt_setter(uint64 pa, int n){
    80000a64:	1141                	addi	sp,sp,-16
    80000a66:	e422                	sd	s0,8(sp)
    80000a68:	0800                	addi	s0,sp,16
  return (pa - KERNBASE) / PGSIZE;
    80000a6a:	800007b7          	lui	a5,0x80000
    80000a6e:	953e                	add	a0,a0,a5
    80000a70:	8131                	srli	a0,a0,0xc
  refcnt.counter[pgindex((uint64)pa)] = n;
    80000a72:	0511                	addi	a0,a0,4
    80000a74:	050a                	slli	a0,a0,0x2
    80000a76:	00011797          	auipc	a5,0x11
    80000a7a:	eda78793          	addi	a5,a5,-294 # 80011950 <refcnt>
    80000a7e:	953e                	add	a0,a0,a5
    80000a80:	c50c                	sw	a1,8(a0)
}
    80000a82:	6422                	ld	s0,8(sp)
    80000a84:	0141                	addi	sp,sp,16
    80000a86:	8082                	ret

0000000080000a88 <refcnt_getter>:

inline
uint
refcnt_getter(uint64 pa){
    80000a88:	1141                	addi	sp,sp,-16
    80000a8a:	e422                	sd	s0,8(sp)
    80000a8c:	0800                	addi	s0,sp,16
  return (pa - KERNBASE) / PGSIZE;
    80000a8e:	800007b7          	lui	a5,0x80000
    80000a92:	97aa                	add	a5,a5,a0
    80000a94:	83b1                	srli	a5,a5,0xc
  return refcnt.counter[pgindex(pa)];
    80000a96:	0791                	addi	a5,a5,4
    80000a98:	078a                	slli	a5,a5,0x2
    80000a9a:	00011717          	auipc	a4,0x11
    80000a9e:	eb670713          	addi	a4,a4,-330 # 80011950 <refcnt>
    80000aa2:	97ba                	add	a5,a5,a4
}
    80000aa4:	4788                	lw	a0,8(a5)
    80000aa6:	6422                	ld	s0,8(sp)
    80000aa8:	0141                	addi	sp,sp,16
    80000aaa:	8082                	ret

0000000080000aac <refcnt_incr>:

void
refcnt_incr(uint64 pa, int n){
    80000aac:	1101                	addi	sp,sp,-32
    80000aae:	ec06                	sd	ra,24(sp)
    80000ab0:	e822                	sd	s0,16(sp)
    80000ab2:	e426                	sd	s1,8(sp)
    80000ab4:	e04a                	sd	s2,0(sp)
    80000ab6:	1000                	addi	s0,sp,32
    80000ab8:	84aa                	mv	s1,a0
    80000aba:	892e                	mv	s2,a1
  acquire(&refcnt.lock);
    80000abc:	00011517          	auipc	a0,0x11
    80000ac0:	e9450513          	addi	a0,a0,-364 # 80011950 <refcnt>
    80000ac4:	00000097          	auipc	ra,0x0
    80000ac8:	316080e7          	jalr	790(ra) # 80000dda <acquire>
  return (pa - KERNBASE) / PGSIZE;
    80000acc:	800007b7          	lui	a5,0x80000
    80000ad0:	97a6                	add	a5,a5,s1
    80000ad2:	83b1                	srli	a5,a5,0xc
  refcnt.counter[pgindex(pa)] += n;
    80000ad4:	00011517          	auipc	a0,0x11
    80000ad8:	e7c50513          	addi	a0,a0,-388 # 80011950 <refcnt>
    80000adc:	0791                	addi	a5,a5,4
    80000ade:	078a                	slli	a5,a5,0x2
    80000ae0:	97aa                	add	a5,a5,a0
    80000ae2:	4798                	lw	a4,8(a5)
    80000ae4:	012705bb          	addw	a1,a4,s2
    80000ae8:	c78c                	sw	a1,8(a5)
  release(&refcnt.lock);
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	3a4080e7          	jalr	932(ra) # 80000e8e <release>
}
    80000af2:	60e2                	ld	ra,24(sp)
    80000af4:	6442                	ld	s0,16(sp)
    80000af6:	64a2                	ld	s1,8(sp)
    80000af8:	6902                	ld	s2,0(sp)
    80000afa:	6105                	addi	sp,sp,32
    80000afc:	8082                	ret

0000000080000afe <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	e04a                	sd	s2,0(sp)
    80000b08:	1000                	addi	s0,sp,32
    80000b0a:	892a                	mv	s2,a0
  acquire(&refcnt.lock);
    80000b0c:	00011517          	auipc	a0,0x11
    80000b10:	e4450513          	addi	a0,a0,-444 # 80011950 <refcnt>
    80000b14:	00000097          	auipc	ra,0x0
    80000b18:	2c6080e7          	jalr	710(ra) # 80000dda <acquire>
  return (pa - KERNBASE) / PGSIZE;
    80000b1c:	800004b7          	lui	s1,0x80000
    80000b20:	94ca                	add	s1,s1,s2
    80000b22:	80b1                	srli	s1,s1,0xc
  struct run *r;

  // page with refcnt > 1 should not be freed
  acquire_refcnt();
  if(refcnt.counter[pgindex((uint64)pa)] > 1){
    80000b24:	00448793          	addi	a5,s1,4 # ffffffff80000004 <end+0xfffffffefffba004>
    80000b28:	00279713          	slli	a4,a5,0x2
    80000b2c:	00011797          	auipc	a5,0x11
    80000b30:	e2478793          	addi	a5,a5,-476 # 80011950 <refcnt>
    80000b34:	97ba                	add	a5,a5,a4
    80000b36:	479c                	lw	a5,8(a5)
    80000b38:	4705                	li	a4,1
    80000b3a:	06f76c63          	bltu	a4,a5,80000bb2 <kfree+0xb4>
    refcnt.counter[pgindex((uint64)pa)] -= 1;
    release_refcnt();
    return;
  }

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000b3e:	03491793          	slli	a5,s2,0x34
    80000b42:	e7d1                	bnez	a5,80000bce <kfree+0xd0>
    80000b44:	00045797          	auipc	a5,0x45
    80000b48:	4bc78793          	addi	a5,a5,1212 # 80046000 <end>
    80000b4c:	08f96163          	bltu	s2,a5,80000bce <kfree+0xd0>
    80000b50:	47c5                	li	a5,17
    80000b52:	07ee                	slli	a5,a5,0x1b
    80000b54:	06f97d63          	bgeu	s2,a5,80000bce <kfree+0xd0>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000b58:	6605                	lui	a2,0x1
    80000b5a:	4585                	li	a1,1
    80000b5c:	854a                	mv	a0,s2
    80000b5e:	00000097          	auipc	ra,0x0
    80000b62:	378080e7          	jalr	888(ra) # 80000ed6 <memset>
  refcnt.counter[pgindex((uint64)pa)] = 0;
    80000b66:	00011517          	auipc	a0,0x11
    80000b6a:	dea50513          	addi	a0,a0,-534 # 80011950 <refcnt>
    80000b6e:	0491                	addi	s1,s1,4
    80000b70:	048a                	slli	s1,s1,0x2
    80000b72:	94aa                	add	s1,s1,a0
    80000b74:	0004a423          	sw	zero,8(s1)
  release(&refcnt.lock);
    80000b78:	00000097          	auipc	ra,0x0
    80000b7c:	316080e7          	jalr	790(ra) # 80000e8e <release>
  release_refcnt();

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000b80:	00011497          	auipc	s1,0x11
    80000b84:	db048493          	addi	s1,s1,-592 # 80011930 <kmem>
    80000b88:	8526                	mv	a0,s1
    80000b8a:	00000097          	auipc	ra,0x0
    80000b8e:	250080e7          	jalr	592(ra) # 80000dda <acquire>
  r->next = kmem.freelist;
    80000b92:	6c9c                	ld	a5,24(s1)
    80000b94:	00f93023          	sd	a5,0(s2)
  kmem.freelist = r;
    80000b98:	0124bc23          	sd	s2,24(s1)
  release(&kmem.lock);
    80000b9c:	8526                	mv	a0,s1
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	2f0080e7          	jalr	752(ra) # 80000e8e <release>
}
    80000ba6:	60e2                	ld	ra,24(sp)
    80000ba8:	6442                	ld	s0,16(sp)
    80000baa:	64a2                	ld	s1,8(sp)
    80000bac:	6902                	ld	s2,0(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    refcnt.counter[pgindex((uint64)pa)] -= 1;
    80000bb2:	00011517          	auipc	a0,0x11
    80000bb6:	d9e50513          	addi	a0,a0,-610 # 80011950 <refcnt>
    80000bba:	0491                	addi	s1,s1,4
    80000bbc:	048a                	slli	s1,s1,0x2
    80000bbe:	94aa                	add	s1,s1,a0
    80000bc0:	37fd                	addiw	a5,a5,-1
    80000bc2:	c49c                	sw	a5,8(s1)
  release(&refcnt.lock);
    80000bc4:	00000097          	auipc	ra,0x0
    80000bc8:	2ca080e7          	jalr	714(ra) # 80000e8e <release>
    return;
    80000bcc:	bfe9                	j	80000ba6 <kfree+0xa8>
    panic("kfree");
    80000bce:	00007517          	auipc	a0,0x7
    80000bd2:	49250513          	addi	a0,a0,1170 # 80008060 <digits+0x20>
    80000bd6:	00000097          	auipc	ra,0x0
    80000bda:	972080e7          	jalr	-1678(ra) # 80000548 <panic>

0000000080000bde <freerange>:
{
    80000bde:	7179                	addi	sp,sp,-48
    80000be0:	f406                	sd	ra,40(sp)
    80000be2:	f022                	sd	s0,32(sp)
    80000be4:	ec26                	sd	s1,24(sp)
    80000be6:	e84a                	sd	s2,16(sp)
    80000be8:	e44e                	sd	s3,8(sp)
    80000bea:	e052                	sd	s4,0(sp)
    80000bec:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000bee:	6785                	lui	a5,0x1
    80000bf0:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000bf4:	94aa                	add	s1,s1,a0
    80000bf6:	757d                	lui	a0,0xfffff
    80000bf8:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000bfa:	94be                	add	s1,s1,a5
    80000bfc:	0095ee63          	bltu	a1,s1,80000c18 <freerange+0x3a>
    80000c00:	892e                	mv	s2,a1
    kfree(p);
    80000c02:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000c04:	6985                	lui	s3,0x1
    kfree(p);
    80000c06:	01448533          	add	a0,s1,s4
    80000c0a:	00000097          	auipc	ra,0x0
    80000c0e:	ef4080e7          	jalr	-268(ra) # 80000afe <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000c12:	94ce                	add	s1,s1,s3
    80000c14:	fe9979e3          	bgeu	s2,s1,80000c06 <freerange+0x28>
}
    80000c18:	70a2                	ld	ra,40(sp)
    80000c1a:	7402                	ld	s0,32(sp)
    80000c1c:	64e2                	ld	s1,24(sp)
    80000c1e:	6942                	ld	s2,16(sp)
    80000c20:	69a2                	ld	s3,8(sp)
    80000c22:	6a02                	ld	s4,0(sp)
    80000c24:	6145                	addi	sp,sp,48
    80000c26:	8082                	ret

0000000080000c28 <kinit>:
{
    80000c28:	1141                	addi	sp,sp,-16
    80000c2a:	e406                	sd	ra,8(sp)
    80000c2c:	e022                	sd	s0,0(sp)
    80000c2e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000c30:	00007597          	auipc	a1,0x7
    80000c34:	43858593          	addi	a1,a1,1080 # 80008068 <digits+0x28>
    80000c38:	00011517          	auipc	a0,0x11
    80000c3c:	cf850513          	addi	a0,a0,-776 # 80011930 <kmem>
    80000c40:	00000097          	auipc	ra,0x0
    80000c44:	10a080e7          	jalr	266(ra) # 80000d4a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000c48:	45c5                	li	a1,17
    80000c4a:	05ee                	slli	a1,a1,0x1b
    80000c4c:	00045517          	auipc	a0,0x45
    80000c50:	3b450513          	addi	a0,a0,948 # 80046000 <end>
    80000c54:	00000097          	auipc	ra,0x0
    80000c58:	f8a080e7          	jalr	-118(ra) # 80000bde <freerange>
}
    80000c5c:	60a2                	ld	ra,8(sp)
    80000c5e:	6402                	ld	s0,0(sp)
    80000c60:	0141                	addi	sp,sp,16
    80000c62:	8082                	ret

0000000080000c64 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c64:	1101                	addi	sp,sp,-32
    80000c66:	ec06                	sd	ra,24(sp)
    80000c68:	e822                	sd	s0,16(sp)
    80000c6a:	e426                	sd	s1,8(sp)
    80000c6c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000c6e:	00011497          	auipc	s1,0x11
    80000c72:	cc248493          	addi	s1,s1,-830 # 80011930 <kmem>
    80000c76:	8526                	mv	a0,s1
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	162080e7          	jalr	354(ra) # 80000dda <acquire>
  r = kmem.freelist;
    80000c80:	6c84                	ld	s1,24(s1)
  if(r)
    80000c82:	cc95                	beqz	s1,80000cbe <kalloc+0x5a>
    kmem.freelist = r->next;
    80000c84:	609c                	ld	a5,0(s1)
    80000c86:	00011517          	auipc	a0,0x11
    80000c8a:	caa50513          	addi	a0,a0,-854 # 80011930 <kmem>
    80000c8e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	1fe080e7          	jalr	510(ra) # 80000e8e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c98:	6605                	lui	a2,0x1
    80000c9a:	4595                	li	a1,5
    80000c9c:	8526                	mv	a0,s1
    80000c9e:	00000097          	auipc	ra,0x0
    80000ca2:	238080e7          	jalr	568(ra) # 80000ed6 <memset>

  if(r)
    refcnt_incr((uint64)r, 1); // set refcnt to 1
    80000ca6:	4585                	li	a1,1
    80000ca8:	8526                	mv	a0,s1
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	e02080e7          	jalr	-510(ra) # 80000aac <refcnt_incr>
  return (void*)r;
}
    80000cb2:	8526                	mv	a0,s1
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
  release(&kmem.lock);
    80000cbe:	00011517          	auipc	a0,0x11
    80000cc2:	c7250513          	addi	a0,a0,-910 # 80011930 <kmem>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	1c8080e7          	jalr	456(ra) # 80000e8e <release>
  if(r)
    80000cce:	b7d5                	j	80000cb2 <kalloc+0x4e>

0000000080000cd0 <kalloc_nolock>:

void *
kalloc_nolock(void)
{
    80000cd0:	1101                	addi	sp,sp,-32
    80000cd2:	ec06                	sd	ra,24(sp)
    80000cd4:	e822                	sd	s0,16(sp)
    80000cd6:	e426                	sd	s1,8(sp)
    80000cd8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000cda:	00011497          	auipc	s1,0x11
    80000cde:	c5648493          	addi	s1,s1,-938 # 80011930 <kmem>
    80000ce2:	8526                	mv	a0,s1
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	0f6080e7          	jalr	246(ra) # 80000dda <acquire>
  r = kmem.freelist;
    80000cec:	6c84                	ld	s1,24(s1)
  if(r)
    80000cee:	c4a9                	beqz	s1,80000d38 <kalloc_nolock+0x68>
    kmem.freelist = r->next;
    80000cf0:	609c                	ld	a5,0(s1)
    80000cf2:	00011517          	auipc	a0,0x11
    80000cf6:	c3e50513          	addi	a0,a0,-962 # 80011930 <kmem>
    80000cfa:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000cfc:	00000097          	auipc	ra,0x0
    80000d00:	192080e7          	jalr	402(ra) # 80000e8e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000d04:	6605                	lui	a2,0x1
    80000d06:	4595                	li	a1,5
    80000d08:	8526                	mv	a0,s1
    80000d0a:	00000097          	auipc	ra,0x0
    80000d0e:	1cc080e7          	jalr	460(ra) # 80000ed6 <memset>
  return (pa - KERNBASE) / PGSIZE;
    80000d12:	800007b7          	lui	a5,0x80000
    80000d16:	97a6                	add	a5,a5,s1
    80000d18:	83b1                	srli	a5,a5,0xc
  refcnt.counter[pgindex((uint64)pa)] = n;
    80000d1a:	0791                	addi	a5,a5,4
    80000d1c:	078a                	slli	a5,a5,0x2
    80000d1e:	00011717          	auipc	a4,0x11
    80000d22:	c3270713          	addi	a4,a4,-974 # 80011950 <refcnt>
    80000d26:	97ba                	add	a5,a5,a4
    80000d28:	4705                	li	a4,1
    80000d2a:	c798                	sw	a4,8(a5)
  
  if(r)
    refcnt_setter((uint64)r, 1); // set refcnt to 1

  return (void*)r;
}
    80000d2c:	8526                	mv	a0,s1
    80000d2e:	60e2                	ld	ra,24(sp)
    80000d30:	6442                	ld	s0,16(sp)
    80000d32:	64a2                	ld	s1,8(sp)
    80000d34:	6105                	addi	sp,sp,32
    80000d36:	8082                	ret
  release(&kmem.lock);
    80000d38:	00011517          	auipc	a0,0x11
    80000d3c:	bf850513          	addi	a0,a0,-1032 # 80011930 <kmem>
    80000d40:	00000097          	auipc	ra,0x0
    80000d44:	14e080e7          	jalr	334(ra) # 80000e8e <release>
  if(r)
    80000d48:	b7d5                	j	80000d2c <kalloc_nolock+0x5c>

0000000080000d4a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d4a:	1141                	addi	sp,sp,-16
    80000d4c:	e422                	sd	s0,8(sp)
    80000d4e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d50:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d52:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d56:	00053823          	sd	zero,16(a0)
}
    80000d5a:	6422                	ld	s0,8(sp)
    80000d5c:	0141                	addi	sp,sp,16
    80000d5e:	8082                	ret

0000000080000d60 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d60:	411c                	lw	a5,0(a0)
    80000d62:	e399                	bnez	a5,80000d68 <holding+0x8>
    80000d64:	4501                	li	a0,0
  return r;
}
    80000d66:	8082                	ret
{
    80000d68:	1101                	addi	sp,sp,-32
    80000d6a:	ec06                	sd	ra,24(sp)
    80000d6c:	e822                	sd	s0,16(sp)
    80000d6e:	e426                	sd	s1,8(sp)
    80000d70:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d72:	6904                	ld	s1,16(a0)
    80000d74:	00001097          	auipc	ra,0x1
    80000d78:	f36080e7          	jalr	-202(ra) # 80001caa <mycpu>
    80000d7c:	40a48533          	sub	a0,s1,a0
    80000d80:	00153513          	seqz	a0,a0
}
    80000d84:	60e2                	ld	ra,24(sp)
    80000d86:	6442                	ld	s0,16(sp)
    80000d88:	64a2                	ld	s1,8(sp)
    80000d8a:	6105                	addi	sp,sp,32
    80000d8c:	8082                	ret

0000000080000d8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d8e:	1101                	addi	sp,sp,-32
    80000d90:	ec06                	sd	ra,24(sp)
    80000d92:	e822                	sd	s0,16(sp)
    80000d94:	e426                	sd	s1,8(sp)
    80000d96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d98:	100024f3          	csrr	s1,sstatus
    80000d9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000da0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000da2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000da6:	00001097          	auipc	ra,0x1
    80000daa:	f04080e7          	jalr	-252(ra) # 80001caa <mycpu>
    80000dae:	5d3c                	lw	a5,120(a0)
    80000db0:	cf89                	beqz	a5,80000dca <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000db2:	00001097          	auipc	ra,0x1
    80000db6:	ef8080e7          	jalr	-264(ra) # 80001caa <mycpu>
    80000dba:	5d3c                	lw	a5,120(a0)
    80000dbc:	2785                	addiw	a5,a5,1
    80000dbe:	dd3c                	sw	a5,120(a0)
}
    80000dc0:	60e2                	ld	ra,24(sp)
    80000dc2:	6442                	ld	s0,16(sp)
    80000dc4:	64a2                	ld	s1,8(sp)
    80000dc6:	6105                	addi	sp,sp,32
    80000dc8:	8082                	ret
    mycpu()->intena = old;
    80000dca:	00001097          	auipc	ra,0x1
    80000dce:	ee0080e7          	jalr	-288(ra) # 80001caa <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000dd2:	8085                	srli	s1,s1,0x1
    80000dd4:	8885                	andi	s1,s1,1
    80000dd6:	dd64                	sw	s1,124(a0)
    80000dd8:	bfe9                	j	80000db2 <push_off+0x24>

0000000080000dda <acquire>:
{
    80000dda:	1101                	addi	sp,sp,-32
    80000ddc:	ec06                	sd	ra,24(sp)
    80000dde:	e822                	sd	s0,16(sp)
    80000de0:	e426                	sd	s1,8(sp)
    80000de2:	1000                	addi	s0,sp,32
    80000de4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000de6:	00000097          	auipc	ra,0x0
    80000dea:	fa8080e7          	jalr	-88(ra) # 80000d8e <push_off>
  if(holding(lk))
    80000dee:	8526                	mv	a0,s1
    80000df0:	00000097          	auipc	ra,0x0
    80000df4:	f70080e7          	jalr	-144(ra) # 80000d60 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000df8:	4705                	li	a4,1
  if(holding(lk))
    80000dfa:	e115                	bnez	a0,80000e1e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dfc:	87ba                	mv	a5,a4
    80000dfe:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000e02:	2781                	sext.w	a5,a5
    80000e04:	ffe5                	bnez	a5,80000dfc <acquire+0x22>
  __sync_synchronize();
    80000e06:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e0a:	00001097          	auipc	ra,0x1
    80000e0e:	ea0080e7          	jalr	-352(ra) # 80001caa <mycpu>
    80000e12:	e888                	sd	a0,16(s1)
}
    80000e14:	60e2                	ld	ra,24(sp)
    80000e16:	6442                	ld	s0,16(sp)
    80000e18:	64a2                	ld	s1,8(sp)
    80000e1a:	6105                	addi	sp,sp,32
    80000e1c:	8082                	ret
    panic("acquire");
    80000e1e:	00007517          	auipc	a0,0x7
    80000e22:	25250513          	addi	a0,a0,594 # 80008070 <digits+0x30>
    80000e26:	fffff097          	auipc	ra,0xfffff
    80000e2a:	722080e7          	jalr	1826(ra) # 80000548 <panic>

0000000080000e2e <pop_off>:

void
pop_off(void)
{
    80000e2e:	1141                	addi	sp,sp,-16
    80000e30:	e406                	sd	ra,8(sp)
    80000e32:	e022                	sd	s0,0(sp)
    80000e34:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e36:	00001097          	auipc	ra,0x1
    80000e3a:	e74080e7          	jalr	-396(ra) # 80001caa <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e3e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e42:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e44:	e78d                	bnez	a5,80000e6e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e46:	5d3c                	lw	a5,120(a0)
    80000e48:	02f05b63          	blez	a5,80000e7e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e4c:	37fd                	addiw	a5,a5,-1
    80000e4e:	0007871b          	sext.w	a4,a5
    80000e52:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e54:	eb09                	bnez	a4,80000e66 <pop_off+0x38>
    80000e56:	5d7c                	lw	a5,124(a0)
    80000e58:	c799                	beqz	a5,80000e66 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e5a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e5e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e62:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e66:	60a2                	ld	ra,8(sp)
    80000e68:	6402                	ld	s0,0(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
    panic("pop_off - interruptible");
    80000e6e:	00007517          	auipc	a0,0x7
    80000e72:	20a50513          	addi	a0,a0,522 # 80008078 <digits+0x38>
    80000e76:	fffff097          	auipc	ra,0xfffff
    80000e7a:	6d2080e7          	jalr	1746(ra) # 80000548 <panic>
    panic("pop_off");
    80000e7e:	00007517          	auipc	a0,0x7
    80000e82:	21250513          	addi	a0,a0,530 # 80008090 <digits+0x50>
    80000e86:	fffff097          	auipc	ra,0xfffff
    80000e8a:	6c2080e7          	jalr	1730(ra) # 80000548 <panic>

0000000080000e8e <release>:
{
    80000e8e:	1101                	addi	sp,sp,-32
    80000e90:	ec06                	sd	ra,24(sp)
    80000e92:	e822                	sd	s0,16(sp)
    80000e94:	e426                	sd	s1,8(sp)
    80000e96:	1000                	addi	s0,sp,32
    80000e98:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e9a:	00000097          	auipc	ra,0x0
    80000e9e:	ec6080e7          	jalr	-314(ra) # 80000d60 <holding>
    80000ea2:	c115                	beqz	a0,80000ec6 <release+0x38>
  lk->cpu = 0;
    80000ea4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ea8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000eac:	0f50000f          	fence	iorw,ow
    80000eb0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000eb4:	00000097          	auipc	ra,0x0
    80000eb8:	f7a080e7          	jalr	-134(ra) # 80000e2e <pop_off>
}
    80000ebc:	60e2                	ld	ra,24(sp)
    80000ebe:	6442                	ld	s0,16(sp)
    80000ec0:	64a2                	ld	s1,8(sp)
    80000ec2:	6105                	addi	sp,sp,32
    80000ec4:	8082                	ret
    panic("release");
    80000ec6:	00007517          	auipc	a0,0x7
    80000eca:	1d250513          	addi	a0,a0,466 # 80008098 <digits+0x58>
    80000ece:	fffff097          	auipc	ra,0xfffff
    80000ed2:	67a080e7          	jalr	1658(ra) # 80000548 <panic>

0000000080000ed6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ed6:	1141                	addi	sp,sp,-16
    80000ed8:	e422                	sd	s0,8(sp)
    80000eda:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000edc:	ce09                	beqz	a2,80000ef6 <memset+0x20>
    80000ede:	87aa                	mv	a5,a0
    80000ee0:	fff6071b          	addiw	a4,a2,-1
    80000ee4:	1702                	slli	a4,a4,0x20
    80000ee6:	9301                	srli	a4,a4,0x20
    80000ee8:	0705                	addi	a4,a4,1
    80000eea:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000eec:	00b78023          	sb	a1,0(a5) # ffffffff80000000 <end+0xfffffffefffba000>
  for(i = 0; i < n; i++){
    80000ef0:	0785                	addi	a5,a5,1
    80000ef2:	fee79de3          	bne	a5,a4,80000eec <memset+0x16>
  }
  return dst;
}
    80000ef6:	6422                	ld	s0,8(sp)
    80000ef8:	0141                	addi	sp,sp,16
    80000efa:	8082                	ret

0000000080000efc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000efc:	1141                	addi	sp,sp,-16
    80000efe:	e422                	sd	s0,8(sp)
    80000f00:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000f02:	ca05                	beqz	a2,80000f32 <memcmp+0x36>
    80000f04:	fff6069b          	addiw	a3,a2,-1
    80000f08:	1682                	slli	a3,a3,0x20
    80000f0a:	9281                	srli	a3,a3,0x20
    80000f0c:	0685                	addi	a3,a3,1
    80000f0e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000f10:	00054783          	lbu	a5,0(a0)
    80000f14:	0005c703          	lbu	a4,0(a1)
    80000f18:	00e79863          	bne	a5,a4,80000f28 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000f1c:	0505                	addi	a0,a0,1
    80000f1e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000f20:	fed518e3          	bne	a0,a3,80000f10 <memcmp+0x14>
  }

  return 0;
    80000f24:	4501                	li	a0,0
    80000f26:	a019                	j	80000f2c <memcmp+0x30>
      return *s1 - *s2;
    80000f28:	40e7853b          	subw	a0,a5,a4
}
    80000f2c:	6422                	ld	s0,8(sp)
    80000f2e:	0141                	addi	sp,sp,16
    80000f30:	8082                	ret
  return 0;
    80000f32:	4501                	li	a0,0
    80000f34:	bfe5                	j	80000f2c <memcmp+0x30>

0000000080000f36 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f36:	1141                	addi	sp,sp,-16
    80000f38:	e422                	sd	s0,8(sp)
    80000f3a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f3c:	00a5f963          	bgeu	a1,a0,80000f4e <memmove+0x18>
    80000f40:	02061713          	slli	a4,a2,0x20
    80000f44:	9301                	srli	a4,a4,0x20
    80000f46:	00e587b3          	add	a5,a1,a4
    80000f4a:	02f56563          	bltu	a0,a5,80000f74 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f4e:	fff6069b          	addiw	a3,a2,-1
    80000f52:	ce11                	beqz	a2,80000f6e <memmove+0x38>
    80000f54:	1682                	slli	a3,a3,0x20
    80000f56:	9281                	srli	a3,a3,0x20
    80000f58:	0685                	addi	a3,a3,1
    80000f5a:	96ae                	add	a3,a3,a1
    80000f5c:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000f5e:	0585                	addi	a1,a1,1
    80000f60:	0785                	addi	a5,a5,1
    80000f62:	fff5c703          	lbu	a4,-1(a1)
    80000f66:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000f6a:	fed59ae3          	bne	a1,a3,80000f5e <memmove+0x28>

  return dst;
}
    80000f6e:	6422                	ld	s0,8(sp)
    80000f70:	0141                	addi	sp,sp,16
    80000f72:	8082                	ret
    d += n;
    80000f74:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000f76:	fff6069b          	addiw	a3,a2,-1
    80000f7a:	da75                	beqz	a2,80000f6e <memmove+0x38>
    80000f7c:	02069613          	slli	a2,a3,0x20
    80000f80:	9201                	srli	a2,a2,0x20
    80000f82:	fff64613          	not	a2,a2
    80000f86:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000f88:	17fd                	addi	a5,a5,-1
    80000f8a:	177d                	addi	a4,a4,-1
    80000f8c:	0007c683          	lbu	a3,0(a5)
    80000f90:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000f94:	fec79ae3          	bne	a5,a2,80000f88 <memmove+0x52>
    80000f98:	bfd9                	j	80000f6e <memmove+0x38>

0000000080000f9a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f9a:	1141                	addi	sp,sp,-16
    80000f9c:	e406                	sd	ra,8(sp)
    80000f9e:	e022                	sd	s0,0(sp)
    80000fa0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000fa2:	00000097          	auipc	ra,0x0
    80000fa6:	f94080e7          	jalr	-108(ra) # 80000f36 <memmove>
}
    80000faa:	60a2                	ld	ra,8(sp)
    80000fac:	6402                	ld	s0,0(sp)
    80000fae:	0141                	addi	sp,sp,16
    80000fb0:	8082                	ret

0000000080000fb2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000fb2:	1141                	addi	sp,sp,-16
    80000fb4:	e422                	sd	s0,8(sp)
    80000fb6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000fb8:	ce11                	beqz	a2,80000fd4 <strncmp+0x22>
    80000fba:	00054783          	lbu	a5,0(a0)
    80000fbe:	cf89                	beqz	a5,80000fd8 <strncmp+0x26>
    80000fc0:	0005c703          	lbu	a4,0(a1)
    80000fc4:	00f71a63          	bne	a4,a5,80000fd8 <strncmp+0x26>
    n--, p++, q++;
    80000fc8:	367d                	addiw	a2,a2,-1
    80000fca:	0505                	addi	a0,a0,1
    80000fcc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000fce:	f675                	bnez	a2,80000fba <strncmp+0x8>
  if(n == 0)
    return 0;
    80000fd0:	4501                	li	a0,0
    80000fd2:	a809                	j	80000fe4 <strncmp+0x32>
    80000fd4:	4501                	li	a0,0
    80000fd6:	a039                	j	80000fe4 <strncmp+0x32>
  if(n == 0)
    80000fd8:	ca09                	beqz	a2,80000fea <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000fda:	00054503          	lbu	a0,0(a0)
    80000fde:	0005c783          	lbu	a5,0(a1)
    80000fe2:	9d1d                	subw	a0,a0,a5
}
    80000fe4:	6422                	ld	s0,8(sp)
    80000fe6:	0141                	addi	sp,sp,16
    80000fe8:	8082                	ret
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	bfe5                	j	80000fe4 <strncmp+0x32>

0000000080000fee <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fee:	1141                	addi	sp,sp,-16
    80000ff0:	e422                	sd	s0,8(sp)
    80000ff2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ff4:	872a                	mv	a4,a0
    80000ff6:	8832                	mv	a6,a2
    80000ff8:	367d                	addiw	a2,a2,-1
    80000ffa:	01005963          	blez	a6,8000100c <strncpy+0x1e>
    80000ffe:	0705                	addi	a4,a4,1
    80001000:	0005c783          	lbu	a5,0(a1)
    80001004:	fef70fa3          	sb	a5,-1(a4)
    80001008:	0585                	addi	a1,a1,1
    8000100a:	f7f5                	bnez	a5,80000ff6 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000100c:	00c05d63          	blez	a2,80001026 <strncpy+0x38>
    80001010:	86ba                	mv	a3,a4
    *s++ = 0;
    80001012:	0685                	addi	a3,a3,1
    80001014:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001018:	fff6c793          	not	a5,a3
    8000101c:	9fb9                	addw	a5,a5,a4
    8000101e:	010787bb          	addw	a5,a5,a6
    80001022:	fef048e3          	bgtz	a5,80001012 <strncpy+0x24>
  return os;
}
    80001026:	6422                	ld	s0,8(sp)
    80001028:	0141                	addi	sp,sp,16
    8000102a:	8082                	ret

000000008000102c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000102c:	1141                	addi	sp,sp,-16
    8000102e:	e422                	sd	s0,8(sp)
    80001030:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001032:	02c05363          	blez	a2,80001058 <safestrcpy+0x2c>
    80001036:	fff6069b          	addiw	a3,a2,-1
    8000103a:	1682                	slli	a3,a3,0x20
    8000103c:	9281                	srli	a3,a3,0x20
    8000103e:	96ae                	add	a3,a3,a1
    80001040:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001042:	00d58963          	beq	a1,a3,80001054 <safestrcpy+0x28>
    80001046:	0585                	addi	a1,a1,1
    80001048:	0785                	addi	a5,a5,1
    8000104a:	fff5c703          	lbu	a4,-1(a1)
    8000104e:	fee78fa3          	sb	a4,-1(a5)
    80001052:	fb65                	bnez	a4,80001042 <safestrcpy+0x16>
    ;
  *s = 0;
    80001054:	00078023          	sb	zero,0(a5)
  return os;
}
    80001058:	6422                	ld	s0,8(sp)
    8000105a:	0141                	addi	sp,sp,16
    8000105c:	8082                	ret

000000008000105e <strlen>:

int
strlen(const char *s)
{
    8000105e:	1141                	addi	sp,sp,-16
    80001060:	e422                	sd	s0,8(sp)
    80001062:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001064:	00054783          	lbu	a5,0(a0)
    80001068:	cf91                	beqz	a5,80001084 <strlen+0x26>
    8000106a:	0505                	addi	a0,a0,1
    8000106c:	87aa                	mv	a5,a0
    8000106e:	4685                	li	a3,1
    80001070:	9e89                	subw	a3,a3,a0
    80001072:	00f6853b          	addw	a0,a3,a5
    80001076:	0785                	addi	a5,a5,1
    80001078:	fff7c703          	lbu	a4,-1(a5)
    8000107c:	fb7d                	bnez	a4,80001072 <strlen+0x14>
    ;
  return n;
}
    8000107e:	6422                	ld	s0,8(sp)
    80001080:	0141                	addi	sp,sp,16
    80001082:	8082                	ret
  for(n = 0; s[n]; n++)
    80001084:	4501                	li	a0,0
    80001086:	bfe5                	j	8000107e <strlen+0x20>

0000000080001088 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001088:	1141                	addi	sp,sp,-16
    8000108a:	e406                	sd	ra,8(sp)
    8000108c:	e022                	sd	s0,0(sp)
    8000108e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001090:	00001097          	auipc	ra,0x1
    80001094:	c0a080e7          	jalr	-1014(ra) # 80001c9a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001098:	00008717          	auipc	a4,0x8
    8000109c:	f7470713          	addi	a4,a4,-140 # 8000900c <started>
  if(cpuid() == 0){
    800010a0:	c139                	beqz	a0,800010e6 <main+0x5e>
    while(started == 0)
    800010a2:	431c                	lw	a5,0(a4)
    800010a4:	2781                	sext.w	a5,a5
    800010a6:	dff5                	beqz	a5,800010a2 <main+0x1a>
      ;
    __sync_synchronize();
    800010a8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800010ac:	00001097          	auipc	ra,0x1
    800010b0:	bee080e7          	jalr	-1042(ra) # 80001c9a <cpuid>
    800010b4:	85aa                	mv	a1,a0
    800010b6:	00007517          	auipc	a0,0x7
    800010ba:	00250513          	addi	a0,a0,2 # 800080b8 <digits+0x78>
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	4d4080e7          	jalr	1236(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    800010c6:	00000097          	auipc	ra,0x0
    800010ca:	0d8080e7          	jalr	216(ra) # 8000119e <kvminithart>
    trapinithart();   // install kernel trap vector
    800010ce:	00002097          	auipc	ra,0x2
    800010d2:	856080e7          	jalr	-1962(ra) # 80002924 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800010d6:	00005097          	auipc	ra,0x5
    800010da:	e0a080e7          	jalr	-502(ra) # 80005ee0 <plicinithart>
  }

  scheduler();        
    800010de:	00001097          	auipc	ra,0x1
    800010e2:	118080e7          	jalr	280(ra) # 800021f6 <scheduler>
    consoleinit();
    800010e6:	fffff097          	auipc	ra,0xfffff
    800010ea:	374080e7          	jalr	884(ra) # 8000045a <consoleinit>
    printfinit();
    800010ee:	fffff097          	auipc	ra,0xfffff
    800010f2:	68a080e7          	jalr	1674(ra) # 80000778 <printfinit>
    printf("\n");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	fd250513          	addi	a0,a0,-46 # 800080c8 <digits+0x88>
    800010fe:	fffff097          	auipc	ra,0xfffff
    80001102:	494080e7          	jalr	1172(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80001106:	00007517          	auipc	a0,0x7
    8000110a:	f9a50513          	addi	a0,a0,-102 # 800080a0 <digits+0x60>
    8000110e:	fffff097          	auipc	ra,0xfffff
    80001112:	484080e7          	jalr	1156(ra) # 80000592 <printf>
    printf("\n");
    80001116:	00007517          	auipc	a0,0x7
    8000111a:	fb250513          	addi	a0,a0,-78 # 800080c8 <digits+0x88>
    8000111e:	fffff097          	auipc	ra,0xfffff
    80001122:	474080e7          	jalr	1140(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80001126:	00000097          	auipc	ra,0x0
    8000112a:	b02080e7          	jalr	-1278(ra) # 80000c28 <kinit>
    kvminit();       // create kernel page table
    8000112e:	00000097          	auipc	ra,0x0
    80001132:	28a080e7          	jalr	650(ra) # 800013b8 <kvminit>
    kvminithart();   // turn on paging
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	068080e7          	jalr	104(ra) # 8000119e <kvminithart>
    procinit();      // process table
    8000113e:	00001097          	auipc	ra,0x1
    80001142:	a8c080e7          	jalr	-1396(ra) # 80001bca <procinit>
    trapinit();      // trap vectors
    80001146:	00001097          	auipc	ra,0x1
    8000114a:	7b6080e7          	jalr	1974(ra) # 800028fc <trapinit>
    trapinithart();  // install kernel trap vector
    8000114e:	00001097          	auipc	ra,0x1
    80001152:	7d6080e7          	jalr	2006(ra) # 80002924 <trapinithart>
    plicinit();      // set up interrupt controller
    80001156:	00005097          	auipc	ra,0x5
    8000115a:	d74080e7          	jalr	-652(ra) # 80005eca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000115e:	00005097          	auipc	ra,0x5
    80001162:	d82080e7          	jalr	-638(ra) # 80005ee0 <plicinithart>
    binit();         // buffer cache
    80001166:	00002097          	auipc	ra,0x2
    8000116a:	f24080e7          	jalr	-220(ra) # 8000308a <binit>
    iinit();         // inode cache
    8000116e:	00002097          	auipc	ra,0x2
    80001172:	5b4080e7          	jalr	1460(ra) # 80003722 <iinit>
    fileinit();      // file table
    80001176:	00003097          	auipc	ra,0x3
    8000117a:	552080e7          	jalr	1362(ra) # 800046c8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000117e:	00005097          	auipc	ra,0x5
    80001182:	e6a080e7          	jalr	-406(ra) # 80005fe8 <virtio_disk_init>
    userinit();      // first user process
    80001186:	00001097          	auipc	ra,0x1
    8000118a:	e0a080e7          	jalr	-502(ra) # 80001f90 <userinit>
    __sync_synchronize();
    8000118e:	0ff0000f          	fence
    started = 1;
    80001192:	4785                	li	a5,1
    80001194:	00008717          	auipc	a4,0x8
    80001198:	e6f72c23          	sw	a5,-392(a4) # 8000900c <started>
    8000119c:	b789                	j	800010de <main+0x56>

000000008000119e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e422                	sd	s0,8(sp)
    800011a2:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    800011a4:	00008797          	auipc	a5,0x8
    800011a8:	e6c7b783          	ld	a5,-404(a5) # 80009010 <kernel_pagetable>
    800011ac:	83b1                	srli	a5,a5,0xc
    800011ae:	577d                	li	a4,-1
    800011b0:	177e                	slli	a4,a4,0x3f
    800011b2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800011b4:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800011b8:	12000073          	sfence.vma
  sfence_vma();
}
    800011bc:	6422                	ld	s0,8(sp)
    800011be:	0141                	addi	sp,sp,16
    800011c0:	8082                	ret

00000000800011c2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800011c2:	7139                	addi	sp,sp,-64
    800011c4:	fc06                	sd	ra,56(sp)
    800011c6:	f822                	sd	s0,48(sp)
    800011c8:	f426                	sd	s1,40(sp)
    800011ca:	f04a                	sd	s2,32(sp)
    800011cc:	ec4e                	sd	s3,24(sp)
    800011ce:	e852                	sd	s4,16(sp)
    800011d0:	e456                	sd	s5,8(sp)
    800011d2:	e05a                	sd	s6,0(sp)
    800011d4:	0080                	addi	s0,sp,64
    800011d6:	84aa                	mv	s1,a0
    800011d8:	89ae                	mv	s3,a1
    800011da:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800011dc:	57fd                	li	a5,-1
    800011de:	83e9                	srli	a5,a5,0x1a
    800011e0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800011e2:	4b31                	li	s6,12
  if(va >= MAXVA)
    800011e4:	04b7f263          	bgeu	a5,a1,80001228 <walk+0x66>
    panic("walk");
    800011e8:	00007517          	auipc	a0,0x7
    800011ec:	ee850513          	addi	a0,a0,-280 # 800080d0 <digits+0x90>
    800011f0:	fffff097          	auipc	ra,0xfffff
    800011f4:	358080e7          	jalr	856(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800011f8:	060a8663          	beqz	s5,80001264 <walk+0xa2>
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	a68080e7          	jalr	-1432(ra) # 80000c64 <kalloc>
    80001204:	84aa                	mv	s1,a0
    80001206:	c529                	beqz	a0,80001250 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001208:	6605                	lui	a2,0x1
    8000120a:	4581                	li	a1,0
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	cca080e7          	jalr	-822(ra) # 80000ed6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001214:	00c4d793          	srli	a5,s1,0xc
    80001218:	07aa                	slli	a5,a5,0xa
    8000121a:	0017e793          	ori	a5,a5,1
    8000121e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001222:	3a5d                	addiw	s4,s4,-9
    80001224:	036a0063          	beq	s4,s6,80001244 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001228:	0149d933          	srl	s2,s3,s4
    8000122c:	1ff97913          	andi	s2,s2,511
    80001230:	090e                	slli	s2,s2,0x3
    80001232:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001234:	00093483          	ld	s1,0(s2)
    80001238:	0014f793          	andi	a5,s1,1
    8000123c:	dfd5                	beqz	a5,800011f8 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000123e:	80a9                	srli	s1,s1,0xa
    80001240:	04b2                	slli	s1,s1,0xc
    80001242:	b7c5                	j	80001222 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001244:	00c9d513          	srli	a0,s3,0xc
    80001248:	1ff57513          	andi	a0,a0,511
    8000124c:	050e                	slli	a0,a0,0x3
    8000124e:	9526                	add	a0,a0,s1
}
    80001250:	70e2                	ld	ra,56(sp)
    80001252:	7442                	ld	s0,48(sp)
    80001254:	74a2                	ld	s1,40(sp)
    80001256:	7902                	ld	s2,32(sp)
    80001258:	69e2                	ld	s3,24(sp)
    8000125a:	6a42                	ld	s4,16(sp)
    8000125c:	6aa2                	ld	s5,8(sp)
    8000125e:	6b02                	ld	s6,0(sp)
    80001260:	6121                	addi	sp,sp,64
    80001262:	8082                	ret
        return 0;
    80001264:	4501                	li	a0,0
    80001266:	b7ed                	j	80001250 <walk+0x8e>

0000000080001268 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001268:	57fd                	li	a5,-1
    8000126a:	83e9                	srli	a5,a5,0x1a
    8000126c:	00b7f463          	bgeu	a5,a1,80001274 <walkaddr+0xc>
    return 0;
    80001270:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001272:	8082                	ret
{
    80001274:	1141                	addi	sp,sp,-16
    80001276:	e406                	sd	ra,8(sp)
    80001278:	e022                	sd	s0,0(sp)
    8000127a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000127c:	4601                	li	a2,0
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f44080e7          	jalr	-188(ra) # 800011c2 <walk>
  if(pte == 0)
    80001286:	c105                	beqz	a0,800012a6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001288:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000128a:	0117f693          	andi	a3,a5,17
    8000128e:	4745                	li	a4,17
    return 0;
    80001290:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001292:	00e68663          	beq	a3,a4,8000129e <walkaddr+0x36>
}
    80001296:	60a2                	ld	ra,8(sp)
    80001298:	6402                	ld	s0,0(sp)
    8000129a:	0141                	addi	sp,sp,16
    8000129c:	8082                	ret
  pa = PTE2PA(*pte);
    8000129e:	00a7d513          	srli	a0,a5,0xa
    800012a2:	0532                	slli	a0,a0,0xc
  return pa;
    800012a4:	bfcd                	j	80001296 <walkaddr+0x2e>
    return 0;
    800012a6:	4501                	li	a0,0
    800012a8:	b7fd                	j	80001296 <walkaddr+0x2e>

00000000800012aa <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800012aa:	1101                	addi	sp,sp,-32
    800012ac:	ec06                	sd	ra,24(sp)
    800012ae:	e822                	sd	s0,16(sp)
    800012b0:	e426                	sd	s1,8(sp)
    800012b2:	1000                	addi	s0,sp,32
    800012b4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800012b6:	1552                	slli	a0,a0,0x34
    800012b8:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800012bc:	4601                	li	a2,0
    800012be:	00008517          	auipc	a0,0x8
    800012c2:	d5253503          	ld	a0,-686(a0) # 80009010 <kernel_pagetable>
    800012c6:	00000097          	auipc	ra,0x0
    800012ca:	efc080e7          	jalr	-260(ra) # 800011c2 <walk>
  if(pte == 0)
    800012ce:	cd09                	beqz	a0,800012e8 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800012d0:	6108                	ld	a0,0(a0)
    800012d2:	00157793          	andi	a5,a0,1
    800012d6:	c38d                	beqz	a5,800012f8 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800012d8:	8129                	srli	a0,a0,0xa
    800012da:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    800012dc:	9526                	add	a0,a0,s1
    800012de:	60e2                	ld	ra,24(sp)
    800012e0:	6442                	ld	s0,16(sp)
    800012e2:	64a2                	ld	s1,8(sp)
    800012e4:	6105                	addi	sp,sp,32
    800012e6:	8082                	ret
    panic("kvmpa");
    800012e8:	00007517          	auipc	a0,0x7
    800012ec:	df050513          	addi	a0,a0,-528 # 800080d8 <digits+0x98>
    800012f0:	fffff097          	auipc	ra,0xfffff
    800012f4:	258080e7          	jalr	600(ra) # 80000548 <panic>
    panic("kvmpa");
    800012f8:	00007517          	auipc	a0,0x7
    800012fc:	de050513          	addi	a0,a0,-544 # 800080d8 <digits+0x98>
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	248080e7          	jalr	584(ra) # 80000548 <panic>

0000000080001308 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001308:	715d                	addi	sp,sp,-80
    8000130a:	e486                	sd	ra,72(sp)
    8000130c:	e0a2                	sd	s0,64(sp)
    8000130e:	fc26                	sd	s1,56(sp)
    80001310:	f84a                	sd	s2,48(sp)
    80001312:	f44e                	sd	s3,40(sp)
    80001314:	f052                	sd	s4,32(sp)
    80001316:	ec56                	sd	s5,24(sp)
    80001318:	e85a                	sd	s6,16(sp)
    8000131a:	e45e                	sd	s7,8(sp)
    8000131c:	0880                	addi	s0,sp,80
    8000131e:	8aaa                	mv	s5,a0
    80001320:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001322:	777d                	lui	a4,0xfffff
    80001324:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001328:	167d                	addi	a2,a2,-1
    8000132a:	00b609b3          	add	s3,a2,a1
    8000132e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001332:	893e                	mv	s2,a5
    80001334:	40f68a33          	sub	s4,a3,a5
    // if(*pte & PTE_V)
    //   panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001338:	6b85                	lui	s7,0x1
    8000133a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000133e:	4605                	li	a2,1
    80001340:	85ca                	mv	a1,s2
    80001342:	8556                	mv	a0,s5
    80001344:	00000097          	auipc	ra,0x0
    80001348:	e7e080e7          	jalr	-386(ra) # 800011c2 <walk>
    8000134c:	cd01                	beqz	a0,80001364 <mappages+0x5c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000134e:	80b1                	srli	s1,s1,0xc
    80001350:	04aa                	slli	s1,s1,0xa
    80001352:	0164e4b3          	or	s1,s1,s6
    80001356:	0014e493          	ori	s1,s1,1
    8000135a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000135c:	03390063          	beq	s2,s3,8000137c <mappages+0x74>
    a += PGSIZE;
    80001360:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001362:	bfe1                	j	8000133a <mappages+0x32>
      return -1;
    80001364:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001366:	60a6                	ld	ra,72(sp)
    80001368:	6406                	ld	s0,64(sp)
    8000136a:	74e2                	ld	s1,56(sp)
    8000136c:	7942                	ld	s2,48(sp)
    8000136e:	79a2                	ld	s3,40(sp)
    80001370:	7a02                	ld	s4,32(sp)
    80001372:	6ae2                	ld	s5,24(sp)
    80001374:	6b42                	ld	s6,16(sp)
    80001376:	6ba2                	ld	s7,8(sp)
    80001378:	6161                	addi	sp,sp,80
    8000137a:	8082                	ret
  return 0;
    8000137c:	4501                	li	a0,0
    8000137e:	b7e5                	j	80001366 <mappages+0x5e>

0000000080001380 <kvmmap>:
{
    80001380:	1141                	addi	sp,sp,-16
    80001382:	e406                	sd	ra,8(sp)
    80001384:	e022                	sd	s0,0(sp)
    80001386:	0800                	addi	s0,sp,16
    80001388:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000138a:	86ae                	mv	a3,a1
    8000138c:	85aa                	mv	a1,a0
    8000138e:	00008517          	auipc	a0,0x8
    80001392:	c8253503          	ld	a0,-894(a0) # 80009010 <kernel_pagetable>
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	f72080e7          	jalr	-142(ra) # 80001308 <mappages>
    8000139e:	e509                	bnez	a0,800013a8 <kvmmap+0x28>
}
    800013a0:	60a2                	ld	ra,8(sp)
    800013a2:	6402                	ld	s0,0(sp)
    800013a4:	0141                	addi	sp,sp,16
    800013a6:	8082                	ret
    panic("kvmmap");
    800013a8:	00007517          	auipc	a0,0x7
    800013ac:	d3850513          	addi	a0,a0,-712 # 800080e0 <digits+0xa0>
    800013b0:	fffff097          	auipc	ra,0xfffff
    800013b4:	198080e7          	jalr	408(ra) # 80000548 <panic>

00000000800013b8 <kvminit>:
{
    800013b8:	1101                	addi	sp,sp,-32
    800013ba:	ec06                	sd	ra,24(sp)
    800013bc:	e822                	sd	s0,16(sp)
    800013be:	e426                	sd	s1,8(sp)
    800013c0:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	8a2080e7          	jalr	-1886(ra) # 80000c64 <kalloc>
    800013ca:	00008797          	auipc	a5,0x8
    800013ce:	c4a7b323          	sd	a0,-954(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800013d2:	6605                	lui	a2,0x1
    800013d4:	4581                	li	a1,0
    800013d6:	00000097          	auipc	ra,0x0
    800013da:	b00080e7          	jalr	-1280(ra) # 80000ed6 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013de:	4699                	li	a3,6
    800013e0:	6605                	lui	a2,0x1
    800013e2:	100005b7          	lui	a1,0x10000
    800013e6:	10000537          	lui	a0,0x10000
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	f96080e7          	jalr	-106(ra) # 80001380 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013f2:	4699                	li	a3,6
    800013f4:	6605                	lui	a2,0x1
    800013f6:	100015b7          	lui	a1,0x10001
    800013fa:	10001537          	lui	a0,0x10001
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	f82080e7          	jalr	-126(ra) # 80001380 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001406:	4699                	li	a3,6
    80001408:	6641                	lui	a2,0x10
    8000140a:	020005b7          	lui	a1,0x2000
    8000140e:	02000537          	lui	a0,0x2000
    80001412:	00000097          	auipc	ra,0x0
    80001416:	f6e080e7          	jalr	-146(ra) # 80001380 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000141a:	4699                	li	a3,6
    8000141c:	00400637          	lui	a2,0x400
    80001420:	0c0005b7          	lui	a1,0xc000
    80001424:	0c000537          	lui	a0,0xc000
    80001428:	00000097          	auipc	ra,0x0
    8000142c:	f58080e7          	jalr	-168(ra) # 80001380 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001430:	00007497          	auipc	s1,0x7
    80001434:	bd048493          	addi	s1,s1,-1072 # 80008000 <etext>
    80001438:	46a9                	li	a3,10
    8000143a:	80007617          	auipc	a2,0x80007
    8000143e:	bc660613          	addi	a2,a2,-1082 # 8000 <_entry-0x7fff8000>
    80001442:	4585                	li	a1,1
    80001444:	05fe                	slli	a1,a1,0x1f
    80001446:	852e                	mv	a0,a1
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	f38080e7          	jalr	-200(ra) # 80001380 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001450:	4699                	li	a3,6
    80001452:	4645                	li	a2,17
    80001454:	066e                	slli	a2,a2,0x1b
    80001456:	8e05                	sub	a2,a2,s1
    80001458:	85a6                	mv	a1,s1
    8000145a:	8526                	mv	a0,s1
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	f24080e7          	jalr	-220(ra) # 80001380 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001464:	46a9                	li	a3,10
    80001466:	6605                	lui	a2,0x1
    80001468:	00006597          	auipc	a1,0x6
    8000146c:	b9858593          	addi	a1,a1,-1128 # 80007000 <_trampoline>
    80001470:	04000537          	lui	a0,0x4000
    80001474:	157d                	addi	a0,a0,-1
    80001476:	0532                	slli	a0,a0,0xc
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	f08080e7          	jalr	-248(ra) # 80001380 <kvmmap>
}
    80001480:	60e2                	ld	ra,24(sp)
    80001482:	6442                	ld	s0,16(sp)
    80001484:	64a2                	ld	s1,8(sp)
    80001486:	6105                	addi	sp,sp,32
    80001488:	8082                	ret

000000008000148a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800014a0:	03459793          	slli	a5,a1,0x34
    800014a4:	e795                	bnez	a5,800014d0 <uvmunmap+0x46>
    800014a6:	8a2a                	mv	s4,a0
    800014a8:	892e                	mv	s2,a1
    800014aa:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014ac:	0632                	slli	a2,a2,0xc
    800014ae:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800014b2:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014b4:	6b05                	lui	s6,0x1
    800014b6:	0735e863          	bltu	a1,s3,80001526 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    panic("uvmunmap: not aligned");
    800014d0:	00007517          	auipc	a0,0x7
    800014d4:	c1850513          	addi	a0,a0,-1000 # 800080e8 <digits+0xa8>
    800014d8:	fffff097          	auipc	ra,0xfffff
    800014dc:	070080e7          	jalr	112(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    800014e0:	00007517          	auipc	a0,0x7
    800014e4:	c2050513          	addi	a0,a0,-992 # 80008100 <digits+0xc0>
    800014e8:	fffff097          	auipc	ra,0xfffff
    800014ec:	060080e7          	jalr	96(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    800014f0:	00007517          	auipc	a0,0x7
    800014f4:	c2050513          	addi	a0,a0,-992 # 80008110 <digits+0xd0>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	050080e7          	jalr	80(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    80001500:	00007517          	auipc	a0,0x7
    80001504:	c2850513          	addi	a0,a0,-984 # 80008128 <digits+0xe8>
    80001508:	fffff097          	auipc	ra,0xfffff
    8000150c:	040080e7          	jalr	64(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    80001510:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001512:	0532                	slli	a0,a0,0xc
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	5ea080e7          	jalr	1514(ra) # 80000afe <kfree>
    *pte = 0;
    8000151c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001520:	995a                	add	s2,s2,s6
    80001522:	f9397ce3          	bgeu	s2,s3,800014ba <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001526:	4601                	li	a2,0
    80001528:	85ca                	mv	a1,s2
    8000152a:	8552                	mv	a0,s4
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	c96080e7          	jalr	-874(ra) # 800011c2 <walk>
    80001534:	84aa                	mv	s1,a0
    80001536:	d54d                	beqz	a0,800014e0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001538:	6108                	ld	a0,0(a0)
    8000153a:	00157793          	andi	a5,a0,1
    8000153e:	dbcd                	beqz	a5,800014f0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001540:	3ff57793          	andi	a5,a0,1023
    80001544:	fb778ee3          	beq	a5,s7,80001500 <uvmunmap+0x76>
    if(do_free){
    80001548:	fc0a8ae3          	beqz	s5,8000151c <uvmunmap+0x92>
    8000154c:	b7d1                	j	80001510 <uvmunmap+0x86>

000000008000154e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000154e:	1101                	addi	sp,sp,-32
    80001550:	ec06                	sd	ra,24(sp)
    80001552:	e822                	sd	s0,16(sp)
    80001554:	e426                	sd	s1,8(sp)
    80001556:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001558:	fffff097          	auipc	ra,0xfffff
    8000155c:	70c080e7          	jalr	1804(ra) # 80000c64 <kalloc>
    80001560:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001562:	c519                	beqz	a0,80001570 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001564:	6605                	lui	a2,0x1
    80001566:	4581                	li	a1,0
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	96e080e7          	jalr	-1682(ra) # 80000ed6 <memset>
  return pagetable;
}
    80001570:	8526                	mv	a0,s1
    80001572:	60e2                	ld	ra,24(sp)
    80001574:	6442                	ld	s0,16(sp)
    80001576:	64a2                	ld	s1,8(sp)
    80001578:	6105                	addi	sp,sp,32
    8000157a:	8082                	ret

000000008000157c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000157c:	7179                	addi	sp,sp,-48
    8000157e:	f406                	sd	ra,40(sp)
    80001580:	f022                	sd	s0,32(sp)
    80001582:	ec26                	sd	s1,24(sp)
    80001584:	e84a                	sd	s2,16(sp)
    80001586:	e44e                	sd	s3,8(sp)
    80001588:	e052                	sd	s4,0(sp)
    8000158a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000158c:	6785                	lui	a5,0x1
    8000158e:	04f67863          	bgeu	a2,a5,800015de <uvminit+0x62>
    80001592:	8a2a                	mv	s4,a0
    80001594:	89ae                	mv	s3,a1
    80001596:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001598:	fffff097          	auipc	ra,0xfffff
    8000159c:	6cc080e7          	jalr	1740(ra) # 80000c64 <kalloc>
    800015a0:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800015a2:	6605                	lui	a2,0x1
    800015a4:	4581                	li	a1,0
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	930080e7          	jalr	-1744(ra) # 80000ed6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015ae:	4779                	li	a4,30
    800015b0:	86ca                	mv	a3,s2
    800015b2:	6605                	lui	a2,0x1
    800015b4:	4581                	li	a1,0
    800015b6:	8552                	mv	a0,s4
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	d50080e7          	jalr	-688(ra) # 80001308 <mappages>
  memmove(mem, src, sz);
    800015c0:	8626                	mv	a2,s1
    800015c2:	85ce                	mv	a1,s3
    800015c4:	854a                	mv	a0,s2
    800015c6:	00000097          	auipc	ra,0x0
    800015ca:	970080e7          	jalr	-1680(ra) # 80000f36 <memmove>
}
    800015ce:	70a2                	ld	ra,40(sp)
    800015d0:	7402                	ld	s0,32(sp)
    800015d2:	64e2                	ld	s1,24(sp)
    800015d4:	6942                	ld	s2,16(sp)
    800015d6:	69a2                	ld	s3,8(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	6145                	addi	sp,sp,48
    800015dc:	8082                	ret
    panic("inituvm: more than a page");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	b6250513          	addi	a0,a0,-1182 # 80008140 <digits+0x100>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f62080e7          	jalr	-158(ra) # 80000548 <panic>

00000000800015ee <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800015ee:	1101                	addi	sp,sp,-32
    800015f0:	ec06                	sd	ra,24(sp)
    800015f2:	e822                	sd	s0,16(sp)
    800015f4:	e426                	sd	s1,8(sp)
    800015f6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800015f8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015fa:	00b67d63          	bgeu	a2,a1,80001614 <uvmdealloc+0x26>
    800015fe:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001600:	6785                	lui	a5,0x1
    80001602:	17fd                	addi	a5,a5,-1
    80001604:	00f60733          	add	a4,a2,a5
    80001608:	767d                	lui	a2,0xfffff
    8000160a:	8f71                	and	a4,a4,a2
    8000160c:	97ae                	add	a5,a5,a1
    8000160e:	8ff1                	and	a5,a5,a2
    80001610:	00f76863          	bltu	a4,a5,80001620 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001614:	8526                	mv	a0,s1
    80001616:	60e2                	ld	ra,24(sp)
    80001618:	6442                	ld	s0,16(sp)
    8000161a:	64a2                	ld	s1,8(sp)
    8000161c:	6105                	addi	sp,sp,32
    8000161e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001620:	8f99                	sub	a5,a5,a4
    80001622:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001624:	4685                	li	a3,1
    80001626:	0007861b          	sext.w	a2,a5
    8000162a:	85ba                	mv	a1,a4
    8000162c:	00000097          	auipc	ra,0x0
    80001630:	e5e080e7          	jalr	-418(ra) # 8000148a <uvmunmap>
    80001634:	b7c5                	j	80001614 <uvmdealloc+0x26>

0000000080001636 <uvmalloc>:
  if(newsz < oldsz)
    80001636:	0ab66163          	bltu	a2,a1,800016d8 <uvmalloc+0xa2>
{
    8000163a:	7139                	addi	sp,sp,-64
    8000163c:	fc06                	sd	ra,56(sp)
    8000163e:	f822                	sd	s0,48(sp)
    80001640:	f426                	sd	s1,40(sp)
    80001642:	f04a                	sd	s2,32(sp)
    80001644:	ec4e                	sd	s3,24(sp)
    80001646:	e852                	sd	s4,16(sp)
    80001648:	e456                	sd	s5,8(sp)
    8000164a:	0080                	addi	s0,sp,64
    8000164c:	8aaa                	mv	s5,a0
    8000164e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001650:	6985                	lui	s3,0x1
    80001652:	19fd                	addi	s3,s3,-1
    80001654:	95ce                	add	a1,a1,s3
    80001656:	79fd                	lui	s3,0xfffff
    80001658:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000165c:	08c9f063          	bgeu	s3,a2,800016dc <uvmalloc+0xa6>
    80001660:	894e                	mv	s2,s3
    mem = kalloc();
    80001662:	fffff097          	auipc	ra,0xfffff
    80001666:	602080e7          	jalr	1538(ra) # 80000c64 <kalloc>
    8000166a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000166c:	c51d                	beqz	a0,8000169a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000166e:	6605                	lui	a2,0x1
    80001670:	4581                	li	a1,0
    80001672:	00000097          	auipc	ra,0x0
    80001676:	864080e7          	jalr	-1948(ra) # 80000ed6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000167a:	4779                	li	a4,30
    8000167c:	86a6                	mv	a3,s1
    8000167e:	6605                	lui	a2,0x1
    80001680:	85ca                	mv	a1,s2
    80001682:	8556                	mv	a0,s5
    80001684:	00000097          	auipc	ra,0x0
    80001688:	c84080e7          	jalr	-892(ra) # 80001308 <mappages>
    8000168c:	e905                	bnez	a0,800016bc <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000168e:	6785                	lui	a5,0x1
    80001690:	993e                	add	s2,s2,a5
    80001692:	fd4968e3          	bltu	s2,s4,80001662 <uvmalloc+0x2c>
  return newsz;
    80001696:	8552                	mv	a0,s4
    80001698:	a809                	j	800016aa <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000169a:	864e                	mv	a2,s3
    8000169c:	85ca                	mv	a1,s2
    8000169e:	8556                	mv	a0,s5
    800016a0:	00000097          	auipc	ra,0x0
    800016a4:	f4e080e7          	jalr	-178(ra) # 800015ee <uvmdealloc>
      return 0;
    800016a8:	4501                	li	a0,0
}
    800016aa:	70e2                	ld	ra,56(sp)
    800016ac:	7442                	ld	s0,48(sp)
    800016ae:	74a2                	ld	s1,40(sp)
    800016b0:	7902                	ld	s2,32(sp)
    800016b2:	69e2                	ld	s3,24(sp)
    800016b4:	6a42                	ld	s4,16(sp)
    800016b6:	6aa2                	ld	s5,8(sp)
    800016b8:	6121                	addi	sp,sp,64
    800016ba:	8082                	ret
      kfree(mem);
    800016bc:	8526                	mv	a0,s1
    800016be:	fffff097          	auipc	ra,0xfffff
    800016c2:	440080e7          	jalr	1088(ra) # 80000afe <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016c6:	864e                	mv	a2,s3
    800016c8:	85ca                	mv	a1,s2
    800016ca:	8556                	mv	a0,s5
    800016cc:	00000097          	auipc	ra,0x0
    800016d0:	f22080e7          	jalr	-222(ra) # 800015ee <uvmdealloc>
      return 0;
    800016d4:	4501                	li	a0,0
    800016d6:	bfd1                	j	800016aa <uvmalloc+0x74>
    return oldsz;
    800016d8:	852e                	mv	a0,a1
}
    800016da:	8082                	ret
  return newsz;
    800016dc:	8532                	mv	a0,a2
    800016de:	b7f1                	j	800016aa <uvmalloc+0x74>

00000000800016e0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800016e0:	7179                	addi	sp,sp,-48
    800016e2:	f406                	sd	ra,40(sp)
    800016e4:	f022                	sd	s0,32(sp)
    800016e6:	ec26                	sd	s1,24(sp)
    800016e8:	e84a                	sd	s2,16(sp)
    800016ea:	e44e                	sd	s3,8(sp)
    800016ec:	e052                	sd	s4,0(sp)
    800016ee:	1800                	addi	s0,sp,48
    800016f0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016f2:	84aa                	mv	s1,a0
    800016f4:	6905                	lui	s2,0x1
    800016f6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016f8:	4985                	li	s3,1
    800016fa:	a821                	j	80001712 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016fc:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800016fe:	0532                	slli	a0,a0,0xc
    80001700:	00000097          	auipc	ra,0x0
    80001704:	fe0080e7          	jalr	-32(ra) # 800016e0 <freewalk>
      pagetable[i] = 0;
    80001708:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000170c:	04a1                	addi	s1,s1,8
    8000170e:	03248163          	beq	s1,s2,80001730 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001712:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001714:	00f57793          	andi	a5,a0,15
    80001718:	ff3782e3          	beq	a5,s3,800016fc <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000171c:	8905                	andi	a0,a0,1
    8000171e:	d57d                	beqz	a0,8000170c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001720:	00007517          	auipc	a0,0x7
    80001724:	a4050513          	addi	a0,a0,-1472 # 80008160 <digits+0x120>
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	e20080e7          	jalr	-480(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	3cc080e7          	jalr	972(ra) # 80000afe <kfree>
}
    8000173a:	70a2                	ld	ra,40(sp)
    8000173c:	7402                	ld	s0,32(sp)
    8000173e:	64e2                	ld	s1,24(sp)
    80001740:	6942                	ld	s2,16(sp)
    80001742:	69a2                	ld	s3,8(sp)
    80001744:	6a02                	ld	s4,0(sp)
    80001746:	6145                	addi	sp,sp,48
    80001748:	8082                	ret

000000008000174a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000174a:	1101                	addi	sp,sp,-32
    8000174c:	ec06                	sd	ra,24(sp)
    8000174e:	e822                	sd	s0,16(sp)
    80001750:	e426                	sd	s1,8(sp)
    80001752:	1000                	addi	s0,sp,32
    80001754:	84aa                	mv	s1,a0
  if(sz > 0)
    80001756:	e999                	bnez	a1,8000176c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001758:	8526                	mv	a0,s1
    8000175a:	00000097          	auipc	ra,0x0
    8000175e:	f86080e7          	jalr	-122(ra) # 800016e0 <freewalk>
}
    80001762:	60e2                	ld	ra,24(sp)
    80001764:	6442                	ld	s0,16(sp)
    80001766:	64a2                	ld	s1,8(sp)
    80001768:	6105                	addi	sp,sp,32
    8000176a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000176c:	6605                	lui	a2,0x1
    8000176e:	167d                	addi	a2,a2,-1
    80001770:	962e                	add	a2,a2,a1
    80001772:	4685                	li	a3,1
    80001774:	8231                	srli	a2,a2,0xc
    80001776:	4581                	li	a1,0
    80001778:	00000097          	auipc	ra,0x0
    8000177c:	d12080e7          	jalr	-750(ra) # 8000148a <uvmunmap>
    80001780:	bfe1                	j	80001758 <uvmfree+0xe>

0000000080001782 <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    80001782:	7139                	addi	sp,sp,-64
    80001784:	fc06                	sd	ra,56(sp)
    80001786:	f822                	sd	s0,48(sp)
    80001788:	f426                	sd	s1,40(sp)
    8000178a:	f04a                	sd	s2,32(sp)
    8000178c:	ec4e                	sd	s3,24(sp)
    8000178e:	e852                	sd	s4,16(sp)
    80001790:	e456                	sd	s5,8(sp)
    80001792:	e05a                	sd	s6,0(sp)
    80001794:	0080                	addi	s0,sp,64
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001796:	c65d                	beqz	a2,80001844 <uvmcopy+0xc2>
    80001798:	8b2a                	mv	s6,a0
    8000179a:	8aae                	mv	s5,a1
    8000179c:	8a32                	mv	s4,a2
    8000179e:	4481                	li	s1,0
    if((pte = walk(old, i, 0)) == 0)
    800017a0:	4601                	li	a2,0
    800017a2:	85a6                	mv	a1,s1
    800017a4:	855a                	mv	a0,s6
    800017a6:	00000097          	auipc	ra,0x0
    800017aa:	a1c080e7          	jalr	-1508(ra) # 800011c2 <walk>
    800017ae:	c531                	beqz	a0,800017fa <uvmcopy+0x78>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800017b0:	6118                	ld	a4,0(a0)
    800017b2:	00177793          	andi	a5,a4,1
    800017b6:	cbb1                	beqz	a5,8000180a <uvmcopy+0x88>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800017b8:	00a75913          	srli	s2,a4,0xa
    800017bc:	0932                	slli	s2,s2,0xc
    flags = PTE_FLAGS(*pte);

    *pte = ((*pte) & (~PTE_W)) | PTE_COW; // set parent's page unwritable
    800017be:	efb77793          	andi	a5,a4,-261
    800017c2:	1007e793          	ori	a5,a5,256
    800017c6:	e11c                	sd	a5,0(a0)
    // printf("c: %p %p %p\n", i, ((flags & (~PTE_W)) | PTE_COW), *pte);
    // map child's page with page unwritable
    if(mappages(new, i, PGSIZE, (uint64)pa, (flags & (~PTE_W)) | PTE_COW) != 0){
    800017c8:	2fb77713          	andi	a4,a4,763
    800017cc:	10076713          	ori	a4,a4,256
    800017d0:	86ca                	mv	a3,s2
    800017d2:	6605                	lui	a2,0x1
    800017d4:	85a6                	mv	a1,s1
    800017d6:	8556                	mv	a0,s5
    800017d8:	00000097          	auipc	ra,0x0
    800017dc:	b30080e7          	jalr	-1232(ra) # 80001308 <mappages>
    800017e0:	89aa                	mv	s3,a0
    800017e2:	ed05                	bnez	a0,8000181a <uvmcopy+0x98>
      goto err;
    }
    refcnt_incr(pa, 1);
    800017e4:	4585                	li	a1,1
    800017e6:	854a                	mv	a0,s2
    800017e8:	fffff097          	auipc	ra,0xfffff
    800017ec:	2c4080e7          	jalr	708(ra) # 80000aac <refcnt_incr>
  for(i = 0; i < sz; i += PGSIZE){
    800017f0:	6785                	lui	a5,0x1
    800017f2:	94be                	add	s1,s1,a5
    800017f4:	fb44e6e3          	bltu	s1,s4,800017a0 <uvmcopy+0x1e>
    800017f8:	a81d                	j	8000182e <uvmcopy+0xac>
      panic("uvmcopy: pte should exist");
    800017fa:	00007517          	auipc	a0,0x7
    800017fe:	97650513          	addi	a0,a0,-1674 # 80008170 <digits+0x130>
    80001802:	fffff097          	auipc	ra,0xfffff
    80001806:	d46080e7          	jalr	-698(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    8000180a:	00007517          	auipc	a0,0x7
    8000180e:	98650513          	addi	a0,a0,-1658 # 80008190 <digits+0x150>
    80001812:	fffff097          	auipc	ra,0xfffff
    80001816:	d36080e7          	jalr	-714(ra) # 80000548 <panic>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000181a:	4685                	li	a3,1
    8000181c:	00c4d613          	srli	a2,s1,0xc
    80001820:	4581                	li	a1,0
    80001822:	8556                	mv	a0,s5
    80001824:	00000097          	auipc	ra,0x0
    80001828:	c66080e7          	jalr	-922(ra) # 8000148a <uvmunmap>
  return -1;
    8000182c:	59fd                	li	s3,-1
}
    8000182e:	854e                	mv	a0,s3
    80001830:	70e2                	ld	ra,56(sp)
    80001832:	7442                	ld	s0,48(sp)
    80001834:	74a2                	ld	s1,40(sp)
    80001836:	7902                	ld	s2,32(sp)
    80001838:	69e2                	ld	s3,24(sp)
    8000183a:	6a42                	ld	s4,16(sp)
    8000183c:	6aa2                	ld	s5,8(sp)
    8000183e:	6b02                	ld	s6,0(sp)
    80001840:	6121                	addi	sp,sp,64
    80001842:	8082                	ret
  return 0;
    80001844:	4981                	li	s3,0
    80001846:	b7e5                	j	8000182e <uvmcopy+0xac>

0000000080001848 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001848:	1141                	addi	sp,sp,-16
    8000184a:	e406                	sd	ra,8(sp)
    8000184c:	e022                	sd	s0,0(sp)
    8000184e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001850:	4601                	li	a2,0
    80001852:	00000097          	auipc	ra,0x0
    80001856:	970080e7          	jalr	-1680(ra) # 800011c2 <walk>
  if(pte == 0)
    8000185a:	c901                	beqz	a0,8000186a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000185c:	611c                	ld	a5,0(a0)
    8000185e:	9bbd                	andi	a5,a5,-17
    80001860:	e11c                	sd	a5,0(a0)
}
    80001862:	60a2                	ld	ra,8(sp)
    80001864:	6402                	ld	s0,0(sp)
    80001866:	0141                	addi	sp,sp,16
    80001868:	8082                	ret
    panic("uvmclear");
    8000186a:	00007517          	auipc	a0,0x7
    8000186e:	94650513          	addi	a0,a0,-1722 # 800081b0 <digits+0x170>
    80001872:	fffff097          	auipc	ra,0xfffff
    80001876:	cd6080e7          	jalr	-810(ra) # 80000548 <panic>

000000008000187a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000187a:	c6bd                	beqz	a3,800018e8 <copyin+0x6e>
{
    8000187c:	715d                	addi	sp,sp,-80
    8000187e:	e486                	sd	ra,72(sp)
    80001880:	e0a2                	sd	s0,64(sp)
    80001882:	fc26                	sd	s1,56(sp)
    80001884:	f84a                	sd	s2,48(sp)
    80001886:	f44e                	sd	s3,40(sp)
    80001888:	f052                	sd	s4,32(sp)
    8000188a:	ec56                	sd	s5,24(sp)
    8000188c:	e85a                	sd	s6,16(sp)
    8000188e:	e45e                	sd	s7,8(sp)
    80001890:	e062                	sd	s8,0(sp)
    80001892:	0880                	addi	s0,sp,80
    80001894:	8b2a                	mv	s6,a0
    80001896:	8a2e                	mv	s4,a1
    80001898:	8c32                	mv	s8,a2
    8000189a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000189c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000189e:	6a85                	lui	s5,0x1
    800018a0:	a015                	j	800018c4 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018a2:	9562                	add	a0,a0,s8
    800018a4:	0004861b          	sext.w	a2,s1
    800018a8:	412505b3          	sub	a1,a0,s2
    800018ac:	8552                	mv	a0,s4
    800018ae:	fffff097          	auipc	ra,0xfffff
    800018b2:	688080e7          	jalr	1672(ra) # 80000f36 <memmove>

    len -= n;
    800018b6:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018ba:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018bc:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018c0:	02098263          	beqz	s3,800018e4 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    800018c4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018c8:	85ca                	mv	a1,s2
    800018ca:	855a                	mv	a0,s6
    800018cc:	00000097          	auipc	ra,0x0
    800018d0:	99c080e7          	jalr	-1636(ra) # 80001268 <walkaddr>
    if(pa0 == 0)
    800018d4:	cd01                	beqz	a0,800018ec <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    800018d6:	418904b3          	sub	s1,s2,s8
    800018da:	94d6                	add	s1,s1,s5
    if(n > len)
    800018dc:	fc99f3e3          	bgeu	s3,s1,800018a2 <copyin+0x28>
    800018e0:	84ce                	mv	s1,s3
    800018e2:	b7c1                	j	800018a2 <copyin+0x28>
  }
  return 0;
    800018e4:	4501                	li	a0,0
    800018e6:	a021                	j	800018ee <copyin+0x74>
    800018e8:	4501                	li	a0,0
}
    800018ea:	8082                	ret
      return -1;
    800018ec:	557d                	li	a0,-1
}
    800018ee:	60a6                	ld	ra,72(sp)
    800018f0:	6406                	ld	s0,64(sp)
    800018f2:	74e2                	ld	s1,56(sp)
    800018f4:	7942                	ld	s2,48(sp)
    800018f6:	79a2                	ld	s3,40(sp)
    800018f8:	7a02                	ld	s4,32(sp)
    800018fa:	6ae2                	ld	s5,24(sp)
    800018fc:	6b42                	ld	s6,16(sp)
    800018fe:	6ba2                	ld	s7,8(sp)
    80001900:	6c02                	ld	s8,0(sp)
    80001902:	6161                	addi	sp,sp,80
    80001904:	8082                	ret

0000000080001906 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001906:	c6c5                	beqz	a3,800019ae <copyinstr+0xa8>
{
    80001908:	715d                	addi	sp,sp,-80
    8000190a:	e486                	sd	ra,72(sp)
    8000190c:	e0a2                	sd	s0,64(sp)
    8000190e:	fc26                	sd	s1,56(sp)
    80001910:	f84a                	sd	s2,48(sp)
    80001912:	f44e                	sd	s3,40(sp)
    80001914:	f052                	sd	s4,32(sp)
    80001916:	ec56                	sd	s5,24(sp)
    80001918:	e85a                	sd	s6,16(sp)
    8000191a:	e45e                	sd	s7,8(sp)
    8000191c:	0880                	addi	s0,sp,80
    8000191e:	8a2a                	mv	s4,a0
    80001920:	8b2e                	mv	s6,a1
    80001922:	8bb2                	mv	s7,a2
    80001924:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001926:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001928:	6985                	lui	s3,0x1
    8000192a:	a035                	j	80001956 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000192c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001930:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001932:	0017b793          	seqz	a5,a5
    80001936:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000193a:	60a6                	ld	ra,72(sp)
    8000193c:	6406                	ld	s0,64(sp)
    8000193e:	74e2                	ld	s1,56(sp)
    80001940:	7942                	ld	s2,48(sp)
    80001942:	79a2                	ld	s3,40(sp)
    80001944:	7a02                	ld	s4,32(sp)
    80001946:	6ae2                	ld	s5,24(sp)
    80001948:	6b42                	ld	s6,16(sp)
    8000194a:	6ba2                	ld	s7,8(sp)
    8000194c:	6161                	addi	sp,sp,80
    8000194e:	8082                	ret
    srcva = va0 + PGSIZE;
    80001950:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001954:	c8a9                	beqz	s1,800019a6 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001956:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000195a:	85ca                	mv	a1,s2
    8000195c:	8552                	mv	a0,s4
    8000195e:	00000097          	auipc	ra,0x0
    80001962:	90a080e7          	jalr	-1782(ra) # 80001268 <walkaddr>
    if(pa0 == 0)
    80001966:	c131                	beqz	a0,800019aa <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001968:	41790833          	sub	a6,s2,s7
    8000196c:	984e                	add	a6,a6,s3
    if(n > max)
    8000196e:	0104f363          	bgeu	s1,a6,80001974 <copyinstr+0x6e>
    80001972:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001974:	955e                	add	a0,a0,s7
    80001976:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000197a:	fc080be3          	beqz	a6,80001950 <copyinstr+0x4a>
    8000197e:	985a                	add	a6,a6,s6
    80001980:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001982:	41650633          	sub	a2,a0,s6
    80001986:	14fd                	addi	s1,s1,-1
    80001988:	9b26                	add	s6,s6,s1
    8000198a:	00f60733          	add	a4,a2,a5
    8000198e:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb9000>
    80001992:	df49                	beqz	a4,8000192c <copyinstr+0x26>
        *dst = *p;
    80001994:	00e78023          	sb	a4,0(a5)
      --max;
    80001998:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000199c:	0785                	addi	a5,a5,1
    while(n > 0){
    8000199e:	ff0796e3          	bne	a5,a6,8000198a <copyinstr+0x84>
      dst++;
    800019a2:	8b42                	mv	s6,a6
    800019a4:	b775                	j	80001950 <copyinstr+0x4a>
    800019a6:	4781                	li	a5,0
    800019a8:	b769                	j	80001932 <copyinstr+0x2c>
      return -1;
    800019aa:	557d                	li	a0,-1
    800019ac:	b779                	j	8000193a <copyinstr+0x34>
  int got_null = 0;
    800019ae:	4781                	li	a5,0
  if(got_null){
    800019b0:	0017b793          	seqz	a5,a5
    800019b4:	40f00533          	neg	a0,a5
}
    800019b8:	8082                	ret

00000000800019ba <cowcopy>:

int
cowcopy(uint64 va){
    800019ba:	7139                	addi	sp,sp,-64
    800019bc:	fc06                	sd	ra,56(sp)
    800019be:	f822                	sd	s0,48(sp)
    800019c0:	f426                	sd	s1,40(sp)
    800019c2:	f04a                	sd	s2,32(sp)
    800019c4:	ec4e                	sd	s3,24(sp)
    800019c6:	e852                	sd	s4,16(sp)
    800019c8:	e456                	sd	s5,8(sp)
    800019ca:	e05a                	sd	s6,0(sp)
    800019cc:	0080                	addi	s0,sp,64
  va = PGROUNDDOWN(va);
    800019ce:	77fd                	lui	a5,0xfffff
    800019d0:	00f57a33          	and	s4,a0,a5
  pagetable_t p = myproc()->pagetable;
    800019d4:	00000097          	auipc	ra,0x0
    800019d8:	2f2080e7          	jalr	754(ra) # 80001cc6 <myproc>
    800019dc:	05053b03          	ld	s6,80(a0)
  pte_t* pte = walk(p, va, 0);
    800019e0:	4601                	li	a2,0
    800019e2:	85d2                	mv	a1,s4
    800019e4:	855a                	mv	a0,s6
    800019e6:	fffff097          	auipc	ra,0xfffff
    800019ea:	7dc080e7          	jalr	2012(ra) # 800011c2 <walk>
  uint64 pa = PTE2PA(*pte);
    800019ee:	6118                	ld	a4,0(a0)
  uint flags = PTE_FLAGS(*pte);
    800019f0:	0007049b          	sext.w	s1,a4

  // printf("w: %p %p %p\n", va, flags, *pte);

  if(!(flags & PTE_COW)){
    800019f4:	1004f793          	andi	a5,s1,256
    800019f8:	cbb1                	beqz	a5,80001a4c <cowcopy+0x92>
    800019fa:	892a                	mv	s2,a0
    800019fc:	00a75993          	srli	s3,a4,0xa
    80001a00:	09b2                	slli	s3,s3,0xc
    printf("not cow\n");
    return -2; // not cow page
  }

  acquire_refcnt();
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	022080e7          	jalr	34(ra) # 80000a24 <acquire_refcnt>
  uint ref = refcnt_getter(pa);
    80001a0a:	854e                	mv	a0,s3
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	07c080e7          	jalr	124(ra) # 80000a88 <refcnt_getter>
    80001a14:	00050a9b          	sext.w	s5,a0
  // printf("%d\n", *ref);
  if(ref > 1){
    80001a18:	4785                	li	a5,1
    80001a1a:	0557e363          	bltu	a5,s5,80001a60 <cowcopy+0xa6>
      goto bad;
    }
    refcnt_setter(pa, ref - 1);
  }else{
    // ref = 1, use this page directly
    *pte = ((*pte) & (~PTE_COW)) | PTE_W;
    80001a1e:	00093783          	ld	a5,0(s2) # 1000 <_entry-0x7ffff000>
    80001a22:	efb7f793          	andi	a5,a5,-261
    80001a26:	0047e793          	ori	a5,a5,4
    80001a2a:	00f93023          	sd	a5,0(s2)
  }
  release_refcnt();
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	016080e7          	jalr	22(ra) # 80000a44 <release_refcnt>
  return 0;
    80001a36:	4501                	li	a0,0

  bad:
  release_refcnt();
  return -1;
}
    80001a38:	70e2                	ld	ra,56(sp)
    80001a3a:	7442                	ld	s0,48(sp)
    80001a3c:	74a2                	ld	s1,40(sp)
    80001a3e:	7902                	ld	s2,32(sp)
    80001a40:	69e2                	ld	s3,24(sp)
    80001a42:	6a42                	ld	s4,16(sp)
    80001a44:	6aa2                	ld	s5,8(sp)
    80001a46:	6b02                	ld	s6,0(sp)
    80001a48:	6121                	addi	sp,sp,64
    80001a4a:	8082                	ret
    printf("not cow\n");
    80001a4c:	00006517          	auipc	a0,0x6
    80001a50:	77450513          	addi	a0,a0,1908 # 800081c0 <digits+0x180>
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	b3e080e7          	jalr	-1218(ra) # 80000592 <printf>
    return -2; // not cow page
    80001a5c:	5579                	li	a0,-2
    80001a5e:	bfe9                	j	80001a38 <cowcopy+0x7e>
    char* mem = kalloc_nolock();
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	270080e7          	jalr	624(ra) # 80000cd0 <kalloc_nolock>
    80001a68:	892a                	mv	s2,a0
    if(mem == 0)
    80001a6a:	c129                	beqz	a0,80001aac <cowcopy+0xf2>
    memmove(mem, (char*)pa, PGSIZE);
    80001a6c:	6605                	lui	a2,0x1
    80001a6e:	85ce                	mv	a1,s3
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	4c6080e7          	jalr	1222(ra) # 80000f36 <memmove>
    if(mappages(p, va, PGSIZE, (uint64)mem, (flags & (~PTE_COW)) | PTE_W) != 0){
    80001a78:	2fb4f713          	andi	a4,s1,763
    80001a7c:	00476713          	ori	a4,a4,4
    80001a80:	86ca                	mv	a3,s2
    80001a82:	6605                	lui	a2,0x1
    80001a84:	85d2                	mv	a1,s4
    80001a86:	855a                	mv	a0,s6
    80001a88:	00000097          	auipc	ra,0x0
    80001a8c:	880080e7          	jalr	-1920(ra) # 80001308 <mappages>
    80001a90:	e909                	bnez	a0,80001aa2 <cowcopy+0xe8>
    refcnt_setter(pa, ref - 1);
    80001a92:	fffa859b          	addiw	a1,s5,-1
    80001a96:	854e                	mv	a0,s3
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	fcc080e7          	jalr	-52(ra) # 80000a64 <refcnt_setter>
    80001aa0:	b779                	j	80001a2e <cowcopy+0x74>
      kfree(mem);
    80001aa2:	854a                	mv	a0,s2
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	05a080e7          	jalr	90(ra) # 80000afe <kfree>
  release_refcnt();
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	f98080e7          	jalr	-104(ra) # 80000a44 <release_refcnt>
  return -1;
    80001ab4:	557d                	li	a0,-1
    80001ab6:	b749                	j	80001a38 <cowcopy+0x7e>

0000000080001ab8 <copyout>:
  while(len > 0){
    80001ab8:	c2dd                	beqz	a3,80001b5e <copyout+0xa6>
{
    80001aba:	711d                	addi	sp,sp,-96
    80001abc:	ec86                	sd	ra,88(sp)
    80001abe:	e8a2                	sd	s0,80(sp)
    80001ac0:	e4a6                	sd	s1,72(sp)
    80001ac2:	e0ca                	sd	s2,64(sp)
    80001ac4:	fc4e                	sd	s3,56(sp)
    80001ac6:	f852                	sd	s4,48(sp)
    80001ac8:	f456                	sd	s5,40(sp)
    80001aca:	f05a                	sd	s6,32(sp)
    80001acc:	ec5e                	sd	s7,24(sp)
    80001ace:	e862                	sd	s8,16(sp)
    80001ad0:	e466                	sd	s9,8(sp)
    80001ad2:	1080                	addi	s0,sp,96
    80001ad4:	8b2a                	mv	s6,a0
    80001ad6:	8a2e                	mv	s4,a1
    80001ad8:	8ab2                	mv	s5,a2
    80001ada:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001adc:	74fd                	lui	s1,0xfffff
    80001ade:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001ae0:	57fd                	li	a5,-1
    80001ae2:	83e9                	srli	a5,a5,0x1a
    80001ae4:	0697ef63          	bltu	a5,s1,80001b62 <copyout+0xaa>
    80001ae8:	6c05                	lui	s8,0x1
    80001aea:	8bbe                	mv	s7,a5
    80001aec:	a825                	j	80001b24 <copyout+0x6c>
      if(cowcopy(va0) != 0){
    80001aee:	8526                	mv	a0,s1
    80001af0:	00000097          	auipc	ra,0x0
    80001af4:	eca080e7          	jalr	-310(ra) # 800019ba <cowcopy>
    80001af8:	c131                	beqz	a0,80001b3c <copyout+0x84>
        return -1;
    80001afa:	557d                	li	a0,-1
    80001afc:	a885                	j	80001b6c <copyout+0xb4>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001afe:	409a04b3          	sub	s1,s4,s1
    80001b02:	0009061b          	sext.w	a2,s2
    80001b06:	85d6                	mv	a1,s5
    80001b08:	9526                	add	a0,a0,s1
    80001b0a:	fffff097          	auipc	ra,0xfffff
    80001b0e:	42c080e7          	jalr	1068(ra) # 80000f36 <memmove>
    len -= n;
    80001b12:	412989b3          	sub	s3,s3,s2
    src += n;
    80001b16:	9aca                	add	s5,s5,s2
  while(len > 0){
    80001b18:	04098163          	beqz	s3,80001b5a <copyout+0xa2>
    if(va0 >= MAXVA)
    80001b1c:	059be563          	bltu	s7,s9,80001b66 <copyout+0xae>
    va0 = PGROUNDDOWN(dstva);
    80001b20:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80001b22:	8a66                	mv	s4,s9
    pte_t* pte = walk(pagetable, va0, 0);
    80001b24:	4601                	li	a2,0
    80001b26:	85a6                	mv	a1,s1
    80001b28:	855a                	mv	a0,s6
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	698080e7          	jalr	1688(ra) # 800011c2 <walk>
    if(pte && (*pte & PTE_COW) != 0){
    80001b32:	c509                	beqz	a0,80001b3c <copyout+0x84>
    80001b34:	611c                	ld	a5,0(a0)
    80001b36:	1007f793          	andi	a5,a5,256
    80001b3a:	fbd5                	bnez	a5,80001aee <copyout+0x36>
    pa0 = walkaddr(pagetable, va0);
    80001b3c:	85a6                	mv	a1,s1
    80001b3e:	855a                	mv	a0,s6
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	728080e7          	jalr	1832(ra) # 80001268 <walkaddr>
    if(pa0 == 0)
    80001b48:	c10d                	beqz	a0,80001b6a <copyout+0xb2>
    n = PGSIZE - (dstva - va0);
    80001b4a:	01848cb3          	add	s9,s1,s8
    80001b4e:	414c8933          	sub	s2,s9,s4
    if(n > len)
    80001b52:	fb29f6e3          	bgeu	s3,s2,80001afe <copyout+0x46>
    80001b56:	894e                	mv	s2,s3
    80001b58:	b75d                	j	80001afe <copyout+0x46>
  return 0;
    80001b5a:	4501                	li	a0,0
    80001b5c:	a801                	j	80001b6c <copyout+0xb4>
    80001b5e:	4501                	li	a0,0
}
    80001b60:	8082                	ret
      return -1;
    80001b62:	557d                	li	a0,-1
    80001b64:	a021                	j	80001b6c <copyout+0xb4>
    80001b66:	557d                	li	a0,-1
    80001b68:	a011                	j	80001b6c <copyout+0xb4>
      return -1;
    80001b6a:	557d                	li	a0,-1
}
    80001b6c:	60e6                	ld	ra,88(sp)
    80001b6e:	6446                	ld	s0,80(sp)
    80001b70:	64a6                	ld	s1,72(sp)
    80001b72:	6906                	ld	s2,64(sp)
    80001b74:	79e2                	ld	s3,56(sp)
    80001b76:	7a42                	ld	s4,48(sp)
    80001b78:	7aa2                	ld	s5,40(sp)
    80001b7a:	7b02                	ld	s6,32(sp)
    80001b7c:	6be2                	ld	s7,24(sp)
    80001b7e:	6c42                	ld	s8,16(sp)
    80001b80:	6ca2                	ld	s9,8(sp)
    80001b82:	6125                	addi	sp,sp,96
    80001b84:	8082                	ret

0000000080001b86 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001b86:	1101                	addi	sp,sp,-32
    80001b88:	ec06                	sd	ra,24(sp)
    80001b8a:	e822                	sd	s0,16(sp)
    80001b8c:	e426                	sd	s1,8(sp)
    80001b8e:	1000                	addi	s0,sp,32
    80001b90:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	1ce080e7          	jalr	462(ra) # 80000d60 <holding>
    80001b9a:	c909                	beqz	a0,80001bac <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001b9c:	749c                	ld	a5,40(s1)
    80001b9e:	00978f63          	beq	a5,s1,80001bbc <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001ba2:	60e2                	ld	ra,24(sp)
    80001ba4:	6442                	ld	s0,16(sp)
    80001ba6:	64a2                	ld	s1,8(sp)
    80001ba8:	6105                	addi	sp,sp,32
    80001baa:	8082                	ret
    panic("wakeup1");
    80001bac:	00006517          	auipc	a0,0x6
    80001bb0:	62450513          	addi	a0,a0,1572 # 800081d0 <digits+0x190>
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	994080e7          	jalr	-1644(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001bbc:	4c98                	lw	a4,24(s1)
    80001bbe:	4785                	li	a5,1
    80001bc0:	fef711e3          	bne	a4,a5,80001ba2 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001bc4:	4789                	li	a5,2
    80001bc6:	cc9c                	sw	a5,24(s1)
}
    80001bc8:	bfe9                	j	80001ba2 <wakeup1+0x1c>

0000000080001bca <procinit>:
{
    80001bca:	715d                	addi	sp,sp,-80
    80001bcc:	e486                	sd	ra,72(sp)
    80001bce:	e0a2                	sd	s0,64(sp)
    80001bd0:	fc26                	sd	s1,56(sp)
    80001bd2:	f84a                	sd	s2,48(sp)
    80001bd4:	f44e                	sd	s3,40(sp)
    80001bd6:	f052                	sd	s4,32(sp)
    80001bd8:	ec56                	sd	s5,24(sp)
    80001bda:	e85a                	sd	s6,16(sp)
    80001bdc:	e45e                	sd	s7,8(sp)
    80001bde:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001be0:	00006597          	auipc	a1,0x6
    80001be4:	5f858593          	addi	a1,a1,1528 # 800081d8 <digits+0x198>
    80001be8:	00030517          	auipc	a0,0x30
    80001bec:	d8050513          	addi	a0,a0,-640 # 80031968 <pid_lock>
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	15a080e7          	jalr	346(ra) # 80000d4a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf8:	00030917          	auipc	s2,0x30
    80001bfc:	18890913          	addi	s2,s2,392 # 80031d80 <proc>
      initlock(&p->lock, "proc");
    80001c00:	00006b97          	auipc	s7,0x6
    80001c04:	5e0b8b93          	addi	s7,s7,1504 # 800081e0 <digits+0x1a0>
      uint64 va = KSTACK((int) (p - proc));
    80001c08:	8b4a                	mv	s6,s2
    80001c0a:	00006a97          	auipc	s5,0x6
    80001c0e:	3f6a8a93          	addi	s5,s5,1014 # 80008000 <etext>
    80001c12:	040009b7          	lui	s3,0x4000
    80001c16:	19fd                	addi	s3,s3,-1
    80001c18:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c1a:	00036a17          	auipc	s4,0x36
    80001c1e:	b66a0a13          	addi	s4,s4,-1178 # 80037780 <tickslock>
      initlock(&p->lock, "proc");
    80001c22:	85de                	mv	a1,s7
    80001c24:	854a                	mv	a0,s2
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	124080e7          	jalr	292(ra) # 80000d4a <initlock>
      char *pa = kalloc();
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	036080e7          	jalr	54(ra) # 80000c64 <kalloc>
    80001c36:	85aa                	mv	a1,a0
      if(pa == 0)
    80001c38:	c929                	beqz	a0,80001c8a <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001c3a:	416904b3          	sub	s1,s2,s6
    80001c3e:	848d                	srai	s1,s1,0x3
    80001c40:	000ab783          	ld	a5,0(s5)
    80001c44:	02f484b3          	mul	s1,s1,a5
    80001c48:	2485                	addiw	s1,s1,1
    80001c4a:	00d4949b          	slliw	s1,s1,0xd
    80001c4e:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c52:	4699                	li	a3,6
    80001c54:	6605                	lui	a2,0x1
    80001c56:	8526                	mv	a0,s1
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	728080e7          	jalr	1832(ra) # 80001380 <kvmmap>
      p->kstack = va;
    80001c60:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c64:	16890913          	addi	s2,s2,360
    80001c68:	fb491de3          	bne	s2,s4,80001c22 <procinit+0x58>
  kvminithart();
    80001c6c:	fffff097          	auipc	ra,0xfffff
    80001c70:	532080e7          	jalr	1330(ra) # 8000119e <kvminithart>
}
    80001c74:	60a6                	ld	ra,72(sp)
    80001c76:	6406                	ld	s0,64(sp)
    80001c78:	74e2                	ld	s1,56(sp)
    80001c7a:	7942                	ld	s2,48(sp)
    80001c7c:	79a2                	ld	s3,40(sp)
    80001c7e:	7a02                	ld	s4,32(sp)
    80001c80:	6ae2                	ld	s5,24(sp)
    80001c82:	6b42                	ld	s6,16(sp)
    80001c84:	6ba2                	ld	s7,8(sp)
    80001c86:	6161                	addi	sp,sp,80
    80001c88:	8082                	ret
        panic("kalloc");
    80001c8a:	00006517          	auipc	a0,0x6
    80001c8e:	55e50513          	addi	a0,a0,1374 # 800081e8 <digits+0x1a8>
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	8b6080e7          	jalr	-1866(ra) # 80000548 <panic>

0000000080001c9a <cpuid>:
{
    80001c9a:	1141                	addi	sp,sp,-16
    80001c9c:	e422                	sd	s0,8(sp)
    80001c9e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ca0:	8512                	mv	a0,tp
}
    80001ca2:	2501                	sext.w	a0,a0
    80001ca4:	6422                	ld	s0,8(sp)
    80001ca6:	0141                	addi	sp,sp,16
    80001ca8:	8082                	ret

0000000080001caa <mycpu>:
mycpu(void) {
    80001caa:	1141                	addi	sp,sp,-16
    80001cac:	e422                	sd	s0,8(sp)
    80001cae:	0800                	addi	s0,sp,16
    80001cb0:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001cb2:	2781                	sext.w	a5,a5
    80001cb4:	079e                	slli	a5,a5,0x7
}
    80001cb6:	00030517          	auipc	a0,0x30
    80001cba:	cca50513          	addi	a0,a0,-822 # 80031980 <cpus>
    80001cbe:	953e                	add	a0,a0,a5
    80001cc0:	6422                	ld	s0,8(sp)
    80001cc2:	0141                	addi	sp,sp,16
    80001cc4:	8082                	ret

0000000080001cc6 <myproc>:
myproc(void) {
    80001cc6:	1101                	addi	sp,sp,-32
    80001cc8:	ec06                	sd	ra,24(sp)
    80001cca:	e822                	sd	s0,16(sp)
    80001ccc:	e426                	sd	s1,8(sp)
    80001cce:	1000                	addi	s0,sp,32
  push_off();
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	0be080e7          	jalr	190(ra) # 80000d8e <push_off>
    80001cd8:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001cda:	2781                	sext.w	a5,a5
    80001cdc:	079e                	slli	a5,a5,0x7
    80001cde:	00030717          	auipc	a4,0x30
    80001ce2:	c8a70713          	addi	a4,a4,-886 # 80031968 <pid_lock>
    80001ce6:	97ba                	add	a5,a5,a4
    80001ce8:	6f84                	ld	s1,24(a5)
  pop_off();
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	144080e7          	jalr	324(ra) # 80000e2e <pop_off>
}
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6105                	addi	sp,sp,32
    80001cfc:	8082                	ret

0000000080001cfe <forkret>:
{
    80001cfe:	1141                	addi	sp,sp,-16
    80001d00:	e406                	sd	ra,8(sp)
    80001d02:	e022                	sd	s0,0(sp)
    80001d04:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	fc0080e7          	jalr	-64(ra) # 80001cc6 <myproc>
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	180080e7          	jalr	384(ra) # 80000e8e <release>
  if (first) {
    80001d16:	00007797          	auipc	a5,0x7
    80001d1a:	b0a7a783          	lw	a5,-1270(a5) # 80008820 <first.1676>
    80001d1e:	eb89                	bnez	a5,80001d30 <forkret+0x32>
  usertrapret();
    80001d20:	00001097          	auipc	ra,0x1
    80001d24:	c1c080e7          	jalr	-996(ra) # 8000293c <usertrapret>
}
    80001d28:	60a2                	ld	ra,8(sp)
    80001d2a:	6402                	ld	s0,0(sp)
    80001d2c:	0141                	addi	sp,sp,16
    80001d2e:	8082                	ret
    first = 0;
    80001d30:	00007797          	auipc	a5,0x7
    80001d34:	ae07a823          	sw	zero,-1296(a5) # 80008820 <first.1676>
    fsinit(ROOTDEV);
    80001d38:	4505                	li	a0,1
    80001d3a:	00002097          	auipc	ra,0x2
    80001d3e:	968080e7          	jalr	-1688(ra) # 800036a2 <fsinit>
    80001d42:	bff9                	j	80001d20 <forkret+0x22>

0000000080001d44 <allocpid>:
allocpid() {
    80001d44:	1101                	addi	sp,sp,-32
    80001d46:	ec06                	sd	ra,24(sp)
    80001d48:	e822                	sd	s0,16(sp)
    80001d4a:	e426                	sd	s1,8(sp)
    80001d4c:	e04a                	sd	s2,0(sp)
    80001d4e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d50:	00030917          	auipc	s2,0x30
    80001d54:	c1890913          	addi	s2,s2,-1000 # 80031968 <pid_lock>
    80001d58:	854a                	mv	a0,s2
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	080080e7          	jalr	128(ra) # 80000dda <acquire>
  pid = nextpid;
    80001d62:	00007797          	auipc	a5,0x7
    80001d66:	ac278793          	addi	a5,a5,-1342 # 80008824 <nextpid>
    80001d6a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d6c:	0014871b          	addiw	a4,s1,1
    80001d70:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d72:	854a                	mv	a0,s2
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	11a080e7          	jalr	282(ra) # 80000e8e <release>
}
    80001d7c:	8526                	mv	a0,s1
    80001d7e:	60e2                	ld	ra,24(sp)
    80001d80:	6442                	ld	s0,16(sp)
    80001d82:	64a2                	ld	s1,8(sp)
    80001d84:	6902                	ld	s2,0(sp)
    80001d86:	6105                	addi	sp,sp,32
    80001d88:	8082                	ret

0000000080001d8a <proc_pagetable>:
{
    80001d8a:	1101                	addi	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	e04a                	sd	s2,0(sp)
    80001d94:	1000                	addi	s0,sp,32
    80001d96:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	7b6080e7          	jalr	1974(ra) # 8000154e <uvmcreate>
    80001da0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001da2:	c121                	beqz	a0,80001de2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001da4:	4729                	li	a4,10
    80001da6:	00005697          	auipc	a3,0x5
    80001daa:	25a68693          	addi	a3,a3,602 # 80007000 <_trampoline>
    80001dae:	6605                	lui	a2,0x1
    80001db0:	040005b7          	lui	a1,0x4000
    80001db4:	15fd                	addi	a1,a1,-1
    80001db6:	05b2                	slli	a1,a1,0xc
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	550080e7          	jalr	1360(ra) # 80001308 <mappages>
    80001dc0:	02054863          	bltz	a0,80001df0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001dc4:	4719                	li	a4,6
    80001dc6:	05893683          	ld	a3,88(s2)
    80001dca:	6605                	lui	a2,0x1
    80001dcc:	020005b7          	lui	a1,0x2000
    80001dd0:	15fd                	addi	a1,a1,-1
    80001dd2:	05b6                	slli	a1,a1,0xd
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	532080e7          	jalr	1330(ra) # 80001308 <mappages>
    80001dde:	02054163          	bltz	a0,80001e00 <proc_pagetable+0x76>
}
    80001de2:	8526                	mv	a0,s1
    80001de4:	60e2                	ld	ra,24(sp)
    80001de6:	6442                	ld	s0,16(sp)
    80001de8:	64a2                	ld	s1,8(sp)
    80001dea:	6902                	ld	s2,0(sp)
    80001dec:	6105                	addi	sp,sp,32
    80001dee:	8082                	ret
    uvmfree(pagetable, 0);
    80001df0:	4581                	li	a1,0
    80001df2:	8526                	mv	a0,s1
    80001df4:	00000097          	auipc	ra,0x0
    80001df8:	956080e7          	jalr	-1706(ra) # 8000174a <uvmfree>
    return 0;
    80001dfc:	4481                	li	s1,0
    80001dfe:	b7d5                	j	80001de2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e00:	4681                	li	a3,0
    80001e02:	4605                	li	a2,1
    80001e04:	040005b7          	lui	a1,0x4000
    80001e08:	15fd                	addi	a1,a1,-1
    80001e0a:	05b2                	slli	a1,a1,0xc
    80001e0c:	8526                	mv	a0,s1
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	67c080e7          	jalr	1660(ra) # 8000148a <uvmunmap>
    uvmfree(pagetable, 0);
    80001e16:	4581                	li	a1,0
    80001e18:	8526                	mv	a0,s1
    80001e1a:	00000097          	auipc	ra,0x0
    80001e1e:	930080e7          	jalr	-1744(ra) # 8000174a <uvmfree>
    return 0;
    80001e22:	4481                	li	s1,0
    80001e24:	bf7d                	j	80001de2 <proc_pagetable+0x58>

0000000080001e26 <proc_freepagetable>:
{
    80001e26:	1101                	addi	sp,sp,-32
    80001e28:	ec06                	sd	ra,24(sp)
    80001e2a:	e822                	sd	s0,16(sp)
    80001e2c:	e426                	sd	s1,8(sp)
    80001e2e:	e04a                	sd	s2,0(sp)
    80001e30:	1000                	addi	s0,sp,32
    80001e32:	84aa                	mv	s1,a0
    80001e34:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e36:	4681                	li	a3,0
    80001e38:	4605                	li	a2,1
    80001e3a:	040005b7          	lui	a1,0x4000
    80001e3e:	15fd                	addi	a1,a1,-1
    80001e40:	05b2                	slli	a1,a1,0xc
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	648080e7          	jalr	1608(ra) # 8000148a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e4a:	4681                	li	a3,0
    80001e4c:	4605                	li	a2,1
    80001e4e:	020005b7          	lui	a1,0x2000
    80001e52:	15fd                	addi	a1,a1,-1
    80001e54:	05b6                	slli	a1,a1,0xd
    80001e56:	8526                	mv	a0,s1
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	632080e7          	jalr	1586(ra) # 8000148a <uvmunmap>
  uvmfree(pagetable, sz);
    80001e60:	85ca                	mv	a1,s2
    80001e62:	8526                	mv	a0,s1
    80001e64:	00000097          	auipc	ra,0x0
    80001e68:	8e6080e7          	jalr	-1818(ra) # 8000174a <uvmfree>
}
    80001e6c:	60e2                	ld	ra,24(sp)
    80001e6e:	6442                	ld	s0,16(sp)
    80001e70:	64a2                	ld	s1,8(sp)
    80001e72:	6902                	ld	s2,0(sp)
    80001e74:	6105                	addi	sp,sp,32
    80001e76:	8082                	ret

0000000080001e78 <freeproc>:
{
    80001e78:	1101                	addi	sp,sp,-32
    80001e7a:	ec06                	sd	ra,24(sp)
    80001e7c:	e822                	sd	s0,16(sp)
    80001e7e:	e426                	sd	s1,8(sp)
    80001e80:	1000                	addi	s0,sp,32
    80001e82:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e84:	6d28                	ld	a0,88(a0)
    80001e86:	c509                	beqz	a0,80001e90 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	c76080e7          	jalr	-906(ra) # 80000afe <kfree>
  p->trapframe = 0;
    80001e90:	0404bc23          	sd	zero,88(s1) # fffffffffffff058 <end+0xffffffff7ffb9058>
  if(p->pagetable)
    80001e94:	68a8                	ld	a0,80(s1)
    80001e96:	c511                	beqz	a0,80001ea2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e98:	64ac                	ld	a1,72(s1)
    80001e9a:	00000097          	auipc	ra,0x0
    80001e9e:	f8c080e7          	jalr	-116(ra) # 80001e26 <proc_freepagetable>
  p->pagetable = 0;
    80001ea2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ea6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001eaa:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001eae:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001eb2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001eb6:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001eba:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001ebe:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001ec2:	0004ac23          	sw	zero,24(s1)
}
    80001ec6:	60e2                	ld	ra,24(sp)
    80001ec8:	6442                	ld	s0,16(sp)
    80001eca:	64a2                	ld	s1,8(sp)
    80001ecc:	6105                	addi	sp,sp,32
    80001ece:	8082                	ret

0000000080001ed0 <allocproc>:
{
    80001ed0:	1101                	addi	sp,sp,-32
    80001ed2:	ec06                	sd	ra,24(sp)
    80001ed4:	e822                	sd	s0,16(sp)
    80001ed6:	e426                	sd	s1,8(sp)
    80001ed8:	e04a                	sd	s2,0(sp)
    80001eda:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001edc:	00030497          	auipc	s1,0x30
    80001ee0:	ea448493          	addi	s1,s1,-348 # 80031d80 <proc>
    80001ee4:	00036917          	auipc	s2,0x36
    80001ee8:	89c90913          	addi	s2,s2,-1892 # 80037780 <tickslock>
    acquire(&p->lock);
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	eec080e7          	jalr	-276(ra) # 80000dda <acquire>
    if(p->state == UNUSED) {
    80001ef6:	4c9c                	lw	a5,24(s1)
    80001ef8:	cf81                	beqz	a5,80001f10 <allocproc+0x40>
      release(&p->lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	f92080e7          	jalr	-110(ra) # 80000e8e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f04:	16848493          	addi	s1,s1,360
    80001f08:	ff2492e3          	bne	s1,s2,80001eec <allocproc+0x1c>
  return 0;
    80001f0c:	4481                	li	s1,0
    80001f0e:	a0b9                	j	80001f5c <allocproc+0x8c>
  p->pid = allocpid();
    80001f10:	00000097          	auipc	ra,0x0
    80001f14:	e34080e7          	jalr	-460(ra) # 80001d44 <allocpid>
    80001f18:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	d4a080e7          	jalr	-694(ra) # 80000c64 <kalloc>
    80001f22:	892a                	mv	s2,a0
    80001f24:	eca8                	sd	a0,88(s1)
    80001f26:	c131                	beqz	a0,80001f6a <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001f28:	8526                	mv	a0,s1
    80001f2a:	00000097          	auipc	ra,0x0
    80001f2e:	e60080e7          	jalr	-416(ra) # 80001d8a <proc_pagetable>
    80001f32:	892a                	mv	s2,a0
    80001f34:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001f36:	c129                	beqz	a0,80001f78 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001f38:	07000613          	li	a2,112
    80001f3c:	4581                	li	a1,0
    80001f3e:	06048513          	addi	a0,s1,96
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	f94080e7          	jalr	-108(ra) # 80000ed6 <memset>
  p->context.ra = (uint64)forkret;
    80001f4a:	00000797          	auipc	a5,0x0
    80001f4e:	db478793          	addi	a5,a5,-588 # 80001cfe <forkret>
    80001f52:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f54:	60bc                	ld	a5,64(s1)
    80001f56:	6705                	lui	a4,0x1
    80001f58:	97ba                	add	a5,a5,a4
    80001f5a:	f4bc                	sd	a5,104(s1)
}
    80001f5c:	8526                	mv	a0,s1
    80001f5e:	60e2                	ld	ra,24(sp)
    80001f60:	6442                	ld	s0,16(sp)
    80001f62:	64a2                	ld	s1,8(sp)
    80001f64:	6902                	ld	s2,0(sp)
    80001f66:	6105                	addi	sp,sp,32
    80001f68:	8082                	ret
    release(&p->lock);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	f22080e7          	jalr	-222(ra) # 80000e8e <release>
    return 0;
    80001f74:	84ca                	mv	s1,s2
    80001f76:	b7dd                	j	80001f5c <allocproc+0x8c>
    freeproc(p);
    80001f78:	8526                	mv	a0,s1
    80001f7a:	00000097          	auipc	ra,0x0
    80001f7e:	efe080e7          	jalr	-258(ra) # 80001e78 <freeproc>
    release(&p->lock);
    80001f82:	8526                	mv	a0,s1
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	f0a080e7          	jalr	-246(ra) # 80000e8e <release>
    return 0;
    80001f8c:	84ca                	mv	s1,s2
    80001f8e:	b7f9                	j	80001f5c <allocproc+0x8c>

0000000080001f90 <userinit>:
{
    80001f90:	1101                	addi	sp,sp,-32
    80001f92:	ec06                	sd	ra,24(sp)
    80001f94:	e822                	sd	s0,16(sp)
    80001f96:	e426                	sd	s1,8(sp)
    80001f98:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f9a:	00000097          	auipc	ra,0x0
    80001f9e:	f36080e7          	jalr	-202(ra) # 80001ed0 <allocproc>
    80001fa2:	84aa                	mv	s1,a0
  initproc = p;
    80001fa4:	00007797          	auipc	a5,0x7
    80001fa8:	06a7ba23          	sd	a0,116(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001fac:	03400613          	li	a2,52
    80001fb0:	00007597          	auipc	a1,0x7
    80001fb4:	88058593          	addi	a1,a1,-1920 # 80008830 <initcode>
    80001fb8:	6928                	ld	a0,80(a0)
    80001fba:	fffff097          	auipc	ra,0xfffff
    80001fbe:	5c2080e7          	jalr	1474(ra) # 8000157c <uvminit>
  p->sz = PGSIZE;
    80001fc2:	6785                	lui	a5,0x1
    80001fc4:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001fc6:	6cb8                	ld	a4,88(s1)
    80001fc8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001fcc:	6cb8                	ld	a4,88(s1)
    80001fce:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001fd0:	4641                	li	a2,16
    80001fd2:	00006597          	auipc	a1,0x6
    80001fd6:	21e58593          	addi	a1,a1,542 # 800081f0 <digits+0x1b0>
    80001fda:	15848513          	addi	a0,s1,344
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	04e080e7          	jalr	78(ra) # 8000102c <safestrcpy>
  p->cwd = namei("/");
    80001fe6:	00006517          	auipc	a0,0x6
    80001fea:	21a50513          	addi	a0,a0,538 # 80008200 <digits+0x1c0>
    80001fee:	00002097          	auipc	ra,0x2
    80001ff2:	0e0080e7          	jalr	224(ra) # 800040ce <namei>
    80001ff6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ffa:	4789                	li	a5,2
    80001ffc:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ffe:	8526                	mv	a0,s1
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	e8e080e7          	jalr	-370(ra) # 80000e8e <release>
}
    80002008:	60e2                	ld	ra,24(sp)
    8000200a:	6442                	ld	s0,16(sp)
    8000200c:	64a2                	ld	s1,8(sp)
    8000200e:	6105                	addi	sp,sp,32
    80002010:	8082                	ret

0000000080002012 <growproc>:
{
    80002012:	1101                	addi	sp,sp,-32
    80002014:	ec06                	sd	ra,24(sp)
    80002016:	e822                	sd	s0,16(sp)
    80002018:	e426                	sd	s1,8(sp)
    8000201a:	e04a                	sd	s2,0(sp)
    8000201c:	1000                	addi	s0,sp,32
    8000201e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002020:	00000097          	auipc	ra,0x0
    80002024:	ca6080e7          	jalr	-858(ra) # 80001cc6 <myproc>
    80002028:	892a                	mv	s2,a0
  sz = p->sz;
    8000202a:	652c                	ld	a1,72(a0)
    8000202c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002030:	00904f63          	bgtz	s1,8000204e <growproc+0x3c>
  } else if(n < 0){
    80002034:	0204cc63          	bltz	s1,8000206c <growproc+0x5a>
  p->sz = sz;
    80002038:	1602                	slli	a2,a2,0x20
    8000203a:	9201                	srli	a2,a2,0x20
    8000203c:	04c93423          	sd	a2,72(s2)
  return 0;
    80002040:	4501                	li	a0,0
}
    80002042:	60e2                	ld	ra,24(sp)
    80002044:	6442                	ld	s0,16(sp)
    80002046:	64a2                	ld	s1,8(sp)
    80002048:	6902                	ld	s2,0(sp)
    8000204a:	6105                	addi	sp,sp,32
    8000204c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000204e:	9e25                	addw	a2,a2,s1
    80002050:	1602                	slli	a2,a2,0x20
    80002052:	9201                	srli	a2,a2,0x20
    80002054:	1582                	slli	a1,a1,0x20
    80002056:	9181                	srli	a1,a1,0x20
    80002058:	6928                	ld	a0,80(a0)
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	5dc080e7          	jalr	1500(ra) # 80001636 <uvmalloc>
    80002062:	0005061b          	sext.w	a2,a0
    80002066:	fa69                	bnez	a2,80002038 <growproc+0x26>
      return -1;
    80002068:	557d                	li	a0,-1
    8000206a:	bfe1                	j	80002042 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000206c:	9e25                	addw	a2,a2,s1
    8000206e:	1602                	slli	a2,a2,0x20
    80002070:	9201                	srli	a2,a2,0x20
    80002072:	1582                	slli	a1,a1,0x20
    80002074:	9181                	srli	a1,a1,0x20
    80002076:	6928                	ld	a0,80(a0)
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	576080e7          	jalr	1398(ra) # 800015ee <uvmdealloc>
    80002080:	0005061b          	sext.w	a2,a0
    80002084:	bf55                	j	80002038 <growproc+0x26>

0000000080002086 <fork>:
{
    80002086:	7179                	addi	sp,sp,-48
    80002088:	f406                	sd	ra,40(sp)
    8000208a:	f022                	sd	s0,32(sp)
    8000208c:	ec26                	sd	s1,24(sp)
    8000208e:	e84a                	sd	s2,16(sp)
    80002090:	e44e                	sd	s3,8(sp)
    80002092:	e052                	sd	s4,0(sp)
    80002094:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	c30080e7          	jalr	-976(ra) # 80001cc6 <myproc>
    8000209e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	e30080e7          	jalr	-464(ra) # 80001ed0 <allocproc>
    800020a8:	c175                	beqz	a0,8000218c <fork+0x106>
    800020aa:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020ac:	04893603          	ld	a2,72(s2)
    800020b0:	692c                	ld	a1,80(a0)
    800020b2:	05093503          	ld	a0,80(s2)
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	6cc080e7          	jalr	1740(ra) # 80001782 <uvmcopy>
    800020be:	04054863          	bltz	a0,8000210e <fork+0x88>
  np->sz = p->sz;
    800020c2:	04893783          	ld	a5,72(s2)
    800020c6:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    800020ca:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    800020ce:	05893683          	ld	a3,88(s2)
    800020d2:	87b6                	mv	a5,a3
    800020d4:	0589b703          	ld	a4,88(s3)
    800020d8:	12068693          	addi	a3,a3,288
    800020dc:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800020e0:	6788                	ld	a0,8(a5)
    800020e2:	6b8c                	ld	a1,16(a5)
    800020e4:	6f90                	ld	a2,24(a5)
    800020e6:	01073023          	sd	a6,0(a4)
    800020ea:	e708                	sd	a0,8(a4)
    800020ec:	eb0c                	sd	a1,16(a4)
    800020ee:	ef10                	sd	a2,24(a4)
    800020f0:	02078793          	addi	a5,a5,32
    800020f4:	02070713          	addi	a4,a4,32
    800020f8:	fed792e3          	bne	a5,a3,800020dc <fork+0x56>
  np->trapframe->a0 = 0;
    800020fc:	0589b783          	ld	a5,88(s3)
    80002100:	0607b823          	sd	zero,112(a5)
    80002104:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80002108:	15000a13          	li	s4,336
    8000210c:	a03d                	j	8000213a <fork+0xb4>
    freeproc(np);
    8000210e:	854e                	mv	a0,s3
    80002110:	00000097          	auipc	ra,0x0
    80002114:	d68080e7          	jalr	-664(ra) # 80001e78 <freeproc>
    release(&np->lock);
    80002118:	854e                	mv	a0,s3
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	d74080e7          	jalr	-652(ra) # 80000e8e <release>
    return -1;
    80002122:	54fd                	li	s1,-1
    80002124:	a899                	j	8000217a <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002126:	00002097          	auipc	ra,0x2
    8000212a:	634080e7          	jalr	1588(ra) # 8000475a <filedup>
    8000212e:	009987b3          	add	a5,s3,s1
    80002132:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002134:	04a1                	addi	s1,s1,8
    80002136:	01448763          	beq	s1,s4,80002144 <fork+0xbe>
    if(p->ofile[i])
    8000213a:	009907b3          	add	a5,s2,s1
    8000213e:	6388                	ld	a0,0(a5)
    80002140:	f17d                	bnez	a0,80002126 <fork+0xa0>
    80002142:	bfcd                	j	80002134 <fork+0xae>
  np->cwd = idup(p->cwd);
    80002144:	15093503          	ld	a0,336(s2)
    80002148:	00001097          	auipc	ra,0x1
    8000214c:	794080e7          	jalr	1940(ra) # 800038dc <idup>
    80002150:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002154:	4641                	li	a2,16
    80002156:	15890593          	addi	a1,s2,344
    8000215a:	15898513          	addi	a0,s3,344
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	ece080e7          	jalr	-306(ra) # 8000102c <safestrcpy>
  pid = np->pid;
    80002166:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    8000216a:	4789                	li	a5,2
    8000216c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002170:	854e                	mv	a0,s3
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	d1c080e7          	jalr	-740(ra) # 80000e8e <release>
}
    8000217a:	8526                	mv	a0,s1
    8000217c:	70a2                	ld	ra,40(sp)
    8000217e:	7402                	ld	s0,32(sp)
    80002180:	64e2                	ld	s1,24(sp)
    80002182:	6942                	ld	s2,16(sp)
    80002184:	69a2                	ld	s3,8(sp)
    80002186:	6a02                	ld	s4,0(sp)
    80002188:	6145                	addi	sp,sp,48
    8000218a:	8082                	ret
    return -1;
    8000218c:	54fd                	li	s1,-1
    8000218e:	b7f5                	j	8000217a <fork+0xf4>

0000000080002190 <reparent>:
{
    80002190:	7179                	addi	sp,sp,-48
    80002192:	f406                	sd	ra,40(sp)
    80002194:	f022                	sd	s0,32(sp)
    80002196:	ec26                	sd	s1,24(sp)
    80002198:	e84a                	sd	s2,16(sp)
    8000219a:	e44e                	sd	s3,8(sp)
    8000219c:	e052                	sd	s4,0(sp)
    8000219e:	1800                	addi	s0,sp,48
    800021a0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021a2:	00030497          	auipc	s1,0x30
    800021a6:	bde48493          	addi	s1,s1,-1058 # 80031d80 <proc>
      pp->parent = initproc;
    800021aa:	00007a17          	auipc	s4,0x7
    800021ae:	e6ea0a13          	addi	s4,s4,-402 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b2:	00035997          	auipc	s3,0x35
    800021b6:	5ce98993          	addi	s3,s3,1486 # 80037780 <tickslock>
    800021ba:	a029                	j	800021c4 <reparent+0x34>
    800021bc:	16848493          	addi	s1,s1,360
    800021c0:	03348363          	beq	s1,s3,800021e6 <reparent+0x56>
    if(pp->parent == p){
    800021c4:	709c                	ld	a5,32(s1)
    800021c6:	ff279be3          	bne	a5,s2,800021bc <reparent+0x2c>
      acquire(&pp->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	c0e080e7          	jalr	-1010(ra) # 80000dda <acquire>
      pp->parent = initproc;
    800021d4:	000a3783          	ld	a5,0(s4)
    800021d8:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    800021da:	8526                	mv	a0,s1
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	cb2080e7          	jalr	-846(ra) # 80000e8e <release>
    800021e4:	bfe1                	j	800021bc <reparent+0x2c>
}
    800021e6:	70a2                	ld	ra,40(sp)
    800021e8:	7402                	ld	s0,32(sp)
    800021ea:	64e2                	ld	s1,24(sp)
    800021ec:	6942                	ld	s2,16(sp)
    800021ee:	69a2                	ld	s3,8(sp)
    800021f0:	6a02                	ld	s4,0(sp)
    800021f2:	6145                	addi	sp,sp,48
    800021f4:	8082                	ret

00000000800021f6 <scheduler>:
{
    800021f6:	711d                	addi	sp,sp,-96
    800021f8:	ec86                	sd	ra,88(sp)
    800021fa:	e8a2                	sd	s0,80(sp)
    800021fc:	e4a6                	sd	s1,72(sp)
    800021fe:	e0ca                	sd	s2,64(sp)
    80002200:	fc4e                	sd	s3,56(sp)
    80002202:	f852                	sd	s4,48(sp)
    80002204:	f456                	sd	s5,40(sp)
    80002206:	f05a                	sd	s6,32(sp)
    80002208:	ec5e                	sd	s7,24(sp)
    8000220a:	e862                	sd	s8,16(sp)
    8000220c:	e466                	sd	s9,8(sp)
    8000220e:	1080                	addi	s0,sp,96
    80002210:	8792                	mv	a5,tp
  int id = r_tp();
    80002212:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002214:	00779c13          	slli	s8,a5,0x7
    80002218:	0002f717          	auipc	a4,0x2f
    8000221c:	75070713          	addi	a4,a4,1872 # 80031968 <pid_lock>
    80002220:	9762                	add	a4,a4,s8
    80002222:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002226:	0002f717          	auipc	a4,0x2f
    8000222a:	76270713          	addi	a4,a4,1890 # 80031988 <cpus+0x8>
    8000222e:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80002230:	4a89                	li	s5,2
        c->proc = p;
    80002232:	079e                	slli	a5,a5,0x7
    80002234:	0002fb17          	auipc	s6,0x2f
    80002238:	734b0b13          	addi	s6,s6,1844 # 80031968 <pid_lock>
    8000223c:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000223e:	00035a17          	auipc	s4,0x35
    80002242:	542a0a13          	addi	s4,s4,1346 # 80037780 <tickslock>
    int nproc = 0;
    80002246:	4c81                	li	s9,0
    80002248:	a8a1                	j	800022a0 <scheduler+0xaa>
        p->state = RUNNING;
    8000224a:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    8000224e:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80002252:	06048593          	addi	a1,s1,96
    80002256:	8562                	mv	a0,s8
    80002258:	00000097          	auipc	ra,0x0
    8000225c:	63a080e7          	jalr	1594(ra) # 80002892 <swtch>
        c->proc = 0;
    80002260:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80002264:	8526                	mv	a0,s1
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	c28080e7          	jalr	-984(ra) # 80000e8e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000226e:	16848493          	addi	s1,s1,360
    80002272:	01448d63          	beq	s1,s4,8000228c <scheduler+0x96>
      acquire(&p->lock);
    80002276:	8526                	mv	a0,s1
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	b62080e7          	jalr	-1182(ra) # 80000dda <acquire>
      if(p->state != UNUSED) {
    80002280:	4c9c                	lw	a5,24(s1)
    80002282:	d3ed                	beqz	a5,80002264 <scheduler+0x6e>
        nproc++;
    80002284:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    80002286:	fd579fe3          	bne	a5,s5,80002264 <scheduler+0x6e>
    8000228a:	b7c1                	j	8000224a <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    8000228c:	013aca63          	blt	s5,s3,800022a0 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002290:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002294:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002298:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000229c:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022a0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022a4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022a8:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    800022ac:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    800022ae:	00030497          	auipc	s1,0x30
    800022b2:	ad248493          	addi	s1,s1,-1326 # 80031d80 <proc>
        p->state = RUNNING;
    800022b6:	4b8d                	li	s7,3
    800022b8:	bf7d                	j	80002276 <scheduler+0x80>

00000000800022ba <sched>:
{
    800022ba:	7179                	addi	sp,sp,-48
    800022bc:	f406                	sd	ra,40(sp)
    800022be:	f022                	sd	s0,32(sp)
    800022c0:	ec26                	sd	s1,24(sp)
    800022c2:	e84a                	sd	s2,16(sp)
    800022c4:	e44e                	sd	s3,8(sp)
    800022c6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800022c8:	00000097          	auipc	ra,0x0
    800022cc:	9fe080e7          	jalr	-1538(ra) # 80001cc6 <myproc>
    800022d0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	a8e080e7          	jalr	-1394(ra) # 80000d60 <holding>
    800022da:	c93d                	beqz	a0,80002350 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022dc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800022de:	2781                	sext.w	a5,a5
    800022e0:	079e                	slli	a5,a5,0x7
    800022e2:	0002f717          	auipc	a4,0x2f
    800022e6:	68670713          	addi	a4,a4,1670 # 80031968 <pid_lock>
    800022ea:	97ba                	add	a5,a5,a4
    800022ec:	0907a703          	lw	a4,144(a5)
    800022f0:	4785                	li	a5,1
    800022f2:	06f71763          	bne	a4,a5,80002360 <sched+0xa6>
  if(p->state == RUNNING)
    800022f6:	4c98                	lw	a4,24(s1)
    800022f8:	478d                	li	a5,3
    800022fa:	06f70b63          	beq	a4,a5,80002370 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022fe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002302:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002304:	efb5                	bnez	a5,80002380 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002306:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002308:	0002f917          	auipc	s2,0x2f
    8000230c:	66090913          	addi	s2,s2,1632 # 80031968 <pid_lock>
    80002310:	2781                	sext.w	a5,a5
    80002312:	079e                	slli	a5,a5,0x7
    80002314:	97ca                	add	a5,a5,s2
    80002316:	0947a983          	lw	s3,148(a5)
    8000231a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000231c:	2781                	sext.w	a5,a5
    8000231e:	079e                	slli	a5,a5,0x7
    80002320:	0002f597          	auipc	a1,0x2f
    80002324:	66858593          	addi	a1,a1,1640 # 80031988 <cpus+0x8>
    80002328:	95be                	add	a1,a1,a5
    8000232a:	06048513          	addi	a0,s1,96
    8000232e:	00000097          	auipc	ra,0x0
    80002332:	564080e7          	jalr	1380(ra) # 80002892 <swtch>
    80002336:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002338:	2781                	sext.w	a5,a5
    8000233a:	079e                	slli	a5,a5,0x7
    8000233c:	97ca                	add	a5,a5,s2
    8000233e:	0937aa23          	sw	s3,148(a5)
}
    80002342:	70a2                	ld	ra,40(sp)
    80002344:	7402                	ld	s0,32(sp)
    80002346:	64e2                	ld	s1,24(sp)
    80002348:	6942                	ld	s2,16(sp)
    8000234a:	69a2                	ld	s3,8(sp)
    8000234c:	6145                	addi	sp,sp,48
    8000234e:	8082                	ret
    panic("sched p->lock");
    80002350:	00006517          	auipc	a0,0x6
    80002354:	eb850513          	addi	a0,a0,-328 # 80008208 <digits+0x1c8>
    80002358:	ffffe097          	auipc	ra,0xffffe
    8000235c:	1f0080e7          	jalr	496(ra) # 80000548 <panic>
    panic("sched locks");
    80002360:	00006517          	auipc	a0,0x6
    80002364:	eb850513          	addi	a0,a0,-328 # 80008218 <digits+0x1d8>
    80002368:	ffffe097          	auipc	ra,0xffffe
    8000236c:	1e0080e7          	jalr	480(ra) # 80000548 <panic>
    panic("sched running");
    80002370:	00006517          	auipc	a0,0x6
    80002374:	eb850513          	addi	a0,a0,-328 # 80008228 <digits+0x1e8>
    80002378:	ffffe097          	auipc	ra,0xffffe
    8000237c:	1d0080e7          	jalr	464(ra) # 80000548 <panic>
    panic("sched interruptible");
    80002380:	00006517          	auipc	a0,0x6
    80002384:	eb850513          	addi	a0,a0,-328 # 80008238 <digits+0x1f8>
    80002388:	ffffe097          	auipc	ra,0xffffe
    8000238c:	1c0080e7          	jalr	448(ra) # 80000548 <panic>

0000000080002390 <exit>:
{
    80002390:	7179                	addi	sp,sp,-48
    80002392:	f406                	sd	ra,40(sp)
    80002394:	f022                	sd	s0,32(sp)
    80002396:	ec26                	sd	s1,24(sp)
    80002398:	e84a                	sd	s2,16(sp)
    8000239a:	e44e                	sd	s3,8(sp)
    8000239c:	e052                	sd	s4,0(sp)
    8000239e:	1800                	addi	s0,sp,48
    800023a0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	924080e7          	jalr	-1756(ra) # 80001cc6 <myproc>
    800023aa:	89aa                	mv	s3,a0
  if(p == initproc)
    800023ac:	00007797          	auipc	a5,0x7
    800023b0:	c6c7b783          	ld	a5,-916(a5) # 80009018 <initproc>
    800023b4:	0d050493          	addi	s1,a0,208
    800023b8:	15050913          	addi	s2,a0,336
    800023bc:	02a79363          	bne	a5,a0,800023e2 <exit+0x52>
    panic("init exiting");
    800023c0:	00006517          	auipc	a0,0x6
    800023c4:	e9050513          	addi	a0,a0,-368 # 80008250 <digits+0x210>
    800023c8:	ffffe097          	auipc	ra,0xffffe
    800023cc:	180080e7          	jalr	384(ra) # 80000548 <panic>
      fileclose(f);
    800023d0:	00002097          	auipc	ra,0x2
    800023d4:	3dc080e7          	jalr	988(ra) # 800047ac <fileclose>
      p->ofile[fd] = 0;
    800023d8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023dc:	04a1                	addi	s1,s1,8
    800023de:	01248563          	beq	s1,s2,800023e8 <exit+0x58>
    if(p->ofile[fd]){
    800023e2:	6088                	ld	a0,0(s1)
    800023e4:	f575                	bnez	a0,800023d0 <exit+0x40>
    800023e6:	bfdd                	j	800023dc <exit+0x4c>
  begin_op();
    800023e8:	00002097          	auipc	ra,0x2
    800023ec:	ef2080e7          	jalr	-270(ra) # 800042da <begin_op>
  iput(p->cwd);
    800023f0:	1509b503          	ld	a0,336(s3)
    800023f4:	00001097          	auipc	ra,0x1
    800023f8:	6e0080e7          	jalr	1760(ra) # 80003ad4 <iput>
  end_op();
    800023fc:	00002097          	auipc	ra,0x2
    80002400:	f5e080e7          	jalr	-162(ra) # 8000435a <end_op>
  p->cwd = 0;
    80002404:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002408:	00007497          	auipc	s1,0x7
    8000240c:	c1048493          	addi	s1,s1,-1008 # 80009018 <initproc>
    80002410:	6088                	ld	a0,0(s1)
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	9c8080e7          	jalr	-1592(ra) # 80000dda <acquire>
  wakeup1(initproc);
    8000241a:	6088                	ld	a0,0(s1)
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	76a080e7          	jalr	1898(ra) # 80001b86 <wakeup1>
  release(&initproc->lock);
    80002424:	6088                	ld	a0,0(s1)
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	a68080e7          	jalr	-1432(ra) # 80000e8e <release>
  acquire(&p->lock);
    8000242e:	854e                	mv	a0,s3
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	9aa080e7          	jalr	-1622(ra) # 80000dda <acquire>
  struct proc *original_parent = p->parent;
    80002438:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000243c:	854e                	mv	a0,s3
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	a50080e7          	jalr	-1456(ra) # 80000e8e <release>
  acquire(&original_parent->lock);
    80002446:	8526                	mv	a0,s1
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	992080e7          	jalr	-1646(ra) # 80000dda <acquire>
  acquire(&p->lock);
    80002450:	854e                	mv	a0,s3
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	988080e7          	jalr	-1656(ra) # 80000dda <acquire>
  reparent(p);
    8000245a:	854e                	mv	a0,s3
    8000245c:	00000097          	auipc	ra,0x0
    80002460:	d34080e7          	jalr	-716(ra) # 80002190 <reparent>
  wakeup1(original_parent);
    80002464:	8526                	mv	a0,s1
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	720080e7          	jalr	1824(ra) # 80001b86 <wakeup1>
  p->xstate = status;
    8000246e:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002472:	4791                	li	a5,4
    80002474:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002478:	8526                	mv	a0,s1
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	a14080e7          	jalr	-1516(ra) # 80000e8e <release>
  sched();
    80002482:	00000097          	auipc	ra,0x0
    80002486:	e38080e7          	jalr	-456(ra) # 800022ba <sched>
  panic("zombie exit");
    8000248a:	00006517          	auipc	a0,0x6
    8000248e:	dd650513          	addi	a0,a0,-554 # 80008260 <digits+0x220>
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	0b6080e7          	jalr	182(ra) # 80000548 <panic>

000000008000249a <yield>:
{
    8000249a:	1101                	addi	sp,sp,-32
    8000249c:	ec06                	sd	ra,24(sp)
    8000249e:	e822                	sd	s0,16(sp)
    800024a0:	e426                	sd	s1,8(sp)
    800024a2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024a4:	00000097          	auipc	ra,0x0
    800024a8:	822080e7          	jalr	-2014(ra) # 80001cc6 <myproc>
    800024ac:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024ae:	fffff097          	auipc	ra,0xfffff
    800024b2:	92c080e7          	jalr	-1748(ra) # 80000dda <acquire>
  p->state = RUNNABLE;
    800024b6:	4789                	li	a5,2
    800024b8:	cc9c                	sw	a5,24(s1)
  sched();
    800024ba:	00000097          	auipc	ra,0x0
    800024be:	e00080e7          	jalr	-512(ra) # 800022ba <sched>
  release(&p->lock);
    800024c2:	8526                	mv	a0,s1
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	9ca080e7          	jalr	-1590(ra) # 80000e8e <release>
}
    800024cc:	60e2                	ld	ra,24(sp)
    800024ce:	6442                	ld	s0,16(sp)
    800024d0:	64a2                	ld	s1,8(sp)
    800024d2:	6105                	addi	sp,sp,32
    800024d4:	8082                	ret

00000000800024d6 <sleep>:
{
    800024d6:	7179                	addi	sp,sp,-48
    800024d8:	f406                	sd	ra,40(sp)
    800024da:	f022                	sd	s0,32(sp)
    800024dc:	ec26                	sd	s1,24(sp)
    800024de:	e84a                	sd	s2,16(sp)
    800024e0:	e44e                	sd	s3,8(sp)
    800024e2:	1800                	addi	s0,sp,48
    800024e4:	89aa                	mv	s3,a0
    800024e6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024e8:	fffff097          	auipc	ra,0xfffff
    800024ec:	7de080e7          	jalr	2014(ra) # 80001cc6 <myproc>
    800024f0:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800024f2:	05250663          	beq	a0,s2,8000253e <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	8e4080e7          	jalr	-1820(ra) # 80000dda <acquire>
    release(lk);
    800024fe:	854a                	mv	a0,s2
    80002500:	fffff097          	auipc	ra,0xfffff
    80002504:	98e080e7          	jalr	-1650(ra) # 80000e8e <release>
  p->chan = chan;
    80002508:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000250c:	4785                	li	a5,1
    8000250e:	cc9c                	sw	a5,24(s1)
  sched();
    80002510:	00000097          	auipc	ra,0x0
    80002514:	daa080e7          	jalr	-598(ra) # 800022ba <sched>
  p->chan = 0;
    80002518:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000251c:	8526                	mv	a0,s1
    8000251e:	fffff097          	auipc	ra,0xfffff
    80002522:	970080e7          	jalr	-1680(ra) # 80000e8e <release>
    acquire(lk);
    80002526:	854a                	mv	a0,s2
    80002528:	fffff097          	auipc	ra,0xfffff
    8000252c:	8b2080e7          	jalr	-1870(ra) # 80000dda <acquire>
}
    80002530:	70a2                	ld	ra,40(sp)
    80002532:	7402                	ld	s0,32(sp)
    80002534:	64e2                	ld	s1,24(sp)
    80002536:	6942                	ld	s2,16(sp)
    80002538:	69a2                	ld	s3,8(sp)
    8000253a:	6145                	addi	sp,sp,48
    8000253c:	8082                	ret
  p->chan = chan;
    8000253e:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002542:	4785                	li	a5,1
    80002544:	cd1c                	sw	a5,24(a0)
  sched();
    80002546:	00000097          	auipc	ra,0x0
    8000254a:	d74080e7          	jalr	-652(ra) # 800022ba <sched>
  p->chan = 0;
    8000254e:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002552:	bff9                	j	80002530 <sleep+0x5a>

0000000080002554 <wait>:
{
    80002554:	715d                	addi	sp,sp,-80
    80002556:	e486                	sd	ra,72(sp)
    80002558:	e0a2                	sd	s0,64(sp)
    8000255a:	fc26                	sd	s1,56(sp)
    8000255c:	f84a                	sd	s2,48(sp)
    8000255e:	f44e                	sd	s3,40(sp)
    80002560:	f052                	sd	s4,32(sp)
    80002562:	ec56                	sd	s5,24(sp)
    80002564:	e85a                	sd	s6,16(sp)
    80002566:	e45e                	sd	s7,8(sp)
    80002568:	e062                	sd	s8,0(sp)
    8000256a:	0880                	addi	s0,sp,80
    8000256c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000256e:	fffff097          	auipc	ra,0xfffff
    80002572:	758080e7          	jalr	1880(ra) # 80001cc6 <myproc>
    80002576:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002578:	8c2a                	mv	s8,a0
    8000257a:	fffff097          	auipc	ra,0xfffff
    8000257e:	860080e7          	jalr	-1952(ra) # 80000dda <acquire>
    havekids = 0;
    80002582:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002584:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002586:	00035997          	auipc	s3,0x35
    8000258a:	1fa98993          	addi	s3,s3,506 # 80037780 <tickslock>
        havekids = 1;
    8000258e:	4a85                	li	s5,1
    havekids = 0;
    80002590:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002592:	0002f497          	auipc	s1,0x2f
    80002596:	7ee48493          	addi	s1,s1,2030 # 80031d80 <proc>
    8000259a:	a08d                	j	800025fc <wait+0xa8>
          pid = np->pid;
    8000259c:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800025a0:	000b0e63          	beqz	s6,800025bc <wait+0x68>
    800025a4:	4691                	li	a3,4
    800025a6:	03448613          	addi	a2,s1,52
    800025aa:	85da                	mv	a1,s6
    800025ac:	05093503          	ld	a0,80(s2)
    800025b0:	fffff097          	auipc	ra,0xfffff
    800025b4:	508080e7          	jalr	1288(ra) # 80001ab8 <copyout>
    800025b8:	02054263          	bltz	a0,800025dc <wait+0x88>
          freeproc(np);
    800025bc:	8526                	mv	a0,s1
    800025be:	00000097          	auipc	ra,0x0
    800025c2:	8ba080e7          	jalr	-1862(ra) # 80001e78 <freeproc>
          release(&np->lock);
    800025c6:	8526                	mv	a0,s1
    800025c8:	fffff097          	auipc	ra,0xfffff
    800025cc:	8c6080e7          	jalr	-1850(ra) # 80000e8e <release>
          release(&p->lock);
    800025d0:	854a                	mv	a0,s2
    800025d2:	fffff097          	auipc	ra,0xfffff
    800025d6:	8bc080e7          	jalr	-1860(ra) # 80000e8e <release>
          return pid;
    800025da:	a8a9                	j	80002634 <wait+0xe0>
            release(&np->lock);
    800025dc:	8526                	mv	a0,s1
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	8b0080e7          	jalr	-1872(ra) # 80000e8e <release>
            release(&p->lock);
    800025e6:	854a                	mv	a0,s2
    800025e8:	fffff097          	auipc	ra,0xfffff
    800025ec:	8a6080e7          	jalr	-1882(ra) # 80000e8e <release>
            return -1;
    800025f0:	59fd                	li	s3,-1
    800025f2:	a089                	j	80002634 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800025f4:	16848493          	addi	s1,s1,360
    800025f8:	03348463          	beq	s1,s3,80002620 <wait+0xcc>
      if(np->parent == p){
    800025fc:	709c                	ld	a5,32(s1)
    800025fe:	ff279be3          	bne	a5,s2,800025f4 <wait+0xa0>
        acquire(&np->lock);
    80002602:	8526                	mv	a0,s1
    80002604:	ffffe097          	auipc	ra,0xffffe
    80002608:	7d6080e7          	jalr	2006(ra) # 80000dda <acquire>
        if(np->state == ZOMBIE){
    8000260c:	4c9c                	lw	a5,24(s1)
    8000260e:	f94787e3          	beq	a5,s4,8000259c <wait+0x48>
        release(&np->lock);
    80002612:	8526                	mv	a0,s1
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	87a080e7          	jalr	-1926(ra) # 80000e8e <release>
        havekids = 1;
    8000261c:	8756                	mv	a4,s5
    8000261e:	bfd9                	j	800025f4 <wait+0xa0>
    if(!havekids || p->killed){
    80002620:	c701                	beqz	a4,80002628 <wait+0xd4>
    80002622:	03092783          	lw	a5,48(s2)
    80002626:	c785                	beqz	a5,8000264e <wait+0xfa>
      release(&p->lock);
    80002628:	854a                	mv	a0,s2
    8000262a:	fffff097          	auipc	ra,0xfffff
    8000262e:	864080e7          	jalr	-1948(ra) # 80000e8e <release>
      return -1;
    80002632:	59fd                	li	s3,-1
}
    80002634:	854e                	mv	a0,s3
    80002636:	60a6                	ld	ra,72(sp)
    80002638:	6406                	ld	s0,64(sp)
    8000263a:	74e2                	ld	s1,56(sp)
    8000263c:	7942                	ld	s2,48(sp)
    8000263e:	79a2                	ld	s3,40(sp)
    80002640:	7a02                	ld	s4,32(sp)
    80002642:	6ae2                	ld	s5,24(sp)
    80002644:	6b42                	ld	s6,16(sp)
    80002646:	6ba2                	ld	s7,8(sp)
    80002648:	6c02                	ld	s8,0(sp)
    8000264a:	6161                	addi	sp,sp,80
    8000264c:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000264e:	85e2                	mv	a1,s8
    80002650:	854a                	mv	a0,s2
    80002652:	00000097          	auipc	ra,0x0
    80002656:	e84080e7          	jalr	-380(ra) # 800024d6 <sleep>
    havekids = 0;
    8000265a:	bf1d                	j	80002590 <wait+0x3c>

000000008000265c <wakeup>:
{
    8000265c:	7139                	addi	sp,sp,-64
    8000265e:	fc06                	sd	ra,56(sp)
    80002660:	f822                	sd	s0,48(sp)
    80002662:	f426                	sd	s1,40(sp)
    80002664:	f04a                	sd	s2,32(sp)
    80002666:	ec4e                	sd	s3,24(sp)
    80002668:	e852                	sd	s4,16(sp)
    8000266a:	e456                	sd	s5,8(sp)
    8000266c:	0080                	addi	s0,sp,64
    8000266e:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002670:	0002f497          	auipc	s1,0x2f
    80002674:	71048493          	addi	s1,s1,1808 # 80031d80 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002678:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000267a:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000267c:	00035917          	auipc	s2,0x35
    80002680:	10490913          	addi	s2,s2,260 # 80037780 <tickslock>
    80002684:	a821                	j	8000269c <wakeup+0x40>
      p->state = RUNNABLE;
    80002686:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    8000268a:	8526                	mv	a0,s1
    8000268c:	fffff097          	auipc	ra,0xfffff
    80002690:	802080e7          	jalr	-2046(ra) # 80000e8e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002694:	16848493          	addi	s1,s1,360
    80002698:	01248e63          	beq	s1,s2,800026b4 <wakeup+0x58>
    acquire(&p->lock);
    8000269c:	8526                	mv	a0,s1
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	73c080e7          	jalr	1852(ra) # 80000dda <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800026a6:	4c9c                	lw	a5,24(s1)
    800026a8:	ff3791e3          	bne	a5,s3,8000268a <wakeup+0x2e>
    800026ac:	749c                	ld	a5,40(s1)
    800026ae:	fd479ee3          	bne	a5,s4,8000268a <wakeup+0x2e>
    800026b2:	bfd1                	j	80002686 <wakeup+0x2a>
}
    800026b4:	70e2                	ld	ra,56(sp)
    800026b6:	7442                	ld	s0,48(sp)
    800026b8:	74a2                	ld	s1,40(sp)
    800026ba:	7902                	ld	s2,32(sp)
    800026bc:	69e2                	ld	s3,24(sp)
    800026be:	6a42                	ld	s4,16(sp)
    800026c0:	6aa2                	ld	s5,8(sp)
    800026c2:	6121                	addi	sp,sp,64
    800026c4:	8082                	ret

00000000800026c6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800026c6:	7179                	addi	sp,sp,-48
    800026c8:	f406                	sd	ra,40(sp)
    800026ca:	f022                	sd	s0,32(sp)
    800026cc:	ec26                	sd	s1,24(sp)
    800026ce:	e84a                	sd	s2,16(sp)
    800026d0:	e44e                	sd	s3,8(sp)
    800026d2:	1800                	addi	s0,sp,48
    800026d4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800026d6:	0002f497          	auipc	s1,0x2f
    800026da:	6aa48493          	addi	s1,s1,1706 # 80031d80 <proc>
    800026de:	00035997          	auipc	s3,0x35
    800026e2:	0a298993          	addi	s3,s3,162 # 80037780 <tickslock>
    acquire(&p->lock);
    800026e6:	8526                	mv	a0,s1
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	6f2080e7          	jalr	1778(ra) # 80000dda <acquire>
    if(p->pid == pid){
    800026f0:	5c9c                	lw	a5,56(s1)
    800026f2:	01278d63          	beq	a5,s2,8000270c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026f6:	8526                	mv	a0,s1
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	796080e7          	jalr	1942(ra) # 80000e8e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002700:	16848493          	addi	s1,s1,360
    80002704:	ff3491e3          	bne	s1,s3,800026e6 <kill+0x20>
  }
  return -1;
    80002708:	557d                	li	a0,-1
    8000270a:	a829                	j	80002724 <kill+0x5e>
      p->killed = 1;
    8000270c:	4785                	li	a5,1
    8000270e:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002710:	4c98                	lw	a4,24(s1)
    80002712:	4785                	li	a5,1
    80002714:	00f70f63          	beq	a4,a5,80002732 <kill+0x6c>
      release(&p->lock);
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	774080e7          	jalr	1908(ra) # 80000e8e <release>
      return 0;
    80002722:	4501                	li	a0,0
}
    80002724:	70a2                	ld	ra,40(sp)
    80002726:	7402                	ld	s0,32(sp)
    80002728:	64e2                	ld	s1,24(sp)
    8000272a:	6942                	ld	s2,16(sp)
    8000272c:	69a2                	ld	s3,8(sp)
    8000272e:	6145                	addi	sp,sp,48
    80002730:	8082                	ret
        p->state = RUNNABLE;
    80002732:	4789                	li	a5,2
    80002734:	cc9c                	sw	a5,24(s1)
    80002736:	b7cd                	j	80002718 <kill+0x52>

0000000080002738 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002738:	7179                	addi	sp,sp,-48
    8000273a:	f406                	sd	ra,40(sp)
    8000273c:	f022                	sd	s0,32(sp)
    8000273e:	ec26                	sd	s1,24(sp)
    80002740:	e84a                	sd	s2,16(sp)
    80002742:	e44e                	sd	s3,8(sp)
    80002744:	e052                	sd	s4,0(sp)
    80002746:	1800                	addi	s0,sp,48
    80002748:	84aa                	mv	s1,a0
    8000274a:	892e                	mv	s2,a1
    8000274c:	89b2                	mv	s3,a2
    8000274e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002750:	fffff097          	auipc	ra,0xfffff
    80002754:	576080e7          	jalr	1398(ra) # 80001cc6 <myproc>
  if(user_dst){
    80002758:	c08d                	beqz	s1,8000277a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000275a:	86d2                	mv	a3,s4
    8000275c:	864e                	mv	a2,s3
    8000275e:	85ca                	mv	a1,s2
    80002760:	6928                	ld	a0,80(a0)
    80002762:	fffff097          	auipc	ra,0xfffff
    80002766:	356080e7          	jalr	854(ra) # 80001ab8 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000276a:	70a2                	ld	ra,40(sp)
    8000276c:	7402                	ld	s0,32(sp)
    8000276e:	64e2                	ld	s1,24(sp)
    80002770:	6942                	ld	s2,16(sp)
    80002772:	69a2                	ld	s3,8(sp)
    80002774:	6a02                	ld	s4,0(sp)
    80002776:	6145                	addi	sp,sp,48
    80002778:	8082                	ret
    memmove((char *)dst, src, len);
    8000277a:	000a061b          	sext.w	a2,s4
    8000277e:	85ce                	mv	a1,s3
    80002780:	854a                	mv	a0,s2
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	7b4080e7          	jalr	1972(ra) # 80000f36 <memmove>
    return 0;
    8000278a:	8526                	mv	a0,s1
    8000278c:	bff9                	j	8000276a <either_copyout+0x32>

000000008000278e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000278e:	7179                	addi	sp,sp,-48
    80002790:	f406                	sd	ra,40(sp)
    80002792:	f022                	sd	s0,32(sp)
    80002794:	ec26                	sd	s1,24(sp)
    80002796:	e84a                	sd	s2,16(sp)
    80002798:	e44e                	sd	s3,8(sp)
    8000279a:	e052                	sd	s4,0(sp)
    8000279c:	1800                	addi	s0,sp,48
    8000279e:	892a                	mv	s2,a0
    800027a0:	84ae                	mv	s1,a1
    800027a2:	89b2                	mv	s3,a2
    800027a4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027a6:	fffff097          	auipc	ra,0xfffff
    800027aa:	520080e7          	jalr	1312(ra) # 80001cc6 <myproc>
  if(user_src){
    800027ae:	c08d                	beqz	s1,800027d0 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800027b0:	86d2                	mv	a3,s4
    800027b2:	864e                	mv	a2,s3
    800027b4:	85ca                	mv	a1,s2
    800027b6:	6928                	ld	a0,80(a0)
    800027b8:	fffff097          	auipc	ra,0xfffff
    800027bc:	0c2080e7          	jalr	194(ra) # 8000187a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800027c0:	70a2                	ld	ra,40(sp)
    800027c2:	7402                	ld	s0,32(sp)
    800027c4:	64e2                	ld	s1,24(sp)
    800027c6:	6942                	ld	s2,16(sp)
    800027c8:	69a2                	ld	s3,8(sp)
    800027ca:	6a02                	ld	s4,0(sp)
    800027cc:	6145                	addi	sp,sp,48
    800027ce:	8082                	ret
    memmove(dst, (char*)src, len);
    800027d0:	000a061b          	sext.w	a2,s4
    800027d4:	85ce                	mv	a1,s3
    800027d6:	854a                	mv	a0,s2
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	75e080e7          	jalr	1886(ra) # 80000f36 <memmove>
    return 0;
    800027e0:	8526                	mv	a0,s1
    800027e2:	bff9                	j	800027c0 <either_copyin+0x32>

00000000800027e4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027e4:	715d                	addi	sp,sp,-80
    800027e6:	e486                	sd	ra,72(sp)
    800027e8:	e0a2                	sd	s0,64(sp)
    800027ea:	fc26                	sd	s1,56(sp)
    800027ec:	f84a                	sd	s2,48(sp)
    800027ee:	f44e                	sd	s3,40(sp)
    800027f0:	f052                	sd	s4,32(sp)
    800027f2:	ec56                	sd	s5,24(sp)
    800027f4:	e85a                	sd	s6,16(sp)
    800027f6:	e45e                	sd	s7,8(sp)
    800027f8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027fa:	00006517          	auipc	a0,0x6
    800027fe:	8ce50513          	addi	a0,a0,-1842 # 800080c8 <digits+0x88>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	d90080e7          	jalr	-624(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000280a:	0002f497          	auipc	s1,0x2f
    8000280e:	6ce48493          	addi	s1,s1,1742 # 80031ed8 <proc+0x158>
    80002812:	00035917          	auipc	s2,0x35
    80002816:	0c690913          	addi	s2,s2,198 # 800378d8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000281a:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000281c:	00006997          	auipc	s3,0x6
    80002820:	a5498993          	addi	s3,s3,-1452 # 80008270 <digits+0x230>
    printf("%d %s %s", p->pid, state, p->name);
    80002824:	00006a97          	auipc	s5,0x6
    80002828:	a54a8a93          	addi	s5,s5,-1452 # 80008278 <digits+0x238>
    printf("\n");
    8000282c:	00006a17          	auipc	s4,0x6
    80002830:	89ca0a13          	addi	s4,s4,-1892 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002834:	00006b97          	auipc	s7,0x6
    80002838:	a7cb8b93          	addi	s7,s7,-1412 # 800082b0 <states.1716>
    8000283c:	a00d                	j	8000285e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000283e:	ee06a583          	lw	a1,-288(a3)
    80002842:	8556                	mv	a0,s5
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	d4e080e7          	jalr	-690(ra) # 80000592 <printf>
    printf("\n");
    8000284c:	8552                	mv	a0,s4
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	d44080e7          	jalr	-700(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002856:	16848493          	addi	s1,s1,360
    8000285a:	03248163          	beq	s1,s2,8000287c <procdump+0x98>
    if(p->state == UNUSED)
    8000285e:	86a6                	mv	a3,s1
    80002860:	ec04a783          	lw	a5,-320(s1)
    80002864:	dbed                	beqz	a5,80002856 <procdump+0x72>
      state = "???";
    80002866:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002868:	fcfb6be3          	bltu	s6,a5,8000283e <procdump+0x5a>
    8000286c:	1782                	slli	a5,a5,0x20
    8000286e:	9381                	srli	a5,a5,0x20
    80002870:	078e                	slli	a5,a5,0x3
    80002872:	97de                	add	a5,a5,s7
    80002874:	6390                	ld	a2,0(a5)
    80002876:	f661                	bnez	a2,8000283e <procdump+0x5a>
      state = "???";
    80002878:	864e                	mv	a2,s3
    8000287a:	b7d1                	j	8000283e <procdump+0x5a>
  }
}
    8000287c:	60a6                	ld	ra,72(sp)
    8000287e:	6406                	ld	s0,64(sp)
    80002880:	74e2                	ld	s1,56(sp)
    80002882:	7942                	ld	s2,48(sp)
    80002884:	79a2                	ld	s3,40(sp)
    80002886:	7a02                	ld	s4,32(sp)
    80002888:	6ae2                	ld	s5,24(sp)
    8000288a:	6b42                	ld	s6,16(sp)
    8000288c:	6ba2                	ld	s7,8(sp)
    8000288e:	6161                	addi	sp,sp,80
    80002890:	8082                	ret

0000000080002892 <swtch>:
    80002892:	00153023          	sd	ra,0(a0)
    80002896:	00253423          	sd	sp,8(a0)
    8000289a:	e900                	sd	s0,16(a0)
    8000289c:	ed04                	sd	s1,24(a0)
    8000289e:	03253023          	sd	s2,32(a0)
    800028a2:	03353423          	sd	s3,40(a0)
    800028a6:	03453823          	sd	s4,48(a0)
    800028aa:	03553c23          	sd	s5,56(a0)
    800028ae:	05653023          	sd	s6,64(a0)
    800028b2:	05753423          	sd	s7,72(a0)
    800028b6:	05853823          	sd	s8,80(a0)
    800028ba:	05953c23          	sd	s9,88(a0)
    800028be:	07a53023          	sd	s10,96(a0)
    800028c2:	07b53423          	sd	s11,104(a0)
    800028c6:	0005b083          	ld	ra,0(a1)
    800028ca:	0085b103          	ld	sp,8(a1)
    800028ce:	6980                	ld	s0,16(a1)
    800028d0:	6d84                	ld	s1,24(a1)
    800028d2:	0205b903          	ld	s2,32(a1)
    800028d6:	0285b983          	ld	s3,40(a1)
    800028da:	0305ba03          	ld	s4,48(a1)
    800028de:	0385ba83          	ld	s5,56(a1)
    800028e2:	0405bb03          	ld	s6,64(a1)
    800028e6:	0485bb83          	ld	s7,72(a1)
    800028ea:	0505bc03          	ld	s8,80(a1)
    800028ee:	0585bc83          	ld	s9,88(a1)
    800028f2:	0605bd03          	ld	s10,96(a1)
    800028f6:	0685bd83          	ld	s11,104(a1)
    800028fa:	8082                	ret

00000000800028fc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028fc:	1141                	addi	sp,sp,-16
    800028fe:	e406                	sd	ra,8(sp)
    80002900:	e022                	sd	s0,0(sp)
    80002902:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002904:	00006597          	auipc	a1,0x6
    80002908:	9d458593          	addi	a1,a1,-1580 # 800082d8 <states.1716+0x28>
    8000290c:	00035517          	auipc	a0,0x35
    80002910:	e7450513          	addi	a0,a0,-396 # 80037780 <tickslock>
    80002914:	ffffe097          	auipc	ra,0xffffe
    80002918:	436080e7          	jalr	1078(ra) # 80000d4a <initlock>
}
    8000291c:	60a2                	ld	ra,8(sp)
    8000291e:	6402                	ld	s0,0(sp)
    80002920:	0141                	addi	sp,sp,16
    80002922:	8082                	ret

0000000080002924 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002924:	1141                	addi	sp,sp,-16
    80002926:	e422                	sd	s0,8(sp)
    80002928:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000292a:	00003797          	auipc	a5,0x3
    8000292e:	4e678793          	addi	a5,a5,1254 # 80005e10 <kernelvec>
    80002932:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002936:	6422                	ld	s0,8(sp)
    80002938:	0141                	addi	sp,sp,16
    8000293a:	8082                	ret

000000008000293c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000293c:	1141                	addi	sp,sp,-16
    8000293e:	e406                	sd	ra,8(sp)
    80002940:	e022                	sd	s0,0(sp)
    80002942:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002944:	fffff097          	auipc	ra,0xfffff
    80002948:	382080e7          	jalr	898(ra) # 80001cc6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000294c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002950:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002952:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002956:	00004617          	auipc	a2,0x4
    8000295a:	6aa60613          	addi	a2,a2,1706 # 80007000 <_trampoline>
    8000295e:	00004697          	auipc	a3,0x4
    80002962:	6a268693          	addi	a3,a3,1698 # 80007000 <_trampoline>
    80002966:	8e91                	sub	a3,a3,a2
    80002968:	040007b7          	lui	a5,0x4000
    8000296c:	17fd                	addi	a5,a5,-1
    8000296e:	07b2                	slli	a5,a5,0xc
    80002970:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002972:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002976:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002978:	180026f3          	csrr	a3,satp
    8000297c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000297e:	6d38                	ld	a4,88(a0)
    80002980:	6134                	ld	a3,64(a0)
    80002982:	6585                	lui	a1,0x1
    80002984:	96ae                	add	a3,a3,a1
    80002986:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002988:	6d38                	ld	a4,88(a0)
    8000298a:	00000697          	auipc	a3,0x0
    8000298e:	13868693          	addi	a3,a3,312 # 80002ac2 <usertrap>
    80002992:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002994:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002996:	8692                	mv	a3,tp
    80002998:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000299a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000299e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029a2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029a6:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029aa:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029ac:	6f18                	ld	a4,24(a4)
    800029ae:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029b2:	692c                	ld	a1,80(a0)
    800029b4:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800029b6:	00004717          	auipc	a4,0x4
    800029ba:	6da70713          	addi	a4,a4,1754 # 80007090 <userret>
    800029be:	8f11                	sub	a4,a4,a2
    800029c0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800029c2:	577d                	li	a4,-1
    800029c4:	177e                	slli	a4,a4,0x3f
    800029c6:	8dd9                	or	a1,a1,a4
    800029c8:	02000537          	lui	a0,0x2000
    800029cc:	157d                	addi	a0,a0,-1
    800029ce:	0536                	slli	a0,a0,0xd
    800029d0:	9782                	jalr	a5
}
    800029d2:	60a2                	ld	ra,8(sp)
    800029d4:	6402                	ld	s0,0(sp)
    800029d6:	0141                	addi	sp,sp,16
    800029d8:	8082                	ret

00000000800029da <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029da:	1101                	addi	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	e426                	sd	s1,8(sp)
    800029e2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029e4:	00035497          	auipc	s1,0x35
    800029e8:	d9c48493          	addi	s1,s1,-612 # 80037780 <tickslock>
    800029ec:	8526                	mv	a0,s1
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	3ec080e7          	jalr	1004(ra) # 80000dda <acquire>
  ticks++;
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	62a50513          	addi	a0,a0,1578 # 80009020 <ticks>
    800029fe:	411c                	lw	a5,0(a0)
    80002a00:	2785                	addiw	a5,a5,1
    80002a02:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a04:	00000097          	auipc	ra,0x0
    80002a08:	c58080e7          	jalr	-936(ra) # 8000265c <wakeup>
  release(&tickslock);
    80002a0c:	8526                	mv	a0,s1
    80002a0e:	ffffe097          	auipc	ra,0xffffe
    80002a12:	480080e7          	jalr	1152(ra) # 80000e8e <release>
}
    80002a16:	60e2                	ld	ra,24(sp)
    80002a18:	6442                	ld	s0,16(sp)
    80002a1a:	64a2                	ld	s1,8(sp)
    80002a1c:	6105                	addi	sp,sp,32
    80002a1e:	8082                	ret

0000000080002a20 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a20:	1101                	addi	sp,sp,-32
    80002a22:	ec06                	sd	ra,24(sp)
    80002a24:	e822                	sd	s0,16(sp)
    80002a26:	e426                	sd	s1,8(sp)
    80002a28:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a2a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a2e:	00074d63          	bltz	a4,80002a48 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a32:	57fd                	li	a5,-1
    80002a34:	17fe                	slli	a5,a5,0x3f
    80002a36:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a38:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a3a:	06f70363          	beq	a4,a5,80002aa0 <devintr+0x80>
  }
}
    80002a3e:	60e2                	ld	ra,24(sp)
    80002a40:	6442                	ld	s0,16(sp)
    80002a42:	64a2                	ld	s1,8(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret
     (scause & 0xff) == 9){
    80002a48:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a4c:	46a5                	li	a3,9
    80002a4e:	fed792e3          	bne	a5,a3,80002a32 <devintr+0x12>
    int irq = plic_claim();
    80002a52:	00003097          	auipc	ra,0x3
    80002a56:	4c6080e7          	jalr	1222(ra) # 80005f18 <plic_claim>
    80002a5a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a5c:	47a9                	li	a5,10
    80002a5e:	02f50763          	beq	a0,a5,80002a8c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a62:	4785                	li	a5,1
    80002a64:	02f50963          	beq	a0,a5,80002a96 <devintr+0x76>
    return 1;
    80002a68:	4505                	li	a0,1
    } else if(irq){
    80002a6a:	d8f1                	beqz	s1,80002a3e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a6c:	85a6                	mv	a1,s1
    80002a6e:	00006517          	auipc	a0,0x6
    80002a72:	87250513          	addi	a0,a0,-1934 # 800082e0 <states.1716+0x30>
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	b1c080e7          	jalr	-1252(ra) # 80000592 <printf>
      plic_complete(irq);
    80002a7e:	8526                	mv	a0,s1
    80002a80:	00003097          	auipc	ra,0x3
    80002a84:	4bc080e7          	jalr	1212(ra) # 80005f3c <plic_complete>
    return 1;
    80002a88:	4505                	li	a0,1
    80002a8a:	bf55                	j	80002a3e <devintr+0x1e>
      uartintr();
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	f48080e7          	jalr	-184(ra) # 800009d4 <uartintr>
    80002a94:	b7ed                	j	80002a7e <devintr+0x5e>
      virtio_disk_intr();
    80002a96:	00004097          	auipc	ra,0x4
    80002a9a:	940080e7          	jalr	-1728(ra) # 800063d6 <virtio_disk_intr>
    80002a9e:	b7c5                	j	80002a7e <devintr+0x5e>
    if(cpuid() == 0){
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	1fa080e7          	jalr	506(ra) # 80001c9a <cpuid>
    80002aa8:	c901                	beqz	a0,80002ab8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002aaa:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002aae:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ab0:	14479073          	csrw	sip,a5
    return 2;
    80002ab4:	4509                	li	a0,2
    80002ab6:	b761                	j	80002a3e <devintr+0x1e>
      clockintr();
    80002ab8:	00000097          	auipc	ra,0x0
    80002abc:	f22080e7          	jalr	-222(ra) # 800029da <clockintr>
    80002ac0:	b7ed                	j	80002aaa <devintr+0x8a>

0000000080002ac2 <usertrap>:
{
    80002ac2:	1101                	addi	sp,sp,-32
    80002ac4:	ec06                	sd	ra,24(sp)
    80002ac6:	e822                	sd	s0,16(sp)
    80002ac8:	e426                	sd	s1,8(sp)
    80002aca:	e04a                	sd	s2,0(sp)
    80002acc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ace:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ad2:	1007f793          	andi	a5,a5,256
    80002ad6:	e3b9                	bnez	a5,80002b1c <usertrap+0x5a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ad8:	00003797          	auipc	a5,0x3
    80002adc:	33878793          	addi	a5,a5,824 # 80005e10 <kernelvec>
    80002ae0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ae4:	fffff097          	auipc	ra,0xfffff
    80002ae8:	1e2080e7          	jalr	482(ra) # 80001cc6 <myproc>
    80002aec:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002aee:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002af0:	14102773          	csrr	a4,sepc
    80002af4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002afa:	47a1                	li	a5,8
    80002afc:	02f70863          	beq	a4,a5,80002b2c <usertrap+0x6a>
    80002b00:	14202773          	csrr	a4,scause
  } else if(r_scause() == 15){
    80002b04:	47bd                	li	a5,15
    80002b06:	06f70563          	beq	a4,a5,80002b70 <usertrap+0xae>
  } else if((which_dev = devintr()) != 0){
    80002b0a:	00000097          	auipc	ra,0x0
    80002b0e:	f16080e7          	jalr	-234(ra) # 80002a20 <devintr>
    80002b12:	892a                	mv	s2,a0
    80002b14:	c935                	beqz	a0,80002b88 <usertrap+0xc6>
  if(p->killed)
    80002b16:	589c                	lw	a5,48(s1)
    80002b18:	c7dd                	beqz	a5,80002bc6 <usertrap+0x104>
    80002b1a:	a04d                	j	80002bbc <usertrap+0xfa>
    panic("usertrap: not from user mode");
    80002b1c:	00005517          	auipc	a0,0x5
    80002b20:	7e450513          	addi	a0,a0,2020 # 80008300 <states.1716+0x50>
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	a24080e7          	jalr	-1500(ra) # 80000548 <panic>
    if(p->killed)
    80002b2c:	591c                	lw	a5,48(a0)
    80002b2e:	eb9d                	bnez	a5,80002b64 <usertrap+0xa2>
    p->trapframe->epc += 4;
    80002b30:	6cb8                	ld	a4,88(s1)
    80002b32:	6f1c                	ld	a5,24(a4)
    80002b34:	0791                	addi	a5,a5,4
    80002b36:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b3c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b40:	10079073          	csrw	sstatus,a5
    syscall();
    80002b44:	00000097          	auipc	ra,0x0
    80002b48:	2d8080e7          	jalr	728(ra) # 80002e1c <syscall>
  if(p->killed)
    80002b4c:	589c                	lw	a5,48(s1)
    80002b4e:	e7c1                	bnez	a5,80002bd6 <usertrap+0x114>
  usertrapret();
    80002b50:	00000097          	auipc	ra,0x0
    80002b54:	dec080e7          	jalr	-532(ra) # 8000293c <usertrapret>
}
    80002b58:	60e2                	ld	ra,24(sp)
    80002b5a:	6442                	ld	s0,16(sp)
    80002b5c:	64a2                	ld	s1,8(sp)
    80002b5e:	6902                	ld	s2,0(sp)
    80002b60:	6105                	addi	sp,sp,32
    80002b62:	8082                	ret
      exit(-1);
    80002b64:	557d                	li	a0,-1
    80002b66:	00000097          	auipc	ra,0x0
    80002b6a:	82a080e7          	jalr	-2006(ra) # 80002390 <exit>
    80002b6e:	b7c9                	j	80002b30 <usertrap+0x6e>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b70:	14302573          	csrr	a0,stval
    if(cowcopy(va) == -1){
    80002b74:	fffff097          	auipc	ra,0xfffff
    80002b78:	e46080e7          	jalr	-442(ra) # 800019ba <cowcopy>
    80002b7c:	57fd                	li	a5,-1
    80002b7e:	fcf517e3          	bne	a0,a5,80002b4c <usertrap+0x8a>
      p->killed = 1;
    80002b82:	4785                	li	a5,1
    80002b84:	d89c                	sw	a5,48(s1)
    80002b86:	a815                	j	80002bba <usertrap+0xf8>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b88:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b8c:	5c90                	lw	a2,56(s1)
    80002b8e:	00005517          	auipc	a0,0x5
    80002b92:	79250513          	addi	a0,a0,1938 # 80008320 <states.1716+0x70>
    80002b96:	ffffe097          	auipc	ra,0xffffe
    80002b9a:	9fc080e7          	jalr	-1540(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b9e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ba2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ba6:	00005517          	auipc	a0,0x5
    80002baa:	7aa50513          	addi	a0,a0,1962 # 80008350 <states.1716+0xa0>
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	9e4080e7          	jalr	-1564(ra) # 80000592 <printf>
    p->killed = 1;
    80002bb6:	4785                	li	a5,1
    80002bb8:	d89c                	sw	a5,48(s1)
{
    80002bba:	4901                	li	s2,0
    exit(-1);
    80002bbc:	557d                	li	a0,-1
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	7d2080e7          	jalr	2002(ra) # 80002390 <exit>
  if(which_dev == 2)
    80002bc6:	4789                	li	a5,2
    80002bc8:	f8f914e3          	bne	s2,a5,80002b50 <usertrap+0x8e>
    yield();
    80002bcc:	00000097          	auipc	ra,0x0
    80002bd0:	8ce080e7          	jalr	-1842(ra) # 8000249a <yield>
    80002bd4:	bfb5                	j	80002b50 <usertrap+0x8e>
  if(p->killed)
    80002bd6:	4901                	li	s2,0
    80002bd8:	b7d5                	j	80002bbc <usertrap+0xfa>

0000000080002bda <kerneltrap>:
{
    80002bda:	7179                	addi	sp,sp,-48
    80002bdc:	f406                	sd	ra,40(sp)
    80002bde:	f022                	sd	s0,32(sp)
    80002be0:	ec26                	sd	s1,24(sp)
    80002be2:	e84a                	sd	s2,16(sp)
    80002be4:	e44e                	sd	s3,8(sp)
    80002be6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bec:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bf4:	1004f793          	andi	a5,s1,256
    80002bf8:	cb85                	beqz	a5,80002c28 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bfa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bfe:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c00:	ef85                	bnez	a5,80002c38 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c02:	00000097          	auipc	ra,0x0
    80002c06:	e1e080e7          	jalr	-482(ra) # 80002a20 <devintr>
    80002c0a:	cd1d                	beqz	a0,80002c48 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c0c:	4789                	li	a5,2
    80002c0e:	06f50a63          	beq	a0,a5,80002c82 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c12:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c16:	10049073          	csrw	sstatus,s1
}
    80002c1a:	70a2                	ld	ra,40(sp)
    80002c1c:	7402                	ld	s0,32(sp)
    80002c1e:	64e2                	ld	s1,24(sp)
    80002c20:	6942                	ld	s2,16(sp)
    80002c22:	69a2                	ld	s3,8(sp)
    80002c24:	6145                	addi	sp,sp,48
    80002c26:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	74850513          	addi	a0,a0,1864 # 80008370 <states.1716+0xc0>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	918080e7          	jalr	-1768(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c38:	00005517          	auipc	a0,0x5
    80002c3c:	76050513          	addi	a0,a0,1888 # 80008398 <states.1716+0xe8>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	908080e7          	jalr	-1784(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002c48:	85ce                	mv	a1,s3
    80002c4a:	00005517          	auipc	a0,0x5
    80002c4e:	76e50513          	addi	a0,a0,1902 # 800083b8 <states.1716+0x108>
    80002c52:	ffffe097          	auipc	ra,0xffffe
    80002c56:	940080e7          	jalr	-1728(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c5a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c5e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c62:	00005517          	auipc	a0,0x5
    80002c66:	76650513          	addi	a0,a0,1894 # 800083c8 <states.1716+0x118>
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	928080e7          	jalr	-1752(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002c72:	00005517          	auipc	a0,0x5
    80002c76:	76e50513          	addi	a0,a0,1902 # 800083e0 <states.1716+0x130>
    80002c7a:	ffffe097          	auipc	ra,0xffffe
    80002c7e:	8ce080e7          	jalr	-1842(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	044080e7          	jalr	68(ra) # 80001cc6 <myproc>
    80002c8a:	d541                	beqz	a0,80002c12 <kerneltrap+0x38>
    80002c8c:	fffff097          	auipc	ra,0xfffff
    80002c90:	03a080e7          	jalr	58(ra) # 80001cc6 <myproc>
    80002c94:	4d18                	lw	a4,24(a0)
    80002c96:	478d                	li	a5,3
    80002c98:	f6f71de3          	bne	a4,a5,80002c12 <kerneltrap+0x38>
    yield();
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	7fe080e7          	jalr	2046(ra) # 8000249a <yield>
    80002ca4:	b7bd                	j	80002c12 <kerneltrap+0x38>

0000000080002ca6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ca6:	1101                	addi	sp,sp,-32
    80002ca8:	ec06                	sd	ra,24(sp)
    80002caa:	e822                	sd	s0,16(sp)
    80002cac:	e426                	sd	s1,8(sp)
    80002cae:	1000                	addi	s0,sp,32
    80002cb0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	014080e7          	jalr	20(ra) # 80001cc6 <myproc>
  switch (n) {
    80002cba:	4795                	li	a5,5
    80002cbc:	0497e163          	bltu	a5,s1,80002cfe <argraw+0x58>
    80002cc0:	048a                	slli	s1,s1,0x2
    80002cc2:	00005717          	auipc	a4,0x5
    80002cc6:	75670713          	addi	a4,a4,1878 # 80008418 <states.1716+0x168>
    80002cca:	94ba                	add	s1,s1,a4
    80002ccc:	409c                	lw	a5,0(s1)
    80002cce:	97ba                	add	a5,a5,a4
    80002cd0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cd2:	6d3c                	ld	a5,88(a0)
    80002cd4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cd6:	60e2                	ld	ra,24(sp)
    80002cd8:	6442                	ld	s0,16(sp)
    80002cda:	64a2                	ld	s1,8(sp)
    80002cdc:	6105                	addi	sp,sp,32
    80002cde:	8082                	ret
    return p->trapframe->a1;
    80002ce0:	6d3c                	ld	a5,88(a0)
    80002ce2:	7fa8                	ld	a0,120(a5)
    80002ce4:	bfcd                	j	80002cd6 <argraw+0x30>
    return p->trapframe->a2;
    80002ce6:	6d3c                	ld	a5,88(a0)
    80002ce8:	63c8                	ld	a0,128(a5)
    80002cea:	b7f5                	j	80002cd6 <argraw+0x30>
    return p->trapframe->a3;
    80002cec:	6d3c                	ld	a5,88(a0)
    80002cee:	67c8                	ld	a0,136(a5)
    80002cf0:	b7dd                	j	80002cd6 <argraw+0x30>
    return p->trapframe->a4;
    80002cf2:	6d3c                	ld	a5,88(a0)
    80002cf4:	6bc8                	ld	a0,144(a5)
    80002cf6:	b7c5                	j	80002cd6 <argraw+0x30>
    return p->trapframe->a5;
    80002cf8:	6d3c                	ld	a5,88(a0)
    80002cfa:	6fc8                	ld	a0,152(a5)
    80002cfc:	bfe9                	j	80002cd6 <argraw+0x30>
  panic("argraw");
    80002cfe:	00005517          	auipc	a0,0x5
    80002d02:	6f250513          	addi	a0,a0,1778 # 800083f0 <states.1716+0x140>
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	842080e7          	jalr	-1982(ra) # 80000548 <panic>

0000000080002d0e <fetchaddr>:
{
    80002d0e:	1101                	addi	sp,sp,-32
    80002d10:	ec06                	sd	ra,24(sp)
    80002d12:	e822                	sd	s0,16(sp)
    80002d14:	e426                	sd	s1,8(sp)
    80002d16:	e04a                	sd	s2,0(sp)
    80002d18:	1000                	addi	s0,sp,32
    80002d1a:	84aa                	mv	s1,a0
    80002d1c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	fa8080e7          	jalr	-88(ra) # 80001cc6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d26:	653c                	ld	a5,72(a0)
    80002d28:	02f4f863          	bgeu	s1,a5,80002d58 <fetchaddr+0x4a>
    80002d2c:	00848713          	addi	a4,s1,8
    80002d30:	02e7e663          	bltu	a5,a4,80002d5c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d34:	46a1                	li	a3,8
    80002d36:	8626                	mv	a2,s1
    80002d38:	85ca                	mv	a1,s2
    80002d3a:	6928                	ld	a0,80(a0)
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	b3e080e7          	jalr	-1218(ra) # 8000187a <copyin>
    80002d44:	00a03533          	snez	a0,a0
    80002d48:	40a00533          	neg	a0,a0
}
    80002d4c:	60e2                	ld	ra,24(sp)
    80002d4e:	6442                	ld	s0,16(sp)
    80002d50:	64a2                	ld	s1,8(sp)
    80002d52:	6902                	ld	s2,0(sp)
    80002d54:	6105                	addi	sp,sp,32
    80002d56:	8082                	ret
    return -1;
    80002d58:	557d                	li	a0,-1
    80002d5a:	bfcd                	j	80002d4c <fetchaddr+0x3e>
    80002d5c:	557d                	li	a0,-1
    80002d5e:	b7fd                	j	80002d4c <fetchaddr+0x3e>

0000000080002d60 <fetchstr>:
{
    80002d60:	7179                	addi	sp,sp,-48
    80002d62:	f406                	sd	ra,40(sp)
    80002d64:	f022                	sd	s0,32(sp)
    80002d66:	ec26                	sd	s1,24(sp)
    80002d68:	e84a                	sd	s2,16(sp)
    80002d6a:	e44e                	sd	s3,8(sp)
    80002d6c:	1800                	addi	s0,sp,48
    80002d6e:	892a                	mv	s2,a0
    80002d70:	84ae                	mv	s1,a1
    80002d72:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d74:	fffff097          	auipc	ra,0xfffff
    80002d78:	f52080e7          	jalr	-174(ra) # 80001cc6 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d7c:	86ce                	mv	a3,s3
    80002d7e:	864a                	mv	a2,s2
    80002d80:	85a6                	mv	a1,s1
    80002d82:	6928                	ld	a0,80(a0)
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	b82080e7          	jalr	-1150(ra) # 80001906 <copyinstr>
  if(err < 0)
    80002d8c:	00054763          	bltz	a0,80002d9a <fetchstr+0x3a>
  return strlen(buf);
    80002d90:	8526                	mv	a0,s1
    80002d92:	ffffe097          	auipc	ra,0xffffe
    80002d96:	2cc080e7          	jalr	716(ra) # 8000105e <strlen>
}
    80002d9a:	70a2                	ld	ra,40(sp)
    80002d9c:	7402                	ld	s0,32(sp)
    80002d9e:	64e2                	ld	s1,24(sp)
    80002da0:	6942                	ld	s2,16(sp)
    80002da2:	69a2                	ld	s3,8(sp)
    80002da4:	6145                	addi	sp,sp,48
    80002da6:	8082                	ret

0000000080002da8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002da8:	1101                	addi	sp,sp,-32
    80002daa:	ec06                	sd	ra,24(sp)
    80002dac:	e822                	sd	s0,16(sp)
    80002dae:	e426                	sd	s1,8(sp)
    80002db0:	1000                	addi	s0,sp,32
    80002db2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002db4:	00000097          	auipc	ra,0x0
    80002db8:	ef2080e7          	jalr	-270(ra) # 80002ca6 <argraw>
    80002dbc:	c088                	sw	a0,0(s1)
  return 0;
}
    80002dbe:	4501                	li	a0,0
    80002dc0:	60e2                	ld	ra,24(sp)
    80002dc2:	6442                	ld	s0,16(sp)
    80002dc4:	64a2                	ld	s1,8(sp)
    80002dc6:	6105                	addi	sp,sp,32
    80002dc8:	8082                	ret

0000000080002dca <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	1000                	addi	s0,sp,32
    80002dd4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	ed0080e7          	jalr	-304(ra) # 80002ca6 <argraw>
    80002dde:	e088                	sd	a0,0(s1)
  return 0;
}
    80002de0:	4501                	li	a0,0
    80002de2:	60e2                	ld	ra,24(sp)
    80002de4:	6442                	ld	s0,16(sp)
    80002de6:	64a2                	ld	s1,8(sp)
    80002de8:	6105                	addi	sp,sp,32
    80002dea:	8082                	ret

0000000080002dec <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002dec:	1101                	addi	sp,sp,-32
    80002dee:	ec06                	sd	ra,24(sp)
    80002df0:	e822                	sd	s0,16(sp)
    80002df2:	e426                	sd	s1,8(sp)
    80002df4:	e04a                	sd	s2,0(sp)
    80002df6:	1000                	addi	s0,sp,32
    80002df8:	84ae                	mv	s1,a1
    80002dfa:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	eaa080e7          	jalr	-342(ra) # 80002ca6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e04:	864a                	mv	a2,s2
    80002e06:	85a6                	mv	a1,s1
    80002e08:	00000097          	auipc	ra,0x0
    80002e0c:	f58080e7          	jalr	-168(ra) # 80002d60 <fetchstr>
}
    80002e10:	60e2                	ld	ra,24(sp)
    80002e12:	6442                	ld	s0,16(sp)
    80002e14:	64a2                	ld	s1,8(sp)
    80002e16:	6902                	ld	s2,0(sp)
    80002e18:	6105                	addi	sp,sp,32
    80002e1a:	8082                	ret

0000000080002e1c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e1c:	1101                	addi	sp,sp,-32
    80002e1e:	ec06                	sd	ra,24(sp)
    80002e20:	e822                	sd	s0,16(sp)
    80002e22:	e426                	sd	s1,8(sp)
    80002e24:	e04a                	sd	s2,0(sp)
    80002e26:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e28:	fffff097          	auipc	ra,0xfffff
    80002e2c:	e9e080e7          	jalr	-354(ra) # 80001cc6 <myproc>
    80002e30:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e32:	05853903          	ld	s2,88(a0)
    80002e36:	0a893783          	ld	a5,168(s2)
    80002e3a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e3e:	37fd                	addiw	a5,a5,-1
    80002e40:	4751                	li	a4,20
    80002e42:	00f76f63          	bltu	a4,a5,80002e60 <syscall+0x44>
    80002e46:	00369713          	slli	a4,a3,0x3
    80002e4a:	00005797          	auipc	a5,0x5
    80002e4e:	5e678793          	addi	a5,a5,1510 # 80008430 <syscalls>
    80002e52:	97ba                	add	a5,a5,a4
    80002e54:	639c                	ld	a5,0(a5)
    80002e56:	c789                	beqz	a5,80002e60 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e58:	9782                	jalr	a5
    80002e5a:	06a93823          	sd	a0,112(s2)
    80002e5e:	a839                	j	80002e7c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e60:	15848613          	addi	a2,s1,344
    80002e64:	5c8c                	lw	a1,56(s1)
    80002e66:	00005517          	auipc	a0,0x5
    80002e6a:	59250513          	addi	a0,a0,1426 # 800083f8 <states.1716+0x148>
    80002e6e:	ffffd097          	auipc	ra,0xffffd
    80002e72:	724080e7          	jalr	1828(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e76:	6cbc                	ld	a5,88(s1)
    80002e78:	577d                	li	a4,-1
    80002e7a:	fbb8                	sd	a4,112(a5)
  }
}
    80002e7c:	60e2                	ld	ra,24(sp)
    80002e7e:	6442                	ld	s0,16(sp)
    80002e80:	64a2                	ld	s1,8(sp)
    80002e82:	6902                	ld	s2,0(sp)
    80002e84:	6105                	addi	sp,sp,32
    80002e86:	8082                	ret

0000000080002e88 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e90:	fec40593          	addi	a1,s0,-20
    80002e94:	4501                	li	a0,0
    80002e96:	00000097          	auipc	ra,0x0
    80002e9a:	f12080e7          	jalr	-238(ra) # 80002da8 <argint>
    return -1;
    80002e9e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ea0:	00054963          	bltz	a0,80002eb2 <sys_exit+0x2a>
  exit(n);
    80002ea4:	fec42503          	lw	a0,-20(s0)
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	4e8080e7          	jalr	1256(ra) # 80002390 <exit>
  return 0;  // not reached
    80002eb0:	4781                	li	a5,0
}
    80002eb2:	853e                	mv	a0,a5
    80002eb4:	60e2                	ld	ra,24(sp)
    80002eb6:	6442                	ld	s0,16(sp)
    80002eb8:	6105                	addi	sp,sp,32
    80002eba:	8082                	ret

0000000080002ebc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ebc:	1141                	addi	sp,sp,-16
    80002ebe:	e406                	sd	ra,8(sp)
    80002ec0:	e022                	sd	s0,0(sp)
    80002ec2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ec4:	fffff097          	auipc	ra,0xfffff
    80002ec8:	e02080e7          	jalr	-510(ra) # 80001cc6 <myproc>
}
    80002ecc:	5d08                	lw	a0,56(a0)
    80002ece:	60a2                	ld	ra,8(sp)
    80002ed0:	6402                	ld	s0,0(sp)
    80002ed2:	0141                	addi	sp,sp,16
    80002ed4:	8082                	ret

0000000080002ed6 <sys_fork>:

uint64
sys_fork(void)
{
    80002ed6:	1141                	addi	sp,sp,-16
    80002ed8:	e406                	sd	ra,8(sp)
    80002eda:	e022                	sd	s0,0(sp)
    80002edc:	0800                	addi	s0,sp,16
  return fork();
    80002ede:	fffff097          	auipc	ra,0xfffff
    80002ee2:	1a8080e7          	jalr	424(ra) # 80002086 <fork>
}
    80002ee6:	60a2                	ld	ra,8(sp)
    80002ee8:	6402                	ld	s0,0(sp)
    80002eea:	0141                	addi	sp,sp,16
    80002eec:	8082                	ret

0000000080002eee <sys_wait>:

uint64
sys_wait(void)
{
    80002eee:	1101                	addi	sp,sp,-32
    80002ef0:	ec06                	sd	ra,24(sp)
    80002ef2:	e822                	sd	s0,16(sp)
    80002ef4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002ef6:	fe840593          	addi	a1,s0,-24
    80002efa:	4501                	li	a0,0
    80002efc:	00000097          	auipc	ra,0x0
    80002f00:	ece080e7          	jalr	-306(ra) # 80002dca <argaddr>
    80002f04:	87aa                	mv	a5,a0
    return -1;
    80002f06:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f08:	0007c863          	bltz	a5,80002f18 <sys_wait+0x2a>
  return wait(p);
    80002f0c:	fe843503          	ld	a0,-24(s0)
    80002f10:	fffff097          	auipc	ra,0xfffff
    80002f14:	644080e7          	jalr	1604(ra) # 80002554 <wait>
}
    80002f18:	60e2                	ld	ra,24(sp)
    80002f1a:	6442                	ld	s0,16(sp)
    80002f1c:	6105                	addi	sp,sp,32
    80002f1e:	8082                	ret

0000000080002f20 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f20:	7179                	addi	sp,sp,-48
    80002f22:	f406                	sd	ra,40(sp)
    80002f24:	f022                	sd	s0,32(sp)
    80002f26:	ec26                	sd	s1,24(sp)
    80002f28:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f2a:	fdc40593          	addi	a1,s0,-36
    80002f2e:	4501                	li	a0,0
    80002f30:	00000097          	auipc	ra,0x0
    80002f34:	e78080e7          	jalr	-392(ra) # 80002da8 <argint>
    80002f38:	87aa                	mv	a5,a0
    return -1;
    80002f3a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002f3c:	0207c063          	bltz	a5,80002f5c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	d86080e7          	jalr	-634(ra) # 80001cc6 <myproc>
    80002f48:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002f4a:	fdc42503          	lw	a0,-36(s0)
    80002f4e:	fffff097          	auipc	ra,0xfffff
    80002f52:	0c4080e7          	jalr	196(ra) # 80002012 <growproc>
    80002f56:	00054863          	bltz	a0,80002f66 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002f5a:	8526                	mv	a0,s1
}
    80002f5c:	70a2                	ld	ra,40(sp)
    80002f5e:	7402                	ld	s0,32(sp)
    80002f60:	64e2                	ld	s1,24(sp)
    80002f62:	6145                	addi	sp,sp,48
    80002f64:	8082                	ret
    return -1;
    80002f66:	557d                	li	a0,-1
    80002f68:	bfd5                	j	80002f5c <sys_sbrk+0x3c>

0000000080002f6a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f6a:	7139                	addi	sp,sp,-64
    80002f6c:	fc06                	sd	ra,56(sp)
    80002f6e:	f822                	sd	s0,48(sp)
    80002f70:	f426                	sd	s1,40(sp)
    80002f72:	f04a                	sd	s2,32(sp)
    80002f74:	ec4e                	sd	s3,24(sp)
    80002f76:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f78:	fcc40593          	addi	a1,s0,-52
    80002f7c:	4501                	li	a0,0
    80002f7e:	00000097          	auipc	ra,0x0
    80002f82:	e2a080e7          	jalr	-470(ra) # 80002da8 <argint>
    return -1;
    80002f86:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f88:	06054563          	bltz	a0,80002ff2 <sys_sleep+0x88>
  acquire(&tickslock);
    80002f8c:	00034517          	auipc	a0,0x34
    80002f90:	7f450513          	addi	a0,a0,2036 # 80037780 <tickslock>
    80002f94:	ffffe097          	auipc	ra,0xffffe
    80002f98:	e46080e7          	jalr	-442(ra) # 80000dda <acquire>
  ticks0 = ticks;
    80002f9c:	00006917          	auipc	s2,0x6
    80002fa0:	08492903          	lw	s2,132(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002fa4:	fcc42783          	lw	a5,-52(s0)
    80002fa8:	cf85                	beqz	a5,80002fe0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002faa:	00034997          	auipc	s3,0x34
    80002fae:	7d698993          	addi	s3,s3,2006 # 80037780 <tickslock>
    80002fb2:	00006497          	auipc	s1,0x6
    80002fb6:	06e48493          	addi	s1,s1,110 # 80009020 <ticks>
    if(myproc()->killed){
    80002fba:	fffff097          	auipc	ra,0xfffff
    80002fbe:	d0c080e7          	jalr	-756(ra) # 80001cc6 <myproc>
    80002fc2:	591c                	lw	a5,48(a0)
    80002fc4:	ef9d                	bnez	a5,80003002 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002fc6:	85ce                	mv	a1,s3
    80002fc8:	8526                	mv	a0,s1
    80002fca:	fffff097          	auipc	ra,0xfffff
    80002fce:	50c080e7          	jalr	1292(ra) # 800024d6 <sleep>
  while(ticks - ticks0 < n){
    80002fd2:	409c                	lw	a5,0(s1)
    80002fd4:	412787bb          	subw	a5,a5,s2
    80002fd8:	fcc42703          	lw	a4,-52(s0)
    80002fdc:	fce7efe3          	bltu	a5,a4,80002fba <sys_sleep+0x50>
  }
  release(&tickslock);
    80002fe0:	00034517          	auipc	a0,0x34
    80002fe4:	7a050513          	addi	a0,a0,1952 # 80037780 <tickslock>
    80002fe8:	ffffe097          	auipc	ra,0xffffe
    80002fec:	ea6080e7          	jalr	-346(ra) # 80000e8e <release>
  return 0;
    80002ff0:	4781                	li	a5,0
}
    80002ff2:	853e                	mv	a0,a5
    80002ff4:	70e2                	ld	ra,56(sp)
    80002ff6:	7442                	ld	s0,48(sp)
    80002ff8:	74a2                	ld	s1,40(sp)
    80002ffa:	7902                	ld	s2,32(sp)
    80002ffc:	69e2                	ld	s3,24(sp)
    80002ffe:	6121                	addi	sp,sp,64
    80003000:	8082                	ret
      release(&tickslock);
    80003002:	00034517          	auipc	a0,0x34
    80003006:	77e50513          	addi	a0,a0,1918 # 80037780 <tickslock>
    8000300a:	ffffe097          	auipc	ra,0xffffe
    8000300e:	e84080e7          	jalr	-380(ra) # 80000e8e <release>
      return -1;
    80003012:	57fd                	li	a5,-1
    80003014:	bff9                	j	80002ff2 <sys_sleep+0x88>

0000000080003016 <sys_kill>:

uint64
sys_kill(void)
{
    80003016:	1101                	addi	sp,sp,-32
    80003018:	ec06                	sd	ra,24(sp)
    8000301a:	e822                	sd	s0,16(sp)
    8000301c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000301e:	fec40593          	addi	a1,s0,-20
    80003022:	4501                	li	a0,0
    80003024:	00000097          	auipc	ra,0x0
    80003028:	d84080e7          	jalr	-636(ra) # 80002da8 <argint>
    8000302c:	87aa                	mv	a5,a0
    return -1;
    8000302e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003030:	0007c863          	bltz	a5,80003040 <sys_kill+0x2a>
  return kill(pid);
    80003034:	fec42503          	lw	a0,-20(s0)
    80003038:	fffff097          	auipc	ra,0xfffff
    8000303c:	68e080e7          	jalr	1678(ra) # 800026c6 <kill>
}
    80003040:	60e2                	ld	ra,24(sp)
    80003042:	6442                	ld	s0,16(sp)
    80003044:	6105                	addi	sp,sp,32
    80003046:	8082                	ret

0000000080003048 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003048:	1101                	addi	sp,sp,-32
    8000304a:	ec06                	sd	ra,24(sp)
    8000304c:	e822                	sd	s0,16(sp)
    8000304e:	e426                	sd	s1,8(sp)
    80003050:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003052:	00034517          	auipc	a0,0x34
    80003056:	72e50513          	addi	a0,a0,1838 # 80037780 <tickslock>
    8000305a:	ffffe097          	auipc	ra,0xffffe
    8000305e:	d80080e7          	jalr	-640(ra) # 80000dda <acquire>
  xticks = ticks;
    80003062:	00006497          	auipc	s1,0x6
    80003066:	fbe4a483          	lw	s1,-66(s1) # 80009020 <ticks>
  release(&tickslock);
    8000306a:	00034517          	auipc	a0,0x34
    8000306e:	71650513          	addi	a0,a0,1814 # 80037780 <tickslock>
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	e1c080e7          	jalr	-484(ra) # 80000e8e <release>
  return xticks;
}
    8000307a:	02049513          	slli	a0,s1,0x20
    8000307e:	9101                	srli	a0,a0,0x20
    80003080:	60e2                	ld	ra,24(sp)
    80003082:	6442                	ld	s0,16(sp)
    80003084:	64a2                	ld	s1,8(sp)
    80003086:	6105                	addi	sp,sp,32
    80003088:	8082                	ret

000000008000308a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000308a:	7179                	addi	sp,sp,-48
    8000308c:	f406                	sd	ra,40(sp)
    8000308e:	f022                	sd	s0,32(sp)
    80003090:	ec26                	sd	s1,24(sp)
    80003092:	e84a                	sd	s2,16(sp)
    80003094:	e44e                	sd	s3,8(sp)
    80003096:	e052                	sd	s4,0(sp)
    80003098:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000309a:	00005597          	auipc	a1,0x5
    8000309e:	44658593          	addi	a1,a1,1094 # 800084e0 <syscalls+0xb0>
    800030a2:	00034517          	auipc	a0,0x34
    800030a6:	6f650513          	addi	a0,a0,1782 # 80037798 <bcache>
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	ca0080e7          	jalr	-864(ra) # 80000d4a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030b2:	0003c797          	auipc	a5,0x3c
    800030b6:	6e678793          	addi	a5,a5,1766 # 8003f798 <bcache+0x8000>
    800030ba:	0003d717          	auipc	a4,0x3d
    800030be:	94670713          	addi	a4,a4,-1722 # 8003fa00 <bcache+0x8268>
    800030c2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030c6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ca:	00034497          	auipc	s1,0x34
    800030ce:	6e648493          	addi	s1,s1,1766 # 800377b0 <bcache+0x18>
    b->next = bcache.head.next;
    800030d2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030d4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030d6:	00005a17          	auipc	s4,0x5
    800030da:	412a0a13          	addi	s4,s4,1042 # 800084e8 <syscalls+0xb8>
    b->next = bcache.head.next;
    800030de:	2b893783          	ld	a5,696(s2)
    800030e2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030e4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030e8:	85d2                	mv	a1,s4
    800030ea:	01048513          	addi	a0,s1,16
    800030ee:	00001097          	auipc	ra,0x1
    800030f2:	4b0080e7          	jalr	1200(ra) # 8000459e <initsleeplock>
    bcache.head.next->prev = b;
    800030f6:	2b893783          	ld	a5,696(s2)
    800030fa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030fc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003100:	45848493          	addi	s1,s1,1112
    80003104:	fd349de3          	bne	s1,s3,800030de <binit+0x54>
  }
}
    80003108:	70a2                	ld	ra,40(sp)
    8000310a:	7402                	ld	s0,32(sp)
    8000310c:	64e2                	ld	s1,24(sp)
    8000310e:	6942                	ld	s2,16(sp)
    80003110:	69a2                	ld	s3,8(sp)
    80003112:	6a02                	ld	s4,0(sp)
    80003114:	6145                	addi	sp,sp,48
    80003116:	8082                	ret

0000000080003118 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003118:	7179                	addi	sp,sp,-48
    8000311a:	f406                	sd	ra,40(sp)
    8000311c:	f022                	sd	s0,32(sp)
    8000311e:	ec26                	sd	s1,24(sp)
    80003120:	e84a                	sd	s2,16(sp)
    80003122:	e44e                	sd	s3,8(sp)
    80003124:	1800                	addi	s0,sp,48
    80003126:	89aa                	mv	s3,a0
    80003128:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000312a:	00034517          	auipc	a0,0x34
    8000312e:	66e50513          	addi	a0,a0,1646 # 80037798 <bcache>
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	ca8080e7          	jalr	-856(ra) # 80000dda <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000313a:	0003d497          	auipc	s1,0x3d
    8000313e:	9164b483          	ld	s1,-1770(s1) # 8003fa50 <bcache+0x82b8>
    80003142:	0003d797          	auipc	a5,0x3d
    80003146:	8be78793          	addi	a5,a5,-1858 # 8003fa00 <bcache+0x8268>
    8000314a:	02f48f63          	beq	s1,a5,80003188 <bread+0x70>
    8000314e:	873e                	mv	a4,a5
    80003150:	a021                	j	80003158 <bread+0x40>
    80003152:	68a4                	ld	s1,80(s1)
    80003154:	02e48a63          	beq	s1,a4,80003188 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003158:	449c                	lw	a5,8(s1)
    8000315a:	ff379ce3          	bne	a5,s3,80003152 <bread+0x3a>
    8000315e:	44dc                	lw	a5,12(s1)
    80003160:	ff2799e3          	bne	a5,s2,80003152 <bread+0x3a>
      b->refcnt++;
    80003164:	40bc                	lw	a5,64(s1)
    80003166:	2785                	addiw	a5,a5,1
    80003168:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000316a:	00034517          	auipc	a0,0x34
    8000316e:	62e50513          	addi	a0,a0,1582 # 80037798 <bcache>
    80003172:	ffffe097          	auipc	ra,0xffffe
    80003176:	d1c080e7          	jalr	-740(ra) # 80000e8e <release>
      acquiresleep(&b->lock);
    8000317a:	01048513          	addi	a0,s1,16
    8000317e:	00001097          	auipc	ra,0x1
    80003182:	45a080e7          	jalr	1114(ra) # 800045d8 <acquiresleep>
      return b;
    80003186:	a8b9                	j	800031e4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003188:	0003d497          	auipc	s1,0x3d
    8000318c:	8c04b483          	ld	s1,-1856(s1) # 8003fa48 <bcache+0x82b0>
    80003190:	0003d797          	auipc	a5,0x3d
    80003194:	87078793          	addi	a5,a5,-1936 # 8003fa00 <bcache+0x8268>
    80003198:	00f48863          	beq	s1,a5,800031a8 <bread+0x90>
    8000319c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000319e:	40bc                	lw	a5,64(s1)
    800031a0:	cf81                	beqz	a5,800031b8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031a2:	64a4                	ld	s1,72(s1)
    800031a4:	fee49de3          	bne	s1,a4,8000319e <bread+0x86>
  panic("bget: no buffers");
    800031a8:	00005517          	auipc	a0,0x5
    800031ac:	34850513          	addi	a0,a0,840 # 800084f0 <syscalls+0xc0>
    800031b0:	ffffd097          	auipc	ra,0xffffd
    800031b4:	398080e7          	jalr	920(ra) # 80000548 <panic>
      b->dev = dev;
    800031b8:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800031bc:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800031c0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031c4:	4785                	li	a5,1
    800031c6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031c8:	00034517          	auipc	a0,0x34
    800031cc:	5d050513          	addi	a0,a0,1488 # 80037798 <bcache>
    800031d0:	ffffe097          	auipc	ra,0xffffe
    800031d4:	cbe080e7          	jalr	-834(ra) # 80000e8e <release>
      acquiresleep(&b->lock);
    800031d8:	01048513          	addi	a0,s1,16
    800031dc:	00001097          	auipc	ra,0x1
    800031e0:	3fc080e7          	jalr	1020(ra) # 800045d8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031e4:	409c                	lw	a5,0(s1)
    800031e6:	cb89                	beqz	a5,800031f8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031e8:	8526                	mv	a0,s1
    800031ea:	70a2                	ld	ra,40(sp)
    800031ec:	7402                	ld	s0,32(sp)
    800031ee:	64e2                	ld	s1,24(sp)
    800031f0:	6942                	ld	s2,16(sp)
    800031f2:	69a2                	ld	s3,8(sp)
    800031f4:	6145                	addi	sp,sp,48
    800031f6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031f8:	4581                	li	a1,0
    800031fa:	8526                	mv	a0,s1
    800031fc:	00003097          	auipc	ra,0x3
    80003200:	f30080e7          	jalr	-208(ra) # 8000612c <virtio_disk_rw>
    b->valid = 1;
    80003204:	4785                	li	a5,1
    80003206:	c09c                	sw	a5,0(s1)
  return b;
    80003208:	b7c5                	j	800031e8 <bread+0xd0>

000000008000320a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000320a:	1101                	addi	sp,sp,-32
    8000320c:	ec06                	sd	ra,24(sp)
    8000320e:	e822                	sd	s0,16(sp)
    80003210:	e426                	sd	s1,8(sp)
    80003212:	1000                	addi	s0,sp,32
    80003214:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003216:	0541                	addi	a0,a0,16
    80003218:	00001097          	auipc	ra,0x1
    8000321c:	45a080e7          	jalr	1114(ra) # 80004672 <holdingsleep>
    80003220:	cd01                	beqz	a0,80003238 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003222:	4585                	li	a1,1
    80003224:	8526                	mv	a0,s1
    80003226:	00003097          	auipc	ra,0x3
    8000322a:	f06080e7          	jalr	-250(ra) # 8000612c <virtio_disk_rw>
}
    8000322e:	60e2                	ld	ra,24(sp)
    80003230:	6442                	ld	s0,16(sp)
    80003232:	64a2                	ld	s1,8(sp)
    80003234:	6105                	addi	sp,sp,32
    80003236:	8082                	ret
    panic("bwrite");
    80003238:	00005517          	auipc	a0,0x5
    8000323c:	2d050513          	addi	a0,a0,720 # 80008508 <syscalls+0xd8>
    80003240:	ffffd097          	auipc	ra,0xffffd
    80003244:	308080e7          	jalr	776(ra) # 80000548 <panic>

0000000080003248 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003248:	1101                	addi	sp,sp,-32
    8000324a:	ec06                	sd	ra,24(sp)
    8000324c:	e822                	sd	s0,16(sp)
    8000324e:	e426                	sd	s1,8(sp)
    80003250:	e04a                	sd	s2,0(sp)
    80003252:	1000                	addi	s0,sp,32
    80003254:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003256:	01050913          	addi	s2,a0,16
    8000325a:	854a                	mv	a0,s2
    8000325c:	00001097          	auipc	ra,0x1
    80003260:	416080e7          	jalr	1046(ra) # 80004672 <holdingsleep>
    80003264:	c92d                	beqz	a0,800032d6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003266:	854a                	mv	a0,s2
    80003268:	00001097          	auipc	ra,0x1
    8000326c:	3c6080e7          	jalr	966(ra) # 8000462e <releasesleep>

  acquire(&bcache.lock);
    80003270:	00034517          	auipc	a0,0x34
    80003274:	52850513          	addi	a0,a0,1320 # 80037798 <bcache>
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	b62080e7          	jalr	-1182(ra) # 80000dda <acquire>
  b->refcnt--;
    80003280:	40bc                	lw	a5,64(s1)
    80003282:	37fd                	addiw	a5,a5,-1
    80003284:	0007871b          	sext.w	a4,a5
    80003288:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000328a:	eb05                	bnez	a4,800032ba <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000328c:	68bc                	ld	a5,80(s1)
    8000328e:	64b8                	ld	a4,72(s1)
    80003290:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003292:	64bc                	ld	a5,72(s1)
    80003294:	68b8                	ld	a4,80(s1)
    80003296:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003298:	0003c797          	auipc	a5,0x3c
    8000329c:	50078793          	addi	a5,a5,1280 # 8003f798 <bcache+0x8000>
    800032a0:	2b87b703          	ld	a4,696(a5)
    800032a4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032a6:	0003c717          	auipc	a4,0x3c
    800032aa:	75a70713          	addi	a4,a4,1882 # 8003fa00 <bcache+0x8268>
    800032ae:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032b0:	2b87b703          	ld	a4,696(a5)
    800032b4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032b6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032ba:	00034517          	auipc	a0,0x34
    800032be:	4de50513          	addi	a0,a0,1246 # 80037798 <bcache>
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	bcc080e7          	jalr	-1076(ra) # 80000e8e <release>
}
    800032ca:	60e2                	ld	ra,24(sp)
    800032cc:	6442                	ld	s0,16(sp)
    800032ce:	64a2                	ld	s1,8(sp)
    800032d0:	6902                	ld	s2,0(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret
    panic("brelse");
    800032d6:	00005517          	auipc	a0,0x5
    800032da:	23a50513          	addi	a0,a0,570 # 80008510 <syscalls+0xe0>
    800032de:	ffffd097          	auipc	ra,0xffffd
    800032e2:	26a080e7          	jalr	618(ra) # 80000548 <panic>

00000000800032e6 <bpin>:

void
bpin(struct buf *b) {
    800032e6:	1101                	addi	sp,sp,-32
    800032e8:	ec06                	sd	ra,24(sp)
    800032ea:	e822                	sd	s0,16(sp)
    800032ec:	e426                	sd	s1,8(sp)
    800032ee:	1000                	addi	s0,sp,32
    800032f0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032f2:	00034517          	auipc	a0,0x34
    800032f6:	4a650513          	addi	a0,a0,1190 # 80037798 <bcache>
    800032fa:	ffffe097          	auipc	ra,0xffffe
    800032fe:	ae0080e7          	jalr	-1312(ra) # 80000dda <acquire>
  b->refcnt++;
    80003302:	40bc                	lw	a5,64(s1)
    80003304:	2785                	addiw	a5,a5,1
    80003306:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003308:	00034517          	auipc	a0,0x34
    8000330c:	49050513          	addi	a0,a0,1168 # 80037798 <bcache>
    80003310:	ffffe097          	auipc	ra,0xffffe
    80003314:	b7e080e7          	jalr	-1154(ra) # 80000e8e <release>
}
    80003318:	60e2                	ld	ra,24(sp)
    8000331a:	6442                	ld	s0,16(sp)
    8000331c:	64a2                	ld	s1,8(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <bunpin>:

void
bunpin(struct buf *b) {
    80003322:	1101                	addi	sp,sp,-32
    80003324:	ec06                	sd	ra,24(sp)
    80003326:	e822                	sd	s0,16(sp)
    80003328:	e426                	sd	s1,8(sp)
    8000332a:	1000                	addi	s0,sp,32
    8000332c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000332e:	00034517          	auipc	a0,0x34
    80003332:	46a50513          	addi	a0,a0,1130 # 80037798 <bcache>
    80003336:	ffffe097          	auipc	ra,0xffffe
    8000333a:	aa4080e7          	jalr	-1372(ra) # 80000dda <acquire>
  b->refcnt--;
    8000333e:	40bc                	lw	a5,64(s1)
    80003340:	37fd                	addiw	a5,a5,-1
    80003342:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003344:	00034517          	auipc	a0,0x34
    80003348:	45450513          	addi	a0,a0,1108 # 80037798 <bcache>
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	b42080e7          	jalr	-1214(ra) # 80000e8e <release>
}
    80003354:	60e2                	ld	ra,24(sp)
    80003356:	6442                	ld	s0,16(sp)
    80003358:	64a2                	ld	s1,8(sp)
    8000335a:	6105                	addi	sp,sp,32
    8000335c:	8082                	ret

000000008000335e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000335e:	1101                	addi	sp,sp,-32
    80003360:	ec06                	sd	ra,24(sp)
    80003362:	e822                	sd	s0,16(sp)
    80003364:	e426                	sd	s1,8(sp)
    80003366:	e04a                	sd	s2,0(sp)
    80003368:	1000                	addi	s0,sp,32
    8000336a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000336c:	00d5d59b          	srliw	a1,a1,0xd
    80003370:	0003d797          	auipc	a5,0x3d
    80003374:	b047a783          	lw	a5,-1276(a5) # 8003fe74 <sb+0x1c>
    80003378:	9dbd                	addw	a1,a1,a5
    8000337a:	00000097          	auipc	ra,0x0
    8000337e:	d9e080e7          	jalr	-610(ra) # 80003118 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003382:	0074f713          	andi	a4,s1,7
    80003386:	4785                	li	a5,1
    80003388:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000338c:	14ce                	slli	s1,s1,0x33
    8000338e:	90d9                	srli	s1,s1,0x36
    80003390:	00950733          	add	a4,a0,s1
    80003394:	05874703          	lbu	a4,88(a4)
    80003398:	00e7f6b3          	and	a3,a5,a4
    8000339c:	c69d                	beqz	a3,800033ca <bfree+0x6c>
    8000339e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033a0:	94aa                	add	s1,s1,a0
    800033a2:	fff7c793          	not	a5,a5
    800033a6:	8ff9                	and	a5,a5,a4
    800033a8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033ac:	00001097          	auipc	ra,0x1
    800033b0:	104080e7          	jalr	260(ra) # 800044b0 <log_write>
  brelse(bp);
    800033b4:	854a                	mv	a0,s2
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	e92080e7          	jalr	-366(ra) # 80003248 <brelse>
}
    800033be:	60e2                	ld	ra,24(sp)
    800033c0:	6442                	ld	s0,16(sp)
    800033c2:	64a2                	ld	s1,8(sp)
    800033c4:	6902                	ld	s2,0(sp)
    800033c6:	6105                	addi	sp,sp,32
    800033c8:	8082                	ret
    panic("freeing free block");
    800033ca:	00005517          	auipc	a0,0x5
    800033ce:	14e50513          	addi	a0,a0,334 # 80008518 <syscalls+0xe8>
    800033d2:	ffffd097          	auipc	ra,0xffffd
    800033d6:	176080e7          	jalr	374(ra) # 80000548 <panic>

00000000800033da <balloc>:
{
    800033da:	711d                	addi	sp,sp,-96
    800033dc:	ec86                	sd	ra,88(sp)
    800033de:	e8a2                	sd	s0,80(sp)
    800033e0:	e4a6                	sd	s1,72(sp)
    800033e2:	e0ca                	sd	s2,64(sp)
    800033e4:	fc4e                	sd	s3,56(sp)
    800033e6:	f852                	sd	s4,48(sp)
    800033e8:	f456                	sd	s5,40(sp)
    800033ea:	f05a                	sd	s6,32(sp)
    800033ec:	ec5e                	sd	s7,24(sp)
    800033ee:	e862                	sd	s8,16(sp)
    800033f0:	e466                	sd	s9,8(sp)
    800033f2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033f4:	0003d797          	auipc	a5,0x3d
    800033f8:	a687a783          	lw	a5,-1432(a5) # 8003fe5c <sb+0x4>
    800033fc:	cbd1                	beqz	a5,80003490 <balloc+0xb6>
    800033fe:	8baa                	mv	s7,a0
    80003400:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003402:	0003db17          	auipc	s6,0x3d
    80003406:	a56b0b13          	addi	s6,s6,-1450 # 8003fe58 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000340c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003410:	6c89                	lui	s9,0x2
    80003412:	a831                	j	8000342e <balloc+0x54>
    brelse(bp);
    80003414:	854a                	mv	a0,s2
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	e32080e7          	jalr	-462(ra) # 80003248 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000341e:	015c87bb          	addw	a5,s9,s5
    80003422:	00078a9b          	sext.w	s5,a5
    80003426:	004b2703          	lw	a4,4(s6)
    8000342a:	06eaf363          	bgeu	s5,a4,80003490 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000342e:	41fad79b          	sraiw	a5,s5,0x1f
    80003432:	0137d79b          	srliw	a5,a5,0x13
    80003436:	015787bb          	addw	a5,a5,s5
    8000343a:	40d7d79b          	sraiw	a5,a5,0xd
    8000343e:	01cb2583          	lw	a1,28(s6)
    80003442:	9dbd                	addw	a1,a1,a5
    80003444:	855e                	mv	a0,s7
    80003446:	00000097          	auipc	ra,0x0
    8000344a:	cd2080e7          	jalr	-814(ra) # 80003118 <bread>
    8000344e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003450:	004b2503          	lw	a0,4(s6)
    80003454:	000a849b          	sext.w	s1,s5
    80003458:	8662                	mv	a2,s8
    8000345a:	faa4fde3          	bgeu	s1,a0,80003414 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000345e:	41f6579b          	sraiw	a5,a2,0x1f
    80003462:	01d7d69b          	srliw	a3,a5,0x1d
    80003466:	00c6873b          	addw	a4,a3,a2
    8000346a:	00777793          	andi	a5,a4,7
    8000346e:	9f95                	subw	a5,a5,a3
    80003470:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003474:	4037571b          	sraiw	a4,a4,0x3
    80003478:	00e906b3          	add	a3,s2,a4
    8000347c:	0586c683          	lbu	a3,88(a3)
    80003480:	00d7f5b3          	and	a1,a5,a3
    80003484:	cd91                	beqz	a1,800034a0 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003486:	2605                	addiw	a2,a2,1
    80003488:	2485                	addiw	s1,s1,1
    8000348a:	fd4618e3          	bne	a2,s4,8000345a <balloc+0x80>
    8000348e:	b759                	j	80003414 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003490:	00005517          	auipc	a0,0x5
    80003494:	0a050513          	addi	a0,a0,160 # 80008530 <syscalls+0x100>
    80003498:	ffffd097          	auipc	ra,0xffffd
    8000349c:	0b0080e7          	jalr	176(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034a0:	974a                	add	a4,a4,s2
    800034a2:	8fd5                	or	a5,a5,a3
    800034a4:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800034a8:	854a                	mv	a0,s2
    800034aa:	00001097          	auipc	ra,0x1
    800034ae:	006080e7          	jalr	6(ra) # 800044b0 <log_write>
        brelse(bp);
    800034b2:	854a                	mv	a0,s2
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	d94080e7          	jalr	-620(ra) # 80003248 <brelse>
  bp = bread(dev, bno);
    800034bc:	85a6                	mv	a1,s1
    800034be:	855e                	mv	a0,s7
    800034c0:	00000097          	auipc	ra,0x0
    800034c4:	c58080e7          	jalr	-936(ra) # 80003118 <bread>
    800034c8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034ca:	40000613          	li	a2,1024
    800034ce:	4581                	li	a1,0
    800034d0:	05850513          	addi	a0,a0,88
    800034d4:	ffffe097          	auipc	ra,0xffffe
    800034d8:	a02080e7          	jalr	-1534(ra) # 80000ed6 <memset>
  log_write(bp);
    800034dc:	854a                	mv	a0,s2
    800034de:	00001097          	auipc	ra,0x1
    800034e2:	fd2080e7          	jalr	-46(ra) # 800044b0 <log_write>
  brelse(bp);
    800034e6:	854a                	mv	a0,s2
    800034e8:	00000097          	auipc	ra,0x0
    800034ec:	d60080e7          	jalr	-672(ra) # 80003248 <brelse>
}
    800034f0:	8526                	mv	a0,s1
    800034f2:	60e6                	ld	ra,88(sp)
    800034f4:	6446                	ld	s0,80(sp)
    800034f6:	64a6                	ld	s1,72(sp)
    800034f8:	6906                	ld	s2,64(sp)
    800034fa:	79e2                	ld	s3,56(sp)
    800034fc:	7a42                	ld	s4,48(sp)
    800034fe:	7aa2                	ld	s5,40(sp)
    80003500:	7b02                	ld	s6,32(sp)
    80003502:	6be2                	ld	s7,24(sp)
    80003504:	6c42                	ld	s8,16(sp)
    80003506:	6ca2                	ld	s9,8(sp)
    80003508:	6125                	addi	sp,sp,96
    8000350a:	8082                	ret

000000008000350c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000350c:	7179                	addi	sp,sp,-48
    8000350e:	f406                	sd	ra,40(sp)
    80003510:	f022                	sd	s0,32(sp)
    80003512:	ec26                	sd	s1,24(sp)
    80003514:	e84a                	sd	s2,16(sp)
    80003516:	e44e                	sd	s3,8(sp)
    80003518:	e052                	sd	s4,0(sp)
    8000351a:	1800                	addi	s0,sp,48
    8000351c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000351e:	47ad                	li	a5,11
    80003520:	04b7fe63          	bgeu	a5,a1,8000357c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003524:	ff45849b          	addiw	s1,a1,-12
    80003528:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000352c:	0ff00793          	li	a5,255
    80003530:	0ae7e363          	bltu	a5,a4,800035d6 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003534:	08052583          	lw	a1,128(a0)
    80003538:	c5ad                	beqz	a1,800035a2 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000353a:	00092503          	lw	a0,0(s2)
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	bda080e7          	jalr	-1062(ra) # 80003118 <bread>
    80003546:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003548:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000354c:	02049593          	slli	a1,s1,0x20
    80003550:	9181                	srli	a1,a1,0x20
    80003552:	058a                	slli	a1,a1,0x2
    80003554:	00b784b3          	add	s1,a5,a1
    80003558:	0004a983          	lw	s3,0(s1)
    8000355c:	04098d63          	beqz	s3,800035b6 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003560:	8552                	mv	a0,s4
    80003562:	00000097          	auipc	ra,0x0
    80003566:	ce6080e7          	jalr	-794(ra) # 80003248 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000356a:	854e                	mv	a0,s3
    8000356c:	70a2                	ld	ra,40(sp)
    8000356e:	7402                	ld	s0,32(sp)
    80003570:	64e2                	ld	s1,24(sp)
    80003572:	6942                	ld	s2,16(sp)
    80003574:	69a2                	ld	s3,8(sp)
    80003576:	6a02                	ld	s4,0(sp)
    80003578:	6145                	addi	sp,sp,48
    8000357a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000357c:	02059493          	slli	s1,a1,0x20
    80003580:	9081                	srli	s1,s1,0x20
    80003582:	048a                	slli	s1,s1,0x2
    80003584:	94aa                	add	s1,s1,a0
    80003586:	0504a983          	lw	s3,80(s1)
    8000358a:	fe0990e3          	bnez	s3,8000356a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000358e:	4108                	lw	a0,0(a0)
    80003590:	00000097          	auipc	ra,0x0
    80003594:	e4a080e7          	jalr	-438(ra) # 800033da <balloc>
    80003598:	0005099b          	sext.w	s3,a0
    8000359c:	0534a823          	sw	s3,80(s1)
    800035a0:	b7e9                	j	8000356a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800035a2:	4108                	lw	a0,0(a0)
    800035a4:	00000097          	auipc	ra,0x0
    800035a8:	e36080e7          	jalr	-458(ra) # 800033da <balloc>
    800035ac:	0005059b          	sext.w	a1,a0
    800035b0:	08b92023          	sw	a1,128(s2)
    800035b4:	b759                	j	8000353a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800035b6:	00092503          	lw	a0,0(s2)
    800035ba:	00000097          	auipc	ra,0x0
    800035be:	e20080e7          	jalr	-480(ra) # 800033da <balloc>
    800035c2:	0005099b          	sext.w	s3,a0
    800035c6:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800035ca:	8552                	mv	a0,s4
    800035cc:	00001097          	auipc	ra,0x1
    800035d0:	ee4080e7          	jalr	-284(ra) # 800044b0 <log_write>
    800035d4:	b771                	j	80003560 <bmap+0x54>
  panic("bmap: out of range");
    800035d6:	00005517          	auipc	a0,0x5
    800035da:	f7250513          	addi	a0,a0,-142 # 80008548 <syscalls+0x118>
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	f6a080e7          	jalr	-150(ra) # 80000548 <panic>

00000000800035e6 <iget>:
{
    800035e6:	7179                	addi	sp,sp,-48
    800035e8:	f406                	sd	ra,40(sp)
    800035ea:	f022                	sd	s0,32(sp)
    800035ec:	ec26                	sd	s1,24(sp)
    800035ee:	e84a                	sd	s2,16(sp)
    800035f0:	e44e                	sd	s3,8(sp)
    800035f2:	e052                	sd	s4,0(sp)
    800035f4:	1800                	addi	s0,sp,48
    800035f6:	89aa                	mv	s3,a0
    800035f8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800035fa:	0003d517          	auipc	a0,0x3d
    800035fe:	87e50513          	addi	a0,a0,-1922 # 8003fe78 <icache>
    80003602:	ffffd097          	auipc	ra,0xffffd
    80003606:	7d8080e7          	jalr	2008(ra) # 80000dda <acquire>
  empty = 0;
    8000360a:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000360c:	0003d497          	auipc	s1,0x3d
    80003610:	88448493          	addi	s1,s1,-1916 # 8003fe90 <icache+0x18>
    80003614:	0003e697          	auipc	a3,0x3e
    80003618:	30c68693          	addi	a3,a3,780 # 80041920 <log>
    8000361c:	a039                	j	8000362a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000361e:	02090b63          	beqz	s2,80003654 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003622:	08848493          	addi	s1,s1,136
    80003626:	02d48a63          	beq	s1,a3,8000365a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000362a:	449c                	lw	a5,8(s1)
    8000362c:	fef059e3          	blez	a5,8000361e <iget+0x38>
    80003630:	4098                	lw	a4,0(s1)
    80003632:	ff3716e3          	bne	a4,s3,8000361e <iget+0x38>
    80003636:	40d8                	lw	a4,4(s1)
    80003638:	ff4713e3          	bne	a4,s4,8000361e <iget+0x38>
      ip->ref++;
    8000363c:	2785                	addiw	a5,a5,1
    8000363e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003640:	0003d517          	auipc	a0,0x3d
    80003644:	83850513          	addi	a0,a0,-1992 # 8003fe78 <icache>
    80003648:	ffffe097          	auipc	ra,0xffffe
    8000364c:	846080e7          	jalr	-1978(ra) # 80000e8e <release>
      return ip;
    80003650:	8926                	mv	s2,s1
    80003652:	a03d                	j	80003680 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003654:	f7f9                	bnez	a5,80003622 <iget+0x3c>
    80003656:	8926                	mv	s2,s1
    80003658:	b7e9                	j	80003622 <iget+0x3c>
  if(empty == 0)
    8000365a:	02090c63          	beqz	s2,80003692 <iget+0xac>
  ip->dev = dev;
    8000365e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003662:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003666:	4785                	li	a5,1
    80003668:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000366c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003670:	0003d517          	auipc	a0,0x3d
    80003674:	80850513          	addi	a0,a0,-2040 # 8003fe78 <icache>
    80003678:	ffffe097          	auipc	ra,0xffffe
    8000367c:	816080e7          	jalr	-2026(ra) # 80000e8e <release>
}
    80003680:	854a                	mv	a0,s2
    80003682:	70a2                	ld	ra,40(sp)
    80003684:	7402                	ld	s0,32(sp)
    80003686:	64e2                	ld	s1,24(sp)
    80003688:	6942                	ld	s2,16(sp)
    8000368a:	69a2                	ld	s3,8(sp)
    8000368c:	6a02                	ld	s4,0(sp)
    8000368e:	6145                	addi	sp,sp,48
    80003690:	8082                	ret
    panic("iget: no inodes");
    80003692:	00005517          	auipc	a0,0x5
    80003696:	ece50513          	addi	a0,a0,-306 # 80008560 <syscalls+0x130>
    8000369a:	ffffd097          	auipc	ra,0xffffd
    8000369e:	eae080e7          	jalr	-338(ra) # 80000548 <panic>

00000000800036a2 <fsinit>:
fsinit(int dev) {
    800036a2:	7179                	addi	sp,sp,-48
    800036a4:	f406                	sd	ra,40(sp)
    800036a6:	f022                	sd	s0,32(sp)
    800036a8:	ec26                	sd	s1,24(sp)
    800036aa:	e84a                	sd	s2,16(sp)
    800036ac:	e44e                	sd	s3,8(sp)
    800036ae:	1800                	addi	s0,sp,48
    800036b0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036b2:	4585                	li	a1,1
    800036b4:	00000097          	auipc	ra,0x0
    800036b8:	a64080e7          	jalr	-1436(ra) # 80003118 <bread>
    800036bc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036be:	0003c997          	auipc	s3,0x3c
    800036c2:	79a98993          	addi	s3,s3,1946 # 8003fe58 <sb>
    800036c6:	02000613          	li	a2,32
    800036ca:	05850593          	addi	a1,a0,88
    800036ce:	854e                	mv	a0,s3
    800036d0:	ffffe097          	auipc	ra,0xffffe
    800036d4:	866080e7          	jalr	-1946(ra) # 80000f36 <memmove>
  brelse(bp);
    800036d8:	8526                	mv	a0,s1
    800036da:	00000097          	auipc	ra,0x0
    800036de:	b6e080e7          	jalr	-1170(ra) # 80003248 <brelse>
  if(sb.magic != FSMAGIC)
    800036e2:	0009a703          	lw	a4,0(s3)
    800036e6:	102037b7          	lui	a5,0x10203
    800036ea:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036ee:	02f71263          	bne	a4,a5,80003712 <fsinit+0x70>
  initlog(dev, &sb);
    800036f2:	0003c597          	auipc	a1,0x3c
    800036f6:	76658593          	addi	a1,a1,1894 # 8003fe58 <sb>
    800036fa:	854a                	mv	a0,s2
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	b3c080e7          	jalr	-1220(ra) # 80004238 <initlog>
}
    80003704:	70a2                	ld	ra,40(sp)
    80003706:	7402                	ld	s0,32(sp)
    80003708:	64e2                	ld	s1,24(sp)
    8000370a:	6942                	ld	s2,16(sp)
    8000370c:	69a2                	ld	s3,8(sp)
    8000370e:	6145                	addi	sp,sp,48
    80003710:	8082                	ret
    panic("invalid file system");
    80003712:	00005517          	auipc	a0,0x5
    80003716:	e5e50513          	addi	a0,a0,-418 # 80008570 <syscalls+0x140>
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	e2e080e7          	jalr	-466(ra) # 80000548 <panic>

0000000080003722 <iinit>:
{
    80003722:	7179                	addi	sp,sp,-48
    80003724:	f406                	sd	ra,40(sp)
    80003726:	f022                	sd	s0,32(sp)
    80003728:	ec26                	sd	s1,24(sp)
    8000372a:	e84a                	sd	s2,16(sp)
    8000372c:	e44e                	sd	s3,8(sp)
    8000372e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003730:	00005597          	auipc	a1,0x5
    80003734:	e5858593          	addi	a1,a1,-424 # 80008588 <syscalls+0x158>
    80003738:	0003c517          	auipc	a0,0x3c
    8000373c:	74050513          	addi	a0,a0,1856 # 8003fe78 <icache>
    80003740:	ffffd097          	auipc	ra,0xffffd
    80003744:	60a080e7          	jalr	1546(ra) # 80000d4a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003748:	0003c497          	auipc	s1,0x3c
    8000374c:	75848493          	addi	s1,s1,1880 # 8003fea0 <icache+0x28>
    80003750:	0003e997          	auipc	s3,0x3e
    80003754:	1e098993          	addi	s3,s3,480 # 80041930 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003758:	00005917          	auipc	s2,0x5
    8000375c:	e3890913          	addi	s2,s2,-456 # 80008590 <syscalls+0x160>
    80003760:	85ca                	mv	a1,s2
    80003762:	8526                	mv	a0,s1
    80003764:	00001097          	auipc	ra,0x1
    80003768:	e3a080e7          	jalr	-454(ra) # 8000459e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000376c:	08848493          	addi	s1,s1,136
    80003770:	ff3498e3          	bne	s1,s3,80003760 <iinit+0x3e>
}
    80003774:	70a2                	ld	ra,40(sp)
    80003776:	7402                	ld	s0,32(sp)
    80003778:	64e2                	ld	s1,24(sp)
    8000377a:	6942                	ld	s2,16(sp)
    8000377c:	69a2                	ld	s3,8(sp)
    8000377e:	6145                	addi	sp,sp,48
    80003780:	8082                	ret

0000000080003782 <ialloc>:
{
    80003782:	715d                	addi	sp,sp,-80
    80003784:	e486                	sd	ra,72(sp)
    80003786:	e0a2                	sd	s0,64(sp)
    80003788:	fc26                	sd	s1,56(sp)
    8000378a:	f84a                	sd	s2,48(sp)
    8000378c:	f44e                	sd	s3,40(sp)
    8000378e:	f052                	sd	s4,32(sp)
    80003790:	ec56                	sd	s5,24(sp)
    80003792:	e85a                	sd	s6,16(sp)
    80003794:	e45e                	sd	s7,8(sp)
    80003796:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003798:	0003c717          	auipc	a4,0x3c
    8000379c:	6cc72703          	lw	a4,1740(a4) # 8003fe64 <sb+0xc>
    800037a0:	4785                	li	a5,1
    800037a2:	04e7fa63          	bgeu	a5,a4,800037f6 <ialloc+0x74>
    800037a6:	8aaa                	mv	s5,a0
    800037a8:	8bae                	mv	s7,a1
    800037aa:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037ac:	0003ca17          	auipc	s4,0x3c
    800037b0:	6aca0a13          	addi	s4,s4,1708 # 8003fe58 <sb>
    800037b4:	00048b1b          	sext.w	s6,s1
    800037b8:	0044d593          	srli	a1,s1,0x4
    800037bc:	018a2783          	lw	a5,24(s4)
    800037c0:	9dbd                	addw	a1,a1,a5
    800037c2:	8556                	mv	a0,s5
    800037c4:	00000097          	auipc	ra,0x0
    800037c8:	954080e7          	jalr	-1708(ra) # 80003118 <bread>
    800037cc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037ce:	05850993          	addi	s3,a0,88
    800037d2:	00f4f793          	andi	a5,s1,15
    800037d6:	079a                	slli	a5,a5,0x6
    800037d8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037da:	00099783          	lh	a5,0(s3)
    800037de:	c785                	beqz	a5,80003806 <ialloc+0x84>
    brelse(bp);
    800037e0:	00000097          	auipc	ra,0x0
    800037e4:	a68080e7          	jalr	-1432(ra) # 80003248 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037e8:	0485                	addi	s1,s1,1
    800037ea:	00ca2703          	lw	a4,12(s4)
    800037ee:	0004879b          	sext.w	a5,s1
    800037f2:	fce7e1e3          	bltu	a5,a4,800037b4 <ialloc+0x32>
  panic("ialloc: no inodes");
    800037f6:	00005517          	auipc	a0,0x5
    800037fa:	da250513          	addi	a0,a0,-606 # 80008598 <syscalls+0x168>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	d4a080e7          	jalr	-694(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    80003806:	04000613          	li	a2,64
    8000380a:	4581                	li	a1,0
    8000380c:	854e                	mv	a0,s3
    8000380e:	ffffd097          	auipc	ra,0xffffd
    80003812:	6c8080e7          	jalr	1736(ra) # 80000ed6 <memset>
      dip->type = type;
    80003816:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000381a:	854a                	mv	a0,s2
    8000381c:	00001097          	auipc	ra,0x1
    80003820:	c94080e7          	jalr	-876(ra) # 800044b0 <log_write>
      brelse(bp);
    80003824:	854a                	mv	a0,s2
    80003826:	00000097          	auipc	ra,0x0
    8000382a:	a22080e7          	jalr	-1502(ra) # 80003248 <brelse>
      return iget(dev, inum);
    8000382e:	85da                	mv	a1,s6
    80003830:	8556                	mv	a0,s5
    80003832:	00000097          	auipc	ra,0x0
    80003836:	db4080e7          	jalr	-588(ra) # 800035e6 <iget>
}
    8000383a:	60a6                	ld	ra,72(sp)
    8000383c:	6406                	ld	s0,64(sp)
    8000383e:	74e2                	ld	s1,56(sp)
    80003840:	7942                	ld	s2,48(sp)
    80003842:	79a2                	ld	s3,40(sp)
    80003844:	7a02                	ld	s4,32(sp)
    80003846:	6ae2                	ld	s5,24(sp)
    80003848:	6b42                	ld	s6,16(sp)
    8000384a:	6ba2                	ld	s7,8(sp)
    8000384c:	6161                	addi	sp,sp,80
    8000384e:	8082                	ret

0000000080003850 <iupdate>:
{
    80003850:	1101                	addi	sp,sp,-32
    80003852:	ec06                	sd	ra,24(sp)
    80003854:	e822                	sd	s0,16(sp)
    80003856:	e426                	sd	s1,8(sp)
    80003858:	e04a                	sd	s2,0(sp)
    8000385a:	1000                	addi	s0,sp,32
    8000385c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000385e:	415c                	lw	a5,4(a0)
    80003860:	0047d79b          	srliw	a5,a5,0x4
    80003864:	0003c597          	auipc	a1,0x3c
    80003868:	60c5a583          	lw	a1,1548(a1) # 8003fe70 <sb+0x18>
    8000386c:	9dbd                	addw	a1,a1,a5
    8000386e:	4108                	lw	a0,0(a0)
    80003870:	00000097          	auipc	ra,0x0
    80003874:	8a8080e7          	jalr	-1880(ra) # 80003118 <bread>
    80003878:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000387a:	05850793          	addi	a5,a0,88
    8000387e:	40c8                	lw	a0,4(s1)
    80003880:	893d                	andi	a0,a0,15
    80003882:	051a                	slli	a0,a0,0x6
    80003884:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003886:	04449703          	lh	a4,68(s1)
    8000388a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000388e:	04649703          	lh	a4,70(s1)
    80003892:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003896:	04849703          	lh	a4,72(s1)
    8000389a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000389e:	04a49703          	lh	a4,74(s1)
    800038a2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038a6:	44f8                	lw	a4,76(s1)
    800038a8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038aa:	03400613          	li	a2,52
    800038ae:	05048593          	addi	a1,s1,80
    800038b2:	0531                	addi	a0,a0,12
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	682080e7          	jalr	1666(ra) # 80000f36 <memmove>
  log_write(bp);
    800038bc:	854a                	mv	a0,s2
    800038be:	00001097          	auipc	ra,0x1
    800038c2:	bf2080e7          	jalr	-1038(ra) # 800044b0 <log_write>
  brelse(bp);
    800038c6:	854a                	mv	a0,s2
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	980080e7          	jalr	-1664(ra) # 80003248 <brelse>
}
    800038d0:	60e2                	ld	ra,24(sp)
    800038d2:	6442                	ld	s0,16(sp)
    800038d4:	64a2                	ld	s1,8(sp)
    800038d6:	6902                	ld	s2,0(sp)
    800038d8:	6105                	addi	sp,sp,32
    800038da:	8082                	ret

00000000800038dc <idup>:
{
    800038dc:	1101                	addi	sp,sp,-32
    800038de:	ec06                	sd	ra,24(sp)
    800038e0:	e822                	sd	s0,16(sp)
    800038e2:	e426                	sd	s1,8(sp)
    800038e4:	1000                	addi	s0,sp,32
    800038e6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038e8:	0003c517          	auipc	a0,0x3c
    800038ec:	59050513          	addi	a0,a0,1424 # 8003fe78 <icache>
    800038f0:	ffffd097          	auipc	ra,0xffffd
    800038f4:	4ea080e7          	jalr	1258(ra) # 80000dda <acquire>
  ip->ref++;
    800038f8:	449c                	lw	a5,8(s1)
    800038fa:	2785                	addiw	a5,a5,1
    800038fc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800038fe:	0003c517          	auipc	a0,0x3c
    80003902:	57a50513          	addi	a0,a0,1402 # 8003fe78 <icache>
    80003906:	ffffd097          	auipc	ra,0xffffd
    8000390a:	588080e7          	jalr	1416(ra) # 80000e8e <release>
}
    8000390e:	8526                	mv	a0,s1
    80003910:	60e2                	ld	ra,24(sp)
    80003912:	6442                	ld	s0,16(sp)
    80003914:	64a2                	ld	s1,8(sp)
    80003916:	6105                	addi	sp,sp,32
    80003918:	8082                	ret

000000008000391a <ilock>:
{
    8000391a:	1101                	addi	sp,sp,-32
    8000391c:	ec06                	sd	ra,24(sp)
    8000391e:	e822                	sd	s0,16(sp)
    80003920:	e426                	sd	s1,8(sp)
    80003922:	e04a                	sd	s2,0(sp)
    80003924:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003926:	c115                	beqz	a0,8000394a <ilock+0x30>
    80003928:	84aa                	mv	s1,a0
    8000392a:	451c                	lw	a5,8(a0)
    8000392c:	00f05f63          	blez	a5,8000394a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003930:	0541                	addi	a0,a0,16
    80003932:	00001097          	auipc	ra,0x1
    80003936:	ca6080e7          	jalr	-858(ra) # 800045d8 <acquiresleep>
  if(ip->valid == 0){
    8000393a:	40bc                	lw	a5,64(s1)
    8000393c:	cf99                	beqz	a5,8000395a <ilock+0x40>
}
    8000393e:	60e2                	ld	ra,24(sp)
    80003940:	6442                	ld	s0,16(sp)
    80003942:	64a2                	ld	s1,8(sp)
    80003944:	6902                	ld	s2,0(sp)
    80003946:	6105                	addi	sp,sp,32
    80003948:	8082                	ret
    panic("ilock");
    8000394a:	00005517          	auipc	a0,0x5
    8000394e:	c6650513          	addi	a0,a0,-922 # 800085b0 <syscalls+0x180>
    80003952:	ffffd097          	auipc	ra,0xffffd
    80003956:	bf6080e7          	jalr	-1034(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000395a:	40dc                	lw	a5,4(s1)
    8000395c:	0047d79b          	srliw	a5,a5,0x4
    80003960:	0003c597          	auipc	a1,0x3c
    80003964:	5105a583          	lw	a1,1296(a1) # 8003fe70 <sb+0x18>
    80003968:	9dbd                	addw	a1,a1,a5
    8000396a:	4088                	lw	a0,0(s1)
    8000396c:	fffff097          	auipc	ra,0xfffff
    80003970:	7ac080e7          	jalr	1964(ra) # 80003118 <bread>
    80003974:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003976:	05850593          	addi	a1,a0,88
    8000397a:	40dc                	lw	a5,4(s1)
    8000397c:	8bbd                	andi	a5,a5,15
    8000397e:	079a                	slli	a5,a5,0x6
    80003980:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003982:	00059783          	lh	a5,0(a1)
    80003986:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000398a:	00259783          	lh	a5,2(a1)
    8000398e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003992:	00459783          	lh	a5,4(a1)
    80003996:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000399a:	00659783          	lh	a5,6(a1)
    8000399e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039a2:	459c                	lw	a5,8(a1)
    800039a4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039a6:	03400613          	li	a2,52
    800039aa:	05b1                	addi	a1,a1,12
    800039ac:	05048513          	addi	a0,s1,80
    800039b0:	ffffd097          	auipc	ra,0xffffd
    800039b4:	586080e7          	jalr	1414(ra) # 80000f36 <memmove>
    brelse(bp);
    800039b8:	854a                	mv	a0,s2
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	88e080e7          	jalr	-1906(ra) # 80003248 <brelse>
    ip->valid = 1;
    800039c2:	4785                	li	a5,1
    800039c4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039c6:	04449783          	lh	a5,68(s1)
    800039ca:	fbb5                	bnez	a5,8000393e <ilock+0x24>
      panic("ilock: no type");
    800039cc:	00005517          	auipc	a0,0x5
    800039d0:	bec50513          	addi	a0,a0,-1044 # 800085b8 <syscalls+0x188>
    800039d4:	ffffd097          	auipc	ra,0xffffd
    800039d8:	b74080e7          	jalr	-1164(ra) # 80000548 <panic>

00000000800039dc <iunlock>:
{
    800039dc:	1101                	addi	sp,sp,-32
    800039de:	ec06                	sd	ra,24(sp)
    800039e0:	e822                	sd	s0,16(sp)
    800039e2:	e426                	sd	s1,8(sp)
    800039e4:	e04a                	sd	s2,0(sp)
    800039e6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039e8:	c905                	beqz	a0,80003a18 <iunlock+0x3c>
    800039ea:	84aa                	mv	s1,a0
    800039ec:	01050913          	addi	s2,a0,16
    800039f0:	854a                	mv	a0,s2
    800039f2:	00001097          	auipc	ra,0x1
    800039f6:	c80080e7          	jalr	-896(ra) # 80004672 <holdingsleep>
    800039fa:	cd19                	beqz	a0,80003a18 <iunlock+0x3c>
    800039fc:	449c                	lw	a5,8(s1)
    800039fe:	00f05d63          	blez	a5,80003a18 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a02:	854a                	mv	a0,s2
    80003a04:	00001097          	auipc	ra,0x1
    80003a08:	c2a080e7          	jalr	-982(ra) # 8000462e <releasesleep>
}
    80003a0c:	60e2                	ld	ra,24(sp)
    80003a0e:	6442                	ld	s0,16(sp)
    80003a10:	64a2                	ld	s1,8(sp)
    80003a12:	6902                	ld	s2,0(sp)
    80003a14:	6105                	addi	sp,sp,32
    80003a16:	8082                	ret
    panic("iunlock");
    80003a18:	00005517          	auipc	a0,0x5
    80003a1c:	bb050513          	addi	a0,a0,-1104 # 800085c8 <syscalls+0x198>
    80003a20:	ffffd097          	auipc	ra,0xffffd
    80003a24:	b28080e7          	jalr	-1240(ra) # 80000548 <panic>

0000000080003a28 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a28:	7179                	addi	sp,sp,-48
    80003a2a:	f406                	sd	ra,40(sp)
    80003a2c:	f022                	sd	s0,32(sp)
    80003a2e:	ec26                	sd	s1,24(sp)
    80003a30:	e84a                	sd	s2,16(sp)
    80003a32:	e44e                	sd	s3,8(sp)
    80003a34:	e052                	sd	s4,0(sp)
    80003a36:	1800                	addi	s0,sp,48
    80003a38:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a3a:	05050493          	addi	s1,a0,80
    80003a3e:	08050913          	addi	s2,a0,128
    80003a42:	a021                	j	80003a4a <itrunc+0x22>
    80003a44:	0491                	addi	s1,s1,4
    80003a46:	01248d63          	beq	s1,s2,80003a60 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a4a:	408c                	lw	a1,0(s1)
    80003a4c:	dde5                	beqz	a1,80003a44 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a4e:	0009a503          	lw	a0,0(s3)
    80003a52:	00000097          	auipc	ra,0x0
    80003a56:	90c080e7          	jalr	-1780(ra) # 8000335e <bfree>
      ip->addrs[i] = 0;
    80003a5a:	0004a023          	sw	zero,0(s1)
    80003a5e:	b7dd                	j	80003a44 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a60:	0809a583          	lw	a1,128(s3)
    80003a64:	e185                	bnez	a1,80003a84 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a66:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a6a:	854e                	mv	a0,s3
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	de4080e7          	jalr	-540(ra) # 80003850 <iupdate>
}
    80003a74:	70a2                	ld	ra,40(sp)
    80003a76:	7402                	ld	s0,32(sp)
    80003a78:	64e2                	ld	s1,24(sp)
    80003a7a:	6942                	ld	s2,16(sp)
    80003a7c:	69a2                	ld	s3,8(sp)
    80003a7e:	6a02                	ld	s4,0(sp)
    80003a80:	6145                	addi	sp,sp,48
    80003a82:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a84:	0009a503          	lw	a0,0(s3)
    80003a88:	fffff097          	auipc	ra,0xfffff
    80003a8c:	690080e7          	jalr	1680(ra) # 80003118 <bread>
    80003a90:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a92:	05850493          	addi	s1,a0,88
    80003a96:	45850913          	addi	s2,a0,1112
    80003a9a:	a811                	j	80003aae <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a9c:	0009a503          	lw	a0,0(s3)
    80003aa0:	00000097          	auipc	ra,0x0
    80003aa4:	8be080e7          	jalr	-1858(ra) # 8000335e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003aa8:	0491                	addi	s1,s1,4
    80003aaa:	01248563          	beq	s1,s2,80003ab4 <itrunc+0x8c>
      if(a[j])
    80003aae:	408c                	lw	a1,0(s1)
    80003ab0:	dde5                	beqz	a1,80003aa8 <itrunc+0x80>
    80003ab2:	b7ed                	j	80003a9c <itrunc+0x74>
    brelse(bp);
    80003ab4:	8552                	mv	a0,s4
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	792080e7          	jalr	1938(ra) # 80003248 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003abe:	0809a583          	lw	a1,128(s3)
    80003ac2:	0009a503          	lw	a0,0(s3)
    80003ac6:	00000097          	auipc	ra,0x0
    80003aca:	898080e7          	jalr	-1896(ra) # 8000335e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ace:	0809a023          	sw	zero,128(s3)
    80003ad2:	bf51                	j	80003a66 <itrunc+0x3e>

0000000080003ad4 <iput>:
{
    80003ad4:	1101                	addi	sp,sp,-32
    80003ad6:	ec06                	sd	ra,24(sp)
    80003ad8:	e822                	sd	s0,16(sp)
    80003ada:	e426                	sd	s1,8(sp)
    80003adc:	e04a                	sd	s2,0(sp)
    80003ade:	1000                	addi	s0,sp,32
    80003ae0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003ae2:	0003c517          	auipc	a0,0x3c
    80003ae6:	39650513          	addi	a0,a0,918 # 8003fe78 <icache>
    80003aea:	ffffd097          	auipc	ra,0xffffd
    80003aee:	2f0080e7          	jalr	752(ra) # 80000dda <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003af2:	4498                	lw	a4,8(s1)
    80003af4:	4785                	li	a5,1
    80003af6:	02f70363          	beq	a4,a5,80003b1c <iput+0x48>
  ip->ref--;
    80003afa:	449c                	lw	a5,8(s1)
    80003afc:	37fd                	addiw	a5,a5,-1
    80003afe:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b00:	0003c517          	auipc	a0,0x3c
    80003b04:	37850513          	addi	a0,a0,888 # 8003fe78 <icache>
    80003b08:	ffffd097          	auipc	ra,0xffffd
    80003b0c:	386080e7          	jalr	902(ra) # 80000e8e <release>
}
    80003b10:	60e2                	ld	ra,24(sp)
    80003b12:	6442                	ld	s0,16(sp)
    80003b14:	64a2                	ld	s1,8(sp)
    80003b16:	6902                	ld	s2,0(sp)
    80003b18:	6105                	addi	sp,sp,32
    80003b1a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b1c:	40bc                	lw	a5,64(s1)
    80003b1e:	dff1                	beqz	a5,80003afa <iput+0x26>
    80003b20:	04a49783          	lh	a5,74(s1)
    80003b24:	fbf9                	bnez	a5,80003afa <iput+0x26>
    acquiresleep(&ip->lock);
    80003b26:	01048913          	addi	s2,s1,16
    80003b2a:	854a                	mv	a0,s2
    80003b2c:	00001097          	auipc	ra,0x1
    80003b30:	aac080e7          	jalr	-1364(ra) # 800045d8 <acquiresleep>
    release(&icache.lock);
    80003b34:	0003c517          	auipc	a0,0x3c
    80003b38:	34450513          	addi	a0,a0,836 # 8003fe78 <icache>
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	352080e7          	jalr	850(ra) # 80000e8e <release>
    itrunc(ip);
    80003b44:	8526                	mv	a0,s1
    80003b46:	00000097          	auipc	ra,0x0
    80003b4a:	ee2080e7          	jalr	-286(ra) # 80003a28 <itrunc>
    ip->type = 0;
    80003b4e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b52:	8526                	mv	a0,s1
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	cfc080e7          	jalr	-772(ra) # 80003850 <iupdate>
    ip->valid = 0;
    80003b5c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b60:	854a                	mv	a0,s2
    80003b62:	00001097          	auipc	ra,0x1
    80003b66:	acc080e7          	jalr	-1332(ra) # 8000462e <releasesleep>
    acquire(&icache.lock);
    80003b6a:	0003c517          	auipc	a0,0x3c
    80003b6e:	30e50513          	addi	a0,a0,782 # 8003fe78 <icache>
    80003b72:	ffffd097          	auipc	ra,0xffffd
    80003b76:	268080e7          	jalr	616(ra) # 80000dda <acquire>
    80003b7a:	b741                	j	80003afa <iput+0x26>

0000000080003b7c <iunlockput>:
{
    80003b7c:	1101                	addi	sp,sp,-32
    80003b7e:	ec06                	sd	ra,24(sp)
    80003b80:	e822                	sd	s0,16(sp)
    80003b82:	e426                	sd	s1,8(sp)
    80003b84:	1000                	addi	s0,sp,32
    80003b86:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	e54080e7          	jalr	-428(ra) # 800039dc <iunlock>
  iput(ip);
    80003b90:	8526                	mv	a0,s1
    80003b92:	00000097          	auipc	ra,0x0
    80003b96:	f42080e7          	jalr	-190(ra) # 80003ad4 <iput>
}
    80003b9a:	60e2                	ld	ra,24(sp)
    80003b9c:	6442                	ld	s0,16(sp)
    80003b9e:	64a2                	ld	s1,8(sp)
    80003ba0:	6105                	addi	sp,sp,32
    80003ba2:	8082                	ret

0000000080003ba4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ba4:	1141                	addi	sp,sp,-16
    80003ba6:	e422                	sd	s0,8(sp)
    80003ba8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003baa:	411c                	lw	a5,0(a0)
    80003bac:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bae:	415c                	lw	a5,4(a0)
    80003bb0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bb2:	04451783          	lh	a5,68(a0)
    80003bb6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bba:	04a51783          	lh	a5,74(a0)
    80003bbe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bc2:	04c56783          	lwu	a5,76(a0)
    80003bc6:	e99c                	sd	a5,16(a1)
}
    80003bc8:	6422                	ld	s0,8(sp)
    80003bca:	0141                	addi	sp,sp,16
    80003bcc:	8082                	ret

0000000080003bce <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bce:	457c                	lw	a5,76(a0)
    80003bd0:	0ed7e963          	bltu	a5,a3,80003cc2 <readi+0xf4>
{
    80003bd4:	7159                	addi	sp,sp,-112
    80003bd6:	f486                	sd	ra,104(sp)
    80003bd8:	f0a2                	sd	s0,96(sp)
    80003bda:	eca6                	sd	s1,88(sp)
    80003bdc:	e8ca                	sd	s2,80(sp)
    80003bde:	e4ce                	sd	s3,72(sp)
    80003be0:	e0d2                	sd	s4,64(sp)
    80003be2:	fc56                	sd	s5,56(sp)
    80003be4:	f85a                	sd	s6,48(sp)
    80003be6:	f45e                	sd	s7,40(sp)
    80003be8:	f062                	sd	s8,32(sp)
    80003bea:	ec66                	sd	s9,24(sp)
    80003bec:	e86a                	sd	s10,16(sp)
    80003bee:	e46e                	sd	s11,8(sp)
    80003bf0:	1880                	addi	s0,sp,112
    80003bf2:	8baa                	mv	s7,a0
    80003bf4:	8c2e                	mv	s8,a1
    80003bf6:	8ab2                	mv	s5,a2
    80003bf8:	84b6                	mv	s1,a3
    80003bfa:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bfc:	9f35                	addw	a4,a4,a3
    return 0;
    80003bfe:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c00:	0ad76063          	bltu	a4,a3,80003ca0 <readi+0xd2>
  if(off + n > ip->size)
    80003c04:	00e7f463          	bgeu	a5,a4,80003c0c <readi+0x3e>
    n = ip->size - off;
    80003c08:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c0c:	0a0b0963          	beqz	s6,80003cbe <readi+0xf0>
    80003c10:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c12:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c16:	5cfd                	li	s9,-1
    80003c18:	a82d                	j	80003c52 <readi+0x84>
    80003c1a:	020a1d93          	slli	s11,s4,0x20
    80003c1e:	020ddd93          	srli	s11,s11,0x20
    80003c22:	05890613          	addi	a2,s2,88
    80003c26:	86ee                	mv	a3,s11
    80003c28:	963a                	add	a2,a2,a4
    80003c2a:	85d6                	mv	a1,s5
    80003c2c:	8562                	mv	a0,s8
    80003c2e:	fffff097          	auipc	ra,0xfffff
    80003c32:	b0a080e7          	jalr	-1270(ra) # 80002738 <either_copyout>
    80003c36:	05950d63          	beq	a0,s9,80003c90 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c3a:	854a                	mv	a0,s2
    80003c3c:	fffff097          	auipc	ra,0xfffff
    80003c40:	60c080e7          	jalr	1548(ra) # 80003248 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c44:	013a09bb          	addw	s3,s4,s3
    80003c48:	009a04bb          	addw	s1,s4,s1
    80003c4c:	9aee                	add	s5,s5,s11
    80003c4e:	0569f763          	bgeu	s3,s6,80003c9c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c52:	000ba903          	lw	s2,0(s7)
    80003c56:	00a4d59b          	srliw	a1,s1,0xa
    80003c5a:	855e                	mv	a0,s7
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	8b0080e7          	jalr	-1872(ra) # 8000350c <bmap>
    80003c64:	0005059b          	sext.w	a1,a0
    80003c68:	854a                	mv	a0,s2
    80003c6a:	fffff097          	auipc	ra,0xfffff
    80003c6e:	4ae080e7          	jalr	1198(ra) # 80003118 <bread>
    80003c72:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c74:	3ff4f713          	andi	a4,s1,1023
    80003c78:	40ed07bb          	subw	a5,s10,a4
    80003c7c:	413b06bb          	subw	a3,s6,s3
    80003c80:	8a3e                	mv	s4,a5
    80003c82:	2781                	sext.w	a5,a5
    80003c84:	0006861b          	sext.w	a2,a3
    80003c88:	f8f679e3          	bgeu	a2,a5,80003c1a <readi+0x4c>
    80003c8c:	8a36                	mv	s4,a3
    80003c8e:	b771                	j	80003c1a <readi+0x4c>
      brelse(bp);
    80003c90:	854a                	mv	a0,s2
    80003c92:	fffff097          	auipc	ra,0xfffff
    80003c96:	5b6080e7          	jalr	1462(ra) # 80003248 <brelse>
      tot = -1;
    80003c9a:	59fd                	li	s3,-1
  }
  return tot;
    80003c9c:	0009851b          	sext.w	a0,s3
}
    80003ca0:	70a6                	ld	ra,104(sp)
    80003ca2:	7406                	ld	s0,96(sp)
    80003ca4:	64e6                	ld	s1,88(sp)
    80003ca6:	6946                	ld	s2,80(sp)
    80003ca8:	69a6                	ld	s3,72(sp)
    80003caa:	6a06                	ld	s4,64(sp)
    80003cac:	7ae2                	ld	s5,56(sp)
    80003cae:	7b42                	ld	s6,48(sp)
    80003cb0:	7ba2                	ld	s7,40(sp)
    80003cb2:	7c02                	ld	s8,32(sp)
    80003cb4:	6ce2                	ld	s9,24(sp)
    80003cb6:	6d42                	ld	s10,16(sp)
    80003cb8:	6da2                	ld	s11,8(sp)
    80003cba:	6165                	addi	sp,sp,112
    80003cbc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cbe:	89da                	mv	s3,s6
    80003cc0:	bff1                	j	80003c9c <readi+0xce>
    return 0;
    80003cc2:	4501                	li	a0,0
}
    80003cc4:	8082                	ret

0000000080003cc6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cc6:	457c                	lw	a5,76(a0)
    80003cc8:	10d7e763          	bltu	a5,a3,80003dd6 <writei+0x110>
{
    80003ccc:	7159                	addi	sp,sp,-112
    80003cce:	f486                	sd	ra,104(sp)
    80003cd0:	f0a2                	sd	s0,96(sp)
    80003cd2:	eca6                	sd	s1,88(sp)
    80003cd4:	e8ca                	sd	s2,80(sp)
    80003cd6:	e4ce                	sd	s3,72(sp)
    80003cd8:	e0d2                	sd	s4,64(sp)
    80003cda:	fc56                	sd	s5,56(sp)
    80003cdc:	f85a                	sd	s6,48(sp)
    80003cde:	f45e                	sd	s7,40(sp)
    80003ce0:	f062                	sd	s8,32(sp)
    80003ce2:	ec66                	sd	s9,24(sp)
    80003ce4:	e86a                	sd	s10,16(sp)
    80003ce6:	e46e                	sd	s11,8(sp)
    80003ce8:	1880                	addi	s0,sp,112
    80003cea:	8baa                	mv	s7,a0
    80003cec:	8c2e                	mv	s8,a1
    80003cee:	8ab2                	mv	s5,a2
    80003cf0:	8936                	mv	s2,a3
    80003cf2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cf4:	00e687bb          	addw	a5,a3,a4
    80003cf8:	0ed7e163          	bltu	a5,a3,80003dda <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cfc:	00043737          	lui	a4,0x43
    80003d00:	0cf76f63          	bltu	a4,a5,80003dde <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d04:	0a0b0863          	beqz	s6,80003db4 <writei+0xee>
    80003d08:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d0a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d0e:	5cfd                	li	s9,-1
    80003d10:	a091                	j	80003d54 <writei+0x8e>
    80003d12:	02099d93          	slli	s11,s3,0x20
    80003d16:	020ddd93          	srli	s11,s11,0x20
    80003d1a:	05848513          	addi	a0,s1,88
    80003d1e:	86ee                	mv	a3,s11
    80003d20:	8656                	mv	a2,s5
    80003d22:	85e2                	mv	a1,s8
    80003d24:	953a                	add	a0,a0,a4
    80003d26:	fffff097          	auipc	ra,0xfffff
    80003d2a:	a68080e7          	jalr	-1432(ra) # 8000278e <either_copyin>
    80003d2e:	07950263          	beq	a0,s9,80003d92 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003d32:	8526                	mv	a0,s1
    80003d34:	00000097          	auipc	ra,0x0
    80003d38:	77c080e7          	jalr	1916(ra) # 800044b0 <log_write>
    brelse(bp);
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	50a080e7          	jalr	1290(ra) # 80003248 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d46:	01498a3b          	addw	s4,s3,s4
    80003d4a:	0129893b          	addw	s2,s3,s2
    80003d4e:	9aee                	add	s5,s5,s11
    80003d50:	056a7763          	bgeu	s4,s6,80003d9e <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d54:	000ba483          	lw	s1,0(s7)
    80003d58:	00a9559b          	srliw	a1,s2,0xa
    80003d5c:	855e                	mv	a0,s7
    80003d5e:	fffff097          	auipc	ra,0xfffff
    80003d62:	7ae080e7          	jalr	1966(ra) # 8000350c <bmap>
    80003d66:	0005059b          	sext.w	a1,a0
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	fffff097          	auipc	ra,0xfffff
    80003d70:	3ac080e7          	jalr	940(ra) # 80003118 <bread>
    80003d74:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d76:	3ff97713          	andi	a4,s2,1023
    80003d7a:	40ed07bb          	subw	a5,s10,a4
    80003d7e:	414b06bb          	subw	a3,s6,s4
    80003d82:	89be                	mv	s3,a5
    80003d84:	2781                	sext.w	a5,a5
    80003d86:	0006861b          	sext.w	a2,a3
    80003d8a:	f8f674e3          	bgeu	a2,a5,80003d12 <writei+0x4c>
    80003d8e:	89b6                	mv	s3,a3
    80003d90:	b749                	j	80003d12 <writei+0x4c>
      brelse(bp);
    80003d92:	8526                	mv	a0,s1
    80003d94:	fffff097          	auipc	ra,0xfffff
    80003d98:	4b4080e7          	jalr	1204(ra) # 80003248 <brelse>
      n = -1;
    80003d9c:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003d9e:	04cba783          	lw	a5,76(s7)
    80003da2:	0127f463          	bgeu	a5,s2,80003daa <writei+0xe4>
      ip->size = off;
    80003da6:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003daa:	855e                	mv	a0,s7
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	aa4080e7          	jalr	-1372(ra) # 80003850 <iupdate>
  }

  return n;
    80003db4:	000b051b          	sext.w	a0,s6
}
    80003db8:	70a6                	ld	ra,104(sp)
    80003dba:	7406                	ld	s0,96(sp)
    80003dbc:	64e6                	ld	s1,88(sp)
    80003dbe:	6946                	ld	s2,80(sp)
    80003dc0:	69a6                	ld	s3,72(sp)
    80003dc2:	6a06                	ld	s4,64(sp)
    80003dc4:	7ae2                	ld	s5,56(sp)
    80003dc6:	7b42                	ld	s6,48(sp)
    80003dc8:	7ba2                	ld	s7,40(sp)
    80003dca:	7c02                	ld	s8,32(sp)
    80003dcc:	6ce2                	ld	s9,24(sp)
    80003dce:	6d42                	ld	s10,16(sp)
    80003dd0:	6da2                	ld	s11,8(sp)
    80003dd2:	6165                	addi	sp,sp,112
    80003dd4:	8082                	ret
    return -1;
    80003dd6:	557d                	li	a0,-1
}
    80003dd8:	8082                	ret
    return -1;
    80003dda:	557d                	li	a0,-1
    80003ddc:	bff1                	j	80003db8 <writei+0xf2>
    return -1;
    80003dde:	557d                	li	a0,-1
    80003de0:	bfe1                	j	80003db8 <writei+0xf2>

0000000080003de2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003de2:	1141                	addi	sp,sp,-16
    80003de4:	e406                	sd	ra,8(sp)
    80003de6:	e022                	sd	s0,0(sp)
    80003de8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dea:	4639                	li	a2,14
    80003dec:	ffffd097          	auipc	ra,0xffffd
    80003df0:	1c6080e7          	jalr	454(ra) # 80000fb2 <strncmp>
}
    80003df4:	60a2                	ld	ra,8(sp)
    80003df6:	6402                	ld	s0,0(sp)
    80003df8:	0141                	addi	sp,sp,16
    80003dfa:	8082                	ret

0000000080003dfc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dfc:	7139                	addi	sp,sp,-64
    80003dfe:	fc06                	sd	ra,56(sp)
    80003e00:	f822                	sd	s0,48(sp)
    80003e02:	f426                	sd	s1,40(sp)
    80003e04:	f04a                	sd	s2,32(sp)
    80003e06:	ec4e                	sd	s3,24(sp)
    80003e08:	e852                	sd	s4,16(sp)
    80003e0a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e0c:	04451703          	lh	a4,68(a0)
    80003e10:	4785                	li	a5,1
    80003e12:	00f71a63          	bne	a4,a5,80003e26 <dirlookup+0x2a>
    80003e16:	892a                	mv	s2,a0
    80003e18:	89ae                	mv	s3,a1
    80003e1a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e1c:	457c                	lw	a5,76(a0)
    80003e1e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e20:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e22:	e79d                	bnez	a5,80003e50 <dirlookup+0x54>
    80003e24:	a8a5                	j	80003e9c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e26:	00004517          	auipc	a0,0x4
    80003e2a:	7aa50513          	addi	a0,a0,1962 # 800085d0 <syscalls+0x1a0>
    80003e2e:	ffffc097          	auipc	ra,0xffffc
    80003e32:	71a080e7          	jalr	1818(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003e36:	00004517          	auipc	a0,0x4
    80003e3a:	7b250513          	addi	a0,a0,1970 # 800085e8 <syscalls+0x1b8>
    80003e3e:	ffffc097          	auipc	ra,0xffffc
    80003e42:	70a080e7          	jalr	1802(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e46:	24c1                	addiw	s1,s1,16
    80003e48:	04c92783          	lw	a5,76(s2)
    80003e4c:	04f4f763          	bgeu	s1,a5,80003e9a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e50:	4741                	li	a4,16
    80003e52:	86a6                	mv	a3,s1
    80003e54:	fc040613          	addi	a2,s0,-64
    80003e58:	4581                	li	a1,0
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	d72080e7          	jalr	-654(ra) # 80003bce <readi>
    80003e64:	47c1                	li	a5,16
    80003e66:	fcf518e3          	bne	a0,a5,80003e36 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e6a:	fc045783          	lhu	a5,-64(s0)
    80003e6e:	dfe1                	beqz	a5,80003e46 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e70:	fc240593          	addi	a1,s0,-62
    80003e74:	854e                	mv	a0,s3
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	f6c080e7          	jalr	-148(ra) # 80003de2 <namecmp>
    80003e7e:	f561                	bnez	a0,80003e46 <dirlookup+0x4a>
      if(poff)
    80003e80:	000a0463          	beqz	s4,80003e88 <dirlookup+0x8c>
        *poff = off;
    80003e84:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e88:	fc045583          	lhu	a1,-64(s0)
    80003e8c:	00092503          	lw	a0,0(s2)
    80003e90:	fffff097          	auipc	ra,0xfffff
    80003e94:	756080e7          	jalr	1878(ra) # 800035e6 <iget>
    80003e98:	a011                	j	80003e9c <dirlookup+0xa0>
  return 0;
    80003e9a:	4501                	li	a0,0
}
    80003e9c:	70e2                	ld	ra,56(sp)
    80003e9e:	7442                	ld	s0,48(sp)
    80003ea0:	74a2                	ld	s1,40(sp)
    80003ea2:	7902                	ld	s2,32(sp)
    80003ea4:	69e2                	ld	s3,24(sp)
    80003ea6:	6a42                	ld	s4,16(sp)
    80003ea8:	6121                	addi	sp,sp,64
    80003eaa:	8082                	ret

0000000080003eac <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eac:	711d                	addi	sp,sp,-96
    80003eae:	ec86                	sd	ra,88(sp)
    80003eb0:	e8a2                	sd	s0,80(sp)
    80003eb2:	e4a6                	sd	s1,72(sp)
    80003eb4:	e0ca                	sd	s2,64(sp)
    80003eb6:	fc4e                	sd	s3,56(sp)
    80003eb8:	f852                	sd	s4,48(sp)
    80003eba:	f456                	sd	s5,40(sp)
    80003ebc:	f05a                	sd	s6,32(sp)
    80003ebe:	ec5e                	sd	s7,24(sp)
    80003ec0:	e862                	sd	s8,16(sp)
    80003ec2:	e466                	sd	s9,8(sp)
    80003ec4:	1080                	addi	s0,sp,96
    80003ec6:	84aa                	mv	s1,a0
    80003ec8:	8b2e                	mv	s6,a1
    80003eca:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ecc:	00054703          	lbu	a4,0(a0)
    80003ed0:	02f00793          	li	a5,47
    80003ed4:	02f70363          	beq	a4,a5,80003efa <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ed8:	ffffe097          	auipc	ra,0xffffe
    80003edc:	dee080e7          	jalr	-530(ra) # 80001cc6 <myproc>
    80003ee0:	15053503          	ld	a0,336(a0)
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	9f8080e7          	jalr	-1544(ra) # 800038dc <idup>
    80003eec:	89aa                	mv	s3,a0
  while(*path == '/')
    80003eee:	02f00913          	li	s2,47
  len = path - s;
    80003ef2:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003ef4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ef6:	4c05                	li	s8,1
    80003ef8:	a865                	j	80003fb0 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003efa:	4585                	li	a1,1
    80003efc:	4505                	li	a0,1
    80003efe:	fffff097          	auipc	ra,0xfffff
    80003f02:	6e8080e7          	jalr	1768(ra) # 800035e6 <iget>
    80003f06:	89aa                	mv	s3,a0
    80003f08:	b7dd                	j	80003eee <namex+0x42>
      iunlockput(ip);
    80003f0a:	854e                	mv	a0,s3
    80003f0c:	00000097          	auipc	ra,0x0
    80003f10:	c70080e7          	jalr	-912(ra) # 80003b7c <iunlockput>
      return 0;
    80003f14:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f16:	854e                	mv	a0,s3
    80003f18:	60e6                	ld	ra,88(sp)
    80003f1a:	6446                	ld	s0,80(sp)
    80003f1c:	64a6                	ld	s1,72(sp)
    80003f1e:	6906                	ld	s2,64(sp)
    80003f20:	79e2                	ld	s3,56(sp)
    80003f22:	7a42                	ld	s4,48(sp)
    80003f24:	7aa2                	ld	s5,40(sp)
    80003f26:	7b02                	ld	s6,32(sp)
    80003f28:	6be2                	ld	s7,24(sp)
    80003f2a:	6c42                	ld	s8,16(sp)
    80003f2c:	6ca2                	ld	s9,8(sp)
    80003f2e:	6125                	addi	sp,sp,96
    80003f30:	8082                	ret
      iunlock(ip);
    80003f32:	854e                	mv	a0,s3
    80003f34:	00000097          	auipc	ra,0x0
    80003f38:	aa8080e7          	jalr	-1368(ra) # 800039dc <iunlock>
      return ip;
    80003f3c:	bfe9                	j	80003f16 <namex+0x6a>
      iunlockput(ip);
    80003f3e:	854e                	mv	a0,s3
    80003f40:	00000097          	auipc	ra,0x0
    80003f44:	c3c080e7          	jalr	-964(ra) # 80003b7c <iunlockput>
      return 0;
    80003f48:	89d2                	mv	s3,s4
    80003f4a:	b7f1                	j	80003f16 <namex+0x6a>
  len = path - s;
    80003f4c:	40b48633          	sub	a2,s1,a1
    80003f50:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f54:	094cd463          	bge	s9,s4,80003fdc <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f58:	4639                	li	a2,14
    80003f5a:	8556                	mv	a0,s5
    80003f5c:	ffffd097          	auipc	ra,0xffffd
    80003f60:	fda080e7          	jalr	-38(ra) # 80000f36 <memmove>
  while(*path == '/')
    80003f64:	0004c783          	lbu	a5,0(s1)
    80003f68:	01279763          	bne	a5,s2,80003f76 <namex+0xca>
    path++;
    80003f6c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f6e:	0004c783          	lbu	a5,0(s1)
    80003f72:	ff278de3          	beq	a5,s2,80003f6c <namex+0xc0>
    ilock(ip);
    80003f76:	854e                	mv	a0,s3
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	9a2080e7          	jalr	-1630(ra) # 8000391a <ilock>
    if(ip->type != T_DIR){
    80003f80:	04499783          	lh	a5,68(s3)
    80003f84:	f98793e3          	bne	a5,s8,80003f0a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f88:	000b0563          	beqz	s6,80003f92 <namex+0xe6>
    80003f8c:	0004c783          	lbu	a5,0(s1)
    80003f90:	d3cd                	beqz	a5,80003f32 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f92:	865e                	mv	a2,s7
    80003f94:	85d6                	mv	a1,s5
    80003f96:	854e                	mv	a0,s3
    80003f98:	00000097          	auipc	ra,0x0
    80003f9c:	e64080e7          	jalr	-412(ra) # 80003dfc <dirlookup>
    80003fa0:	8a2a                	mv	s4,a0
    80003fa2:	dd51                	beqz	a0,80003f3e <namex+0x92>
    iunlockput(ip);
    80003fa4:	854e                	mv	a0,s3
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	bd6080e7          	jalr	-1066(ra) # 80003b7c <iunlockput>
    ip = next;
    80003fae:	89d2                	mv	s3,s4
  while(*path == '/')
    80003fb0:	0004c783          	lbu	a5,0(s1)
    80003fb4:	05279763          	bne	a5,s2,80004002 <namex+0x156>
    path++;
    80003fb8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fba:	0004c783          	lbu	a5,0(s1)
    80003fbe:	ff278de3          	beq	a5,s2,80003fb8 <namex+0x10c>
  if(*path == 0)
    80003fc2:	c79d                	beqz	a5,80003ff0 <namex+0x144>
    path++;
    80003fc4:	85a6                	mv	a1,s1
  len = path - s;
    80003fc6:	8a5e                	mv	s4,s7
    80003fc8:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fca:	01278963          	beq	a5,s2,80003fdc <namex+0x130>
    80003fce:	dfbd                	beqz	a5,80003f4c <namex+0xa0>
    path++;
    80003fd0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fd2:	0004c783          	lbu	a5,0(s1)
    80003fd6:	ff279ce3          	bne	a5,s2,80003fce <namex+0x122>
    80003fda:	bf8d                	j	80003f4c <namex+0xa0>
    memmove(name, s, len);
    80003fdc:	2601                	sext.w	a2,a2
    80003fde:	8556                	mv	a0,s5
    80003fe0:	ffffd097          	auipc	ra,0xffffd
    80003fe4:	f56080e7          	jalr	-170(ra) # 80000f36 <memmove>
    name[len] = 0;
    80003fe8:	9a56                	add	s4,s4,s5
    80003fea:	000a0023          	sb	zero,0(s4)
    80003fee:	bf9d                	j	80003f64 <namex+0xb8>
  if(nameiparent){
    80003ff0:	f20b03e3          	beqz	s6,80003f16 <namex+0x6a>
    iput(ip);
    80003ff4:	854e                	mv	a0,s3
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	ade080e7          	jalr	-1314(ra) # 80003ad4 <iput>
    return 0;
    80003ffe:	4981                	li	s3,0
    80004000:	bf19                	j	80003f16 <namex+0x6a>
  if(*path == 0)
    80004002:	d7fd                	beqz	a5,80003ff0 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004004:	0004c783          	lbu	a5,0(s1)
    80004008:	85a6                	mv	a1,s1
    8000400a:	b7d1                	j	80003fce <namex+0x122>

000000008000400c <dirlink>:
{
    8000400c:	7139                	addi	sp,sp,-64
    8000400e:	fc06                	sd	ra,56(sp)
    80004010:	f822                	sd	s0,48(sp)
    80004012:	f426                	sd	s1,40(sp)
    80004014:	f04a                	sd	s2,32(sp)
    80004016:	ec4e                	sd	s3,24(sp)
    80004018:	e852                	sd	s4,16(sp)
    8000401a:	0080                	addi	s0,sp,64
    8000401c:	892a                	mv	s2,a0
    8000401e:	8a2e                	mv	s4,a1
    80004020:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004022:	4601                	li	a2,0
    80004024:	00000097          	auipc	ra,0x0
    80004028:	dd8080e7          	jalr	-552(ra) # 80003dfc <dirlookup>
    8000402c:	e93d                	bnez	a0,800040a2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000402e:	04c92483          	lw	s1,76(s2)
    80004032:	c49d                	beqz	s1,80004060 <dirlink+0x54>
    80004034:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004036:	4741                	li	a4,16
    80004038:	86a6                	mv	a3,s1
    8000403a:	fc040613          	addi	a2,s0,-64
    8000403e:	4581                	li	a1,0
    80004040:	854a                	mv	a0,s2
    80004042:	00000097          	auipc	ra,0x0
    80004046:	b8c080e7          	jalr	-1140(ra) # 80003bce <readi>
    8000404a:	47c1                	li	a5,16
    8000404c:	06f51163          	bne	a0,a5,800040ae <dirlink+0xa2>
    if(de.inum == 0)
    80004050:	fc045783          	lhu	a5,-64(s0)
    80004054:	c791                	beqz	a5,80004060 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004056:	24c1                	addiw	s1,s1,16
    80004058:	04c92783          	lw	a5,76(s2)
    8000405c:	fcf4ede3          	bltu	s1,a5,80004036 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004060:	4639                	li	a2,14
    80004062:	85d2                	mv	a1,s4
    80004064:	fc240513          	addi	a0,s0,-62
    80004068:	ffffd097          	auipc	ra,0xffffd
    8000406c:	f86080e7          	jalr	-122(ra) # 80000fee <strncpy>
  de.inum = inum;
    80004070:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004074:	4741                	li	a4,16
    80004076:	86a6                	mv	a3,s1
    80004078:	fc040613          	addi	a2,s0,-64
    8000407c:	4581                	li	a1,0
    8000407e:	854a                	mv	a0,s2
    80004080:	00000097          	auipc	ra,0x0
    80004084:	c46080e7          	jalr	-954(ra) # 80003cc6 <writei>
    80004088:	872a                	mv	a4,a0
    8000408a:	47c1                	li	a5,16
  return 0;
    8000408c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000408e:	02f71863          	bne	a4,a5,800040be <dirlink+0xb2>
}
    80004092:	70e2                	ld	ra,56(sp)
    80004094:	7442                	ld	s0,48(sp)
    80004096:	74a2                	ld	s1,40(sp)
    80004098:	7902                	ld	s2,32(sp)
    8000409a:	69e2                	ld	s3,24(sp)
    8000409c:	6a42                	ld	s4,16(sp)
    8000409e:	6121                	addi	sp,sp,64
    800040a0:	8082                	ret
    iput(ip);
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	a32080e7          	jalr	-1486(ra) # 80003ad4 <iput>
    return -1;
    800040aa:	557d                	li	a0,-1
    800040ac:	b7dd                	j	80004092 <dirlink+0x86>
      panic("dirlink read");
    800040ae:	00004517          	auipc	a0,0x4
    800040b2:	54a50513          	addi	a0,a0,1354 # 800085f8 <syscalls+0x1c8>
    800040b6:	ffffc097          	auipc	ra,0xffffc
    800040ba:	492080e7          	jalr	1170(ra) # 80000548 <panic>
    panic("dirlink");
    800040be:	00004517          	auipc	a0,0x4
    800040c2:	65a50513          	addi	a0,a0,1626 # 80008718 <syscalls+0x2e8>
    800040c6:	ffffc097          	auipc	ra,0xffffc
    800040ca:	482080e7          	jalr	1154(ra) # 80000548 <panic>

00000000800040ce <namei>:

struct inode*
namei(char *path)
{
    800040ce:	1101                	addi	sp,sp,-32
    800040d0:	ec06                	sd	ra,24(sp)
    800040d2:	e822                	sd	s0,16(sp)
    800040d4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040d6:	fe040613          	addi	a2,s0,-32
    800040da:	4581                	li	a1,0
    800040dc:	00000097          	auipc	ra,0x0
    800040e0:	dd0080e7          	jalr	-560(ra) # 80003eac <namex>
}
    800040e4:	60e2                	ld	ra,24(sp)
    800040e6:	6442                	ld	s0,16(sp)
    800040e8:	6105                	addi	sp,sp,32
    800040ea:	8082                	ret

00000000800040ec <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040ec:	1141                	addi	sp,sp,-16
    800040ee:	e406                	sd	ra,8(sp)
    800040f0:	e022                	sd	s0,0(sp)
    800040f2:	0800                	addi	s0,sp,16
    800040f4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040f6:	4585                	li	a1,1
    800040f8:	00000097          	auipc	ra,0x0
    800040fc:	db4080e7          	jalr	-588(ra) # 80003eac <namex>
}
    80004100:	60a2                	ld	ra,8(sp)
    80004102:	6402                	ld	s0,0(sp)
    80004104:	0141                	addi	sp,sp,16
    80004106:	8082                	ret

0000000080004108 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004108:	1101                	addi	sp,sp,-32
    8000410a:	ec06                	sd	ra,24(sp)
    8000410c:	e822                	sd	s0,16(sp)
    8000410e:	e426                	sd	s1,8(sp)
    80004110:	e04a                	sd	s2,0(sp)
    80004112:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004114:	0003e917          	auipc	s2,0x3e
    80004118:	80c90913          	addi	s2,s2,-2036 # 80041920 <log>
    8000411c:	01892583          	lw	a1,24(s2)
    80004120:	02892503          	lw	a0,40(s2)
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	ff4080e7          	jalr	-12(ra) # 80003118 <bread>
    8000412c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000412e:	02c92683          	lw	a3,44(s2)
    80004132:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004134:	02d05763          	blez	a3,80004162 <write_head+0x5a>
    80004138:	0003e797          	auipc	a5,0x3e
    8000413c:	81878793          	addi	a5,a5,-2024 # 80041950 <log+0x30>
    80004140:	05c50713          	addi	a4,a0,92
    80004144:	36fd                	addiw	a3,a3,-1
    80004146:	1682                	slli	a3,a3,0x20
    80004148:	9281                	srli	a3,a3,0x20
    8000414a:	068a                	slli	a3,a3,0x2
    8000414c:	0003e617          	auipc	a2,0x3e
    80004150:	80860613          	addi	a2,a2,-2040 # 80041954 <log+0x34>
    80004154:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004156:	4390                	lw	a2,0(a5)
    80004158:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000415a:	0791                	addi	a5,a5,4
    8000415c:	0711                	addi	a4,a4,4
    8000415e:	fed79ce3          	bne	a5,a3,80004156 <write_head+0x4e>
  }
  bwrite(buf);
    80004162:	8526                	mv	a0,s1
    80004164:	fffff097          	auipc	ra,0xfffff
    80004168:	0a6080e7          	jalr	166(ra) # 8000320a <bwrite>
  brelse(buf);
    8000416c:	8526                	mv	a0,s1
    8000416e:	fffff097          	auipc	ra,0xfffff
    80004172:	0da080e7          	jalr	218(ra) # 80003248 <brelse>
}
    80004176:	60e2                	ld	ra,24(sp)
    80004178:	6442                	ld	s0,16(sp)
    8000417a:	64a2                	ld	s1,8(sp)
    8000417c:	6902                	ld	s2,0(sp)
    8000417e:	6105                	addi	sp,sp,32
    80004180:	8082                	ret

0000000080004182 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004182:	0003d797          	auipc	a5,0x3d
    80004186:	7ca7a783          	lw	a5,1994(a5) # 8004194c <log+0x2c>
    8000418a:	0af05663          	blez	a5,80004236 <install_trans+0xb4>
{
    8000418e:	7139                	addi	sp,sp,-64
    80004190:	fc06                	sd	ra,56(sp)
    80004192:	f822                	sd	s0,48(sp)
    80004194:	f426                	sd	s1,40(sp)
    80004196:	f04a                	sd	s2,32(sp)
    80004198:	ec4e                	sd	s3,24(sp)
    8000419a:	e852                	sd	s4,16(sp)
    8000419c:	e456                	sd	s5,8(sp)
    8000419e:	0080                	addi	s0,sp,64
    800041a0:	0003da97          	auipc	s5,0x3d
    800041a4:	7b0a8a93          	addi	s5,s5,1968 # 80041950 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041aa:	0003d997          	auipc	s3,0x3d
    800041ae:	77698993          	addi	s3,s3,1910 # 80041920 <log>
    800041b2:	0189a583          	lw	a1,24(s3)
    800041b6:	014585bb          	addw	a1,a1,s4
    800041ba:	2585                	addiw	a1,a1,1
    800041bc:	0289a503          	lw	a0,40(s3)
    800041c0:	fffff097          	auipc	ra,0xfffff
    800041c4:	f58080e7          	jalr	-168(ra) # 80003118 <bread>
    800041c8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041ca:	000aa583          	lw	a1,0(s5)
    800041ce:	0289a503          	lw	a0,40(s3)
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	f46080e7          	jalr	-186(ra) # 80003118 <bread>
    800041da:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041dc:	40000613          	li	a2,1024
    800041e0:	05890593          	addi	a1,s2,88
    800041e4:	05850513          	addi	a0,a0,88
    800041e8:	ffffd097          	auipc	ra,0xffffd
    800041ec:	d4e080e7          	jalr	-690(ra) # 80000f36 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041f0:	8526                	mv	a0,s1
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	018080e7          	jalr	24(ra) # 8000320a <bwrite>
    bunpin(dbuf);
    800041fa:	8526                	mv	a0,s1
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	126080e7          	jalr	294(ra) # 80003322 <bunpin>
    brelse(lbuf);
    80004204:	854a                	mv	a0,s2
    80004206:	fffff097          	auipc	ra,0xfffff
    8000420a:	042080e7          	jalr	66(ra) # 80003248 <brelse>
    brelse(dbuf);
    8000420e:	8526                	mv	a0,s1
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	038080e7          	jalr	56(ra) # 80003248 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004218:	2a05                	addiw	s4,s4,1
    8000421a:	0a91                	addi	s5,s5,4
    8000421c:	02c9a783          	lw	a5,44(s3)
    80004220:	f8fa49e3          	blt	s4,a5,800041b2 <install_trans+0x30>
}
    80004224:	70e2                	ld	ra,56(sp)
    80004226:	7442                	ld	s0,48(sp)
    80004228:	74a2                	ld	s1,40(sp)
    8000422a:	7902                	ld	s2,32(sp)
    8000422c:	69e2                	ld	s3,24(sp)
    8000422e:	6a42                	ld	s4,16(sp)
    80004230:	6aa2                	ld	s5,8(sp)
    80004232:	6121                	addi	sp,sp,64
    80004234:	8082                	ret
    80004236:	8082                	ret

0000000080004238 <initlog>:
{
    80004238:	7179                	addi	sp,sp,-48
    8000423a:	f406                	sd	ra,40(sp)
    8000423c:	f022                	sd	s0,32(sp)
    8000423e:	ec26                	sd	s1,24(sp)
    80004240:	e84a                	sd	s2,16(sp)
    80004242:	e44e                	sd	s3,8(sp)
    80004244:	1800                	addi	s0,sp,48
    80004246:	892a                	mv	s2,a0
    80004248:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000424a:	0003d497          	auipc	s1,0x3d
    8000424e:	6d648493          	addi	s1,s1,1750 # 80041920 <log>
    80004252:	00004597          	auipc	a1,0x4
    80004256:	3b658593          	addi	a1,a1,950 # 80008608 <syscalls+0x1d8>
    8000425a:	8526                	mv	a0,s1
    8000425c:	ffffd097          	auipc	ra,0xffffd
    80004260:	aee080e7          	jalr	-1298(ra) # 80000d4a <initlock>
  log.start = sb->logstart;
    80004264:	0149a583          	lw	a1,20(s3)
    80004268:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000426a:	0109a783          	lw	a5,16(s3)
    8000426e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004270:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004274:	854a                	mv	a0,s2
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	ea2080e7          	jalr	-350(ra) # 80003118 <bread>
  log.lh.n = lh->n;
    8000427e:	4d3c                	lw	a5,88(a0)
    80004280:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004282:	02f05563          	blez	a5,800042ac <initlog+0x74>
    80004286:	05c50713          	addi	a4,a0,92
    8000428a:	0003d697          	auipc	a3,0x3d
    8000428e:	6c668693          	addi	a3,a3,1734 # 80041950 <log+0x30>
    80004292:	37fd                	addiw	a5,a5,-1
    80004294:	1782                	slli	a5,a5,0x20
    80004296:	9381                	srli	a5,a5,0x20
    80004298:	078a                	slli	a5,a5,0x2
    8000429a:	06050613          	addi	a2,a0,96
    8000429e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800042a0:	4310                	lw	a2,0(a4)
    800042a2:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800042a4:	0711                	addi	a4,a4,4
    800042a6:	0691                	addi	a3,a3,4
    800042a8:	fef71ce3          	bne	a4,a5,800042a0 <initlog+0x68>
  brelse(buf);
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	f9c080e7          	jalr	-100(ra) # 80003248 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800042b4:	00000097          	auipc	ra,0x0
    800042b8:	ece080e7          	jalr	-306(ra) # 80004182 <install_trans>
  log.lh.n = 0;
    800042bc:	0003d797          	auipc	a5,0x3d
    800042c0:	6807a823          	sw	zero,1680(a5) # 8004194c <log+0x2c>
  write_head(); // clear the log
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	e44080e7          	jalr	-444(ra) # 80004108 <write_head>
}
    800042cc:	70a2                	ld	ra,40(sp)
    800042ce:	7402                	ld	s0,32(sp)
    800042d0:	64e2                	ld	s1,24(sp)
    800042d2:	6942                	ld	s2,16(sp)
    800042d4:	69a2                	ld	s3,8(sp)
    800042d6:	6145                	addi	sp,sp,48
    800042d8:	8082                	ret

00000000800042da <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042da:	1101                	addi	sp,sp,-32
    800042dc:	ec06                	sd	ra,24(sp)
    800042de:	e822                	sd	s0,16(sp)
    800042e0:	e426                	sd	s1,8(sp)
    800042e2:	e04a                	sd	s2,0(sp)
    800042e4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042e6:	0003d517          	auipc	a0,0x3d
    800042ea:	63a50513          	addi	a0,a0,1594 # 80041920 <log>
    800042ee:	ffffd097          	auipc	ra,0xffffd
    800042f2:	aec080e7          	jalr	-1300(ra) # 80000dda <acquire>
  while(1){
    if(log.committing){
    800042f6:	0003d497          	auipc	s1,0x3d
    800042fa:	62a48493          	addi	s1,s1,1578 # 80041920 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042fe:	4979                	li	s2,30
    80004300:	a039                	j	8000430e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004302:	85a6                	mv	a1,s1
    80004304:	8526                	mv	a0,s1
    80004306:	ffffe097          	auipc	ra,0xffffe
    8000430a:	1d0080e7          	jalr	464(ra) # 800024d6 <sleep>
    if(log.committing){
    8000430e:	50dc                	lw	a5,36(s1)
    80004310:	fbed                	bnez	a5,80004302 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004312:	509c                	lw	a5,32(s1)
    80004314:	0017871b          	addiw	a4,a5,1
    80004318:	0007069b          	sext.w	a3,a4
    8000431c:	0027179b          	slliw	a5,a4,0x2
    80004320:	9fb9                	addw	a5,a5,a4
    80004322:	0017979b          	slliw	a5,a5,0x1
    80004326:	54d8                	lw	a4,44(s1)
    80004328:	9fb9                	addw	a5,a5,a4
    8000432a:	00f95963          	bge	s2,a5,8000433c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000432e:	85a6                	mv	a1,s1
    80004330:	8526                	mv	a0,s1
    80004332:	ffffe097          	auipc	ra,0xffffe
    80004336:	1a4080e7          	jalr	420(ra) # 800024d6 <sleep>
    8000433a:	bfd1                	j	8000430e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000433c:	0003d517          	auipc	a0,0x3d
    80004340:	5e450513          	addi	a0,a0,1508 # 80041920 <log>
    80004344:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004346:	ffffd097          	auipc	ra,0xffffd
    8000434a:	b48080e7          	jalr	-1208(ra) # 80000e8e <release>
      break;
    }
  }
}
    8000434e:	60e2                	ld	ra,24(sp)
    80004350:	6442                	ld	s0,16(sp)
    80004352:	64a2                	ld	s1,8(sp)
    80004354:	6902                	ld	s2,0(sp)
    80004356:	6105                	addi	sp,sp,32
    80004358:	8082                	ret

000000008000435a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000435a:	7139                	addi	sp,sp,-64
    8000435c:	fc06                	sd	ra,56(sp)
    8000435e:	f822                	sd	s0,48(sp)
    80004360:	f426                	sd	s1,40(sp)
    80004362:	f04a                	sd	s2,32(sp)
    80004364:	ec4e                	sd	s3,24(sp)
    80004366:	e852                	sd	s4,16(sp)
    80004368:	e456                	sd	s5,8(sp)
    8000436a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000436c:	0003d497          	auipc	s1,0x3d
    80004370:	5b448493          	addi	s1,s1,1460 # 80041920 <log>
    80004374:	8526                	mv	a0,s1
    80004376:	ffffd097          	auipc	ra,0xffffd
    8000437a:	a64080e7          	jalr	-1436(ra) # 80000dda <acquire>
  log.outstanding -= 1;
    8000437e:	509c                	lw	a5,32(s1)
    80004380:	37fd                	addiw	a5,a5,-1
    80004382:	0007891b          	sext.w	s2,a5
    80004386:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004388:	50dc                	lw	a5,36(s1)
    8000438a:	efb9                	bnez	a5,800043e8 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000438c:	06091663          	bnez	s2,800043f8 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004390:	0003d497          	auipc	s1,0x3d
    80004394:	59048493          	addi	s1,s1,1424 # 80041920 <log>
    80004398:	4785                	li	a5,1
    8000439a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000439c:	8526                	mv	a0,s1
    8000439e:	ffffd097          	auipc	ra,0xffffd
    800043a2:	af0080e7          	jalr	-1296(ra) # 80000e8e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043a6:	54dc                	lw	a5,44(s1)
    800043a8:	06f04763          	bgtz	a5,80004416 <end_op+0xbc>
    acquire(&log.lock);
    800043ac:	0003d497          	auipc	s1,0x3d
    800043b0:	57448493          	addi	s1,s1,1396 # 80041920 <log>
    800043b4:	8526                	mv	a0,s1
    800043b6:	ffffd097          	auipc	ra,0xffffd
    800043ba:	a24080e7          	jalr	-1500(ra) # 80000dda <acquire>
    log.committing = 0;
    800043be:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043c2:	8526                	mv	a0,s1
    800043c4:	ffffe097          	auipc	ra,0xffffe
    800043c8:	298080e7          	jalr	664(ra) # 8000265c <wakeup>
    release(&log.lock);
    800043cc:	8526                	mv	a0,s1
    800043ce:	ffffd097          	auipc	ra,0xffffd
    800043d2:	ac0080e7          	jalr	-1344(ra) # 80000e8e <release>
}
    800043d6:	70e2                	ld	ra,56(sp)
    800043d8:	7442                	ld	s0,48(sp)
    800043da:	74a2                	ld	s1,40(sp)
    800043dc:	7902                	ld	s2,32(sp)
    800043de:	69e2                	ld	s3,24(sp)
    800043e0:	6a42                	ld	s4,16(sp)
    800043e2:	6aa2                	ld	s5,8(sp)
    800043e4:	6121                	addi	sp,sp,64
    800043e6:	8082                	ret
    panic("log.committing");
    800043e8:	00004517          	auipc	a0,0x4
    800043ec:	22850513          	addi	a0,a0,552 # 80008610 <syscalls+0x1e0>
    800043f0:	ffffc097          	auipc	ra,0xffffc
    800043f4:	158080e7          	jalr	344(ra) # 80000548 <panic>
    wakeup(&log);
    800043f8:	0003d497          	auipc	s1,0x3d
    800043fc:	52848493          	addi	s1,s1,1320 # 80041920 <log>
    80004400:	8526                	mv	a0,s1
    80004402:	ffffe097          	auipc	ra,0xffffe
    80004406:	25a080e7          	jalr	602(ra) # 8000265c <wakeup>
  release(&log.lock);
    8000440a:	8526                	mv	a0,s1
    8000440c:	ffffd097          	auipc	ra,0xffffd
    80004410:	a82080e7          	jalr	-1406(ra) # 80000e8e <release>
  if(do_commit){
    80004414:	b7c9                	j	800043d6 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004416:	0003da97          	auipc	s5,0x3d
    8000441a:	53aa8a93          	addi	s5,s5,1338 # 80041950 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000441e:	0003da17          	auipc	s4,0x3d
    80004422:	502a0a13          	addi	s4,s4,1282 # 80041920 <log>
    80004426:	018a2583          	lw	a1,24(s4)
    8000442a:	012585bb          	addw	a1,a1,s2
    8000442e:	2585                	addiw	a1,a1,1
    80004430:	028a2503          	lw	a0,40(s4)
    80004434:	fffff097          	auipc	ra,0xfffff
    80004438:	ce4080e7          	jalr	-796(ra) # 80003118 <bread>
    8000443c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000443e:	000aa583          	lw	a1,0(s5)
    80004442:	028a2503          	lw	a0,40(s4)
    80004446:	fffff097          	auipc	ra,0xfffff
    8000444a:	cd2080e7          	jalr	-814(ra) # 80003118 <bread>
    8000444e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004450:	40000613          	li	a2,1024
    80004454:	05850593          	addi	a1,a0,88
    80004458:	05848513          	addi	a0,s1,88
    8000445c:	ffffd097          	auipc	ra,0xffffd
    80004460:	ada080e7          	jalr	-1318(ra) # 80000f36 <memmove>
    bwrite(to);  // write the log
    80004464:	8526                	mv	a0,s1
    80004466:	fffff097          	auipc	ra,0xfffff
    8000446a:	da4080e7          	jalr	-604(ra) # 8000320a <bwrite>
    brelse(from);
    8000446e:	854e                	mv	a0,s3
    80004470:	fffff097          	auipc	ra,0xfffff
    80004474:	dd8080e7          	jalr	-552(ra) # 80003248 <brelse>
    brelse(to);
    80004478:	8526                	mv	a0,s1
    8000447a:	fffff097          	auipc	ra,0xfffff
    8000447e:	dce080e7          	jalr	-562(ra) # 80003248 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004482:	2905                	addiw	s2,s2,1
    80004484:	0a91                	addi	s5,s5,4
    80004486:	02ca2783          	lw	a5,44(s4)
    8000448a:	f8f94ee3          	blt	s2,a5,80004426 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000448e:	00000097          	auipc	ra,0x0
    80004492:	c7a080e7          	jalr	-902(ra) # 80004108 <write_head>
    install_trans(); // Now install writes to home locations
    80004496:	00000097          	auipc	ra,0x0
    8000449a:	cec080e7          	jalr	-788(ra) # 80004182 <install_trans>
    log.lh.n = 0;
    8000449e:	0003d797          	auipc	a5,0x3d
    800044a2:	4a07a723          	sw	zero,1198(a5) # 8004194c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044a6:	00000097          	auipc	ra,0x0
    800044aa:	c62080e7          	jalr	-926(ra) # 80004108 <write_head>
    800044ae:	bdfd                	j	800043ac <end_op+0x52>

00000000800044b0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044b0:	1101                	addi	sp,sp,-32
    800044b2:	ec06                	sd	ra,24(sp)
    800044b4:	e822                	sd	s0,16(sp)
    800044b6:	e426                	sd	s1,8(sp)
    800044b8:	e04a                	sd	s2,0(sp)
    800044ba:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044bc:	0003d717          	auipc	a4,0x3d
    800044c0:	49072703          	lw	a4,1168(a4) # 8004194c <log+0x2c>
    800044c4:	47f5                	li	a5,29
    800044c6:	08e7c063          	blt	a5,a4,80004546 <log_write+0x96>
    800044ca:	84aa                	mv	s1,a0
    800044cc:	0003d797          	auipc	a5,0x3d
    800044d0:	4707a783          	lw	a5,1136(a5) # 8004193c <log+0x1c>
    800044d4:	37fd                	addiw	a5,a5,-1
    800044d6:	06f75863          	bge	a4,a5,80004546 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044da:	0003d797          	auipc	a5,0x3d
    800044de:	4667a783          	lw	a5,1126(a5) # 80041940 <log+0x20>
    800044e2:	06f05a63          	blez	a5,80004556 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800044e6:	0003d917          	auipc	s2,0x3d
    800044ea:	43a90913          	addi	s2,s2,1082 # 80041920 <log>
    800044ee:	854a                	mv	a0,s2
    800044f0:	ffffd097          	auipc	ra,0xffffd
    800044f4:	8ea080e7          	jalr	-1814(ra) # 80000dda <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800044f8:	02c92603          	lw	a2,44(s2)
    800044fc:	06c05563          	blez	a2,80004566 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004500:	44cc                	lw	a1,12(s1)
    80004502:	0003d717          	auipc	a4,0x3d
    80004506:	44e70713          	addi	a4,a4,1102 # 80041950 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000450a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000450c:	4314                	lw	a3,0(a4)
    8000450e:	04b68d63          	beq	a3,a1,80004568 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004512:	2785                	addiw	a5,a5,1
    80004514:	0711                	addi	a4,a4,4
    80004516:	fec79be3          	bne	a5,a2,8000450c <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000451a:	0621                	addi	a2,a2,8
    8000451c:	060a                	slli	a2,a2,0x2
    8000451e:	0003d797          	auipc	a5,0x3d
    80004522:	40278793          	addi	a5,a5,1026 # 80041920 <log>
    80004526:	963e                	add	a2,a2,a5
    80004528:	44dc                	lw	a5,12(s1)
    8000452a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000452c:	8526                	mv	a0,s1
    8000452e:	fffff097          	auipc	ra,0xfffff
    80004532:	db8080e7          	jalr	-584(ra) # 800032e6 <bpin>
    log.lh.n++;
    80004536:	0003d717          	auipc	a4,0x3d
    8000453a:	3ea70713          	addi	a4,a4,1002 # 80041920 <log>
    8000453e:	575c                	lw	a5,44(a4)
    80004540:	2785                	addiw	a5,a5,1
    80004542:	d75c                	sw	a5,44(a4)
    80004544:	a83d                	j	80004582 <log_write+0xd2>
    panic("too big a transaction");
    80004546:	00004517          	auipc	a0,0x4
    8000454a:	0da50513          	addi	a0,a0,218 # 80008620 <syscalls+0x1f0>
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	ffa080e7          	jalr	-6(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004556:	00004517          	auipc	a0,0x4
    8000455a:	0e250513          	addi	a0,a0,226 # 80008638 <syscalls+0x208>
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	fea080e7          	jalr	-22(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004566:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004568:	00878713          	addi	a4,a5,8
    8000456c:	00271693          	slli	a3,a4,0x2
    80004570:	0003d717          	auipc	a4,0x3d
    80004574:	3b070713          	addi	a4,a4,944 # 80041920 <log>
    80004578:	9736                	add	a4,a4,a3
    8000457a:	44d4                	lw	a3,12(s1)
    8000457c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000457e:	faf607e3          	beq	a2,a5,8000452c <log_write+0x7c>
  }
  release(&log.lock);
    80004582:	0003d517          	auipc	a0,0x3d
    80004586:	39e50513          	addi	a0,a0,926 # 80041920 <log>
    8000458a:	ffffd097          	auipc	ra,0xffffd
    8000458e:	904080e7          	jalr	-1788(ra) # 80000e8e <release>
}
    80004592:	60e2                	ld	ra,24(sp)
    80004594:	6442                	ld	s0,16(sp)
    80004596:	64a2                	ld	s1,8(sp)
    80004598:	6902                	ld	s2,0(sp)
    8000459a:	6105                	addi	sp,sp,32
    8000459c:	8082                	ret

000000008000459e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000459e:	1101                	addi	sp,sp,-32
    800045a0:	ec06                	sd	ra,24(sp)
    800045a2:	e822                	sd	s0,16(sp)
    800045a4:	e426                	sd	s1,8(sp)
    800045a6:	e04a                	sd	s2,0(sp)
    800045a8:	1000                	addi	s0,sp,32
    800045aa:	84aa                	mv	s1,a0
    800045ac:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045ae:	00004597          	auipc	a1,0x4
    800045b2:	0aa58593          	addi	a1,a1,170 # 80008658 <syscalls+0x228>
    800045b6:	0521                	addi	a0,a0,8
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	792080e7          	jalr	1938(ra) # 80000d4a <initlock>
  lk->name = name;
    800045c0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045c4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045c8:	0204a423          	sw	zero,40(s1)
}
    800045cc:	60e2                	ld	ra,24(sp)
    800045ce:	6442                	ld	s0,16(sp)
    800045d0:	64a2                	ld	s1,8(sp)
    800045d2:	6902                	ld	s2,0(sp)
    800045d4:	6105                	addi	sp,sp,32
    800045d6:	8082                	ret

00000000800045d8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045d8:	1101                	addi	sp,sp,-32
    800045da:	ec06                	sd	ra,24(sp)
    800045dc:	e822                	sd	s0,16(sp)
    800045de:	e426                	sd	s1,8(sp)
    800045e0:	e04a                	sd	s2,0(sp)
    800045e2:	1000                	addi	s0,sp,32
    800045e4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045e6:	00850913          	addi	s2,a0,8
    800045ea:	854a                	mv	a0,s2
    800045ec:	ffffc097          	auipc	ra,0xffffc
    800045f0:	7ee080e7          	jalr	2030(ra) # 80000dda <acquire>
  while (lk->locked) {
    800045f4:	409c                	lw	a5,0(s1)
    800045f6:	cb89                	beqz	a5,80004608 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045f8:	85ca                	mv	a1,s2
    800045fa:	8526                	mv	a0,s1
    800045fc:	ffffe097          	auipc	ra,0xffffe
    80004600:	eda080e7          	jalr	-294(ra) # 800024d6 <sleep>
  while (lk->locked) {
    80004604:	409c                	lw	a5,0(s1)
    80004606:	fbed                	bnez	a5,800045f8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004608:	4785                	li	a5,1
    8000460a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000460c:	ffffd097          	auipc	ra,0xffffd
    80004610:	6ba080e7          	jalr	1722(ra) # 80001cc6 <myproc>
    80004614:	5d1c                	lw	a5,56(a0)
    80004616:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004618:	854a                	mv	a0,s2
    8000461a:	ffffd097          	auipc	ra,0xffffd
    8000461e:	874080e7          	jalr	-1932(ra) # 80000e8e <release>
}
    80004622:	60e2                	ld	ra,24(sp)
    80004624:	6442                	ld	s0,16(sp)
    80004626:	64a2                	ld	s1,8(sp)
    80004628:	6902                	ld	s2,0(sp)
    8000462a:	6105                	addi	sp,sp,32
    8000462c:	8082                	ret

000000008000462e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000462e:	1101                	addi	sp,sp,-32
    80004630:	ec06                	sd	ra,24(sp)
    80004632:	e822                	sd	s0,16(sp)
    80004634:	e426                	sd	s1,8(sp)
    80004636:	e04a                	sd	s2,0(sp)
    80004638:	1000                	addi	s0,sp,32
    8000463a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000463c:	00850913          	addi	s2,a0,8
    80004640:	854a                	mv	a0,s2
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	798080e7          	jalr	1944(ra) # 80000dda <acquire>
  lk->locked = 0;
    8000464a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000464e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004652:	8526                	mv	a0,s1
    80004654:	ffffe097          	auipc	ra,0xffffe
    80004658:	008080e7          	jalr	8(ra) # 8000265c <wakeup>
  release(&lk->lk);
    8000465c:	854a                	mv	a0,s2
    8000465e:	ffffd097          	auipc	ra,0xffffd
    80004662:	830080e7          	jalr	-2000(ra) # 80000e8e <release>
}
    80004666:	60e2                	ld	ra,24(sp)
    80004668:	6442                	ld	s0,16(sp)
    8000466a:	64a2                	ld	s1,8(sp)
    8000466c:	6902                	ld	s2,0(sp)
    8000466e:	6105                	addi	sp,sp,32
    80004670:	8082                	ret

0000000080004672 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004672:	7179                	addi	sp,sp,-48
    80004674:	f406                	sd	ra,40(sp)
    80004676:	f022                	sd	s0,32(sp)
    80004678:	ec26                	sd	s1,24(sp)
    8000467a:	e84a                	sd	s2,16(sp)
    8000467c:	e44e                	sd	s3,8(sp)
    8000467e:	1800                	addi	s0,sp,48
    80004680:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004682:	00850913          	addi	s2,a0,8
    80004686:	854a                	mv	a0,s2
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	752080e7          	jalr	1874(ra) # 80000dda <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004690:	409c                	lw	a5,0(s1)
    80004692:	ef99                	bnez	a5,800046b0 <holdingsleep+0x3e>
    80004694:	4481                	li	s1,0
  release(&lk->lk);
    80004696:	854a                	mv	a0,s2
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	7f6080e7          	jalr	2038(ra) # 80000e8e <release>
  return r;
}
    800046a0:	8526                	mv	a0,s1
    800046a2:	70a2                	ld	ra,40(sp)
    800046a4:	7402                	ld	s0,32(sp)
    800046a6:	64e2                	ld	s1,24(sp)
    800046a8:	6942                	ld	s2,16(sp)
    800046aa:	69a2                	ld	s3,8(sp)
    800046ac:	6145                	addi	sp,sp,48
    800046ae:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046b0:	0284a983          	lw	s3,40(s1)
    800046b4:	ffffd097          	auipc	ra,0xffffd
    800046b8:	612080e7          	jalr	1554(ra) # 80001cc6 <myproc>
    800046bc:	5d04                	lw	s1,56(a0)
    800046be:	413484b3          	sub	s1,s1,s3
    800046c2:	0014b493          	seqz	s1,s1
    800046c6:	bfc1                	j	80004696 <holdingsleep+0x24>

00000000800046c8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046c8:	1141                	addi	sp,sp,-16
    800046ca:	e406                	sd	ra,8(sp)
    800046cc:	e022                	sd	s0,0(sp)
    800046ce:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046d0:	00004597          	auipc	a1,0x4
    800046d4:	f9858593          	addi	a1,a1,-104 # 80008668 <syscalls+0x238>
    800046d8:	0003d517          	auipc	a0,0x3d
    800046dc:	39050513          	addi	a0,a0,912 # 80041a68 <ftable>
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	66a080e7          	jalr	1642(ra) # 80000d4a <initlock>
}
    800046e8:	60a2                	ld	ra,8(sp)
    800046ea:	6402                	ld	s0,0(sp)
    800046ec:	0141                	addi	sp,sp,16
    800046ee:	8082                	ret

00000000800046f0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046f0:	1101                	addi	sp,sp,-32
    800046f2:	ec06                	sd	ra,24(sp)
    800046f4:	e822                	sd	s0,16(sp)
    800046f6:	e426                	sd	s1,8(sp)
    800046f8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046fa:	0003d517          	auipc	a0,0x3d
    800046fe:	36e50513          	addi	a0,a0,878 # 80041a68 <ftable>
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	6d8080e7          	jalr	1752(ra) # 80000dda <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000470a:	0003d497          	auipc	s1,0x3d
    8000470e:	37648493          	addi	s1,s1,886 # 80041a80 <ftable+0x18>
    80004712:	0003e717          	auipc	a4,0x3e
    80004716:	30e70713          	addi	a4,a4,782 # 80042a20 <ftable+0xfb8>
    if(f->ref == 0){
    8000471a:	40dc                	lw	a5,4(s1)
    8000471c:	cf99                	beqz	a5,8000473a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000471e:	02848493          	addi	s1,s1,40
    80004722:	fee49ce3          	bne	s1,a4,8000471a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004726:	0003d517          	auipc	a0,0x3d
    8000472a:	34250513          	addi	a0,a0,834 # 80041a68 <ftable>
    8000472e:	ffffc097          	auipc	ra,0xffffc
    80004732:	760080e7          	jalr	1888(ra) # 80000e8e <release>
  return 0;
    80004736:	4481                	li	s1,0
    80004738:	a819                	j	8000474e <filealloc+0x5e>
      f->ref = 1;
    8000473a:	4785                	li	a5,1
    8000473c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000473e:	0003d517          	auipc	a0,0x3d
    80004742:	32a50513          	addi	a0,a0,810 # 80041a68 <ftable>
    80004746:	ffffc097          	auipc	ra,0xffffc
    8000474a:	748080e7          	jalr	1864(ra) # 80000e8e <release>
}
    8000474e:	8526                	mv	a0,s1
    80004750:	60e2                	ld	ra,24(sp)
    80004752:	6442                	ld	s0,16(sp)
    80004754:	64a2                	ld	s1,8(sp)
    80004756:	6105                	addi	sp,sp,32
    80004758:	8082                	ret

000000008000475a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000475a:	1101                	addi	sp,sp,-32
    8000475c:	ec06                	sd	ra,24(sp)
    8000475e:	e822                	sd	s0,16(sp)
    80004760:	e426                	sd	s1,8(sp)
    80004762:	1000                	addi	s0,sp,32
    80004764:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004766:	0003d517          	auipc	a0,0x3d
    8000476a:	30250513          	addi	a0,a0,770 # 80041a68 <ftable>
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	66c080e7          	jalr	1644(ra) # 80000dda <acquire>
  if(f->ref < 1)
    80004776:	40dc                	lw	a5,4(s1)
    80004778:	02f05263          	blez	a5,8000479c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000477c:	2785                	addiw	a5,a5,1
    8000477e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004780:	0003d517          	auipc	a0,0x3d
    80004784:	2e850513          	addi	a0,a0,744 # 80041a68 <ftable>
    80004788:	ffffc097          	auipc	ra,0xffffc
    8000478c:	706080e7          	jalr	1798(ra) # 80000e8e <release>
  return f;
}
    80004790:	8526                	mv	a0,s1
    80004792:	60e2                	ld	ra,24(sp)
    80004794:	6442                	ld	s0,16(sp)
    80004796:	64a2                	ld	s1,8(sp)
    80004798:	6105                	addi	sp,sp,32
    8000479a:	8082                	ret
    panic("filedup");
    8000479c:	00004517          	auipc	a0,0x4
    800047a0:	ed450513          	addi	a0,a0,-300 # 80008670 <syscalls+0x240>
    800047a4:	ffffc097          	auipc	ra,0xffffc
    800047a8:	da4080e7          	jalr	-604(ra) # 80000548 <panic>

00000000800047ac <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047ac:	7139                	addi	sp,sp,-64
    800047ae:	fc06                	sd	ra,56(sp)
    800047b0:	f822                	sd	s0,48(sp)
    800047b2:	f426                	sd	s1,40(sp)
    800047b4:	f04a                	sd	s2,32(sp)
    800047b6:	ec4e                	sd	s3,24(sp)
    800047b8:	e852                	sd	s4,16(sp)
    800047ba:	e456                	sd	s5,8(sp)
    800047bc:	0080                	addi	s0,sp,64
    800047be:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047c0:	0003d517          	auipc	a0,0x3d
    800047c4:	2a850513          	addi	a0,a0,680 # 80041a68 <ftable>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	612080e7          	jalr	1554(ra) # 80000dda <acquire>
  if(f->ref < 1)
    800047d0:	40dc                	lw	a5,4(s1)
    800047d2:	06f05163          	blez	a5,80004834 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047d6:	37fd                	addiw	a5,a5,-1
    800047d8:	0007871b          	sext.w	a4,a5
    800047dc:	c0dc                	sw	a5,4(s1)
    800047de:	06e04363          	bgtz	a4,80004844 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047e2:	0004a903          	lw	s2,0(s1)
    800047e6:	0094ca83          	lbu	s5,9(s1)
    800047ea:	0104ba03          	ld	s4,16(s1)
    800047ee:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047f2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047f6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047fa:	0003d517          	auipc	a0,0x3d
    800047fe:	26e50513          	addi	a0,a0,622 # 80041a68 <ftable>
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	68c080e7          	jalr	1676(ra) # 80000e8e <release>

  if(ff.type == FD_PIPE){
    8000480a:	4785                	li	a5,1
    8000480c:	04f90d63          	beq	s2,a5,80004866 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004810:	3979                	addiw	s2,s2,-2
    80004812:	4785                	li	a5,1
    80004814:	0527e063          	bltu	a5,s2,80004854 <fileclose+0xa8>
    begin_op();
    80004818:	00000097          	auipc	ra,0x0
    8000481c:	ac2080e7          	jalr	-1342(ra) # 800042da <begin_op>
    iput(ff.ip);
    80004820:	854e                	mv	a0,s3
    80004822:	fffff097          	auipc	ra,0xfffff
    80004826:	2b2080e7          	jalr	690(ra) # 80003ad4 <iput>
    end_op();
    8000482a:	00000097          	auipc	ra,0x0
    8000482e:	b30080e7          	jalr	-1232(ra) # 8000435a <end_op>
    80004832:	a00d                	j	80004854 <fileclose+0xa8>
    panic("fileclose");
    80004834:	00004517          	auipc	a0,0x4
    80004838:	e4450513          	addi	a0,a0,-444 # 80008678 <syscalls+0x248>
    8000483c:	ffffc097          	auipc	ra,0xffffc
    80004840:	d0c080e7          	jalr	-756(ra) # 80000548 <panic>
    release(&ftable.lock);
    80004844:	0003d517          	auipc	a0,0x3d
    80004848:	22450513          	addi	a0,a0,548 # 80041a68 <ftable>
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	642080e7          	jalr	1602(ra) # 80000e8e <release>
  }
}
    80004854:	70e2                	ld	ra,56(sp)
    80004856:	7442                	ld	s0,48(sp)
    80004858:	74a2                	ld	s1,40(sp)
    8000485a:	7902                	ld	s2,32(sp)
    8000485c:	69e2                	ld	s3,24(sp)
    8000485e:	6a42                	ld	s4,16(sp)
    80004860:	6aa2                	ld	s5,8(sp)
    80004862:	6121                	addi	sp,sp,64
    80004864:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004866:	85d6                	mv	a1,s5
    80004868:	8552                	mv	a0,s4
    8000486a:	00000097          	auipc	ra,0x0
    8000486e:	372080e7          	jalr	882(ra) # 80004bdc <pipeclose>
    80004872:	b7cd                	j	80004854 <fileclose+0xa8>

0000000080004874 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004874:	715d                	addi	sp,sp,-80
    80004876:	e486                	sd	ra,72(sp)
    80004878:	e0a2                	sd	s0,64(sp)
    8000487a:	fc26                	sd	s1,56(sp)
    8000487c:	f84a                	sd	s2,48(sp)
    8000487e:	f44e                	sd	s3,40(sp)
    80004880:	0880                	addi	s0,sp,80
    80004882:	84aa                	mv	s1,a0
    80004884:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004886:	ffffd097          	auipc	ra,0xffffd
    8000488a:	440080e7          	jalr	1088(ra) # 80001cc6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000488e:	409c                	lw	a5,0(s1)
    80004890:	37f9                	addiw	a5,a5,-2
    80004892:	4705                	li	a4,1
    80004894:	04f76763          	bltu	a4,a5,800048e2 <filestat+0x6e>
    80004898:	892a                	mv	s2,a0
    ilock(f->ip);
    8000489a:	6c88                	ld	a0,24(s1)
    8000489c:	fffff097          	auipc	ra,0xfffff
    800048a0:	07e080e7          	jalr	126(ra) # 8000391a <ilock>
    stati(f->ip, &st);
    800048a4:	fb840593          	addi	a1,s0,-72
    800048a8:	6c88                	ld	a0,24(s1)
    800048aa:	fffff097          	auipc	ra,0xfffff
    800048ae:	2fa080e7          	jalr	762(ra) # 80003ba4 <stati>
    iunlock(f->ip);
    800048b2:	6c88                	ld	a0,24(s1)
    800048b4:	fffff097          	auipc	ra,0xfffff
    800048b8:	128080e7          	jalr	296(ra) # 800039dc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048bc:	46e1                	li	a3,24
    800048be:	fb840613          	addi	a2,s0,-72
    800048c2:	85ce                	mv	a1,s3
    800048c4:	05093503          	ld	a0,80(s2)
    800048c8:	ffffd097          	auipc	ra,0xffffd
    800048cc:	1f0080e7          	jalr	496(ra) # 80001ab8 <copyout>
    800048d0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048d4:	60a6                	ld	ra,72(sp)
    800048d6:	6406                	ld	s0,64(sp)
    800048d8:	74e2                	ld	s1,56(sp)
    800048da:	7942                	ld	s2,48(sp)
    800048dc:	79a2                	ld	s3,40(sp)
    800048de:	6161                	addi	sp,sp,80
    800048e0:	8082                	ret
  return -1;
    800048e2:	557d                	li	a0,-1
    800048e4:	bfc5                	j	800048d4 <filestat+0x60>

00000000800048e6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048e6:	7179                	addi	sp,sp,-48
    800048e8:	f406                	sd	ra,40(sp)
    800048ea:	f022                	sd	s0,32(sp)
    800048ec:	ec26                	sd	s1,24(sp)
    800048ee:	e84a                	sd	s2,16(sp)
    800048f0:	e44e                	sd	s3,8(sp)
    800048f2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048f4:	00854783          	lbu	a5,8(a0)
    800048f8:	c3d5                	beqz	a5,8000499c <fileread+0xb6>
    800048fa:	84aa                	mv	s1,a0
    800048fc:	89ae                	mv	s3,a1
    800048fe:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004900:	411c                	lw	a5,0(a0)
    80004902:	4705                	li	a4,1
    80004904:	04e78963          	beq	a5,a4,80004956 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004908:	470d                	li	a4,3
    8000490a:	04e78d63          	beq	a5,a4,80004964 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000490e:	4709                	li	a4,2
    80004910:	06e79e63          	bne	a5,a4,8000498c <fileread+0xa6>
    ilock(f->ip);
    80004914:	6d08                	ld	a0,24(a0)
    80004916:	fffff097          	auipc	ra,0xfffff
    8000491a:	004080e7          	jalr	4(ra) # 8000391a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000491e:	874a                	mv	a4,s2
    80004920:	5094                	lw	a3,32(s1)
    80004922:	864e                	mv	a2,s3
    80004924:	4585                	li	a1,1
    80004926:	6c88                	ld	a0,24(s1)
    80004928:	fffff097          	auipc	ra,0xfffff
    8000492c:	2a6080e7          	jalr	678(ra) # 80003bce <readi>
    80004930:	892a                	mv	s2,a0
    80004932:	00a05563          	blez	a0,8000493c <fileread+0x56>
      f->off += r;
    80004936:	509c                	lw	a5,32(s1)
    80004938:	9fa9                	addw	a5,a5,a0
    8000493a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000493c:	6c88                	ld	a0,24(s1)
    8000493e:	fffff097          	auipc	ra,0xfffff
    80004942:	09e080e7          	jalr	158(ra) # 800039dc <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004946:	854a                	mv	a0,s2
    80004948:	70a2                	ld	ra,40(sp)
    8000494a:	7402                	ld	s0,32(sp)
    8000494c:	64e2                	ld	s1,24(sp)
    8000494e:	6942                	ld	s2,16(sp)
    80004950:	69a2                	ld	s3,8(sp)
    80004952:	6145                	addi	sp,sp,48
    80004954:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004956:	6908                	ld	a0,16(a0)
    80004958:	00000097          	auipc	ra,0x0
    8000495c:	418080e7          	jalr	1048(ra) # 80004d70 <piperead>
    80004960:	892a                	mv	s2,a0
    80004962:	b7d5                	j	80004946 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004964:	02451783          	lh	a5,36(a0)
    80004968:	03079693          	slli	a3,a5,0x30
    8000496c:	92c1                	srli	a3,a3,0x30
    8000496e:	4725                	li	a4,9
    80004970:	02d76863          	bltu	a4,a3,800049a0 <fileread+0xba>
    80004974:	0792                	slli	a5,a5,0x4
    80004976:	0003d717          	auipc	a4,0x3d
    8000497a:	05270713          	addi	a4,a4,82 # 800419c8 <devsw>
    8000497e:	97ba                	add	a5,a5,a4
    80004980:	639c                	ld	a5,0(a5)
    80004982:	c38d                	beqz	a5,800049a4 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004984:	4505                	li	a0,1
    80004986:	9782                	jalr	a5
    80004988:	892a                	mv	s2,a0
    8000498a:	bf75                	j	80004946 <fileread+0x60>
    panic("fileread");
    8000498c:	00004517          	auipc	a0,0x4
    80004990:	cfc50513          	addi	a0,a0,-772 # 80008688 <syscalls+0x258>
    80004994:	ffffc097          	auipc	ra,0xffffc
    80004998:	bb4080e7          	jalr	-1100(ra) # 80000548 <panic>
    return -1;
    8000499c:	597d                	li	s2,-1
    8000499e:	b765                	j	80004946 <fileread+0x60>
      return -1;
    800049a0:	597d                	li	s2,-1
    800049a2:	b755                	j	80004946 <fileread+0x60>
    800049a4:	597d                	li	s2,-1
    800049a6:	b745                	j	80004946 <fileread+0x60>

00000000800049a8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800049a8:	00954783          	lbu	a5,9(a0)
    800049ac:	14078563          	beqz	a5,80004af6 <filewrite+0x14e>
{
    800049b0:	715d                	addi	sp,sp,-80
    800049b2:	e486                	sd	ra,72(sp)
    800049b4:	e0a2                	sd	s0,64(sp)
    800049b6:	fc26                	sd	s1,56(sp)
    800049b8:	f84a                	sd	s2,48(sp)
    800049ba:	f44e                	sd	s3,40(sp)
    800049bc:	f052                	sd	s4,32(sp)
    800049be:	ec56                	sd	s5,24(sp)
    800049c0:	e85a                	sd	s6,16(sp)
    800049c2:	e45e                	sd	s7,8(sp)
    800049c4:	e062                	sd	s8,0(sp)
    800049c6:	0880                	addi	s0,sp,80
    800049c8:	892a                	mv	s2,a0
    800049ca:	8aae                	mv	s5,a1
    800049cc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049ce:	411c                	lw	a5,0(a0)
    800049d0:	4705                	li	a4,1
    800049d2:	02e78263          	beq	a5,a4,800049f6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049d6:	470d                	li	a4,3
    800049d8:	02e78563          	beq	a5,a4,80004a02 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049dc:	4709                	li	a4,2
    800049de:	10e79463          	bne	a5,a4,80004ae6 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049e2:	0ec05e63          	blez	a2,80004ade <filewrite+0x136>
    int i = 0;
    800049e6:	4981                	li	s3,0
    800049e8:	6b05                	lui	s6,0x1
    800049ea:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049ee:	6b85                	lui	s7,0x1
    800049f0:	c00b8b9b          	addiw	s7,s7,-1024
    800049f4:	a851                	j	80004a88 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049f6:	6908                	ld	a0,16(a0)
    800049f8:	00000097          	auipc	ra,0x0
    800049fc:	254080e7          	jalr	596(ra) # 80004c4c <pipewrite>
    80004a00:	a85d                	j	80004ab6 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a02:	02451783          	lh	a5,36(a0)
    80004a06:	03079693          	slli	a3,a5,0x30
    80004a0a:	92c1                	srli	a3,a3,0x30
    80004a0c:	4725                	li	a4,9
    80004a0e:	0ed76663          	bltu	a4,a3,80004afa <filewrite+0x152>
    80004a12:	0792                	slli	a5,a5,0x4
    80004a14:	0003d717          	auipc	a4,0x3d
    80004a18:	fb470713          	addi	a4,a4,-76 # 800419c8 <devsw>
    80004a1c:	97ba                	add	a5,a5,a4
    80004a1e:	679c                	ld	a5,8(a5)
    80004a20:	cff9                	beqz	a5,80004afe <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004a22:	4505                	li	a0,1
    80004a24:	9782                	jalr	a5
    80004a26:	a841                	j	80004ab6 <filewrite+0x10e>
    80004a28:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a2c:	00000097          	auipc	ra,0x0
    80004a30:	8ae080e7          	jalr	-1874(ra) # 800042da <begin_op>
      ilock(f->ip);
    80004a34:	01893503          	ld	a0,24(s2)
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	ee2080e7          	jalr	-286(ra) # 8000391a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a40:	8762                	mv	a4,s8
    80004a42:	02092683          	lw	a3,32(s2)
    80004a46:	01598633          	add	a2,s3,s5
    80004a4a:	4585                	li	a1,1
    80004a4c:	01893503          	ld	a0,24(s2)
    80004a50:	fffff097          	auipc	ra,0xfffff
    80004a54:	276080e7          	jalr	630(ra) # 80003cc6 <writei>
    80004a58:	84aa                	mv	s1,a0
    80004a5a:	02a05f63          	blez	a0,80004a98 <filewrite+0xf0>
        f->off += r;
    80004a5e:	02092783          	lw	a5,32(s2)
    80004a62:	9fa9                	addw	a5,a5,a0
    80004a64:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a68:	01893503          	ld	a0,24(s2)
    80004a6c:	fffff097          	auipc	ra,0xfffff
    80004a70:	f70080e7          	jalr	-144(ra) # 800039dc <iunlock>
      end_op();
    80004a74:	00000097          	auipc	ra,0x0
    80004a78:	8e6080e7          	jalr	-1818(ra) # 8000435a <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a7c:	049c1963          	bne	s8,s1,80004ace <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004a80:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a84:	0349d663          	bge	s3,s4,80004ab0 <filewrite+0x108>
      int n1 = n - i;
    80004a88:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a8c:	84be                	mv	s1,a5
    80004a8e:	2781                	sext.w	a5,a5
    80004a90:	f8fb5ce3          	bge	s6,a5,80004a28 <filewrite+0x80>
    80004a94:	84de                	mv	s1,s7
    80004a96:	bf49                	j	80004a28 <filewrite+0x80>
      iunlock(f->ip);
    80004a98:	01893503          	ld	a0,24(s2)
    80004a9c:	fffff097          	auipc	ra,0xfffff
    80004aa0:	f40080e7          	jalr	-192(ra) # 800039dc <iunlock>
      end_op();
    80004aa4:	00000097          	auipc	ra,0x0
    80004aa8:	8b6080e7          	jalr	-1866(ra) # 8000435a <end_op>
      if(r < 0)
    80004aac:	fc04d8e3          	bgez	s1,80004a7c <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004ab0:	8552                	mv	a0,s4
    80004ab2:	033a1863          	bne	s4,s3,80004ae2 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ab6:	60a6                	ld	ra,72(sp)
    80004ab8:	6406                	ld	s0,64(sp)
    80004aba:	74e2                	ld	s1,56(sp)
    80004abc:	7942                	ld	s2,48(sp)
    80004abe:	79a2                	ld	s3,40(sp)
    80004ac0:	7a02                	ld	s4,32(sp)
    80004ac2:	6ae2                	ld	s5,24(sp)
    80004ac4:	6b42                	ld	s6,16(sp)
    80004ac6:	6ba2                	ld	s7,8(sp)
    80004ac8:	6c02                	ld	s8,0(sp)
    80004aca:	6161                	addi	sp,sp,80
    80004acc:	8082                	ret
        panic("short filewrite");
    80004ace:	00004517          	auipc	a0,0x4
    80004ad2:	bca50513          	addi	a0,a0,-1078 # 80008698 <syscalls+0x268>
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	a72080e7          	jalr	-1422(ra) # 80000548 <panic>
    int i = 0;
    80004ade:	4981                	li	s3,0
    80004ae0:	bfc1                	j	80004ab0 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004ae2:	557d                	li	a0,-1
    80004ae4:	bfc9                	j	80004ab6 <filewrite+0x10e>
    panic("filewrite");
    80004ae6:	00004517          	auipc	a0,0x4
    80004aea:	bc250513          	addi	a0,a0,-1086 # 800086a8 <syscalls+0x278>
    80004aee:	ffffc097          	auipc	ra,0xffffc
    80004af2:	a5a080e7          	jalr	-1446(ra) # 80000548 <panic>
    return -1;
    80004af6:	557d                	li	a0,-1
}
    80004af8:	8082                	ret
      return -1;
    80004afa:	557d                	li	a0,-1
    80004afc:	bf6d                	j	80004ab6 <filewrite+0x10e>
    80004afe:	557d                	li	a0,-1
    80004b00:	bf5d                	j	80004ab6 <filewrite+0x10e>

0000000080004b02 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b02:	7179                	addi	sp,sp,-48
    80004b04:	f406                	sd	ra,40(sp)
    80004b06:	f022                	sd	s0,32(sp)
    80004b08:	ec26                	sd	s1,24(sp)
    80004b0a:	e84a                	sd	s2,16(sp)
    80004b0c:	e44e                	sd	s3,8(sp)
    80004b0e:	e052                	sd	s4,0(sp)
    80004b10:	1800                	addi	s0,sp,48
    80004b12:	84aa                	mv	s1,a0
    80004b14:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b16:	0005b023          	sd	zero,0(a1)
    80004b1a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b1e:	00000097          	auipc	ra,0x0
    80004b22:	bd2080e7          	jalr	-1070(ra) # 800046f0 <filealloc>
    80004b26:	e088                	sd	a0,0(s1)
    80004b28:	c551                	beqz	a0,80004bb4 <pipealloc+0xb2>
    80004b2a:	00000097          	auipc	ra,0x0
    80004b2e:	bc6080e7          	jalr	-1082(ra) # 800046f0 <filealloc>
    80004b32:	00aa3023          	sd	a0,0(s4)
    80004b36:	c92d                	beqz	a0,80004ba8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b38:	ffffc097          	auipc	ra,0xffffc
    80004b3c:	12c080e7          	jalr	300(ra) # 80000c64 <kalloc>
    80004b40:	892a                	mv	s2,a0
    80004b42:	c125                	beqz	a0,80004ba2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b44:	4985                	li	s3,1
    80004b46:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b4a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b4e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b52:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b56:	00004597          	auipc	a1,0x4
    80004b5a:	b6258593          	addi	a1,a1,-1182 # 800086b8 <syscalls+0x288>
    80004b5e:	ffffc097          	auipc	ra,0xffffc
    80004b62:	1ec080e7          	jalr	492(ra) # 80000d4a <initlock>
  (*f0)->type = FD_PIPE;
    80004b66:	609c                	ld	a5,0(s1)
    80004b68:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b6c:	609c                	ld	a5,0(s1)
    80004b6e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b72:	609c                	ld	a5,0(s1)
    80004b74:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b78:	609c                	ld	a5,0(s1)
    80004b7a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b7e:	000a3783          	ld	a5,0(s4)
    80004b82:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b86:	000a3783          	ld	a5,0(s4)
    80004b8a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b8e:	000a3783          	ld	a5,0(s4)
    80004b92:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b96:	000a3783          	ld	a5,0(s4)
    80004b9a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b9e:	4501                	li	a0,0
    80004ba0:	a025                	j	80004bc8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ba2:	6088                	ld	a0,0(s1)
    80004ba4:	e501                	bnez	a0,80004bac <pipealloc+0xaa>
    80004ba6:	a039                	j	80004bb4 <pipealloc+0xb2>
    80004ba8:	6088                	ld	a0,0(s1)
    80004baa:	c51d                	beqz	a0,80004bd8 <pipealloc+0xd6>
    fileclose(*f0);
    80004bac:	00000097          	auipc	ra,0x0
    80004bb0:	c00080e7          	jalr	-1024(ra) # 800047ac <fileclose>
  if(*f1)
    80004bb4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bb8:	557d                	li	a0,-1
  if(*f1)
    80004bba:	c799                	beqz	a5,80004bc8 <pipealloc+0xc6>
    fileclose(*f1);
    80004bbc:	853e                	mv	a0,a5
    80004bbe:	00000097          	auipc	ra,0x0
    80004bc2:	bee080e7          	jalr	-1042(ra) # 800047ac <fileclose>
  return -1;
    80004bc6:	557d                	li	a0,-1
}
    80004bc8:	70a2                	ld	ra,40(sp)
    80004bca:	7402                	ld	s0,32(sp)
    80004bcc:	64e2                	ld	s1,24(sp)
    80004bce:	6942                	ld	s2,16(sp)
    80004bd0:	69a2                	ld	s3,8(sp)
    80004bd2:	6a02                	ld	s4,0(sp)
    80004bd4:	6145                	addi	sp,sp,48
    80004bd6:	8082                	ret
  return -1;
    80004bd8:	557d                	li	a0,-1
    80004bda:	b7fd                	j	80004bc8 <pipealloc+0xc6>

0000000080004bdc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bdc:	1101                	addi	sp,sp,-32
    80004bde:	ec06                	sd	ra,24(sp)
    80004be0:	e822                	sd	s0,16(sp)
    80004be2:	e426                	sd	s1,8(sp)
    80004be4:	e04a                	sd	s2,0(sp)
    80004be6:	1000                	addi	s0,sp,32
    80004be8:	84aa                	mv	s1,a0
    80004bea:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	1ee080e7          	jalr	494(ra) # 80000dda <acquire>
  if(writable){
    80004bf4:	02090d63          	beqz	s2,80004c2e <pipeclose+0x52>
    pi->writeopen = 0;
    80004bf8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bfc:	21848513          	addi	a0,s1,536
    80004c00:	ffffe097          	auipc	ra,0xffffe
    80004c04:	a5c080e7          	jalr	-1444(ra) # 8000265c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c08:	2204b783          	ld	a5,544(s1)
    80004c0c:	eb95                	bnez	a5,80004c40 <pipeclose+0x64>
    release(&pi->lock);
    80004c0e:	8526                	mv	a0,s1
    80004c10:	ffffc097          	auipc	ra,0xffffc
    80004c14:	27e080e7          	jalr	638(ra) # 80000e8e <release>
    kfree((char*)pi);
    80004c18:	8526                	mv	a0,s1
    80004c1a:	ffffc097          	auipc	ra,0xffffc
    80004c1e:	ee4080e7          	jalr	-284(ra) # 80000afe <kfree>
  } else
    release(&pi->lock);
}
    80004c22:	60e2                	ld	ra,24(sp)
    80004c24:	6442                	ld	s0,16(sp)
    80004c26:	64a2                	ld	s1,8(sp)
    80004c28:	6902                	ld	s2,0(sp)
    80004c2a:	6105                	addi	sp,sp,32
    80004c2c:	8082                	ret
    pi->readopen = 0;
    80004c2e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c32:	21c48513          	addi	a0,s1,540
    80004c36:	ffffe097          	auipc	ra,0xffffe
    80004c3a:	a26080e7          	jalr	-1498(ra) # 8000265c <wakeup>
    80004c3e:	b7e9                	j	80004c08 <pipeclose+0x2c>
    release(&pi->lock);
    80004c40:	8526                	mv	a0,s1
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	24c080e7          	jalr	588(ra) # 80000e8e <release>
}
    80004c4a:	bfe1                	j	80004c22 <pipeclose+0x46>

0000000080004c4c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c4c:	7119                	addi	sp,sp,-128
    80004c4e:	fc86                	sd	ra,120(sp)
    80004c50:	f8a2                	sd	s0,112(sp)
    80004c52:	f4a6                	sd	s1,104(sp)
    80004c54:	f0ca                	sd	s2,96(sp)
    80004c56:	ecce                	sd	s3,88(sp)
    80004c58:	e8d2                	sd	s4,80(sp)
    80004c5a:	e4d6                	sd	s5,72(sp)
    80004c5c:	e0da                	sd	s6,64(sp)
    80004c5e:	fc5e                	sd	s7,56(sp)
    80004c60:	f862                	sd	s8,48(sp)
    80004c62:	f466                	sd	s9,40(sp)
    80004c64:	f06a                	sd	s10,32(sp)
    80004c66:	ec6e                	sd	s11,24(sp)
    80004c68:	0100                	addi	s0,sp,128
    80004c6a:	84aa                	mv	s1,a0
    80004c6c:	8cae                	mv	s9,a1
    80004c6e:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c70:	ffffd097          	auipc	ra,0xffffd
    80004c74:	056080e7          	jalr	86(ra) # 80001cc6 <myproc>
    80004c78:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	ffffc097          	auipc	ra,0xffffc
    80004c80:	15e080e7          	jalr	350(ra) # 80000dda <acquire>
  for(i = 0; i < n; i++){
    80004c84:	0d605963          	blez	s6,80004d56 <pipewrite+0x10a>
    80004c88:	89a6                	mv	s3,s1
    80004c8a:	3b7d                	addiw	s6,s6,-1
    80004c8c:	1b02                	slli	s6,s6,0x20
    80004c8e:	020b5b13          	srli	s6,s6,0x20
    80004c92:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c94:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c98:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c9c:	5dfd                	li	s11,-1
    80004c9e:	000b8d1b          	sext.w	s10,s7
    80004ca2:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ca4:	2184a783          	lw	a5,536(s1)
    80004ca8:	21c4a703          	lw	a4,540(s1)
    80004cac:	2007879b          	addiw	a5,a5,512
    80004cb0:	02f71b63          	bne	a4,a5,80004ce6 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004cb4:	2204a783          	lw	a5,544(s1)
    80004cb8:	cbad                	beqz	a5,80004d2a <pipewrite+0xde>
    80004cba:	03092783          	lw	a5,48(s2)
    80004cbe:	e7b5                	bnez	a5,80004d2a <pipewrite+0xde>
      wakeup(&pi->nread);
    80004cc0:	8556                	mv	a0,s5
    80004cc2:	ffffe097          	auipc	ra,0xffffe
    80004cc6:	99a080e7          	jalr	-1638(ra) # 8000265c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cca:	85ce                	mv	a1,s3
    80004ccc:	8552                	mv	a0,s4
    80004cce:	ffffe097          	auipc	ra,0xffffe
    80004cd2:	808080e7          	jalr	-2040(ra) # 800024d6 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004cd6:	2184a783          	lw	a5,536(s1)
    80004cda:	21c4a703          	lw	a4,540(s1)
    80004cde:	2007879b          	addiw	a5,a5,512
    80004ce2:	fcf709e3          	beq	a4,a5,80004cb4 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ce6:	4685                	li	a3,1
    80004ce8:	019b8633          	add	a2,s7,s9
    80004cec:	f8f40593          	addi	a1,s0,-113
    80004cf0:	05093503          	ld	a0,80(s2)
    80004cf4:	ffffd097          	auipc	ra,0xffffd
    80004cf8:	b86080e7          	jalr	-1146(ra) # 8000187a <copyin>
    80004cfc:	05b50e63          	beq	a0,s11,80004d58 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d00:	21c4a783          	lw	a5,540(s1)
    80004d04:	0017871b          	addiw	a4,a5,1
    80004d08:	20e4ae23          	sw	a4,540(s1)
    80004d0c:	1ff7f793          	andi	a5,a5,511
    80004d10:	97a6                	add	a5,a5,s1
    80004d12:	f8f44703          	lbu	a4,-113(s0)
    80004d16:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004d1a:	001d0c1b          	addiw	s8,s10,1
    80004d1e:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004d22:	036b8b63          	beq	s7,s6,80004d58 <pipewrite+0x10c>
    80004d26:	8bbe                	mv	s7,a5
    80004d28:	bf9d                	j	80004c9e <pipewrite+0x52>
        release(&pi->lock);
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	162080e7          	jalr	354(ra) # 80000e8e <release>
        return -1;
    80004d34:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004d36:	8562                	mv	a0,s8
    80004d38:	70e6                	ld	ra,120(sp)
    80004d3a:	7446                	ld	s0,112(sp)
    80004d3c:	74a6                	ld	s1,104(sp)
    80004d3e:	7906                	ld	s2,96(sp)
    80004d40:	69e6                	ld	s3,88(sp)
    80004d42:	6a46                	ld	s4,80(sp)
    80004d44:	6aa6                	ld	s5,72(sp)
    80004d46:	6b06                	ld	s6,64(sp)
    80004d48:	7be2                	ld	s7,56(sp)
    80004d4a:	7c42                	ld	s8,48(sp)
    80004d4c:	7ca2                	ld	s9,40(sp)
    80004d4e:	7d02                	ld	s10,32(sp)
    80004d50:	6de2                	ld	s11,24(sp)
    80004d52:	6109                	addi	sp,sp,128
    80004d54:	8082                	ret
  for(i = 0; i < n; i++){
    80004d56:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004d58:	21848513          	addi	a0,s1,536
    80004d5c:	ffffe097          	auipc	ra,0xffffe
    80004d60:	900080e7          	jalr	-1792(ra) # 8000265c <wakeup>
  release(&pi->lock);
    80004d64:	8526                	mv	a0,s1
    80004d66:	ffffc097          	auipc	ra,0xffffc
    80004d6a:	128080e7          	jalr	296(ra) # 80000e8e <release>
  return i;
    80004d6e:	b7e1                	j	80004d36 <pipewrite+0xea>

0000000080004d70 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d70:	715d                	addi	sp,sp,-80
    80004d72:	e486                	sd	ra,72(sp)
    80004d74:	e0a2                	sd	s0,64(sp)
    80004d76:	fc26                	sd	s1,56(sp)
    80004d78:	f84a                	sd	s2,48(sp)
    80004d7a:	f44e                	sd	s3,40(sp)
    80004d7c:	f052                	sd	s4,32(sp)
    80004d7e:	ec56                	sd	s5,24(sp)
    80004d80:	e85a                	sd	s6,16(sp)
    80004d82:	0880                	addi	s0,sp,80
    80004d84:	84aa                	mv	s1,a0
    80004d86:	892e                	mv	s2,a1
    80004d88:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d8a:	ffffd097          	auipc	ra,0xffffd
    80004d8e:	f3c080e7          	jalr	-196(ra) # 80001cc6 <myproc>
    80004d92:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d94:	8b26                	mv	s6,s1
    80004d96:	8526                	mv	a0,s1
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	042080e7          	jalr	66(ra) # 80000dda <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004da0:	2184a703          	lw	a4,536(s1)
    80004da4:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004da8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dac:	02f71463          	bne	a4,a5,80004dd4 <piperead+0x64>
    80004db0:	2244a783          	lw	a5,548(s1)
    80004db4:	c385                	beqz	a5,80004dd4 <piperead+0x64>
    if(pr->killed){
    80004db6:	030a2783          	lw	a5,48(s4)
    80004dba:	ebc1                	bnez	a5,80004e4a <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dbc:	85da                	mv	a1,s6
    80004dbe:	854e                	mv	a0,s3
    80004dc0:	ffffd097          	auipc	ra,0xffffd
    80004dc4:	716080e7          	jalr	1814(ra) # 800024d6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc8:	2184a703          	lw	a4,536(s1)
    80004dcc:	21c4a783          	lw	a5,540(s1)
    80004dd0:	fef700e3          	beq	a4,a5,80004db0 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dd4:	09505263          	blez	s5,80004e58 <piperead+0xe8>
    80004dd8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dda:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004ddc:	2184a783          	lw	a5,536(s1)
    80004de0:	21c4a703          	lw	a4,540(s1)
    80004de4:	02f70d63          	beq	a4,a5,80004e1e <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004de8:	0017871b          	addiw	a4,a5,1
    80004dec:	20e4ac23          	sw	a4,536(s1)
    80004df0:	1ff7f793          	andi	a5,a5,511
    80004df4:	97a6                	add	a5,a5,s1
    80004df6:	0187c783          	lbu	a5,24(a5)
    80004dfa:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dfe:	4685                	li	a3,1
    80004e00:	fbf40613          	addi	a2,s0,-65
    80004e04:	85ca                	mv	a1,s2
    80004e06:	050a3503          	ld	a0,80(s4)
    80004e0a:	ffffd097          	auipc	ra,0xffffd
    80004e0e:	cae080e7          	jalr	-850(ra) # 80001ab8 <copyout>
    80004e12:	01650663          	beq	a0,s6,80004e1e <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e16:	2985                	addiw	s3,s3,1
    80004e18:	0905                	addi	s2,s2,1
    80004e1a:	fd3a91e3          	bne	s5,s3,80004ddc <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e1e:	21c48513          	addi	a0,s1,540
    80004e22:	ffffe097          	auipc	ra,0xffffe
    80004e26:	83a080e7          	jalr	-1990(ra) # 8000265c <wakeup>
  release(&pi->lock);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	ffffc097          	auipc	ra,0xffffc
    80004e30:	062080e7          	jalr	98(ra) # 80000e8e <release>
  return i;
}
    80004e34:	854e                	mv	a0,s3
    80004e36:	60a6                	ld	ra,72(sp)
    80004e38:	6406                	ld	s0,64(sp)
    80004e3a:	74e2                	ld	s1,56(sp)
    80004e3c:	7942                	ld	s2,48(sp)
    80004e3e:	79a2                	ld	s3,40(sp)
    80004e40:	7a02                	ld	s4,32(sp)
    80004e42:	6ae2                	ld	s5,24(sp)
    80004e44:	6b42                	ld	s6,16(sp)
    80004e46:	6161                	addi	sp,sp,80
    80004e48:	8082                	ret
      release(&pi->lock);
    80004e4a:	8526                	mv	a0,s1
    80004e4c:	ffffc097          	auipc	ra,0xffffc
    80004e50:	042080e7          	jalr	66(ra) # 80000e8e <release>
      return -1;
    80004e54:	59fd                	li	s3,-1
    80004e56:	bff9                	j	80004e34 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e58:	4981                	li	s3,0
    80004e5a:	b7d1                	j	80004e1e <piperead+0xae>

0000000080004e5c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e5c:	df010113          	addi	sp,sp,-528
    80004e60:	20113423          	sd	ra,520(sp)
    80004e64:	20813023          	sd	s0,512(sp)
    80004e68:	ffa6                	sd	s1,504(sp)
    80004e6a:	fbca                	sd	s2,496(sp)
    80004e6c:	f7ce                	sd	s3,488(sp)
    80004e6e:	f3d2                	sd	s4,480(sp)
    80004e70:	efd6                	sd	s5,472(sp)
    80004e72:	ebda                	sd	s6,464(sp)
    80004e74:	e7de                	sd	s7,456(sp)
    80004e76:	e3e2                	sd	s8,448(sp)
    80004e78:	ff66                	sd	s9,440(sp)
    80004e7a:	fb6a                	sd	s10,432(sp)
    80004e7c:	f76e                	sd	s11,424(sp)
    80004e7e:	0c00                	addi	s0,sp,528
    80004e80:	84aa                	mv	s1,a0
    80004e82:	dea43c23          	sd	a0,-520(s0)
    80004e86:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e8a:	ffffd097          	auipc	ra,0xffffd
    80004e8e:	e3c080e7          	jalr	-452(ra) # 80001cc6 <myproc>
    80004e92:	892a                	mv	s2,a0

  begin_op();
    80004e94:	fffff097          	auipc	ra,0xfffff
    80004e98:	446080e7          	jalr	1094(ra) # 800042da <begin_op>

  if((ip = namei(path)) == 0){
    80004e9c:	8526                	mv	a0,s1
    80004e9e:	fffff097          	auipc	ra,0xfffff
    80004ea2:	230080e7          	jalr	560(ra) # 800040ce <namei>
    80004ea6:	c92d                	beqz	a0,80004f18 <exec+0xbc>
    80004ea8:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	a70080e7          	jalr	-1424(ra) # 8000391a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004eb2:	04000713          	li	a4,64
    80004eb6:	4681                	li	a3,0
    80004eb8:	e4840613          	addi	a2,s0,-440
    80004ebc:	4581                	li	a1,0
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	d0e080e7          	jalr	-754(ra) # 80003bce <readi>
    80004ec8:	04000793          	li	a5,64
    80004ecc:	00f51a63          	bne	a0,a5,80004ee0 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004ed0:	e4842703          	lw	a4,-440(s0)
    80004ed4:	464c47b7          	lui	a5,0x464c4
    80004ed8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004edc:	04f70463          	beq	a4,a5,80004f24 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ee0:	8526                	mv	a0,s1
    80004ee2:	fffff097          	auipc	ra,0xfffff
    80004ee6:	c9a080e7          	jalr	-870(ra) # 80003b7c <iunlockput>
    end_op();
    80004eea:	fffff097          	auipc	ra,0xfffff
    80004eee:	470080e7          	jalr	1136(ra) # 8000435a <end_op>
  }
  return -1;
    80004ef2:	557d                	li	a0,-1
}
    80004ef4:	20813083          	ld	ra,520(sp)
    80004ef8:	20013403          	ld	s0,512(sp)
    80004efc:	74fe                	ld	s1,504(sp)
    80004efe:	795e                	ld	s2,496(sp)
    80004f00:	79be                	ld	s3,488(sp)
    80004f02:	7a1e                	ld	s4,480(sp)
    80004f04:	6afe                	ld	s5,472(sp)
    80004f06:	6b5e                	ld	s6,464(sp)
    80004f08:	6bbe                	ld	s7,456(sp)
    80004f0a:	6c1e                	ld	s8,448(sp)
    80004f0c:	7cfa                	ld	s9,440(sp)
    80004f0e:	7d5a                	ld	s10,432(sp)
    80004f10:	7dba                	ld	s11,424(sp)
    80004f12:	21010113          	addi	sp,sp,528
    80004f16:	8082                	ret
    end_op();
    80004f18:	fffff097          	auipc	ra,0xfffff
    80004f1c:	442080e7          	jalr	1090(ra) # 8000435a <end_op>
    return -1;
    80004f20:	557d                	li	a0,-1
    80004f22:	bfc9                	j	80004ef4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f24:	854a                	mv	a0,s2
    80004f26:	ffffd097          	auipc	ra,0xffffd
    80004f2a:	e64080e7          	jalr	-412(ra) # 80001d8a <proc_pagetable>
    80004f2e:	8baa                	mv	s7,a0
    80004f30:	d945                	beqz	a0,80004ee0 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f32:	e6842983          	lw	s3,-408(s0)
    80004f36:	e8045783          	lhu	a5,-384(s0)
    80004f3a:	c7ad                	beqz	a5,80004fa4 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f3c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f3e:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004f40:	6c85                	lui	s9,0x1
    80004f42:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f46:	def43823          	sd	a5,-528(s0)
    80004f4a:	a42d                	j	80005174 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f4c:	00003517          	auipc	a0,0x3
    80004f50:	77450513          	addi	a0,a0,1908 # 800086c0 <syscalls+0x290>
    80004f54:	ffffb097          	auipc	ra,0xffffb
    80004f58:	5f4080e7          	jalr	1524(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f5c:	8756                	mv	a4,s5
    80004f5e:	012d86bb          	addw	a3,s11,s2
    80004f62:	4581                	li	a1,0
    80004f64:	8526                	mv	a0,s1
    80004f66:	fffff097          	auipc	ra,0xfffff
    80004f6a:	c68080e7          	jalr	-920(ra) # 80003bce <readi>
    80004f6e:	2501                	sext.w	a0,a0
    80004f70:	1aaa9963          	bne	s5,a0,80005122 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004f74:	6785                	lui	a5,0x1
    80004f76:	0127893b          	addw	s2,a5,s2
    80004f7a:	77fd                	lui	a5,0xfffff
    80004f7c:	01478a3b          	addw	s4,a5,s4
    80004f80:	1f897163          	bgeu	s2,s8,80005162 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004f84:	02091593          	slli	a1,s2,0x20
    80004f88:	9181                	srli	a1,a1,0x20
    80004f8a:	95ea                	add	a1,a1,s10
    80004f8c:	855e                	mv	a0,s7
    80004f8e:	ffffc097          	auipc	ra,0xffffc
    80004f92:	2da080e7          	jalr	730(ra) # 80001268 <walkaddr>
    80004f96:	862a                	mv	a2,a0
    if(pa == 0)
    80004f98:	d955                	beqz	a0,80004f4c <exec+0xf0>
      n = PGSIZE;
    80004f9a:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004f9c:	fd9a70e3          	bgeu	s4,s9,80004f5c <exec+0x100>
      n = sz - i;
    80004fa0:	8ad2                	mv	s5,s4
    80004fa2:	bf6d                	j	80004f5c <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004fa4:	4901                	li	s2,0
  iunlockput(ip);
    80004fa6:	8526                	mv	a0,s1
    80004fa8:	fffff097          	auipc	ra,0xfffff
    80004fac:	bd4080e7          	jalr	-1068(ra) # 80003b7c <iunlockput>
  end_op();
    80004fb0:	fffff097          	auipc	ra,0xfffff
    80004fb4:	3aa080e7          	jalr	938(ra) # 8000435a <end_op>
  p = myproc();
    80004fb8:	ffffd097          	auipc	ra,0xffffd
    80004fbc:	d0e080e7          	jalr	-754(ra) # 80001cc6 <myproc>
    80004fc0:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004fc2:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004fc6:	6785                	lui	a5,0x1
    80004fc8:	17fd                	addi	a5,a5,-1
    80004fca:	993e                	add	s2,s2,a5
    80004fcc:	757d                	lui	a0,0xfffff
    80004fce:	00a977b3          	and	a5,s2,a0
    80004fd2:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fd6:	6609                	lui	a2,0x2
    80004fd8:	963e                	add	a2,a2,a5
    80004fda:	85be                	mv	a1,a5
    80004fdc:	855e                	mv	a0,s7
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	658080e7          	jalr	1624(ra) # 80001636 <uvmalloc>
    80004fe6:	8b2a                	mv	s6,a0
  ip = 0;
    80004fe8:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fea:	12050c63          	beqz	a0,80005122 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fee:	75f9                	lui	a1,0xffffe
    80004ff0:	95aa                	add	a1,a1,a0
    80004ff2:	855e                	mv	a0,s7
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	854080e7          	jalr	-1964(ra) # 80001848 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ffc:	7c7d                	lui	s8,0xfffff
    80004ffe:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005000:	e0043783          	ld	a5,-512(s0)
    80005004:	6388                	ld	a0,0(a5)
    80005006:	c535                	beqz	a0,80005072 <exec+0x216>
    80005008:	e8840993          	addi	s3,s0,-376
    8000500c:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005010:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005012:	ffffc097          	auipc	ra,0xffffc
    80005016:	04c080e7          	jalr	76(ra) # 8000105e <strlen>
    8000501a:	2505                	addiw	a0,a0,1
    8000501c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005020:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005024:	13896363          	bltu	s2,s8,8000514a <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005028:	e0043d83          	ld	s11,-512(s0)
    8000502c:	000dba03          	ld	s4,0(s11)
    80005030:	8552                	mv	a0,s4
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	02c080e7          	jalr	44(ra) # 8000105e <strlen>
    8000503a:	0015069b          	addiw	a3,a0,1
    8000503e:	8652                	mv	a2,s4
    80005040:	85ca                	mv	a1,s2
    80005042:	855e                	mv	a0,s7
    80005044:	ffffd097          	auipc	ra,0xffffd
    80005048:	a74080e7          	jalr	-1420(ra) # 80001ab8 <copyout>
    8000504c:	10054363          	bltz	a0,80005152 <exec+0x2f6>
    ustack[argc] = sp;
    80005050:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005054:	0485                	addi	s1,s1,1
    80005056:	008d8793          	addi	a5,s11,8
    8000505a:	e0f43023          	sd	a5,-512(s0)
    8000505e:	008db503          	ld	a0,8(s11)
    80005062:	c911                	beqz	a0,80005076 <exec+0x21a>
    if(argc >= MAXARG)
    80005064:	09a1                	addi	s3,s3,8
    80005066:	fb3c96e3          	bne	s9,s3,80005012 <exec+0x1b6>
  sz = sz1;
    8000506a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000506e:	4481                	li	s1,0
    80005070:	a84d                	j	80005122 <exec+0x2c6>
  sp = sz;
    80005072:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005074:	4481                	li	s1,0
  ustack[argc] = 0;
    80005076:	00349793          	slli	a5,s1,0x3
    8000507a:	f9040713          	addi	a4,s0,-112
    8000507e:	97ba                	add	a5,a5,a4
    80005080:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80005084:	00148693          	addi	a3,s1,1
    80005088:	068e                	slli	a3,a3,0x3
    8000508a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000508e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005092:	01897663          	bgeu	s2,s8,8000509e <exec+0x242>
  sz = sz1;
    80005096:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000509a:	4481                	li	s1,0
    8000509c:	a059                	j	80005122 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000509e:	e8840613          	addi	a2,s0,-376
    800050a2:	85ca                	mv	a1,s2
    800050a4:	855e                	mv	a0,s7
    800050a6:	ffffd097          	auipc	ra,0xffffd
    800050aa:	a12080e7          	jalr	-1518(ra) # 80001ab8 <copyout>
    800050ae:	0a054663          	bltz	a0,8000515a <exec+0x2fe>
  p->trapframe->a1 = sp;
    800050b2:	058ab783          	ld	a5,88(s5)
    800050b6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050ba:	df843783          	ld	a5,-520(s0)
    800050be:	0007c703          	lbu	a4,0(a5)
    800050c2:	cf11                	beqz	a4,800050de <exec+0x282>
    800050c4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050c6:	02f00693          	li	a3,47
    800050ca:	a029                	j	800050d4 <exec+0x278>
  for(last=s=path; *s; s++)
    800050cc:	0785                	addi	a5,a5,1
    800050ce:	fff7c703          	lbu	a4,-1(a5)
    800050d2:	c711                	beqz	a4,800050de <exec+0x282>
    if(*s == '/')
    800050d4:	fed71ce3          	bne	a4,a3,800050cc <exec+0x270>
      last = s+1;
    800050d8:	def43c23          	sd	a5,-520(s0)
    800050dc:	bfc5                	j	800050cc <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    800050de:	4641                	li	a2,16
    800050e0:	df843583          	ld	a1,-520(s0)
    800050e4:	158a8513          	addi	a0,s5,344
    800050e8:	ffffc097          	auipc	ra,0xffffc
    800050ec:	f44080e7          	jalr	-188(ra) # 8000102c <safestrcpy>
  oldpagetable = p->pagetable;
    800050f0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050f4:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800050f8:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050fc:	058ab783          	ld	a5,88(s5)
    80005100:	e6043703          	ld	a4,-416(s0)
    80005104:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005106:	058ab783          	ld	a5,88(s5)
    8000510a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000510e:	85ea                	mv	a1,s10
    80005110:	ffffd097          	auipc	ra,0xffffd
    80005114:	d16080e7          	jalr	-746(ra) # 80001e26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005118:	0004851b          	sext.w	a0,s1
    8000511c:	bbe1                	j	80004ef4 <exec+0x98>
    8000511e:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005122:	e0843583          	ld	a1,-504(s0)
    80005126:	855e                	mv	a0,s7
    80005128:	ffffd097          	auipc	ra,0xffffd
    8000512c:	cfe080e7          	jalr	-770(ra) # 80001e26 <proc_freepagetable>
  if(ip){
    80005130:	da0498e3          	bnez	s1,80004ee0 <exec+0x84>
  return -1;
    80005134:	557d                	li	a0,-1
    80005136:	bb7d                	j	80004ef4 <exec+0x98>
    80005138:	e1243423          	sd	s2,-504(s0)
    8000513c:	b7dd                	j	80005122 <exec+0x2c6>
    8000513e:	e1243423          	sd	s2,-504(s0)
    80005142:	b7c5                	j	80005122 <exec+0x2c6>
    80005144:	e1243423          	sd	s2,-504(s0)
    80005148:	bfe9                	j	80005122 <exec+0x2c6>
  sz = sz1;
    8000514a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000514e:	4481                	li	s1,0
    80005150:	bfc9                	j	80005122 <exec+0x2c6>
  sz = sz1;
    80005152:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005156:	4481                	li	s1,0
    80005158:	b7e9                	j	80005122 <exec+0x2c6>
  sz = sz1;
    8000515a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000515e:	4481                	li	s1,0
    80005160:	b7c9                	j	80005122 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005162:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005166:	2b05                	addiw	s6,s6,1
    80005168:	0389899b          	addiw	s3,s3,56
    8000516c:	e8045783          	lhu	a5,-384(s0)
    80005170:	e2fb5be3          	bge	s6,a5,80004fa6 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005174:	2981                	sext.w	s3,s3
    80005176:	03800713          	li	a4,56
    8000517a:	86ce                	mv	a3,s3
    8000517c:	e1040613          	addi	a2,s0,-496
    80005180:	4581                	li	a1,0
    80005182:	8526                	mv	a0,s1
    80005184:	fffff097          	auipc	ra,0xfffff
    80005188:	a4a080e7          	jalr	-1462(ra) # 80003bce <readi>
    8000518c:	03800793          	li	a5,56
    80005190:	f8f517e3          	bne	a0,a5,8000511e <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005194:	e1042783          	lw	a5,-496(s0)
    80005198:	4705                	li	a4,1
    8000519a:	fce796e3          	bne	a5,a4,80005166 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    8000519e:	e3843603          	ld	a2,-456(s0)
    800051a2:	e3043783          	ld	a5,-464(s0)
    800051a6:	f8f669e3          	bltu	a2,a5,80005138 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051aa:	e2043783          	ld	a5,-480(s0)
    800051ae:	963e                	add	a2,a2,a5
    800051b0:	f8f667e3          	bltu	a2,a5,8000513e <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051b4:	85ca                	mv	a1,s2
    800051b6:	855e                	mv	a0,s7
    800051b8:	ffffc097          	auipc	ra,0xffffc
    800051bc:	47e080e7          	jalr	1150(ra) # 80001636 <uvmalloc>
    800051c0:	e0a43423          	sd	a0,-504(s0)
    800051c4:	d141                	beqz	a0,80005144 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    800051c6:	e2043d03          	ld	s10,-480(s0)
    800051ca:	df043783          	ld	a5,-528(s0)
    800051ce:	00fd77b3          	and	a5,s10,a5
    800051d2:	fba1                	bnez	a5,80005122 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051d4:	e1842d83          	lw	s11,-488(s0)
    800051d8:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051dc:	f80c03e3          	beqz	s8,80005162 <exec+0x306>
    800051e0:	8a62                	mv	s4,s8
    800051e2:	4901                	li	s2,0
    800051e4:	b345                	j	80004f84 <exec+0x128>

00000000800051e6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051e6:	7179                	addi	sp,sp,-48
    800051e8:	f406                	sd	ra,40(sp)
    800051ea:	f022                	sd	s0,32(sp)
    800051ec:	ec26                	sd	s1,24(sp)
    800051ee:	e84a                	sd	s2,16(sp)
    800051f0:	1800                	addi	s0,sp,48
    800051f2:	892e                	mv	s2,a1
    800051f4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051f6:	fdc40593          	addi	a1,s0,-36
    800051fa:	ffffe097          	auipc	ra,0xffffe
    800051fe:	bae080e7          	jalr	-1106(ra) # 80002da8 <argint>
    80005202:	04054063          	bltz	a0,80005242 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005206:	fdc42703          	lw	a4,-36(s0)
    8000520a:	47bd                	li	a5,15
    8000520c:	02e7ed63          	bltu	a5,a4,80005246 <argfd+0x60>
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	ab6080e7          	jalr	-1354(ra) # 80001cc6 <myproc>
    80005218:	fdc42703          	lw	a4,-36(s0)
    8000521c:	01a70793          	addi	a5,a4,26
    80005220:	078e                	slli	a5,a5,0x3
    80005222:	953e                	add	a0,a0,a5
    80005224:	611c                	ld	a5,0(a0)
    80005226:	c395                	beqz	a5,8000524a <argfd+0x64>
    return -1;
  if(pfd)
    80005228:	00090463          	beqz	s2,80005230 <argfd+0x4a>
    *pfd = fd;
    8000522c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005230:	4501                	li	a0,0
  if(pf)
    80005232:	c091                	beqz	s1,80005236 <argfd+0x50>
    *pf = f;
    80005234:	e09c                	sd	a5,0(s1)
}
    80005236:	70a2                	ld	ra,40(sp)
    80005238:	7402                	ld	s0,32(sp)
    8000523a:	64e2                	ld	s1,24(sp)
    8000523c:	6942                	ld	s2,16(sp)
    8000523e:	6145                	addi	sp,sp,48
    80005240:	8082                	ret
    return -1;
    80005242:	557d                	li	a0,-1
    80005244:	bfcd                	j	80005236 <argfd+0x50>
    return -1;
    80005246:	557d                	li	a0,-1
    80005248:	b7fd                	j	80005236 <argfd+0x50>
    8000524a:	557d                	li	a0,-1
    8000524c:	b7ed                	j	80005236 <argfd+0x50>

000000008000524e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000524e:	1101                	addi	sp,sp,-32
    80005250:	ec06                	sd	ra,24(sp)
    80005252:	e822                	sd	s0,16(sp)
    80005254:	e426                	sd	s1,8(sp)
    80005256:	1000                	addi	s0,sp,32
    80005258:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000525a:	ffffd097          	auipc	ra,0xffffd
    8000525e:	a6c080e7          	jalr	-1428(ra) # 80001cc6 <myproc>
    80005262:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005264:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffb90d0>
    80005268:	4501                	li	a0,0
    8000526a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000526c:	6398                	ld	a4,0(a5)
    8000526e:	cb19                	beqz	a4,80005284 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005270:	2505                	addiw	a0,a0,1
    80005272:	07a1                	addi	a5,a5,8
    80005274:	fed51ce3          	bne	a0,a3,8000526c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005278:	557d                	li	a0,-1
}
    8000527a:	60e2                	ld	ra,24(sp)
    8000527c:	6442                	ld	s0,16(sp)
    8000527e:	64a2                	ld	s1,8(sp)
    80005280:	6105                	addi	sp,sp,32
    80005282:	8082                	ret
      p->ofile[fd] = f;
    80005284:	01a50793          	addi	a5,a0,26
    80005288:	078e                	slli	a5,a5,0x3
    8000528a:	963e                	add	a2,a2,a5
    8000528c:	e204                	sd	s1,0(a2)
      return fd;
    8000528e:	b7f5                	j	8000527a <fdalloc+0x2c>

0000000080005290 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005290:	715d                	addi	sp,sp,-80
    80005292:	e486                	sd	ra,72(sp)
    80005294:	e0a2                	sd	s0,64(sp)
    80005296:	fc26                	sd	s1,56(sp)
    80005298:	f84a                	sd	s2,48(sp)
    8000529a:	f44e                	sd	s3,40(sp)
    8000529c:	f052                	sd	s4,32(sp)
    8000529e:	ec56                	sd	s5,24(sp)
    800052a0:	0880                	addi	s0,sp,80
    800052a2:	89ae                	mv	s3,a1
    800052a4:	8ab2                	mv	s5,a2
    800052a6:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052a8:	fb040593          	addi	a1,s0,-80
    800052ac:	fffff097          	auipc	ra,0xfffff
    800052b0:	e40080e7          	jalr	-448(ra) # 800040ec <nameiparent>
    800052b4:	892a                	mv	s2,a0
    800052b6:	12050f63          	beqz	a0,800053f4 <create+0x164>
    return 0;

  ilock(dp);
    800052ba:	ffffe097          	auipc	ra,0xffffe
    800052be:	660080e7          	jalr	1632(ra) # 8000391a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052c2:	4601                	li	a2,0
    800052c4:	fb040593          	addi	a1,s0,-80
    800052c8:	854a                	mv	a0,s2
    800052ca:	fffff097          	auipc	ra,0xfffff
    800052ce:	b32080e7          	jalr	-1230(ra) # 80003dfc <dirlookup>
    800052d2:	84aa                	mv	s1,a0
    800052d4:	c921                	beqz	a0,80005324 <create+0x94>
    iunlockput(dp);
    800052d6:	854a                	mv	a0,s2
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	8a4080e7          	jalr	-1884(ra) # 80003b7c <iunlockput>
    ilock(ip);
    800052e0:	8526                	mv	a0,s1
    800052e2:	ffffe097          	auipc	ra,0xffffe
    800052e6:	638080e7          	jalr	1592(ra) # 8000391a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052ea:	2981                	sext.w	s3,s3
    800052ec:	4789                	li	a5,2
    800052ee:	02f99463          	bne	s3,a5,80005316 <create+0x86>
    800052f2:	0444d783          	lhu	a5,68(s1)
    800052f6:	37f9                	addiw	a5,a5,-2
    800052f8:	17c2                	slli	a5,a5,0x30
    800052fa:	93c1                	srli	a5,a5,0x30
    800052fc:	4705                	li	a4,1
    800052fe:	00f76c63          	bltu	a4,a5,80005316 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005302:	8526                	mv	a0,s1
    80005304:	60a6                	ld	ra,72(sp)
    80005306:	6406                	ld	s0,64(sp)
    80005308:	74e2                	ld	s1,56(sp)
    8000530a:	7942                	ld	s2,48(sp)
    8000530c:	79a2                	ld	s3,40(sp)
    8000530e:	7a02                	ld	s4,32(sp)
    80005310:	6ae2                	ld	s5,24(sp)
    80005312:	6161                	addi	sp,sp,80
    80005314:	8082                	ret
    iunlockput(ip);
    80005316:	8526                	mv	a0,s1
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	864080e7          	jalr	-1948(ra) # 80003b7c <iunlockput>
    return 0;
    80005320:	4481                	li	s1,0
    80005322:	b7c5                	j	80005302 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005324:	85ce                	mv	a1,s3
    80005326:	00092503          	lw	a0,0(s2)
    8000532a:	ffffe097          	auipc	ra,0xffffe
    8000532e:	458080e7          	jalr	1112(ra) # 80003782 <ialloc>
    80005332:	84aa                	mv	s1,a0
    80005334:	c529                	beqz	a0,8000537e <create+0xee>
  ilock(ip);
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	5e4080e7          	jalr	1508(ra) # 8000391a <ilock>
  ip->major = major;
    8000533e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005342:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005346:	4785                	li	a5,1
    80005348:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000534c:	8526                	mv	a0,s1
    8000534e:	ffffe097          	auipc	ra,0xffffe
    80005352:	502080e7          	jalr	1282(ra) # 80003850 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005356:	2981                	sext.w	s3,s3
    80005358:	4785                	li	a5,1
    8000535a:	02f98a63          	beq	s3,a5,8000538e <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000535e:	40d0                	lw	a2,4(s1)
    80005360:	fb040593          	addi	a1,s0,-80
    80005364:	854a                	mv	a0,s2
    80005366:	fffff097          	auipc	ra,0xfffff
    8000536a:	ca6080e7          	jalr	-858(ra) # 8000400c <dirlink>
    8000536e:	06054b63          	bltz	a0,800053e4 <create+0x154>
  iunlockput(dp);
    80005372:	854a                	mv	a0,s2
    80005374:	fffff097          	auipc	ra,0xfffff
    80005378:	808080e7          	jalr	-2040(ra) # 80003b7c <iunlockput>
  return ip;
    8000537c:	b759                	j	80005302 <create+0x72>
    panic("create: ialloc");
    8000537e:	00003517          	auipc	a0,0x3
    80005382:	36250513          	addi	a0,a0,866 # 800086e0 <syscalls+0x2b0>
    80005386:	ffffb097          	auipc	ra,0xffffb
    8000538a:	1c2080e7          	jalr	450(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    8000538e:	04a95783          	lhu	a5,74(s2)
    80005392:	2785                	addiw	a5,a5,1
    80005394:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005398:	854a                	mv	a0,s2
    8000539a:	ffffe097          	auipc	ra,0xffffe
    8000539e:	4b6080e7          	jalr	1206(ra) # 80003850 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053a2:	40d0                	lw	a2,4(s1)
    800053a4:	00003597          	auipc	a1,0x3
    800053a8:	34c58593          	addi	a1,a1,844 # 800086f0 <syscalls+0x2c0>
    800053ac:	8526                	mv	a0,s1
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	c5e080e7          	jalr	-930(ra) # 8000400c <dirlink>
    800053b6:	00054f63          	bltz	a0,800053d4 <create+0x144>
    800053ba:	00492603          	lw	a2,4(s2)
    800053be:	00003597          	auipc	a1,0x3
    800053c2:	33a58593          	addi	a1,a1,826 # 800086f8 <syscalls+0x2c8>
    800053c6:	8526                	mv	a0,s1
    800053c8:	fffff097          	auipc	ra,0xfffff
    800053cc:	c44080e7          	jalr	-956(ra) # 8000400c <dirlink>
    800053d0:	f80557e3          	bgez	a0,8000535e <create+0xce>
      panic("create dots");
    800053d4:	00003517          	auipc	a0,0x3
    800053d8:	32c50513          	addi	a0,a0,812 # 80008700 <syscalls+0x2d0>
    800053dc:	ffffb097          	auipc	ra,0xffffb
    800053e0:	16c080e7          	jalr	364(ra) # 80000548 <panic>
    panic("create: dirlink");
    800053e4:	00003517          	auipc	a0,0x3
    800053e8:	32c50513          	addi	a0,a0,812 # 80008710 <syscalls+0x2e0>
    800053ec:	ffffb097          	auipc	ra,0xffffb
    800053f0:	15c080e7          	jalr	348(ra) # 80000548 <panic>
    return 0;
    800053f4:	84aa                	mv	s1,a0
    800053f6:	b731                	j	80005302 <create+0x72>

00000000800053f8 <sys_dup>:
{
    800053f8:	7179                	addi	sp,sp,-48
    800053fa:	f406                	sd	ra,40(sp)
    800053fc:	f022                	sd	s0,32(sp)
    800053fe:	ec26                	sd	s1,24(sp)
    80005400:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005402:	fd840613          	addi	a2,s0,-40
    80005406:	4581                	li	a1,0
    80005408:	4501                	li	a0,0
    8000540a:	00000097          	auipc	ra,0x0
    8000540e:	ddc080e7          	jalr	-548(ra) # 800051e6 <argfd>
    return -1;
    80005412:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005414:	02054363          	bltz	a0,8000543a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005418:	fd843503          	ld	a0,-40(s0)
    8000541c:	00000097          	auipc	ra,0x0
    80005420:	e32080e7          	jalr	-462(ra) # 8000524e <fdalloc>
    80005424:	84aa                	mv	s1,a0
    return -1;
    80005426:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005428:	00054963          	bltz	a0,8000543a <sys_dup+0x42>
  filedup(f);
    8000542c:	fd843503          	ld	a0,-40(s0)
    80005430:	fffff097          	auipc	ra,0xfffff
    80005434:	32a080e7          	jalr	810(ra) # 8000475a <filedup>
  return fd;
    80005438:	87a6                	mv	a5,s1
}
    8000543a:	853e                	mv	a0,a5
    8000543c:	70a2                	ld	ra,40(sp)
    8000543e:	7402                	ld	s0,32(sp)
    80005440:	64e2                	ld	s1,24(sp)
    80005442:	6145                	addi	sp,sp,48
    80005444:	8082                	ret

0000000080005446 <sys_read>:
{
    80005446:	7179                	addi	sp,sp,-48
    80005448:	f406                	sd	ra,40(sp)
    8000544a:	f022                	sd	s0,32(sp)
    8000544c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000544e:	fe840613          	addi	a2,s0,-24
    80005452:	4581                	li	a1,0
    80005454:	4501                	li	a0,0
    80005456:	00000097          	auipc	ra,0x0
    8000545a:	d90080e7          	jalr	-624(ra) # 800051e6 <argfd>
    return -1;
    8000545e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005460:	04054163          	bltz	a0,800054a2 <sys_read+0x5c>
    80005464:	fe440593          	addi	a1,s0,-28
    80005468:	4509                	li	a0,2
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	93e080e7          	jalr	-1730(ra) # 80002da8 <argint>
    return -1;
    80005472:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005474:	02054763          	bltz	a0,800054a2 <sys_read+0x5c>
    80005478:	fd840593          	addi	a1,s0,-40
    8000547c:	4505                	li	a0,1
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	94c080e7          	jalr	-1716(ra) # 80002dca <argaddr>
    return -1;
    80005486:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005488:	00054d63          	bltz	a0,800054a2 <sys_read+0x5c>
  return fileread(f, p, n);
    8000548c:	fe442603          	lw	a2,-28(s0)
    80005490:	fd843583          	ld	a1,-40(s0)
    80005494:	fe843503          	ld	a0,-24(s0)
    80005498:	fffff097          	auipc	ra,0xfffff
    8000549c:	44e080e7          	jalr	1102(ra) # 800048e6 <fileread>
    800054a0:	87aa                	mv	a5,a0
}
    800054a2:	853e                	mv	a0,a5
    800054a4:	70a2                	ld	ra,40(sp)
    800054a6:	7402                	ld	s0,32(sp)
    800054a8:	6145                	addi	sp,sp,48
    800054aa:	8082                	ret

00000000800054ac <sys_write>:
{
    800054ac:	7179                	addi	sp,sp,-48
    800054ae:	f406                	sd	ra,40(sp)
    800054b0:	f022                	sd	s0,32(sp)
    800054b2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054b4:	fe840613          	addi	a2,s0,-24
    800054b8:	4581                	li	a1,0
    800054ba:	4501                	li	a0,0
    800054bc:	00000097          	auipc	ra,0x0
    800054c0:	d2a080e7          	jalr	-726(ra) # 800051e6 <argfd>
    return -1;
    800054c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c6:	04054163          	bltz	a0,80005508 <sys_write+0x5c>
    800054ca:	fe440593          	addi	a1,s0,-28
    800054ce:	4509                	li	a0,2
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	8d8080e7          	jalr	-1832(ra) # 80002da8 <argint>
    return -1;
    800054d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054da:	02054763          	bltz	a0,80005508 <sys_write+0x5c>
    800054de:	fd840593          	addi	a1,s0,-40
    800054e2:	4505                	li	a0,1
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	8e6080e7          	jalr	-1818(ra) # 80002dca <argaddr>
    return -1;
    800054ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ee:	00054d63          	bltz	a0,80005508 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054f2:	fe442603          	lw	a2,-28(s0)
    800054f6:	fd843583          	ld	a1,-40(s0)
    800054fa:	fe843503          	ld	a0,-24(s0)
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	4aa080e7          	jalr	1194(ra) # 800049a8 <filewrite>
    80005506:	87aa                	mv	a5,a0
}
    80005508:	853e                	mv	a0,a5
    8000550a:	70a2                	ld	ra,40(sp)
    8000550c:	7402                	ld	s0,32(sp)
    8000550e:	6145                	addi	sp,sp,48
    80005510:	8082                	ret

0000000080005512 <sys_close>:
{
    80005512:	1101                	addi	sp,sp,-32
    80005514:	ec06                	sd	ra,24(sp)
    80005516:	e822                	sd	s0,16(sp)
    80005518:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000551a:	fe040613          	addi	a2,s0,-32
    8000551e:	fec40593          	addi	a1,s0,-20
    80005522:	4501                	li	a0,0
    80005524:	00000097          	auipc	ra,0x0
    80005528:	cc2080e7          	jalr	-830(ra) # 800051e6 <argfd>
    return -1;
    8000552c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000552e:	02054463          	bltz	a0,80005556 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005532:	ffffc097          	auipc	ra,0xffffc
    80005536:	794080e7          	jalr	1940(ra) # 80001cc6 <myproc>
    8000553a:	fec42783          	lw	a5,-20(s0)
    8000553e:	07e9                	addi	a5,a5,26
    80005540:	078e                	slli	a5,a5,0x3
    80005542:	97aa                	add	a5,a5,a0
    80005544:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005548:	fe043503          	ld	a0,-32(s0)
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	260080e7          	jalr	608(ra) # 800047ac <fileclose>
  return 0;
    80005554:	4781                	li	a5,0
}
    80005556:	853e                	mv	a0,a5
    80005558:	60e2                	ld	ra,24(sp)
    8000555a:	6442                	ld	s0,16(sp)
    8000555c:	6105                	addi	sp,sp,32
    8000555e:	8082                	ret

0000000080005560 <sys_fstat>:
{
    80005560:	1101                	addi	sp,sp,-32
    80005562:	ec06                	sd	ra,24(sp)
    80005564:	e822                	sd	s0,16(sp)
    80005566:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005568:	fe840613          	addi	a2,s0,-24
    8000556c:	4581                	li	a1,0
    8000556e:	4501                	li	a0,0
    80005570:	00000097          	auipc	ra,0x0
    80005574:	c76080e7          	jalr	-906(ra) # 800051e6 <argfd>
    return -1;
    80005578:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000557a:	02054563          	bltz	a0,800055a4 <sys_fstat+0x44>
    8000557e:	fe040593          	addi	a1,s0,-32
    80005582:	4505                	li	a0,1
    80005584:	ffffe097          	auipc	ra,0xffffe
    80005588:	846080e7          	jalr	-1978(ra) # 80002dca <argaddr>
    return -1;
    8000558c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000558e:	00054b63          	bltz	a0,800055a4 <sys_fstat+0x44>
  return filestat(f, st);
    80005592:	fe043583          	ld	a1,-32(s0)
    80005596:	fe843503          	ld	a0,-24(s0)
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	2da080e7          	jalr	730(ra) # 80004874 <filestat>
    800055a2:	87aa                	mv	a5,a0
}
    800055a4:	853e                	mv	a0,a5
    800055a6:	60e2                	ld	ra,24(sp)
    800055a8:	6442                	ld	s0,16(sp)
    800055aa:	6105                	addi	sp,sp,32
    800055ac:	8082                	ret

00000000800055ae <sys_link>:
{
    800055ae:	7169                	addi	sp,sp,-304
    800055b0:	f606                	sd	ra,296(sp)
    800055b2:	f222                	sd	s0,288(sp)
    800055b4:	ee26                	sd	s1,280(sp)
    800055b6:	ea4a                	sd	s2,272(sp)
    800055b8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ba:	08000613          	li	a2,128
    800055be:	ed040593          	addi	a1,s0,-304
    800055c2:	4501                	li	a0,0
    800055c4:	ffffe097          	auipc	ra,0xffffe
    800055c8:	828080e7          	jalr	-2008(ra) # 80002dec <argstr>
    return -1;
    800055cc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ce:	10054e63          	bltz	a0,800056ea <sys_link+0x13c>
    800055d2:	08000613          	li	a2,128
    800055d6:	f5040593          	addi	a1,s0,-176
    800055da:	4505                	li	a0,1
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	810080e7          	jalr	-2032(ra) # 80002dec <argstr>
    return -1;
    800055e4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055e6:	10054263          	bltz	a0,800056ea <sys_link+0x13c>
  begin_op();
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	cf0080e7          	jalr	-784(ra) # 800042da <begin_op>
  if((ip = namei(old)) == 0){
    800055f2:	ed040513          	addi	a0,s0,-304
    800055f6:	fffff097          	auipc	ra,0xfffff
    800055fa:	ad8080e7          	jalr	-1320(ra) # 800040ce <namei>
    800055fe:	84aa                	mv	s1,a0
    80005600:	c551                	beqz	a0,8000568c <sys_link+0xde>
  ilock(ip);
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	318080e7          	jalr	792(ra) # 8000391a <ilock>
  if(ip->type == T_DIR){
    8000560a:	04449703          	lh	a4,68(s1)
    8000560e:	4785                	li	a5,1
    80005610:	08f70463          	beq	a4,a5,80005698 <sys_link+0xea>
  ip->nlink++;
    80005614:	04a4d783          	lhu	a5,74(s1)
    80005618:	2785                	addiw	a5,a5,1
    8000561a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000561e:	8526                	mv	a0,s1
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	230080e7          	jalr	560(ra) # 80003850 <iupdate>
  iunlock(ip);
    80005628:	8526                	mv	a0,s1
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	3b2080e7          	jalr	946(ra) # 800039dc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005632:	fd040593          	addi	a1,s0,-48
    80005636:	f5040513          	addi	a0,s0,-176
    8000563a:	fffff097          	auipc	ra,0xfffff
    8000563e:	ab2080e7          	jalr	-1358(ra) # 800040ec <nameiparent>
    80005642:	892a                	mv	s2,a0
    80005644:	c935                	beqz	a0,800056b8 <sys_link+0x10a>
  ilock(dp);
    80005646:	ffffe097          	auipc	ra,0xffffe
    8000564a:	2d4080e7          	jalr	724(ra) # 8000391a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000564e:	00092703          	lw	a4,0(s2)
    80005652:	409c                	lw	a5,0(s1)
    80005654:	04f71d63          	bne	a4,a5,800056ae <sys_link+0x100>
    80005658:	40d0                	lw	a2,4(s1)
    8000565a:	fd040593          	addi	a1,s0,-48
    8000565e:	854a                	mv	a0,s2
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	9ac080e7          	jalr	-1620(ra) # 8000400c <dirlink>
    80005668:	04054363          	bltz	a0,800056ae <sys_link+0x100>
  iunlockput(dp);
    8000566c:	854a                	mv	a0,s2
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	50e080e7          	jalr	1294(ra) # 80003b7c <iunlockput>
  iput(ip);
    80005676:	8526                	mv	a0,s1
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	45c080e7          	jalr	1116(ra) # 80003ad4 <iput>
  end_op();
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	cda080e7          	jalr	-806(ra) # 8000435a <end_op>
  return 0;
    80005688:	4781                	li	a5,0
    8000568a:	a085                	j	800056ea <sys_link+0x13c>
    end_op();
    8000568c:	fffff097          	auipc	ra,0xfffff
    80005690:	cce080e7          	jalr	-818(ra) # 8000435a <end_op>
    return -1;
    80005694:	57fd                	li	a5,-1
    80005696:	a891                	j	800056ea <sys_link+0x13c>
    iunlockput(ip);
    80005698:	8526                	mv	a0,s1
    8000569a:	ffffe097          	auipc	ra,0xffffe
    8000569e:	4e2080e7          	jalr	1250(ra) # 80003b7c <iunlockput>
    end_op();
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	cb8080e7          	jalr	-840(ra) # 8000435a <end_op>
    return -1;
    800056aa:	57fd                	li	a5,-1
    800056ac:	a83d                	j	800056ea <sys_link+0x13c>
    iunlockput(dp);
    800056ae:	854a                	mv	a0,s2
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	4cc080e7          	jalr	1228(ra) # 80003b7c <iunlockput>
  ilock(ip);
    800056b8:	8526                	mv	a0,s1
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	260080e7          	jalr	608(ra) # 8000391a <ilock>
  ip->nlink--;
    800056c2:	04a4d783          	lhu	a5,74(s1)
    800056c6:	37fd                	addiw	a5,a5,-1
    800056c8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056cc:	8526                	mv	a0,s1
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	182080e7          	jalr	386(ra) # 80003850 <iupdate>
  iunlockput(ip);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	4a4080e7          	jalr	1188(ra) # 80003b7c <iunlockput>
  end_op();
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	c7a080e7          	jalr	-902(ra) # 8000435a <end_op>
  return -1;
    800056e8:	57fd                	li	a5,-1
}
    800056ea:	853e                	mv	a0,a5
    800056ec:	70b2                	ld	ra,296(sp)
    800056ee:	7412                	ld	s0,288(sp)
    800056f0:	64f2                	ld	s1,280(sp)
    800056f2:	6952                	ld	s2,272(sp)
    800056f4:	6155                	addi	sp,sp,304
    800056f6:	8082                	ret

00000000800056f8 <sys_unlink>:
{
    800056f8:	7151                	addi	sp,sp,-240
    800056fa:	f586                	sd	ra,232(sp)
    800056fc:	f1a2                	sd	s0,224(sp)
    800056fe:	eda6                	sd	s1,216(sp)
    80005700:	e9ca                	sd	s2,208(sp)
    80005702:	e5ce                	sd	s3,200(sp)
    80005704:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005706:	08000613          	li	a2,128
    8000570a:	f3040593          	addi	a1,s0,-208
    8000570e:	4501                	li	a0,0
    80005710:	ffffd097          	auipc	ra,0xffffd
    80005714:	6dc080e7          	jalr	1756(ra) # 80002dec <argstr>
    80005718:	18054163          	bltz	a0,8000589a <sys_unlink+0x1a2>
  begin_op();
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	bbe080e7          	jalr	-1090(ra) # 800042da <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005724:	fb040593          	addi	a1,s0,-80
    80005728:	f3040513          	addi	a0,s0,-208
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	9c0080e7          	jalr	-1600(ra) # 800040ec <nameiparent>
    80005734:	84aa                	mv	s1,a0
    80005736:	c979                	beqz	a0,8000580c <sys_unlink+0x114>
  ilock(dp);
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	1e2080e7          	jalr	482(ra) # 8000391a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005740:	00003597          	auipc	a1,0x3
    80005744:	fb058593          	addi	a1,a1,-80 # 800086f0 <syscalls+0x2c0>
    80005748:	fb040513          	addi	a0,s0,-80
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	696080e7          	jalr	1686(ra) # 80003de2 <namecmp>
    80005754:	14050a63          	beqz	a0,800058a8 <sys_unlink+0x1b0>
    80005758:	00003597          	auipc	a1,0x3
    8000575c:	fa058593          	addi	a1,a1,-96 # 800086f8 <syscalls+0x2c8>
    80005760:	fb040513          	addi	a0,s0,-80
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	67e080e7          	jalr	1662(ra) # 80003de2 <namecmp>
    8000576c:	12050e63          	beqz	a0,800058a8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005770:	f2c40613          	addi	a2,s0,-212
    80005774:	fb040593          	addi	a1,s0,-80
    80005778:	8526                	mv	a0,s1
    8000577a:	ffffe097          	auipc	ra,0xffffe
    8000577e:	682080e7          	jalr	1666(ra) # 80003dfc <dirlookup>
    80005782:	892a                	mv	s2,a0
    80005784:	12050263          	beqz	a0,800058a8 <sys_unlink+0x1b0>
  ilock(ip);
    80005788:	ffffe097          	auipc	ra,0xffffe
    8000578c:	192080e7          	jalr	402(ra) # 8000391a <ilock>
  if(ip->nlink < 1)
    80005790:	04a91783          	lh	a5,74(s2)
    80005794:	08f05263          	blez	a5,80005818 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005798:	04491703          	lh	a4,68(s2)
    8000579c:	4785                	li	a5,1
    8000579e:	08f70563          	beq	a4,a5,80005828 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057a2:	4641                	li	a2,16
    800057a4:	4581                	li	a1,0
    800057a6:	fc040513          	addi	a0,s0,-64
    800057aa:	ffffb097          	auipc	ra,0xffffb
    800057ae:	72c080e7          	jalr	1836(ra) # 80000ed6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057b2:	4741                	li	a4,16
    800057b4:	f2c42683          	lw	a3,-212(s0)
    800057b8:	fc040613          	addi	a2,s0,-64
    800057bc:	4581                	li	a1,0
    800057be:	8526                	mv	a0,s1
    800057c0:	ffffe097          	auipc	ra,0xffffe
    800057c4:	506080e7          	jalr	1286(ra) # 80003cc6 <writei>
    800057c8:	47c1                	li	a5,16
    800057ca:	0af51563          	bne	a0,a5,80005874 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057ce:	04491703          	lh	a4,68(s2)
    800057d2:	4785                	li	a5,1
    800057d4:	0af70863          	beq	a4,a5,80005884 <sys_unlink+0x18c>
  iunlockput(dp);
    800057d8:	8526                	mv	a0,s1
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	3a2080e7          	jalr	930(ra) # 80003b7c <iunlockput>
  ip->nlink--;
    800057e2:	04a95783          	lhu	a5,74(s2)
    800057e6:	37fd                	addiw	a5,a5,-1
    800057e8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057ec:	854a                	mv	a0,s2
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	062080e7          	jalr	98(ra) # 80003850 <iupdate>
  iunlockput(ip);
    800057f6:	854a                	mv	a0,s2
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	384080e7          	jalr	900(ra) # 80003b7c <iunlockput>
  end_op();
    80005800:	fffff097          	auipc	ra,0xfffff
    80005804:	b5a080e7          	jalr	-1190(ra) # 8000435a <end_op>
  return 0;
    80005808:	4501                	li	a0,0
    8000580a:	a84d                	j	800058bc <sys_unlink+0x1c4>
    end_op();
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	b4e080e7          	jalr	-1202(ra) # 8000435a <end_op>
    return -1;
    80005814:	557d                	li	a0,-1
    80005816:	a05d                	j	800058bc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005818:	00003517          	auipc	a0,0x3
    8000581c:	f0850513          	addi	a0,a0,-248 # 80008720 <syscalls+0x2f0>
    80005820:	ffffb097          	auipc	ra,0xffffb
    80005824:	d28080e7          	jalr	-728(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005828:	04c92703          	lw	a4,76(s2)
    8000582c:	02000793          	li	a5,32
    80005830:	f6e7f9e3          	bgeu	a5,a4,800057a2 <sys_unlink+0xaa>
    80005834:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005838:	4741                	li	a4,16
    8000583a:	86ce                	mv	a3,s3
    8000583c:	f1840613          	addi	a2,s0,-232
    80005840:	4581                	li	a1,0
    80005842:	854a                	mv	a0,s2
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	38a080e7          	jalr	906(ra) # 80003bce <readi>
    8000584c:	47c1                	li	a5,16
    8000584e:	00f51b63          	bne	a0,a5,80005864 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005852:	f1845783          	lhu	a5,-232(s0)
    80005856:	e7a1                	bnez	a5,8000589e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005858:	29c1                	addiw	s3,s3,16
    8000585a:	04c92783          	lw	a5,76(s2)
    8000585e:	fcf9ede3          	bltu	s3,a5,80005838 <sys_unlink+0x140>
    80005862:	b781                	j	800057a2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005864:	00003517          	auipc	a0,0x3
    80005868:	ed450513          	addi	a0,a0,-300 # 80008738 <syscalls+0x308>
    8000586c:	ffffb097          	auipc	ra,0xffffb
    80005870:	cdc080e7          	jalr	-804(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005874:	00003517          	auipc	a0,0x3
    80005878:	edc50513          	addi	a0,a0,-292 # 80008750 <syscalls+0x320>
    8000587c:	ffffb097          	auipc	ra,0xffffb
    80005880:	ccc080e7          	jalr	-820(ra) # 80000548 <panic>
    dp->nlink--;
    80005884:	04a4d783          	lhu	a5,74(s1)
    80005888:	37fd                	addiw	a5,a5,-1
    8000588a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000588e:	8526                	mv	a0,s1
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	fc0080e7          	jalr	-64(ra) # 80003850 <iupdate>
    80005898:	b781                	j	800057d8 <sys_unlink+0xe0>
    return -1;
    8000589a:	557d                	li	a0,-1
    8000589c:	a005                	j	800058bc <sys_unlink+0x1c4>
    iunlockput(ip);
    8000589e:	854a                	mv	a0,s2
    800058a0:	ffffe097          	auipc	ra,0xffffe
    800058a4:	2dc080e7          	jalr	732(ra) # 80003b7c <iunlockput>
  iunlockput(dp);
    800058a8:	8526                	mv	a0,s1
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	2d2080e7          	jalr	722(ra) # 80003b7c <iunlockput>
  end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	aa8080e7          	jalr	-1368(ra) # 8000435a <end_op>
  return -1;
    800058ba:	557d                	li	a0,-1
}
    800058bc:	70ae                	ld	ra,232(sp)
    800058be:	740e                	ld	s0,224(sp)
    800058c0:	64ee                	ld	s1,216(sp)
    800058c2:	694e                	ld	s2,208(sp)
    800058c4:	69ae                	ld	s3,200(sp)
    800058c6:	616d                	addi	sp,sp,240
    800058c8:	8082                	ret

00000000800058ca <sys_open>:

uint64
sys_open(void)
{
    800058ca:	7131                	addi	sp,sp,-192
    800058cc:	fd06                	sd	ra,184(sp)
    800058ce:	f922                	sd	s0,176(sp)
    800058d0:	f526                	sd	s1,168(sp)
    800058d2:	f14a                	sd	s2,160(sp)
    800058d4:	ed4e                	sd	s3,152(sp)
    800058d6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058d8:	08000613          	li	a2,128
    800058dc:	f5040593          	addi	a1,s0,-176
    800058e0:	4501                	li	a0,0
    800058e2:	ffffd097          	auipc	ra,0xffffd
    800058e6:	50a080e7          	jalr	1290(ra) # 80002dec <argstr>
    return -1;
    800058ea:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058ec:	0c054163          	bltz	a0,800059ae <sys_open+0xe4>
    800058f0:	f4c40593          	addi	a1,s0,-180
    800058f4:	4505                	li	a0,1
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	4b2080e7          	jalr	1202(ra) # 80002da8 <argint>
    800058fe:	0a054863          	bltz	a0,800059ae <sys_open+0xe4>

  begin_op();
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	9d8080e7          	jalr	-1576(ra) # 800042da <begin_op>

  if(omode & O_CREATE){
    8000590a:	f4c42783          	lw	a5,-180(s0)
    8000590e:	2007f793          	andi	a5,a5,512
    80005912:	cbdd                	beqz	a5,800059c8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005914:	4681                	li	a3,0
    80005916:	4601                	li	a2,0
    80005918:	4589                	li	a1,2
    8000591a:	f5040513          	addi	a0,s0,-176
    8000591e:	00000097          	auipc	ra,0x0
    80005922:	972080e7          	jalr	-1678(ra) # 80005290 <create>
    80005926:	892a                	mv	s2,a0
    if(ip == 0){
    80005928:	c959                	beqz	a0,800059be <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000592a:	04491703          	lh	a4,68(s2)
    8000592e:	478d                	li	a5,3
    80005930:	00f71763          	bne	a4,a5,8000593e <sys_open+0x74>
    80005934:	04695703          	lhu	a4,70(s2)
    80005938:	47a5                	li	a5,9
    8000593a:	0ce7ec63          	bltu	a5,a4,80005a12 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000593e:	fffff097          	auipc	ra,0xfffff
    80005942:	db2080e7          	jalr	-590(ra) # 800046f0 <filealloc>
    80005946:	89aa                	mv	s3,a0
    80005948:	10050263          	beqz	a0,80005a4c <sys_open+0x182>
    8000594c:	00000097          	auipc	ra,0x0
    80005950:	902080e7          	jalr	-1790(ra) # 8000524e <fdalloc>
    80005954:	84aa                	mv	s1,a0
    80005956:	0e054663          	bltz	a0,80005a42 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000595a:	04491703          	lh	a4,68(s2)
    8000595e:	478d                	li	a5,3
    80005960:	0cf70463          	beq	a4,a5,80005a28 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005964:	4789                	li	a5,2
    80005966:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000596a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000596e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005972:	f4c42783          	lw	a5,-180(s0)
    80005976:	0017c713          	xori	a4,a5,1
    8000597a:	8b05                	andi	a4,a4,1
    8000597c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005980:	0037f713          	andi	a4,a5,3
    80005984:	00e03733          	snez	a4,a4
    80005988:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000598c:	4007f793          	andi	a5,a5,1024
    80005990:	c791                	beqz	a5,8000599c <sys_open+0xd2>
    80005992:	04491703          	lh	a4,68(s2)
    80005996:	4789                	li	a5,2
    80005998:	08f70f63          	beq	a4,a5,80005a36 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000599c:	854a                	mv	a0,s2
    8000599e:	ffffe097          	auipc	ra,0xffffe
    800059a2:	03e080e7          	jalr	62(ra) # 800039dc <iunlock>
  end_op();
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	9b4080e7          	jalr	-1612(ra) # 8000435a <end_op>

  return fd;
}
    800059ae:	8526                	mv	a0,s1
    800059b0:	70ea                	ld	ra,184(sp)
    800059b2:	744a                	ld	s0,176(sp)
    800059b4:	74aa                	ld	s1,168(sp)
    800059b6:	790a                	ld	s2,160(sp)
    800059b8:	69ea                	ld	s3,152(sp)
    800059ba:	6129                	addi	sp,sp,192
    800059bc:	8082                	ret
      end_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	99c080e7          	jalr	-1636(ra) # 8000435a <end_op>
      return -1;
    800059c6:	b7e5                	j	800059ae <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059c8:	f5040513          	addi	a0,s0,-176
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	702080e7          	jalr	1794(ra) # 800040ce <namei>
    800059d4:	892a                	mv	s2,a0
    800059d6:	c905                	beqz	a0,80005a06 <sys_open+0x13c>
    ilock(ip);
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	f42080e7          	jalr	-190(ra) # 8000391a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059e0:	04491703          	lh	a4,68(s2)
    800059e4:	4785                	li	a5,1
    800059e6:	f4f712e3          	bne	a4,a5,8000592a <sys_open+0x60>
    800059ea:	f4c42783          	lw	a5,-180(s0)
    800059ee:	dba1                	beqz	a5,8000593e <sys_open+0x74>
      iunlockput(ip);
    800059f0:	854a                	mv	a0,s2
    800059f2:	ffffe097          	auipc	ra,0xffffe
    800059f6:	18a080e7          	jalr	394(ra) # 80003b7c <iunlockput>
      end_op();
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	960080e7          	jalr	-1696(ra) # 8000435a <end_op>
      return -1;
    80005a02:	54fd                	li	s1,-1
    80005a04:	b76d                	j	800059ae <sys_open+0xe4>
      end_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	954080e7          	jalr	-1708(ra) # 8000435a <end_op>
      return -1;
    80005a0e:	54fd                	li	s1,-1
    80005a10:	bf79                	j	800059ae <sys_open+0xe4>
    iunlockput(ip);
    80005a12:	854a                	mv	a0,s2
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	168080e7          	jalr	360(ra) # 80003b7c <iunlockput>
    end_op();
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	93e080e7          	jalr	-1730(ra) # 8000435a <end_op>
    return -1;
    80005a24:	54fd                	li	s1,-1
    80005a26:	b761                	j	800059ae <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a28:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a2c:	04691783          	lh	a5,70(s2)
    80005a30:	02f99223          	sh	a5,36(s3)
    80005a34:	bf2d                	j	8000596e <sys_open+0xa4>
    itrunc(ip);
    80005a36:	854a                	mv	a0,s2
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	ff0080e7          	jalr	-16(ra) # 80003a28 <itrunc>
    80005a40:	bfb1                	j	8000599c <sys_open+0xd2>
      fileclose(f);
    80005a42:	854e                	mv	a0,s3
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	d68080e7          	jalr	-664(ra) # 800047ac <fileclose>
    iunlockput(ip);
    80005a4c:	854a                	mv	a0,s2
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	12e080e7          	jalr	302(ra) # 80003b7c <iunlockput>
    end_op();
    80005a56:	fffff097          	auipc	ra,0xfffff
    80005a5a:	904080e7          	jalr	-1788(ra) # 8000435a <end_op>
    return -1;
    80005a5e:	54fd                	li	s1,-1
    80005a60:	b7b9                	j	800059ae <sys_open+0xe4>

0000000080005a62 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a62:	7175                	addi	sp,sp,-144
    80005a64:	e506                	sd	ra,136(sp)
    80005a66:	e122                	sd	s0,128(sp)
    80005a68:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	870080e7          	jalr	-1936(ra) # 800042da <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a72:	08000613          	li	a2,128
    80005a76:	f7040593          	addi	a1,s0,-144
    80005a7a:	4501                	li	a0,0
    80005a7c:	ffffd097          	auipc	ra,0xffffd
    80005a80:	370080e7          	jalr	880(ra) # 80002dec <argstr>
    80005a84:	02054963          	bltz	a0,80005ab6 <sys_mkdir+0x54>
    80005a88:	4681                	li	a3,0
    80005a8a:	4601                	li	a2,0
    80005a8c:	4585                	li	a1,1
    80005a8e:	f7040513          	addi	a0,s0,-144
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	7fe080e7          	jalr	2046(ra) # 80005290 <create>
    80005a9a:	cd11                	beqz	a0,80005ab6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	0e0080e7          	jalr	224(ra) # 80003b7c <iunlockput>
  end_op();
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	8b6080e7          	jalr	-1866(ra) # 8000435a <end_op>
  return 0;
    80005aac:	4501                	li	a0,0
}
    80005aae:	60aa                	ld	ra,136(sp)
    80005ab0:	640a                	ld	s0,128(sp)
    80005ab2:	6149                	addi	sp,sp,144
    80005ab4:	8082                	ret
    end_op();
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	8a4080e7          	jalr	-1884(ra) # 8000435a <end_op>
    return -1;
    80005abe:	557d                	li	a0,-1
    80005ac0:	b7fd                	j	80005aae <sys_mkdir+0x4c>

0000000080005ac2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ac2:	7135                	addi	sp,sp,-160
    80005ac4:	ed06                	sd	ra,152(sp)
    80005ac6:	e922                	sd	s0,144(sp)
    80005ac8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	810080e7          	jalr	-2032(ra) # 800042da <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ad2:	08000613          	li	a2,128
    80005ad6:	f7040593          	addi	a1,s0,-144
    80005ada:	4501                	li	a0,0
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	310080e7          	jalr	784(ra) # 80002dec <argstr>
    80005ae4:	04054a63          	bltz	a0,80005b38 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005ae8:	f6c40593          	addi	a1,s0,-148
    80005aec:	4505                	li	a0,1
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	2ba080e7          	jalr	698(ra) # 80002da8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005af6:	04054163          	bltz	a0,80005b38 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005afa:	f6840593          	addi	a1,s0,-152
    80005afe:	4509                	li	a0,2
    80005b00:	ffffd097          	auipc	ra,0xffffd
    80005b04:	2a8080e7          	jalr	680(ra) # 80002da8 <argint>
     argint(1, &major) < 0 ||
    80005b08:	02054863          	bltz	a0,80005b38 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b0c:	f6841683          	lh	a3,-152(s0)
    80005b10:	f6c41603          	lh	a2,-148(s0)
    80005b14:	458d                	li	a1,3
    80005b16:	f7040513          	addi	a0,s0,-144
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	776080e7          	jalr	1910(ra) # 80005290 <create>
     argint(2, &minor) < 0 ||
    80005b22:	c919                	beqz	a0,80005b38 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	058080e7          	jalr	88(ra) # 80003b7c <iunlockput>
  end_op();
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	82e080e7          	jalr	-2002(ra) # 8000435a <end_op>
  return 0;
    80005b34:	4501                	li	a0,0
    80005b36:	a031                	j	80005b42 <sys_mknod+0x80>
    end_op();
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	822080e7          	jalr	-2014(ra) # 8000435a <end_op>
    return -1;
    80005b40:	557d                	li	a0,-1
}
    80005b42:	60ea                	ld	ra,152(sp)
    80005b44:	644a                	ld	s0,144(sp)
    80005b46:	610d                	addi	sp,sp,160
    80005b48:	8082                	ret

0000000080005b4a <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b4a:	7135                	addi	sp,sp,-160
    80005b4c:	ed06                	sd	ra,152(sp)
    80005b4e:	e922                	sd	s0,144(sp)
    80005b50:	e526                	sd	s1,136(sp)
    80005b52:	e14a                	sd	s2,128(sp)
    80005b54:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b56:	ffffc097          	auipc	ra,0xffffc
    80005b5a:	170080e7          	jalr	368(ra) # 80001cc6 <myproc>
    80005b5e:	892a                	mv	s2,a0
  
  begin_op();
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	77a080e7          	jalr	1914(ra) # 800042da <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b68:	08000613          	li	a2,128
    80005b6c:	f6040593          	addi	a1,s0,-160
    80005b70:	4501                	li	a0,0
    80005b72:	ffffd097          	auipc	ra,0xffffd
    80005b76:	27a080e7          	jalr	634(ra) # 80002dec <argstr>
    80005b7a:	04054b63          	bltz	a0,80005bd0 <sys_chdir+0x86>
    80005b7e:	f6040513          	addi	a0,s0,-160
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	54c080e7          	jalr	1356(ra) # 800040ce <namei>
    80005b8a:	84aa                	mv	s1,a0
    80005b8c:	c131                	beqz	a0,80005bd0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	d8c080e7          	jalr	-628(ra) # 8000391a <ilock>
  if(ip->type != T_DIR){
    80005b96:	04449703          	lh	a4,68(s1)
    80005b9a:	4785                	li	a5,1
    80005b9c:	04f71063          	bne	a4,a5,80005bdc <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ba0:	8526                	mv	a0,s1
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	e3a080e7          	jalr	-454(ra) # 800039dc <iunlock>
  iput(p->cwd);
    80005baa:	15093503          	ld	a0,336(s2)
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	f26080e7          	jalr	-218(ra) # 80003ad4 <iput>
  end_op();
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	7a4080e7          	jalr	1956(ra) # 8000435a <end_op>
  p->cwd = ip;
    80005bbe:	14993823          	sd	s1,336(s2)
  return 0;
    80005bc2:	4501                	li	a0,0
}
    80005bc4:	60ea                	ld	ra,152(sp)
    80005bc6:	644a                	ld	s0,144(sp)
    80005bc8:	64aa                	ld	s1,136(sp)
    80005bca:	690a                	ld	s2,128(sp)
    80005bcc:	610d                	addi	sp,sp,160
    80005bce:	8082                	ret
    end_op();
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	78a080e7          	jalr	1930(ra) # 8000435a <end_op>
    return -1;
    80005bd8:	557d                	li	a0,-1
    80005bda:	b7ed                	j	80005bc4 <sys_chdir+0x7a>
    iunlockput(ip);
    80005bdc:	8526                	mv	a0,s1
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	f9e080e7          	jalr	-98(ra) # 80003b7c <iunlockput>
    end_op();
    80005be6:	ffffe097          	auipc	ra,0xffffe
    80005bea:	774080e7          	jalr	1908(ra) # 8000435a <end_op>
    return -1;
    80005bee:	557d                	li	a0,-1
    80005bf0:	bfd1                	j	80005bc4 <sys_chdir+0x7a>

0000000080005bf2 <sys_exec>:

uint64
sys_exec(void)
{
    80005bf2:	7145                	addi	sp,sp,-464
    80005bf4:	e786                	sd	ra,456(sp)
    80005bf6:	e3a2                	sd	s0,448(sp)
    80005bf8:	ff26                	sd	s1,440(sp)
    80005bfa:	fb4a                	sd	s2,432(sp)
    80005bfc:	f74e                	sd	s3,424(sp)
    80005bfe:	f352                	sd	s4,416(sp)
    80005c00:	ef56                	sd	s5,408(sp)
    80005c02:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c04:	08000613          	li	a2,128
    80005c08:	f4040593          	addi	a1,s0,-192
    80005c0c:	4501                	li	a0,0
    80005c0e:	ffffd097          	auipc	ra,0xffffd
    80005c12:	1de080e7          	jalr	478(ra) # 80002dec <argstr>
    return -1;
    80005c16:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c18:	0c054a63          	bltz	a0,80005cec <sys_exec+0xfa>
    80005c1c:	e3840593          	addi	a1,s0,-456
    80005c20:	4505                	li	a0,1
    80005c22:	ffffd097          	auipc	ra,0xffffd
    80005c26:	1a8080e7          	jalr	424(ra) # 80002dca <argaddr>
    80005c2a:	0c054163          	bltz	a0,80005cec <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c2e:	10000613          	li	a2,256
    80005c32:	4581                	li	a1,0
    80005c34:	e4040513          	addi	a0,s0,-448
    80005c38:	ffffb097          	auipc	ra,0xffffb
    80005c3c:	29e080e7          	jalr	670(ra) # 80000ed6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c40:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c44:	89a6                	mv	s3,s1
    80005c46:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c48:	02000a13          	li	s4,32
    80005c4c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c50:	00391513          	slli	a0,s2,0x3
    80005c54:	e3040593          	addi	a1,s0,-464
    80005c58:	e3843783          	ld	a5,-456(s0)
    80005c5c:	953e                	add	a0,a0,a5
    80005c5e:	ffffd097          	auipc	ra,0xffffd
    80005c62:	0b0080e7          	jalr	176(ra) # 80002d0e <fetchaddr>
    80005c66:	02054a63          	bltz	a0,80005c9a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c6a:	e3043783          	ld	a5,-464(s0)
    80005c6e:	c3b9                	beqz	a5,80005cb4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c70:	ffffb097          	auipc	ra,0xffffb
    80005c74:	ff4080e7          	jalr	-12(ra) # 80000c64 <kalloc>
    80005c78:	85aa                	mv	a1,a0
    80005c7a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c7e:	cd11                	beqz	a0,80005c9a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c80:	6605                	lui	a2,0x1
    80005c82:	e3043503          	ld	a0,-464(s0)
    80005c86:	ffffd097          	auipc	ra,0xffffd
    80005c8a:	0da080e7          	jalr	218(ra) # 80002d60 <fetchstr>
    80005c8e:	00054663          	bltz	a0,80005c9a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c92:	0905                	addi	s2,s2,1
    80005c94:	09a1                	addi	s3,s3,8
    80005c96:	fb491be3          	bne	s2,s4,80005c4c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c9a:	10048913          	addi	s2,s1,256
    80005c9e:	6088                	ld	a0,0(s1)
    80005ca0:	c529                	beqz	a0,80005cea <sys_exec+0xf8>
    kfree(argv[i]);
    80005ca2:	ffffb097          	auipc	ra,0xffffb
    80005ca6:	e5c080e7          	jalr	-420(ra) # 80000afe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005caa:	04a1                	addi	s1,s1,8
    80005cac:	ff2499e3          	bne	s1,s2,80005c9e <sys_exec+0xac>
  return -1;
    80005cb0:	597d                	li	s2,-1
    80005cb2:	a82d                	j	80005cec <sys_exec+0xfa>
      argv[i] = 0;
    80005cb4:	0a8e                	slli	s5,s5,0x3
    80005cb6:	fc040793          	addi	a5,s0,-64
    80005cba:	9abe                	add	s5,s5,a5
    80005cbc:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005cc0:	e4040593          	addi	a1,s0,-448
    80005cc4:	f4040513          	addi	a0,s0,-192
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	194080e7          	jalr	404(ra) # 80004e5c <exec>
    80005cd0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cd2:	10048993          	addi	s3,s1,256
    80005cd6:	6088                	ld	a0,0(s1)
    80005cd8:	c911                	beqz	a0,80005cec <sys_exec+0xfa>
    kfree(argv[i]);
    80005cda:	ffffb097          	auipc	ra,0xffffb
    80005cde:	e24080e7          	jalr	-476(ra) # 80000afe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce2:	04a1                	addi	s1,s1,8
    80005ce4:	ff3499e3          	bne	s1,s3,80005cd6 <sys_exec+0xe4>
    80005ce8:	a011                	j	80005cec <sys_exec+0xfa>
  return -1;
    80005cea:	597d                	li	s2,-1
}
    80005cec:	854a                	mv	a0,s2
    80005cee:	60be                	ld	ra,456(sp)
    80005cf0:	641e                	ld	s0,448(sp)
    80005cf2:	74fa                	ld	s1,440(sp)
    80005cf4:	795a                	ld	s2,432(sp)
    80005cf6:	79ba                	ld	s3,424(sp)
    80005cf8:	7a1a                	ld	s4,416(sp)
    80005cfa:	6afa                	ld	s5,408(sp)
    80005cfc:	6179                	addi	sp,sp,464
    80005cfe:	8082                	ret

0000000080005d00 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d00:	7139                	addi	sp,sp,-64
    80005d02:	fc06                	sd	ra,56(sp)
    80005d04:	f822                	sd	s0,48(sp)
    80005d06:	f426                	sd	s1,40(sp)
    80005d08:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d0a:	ffffc097          	auipc	ra,0xffffc
    80005d0e:	fbc080e7          	jalr	-68(ra) # 80001cc6 <myproc>
    80005d12:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d14:	fd840593          	addi	a1,s0,-40
    80005d18:	4501                	li	a0,0
    80005d1a:	ffffd097          	auipc	ra,0xffffd
    80005d1e:	0b0080e7          	jalr	176(ra) # 80002dca <argaddr>
    return -1;
    80005d22:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d24:	0e054063          	bltz	a0,80005e04 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d28:	fc840593          	addi	a1,s0,-56
    80005d2c:	fd040513          	addi	a0,s0,-48
    80005d30:	fffff097          	auipc	ra,0xfffff
    80005d34:	dd2080e7          	jalr	-558(ra) # 80004b02 <pipealloc>
    return -1;
    80005d38:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d3a:	0c054563          	bltz	a0,80005e04 <sys_pipe+0x104>
  fd0 = -1;
    80005d3e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d42:	fd043503          	ld	a0,-48(s0)
    80005d46:	fffff097          	auipc	ra,0xfffff
    80005d4a:	508080e7          	jalr	1288(ra) # 8000524e <fdalloc>
    80005d4e:	fca42223          	sw	a0,-60(s0)
    80005d52:	08054c63          	bltz	a0,80005dea <sys_pipe+0xea>
    80005d56:	fc843503          	ld	a0,-56(s0)
    80005d5a:	fffff097          	auipc	ra,0xfffff
    80005d5e:	4f4080e7          	jalr	1268(ra) # 8000524e <fdalloc>
    80005d62:	fca42023          	sw	a0,-64(s0)
    80005d66:	06054863          	bltz	a0,80005dd6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d6a:	4691                	li	a3,4
    80005d6c:	fc440613          	addi	a2,s0,-60
    80005d70:	fd843583          	ld	a1,-40(s0)
    80005d74:	68a8                	ld	a0,80(s1)
    80005d76:	ffffc097          	auipc	ra,0xffffc
    80005d7a:	d42080e7          	jalr	-702(ra) # 80001ab8 <copyout>
    80005d7e:	02054063          	bltz	a0,80005d9e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d82:	4691                	li	a3,4
    80005d84:	fc040613          	addi	a2,s0,-64
    80005d88:	fd843583          	ld	a1,-40(s0)
    80005d8c:	0591                	addi	a1,a1,4
    80005d8e:	68a8                	ld	a0,80(s1)
    80005d90:	ffffc097          	auipc	ra,0xffffc
    80005d94:	d28080e7          	jalr	-728(ra) # 80001ab8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d98:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d9a:	06055563          	bgez	a0,80005e04 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d9e:	fc442783          	lw	a5,-60(s0)
    80005da2:	07e9                	addi	a5,a5,26
    80005da4:	078e                	slli	a5,a5,0x3
    80005da6:	97a6                	add	a5,a5,s1
    80005da8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005dac:	fc042503          	lw	a0,-64(s0)
    80005db0:	0569                	addi	a0,a0,26
    80005db2:	050e                	slli	a0,a0,0x3
    80005db4:	9526                	add	a0,a0,s1
    80005db6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005dba:	fd043503          	ld	a0,-48(s0)
    80005dbe:	fffff097          	auipc	ra,0xfffff
    80005dc2:	9ee080e7          	jalr	-1554(ra) # 800047ac <fileclose>
    fileclose(wf);
    80005dc6:	fc843503          	ld	a0,-56(s0)
    80005dca:	fffff097          	auipc	ra,0xfffff
    80005dce:	9e2080e7          	jalr	-1566(ra) # 800047ac <fileclose>
    return -1;
    80005dd2:	57fd                	li	a5,-1
    80005dd4:	a805                	j	80005e04 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005dd6:	fc442783          	lw	a5,-60(s0)
    80005dda:	0007c863          	bltz	a5,80005dea <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005dde:	01a78513          	addi	a0,a5,26
    80005de2:	050e                	slli	a0,a0,0x3
    80005de4:	9526                	add	a0,a0,s1
    80005de6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005dea:	fd043503          	ld	a0,-48(s0)
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	9be080e7          	jalr	-1602(ra) # 800047ac <fileclose>
    fileclose(wf);
    80005df6:	fc843503          	ld	a0,-56(s0)
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	9b2080e7          	jalr	-1614(ra) # 800047ac <fileclose>
    return -1;
    80005e02:	57fd                	li	a5,-1
}
    80005e04:	853e                	mv	a0,a5
    80005e06:	70e2                	ld	ra,56(sp)
    80005e08:	7442                	ld	s0,48(sp)
    80005e0a:	74a2                	ld	s1,40(sp)
    80005e0c:	6121                	addi	sp,sp,64
    80005e0e:	8082                	ret

0000000080005e10 <kernelvec>:
    80005e10:	7111                	addi	sp,sp,-256
    80005e12:	e006                	sd	ra,0(sp)
    80005e14:	e40a                	sd	sp,8(sp)
    80005e16:	e80e                	sd	gp,16(sp)
    80005e18:	ec12                	sd	tp,24(sp)
    80005e1a:	f016                	sd	t0,32(sp)
    80005e1c:	f41a                	sd	t1,40(sp)
    80005e1e:	f81e                	sd	t2,48(sp)
    80005e20:	fc22                	sd	s0,56(sp)
    80005e22:	e0a6                	sd	s1,64(sp)
    80005e24:	e4aa                	sd	a0,72(sp)
    80005e26:	e8ae                	sd	a1,80(sp)
    80005e28:	ecb2                	sd	a2,88(sp)
    80005e2a:	f0b6                	sd	a3,96(sp)
    80005e2c:	f4ba                	sd	a4,104(sp)
    80005e2e:	f8be                	sd	a5,112(sp)
    80005e30:	fcc2                	sd	a6,120(sp)
    80005e32:	e146                	sd	a7,128(sp)
    80005e34:	e54a                	sd	s2,136(sp)
    80005e36:	e94e                	sd	s3,144(sp)
    80005e38:	ed52                	sd	s4,152(sp)
    80005e3a:	f156                	sd	s5,160(sp)
    80005e3c:	f55a                	sd	s6,168(sp)
    80005e3e:	f95e                	sd	s7,176(sp)
    80005e40:	fd62                	sd	s8,184(sp)
    80005e42:	e1e6                	sd	s9,192(sp)
    80005e44:	e5ea                	sd	s10,200(sp)
    80005e46:	e9ee                	sd	s11,208(sp)
    80005e48:	edf2                	sd	t3,216(sp)
    80005e4a:	f1f6                	sd	t4,224(sp)
    80005e4c:	f5fa                	sd	t5,232(sp)
    80005e4e:	f9fe                	sd	t6,240(sp)
    80005e50:	d8bfc0ef          	jal	ra,80002bda <kerneltrap>
    80005e54:	6082                	ld	ra,0(sp)
    80005e56:	6122                	ld	sp,8(sp)
    80005e58:	61c2                	ld	gp,16(sp)
    80005e5a:	7282                	ld	t0,32(sp)
    80005e5c:	7322                	ld	t1,40(sp)
    80005e5e:	73c2                	ld	t2,48(sp)
    80005e60:	7462                	ld	s0,56(sp)
    80005e62:	6486                	ld	s1,64(sp)
    80005e64:	6526                	ld	a0,72(sp)
    80005e66:	65c6                	ld	a1,80(sp)
    80005e68:	6666                	ld	a2,88(sp)
    80005e6a:	7686                	ld	a3,96(sp)
    80005e6c:	7726                	ld	a4,104(sp)
    80005e6e:	77c6                	ld	a5,112(sp)
    80005e70:	7866                	ld	a6,120(sp)
    80005e72:	688a                	ld	a7,128(sp)
    80005e74:	692a                	ld	s2,136(sp)
    80005e76:	69ca                	ld	s3,144(sp)
    80005e78:	6a6a                	ld	s4,152(sp)
    80005e7a:	7a8a                	ld	s5,160(sp)
    80005e7c:	7b2a                	ld	s6,168(sp)
    80005e7e:	7bca                	ld	s7,176(sp)
    80005e80:	7c6a                	ld	s8,184(sp)
    80005e82:	6c8e                	ld	s9,192(sp)
    80005e84:	6d2e                	ld	s10,200(sp)
    80005e86:	6dce                	ld	s11,208(sp)
    80005e88:	6e6e                	ld	t3,216(sp)
    80005e8a:	7e8e                	ld	t4,224(sp)
    80005e8c:	7f2e                	ld	t5,232(sp)
    80005e8e:	7fce                	ld	t6,240(sp)
    80005e90:	6111                	addi	sp,sp,256
    80005e92:	10200073          	sret
    80005e96:	00000013          	nop
    80005e9a:	00000013          	nop
    80005e9e:	0001                	nop

0000000080005ea0 <timervec>:
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	e10c                	sd	a1,0(a0)
    80005ea6:	e510                	sd	a2,8(a0)
    80005ea8:	e914                	sd	a3,16(a0)
    80005eaa:	710c                	ld	a1,32(a0)
    80005eac:	7510                	ld	a2,40(a0)
    80005eae:	6194                	ld	a3,0(a1)
    80005eb0:	96b2                	add	a3,a3,a2
    80005eb2:	e194                	sd	a3,0(a1)
    80005eb4:	4589                	li	a1,2
    80005eb6:	14459073          	csrw	sip,a1
    80005eba:	6914                	ld	a3,16(a0)
    80005ebc:	6510                	ld	a2,8(a0)
    80005ebe:	610c                	ld	a1,0(a0)
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	30200073          	mret
	...

0000000080005eca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eca:	1141                	addi	sp,sp,-16
    80005ecc:	e422                	sd	s0,8(sp)
    80005ece:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ed0:	0c0007b7          	lui	a5,0xc000
    80005ed4:	4705                	li	a4,1
    80005ed6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ed8:	c3d8                	sw	a4,4(a5)
}
    80005eda:	6422                	ld	s0,8(sp)
    80005edc:	0141                	addi	sp,sp,16
    80005ede:	8082                	ret

0000000080005ee0 <plicinithart>:

void
plicinithart(void)
{
    80005ee0:	1141                	addi	sp,sp,-16
    80005ee2:	e406                	sd	ra,8(sp)
    80005ee4:	e022                	sd	s0,0(sp)
    80005ee6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ee8:	ffffc097          	auipc	ra,0xffffc
    80005eec:	db2080e7          	jalr	-590(ra) # 80001c9a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ef0:	0085171b          	slliw	a4,a0,0x8
    80005ef4:	0c0027b7          	lui	a5,0xc002
    80005ef8:	97ba                	add	a5,a5,a4
    80005efa:	40200713          	li	a4,1026
    80005efe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f02:	00d5151b          	slliw	a0,a0,0xd
    80005f06:	0c2017b7          	lui	a5,0xc201
    80005f0a:	953e                	add	a0,a0,a5
    80005f0c:	00052023          	sw	zero,0(a0)
}
    80005f10:	60a2                	ld	ra,8(sp)
    80005f12:	6402                	ld	s0,0(sp)
    80005f14:	0141                	addi	sp,sp,16
    80005f16:	8082                	ret

0000000080005f18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f18:	1141                	addi	sp,sp,-16
    80005f1a:	e406                	sd	ra,8(sp)
    80005f1c:	e022                	sd	s0,0(sp)
    80005f1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f20:	ffffc097          	auipc	ra,0xffffc
    80005f24:	d7a080e7          	jalr	-646(ra) # 80001c9a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f28:	00d5179b          	slliw	a5,a0,0xd
    80005f2c:	0c201537          	lui	a0,0xc201
    80005f30:	953e                	add	a0,a0,a5
  return irq;
}
    80005f32:	4148                	lw	a0,4(a0)
    80005f34:	60a2                	ld	ra,8(sp)
    80005f36:	6402                	ld	s0,0(sp)
    80005f38:	0141                	addi	sp,sp,16
    80005f3a:	8082                	ret

0000000080005f3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f3c:	1101                	addi	sp,sp,-32
    80005f3e:	ec06                	sd	ra,24(sp)
    80005f40:	e822                	sd	s0,16(sp)
    80005f42:	e426                	sd	s1,8(sp)
    80005f44:	1000                	addi	s0,sp,32
    80005f46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f48:	ffffc097          	auipc	ra,0xffffc
    80005f4c:	d52080e7          	jalr	-686(ra) # 80001c9a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f50:	00d5151b          	slliw	a0,a0,0xd
    80005f54:	0c2017b7          	lui	a5,0xc201
    80005f58:	97aa                	add	a5,a5,a0
    80005f5a:	c3c4                	sw	s1,4(a5)
}
    80005f5c:	60e2                	ld	ra,24(sp)
    80005f5e:	6442                	ld	s0,16(sp)
    80005f60:	64a2                	ld	s1,8(sp)
    80005f62:	6105                	addi	sp,sp,32
    80005f64:	8082                	ret

0000000080005f66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f66:	1141                	addi	sp,sp,-16
    80005f68:	e406                	sd	ra,8(sp)
    80005f6a:	e022                	sd	s0,0(sp)
    80005f6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f6e:	479d                	li	a5,7
    80005f70:	04a7cc63          	blt	a5,a0,80005fc8 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f74:	0003d797          	auipc	a5,0x3d
    80005f78:	08c78793          	addi	a5,a5,140 # 80043000 <disk>
    80005f7c:	00a78733          	add	a4,a5,a0
    80005f80:	6789                	lui	a5,0x2
    80005f82:	97ba                	add	a5,a5,a4
    80005f84:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f88:	eba1                	bnez	a5,80005fd8 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f8a:	00451713          	slli	a4,a0,0x4
    80005f8e:	0003f797          	auipc	a5,0x3f
    80005f92:	0727b783          	ld	a5,114(a5) # 80045000 <disk+0x2000>
    80005f96:	97ba                	add	a5,a5,a4
    80005f98:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f9c:	0003d797          	auipc	a5,0x3d
    80005fa0:	06478793          	addi	a5,a5,100 # 80043000 <disk>
    80005fa4:	97aa                	add	a5,a5,a0
    80005fa6:	6509                	lui	a0,0x2
    80005fa8:	953e                	add	a0,a0,a5
    80005faa:	4785                	li	a5,1
    80005fac:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005fb0:	0003f517          	auipc	a0,0x3f
    80005fb4:	06850513          	addi	a0,a0,104 # 80045018 <disk+0x2018>
    80005fb8:	ffffc097          	auipc	ra,0xffffc
    80005fbc:	6a4080e7          	jalr	1700(ra) # 8000265c <wakeup>
}
    80005fc0:	60a2                	ld	ra,8(sp)
    80005fc2:	6402                	ld	s0,0(sp)
    80005fc4:	0141                	addi	sp,sp,16
    80005fc6:	8082                	ret
    panic("virtio_disk_intr 1");
    80005fc8:	00002517          	auipc	a0,0x2
    80005fcc:	79850513          	addi	a0,a0,1944 # 80008760 <syscalls+0x330>
    80005fd0:	ffffa097          	auipc	ra,0xffffa
    80005fd4:	578080e7          	jalr	1400(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005fd8:	00002517          	auipc	a0,0x2
    80005fdc:	7a050513          	addi	a0,a0,1952 # 80008778 <syscalls+0x348>
    80005fe0:	ffffa097          	auipc	ra,0xffffa
    80005fe4:	568080e7          	jalr	1384(ra) # 80000548 <panic>

0000000080005fe8 <virtio_disk_init>:
{
    80005fe8:	1101                	addi	sp,sp,-32
    80005fea:	ec06                	sd	ra,24(sp)
    80005fec:	e822                	sd	s0,16(sp)
    80005fee:	e426                	sd	s1,8(sp)
    80005ff0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ff2:	00002597          	auipc	a1,0x2
    80005ff6:	79e58593          	addi	a1,a1,1950 # 80008790 <syscalls+0x360>
    80005ffa:	0003f517          	auipc	a0,0x3f
    80005ffe:	0ae50513          	addi	a0,a0,174 # 800450a8 <disk+0x20a8>
    80006002:	ffffb097          	auipc	ra,0xffffb
    80006006:	d48080e7          	jalr	-696(ra) # 80000d4a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000600a:	100017b7          	lui	a5,0x10001
    8000600e:	4398                	lw	a4,0(a5)
    80006010:	2701                	sext.w	a4,a4
    80006012:	747277b7          	lui	a5,0x74727
    80006016:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000601a:	0ef71163          	bne	a4,a5,800060fc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000601e:	100017b7          	lui	a5,0x10001
    80006022:	43dc                	lw	a5,4(a5)
    80006024:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006026:	4705                	li	a4,1
    80006028:	0ce79a63          	bne	a5,a4,800060fc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000602c:	100017b7          	lui	a5,0x10001
    80006030:	479c                	lw	a5,8(a5)
    80006032:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006034:	4709                	li	a4,2
    80006036:	0ce79363          	bne	a5,a4,800060fc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000603a:	100017b7          	lui	a5,0x10001
    8000603e:	47d8                	lw	a4,12(a5)
    80006040:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006042:	554d47b7          	lui	a5,0x554d4
    80006046:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000604a:	0af71963          	bne	a4,a5,800060fc <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604e:	100017b7          	lui	a5,0x10001
    80006052:	4705                	li	a4,1
    80006054:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006056:	470d                	li	a4,3
    80006058:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000605a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000605c:	c7ffe737          	lui	a4,0xc7ffe
    80006060:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb875f>
    80006064:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006066:	2701                	sext.w	a4,a4
    80006068:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000606a:	472d                	li	a4,11
    8000606c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000606e:	473d                	li	a4,15
    80006070:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006072:	6705                	lui	a4,0x1
    80006074:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006076:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000607a:	5bdc                	lw	a5,52(a5)
    8000607c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000607e:	c7d9                	beqz	a5,8000610c <virtio_disk_init+0x124>
  if(max < NUM)
    80006080:	471d                	li	a4,7
    80006082:	08f77d63          	bgeu	a4,a5,8000611c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006086:	100014b7          	lui	s1,0x10001
    8000608a:	47a1                	li	a5,8
    8000608c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000608e:	6609                	lui	a2,0x2
    80006090:	4581                	li	a1,0
    80006092:	0003d517          	auipc	a0,0x3d
    80006096:	f6e50513          	addi	a0,a0,-146 # 80043000 <disk>
    8000609a:	ffffb097          	auipc	ra,0xffffb
    8000609e:	e3c080e7          	jalr	-452(ra) # 80000ed6 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800060a2:	0003d717          	auipc	a4,0x3d
    800060a6:	f5e70713          	addi	a4,a4,-162 # 80043000 <disk>
    800060aa:	00c75793          	srli	a5,a4,0xc
    800060ae:	2781                	sext.w	a5,a5
    800060b0:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    800060b2:	0003f797          	auipc	a5,0x3f
    800060b6:	f4e78793          	addi	a5,a5,-178 # 80045000 <disk+0x2000>
    800060ba:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    800060bc:	0003d717          	auipc	a4,0x3d
    800060c0:	fc470713          	addi	a4,a4,-60 # 80043080 <disk+0x80>
    800060c4:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800060c6:	0003e717          	auipc	a4,0x3e
    800060ca:	f3a70713          	addi	a4,a4,-198 # 80044000 <disk+0x1000>
    800060ce:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800060d0:	4705                	li	a4,1
    800060d2:	00e78c23          	sb	a4,24(a5)
    800060d6:	00e78ca3          	sb	a4,25(a5)
    800060da:	00e78d23          	sb	a4,26(a5)
    800060de:	00e78da3          	sb	a4,27(a5)
    800060e2:	00e78e23          	sb	a4,28(a5)
    800060e6:	00e78ea3          	sb	a4,29(a5)
    800060ea:	00e78f23          	sb	a4,30(a5)
    800060ee:	00e78fa3          	sb	a4,31(a5)
}
    800060f2:	60e2                	ld	ra,24(sp)
    800060f4:	6442                	ld	s0,16(sp)
    800060f6:	64a2                	ld	s1,8(sp)
    800060f8:	6105                	addi	sp,sp,32
    800060fa:	8082                	ret
    panic("could not find virtio disk");
    800060fc:	00002517          	auipc	a0,0x2
    80006100:	6a450513          	addi	a0,a0,1700 # 800087a0 <syscalls+0x370>
    80006104:	ffffa097          	auipc	ra,0xffffa
    80006108:	444080e7          	jalr	1092(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    8000610c:	00002517          	auipc	a0,0x2
    80006110:	6b450513          	addi	a0,a0,1716 # 800087c0 <syscalls+0x390>
    80006114:	ffffa097          	auipc	ra,0xffffa
    80006118:	434080e7          	jalr	1076(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    8000611c:	00002517          	auipc	a0,0x2
    80006120:	6c450513          	addi	a0,a0,1732 # 800087e0 <syscalls+0x3b0>
    80006124:	ffffa097          	auipc	ra,0xffffa
    80006128:	424080e7          	jalr	1060(ra) # 80000548 <panic>

000000008000612c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000612c:	7119                	addi	sp,sp,-128
    8000612e:	fc86                	sd	ra,120(sp)
    80006130:	f8a2                	sd	s0,112(sp)
    80006132:	f4a6                	sd	s1,104(sp)
    80006134:	f0ca                	sd	s2,96(sp)
    80006136:	ecce                	sd	s3,88(sp)
    80006138:	e8d2                	sd	s4,80(sp)
    8000613a:	e4d6                	sd	s5,72(sp)
    8000613c:	e0da                	sd	s6,64(sp)
    8000613e:	fc5e                	sd	s7,56(sp)
    80006140:	f862                	sd	s8,48(sp)
    80006142:	f466                	sd	s9,40(sp)
    80006144:	f06a                	sd	s10,32(sp)
    80006146:	0100                	addi	s0,sp,128
    80006148:	892a                	mv	s2,a0
    8000614a:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000614c:	00c52c83          	lw	s9,12(a0)
    80006150:	001c9c9b          	slliw	s9,s9,0x1
    80006154:	1c82                	slli	s9,s9,0x20
    80006156:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000615a:	0003f517          	auipc	a0,0x3f
    8000615e:	f4e50513          	addi	a0,a0,-178 # 800450a8 <disk+0x20a8>
    80006162:	ffffb097          	auipc	ra,0xffffb
    80006166:	c78080e7          	jalr	-904(ra) # 80000dda <acquire>
  for(int i = 0; i < 3; i++){
    8000616a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000616c:	4c21                	li	s8,8
      disk.free[i] = 0;
    8000616e:	0003db97          	auipc	s7,0x3d
    80006172:	e92b8b93          	addi	s7,s7,-366 # 80043000 <disk>
    80006176:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006178:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    8000617a:	8a4e                	mv	s4,s3
    8000617c:	a051                	j	80006200 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    8000617e:	00fb86b3          	add	a3,s7,a5
    80006182:	96da                	add	a3,a3,s6
    80006184:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006188:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000618a:	0207c563          	bltz	a5,800061b4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000618e:	2485                	addiw	s1,s1,1
    80006190:	0711                	addi	a4,a4,4
    80006192:	23548d63          	beq	s1,s5,800063cc <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80006196:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006198:	0003f697          	auipc	a3,0x3f
    8000619c:	e8068693          	addi	a3,a3,-384 # 80045018 <disk+0x2018>
    800061a0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800061a2:	0006c583          	lbu	a1,0(a3)
    800061a6:	fde1                	bnez	a1,8000617e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800061a8:	2785                	addiw	a5,a5,1
    800061aa:	0685                	addi	a3,a3,1
    800061ac:	ff879be3          	bne	a5,s8,800061a2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800061b0:	57fd                	li	a5,-1
    800061b2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800061b4:	02905a63          	blez	s1,800061e8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800061b8:	f9042503          	lw	a0,-112(s0)
    800061bc:	00000097          	auipc	ra,0x0
    800061c0:	daa080e7          	jalr	-598(ra) # 80005f66 <free_desc>
      for(int j = 0; j < i; j++)
    800061c4:	4785                	li	a5,1
    800061c6:	0297d163          	bge	a5,s1,800061e8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800061ca:	f9442503          	lw	a0,-108(s0)
    800061ce:	00000097          	auipc	ra,0x0
    800061d2:	d98080e7          	jalr	-616(ra) # 80005f66 <free_desc>
      for(int j = 0; j < i; j++)
    800061d6:	4789                	li	a5,2
    800061d8:	0097d863          	bge	a5,s1,800061e8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800061dc:	f9842503          	lw	a0,-104(s0)
    800061e0:	00000097          	auipc	ra,0x0
    800061e4:	d86080e7          	jalr	-634(ra) # 80005f66 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061e8:	0003f597          	auipc	a1,0x3f
    800061ec:	ec058593          	addi	a1,a1,-320 # 800450a8 <disk+0x20a8>
    800061f0:	0003f517          	auipc	a0,0x3f
    800061f4:	e2850513          	addi	a0,a0,-472 # 80045018 <disk+0x2018>
    800061f8:	ffffc097          	auipc	ra,0xffffc
    800061fc:	2de080e7          	jalr	734(ra) # 800024d6 <sleep>
  for(int i = 0; i < 3; i++){
    80006200:	f9040713          	addi	a4,s0,-112
    80006204:	84ce                	mv	s1,s3
    80006206:	bf41                	j	80006196 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006208:	4785                	li	a5,1
    8000620a:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000620e:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80006212:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006216:	f9042983          	lw	s3,-112(s0)
    8000621a:	00499493          	slli	s1,s3,0x4
    8000621e:	0003fa17          	auipc	s4,0x3f
    80006222:	de2a0a13          	addi	s4,s4,-542 # 80045000 <disk+0x2000>
    80006226:	000a3a83          	ld	s5,0(s4)
    8000622a:	9aa6                	add	s5,s5,s1
    8000622c:	f8040513          	addi	a0,s0,-128
    80006230:	ffffb097          	auipc	ra,0xffffb
    80006234:	07a080e7          	jalr	122(ra) # 800012aa <kvmpa>
    80006238:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000623c:	000a3783          	ld	a5,0(s4)
    80006240:	97a6                	add	a5,a5,s1
    80006242:	4741                	li	a4,16
    80006244:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006246:	000a3783          	ld	a5,0(s4)
    8000624a:	97a6                	add	a5,a5,s1
    8000624c:	4705                	li	a4,1
    8000624e:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006252:	f9442703          	lw	a4,-108(s0)
    80006256:	000a3783          	ld	a5,0(s4)
    8000625a:	97a6                	add	a5,a5,s1
    8000625c:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006260:	0712                	slli	a4,a4,0x4
    80006262:	000a3783          	ld	a5,0(s4)
    80006266:	97ba                	add	a5,a5,a4
    80006268:	05890693          	addi	a3,s2,88
    8000626c:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000626e:	000a3783          	ld	a5,0(s4)
    80006272:	97ba                	add	a5,a5,a4
    80006274:	40000693          	li	a3,1024
    80006278:	c794                	sw	a3,8(a5)
  if(write)
    8000627a:	100d0a63          	beqz	s10,8000638e <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000627e:	0003f797          	auipc	a5,0x3f
    80006282:	d827b783          	ld	a5,-638(a5) # 80045000 <disk+0x2000>
    80006286:	97ba                	add	a5,a5,a4
    80006288:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000628c:	0003d517          	auipc	a0,0x3d
    80006290:	d7450513          	addi	a0,a0,-652 # 80043000 <disk>
    80006294:	0003f797          	auipc	a5,0x3f
    80006298:	d6c78793          	addi	a5,a5,-660 # 80045000 <disk+0x2000>
    8000629c:	6394                	ld	a3,0(a5)
    8000629e:	96ba                	add	a3,a3,a4
    800062a0:	00c6d603          	lhu	a2,12(a3)
    800062a4:	00166613          	ori	a2,a2,1
    800062a8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800062ac:	f9842683          	lw	a3,-104(s0)
    800062b0:	6390                	ld	a2,0(a5)
    800062b2:	9732                	add	a4,a4,a2
    800062b4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    800062b8:	20098613          	addi	a2,s3,512
    800062bc:	0612                	slli	a2,a2,0x4
    800062be:	962a                	add	a2,a2,a0
    800062c0:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062c4:	00469713          	slli	a4,a3,0x4
    800062c8:	6394                	ld	a3,0(a5)
    800062ca:	96ba                	add	a3,a3,a4
    800062cc:	6589                	lui	a1,0x2
    800062ce:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    800062d2:	94ae                	add	s1,s1,a1
    800062d4:	94aa                	add	s1,s1,a0
    800062d6:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    800062d8:	6394                	ld	a3,0(a5)
    800062da:	96ba                	add	a3,a3,a4
    800062dc:	4585                	li	a1,1
    800062de:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062e0:	6394                	ld	a3,0(a5)
    800062e2:	96ba                	add	a3,a3,a4
    800062e4:	4509                	li	a0,2
    800062e6:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800062ea:	6394                	ld	a3,0(a5)
    800062ec:	9736                	add	a4,a4,a3
    800062ee:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062f2:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062f6:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800062fa:	6794                	ld	a3,8(a5)
    800062fc:	0026d703          	lhu	a4,2(a3)
    80006300:	8b1d                	andi	a4,a4,7
    80006302:	2709                	addiw	a4,a4,2
    80006304:	0706                	slli	a4,a4,0x1
    80006306:	9736                	add	a4,a4,a3
    80006308:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    8000630c:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006310:	6798                	ld	a4,8(a5)
    80006312:	00275783          	lhu	a5,2(a4)
    80006316:	2785                	addiw	a5,a5,1
    80006318:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000631c:	100017b7          	lui	a5,0x10001
    80006320:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006324:	00492703          	lw	a4,4(s2)
    80006328:	4785                	li	a5,1
    8000632a:	02f71163          	bne	a4,a5,8000634c <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    8000632e:	0003f997          	auipc	s3,0x3f
    80006332:	d7a98993          	addi	s3,s3,-646 # 800450a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006336:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006338:	85ce                	mv	a1,s3
    8000633a:	854a                	mv	a0,s2
    8000633c:	ffffc097          	auipc	ra,0xffffc
    80006340:	19a080e7          	jalr	410(ra) # 800024d6 <sleep>
  while(b->disk == 1) {
    80006344:	00492783          	lw	a5,4(s2)
    80006348:	fe9788e3          	beq	a5,s1,80006338 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    8000634c:	f9042483          	lw	s1,-112(s0)
    80006350:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80006354:	00479713          	slli	a4,a5,0x4
    80006358:	0003d797          	auipc	a5,0x3d
    8000635c:	ca878793          	addi	a5,a5,-856 # 80043000 <disk>
    80006360:	97ba                	add	a5,a5,a4
    80006362:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006366:	0003f917          	auipc	s2,0x3f
    8000636a:	c9a90913          	addi	s2,s2,-870 # 80045000 <disk+0x2000>
    free_desc(i);
    8000636e:	8526                	mv	a0,s1
    80006370:	00000097          	auipc	ra,0x0
    80006374:	bf6080e7          	jalr	-1034(ra) # 80005f66 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006378:	0492                	slli	s1,s1,0x4
    8000637a:	00093783          	ld	a5,0(s2)
    8000637e:	94be                	add	s1,s1,a5
    80006380:	00c4d783          	lhu	a5,12(s1)
    80006384:	8b85                	andi	a5,a5,1
    80006386:	cf89                	beqz	a5,800063a0 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    80006388:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000638c:	b7cd                	j	8000636e <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000638e:	0003f797          	auipc	a5,0x3f
    80006392:	c727b783          	ld	a5,-910(a5) # 80045000 <disk+0x2000>
    80006396:	97ba                	add	a5,a5,a4
    80006398:	4689                	li	a3,2
    8000639a:	00d79623          	sh	a3,12(a5)
    8000639e:	b5fd                	j	8000628c <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063a0:	0003f517          	auipc	a0,0x3f
    800063a4:	d0850513          	addi	a0,a0,-760 # 800450a8 <disk+0x20a8>
    800063a8:	ffffb097          	auipc	ra,0xffffb
    800063ac:	ae6080e7          	jalr	-1306(ra) # 80000e8e <release>
}
    800063b0:	70e6                	ld	ra,120(sp)
    800063b2:	7446                	ld	s0,112(sp)
    800063b4:	74a6                	ld	s1,104(sp)
    800063b6:	7906                	ld	s2,96(sp)
    800063b8:	69e6                	ld	s3,88(sp)
    800063ba:	6a46                	ld	s4,80(sp)
    800063bc:	6aa6                	ld	s5,72(sp)
    800063be:	6b06                	ld	s6,64(sp)
    800063c0:	7be2                	ld	s7,56(sp)
    800063c2:	7c42                	ld	s8,48(sp)
    800063c4:	7ca2                	ld	s9,40(sp)
    800063c6:	7d02                	ld	s10,32(sp)
    800063c8:	6109                	addi	sp,sp,128
    800063ca:	8082                	ret
  if(write)
    800063cc:	e20d1ee3          	bnez	s10,80006208 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    800063d0:	f8042023          	sw	zero,-128(s0)
    800063d4:	bd2d                	j	8000620e <virtio_disk_rw+0xe2>

00000000800063d6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063d6:	1101                	addi	sp,sp,-32
    800063d8:	ec06                	sd	ra,24(sp)
    800063da:	e822                	sd	s0,16(sp)
    800063dc:	e426                	sd	s1,8(sp)
    800063de:	e04a                	sd	s2,0(sp)
    800063e0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063e2:	0003f517          	auipc	a0,0x3f
    800063e6:	cc650513          	addi	a0,a0,-826 # 800450a8 <disk+0x20a8>
    800063ea:	ffffb097          	auipc	ra,0xffffb
    800063ee:	9f0080e7          	jalr	-1552(ra) # 80000dda <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063f2:	0003f717          	auipc	a4,0x3f
    800063f6:	c0e70713          	addi	a4,a4,-1010 # 80045000 <disk+0x2000>
    800063fa:	02075783          	lhu	a5,32(a4)
    800063fe:	6b18                	ld	a4,16(a4)
    80006400:	00275683          	lhu	a3,2(a4)
    80006404:	8ebd                	xor	a3,a3,a5
    80006406:	8a9d                	andi	a3,a3,7
    80006408:	cab9                	beqz	a3,8000645e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000640a:	0003d917          	auipc	s2,0x3d
    8000640e:	bf690913          	addi	s2,s2,-1034 # 80043000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006412:	0003f497          	auipc	s1,0x3f
    80006416:	bee48493          	addi	s1,s1,-1042 # 80045000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000641a:	078e                	slli	a5,a5,0x3
    8000641c:	97ba                	add	a5,a5,a4
    8000641e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006420:	20078713          	addi	a4,a5,512
    80006424:	0712                	slli	a4,a4,0x4
    80006426:	974a                	add	a4,a4,s2
    80006428:	03074703          	lbu	a4,48(a4)
    8000642c:	ef21                	bnez	a4,80006484 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000642e:	20078793          	addi	a5,a5,512
    80006432:	0792                	slli	a5,a5,0x4
    80006434:	97ca                	add	a5,a5,s2
    80006436:	7798                	ld	a4,40(a5)
    80006438:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000643c:	7788                	ld	a0,40(a5)
    8000643e:	ffffc097          	auipc	ra,0xffffc
    80006442:	21e080e7          	jalr	542(ra) # 8000265c <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006446:	0204d783          	lhu	a5,32(s1)
    8000644a:	2785                	addiw	a5,a5,1
    8000644c:	8b9d                	andi	a5,a5,7
    8000644e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006452:	6898                	ld	a4,16(s1)
    80006454:	00275683          	lhu	a3,2(a4)
    80006458:	8a9d                	andi	a3,a3,7
    8000645a:	fcf690e3          	bne	a3,a5,8000641a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000645e:	10001737          	lui	a4,0x10001
    80006462:	533c                	lw	a5,96(a4)
    80006464:	8b8d                	andi	a5,a5,3
    80006466:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006468:	0003f517          	auipc	a0,0x3f
    8000646c:	c4050513          	addi	a0,a0,-960 # 800450a8 <disk+0x20a8>
    80006470:	ffffb097          	auipc	ra,0xffffb
    80006474:	a1e080e7          	jalr	-1506(ra) # 80000e8e <release>
}
    80006478:	60e2                	ld	ra,24(sp)
    8000647a:	6442                	ld	s0,16(sp)
    8000647c:	64a2                	ld	s1,8(sp)
    8000647e:	6902                	ld	s2,0(sp)
    80006480:	6105                	addi	sp,sp,32
    80006482:	8082                	ret
      panic("virtio_disk_intr status");
    80006484:	00002517          	auipc	a0,0x2
    80006488:	37c50513          	addi	a0,a0,892 # 80008800 <syscalls+0x3d0>
    8000648c:	ffffa097          	auipc	ra,0xffffa
    80006490:	0bc080e7          	jalr	188(ra) # 80000548 <panic>
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
