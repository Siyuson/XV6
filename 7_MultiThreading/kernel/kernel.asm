
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
    80000068:	adc78793          	addi	a5,a5,-1316 # 80005b40 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e1878793          	addi	a5,a5,-488 # 80000ec6 <main>
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
    80000118:	b04080e7          	jalr	-1276(ra) # 80000c18 <acquire>
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
    80000132:	30e080e7          	jalr	782(ra) # 8000243c <either_copyin>
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
    8000015a:	b76080e7          	jalr	-1162(ra) # 80000ccc <release>

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
    800001aa:	a72080e7          	jalr	-1422(ra) # 80000c18 <acquire>
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
    800001bc:	05090913          	addi	s2,s2,80 # 80011208 <cons+0x98>
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
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	02f71463          	bne	a4,a5,800001fa <consoleread+0x84>
      if(myproc()->killed){
    800001d6:	00001097          	auipc	ra,0x1
    800001da:	79e080e7          	jalr	1950(ra) # 80001974 <myproc>
    800001de:	591c                	lw	a5,48(a0)
    800001e0:	e7b5                	bnez	a5,8000024c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001e2:	85ce                	mv	a1,s3
    800001e4:	854a                	mv	a0,s2
    800001e6:	00002097          	auipc	ra,0x2
    800001ea:	f9e080e7          	jalr	-98(ra) # 80002184 <sleep>
    while(cons.r == cons.w){
    800001ee:	0984a783          	lw	a5,152(s1)
    800001f2:	09c4a703          	lw	a4,156(s1)
    800001f6:	fef700e3          	beq	a4,a5,800001d6 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001fa:	0017871b          	addiw	a4,a5,1
    800001fe:	08e4ac23          	sw	a4,152(s1)
    80000202:	07f7f713          	andi	a4,a5,127
    80000206:	9726                	add	a4,a4,s1
    80000208:	01874703          	lbu	a4,24(a4)
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
    80000226:	1c4080e7          	jalr	452(ra) # 800023e6 <either_copyout>
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
    80000242:	a8e080e7          	jalr	-1394(ra) # 80000ccc <release>

  return target - n;
    80000246:	414b853b          	subw	a0,s7,s4
    8000024a:	a811                	j	8000025e <consoleread+0xe8>
        release(&cons.lock);
    8000024c:	00011517          	auipc	a0,0x11
    80000250:	f2450513          	addi	a0,a0,-220 # 80011170 <cons>
    80000254:	00001097          	auipc	ra,0x1
    80000258:	a78080e7          	jalr	-1416(ra) # 80000ccc <release>
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
    80000288:	f8f72223          	sw	a5,-124(a4) # 80011208 <cons+0x98>
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
    800002ea:	932080e7          	jalr	-1742(ra) # 80000c18 <acquire>

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
    80000308:	18e080e7          	jalr	398(ra) # 80002492 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030c:	00011517          	auipc	a0,0x11
    80000310:	e6450513          	addi	a0,a0,-412 # 80011170 <cons>
    80000314:	00001097          	auipc	ra,0x1
    80000318:	9b8080e7          	jalr	-1608(ra) # 80000ccc <release>
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
    80000338:	0a072783          	lw	a5,160(a4)
    8000033c:	09872703          	lw	a4,152(a4)
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
    80000362:	0a07a703          	lw	a4,160(a5)
    80000366:	0017069b          	addiw	a3,a4,1
    8000036a:	0006861b          	sext.w	a2,a3
    8000036e:	0ad7a023          	sw	a3,160(a5)
    80000372:	07f77713          	andi	a4,a4,127
    80000376:	97ba                	add	a5,a5,a4
    80000378:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000037c:	47a9                	li	a5,10
    8000037e:	0cf48563          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000382:	4791                	li	a5,4
    80000384:	0cf48263          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000388:	00011797          	auipc	a5,0x11
    8000038c:	e807a783          	lw	a5,-384(a5) # 80011208 <cons+0x98>
    80000390:	0807879b          	addiw	a5,a5,128
    80000394:	f6f61ce3          	bne	a2,a5,8000030c <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000398:	863e                	mv	a2,a5
    8000039a:	a07d                	j	80000448 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000039c:	00011717          	auipc	a4,0x11
    800003a0:	dd470713          	addi	a4,a4,-556 # 80011170 <cons>
    800003a4:	0a072783          	lw	a5,160(a4)
    800003a8:	09c72703          	lw	a4,156(a4)
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
    800003c2:	01874703          	lbu	a4,24(a4)
    800003c6:	f52703e3          	beq	a4,s2,8000030c <consoleintr+0x3c>
      cons.e--;
    800003ca:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ce:	10000513          	li	a0,256
    800003d2:	00000097          	auipc	ra,0x0
    800003d6:	ebc080e7          	jalr	-324(ra) # 8000028e <consputc>
    while(cons.e != cons.w &&
    800003da:	0a04a783          	lw	a5,160(s1)
    800003de:	09c4a703          	lw	a4,156(s1)
    800003e2:	fcf71ce3          	bne	a4,a5,800003ba <consoleintr+0xea>
    800003e6:	b71d                	j	8000030c <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	d8870713          	addi	a4,a4,-632 # 80011170 <cons>
    800003f0:	0a072783          	lw	a5,160(a4)
    800003f4:	09c72703          	lw	a4,156(a4)
    800003f8:	f0f70ae3          	beq	a4,a5,8000030c <consoleintr+0x3c>
      cons.e--;
    800003fc:	37fd                	addiw	a5,a5,-1
    800003fe:	00011717          	auipc	a4,0x11
    80000402:	e0f72923          	sw	a5,-494(a4) # 80011210 <cons+0xa0>
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
    8000042c:	0a07a703          	lw	a4,160(a5)
    80000430:	0017069b          	addiw	a3,a4,1
    80000434:	0006861b          	sext.w	a2,a3
    80000438:	0ad7a023          	sw	a3,160(a5)
    8000043c:	07f77713          	andi	a4,a4,127
    80000440:	97ba                	add	a5,a5,a4
    80000442:	4729                	li	a4,10
    80000444:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000448:	00011797          	auipc	a5,0x11
    8000044c:	dcc7a223          	sw	a2,-572(a5) # 8001120c <cons+0x9c>
        wakeup(&cons.r);
    80000450:	00011517          	auipc	a0,0x11
    80000454:	db850513          	addi	a0,a0,-584 # 80011208 <cons+0x98>
    80000458:	00002097          	auipc	ra,0x2
    8000045c:	eb2080e7          	jalr	-334(ra) # 8000230a <wakeup>
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
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	70e080e7          	jalr	1806(ra) # 80000b88 <initlock>

  uartinit();
    80000482:	00000097          	auipc	ra,0x0
    80000486:	330080e7          	jalr	816(ra) # 800007b2 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048a:	00021797          	auipc	a5,0x21
    8000048e:	e6678793          	addi	a5,a5,-410 # 800212f0 <devsw>
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
    80000560:	cc07aa23          	sw	zero,-812(a5) # 80011230 <pr+0x18>
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
    80000582:	b4a50513          	addi	a0,a0,-1206 # 800080c8 <digits+0x88>
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
    800005d0:	c64dad83          	lw	s11,-924(s11) # 80011230 <pr+0x18>
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
    8000060e:	c0e50513          	addi	a0,a0,-1010 # 80011218 <pr>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	606080e7          	jalr	1542(ra) # 80000c18 <acquire>
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
    80000772:	aaa50513          	addi	a0,a0,-1366 # 80011218 <pr>
    80000776:	00000097          	auipc	ra,0x0
    8000077a:	556080e7          	jalr	1366(ra) # 80000ccc <release>
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
    8000078e:	a8e48493          	addi	s1,s1,-1394 # 80011218 <pr>
    80000792:	00008597          	auipc	a1,0x8
    80000796:	8a658593          	addi	a1,a1,-1882 # 80008038 <etext+0x38>
    8000079a:	8526                	mv	a0,s1
    8000079c:	00000097          	auipc	ra,0x0
    800007a0:	3ec080e7          	jalr	1004(ra) # 80000b88 <initlock>
  pr.locking = 1;
    800007a4:	4785                	li	a5,1
    800007a6:	cc9c                	sw	a5,24(s1)
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
    800007ee:	a4e50513          	addi	a0,a0,-1458 # 80011238 <uart_tx_lock>
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	396080e7          	jalr	918(ra) # 80000b88 <initlock>
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
    80000812:	3be080e7          	jalr	958(ra) # 80000bcc <push_off>

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
    80000844:	42c080e7          	jalr	1068(ra) # 80000c6c <pop_off>
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
    80000880:	9bca0a13          	addi	s4,s4,-1604 # 80011238 <uart_tx_lock>
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
    800008a6:	01874a83          	lbu	s5,24(a4)
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
    800008c2:	a4c080e7          	jalr	-1460(ra) # 8000230a <wakeup>
    
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
    800008fe:	93e50513          	addi	a0,a0,-1730 # 80011238 <uart_tx_lock>
    80000902:	00000097          	auipc	ra,0x0
    80000906:	316080e7          	jalr	790(ra) # 80000c18 <acquire>
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
    80000940:	8fca0a13          	addi	s4,s4,-1796 # 80011238 <uart_tx_lock>
    80000944:	00008497          	auipc	s1,0x8
    80000948:	6c048493          	addi	s1,s1,1728 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000094c:	00008917          	auipc	s2,0x8
    80000950:	6bc90913          	addi	s2,s2,1724 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000954:	85d2                	mv	a1,s4
    80000956:	8526                	mv	a0,s1
    80000958:	00002097          	auipc	ra,0x2
    8000095c:	82c080e7          	jalr	-2004(ra) # 80002184 <sleep>
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
    80000980:	8bc48493          	addi	s1,s1,-1860 # 80011238 <uart_tx_lock>
    80000984:	9726                	add	a4,a4,s1
    80000986:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    8000098a:	00008717          	auipc	a4,0x8
    8000098e:	66f72f23          	sw	a5,1662(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000992:	00000097          	auipc	ra,0x0
    80000996:	ec0080e7          	jalr	-320(ra) # 80000852 <uartstart>
      release(&uart_tx_lock);
    8000099a:	8526                	mv	a0,s1
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	330080e7          	jalr	816(ra) # 80000ccc <release>
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
    80000a02:	83a48493          	addi	s1,s1,-1990 # 80011238 <uart_tx_lock>
    80000a06:	8526                	mv	a0,s1
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	210080e7          	jalr	528(ra) # 80000c18 <acquire>
  uartstart();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	e42080e7          	jalr	-446(ra) # 80000852 <uartstart>
  release(&uart_tx_lock);
    80000a18:	8526                	mv	a0,s1
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	2b2080e7          	jalr	690(ra) # 80000ccc <release>
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
    80000a2c:	1101                	addi	sp,sp,-32
    80000a2e:	ec06                	sd	ra,24(sp)
    80000a30:	e822                	sd	s0,16(sp)
    80000a32:	e426                	sd	s1,8(sp)
    80000a34:	e04a                	sd	s2,0(sp)
    80000a36:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a38:	03451793          	slli	a5,a0,0x34
    80000a3c:	ebb9                	bnez	a5,80000a92 <kfree+0x66>
    80000a3e:	84aa                	mv	s1,a0
    80000a40:	00025797          	auipc	a5,0x25
    80000a44:	5c078793          	addi	a5,a5,1472 # 80026000 <end>
    80000a48:	04f56563          	bltu	a0,a5,80000a92 <kfree+0x66>
    80000a4c:	47c5                	li	a5,17
    80000a4e:	07ee                	slli	a5,a5,0x1b
    80000a50:	04f57163          	bgeu	a0,a5,80000a92 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a54:	6605                	lui	a2,0x1
    80000a56:	4585                	li	a1,1
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	2bc080e7          	jalr	700(ra) # 80000d14 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a60:	00011917          	auipc	s2,0x11
    80000a64:	81090913          	addi	s2,s2,-2032 # 80011270 <kmem>
    80000a68:	854a                	mv	a0,s2
    80000a6a:	00000097          	auipc	ra,0x0
    80000a6e:	1ae080e7          	jalr	430(ra) # 80000c18 <acquire>
  r->next = kmem.freelist;
    80000a72:	01893783          	ld	a5,24(s2)
    80000a76:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a78:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a7c:	854a                	mv	a0,s2
    80000a7e:	00000097          	auipc	ra,0x0
    80000a82:	24e080e7          	jalr	590(ra) # 80000ccc <release>
}
    80000a86:	60e2                	ld	ra,24(sp)
    80000a88:	6442                	ld	s0,16(sp)
    80000a8a:	64a2                	ld	s1,8(sp)
    80000a8c:	6902                	ld	s2,0(sp)
    80000a8e:	6105                	addi	sp,sp,32
    80000a90:	8082                	ret
    panic("kfree");
    80000a92:	00007517          	auipc	a0,0x7
    80000a96:	5ce50513          	addi	a0,a0,1486 # 80008060 <digits+0x20>
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	ab6080e7          	jalr	-1354(ra) # 80000550 <panic>

0000000080000aa2 <freerange>:
{
    80000aa2:	7179                	addi	sp,sp,-48
    80000aa4:	f406                	sd	ra,40(sp)
    80000aa6:	f022                	sd	s0,32(sp)
    80000aa8:	ec26                	sd	s1,24(sp)
    80000aaa:	e84a                	sd	s2,16(sp)
    80000aac:	e44e                	sd	s3,8(sp)
    80000aae:	e052                	sd	s4,0(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	94aa                	add	s1,s1,a0
    80000aba:	757d                	lui	a0,0xfffff
    80000abc:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000abe:	94be                	add	s1,s1,a5
    80000ac0:	0095ee63          	bltu	a1,s1,80000adc <freerange+0x3a>
    80000ac4:	892e                	mv	s2,a1
    kfree(p);
    80000ac6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac8:	6985                	lui	s3,0x1
    kfree(p);
    80000aca:	01448533          	add	a0,s1,s4
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	f5e080e7          	jalr	-162(ra) # 80000a2c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad6:	94ce                	add	s1,s1,s3
    80000ad8:	fe9979e3          	bgeu	s2,s1,80000aca <freerange+0x28>
}
    80000adc:	70a2                	ld	ra,40(sp)
    80000ade:	7402                	ld	s0,32(sp)
    80000ae0:	64e2                	ld	s1,24(sp)
    80000ae2:	6942                	ld	s2,16(sp)
    80000ae4:	69a2                	ld	s3,8(sp)
    80000ae6:	6a02                	ld	s4,0(sp)
    80000ae8:	6145                	addi	sp,sp,48
    80000aea:	8082                	ret

0000000080000aec <kinit>:
{
    80000aec:	1141                	addi	sp,sp,-16
    80000aee:	e406                	sd	ra,8(sp)
    80000af0:	e022                	sd	s0,0(sp)
    80000af2:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af4:	00007597          	auipc	a1,0x7
    80000af8:	57458593          	addi	a1,a1,1396 # 80008068 <digits+0x28>
    80000afc:	00010517          	auipc	a0,0x10
    80000b00:	77450513          	addi	a0,a0,1908 # 80011270 <kmem>
    80000b04:	00000097          	auipc	ra,0x0
    80000b08:	084080e7          	jalr	132(ra) # 80000b88 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00025517          	auipc	a0,0x25
    80000b14:	4f050513          	addi	a0,a0,1264 # 80026000 <end>
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	f8a080e7          	jalr	-118(ra) # 80000aa2 <freerange>
}
    80000b20:	60a2                	ld	ra,8(sp)
    80000b22:	6402                	ld	s0,0(sp)
    80000b24:	0141                	addi	sp,sp,16
    80000b26:	8082                	ret

0000000080000b28 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b28:	1101                	addi	sp,sp,-32
    80000b2a:	ec06                	sd	ra,24(sp)
    80000b2c:	e822                	sd	s0,16(sp)
    80000b2e:	e426                	sd	s1,8(sp)
    80000b30:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b32:	00010497          	auipc	s1,0x10
    80000b36:	73e48493          	addi	s1,s1,1854 # 80011270 <kmem>
    80000b3a:	8526                	mv	a0,s1
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	0dc080e7          	jalr	220(ra) # 80000c18 <acquire>
  r = kmem.freelist;
    80000b44:	6c84                	ld	s1,24(s1)
  if(r)
    80000b46:	c885                	beqz	s1,80000b76 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b48:	609c                	ld	a5,0(s1)
    80000b4a:	00010517          	auipc	a0,0x10
    80000b4e:	72650513          	addi	a0,a0,1830 # 80011270 <kmem>
    80000b52:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b54:	00000097          	auipc	ra,0x0
    80000b58:	178080e7          	jalr	376(ra) # 80000ccc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b5c:	6605                	lui	a2,0x1
    80000b5e:	4595                	li	a1,5
    80000b60:	8526                	mv	a0,s1
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	1b2080e7          	jalr	434(ra) # 80000d14 <memset>
  return (void*)r;
}
    80000b6a:	8526                	mv	a0,s1
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret
  release(&kmem.lock);
    80000b76:	00010517          	auipc	a0,0x10
    80000b7a:	6fa50513          	addi	a0,a0,1786 # 80011270 <kmem>
    80000b7e:	00000097          	auipc	ra,0x0
    80000b82:	14e080e7          	jalr	334(ra) # 80000ccc <release>
  if(r)
    80000b86:	b7d5                	j	80000b6a <kalloc+0x42>

0000000080000b88 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b88:	1141                	addi	sp,sp,-16
    80000b8a:	e422                	sd	s0,8(sp)
    80000b8c:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b8e:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b90:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b94:	00053823          	sd	zero,16(a0)
}
    80000b98:	6422                	ld	s0,8(sp)
    80000b9a:	0141                	addi	sp,sp,16
    80000b9c:	8082                	ret

0000000080000b9e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b9e:	411c                	lw	a5,0(a0)
    80000ba0:	e399                	bnez	a5,80000ba6 <holding+0x8>
    80000ba2:	4501                	li	a0,0
  return r;
}
    80000ba4:	8082                	ret
{
    80000ba6:	1101                	addi	sp,sp,-32
    80000ba8:	ec06                	sd	ra,24(sp)
    80000baa:	e822                	sd	s0,16(sp)
    80000bac:	e426                	sd	s1,8(sp)
    80000bae:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bb0:	6904                	ld	s1,16(a0)
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	da6080e7          	jalr	-602(ra) # 80001958 <mycpu>
    80000bba:	40a48533          	sub	a0,s1,a0
    80000bbe:	00153513          	seqz	a0,a0
}
    80000bc2:	60e2                	ld	ra,24(sp)
    80000bc4:	6442                	ld	s0,16(sp)
    80000bc6:	64a2                	ld	s1,8(sp)
    80000bc8:	6105                	addi	sp,sp,32
    80000bca:	8082                	ret

0000000080000bcc <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bcc:	1101                	addi	sp,sp,-32
    80000bce:	ec06                	sd	ra,24(sp)
    80000bd0:	e822                	sd	s0,16(sp)
    80000bd2:	e426                	sd	s1,8(sp)
    80000bd4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd6:	100024f3          	csrr	s1,sstatus
    80000bda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bde:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000be0:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000be4:	00001097          	auipc	ra,0x1
    80000be8:	d74080e7          	jalr	-652(ra) # 80001958 <mycpu>
    80000bec:	5d3c                	lw	a5,120(a0)
    80000bee:	cf89                	beqz	a5,80000c08 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bf0:	00001097          	auipc	ra,0x1
    80000bf4:	d68080e7          	jalr	-664(ra) # 80001958 <mycpu>
    80000bf8:	5d3c                	lw	a5,120(a0)
    80000bfa:	2785                	addiw	a5,a5,1
    80000bfc:	dd3c                	sw	a5,120(a0)
}
    80000bfe:	60e2                	ld	ra,24(sp)
    80000c00:	6442                	ld	s0,16(sp)
    80000c02:	64a2                	ld	s1,8(sp)
    80000c04:	6105                	addi	sp,sp,32
    80000c06:	8082                	ret
    mycpu()->intena = old;
    80000c08:	00001097          	auipc	ra,0x1
    80000c0c:	d50080e7          	jalr	-688(ra) # 80001958 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c10:	8085                	srli	s1,s1,0x1
    80000c12:	8885                	andi	s1,s1,1
    80000c14:	dd64                	sw	s1,124(a0)
    80000c16:	bfe9                	j	80000bf0 <push_off+0x24>

0000000080000c18 <acquire>:
{
    80000c18:	1101                	addi	sp,sp,-32
    80000c1a:	ec06                	sd	ra,24(sp)
    80000c1c:	e822                	sd	s0,16(sp)
    80000c1e:	e426                	sd	s1,8(sp)
    80000c20:	1000                	addi	s0,sp,32
    80000c22:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c24:	00000097          	auipc	ra,0x0
    80000c28:	fa8080e7          	jalr	-88(ra) # 80000bcc <push_off>
  if(holding(lk))
    80000c2c:	8526                	mv	a0,s1
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	f70080e7          	jalr	-144(ra) # 80000b9e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c36:	4705                	li	a4,1
  if(holding(lk))
    80000c38:	e115                	bnez	a0,80000c5c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3a:	87ba                	mv	a5,a4
    80000c3c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c40:	2781                	sext.w	a5,a5
    80000c42:	ffe5                	bnez	a5,80000c3a <acquire+0x22>
  __sync_synchronize();
    80000c44:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c48:	00001097          	auipc	ra,0x1
    80000c4c:	d10080e7          	jalr	-752(ra) # 80001958 <mycpu>
    80000c50:	e888                	sd	a0,16(s1)
}
    80000c52:	60e2                	ld	ra,24(sp)
    80000c54:	6442                	ld	s0,16(sp)
    80000c56:	64a2                	ld	s1,8(sp)
    80000c58:	6105                	addi	sp,sp,32
    80000c5a:	8082                	ret
    panic("acquire");
    80000c5c:	00007517          	auipc	a0,0x7
    80000c60:	41450513          	addi	a0,a0,1044 # 80008070 <digits+0x30>
    80000c64:	00000097          	auipc	ra,0x0
    80000c68:	8ec080e7          	jalr	-1812(ra) # 80000550 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	00001097          	auipc	ra,0x1
    80000c78:	ce4080e7          	jalr	-796(ra) # 80001958 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c7c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c80:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c82:	e78d                	bnez	a5,80000cac <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c84:	5d3c                	lw	a5,120(a0)
    80000c86:	02f05b63          	blez	a5,80000cbc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c8a:	37fd                	addiw	a5,a5,-1
    80000c8c:	0007871b          	sext.w	a4,a5
    80000c90:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c92:	eb09                	bnez	a4,80000ca4 <pop_off+0x38>
    80000c94:	5d7c                	lw	a5,124(a0)
    80000c96:	c799                	beqz	a5,80000ca4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c9c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ca0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ca4:	60a2                	ld	ra,8(sp)
    80000ca6:	6402                	ld	s0,0(sp)
    80000ca8:	0141                	addi	sp,sp,16
    80000caa:	8082                	ret
    panic("pop_off - interruptible");
    80000cac:	00007517          	auipc	a0,0x7
    80000cb0:	3cc50513          	addi	a0,a0,972 # 80008078 <digits+0x38>
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	89c080e7          	jalr	-1892(ra) # 80000550 <panic>
    panic("pop_off");
    80000cbc:	00007517          	auipc	a0,0x7
    80000cc0:	3d450513          	addi	a0,a0,980 # 80008090 <digits+0x50>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	88c080e7          	jalr	-1908(ra) # 80000550 <panic>

0000000080000ccc <release>:
{
    80000ccc:	1101                	addi	sp,sp,-32
    80000cce:	ec06                	sd	ra,24(sp)
    80000cd0:	e822                	sd	s0,16(sp)
    80000cd2:	e426                	sd	s1,8(sp)
    80000cd4:	1000                	addi	s0,sp,32
    80000cd6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	ec6080e7          	jalr	-314(ra) # 80000b9e <holding>
    80000ce0:	c115                	beqz	a0,80000d04 <release+0x38>
  lk->cpu = 0;
    80000ce2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ce6:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cea:	0f50000f          	fence	iorw,ow
    80000cee:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	f7a080e7          	jalr	-134(ra) # 80000c6c <pop_off>
}
    80000cfa:	60e2                	ld	ra,24(sp)
    80000cfc:	6442                	ld	s0,16(sp)
    80000cfe:	64a2                	ld	s1,8(sp)
    80000d00:	6105                	addi	sp,sp,32
    80000d02:	8082                	ret
    panic("release");
    80000d04:	00007517          	auipc	a0,0x7
    80000d08:	39450513          	addi	a0,a0,916 # 80008098 <digits+0x58>
    80000d0c:	00000097          	auipc	ra,0x0
    80000d10:	844080e7          	jalr	-1980(ra) # 80000550 <panic>

0000000080000d14 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d14:	1141                	addi	sp,sp,-16
    80000d16:	e422                	sd	s0,8(sp)
    80000d18:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d1a:	ce09                	beqz	a2,80000d34 <memset+0x20>
    80000d1c:	87aa                	mv	a5,a0
    80000d1e:	fff6071b          	addiw	a4,a2,-1
    80000d22:	1702                	slli	a4,a4,0x20
    80000d24:	9301                	srli	a4,a4,0x20
    80000d26:	0705                	addi	a4,a4,1
    80000d28:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d2a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d2e:	0785                	addi	a5,a5,1
    80000d30:	fee79de3          	bne	a5,a4,80000d2a <memset+0x16>
  }
  return dst;
}
    80000d34:	6422                	ld	s0,8(sp)
    80000d36:	0141                	addi	sp,sp,16
    80000d38:	8082                	ret

0000000080000d3a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d3a:	1141                	addi	sp,sp,-16
    80000d3c:	e422                	sd	s0,8(sp)
    80000d3e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d40:	ca05                	beqz	a2,80000d70 <memcmp+0x36>
    80000d42:	fff6069b          	addiw	a3,a2,-1
    80000d46:	1682                	slli	a3,a3,0x20
    80000d48:	9281                	srli	a3,a3,0x20
    80000d4a:	0685                	addi	a3,a3,1
    80000d4c:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d4e:	00054783          	lbu	a5,0(a0)
    80000d52:	0005c703          	lbu	a4,0(a1)
    80000d56:	00e79863          	bne	a5,a4,80000d66 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d5a:	0505                	addi	a0,a0,1
    80000d5c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d5e:	fed518e3          	bne	a0,a3,80000d4e <memcmp+0x14>
  }

  return 0;
    80000d62:	4501                	li	a0,0
    80000d64:	a019                	j	80000d6a <memcmp+0x30>
      return *s1 - *s2;
    80000d66:	40e7853b          	subw	a0,a5,a4
}
    80000d6a:	6422                	ld	s0,8(sp)
    80000d6c:	0141                	addi	sp,sp,16
    80000d6e:	8082                	ret
  return 0;
    80000d70:	4501                	li	a0,0
    80000d72:	bfe5                	j	80000d6a <memcmp+0x30>

0000000080000d74 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d74:	1141                	addi	sp,sp,-16
    80000d76:	e422                	sd	s0,8(sp)
    80000d78:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d7a:	00a5f963          	bgeu	a1,a0,80000d8c <memmove+0x18>
    80000d7e:	02061713          	slli	a4,a2,0x20
    80000d82:	9301                	srli	a4,a4,0x20
    80000d84:	00e587b3          	add	a5,a1,a4
    80000d88:	02f56563          	bltu	a0,a5,80000db2 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d8c:	fff6069b          	addiw	a3,a2,-1
    80000d90:	ce11                	beqz	a2,80000dac <memmove+0x38>
    80000d92:	1682                	slli	a3,a3,0x20
    80000d94:	9281                	srli	a3,a3,0x20
    80000d96:	0685                	addi	a3,a3,1
    80000d98:	96ae                	add	a3,a3,a1
    80000d9a:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d9c:	0585                	addi	a1,a1,1
    80000d9e:	0785                	addi	a5,a5,1
    80000da0:	fff5c703          	lbu	a4,-1(a1)
    80000da4:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000da8:	fed59ae3          	bne	a1,a3,80000d9c <memmove+0x28>

  return dst;
}
    80000dac:	6422                	ld	s0,8(sp)
    80000dae:	0141                	addi	sp,sp,16
    80000db0:	8082                	ret
    d += n;
    80000db2:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000db4:	fff6069b          	addiw	a3,a2,-1
    80000db8:	da75                	beqz	a2,80000dac <memmove+0x38>
    80000dba:	02069613          	slli	a2,a3,0x20
    80000dbe:	9201                	srli	a2,a2,0x20
    80000dc0:	fff64613          	not	a2,a2
    80000dc4:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000dc6:	17fd                	addi	a5,a5,-1
    80000dc8:	177d                	addi	a4,a4,-1
    80000dca:	0007c683          	lbu	a3,0(a5)
    80000dce:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000dd2:	fec79ae3          	bne	a5,a2,80000dc6 <memmove+0x52>
    80000dd6:	bfd9                	j	80000dac <memmove+0x38>

0000000080000dd8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dd8:	1141                	addi	sp,sp,-16
    80000dda:	e406                	sd	ra,8(sp)
    80000ddc:	e022                	sd	s0,0(sp)
    80000dde:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000de0:	00000097          	auipc	ra,0x0
    80000de4:	f94080e7          	jalr	-108(ra) # 80000d74 <memmove>
}
    80000de8:	60a2                	ld	ra,8(sp)
    80000dea:	6402                	ld	s0,0(sp)
    80000dec:	0141                	addi	sp,sp,16
    80000dee:	8082                	ret

0000000080000df0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000df0:	1141                	addi	sp,sp,-16
    80000df2:	e422                	sd	s0,8(sp)
    80000df4:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000df6:	ce11                	beqz	a2,80000e12 <strncmp+0x22>
    80000df8:	00054783          	lbu	a5,0(a0)
    80000dfc:	cf89                	beqz	a5,80000e16 <strncmp+0x26>
    80000dfe:	0005c703          	lbu	a4,0(a1)
    80000e02:	00f71a63          	bne	a4,a5,80000e16 <strncmp+0x26>
    n--, p++, q++;
    80000e06:	367d                	addiw	a2,a2,-1
    80000e08:	0505                	addi	a0,a0,1
    80000e0a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e0c:	f675                	bnez	a2,80000df8 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e0e:	4501                	li	a0,0
    80000e10:	a809                	j	80000e22 <strncmp+0x32>
    80000e12:	4501                	li	a0,0
    80000e14:	a039                	j	80000e22 <strncmp+0x32>
  if(n == 0)
    80000e16:	ca09                	beqz	a2,80000e28 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e18:	00054503          	lbu	a0,0(a0)
    80000e1c:	0005c783          	lbu	a5,0(a1)
    80000e20:	9d1d                	subw	a0,a0,a5
}
    80000e22:	6422                	ld	s0,8(sp)
    80000e24:	0141                	addi	sp,sp,16
    80000e26:	8082                	ret
    return 0;
    80000e28:	4501                	li	a0,0
    80000e2a:	bfe5                	j	80000e22 <strncmp+0x32>

0000000080000e2c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e422                	sd	s0,8(sp)
    80000e30:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e32:	872a                	mv	a4,a0
    80000e34:	8832                	mv	a6,a2
    80000e36:	367d                	addiw	a2,a2,-1
    80000e38:	01005963          	blez	a6,80000e4a <strncpy+0x1e>
    80000e3c:	0705                	addi	a4,a4,1
    80000e3e:	0005c783          	lbu	a5,0(a1)
    80000e42:	fef70fa3          	sb	a5,-1(a4)
    80000e46:	0585                	addi	a1,a1,1
    80000e48:	f7f5                	bnez	a5,80000e34 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e4a:	00c05d63          	blez	a2,80000e64 <strncpy+0x38>
    80000e4e:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e50:	0685                	addi	a3,a3,1
    80000e52:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e56:	fff6c793          	not	a5,a3
    80000e5a:	9fb9                	addw	a5,a5,a4
    80000e5c:	010787bb          	addw	a5,a5,a6
    80000e60:	fef048e3          	bgtz	a5,80000e50 <strncpy+0x24>
  return os;
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e70:	02c05363          	blez	a2,80000e96 <safestrcpy+0x2c>
    80000e74:	fff6069b          	addiw	a3,a2,-1
    80000e78:	1682                	slli	a3,a3,0x20
    80000e7a:	9281                	srli	a3,a3,0x20
    80000e7c:	96ae                	add	a3,a3,a1
    80000e7e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e80:	00d58963          	beq	a1,a3,80000e92 <safestrcpy+0x28>
    80000e84:	0585                	addi	a1,a1,1
    80000e86:	0785                	addi	a5,a5,1
    80000e88:	fff5c703          	lbu	a4,-1(a1)
    80000e8c:	fee78fa3          	sb	a4,-1(a5)
    80000e90:	fb65                	bnez	a4,80000e80 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e92:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e96:	6422                	ld	s0,8(sp)
    80000e98:	0141                	addi	sp,sp,16
    80000e9a:	8082                	ret

0000000080000e9c <strlen>:

int
strlen(const char *s)
{
    80000e9c:	1141                	addi	sp,sp,-16
    80000e9e:	e422                	sd	s0,8(sp)
    80000ea0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ea2:	00054783          	lbu	a5,0(a0)
    80000ea6:	cf91                	beqz	a5,80000ec2 <strlen+0x26>
    80000ea8:	0505                	addi	a0,a0,1
    80000eaa:	87aa                	mv	a5,a0
    80000eac:	4685                	li	a3,1
    80000eae:	9e89                	subw	a3,a3,a0
    80000eb0:	00f6853b          	addw	a0,a3,a5
    80000eb4:	0785                	addi	a5,a5,1
    80000eb6:	fff7c703          	lbu	a4,-1(a5)
    80000eba:	fb7d                	bnez	a4,80000eb0 <strlen+0x14>
    ;
  return n;
}
    80000ebc:	6422                	ld	s0,8(sp)
    80000ebe:	0141                	addi	sp,sp,16
    80000ec0:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ec2:	4501                	li	a0,0
    80000ec4:	bfe5                	j	80000ebc <strlen+0x20>

0000000080000ec6 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ec6:	1141                	addi	sp,sp,-16
    80000ec8:	e406                	sd	ra,8(sp)
    80000eca:	e022                	sd	s0,0(sp)
    80000ecc:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	a7a080e7          	jalr	-1414(ra) # 80001948 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ed6:	00008717          	auipc	a4,0x8
    80000eda:	13670713          	addi	a4,a4,310 # 8000900c <started>
  if(cpuid() == 0){
    80000ede:	c139                	beqz	a0,80000f24 <main+0x5e>
    while(started == 0)
    80000ee0:	431c                	lw	a5,0(a4)
    80000ee2:	2781                	sext.w	a5,a5
    80000ee4:	dff5                	beqz	a5,80000ee0 <main+0x1a>
      ;
    __sync_synchronize();
    80000ee6:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	a5e080e7          	jalr	-1442(ra) # 80001948 <cpuid>
    80000ef2:	85aa                	mv	a1,a0
    80000ef4:	00007517          	auipc	a0,0x7
    80000ef8:	1c450513          	addi	a0,a0,452 # 800080b8 <digits+0x78>
    80000efc:	fffff097          	auipc	ra,0xfffff
    80000f00:	69e080e7          	jalr	1694(ra) # 8000059a <printf>
    kvminithart();    // turn on paging
    80000f04:	00000097          	auipc	ra,0x0
    80000f08:	17e080e7          	jalr	382(ra) # 80001082 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f0c:	00001097          	auipc	ra,0x1
    80000f10:	6c6080e7          	jalr	1734(ra) # 800025d2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f14:	00005097          	auipc	ra,0x5
    80000f18:	c6c080e7          	jalr	-916(ra) # 80005b80 <plicinithart>
  }

  scheduler();        
    80000f1c:	00001097          	auipc	ra,0x1
    80000f20:	f88080e7          	jalr	-120(ra) # 80001ea4 <scheduler>
    consoleinit();
    80000f24:	fffff097          	auipc	ra,0xfffff
    80000f28:	53e080e7          	jalr	1342(ra) # 80000462 <consoleinit>
    printfinit();
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	854080e7          	jalr	-1964(ra) # 80000780 <printfinit>
    printf("\n");
    80000f34:	00007517          	auipc	a0,0x7
    80000f38:	19450513          	addi	a0,a0,404 # 800080c8 <digits+0x88>
    80000f3c:	fffff097          	auipc	ra,0xfffff
    80000f40:	65e080e7          	jalr	1630(ra) # 8000059a <printf>
    printf("xv6 kernel is booting\n");
    80000f44:	00007517          	auipc	a0,0x7
    80000f48:	15c50513          	addi	a0,a0,348 # 800080a0 <digits+0x60>
    80000f4c:	fffff097          	auipc	ra,0xfffff
    80000f50:	64e080e7          	jalr	1614(ra) # 8000059a <printf>
    printf("\n");
    80000f54:	00007517          	auipc	a0,0x7
    80000f58:	17450513          	addi	a0,a0,372 # 800080c8 <digits+0x88>
    80000f5c:	fffff097          	auipc	ra,0xfffff
    80000f60:	63e080e7          	jalr	1598(ra) # 8000059a <printf>
    kinit();         // physical page allocator
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	b88080e7          	jalr	-1144(ra) # 80000aec <kinit>
    kvminit();       // create kernel page table
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	242080e7          	jalr	578(ra) # 800011ae <kvminit>
    kvminithart();   // turn on paging
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	10e080e7          	jalr	270(ra) # 80001082 <kvminithart>
    procinit();      // process table
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	8fc080e7          	jalr	-1796(ra) # 80001878 <procinit>
    trapinit();      // trap vectors
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	626080e7          	jalr	1574(ra) # 800025aa <trapinit>
    trapinithart();  // install kernel trap vector
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	646080e7          	jalr	1606(ra) # 800025d2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f94:	00005097          	auipc	ra,0x5
    80000f98:	bd6080e7          	jalr	-1066(ra) # 80005b6a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f9c:	00005097          	auipc	ra,0x5
    80000fa0:	be4080e7          	jalr	-1052(ra) # 80005b80 <plicinithart>
    binit();         // buffer cache
    80000fa4:	00002097          	auipc	ra,0x2
    80000fa8:	d70080e7          	jalr	-656(ra) # 80002d14 <binit>
    iinit();         // inode cache
    80000fac:	00002097          	auipc	ra,0x2
    80000fb0:	400080e7          	jalr	1024(ra) # 800033ac <iinit>
    fileinit();      // file table
    80000fb4:	00003097          	auipc	ra,0x3
    80000fb8:	3b0080e7          	jalr	944(ra) # 80004364 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fbc:	00005097          	auipc	ra,0x5
    80000fc0:	ce6080e7          	jalr	-794(ra) # 80005ca2 <virtio_disk_init>
    userinit();      // first user process
    80000fc4:	00001097          	auipc	ra,0x1
    80000fc8:	c7a080e7          	jalr	-902(ra) # 80001c3e <userinit>
    __sync_synchronize();
    80000fcc:	0ff0000f          	fence
    started = 1;
    80000fd0:	4785                	li	a5,1
    80000fd2:	00008717          	auipc	a4,0x8
    80000fd6:	02f72d23          	sw	a5,58(a4) # 8000900c <started>
    80000fda:	b789                	j	80000f1c <main+0x56>

0000000080000fdc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fdc:	7139                	addi	sp,sp,-64
    80000fde:	fc06                	sd	ra,56(sp)
    80000fe0:	f822                	sd	s0,48(sp)
    80000fe2:	f426                	sd	s1,40(sp)
    80000fe4:	f04a                	sd	s2,32(sp)
    80000fe6:	ec4e                	sd	s3,24(sp)
    80000fe8:	e852                	sd	s4,16(sp)
    80000fea:	e456                	sd	s5,8(sp)
    80000fec:	e05a                	sd	s6,0(sp)
    80000fee:	0080                	addi	s0,sp,64
    80000ff0:	84aa                	mv	s1,a0
    80000ff2:	89ae                	mv	s3,a1
    80000ff4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ff6:	57fd                	li	a5,-1
    80000ff8:	83e9                	srli	a5,a5,0x1a
    80000ffa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ffc:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ffe:	04b7f263          	bgeu	a5,a1,80001042 <walk+0x66>
    panic("walk");
    80001002:	00007517          	auipc	a0,0x7
    80001006:	0ce50513          	addi	a0,a0,206 # 800080d0 <digits+0x90>
    8000100a:	fffff097          	auipc	ra,0xfffff
    8000100e:	546080e7          	jalr	1350(ra) # 80000550 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001012:	060a8663          	beqz	s5,8000107e <walk+0xa2>
    80001016:	00000097          	auipc	ra,0x0
    8000101a:	b12080e7          	jalr	-1262(ra) # 80000b28 <kalloc>
    8000101e:	84aa                	mv	s1,a0
    80001020:	c529                	beqz	a0,8000106a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001022:	6605                	lui	a2,0x1
    80001024:	4581                	li	a1,0
    80001026:	00000097          	auipc	ra,0x0
    8000102a:	cee080e7          	jalr	-786(ra) # 80000d14 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000102e:	00c4d793          	srli	a5,s1,0xc
    80001032:	07aa                	slli	a5,a5,0xa
    80001034:	0017e793          	ori	a5,a5,1
    80001038:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000103c:	3a5d                	addiw	s4,s4,-9
    8000103e:	036a0063          	beq	s4,s6,8000105e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001042:	0149d933          	srl	s2,s3,s4
    80001046:	1ff97913          	andi	s2,s2,511
    8000104a:	090e                	slli	s2,s2,0x3
    8000104c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000104e:	00093483          	ld	s1,0(s2)
    80001052:	0014f793          	andi	a5,s1,1
    80001056:	dfd5                	beqz	a5,80001012 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001058:	80a9                	srli	s1,s1,0xa
    8000105a:	04b2                	slli	s1,s1,0xc
    8000105c:	b7c5                	j	8000103c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000105e:	00c9d513          	srli	a0,s3,0xc
    80001062:	1ff57513          	andi	a0,a0,511
    80001066:	050e                	slli	a0,a0,0x3
    80001068:	9526                	add	a0,a0,s1
}
    8000106a:	70e2                	ld	ra,56(sp)
    8000106c:	7442                	ld	s0,48(sp)
    8000106e:	74a2                	ld	s1,40(sp)
    80001070:	7902                	ld	s2,32(sp)
    80001072:	69e2                	ld	s3,24(sp)
    80001074:	6a42                	ld	s4,16(sp)
    80001076:	6aa2                	ld	s5,8(sp)
    80001078:	6b02                	ld	s6,0(sp)
    8000107a:	6121                	addi	sp,sp,64
    8000107c:	8082                	ret
        return 0;
    8000107e:	4501                	li	a0,0
    80001080:	b7ed                	j	8000106a <walk+0x8e>

0000000080001082 <kvminithart>:
{
    80001082:	1141                	addi	sp,sp,-16
    80001084:	e422                	sd	s0,8(sp)
    80001086:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001088:	00008797          	auipc	a5,0x8
    8000108c:	f887b783          	ld	a5,-120(a5) # 80009010 <kernel_pagetable>
    80001090:	83b1                	srli	a5,a5,0xc
    80001092:	577d                	li	a4,-1
    80001094:	177e                	slli	a4,a4,0x3f
    80001096:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001098:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000109c:	12000073          	sfence.vma
}
    800010a0:	6422                	ld	s0,8(sp)
    800010a2:	0141                	addi	sp,sp,16
    800010a4:	8082                	ret

00000000800010a6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010a6:	57fd                	li	a5,-1
    800010a8:	83e9                	srli	a5,a5,0x1a
    800010aa:	00b7f463          	bgeu	a5,a1,800010b2 <walkaddr+0xc>
    return 0;
    800010ae:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010b0:	8082                	ret
{
    800010b2:	1141                	addi	sp,sp,-16
    800010b4:	e406                	sd	ra,8(sp)
    800010b6:	e022                	sd	s0,0(sp)
    800010b8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ba:	4601                	li	a2,0
    800010bc:	00000097          	auipc	ra,0x0
    800010c0:	f20080e7          	jalr	-224(ra) # 80000fdc <walk>
  if(pte == 0)
    800010c4:	c105                	beqz	a0,800010e4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010c6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010c8:	0117f693          	andi	a3,a5,17
    800010cc:	4745                	li	a4,17
    return 0;
    800010ce:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010d0:	00e68663          	beq	a3,a4,800010dc <walkaddr+0x36>
}
    800010d4:	60a2                	ld	ra,8(sp)
    800010d6:	6402                	ld	s0,0(sp)
    800010d8:	0141                	addi	sp,sp,16
    800010da:	8082                	ret
  pa = PTE2PA(*pte);
    800010dc:	00a7d513          	srli	a0,a5,0xa
    800010e0:	0532                	slli	a0,a0,0xc
  return pa;
    800010e2:	bfcd                	j	800010d4 <walkaddr+0x2e>
    return 0;
    800010e4:	4501                	li	a0,0
    800010e6:	b7fd                	j	800010d4 <walkaddr+0x2e>

00000000800010e8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010e8:	715d                	addi	sp,sp,-80
    800010ea:	e486                	sd	ra,72(sp)
    800010ec:	e0a2                	sd	s0,64(sp)
    800010ee:	fc26                	sd	s1,56(sp)
    800010f0:	f84a                	sd	s2,48(sp)
    800010f2:	f44e                	sd	s3,40(sp)
    800010f4:	f052                	sd	s4,32(sp)
    800010f6:	ec56                	sd	s5,24(sp)
    800010f8:	e85a                	sd	s6,16(sp)
    800010fa:	e45e                	sd	s7,8(sp)
    800010fc:	0880                	addi	s0,sp,80
    800010fe:	8aaa                	mv	s5,a0
    80001100:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001102:	777d                	lui	a4,0xfffff
    80001104:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001108:	167d                	addi	a2,a2,-1
    8000110a:	00b609b3          	add	s3,a2,a1
    8000110e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001112:	893e                	mv	s2,a5
    80001114:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001118:	6b85                	lui	s7,0x1
    8000111a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000111e:	4605                	li	a2,1
    80001120:	85ca                	mv	a1,s2
    80001122:	8556                	mv	a0,s5
    80001124:	00000097          	auipc	ra,0x0
    80001128:	eb8080e7          	jalr	-328(ra) # 80000fdc <walk>
    8000112c:	c51d                	beqz	a0,8000115a <mappages+0x72>
    if(*pte & PTE_V)
    8000112e:	611c                	ld	a5,0(a0)
    80001130:	8b85                	andi	a5,a5,1
    80001132:	ef81                	bnez	a5,8000114a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001134:	80b1                	srli	s1,s1,0xc
    80001136:	04aa                	slli	s1,s1,0xa
    80001138:	0164e4b3          	or	s1,s1,s6
    8000113c:	0014e493          	ori	s1,s1,1
    80001140:	e104                	sd	s1,0(a0)
    if(a == last)
    80001142:	03390863          	beq	s2,s3,80001172 <mappages+0x8a>
    a += PGSIZE;
    80001146:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001148:	bfc9                	j	8000111a <mappages+0x32>
      panic("remap");
    8000114a:	00007517          	auipc	a0,0x7
    8000114e:	f8e50513          	addi	a0,a0,-114 # 800080d8 <digits+0x98>
    80001152:	fffff097          	auipc	ra,0xfffff
    80001156:	3fe080e7          	jalr	1022(ra) # 80000550 <panic>
      return -1;
    8000115a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000115c:	60a6                	ld	ra,72(sp)
    8000115e:	6406                	ld	s0,64(sp)
    80001160:	74e2                	ld	s1,56(sp)
    80001162:	7942                	ld	s2,48(sp)
    80001164:	79a2                	ld	s3,40(sp)
    80001166:	7a02                	ld	s4,32(sp)
    80001168:	6ae2                	ld	s5,24(sp)
    8000116a:	6b42                	ld	s6,16(sp)
    8000116c:	6ba2                	ld	s7,8(sp)
    8000116e:	6161                	addi	sp,sp,80
    80001170:	8082                	ret
  return 0;
    80001172:	4501                	li	a0,0
    80001174:	b7e5                	j	8000115c <mappages+0x74>

0000000080001176 <kvmmap>:
{
    80001176:	1141                	addi	sp,sp,-16
    80001178:	e406                	sd	ra,8(sp)
    8000117a:	e022                	sd	s0,0(sp)
    8000117c:	0800                	addi	s0,sp,16
    8000117e:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001180:	86ae                	mv	a3,a1
    80001182:	85aa                	mv	a1,a0
    80001184:	00008517          	auipc	a0,0x8
    80001188:	e8c53503          	ld	a0,-372(a0) # 80009010 <kernel_pagetable>
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	f5c080e7          	jalr	-164(ra) # 800010e8 <mappages>
    80001194:	e509                	bnez	a0,8000119e <kvmmap+0x28>
}
    80001196:	60a2                	ld	ra,8(sp)
    80001198:	6402                	ld	s0,0(sp)
    8000119a:	0141                	addi	sp,sp,16
    8000119c:	8082                	ret
    panic("kvmmap");
    8000119e:	00007517          	auipc	a0,0x7
    800011a2:	f4250513          	addi	a0,a0,-190 # 800080e0 <digits+0xa0>
    800011a6:	fffff097          	auipc	ra,0xfffff
    800011aa:	3aa080e7          	jalr	938(ra) # 80000550 <panic>

00000000800011ae <kvminit>:
{
    800011ae:	1101                	addi	sp,sp,-32
    800011b0:	ec06                	sd	ra,24(sp)
    800011b2:	e822                	sd	s0,16(sp)
    800011b4:	e426                	sd	s1,8(sp)
    800011b6:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800011b8:	00000097          	auipc	ra,0x0
    800011bc:	970080e7          	jalr	-1680(ra) # 80000b28 <kalloc>
    800011c0:	00008797          	auipc	a5,0x8
    800011c4:	e4a7b823          	sd	a0,-432(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800011c8:	6605                	lui	a2,0x1
    800011ca:	4581                	li	a1,0
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	b48080e7          	jalr	-1208(ra) # 80000d14 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011d4:	4699                	li	a3,6
    800011d6:	6605                	lui	a2,0x1
    800011d8:	100005b7          	lui	a1,0x10000
    800011dc:	10000537          	lui	a0,0x10000
    800011e0:	00000097          	auipc	ra,0x0
    800011e4:	f96080e7          	jalr	-106(ra) # 80001176 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011e8:	4699                	li	a3,6
    800011ea:	6605                	lui	a2,0x1
    800011ec:	100015b7          	lui	a1,0x10001
    800011f0:	10001537          	lui	a0,0x10001
    800011f4:	00000097          	auipc	ra,0x0
    800011f8:	f82080e7          	jalr	-126(ra) # 80001176 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011fc:	4699                	li	a3,6
    800011fe:	00400637          	lui	a2,0x400
    80001202:	0c0005b7          	lui	a1,0xc000
    80001206:	0c000537          	lui	a0,0xc000
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f6c080e7          	jalr	-148(ra) # 80001176 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001212:	00007497          	auipc	s1,0x7
    80001216:	dee48493          	addi	s1,s1,-530 # 80008000 <etext>
    8000121a:	46a9                	li	a3,10
    8000121c:	80007617          	auipc	a2,0x80007
    80001220:	de460613          	addi	a2,a2,-540 # 8000 <_entry-0x7fff8000>
    80001224:	4585                	li	a1,1
    80001226:	05fe                	slli	a1,a1,0x1f
    80001228:	852e                	mv	a0,a1
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f4c080e7          	jalr	-180(ra) # 80001176 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001232:	4699                	li	a3,6
    80001234:	4645                	li	a2,17
    80001236:	066e                	slli	a2,a2,0x1b
    80001238:	8e05                	sub	a2,a2,s1
    8000123a:	85a6                	mv	a1,s1
    8000123c:	8526                	mv	a0,s1
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	f38080e7          	jalr	-200(ra) # 80001176 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001246:	46a9                	li	a3,10
    80001248:	6605                	lui	a2,0x1
    8000124a:	00006597          	auipc	a1,0x6
    8000124e:	db658593          	addi	a1,a1,-586 # 80007000 <_trampoline>
    80001252:	04000537          	lui	a0,0x4000
    80001256:	157d                	addi	a0,a0,-1
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	00000097          	auipc	ra,0x0
    8000125e:	f1c080e7          	jalr	-228(ra) # 80001176 <kvmmap>
}
    80001262:	60e2                	ld	ra,24(sp)
    80001264:	6442                	ld	s0,16(sp)
    80001266:	64a2                	ld	s1,8(sp)
    80001268:	6105                	addi	sp,sp,32
    8000126a:	8082                	ret

000000008000126c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000126c:	715d                	addi	sp,sp,-80
    8000126e:	e486                	sd	ra,72(sp)
    80001270:	e0a2                	sd	s0,64(sp)
    80001272:	fc26                	sd	s1,56(sp)
    80001274:	f84a                	sd	s2,48(sp)
    80001276:	f44e                	sd	s3,40(sp)
    80001278:	f052                	sd	s4,32(sp)
    8000127a:	ec56                	sd	s5,24(sp)
    8000127c:	e85a                	sd	s6,16(sp)
    8000127e:	e45e                	sd	s7,8(sp)
    80001280:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001282:	03459793          	slli	a5,a1,0x34
    80001286:	e795                	bnez	a5,800012b2 <uvmunmap+0x46>
    80001288:	8a2a                	mv	s4,a0
    8000128a:	892e                	mv	s2,a1
    8000128c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	0632                	slli	a2,a2,0xc
    80001290:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001294:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001296:	6b05                	lui	s6,0x1
    80001298:	0735e863          	bltu	a1,s3,80001308 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000129c:	60a6                	ld	ra,72(sp)
    8000129e:	6406                	ld	s0,64(sp)
    800012a0:	74e2                	ld	s1,56(sp)
    800012a2:	7942                	ld	s2,48(sp)
    800012a4:	79a2                	ld	s3,40(sp)
    800012a6:	7a02                	ld	s4,32(sp)
    800012a8:	6ae2                	ld	s5,24(sp)
    800012aa:	6b42                	ld	s6,16(sp)
    800012ac:	6ba2                	ld	s7,8(sp)
    800012ae:	6161                	addi	sp,sp,80
    800012b0:	8082                	ret
    panic("uvmunmap: not aligned");
    800012b2:	00007517          	auipc	a0,0x7
    800012b6:	e3650513          	addi	a0,a0,-458 # 800080e8 <digits+0xa8>
    800012ba:	fffff097          	auipc	ra,0xfffff
    800012be:	296080e7          	jalr	662(ra) # 80000550 <panic>
      panic("uvmunmap: walk");
    800012c2:	00007517          	auipc	a0,0x7
    800012c6:	e3e50513          	addi	a0,a0,-450 # 80008100 <digits+0xc0>
    800012ca:	fffff097          	auipc	ra,0xfffff
    800012ce:	286080e7          	jalr	646(ra) # 80000550 <panic>
      panic("uvmunmap: not mapped");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e3e50513          	addi	a0,a0,-450 # 80008110 <digits+0xd0>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	276080e7          	jalr	630(ra) # 80000550 <panic>
      panic("uvmunmap: not a leaf");
    800012e2:	00007517          	auipc	a0,0x7
    800012e6:	e4650513          	addi	a0,a0,-442 # 80008128 <digits+0xe8>
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	266080e7          	jalr	614(ra) # 80000550 <panic>
      uint64 pa = PTE2PA(*pte);
    800012f2:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012f4:	0532                	slli	a0,a0,0xc
    800012f6:	fffff097          	auipc	ra,0xfffff
    800012fa:	736080e7          	jalr	1846(ra) # 80000a2c <kfree>
    *pte = 0;
    800012fe:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001302:	995a                	add	s2,s2,s6
    80001304:	f9397ce3          	bgeu	s2,s3,8000129c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001308:	4601                	li	a2,0
    8000130a:	85ca                	mv	a1,s2
    8000130c:	8552                	mv	a0,s4
    8000130e:	00000097          	auipc	ra,0x0
    80001312:	cce080e7          	jalr	-818(ra) # 80000fdc <walk>
    80001316:	84aa                	mv	s1,a0
    80001318:	d54d                	beqz	a0,800012c2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000131a:	6108                	ld	a0,0(a0)
    8000131c:	00157793          	andi	a5,a0,1
    80001320:	dbcd                	beqz	a5,800012d2 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001322:	3ff57793          	andi	a5,a0,1023
    80001326:	fb778ee3          	beq	a5,s7,800012e2 <uvmunmap+0x76>
    if(do_free){
    8000132a:	fc0a8ae3          	beqz	s5,800012fe <uvmunmap+0x92>
    8000132e:	b7d1                	j	800012f2 <uvmunmap+0x86>

0000000080001330 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001330:	1101                	addi	sp,sp,-32
    80001332:	ec06                	sd	ra,24(sp)
    80001334:	e822                	sd	s0,16(sp)
    80001336:	e426                	sd	s1,8(sp)
    80001338:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000133a:	fffff097          	auipc	ra,0xfffff
    8000133e:	7ee080e7          	jalr	2030(ra) # 80000b28 <kalloc>
    80001342:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001344:	c519                	beqz	a0,80001352 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001346:	6605                	lui	a2,0x1
    80001348:	4581                	li	a1,0
    8000134a:	00000097          	auipc	ra,0x0
    8000134e:	9ca080e7          	jalr	-1590(ra) # 80000d14 <memset>
  return pagetable;
}
    80001352:	8526                	mv	a0,s1
    80001354:	60e2                	ld	ra,24(sp)
    80001356:	6442                	ld	s0,16(sp)
    80001358:	64a2                	ld	s1,8(sp)
    8000135a:	6105                	addi	sp,sp,32
    8000135c:	8082                	ret

000000008000135e <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000135e:	7179                	addi	sp,sp,-48
    80001360:	f406                	sd	ra,40(sp)
    80001362:	f022                	sd	s0,32(sp)
    80001364:	ec26                	sd	s1,24(sp)
    80001366:	e84a                	sd	s2,16(sp)
    80001368:	e44e                	sd	s3,8(sp)
    8000136a:	e052                	sd	s4,0(sp)
    8000136c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000136e:	6785                	lui	a5,0x1
    80001370:	04f67863          	bgeu	a2,a5,800013c0 <uvminit+0x62>
    80001374:	8a2a                	mv	s4,a0
    80001376:	89ae                	mv	s3,a1
    80001378:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	7ae080e7          	jalr	1966(ra) # 80000b28 <kalloc>
    80001382:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001384:	6605                	lui	a2,0x1
    80001386:	4581                	li	a1,0
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	98c080e7          	jalr	-1652(ra) # 80000d14 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001390:	4779                	li	a4,30
    80001392:	86ca                	mv	a3,s2
    80001394:	6605                	lui	a2,0x1
    80001396:	4581                	li	a1,0
    80001398:	8552                	mv	a0,s4
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	d4e080e7          	jalr	-690(ra) # 800010e8 <mappages>
  memmove(mem, src, sz);
    800013a2:	8626                	mv	a2,s1
    800013a4:	85ce                	mv	a1,s3
    800013a6:	854a                	mv	a0,s2
    800013a8:	00000097          	auipc	ra,0x0
    800013ac:	9cc080e7          	jalr	-1588(ra) # 80000d74 <memmove>
}
    800013b0:	70a2                	ld	ra,40(sp)
    800013b2:	7402                	ld	s0,32(sp)
    800013b4:	64e2                	ld	s1,24(sp)
    800013b6:	6942                	ld	s2,16(sp)
    800013b8:	69a2                	ld	s3,8(sp)
    800013ba:	6a02                	ld	s4,0(sp)
    800013bc:	6145                	addi	sp,sp,48
    800013be:	8082                	ret
    panic("inituvm: more than a page");
    800013c0:	00007517          	auipc	a0,0x7
    800013c4:	d8050513          	addi	a0,a0,-640 # 80008140 <digits+0x100>
    800013c8:	fffff097          	auipc	ra,0xfffff
    800013cc:	188080e7          	jalr	392(ra) # 80000550 <panic>

00000000800013d0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d0:	1101                	addi	sp,sp,-32
    800013d2:	ec06                	sd	ra,24(sp)
    800013d4:	e822                	sd	s0,16(sp)
    800013d6:	e426                	sd	s1,8(sp)
    800013d8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013da:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013dc:	00b67d63          	bgeu	a2,a1,800013f6 <uvmdealloc+0x26>
    800013e0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013e2:	6785                	lui	a5,0x1
    800013e4:	17fd                	addi	a5,a5,-1
    800013e6:	00f60733          	add	a4,a2,a5
    800013ea:	767d                	lui	a2,0xfffff
    800013ec:	8f71                	and	a4,a4,a2
    800013ee:	97ae                	add	a5,a5,a1
    800013f0:	8ff1                	and	a5,a5,a2
    800013f2:	00f76863          	bltu	a4,a5,80001402 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f6:	8526                	mv	a0,s1
    800013f8:	60e2                	ld	ra,24(sp)
    800013fa:	6442                	ld	s0,16(sp)
    800013fc:	64a2                	ld	s1,8(sp)
    800013fe:	6105                	addi	sp,sp,32
    80001400:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001402:	8f99                	sub	a5,a5,a4
    80001404:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001406:	4685                	li	a3,1
    80001408:	0007861b          	sext.w	a2,a5
    8000140c:	85ba                	mv	a1,a4
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	e5e080e7          	jalr	-418(ra) # 8000126c <uvmunmap>
    80001416:	b7c5                	j	800013f6 <uvmdealloc+0x26>

0000000080001418 <uvmalloc>:
  if(newsz < oldsz)
    80001418:	0ab66163          	bltu	a2,a1,800014ba <uvmalloc+0xa2>
{
    8000141c:	7139                	addi	sp,sp,-64
    8000141e:	fc06                	sd	ra,56(sp)
    80001420:	f822                	sd	s0,48(sp)
    80001422:	f426                	sd	s1,40(sp)
    80001424:	f04a                	sd	s2,32(sp)
    80001426:	ec4e                	sd	s3,24(sp)
    80001428:	e852                	sd	s4,16(sp)
    8000142a:	e456                	sd	s5,8(sp)
    8000142c:	0080                	addi	s0,sp,64
    8000142e:	8aaa                	mv	s5,a0
    80001430:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001432:	6985                	lui	s3,0x1
    80001434:	19fd                	addi	s3,s3,-1
    80001436:	95ce                	add	a1,a1,s3
    80001438:	79fd                	lui	s3,0xfffff
    8000143a:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000143e:	08c9f063          	bgeu	s3,a2,800014be <uvmalloc+0xa6>
    80001442:	894e                	mv	s2,s3
    mem = kalloc();
    80001444:	fffff097          	auipc	ra,0xfffff
    80001448:	6e4080e7          	jalr	1764(ra) # 80000b28 <kalloc>
    8000144c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144e:	c51d                	beqz	a0,8000147c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001450:	6605                	lui	a2,0x1
    80001452:	4581                	li	a1,0
    80001454:	00000097          	auipc	ra,0x0
    80001458:	8c0080e7          	jalr	-1856(ra) # 80000d14 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000145c:	4779                	li	a4,30
    8000145e:	86a6                	mv	a3,s1
    80001460:	6605                	lui	a2,0x1
    80001462:	85ca                	mv	a1,s2
    80001464:	8556                	mv	a0,s5
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	c82080e7          	jalr	-894(ra) # 800010e8 <mappages>
    8000146e:	e905                	bnez	a0,8000149e <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001470:	6785                	lui	a5,0x1
    80001472:	993e                	add	s2,s2,a5
    80001474:	fd4968e3          	bltu	s2,s4,80001444 <uvmalloc+0x2c>
  return newsz;
    80001478:	8552                	mv	a0,s4
    8000147a:	a809                	j	8000148c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000147c:	864e                	mv	a2,s3
    8000147e:	85ca                	mv	a1,s2
    80001480:	8556                	mv	a0,s5
    80001482:	00000097          	auipc	ra,0x0
    80001486:	f4e080e7          	jalr	-178(ra) # 800013d0 <uvmdealloc>
      return 0;
    8000148a:	4501                	li	a0,0
}
    8000148c:	70e2                	ld	ra,56(sp)
    8000148e:	7442                	ld	s0,48(sp)
    80001490:	74a2                	ld	s1,40(sp)
    80001492:	7902                	ld	s2,32(sp)
    80001494:	69e2                	ld	s3,24(sp)
    80001496:	6a42                	ld	s4,16(sp)
    80001498:	6aa2                	ld	s5,8(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	58c080e7          	jalr	1420(ra) # 80000a2c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f22080e7          	jalr	-222(ra) # 800013d0 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfd1                	j	8000148c <uvmalloc+0x74>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7f1                	j	8000148c <uvmalloc+0x74>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c5e50513          	addi	a0,a0,-930 # 80008160 <digits+0x120>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	046080e7          	jalr	70(ra) # 80000550 <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	518080e7          	jalr	1304(ra) # 80000a2c <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d12080e7          	jalr	-750(ra) # 8000126c <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a52080e7          	jalr	-1454(ra) # 80000fdc <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	580080e7          	jalr	1408(ra) # 80000b28 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	7bc080e7          	jalr	1980(ra) # 80000d74 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	b1e080e7          	jalr	-1250(ra) # 800010e8 <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	b9250513          	addi	a0,a0,-1134 # 80008170 <digits+0x130>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f6a080e7          	jalr	-150(ra) # 80000550 <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	ba250513          	addi	a0,a0,-1118 # 80008190 <digits+0x150>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f5a080e7          	jalr	-166(ra) # 80000550 <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	42c080e7          	jalr	1068(ra) # 80000a2c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c5a080e7          	jalr	-934(ra) # 8000126c <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	99c080e7          	jalr	-1636(ra) # 80000fdc <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b5850513          	addi	a0,a0,-1192 # 800081b0 <digits+0x170>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ef0080e7          	jalr	-272(ra) # 80000550 <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	6d8080e7          	jalr	1752(ra) # 80000d74 <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9ec080e7          	jalr	-1556(ra) # 800010a6 <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	c6bd                	beqz	a3,80001762 <copyin+0x6e>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a015                	j	8000173e <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	9562                	add	a0,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412505b3          	sub	a1,a0,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	64c080e7          	jalr	1612(ra) # 80000d74 <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	960080e7          	jalr	-1696(ra) # 800010a6 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    if(n > len)
    80001756:	fc99f3e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	b7c1                	j	8000171c <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x74>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	addi	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c6c5                	beqz	a3,80001828 <copyinstr+0xa8>
{
    80001782:	715d                	addi	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	addi	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a035                	j	800017d0 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	0017b793          	seqz	a5,a5
    800017b0:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b4:	60a6                	ld	ra,72(sp)
    800017b6:	6406                	ld	s0,64(sp)
    800017b8:	74e2                	ld	s1,56(sp)
    800017ba:	7942                	ld	s2,48(sp)
    800017bc:	79a2                	ld	s3,40(sp)
    800017be:	7a02                	ld	s4,32(sp)
    800017c0:	6ae2                	ld	s5,24(sp)
    800017c2:	6b42                	ld	s6,16(sp)
    800017c4:	6ba2                	ld	s7,8(sp)
    800017c6:	6161                	addi	sp,sp,80
    800017c8:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ca:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ce:	c8a9                	beqz	s1,80001820 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d0:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d4:	85ca                	mv	a1,s2
    800017d6:	8552                	mv	a0,s4
    800017d8:	00000097          	auipc	ra,0x0
    800017dc:	8ce080e7          	jalr	-1842(ra) # 800010a6 <walkaddr>
    if(pa0 == 0)
    800017e0:	c131                	beqz	a0,80001824 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e2:	41790833          	sub	a6,s2,s7
    800017e6:	984e                	add	a6,a6,s3
    if(n > max)
    800017e8:	0104f363          	bgeu	s1,a6,800017ee <copyinstr+0x6e>
    800017ec:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ee:	955e                	add	a0,a0,s7
    800017f0:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f4:	fc080be3          	beqz	a6,800017ca <copyinstr+0x4a>
    800017f8:	985a                	add	a6,a6,s6
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	14fd                	addi	s1,s1,-1
    80001802:	9b26                	add	s6,s6,s1
    80001804:	00f60733          	add	a4,a2,a5
    80001808:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    8000180c:	df49                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180e:	00e78023          	sb	a4,0(a5)
      --max;
    80001812:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001816:	0785                	addi	a5,a5,1
    while(n > 0){
    80001818:	ff0796e3          	bne	a5,a6,80001804 <copyinstr+0x84>
      dst++;
    8000181c:	8b42                	mv	s6,a6
    8000181e:	b775                	j	800017ca <copyinstr+0x4a>
    80001820:	4781                	li	a5,0
    80001822:	b769                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001824:	557d                	li	a0,-1
    80001826:	b779                	j	800017b4 <copyinstr+0x34>
  int got_null = 0;
    80001828:	4781                	li	a5,0
  if(got_null){
    8000182a:	0017b793          	seqz	a5,a5
    8000182e:	40f00533          	neg	a0,a5
}
    80001832:	8082                	ret

0000000080001834 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001834:	1101                	addi	sp,sp,-32
    80001836:	ec06                	sd	ra,24(sp)
    80001838:	e822                	sd	s0,16(sp)
    8000183a:	e426                	sd	s1,8(sp)
    8000183c:	1000                	addi	s0,sp,32
    8000183e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001840:	fffff097          	auipc	ra,0xfffff
    80001844:	35e080e7          	jalr	862(ra) # 80000b9e <holding>
    80001848:	c909                	beqz	a0,8000185a <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    8000184a:	749c                	ld	a5,40(s1)
    8000184c:	00978f63          	beq	a5,s1,8000186a <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001850:	60e2                	ld	ra,24(sp)
    80001852:	6442                	ld	s0,16(sp)
    80001854:	64a2                	ld	s1,8(sp)
    80001856:	6105                	addi	sp,sp,32
    80001858:	8082                	ret
    panic("wakeup1");
    8000185a:	00007517          	auipc	a0,0x7
    8000185e:	96650513          	addi	a0,a0,-1690 # 800081c0 <digits+0x180>
    80001862:	fffff097          	auipc	ra,0xfffff
    80001866:	cee080e7          	jalr	-786(ra) # 80000550 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000186a:	4c98                	lw	a4,24(s1)
    8000186c:	4785                	li	a5,1
    8000186e:	fef711e3          	bne	a4,a5,80001850 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001872:	4789                	li	a5,2
    80001874:	cc9c                	sw	a5,24(s1)
}
    80001876:	bfe9                	j	80001850 <wakeup1+0x1c>

0000000080001878 <procinit>:
{
    80001878:	715d                	addi	sp,sp,-80
    8000187a:	e486                	sd	ra,72(sp)
    8000187c:	e0a2                	sd	s0,64(sp)
    8000187e:	fc26                	sd	s1,56(sp)
    80001880:	f84a                	sd	s2,48(sp)
    80001882:	f44e                	sd	s3,40(sp)
    80001884:	f052                	sd	s4,32(sp)
    80001886:	ec56                	sd	s5,24(sp)
    80001888:	e85a                	sd	s6,16(sp)
    8000188a:	e45e                	sd	s7,8(sp)
    8000188c:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000188e:	00007597          	auipc	a1,0x7
    80001892:	93a58593          	addi	a1,a1,-1734 # 800081c8 <digits+0x188>
    80001896:	00010517          	auipc	a0,0x10
    8000189a:	9fa50513          	addi	a0,a0,-1542 # 80011290 <pid_lock>
    8000189e:	fffff097          	auipc	ra,0xfffff
    800018a2:	2ea080e7          	jalr	746(ra) # 80000b88 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a6:	00010917          	auipc	s2,0x10
    800018aa:	e0290913          	addi	s2,s2,-510 # 800116a8 <proc>
      initlock(&p->lock, "proc");
    800018ae:	00007b97          	auipc	s7,0x7
    800018b2:	922b8b93          	addi	s7,s7,-1758 # 800081d0 <digits+0x190>
      uint64 va = KSTACK((int) (p - proc));
    800018b6:	8b4a                	mv	s6,s2
    800018b8:	00006a97          	auipc	s5,0x6
    800018bc:	748a8a93          	addi	s5,s5,1864 # 80008000 <etext>
    800018c0:	040009b7          	lui	s3,0x4000
    800018c4:	19fd                	addi	s3,s3,-1
    800018c6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018c8:	00015a17          	auipc	s4,0x15
    800018cc:	7e0a0a13          	addi	s4,s4,2016 # 800170a8 <tickslock>
      initlock(&p->lock, "proc");
    800018d0:	85de                	mv	a1,s7
    800018d2:	854a                	mv	a0,s2
    800018d4:	fffff097          	auipc	ra,0xfffff
    800018d8:	2b4080e7          	jalr	692(ra) # 80000b88 <initlock>
      char *pa = kalloc();
    800018dc:	fffff097          	auipc	ra,0xfffff
    800018e0:	24c080e7          	jalr	588(ra) # 80000b28 <kalloc>
    800018e4:	85aa                	mv	a1,a0
      if(pa == 0)
    800018e6:	c929                	beqz	a0,80001938 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800018e8:	416904b3          	sub	s1,s2,s6
    800018ec:	848d                	srai	s1,s1,0x3
    800018ee:	000ab783          	ld	a5,0(s5)
    800018f2:	02f484b3          	mul	s1,s1,a5
    800018f6:	2485                	addiw	s1,s1,1
    800018f8:	00d4949b          	slliw	s1,s1,0xd
    800018fc:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001900:	4699                	li	a3,6
    80001902:	6605                	lui	a2,0x1
    80001904:	8526                	mv	a0,s1
    80001906:	00000097          	auipc	ra,0x0
    8000190a:	870080e7          	jalr	-1936(ra) # 80001176 <kvmmap>
      p->kstack = va;
    8000190e:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001912:	16890913          	addi	s2,s2,360
    80001916:	fb491de3          	bne	s2,s4,800018d0 <procinit+0x58>
  kvminithart();
    8000191a:	fffff097          	auipc	ra,0xfffff
    8000191e:	768080e7          	jalr	1896(ra) # 80001082 <kvminithart>
}
    80001922:	60a6                	ld	ra,72(sp)
    80001924:	6406                	ld	s0,64(sp)
    80001926:	74e2                	ld	s1,56(sp)
    80001928:	7942                	ld	s2,48(sp)
    8000192a:	79a2                	ld	s3,40(sp)
    8000192c:	7a02                	ld	s4,32(sp)
    8000192e:	6ae2                	ld	s5,24(sp)
    80001930:	6b42                	ld	s6,16(sp)
    80001932:	6ba2                	ld	s7,8(sp)
    80001934:	6161                	addi	sp,sp,80
    80001936:	8082                	ret
        panic("kalloc");
    80001938:	00007517          	auipc	a0,0x7
    8000193c:	8a050513          	addi	a0,a0,-1888 # 800081d8 <digits+0x198>
    80001940:	fffff097          	auipc	ra,0xfffff
    80001944:	c10080e7          	jalr	-1008(ra) # 80000550 <panic>

0000000080001948 <cpuid>:
{
    80001948:	1141                	addi	sp,sp,-16
    8000194a:	e422                	sd	s0,8(sp)
    8000194c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000194e:	8512                	mv	a0,tp
}
    80001950:	2501                	sext.w	a0,a0
    80001952:	6422                	ld	s0,8(sp)
    80001954:	0141                	addi	sp,sp,16
    80001956:	8082                	ret

0000000080001958 <mycpu>:
mycpu(void) {
    80001958:	1141                	addi	sp,sp,-16
    8000195a:	e422                	sd	s0,8(sp)
    8000195c:	0800                	addi	s0,sp,16
    8000195e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001960:	2781                	sext.w	a5,a5
    80001962:	079e                	slli	a5,a5,0x7
}
    80001964:	00010517          	auipc	a0,0x10
    80001968:	94450513          	addi	a0,a0,-1724 # 800112a8 <cpus>
    8000196c:	953e                	add	a0,a0,a5
    8000196e:	6422                	ld	s0,8(sp)
    80001970:	0141                	addi	sp,sp,16
    80001972:	8082                	ret

0000000080001974 <myproc>:
myproc(void) {
    80001974:	1101                	addi	sp,sp,-32
    80001976:	ec06                	sd	ra,24(sp)
    80001978:	e822                	sd	s0,16(sp)
    8000197a:	e426                	sd	s1,8(sp)
    8000197c:	1000                	addi	s0,sp,32
  push_off();
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	24e080e7          	jalr	590(ra) # 80000bcc <push_off>
    80001986:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001988:	2781                	sext.w	a5,a5
    8000198a:	079e                	slli	a5,a5,0x7
    8000198c:	00010717          	auipc	a4,0x10
    80001990:	90470713          	addi	a4,a4,-1788 # 80011290 <pid_lock>
    80001994:	97ba                	add	a5,a5,a4
    80001996:	6f84                	ld	s1,24(a5)
  pop_off();
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	2d4080e7          	jalr	724(ra) # 80000c6c <pop_off>
}
    800019a0:	8526                	mv	a0,s1
    800019a2:	60e2                	ld	ra,24(sp)
    800019a4:	6442                	ld	s0,16(sp)
    800019a6:	64a2                	ld	s1,8(sp)
    800019a8:	6105                	addi	sp,sp,32
    800019aa:	8082                	ret

00000000800019ac <forkret>:
{
    800019ac:	1141                	addi	sp,sp,-16
    800019ae:	e406                	sd	ra,8(sp)
    800019b0:	e022                	sd	s0,0(sp)
    800019b2:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    800019b4:	00000097          	auipc	ra,0x0
    800019b8:	fc0080e7          	jalr	-64(ra) # 80001974 <myproc>
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	310080e7          	jalr	784(ra) # 80000ccc <release>
  if (first) {
    800019c4:	00007797          	auipc	a5,0x7
    800019c8:	e3c7a783          	lw	a5,-452(a5) # 80008800 <first.1660>
    800019cc:	eb89                	bnez	a5,800019de <forkret+0x32>
  usertrapret();
    800019ce:	00001097          	auipc	ra,0x1
    800019d2:	c1c080e7          	jalr	-996(ra) # 800025ea <usertrapret>
}
    800019d6:	60a2                	ld	ra,8(sp)
    800019d8:	6402                	ld	s0,0(sp)
    800019da:	0141                	addi	sp,sp,16
    800019dc:	8082                	ret
    first = 0;
    800019de:	00007797          	auipc	a5,0x7
    800019e2:	e207a123          	sw	zero,-478(a5) # 80008800 <first.1660>
    fsinit(ROOTDEV);
    800019e6:	4505                	li	a0,1
    800019e8:	00002097          	auipc	ra,0x2
    800019ec:	944080e7          	jalr	-1724(ra) # 8000332c <fsinit>
    800019f0:	bff9                	j	800019ce <forkret+0x22>

00000000800019f2 <allocpid>:
allocpid() {
    800019f2:	1101                	addi	sp,sp,-32
    800019f4:	ec06                	sd	ra,24(sp)
    800019f6:	e822                	sd	s0,16(sp)
    800019f8:	e426                	sd	s1,8(sp)
    800019fa:	e04a                	sd	s2,0(sp)
    800019fc:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019fe:	00010917          	auipc	s2,0x10
    80001a02:	89290913          	addi	s2,s2,-1902 # 80011290 <pid_lock>
    80001a06:	854a                	mv	a0,s2
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	210080e7          	jalr	528(ra) # 80000c18 <acquire>
  pid = nextpid;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	df478793          	addi	a5,a5,-524 # 80008804 <nextpid>
    80001a18:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a1a:	0014871b          	addiw	a4,s1,1
    80001a1e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a20:	854a                	mv	a0,s2
    80001a22:	fffff097          	auipc	ra,0xfffff
    80001a26:	2aa080e7          	jalr	682(ra) # 80000ccc <release>
}
    80001a2a:	8526                	mv	a0,s1
    80001a2c:	60e2                	ld	ra,24(sp)
    80001a2e:	6442                	ld	s0,16(sp)
    80001a30:	64a2                	ld	s1,8(sp)
    80001a32:	6902                	ld	s2,0(sp)
    80001a34:	6105                	addi	sp,sp,32
    80001a36:	8082                	ret

0000000080001a38 <proc_pagetable>:
{
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	e04a                	sd	s2,0(sp)
    80001a42:	1000                	addi	s0,sp,32
    80001a44:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a46:	00000097          	auipc	ra,0x0
    80001a4a:	8ea080e7          	jalr	-1814(ra) # 80001330 <uvmcreate>
    80001a4e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a50:	c121                	beqz	a0,80001a90 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a52:	4729                	li	a4,10
    80001a54:	00005697          	auipc	a3,0x5
    80001a58:	5ac68693          	addi	a3,a3,1452 # 80007000 <_trampoline>
    80001a5c:	6605                	lui	a2,0x1
    80001a5e:	040005b7          	lui	a1,0x4000
    80001a62:	15fd                	addi	a1,a1,-1
    80001a64:	05b2                	slli	a1,a1,0xc
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	682080e7          	jalr	1666(ra) # 800010e8 <mappages>
    80001a6e:	02054863          	bltz	a0,80001a9e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a72:	4719                	li	a4,6
    80001a74:	05893683          	ld	a3,88(s2)
    80001a78:	6605                	lui	a2,0x1
    80001a7a:	020005b7          	lui	a1,0x2000
    80001a7e:	15fd                	addi	a1,a1,-1
    80001a80:	05b6                	slli	a1,a1,0xd
    80001a82:	8526                	mv	a0,s1
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	664080e7          	jalr	1636(ra) # 800010e8 <mappages>
    80001a8c:	02054163          	bltz	a0,80001aae <proc_pagetable+0x76>
}
    80001a90:	8526                	mv	a0,s1
    80001a92:	60e2                	ld	ra,24(sp)
    80001a94:	6442                	ld	s0,16(sp)
    80001a96:	64a2                	ld	s1,8(sp)
    80001a98:	6902                	ld	s2,0(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a9e:	4581                	li	a1,0
    80001aa0:	8526                	mv	a0,s1
    80001aa2:	00000097          	auipc	ra,0x0
    80001aa6:	a8a080e7          	jalr	-1398(ra) # 8000152c <uvmfree>
    return 0;
    80001aaa:	4481                	li	s1,0
    80001aac:	b7d5                	j	80001a90 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aae:	4681                	li	a3,0
    80001ab0:	4605                	li	a2,1
    80001ab2:	040005b7          	lui	a1,0x4000
    80001ab6:	15fd                	addi	a1,a1,-1
    80001ab8:	05b2                	slli	a1,a1,0xc
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	7b0080e7          	jalr	1968(ra) # 8000126c <uvmunmap>
    uvmfree(pagetable, 0);
    80001ac4:	4581                	li	a1,0
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	00000097          	auipc	ra,0x0
    80001acc:	a64080e7          	jalr	-1436(ra) # 8000152c <uvmfree>
    return 0;
    80001ad0:	4481                	li	s1,0
    80001ad2:	bf7d                	j	80001a90 <proc_pagetable+0x58>

0000000080001ad4 <proc_freepagetable>:
{
    80001ad4:	1101                	addi	sp,sp,-32
    80001ad6:	ec06                	sd	ra,24(sp)
    80001ad8:	e822                	sd	s0,16(sp)
    80001ada:	e426                	sd	s1,8(sp)
    80001adc:	e04a                	sd	s2,0(sp)
    80001ade:	1000                	addi	s0,sp,32
    80001ae0:	84aa                	mv	s1,a0
    80001ae2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae4:	4681                	li	a3,0
    80001ae6:	4605                	li	a2,1
    80001ae8:	040005b7          	lui	a1,0x4000
    80001aec:	15fd                	addi	a1,a1,-1
    80001aee:	05b2                	slli	a1,a1,0xc
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	77c080e7          	jalr	1916(ra) # 8000126c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001af8:	4681                	li	a3,0
    80001afa:	4605                	li	a2,1
    80001afc:	020005b7          	lui	a1,0x2000
    80001b00:	15fd                	addi	a1,a1,-1
    80001b02:	05b6                	slli	a1,a1,0xd
    80001b04:	8526                	mv	a0,s1
    80001b06:	fffff097          	auipc	ra,0xfffff
    80001b0a:	766080e7          	jalr	1894(ra) # 8000126c <uvmunmap>
  uvmfree(pagetable, sz);
    80001b0e:	85ca                	mv	a1,s2
    80001b10:	8526                	mv	a0,s1
    80001b12:	00000097          	auipc	ra,0x0
    80001b16:	a1a080e7          	jalr	-1510(ra) # 8000152c <uvmfree>
}
    80001b1a:	60e2                	ld	ra,24(sp)
    80001b1c:	6442                	ld	s0,16(sp)
    80001b1e:	64a2                	ld	s1,8(sp)
    80001b20:	6902                	ld	s2,0(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret

0000000080001b26 <freeproc>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	1000                	addi	s0,sp,32
    80001b30:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b32:	6d28                	ld	a0,88(a0)
    80001b34:	c509                	beqz	a0,80001b3e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b36:	fffff097          	auipc	ra,0xfffff
    80001b3a:	ef6080e7          	jalr	-266(ra) # 80000a2c <kfree>
  p->trapframe = 0;
    80001b3e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b42:	68a8                	ld	a0,80(s1)
    80001b44:	c511                	beqz	a0,80001b50 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b46:	64ac                	ld	a1,72(s1)
    80001b48:	00000097          	auipc	ra,0x0
    80001b4c:	f8c080e7          	jalr	-116(ra) # 80001ad4 <proc_freepagetable>
  p->pagetable = 0;
    80001b50:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b54:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b58:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001b5c:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001b60:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b64:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001b68:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001b6c:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001b70:	0004ac23          	sw	zero,24(s1)
}
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6105                	addi	sp,sp,32
    80001b7c:	8082                	ret

0000000080001b7e <allocproc>:
{
    80001b7e:	1101                	addi	sp,sp,-32
    80001b80:	ec06                	sd	ra,24(sp)
    80001b82:	e822                	sd	s0,16(sp)
    80001b84:	e426                	sd	s1,8(sp)
    80001b86:	e04a                	sd	s2,0(sp)
    80001b88:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b8a:	00010497          	auipc	s1,0x10
    80001b8e:	b1e48493          	addi	s1,s1,-1250 # 800116a8 <proc>
    80001b92:	00015917          	auipc	s2,0x15
    80001b96:	51690913          	addi	s2,s2,1302 # 800170a8 <tickslock>
    acquire(&p->lock);
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	fffff097          	auipc	ra,0xfffff
    80001ba0:	07c080e7          	jalr	124(ra) # 80000c18 <acquire>
    if(p->state == UNUSED) {
    80001ba4:	4c9c                	lw	a5,24(s1)
    80001ba6:	cf81                	beqz	a5,80001bbe <allocproc+0x40>
      release(&p->lock);
    80001ba8:	8526                	mv	a0,s1
    80001baa:	fffff097          	auipc	ra,0xfffff
    80001bae:	122080e7          	jalr	290(ra) # 80000ccc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb2:	16848493          	addi	s1,s1,360
    80001bb6:	ff2492e3          	bne	s1,s2,80001b9a <allocproc+0x1c>
  return 0;
    80001bba:	4481                	li	s1,0
    80001bbc:	a0b9                	j	80001c0a <allocproc+0x8c>
  p->pid = allocpid();
    80001bbe:	00000097          	auipc	ra,0x0
    80001bc2:	e34080e7          	jalr	-460(ra) # 800019f2 <allocpid>
    80001bc6:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	f60080e7          	jalr	-160(ra) # 80000b28 <kalloc>
    80001bd0:	892a                	mv	s2,a0
    80001bd2:	eca8                	sd	a0,88(s1)
    80001bd4:	c131                	beqz	a0,80001c18 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	00000097          	auipc	ra,0x0
    80001bdc:	e60080e7          	jalr	-416(ra) # 80001a38 <proc_pagetable>
    80001be0:	892a                	mv	s2,a0
    80001be2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001be4:	c129                	beqz	a0,80001c26 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001be6:	07000613          	li	a2,112
    80001bea:	4581                	li	a1,0
    80001bec:	06048513          	addi	a0,s1,96
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	124080e7          	jalr	292(ra) # 80000d14 <memset>
  p->context.ra = (uint64)forkret;
    80001bf8:	00000797          	auipc	a5,0x0
    80001bfc:	db478793          	addi	a5,a5,-588 # 800019ac <forkret>
    80001c00:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c02:	60bc                	ld	a5,64(s1)
    80001c04:	6705                	lui	a4,0x1
    80001c06:	97ba                	add	a5,a5,a4
    80001c08:	f4bc                	sd	a5,104(s1)
}
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6902                	ld	s2,0(sp)
    80001c14:	6105                	addi	sp,sp,32
    80001c16:	8082                	ret
    release(&p->lock);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	0b2080e7          	jalr	178(ra) # 80000ccc <release>
    return 0;
    80001c22:	84ca                	mv	s1,s2
    80001c24:	b7dd                	j	80001c0a <allocproc+0x8c>
    freeproc(p);
    80001c26:	8526                	mv	a0,s1
    80001c28:	00000097          	auipc	ra,0x0
    80001c2c:	efe080e7          	jalr	-258(ra) # 80001b26 <freeproc>
    release(&p->lock);
    80001c30:	8526                	mv	a0,s1
    80001c32:	fffff097          	auipc	ra,0xfffff
    80001c36:	09a080e7          	jalr	154(ra) # 80000ccc <release>
    return 0;
    80001c3a:	84ca                	mv	s1,s2
    80001c3c:	b7f9                	j	80001c0a <allocproc+0x8c>

0000000080001c3e <userinit>:
{
    80001c3e:	1101                	addi	sp,sp,-32
    80001c40:	ec06                	sd	ra,24(sp)
    80001c42:	e822                	sd	s0,16(sp)
    80001c44:	e426                	sd	s1,8(sp)
    80001c46:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c48:	00000097          	auipc	ra,0x0
    80001c4c:	f36080e7          	jalr	-202(ra) # 80001b7e <allocproc>
    80001c50:	84aa                	mv	s1,a0
  initproc = p;
    80001c52:	00007797          	auipc	a5,0x7
    80001c56:	3ca7b323          	sd	a0,966(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001c5a:	03400613          	li	a2,52
    80001c5e:	00007597          	auipc	a1,0x7
    80001c62:	bb258593          	addi	a1,a1,-1102 # 80008810 <initcode>
    80001c66:	6928                	ld	a0,80(a0)
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	6f6080e7          	jalr	1782(ra) # 8000135e <uvminit>
  p->sz = PGSIZE;
    80001c70:	6785                	lui	a5,0x1
    80001c72:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001c74:	6cb8                	ld	a4,88(s1)
    80001c76:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001c7a:	6cb8                	ld	a4,88(s1)
    80001c7c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001c7e:	4641                	li	a2,16
    80001c80:	00006597          	auipc	a1,0x6
    80001c84:	56058593          	addi	a1,a1,1376 # 800081e0 <digits+0x1a0>
    80001c88:	15848513          	addi	a0,s1,344
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	1de080e7          	jalr	478(ra) # 80000e6a <safestrcpy>
  p->cwd = namei("/");
    80001c94:	00006517          	auipc	a0,0x6
    80001c98:	55c50513          	addi	a0,a0,1372 # 800081f0 <digits+0x1b0>
    80001c9c:	00002097          	auipc	ra,0x2
    80001ca0:	0bc080e7          	jalr	188(ra) # 80003d58 <namei>
    80001ca4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ca8:	4789                	li	a5,2
    80001caa:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cac:	8526                	mv	a0,s1
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	01e080e7          	jalr	30(ra) # 80000ccc <release>
}
    80001cb6:	60e2                	ld	ra,24(sp)
    80001cb8:	6442                	ld	s0,16(sp)
    80001cba:	64a2                	ld	s1,8(sp)
    80001cbc:	6105                	addi	sp,sp,32
    80001cbe:	8082                	ret

0000000080001cc0 <growproc>:
{
    80001cc0:	1101                	addi	sp,sp,-32
    80001cc2:	ec06                	sd	ra,24(sp)
    80001cc4:	e822                	sd	s0,16(sp)
    80001cc6:	e426                	sd	s1,8(sp)
    80001cc8:	e04a                	sd	s2,0(sp)
    80001cca:	1000                	addi	s0,sp,32
    80001ccc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	ca6080e7          	jalr	-858(ra) # 80001974 <myproc>
    80001cd6:	892a                	mv	s2,a0
  sz = p->sz;
    80001cd8:	652c                	ld	a1,72(a0)
    80001cda:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001cde:	00904f63          	bgtz	s1,80001cfc <growproc+0x3c>
  } else if(n < 0){
    80001ce2:	0204cc63          	bltz	s1,80001d1a <growproc+0x5a>
  p->sz = sz;
    80001ce6:	1602                	slli	a2,a2,0x20
    80001ce8:	9201                	srli	a2,a2,0x20
    80001cea:	04c93423          	sd	a2,72(s2)
  return 0;
    80001cee:	4501                	li	a0,0
}
    80001cf0:	60e2                	ld	ra,24(sp)
    80001cf2:	6442                	ld	s0,16(sp)
    80001cf4:	64a2                	ld	s1,8(sp)
    80001cf6:	6902                	ld	s2,0(sp)
    80001cf8:	6105                	addi	sp,sp,32
    80001cfa:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001cfc:	9e25                	addw	a2,a2,s1
    80001cfe:	1602                	slli	a2,a2,0x20
    80001d00:	9201                	srli	a2,a2,0x20
    80001d02:	1582                	slli	a1,a1,0x20
    80001d04:	9181                	srli	a1,a1,0x20
    80001d06:	6928                	ld	a0,80(a0)
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	710080e7          	jalr	1808(ra) # 80001418 <uvmalloc>
    80001d10:	0005061b          	sext.w	a2,a0
    80001d14:	fa69                	bnez	a2,80001ce6 <growproc+0x26>
      return -1;
    80001d16:	557d                	li	a0,-1
    80001d18:	bfe1                	j	80001cf0 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d1a:	9e25                	addw	a2,a2,s1
    80001d1c:	1602                	slli	a2,a2,0x20
    80001d1e:	9201                	srli	a2,a2,0x20
    80001d20:	1582                	slli	a1,a1,0x20
    80001d22:	9181                	srli	a1,a1,0x20
    80001d24:	6928                	ld	a0,80(a0)
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	6aa080e7          	jalr	1706(ra) # 800013d0 <uvmdealloc>
    80001d2e:	0005061b          	sext.w	a2,a0
    80001d32:	bf55                	j	80001ce6 <growproc+0x26>

0000000080001d34 <fork>:
{
    80001d34:	7179                	addi	sp,sp,-48
    80001d36:	f406                	sd	ra,40(sp)
    80001d38:	f022                	sd	s0,32(sp)
    80001d3a:	ec26                	sd	s1,24(sp)
    80001d3c:	e84a                	sd	s2,16(sp)
    80001d3e:	e44e                	sd	s3,8(sp)
    80001d40:	e052                	sd	s4,0(sp)
    80001d42:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d44:	00000097          	auipc	ra,0x0
    80001d48:	c30080e7          	jalr	-976(ra) # 80001974 <myproc>
    80001d4c:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001d4e:	00000097          	auipc	ra,0x0
    80001d52:	e30080e7          	jalr	-464(ra) # 80001b7e <allocproc>
    80001d56:	c175                	beqz	a0,80001e3a <fork+0x106>
    80001d58:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d5a:	04893603          	ld	a2,72(s2)
    80001d5e:	692c                	ld	a1,80(a0)
    80001d60:	05093503          	ld	a0,80(s2)
    80001d64:	00000097          	auipc	ra,0x0
    80001d68:	800080e7          	jalr	-2048(ra) # 80001564 <uvmcopy>
    80001d6c:	04054863          	bltz	a0,80001dbc <fork+0x88>
  np->sz = p->sz;
    80001d70:	04893783          	ld	a5,72(s2)
    80001d74:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001d78:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001d7c:	05893683          	ld	a3,88(s2)
    80001d80:	87b6                	mv	a5,a3
    80001d82:	0589b703          	ld	a4,88(s3)
    80001d86:	12068693          	addi	a3,a3,288
    80001d8a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001d8e:	6788                	ld	a0,8(a5)
    80001d90:	6b8c                	ld	a1,16(a5)
    80001d92:	6f90                	ld	a2,24(a5)
    80001d94:	01073023          	sd	a6,0(a4)
    80001d98:	e708                	sd	a0,8(a4)
    80001d9a:	eb0c                	sd	a1,16(a4)
    80001d9c:	ef10                	sd	a2,24(a4)
    80001d9e:	02078793          	addi	a5,a5,32
    80001da2:	02070713          	addi	a4,a4,32
    80001da6:	fed792e3          	bne	a5,a3,80001d8a <fork+0x56>
  np->trapframe->a0 = 0;
    80001daa:	0589b783          	ld	a5,88(s3)
    80001dae:	0607b823          	sd	zero,112(a5)
    80001db2:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001db6:	15000a13          	li	s4,336
    80001dba:	a03d                	j	80001de8 <fork+0xb4>
    freeproc(np);
    80001dbc:	854e                	mv	a0,s3
    80001dbe:	00000097          	auipc	ra,0x0
    80001dc2:	d68080e7          	jalr	-664(ra) # 80001b26 <freeproc>
    release(&np->lock);
    80001dc6:	854e                	mv	a0,s3
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	f04080e7          	jalr	-252(ra) # 80000ccc <release>
    return -1;
    80001dd0:	54fd                	li	s1,-1
    80001dd2:	a899                	j	80001e28 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001dd4:	00002097          	auipc	ra,0x2
    80001dd8:	622080e7          	jalr	1570(ra) # 800043f6 <filedup>
    80001ddc:	009987b3          	add	a5,s3,s1
    80001de0:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001de2:	04a1                	addi	s1,s1,8
    80001de4:	01448763          	beq	s1,s4,80001df2 <fork+0xbe>
    if(p->ofile[i])
    80001de8:	009907b3          	add	a5,s2,s1
    80001dec:	6388                	ld	a0,0(a5)
    80001dee:	f17d                	bnez	a0,80001dd4 <fork+0xa0>
    80001df0:	bfcd                	j	80001de2 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001df2:	15093503          	ld	a0,336(s2)
    80001df6:	00001097          	auipc	ra,0x1
    80001dfa:	770080e7          	jalr	1904(ra) # 80003566 <idup>
    80001dfe:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e02:	4641                	li	a2,16
    80001e04:	15890593          	addi	a1,s2,344
    80001e08:	15898513          	addi	a0,s3,344
    80001e0c:	fffff097          	auipc	ra,0xfffff
    80001e10:	05e080e7          	jalr	94(ra) # 80000e6a <safestrcpy>
  pid = np->pid;
    80001e14:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001e18:	4789                	li	a5,2
    80001e1a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e1e:	854e                	mv	a0,s3
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	eac080e7          	jalr	-340(ra) # 80000ccc <release>
}
    80001e28:	8526                	mv	a0,s1
    80001e2a:	70a2                	ld	ra,40(sp)
    80001e2c:	7402                	ld	s0,32(sp)
    80001e2e:	64e2                	ld	s1,24(sp)
    80001e30:	6942                	ld	s2,16(sp)
    80001e32:	69a2                	ld	s3,8(sp)
    80001e34:	6a02                	ld	s4,0(sp)
    80001e36:	6145                	addi	sp,sp,48
    80001e38:	8082                	ret
    return -1;
    80001e3a:	54fd                	li	s1,-1
    80001e3c:	b7f5                	j	80001e28 <fork+0xf4>

0000000080001e3e <reparent>:
{
    80001e3e:	7179                	addi	sp,sp,-48
    80001e40:	f406                	sd	ra,40(sp)
    80001e42:	f022                	sd	s0,32(sp)
    80001e44:	ec26                	sd	s1,24(sp)
    80001e46:	e84a                	sd	s2,16(sp)
    80001e48:	e44e                	sd	s3,8(sp)
    80001e4a:	e052                	sd	s4,0(sp)
    80001e4c:	1800                	addi	s0,sp,48
    80001e4e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001e50:	00010497          	auipc	s1,0x10
    80001e54:	85848493          	addi	s1,s1,-1960 # 800116a8 <proc>
      pp->parent = initproc;
    80001e58:	00007a17          	auipc	s4,0x7
    80001e5c:	1c0a0a13          	addi	s4,s4,448 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001e60:	00015997          	auipc	s3,0x15
    80001e64:	24898993          	addi	s3,s3,584 # 800170a8 <tickslock>
    80001e68:	a029                	j	80001e72 <reparent+0x34>
    80001e6a:	16848493          	addi	s1,s1,360
    80001e6e:	03348363          	beq	s1,s3,80001e94 <reparent+0x56>
    if(pp->parent == p){
    80001e72:	709c                	ld	a5,32(s1)
    80001e74:	ff279be3          	bne	a5,s2,80001e6a <reparent+0x2c>
      acquire(&pp->lock);
    80001e78:	8526                	mv	a0,s1
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	d9e080e7          	jalr	-610(ra) # 80000c18 <acquire>
      pp->parent = initproc;
    80001e82:	000a3783          	ld	a5,0(s4)
    80001e86:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001e88:	8526                	mv	a0,s1
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e42080e7          	jalr	-446(ra) # 80000ccc <release>
    80001e92:	bfe1                	j	80001e6a <reparent+0x2c>
}
    80001e94:	70a2                	ld	ra,40(sp)
    80001e96:	7402                	ld	s0,32(sp)
    80001e98:	64e2                	ld	s1,24(sp)
    80001e9a:	6942                	ld	s2,16(sp)
    80001e9c:	69a2                	ld	s3,8(sp)
    80001e9e:	6a02                	ld	s4,0(sp)
    80001ea0:	6145                	addi	sp,sp,48
    80001ea2:	8082                	ret

0000000080001ea4 <scheduler>:
{
    80001ea4:	711d                	addi	sp,sp,-96
    80001ea6:	ec86                	sd	ra,88(sp)
    80001ea8:	e8a2                	sd	s0,80(sp)
    80001eaa:	e4a6                	sd	s1,72(sp)
    80001eac:	e0ca                	sd	s2,64(sp)
    80001eae:	fc4e                	sd	s3,56(sp)
    80001eb0:	f852                	sd	s4,48(sp)
    80001eb2:	f456                	sd	s5,40(sp)
    80001eb4:	f05a                	sd	s6,32(sp)
    80001eb6:	ec5e                	sd	s7,24(sp)
    80001eb8:	e862                	sd	s8,16(sp)
    80001eba:	e466                	sd	s9,8(sp)
    80001ebc:	1080                	addi	s0,sp,96
    80001ebe:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec2:	00779c13          	slli	s8,a5,0x7
    80001ec6:	0000f717          	auipc	a4,0xf
    80001eca:	3ca70713          	addi	a4,a4,970 # 80011290 <pid_lock>
    80001ece:	9762                	add	a4,a4,s8
    80001ed0:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001ed4:	0000f717          	auipc	a4,0xf
    80001ed8:	3dc70713          	addi	a4,a4,988 # 800112b0 <cpus+0x8>
    80001edc:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80001ede:	4a89                	li	s5,2
        c->proc = p;
    80001ee0:	079e                	slli	a5,a5,0x7
    80001ee2:	0000fb17          	auipc	s6,0xf
    80001ee6:	3aeb0b13          	addi	s6,s6,942 # 80011290 <pid_lock>
    80001eea:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eec:	00015a17          	auipc	s4,0x15
    80001ef0:	1bca0a13          	addi	s4,s4,444 # 800170a8 <tickslock>
    int nproc = 0;
    80001ef4:	4c81                	li	s9,0
    80001ef6:	a8a1                	j	80001f4e <scheduler+0xaa>
        p->state = RUNNING;
    80001ef8:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001efc:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80001f00:	06048593          	addi	a1,s1,96
    80001f04:	8562                	mv	a0,s8
    80001f06:	00000097          	auipc	ra,0x0
    80001f0a:	63a080e7          	jalr	1594(ra) # 80002540 <swtch>
        c->proc = 0;
    80001f0e:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	db8080e7          	jalr	-584(ra) # 80000ccc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f1c:	16848493          	addi	s1,s1,360
    80001f20:	01448d63          	beq	s1,s4,80001f3a <scheduler+0x96>
      acquire(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	cf2080e7          	jalr	-782(ra) # 80000c18 <acquire>
      if(p->state != UNUSED) {
    80001f2e:	4c9c                	lw	a5,24(s1)
    80001f30:	d3ed                	beqz	a5,80001f12 <scheduler+0x6e>
        nproc++;
    80001f32:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    80001f34:	fd579fe3          	bne	a5,s5,80001f12 <scheduler+0x6e>
    80001f38:	b7c1                	j	80001ef8 <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    80001f3a:	013aca63          	blt	s5,s3,80001f4e <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f3e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f42:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f46:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001f4a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f4e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f52:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f56:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80001f5a:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f5c:	0000f497          	auipc	s1,0xf
    80001f60:	74c48493          	addi	s1,s1,1868 # 800116a8 <proc>
        p->state = RUNNING;
    80001f64:	4b8d                	li	s7,3
    80001f66:	bf7d                	j	80001f24 <scheduler+0x80>

0000000080001f68 <sched>:
{
    80001f68:	7179                	addi	sp,sp,-48
    80001f6a:	f406                	sd	ra,40(sp)
    80001f6c:	f022                	sd	s0,32(sp)
    80001f6e:	ec26                	sd	s1,24(sp)
    80001f70:	e84a                	sd	s2,16(sp)
    80001f72:	e44e                	sd	s3,8(sp)
    80001f74:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f76:	00000097          	auipc	ra,0x0
    80001f7a:	9fe080e7          	jalr	-1538(ra) # 80001974 <myproc>
    80001f7e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	c1e080e7          	jalr	-994(ra) # 80000b9e <holding>
    80001f88:	c93d                	beqz	a0,80001ffe <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f8a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f8c:	2781                	sext.w	a5,a5
    80001f8e:	079e                	slli	a5,a5,0x7
    80001f90:	0000f717          	auipc	a4,0xf
    80001f94:	30070713          	addi	a4,a4,768 # 80011290 <pid_lock>
    80001f98:	97ba                	add	a5,a5,a4
    80001f9a:	0907a703          	lw	a4,144(a5)
    80001f9e:	4785                	li	a5,1
    80001fa0:	06f71763          	bne	a4,a5,8000200e <sched+0xa6>
  if(p->state == RUNNING)
    80001fa4:	4c98                	lw	a4,24(s1)
    80001fa6:	478d                	li	a5,3
    80001fa8:	06f70b63          	beq	a4,a5,8000201e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fac:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fb0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fb2:	efb5                	bnez	a5,8000202e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fb4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fb6:	0000f917          	auipc	s2,0xf
    80001fba:	2da90913          	addi	s2,s2,730 # 80011290 <pid_lock>
    80001fbe:	2781                	sext.w	a5,a5
    80001fc0:	079e                	slli	a5,a5,0x7
    80001fc2:	97ca                	add	a5,a5,s2
    80001fc4:	0947a983          	lw	s3,148(a5)
    80001fc8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fca:	2781                	sext.w	a5,a5
    80001fcc:	079e                	slli	a5,a5,0x7
    80001fce:	0000f597          	auipc	a1,0xf
    80001fd2:	2e258593          	addi	a1,a1,738 # 800112b0 <cpus+0x8>
    80001fd6:	95be                	add	a1,a1,a5
    80001fd8:	06048513          	addi	a0,s1,96
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	564080e7          	jalr	1380(ra) # 80002540 <swtch>
    80001fe4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fe6:	2781                	sext.w	a5,a5
    80001fe8:	079e                	slli	a5,a5,0x7
    80001fea:	97ca                	add	a5,a5,s2
    80001fec:	0937aa23          	sw	s3,148(a5)
}
    80001ff0:	70a2                	ld	ra,40(sp)
    80001ff2:	7402                	ld	s0,32(sp)
    80001ff4:	64e2                	ld	s1,24(sp)
    80001ff6:	6942                	ld	s2,16(sp)
    80001ff8:	69a2                	ld	s3,8(sp)
    80001ffa:	6145                	addi	sp,sp,48
    80001ffc:	8082                	ret
    panic("sched p->lock");
    80001ffe:	00006517          	auipc	a0,0x6
    80002002:	1fa50513          	addi	a0,a0,506 # 800081f8 <digits+0x1b8>
    80002006:	ffffe097          	auipc	ra,0xffffe
    8000200a:	54a080e7          	jalr	1354(ra) # 80000550 <panic>
    panic("sched locks");
    8000200e:	00006517          	auipc	a0,0x6
    80002012:	1fa50513          	addi	a0,a0,506 # 80008208 <digits+0x1c8>
    80002016:	ffffe097          	auipc	ra,0xffffe
    8000201a:	53a080e7          	jalr	1338(ra) # 80000550 <panic>
    panic("sched running");
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	1fa50513          	addi	a0,a0,506 # 80008218 <digits+0x1d8>
    80002026:	ffffe097          	auipc	ra,0xffffe
    8000202a:	52a080e7          	jalr	1322(ra) # 80000550 <panic>
    panic("sched interruptible");
    8000202e:	00006517          	auipc	a0,0x6
    80002032:	1fa50513          	addi	a0,a0,506 # 80008228 <digits+0x1e8>
    80002036:	ffffe097          	auipc	ra,0xffffe
    8000203a:	51a080e7          	jalr	1306(ra) # 80000550 <panic>

000000008000203e <exit>:
{
    8000203e:	7179                	addi	sp,sp,-48
    80002040:	f406                	sd	ra,40(sp)
    80002042:	f022                	sd	s0,32(sp)
    80002044:	ec26                	sd	s1,24(sp)
    80002046:	e84a                	sd	s2,16(sp)
    80002048:	e44e                	sd	s3,8(sp)
    8000204a:	e052                	sd	s4,0(sp)
    8000204c:	1800                	addi	s0,sp,48
    8000204e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002050:	00000097          	auipc	ra,0x0
    80002054:	924080e7          	jalr	-1756(ra) # 80001974 <myproc>
    80002058:	89aa                	mv	s3,a0
  if(p == initproc)
    8000205a:	00007797          	auipc	a5,0x7
    8000205e:	fbe7b783          	ld	a5,-66(a5) # 80009018 <initproc>
    80002062:	0d050493          	addi	s1,a0,208
    80002066:	15050913          	addi	s2,a0,336
    8000206a:	02a79363          	bne	a5,a0,80002090 <exit+0x52>
    panic("init exiting");
    8000206e:	00006517          	auipc	a0,0x6
    80002072:	1d250513          	addi	a0,a0,466 # 80008240 <digits+0x200>
    80002076:	ffffe097          	auipc	ra,0xffffe
    8000207a:	4da080e7          	jalr	1242(ra) # 80000550 <panic>
      fileclose(f);
    8000207e:	00002097          	auipc	ra,0x2
    80002082:	3ca080e7          	jalr	970(ra) # 80004448 <fileclose>
      p->ofile[fd] = 0;
    80002086:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000208a:	04a1                	addi	s1,s1,8
    8000208c:	01248563          	beq	s1,s2,80002096 <exit+0x58>
    if(p->ofile[fd]){
    80002090:	6088                	ld	a0,0(s1)
    80002092:	f575                	bnez	a0,8000207e <exit+0x40>
    80002094:	bfdd                	j	8000208a <exit+0x4c>
  begin_op();
    80002096:	00002097          	auipc	ra,0x2
    8000209a:	ede080e7          	jalr	-290(ra) # 80003f74 <begin_op>
  iput(p->cwd);
    8000209e:	1509b503          	ld	a0,336(s3)
    800020a2:	00001097          	auipc	ra,0x1
    800020a6:	6bc080e7          	jalr	1724(ra) # 8000375e <iput>
  end_op();
    800020aa:	00002097          	auipc	ra,0x2
    800020ae:	f4a080e7          	jalr	-182(ra) # 80003ff4 <end_op>
  p->cwd = 0;
    800020b2:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800020b6:	00007497          	auipc	s1,0x7
    800020ba:	f6248493          	addi	s1,s1,-158 # 80009018 <initproc>
    800020be:	6088                	ld	a0,0(s1)
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	b58080e7          	jalr	-1192(ra) # 80000c18 <acquire>
  wakeup1(initproc);
    800020c8:	6088                	ld	a0,0(s1)
    800020ca:	fffff097          	auipc	ra,0xfffff
    800020ce:	76a080e7          	jalr	1898(ra) # 80001834 <wakeup1>
  release(&initproc->lock);
    800020d2:	6088                	ld	a0,0(s1)
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	bf8080e7          	jalr	-1032(ra) # 80000ccc <release>
  acquire(&p->lock);
    800020dc:	854e                	mv	a0,s3
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	b3a080e7          	jalr	-1222(ra) # 80000c18 <acquire>
  struct proc *original_parent = p->parent;
    800020e6:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800020ea:	854e                	mv	a0,s3
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	be0080e7          	jalr	-1056(ra) # 80000ccc <release>
  acquire(&original_parent->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	b22080e7          	jalr	-1246(ra) # 80000c18 <acquire>
  acquire(&p->lock);
    800020fe:	854e                	mv	a0,s3
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	b18080e7          	jalr	-1256(ra) # 80000c18 <acquire>
  reparent(p);
    80002108:	854e                	mv	a0,s3
    8000210a:	00000097          	auipc	ra,0x0
    8000210e:	d34080e7          	jalr	-716(ra) # 80001e3e <reparent>
  wakeup1(original_parent);
    80002112:	8526                	mv	a0,s1
    80002114:	fffff097          	auipc	ra,0xfffff
    80002118:	720080e7          	jalr	1824(ra) # 80001834 <wakeup1>
  p->xstate = status;
    8000211c:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002120:	4791                	li	a5,4
    80002122:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	ba4080e7          	jalr	-1116(ra) # 80000ccc <release>
  sched();
    80002130:	00000097          	auipc	ra,0x0
    80002134:	e38080e7          	jalr	-456(ra) # 80001f68 <sched>
  panic("zombie exit");
    80002138:	00006517          	auipc	a0,0x6
    8000213c:	11850513          	addi	a0,a0,280 # 80008250 <digits+0x210>
    80002140:	ffffe097          	auipc	ra,0xffffe
    80002144:	410080e7          	jalr	1040(ra) # 80000550 <panic>

0000000080002148 <yield>:
{
    80002148:	1101                	addi	sp,sp,-32
    8000214a:	ec06                	sd	ra,24(sp)
    8000214c:	e822                	sd	s0,16(sp)
    8000214e:	e426                	sd	s1,8(sp)
    80002150:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002152:	00000097          	auipc	ra,0x0
    80002156:	822080e7          	jalr	-2014(ra) # 80001974 <myproc>
    8000215a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	abc080e7          	jalr	-1348(ra) # 80000c18 <acquire>
  p->state = RUNNABLE;
    80002164:	4789                	li	a5,2
    80002166:	cc9c                	sw	a5,24(s1)
  sched();
    80002168:	00000097          	auipc	ra,0x0
    8000216c:	e00080e7          	jalr	-512(ra) # 80001f68 <sched>
  release(&p->lock);
    80002170:	8526                	mv	a0,s1
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	b5a080e7          	jalr	-1190(ra) # 80000ccc <release>
}
    8000217a:	60e2                	ld	ra,24(sp)
    8000217c:	6442                	ld	s0,16(sp)
    8000217e:	64a2                	ld	s1,8(sp)
    80002180:	6105                	addi	sp,sp,32
    80002182:	8082                	ret

0000000080002184 <sleep>:
{
    80002184:	7179                	addi	sp,sp,-48
    80002186:	f406                	sd	ra,40(sp)
    80002188:	f022                	sd	s0,32(sp)
    8000218a:	ec26                	sd	s1,24(sp)
    8000218c:	e84a                	sd	s2,16(sp)
    8000218e:	e44e                	sd	s3,8(sp)
    80002190:	1800                	addi	s0,sp,48
    80002192:	89aa                	mv	s3,a0
    80002194:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	7de080e7          	jalr	2014(ra) # 80001974 <myproc>
    8000219e:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800021a0:	05250663          	beq	a0,s2,800021ec <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	a74080e7          	jalr	-1420(ra) # 80000c18 <acquire>
    release(lk);
    800021ac:	854a                	mv	a0,s2
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	b1e080e7          	jalr	-1250(ra) # 80000ccc <release>
  p->chan = chan;
    800021b6:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800021ba:	4785                	li	a5,1
    800021bc:	cc9c                	sw	a5,24(s1)
  sched();
    800021be:	00000097          	auipc	ra,0x0
    800021c2:	daa080e7          	jalr	-598(ra) # 80001f68 <sched>
  p->chan = 0;
    800021c6:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	b00080e7          	jalr	-1280(ra) # 80000ccc <release>
    acquire(lk);
    800021d4:	854a                	mv	a0,s2
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	a42080e7          	jalr	-1470(ra) # 80000c18 <acquire>
}
    800021de:	70a2                	ld	ra,40(sp)
    800021e0:	7402                	ld	s0,32(sp)
    800021e2:	64e2                	ld	s1,24(sp)
    800021e4:	6942                	ld	s2,16(sp)
    800021e6:	69a2                	ld	s3,8(sp)
    800021e8:	6145                	addi	sp,sp,48
    800021ea:	8082                	ret
  p->chan = chan;
    800021ec:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800021f0:	4785                	li	a5,1
    800021f2:	cd1c                	sw	a5,24(a0)
  sched();
    800021f4:	00000097          	auipc	ra,0x0
    800021f8:	d74080e7          	jalr	-652(ra) # 80001f68 <sched>
  p->chan = 0;
    800021fc:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002200:	bff9                	j	800021de <sleep+0x5a>

0000000080002202 <wait>:
{
    80002202:	715d                	addi	sp,sp,-80
    80002204:	e486                	sd	ra,72(sp)
    80002206:	e0a2                	sd	s0,64(sp)
    80002208:	fc26                	sd	s1,56(sp)
    8000220a:	f84a                	sd	s2,48(sp)
    8000220c:	f44e                	sd	s3,40(sp)
    8000220e:	f052                	sd	s4,32(sp)
    80002210:	ec56                	sd	s5,24(sp)
    80002212:	e85a                	sd	s6,16(sp)
    80002214:	e45e                	sd	s7,8(sp)
    80002216:	e062                	sd	s8,0(sp)
    80002218:	0880                	addi	s0,sp,80
    8000221a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	758080e7          	jalr	1880(ra) # 80001974 <myproc>
    80002224:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002226:	8c2a                	mv	s8,a0
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	9f0080e7          	jalr	-1552(ra) # 80000c18 <acquire>
    havekids = 0;
    80002230:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002232:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    80002234:	00015997          	auipc	s3,0x15
    80002238:	e7498993          	addi	s3,s3,-396 # 800170a8 <tickslock>
        havekids = 1;
    8000223c:	4a85                	li	s5,1
    havekids = 0;
    8000223e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002240:	0000f497          	auipc	s1,0xf
    80002244:	46848493          	addi	s1,s1,1128 # 800116a8 <proc>
    80002248:	a08d                	j	800022aa <wait+0xa8>
          pid = np->pid;
    8000224a:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000224e:	000b0e63          	beqz	s6,8000226a <wait+0x68>
    80002252:	4691                	li	a3,4
    80002254:	03448613          	addi	a2,s1,52
    80002258:	85da                	mv	a1,s6
    8000225a:	05093503          	ld	a0,80(s2)
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	40a080e7          	jalr	1034(ra) # 80001668 <copyout>
    80002266:	02054263          	bltz	a0,8000228a <wait+0x88>
          freeproc(np);
    8000226a:	8526                	mv	a0,s1
    8000226c:	00000097          	auipc	ra,0x0
    80002270:	8ba080e7          	jalr	-1862(ra) # 80001b26 <freeproc>
          release(&np->lock);
    80002274:	8526                	mv	a0,s1
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	a56080e7          	jalr	-1450(ra) # 80000ccc <release>
          release(&p->lock);
    8000227e:	854a                	mv	a0,s2
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	a4c080e7          	jalr	-1460(ra) # 80000ccc <release>
          return pid;
    80002288:	a8a9                	j	800022e2 <wait+0xe0>
            release(&np->lock);
    8000228a:	8526                	mv	a0,s1
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	a40080e7          	jalr	-1472(ra) # 80000ccc <release>
            release(&p->lock);
    80002294:	854a                	mv	a0,s2
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	a36080e7          	jalr	-1482(ra) # 80000ccc <release>
            return -1;
    8000229e:	59fd                	li	s3,-1
    800022a0:	a089                	j	800022e2 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800022a2:	16848493          	addi	s1,s1,360
    800022a6:	03348463          	beq	s1,s3,800022ce <wait+0xcc>
      if(np->parent == p){
    800022aa:	709c                	ld	a5,32(s1)
    800022ac:	ff279be3          	bne	a5,s2,800022a2 <wait+0xa0>
        acquire(&np->lock);
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	966080e7          	jalr	-1690(ra) # 80000c18 <acquire>
        if(np->state == ZOMBIE){
    800022ba:	4c9c                	lw	a5,24(s1)
    800022bc:	f94787e3          	beq	a5,s4,8000224a <wait+0x48>
        release(&np->lock);
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	a0a080e7          	jalr	-1526(ra) # 80000ccc <release>
        havekids = 1;
    800022ca:	8756                	mv	a4,s5
    800022cc:	bfd9                	j	800022a2 <wait+0xa0>
    if(!havekids || p->killed){
    800022ce:	c701                	beqz	a4,800022d6 <wait+0xd4>
    800022d0:	03092783          	lw	a5,48(s2)
    800022d4:	c785                	beqz	a5,800022fc <wait+0xfa>
      release(&p->lock);
    800022d6:	854a                	mv	a0,s2
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	9f4080e7          	jalr	-1548(ra) # 80000ccc <release>
      return -1;
    800022e0:	59fd                	li	s3,-1
}
    800022e2:	854e                	mv	a0,s3
    800022e4:	60a6                	ld	ra,72(sp)
    800022e6:	6406                	ld	s0,64(sp)
    800022e8:	74e2                	ld	s1,56(sp)
    800022ea:	7942                	ld	s2,48(sp)
    800022ec:	79a2                	ld	s3,40(sp)
    800022ee:	7a02                	ld	s4,32(sp)
    800022f0:	6ae2                	ld	s5,24(sp)
    800022f2:	6b42                	ld	s6,16(sp)
    800022f4:	6ba2                	ld	s7,8(sp)
    800022f6:	6c02                	ld	s8,0(sp)
    800022f8:	6161                	addi	sp,sp,80
    800022fa:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800022fc:	85e2                	mv	a1,s8
    800022fe:	854a                	mv	a0,s2
    80002300:	00000097          	auipc	ra,0x0
    80002304:	e84080e7          	jalr	-380(ra) # 80002184 <sleep>
    havekids = 0;
    80002308:	bf1d                	j	8000223e <wait+0x3c>

000000008000230a <wakeup>:
{
    8000230a:	7139                	addi	sp,sp,-64
    8000230c:	fc06                	sd	ra,56(sp)
    8000230e:	f822                	sd	s0,48(sp)
    80002310:	f426                	sd	s1,40(sp)
    80002312:	f04a                	sd	s2,32(sp)
    80002314:	ec4e                	sd	s3,24(sp)
    80002316:	e852                	sd	s4,16(sp)
    80002318:	e456                	sd	s5,8(sp)
    8000231a:	0080                	addi	s0,sp,64
    8000231c:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000231e:	0000f497          	auipc	s1,0xf
    80002322:	38a48493          	addi	s1,s1,906 # 800116a8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002326:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002328:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000232a:	00015917          	auipc	s2,0x15
    8000232e:	d7e90913          	addi	s2,s2,-642 # 800170a8 <tickslock>
    80002332:	a821                	j	8000234a <wakeup+0x40>
      p->state = RUNNABLE;
    80002334:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	992080e7          	jalr	-1646(ra) # 80000ccc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002342:	16848493          	addi	s1,s1,360
    80002346:	01248e63          	beq	s1,s2,80002362 <wakeup+0x58>
    acquire(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	8cc080e7          	jalr	-1844(ra) # 80000c18 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002354:	4c9c                	lw	a5,24(s1)
    80002356:	ff3791e3          	bne	a5,s3,80002338 <wakeup+0x2e>
    8000235a:	749c                	ld	a5,40(s1)
    8000235c:	fd479ee3          	bne	a5,s4,80002338 <wakeup+0x2e>
    80002360:	bfd1                	j	80002334 <wakeup+0x2a>
}
    80002362:	70e2                	ld	ra,56(sp)
    80002364:	7442                	ld	s0,48(sp)
    80002366:	74a2                	ld	s1,40(sp)
    80002368:	7902                	ld	s2,32(sp)
    8000236a:	69e2                	ld	s3,24(sp)
    8000236c:	6a42                	ld	s4,16(sp)
    8000236e:	6aa2                	ld	s5,8(sp)
    80002370:	6121                	addi	sp,sp,64
    80002372:	8082                	ret

0000000080002374 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002374:	7179                	addi	sp,sp,-48
    80002376:	f406                	sd	ra,40(sp)
    80002378:	f022                	sd	s0,32(sp)
    8000237a:	ec26                	sd	s1,24(sp)
    8000237c:	e84a                	sd	s2,16(sp)
    8000237e:	e44e                	sd	s3,8(sp)
    80002380:	1800                	addi	s0,sp,48
    80002382:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002384:	0000f497          	auipc	s1,0xf
    80002388:	32448493          	addi	s1,s1,804 # 800116a8 <proc>
    8000238c:	00015997          	auipc	s3,0x15
    80002390:	d1c98993          	addi	s3,s3,-740 # 800170a8 <tickslock>
    acquire(&p->lock);
    80002394:	8526                	mv	a0,s1
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	882080e7          	jalr	-1918(ra) # 80000c18 <acquire>
    if(p->pid == pid){
    8000239e:	5c9c                	lw	a5,56(s1)
    800023a0:	01278d63          	beq	a5,s2,800023ba <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	926080e7          	jalr	-1754(ra) # 80000ccc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023ae:	16848493          	addi	s1,s1,360
    800023b2:	ff3491e3          	bne	s1,s3,80002394 <kill+0x20>
  }
  return -1;
    800023b6:	557d                	li	a0,-1
    800023b8:	a829                	j	800023d2 <kill+0x5e>
      p->killed = 1;
    800023ba:	4785                	li	a5,1
    800023bc:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800023be:	4c98                	lw	a4,24(s1)
    800023c0:	4785                	li	a5,1
    800023c2:	00f70f63          	beq	a4,a5,800023e0 <kill+0x6c>
      release(&p->lock);
    800023c6:	8526                	mv	a0,s1
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	904080e7          	jalr	-1788(ra) # 80000ccc <release>
      return 0;
    800023d0:	4501                	li	a0,0
}
    800023d2:	70a2                	ld	ra,40(sp)
    800023d4:	7402                	ld	s0,32(sp)
    800023d6:	64e2                	ld	s1,24(sp)
    800023d8:	6942                	ld	s2,16(sp)
    800023da:	69a2                	ld	s3,8(sp)
    800023dc:	6145                	addi	sp,sp,48
    800023de:	8082                	ret
        p->state = RUNNABLE;
    800023e0:	4789                	li	a5,2
    800023e2:	cc9c                	sw	a5,24(s1)
    800023e4:	b7cd                	j	800023c6 <kill+0x52>

00000000800023e6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800023e6:	7179                	addi	sp,sp,-48
    800023e8:	f406                	sd	ra,40(sp)
    800023ea:	f022                	sd	s0,32(sp)
    800023ec:	ec26                	sd	s1,24(sp)
    800023ee:	e84a                	sd	s2,16(sp)
    800023f0:	e44e                	sd	s3,8(sp)
    800023f2:	e052                	sd	s4,0(sp)
    800023f4:	1800                	addi	s0,sp,48
    800023f6:	84aa                	mv	s1,a0
    800023f8:	892e                	mv	s2,a1
    800023fa:	89b2                	mv	s3,a2
    800023fc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	576080e7          	jalr	1398(ra) # 80001974 <myproc>
  if(user_dst){
    80002406:	c08d                	beqz	s1,80002428 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002408:	86d2                	mv	a3,s4
    8000240a:	864e                	mv	a2,s3
    8000240c:	85ca                	mv	a1,s2
    8000240e:	6928                	ld	a0,80(a0)
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	258080e7          	jalr	600(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002418:	70a2                	ld	ra,40(sp)
    8000241a:	7402                	ld	s0,32(sp)
    8000241c:	64e2                	ld	s1,24(sp)
    8000241e:	6942                	ld	s2,16(sp)
    80002420:	69a2                	ld	s3,8(sp)
    80002422:	6a02                	ld	s4,0(sp)
    80002424:	6145                	addi	sp,sp,48
    80002426:	8082                	ret
    memmove((char *)dst, src, len);
    80002428:	000a061b          	sext.w	a2,s4
    8000242c:	85ce                	mv	a1,s3
    8000242e:	854a                	mv	a0,s2
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	944080e7          	jalr	-1724(ra) # 80000d74 <memmove>
    return 0;
    80002438:	8526                	mv	a0,s1
    8000243a:	bff9                	j	80002418 <either_copyout+0x32>

000000008000243c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000243c:	7179                	addi	sp,sp,-48
    8000243e:	f406                	sd	ra,40(sp)
    80002440:	f022                	sd	s0,32(sp)
    80002442:	ec26                	sd	s1,24(sp)
    80002444:	e84a                	sd	s2,16(sp)
    80002446:	e44e                	sd	s3,8(sp)
    80002448:	e052                	sd	s4,0(sp)
    8000244a:	1800                	addi	s0,sp,48
    8000244c:	892a                	mv	s2,a0
    8000244e:	84ae                	mv	s1,a1
    80002450:	89b2                	mv	s3,a2
    80002452:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002454:	fffff097          	auipc	ra,0xfffff
    80002458:	520080e7          	jalr	1312(ra) # 80001974 <myproc>
  if(user_src){
    8000245c:	c08d                	beqz	s1,8000247e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000245e:	86d2                	mv	a3,s4
    80002460:	864e                	mv	a2,s3
    80002462:	85ca                	mv	a1,s2
    80002464:	6928                	ld	a0,80(a0)
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	28e080e7          	jalr	654(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000246e:	70a2                	ld	ra,40(sp)
    80002470:	7402                	ld	s0,32(sp)
    80002472:	64e2                	ld	s1,24(sp)
    80002474:	6942                	ld	s2,16(sp)
    80002476:	69a2                	ld	s3,8(sp)
    80002478:	6a02                	ld	s4,0(sp)
    8000247a:	6145                	addi	sp,sp,48
    8000247c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000247e:	000a061b          	sext.w	a2,s4
    80002482:	85ce                	mv	a1,s3
    80002484:	854a                	mv	a0,s2
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	8ee080e7          	jalr	-1810(ra) # 80000d74 <memmove>
    return 0;
    8000248e:	8526                	mv	a0,s1
    80002490:	bff9                	j	8000246e <either_copyin+0x32>

0000000080002492 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002492:	715d                	addi	sp,sp,-80
    80002494:	e486                	sd	ra,72(sp)
    80002496:	e0a2                	sd	s0,64(sp)
    80002498:	fc26                	sd	s1,56(sp)
    8000249a:	f84a                	sd	s2,48(sp)
    8000249c:	f44e                	sd	s3,40(sp)
    8000249e:	f052                	sd	s4,32(sp)
    800024a0:	ec56                	sd	s5,24(sp)
    800024a2:	e85a                	sd	s6,16(sp)
    800024a4:	e45e                	sd	s7,8(sp)
    800024a6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024a8:	00006517          	auipc	a0,0x6
    800024ac:	c2050513          	addi	a0,a0,-992 # 800080c8 <digits+0x88>
    800024b0:	ffffe097          	auipc	ra,0xffffe
    800024b4:	0ea080e7          	jalr	234(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024b8:	0000f497          	auipc	s1,0xf
    800024bc:	34848493          	addi	s1,s1,840 # 80011800 <proc+0x158>
    800024c0:	00015917          	auipc	s2,0x15
    800024c4:	d4090913          	addi	s2,s2,-704 # 80017200 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024c8:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800024ca:	00006997          	auipc	s3,0x6
    800024ce:	d9698993          	addi	s3,s3,-618 # 80008260 <digits+0x220>
    printf("%d %s %s", p->pid, state, p->name);
    800024d2:	00006a97          	auipc	s5,0x6
    800024d6:	d96a8a93          	addi	s5,s5,-618 # 80008268 <digits+0x228>
    printf("\n");
    800024da:	00006a17          	auipc	s4,0x6
    800024de:	beea0a13          	addi	s4,s4,-1042 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024e2:	00006b97          	auipc	s7,0x6
    800024e6:	dbeb8b93          	addi	s7,s7,-578 # 800082a0 <states.1700>
    800024ea:	a00d                	j	8000250c <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800024ec:	ee06a583          	lw	a1,-288(a3)
    800024f0:	8556                	mv	a0,s5
    800024f2:	ffffe097          	auipc	ra,0xffffe
    800024f6:	0a8080e7          	jalr	168(ra) # 8000059a <printf>
    printf("\n");
    800024fa:	8552                	mv	a0,s4
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	09e080e7          	jalr	158(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002504:	16848493          	addi	s1,s1,360
    80002508:	03248163          	beq	s1,s2,8000252a <procdump+0x98>
    if(p->state == UNUSED)
    8000250c:	86a6                	mv	a3,s1
    8000250e:	ec04a783          	lw	a5,-320(s1)
    80002512:	dbed                	beqz	a5,80002504 <procdump+0x72>
      state = "???";
    80002514:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002516:	fcfb6be3          	bltu	s6,a5,800024ec <procdump+0x5a>
    8000251a:	1782                	slli	a5,a5,0x20
    8000251c:	9381                	srli	a5,a5,0x20
    8000251e:	078e                	slli	a5,a5,0x3
    80002520:	97de                	add	a5,a5,s7
    80002522:	6390                	ld	a2,0(a5)
    80002524:	f661                	bnez	a2,800024ec <procdump+0x5a>
      state = "???";
    80002526:	864e                	mv	a2,s3
    80002528:	b7d1                	j	800024ec <procdump+0x5a>
  }
}
    8000252a:	60a6                	ld	ra,72(sp)
    8000252c:	6406                	ld	s0,64(sp)
    8000252e:	74e2                	ld	s1,56(sp)
    80002530:	7942                	ld	s2,48(sp)
    80002532:	79a2                	ld	s3,40(sp)
    80002534:	7a02                	ld	s4,32(sp)
    80002536:	6ae2                	ld	s5,24(sp)
    80002538:	6b42                	ld	s6,16(sp)
    8000253a:	6ba2                	ld	s7,8(sp)
    8000253c:	6161                	addi	sp,sp,80
    8000253e:	8082                	ret

0000000080002540 <swtch>:
    80002540:	00153023          	sd	ra,0(a0)
    80002544:	00253423          	sd	sp,8(a0)
    80002548:	e900                	sd	s0,16(a0)
    8000254a:	ed04                	sd	s1,24(a0)
    8000254c:	03253023          	sd	s2,32(a0)
    80002550:	03353423          	sd	s3,40(a0)
    80002554:	03453823          	sd	s4,48(a0)
    80002558:	03553c23          	sd	s5,56(a0)
    8000255c:	05653023          	sd	s6,64(a0)
    80002560:	05753423          	sd	s7,72(a0)
    80002564:	05853823          	sd	s8,80(a0)
    80002568:	05953c23          	sd	s9,88(a0)
    8000256c:	07a53023          	sd	s10,96(a0)
    80002570:	07b53423          	sd	s11,104(a0)
    80002574:	0005b083          	ld	ra,0(a1)
    80002578:	0085b103          	ld	sp,8(a1)
    8000257c:	6980                	ld	s0,16(a1)
    8000257e:	6d84                	ld	s1,24(a1)
    80002580:	0205b903          	ld	s2,32(a1)
    80002584:	0285b983          	ld	s3,40(a1)
    80002588:	0305ba03          	ld	s4,48(a1)
    8000258c:	0385ba83          	ld	s5,56(a1)
    80002590:	0405bb03          	ld	s6,64(a1)
    80002594:	0485bb83          	ld	s7,72(a1)
    80002598:	0505bc03          	ld	s8,80(a1)
    8000259c:	0585bc83          	ld	s9,88(a1)
    800025a0:	0605bd03          	ld	s10,96(a1)
    800025a4:	0685bd83          	ld	s11,104(a1)
    800025a8:	8082                	ret

00000000800025aa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025aa:	1141                	addi	sp,sp,-16
    800025ac:	e406                	sd	ra,8(sp)
    800025ae:	e022                	sd	s0,0(sp)
    800025b0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025b2:	00006597          	auipc	a1,0x6
    800025b6:	d1658593          	addi	a1,a1,-746 # 800082c8 <states.1700+0x28>
    800025ba:	00015517          	auipc	a0,0x15
    800025be:	aee50513          	addi	a0,a0,-1298 # 800170a8 <tickslock>
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	5c6080e7          	jalr	1478(ra) # 80000b88 <initlock>
}
    800025ca:	60a2                	ld	ra,8(sp)
    800025cc:	6402                	ld	s0,0(sp)
    800025ce:	0141                	addi	sp,sp,16
    800025d0:	8082                	ret

00000000800025d2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025d2:	1141                	addi	sp,sp,-16
    800025d4:	e422                	sd	s0,8(sp)
    800025d6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025d8:	00003797          	auipc	a5,0x3
    800025dc:	4d878793          	addi	a5,a5,1240 # 80005ab0 <kernelvec>
    800025e0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800025e4:	6422                	ld	s0,8(sp)
    800025e6:	0141                	addi	sp,sp,16
    800025e8:	8082                	ret

00000000800025ea <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800025ea:	1141                	addi	sp,sp,-16
    800025ec:	e406                	sd	ra,8(sp)
    800025ee:	e022                	sd	s0,0(sp)
    800025f0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	382080e7          	jalr	898(ra) # 80001974 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800025fe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002600:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002604:	00005617          	auipc	a2,0x5
    80002608:	9fc60613          	addi	a2,a2,-1540 # 80007000 <_trampoline>
    8000260c:	00005697          	auipc	a3,0x5
    80002610:	9f468693          	addi	a3,a3,-1548 # 80007000 <_trampoline>
    80002614:	8e91                	sub	a3,a3,a2
    80002616:	040007b7          	lui	a5,0x4000
    8000261a:	17fd                	addi	a5,a5,-1
    8000261c:	07b2                	slli	a5,a5,0xc
    8000261e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002620:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002624:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002626:	180026f3          	csrr	a3,satp
    8000262a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000262c:	6d38                	ld	a4,88(a0)
    8000262e:	6134                	ld	a3,64(a0)
    80002630:	6585                	lui	a1,0x1
    80002632:	96ae                	add	a3,a3,a1
    80002634:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002636:	6d38                	ld	a4,88(a0)
    80002638:	00000697          	auipc	a3,0x0
    8000263c:	13868693          	addi	a3,a3,312 # 80002770 <usertrap>
    80002640:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002642:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002644:	8692                	mv	a3,tp
    80002646:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002648:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000264c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002650:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002654:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002658:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000265a:	6f18                	ld	a4,24(a4)
    8000265c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002660:	692c                	ld	a1,80(a0)
    80002662:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002664:	00005717          	auipc	a4,0x5
    80002668:	a2c70713          	addi	a4,a4,-1492 # 80007090 <userret>
    8000266c:	8f11                	sub	a4,a4,a2
    8000266e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002670:	577d                	li	a4,-1
    80002672:	177e                	slli	a4,a4,0x3f
    80002674:	8dd9                	or	a1,a1,a4
    80002676:	02000537          	lui	a0,0x2000
    8000267a:	157d                	addi	a0,a0,-1
    8000267c:	0536                	slli	a0,a0,0xd
    8000267e:	9782                	jalr	a5
}
    80002680:	60a2                	ld	ra,8(sp)
    80002682:	6402                	ld	s0,0(sp)
    80002684:	0141                	addi	sp,sp,16
    80002686:	8082                	ret

0000000080002688 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002688:	1101                	addi	sp,sp,-32
    8000268a:	ec06                	sd	ra,24(sp)
    8000268c:	e822                	sd	s0,16(sp)
    8000268e:	e426                	sd	s1,8(sp)
    80002690:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002692:	00015497          	auipc	s1,0x15
    80002696:	a1648493          	addi	s1,s1,-1514 # 800170a8 <tickslock>
    8000269a:	8526                	mv	a0,s1
    8000269c:	ffffe097          	auipc	ra,0xffffe
    800026a0:	57c080e7          	jalr	1404(ra) # 80000c18 <acquire>
  ticks++;
    800026a4:	00007517          	auipc	a0,0x7
    800026a8:	97c50513          	addi	a0,a0,-1668 # 80009020 <ticks>
    800026ac:	411c                	lw	a5,0(a0)
    800026ae:	2785                	addiw	a5,a5,1
    800026b0:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800026b2:	00000097          	auipc	ra,0x0
    800026b6:	c58080e7          	jalr	-936(ra) # 8000230a <wakeup>
  release(&tickslock);
    800026ba:	8526                	mv	a0,s1
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	610080e7          	jalr	1552(ra) # 80000ccc <release>
}
    800026c4:	60e2                	ld	ra,24(sp)
    800026c6:	6442                	ld	s0,16(sp)
    800026c8:	64a2                	ld	s1,8(sp)
    800026ca:	6105                	addi	sp,sp,32
    800026cc:	8082                	ret

00000000800026ce <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026ce:	1101                	addi	sp,sp,-32
    800026d0:	ec06                	sd	ra,24(sp)
    800026d2:	e822                	sd	s0,16(sp)
    800026d4:	e426                	sd	s1,8(sp)
    800026d6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026d8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800026dc:	00074d63          	bltz	a4,800026f6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800026e0:	57fd                	li	a5,-1
    800026e2:	17fe                	slli	a5,a5,0x3f
    800026e4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800026e6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800026e8:	06f70363          	beq	a4,a5,8000274e <devintr+0x80>
  }
}
    800026ec:	60e2                	ld	ra,24(sp)
    800026ee:	6442                	ld	s0,16(sp)
    800026f0:	64a2                	ld	s1,8(sp)
    800026f2:	6105                	addi	sp,sp,32
    800026f4:	8082                	ret
     (scause & 0xff) == 9){
    800026f6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800026fa:	46a5                	li	a3,9
    800026fc:	fed792e3          	bne	a5,a3,800026e0 <devintr+0x12>
    int irq = plic_claim();
    80002700:	00003097          	auipc	ra,0x3
    80002704:	4b8080e7          	jalr	1208(ra) # 80005bb8 <plic_claim>
    80002708:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000270a:	47a9                	li	a5,10
    8000270c:	02f50763          	beq	a0,a5,8000273a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002710:	4785                	li	a5,1
    80002712:	02f50963          	beq	a0,a5,80002744 <devintr+0x76>
    return 1;
    80002716:	4505                	li	a0,1
    } else if(irq){
    80002718:	d8f1                	beqz	s1,800026ec <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000271a:	85a6                	mv	a1,s1
    8000271c:	00006517          	auipc	a0,0x6
    80002720:	bb450513          	addi	a0,a0,-1100 # 800082d0 <states.1700+0x30>
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	e76080e7          	jalr	-394(ra) # 8000059a <printf>
      plic_complete(irq);
    8000272c:	8526                	mv	a0,s1
    8000272e:	00003097          	auipc	ra,0x3
    80002732:	4ae080e7          	jalr	1198(ra) # 80005bdc <plic_complete>
    return 1;
    80002736:	4505                	li	a0,1
    80002738:	bf55                	j	800026ec <devintr+0x1e>
      uartintr();
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	2a2080e7          	jalr	674(ra) # 800009dc <uartintr>
    80002742:	b7ed                	j	8000272c <devintr+0x5e>
      virtio_disk_intr();
    80002744:	00004097          	auipc	ra,0x4
    80002748:	978080e7          	jalr	-1672(ra) # 800060bc <virtio_disk_intr>
    8000274c:	b7c5                	j	8000272c <devintr+0x5e>
    if(cpuid() == 0){
    8000274e:	fffff097          	auipc	ra,0xfffff
    80002752:	1fa080e7          	jalr	506(ra) # 80001948 <cpuid>
    80002756:	c901                	beqz	a0,80002766 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002758:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000275c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000275e:	14479073          	csrw	sip,a5
    return 2;
    80002762:	4509                	li	a0,2
    80002764:	b761                	j	800026ec <devintr+0x1e>
      clockintr();
    80002766:	00000097          	auipc	ra,0x0
    8000276a:	f22080e7          	jalr	-222(ra) # 80002688 <clockintr>
    8000276e:	b7ed                	j	80002758 <devintr+0x8a>

0000000080002770 <usertrap>:
{
    80002770:	1101                	addi	sp,sp,-32
    80002772:	ec06                	sd	ra,24(sp)
    80002774:	e822                	sd	s0,16(sp)
    80002776:	e426                	sd	s1,8(sp)
    80002778:	e04a                	sd	s2,0(sp)
    8000277a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000277c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002780:	1007f793          	andi	a5,a5,256
    80002784:	e3ad                	bnez	a5,800027e6 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002786:	00003797          	auipc	a5,0x3
    8000278a:	32a78793          	addi	a5,a5,810 # 80005ab0 <kernelvec>
    8000278e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002792:	fffff097          	auipc	ra,0xfffff
    80002796:	1e2080e7          	jalr	482(ra) # 80001974 <myproc>
    8000279a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000279c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000279e:	14102773          	csrr	a4,sepc
    800027a2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027a4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027a8:	47a1                	li	a5,8
    800027aa:	04f71c63          	bne	a4,a5,80002802 <usertrap+0x92>
    if(p->killed)
    800027ae:	591c                	lw	a5,48(a0)
    800027b0:	e3b9                	bnez	a5,800027f6 <usertrap+0x86>
    p->trapframe->epc += 4;
    800027b2:	6cb8                	ld	a4,88(s1)
    800027b4:	6f1c                	ld	a5,24(a4)
    800027b6:	0791                	addi	a5,a5,4
    800027b8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800027be:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027c2:	10079073          	csrw	sstatus,a5
    syscall();
    800027c6:	00000097          	auipc	ra,0x0
    800027ca:	2e0080e7          	jalr	736(ra) # 80002aa6 <syscall>
  if(p->killed)
    800027ce:	589c                	lw	a5,48(s1)
    800027d0:	ebc1                	bnez	a5,80002860 <usertrap+0xf0>
  usertrapret();
    800027d2:	00000097          	auipc	ra,0x0
    800027d6:	e18080e7          	jalr	-488(ra) # 800025ea <usertrapret>
}
    800027da:	60e2                	ld	ra,24(sp)
    800027dc:	6442                	ld	s0,16(sp)
    800027de:	64a2                	ld	s1,8(sp)
    800027e0:	6902                	ld	s2,0(sp)
    800027e2:	6105                	addi	sp,sp,32
    800027e4:	8082                	ret
    panic("usertrap: not from user mode");
    800027e6:	00006517          	auipc	a0,0x6
    800027ea:	b0a50513          	addi	a0,a0,-1270 # 800082f0 <states.1700+0x50>
    800027ee:	ffffe097          	auipc	ra,0xffffe
    800027f2:	d62080e7          	jalr	-670(ra) # 80000550 <panic>
      exit(-1);
    800027f6:	557d                	li	a0,-1
    800027f8:	00000097          	auipc	ra,0x0
    800027fc:	846080e7          	jalr	-1978(ra) # 8000203e <exit>
    80002800:	bf4d                	j	800027b2 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002802:	00000097          	auipc	ra,0x0
    80002806:	ecc080e7          	jalr	-308(ra) # 800026ce <devintr>
    8000280a:	892a                	mv	s2,a0
    8000280c:	c501                	beqz	a0,80002814 <usertrap+0xa4>
  if(p->killed)
    8000280e:	589c                	lw	a5,48(s1)
    80002810:	c3a1                	beqz	a5,80002850 <usertrap+0xe0>
    80002812:	a815                	j	80002846 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002814:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002818:	5c90                	lw	a2,56(s1)
    8000281a:	00006517          	auipc	a0,0x6
    8000281e:	af650513          	addi	a0,a0,-1290 # 80008310 <states.1700+0x70>
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	d78080e7          	jalr	-648(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000282a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000282e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002832:	00006517          	auipc	a0,0x6
    80002836:	b0e50513          	addi	a0,a0,-1266 # 80008340 <states.1700+0xa0>
    8000283a:	ffffe097          	auipc	ra,0xffffe
    8000283e:	d60080e7          	jalr	-672(ra) # 8000059a <printf>
    p->killed = 1;
    80002842:	4785                	li	a5,1
    80002844:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002846:	557d                	li	a0,-1
    80002848:	fffff097          	auipc	ra,0xfffff
    8000284c:	7f6080e7          	jalr	2038(ra) # 8000203e <exit>
  if(which_dev == 2)
    80002850:	4789                	li	a5,2
    80002852:	f8f910e3          	bne	s2,a5,800027d2 <usertrap+0x62>
    yield();
    80002856:	00000097          	auipc	ra,0x0
    8000285a:	8f2080e7          	jalr	-1806(ra) # 80002148 <yield>
    8000285e:	bf95                	j	800027d2 <usertrap+0x62>
  int which_dev = 0;
    80002860:	4901                	li	s2,0
    80002862:	b7d5                	j	80002846 <usertrap+0xd6>

0000000080002864 <kerneltrap>:
{
    80002864:	7179                	addi	sp,sp,-48
    80002866:	f406                	sd	ra,40(sp)
    80002868:	f022                	sd	s0,32(sp)
    8000286a:	ec26                	sd	s1,24(sp)
    8000286c:	e84a                	sd	s2,16(sp)
    8000286e:	e44e                	sd	s3,8(sp)
    80002870:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002872:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002876:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000287a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000287e:	1004f793          	andi	a5,s1,256
    80002882:	cb85                	beqz	a5,800028b2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002884:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002888:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000288a:	ef85                	bnez	a5,800028c2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000288c:	00000097          	auipc	ra,0x0
    80002890:	e42080e7          	jalr	-446(ra) # 800026ce <devintr>
    80002894:	cd1d                	beqz	a0,800028d2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002896:	4789                	li	a5,2
    80002898:	06f50a63          	beq	a0,a5,8000290c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000289c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028a0:	10049073          	csrw	sstatus,s1
}
    800028a4:	70a2                	ld	ra,40(sp)
    800028a6:	7402                	ld	s0,32(sp)
    800028a8:	64e2                	ld	s1,24(sp)
    800028aa:	6942                	ld	s2,16(sp)
    800028ac:	69a2                	ld	s3,8(sp)
    800028ae:	6145                	addi	sp,sp,48
    800028b0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028b2:	00006517          	auipc	a0,0x6
    800028b6:	aae50513          	addi	a0,a0,-1362 # 80008360 <states.1700+0xc0>
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	c96080e7          	jalr	-874(ra) # 80000550 <panic>
    panic("kerneltrap: interrupts enabled");
    800028c2:	00006517          	auipc	a0,0x6
    800028c6:	ac650513          	addi	a0,a0,-1338 # 80008388 <states.1700+0xe8>
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	c86080e7          	jalr	-890(ra) # 80000550 <panic>
    printf("scause %p\n", scause);
    800028d2:	85ce                	mv	a1,s3
    800028d4:	00006517          	auipc	a0,0x6
    800028d8:	ad450513          	addi	a0,a0,-1324 # 800083a8 <states.1700+0x108>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	cbe080e7          	jalr	-834(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028e4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028e8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028ec:	00006517          	auipc	a0,0x6
    800028f0:	acc50513          	addi	a0,a0,-1332 # 800083b8 <states.1700+0x118>
    800028f4:	ffffe097          	auipc	ra,0xffffe
    800028f8:	ca6080e7          	jalr	-858(ra) # 8000059a <printf>
    panic("kerneltrap");
    800028fc:	00006517          	auipc	a0,0x6
    80002900:	ad450513          	addi	a0,a0,-1324 # 800083d0 <states.1700+0x130>
    80002904:	ffffe097          	auipc	ra,0xffffe
    80002908:	c4c080e7          	jalr	-948(ra) # 80000550 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	068080e7          	jalr	104(ra) # 80001974 <myproc>
    80002914:	d541                	beqz	a0,8000289c <kerneltrap+0x38>
    80002916:	fffff097          	auipc	ra,0xfffff
    8000291a:	05e080e7          	jalr	94(ra) # 80001974 <myproc>
    8000291e:	4d18                	lw	a4,24(a0)
    80002920:	478d                	li	a5,3
    80002922:	f6f71de3          	bne	a4,a5,8000289c <kerneltrap+0x38>
    yield();
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	822080e7          	jalr	-2014(ra) # 80002148 <yield>
    8000292e:	b7bd                	j	8000289c <kerneltrap+0x38>

0000000080002930 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002930:	1101                	addi	sp,sp,-32
    80002932:	ec06                	sd	ra,24(sp)
    80002934:	e822                	sd	s0,16(sp)
    80002936:	e426                	sd	s1,8(sp)
    80002938:	1000                	addi	s0,sp,32
    8000293a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000293c:	fffff097          	auipc	ra,0xfffff
    80002940:	038080e7          	jalr	56(ra) # 80001974 <myproc>
  switch (n) {
    80002944:	4795                	li	a5,5
    80002946:	0497e163          	bltu	a5,s1,80002988 <argraw+0x58>
    8000294a:	048a                	slli	s1,s1,0x2
    8000294c:	00006717          	auipc	a4,0x6
    80002950:	abc70713          	addi	a4,a4,-1348 # 80008408 <states.1700+0x168>
    80002954:	94ba                	add	s1,s1,a4
    80002956:	409c                	lw	a5,0(s1)
    80002958:	97ba                	add	a5,a5,a4
    8000295a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000295c:	6d3c                	ld	a5,88(a0)
    8000295e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002960:	60e2                	ld	ra,24(sp)
    80002962:	6442                	ld	s0,16(sp)
    80002964:	64a2                	ld	s1,8(sp)
    80002966:	6105                	addi	sp,sp,32
    80002968:	8082                	ret
    return p->trapframe->a1;
    8000296a:	6d3c                	ld	a5,88(a0)
    8000296c:	7fa8                	ld	a0,120(a5)
    8000296e:	bfcd                	j	80002960 <argraw+0x30>
    return p->trapframe->a2;
    80002970:	6d3c                	ld	a5,88(a0)
    80002972:	63c8                	ld	a0,128(a5)
    80002974:	b7f5                	j	80002960 <argraw+0x30>
    return p->trapframe->a3;
    80002976:	6d3c                	ld	a5,88(a0)
    80002978:	67c8                	ld	a0,136(a5)
    8000297a:	b7dd                	j	80002960 <argraw+0x30>
    return p->trapframe->a4;
    8000297c:	6d3c                	ld	a5,88(a0)
    8000297e:	6bc8                	ld	a0,144(a5)
    80002980:	b7c5                	j	80002960 <argraw+0x30>
    return p->trapframe->a5;
    80002982:	6d3c                	ld	a5,88(a0)
    80002984:	6fc8                	ld	a0,152(a5)
    80002986:	bfe9                	j	80002960 <argraw+0x30>
  panic("argraw");
    80002988:	00006517          	auipc	a0,0x6
    8000298c:	a5850513          	addi	a0,a0,-1448 # 800083e0 <states.1700+0x140>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	bc0080e7          	jalr	-1088(ra) # 80000550 <panic>

0000000080002998 <fetchaddr>:
{
    80002998:	1101                	addi	sp,sp,-32
    8000299a:	ec06                	sd	ra,24(sp)
    8000299c:	e822                	sd	s0,16(sp)
    8000299e:	e426                	sd	s1,8(sp)
    800029a0:	e04a                	sd	s2,0(sp)
    800029a2:	1000                	addi	s0,sp,32
    800029a4:	84aa                	mv	s1,a0
    800029a6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029a8:	fffff097          	auipc	ra,0xfffff
    800029ac:	fcc080e7          	jalr	-52(ra) # 80001974 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800029b0:	653c                	ld	a5,72(a0)
    800029b2:	02f4f863          	bgeu	s1,a5,800029e2 <fetchaddr+0x4a>
    800029b6:	00848713          	addi	a4,s1,8
    800029ba:	02e7e663          	bltu	a5,a4,800029e6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029be:	46a1                	li	a3,8
    800029c0:	8626                	mv	a2,s1
    800029c2:	85ca                	mv	a1,s2
    800029c4:	6928                	ld	a0,80(a0)
    800029c6:	fffff097          	auipc	ra,0xfffff
    800029ca:	d2e080e7          	jalr	-722(ra) # 800016f4 <copyin>
    800029ce:	00a03533          	snez	a0,a0
    800029d2:	40a00533          	neg	a0,a0
}
    800029d6:	60e2                	ld	ra,24(sp)
    800029d8:	6442                	ld	s0,16(sp)
    800029da:	64a2                	ld	s1,8(sp)
    800029dc:	6902                	ld	s2,0(sp)
    800029de:	6105                	addi	sp,sp,32
    800029e0:	8082                	ret
    return -1;
    800029e2:	557d                	li	a0,-1
    800029e4:	bfcd                	j	800029d6 <fetchaddr+0x3e>
    800029e6:	557d                	li	a0,-1
    800029e8:	b7fd                	j	800029d6 <fetchaddr+0x3e>

00000000800029ea <fetchstr>:
{
    800029ea:	7179                	addi	sp,sp,-48
    800029ec:	f406                	sd	ra,40(sp)
    800029ee:	f022                	sd	s0,32(sp)
    800029f0:	ec26                	sd	s1,24(sp)
    800029f2:	e84a                	sd	s2,16(sp)
    800029f4:	e44e                	sd	s3,8(sp)
    800029f6:	1800                	addi	s0,sp,48
    800029f8:	892a                	mv	s2,a0
    800029fa:	84ae                	mv	s1,a1
    800029fc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800029fe:	fffff097          	auipc	ra,0xfffff
    80002a02:	f76080e7          	jalr	-138(ra) # 80001974 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002a06:	86ce                	mv	a3,s3
    80002a08:	864a                	mv	a2,s2
    80002a0a:	85a6                	mv	a1,s1
    80002a0c:	6928                	ld	a0,80(a0)
    80002a0e:	fffff097          	auipc	ra,0xfffff
    80002a12:	d72080e7          	jalr	-654(ra) # 80001780 <copyinstr>
  if(err < 0)
    80002a16:	00054763          	bltz	a0,80002a24 <fetchstr+0x3a>
  return strlen(buf);
    80002a1a:	8526                	mv	a0,s1
    80002a1c:	ffffe097          	auipc	ra,0xffffe
    80002a20:	480080e7          	jalr	1152(ra) # 80000e9c <strlen>
}
    80002a24:	70a2                	ld	ra,40(sp)
    80002a26:	7402                	ld	s0,32(sp)
    80002a28:	64e2                	ld	s1,24(sp)
    80002a2a:	6942                	ld	s2,16(sp)
    80002a2c:	69a2                	ld	s3,8(sp)
    80002a2e:	6145                	addi	sp,sp,48
    80002a30:	8082                	ret

0000000080002a32 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	1000                	addi	s0,sp,32
    80002a3c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a3e:	00000097          	auipc	ra,0x0
    80002a42:	ef2080e7          	jalr	-270(ra) # 80002930 <argraw>
    80002a46:	c088                	sw	a0,0(s1)
  return 0;
}
    80002a48:	4501                	li	a0,0
    80002a4a:	60e2                	ld	ra,24(sp)
    80002a4c:	6442                	ld	s0,16(sp)
    80002a4e:	64a2                	ld	s1,8(sp)
    80002a50:	6105                	addi	sp,sp,32
    80002a52:	8082                	ret

0000000080002a54 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002a54:	1101                	addi	sp,sp,-32
    80002a56:	ec06                	sd	ra,24(sp)
    80002a58:	e822                	sd	s0,16(sp)
    80002a5a:	e426                	sd	s1,8(sp)
    80002a5c:	1000                	addi	s0,sp,32
    80002a5e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	ed0080e7          	jalr	-304(ra) # 80002930 <argraw>
    80002a68:	e088                	sd	a0,0(s1)
  return 0;
}
    80002a6a:	4501                	li	a0,0
    80002a6c:	60e2                	ld	ra,24(sp)
    80002a6e:	6442                	ld	s0,16(sp)
    80002a70:	64a2                	ld	s1,8(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret

0000000080002a76 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a76:	1101                	addi	sp,sp,-32
    80002a78:	ec06                	sd	ra,24(sp)
    80002a7a:	e822                	sd	s0,16(sp)
    80002a7c:	e426                	sd	s1,8(sp)
    80002a7e:	e04a                	sd	s2,0(sp)
    80002a80:	1000                	addi	s0,sp,32
    80002a82:	84ae                	mv	s1,a1
    80002a84:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002a86:	00000097          	auipc	ra,0x0
    80002a8a:	eaa080e7          	jalr	-342(ra) # 80002930 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002a8e:	864a                	mv	a2,s2
    80002a90:	85a6                	mv	a1,s1
    80002a92:	00000097          	auipc	ra,0x0
    80002a96:	f58080e7          	jalr	-168(ra) # 800029ea <fetchstr>
}
    80002a9a:	60e2                	ld	ra,24(sp)
    80002a9c:	6442                	ld	s0,16(sp)
    80002a9e:	64a2                	ld	s1,8(sp)
    80002aa0:	6902                	ld	s2,0(sp)
    80002aa2:	6105                	addi	sp,sp,32
    80002aa4:	8082                	ret

0000000080002aa6 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002aa6:	1101                	addi	sp,sp,-32
    80002aa8:	ec06                	sd	ra,24(sp)
    80002aaa:	e822                	sd	s0,16(sp)
    80002aac:	e426                	sd	s1,8(sp)
    80002aae:	e04a                	sd	s2,0(sp)
    80002ab0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	ec2080e7          	jalr	-318(ra) # 80001974 <myproc>
    80002aba:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002abc:	05853903          	ld	s2,88(a0)
    80002ac0:	0a893783          	ld	a5,168(s2)
    80002ac4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ac8:	37fd                	addiw	a5,a5,-1
    80002aca:	4751                	li	a4,20
    80002acc:	00f76f63          	bltu	a4,a5,80002aea <syscall+0x44>
    80002ad0:	00369713          	slli	a4,a3,0x3
    80002ad4:	00006797          	auipc	a5,0x6
    80002ad8:	94c78793          	addi	a5,a5,-1716 # 80008420 <syscalls>
    80002adc:	97ba                	add	a5,a5,a4
    80002ade:	639c                	ld	a5,0(a5)
    80002ae0:	c789                	beqz	a5,80002aea <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002ae2:	9782                	jalr	a5
    80002ae4:	06a93823          	sd	a0,112(s2)
    80002ae8:	a839                	j	80002b06 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002aea:	15848613          	addi	a2,s1,344
    80002aee:	5c8c                	lw	a1,56(s1)
    80002af0:	00006517          	auipc	a0,0x6
    80002af4:	8f850513          	addi	a0,a0,-1800 # 800083e8 <states.1700+0x148>
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	aa2080e7          	jalr	-1374(ra) # 8000059a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b00:	6cbc                	ld	a5,88(s1)
    80002b02:	577d                	li	a4,-1
    80002b04:	fbb8                	sd	a4,112(a5)
  }
}
    80002b06:	60e2                	ld	ra,24(sp)
    80002b08:	6442                	ld	s0,16(sp)
    80002b0a:	64a2                	ld	s1,8(sp)
    80002b0c:	6902                	ld	s2,0(sp)
    80002b0e:	6105                	addi	sp,sp,32
    80002b10:	8082                	ret

0000000080002b12 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b12:	1101                	addi	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002b1a:	fec40593          	addi	a1,s0,-20
    80002b1e:	4501                	li	a0,0
    80002b20:	00000097          	auipc	ra,0x0
    80002b24:	f12080e7          	jalr	-238(ra) # 80002a32 <argint>
    return -1;
    80002b28:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002b2a:	00054963          	bltz	a0,80002b3c <sys_exit+0x2a>
  exit(n);
    80002b2e:	fec42503          	lw	a0,-20(s0)
    80002b32:	fffff097          	auipc	ra,0xfffff
    80002b36:	50c080e7          	jalr	1292(ra) # 8000203e <exit>
  return 0;  // not reached
    80002b3a:	4781                	li	a5,0
}
    80002b3c:	853e                	mv	a0,a5
    80002b3e:	60e2                	ld	ra,24(sp)
    80002b40:	6442                	ld	s0,16(sp)
    80002b42:	6105                	addi	sp,sp,32
    80002b44:	8082                	ret

0000000080002b46 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b46:	1141                	addi	sp,sp,-16
    80002b48:	e406                	sd	ra,8(sp)
    80002b4a:	e022                	sd	s0,0(sp)
    80002b4c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	e26080e7          	jalr	-474(ra) # 80001974 <myproc>
}
    80002b56:	5d08                	lw	a0,56(a0)
    80002b58:	60a2                	ld	ra,8(sp)
    80002b5a:	6402                	ld	s0,0(sp)
    80002b5c:	0141                	addi	sp,sp,16
    80002b5e:	8082                	ret

0000000080002b60 <sys_fork>:

uint64
sys_fork(void)
{
    80002b60:	1141                	addi	sp,sp,-16
    80002b62:	e406                	sd	ra,8(sp)
    80002b64:	e022                	sd	s0,0(sp)
    80002b66:	0800                	addi	s0,sp,16
  return fork();
    80002b68:	fffff097          	auipc	ra,0xfffff
    80002b6c:	1cc080e7          	jalr	460(ra) # 80001d34 <fork>
}
    80002b70:	60a2                	ld	ra,8(sp)
    80002b72:	6402                	ld	s0,0(sp)
    80002b74:	0141                	addi	sp,sp,16
    80002b76:	8082                	ret

0000000080002b78 <sys_wait>:

uint64
sys_wait(void)
{
    80002b78:	1101                	addi	sp,sp,-32
    80002b7a:	ec06                	sd	ra,24(sp)
    80002b7c:	e822                	sd	s0,16(sp)
    80002b7e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002b80:	fe840593          	addi	a1,s0,-24
    80002b84:	4501                	li	a0,0
    80002b86:	00000097          	auipc	ra,0x0
    80002b8a:	ece080e7          	jalr	-306(ra) # 80002a54 <argaddr>
    80002b8e:	87aa                	mv	a5,a0
    return -1;
    80002b90:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002b92:	0007c863          	bltz	a5,80002ba2 <sys_wait+0x2a>
  return wait(p);
    80002b96:	fe843503          	ld	a0,-24(s0)
    80002b9a:	fffff097          	auipc	ra,0xfffff
    80002b9e:	668080e7          	jalr	1640(ra) # 80002202 <wait>
}
    80002ba2:	60e2                	ld	ra,24(sp)
    80002ba4:	6442                	ld	s0,16(sp)
    80002ba6:	6105                	addi	sp,sp,32
    80002ba8:	8082                	ret

0000000080002baa <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002baa:	7179                	addi	sp,sp,-48
    80002bac:	f406                	sd	ra,40(sp)
    80002bae:	f022                	sd	s0,32(sp)
    80002bb0:	ec26                	sd	s1,24(sp)
    80002bb2:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002bb4:	fdc40593          	addi	a1,s0,-36
    80002bb8:	4501                	li	a0,0
    80002bba:	00000097          	auipc	ra,0x0
    80002bbe:	e78080e7          	jalr	-392(ra) # 80002a32 <argint>
    80002bc2:	87aa                	mv	a5,a0
    return -1;
    80002bc4:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002bc6:	0207c063          	bltz	a5,80002be6 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002bca:	fffff097          	auipc	ra,0xfffff
    80002bce:	daa080e7          	jalr	-598(ra) # 80001974 <myproc>
    80002bd2:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002bd4:	fdc42503          	lw	a0,-36(s0)
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	0e8080e7          	jalr	232(ra) # 80001cc0 <growproc>
    80002be0:	00054863          	bltz	a0,80002bf0 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002be4:	8526                	mv	a0,s1
}
    80002be6:	70a2                	ld	ra,40(sp)
    80002be8:	7402                	ld	s0,32(sp)
    80002bea:	64e2                	ld	s1,24(sp)
    80002bec:	6145                	addi	sp,sp,48
    80002bee:	8082                	ret
    return -1;
    80002bf0:	557d                	li	a0,-1
    80002bf2:	bfd5                	j	80002be6 <sys_sbrk+0x3c>

0000000080002bf4 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002bf4:	7139                	addi	sp,sp,-64
    80002bf6:	fc06                	sd	ra,56(sp)
    80002bf8:	f822                	sd	s0,48(sp)
    80002bfa:	f426                	sd	s1,40(sp)
    80002bfc:	f04a                	sd	s2,32(sp)
    80002bfe:	ec4e                	sd	s3,24(sp)
    80002c00:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c02:	fcc40593          	addi	a1,s0,-52
    80002c06:	4501                	li	a0,0
    80002c08:	00000097          	auipc	ra,0x0
    80002c0c:	e2a080e7          	jalr	-470(ra) # 80002a32 <argint>
    return -1;
    80002c10:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c12:	06054563          	bltz	a0,80002c7c <sys_sleep+0x88>
  acquire(&tickslock);
    80002c16:	00014517          	auipc	a0,0x14
    80002c1a:	49250513          	addi	a0,a0,1170 # 800170a8 <tickslock>
    80002c1e:	ffffe097          	auipc	ra,0xffffe
    80002c22:	ffa080e7          	jalr	-6(ra) # 80000c18 <acquire>
  ticks0 = ticks;
    80002c26:	00006917          	auipc	s2,0x6
    80002c2a:	3fa92903          	lw	s2,1018(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002c2e:	fcc42783          	lw	a5,-52(s0)
    80002c32:	cf85                	beqz	a5,80002c6a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c34:	00014997          	auipc	s3,0x14
    80002c38:	47498993          	addi	s3,s3,1140 # 800170a8 <tickslock>
    80002c3c:	00006497          	auipc	s1,0x6
    80002c40:	3e448493          	addi	s1,s1,996 # 80009020 <ticks>
    if(myproc()->killed){
    80002c44:	fffff097          	auipc	ra,0xfffff
    80002c48:	d30080e7          	jalr	-720(ra) # 80001974 <myproc>
    80002c4c:	591c                	lw	a5,48(a0)
    80002c4e:	ef9d                	bnez	a5,80002c8c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002c50:	85ce                	mv	a1,s3
    80002c52:	8526                	mv	a0,s1
    80002c54:	fffff097          	auipc	ra,0xfffff
    80002c58:	530080e7          	jalr	1328(ra) # 80002184 <sleep>
  while(ticks - ticks0 < n){
    80002c5c:	409c                	lw	a5,0(s1)
    80002c5e:	412787bb          	subw	a5,a5,s2
    80002c62:	fcc42703          	lw	a4,-52(s0)
    80002c66:	fce7efe3          	bltu	a5,a4,80002c44 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002c6a:	00014517          	auipc	a0,0x14
    80002c6e:	43e50513          	addi	a0,a0,1086 # 800170a8 <tickslock>
    80002c72:	ffffe097          	auipc	ra,0xffffe
    80002c76:	05a080e7          	jalr	90(ra) # 80000ccc <release>
  return 0;
    80002c7a:	4781                	li	a5,0
}
    80002c7c:	853e                	mv	a0,a5
    80002c7e:	70e2                	ld	ra,56(sp)
    80002c80:	7442                	ld	s0,48(sp)
    80002c82:	74a2                	ld	s1,40(sp)
    80002c84:	7902                	ld	s2,32(sp)
    80002c86:	69e2                	ld	s3,24(sp)
    80002c88:	6121                	addi	sp,sp,64
    80002c8a:	8082                	ret
      release(&tickslock);
    80002c8c:	00014517          	auipc	a0,0x14
    80002c90:	41c50513          	addi	a0,a0,1052 # 800170a8 <tickslock>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	038080e7          	jalr	56(ra) # 80000ccc <release>
      return -1;
    80002c9c:	57fd                	li	a5,-1
    80002c9e:	bff9                	j	80002c7c <sys_sleep+0x88>

0000000080002ca0 <sys_kill>:

uint64
sys_kill(void)
{
    80002ca0:	1101                	addi	sp,sp,-32
    80002ca2:	ec06                	sd	ra,24(sp)
    80002ca4:	e822                	sd	s0,16(sp)
    80002ca6:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002ca8:	fec40593          	addi	a1,s0,-20
    80002cac:	4501                	li	a0,0
    80002cae:	00000097          	auipc	ra,0x0
    80002cb2:	d84080e7          	jalr	-636(ra) # 80002a32 <argint>
    80002cb6:	87aa                	mv	a5,a0
    return -1;
    80002cb8:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002cba:	0007c863          	bltz	a5,80002cca <sys_kill+0x2a>
  return kill(pid);
    80002cbe:	fec42503          	lw	a0,-20(s0)
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	6b2080e7          	jalr	1714(ra) # 80002374 <kill>
}
    80002cca:	60e2                	ld	ra,24(sp)
    80002ccc:	6442                	ld	s0,16(sp)
    80002cce:	6105                	addi	sp,sp,32
    80002cd0:	8082                	ret

0000000080002cd2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cd2:	1101                	addi	sp,sp,-32
    80002cd4:	ec06                	sd	ra,24(sp)
    80002cd6:	e822                	sd	s0,16(sp)
    80002cd8:	e426                	sd	s1,8(sp)
    80002cda:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cdc:	00014517          	auipc	a0,0x14
    80002ce0:	3cc50513          	addi	a0,a0,972 # 800170a8 <tickslock>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	f34080e7          	jalr	-204(ra) # 80000c18 <acquire>
  xticks = ticks;
    80002cec:	00006497          	auipc	s1,0x6
    80002cf0:	3344a483          	lw	s1,820(s1) # 80009020 <ticks>
  release(&tickslock);
    80002cf4:	00014517          	auipc	a0,0x14
    80002cf8:	3b450513          	addi	a0,a0,948 # 800170a8 <tickslock>
    80002cfc:	ffffe097          	auipc	ra,0xffffe
    80002d00:	fd0080e7          	jalr	-48(ra) # 80000ccc <release>
  return xticks;
}
    80002d04:	02049513          	slli	a0,s1,0x20
    80002d08:	9101                	srli	a0,a0,0x20
    80002d0a:	60e2                	ld	ra,24(sp)
    80002d0c:	6442                	ld	s0,16(sp)
    80002d0e:	64a2                	ld	s1,8(sp)
    80002d10:	6105                	addi	sp,sp,32
    80002d12:	8082                	ret

0000000080002d14 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d14:	7179                	addi	sp,sp,-48
    80002d16:	f406                	sd	ra,40(sp)
    80002d18:	f022                	sd	s0,32(sp)
    80002d1a:	ec26                	sd	s1,24(sp)
    80002d1c:	e84a                	sd	s2,16(sp)
    80002d1e:	e44e                	sd	s3,8(sp)
    80002d20:	e052                	sd	s4,0(sp)
    80002d22:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d24:	00005597          	auipc	a1,0x5
    80002d28:	7ac58593          	addi	a1,a1,1964 # 800084d0 <syscalls+0xb0>
    80002d2c:	00014517          	auipc	a0,0x14
    80002d30:	39450513          	addi	a0,a0,916 # 800170c0 <bcache>
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	e54080e7          	jalr	-428(ra) # 80000b88 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d3c:	0001c797          	auipc	a5,0x1c
    80002d40:	38478793          	addi	a5,a5,900 # 8001f0c0 <bcache+0x8000>
    80002d44:	0001c717          	auipc	a4,0x1c
    80002d48:	5e470713          	addi	a4,a4,1508 # 8001f328 <bcache+0x8268>
    80002d4c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d50:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d54:	00014497          	auipc	s1,0x14
    80002d58:	38448493          	addi	s1,s1,900 # 800170d8 <bcache+0x18>
    b->next = bcache.head.next;
    80002d5c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d5e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d60:	00005a17          	auipc	s4,0x5
    80002d64:	778a0a13          	addi	s4,s4,1912 # 800084d8 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002d68:	2b893783          	ld	a5,696(s2)
    80002d6c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d6e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d72:	85d2                	mv	a1,s4
    80002d74:	01048513          	addi	a0,s1,16
    80002d78:	00001097          	auipc	ra,0x1
    80002d7c:	4c2080e7          	jalr	1218(ra) # 8000423a <initsleeplock>
    bcache.head.next->prev = b;
    80002d80:	2b893783          	ld	a5,696(s2)
    80002d84:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d86:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d8a:	45848493          	addi	s1,s1,1112
    80002d8e:	fd349de3          	bne	s1,s3,80002d68 <binit+0x54>
  }
}
    80002d92:	70a2                	ld	ra,40(sp)
    80002d94:	7402                	ld	s0,32(sp)
    80002d96:	64e2                	ld	s1,24(sp)
    80002d98:	6942                	ld	s2,16(sp)
    80002d9a:	69a2                	ld	s3,8(sp)
    80002d9c:	6a02                	ld	s4,0(sp)
    80002d9e:	6145                	addi	sp,sp,48
    80002da0:	8082                	ret

0000000080002da2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002da2:	7179                	addi	sp,sp,-48
    80002da4:	f406                	sd	ra,40(sp)
    80002da6:	f022                	sd	s0,32(sp)
    80002da8:	ec26                	sd	s1,24(sp)
    80002daa:	e84a                	sd	s2,16(sp)
    80002dac:	e44e                	sd	s3,8(sp)
    80002dae:	1800                	addi	s0,sp,48
    80002db0:	89aa                	mv	s3,a0
    80002db2:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002db4:	00014517          	auipc	a0,0x14
    80002db8:	30c50513          	addi	a0,a0,780 # 800170c0 <bcache>
    80002dbc:	ffffe097          	auipc	ra,0xffffe
    80002dc0:	e5c080e7          	jalr	-420(ra) # 80000c18 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002dc4:	0001c497          	auipc	s1,0x1c
    80002dc8:	5b44b483          	ld	s1,1460(s1) # 8001f378 <bcache+0x82b8>
    80002dcc:	0001c797          	auipc	a5,0x1c
    80002dd0:	55c78793          	addi	a5,a5,1372 # 8001f328 <bcache+0x8268>
    80002dd4:	02f48f63          	beq	s1,a5,80002e12 <bread+0x70>
    80002dd8:	873e                	mv	a4,a5
    80002dda:	a021                	j	80002de2 <bread+0x40>
    80002ddc:	68a4                	ld	s1,80(s1)
    80002dde:	02e48a63          	beq	s1,a4,80002e12 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002de2:	449c                	lw	a5,8(s1)
    80002de4:	ff379ce3          	bne	a5,s3,80002ddc <bread+0x3a>
    80002de8:	44dc                	lw	a5,12(s1)
    80002dea:	ff2799e3          	bne	a5,s2,80002ddc <bread+0x3a>
      b->refcnt++;
    80002dee:	40bc                	lw	a5,64(s1)
    80002df0:	2785                	addiw	a5,a5,1
    80002df2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002df4:	00014517          	auipc	a0,0x14
    80002df8:	2cc50513          	addi	a0,a0,716 # 800170c0 <bcache>
    80002dfc:	ffffe097          	auipc	ra,0xffffe
    80002e00:	ed0080e7          	jalr	-304(ra) # 80000ccc <release>
      acquiresleep(&b->lock);
    80002e04:	01048513          	addi	a0,s1,16
    80002e08:	00001097          	auipc	ra,0x1
    80002e0c:	46c080e7          	jalr	1132(ra) # 80004274 <acquiresleep>
      return b;
    80002e10:	a8b9                	j	80002e6e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e12:	0001c497          	auipc	s1,0x1c
    80002e16:	55e4b483          	ld	s1,1374(s1) # 8001f370 <bcache+0x82b0>
    80002e1a:	0001c797          	auipc	a5,0x1c
    80002e1e:	50e78793          	addi	a5,a5,1294 # 8001f328 <bcache+0x8268>
    80002e22:	00f48863          	beq	s1,a5,80002e32 <bread+0x90>
    80002e26:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e28:	40bc                	lw	a5,64(s1)
    80002e2a:	cf81                	beqz	a5,80002e42 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e2c:	64a4                	ld	s1,72(s1)
    80002e2e:	fee49de3          	bne	s1,a4,80002e28 <bread+0x86>
  panic("bget: no buffers");
    80002e32:	00005517          	auipc	a0,0x5
    80002e36:	6ae50513          	addi	a0,a0,1710 # 800084e0 <syscalls+0xc0>
    80002e3a:	ffffd097          	auipc	ra,0xffffd
    80002e3e:	716080e7          	jalr	1814(ra) # 80000550 <panic>
      b->dev = dev;
    80002e42:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002e46:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002e4a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e4e:	4785                	li	a5,1
    80002e50:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e52:	00014517          	auipc	a0,0x14
    80002e56:	26e50513          	addi	a0,a0,622 # 800170c0 <bcache>
    80002e5a:	ffffe097          	auipc	ra,0xffffe
    80002e5e:	e72080e7          	jalr	-398(ra) # 80000ccc <release>
      acquiresleep(&b->lock);
    80002e62:	01048513          	addi	a0,s1,16
    80002e66:	00001097          	auipc	ra,0x1
    80002e6a:	40e080e7          	jalr	1038(ra) # 80004274 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e6e:	409c                	lw	a5,0(s1)
    80002e70:	cb89                	beqz	a5,80002e82 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e72:	8526                	mv	a0,s1
    80002e74:	70a2                	ld	ra,40(sp)
    80002e76:	7402                	ld	s0,32(sp)
    80002e78:	64e2                	ld	s1,24(sp)
    80002e7a:	6942                	ld	s2,16(sp)
    80002e7c:	69a2                	ld	s3,8(sp)
    80002e7e:	6145                	addi	sp,sp,48
    80002e80:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e82:	4581                	li	a1,0
    80002e84:	8526                	mv	a0,s1
    80002e86:	00003097          	auipc	ra,0x3
    80002e8a:	f60080e7          	jalr	-160(ra) # 80005de6 <virtio_disk_rw>
    b->valid = 1;
    80002e8e:	4785                	li	a5,1
    80002e90:	c09c                	sw	a5,0(s1)
  return b;
    80002e92:	b7c5                	j	80002e72 <bread+0xd0>

0000000080002e94 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e94:	1101                	addi	sp,sp,-32
    80002e96:	ec06                	sd	ra,24(sp)
    80002e98:	e822                	sd	s0,16(sp)
    80002e9a:	e426                	sd	s1,8(sp)
    80002e9c:	1000                	addi	s0,sp,32
    80002e9e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ea0:	0541                	addi	a0,a0,16
    80002ea2:	00001097          	auipc	ra,0x1
    80002ea6:	46c080e7          	jalr	1132(ra) # 8000430e <holdingsleep>
    80002eaa:	cd01                	beqz	a0,80002ec2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002eac:	4585                	li	a1,1
    80002eae:	8526                	mv	a0,s1
    80002eb0:	00003097          	auipc	ra,0x3
    80002eb4:	f36080e7          	jalr	-202(ra) # 80005de6 <virtio_disk_rw>
}
    80002eb8:	60e2                	ld	ra,24(sp)
    80002eba:	6442                	ld	s0,16(sp)
    80002ebc:	64a2                	ld	s1,8(sp)
    80002ebe:	6105                	addi	sp,sp,32
    80002ec0:	8082                	ret
    panic("bwrite");
    80002ec2:	00005517          	auipc	a0,0x5
    80002ec6:	63650513          	addi	a0,a0,1590 # 800084f8 <syscalls+0xd8>
    80002eca:	ffffd097          	auipc	ra,0xffffd
    80002ece:	686080e7          	jalr	1670(ra) # 80000550 <panic>

0000000080002ed2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ed2:	1101                	addi	sp,sp,-32
    80002ed4:	ec06                	sd	ra,24(sp)
    80002ed6:	e822                	sd	s0,16(sp)
    80002ed8:	e426                	sd	s1,8(sp)
    80002eda:	e04a                	sd	s2,0(sp)
    80002edc:	1000                	addi	s0,sp,32
    80002ede:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ee0:	01050913          	addi	s2,a0,16
    80002ee4:	854a                	mv	a0,s2
    80002ee6:	00001097          	auipc	ra,0x1
    80002eea:	428080e7          	jalr	1064(ra) # 8000430e <holdingsleep>
    80002eee:	c92d                	beqz	a0,80002f60 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002ef0:	854a                	mv	a0,s2
    80002ef2:	00001097          	auipc	ra,0x1
    80002ef6:	3d8080e7          	jalr	984(ra) # 800042ca <releasesleep>

  acquire(&bcache.lock);
    80002efa:	00014517          	auipc	a0,0x14
    80002efe:	1c650513          	addi	a0,a0,454 # 800170c0 <bcache>
    80002f02:	ffffe097          	auipc	ra,0xffffe
    80002f06:	d16080e7          	jalr	-746(ra) # 80000c18 <acquire>
  b->refcnt--;
    80002f0a:	40bc                	lw	a5,64(s1)
    80002f0c:	37fd                	addiw	a5,a5,-1
    80002f0e:	0007871b          	sext.w	a4,a5
    80002f12:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f14:	eb05                	bnez	a4,80002f44 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f16:	68bc                	ld	a5,80(s1)
    80002f18:	64b8                	ld	a4,72(s1)
    80002f1a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002f1c:	64bc                	ld	a5,72(s1)
    80002f1e:	68b8                	ld	a4,80(s1)
    80002f20:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f22:	0001c797          	auipc	a5,0x1c
    80002f26:	19e78793          	addi	a5,a5,414 # 8001f0c0 <bcache+0x8000>
    80002f2a:	2b87b703          	ld	a4,696(a5)
    80002f2e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f30:	0001c717          	auipc	a4,0x1c
    80002f34:	3f870713          	addi	a4,a4,1016 # 8001f328 <bcache+0x8268>
    80002f38:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f3a:	2b87b703          	ld	a4,696(a5)
    80002f3e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f40:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f44:	00014517          	auipc	a0,0x14
    80002f48:	17c50513          	addi	a0,a0,380 # 800170c0 <bcache>
    80002f4c:	ffffe097          	auipc	ra,0xffffe
    80002f50:	d80080e7          	jalr	-640(ra) # 80000ccc <release>
}
    80002f54:	60e2                	ld	ra,24(sp)
    80002f56:	6442                	ld	s0,16(sp)
    80002f58:	64a2                	ld	s1,8(sp)
    80002f5a:	6902                	ld	s2,0(sp)
    80002f5c:	6105                	addi	sp,sp,32
    80002f5e:	8082                	ret
    panic("brelse");
    80002f60:	00005517          	auipc	a0,0x5
    80002f64:	5a050513          	addi	a0,a0,1440 # 80008500 <syscalls+0xe0>
    80002f68:	ffffd097          	auipc	ra,0xffffd
    80002f6c:	5e8080e7          	jalr	1512(ra) # 80000550 <panic>

0000000080002f70 <bpin>:

void
bpin(struct buf *b) {
    80002f70:	1101                	addi	sp,sp,-32
    80002f72:	ec06                	sd	ra,24(sp)
    80002f74:	e822                	sd	s0,16(sp)
    80002f76:	e426                	sd	s1,8(sp)
    80002f78:	1000                	addi	s0,sp,32
    80002f7a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f7c:	00014517          	auipc	a0,0x14
    80002f80:	14450513          	addi	a0,a0,324 # 800170c0 <bcache>
    80002f84:	ffffe097          	auipc	ra,0xffffe
    80002f88:	c94080e7          	jalr	-876(ra) # 80000c18 <acquire>
  b->refcnt++;
    80002f8c:	40bc                	lw	a5,64(s1)
    80002f8e:	2785                	addiw	a5,a5,1
    80002f90:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f92:	00014517          	auipc	a0,0x14
    80002f96:	12e50513          	addi	a0,a0,302 # 800170c0 <bcache>
    80002f9a:	ffffe097          	auipc	ra,0xffffe
    80002f9e:	d32080e7          	jalr	-718(ra) # 80000ccc <release>
}
    80002fa2:	60e2                	ld	ra,24(sp)
    80002fa4:	6442                	ld	s0,16(sp)
    80002fa6:	64a2                	ld	s1,8(sp)
    80002fa8:	6105                	addi	sp,sp,32
    80002faa:	8082                	ret

0000000080002fac <bunpin>:

void
bunpin(struct buf *b) {
    80002fac:	1101                	addi	sp,sp,-32
    80002fae:	ec06                	sd	ra,24(sp)
    80002fb0:	e822                	sd	s0,16(sp)
    80002fb2:	e426                	sd	s1,8(sp)
    80002fb4:	1000                	addi	s0,sp,32
    80002fb6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fb8:	00014517          	auipc	a0,0x14
    80002fbc:	10850513          	addi	a0,a0,264 # 800170c0 <bcache>
    80002fc0:	ffffe097          	auipc	ra,0xffffe
    80002fc4:	c58080e7          	jalr	-936(ra) # 80000c18 <acquire>
  b->refcnt--;
    80002fc8:	40bc                	lw	a5,64(s1)
    80002fca:	37fd                	addiw	a5,a5,-1
    80002fcc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fce:	00014517          	auipc	a0,0x14
    80002fd2:	0f250513          	addi	a0,a0,242 # 800170c0 <bcache>
    80002fd6:	ffffe097          	auipc	ra,0xffffe
    80002fda:	cf6080e7          	jalr	-778(ra) # 80000ccc <release>
}
    80002fde:	60e2                	ld	ra,24(sp)
    80002fe0:	6442                	ld	s0,16(sp)
    80002fe2:	64a2                	ld	s1,8(sp)
    80002fe4:	6105                	addi	sp,sp,32
    80002fe6:	8082                	ret

0000000080002fe8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	e426                	sd	s1,8(sp)
    80002ff0:	e04a                	sd	s2,0(sp)
    80002ff2:	1000                	addi	s0,sp,32
    80002ff4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ff6:	00d5d59b          	srliw	a1,a1,0xd
    80002ffa:	0001c797          	auipc	a5,0x1c
    80002ffe:	7a27a783          	lw	a5,1954(a5) # 8001f79c <sb+0x1c>
    80003002:	9dbd                	addw	a1,a1,a5
    80003004:	00000097          	auipc	ra,0x0
    80003008:	d9e080e7          	jalr	-610(ra) # 80002da2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000300c:	0074f713          	andi	a4,s1,7
    80003010:	4785                	li	a5,1
    80003012:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003016:	14ce                	slli	s1,s1,0x33
    80003018:	90d9                	srli	s1,s1,0x36
    8000301a:	00950733          	add	a4,a0,s1
    8000301e:	05874703          	lbu	a4,88(a4)
    80003022:	00e7f6b3          	and	a3,a5,a4
    80003026:	c69d                	beqz	a3,80003054 <bfree+0x6c>
    80003028:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000302a:	94aa                	add	s1,s1,a0
    8000302c:	fff7c793          	not	a5,a5
    80003030:	8ff9                	and	a5,a5,a4
    80003032:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003036:	00001097          	auipc	ra,0x1
    8000303a:	116080e7          	jalr	278(ra) # 8000414c <log_write>
  brelse(bp);
    8000303e:	854a                	mv	a0,s2
    80003040:	00000097          	auipc	ra,0x0
    80003044:	e92080e7          	jalr	-366(ra) # 80002ed2 <brelse>
}
    80003048:	60e2                	ld	ra,24(sp)
    8000304a:	6442                	ld	s0,16(sp)
    8000304c:	64a2                	ld	s1,8(sp)
    8000304e:	6902                	ld	s2,0(sp)
    80003050:	6105                	addi	sp,sp,32
    80003052:	8082                	ret
    panic("freeing free block");
    80003054:	00005517          	auipc	a0,0x5
    80003058:	4b450513          	addi	a0,a0,1204 # 80008508 <syscalls+0xe8>
    8000305c:	ffffd097          	auipc	ra,0xffffd
    80003060:	4f4080e7          	jalr	1268(ra) # 80000550 <panic>

0000000080003064 <balloc>:
{
    80003064:	711d                	addi	sp,sp,-96
    80003066:	ec86                	sd	ra,88(sp)
    80003068:	e8a2                	sd	s0,80(sp)
    8000306a:	e4a6                	sd	s1,72(sp)
    8000306c:	e0ca                	sd	s2,64(sp)
    8000306e:	fc4e                	sd	s3,56(sp)
    80003070:	f852                	sd	s4,48(sp)
    80003072:	f456                	sd	s5,40(sp)
    80003074:	f05a                	sd	s6,32(sp)
    80003076:	ec5e                	sd	s7,24(sp)
    80003078:	e862                	sd	s8,16(sp)
    8000307a:	e466                	sd	s9,8(sp)
    8000307c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000307e:	0001c797          	auipc	a5,0x1c
    80003082:	7067a783          	lw	a5,1798(a5) # 8001f784 <sb+0x4>
    80003086:	cbd1                	beqz	a5,8000311a <balloc+0xb6>
    80003088:	8baa                	mv	s7,a0
    8000308a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000308c:	0001cb17          	auipc	s6,0x1c
    80003090:	6f4b0b13          	addi	s6,s6,1780 # 8001f780 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003094:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003096:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003098:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000309a:	6c89                	lui	s9,0x2
    8000309c:	a831                	j	800030b8 <balloc+0x54>
    brelse(bp);
    8000309e:	854a                	mv	a0,s2
    800030a0:	00000097          	auipc	ra,0x0
    800030a4:	e32080e7          	jalr	-462(ra) # 80002ed2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800030a8:	015c87bb          	addw	a5,s9,s5
    800030ac:	00078a9b          	sext.w	s5,a5
    800030b0:	004b2703          	lw	a4,4(s6)
    800030b4:	06eaf363          	bgeu	s5,a4,8000311a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800030b8:	41fad79b          	sraiw	a5,s5,0x1f
    800030bc:	0137d79b          	srliw	a5,a5,0x13
    800030c0:	015787bb          	addw	a5,a5,s5
    800030c4:	40d7d79b          	sraiw	a5,a5,0xd
    800030c8:	01cb2583          	lw	a1,28(s6)
    800030cc:	9dbd                	addw	a1,a1,a5
    800030ce:	855e                	mv	a0,s7
    800030d0:	00000097          	auipc	ra,0x0
    800030d4:	cd2080e7          	jalr	-814(ra) # 80002da2 <bread>
    800030d8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030da:	004b2503          	lw	a0,4(s6)
    800030de:	000a849b          	sext.w	s1,s5
    800030e2:	8662                	mv	a2,s8
    800030e4:	faa4fde3          	bgeu	s1,a0,8000309e <balloc+0x3a>
      m = 1 << (bi % 8);
    800030e8:	41f6579b          	sraiw	a5,a2,0x1f
    800030ec:	01d7d69b          	srliw	a3,a5,0x1d
    800030f0:	00c6873b          	addw	a4,a3,a2
    800030f4:	00777793          	andi	a5,a4,7
    800030f8:	9f95                	subw	a5,a5,a3
    800030fa:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800030fe:	4037571b          	sraiw	a4,a4,0x3
    80003102:	00e906b3          	add	a3,s2,a4
    80003106:	0586c683          	lbu	a3,88(a3)
    8000310a:	00d7f5b3          	and	a1,a5,a3
    8000310e:	cd91                	beqz	a1,8000312a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003110:	2605                	addiw	a2,a2,1
    80003112:	2485                	addiw	s1,s1,1
    80003114:	fd4618e3          	bne	a2,s4,800030e4 <balloc+0x80>
    80003118:	b759                	j	8000309e <balloc+0x3a>
  panic("balloc: out of blocks");
    8000311a:	00005517          	auipc	a0,0x5
    8000311e:	40650513          	addi	a0,a0,1030 # 80008520 <syscalls+0x100>
    80003122:	ffffd097          	auipc	ra,0xffffd
    80003126:	42e080e7          	jalr	1070(ra) # 80000550 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000312a:	974a                	add	a4,a4,s2
    8000312c:	8fd5                	or	a5,a5,a3
    8000312e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003132:	854a                	mv	a0,s2
    80003134:	00001097          	auipc	ra,0x1
    80003138:	018080e7          	jalr	24(ra) # 8000414c <log_write>
        brelse(bp);
    8000313c:	854a                	mv	a0,s2
    8000313e:	00000097          	auipc	ra,0x0
    80003142:	d94080e7          	jalr	-620(ra) # 80002ed2 <brelse>
  bp = bread(dev, bno);
    80003146:	85a6                	mv	a1,s1
    80003148:	855e                	mv	a0,s7
    8000314a:	00000097          	auipc	ra,0x0
    8000314e:	c58080e7          	jalr	-936(ra) # 80002da2 <bread>
    80003152:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003154:	40000613          	li	a2,1024
    80003158:	4581                	li	a1,0
    8000315a:	05850513          	addi	a0,a0,88
    8000315e:	ffffe097          	auipc	ra,0xffffe
    80003162:	bb6080e7          	jalr	-1098(ra) # 80000d14 <memset>
  log_write(bp);
    80003166:	854a                	mv	a0,s2
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	fe4080e7          	jalr	-28(ra) # 8000414c <log_write>
  brelse(bp);
    80003170:	854a                	mv	a0,s2
    80003172:	00000097          	auipc	ra,0x0
    80003176:	d60080e7          	jalr	-672(ra) # 80002ed2 <brelse>
}
    8000317a:	8526                	mv	a0,s1
    8000317c:	60e6                	ld	ra,88(sp)
    8000317e:	6446                	ld	s0,80(sp)
    80003180:	64a6                	ld	s1,72(sp)
    80003182:	6906                	ld	s2,64(sp)
    80003184:	79e2                	ld	s3,56(sp)
    80003186:	7a42                	ld	s4,48(sp)
    80003188:	7aa2                	ld	s5,40(sp)
    8000318a:	7b02                	ld	s6,32(sp)
    8000318c:	6be2                	ld	s7,24(sp)
    8000318e:	6c42                	ld	s8,16(sp)
    80003190:	6ca2                	ld	s9,8(sp)
    80003192:	6125                	addi	sp,sp,96
    80003194:	8082                	ret

0000000080003196 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003196:	7179                	addi	sp,sp,-48
    80003198:	f406                	sd	ra,40(sp)
    8000319a:	f022                	sd	s0,32(sp)
    8000319c:	ec26                	sd	s1,24(sp)
    8000319e:	e84a                	sd	s2,16(sp)
    800031a0:	e44e                	sd	s3,8(sp)
    800031a2:	e052                	sd	s4,0(sp)
    800031a4:	1800                	addi	s0,sp,48
    800031a6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800031a8:	47ad                	li	a5,11
    800031aa:	04b7fe63          	bgeu	a5,a1,80003206 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800031ae:	ff45849b          	addiw	s1,a1,-12
    800031b2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800031b6:	0ff00793          	li	a5,255
    800031ba:	0ae7e363          	bltu	a5,a4,80003260 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800031be:	08052583          	lw	a1,128(a0)
    800031c2:	c5ad                	beqz	a1,8000322c <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800031c4:	00092503          	lw	a0,0(s2)
    800031c8:	00000097          	auipc	ra,0x0
    800031cc:	bda080e7          	jalr	-1062(ra) # 80002da2 <bread>
    800031d0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800031d2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800031d6:	02049593          	slli	a1,s1,0x20
    800031da:	9181                	srli	a1,a1,0x20
    800031dc:	058a                	slli	a1,a1,0x2
    800031de:	00b784b3          	add	s1,a5,a1
    800031e2:	0004a983          	lw	s3,0(s1)
    800031e6:	04098d63          	beqz	s3,80003240 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800031ea:	8552                	mv	a0,s4
    800031ec:	00000097          	auipc	ra,0x0
    800031f0:	ce6080e7          	jalr	-794(ra) # 80002ed2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800031f4:	854e                	mv	a0,s3
    800031f6:	70a2                	ld	ra,40(sp)
    800031f8:	7402                	ld	s0,32(sp)
    800031fa:	64e2                	ld	s1,24(sp)
    800031fc:	6942                	ld	s2,16(sp)
    800031fe:	69a2                	ld	s3,8(sp)
    80003200:	6a02                	ld	s4,0(sp)
    80003202:	6145                	addi	sp,sp,48
    80003204:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003206:	02059493          	slli	s1,a1,0x20
    8000320a:	9081                	srli	s1,s1,0x20
    8000320c:	048a                	slli	s1,s1,0x2
    8000320e:	94aa                	add	s1,s1,a0
    80003210:	0504a983          	lw	s3,80(s1)
    80003214:	fe0990e3          	bnez	s3,800031f4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003218:	4108                	lw	a0,0(a0)
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	e4a080e7          	jalr	-438(ra) # 80003064 <balloc>
    80003222:	0005099b          	sext.w	s3,a0
    80003226:	0534a823          	sw	s3,80(s1)
    8000322a:	b7e9                	j	800031f4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000322c:	4108                	lw	a0,0(a0)
    8000322e:	00000097          	auipc	ra,0x0
    80003232:	e36080e7          	jalr	-458(ra) # 80003064 <balloc>
    80003236:	0005059b          	sext.w	a1,a0
    8000323a:	08b92023          	sw	a1,128(s2)
    8000323e:	b759                	j	800031c4 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003240:	00092503          	lw	a0,0(s2)
    80003244:	00000097          	auipc	ra,0x0
    80003248:	e20080e7          	jalr	-480(ra) # 80003064 <balloc>
    8000324c:	0005099b          	sext.w	s3,a0
    80003250:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003254:	8552                	mv	a0,s4
    80003256:	00001097          	auipc	ra,0x1
    8000325a:	ef6080e7          	jalr	-266(ra) # 8000414c <log_write>
    8000325e:	b771                	j	800031ea <bmap+0x54>
  panic("bmap: out of range");
    80003260:	00005517          	auipc	a0,0x5
    80003264:	2d850513          	addi	a0,a0,728 # 80008538 <syscalls+0x118>
    80003268:	ffffd097          	auipc	ra,0xffffd
    8000326c:	2e8080e7          	jalr	744(ra) # 80000550 <panic>

0000000080003270 <iget>:
{
    80003270:	7179                	addi	sp,sp,-48
    80003272:	f406                	sd	ra,40(sp)
    80003274:	f022                	sd	s0,32(sp)
    80003276:	ec26                	sd	s1,24(sp)
    80003278:	e84a                	sd	s2,16(sp)
    8000327a:	e44e                	sd	s3,8(sp)
    8000327c:	e052                	sd	s4,0(sp)
    8000327e:	1800                	addi	s0,sp,48
    80003280:	89aa                	mv	s3,a0
    80003282:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003284:	0001c517          	auipc	a0,0x1c
    80003288:	51c50513          	addi	a0,a0,1308 # 8001f7a0 <icache>
    8000328c:	ffffe097          	auipc	ra,0xffffe
    80003290:	98c080e7          	jalr	-1652(ra) # 80000c18 <acquire>
  empty = 0;
    80003294:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003296:	0001c497          	auipc	s1,0x1c
    8000329a:	52248493          	addi	s1,s1,1314 # 8001f7b8 <icache+0x18>
    8000329e:	0001e697          	auipc	a3,0x1e
    800032a2:	faa68693          	addi	a3,a3,-86 # 80021248 <log>
    800032a6:	a039                	j	800032b4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032a8:	02090b63          	beqz	s2,800032de <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800032ac:	08848493          	addi	s1,s1,136
    800032b0:	02d48a63          	beq	s1,a3,800032e4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800032b4:	449c                	lw	a5,8(s1)
    800032b6:	fef059e3          	blez	a5,800032a8 <iget+0x38>
    800032ba:	4098                	lw	a4,0(s1)
    800032bc:	ff3716e3          	bne	a4,s3,800032a8 <iget+0x38>
    800032c0:	40d8                	lw	a4,4(s1)
    800032c2:	ff4713e3          	bne	a4,s4,800032a8 <iget+0x38>
      ip->ref++;
    800032c6:	2785                	addiw	a5,a5,1
    800032c8:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800032ca:	0001c517          	auipc	a0,0x1c
    800032ce:	4d650513          	addi	a0,a0,1238 # 8001f7a0 <icache>
    800032d2:	ffffe097          	auipc	ra,0xffffe
    800032d6:	9fa080e7          	jalr	-1542(ra) # 80000ccc <release>
      return ip;
    800032da:	8926                	mv	s2,s1
    800032dc:	a03d                	j	8000330a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032de:	f7f9                	bnez	a5,800032ac <iget+0x3c>
    800032e0:	8926                	mv	s2,s1
    800032e2:	b7e9                	j	800032ac <iget+0x3c>
  if(empty == 0)
    800032e4:	02090c63          	beqz	s2,8000331c <iget+0xac>
  ip->dev = dev;
    800032e8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800032ec:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800032f0:	4785                	li	a5,1
    800032f2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800032f6:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800032fa:	0001c517          	auipc	a0,0x1c
    800032fe:	4a650513          	addi	a0,a0,1190 # 8001f7a0 <icache>
    80003302:	ffffe097          	auipc	ra,0xffffe
    80003306:	9ca080e7          	jalr	-1590(ra) # 80000ccc <release>
}
    8000330a:	854a                	mv	a0,s2
    8000330c:	70a2                	ld	ra,40(sp)
    8000330e:	7402                	ld	s0,32(sp)
    80003310:	64e2                	ld	s1,24(sp)
    80003312:	6942                	ld	s2,16(sp)
    80003314:	69a2                	ld	s3,8(sp)
    80003316:	6a02                	ld	s4,0(sp)
    80003318:	6145                	addi	sp,sp,48
    8000331a:	8082                	ret
    panic("iget: no inodes");
    8000331c:	00005517          	auipc	a0,0x5
    80003320:	23450513          	addi	a0,a0,564 # 80008550 <syscalls+0x130>
    80003324:	ffffd097          	auipc	ra,0xffffd
    80003328:	22c080e7          	jalr	556(ra) # 80000550 <panic>

000000008000332c <fsinit>:
fsinit(int dev) {
    8000332c:	7179                	addi	sp,sp,-48
    8000332e:	f406                	sd	ra,40(sp)
    80003330:	f022                	sd	s0,32(sp)
    80003332:	ec26                	sd	s1,24(sp)
    80003334:	e84a                	sd	s2,16(sp)
    80003336:	e44e                	sd	s3,8(sp)
    80003338:	1800                	addi	s0,sp,48
    8000333a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000333c:	4585                	li	a1,1
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	a64080e7          	jalr	-1436(ra) # 80002da2 <bread>
    80003346:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003348:	0001c997          	auipc	s3,0x1c
    8000334c:	43898993          	addi	s3,s3,1080 # 8001f780 <sb>
    80003350:	02000613          	li	a2,32
    80003354:	05850593          	addi	a1,a0,88
    80003358:	854e                	mv	a0,s3
    8000335a:	ffffe097          	auipc	ra,0xffffe
    8000335e:	a1a080e7          	jalr	-1510(ra) # 80000d74 <memmove>
  brelse(bp);
    80003362:	8526                	mv	a0,s1
    80003364:	00000097          	auipc	ra,0x0
    80003368:	b6e080e7          	jalr	-1170(ra) # 80002ed2 <brelse>
  if(sb.magic != FSMAGIC)
    8000336c:	0009a703          	lw	a4,0(s3)
    80003370:	102037b7          	lui	a5,0x10203
    80003374:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003378:	02f71263          	bne	a4,a5,8000339c <fsinit+0x70>
  initlog(dev, &sb);
    8000337c:	0001c597          	auipc	a1,0x1c
    80003380:	40458593          	addi	a1,a1,1028 # 8001f780 <sb>
    80003384:	854a                	mv	a0,s2
    80003386:	00001097          	auipc	ra,0x1
    8000338a:	b4a080e7          	jalr	-1206(ra) # 80003ed0 <initlog>
}
    8000338e:	70a2                	ld	ra,40(sp)
    80003390:	7402                	ld	s0,32(sp)
    80003392:	64e2                	ld	s1,24(sp)
    80003394:	6942                	ld	s2,16(sp)
    80003396:	69a2                	ld	s3,8(sp)
    80003398:	6145                	addi	sp,sp,48
    8000339a:	8082                	ret
    panic("invalid file system");
    8000339c:	00005517          	auipc	a0,0x5
    800033a0:	1c450513          	addi	a0,a0,452 # 80008560 <syscalls+0x140>
    800033a4:	ffffd097          	auipc	ra,0xffffd
    800033a8:	1ac080e7          	jalr	428(ra) # 80000550 <panic>

00000000800033ac <iinit>:
{
    800033ac:	7179                	addi	sp,sp,-48
    800033ae:	f406                	sd	ra,40(sp)
    800033b0:	f022                	sd	s0,32(sp)
    800033b2:	ec26                	sd	s1,24(sp)
    800033b4:	e84a                	sd	s2,16(sp)
    800033b6:	e44e                	sd	s3,8(sp)
    800033b8:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800033ba:	00005597          	auipc	a1,0x5
    800033be:	1be58593          	addi	a1,a1,446 # 80008578 <syscalls+0x158>
    800033c2:	0001c517          	auipc	a0,0x1c
    800033c6:	3de50513          	addi	a0,a0,990 # 8001f7a0 <icache>
    800033ca:	ffffd097          	auipc	ra,0xffffd
    800033ce:	7be080e7          	jalr	1982(ra) # 80000b88 <initlock>
  for(i = 0; i < NINODE; i++) {
    800033d2:	0001c497          	auipc	s1,0x1c
    800033d6:	3f648493          	addi	s1,s1,1014 # 8001f7c8 <icache+0x28>
    800033da:	0001e997          	auipc	s3,0x1e
    800033de:	e7e98993          	addi	s3,s3,-386 # 80021258 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800033e2:	00005917          	auipc	s2,0x5
    800033e6:	19e90913          	addi	s2,s2,414 # 80008580 <syscalls+0x160>
    800033ea:	85ca                	mv	a1,s2
    800033ec:	8526                	mv	a0,s1
    800033ee:	00001097          	auipc	ra,0x1
    800033f2:	e4c080e7          	jalr	-436(ra) # 8000423a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800033f6:	08848493          	addi	s1,s1,136
    800033fa:	ff3498e3          	bne	s1,s3,800033ea <iinit+0x3e>
}
    800033fe:	70a2                	ld	ra,40(sp)
    80003400:	7402                	ld	s0,32(sp)
    80003402:	64e2                	ld	s1,24(sp)
    80003404:	6942                	ld	s2,16(sp)
    80003406:	69a2                	ld	s3,8(sp)
    80003408:	6145                	addi	sp,sp,48
    8000340a:	8082                	ret

000000008000340c <ialloc>:
{
    8000340c:	715d                	addi	sp,sp,-80
    8000340e:	e486                	sd	ra,72(sp)
    80003410:	e0a2                	sd	s0,64(sp)
    80003412:	fc26                	sd	s1,56(sp)
    80003414:	f84a                	sd	s2,48(sp)
    80003416:	f44e                	sd	s3,40(sp)
    80003418:	f052                	sd	s4,32(sp)
    8000341a:	ec56                	sd	s5,24(sp)
    8000341c:	e85a                	sd	s6,16(sp)
    8000341e:	e45e                	sd	s7,8(sp)
    80003420:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003422:	0001c717          	auipc	a4,0x1c
    80003426:	36a72703          	lw	a4,874(a4) # 8001f78c <sb+0xc>
    8000342a:	4785                	li	a5,1
    8000342c:	04e7fa63          	bgeu	a5,a4,80003480 <ialloc+0x74>
    80003430:	8aaa                	mv	s5,a0
    80003432:	8bae                	mv	s7,a1
    80003434:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003436:	0001ca17          	auipc	s4,0x1c
    8000343a:	34aa0a13          	addi	s4,s4,842 # 8001f780 <sb>
    8000343e:	00048b1b          	sext.w	s6,s1
    80003442:	0044d593          	srli	a1,s1,0x4
    80003446:	018a2783          	lw	a5,24(s4)
    8000344a:	9dbd                	addw	a1,a1,a5
    8000344c:	8556                	mv	a0,s5
    8000344e:	00000097          	auipc	ra,0x0
    80003452:	954080e7          	jalr	-1708(ra) # 80002da2 <bread>
    80003456:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003458:	05850993          	addi	s3,a0,88
    8000345c:	00f4f793          	andi	a5,s1,15
    80003460:	079a                	slli	a5,a5,0x6
    80003462:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003464:	00099783          	lh	a5,0(s3)
    80003468:	c785                	beqz	a5,80003490 <ialloc+0x84>
    brelse(bp);
    8000346a:	00000097          	auipc	ra,0x0
    8000346e:	a68080e7          	jalr	-1432(ra) # 80002ed2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003472:	0485                	addi	s1,s1,1
    80003474:	00ca2703          	lw	a4,12(s4)
    80003478:	0004879b          	sext.w	a5,s1
    8000347c:	fce7e1e3          	bltu	a5,a4,8000343e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003480:	00005517          	auipc	a0,0x5
    80003484:	10850513          	addi	a0,a0,264 # 80008588 <syscalls+0x168>
    80003488:	ffffd097          	auipc	ra,0xffffd
    8000348c:	0c8080e7          	jalr	200(ra) # 80000550 <panic>
      memset(dip, 0, sizeof(*dip));
    80003490:	04000613          	li	a2,64
    80003494:	4581                	li	a1,0
    80003496:	854e                	mv	a0,s3
    80003498:	ffffe097          	auipc	ra,0xffffe
    8000349c:	87c080e7          	jalr	-1924(ra) # 80000d14 <memset>
      dip->type = type;
    800034a0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800034a4:	854a                	mv	a0,s2
    800034a6:	00001097          	auipc	ra,0x1
    800034aa:	ca6080e7          	jalr	-858(ra) # 8000414c <log_write>
      brelse(bp);
    800034ae:	854a                	mv	a0,s2
    800034b0:	00000097          	auipc	ra,0x0
    800034b4:	a22080e7          	jalr	-1502(ra) # 80002ed2 <brelse>
      return iget(dev, inum);
    800034b8:	85da                	mv	a1,s6
    800034ba:	8556                	mv	a0,s5
    800034bc:	00000097          	auipc	ra,0x0
    800034c0:	db4080e7          	jalr	-588(ra) # 80003270 <iget>
}
    800034c4:	60a6                	ld	ra,72(sp)
    800034c6:	6406                	ld	s0,64(sp)
    800034c8:	74e2                	ld	s1,56(sp)
    800034ca:	7942                	ld	s2,48(sp)
    800034cc:	79a2                	ld	s3,40(sp)
    800034ce:	7a02                	ld	s4,32(sp)
    800034d0:	6ae2                	ld	s5,24(sp)
    800034d2:	6b42                	ld	s6,16(sp)
    800034d4:	6ba2                	ld	s7,8(sp)
    800034d6:	6161                	addi	sp,sp,80
    800034d8:	8082                	ret

00000000800034da <iupdate>:
{
    800034da:	1101                	addi	sp,sp,-32
    800034dc:	ec06                	sd	ra,24(sp)
    800034de:	e822                	sd	s0,16(sp)
    800034e0:	e426                	sd	s1,8(sp)
    800034e2:	e04a                	sd	s2,0(sp)
    800034e4:	1000                	addi	s0,sp,32
    800034e6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034e8:	415c                	lw	a5,4(a0)
    800034ea:	0047d79b          	srliw	a5,a5,0x4
    800034ee:	0001c597          	auipc	a1,0x1c
    800034f2:	2aa5a583          	lw	a1,682(a1) # 8001f798 <sb+0x18>
    800034f6:	9dbd                	addw	a1,a1,a5
    800034f8:	4108                	lw	a0,0(a0)
    800034fa:	00000097          	auipc	ra,0x0
    800034fe:	8a8080e7          	jalr	-1880(ra) # 80002da2 <bread>
    80003502:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003504:	05850793          	addi	a5,a0,88
    80003508:	40c8                	lw	a0,4(s1)
    8000350a:	893d                	andi	a0,a0,15
    8000350c:	051a                	slli	a0,a0,0x6
    8000350e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003510:	04449703          	lh	a4,68(s1)
    80003514:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003518:	04649703          	lh	a4,70(s1)
    8000351c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003520:	04849703          	lh	a4,72(s1)
    80003524:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003528:	04a49703          	lh	a4,74(s1)
    8000352c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003530:	44f8                	lw	a4,76(s1)
    80003532:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003534:	03400613          	li	a2,52
    80003538:	05048593          	addi	a1,s1,80
    8000353c:	0531                	addi	a0,a0,12
    8000353e:	ffffe097          	auipc	ra,0xffffe
    80003542:	836080e7          	jalr	-1994(ra) # 80000d74 <memmove>
  log_write(bp);
    80003546:	854a                	mv	a0,s2
    80003548:	00001097          	auipc	ra,0x1
    8000354c:	c04080e7          	jalr	-1020(ra) # 8000414c <log_write>
  brelse(bp);
    80003550:	854a                	mv	a0,s2
    80003552:	00000097          	auipc	ra,0x0
    80003556:	980080e7          	jalr	-1664(ra) # 80002ed2 <brelse>
}
    8000355a:	60e2                	ld	ra,24(sp)
    8000355c:	6442                	ld	s0,16(sp)
    8000355e:	64a2                	ld	s1,8(sp)
    80003560:	6902                	ld	s2,0(sp)
    80003562:	6105                	addi	sp,sp,32
    80003564:	8082                	ret

0000000080003566 <idup>:
{
    80003566:	1101                	addi	sp,sp,-32
    80003568:	ec06                	sd	ra,24(sp)
    8000356a:	e822                	sd	s0,16(sp)
    8000356c:	e426                	sd	s1,8(sp)
    8000356e:	1000                	addi	s0,sp,32
    80003570:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003572:	0001c517          	auipc	a0,0x1c
    80003576:	22e50513          	addi	a0,a0,558 # 8001f7a0 <icache>
    8000357a:	ffffd097          	auipc	ra,0xffffd
    8000357e:	69e080e7          	jalr	1694(ra) # 80000c18 <acquire>
  ip->ref++;
    80003582:	449c                	lw	a5,8(s1)
    80003584:	2785                	addiw	a5,a5,1
    80003586:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003588:	0001c517          	auipc	a0,0x1c
    8000358c:	21850513          	addi	a0,a0,536 # 8001f7a0 <icache>
    80003590:	ffffd097          	auipc	ra,0xffffd
    80003594:	73c080e7          	jalr	1852(ra) # 80000ccc <release>
}
    80003598:	8526                	mv	a0,s1
    8000359a:	60e2                	ld	ra,24(sp)
    8000359c:	6442                	ld	s0,16(sp)
    8000359e:	64a2                	ld	s1,8(sp)
    800035a0:	6105                	addi	sp,sp,32
    800035a2:	8082                	ret

00000000800035a4 <ilock>:
{
    800035a4:	1101                	addi	sp,sp,-32
    800035a6:	ec06                	sd	ra,24(sp)
    800035a8:	e822                	sd	s0,16(sp)
    800035aa:	e426                	sd	s1,8(sp)
    800035ac:	e04a                	sd	s2,0(sp)
    800035ae:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800035b0:	c115                	beqz	a0,800035d4 <ilock+0x30>
    800035b2:	84aa                	mv	s1,a0
    800035b4:	451c                	lw	a5,8(a0)
    800035b6:	00f05f63          	blez	a5,800035d4 <ilock+0x30>
  acquiresleep(&ip->lock);
    800035ba:	0541                	addi	a0,a0,16
    800035bc:	00001097          	auipc	ra,0x1
    800035c0:	cb8080e7          	jalr	-840(ra) # 80004274 <acquiresleep>
  if(ip->valid == 0){
    800035c4:	40bc                	lw	a5,64(s1)
    800035c6:	cf99                	beqz	a5,800035e4 <ilock+0x40>
}
    800035c8:	60e2                	ld	ra,24(sp)
    800035ca:	6442                	ld	s0,16(sp)
    800035cc:	64a2                	ld	s1,8(sp)
    800035ce:	6902                	ld	s2,0(sp)
    800035d0:	6105                	addi	sp,sp,32
    800035d2:	8082                	ret
    panic("ilock");
    800035d4:	00005517          	auipc	a0,0x5
    800035d8:	fcc50513          	addi	a0,a0,-52 # 800085a0 <syscalls+0x180>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	f74080e7          	jalr	-140(ra) # 80000550 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035e4:	40dc                	lw	a5,4(s1)
    800035e6:	0047d79b          	srliw	a5,a5,0x4
    800035ea:	0001c597          	auipc	a1,0x1c
    800035ee:	1ae5a583          	lw	a1,430(a1) # 8001f798 <sb+0x18>
    800035f2:	9dbd                	addw	a1,a1,a5
    800035f4:	4088                	lw	a0,0(s1)
    800035f6:	fffff097          	auipc	ra,0xfffff
    800035fa:	7ac080e7          	jalr	1964(ra) # 80002da2 <bread>
    800035fe:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003600:	05850593          	addi	a1,a0,88
    80003604:	40dc                	lw	a5,4(s1)
    80003606:	8bbd                	andi	a5,a5,15
    80003608:	079a                	slli	a5,a5,0x6
    8000360a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000360c:	00059783          	lh	a5,0(a1)
    80003610:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003614:	00259783          	lh	a5,2(a1)
    80003618:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000361c:	00459783          	lh	a5,4(a1)
    80003620:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003624:	00659783          	lh	a5,6(a1)
    80003628:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000362c:	459c                	lw	a5,8(a1)
    8000362e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003630:	03400613          	li	a2,52
    80003634:	05b1                	addi	a1,a1,12
    80003636:	05048513          	addi	a0,s1,80
    8000363a:	ffffd097          	auipc	ra,0xffffd
    8000363e:	73a080e7          	jalr	1850(ra) # 80000d74 <memmove>
    brelse(bp);
    80003642:	854a                	mv	a0,s2
    80003644:	00000097          	auipc	ra,0x0
    80003648:	88e080e7          	jalr	-1906(ra) # 80002ed2 <brelse>
    ip->valid = 1;
    8000364c:	4785                	li	a5,1
    8000364e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003650:	04449783          	lh	a5,68(s1)
    80003654:	fbb5                	bnez	a5,800035c8 <ilock+0x24>
      panic("ilock: no type");
    80003656:	00005517          	auipc	a0,0x5
    8000365a:	f5250513          	addi	a0,a0,-174 # 800085a8 <syscalls+0x188>
    8000365e:	ffffd097          	auipc	ra,0xffffd
    80003662:	ef2080e7          	jalr	-270(ra) # 80000550 <panic>

0000000080003666 <iunlock>:
{
    80003666:	1101                	addi	sp,sp,-32
    80003668:	ec06                	sd	ra,24(sp)
    8000366a:	e822                	sd	s0,16(sp)
    8000366c:	e426                	sd	s1,8(sp)
    8000366e:	e04a                	sd	s2,0(sp)
    80003670:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003672:	c905                	beqz	a0,800036a2 <iunlock+0x3c>
    80003674:	84aa                	mv	s1,a0
    80003676:	01050913          	addi	s2,a0,16
    8000367a:	854a                	mv	a0,s2
    8000367c:	00001097          	auipc	ra,0x1
    80003680:	c92080e7          	jalr	-878(ra) # 8000430e <holdingsleep>
    80003684:	cd19                	beqz	a0,800036a2 <iunlock+0x3c>
    80003686:	449c                	lw	a5,8(s1)
    80003688:	00f05d63          	blez	a5,800036a2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000368c:	854a                	mv	a0,s2
    8000368e:	00001097          	auipc	ra,0x1
    80003692:	c3c080e7          	jalr	-964(ra) # 800042ca <releasesleep>
}
    80003696:	60e2                	ld	ra,24(sp)
    80003698:	6442                	ld	s0,16(sp)
    8000369a:	64a2                	ld	s1,8(sp)
    8000369c:	6902                	ld	s2,0(sp)
    8000369e:	6105                	addi	sp,sp,32
    800036a0:	8082                	ret
    panic("iunlock");
    800036a2:	00005517          	auipc	a0,0x5
    800036a6:	f1650513          	addi	a0,a0,-234 # 800085b8 <syscalls+0x198>
    800036aa:	ffffd097          	auipc	ra,0xffffd
    800036ae:	ea6080e7          	jalr	-346(ra) # 80000550 <panic>

00000000800036b2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800036b2:	7179                	addi	sp,sp,-48
    800036b4:	f406                	sd	ra,40(sp)
    800036b6:	f022                	sd	s0,32(sp)
    800036b8:	ec26                	sd	s1,24(sp)
    800036ba:	e84a                	sd	s2,16(sp)
    800036bc:	e44e                	sd	s3,8(sp)
    800036be:	e052                	sd	s4,0(sp)
    800036c0:	1800                	addi	s0,sp,48
    800036c2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800036c4:	05050493          	addi	s1,a0,80
    800036c8:	08050913          	addi	s2,a0,128
    800036cc:	a021                	j	800036d4 <itrunc+0x22>
    800036ce:	0491                	addi	s1,s1,4
    800036d0:	01248d63          	beq	s1,s2,800036ea <itrunc+0x38>
    if(ip->addrs[i]){
    800036d4:	408c                	lw	a1,0(s1)
    800036d6:	dde5                	beqz	a1,800036ce <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800036d8:	0009a503          	lw	a0,0(s3)
    800036dc:	00000097          	auipc	ra,0x0
    800036e0:	90c080e7          	jalr	-1780(ra) # 80002fe8 <bfree>
      ip->addrs[i] = 0;
    800036e4:	0004a023          	sw	zero,0(s1)
    800036e8:	b7dd                	j	800036ce <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800036ea:	0809a583          	lw	a1,128(s3)
    800036ee:	e185                	bnez	a1,8000370e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036f0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036f4:	854e                	mv	a0,s3
    800036f6:	00000097          	auipc	ra,0x0
    800036fa:	de4080e7          	jalr	-540(ra) # 800034da <iupdate>
}
    800036fe:	70a2                	ld	ra,40(sp)
    80003700:	7402                	ld	s0,32(sp)
    80003702:	64e2                	ld	s1,24(sp)
    80003704:	6942                	ld	s2,16(sp)
    80003706:	69a2                	ld	s3,8(sp)
    80003708:	6a02                	ld	s4,0(sp)
    8000370a:	6145                	addi	sp,sp,48
    8000370c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000370e:	0009a503          	lw	a0,0(s3)
    80003712:	fffff097          	auipc	ra,0xfffff
    80003716:	690080e7          	jalr	1680(ra) # 80002da2 <bread>
    8000371a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000371c:	05850493          	addi	s1,a0,88
    80003720:	45850913          	addi	s2,a0,1112
    80003724:	a811                	j	80003738 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003726:	0009a503          	lw	a0,0(s3)
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	8be080e7          	jalr	-1858(ra) # 80002fe8 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003732:	0491                	addi	s1,s1,4
    80003734:	01248563          	beq	s1,s2,8000373e <itrunc+0x8c>
      if(a[j])
    80003738:	408c                	lw	a1,0(s1)
    8000373a:	dde5                	beqz	a1,80003732 <itrunc+0x80>
    8000373c:	b7ed                	j	80003726 <itrunc+0x74>
    brelse(bp);
    8000373e:	8552                	mv	a0,s4
    80003740:	fffff097          	auipc	ra,0xfffff
    80003744:	792080e7          	jalr	1938(ra) # 80002ed2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003748:	0809a583          	lw	a1,128(s3)
    8000374c:	0009a503          	lw	a0,0(s3)
    80003750:	00000097          	auipc	ra,0x0
    80003754:	898080e7          	jalr	-1896(ra) # 80002fe8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003758:	0809a023          	sw	zero,128(s3)
    8000375c:	bf51                	j	800036f0 <itrunc+0x3e>

000000008000375e <iput>:
{
    8000375e:	1101                	addi	sp,sp,-32
    80003760:	ec06                	sd	ra,24(sp)
    80003762:	e822                	sd	s0,16(sp)
    80003764:	e426                	sd	s1,8(sp)
    80003766:	e04a                	sd	s2,0(sp)
    80003768:	1000                	addi	s0,sp,32
    8000376a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000376c:	0001c517          	auipc	a0,0x1c
    80003770:	03450513          	addi	a0,a0,52 # 8001f7a0 <icache>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	4a4080e7          	jalr	1188(ra) # 80000c18 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000377c:	4498                	lw	a4,8(s1)
    8000377e:	4785                	li	a5,1
    80003780:	02f70363          	beq	a4,a5,800037a6 <iput+0x48>
  ip->ref--;
    80003784:	449c                	lw	a5,8(s1)
    80003786:	37fd                	addiw	a5,a5,-1
    80003788:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000378a:	0001c517          	auipc	a0,0x1c
    8000378e:	01650513          	addi	a0,a0,22 # 8001f7a0 <icache>
    80003792:	ffffd097          	auipc	ra,0xffffd
    80003796:	53a080e7          	jalr	1338(ra) # 80000ccc <release>
}
    8000379a:	60e2                	ld	ra,24(sp)
    8000379c:	6442                	ld	s0,16(sp)
    8000379e:	64a2                	ld	s1,8(sp)
    800037a0:	6902                	ld	s2,0(sp)
    800037a2:	6105                	addi	sp,sp,32
    800037a4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037a6:	40bc                	lw	a5,64(s1)
    800037a8:	dff1                	beqz	a5,80003784 <iput+0x26>
    800037aa:	04a49783          	lh	a5,74(s1)
    800037ae:	fbf9                	bnez	a5,80003784 <iput+0x26>
    acquiresleep(&ip->lock);
    800037b0:	01048913          	addi	s2,s1,16
    800037b4:	854a                	mv	a0,s2
    800037b6:	00001097          	auipc	ra,0x1
    800037ba:	abe080e7          	jalr	-1346(ra) # 80004274 <acquiresleep>
    release(&icache.lock);
    800037be:	0001c517          	auipc	a0,0x1c
    800037c2:	fe250513          	addi	a0,a0,-30 # 8001f7a0 <icache>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	506080e7          	jalr	1286(ra) # 80000ccc <release>
    itrunc(ip);
    800037ce:	8526                	mv	a0,s1
    800037d0:	00000097          	auipc	ra,0x0
    800037d4:	ee2080e7          	jalr	-286(ra) # 800036b2 <itrunc>
    ip->type = 0;
    800037d8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800037dc:	8526                	mv	a0,s1
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	cfc080e7          	jalr	-772(ra) # 800034da <iupdate>
    ip->valid = 0;
    800037e6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800037ea:	854a                	mv	a0,s2
    800037ec:	00001097          	auipc	ra,0x1
    800037f0:	ade080e7          	jalr	-1314(ra) # 800042ca <releasesleep>
    acquire(&icache.lock);
    800037f4:	0001c517          	auipc	a0,0x1c
    800037f8:	fac50513          	addi	a0,a0,-84 # 8001f7a0 <icache>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	41c080e7          	jalr	1052(ra) # 80000c18 <acquire>
    80003804:	b741                	j	80003784 <iput+0x26>

0000000080003806 <iunlockput>:
{
    80003806:	1101                	addi	sp,sp,-32
    80003808:	ec06                	sd	ra,24(sp)
    8000380a:	e822                	sd	s0,16(sp)
    8000380c:	e426                	sd	s1,8(sp)
    8000380e:	1000                	addi	s0,sp,32
    80003810:	84aa                	mv	s1,a0
  iunlock(ip);
    80003812:	00000097          	auipc	ra,0x0
    80003816:	e54080e7          	jalr	-428(ra) # 80003666 <iunlock>
  iput(ip);
    8000381a:	8526                	mv	a0,s1
    8000381c:	00000097          	auipc	ra,0x0
    80003820:	f42080e7          	jalr	-190(ra) # 8000375e <iput>
}
    80003824:	60e2                	ld	ra,24(sp)
    80003826:	6442                	ld	s0,16(sp)
    80003828:	64a2                	ld	s1,8(sp)
    8000382a:	6105                	addi	sp,sp,32
    8000382c:	8082                	ret

000000008000382e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000382e:	1141                	addi	sp,sp,-16
    80003830:	e422                	sd	s0,8(sp)
    80003832:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003834:	411c                	lw	a5,0(a0)
    80003836:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003838:	415c                	lw	a5,4(a0)
    8000383a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000383c:	04451783          	lh	a5,68(a0)
    80003840:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003844:	04a51783          	lh	a5,74(a0)
    80003848:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000384c:	04c56783          	lwu	a5,76(a0)
    80003850:	e99c                	sd	a5,16(a1)
}
    80003852:	6422                	ld	s0,8(sp)
    80003854:	0141                	addi	sp,sp,16
    80003856:	8082                	ret

0000000080003858 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003858:	457c                	lw	a5,76(a0)
    8000385a:	0ed7e963          	bltu	a5,a3,8000394c <readi+0xf4>
{
    8000385e:	7159                	addi	sp,sp,-112
    80003860:	f486                	sd	ra,104(sp)
    80003862:	f0a2                	sd	s0,96(sp)
    80003864:	eca6                	sd	s1,88(sp)
    80003866:	e8ca                	sd	s2,80(sp)
    80003868:	e4ce                	sd	s3,72(sp)
    8000386a:	e0d2                	sd	s4,64(sp)
    8000386c:	fc56                	sd	s5,56(sp)
    8000386e:	f85a                	sd	s6,48(sp)
    80003870:	f45e                	sd	s7,40(sp)
    80003872:	f062                	sd	s8,32(sp)
    80003874:	ec66                	sd	s9,24(sp)
    80003876:	e86a                	sd	s10,16(sp)
    80003878:	e46e                	sd	s11,8(sp)
    8000387a:	1880                	addi	s0,sp,112
    8000387c:	8baa                	mv	s7,a0
    8000387e:	8c2e                	mv	s8,a1
    80003880:	8ab2                	mv	s5,a2
    80003882:	84b6                	mv	s1,a3
    80003884:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003886:	9f35                	addw	a4,a4,a3
    return 0;
    80003888:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000388a:	0ad76063          	bltu	a4,a3,8000392a <readi+0xd2>
  if(off + n > ip->size)
    8000388e:	00e7f463          	bgeu	a5,a4,80003896 <readi+0x3e>
    n = ip->size - off;
    80003892:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003896:	0a0b0963          	beqz	s6,80003948 <readi+0xf0>
    8000389a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000389c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038a0:	5cfd                	li	s9,-1
    800038a2:	a82d                	j	800038dc <readi+0x84>
    800038a4:	020a1d93          	slli	s11,s4,0x20
    800038a8:	020ddd93          	srli	s11,s11,0x20
    800038ac:	05890613          	addi	a2,s2,88
    800038b0:	86ee                	mv	a3,s11
    800038b2:	963a                	add	a2,a2,a4
    800038b4:	85d6                	mv	a1,s5
    800038b6:	8562                	mv	a0,s8
    800038b8:	fffff097          	auipc	ra,0xfffff
    800038bc:	b2e080e7          	jalr	-1234(ra) # 800023e6 <either_copyout>
    800038c0:	05950d63          	beq	a0,s9,8000391a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038c4:	854a                	mv	a0,s2
    800038c6:	fffff097          	auipc	ra,0xfffff
    800038ca:	60c080e7          	jalr	1548(ra) # 80002ed2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038ce:	013a09bb          	addw	s3,s4,s3
    800038d2:	009a04bb          	addw	s1,s4,s1
    800038d6:	9aee                	add	s5,s5,s11
    800038d8:	0569f763          	bgeu	s3,s6,80003926 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800038dc:	000ba903          	lw	s2,0(s7)
    800038e0:	00a4d59b          	srliw	a1,s1,0xa
    800038e4:	855e                	mv	a0,s7
    800038e6:	00000097          	auipc	ra,0x0
    800038ea:	8b0080e7          	jalr	-1872(ra) # 80003196 <bmap>
    800038ee:	0005059b          	sext.w	a1,a0
    800038f2:	854a                	mv	a0,s2
    800038f4:	fffff097          	auipc	ra,0xfffff
    800038f8:	4ae080e7          	jalr	1198(ra) # 80002da2 <bread>
    800038fc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038fe:	3ff4f713          	andi	a4,s1,1023
    80003902:	40ed07bb          	subw	a5,s10,a4
    80003906:	413b06bb          	subw	a3,s6,s3
    8000390a:	8a3e                	mv	s4,a5
    8000390c:	2781                	sext.w	a5,a5
    8000390e:	0006861b          	sext.w	a2,a3
    80003912:	f8f679e3          	bgeu	a2,a5,800038a4 <readi+0x4c>
    80003916:	8a36                	mv	s4,a3
    80003918:	b771                	j	800038a4 <readi+0x4c>
      brelse(bp);
    8000391a:	854a                	mv	a0,s2
    8000391c:	fffff097          	auipc	ra,0xfffff
    80003920:	5b6080e7          	jalr	1462(ra) # 80002ed2 <brelse>
      tot = -1;
    80003924:	59fd                	li	s3,-1
  }
  return tot;
    80003926:	0009851b          	sext.w	a0,s3
}
    8000392a:	70a6                	ld	ra,104(sp)
    8000392c:	7406                	ld	s0,96(sp)
    8000392e:	64e6                	ld	s1,88(sp)
    80003930:	6946                	ld	s2,80(sp)
    80003932:	69a6                	ld	s3,72(sp)
    80003934:	6a06                	ld	s4,64(sp)
    80003936:	7ae2                	ld	s5,56(sp)
    80003938:	7b42                	ld	s6,48(sp)
    8000393a:	7ba2                	ld	s7,40(sp)
    8000393c:	7c02                	ld	s8,32(sp)
    8000393e:	6ce2                	ld	s9,24(sp)
    80003940:	6d42                	ld	s10,16(sp)
    80003942:	6da2                	ld	s11,8(sp)
    80003944:	6165                	addi	sp,sp,112
    80003946:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003948:	89da                	mv	s3,s6
    8000394a:	bff1                	j	80003926 <readi+0xce>
    return 0;
    8000394c:	4501                	li	a0,0
}
    8000394e:	8082                	ret

0000000080003950 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003950:	457c                	lw	a5,76(a0)
    80003952:	10d7e763          	bltu	a5,a3,80003a60 <writei+0x110>
{
    80003956:	7159                	addi	sp,sp,-112
    80003958:	f486                	sd	ra,104(sp)
    8000395a:	f0a2                	sd	s0,96(sp)
    8000395c:	eca6                	sd	s1,88(sp)
    8000395e:	e8ca                	sd	s2,80(sp)
    80003960:	e4ce                	sd	s3,72(sp)
    80003962:	e0d2                	sd	s4,64(sp)
    80003964:	fc56                	sd	s5,56(sp)
    80003966:	f85a                	sd	s6,48(sp)
    80003968:	f45e                	sd	s7,40(sp)
    8000396a:	f062                	sd	s8,32(sp)
    8000396c:	ec66                	sd	s9,24(sp)
    8000396e:	e86a                	sd	s10,16(sp)
    80003970:	e46e                	sd	s11,8(sp)
    80003972:	1880                	addi	s0,sp,112
    80003974:	8baa                	mv	s7,a0
    80003976:	8c2e                	mv	s8,a1
    80003978:	8ab2                	mv	s5,a2
    8000397a:	8936                	mv	s2,a3
    8000397c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000397e:	00e687bb          	addw	a5,a3,a4
    80003982:	0ed7e163          	bltu	a5,a3,80003a64 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003986:	00043737          	lui	a4,0x43
    8000398a:	0cf76f63          	bltu	a4,a5,80003a68 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000398e:	0a0b0863          	beqz	s6,80003a3e <writei+0xee>
    80003992:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003994:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003998:	5cfd                	li	s9,-1
    8000399a:	a091                	j	800039de <writei+0x8e>
    8000399c:	02099d93          	slli	s11,s3,0x20
    800039a0:	020ddd93          	srli	s11,s11,0x20
    800039a4:	05848513          	addi	a0,s1,88
    800039a8:	86ee                	mv	a3,s11
    800039aa:	8656                	mv	a2,s5
    800039ac:	85e2                	mv	a1,s8
    800039ae:	953a                	add	a0,a0,a4
    800039b0:	fffff097          	auipc	ra,0xfffff
    800039b4:	a8c080e7          	jalr	-1396(ra) # 8000243c <either_copyin>
    800039b8:	07950263          	beq	a0,s9,80003a1c <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    800039bc:	8526                	mv	a0,s1
    800039be:	00000097          	auipc	ra,0x0
    800039c2:	78e080e7          	jalr	1934(ra) # 8000414c <log_write>
    brelse(bp);
    800039c6:	8526                	mv	a0,s1
    800039c8:	fffff097          	auipc	ra,0xfffff
    800039cc:	50a080e7          	jalr	1290(ra) # 80002ed2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039d0:	01498a3b          	addw	s4,s3,s4
    800039d4:	0129893b          	addw	s2,s3,s2
    800039d8:	9aee                	add	s5,s5,s11
    800039da:	056a7763          	bgeu	s4,s6,80003a28 <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039de:	000ba483          	lw	s1,0(s7)
    800039e2:	00a9559b          	srliw	a1,s2,0xa
    800039e6:	855e                	mv	a0,s7
    800039e8:	fffff097          	auipc	ra,0xfffff
    800039ec:	7ae080e7          	jalr	1966(ra) # 80003196 <bmap>
    800039f0:	0005059b          	sext.w	a1,a0
    800039f4:	8526                	mv	a0,s1
    800039f6:	fffff097          	auipc	ra,0xfffff
    800039fa:	3ac080e7          	jalr	940(ra) # 80002da2 <bread>
    800039fe:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a00:	3ff97713          	andi	a4,s2,1023
    80003a04:	40ed07bb          	subw	a5,s10,a4
    80003a08:	414b06bb          	subw	a3,s6,s4
    80003a0c:	89be                	mv	s3,a5
    80003a0e:	2781                	sext.w	a5,a5
    80003a10:	0006861b          	sext.w	a2,a3
    80003a14:	f8f674e3          	bgeu	a2,a5,8000399c <writei+0x4c>
    80003a18:	89b6                	mv	s3,a3
    80003a1a:	b749                	j	8000399c <writei+0x4c>
      brelse(bp);
    80003a1c:	8526                	mv	a0,s1
    80003a1e:	fffff097          	auipc	ra,0xfffff
    80003a22:	4b4080e7          	jalr	1204(ra) # 80002ed2 <brelse>
      n = -1;
    80003a26:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003a28:	04cba783          	lw	a5,76(s7)
    80003a2c:	0127f463          	bgeu	a5,s2,80003a34 <writei+0xe4>
      ip->size = off;
    80003a30:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003a34:	855e                	mv	a0,s7
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	aa4080e7          	jalr	-1372(ra) # 800034da <iupdate>
  }

  return n;
    80003a3e:	000b051b          	sext.w	a0,s6
}
    80003a42:	70a6                	ld	ra,104(sp)
    80003a44:	7406                	ld	s0,96(sp)
    80003a46:	64e6                	ld	s1,88(sp)
    80003a48:	6946                	ld	s2,80(sp)
    80003a4a:	69a6                	ld	s3,72(sp)
    80003a4c:	6a06                	ld	s4,64(sp)
    80003a4e:	7ae2                	ld	s5,56(sp)
    80003a50:	7b42                	ld	s6,48(sp)
    80003a52:	7ba2                	ld	s7,40(sp)
    80003a54:	7c02                	ld	s8,32(sp)
    80003a56:	6ce2                	ld	s9,24(sp)
    80003a58:	6d42                	ld	s10,16(sp)
    80003a5a:	6da2                	ld	s11,8(sp)
    80003a5c:	6165                	addi	sp,sp,112
    80003a5e:	8082                	ret
    return -1;
    80003a60:	557d                	li	a0,-1
}
    80003a62:	8082                	ret
    return -1;
    80003a64:	557d                	li	a0,-1
    80003a66:	bff1                	j	80003a42 <writei+0xf2>
    return -1;
    80003a68:	557d                	li	a0,-1
    80003a6a:	bfe1                	j	80003a42 <writei+0xf2>

0000000080003a6c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a6c:	1141                	addi	sp,sp,-16
    80003a6e:	e406                	sd	ra,8(sp)
    80003a70:	e022                	sd	s0,0(sp)
    80003a72:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a74:	4639                	li	a2,14
    80003a76:	ffffd097          	auipc	ra,0xffffd
    80003a7a:	37a080e7          	jalr	890(ra) # 80000df0 <strncmp>
}
    80003a7e:	60a2                	ld	ra,8(sp)
    80003a80:	6402                	ld	s0,0(sp)
    80003a82:	0141                	addi	sp,sp,16
    80003a84:	8082                	ret

0000000080003a86 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a86:	7139                	addi	sp,sp,-64
    80003a88:	fc06                	sd	ra,56(sp)
    80003a8a:	f822                	sd	s0,48(sp)
    80003a8c:	f426                	sd	s1,40(sp)
    80003a8e:	f04a                	sd	s2,32(sp)
    80003a90:	ec4e                	sd	s3,24(sp)
    80003a92:	e852                	sd	s4,16(sp)
    80003a94:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a96:	04451703          	lh	a4,68(a0)
    80003a9a:	4785                	li	a5,1
    80003a9c:	00f71a63          	bne	a4,a5,80003ab0 <dirlookup+0x2a>
    80003aa0:	892a                	mv	s2,a0
    80003aa2:	89ae                	mv	s3,a1
    80003aa4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aa6:	457c                	lw	a5,76(a0)
    80003aa8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003aaa:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aac:	e79d                	bnez	a5,80003ada <dirlookup+0x54>
    80003aae:	a8a5                	j	80003b26 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ab0:	00005517          	auipc	a0,0x5
    80003ab4:	b1050513          	addi	a0,a0,-1264 # 800085c0 <syscalls+0x1a0>
    80003ab8:	ffffd097          	auipc	ra,0xffffd
    80003abc:	a98080e7          	jalr	-1384(ra) # 80000550 <panic>
      panic("dirlookup read");
    80003ac0:	00005517          	auipc	a0,0x5
    80003ac4:	b1850513          	addi	a0,a0,-1256 # 800085d8 <syscalls+0x1b8>
    80003ac8:	ffffd097          	auipc	ra,0xffffd
    80003acc:	a88080e7          	jalr	-1400(ra) # 80000550 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ad0:	24c1                	addiw	s1,s1,16
    80003ad2:	04c92783          	lw	a5,76(s2)
    80003ad6:	04f4f763          	bgeu	s1,a5,80003b24 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ada:	4741                	li	a4,16
    80003adc:	86a6                	mv	a3,s1
    80003ade:	fc040613          	addi	a2,s0,-64
    80003ae2:	4581                	li	a1,0
    80003ae4:	854a                	mv	a0,s2
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	d72080e7          	jalr	-654(ra) # 80003858 <readi>
    80003aee:	47c1                	li	a5,16
    80003af0:	fcf518e3          	bne	a0,a5,80003ac0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003af4:	fc045783          	lhu	a5,-64(s0)
    80003af8:	dfe1                	beqz	a5,80003ad0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003afa:	fc240593          	addi	a1,s0,-62
    80003afe:	854e                	mv	a0,s3
    80003b00:	00000097          	auipc	ra,0x0
    80003b04:	f6c080e7          	jalr	-148(ra) # 80003a6c <namecmp>
    80003b08:	f561                	bnez	a0,80003ad0 <dirlookup+0x4a>
      if(poff)
    80003b0a:	000a0463          	beqz	s4,80003b12 <dirlookup+0x8c>
        *poff = off;
    80003b0e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b12:	fc045583          	lhu	a1,-64(s0)
    80003b16:	00092503          	lw	a0,0(s2)
    80003b1a:	fffff097          	auipc	ra,0xfffff
    80003b1e:	756080e7          	jalr	1878(ra) # 80003270 <iget>
    80003b22:	a011                	j	80003b26 <dirlookup+0xa0>
  return 0;
    80003b24:	4501                	li	a0,0
}
    80003b26:	70e2                	ld	ra,56(sp)
    80003b28:	7442                	ld	s0,48(sp)
    80003b2a:	74a2                	ld	s1,40(sp)
    80003b2c:	7902                	ld	s2,32(sp)
    80003b2e:	69e2                	ld	s3,24(sp)
    80003b30:	6a42                	ld	s4,16(sp)
    80003b32:	6121                	addi	sp,sp,64
    80003b34:	8082                	ret

0000000080003b36 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b36:	711d                	addi	sp,sp,-96
    80003b38:	ec86                	sd	ra,88(sp)
    80003b3a:	e8a2                	sd	s0,80(sp)
    80003b3c:	e4a6                	sd	s1,72(sp)
    80003b3e:	e0ca                	sd	s2,64(sp)
    80003b40:	fc4e                	sd	s3,56(sp)
    80003b42:	f852                	sd	s4,48(sp)
    80003b44:	f456                	sd	s5,40(sp)
    80003b46:	f05a                	sd	s6,32(sp)
    80003b48:	ec5e                	sd	s7,24(sp)
    80003b4a:	e862                	sd	s8,16(sp)
    80003b4c:	e466                	sd	s9,8(sp)
    80003b4e:	1080                	addi	s0,sp,96
    80003b50:	84aa                	mv	s1,a0
    80003b52:	8b2e                	mv	s6,a1
    80003b54:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b56:	00054703          	lbu	a4,0(a0)
    80003b5a:	02f00793          	li	a5,47
    80003b5e:	02f70363          	beq	a4,a5,80003b84 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b62:	ffffe097          	auipc	ra,0xffffe
    80003b66:	e12080e7          	jalr	-494(ra) # 80001974 <myproc>
    80003b6a:	15053503          	ld	a0,336(a0)
    80003b6e:	00000097          	auipc	ra,0x0
    80003b72:	9f8080e7          	jalr	-1544(ra) # 80003566 <idup>
    80003b76:	89aa                	mv	s3,a0
  while(*path == '/')
    80003b78:	02f00913          	li	s2,47
  len = path - s;
    80003b7c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003b7e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b80:	4c05                	li	s8,1
    80003b82:	a865                	j	80003c3a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003b84:	4585                	li	a1,1
    80003b86:	4505                	li	a0,1
    80003b88:	fffff097          	auipc	ra,0xfffff
    80003b8c:	6e8080e7          	jalr	1768(ra) # 80003270 <iget>
    80003b90:	89aa                	mv	s3,a0
    80003b92:	b7dd                	j	80003b78 <namex+0x42>
      iunlockput(ip);
    80003b94:	854e                	mv	a0,s3
    80003b96:	00000097          	auipc	ra,0x0
    80003b9a:	c70080e7          	jalr	-912(ra) # 80003806 <iunlockput>
      return 0;
    80003b9e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ba0:	854e                	mv	a0,s3
    80003ba2:	60e6                	ld	ra,88(sp)
    80003ba4:	6446                	ld	s0,80(sp)
    80003ba6:	64a6                	ld	s1,72(sp)
    80003ba8:	6906                	ld	s2,64(sp)
    80003baa:	79e2                	ld	s3,56(sp)
    80003bac:	7a42                	ld	s4,48(sp)
    80003bae:	7aa2                	ld	s5,40(sp)
    80003bb0:	7b02                	ld	s6,32(sp)
    80003bb2:	6be2                	ld	s7,24(sp)
    80003bb4:	6c42                	ld	s8,16(sp)
    80003bb6:	6ca2                	ld	s9,8(sp)
    80003bb8:	6125                	addi	sp,sp,96
    80003bba:	8082                	ret
      iunlock(ip);
    80003bbc:	854e                	mv	a0,s3
    80003bbe:	00000097          	auipc	ra,0x0
    80003bc2:	aa8080e7          	jalr	-1368(ra) # 80003666 <iunlock>
      return ip;
    80003bc6:	bfe9                	j	80003ba0 <namex+0x6a>
      iunlockput(ip);
    80003bc8:	854e                	mv	a0,s3
    80003bca:	00000097          	auipc	ra,0x0
    80003bce:	c3c080e7          	jalr	-964(ra) # 80003806 <iunlockput>
      return 0;
    80003bd2:	89d2                	mv	s3,s4
    80003bd4:	b7f1                	j	80003ba0 <namex+0x6a>
  len = path - s;
    80003bd6:	40b48633          	sub	a2,s1,a1
    80003bda:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003bde:	094cd463          	bge	s9,s4,80003c66 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003be2:	4639                	li	a2,14
    80003be4:	8556                	mv	a0,s5
    80003be6:	ffffd097          	auipc	ra,0xffffd
    80003bea:	18e080e7          	jalr	398(ra) # 80000d74 <memmove>
  while(*path == '/')
    80003bee:	0004c783          	lbu	a5,0(s1)
    80003bf2:	01279763          	bne	a5,s2,80003c00 <namex+0xca>
    path++;
    80003bf6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bf8:	0004c783          	lbu	a5,0(s1)
    80003bfc:	ff278de3          	beq	a5,s2,80003bf6 <namex+0xc0>
    ilock(ip);
    80003c00:	854e                	mv	a0,s3
    80003c02:	00000097          	auipc	ra,0x0
    80003c06:	9a2080e7          	jalr	-1630(ra) # 800035a4 <ilock>
    if(ip->type != T_DIR){
    80003c0a:	04499783          	lh	a5,68(s3)
    80003c0e:	f98793e3          	bne	a5,s8,80003b94 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003c12:	000b0563          	beqz	s6,80003c1c <namex+0xe6>
    80003c16:	0004c783          	lbu	a5,0(s1)
    80003c1a:	d3cd                	beqz	a5,80003bbc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c1c:	865e                	mv	a2,s7
    80003c1e:	85d6                	mv	a1,s5
    80003c20:	854e                	mv	a0,s3
    80003c22:	00000097          	auipc	ra,0x0
    80003c26:	e64080e7          	jalr	-412(ra) # 80003a86 <dirlookup>
    80003c2a:	8a2a                	mv	s4,a0
    80003c2c:	dd51                	beqz	a0,80003bc8 <namex+0x92>
    iunlockput(ip);
    80003c2e:	854e                	mv	a0,s3
    80003c30:	00000097          	auipc	ra,0x0
    80003c34:	bd6080e7          	jalr	-1066(ra) # 80003806 <iunlockput>
    ip = next;
    80003c38:	89d2                	mv	s3,s4
  while(*path == '/')
    80003c3a:	0004c783          	lbu	a5,0(s1)
    80003c3e:	05279763          	bne	a5,s2,80003c8c <namex+0x156>
    path++;
    80003c42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c44:	0004c783          	lbu	a5,0(s1)
    80003c48:	ff278de3          	beq	a5,s2,80003c42 <namex+0x10c>
  if(*path == 0)
    80003c4c:	c79d                	beqz	a5,80003c7a <namex+0x144>
    path++;
    80003c4e:	85a6                	mv	a1,s1
  len = path - s;
    80003c50:	8a5e                	mv	s4,s7
    80003c52:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003c54:	01278963          	beq	a5,s2,80003c66 <namex+0x130>
    80003c58:	dfbd                	beqz	a5,80003bd6 <namex+0xa0>
    path++;
    80003c5a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003c5c:	0004c783          	lbu	a5,0(s1)
    80003c60:	ff279ce3          	bne	a5,s2,80003c58 <namex+0x122>
    80003c64:	bf8d                	j	80003bd6 <namex+0xa0>
    memmove(name, s, len);
    80003c66:	2601                	sext.w	a2,a2
    80003c68:	8556                	mv	a0,s5
    80003c6a:	ffffd097          	auipc	ra,0xffffd
    80003c6e:	10a080e7          	jalr	266(ra) # 80000d74 <memmove>
    name[len] = 0;
    80003c72:	9a56                	add	s4,s4,s5
    80003c74:	000a0023          	sb	zero,0(s4)
    80003c78:	bf9d                	j	80003bee <namex+0xb8>
  if(nameiparent){
    80003c7a:	f20b03e3          	beqz	s6,80003ba0 <namex+0x6a>
    iput(ip);
    80003c7e:	854e                	mv	a0,s3
    80003c80:	00000097          	auipc	ra,0x0
    80003c84:	ade080e7          	jalr	-1314(ra) # 8000375e <iput>
    return 0;
    80003c88:	4981                	li	s3,0
    80003c8a:	bf19                	j	80003ba0 <namex+0x6a>
  if(*path == 0)
    80003c8c:	d7fd                	beqz	a5,80003c7a <namex+0x144>
  while(*path != '/' && *path != 0)
    80003c8e:	0004c783          	lbu	a5,0(s1)
    80003c92:	85a6                	mv	a1,s1
    80003c94:	b7d1                	j	80003c58 <namex+0x122>

0000000080003c96 <dirlink>:
{
    80003c96:	7139                	addi	sp,sp,-64
    80003c98:	fc06                	sd	ra,56(sp)
    80003c9a:	f822                	sd	s0,48(sp)
    80003c9c:	f426                	sd	s1,40(sp)
    80003c9e:	f04a                	sd	s2,32(sp)
    80003ca0:	ec4e                	sd	s3,24(sp)
    80003ca2:	e852                	sd	s4,16(sp)
    80003ca4:	0080                	addi	s0,sp,64
    80003ca6:	892a                	mv	s2,a0
    80003ca8:	8a2e                	mv	s4,a1
    80003caa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003cac:	4601                	li	a2,0
    80003cae:	00000097          	auipc	ra,0x0
    80003cb2:	dd8080e7          	jalr	-552(ra) # 80003a86 <dirlookup>
    80003cb6:	e93d                	bnez	a0,80003d2c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cb8:	04c92483          	lw	s1,76(s2)
    80003cbc:	c49d                	beqz	s1,80003cea <dirlink+0x54>
    80003cbe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cc0:	4741                	li	a4,16
    80003cc2:	86a6                	mv	a3,s1
    80003cc4:	fc040613          	addi	a2,s0,-64
    80003cc8:	4581                	li	a1,0
    80003cca:	854a                	mv	a0,s2
    80003ccc:	00000097          	auipc	ra,0x0
    80003cd0:	b8c080e7          	jalr	-1140(ra) # 80003858 <readi>
    80003cd4:	47c1                	li	a5,16
    80003cd6:	06f51163          	bne	a0,a5,80003d38 <dirlink+0xa2>
    if(de.inum == 0)
    80003cda:	fc045783          	lhu	a5,-64(s0)
    80003cde:	c791                	beqz	a5,80003cea <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ce0:	24c1                	addiw	s1,s1,16
    80003ce2:	04c92783          	lw	a5,76(s2)
    80003ce6:	fcf4ede3          	bltu	s1,a5,80003cc0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003cea:	4639                	li	a2,14
    80003cec:	85d2                	mv	a1,s4
    80003cee:	fc240513          	addi	a0,s0,-62
    80003cf2:	ffffd097          	auipc	ra,0xffffd
    80003cf6:	13a080e7          	jalr	314(ra) # 80000e2c <strncpy>
  de.inum = inum;
    80003cfa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cfe:	4741                	li	a4,16
    80003d00:	86a6                	mv	a3,s1
    80003d02:	fc040613          	addi	a2,s0,-64
    80003d06:	4581                	li	a1,0
    80003d08:	854a                	mv	a0,s2
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	c46080e7          	jalr	-954(ra) # 80003950 <writei>
    80003d12:	872a                	mv	a4,a0
    80003d14:	47c1                	li	a5,16
  return 0;
    80003d16:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d18:	02f71863          	bne	a4,a5,80003d48 <dirlink+0xb2>
}
    80003d1c:	70e2                	ld	ra,56(sp)
    80003d1e:	7442                	ld	s0,48(sp)
    80003d20:	74a2                	ld	s1,40(sp)
    80003d22:	7902                	ld	s2,32(sp)
    80003d24:	69e2                	ld	s3,24(sp)
    80003d26:	6a42                	ld	s4,16(sp)
    80003d28:	6121                	addi	sp,sp,64
    80003d2a:	8082                	ret
    iput(ip);
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	a32080e7          	jalr	-1486(ra) # 8000375e <iput>
    return -1;
    80003d34:	557d                	li	a0,-1
    80003d36:	b7dd                	j	80003d1c <dirlink+0x86>
      panic("dirlink read");
    80003d38:	00005517          	auipc	a0,0x5
    80003d3c:	8b050513          	addi	a0,a0,-1872 # 800085e8 <syscalls+0x1c8>
    80003d40:	ffffd097          	auipc	ra,0xffffd
    80003d44:	810080e7          	jalr	-2032(ra) # 80000550 <panic>
    panic("dirlink");
    80003d48:	00005517          	auipc	a0,0x5
    80003d4c:	9c050513          	addi	a0,a0,-1600 # 80008708 <syscalls+0x2e8>
    80003d50:	ffffd097          	auipc	ra,0xffffd
    80003d54:	800080e7          	jalr	-2048(ra) # 80000550 <panic>

0000000080003d58 <namei>:

struct inode*
namei(char *path)
{
    80003d58:	1101                	addi	sp,sp,-32
    80003d5a:	ec06                	sd	ra,24(sp)
    80003d5c:	e822                	sd	s0,16(sp)
    80003d5e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d60:	fe040613          	addi	a2,s0,-32
    80003d64:	4581                	li	a1,0
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	dd0080e7          	jalr	-560(ra) # 80003b36 <namex>
}
    80003d6e:	60e2                	ld	ra,24(sp)
    80003d70:	6442                	ld	s0,16(sp)
    80003d72:	6105                	addi	sp,sp,32
    80003d74:	8082                	ret

0000000080003d76 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d76:	1141                	addi	sp,sp,-16
    80003d78:	e406                	sd	ra,8(sp)
    80003d7a:	e022                	sd	s0,0(sp)
    80003d7c:	0800                	addi	s0,sp,16
    80003d7e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d80:	4585                	li	a1,1
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	db4080e7          	jalr	-588(ra) # 80003b36 <namex>
}
    80003d8a:	60a2                	ld	ra,8(sp)
    80003d8c:	6402                	ld	s0,0(sp)
    80003d8e:	0141                	addi	sp,sp,16
    80003d90:	8082                	ret

0000000080003d92 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d92:	1101                	addi	sp,sp,-32
    80003d94:	ec06                	sd	ra,24(sp)
    80003d96:	e822                	sd	s0,16(sp)
    80003d98:	e426                	sd	s1,8(sp)
    80003d9a:	e04a                	sd	s2,0(sp)
    80003d9c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d9e:	0001d917          	auipc	s2,0x1d
    80003da2:	4aa90913          	addi	s2,s2,1194 # 80021248 <log>
    80003da6:	01892583          	lw	a1,24(s2)
    80003daa:	02892503          	lw	a0,40(s2)
    80003dae:	fffff097          	auipc	ra,0xfffff
    80003db2:	ff4080e7          	jalr	-12(ra) # 80002da2 <bread>
    80003db6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003db8:	02c92683          	lw	a3,44(s2)
    80003dbc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003dbe:	02d05763          	blez	a3,80003dec <write_head+0x5a>
    80003dc2:	0001d797          	auipc	a5,0x1d
    80003dc6:	4b678793          	addi	a5,a5,1206 # 80021278 <log+0x30>
    80003dca:	05c50713          	addi	a4,a0,92
    80003dce:	36fd                	addiw	a3,a3,-1
    80003dd0:	1682                	slli	a3,a3,0x20
    80003dd2:	9281                	srli	a3,a3,0x20
    80003dd4:	068a                	slli	a3,a3,0x2
    80003dd6:	0001d617          	auipc	a2,0x1d
    80003dda:	4a660613          	addi	a2,a2,1190 # 8002127c <log+0x34>
    80003dde:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003de0:	4390                	lw	a2,0(a5)
    80003de2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003de4:	0791                	addi	a5,a5,4
    80003de6:	0711                	addi	a4,a4,4
    80003de8:	fed79ce3          	bne	a5,a3,80003de0 <write_head+0x4e>
  }
  bwrite(buf);
    80003dec:	8526                	mv	a0,s1
    80003dee:	fffff097          	auipc	ra,0xfffff
    80003df2:	0a6080e7          	jalr	166(ra) # 80002e94 <bwrite>
  brelse(buf);
    80003df6:	8526                	mv	a0,s1
    80003df8:	fffff097          	auipc	ra,0xfffff
    80003dfc:	0da080e7          	jalr	218(ra) # 80002ed2 <brelse>
}
    80003e00:	60e2                	ld	ra,24(sp)
    80003e02:	6442                	ld	s0,16(sp)
    80003e04:	64a2                	ld	s1,8(sp)
    80003e06:	6902                	ld	s2,0(sp)
    80003e08:	6105                	addi	sp,sp,32
    80003e0a:	8082                	ret

0000000080003e0c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e0c:	0001d797          	auipc	a5,0x1d
    80003e10:	4687a783          	lw	a5,1128(a5) # 80021274 <log+0x2c>
    80003e14:	0af05d63          	blez	a5,80003ece <install_trans+0xc2>
{
    80003e18:	7139                	addi	sp,sp,-64
    80003e1a:	fc06                	sd	ra,56(sp)
    80003e1c:	f822                	sd	s0,48(sp)
    80003e1e:	f426                	sd	s1,40(sp)
    80003e20:	f04a                	sd	s2,32(sp)
    80003e22:	ec4e                	sd	s3,24(sp)
    80003e24:	e852                	sd	s4,16(sp)
    80003e26:	e456                	sd	s5,8(sp)
    80003e28:	e05a                	sd	s6,0(sp)
    80003e2a:	0080                	addi	s0,sp,64
    80003e2c:	8b2a                	mv	s6,a0
    80003e2e:	0001da97          	auipc	s5,0x1d
    80003e32:	44aa8a93          	addi	s5,s5,1098 # 80021278 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e36:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e38:	0001d997          	auipc	s3,0x1d
    80003e3c:	41098993          	addi	s3,s3,1040 # 80021248 <log>
    80003e40:	a035                	j	80003e6c <install_trans+0x60>
      bunpin(dbuf);
    80003e42:	8526                	mv	a0,s1
    80003e44:	fffff097          	auipc	ra,0xfffff
    80003e48:	168080e7          	jalr	360(ra) # 80002fac <bunpin>
    brelse(lbuf);
    80003e4c:	854a                	mv	a0,s2
    80003e4e:	fffff097          	auipc	ra,0xfffff
    80003e52:	084080e7          	jalr	132(ra) # 80002ed2 <brelse>
    brelse(dbuf);
    80003e56:	8526                	mv	a0,s1
    80003e58:	fffff097          	auipc	ra,0xfffff
    80003e5c:	07a080e7          	jalr	122(ra) # 80002ed2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e60:	2a05                	addiw	s4,s4,1
    80003e62:	0a91                	addi	s5,s5,4
    80003e64:	02c9a783          	lw	a5,44(s3)
    80003e68:	04fa5963          	bge	s4,a5,80003eba <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e6c:	0189a583          	lw	a1,24(s3)
    80003e70:	014585bb          	addw	a1,a1,s4
    80003e74:	2585                	addiw	a1,a1,1
    80003e76:	0289a503          	lw	a0,40(s3)
    80003e7a:	fffff097          	auipc	ra,0xfffff
    80003e7e:	f28080e7          	jalr	-216(ra) # 80002da2 <bread>
    80003e82:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003e84:	000aa583          	lw	a1,0(s5)
    80003e88:	0289a503          	lw	a0,40(s3)
    80003e8c:	fffff097          	auipc	ra,0xfffff
    80003e90:	f16080e7          	jalr	-234(ra) # 80002da2 <bread>
    80003e94:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e96:	40000613          	li	a2,1024
    80003e9a:	05890593          	addi	a1,s2,88
    80003e9e:	05850513          	addi	a0,a0,88
    80003ea2:	ffffd097          	auipc	ra,0xffffd
    80003ea6:	ed2080e7          	jalr	-302(ra) # 80000d74 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003eaa:	8526                	mv	a0,s1
    80003eac:	fffff097          	auipc	ra,0xfffff
    80003eb0:	fe8080e7          	jalr	-24(ra) # 80002e94 <bwrite>
    if(recovering == 0)
    80003eb4:	f80b1ce3          	bnez	s6,80003e4c <install_trans+0x40>
    80003eb8:	b769                	j	80003e42 <install_trans+0x36>
}
    80003eba:	70e2                	ld	ra,56(sp)
    80003ebc:	7442                	ld	s0,48(sp)
    80003ebe:	74a2                	ld	s1,40(sp)
    80003ec0:	7902                	ld	s2,32(sp)
    80003ec2:	69e2                	ld	s3,24(sp)
    80003ec4:	6a42                	ld	s4,16(sp)
    80003ec6:	6aa2                	ld	s5,8(sp)
    80003ec8:	6b02                	ld	s6,0(sp)
    80003eca:	6121                	addi	sp,sp,64
    80003ecc:	8082                	ret
    80003ece:	8082                	ret

0000000080003ed0 <initlog>:
{
    80003ed0:	7179                	addi	sp,sp,-48
    80003ed2:	f406                	sd	ra,40(sp)
    80003ed4:	f022                	sd	s0,32(sp)
    80003ed6:	ec26                	sd	s1,24(sp)
    80003ed8:	e84a                	sd	s2,16(sp)
    80003eda:	e44e                	sd	s3,8(sp)
    80003edc:	1800                	addi	s0,sp,48
    80003ede:	892a                	mv	s2,a0
    80003ee0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ee2:	0001d497          	auipc	s1,0x1d
    80003ee6:	36648493          	addi	s1,s1,870 # 80021248 <log>
    80003eea:	00004597          	auipc	a1,0x4
    80003eee:	70e58593          	addi	a1,a1,1806 # 800085f8 <syscalls+0x1d8>
    80003ef2:	8526                	mv	a0,s1
    80003ef4:	ffffd097          	auipc	ra,0xffffd
    80003ef8:	c94080e7          	jalr	-876(ra) # 80000b88 <initlock>
  log.start = sb->logstart;
    80003efc:	0149a583          	lw	a1,20(s3)
    80003f00:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f02:	0109a783          	lw	a5,16(s3)
    80003f06:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f08:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f0c:	854a                	mv	a0,s2
    80003f0e:	fffff097          	auipc	ra,0xfffff
    80003f12:	e94080e7          	jalr	-364(ra) # 80002da2 <bread>
  log.lh.n = lh->n;
    80003f16:	4d3c                	lw	a5,88(a0)
    80003f18:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f1a:	02f05563          	blez	a5,80003f44 <initlog+0x74>
    80003f1e:	05c50713          	addi	a4,a0,92
    80003f22:	0001d697          	auipc	a3,0x1d
    80003f26:	35668693          	addi	a3,a3,854 # 80021278 <log+0x30>
    80003f2a:	37fd                	addiw	a5,a5,-1
    80003f2c:	1782                	slli	a5,a5,0x20
    80003f2e:	9381                	srli	a5,a5,0x20
    80003f30:	078a                	slli	a5,a5,0x2
    80003f32:	06050613          	addi	a2,a0,96
    80003f36:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003f38:	4310                	lw	a2,0(a4)
    80003f3a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003f3c:	0711                	addi	a4,a4,4
    80003f3e:	0691                	addi	a3,a3,4
    80003f40:	fef71ce3          	bne	a4,a5,80003f38 <initlog+0x68>
  brelse(buf);
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	f8e080e7          	jalr	-114(ra) # 80002ed2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003f4c:	4505                	li	a0,1
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	ebe080e7          	jalr	-322(ra) # 80003e0c <install_trans>
  log.lh.n = 0;
    80003f56:	0001d797          	auipc	a5,0x1d
    80003f5a:	3007af23          	sw	zero,798(a5) # 80021274 <log+0x2c>
  write_head(); // clear the log
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	e34080e7          	jalr	-460(ra) # 80003d92 <write_head>
}
    80003f66:	70a2                	ld	ra,40(sp)
    80003f68:	7402                	ld	s0,32(sp)
    80003f6a:	64e2                	ld	s1,24(sp)
    80003f6c:	6942                	ld	s2,16(sp)
    80003f6e:	69a2                	ld	s3,8(sp)
    80003f70:	6145                	addi	sp,sp,48
    80003f72:	8082                	ret

0000000080003f74 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f74:	1101                	addi	sp,sp,-32
    80003f76:	ec06                	sd	ra,24(sp)
    80003f78:	e822                	sd	s0,16(sp)
    80003f7a:	e426                	sd	s1,8(sp)
    80003f7c:	e04a                	sd	s2,0(sp)
    80003f7e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f80:	0001d517          	auipc	a0,0x1d
    80003f84:	2c850513          	addi	a0,a0,712 # 80021248 <log>
    80003f88:	ffffd097          	auipc	ra,0xffffd
    80003f8c:	c90080e7          	jalr	-880(ra) # 80000c18 <acquire>
  while(1){
    if(log.committing){
    80003f90:	0001d497          	auipc	s1,0x1d
    80003f94:	2b848493          	addi	s1,s1,696 # 80021248 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f98:	4979                	li	s2,30
    80003f9a:	a039                	j	80003fa8 <begin_op+0x34>
      sleep(&log, &log.lock);
    80003f9c:	85a6                	mv	a1,s1
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	ffffe097          	auipc	ra,0xffffe
    80003fa4:	1e4080e7          	jalr	484(ra) # 80002184 <sleep>
    if(log.committing){
    80003fa8:	50dc                	lw	a5,36(s1)
    80003faa:	fbed                	bnez	a5,80003f9c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003fac:	509c                	lw	a5,32(s1)
    80003fae:	0017871b          	addiw	a4,a5,1
    80003fb2:	0007069b          	sext.w	a3,a4
    80003fb6:	0027179b          	slliw	a5,a4,0x2
    80003fba:	9fb9                	addw	a5,a5,a4
    80003fbc:	0017979b          	slliw	a5,a5,0x1
    80003fc0:	54d8                	lw	a4,44(s1)
    80003fc2:	9fb9                	addw	a5,a5,a4
    80003fc4:	00f95963          	bge	s2,a5,80003fd6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003fc8:	85a6                	mv	a1,s1
    80003fca:	8526                	mv	a0,s1
    80003fcc:	ffffe097          	auipc	ra,0xffffe
    80003fd0:	1b8080e7          	jalr	440(ra) # 80002184 <sleep>
    80003fd4:	bfd1                	j	80003fa8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80003fd6:	0001d517          	auipc	a0,0x1d
    80003fda:	27250513          	addi	a0,a0,626 # 80021248 <log>
    80003fde:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80003fe0:	ffffd097          	auipc	ra,0xffffd
    80003fe4:	cec080e7          	jalr	-788(ra) # 80000ccc <release>
      break;
    }
  }
}
    80003fe8:	60e2                	ld	ra,24(sp)
    80003fea:	6442                	ld	s0,16(sp)
    80003fec:	64a2                	ld	s1,8(sp)
    80003fee:	6902                	ld	s2,0(sp)
    80003ff0:	6105                	addi	sp,sp,32
    80003ff2:	8082                	ret

0000000080003ff4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
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
  int do_commit = 0;

  acquire(&log.lock);
    80004006:	0001d497          	auipc	s1,0x1d
    8000400a:	24248493          	addi	s1,s1,578 # 80021248 <log>
    8000400e:	8526                	mv	a0,s1
    80004010:	ffffd097          	auipc	ra,0xffffd
    80004014:	c08080e7          	jalr	-1016(ra) # 80000c18 <acquire>
  log.outstanding -= 1;
    80004018:	509c                	lw	a5,32(s1)
    8000401a:	37fd                	addiw	a5,a5,-1
    8000401c:	0007891b          	sext.w	s2,a5
    80004020:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004022:	50dc                	lw	a5,36(s1)
    80004024:	efb9                	bnez	a5,80004082 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004026:	06091663          	bnez	s2,80004092 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000402a:	0001d497          	auipc	s1,0x1d
    8000402e:	21e48493          	addi	s1,s1,542 # 80021248 <log>
    80004032:	4785                	li	a5,1
    80004034:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004036:	8526                	mv	a0,s1
    80004038:	ffffd097          	auipc	ra,0xffffd
    8000403c:	c94080e7          	jalr	-876(ra) # 80000ccc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004040:	54dc                	lw	a5,44(s1)
    80004042:	06f04763          	bgtz	a5,800040b0 <end_op+0xbc>
    acquire(&log.lock);
    80004046:	0001d497          	auipc	s1,0x1d
    8000404a:	20248493          	addi	s1,s1,514 # 80021248 <log>
    8000404e:	8526                	mv	a0,s1
    80004050:	ffffd097          	auipc	ra,0xffffd
    80004054:	bc8080e7          	jalr	-1080(ra) # 80000c18 <acquire>
    log.committing = 0;
    80004058:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000405c:	8526                	mv	a0,s1
    8000405e:	ffffe097          	auipc	ra,0xffffe
    80004062:	2ac080e7          	jalr	684(ra) # 8000230a <wakeup>
    release(&log.lock);
    80004066:	8526                	mv	a0,s1
    80004068:	ffffd097          	auipc	ra,0xffffd
    8000406c:	c64080e7          	jalr	-924(ra) # 80000ccc <release>
}
    80004070:	70e2                	ld	ra,56(sp)
    80004072:	7442                	ld	s0,48(sp)
    80004074:	74a2                	ld	s1,40(sp)
    80004076:	7902                	ld	s2,32(sp)
    80004078:	69e2                	ld	s3,24(sp)
    8000407a:	6a42                	ld	s4,16(sp)
    8000407c:	6aa2                	ld	s5,8(sp)
    8000407e:	6121                	addi	sp,sp,64
    80004080:	8082                	ret
    panic("log.committing");
    80004082:	00004517          	auipc	a0,0x4
    80004086:	57e50513          	addi	a0,a0,1406 # 80008600 <syscalls+0x1e0>
    8000408a:	ffffc097          	auipc	ra,0xffffc
    8000408e:	4c6080e7          	jalr	1222(ra) # 80000550 <panic>
    wakeup(&log);
    80004092:	0001d497          	auipc	s1,0x1d
    80004096:	1b648493          	addi	s1,s1,438 # 80021248 <log>
    8000409a:	8526                	mv	a0,s1
    8000409c:	ffffe097          	auipc	ra,0xffffe
    800040a0:	26e080e7          	jalr	622(ra) # 8000230a <wakeup>
  release(&log.lock);
    800040a4:	8526                	mv	a0,s1
    800040a6:	ffffd097          	auipc	ra,0xffffd
    800040aa:	c26080e7          	jalr	-986(ra) # 80000ccc <release>
  if(do_commit){
    800040ae:	b7c9                	j	80004070 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040b0:	0001da97          	auipc	s5,0x1d
    800040b4:	1c8a8a93          	addi	s5,s5,456 # 80021278 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040b8:	0001da17          	auipc	s4,0x1d
    800040bc:	190a0a13          	addi	s4,s4,400 # 80021248 <log>
    800040c0:	018a2583          	lw	a1,24(s4)
    800040c4:	012585bb          	addw	a1,a1,s2
    800040c8:	2585                	addiw	a1,a1,1
    800040ca:	028a2503          	lw	a0,40(s4)
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	cd4080e7          	jalr	-812(ra) # 80002da2 <bread>
    800040d6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800040d8:	000aa583          	lw	a1,0(s5)
    800040dc:	028a2503          	lw	a0,40(s4)
    800040e0:	fffff097          	auipc	ra,0xfffff
    800040e4:	cc2080e7          	jalr	-830(ra) # 80002da2 <bread>
    800040e8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800040ea:	40000613          	li	a2,1024
    800040ee:	05850593          	addi	a1,a0,88
    800040f2:	05848513          	addi	a0,s1,88
    800040f6:	ffffd097          	auipc	ra,0xffffd
    800040fa:	c7e080e7          	jalr	-898(ra) # 80000d74 <memmove>
    bwrite(to);  // write the log
    800040fe:	8526                	mv	a0,s1
    80004100:	fffff097          	auipc	ra,0xfffff
    80004104:	d94080e7          	jalr	-620(ra) # 80002e94 <bwrite>
    brelse(from);
    80004108:	854e                	mv	a0,s3
    8000410a:	fffff097          	auipc	ra,0xfffff
    8000410e:	dc8080e7          	jalr	-568(ra) # 80002ed2 <brelse>
    brelse(to);
    80004112:	8526                	mv	a0,s1
    80004114:	fffff097          	auipc	ra,0xfffff
    80004118:	dbe080e7          	jalr	-578(ra) # 80002ed2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000411c:	2905                	addiw	s2,s2,1
    8000411e:	0a91                	addi	s5,s5,4
    80004120:	02ca2783          	lw	a5,44(s4)
    80004124:	f8f94ee3          	blt	s2,a5,800040c0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004128:	00000097          	auipc	ra,0x0
    8000412c:	c6a080e7          	jalr	-918(ra) # 80003d92 <write_head>
    install_trans(0); // Now install writes to home locations
    80004130:	4501                	li	a0,0
    80004132:	00000097          	auipc	ra,0x0
    80004136:	cda080e7          	jalr	-806(ra) # 80003e0c <install_trans>
    log.lh.n = 0;
    8000413a:	0001d797          	auipc	a5,0x1d
    8000413e:	1207ad23          	sw	zero,314(a5) # 80021274 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004142:	00000097          	auipc	ra,0x0
    80004146:	c50080e7          	jalr	-944(ra) # 80003d92 <write_head>
    8000414a:	bdf5                	j	80004046 <end_op+0x52>

000000008000414c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000414c:	1101                	addi	sp,sp,-32
    8000414e:	ec06                	sd	ra,24(sp)
    80004150:	e822                	sd	s0,16(sp)
    80004152:	e426                	sd	s1,8(sp)
    80004154:	e04a                	sd	s2,0(sp)
    80004156:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004158:	0001d717          	auipc	a4,0x1d
    8000415c:	11c72703          	lw	a4,284(a4) # 80021274 <log+0x2c>
    80004160:	47f5                	li	a5,29
    80004162:	08e7c063          	blt	a5,a4,800041e2 <log_write+0x96>
    80004166:	84aa                	mv	s1,a0
    80004168:	0001d797          	auipc	a5,0x1d
    8000416c:	0fc7a783          	lw	a5,252(a5) # 80021264 <log+0x1c>
    80004170:	37fd                	addiw	a5,a5,-1
    80004172:	06f75863          	bge	a4,a5,800041e2 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004176:	0001d797          	auipc	a5,0x1d
    8000417a:	0f27a783          	lw	a5,242(a5) # 80021268 <log+0x20>
    8000417e:	06f05a63          	blez	a5,800041f2 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004182:	0001d917          	auipc	s2,0x1d
    80004186:	0c690913          	addi	s2,s2,198 # 80021248 <log>
    8000418a:	854a                	mv	a0,s2
    8000418c:	ffffd097          	auipc	ra,0xffffd
    80004190:	a8c080e7          	jalr	-1396(ra) # 80000c18 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004194:	02c92603          	lw	a2,44(s2)
    80004198:	06c05563          	blez	a2,80004202 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000419c:	44cc                	lw	a1,12(s1)
    8000419e:	0001d717          	auipc	a4,0x1d
    800041a2:	0da70713          	addi	a4,a4,218 # 80021278 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041a6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041a8:	4314                	lw	a3,0(a4)
    800041aa:	04b68d63          	beq	a3,a1,80004204 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800041ae:	2785                	addiw	a5,a5,1
    800041b0:	0711                	addi	a4,a4,4
    800041b2:	fec79be3          	bne	a5,a2,800041a8 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041b6:	0621                	addi	a2,a2,8
    800041b8:	060a                	slli	a2,a2,0x2
    800041ba:	0001d797          	auipc	a5,0x1d
    800041be:	08e78793          	addi	a5,a5,142 # 80021248 <log>
    800041c2:	963e                	add	a2,a2,a5
    800041c4:	44dc                	lw	a5,12(s1)
    800041c6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800041c8:	8526                	mv	a0,s1
    800041ca:	fffff097          	auipc	ra,0xfffff
    800041ce:	da6080e7          	jalr	-602(ra) # 80002f70 <bpin>
    log.lh.n++;
    800041d2:	0001d717          	auipc	a4,0x1d
    800041d6:	07670713          	addi	a4,a4,118 # 80021248 <log>
    800041da:	575c                	lw	a5,44(a4)
    800041dc:	2785                	addiw	a5,a5,1
    800041de:	d75c                	sw	a5,44(a4)
    800041e0:	a83d                	j	8000421e <log_write+0xd2>
    panic("too big a transaction");
    800041e2:	00004517          	auipc	a0,0x4
    800041e6:	42e50513          	addi	a0,a0,1070 # 80008610 <syscalls+0x1f0>
    800041ea:	ffffc097          	auipc	ra,0xffffc
    800041ee:	366080e7          	jalr	870(ra) # 80000550 <panic>
    panic("log_write outside of trans");
    800041f2:	00004517          	auipc	a0,0x4
    800041f6:	43650513          	addi	a0,a0,1078 # 80008628 <syscalls+0x208>
    800041fa:	ffffc097          	auipc	ra,0xffffc
    800041fe:	356080e7          	jalr	854(ra) # 80000550 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004202:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004204:	00878713          	addi	a4,a5,8
    80004208:	00271693          	slli	a3,a4,0x2
    8000420c:	0001d717          	auipc	a4,0x1d
    80004210:	03c70713          	addi	a4,a4,60 # 80021248 <log>
    80004214:	9736                	add	a4,a4,a3
    80004216:	44d4                	lw	a3,12(s1)
    80004218:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000421a:	faf607e3          	beq	a2,a5,800041c8 <log_write+0x7c>
  }
  release(&log.lock);
    8000421e:	0001d517          	auipc	a0,0x1d
    80004222:	02a50513          	addi	a0,a0,42 # 80021248 <log>
    80004226:	ffffd097          	auipc	ra,0xffffd
    8000422a:	aa6080e7          	jalr	-1370(ra) # 80000ccc <release>
}
    8000422e:	60e2                	ld	ra,24(sp)
    80004230:	6442                	ld	s0,16(sp)
    80004232:	64a2                	ld	s1,8(sp)
    80004234:	6902                	ld	s2,0(sp)
    80004236:	6105                	addi	sp,sp,32
    80004238:	8082                	ret

000000008000423a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000423a:	1101                	addi	sp,sp,-32
    8000423c:	ec06                	sd	ra,24(sp)
    8000423e:	e822                	sd	s0,16(sp)
    80004240:	e426                	sd	s1,8(sp)
    80004242:	e04a                	sd	s2,0(sp)
    80004244:	1000                	addi	s0,sp,32
    80004246:	84aa                	mv	s1,a0
    80004248:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000424a:	00004597          	auipc	a1,0x4
    8000424e:	3fe58593          	addi	a1,a1,1022 # 80008648 <syscalls+0x228>
    80004252:	0521                	addi	a0,a0,8
    80004254:	ffffd097          	auipc	ra,0xffffd
    80004258:	934080e7          	jalr	-1740(ra) # 80000b88 <initlock>
  lk->name = name;
    8000425c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004260:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004264:	0204a423          	sw	zero,40(s1)
}
    80004268:	60e2                	ld	ra,24(sp)
    8000426a:	6442                	ld	s0,16(sp)
    8000426c:	64a2                	ld	s1,8(sp)
    8000426e:	6902                	ld	s2,0(sp)
    80004270:	6105                	addi	sp,sp,32
    80004272:	8082                	ret

0000000080004274 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004274:	1101                	addi	sp,sp,-32
    80004276:	ec06                	sd	ra,24(sp)
    80004278:	e822                	sd	s0,16(sp)
    8000427a:	e426                	sd	s1,8(sp)
    8000427c:	e04a                	sd	s2,0(sp)
    8000427e:	1000                	addi	s0,sp,32
    80004280:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004282:	00850913          	addi	s2,a0,8
    80004286:	854a                	mv	a0,s2
    80004288:	ffffd097          	auipc	ra,0xffffd
    8000428c:	990080e7          	jalr	-1648(ra) # 80000c18 <acquire>
  while (lk->locked) {
    80004290:	409c                	lw	a5,0(s1)
    80004292:	cb89                	beqz	a5,800042a4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004294:	85ca                	mv	a1,s2
    80004296:	8526                	mv	a0,s1
    80004298:	ffffe097          	auipc	ra,0xffffe
    8000429c:	eec080e7          	jalr	-276(ra) # 80002184 <sleep>
  while (lk->locked) {
    800042a0:	409c                	lw	a5,0(s1)
    800042a2:	fbed                	bnez	a5,80004294 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800042a4:	4785                	li	a5,1
    800042a6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	6cc080e7          	jalr	1740(ra) # 80001974 <myproc>
    800042b0:	5d1c                	lw	a5,56(a0)
    800042b2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800042b4:	854a                	mv	a0,s2
    800042b6:	ffffd097          	auipc	ra,0xffffd
    800042ba:	a16080e7          	jalr	-1514(ra) # 80000ccc <release>
}
    800042be:	60e2                	ld	ra,24(sp)
    800042c0:	6442                	ld	s0,16(sp)
    800042c2:	64a2                	ld	s1,8(sp)
    800042c4:	6902                	ld	s2,0(sp)
    800042c6:	6105                	addi	sp,sp,32
    800042c8:	8082                	ret

00000000800042ca <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800042ca:	1101                	addi	sp,sp,-32
    800042cc:	ec06                	sd	ra,24(sp)
    800042ce:	e822                	sd	s0,16(sp)
    800042d0:	e426                	sd	s1,8(sp)
    800042d2:	e04a                	sd	s2,0(sp)
    800042d4:	1000                	addi	s0,sp,32
    800042d6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042d8:	00850913          	addi	s2,a0,8
    800042dc:	854a                	mv	a0,s2
    800042de:	ffffd097          	auipc	ra,0xffffd
    800042e2:	93a080e7          	jalr	-1734(ra) # 80000c18 <acquire>
  lk->locked = 0;
    800042e6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042ea:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800042ee:	8526                	mv	a0,s1
    800042f0:	ffffe097          	auipc	ra,0xffffe
    800042f4:	01a080e7          	jalr	26(ra) # 8000230a <wakeup>
  release(&lk->lk);
    800042f8:	854a                	mv	a0,s2
    800042fa:	ffffd097          	auipc	ra,0xffffd
    800042fe:	9d2080e7          	jalr	-1582(ra) # 80000ccc <release>
}
    80004302:	60e2                	ld	ra,24(sp)
    80004304:	6442                	ld	s0,16(sp)
    80004306:	64a2                	ld	s1,8(sp)
    80004308:	6902                	ld	s2,0(sp)
    8000430a:	6105                	addi	sp,sp,32
    8000430c:	8082                	ret

000000008000430e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000430e:	7179                	addi	sp,sp,-48
    80004310:	f406                	sd	ra,40(sp)
    80004312:	f022                	sd	s0,32(sp)
    80004314:	ec26                	sd	s1,24(sp)
    80004316:	e84a                	sd	s2,16(sp)
    80004318:	e44e                	sd	s3,8(sp)
    8000431a:	1800                	addi	s0,sp,48
    8000431c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000431e:	00850913          	addi	s2,a0,8
    80004322:	854a                	mv	a0,s2
    80004324:	ffffd097          	auipc	ra,0xffffd
    80004328:	8f4080e7          	jalr	-1804(ra) # 80000c18 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000432c:	409c                	lw	a5,0(s1)
    8000432e:	ef99                	bnez	a5,8000434c <holdingsleep+0x3e>
    80004330:	4481                	li	s1,0
  release(&lk->lk);
    80004332:	854a                	mv	a0,s2
    80004334:	ffffd097          	auipc	ra,0xffffd
    80004338:	998080e7          	jalr	-1640(ra) # 80000ccc <release>
  return r;
}
    8000433c:	8526                	mv	a0,s1
    8000433e:	70a2                	ld	ra,40(sp)
    80004340:	7402                	ld	s0,32(sp)
    80004342:	64e2                	ld	s1,24(sp)
    80004344:	6942                	ld	s2,16(sp)
    80004346:	69a2                	ld	s3,8(sp)
    80004348:	6145                	addi	sp,sp,48
    8000434a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000434c:	0284a983          	lw	s3,40(s1)
    80004350:	ffffd097          	auipc	ra,0xffffd
    80004354:	624080e7          	jalr	1572(ra) # 80001974 <myproc>
    80004358:	5d04                	lw	s1,56(a0)
    8000435a:	413484b3          	sub	s1,s1,s3
    8000435e:	0014b493          	seqz	s1,s1
    80004362:	bfc1                	j	80004332 <holdingsleep+0x24>

0000000080004364 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004364:	1141                	addi	sp,sp,-16
    80004366:	e406                	sd	ra,8(sp)
    80004368:	e022                	sd	s0,0(sp)
    8000436a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000436c:	00004597          	auipc	a1,0x4
    80004370:	2ec58593          	addi	a1,a1,748 # 80008658 <syscalls+0x238>
    80004374:	0001d517          	auipc	a0,0x1d
    80004378:	01c50513          	addi	a0,a0,28 # 80021390 <ftable>
    8000437c:	ffffd097          	auipc	ra,0xffffd
    80004380:	80c080e7          	jalr	-2036(ra) # 80000b88 <initlock>
}
    80004384:	60a2                	ld	ra,8(sp)
    80004386:	6402                	ld	s0,0(sp)
    80004388:	0141                	addi	sp,sp,16
    8000438a:	8082                	ret

000000008000438c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000438c:	1101                	addi	sp,sp,-32
    8000438e:	ec06                	sd	ra,24(sp)
    80004390:	e822                	sd	s0,16(sp)
    80004392:	e426                	sd	s1,8(sp)
    80004394:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004396:	0001d517          	auipc	a0,0x1d
    8000439a:	ffa50513          	addi	a0,a0,-6 # 80021390 <ftable>
    8000439e:	ffffd097          	auipc	ra,0xffffd
    800043a2:	87a080e7          	jalr	-1926(ra) # 80000c18 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043a6:	0001d497          	auipc	s1,0x1d
    800043aa:	00248493          	addi	s1,s1,2 # 800213a8 <ftable+0x18>
    800043ae:	0001e717          	auipc	a4,0x1e
    800043b2:	f9a70713          	addi	a4,a4,-102 # 80022348 <ftable+0xfb8>
    if(f->ref == 0){
    800043b6:	40dc                	lw	a5,4(s1)
    800043b8:	cf99                	beqz	a5,800043d6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043ba:	02848493          	addi	s1,s1,40
    800043be:	fee49ce3          	bne	s1,a4,800043b6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800043c2:	0001d517          	auipc	a0,0x1d
    800043c6:	fce50513          	addi	a0,a0,-50 # 80021390 <ftable>
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	902080e7          	jalr	-1790(ra) # 80000ccc <release>
  return 0;
    800043d2:	4481                	li	s1,0
    800043d4:	a819                	j	800043ea <filealloc+0x5e>
      f->ref = 1;
    800043d6:	4785                	li	a5,1
    800043d8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800043da:	0001d517          	auipc	a0,0x1d
    800043de:	fb650513          	addi	a0,a0,-74 # 80021390 <ftable>
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	8ea080e7          	jalr	-1814(ra) # 80000ccc <release>
}
    800043ea:	8526                	mv	a0,s1
    800043ec:	60e2                	ld	ra,24(sp)
    800043ee:	6442                	ld	s0,16(sp)
    800043f0:	64a2                	ld	s1,8(sp)
    800043f2:	6105                	addi	sp,sp,32
    800043f4:	8082                	ret

00000000800043f6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800043f6:	1101                	addi	sp,sp,-32
    800043f8:	ec06                	sd	ra,24(sp)
    800043fa:	e822                	sd	s0,16(sp)
    800043fc:	e426                	sd	s1,8(sp)
    800043fe:	1000                	addi	s0,sp,32
    80004400:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004402:	0001d517          	auipc	a0,0x1d
    80004406:	f8e50513          	addi	a0,a0,-114 # 80021390 <ftable>
    8000440a:	ffffd097          	auipc	ra,0xffffd
    8000440e:	80e080e7          	jalr	-2034(ra) # 80000c18 <acquire>
  if(f->ref < 1)
    80004412:	40dc                	lw	a5,4(s1)
    80004414:	02f05263          	blez	a5,80004438 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004418:	2785                	addiw	a5,a5,1
    8000441a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000441c:	0001d517          	auipc	a0,0x1d
    80004420:	f7450513          	addi	a0,a0,-140 # 80021390 <ftable>
    80004424:	ffffd097          	auipc	ra,0xffffd
    80004428:	8a8080e7          	jalr	-1880(ra) # 80000ccc <release>
  return f;
}
    8000442c:	8526                	mv	a0,s1
    8000442e:	60e2                	ld	ra,24(sp)
    80004430:	6442                	ld	s0,16(sp)
    80004432:	64a2                	ld	s1,8(sp)
    80004434:	6105                	addi	sp,sp,32
    80004436:	8082                	ret
    panic("filedup");
    80004438:	00004517          	auipc	a0,0x4
    8000443c:	22850513          	addi	a0,a0,552 # 80008660 <syscalls+0x240>
    80004440:	ffffc097          	auipc	ra,0xffffc
    80004444:	110080e7          	jalr	272(ra) # 80000550 <panic>

0000000080004448 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004448:	7139                	addi	sp,sp,-64
    8000444a:	fc06                	sd	ra,56(sp)
    8000444c:	f822                	sd	s0,48(sp)
    8000444e:	f426                	sd	s1,40(sp)
    80004450:	f04a                	sd	s2,32(sp)
    80004452:	ec4e                	sd	s3,24(sp)
    80004454:	e852                	sd	s4,16(sp)
    80004456:	e456                	sd	s5,8(sp)
    80004458:	0080                	addi	s0,sp,64
    8000445a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000445c:	0001d517          	auipc	a0,0x1d
    80004460:	f3450513          	addi	a0,a0,-204 # 80021390 <ftable>
    80004464:	ffffc097          	auipc	ra,0xffffc
    80004468:	7b4080e7          	jalr	1972(ra) # 80000c18 <acquire>
  if(f->ref < 1)
    8000446c:	40dc                	lw	a5,4(s1)
    8000446e:	06f05163          	blez	a5,800044d0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004472:	37fd                	addiw	a5,a5,-1
    80004474:	0007871b          	sext.w	a4,a5
    80004478:	c0dc                	sw	a5,4(s1)
    8000447a:	06e04363          	bgtz	a4,800044e0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000447e:	0004a903          	lw	s2,0(s1)
    80004482:	0094ca83          	lbu	s5,9(s1)
    80004486:	0104ba03          	ld	s4,16(s1)
    8000448a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000448e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004492:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004496:	0001d517          	auipc	a0,0x1d
    8000449a:	efa50513          	addi	a0,a0,-262 # 80021390 <ftable>
    8000449e:	ffffd097          	auipc	ra,0xffffd
    800044a2:	82e080e7          	jalr	-2002(ra) # 80000ccc <release>

  if(ff.type == FD_PIPE){
    800044a6:	4785                	li	a5,1
    800044a8:	04f90d63          	beq	s2,a5,80004502 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044ac:	3979                	addiw	s2,s2,-2
    800044ae:	4785                	li	a5,1
    800044b0:	0527e063          	bltu	a5,s2,800044f0 <fileclose+0xa8>
    begin_op();
    800044b4:	00000097          	auipc	ra,0x0
    800044b8:	ac0080e7          	jalr	-1344(ra) # 80003f74 <begin_op>
    iput(ff.ip);
    800044bc:	854e                	mv	a0,s3
    800044be:	fffff097          	auipc	ra,0xfffff
    800044c2:	2a0080e7          	jalr	672(ra) # 8000375e <iput>
    end_op();
    800044c6:	00000097          	auipc	ra,0x0
    800044ca:	b2e080e7          	jalr	-1234(ra) # 80003ff4 <end_op>
    800044ce:	a00d                	j	800044f0 <fileclose+0xa8>
    panic("fileclose");
    800044d0:	00004517          	auipc	a0,0x4
    800044d4:	19850513          	addi	a0,a0,408 # 80008668 <syscalls+0x248>
    800044d8:	ffffc097          	auipc	ra,0xffffc
    800044dc:	078080e7          	jalr	120(ra) # 80000550 <panic>
    release(&ftable.lock);
    800044e0:	0001d517          	auipc	a0,0x1d
    800044e4:	eb050513          	addi	a0,a0,-336 # 80021390 <ftable>
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	7e4080e7          	jalr	2020(ra) # 80000ccc <release>
  }
}
    800044f0:	70e2                	ld	ra,56(sp)
    800044f2:	7442                	ld	s0,48(sp)
    800044f4:	74a2                	ld	s1,40(sp)
    800044f6:	7902                	ld	s2,32(sp)
    800044f8:	69e2                	ld	s3,24(sp)
    800044fa:	6a42                	ld	s4,16(sp)
    800044fc:	6aa2                	ld	s5,8(sp)
    800044fe:	6121                	addi	sp,sp,64
    80004500:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004502:	85d6                	mv	a1,s5
    80004504:	8552                	mv	a0,s4
    80004506:	00000097          	auipc	ra,0x0
    8000450a:	372080e7          	jalr	882(ra) # 80004878 <pipeclose>
    8000450e:	b7cd                	j	800044f0 <fileclose+0xa8>

0000000080004510 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004510:	715d                	addi	sp,sp,-80
    80004512:	e486                	sd	ra,72(sp)
    80004514:	e0a2                	sd	s0,64(sp)
    80004516:	fc26                	sd	s1,56(sp)
    80004518:	f84a                	sd	s2,48(sp)
    8000451a:	f44e                	sd	s3,40(sp)
    8000451c:	0880                	addi	s0,sp,80
    8000451e:	84aa                	mv	s1,a0
    80004520:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004522:	ffffd097          	auipc	ra,0xffffd
    80004526:	452080e7          	jalr	1106(ra) # 80001974 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000452a:	409c                	lw	a5,0(s1)
    8000452c:	37f9                	addiw	a5,a5,-2
    8000452e:	4705                	li	a4,1
    80004530:	04f76763          	bltu	a4,a5,8000457e <filestat+0x6e>
    80004534:	892a                	mv	s2,a0
    ilock(f->ip);
    80004536:	6c88                	ld	a0,24(s1)
    80004538:	fffff097          	auipc	ra,0xfffff
    8000453c:	06c080e7          	jalr	108(ra) # 800035a4 <ilock>
    stati(f->ip, &st);
    80004540:	fb840593          	addi	a1,s0,-72
    80004544:	6c88                	ld	a0,24(s1)
    80004546:	fffff097          	auipc	ra,0xfffff
    8000454a:	2e8080e7          	jalr	744(ra) # 8000382e <stati>
    iunlock(f->ip);
    8000454e:	6c88                	ld	a0,24(s1)
    80004550:	fffff097          	auipc	ra,0xfffff
    80004554:	116080e7          	jalr	278(ra) # 80003666 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004558:	46e1                	li	a3,24
    8000455a:	fb840613          	addi	a2,s0,-72
    8000455e:	85ce                	mv	a1,s3
    80004560:	05093503          	ld	a0,80(s2)
    80004564:	ffffd097          	auipc	ra,0xffffd
    80004568:	104080e7          	jalr	260(ra) # 80001668 <copyout>
    8000456c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004570:	60a6                	ld	ra,72(sp)
    80004572:	6406                	ld	s0,64(sp)
    80004574:	74e2                	ld	s1,56(sp)
    80004576:	7942                	ld	s2,48(sp)
    80004578:	79a2                	ld	s3,40(sp)
    8000457a:	6161                	addi	sp,sp,80
    8000457c:	8082                	ret
  return -1;
    8000457e:	557d                	li	a0,-1
    80004580:	bfc5                	j	80004570 <filestat+0x60>

0000000080004582 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004582:	7179                	addi	sp,sp,-48
    80004584:	f406                	sd	ra,40(sp)
    80004586:	f022                	sd	s0,32(sp)
    80004588:	ec26                	sd	s1,24(sp)
    8000458a:	e84a                	sd	s2,16(sp)
    8000458c:	e44e                	sd	s3,8(sp)
    8000458e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004590:	00854783          	lbu	a5,8(a0)
    80004594:	c3d5                	beqz	a5,80004638 <fileread+0xb6>
    80004596:	84aa                	mv	s1,a0
    80004598:	89ae                	mv	s3,a1
    8000459a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000459c:	411c                	lw	a5,0(a0)
    8000459e:	4705                	li	a4,1
    800045a0:	04e78963          	beq	a5,a4,800045f2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045a4:	470d                	li	a4,3
    800045a6:	04e78d63          	beq	a5,a4,80004600 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045aa:	4709                	li	a4,2
    800045ac:	06e79e63          	bne	a5,a4,80004628 <fileread+0xa6>
    ilock(f->ip);
    800045b0:	6d08                	ld	a0,24(a0)
    800045b2:	fffff097          	auipc	ra,0xfffff
    800045b6:	ff2080e7          	jalr	-14(ra) # 800035a4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800045ba:	874a                	mv	a4,s2
    800045bc:	5094                	lw	a3,32(s1)
    800045be:	864e                	mv	a2,s3
    800045c0:	4585                	li	a1,1
    800045c2:	6c88                	ld	a0,24(s1)
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	294080e7          	jalr	660(ra) # 80003858 <readi>
    800045cc:	892a                	mv	s2,a0
    800045ce:	00a05563          	blez	a0,800045d8 <fileread+0x56>
      f->off += r;
    800045d2:	509c                	lw	a5,32(s1)
    800045d4:	9fa9                	addw	a5,a5,a0
    800045d6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800045d8:	6c88                	ld	a0,24(s1)
    800045da:	fffff097          	auipc	ra,0xfffff
    800045de:	08c080e7          	jalr	140(ra) # 80003666 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800045e2:	854a                	mv	a0,s2
    800045e4:	70a2                	ld	ra,40(sp)
    800045e6:	7402                	ld	s0,32(sp)
    800045e8:	64e2                	ld	s1,24(sp)
    800045ea:	6942                	ld	s2,16(sp)
    800045ec:	69a2                	ld	s3,8(sp)
    800045ee:	6145                	addi	sp,sp,48
    800045f0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800045f2:	6908                	ld	a0,16(a0)
    800045f4:	00000097          	auipc	ra,0x0
    800045f8:	418080e7          	jalr	1048(ra) # 80004a0c <piperead>
    800045fc:	892a                	mv	s2,a0
    800045fe:	b7d5                	j	800045e2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004600:	02451783          	lh	a5,36(a0)
    80004604:	03079693          	slli	a3,a5,0x30
    80004608:	92c1                	srli	a3,a3,0x30
    8000460a:	4725                	li	a4,9
    8000460c:	02d76863          	bltu	a4,a3,8000463c <fileread+0xba>
    80004610:	0792                	slli	a5,a5,0x4
    80004612:	0001d717          	auipc	a4,0x1d
    80004616:	cde70713          	addi	a4,a4,-802 # 800212f0 <devsw>
    8000461a:	97ba                	add	a5,a5,a4
    8000461c:	639c                	ld	a5,0(a5)
    8000461e:	c38d                	beqz	a5,80004640 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004620:	4505                	li	a0,1
    80004622:	9782                	jalr	a5
    80004624:	892a                	mv	s2,a0
    80004626:	bf75                	j	800045e2 <fileread+0x60>
    panic("fileread");
    80004628:	00004517          	auipc	a0,0x4
    8000462c:	05050513          	addi	a0,a0,80 # 80008678 <syscalls+0x258>
    80004630:	ffffc097          	auipc	ra,0xffffc
    80004634:	f20080e7          	jalr	-224(ra) # 80000550 <panic>
    return -1;
    80004638:	597d                	li	s2,-1
    8000463a:	b765                	j	800045e2 <fileread+0x60>
      return -1;
    8000463c:	597d                	li	s2,-1
    8000463e:	b755                	j	800045e2 <fileread+0x60>
    80004640:	597d                	li	s2,-1
    80004642:	b745                	j	800045e2 <fileread+0x60>

0000000080004644 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004644:	00954783          	lbu	a5,9(a0)
    80004648:	14078563          	beqz	a5,80004792 <filewrite+0x14e>
{
    8000464c:	715d                	addi	sp,sp,-80
    8000464e:	e486                	sd	ra,72(sp)
    80004650:	e0a2                	sd	s0,64(sp)
    80004652:	fc26                	sd	s1,56(sp)
    80004654:	f84a                	sd	s2,48(sp)
    80004656:	f44e                	sd	s3,40(sp)
    80004658:	f052                	sd	s4,32(sp)
    8000465a:	ec56                	sd	s5,24(sp)
    8000465c:	e85a                	sd	s6,16(sp)
    8000465e:	e45e                	sd	s7,8(sp)
    80004660:	e062                	sd	s8,0(sp)
    80004662:	0880                	addi	s0,sp,80
    80004664:	892a                	mv	s2,a0
    80004666:	8aae                	mv	s5,a1
    80004668:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000466a:	411c                	lw	a5,0(a0)
    8000466c:	4705                	li	a4,1
    8000466e:	02e78263          	beq	a5,a4,80004692 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004672:	470d                	li	a4,3
    80004674:	02e78563          	beq	a5,a4,8000469e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004678:	4709                	li	a4,2
    8000467a:	10e79463          	bne	a5,a4,80004782 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000467e:	0ec05e63          	blez	a2,8000477a <filewrite+0x136>
    int i = 0;
    80004682:	4981                	li	s3,0
    80004684:	6b05                	lui	s6,0x1
    80004686:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000468a:	6b85                	lui	s7,0x1
    8000468c:	c00b8b9b          	addiw	s7,s7,-1024
    80004690:	a851                	j	80004724 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004692:	6908                	ld	a0,16(a0)
    80004694:	00000097          	auipc	ra,0x0
    80004698:	254080e7          	jalr	596(ra) # 800048e8 <pipewrite>
    8000469c:	a85d                	j	80004752 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000469e:	02451783          	lh	a5,36(a0)
    800046a2:	03079693          	slli	a3,a5,0x30
    800046a6:	92c1                	srli	a3,a3,0x30
    800046a8:	4725                	li	a4,9
    800046aa:	0ed76663          	bltu	a4,a3,80004796 <filewrite+0x152>
    800046ae:	0792                	slli	a5,a5,0x4
    800046b0:	0001d717          	auipc	a4,0x1d
    800046b4:	c4070713          	addi	a4,a4,-960 # 800212f0 <devsw>
    800046b8:	97ba                	add	a5,a5,a4
    800046ba:	679c                	ld	a5,8(a5)
    800046bc:	cff9                	beqz	a5,8000479a <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    800046be:	4505                	li	a0,1
    800046c0:	9782                	jalr	a5
    800046c2:	a841                	j	80004752 <filewrite+0x10e>
    800046c4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800046c8:	00000097          	auipc	ra,0x0
    800046cc:	8ac080e7          	jalr	-1876(ra) # 80003f74 <begin_op>
      ilock(f->ip);
    800046d0:	01893503          	ld	a0,24(s2)
    800046d4:	fffff097          	auipc	ra,0xfffff
    800046d8:	ed0080e7          	jalr	-304(ra) # 800035a4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800046dc:	8762                	mv	a4,s8
    800046de:	02092683          	lw	a3,32(s2)
    800046e2:	01598633          	add	a2,s3,s5
    800046e6:	4585                	li	a1,1
    800046e8:	01893503          	ld	a0,24(s2)
    800046ec:	fffff097          	auipc	ra,0xfffff
    800046f0:	264080e7          	jalr	612(ra) # 80003950 <writei>
    800046f4:	84aa                	mv	s1,a0
    800046f6:	02a05f63          	blez	a0,80004734 <filewrite+0xf0>
        f->off += r;
    800046fa:	02092783          	lw	a5,32(s2)
    800046fe:	9fa9                	addw	a5,a5,a0
    80004700:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004704:	01893503          	ld	a0,24(s2)
    80004708:	fffff097          	auipc	ra,0xfffff
    8000470c:	f5e080e7          	jalr	-162(ra) # 80003666 <iunlock>
      end_op();
    80004710:	00000097          	auipc	ra,0x0
    80004714:	8e4080e7          	jalr	-1820(ra) # 80003ff4 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004718:	049c1963          	bne	s8,s1,8000476a <filewrite+0x126>
        panic("short filewrite");
      i += r;
    8000471c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004720:	0349d663          	bge	s3,s4,8000474c <filewrite+0x108>
      int n1 = n - i;
    80004724:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004728:	84be                	mv	s1,a5
    8000472a:	2781                	sext.w	a5,a5
    8000472c:	f8fb5ce3          	bge	s6,a5,800046c4 <filewrite+0x80>
    80004730:	84de                	mv	s1,s7
    80004732:	bf49                	j	800046c4 <filewrite+0x80>
      iunlock(f->ip);
    80004734:	01893503          	ld	a0,24(s2)
    80004738:	fffff097          	auipc	ra,0xfffff
    8000473c:	f2e080e7          	jalr	-210(ra) # 80003666 <iunlock>
      end_op();
    80004740:	00000097          	auipc	ra,0x0
    80004744:	8b4080e7          	jalr	-1868(ra) # 80003ff4 <end_op>
      if(r < 0)
    80004748:	fc04d8e3          	bgez	s1,80004718 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    8000474c:	8552                	mv	a0,s4
    8000474e:	033a1863          	bne	s4,s3,8000477e <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004752:	60a6                	ld	ra,72(sp)
    80004754:	6406                	ld	s0,64(sp)
    80004756:	74e2                	ld	s1,56(sp)
    80004758:	7942                	ld	s2,48(sp)
    8000475a:	79a2                	ld	s3,40(sp)
    8000475c:	7a02                	ld	s4,32(sp)
    8000475e:	6ae2                	ld	s5,24(sp)
    80004760:	6b42                	ld	s6,16(sp)
    80004762:	6ba2                	ld	s7,8(sp)
    80004764:	6c02                	ld	s8,0(sp)
    80004766:	6161                	addi	sp,sp,80
    80004768:	8082                	ret
        panic("short filewrite");
    8000476a:	00004517          	auipc	a0,0x4
    8000476e:	f1e50513          	addi	a0,a0,-226 # 80008688 <syscalls+0x268>
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	dde080e7          	jalr	-546(ra) # 80000550 <panic>
    int i = 0;
    8000477a:	4981                	li	s3,0
    8000477c:	bfc1                	j	8000474c <filewrite+0x108>
    ret = (i == n ? n : -1);
    8000477e:	557d                	li	a0,-1
    80004780:	bfc9                	j	80004752 <filewrite+0x10e>
    panic("filewrite");
    80004782:	00004517          	auipc	a0,0x4
    80004786:	f1650513          	addi	a0,a0,-234 # 80008698 <syscalls+0x278>
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	dc6080e7          	jalr	-570(ra) # 80000550 <panic>
    return -1;
    80004792:	557d                	li	a0,-1
}
    80004794:	8082                	ret
      return -1;
    80004796:	557d                	li	a0,-1
    80004798:	bf6d                	j	80004752 <filewrite+0x10e>
    8000479a:	557d                	li	a0,-1
    8000479c:	bf5d                	j	80004752 <filewrite+0x10e>

000000008000479e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000479e:	7179                	addi	sp,sp,-48
    800047a0:	f406                	sd	ra,40(sp)
    800047a2:	f022                	sd	s0,32(sp)
    800047a4:	ec26                	sd	s1,24(sp)
    800047a6:	e84a                	sd	s2,16(sp)
    800047a8:	e44e                	sd	s3,8(sp)
    800047aa:	e052                	sd	s4,0(sp)
    800047ac:	1800                	addi	s0,sp,48
    800047ae:	84aa                	mv	s1,a0
    800047b0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047b2:	0005b023          	sd	zero,0(a1)
    800047b6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800047ba:	00000097          	auipc	ra,0x0
    800047be:	bd2080e7          	jalr	-1070(ra) # 8000438c <filealloc>
    800047c2:	e088                	sd	a0,0(s1)
    800047c4:	c551                	beqz	a0,80004850 <pipealloc+0xb2>
    800047c6:	00000097          	auipc	ra,0x0
    800047ca:	bc6080e7          	jalr	-1082(ra) # 8000438c <filealloc>
    800047ce:	00aa3023          	sd	a0,0(s4)
    800047d2:	c92d                	beqz	a0,80004844 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800047d4:	ffffc097          	auipc	ra,0xffffc
    800047d8:	354080e7          	jalr	852(ra) # 80000b28 <kalloc>
    800047dc:	892a                	mv	s2,a0
    800047de:	c125                	beqz	a0,8000483e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800047e0:	4985                	li	s3,1
    800047e2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800047e6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800047ea:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800047ee:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800047f2:	00004597          	auipc	a1,0x4
    800047f6:	eb658593          	addi	a1,a1,-330 # 800086a8 <syscalls+0x288>
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	38e080e7          	jalr	910(ra) # 80000b88 <initlock>
  (*f0)->type = FD_PIPE;
    80004802:	609c                	ld	a5,0(s1)
    80004804:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004808:	609c                	ld	a5,0(s1)
    8000480a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000480e:	609c                	ld	a5,0(s1)
    80004810:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004814:	609c                	ld	a5,0(s1)
    80004816:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000481a:	000a3783          	ld	a5,0(s4)
    8000481e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004822:	000a3783          	ld	a5,0(s4)
    80004826:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000482a:	000a3783          	ld	a5,0(s4)
    8000482e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004832:	000a3783          	ld	a5,0(s4)
    80004836:	0127b823          	sd	s2,16(a5)
  return 0;
    8000483a:	4501                	li	a0,0
    8000483c:	a025                	j	80004864 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000483e:	6088                	ld	a0,0(s1)
    80004840:	e501                	bnez	a0,80004848 <pipealloc+0xaa>
    80004842:	a039                	j	80004850 <pipealloc+0xb2>
    80004844:	6088                	ld	a0,0(s1)
    80004846:	c51d                	beqz	a0,80004874 <pipealloc+0xd6>
    fileclose(*f0);
    80004848:	00000097          	auipc	ra,0x0
    8000484c:	c00080e7          	jalr	-1024(ra) # 80004448 <fileclose>
  if(*f1)
    80004850:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004854:	557d                	li	a0,-1
  if(*f1)
    80004856:	c799                	beqz	a5,80004864 <pipealloc+0xc6>
    fileclose(*f1);
    80004858:	853e                	mv	a0,a5
    8000485a:	00000097          	auipc	ra,0x0
    8000485e:	bee080e7          	jalr	-1042(ra) # 80004448 <fileclose>
  return -1;
    80004862:	557d                	li	a0,-1
}
    80004864:	70a2                	ld	ra,40(sp)
    80004866:	7402                	ld	s0,32(sp)
    80004868:	64e2                	ld	s1,24(sp)
    8000486a:	6942                	ld	s2,16(sp)
    8000486c:	69a2                	ld	s3,8(sp)
    8000486e:	6a02                	ld	s4,0(sp)
    80004870:	6145                	addi	sp,sp,48
    80004872:	8082                	ret
  return -1;
    80004874:	557d                	li	a0,-1
    80004876:	b7fd                	j	80004864 <pipealloc+0xc6>

0000000080004878 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004878:	1101                	addi	sp,sp,-32
    8000487a:	ec06                	sd	ra,24(sp)
    8000487c:	e822                	sd	s0,16(sp)
    8000487e:	e426                	sd	s1,8(sp)
    80004880:	e04a                	sd	s2,0(sp)
    80004882:	1000                	addi	s0,sp,32
    80004884:	84aa                	mv	s1,a0
    80004886:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004888:	ffffc097          	auipc	ra,0xffffc
    8000488c:	390080e7          	jalr	912(ra) # 80000c18 <acquire>
  if(writable){
    80004890:	02090d63          	beqz	s2,800048ca <pipeclose+0x52>
    pi->writeopen = 0;
    80004894:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004898:	21848513          	addi	a0,s1,536
    8000489c:	ffffe097          	auipc	ra,0xffffe
    800048a0:	a6e080e7          	jalr	-1426(ra) # 8000230a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800048a4:	2204b783          	ld	a5,544(s1)
    800048a8:	eb95                	bnez	a5,800048dc <pipeclose+0x64>
    release(&pi->lock);
    800048aa:	8526                	mv	a0,s1
    800048ac:	ffffc097          	auipc	ra,0xffffc
    800048b0:	420080e7          	jalr	1056(ra) # 80000ccc <release>
    kfree((char*)pi);
    800048b4:	8526                	mv	a0,s1
    800048b6:	ffffc097          	auipc	ra,0xffffc
    800048ba:	176080e7          	jalr	374(ra) # 80000a2c <kfree>
  } else
    release(&pi->lock);
}
    800048be:	60e2                	ld	ra,24(sp)
    800048c0:	6442                	ld	s0,16(sp)
    800048c2:	64a2                	ld	s1,8(sp)
    800048c4:	6902                	ld	s2,0(sp)
    800048c6:	6105                	addi	sp,sp,32
    800048c8:	8082                	ret
    pi->readopen = 0;
    800048ca:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800048ce:	21c48513          	addi	a0,s1,540
    800048d2:	ffffe097          	auipc	ra,0xffffe
    800048d6:	a38080e7          	jalr	-1480(ra) # 8000230a <wakeup>
    800048da:	b7e9                	j	800048a4 <pipeclose+0x2c>
    release(&pi->lock);
    800048dc:	8526                	mv	a0,s1
    800048de:	ffffc097          	auipc	ra,0xffffc
    800048e2:	3ee080e7          	jalr	1006(ra) # 80000ccc <release>
}
    800048e6:	bfe1                	j	800048be <pipeclose+0x46>

00000000800048e8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800048e8:	7119                	addi	sp,sp,-128
    800048ea:	fc86                	sd	ra,120(sp)
    800048ec:	f8a2                	sd	s0,112(sp)
    800048ee:	f4a6                	sd	s1,104(sp)
    800048f0:	f0ca                	sd	s2,96(sp)
    800048f2:	ecce                	sd	s3,88(sp)
    800048f4:	e8d2                	sd	s4,80(sp)
    800048f6:	e4d6                	sd	s5,72(sp)
    800048f8:	e0da                	sd	s6,64(sp)
    800048fa:	fc5e                	sd	s7,56(sp)
    800048fc:	f862                	sd	s8,48(sp)
    800048fe:	f466                	sd	s9,40(sp)
    80004900:	f06a                	sd	s10,32(sp)
    80004902:	ec6e                	sd	s11,24(sp)
    80004904:	0100                	addi	s0,sp,128
    80004906:	84aa                	mv	s1,a0
    80004908:	8cae                	mv	s9,a1
    8000490a:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    8000490c:	ffffd097          	auipc	ra,0xffffd
    80004910:	068080e7          	jalr	104(ra) # 80001974 <myproc>
    80004914:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004916:	8526                	mv	a0,s1
    80004918:	ffffc097          	auipc	ra,0xffffc
    8000491c:	300080e7          	jalr	768(ra) # 80000c18 <acquire>
  for(i = 0; i < n; i++){
    80004920:	0d605963          	blez	s6,800049f2 <pipewrite+0x10a>
    80004924:	89a6                	mv	s3,s1
    80004926:	3b7d                	addiw	s6,s6,-1
    80004928:	1b02                	slli	s6,s6,0x20
    8000492a:	020b5b13          	srli	s6,s6,0x20
    8000492e:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004930:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004934:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004938:	5dfd                	li	s11,-1
    8000493a:	000b8d1b          	sext.w	s10,s7
    8000493e:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004940:	2184a783          	lw	a5,536(s1)
    80004944:	21c4a703          	lw	a4,540(s1)
    80004948:	2007879b          	addiw	a5,a5,512
    8000494c:	02f71b63          	bne	a4,a5,80004982 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004950:	2204a783          	lw	a5,544(s1)
    80004954:	cbad                	beqz	a5,800049c6 <pipewrite+0xde>
    80004956:	03092783          	lw	a5,48(s2)
    8000495a:	e7b5                	bnez	a5,800049c6 <pipewrite+0xde>
      wakeup(&pi->nread);
    8000495c:	8556                	mv	a0,s5
    8000495e:	ffffe097          	auipc	ra,0xffffe
    80004962:	9ac080e7          	jalr	-1620(ra) # 8000230a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004966:	85ce                	mv	a1,s3
    80004968:	8552                	mv	a0,s4
    8000496a:	ffffe097          	auipc	ra,0xffffe
    8000496e:	81a080e7          	jalr	-2022(ra) # 80002184 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004972:	2184a783          	lw	a5,536(s1)
    80004976:	21c4a703          	lw	a4,540(s1)
    8000497a:	2007879b          	addiw	a5,a5,512
    8000497e:	fcf709e3          	beq	a4,a5,80004950 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004982:	4685                	li	a3,1
    80004984:	019b8633          	add	a2,s7,s9
    80004988:	f8f40593          	addi	a1,s0,-113
    8000498c:	05093503          	ld	a0,80(s2)
    80004990:	ffffd097          	auipc	ra,0xffffd
    80004994:	d64080e7          	jalr	-668(ra) # 800016f4 <copyin>
    80004998:	05b50e63          	beq	a0,s11,800049f4 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000499c:	21c4a783          	lw	a5,540(s1)
    800049a0:	0017871b          	addiw	a4,a5,1
    800049a4:	20e4ae23          	sw	a4,540(s1)
    800049a8:	1ff7f793          	andi	a5,a5,511
    800049ac:	97a6                	add	a5,a5,s1
    800049ae:	f8f44703          	lbu	a4,-113(s0)
    800049b2:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    800049b6:	001d0c1b          	addiw	s8,s10,1
    800049ba:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    800049be:	036b8b63          	beq	s7,s6,800049f4 <pipewrite+0x10c>
    800049c2:	8bbe                	mv	s7,a5
    800049c4:	bf9d                	j	8000493a <pipewrite+0x52>
        release(&pi->lock);
    800049c6:	8526                	mv	a0,s1
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	304080e7          	jalr	772(ra) # 80000ccc <release>
        return -1;
    800049d0:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    800049d2:	8562                	mv	a0,s8
    800049d4:	70e6                	ld	ra,120(sp)
    800049d6:	7446                	ld	s0,112(sp)
    800049d8:	74a6                	ld	s1,104(sp)
    800049da:	7906                	ld	s2,96(sp)
    800049dc:	69e6                	ld	s3,88(sp)
    800049de:	6a46                	ld	s4,80(sp)
    800049e0:	6aa6                	ld	s5,72(sp)
    800049e2:	6b06                	ld	s6,64(sp)
    800049e4:	7be2                	ld	s7,56(sp)
    800049e6:	7c42                	ld	s8,48(sp)
    800049e8:	7ca2                	ld	s9,40(sp)
    800049ea:	7d02                	ld	s10,32(sp)
    800049ec:	6de2                	ld	s11,24(sp)
    800049ee:	6109                	addi	sp,sp,128
    800049f0:	8082                	ret
  for(i = 0; i < n; i++){
    800049f2:	4c01                	li	s8,0
  wakeup(&pi->nread);
    800049f4:	21848513          	addi	a0,s1,536
    800049f8:	ffffe097          	auipc	ra,0xffffe
    800049fc:	912080e7          	jalr	-1774(ra) # 8000230a <wakeup>
  release(&pi->lock);
    80004a00:	8526                	mv	a0,s1
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	2ca080e7          	jalr	714(ra) # 80000ccc <release>
  return i;
    80004a0a:	b7e1                	j	800049d2 <pipewrite+0xea>

0000000080004a0c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a0c:	715d                	addi	sp,sp,-80
    80004a0e:	e486                	sd	ra,72(sp)
    80004a10:	e0a2                	sd	s0,64(sp)
    80004a12:	fc26                	sd	s1,56(sp)
    80004a14:	f84a                	sd	s2,48(sp)
    80004a16:	f44e                	sd	s3,40(sp)
    80004a18:	f052                	sd	s4,32(sp)
    80004a1a:	ec56                	sd	s5,24(sp)
    80004a1c:	e85a                	sd	s6,16(sp)
    80004a1e:	0880                	addi	s0,sp,80
    80004a20:	84aa                	mv	s1,a0
    80004a22:	892e                	mv	s2,a1
    80004a24:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a26:	ffffd097          	auipc	ra,0xffffd
    80004a2a:	f4e080e7          	jalr	-178(ra) # 80001974 <myproc>
    80004a2e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a30:	8b26                	mv	s6,s1
    80004a32:	8526                	mv	a0,s1
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	1e4080e7          	jalr	484(ra) # 80000c18 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a3c:	2184a703          	lw	a4,536(s1)
    80004a40:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a44:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a48:	02f71463          	bne	a4,a5,80004a70 <piperead+0x64>
    80004a4c:	2244a783          	lw	a5,548(s1)
    80004a50:	c385                	beqz	a5,80004a70 <piperead+0x64>
    if(pr->killed){
    80004a52:	030a2783          	lw	a5,48(s4)
    80004a56:	ebc1                	bnez	a5,80004ae6 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a58:	85da                	mv	a1,s6
    80004a5a:	854e                	mv	a0,s3
    80004a5c:	ffffd097          	auipc	ra,0xffffd
    80004a60:	728080e7          	jalr	1832(ra) # 80002184 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a64:	2184a703          	lw	a4,536(s1)
    80004a68:	21c4a783          	lw	a5,540(s1)
    80004a6c:	fef700e3          	beq	a4,a5,80004a4c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a70:	09505263          	blez	s5,80004af4 <piperead+0xe8>
    80004a74:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a76:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004a78:	2184a783          	lw	a5,536(s1)
    80004a7c:	21c4a703          	lw	a4,540(s1)
    80004a80:	02f70d63          	beq	a4,a5,80004aba <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004a84:	0017871b          	addiw	a4,a5,1
    80004a88:	20e4ac23          	sw	a4,536(s1)
    80004a8c:	1ff7f793          	andi	a5,a5,511
    80004a90:	97a6                	add	a5,a5,s1
    80004a92:	0187c783          	lbu	a5,24(a5)
    80004a96:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a9a:	4685                	li	a3,1
    80004a9c:	fbf40613          	addi	a2,s0,-65
    80004aa0:	85ca                	mv	a1,s2
    80004aa2:	050a3503          	ld	a0,80(s4)
    80004aa6:	ffffd097          	auipc	ra,0xffffd
    80004aaa:	bc2080e7          	jalr	-1086(ra) # 80001668 <copyout>
    80004aae:	01650663          	beq	a0,s6,80004aba <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ab2:	2985                	addiw	s3,s3,1
    80004ab4:	0905                	addi	s2,s2,1
    80004ab6:	fd3a91e3          	bne	s5,s3,80004a78 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004aba:	21c48513          	addi	a0,s1,540
    80004abe:	ffffe097          	auipc	ra,0xffffe
    80004ac2:	84c080e7          	jalr	-1972(ra) # 8000230a <wakeup>
  release(&pi->lock);
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	ffffc097          	auipc	ra,0xffffc
    80004acc:	204080e7          	jalr	516(ra) # 80000ccc <release>
  return i;
}
    80004ad0:	854e                	mv	a0,s3
    80004ad2:	60a6                	ld	ra,72(sp)
    80004ad4:	6406                	ld	s0,64(sp)
    80004ad6:	74e2                	ld	s1,56(sp)
    80004ad8:	7942                	ld	s2,48(sp)
    80004ada:	79a2                	ld	s3,40(sp)
    80004adc:	7a02                	ld	s4,32(sp)
    80004ade:	6ae2                	ld	s5,24(sp)
    80004ae0:	6b42                	ld	s6,16(sp)
    80004ae2:	6161                	addi	sp,sp,80
    80004ae4:	8082                	ret
      release(&pi->lock);
    80004ae6:	8526                	mv	a0,s1
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	1e4080e7          	jalr	484(ra) # 80000ccc <release>
      return -1;
    80004af0:	59fd                	li	s3,-1
    80004af2:	bff9                	j	80004ad0 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004af4:	4981                	li	s3,0
    80004af6:	b7d1                	j	80004aba <piperead+0xae>

0000000080004af8 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004af8:	df010113          	addi	sp,sp,-528
    80004afc:	20113423          	sd	ra,520(sp)
    80004b00:	20813023          	sd	s0,512(sp)
    80004b04:	ffa6                	sd	s1,504(sp)
    80004b06:	fbca                	sd	s2,496(sp)
    80004b08:	f7ce                	sd	s3,488(sp)
    80004b0a:	f3d2                	sd	s4,480(sp)
    80004b0c:	efd6                	sd	s5,472(sp)
    80004b0e:	ebda                	sd	s6,464(sp)
    80004b10:	e7de                	sd	s7,456(sp)
    80004b12:	e3e2                	sd	s8,448(sp)
    80004b14:	ff66                	sd	s9,440(sp)
    80004b16:	fb6a                	sd	s10,432(sp)
    80004b18:	f76e                	sd	s11,424(sp)
    80004b1a:	0c00                	addi	s0,sp,528
    80004b1c:	84aa                	mv	s1,a0
    80004b1e:	dea43c23          	sd	a0,-520(s0)
    80004b22:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b26:	ffffd097          	auipc	ra,0xffffd
    80004b2a:	e4e080e7          	jalr	-434(ra) # 80001974 <myproc>
    80004b2e:	892a                	mv	s2,a0

  begin_op();
    80004b30:	fffff097          	auipc	ra,0xfffff
    80004b34:	444080e7          	jalr	1092(ra) # 80003f74 <begin_op>

  if((ip = namei(path)) == 0){
    80004b38:	8526                	mv	a0,s1
    80004b3a:	fffff097          	auipc	ra,0xfffff
    80004b3e:	21e080e7          	jalr	542(ra) # 80003d58 <namei>
    80004b42:	c92d                	beqz	a0,80004bb4 <exec+0xbc>
    80004b44:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b46:	fffff097          	auipc	ra,0xfffff
    80004b4a:	a5e080e7          	jalr	-1442(ra) # 800035a4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b4e:	04000713          	li	a4,64
    80004b52:	4681                	li	a3,0
    80004b54:	e4840613          	addi	a2,s0,-440
    80004b58:	4581                	li	a1,0
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	fffff097          	auipc	ra,0xfffff
    80004b60:	cfc080e7          	jalr	-772(ra) # 80003858 <readi>
    80004b64:	04000793          	li	a5,64
    80004b68:	00f51a63          	bne	a0,a5,80004b7c <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004b6c:	e4842703          	lw	a4,-440(s0)
    80004b70:	464c47b7          	lui	a5,0x464c4
    80004b74:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004b78:	04f70463          	beq	a4,a5,80004bc0 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	fffff097          	auipc	ra,0xfffff
    80004b82:	c88080e7          	jalr	-888(ra) # 80003806 <iunlockput>
    end_op();
    80004b86:	fffff097          	auipc	ra,0xfffff
    80004b8a:	46e080e7          	jalr	1134(ra) # 80003ff4 <end_op>
  }
  return -1;
    80004b8e:	557d                	li	a0,-1
}
    80004b90:	20813083          	ld	ra,520(sp)
    80004b94:	20013403          	ld	s0,512(sp)
    80004b98:	74fe                	ld	s1,504(sp)
    80004b9a:	795e                	ld	s2,496(sp)
    80004b9c:	79be                	ld	s3,488(sp)
    80004b9e:	7a1e                	ld	s4,480(sp)
    80004ba0:	6afe                	ld	s5,472(sp)
    80004ba2:	6b5e                	ld	s6,464(sp)
    80004ba4:	6bbe                	ld	s7,456(sp)
    80004ba6:	6c1e                	ld	s8,448(sp)
    80004ba8:	7cfa                	ld	s9,440(sp)
    80004baa:	7d5a                	ld	s10,432(sp)
    80004bac:	7dba                	ld	s11,424(sp)
    80004bae:	21010113          	addi	sp,sp,528
    80004bb2:	8082                	ret
    end_op();
    80004bb4:	fffff097          	auipc	ra,0xfffff
    80004bb8:	440080e7          	jalr	1088(ra) # 80003ff4 <end_op>
    return -1;
    80004bbc:	557d                	li	a0,-1
    80004bbe:	bfc9                	j	80004b90 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004bc0:	854a                	mv	a0,s2
    80004bc2:	ffffd097          	auipc	ra,0xffffd
    80004bc6:	e76080e7          	jalr	-394(ra) # 80001a38 <proc_pagetable>
    80004bca:	8baa                	mv	s7,a0
    80004bcc:	d945                	beqz	a0,80004b7c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bce:	e6842983          	lw	s3,-408(s0)
    80004bd2:	e8045783          	lhu	a5,-384(s0)
    80004bd6:	c7ad                	beqz	a5,80004c40 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004bd8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bda:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004bdc:	6c85                	lui	s9,0x1
    80004bde:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004be2:	def43823          	sd	a5,-528(s0)
    80004be6:	a42d                	j	80004e10 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004be8:	00004517          	auipc	a0,0x4
    80004bec:	ac850513          	addi	a0,a0,-1336 # 800086b0 <syscalls+0x290>
    80004bf0:	ffffc097          	auipc	ra,0xffffc
    80004bf4:	960080e7          	jalr	-1696(ra) # 80000550 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004bf8:	8756                	mv	a4,s5
    80004bfa:	012d86bb          	addw	a3,s11,s2
    80004bfe:	4581                	li	a1,0
    80004c00:	8526                	mv	a0,s1
    80004c02:	fffff097          	auipc	ra,0xfffff
    80004c06:	c56080e7          	jalr	-938(ra) # 80003858 <readi>
    80004c0a:	2501                	sext.w	a0,a0
    80004c0c:	1aaa9963          	bne	s5,a0,80004dbe <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004c10:	6785                	lui	a5,0x1
    80004c12:	0127893b          	addw	s2,a5,s2
    80004c16:	77fd                	lui	a5,0xfffff
    80004c18:	01478a3b          	addw	s4,a5,s4
    80004c1c:	1f897163          	bgeu	s2,s8,80004dfe <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004c20:	02091593          	slli	a1,s2,0x20
    80004c24:	9181                	srli	a1,a1,0x20
    80004c26:	95ea                	add	a1,a1,s10
    80004c28:	855e                	mv	a0,s7
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	47c080e7          	jalr	1148(ra) # 800010a6 <walkaddr>
    80004c32:	862a                	mv	a2,a0
    if(pa == 0)
    80004c34:	d955                	beqz	a0,80004be8 <exec+0xf0>
      n = PGSIZE;
    80004c36:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004c38:	fd9a70e3          	bgeu	s4,s9,80004bf8 <exec+0x100>
      n = sz - i;
    80004c3c:	8ad2                	mv	s5,s4
    80004c3e:	bf6d                	j	80004bf8 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c40:	4901                	li	s2,0
  iunlockput(ip);
    80004c42:	8526                	mv	a0,s1
    80004c44:	fffff097          	auipc	ra,0xfffff
    80004c48:	bc2080e7          	jalr	-1086(ra) # 80003806 <iunlockput>
  end_op();
    80004c4c:	fffff097          	auipc	ra,0xfffff
    80004c50:	3a8080e7          	jalr	936(ra) # 80003ff4 <end_op>
  p = myproc();
    80004c54:	ffffd097          	auipc	ra,0xffffd
    80004c58:	d20080e7          	jalr	-736(ra) # 80001974 <myproc>
    80004c5c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004c5e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004c62:	6785                	lui	a5,0x1
    80004c64:	17fd                	addi	a5,a5,-1
    80004c66:	993e                	add	s2,s2,a5
    80004c68:	757d                	lui	a0,0xfffff
    80004c6a:	00a977b3          	and	a5,s2,a0
    80004c6e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004c72:	6609                	lui	a2,0x2
    80004c74:	963e                	add	a2,a2,a5
    80004c76:	85be                	mv	a1,a5
    80004c78:	855e                	mv	a0,s7
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	79e080e7          	jalr	1950(ra) # 80001418 <uvmalloc>
    80004c82:	8b2a                	mv	s6,a0
  ip = 0;
    80004c84:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004c86:	12050c63          	beqz	a0,80004dbe <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004c8a:	75f9                	lui	a1,0xffffe
    80004c8c:	95aa                	add	a1,a1,a0
    80004c8e:	855e                	mv	a0,s7
    80004c90:	ffffd097          	auipc	ra,0xffffd
    80004c94:	9a6080e7          	jalr	-1626(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80004c98:	7c7d                	lui	s8,0xfffff
    80004c9a:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004c9c:	e0043783          	ld	a5,-512(s0)
    80004ca0:	6388                	ld	a0,0(a5)
    80004ca2:	c535                	beqz	a0,80004d0e <exec+0x216>
    80004ca4:	e8840993          	addi	s3,s0,-376
    80004ca8:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004cac:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004cae:	ffffc097          	auipc	ra,0xffffc
    80004cb2:	1ee080e7          	jalr	494(ra) # 80000e9c <strlen>
    80004cb6:	2505                	addiw	a0,a0,1
    80004cb8:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004cbc:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004cc0:	13896363          	bltu	s2,s8,80004de6 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004cc4:	e0043d83          	ld	s11,-512(s0)
    80004cc8:	000dba03          	ld	s4,0(s11)
    80004ccc:	8552                	mv	a0,s4
    80004cce:	ffffc097          	auipc	ra,0xffffc
    80004cd2:	1ce080e7          	jalr	462(ra) # 80000e9c <strlen>
    80004cd6:	0015069b          	addiw	a3,a0,1
    80004cda:	8652                	mv	a2,s4
    80004cdc:	85ca                	mv	a1,s2
    80004cde:	855e                	mv	a0,s7
    80004ce0:	ffffd097          	auipc	ra,0xffffd
    80004ce4:	988080e7          	jalr	-1656(ra) # 80001668 <copyout>
    80004ce8:	10054363          	bltz	a0,80004dee <exec+0x2f6>
    ustack[argc] = sp;
    80004cec:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004cf0:	0485                	addi	s1,s1,1
    80004cf2:	008d8793          	addi	a5,s11,8
    80004cf6:	e0f43023          	sd	a5,-512(s0)
    80004cfa:	008db503          	ld	a0,8(s11)
    80004cfe:	c911                	beqz	a0,80004d12 <exec+0x21a>
    if(argc >= MAXARG)
    80004d00:	09a1                	addi	s3,s3,8
    80004d02:	fb3c96e3          	bne	s9,s3,80004cae <exec+0x1b6>
  sz = sz1;
    80004d06:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004d0a:	4481                	li	s1,0
    80004d0c:	a84d                	j	80004dbe <exec+0x2c6>
  sp = sz;
    80004d0e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004d10:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d12:	00349793          	slli	a5,s1,0x3
    80004d16:	f9040713          	addi	a4,s0,-112
    80004d1a:	97ba                	add	a5,a5,a4
    80004d1c:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004d20:	00148693          	addi	a3,s1,1
    80004d24:	068e                	slli	a3,a3,0x3
    80004d26:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d2a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004d2e:	01897663          	bgeu	s2,s8,80004d3a <exec+0x242>
  sz = sz1;
    80004d32:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004d36:	4481                	li	s1,0
    80004d38:	a059                	j	80004dbe <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d3a:	e8840613          	addi	a2,s0,-376
    80004d3e:	85ca                	mv	a1,s2
    80004d40:	855e                	mv	a0,s7
    80004d42:	ffffd097          	auipc	ra,0xffffd
    80004d46:	926080e7          	jalr	-1754(ra) # 80001668 <copyout>
    80004d4a:	0a054663          	bltz	a0,80004df6 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004d4e:	058ab783          	ld	a5,88(s5)
    80004d52:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004d56:	df843783          	ld	a5,-520(s0)
    80004d5a:	0007c703          	lbu	a4,0(a5)
    80004d5e:	cf11                	beqz	a4,80004d7a <exec+0x282>
    80004d60:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004d62:	02f00693          	li	a3,47
    80004d66:	a029                	j	80004d70 <exec+0x278>
  for(last=s=path; *s; s++)
    80004d68:	0785                	addi	a5,a5,1
    80004d6a:	fff7c703          	lbu	a4,-1(a5)
    80004d6e:	c711                	beqz	a4,80004d7a <exec+0x282>
    if(*s == '/')
    80004d70:	fed71ce3          	bne	a4,a3,80004d68 <exec+0x270>
      last = s+1;
    80004d74:	def43c23          	sd	a5,-520(s0)
    80004d78:	bfc5                	j	80004d68 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004d7a:	4641                	li	a2,16
    80004d7c:	df843583          	ld	a1,-520(s0)
    80004d80:	158a8513          	addi	a0,s5,344
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	0e6080e7          	jalr	230(ra) # 80000e6a <safestrcpy>
  oldpagetable = p->pagetable;
    80004d8c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004d90:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004d94:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004d98:	058ab783          	ld	a5,88(s5)
    80004d9c:	e6043703          	ld	a4,-416(s0)
    80004da0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004da2:	058ab783          	ld	a5,88(s5)
    80004da6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004daa:	85ea                	mv	a1,s10
    80004dac:	ffffd097          	auipc	ra,0xffffd
    80004db0:	d28080e7          	jalr	-728(ra) # 80001ad4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004db4:	0004851b          	sext.w	a0,s1
    80004db8:	bbe1                	j	80004b90 <exec+0x98>
    80004dba:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004dbe:	e0843583          	ld	a1,-504(s0)
    80004dc2:	855e                	mv	a0,s7
    80004dc4:	ffffd097          	auipc	ra,0xffffd
    80004dc8:	d10080e7          	jalr	-752(ra) # 80001ad4 <proc_freepagetable>
  if(ip){
    80004dcc:	da0498e3          	bnez	s1,80004b7c <exec+0x84>
  return -1;
    80004dd0:	557d                	li	a0,-1
    80004dd2:	bb7d                	j	80004b90 <exec+0x98>
    80004dd4:	e1243423          	sd	s2,-504(s0)
    80004dd8:	b7dd                	j	80004dbe <exec+0x2c6>
    80004dda:	e1243423          	sd	s2,-504(s0)
    80004dde:	b7c5                	j	80004dbe <exec+0x2c6>
    80004de0:	e1243423          	sd	s2,-504(s0)
    80004de4:	bfe9                	j	80004dbe <exec+0x2c6>
  sz = sz1;
    80004de6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004dea:	4481                	li	s1,0
    80004dec:	bfc9                	j	80004dbe <exec+0x2c6>
  sz = sz1;
    80004dee:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004df2:	4481                	li	s1,0
    80004df4:	b7e9                	j	80004dbe <exec+0x2c6>
  sz = sz1;
    80004df6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004dfa:	4481                	li	s1,0
    80004dfc:	b7c9                	j	80004dbe <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004dfe:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e02:	2b05                	addiw	s6,s6,1
    80004e04:	0389899b          	addiw	s3,s3,56
    80004e08:	e8045783          	lhu	a5,-384(s0)
    80004e0c:	e2fb5be3          	bge	s6,a5,80004c42 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e10:	2981                	sext.w	s3,s3
    80004e12:	03800713          	li	a4,56
    80004e16:	86ce                	mv	a3,s3
    80004e18:	e1040613          	addi	a2,s0,-496
    80004e1c:	4581                	li	a1,0
    80004e1e:	8526                	mv	a0,s1
    80004e20:	fffff097          	auipc	ra,0xfffff
    80004e24:	a38080e7          	jalr	-1480(ra) # 80003858 <readi>
    80004e28:	03800793          	li	a5,56
    80004e2c:	f8f517e3          	bne	a0,a5,80004dba <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004e30:	e1042783          	lw	a5,-496(s0)
    80004e34:	4705                	li	a4,1
    80004e36:	fce796e3          	bne	a5,a4,80004e02 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004e3a:	e3843603          	ld	a2,-456(s0)
    80004e3e:	e3043783          	ld	a5,-464(s0)
    80004e42:	f8f669e3          	bltu	a2,a5,80004dd4 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e46:	e2043783          	ld	a5,-480(s0)
    80004e4a:	963e                	add	a2,a2,a5
    80004e4c:	f8f667e3          	bltu	a2,a5,80004dda <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e50:	85ca                	mv	a1,s2
    80004e52:	855e                	mv	a0,s7
    80004e54:	ffffc097          	auipc	ra,0xffffc
    80004e58:	5c4080e7          	jalr	1476(ra) # 80001418 <uvmalloc>
    80004e5c:	e0a43423          	sd	a0,-504(s0)
    80004e60:	d141                	beqz	a0,80004de0 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80004e62:	e2043d03          	ld	s10,-480(s0)
    80004e66:	df043783          	ld	a5,-528(s0)
    80004e6a:	00fd77b3          	and	a5,s10,a5
    80004e6e:	fba1                	bnez	a5,80004dbe <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e70:	e1842d83          	lw	s11,-488(s0)
    80004e74:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e78:	f80c03e3          	beqz	s8,80004dfe <exec+0x306>
    80004e7c:	8a62                	mv	s4,s8
    80004e7e:	4901                	li	s2,0
    80004e80:	b345                	j	80004c20 <exec+0x128>

0000000080004e82 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004e82:	7179                	addi	sp,sp,-48
    80004e84:	f406                	sd	ra,40(sp)
    80004e86:	f022                	sd	s0,32(sp)
    80004e88:	ec26                	sd	s1,24(sp)
    80004e8a:	e84a                	sd	s2,16(sp)
    80004e8c:	1800                	addi	s0,sp,48
    80004e8e:	892e                	mv	s2,a1
    80004e90:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004e92:	fdc40593          	addi	a1,s0,-36
    80004e96:	ffffe097          	auipc	ra,0xffffe
    80004e9a:	b9c080e7          	jalr	-1124(ra) # 80002a32 <argint>
    80004e9e:	04054063          	bltz	a0,80004ede <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ea2:	fdc42703          	lw	a4,-36(s0)
    80004ea6:	47bd                	li	a5,15
    80004ea8:	02e7ed63          	bltu	a5,a4,80004ee2 <argfd+0x60>
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	ac8080e7          	jalr	-1336(ra) # 80001974 <myproc>
    80004eb4:	fdc42703          	lw	a4,-36(s0)
    80004eb8:	01a70793          	addi	a5,a4,26
    80004ebc:	078e                	slli	a5,a5,0x3
    80004ebe:	953e                	add	a0,a0,a5
    80004ec0:	611c                	ld	a5,0(a0)
    80004ec2:	c395                	beqz	a5,80004ee6 <argfd+0x64>
    return -1;
  if(pfd)
    80004ec4:	00090463          	beqz	s2,80004ecc <argfd+0x4a>
    *pfd = fd;
    80004ec8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ecc:	4501                	li	a0,0
  if(pf)
    80004ece:	c091                	beqz	s1,80004ed2 <argfd+0x50>
    *pf = f;
    80004ed0:	e09c                	sd	a5,0(s1)
}
    80004ed2:	70a2                	ld	ra,40(sp)
    80004ed4:	7402                	ld	s0,32(sp)
    80004ed6:	64e2                	ld	s1,24(sp)
    80004ed8:	6942                	ld	s2,16(sp)
    80004eda:	6145                	addi	sp,sp,48
    80004edc:	8082                	ret
    return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	bfcd                	j	80004ed2 <argfd+0x50>
    return -1;
    80004ee2:	557d                	li	a0,-1
    80004ee4:	b7fd                	j	80004ed2 <argfd+0x50>
    80004ee6:	557d                	li	a0,-1
    80004ee8:	b7ed                	j	80004ed2 <argfd+0x50>

0000000080004eea <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004eea:	1101                	addi	sp,sp,-32
    80004eec:	ec06                	sd	ra,24(sp)
    80004eee:	e822                	sd	s0,16(sp)
    80004ef0:	e426                	sd	s1,8(sp)
    80004ef2:	1000                	addi	s0,sp,32
    80004ef4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	a7e080e7          	jalr	-1410(ra) # 80001974 <myproc>
    80004efe:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f00:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    80004f04:	4501                	li	a0,0
    80004f06:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f08:	6398                	ld	a4,0(a5)
    80004f0a:	cb19                	beqz	a4,80004f20 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f0c:	2505                	addiw	a0,a0,1
    80004f0e:	07a1                	addi	a5,a5,8
    80004f10:	fed51ce3          	bne	a0,a3,80004f08 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f14:	557d                	li	a0,-1
}
    80004f16:	60e2                	ld	ra,24(sp)
    80004f18:	6442                	ld	s0,16(sp)
    80004f1a:	64a2                	ld	s1,8(sp)
    80004f1c:	6105                	addi	sp,sp,32
    80004f1e:	8082                	ret
      p->ofile[fd] = f;
    80004f20:	01a50793          	addi	a5,a0,26
    80004f24:	078e                	slli	a5,a5,0x3
    80004f26:	963e                	add	a2,a2,a5
    80004f28:	e204                	sd	s1,0(a2)
      return fd;
    80004f2a:	b7f5                	j	80004f16 <fdalloc+0x2c>

0000000080004f2c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f2c:	715d                	addi	sp,sp,-80
    80004f2e:	e486                	sd	ra,72(sp)
    80004f30:	e0a2                	sd	s0,64(sp)
    80004f32:	fc26                	sd	s1,56(sp)
    80004f34:	f84a                	sd	s2,48(sp)
    80004f36:	f44e                	sd	s3,40(sp)
    80004f38:	f052                	sd	s4,32(sp)
    80004f3a:	ec56                	sd	s5,24(sp)
    80004f3c:	0880                	addi	s0,sp,80
    80004f3e:	89ae                	mv	s3,a1
    80004f40:	8ab2                	mv	s5,a2
    80004f42:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f44:	fb040593          	addi	a1,s0,-80
    80004f48:	fffff097          	auipc	ra,0xfffff
    80004f4c:	e2e080e7          	jalr	-466(ra) # 80003d76 <nameiparent>
    80004f50:	892a                	mv	s2,a0
    80004f52:	12050f63          	beqz	a0,80005090 <create+0x164>
    return 0;

  ilock(dp);
    80004f56:	ffffe097          	auipc	ra,0xffffe
    80004f5a:	64e080e7          	jalr	1614(ra) # 800035a4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f5e:	4601                	li	a2,0
    80004f60:	fb040593          	addi	a1,s0,-80
    80004f64:	854a                	mv	a0,s2
    80004f66:	fffff097          	auipc	ra,0xfffff
    80004f6a:	b20080e7          	jalr	-1248(ra) # 80003a86 <dirlookup>
    80004f6e:	84aa                	mv	s1,a0
    80004f70:	c921                	beqz	a0,80004fc0 <create+0x94>
    iunlockput(dp);
    80004f72:	854a                	mv	a0,s2
    80004f74:	fffff097          	auipc	ra,0xfffff
    80004f78:	892080e7          	jalr	-1902(ra) # 80003806 <iunlockput>
    ilock(ip);
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	ffffe097          	auipc	ra,0xffffe
    80004f82:	626080e7          	jalr	1574(ra) # 800035a4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004f86:	2981                	sext.w	s3,s3
    80004f88:	4789                	li	a5,2
    80004f8a:	02f99463          	bne	s3,a5,80004fb2 <create+0x86>
    80004f8e:	0444d783          	lhu	a5,68(s1)
    80004f92:	37f9                	addiw	a5,a5,-2
    80004f94:	17c2                	slli	a5,a5,0x30
    80004f96:	93c1                	srli	a5,a5,0x30
    80004f98:	4705                	li	a4,1
    80004f9a:	00f76c63          	bltu	a4,a5,80004fb2 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004f9e:	8526                	mv	a0,s1
    80004fa0:	60a6                	ld	ra,72(sp)
    80004fa2:	6406                	ld	s0,64(sp)
    80004fa4:	74e2                	ld	s1,56(sp)
    80004fa6:	7942                	ld	s2,48(sp)
    80004fa8:	79a2                	ld	s3,40(sp)
    80004faa:	7a02                	ld	s4,32(sp)
    80004fac:	6ae2                	ld	s5,24(sp)
    80004fae:	6161                	addi	sp,sp,80
    80004fb0:	8082                	ret
    iunlockput(ip);
    80004fb2:	8526                	mv	a0,s1
    80004fb4:	fffff097          	auipc	ra,0xfffff
    80004fb8:	852080e7          	jalr	-1966(ra) # 80003806 <iunlockput>
    return 0;
    80004fbc:	4481                	li	s1,0
    80004fbe:	b7c5                	j	80004f9e <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004fc0:	85ce                	mv	a1,s3
    80004fc2:	00092503          	lw	a0,0(s2)
    80004fc6:	ffffe097          	auipc	ra,0xffffe
    80004fca:	446080e7          	jalr	1094(ra) # 8000340c <ialloc>
    80004fce:	84aa                	mv	s1,a0
    80004fd0:	c529                	beqz	a0,8000501a <create+0xee>
  ilock(ip);
    80004fd2:	ffffe097          	auipc	ra,0xffffe
    80004fd6:	5d2080e7          	jalr	1490(ra) # 800035a4 <ilock>
  ip->major = major;
    80004fda:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80004fde:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004fe2:	4785                	li	a5,1
    80004fe4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fe8:	8526                	mv	a0,s1
    80004fea:	ffffe097          	auipc	ra,0xffffe
    80004fee:	4f0080e7          	jalr	1264(ra) # 800034da <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ff2:	2981                	sext.w	s3,s3
    80004ff4:	4785                	li	a5,1
    80004ff6:	02f98a63          	beq	s3,a5,8000502a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ffa:	40d0                	lw	a2,4(s1)
    80004ffc:	fb040593          	addi	a1,s0,-80
    80005000:	854a                	mv	a0,s2
    80005002:	fffff097          	auipc	ra,0xfffff
    80005006:	c94080e7          	jalr	-876(ra) # 80003c96 <dirlink>
    8000500a:	06054b63          	bltz	a0,80005080 <create+0x154>
  iunlockput(dp);
    8000500e:	854a                	mv	a0,s2
    80005010:	ffffe097          	auipc	ra,0xffffe
    80005014:	7f6080e7          	jalr	2038(ra) # 80003806 <iunlockput>
  return ip;
    80005018:	b759                	j	80004f9e <create+0x72>
    panic("create: ialloc");
    8000501a:	00003517          	auipc	a0,0x3
    8000501e:	6b650513          	addi	a0,a0,1718 # 800086d0 <syscalls+0x2b0>
    80005022:	ffffb097          	auipc	ra,0xffffb
    80005026:	52e080e7          	jalr	1326(ra) # 80000550 <panic>
    dp->nlink++;  // for ".."
    8000502a:	04a95783          	lhu	a5,74(s2)
    8000502e:	2785                	addiw	a5,a5,1
    80005030:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005034:	854a                	mv	a0,s2
    80005036:	ffffe097          	auipc	ra,0xffffe
    8000503a:	4a4080e7          	jalr	1188(ra) # 800034da <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000503e:	40d0                	lw	a2,4(s1)
    80005040:	00003597          	auipc	a1,0x3
    80005044:	6a058593          	addi	a1,a1,1696 # 800086e0 <syscalls+0x2c0>
    80005048:	8526                	mv	a0,s1
    8000504a:	fffff097          	auipc	ra,0xfffff
    8000504e:	c4c080e7          	jalr	-948(ra) # 80003c96 <dirlink>
    80005052:	00054f63          	bltz	a0,80005070 <create+0x144>
    80005056:	00492603          	lw	a2,4(s2)
    8000505a:	00003597          	auipc	a1,0x3
    8000505e:	68e58593          	addi	a1,a1,1678 # 800086e8 <syscalls+0x2c8>
    80005062:	8526                	mv	a0,s1
    80005064:	fffff097          	auipc	ra,0xfffff
    80005068:	c32080e7          	jalr	-974(ra) # 80003c96 <dirlink>
    8000506c:	f80557e3          	bgez	a0,80004ffa <create+0xce>
      panic("create dots");
    80005070:	00003517          	auipc	a0,0x3
    80005074:	68050513          	addi	a0,a0,1664 # 800086f0 <syscalls+0x2d0>
    80005078:	ffffb097          	auipc	ra,0xffffb
    8000507c:	4d8080e7          	jalr	1240(ra) # 80000550 <panic>
    panic("create: dirlink");
    80005080:	00003517          	auipc	a0,0x3
    80005084:	68050513          	addi	a0,a0,1664 # 80008700 <syscalls+0x2e0>
    80005088:	ffffb097          	auipc	ra,0xffffb
    8000508c:	4c8080e7          	jalr	1224(ra) # 80000550 <panic>
    return 0;
    80005090:	84aa                	mv	s1,a0
    80005092:	b731                	j	80004f9e <create+0x72>

0000000080005094 <sys_dup>:
{
    80005094:	7179                	addi	sp,sp,-48
    80005096:	f406                	sd	ra,40(sp)
    80005098:	f022                	sd	s0,32(sp)
    8000509a:	ec26                	sd	s1,24(sp)
    8000509c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000509e:	fd840613          	addi	a2,s0,-40
    800050a2:	4581                	li	a1,0
    800050a4:	4501                	li	a0,0
    800050a6:	00000097          	auipc	ra,0x0
    800050aa:	ddc080e7          	jalr	-548(ra) # 80004e82 <argfd>
    return -1;
    800050ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800050b0:	02054363          	bltz	a0,800050d6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800050b4:	fd843503          	ld	a0,-40(s0)
    800050b8:	00000097          	auipc	ra,0x0
    800050bc:	e32080e7          	jalr	-462(ra) # 80004eea <fdalloc>
    800050c0:	84aa                	mv	s1,a0
    return -1;
    800050c2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800050c4:	00054963          	bltz	a0,800050d6 <sys_dup+0x42>
  filedup(f);
    800050c8:	fd843503          	ld	a0,-40(s0)
    800050cc:	fffff097          	auipc	ra,0xfffff
    800050d0:	32a080e7          	jalr	810(ra) # 800043f6 <filedup>
  return fd;
    800050d4:	87a6                	mv	a5,s1
}
    800050d6:	853e                	mv	a0,a5
    800050d8:	70a2                	ld	ra,40(sp)
    800050da:	7402                	ld	s0,32(sp)
    800050dc:	64e2                	ld	s1,24(sp)
    800050de:	6145                	addi	sp,sp,48
    800050e0:	8082                	ret

00000000800050e2 <sys_read>:
{
    800050e2:	7179                	addi	sp,sp,-48
    800050e4:	f406                	sd	ra,40(sp)
    800050e6:	f022                	sd	s0,32(sp)
    800050e8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050ea:	fe840613          	addi	a2,s0,-24
    800050ee:	4581                	li	a1,0
    800050f0:	4501                	li	a0,0
    800050f2:	00000097          	auipc	ra,0x0
    800050f6:	d90080e7          	jalr	-624(ra) # 80004e82 <argfd>
    return -1;
    800050fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050fc:	04054163          	bltz	a0,8000513e <sys_read+0x5c>
    80005100:	fe440593          	addi	a1,s0,-28
    80005104:	4509                	li	a0,2
    80005106:	ffffe097          	auipc	ra,0xffffe
    8000510a:	92c080e7          	jalr	-1748(ra) # 80002a32 <argint>
    return -1;
    8000510e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005110:	02054763          	bltz	a0,8000513e <sys_read+0x5c>
    80005114:	fd840593          	addi	a1,s0,-40
    80005118:	4505                	li	a0,1
    8000511a:	ffffe097          	auipc	ra,0xffffe
    8000511e:	93a080e7          	jalr	-1734(ra) # 80002a54 <argaddr>
    return -1;
    80005122:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005124:	00054d63          	bltz	a0,8000513e <sys_read+0x5c>
  return fileread(f, p, n);
    80005128:	fe442603          	lw	a2,-28(s0)
    8000512c:	fd843583          	ld	a1,-40(s0)
    80005130:	fe843503          	ld	a0,-24(s0)
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	44e080e7          	jalr	1102(ra) # 80004582 <fileread>
    8000513c:	87aa                	mv	a5,a0
}
    8000513e:	853e                	mv	a0,a5
    80005140:	70a2                	ld	ra,40(sp)
    80005142:	7402                	ld	s0,32(sp)
    80005144:	6145                	addi	sp,sp,48
    80005146:	8082                	ret

0000000080005148 <sys_write>:
{
    80005148:	7179                	addi	sp,sp,-48
    8000514a:	f406                	sd	ra,40(sp)
    8000514c:	f022                	sd	s0,32(sp)
    8000514e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005150:	fe840613          	addi	a2,s0,-24
    80005154:	4581                	li	a1,0
    80005156:	4501                	li	a0,0
    80005158:	00000097          	auipc	ra,0x0
    8000515c:	d2a080e7          	jalr	-726(ra) # 80004e82 <argfd>
    return -1;
    80005160:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005162:	04054163          	bltz	a0,800051a4 <sys_write+0x5c>
    80005166:	fe440593          	addi	a1,s0,-28
    8000516a:	4509                	li	a0,2
    8000516c:	ffffe097          	auipc	ra,0xffffe
    80005170:	8c6080e7          	jalr	-1850(ra) # 80002a32 <argint>
    return -1;
    80005174:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005176:	02054763          	bltz	a0,800051a4 <sys_write+0x5c>
    8000517a:	fd840593          	addi	a1,s0,-40
    8000517e:	4505                	li	a0,1
    80005180:	ffffe097          	auipc	ra,0xffffe
    80005184:	8d4080e7          	jalr	-1836(ra) # 80002a54 <argaddr>
    return -1;
    80005188:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000518a:	00054d63          	bltz	a0,800051a4 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000518e:	fe442603          	lw	a2,-28(s0)
    80005192:	fd843583          	ld	a1,-40(s0)
    80005196:	fe843503          	ld	a0,-24(s0)
    8000519a:	fffff097          	auipc	ra,0xfffff
    8000519e:	4aa080e7          	jalr	1194(ra) # 80004644 <filewrite>
    800051a2:	87aa                	mv	a5,a0
}
    800051a4:	853e                	mv	a0,a5
    800051a6:	70a2                	ld	ra,40(sp)
    800051a8:	7402                	ld	s0,32(sp)
    800051aa:	6145                	addi	sp,sp,48
    800051ac:	8082                	ret

00000000800051ae <sys_close>:
{
    800051ae:	1101                	addi	sp,sp,-32
    800051b0:	ec06                	sd	ra,24(sp)
    800051b2:	e822                	sd	s0,16(sp)
    800051b4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800051b6:	fe040613          	addi	a2,s0,-32
    800051ba:	fec40593          	addi	a1,s0,-20
    800051be:	4501                	li	a0,0
    800051c0:	00000097          	auipc	ra,0x0
    800051c4:	cc2080e7          	jalr	-830(ra) # 80004e82 <argfd>
    return -1;
    800051c8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800051ca:	02054463          	bltz	a0,800051f2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800051ce:	ffffc097          	auipc	ra,0xffffc
    800051d2:	7a6080e7          	jalr	1958(ra) # 80001974 <myproc>
    800051d6:	fec42783          	lw	a5,-20(s0)
    800051da:	07e9                	addi	a5,a5,26
    800051dc:	078e                	slli	a5,a5,0x3
    800051de:	97aa                	add	a5,a5,a0
    800051e0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800051e4:	fe043503          	ld	a0,-32(s0)
    800051e8:	fffff097          	auipc	ra,0xfffff
    800051ec:	260080e7          	jalr	608(ra) # 80004448 <fileclose>
  return 0;
    800051f0:	4781                	li	a5,0
}
    800051f2:	853e                	mv	a0,a5
    800051f4:	60e2                	ld	ra,24(sp)
    800051f6:	6442                	ld	s0,16(sp)
    800051f8:	6105                	addi	sp,sp,32
    800051fa:	8082                	ret

00000000800051fc <sys_fstat>:
{
    800051fc:	1101                	addi	sp,sp,-32
    800051fe:	ec06                	sd	ra,24(sp)
    80005200:	e822                	sd	s0,16(sp)
    80005202:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005204:	fe840613          	addi	a2,s0,-24
    80005208:	4581                	li	a1,0
    8000520a:	4501                	li	a0,0
    8000520c:	00000097          	auipc	ra,0x0
    80005210:	c76080e7          	jalr	-906(ra) # 80004e82 <argfd>
    return -1;
    80005214:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005216:	02054563          	bltz	a0,80005240 <sys_fstat+0x44>
    8000521a:	fe040593          	addi	a1,s0,-32
    8000521e:	4505                	li	a0,1
    80005220:	ffffe097          	auipc	ra,0xffffe
    80005224:	834080e7          	jalr	-1996(ra) # 80002a54 <argaddr>
    return -1;
    80005228:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000522a:	00054b63          	bltz	a0,80005240 <sys_fstat+0x44>
  return filestat(f, st);
    8000522e:	fe043583          	ld	a1,-32(s0)
    80005232:	fe843503          	ld	a0,-24(s0)
    80005236:	fffff097          	auipc	ra,0xfffff
    8000523a:	2da080e7          	jalr	730(ra) # 80004510 <filestat>
    8000523e:	87aa                	mv	a5,a0
}
    80005240:	853e                	mv	a0,a5
    80005242:	60e2                	ld	ra,24(sp)
    80005244:	6442                	ld	s0,16(sp)
    80005246:	6105                	addi	sp,sp,32
    80005248:	8082                	ret

000000008000524a <sys_link>:
{
    8000524a:	7169                	addi	sp,sp,-304
    8000524c:	f606                	sd	ra,296(sp)
    8000524e:	f222                	sd	s0,288(sp)
    80005250:	ee26                	sd	s1,280(sp)
    80005252:	ea4a                	sd	s2,272(sp)
    80005254:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005256:	08000613          	li	a2,128
    8000525a:	ed040593          	addi	a1,s0,-304
    8000525e:	4501                	li	a0,0
    80005260:	ffffe097          	auipc	ra,0xffffe
    80005264:	816080e7          	jalr	-2026(ra) # 80002a76 <argstr>
    return -1;
    80005268:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000526a:	10054e63          	bltz	a0,80005386 <sys_link+0x13c>
    8000526e:	08000613          	li	a2,128
    80005272:	f5040593          	addi	a1,s0,-176
    80005276:	4505                	li	a0,1
    80005278:	ffffd097          	auipc	ra,0xffffd
    8000527c:	7fe080e7          	jalr	2046(ra) # 80002a76 <argstr>
    return -1;
    80005280:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005282:	10054263          	bltz	a0,80005386 <sys_link+0x13c>
  begin_op();
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	cee080e7          	jalr	-786(ra) # 80003f74 <begin_op>
  if((ip = namei(old)) == 0){
    8000528e:	ed040513          	addi	a0,s0,-304
    80005292:	fffff097          	auipc	ra,0xfffff
    80005296:	ac6080e7          	jalr	-1338(ra) # 80003d58 <namei>
    8000529a:	84aa                	mv	s1,a0
    8000529c:	c551                	beqz	a0,80005328 <sys_link+0xde>
  ilock(ip);
    8000529e:	ffffe097          	auipc	ra,0xffffe
    800052a2:	306080e7          	jalr	774(ra) # 800035a4 <ilock>
  if(ip->type == T_DIR){
    800052a6:	04449703          	lh	a4,68(s1)
    800052aa:	4785                	li	a5,1
    800052ac:	08f70463          	beq	a4,a5,80005334 <sys_link+0xea>
  ip->nlink++;
    800052b0:	04a4d783          	lhu	a5,74(s1)
    800052b4:	2785                	addiw	a5,a5,1
    800052b6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052ba:	8526                	mv	a0,s1
    800052bc:	ffffe097          	auipc	ra,0xffffe
    800052c0:	21e080e7          	jalr	542(ra) # 800034da <iupdate>
  iunlock(ip);
    800052c4:	8526                	mv	a0,s1
    800052c6:	ffffe097          	auipc	ra,0xffffe
    800052ca:	3a0080e7          	jalr	928(ra) # 80003666 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800052ce:	fd040593          	addi	a1,s0,-48
    800052d2:	f5040513          	addi	a0,s0,-176
    800052d6:	fffff097          	auipc	ra,0xfffff
    800052da:	aa0080e7          	jalr	-1376(ra) # 80003d76 <nameiparent>
    800052de:	892a                	mv	s2,a0
    800052e0:	c935                	beqz	a0,80005354 <sys_link+0x10a>
  ilock(dp);
    800052e2:	ffffe097          	auipc	ra,0xffffe
    800052e6:	2c2080e7          	jalr	706(ra) # 800035a4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800052ea:	00092703          	lw	a4,0(s2)
    800052ee:	409c                	lw	a5,0(s1)
    800052f0:	04f71d63          	bne	a4,a5,8000534a <sys_link+0x100>
    800052f4:	40d0                	lw	a2,4(s1)
    800052f6:	fd040593          	addi	a1,s0,-48
    800052fa:	854a                	mv	a0,s2
    800052fc:	fffff097          	auipc	ra,0xfffff
    80005300:	99a080e7          	jalr	-1638(ra) # 80003c96 <dirlink>
    80005304:	04054363          	bltz	a0,8000534a <sys_link+0x100>
  iunlockput(dp);
    80005308:	854a                	mv	a0,s2
    8000530a:	ffffe097          	auipc	ra,0xffffe
    8000530e:	4fc080e7          	jalr	1276(ra) # 80003806 <iunlockput>
  iput(ip);
    80005312:	8526                	mv	a0,s1
    80005314:	ffffe097          	auipc	ra,0xffffe
    80005318:	44a080e7          	jalr	1098(ra) # 8000375e <iput>
  end_op();
    8000531c:	fffff097          	auipc	ra,0xfffff
    80005320:	cd8080e7          	jalr	-808(ra) # 80003ff4 <end_op>
  return 0;
    80005324:	4781                	li	a5,0
    80005326:	a085                	j	80005386 <sys_link+0x13c>
    end_op();
    80005328:	fffff097          	auipc	ra,0xfffff
    8000532c:	ccc080e7          	jalr	-820(ra) # 80003ff4 <end_op>
    return -1;
    80005330:	57fd                	li	a5,-1
    80005332:	a891                	j	80005386 <sys_link+0x13c>
    iunlockput(ip);
    80005334:	8526                	mv	a0,s1
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	4d0080e7          	jalr	1232(ra) # 80003806 <iunlockput>
    end_op();
    8000533e:	fffff097          	auipc	ra,0xfffff
    80005342:	cb6080e7          	jalr	-842(ra) # 80003ff4 <end_op>
    return -1;
    80005346:	57fd                	li	a5,-1
    80005348:	a83d                	j	80005386 <sys_link+0x13c>
    iunlockput(dp);
    8000534a:	854a                	mv	a0,s2
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	4ba080e7          	jalr	1210(ra) # 80003806 <iunlockput>
  ilock(ip);
    80005354:	8526                	mv	a0,s1
    80005356:	ffffe097          	auipc	ra,0xffffe
    8000535a:	24e080e7          	jalr	590(ra) # 800035a4 <ilock>
  ip->nlink--;
    8000535e:	04a4d783          	lhu	a5,74(s1)
    80005362:	37fd                	addiw	a5,a5,-1
    80005364:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005368:	8526                	mv	a0,s1
    8000536a:	ffffe097          	auipc	ra,0xffffe
    8000536e:	170080e7          	jalr	368(ra) # 800034da <iupdate>
  iunlockput(ip);
    80005372:	8526                	mv	a0,s1
    80005374:	ffffe097          	auipc	ra,0xffffe
    80005378:	492080e7          	jalr	1170(ra) # 80003806 <iunlockput>
  end_op();
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	c78080e7          	jalr	-904(ra) # 80003ff4 <end_op>
  return -1;
    80005384:	57fd                	li	a5,-1
}
    80005386:	853e                	mv	a0,a5
    80005388:	70b2                	ld	ra,296(sp)
    8000538a:	7412                	ld	s0,288(sp)
    8000538c:	64f2                	ld	s1,280(sp)
    8000538e:	6952                	ld	s2,272(sp)
    80005390:	6155                	addi	sp,sp,304
    80005392:	8082                	ret

0000000080005394 <sys_unlink>:
{
    80005394:	7151                	addi	sp,sp,-240
    80005396:	f586                	sd	ra,232(sp)
    80005398:	f1a2                	sd	s0,224(sp)
    8000539a:	eda6                	sd	s1,216(sp)
    8000539c:	e9ca                	sd	s2,208(sp)
    8000539e:	e5ce                	sd	s3,200(sp)
    800053a0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053a2:	08000613          	li	a2,128
    800053a6:	f3040593          	addi	a1,s0,-208
    800053aa:	4501                	li	a0,0
    800053ac:	ffffd097          	auipc	ra,0xffffd
    800053b0:	6ca080e7          	jalr	1738(ra) # 80002a76 <argstr>
    800053b4:	18054163          	bltz	a0,80005536 <sys_unlink+0x1a2>
  begin_op();
    800053b8:	fffff097          	auipc	ra,0xfffff
    800053bc:	bbc080e7          	jalr	-1092(ra) # 80003f74 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053c0:	fb040593          	addi	a1,s0,-80
    800053c4:	f3040513          	addi	a0,s0,-208
    800053c8:	fffff097          	auipc	ra,0xfffff
    800053cc:	9ae080e7          	jalr	-1618(ra) # 80003d76 <nameiparent>
    800053d0:	84aa                	mv	s1,a0
    800053d2:	c979                	beqz	a0,800054a8 <sys_unlink+0x114>
  ilock(dp);
    800053d4:	ffffe097          	auipc	ra,0xffffe
    800053d8:	1d0080e7          	jalr	464(ra) # 800035a4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053dc:	00003597          	auipc	a1,0x3
    800053e0:	30458593          	addi	a1,a1,772 # 800086e0 <syscalls+0x2c0>
    800053e4:	fb040513          	addi	a0,s0,-80
    800053e8:	ffffe097          	auipc	ra,0xffffe
    800053ec:	684080e7          	jalr	1668(ra) # 80003a6c <namecmp>
    800053f0:	14050a63          	beqz	a0,80005544 <sys_unlink+0x1b0>
    800053f4:	00003597          	auipc	a1,0x3
    800053f8:	2f458593          	addi	a1,a1,756 # 800086e8 <syscalls+0x2c8>
    800053fc:	fb040513          	addi	a0,s0,-80
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	66c080e7          	jalr	1644(ra) # 80003a6c <namecmp>
    80005408:	12050e63          	beqz	a0,80005544 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000540c:	f2c40613          	addi	a2,s0,-212
    80005410:	fb040593          	addi	a1,s0,-80
    80005414:	8526                	mv	a0,s1
    80005416:	ffffe097          	auipc	ra,0xffffe
    8000541a:	670080e7          	jalr	1648(ra) # 80003a86 <dirlookup>
    8000541e:	892a                	mv	s2,a0
    80005420:	12050263          	beqz	a0,80005544 <sys_unlink+0x1b0>
  ilock(ip);
    80005424:	ffffe097          	auipc	ra,0xffffe
    80005428:	180080e7          	jalr	384(ra) # 800035a4 <ilock>
  if(ip->nlink < 1)
    8000542c:	04a91783          	lh	a5,74(s2)
    80005430:	08f05263          	blez	a5,800054b4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005434:	04491703          	lh	a4,68(s2)
    80005438:	4785                	li	a5,1
    8000543a:	08f70563          	beq	a4,a5,800054c4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000543e:	4641                	li	a2,16
    80005440:	4581                	li	a1,0
    80005442:	fc040513          	addi	a0,s0,-64
    80005446:	ffffc097          	auipc	ra,0xffffc
    8000544a:	8ce080e7          	jalr	-1842(ra) # 80000d14 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000544e:	4741                	li	a4,16
    80005450:	f2c42683          	lw	a3,-212(s0)
    80005454:	fc040613          	addi	a2,s0,-64
    80005458:	4581                	li	a1,0
    8000545a:	8526                	mv	a0,s1
    8000545c:	ffffe097          	auipc	ra,0xffffe
    80005460:	4f4080e7          	jalr	1268(ra) # 80003950 <writei>
    80005464:	47c1                	li	a5,16
    80005466:	0af51563          	bne	a0,a5,80005510 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000546a:	04491703          	lh	a4,68(s2)
    8000546e:	4785                	li	a5,1
    80005470:	0af70863          	beq	a4,a5,80005520 <sys_unlink+0x18c>
  iunlockput(dp);
    80005474:	8526                	mv	a0,s1
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	390080e7          	jalr	912(ra) # 80003806 <iunlockput>
  ip->nlink--;
    8000547e:	04a95783          	lhu	a5,74(s2)
    80005482:	37fd                	addiw	a5,a5,-1
    80005484:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005488:	854a                	mv	a0,s2
    8000548a:	ffffe097          	auipc	ra,0xffffe
    8000548e:	050080e7          	jalr	80(ra) # 800034da <iupdate>
  iunlockput(ip);
    80005492:	854a                	mv	a0,s2
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	372080e7          	jalr	882(ra) # 80003806 <iunlockput>
  end_op();
    8000549c:	fffff097          	auipc	ra,0xfffff
    800054a0:	b58080e7          	jalr	-1192(ra) # 80003ff4 <end_op>
  return 0;
    800054a4:	4501                	li	a0,0
    800054a6:	a84d                	j	80005558 <sys_unlink+0x1c4>
    end_op();
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	b4c080e7          	jalr	-1204(ra) # 80003ff4 <end_op>
    return -1;
    800054b0:	557d                	li	a0,-1
    800054b2:	a05d                	j	80005558 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800054b4:	00003517          	auipc	a0,0x3
    800054b8:	25c50513          	addi	a0,a0,604 # 80008710 <syscalls+0x2f0>
    800054bc:	ffffb097          	auipc	ra,0xffffb
    800054c0:	094080e7          	jalr	148(ra) # 80000550 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054c4:	04c92703          	lw	a4,76(s2)
    800054c8:	02000793          	li	a5,32
    800054cc:	f6e7f9e3          	bgeu	a5,a4,8000543e <sys_unlink+0xaa>
    800054d0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054d4:	4741                	li	a4,16
    800054d6:	86ce                	mv	a3,s3
    800054d8:	f1840613          	addi	a2,s0,-232
    800054dc:	4581                	li	a1,0
    800054de:	854a                	mv	a0,s2
    800054e0:	ffffe097          	auipc	ra,0xffffe
    800054e4:	378080e7          	jalr	888(ra) # 80003858 <readi>
    800054e8:	47c1                	li	a5,16
    800054ea:	00f51b63          	bne	a0,a5,80005500 <sys_unlink+0x16c>
    if(de.inum != 0)
    800054ee:	f1845783          	lhu	a5,-232(s0)
    800054f2:	e7a1                	bnez	a5,8000553a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054f4:	29c1                	addiw	s3,s3,16
    800054f6:	04c92783          	lw	a5,76(s2)
    800054fa:	fcf9ede3          	bltu	s3,a5,800054d4 <sys_unlink+0x140>
    800054fe:	b781                	j	8000543e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005500:	00003517          	auipc	a0,0x3
    80005504:	22850513          	addi	a0,a0,552 # 80008728 <syscalls+0x308>
    80005508:	ffffb097          	auipc	ra,0xffffb
    8000550c:	048080e7          	jalr	72(ra) # 80000550 <panic>
    panic("unlink: writei");
    80005510:	00003517          	auipc	a0,0x3
    80005514:	23050513          	addi	a0,a0,560 # 80008740 <syscalls+0x320>
    80005518:	ffffb097          	auipc	ra,0xffffb
    8000551c:	038080e7          	jalr	56(ra) # 80000550 <panic>
    dp->nlink--;
    80005520:	04a4d783          	lhu	a5,74(s1)
    80005524:	37fd                	addiw	a5,a5,-1
    80005526:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000552a:	8526                	mv	a0,s1
    8000552c:	ffffe097          	auipc	ra,0xffffe
    80005530:	fae080e7          	jalr	-82(ra) # 800034da <iupdate>
    80005534:	b781                	j	80005474 <sys_unlink+0xe0>
    return -1;
    80005536:	557d                	li	a0,-1
    80005538:	a005                	j	80005558 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000553a:	854a                	mv	a0,s2
    8000553c:	ffffe097          	auipc	ra,0xffffe
    80005540:	2ca080e7          	jalr	714(ra) # 80003806 <iunlockput>
  iunlockput(dp);
    80005544:	8526                	mv	a0,s1
    80005546:	ffffe097          	auipc	ra,0xffffe
    8000554a:	2c0080e7          	jalr	704(ra) # 80003806 <iunlockput>
  end_op();
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	aa6080e7          	jalr	-1370(ra) # 80003ff4 <end_op>
  return -1;
    80005556:	557d                	li	a0,-1
}
    80005558:	70ae                	ld	ra,232(sp)
    8000555a:	740e                	ld	s0,224(sp)
    8000555c:	64ee                	ld	s1,216(sp)
    8000555e:	694e                	ld	s2,208(sp)
    80005560:	69ae                	ld	s3,200(sp)
    80005562:	616d                	addi	sp,sp,240
    80005564:	8082                	ret

0000000080005566 <sys_open>:

uint64
sys_open(void)
{
    80005566:	7131                	addi	sp,sp,-192
    80005568:	fd06                	sd	ra,184(sp)
    8000556a:	f922                	sd	s0,176(sp)
    8000556c:	f526                	sd	s1,168(sp)
    8000556e:	f14a                	sd	s2,160(sp)
    80005570:	ed4e                	sd	s3,152(sp)
    80005572:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005574:	08000613          	li	a2,128
    80005578:	f5040593          	addi	a1,s0,-176
    8000557c:	4501                	li	a0,0
    8000557e:	ffffd097          	auipc	ra,0xffffd
    80005582:	4f8080e7          	jalr	1272(ra) # 80002a76 <argstr>
    return -1;
    80005586:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005588:	0c054163          	bltz	a0,8000564a <sys_open+0xe4>
    8000558c:	f4c40593          	addi	a1,s0,-180
    80005590:	4505                	li	a0,1
    80005592:	ffffd097          	auipc	ra,0xffffd
    80005596:	4a0080e7          	jalr	1184(ra) # 80002a32 <argint>
    8000559a:	0a054863          	bltz	a0,8000564a <sys_open+0xe4>

  begin_op();
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	9d6080e7          	jalr	-1578(ra) # 80003f74 <begin_op>

  if(omode & O_CREATE){
    800055a6:	f4c42783          	lw	a5,-180(s0)
    800055aa:	2007f793          	andi	a5,a5,512
    800055ae:	cbdd                	beqz	a5,80005664 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800055b0:	4681                	li	a3,0
    800055b2:	4601                	li	a2,0
    800055b4:	4589                	li	a1,2
    800055b6:	f5040513          	addi	a0,s0,-176
    800055ba:	00000097          	auipc	ra,0x0
    800055be:	972080e7          	jalr	-1678(ra) # 80004f2c <create>
    800055c2:	892a                	mv	s2,a0
    if(ip == 0){
    800055c4:	c959                	beqz	a0,8000565a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055c6:	04491703          	lh	a4,68(s2)
    800055ca:	478d                	li	a5,3
    800055cc:	00f71763          	bne	a4,a5,800055da <sys_open+0x74>
    800055d0:	04695703          	lhu	a4,70(s2)
    800055d4:	47a5                	li	a5,9
    800055d6:	0ce7ec63          	bltu	a5,a4,800056ae <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055da:	fffff097          	auipc	ra,0xfffff
    800055de:	db2080e7          	jalr	-590(ra) # 8000438c <filealloc>
    800055e2:	89aa                	mv	s3,a0
    800055e4:	10050263          	beqz	a0,800056e8 <sys_open+0x182>
    800055e8:	00000097          	auipc	ra,0x0
    800055ec:	902080e7          	jalr	-1790(ra) # 80004eea <fdalloc>
    800055f0:	84aa                	mv	s1,a0
    800055f2:	0e054663          	bltz	a0,800056de <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800055f6:	04491703          	lh	a4,68(s2)
    800055fa:	478d                	li	a5,3
    800055fc:	0cf70463          	beq	a4,a5,800056c4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005600:	4789                	li	a5,2
    80005602:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005606:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000560a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000560e:	f4c42783          	lw	a5,-180(s0)
    80005612:	0017c713          	xori	a4,a5,1
    80005616:	8b05                	andi	a4,a4,1
    80005618:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000561c:	0037f713          	andi	a4,a5,3
    80005620:	00e03733          	snez	a4,a4
    80005624:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005628:	4007f793          	andi	a5,a5,1024
    8000562c:	c791                	beqz	a5,80005638 <sys_open+0xd2>
    8000562e:	04491703          	lh	a4,68(s2)
    80005632:	4789                	li	a5,2
    80005634:	08f70f63          	beq	a4,a5,800056d2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005638:	854a                	mv	a0,s2
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	02c080e7          	jalr	44(ra) # 80003666 <iunlock>
  end_op();
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	9b2080e7          	jalr	-1614(ra) # 80003ff4 <end_op>

  return fd;
}
    8000564a:	8526                	mv	a0,s1
    8000564c:	70ea                	ld	ra,184(sp)
    8000564e:	744a                	ld	s0,176(sp)
    80005650:	74aa                	ld	s1,168(sp)
    80005652:	790a                	ld	s2,160(sp)
    80005654:	69ea                	ld	s3,152(sp)
    80005656:	6129                	addi	sp,sp,192
    80005658:	8082                	ret
      end_op();
    8000565a:	fffff097          	auipc	ra,0xfffff
    8000565e:	99a080e7          	jalr	-1638(ra) # 80003ff4 <end_op>
      return -1;
    80005662:	b7e5                	j	8000564a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005664:	f5040513          	addi	a0,s0,-176
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	6f0080e7          	jalr	1776(ra) # 80003d58 <namei>
    80005670:	892a                	mv	s2,a0
    80005672:	c905                	beqz	a0,800056a2 <sys_open+0x13c>
    ilock(ip);
    80005674:	ffffe097          	auipc	ra,0xffffe
    80005678:	f30080e7          	jalr	-208(ra) # 800035a4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000567c:	04491703          	lh	a4,68(s2)
    80005680:	4785                	li	a5,1
    80005682:	f4f712e3          	bne	a4,a5,800055c6 <sys_open+0x60>
    80005686:	f4c42783          	lw	a5,-180(s0)
    8000568a:	dba1                	beqz	a5,800055da <sys_open+0x74>
      iunlockput(ip);
    8000568c:	854a                	mv	a0,s2
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	178080e7          	jalr	376(ra) # 80003806 <iunlockput>
      end_op();
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	95e080e7          	jalr	-1698(ra) # 80003ff4 <end_op>
      return -1;
    8000569e:	54fd                	li	s1,-1
    800056a0:	b76d                	j	8000564a <sys_open+0xe4>
      end_op();
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	952080e7          	jalr	-1710(ra) # 80003ff4 <end_op>
      return -1;
    800056aa:	54fd                	li	s1,-1
    800056ac:	bf79                	j	8000564a <sys_open+0xe4>
    iunlockput(ip);
    800056ae:	854a                	mv	a0,s2
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	156080e7          	jalr	342(ra) # 80003806 <iunlockput>
    end_op();
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	93c080e7          	jalr	-1732(ra) # 80003ff4 <end_op>
    return -1;
    800056c0:	54fd                	li	s1,-1
    800056c2:	b761                	j	8000564a <sys_open+0xe4>
    f->type = FD_DEVICE;
    800056c4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800056c8:	04691783          	lh	a5,70(s2)
    800056cc:	02f99223          	sh	a5,36(s3)
    800056d0:	bf2d                	j	8000560a <sys_open+0xa4>
    itrunc(ip);
    800056d2:	854a                	mv	a0,s2
    800056d4:	ffffe097          	auipc	ra,0xffffe
    800056d8:	fde080e7          	jalr	-34(ra) # 800036b2 <itrunc>
    800056dc:	bfb1                	j	80005638 <sys_open+0xd2>
      fileclose(f);
    800056de:	854e                	mv	a0,s3
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	d68080e7          	jalr	-664(ra) # 80004448 <fileclose>
    iunlockput(ip);
    800056e8:	854a                	mv	a0,s2
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	11c080e7          	jalr	284(ra) # 80003806 <iunlockput>
    end_op();
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	902080e7          	jalr	-1790(ra) # 80003ff4 <end_op>
    return -1;
    800056fa:	54fd                	li	s1,-1
    800056fc:	b7b9                	j	8000564a <sys_open+0xe4>

00000000800056fe <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800056fe:	7175                	addi	sp,sp,-144
    80005700:	e506                	sd	ra,136(sp)
    80005702:	e122                	sd	s0,128(sp)
    80005704:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	86e080e7          	jalr	-1938(ra) # 80003f74 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000570e:	08000613          	li	a2,128
    80005712:	f7040593          	addi	a1,s0,-144
    80005716:	4501                	li	a0,0
    80005718:	ffffd097          	auipc	ra,0xffffd
    8000571c:	35e080e7          	jalr	862(ra) # 80002a76 <argstr>
    80005720:	02054963          	bltz	a0,80005752 <sys_mkdir+0x54>
    80005724:	4681                	li	a3,0
    80005726:	4601                	li	a2,0
    80005728:	4585                	li	a1,1
    8000572a:	f7040513          	addi	a0,s0,-144
    8000572e:	fffff097          	auipc	ra,0xfffff
    80005732:	7fe080e7          	jalr	2046(ra) # 80004f2c <create>
    80005736:	cd11                	beqz	a0,80005752 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	0ce080e7          	jalr	206(ra) # 80003806 <iunlockput>
  end_op();
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	8b4080e7          	jalr	-1868(ra) # 80003ff4 <end_op>
  return 0;
    80005748:	4501                	li	a0,0
}
    8000574a:	60aa                	ld	ra,136(sp)
    8000574c:	640a                	ld	s0,128(sp)
    8000574e:	6149                	addi	sp,sp,144
    80005750:	8082                	ret
    end_op();
    80005752:	fffff097          	auipc	ra,0xfffff
    80005756:	8a2080e7          	jalr	-1886(ra) # 80003ff4 <end_op>
    return -1;
    8000575a:	557d                	li	a0,-1
    8000575c:	b7fd                	j	8000574a <sys_mkdir+0x4c>

000000008000575e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000575e:	7135                	addi	sp,sp,-160
    80005760:	ed06                	sd	ra,152(sp)
    80005762:	e922                	sd	s0,144(sp)
    80005764:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	80e080e7          	jalr	-2034(ra) # 80003f74 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000576e:	08000613          	li	a2,128
    80005772:	f7040593          	addi	a1,s0,-144
    80005776:	4501                	li	a0,0
    80005778:	ffffd097          	auipc	ra,0xffffd
    8000577c:	2fe080e7          	jalr	766(ra) # 80002a76 <argstr>
    80005780:	04054a63          	bltz	a0,800057d4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005784:	f6c40593          	addi	a1,s0,-148
    80005788:	4505                	li	a0,1
    8000578a:	ffffd097          	auipc	ra,0xffffd
    8000578e:	2a8080e7          	jalr	680(ra) # 80002a32 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005792:	04054163          	bltz	a0,800057d4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005796:	f6840593          	addi	a1,s0,-152
    8000579a:	4509                	li	a0,2
    8000579c:	ffffd097          	auipc	ra,0xffffd
    800057a0:	296080e7          	jalr	662(ra) # 80002a32 <argint>
     argint(1, &major) < 0 ||
    800057a4:	02054863          	bltz	a0,800057d4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800057a8:	f6841683          	lh	a3,-152(s0)
    800057ac:	f6c41603          	lh	a2,-148(s0)
    800057b0:	458d                	li	a1,3
    800057b2:	f7040513          	addi	a0,s0,-144
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	776080e7          	jalr	1910(ra) # 80004f2c <create>
     argint(2, &minor) < 0 ||
    800057be:	c919                	beqz	a0,800057d4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057c0:	ffffe097          	auipc	ra,0xffffe
    800057c4:	046080e7          	jalr	70(ra) # 80003806 <iunlockput>
  end_op();
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	82c080e7          	jalr	-2004(ra) # 80003ff4 <end_op>
  return 0;
    800057d0:	4501                	li	a0,0
    800057d2:	a031                	j	800057de <sys_mknod+0x80>
    end_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	820080e7          	jalr	-2016(ra) # 80003ff4 <end_op>
    return -1;
    800057dc:	557d                	li	a0,-1
}
    800057de:	60ea                	ld	ra,152(sp)
    800057e0:	644a                	ld	s0,144(sp)
    800057e2:	610d                	addi	sp,sp,160
    800057e4:	8082                	ret

00000000800057e6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800057e6:	7135                	addi	sp,sp,-160
    800057e8:	ed06                	sd	ra,152(sp)
    800057ea:	e922                	sd	s0,144(sp)
    800057ec:	e526                	sd	s1,136(sp)
    800057ee:	e14a                	sd	s2,128(sp)
    800057f0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800057f2:	ffffc097          	auipc	ra,0xffffc
    800057f6:	182080e7          	jalr	386(ra) # 80001974 <myproc>
    800057fa:	892a                	mv	s2,a0
  
  begin_op();
    800057fc:	ffffe097          	auipc	ra,0xffffe
    80005800:	778080e7          	jalr	1912(ra) # 80003f74 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005804:	08000613          	li	a2,128
    80005808:	f6040593          	addi	a1,s0,-160
    8000580c:	4501                	li	a0,0
    8000580e:	ffffd097          	auipc	ra,0xffffd
    80005812:	268080e7          	jalr	616(ra) # 80002a76 <argstr>
    80005816:	04054b63          	bltz	a0,8000586c <sys_chdir+0x86>
    8000581a:	f6040513          	addi	a0,s0,-160
    8000581e:	ffffe097          	auipc	ra,0xffffe
    80005822:	53a080e7          	jalr	1338(ra) # 80003d58 <namei>
    80005826:	84aa                	mv	s1,a0
    80005828:	c131                	beqz	a0,8000586c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	d7a080e7          	jalr	-646(ra) # 800035a4 <ilock>
  if(ip->type != T_DIR){
    80005832:	04449703          	lh	a4,68(s1)
    80005836:	4785                	li	a5,1
    80005838:	04f71063          	bne	a4,a5,80005878 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000583c:	8526                	mv	a0,s1
    8000583e:	ffffe097          	auipc	ra,0xffffe
    80005842:	e28080e7          	jalr	-472(ra) # 80003666 <iunlock>
  iput(p->cwd);
    80005846:	15093503          	ld	a0,336(s2)
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	f14080e7          	jalr	-236(ra) # 8000375e <iput>
  end_op();
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	7a2080e7          	jalr	1954(ra) # 80003ff4 <end_op>
  p->cwd = ip;
    8000585a:	14993823          	sd	s1,336(s2)
  return 0;
    8000585e:	4501                	li	a0,0
}
    80005860:	60ea                	ld	ra,152(sp)
    80005862:	644a                	ld	s0,144(sp)
    80005864:	64aa                	ld	s1,136(sp)
    80005866:	690a                	ld	s2,128(sp)
    80005868:	610d                	addi	sp,sp,160
    8000586a:	8082                	ret
    end_op();
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	788080e7          	jalr	1928(ra) # 80003ff4 <end_op>
    return -1;
    80005874:	557d                	li	a0,-1
    80005876:	b7ed                	j	80005860 <sys_chdir+0x7a>
    iunlockput(ip);
    80005878:	8526                	mv	a0,s1
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	f8c080e7          	jalr	-116(ra) # 80003806 <iunlockput>
    end_op();
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	772080e7          	jalr	1906(ra) # 80003ff4 <end_op>
    return -1;
    8000588a:	557d                	li	a0,-1
    8000588c:	bfd1                	j	80005860 <sys_chdir+0x7a>

000000008000588e <sys_exec>:

uint64
sys_exec(void)
{
    8000588e:	7145                	addi	sp,sp,-464
    80005890:	e786                	sd	ra,456(sp)
    80005892:	e3a2                	sd	s0,448(sp)
    80005894:	ff26                	sd	s1,440(sp)
    80005896:	fb4a                	sd	s2,432(sp)
    80005898:	f74e                	sd	s3,424(sp)
    8000589a:	f352                	sd	s4,416(sp)
    8000589c:	ef56                	sd	s5,408(sp)
    8000589e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800058a0:	08000613          	li	a2,128
    800058a4:	f4040593          	addi	a1,s0,-192
    800058a8:	4501                	li	a0,0
    800058aa:	ffffd097          	auipc	ra,0xffffd
    800058ae:	1cc080e7          	jalr	460(ra) # 80002a76 <argstr>
    return -1;
    800058b2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800058b4:	0c054a63          	bltz	a0,80005988 <sys_exec+0xfa>
    800058b8:	e3840593          	addi	a1,s0,-456
    800058bc:	4505                	li	a0,1
    800058be:	ffffd097          	auipc	ra,0xffffd
    800058c2:	196080e7          	jalr	406(ra) # 80002a54 <argaddr>
    800058c6:	0c054163          	bltz	a0,80005988 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800058ca:	10000613          	li	a2,256
    800058ce:	4581                	li	a1,0
    800058d0:	e4040513          	addi	a0,s0,-448
    800058d4:	ffffb097          	auipc	ra,0xffffb
    800058d8:	440080e7          	jalr	1088(ra) # 80000d14 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800058dc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800058e0:	89a6                	mv	s3,s1
    800058e2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800058e4:	02000a13          	li	s4,32
    800058e8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800058ec:	00391513          	slli	a0,s2,0x3
    800058f0:	e3040593          	addi	a1,s0,-464
    800058f4:	e3843783          	ld	a5,-456(s0)
    800058f8:	953e                	add	a0,a0,a5
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	09e080e7          	jalr	158(ra) # 80002998 <fetchaddr>
    80005902:	02054a63          	bltz	a0,80005936 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005906:	e3043783          	ld	a5,-464(s0)
    8000590a:	c3b9                	beqz	a5,80005950 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000590c:	ffffb097          	auipc	ra,0xffffb
    80005910:	21c080e7          	jalr	540(ra) # 80000b28 <kalloc>
    80005914:	85aa                	mv	a1,a0
    80005916:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000591a:	cd11                	beqz	a0,80005936 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000591c:	6605                	lui	a2,0x1
    8000591e:	e3043503          	ld	a0,-464(s0)
    80005922:	ffffd097          	auipc	ra,0xffffd
    80005926:	0c8080e7          	jalr	200(ra) # 800029ea <fetchstr>
    8000592a:	00054663          	bltz	a0,80005936 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000592e:	0905                	addi	s2,s2,1
    80005930:	09a1                	addi	s3,s3,8
    80005932:	fb491be3          	bne	s2,s4,800058e8 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005936:	10048913          	addi	s2,s1,256
    8000593a:	6088                	ld	a0,0(s1)
    8000593c:	c529                	beqz	a0,80005986 <sys_exec+0xf8>
    kfree(argv[i]);
    8000593e:	ffffb097          	auipc	ra,0xffffb
    80005942:	0ee080e7          	jalr	238(ra) # 80000a2c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005946:	04a1                	addi	s1,s1,8
    80005948:	ff2499e3          	bne	s1,s2,8000593a <sys_exec+0xac>
  return -1;
    8000594c:	597d                	li	s2,-1
    8000594e:	a82d                	j	80005988 <sys_exec+0xfa>
      argv[i] = 0;
    80005950:	0a8e                	slli	s5,s5,0x3
    80005952:	fc040793          	addi	a5,s0,-64
    80005956:	9abe                	add	s5,s5,a5
    80005958:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000595c:	e4040593          	addi	a1,s0,-448
    80005960:	f4040513          	addi	a0,s0,-192
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	194080e7          	jalr	404(ra) # 80004af8 <exec>
    8000596c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000596e:	10048993          	addi	s3,s1,256
    80005972:	6088                	ld	a0,0(s1)
    80005974:	c911                	beqz	a0,80005988 <sys_exec+0xfa>
    kfree(argv[i]);
    80005976:	ffffb097          	auipc	ra,0xffffb
    8000597a:	0b6080e7          	jalr	182(ra) # 80000a2c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000597e:	04a1                	addi	s1,s1,8
    80005980:	ff3499e3          	bne	s1,s3,80005972 <sys_exec+0xe4>
    80005984:	a011                	j	80005988 <sys_exec+0xfa>
  return -1;
    80005986:	597d                	li	s2,-1
}
    80005988:	854a                	mv	a0,s2
    8000598a:	60be                	ld	ra,456(sp)
    8000598c:	641e                	ld	s0,448(sp)
    8000598e:	74fa                	ld	s1,440(sp)
    80005990:	795a                	ld	s2,432(sp)
    80005992:	79ba                	ld	s3,424(sp)
    80005994:	7a1a                	ld	s4,416(sp)
    80005996:	6afa                	ld	s5,408(sp)
    80005998:	6179                	addi	sp,sp,464
    8000599a:	8082                	ret

000000008000599c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000599c:	7139                	addi	sp,sp,-64
    8000599e:	fc06                	sd	ra,56(sp)
    800059a0:	f822                	sd	s0,48(sp)
    800059a2:	f426                	sd	s1,40(sp)
    800059a4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059a6:	ffffc097          	auipc	ra,0xffffc
    800059aa:	fce080e7          	jalr	-50(ra) # 80001974 <myproc>
    800059ae:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800059b0:	fd840593          	addi	a1,s0,-40
    800059b4:	4501                	li	a0,0
    800059b6:	ffffd097          	auipc	ra,0xffffd
    800059ba:	09e080e7          	jalr	158(ra) # 80002a54 <argaddr>
    return -1;
    800059be:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800059c0:	0e054063          	bltz	a0,80005aa0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800059c4:	fc840593          	addi	a1,s0,-56
    800059c8:	fd040513          	addi	a0,s0,-48
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	dd2080e7          	jalr	-558(ra) # 8000479e <pipealloc>
    return -1;
    800059d4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800059d6:	0c054563          	bltz	a0,80005aa0 <sys_pipe+0x104>
  fd0 = -1;
    800059da:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800059de:	fd043503          	ld	a0,-48(s0)
    800059e2:	fffff097          	auipc	ra,0xfffff
    800059e6:	508080e7          	jalr	1288(ra) # 80004eea <fdalloc>
    800059ea:	fca42223          	sw	a0,-60(s0)
    800059ee:	08054c63          	bltz	a0,80005a86 <sys_pipe+0xea>
    800059f2:	fc843503          	ld	a0,-56(s0)
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	4f4080e7          	jalr	1268(ra) # 80004eea <fdalloc>
    800059fe:	fca42023          	sw	a0,-64(s0)
    80005a02:	06054863          	bltz	a0,80005a72 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a06:	4691                	li	a3,4
    80005a08:	fc440613          	addi	a2,s0,-60
    80005a0c:	fd843583          	ld	a1,-40(s0)
    80005a10:	68a8                	ld	a0,80(s1)
    80005a12:	ffffc097          	auipc	ra,0xffffc
    80005a16:	c56080e7          	jalr	-938(ra) # 80001668 <copyout>
    80005a1a:	02054063          	bltz	a0,80005a3a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a1e:	4691                	li	a3,4
    80005a20:	fc040613          	addi	a2,s0,-64
    80005a24:	fd843583          	ld	a1,-40(s0)
    80005a28:	0591                	addi	a1,a1,4
    80005a2a:	68a8                	ld	a0,80(s1)
    80005a2c:	ffffc097          	auipc	ra,0xffffc
    80005a30:	c3c080e7          	jalr	-964(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a34:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a36:	06055563          	bgez	a0,80005aa0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005a3a:	fc442783          	lw	a5,-60(s0)
    80005a3e:	07e9                	addi	a5,a5,26
    80005a40:	078e                	slli	a5,a5,0x3
    80005a42:	97a6                	add	a5,a5,s1
    80005a44:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005a48:	fc042503          	lw	a0,-64(s0)
    80005a4c:	0569                	addi	a0,a0,26
    80005a4e:	050e                	slli	a0,a0,0x3
    80005a50:	9526                	add	a0,a0,s1
    80005a52:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005a56:	fd043503          	ld	a0,-48(s0)
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	9ee080e7          	jalr	-1554(ra) # 80004448 <fileclose>
    fileclose(wf);
    80005a62:	fc843503          	ld	a0,-56(s0)
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	9e2080e7          	jalr	-1566(ra) # 80004448 <fileclose>
    return -1;
    80005a6e:	57fd                	li	a5,-1
    80005a70:	a805                	j	80005aa0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005a72:	fc442783          	lw	a5,-60(s0)
    80005a76:	0007c863          	bltz	a5,80005a86 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005a7a:	01a78513          	addi	a0,a5,26
    80005a7e:	050e                	slli	a0,a0,0x3
    80005a80:	9526                	add	a0,a0,s1
    80005a82:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005a86:	fd043503          	ld	a0,-48(s0)
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	9be080e7          	jalr	-1602(ra) # 80004448 <fileclose>
    fileclose(wf);
    80005a92:	fc843503          	ld	a0,-56(s0)
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	9b2080e7          	jalr	-1614(ra) # 80004448 <fileclose>
    return -1;
    80005a9e:	57fd                	li	a5,-1
}
    80005aa0:	853e                	mv	a0,a5
    80005aa2:	70e2                	ld	ra,56(sp)
    80005aa4:	7442                	ld	s0,48(sp)
    80005aa6:	74a2                	ld	s1,40(sp)
    80005aa8:	6121                	addi	sp,sp,64
    80005aaa:	8082                	ret
    80005aac:	0000                	unimp
	...

0000000080005ab0 <kernelvec>:
    80005ab0:	7111                	addi	sp,sp,-256
    80005ab2:	e006                	sd	ra,0(sp)
    80005ab4:	e40a                	sd	sp,8(sp)
    80005ab6:	e80e                	sd	gp,16(sp)
    80005ab8:	ec12                	sd	tp,24(sp)
    80005aba:	f016                	sd	t0,32(sp)
    80005abc:	f41a                	sd	t1,40(sp)
    80005abe:	f81e                	sd	t2,48(sp)
    80005ac0:	fc22                	sd	s0,56(sp)
    80005ac2:	e0a6                	sd	s1,64(sp)
    80005ac4:	e4aa                	sd	a0,72(sp)
    80005ac6:	e8ae                	sd	a1,80(sp)
    80005ac8:	ecb2                	sd	a2,88(sp)
    80005aca:	f0b6                	sd	a3,96(sp)
    80005acc:	f4ba                	sd	a4,104(sp)
    80005ace:	f8be                	sd	a5,112(sp)
    80005ad0:	fcc2                	sd	a6,120(sp)
    80005ad2:	e146                	sd	a7,128(sp)
    80005ad4:	e54a                	sd	s2,136(sp)
    80005ad6:	e94e                	sd	s3,144(sp)
    80005ad8:	ed52                	sd	s4,152(sp)
    80005ada:	f156                	sd	s5,160(sp)
    80005adc:	f55a                	sd	s6,168(sp)
    80005ade:	f95e                	sd	s7,176(sp)
    80005ae0:	fd62                	sd	s8,184(sp)
    80005ae2:	e1e6                	sd	s9,192(sp)
    80005ae4:	e5ea                	sd	s10,200(sp)
    80005ae6:	e9ee                	sd	s11,208(sp)
    80005ae8:	edf2                	sd	t3,216(sp)
    80005aea:	f1f6                	sd	t4,224(sp)
    80005aec:	f5fa                	sd	t5,232(sp)
    80005aee:	f9fe                	sd	t6,240(sp)
    80005af0:	d75fc0ef          	jal	ra,80002864 <kerneltrap>
    80005af4:	6082                	ld	ra,0(sp)
    80005af6:	6122                	ld	sp,8(sp)
    80005af8:	61c2                	ld	gp,16(sp)
    80005afa:	7282                	ld	t0,32(sp)
    80005afc:	7322                	ld	t1,40(sp)
    80005afe:	73c2                	ld	t2,48(sp)
    80005b00:	7462                	ld	s0,56(sp)
    80005b02:	6486                	ld	s1,64(sp)
    80005b04:	6526                	ld	a0,72(sp)
    80005b06:	65c6                	ld	a1,80(sp)
    80005b08:	6666                	ld	a2,88(sp)
    80005b0a:	7686                	ld	a3,96(sp)
    80005b0c:	7726                	ld	a4,104(sp)
    80005b0e:	77c6                	ld	a5,112(sp)
    80005b10:	7866                	ld	a6,120(sp)
    80005b12:	688a                	ld	a7,128(sp)
    80005b14:	692a                	ld	s2,136(sp)
    80005b16:	69ca                	ld	s3,144(sp)
    80005b18:	6a6a                	ld	s4,152(sp)
    80005b1a:	7a8a                	ld	s5,160(sp)
    80005b1c:	7b2a                	ld	s6,168(sp)
    80005b1e:	7bca                	ld	s7,176(sp)
    80005b20:	7c6a                	ld	s8,184(sp)
    80005b22:	6c8e                	ld	s9,192(sp)
    80005b24:	6d2e                	ld	s10,200(sp)
    80005b26:	6dce                	ld	s11,208(sp)
    80005b28:	6e6e                	ld	t3,216(sp)
    80005b2a:	7e8e                	ld	t4,224(sp)
    80005b2c:	7f2e                	ld	t5,232(sp)
    80005b2e:	7fce                	ld	t6,240(sp)
    80005b30:	6111                	addi	sp,sp,256
    80005b32:	10200073          	sret
    80005b36:	00000013          	nop
    80005b3a:	00000013          	nop
    80005b3e:	0001                	nop

0000000080005b40 <timervec>:
    80005b40:	34051573          	csrrw	a0,mscratch,a0
    80005b44:	e10c                	sd	a1,0(a0)
    80005b46:	e510                	sd	a2,8(a0)
    80005b48:	e914                	sd	a3,16(a0)
    80005b4a:	6d0c                	ld	a1,24(a0)
    80005b4c:	7110                	ld	a2,32(a0)
    80005b4e:	6194                	ld	a3,0(a1)
    80005b50:	96b2                	add	a3,a3,a2
    80005b52:	e194                	sd	a3,0(a1)
    80005b54:	4589                	li	a1,2
    80005b56:	14459073          	csrw	sip,a1
    80005b5a:	6914                	ld	a3,16(a0)
    80005b5c:	6510                	ld	a2,8(a0)
    80005b5e:	610c                	ld	a1,0(a0)
    80005b60:	34051573          	csrrw	a0,mscratch,a0
    80005b64:	30200073          	mret
	...

0000000080005b6a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b6a:	1141                	addi	sp,sp,-16
    80005b6c:	e422                	sd	s0,8(sp)
    80005b6e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005b70:	0c0007b7          	lui	a5,0xc000
    80005b74:	4705                	li	a4,1
    80005b76:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005b78:	c3d8                	sw	a4,4(a5)
}
    80005b7a:	6422                	ld	s0,8(sp)
    80005b7c:	0141                	addi	sp,sp,16
    80005b7e:	8082                	ret

0000000080005b80 <plicinithart>:

void
plicinithart(void)
{
    80005b80:	1141                	addi	sp,sp,-16
    80005b82:	e406                	sd	ra,8(sp)
    80005b84:	e022                	sd	s0,0(sp)
    80005b86:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b88:	ffffc097          	auipc	ra,0xffffc
    80005b8c:	dc0080e7          	jalr	-576(ra) # 80001948 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005b90:	0085171b          	slliw	a4,a0,0x8
    80005b94:	0c0027b7          	lui	a5,0xc002
    80005b98:	97ba                	add	a5,a5,a4
    80005b9a:	40200713          	li	a4,1026
    80005b9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ba2:	00d5151b          	slliw	a0,a0,0xd
    80005ba6:	0c2017b7          	lui	a5,0xc201
    80005baa:	953e                	add	a0,a0,a5
    80005bac:	00052023          	sw	zero,0(a0)
}
    80005bb0:	60a2                	ld	ra,8(sp)
    80005bb2:	6402                	ld	s0,0(sp)
    80005bb4:	0141                	addi	sp,sp,16
    80005bb6:	8082                	ret

0000000080005bb8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005bb8:	1141                	addi	sp,sp,-16
    80005bba:	e406                	sd	ra,8(sp)
    80005bbc:	e022                	sd	s0,0(sp)
    80005bbe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bc0:	ffffc097          	auipc	ra,0xffffc
    80005bc4:	d88080e7          	jalr	-632(ra) # 80001948 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005bc8:	00d5179b          	slliw	a5,a0,0xd
    80005bcc:	0c201537          	lui	a0,0xc201
    80005bd0:	953e                	add	a0,a0,a5
  return irq;
}
    80005bd2:	4148                	lw	a0,4(a0)
    80005bd4:	60a2                	ld	ra,8(sp)
    80005bd6:	6402                	ld	s0,0(sp)
    80005bd8:	0141                	addi	sp,sp,16
    80005bda:	8082                	ret

0000000080005bdc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005bdc:	1101                	addi	sp,sp,-32
    80005bde:	ec06                	sd	ra,24(sp)
    80005be0:	e822                	sd	s0,16(sp)
    80005be2:	e426                	sd	s1,8(sp)
    80005be4:	1000                	addi	s0,sp,32
    80005be6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005be8:	ffffc097          	auipc	ra,0xffffc
    80005bec:	d60080e7          	jalr	-672(ra) # 80001948 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005bf0:	00d5151b          	slliw	a0,a0,0xd
    80005bf4:	0c2017b7          	lui	a5,0xc201
    80005bf8:	97aa                	add	a5,a5,a0
    80005bfa:	c3c4                	sw	s1,4(a5)
}
    80005bfc:	60e2                	ld	ra,24(sp)
    80005bfe:	6442                	ld	s0,16(sp)
    80005c00:	64a2                	ld	s1,8(sp)
    80005c02:	6105                	addi	sp,sp,32
    80005c04:	8082                	ret

0000000080005c06 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c06:	1141                	addi	sp,sp,-16
    80005c08:	e406                	sd	ra,8(sp)
    80005c0a:	e022                	sd	s0,0(sp)
    80005c0c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c0e:	479d                	li	a5,7
    80005c10:	06a7c963          	blt	a5,a0,80005c82 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80005c14:	0001d797          	auipc	a5,0x1d
    80005c18:	3ec78793          	addi	a5,a5,1004 # 80023000 <disk>
    80005c1c:	00a78733          	add	a4,a5,a0
    80005c20:	6789                	lui	a5,0x2
    80005c22:	97ba                	add	a5,a5,a4
    80005c24:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005c28:	e7ad                	bnez	a5,80005c92 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c2a:	00451793          	slli	a5,a0,0x4
    80005c2e:	0001f717          	auipc	a4,0x1f
    80005c32:	3d270713          	addi	a4,a4,978 # 80025000 <disk+0x2000>
    80005c36:	6314                	ld	a3,0(a4)
    80005c38:	96be                	add	a3,a3,a5
    80005c3a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005c3e:	6314                	ld	a3,0(a4)
    80005c40:	96be                	add	a3,a3,a5
    80005c42:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005c46:	6314                	ld	a3,0(a4)
    80005c48:	96be                	add	a3,a3,a5
    80005c4a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005c4e:	6318                	ld	a4,0(a4)
    80005c50:	97ba                	add	a5,a5,a4
    80005c52:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005c56:	0001d797          	auipc	a5,0x1d
    80005c5a:	3aa78793          	addi	a5,a5,938 # 80023000 <disk>
    80005c5e:	97aa                	add	a5,a5,a0
    80005c60:	6509                	lui	a0,0x2
    80005c62:	953e                	add	a0,a0,a5
    80005c64:	4785                	li	a5,1
    80005c66:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005c6a:	0001f517          	auipc	a0,0x1f
    80005c6e:	3ae50513          	addi	a0,a0,942 # 80025018 <disk+0x2018>
    80005c72:	ffffc097          	auipc	ra,0xffffc
    80005c76:	698080e7          	jalr	1688(ra) # 8000230a <wakeup>
}
    80005c7a:	60a2                	ld	ra,8(sp)
    80005c7c:	6402                	ld	s0,0(sp)
    80005c7e:	0141                	addi	sp,sp,16
    80005c80:	8082                	ret
    panic("free_desc 1");
    80005c82:	00003517          	auipc	a0,0x3
    80005c86:	ace50513          	addi	a0,a0,-1330 # 80008750 <syscalls+0x330>
    80005c8a:	ffffb097          	auipc	ra,0xffffb
    80005c8e:	8c6080e7          	jalr	-1850(ra) # 80000550 <panic>
    panic("free_desc 2");
    80005c92:	00003517          	auipc	a0,0x3
    80005c96:	ace50513          	addi	a0,a0,-1330 # 80008760 <syscalls+0x340>
    80005c9a:	ffffb097          	auipc	ra,0xffffb
    80005c9e:	8b6080e7          	jalr	-1866(ra) # 80000550 <panic>

0000000080005ca2 <virtio_disk_init>:
{
    80005ca2:	1101                	addi	sp,sp,-32
    80005ca4:	ec06                	sd	ra,24(sp)
    80005ca6:	e822                	sd	s0,16(sp)
    80005ca8:	e426                	sd	s1,8(sp)
    80005caa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005cac:	00003597          	auipc	a1,0x3
    80005cb0:	ac458593          	addi	a1,a1,-1340 # 80008770 <syscalls+0x350>
    80005cb4:	0001f517          	auipc	a0,0x1f
    80005cb8:	47450513          	addi	a0,a0,1140 # 80025128 <disk+0x2128>
    80005cbc:	ffffb097          	auipc	ra,0xffffb
    80005cc0:	ecc080e7          	jalr	-308(ra) # 80000b88 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cc4:	100017b7          	lui	a5,0x10001
    80005cc8:	4398                	lw	a4,0(a5)
    80005cca:	2701                	sext.w	a4,a4
    80005ccc:	747277b7          	lui	a5,0x74727
    80005cd0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005cd4:	0ef71163          	bne	a4,a5,80005db6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005cd8:	100017b7          	lui	a5,0x10001
    80005cdc:	43dc                	lw	a5,4(a5)
    80005cde:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ce0:	4705                	li	a4,1
    80005ce2:	0ce79a63          	bne	a5,a4,80005db6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ce6:	100017b7          	lui	a5,0x10001
    80005cea:	479c                	lw	a5,8(a5)
    80005cec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005cee:	4709                	li	a4,2
    80005cf0:	0ce79363          	bne	a5,a4,80005db6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005cf4:	100017b7          	lui	a5,0x10001
    80005cf8:	47d8                	lw	a4,12(a5)
    80005cfa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cfc:	554d47b7          	lui	a5,0x554d4
    80005d00:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d04:	0af71963          	bne	a4,a5,80005db6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d08:	100017b7          	lui	a5,0x10001
    80005d0c:	4705                	li	a4,1
    80005d0e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d10:	470d                	li	a4,3
    80005d12:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d14:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005d16:	c7ffe737          	lui	a4,0xc7ffe
    80005d1a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005d1e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d20:	2701                	sext.w	a4,a4
    80005d22:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d24:	472d                	li	a4,11
    80005d26:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d28:	473d                	li	a4,15
    80005d2a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005d2c:	6705                	lui	a4,0x1
    80005d2e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d30:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d34:	5bdc                	lw	a5,52(a5)
    80005d36:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d38:	c7d9                	beqz	a5,80005dc6 <virtio_disk_init+0x124>
  if(max < NUM)
    80005d3a:	471d                	li	a4,7
    80005d3c:	08f77d63          	bgeu	a4,a5,80005dd6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d40:	100014b7          	lui	s1,0x10001
    80005d44:	47a1                	li	a5,8
    80005d46:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005d48:	6609                	lui	a2,0x2
    80005d4a:	4581                	li	a1,0
    80005d4c:	0001d517          	auipc	a0,0x1d
    80005d50:	2b450513          	addi	a0,a0,692 # 80023000 <disk>
    80005d54:	ffffb097          	auipc	ra,0xffffb
    80005d58:	fc0080e7          	jalr	-64(ra) # 80000d14 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005d5c:	0001d717          	auipc	a4,0x1d
    80005d60:	2a470713          	addi	a4,a4,676 # 80023000 <disk>
    80005d64:	00c75793          	srli	a5,a4,0xc
    80005d68:	2781                	sext.w	a5,a5
    80005d6a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005d6c:	0001f797          	auipc	a5,0x1f
    80005d70:	29478793          	addi	a5,a5,660 # 80025000 <disk+0x2000>
    80005d74:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005d76:	0001d717          	auipc	a4,0x1d
    80005d7a:	30a70713          	addi	a4,a4,778 # 80023080 <disk+0x80>
    80005d7e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005d80:	0001e717          	auipc	a4,0x1e
    80005d84:	28070713          	addi	a4,a4,640 # 80024000 <disk+0x1000>
    80005d88:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005d8a:	4705                	li	a4,1
    80005d8c:	00e78c23          	sb	a4,24(a5)
    80005d90:	00e78ca3          	sb	a4,25(a5)
    80005d94:	00e78d23          	sb	a4,26(a5)
    80005d98:	00e78da3          	sb	a4,27(a5)
    80005d9c:	00e78e23          	sb	a4,28(a5)
    80005da0:	00e78ea3          	sb	a4,29(a5)
    80005da4:	00e78f23          	sb	a4,30(a5)
    80005da8:	00e78fa3          	sb	a4,31(a5)
}
    80005dac:	60e2                	ld	ra,24(sp)
    80005dae:	6442                	ld	s0,16(sp)
    80005db0:	64a2                	ld	s1,8(sp)
    80005db2:	6105                	addi	sp,sp,32
    80005db4:	8082                	ret
    panic("could not find virtio disk");
    80005db6:	00003517          	auipc	a0,0x3
    80005dba:	9ca50513          	addi	a0,a0,-1590 # 80008780 <syscalls+0x360>
    80005dbe:	ffffa097          	auipc	ra,0xffffa
    80005dc2:	792080e7          	jalr	1938(ra) # 80000550 <panic>
    panic("virtio disk has no queue 0");
    80005dc6:	00003517          	auipc	a0,0x3
    80005dca:	9da50513          	addi	a0,a0,-1574 # 800087a0 <syscalls+0x380>
    80005dce:	ffffa097          	auipc	ra,0xffffa
    80005dd2:	782080e7          	jalr	1922(ra) # 80000550 <panic>
    panic("virtio disk max queue too short");
    80005dd6:	00003517          	auipc	a0,0x3
    80005dda:	9ea50513          	addi	a0,a0,-1558 # 800087c0 <syscalls+0x3a0>
    80005dde:	ffffa097          	auipc	ra,0xffffa
    80005de2:	772080e7          	jalr	1906(ra) # 80000550 <panic>

0000000080005de6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005de6:	7159                	addi	sp,sp,-112
    80005de8:	f486                	sd	ra,104(sp)
    80005dea:	f0a2                	sd	s0,96(sp)
    80005dec:	eca6                	sd	s1,88(sp)
    80005dee:	e8ca                	sd	s2,80(sp)
    80005df0:	e4ce                	sd	s3,72(sp)
    80005df2:	e0d2                	sd	s4,64(sp)
    80005df4:	fc56                	sd	s5,56(sp)
    80005df6:	f85a                	sd	s6,48(sp)
    80005df8:	f45e                	sd	s7,40(sp)
    80005dfa:	f062                	sd	s8,32(sp)
    80005dfc:	ec66                	sd	s9,24(sp)
    80005dfe:	e86a                	sd	s10,16(sp)
    80005e00:	1880                	addi	s0,sp,112
    80005e02:	892a                	mv	s2,a0
    80005e04:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e06:	00c52c83          	lw	s9,12(a0)
    80005e0a:	001c9c9b          	slliw	s9,s9,0x1
    80005e0e:	1c82                	slli	s9,s9,0x20
    80005e10:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005e14:	0001f517          	auipc	a0,0x1f
    80005e18:	31450513          	addi	a0,a0,788 # 80025128 <disk+0x2128>
    80005e1c:	ffffb097          	auipc	ra,0xffffb
    80005e20:	dfc080e7          	jalr	-516(ra) # 80000c18 <acquire>
  for(int i = 0; i < 3; i++){
    80005e24:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005e26:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005e28:	0001db97          	auipc	s7,0x1d
    80005e2c:	1d8b8b93          	addi	s7,s7,472 # 80023000 <disk>
    80005e30:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005e32:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005e34:	8a4e                	mv	s4,s3
    80005e36:	a051                	j	80005eba <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005e38:	00fb86b3          	add	a3,s7,a5
    80005e3c:	96da                	add	a3,a3,s6
    80005e3e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005e42:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005e44:	0207c563          	bltz	a5,80005e6e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005e48:	2485                	addiw	s1,s1,1
    80005e4a:	0711                	addi	a4,a4,4
    80005e4c:	25548063          	beq	s1,s5,8000608c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80005e50:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005e52:	0001f697          	auipc	a3,0x1f
    80005e56:	1c668693          	addi	a3,a3,454 # 80025018 <disk+0x2018>
    80005e5a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005e5c:	0006c583          	lbu	a1,0(a3)
    80005e60:	fde1                	bnez	a1,80005e38 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005e62:	2785                	addiw	a5,a5,1
    80005e64:	0685                	addi	a3,a3,1
    80005e66:	ff879be3          	bne	a5,s8,80005e5c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005e6a:	57fd                	li	a5,-1
    80005e6c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005e6e:	02905a63          	blez	s1,80005ea2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e72:	f9042503          	lw	a0,-112(s0)
    80005e76:	00000097          	auipc	ra,0x0
    80005e7a:	d90080e7          	jalr	-624(ra) # 80005c06 <free_desc>
      for(int j = 0; j < i; j++)
    80005e7e:	4785                	li	a5,1
    80005e80:	0297d163          	bge	a5,s1,80005ea2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e84:	f9442503          	lw	a0,-108(s0)
    80005e88:	00000097          	auipc	ra,0x0
    80005e8c:	d7e080e7          	jalr	-642(ra) # 80005c06 <free_desc>
      for(int j = 0; j < i; j++)
    80005e90:	4789                	li	a5,2
    80005e92:	0097d863          	bge	a5,s1,80005ea2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005e96:	f9842503          	lw	a0,-104(s0)
    80005e9a:	00000097          	auipc	ra,0x0
    80005e9e:	d6c080e7          	jalr	-660(ra) # 80005c06 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ea2:	0001f597          	auipc	a1,0x1f
    80005ea6:	28658593          	addi	a1,a1,646 # 80025128 <disk+0x2128>
    80005eaa:	0001f517          	auipc	a0,0x1f
    80005eae:	16e50513          	addi	a0,a0,366 # 80025018 <disk+0x2018>
    80005eb2:	ffffc097          	auipc	ra,0xffffc
    80005eb6:	2d2080e7          	jalr	722(ra) # 80002184 <sleep>
  for(int i = 0; i < 3; i++){
    80005eba:	f9040713          	addi	a4,s0,-112
    80005ebe:	84ce                	mv	s1,s3
    80005ec0:	bf41                	j	80005e50 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005ec2:	20058713          	addi	a4,a1,512
    80005ec6:	00471693          	slli	a3,a4,0x4
    80005eca:	0001d717          	auipc	a4,0x1d
    80005ece:	13670713          	addi	a4,a4,310 # 80023000 <disk>
    80005ed2:	9736                	add	a4,a4,a3
    80005ed4:	4685                	li	a3,1
    80005ed6:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005eda:	20058713          	addi	a4,a1,512
    80005ede:	00471693          	slli	a3,a4,0x4
    80005ee2:	0001d717          	auipc	a4,0x1d
    80005ee6:	11e70713          	addi	a4,a4,286 # 80023000 <disk>
    80005eea:	9736                	add	a4,a4,a3
    80005eec:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80005ef0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ef4:	7679                	lui	a2,0xffffe
    80005ef6:	963e                	add	a2,a2,a5
    80005ef8:	0001f697          	auipc	a3,0x1f
    80005efc:	10868693          	addi	a3,a3,264 # 80025000 <disk+0x2000>
    80005f00:	6298                	ld	a4,0(a3)
    80005f02:	9732                	add	a4,a4,a2
    80005f04:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005f06:	6298                	ld	a4,0(a3)
    80005f08:	9732                	add	a4,a4,a2
    80005f0a:	4541                	li	a0,16
    80005f0c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005f0e:	6298                	ld	a4,0(a3)
    80005f10:	9732                	add	a4,a4,a2
    80005f12:	4505                	li	a0,1
    80005f14:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80005f18:	f9442703          	lw	a4,-108(s0)
    80005f1c:	6288                	ld	a0,0(a3)
    80005f1e:	962a                	add	a2,a2,a0
    80005f20:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005f24:	0712                	slli	a4,a4,0x4
    80005f26:	6290                	ld	a2,0(a3)
    80005f28:	963a                	add	a2,a2,a4
    80005f2a:	05890513          	addi	a0,s2,88
    80005f2e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005f30:	6294                	ld	a3,0(a3)
    80005f32:	96ba                	add	a3,a3,a4
    80005f34:	40000613          	li	a2,1024
    80005f38:	c690                	sw	a2,8(a3)
  if(write)
    80005f3a:	140d0063          	beqz	s10,8000607a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005f3e:	0001f697          	auipc	a3,0x1f
    80005f42:	0c26b683          	ld	a3,194(a3) # 80025000 <disk+0x2000>
    80005f46:	96ba                	add	a3,a3,a4
    80005f48:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005f4c:	0001d817          	auipc	a6,0x1d
    80005f50:	0b480813          	addi	a6,a6,180 # 80023000 <disk>
    80005f54:	0001f517          	auipc	a0,0x1f
    80005f58:	0ac50513          	addi	a0,a0,172 # 80025000 <disk+0x2000>
    80005f5c:	6114                	ld	a3,0(a0)
    80005f5e:	96ba                	add	a3,a3,a4
    80005f60:	00c6d603          	lhu	a2,12(a3)
    80005f64:	00166613          	ori	a2,a2,1
    80005f68:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005f6c:	f9842683          	lw	a3,-104(s0)
    80005f70:	6110                	ld	a2,0(a0)
    80005f72:	9732                	add	a4,a4,a2
    80005f74:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005f78:	20058613          	addi	a2,a1,512
    80005f7c:	0612                	slli	a2,a2,0x4
    80005f7e:	9642                	add	a2,a2,a6
    80005f80:	577d                	li	a4,-1
    80005f82:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005f86:	00469713          	slli	a4,a3,0x4
    80005f8a:	6114                	ld	a3,0(a0)
    80005f8c:	96ba                	add	a3,a3,a4
    80005f8e:	03078793          	addi	a5,a5,48
    80005f92:	97c2                	add	a5,a5,a6
    80005f94:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80005f96:	611c                	ld	a5,0(a0)
    80005f98:	97ba                	add	a5,a5,a4
    80005f9a:	4685                	li	a3,1
    80005f9c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f9e:	611c                	ld	a5,0(a0)
    80005fa0:	97ba                	add	a5,a5,a4
    80005fa2:	4809                	li	a6,2
    80005fa4:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80005fa8:	611c                	ld	a5,0(a0)
    80005faa:	973e                	add	a4,a4,a5
    80005fac:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005fb0:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80005fb4:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005fb8:	6518                	ld	a4,8(a0)
    80005fba:	00275783          	lhu	a5,2(a4)
    80005fbe:	8b9d                	andi	a5,a5,7
    80005fc0:	0786                	slli	a5,a5,0x1
    80005fc2:	97ba                	add	a5,a5,a4
    80005fc4:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005fc8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005fcc:	6518                	ld	a4,8(a0)
    80005fce:	00275783          	lhu	a5,2(a4)
    80005fd2:	2785                	addiw	a5,a5,1
    80005fd4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005fd8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005fdc:	100017b7          	lui	a5,0x10001
    80005fe0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005fe4:	00492703          	lw	a4,4(s2)
    80005fe8:	4785                	li	a5,1
    80005fea:	02f71163          	bne	a4,a5,8000600c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    80005fee:	0001f997          	auipc	s3,0x1f
    80005ff2:	13a98993          	addi	s3,s3,314 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80005ff6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005ff8:	85ce                	mv	a1,s3
    80005ffa:	854a                	mv	a0,s2
    80005ffc:	ffffc097          	auipc	ra,0xffffc
    80006000:	188080e7          	jalr	392(ra) # 80002184 <sleep>
  while(b->disk == 1) {
    80006004:	00492783          	lw	a5,4(s2)
    80006008:	fe9788e3          	beq	a5,s1,80005ff8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000600c:	f9042903          	lw	s2,-112(s0)
    80006010:	20090793          	addi	a5,s2,512
    80006014:	00479713          	slli	a4,a5,0x4
    80006018:	0001d797          	auipc	a5,0x1d
    8000601c:	fe878793          	addi	a5,a5,-24 # 80023000 <disk>
    80006020:	97ba                	add	a5,a5,a4
    80006022:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006026:	0001f997          	auipc	s3,0x1f
    8000602a:	fda98993          	addi	s3,s3,-38 # 80025000 <disk+0x2000>
    8000602e:	00491713          	slli	a4,s2,0x4
    80006032:	0009b783          	ld	a5,0(s3)
    80006036:	97ba                	add	a5,a5,a4
    80006038:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000603c:	854a                	mv	a0,s2
    8000603e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006042:	00000097          	auipc	ra,0x0
    80006046:	bc4080e7          	jalr	-1084(ra) # 80005c06 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000604a:	8885                	andi	s1,s1,1
    8000604c:	f0ed                	bnez	s1,8000602e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000604e:	0001f517          	auipc	a0,0x1f
    80006052:	0da50513          	addi	a0,a0,218 # 80025128 <disk+0x2128>
    80006056:	ffffb097          	auipc	ra,0xffffb
    8000605a:	c76080e7          	jalr	-906(ra) # 80000ccc <release>
}
    8000605e:	70a6                	ld	ra,104(sp)
    80006060:	7406                	ld	s0,96(sp)
    80006062:	64e6                	ld	s1,88(sp)
    80006064:	6946                	ld	s2,80(sp)
    80006066:	69a6                	ld	s3,72(sp)
    80006068:	6a06                	ld	s4,64(sp)
    8000606a:	7ae2                	ld	s5,56(sp)
    8000606c:	7b42                	ld	s6,48(sp)
    8000606e:	7ba2                	ld	s7,40(sp)
    80006070:	7c02                	ld	s8,32(sp)
    80006072:	6ce2                	ld	s9,24(sp)
    80006074:	6d42                	ld	s10,16(sp)
    80006076:	6165                	addi	sp,sp,112
    80006078:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000607a:	0001f697          	auipc	a3,0x1f
    8000607e:	f866b683          	ld	a3,-122(a3) # 80025000 <disk+0x2000>
    80006082:	96ba                	add	a3,a3,a4
    80006084:	4609                	li	a2,2
    80006086:	00c69623          	sh	a2,12(a3)
    8000608a:	b5c9                	j	80005f4c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000608c:	f9042583          	lw	a1,-112(s0)
    80006090:	20058793          	addi	a5,a1,512
    80006094:	0792                	slli	a5,a5,0x4
    80006096:	0001d517          	auipc	a0,0x1d
    8000609a:	01250513          	addi	a0,a0,18 # 800230a8 <disk+0xa8>
    8000609e:	953e                	add	a0,a0,a5
  if(write)
    800060a0:	e20d11e3          	bnez	s10,80005ec2 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800060a4:	20058713          	addi	a4,a1,512
    800060a8:	00471693          	slli	a3,a4,0x4
    800060ac:	0001d717          	auipc	a4,0x1d
    800060b0:	f5470713          	addi	a4,a4,-172 # 80023000 <disk>
    800060b4:	9736                	add	a4,a4,a3
    800060b6:	0a072423          	sw	zero,168(a4)
    800060ba:	b505                	j	80005eda <virtio_disk_rw+0xf4>

00000000800060bc <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800060bc:	1101                	addi	sp,sp,-32
    800060be:	ec06                	sd	ra,24(sp)
    800060c0:	e822                	sd	s0,16(sp)
    800060c2:	e426                	sd	s1,8(sp)
    800060c4:	e04a                	sd	s2,0(sp)
    800060c6:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800060c8:	0001f517          	auipc	a0,0x1f
    800060cc:	06050513          	addi	a0,a0,96 # 80025128 <disk+0x2128>
    800060d0:	ffffb097          	auipc	ra,0xffffb
    800060d4:	b48080e7          	jalr	-1208(ra) # 80000c18 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800060d8:	10001737          	lui	a4,0x10001
    800060dc:	533c                	lw	a5,96(a4)
    800060de:	8b8d                	andi	a5,a5,3
    800060e0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800060e2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800060e6:	0001f797          	auipc	a5,0x1f
    800060ea:	f1a78793          	addi	a5,a5,-230 # 80025000 <disk+0x2000>
    800060ee:	6b94                	ld	a3,16(a5)
    800060f0:	0207d703          	lhu	a4,32(a5)
    800060f4:	0026d783          	lhu	a5,2(a3)
    800060f8:	06f70163          	beq	a4,a5,8000615a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800060fc:	0001d917          	auipc	s2,0x1d
    80006100:	f0490913          	addi	s2,s2,-252 # 80023000 <disk>
    80006104:	0001f497          	auipc	s1,0x1f
    80006108:	efc48493          	addi	s1,s1,-260 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000610c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006110:	6898                	ld	a4,16(s1)
    80006112:	0204d783          	lhu	a5,32(s1)
    80006116:	8b9d                	andi	a5,a5,7
    80006118:	078e                	slli	a5,a5,0x3
    8000611a:	97ba                	add	a5,a5,a4
    8000611c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000611e:	20078713          	addi	a4,a5,512
    80006122:	0712                	slli	a4,a4,0x4
    80006124:	974a                	add	a4,a4,s2
    80006126:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000612a:	e731                	bnez	a4,80006176 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000612c:	20078793          	addi	a5,a5,512
    80006130:	0792                	slli	a5,a5,0x4
    80006132:	97ca                	add	a5,a5,s2
    80006134:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006136:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000613a:	ffffc097          	auipc	ra,0xffffc
    8000613e:	1d0080e7          	jalr	464(ra) # 8000230a <wakeup>

    disk.used_idx += 1;
    80006142:	0204d783          	lhu	a5,32(s1)
    80006146:	2785                	addiw	a5,a5,1
    80006148:	17c2                	slli	a5,a5,0x30
    8000614a:	93c1                	srli	a5,a5,0x30
    8000614c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006150:	6898                	ld	a4,16(s1)
    80006152:	00275703          	lhu	a4,2(a4)
    80006156:	faf71be3          	bne	a4,a5,8000610c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000615a:	0001f517          	auipc	a0,0x1f
    8000615e:	fce50513          	addi	a0,a0,-50 # 80025128 <disk+0x2128>
    80006162:	ffffb097          	auipc	ra,0xffffb
    80006166:	b6a080e7          	jalr	-1174(ra) # 80000ccc <release>
}
    8000616a:	60e2                	ld	ra,24(sp)
    8000616c:	6442                	ld	s0,16(sp)
    8000616e:	64a2                	ld	s1,8(sp)
    80006170:	6902                	ld	s2,0(sp)
    80006172:	6105                	addi	sp,sp,32
    80006174:	8082                	ret
      panic("virtio_disk_intr status");
    80006176:	00002517          	auipc	a0,0x2
    8000617a:	66a50513          	addi	a0,a0,1642 # 800087e0 <syscalls+0x3c0>
    8000617e:	ffffa097          	auipc	ra,0xffffa
    80006182:	3d2080e7          	jalr	978(ra) # 80000550 <panic>
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
