
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	17010113          	addi	sp,sp,368 # 80009170 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fde70713          	addi	a4,a4,-34 # 80009030 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	0ac78793          	addi	a5,a5,172 # 80006110 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd07d7>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	25278793          	addi	a5,a5,594 # 80001300 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
    80000106:	8a2a                	mv	s4,a0
    80000108:	84ae                	mv	s1,a1
    8000010a:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    8000010c:	00011517          	auipc	a0,0x11
    80000110:	06450513          	addi	a0,a0,100 # 80011170 <cons>
    80000114:	00001097          	auipc	ra,0x1
    80000118:	c5a080e7          	jalr	-934(ra) # 80000d6e <acquire>
  for(i = 0; i < n; i++){
    8000011c:	05305b63          	blez	s3,80000172 <consolewrite+0x7e>
    80000120:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000122:	5afd                	li	s5,-1
    80000124:	4685                	li	a3,1
    80000126:	8626                	mv	a2,s1
    80000128:	85d2                	mv	a1,s4
    8000012a:	fbf40513          	addi	a0,s0,-65
    8000012e:	00002097          	auipc	ra,0x2
    80000132:	750080e7          	jalr	1872(ra) # 8000287e <either_copyin>
    80000136:	01550c63          	beq	a0,s5,8000014e <consolewrite+0x5a>
      break;
    uartputc(c);
    8000013a:	fbf44503          	lbu	a0,-65(s0)
    8000013e:	00000097          	auipc	ra,0x0
    80000142:	7aa080e7          	jalr	1962(ra) # 800008e8 <uartputc>
  for(i = 0; i < n; i++){
    80000146:	2905                	addiw	s2,s2,1
    80000148:	0485                	addi	s1,s1,1
    8000014a:	fd299de3          	bne	s3,s2,80000124 <consolewrite+0x30>
  }
  release(&cons.lock);
    8000014e:	00011517          	auipc	a0,0x11
    80000152:	02250513          	addi	a0,a0,34 # 80011170 <cons>
    80000156:	00001097          	auipc	ra,0x1
    8000015a:	ce8080e7          	jalr	-792(ra) # 80000e3e <release>

  return i;
}
    8000015e:	854a                	mv	a0,s2
    80000160:	60a6                	ld	ra,72(sp)
    80000162:	6406                	ld	s0,64(sp)
    80000164:	74e2                	ld	s1,56(sp)
    80000166:	7942                	ld	s2,48(sp)
    80000168:	79a2                	ld	s3,40(sp)
    8000016a:	7a02                	ld	s4,32(sp)
    8000016c:	6ae2                	ld	s5,24(sp)
    8000016e:	6161                	addi	sp,sp,80
    80000170:	8082                	ret
  for(i = 0; i < n; i++){
    80000172:	4901                	li	s2,0
    80000174:	bfe9                	j	8000014e <consolewrite+0x5a>

0000000080000176 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	7119                	addi	sp,sp,-128
    80000178:	fc86                	sd	ra,120(sp)
    8000017a:	f8a2                	sd	s0,112(sp)
    8000017c:	f4a6                	sd	s1,104(sp)
    8000017e:	f0ca                	sd	s2,96(sp)
    80000180:	ecce                	sd	s3,88(sp)
    80000182:	e8d2                	sd	s4,80(sp)
    80000184:	e4d6                	sd	s5,72(sp)
    80000186:	e0da                	sd	s6,64(sp)
    80000188:	fc5e                	sd	s7,56(sp)
    8000018a:	f862                	sd	s8,48(sp)
    8000018c:	f466                	sd	s9,40(sp)
    8000018e:	f06a                	sd	s10,32(sp)
    80000190:	ec6e                	sd	s11,24(sp)
    80000192:	0100                	addi	s0,sp,128
    80000194:	8b2a                	mv	s6,a0
    80000196:	8aae                	mv	s5,a1
    80000198:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000019a:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000019e:	00011517          	auipc	a0,0x11
    800001a2:	fd250513          	addi	a0,a0,-46 # 80011170 <cons>
    800001a6:	00001097          	auipc	ra,0x1
    800001aa:	bc8080e7          	jalr	-1080(ra) # 80000d6e <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ae:	00011497          	auipc	s1,0x11
    800001b2:	fc248493          	addi	s1,s1,-62 # 80011170 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b6:	89a6                	mv	s3,s1
    800001b8:	00011917          	auipc	s2,0x11
    800001bc:	05890913          	addi	s2,s2,88 # 80011210 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001c0:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c2:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001c4:	4da9                	li	s11,10
  while(n > 0){
    800001c6:	07405863          	blez	s4,80000236 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001ca:	0a04a783          	lw	a5,160(s1)
    800001ce:	0a44a703          	lw	a4,164(s1)
    800001d2:	02f71463          	bne	a4,a5,800001fa <consoleread+0x84>
      if(myproc()->killed){
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	be0080e7          	jalr	-1056(ra) # 80001db6 <myproc>
    800001de:	5d1c                	lw	a5,56(a0)
    800001e0:	e7b5                	bnez	a5,8000024c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001e2:	85ce                	mv	a1,s3
    800001e4:	854a                	mv	a0,s2
    800001e6:	00002097          	auipc	ra,0x2
    800001ea:	3e0080e7          	jalr	992(ra) # 800025c6 <sleep>
    while(cons.r == cons.w){
    800001ee:	0a04a783          	lw	a5,160(s1)
    800001f2:	0a44a703          	lw	a4,164(s1)
    800001f6:	fef700e3          	beq	a4,a5,800001d6 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001fa:	0017871b          	addiw	a4,a5,1
    800001fe:	0ae4a023          	sw	a4,160(s1)
    80000202:	07f7f713          	andi	a4,a5,127
    80000206:	9726                	add	a4,a4,s1
    80000208:	02074703          	lbu	a4,32(a4)
    8000020c:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000210:	079c0663          	beq	s8,s9,8000027c <consoleread+0x106>
    cbuf = c;
    80000214:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000218:	4685                	li	a3,1
    8000021a:	f8f40613          	addi	a2,s0,-113
    8000021e:	85d6                	mv	a1,s5
    80000220:	855a                	mv	a0,s6
    80000222:	00002097          	auipc	ra,0x2
    80000226:	606080e7          	jalr	1542(ra) # 80002828 <either_copyout>
    8000022a:	01a50663          	beq	a0,s10,80000236 <consoleread+0xc0>
    dst++;
    8000022e:	0a85                	addi	s5,s5,1
    --n;
    80000230:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000232:	f9bc1ae3          	bne	s8,s11,800001c6 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	f3a50513          	addi	a0,a0,-198 # 80011170 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	c00080e7          	jalr	-1024(ra) # 80000e3e <release>

  return target - n;
    80000246:	414b853b          	subw	a0,s7,s4
    8000024a:	a811                	j	8000025e <consoleread+0xe8>
        release(&cons.lock);
    8000024c:	00011517          	auipc	a0,0x11
    80000250:	f2450513          	addi	a0,a0,-220 # 80011170 <cons>
    80000254:	00001097          	auipc	ra,0x1
    80000258:	bea080e7          	jalr	-1046(ra) # 80000e3e <release>
        return -1;
    8000025c:	557d                	li	a0,-1
}
    8000025e:	70e6                	ld	ra,120(sp)
    80000260:	7446                	ld	s0,112(sp)
    80000262:	74a6                	ld	s1,104(sp)
    80000264:	7906                	ld	s2,96(sp)
    80000266:	69e6                	ld	s3,88(sp)
    80000268:	6a46                	ld	s4,80(sp)
    8000026a:	6aa6                	ld	s5,72(sp)
    8000026c:	6b06                	ld	s6,64(sp)
    8000026e:	7be2                	ld	s7,56(sp)
    80000270:	7c42                	ld	s8,48(sp)
    80000272:	7ca2                	ld	s9,40(sp)
    80000274:	7d02                	ld	s10,32(sp)
    80000276:	6de2                	ld	s11,24(sp)
    80000278:	6109                	addi	sp,sp,128
    8000027a:	8082                	ret
      if(n < target){
    8000027c:	000a071b          	sext.w	a4,s4
    80000280:	fb777be3          	bgeu	a4,s7,80000236 <consoleread+0xc0>
        cons.r--;
    80000284:	00011717          	auipc	a4,0x11
    80000288:	f8f72623          	sw	a5,-116(a4) # 80011210 <cons+0xa0>
    8000028c:	b76d                	j	80000236 <consoleread+0xc0>

000000008000028e <consputc>:
{
    8000028e:	1141                	addi	sp,sp,-16
    80000290:	e406                	sd	ra,8(sp)
    80000292:	e022                	sd	s0,0(sp)
    80000294:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000296:	10000793          	li	a5,256
    8000029a:	00f50a63          	beq	a0,a5,800002ae <consputc+0x20>
    uartputc_sync(c);
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	564080e7          	jalr	1380(ra) # 80000802 <uartputc_sync>
}
    800002a6:	60a2                	ld	ra,8(sp)
    800002a8:	6402                	ld	s0,0(sp)
    800002aa:	0141                	addi	sp,sp,16
    800002ac:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	552080e7          	jalr	1362(ra) # 80000802 <uartputc_sync>
    800002b8:	02000513          	li	a0,32
    800002bc:	00000097          	auipc	ra,0x0
    800002c0:	546080e7          	jalr	1350(ra) # 80000802 <uartputc_sync>
    800002c4:	4521                	li	a0,8
    800002c6:	00000097          	auipc	ra,0x0
    800002ca:	53c080e7          	jalr	1340(ra) # 80000802 <uartputc_sync>
    800002ce:	bfe1                	j	800002a6 <consputc+0x18>

00000000800002d0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d0:	1101                	addi	sp,sp,-32
    800002d2:	ec06                	sd	ra,24(sp)
    800002d4:	e822                	sd	s0,16(sp)
    800002d6:	e426                	sd	s1,8(sp)
    800002d8:	e04a                	sd	s2,0(sp)
    800002da:	1000                	addi	s0,sp,32
    800002dc:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002de:	00011517          	auipc	a0,0x11
    800002e2:	e9250513          	addi	a0,a0,-366 # 80011170 <cons>
    800002e6:	00001097          	auipc	ra,0x1
    800002ea:	a88080e7          	jalr	-1400(ra) # 80000d6e <acquire>

  switch(c){
    800002ee:	47d5                	li	a5,21
    800002f0:	0af48663          	beq	s1,a5,8000039c <consoleintr+0xcc>
    800002f4:	0297ca63          	blt	a5,s1,80000328 <consoleintr+0x58>
    800002f8:	47a1                	li	a5,8
    800002fa:	0ef48763          	beq	s1,a5,800003e8 <consoleintr+0x118>
    800002fe:	47c1                	li	a5,16
    80000300:	10f49a63          	bne	s1,a5,80000414 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000304:	00002097          	auipc	ra,0x2
    80000308:	5d0080e7          	jalr	1488(ra) # 800028d4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030c:	00011517          	auipc	a0,0x11
    80000310:	e6450513          	addi	a0,a0,-412 # 80011170 <cons>
    80000314:	00001097          	auipc	ra,0x1
    80000318:	b2a080e7          	jalr	-1238(ra) # 80000e3e <release>
}
    8000031c:	60e2                	ld	ra,24(sp)
    8000031e:	6442                	ld	s0,16(sp)
    80000320:	64a2                	ld	s1,8(sp)
    80000322:	6902                	ld	s2,0(sp)
    80000324:	6105                	addi	sp,sp,32
    80000326:	8082                	ret
  switch(c){
    80000328:	07f00793          	li	a5,127
    8000032c:	0af48e63          	beq	s1,a5,800003e8 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000330:	00011717          	auipc	a4,0x11
    80000334:	e4070713          	addi	a4,a4,-448 # 80011170 <cons>
    80000338:	0a872783          	lw	a5,168(a4)
    8000033c:	0a072703          	lw	a4,160(a4)
    80000340:	9f99                	subw	a5,a5,a4
    80000342:	07f00713          	li	a4,127
    80000346:	fcf763e3          	bltu	a4,a5,8000030c <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000034a:	47b5                	li	a5,13
    8000034c:	0cf48763          	beq	s1,a5,8000041a <consoleintr+0x14a>
      consputc(c);
    80000350:	8526                	mv	a0,s1
    80000352:	00000097          	auipc	ra,0x0
    80000356:	f3c080e7          	jalr	-196(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000035a:	00011797          	auipc	a5,0x11
    8000035e:	e1678793          	addi	a5,a5,-490 # 80011170 <cons>
    80000362:	0a87a703          	lw	a4,168(a5)
    80000366:	0017069b          	addiw	a3,a4,1
    8000036a:	0006861b          	sext.w	a2,a3
    8000036e:	0ad7a423          	sw	a3,168(a5)
    80000372:	07f77713          	andi	a4,a4,127
    80000376:	97ba                	add	a5,a5,a4
    80000378:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000037c:	47a9                	li	a5,10
    8000037e:	0cf48563          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000382:	4791                	li	a5,4
    80000384:	0cf48263          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000388:	00011797          	auipc	a5,0x11
    8000038c:	e887a783          	lw	a5,-376(a5) # 80011210 <cons+0xa0>
    80000390:	0807879b          	addiw	a5,a5,128
    80000394:	f6f61ce3          	bne	a2,a5,8000030c <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000398:	863e                	mv	a2,a5
    8000039a:	a07d                	j	80000448 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000039c:	00011717          	auipc	a4,0x11
    800003a0:	dd470713          	addi	a4,a4,-556 # 80011170 <cons>
    800003a4:	0a872783          	lw	a5,168(a4)
    800003a8:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ac:	00011497          	auipc	s1,0x11
    800003b0:	dc448493          	addi	s1,s1,-572 # 80011170 <cons>
    while(cons.e != cons.w &&
    800003b4:	4929                	li	s2,10
    800003b6:	f4f70be3          	beq	a4,a5,8000030c <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ba:	37fd                	addiw	a5,a5,-1
    800003bc:	07f7f713          	andi	a4,a5,127
    800003c0:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c2:	02074703          	lbu	a4,32(a4)
    800003c6:	f52703e3          	beq	a4,s2,8000030c <consoleintr+0x3c>
      cons.e--;
    800003ca:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003ce:	10000513          	li	a0,256
    800003d2:	00000097          	auipc	ra,0x0
    800003d6:	ebc080e7          	jalr	-324(ra) # 8000028e <consputc>
    while(cons.e != cons.w &&
    800003da:	0a84a783          	lw	a5,168(s1)
    800003de:	0a44a703          	lw	a4,164(s1)
    800003e2:	fcf71ce3          	bne	a4,a5,800003ba <consoleintr+0xea>
    800003e6:	b71d                	j	8000030c <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	d8870713          	addi	a4,a4,-632 # 80011170 <cons>
    800003f0:	0a872783          	lw	a5,168(a4)
    800003f4:	0a472703          	lw	a4,164(a4)
    800003f8:	f0f70ae3          	beq	a4,a5,8000030c <consoleintr+0x3c>
      cons.e--;
    800003fc:	37fd                	addiw	a5,a5,-1
    800003fe:	00011717          	auipc	a4,0x11
    80000402:	e0f72d23          	sw	a5,-486(a4) # 80011218 <cons+0xa8>
      consputc(BACKSPACE);
    80000406:	10000513          	li	a0,256
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e84080e7          	jalr	-380(ra) # 8000028e <consputc>
    80000412:	bded                	j	8000030c <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000414:	ee048ce3          	beqz	s1,8000030c <consoleintr+0x3c>
    80000418:	bf21                	j	80000330 <consoleintr+0x60>
      consputc(c);
    8000041a:	4529                	li	a0,10
    8000041c:	00000097          	auipc	ra,0x0
    80000420:	e72080e7          	jalr	-398(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000424:	00011797          	auipc	a5,0x11
    80000428:	d4c78793          	addi	a5,a5,-692 # 80011170 <cons>
    8000042c:	0a87a703          	lw	a4,168(a5)
    80000430:	0017069b          	addiw	a3,a4,1
    80000434:	0006861b          	sext.w	a2,a3
    80000438:	0ad7a423          	sw	a3,168(a5)
    8000043c:	07f77713          	andi	a4,a4,127
    80000440:	97ba                	add	a5,a5,a4
    80000442:	4729                	li	a4,10
    80000444:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000448:	00011797          	auipc	a5,0x11
    8000044c:	dcc7a623          	sw	a2,-564(a5) # 80011214 <cons+0xa4>
        wakeup(&cons.r);
    80000450:	00011517          	auipc	a0,0x11
    80000454:	dc050513          	addi	a0,a0,-576 # 80011210 <cons+0xa0>
    80000458:	00002097          	auipc	ra,0x2
    8000045c:	2f4080e7          	jalr	756(ra) # 8000274c <wakeup>
    80000460:	b575                	j	8000030c <consoleintr+0x3c>

0000000080000462 <consoleinit>:

void
consoleinit(void)
{
    80000462:	1141                	addi	sp,sp,-16
    80000464:	e406                	sd	ra,8(sp)
    80000466:	e022                	sd	s0,0(sp)
    80000468:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000046a:	00008597          	auipc	a1,0x8
    8000046e:	ba658593          	addi	a1,a1,-1114 # 80008010 <etext+0x10>
    80000472:	00011517          	auipc	a0,0x11
    80000476:	cfe50513          	addi	a0,a0,-770 # 80011170 <cons>
    8000047a:	00001097          	auipc	ra,0x1
    8000047e:	a70080e7          	jalr	-1424(ra) # 80000eea <initlock>

  uartinit();
    80000482:	00000097          	auipc	ra,0x0
    80000486:	330080e7          	jalr	816(ra) # 800007b2 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048a:	00028797          	auipc	a5,0x28
    8000048e:	1ce78793          	addi	a5,a5,462 # 80028658 <devsw>
    80000492:	00000717          	auipc	a4,0x0
    80000496:	ce470713          	addi	a4,a4,-796 # 80000176 <consoleread>
    8000049a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000049c:	00000717          	auipc	a4,0x0
    800004a0:	c5870713          	addi	a4,a4,-936 # 800000f4 <consolewrite>
    800004a4:	ef98                	sd	a4,24(a5)
}
    800004a6:	60a2                	ld	ra,8(sp)
    800004a8:	6402                	ld	s0,0(sp)
    800004aa:	0141                	addi	sp,sp,16
    800004ac:	8082                	ret

00000000800004ae <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ae:	7179                	addi	sp,sp,-48
    800004b0:	f406                	sd	ra,40(sp)
    800004b2:	f022                	sd	s0,32(sp)
    800004b4:	ec26                	sd	s1,24(sp)
    800004b6:	e84a                	sd	s2,16(sp)
    800004b8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ba:	c219                	beqz	a2,800004c0 <printint+0x12>
    800004bc:	08054663          	bltz	a0,80000548 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004c0:	2501                	sext.w	a0,a0
    800004c2:	4881                	li	a7,0
    800004c4:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004ca:	2581                	sext.w	a1,a1
    800004cc:	00008617          	auipc	a2,0x8
    800004d0:	b7460613          	addi	a2,a2,-1164 # 80008040 <digits>
    800004d4:	883a                	mv	a6,a4
    800004d6:	2705                	addiw	a4,a4,1
    800004d8:	02b577bb          	remuw	a5,a0,a1
    800004dc:	1782                	slli	a5,a5,0x20
    800004de:	9381                	srli	a5,a5,0x20
    800004e0:	97b2                	add	a5,a5,a2
    800004e2:	0007c783          	lbu	a5,0(a5)
    800004e6:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ea:	0005079b          	sext.w	a5,a0
    800004ee:	02b5553b          	divuw	a0,a0,a1
    800004f2:	0685                	addi	a3,a3,1
    800004f4:	feb7f0e3          	bgeu	a5,a1,800004d4 <printint+0x26>

  if(sign)
    800004f8:	00088b63          	beqz	a7,8000050e <printint+0x60>
    buf[i++] = '-';
    800004fc:	fe040793          	addi	a5,s0,-32
    80000500:	973e                	add	a4,a4,a5
    80000502:	02d00793          	li	a5,45
    80000506:	fef70823          	sb	a5,-16(a4)
    8000050a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000050e:	02e05763          	blez	a4,8000053c <printint+0x8e>
    80000512:	fd040793          	addi	a5,s0,-48
    80000516:	00e784b3          	add	s1,a5,a4
    8000051a:	fff78913          	addi	s2,a5,-1
    8000051e:	993a                	add	s2,s2,a4
    80000520:	377d                	addiw	a4,a4,-1
    80000522:	1702                	slli	a4,a4,0x20
    80000524:	9301                	srli	a4,a4,0x20
    80000526:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000052a:	fff4c503          	lbu	a0,-1(s1)
    8000052e:	00000097          	auipc	ra,0x0
    80000532:	d60080e7          	jalr	-672(ra) # 8000028e <consputc>
  while(--i >= 0)
    80000536:	14fd                	addi	s1,s1,-1
    80000538:	ff2499e3          	bne	s1,s2,8000052a <printint+0x7c>
}
    8000053c:	70a2                	ld	ra,40(sp)
    8000053e:	7402                	ld	s0,32(sp)
    80000540:	64e2                	ld	s1,24(sp)
    80000542:	6942                	ld	s2,16(sp)
    80000544:	6145                	addi	sp,sp,48
    80000546:	8082                	ret
    x = -xx;
    80000548:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000054c:	4885                	li	a7,1
    x = -xx;
    8000054e:	bf9d                	j	800004c4 <printint+0x16>

0000000080000550 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000550:	1101                	addi	sp,sp,-32
    80000552:	ec06                	sd	ra,24(sp)
    80000554:	e822                	sd	s0,16(sp)
    80000556:	e426                	sd	s1,8(sp)
    80000558:	1000                	addi	s0,sp,32
    8000055a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000055c:	00011797          	auipc	a5,0x11
    80000560:	ce07a223          	sw	zero,-796(a5) # 80011240 <pr+0x20>
  printf("panic: ");
    80000564:	00008517          	auipc	a0,0x8
    80000568:	ab450513          	addi	a0,a0,-1356 # 80008018 <etext+0x18>
    8000056c:	00000097          	auipc	ra,0x0
    80000570:	02e080e7          	jalr	46(ra) # 8000059a <printf>
  printf(s);
    80000574:	8526                	mv	a0,s1
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	024080e7          	jalr	36(ra) # 8000059a <printf>
  printf("\n");
    8000057e:	00008517          	auipc	a0,0x8
    80000582:	bea50513          	addi	a0,a0,-1046 # 80008168 <digits+0x128>
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	014080e7          	jalr	20(ra) # 8000059a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000058e:	4785                	li	a5,1
    80000590:	00009717          	auipc	a4,0x9
    80000594:	a6f72823          	sw	a5,-1424(a4) # 80009000 <panicked>
  for(;;)
    80000598:	a001                	j	80000598 <panic+0x48>

000000008000059a <printf>:
{
    8000059a:	7131                	addi	sp,sp,-192
    8000059c:	fc86                	sd	ra,120(sp)
    8000059e:	f8a2                	sd	s0,112(sp)
    800005a0:	f4a6                	sd	s1,104(sp)
    800005a2:	f0ca                	sd	s2,96(sp)
    800005a4:	ecce                	sd	s3,88(sp)
    800005a6:	e8d2                	sd	s4,80(sp)
    800005a8:	e4d6                	sd	s5,72(sp)
    800005aa:	e0da                	sd	s6,64(sp)
    800005ac:	fc5e                	sd	s7,56(sp)
    800005ae:	f862                	sd	s8,48(sp)
    800005b0:	f466                	sd	s9,40(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	ec6e                	sd	s11,24(sp)
    800005b6:	0100                	addi	s0,sp,128
    800005b8:	8a2a                	mv	s4,a0
    800005ba:	e40c                	sd	a1,8(s0)
    800005bc:	e810                	sd	a2,16(s0)
    800005be:	ec14                	sd	a3,24(s0)
    800005c0:	f018                	sd	a4,32(s0)
    800005c2:	f41c                	sd	a5,40(s0)
    800005c4:	03043823          	sd	a6,48(s0)
    800005c8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005cc:	00011d97          	auipc	s11,0x11
    800005d0:	c74dad83          	lw	s11,-908(s11) # 80011240 <pr+0x20>
  if(locking)
    800005d4:	020d9b63          	bnez	s11,8000060a <printf+0x70>
  if (fmt == 0)
    800005d8:	040a0263          	beqz	s4,8000061c <printf+0x82>
  va_start(ap, fmt);
    800005dc:	00840793          	addi	a5,s0,8
    800005e0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e4:	000a4503          	lbu	a0,0(s4)
    800005e8:	16050263          	beqz	a0,8000074c <printf+0x1b2>
    800005ec:	4481                	li	s1,0
    if(c != '%'){
    800005ee:	02500a93          	li	s5,37
    switch(c){
    800005f2:	07000b13          	li	s6,112
  consputc('x');
    800005f6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f8:	00008b97          	auipc	s7,0x8
    800005fc:	a48b8b93          	addi	s7,s7,-1464 # 80008040 <digits>
    switch(c){
    80000600:	07300c93          	li	s9,115
    80000604:	06400c13          	li	s8,100
    80000608:	a82d                	j	80000642 <printf+0xa8>
    acquire(&pr.lock);
    8000060a:	00011517          	auipc	a0,0x11
    8000060e:	c1650513          	addi	a0,a0,-1002 # 80011220 <pr>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	75c080e7          	jalr	1884(ra) # 80000d6e <acquire>
    8000061a:	bf7d                	j	800005d8 <printf+0x3e>
    panic("null fmt");
    8000061c:	00008517          	auipc	a0,0x8
    80000620:	a0c50513          	addi	a0,a0,-1524 # 80008028 <etext+0x28>
    80000624:	00000097          	auipc	ra,0x0
    80000628:	f2c080e7          	jalr	-212(ra) # 80000550 <panic>
      consputc(c);
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	c62080e7          	jalr	-926(ra) # 8000028e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c503          	lbu	a0,0(a5)
    8000063e:	10050763          	beqz	a0,8000074c <printf+0x1b2>
    if(c != '%'){
    80000642:	ff5515e3          	bne	a0,s5,8000062c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000646:	2485                	addiw	s1,s1,1
    80000648:	009a07b3          	add	a5,s4,s1
    8000064c:	0007c783          	lbu	a5,0(a5)
    80000650:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000654:	cfe5                	beqz	a5,8000074c <printf+0x1b2>
    switch(c){
    80000656:	05678a63          	beq	a5,s6,800006aa <printf+0x110>
    8000065a:	02fb7663          	bgeu	s6,a5,80000686 <printf+0xec>
    8000065e:	09978963          	beq	a5,s9,800006f0 <printf+0x156>
    80000662:	07800713          	li	a4,120
    80000666:	0ce79863          	bne	a5,a4,80000736 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4605                	li	a2,1
    80000678:	85ea                	mv	a1,s10
    8000067a:	4388                	lw	a0,0(a5)
    8000067c:	00000097          	auipc	ra,0x0
    80000680:	e32080e7          	jalr	-462(ra) # 800004ae <printint>
      break;
    80000684:	bf45                	j	80000634 <printf+0x9a>
    switch(c){
    80000686:	0b578263          	beq	a5,s5,8000072a <printf+0x190>
    8000068a:	0b879663          	bne	a5,s8,80000736 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	45a9                	li	a1,10
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e0e080e7          	jalr	-498(ra) # 800004ae <printint>
      break;
    800006a8:	b771                	j	80000634 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006aa:	f8843783          	ld	a5,-120(s0)
    800006ae:	00878713          	addi	a4,a5,8
    800006b2:	f8e43423          	sd	a4,-120(s0)
    800006b6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ba:	03000513          	li	a0,48
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bd0080e7          	jalr	-1072(ra) # 8000028e <consputc>
  consputc('x');
    800006c6:	07800513          	li	a0,120
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bc4080e7          	jalr	-1084(ra) # 8000028e <consputc>
    800006d2:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d4:	03c9d793          	srli	a5,s3,0x3c
    800006d8:	97de                	add	a5,a5,s7
    800006da:	0007c503          	lbu	a0,0(a5)
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	bb0080e7          	jalr	-1104(ra) # 8000028e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e6:	0992                	slli	s3,s3,0x4
    800006e8:	397d                	addiw	s2,s2,-1
    800006ea:	fe0915e3          	bnez	s2,800006d4 <printf+0x13a>
    800006ee:	b799                	j	80000634 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006f0:	f8843783          	ld	a5,-120(s0)
    800006f4:	00878713          	addi	a4,a5,8
    800006f8:	f8e43423          	sd	a4,-120(s0)
    800006fc:	0007b903          	ld	s2,0(a5)
    80000700:	00090e63          	beqz	s2,8000071c <printf+0x182>
      for(; *s; s++)
    80000704:	00094503          	lbu	a0,0(s2)
    80000708:	d515                	beqz	a0,80000634 <printf+0x9a>
        consputc(*s);
    8000070a:	00000097          	auipc	ra,0x0
    8000070e:	b84080e7          	jalr	-1148(ra) # 8000028e <consputc>
      for(; *s; s++)
    80000712:	0905                	addi	s2,s2,1
    80000714:	00094503          	lbu	a0,0(s2)
    80000718:	f96d                	bnez	a0,8000070a <printf+0x170>
    8000071a:	bf29                	j	80000634 <printf+0x9a>
        s = "(null)";
    8000071c:	00008917          	auipc	s2,0x8
    80000720:	90490913          	addi	s2,s2,-1788 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000724:	02800513          	li	a0,40
    80000728:	b7cd                	j	8000070a <printf+0x170>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b62080e7          	jalr	-1182(ra) # 8000028e <consputc>
      break;
    80000734:	b701                	j	80000634 <printf+0x9a>
      consputc('%');
    80000736:	8556                	mv	a0,s5
    80000738:	00000097          	auipc	ra,0x0
    8000073c:	b56080e7          	jalr	-1194(ra) # 8000028e <consputc>
      consputc(c);
    80000740:	854a                	mv	a0,s2
    80000742:	00000097          	auipc	ra,0x0
    80000746:	b4c080e7          	jalr	-1204(ra) # 8000028e <consputc>
      break;
    8000074a:	b5ed                	j	80000634 <printf+0x9a>
  if(locking)
    8000074c:	020d9163          	bnez	s11,8000076e <printf+0x1d4>
}
    80000750:	70e6                	ld	ra,120(sp)
    80000752:	7446                	ld	s0,112(sp)
    80000754:	74a6                	ld	s1,104(sp)
    80000756:	7906                	ld	s2,96(sp)
    80000758:	69e6                	ld	s3,88(sp)
    8000075a:	6a46                	ld	s4,80(sp)
    8000075c:	6aa6                	ld	s5,72(sp)
    8000075e:	6b06                	ld	s6,64(sp)
    80000760:	7be2                	ld	s7,56(sp)
    80000762:	7c42                	ld	s8,48(sp)
    80000764:	7ca2                	ld	s9,40(sp)
    80000766:	7d02                	ld	s10,32(sp)
    80000768:	6de2                	ld	s11,24(sp)
    8000076a:	6129                	addi	sp,sp,192
    8000076c:	8082                	ret
    release(&pr.lock);
    8000076e:	00011517          	auipc	a0,0x11
    80000772:	ab250513          	addi	a0,a0,-1358 # 80011220 <pr>
    80000776:	00000097          	auipc	ra,0x0
    8000077a:	6c8080e7          	jalr	1736(ra) # 80000e3e <release>
}
    8000077e:	bfc9                	j	80000750 <printf+0x1b6>

0000000080000780 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000780:	1101                	addi	sp,sp,-32
    80000782:	ec06                	sd	ra,24(sp)
    80000784:	e822                	sd	s0,16(sp)
    80000786:	e426                	sd	s1,8(sp)
    80000788:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000078a:	00011497          	auipc	s1,0x11
    8000078e:	a9648493          	addi	s1,s1,-1386 # 80011220 <pr>
    80000792:	00008597          	auipc	a1,0x8
    80000796:	8a658593          	addi	a1,a1,-1882 # 80008038 <etext+0x38>
    8000079a:	8526                	mv	a0,s1
    8000079c:	00000097          	auipc	ra,0x0
    800007a0:	74e080e7          	jalr	1870(ra) # 80000eea <initlock>
  pr.locking = 1;
    800007a4:	4785                	li	a5,1
    800007a6:	d09c                	sw	a5,32(s1)
}
    800007a8:	60e2                	ld	ra,24(sp)
    800007aa:	6442                	ld	s0,16(sp)
    800007ac:	64a2                	ld	s1,8(sp)
    800007ae:	6105                	addi	sp,sp,32
    800007b0:	8082                	ret

00000000800007b2 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007b2:	1141                	addi	sp,sp,-16
    800007b4:	e406                	sd	ra,8(sp)
    800007b6:	e022                	sd	s0,0(sp)
    800007b8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ba:	100007b7          	lui	a5,0x10000
    800007be:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007c2:	f8000713          	li	a4,-128
    800007c6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ca:	470d                	li	a4,3
    800007cc:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007d0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007d4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d8:	469d                	li	a3,7
    800007da:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007de:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007e2:	00008597          	auipc	a1,0x8
    800007e6:	87658593          	addi	a1,a1,-1930 # 80008058 <digits+0x18>
    800007ea:	00011517          	auipc	a0,0x11
    800007ee:	a5e50513          	addi	a0,a0,-1442 # 80011248 <uart_tx_lock>
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	6f8080e7          	jalr	1784(ra) # 80000eea <initlock>
}
    800007fa:	60a2                	ld	ra,8(sp)
    800007fc:	6402                	ld	s0,0(sp)
    800007fe:	0141                	addi	sp,sp,16
    80000800:	8082                	ret

0000000080000802 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000802:	1101                	addi	sp,sp,-32
    80000804:	ec06                	sd	ra,24(sp)
    80000806:	e822                	sd	s0,16(sp)
    80000808:	e426                	sd	s1,8(sp)
    8000080a:	1000                	addi	s0,sp,32
    8000080c:	84aa                	mv	s1,a0
  push_off();
    8000080e:	00000097          	auipc	ra,0x0
    80000812:	514080e7          	jalr	1300(ra) # 80000d22 <push_off>

  if(panicked){
    80000816:	00008797          	auipc	a5,0x8
    8000081a:	7ea7a783          	lw	a5,2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	10000737          	lui	a4,0x10000
  if(panicked){
    80000822:	c391                	beqz	a5,80000826 <uartputc_sync+0x24>
    for(;;)
    80000824:	a001                	j	80000824 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000826:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000082a:	0ff7f793          	andi	a5,a5,255
    8000082e:	0207f793          	andi	a5,a5,32
    80000832:	dbf5                	beqz	a5,80000826 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000834:	0ff4f793          	andi	a5,s1,255
    80000838:	10000737          	lui	a4,0x10000
    8000083c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000840:	00000097          	auipc	ra,0x0
    80000844:	59e080e7          	jalr	1438(ra) # 80000dde <pop_off>
}
    80000848:	60e2                	ld	ra,24(sp)
    8000084a:	6442                	ld	s0,16(sp)
    8000084c:	64a2                	ld	s1,8(sp)
    8000084e:	6105                	addi	sp,sp,32
    80000850:	8082                	ret

0000000080000852 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000852:	00008797          	auipc	a5,0x8
    80000856:	7b27a783          	lw	a5,1970(a5) # 80009004 <uart_tx_r>
    8000085a:	00008717          	auipc	a4,0x8
    8000085e:	7ae72703          	lw	a4,1966(a4) # 80009008 <uart_tx_w>
    80000862:	08f70263          	beq	a4,a5,800008e6 <uartstart+0x94>
{
    80000866:	7139                	addi	sp,sp,-64
    80000868:	fc06                	sd	ra,56(sp)
    8000086a:	f822                	sd	s0,48(sp)
    8000086c:	f426                	sd	s1,40(sp)
    8000086e:	f04a                	sd	s2,32(sp)
    80000870:	ec4e                	sd	s3,24(sp)
    80000872:	e852                	sd	s4,16(sp)
    80000874:	e456                	sd	s5,8(sp)
    80000876:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    8000087c:	00011a17          	auipc	s4,0x11
    80000880:	9cca0a13          	addi	s4,s4,-1588 # 80011248 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000884:	00008497          	auipc	s1,0x8
    80000888:	78048493          	addi	s1,s1,1920 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000088c:	00008997          	auipc	s3,0x8
    80000890:	77c98993          	addi	s3,s3,1916 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000894:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000898:	0ff77713          	andi	a4,a4,255
    8000089c:	02077713          	andi	a4,a4,32
    800008a0:	cb15                	beqz	a4,800008d4 <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    800008a2:	00fa0733          	add	a4,s4,a5
    800008a6:	02074a83          	lbu	s5,32(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008aa:	2785                	addiw	a5,a5,1
    800008ac:	41f7d71b          	sraiw	a4,a5,0x1f
    800008b0:	01b7571b          	srliw	a4,a4,0x1b
    800008b4:	9fb9                	addw	a5,a5,a4
    800008b6:	8bfd                	andi	a5,a5,31
    800008b8:	9f99                	subw	a5,a5,a4
    800008ba:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008bc:	8526                	mv	a0,s1
    800008be:	00002097          	auipc	ra,0x2
    800008c2:	e8e080e7          	jalr	-370(ra) # 8000274c <wakeup>
    
    WriteReg(THR, c);
    800008c6:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ca:	409c                	lw	a5,0(s1)
    800008cc:	0009a703          	lw	a4,0(s3)
    800008d0:	fcf712e3          	bne	a4,a5,80000894 <uartstart+0x42>
  }
}
    800008d4:	70e2                	ld	ra,56(sp)
    800008d6:	7442                	ld	s0,48(sp)
    800008d8:	74a2                	ld	s1,40(sp)
    800008da:	7902                	ld	s2,32(sp)
    800008dc:	69e2                	ld	s3,24(sp)
    800008de:	6a42                	ld	s4,16(sp)
    800008e0:	6aa2                	ld	s5,8(sp)
    800008e2:	6121                	addi	sp,sp,64
    800008e4:	8082                	ret
    800008e6:	8082                	ret

00000000800008e8 <uartputc>:
{
    800008e8:	7179                	addi	sp,sp,-48
    800008ea:	f406                	sd	ra,40(sp)
    800008ec:	f022                	sd	s0,32(sp)
    800008ee:	ec26                	sd	s1,24(sp)
    800008f0:	e84a                	sd	s2,16(sp)
    800008f2:	e44e                	sd	s3,8(sp)
    800008f4:	e052                	sd	s4,0(sp)
    800008f6:	1800                	addi	s0,sp,48
    800008f8:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008fa:	00011517          	auipc	a0,0x11
    800008fe:	94e50513          	addi	a0,a0,-1714 # 80011248 <uart_tx_lock>
    80000902:	00000097          	auipc	ra,0x0
    80000906:	46c080e7          	jalr	1132(ra) # 80000d6e <acquire>
  if(panicked){
    8000090a:	00008797          	auipc	a5,0x8
    8000090e:	6f67a783          	lw	a5,1782(a5) # 80009000 <panicked>
    80000912:	c391                	beqz	a5,80000916 <uartputc+0x2e>
    for(;;)
    80000914:	a001                	j	80000914 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000916:	00008717          	auipc	a4,0x8
    8000091a:	6f272703          	lw	a4,1778(a4) # 80009008 <uart_tx_w>
    8000091e:	0017079b          	addiw	a5,a4,1
    80000922:	41f7d69b          	sraiw	a3,a5,0x1f
    80000926:	01b6d69b          	srliw	a3,a3,0x1b
    8000092a:	9fb5                	addw	a5,a5,a3
    8000092c:	8bfd                	andi	a5,a5,31
    8000092e:	9f95                	subw	a5,a5,a3
    80000930:	00008697          	auipc	a3,0x8
    80000934:	6d46a683          	lw	a3,1748(a3) # 80009004 <uart_tx_r>
    80000938:	04f69263          	bne	a3,a5,8000097c <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000093c:	00011a17          	auipc	s4,0x11
    80000940:	90ca0a13          	addi	s4,s4,-1780 # 80011248 <uart_tx_lock>
    80000944:	00008497          	auipc	s1,0x8
    80000948:	6c048493          	addi	s1,s1,1728 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000094c:	00008917          	auipc	s2,0x8
    80000950:	6bc90913          	addi	s2,s2,1724 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000954:	85d2                	mv	a1,s4
    80000956:	8526                	mv	a0,s1
    80000958:	00002097          	auipc	ra,0x2
    8000095c:	c6e080e7          	jalr	-914(ra) # 800025c6 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000960:	00092703          	lw	a4,0(s2)
    80000964:	0017079b          	addiw	a5,a4,1
    80000968:	41f7d69b          	sraiw	a3,a5,0x1f
    8000096c:	01b6d69b          	srliw	a3,a3,0x1b
    80000970:	9fb5                	addw	a5,a5,a3
    80000972:	8bfd                	andi	a5,a5,31
    80000974:	9f95                	subw	a5,a5,a3
    80000976:	4094                	lw	a3,0(s1)
    80000978:	fcf68ee3          	beq	a3,a5,80000954 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    8000097c:	00011497          	auipc	s1,0x11
    80000980:	8cc48493          	addi	s1,s1,-1844 # 80011248 <uart_tx_lock>
    80000984:	9726                	add	a4,a4,s1
    80000986:	03370023          	sb	s3,32(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    8000098a:	00008717          	auipc	a4,0x8
    8000098e:	66f72f23          	sw	a5,1662(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000992:	00000097          	auipc	ra,0x0
    80000996:	ec0080e7          	jalr	-320(ra) # 80000852 <uartstart>
      release(&uart_tx_lock);
    8000099a:	8526                	mv	a0,s1
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	4a2080e7          	jalr	1186(ra) # 80000e3e <release>
}
    800009a4:	70a2                	ld	ra,40(sp)
    800009a6:	7402                	ld	s0,32(sp)
    800009a8:	64e2                	ld	s1,24(sp)
    800009aa:	6942                	ld	s2,16(sp)
    800009ac:	69a2                	ld	s3,8(sp)
    800009ae:	6a02                	ld	s4,0(sp)
    800009b0:	6145                	addi	sp,sp,48
    800009b2:	8082                	ret

00000000800009b4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009b4:	1141                	addi	sp,sp,-16
    800009b6:	e422                	sd	s0,8(sp)
    800009b8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009c2:	8b85                	andi	a5,a5,1
    800009c4:	cb91                	beqz	a5,800009d8 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009c6:	100007b7          	lui	a5,0x10000
    800009ca:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009ce:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009d2:	6422                	ld	s0,8(sp)
    800009d4:	0141                	addi	sp,sp,16
    800009d6:	8082                	ret
    return -1;
    800009d8:	557d                	li	a0,-1
    800009da:	bfe5                	j	800009d2 <uartgetc+0x1e>

00000000800009dc <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009dc:	1101                	addi	sp,sp,-32
    800009de:	ec06                	sd	ra,24(sp)
    800009e0:	e822                	sd	s0,16(sp)
    800009e2:	e426                	sd	s1,8(sp)
    800009e4:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009e6:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	fcc080e7          	jalr	-52(ra) # 800009b4 <uartgetc>
    if(c == -1)
    800009f0:	00950763          	beq	a0,s1,800009fe <uartintr+0x22>
      break;
    consoleintr(c);
    800009f4:	00000097          	auipc	ra,0x0
    800009f8:	8dc080e7          	jalr	-1828(ra) # 800002d0 <consoleintr>
  while(1){
    800009fc:	b7f5                	j	800009e8 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009fe:	00011497          	auipc	s1,0x11
    80000a02:	84a48493          	addi	s1,s1,-1974 # 80011248 <uart_tx_lock>
    80000a06:	8526                	mv	a0,s1
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	366080e7          	jalr	870(ra) # 80000d6e <acquire>
  uartstart();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	e42080e7          	jalr	-446(ra) # 80000852 <uartstart>
  release(&uart_tx_lock);
    80000a18:	8526                	mv	a0,s1
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	424080e7          	jalr	1060(ra) # 80000e3e <release>
}
    80000a22:	60e2                	ld	ra,24(sp)
    80000a24:	6442                	ld	s0,16(sp)
    80000a26:	64a2                	ld	s1,8(sp)
    80000a28:	6105                	addi	sp,sp,32
    80000a2a:	8082                	ret

0000000080000a2c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a2c:	7139                	addi	sp,sp,-64
    80000a2e:	fc06                	sd	ra,56(sp)
    80000a30:	f822                	sd	s0,48(sp)
    80000a32:	f426                	sd	s1,40(sp)
    80000a34:	f04a                	sd	s2,32(sp)
    80000a36:	ec4e                	sd	s3,24(sp)
    80000a38:	e852                	sd	s4,16(sp)
    80000a3a:	e456                	sd	s5,8(sp)
    80000a3c:	0080                	addi	s0,sp,64
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a3e:	03451793          	slli	a5,a0,0x34
    80000a42:	e3c1                	bnez	a5,80000ac2 <kfree+0x96>
    80000a44:	84aa                	mv	s1,a0
    80000a46:	0002d797          	auipc	a5,0x2d
    80000a4a:	5e278793          	addi	a5,a5,1506 # 8002e028 <end>
    80000a4e:	06f56a63          	bltu	a0,a5,80000ac2 <kfree+0x96>
    80000a52:	47c5                	li	a5,17
    80000a54:	07ee                	slli	a5,a5,0x1b
    80000a56:	06f57663          	bgeu	a0,a5,80000ac2 <kfree+0x96>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a5a:	6605                	lui	a2,0x1
    80000a5c:	4585                	li	a1,1
    80000a5e:	00000097          	auipc	ra,0x0
    80000a62:	6f0080e7          	jalr	1776(ra) # 8000114e <memset>

  r = (struct run*)pa;

  push_off();
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	2bc080e7          	jalr	700(ra) # 80000d22 <push_off>
  int id = cpuid();
    80000a6e:	00001097          	auipc	ra,0x1
    80000a72:	31c080e7          	jalr	796(ra) # 80001d8a <cpuid>

  acquire(&kmem[id].lock);
    80000a76:	00011a97          	auipc	s5,0x11
    80000a7a:	812a8a93          	addi	s5,s5,-2030 # 80011288 <kmem>
    80000a7e:	00151993          	slli	s3,a0,0x1
    80000a82:	00a98933          	add	s2,s3,a0
    80000a86:	0912                	slli	s2,s2,0x4
    80000a88:	9956                	add	s2,s2,s5
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	2e2080e7          	jalr	738(ra) # 80000d6e <acquire>
  r->next = kmem[id].freelist;
    80000a94:	02093783          	ld	a5,32(s2)
    80000a98:	e09c                	sd	a5,0(s1)
  kmem[id].freelist = r;
    80000a9a:	02993023          	sd	s1,32(s2)
  release(&kmem[id].lock);
    80000a9e:	854a                	mv	a0,s2
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	39e080e7          	jalr	926(ra) # 80000e3e <release>

  pop_off();
    80000aa8:	00000097          	auipc	ra,0x0
    80000aac:	336080e7          	jalr	822(ra) # 80000dde <pop_off>
}
    80000ab0:	70e2                	ld	ra,56(sp)
    80000ab2:	7442                	ld	s0,48(sp)
    80000ab4:	74a2                	ld	s1,40(sp)
    80000ab6:	7902                	ld	s2,32(sp)
    80000ab8:	69e2                	ld	s3,24(sp)
    80000aba:	6a42                	ld	s4,16(sp)
    80000abc:	6aa2                	ld	s5,8(sp)
    80000abe:	6121                	addi	sp,sp,64
    80000ac0:	8082                	ret
    panic("kfree");
    80000ac2:	00007517          	auipc	a0,0x7
    80000ac6:	59e50513          	addi	a0,a0,1438 # 80008060 <digits+0x20>
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	a86080e7          	jalr	-1402(ra) # 80000550 <panic>

0000000080000ad2 <freerange>:
{
    80000ad2:	7179                	addi	sp,sp,-48
    80000ad4:	f406                	sd	ra,40(sp)
    80000ad6:	f022                	sd	s0,32(sp)
    80000ad8:	ec26                	sd	s1,24(sp)
    80000ada:	e84a                	sd	s2,16(sp)
    80000adc:	e44e                	sd	s3,8(sp)
    80000ade:	e052                	sd	s4,0(sp)
    80000ae0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ae2:	6785                	lui	a5,0x1
    80000ae4:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ae8:	94aa                	add	s1,s1,a0
    80000aea:	757d                	lui	a0,0xfffff
    80000aec:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aee:	94be                	add	s1,s1,a5
    80000af0:	0095ee63          	bltu	a1,s1,80000b0c <freerange+0x3a>
    80000af4:	892e                	mv	s2,a1
    kfree(p);
    80000af6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af8:	6985                	lui	s3,0x1
    kfree(p);
    80000afa:	01448533          	add	a0,s1,s4
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f2e080e7          	jalr	-210(ra) # 80000a2c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b06:	94ce                	add	s1,s1,s3
    80000b08:	fe9979e3          	bgeu	s2,s1,80000afa <freerange+0x28>
}
    80000b0c:	70a2                	ld	ra,40(sp)
    80000b0e:	7402                	ld	s0,32(sp)
    80000b10:	64e2                	ld	s1,24(sp)
    80000b12:	6942                	ld	s2,16(sp)
    80000b14:	69a2                	ld	s3,8(sp)
    80000b16:	6a02                	ld	s4,0(sp)
    80000b18:	6145                	addi	sp,sp,48
    80000b1a:	8082                	ret

0000000080000b1c <kinit>:
{
    80000b1c:	7139                	addi	sp,sp,-64
    80000b1e:	fc06                	sd	ra,56(sp)
    80000b20:	f822                	sd	s0,48(sp)
    80000b22:	f426                	sd	s1,40(sp)
    80000b24:	f04a                	sd	s2,32(sp)
    80000b26:	ec4e                	sd	s3,24(sp)
    80000b28:	e852                	sd	s4,16(sp)
    80000b2a:	e456                	sd	s5,8(sp)
    80000b2c:	0080                	addi	s0,sp,64
  for (int i = 0; i < NCPU; i++) {
    80000b2e:	00010917          	auipc	s2,0x10
    80000b32:	75a90913          	addi	s2,s2,1882 # 80011288 <kmem>
    80000b36:	4481                	li	s1,0
    snprintf(kmem[i].lock_name, sizeof(kmem[i].lock_name), "kmem_%d", i);
    80000b38:	00007a97          	auipc	s5,0x7
    80000b3c:	530a8a93          	addi	s5,s5,1328 # 80008068 <digits+0x28>
  for (int i = 0; i < NCPU; i++) {
    80000b40:	4a21                	li	s4,8
    snprintf(kmem[i].lock_name, sizeof(kmem[i].lock_name), "kmem_%d", i);
    80000b42:	02890993          	addi	s3,s2,40
    80000b46:	86a6                	mv	a3,s1
    80000b48:	8656                	mv	a2,s5
    80000b4a:	459d                	li	a1,7
    80000b4c:	854e                	mv	a0,s3
    80000b4e:	00006097          	auipc	ra,0x6
    80000b52:	dc4080e7          	jalr	-572(ra) # 80006912 <snprintf>
    initlock(&kmem[i].lock, kmem[i].lock_name);
    80000b56:	85ce                	mv	a1,s3
    80000b58:	854a                	mv	a0,s2
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	390080e7          	jalr	912(ra) # 80000eea <initlock>
  for (int i = 0; i < NCPU; i++) {
    80000b62:	2485                	addiw	s1,s1,1
    80000b64:	03090913          	addi	s2,s2,48
    80000b68:	fd449de3          	bne	s1,s4,80000b42 <kinit+0x26>
  freerange(end, (void*)PHYSTOP);
    80000b6c:	45c5                	li	a1,17
    80000b6e:	05ee                	slli	a1,a1,0x1b
    80000b70:	0002d517          	auipc	a0,0x2d
    80000b74:	4b850513          	addi	a0,a0,1208 # 8002e028 <end>
    80000b78:	00000097          	auipc	ra,0x0
    80000b7c:	f5a080e7          	jalr	-166(ra) # 80000ad2 <freerange>
}
    80000b80:	70e2                	ld	ra,56(sp)
    80000b82:	7442                	ld	s0,48(sp)
    80000b84:	74a2                	ld	s1,40(sp)
    80000b86:	7902                	ld	s2,32(sp)
    80000b88:	69e2                	ld	s3,24(sp)
    80000b8a:	6a42                	ld	s4,16(sp)
    80000b8c:	6aa2                	ld	s5,8(sp)
    80000b8e:	6121                	addi	sp,sp,64
    80000b90:	8082                	ret

0000000080000b92 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b92:	715d                	addi	sp,sp,-80
    80000b94:	e486                	sd	ra,72(sp)
    80000b96:	e0a2                	sd	s0,64(sp)
    80000b98:	fc26                	sd	s1,56(sp)
    80000b9a:	f84a                	sd	s2,48(sp)
    80000b9c:	f44e                	sd	s3,40(sp)
    80000b9e:	f052                	sd	s4,32(sp)
    80000ba0:	ec56                	sd	s5,24(sp)
    80000ba2:	e85a                	sd	s6,16(sp)
    80000ba4:	e45e                	sd	s7,8(sp)
    80000ba6:	0880                	addi	s0,sp,80
  struct run *r;

  push_off();
    80000ba8:	00000097          	auipc	ra,0x0
    80000bac:	17a080e7          	jalr	378(ra) # 80000d22 <push_off>
  int id = cpuid();
    80000bb0:	00001097          	auipc	ra,0x1
    80000bb4:	1da080e7          	jalr	474(ra) # 80001d8a <cpuid>
    80000bb8:	84aa                	mv	s1,a0

  acquire(&kmem[id].lock);
    80000bba:	00151793          	slli	a5,a0,0x1
    80000bbe:	97aa                	add	a5,a5,a0
    80000bc0:	0792                	slli	a5,a5,0x4
    80000bc2:	00010a17          	auipc	s4,0x10
    80000bc6:	6c6a0a13          	addi	s4,s4,1734 # 80011288 <kmem>
    80000bca:	9a3e                	add	s4,s4,a5
    80000bcc:	8552                	mv	a0,s4
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	1a0080e7          	jalr	416(ra) # 80000d6e <acquire>
  r = kmem[id].freelist;
    80000bd6:	020a3b03          	ld	s6,32(s4)
  if(r) {
    80000bda:	040b0263          	beqz	s6,80000c1e <kalloc+0x8c>
    kmem[id].freelist = r->next;
    80000bde:	000b3703          	ld	a4,0(s6)
    80000be2:	02ea3023          	sd	a4,32(s4)
    }
    // if (i == NCPU) {
    //   printf("alloc failed in %d: r=%p\n", id, r);
    // }
  }
  release(&kmem[id].lock);
    80000be6:	8552                	mv	a0,s4
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	256080e7          	jalr	598(ra) # 80000e3e <release>
  pop_off();
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	1ee080e7          	jalr	494(ra) # 80000dde <pop_off>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bf8:	6605                	lui	a2,0x1
    80000bfa:	4595                	li	a1,5
    80000bfc:	855a                	mv	a0,s6
    80000bfe:	00000097          	auipc	ra,0x0
    80000c02:	550080e7          	jalr	1360(ra) # 8000114e <memset>
  return (void*)r;
}
    80000c06:	855a                	mv	a0,s6
    80000c08:	60a6                	ld	ra,72(sp)
    80000c0a:	6406                	ld	s0,64(sp)
    80000c0c:	74e2                	ld	s1,56(sp)
    80000c0e:	7942                	ld	s2,48(sp)
    80000c10:	79a2                	ld	s3,40(sp)
    80000c12:	7a02                	ld	s4,32(sp)
    80000c14:	6ae2                	ld	s5,24(sp)
    80000c16:	6b42                	ld	s6,16(sp)
    80000c18:	6ba2                	ld	s7,8(sp)
    80000c1a:	6161                	addi	sp,sp,80
    80000c1c:	8082                	ret
    80000c1e:	00010917          	auipc	s2,0x10
    80000c22:	66a90913          	addi	s2,s2,1642 # 80011288 <kmem>
    for(i = 0; i < NCPU; i++) {
    80000c26:	4981                	li	s3,0
    80000c28:	4ba1                	li	s7,8
    80000c2a:	a069                	j	80000cb4 <kalloc+0x122>
          p = p->next;
    80000c2c:	87b6                	mv	a5,a3
        kmem[id].freelist = kmem[i].freelist;
    80000c2e:	00149713          	slli	a4,s1,0x1
    80000c32:	9726                	add	a4,a4,s1
    80000c34:	0712                	slli	a4,a4,0x4
    80000c36:	00010697          	auipc	a3,0x10
    80000c3a:	65268693          	addi	a3,a3,1618 # 80011288 <kmem>
    80000c3e:	9736                	add	a4,a4,a3
    80000c40:	f30c                	sd	a1,32(a4)
        if (p == kmem[i].freelist) {
    80000c42:	04f58763          	beq	a1,a5,80000c90 <kalloc+0xfe>
          kmem[i].freelist = p;
    80000c46:	00199713          	slli	a4,s3,0x1
    80000c4a:	99ba                	add	s3,s3,a4
    80000c4c:	0992                	slli	s3,s3,0x4
    80000c4e:	00010717          	auipc	a4,0x10
    80000c52:	63a70713          	addi	a4,a4,1594 # 80011288 <kmem>
    80000c56:	99ba                	add	s3,s3,a4
    80000c58:	02f9b023          	sd	a5,32(s3) # 1020 <_entry-0x7fffefe0>
          pre->next = 0;
    80000c5c:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
      release(&kmem[i].lock);
    80000c60:	8556                	mv	a0,s5
    80000c62:	00000097          	auipc	ra,0x0
    80000c66:	1dc080e7          	jalr	476(ra) # 80000e3e <release>
        r = kmem[id].freelist;
    80000c6a:	00010697          	auipc	a3,0x10
    80000c6e:	61e68693          	addi	a3,a3,1566 # 80011288 <kmem>
    80000c72:	00149793          	slli	a5,s1,0x1
    80000c76:	00978733          	add	a4,a5,s1
    80000c7a:	0712                	slli	a4,a4,0x4
    80000c7c:	9736                	add	a4,a4,a3
    80000c7e:	02073b03          	ld	s6,32(a4)
        kmem[id].freelist = r->next;
    80000c82:	000b3703          	ld	a4,0(s6)
    80000c86:	97a6                	add	a5,a5,s1
    80000c88:	0792                	slli	a5,a5,0x4
    80000c8a:	97b6                	add	a5,a5,a3
    80000c8c:	f398                	sd	a4,32(a5)
        break;
    80000c8e:	bfa1                	j	80000be6 <kalloc+0x54>
          kmem[i].freelist = 0;
    80000c90:	00199793          	slli	a5,s3,0x1
    80000c94:	99be                	add	s3,s3,a5
    80000c96:	0992                	slli	s3,s3,0x4
    80000c98:	99b6                	add	s3,s3,a3
    80000c9a:	0209b023          	sd	zero,32(s3)
    80000c9e:	b7c9                	j	80000c60 <kalloc+0xce>
      release(&kmem[i].lock);
    80000ca0:	854a                	mv	a0,s2
    80000ca2:	00000097          	auipc	ra,0x0
    80000ca6:	19c080e7          	jalr	412(ra) # 80000e3e <release>
    for(i = 0; i < NCPU; i++) {
    80000caa:	2985                	addiw	s3,s3,1
    80000cac:	03090913          	addi	s2,s2,48
    80000cb0:	03798863          	beq	s3,s7,80000ce0 <kalloc+0x14e>
      if (i == id) continue;
    80000cb4:	ff348be3          	beq	s1,s3,80000caa <kalloc+0x118>
      acquire(&kmem[i].lock);
    80000cb8:	8aca                	mv	s5,s2
    80000cba:	854a                	mv	a0,s2
    80000cbc:	00000097          	auipc	ra,0x0
    80000cc0:	0b2080e7          	jalr	178(ra) # 80000d6e <acquire>
      struct run *p = kmem[i].freelist;
    80000cc4:	02093583          	ld	a1,32(s2)
      if(p) {
    80000cc8:	dde1                	beqz	a1,80000ca0 <kalloc+0x10e>
      struct run *p = kmem[i].freelist;
    80000cca:	862e                	mv	a2,a1
    80000ccc:	872e                	mv	a4,a1
    80000cce:	87ae                	mv	a5,a1
        while (fp && fp->next) {
    80000cd0:	6318                	ld	a4,0(a4)
    80000cd2:	df31                	beqz	a4,80000c2e <kalloc+0x9c>
          fp = fp->next->next;
    80000cd4:	6318                	ld	a4,0(a4)
          p = p->next;
    80000cd6:	6394                	ld	a3,0(a5)
        while (fp && fp->next) {
    80000cd8:	863e                	mv	a2,a5
    80000cda:	db29                	beqz	a4,80000c2c <kalloc+0x9a>
          p = p->next;
    80000cdc:	87b6                	mv	a5,a3
    80000cde:	bfcd                	j	80000cd0 <kalloc+0x13e>
  release(&kmem[id].lock);
    80000ce0:	8552                	mv	a0,s4
    80000ce2:	00000097          	auipc	ra,0x0
    80000ce6:	15c080e7          	jalr	348(ra) # 80000e3e <release>
  pop_off();
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	0f4080e7          	jalr	244(ra) # 80000dde <pop_off>
  if(r)
    80000cf2:	bf11                	j	80000c06 <kalloc+0x74>

0000000080000cf4 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000cf4:	411c                	lw	a5,0(a0)
    80000cf6:	e399                	bnez	a5,80000cfc <holding+0x8>
    80000cf8:	4501                	li	a0,0
  return r;
}
    80000cfa:	8082                	ret
{
    80000cfc:	1101                	addi	sp,sp,-32
    80000cfe:	ec06                	sd	ra,24(sp)
    80000d00:	e822                	sd	s0,16(sp)
    80000d02:	e426                	sd	s1,8(sp)
    80000d04:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d06:	6904                	ld	s1,16(a0)
    80000d08:	00001097          	auipc	ra,0x1
    80000d0c:	092080e7          	jalr	146(ra) # 80001d9a <mycpu>
    80000d10:	40a48533          	sub	a0,s1,a0
    80000d14:	00153513          	seqz	a0,a0
}
    80000d18:	60e2                	ld	ra,24(sp)
    80000d1a:	6442                	ld	s0,16(sp)
    80000d1c:	64a2                	ld	s1,8(sp)
    80000d1e:	6105                	addi	sp,sp,32
    80000d20:	8082                	ret

0000000080000d22 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d22:	1101                	addi	sp,sp,-32
    80000d24:	ec06                	sd	ra,24(sp)
    80000d26:	e822                	sd	s0,16(sp)
    80000d28:	e426                	sd	s1,8(sp)
    80000d2a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d2c:	100024f3          	csrr	s1,sstatus
    80000d30:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d34:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d36:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d3a:	00001097          	auipc	ra,0x1
    80000d3e:	060080e7          	jalr	96(ra) # 80001d9a <mycpu>
    80000d42:	5d3c                	lw	a5,120(a0)
    80000d44:	cf89                	beqz	a5,80000d5e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d46:	00001097          	auipc	ra,0x1
    80000d4a:	054080e7          	jalr	84(ra) # 80001d9a <mycpu>
    80000d4e:	5d3c                	lw	a5,120(a0)
    80000d50:	2785                	addiw	a5,a5,1
    80000d52:	dd3c                	sw	a5,120(a0)
}
    80000d54:	60e2                	ld	ra,24(sp)
    80000d56:	6442                	ld	s0,16(sp)
    80000d58:	64a2                	ld	s1,8(sp)
    80000d5a:	6105                	addi	sp,sp,32
    80000d5c:	8082                	ret
    mycpu()->intena = old;
    80000d5e:	00001097          	auipc	ra,0x1
    80000d62:	03c080e7          	jalr	60(ra) # 80001d9a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d66:	8085                	srli	s1,s1,0x1
    80000d68:	8885                	andi	s1,s1,1
    80000d6a:	dd64                	sw	s1,124(a0)
    80000d6c:	bfe9                	j	80000d46 <push_off+0x24>

0000000080000d6e <acquire>:
{
    80000d6e:	1101                	addi	sp,sp,-32
    80000d70:	ec06                	sd	ra,24(sp)
    80000d72:	e822                	sd	s0,16(sp)
    80000d74:	e426                	sd	s1,8(sp)
    80000d76:	1000                	addi	s0,sp,32
    80000d78:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d7a:	00000097          	auipc	ra,0x0
    80000d7e:	fa8080e7          	jalr	-88(ra) # 80000d22 <push_off>
  if(holding(lk))
    80000d82:	8526                	mv	a0,s1
    80000d84:	00000097          	auipc	ra,0x0
    80000d88:	f70080e7          	jalr	-144(ra) # 80000cf4 <holding>
    80000d8c:	e911                	bnez	a0,80000da0 <acquire+0x32>
    __sync_fetch_and_add(&(lk->n), 1);
    80000d8e:	4785                	li	a5,1
    80000d90:	01c48713          	addi	a4,s1,28
    80000d94:	0f50000f          	fence	iorw,ow
    80000d98:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d9c:	4705                	li	a4,1
    80000d9e:	a839                	j	80000dbc <acquire+0x4e>
    panic("acquire");
    80000da0:	00007517          	auipc	a0,0x7
    80000da4:	2d050513          	addi	a0,a0,720 # 80008070 <digits+0x30>
    80000da8:	fffff097          	auipc	ra,0xfffff
    80000dac:	7a8080e7          	jalr	1960(ra) # 80000550 <panic>
    __sync_fetch_and_add(&(lk->nts), 1);
    80000db0:	01848793          	addi	a5,s1,24
    80000db4:	0f50000f          	fence	iorw,ow
    80000db8:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000dbc:	87ba                	mv	a5,a4
    80000dbe:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000dc2:	2781                	sext.w	a5,a5
    80000dc4:	f7f5                	bnez	a5,80000db0 <acquire+0x42>
  __sync_synchronize();
    80000dc6:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000dca:	00001097          	auipc	ra,0x1
    80000dce:	fd0080e7          	jalr	-48(ra) # 80001d9a <mycpu>
    80000dd2:	e888                	sd	a0,16(s1)
}
    80000dd4:	60e2                	ld	ra,24(sp)
    80000dd6:	6442                	ld	s0,16(sp)
    80000dd8:	64a2                	ld	s1,8(sp)
    80000dda:	6105                	addi	sp,sp,32
    80000ddc:	8082                	ret

0000000080000dde <pop_off>:

void
pop_off(void)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e406                	sd	ra,8(sp)
    80000de2:	e022                	sd	s0,0(sp)
    80000de4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000de6:	00001097          	auipc	ra,0x1
    80000dea:	fb4080e7          	jalr	-76(ra) # 80001d9a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000df2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000df4:	e78d                	bnez	a5,80000e1e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000df6:	5d3c                	lw	a5,120(a0)
    80000df8:	02f05b63          	blez	a5,80000e2e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	0007871b          	sext.w	a4,a5
    80000e02:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e04:	eb09                	bnez	a4,80000e16 <pop_off+0x38>
    80000e06:	5d7c                	lw	a5,124(a0)
    80000e08:	c799                	beqz	a5,80000e16 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e0a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e0e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e12:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e16:	60a2                	ld	ra,8(sp)
    80000e18:	6402                	ld	s0,0(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret
    panic("pop_off - interruptible");
    80000e1e:	00007517          	auipc	a0,0x7
    80000e22:	25a50513          	addi	a0,a0,602 # 80008078 <digits+0x38>
    80000e26:	fffff097          	auipc	ra,0xfffff
    80000e2a:	72a080e7          	jalr	1834(ra) # 80000550 <panic>
    panic("pop_off");
    80000e2e:	00007517          	auipc	a0,0x7
    80000e32:	26250513          	addi	a0,a0,610 # 80008090 <digits+0x50>
    80000e36:	fffff097          	auipc	ra,0xfffff
    80000e3a:	71a080e7          	jalr	1818(ra) # 80000550 <panic>

0000000080000e3e <release>:
{
    80000e3e:	1101                	addi	sp,sp,-32
    80000e40:	ec06                	sd	ra,24(sp)
    80000e42:	e822                	sd	s0,16(sp)
    80000e44:	e426                	sd	s1,8(sp)
    80000e46:	1000                	addi	s0,sp,32
    80000e48:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e4a:	00000097          	auipc	ra,0x0
    80000e4e:	eaa080e7          	jalr	-342(ra) # 80000cf4 <holding>
    80000e52:	c115                	beqz	a0,80000e76 <release+0x38>
  lk->cpu = 0;
    80000e54:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e58:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e5c:	0f50000f          	fence	iorw,ow
    80000e60:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e64:	00000097          	auipc	ra,0x0
    80000e68:	f7a080e7          	jalr	-134(ra) # 80000dde <pop_off>
}
    80000e6c:	60e2                	ld	ra,24(sp)
    80000e6e:	6442                	ld	s0,16(sp)
    80000e70:	64a2                	ld	s1,8(sp)
    80000e72:	6105                	addi	sp,sp,32
    80000e74:	8082                	ret
    panic("release");
    80000e76:	00007517          	auipc	a0,0x7
    80000e7a:	22250513          	addi	a0,a0,546 # 80008098 <digits+0x58>
    80000e7e:	fffff097          	auipc	ra,0xfffff
    80000e82:	6d2080e7          	jalr	1746(ra) # 80000550 <panic>

0000000080000e86 <freelock>:
{
    80000e86:	1101                	addi	sp,sp,-32
    80000e88:	ec06                	sd	ra,24(sp)
    80000e8a:	e822                	sd	s0,16(sp)
    80000e8c:	e426                	sd	s1,8(sp)
    80000e8e:	1000                	addi	s0,sp,32
    80000e90:	84aa                	mv	s1,a0
  acquire(&lock_locks);
    80000e92:	00010517          	auipc	a0,0x10
    80000e96:	57650513          	addi	a0,a0,1398 # 80011408 <lock_locks>
    80000e9a:	00000097          	auipc	ra,0x0
    80000e9e:	ed4080e7          	jalr	-300(ra) # 80000d6e <acquire>
  for (i = 0; i < NLOCK; i++) {
    80000ea2:	00010717          	auipc	a4,0x10
    80000ea6:	58670713          	addi	a4,a4,1414 # 80011428 <locks>
    80000eaa:	4781                	li	a5,0
    80000eac:	1f400613          	li	a2,500
    if(locks[i] == lk) {
    80000eb0:	6314                	ld	a3,0(a4)
    80000eb2:	00968763          	beq	a3,s1,80000ec0 <freelock+0x3a>
  for (i = 0; i < NLOCK; i++) {
    80000eb6:	2785                	addiw	a5,a5,1
    80000eb8:	0721                	addi	a4,a4,8
    80000eba:	fec79be3          	bne	a5,a2,80000eb0 <freelock+0x2a>
    80000ebe:	a809                	j	80000ed0 <freelock+0x4a>
      locks[i] = 0;
    80000ec0:	078e                	slli	a5,a5,0x3
    80000ec2:	00010717          	auipc	a4,0x10
    80000ec6:	56670713          	addi	a4,a4,1382 # 80011428 <locks>
    80000eca:	97ba                	add	a5,a5,a4
    80000ecc:	0007b023          	sd	zero,0(a5)
  release(&lock_locks);
    80000ed0:	00010517          	auipc	a0,0x10
    80000ed4:	53850513          	addi	a0,a0,1336 # 80011408 <lock_locks>
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	f66080e7          	jalr	-154(ra) # 80000e3e <release>
}
    80000ee0:	60e2                	ld	ra,24(sp)
    80000ee2:	6442                	ld	s0,16(sp)
    80000ee4:	64a2                	ld	s1,8(sp)
    80000ee6:	6105                	addi	sp,sp,32
    80000ee8:	8082                	ret

0000000080000eea <initlock>:
{
    80000eea:	1101                	addi	sp,sp,-32
    80000eec:	ec06                	sd	ra,24(sp)
    80000eee:	e822                	sd	s0,16(sp)
    80000ef0:	e426                	sd	s1,8(sp)
    80000ef2:	1000                	addi	s0,sp,32
    80000ef4:	84aa                	mv	s1,a0
  lk->name = name;
    80000ef6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ef8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000efc:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000f00:	00052c23          	sw	zero,24(a0)
  lk->n = 0;
    80000f04:	00052e23          	sw	zero,28(a0)
  acquire(&lock_locks);
    80000f08:	00010517          	auipc	a0,0x10
    80000f0c:	50050513          	addi	a0,a0,1280 # 80011408 <lock_locks>
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	e5e080e7          	jalr	-418(ra) # 80000d6e <acquire>
  for (i = 0; i < NLOCK; i++) {
    80000f18:	00010717          	auipc	a4,0x10
    80000f1c:	51070713          	addi	a4,a4,1296 # 80011428 <locks>
    80000f20:	4781                	li	a5,0
    80000f22:	1f400693          	li	a3,500
    if(locks[i] == 0) {
    80000f26:	6310                	ld	a2,0(a4)
    80000f28:	ce09                	beqz	a2,80000f42 <initlock+0x58>
  for (i = 0; i < NLOCK; i++) {
    80000f2a:	2785                	addiw	a5,a5,1
    80000f2c:	0721                	addi	a4,a4,8
    80000f2e:	fed79ce3          	bne	a5,a3,80000f26 <initlock+0x3c>
  panic("findslot");
    80000f32:	00007517          	auipc	a0,0x7
    80000f36:	16e50513          	addi	a0,a0,366 # 800080a0 <digits+0x60>
    80000f3a:	fffff097          	auipc	ra,0xfffff
    80000f3e:	616080e7          	jalr	1558(ra) # 80000550 <panic>
      locks[i] = lk;
    80000f42:	078e                	slli	a5,a5,0x3
    80000f44:	00010717          	auipc	a4,0x10
    80000f48:	4e470713          	addi	a4,a4,1252 # 80011428 <locks>
    80000f4c:	97ba                	add	a5,a5,a4
    80000f4e:	e384                	sd	s1,0(a5)
      release(&lock_locks);
    80000f50:	00010517          	auipc	a0,0x10
    80000f54:	4b850513          	addi	a0,a0,1208 # 80011408 <lock_locks>
    80000f58:	00000097          	auipc	ra,0x0
    80000f5c:	ee6080e7          	jalr	-282(ra) # 80000e3e <release>
}
    80000f60:	60e2                	ld	ra,24(sp)
    80000f62:	6442                	ld	s0,16(sp)
    80000f64:	64a2                	ld	s1,8(sp)
    80000f66:	6105                	addi	sp,sp,32
    80000f68:	8082                	ret

0000000080000f6a <snprint_lock>:
#ifdef LAB_LOCK
int
snprint_lock(char *buf, int sz, struct spinlock *lk)
{
  int n = 0;
  if(lk->n > 0) {
    80000f6a:	4e5c                	lw	a5,28(a2)
    80000f6c:	00f04463          	bgtz	a5,80000f74 <snprint_lock+0xa>
  int n = 0;
    80000f70:	4501                	li	a0,0
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
                 lk->name, lk->nts, lk->n);
  }
  return n;
}
    80000f72:	8082                	ret
{
    80000f74:	1141                	addi	sp,sp,-16
    80000f76:	e406                	sd	ra,8(sp)
    80000f78:	e022                	sd	s0,0(sp)
    80000f7a:	0800                	addi	s0,sp,16
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
    80000f7c:	4e18                	lw	a4,24(a2)
    80000f7e:	6614                	ld	a3,8(a2)
    80000f80:	00007617          	auipc	a2,0x7
    80000f84:	13060613          	addi	a2,a2,304 # 800080b0 <digits+0x70>
    80000f88:	00006097          	auipc	ra,0x6
    80000f8c:	98a080e7          	jalr	-1654(ra) # 80006912 <snprintf>
}
    80000f90:	60a2                	ld	ra,8(sp)
    80000f92:	6402                	ld	s0,0(sp)
    80000f94:	0141                	addi	sp,sp,16
    80000f96:	8082                	ret

0000000080000f98 <statslock>:

int
statslock(char *buf, int sz) {
    80000f98:	7159                	addi	sp,sp,-112
    80000f9a:	f486                	sd	ra,104(sp)
    80000f9c:	f0a2                	sd	s0,96(sp)
    80000f9e:	eca6                	sd	s1,88(sp)
    80000fa0:	e8ca                	sd	s2,80(sp)
    80000fa2:	e4ce                	sd	s3,72(sp)
    80000fa4:	e0d2                	sd	s4,64(sp)
    80000fa6:	fc56                	sd	s5,56(sp)
    80000fa8:	f85a                	sd	s6,48(sp)
    80000faa:	f45e                	sd	s7,40(sp)
    80000fac:	f062                	sd	s8,32(sp)
    80000fae:	ec66                	sd	s9,24(sp)
    80000fb0:	e86a                	sd	s10,16(sp)
    80000fb2:	e46e                	sd	s11,8(sp)
    80000fb4:	1880                	addi	s0,sp,112
    80000fb6:	8aaa                	mv	s5,a0
    80000fb8:	8b2e                	mv	s6,a1
  int n;
  int tot = 0;

  acquire(&lock_locks);
    80000fba:	00010517          	auipc	a0,0x10
    80000fbe:	44e50513          	addi	a0,a0,1102 # 80011408 <lock_locks>
    80000fc2:	00000097          	auipc	ra,0x0
    80000fc6:	dac080e7          	jalr	-596(ra) # 80000d6e <acquire>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80000fca:	00007617          	auipc	a2,0x7
    80000fce:	11660613          	addi	a2,a2,278 # 800080e0 <digits+0xa0>
    80000fd2:	85da                	mv	a1,s6
    80000fd4:	8556                	mv	a0,s5
    80000fd6:	00006097          	auipc	ra,0x6
    80000fda:	93c080e7          	jalr	-1732(ra) # 80006912 <snprintf>
    80000fde:	892a                	mv	s2,a0
  for(int i = 0; i < NLOCK; i++) {
    80000fe0:	00010c97          	auipc	s9,0x10
    80000fe4:	448c8c93          	addi	s9,s9,1096 # 80011428 <locks>
    80000fe8:	00011c17          	auipc	s8,0x11
    80000fec:	3e0c0c13          	addi	s8,s8,992 # 800123c8 <pid_lock>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80000ff0:	84e6                	mv	s1,s9
  int tot = 0;
    80000ff2:	4a01                	li	s4,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000ff4:	00007b97          	auipc	s7,0x7
    80000ff8:	10cb8b93          	addi	s7,s7,268 # 80008100 <digits+0xc0>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000ffc:	00007d17          	auipc	s10,0x7
    80001000:	10cd0d13          	addi	s10,s10,268 # 80008108 <digits+0xc8>
    80001004:	a01d                	j	8000102a <statslock+0x92>
      tot += locks[i]->nts;
    80001006:	0009b603          	ld	a2,0(s3)
    8000100a:	4e1c                	lw	a5,24(a2)
    8000100c:	01478a3b          	addw	s4,a5,s4
      n += snprint_lock(buf +n, sz-n, locks[i]);
    80001010:	412b05bb          	subw	a1,s6,s2
    80001014:	012a8533          	add	a0,s5,s2
    80001018:	00000097          	auipc	ra,0x0
    8000101c:	f52080e7          	jalr	-174(ra) # 80000f6a <snprint_lock>
    80001020:	0125093b          	addw	s2,a0,s2
  for(int i = 0; i < NLOCK; i++) {
    80001024:	04a1                	addi	s1,s1,8
    80001026:	05848763          	beq	s1,s8,80001074 <statslock+0xdc>
    if(locks[i] == 0)
    8000102a:	89a6                	mv	s3,s1
    8000102c:	609c                	ld	a5,0(s1)
    8000102e:	c3b9                	beqz	a5,80001074 <statslock+0xdc>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80001030:	0087bd83          	ld	s11,8(a5)
    80001034:	855e                	mv	a0,s7
    80001036:	00000097          	auipc	ra,0x0
    8000103a:	2a0080e7          	jalr	672(ra) # 800012d6 <strlen>
    8000103e:	0005061b          	sext.w	a2,a0
    80001042:	85de                	mv	a1,s7
    80001044:	856e                	mv	a0,s11
    80001046:	00000097          	auipc	ra,0x0
    8000104a:	1e4080e7          	jalr	484(ra) # 8000122a <strncmp>
    8000104e:	dd45                	beqz	a0,80001006 <statslock+0x6e>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80001050:	609c                	ld	a5,0(s1)
    80001052:	0087bd83          	ld	s11,8(a5)
    80001056:	856a                	mv	a0,s10
    80001058:	00000097          	auipc	ra,0x0
    8000105c:	27e080e7          	jalr	638(ra) # 800012d6 <strlen>
    80001060:	0005061b          	sext.w	a2,a0
    80001064:	85ea                	mv	a1,s10
    80001066:	856e                	mv	a0,s11
    80001068:	00000097          	auipc	ra,0x0
    8000106c:	1c2080e7          	jalr	450(ra) # 8000122a <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80001070:	f955                	bnez	a0,80001024 <statslock+0x8c>
    80001072:	bf51                	j	80001006 <statslock+0x6e>
    }
  }
  
  n += snprintf(buf+n, sz-n, "--- top 5 contended locks:\n");
    80001074:	00007617          	auipc	a2,0x7
    80001078:	09c60613          	addi	a2,a2,156 # 80008110 <digits+0xd0>
    8000107c:	412b05bb          	subw	a1,s6,s2
    80001080:	012a8533          	add	a0,s5,s2
    80001084:	00006097          	auipc	ra,0x6
    80001088:	88e080e7          	jalr	-1906(ra) # 80006912 <snprintf>
    8000108c:	012509bb          	addw	s3,a0,s2
    80001090:	4b95                	li	s7,5
  int last = 100000000;
    80001092:	05f5e537          	lui	a0,0x5f5e
    80001096:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t = 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    8000109a:	4c01                	li	s8,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    8000109c:	00010497          	auipc	s1,0x10
    800010a0:	38c48493          	addi	s1,s1,908 # 80011428 <locks>
    for(int i = 0; i < NLOCK; i++) {
    800010a4:	1f400913          	li	s2,500
    800010a8:	a881                	j	800010f8 <statslock+0x160>
    800010aa:	2705                	addiw	a4,a4,1
    800010ac:	06a1                	addi	a3,a3,8
    800010ae:	03270063          	beq	a4,s2,800010ce <statslock+0x136>
      if(locks[i] == 0)
    800010b2:	629c                	ld	a5,0(a3)
    800010b4:	cf89                	beqz	a5,800010ce <statslock+0x136>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    800010b6:	4f90                	lw	a2,24(a5)
    800010b8:	00359793          	slli	a5,a1,0x3
    800010bc:	97a6                	add	a5,a5,s1
    800010be:	639c                	ld	a5,0(a5)
    800010c0:	4f9c                	lw	a5,24(a5)
    800010c2:	fec7d4e3          	bge	a5,a2,800010aa <statslock+0x112>
    800010c6:	fea652e3          	bge	a2,a0,800010aa <statslock+0x112>
    800010ca:	85ba                	mv	a1,a4
    800010cc:	bff9                	j	800010aa <statslock+0x112>
        top = i;
      }
    }
    n += snprint_lock(buf+n, sz-n, locks[top]);
    800010ce:	058e                	slli	a1,a1,0x3
    800010d0:	00b48d33          	add	s10,s1,a1
    800010d4:	000d3603          	ld	a2,0(s10)
    800010d8:	413b05bb          	subw	a1,s6,s3
    800010dc:	013a8533          	add	a0,s5,s3
    800010e0:	00000097          	auipc	ra,0x0
    800010e4:	e8a080e7          	jalr	-374(ra) # 80000f6a <snprint_lock>
    800010e8:	013509bb          	addw	s3,a0,s3
    last = locks[top]->nts;
    800010ec:	000d3783          	ld	a5,0(s10)
    800010f0:	4f88                	lw	a0,24(a5)
  for(int t = 0; t < 5; t++) {
    800010f2:	3bfd                	addiw	s7,s7,-1
    800010f4:	000b8663          	beqz	s7,80001100 <statslock+0x168>
  int tot = 0;
    800010f8:	86e6                	mv	a3,s9
    for(int i = 0; i < NLOCK; i++) {
    800010fa:	8762                	mv	a4,s8
    int top = 0;
    800010fc:	85e2                	mv	a1,s8
    800010fe:	bf55                	j	800010b2 <statslock+0x11a>
  }
  n += snprintf(buf+n, sz-n, "tot= %d\n", tot);
    80001100:	86d2                	mv	a3,s4
    80001102:	00007617          	auipc	a2,0x7
    80001106:	02e60613          	addi	a2,a2,46 # 80008130 <digits+0xf0>
    8000110a:	413b05bb          	subw	a1,s6,s3
    8000110e:	013a8533          	add	a0,s5,s3
    80001112:	00006097          	auipc	ra,0x6
    80001116:	800080e7          	jalr	-2048(ra) # 80006912 <snprintf>
    8000111a:	013509bb          	addw	s3,a0,s3
  release(&lock_locks);  
    8000111e:	00010517          	auipc	a0,0x10
    80001122:	2ea50513          	addi	a0,a0,746 # 80011408 <lock_locks>
    80001126:	00000097          	auipc	ra,0x0
    8000112a:	d18080e7          	jalr	-744(ra) # 80000e3e <release>
  return n;
}
    8000112e:	854e                	mv	a0,s3
    80001130:	70a6                	ld	ra,104(sp)
    80001132:	7406                	ld	s0,96(sp)
    80001134:	64e6                	ld	s1,88(sp)
    80001136:	6946                	ld	s2,80(sp)
    80001138:	69a6                	ld	s3,72(sp)
    8000113a:	6a06                	ld	s4,64(sp)
    8000113c:	7ae2                	ld	s5,56(sp)
    8000113e:	7b42                	ld	s6,48(sp)
    80001140:	7ba2                	ld	s7,40(sp)
    80001142:	7c02                	ld	s8,32(sp)
    80001144:	6ce2                	ld	s9,24(sp)
    80001146:	6d42                	ld	s10,16(sp)
    80001148:	6da2                	ld	s11,8(sp)
    8000114a:	6165                	addi	sp,sp,112
    8000114c:	8082                	ret

000000008000114e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000114e:	1141                	addi	sp,sp,-16
    80001150:	e422                	sd	s0,8(sp)
    80001152:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80001154:	ce09                	beqz	a2,8000116e <memset+0x20>
    80001156:	87aa                	mv	a5,a0
    80001158:	fff6071b          	addiw	a4,a2,-1
    8000115c:	1702                	slli	a4,a4,0x20
    8000115e:	9301                	srli	a4,a4,0x20
    80001160:	0705                	addi	a4,a4,1
    80001162:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80001164:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80001168:	0785                	addi	a5,a5,1
    8000116a:	fee79de3          	bne	a5,a4,80001164 <memset+0x16>
  }
  return dst;
}
    8000116e:	6422                	ld	s0,8(sp)
    80001170:	0141                	addi	sp,sp,16
    80001172:	8082                	ret

0000000080001174 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80001174:	1141                	addi	sp,sp,-16
    80001176:	e422                	sd	s0,8(sp)
    80001178:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000117a:	ca05                	beqz	a2,800011aa <memcmp+0x36>
    8000117c:	fff6069b          	addiw	a3,a2,-1
    80001180:	1682                	slli	a3,a3,0x20
    80001182:	9281                	srli	a3,a3,0x20
    80001184:	0685                	addi	a3,a3,1
    80001186:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80001188:	00054783          	lbu	a5,0(a0)
    8000118c:	0005c703          	lbu	a4,0(a1)
    80001190:	00e79863          	bne	a5,a4,800011a0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80001194:	0505                	addi	a0,a0,1
    80001196:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80001198:	fed518e3          	bne	a0,a3,80001188 <memcmp+0x14>
  }

  return 0;
    8000119c:	4501                	li	a0,0
    8000119e:	a019                	j	800011a4 <memcmp+0x30>
      return *s1 - *s2;
    800011a0:	40e7853b          	subw	a0,a5,a4
}
    800011a4:	6422                	ld	s0,8(sp)
    800011a6:	0141                	addi	sp,sp,16
    800011a8:	8082                	ret
  return 0;
    800011aa:	4501                	li	a0,0
    800011ac:	bfe5                	j	800011a4 <memcmp+0x30>

00000000800011ae <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800011ae:	1141                	addi	sp,sp,-16
    800011b0:	e422                	sd	s0,8(sp)
    800011b2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    800011b4:	00a5f963          	bgeu	a1,a0,800011c6 <memmove+0x18>
    800011b8:	02061713          	slli	a4,a2,0x20
    800011bc:	9301                	srli	a4,a4,0x20
    800011be:	00e587b3          	add	a5,a1,a4
    800011c2:	02f56563          	bltu	a0,a5,800011ec <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800011c6:	fff6069b          	addiw	a3,a2,-1
    800011ca:	ce11                	beqz	a2,800011e6 <memmove+0x38>
    800011cc:	1682                	slli	a3,a3,0x20
    800011ce:	9281                	srli	a3,a3,0x20
    800011d0:	0685                	addi	a3,a3,1
    800011d2:	96ae                	add	a3,a3,a1
    800011d4:	87aa                	mv	a5,a0
      *d++ = *s++;
    800011d6:	0585                	addi	a1,a1,1
    800011d8:	0785                	addi	a5,a5,1
    800011da:	fff5c703          	lbu	a4,-1(a1)
    800011de:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    800011e2:	fed59ae3          	bne	a1,a3,800011d6 <memmove+0x28>

  return dst;
}
    800011e6:	6422                	ld	s0,8(sp)
    800011e8:	0141                	addi	sp,sp,16
    800011ea:	8082                	ret
    d += n;
    800011ec:	972a                	add	a4,a4,a0
    while(n-- > 0)
    800011ee:	fff6069b          	addiw	a3,a2,-1
    800011f2:	da75                	beqz	a2,800011e6 <memmove+0x38>
    800011f4:	02069613          	slli	a2,a3,0x20
    800011f8:	9201                	srli	a2,a2,0x20
    800011fa:	fff64613          	not	a2,a2
    800011fe:	963e                	add	a2,a2,a5
      *--d = *--s;
    80001200:	17fd                	addi	a5,a5,-1
    80001202:	177d                	addi	a4,a4,-1
    80001204:	0007c683          	lbu	a3,0(a5)
    80001208:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    8000120c:	fec79ae3          	bne	a5,a2,80001200 <memmove+0x52>
    80001210:	bfd9                	j	800011e6 <memmove+0x38>

0000000080001212 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80001212:	1141                	addi	sp,sp,-16
    80001214:	e406                	sd	ra,8(sp)
    80001216:	e022                	sd	s0,0(sp)
    80001218:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	f94080e7          	jalr	-108(ra) # 800011ae <memmove>
}
    80001222:	60a2                	ld	ra,8(sp)
    80001224:	6402                	ld	s0,0(sp)
    80001226:	0141                	addi	sp,sp,16
    80001228:	8082                	ret

000000008000122a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000122a:	1141                	addi	sp,sp,-16
    8000122c:	e422                	sd	s0,8(sp)
    8000122e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001230:	ce11                	beqz	a2,8000124c <strncmp+0x22>
    80001232:	00054783          	lbu	a5,0(a0)
    80001236:	cf89                	beqz	a5,80001250 <strncmp+0x26>
    80001238:	0005c703          	lbu	a4,0(a1)
    8000123c:	00f71a63          	bne	a4,a5,80001250 <strncmp+0x26>
    n--, p++, q++;
    80001240:	367d                	addiw	a2,a2,-1
    80001242:	0505                	addi	a0,a0,1
    80001244:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80001246:	f675                	bnez	a2,80001232 <strncmp+0x8>
  if(n == 0)
    return 0;
    80001248:	4501                	li	a0,0
    8000124a:	a809                	j	8000125c <strncmp+0x32>
    8000124c:	4501                	li	a0,0
    8000124e:	a039                	j	8000125c <strncmp+0x32>
  if(n == 0)
    80001250:	ca09                	beqz	a2,80001262 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80001252:	00054503          	lbu	a0,0(a0)
    80001256:	0005c783          	lbu	a5,0(a1)
    8000125a:	9d1d                	subw	a0,a0,a5
}
    8000125c:	6422                	ld	s0,8(sp)
    8000125e:	0141                	addi	sp,sp,16
    80001260:	8082                	ret
    return 0;
    80001262:	4501                	li	a0,0
    80001264:	bfe5                	j	8000125c <strncmp+0x32>

0000000080001266 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80001266:	1141                	addi	sp,sp,-16
    80001268:	e422                	sd	s0,8(sp)
    8000126a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000126c:	872a                	mv	a4,a0
    8000126e:	8832                	mv	a6,a2
    80001270:	367d                	addiw	a2,a2,-1
    80001272:	01005963          	blez	a6,80001284 <strncpy+0x1e>
    80001276:	0705                	addi	a4,a4,1
    80001278:	0005c783          	lbu	a5,0(a1)
    8000127c:	fef70fa3          	sb	a5,-1(a4)
    80001280:	0585                	addi	a1,a1,1
    80001282:	f7f5                	bnez	a5,8000126e <strncpy+0x8>
    ;
  while(n-- > 0)
    80001284:	00c05d63          	blez	a2,8000129e <strncpy+0x38>
    80001288:	86ba                	mv	a3,a4
    *s++ = 0;
    8000128a:	0685                	addi	a3,a3,1
    8000128c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001290:	fff6c793          	not	a5,a3
    80001294:	9fb9                	addw	a5,a5,a4
    80001296:	010787bb          	addw	a5,a5,a6
    8000129a:	fef048e3          	bgtz	a5,8000128a <strncpy+0x24>
  return os;
}
    8000129e:	6422                	ld	s0,8(sp)
    800012a0:	0141                	addi	sp,sp,16
    800012a2:	8082                	ret

00000000800012a4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800012a4:	1141                	addi	sp,sp,-16
    800012a6:	e422                	sd	s0,8(sp)
    800012a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800012aa:	02c05363          	blez	a2,800012d0 <safestrcpy+0x2c>
    800012ae:	fff6069b          	addiw	a3,a2,-1
    800012b2:	1682                	slli	a3,a3,0x20
    800012b4:	9281                	srli	a3,a3,0x20
    800012b6:	96ae                	add	a3,a3,a1
    800012b8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800012ba:	00d58963          	beq	a1,a3,800012cc <safestrcpy+0x28>
    800012be:	0585                	addi	a1,a1,1
    800012c0:	0785                	addi	a5,a5,1
    800012c2:	fff5c703          	lbu	a4,-1(a1)
    800012c6:	fee78fa3          	sb	a4,-1(a5)
    800012ca:	fb65                	bnez	a4,800012ba <safestrcpy+0x16>
    ;
  *s = 0;
    800012cc:	00078023          	sb	zero,0(a5)
  return os;
}
    800012d0:	6422                	ld	s0,8(sp)
    800012d2:	0141                	addi	sp,sp,16
    800012d4:	8082                	ret

00000000800012d6 <strlen>:

int
strlen(const char *s)
{
    800012d6:	1141                	addi	sp,sp,-16
    800012d8:	e422                	sd	s0,8(sp)
    800012da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800012dc:	00054783          	lbu	a5,0(a0)
    800012e0:	cf91                	beqz	a5,800012fc <strlen+0x26>
    800012e2:	0505                	addi	a0,a0,1
    800012e4:	87aa                	mv	a5,a0
    800012e6:	4685                	li	a3,1
    800012e8:	9e89                	subw	a3,a3,a0
    800012ea:	00f6853b          	addw	a0,a3,a5
    800012ee:	0785                	addi	a5,a5,1
    800012f0:	fff7c703          	lbu	a4,-1(a5)
    800012f4:	fb7d                	bnez	a4,800012ea <strlen+0x14>
    ;
  return n;
}
    800012f6:	6422                	ld	s0,8(sp)
    800012f8:	0141                	addi	sp,sp,16
    800012fa:	8082                	ret
  for(n = 0; s[n]; n++)
    800012fc:	4501                	li	a0,0
    800012fe:	bfe5                	j	800012f6 <strlen+0x20>

0000000080001300 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001300:	1141                	addi	sp,sp,-16
    80001302:	e406                	sd	ra,8(sp)
    80001304:	e022                	sd	s0,0(sp)
    80001306:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001308:	00001097          	auipc	ra,0x1
    8000130c:	a82080e7          	jalr	-1406(ra) # 80001d8a <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001310:	00008717          	auipc	a4,0x8
    80001314:	cfc70713          	addi	a4,a4,-772 # 8000900c <started>
  if(cpuid() == 0){
    80001318:	c139                	beqz	a0,8000135e <main+0x5e>
    while(started == 0)
    8000131a:	431c                	lw	a5,0(a4)
    8000131c:	2781                	sext.w	a5,a5
    8000131e:	dff5                	beqz	a5,8000131a <main+0x1a>
      ;
    __sync_synchronize();
    80001320:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001324:	00001097          	auipc	ra,0x1
    80001328:	a66080e7          	jalr	-1434(ra) # 80001d8a <cpuid>
    8000132c:	85aa                	mv	a1,a0
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	e2a50513          	addi	a0,a0,-470 # 80008158 <digits+0x118>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	264080e7          	jalr	612(ra) # 8000059a <printf>
    kvminithart();    // turn on paging
    8000133e:	00000097          	auipc	ra,0x0
    80001342:	186080e7          	jalr	390(ra) # 800014c4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001346:	00001097          	auipc	ra,0x1
    8000134a:	6ce080e7          	jalr	1742(ra) # 80002a14 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000134e:	00005097          	auipc	ra,0x5
    80001352:	e02080e7          	jalr	-510(ra) # 80006150 <plicinithart>
  }

  scheduler();        
    80001356:	00001097          	auipc	ra,0x1
    8000135a:	f90080e7          	jalr	-112(ra) # 800022e6 <scheduler>
    consoleinit();
    8000135e:	fffff097          	auipc	ra,0xfffff
    80001362:	104080e7          	jalr	260(ra) # 80000462 <consoleinit>
    statsinit();
    80001366:	00005097          	auipc	ra,0x5
    8000136a:	4d0080e7          	jalr	1232(ra) # 80006836 <statsinit>
    printfinit();
    8000136e:	fffff097          	auipc	ra,0xfffff
    80001372:	412080e7          	jalr	1042(ra) # 80000780 <printfinit>
    printf("\n");
    80001376:	00007517          	auipc	a0,0x7
    8000137a:	df250513          	addi	a0,a0,-526 # 80008168 <digits+0x128>
    8000137e:	fffff097          	auipc	ra,0xfffff
    80001382:	21c080e7          	jalr	540(ra) # 8000059a <printf>
    printf("xv6 kernel is booting\n");
    80001386:	00007517          	auipc	a0,0x7
    8000138a:	dba50513          	addi	a0,a0,-582 # 80008140 <digits+0x100>
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	20c080e7          	jalr	524(ra) # 8000059a <printf>
    printf("\n");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	dd250513          	addi	a0,a0,-558 # 80008168 <digits+0x128>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	1fc080e7          	jalr	508(ra) # 8000059a <printf>
    kinit();         // physical page allocator
    800013a6:	fffff097          	auipc	ra,0xfffff
    800013aa:	776080e7          	jalr	1910(ra) # 80000b1c <kinit>
    kvminit();       // create kernel page table
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	242080e7          	jalr	578(ra) # 800015f0 <kvminit>
    kvminithart();   // turn on paging
    800013b6:	00000097          	auipc	ra,0x0
    800013ba:	10e080e7          	jalr	270(ra) # 800014c4 <kvminithart>
    procinit();      // process table
    800013be:	00001097          	auipc	ra,0x1
    800013c2:	8fc080e7          	jalr	-1796(ra) # 80001cba <procinit>
    trapinit();      // trap vectors
    800013c6:	00001097          	auipc	ra,0x1
    800013ca:	626080e7          	jalr	1574(ra) # 800029ec <trapinit>
    trapinithart();  // install kernel trap vector
    800013ce:	00001097          	auipc	ra,0x1
    800013d2:	646080e7          	jalr	1606(ra) # 80002a14 <trapinithart>
    plicinit();      // set up interrupt controller
    800013d6:	00005097          	auipc	ra,0x5
    800013da:	d64080e7          	jalr	-668(ra) # 8000613a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800013de:	00005097          	auipc	ra,0x5
    800013e2:	d72080e7          	jalr	-654(ra) # 80006150 <plicinithart>
    binit();         // buffer cache
    800013e6:	00002097          	auipc	ra,0x2
    800013ea:	d82080e7          	jalr	-638(ra) # 80003168 <binit>
    iinit();         // inode cache
    800013ee:	00002097          	auipc	ra,0x2
    800013f2:	582080e7          	jalr	1410(ra) # 80003970 <iinit>
    fileinit();      // file table
    800013f6:	00003097          	auipc	ra,0x3
    800013fa:	532080e7          	jalr	1330(ra) # 80004928 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800013fe:	00005097          	auipc	ra,0x5
    80001402:	e74080e7          	jalr	-396(ra) # 80006272 <virtio_disk_init>
    userinit();      // first user process
    80001406:	00001097          	auipc	ra,0x1
    8000140a:	c7a080e7          	jalr	-902(ra) # 80002080 <userinit>
    __sync_synchronize();
    8000140e:	0ff0000f          	fence
    started = 1;
    80001412:	4785                	li	a5,1
    80001414:	00008717          	auipc	a4,0x8
    80001418:	bef72c23          	sw	a5,-1032(a4) # 8000900c <started>
    8000141c:	bf2d                	j	80001356 <main+0x56>

000000008000141e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000141e:	7139                	addi	sp,sp,-64
    80001420:	fc06                	sd	ra,56(sp)
    80001422:	f822                	sd	s0,48(sp)
    80001424:	f426                	sd	s1,40(sp)
    80001426:	f04a                	sd	s2,32(sp)
    80001428:	ec4e                	sd	s3,24(sp)
    8000142a:	e852                	sd	s4,16(sp)
    8000142c:	e456                	sd	s5,8(sp)
    8000142e:	e05a                	sd	s6,0(sp)
    80001430:	0080                	addi	s0,sp,64
    80001432:	84aa                	mv	s1,a0
    80001434:	89ae                	mv	s3,a1
    80001436:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001438:	57fd                	li	a5,-1
    8000143a:	83e9                	srli	a5,a5,0x1a
    8000143c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000143e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001440:	04b7f263          	bgeu	a5,a1,80001484 <walk+0x66>
    panic("walk");
    80001444:	00007517          	auipc	a0,0x7
    80001448:	d2c50513          	addi	a0,a0,-724 # 80008170 <digits+0x130>
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	104080e7          	jalr	260(ra) # 80000550 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001454:	060a8663          	beqz	s5,800014c0 <walk+0xa2>
    80001458:	fffff097          	auipc	ra,0xfffff
    8000145c:	73a080e7          	jalr	1850(ra) # 80000b92 <kalloc>
    80001460:	84aa                	mv	s1,a0
    80001462:	c529                	beqz	a0,800014ac <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001464:	6605                	lui	a2,0x1
    80001466:	4581                	li	a1,0
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	ce6080e7          	jalr	-794(ra) # 8000114e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001470:	00c4d793          	srli	a5,s1,0xc
    80001474:	07aa                	slli	a5,a5,0xa
    80001476:	0017e793          	ori	a5,a5,1
    8000147a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000147e:	3a5d                	addiw	s4,s4,-9
    80001480:	036a0063          	beq	s4,s6,800014a0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001484:	0149d933          	srl	s2,s3,s4
    80001488:	1ff97913          	andi	s2,s2,511
    8000148c:	090e                	slli	s2,s2,0x3
    8000148e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001490:	00093483          	ld	s1,0(s2)
    80001494:	0014f793          	andi	a5,s1,1
    80001498:	dfd5                	beqz	a5,80001454 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000149a:	80a9                	srli	s1,s1,0xa
    8000149c:	04b2                	slli	s1,s1,0xc
    8000149e:	b7c5                	j	8000147e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800014a0:	00c9d513          	srli	a0,s3,0xc
    800014a4:	1ff57513          	andi	a0,a0,511
    800014a8:	050e                	slli	a0,a0,0x3
    800014aa:	9526                	add	a0,a0,s1
}
    800014ac:	70e2                	ld	ra,56(sp)
    800014ae:	7442                	ld	s0,48(sp)
    800014b0:	74a2                	ld	s1,40(sp)
    800014b2:	7902                	ld	s2,32(sp)
    800014b4:	69e2                	ld	s3,24(sp)
    800014b6:	6a42                	ld	s4,16(sp)
    800014b8:	6aa2                	ld	s5,8(sp)
    800014ba:	6b02                	ld	s6,0(sp)
    800014bc:	6121                	addi	sp,sp,64
    800014be:	8082                	ret
        return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	b7ed                	j	800014ac <walk+0x8e>

00000000800014c4 <kvminithart>:
{
    800014c4:	1141                	addi	sp,sp,-16
    800014c6:	e422                	sd	s0,8(sp)
    800014c8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    800014ca:	00008797          	auipc	a5,0x8
    800014ce:	b467b783          	ld	a5,-1210(a5) # 80009010 <kernel_pagetable>
    800014d2:	83b1                	srli	a5,a5,0xc
    800014d4:	577d                	li	a4,-1
    800014d6:	177e                	slli	a4,a4,0x3f
    800014d8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800014da:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800014de:	12000073          	sfence.vma
}
    800014e2:	6422                	ld	s0,8(sp)
    800014e4:	0141                	addi	sp,sp,16
    800014e6:	8082                	ret

00000000800014e8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800014e8:	57fd                	li	a5,-1
    800014ea:	83e9                	srli	a5,a5,0x1a
    800014ec:	00b7f463          	bgeu	a5,a1,800014f4 <walkaddr+0xc>
    return 0;
    800014f0:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800014f2:	8082                	ret
{
    800014f4:	1141                	addi	sp,sp,-16
    800014f6:	e406                	sd	ra,8(sp)
    800014f8:	e022                	sd	s0,0(sp)
    800014fa:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800014fc:	4601                	li	a2,0
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	f20080e7          	jalr	-224(ra) # 8000141e <walk>
  if(pte == 0)
    80001506:	c105                	beqz	a0,80001526 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001508:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000150a:	0117f693          	andi	a3,a5,17
    8000150e:	4745                	li	a4,17
    return 0;
    80001510:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001512:	00e68663          	beq	a3,a4,8000151e <walkaddr+0x36>
}
    80001516:	60a2                	ld	ra,8(sp)
    80001518:	6402                	ld	s0,0(sp)
    8000151a:	0141                	addi	sp,sp,16
    8000151c:	8082                	ret
  pa = PTE2PA(*pte);
    8000151e:	00a7d513          	srli	a0,a5,0xa
    80001522:	0532                	slli	a0,a0,0xc
  return pa;
    80001524:	bfcd                	j	80001516 <walkaddr+0x2e>
    return 0;
    80001526:	4501                	li	a0,0
    80001528:	b7fd                	j	80001516 <walkaddr+0x2e>

000000008000152a <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000152a:	715d                	addi	sp,sp,-80
    8000152c:	e486                	sd	ra,72(sp)
    8000152e:	e0a2                	sd	s0,64(sp)
    80001530:	fc26                	sd	s1,56(sp)
    80001532:	f84a                	sd	s2,48(sp)
    80001534:	f44e                	sd	s3,40(sp)
    80001536:	f052                	sd	s4,32(sp)
    80001538:	ec56                	sd	s5,24(sp)
    8000153a:	e85a                	sd	s6,16(sp)
    8000153c:	e45e                	sd	s7,8(sp)
    8000153e:	0880                	addi	s0,sp,80
    80001540:	8aaa                	mv	s5,a0
    80001542:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001544:	777d                	lui	a4,0xfffff
    80001546:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000154a:	167d                	addi	a2,a2,-1
    8000154c:	00b609b3          	add	s3,a2,a1
    80001550:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001554:	893e                	mv	s2,a5
    80001556:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000155a:	6b85                	lui	s7,0x1
    8000155c:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001560:	4605                	li	a2,1
    80001562:	85ca                	mv	a1,s2
    80001564:	8556                	mv	a0,s5
    80001566:	00000097          	auipc	ra,0x0
    8000156a:	eb8080e7          	jalr	-328(ra) # 8000141e <walk>
    8000156e:	c51d                	beqz	a0,8000159c <mappages+0x72>
    if(*pte & PTE_V)
    80001570:	611c                	ld	a5,0(a0)
    80001572:	8b85                	andi	a5,a5,1
    80001574:	ef81                	bnez	a5,8000158c <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001576:	80b1                	srli	s1,s1,0xc
    80001578:	04aa                	slli	s1,s1,0xa
    8000157a:	0164e4b3          	or	s1,s1,s6
    8000157e:	0014e493          	ori	s1,s1,1
    80001582:	e104                	sd	s1,0(a0)
    if(a == last)
    80001584:	03390863          	beq	s2,s3,800015b4 <mappages+0x8a>
    a += PGSIZE;
    80001588:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000158a:	bfc9                	j	8000155c <mappages+0x32>
      panic("remap");
    8000158c:	00007517          	auipc	a0,0x7
    80001590:	bec50513          	addi	a0,a0,-1044 # 80008178 <digits+0x138>
    80001594:	fffff097          	auipc	ra,0xfffff
    80001598:	fbc080e7          	jalr	-68(ra) # 80000550 <panic>
      return -1;
    8000159c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000159e:	60a6                	ld	ra,72(sp)
    800015a0:	6406                	ld	s0,64(sp)
    800015a2:	74e2                	ld	s1,56(sp)
    800015a4:	7942                	ld	s2,48(sp)
    800015a6:	79a2                	ld	s3,40(sp)
    800015a8:	7a02                	ld	s4,32(sp)
    800015aa:	6ae2                	ld	s5,24(sp)
    800015ac:	6b42                	ld	s6,16(sp)
    800015ae:	6ba2                	ld	s7,8(sp)
    800015b0:	6161                	addi	sp,sp,80
    800015b2:	8082                	ret
  return 0;
    800015b4:	4501                	li	a0,0
    800015b6:	b7e5                	j	8000159e <mappages+0x74>

00000000800015b8 <kvmmap>:
{
    800015b8:	1141                	addi	sp,sp,-16
    800015ba:	e406                	sd	ra,8(sp)
    800015bc:	e022                	sd	s0,0(sp)
    800015be:	0800                	addi	s0,sp,16
    800015c0:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800015c2:	86ae                	mv	a3,a1
    800015c4:	85aa                	mv	a1,a0
    800015c6:	00008517          	auipc	a0,0x8
    800015ca:	a4a53503          	ld	a0,-1462(a0) # 80009010 <kernel_pagetable>
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	f5c080e7          	jalr	-164(ra) # 8000152a <mappages>
    800015d6:	e509                	bnez	a0,800015e0 <kvmmap+0x28>
}
    800015d8:	60a2                	ld	ra,8(sp)
    800015da:	6402                	ld	s0,0(sp)
    800015dc:	0141                	addi	sp,sp,16
    800015de:	8082                	ret
    panic("kvmmap");
    800015e0:	00007517          	auipc	a0,0x7
    800015e4:	ba050513          	addi	a0,a0,-1120 # 80008180 <digits+0x140>
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	f68080e7          	jalr	-152(ra) # 80000550 <panic>

00000000800015f0 <kvminit>:
{
    800015f0:	1101                	addi	sp,sp,-32
    800015f2:	ec06                	sd	ra,24(sp)
    800015f4:	e822                	sd	s0,16(sp)
    800015f6:	e426                	sd	s1,8(sp)
    800015f8:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	598080e7          	jalr	1432(ra) # 80000b92 <kalloc>
    80001602:	00008797          	auipc	a5,0x8
    80001606:	a0a7b723          	sd	a0,-1522(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000160a:	6605                	lui	a2,0x1
    8000160c:	4581                	li	a1,0
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	b40080e7          	jalr	-1216(ra) # 8000114e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001616:	4699                	li	a3,6
    80001618:	6605                	lui	a2,0x1
    8000161a:	100005b7          	lui	a1,0x10000
    8000161e:	10000537          	lui	a0,0x10000
    80001622:	00000097          	auipc	ra,0x0
    80001626:	f96080e7          	jalr	-106(ra) # 800015b8 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000162a:	4699                	li	a3,6
    8000162c:	6605                	lui	a2,0x1
    8000162e:	100015b7          	lui	a1,0x10001
    80001632:	10001537          	lui	a0,0x10001
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	f82080e7          	jalr	-126(ra) # 800015b8 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000163e:	4699                	li	a3,6
    80001640:	00400637          	lui	a2,0x400
    80001644:	0c0005b7          	lui	a1,0xc000
    80001648:	0c000537          	lui	a0,0xc000
    8000164c:	00000097          	auipc	ra,0x0
    80001650:	f6c080e7          	jalr	-148(ra) # 800015b8 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001654:	00007497          	auipc	s1,0x7
    80001658:	9ac48493          	addi	s1,s1,-1620 # 80008000 <etext>
    8000165c:	46a9                	li	a3,10
    8000165e:	80007617          	auipc	a2,0x80007
    80001662:	9a260613          	addi	a2,a2,-1630 # 8000 <_entry-0x7fff8000>
    80001666:	4585                	li	a1,1
    80001668:	05fe                	slli	a1,a1,0x1f
    8000166a:	852e                	mv	a0,a1
    8000166c:	00000097          	auipc	ra,0x0
    80001670:	f4c080e7          	jalr	-180(ra) # 800015b8 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001674:	4699                	li	a3,6
    80001676:	4645                	li	a2,17
    80001678:	066e                	slli	a2,a2,0x1b
    8000167a:	8e05                	sub	a2,a2,s1
    8000167c:	85a6                	mv	a1,s1
    8000167e:	8526                	mv	a0,s1
    80001680:	00000097          	auipc	ra,0x0
    80001684:	f38080e7          	jalr	-200(ra) # 800015b8 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001688:	46a9                	li	a3,10
    8000168a:	6605                	lui	a2,0x1
    8000168c:	00006597          	auipc	a1,0x6
    80001690:	97458593          	addi	a1,a1,-1676 # 80007000 <_trampoline>
    80001694:	04000537          	lui	a0,0x4000
    80001698:	157d                	addi	a0,a0,-1
    8000169a:	0532                	slli	a0,a0,0xc
    8000169c:	00000097          	auipc	ra,0x0
    800016a0:	f1c080e7          	jalr	-228(ra) # 800015b8 <kvmmap>
}
    800016a4:	60e2                	ld	ra,24(sp)
    800016a6:	6442                	ld	s0,16(sp)
    800016a8:	64a2                	ld	s1,8(sp)
    800016aa:	6105                	addi	sp,sp,32
    800016ac:	8082                	ret

00000000800016ae <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800016ae:	715d                	addi	sp,sp,-80
    800016b0:	e486                	sd	ra,72(sp)
    800016b2:	e0a2                	sd	s0,64(sp)
    800016b4:	fc26                	sd	s1,56(sp)
    800016b6:	f84a                	sd	s2,48(sp)
    800016b8:	f44e                	sd	s3,40(sp)
    800016ba:	f052                	sd	s4,32(sp)
    800016bc:	ec56                	sd	s5,24(sp)
    800016be:	e85a                	sd	s6,16(sp)
    800016c0:	e45e                	sd	s7,8(sp)
    800016c2:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800016c4:	03459793          	slli	a5,a1,0x34
    800016c8:	e795                	bnez	a5,800016f4 <uvmunmap+0x46>
    800016ca:	8a2a                	mv	s4,a0
    800016cc:	892e                	mv	s2,a1
    800016ce:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800016d0:	0632                	slli	a2,a2,0xc
    800016d2:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800016d6:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800016d8:	6b05                	lui	s6,0x1
    800016da:	0735e863          	bltu	a1,s3,8000174a <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800016de:	60a6                	ld	ra,72(sp)
    800016e0:	6406                	ld	s0,64(sp)
    800016e2:	74e2                	ld	s1,56(sp)
    800016e4:	7942                	ld	s2,48(sp)
    800016e6:	79a2                	ld	s3,40(sp)
    800016e8:	7a02                	ld	s4,32(sp)
    800016ea:	6ae2                	ld	s5,24(sp)
    800016ec:	6b42                	ld	s6,16(sp)
    800016ee:	6ba2                	ld	s7,8(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret
    panic("uvmunmap: not aligned");
    800016f4:	00007517          	auipc	a0,0x7
    800016f8:	a9450513          	addi	a0,a0,-1388 # 80008188 <digits+0x148>
    800016fc:	fffff097          	auipc	ra,0xfffff
    80001700:	e54080e7          	jalr	-428(ra) # 80000550 <panic>
      panic("uvmunmap: walk");
    80001704:	00007517          	auipc	a0,0x7
    80001708:	a9c50513          	addi	a0,a0,-1380 # 800081a0 <digits+0x160>
    8000170c:	fffff097          	auipc	ra,0xfffff
    80001710:	e44080e7          	jalr	-444(ra) # 80000550 <panic>
      panic("uvmunmap: not mapped");
    80001714:	00007517          	auipc	a0,0x7
    80001718:	a9c50513          	addi	a0,a0,-1380 # 800081b0 <digits+0x170>
    8000171c:	fffff097          	auipc	ra,0xfffff
    80001720:	e34080e7          	jalr	-460(ra) # 80000550 <panic>
      panic("uvmunmap: not a leaf");
    80001724:	00007517          	auipc	a0,0x7
    80001728:	aa450513          	addi	a0,a0,-1372 # 800081c8 <digits+0x188>
    8000172c:	fffff097          	auipc	ra,0xfffff
    80001730:	e24080e7          	jalr	-476(ra) # 80000550 <panic>
      uint64 pa = PTE2PA(*pte);
    80001734:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001736:	0532                	slli	a0,a0,0xc
    80001738:	fffff097          	auipc	ra,0xfffff
    8000173c:	2f4080e7          	jalr	756(ra) # 80000a2c <kfree>
    *pte = 0;
    80001740:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001744:	995a                	add	s2,s2,s6
    80001746:	f9397ce3          	bgeu	s2,s3,800016de <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000174a:	4601                	li	a2,0
    8000174c:	85ca                	mv	a1,s2
    8000174e:	8552                	mv	a0,s4
    80001750:	00000097          	auipc	ra,0x0
    80001754:	cce080e7          	jalr	-818(ra) # 8000141e <walk>
    80001758:	84aa                	mv	s1,a0
    8000175a:	d54d                	beqz	a0,80001704 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000175c:	6108                	ld	a0,0(a0)
    8000175e:	00157793          	andi	a5,a0,1
    80001762:	dbcd                	beqz	a5,80001714 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001764:	3ff57793          	andi	a5,a0,1023
    80001768:	fb778ee3          	beq	a5,s7,80001724 <uvmunmap+0x76>
    if(do_free){
    8000176c:	fc0a8ae3          	beqz	s5,80001740 <uvmunmap+0x92>
    80001770:	b7d1                	j	80001734 <uvmunmap+0x86>

0000000080001772 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001772:	1101                	addi	sp,sp,-32
    80001774:	ec06                	sd	ra,24(sp)
    80001776:	e822                	sd	s0,16(sp)
    80001778:	e426                	sd	s1,8(sp)
    8000177a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000177c:	fffff097          	auipc	ra,0xfffff
    80001780:	416080e7          	jalr	1046(ra) # 80000b92 <kalloc>
    80001784:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001786:	c519                	beqz	a0,80001794 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001788:	6605                	lui	a2,0x1
    8000178a:	4581                	li	a1,0
    8000178c:	00000097          	auipc	ra,0x0
    80001790:	9c2080e7          	jalr	-1598(ra) # 8000114e <memset>
  return pagetable;
}
    80001794:	8526                	mv	a0,s1
    80001796:	60e2                	ld	ra,24(sp)
    80001798:	6442                	ld	s0,16(sp)
    8000179a:	64a2                	ld	s1,8(sp)
    8000179c:	6105                	addi	sp,sp,32
    8000179e:	8082                	ret

00000000800017a0 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800017a0:	7179                	addi	sp,sp,-48
    800017a2:	f406                	sd	ra,40(sp)
    800017a4:	f022                	sd	s0,32(sp)
    800017a6:	ec26                	sd	s1,24(sp)
    800017a8:	e84a                	sd	s2,16(sp)
    800017aa:	e44e                	sd	s3,8(sp)
    800017ac:	e052                	sd	s4,0(sp)
    800017ae:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800017b0:	6785                	lui	a5,0x1
    800017b2:	04f67863          	bgeu	a2,a5,80001802 <uvminit+0x62>
    800017b6:	8a2a                	mv	s4,a0
    800017b8:	89ae                	mv	s3,a1
    800017ba:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800017bc:	fffff097          	auipc	ra,0xfffff
    800017c0:	3d6080e7          	jalr	982(ra) # 80000b92 <kalloc>
    800017c4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800017c6:	6605                	lui	a2,0x1
    800017c8:	4581                	li	a1,0
    800017ca:	00000097          	auipc	ra,0x0
    800017ce:	984080e7          	jalr	-1660(ra) # 8000114e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800017d2:	4779                	li	a4,30
    800017d4:	86ca                	mv	a3,s2
    800017d6:	6605                	lui	a2,0x1
    800017d8:	4581                	li	a1,0
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	d4e080e7          	jalr	-690(ra) # 8000152a <mappages>
  memmove(mem, src, sz);
    800017e4:	8626                	mv	a2,s1
    800017e6:	85ce                	mv	a1,s3
    800017e8:	854a                	mv	a0,s2
    800017ea:	00000097          	auipc	ra,0x0
    800017ee:	9c4080e7          	jalr	-1596(ra) # 800011ae <memmove>
}
    800017f2:	70a2                	ld	ra,40(sp)
    800017f4:	7402                	ld	s0,32(sp)
    800017f6:	64e2                	ld	s1,24(sp)
    800017f8:	6942                	ld	s2,16(sp)
    800017fa:	69a2                	ld	s3,8(sp)
    800017fc:	6a02                	ld	s4,0(sp)
    800017fe:	6145                	addi	sp,sp,48
    80001800:	8082                	ret
    panic("inituvm: more than a page");
    80001802:	00007517          	auipc	a0,0x7
    80001806:	9de50513          	addi	a0,a0,-1570 # 800081e0 <digits+0x1a0>
    8000180a:	fffff097          	auipc	ra,0xfffff
    8000180e:	d46080e7          	jalr	-698(ra) # 80000550 <panic>

0000000080001812 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001812:	1101                	addi	sp,sp,-32
    80001814:	ec06                	sd	ra,24(sp)
    80001816:	e822                	sd	s0,16(sp)
    80001818:	e426                	sd	s1,8(sp)
    8000181a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000181c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000181e:	00b67d63          	bgeu	a2,a1,80001838 <uvmdealloc+0x26>
    80001822:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001824:	6785                	lui	a5,0x1
    80001826:	17fd                	addi	a5,a5,-1
    80001828:	00f60733          	add	a4,a2,a5
    8000182c:	767d                	lui	a2,0xfffff
    8000182e:	8f71                	and	a4,a4,a2
    80001830:	97ae                	add	a5,a5,a1
    80001832:	8ff1                	and	a5,a5,a2
    80001834:	00f76863          	bltu	a4,a5,80001844 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001838:	8526                	mv	a0,s1
    8000183a:	60e2                	ld	ra,24(sp)
    8000183c:	6442                	ld	s0,16(sp)
    8000183e:	64a2                	ld	s1,8(sp)
    80001840:	6105                	addi	sp,sp,32
    80001842:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001844:	8f99                	sub	a5,a5,a4
    80001846:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001848:	4685                	li	a3,1
    8000184a:	0007861b          	sext.w	a2,a5
    8000184e:	85ba                	mv	a1,a4
    80001850:	00000097          	auipc	ra,0x0
    80001854:	e5e080e7          	jalr	-418(ra) # 800016ae <uvmunmap>
    80001858:	b7c5                	j	80001838 <uvmdealloc+0x26>

000000008000185a <uvmalloc>:
  if(newsz < oldsz)
    8000185a:	0ab66163          	bltu	a2,a1,800018fc <uvmalloc+0xa2>
{
    8000185e:	7139                	addi	sp,sp,-64
    80001860:	fc06                	sd	ra,56(sp)
    80001862:	f822                	sd	s0,48(sp)
    80001864:	f426                	sd	s1,40(sp)
    80001866:	f04a                	sd	s2,32(sp)
    80001868:	ec4e                	sd	s3,24(sp)
    8000186a:	e852                	sd	s4,16(sp)
    8000186c:	e456                	sd	s5,8(sp)
    8000186e:	0080                	addi	s0,sp,64
    80001870:	8aaa                	mv	s5,a0
    80001872:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001874:	6985                	lui	s3,0x1
    80001876:	19fd                	addi	s3,s3,-1
    80001878:	95ce                	add	a1,a1,s3
    8000187a:	79fd                	lui	s3,0xfffff
    8000187c:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001880:	08c9f063          	bgeu	s3,a2,80001900 <uvmalloc+0xa6>
    80001884:	894e                	mv	s2,s3
    mem = kalloc();
    80001886:	fffff097          	auipc	ra,0xfffff
    8000188a:	30c080e7          	jalr	780(ra) # 80000b92 <kalloc>
    8000188e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001890:	c51d                	beqz	a0,800018be <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001892:	6605                	lui	a2,0x1
    80001894:	4581                	li	a1,0
    80001896:	00000097          	auipc	ra,0x0
    8000189a:	8b8080e7          	jalr	-1864(ra) # 8000114e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000189e:	4779                	li	a4,30
    800018a0:	86a6                	mv	a3,s1
    800018a2:	6605                	lui	a2,0x1
    800018a4:	85ca                	mv	a1,s2
    800018a6:	8556                	mv	a0,s5
    800018a8:	00000097          	auipc	ra,0x0
    800018ac:	c82080e7          	jalr	-894(ra) # 8000152a <mappages>
    800018b0:	e905                	bnez	a0,800018e0 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800018b2:	6785                	lui	a5,0x1
    800018b4:	993e                	add	s2,s2,a5
    800018b6:	fd4968e3          	bltu	s2,s4,80001886 <uvmalloc+0x2c>
  return newsz;
    800018ba:	8552                	mv	a0,s4
    800018bc:	a809                	j	800018ce <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800018be:	864e                	mv	a2,s3
    800018c0:	85ca                	mv	a1,s2
    800018c2:	8556                	mv	a0,s5
    800018c4:	00000097          	auipc	ra,0x0
    800018c8:	f4e080e7          	jalr	-178(ra) # 80001812 <uvmdealloc>
      return 0;
    800018cc:	4501                	li	a0,0
}
    800018ce:	70e2                	ld	ra,56(sp)
    800018d0:	7442                	ld	s0,48(sp)
    800018d2:	74a2                	ld	s1,40(sp)
    800018d4:	7902                	ld	s2,32(sp)
    800018d6:	69e2                	ld	s3,24(sp)
    800018d8:	6a42                	ld	s4,16(sp)
    800018da:	6aa2                	ld	s5,8(sp)
    800018dc:	6121                	addi	sp,sp,64
    800018de:	8082                	ret
      kfree(mem);
    800018e0:	8526                	mv	a0,s1
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	14a080e7          	jalr	330(ra) # 80000a2c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800018ea:	864e                	mv	a2,s3
    800018ec:	85ca                	mv	a1,s2
    800018ee:	8556                	mv	a0,s5
    800018f0:	00000097          	auipc	ra,0x0
    800018f4:	f22080e7          	jalr	-222(ra) # 80001812 <uvmdealloc>
      return 0;
    800018f8:	4501                	li	a0,0
    800018fa:	bfd1                	j	800018ce <uvmalloc+0x74>
    return oldsz;
    800018fc:	852e                	mv	a0,a1
}
    800018fe:	8082                	ret
  return newsz;
    80001900:	8532                	mv	a0,a2
    80001902:	b7f1                	j	800018ce <uvmalloc+0x74>

0000000080001904 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001904:	7179                	addi	sp,sp,-48
    80001906:	f406                	sd	ra,40(sp)
    80001908:	f022                	sd	s0,32(sp)
    8000190a:	ec26                	sd	s1,24(sp)
    8000190c:	e84a                	sd	s2,16(sp)
    8000190e:	e44e                	sd	s3,8(sp)
    80001910:	e052                	sd	s4,0(sp)
    80001912:	1800                	addi	s0,sp,48
    80001914:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001916:	84aa                	mv	s1,a0
    80001918:	6905                	lui	s2,0x1
    8000191a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000191c:	4985                	li	s3,1
    8000191e:	a821                	j	80001936 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001920:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001922:	0532                	slli	a0,a0,0xc
    80001924:	00000097          	auipc	ra,0x0
    80001928:	fe0080e7          	jalr	-32(ra) # 80001904 <freewalk>
      pagetable[i] = 0;
    8000192c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001930:	04a1                	addi	s1,s1,8
    80001932:	03248163          	beq	s1,s2,80001954 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001936:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001938:	00f57793          	andi	a5,a0,15
    8000193c:	ff3782e3          	beq	a5,s3,80001920 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001940:	8905                	andi	a0,a0,1
    80001942:	d57d                	beqz	a0,80001930 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001944:	00007517          	auipc	a0,0x7
    80001948:	8bc50513          	addi	a0,a0,-1860 # 80008200 <digits+0x1c0>
    8000194c:	fffff097          	auipc	ra,0xfffff
    80001950:	c04080e7          	jalr	-1020(ra) # 80000550 <panic>
    }
  }
  kfree((void*)pagetable);
    80001954:	8552                	mv	a0,s4
    80001956:	fffff097          	auipc	ra,0xfffff
    8000195a:	0d6080e7          	jalr	214(ra) # 80000a2c <kfree>
}
    8000195e:	70a2                	ld	ra,40(sp)
    80001960:	7402                	ld	s0,32(sp)
    80001962:	64e2                	ld	s1,24(sp)
    80001964:	6942                	ld	s2,16(sp)
    80001966:	69a2                	ld	s3,8(sp)
    80001968:	6a02                	ld	s4,0(sp)
    8000196a:	6145                	addi	sp,sp,48
    8000196c:	8082                	ret

000000008000196e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000196e:	1101                	addi	sp,sp,-32
    80001970:	ec06                	sd	ra,24(sp)
    80001972:	e822                	sd	s0,16(sp)
    80001974:	e426                	sd	s1,8(sp)
    80001976:	1000                	addi	s0,sp,32
    80001978:	84aa                	mv	s1,a0
  if(sz > 0)
    8000197a:	e999                	bnez	a1,80001990 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000197c:	8526                	mv	a0,s1
    8000197e:	00000097          	auipc	ra,0x0
    80001982:	f86080e7          	jalr	-122(ra) # 80001904 <freewalk>
}
    80001986:	60e2                	ld	ra,24(sp)
    80001988:	6442                	ld	s0,16(sp)
    8000198a:	64a2                	ld	s1,8(sp)
    8000198c:	6105                	addi	sp,sp,32
    8000198e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001990:	6605                	lui	a2,0x1
    80001992:	167d                	addi	a2,a2,-1
    80001994:	962e                	add	a2,a2,a1
    80001996:	4685                	li	a3,1
    80001998:	8231                	srli	a2,a2,0xc
    8000199a:	4581                	li	a1,0
    8000199c:	00000097          	auipc	ra,0x0
    800019a0:	d12080e7          	jalr	-750(ra) # 800016ae <uvmunmap>
    800019a4:	bfe1                	j	8000197c <uvmfree+0xe>

00000000800019a6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800019a6:	c679                	beqz	a2,80001a74 <uvmcopy+0xce>
{
    800019a8:	715d                	addi	sp,sp,-80
    800019aa:	e486                	sd	ra,72(sp)
    800019ac:	e0a2                	sd	s0,64(sp)
    800019ae:	fc26                	sd	s1,56(sp)
    800019b0:	f84a                	sd	s2,48(sp)
    800019b2:	f44e                	sd	s3,40(sp)
    800019b4:	f052                	sd	s4,32(sp)
    800019b6:	ec56                	sd	s5,24(sp)
    800019b8:	e85a                	sd	s6,16(sp)
    800019ba:	e45e                	sd	s7,8(sp)
    800019bc:	0880                	addi	s0,sp,80
    800019be:	8b2a                	mv	s6,a0
    800019c0:	8aae                	mv	s5,a1
    800019c2:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800019c4:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800019c6:	4601                	li	a2,0
    800019c8:	85ce                	mv	a1,s3
    800019ca:	855a                	mv	a0,s6
    800019cc:	00000097          	auipc	ra,0x0
    800019d0:	a52080e7          	jalr	-1454(ra) # 8000141e <walk>
    800019d4:	c531                	beqz	a0,80001a20 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800019d6:	6118                	ld	a4,0(a0)
    800019d8:	00177793          	andi	a5,a4,1
    800019dc:	cbb1                	beqz	a5,80001a30 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800019de:	00a75593          	srli	a1,a4,0xa
    800019e2:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800019e6:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	1a8080e7          	jalr	424(ra) # 80000b92 <kalloc>
    800019f2:	892a                	mv	s2,a0
    800019f4:	c939                	beqz	a0,80001a4a <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800019f6:	6605                	lui	a2,0x1
    800019f8:	85de                	mv	a1,s7
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	7b4080e7          	jalr	1972(ra) # 800011ae <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001a02:	8726                	mv	a4,s1
    80001a04:	86ca                	mv	a3,s2
    80001a06:	6605                	lui	a2,0x1
    80001a08:	85ce                	mv	a1,s3
    80001a0a:	8556                	mv	a0,s5
    80001a0c:	00000097          	auipc	ra,0x0
    80001a10:	b1e080e7          	jalr	-1250(ra) # 8000152a <mappages>
    80001a14:	e515                	bnez	a0,80001a40 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001a16:	6785                	lui	a5,0x1
    80001a18:	99be                	add	s3,s3,a5
    80001a1a:	fb49e6e3          	bltu	s3,s4,800019c6 <uvmcopy+0x20>
    80001a1e:	a081                	j	80001a5e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001a20:	00006517          	auipc	a0,0x6
    80001a24:	7f050513          	addi	a0,a0,2032 # 80008210 <digits+0x1d0>
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	b28080e7          	jalr	-1240(ra) # 80000550 <panic>
      panic("uvmcopy: page not present");
    80001a30:	00007517          	auipc	a0,0x7
    80001a34:	80050513          	addi	a0,a0,-2048 # 80008230 <digits+0x1f0>
    80001a38:	fffff097          	auipc	ra,0xfffff
    80001a3c:	b18080e7          	jalr	-1256(ra) # 80000550 <panic>
      kfree(mem);
    80001a40:	854a                	mv	a0,s2
    80001a42:	fffff097          	auipc	ra,0xfffff
    80001a46:	fea080e7          	jalr	-22(ra) # 80000a2c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001a4a:	4685                	li	a3,1
    80001a4c:	00c9d613          	srli	a2,s3,0xc
    80001a50:	4581                	li	a1,0
    80001a52:	8556                	mv	a0,s5
    80001a54:	00000097          	auipc	ra,0x0
    80001a58:	c5a080e7          	jalr	-934(ra) # 800016ae <uvmunmap>
  return -1;
    80001a5c:	557d                	li	a0,-1
}
    80001a5e:	60a6                	ld	ra,72(sp)
    80001a60:	6406                	ld	s0,64(sp)
    80001a62:	74e2                	ld	s1,56(sp)
    80001a64:	7942                	ld	s2,48(sp)
    80001a66:	79a2                	ld	s3,40(sp)
    80001a68:	7a02                	ld	s4,32(sp)
    80001a6a:	6ae2                	ld	s5,24(sp)
    80001a6c:	6b42                	ld	s6,16(sp)
    80001a6e:	6ba2                	ld	s7,8(sp)
    80001a70:	6161                	addi	sp,sp,80
    80001a72:	8082                	ret
  return 0;
    80001a74:	4501                	li	a0,0
}
    80001a76:	8082                	ret

0000000080001a78 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001a78:	1141                	addi	sp,sp,-16
    80001a7a:	e406                	sd	ra,8(sp)
    80001a7c:	e022                	sd	s0,0(sp)
    80001a7e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001a80:	4601                	li	a2,0
    80001a82:	00000097          	auipc	ra,0x0
    80001a86:	99c080e7          	jalr	-1636(ra) # 8000141e <walk>
  if(pte == 0)
    80001a8a:	c901                	beqz	a0,80001a9a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001a8c:	611c                	ld	a5,0(a0)
    80001a8e:	9bbd                	andi	a5,a5,-17
    80001a90:	e11c                	sd	a5,0(a0)
}
    80001a92:	60a2                	ld	ra,8(sp)
    80001a94:	6402                	ld	s0,0(sp)
    80001a96:	0141                	addi	sp,sp,16
    80001a98:	8082                	ret
    panic("uvmclear");
    80001a9a:	00006517          	auipc	a0,0x6
    80001a9e:	7b650513          	addi	a0,a0,1974 # 80008250 <digits+0x210>
    80001aa2:	fffff097          	auipc	ra,0xfffff
    80001aa6:	aae080e7          	jalr	-1362(ra) # 80000550 <panic>

0000000080001aaa <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001aaa:	c6bd                	beqz	a3,80001b18 <copyout+0x6e>
{
    80001aac:	715d                	addi	sp,sp,-80
    80001aae:	e486                	sd	ra,72(sp)
    80001ab0:	e0a2                	sd	s0,64(sp)
    80001ab2:	fc26                	sd	s1,56(sp)
    80001ab4:	f84a                	sd	s2,48(sp)
    80001ab6:	f44e                	sd	s3,40(sp)
    80001ab8:	f052                	sd	s4,32(sp)
    80001aba:	ec56                	sd	s5,24(sp)
    80001abc:	e85a                	sd	s6,16(sp)
    80001abe:	e45e                	sd	s7,8(sp)
    80001ac0:	e062                	sd	s8,0(sp)
    80001ac2:	0880                	addi	s0,sp,80
    80001ac4:	8b2a                	mv	s6,a0
    80001ac6:	8c2e                	mv	s8,a1
    80001ac8:	8a32                	mv	s4,a2
    80001aca:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001acc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001ace:	6a85                	lui	s5,0x1
    80001ad0:	a015                	j	80001af4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001ad2:	9562                	add	a0,a0,s8
    80001ad4:	0004861b          	sext.w	a2,s1
    80001ad8:	85d2                	mv	a1,s4
    80001ada:	41250533          	sub	a0,a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	6d0080e7          	jalr	1744(ra) # 800011ae <memmove>

    len -= n;
    80001ae6:	409989b3          	sub	s3,s3,s1
    src += n;
    80001aea:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001aec:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001af0:	02098263          	beqz	s3,80001b14 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001af4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001af8:	85ca                	mv	a1,s2
    80001afa:	855a                	mv	a0,s6
    80001afc:	00000097          	auipc	ra,0x0
    80001b00:	9ec080e7          	jalr	-1556(ra) # 800014e8 <walkaddr>
    if(pa0 == 0)
    80001b04:	cd01                	beqz	a0,80001b1c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001b06:	418904b3          	sub	s1,s2,s8
    80001b0a:	94d6                	add	s1,s1,s5
    if(n > len)
    80001b0c:	fc99f3e3          	bgeu	s3,s1,80001ad2 <copyout+0x28>
    80001b10:	84ce                	mv	s1,s3
    80001b12:	b7c1                	j	80001ad2 <copyout+0x28>
  }
  return 0;
    80001b14:	4501                	li	a0,0
    80001b16:	a021                	j	80001b1e <copyout+0x74>
    80001b18:	4501                	li	a0,0
}
    80001b1a:	8082                	ret
      return -1;
    80001b1c:	557d                	li	a0,-1
}
    80001b1e:	60a6                	ld	ra,72(sp)
    80001b20:	6406                	ld	s0,64(sp)
    80001b22:	74e2                	ld	s1,56(sp)
    80001b24:	7942                	ld	s2,48(sp)
    80001b26:	79a2                	ld	s3,40(sp)
    80001b28:	7a02                	ld	s4,32(sp)
    80001b2a:	6ae2                	ld	s5,24(sp)
    80001b2c:	6b42                	ld	s6,16(sp)
    80001b2e:	6ba2                	ld	s7,8(sp)
    80001b30:	6c02                	ld	s8,0(sp)
    80001b32:	6161                	addi	sp,sp,80
    80001b34:	8082                	ret

0000000080001b36 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001b36:	c6bd                	beqz	a3,80001ba4 <copyin+0x6e>
{
    80001b38:	715d                	addi	sp,sp,-80
    80001b3a:	e486                	sd	ra,72(sp)
    80001b3c:	e0a2                	sd	s0,64(sp)
    80001b3e:	fc26                	sd	s1,56(sp)
    80001b40:	f84a                	sd	s2,48(sp)
    80001b42:	f44e                	sd	s3,40(sp)
    80001b44:	f052                	sd	s4,32(sp)
    80001b46:	ec56                	sd	s5,24(sp)
    80001b48:	e85a                	sd	s6,16(sp)
    80001b4a:	e45e                	sd	s7,8(sp)
    80001b4c:	e062                	sd	s8,0(sp)
    80001b4e:	0880                	addi	s0,sp,80
    80001b50:	8b2a                	mv	s6,a0
    80001b52:	8a2e                	mv	s4,a1
    80001b54:	8c32                	mv	s8,a2
    80001b56:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001b58:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001b5a:	6a85                	lui	s5,0x1
    80001b5c:	a015                	j	80001b80 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001b5e:	9562                	add	a0,a0,s8
    80001b60:	0004861b          	sext.w	a2,s1
    80001b64:	412505b3          	sub	a1,a0,s2
    80001b68:	8552                	mv	a0,s4
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	644080e7          	jalr	1604(ra) # 800011ae <memmove>

    len -= n;
    80001b72:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001b76:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001b78:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001b7c:	02098263          	beqz	s3,80001ba0 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001b80:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001b84:	85ca                	mv	a1,s2
    80001b86:	855a                	mv	a0,s6
    80001b88:	00000097          	auipc	ra,0x0
    80001b8c:	960080e7          	jalr	-1696(ra) # 800014e8 <walkaddr>
    if(pa0 == 0)
    80001b90:	cd01                	beqz	a0,80001ba8 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001b92:	418904b3          	sub	s1,s2,s8
    80001b96:	94d6                	add	s1,s1,s5
    if(n > len)
    80001b98:	fc99f3e3          	bgeu	s3,s1,80001b5e <copyin+0x28>
    80001b9c:	84ce                	mv	s1,s3
    80001b9e:	b7c1                	j	80001b5e <copyin+0x28>
  }
  return 0;
    80001ba0:	4501                	li	a0,0
    80001ba2:	a021                	j	80001baa <copyin+0x74>
    80001ba4:	4501                	li	a0,0
}
    80001ba6:	8082                	ret
      return -1;
    80001ba8:	557d                	li	a0,-1
}
    80001baa:	60a6                	ld	ra,72(sp)
    80001bac:	6406                	ld	s0,64(sp)
    80001bae:	74e2                	ld	s1,56(sp)
    80001bb0:	7942                	ld	s2,48(sp)
    80001bb2:	79a2                	ld	s3,40(sp)
    80001bb4:	7a02                	ld	s4,32(sp)
    80001bb6:	6ae2                	ld	s5,24(sp)
    80001bb8:	6b42                	ld	s6,16(sp)
    80001bba:	6ba2                	ld	s7,8(sp)
    80001bbc:	6c02                	ld	s8,0(sp)
    80001bbe:	6161                	addi	sp,sp,80
    80001bc0:	8082                	ret

0000000080001bc2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001bc2:	c6c5                	beqz	a3,80001c6a <copyinstr+0xa8>
{
    80001bc4:	715d                	addi	sp,sp,-80
    80001bc6:	e486                	sd	ra,72(sp)
    80001bc8:	e0a2                	sd	s0,64(sp)
    80001bca:	fc26                	sd	s1,56(sp)
    80001bcc:	f84a                	sd	s2,48(sp)
    80001bce:	f44e                	sd	s3,40(sp)
    80001bd0:	f052                	sd	s4,32(sp)
    80001bd2:	ec56                	sd	s5,24(sp)
    80001bd4:	e85a                	sd	s6,16(sp)
    80001bd6:	e45e                	sd	s7,8(sp)
    80001bd8:	0880                	addi	s0,sp,80
    80001bda:	8a2a                	mv	s4,a0
    80001bdc:	8b2e                	mv	s6,a1
    80001bde:	8bb2                	mv	s7,a2
    80001be0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001be2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001be4:	6985                	lui	s3,0x1
    80001be6:	a035                	j	80001c12 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001be8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001bec:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001bee:	0017b793          	seqz	a5,a5
    80001bf2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001bf6:	60a6                	ld	ra,72(sp)
    80001bf8:	6406                	ld	s0,64(sp)
    80001bfa:	74e2                	ld	s1,56(sp)
    80001bfc:	7942                	ld	s2,48(sp)
    80001bfe:	79a2                	ld	s3,40(sp)
    80001c00:	7a02                	ld	s4,32(sp)
    80001c02:	6ae2                	ld	s5,24(sp)
    80001c04:	6b42                	ld	s6,16(sp)
    80001c06:	6ba2                	ld	s7,8(sp)
    80001c08:	6161                	addi	sp,sp,80
    80001c0a:	8082                	ret
    srcva = va0 + PGSIZE;
    80001c0c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001c10:	c8a9                	beqz	s1,80001c62 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001c12:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001c16:	85ca                	mv	a1,s2
    80001c18:	8552                	mv	a0,s4
    80001c1a:	00000097          	auipc	ra,0x0
    80001c1e:	8ce080e7          	jalr	-1842(ra) # 800014e8 <walkaddr>
    if(pa0 == 0)
    80001c22:	c131                	beqz	a0,80001c66 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001c24:	41790833          	sub	a6,s2,s7
    80001c28:	984e                	add	a6,a6,s3
    if(n > max)
    80001c2a:	0104f363          	bgeu	s1,a6,80001c30 <copyinstr+0x6e>
    80001c2e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001c30:	955e                	add	a0,a0,s7
    80001c32:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001c36:	fc080be3          	beqz	a6,80001c0c <copyinstr+0x4a>
    80001c3a:	985a                	add	a6,a6,s6
    80001c3c:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001c3e:	41650633          	sub	a2,a0,s6
    80001c42:	14fd                	addi	s1,s1,-1
    80001c44:	9b26                	add	s6,s6,s1
    80001c46:	00f60733          	add	a4,a2,a5
    80001c4a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd0fd8>
    80001c4e:	df49                	beqz	a4,80001be8 <copyinstr+0x26>
        *dst = *p;
    80001c50:	00e78023          	sb	a4,0(a5)
      --max;
    80001c54:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001c58:	0785                	addi	a5,a5,1
    while(n > 0){
    80001c5a:	ff0796e3          	bne	a5,a6,80001c46 <copyinstr+0x84>
      dst++;
    80001c5e:	8b42                	mv	s6,a6
    80001c60:	b775                	j	80001c0c <copyinstr+0x4a>
    80001c62:	4781                	li	a5,0
    80001c64:	b769                	j	80001bee <copyinstr+0x2c>
      return -1;
    80001c66:	557d                	li	a0,-1
    80001c68:	b779                	j	80001bf6 <copyinstr+0x34>
  int got_null = 0;
    80001c6a:	4781                	li	a5,0
  if(got_null){
    80001c6c:	0017b793          	seqz	a5,a5
    80001c70:	40f00533          	neg	a0,a5
}
    80001c74:	8082                	ret

0000000080001c76 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001c76:	1101                	addi	sp,sp,-32
    80001c78:	ec06                	sd	ra,24(sp)
    80001c7a:	e822                	sd	s0,16(sp)
    80001c7c:	e426                	sd	s1,8(sp)
    80001c7e:	1000                	addi	s0,sp,32
    80001c80:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	072080e7          	jalr	114(ra) # 80000cf4 <holding>
    80001c8a:	c909                	beqz	a0,80001c9c <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001c8c:	789c                	ld	a5,48(s1)
    80001c8e:	00978f63          	beq	a5,s1,80001cac <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001c92:	60e2                	ld	ra,24(sp)
    80001c94:	6442                	ld	s0,16(sp)
    80001c96:	64a2                	ld	s1,8(sp)
    80001c98:	6105                	addi	sp,sp,32
    80001c9a:	8082                	ret
    panic("wakeup1");
    80001c9c:	00006517          	auipc	a0,0x6
    80001ca0:	5c450513          	addi	a0,a0,1476 # 80008260 <digits+0x220>
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	8ac080e7          	jalr	-1876(ra) # 80000550 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001cac:	5098                	lw	a4,32(s1)
    80001cae:	4785                	li	a5,1
    80001cb0:	fef711e3          	bne	a4,a5,80001c92 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001cb4:	4789                	li	a5,2
    80001cb6:	d09c                	sw	a5,32(s1)
}
    80001cb8:	bfe9                	j	80001c92 <wakeup1+0x1c>

0000000080001cba <procinit>:
{
    80001cba:	715d                	addi	sp,sp,-80
    80001cbc:	e486                	sd	ra,72(sp)
    80001cbe:	e0a2                	sd	s0,64(sp)
    80001cc0:	fc26                	sd	s1,56(sp)
    80001cc2:	f84a                	sd	s2,48(sp)
    80001cc4:	f44e                	sd	s3,40(sp)
    80001cc6:	f052                	sd	s4,32(sp)
    80001cc8:	ec56                	sd	s5,24(sp)
    80001cca:	e85a                	sd	s6,16(sp)
    80001ccc:	e45e                	sd	s7,8(sp)
    80001cce:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001cd0:	00006597          	auipc	a1,0x6
    80001cd4:	59858593          	addi	a1,a1,1432 # 80008268 <digits+0x228>
    80001cd8:	00010517          	auipc	a0,0x10
    80001cdc:	6f050513          	addi	a0,a0,1776 # 800123c8 <pid_lock>
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	20a080e7          	jalr	522(ra) # 80000eea <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ce8:	00011917          	auipc	s2,0x11
    80001cec:	b0090913          	addi	s2,s2,-1280 # 800127e8 <proc>
      initlock(&p->lock, "proc");
    80001cf0:	00006b97          	auipc	s7,0x6
    80001cf4:	580b8b93          	addi	s7,s7,1408 # 80008270 <digits+0x230>
      uint64 va = KSTACK((int) (p - proc));
    80001cf8:	8b4a                	mv	s6,s2
    80001cfa:	00006a97          	auipc	s5,0x6
    80001cfe:	306a8a93          	addi	s5,s5,774 # 80008000 <etext>
    80001d02:	040009b7          	lui	s3,0x4000
    80001d06:	19fd                	addi	s3,s3,-1
    80001d08:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d0a:	00016a17          	auipc	s4,0x16
    80001d0e:	6dea0a13          	addi	s4,s4,1758 # 800183e8 <tickslock>
      initlock(&p->lock, "proc");
    80001d12:	85de                	mv	a1,s7
    80001d14:	854a                	mv	a0,s2
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	1d4080e7          	jalr	468(ra) # 80000eea <initlock>
      char *pa = kalloc();
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	e74080e7          	jalr	-396(ra) # 80000b92 <kalloc>
    80001d26:	85aa                	mv	a1,a0
      if(pa == 0)
    80001d28:	c929                	beqz	a0,80001d7a <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001d2a:	416904b3          	sub	s1,s2,s6
    80001d2e:	8491                	srai	s1,s1,0x4
    80001d30:	000ab783          	ld	a5,0(s5)
    80001d34:	02f484b3          	mul	s1,s1,a5
    80001d38:	2485                	addiw	s1,s1,1
    80001d3a:	00d4949b          	slliw	s1,s1,0xd
    80001d3e:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001d42:	4699                	li	a3,6
    80001d44:	6605                	lui	a2,0x1
    80001d46:	8526                	mv	a0,s1
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	870080e7          	jalr	-1936(ra) # 800015b8 <kvmmap>
      p->kstack = va;
    80001d50:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d54:	17090913          	addi	s2,s2,368
    80001d58:	fb491de3          	bne	s2,s4,80001d12 <procinit+0x58>
  kvminithart();
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	768080e7          	jalr	1896(ra) # 800014c4 <kvminithart>
}
    80001d64:	60a6                	ld	ra,72(sp)
    80001d66:	6406                	ld	s0,64(sp)
    80001d68:	74e2                	ld	s1,56(sp)
    80001d6a:	7942                	ld	s2,48(sp)
    80001d6c:	79a2                	ld	s3,40(sp)
    80001d6e:	7a02                	ld	s4,32(sp)
    80001d70:	6ae2                	ld	s5,24(sp)
    80001d72:	6b42                	ld	s6,16(sp)
    80001d74:	6ba2                	ld	s7,8(sp)
    80001d76:	6161                	addi	sp,sp,80
    80001d78:	8082                	ret
        panic("kalloc");
    80001d7a:	00006517          	auipc	a0,0x6
    80001d7e:	4fe50513          	addi	a0,a0,1278 # 80008278 <digits+0x238>
    80001d82:	ffffe097          	auipc	ra,0xffffe
    80001d86:	7ce080e7          	jalr	1998(ra) # 80000550 <panic>

0000000080001d8a <cpuid>:
{
    80001d8a:	1141                	addi	sp,sp,-16
    80001d8c:	e422                	sd	s0,8(sp)
    80001d8e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d90:	8512                	mv	a0,tp
}
    80001d92:	2501                	sext.w	a0,a0
    80001d94:	6422                	ld	s0,8(sp)
    80001d96:	0141                	addi	sp,sp,16
    80001d98:	8082                	ret

0000000080001d9a <mycpu>:
mycpu(void) {
    80001d9a:	1141                	addi	sp,sp,-16
    80001d9c:	e422                	sd	s0,8(sp)
    80001d9e:	0800                	addi	s0,sp,16
    80001da0:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001da2:	2781                	sext.w	a5,a5
    80001da4:	079e                	slli	a5,a5,0x7
}
    80001da6:	00010517          	auipc	a0,0x10
    80001daa:	64250513          	addi	a0,a0,1602 # 800123e8 <cpus>
    80001dae:	953e                	add	a0,a0,a5
    80001db0:	6422                	ld	s0,8(sp)
    80001db2:	0141                	addi	sp,sp,16
    80001db4:	8082                	ret

0000000080001db6 <myproc>:
myproc(void) {
    80001db6:	1101                	addi	sp,sp,-32
    80001db8:	ec06                	sd	ra,24(sp)
    80001dba:	e822                	sd	s0,16(sp)
    80001dbc:	e426                	sd	s1,8(sp)
    80001dbe:	1000                	addi	s0,sp,32
  push_off();
    80001dc0:	fffff097          	auipc	ra,0xfffff
    80001dc4:	f62080e7          	jalr	-158(ra) # 80000d22 <push_off>
    80001dc8:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001dca:	2781                	sext.w	a5,a5
    80001dcc:	079e                	slli	a5,a5,0x7
    80001dce:	00010717          	auipc	a4,0x10
    80001dd2:	5fa70713          	addi	a4,a4,1530 # 800123c8 <pid_lock>
    80001dd6:	97ba                	add	a5,a5,a4
    80001dd8:	7384                	ld	s1,32(a5)
  pop_off();
    80001dda:	fffff097          	auipc	ra,0xfffff
    80001dde:	004080e7          	jalr	4(ra) # 80000dde <pop_off>
}
    80001de2:	8526                	mv	a0,s1
    80001de4:	60e2                	ld	ra,24(sp)
    80001de6:	6442                	ld	s0,16(sp)
    80001de8:	64a2                	ld	s1,8(sp)
    80001dea:	6105                	addi	sp,sp,32
    80001dec:	8082                	ret

0000000080001dee <forkret>:
{
    80001dee:	1141                	addi	sp,sp,-16
    80001df0:	e406                	sd	ra,8(sp)
    80001df2:	e022                	sd	s0,0(sp)
    80001df4:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001df6:	00000097          	auipc	ra,0x0
    80001dfa:	fc0080e7          	jalr	-64(ra) # 80001db6 <myproc>
    80001dfe:	fffff097          	auipc	ra,0xfffff
    80001e02:	040080e7          	jalr	64(ra) # 80000e3e <release>
  if (first) {
    80001e06:	00007797          	auipc	a5,0x7
    80001e0a:	aba7a783          	lw	a5,-1350(a5) # 800088c0 <first.1672>
    80001e0e:	eb89                	bnez	a5,80001e20 <forkret+0x32>
  usertrapret();
    80001e10:	00001097          	auipc	ra,0x1
    80001e14:	c1c080e7          	jalr	-996(ra) # 80002a2c <usertrapret>
}
    80001e18:	60a2                	ld	ra,8(sp)
    80001e1a:	6402                	ld	s0,0(sp)
    80001e1c:	0141                	addi	sp,sp,16
    80001e1e:	8082                	ret
    first = 0;
    80001e20:	00007797          	auipc	a5,0x7
    80001e24:	aa07a023          	sw	zero,-1376(a5) # 800088c0 <first.1672>
    fsinit(ROOTDEV);
    80001e28:	4505                	li	a0,1
    80001e2a:	00002097          	auipc	ra,0x2
    80001e2e:	ac6080e7          	jalr	-1338(ra) # 800038f0 <fsinit>
    80001e32:	bff9                	j	80001e10 <forkret+0x22>

0000000080001e34 <allocpid>:
allocpid() {
    80001e34:	1101                	addi	sp,sp,-32
    80001e36:	ec06                	sd	ra,24(sp)
    80001e38:	e822                	sd	s0,16(sp)
    80001e3a:	e426                	sd	s1,8(sp)
    80001e3c:	e04a                	sd	s2,0(sp)
    80001e3e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001e40:	00010917          	auipc	s2,0x10
    80001e44:	58890913          	addi	s2,s2,1416 # 800123c8 <pid_lock>
    80001e48:	854a                	mv	a0,s2
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	f24080e7          	jalr	-220(ra) # 80000d6e <acquire>
  pid = nextpid;
    80001e52:	00007797          	auipc	a5,0x7
    80001e56:	a7278793          	addi	a5,a5,-1422 # 800088c4 <nextpid>
    80001e5a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001e5c:	0014871b          	addiw	a4,s1,1
    80001e60:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001e62:	854a                	mv	a0,s2
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	fda080e7          	jalr	-38(ra) # 80000e3e <release>
}
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	60e2                	ld	ra,24(sp)
    80001e70:	6442                	ld	s0,16(sp)
    80001e72:	64a2                	ld	s1,8(sp)
    80001e74:	6902                	ld	s2,0(sp)
    80001e76:	6105                	addi	sp,sp,32
    80001e78:	8082                	ret

0000000080001e7a <proc_pagetable>:
{
    80001e7a:	1101                	addi	sp,sp,-32
    80001e7c:	ec06                	sd	ra,24(sp)
    80001e7e:	e822                	sd	s0,16(sp)
    80001e80:	e426                	sd	s1,8(sp)
    80001e82:	e04a                	sd	s2,0(sp)
    80001e84:	1000                	addi	s0,sp,32
    80001e86:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e88:	00000097          	auipc	ra,0x0
    80001e8c:	8ea080e7          	jalr	-1814(ra) # 80001772 <uvmcreate>
    80001e90:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e92:	c121                	beqz	a0,80001ed2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e94:	4729                	li	a4,10
    80001e96:	00005697          	auipc	a3,0x5
    80001e9a:	16a68693          	addi	a3,a3,362 # 80007000 <_trampoline>
    80001e9e:	6605                	lui	a2,0x1
    80001ea0:	040005b7          	lui	a1,0x4000
    80001ea4:	15fd                	addi	a1,a1,-1
    80001ea6:	05b2                	slli	a1,a1,0xc
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	682080e7          	jalr	1666(ra) # 8000152a <mappages>
    80001eb0:	02054863          	bltz	a0,80001ee0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001eb4:	4719                	li	a4,6
    80001eb6:	06093683          	ld	a3,96(s2)
    80001eba:	6605                	lui	a2,0x1
    80001ebc:	020005b7          	lui	a1,0x2000
    80001ec0:	15fd                	addi	a1,a1,-1
    80001ec2:	05b6                	slli	a1,a1,0xd
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	664080e7          	jalr	1636(ra) # 8000152a <mappages>
    80001ece:	02054163          	bltz	a0,80001ef0 <proc_pagetable+0x76>
}
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	60e2                	ld	ra,24(sp)
    80001ed6:	6442                	ld	s0,16(sp)
    80001ed8:	64a2                	ld	s1,8(sp)
    80001eda:	6902                	ld	s2,0(sp)
    80001edc:	6105                	addi	sp,sp,32
    80001ede:	8082                	ret
    uvmfree(pagetable, 0);
    80001ee0:	4581                	li	a1,0
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	00000097          	auipc	ra,0x0
    80001ee8:	a8a080e7          	jalr	-1398(ra) # 8000196e <uvmfree>
    return 0;
    80001eec:	4481                	li	s1,0
    80001eee:	b7d5                	j	80001ed2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ef0:	4681                	li	a3,0
    80001ef2:	4605                	li	a2,1
    80001ef4:	040005b7          	lui	a1,0x4000
    80001ef8:	15fd                	addi	a1,a1,-1
    80001efa:	05b2                	slli	a1,a1,0xc
    80001efc:	8526                	mv	a0,s1
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	7b0080e7          	jalr	1968(ra) # 800016ae <uvmunmap>
    uvmfree(pagetable, 0);
    80001f06:	4581                	li	a1,0
    80001f08:	8526                	mv	a0,s1
    80001f0a:	00000097          	auipc	ra,0x0
    80001f0e:	a64080e7          	jalr	-1436(ra) # 8000196e <uvmfree>
    return 0;
    80001f12:	4481                	li	s1,0
    80001f14:	bf7d                	j	80001ed2 <proc_pagetable+0x58>

0000000080001f16 <proc_freepagetable>:
{
    80001f16:	1101                	addi	sp,sp,-32
    80001f18:	ec06                	sd	ra,24(sp)
    80001f1a:	e822                	sd	s0,16(sp)
    80001f1c:	e426                	sd	s1,8(sp)
    80001f1e:	e04a                	sd	s2,0(sp)
    80001f20:	1000                	addi	s0,sp,32
    80001f22:	84aa                	mv	s1,a0
    80001f24:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f26:	4681                	li	a3,0
    80001f28:	4605                	li	a2,1
    80001f2a:	040005b7          	lui	a1,0x4000
    80001f2e:	15fd                	addi	a1,a1,-1
    80001f30:	05b2                	slli	a1,a1,0xc
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	77c080e7          	jalr	1916(ra) # 800016ae <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f3a:	4681                	li	a3,0
    80001f3c:	4605                	li	a2,1
    80001f3e:	020005b7          	lui	a1,0x2000
    80001f42:	15fd                	addi	a1,a1,-1
    80001f44:	05b6                	slli	a1,a1,0xd
    80001f46:	8526                	mv	a0,s1
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	766080e7          	jalr	1894(ra) # 800016ae <uvmunmap>
  uvmfree(pagetable, sz);
    80001f50:	85ca                	mv	a1,s2
    80001f52:	8526                	mv	a0,s1
    80001f54:	00000097          	auipc	ra,0x0
    80001f58:	a1a080e7          	jalr	-1510(ra) # 8000196e <uvmfree>
}
    80001f5c:	60e2                	ld	ra,24(sp)
    80001f5e:	6442                	ld	s0,16(sp)
    80001f60:	64a2                	ld	s1,8(sp)
    80001f62:	6902                	ld	s2,0(sp)
    80001f64:	6105                	addi	sp,sp,32
    80001f66:	8082                	ret

0000000080001f68 <freeproc>:
{
    80001f68:	1101                	addi	sp,sp,-32
    80001f6a:	ec06                	sd	ra,24(sp)
    80001f6c:	e822                	sd	s0,16(sp)
    80001f6e:	e426                	sd	s1,8(sp)
    80001f70:	1000                	addi	s0,sp,32
    80001f72:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001f74:	7128                	ld	a0,96(a0)
    80001f76:	c509                	beqz	a0,80001f80 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	ab4080e7          	jalr	-1356(ra) # 80000a2c <kfree>
  p->trapframe = 0;
    80001f80:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001f84:	6ca8                	ld	a0,88(s1)
    80001f86:	c511                	beqz	a0,80001f92 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f88:	68ac                	ld	a1,80(s1)
    80001f8a:	00000097          	auipc	ra,0x0
    80001f8e:	f8c080e7          	jalr	-116(ra) # 80001f16 <proc_freepagetable>
  p->pagetable = 0;
    80001f92:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001f96:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001f9a:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001f9e:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001fa2:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001fa6:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001faa:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001fae:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001fb2:	0204a023          	sw	zero,32(s1)
}
    80001fb6:	60e2                	ld	ra,24(sp)
    80001fb8:	6442                	ld	s0,16(sp)
    80001fba:	64a2                	ld	s1,8(sp)
    80001fbc:	6105                	addi	sp,sp,32
    80001fbe:	8082                	ret

0000000080001fc0 <allocproc>:
{
    80001fc0:	1101                	addi	sp,sp,-32
    80001fc2:	ec06                	sd	ra,24(sp)
    80001fc4:	e822                	sd	s0,16(sp)
    80001fc6:	e426                	sd	s1,8(sp)
    80001fc8:	e04a                	sd	s2,0(sp)
    80001fca:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fcc:	00011497          	auipc	s1,0x11
    80001fd0:	81c48493          	addi	s1,s1,-2020 # 800127e8 <proc>
    80001fd4:	00016917          	auipc	s2,0x16
    80001fd8:	41490913          	addi	s2,s2,1044 # 800183e8 <tickslock>
    acquire(&p->lock);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	d90080e7          	jalr	-624(ra) # 80000d6e <acquire>
    if(p->state == UNUSED) {
    80001fe6:	509c                	lw	a5,32(s1)
    80001fe8:	cf81                	beqz	a5,80002000 <allocproc+0x40>
      release(&p->lock);
    80001fea:	8526                	mv	a0,s1
    80001fec:	fffff097          	auipc	ra,0xfffff
    80001ff0:	e52080e7          	jalr	-430(ra) # 80000e3e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ff4:	17048493          	addi	s1,s1,368
    80001ff8:	ff2492e3          	bne	s1,s2,80001fdc <allocproc+0x1c>
  return 0;
    80001ffc:	4481                	li	s1,0
    80001ffe:	a0b9                	j	8000204c <allocproc+0x8c>
  p->pid = allocpid();
    80002000:	00000097          	auipc	ra,0x0
    80002004:	e34080e7          	jalr	-460(ra) # 80001e34 <allocpid>
    80002008:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	b88080e7          	jalr	-1144(ra) # 80000b92 <kalloc>
    80002012:	892a                	mv	s2,a0
    80002014:	f0a8                	sd	a0,96(s1)
    80002016:	c131                	beqz	a0,8000205a <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80002018:	8526                	mv	a0,s1
    8000201a:	00000097          	auipc	ra,0x0
    8000201e:	e60080e7          	jalr	-416(ra) # 80001e7a <proc_pagetable>
    80002022:	892a                	mv	s2,a0
    80002024:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80002026:	c129                	beqz	a0,80002068 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80002028:	07000613          	li	a2,112
    8000202c:	4581                	li	a1,0
    8000202e:	06848513          	addi	a0,s1,104
    80002032:	fffff097          	auipc	ra,0xfffff
    80002036:	11c080e7          	jalr	284(ra) # 8000114e <memset>
  p->context.ra = (uint64)forkret;
    8000203a:	00000797          	auipc	a5,0x0
    8000203e:	db478793          	addi	a5,a5,-588 # 80001dee <forkret>
    80002042:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002044:	64bc                	ld	a5,72(s1)
    80002046:	6705                	lui	a4,0x1
    80002048:	97ba                	add	a5,a5,a4
    8000204a:	f8bc                	sd	a5,112(s1)
}
    8000204c:	8526                	mv	a0,s1
    8000204e:	60e2                	ld	ra,24(sp)
    80002050:	6442                	ld	s0,16(sp)
    80002052:	64a2                	ld	s1,8(sp)
    80002054:	6902                	ld	s2,0(sp)
    80002056:	6105                	addi	sp,sp,32
    80002058:	8082                	ret
    release(&p->lock);
    8000205a:	8526                	mv	a0,s1
    8000205c:	fffff097          	auipc	ra,0xfffff
    80002060:	de2080e7          	jalr	-542(ra) # 80000e3e <release>
    return 0;
    80002064:	84ca                	mv	s1,s2
    80002066:	b7dd                	j	8000204c <allocproc+0x8c>
    freeproc(p);
    80002068:	8526                	mv	a0,s1
    8000206a:	00000097          	auipc	ra,0x0
    8000206e:	efe080e7          	jalr	-258(ra) # 80001f68 <freeproc>
    release(&p->lock);
    80002072:	8526                	mv	a0,s1
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	dca080e7          	jalr	-566(ra) # 80000e3e <release>
    return 0;
    8000207c:	84ca                	mv	s1,s2
    8000207e:	b7f9                	j	8000204c <allocproc+0x8c>

0000000080002080 <userinit>:
{
    80002080:	1101                	addi	sp,sp,-32
    80002082:	ec06                	sd	ra,24(sp)
    80002084:	e822                	sd	s0,16(sp)
    80002086:	e426                	sd	s1,8(sp)
    80002088:	1000                	addi	s0,sp,32
  p = allocproc();
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	f36080e7          	jalr	-202(ra) # 80001fc0 <allocproc>
    80002092:	84aa                	mv	s1,a0
  initproc = p;
    80002094:	00007797          	auipc	a5,0x7
    80002098:	f8a7b223          	sd	a0,-124(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000209c:	03400613          	li	a2,52
    800020a0:	00007597          	auipc	a1,0x7
    800020a4:	83058593          	addi	a1,a1,-2000 # 800088d0 <initcode>
    800020a8:	6d28                	ld	a0,88(a0)
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	6f6080e7          	jalr	1782(ra) # 800017a0 <uvminit>
  p->sz = PGSIZE;
    800020b2:	6785                	lui	a5,0x1
    800020b4:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    800020b6:	70b8                	ld	a4,96(s1)
    800020b8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800020bc:	70b8                	ld	a4,96(s1)
    800020be:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800020c0:	4641                	li	a2,16
    800020c2:	00006597          	auipc	a1,0x6
    800020c6:	1be58593          	addi	a1,a1,446 # 80008280 <digits+0x240>
    800020ca:	16048513          	addi	a0,s1,352
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	1d6080e7          	jalr	470(ra) # 800012a4 <safestrcpy>
  p->cwd = namei("/");
    800020d6:	00006517          	auipc	a0,0x6
    800020da:	1ba50513          	addi	a0,a0,442 # 80008290 <digits+0x250>
    800020de:	00002097          	auipc	ra,0x2
    800020e2:	23e080e7          	jalr	574(ra) # 8000431c <namei>
    800020e6:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    800020ea:	4789                	li	a5,2
    800020ec:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    800020ee:	8526                	mv	a0,s1
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	d4e080e7          	jalr	-690(ra) # 80000e3e <release>
}
    800020f8:	60e2                	ld	ra,24(sp)
    800020fa:	6442                	ld	s0,16(sp)
    800020fc:	64a2                	ld	s1,8(sp)
    800020fe:	6105                	addi	sp,sp,32
    80002100:	8082                	ret

0000000080002102 <growproc>:
{
    80002102:	1101                	addi	sp,sp,-32
    80002104:	ec06                	sd	ra,24(sp)
    80002106:	e822                	sd	s0,16(sp)
    80002108:	e426                	sd	s1,8(sp)
    8000210a:	e04a                	sd	s2,0(sp)
    8000210c:	1000                	addi	s0,sp,32
    8000210e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002110:	00000097          	auipc	ra,0x0
    80002114:	ca6080e7          	jalr	-858(ra) # 80001db6 <myproc>
    80002118:	892a                	mv	s2,a0
  sz = p->sz;
    8000211a:	692c                	ld	a1,80(a0)
    8000211c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002120:	00904f63          	bgtz	s1,8000213e <growproc+0x3c>
  } else if(n < 0){
    80002124:	0204cc63          	bltz	s1,8000215c <growproc+0x5a>
  p->sz = sz;
    80002128:	1602                	slli	a2,a2,0x20
    8000212a:	9201                	srli	a2,a2,0x20
    8000212c:	04c93823          	sd	a2,80(s2)
  return 0;
    80002130:	4501                	li	a0,0
}
    80002132:	60e2                	ld	ra,24(sp)
    80002134:	6442                	ld	s0,16(sp)
    80002136:	64a2                	ld	s1,8(sp)
    80002138:	6902                	ld	s2,0(sp)
    8000213a:	6105                	addi	sp,sp,32
    8000213c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000213e:	9e25                	addw	a2,a2,s1
    80002140:	1602                	slli	a2,a2,0x20
    80002142:	9201                	srli	a2,a2,0x20
    80002144:	1582                	slli	a1,a1,0x20
    80002146:	9181                	srli	a1,a1,0x20
    80002148:	6d28                	ld	a0,88(a0)
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	710080e7          	jalr	1808(ra) # 8000185a <uvmalloc>
    80002152:	0005061b          	sext.w	a2,a0
    80002156:	fa69                	bnez	a2,80002128 <growproc+0x26>
      return -1;
    80002158:	557d                	li	a0,-1
    8000215a:	bfe1                	j	80002132 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000215c:	9e25                	addw	a2,a2,s1
    8000215e:	1602                	slli	a2,a2,0x20
    80002160:	9201                	srli	a2,a2,0x20
    80002162:	1582                	slli	a1,a1,0x20
    80002164:	9181                	srli	a1,a1,0x20
    80002166:	6d28                	ld	a0,88(a0)
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	6aa080e7          	jalr	1706(ra) # 80001812 <uvmdealloc>
    80002170:	0005061b          	sext.w	a2,a0
    80002174:	bf55                	j	80002128 <growproc+0x26>

0000000080002176 <fork>:
{
    80002176:	7179                	addi	sp,sp,-48
    80002178:	f406                	sd	ra,40(sp)
    8000217a:	f022                	sd	s0,32(sp)
    8000217c:	ec26                	sd	s1,24(sp)
    8000217e:	e84a                	sd	s2,16(sp)
    80002180:	e44e                	sd	s3,8(sp)
    80002182:	e052                	sd	s4,0(sp)
    80002184:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002186:	00000097          	auipc	ra,0x0
    8000218a:	c30080e7          	jalr	-976(ra) # 80001db6 <myproc>
    8000218e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002190:	00000097          	auipc	ra,0x0
    80002194:	e30080e7          	jalr	-464(ra) # 80001fc0 <allocproc>
    80002198:	c175                	beqz	a0,8000227c <fork+0x106>
    8000219a:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000219c:	05093603          	ld	a2,80(s2)
    800021a0:	6d2c                	ld	a1,88(a0)
    800021a2:	05893503          	ld	a0,88(s2)
    800021a6:	00000097          	auipc	ra,0x0
    800021aa:	800080e7          	jalr	-2048(ra) # 800019a6 <uvmcopy>
    800021ae:	04054863          	bltz	a0,800021fe <fork+0x88>
  np->sz = p->sz;
    800021b2:	05093783          	ld	a5,80(s2)
    800021b6:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    800021ba:	0329b423          	sd	s2,40(s3)
  *(np->trapframe) = *(p->trapframe);
    800021be:	06093683          	ld	a3,96(s2)
    800021c2:	87b6                	mv	a5,a3
    800021c4:	0609b703          	ld	a4,96(s3)
    800021c8:	12068693          	addi	a3,a3,288
    800021cc:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800021d0:	6788                	ld	a0,8(a5)
    800021d2:	6b8c                	ld	a1,16(a5)
    800021d4:	6f90                	ld	a2,24(a5)
    800021d6:	01073023          	sd	a6,0(a4)
    800021da:	e708                	sd	a0,8(a4)
    800021dc:	eb0c                	sd	a1,16(a4)
    800021de:	ef10                	sd	a2,24(a4)
    800021e0:	02078793          	addi	a5,a5,32
    800021e4:	02070713          	addi	a4,a4,32
    800021e8:	fed792e3          	bne	a5,a3,800021cc <fork+0x56>
  np->trapframe->a0 = 0;
    800021ec:	0609b783          	ld	a5,96(s3)
    800021f0:	0607b823          	sd	zero,112(a5)
    800021f4:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    800021f8:	15800a13          	li	s4,344
    800021fc:	a03d                	j	8000222a <fork+0xb4>
    freeproc(np);
    800021fe:	854e                	mv	a0,s3
    80002200:	00000097          	auipc	ra,0x0
    80002204:	d68080e7          	jalr	-664(ra) # 80001f68 <freeproc>
    release(&np->lock);
    80002208:	854e                	mv	a0,s3
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	c34080e7          	jalr	-972(ra) # 80000e3e <release>
    return -1;
    80002212:	54fd                	li	s1,-1
    80002214:	a899                	j	8000226a <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002216:	00002097          	auipc	ra,0x2
    8000221a:	7a4080e7          	jalr	1956(ra) # 800049ba <filedup>
    8000221e:	009987b3          	add	a5,s3,s1
    80002222:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002224:	04a1                	addi	s1,s1,8
    80002226:	01448763          	beq	s1,s4,80002234 <fork+0xbe>
    if(p->ofile[i])
    8000222a:	009907b3          	add	a5,s2,s1
    8000222e:	6388                	ld	a0,0(a5)
    80002230:	f17d                	bnez	a0,80002216 <fork+0xa0>
    80002232:	bfcd                	j	80002224 <fork+0xae>
  np->cwd = idup(p->cwd);
    80002234:	15893503          	ld	a0,344(s2)
    80002238:	00002097          	auipc	ra,0x2
    8000223c:	8f2080e7          	jalr	-1806(ra) # 80003b2a <idup>
    80002240:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002244:	4641                	li	a2,16
    80002246:	16090593          	addi	a1,s2,352
    8000224a:	16098513          	addi	a0,s3,352
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	056080e7          	jalr	86(ra) # 800012a4 <safestrcpy>
  pid = np->pid;
    80002256:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    8000225a:	4789                	li	a5,2
    8000225c:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    80002260:	854e                	mv	a0,s3
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	bdc080e7          	jalr	-1060(ra) # 80000e3e <release>
}
    8000226a:	8526                	mv	a0,s1
    8000226c:	70a2                	ld	ra,40(sp)
    8000226e:	7402                	ld	s0,32(sp)
    80002270:	64e2                	ld	s1,24(sp)
    80002272:	6942                	ld	s2,16(sp)
    80002274:	69a2                	ld	s3,8(sp)
    80002276:	6a02                	ld	s4,0(sp)
    80002278:	6145                	addi	sp,sp,48
    8000227a:	8082                	ret
    return -1;
    8000227c:	54fd                	li	s1,-1
    8000227e:	b7f5                	j	8000226a <fork+0xf4>

0000000080002280 <reparent>:
{
    80002280:	7179                	addi	sp,sp,-48
    80002282:	f406                	sd	ra,40(sp)
    80002284:	f022                	sd	s0,32(sp)
    80002286:	ec26                	sd	s1,24(sp)
    80002288:	e84a                	sd	s2,16(sp)
    8000228a:	e44e                	sd	s3,8(sp)
    8000228c:	e052                	sd	s4,0(sp)
    8000228e:	1800                	addi	s0,sp,48
    80002290:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002292:	00010497          	auipc	s1,0x10
    80002296:	55648493          	addi	s1,s1,1366 # 800127e8 <proc>
      pp->parent = initproc;
    8000229a:	00007a17          	auipc	s4,0x7
    8000229e:	d7ea0a13          	addi	s4,s4,-642 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022a2:	00016997          	auipc	s3,0x16
    800022a6:	14698993          	addi	s3,s3,326 # 800183e8 <tickslock>
    800022aa:	a029                	j	800022b4 <reparent+0x34>
    800022ac:	17048493          	addi	s1,s1,368
    800022b0:	03348363          	beq	s1,s3,800022d6 <reparent+0x56>
    if(pp->parent == p){
    800022b4:	749c                	ld	a5,40(s1)
    800022b6:	ff279be3          	bne	a5,s2,800022ac <reparent+0x2c>
      acquire(&pp->lock);
    800022ba:	8526                	mv	a0,s1
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	ab2080e7          	jalr	-1358(ra) # 80000d6e <acquire>
      pp->parent = initproc;
    800022c4:	000a3783          	ld	a5,0(s4)
    800022c8:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	b72080e7          	jalr	-1166(ra) # 80000e3e <release>
    800022d4:	bfe1                	j	800022ac <reparent+0x2c>
}
    800022d6:	70a2                	ld	ra,40(sp)
    800022d8:	7402                	ld	s0,32(sp)
    800022da:	64e2                	ld	s1,24(sp)
    800022dc:	6942                	ld	s2,16(sp)
    800022de:	69a2                	ld	s3,8(sp)
    800022e0:	6a02                	ld	s4,0(sp)
    800022e2:	6145                	addi	sp,sp,48
    800022e4:	8082                	ret

00000000800022e6 <scheduler>:
{
    800022e6:	711d                	addi	sp,sp,-96
    800022e8:	ec86                	sd	ra,88(sp)
    800022ea:	e8a2                	sd	s0,80(sp)
    800022ec:	e4a6                	sd	s1,72(sp)
    800022ee:	e0ca                	sd	s2,64(sp)
    800022f0:	fc4e                	sd	s3,56(sp)
    800022f2:	f852                	sd	s4,48(sp)
    800022f4:	f456                	sd	s5,40(sp)
    800022f6:	f05a                	sd	s6,32(sp)
    800022f8:	ec5e                	sd	s7,24(sp)
    800022fa:	e862                	sd	s8,16(sp)
    800022fc:	e466                	sd	s9,8(sp)
    800022fe:	1080                	addi	s0,sp,96
    80002300:	8792                	mv	a5,tp
  int id = r_tp();
    80002302:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002304:	00779c13          	slli	s8,a5,0x7
    80002308:	00010717          	auipc	a4,0x10
    8000230c:	0c070713          	addi	a4,a4,192 # 800123c8 <pid_lock>
    80002310:	9762                	add	a4,a4,s8
    80002312:	02073023          	sd	zero,32(a4)
        swtch(&c->context, &p->context);
    80002316:	00010717          	auipc	a4,0x10
    8000231a:	0da70713          	addi	a4,a4,218 # 800123f0 <cpus+0x8>
    8000231e:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80002320:	4a89                	li	s5,2
        c->proc = p;
    80002322:	079e                	slli	a5,a5,0x7
    80002324:	00010b17          	auipc	s6,0x10
    80002328:	0a4b0b13          	addi	s6,s6,164 # 800123c8 <pid_lock>
    8000232c:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000232e:	00016a17          	auipc	s4,0x16
    80002332:	0baa0a13          	addi	s4,s4,186 # 800183e8 <tickslock>
    int nproc = 0;
    80002336:	4c81                	li	s9,0
    80002338:	a8a1                	j	80002390 <scheduler+0xaa>
        p->state = RUNNING;
    8000233a:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    8000233e:	029b3023          	sd	s1,32(s6)
        swtch(&c->context, &p->context);
    80002342:	06848593          	addi	a1,s1,104
    80002346:	8562                	mv	a0,s8
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	63a080e7          	jalr	1594(ra) # 80002982 <swtch>
        c->proc = 0;
    80002350:	020b3023          	sd	zero,32(s6)
      release(&p->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	ae8080e7          	jalr	-1304(ra) # 80000e3e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000235e:	17048493          	addi	s1,s1,368
    80002362:	01448d63          	beq	s1,s4,8000237c <scheduler+0x96>
      acquire(&p->lock);
    80002366:	8526                	mv	a0,s1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	a06080e7          	jalr	-1530(ra) # 80000d6e <acquire>
      if(p->state != UNUSED) {
    80002370:	509c                	lw	a5,32(s1)
    80002372:	d3ed                	beqz	a5,80002354 <scheduler+0x6e>
        nproc++;
    80002374:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    80002376:	fd579fe3          	bne	a5,s5,80002354 <scheduler+0x6e>
    8000237a:	b7c1                	j	8000233a <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    8000237c:	013aca63          	blt	s5,s3,80002390 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002380:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002384:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002388:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000238c:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002390:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002394:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002398:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    8000239c:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    8000239e:	00010497          	auipc	s1,0x10
    800023a2:	44a48493          	addi	s1,s1,1098 # 800127e8 <proc>
        p->state = RUNNING;
    800023a6:	4b8d                	li	s7,3
    800023a8:	bf7d                	j	80002366 <scheduler+0x80>

00000000800023aa <sched>:
{
    800023aa:	7179                	addi	sp,sp,-48
    800023ac:	f406                	sd	ra,40(sp)
    800023ae:	f022                	sd	s0,32(sp)
    800023b0:	ec26                	sd	s1,24(sp)
    800023b2:	e84a                	sd	s2,16(sp)
    800023b4:	e44e                	sd	s3,8(sp)
    800023b6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023b8:	00000097          	auipc	ra,0x0
    800023bc:	9fe080e7          	jalr	-1538(ra) # 80001db6 <myproc>
    800023c0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	932080e7          	jalr	-1742(ra) # 80000cf4 <holding>
    800023ca:	c93d                	beqz	a0,80002440 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023cc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023ce:	2781                	sext.w	a5,a5
    800023d0:	079e                	slli	a5,a5,0x7
    800023d2:	00010717          	auipc	a4,0x10
    800023d6:	ff670713          	addi	a4,a4,-10 # 800123c8 <pid_lock>
    800023da:	97ba                	add	a5,a5,a4
    800023dc:	0987a703          	lw	a4,152(a5)
    800023e0:	4785                	li	a5,1
    800023e2:	06f71763          	bne	a4,a5,80002450 <sched+0xa6>
  if(p->state == RUNNING)
    800023e6:	5098                	lw	a4,32(s1)
    800023e8:	478d                	li	a5,3
    800023ea:	06f70b63          	beq	a4,a5,80002460 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023ee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023f2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800023f4:	efb5                	bnez	a5,80002470 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023f6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023f8:	00010917          	auipc	s2,0x10
    800023fc:	fd090913          	addi	s2,s2,-48 # 800123c8 <pid_lock>
    80002400:	2781                	sext.w	a5,a5
    80002402:	079e                	slli	a5,a5,0x7
    80002404:	97ca                	add	a5,a5,s2
    80002406:	09c7a983          	lw	s3,156(a5)
    8000240a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000240c:	2781                	sext.w	a5,a5
    8000240e:	079e                	slli	a5,a5,0x7
    80002410:	00010597          	auipc	a1,0x10
    80002414:	fe058593          	addi	a1,a1,-32 # 800123f0 <cpus+0x8>
    80002418:	95be                	add	a1,a1,a5
    8000241a:	06848513          	addi	a0,s1,104
    8000241e:	00000097          	auipc	ra,0x0
    80002422:	564080e7          	jalr	1380(ra) # 80002982 <swtch>
    80002426:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002428:	2781                	sext.w	a5,a5
    8000242a:	079e                	slli	a5,a5,0x7
    8000242c:	97ca                	add	a5,a5,s2
    8000242e:	0937ae23          	sw	s3,156(a5)
}
    80002432:	70a2                	ld	ra,40(sp)
    80002434:	7402                	ld	s0,32(sp)
    80002436:	64e2                	ld	s1,24(sp)
    80002438:	6942                	ld	s2,16(sp)
    8000243a:	69a2                	ld	s3,8(sp)
    8000243c:	6145                	addi	sp,sp,48
    8000243e:	8082                	ret
    panic("sched p->lock");
    80002440:	00006517          	auipc	a0,0x6
    80002444:	e5850513          	addi	a0,a0,-424 # 80008298 <digits+0x258>
    80002448:	ffffe097          	auipc	ra,0xffffe
    8000244c:	108080e7          	jalr	264(ra) # 80000550 <panic>
    panic("sched locks");
    80002450:	00006517          	auipc	a0,0x6
    80002454:	e5850513          	addi	a0,a0,-424 # 800082a8 <digits+0x268>
    80002458:	ffffe097          	auipc	ra,0xffffe
    8000245c:	0f8080e7          	jalr	248(ra) # 80000550 <panic>
    panic("sched running");
    80002460:	00006517          	auipc	a0,0x6
    80002464:	e5850513          	addi	a0,a0,-424 # 800082b8 <digits+0x278>
    80002468:	ffffe097          	auipc	ra,0xffffe
    8000246c:	0e8080e7          	jalr	232(ra) # 80000550 <panic>
    panic("sched interruptible");
    80002470:	00006517          	auipc	a0,0x6
    80002474:	e5850513          	addi	a0,a0,-424 # 800082c8 <digits+0x288>
    80002478:	ffffe097          	auipc	ra,0xffffe
    8000247c:	0d8080e7          	jalr	216(ra) # 80000550 <panic>

0000000080002480 <exit>:
{
    80002480:	7179                	addi	sp,sp,-48
    80002482:	f406                	sd	ra,40(sp)
    80002484:	f022                	sd	s0,32(sp)
    80002486:	ec26                	sd	s1,24(sp)
    80002488:	e84a                	sd	s2,16(sp)
    8000248a:	e44e                	sd	s3,8(sp)
    8000248c:	e052                	sd	s4,0(sp)
    8000248e:	1800                	addi	s0,sp,48
    80002490:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002492:	00000097          	auipc	ra,0x0
    80002496:	924080e7          	jalr	-1756(ra) # 80001db6 <myproc>
    8000249a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000249c:	00007797          	auipc	a5,0x7
    800024a0:	b7c7b783          	ld	a5,-1156(a5) # 80009018 <initproc>
    800024a4:	0d850493          	addi	s1,a0,216
    800024a8:	15850913          	addi	s2,a0,344
    800024ac:	02a79363          	bne	a5,a0,800024d2 <exit+0x52>
    panic("init exiting");
    800024b0:	00006517          	auipc	a0,0x6
    800024b4:	e3050513          	addi	a0,a0,-464 # 800082e0 <digits+0x2a0>
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	098080e7          	jalr	152(ra) # 80000550 <panic>
      fileclose(f);
    800024c0:	00002097          	auipc	ra,0x2
    800024c4:	54c080e7          	jalr	1356(ra) # 80004a0c <fileclose>
      p->ofile[fd] = 0;
    800024c8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800024cc:	04a1                	addi	s1,s1,8
    800024ce:	01248563          	beq	s1,s2,800024d8 <exit+0x58>
    if(p->ofile[fd]){
    800024d2:	6088                	ld	a0,0(s1)
    800024d4:	f575                	bnez	a0,800024c0 <exit+0x40>
    800024d6:	bfdd                	j	800024cc <exit+0x4c>
  begin_op();
    800024d8:	00002097          	auipc	ra,0x2
    800024dc:	060080e7          	jalr	96(ra) # 80004538 <begin_op>
  iput(p->cwd);
    800024e0:	1589b503          	ld	a0,344(s3)
    800024e4:	00002097          	auipc	ra,0x2
    800024e8:	83e080e7          	jalr	-1986(ra) # 80003d22 <iput>
  end_op();
    800024ec:	00002097          	auipc	ra,0x2
    800024f0:	0cc080e7          	jalr	204(ra) # 800045b8 <end_op>
  p->cwd = 0;
    800024f4:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    800024f8:	00007497          	auipc	s1,0x7
    800024fc:	b2048493          	addi	s1,s1,-1248 # 80009018 <initproc>
    80002500:	6088                	ld	a0,0(s1)
    80002502:	fffff097          	auipc	ra,0xfffff
    80002506:	86c080e7          	jalr	-1940(ra) # 80000d6e <acquire>
  wakeup1(initproc);
    8000250a:	6088                	ld	a0,0(s1)
    8000250c:	fffff097          	auipc	ra,0xfffff
    80002510:	76a080e7          	jalr	1898(ra) # 80001c76 <wakeup1>
  release(&initproc->lock);
    80002514:	6088                	ld	a0,0(s1)
    80002516:	fffff097          	auipc	ra,0xfffff
    8000251a:	928080e7          	jalr	-1752(ra) # 80000e3e <release>
  acquire(&p->lock);
    8000251e:	854e                	mv	a0,s3
    80002520:	fffff097          	auipc	ra,0xfffff
    80002524:	84e080e7          	jalr	-1970(ra) # 80000d6e <acquire>
  struct proc *original_parent = p->parent;
    80002528:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    8000252c:	854e                	mv	a0,s3
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	910080e7          	jalr	-1776(ra) # 80000e3e <release>
  acquire(&original_parent->lock);
    80002536:	8526                	mv	a0,s1
    80002538:	fffff097          	auipc	ra,0xfffff
    8000253c:	836080e7          	jalr	-1994(ra) # 80000d6e <acquire>
  acquire(&p->lock);
    80002540:	854e                	mv	a0,s3
    80002542:	fffff097          	auipc	ra,0xfffff
    80002546:	82c080e7          	jalr	-2004(ra) # 80000d6e <acquire>
  reparent(p);
    8000254a:	854e                	mv	a0,s3
    8000254c:	00000097          	auipc	ra,0x0
    80002550:	d34080e7          	jalr	-716(ra) # 80002280 <reparent>
  wakeup1(original_parent);
    80002554:	8526                	mv	a0,s1
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	720080e7          	jalr	1824(ra) # 80001c76 <wakeup1>
  p->xstate = status;
    8000255e:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    80002562:	4791                	li	a5,4
    80002564:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    80002568:	8526                	mv	a0,s1
    8000256a:	fffff097          	auipc	ra,0xfffff
    8000256e:	8d4080e7          	jalr	-1836(ra) # 80000e3e <release>
  sched();
    80002572:	00000097          	auipc	ra,0x0
    80002576:	e38080e7          	jalr	-456(ra) # 800023aa <sched>
  panic("zombie exit");
    8000257a:	00006517          	auipc	a0,0x6
    8000257e:	d7650513          	addi	a0,a0,-650 # 800082f0 <digits+0x2b0>
    80002582:	ffffe097          	auipc	ra,0xffffe
    80002586:	fce080e7          	jalr	-50(ra) # 80000550 <panic>

000000008000258a <yield>:
{
    8000258a:	1101                	addi	sp,sp,-32
    8000258c:	ec06                	sd	ra,24(sp)
    8000258e:	e822                	sd	s0,16(sp)
    80002590:	e426                	sd	s1,8(sp)
    80002592:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002594:	00000097          	auipc	ra,0x0
    80002598:	822080e7          	jalr	-2014(ra) # 80001db6 <myproc>
    8000259c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	7d0080e7          	jalr	2000(ra) # 80000d6e <acquire>
  p->state = RUNNABLE;
    800025a6:	4789                	li	a5,2
    800025a8:	d09c                	sw	a5,32(s1)
  sched();
    800025aa:	00000097          	auipc	ra,0x0
    800025ae:	e00080e7          	jalr	-512(ra) # 800023aa <sched>
  release(&p->lock);
    800025b2:	8526                	mv	a0,s1
    800025b4:	fffff097          	auipc	ra,0xfffff
    800025b8:	88a080e7          	jalr	-1910(ra) # 80000e3e <release>
}
    800025bc:	60e2                	ld	ra,24(sp)
    800025be:	6442                	ld	s0,16(sp)
    800025c0:	64a2                	ld	s1,8(sp)
    800025c2:	6105                	addi	sp,sp,32
    800025c4:	8082                	ret

00000000800025c6 <sleep>:
{
    800025c6:	7179                	addi	sp,sp,-48
    800025c8:	f406                	sd	ra,40(sp)
    800025ca:	f022                	sd	s0,32(sp)
    800025cc:	ec26                	sd	s1,24(sp)
    800025ce:	e84a                	sd	s2,16(sp)
    800025d0:	e44e                	sd	s3,8(sp)
    800025d2:	1800                	addi	s0,sp,48
    800025d4:	89aa                	mv	s3,a0
    800025d6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800025d8:	fffff097          	auipc	ra,0xfffff
    800025dc:	7de080e7          	jalr	2014(ra) # 80001db6 <myproc>
    800025e0:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800025e2:	05250663          	beq	a0,s2,8000262e <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	788080e7          	jalr	1928(ra) # 80000d6e <acquire>
    release(lk);
    800025ee:	854a                	mv	a0,s2
    800025f0:	fffff097          	auipc	ra,0xfffff
    800025f4:	84e080e7          	jalr	-1970(ra) # 80000e3e <release>
  p->chan = chan;
    800025f8:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    800025fc:	4785                	li	a5,1
    800025fe:	d09c                	sw	a5,32(s1)
  sched();
    80002600:	00000097          	auipc	ra,0x0
    80002604:	daa080e7          	jalr	-598(ra) # 800023aa <sched>
  p->chan = 0;
    80002608:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000260c:	8526                	mv	a0,s1
    8000260e:	fffff097          	auipc	ra,0xfffff
    80002612:	830080e7          	jalr	-2000(ra) # 80000e3e <release>
    acquire(lk);
    80002616:	854a                	mv	a0,s2
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	756080e7          	jalr	1878(ra) # 80000d6e <acquire>
}
    80002620:	70a2                	ld	ra,40(sp)
    80002622:	7402                	ld	s0,32(sp)
    80002624:	64e2                	ld	s1,24(sp)
    80002626:	6942                	ld	s2,16(sp)
    80002628:	69a2                	ld	s3,8(sp)
    8000262a:	6145                	addi	sp,sp,48
    8000262c:	8082                	ret
  p->chan = chan;
    8000262e:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    80002632:	4785                	li	a5,1
    80002634:	d11c                	sw	a5,32(a0)
  sched();
    80002636:	00000097          	auipc	ra,0x0
    8000263a:	d74080e7          	jalr	-652(ra) # 800023aa <sched>
  p->chan = 0;
    8000263e:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    80002642:	bff9                	j	80002620 <sleep+0x5a>

0000000080002644 <wait>:
{
    80002644:	715d                	addi	sp,sp,-80
    80002646:	e486                	sd	ra,72(sp)
    80002648:	e0a2                	sd	s0,64(sp)
    8000264a:	fc26                	sd	s1,56(sp)
    8000264c:	f84a                	sd	s2,48(sp)
    8000264e:	f44e                	sd	s3,40(sp)
    80002650:	f052                	sd	s4,32(sp)
    80002652:	ec56                	sd	s5,24(sp)
    80002654:	e85a                	sd	s6,16(sp)
    80002656:	e45e                	sd	s7,8(sp)
    80002658:	e062                	sd	s8,0(sp)
    8000265a:	0880                	addi	s0,sp,80
    8000265c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000265e:	fffff097          	auipc	ra,0xfffff
    80002662:	758080e7          	jalr	1880(ra) # 80001db6 <myproc>
    80002666:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002668:	8c2a                	mv	s8,a0
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	704080e7          	jalr	1796(ra) # 80000d6e <acquire>
    havekids = 0;
    80002672:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002674:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002676:	00016997          	auipc	s3,0x16
    8000267a:	d7298993          	addi	s3,s3,-654 # 800183e8 <tickslock>
        havekids = 1;
    8000267e:	4a85                	li	s5,1
    havekids = 0;
    80002680:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002682:	00010497          	auipc	s1,0x10
    80002686:	16648493          	addi	s1,s1,358 # 800127e8 <proc>
    8000268a:	a08d                	j	800026ec <wait+0xa8>
          pid = np->pid;
    8000268c:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002690:	000b0e63          	beqz	s6,800026ac <wait+0x68>
    80002694:	4691                	li	a3,4
    80002696:	03c48613          	addi	a2,s1,60
    8000269a:	85da                	mv	a1,s6
    8000269c:	05893503          	ld	a0,88(s2)
    800026a0:	fffff097          	auipc	ra,0xfffff
    800026a4:	40a080e7          	jalr	1034(ra) # 80001aaa <copyout>
    800026a8:	02054263          	bltz	a0,800026cc <wait+0x88>
          freeproc(np);
    800026ac:	8526                	mv	a0,s1
    800026ae:	00000097          	auipc	ra,0x0
    800026b2:	8ba080e7          	jalr	-1862(ra) # 80001f68 <freeproc>
          release(&np->lock);
    800026b6:	8526                	mv	a0,s1
    800026b8:	ffffe097          	auipc	ra,0xffffe
    800026bc:	786080e7          	jalr	1926(ra) # 80000e3e <release>
          release(&p->lock);
    800026c0:	854a                	mv	a0,s2
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	77c080e7          	jalr	1916(ra) # 80000e3e <release>
          return pid;
    800026ca:	a8a9                	j	80002724 <wait+0xe0>
            release(&np->lock);
    800026cc:	8526                	mv	a0,s1
    800026ce:	ffffe097          	auipc	ra,0xffffe
    800026d2:	770080e7          	jalr	1904(ra) # 80000e3e <release>
            release(&p->lock);
    800026d6:	854a                	mv	a0,s2
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	766080e7          	jalr	1894(ra) # 80000e3e <release>
            return -1;
    800026e0:	59fd                	li	s3,-1
    800026e2:	a089                	j	80002724 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800026e4:	17048493          	addi	s1,s1,368
    800026e8:	03348463          	beq	s1,s3,80002710 <wait+0xcc>
      if(np->parent == p){
    800026ec:	749c                	ld	a5,40(s1)
    800026ee:	ff279be3          	bne	a5,s2,800026e4 <wait+0xa0>
        acquire(&np->lock);
    800026f2:	8526                	mv	a0,s1
    800026f4:	ffffe097          	auipc	ra,0xffffe
    800026f8:	67a080e7          	jalr	1658(ra) # 80000d6e <acquire>
        if(np->state == ZOMBIE){
    800026fc:	509c                	lw	a5,32(s1)
    800026fe:	f94787e3          	beq	a5,s4,8000268c <wait+0x48>
        release(&np->lock);
    80002702:	8526                	mv	a0,s1
    80002704:	ffffe097          	auipc	ra,0xffffe
    80002708:	73a080e7          	jalr	1850(ra) # 80000e3e <release>
        havekids = 1;
    8000270c:	8756                	mv	a4,s5
    8000270e:	bfd9                	j	800026e4 <wait+0xa0>
    if(!havekids || p->killed){
    80002710:	c701                	beqz	a4,80002718 <wait+0xd4>
    80002712:	03892783          	lw	a5,56(s2)
    80002716:	c785                	beqz	a5,8000273e <wait+0xfa>
      release(&p->lock);
    80002718:	854a                	mv	a0,s2
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	724080e7          	jalr	1828(ra) # 80000e3e <release>
      return -1;
    80002722:	59fd                	li	s3,-1
}
    80002724:	854e                	mv	a0,s3
    80002726:	60a6                	ld	ra,72(sp)
    80002728:	6406                	ld	s0,64(sp)
    8000272a:	74e2                	ld	s1,56(sp)
    8000272c:	7942                	ld	s2,48(sp)
    8000272e:	79a2                	ld	s3,40(sp)
    80002730:	7a02                	ld	s4,32(sp)
    80002732:	6ae2                	ld	s5,24(sp)
    80002734:	6b42                	ld	s6,16(sp)
    80002736:	6ba2                	ld	s7,8(sp)
    80002738:	6c02                	ld	s8,0(sp)
    8000273a:	6161                	addi	sp,sp,80
    8000273c:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000273e:	85e2                	mv	a1,s8
    80002740:	854a                	mv	a0,s2
    80002742:	00000097          	auipc	ra,0x0
    80002746:	e84080e7          	jalr	-380(ra) # 800025c6 <sleep>
    havekids = 0;
    8000274a:	bf1d                	j	80002680 <wait+0x3c>

000000008000274c <wakeup>:
{
    8000274c:	7139                	addi	sp,sp,-64
    8000274e:	fc06                	sd	ra,56(sp)
    80002750:	f822                	sd	s0,48(sp)
    80002752:	f426                	sd	s1,40(sp)
    80002754:	f04a                	sd	s2,32(sp)
    80002756:	ec4e                	sd	s3,24(sp)
    80002758:	e852                	sd	s4,16(sp)
    8000275a:	e456                	sd	s5,8(sp)
    8000275c:	0080                	addi	s0,sp,64
    8000275e:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002760:	00010497          	auipc	s1,0x10
    80002764:	08848493          	addi	s1,s1,136 # 800127e8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002768:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000276a:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000276c:	00016917          	auipc	s2,0x16
    80002770:	c7c90913          	addi	s2,s2,-900 # 800183e8 <tickslock>
    80002774:	a821                	j	8000278c <wakeup+0x40>
      p->state = RUNNABLE;
    80002776:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    8000277a:	8526                	mv	a0,s1
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	6c2080e7          	jalr	1730(ra) # 80000e3e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002784:	17048493          	addi	s1,s1,368
    80002788:	01248e63          	beq	s1,s2,800027a4 <wakeup+0x58>
    acquire(&p->lock);
    8000278c:	8526                	mv	a0,s1
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	5e0080e7          	jalr	1504(ra) # 80000d6e <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002796:	509c                	lw	a5,32(s1)
    80002798:	ff3791e3          	bne	a5,s3,8000277a <wakeup+0x2e>
    8000279c:	789c                	ld	a5,48(s1)
    8000279e:	fd479ee3          	bne	a5,s4,8000277a <wakeup+0x2e>
    800027a2:	bfd1                	j	80002776 <wakeup+0x2a>
}
    800027a4:	70e2                	ld	ra,56(sp)
    800027a6:	7442                	ld	s0,48(sp)
    800027a8:	74a2                	ld	s1,40(sp)
    800027aa:	7902                	ld	s2,32(sp)
    800027ac:	69e2                	ld	s3,24(sp)
    800027ae:	6a42                	ld	s4,16(sp)
    800027b0:	6aa2                	ld	s5,8(sp)
    800027b2:	6121                	addi	sp,sp,64
    800027b4:	8082                	ret

00000000800027b6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800027b6:	7179                	addi	sp,sp,-48
    800027b8:	f406                	sd	ra,40(sp)
    800027ba:	f022                	sd	s0,32(sp)
    800027bc:	ec26                	sd	s1,24(sp)
    800027be:	e84a                	sd	s2,16(sp)
    800027c0:	e44e                	sd	s3,8(sp)
    800027c2:	1800                	addi	s0,sp,48
    800027c4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800027c6:	00010497          	auipc	s1,0x10
    800027ca:	02248493          	addi	s1,s1,34 # 800127e8 <proc>
    800027ce:	00016997          	auipc	s3,0x16
    800027d2:	c1a98993          	addi	s3,s3,-998 # 800183e8 <tickslock>
    acquire(&p->lock);
    800027d6:	8526                	mv	a0,s1
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	596080e7          	jalr	1430(ra) # 80000d6e <acquire>
    if(p->pid == pid){
    800027e0:	40bc                	lw	a5,64(s1)
    800027e2:	01278d63          	beq	a5,s2,800027fc <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800027e6:	8526                	mv	a0,s1
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	656080e7          	jalr	1622(ra) # 80000e3e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800027f0:	17048493          	addi	s1,s1,368
    800027f4:	ff3491e3          	bne	s1,s3,800027d6 <kill+0x20>
  }
  return -1;
    800027f8:	557d                	li	a0,-1
    800027fa:	a829                	j	80002814 <kill+0x5e>
      p->killed = 1;
    800027fc:	4785                	li	a5,1
    800027fe:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    80002800:	5098                	lw	a4,32(s1)
    80002802:	4785                	li	a5,1
    80002804:	00f70f63          	beq	a4,a5,80002822 <kill+0x6c>
      release(&p->lock);
    80002808:	8526                	mv	a0,s1
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	634080e7          	jalr	1588(ra) # 80000e3e <release>
      return 0;
    80002812:	4501                	li	a0,0
}
    80002814:	70a2                	ld	ra,40(sp)
    80002816:	7402                	ld	s0,32(sp)
    80002818:	64e2                	ld	s1,24(sp)
    8000281a:	6942                	ld	s2,16(sp)
    8000281c:	69a2                	ld	s3,8(sp)
    8000281e:	6145                	addi	sp,sp,48
    80002820:	8082                	ret
        p->state = RUNNABLE;
    80002822:	4789                	li	a5,2
    80002824:	d09c                	sw	a5,32(s1)
    80002826:	b7cd                	j	80002808 <kill+0x52>

0000000080002828 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002828:	7179                	addi	sp,sp,-48
    8000282a:	f406                	sd	ra,40(sp)
    8000282c:	f022                	sd	s0,32(sp)
    8000282e:	ec26                	sd	s1,24(sp)
    80002830:	e84a                	sd	s2,16(sp)
    80002832:	e44e                	sd	s3,8(sp)
    80002834:	e052                	sd	s4,0(sp)
    80002836:	1800                	addi	s0,sp,48
    80002838:	84aa                	mv	s1,a0
    8000283a:	892e                	mv	s2,a1
    8000283c:	89b2                	mv	s3,a2
    8000283e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002840:	fffff097          	auipc	ra,0xfffff
    80002844:	576080e7          	jalr	1398(ra) # 80001db6 <myproc>
  if(user_dst){
    80002848:	c08d                	beqz	s1,8000286a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000284a:	86d2                	mv	a3,s4
    8000284c:	864e                	mv	a2,s3
    8000284e:	85ca                	mv	a1,s2
    80002850:	6d28                	ld	a0,88(a0)
    80002852:	fffff097          	auipc	ra,0xfffff
    80002856:	258080e7          	jalr	600(ra) # 80001aaa <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000285a:	70a2                	ld	ra,40(sp)
    8000285c:	7402                	ld	s0,32(sp)
    8000285e:	64e2                	ld	s1,24(sp)
    80002860:	6942                	ld	s2,16(sp)
    80002862:	69a2                	ld	s3,8(sp)
    80002864:	6a02                	ld	s4,0(sp)
    80002866:	6145                	addi	sp,sp,48
    80002868:	8082                	ret
    memmove((char *)dst, src, len);
    8000286a:	000a061b          	sext.w	a2,s4
    8000286e:	85ce                	mv	a1,s3
    80002870:	854a                	mv	a0,s2
    80002872:	fffff097          	auipc	ra,0xfffff
    80002876:	93c080e7          	jalr	-1732(ra) # 800011ae <memmove>
    return 0;
    8000287a:	8526                	mv	a0,s1
    8000287c:	bff9                	j	8000285a <either_copyout+0x32>

000000008000287e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000287e:	7179                	addi	sp,sp,-48
    80002880:	f406                	sd	ra,40(sp)
    80002882:	f022                	sd	s0,32(sp)
    80002884:	ec26                	sd	s1,24(sp)
    80002886:	e84a                	sd	s2,16(sp)
    80002888:	e44e                	sd	s3,8(sp)
    8000288a:	e052                	sd	s4,0(sp)
    8000288c:	1800                	addi	s0,sp,48
    8000288e:	892a                	mv	s2,a0
    80002890:	84ae                	mv	s1,a1
    80002892:	89b2                	mv	s3,a2
    80002894:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002896:	fffff097          	auipc	ra,0xfffff
    8000289a:	520080e7          	jalr	1312(ra) # 80001db6 <myproc>
  if(user_src){
    8000289e:	c08d                	beqz	s1,800028c0 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800028a0:	86d2                	mv	a3,s4
    800028a2:	864e                	mv	a2,s3
    800028a4:	85ca                	mv	a1,s2
    800028a6:	6d28                	ld	a0,88(a0)
    800028a8:	fffff097          	auipc	ra,0xfffff
    800028ac:	28e080e7          	jalr	654(ra) # 80001b36 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800028b0:	70a2                	ld	ra,40(sp)
    800028b2:	7402                	ld	s0,32(sp)
    800028b4:	64e2                	ld	s1,24(sp)
    800028b6:	6942                	ld	s2,16(sp)
    800028b8:	69a2                	ld	s3,8(sp)
    800028ba:	6a02                	ld	s4,0(sp)
    800028bc:	6145                	addi	sp,sp,48
    800028be:	8082                	ret
    memmove(dst, (char*)src, len);
    800028c0:	000a061b          	sext.w	a2,s4
    800028c4:	85ce                	mv	a1,s3
    800028c6:	854a                	mv	a0,s2
    800028c8:	fffff097          	auipc	ra,0xfffff
    800028cc:	8e6080e7          	jalr	-1818(ra) # 800011ae <memmove>
    return 0;
    800028d0:	8526                	mv	a0,s1
    800028d2:	bff9                	j	800028b0 <either_copyin+0x32>

00000000800028d4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800028d4:	715d                	addi	sp,sp,-80
    800028d6:	e486                	sd	ra,72(sp)
    800028d8:	e0a2                	sd	s0,64(sp)
    800028da:	fc26                	sd	s1,56(sp)
    800028dc:	f84a                	sd	s2,48(sp)
    800028de:	f44e                	sd	s3,40(sp)
    800028e0:	f052                	sd	s4,32(sp)
    800028e2:	ec56                	sd	s5,24(sp)
    800028e4:	e85a                	sd	s6,16(sp)
    800028e6:	e45e                	sd	s7,8(sp)
    800028e8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800028ea:	00006517          	auipc	a0,0x6
    800028ee:	87e50513          	addi	a0,a0,-1922 # 80008168 <digits+0x128>
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	ca8080e7          	jalr	-856(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028fa:	00010497          	auipc	s1,0x10
    800028fe:	04e48493          	addi	s1,s1,78 # 80012948 <proc+0x160>
    80002902:	00016917          	auipc	s2,0x16
    80002906:	c4690913          	addi	s2,s2,-954 # 80018548 <hashtable+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000290a:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000290c:	00006997          	auipc	s3,0x6
    80002910:	9f498993          	addi	s3,s3,-1548 # 80008300 <digits+0x2c0>
    printf("%d %s %s", p->pid, state, p->name);
    80002914:	00006a97          	auipc	s5,0x6
    80002918:	9f4a8a93          	addi	s5,s5,-1548 # 80008308 <digits+0x2c8>
    printf("\n");
    8000291c:	00006a17          	auipc	s4,0x6
    80002920:	84ca0a13          	addi	s4,s4,-1972 # 80008168 <digits+0x128>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002924:	00006b97          	auipc	s7,0x6
    80002928:	a1cb8b93          	addi	s7,s7,-1508 # 80008340 <states.1712>
    8000292c:	a00d                	j	8000294e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000292e:	ee06a583          	lw	a1,-288(a3)
    80002932:	8556                	mv	a0,s5
    80002934:	ffffe097          	auipc	ra,0xffffe
    80002938:	c66080e7          	jalr	-922(ra) # 8000059a <printf>
    printf("\n");
    8000293c:	8552                	mv	a0,s4
    8000293e:	ffffe097          	auipc	ra,0xffffe
    80002942:	c5c080e7          	jalr	-932(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002946:	17048493          	addi	s1,s1,368
    8000294a:	03248163          	beq	s1,s2,8000296c <procdump+0x98>
    if(p->state == UNUSED)
    8000294e:	86a6                	mv	a3,s1
    80002950:	ec04a783          	lw	a5,-320(s1)
    80002954:	dbed                	beqz	a5,80002946 <procdump+0x72>
      state = "???";
    80002956:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002958:	fcfb6be3          	bltu	s6,a5,8000292e <procdump+0x5a>
    8000295c:	1782                	slli	a5,a5,0x20
    8000295e:	9381                	srli	a5,a5,0x20
    80002960:	078e                	slli	a5,a5,0x3
    80002962:	97de                	add	a5,a5,s7
    80002964:	6390                	ld	a2,0(a5)
    80002966:	f661                	bnez	a2,8000292e <procdump+0x5a>
      state = "???";
    80002968:	864e                	mv	a2,s3
    8000296a:	b7d1                	j	8000292e <procdump+0x5a>
  }
}
    8000296c:	60a6                	ld	ra,72(sp)
    8000296e:	6406                	ld	s0,64(sp)
    80002970:	74e2                	ld	s1,56(sp)
    80002972:	7942                	ld	s2,48(sp)
    80002974:	79a2                	ld	s3,40(sp)
    80002976:	7a02                	ld	s4,32(sp)
    80002978:	6ae2                	ld	s5,24(sp)
    8000297a:	6b42                	ld	s6,16(sp)
    8000297c:	6ba2                	ld	s7,8(sp)
    8000297e:	6161                	addi	sp,sp,80
    80002980:	8082                	ret

0000000080002982 <swtch>:
    80002982:	00153023          	sd	ra,0(a0)
    80002986:	00253423          	sd	sp,8(a0)
    8000298a:	e900                	sd	s0,16(a0)
    8000298c:	ed04                	sd	s1,24(a0)
    8000298e:	03253023          	sd	s2,32(a0)
    80002992:	03353423          	sd	s3,40(a0)
    80002996:	03453823          	sd	s4,48(a0)
    8000299a:	03553c23          	sd	s5,56(a0)
    8000299e:	05653023          	sd	s6,64(a0)
    800029a2:	05753423          	sd	s7,72(a0)
    800029a6:	05853823          	sd	s8,80(a0)
    800029aa:	05953c23          	sd	s9,88(a0)
    800029ae:	07a53023          	sd	s10,96(a0)
    800029b2:	07b53423          	sd	s11,104(a0)
    800029b6:	0005b083          	ld	ra,0(a1)
    800029ba:	0085b103          	ld	sp,8(a1)
    800029be:	6980                	ld	s0,16(a1)
    800029c0:	6d84                	ld	s1,24(a1)
    800029c2:	0205b903          	ld	s2,32(a1)
    800029c6:	0285b983          	ld	s3,40(a1)
    800029ca:	0305ba03          	ld	s4,48(a1)
    800029ce:	0385ba83          	ld	s5,56(a1)
    800029d2:	0405bb03          	ld	s6,64(a1)
    800029d6:	0485bb83          	ld	s7,72(a1)
    800029da:	0505bc03          	ld	s8,80(a1)
    800029de:	0585bc83          	ld	s9,88(a1)
    800029e2:	0605bd03          	ld	s10,96(a1)
    800029e6:	0685bd83          	ld	s11,104(a1)
    800029ea:	8082                	ret

00000000800029ec <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800029ec:	1141                	addi	sp,sp,-16
    800029ee:	e406                	sd	ra,8(sp)
    800029f0:	e022                	sd	s0,0(sp)
    800029f2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029f4:	00006597          	auipc	a1,0x6
    800029f8:	97458593          	addi	a1,a1,-1676 # 80008368 <states.1712+0x28>
    800029fc:	00016517          	auipc	a0,0x16
    80002a00:	9ec50513          	addi	a0,a0,-1556 # 800183e8 <tickslock>
    80002a04:	ffffe097          	auipc	ra,0xffffe
    80002a08:	4e6080e7          	jalr	1254(ra) # 80000eea <initlock>
}
    80002a0c:	60a2                	ld	ra,8(sp)
    80002a0e:	6402                	ld	s0,0(sp)
    80002a10:	0141                	addi	sp,sp,16
    80002a12:	8082                	ret

0000000080002a14 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a14:	1141                	addi	sp,sp,-16
    80002a16:	e422                	sd	s0,8(sp)
    80002a18:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a1a:	00003797          	auipc	a5,0x3
    80002a1e:	66678793          	addi	a5,a5,1638 # 80006080 <kernelvec>
    80002a22:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a26:	6422                	ld	s0,8(sp)
    80002a28:	0141                	addi	sp,sp,16
    80002a2a:	8082                	ret

0000000080002a2c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a2c:	1141                	addi	sp,sp,-16
    80002a2e:	e406                	sd	ra,8(sp)
    80002a30:	e022                	sd	s0,0(sp)
    80002a32:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a34:	fffff097          	auipc	ra,0xfffff
    80002a38:	382080e7          	jalr	898(ra) # 80001db6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a3c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a40:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a42:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002a46:	00004617          	auipc	a2,0x4
    80002a4a:	5ba60613          	addi	a2,a2,1466 # 80007000 <_trampoline>
    80002a4e:	00004697          	auipc	a3,0x4
    80002a52:	5b268693          	addi	a3,a3,1458 # 80007000 <_trampoline>
    80002a56:	8e91                	sub	a3,a3,a2
    80002a58:	040007b7          	lui	a5,0x4000
    80002a5c:	17fd                	addi	a5,a5,-1
    80002a5e:	07b2                	slli	a5,a5,0xc
    80002a60:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a62:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a66:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a68:	180026f3          	csrr	a3,satp
    80002a6c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a6e:	7138                	ld	a4,96(a0)
    80002a70:	6534                	ld	a3,72(a0)
    80002a72:	6585                	lui	a1,0x1
    80002a74:	96ae                	add	a3,a3,a1
    80002a76:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a78:	7138                	ld	a4,96(a0)
    80002a7a:	00000697          	auipc	a3,0x0
    80002a7e:	13868693          	addi	a3,a3,312 # 80002bb2 <usertrap>
    80002a82:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a84:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a86:	8692                	mv	a3,tp
    80002a88:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a8a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a8e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a92:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a96:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a9a:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a9c:	6f18                	ld	a4,24(a4)
    80002a9e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002aa2:	6d2c                	ld	a1,88(a0)
    80002aa4:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002aa6:	00004717          	auipc	a4,0x4
    80002aaa:	5ea70713          	addi	a4,a4,1514 # 80007090 <userret>
    80002aae:	8f11                	sub	a4,a4,a2
    80002ab0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002ab2:	577d                	li	a4,-1
    80002ab4:	177e                	slli	a4,a4,0x3f
    80002ab6:	8dd9                	or	a1,a1,a4
    80002ab8:	02000537          	lui	a0,0x2000
    80002abc:	157d                	addi	a0,a0,-1
    80002abe:	0536                	slli	a0,a0,0xd
    80002ac0:	9782                	jalr	a5
}
    80002ac2:	60a2                	ld	ra,8(sp)
    80002ac4:	6402                	ld	s0,0(sp)
    80002ac6:	0141                	addi	sp,sp,16
    80002ac8:	8082                	ret

0000000080002aca <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	e426                	sd	s1,8(sp)
    80002ad2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ad4:	00016497          	auipc	s1,0x16
    80002ad8:	91448493          	addi	s1,s1,-1772 # 800183e8 <tickslock>
    80002adc:	8526                	mv	a0,s1
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	290080e7          	jalr	656(ra) # 80000d6e <acquire>
  ticks++;
    80002ae6:	00006517          	auipc	a0,0x6
    80002aea:	53a50513          	addi	a0,a0,1338 # 80009020 <ticks>
    80002aee:	411c                	lw	a5,0(a0)
    80002af0:	2785                	addiw	a5,a5,1
    80002af2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002af4:	00000097          	auipc	ra,0x0
    80002af8:	c58080e7          	jalr	-936(ra) # 8000274c <wakeup>
  release(&tickslock);
    80002afc:	8526                	mv	a0,s1
    80002afe:	ffffe097          	auipc	ra,0xffffe
    80002b02:	340080e7          	jalr	832(ra) # 80000e3e <release>
}
    80002b06:	60e2                	ld	ra,24(sp)
    80002b08:	6442                	ld	s0,16(sp)
    80002b0a:	64a2                	ld	s1,8(sp)
    80002b0c:	6105                	addi	sp,sp,32
    80002b0e:	8082                	ret

0000000080002b10 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b1e:	00074d63          	bltz	a4,80002b38 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b22:	57fd                	li	a5,-1
    80002b24:	17fe                	slli	a5,a5,0x3f
    80002b26:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b28:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b2a:	06f70363          	beq	a4,a5,80002b90 <devintr+0x80>
  }
}
    80002b2e:	60e2                	ld	ra,24(sp)
    80002b30:	6442                	ld	s0,16(sp)
    80002b32:	64a2                	ld	s1,8(sp)
    80002b34:	6105                	addi	sp,sp,32
    80002b36:	8082                	ret
     (scause & 0xff) == 9){
    80002b38:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b3c:	46a5                	li	a3,9
    80002b3e:	fed792e3          	bne	a5,a3,80002b22 <devintr+0x12>
    int irq = plic_claim();
    80002b42:	00003097          	auipc	ra,0x3
    80002b46:	646080e7          	jalr	1606(ra) # 80006188 <plic_claim>
    80002b4a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b4c:	47a9                	li	a5,10
    80002b4e:	02f50763          	beq	a0,a5,80002b7c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b52:	4785                	li	a5,1
    80002b54:	02f50963          	beq	a0,a5,80002b86 <devintr+0x76>
    return 1;
    80002b58:	4505                	li	a0,1
    } else if(irq){
    80002b5a:	d8f1                	beqz	s1,80002b2e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b5c:	85a6                	mv	a1,s1
    80002b5e:	00006517          	auipc	a0,0x6
    80002b62:	81250513          	addi	a0,a0,-2030 # 80008370 <states.1712+0x30>
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	a34080e7          	jalr	-1484(ra) # 8000059a <printf>
      plic_complete(irq);
    80002b6e:	8526                	mv	a0,s1
    80002b70:	00003097          	auipc	ra,0x3
    80002b74:	63c080e7          	jalr	1596(ra) # 800061ac <plic_complete>
    return 1;
    80002b78:	4505                	li	a0,1
    80002b7a:	bf55                	j	80002b2e <devintr+0x1e>
      uartintr();
    80002b7c:	ffffe097          	auipc	ra,0xffffe
    80002b80:	e60080e7          	jalr	-416(ra) # 800009dc <uartintr>
    80002b84:	b7ed                	j	80002b6e <devintr+0x5e>
      virtio_disk_intr();
    80002b86:	00004097          	auipc	ra,0x4
    80002b8a:	b06080e7          	jalr	-1274(ra) # 8000668c <virtio_disk_intr>
    80002b8e:	b7c5                	j	80002b6e <devintr+0x5e>
    if(cpuid() == 0){
    80002b90:	fffff097          	auipc	ra,0xfffff
    80002b94:	1fa080e7          	jalr	506(ra) # 80001d8a <cpuid>
    80002b98:	c901                	beqz	a0,80002ba8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b9a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b9e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ba0:	14479073          	csrw	sip,a5
    return 2;
    80002ba4:	4509                	li	a0,2
    80002ba6:	b761                	j	80002b2e <devintr+0x1e>
      clockintr();
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	f22080e7          	jalr	-222(ra) # 80002aca <clockintr>
    80002bb0:	b7ed                	j	80002b9a <devintr+0x8a>

0000000080002bb2 <usertrap>:
{
    80002bb2:	1101                	addi	sp,sp,-32
    80002bb4:	ec06                	sd	ra,24(sp)
    80002bb6:	e822                	sd	s0,16(sp)
    80002bb8:	e426                	sd	s1,8(sp)
    80002bba:	e04a                	sd	s2,0(sp)
    80002bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbe:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bc2:	1007f793          	andi	a5,a5,256
    80002bc6:	e3ad                	bnez	a5,80002c28 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bc8:	00003797          	auipc	a5,0x3
    80002bcc:	4b878793          	addi	a5,a5,1208 # 80006080 <kernelvec>
    80002bd0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bd4:	fffff097          	auipc	ra,0xfffff
    80002bd8:	1e2080e7          	jalr	482(ra) # 80001db6 <myproc>
    80002bdc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bde:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be0:	14102773          	csrr	a4,sepc
    80002be4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002be6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bea:	47a1                	li	a5,8
    80002bec:	04f71c63          	bne	a4,a5,80002c44 <usertrap+0x92>
    if(p->killed)
    80002bf0:	5d1c                	lw	a5,56(a0)
    80002bf2:	e3b9                	bnez	a5,80002c38 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002bf4:	70b8                	ld	a4,96(s1)
    80002bf6:	6f1c                	ld	a5,24(a4)
    80002bf8:	0791                	addi	a5,a5,4
    80002bfa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bfc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c00:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c04:	10079073          	csrw	sstatus,a5
    syscall();
    80002c08:	00000097          	auipc	ra,0x0
    80002c0c:	2e0080e7          	jalr	736(ra) # 80002ee8 <syscall>
  if(p->killed)
    80002c10:	5c9c                	lw	a5,56(s1)
    80002c12:	ebc1                	bnez	a5,80002ca2 <usertrap+0xf0>
  usertrapret();
    80002c14:	00000097          	auipc	ra,0x0
    80002c18:	e18080e7          	jalr	-488(ra) # 80002a2c <usertrapret>
}
    80002c1c:	60e2                	ld	ra,24(sp)
    80002c1e:	6442                	ld	s0,16(sp)
    80002c20:	64a2                	ld	s1,8(sp)
    80002c22:	6902                	ld	s2,0(sp)
    80002c24:	6105                	addi	sp,sp,32
    80002c26:	8082                	ret
    panic("usertrap: not from user mode");
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	76850513          	addi	a0,a0,1896 # 80008390 <states.1712+0x50>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	920080e7          	jalr	-1760(ra) # 80000550 <panic>
      exit(-1);
    80002c38:	557d                	li	a0,-1
    80002c3a:	00000097          	auipc	ra,0x0
    80002c3e:	846080e7          	jalr	-1978(ra) # 80002480 <exit>
    80002c42:	bf4d                	j	80002bf4 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	ecc080e7          	jalr	-308(ra) # 80002b10 <devintr>
    80002c4c:	892a                	mv	s2,a0
    80002c4e:	c501                	beqz	a0,80002c56 <usertrap+0xa4>
  if(p->killed)
    80002c50:	5c9c                	lw	a5,56(s1)
    80002c52:	c3a1                	beqz	a5,80002c92 <usertrap+0xe0>
    80002c54:	a815                	j	80002c88 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c56:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c5a:	40b0                	lw	a2,64(s1)
    80002c5c:	00005517          	auipc	a0,0x5
    80002c60:	75450513          	addi	a0,a0,1876 # 800083b0 <states.1712+0x70>
    80002c64:	ffffe097          	auipc	ra,0xffffe
    80002c68:	936080e7          	jalr	-1738(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c6c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c70:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c74:	00005517          	auipc	a0,0x5
    80002c78:	76c50513          	addi	a0,a0,1900 # 800083e0 <states.1712+0xa0>
    80002c7c:	ffffe097          	auipc	ra,0xffffe
    80002c80:	91e080e7          	jalr	-1762(ra) # 8000059a <printf>
    p->killed = 1;
    80002c84:	4785                	li	a5,1
    80002c86:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002c88:	557d                	li	a0,-1
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	7f6080e7          	jalr	2038(ra) # 80002480 <exit>
  if(which_dev == 2)
    80002c92:	4789                	li	a5,2
    80002c94:	f8f910e3          	bne	s2,a5,80002c14 <usertrap+0x62>
    yield();
    80002c98:	00000097          	auipc	ra,0x0
    80002c9c:	8f2080e7          	jalr	-1806(ra) # 8000258a <yield>
    80002ca0:	bf95                	j	80002c14 <usertrap+0x62>
  int which_dev = 0;
    80002ca2:	4901                	li	s2,0
    80002ca4:	b7d5                	j	80002c88 <usertrap+0xd6>

0000000080002ca6 <kerneltrap>:
{
    80002ca6:	7179                	addi	sp,sp,-48
    80002ca8:	f406                	sd	ra,40(sp)
    80002caa:	f022                	sd	s0,32(sp)
    80002cac:	ec26                	sd	s1,24(sp)
    80002cae:	e84a                	sd	s2,16(sp)
    80002cb0:	e44e                	sd	s3,8(sp)
    80002cb2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cb8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cbc:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002cc0:	1004f793          	andi	a5,s1,256
    80002cc4:	cb85                	beqz	a5,80002cf4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cca:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ccc:	ef85                	bnez	a5,80002d04 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cce:	00000097          	auipc	ra,0x0
    80002cd2:	e42080e7          	jalr	-446(ra) # 80002b10 <devintr>
    80002cd6:	cd1d                	beqz	a0,80002d14 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cd8:	4789                	li	a5,2
    80002cda:	06f50a63          	beq	a0,a5,80002d4e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cde:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ce2:	10049073          	csrw	sstatus,s1
}
    80002ce6:	70a2                	ld	ra,40(sp)
    80002ce8:	7402                	ld	s0,32(sp)
    80002cea:	64e2                	ld	s1,24(sp)
    80002cec:	6942                	ld	s2,16(sp)
    80002cee:	69a2                	ld	s3,8(sp)
    80002cf0:	6145                	addi	sp,sp,48
    80002cf2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cf4:	00005517          	auipc	a0,0x5
    80002cf8:	70c50513          	addi	a0,a0,1804 # 80008400 <states.1712+0xc0>
    80002cfc:	ffffe097          	auipc	ra,0xffffe
    80002d00:	854080e7          	jalr	-1964(ra) # 80000550 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d04:	00005517          	auipc	a0,0x5
    80002d08:	72450513          	addi	a0,a0,1828 # 80008428 <states.1712+0xe8>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	844080e7          	jalr	-1980(ra) # 80000550 <panic>
    printf("scause %p\n", scause);
    80002d14:	85ce                	mv	a1,s3
    80002d16:	00005517          	auipc	a0,0x5
    80002d1a:	73250513          	addi	a0,a0,1842 # 80008448 <states.1712+0x108>
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	87c080e7          	jalr	-1924(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d26:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d2a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d2e:	00005517          	auipc	a0,0x5
    80002d32:	72a50513          	addi	a0,a0,1834 # 80008458 <states.1712+0x118>
    80002d36:	ffffe097          	auipc	ra,0xffffe
    80002d3a:	864080e7          	jalr	-1948(ra) # 8000059a <printf>
    panic("kerneltrap");
    80002d3e:	00005517          	auipc	a0,0x5
    80002d42:	73250513          	addi	a0,a0,1842 # 80008470 <states.1712+0x130>
    80002d46:	ffffe097          	auipc	ra,0xffffe
    80002d4a:	80a080e7          	jalr	-2038(ra) # 80000550 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	068080e7          	jalr	104(ra) # 80001db6 <myproc>
    80002d56:	d541                	beqz	a0,80002cde <kerneltrap+0x38>
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	05e080e7          	jalr	94(ra) # 80001db6 <myproc>
    80002d60:	5118                	lw	a4,32(a0)
    80002d62:	478d                	li	a5,3
    80002d64:	f6f71de3          	bne	a4,a5,80002cde <kerneltrap+0x38>
    yield();
    80002d68:	00000097          	auipc	ra,0x0
    80002d6c:	822080e7          	jalr	-2014(ra) # 8000258a <yield>
    80002d70:	b7bd                	j	80002cde <kerneltrap+0x38>

0000000080002d72 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d72:	1101                	addi	sp,sp,-32
    80002d74:	ec06                	sd	ra,24(sp)
    80002d76:	e822                	sd	s0,16(sp)
    80002d78:	e426                	sd	s1,8(sp)
    80002d7a:	1000                	addi	s0,sp,32
    80002d7c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d7e:	fffff097          	auipc	ra,0xfffff
    80002d82:	038080e7          	jalr	56(ra) # 80001db6 <myproc>
  switch (n) {
    80002d86:	4795                	li	a5,5
    80002d88:	0497e163          	bltu	a5,s1,80002dca <argraw+0x58>
    80002d8c:	048a                	slli	s1,s1,0x2
    80002d8e:	00005717          	auipc	a4,0x5
    80002d92:	71a70713          	addi	a4,a4,1818 # 800084a8 <states.1712+0x168>
    80002d96:	94ba                	add	s1,s1,a4
    80002d98:	409c                	lw	a5,0(s1)
    80002d9a:	97ba                	add	a5,a5,a4
    80002d9c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d9e:	713c                	ld	a5,96(a0)
    80002da0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002da2:	60e2                	ld	ra,24(sp)
    80002da4:	6442                	ld	s0,16(sp)
    80002da6:	64a2                	ld	s1,8(sp)
    80002da8:	6105                	addi	sp,sp,32
    80002daa:	8082                	ret
    return p->trapframe->a1;
    80002dac:	713c                	ld	a5,96(a0)
    80002dae:	7fa8                	ld	a0,120(a5)
    80002db0:	bfcd                	j	80002da2 <argraw+0x30>
    return p->trapframe->a2;
    80002db2:	713c                	ld	a5,96(a0)
    80002db4:	63c8                	ld	a0,128(a5)
    80002db6:	b7f5                	j	80002da2 <argraw+0x30>
    return p->trapframe->a3;
    80002db8:	713c                	ld	a5,96(a0)
    80002dba:	67c8                	ld	a0,136(a5)
    80002dbc:	b7dd                	j	80002da2 <argraw+0x30>
    return p->trapframe->a4;
    80002dbe:	713c                	ld	a5,96(a0)
    80002dc0:	6bc8                	ld	a0,144(a5)
    80002dc2:	b7c5                	j	80002da2 <argraw+0x30>
    return p->trapframe->a5;
    80002dc4:	713c                	ld	a5,96(a0)
    80002dc6:	6fc8                	ld	a0,152(a5)
    80002dc8:	bfe9                	j	80002da2 <argraw+0x30>
  panic("argraw");
    80002dca:	00005517          	auipc	a0,0x5
    80002dce:	6b650513          	addi	a0,a0,1718 # 80008480 <states.1712+0x140>
    80002dd2:	ffffd097          	auipc	ra,0xffffd
    80002dd6:	77e080e7          	jalr	1918(ra) # 80000550 <panic>

0000000080002dda <fetchaddr>:
{
    80002dda:	1101                	addi	sp,sp,-32
    80002ddc:	ec06                	sd	ra,24(sp)
    80002dde:	e822                	sd	s0,16(sp)
    80002de0:	e426                	sd	s1,8(sp)
    80002de2:	e04a                	sd	s2,0(sp)
    80002de4:	1000                	addi	s0,sp,32
    80002de6:	84aa                	mv	s1,a0
    80002de8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dea:	fffff097          	auipc	ra,0xfffff
    80002dee:	fcc080e7          	jalr	-52(ra) # 80001db6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002df2:	693c                	ld	a5,80(a0)
    80002df4:	02f4f863          	bgeu	s1,a5,80002e24 <fetchaddr+0x4a>
    80002df8:	00848713          	addi	a4,s1,8
    80002dfc:	02e7e663          	bltu	a5,a4,80002e28 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e00:	46a1                	li	a3,8
    80002e02:	8626                	mv	a2,s1
    80002e04:	85ca                	mv	a1,s2
    80002e06:	6d28                	ld	a0,88(a0)
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	d2e080e7          	jalr	-722(ra) # 80001b36 <copyin>
    80002e10:	00a03533          	snez	a0,a0
    80002e14:	40a00533          	neg	a0,a0
}
    80002e18:	60e2                	ld	ra,24(sp)
    80002e1a:	6442                	ld	s0,16(sp)
    80002e1c:	64a2                	ld	s1,8(sp)
    80002e1e:	6902                	ld	s2,0(sp)
    80002e20:	6105                	addi	sp,sp,32
    80002e22:	8082                	ret
    return -1;
    80002e24:	557d                	li	a0,-1
    80002e26:	bfcd                	j	80002e18 <fetchaddr+0x3e>
    80002e28:	557d                	li	a0,-1
    80002e2a:	b7fd                	j	80002e18 <fetchaddr+0x3e>

0000000080002e2c <fetchstr>:
{
    80002e2c:	7179                	addi	sp,sp,-48
    80002e2e:	f406                	sd	ra,40(sp)
    80002e30:	f022                	sd	s0,32(sp)
    80002e32:	ec26                	sd	s1,24(sp)
    80002e34:	e84a                	sd	s2,16(sp)
    80002e36:	e44e                	sd	s3,8(sp)
    80002e38:	1800                	addi	s0,sp,48
    80002e3a:	892a                	mv	s2,a0
    80002e3c:	84ae                	mv	s1,a1
    80002e3e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	f76080e7          	jalr	-138(ra) # 80001db6 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002e48:	86ce                	mv	a3,s3
    80002e4a:	864a                	mv	a2,s2
    80002e4c:	85a6                	mv	a1,s1
    80002e4e:	6d28                	ld	a0,88(a0)
    80002e50:	fffff097          	auipc	ra,0xfffff
    80002e54:	d72080e7          	jalr	-654(ra) # 80001bc2 <copyinstr>
  if(err < 0)
    80002e58:	00054763          	bltz	a0,80002e66 <fetchstr+0x3a>
  return strlen(buf);
    80002e5c:	8526                	mv	a0,s1
    80002e5e:	ffffe097          	auipc	ra,0xffffe
    80002e62:	478080e7          	jalr	1144(ra) # 800012d6 <strlen>
}
    80002e66:	70a2                	ld	ra,40(sp)
    80002e68:	7402                	ld	s0,32(sp)
    80002e6a:	64e2                	ld	s1,24(sp)
    80002e6c:	6942                	ld	s2,16(sp)
    80002e6e:	69a2                	ld	s3,8(sp)
    80002e70:	6145                	addi	sp,sp,48
    80002e72:	8082                	ret

0000000080002e74 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e74:	1101                	addi	sp,sp,-32
    80002e76:	ec06                	sd	ra,24(sp)
    80002e78:	e822                	sd	s0,16(sp)
    80002e7a:	e426                	sd	s1,8(sp)
    80002e7c:	1000                	addi	s0,sp,32
    80002e7e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	ef2080e7          	jalr	-270(ra) # 80002d72 <argraw>
    80002e88:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e8a:	4501                	li	a0,0
    80002e8c:	60e2                	ld	ra,24(sp)
    80002e8e:	6442                	ld	s0,16(sp)
    80002e90:	64a2                	ld	s1,8(sp)
    80002e92:	6105                	addi	sp,sp,32
    80002e94:	8082                	ret

0000000080002e96 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e96:	1101                	addi	sp,sp,-32
    80002e98:	ec06                	sd	ra,24(sp)
    80002e9a:	e822                	sd	s0,16(sp)
    80002e9c:	e426                	sd	s1,8(sp)
    80002e9e:	1000                	addi	s0,sp,32
    80002ea0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ea2:	00000097          	auipc	ra,0x0
    80002ea6:	ed0080e7          	jalr	-304(ra) # 80002d72 <argraw>
    80002eaa:	e088                	sd	a0,0(s1)
  return 0;
}
    80002eac:	4501                	li	a0,0
    80002eae:	60e2                	ld	ra,24(sp)
    80002eb0:	6442                	ld	s0,16(sp)
    80002eb2:	64a2                	ld	s1,8(sp)
    80002eb4:	6105                	addi	sp,sp,32
    80002eb6:	8082                	ret

0000000080002eb8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002eb8:	1101                	addi	sp,sp,-32
    80002eba:	ec06                	sd	ra,24(sp)
    80002ebc:	e822                	sd	s0,16(sp)
    80002ebe:	e426                	sd	s1,8(sp)
    80002ec0:	e04a                	sd	s2,0(sp)
    80002ec2:	1000                	addi	s0,sp,32
    80002ec4:	84ae                	mv	s1,a1
    80002ec6:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002ec8:	00000097          	auipc	ra,0x0
    80002ecc:	eaa080e7          	jalr	-342(ra) # 80002d72 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002ed0:	864a                	mv	a2,s2
    80002ed2:	85a6                	mv	a1,s1
    80002ed4:	00000097          	auipc	ra,0x0
    80002ed8:	f58080e7          	jalr	-168(ra) # 80002e2c <fetchstr>
}
    80002edc:	60e2                	ld	ra,24(sp)
    80002ede:	6442                	ld	s0,16(sp)
    80002ee0:	64a2                	ld	s1,8(sp)
    80002ee2:	6902                	ld	s2,0(sp)
    80002ee4:	6105                	addi	sp,sp,32
    80002ee6:	8082                	ret

0000000080002ee8 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002ee8:	1101                	addi	sp,sp,-32
    80002eea:	ec06                	sd	ra,24(sp)
    80002eec:	e822                	sd	s0,16(sp)
    80002eee:	e426                	sd	s1,8(sp)
    80002ef0:	e04a                	sd	s2,0(sp)
    80002ef2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ef4:	fffff097          	auipc	ra,0xfffff
    80002ef8:	ec2080e7          	jalr	-318(ra) # 80001db6 <myproc>
    80002efc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002efe:	06053903          	ld	s2,96(a0)
    80002f02:	0a893783          	ld	a5,168(s2)
    80002f06:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f0a:	37fd                	addiw	a5,a5,-1
    80002f0c:	4751                	li	a4,20
    80002f0e:	00f76f63          	bltu	a4,a5,80002f2c <syscall+0x44>
    80002f12:	00369713          	slli	a4,a3,0x3
    80002f16:	00005797          	auipc	a5,0x5
    80002f1a:	5aa78793          	addi	a5,a5,1450 # 800084c0 <syscalls>
    80002f1e:	97ba                	add	a5,a5,a4
    80002f20:	639c                	ld	a5,0(a5)
    80002f22:	c789                	beqz	a5,80002f2c <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002f24:	9782                	jalr	a5
    80002f26:	06a93823          	sd	a0,112(s2)
    80002f2a:	a839                	j	80002f48 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f2c:	16048613          	addi	a2,s1,352
    80002f30:	40ac                	lw	a1,64(s1)
    80002f32:	00005517          	auipc	a0,0x5
    80002f36:	55650513          	addi	a0,a0,1366 # 80008488 <states.1712+0x148>
    80002f3a:	ffffd097          	auipc	ra,0xffffd
    80002f3e:	660080e7          	jalr	1632(ra) # 8000059a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f42:	70bc                	ld	a5,96(s1)
    80002f44:	577d                	li	a4,-1
    80002f46:	fbb8                	sd	a4,112(a5)
  }
}
    80002f48:	60e2                	ld	ra,24(sp)
    80002f4a:	6442                	ld	s0,16(sp)
    80002f4c:	64a2                	ld	s1,8(sp)
    80002f4e:	6902                	ld	s2,0(sp)
    80002f50:	6105                	addi	sp,sp,32
    80002f52:	8082                	ret

0000000080002f54 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f54:	1101                	addi	sp,sp,-32
    80002f56:	ec06                	sd	ra,24(sp)
    80002f58:	e822                	sd	s0,16(sp)
    80002f5a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f5c:	fec40593          	addi	a1,s0,-20
    80002f60:	4501                	li	a0,0
    80002f62:	00000097          	auipc	ra,0x0
    80002f66:	f12080e7          	jalr	-238(ra) # 80002e74 <argint>
    return -1;
    80002f6a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f6c:	00054963          	bltz	a0,80002f7e <sys_exit+0x2a>
  exit(n);
    80002f70:	fec42503          	lw	a0,-20(s0)
    80002f74:	fffff097          	auipc	ra,0xfffff
    80002f78:	50c080e7          	jalr	1292(ra) # 80002480 <exit>
  return 0;  // not reached
    80002f7c:	4781                	li	a5,0
}
    80002f7e:	853e                	mv	a0,a5
    80002f80:	60e2                	ld	ra,24(sp)
    80002f82:	6442                	ld	s0,16(sp)
    80002f84:	6105                	addi	sp,sp,32
    80002f86:	8082                	ret

0000000080002f88 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f88:	1141                	addi	sp,sp,-16
    80002f8a:	e406                	sd	ra,8(sp)
    80002f8c:	e022                	sd	s0,0(sp)
    80002f8e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f90:	fffff097          	auipc	ra,0xfffff
    80002f94:	e26080e7          	jalr	-474(ra) # 80001db6 <myproc>
}
    80002f98:	4128                	lw	a0,64(a0)
    80002f9a:	60a2                	ld	ra,8(sp)
    80002f9c:	6402                	ld	s0,0(sp)
    80002f9e:	0141                	addi	sp,sp,16
    80002fa0:	8082                	ret

0000000080002fa2 <sys_fork>:

uint64
sys_fork(void)
{
    80002fa2:	1141                	addi	sp,sp,-16
    80002fa4:	e406                	sd	ra,8(sp)
    80002fa6:	e022                	sd	s0,0(sp)
    80002fa8:	0800                	addi	s0,sp,16
  return fork();
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	1cc080e7          	jalr	460(ra) # 80002176 <fork>
}
    80002fb2:	60a2                	ld	ra,8(sp)
    80002fb4:	6402                	ld	s0,0(sp)
    80002fb6:	0141                	addi	sp,sp,16
    80002fb8:	8082                	ret

0000000080002fba <sys_wait>:

uint64
sys_wait(void)
{
    80002fba:	1101                	addi	sp,sp,-32
    80002fbc:	ec06                	sd	ra,24(sp)
    80002fbe:	e822                	sd	s0,16(sp)
    80002fc0:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002fc2:	fe840593          	addi	a1,s0,-24
    80002fc6:	4501                	li	a0,0
    80002fc8:	00000097          	auipc	ra,0x0
    80002fcc:	ece080e7          	jalr	-306(ra) # 80002e96 <argaddr>
    80002fd0:	87aa                	mv	a5,a0
    return -1;
    80002fd2:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002fd4:	0007c863          	bltz	a5,80002fe4 <sys_wait+0x2a>
  return wait(p);
    80002fd8:	fe843503          	ld	a0,-24(s0)
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	668080e7          	jalr	1640(ra) # 80002644 <wait>
}
    80002fe4:	60e2                	ld	ra,24(sp)
    80002fe6:	6442                	ld	s0,16(sp)
    80002fe8:	6105                	addi	sp,sp,32
    80002fea:	8082                	ret

0000000080002fec <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fec:	7179                	addi	sp,sp,-48
    80002fee:	f406                	sd	ra,40(sp)
    80002ff0:	f022                	sd	s0,32(sp)
    80002ff2:	ec26                	sd	s1,24(sp)
    80002ff4:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002ff6:	fdc40593          	addi	a1,s0,-36
    80002ffa:	4501                	li	a0,0
    80002ffc:	00000097          	auipc	ra,0x0
    80003000:	e78080e7          	jalr	-392(ra) # 80002e74 <argint>
    80003004:	87aa                	mv	a5,a0
    return -1;
    80003006:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003008:	0207c063          	bltz	a5,80003028 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    8000300c:	fffff097          	auipc	ra,0xfffff
    80003010:	daa080e7          	jalr	-598(ra) # 80001db6 <myproc>
    80003014:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80003016:	fdc42503          	lw	a0,-36(s0)
    8000301a:	fffff097          	auipc	ra,0xfffff
    8000301e:	0e8080e7          	jalr	232(ra) # 80002102 <growproc>
    80003022:	00054863          	bltz	a0,80003032 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003026:	8526                	mv	a0,s1
}
    80003028:	70a2                	ld	ra,40(sp)
    8000302a:	7402                	ld	s0,32(sp)
    8000302c:	64e2                	ld	s1,24(sp)
    8000302e:	6145                	addi	sp,sp,48
    80003030:	8082                	ret
    return -1;
    80003032:	557d                	li	a0,-1
    80003034:	bfd5                	j	80003028 <sys_sbrk+0x3c>

0000000080003036 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003036:	7139                	addi	sp,sp,-64
    80003038:	fc06                	sd	ra,56(sp)
    8000303a:	f822                	sd	s0,48(sp)
    8000303c:	f426                	sd	s1,40(sp)
    8000303e:	f04a                	sd	s2,32(sp)
    80003040:	ec4e                	sd	s3,24(sp)
    80003042:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003044:	fcc40593          	addi	a1,s0,-52
    80003048:	4501                	li	a0,0
    8000304a:	00000097          	auipc	ra,0x0
    8000304e:	e2a080e7          	jalr	-470(ra) # 80002e74 <argint>
    return -1;
    80003052:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003054:	06054563          	bltz	a0,800030be <sys_sleep+0x88>
  acquire(&tickslock);
    80003058:	00015517          	auipc	a0,0x15
    8000305c:	39050513          	addi	a0,a0,912 # 800183e8 <tickslock>
    80003060:	ffffe097          	auipc	ra,0xffffe
    80003064:	d0e080e7          	jalr	-754(ra) # 80000d6e <acquire>
  ticks0 = ticks;
    80003068:	00006917          	auipc	s2,0x6
    8000306c:	fb892903          	lw	s2,-72(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80003070:	fcc42783          	lw	a5,-52(s0)
    80003074:	cf85                	beqz	a5,800030ac <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003076:	00015997          	auipc	s3,0x15
    8000307a:	37298993          	addi	s3,s3,882 # 800183e8 <tickslock>
    8000307e:	00006497          	auipc	s1,0x6
    80003082:	fa248493          	addi	s1,s1,-94 # 80009020 <ticks>
    if(myproc()->killed){
    80003086:	fffff097          	auipc	ra,0xfffff
    8000308a:	d30080e7          	jalr	-720(ra) # 80001db6 <myproc>
    8000308e:	5d1c                	lw	a5,56(a0)
    80003090:	ef9d                	bnez	a5,800030ce <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003092:	85ce                	mv	a1,s3
    80003094:	8526                	mv	a0,s1
    80003096:	fffff097          	auipc	ra,0xfffff
    8000309a:	530080e7          	jalr	1328(ra) # 800025c6 <sleep>
  while(ticks - ticks0 < n){
    8000309e:	409c                	lw	a5,0(s1)
    800030a0:	412787bb          	subw	a5,a5,s2
    800030a4:	fcc42703          	lw	a4,-52(s0)
    800030a8:	fce7efe3          	bltu	a5,a4,80003086 <sys_sleep+0x50>
  }
  release(&tickslock);
    800030ac:	00015517          	auipc	a0,0x15
    800030b0:	33c50513          	addi	a0,a0,828 # 800183e8 <tickslock>
    800030b4:	ffffe097          	auipc	ra,0xffffe
    800030b8:	d8a080e7          	jalr	-630(ra) # 80000e3e <release>
  return 0;
    800030bc:	4781                	li	a5,0
}
    800030be:	853e                	mv	a0,a5
    800030c0:	70e2                	ld	ra,56(sp)
    800030c2:	7442                	ld	s0,48(sp)
    800030c4:	74a2                	ld	s1,40(sp)
    800030c6:	7902                	ld	s2,32(sp)
    800030c8:	69e2                	ld	s3,24(sp)
    800030ca:	6121                	addi	sp,sp,64
    800030cc:	8082                	ret
      release(&tickslock);
    800030ce:	00015517          	auipc	a0,0x15
    800030d2:	31a50513          	addi	a0,a0,794 # 800183e8 <tickslock>
    800030d6:	ffffe097          	auipc	ra,0xffffe
    800030da:	d68080e7          	jalr	-664(ra) # 80000e3e <release>
      return -1;
    800030de:	57fd                	li	a5,-1
    800030e0:	bff9                	j	800030be <sys_sleep+0x88>

00000000800030e2 <sys_kill>:

uint64
sys_kill(void)
{
    800030e2:	1101                	addi	sp,sp,-32
    800030e4:	ec06                	sd	ra,24(sp)
    800030e6:	e822                	sd	s0,16(sp)
    800030e8:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800030ea:	fec40593          	addi	a1,s0,-20
    800030ee:	4501                	li	a0,0
    800030f0:	00000097          	auipc	ra,0x0
    800030f4:	d84080e7          	jalr	-636(ra) # 80002e74 <argint>
    800030f8:	87aa                	mv	a5,a0
    return -1;
    800030fa:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800030fc:	0007c863          	bltz	a5,8000310c <sys_kill+0x2a>
  return kill(pid);
    80003100:	fec42503          	lw	a0,-20(s0)
    80003104:	fffff097          	auipc	ra,0xfffff
    80003108:	6b2080e7          	jalr	1714(ra) # 800027b6 <kill>
}
    8000310c:	60e2                	ld	ra,24(sp)
    8000310e:	6442                	ld	s0,16(sp)
    80003110:	6105                	addi	sp,sp,32
    80003112:	8082                	ret

0000000080003114 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003114:	1101                	addi	sp,sp,-32
    80003116:	ec06                	sd	ra,24(sp)
    80003118:	e822                	sd	s0,16(sp)
    8000311a:	e426                	sd	s1,8(sp)
    8000311c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000311e:	00015517          	auipc	a0,0x15
    80003122:	2ca50513          	addi	a0,a0,714 # 800183e8 <tickslock>
    80003126:	ffffe097          	auipc	ra,0xffffe
    8000312a:	c48080e7          	jalr	-952(ra) # 80000d6e <acquire>
  xticks = ticks;
    8000312e:	00006497          	auipc	s1,0x6
    80003132:	ef24a483          	lw	s1,-270(s1) # 80009020 <ticks>
  release(&tickslock);
    80003136:	00015517          	auipc	a0,0x15
    8000313a:	2b250513          	addi	a0,a0,690 # 800183e8 <tickslock>
    8000313e:	ffffe097          	auipc	ra,0xffffe
    80003142:	d00080e7          	jalr	-768(ra) # 80000e3e <release>
  return xticks;
}
    80003146:	02049513          	slli	a0,s1,0x20
    8000314a:	9101                	srli	a0,a0,0x20
    8000314c:	60e2                	ld	ra,24(sp)
    8000314e:	6442                	ld	s0,16(sp)
    80003150:	64a2                	ld	s1,8(sp)
    80003152:	6105                	addi	sp,sp,32
    80003154:	8082                	ret

0000000080003156 <hash>:
  struct buf head;
}hashtable[NBUCKET];

int
hash(uint dev, uint blockno)
{
    80003156:	1141                	addi	sp,sp,-16
    80003158:	e422                	sd	s0,8(sp)
    8000315a:	0800                	addi	s0,sp,16
  return blockno % NBUCKET;
}
    8000315c:	4535                	li	a0,13
    8000315e:	02a5f53b          	remuw	a0,a1,a0
    80003162:	6422                	ld	s0,8(sp)
    80003164:	0141                	addi	sp,sp,16
    80003166:	8082                	ret

0000000080003168 <binit>:

void
binit(void)
{
    80003168:	7139                	addi	sp,sp,-64
    8000316a:	fc06                	sd	ra,56(sp)
    8000316c:	f822                	sd	s0,48(sp)
    8000316e:	f426                	sd	s1,40(sp)
    80003170:	f04a                	sd	s2,32(sp)
    80003172:	ec4e                	sd	s3,24(sp)
    80003174:	e852                	sd	s4,16(sp)
    80003176:	e456                	sd	s5,8(sp)
    80003178:	e05a                	sd	s6,0(sp)
    8000317a:	0080                	addi	s0,sp,64
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000317c:	00005597          	auipc	a1,0x5
    80003180:	f8458593          	addi	a1,a1,-124 # 80008100 <digits+0xc0>
    80003184:	00019517          	auipc	a0,0x19
    80003188:	d0450513          	addi	a0,a0,-764 # 8001be88 <bcache>
    8000318c:	ffffe097          	auipc	ra,0xffffe
    80003190:	d5e080e7          	jalr	-674(ra) # 80000eea <initlock>

  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003194:	00019497          	auipc	s1,0x19
    80003198:	d2448493          	addi	s1,s1,-732 # 8001beb8 <bcache+0x30>
    8000319c:	00023997          	auipc	s3,0x23
    800031a0:	7bc98993          	addi	s3,s3,1980 # 80026958 <sb+0x10>
    initsleeplock(&b->lock, "buffer");
    800031a4:	00005917          	auipc	s2,0x5
    800031a8:	3cc90913          	addi	s2,s2,972 # 80008570 <syscalls+0xb0>
    800031ac:	85ca                	mv	a1,s2
    800031ae:	8526                	mv	a0,s1
    800031b0:	00001097          	auipc	ra,0x1
    800031b4:	64e080e7          	jalr	1614(ra) # 800047fe <initsleeplock>
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031b8:	46048493          	addi	s1,s1,1120
    800031bc:	ff3498e3          	bne	s1,s3,800031ac <binit+0x44>
    800031c0:	00015917          	auipc	s2,0x15
    800031c4:	24890913          	addi	s2,s2,584 # 80018408 <hashtable>
    800031c8:	00019497          	auipc	s1,0x19
    800031cc:	14048493          	addi	s1,s1,320 # 8001c308 <bcache+0x480>
  }

  b = bcache.buf;
  for (int i = 0; i < NBUCKET; i++) {
    800031d0:	4981                	li	s3,0
    initlock(&hashtable[i].lock, "bcache_bucket");
    800031d2:	00005b17          	auipc	s6,0x5
    800031d6:	3a6b0b13          	addi	s6,s6,934 # 80008578 <syscalls+0xb8>
    800031da:	6a05                	lui	s4,0x1
    800031dc:	d20a0a13          	addi	s4,s4,-736 # d20 <_entry-0x7ffff2e0>
  for (int i = 0; i < NBUCKET; i++) {
    800031e0:	4ab5                	li	s5,13
    initlock(&hashtable[i].lock, "bcache_bucket");
    800031e2:	85da                	mv	a1,s6
    800031e4:	854a                	mv	a0,s2
    800031e6:	ffffe097          	auipc	ra,0xffffe
    800031ea:	d04080e7          	jalr	-764(ra) # 80000eea <initlock>
    for (int j = 0; j < NBUF / NBUCKET; j++) {
    800031ee:	07093703          	ld	a4,112(s2)
      b->blockno = i;
    800031f2:	0009879b          	sext.w	a5,s3
    800031f6:	baf4a623          	sw	a5,-1108(s1)
      b->next = hashtable[i].head.next;
    800031fa:	bee4b823          	sd	a4,-1040(s1)
      b->blockno = i;
    800031fe:	c4dc                	sw	a5,12(s1)
      b->next = hashtable[i].head.next;
    80003200:	ba048713          	addi	a4,s1,-1120
    80003204:	e8b8                	sd	a4,80(s1)
      b->blockno = i;
    80003206:	46f4a623          	sw	a5,1132(s1)
      b->next = hashtable[i].head.next;
    8000320a:	4a94b823          	sd	s1,1200(s1)
    for (int j = 0; j < NBUF / NBUCKET; j++) {
    8000320e:	46048793          	addi	a5,s1,1120
    80003212:	06f93823          	sd	a5,112(s2)
  for (int i = 0; i < NBUCKET; i++) {
    80003216:	2985                	addiw	s3,s3,1
    80003218:	48090913          	addi	s2,s2,1152
    8000321c:	94d2                	add	s1,s1,s4
    8000321e:	fd5992e3          	bne	s3,s5,800031e2 <binit+0x7a>
      hashtable[i].head.next = b;
      b++;
    }
  }
}
    80003222:	70e2                	ld	ra,56(sp)
    80003224:	7442                	ld	s0,48(sp)
    80003226:	74a2                	ld	s1,40(sp)
    80003228:	7902                	ld	s2,32(sp)
    8000322a:	69e2                	ld	s3,24(sp)
    8000322c:	6a42                	ld	s4,16(sp)
    8000322e:	6aa2                	ld	s5,8(sp)
    80003230:	6b02                	ld	s6,0(sp)
    80003232:	6121                	addi	sp,sp,64
    80003234:	8082                	ret

0000000080003236 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003236:	7119                	addi	sp,sp,-128
    80003238:	fc86                	sd	ra,120(sp)
    8000323a:	f8a2                	sd	s0,112(sp)
    8000323c:	f4a6                	sd	s1,104(sp)
    8000323e:	f0ca                	sd	s2,96(sp)
    80003240:	ecce                	sd	s3,88(sp)
    80003242:	e8d2                	sd	s4,80(sp)
    80003244:	e4d6                	sd	s5,72(sp)
    80003246:	e0da                	sd	s6,64(sp)
    80003248:	fc5e                	sd	s7,56(sp)
    8000324a:	f862                	sd	s8,48(sp)
    8000324c:	f466                	sd	s9,40(sp)
    8000324e:	f06a                	sd	s10,32(sp)
    80003250:	ec6e                	sd	s11,24(sp)
    80003252:	0100                	addi	s0,sp,128
    80003254:	8c2a                	mv	s8,a0
    80003256:	8aae                	mv	s5,a1
  return blockno % NBUCKET;
    80003258:	4b35                	li	s6,13
    8000325a:	0365fb3b          	remuw	s6,a1,s6
  struct bucket* bucket = hashtable + idx;
    8000325e:	003b1993          	slli	s3,s6,0x3
    80003262:	99da                	add	s3,s3,s6
    80003264:	099e                	slli	s3,s3,0x7
    80003266:	00015797          	auipc	a5,0x15
    8000326a:	1a278793          	addi	a5,a5,418 # 80018408 <hashtable>
    8000326e:	99be                	add	s3,s3,a5
  acquire(&bucket->lock);
    80003270:	854e                	mv	a0,s3
    80003272:	ffffe097          	auipc	ra,0xffffe
    80003276:	afc080e7          	jalr	-1284(ra) # 80000d6e <acquire>
  for(b = bucket->head.next; b != 0; b = b->next){
    8000327a:	0709b783          	ld	a5,112(s3)
    8000327e:	c3dd                	beqz	a5,80003324 <bread+0xee>
    80003280:	84be                	mv	s1,a5
    80003282:	a019                	j	80003288 <bread+0x52>
    80003284:	68a4                	ld	s1,80(s1)
    80003286:	c495                	beqz	s1,800032b2 <bread+0x7c>
    if(b->dev == dev && b->blockno == blockno){
    80003288:	4498                	lw	a4,8(s1)
    8000328a:	ff871de3          	bne	a4,s8,80003284 <bread+0x4e>
    8000328e:	44d8                	lw	a4,12(s1)
    80003290:	ff571ae3          	bne	a4,s5,80003284 <bread+0x4e>
      b->refcnt++;
    80003294:	44bc                	lw	a5,72(s1)
    80003296:	2785                	addiw	a5,a5,1
    80003298:	c4bc                	sw	a5,72(s1)
      release(&bucket->lock);
    8000329a:	854e                	mv	a0,s3
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	ba2080e7          	jalr	-1118(ra) # 80000e3e <release>
      acquiresleep(&b->lock);
    800032a4:	01048513          	addi	a0,s1,16
    800032a8:	00001097          	auipc	ra,0x1
    800032ac:	590080e7          	jalr	1424(ra) # 80004838 <acquiresleep>
      return b;
    800032b0:	a0b9                	j	800032fe <bread+0xc8>
    800032b2:	90000a37          	lui	s4,0x90000
    800032b6:	1a7d                	addi	s4,s4,-1
    800032b8:	a031                	j	800032c4 <bread+0x8e>
      min_time = b->timestamp;
    800032ba:	00070a1b          	sext.w	s4,a4
    800032be:	84be                	mv	s1,a5
  for(b = bucket->head.next; b != 0; b = b->next){
    800032c0:	6bbc                	ld	a5,80(a5)
    800032c2:	cb91                	beqz	a5,800032d6 <bread+0xa0>
    if(b->refcnt == 0 && b->timestamp < min_time) {
    800032c4:	47b8                	lw	a4,72(a5)
    800032c6:	ff6d                	bnez	a4,800032c0 <bread+0x8a>
    800032c8:	4587a703          	lw	a4,1112(a5)
    800032cc:	000a069b          	sext.w	a3,s4
    800032d0:	fed778e3          	bgeu	a4,a3,800032c0 <bread+0x8a>
    800032d4:	b7dd                	j	800032ba <bread+0x84>
  if(replace_buf) {
    800032d6:	c8b1                	beqz	s1,8000332a <bread+0xf4>
  replace_buf->dev = dev;
    800032d8:	0184a423          	sw	s8,8(s1)
  replace_buf->blockno = blockno;
    800032dc:	0154a623          	sw	s5,12(s1)
  replace_buf->valid = 0;
    800032e0:	0004a023          	sw	zero,0(s1)
  replace_buf->refcnt = 1;
    800032e4:	4785                	li	a5,1
    800032e6:	c4bc                	sw	a5,72(s1)
  release(&bucket->lock);
    800032e8:	854e                	mv	a0,s3
    800032ea:	ffffe097          	auipc	ra,0xffffe
    800032ee:	b54080e7          	jalr	-1196(ra) # 80000e3e <release>
  acquiresleep(&replace_buf->lock);
    800032f2:	01048513          	addi	a0,s1,16
    800032f6:	00001097          	auipc	ra,0x1
    800032fa:	542080e7          	jalr	1346(ra) # 80004838 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800032fe:	409c                	lw	a5,0(s1)
    80003300:	12078463          	beqz	a5,80003428 <bread+0x1f2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003304:	8526                	mv	a0,s1
    80003306:	70e6                	ld	ra,120(sp)
    80003308:	7446                	ld	s0,112(sp)
    8000330a:	74a6                	ld	s1,104(sp)
    8000330c:	7906                	ld	s2,96(sp)
    8000330e:	69e6                	ld	s3,88(sp)
    80003310:	6a46                	ld	s4,80(sp)
    80003312:	6aa6                	ld	s5,72(sp)
    80003314:	6b06                	ld	s6,64(sp)
    80003316:	7be2                	ld	s7,56(sp)
    80003318:	7c42                	ld	s8,48(sp)
    8000331a:	7ca2                	ld	s9,40(sp)
    8000331c:	7d02                	ld	s10,32(sp)
    8000331e:	6de2                	ld	s11,24(sp)
    80003320:	6109                	addi	sp,sp,128
    80003322:	8082                	ret
  int min_time = 0x8fffffff;
    80003324:	90000a37          	lui	s4,0x90000
    80003328:	1a7d                	addi	s4,s4,-1
  acquire(&bcache.lock);
    8000332a:	00019517          	auipc	a0,0x19
    8000332e:	b5e50513          	addi	a0,a0,-1186 # 8001be88 <bcache>
    80003332:	ffffe097          	auipc	ra,0xffffe
    80003336:	a3c080e7          	jalr	-1476(ra) # 80000d6e <acquire>
    8000333a:	4481                	li	s1,0
  for(b = bcache.buf; b < bcache.buf + NBUF; b++) {
    8000333c:	00023d97          	auipc	s11,0x23
    80003340:	60cd8d93          	addi	s11,s11,1548 # 80026948 <sb>
  return blockno % NBUCKET;
    80003344:	4d35                	li	s10,13
    acquire(&hashtable[ridx].lock);
    80003346:	00015c97          	auipc	s9,0x15
    8000334a:	0c2c8c93          	addi	s9,s9,194 # 80018408 <hashtable>
    8000334e:	a889                	j	800033a0 <bread+0x16a>
      min_time = b->timestamp;
    80003350:	00070a1b          	sext.w	s4,a4
    80003354:	84be                	mv	s1,a5
  for(b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80003356:	46078793          	addi	a5,a5,1120
    8000335a:	01b78b63          	beq	a5,s11,80003370 <bread+0x13a>
    if(b->refcnt == 0 && b->timestamp < min_time) {
    8000335e:	47b8                	lw	a4,72(a5)
    80003360:	fb7d                	bnez	a4,80003356 <bread+0x120>
    80003362:	4587a703          	lw	a4,1112(a5)
    80003366:	000a069b          	sext.w	a3,s4
    8000336a:	fed776e3          	bgeu	a4,a3,80003356 <bread+0x120>
    8000336e:	b7cd                	j	80003350 <bread+0x11a>
  if (replace_buf) {
    80003370:	c4c5                	beqz	s1,80003418 <bread+0x1e2>
  return blockno % NBUCKET;
    80003372:	00c4ab83          	lw	s7,12(s1)
    80003376:	03abfbbb          	remuw	s7,s7,s10
    acquire(&hashtable[ridx].lock);
    8000337a:	003b9913          	slli	s2,s7,0x3
    8000337e:	995e                	add	s2,s2,s7
    80003380:	091e                	slli	s2,s2,0x7
    80003382:	f9243423          	sd	s2,-120(s0)
    80003386:	9966                	add	s2,s2,s9
    80003388:	854a                	mv	a0,s2
    8000338a:	ffffe097          	auipc	ra,0xffffe
    8000338e:	9e4080e7          	jalr	-1564(ra) # 80000d6e <acquire>
    if(replace_buf->refcnt != 0)  // be used in another bucket's local find between finded and acquire
    80003392:	44bc                	lw	a5,72(s1)
    80003394:	cb99                	beqz	a5,800033aa <bread+0x174>
      release(&hashtable[ridx].lock);
    80003396:	854a                	mv	a0,s2
    80003398:	ffffe097          	auipc	ra,0xffffe
    8000339c:	aa6080e7          	jalr	-1370(ra) # 80000e3e <release>
  for(b = bcache.buf; b < bcache.buf + NBUF; b++) {
    800033a0:	00019797          	auipc	a5,0x19
    800033a4:	b0878793          	addi	a5,a5,-1272 # 8001bea8 <bcache+0x20>
    800033a8:	bf5d                	j	8000335e <bread+0x128>
    struct buf *pre = &hashtable[ridx].head;
    800033aa:	f8843783          	ld	a5,-120(s0)
    800033ae:	02078793          	addi	a5,a5,32
    800033b2:	00015697          	auipc	a3,0x15
    800033b6:	05668693          	addi	a3,a3,86 # 80018408 <hashtable>
    800033ba:	97b6                	add	a5,a5,a3
    struct buf *p = hashtable[ridx].head.next;
    800033bc:	003b9713          	slli	a4,s7,0x3
    800033c0:	9bba                	add	s7,s7,a4
    800033c2:	0b9e                	slli	s7,s7,0x7
    800033c4:	9bb6                	add	s7,s7,a3
    800033c6:	070bb703          	ld	a4,112(s7)
    while (p != replace_buf) {
    800033ca:	00970663          	beq	a4,s1,800033d6 <bread+0x1a0>
      pre = pre->next;
    800033ce:	6bbc                	ld	a5,80(a5)
      p = p->next;
    800033d0:	6b38                	ld	a4,80(a4)
    while (p != replace_buf) {
    800033d2:	fe971ee3          	bne	a4,s1,800033ce <bread+0x198>
    pre->next = p->next;
    800033d6:	68b8                	ld	a4,80(s1)
    800033d8:	ebb8                	sd	a4,80(a5)
    release(&hashtable[ridx].lock);
    800033da:	854a                	mv	a0,s2
    800033dc:	ffffe097          	auipc	ra,0xffffe
    800033e0:	a62080e7          	jalr	-1438(ra) # 80000e3e <release>
    replace_buf->next = hashtable[idx].head.next;
    800033e4:	00015697          	auipc	a3,0x15
    800033e8:	02468693          	addi	a3,a3,36 # 80018408 <hashtable>
    800033ec:	003b1793          	slli	a5,s6,0x3
    800033f0:	01678733          	add	a4,a5,s6
    800033f4:	071e                	slli	a4,a4,0x7
    800033f6:	9736                	add	a4,a4,a3
    800033f8:	7b38                	ld	a4,112(a4)
    800033fa:	e8b8                	sd	a4,80(s1)
    hashtable[idx].head.next = replace_buf;
    800033fc:	9b3e                	add	s6,s6,a5
    800033fe:	0b1e                	slli	s6,s6,0x7
    80003400:	9b36                	add	s6,s6,a3
    80003402:	069b3823          	sd	s1,112(s6)
    release(&bcache.lock);
    80003406:	00019517          	auipc	a0,0x19
    8000340a:	a8250513          	addi	a0,a0,-1406 # 8001be88 <bcache>
    8000340e:	ffffe097          	auipc	ra,0xffffe
    80003412:	a30080e7          	jalr	-1488(ra) # 80000e3e <release>
    goto find;
    80003416:	b5c9                	j	800032d8 <bread+0xa2>
    panic("bget: no buffers");
    80003418:	00005517          	auipc	a0,0x5
    8000341c:	17050513          	addi	a0,a0,368 # 80008588 <syscalls+0xc8>
    80003420:	ffffd097          	auipc	ra,0xffffd
    80003424:	130080e7          	jalr	304(ra) # 80000550 <panic>
    virtio_disk_rw(b, 0);
    80003428:	4581                	li	a1,0
    8000342a:	8526                	mv	a0,s1
    8000342c:	00003097          	auipc	ra,0x3
    80003430:	f8a080e7          	jalr	-118(ra) # 800063b6 <virtio_disk_rw>
    b->valid = 1;
    80003434:	4785                	li	a5,1
    80003436:	c09c                	sw	a5,0(s1)
  return b;
    80003438:	b5f1                	j	80003304 <bread+0xce>

000000008000343a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000343a:	1101                	addi	sp,sp,-32
    8000343c:	ec06                	sd	ra,24(sp)
    8000343e:	e822                	sd	s0,16(sp)
    80003440:	e426                	sd	s1,8(sp)
    80003442:	1000                	addi	s0,sp,32
    80003444:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003446:	0541                	addi	a0,a0,16
    80003448:	00001097          	auipc	ra,0x1
    8000344c:	48a080e7          	jalr	1162(ra) # 800048d2 <holdingsleep>
    80003450:	cd01                	beqz	a0,80003468 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003452:	4585                	li	a1,1
    80003454:	8526                	mv	a0,s1
    80003456:	00003097          	auipc	ra,0x3
    8000345a:	f60080e7          	jalr	-160(ra) # 800063b6 <virtio_disk_rw>
}
    8000345e:	60e2                	ld	ra,24(sp)
    80003460:	6442                	ld	s0,16(sp)
    80003462:	64a2                	ld	s1,8(sp)
    80003464:	6105                	addi	sp,sp,32
    80003466:	8082                	ret
    panic("bwrite");
    80003468:	00005517          	auipc	a0,0x5
    8000346c:	13850513          	addi	a0,a0,312 # 800085a0 <syscalls+0xe0>
    80003470:	ffffd097          	auipc	ra,0xffffd
    80003474:	0e0080e7          	jalr	224(ra) # 80000550 <panic>

0000000080003478 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003478:	1101                	addi	sp,sp,-32
    8000347a:	ec06                	sd	ra,24(sp)
    8000347c:	e822                	sd	s0,16(sp)
    8000347e:	e426                	sd	s1,8(sp)
    80003480:	e04a                	sd	s2,0(sp)
    80003482:	1000                	addi	s0,sp,32
    80003484:	892a                	mv	s2,a0
  if(!holdingsleep(&b->lock))
    80003486:	01050493          	addi	s1,a0,16
    8000348a:	8526                	mv	a0,s1
    8000348c:	00001097          	auipc	ra,0x1
    80003490:	446080e7          	jalr	1094(ra) # 800048d2 <holdingsleep>
    80003494:	c135                	beqz	a0,800034f8 <brelse+0x80>
    panic("brelse");

  releasesleep(&b->lock);
    80003496:	8526                	mv	a0,s1
    80003498:	00001097          	auipc	ra,0x1
    8000349c:	3f6080e7          	jalr	1014(ra) # 8000488e <releasesleep>
  return blockno % NBUCKET;
    800034a0:	00c92483          	lw	s1,12(s2)

  int idx = hash(b->dev, b->blockno);

  acquire(&hashtable[idx].lock);
    800034a4:	47b5                	li	a5,13
    800034a6:	02f4f7bb          	remuw	a5,s1,a5
    800034aa:	00379493          	slli	s1,a5,0x3
    800034ae:	94be                	add	s1,s1,a5
    800034b0:	049e                	slli	s1,s1,0x7
    800034b2:	00015797          	auipc	a5,0x15
    800034b6:	f5678793          	addi	a5,a5,-170 # 80018408 <hashtable>
    800034ba:	94be                	add	s1,s1,a5
    800034bc:	8526                	mv	a0,s1
    800034be:	ffffe097          	auipc	ra,0xffffe
    800034c2:	8b0080e7          	jalr	-1872(ra) # 80000d6e <acquire>
  b->refcnt--;
    800034c6:	04892783          	lw	a5,72(s2)
    800034ca:	37fd                	addiw	a5,a5,-1
    800034cc:	0007871b          	sext.w	a4,a5
    800034d0:	04f92423          	sw	a5,72(s2)
  if (b->refcnt == 0) {
    800034d4:	e719                	bnez	a4,800034e2 <brelse+0x6a>
    // no one is waiting for it.
    b->timestamp = ticks;
    800034d6:	00006797          	auipc	a5,0x6
    800034da:	b4a7a783          	lw	a5,-1206(a5) # 80009020 <ticks>
    800034de:	44f92c23          	sw	a5,1112(s2)
  }
  
  release(&hashtable[idx].lock);
    800034e2:	8526                	mv	a0,s1
    800034e4:	ffffe097          	auipc	ra,0xffffe
    800034e8:	95a080e7          	jalr	-1702(ra) # 80000e3e <release>
}
    800034ec:	60e2                	ld	ra,24(sp)
    800034ee:	6442                	ld	s0,16(sp)
    800034f0:	64a2                	ld	s1,8(sp)
    800034f2:	6902                	ld	s2,0(sp)
    800034f4:	6105                	addi	sp,sp,32
    800034f6:	8082                	ret
    panic("brelse");
    800034f8:	00005517          	auipc	a0,0x5
    800034fc:	0b050513          	addi	a0,a0,176 # 800085a8 <syscalls+0xe8>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	050080e7          	jalr	80(ra) # 80000550 <panic>

0000000080003508 <bpin>:

void
bpin(struct buf *b) {
    80003508:	1101                	addi	sp,sp,-32
    8000350a:	ec06                	sd	ra,24(sp)
    8000350c:	e822                	sd	s0,16(sp)
    8000350e:	e426                	sd	s1,8(sp)
    80003510:	e04a                	sd	s2,0(sp)
    80003512:	1000                	addi	s0,sp,32
    80003514:	892a                	mv	s2,a0
  return blockno % NBUCKET;
    80003516:	4544                	lw	s1,12(a0)
  int idx = hash(b->dev, b->blockno);
  acquire(&hashtable[idx].lock);
    80003518:	47b5                	li	a5,13
    8000351a:	02f4f7bb          	remuw	a5,s1,a5
    8000351e:	00379493          	slli	s1,a5,0x3
    80003522:	94be                	add	s1,s1,a5
    80003524:	049e                	slli	s1,s1,0x7
    80003526:	00015797          	auipc	a5,0x15
    8000352a:	ee278793          	addi	a5,a5,-286 # 80018408 <hashtable>
    8000352e:	94be                	add	s1,s1,a5
    80003530:	8526                	mv	a0,s1
    80003532:	ffffe097          	auipc	ra,0xffffe
    80003536:	83c080e7          	jalr	-1988(ra) # 80000d6e <acquire>
  b->refcnt++;
    8000353a:	04892783          	lw	a5,72(s2)
    8000353e:	2785                	addiw	a5,a5,1
    80003540:	04f92423          	sw	a5,72(s2)
  release(&hashtable[idx].lock);
    80003544:	8526                	mv	a0,s1
    80003546:	ffffe097          	auipc	ra,0xffffe
    8000354a:	8f8080e7          	jalr	-1800(ra) # 80000e3e <release>
}
    8000354e:	60e2                	ld	ra,24(sp)
    80003550:	6442                	ld	s0,16(sp)
    80003552:	64a2                	ld	s1,8(sp)
    80003554:	6902                	ld	s2,0(sp)
    80003556:	6105                	addi	sp,sp,32
    80003558:	8082                	ret

000000008000355a <bunpin>:

void
bunpin(struct buf *b) {
    8000355a:	1101                	addi	sp,sp,-32
    8000355c:	ec06                	sd	ra,24(sp)
    8000355e:	e822                	sd	s0,16(sp)
    80003560:	e426                	sd	s1,8(sp)
    80003562:	e04a                	sd	s2,0(sp)
    80003564:	1000                	addi	s0,sp,32
    80003566:	892a                	mv	s2,a0
  return blockno % NBUCKET;
    80003568:	4544                	lw	s1,12(a0)
  int idx = hash(b->dev, b->blockno);
  acquire(&hashtable[idx].lock);
    8000356a:	47b5                	li	a5,13
    8000356c:	02f4f7bb          	remuw	a5,s1,a5
    80003570:	00379493          	slli	s1,a5,0x3
    80003574:	94be                	add	s1,s1,a5
    80003576:	049e                	slli	s1,s1,0x7
    80003578:	00015797          	auipc	a5,0x15
    8000357c:	e9078793          	addi	a5,a5,-368 # 80018408 <hashtable>
    80003580:	94be                	add	s1,s1,a5
    80003582:	8526                	mv	a0,s1
    80003584:	ffffd097          	auipc	ra,0xffffd
    80003588:	7ea080e7          	jalr	2026(ra) # 80000d6e <acquire>
  b->refcnt--;
    8000358c:	04892783          	lw	a5,72(s2)
    80003590:	37fd                	addiw	a5,a5,-1
    80003592:	04f92423          	sw	a5,72(s2)
  release(&hashtable[idx].lock);
    80003596:	8526                	mv	a0,s1
    80003598:	ffffe097          	auipc	ra,0xffffe
    8000359c:	8a6080e7          	jalr	-1882(ra) # 80000e3e <release>
}
    800035a0:	60e2                	ld	ra,24(sp)
    800035a2:	6442                	ld	s0,16(sp)
    800035a4:	64a2                	ld	s1,8(sp)
    800035a6:	6902                	ld	s2,0(sp)
    800035a8:	6105                	addi	sp,sp,32
    800035aa:	8082                	ret

00000000800035ac <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800035ac:	1101                	addi	sp,sp,-32
    800035ae:	ec06                	sd	ra,24(sp)
    800035b0:	e822                	sd	s0,16(sp)
    800035b2:	e426                	sd	s1,8(sp)
    800035b4:	e04a                	sd	s2,0(sp)
    800035b6:	1000                	addi	s0,sp,32
    800035b8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800035ba:	00d5d59b          	srliw	a1,a1,0xd
    800035be:	00023797          	auipc	a5,0x23
    800035c2:	3a67a783          	lw	a5,934(a5) # 80026964 <sb+0x1c>
    800035c6:	9dbd                	addw	a1,a1,a5
    800035c8:	00000097          	auipc	ra,0x0
    800035cc:	c6e080e7          	jalr	-914(ra) # 80003236 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035d0:	0074f713          	andi	a4,s1,7
    800035d4:	4785                	li	a5,1
    800035d6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035da:	14ce                	slli	s1,s1,0x33
    800035dc:	90d9                	srli	s1,s1,0x36
    800035de:	00950733          	add	a4,a0,s1
    800035e2:	05874703          	lbu	a4,88(a4)
    800035e6:	00e7f6b3          	and	a3,a5,a4
    800035ea:	c69d                	beqz	a3,80003618 <bfree+0x6c>
    800035ec:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035ee:	94aa                	add	s1,s1,a0
    800035f0:	fff7c793          	not	a5,a5
    800035f4:	8ff9                	and	a5,a5,a4
    800035f6:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800035fa:	00001097          	auipc	ra,0x1
    800035fe:	116080e7          	jalr	278(ra) # 80004710 <log_write>
  brelse(bp);
    80003602:	854a                	mv	a0,s2
    80003604:	00000097          	auipc	ra,0x0
    80003608:	e74080e7          	jalr	-396(ra) # 80003478 <brelse>
}
    8000360c:	60e2                	ld	ra,24(sp)
    8000360e:	6442                	ld	s0,16(sp)
    80003610:	64a2                	ld	s1,8(sp)
    80003612:	6902                	ld	s2,0(sp)
    80003614:	6105                	addi	sp,sp,32
    80003616:	8082                	ret
    panic("freeing free block");
    80003618:	00005517          	auipc	a0,0x5
    8000361c:	f9850513          	addi	a0,a0,-104 # 800085b0 <syscalls+0xf0>
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	f30080e7          	jalr	-208(ra) # 80000550 <panic>

0000000080003628 <balloc>:
{
    80003628:	711d                	addi	sp,sp,-96
    8000362a:	ec86                	sd	ra,88(sp)
    8000362c:	e8a2                	sd	s0,80(sp)
    8000362e:	e4a6                	sd	s1,72(sp)
    80003630:	e0ca                	sd	s2,64(sp)
    80003632:	fc4e                	sd	s3,56(sp)
    80003634:	f852                	sd	s4,48(sp)
    80003636:	f456                	sd	s5,40(sp)
    80003638:	f05a                	sd	s6,32(sp)
    8000363a:	ec5e                	sd	s7,24(sp)
    8000363c:	e862                	sd	s8,16(sp)
    8000363e:	e466                	sd	s9,8(sp)
    80003640:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003642:	00023797          	auipc	a5,0x23
    80003646:	30a7a783          	lw	a5,778(a5) # 8002694c <sb+0x4>
    8000364a:	cbd1                	beqz	a5,800036de <balloc+0xb6>
    8000364c:	8baa                	mv	s7,a0
    8000364e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003650:	00023b17          	auipc	s6,0x23
    80003654:	2f8b0b13          	addi	s6,s6,760 # 80026948 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003658:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000365a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000365c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000365e:	6c89                	lui	s9,0x2
    80003660:	a831                	j	8000367c <balloc+0x54>
    brelse(bp);
    80003662:	854a                	mv	a0,s2
    80003664:	00000097          	auipc	ra,0x0
    80003668:	e14080e7          	jalr	-492(ra) # 80003478 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000366c:	015c87bb          	addw	a5,s9,s5
    80003670:	00078a9b          	sext.w	s5,a5
    80003674:	004b2703          	lw	a4,4(s6)
    80003678:	06eaf363          	bgeu	s5,a4,800036de <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000367c:	41fad79b          	sraiw	a5,s5,0x1f
    80003680:	0137d79b          	srliw	a5,a5,0x13
    80003684:	015787bb          	addw	a5,a5,s5
    80003688:	40d7d79b          	sraiw	a5,a5,0xd
    8000368c:	01cb2583          	lw	a1,28(s6)
    80003690:	9dbd                	addw	a1,a1,a5
    80003692:	855e                	mv	a0,s7
    80003694:	00000097          	auipc	ra,0x0
    80003698:	ba2080e7          	jalr	-1118(ra) # 80003236 <bread>
    8000369c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000369e:	004b2503          	lw	a0,4(s6)
    800036a2:	000a849b          	sext.w	s1,s5
    800036a6:	8662                	mv	a2,s8
    800036a8:	faa4fde3          	bgeu	s1,a0,80003662 <balloc+0x3a>
      m = 1 << (bi % 8);
    800036ac:	41f6579b          	sraiw	a5,a2,0x1f
    800036b0:	01d7d69b          	srliw	a3,a5,0x1d
    800036b4:	00c6873b          	addw	a4,a3,a2
    800036b8:	00777793          	andi	a5,a4,7
    800036bc:	9f95                	subw	a5,a5,a3
    800036be:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800036c2:	4037571b          	sraiw	a4,a4,0x3
    800036c6:	00e906b3          	add	a3,s2,a4
    800036ca:	0586c683          	lbu	a3,88(a3)
    800036ce:	00d7f5b3          	and	a1,a5,a3
    800036d2:	cd91                	beqz	a1,800036ee <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036d4:	2605                	addiw	a2,a2,1
    800036d6:	2485                	addiw	s1,s1,1
    800036d8:	fd4618e3          	bne	a2,s4,800036a8 <balloc+0x80>
    800036dc:	b759                	j	80003662 <balloc+0x3a>
  panic("balloc: out of blocks");
    800036de:	00005517          	auipc	a0,0x5
    800036e2:	eea50513          	addi	a0,a0,-278 # 800085c8 <syscalls+0x108>
    800036e6:	ffffd097          	auipc	ra,0xffffd
    800036ea:	e6a080e7          	jalr	-406(ra) # 80000550 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036ee:	974a                	add	a4,a4,s2
    800036f0:	8fd5                	or	a5,a5,a3
    800036f2:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800036f6:	854a                	mv	a0,s2
    800036f8:	00001097          	auipc	ra,0x1
    800036fc:	018080e7          	jalr	24(ra) # 80004710 <log_write>
        brelse(bp);
    80003700:	854a                	mv	a0,s2
    80003702:	00000097          	auipc	ra,0x0
    80003706:	d76080e7          	jalr	-650(ra) # 80003478 <brelse>
  bp = bread(dev, bno);
    8000370a:	85a6                	mv	a1,s1
    8000370c:	855e                	mv	a0,s7
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	b28080e7          	jalr	-1240(ra) # 80003236 <bread>
    80003716:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003718:	40000613          	li	a2,1024
    8000371c:	4581                	li	a1,0
    8000371e:	05850513          	addi	a0,a0,88
    80003722:	ffffe097          	auipc	ra,0xffffe
    80003726:	a2c080e7          	jalr	-1492(ra) # 8000114e <memset>
  log_write(bp);
    8000372a:	854a                	mv	a0,s2
    8000372c:	00001097          	auipc	ra,0x1
    80003730:	fe4080e7          	jalr	-28(ra) # 80004710 <log_write>
  brelse(bp);
    80003734:	854a                	mv	a0,s2
    80003736:	00000097          	auipc	ra,0x0
    8000373a:	d42080e7          	jalr	-702(ra) # 80003478 <brelse>
}
    8000373e:	8526                	mv	a0,s1
    80003740:	60e6                	ld	ra,88(sp)
    80003742:	6446                	ld	s0,80(sp)
    80003744:	64a6                	ld	s1,72(sp)
    80003746:	6906                	ld	s2,64(sp)
    80003748:	79e2                	ld	s3,56(sp)
    8000374a:	7a42                	ld	s4,48(sp)
    8000374c:	7aa2                	ld	s5,40(sp)
    8000374e:	7b02                	ld	s6,32(sp)
    80003750:	6be2                	ld	s7,24(sp)
    80003752:	6c42                	ld	s8,16(sp)
    80003754:	6ca2                	ld	s9,8(sp)
    80003756:	6125                	addi	sp,sp,96
    80003758:	8082                	ret

000000008000375a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000375a:	7179                	addi	sp,sp,-48
    8000375c:	f406                	sd	ra,40(sp)
    8000375e:	f022                	sd	s0,32(sp)
    80003760:	ec26                	sd	s1,24(sp)
    80003762:	e84a                	sd	s2,16(sp)
    80003764:	e44e                	sd	s3,8(sp)
    80003766:	e052                	sd	s4,0(sp)
    80003768:	1800                	addi	s0,sp,48
    8000376a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000376c:	47ad                	li	a5,11
    8000376e:	04b7fe63          	bgeu	a5,a1,800037ca <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003772:	ff45849b          	addiw	s1,a1,-12
    80003776:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000377a:	0ff00793          	li	a5,255
    8000377e:	0ae7e363          	bltu	a5,a4,80003824 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003782:	08852583          	lw	a1,136(a0)
    80003786:	c5ad                	beqz	a1,800037f0 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003788:	00092503          	lw	a0,0(s2)
    8000378c:	00000097          	auipc	ra,0x0
    80003790:	aaa080e7          	jalr	-1366(ra) # 80003236 <bread>
    80003794:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003796:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000379a:	02049593          	slli	a1,s1,0x20
    8000379e:	9181                	srli	a1,a1,0x20
    800037a0:	058a                	slli	a1,a1,0x2
    800037a2:	00b784b3          	add	s1,a5,a1
    800037a6:	0004a983          	lw	s3,0(s1)
    800037aa:	04098d63          	beqz	s3,80003804 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800037ae:	8552                	mv	a0,s4
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	cc8080e7          	jalr	-824(ra) # 80003478 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800037b8:	854e                	mv	a0,s3
    800037ba:	70a2                	ld	ra,40(sp)
    800037bc:	7402                	ld	s0,32(sp)
    800037be:	64e2                	ld	s1,24(sp)
    800037c0:	6942                	ld	s2,16(sp)
    800037c2:	69a2                	ld	s3,8(sp)
    800037c4:	6a02                	ld	s4,0(sp)
    800037c6:	6145                	addi	sp,sp,48
    800037c8:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800037ca:	02059493          	slli	s1,a1,0x20
    800037ce:	9081                	srli	s1,s1,0x20
    800037d0:	048a                	slli	s1,s1,0x2
    800037d2:	94aa                	add	s1,s1,a0
    800037d4:	0584a983          	lw	s3,88(s1)
    800037d8:	fe0990e3          	bnez	s3,800037b8 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800037dc:	4108                	lw	a0,0(a0)
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	e4a080e7          	jalr	-438(ra) # 80003628 <balloc>
    800037e6:	0005099b          	sext.w	s3,a0
    800037ea:	0534ac23          	sw	s3,88(s1)
    800037ee:	b7e9                	j	800037b8 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800037f0:	4108                	lw	a0,0(a0)
    800037f2:	00000097          	auipc	ra,0x0
    800037f6:	e36080e7          	jalr	-458(ra) # 80003628 <balloc>
    800037fa:	0005059b          	sext.w	a1,a0
    800037fe:	08b92423          	sw	a1,136(s2)
    80003802:	b759                	j	80003788 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003804:	00092503          	lw	a0,0(s2)
    80003808:	00000097          	auipc	ra,0x0
    8000380c:	e20080e7          	jalr	-480(ra) # 80003628 <balloc>
    80003810:	0005099b          	sext.w	s3,a0
    80003814:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003818:	8552                	mv	a0,s4
    8000381a:	00001097          	auipc	ra,0x1
    8000381e:	ef6080e7          	jalr	-266(ra) # 80004710 <log_write>
    80003822:	b771                	j	800037ae <bmap+0x54>
  panic("bmap: out of range");
    80003824:	00005517          	auipc	a0,0x5
    80003828:	dbc50513          	addi	a0,a0,-580 # 800085e0 <syscalls+0x120>
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	d24080e7          	jalr	-732(ra) # 80000550 <panic>

0000000080003834 <iget>:
{
    80003834:	7179                	addi	sp,sp,-48
    80003836:	f406                	sd	ra,40(sp)
    80003838:	f022                	sd	s0,32(sp)
    8000383a:	ec26                	sd	s1,24(sp)
    8000383c:	e84a                	sd	s2,16(sp)
    8000383e:	e44e                	sd	s3,8(sp)
    80003840:	e052                	sd	s4,0(sp)
    80003842:	1800                	addi	s0,sp,48
    80003844:	89aa                	mv	s3,a0
    80003846:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003848:	00023517          	auipc	a0,0x23
    8000384c:	12050513          	addi	a0,a0,288 # 80026968 <icache>
    80003850:	ffffd097          	auipc	ra,0xffffd
    80003854:	51e080e7          	jalr	1310(ra) # 80000d6e <acquire>
  empty = 0;
    80003858:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000385a:	00023497          	auipc	s1,0x23
    8000385e:	12e48493          	addi	s1,s1,302 # 80026988 <icache+0x20>
    80003862:	00025697          	auipc	a3,0x25
    80003866:	d4668693          	addi	a3,a3,-698 # 800285a8 <log>
    8000386a:	a039                	j	80003878 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000386c:	02090b63          	beqz	s2,800038a2 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003870:	09048493          	addi	s1,s1,144
    80003874:	02d48a63          	beq	s1,a3,800038a8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003878:	449c                	lw	a5,8(s1)
    8000387a:	fef059e3          	blez	a5,8000386c <iget+0x38>
    8000387e:	4098                	lw	a4,0(s1)
    80003880:	ff3716e3          	bne	a4,s3,8000386c <iget+0x38>
    80003884:	40d8                	lw	a4,4(s1)
    80003886:	ff4713e3          	bne	a4,s4,8000386c <iget+0x38>
      ip->ref++;
    8000388a:	2785                	addiw	a5,a5,1
    8000388c:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000388e:	00023517          	auipc	a0,0x23
    80003892:	0da50513          	addi	a0,a0,218 # 80026968 <icache>
    80003896:	ffffd097          	auipc	ra,0xffffd
    8000389a:	5a8080e7          	jalr	1448(ra) # 80000e3e <release>
      return ip;
    8000389e:	8926                	mv	s2,s1
    800038a0:	a03d                	j	800038ce <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038a2:	f7f9                	bnez	a5,80003870 <iget+0x3c>
    800038a4:	8926                	mv	s2,s1
    800038a6:	b7e9                	j	80003870 <iget+0x3c>
  if(empty == 0)
    800038a8:	02090c63          	beqz	s2,800038e0 <iget+0xac>
  ip->dev = dev;
    800038ac:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038b0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038b4:	4785                	li	a5,1
    800038b6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038ba:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    800038be:	00023517          	auipc	a0,0x23
    800038c2:	0aa50513          	addi	a0,a0,170 # 80026968 <icache>
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	578080e7          	jalr	1400(ra) # 80000e3e <release>
}
    800038ce:	854a                	mv	a0,s2
    800038d0:	70a2                	ld	ra,40(sp)
    800038d2:	7402                	ld	s0,32(sp)
    800038d4:	64e2                	ld	s1,24(sp)
    800038d6:	6942                	ld	s2,16(sp)
    800038d8:	69a2                	ld	s3,8(sp)
    800038da:	6a02                	ld	s4,0(sp)
    800038dc:	6145                	addi	sp,sp,48
    800038de:	8082                	ret
    panic("iget: no inodes");
    800038e0:	00005517          	auipc	a0,0x5
    800038e4:	d1850513          	addi	a0,a0,-744 # 800085f8 <syscalls+0x138>
    800038e8:	ffffd097          	auipc	ra,0xffffd
    800038ec:	c68080e7          	jalr	-920(ra) # 80000550 <panic>

00000000800038f0 <fsinit>:
fsinit(int dev) {
    800038f0:	7179                	addi	sp,sp,-48
    800038f2:	f406                	sd	ra,40(sp)
    800038f4:	f022                	sd	s0,32(sp)
    800038f6:	ec26                	sd	s1,24(sp)
    800038f8:	e84a                	sd	s2,16(sp)
    800038fa:	e44e                	sd	s3,8(sp)
    800038fc:	1800                	addi	s0,sp,48
    800038fe:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003900:	4585                	li	a1,1
    80003902:	00000097          	auipc	ra,0x0
    80003906:	934080e7          	jalr	-1740(ra) # 80003236 <bread>
    8000390a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000390c:	00023997          	auipc	s3,0x23
    80003910:	03c98993          	addi	s3,s3,60 # 80026948 <sb>
    80003914:	02000613          	li	a2,32
    80003918:	05850593          	addi	a1,a0,88
    8000391c:	854e                	mv	a0,s3
    8000391e:	ffffe097          	auipc	ra,0xffffe
    80003922:	890080e7          	jalr	-1904(ra) # 800011ae <memmove>
  brelse(bp);
    80003926:	8526                	mv	a0,s1
    80003928:	00000097          	auipc	ra,0x0
    8000392c:	b50080e7          	jalr	-1200(ra) # 80003478 <brelse>
  if(sb.magic != FSMAGIC)
    80003930:	0009a703          	lw	a4,0(s3)
    80003934:	102037b7          	lui	a5,0x10203
    80003938:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000393c:	02f71263          	bne	a4,a5,80003960 <fsinit+0x70>
  initlog(dev, &sb);
    80003940:	00023597          	auipc	a1,0x23
    80003944:	00858593          	addi	a1,a1,8 # 80026948 <sb>
    80003948:	854a                	mv	a0,s2
    8000394a:	00001097          	auipc	ra,0x1
    8000394e:	b4a080e7          	jalr	-1206(ra) # 80004494 <initlog>
}
    80003952:	70a2                	ld	ra,40(sp)
    80003954:	7402                	ld	s0,32(sp)
    80003956:	64e2                	ld	s1,24(sp)
    80003958:	6942                	ld	s2,16(sp)
    8000395a:	69a2                	ld	s3,8(sp)
    8000395c:	6145                	addi	sp,sp,48
    8000395e:	8082                	ret
    panic("invalid file system");
    80003960:	00005517          	auipc	a0,0x5
    80003964:	ca850513          	addi	a0,a0,-856 # 80008608 <syscalls+0x148>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	be8080e7          	jalr	-1048(ra) # 80000550 <panic>

0000000080003970 <iinit>:
{
    80003970:	7179                	addi	sp,sp,-48
    80003972:	f406                	sd	ra,40(sp)
    80003974:	f022                	sd	s0,32(sp)
    80003976:	ec26                	sd	s1,24(sp)
    80003978:	e84a                	sd	s2,16(sp)
    8000397a:	e44e                	sd	s3,8(sp)
    8000397c:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000397e:	00005597          	auipc	a1,0x5
    80003982:	ca258593          	addi	a1,a1,-862 # 80008620 <syscalls+0x160>
    80003986:	00023517          	auipc	a0,0x23
    8000398a:	fe250513          	addi	a0,a0,-30 # 80026968 <icache>
    8000398e:	ffffd097          	auipc	ra,0xffffd
    80003992:	55c080e7          	jalr	1372(ra) # 80000eea <initlock>
  for(i = 0; i < NINODE; i++) {
    80003996:	00023497          	auipc	s1,0x23
    8000399a:	00248493          	addi	s1,s1,2 # 80026998 <icache+0x30>
    8000399e:	00025997          	auipc	s3,0x25
    800039a2:	c1a98993          	addi	s3,s3,-998 # 800285b8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800039a6:	00005917          	auipc	s2,0x5
    800039aa:	c8290913          	addi	s2,s2,-894 # 80008628 <syscalls+0x168>
    800039ae:	85ca                	mv	a1,s2
    800039b0:	8526                	mv	a0,s1
    800039b2:	00001097          	auipc	ra,0x1
    800039b6:	e4c080e7          	jalr	-436(ra) # 800047fe <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039ba:	09048493          	addi	s1,s1,144
    800039be:	ff3498e3          	bne	s1,s3,800039ae <iinit+0x3e>
}
    800039c2:	70a2                	ld	ra,40(sp)
    800039c4:	7402                	ld	s0,32(sp)
    800039c6:	64e2                	ld	s1,24(sp)
    800039c8:	6942                	ld	s2,16(sp)
    800039ca:	69a2                	ld	s3,8(sp)
    800039cc:	6145                	addi	sp,sp,48
    800039ce:	8082                	ret

00000000800039d0 <ialloc>:
{
    800039d0:	715d                	addi	sp,sp,-80
    800039d2:	e486                	sd	ra,72(sp)
    800039d4:	e0a2                	sd	s0,64(sp)
    800039d6:	fc26                	sd	s1,56(sp)
    800039d8:	f84a                	sd	s2,48(sp)
    800039da:	f44e                	sd	s3,40(sp)
    800039dc:	f052                	sd	s4,32(sp)
    800039de:	ec56                	sd	s5,24(sp)
    800039e0:	e85a                	sd	s6,16(sp)
    800039e2:	e45e                	sd	s7,8(sp)
    800039e4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800039e6:	00023717          	auipc	a4,0x23
    800039ea:	f6e72703          	lw	a4,-146(a4) # 80026954 <sb+0xc>
    800039ee:	4785                	li	a5,1
    800039f0:	04e7fa63          	bgeu	a5,a4,80003a44 <ialloc+0x74>
    800039f4:	8aaa                	mv	s5,a0
    800039f6:	8bae                	mv	s7,a1
    800039f8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039fa:	00023a17          	auipc	s4,0x23
    800039fe:	f4ea0a13          	addi	s4,s4,-178 # 80026948 <sb>
    80003a02:	00048b1b          	sext.w	s6,s1
    80003a06:	0044d593          	srli	a1,s1,0x4
    80003a0a:	018a2783          	lw	a5,24(s4)
    80003a0e:	9dbd                	addw	a1,a1,a5
    80003a10:	8556                	mv	a0,s5
    80003a12:	00000097          	auipc	ra,0x0
    80003a16:	824080e7          	jalr	-2012(ra) # 80003236 <bread>
    80003a1a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a1c:	05850993          	addi	s3,a0,88
    80003a20:	00f4f793          	andi	a5,s1,15
    80003a24:	079a                	slli	a5,a5,0x6
    80003a26:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a28:	00099783          	lh	a5,0(s3)
    80003a2c:	c785                	beqz	a5,80003a54 <ialloc+0x84>
    brelse(bp);
    80003a2e:	00000097          	auipc	ra,0x0
    80003a32:	a4a080e7          	jalr	-1462(ra) # 80003478 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a36:	0485                	addi	s1,s1,1
    80003a38:	00ca2703          	lw	a4,12(s4)
    80003a3c:	0004879b          	sext.w	a5,s1
    80003a40:	fce7e1e3          	bltu	a5,a4,80003a02 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003a44:	00005517          	auipc	a0,0x5
    80003a48:	bec50513          	addi	a0,a0,-1044 # 80008630 <syscalls+0x170>
    80003a4c:	ffffd097          	auipc	ra,0xffffd
    80003a50:	b04080e7          	jalr	-1276(ra) # 80000550 <panic>
      memset(dip, 0, sizeof(*dip));
    80003a54:	04000613          	li	a2,64
    80003a58:	4581                	li	a1,0
    80003a5a:	854e                	mv	a0,s3
    80003a5c:	ffffd097          	auipc	ra,0xffffd
    80003a60:	6f2080e7          	jalr	1778(ra) # 8000114e <memset>
      dip->type = type;
    80003a64:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a68:	854a                	mv	a0,s2
    80003a6a:	00001097          	auipc	ra,0x1
    80003a6e:	ca6080e7          	jalr	-858(ra) # 80004710 <log_write>
      brelse(bp);
    80003a72:	854a                	mv	a0,s2
    80003a74:	00000097          	auipc	ra,0x0
    80003a78:	a04080e7          	jalr	-1532(ra) # 80003478 <brelse>
      return iget(dev, inum);
    80003a7c:	85da                	mv	a1,s6
    80003a7e:	8556                	mv	a0,s5
    80003a80:	00000097          	auipc	ra,0x0
    80003a84:	db4080e7          	jalr	-588(ra) # 80003834 <iget>
}
    80003a88:	60a6                	ld	ra,72(sp)
    80003a8a:	6406                	ld	s0,64(sp)
    80003a8c:	74e2                	ld	s1,56(sp)
    80003a8e:	7942                	ld	s2,48(sp)
    80003a90:	79a2                	ld	s3,40(sp)
    80003a92:	7a02                	ld	s4,32(sp)
    80003a94:	6ae2                	ld	s5,24(sp)
    80003a96:	6b42                	ld	s6,16(sp)
    80003a98:	6ba2                	ld	s7,8(sp)
    80003a9a:	6161                	addi	sp,sp,80
    80003a9c:	8082                	ret

0000000080003a9e <iupdate>:
{
    80003a9e:	1101                	addi	sp,sp,-32
    80003aa0:	ec06                	sd	ra,24(sp)
    80003aa2:	e822                	sd	s0,16(sp)
    80003aa4:	e426                	sd	s1,8(sp)
    80003aa6:	e04a                	sd	s2,0(sp)
    80003aa8:	1000                	addi	s0,sp,32
    80003aaa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003aac:	415c                	lw	a5,4(a0)
    80003aae:	0047d79b          	srliw	a5,a5,0x4
    80003ab2:	00023597          	auipc	a1,0x23
    80003ab6:	eae5a583          	lw	a1,-338(a1) # 80026960 <sb+0x18>
    80003aba:	9dbd                	addw	a1,a1,a5
    80003abc:	4108                	lw	a0,0(a0)
    80003abe:	fffff097          	auipc	ra,0xfffff
    80003ac2:	778080e7          	jalr	1912(ra) # 80003236 <bread>
    80003ac6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ac8:	05850793          	addi	a5,a0,88
    80003acc:	40c8                	lw	a0,4(s1)
    80003ace:	893d                	andi	a0,a0,15
    80003ad0:	051a                	slli	a0,a0,0x6
    80003ad2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ad4:	04c49703          	lh	a4,76(s1)
    80003ad8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003adc:	04e49703          	lh	a4,78(s1)
    80003ae0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ae4:	05049703          	lh	a4,80(s1)
    80003ae8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003aec:	05249703          	lh	a4,82(s1)
    80003af0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003af4:	48f8                	lw	a4,84(s1)
    80003af6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003af8:	03400613          	li	a2,52
    80003afc:	05848593          	addi	a1,s1,88
    80003b00:	0531                	addi	a0,a0,12
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	6ac080e7          	jalr	1708(ra) # 800011ae <memmove>
  log_write(bp);
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	00001097          	auipc	ra,0x1
    80003b10:	c04080e7          	jalr	-1020(ra) # 80004710 <log_write>
  brelse(bp);
    80003b14:	854a                	mv	a0,s2
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	962080e7          	jalr	-1694(ra) # 80003478 <brelse>
}
    80003b1e:	60e2                	ld	ra,24(sp)
    80003b20:	6442                	ld	s0,16(sp)
    80003b22:	64a2                	ld	s1,8(sp)
    80003b24:	6902                	ld	s2,0(sp)
    80003b26:	6105                	addi	sp,sp,32
    80003b28:	8082                	ret

0000000080003b2a <idup>:
{
    80003b2a:	1101                	addi	sp,sp,-32
    80003b2c:	ec06                	sd	ra,24(sp)
    80003b2e:	e822                	sd	s0,16(sp)
    80003b30:	e426                	sd	s1,8(sp)
    80003b32:	1000                	addi	s0,sp,32
    80003b34:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b36:	00023517          	auipc	a0,0x23
    80003b3a:	e3250513          	addi	a0,a0,-462 # 80026968 <icache>
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	230080e7          	jalr	560(ra) # 80000d6e <acquire>
  ip->ref++;
    80003b46:	449c                	lw	a5,8(s1)
    80003b48:	2785                	addiw	a5,a5,1
    80003b4a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b4c:	00023517          	auipc	a0,0x23
    80003b50:	e1c50513          	addi	a0,a0,-484 # 80026968 <icache>
    80003b54:	ffffd097          	auipc	ra,0xffffd
    80003b58:	2ea080e7          	jalr	746(ra) # 80000e3e <release>
}
    80003b5c:	8526                	mv	a0,s1
    80003b5e:	60e2                	ld	ra,24(sp)
    80003b60:	6442                	ld	s0,16(sp)
    80003b62:	64a2                	ld	s1,8(sp)
    80003b64:	6105                	addi	sp,sp,32
    80003b66:	8082                	ret

0000000080003b68 <ilock>:
{
    80003b68:	1101                	addi	sp,sp,-32
    80003b6a:	ec06                	sd	ra,24(sp)
    80003b6c:	e822                	sd	s0,16(sp)
    80003b6e:	e426                	sd	s1,8(sp)
    80003b70:	e04a                	sd	s2,0(sp)
    80003b72:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b74:	c115                	beqz	a0,80003b98 <ilock+0x30>
    80003b76:	84aa                	mv	s1,a0
    80003b78:	451c                	lw	a5,8(a0)
    80003b7a:	00f05f63          	blez	a5,80003b98 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b7e:	0541                	addi	a0,a0,16
    80003b80:	00001097          	auipc	ra,0x1
    80003b84:	cb8080e7          	jalr	-840(ra) # 80004838 <acquiresleep>
  if(ip->valid == 0){
    80003b88:	44bc                	lw	a5,72(s1)
    80003b8a:	cf99                	beqz	a5,80003ba8 <ilock+0x40>
}
    80003b8c:	60e2                	ld	ra,24(sp)
    80003b8e:	6442                	ld	s0,16(sp)
    80003b90:	64a2                	ld	s1,8(sp)
    80003b92:	6902                	ld	s2,0(sp)
    80003b94:	6105                	addi	sp,sp,32
    80003b96:	8082                	ret
    panic("ilock");
    80003b98:	00005517          	auipc	a0,0x5
    80003b9c:	ab050513          	addi	a0,a0,-1360 # 80008648 <syscalls+0x188>
    80003ba0:	ffffd097          	auipc	ra,0xffffd
    80003ba4:	9b0080e7          	jalr	-1616(ra) # 80000550 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ba8:	40dc                	lw	a5,4(s1)
    80003baa:	0047d79b          	srliw	a5,a5,0x4
    80003bae:	00023597          	auipc	a1,0x23
    80003bb2:	db25a583          	lw	a1,-590(a1) # 80026960 <sb+0x18>
    80003bb6:	9dbd                	addw	a1,a1,a5
    80003bb8:	4088                	lw	a0,0(s1)
    80003bba:	fffff097          	auipc	ra,0xfffff
    80003bbe:	67c080e7          	jalr	1660(ra) # 80003236 <bread>
    80003bc2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bc4:	05850593          	addi	a1,a0,88
    80003bc8:	40dc                	lw	a5,4(s1)
    80003bca:	8bbd                	andi	a5,a5,15
    80003bcc:	079a                	slli	a5,a5,0x6
    80003bce:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003bd0:	00059783          	lh	a5,0(a1)
    80003bd4:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003bd8:	00259783          	lh	a5,2(a1)
    80003bdc:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003be0:	00459783          	lh	a5,4(a1)
    80003be4:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003be8:	00659783          	lh	a5,6(a1)
    80003bec:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003bf0:	459c                	lw	a5,8(a1)
    80003bf2:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bf4:	03400613          	li	a2,52
    80003bf8:	05b1                	addi	a1,a1,12
    80003bfa:	05848513          	addi	a0,s1,88
    80003bfe:	ffffd097          	auipc	ra,0xffffd
    80003c02:	5b0080e7          	jalr	1456(ra) # 800011ae <memmove>
    brelse(bp);
    80003c06:	854a                	mv	a0,s2
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	870080e7          	jalr	-1936(ra) # 80003478 <brelse>
    ip->valid = 1;
    80003c10:	4785                	li	a5,1
    80003c12:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003c14:	04c49783          	lh	a5,76(s1)
    80003c18:	fbb5                	bnez	a5,80003b8c <ilock+0x24>
      panic("ilock: no type");
    80003c1a:	00005517          	auipc	a0,0x5
    80003c1e:	a3650513          	addi	a0,a0,-1482 # 80008650 <syscalls+0x190>
    80003c22:	ffffd097          	auipc	ra,0xffffd
    80003c26:	92e080e7          	jalr	-1746(ra) # 80000550 <panic>

0000000080003c2a <iunlock>:
{
    80003c2a:	1101                	addi	sp,sp,-32
    80003c2c:	ec06                	sd	ra,24(sp)
    80003c2e:	e822                	sd	s0,16(sp)
    80003c30:	e426                	sd	s1,8(sp)
    80003c32:	e04a                	sd	s2,0(sp)
    80003c34:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c36:	c905                	beqz	a0,80003c66 <iunlock+0x3c>
    80003c38:	84aa                	mv	s1,a0
    80003c3a:	01050913          	addi	s2,a0,16
    80003c3e:	854a                	mv	a0,s2
    80003c40:	00001097          	auipc	ra,0x1
    80003c44:	c92080e7          	jalr	-878(ra) # 800048d2 <holdingsleep>
    80003c48:	cd19                	beqz	a0,80003c66 <iunlock+0x3c>
    80003c4a:	449c                	lw	a5,8(s1)
    80003c4c:	00f05d63          	blez	a5,80003c66 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c50:	854a                	mv	a0,s2
    80003c52:	00001097          	auipc	ra,0x1
    80003c56:	c3c080e7          	jalr	-964(ra) # 8000488e <releasesleep>
}
    80003c5a:	60e2                	ld	ra,24(sp)
    80003c5c:	6442                	ld	s0,16(sp)
    80003c5e:	64a2                	ld	s1,8(sp)
    80003c60:	6902                	ld	s2,0(sp)
    80003c62:	6105                	addi	sp,sp,32
    80003c64:	8082                	ret
    panic("iunlock");
    80003c66:	00005517          	auipc	a0,0x5
    80003c6a:	9fa50513          	addi	a0,a0,-1542 # 80008660 <syscalls+0x1a0>
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	8e2080e7          	jalr	-1822(ra) # 80000550 <panic>

0000000080003c76 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c76:	7179                	addi	sp,sp,-48
    80003c78:	f406                	sd	ra,40(sp)
    80003c7a:	f022                	sd	s0,32(sp)
    80003c7c:	ec26                	sd	s1,24(sp)
    80003c7e:	e84a                	sd	s2,16(sp)
    80003c80:	e44e                	sd	s3,8(sp)
    80003c82:	e052                	sd	s4,0(sp)
    80003c84:	1800                	addi	s0,sp,48
    80003c86:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c88:	05850493          	addi	s1,a0,88
    80003c8c:	08850913          	addi	s2,a0,136
    80003c90:	a021                	j	80003c98 <itrunc+0x22>
    80003c92:	0491                	addi	s1,s1,4
    80003c94:	01248d63          	beq	s1,s2,80003cae <itrunc+0x38>
    if(ip->addrs[i]){
    80003c98:	408c                	lw	a1,0(s1)
    80003c9a:	dde5                	beqz	a1,80003c92 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c9c:	0009a503          	lw	a0,0(s3)
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	90c080e7          	jalr	-1780(ra) # 800035ac <bfree>
      ip->addrs[i] = 0;
    80003ca8:	0004a023          	sw	zero,0(s1)
    80003cac:	b7dd                	j	80003c92 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cae:	0889a583          	lw	a1,136(s3)
    80003cb2:	e185                	bnez	a1,80003cd2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cb4:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003cb8:	854e                	mv	a0,s3
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	de4080e7          	jalr	-540(ra) # 80003a9e <iupdate>
}
    80003cc2:	70a2                	ld	ra,40(sp)
    80003cc4:	7402                	ld	s0,32(sp)
    80003cc6:	64e2                	ld	s1,24(sp)
    80003cc8:	6942                	ld	s2,16(sp)
    80003cca:	69a2                	ld	s3,8(sp)
    80003ccc:	6a02                	ld	s4,0(sp)
    80003cce:	6145                	addi	sp,sp,48
    80003cd0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cd2:	0009a503          	lw	a0,0(s3)
    80003cd6:	fffff097          	auipc	ra,0xfffff
    80003cda:	560080e7          	jalr	1376(ra) # 80003236 <bread>
    80003cde:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ce0:	05850493          	addi	s1,a0,88
    80003ce4:	45850913          	addi	s2,a0,1112
    80003ce8:	a811                	j	80003cfc <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003cea:	0009a503          	lw	a0,0(s3)
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	8be080e7          	jalr	-1858(ra) # 800035ac <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003cf6:	0491                	addi	s1,s1,4
    80003cf8:	01248563          	beq	s1,s2,80003d02 <itrunc+0x8c>
      if(a[j])
    80003cfc:	408c                	lw	a1,0(s1)
    80003cfe:	dde5                	beqz	a1,80003cf6 <itrunc+0x80>
    80003d00:	b7ed                	j	80003cea <itrunc+0x74>
    brelse(bp);
    80003d02:	8552                	mv	a0,s4
    80003d04:	fffff097          	auipc	ra,0xfffff
    80003d08:	774080e7          	jalr	1908(ra) # 80003478 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d0c:	0889a583          	lw	a1,136(s3)
    80003d10:	0009a503          	lw	a0,0(s3)
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	898080e7          	jalr	-1896(ra) # 800035ac <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d1c:	0809a423          	sw	zero,136(s3)
    80003d20:	bf51                	j	80003cb4 <itrunc+0x3e>

0000000080003d22 <iput>:
{
    80003d22:	1101                	addi	sp,sp,-32
    80003d24:	ec06                	sd	ra,24(sp)
    80003d26:	e822                	sd	s0,16(sp)
    80003d28:	e426                	sd	s1,8(sp)
    80003d2a:	e04a                	sd	s2,0(sp)
    80003d2c:	1000                	addi	s0,sp,32
    80003d2e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003d30:	00023517          	auipc	a0,0x23
    80003d34:	c3850513          	addi	a0,a0,-968 # 80026968 <icache>
    80003d38:	ffffd097          	auipc	ra,0xffffd
    80003d3c:	036080e7          	jalr	54(ra) # 80000d6e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d40:	4498                	lw	a4,8(s1)
    80003d42:	4785                	li	a5,1
    80003d44:	02f70363          	beq	a4,a5,80003d6a <iput+0x48>
  ip->ref--;
    80003d48:	449c                	lw	a5,8(s1)
    80003d4a:	37fd                	addiw	a5,a5,-1
    80003d4c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003d4e:	00023517          	auipc	a0,0x23
    80003d52:	c1a50513          	addi	a0,a0,-998 # 80026968 <icache>
    80003d56:	ffffd097          	auipc	ra,0xffffd
    80003d5a:	0e8080e7          	jalr	232(ra) # 80000e3e <release>
}
    80003d5e:	60e2                	ld	ra,24(sp)
    80003d60:	6442                	ld	s0,16(sp)
    80003d62:	64a2                	ld	s1,8(sp)
    80003d64:	6902                	ld	s2,0(sp)
    80003d66:	6105                	addi	sp,sp,32
    80003d68:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d6a:	44bc                	lw	a5,72(s1)
    80003d6c:	dff1                	beqz	a5,80003d48 <iput+0x26>
    80003d6e:	05249783          	lh	a5,82(s1)
    80003d72:	fbf9                	bnez	a5,80003d48 <iput+0x26>
    acquiresleep(&ip->lock);
    80003d74:	01048913          	addi	s2,s1,16
    80003d78:	854a                	mv	a0,s2
    80003d7a:	00001097          	auipc	ra,0x1
    80003d7e:	abe080e7          	jalr	-1346(ra) # 80004838 <acquiresleep>
    release(&icache.lock);
    80003d82:	00023517          	auipc	a0,0x23
    80003d86:	be650513          	addi	a0,a0,-1050 # 80026968 <icache>
    80003d8a:	ffffd097          	auipc	ra,0xffffd
    80003d8e:	0b4080e7          	jalr	180(ra) # 80000e3e <release>
    itrunc(ip);
    80003d92:	8526                	mv	a0,s1
    80003d94:	00000097          	auipc	ra,0x0
    80003d98:	ee2080e7          	jalr	-286(ra) # 80003c76 <itrunc>
    ip->type = 0;
    80003d9c:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003da0:	8526                	mv	a0,s1
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	cfc080e7          	jalr	-772(ra) # 80003a9e <iupdate>
    ip->valid = 0;
    80003daa:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003dae:	854a                	mv	a0,s2
    80003db0:	00001097          	auipc	ra,0x1
    80003db4:	ade080e7          	jalr	-1314(ra) # 8000488e <releasesleep>
    acquire(&icache.lock);
    80003db8:	00023517          	auipc	a0,0x23
    80003dbc:	bb050513          	addi	a0,a0,-1104 # 80026968 <icache>
    80003dc0:	ffffd097          	auipc	ra,0xffffd
    80003dc4:	fae080e7          	jalr	-82(ra) # 80000d6e <acquire>
    80003dc8:	b741                	j	80003d48 <iput+0x26>

0000000080003dca <iunlockput>:
{
    80003dca:	1101                	addi	sp,sp,-32
    80003dcc:	ec06                	sd	ra,24(sp)
    80003dce:	e822                	sd	s0,16(sp)
    80003dd0:	e426                	sd	s1,8(sp)
    80003dd2:	1000                	addi	s0,sp,32
    80003dd4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dd6:	00000097          	auipc	ra,0x0
    80003dda:	e54080e7          	jalr	-428(ra) # 80003c2a <iunlock>
  iput(ip);
    80003dde:	8526                	mv	a0,s1
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	f42080e7          	jalr	-190(ra) # 80003d22 <iput>
}
    80003de8:	60e2                	ld	ra,24(sp)
    80003dea:	6442                	ld	s0,16(sp)
    80003dec:	64a2                	ld	s1,8(sp)
    80003dee:	6105                	addi	sp,sp,32
    80003df0:	8082                	ret

0000000080003df2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003df2:	1141                	addi	sp,sp,-16
    80003df4:	e422                	sd	s0,8(sp)
    80003df6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003df8:	411c                	lw	a5,0(a0)
    80003dfa:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003dfc:	415c                	lw	a5,4(a0)
    80003dfe:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e00:	04c51783          	lh	a5,76(a0)
    80003e04:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e08:	05251783          	lh	a5,82(a0)
    80003e0c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e10:	05456783          	lwu	a5,84(a0)
    80003e14:	e99c                	sd	a5,16(a1)
}
    80003e16:	6422                	ld	s0,8(sp)
    80003e18:	0141                	addi	sp,sp,16
    80003e1a:	8082                	ret

0000000080003e1c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e1c:	497c                	lw	a5,84(a0)
    80003e1e:	0ed7e963          	bltu	a5,a3,80003f10 <readi+0xf4>
{
    80003e22:	7159                	addi	sp,sp,-112
    80003e24:	f486                	sd	ra,104(sp)
    80003e26:	f0a2                	sd	s0,96(sp)
    80003e28:	eca6                	sd	s1,88(sp)
    80003e2a:	e8ca                	sd	s2,80(sp)
    80003e2c:	e4ce                	sd	s3,72(sp)
    80003e2e:	e0d2                	sd	s4,64(sp)
    80003e30:	fc56                	sd	s5,56(sp)
    80003e32:	f85a                	sd	s6,48(sp)
    80003e34:	f45e                	sd	s7,40(sp)
    80003e36:	f062                	sd	s8,32(sp)
    80003e38:	ec66                	sd	s9,24(sp)
    80003e3a:	e86a                	sd	s10,16(sp)
    80003e3c:	e46e                	sd	s11,8(sp)
    80003e3e:	1880                	addi	s0,sp,112
    80003e40:	8baa                	mv	s7,a0
    80003e42:	8c2e                	mv	s8,a1
    80003e44:	8ab2                	mv	s5,a2
    80003e46:	84b6                	mv	s1,a3
    80003e48:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e4a:	9f35                	addw	a4,a4,a3
    return 0;
    80003e4c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e4e:	0ad76063          	bltu	a4,a3,80003eee <readi+0xd2>
  if(off + n > ip->size)
    80003e52:	00e7f463          	bgeu	a5,a4,80003e5a <readi+0x3e>
    n = ip->size - off;
    80003e56:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e5a:	0a0b0963          	beqz	s6,80003f0c <readi+0xf0>
    80003e5e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e60:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e64:	5cfd                	li	s9,-1
    80003e66:	a82d                	j	80003ea0 <readi+0x84>
    80003e68:	020a1d93          	slli	s11,s4,0x20
    80003e6c:	020ddd93          	srli	s11,s11,0x20
    80003e70:	05890613          	addi	a2,s2,88
    80003e74:	86ee                	mv	a3,s11
    80003e76:	963a                	add	a2,a2,a4
    80003e78:	85d6                	mv	a1,s5
    80003e7a:	8562                	mv	a0,s8
    80003e7c:	fffff097          	auipc	ra,0xfffff
    80003e80:	9ac080e7          	jalr	-1620(ra) # 80002828 <either_copyout>
    80003e84:	05950d63          	beq	a0,s9,80003ede <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e88:	854a                	mv	a0,s2
    80003e8a:	fffff097          	auipc	ra,0xfffff
    80003e8e:	5ee080e7          	jalr	1518(ra) # 80003478 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e92:	013a09bb          	addw	s3,s4,s3
    80003e96:	009a04bb          	addw	s1,s4,s1
    80003e9a:	9aee                	add	s5,s5,s11
    80003e9c:	0569f763          	bgeu	s3,s6,80003eea <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ea0:	000ba903          	lw	s2,0(s7)
    80003ea4:	00a4d59b          	srliw	a1,s1,0xa
    80003ea8:	855e                	mv	a0,s7
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	8b0080e7          	jalr	-1872(ra) # 8000375a <bmap>
    80003eb2:	0005059b          	sext.w	a1,a0
    80003eb6:	854a                	mv	a0,s2
    80003eb8:	fffff097          	auipc	ra,0xfffff
    80003ebc:	37e080e7          	jalr	894(ra) # 80003236 <bread>
    80003ec0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ec2:	3ff4f713          	andi	a4,s1,1023
    80003ec6:	40ed07bb          	subw	a5,s10,a4
    80003eca:	413b06bb          	subw	a3,s6,s3
    80003ece:	8a3e                	mv	s4,a5
    80003ed0:	2781                	sext.w	a5,a5
    80003ed2:	0006861b          	sext.w	a2,a3
    80003ed6:	f8f679e3          	bgeu	a2,a5,80003e68 <readi+0x4c>
    80003eda:	8a36                	mv	s4,a3
    80003edc:	b771                	j	80003e68 <readi+0x4c>
      brelse(bp);
    80003ede:	854a                	mv	a0,s2
    80003ee0:	fffff097          	auipc	ra,0xfffff
    80003ee4:	598080e7          	jalr	1432(ra) # 80003478 <brelse>
      tot = -1;
    80003ee8:	59fd                	li	s3,-1
  }
  return tot;
    80003eea:	0009851b          	sext.w	a0,s3
}
    80003eee:	70a6                	ld	ra,104(sp)
    80003ef0:	7406                	ld	s0,96(sp)
    80003ef2:	64e6                	ld	s1,88(sp)
    80003ef4:	6946                	ld	s2,80(sp)
    80003ef6:	69a6                	ld	s3,72(sp)
    80003ef8:	6a06                	ld	s4,64(sp)
    80003efa:	7ae2                	ld	s5,56(sp)
    80003efc:	7b42                	ld	s6,48(sp)
    80003efe:	7ba2                	ld	s7,40(sp)
    80003f00:	7c02                	ld	s8,32(sp)
    80003f02:	6ce2                	ld	s9,24(sp)
    80003f04:	6d42                	ld	s10,16(sp)
    80003f06:	6da2                	ld	s11,8(sp)
    80003f08:	6165                	addi	sp,sp,112
    80003f0a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f0c:	89da                	mv	s3,s6
    80003f0e:	bff1                	j	80003eea <readi+0xce>
    return 0;
    80003f10:	4501                	li	a0,0
}
    80003f12:	8082                	ret

0000000080003f14 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f14:	497c                	lw	a5,84(a0)
    80003f16:	10d7e763          	bltu	a5,a3,80004024 <writei+0x110>
{
    80003f1a:	7159                	addi	sp,sp,-112
    80003f1c:	f486                	sd	ra,104(sp)
    80003f1e:	f0a2                	sd	s0,96(sp)
    80003f20:	eca6                	sd	s1,88(sp)
    80003f22:	e8ca                	sd	s2,80(sp)
    80003f24:	e4ce                	sd	s3,72(sp)
    80003f26:	e0d2                	sd	s4,64(sp)
    80003f28:	fc56                	sd	s5,56(sp)
    80003f2a:	f85a                	sd	s6,48(sp)
    80003f2c:	f45e                	sd	s7,40(sp)
    80003f2e:	f062                	sd	s8,32(sp)
    80003f30:	ec66                	sd	s9,24(sp)
    80003f32:	e86a                	sd	s10,16(sp)
    80003f34:	e46e                	sd	s11,8(sp)
    80003f36:	1880                	addi	s0,sp,112
    80003f38:	8baa                	mv	s7,a0
    80003f3a:	8c2e                	mv	s8,a1
    80003f3c:	8ab2                	mv	s5,a2
    80003f3e:	8936                	mv	s2,a3
    80003f40:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f42:	00e687bb          	addw	a5,a3,a4
    80003f46:	0ed7e163          	bltu	a5,a3,80004028 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f4a:	00043737          	lui	a4,0x43
    80003f4e:	0cf76f63          	bltu	a4,a5,8000402c <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f52:	0a0b0863          	beqz	s6,80004002 <writei+0xee>
    80003f56:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f58:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f5c:	5cfd                	li	s9,-1
    80003f5e:	a091                	j	80003fa2 <writei+0x8e>
    80003f60:	02099d93          	slli	s11,s3,0x20
    80003f64:	020ddd93          	srli	s11,s11,0x20
    80003f68:	05848513          	addi	a0,s1,88
    80003f6c:	86ee                	mv	a3,s11
    80003f6e:	8656                	mv	a2,s5
    80003f70:	85e2                	mv	a1,s8
    80003f72:	953a                	add	a0,a0,a4
    80003f74:	fffff097          	auipc	ra,0xfffff
    80003f78:	90a080e7          	jalr	-1782(ra) # 8000287e <either_copyin>
    80003f7c:	07950263          	beq	a0,s9,80003fe0 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003f80:	8526                	mv	a0,s1
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	78e080e7          	jalr	1934(ra) # 80004710 <log_write>
    brelse(bp);
    80003f8a:	8526                	mv	a0,s1
    80003f8c:	fffff097          	auipc	ra,0xfffff
    80003f90:	4ec080e7          	jalr	1260(ra) # 80003478 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f94:	01498a3b          	addw	s4,s3,s4
    80003f98:	0129893b          	addw	s2,s3,s2
    80003f9c:	9aee                	add	s5,s5,s11
    80003f9e:	056a7763          	bgeu	s4,s6,80003fec <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fa2:	000ba483          	lw	s1,0(s7)
    80003fa6:	00a9559b          	srliw	a1,s2,0xa
    80003faa:	855e                	mv	a0,s7
    80003fac:	fffff097          	auipc	ra,0xfffff
    80003fb0:	7ae080e7          	jalr	1966(ra) # 8000375a <bmap>
    80003fb4:	0005059b          	sext.w	a1,a0
    80003fb8:	8526                	mv	a0,s1
    80003fba:	fffff097          	auipc	ra,0xfffff
    80003fbe:	27c080e7          	jalr	636(ra) # 80003236 <bread>
    80003fc2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fc4:	3ff97713          	andi	a4,s2,1023
    80003fc8:	40ed07bb          	subw	a5,s10,a4
    80003fcc:	414b06bb          	subw	a3,s6,s4
    80003fd0:	89be                	mv	s3,a5
    80003fd2:	2781                	sext.w	a5,a5
    80003fd4:	0006861b          	sext.w	a2,a3
    80003fd8:	f8f674e3          	bgeu	a2,a5,80003f60 <writei+0x4c>
    80003fdc:	89b6                	mv	s3,a3
    80003fde:	b749                	j	80003f60 <writei+0x4c>
      brelse(bp);
    80003fe0:	8526                	mv	a0,s1
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	496080e7          	jalr	1174(ra) # 80003478 <brelse>
      n = -1;
    80003fea:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003fec:	054ba783          	lw	a5,84(s7)
    80003ff0:	0127f463          	bgeu	a5,s2,80003ff8 <writei+0xe4>
      ip->size = off;
    80003ff4:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003ff8:	855e                	mv	a0,s7
    80003ffa:	00000097          	auipc	ra,0x0
    80003ffe:	aa4080e7          	jalr	-1372(ra) # 80003a9e <iupdate>
  }

  return n;
    80004002:	000b051b          	sext.w	a0,s6
}
    80004006:	70a6                	ld	ra,104(sp)
    80004008:	7406                	ld	s0,96(sp)
    8000400a:	64e6                	ld	s1,88(sp)
    8000400c:	6946                	ld	s2,80(sp)
    8000400e:	69a6                	ld	s3,72(sp)
    80004010:	6a06                	ld	s4,64(sp)
    80004012:	7ae2                	ld	s5,56(sp)
    80004014:	7b42                	ld	s6,48(sp)
    80004016:	7ba2                	ld	s7,40(sp)
    80004018:	7c02                	ld	s8,32(sp)
    8000401a:	6ce2                	ld	s9,24(sp)
    8000401c:	6d42                	ld	s10,16(sp)
    8000401e:	6da2                	ld	s11,8(sp)
    80004020:	6165                	addi	sp,sp,112
    80004022:	8082                	ret
    return -1;
    80004024:	557d                	li	a0,-1
}
    80004026:	8082                	ret
    return -1;
    80004028:	557d                	li	a0,-1
    8000402a:	bff1                	j	80004006 <writei+0xf2>
    return -1;
    8000402c:	557d                	li	a0,-1
    8000402e:	bfe1                	j	80004006 <writei+0xf2>

0000000080004030 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004030:	1141                	addi	sp,sp,-16
    80004032:	e406                	sd	ra,8(sp)
    80004034:	e022                	sd	s0,0(sp)
    80004036:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004038:	4639                	li	a2,14
    8000403a:	ffffd097          	auipc	ra,0xffffd
    8000403e:	1f0080e7          	jalr	496(ra) # 8000122a <strncmp>
}
    80004042:	60a2                	ld	ra,8(sp)
    80004044:	6402                	ld	s0,0(sp)
    80004046:	0141                	addi	sp,sp,16
    80004048:	8082                	ret

000000008000404a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000404a:	7139                	addi	sp,sp,-64
    8000404c:	fc06                	sd	ra,56(sp)
    8000404e:	f822                	sd	s0,48(sp)
    80004050:	f426                	sd	s1,40(sp)
    80004052:	f04a                	sd	s2,32(sp)
    80004054:	ec4e                	sd	s3,24(sp)
    80004056:	e852                	sd	s4,16(sp)
    80004058:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000405a:	04c51703          	lh	a4,76(a0)
    8000405e:	4785                	li	a5,1
    80004060:	00f71a63          	bne	a4,a5,80004074 <dirlookup+0x2a>
    80004064:	892a                	mv	s2,a0
    80004066:	89ae                	mv	s3,a1
    80004068:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000406a:	497c                	lw	a5,84(a0)
    8000406c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000406e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004070:	e79d                	bnez	a5,8000409e <dirlookup+0x54>
    80004072:	a8a5                	j	800040ea <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004074:	00004517          	auipc	a0,0x4
    80004078:	5f450513          	addi	a0,a0,1524 # 80008668 <syscalls+0x1a8>
    8000407c:	ffffc097          	auipc	ra,0xffffc
    80004080:	4d4080e7          	jalr	1236(ra) # 80000550 <panic>
      panic("dirlookup read");
    80004084:	00004517          	auipc	a0,0x4
    80004088:	5fc50513          	addi	a0,a0,1532 # 80008680 <syscalls+0x1c0>
    8000408c:	ffffc097          	auipc	ra,0xffffc
    80004090:	4c4080e7          	jalr	1220(ra) # 80000550 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004094:	24c1                	addiw	s1,s1,16
    80004096:	05492783          	lw	a5,84(s2)
    8000409a:	04f4f763          	bgeu	s1,a5,800040e8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000409e:	4741                	li	a4,16
    800040a0:	86a6                	mv	a3,s1
    800040a2:	fc040613          	addi	a2,s0,-64
    800040a6:	4581                	li	a1,0
    800040a8:	854a                	mv	a0,s2
    800040aa:	00000097          	auipc	ra,0x0
    800040ae:	d72080e7          	jalr	-654(ra) # 80003e1c <readi>
    800040b2:	47c1                	li	a5,16
    800040b4:	fcf518e3          	bne	a0,a5,80004084 <dirlookup+0x3a>
    if(de.inum == 0)
    800040b8:	fc045783          	lhu	a5,-64(s0)
    800040bc:	dfe1                	beqz	a5,80004094 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040be:	fc240593          	addi	a1,s0,-62
    800040c2:	854e                	mv	a0,s3
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	f6c080e7          	jalr	-148(ra) # 80004030 <namecmp>
    800040cc:	f561                	bnez	a0,80004094 <dirlookup+0x4a>
      if(poff)
    800040ce:	000a0463          	beqz	s4,800040d6 <dirlookup+0x8c>
        *poff = off;
    800040d2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800040d6:	fc045583          	lhu	a1,-64(s0)
    800040da:	00092503          	lw	a0,0(s2)
    800040de:	fffff097          	auipc	ra,0xfffff
    800040e2:	756080e7          	jalr	1878(ra) # 80003834 <iget>
    800040e6:	a011                	j	800040ea <dirlookup+0xa0>
  return 0;
    800040e8:	4501                	li	a0,0
}
    800040ea:	70e2                	ld	ra,56(sp)
    800040ec:	7442                	ld	s0,48(sp)
    800040ee:	74a2                	ld	s1,40(sp)
    800040f0:	7902                	ld	s2,32(sp)
    800040f2:	69e2                	ld	s3,24(sp)
    800040f4:	6a42                	ld	s4,16(sp)
    800040f6:	6121                	addi	sp,sp,64
    800040f8:	8082                	ret

00000000800040fa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040fa:	711d                	addi	sp,sp,-96
    800040fc:	ec86                	sd	ra,88(sp)
    800040fe:	e8a2                	sd	s0,80(sp)
    80004100:	e4a6                	sd	s1,72(sp)
    80004102:	e0ca                	sd	s2,64(sp)
    80004104:	fc4e                	sd	s3,56(sp)
    80004106:	f852                	sd	s4,48(sp)
    80004108:	f456                	sd	s5,40(sp)
    8000410a:	f05a                	sd	s6,32(sp)
    8000410c:	ec5e                	sd	s7,24(sp)
    8000410e:	e862                	sd	s8,16(sp)
    80004110:	e466                	sd	s9,8(sp)
    80004112:	1080                	addi	s0,sp,96
    80004114:	84aa                	mv	s1,a0
    80004116:	8b2e                	mv	s6,a1
    80004118:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000411a:	00054703          	lbu	a4,0(a0)
    8000411e:	02f00793          	li	a5,47
    80004122:	02f70363          	beq	a4,a5,80004148 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004126:	ffffe097          	auipc	ra,0xffffe
    8000412a:	c90080e7          	jalr	-880(ra) # 80001db6 <myproc>
    8000412e:	15853503          	ld	a0,344(a0)
    80004132:	00000097          	auipc	ra,0x0
    80004136:	9f8080e7          	jalr	-1544(ra) # 80003b2a <idup>
    8000413a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000413c:	02f00913          	li	s2,47
  len = path - s;
    80004140:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004142:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004144:	4c05                	li	s8,1
    80004146:	a865                	j	800041fe <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004148:	4585                	li	a1,1
    8000414a:	4505                	li	a0,1
    8000414c:	fffff097          	auipc	ra,0xfffff
    80004150:	6e8080e7          	jalr	1768(ra) # 80003834 <iget>
    80004154:	89aa                	mv	s3,a0
    80004156:	b7dd                	j	8000413c <namex+0x42>
      iunlockput(ip);
    80004158:	854e                	mv	a0,s3
    8000415a:	00000097          	auipc	ra,0x0
    8000415e:	c70080e7          	jalr	-912(ra) # 80003dca <iunlockput>
      return 0;
    80004162:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004164:	854e                	mv	a0,s3
    80004166:	60e6                	ld	ra,88(sp)
    80004168:	6446                	ld	s0,80(sp)
    8000416a:	64a6                	ld	s1,72(sp)
    8000416c:	6906                	ld	s2,64(sp)
    8000416e:	79e2                	ld	s3,56(sp)
    80004170:	7a42                	ld	s4,48(sp)
    80004172:	7aa2                	ld	s5,40(sp)
    80004174:	7b02                	ld	s6,32(sp)
    80004176:	6be2                	ld	s7,24(sp)
    80004178:	6c42                	ld	s8,16(sp)
    8000417a:	6ca2                	ld	s9,8(sp)
    8000417c:	6125                	addi	sp,sp,96
    8000417e:	8082                	ret
      iunlock(ip);
    80004180:	854e                	mv	a0,s3
    80004182:	00000097          	auipc	ra,0x0
    80004186:	aa8080e7          	jalr	-1368(ra) # 80003c2a <iunlock>
      return ip;
    8000418a:	bfe9                	j	80004164 <namex+0x6a>
      iunlockput(ip);
    8000418c:	854e                	mv	a0,s3
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	c3c080e7          	jalr	-964(ra) # 80003dca <iunlockput>
      return 0;
    80004196:	89d2                	mv	s3,s4
    80004198:	b7f1                	j	80004164 <namex+0x6a>
  len = path - s;
    8000419a:	40b48633          	sub	a2,s1,a1
    8000419e:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800041a2:	094cd463          	bge	s9,s4,8000422a <namex+0x130>
    memmove(name, s, DIRSIZ);
    800041a6:	4639                	li	a2,14
    800041a8:	8556                	mv	a0,s5
    800041aa:	ffffd097          	auipc	ra,0xffffd
    800041ae:	004080e7          	jalr	4(ra) # 800011ae <memmove>
  while(*path == '/')
    800041b2:	0004c783          	lbu	a5,0(s1)
    800041b6:	01279763          	bne	a5,s2,800041c4 <namex+0xca>
    path++;
    800041ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041bc:	0004c783          	lbu	a5,0(s1)
    800041c0:	ff278de3          	beq	a5,s2,800041ba <namex+0xc0>
    ilock(ip);
    800041c4:	854e                	mv	a0,s3
    800041c6:	00000097          	auipc	ra,0x0
    800041ca:	9a2080e7          	jalr	-1630(ra) # 80003b68 <ilock>
    if(ip->type != T_DIR){
    800041ce:	04c99783          	lh	a5,76(s3)
    800041d2:	f98793e3          	bne	a5,s8,80004158 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800041d6:	000b0563          	beqz	s6,800041e0 <namex+0xe6>
    800041da:	0004c783          	lbu	a5,0(s1)
    800041de:	d3cd                	beqz	a5,80004180 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800041e0:	865e                	mv	a2,s7
    800041e2:	85d6                	mv	a1,s5
    800041e4:	854e                	mv	a0,s3
    800041e6:	00000097          	auipc	ra,0x0
    800041ea:	e64080e7          	jalr	-412(ra) # 8000404a <dirlookup>
    800041ee:	8a2a                	mv	s4,a0
    800041f0:	dd51                	beqz	a0,8000418c <namex+0x92>
    iunlockput(ip);
    800041f2:	854e                	mv	a0,s3
    800041f4:	00000097          	auipc	ra,0x0
    800041f8:	bd6080e7          	jalr	-1066(ra) # 80003dca <iunlockput>
    ip = next;
    800041fc:	89d2                	mv	s3,s4
  while(*path == '/')
    800041fe:	0004c783          	lbu	a5,0(s1)
    80004202:	05279763          	bne	a5,s2,80004250 <namex+0x156>
    path++;
    80004206:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004208:	0004c783          	lbu	a5,0(s1)
    8000420c:	ff278de3          	beq	a5,s2,80004206 <namex+0x10c>
  if(*path == 0)
    80004210:	c79d                	beqz	a5,8000423e <namex+0x144>
    path++;
    80004212:	85a6                	mv	a1,s1
  len = path - s;
    80004214:	8a5e                	mv	s4,s7
    80004216:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004218:	01278963          	beq	a5,s2,8000422a <namex+0x130>
    8000421c:	dfbd                	beqz	a5,8000419a <namex+0xa0>
    path++;
    8000421e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004220:	0004c783          	lbu	a5,0(s1)
    80004224:	ff279ce3          	bne	a5,s2,8000421c <namex+0x122>
    80004228:	bf8d                	j	8000419a <namex+0xa0>
    memmove(name, s, len);
    8000422a:	2601                	sext.w	a2,a2
    8000422c:	8556                	mv	a0,s5
    8000422e:	ffffd097          	auipc	ra,0xffffd
    80004232:	f80080e7          	jalr	-128(ra) # 800011ae <memmove>
    name[len] = 0;
    80004236:	9a56                	add	s4,s4,s5
    80004238:	000a0023          	sb	zero,0(s4)
    8000423c:	bf9d                	j	800041b2 <namex+0xb8>
  if(nameiparent){
    8000423e:	f20b03e3          	beqz	s6,80004164 <namex+0x6a>
    iput(ip);
    80004242:	854e                	mv	a0,s3
    80004244:	00000097          	auipc	ra,0x0
    80004248:	ade080e7          	jalr	-1314(ra) # 80003d22 <iput>
    return 0;
    8000424c:	4981                	li	s3,0
    8000424e:	bf19                	j	80004164 <namex+0x6a>
  if(*path == 0)
    80004250:	d7fd                	beqz	a5,8000423e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004252:	0004c783          	lbu	a5,0(s1)
    80004256:	85a6                	mv	a1,s1
    80004258:	b7d1                	j	8000421c <namex+0x122>

000000008000425a <dirlink>:
{
    8000425a:	7139                	addi	sp,sp,-64
    8000425c:	fc06                	sd	ra,56(sp)
    8000425e:	f822                	sd	s0,48(sp)
    80004260:	f426                	sd	s1,40(sp)
    80004262:	f04a                	sd	s2,32(sp)
    80004264:	ec4e                	sd	s3,24(sp)
    80004266:	e852                	sd	s4,16(sp)
    80004268:	0080                	addi	s0,sp,64
    8000426a:	892a                	mv	s2,a0
    8000426c:	8a2e                	mv	s4,a1
    8000426e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004270:	4601                	li	a2,0
    80004272:	00000097          	auipc	ra,0x0
    80004276:	dd8080e7          	jalr	-552(ra) # 8000404a <dirlookup>
    8000427a:	e93d                	bnez	a0,800042f0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000427c:	05492483          	lw	s1,84(s2)
    80004280:	c49d                	beqz	s1,800042ae <dirlink+0x54>
    80004282:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004284:	4741                	li	a4,16
    80004286:	86a6                	mv	a3,s1
    80004288:	fc040613          	addi	a2,s0,-64
    8000428c:	4581                	li	a1,0
    8000428e:	854a                	mv	a0,s2
    80004290:	00000097          	auipc	ra,0x0
    80004294:	b8c080e7          	jalr	-1140(ra) # 80003e1c <readi>
    80004298:	47c1                	li	a5,16
    8000429a:	06f51163          	bne	a0,a5,800042fc <dirlink+0xa2>
    if(de.inum == 0)
    8000429e:	fc045783          	lhu	a5,-64(s0)
    800042a2:	c791                	beqz	a5,800042ae <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042a4:	24c1                	addiw	s1,s1,16
    800042a6:	05492783          	lw	a5,84(s2)
    800042aa:	fcf4ede3          	bltu	s1,a5,80004284 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042ae:	4639                	li	a2,14
    800042b0:	85d2                	mv	a1,s4
    800042b2:	fc240513          	addi	a0,s0,-62
    800042b6:	ffffd097          	auipc	ra,0xffffd
    800042ba:	fb0080e7          	jalr	-80(ra) # 80001266 <strncpy>
  de.inum = inum;
    800042be:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042c2:	4741                	li	a4,16
    800042c4:	86a6                	mv	a3,s1
    800042c6:	fc040613          	addi	a2,s0,-64
    800042ca:	4581                	li	a1,0
    800042cc:	854a                	mv	a0,s2
    800042ce:	00000097          	auipc	ra,0x0
    800042d2:	c46080e7          	jalr	-954(ra) # 80003f14 <writei>
    800042d6:	872a                	mv	a4,a0
    800042d8:	47c1                	li	a5,16
  return 0;
    800042da:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042dc:	02f71863          	bne	a4,a5,8000430c <dirlink+0xb2>
}
    800042e0:	70e2                	ld	ra,56(sp)
    800042e2:	7442                	ld	s0,48(sp)
    800042e4:	74a2                	ld	s1,40(sp)
    800042e6:	7902                	ld	s2,32(sp)
    800042e8:	69e2                	ld	s3,24(sp)
    800042ea:	6a42                	ld	s4,16(sp)
    800042ec:	6121                	addi	sp,sp,64
    800042ee:	8082                	ret
    iput(ip);
    800042f0:	00000097          	auipc	ra,0x0
    800042f4:	a32080e7          	jalr	-1486(ra) # 80003d22 <iput>
    return -1;
    800042f8:	557d                	li	a0,-1
    800042fa:	b7dd                	j	800042e0 <dirlink+0x86>
      panic("dirlink read");
    800042fc:	00004517          	auipc	a0,0x4
    80004300:	39450513          	addi	a0,a0,916 # 80008690 <syscalls+0x1d0>
    80004304:	ffffc097          	auipc	ra,0xffffc
    80004308:	24c080e7          	jalr	588(ra) # 80000550 <panic>
    panic("dirlink");
    8000430c:	00004517          	auipc	a0,0x4
    80004310:	4a450513          	addi	a0,a0,1188 # 800087b0 <syscalls+0x2f0>
    80004314:	ffffc097          	auipc	ra,0xffffc
    80004318:	23c080e7          	jalr	572(ra) # 80000550 <panic>

000000008000431c <namei>:

struct inode*
namei(char *path)
{
    8000431c:	1101                	addi	sp,sp,-32
    8000431e:	ec06                	sd	ra,24(sp)
    80004320:	e822                	sd	s0,16(sp)
    80004322:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004324:	fe040613          	addi	a2,s0,-32
    80004328:	4581                	li	a1,0
    8000432a:	00000097          	auipc	ra,0x0
    8000432e:	dd0080e7          	jalr	-560(ra) # 800040fa <namex>
}
    80004332:	60e2                	ld	ra,24(sp)
    80004334:	6442                	ld	s0,16(sp)
    80004336:	6105                	addi	sp,sp,32
    80004338:	8082                	ret

000000008000433a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000433a:	1141                	addi	sp,sp,-16
    8000433c:	e406                	sd	ra,8(sp)
    8000433e:	e022                	sd	s0,0(sp)
    80004340:	0800                	addi	s0,sp,16
    80004342:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004344:	4585                	li	a1,1
    80004346:	00000097          	auipc	ra,0x0
    8000434a:	db4080e7          	jalr	-588(ra) # 800040fa <namex>
}
    8000434e:	60a2                	ld	ra,8(sp)
    80004350:	6402                	ld	s0,0(sp)
    80004352:	0141                	addi	sp,sp,16
    80004354:	8082                	ret

0000000080004356 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004356:	1101                	addi	sp,sp,-32
    80004358:	ec06                	sd	ra,24(sp)
    8000435a:	e822                	sd	s0,16(sp)
    8000435c:	e426                	sd	s1,8(sp)
    8000435e:	e04a                	sd	s2,0(sp)
    80004360:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004362:	00024917          	auipc	s2,0x24
    80004366:	24690913          	addi	s2,s2,582 # 800285a8 <log>
    8000436a:	02092583          	lw	a1,32(s2)
    8000436e:	03092503          	lw	a0,48(s2)
    80004372:	fffff097          	auipc	ra,0xfffff
    80004376:	ec4080e7          	jalr	-316(ra) # 80003236 <bread>
    8000437a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000437c:	03492683          	lw	a3,52(s2)
    80004380:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004382:	02d05763          	blez	a3,800043b0 <write_head+0x5a>
    80004386:	00024797          	auipc	a5,0x24
    8000438a:	25a78793          	addi	a5,a5,602 # 800285e0 <log+0x38>
    8000438e:	05c50713          	addi	a4,a0,92
    80004392:	36fd                	addiw	a3,a3,-1
    80004394:	1682                	slli	a3,a3,0x20
    80004396:	9281                	srli	a3,a3,0x20
    80004398:	068a                	slli	a3,a3,0x2
    8000439a:	00024617          	auipc	a2,0x24
    8000439e:	24a60613          	addi	a2,a2,586 # 800285e4 <log+0x3c>
    800043a2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800043a4:	4390                	lw	a2,0(a5)
    800043a6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043a8:	0791                	addi	a5,a5,4
    800043aa:	0711                	addi	a4,a4,4
    800043ac:	fed79ce3          	bne	a5,a3,800043a4 <write_head+0x4e>
  }
  bwrite(buf);
    800043b0:	8526                	mv	a0,s1
    800043b2:	fffff097          	auipc	ra,0xfffff
    800043b6:	088080e7          	jalr	136(ra) # 8000343a <bwrite>
  brelse(buf);
    800043ba:	8526                	mv	a0,s1
    800043bc:	fffff097          	auipc	ra,0xfffff
    800043c0:	0bc080e7          	jalr	188(ra) # 80003478 <brelse>
}
    800043c4:	60e2                	ld	ra,24(sp)
    800043c6:	6442                	ld	s0,16(sp)
    800043c8:	64a2                	ld	s1,8(sp)
    800043ca:	6902                	ld	s2,0(sp)
    800043cc:	6105                	addi	sp,sp,32
    800043ce:	8082                	ret

00000000800043d0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043d0:	00024797          	auipc	a5,0x24
    800043d4:	20c7a783          	lw	a5,524(a5) # 800285dc <log+0x34>
    800043d8:	0af05d63          	blez	a5,80004492 <install_trans+0xc2>
{
    800043dc:	7139                	addi	sp,sp,-64
    800043de:	fc06                	sd	ra,56(sp)
    800043e0:	f822                	sd	s0,48(sp)
    800043e2:	f426                	sd	s1,40(sp)
    800043e4:	f04a                	sd	s2,32(sp)
    800043e6:	ec4e                	sd	s3,24(sp)
    800043e8:	e852                	sd	s4,16(sp)
    800043ea:	e456                	sd	s5,8(sp)
    800043ec:	e05a                	sd	s6,0(sp)
    800043ee:	0080                	addi	s0,sp,64
    800043f0:	8b2a                	mv	s6,a0
    800043f2:	00024a97          	auipc	s5,0x24
    800043f6:	1eea8a93          	addi	s5,s5,494 # 800285e0 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043fa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043fc:	00024997          	auipc	s3,0x24
    80004400:	1ac98993          	addi	s3,s3,428 # 800285a8 <log>
    80004404:	a035                	j	80004430 <install_trans+0x60>
      bunpin(dbuf);
    80004406:	8526                	mv	a0,s1
    80004408:	fffff097          	auipc	ra,0xfffff
    8000440c:	152080e7          	jalr	338(ra) # 8000355a <bunpin>
    brelse(lbuf);
    80004410:	854a                	mv	a0,s2
    80004412:	fffff097          	auipc	ra,0xfffff
    80004416:	066080e7          	jalr	102(ra) # 80003478 <brelse>
    brelse(dbuf);
    8000441a:	8526                	mv	a0,s1
    8000441c:	fffff097          	auipc	ra,0xfffff
    80004420:	05c080e7          	jalr	92(ra) # 80003478 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004424:	2a05                	addiw	s4,s4,1
    80004426:	0a91                	addi	s5,s5,4
    80004428:	0349a783          	lw	a5,52(s3)
    8000442c:	04fa5963          	bge	s4,a5,8000447e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004430:	0209a583          	lw	a1,32(s3)
    80004434:	014585bb          	addw	a1,a1,s4
    80004438:	2585                	addiw	a1,a1,1
    8000443a:	0309a503          	lw	a0,48(s3)
    8000443e:	fffff097          	auipc	ra,0xfffff
    80004442:	df8080e7          	jalr	-520(ra) # 80003236 <bread>
    80004446:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004448:	000aa583          	lw	a1,0(s5)
    8000444c:	0309a503          	lw	a0,48(s3)
    80004450:	fffff097          	auipc	ra,0xfffff
    80004454:	de6080e7          	jalr	-538(ra) # 80003236 <bread>
    80004458:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000445a:	40000613          	li	a2,1024
    8000445e:	05890593          	addi	a1,s2,88
    80004462:	05850513          	addi	a0,a0,88
    80004466:	ffffd097          	auipc	ra,0xffffd
    8000446a:	d48080e7          	jalr	-696(ra) # 800011ae <memmove>
    bwrite(dbuf);  // write dst to disk
    8000446e:	8526                	mv	a0,s1
    80004470:	fffff097          	auipc	ra,0xfffff
    80004474:	fca080e7          	jalr	-54(ra) # 8000343a <bwrite>
    if(recovering == 0)
    80004478:	f80b1ce3          	bnez	s6,80004410 <install_trans+0x40>
    8000447c:	b769                	j	80004406 <install_trans+0x36>
}
    8000447e:	70e2                	ld	ra,56(sp)
    80004480:	7442                	ld	s0,48(sp)
    80004482:	74a2                	ld	s1,40(sp)
    80004484:	7902                	ld	s2,32(sp)
    80004486:	69e2                	ld	s3,24(sp)
    80004488:	6a42                	ld	s4,16(sp)
    8000448a:	6aa2                	ld	s5,8(sp)
    8000448c:	6b02                	ld	s6,0(sp)
    8000448e:	6121                	addi	sp,sp,64
    80004490:	8082                	ret
    80004492:	8082                	ret

0000000080004494 <initlog>:
{
    80004494:	7179                	addi	sp,sp,-48
    80004496:	f406                	sd	ra,40(sp)
    80004498:	f022                	sd	s0,32(sp)
    8000449a:	ec26                	sd	s1,24(sp)
    8000449c:	e84a                	sd	s2,16(sp)
    8000449e:	e44e                	sd	s3,8(sp)
    800044a0:	1800                	addi	s0,sp,48
    800044a2:	892a                	mv	s2,a0
    800044a4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044a6:	00024497          	auipc	s1,0x24
    800044aa:	10248493          	addi	s1,s1,258 # 800285a8 <log>
    800044ae:	00004597          	auipc	a1,0x4
    800044b2:	1f258593          	addi	a1,a1,498 # 800086a0 <syscalls+0x1e0>
    800044b6:	8526                	mv	a0,s1
    800044b8:	ffffd097          	auipc	ra,0xffffd
    800044bc:	a32080e7          	jalr	-1486(ra) # 80000eea <initlock>
  log.start = sb->logstart;
    800044c0:	0149a583          	lw	a1,20(s3)
    800044c4:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    800044c6:	0109a783          	lw	a5,16(s3)
    800044ca:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    800044cc:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044d0:	854a                	mv	a0,s2
    800044d2:	fffff097          	auipc	ra,0xfffff
    800044d6:	d64080e7          	jalr	-668(ra) # 80003236 <bread>
  log.lh.n = lh->n;
    800044da:	4d3c                	lw	a5,88(a0)
    800044dc:	d8dc                	sw	a5,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044de:	02f05563          	blez	a5,80004508 <initlog+0x74>
    800044e2:	05c50713          	addi	a4,a0,92
    800044e6:	00024697          	auipc	a3,0x24
    800044ea:	0fa68693          	addi	a3,a3,250 # 800285e0 <log+0x38>
    800044ee:	37fd                	addiw	a5,a5,-1
    800044f0:	1782                	slli	a5,a5,0x20
    800044f2:	9381                	srli	a5,a5,0x20
    800044f4:	078a                	slli	a5,a5,0x2
    800044f6:	06050613          	addi	a2,a0,96
    800044fa:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800044fc:	4310                	lw	a2,0(a4)
    800044fe:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004500:	0711                	addi	a4,a4,4
    80004502:	0691                	addi	a3,a3,4
    80004504:	fef71ce3          	bne	a4,a5,800044fc <initlog+0x68>
  brelse(buf);
    80004508:	fffff097          	auipc	ra,0xfffff
    8000450c:	f70080e7          	jalr	-144(ra) # 80003478 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004510:	4505                	li	a0,1
    80004512:	00000097          	auipc	ra,0x0
    80004516:	ebe080e7          	jalr	-322(ra) # 800043d0 <install_trans>
  log.lh.n = 0;
    8000451a:	00024797          	auipc	a5,0x24
    8000451e:	0c07a123          	sw	zero,194(a5) # 800285dc <log+0x34>
  write_head(); // clear the log
    80004522:	00000097          	auipc	ra,0x0
    80004526:	e34080e7          	jalr	-460(ra) # 80004356 <write_head>
}
    8000452a:	70a2                	ld	ra,40(sp)
    8000452c:	7402                	ld	s0,32(sp)
    8000452e:	64e2                	ld	s1,24(sp)
    80004530:	6942                	ld	s2,16(sp)
    80004532:	69a2                	ld	s3,8(sp)
    80004534:	6145                	addi	sp,sp,48
    80004536:	8082                	ret

0000000080004538 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004538:	1101                	addi	sp,sp,-32
    8000453a:	ec06                	sd	ra,24(sp)
    8000453c:	e822                	sd	s0,16(sp)
    8000453e:	e426                	sd	s1,8(sp)
    80004540:	e04a                	sd	s2,0(sp)
    80004542:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004544:	00024517          	auipc	a0,0x24
    80004548:	06450513          	addi	a0,a0,100 # 800285a8 <log>
    8000454c:	ffffd097          	auipc	ra,0xffffd
    80004550:	822080e7          	jalr	-2014(ra) # 80000d6e <acquire>
  while(1){
    if(log.committing){
    80004554:	00024497          	auipc	s1,0x24
    80004558:	05448493          	addi	s1,s1,84 # 800285a8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000455c:	4979                	li	s2,30
    8000455e:	a039                	j	8000456c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004560:	85a6                	mv	a1,s1
    80004562:	8526                	mv	a0,s1
    80004564:	ffffe097          	auipc	ra,0xffffe
    80004568:	062080e7          	jalr	98(ra) # 800025c6 <sleep>
    if(log.committing){
    8000456c:	54dc                	lw	a5,44(s1)
    8000456e:	fbed                	bnez	a5,80004560 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004570:	549c                	lw	a5,40(s1)
    80004572:	0017871b          	addiw	a4,a5,1
    80004576:	0007069b          	sext.w	a3,a4
    8000457a:	0027179b          	slliw	a5,a4,0x2
    8000457e:	9fb9                	addw	a5,a5,a4
    80004580:	0017979b          	slliw	a5,a5,0x1
    80004584:	58d8                	lw	a4,52(s1)
    80004586:	9fb9                	addw	a5,a5,a4
    80004588:	00f95963          	bge	s2,a5,8000459a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000458c:	85a6                	mv	a1,s1
    8000458e:	8526                	mv	a0,s1
    80004590:	ffffe097          	auipc	ra,0xffffe
    80004594:	036080e7          	jalr	54(ra) # 800025c6 <sleep>
    80004598:	bfd1                	j	8000456c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000459a:	00024517          	auipc	a0,0x24
    8000459e:	00e50513          	addi	a0,a0,14 # 800285a8 <log>
    800045a2:	d514                	sw	a3,40(a0)
      release(&log.lock);
    800045a4:	ffffd097          	auipc	ra,0xffffd
    800045a8:	89a080e7          	jalr	-1894(ra) # 80000e3e <release>
      break;
    }
  }
}
    800045ac:	60e2                	ld	ra,24(sp)
    800045ae:	6442                	ld	s0,16(sp)
    800045b0:	64a2                	ld	s1,8(sp)
    800045b2:	6902                	ld	s2,0(sp)
    800045b4:	6105                	addi	sp,sp,32
    800045b6:	8082                	ret

00000000800045b8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045b8:	7139                	addi	sp,sp,-64
    800045ba:	fc06                	sd	ra,56(sp)
    800045bc:	f822                	sd	s0,48(sp)
    800045be:	f426                	sd	s1,40(sp)
    800045c0:	f04a                	sd	s2,32(sp)
    800045c2:	ec4e                	sd	s3,24(sp)
    800045c4:	e852                	sd	s4,16(sp)
    800045c6:	e456                	sd	s5,8(sp)
    800045c8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045ca:	00024497          	auipc	s1,0x24
    800045ce:	fde48493          	addi	s1,s1,-34 # 800285a8 <log>
    800045d2:	8526                	mv	a0,s1
    800045d4:	ffffc097          	auipc	ra,0xffffc
    800045d8:	79a080e7          	jalr	1946(ra) # 80000d6e <acquire>
  log.outstanding -= 1;
    800045dc:	549c                	lw	a5,40(s1)
    800045de:	37fd                	addiw	a5,a5,-1
    800045e0:	0007891b          	sext.w	s2,a5
    800045e4:	d49c                	sw	a5,40(s1)
  if(log.committing)
    800045e6:	54dc                	lw	a5,44(s1)
    800045e8:	efb9                	bnez	a5,80004646 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045ea:	06091663          	bnez	s2,80004656 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800045ee:	00024497          	auipc	s1,0x24
    800045f2:	fba48493          	addi	s1,s1,-70 # 800285a8 <log>
    800045f6:	4785                	li	a5,1
    800045f8:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045fa:	8526                	mv	a0,s1
    800045fc:	ffffd097          	auipc	ra,0xffffd
    80004600:	842080e7          	jalr	-1982(ra) # 80000e3e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004604:	58dc                	lw	a5,52(s1)
    80004606:	06f04763          	bgtz	a5,80004674 <end_op+0xbc>
    acquire(&log.lock);
    8000460a:	00024497          	auipc	s1,0x24
    8000460e:	f9e48493          	addi	s1,s1,-98 # 800285a8 <log>
    80004612:	8526                	mv	a0,s1
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	75a080e7          	jalr	1882(ra) # 80000d6e <acquire>
    log.committing = 0;
    8000461c:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    80004620:	8526                	mv	a0,s1
    80004622:	ffffe097          	auipc	ra,0xffffe
    80004626:	12a080e7          	jalr	298(ra) # 8000274c <wakeup>
    release(&log.lock);
    8000462a:	8526                	mv	a0,s1
    8000462c:	ffffd097          	auipc	ra,0xffffd
    80004630:	812080e7          	jalr	-2030(ra) # 80000e3e <release>
}
    80004634:	70e2                	ld	ra,56(sp)
    80004636:	7442                	ld	s0,48(sp)
    80004638:	74a2                	ld	s1,40(sp)
    8000463a:	7902                	ld	s2,32(sp)
    8000463c:	69e2                	ld	s3,24(sp)
    8000463e:	6a42                	ld	s4,16(sp)
    80004640:	6aa2                	ld	s5,8(sp)
    80004642:	6121                	addi	sp,sp,64
    80004644:	8082                	ret
    panic("log.committing");
    80004646:	00004517          	auipc	a0,0x4
    8000464a:	06250513          	addi	a0,a0,98 # 800086a8 <syscalls+0x1e8>
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	f02080e7          	jalr	-254(ra) # 80000550 <panic>
    wakeup(&log);
    80004656:	00024497          	auipc	s1,0x24
    8000465a:	f5248493          	addi	s1,s1,-174 # 800285a8 <log>
    8000465e:	8526                	mv	a0,s1
    80004660:	ffffe097          	auipc	ra,0xffffe
    80004664:	0ec080e7          	jalr	236(ra) # 8000274c <wakeup>
  release(&log.lock);
    80004668:	8526                	mv	a0,s1
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	7d4080e7          	jalr	2004(ra) # 80000e3e <release>
  if(do_commit){
    80004672:	b7c9                	j	80004634 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004674:	00024a97          	auipc	s5,0x24
    80004678:	f6ca8a93          	addi	s5,s5,-148 # 800285e0 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000467c:	00024a17          	auipc	s4,0x24
    80004680:	f2ca0a13          	addi	s4,s4,-212 # 800285a8 <log>
    80004684:	020a2583          	lw	a1,32(s4)
    80004688:	012585bb          	addw	a1,a1,s2
    8000468c:	2585                	addiw	a1,a1,1
    8000468e:	030a2503          	lw	a0,48(s4)
    80004692:	fffff097          	auipc	ra,0xfffff
    80004696:	ba4080e7          	jalr	-1116(ra) # 80003236 <bread>
    8000469a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000469c:	000aa583          	lw	a1,0(s5)
    800046a0:	030a2503          	lw	a0,48(s4)
    800046a4:	fffff097          	auipc	ra,0xfffff
    800046a8:	b92080e7          	jalr	-1134(ra) # 80003236 <bread>
    800046ac:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046ae:	40000613          	li	a2,1024
    800046b2:	05850593          	addi	a1,a0,88
    800046b6:	05848513          	addi	a0,s1,88
    800046ba:	ffffd097          	auipc	ra,0xffffd
    800046be:	af4080e7          	jalr	-1292(ra) # 800011ae <memmove>
    bwrite(to);  // write the log
    800046c2:	8526                	mv	a0,s1
    800046c4:	fffff097          	auipc	ra,0xfffff
    800046c8:	d76080e7          	jalr	-650(ra) # 8000343a <bwrite>
    brelse(from);
    800046cc:	854e                	mv	a0,s3
    800046ce:	fffff097          	auipc	ra,0xfffff
    800046d2:	daa080e7          	jalr	-598(ra) # 80003478 <brelse>
    brelse(to);
    800046d6:	8526                	mv	a0,s1
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	da0080e7          	jalr	-608(ra) # 80003478 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046e0:	2905                	addiw	s2,s2,1
    800046e2:	0a91                	addi	s5,s5,4
    800046e4:	034a2783          	lw	a5,52(s4)
    800046e8:	f8f94ee3          	blt	s2,a5,80004684 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046ec:	00000097          	auipc	ra,0x0
    800046f0:	c6a080e7          	jalr	-918(ra) # 80004356 <write_head>
    install_trans(0); // Now install writes to home locations
    800046f4:	4501                	li	a0,0
    800046f6:	00000097          	auipc	ra,0x0
    800046fa:	cda080e7          	jalr	-806(ra) # 800043d0 <install_trans>
    log.lh.n = 0;
    800046fe:	00024797          	auipc	a5,0x24
    80004702:	ec07af23          	sw	zero,-290(a5) # 800285dc <log+0x34>
    write_head();    // Erase the transaction from the log
    80004706:	00000097          	auipc	ra,0x0
    8000470a:	c50080e7          	jalr	-944(ra) # 80004356 <write_head>
    8000470e:	bdf5                	j	8000460a <end_op+0x52>

0000000080004710 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004710:	1101                	addi	sp,sp,-32
    80004712:	ec06                	sd	ra,24(sp)
    80004714:	e822                	sd	s0,16(sp)
    80004716:	e426                	sd	s1,8(sp)
    80004718:	e04a                	sd	s2,0(sp)
    8000471a:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000471c:	00024717          	auipc	a4,0x24
    80004720:	ec072703          	lw	a4,-320(a4) # 800285dc <log+0x34>
    80004724:	47f5                	li	a5,29
    80004726:	08e7c063          	blt	a5,a4,800047a6 <log_write+0x96>
    8000472a:	84aa                	mv	s1,a0
    8000472c:	00024797          	auipc	a5,0x24
    80004730:	ea07a783          	lw	a5,-352(a5) # 800285cc <log+0x24>
    80004734:	37fd                	addiw	a5,a5,-1
    80004736:	06f75863          	bge	a4,a5,800047a6 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000473a:	00024797          	auipc	a5,0x24
    8000473e:	e967a783          	lw	a5,-362(a5) # 800285d0 <log+0x28>
    80004742:	06f05a63          	blez	a5,800047b6 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004746:	00024917          	auipc	s2,0x24
    8000474a:	e6290913          	addi	s2,s2,-414 # 800285a8 <log>
    8000474e:	854a                	mv	a0,s2
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	61e080e7          	jalr	1566(ra) # 80000d6e <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004758:	03492603          	lw	a2,52(s2)
    8000475c:	06c05563          	blez	a2,800047c6 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004760:	44cc                	lw	a1,12(s1)
    80004762:	00024717          	auipc	a4,0x24
    80004766:	e7e70713          	addi	a4,a4,-386 # 800285e0 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    8000476a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000476c:	4314                	lw	a3,0(a4)
    8000476e:	04b68d63          	beq	a3,a1,800047c8 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004772:	2785                	addiw	a5,a5,1
    80004774:	0711                	addi	a4,a4,4
    80004776:	fec79be3          	bne	a5,a2,8000476c <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000477a:	0631                	addi	a2,a2,12
    8000477c:	060a                	slli	a2,a2,0x2
    8000477e:	00024797          	auipc	a5,0x24
    80004782:	e2a78793          	addi	a5,a5,-470 # 800285a8 <log>
    80004786:	963e                	add	a2,a2,a5
    80004788:	44dc                	lw	a5,12(s1)
    8000478a:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000478c:	8526                	mv	a0,s1
    8000478e:	fffff097          	auipc	ra,0xfffff
    80004792:	d7a080e7          	jalr	-646(ra) # 80003508 <bpin>
    log.lh.n++;
    80004796:	00024717          	auipc	a4,0x24
    8000479a:	e1270713          	addi	a4,a4,-494 # 800285a8 <log>
    8000479e:	5b5c                	lw	a5,52(a4)
    800047a0:	2785                	addiw	a5,a5,1
    800047a2:	db5c                	sw	a5,52(a4)
    800047a4:	a83d                	j	800047e2 <log_write+0xd2>
    panic("too big a transaction");
    800047a6:	00004517          	auipc	a0,0x4
    800047aa:	f1250513          	addi	a0,a0,-238 # 800086b8 <syscalls+0x1f8>
    800047ae:	ffffc097          	auipc	ra,0xffffc
    800047b2:	da2080e7          	jalr	-606(ra) # 80000550 <panic>
    panic("log_write outside of trans");
    800047b6:	00004517          	auipc	a0,0x4
    800047ba:	f1a50513          	addi	a0,a0,-230 # 800086d0 <syscalls+0x210>
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	d92080e7          	jalr	-622(ra) # 80000550 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800047c6:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800047c8:	00c78713          	addi	a4,a5,12
    800047cc:	00271693          	slli	a3,a4,0x2
    800047d0:	00024717          	auipc	a4,0x24
    800047d4:	dd870713          	addi	a4,a4,-552 # 800285a8 <log>
    800047d8:	9736                	add	a4,a4,a3
    800047da:	44d4                	lw	a3,12(s1)
    800047dc:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047de:	faf607e3          	beq	a2,a5,8000478c <log_write+0x7c>
  }
  release(&log.lock);
    800047e2:	00024517          	auipc	a0,0x24
    800047e6:	dc650513          	addi	a0,a0,-570 # 800285a8 <log>
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	654080e7          	jalr	1620(ra) # 80000e3e <release>
}
    800047f2:	60e2                	ld	ra,24(sp)
    800047f4:	6442                	ld	s0,16(sp)
    800047f6:	64a2                	ld	s1,8(sp)
    800047f8:	6902                	ld	s2,0(sp)
    800047fa:	6105                	addi	sp,sp,32
    800047fc:	8082                	ret

00000000800047fe <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047fe:	1101                	addi	sp,sp,-32
    80004800:	ec06                	sd	ra,24(sp)
    80004802:	e822                	sd	s0,16(sp)
    80004804:	e426                	sd	s1,8(sp)
    80004806:	e04a                	sd	s2,0(sp)
    80004808:	1000                	addi	s0,sp,32
    8000480a:	84aa                	mv	s1,a0
    8000480c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000480e:	00004597          	auipc	a1,0x4
    80004812:	ee258593          	addi	a1,a1,-286 # 800086f0 <syscalls+0x230>
    80004816:	0521                	addi	a0,a0,8
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	6d2080e7          	jalr	1746(ra) # 80000eea <initlock>
  lk->name = name;
    80004820:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004824:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004828:	0204a823          	sw	zero,48(s1)
}
    8000482c:	60e2                	ld	ra,24(sp)
    8000482e:	6442                	ld	s0,16(sp)
    80004830:	64a2                	ld	s1,8(sp)
    80004832:	6902                	ld	s2,0(sp)
    80004834:	6105                	addi	sp,sp,32
    80004836:	8082                	ret

0000000080004838 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004838:	1101                	addi	sp,sp,-32
    8000483a:	ec06                	sd	ra,24(sp)
    8000483c:	e822                	sd	s0,16(sp)
    8000483e:	e426                	sd	s1,8(sp)
    80004840:	e04a                	sd	s2,0(sp)
    80004842:	1000                	addi	s0,sp,32
    80004844:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004846:	00850913          	addi	s2,a0,8
    8000484a:	854a                	mv	a0,s2
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	522080e7          	jalr	1314(ra) # 80000d6e <acquire>
  while (lk->locked) {
    80004854:	409c                	lw	a5,0(s1)
    80004856:	cb89                	beqz	a5,80004868 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004858:	85ca                	mv	a1,s2
    8000485a:	8526                	mv	a0,s1
    8000485c:	ffffe097          	auipc	ra,0xffffe
    80004860:	d6a080e7          	jalr	-662(ra) # 800025c6 <sleep>
  while (lk->locked) {
    80004864:	409c                	lw	a5,0(s1)
    80004866:	fbed                	bnez	a5,80004858 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004868:	4785                	li	a5,1
    8000486a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000486c:	ffffd097          	auipc	ra,0xffffd
    80004870:	54a080e7          	jalr	1354(ra) # 80001db6 <myproc>
    80004874:	413c                	lw	a5,64(a0)
    80004876:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    80004878:	854a                	mv	a0,s2
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	5c4080e7          	jalr	1476(ra) # 80000e3e <release>
}
    80004882:	60e2                	ld	ra,24(sp)
    80004884:	6442                	ld	s0,16(sp)
    80004886:	64a2                	ld	s1,8(sp)
    80004888:	6902                	ld	s2,0(sp)
    8000488a:	6105                	addi	sp,sp,32
    8000488c:	8082                	ret

000000008000488e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000488e:	1101                	addi	sp,sp,-32
    80004890:	ec06                	sd	ra,24(sp)
    80004892:	e822                	sd	s0,16(sp)
    80004894:	e426                	sd	s1,8(sp)
    80004896:	e04a                	sd	s2,0(sp)
    80004898:	1000                	addi	s0,sp,32
    8000489a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000489c:	00850913          	addi	s2,a0,8
    800048a0:	854a                	mv	a0,s2
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	4cc080e7          	jalr	1228(ra) # 80000d6e <acquire>
  lk->locked = 0;
    800048aa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048ae:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800048b2:	8526                	mv	a0,s1
    800048b4:	ffffe097          	auipc	ra,0xffffe
    800048b8:	e98080e7          	jalr	-360(ra) # 8000274c <wakeup>
  release(&lk->lk);
    800048bc:	854a                	mv	a0,s2
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	580080e7          	jalr	1408(ra) # 80000e3e <release>
}
    800048c6:	60e2                	ld	ra,24(sp)
    800048c8:	6442                	ld	s0,16(sp)
    800048ca:	64a2                	ld	s1,8(sp)
    800048cc:	6902                	ld	s2,0(sp)
    800048ce:	6105                	addi	sp,sp,32
    800048d0:	8082                	ret

00000000800048d2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048d2:	7179                	addi	sp,sp,-48
    800048d4:	f406                	sd	ra,40(sp)
    800048d6:	f022                	sd	s0,32(sp)
    800048d8:	ec26                	sd	s1,24(sp)
    800048da:	e84a                	sd	s2,16(sp)
    800048dc:	e44e                	sd	s3,8(sp)
    800048de:	1800                	addi	s0,sp,48
    800048e0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048e2:	00850913          	addi	s2,a0,8
    800048e6:	854a                	mv	a0,s2
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	486080e7          	jalr	1158(ra) # 80000d6e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048f0:	409c                	lw	a5,0(s1)
    800048f2:	ef99                	bnez	a5,80004910 <holdingsleep+0x3e>
    800048f4:	4481                	li	s1,0
  release(&lk->lk);
    800048f6:	854a                	mv	a0,s2
    800048f8:	ffffc097          	auipc	ra,0xffffc
    800048fc:	546080e7          	jalr	1350(ra) # 80000e3e <release>
  return r;
}
    80004900:	8526                	mv	a0,s1
    80004902:	70a2                	ld	ra,40(sp)
    80004904:	7402                	ld	s0,32(sp)
    80004906:	64e2                	ld	s1,24(sp)
    80004908:	6942                	ld	s2,16(sp)
    8000490a:	69a2                	ld	s3,8(sp)
    8000490c:	6145                	addi	sp,sp,48
    8000490e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004910:	0304a983          	lw	s3,48(s1)
    80004914:	ffffd097          	auipc	ra,0xffffd
    80004918:	4a2080e7          	jalr	1186(ra) # 80001db6 <myproc>
    8000491c:	4124                	lw	s1,64(a0)
    8000491e:	413484b3          	sub	s1,s1,s3
    80004922:	0014b493          	seqz	s1,s1
    80004926:	bfc1                	j	800048f6 <holdingsleep+0x24>

0000000080004928 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004928:	1141                	addi	sp,sp,-16
    8000492a:	e406                	sd	ra,8(sp)
    8000492c:	e022                	sd	s0,0(sp)
    8000492e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004930:	00004597          	auipc	a1,0x4
    80004934:	dd058593          	addi	a1,a1,-560 # 80008700 <syscalls+0x240>
    80004938:	00024517          	auipc	a0,0x24
    8000493c:	dc050513          	addi	a0,a0,-576 # 800286f8 <ftable>
    80004940:	ffffc097          	auipc	ra,0xffffc
    80004944:	5aa080e7          	jalr	1450(ra) # 80000eea <initlock>
}
    80004948:	60a2                	ld	ra,8(sp)
    8000494a:	6402                	ld	s0,0(sp)
    8000494c:	0141                	addi	sp,sp,16
    8000494e:	8082                	ret

0000000080004950 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004950:	1101                	addi	sp,sp,-32
    80004952:	ec06                	sd	ra,24(sp)
    80004954:	e822                	sd	s0,16(sp)
    80004956:	e426                	sd	s1,8(sp)
    80004958:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000495a:	00024517          	auipc	a0,0x24
    8000495e:	d9e50513          	addi	a0,a0,-610 # 800286f8 <ftable>
    80004962:	ffffc097          	auipc	ra,0xffffc
    80004966:	40c080e7          	jalr	1036(ra) # 80000d6e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000496a:	00024497          	auipc	s1,0x24
    8000496e:	dae48493          	addi	s1,s1,-594 # 80028718 <ftable+0x20>
    80004972:	00025717          	auipc	a4,0x25
    80004976:	d4670713          	addi	a4,a4,-698 # 800296b8 <ftable+0xfc0>
    if(f->ref == 0){
    8000497a:	40dc                	lw	a5,4(s1)
    8000497c:	cf99                	beqz	a5,8000499a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000497e:	02848493          	addi	s1,s1,40
    80004982:	fee49ce3          	bne	s1,a4,8000497a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004986:	00024517          	auipc	a0,0x24
    8000498a:	d7250513          	addi	a0,a0,-654 # 800286f8 <ftable>
    8000498e:	ffffc097          	auipc	ra,0xffffc
    80004992:	4b0080e7          	jalr	1200(ra) # 80000e3e <release>
  return 0;
    80004996:	4481                	li	s1,0
    80004998:	a819                	j	800049ae <filealloc+0x5e>
      f->ref = 1;
    8000499a:	4785                	li	a5,1
    8000499c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000499e:	00024517          	auipc	a0,0x24
    800049a2:	d5a50513          	addi	a0,a0,-678 # 800286f8 <ftable>
    800049a6:	ffffc097          	auipc	ra,0xffffc
    800049aa:	498080e7          	jalr	1176(ra) # 80000e3e <release>
}
    800049ae:	8526                	mv	a0,s1
    800049b0:	60e2                	ld	ra,24(sp)
    800049b2:	6442                	ld	s0,16(sp)
    800049b4:	64a2                	ld	s1,8(sp)
    800049b6:	6105                	addi	sp,sp,32
    800049b8:	8082                	ret

00000000800049ba <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049ba:	1101                	addi	sp,sp,-32
    800049bc:	ec06                	sd	ra,24(sp)
    800049be:	e822                	sd	s0,16(sp)
    800049c0:	e426                	sd	s1,8(sp)
    800049c2:	1000                	addi	s0,sp,32
    800049c4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049c6:	00024517          	auipc	a0,0x24
    800049ca:	d3250513          	addi	a0,a0,-718 # 800286f8 <ftable>
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	3a0080e7          	jalr	928(ra) # 80000d6e <acquire>
  if(f->ref < 1)
    800049d6:	40dc                	lw	a5,4(s1)
    800049d8:	02f05263          	blez	a5,800049fc <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049dc:	2785                	addiw	a5,a5,1
    800049de:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049e0:	00024517          	auipc	a0,0x24
    800049e4:	d1850513          	addi	a0,a0,-744 # 800286f8 <ftable>
    800049e8:	ffffc097          	auipc	ra,0xffffc
    800049ec:	456080e7          	jalr	1110(ra) # 80000e3e <release>
  return f;
}
    800049f0:	8526                	mv	a0,s1
    800049f2:	60e2                	ld	ra,24(sp)
    800049f4:	6442                	ld	s0,16(sp)
    800049f6:	64a2                	ld	s1,8(sp)
    800049f8:	6105                	addi	sp,sp,32
    800049fa:	8082                	ret
    panic("filedup");
    800049fc:	00004517          	auipc	a0,0x4
    80004a00:	d0c50513          	addi	a0,a0,-756 # 80008708 <syscalls+0x248>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	b4c080e7          	jalr	-1204(ra) # 80000550 <panic>

0000000080004a0c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a0c:	7139                	addi	sp,sp,-64
    80004a0e:	fc06                	sd	ra,56(sp)
    80004a10:	f822                	sd	s0,48(sp)
    80004a12:	f426                	sd	s1,40(sp)
    80004a14:	f04a                	sd	s2,32(sp)
    80004a16:	ec4e                	sd	s3,24(sp)
    80004a18:	e852                	sd	s4,16(sp)
    80004a1a:	e456                	sd	s5,8(sp)
    80004a1c:	0080                	addi	s0,sp,64
    80004a1e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a20:	00024517          	auipc	a0,0x24
    80004a24:	cd850513          	addi	a0,a0,-808 # 800286f8 <ftable>
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	346080e7          	jalr	838(ra) # 80000d6e <acquire>
  if(f->ref < 1)
    80004a30:	40dc                	lw	a5,4(s1)
    80004a32:	06f05163          	blez	a5,80004a94 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a36:	37fd                	addiw	a5,a5,-1
    80004a38:	0007871b          	sext.w	a4,a5
    80004a3c:	c0dc                	sw	a5,4(s1)
    80004a3e:	06e04363          	bgtz	a4,80004aa4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a42:	0004a903          	lw	s2,0(s1)
    80004a46:	0094ca83          	lbu	s5,9(s1)
    80004a4a:	0104ba03          	ld	s4,16(s1)
    80004a4e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a52:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a56:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a5a:	00024517          	auipc	a0,0x24
    80004a5e:	c9e50513          	addi	a0,a0,-866 # 800286f8 <ftable>
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	3dc080e7          	jalr	988(ra) # 80000e3e <release>

  if(ff.type == FD_PIPE){
    80004a6a:	4785                	li	a5,1
    80004a6c:	04f90d63          	beq	s2,a5,80004ac6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a70:	3979                	addiw	s2,s2,-2
    80004a72:	4785                	li	a5,1
    80004a74:	0527e063          	bltu	a5,s2,80004ab4 <fileclose+0xa8>
    begin_op();
    80004a78:	00000097          	auipc	ra,0x0
    80004a7c:	ac0080e7          	jalr	-1344(ra) # 80004538 <begin_op>
    iput(ff.ip);
    80004a80:	854e                	mv	a0,s3
    80004a82:	fffff097          	auipc	ra,0xfffff
    80004a86:	2a0080e7          	jalr	672(ra) # 80003d22 <iput>
    end_op();
    80004a8a:	00000097          	auipc	ra,0x0
    80004a8e:	b2e080e7          	jalr	-1234(ra) # 800045b8 <end_op>
    80004a92:	a00d                	j	80004ab4 <fileclose+0xa8>
    panic("fileclose");
    80004a94:	00004517          	auipc	a0,0x4
    80004a98:	c7c50513          	addi	a0,a0,-900 # 80008710 <syscalls+0x250>
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	ab4080e7          	jalr	-1356(ra) # 80000550 <panic>
    release(&ftable.lock);
    80004aa4:	00024517          	auipc	a0,0x24
    80004aa8:	c5450513          	addi	a0,a0,-940 # 800286f8 <ftable>
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	392080e7          	jalr	914(ra) # 80000e3e <release>
  }
}
    80004ab4:	70e2                	ld	ra,56(sp)
    80004ab6:	7442                	ld	s0,48(sp)
    80004ab8:	74a2                	ld	s1,40(sp)
    80004aba:	7902                	ld	s2,32(sp)
    80004abc:	69e2                	ld	s3,24(sp)
    80004abe:	6a42                	ld	s4,16(sp)
    80004ac0:	6aa2                	ld	s5,8(sp)
    80004ac2:	6121                	addi	sp,sp,64
    80004ac4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ac6:	85d6                	mv	a1,s5
    80004ac8:	8552                	mv	a0,s4
    80004aca:	00000097          	auipc	ra,0x0
    80004ace:	372080e7          	jalr	882(ra) # 80004e3c <pipeclose>
    80004ad2:	b7cd                	j	80004ab4 <fileclose+0xa8>

0000000080004ad4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ad4:	715d                	addi	sp,sp,-80
    80004ad6:	e486                	sd	ra,72(sp)
    80004ad8:	e0a2                	sd	s0,64(sp)
    80004ada:	fc26                	sd	s1,56(sp)
    80004adc:	f84a                	sd	s2,48(sp)
    80004ade:	f44e                	sd	s3,40(sp)
    80004ae0:	0880                	addi	s0,sp,80
    80004ae2:	84aa                	mv	s1,a0
    80004ae4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ae6:	ffffd097          	auipc	ra,0xffffd
    80004aea:	2d0080e7          	jalr	720(ra) # 80001db6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004aee:	409c                	lw	a5,0(s1)
    80004af0:	37f9                	addiw	a5,a5,-2
    80004af2:	4705                	li	a4,1
    80004af4:	04f76763          	bltu	a4,a5,80004b42 <filestat+0x6e>
    80004af8:	892a                	mv	s2,a0
    ilock(f->ip);
    80004afa:	6c88                	ld	a0,24(s1)
    80004afc:	fffff097          	auipc	ra,0xfffff
    80004b00:	06c080e7          	jalr	108(ra) # 80003b68 <ilock>
    stati(f->ip, &st);
    80004b04:	fb840593          	addi	a1,s0,-72
    80004b08:	6c88                	ld	a0,24(s1)
    80004b0a:	fffff097          	auipc	ra,0xfffff
    80004b0e:	2e8080e7          	jalr	744(ra) # 80003df2 <stati>
    iunlock(f->ip);
    80004b12:	6c88                	ld	a0,24(s1)
    80004b14:	fffff097          	auipc	ra,0xfffff
    80004b18:	116080e7          	jalr	278(ra) # 80003c2a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b1c:	46e1                	li	a3,24
    80004b1e:	fb840613          	addi	a2,s0,-72
    80004b22:	85ce                	mv	a1,s3
    80004b24:	05893503          	ld	a0,88(s2)
    80004b28:	ffffd097          	auipc	ra,0xffffd
    80004b2c:	f82080e7          	jalr	-126(ra) # 80001aaa <copyout>
    80004b30:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b34:	60a6                	ld	ra,72(sp)
    80004b36:	6406                	ld	s0,64(sp)
    80004b38:	74e2                	ld	s1,56(sp)
    80004b3a:	7942                	ld	s2,48(sp)
    80004b3c:	79a2                	ld	s3,40(sp)
    80004b3e:	6161                	addi	sp,sp,80
    80004b40:	8082                	ret
  return -1;
    80004b42:	557d                	li	a0,-1
    80004b44:	bfc5                	j	80004b34 <filestat+0x60>

0000000080004b46 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b46:	7179                	addi	sp,sp,-48
    80004b48:	f406                	sd	ra,40(sp)
    80004b4a:	f022                	sd	s0,32(sp)
    80004b4c:	ec26                	sd	s1,24(sp)
    80004b4e:	e84a                	sd	s2,16(sp)
    80004b50:	e44e                	sd	s3,8(sp)
    80004b52:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b54:	00854783          	lbu	a5,8(a0)
    80004b58:	c3d5                	beqz	a5,80004bfc <fileread+0xb6>
    80004b5a:	84aa                	mv	s1,a0
    80004b5c:	89ae                	mv	s3,a1
    80004b5e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b60:	411c                	lw	a5,0(a0)
    80004b62:	4705                	li	a4,1
    80004b64:	04e78963          	beq	a5,a4,80004bb6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b68:	470d                	li	a4,3
    80004b6a:	04e78d63          	beq	a5,a4,80004bc4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b6e:	4709                	li	a4,2
    80004b70:	06e79e63          	bne	a5,a4,80004bec <fileread+0xa6>
    ilock(f->ip);
    80004b74:	6d08                	ld	a0,24(a0)
    80004b76:	fffff097          	auipc	ra,0xfffff
    80004b7a:	ff2080e7          	jalr	-14(ra) # 80003b68 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b7e:	874a                	mv	a4,s2
    80004b80:	5094                	lw	a3,32(s1)
    80004b82:	864e                	mv	a2,s3
    80004b84:	4585                	li	a1,1
    80004b86:	6c88                	ld	a0,24(s1)
    80004b88:	fffff097          	auipc	ra,0xfffff
    80004b8c:	294080e7          	jalr	660(ra) # 80003e1c <readi>
    80004b90:	892a                	mv	s2,a0
    80004b92:	00a05563          	blez	a0,80004b9c <fileread+0x56>
      f->off += r;
    80004b96:	509c                	lw	a5,32(s1)
    80004b98:	9fa9                	addw	a5,a5,a0
    80004b9a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b9c:	6c88                	ld	a0,24(s1)
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	08c080e7          	jalr	140(ra) # 80003c2a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ba6:	854a                	mv	a0,s2
    80004ba8:	70a2                	ld	ra,40(sp)
    80004baa:	7402                	ld	s0,32(sp)
    80004bac:	64e2                	ld	s1,24(sp)
    80004bae:	6942                	ld	s2,16(sp)
    80004bb0:	69a2                	ld	s3,8(sp)
    80004bb2:	6145                	addi	sp,sp,48
    80004bb4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004bb6:	6908                	ld	a0,16(a0)
    80004bb8:	00000097          	auipc	ra,0x0
    80004bbc:	422080e7          	jalr	1058(ra) # 80004fda <piperead>
    80004bc0:	892a                	mv	s2,a0
    80004bc2:	b7d5                	j	80004ba6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bc4:	02451783          	lh	a5,36(a0)
    80004bc8:	03079693          	slli	a3,a5,0x30
    80004bcc:	92c1                	srli	a3,a3,0x30
    80004bce:	4725                	li	a4,9
    80004bd0:	02d76863          	bltu	a4,a3,80004c00 <fileread+0xba>
    80004bd4:	0792                	slli	a5,a5,0x4
    80004bd6:	00024717          	auipc	a4,0x24
    80004bda:	a8270713          	addi	a4,a4,-1406 # 80028658 <devsw>
    80004bde:	97ba                	add	a5,a5,a4
    80004be0:	639c                	ld	a5,0(a5)
    80004be2:	c38d                	beqz	a5,80004c04 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004be4:	4505                	li	a0,1
    80004be6:	9782                	jalr	a5
    80004be8:	892a                	mv	s2,a0
    80004bea:	bf75                	j	80004ba6 <fileread+0x60>
    panic("fileread");
    80004bec:	00004517          	auipc	a0,0x4
    80004bf0:	b3450513          	addi	a0,a0,-1228 # 80008720 <syscalls+0x260>
    80004bf4:	ffffc097          	auipc	ra,0xffffc
    80004bf8:	95c080e7          	jalr	-1700(ra) # 80000550 <panic>
    return -1;
    80004bfc:	597d                	li	s2,-1
    80004bfe:	b765                	j	80004ba6 <fileread+0x60>
      return -1;
    80004c00:	597d                	li	s2,-1
    80004c02:	b755                	j	80004ba6 <fileread+0x60>
    80004c04:	597d                	li	s2,-1
    80004c06:	b745                	j	80004ba6 <fileread+0x60>

0000000080004c08 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004c08:	00954783          	lbu	a5,9(a0)
    80004c0c:	14078563          	beqz	a5,80004d56 <filewrite+0x14e>
{
    80004c10:	715d                	addi	sp,sp,-80
    80004c12:	e486                	sd	ra,72(sp)
    80004c14:	e0a2                	sd	s0,64(sp)
    80004c16:	fc26                	sd	s1,56(sp)
    80004c18:	f84a                	sd	s2,48(sp)
    80004c1a:	f44e                	sd	s3,40(sp)
    80004c1c:	f052                	sd	s4,32(sp)
    80004c1e:	ec56                	sd	s5,24(sp)
    80004c20:	e85a                	sd	s6,16(sp)
    80004c22:	e45e                	sd	s7,8(sp)
    80004c24:	e062                	sd	s8,0(sp)
    80004c26:	0880                	addi	s0,sp,80
    80004c28:	892a                	mv	s2,a0
    80004c2a:	8aae                	mv	s5,a1
    80004c2c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c2e:	411c                	lw	a5,0(a0)
    80004c30:	4705                	li	a4,1
    80004c32:	02e78263          	beq	a5,a4,80004c56 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c36:	470d                	li	a4,3
    80004c38:	02e78563          	beq	a5,a4,80004c62 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c3c:	4709                	li	a4,2
    80004c3e:	10e79463          	bne	a5,a4,80004d46 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c42:	0ec05e63          	blez	a2,80004d3e <filewrite+0x136>
    int i = 0;
    80004c46:	4981                	li	s3,0
    80004c48:	6b05                	lui	s6,0x1
    80004c4a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004c4e:	6b85                	lui	s7,0x1
    80004c50:	c00b8b9b          	addiw	s7,s7,-1024
    80004c54:	a851                	j	80004ce8 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004c56:	6908                	ld	a0,16(a0)
    80004c58:	00000097          	auipc	ra,0x0
    80004c5c:	25e080e7          	jalr	606(ra) # 80004eb6 <pipewrite>
    80004c60:	a85d                	j	80004d16 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c62:	02451783          	lh	a5,36(a0)
    80004c66:	03079693          	slli	a3,a5,0x30
    80004c6a:	92c1                	srli	a3,a3,0x30
    80004c6c:	4725                	li	a4,9
    80004c6e:	0ed76663          	bltu	a4,a3,80004d5a <filewrite+0x152>
    80004c72:	0792                	slli	a5,a5,0x4
    80004c74:	00024717          	auipc	a4,0x24
    80004c78:	9e470713          	addi	a4,a4,-1564 # 80028658 <devsw>
    80004c7c:	97ba                	add	a5,a5,a4
    80004c7e:	679c                	ld	a5,8(a5)
    80004c80:	cff9                	beqz	a5,80004d5e <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004c82:	4505                	li	a0,1
    80004c84:	9782                	jalr	a5
    80004c86:	a841                	j	80004d16 <filewrite+0x10e>
    80004c88:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c8c:	00000097          	auipc	ra,0x0
    80004c90:	8ac080e7          	jalr	-1876(ra) # 80004538 <begin_op>
      ilock(f->ip);
    80004c94:	01893503          	ld	a0,24(s2)
    80004c98:	fffff097          	auipc	ra,0xfffff
    80004c9c:	ed0080e7          	jalr	-304(ra) # 80003b68 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ca0:	8762                	mv	a4,s8
    80004ca2:	02092683          	lw	a3,32(s2)
    80004ca6:	01598633          	add	a2,s3,s5
    80004caa:	4585                	li	a1,1
    80004cac:	01893503          	ld	a0,24(s2)
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	264080e7          	jalr	612(ra) # 80003f14 <writei>
    80004cb8:	84aa                	mv	s1,a0
    80004cba:	02a05f63          	blez	a0,80004cf8 <filewrite+0xf0>
        f->off += r;
    80004cbe:	02092783          	lw	a5,32(s2)
    80004cc2:	9fa9                	addw	a5,a5,a0
    80004cc4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004cc8:	01893503          	ld	a0,24(s2)
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	f5e080e7          	jalr	-162(ra) # 80003c2a <iunlock>
      end_op();
    80004cd4:	00000097          	auipc	ra,0x0
    80004cd8:	8e4080e7          	jalr	-1820(ra) # 800045b8 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004cdc:	049c1963          	bne	s8,s1,80004d2e <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004ce0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ce4:	0349d663          	bge	s3,s4,80004d10 <filewrite+0x108>
      int n1 = n - i;
    80004ce8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004cec:	84be                	mv	s1,a5
    80004cee:	2781                	sext.w	a5,a5
    80004cf0:	f8fb5ce3          	bge	s6,a5,80004c88 <filewrite+0x80>
    80004cf4:	84de                	mv	s1,s7
    80004cf6:	bf49                	j	80004c88 <filewrite+0x80>
      iunlock(f->ip);
    80004cf8:	01893503          	ld	a0,24(s2)
    80004cfc:	fffff097          	auipc	ra,0xfffff
    80004d00:	f2e080e7          	jalr	-210(ra) # 80003c2a <iunlock>
      end_op();
    80004d04:	00000097          	auipc	ra,0x0
    80004d08:	8b4080e7          	jalr	-1868(ra) # 800045b8 <end_op>
      if(r < 0)
    80004d0c:	fc04d8e3          	bgez	s1,80004cdc <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004d10:	8552                	mv	a0,s4
    80004d12:	033a1863          	bne	s4,s3,80004d42 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d16:	60a6                	ld	ra,72(sp)
    80004d18:	6406                	ld	s0,64(sp)
    80004d1a:	74e2                	ld	s1,56(sp)
    80004d1c:	7942                	ld	s2,48(sp)
    80004d1e:	79a2                	ld	s3,40(sp)
    80004d20:	7a02                	ld	s4,32(sp)
    80004d22:	6ae2                	ld	s5,24(sp)
    80004d24:	6b42                	ld	s6,16(sp)
    80004d26:	6ba2                	ld	s7,8(sp)
    80004d28:	6c02                	ld	s8,0(sp)
    80004d2a:	6161                	addi	sp,sp,80
    80004d2c:	8082                	ret
        panic("short filewrite");
    80004d2e:	00004517          	auipc	a0,0x4
    80004d32:	a0250513          	addi	a0,a0,-1534 # 80008730 <syscalls+0x270>
    80004d36:	ffffc097          	auipc	ra,0xffffc
    80004d3a:	81a080e7          	jalr	-2022(ra) # 80000550 <panic>
    int i = 0;
    80004d3e:	4981                	li	s3,0
    80004d40:	bfc1                	j	80004d10 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004d42:	557d                	li	a0,-1
    80004d44:	bfc9                	j	80004d16 <filewrite+0x10e>
    panic("filewrite");
    80004d46:	00004517          	auipc	a0,0x4
    80004d4a:	9fa50513          	addi	a0,a0,-1542 # 80008740 <syscalls+0x280>
    80004d4e:	ffffc097          	auipc	ra,0xffffc
    80004d52:	802080e7          	jalr	-2046(ra) # 80000550 <panic>
    return -1;
    80004d56:	557d                	li	a0,-1
}
    80004d58:	8082                	ret
      return -1;
    80004d5a:	557d                	li	a0,-1
    80004d5c:	bf6d                	j	80004d16 <filewrite+0x10e>
    80004d5e:	557d                	li	a0,-1
    80004d60:	bf5d                	j	80004d16 <filewrite+0x10e>

0000000080004d62 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d62:	7179                	addi	sp,sp,-48
    80004d64:	f406                	sd	ra,40(sp)
    80004d66:	f022                	sd	s0,32(sp)
    80004d68:	ec26                	sd	s1,24(sp)
    80004d6a:	e84a                	sd	s2,16(sp)
    80004d6c:	e44e                	sd	s3,8(sp)
    80004d6e:	e052                	sd	s4,0(sp)
    80004d70:	1800                	addi	s0,sp,48
    80004d72:	84aa                	mv	s1,a0
    80004d74:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d76:	0005b023          	sd	zero,0(a1)
    80004d7a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d7e:	00000097          	auipc	ra,0x0
    80004d82:	bd2080e7          	jalr	-1070(ra) # 80004950 <filealloc>
    80004d86:	e088                	sd	a0,0(s1)
    80004d88:	c551                	beqz	a0,80004e14 <pipealloc+0xb2>
    80004d8a:	00000097          	auipc	ra,0x0
    80004d8e:	bc6080e7          	jalr	-1082(ra) # 80004950 <filealloc>
    80004d92:	00aa3023          	sd	a0,0(s4)
    80004d96:	c92d                	beqz	a0,80004e08 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	dfa080e7          	jalr	-518(ra) # 80000b92 <kalloc>
    80004da0:	892a                	mv	s2,a0
    80004da2:	c125                	beqz	a0,80004e02 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004da4:	4985                	li	s3,1
    80004da6:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004daa:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004dae:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004db2:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004db6:	00004597          	auipc	a1,0x4
    80004dba:	99a58593          	addi	a1,a1,-1638 # 80008750 <syscalls+0x290>
    80004dbe:	ffffc097          	auipc	ra,0xffffc
    80004dc2:	12c080e7          	jalr	300(ra) # 80000eea <initlock>
  (*f0)->type = FD_PIPE;
    80004dc6:	609c                	ld	a5,0(s1)
    80004dc8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004dcc:	609c                	ld	a5,0(s1)
    80004dce:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004dd2:	609c                	ld	a5,0(s1)
    80004dd4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004dd8:	609c                	ld	a5,0(s1)
    80004dda:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004dde:	000a3783          	ld	a5,0(s4)
    80004de2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004de6:	000a3783          	ld	a5,0(s4)
    80004dea:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004dee:	000a3783          	ld	a5,0(s4)
    80004df2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004df6:	000a3783          	ld	a5,0(s4)
    80004dfa:	0127b823          	sd	s2,16(a5)
  return 0;
    80004dfe:	4501                	li	a0,0
    80004e00:	a025                	j	80004e28 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e02:	6088                	ld	a0,0(s1)
    80004e04:	e501                	bnez	a0,80004e0c <pipealloc+0xaa>
    80004e06:	a039                	j	80004e14 <pipealloc+0xb2>
    80004e08:	6088                	ld	a0,0(s1)
    80004e0a:	c51d                	beqz	a0,80004e38 <pipealloc+0xd6>
    fileclose(*f0);
    80004e0c:	00000097          	auipc	ra,0x0
    80004e10:	c00080e7          	jalr	-1024(ra) # 80004a0c <fileclose>
  if(*f1)
    80004e14:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e18:	557d                	li	a0,-1
  if(*f1)
    80004e1a:	c799                	beqz	a5,80004e28 <pipealloc+0xc6>
    fileclose(*f1);
    80004e1c:	853e                	mv	a0,a5
    80004e1e:	00000097          	auipc	ra,0x0
    80004e22:	bee080e7          	jalr	-1042(ra) # 80004a0c <fileclose>
  return -1;
    80004e26:	557d                	li	a0,-1
}
    80004e28:	70a2                	ld	ra,40(sp)
    80004e2a:	7402                	ld	s0,32(sp)
    80004e2c:	64e2                	ld	s1,24(sp)
    80004e2e:	6942                	ld	s2,16(sp)
    80004e30:	69a2                	ld	s3,8(sp)
    80004e32:	6a02                	ld	s4,0(sp)
    80004e34:	6145                	addi	sp,sp,48
    80004e36:	8082                	ret
  return -1;
    80004e38:	557d                	li	a0,-1
    80004e3a:	b7fd                	j	80004e28 <pipealloc+0xc6>

0000000080004e3c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e3c:	1101                	addi	sp,sp,-32
    80004e3e:	ec06                	sd	ra,24(sp)
    80004e40:	e822                	sd	s0,16(sp)
    80004e42:	e426                	sd	s1,8(sp)
    80004e44:	e04a                	sd	s2,0(sp)
    80004e46:	1000                	addi	s0,sp,32
    80004e48:	84aa                	mv	s1,a0
    80004e4a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e4c:	ffffc097          	auipc	ra,0xffffc
    80004e50:	f22080e7          	jalr	-222(ra) # 80000d6e <acquire>
  if(writable){
    80004e54:	04090263          	beqz	s2,80004e98 <pipeclose+0x5c>
    pi->writeopen = 0;
    80004e58:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004e5c:	22048513          	addi	a0,s1,544
    80004e60:	ffffe097          	auipc	ra,0xffffe
    80004e64:	8ec080e7          	jalr	-1812(ra) # 8000274c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e68:	2284b783          	ld	a5,552(s1)
    80004e6c:	ef9d                	bnez	a5,80004eaa <pipeclose+0x6e>
    release(&pi->lock);
    80004e6e:	8526                	mv	a0,s1
    80004e70:	ffffc097          	auipc	ra,0xffffc
    80004e74:	fce080e7          	jalr	-50(ra) # 80000e3e <release>
#ifdef LAB_LOCK
    freelock(&pi->lock);
    80004e78:	8526                	mv	a0,s1
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	00c080e7          	jalr	12(ra) # 80000e86 <freelock>
#endif    
    kfree((char*)pi);
    80004e82:	8526                	mv	a0,s1
    80004e84:	ffffc097          	auipc	ra,0xffffc
    80004e88:	ba8080e7          	jalr	-1112(ra) # 80000a2c <kfree>
  } else
    release(&pi->lock);
}
    80004e8c:	60e2                	ld	ra,24(sp)
    80004e8e:	6442                	ld	s0,16(sp)
    80004e90:	64a2                	ld	s1,8(sp)
    80004e92:	6902                	ld	s2,0(sp)
    80004e94:	6105                	addi	sp,sp,32
    80004e96:	8082                	ret
    pi->readopen = 0;
    80004e98:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004e9c:	22448513          	addi	a0,s1,548
    80004ea0:	ffffe097          	auipc	ra,0xffffe
    80004ea4:	8ac080e7          	jalr	-1876(ra) # 8000274c <wakeup>
    80004ea8:	b7c1                	j	80004e68 <pipeclose+0x2c>
    release(&pi->lock);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	ffffc097          	auipc	ra,0xffffc
    80004eb0:	f92080e7          	jalr	-110(ra) # 80000e3e <release>
}
    80004eb4:	bfe1                	j	80004e8c <pipeclose+0x50>

0000000080004eb6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004eb6:	7119                	addi	sp,sp,-128
    80004eb8:	fc86                	sd	ra,120(sp)
    80004eba:	f8a2                	sd	s0,112(sp)
    80004ebc:	f4a6                	sd	s1,104(sp)
    80004ebe:	f0ca                	sd	s2,96(sp)
    80004ec0:	ecce                	sd	s3,88(sp)
    80004ec2:	e8d2                	sd	s4,80(sp)
    80004ec4:	e4d6                	sd	s5,72(sp)
    80004ec6:	e0da                	sd	s6,64(sp)
    80004ec8:	fc5e                	sd	s7,56(sp)
    80004eca:	f862                	sd	s8,48(sp)
    80004ecc:	f466                	sd	s9,40(sp)
    80004ece:	f06a                	sd	s10,32(sp)
    80004ed0:	ec6e                	sd	s11,24(sp)
    80004ed2:	0100                	addi	s0,sp,128
    80004ed4:	84aa                	mv	s1,a0
    80004ed6:	8cae                	mv	s9,a1
    80004ed8:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004eda:	ffffd097          	auipc	ra,0xffffd
    80004ede:	edc080e7          	jalr	-292(ra) # 80001db6 <myproc>
    80004ee2:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004ee4:	8526                	mv	a0,s1
    80004ee6:	ffffc097          	auipc	ra,0xffffc
    80004eea:	e88080e7          	jalr	-376(ra) # 80000d6e <acquire>
  for(i = 0; i < n; i++){
    80004eee:	0d605963          	blez	s6,80004fc0 <pipewrite+0x10a>
    80004ef2:	89a6                	mv	s3,s1
    80004ef4:	3b7d                	addiw	s6,s6,-1
    80004ef6:	1b02                	slli	s6,s6,0x20
    80004ef8:	020b5b13          	srli	s6,s6,0x20
    80004efc:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004efe:	22048a93          	addi	s5,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004f02:	22448a13          	addi	s4,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f06:	5dfd                	li	s11,-1
    80004f08:	000b8d1b          	sext.w	s10,s7
    80004f0c:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004f0e:	2204a783          	lw	a5,544(s1)
    80004f12:	2244a703          	lw	a4,548(s1)
    80004f16:	2007879b          	addiw	a5,a5,512
    80004f1a:	02f71b63          	bne	a4,a5,80004f50 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004f1e:	2284a783          	lw	a5,552(s1)
    80004f22:	cbad                	beqz	a5,80004f94 <pipewrite+0xde>
    80004f24:	03892783          	lw	a5,56(s2)
    80004f28:	e7b5                	bnez	a5,80004f94 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004f2a:	8556                	mv	a0,s5
    80004f2c:	ffffe097          	auipc	ra,0xffffe
    80004f30:	820080e7          	jalr	-2016(ra) # 8000274c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f34:	85ce                	mv	a1,s3
    80004f36:	8552                	mv	a0,s4
    80004f38:	ffffd097          	auipc	ra,0xffffd
    80004f3c:	68e080e7          	jalr	1678(ra) # 800025c6 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004f40:	2204a783          	lw	a5,544(s1)
    80004f44:	2244a703          	lw	a4,548(s1)
    80004f48:	2007879b          	addiw	a5,a5,512
    80004f4c:	fcf709e3          	beq	a4,a5,80004f1e <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f50:	4685                	li	a3,1
    80004f52:	019b8633          	add	a2,s7,s9
    80004f56:	f8f40593          	addi	a1,s0,-113
    80004f5a:	05893503          	ld	a0,88(s2)
    80004f5e:	ffffd097          	auipc	ra,0xffffd
    80004f62:	bd8080e7          	jalr	-1064(ra) # 80001b36 <copyin>
    80004f66:	05b50e63          	beq	a0,s11,80004fc2 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f6a:	2244a783          	lw	a5,548(s1)
    80004f6e:	0017871b          	addiw	a4,a5,1
    80004f72:	22e4a223          	sw	a4,548(s1)
    80004f76:	1ff7f793          	andi	a5,a5,511
    80004f7a:	97a6                	add	a5,a5,s1
    80004f7c:	f8f44703          	lbu	a4,-113(s0)
    80004f80:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004f84:	001d0c1b          	addiw	s8,s10,1
    80004f88:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004f8c:	036b8b63          	beq	s7,s6,80004fc2 <pipewrite+0x10c>
    80004f90:	8bbe                	mv	s7,a5
    80004f92:	bf9d                	j	80004f08 <pipewrite+0x52>
        release(&pi->lock);
    80004f94:	8526                	mv	a0,s1
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	ea8080e7          	jalr	-344(ra) # 80000e3e <release>
        return -1;
    80004f9e:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004fa0:	8562                	mv	a0,s8
    80004fa2:	70e6                	ld	ra,120(sp)
    80004fa4:	7446                	ld	s0,112(sp)
    80004fa6:	74a6                	ld	s1,104(sp)
    80004fa8:	7906                	ld	s2,96(sp)
    80004faa:	69e6                	ld	s3,88(sp)
    80004fac:	6a46                	ld	s4,80(sp)
    80004fae:	6aa6                	ld	s5,72(sp)
    80004fb0:	6b06                	ld	s6,64(sp)
    80004fb2:	7be2                	ld	s7,56(sp)
    80004fb4:	7c42                	ld	s8,48(sp)
    80004fb6:	7ca2                	ld	s9,40(sp)
    80004fb8:	7d02                	ld	s10,32(sp)
    80004fba:	6de2                	ld	s11,24(sp)
    80004fbc:	6109                	addi	sp,sp,128
    80004fbe:	8082                	ret
  for(i = 0; i < n; i++){
    80004fc0:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004fc2:	22048513          	addi	a0,s1,544
    80004fc6:	ffffd097          	auipc	ra,0xffffd
    80004fca:	786080e7          	jalr	1926(ra) # 8000274c <wakeup>
  release(&pi->lock);
    80004fce:	8526                	mv	a0,s1
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	e6e080e7          	jalr	-402(ra) # 80000e3e <release>
  return i;
    80004fd8:	b7e1                	j	80004fa0 <pipewrite+0xea>

0000000080004fda <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004fda:	715d                	addi	sp,sp,-80
    80004fdc:	e486                	sd	ra,72(sp)
    80004fde:	e0a2                	sd	s0,64(sp)
    80004fe0:	fc26                	sd	s1,56(sp)
    80004fe2:	f84a                	sd	s2,48(sp)
    80004fe4:	f44e                	sd	s3,40(sp)
    80004fe6:	f052                	sd	s4,32(sp)
    80004fe8:	ec56                	sd	s5,24(sp)
    80004fea:	e85a                	sd	s6,16(sp)
    80004fec:	0880                	addi	s0,sp,80
    80004fee:	84aa                	mv	s1,a0
    80004ff0:	892e                	mv	s2,a1
    80004ff2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	dc2080e7          	jalr	-574(ra) # 80001db6 <myproc>
    80004ffc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ffe:	8b26                	mv	s6,s1
    80005000:	8526                	mv	a0,s1
    80005002:	ffffc097          	auipc	ra,0xffffc
    80005006:	d6c080e7          	jalr	-660(ra) # 80000d6e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000500a:	2204a703          	lw	a4,544(s1)
    8000500e:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005012:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005016:	02f71463          	bne	a4,a5,8000503e <piperead+0x64>
    8000501a:	22c4a783          	lw	a5,556(s1)
    8000501e:	c385                	beqz	a5,8000503e <piperead+0x64>
    if(pr->killed){
    80005020:	038a2783          	lw	a5,56(s4)
    80005024:	ebc1                	bnez	a5,800050b4 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005026:	85da                	mv	a1,s6
    80005028:	854e                	mv	a0,s3
    8000502a:	ffffd097          	auipc	ra,0xffffd
    8000502e:	59c080e7          	jalr	1436(ra) # 800025c6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005032:	2204a703          	lw	a4,544(s1)
    80005036:	2244a783          	lw	a5,548(s1)
    8000503a:	fef700e3          	beq	a4,a5,8000501a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000503e:	09505263          	blez	s5,800050c2 <piperead+0xe8>
    80005042:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005044:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005046:	2204a783          	lw	a5,544(s1)
    8000504a:	2244a703          	lw	a4,548(s1)
    8000504e:	02f70d63          	beq	a4,a5,80005088 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005052:	0017871b          	addiw	a4,a5,1
    80005056:	22e4a023          	sw	a4,544(s1)
    8000505a:	1ff7f793          	andi	a5,a5,511
    8000505e:	97a6                	add	a5,a5,s1
    80005060:	0207c783          	lbu	a5,32(a5)
    80005064:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005068:	4685                	li	a3,1
    8000506a:	fbf40613          	addi	a2,s0,-65
    8000506e:	85ca                	mv	a1,s2
    80005070:	058a3503          	ld	a0,88(s4)
    80005074:	ffffd097          	auipc	ra,0xffffd
    80005078:	a36080e7          	jalr	-1482(ra) # 80001aaa <copyout>
    8000507c:	01650663          	beq	a0,s6,80005088 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005080:	2985                	addiw	s3,s3,1
    80005082:	0905                	addi	s2,s2,1
    80005084:	fd3a91e3          	bne	s5,s3,80005046 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005088:	22448513          	addi	a0,s1,548
    8000508c:	ffffd097          	auipc	ra,0xffffd
    80005090:	6c0080e7          	jalr	1728(ra) # 8000274c <wakeup>
  release(&pi->lock);
    80005094:	8526                	mv	a0,s1
    80005096:	ffffc097          	auipc	ra,0xffffc
    8000509a:	da8080e7          	jalr	-600(ra) # 80000e3e <release>
  return i;
}
    8000509e:	854e                	mv	a0,s3
    800050a0:	60a6                	ld	ra,72(sp)
    800050a2:	6406                	ld	s0,64(sp)
    800050a4:	74e2                	ld	s1,56(sp)
    800050a6:	7942                	ld	s2,48(sp)
    800050a8:	79a2                	ld	s3,40(sp)
    800050aa:	7a02                	ld	s4,32(sp)
    800050ac:	6ae2                	ld	s5,24(sp)
    800050ae:	6b42                	ld	s6,16(sp)
    800050b0:	6161                	addi	sp,sp,80
    800050b2:	8082                	ret
      release(&pi->lock);
    800050b4:	8526                	mv	a0,s1
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	d88080e7          	jalr	-632(ra) # 80000e3e <release>
      return -1;
    800050be:	59fd                	li	s3,-1
    800050c0:	bff9                	j	8000509e <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050c2:	4981                	li	s3,0
    800050c4:	b7d1                	j	80005088 <piperead+0xae>

00000000800050c6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800050c6:	df010113          	addi	sp,sp,-528
    800050ca:	20113423          	sd	ra,520(sp)
    800050ce:	20813023          	sd	s0,512(sp)
    800050d2:	ffa6                	sd	s1,504(sp)
    800050d4:	fbca                	sd	s2,496(sp)
    800050d6:	f7ce                	sd	s3,488(sp)
    800050d8:	f3d2                	sd	s4,480(sp)
    800050da:	efd6                	sd	s5,472(sp)
    800050dc:	ebda                	sd	s6,464(sp)
    800050de:	e7de                	sd	s7,456(sp)
    800050e0:	e3e2                	sd	s8,448(sp)
    800050e2:	ff66                	sd	s9,440(sp)
    800050e4:	fb6a                	sd	s10,432(sp)
    800050e6:	f76e                	sd	s11,424(sp)
    800050e8:	0c00                	addi	s0,sp,528
    800050ea:	84aa                	mv	s1,a0
    800050ec:	dea43c23          	sd	a0,-520(s0)
    800050f0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800050f4:	ffffd097          	auipc	ra,0xffffd
    800050f8:	cc2080e7          	jalr	-830(ra) # 80001db6 <myproc>
    800050fc:	892a                	mv	s2,a0

  begin_op();
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	43a080e7          	jalr	1082(ra) # 80004538 <begin_op>

  if((ip = namei(path)) == 0){
    80005106:	8526                	mv	a0,s1
    80005108:	fffff097          	auipc	ra,0xfffff
    8000510c:	214080e7          	jalr	532(ra) # 8000431c <namei>
    80005110:	c92d                	beqz	a0,80005182 <exec+0xbc>
    80005112:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005114:	fffff097          	auipc	ra,0xfffff
    80005118:	a54080e7          	jalr	-1452(ra) # 80003b68 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000511c:	04000713          	li	a4,64
    80005120:	4681                	li	a3,0
    80005122:	e4840613          	addi	a2,s0,-440
    80005126:	4581                	li	a1,0
    80005128:	8526                	mv	a0,s1
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	cf2080e7          	jalr	-782(ra) # 80003e1c <readi>
    80005132:	04000793          	li	a5,64
    80005136:	00f51a63          	bne	a0,a5,8000514a <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000513a:	e4842703          	lw	a4,-440(s0)
    8000513e:	464c47b7          	lui	a5,0x464c4
    80005142:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005146:	04f70463          	beq	a4,a5,8000518e <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000514a:	8526                	mv	a0,s1
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	c7e080e7          	jalr	-898(ra) # 80003dca <iunlockput>
    end_op();
    80005154:	fffff097          	auipc	ra,0xfffff
    80005158:	464080e7          	jalr	1124(ra) # 800045b8 <end_op>
  }
  return -1;
    8000515c:	557d                	li	a0,-1
}
    8000515e:	20813083          	ld	ra,520(sp)
    80005162:	20013403          	ld	s0,512(sp)
    80005166:	74fe                	ld	s1,504(sp)
    80005168:	795e                	ld	s2,496(sp)
    8000516a:	79be                	ld	s3,488(sp)
    8000516c:	7a1e                	ld	s4,480(sp)
    8000516e:	6afe                	ld	s5,472(sp)
    80005170:	6b5e                	ld	s6,464(sp)
    80005172:	6bbe                	ld	s7,456(sp)
    80005174:	6c1e                	ld	s8,448(sp)
    80005176:	7cfa                	ld	s9,440(sp)
    80005178:	7d5a                	ld	s10,432(sp)
    8000517a:	7dba                	ld	s11,424(sp)
    8000517c:	21010113          	addi	sp,sp,528
    80005180:	8082                	ret
    end_op();
    80005182:	fffff097          	auipc	ra,0xfffff
    80005186:	436080e7          	jalr	1078(ra) # 800045b8 <end_op>
    return -1;
    8000518a:	557d                	li	a0,-1
    8000518c:	bfc9                	j	8000515e <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000518e:	854a                	mv	a0,s2
    80005190:	ffffd097          	auipc	ra,0xffffd
    80005194:	cea080e7          	jalr	-790(ra) # 80001e7a <proc_pagetable>
    80005198:	8baa                	mv	s7,a0
    8000519a:	d945                	beqz	a0,8000514a <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000519c:	e6842983          	lw	s3,-408(s0)
    800051a0:	e8045783          	lhu	a5,-384(s0)
    800051a4:	c7ad                	beqz	a5,8000520e <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800051a6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051a8:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800051aa:	6c85                	lui	s9,0x1
    800051ac:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800051b0:	def43823          	sd	a5,-528(s0)
    800051b4:	a42d                	j	800053de <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051b6:	00003517          	auipc	a0,0x3
    800051ba:	5a250513          	addi	a0,a0,1442 # 80008758 <syscalls+0x298>
    800051be:	ffffb097          	auipc	ra,0xffffb
    800051c2:	392080e7          	jalr	914(ra) # 80000550 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051c6:	8756                	mv	a4,s5
    800051c8:	012d86bb          	addw	a3,s11,s2
    800051cc:	4581                	li	a1,0
    800051ce:	8526                	mv	a0,s1
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	c4c080e7          	jalr	-948(ra) # 80003e1c <readi>
    800051d8:	2501                	sext.w	a0,a0
    800051da:	1aaa9963          	bne	s5,a0,8000538c <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    800051de:	6785                	lui	a5,0x1
    800051e0:	0127893b          	addw	s2,a5,s2
    800051e4:	77fd                	lui	a5,0xfffff
    800051e6:	01478a3b          	addw	s4,a5,s4
    800051ea:	1f897163          	bgeu	s2,s8,800053cc <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    800051ee:	02091593          	slli	a1,s2,0x20
    800051f2:	9181                	srli	a1,a1,0x20
    800051f4:	95ea                	add	a1,a1,s10
    800051f6:	855e                	mv	a0,s7
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	2f0080e7          	jalr	752(ra) # 800014e8 <walkaddr>
    80005200:	862a                	mv	a2,a0
    if(pa == 0)
    80005202:	d955                	beqz	a0,800051b6 <exec+0xf0>
      n = PGSIZE;
    80005204:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005206:	fd9a70e3          	bgeu	s4,s9,800051c6 <exec+0x100>
      n = sz - i;
    8000520a:	8ad2                	mv	s5,s4
    8000520c:	bf6d                	j	800051c6 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000520e:	4901                	li	s2,0
  iunlockput(ip);
    80005210:	8526                	mv	a0,s1
    80005212:	fffff097          	auipc	ra,0xfffff
    80005216:	bb8080e7          	jalr	-1096(ra) # 80003dca <iunlockput>
  end_op();
    8000521a:	fffff097          	auipc	ra,0xfffff
    8000521e:	39e080e7          	jalr	926(ra) # 800045b8 <end_op>
  p = myproc();
    80005222:	ffffd097          	auipc	ra,0xffffd
    80005226:	b94080e7          	jalr	-1132(ra) # 80001db6 <myproc>
    8000522a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000522c:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005230:	6785                	lui	a5,0x1
    80005232:	17fd                	addi	a5,a5,-1
    80005234:	993e                	add	s2,s2,a5
    80005236:	757d                	lui	a0,0xfffff
    80005238:	00a977b3          	and	a5,s2,a0
    8000523c:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005240:	6609                	lui	a2,0x2
    80005242:	963e                	add	a2,a2,a5
    80005244:	85be                	mv	a1,a5
    80005246:	855e                	mv	a0,s7
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	612080e7          	jalr	1554(ra) # 8000185a <uvmalloc>
    80005250:	8b2a                	mv	s6,a0
  ip = 0;
    80005252:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005254:	12050c63          	beqz	a0,8000538c <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005258:	75f9                	lui	a1,0xffffe
    8000525a:	95aa                	add	a1,a1,a0
    8000525c:	855e                	mv	a0,s7
    8000525e:	ffffd097          	auipc	ra,0xffffd
    80005262:	81a080e7          	jalr	-2022(ra) # 80001a78 <uvmclear>
  stackbase = sp - PGSIZE;
    80005266:	7c7d                	lui	s8,0xfffff
    80005268:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000526a:	e0043783          	ld	a5,-512(s0)
    8000526e:	6388                	ld	a0,0(a5)
    80005270:	c535                	beqz	a0,800052dc <exec+0x216>
    80005272:	e8840993          	addi	s3,s0,-376
    80005276:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    8000527a:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000527c:	ffffc097          	auipc	ra,0xffffc
    80005280:	05a080e7          	jalr	90(ra) # 800012d6 <strlen>
    80005284:	2505                	addiw	a0,a0,1
    80005286:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000528a:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000528e:	13896363          	bltu	s2,s8,800053b4 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005292:	e0043d83          	ld	s11,-512(s0)
    80005296:	000dba03          	ld	s4,0(s11)
    8000529a:	8552                	mv	a0,s4
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	03a080e7          	jalr	58(ra) # 800012d6 <strlen>
    800052a4:	0015069b          	addiw	a3,a0,1
    800052a8:	8652                	mv	a2,s4
    800052aa:	85ca                	mv	a1,s2
    800052ac:	855e                	mv	a0,s7
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	7fc080e7          	jalr	2044(ra) # 80001aaa <copyout>
    800052b6:	10054363          	bltz	a0,800053bc <exec+0x2f6>
    ustack[argc] = sp;
    800052ba:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052be:	0485                	addi	s1,s1,1
    800052c0:	008d8793          	addi	a5,s11,8
    800052c4:	e0f43023          	sd	a5,-512(s0)
    800052c8:	008db503          	ld	a0,8(s11)
    800052cc:	c911                	beqz	a0,800052e0 <exec+0x21a>
    if(argc >= MAXARG)
    800052ce:	09a1                	addi	s3,s3,8
    800052d0:	fb3c96e3          	bne	s9,s3,8000527c <exec+0x1b6>
  sz = sz1;
    800052d4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052d8:	4481                	li	s1,0
    800052da:	a84d                	j	8000538c <exec+0x2c6>
  sp = sz;
    800052dc:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800052de:	4481                	li	s1,0
  ustack[argc] = 0;
    800052e0:	00349793          	slli	a5,s1,0x3
    800052e4:	f9040713          	addi	a4,s0,-112
    800052e8:	97ba                	add	a5,a5,a4
    800052ea:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    800052ee:	00148693          	addi	a3,s1,1
    800052f2:	068e                	slli	a3,a3,0x3
    800052f4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800052f8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800052fc:	01897663          	bgeu	s2,s8,80005308 <exec+0x242>
  sz = sz1;
    80005300:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005304:	4481                	li	s1,0
    80005306:	a059                	j	8000538c <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005308:	e8840613          	addi	a2,s0,-376
    8000530c:	85ca                	mv	a1,s2
    8000530e:	855e                	mv	a0,s7
    80005310:	ffffc097          	auipc	ra,0xffffc
    80005314:	79a080e7          	jalr	1946(ra) # 80001aaa <copyout>
    80005318:	0a054663          	bltz	a0,800053c4 <exec+0x2fe>
  p->trapframe->a1 = sp;
    8000531c:	060ab783          	ld	a5,96(s5)
    80005320:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005324:	df843783          	ld	a5,-520(s0)
    80005328:	0007c703          	lbu	a4,0(a5)
    8000532c:	cf11                	beqz	a4,80005348 <exec+0x282>
    8000532e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005330:	02f00693          	li	a3,47
    80005334:	a029                	j	8000533e <exec+0x278>
  for(last=s=path; *s; s++)
    80005336:	0785                	addi	a5,a5,1
    80005338:	fff7c703          	lbu	a4,-1(a5)
    8000533c:	c711                	beqz	a4,80005348 <exec+0x282>
    if(*s == '/')
    8000533e:	fed71ce3          	bne	a4,a3,80005336 <exec+0x270>
      last = s+1;
    80005342:	def43c23          	sd	a5,-520(s0)
    80005346:	bfc5                	j	80005336 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80005348:	4641                	li	a2,16
    8000534a:	df843583          	ld	a1,-520(s0)
    8000534e:	160a8513          	addi	a0,s5,352
    80005352:	ffffc097          	auipc	ra,0xffffc
    80005356:	f52080e7          	jalr	-174(ra) # 800012a4 <safestrcpy>
  oldpagetable = p->pagetable;
    8000535a:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    8000535e:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80005362:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005366:	060ab783          	ld	a5,96(s5)
    8000536a:	e6043703          	ld	a4,-416(s0)
    8000536e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005370:	060ab783          	ld	a5,96(s5)
    80005374:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005378:	85ea                	mv	a1,s10
    8000537a:	ffffd097          	auipc	ra,0xffffd
    8000537e:	b9c080e7          	jalr	-1124(ra) # 80001f16 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005382:	0004851b          	sext.w	a0,s1
    80005386:	bbe1                	j	8000515e <exec+0x98>
    80005388:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000538c:	e0843583          	ld	a1,-504(s0)
    80005390:	855e                	mv	a0,s7
    80005392:	ffffd097          	auipc	ra,0xffffd
    80005396:	b84080e7          	jalr	-1148(ra) # 80001f16 <proc_freepagetable>
  if(ip){
    8000539a:	da0498e3          	bnez	s1,8000514a <exec+0x84>
  return -1;
    8000539e:	557d                	li	a0,-1
    800053a0:	bb7d                	j	8000515e <exec+0x98>
    800053a2:	e1243423          	sd	s2,-504(s0)
    800053a6:	b7dd                	j	8000538c <exec+0x2c6>
    800053a8:	e1243423          	sd	s2,-504(s0)
    800053ac:	b7c5                	j	8000538c <exec+0x2c6>
    800053ae:	e1243423          	sd	s2,-504(s0)
    800053b2:	bfe9                	j	8000538c <exec+0x2c6>
  sz = sz1;
    800053b4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800053b8:	4481                	li	s1,0
    800053ba:	bfc9                	j	8000538c <exec+0x2c6>
  sz = sz1;
    800053bc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800053c0:	4481                	li	s1,0
    800053c2:	b7e9                	j	8000538c <exec+0x2c6>
  sz = sz1;
    800053c4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800053c8:	4481                	li	s1,0
    800053ca:	b7c9                	j	8000538c <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800053cc:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053d0:	2b05                	addiw	s6,s6,1
    800053d2:	0389899b          	addiw	s3,s3,56
    800053d6:	e8045783          	lhu	a5,-384(s0)
    800053da:	e2fb5be3          	bge	s6,a5,80005210 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053de:	2981                	sext.w	s3,s3
    800053e0:	03800713          	li	a4,56
    800053e4:	86ce                	mv	a3,s3
    800053e6:	e1040613          	addi	a2,s0,-496
    800053ea:	4581                	li	a1,0
    800053ec:	8526                	mv	a0,s1
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	a2e080e7          	jalr	-1490(ra) # 80003e1c <readi>
    800053f6:	03800793          	li	a5,56
    800053fa:	f8f517e3          	bne	a0,a5,80005388 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800053fe:	e1042783          	lw	a5,-496(s0)
    80005402:	4705                	li	a4,1
    80005404:	fce796e3          	bne	a5,a4,800053d0 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005408:	e3843603          	ld	a2,-456(s0)
    8000540c:	e3043783          	ld	a5,-464(s0)
    80005410:	f8f669e3          	bltu	a2,a5,800053a2 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005414:	e2043783          	ld	a5,-480(s0)
    80005418:	963e                	add	a2,a2,a5
    8000541a:	f8f667e3          	bltu	a2,a5,800053a8 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000541e:	85ca                	mv	a1,s2
    80005420:	855e                	mv	a0,s7
    80005422:	ffffc097          	auipc	ra,0xffffc
    80005426:	438080e7          	jalr	1080(ra) # 8000185a <uvmalloc>
    8000542a:	e0a43423          	sd	a0,-504(s0)
    8000542e:	d141                	beqz	a0,800053ae <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80005430:	e2043d03          	ld	s10,-480(s0)
    80005434:	df043783          	ld	a5,-528(s0)
    80005438:	00fd77b3          	and	a5,s10,a5
    8000543c:	fba1                	bnez	a5,8000538c <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000543e:	e1842d83          	lw	s11,-488(s0)
    80005442:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005446:	f80c03e3          	beqz	s8,800053cc <exec+0x306>
    8000544a:	8a62                	mv	s4,s8
    8000544c:	4901                	li	s2,0
    8000544e:	b345                	j	800051ee <exec+0x128>

0000000080005450 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005450:	7179                	addi	sp,sp,-48
    80005452:	f406                	sd	ra,40(sp)
    80005454:	f022                	sd	s0,32(sp)
    80005456:	ec26                	sd	s1,24(sp)
    80005458:	e84a                	sd	s2,16(sp)
    8000545a:	1800                	addi	s0,sp,48
    8000545c:	892e                	mv	s2,a1
    8000545e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005460:	fdc40593          	addi	a1,s0,-36
    80005464:	ffffe097          	auipc	ra,0xffffe
    80005468:	a10080e7          	jalr	-1520(ra) # 80002e74 <argint>
    8000546c:	04054063          	bltz	a0,800054ac <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005470:	fdc42703          	lw	a4,-36(s0)
    80005474:	47bd                	li	a5,15
    80005476:	02e7ed63          	bltu	a5,a4,800054b0 <argfd+0x60>
    8000547a:	ffffd097          	auipc	ra,0xffffd
    8000547e:	93c080e7          	jalr	-1732(ra) # 80001db6 <myproc>
    80005482:	fdc42703          	lw	a4,-36(s0)
    80005486:	01a70793          	addi	a5,a4,26
    8000548a:	078e                	slli	a5,a5,0x3
    8000548c:	953e                	add	a0,a0,a5
    8000548e:	651c                	ld	a5,8(a0)
    80005490:	c395                	beqz	a5,800054b4 <argfd+0x64>
    return -1;
  if(pfd)
    80005492:	00090463          	beqz	s2,8000549a <argfd+0x4a>
    *pfd = fd;
    80005496:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000549a:	4501                	li	a0,0
  if(pf)
    8000549c:	c091                	beqz	s1,800054a0 <argfd+0x50>
    *pf = f;
    8000549e:	e09c                	sd	a5,0(s1)
}
    800054a0:	70a2                	ld	ra,40(sp)
    800054a2:	7402                	ld	s0,32(sp)
    800054a4:	64e2                	ld	s1,24(sp)
    800054a6:	6942                	ld	s2,16(sp)
    800054a8:	6145                	addi	sp,sp,48
    800054aa:	8082                	ret
    return -1;
    800054ac:	557d                	li	a0,-1
    800054ae:	bfcd                	j	800054a0 <argfd+0x50>
    return -1;
    800054b0:	557d                	li	a0,-1
    800054b2:	b7fd                	j	800054a0 <argfd+0x50>
    800054b4:	557d                	li	a0,-1
    800054b6:	b7ed                	j	800054a0 <argfd+0x50>

00000000800054b8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800054b8:	1101                	addi	sp,sp,-32
    800054ba:	ec06                	sd	ra,24(sp)
    800054bc:	e822                	sd	s0,16(sp)
    800054be:	e426                	sd	s1,8(sp)
    800054c0:	1000                	addi	s0,sp,32
    800054c2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800054c4:	ffffd097          	auipc	ra,0xffffd
    800054c8:	8f2080e7          	jalr	-1806(ra) # 80001db6 <myproc>
    800054cc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800054ce:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffd10b0>
    800054d2:	4501                	li	a0,0
    800054d4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800054d6:	6398                	ld	a4,0(a5)
    800054d8:	cb19                	beqz	a4,800054ee <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800054da:	2505                	addiw	a0,a0,1
    800054dc:	07a1                	addi	a5,a5,8
    800054de:	fed51ce3          	bne	a0,a3,800054d6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054e2:	557d                	li	a0,-1
}
    800054e4:	60e2                	ld	ra,24(sp)
    800054e6:	6442                	ld	s0,16(sp)
    800054e8:	64a2                	ld	s1,8(sp)
    800054ea:	6105                	addi	sp,sp,32
    800054ec:	8082                	ret
      p->ofile[fd] = f;
    800054ee:	01a50793          	addi	a5,a0,26
    800054f2:	078e                	slli	a5,a5,0x3
    800054f4:	963e                	add	a2,a2,a5
    800054f6:	e604                	sd	s1,8(a2)
      return fd;
    800054f8:	b7f5                	j	800054e4 <fdalloc+0x2c>

00000000800054fa <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054fa:	715d                	addi	sp,sp,-80
    800054fc:	e486                	sd	ra,72(sp)
    800054fe:	e0a2                	sd	s0,64(sp)
    80005500:	fc26                	sd	s1,56(sp)
    80005502:	f84a                	sd	s2,48(sp)
    80005504:	f44e                	sd	s3,40(sp)
    80005506:	f052                	sd	s4,32(sp)
    80005508:	ec56                	sd	s5,24(sp)
    8000550a:	0880                	addi	s0,sp,80
    8000550c:	89ae                	mv	s3,a1
    8000550e:	8ab2                	mv	s5,a2
    80005510:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005512:	fb040593          	addi	a1,s0,-80
    80005516:	fffff097          	auipc	ra,0xfffff
    8000551a:	e24080e7          	jalr	-476(ra) # 8000433a <nameiparent>
    8000551e:	892a                	mv	s2,a0
    80005520:	12050f63          	beqz	a0,8000565e <create+0x164>
    return 0;

  ilock(dp);
    80005524:	ffffe097          	auipc	ra,0xffffe
    80005528:	644080e7          	jalr	1604(ra) # 80003b68 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000552c:	4601                	li	a2,0
    8000552e:	fb040593          	addi	a1,s0,-80
    80005532:	854a                	mv	a0,s2
    80005534:	fffff097          	auipc	ra,0xfffff
    80005538:	b16080e7          	jalr	-1258(ra) # 8000404a <dirlookup>
    8000553c:	84aa                	mv	s1,a0
    8000553e:	c921                	beqz	a0,8000558e <create+0x94>
    iunlockput(dp);
    80005540:	854a                	mv	a0,s2
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	888080e7          	jalr	-1912(ra) # 80003dca <iunlockput>
    ilock(ip);
    8000554a:	8526                	mv	a0,s1
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	61c080e7          	jalr	1564(ra) # 80003b68 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005554:	2981                	sext.w	s3,s3
    80005556:	4789                	li	a5,2
    80005558:	02f99463          	bne	s3,a5,80005580 <create+0x86>
    8000555c:	04c4d783          	lhu	a5,76(s1)
    80005560:	37f9                	addiw	a5,a5,-2
    80005562:	17c2                	slli	a5,a5,0x30
    80005564:	93c1                	srli	a5,a5,0x30
    80005566:	4705                	li	a4,1
    80005568:	00f76c63          	bltu	a4,a5,80005580 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000556c:	8526                	mv	a0,s1
    8000556e:	60a6                	ld	ra,72(sp)
    80005570:	6406                	ld	s0,64(sp)
    80005572:	74e2                	ld	s1,56(sp)
    80005574:	7942                	ld	s2,48(sp)
    80005576:	79a2                	ld	s3,40(sp)
    80005578:	7a02                	ld	s4,32(sp)
    8000557a:	6ae2                	ld	s5,24(sp)
    8000557c:	6161                	addi	sp,sp,80
    8000557e:	8082                	ret
    iunlockput(ip);
    80005580:	8526                	mv	a0,s1
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	848080e7          	jalr	-1976(ra) # 80003dca <iunlockput>
    return 0;
    8000558a:	4481                	li	s1,0
    8000558c:	b7c5                	j	8000556c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000558e:	85ce                	mv	a1,s3
    80005590:	00092503          	lw	a0,0(s2)
    80005594:	ffffe097          	auipc	ra,0xffffe
    80005598:	43c080e7          	jalr	1084(ra) # 800039d0 <ialloc>
    8000559c:	84aa                	mv	s1,a0
    8000559e:	c529                	beqz	a0,800055e8 <create+0xee>
  ilock(ip);
    800055a0:	ffffe097          	auipc	ra,0xffffe
    800055a4:	5c8080e7          	jalr	1480(ra) # 80003b68 <ilock>
  ip->major = major;
    800055a8:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800055ac:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    800055b0:	4785                	li	a5,1
    800055b2:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800055b6:	8526                	mv	a0,s1
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	4e6080e7          	jalr	1254(ra) # 80003a9e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800055c0:	2981                	sext.w	s3,s3
    800055c2:	4785                	li	a5,1
    800055c4:	02f98a63          	beq	s3,a5,800055f8 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800055c8:	40d0                	lw	a2,4(s1)
    800055ca:	fb040593          	addi	a1,s0,-80
    800055ce:	854a                	mv	a0,s2
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	c8a080e7          	jalr	-886(ra) # 8000425a <dirlink>
    800055d8:	06054b63          	bltz	a0,8000564e <create+0x154>
  iunlockput(dp);
    800055dc:	854a                	mv	a0,s2
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	7ec080e7          	jalr	2028(ra) # 80003dca <iunlockput>
  return ip;
    800055e6:	b759                	j	8000556c <create+0x72>
    panic("create: ialloc");
    800055e8:	00003517          	auipc	a0,0x3
    800055ec:	19050513          	addi	a0,a0,400 # 80008778 <syscalls+0x2b8>
    800055f0:	ffffb097          	auipc	ra,0xffffb
    800055f4:	f60080e7          	jalr	-160(ra) # 80000550 <panic>
    dp->nlink++;  // for ".."
    800055f8:	05295783          	lhu	a5,82(s2)
    800055fc:	2785                	addiw	a5,a5,1
    800055fe:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    80005602:	854a                	mv	a0,s2
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	49a080e7          	jalr	1178(ra) # 80003a9e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000560c:	40d0                	lw	a2,4(s1)
    8000560e:	00003597          	auipc	a1,0x3
    80005612:	17a58593          	addi	a1,a1,378 # 80008788 <syscalls+0x2c8>
    80005616:	8526                	mv	a0,s1
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	c42080e7          	jalr	-958(ra) # 8000425a <dirlink>
    80005620:	00054f63          	bltz	a0,8000563e <create+0x144>
    80005624:	00492603          	lw	a2,4(s2)
    80005628:	00003597          	auipc	a1,0x3
    8000562c:	16858593          	addi	a1,a1,360 # 80008790 <syscalls+0x2d0>
    80005630:	8526                	mv	a0,s1
    80005632:	fffff097          	auipc	ra,0xfffff
    80005636:	c28080e7          	jalr	-984(ra) # 8000425a <dirlink>
    8000563a:	f80557e3          	bgez	a0,800055c8 <create+0xce>
      panic("create dots");
    8000563e:	00003517          	auipc	a0,0x3
    80005642:	15a50513          	addi	a0,a0,346 # 80008798 <syscalls+0x2d8>
    80005646:	ffffb097          	auipc	ra,0xffffb
    8000564a:	f0a080e7          	jalr	-246(ra) # 80000550 <panic>
    panic("create: dirlink");
    8000564e:	00003517          	auipc	a0,0x3
    80005652:	15a50513          	addi	a0,a0,346 # 800087a8 <syscalls+0x2e8>
    80005656:	ffffb097          	auipc	ra,0xffffb
    8000565a:	efa080e7          	jalr	-262(ra) # 80000550 <panic>
    return 0;
    8000565e:	84aa                	mv	s1,a0
    80005660:	b731                	j	8000556c <create+0x72>

0000000080005662 <sys_dup>:
{
    80005662:	7179                	addi	sp,sp,-48
    80005664:	f406                	sd	ra,40(sp)
    80005666:	f022                	sd	s0,32(sp)
    80005668:	ec26                	sd	s1,24(sp)
    8000566a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000566c:	fd840613          	addi	a2,s0,-40
    80005670:	4581                	li	a1,0
    80005672:	4501                	li	a0,0
    80005674:	00000097          	auipc	ra,0x0
    80005678:	ddc080e7          	jalr	-548(ra) # 80005450 <argfd>
    return -1;
    8000567c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000567e:	02054363          	bltz	a0,800056a4 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005682:	fd843503          	ld	a0,-40(s0)
    80005686:	00000097          	auipc	ra,0x0
    8000568a:	e32080e7          	jalr	-462(ra) # 800054b8 <fdalloc>
    8000568e:	84aa                	mv	s1,a0
    return -1;
    80005690:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005692:	00054963          	bltz	a0,800056a4 <sys_dup+0x42>
  filedup(f);
    80005696:	fd843503          	ld	a0,-40(s0)
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	320080e7          	jalr	800(ra) # 800049ba <filedup>
  return fd;
    800056a2:	87a6                	mv	a5,s1
}
    800056a4:	853e                	mv	a0,a5
    800056a6:	70a2                	ld	ra,40(sp)
    800056a8:	7402                	ld	s0,32(sp)
    800056aa:	64e2                	ld	s1,24(sp)
    800056ac:	6145                	addi	sp,sp,48
    800056ae:	8082                	ret

00000000800056b0 <sys_read>:
{
    800056b0:	7179                	addi	sp,sp,-48
    800056b2:	f406                	sd	ra,40(sp)
    800056b4:	f022                	sd	s0,32(sp)
    800056b6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056b8:	fe840613          	addi	a2,s0,-24
    800056bc:	4581                	li	a1,0
    800056be:	4501                	li	a0,0
    800056c0:	00000097          	auipc	ra,0x0
    800056c4:	d90080e7          	jalr	-624(ra) # 80005450 <argfd>
    return -1;
    800056c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056ca:	04054163          	bltz	a0,8000570c <sys_read+0x5c>
    800056ce:	fe440593          	addi	a1,s0,-28
    800056d2:	4509                	li	a0,2
    800056d4:	ffffd097          	auipc	ra,0xffffd
    800056d8:	7a0080e7          	jalr	1952(ra) # 80002e74 <argint>
    return -1;
    800056dc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056de:	02054763          	bltz	a0,8000570c <sys_read+0x5c>
    800056e2:	fd840593          	addi	a1,s0,-40
    800056e6:	4505                	li	a0,1
    800056e8:	ffffd097          	auipc	ra,0xffffd
    800056ec:	7ae080e7          	jalr	1966(ra) # 80002e96 <argaddr>
    return -1;
    800056f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056f2:	00054d63          	bltz	a0,8000570c <sys_read+0x5c>
  return fileread(f, p, n);
    800056f6:	fe442603          	lw	a2,-28(s0)
    800056fa:	fd843583          	ld	a1,-40(s0)
    800056fe:	fe843503          	ld	a0,-24(s0)
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	444080e7          	jalr	1092(ra) # 80004b46 <fileread>
    8000570a:	87aa                	mv	a5,a0
}
    8000570c:	853e                	mv	a0,a5
    8000570e:	70a2                	ld	ra,40(sp)
    80005710:	7402                	ld	s0,32(sp)
    80005712:	6145                	addi	sp,sp,48
    80005714:	8082                	ret

0000000080005716 <sys_write>:
{
    80005716:	7179                	addi	sp,sp,-48
    80005718:	f406                	sd	ra,40(sp)
    8000571a:	f022                	sd	s0,32(sp)
    8000571c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000571e:	fe840613          	addi	a2,s0,-24
    80005722:	4581                	li	a1,0
    80005724:	4501                	li	a0,0
    80005726:	00000097          	auipc	ra,0x0
    8000572a:	d2a080e7          	jalr	-726(ra) # 80005450 <argfd>
    return -1;
    8000572e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005730:	04054163          	bltz	a0,80005772 <sys_write+0x5c>
    80005734:	fe440593          	addi	a1,s0,-28
    80005738:	4509                	li	a0,2
    8000573a:	ffffd097          	auipc	ra,0xffffd
    8000573e:	73a080e7          	jalr	1850(ra) # 80002e74 <argint>
    return -1;
    80005742:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005744:	02054763          	bltz	a0,80005772 <sys_write+0x5c>
    80005748:	fd840593          	addi	a1,s0,-40
    8000574c:	4505                	li	a0,1
    8000574e:	ffffd097          	auipc	ra,0xffffd
    80005752:	748080e7          	jalr	1864(ra) # 80002e96 <argaddr>
    return -1;
    80005756:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005758:	00054d63          	bltz	a0,80005772 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000575c:	fe442603          	lw	a2,-28(s0)
    80005760:	fd843583          	ld	a1,-40(s0)
    80005764:	fe843503          	ld	a0,-24(s0)
    80005768:	fffff097          	auipc	ra,0xfffff
    8000576c:	4a0080e7          	jalr	1184(ra) # 80004c08 <filewrite>
    80005770:	87aa                	mv	a5,a0
}
    80005772:	853e                	mv	a0,a5
    80005774:	70a2                	ld	ra,40(sp)
    80005776:	7402                	ld	s0,32(sp)
    80005778:	6145                	addi	sp,sp,48
    8000577a:	8082                	ret

000000008000577c <sys_close>:
{
    8000577c:	1101                	addi	sp,sp,-32
    8000577e:	ec06                	sd	ra,24(sp)
    80005780:	e822                	sd	s0,16(sp)
    80005782:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005784:	fe040613          	addi	a2,s0,-32
    80005788:	fec40593          	addi	a1,s0,-20
    8000578c:	4501                	li	a0,0
    8000578e:	00000097          	auipc	ra,0x0
    80005792:	cc2080e7          	jalr	-830(ra) # 80005450 <argfd>
    return -1;
    80005796:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005798:	02054463          	bltz	a0,800057c0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000579c:	ffffc097          	auipc	ra,0xffffc
    800057a0:	61a080e7          	jalr	1562(ra) # 80001db6 <myproc>
    800057a4:	fec42783          	lw	a5,-20(s0)
    800057a8:	07e9                	addi	a5,a5,26
    800057aa:	078e                	slli	a5,a5,0x3
    800057ac:	97aa                	add	a5,a5,a0
    800057ae:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800057b2:	fe043503          	ld	a0,-32(s0)
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	256080e7          	jalr	598(ra) # 80004a0c <fileclose>
  return 0;
    800057be:	4781                	li	a5,0
}
    800057c0:	853e                	mv	a0,a5
    800057c2:	60e2                	ld	ra,24(sp)
    800057c4:	6442                	ld	s0,16(sp)
    800057c6:	6105                	addi	sp,sp,32
    800057c8:	8082                	ret

00000000800057ca <sys_fstat>:
{
    800057ca:	1101                	addi	sp,sp,-32
    800057cc:	ec06                	sd	ra,24(sp)
    800057ce:	e822                	sd	s0,16(sp)
    800057d0:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800057d2:	fe840613          	addi	a2,s0,-24
    800057d6:	4581                	li	a1,0
    800057d8:	4501                	li	a0,0
    800057da:	00000097          	auipc	ra,0x0
    800057de:	c76080e7          	jalr	-906(ra) # 80005450 <argfd>
    return -1;
    800057e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800057e4:	02054563          	bltz	a0,8000580e <sys_fstat+0x44>
    800057e8:	fe040593          	addi	a1,s0,-32
    800057ec:	4505                	li	a0,1
    800057ee:	ffffd097          	auipc	ra,0xffffd
    800057f2:	6a8080e7          	jalr	1704(ra) # 80002e96 <argaddr>
    return -1;
    800057f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800057f8:	00054b63          	bltz	a0,8000580e <sys_fstat+0x44>
  return filestat(f, st);
    800057fc:	fe043583          	ld	a1,-32(s0)
    80005800:	fe843503          	ld	a0,-24(s0)
    80005804:	fffff097          	auipc	ra,0xfffff
    80005808:	2d0080e7          	jalr	720(ra) # 80004ad4 <filestat>
    8000580c:	87aa                	mv	a5,a0
}
    8000580e:	853e                	mv	a0,a5
    80005810:	60e2                	ld	ra,24(sp)
    80005812:	6442                	ld	s0,16(sp)
    80005814:	6105                	addi	sp,sp,32
    80005816:	8082                	ret

0000000080005818 <sys_link>:
{
    80005818:	7169                	addi	sp,sp,-304
    8000581a:	f606                	sd	ra,296(sp)
    8000581c:	f222                	sd	s0,288(sp)
    8000581e:	ee26                	sd	s1,280(sp)
    80005820:	ea4a                	sd	s2,272(sp)
    80005822:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005824:	08000613          	li	a2,128
    80005828:	ed040593          	addi	a1,s0,-304
    8000582c:	4501                	li	a0,0
    8000582e:	ffffd097          	auipc	ra,0xffffd
    80005832:	68a080e7          	jalr	1674(ra) # 80002eb8 <argstr>
    return -1;
    80005836:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005838:	10054e63          	bltz	a0,80005954 <sys_link+0x13c>
    8000583c:	08000613          	li	a2,128
    80005840:	f5040593          	addi	a1,s0,-176
    80005844:	4505                	li	a0,1
    80005846:	ffffd097          	auipc	ra,0xffffd
    8000584a:	672080e7          	jalr	1650(ra) # 80002eb8 <argstr>
    return -1;
    8000584e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005850:	10054263          	bltz	a0,80005954 <sys_link+0x13c>
  begin_op();
    80005854:	fffff097          	auipc	ra,0xfffff
    80005858:	ce4080e7          	jalr	-796(ra) # 80004538 <begin_op>
  if((ip = namei(old)) == 0){
    8000585c:	ed040513          	addi	a0,s0,-304
    80005860:	fffff097          	auipc	ra,0xfffff
    80005864:	abc080e7          	jalr	-1348(ra) # 8000431c <namei>
    80005868:	84aa                	mv	s1,a0
    8000586a:	c551                	beqz	a0,800058f6 <sys_link+0xde>
  ilock(ip);
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	2fc080e7          	jalr	764(ra) # 80003b68 <ilock>
  if(ip->type == T_DIR){
    80005874:	04c49703          	lh	a4,76(s1)
    80005878:	4785                	li	a5,1
    8000587a:	08f70463          	beq	a4,a5,80005902 <sys_link+0xea>
  ip->nlink++;
    8000587e:	0524d783          	lhu	a5,82(s1)
    80005882:	2785                	addiw	a5,a5,1
    80005884:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005888:	8526                	mv	a0,s1
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	214080e7          	jalr	532(ra) # 80003a9e <iupdate>
  iunlock(ip);
    80005892:	8526                	mv	a0,s1
    80005894:	ffffe097          	auipc	ra,0xffffe
    80005898:	396080e7          	jalr	918(ra) # 80003c2a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000589c:	fd040593          	addi	a1,s0,-48
    800058a0:	f5040513          	addi	a0,s0,-176
    800058a4:	fffff097          	auipc	ra,0xfffff
    800058a8:	a96080e7          	jalr	-1386(ra) # 8000433a <nameiparent>
    800058ac:	892a                	mv	s2,a0
    800058ae:	c935                	beqz	a0,80005922 <sys_link+0x10a>
  ilock(dp);
    800058b0:	ffffe097          	auipc	ra,0xffffe
    800058b4:	2b8080e7          	jalr	696(ra) # 80003b68 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800058b8:	00092703          	lw	a4,0(s2)
    800058bc:	409c                	lw	a5,0(s1)
    800058be:	04f71d63          	bne	a4,a5,80005918 <sys_link+0x100>
    800058c2:	40d0                	lw	a2,4(s1)
    800058c4:	fd040593          	addi	a1,s0,-48
    800058c8:	854a                	mv	a0,s2
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	990080e7          	jalr	-1648(ra) # 8000425a <dirlink>
    800058d2:	04054363          	bltz	a0,80005918 <sys_link+0x100>
  iunlockput(dp);
    800058d6:	854a                	mv	a0,s2
    800058d8:	ffffe097          	auipc	ra,0xffffe
    800058dc:	4f2080e7          	jalr	1266(ra) # 80003dca <iunlockput>
  iput(ip);
    800058e0:	8526                	mv	a0,s1
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	440080e7          	jalr	1088(ra) # 80003d22 <iput>
  end_op();
    800058ea:	fffff097          	auipc	ra,0xfffff
    800058ee:	cce080e7          	jalr	-818(ra) # 800045b8 <end_op>
  return 0;
    800058f2:	4781                	li	a5,0
    800058f4:	a085                	j	80005954 <sys_link+0x13c>
    end_op();
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	cc2080e7          	jalr	-830(ra) # 800045b8 <end_op>
    return -1;
    800058fe:	57fd                	li	a5,-1
    80005900:	a891                	j	80005954 <sys_link+0x13c>
    iunlockput(ip);
    80005902:	8526                	mv	a0,s1
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	4c6080e7          	jalr	1222(ra) # 80003dca <iunlockput>
    end_op();
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	cac080e7          	jalr	-852(ra) # 800045b8 <end_op>
    return -1;
    80005914:	57fd                	li	a5,-1
    80005916:	a83d                	j	80005954 <sys_link+0x13c>
    iunlockput(dp);
    80005918:	854a                	mv	a0,s2
    8000591a:	ffffe097          	auipc	ra,0xffffe
    8000591e:	4b0080e7          	jalr	1200(ra) # 80003dca <iunlockput>
  ilock(ip);
    80005922:	8526                	mv	a0,s1
    80005924:	ffffe097          	auipc	ra,0xffffe
    80005928:	244080e7          	jalr	580(ra) # 80003b68 <ilock>
  ip->nlink--;
    8000592c:	0524d783          	lhu	a5,82(s1)
    80005930:	37fd                	addiw	a5,a5,-1
    80005932:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005936:	8526                	mv	a0,s1
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	166080e7          	jalr	358(ra) # 80003a9e <iupdate>
  iunlockput(ip);
    80005940:	8526                	mv	a0,s1
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	488080e7          	jalr	1160(ra) # 80003dca <iunlockput>
  end_op();
    8000594a:	fffff097          	auipc	ra,0xfffff
    8000594e:	c6e080e7          	jalr	-914(ra) # 800045b8 <end_op>
  return -1;
    80005952:	57fd                	li	a5,-1
}
    80005954:	853e                	mv	a0,a5
    80005956:	70b2                	ld	ra,296(sp)
    80005958:	7412                	ld	s0,288(sp)
    8000595a:	64f2                	ld	s1,280(sp)
    8000595c:	6952                	ld	s2,272(sp)
    8000595e:	6155                	addi	sp,sp,304
    80005960:	8082                	ret

0000000080005962 <sys_unlink>:
{
    80005962:	7151                	addi	sp,sp,-240
    80005964:	f586                	sd	ra,232(sp)
    80005966:	f1a2                	sd	s0,224(sp)
    80005968:	eda6                	sd	s1,216(sp)
    8000596a:	e9ca                	sd	s2,208(sp)
    8000596c:	e5ce                	sd	s3,200(sp)
    8000596e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005970:	08000613          	li	a2,128
    80005974:	f3040593          	addi	a1,s0,-208
    80005978:	4501                	li	a0,0
    8000597a:	ffffd097          	auipc	ra,0xffffd
    8000597e:	53e080e7          	jalr	1342(ra) # 80002eb8 <argstr>
    80005982:	18054163          	bltz	a0,80005b04 <sys_unlink+0x1a2>
  begin_op();
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	bb2080e7          	jalr	-1102(ra) # 80004538 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000598e:	fb040593          	addi	a1,s0,-80
    80005992:	f3040513          	addi	a0,s0,-208
    80005996:	fffff097          	auipc	ra,0xfffff
    8000599a:	9a4080e7          	jalr	-1628(ra) # 8000433a <nameiparent>
    8000599e:	84aa                	mv	s1,a0
    800059a0:	c979                	beqz	a0,80005a76 <sys_unlink+0x114>
  ilock(dp);
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	1c6080e7          	jalr	454(ra) # 80003b68 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800059aa:	00003597          	auipc	a1,0x3
    800059ae:	dde58593          	addi	a1,a1,-546 # 80008788 <syscalls+0x2c8>
    800059b2:	fb040513          	addi	a0,s0,-80
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	67a080e7          	jalr	1658(ra) # 80004030 <namecmp>
    800059be:	14050a63          	beqz	a0,80005b12 <sys_unlink+0x1b0>
    800059c2:	00003597          	auipc	a1,0x3
    800059c6:	dce58593          	addi	a1,a1,-562 # 80008790 <syscalls+0x2d0>
    800059ca:	fb040513          	addi	a0,s0,-80
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	662080e7          	jalr	1634(ra) # 80004030 <namecmp>
    800059d6:	12050e63          	beqz	a0,80005b12 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800059da:	f2c40613          	addi	a2,s0,-212
    800059de:	fb040593          	addi	a1,s0,-80
    800059e2:	8526                	mv	a0,s1
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	666080e7          	jalr	1638(ra) # 8000404a <dirlookup>
    800059ec:	892a                	mv	s2,a0
    800059ee:	12050263          	beqz	a0,80005b12 <sys_unlink+0x1b0>
  ilock(ip);
    800059f2:	ffffe097          	auipc	ra,0xffffe
    800059f6:	176080e7          	jalr	374(ra) # 80003b68 <ilock>
  if(ip->nlink < 1)
    800059fa:	05291783          	lh	a5,82(s2)
    800059fe:	08f05263          	blez	a5,80005a82 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a02:	04c91703          	lh	a4,76(s2)
    80005a06:	4785                	li	a5,1
    80005a08:	08f70563          	beq	a4,a5,80005a92 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a0c:	4641                	li	a2,16
    80005a0e:	4581                	li	a1,0
    80005a10:	fc040513          	addi	a0,s0,-64
    80005a14:	ffffb097          	auipc	ra,0xffffb
    80005a18:	73a080e7          	jalr	1850(ra) # 8000114e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a1c:	4741                	li	a4,16
    80005a1e:	f2c42683          	lw	a3,-212(s0)
    80005a22:	fc040613          	addi	a2,s0,-64
    80005a26:	4581                	li	a1,0
    80005a28:	8526                	mv	a0,s1
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	4ea080e7          	jalr	1258(ra) # 80003f14 <writei>
    80005a32:	47c1                	li	a5,16
    80005a34:	0af51563          	bne	a0,a5,80005ade <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a38:	04c91703          	lh	a4,76(s2)
    80005a3c:	4785                	li	a5,1
    80005a3e:	0af70863          	beq	a4,a5,80005aee <sys_unlink+0x18c>
  iunlockput(dp);
    80005a42:	8526                	mv	a0,s1
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	386080e7          	jalr	902(ra) # 80003dca <iunlockput>
  ip->nlink--;
    80005a4c:	05295783          	lhu	a5,82(s2)
    80005a50:	37fd                	addiw	a5,a5,-1
    80005a52:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005a56:	854a                	mv	a0,s2
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	046080e7          	jalr	70(ra) # 80003a9e <iupdate>
  iunlockput(ip);
    80005a60:	854a                	mv	a0,s2
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	368080e7          	jalr	872(ra) # 80003dca <iunlockput>
  end_op();
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	b4e080e7          	jalr	-1202(ra) # 800045b8 <end_op>
  return 0;
    80005a72:	4501                	li	a0,0
    80005a74:	a84d                	j	80005b26 <sys_unlink+0x1c4>
    end_op();
    80005a76:	fffff097          	auipc	ra,0xfffff
    80005a7a:	b42080e7          	jalr	-1214(ra) # 800045b8 <end_op>
    return -1;
    80005a7e:	557d                	li	a0,-1
    80005a80:	a05d                	j	80005b26 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a82:	00003517          	auipc	a0,0x3
    80005a86:	d3650513          	addi	a0,a0,-714 # 800087b8 <syscalls+0x2f8>
    80005a8a:	ffffb097          	auipc	ra,0xffffb
    80005a8e:	ac6080e7          	jalr	-1338(ra) # 80000550 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a92:	05492703          	lw	a4,84(s2)
    80005a96:	02000793          	li	a5,32
    80005a9a:	f6e7f9e3          	bgeu	a5,a4,80005a0c <sys_unlink+0xaa>
    80005a9e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005aa2:	4741                	li	a4,16
    80005aa4:	86ce                	mv	a3,s3
    80005aa6:	f1840613          	addi	a2,s0,-232
    80005aaa:	4581                	li	a1,0
    80005aac:	854a                	mv	a0,s2
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	36e080e7          	jalr	878(ra) # 80003e1c <readi>
    80005ab6:	47c1                	li	a5,16
    80005ab8:	00f51b63          	bne	a0,a5,80005ace <sys_unlink+0x16c>
    if(de.inum != 0)
    80005abc:	f1845783          	lhu	a5,-232(s0)
    80005ac0:	e7a1                	bnez	a5,80005b08 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ac2:	29c1                	addiw	s3,s3,16
    80005ac4:	05492783          	lw	a5,84(s2)
    80005ac8:	fcf9ede3          	bltu	s3,a5,80005aa2 <sys_unlink+0x140>
    80005acc:	b781                	j	80005a0c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005ace:	00003517          	auipc	a0,0x3
    80005ad2:	d0250513          	addi	a0,a0,-766 # 800087d0 <syscalls+0x310>
    80005ad6:	ffffb097          	auipc	ra,0xffffb
    80005ada:	a7a080e7          	jalr	-1414(ra) # 80000550 <panic>
    panic("unlink: writei");
    80005ade:	00003517          	auipc	a0,0x3
    80005ae2:	d0a50513          	addi	a0,a0,-758 # 800087e8 <syscalls+0x328>
    80005ae6:	ffffb097          	auipc	ra,0xffffb
    80005aea:	a6a080e7          	jalr	-1430(ra) # 80000550 <panic>
    dp->nlink--;
    80005aee:	0524d783          	lhu	a5,82(s1)
    80005af2:	37fd                	addiw	a5,a5,-1
    80005af4:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005af8:	8526                	mv	a0,s1
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	fa4080e7          	jalr	-92(ra) # 80003a9e <iupdate>
    80005b02:	b781                	j	80005a42 <sys_unlink+0xe0>
    return -1;
    80005b04:	557d                	li	a0,-1
    80005b06:	a005                	j	80005b26 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b08:	854a                	mv	a0,s2
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	2c0080e7          	jalr	704(ra) # 80003dca <iunlockput>
  iunlockput(dp);
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	2b6080e7          	jalr	694(ra) # 80003dca <iunlockput>
  end_op();
    80005b1c:	fffff097          	auipc	ra,0xfffff
    80005b20:	a9c080e7          	jalr	-1380(ra) # 800045b8 <end_op>
  return -1;
    80005b24:	557d                	li	a0,-1
}
    80005b26:	70ae                	ld	ra,232(sp)
    80005b28:	740e                	ld	s0,224(sp)
    80005b2a:	64ee                	ld	s1,216(sp)
    80005b2c:	694e                	ld	s2,208(sp)
    80005b2e:	69ae                	ld	s3,200(sp)
    80005b30:	616d                	addi	sp,sp,240
    80005b32:	8082                	ret

0000000080005b34 <sys_open>:

uint64
sys_open(void)
{
    80005b34:	7131                	addi	sp,sp,-192
    80005b36:	fd06                	sd	ra,184(sp)
    80005b38:	f922                	sd	s0,176(sp)
    80005b3a:	f526                	sd	s1,168(sp)
    80005b3c:	f14a                	sd	s2,160(sp)
    80005b3e:	ed4e                	sd	s3,152(sp)
    80005b40:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005b42:	08000613          	li	a2,128
    80005b46:	f5040593          	addi	a1,s0,-176
    80005b4a:	4501                	li	a0,0
    80005b4c:	ffffd097          	auipc	ra,0xffffd
    80005b50:	36c080e7          	jalr	876(ra) # 80002eb8 <argstr>
    return -1;
    80005b54:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005b56:	0c054163          	bltz	a0,80005c18 <sys_open+0xe4>
    80005b5a:	f4c40593          	addi	a1,s0,-180
    80005b5e:	4505                	li	a0,1
    80005b60:	ffffd097          	auipc	ra,0xffffd
    80005b64:	314080e7          	jalr	788(ra) # 80002e74 <argint>
    80005b68:	0a054863          	bltz	a0,80005c18 <sys_open+0xe4>

  begin_op();
    80005b6c:	fffff097          	auipc	ra,0xfffff
    80005b70:	9cc080e7          	jalr	-1588(ra) # 80004538 <begin_op>

  if(omode & O_CREATE){
    80005b74:	f4c42783          	lw	a5,-180(s0)
    80005b78:	2007f793          	andi	a5,a5,512
    80005b7c:	cbdd                	beqz	a5,80005c32 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b7e:	4681                	li	a3,0
    80005b80:	4601                	li	a2,0
    80005b82:	4589                	li	a1,2
    80005b84:	f5040513          	addi	a0,s0,-176
    80005b88:	00000097          	auipc	ra,0x0
    80005b8c:	972080e7          	jalr	-1678(ra) # 800054fa <create>
    80005b90:	892a                	mv	s2,a0
    if(ip == 0){
    80005b92:	c959                	beqz	a0,80005c28 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b94:	04c91703          	lh	a4,76(s2)
    80005b98:	478d                	li	a5,3
    80005b9a:	00f71763          	bne	a4,a5,80005ba8 <sys_open+0x74>
    80005b9e:	04e95703          	lhu	a4,78(s2)
    80005ba2:	47a5                	li	a5,9
    80005ba4:	0ce7ec63          	bltu	a5,a4,80005c7c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	da8080e7          	jalr	-600(ra) # 80004950 <filealloc>
    80005bb0:	89aa                	mv	s3,a0
    80005bb2:	10050263          	beqz	a0,80005cb6 <sys_open+0x182>
    80005bb6:	00000097          	auipc	ra,0x0
    80005bba:	902080e7          	jalr	-1790(ra) # 800054b8 <fdalloc>
    80005bbe:	84aa                	mv	s1,a0
    80005bc0:	0e054663          	bltz	a0,80005cac <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005bc4:	04c91703          	lh	a4,76(s2)
    80005bc8:	478d                	li	a5,3
    80005bca:	0cf70463          	beq	a4,a5,80005c92 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005bce:	4789                	li	a5,2
    80005bd0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005bd4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005bd8:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005bdc:	f4c42783          	lw	a5,-180(s0)
    80005be0:	0017c713          	xori	a4,a5,1
    80005be4:	8b05                	andi	a4,a4,1
    80005be6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005bea:	0037f713          	andi	a4,a5,3
    80005bee:	00e03733          	snez	a4,a4
    80005bf2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005bf6:	4007f793          	andi	a5,a5,1024
    80005bfa:	c791                	beqz	a5,80005c06 <sys_open+0xd2>
    80005bfc:	04c91703          	lh	a4,76(s2)
    80005c00:	4789                	li	a5,2
    80005c02:	08f70f63          	beq	a4,a5,80005ca0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c06:	854a                	mv	a0,s2
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	022080e7          	jalr	34(ra) # 80003c2a <iunlock>
  end_op();
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	9a8080e7          	jalr	-1624(ra) # 800045b8 <end_op>

  return fd;
}
    80005c18:	8526                	mv	a0,s1
    80005c1a:	70ea                	ld	ra,184(sp)
    80005c1c:	744a                	ld	s0,176(sp)
    80005c1e:	74aa                	ld	s1,168(sp)
    80005c20:	790a                	ld	s2,160(sp)
    80005c22:	69ea                	ld	s3,152(sp)
    80005c24:	6129                	addi	sp,sp,192
    80005c26:	8082                	ret
      end_op();
    80005c28:	fffff097          	auipc	ra,0xfffff
    80005c2c:	990080e7          	jalr	-1648(ra) # 800045b8 <end_op>
      return -1;
    80005c30:	b7e5                	j	80005c18 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c32:	f5040513          	addi	a0,s0,-176
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	6e6080e7          	jalr	1766(ra) # 8000431c <namei>
    80005c3e:	892a                	mv	s2,a0
    80005c40:	c905                	beqz	a0,80005c70 <sys_open+0x13c>
    ilock(ip);
    80005c42:	ffffe097          	auipc	ra,0xffffe
    80005c46:	f26080e7          	jalr	-218(ra) # 80003b68 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c4a:	04c91703          	lh	a4,76(s2)
    80005c4e:	4785                	li	a5,1
    80005c50:	f4f712e3          	bne	a4,a5,80005b94 <sys_open+0x60>
    80005c54:	f4c42783          	lw	a5,-180(s0)
    80005c58:	dba1                	beqz	a5,80005ba8 <sys_open+0x74>
      iunlockput(ip);
    80005c5a:	854a                	mv	a0,s2
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	16e080e7          	jalr	366(ra) # 80003dca <iunlockput>
      end_op();
    80005c64:	fffff097          	auipc	ra,0xfffff
    80005c68:	954080e7          	jalr	-1708(ra) # 800045b8 <end_op>
      return -1;
    80005c6c:	54fd                	li	s1,-1
    80005c6e:	b76d                	j	80005c18 <sys_open+0xe4>
      end_op();
    80005c70:	fffff097          	auipc	ra,0xfffff
    80005c74:	948080e7          	jalr	-1720(ra) # 800045b8 <end_op>
      return -1;
    80005c78:	54fd                	li	s1,-1
    80005c7a:	bf79                	j	80005c18 <sys_open+0xe4>
    iunlockput(ip);
    80005c7c:	854a                	mv	a0,s2
    80005c7e:	ffffe097          	auipc	ra,0xffffe
    80005c82:	14c080e7          	jalr	332(ra) # 80003dca <iunlockput>
    end_op();
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	932080e7          	jalr	-1742(ra) # 800045b8 <end_op>
    return -1;
    80005c8e:	54fd                	li	s1,-1
    80005c90:	b761                	j	80005c18 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c92:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c96:	04e91783          	lh	a5,78(s2)
    80005c9a:	02f99223          	sh	a5,36(s3)
    80005c9e:	bf2d                	j	80005bd8 <sys_open+0xa4>
    itrunc(ip);
    80005ca0:	854a                	mv	a0,s2
    80005ca2:	ffffe097          	auipc	ra,0xffffe
    80005ca6:	fd4080e7          	jalr	-44(ra) # 80003c76 <itrunc>
    80005caa:	bfb1                	j	80005c06 <sys_open+0xd2>
      fileclose(f);
    80005cac:	854e                	mv	a0,s3
    80005cae:	fffff097          	auipc	ra,0xfffff
    80005cb2:	d5e080e7          	jalr	-674(ra) # 80004a0c <fileclose>
    iunlockput(ip);
    80005cb6:	854a                	mv	a0,s2
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	112080e7          	jalr	274(ra) # 80003dca <iunlockput>
    end_op();
    80005cc0:	fffff097          	auipc	ra,0xfffff
    80005cc4:	8f8080e7          	jalr	-1800(ra) # 800045b8 <end_op>
    return -1;
    80005cc8:	54fd                	li	s1,-1
    80005cca:	b7b9                	j	80005c18 <sys_open+0xe4>

0000000080005ccc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ccc:	7175                	addi	sp,sp,-144
    80005cce:	e506                	sd	ra,136(sp)
    80005cd0:	e122                	sd	s0,128(sp)
    80005cd2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005cd4:	fffff097          	auipc	ra,0xfffff
    80005cd8:	864080e7          	jalr	-1948(ra) # 80004538 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005cdc:	08000613          	li	a2,128
    80005ce0:	f7040593          	addi	a1,s0,-144
    80005ce4:	4501                	li	a0,0
    80005ce6:	ffffd097          	auipc	ra,0xffffd
    80005cea:	1d2080e7          	jalr	466(ra) # 80002eb8 <argstr>
    80005cee:	02054963          	bltz	a0,80005d20 <sys_mkdir+0x54>
    80005cf2:	4681                	li	a3,0
    80005cf4:	4601                	li	a2,0
    80005cf6:	4585                	li	a1,1
    80005cf8:	f7040513          	addi	a0,s0,-144
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	7fe080e7          	jalr	2046(ra) # 800054fa <create>
    80005d04:	cd11                	beqz	a0,80005d20 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	0c4080e7          	jalr	196(ra) # 80003dca <iunlockput>
  end_op();
    80005d0e:	fffff097          	auipc	ra,0xfffff
    80005d12:	8aa080e7          	jalr	-1878(ra) # 800045b8 <end_op>
  return 0;
    80005d16:	4501                	li	a0,0
}
    80005d18:	60aa                	ld	ra,136(sp)
    80005d1a:	640a                	ld	s0,128(sp)
    80005d1c:	6149                	addi	sp,sp,144
    80005d1e:	8082                	ret
    end_op();
    80005d20:	fffff097          	auipc	ra,0xfffff
    80005d24:	898080e7          	jalr	-1896(ra) # 800045b8 <end_op>
    return -1;
    80005d28:	557d                	li	a0,-1
    80005d2a:	b7fd                	j	80005d18 <sys_mkdir+0x4c>

0000000080005d2c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d2c:	7135                	addi	sp,sp,-160
    80005d2e:	ed06                	sd	ra,152(sp)
    80005d30:	e922                	sd	s0,144(sp)
    80005d32:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d34:	fffff097          	auipc	ra,0xfffff
    80005d38:	804080e7          	jalr	-2044(ra) # 80004538 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d3c:	08000613          	li	a2,128
    80005d40:	f7040593          	addi	a1,s0,-144
    80005d44:	4501                	li	a0,0
    80005d46:	ffffd097          	auipc	ra,0xffffd
    80005d4a:	172080e7          	jalr	370(ra) # 80002eb8 <argstr>
    80005d4e:	04054a63          	bltz	a0,80005da2 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005d52:	f6c40593          	addi	a1,s0,-148
    80005d56:	4505                	li	a0,1
    80005d58:	ffffd097          	auipc	ra,0xffffd
    80005d5c:	11c080e7          	jalr	284(ra) # 80002e74 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d60:	04054163          	bltz	a0,80005da2 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005d64:	f6840593          	addi	a1,s0,-152
    80005d68:	4509                	li	a0,2
    80005d6a:	ffffd097          	auipc	ra,0xffffd
    80005d6e:	10a080e7          	jalr	266(ra) # 80002e74 <argint>
     argint(1, &major) < 0 ||
    80005d72:	02054863          	bltz	a0,80005da2 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d76:	f6841683          	lh	a3,-152(s0)
    80005d7a:	f6c41603          	lh	a2,-148(s0)
    80005d7e:	458d                	li	a1,3
    80005d80:	f7040513          	addi	a0,s0,-144
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	776080e7          	jalr	1910(ra) # 800054fa <create>
     argint(2, &minor) < 0 ||
    80005d8c:	c919                	beqz	a0,80005da2 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d8e:	ffffe097          	auipc	ra,0xffffe
    80005d92:	03c080e7          	jalr	60(ra) # 80003dca <iunlockput>
  end_op();
    80005d96:	fffff097          	auipc	ra,0xfffff
    80005d9a:	822080e7          	jalr	-2014(ra) # 800045b8 <end_op>
  return 0;
    80005d9e:	4501                	li	a0,0
    80005da0:	a031                	j	80005dac <sys_mknod+0x80>
    end_op();
    80005da2:	fffff097          	auipc	ra,0xfffff
    80005da6:	816080e7          	jalr	-2026(ra) # 800045b8 <end_op>
    return -1;
    80005daa:	557d                	li	a0,-1
}
    80005dac:	60ea                	ld	ra,152(sp)
    80005dae:	644a                	ld	s0,144(sp)
    80005db0:	610d                	addi	sp,sp,160
    80005db2:	8082                	ret

0000000080005db4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005db4:	7135                	addi	sp,sp,-160
    80005db6:	ed06                	sd	ra,152(sp)
    80005db8:	e922                	sd	s0,144(sp)
    80005dba:	e526                	sd	s1,136(sp)
    80005dbc:	e14a                	sd	s2,128(sp)
    80005dbe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005dc0:	ffffc097          	auipc	ra,0xffffc
    80005dc4:	ff6080e7          	jalr	-10(ra) # 80001db6 <myproc>
    80005dc8:	892a                	mv	s2,a0
  
  begin_op();
    80005dca:	ffffe097          	auipc	ra,0xffffe
    80005dce:	76e080e7          	jalr	1902(ra) # 80004538 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005dd2:	08000613          	li	a2,128
    80005dd6:	f6040593          	addi	a1,s0,-160
    80005dda:	4501                	li	a0,0
    80005ddc:	ffffd097          	auipc	ra,0xffffd
    80005de0:	0dc080e7          	jalr	220(ra) # 80002eb8 <argstr>
    80005de4:	04054b63          	bltz	a0,80005e3a <sys_chdir+0x86>
    80005de8:	f6040513          	addi	a0,s0,-160
    80005dec:	ffffe097          	auipc	ra,0xffffe
    80005df0:	530080e7          	jalr	1328(ra) # 8000431c <namei>
    80005df4:	84aa                	mv	s1,a0
    80005df6:	c131                	beqz	a0,80005e3a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005df8:	ffffe097          	auipc	ra,0xffffe
    80005dfc:	d70080e7          	jalr	-656(ra) # 80003b68 <ilock>
  if(ip->type != T_DIR){
    80005e00:	04c49703          	lh	a4,76(s1)
    80005e04:	4785                	li	a5,1
    80005e06:	04f71063          	bne	a4,a5,80005e46 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e0a:	8526                	mv	a0,s1
    80005e0c:	ffffe097          	auipc	ra,0xffffe
    80005e10:	e1e080e7          	jalr	-482(ra) # 80003c2a <iunlock>
  iput(p->cwd);
    80005e14:	15893503          	ld	a0,344(s2)
    80005e18:	ffffe097          	auipc	ra,0xffffe
    80005e1c:	f0a080e7          	jalr	-246(ra) # 80003d22 <iput>
  end_op();
    80005e20:	ffffe097          	auipc	ra,0xffffe
    80005e24:	798080e7          	jalr	1944(ra) # 800045b8 <end_op>
  p->cwd = ip;
    80005e28:	14993c23          	sd	s1,344(s2)
  return 0;
    80005e2c:	4501                	li	a0,0
}
    80005e2e:	60ea                	ld	ra,152(sp)
    80005e30:	644a                	ld	s0,144(sp)
    80005e32:	64aa                	ld	s1,136(sp)
    80005e34:	690a                	ld	s2,128(sp)
    80005e36:	610d                	addi	sp,sp,160
    80005e38:	8082                	ret
    end_op();
    80005e3a:	ffffe097          	auipc	ra,0xffffe
    80005e3e:	77e080e7          	jalr	1918(ra) # 800045b8 <end_op>
    return -1;
    80005e42:	557d                	li	a0,-1
    80005e44:	b7ed                	j	80005e2e <sys_chdir+0x7a>
    iunlockput(ip);
    80005e46:	8526                	mv	a0,s1
    80005e48:	ffffe097          	auipc	ra,0xffffe
    80005e4c:	f82080e7          	jalr	-126(ra) # 80003dca <iunlockput>
    end_op();
    80005e50:	ffffe097          	auipc	ra,0xffffe
    80005e54:	768080e7          	jalr	1896(ra) # 800045b8 <end_op>
    return -1;
    80005e58:	557d                	li	a0,-1
    80005e5a:	bfd1                	j	80005e2e <sys_chdir+0x7a>

0000000080005e5c <sys_exec>:

uint64
sys_exec(void)
{
    80005e5c:	7145                	addi	sp,sp,-464
    80005e5e:	e786                	sd	ra,456(sp)
    80005e60:	e3a2                	sd	s0,448(sp)
    80005e62:	ff26                	sd	s1,440(sp)
    80005e64:	fb4a                	sd	s2,432(sp)
    80005e66:	f74e                	sd	s3,424(sp)
    80005e68:	f352                	sd	s4,416(sp)
    80005e6a:	ef56                	sd	s5,408(sp)
    80005e6c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005e6e:	08000613          	li	a2,128
    80005e72:	f4040593          	addi	a1,s0,-192
    80005e76:	4501                	li	a0,0
    80005e78:	ffffd097          	auipc	ra,0xffffd
    80005e7c:	040080e7          	jalr	64(ra) # 80002eb8 <argstr>
    return -1;
    80005e80:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005e82:	0c054a63          	bltz	a0,80005f56 <sys_exec+0xfa>
    80005e86:	e3840593          	addi	a1,s0,-456
    80005e8a:	4505                	li	a0,1
    80005e8c:	ffffd097          	auipc	ra,0xffffd
    80005e90:	00a080e7          	jalr	10(ra) # 80002e96 <argaddr>
    80005e94:	0c054163          	bltz	a0,80005f56 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005e98:	10000613          	li	a2,256
    80005e9c:	4581                	li	a1,0
    80005e9e:	e4040513          	addi	a0,s0,-448
    80005ea2:	ffffb097          	auipc	ra,0xffffb
    80005ea6:	2ac080e7          	jalr	684(ra) # 8000114e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005eaa:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005eae:	89a6                	mv	s3,s1
    80005eb0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005eb2:	02000a13          	li	s4,32
    80005eb6:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005eba:	00391513          	slli	a0,s2,0x3
    80005ebe:	e3040593          	addi	a1,s0,-464
    80005ec2:	e3843783          	ld	a5,-456(s0)
    80005ec6:	953e                	add	a0,a0,a5
    80005ec8:	ffffd097          	auipc	ra,0xffffd
    80005ecc:	f12080e7          	jalr	-238(ra) # 80002dda <fetchaddr>
    80005ed0:	02054a63          	bltz	a0,80005f04 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005ed4:	e3043783          	ld	a5,-464(s0)
    80005ed8:	c3b9                	beqz	a5,80005f1e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005eda:	ffffb097          	auipc	ra,0xffffb
    80005ede:	cb8080e7          	jalr	-840(ra) # 80000b92 <kalloc>
    80005ee2:	85aa                	mv	a1,a0
    80005ee4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ee8:	cd11                	beqz	a0,80005f04 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005eea:	6605                	lui	a2,0x1
    80005eec:	e3043503          	ld	a0,-464(s0)
    80005ef0:	ffffd097          	auipc	ra,0xffffd
    80005ef4:	f3c080e7          	jalr	-196(ra) # 80002e2c <fetchstr>
    80005ef8:	00054663          	bltz	a0,80005f04 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005efc:	0905                	addi	s2,s2,1
    80005efe:	09a1                	addi	s3,s3,8
    80005f00:	fb491be3          	bne	s2,s4,80005eb6 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f04:	10048913          	addi	s2,s1,256
    80005f08:	6088                	ld	a0,0(s1)
    80005f0a:	c529                	beqz	a0,80005f54 <sys_exec+0xf8>
    kfree(argv[i]);
    80005f0c:	ffffb097          	auipc	ra,0xffffb
    80005f10:	b20080e7          	jalr	-1248(ra) # 80000a2c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f14:	04a1                	addi	s1,s1,8
    80005f16:	ff2499e3          	bne	s1,s2,80005f08 <sys_exec+0xac>
  return -1;
    80005f1a:	597d                	li	s2,-1
    80005f1c:	a82d                	j	80005f56 <sys_exec+0xfa>
      argv[i] = 0;
    80005f1e:	0a8e                	slli	s5,s5,0x3
    80005f20:	fc040793          	addi	a5,s0,-64
    80005f24:	9abe                	add	s5,s5,a5
    80005f26:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f2a:	e4040593          	addi	a1,s0,-448
    80005f2e:	f4040513          	addi	a0,s0,-192
    80005f32:	fffff097          	auipc	ra,0xfffff
    80005f36:	194080e7          	jalr	404(ra) # 800050c6 <exec>
    80005f3a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f3c:	10048993          	addi	s3,s1,256
    80005f40:	6088                	ld	a0,0(s1)
    80005f42:	c911                	beqz	a0,80005f56 <sys_exec+0xfa>
    kfree(argv[i]);
    80005f44:	ffffb097          	auipc	ra,0xffffb
    80005f48:	ae8080e7          	jalr	-1304(ra) # 80000a2c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f4c:	04a1                	addi	s1,s1,8
    80005f4e:	ff3499e3          	bne	s1,s3,80005f40 <sys_exec+0xe4>
    80005f52:	a011                	j	80005f56 <sys_exec+0xfa>
  return -1;
    80005f54:	597d                	li	s2,-1
}
    80005f56:	854a                	mv	a0,s2
    80005f58:	60be                	ld	ra,456(sp)
    80005f5a:	641e                	ld	s0,448(sp)
    80005f5c:	74fa                	ld	s1,440(sp)
    80005f5e:	795a                	ld	s2,432(sp)
    80005f60:	79ba                	ld	s3,424(sp)
    80005f62:	7a1a                	ld	s4,416(sp)
    80005f64:	6afa                	ld	s5,408(sp)
    80005f66:	6179                	addi	sp,sp,464
    80005f68:	8082                	ret

0000000080005f6a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f6a:	7139                	addi	sp,sp,-64
    80005f6c:	fc06                	sd	ra,56(sp)
    80005f6e:	f822                	sd	s0,48(sp)
    80005f70:	f426                	sd	s1,40(sp)
    80005f72:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f74:	ffffc097          	auipc	ra,0xffffc
    80005f78:	e42080e7          	jalr	-446(ra) # 80001db6 <myproc>
    80005f7c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005f7e:	fd840593          	addi	a1,s0,-40
    80005f82:	4501                	li	a0,0
    80005f84:	ffffd097          	auipc	ra,0xffffd
    80005f88:	f12080e7          	jalr	-238(ra) # 80002e96 <argaddr>
    return -1;
    80005f8c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005f8e:	0e054063          	bltz	a0,8000606e <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005f92:	fc840593          	addi	a1,s0,-56
    80005f96:	fd040513          	addi	a0,s0,-48
    80005f9a:	fffff097          	auipc	ra,0xfffff
    80005f9e:	dc8080e7          	jalr	-568(ra) # 80004d62 <pipealloc>
    return -1;
    80005fa2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005fa4:	0c054563          	bltz	a0,8000606e <sys_pipe+0x104>
  fd0 = -1;
    80005fa8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005fac:	fd043503          	ld	a0,-48(s0)
    80005fb0:	fffff097          	auipc	ra,0xfffff
    80005fb4:	508080e7          	jalr	1288(ra) # 800054b8 <fdalloc>
    80005fb8:	fca42223          	sw	a0,-60(s0)
    80005fbc:	08054c63          	bltz	a0,80006054 <sys_pipe+0xea>
    80005fc0:	fc843503          	ld	a0,-56(s0)
    80005fc4:	fffff097          	auipc	ra,0xfffff
    80005fc8:	4f4080e7          	jalr	1268(ra) # 800054b8 <fdalloc>
    80005fcc:	fca42023          	sw	a0,-64(s0)
    80005fd0:	06054863          	bltz	a0,80006040 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fd4:	4691                	li	a3,4
    80005fd6:	fc440613          	addi	a2,s0,-60
    80005fda:	fd843583          	ld	a1,-40(s0)
    80005fde:	6ca8                	ld	a0,88(s1)
    80005fe0:	ffffc097          	auipc	ra,0xffffc
    80005fe4:	aca080e7          	jalr	-1334(ra) # 80001aaa <copyout>
    80005fe8:	02054063          	bltz	a0,80006008 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005fec:	4691                	li	a3,4
    80005fee:	fc040613          	addi	a2,s0,-64
    80005ff2:	fd843583          	ld	a1,-40(s0)
    80005ff6:	0591                	addi	a1,a1,4
    80005ff8:	6ca8                	ld	a0,88(s1)
    80005ffa:	ffffc097          	auipc	ra,0xffffc
    80005ffe:	ab0080e7          	jalr	-1360(ra) # 80001aaa <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006002:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006004:	06055563          	bgez	a0,8000606e <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006008:	fc442783          	lw	a5,-60(s0)
    8000600c:	07e9                	addi	a5,a5,26
    8000600e:	078e                	slli	a5,a5,0x3
    80006010:	97a6                	add	a5,a5,s1
    80006012:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006016:	fc042503          	lw	a0,-64(s0)
    8000601a:	0569                	addi	a0,a0,26
    8000601c:	050e                	slli	a0,a0,0x3
    8000601e:	9526                	add	a0,a0,s1
    80006020:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006024:	fd043503          	ld	a0,-48(s0)
    80006028:	fffff097          	auipc	ra,0xfffff
    8000602c:	9e4080e7          	jalr	-1564(ra) # 80004a0c <fileclose>
    fileclose(wf);
    80006030:	fc843503          	ld	a0,-56(s0)
    80006034:	fffff097          	auipc	ra,0xfffff
    80006038:	9d8080e7          	jalr	-1576(ra) # 80004a0c <fileclose>
    return -1;
    8000603c:	57fd                	li	a5,-1
    8000603e:	a805                	j	8000606e <sys_pipe+0x104>
    if(fd0 >= 0)
    80006040:	fc442783          	lw	a5,-60(s0)
    80006044:	0007c863          	bltz	a5,80006054 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006048:	01a78513          	addi	a0,a5,26
    8000604c:	050e                	slli	a0,a0,0x3
    8000604e:	9526                	add	a0,a0,s1
    80006050:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006054:	fd043503          	ld	a0,-48(s0)
    80006058:	fffff097          	auipc	ra,0xfffff
    8000605c:	9b4080e7          	jalr	-1612(ra) # 80004a0c <fileclose>
    fileclose(wf);
    80006060:	fc843503          	ld	a0,-56(s0)
    80006064:	fffff097          	auipc	ra,0xfffff
    80006068:	9a8080e7          	jalr	-1624(ra) # 80004a0c <fileclose>
    return -1;
    8000606c:	57fd                	li	a5,-1
}
    8000606e:	853e                	mv	a0,a5
    80006070:	70e2                	ld	ra,56(sp)
    80006072:	7442                	ld	s0,48(sp)
    80006074:	74a2                	ld	s1,40(sp)
    80006076:	6121                	addi	sp,sp,64
    80006078:	8082                	ret
    8000607a:	0000                	unimp
    8000607c:	0000                	unimp
	...

0000000080006080 <kernelvec>:
    80006080:	7111                	addi	sp,sp,-256
    80006082:	e006                	sd	ra,0(sp)
    80006084:	e40a                	sd	sp,8(sp)
    80006086:	e80e                	sd	gp,16(sp)
    80006088:	ec12                	sd	tp,24(sp)
    8000608a:	f016                	sd	t0,32(sp)
    8000608c:	f41a                	sd	t1,40(sp)
    8000608e:	f81e                	sd	t2,48(sp)
    80006090:	fc22                	sd	s0,56(sp)
    80006092:	e0a6                	sd	s1,64(sp)
    80006094:	e4aa                	sd	a0,72(sp)
    80006096:	e8ae                	sd	a1,80(sp)
    80006098:	ecb2                	sd	a2,88(sp)
    8000609a:	f0b6                	sd	a3,96(sp)
    8000609c:	f4ba                	sd	a4,104(sp)
    8000609e:	f8be                	sd	a5,112(sp)
    800060a0:	fcc2                	sd	a6,120(sp)
    800060a2:	e146                	sd	a7,128(sp)
    800060a4:	e54a                	sd	s2,136(sp)
    800060a6:	e94e                	sd	s3,144(sp)
    800060a8:	ed52                	sd	s4,152(sp)
    800060aa:	f156                	sd	s5,160(sp)
    800060ac:	f55a                	sd	s6,168(sp)
    800060ae:	f95e                	sd	s7,176(sp)
    800060b0:	fd62                	sd	s8,184(sp)
    800060b2:	e1e6                	sd	s9,192(sp)
    800060b4:	e5ea                	sd	s10,200(sp)
    800060b6:	e9ee                	sd	s11,208(sp)
    800060b8:	edf2                	sd	t3,216(sp)
    800060ba:	f1f6                	sd	t4,224(sp)
    800060bc:	f5fa                	sd	t5,232(sp)
    800060be:	f9fe                	sd	t6,240(sp)
    800060c0:	be7fc0ef          	jal	ra,80002ca6 <kerneltrap>
    800060c4:	6082                	ld	ra,0(sp)
    800060c6:	6122                	ld	sp,8(sp)
    800060c8:	61c2                	ld	gp,16(sp)
    800060ca:	7282                	ld	t0,32(sp)
    800060cc:	7322                	ld	t1,40(sp)
    800060ce:	73c2                	ld	t2,48(sp)
    800060d0:	7462                	ld	s0,56(sp)
    800060d2:	6486                	ld	s1,64(sp)
    800060d4:	6526                	ld	a0,72(sp)
    800060d6:	65c6                	ld	a1,80(sp)
    800060d8:	6666                	ld	a2,88(sp)
    800060da:	7686                	ld	a3,96(sp)
    800060dc:	7726                	ld	a4,104(sp)
    800060de:	77c6                	ld	a5,112(sp)
    800060e0:	7866                	ld	a6,120(sp)
    800060e2:	688a                	ld	a7,128(sp)
    800060e4:	692a                	ld	s2,136(sp)
    800060e6:	69ca                	ld	s3,144(sp)
    800060e8:	6a6a                	ld	s4,152(sp)
    800060ea:	7a8a                	ld	s5,160(sp)
    800060ec:	7b2a                	ld	s6,168(sp)
    800060ee:	7bca                	ld	s7,176(sp)
    800060f0:	7c6a                	ld	s8,184(sp)
    800060f2:	6c8e                	ld	s9,192(sp)
    800060f4:	6d2e                	ld	s10,200(sp)
    800060f6:	6dce                	ld	s11,208(sp)
    800060f8:	6e6e                	ld	t3,216(sp)
    800060fa:	7e8e                	ld	t4,224(sp)
    800060fc:	7f2e                	ld	t5,232(sp)
    800060fe:	7fce                	ld	t6,240(sp)
    80006100:	6111                	addi	sp,sp,256
    80006102:	10200073          	sret
    80006106:	00000013          	nop
    8000610a:	00000013          	nop
    8000610e:	0001                	nop

0000000080006110 <timervec>:
    80006110:	34051573          	csrrw	a0,mscratch,a0
    80006114:	e10c                	sd	a1,0(a0)
    80006116:	e510                	sd	a2,8(a0)
    80006118:	e914                	sd	a3,16(a0)
    8000611a:	6d0c                	ld	a1,24(a0)
    8000611c:	7110                	ld	a2,32(a0)
    8000611e:	6194                	ld	a3,0(a1)
    80006120:	96b2                	add	a3,a3,a2
    80006122:	e194                	sd	a3,0(a1)
    80006124:	4589                	li	a1,2
    80006126:	14459073          	csrw	sip,a1
    8000612a:	6914                	ld	a3,16(a0)
    8000612c:	6510                	ld	a2,8(a0)
    8000612e:	610c                	ld	a1,0(a0)
    80006130:	34051573          	csrrw	a0,mscratch,a0
    80006134:	30200073          	mret
	...

000000008000613a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000613a:	1141                	addi	sp,sp,-16
    8000613c:	e422                	sd	s0,8(sp)
    8000613e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006140:	0c0007b7          	lui	a5,0xc000
    80006144:	4705                	li	a4,1
    80006146:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006148:	c3d8                	sw	a4,4(a5)
}
    8000614a:	6422                	ld	s0,8(sp)
    8000614c:	0141                	addi	sp,sp,16
    8000614e:	8082                	ret

0000000080006150 <plicinithart>:

void
plicinithart(void)
{
    80006150:	1141                	addi	sp,sp,-16
    80006152:	e406                	sd	ra,8(sp)
    80006154:	e022                	sd	s0,0(sp)
    80006156:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006158:	ffffc097          	auipc	ra,0xffffc
    8000615c:	c32080e7          	jalr	-974(ra) # 80001d8a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006160:	0085171b          	slliw	a4,a0,0x8
    80006164:	0c0027b7          	lui	a5,0xc002
    80006168:	97ba                	add	a5,a5,a4
    8000616a:	40200713          	li	a4,1026
    8000616e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006172:	00d5151b          	slliw	a0,a0,0xd
    80006176:	0c2017b7          	lui	a5,0xc201
    8000617a:	953e                	add	a0,a0,a5
    8000617c:	00052023          	sw	zero,0(a0)
}
    80006180:	60a2                	ld	ra,8(sp)
    80006182:	6402                	ld	s0,0(sp)
    80006184:	0141                	addi	sp,sp,16
    80006186:	8082                	ret

0000000080006188 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006188:	1141                	addi	sp,sp,-16
    8000618a:	e406                	sd	ra,8(sp)
    8000618c:	e022                	sd	s0,0(sp)
    8000618e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006190:	ffffc097          	auipc	ra,0xffffc
    80006194:	bfa080e7          	jalr	-1030(ra) # 80001d8a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006198:	00d5179b          	slliw	a5,a0,0xd
    8000619c:	0c201537          	lui	a0,0xc201
    800061a0:	953e                	add	a0,a0,a5
  return irq;
}
    800061a2:	4148                	lw	a0,4(a0)
    800061a4:	60a2                	ld	ra,8(sp)
    800061a6:	6402                	ld	s0,0(sp)
    800061a8:	0141                	addi	sp,sp,16
    800061aa:	8082                	ret

00000000800061ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061ac:	1101                	addi	sp,sp,-32
    800061ae:	ec06                	sd	ra,24(sp)
    800061b0:	e822                	sd	s0,16(sp)
    800061b2:	e426                	sd	s1,8(sp)
    800061b4:	1000                	addi	s0,sp,32
    800061b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800061b8:	ffffc097          	auipc	ra,0xffffc
    800061bc:	bd2080e7          	jalr	-1070(ra) # 80001d8a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800061c0:	00d5151b          	slliw	a0,a0,0xd
    800061c4:	0c2017b7          	lui	a5,0xc201
    800061c8:	97aa                	add	a5,a5,a0
    800061ca:	c3c4                	sw	s1,4(a5)
}
    800061cc:	60e2                	ld	ra,24(sp)
    800061ce:	6442                	ld	s0,16(sp)
    800061d0:	64a2                	ld	s1,8(sp)
    800061d2:	6105                	addi	sp,sp,32
    800061d4:	8082                	ret

00000000800061d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800061d6:	1141                	addi	sp,sp,-16
    800061d8:	e406                	sd	ra,8(sp)
    800061da:	e022                	sd	s0,0(sp)
    800061dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800061de:	479d                	li	a5,7
    800061e0:	06a7c963          	blt	a5,a0,80006252 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800061e4:	00024797          	auipc	a5,0x24
    800061e8:	e1c78793          	addi	a5,a5,-484 # 8002a000 <disk>
    800061ec:	00a78733          	add	a4,a5,a0
    800061f0:	6789                	lui	a5,0x2
    800061f2:	97ba                	add	a5,a5,a4
    800061f4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800061f8:	e7ad                	bnez	a5,80006262 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800061fa:	00451793          	slli	a5,a0,0x4
    800061fe:	00026717          	auipc	a4,0x26
    80006202:	e0270713          	addi	a4,a4,-510 # 8002c000 <disk+0x2000>
    80006206:	6314                	ld	a3,0(a4)
    80006208:	96be                	add	a3,a3,a5
    8000620a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000620e:	6314                	ld	a3,0(a4)
    80006210:	96be                	add	a3,a3,a5
    80006212:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006216:	6314                	ld	a3,0(a4)
    80006218:	96be                	add	a3,a3,a5
    8000621a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000621e:	6318                	ld	a4,0(a4)
    80006220:	97ba                	add	a5,a5,a4
    80006222:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006226:	00024797          	auipc	a5,0x24
    8000622a:	dda78793          	addi	a5,a5,-550 # 8002a000 <disk>
    8000622e:	97aa                	add	a5,a5,a0
    80006230:	6509                	lui	a0,0x2
    80006232:	953e                	add	a0,a0,a5
    80006234:	4785                	li	a5,1
    80006236:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000623a:	00026517          	auipc	a0,0x26
    8000623e:	dde50513          	addi	a0,a0,-546 # 8002c018 <disk+0x2018>
    80006242:	ffffc097          	auipc	ra,0xffffc
    80006246:	50a080e7          	jalr	1290(ra) # 8000274c <wakeup>
}
    8000624a:	60a2                	ld	ra,8(sp)
    8000624c:	6402                	ld	s0,0(sp)
    8000624e:	0141                	addi	sp,sp,16
    80006250:	8082                	ret
    panic("free_desc 1");
    80006252:	00002517          	auipc	a0,0x2
    80006256:	5a650513          	addi	a0,a0,1446 # 800087f8 <syscalls+0x338>
    8000625a:	ffffa097          	auipc	ra,0xffffa
    8000625e:	2f6080e7          	jalr	758(ra) # 80000550 <panic>
    panic("free_desc 2");
    80006262:	00002517          	auipc	a0,0x2
    80006266:	5a650513          	addi	a0,a0,1446 # 80008808 <syscalls+0x348>
    8000626a:	ffffa097          	auipc	ra,0xffffa
    8000626e:	2e6080e7          	jalr	742(ra) # 80000550 <panic>

0000000080006272 <virtio_disk_init>:
{
    80006272:	1101                	addi	sp,sp,-32
    80006274:	ec06                	sd	ra,24(sp)
    80006276:	e822                	sd	s0,16(sp)
    80006278:	e426                	sd	s1,8(sp)
    8000627a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000627c:	00002597          	auipc	a1,0x2
    80006280:	59c58593          	addi	a1,a1,1436 # 80008818 <syscalls+0x358>
    80006284:	00026517          	auipc	a0,0x26
    80006288:	ea450513          	addi	a0,a0,-348 # 8002c128 <disk+0x2128>
    8000628c:	ffffb097          	auipc	ra,0xffffb
    80006290:	c5e080e7          	jalr	-930(ra) # 80000eea <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006294:	100017b7          	lui	a5,0x10001
    80006298:	4398                	lw	a4,0(a5)
    8000629a:	2701                	sext.w	a4,a4
    8000629c:	747277b7          	lui	a5,0x74727
    800062a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062a4:	0ef71163          	bne	a4,a5,80006386 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800062a8:	100017b7          	lui	a5,0x10001
    800062ac:	43dc                	lw	a5,4(a5)
    800062ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062b0:	4705                	li	a4,1
    800062b2:	0ce79a63          	bne	a5,a4,80006386 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062b6:	100017b7          	lui	a5,0x10001
    800062ba:	479c                	lw	a5,8(a5)
    800062bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800062be:	4709                	li	a4,2
    800062c0:	0ce79363          	bne	a5,a4,80006386 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062c4:	100017b7          	lui	a5,0x10001
    800062c8:	47d8                	lw	a4,12(a5)
    800062ca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062cc:	554d47b7          	lui	a5,0x554d4
    800062d0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062d4:	0af71963          	bne	a4,a5,80006386 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062d8:	100017b7          	lui	a5,0x10001
    800062dc:	4705                	li	a4,1
    800062de:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062e0:	470d                	li	a4,3
    800062e2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800062e4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800062e6:	c7ffe737          	lui	a4,0xc7ffe
    800062ea:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd0737>
    800062ee:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062f0:	2701                	sext.w	a4,a4
    800062f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062f4:	472d                	li	a4,11
    800062f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062f8:	473d                	li	a4,15
    800062fa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800062fc:	6705                	lui	a4,0x1
    800062fe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006300:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006304:	5bdc                	lw	a5,52(a5)
    80006306:	2781                	sext.w	a5,a5
  if(max == 0)
    80006308:	c7d9                	beqz	a5,80006396 <virtio_disk_init+0x124>
  if(max < NUM)
    8000630a:	471d                	li	a4,7
    8000630c:	08f77d63          	bgeu	a4,a5,800063a6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006310:	100014b7          	lui	s1,0x10001
    80006314:	47a1                	li	a5,8
    80006316:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006318:	6609                	lui	a2,0x2
    8000631a:	4581                	li	a1,0
    8000631c:	00024517          	auipc	a0,0x24
    80006320:	ce450513          	addi	a0,a0,-796 # 8002a000 <disk>
    80006324:	ffffb097          	auipc	ra,0xffffb
    80006328:	e2a080e7          	jalr	-470(ra) # 8000114e <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000632c:	00024717          	auipc	a4,0x24
    80006330:	cd470713          	addi	a4,a4,-812 # 8002a000 <disk>
    80006334:	00c75793          	srli	a5,a4,0xc
    80006338:	2781                	sext.w	a5,a5
    8000633a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000633c:	00026797          	auipc	a5,0x26
    80006340:	cc478793          	addi	a5,a5,-828 # 8002c000 <disk+0x2000>
    80006344:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006346:	00024717          	auipc	a4,0x24
    8000634a:	d3a70713          	addi	a4,a4,-710 # 8002a080 <disk+0x80>
    8000634e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006350:	00025717          	auipc	a4,0x25
    80006354:	cb070713          	addi	a4,a4,-848 # 8002b000 <disk+0x1000>
    80006358:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000635a:	4705                	li	a4,1
    8000635c:	00e78c23          	sb	a4,24(a5)
    80006360:	00e78ca3          	sb	a4,25(a5)
    80006364:	00e78d23          	sb	a4,26(a5)
    80006368:	00e78da3          	sb	a4,27(a5)
    8000636c:	00e78e23          	sb	a4,28(a5)
    80006370:	00e78ea3          	sb	a4,29(a5)
    80006374:	00e78f23          	sb	a4,30(a5)
    80006378:	00e78fa3          	sb	a4,31(a5)
}
    8000637c:	60e2                	ld	ra,24(sp)
    8000637e:	6442                	ld	s0,16(sp)
    80006380:	64a2                	ld	s1,8(sp)
    80006382:	6105                	addi	sp,sp,32
    80006384:	8082                	ret
    panic("could not find virtio disk");
    80006386:	00002517          	auipc	a0,0x2
    8000638a:	4a250513          	addi	a0,a0,1186 # 80008828 <syscalls+0x368>
    8000638e:	ffffa097          	auipc	ra,0xffffa
    80006392:	1c2080e7          	jalr	450(ra) # 80000550 <panic>
    panic("virtio disk has no queue 0");
    80006396:	00002517          	auipc	a0,0x2
    8000639a:	4b250513          	addi	a0,a0,1202 # 80008848 <syscalls+0x388>
    8000639e:	ffffa097          	auipc	ra,0xffffa
    800063a2:	1b2080e7          	jalr	434(ra) # 80000550 <panic>
    panic("virtio disk max queue too short");
    800063a6:	00002517          	auipc	a0,0x2
    800063aa:	4c250513          	addi	a0,a0,1218 # 80008868 <syscalls+0x3a8>
    800063ae:	ffffa097          	auipc	ra,0xffffa
    800063b2:	1a2080e7          	jalr	418(ra) # 80000550 <panic>

00000000800063b6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063b6:	7159                	addi	sp,sp,-112
    800063b8:	f486                	sd	ra,104(sp)
    800063ba:	f0a2                	sd	s0,96(sp)
    800063bc:	eca6                	sd	s1,88(sp)
    800063be:	e8ca                	sd	s2,80(sp)
    800063c0:	e4ce                	sd	s3,72(sp)
    800063c2:	e0d2                	sd	s4,64(sp)
    800063c4:	fc56                	sd	s5,56(sp)
    800063c6:	f85a                	sd	s6,48(sp)
    800063c8:	f45e                	sd	s7,40(sp)
    800063ca:	f062                	sd	s8,32(sp)
    800063cc:	ec66                	sd	s9,24(sp)
    800063ce:	e86a                	sd	s10,16(sp)
    800063d0:	1880                	addi	s0,sp,112
    800063d2:	892a                	mv	s2,a0
    800063d4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800063d6:	00c52c83          	lw	s9,12(a0)
    800063da:	001c9c9b          	slliw	s9,s9,0x1
    800063de:	1c82                	slli	s9,s9,0x20
    800063e0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800063e4:	00026517          	auipc	a0,0x26
    800063e8:	d4450513          	addi	a0,a0,-700 # 8002c128 <disk+0x2128>
    800063ec:	ffffb097          	auipc	ra,0xffffb
    800063f0:	982080e7          	jalr	-1662(ra) # 80000d6e <acquire>
  for(int i = 0; i < 3; i++){
    800063f4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800063f6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800063f8:	00024b97          	auipc	s7,0x24
    800063fc:	c08b8b93          	addi	s7,s7,-1016 # 8002a000 <disk>
    80006400:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006402:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006404:	8a4e                	mv	s4,s3
    80006406:	a051                	j	8000648a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80006408:	00fb86b3          	add	a3,s7,a5
    8000640c:	96da                	add	a3,a3,s6
    8000640e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006412:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006414:	0207c563          	bltz	a5,8000643e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006418:	2485                	addiw	s1,s1,1
    8000641a:	0711                	addi	a4,a4,4
    8000641c:	25548063          	beq	s1,s5,8000665c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006420:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006422:	00026697          	auipc	a3,0x26
    80006426:	bf668693          	addi	a3,a3,-1034 # 8002c018 <disk+0x2018>
    8000642a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000642c:	0006c583          	lbu	a1,0(a3)
    80006430:	fde1                	bnez	a1,80006408 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006432:	2785                	addiw	a5,a5,1
    80006434:	0685                	addi	a3,a3,1
    80006436:	ff879be3          	bne	a5,s8,8000642c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000643a:	57fd                	li	a5,-1
    8000643c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000643e:	02905a63          	blez	s1,80006472 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006442:	f9042503          	lw	a0,-112(s0)
    80006446:	00000097          	auipc	ra,0x0
    8000644a:	d90080e7          	jalr	-624(ra) # 800061d6 <free_desc>
      for(int j = 0; j < i; j++)
    8000644e:	4785                	li	a5,1
    80006450:	0297d163          	bge	a5,s1,80006472 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006454:	f9442503          	lw	a0,-108(s0)
    80006458:	00000097          	auipc	ra,0x0
    8000645c:	d7e080e7          	jalr	-642(ra) # 800061d6 <free_desc>
      for(int j = 0; j < i; j++)
    80006460:	4789                	li	a5,2
    80006462:	0097d863          	bge	a5,s1,80006472 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006466:	f9842503          	lw	a0,-104(s0)
    8000646a:	00000097          	auipc	ra,0x0
    8000646e:	d6c080e7          	jalr	-660(ra) # 800061d6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006472:	00026597          	auipc	a1,0x26
    80006476:	cb658593          	addi	a1,a1,-842 # 8002c128 <disk+0x2128>
    8000647a:	00026517          	auipc	a0,0x26
    8000647e:	b9e50513          	addi	a0,a0,-1122 # 8002c018 <disk+0x2018>
    80006482:	ffffc097          	auipc	ra,0xffffc
    80006486:	144080e7          	jalr	324(ra) # 800025c6 <sleep>
  for(int i = 0; i < 3; i++){
    8000648a:	f9040713          	addi	a4,s0,-112
    8000648e:	84ce                	mv	s1,s3
    80006490:	bf41                	j	80006420 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006492:	20058713          	addi	a4,a1,512
    80006496:	00471693          	slli	a3,a4,0x4
    8000649a:	00024717          	auipc	a4,0x24
    8000649e:	b6670713          	addi	a4,a4,-1178 # 8002a000 <disk>
    800064a2:	9736                	add	a4,a4,a3
    800064a4:	4685                	li	a3,1
    800064a6:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800064aa:	20058713          	addi	a4,a1,512
    800064ae:	00471693          	slli	a3,a4,0x4
    800064b2:	00024717          	auipc	a4,0x24
    800064b6:	b4e70713          	addi	a4,a4,-1202 # 8002a000 <disk>
    800064ba:	9736                	add	a4,a4,a3
    800064bc:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800064c0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800064c4:	7679                	lui	a2,0xffffe
    800064c6:	963e                	add	a2,a2,a5
    800064c8:	00026697          	auipc	a3,0x26
    800064cc:	b3868693          	addi	a3,a3,-1224 # 8002c000 <disk+0x2000>
    800064d0:	6298                	ld	a4,0(a3)
    800064d2:	9732                	add	a4,a4,a2
    800064d4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064d6:	6298                	ld	a4,0(a3)
    800064d8:	9732                	add	a4,a4,a2
    800064da:	4541                	li	a0,16
    800064dc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064de:	6298                	ld	a4,0(a3)
    800064e0:	9732                	add	a4,a4,a2
    800064e2:	4505                	li	a0,1
    800064e4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800064e8:	f9442703          	lw	a4,-108(s0)
    800064ec:	6288                	ld	a0,0(a3)
    800064ee:	962a                	add	a2,a2,a0
    800064f0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffcffe6>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800064f4:	0712                	slli	a4,a4,0x4
    800064f6:	6290                	ld	a2,0(a3)
    800064f8:	963a                	add	a2,a2,a4
    800064fa:	05890513          	addi	a0,s2,88
    800064fe:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006500:	6294                	ld	a3,0(a3)
    80006502:	96ba                	add	a3,a3,a4
    80006504:	40000613          	li	a2,1024
    80006508:	c690                	sw	a2,8(a3)
  if(write)
    8000650a:	140d0063          	beqz	s10,8000664a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000650e:	00026697          	auipc	a3,0x26
    80006512:	af26b683          	ld	a3,-1294(a3) # 8002c000 <disk+0x2000>
    80006516:	96ba                	add	a3,a3,a4
    80006518:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000651c:	00024817          	auipc	a6,0x24
    80006520:	ae480813          	addi	a6,a6,-1308 # 8002a000 <disk>
    80006524:	00026517          	auipc	a0,0x26
    80006528:	adc50513          	addi	a0,a0,-1316 # 8002c000 <disk+0x2000>
    8000652c:	6114                	ld	a3,0(a0)
    8000652e:	96ba                	add	a3,a3,a4
    80006530:	00c6d603          	lhu	a2,12(a3)
    80006534:	00166613          	ori	a2,a2,1
    80006538:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000653c:	f9842683          	lw	a3,-104(s0)
    80006540:	6110                	ld	a2,0(a0)
    80006542:	9732                	add	a4,a4,a2
    80006544:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006548:	20058613          	addi	a2,a1,512
    8000654c:	0612                	slli	a2,a2,0x4
    8000654e:	9642                	add	a2,a2,a6
    80006550:	577d                	li	a4,-1
    80006552:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006556:	00469713          	slli	a4,a3,0x4
    8000655a:	6114                	ld	a3,0(a0)
    8000655c:	96ba                	add	a3,a3,a4
    8000655e:	03078793          	addi	a5,a5,48
    80006562:	97c2                	add	a5,a5,a6
    80006564:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80006566:	611c                	ld	a5,0(a0)
    80006568:	97ba                	add	a5,a5,a4
    8000656a:	4685                	li	a3,1
    8000656c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000656e:	611c                	ld	a5,0(a0)
    80006570:	97ba                	add	a5,a5,a4
    80006572:	4809                	li	a6,2
    80006574:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006578:	611c                	ld	a5,0(a0)
    8000657a:	973e                	add	a4,a4,a5
    8000657c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006580:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006584:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006588:	6518                	ld	a4,8(a0)
    8000658a:	00275783          	lhu	a5,2(a4)
    8000658e:	8b9d                	andi	a5,a5,7
    80006590:	0786                	slli	a5,a5,0x1
    80006592:	97ba                	add	a5,a5,a4
    80006594:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006598:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000659c:	6518                	ld	a4,8(a0)
    8000659e:	00275783          	lhu	a5,2(a4)
    800065a2:	2785                	addiw	a5,a5,1
    800065a4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065a8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065ac:	100017b7          	lui	a5,0x10001
    800065b0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065b4:	00492703          	lw	a4,4(s2)
    800065b8:	4785                	li	a5,1
    800065ba:	02f71163          	bne	a4,a5,800065dc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800065be:	00026997          	auipc	s3,0x26
    800065c2:	b6a98993          	addi	s3,s3,-1174 # 8002c128 <disk+0x2128>
  while(b->disk == 1) {
    800065c6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800065c8:	85ce                	mv	a1,s3
    800065ca:	854a                	mv	a0,s2
    800065cc:	ffffc097          	auipc	ra,0xffffc
    800065d0:	ffa080e7          	jalr	-6(ra) # 800025c6 <sleep>
  while(b->disk == 1) {
    800065d4:	00492783          	lw	a5,4(s2)
    800065d8:	fe9788e3          	beq	a5,s1,800065c8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800065dc:	f9042903          	lw	s2,-112(s0)
    800065e0:	20090793          	addi	a5,s2,512
    800065e4:	00479713          	slli	a4,a5,0x4
    800065e8:	00024797          	auipc	a5,0x24
    800065ec:	a1878793          	addi	a5,a5,-1512 # 8002a000 <disk>
    800065f0:	97ba                	add	a5,a5,a4
    800065f2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800065f6:	00026997          	auipc	s3,0x26
    800065fa:	a0a98993          	addi	s3,s3,-1526 # 8002c000 <disk+0x2000>
    800065fe:	00491713          	slli	a4,s2,0x4
    80006602:	0009b783          	ld	a5,0(s3)
    80006606:	97ba                	add	a5,a5,a4
    80006608:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000660c:	854a                	mv	a0,s2
    8000660e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006612:	00000097          	auipc	ra,0x0
    80006616:	bc4080e7          	jalr	-1084(ra) # 800061d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000661a:	8885                	andi	s1,s1,1
    8000661c:	f0ed                	bnez	s1,800065fe <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000661e:	00026517          	auipc	a0,0x26
    80006622:	b0a50513          	addi	a0,a0,-1270 # 8002c128 <disk+0x2128>
    80006626:	ffffb097          	auipc	ra,0xffffb
    8000662a:	818080e7          	jalr	-2024(ra) # 80000e3e <release>
}
    8000662e:	70a6                	ld	ra,104(sp)
    80006630:	7406                	ld	s0,96(sp)
    80006632:	64e6                	ld	s1,88(sp)
    80006634:	6946                	ld	s2,80(sp)
    80006636:	69a6                	ld	s3,72(sp)
    80006638:	6a06                	ld	s4,64(sp)
    8000663a:	7ae2                	ld	s5,56(sp)
    8000663c:	7b42                	ld	s6,48(sp)
    8000663e:	7ba2                	ld	s7,40(sp)
    80006640:	7c02                	ld	s8,32(sp)
    80006642:	6ce2                	ld	s9,24(sp)
    80006644:	6d42                	ld	s10,16(sp)
    80006646:	6165                	addi	sp,sp,112
    80006648:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000664a:	00026697          	auipc	a3,0x26
    8000664e:	9b66b683          	ld	a3,-1610(a3) # 8002c000 <disk+0x2000>
    80006652:	96ba                	add	a3,a3,a4
    80006654:	4609                	li	a2,2
    80006656:	00c69623          	sh	a2,12(a3)
    8000665a:	b5c9                	j	8000651c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000665c:	f9042583          	lw	a1,-112(s0)
    80006660:	20058793          	addi	a5,a1,512
    80006664:	0792                	slli	a5,a5,0x4
    80006666:	00024517          	auipc	a0,0x24
    8000666a:	a4250513          	addi	a0,a0,-1470 # 8002a0a8 <disk+0xa8>
    8000666e:	953e                	add	a0,a0,a5
  if(write)
    80006670:	e20d11e3          	bnez	s10,80006492 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006674:	20058713          	addi	a4,a1,512
    80006678:	00471693          	slli	a3,a4,0x4
    8000667c:	00024717          	auipc	a4,0x24
    80006680:	98470713          	addi	a4,a4,-1660 # 8002a000 <disk>
    80006684:	9736                	add	a4,a4,a3
    80006686:	0a072423          	sw	zero,168(a4)
    8000668a:	b505                	j	800064aa <virtio_disk_rw+0xf4>

000000008000668c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000668c:	1101                	addi	sp,sp,-32
    8000668e:	ec06                	sd	ra,24(sp)
    80006690:	e822                	sd	s0,16(sp)
    80006692:	e426                	sd	s1,8(sp)
    80006694:	e04a                	sd	s2,0(sp)
    80006696:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006698:	00026517          	auipc	a0,0x26
    8000669c:	a9050513          	addi	a0,a0,-1392 # 8002c128 <disk+0x2128>
    800066a0:	ffffa097          	auipc	ra,0xffffa
    800066a4:	6ce080e7          	jalr	1742(ra) # 80000d6e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066a8:	10001737          	lui	a4,0x10001
    800066ac:	533c                	lw	a5,96(a4)
    800066ae:	8b8d                	andi	a5,a5,3
    800066b0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066b2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066b6:	00026797          	auipc	a5,0x26
    800066ba:	94a78793          	addi	a5,a5,-1718 # 8002c000 <disk+0x2000>
    800066be:	6b94                	ld	a3,16(a5)
    800066c0:	0207d703          	lhu	a4,32(a5)
    800066c4:	0026d783          	lhu	a5,2(a3)
    800066c8:	06f70163          	beq	a4,a5,8000672a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066cc:	00024917          	auipc	s2,0x24
    800066d0:	93490913          	addi	s2,s2,-1740 # 8002a000 <disk>
    800066d4:	00026497          	auipc	s1,0x26
    800066d8:	92c48493          	addi	s1,s1,-1748 # 8002c000 <disk+0x2000>
    __sync_synchronize();
    800066dc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066e0:	6898                	ld	a4,16(s1)
    800066e2:	0204d783          	lhu	a5,32(s1)
    800066e6:	8b9d                	andi	a5,a5,7
    800066e8:	078e                	slli	a5,a5,0x3
    800066ea:	97ba                	add	a5,a5,a4
    800066ec:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066ee:	20078713          	addi	a4,a5,512
    800066f2:	0712                	slli	a4,a4,0x4
    800066f4:	974a                	add	a4,a4,s2
    800066f6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800066fa:	e731                	bnez	a4,80006746 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800066fc:	20078793          	addi	a5,a5,512
    80006700:	0792                	slli	a5,a5,0x4
    80006702:	97ca                	add	a5,a5,s2
    80006704:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006706:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000670a:	ffffc097          	auipc	ra,0xffffc
    8000670e:	042080e7          	jalr	66(ra) # 8000274c <wakeup>

    disk.used_idx += 1;
    80006712:	0204d783          	lhu	a5,32(s1)
    80006716:	2785                	addiw	a5,a5,1
    80006718:	17c2                	slli	a5,a5,0x30
    8000671a:	93c1                	srli	a5,a5,0x30
    8000671c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006720:	6898                	ld	a4,16(s1)
    80006722:	00275703          	lhu	a4,2(a4)
    80006726:	faf71be3          	bne	a4,a5,800066dc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000672a:	00026517          	auipc	a0,0x26
    8000672e:	9fe50513          	addi	a0,a0,-1538 # 8002c128 <disk+0x2128>
    80006732:	ffffa097          	auipc	ra,0xffffa
    80006736:	70c080e7          	jalr	1804(ra) # 80000e3e <release>
}
    8000673a:	60e2                	ld	ra,24(sp)
    8000673c:	6442                	ld	s0,16(sp)
    8000673e:	64a2                	ld	s1,8(sp)
    80006740:	6902                	ld	s2,0(sp)
    80006742:	6105                	addi	sp,sp,32
    80006744:	8082                	ret
      panic("virtio_disk_intr status");
    80006746:	00002517          	auipc	a0,0x2
    8000674a:	14250513          	addi	a0,a0,322 # 80008888 <syscalls+0x3c8>
    8000674e:	ffffa097          	auipc	ra,0xffffa
    80006752:	e02080e7          	jalr	-510(ra) # 80000550 <panic>

0000000080006756 <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    80006756:	1141                	addi	sp,sp,-16
    80006758:	e422                	sd	s0,8(sp)
    8000675a:	0800                	addi	s0,sp,16
  return -1;
}
    8000675c:	557d                	li	a0,-1
    8000675e:	6422                	ld	s0,8(sp)
    80006760:	0141                	addi	sp,sp,16
    80006762:	8082                	ret

0000000080006764 <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    80006764:	7179                	addi	sp,sp,-48
    80006766:	f406                	sd	ra,40(sp)
    80006768:	f022                	sd	s0,32(sp)
    8000676a:	ec26                	sd	s1,24(sp)
    8000676c:	e84a                	sd	s2,16(sp)
    8000676e:	e44e                	sd	s3,8(sp)
    80006770:	e052                	sd	s4,0(sp)
    80006772:	1800                	addi	s0,sp,48
    80006774:	892a                	mv	s2,a0
    80006776:	89ae                	mv	s3,a1
    80006778:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    8000677a:	00027517          	auipc	a0,0x27
    8000677e:	88650513          	addi	a0,a0,-1914 # 8002d000 <stats>
    80006782:	ffffa097          	auipc	ra,0xffffa
    80006786:	5ec080e7          	jalr	1516(ra) # 80000d6e <acquire>

  if(stats.sz == 0) {
    8000678a:	00028797          	auipc	a5,0x28
    8000678e:	8967a783          	lw	a5,-1898(a5) # 8002e020 <stats+0x1020>
    80006792:	cbb5                	beqz	a5,80006806 <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    80006794:	00028797          	auipc	a5,0x28
    80006798:	86c78793          	addi	a5,a5,-1940 # 8002e000 <stats+0x1000>
    8000679c:	53d8                	lw	a4,36(a5)
    8000679e:	539c                	lw	a5,32(a5)
    800067a0:	9f99                	subw	a5,a5,a4
    800067a2:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    800067a6:	06d05e63          	blez	a3,80006822 <statsread+0xbe>
    if(m > n)
    800067aa:	8a3e                	mv	s4,a5
    800067ac:	00d4d363          	bge	s1,a3,800067b2 <statsread+0x4e>
    800067b0:	8a26                	mv	s4,s1
    800067b2:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    800067b6:	86a6                	mv	a3,s1
    800067b8:	00027617          	auipc	a2,0x27
    800067bc:	86860613          	addi	a2,a2,-1944 # 8002d020 <stats+0x20>
    800067c0:	963a                	add	a2,a2,a4
    800067c2:	85ce                	mv	a1,s3
    800067c4:	854a                	mv	a0,s2
    800067c6:	ffffc097          	auipc	ra,0xffffc
    800067ca:	062080e7          	jalr	98(ra) # 80002828 <either_copyout>
    800067ce:	57fd                	li	a5,-1
    800067d0:	00f50a63          	beq	a0,a5,800067e4 <statsread+0x80>
      stats.off += m;
    800067d4:	00028717          	auipc	a4,0x28
    800067d8:	82c70713          	addi	a4,a4,-2004 # 8002e000 <stats+0x1000>
    800067dc:	535c                	lw	a5,36(a4)
    800067de:	014787bb          	addw	a5,a5,s4
    800067e2:	d35c                	sw	a5,36(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    800067e4:	00027517          	auipc	a0,0x27
    800067e8:	81c50513          	addi	a0,a0,-2020 # 8002d000 <stats>
    800067ec:	ffffa097          	auipc	ra,0xffffa
    800067f0:	652080e7          	jalr	1618(ra) # 80000e3e <release>
  return m;
}
    800067f4:	8526                	mv	a0,s1
    800067f6:	70a2                	ld	ra,40(sp)
    800067f8:	7402                	ld	s0,32(sp)
    800067fa:	64e2                	ld	s1,24(sp)
    800067fc:	6942                	ld	s2,16(sp)
    800067fe:	69a2                	ld	s3,8(sp)
    80006800:	6a02                	ld	s4,0(sp)
    80006802:	6145                	addi	sp,sp,48
    80006804:	8082                	ret
    stats.sz = statslock(stats.buf, BUFSZ);
    80006806:	6585                	lui	a1,0x1
    80006808:	00027517          	auipc	a0,0x27
    8000680c:	81850513          	addi	a0,a0,-2024 # 8002d020 <stats+0x20>
    80006810:	ffffa097          	auipc	ra,0xffffa
    80006814:	788080e7          	jalr	1928(ra) # 80000f98 <statslock>
    80006818:	00028797          	auipc	a5,0x28
    8000681c:	80a7a423          	sw	a0,-2040(a5) # 8002e020 <stats+0x1020>
    80006820:	bf95                	j	80006794 <statsread+0x30>
    stats.sz = 0;
    80006822:	00027797          	auipc	a5,0x27
    80006826:	7de78793          	addi	a5,a5,2014 # 8002e000 <stats+0x1000>
    8000682a:	0207a023          	sw	zero,32(a5)
    stats.off = 0;
    8000682e:	0207a223          	sw	zero,36(a5)
    m = -1;
    80006832:	54fd                	li	s1,-1
    80006834:	bf45                	j	800067e4 <statsread+0x80>

0000000080006836 <statsinit>:

void
statsinit(void)
{
    80006836:	1141                	addi	sp,sp,-16
    80006838:	e406                	sd	ra,8(sp)
    8000683a:	e022                	sd	s0,0(sp)
    8000683c:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    8000683e:	00002597          	auipc	a1,0x2
    80006842:	06258593          	addi	a1,a1,98 # 800088a0 <syscalls+0x3e0>
    80006846:	00026517          	auipc	a0,0x26
    8000684a:	7ba50513          	addi	a0,a0,1978 # 8002d000 <stats>
    8000684e:	ffffa097          	auipc	ra,0xffffa
    80006852:	69c080e7          	jalr	1692(ra) # 80000eea <initlock>

  devsw[STATS].read = statsread;
    80006856:	00022797          	auipc	a5,0x22
    8000685a:	e0278793          	addi	a5,a5,-510 # 80028658 <devsw>
    8000685e:	00000717          	auipc	a4,0x0
    80006862:	f0670713          	addi	a4,a4,-250 # 80006764 <statsread>
    80006866:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    80006868:	00000717          	auipc	a4,0x0
    8000686c:	eee70713          	addi	a4,a4,-274 # 80006756 <statswrite>
    80006870:	f798                	sd	a4,40(a5)
}
    80006872:	60a2                	ld	ra,8(sp)
    80006874:	6402                	ld	s0,0(sp)
    80006876:	0141                	addi	sp,sp,16
    80006878:	8082                	ret

000000008000687a <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    8000687a:	1101                	addi	sp,sp,-32
    8000687c:	ec22                	sd	s0,24(sp)
    8000687e:	1000                	addi	s0,sp,32
    80006880:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    80006882:	c299                	beqz	a3,80006888 <sprintint+0xe>
    80006884:	0805c163          	bltz	a1,80006906 <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    80006888:	2581                	sext.w	a1,a1
    8000688a:	4301                	li	t1,0

  i = 0;
    8000688c:	fe040713          	addi	a4,s0,-32
    80006890:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    80006892:	2601                	sext.w	a2,a2
    80006894:	00002697          	auipc	a3,0x2
    80006898:	01468693          	addi	a3,a3,20 # 800088a8 <digits>
    8000689c:	88aa                	mv	a7,a0
    8000689e:	2505                	addiw	a0,a0,1
    800068a0:	02c5f7bb          	remuw	a5,a1,a2
    800068a4:	1782                	slli	a5,a5,0x20
    800068a6:	9381                	srli	a5,a5,0x20
    800068a8:	97b6                	add	a5,a5,a3
    800068aa:	0007c783          	lbu	a5,0(a5)
    800068ae:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    800068b2:	0005879b          	sext.w	a5,a1
    800068b6:	02c5d5bb          	divuw	a1,a1,a2
    800068ba:	0705                	addi	a4,a4,1
    800068bc:	fec7f0e3          	bgeu	a5,a2,8000689c <sprintint+0x22>

  if(sign)
    800068c0:	00030b63          	beqz	t1,800068d6 <sprintint+0x5c>
    buf[i++] = '-';
    800068c4:	ff040793          	addi	a5,s0,-16
    800068c8:	97aa                	add	a5,a5,a0
    800068ca:	02d00713          	li	a4,45
    800068ce:	fee78823          	sb	a4,-16(a5)
    800068d2:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    800068d6:	02a05c63          	blez	a0,8000690e <sprintint+0x94>
    800068da:	fe040793          	addi	a5,s0,-32
    800068de:	00a78733          	add	a4,a5,a0
    800068e2:	87c2                	mv	a5,a6
    800068e4:	0805                	addi	a6,a6,1
    800068e6:	fff5061b          	addiw	a2,a0,-1
    800068ea:	1602                	slli	a2,a2,0x20
    800068ec:	9201                	srli	a2,a2,0x20
    800068ee:	9642                	add	a2,a2,a6
  *s = c;
    800068f0:	fff74683          	lbu	a3,-1(a4)
    800068f4:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    800068f8:	177d                	addi	a4,a4,-1
    800068fa:	0785                	addi	a5,a5,1
    800068fc:	fec79ae3          	bne	a5,a2,800068f0 <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    80006900:	6462                	ld	s0,24(sp)
    80006902:	6105                	addi	sp,sp,32
    80006904:	8082                	ret
    x = -xx;
    80006906:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    8000690a:	4305                	li	t1,1
    x = -xx;
    8000690c:	b741                	j	8000688c <sprintint+0x12>
  while(--i >= 0)
    8000690e:	4501                	li	a0,0
    80006910:	bfc5                	j	80006900 <sprintint+0x86>

0000000080006912 <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    80006912:	7171                	addi	sp,sp,-176
    80006914:	fc86                	sd	ra,120(sp)
    80006916:	f8a2                	sd	s0,112(sp)
    80006918:	f4a6                	sd	s1,104(sp)
    8000691a:	f0ca                	sd	s2,96(sp)
    8000691c:	ecce                	sd	s3,88(sp)
    8000691e:	e8d2                	sd	s4,80(sp)
    80006920:	e4d6                	sd	s5,72(sp)
    80006922:	e0da                	sd	s6,64(sp)
    80006924:	fc5e                	sd	s7,56(sp)
    80006926:	f862                	sd	s8,48(sp)
    80006928:	f466                	sd	s9,40(sp)
    8000692a:	f06a                	sd	s10,32(sp)
    8000692c:	ec6e                	sd	s11,24(sp)
    8000692e:	0100                	addi	s0,sp,128
    80006930:	e414                	sd	a3,8(s0)
    80006932:	e818                	sd	a4,16(s0)
    80006934:	ec1c                	sd	a5,24(s0)
    80006936:	03043023          	sd	a6,32(s0)
    8000693a:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    8000693e:	ca0d                	beqz	a2,80006970 <snprintf+0x5e>
    80006940:	8baa                	mv	s7,a0
    80006942:	89ae                	mv	s3,a1
    80006944:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    80006946:	00840793          	addi	a5,s0,8
    8000694a:	f8f43423          	sd	a5,-120(s0)
  int off = 0;
    8000694e:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006950:	4901                	li	s2,0
    80006952:	02b05763          	blez	a1,80006980 <snprintf+0x6e>
    if(c != '%'){
    80006956:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    8000695a:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    8000695e:	02800d93          	li	s11,40
  *s = c;
    80006962:	02500d13          	li	s10,37
    switch(c){
    80006966:	07800c93          	li	s9,120
    8000696a:	06400c13          	li	s8,100
    8000696e:	a01d                	j	80006994 <snprintf+0x82>
    panic("null fmt");
    80006970:	00001517          	auipc	a0,0x1
    80006974:	6b850513          	addi	a0,a0,1720 # 80008028 <etext+0x28>
    80006978:	ffffa097          	auipc	ra,0xffffa
    8000697c:	bd8080e7          	jalr	-1064(ra) # 80000550 <panic>
  int off = 0;
    80006980:	4481                	li	s1,0
    80006982:	a86d                	j	80006a3c <snprintf+0x12a>
  *s = c;
    80006984:	009b8733          	add	a4,s7,s1
    80006988:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    8000698c:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    8000698e:	2905                	addiw	s2,s2,1
    80006990:	0b34d663          	bge	s1,s3,80006a3c <snprintf+0x12a>
    80006994:	012a07b3          	add	a5,s4,s2
    80006998:	0007c783          	lbu	a5,0(a5)
    8000699c:	0007871b          	sext.w	a4,a5
    800069a0:	cfd1                	beqz	a5,80006a3c <snprintf+0x12a>
    if(c != '%'){
    800069a2:	ff5711e3          	bne	a4,s5,80006984 <snprintf+0x72>
    c = fmt[++i] & 0xff;
    800069a6:	2905                	addiw	s2,s2,1
    800069a8:	012a07b3          	add	a5,s4,s2
    800069ac:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    800069b0:	c7d1                	beqz	a5,80006a3c <snprintf+0x12a>
    switch(c){
    800069b2:	05678c63          	beq	a5,s6,80006a0a <snprintf+0xf8>
    800069b6:	02fb6763          	bltu	s6,a5,800069e4 <snprintf+0xd2>
    800069ba:	0b578763          	beq	a5,s5,80006a68 <snprintf+0x156>
    800069be:	0b879b63          	bne	a5,s8,80006a74 <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    800069c2:	f8843783          	ld	a5,-120(s0)
    800069c6:	00878713          	addi	a4,a5,8
    800069ca:	f8e43423          	sd	a4,-120(s0)
    800069ce:	4685                	li	a3,1
    800069d0:	4629                	li	a2,10
    800069d2:	438c                	lw	a1,0(a5)
    800069d4:	009b8533          	add	a0,s7,s1
    800069d8:	00000097          	auipc	ra,0x0
    800069dc:	ea2080e7          	jalr	-350(ra) # 8000687a <sprintint>
    800069e0:	9ca9                	addw	s1,s1,a0
      break;
    800069e2:	b775                	j	8000698e <snprintf+0x7c>
    switch(c){
    800069e4:	09979863          	bne	a5,s9,80006a74 <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    800069e8:	f8843783          	ld	a5,-120(s0)
    800069ec:	00878713          	addi	a4,a5,8
    800069f0:	f8e43423          	sd	a4,-120(s0)
    800069f4:	4685                	li	a3,1
    800069f6:	4641                	li	a2,16
    800069f8:	438c                	lw	a1,0(a5)
    800069fa:	009b8533          	add	a0,s7,s1
    800069fe:	00000097          	auipc	ra,0x0
    80006a02:	e7c080e7          	jalr	-388(ra) # 8000687a <sprintint>
    80006a06:	9ca9                	addw	s1,s1,a0
      break;
    80006a08:	b759                	j	8000698e <snprintf+0x7c>
      if((s = va_arg(ap, char*)) == 0)
    80006a0a:	f8843783          	ld	a5,-120(s0)
    80006a0e:	00878713          	addi	a4,a5,8
    80006a12:	f8e43423          	sd	a4,-120(s0)
    80006a16:	639c                	ld	a5,0(a5)
    80006a18:	c3b1                	beqz	a5,80006a5c <snprintf+0x14a>
      for(; *s && off < sz; s++)
    80006a1a:	0007c703          	lbu	a4,0(a5)
    80006a1e:	db25                	beqz	a4,8000698e <snprintf+0x7c>
    80006a20:	0134de63          	bge	s1,s3,80006a3c <snprintf+0x12a>
    80006a24:	009b86b3          	add	a3,s7,s1
  *s = c;
    80006a28:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    80006a2c:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    80006a2e:	0785                	addi	a5,a5,1
    80006a30:	0007c703          	lbu	a4,0(a5)
    80006a34:	df29                	beqz	a4,8000698e <snprintf+0x7c>
    80006a36:	0685                	addi	a3,a3,1
    80006a38:	fe9998e3          	bne	s3,s1,80006a28 <snprintf+0x116>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    80006a3c:	8526                	mv	a0,s1
    80006a3e:	70e6                	ld	ra,120(sp)
    80006a40:	7446                	ld	s0,112(sp)
    80006a42:	74a6                	ld	s1,104(sp)
    80006a44:	7906                	ld	s2,96(sp)
    80006a46:	69e6                	ld	s3,88(sp)
    80006a48:	6a46                	ld	s4,80(sp)
    80006a4a:	6aa6                	ld	s5,72(sp)
    80006a4c:	6b06                	ld	s6,64(sp)
    80006a4e:	7be2                	ld	s7,56(sp)
    80006a50:	7c42                	ld	s8,48(sp)
    80006a52:	7ca2                	ld	s9,40(sp)
    80006a54:	7d02                	ld	s10,32(sp)
    80006a56:	6de2                	ld	s11,24(sp)
    80006a58:	614d                	addi	sp,sp,176
    80006a5a:	8082                	ret
        s = "(null)";
    80006a5c:	00001797          	auipc	a5,0x1
    80006a60:	5c478793          	addi	a5,a5,1476 # 80008020 <etext+0x20>
      for(; *s && off < sz; s++)
    80006a64:	876e                	mv	a4,s11
    80006a66:	bf6d                	j	80006a20 <snprintf+0x10e>
  *s = c;
    80006a68:	009b87b3          	add	a5,s7,s1
    80006a6c:	01a78023          	sb	s10,0(a5)
      off += sputc(buf+off, '%');
    80006a70:	2485                	addiw	s1,s1,1
      break;
    80006a72:	bf31                	j	8000698e <snprintf+0x7c>
  *s = c;
    80006a74:	009b8733          	add	a4,s7,s1
    80006a78:	01a70023          	sb	s10,0(a4)
      off += sputc(buf+off, c);
    80006a7c:	0014871b          	addiw	a4,s1,1
  *s = c;
    80006a80:	975e                	add	a4,a4,s7
    80006a82:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006a86:	2489                	addiw	s1,s1,2
      break;
    80006a88:	b719                	j	8000698e <snprintf+0x7c>
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
