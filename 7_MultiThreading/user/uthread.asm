
user/_uthread:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_init>:
struct thread *current_thread;
extern void thread_switch(uint64, uint64);
              
void 
thread_init(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
   6:	00001797          	auipc	a5,0x1
   a:	d4a78793          	addi	a5,a5,-694 # d50 <all_thread>
   e:	00001717          	auipc	a4,0x1
  12:	d2f73923          	sd	a5,-718(a4) # d40 <current_thread>
  current_thread->state = RUNNING;
  16:	4785                	li	a5,1
  18:	00003717          	auipc	a4,0x3
  1c:	d2f72c23          	sw	a5,-712(a4) # 2d50 <__global_pointer$+0x182f>
}
  20:	6422                	ld	s0,8(sp)
  22:	0141                	addi	sp,sp,16
  24:	8082                	ret

0000000000000026 <thread_schedule>:

void 
thread_schedule(void)
{
  26:	1141                	addi	sp,sp,-16
  28:	e406                	sd	ra,8(sp)
  2a:	e022                	sd	s0,0(sp)
  2c:	0800                	addi	s0,sp,16
  struct thread *t, *next_thread;

  /* Find another runnable thread. */
  next_thread = 0;
  t = current_thread + 1;
  2e:	00001317          	auipc	t1,0x1
  32:	d1233303          	ld	t1,-750(t1) # d40 <current_thread>
  36:	6589                	lui	a1,0x2
  38:	07858593          	addi	a1,a1,120 # 2078 <__global_pointer$+0xb57>
  3c:	959a                	add	a1,a1,t1
  3e:	4791                	li	a5,4
  for(int i = 0; i < MAX_THREAD; i++){
    if(t >= all_thread + MAX_THREAD)
  40:	00009817          	auipc	a6,0x9
  44:	ef080813          	addi	a6,a6,-272 # 8f30 <base>
      t = all_thread;
    if(t->state == RUNNABLE) {
  48:	6689                	lui	a3,0x2
  4a:	4609                	li	a2,2
      next_thread = t;
      break;
    }
    t = t + 1;
  4c:	07868893          	addi	a7,a3,120 # 2078 <__global_pointer$+0xb57>
  50:	a809                	j	62 <thread_schedule+0x3c>
    if(t->state == RUNNABLE) {
  52:	00d58733          	add	a4,a1,a3
  56:	4318                	lw	a4,0(a4)
  58:	02c70963          	beq	a4,a2,8a <thread_schedule+0x64>
    t = t + 1;
  5c:	95c6                	add	a1,a1,a7
  for(int i = 0; i < MAX_THREAD; i++){
  5e:	37fd                	addiw	a5,a5,-1
  60:	cb81                	beqz	a5,70 <thread_schedule+0x4a>
    if(t >= all_thread + MAX_THREAD)
  62:	ff05e8e3          	bltu	a1,a6,52 <thread_schedule+0x2c>
      t = all_thread;
  66:	00001597          	auipc	a1,0x1
  6a:	cea58593          	addi	a1,a1,-790 # d50 <all_thread>
  6e:	b7d5                	j	52 <thread_schedule+0x2c>
  }

  if (next_thread == 0) {
    printf("thread_schedule: no runnable threads\n");
  70:	00001517          	auipc	a0,0x1
  74:	b9850513          	addi	a0,a0,-1128 # c08 <malloc+0xea>
  78:	00001097          	auipc	ra,0x1
  7c:	9e8080e7          	jalr	-1560(ra) # a60 <printf>
    exit(-1);
  80:	557d                	li	a0,-1
  82:	00000097          	auipc	ra,0x0
  86:	666080e7          	jalr	1638(ra) # 6e8 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  8a:	02b30263          	beq	t1,a1,ae <thread_schedule+0x88>
    next_thread->state = RUNNING;
  8e:	6509                	lui	a0,0x2
  90:	00a587b3          	add	a5,a1,a0
  94:	4705                	li	a4,1
  96:	c398                	sw	a4,0(a5)
    t = current_thread;
    current_thread = next_thread;
  98:	00001797          	auipc	a5,0x1
  9c:	cab7b423          	sd	a1,-856(a5) # d40 <current_thread>
    /* YOUR CODE HERE
     * Invoke thread_switch to switch from t to next_thread:
     * thread_switch(??, ??);
     */
    thread_switch((uint64)&t->context, (uint64)&next_thread->context);
  a0:	0521                	addi	a0,a0,8
  a2:	95aa                	add	a1,a1,a0
  a4:	951a                	add	a0,a0,t1
  a6:	00000097          	auipc	ra,0x0
  aa:	362080e7          	jalr	866(ra) # 408 <thread_switch>
  } else
    next_thread = 0;
}
  ae:	60a2                	ld	ra,8(sp)
  b0:	6402                	ld	s0,0(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <thread_create>:

void 
thread_create(void (*func)())
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  struct thread *t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  bc:	00001797          	auipc	a5,0x1
  c0:	c9478793          	addi	a5,a5,-876 # d50 <all_thread>
    if (t->state == FREE) break;
  c4:	6689                	lui	a3,0x2
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  c6:	07868593          	addi	a1,a3,120 # 2078 <__global_pointer$+0xb57>
  ca:	00009617          	auipc	a2,0x9
  ce:	e6660613          	addi	a2,a2,-410 # 8f30 <base>
    if (t->state == FREE) break;
  d2:	00d78733          	add	a4,a5,a3
  d6:	4318                	lw	a4,0(a4)
  d8:	c701                	beqz	a4,e0 <thread_create+0x2a>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  da:	97ae                	add	a5,a5,a1
  dc:	fec79be3          	bne	a5,a2,d2 <thread_create+0x1c>
  }
  t->state = RUNNABLE;
  e0:	6689                	lui	a3,0x2
  e2:	00d78733          	add	a4,a5,a3
  e6:	4609                	li	a2,2
  e8:	c310                	sw	a2,0(a4)
  // YOUR CODE HERE
  t->context.ra = (uint64)func;
  ea:	e708                	sd	a0,8(a4)
  t->context.sp = (uint64)&t->stack[STACK_SIZE - 1];
  ec:	16fd                	addi	a3,a3,-1
  ee:	97b6                	add	a5,a5,a3
  f0:	eb1c                	sd	a5,16(a4)
  t->context.fp = (uint64)&t->stack[STACK_SIZE - 1];
  f2:	ef1c                	sd	a5,24(a4)
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret

00000000000000fa <thread_yield>:

void 
thread_yield(void)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e406                	sd	ra,8(sp)
  fe:	e022                	sd	s0,0(sp)
 100:	0800                	addi	s0,sp,16
  current_thread->state = RUNNABLE;
 102:	00001797          	auipc	a5,0x1
 106:	c3e7b783          	ld	a5,-962(a5) # d40 <current_thread>
 10a:	6709                	lui	a4,0x2
 10c:	97ba                	add	a5,a5,a4
 10e:	4709                	li	a4,2
 110:	c398                	sw	a4,0(a5)
  thread_schedule();
 112:	00000097          	auipc	ra,0x0
 116:	f14080e7          	jalr	-236(ra) # 26 <thread_schedule>
}
 11a:	60a2                	ld	ra,8(sp)
 11c:	6402                	ld	s0,0(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret

0000000000000122 <thread_a>:
volatile int a_started, b_started, c_started;
volatile int a_n, b_n, c_n;

void 
thread_a(void)
{
 122:	7179                	addi	sp,sp,-48
 124:	f406                	sd	ra,40(sp)
 126:	f022                	sd	s0,32(sp)
 128:	ec26                	sd	s1,24(sp)
 12a:	e84a                	sd	s2,16(sp)
 12c:	e44e                	sd	s3,8(sp)
 12e:	e052                	sd	s4,0(sp)
 130:	1800                	addi	s0,sp,48
  int i;
  printf("thread_a started\n");
 132:	00001517          	auipc	a0,0x1
 136:	afe50513          	addi	a0,a0,-1282 # c30 <malloc+0x112>
 13a:	00001097          	auipc	ra,0x1
 13e:	926080e7          	jalr	-1754(ra) # a60 <printf>
  a_started = 1;
 142:	4785                	li	a5,1
 144:	00001717          	auipc	a4,0x1
 148:	bef72c23          	sw	a5,-1032(a4) # d3c <a_started>
  while(b_started == 0 || c_started == 0)
 14c:	00001497          	auipc	s1,0x1
 150:	bec48493          	addi	s1,s1,-1044 # d38 <b_started>
 154:	00001917          	auipc	s2,0x1
 158:	be090913          	addi	s2,s2,-1056 # d34 <c_started>
 15c:	a029                	j	166 <thread_a+0x44>
    thread_yield();
 15e:	00000097          	auipc	ra,0x0
 162:	f9c080e7          	jalr	-100(ra) # fa <thread_yield>
  while(b_started == 0 || c_started == 0)
 166:	409c                	lw	a5,0(s1)
 168:	2781                	sext.w	a5,a5
 16a:	dbf5                	beqz	a5,15e <thread_a+0x3c>
 16c:	00092783          	lw	a5,0(s2)
 170:	2781                	sext.w	a5,a5
 172:	d7f5                	beqz	a5,15e <thread_a+0x3c>
  
  for (i = 0; i < 100; i++) {
 174:	4481                	li	s1,0
    printf("thread_a %d\n", i);
 176:	00001a17          	auipc	s4,0x1
 17a:	ad2a0a13          	addi	s4,s4,-1326 # c48 <malloc+0x12a>
    a_n += 1;
 17e:	00001917          	auipc	s2,0x1
 182:	bb290913          	addi	s2,s2,-1102 # d30 <a_n>
  for (i = 0; i < 100; i++) {
 186:	06400993          	li	s3,100
    printf("thread_a %d\n", i);
 18a:	85a6                	mv	a1,s1
 18c:	8552                	mv	a0,s4
 18e:	00001097          	auipc	ra,0x1
 192:	8d2080e7          	jalr	-1838(ra) # a60 <printf>
    a_n += 1;
 196:	00092783          	lw	a5,0(s2)
 19a:	2785                	addiw	a5,a5,1
 19c:	00f92023          	sw	a5,0(s2)
    thread_yield();
 1a0:	00000097          	auipc	ra,0x0
 1a4:	f5a080e7          	jalr	-166(ra) # fa <thread_yield>
  for (i = 0; i < 100; i++) {
 1a8:	2485                	addiw	s1,s1,1
 1aa:	ff3490e3          	bne	s1,s3,18a <thread_a+0x68>
  }
  printf("thread_a: exit after %d\n", a_n);
 1ae:	00001597          	auipc	a1,0x1
 1b2:	b825a583          	lw	a1,-1150(a1) # d30 <a_n>
 1b6:	00001517          	auipc	a0,0x1
 1ba:	aa250513          	addi	a0,a0,-1374 # c58 <malloc+0x13a>
 1be:	00001097          	auipc	ra,0x1
 1c2:	8a2080e7          	jalr	-1886(ra) # a60 <printf>

  current_thread->state = FREE;
 1c6:	00001797          	auipc	a5,0x1
 1ca:	b7a7b783          	ld	a5,-1158(a5) # d40 <current_thread>
 1ce:	6709                	lui	a4,0x2
 1d0:	97ba                	add	a5,a5,a4
 1d2:	0007a023          	sw	zero,0(a5)
  thread_schedule();
 1d6:	00000097          	auipc	ra,0x0
 1da:	e50080e7          	jalr	-432(ra) # 26 <thread_schedule>
}
 1de:	70a2                	ld	ra,40(sp)
 1e0:	7402                	ld	s0,32(sp)
 1e2:	64e2                	ld	s1,24(sp)
 1e4:	6942                	ld	s2,16(sp)
 1e6:	69a2                	ld	s3,8(sp)
 1e8:	6a02                	ld	s4,0(sp)
 1ea:	6145                	addi	sp,sp,48
 1ec:	8082                	ret

00000000000001ee <thread_b>:

void 
thread_b(void)
{
 1ee:	7179                	addi	sp,sp,-48
 1f0:	f406                	sd	ra,40(sp)
 1f2:	f022                	sd	s0,32(sp)
 1f4:	ec26                	sd	s1,24(sp)
 1f6:	e84a                	sd	s2,16(sp)
 1f8:	e44e                	sd	s3,8(sp)
 1fa:	e052                	sd	s4,0(sp)
 1fc:	1800                	addi	s0,sp,48
  int i;
  printf("thread_b started\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	a7a50513          	addi	a0,a0,-1414 # c78 <malloc+0x15a>
 206:	00001097          	auipc	ra,0x1
 20a:	85a080e7          	jalr	-1958(ra) # a60 <printf>
  b_started = 1;
 20e:	4785                	li	a5,1
 210:	00001717          	auipc	a4,0x1
 214:	b2f72423          	sw	a5,-1240(a4) # d38 <b_started>
  while(a_started == 0 || c_started == 0)
 218:	00001497          	auipc	s1,0x1
 21c:	b2448493          	addi	s1,s1,-1244 # d3c <a_started>
 220:	00001917          	auipc	s2,0x1
 224:	b1490913          	addi	s2,s2,-1260 # d34 <c_started>
 228:	a029                	j	232 <thread_b+0x44>
    thread_yield();
 22a:	00000097          	auipc	ra,0x0
 22e:	ed0080e7          	jalr	-304(ra) # fa <thread_yield>
  while(a_started == 0 || c_started == 0)
 232:	409c                	lw	a5,0(s1)
 234:	2781                	sext.w	a5,a5
 236:	dbf5                	beqz	a5,22a <thread_b+0x3c>
 238:	00092783          	lw	a5,0(s2)
 23c:	2781                	sext.w	a5,a5
 23e:	d7f5                	beqz	a5,22a <thread_b+0x3c>
  
  for (i = 0; i < 100; i++) {
 240:	4481                	li	s1,0
    printf("thread_b %d\n", i);
 242:	00001a17          	auipc	s4,0x1
 246:	a4ea0a13          	addi	s4,s4,-1458 # c90 <malloc+0x172>
    b_n += 1;
 24a:	00001917          	auipc	s2,0x1
 24e:	ae290913          	addi	s2,s2,-1310 # d2c <b_n>
  for (i = 0; i < 100; i++) {
 252:	06400993          	li	s3,100
    printf("thread_b %d\n", i);
 256:	85a6                	mv	a1,s1
 258:	8552                	mv	a0,s4
 25a:	00001097          	auipc	ra,0x1
 25e:	806080e7          	jalr	-2042(ra) # a60 <printf>
    b_n += 1;
 262:	00092783          	lw	a5,0(s2)
 266:	2785                	addiw	a5,a5,1
 268:	00f92023          	sw	a5,0(s2)
    thread_yield();
 26c:	00000097          	auipc	ra,0x0
 270:	e8e080e7          	jalr	-370(ra) # fa <thread_yield>
  for (i = 0; i < 100; i++) {
 274:	2485                	addiw	s1,s1,1
 276:	ff3490e3          	bne	s1,s3,256 <thread_b+0x68>
  }
  printf("thread_b: exit after %d\n", b_n);
 27a:	00001597          	auipc	a1,0x1
 27e:	ab25a583          	lw	a1,-1358(a1) # d2c <b_n>
 282:	00001517          	auipc	a0,0x1
 286:	a1e50513          	addi	a0,a0,-1506 # ca0 <malloc+0x182>
 28a:	00000097          	auipc	ra,0x0
 28e:	7d6080e7          	jalr	2006(ra) # a60 <printf>

  current_thread->state = FREE;
 292:	00001797          	auipc	a5,0x1
 296:	aae7b783          	ld	a5,-1362(a5) # d40 <current_thread>
 29a:	6709                	lui	a4,0x2
 29c:	97ba                	add	a5,a5,a4
 29e:	0007a023          	sw	zero,0(a5)
  thread_schedule();
 2a2:	00000097          	auipc	ra,0x0
 2a6:	d84080e7          	jalr	-636(ra) # 26 <thread_schedule>
}
 2aa:	70a2                	ld	ra,40(sp)
 2ac:	7402                	ld	s0,32(sp)
 2ae:	64e2                	ld	s1,24(sp)
 2b0:	6942                	ld	s2,16(sp)
 2b2:	69a2                	ld	s3,8(sp)
 2b4:	6a02                	ld	s4,0(sp)
 2b6:	6145                	addi	sp,sp,48
 2b8:	8082                	ret

00000000000002ba <thread_c>:

void 
thread_c(void)
{
 2ba:	7179                	addi	sp,sp,-48
 2bc:	f406                	sd	ra,40(sp)
 2be:	f022                	sd	s0,32(sp)
 2c0:	ec26                	sd	s1,24(sp)
 2c2:	e84a                	sd	s2,16(sp)
 2c4:	e44e                	sd	s3,8(sp)
 2c6:	e052                	sd	s4,0(sp)
 2c8:	1800                	addi	s0,sp,48
  int i;
  printf("thread_c started\n");
 2ca:	00001517          	auipc	a0,0x1
 2ce:	9f650513          	addi	a0,a0,-1546 # cc0 <malloc+0x1a2>
 2d2:	00000097          	auipc	ra,0x0
 2d6:	78e080e7          	jalr	1934(ra) # a60 <printf>
  c_started = 1;
 2da:	4785                	li	a5,1
 2dc:	00001717          	auipc	a4,0x1
 2e0:	a4f72c23          	sw	a5,-1448(a4) # d34 <c_started>
  while(a_started == 0 || b_started == 0)
 2e4:	00001497          	auipc	s1,0x1
 2e8:	a5848493          	addi	s1,s1,-1448 # d3c <a_started>
 2ec:	00001917          	auipc	s2,0x1
 2f0:	a4c90913          	addi	s2,s2,-1460 # d38 <b_started>
 2f4:	a029                	j	2fe <thread_c+0x44>
    thread_yield();
 2f6:	00000097          	auipc	ra,0x0
 2fa:	e04080e7          	jalr	-508(ra) # fa <thread_yield>
  while(a_started == 0 || b_started == 0)
 2fe:	409c                	lw	a5,0(s1)
 300:	2781                	sext.w	a5,a5
 302:	dbf5                	beqz	a5,2f6 <thread_c+0x3c>
 304:	00092783          	lw	a5,0(s2)
 308:	2781                	sext.w	a5,a5
 30a:	d7f5                	beqz	a5,2f6 <thread_c+0x3c>
  
  for (i = 0; i < 100; i++) {
 30c:	4481                	li	s1,0
    printf("thread_c %d\n", i);
 30e:	00001a17          	auipc	s4,0x1
 312:	9caa0a13          	addi	s4,s4,-1590 # cd8 <malloc+0x1ba>
    c_n += 1;
 316:	00001917          	auipc	s2,0x1
 31a:	a1290913          	addi	s2,s2,-1518 # d28 <c_n>
  for (i = 0; i < 100; i++) {
 31e:	06400993          	li	s3,100
    printf("thread_c %d\n", i);
 322:	85a6                	mv	a1,s1
 324:	8552                	mv	a0,s4
 326:	00000097          	auipc	ra,0x0
 32a:	73a080e7          	jalr	1850(ra) # a60 <printf>
    c_n += 1;
 32e:	00092783          	lw	a5,0(s2)
 332:	2785                	addiw	a5,a5,1
 334:	00f92023          	sw	a5,0(s2)
    thread_yield();
 338:	00000097          	auipc	ra,0x0
 33c:	dc2080e7          	jalr	-574(ra) # fa <thread_yield>
  for (i = 0; i < 100; i++) {
 340:	2485                	addiw	s1,s1,1
 342:	ff3490e3          	bne	s1,s3,322 <thread_c+0x68>
  }
  printf("thread_c: exit after %d\n", c_n);
 346:	00001597          	auipc	a1,0x1
 34a:	9e25a583          	lw	a1,-1566(a1) # d28 <c_n>
 34e:	00001517          	auipc	a0,0x1
 352:	99a50513          	addi	a0,a0,-1638 # ce8 <malloc+0x1ca>
 356:	00000097          	auipc	ra,0x0
 35a:	70a080e7          	jalr	1802(ra) # a60 <printf>

  current_thread->state = FREE;
 35e:	00001797          	auipc	a5,0x1
 362:	9e27b783          	ld	a5,-1566(a5) # d40 <current_thread>
 366:	6709                	lui	a4,0x2
 368:	97ba                	add	a5,a5,a4
 36a:	0007a023          	sw	zero,0(a5)
  thread_schedule();
 36e:	00000097          	auipc	ra,0x0
 372:	cb8080e7          	jalr	-840(ra) # 26 <thread_schedule>
}
 376:	70a2                	ld	ra,40(sp)
 378:	7402                	ld	s0,32(sp)
 37a:	64e2                	ld	s1,24(sp)
 37c:	6942                	ld	s2,16(sp)
 37e:	69a2                	ld	s3,8(sp)
 380:	6a02                	ld	s4,0(sp)
 382:	6145                	addi	sp,sp,48
 384:	8082                	ret

0000000000000386 <main>:

int 
main(int argc, char *argv[]) 
{
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  a_started = b_started = c_started = 0;
 38e:	00001797          	auipc	a5,0x1
 392:	9a07a323          	sw	zero,-1626(a5) # d34 <c_started>
 396:	00001797          	auipc	a5,0x1
 39a:	9a07a123          	sw	zero,-1630(a5) # d38 <b_started>
 39e:	00001797          	auipc	a5,0x1
 3a2:	9807af23          	sw	zero,-1634(a5) # d3c <a_started>
  a_n = b_n = c_n = 0;
 3a6:	00001797          	auipc	a5,0x1
 3aa:	9807a123          	sw	zero,-1662(a5) # d28 <c_n>
 3ae:	00001797          	auipc	a5,0x1
 3b2:	9607af23          	sw	zero,-1666(a5) # d2c <b_n>
 3b6:	00001797          	auipc	a5,0x1
 3ba:	9607ad23          	sw	zero,-1670(a5) # d30 <a_n>
  thread_init();
 3be:	00000097          	auipc	ra,0x0
 3c2:	c42080e7          	jalr	-958(ra) # 0 <thread_init>
  thread_create(thread_a);
 3c6:	00000517          	auipc	a0,0x0
 3ca:	d5c50513          	addi	a0,a0,-676 # 122 <thread_a>
 3ce:	00000097          	auipc	ra,0x0
 3d2:	ce8080e7          	jalr	-792(ra) # b6 <thread_create>
  thread_create(thread_b);
 3d6:	00000517          	auipc	a0,0x0
 3da:	e1850513          	addi	a0,a0,-488 # 1ee <thread_b>
 3de:	00000097          	auipc	ra,0x0
 3e2:	cd8080e7          	jalr	-808(ra) # b6 <thread_create>
  thread_create(thread_c);
 3e6:	00000517          	auipc	a0,0x0
 3ea:	ed450513          	addi	a0,a0,-300 # 2ba <thread_c>
 3ee:	00000097          	auipc	ra,0x0
 3f2:	cc8080e7          	jalr	-824(ra) # b6 <thread_create>
  thread_schedule();
 3f6:	00000097          	auipc	ra,0x0
 3fa:	c30080e7          	jalr	-976(ra) # 26 <thread_schedule>
  exit(0);
 3fe:	4501                	li	a0,0
 400:	00000097          	auipc	ra,0x0
 404:	2e8080e7          	jalr	744(ra) # 6e8 <exit>

0000000000000408 <thread_switch>:
         */

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
	sd ra, 0(a0)
 408:	00153023          	sd	ra,0(a0)

	sd sp, 8(a0)
 40c:	00253423          	sd	sp,8(a0)
	sd fp, 16(a0)
 410:	e900                	sd	s0,16(a0)
	sd s1, 24(a0)
 412:	ed04                	sd	s1,24(a0)
	sd s2, 32(a0)
 414:	03253023          	sd	s2,32(a0)
	sd s3, 40(a0)
 418:	03353423          	sd	s3,40(a0)
	sd s4, 48(a0)
 41c:	03453823          	sd	s4,48(a0)
	sd s5, 56(a0)
 420:	03553c23          	sd	s5,56(a0)
	sd s6, 64(a0)
 424:	05653023          	sd	s6,64(a0)
	sd s7, 72(a0)
 428:	05753423          	sd	s7,72(a0)
	sd s8, 80(a0)
 42c:	05853823          	sd	s8,80(a0)
	sd s9, 88(a0)
 430:	05953c23          	sd	s9,88(a0)
	sd s10, 96(a0)
 434:	07a53023          	sd	s10,96(a0)
	sd s11, 104(a0)
 438:	07b53423          	sd	s11,104(a0)

    ld sp, 8(a1)
 43c:	0085b103          	ld	sp,8(a1)
	ld fp, 16(a1)
 440:	6980                	ld	s0,16(a1)
	ld s1, 24(a1)
 442:	6d84                	ld	s1,24(a1)
	ld s2, 32(a1)
 444:	0205b903          	ld	s2,32(a1)
	ld s3, 40(a1)
 448:	0285b983          	ld	s3,40(a1)
	ld s4, 48(a1)
 44c:	0305ba03          	ld	s4,48(a1)
	ld s5, 56(a1)
 450:	0385ba83          	ld	s5,56(a1)
	ld s6, 64(a1)
 454:	0405bb03          	ld	s6,64(a1)
	ld s7, 72(a1)
 458:	0485bb83          	ld	s7,72(a1)
	ld s8, 80(a1)
 45c:	0505bc03          	ld	s8,80(a1)
	ld s9, 88(a1)
 460:	0585bc83          	ld	s9,88(a1)
	ld s10, 96(a1)
 464:	0605bd03          	ld	s10,96(a1)
	ld s11, 104(a1)
 468:	0685bd83          	ld	s11,104(a1)

	ld ra, 0(a1) /* set return address to next thread */
 46c:	0005b083          	ld	ra,0(a1)
	ret    /* return to ra */
 470:	8082                	ret

0000000000000472 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 472:	1141                	addi	sp,sp,-16
 474:	e422                	sd	s0,8(sp)
 476:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 478:	87aa                	mv	a5,a0
 47a:	0585                	addi	a1,a1,1
 47c:	0785                	addi	a5,a5,1
 47e:	fff5c703          	lbu	a4,-1(a1)
 482:	fee78fa3          	sb	a4,-1(a5)
 486:	fb75                	bnez	a4,47a <strcpy+0x8>
    ;
  return os;
}
 488:	6422                	ld	s0,8(sp)
 48a:	0141                	addi	sp,sp,16
 48c:	8082                	ret

000000000000048e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 48e:	1141                	addi	sp,sp,-16
 490:	e422                	sd	s0,8(sp)
 492:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 494:	00054783          	lbu	a5,0(a0)
 498:	cb91                	beqz	a5,4ac <strcmp+0x1e>
 49a:	0005c703          	lbu	a4,0(a1)
 49e:	00f71763          	bne	a4,a5,4ac <strcmp+0x1e>
    p++, q++;
 4a2:	0505                	addi	a0,a0,1
 4a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4a6:	00054783          	lbu	a5,0(a0)
 4aa:	fbe5                	bnez	a5,49a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4ac:	0005c503          	lbu	a0,0(a1)
}
 4b0:	40a7853b          	subw	a0,a5,a0
 4b4:	6422                	ld	s0,8(sp)
 4b6:	0141                	addi	sp,sp,16
 4b8:	8082                	ret

00000000000004ba <strlen>:

uint
strlen(const char *s)
{
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e422                	sd	s0,8(sp)
 4be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4c0:	00054783          	lbu	a5,0(a0)
 4c4:	cf91                	beqz	a5,4e0 <strlen+0x26>
 4c6:	0505                	addi	a0,a0,1
 4c8:	87aa                	mv	a5,a0
 4ca:	4685                	li	a3,1
 4cc:	9e89                	subw	a3,a3,a0
 4ce:	00f6853b          	addw	a0,a3,a5
 4d2:	0785                	addi	a5,a5,1
 4d4:	fff7c703          	lbu	a4,-1(a5)
 4d8:	fb7d                	bnez	a4,4ce <strlen+0x14>
    ;
  return n;
}
 4da:	6422                	ld	s0,8(sp)
 4dc:	0141                	addi	sp,sp,16
 4de:	8082                	ret
  for(n = 0; s[n]; n++)
 4e0:	4501                	li	a0,0
 4e2:	bfe5                	j	4da <strlen+0x20>

00000000000004e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4e4:	1141                	addi	sp,sp,-16
 4e6:	e422                	sd	s0,8(sp)
 4e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4ea:	ce09                	beqz	a2,504 <memset+0x20>
 4ec:	87aa                	mv	a5,a0
 4ee:	fff6071b          	addiw	a4,a2,-1
 4f2:	1702                	slli	a4,a4,0x20
 4f4:	9301                	srli	a4,a4,0x20
 4f6:	0705                	addi	a4,a4,1
 4f8:	972a                	add	a4,a4,a0
    cdst[i] = c;
 4fa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 4fe:	0785                	addi	a5,a5,1
 500:	fee79de3          	bne	a5,a4,4fa <memset+0x16>
  }
  return dst;
}
 504:	6422                	ld	s0,8(sp)
 506:	0141                	addi	sp,sp,16
 508:	8082                	ret

000000000000050a <strchr>:

char*
strchr(const char *s, char c)
{
 50a:	1141                	addi	sp,sp,-16
 50c:	e422                	sd	s0,8(sp)
 50e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 510:	00054783          	lbu	a5,0(a0)
 514:	cb99                	beqz	a5,52a <strchr+0x20>
    if(*s == c)
 516:	00f58763          	beq	a1,a5,524 <strchr+0x1a>
  for(; *s; s++)
 51a:	0505                	addi	a0,a0,1
 51c:	00054783          	lbu	a5,0(a0)
 520:	fbfd                	bnez	a5,516 <strchr+0xc>
      return (char*)s;
  return 0;
 522:	4501                	li	a0,0
}
 524:	6422                	ld	s0,8(sp)
 526:	0141                	addi	sp,sp,16
 528:	8082                	ret
  return 0;
 52a:	4501                	li	a0,0
 52c:	bfe5                	j	524 <strchr+0x1a>

000000000000052e <gets>:

char*
gets(char *buf, int max)
{
 52e:	711d                	addi	sp,sp,-96
 530:	ec86                	sd	ra,88(sp)
 532:	e8a2                	sd	s0,80(sp)
 534:	e4a6                	sd	s1,72(sp)
 536:	e0ca                	sd	s2,64(sp)
 538:	fc4e                	sd	s3,56(sp)
 53a:	f852                	sd	s4,48(sp)
 53c:	f456                	sd	s5,40(sp)
 53e:	f05a                	sd	s6,32(sp)
 540:	ec5e                	sd	s7,24(sp)
 542:	1080                	addi	s0,sp,96
 544:	8baa                	mv	s7,a0
 546:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 548:	892a                	mv	s2,a0
 54a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 54c:	4aa9                	li	s5,10
 54e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 550:	89a6                	mv	s3,s1
 552:	2485                	addiw	s1,s1,1
 554:	0344d863          	bge	s1,s4,584 <gets+0x56>
    cc = read(0, &c, 1);
 558:	4605                	li	a2,1
 55a:	faf40593          	addi	a1,s0,-81
 55e:	4501                	li	a0,0
 560:	00000097          	auipc	ra,0x0
 564:	1a0080e7          	jalr	416(ra) # 700 <read>
    if(cc < 1)
 568:	00a05e63          	blez	a0,584 <gets+0x56>
    buf[i++] = c;
 56c:	faf44783          	lbu	a5,-81(s0)
 570:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 574:	01578763          	beq	a5,s5,582 <gets+0x54>
 578:	0905                	addi	s2,s2,1
 57a:	fd679be3          	bne	a5,s6,550 <gets+0x22>
  for(i=0; i+1 < max; ){
 57e:	89a6                	mv	s3,s1
 580:	a011                	j	584 <gets+0x56>
 582:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 584:	99de                	add	s3,s3,s7
 586:	00098023          	sb	zero,0(s3)
  return buf;
}
 58a:	855e                	mv	a0,s7
 58c:	60e6                	ld	ra,88(sp)
 58e:	6446                	ld	s0,80(sp)
 590:	64a6                	ld	s1,72(sp)
 592:	6906                	ld	s2,64(sp)
 594:	79e2                	ld	s3,56(sp)
 596:	7a42                	ld	s4,48(sp)
 598:	7aa2                	ld	s5,40(sp)
 59a:	7b02                	ld	s6,32(sp)
 59c:	6be2                	ld	s7,24(sp)
 59e:	6125                	addi	sp,sp,96
 5a0:	8082                	ret

00000000000005a2 <stat>:

int
stat(const char *n, struct stat *st)
{
 5a2:	1101                	addi	sp,sp,-32
 5a4:	ec06                	sd	ra,24(sp)
 5a6:	e822                	sd	s0,16(sp)
 5a8:	e426                	sd	s1,8(sp)
 5aa:	e04a                	sd	s2,0(sp)
 5ac:	1000                	addi	s0,sp,32
 5ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5b0:	4581                	li	a1,0
 5b2:	00000097          	auipc	ra,0x0
 5b6:	176080e7          	jalr	374(ra) # 728 <open>
  if(fd < 0)
 5ba:	02054563          	bltz	a0,5e4 <stat+0x42>
 5be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5c0:	85ca                	mv	a1,s2
 5c2:	00000097          	auipc	ra,0x0
 5c6:	17e080e7          	jalr	382(ra) # 740 <fstat>
 5ca:	892a                	mv	s2,a0
  close(fd);
 5cc:	8526                	mv	a0,s1
 5ce:	00000097          	auipc	ra,0x0
 5d2:	142080e7          	jalr	322(ra) # 710 <close>
  return r;
}
 5d6:	854a                	mv	a0,s2
 5d8:	60e2                	ld	ra,24(sp)
 5da:	6442                	ld	s0,16(sp)
 5dc:	64a2                	ld	s1,8(sp)
 5de:	6902                	ld	s2,0(sp)
 5e0:	6105                	addi	sp,sp,32
 5e2:	8082                	ret
    return -1;
 5e4:	597d                	li	s2,-1
 5e6:	bfc5                	j	5d6 <stat+0x34>

00000000000005e8 <atoi>:

int
atoi(const char *s)
{
 5e8:	1141                	addi	sp,sp,-16
 5ea:	e422                	sd	s0,8(sp)
 5ec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5ee:	00054603          	lbu	a2,0(a0)
 5f2:	fd06079b          	addiw	a5,a2,-48
 5f6:	0ff7f793          	andi	a5,a5,255
 5fa:	4725                	li	a4,9
 5fc:	02f76963          	bltu	a4,a5,62e <atoi+0x46>
 600:	86aa                	mv	a3,a0
  n = 0;
 602:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 604:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 606:	0685                	addi	a3,a3,1
 608:	0025179b          	slliw	a5,a0,0x2
 60c:	9fa9                	addw	a5,a5,a0
 60e:	0017979b          	slliw	a5,a5,0x1
 612:	9fb1                	addw	a5,a5,a2
 614:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 618:	0006c603          	lbu	a2,0(a3) # 2000 <__global_pointer$+0xadf>
 61c:	fd06071b          	addiw	a4,a2,-48
 620:	0ff77713          	andi	a4,a4,255
 624:	fee5f1e3          	bgeu	a1,a4,606 <atoi+0x1e>
  return n;
}
 628:	6422                	ld	s0,8(sp)
 62a:	0141                	addi	sp,sp,16
 62c:	8082                	ret
  n = 0;
 62e:	4501                	li	a0,0
 630:	bfe5                	j	628 <atoi+0x40>

0000000000000632 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 632:	1141                	addi	sp,sp,-16
 634:	e422                	sd	s0,8(sp)
 636:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 638:	02b57663          	bgeu	a0,a1,664 <memmove+0x32>
    while(n-- > 0)
 63c:	02c05163          	blez	a2,65e <memmove+0x2c>
 640:	fff6079b          	addiw	a5,a2,-1
 644:	1782                	slli	a5,a5,0x20
 646:	9381                	srli	a5,a5,0x20
 648:	0785                	addi	a5,a5,1
 64a:	97aa                	add	a5,a5,a0
  dst = vdst;
 64c:	872a                	mv	a4,a0
      *dst++ = *src++;
 64e:	0585                	addi	a1,a1,1
 650:	0705                	addi	a4,a4,1
 652:	fff5c683          	lbu	a3,-1(a1)
 656:	fed70fa3          	sb	a3,-1(a4) # 1fff <__global_pointer$+0xade>
    while(n-- > 0)
 65a:	fee79ae3          	bne	a5,a4,64e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 65e:	6422                	ld	s0,8(sp)
 660:	0141                	addi	sp,sp,16
 662:	8082                	ret
    dst += n;
 664:	00c50733          	add	a4,a0,a2
    src += n;
 668:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 66a:	fec05ae3          	blez	a2,65e <memmove+0x2c>
 66e:	fff6079b          	addiw	a5,a2,-1
 672:	1782                	slli	a5,a5,0x20
 674:	9381                	srli	a5,a5,0x20
 676:	fff7c793          	not	a5,a5
 67a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 67c:	15fd                	addi	a1,a1,-1
 67e:	177d                	addi	a4,a4,-1
 680:	0005c683          	lbu	a3,0(a1)
 684:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 688:	fee79ae3          	bne	a5,a4,67c <memmove+0x4a>
 68c:	bfc9                	j	65e <memmove+0x2c>

000000000000068e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 68e:	1141                	addi	sp,sp,-16
 690:	e422                	sd	s0,8(sp)
 692:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 694:	ca05                	beqz	a2,6c4 <memcmp+0x36>
 696:	fff6069b          	addiw	a3,a2,-1
 69a:	1682                	slli	a3,a3,0x20
 69c:	9281                	srli	a3,a3,0x20
 69e:	0685                	addi	a3,a3,1
 6a0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6a2:	00054783          	lbu	a5,0(a0)
 6a6:	0005c703          	lbu	a4,0(a1)
 6aa:	00e79863          	bne	a5,a4,6ba <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6ae:	0505                	addi	a0,a0,1
    p2++;
 6b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6b2:	fed518e3          	bne	a0,a3,6a2 <memcmp+0x14>
  }
  return 0;
 6b6:	4501                	li	a0,0
 6b8:	a019                	j	6be <memcmp+0x30>
      return *p1 - *p2;
 6ba:	40e7853b          	subw	a0,a5,a4
}
 6be:	6422                	ld	s0,8(sp)
 6c0:	0141                	addi	sp,sp,16
 6c2:	8082                	ret
  return 0;
 6c4:	4501                	li	a0,0
 6c6:	bfe5                	j	6be <memcmp+0x30>

00000000000006c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6c8:	1141                	addi	sp,sp,-16
 6ca:	e406                	sd	ra,8(sp)
 6cc:	e022                	sd	s0,0(sp)
 6ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6d0:	00000097          	auipc	ra,0x0
 6d4:	f62080e7          	jalr	-158(ra) # 632 <memmove>
}
 6d8:	60a2                	ld	ra,8(sp)
 6da:	6402                	ld	s0,0(sp)
 6dc:	0141                	addi	sp,sp,16
 6de:	8082                	ret

00000000000006e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6e0:	4885                	li	a7,1
 ecall
 6e2:	00000073          	ecall
 ret
 6e6:	8082                	ret

00000000000006e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 6e8:	4889                	li	a7,2
 ecall
 6ea:	00000073          	ecall
 ret
 6ee:	8082                	ret

00000000000006f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6f0:	488d                	li	a7,3
 ecall
 6f2:	00000073          	ecall
 ret
 6f6:	8082                	ret

00000000000006f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6f8:	4891                	li	a7,4
 ecall
 6fa:	00000073          	ecall
 ret
 6fe:	8082                	ret

0000000000000700 <read>:
.global read
read:
 li a7, SYS_read
 700:	4895                	li	a7,5
 ecall
 702:	00000073          	ecall
 ret
 706:	8082                	ret

0000000000000708 <write>:
.global write
write:
 li a7, SYS_write
 708:	48c1                	li	a7,16
 ecall
 70a:	00000073          	ecall
 ret
 70e:	8082                	ret

0000000000000710 <close>:
.global close
close:
 li a7, SYS_close
 710:	48d5                	li	a7,21
 ecall
 712:	00000073          	ecall
 ret
 716:	8082                	ret

0000000000000718 <kill>:
.global kill
kill:
 li a7, SYS_kill
 718:	4899                	li	a7,6
 ecall
 71a:	00000073          	ecall
 ret
 71e:	8082                	ret

0000000000000720 <exec>:
.global exec
exec:
 li a7, SYS_exec
 720:	489d                	li	a7,7
 ecall
 722:	00000073          	ecall
 ret
 726:	8082                	ret

0000000000000728 <open>:
.global open
open:
 li a7, SYS_open
 728:	48bd                	li	a7,15
 ecall
 72a:	00000073          	ecall
 ret
 72e:	8082                	ret

0000000000000730 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 730:	48c5                	li	a7,17
 ecall
 732:	00000073          	ecall
 ret
 736:	8082                	ret

0000000000000738 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 738:	48c9                	li	a7,18
 ecall
 73a:	00000073          	ecall
 ret
 73e:	8082                	ret

0000000000000740 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 740:	48a1                	li	a7,8
 ecall
 742:	00000073          	ecall
 ret
 746:	8082                	ret

0000000000000748 <link>:
.global link
link:
 li a7, SYS_link
 748:	48cd                	li	a7,19
 ecall
 74a:	00000073          	ecall
 ret
 74e:	8082                	ret

0000000000000750 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 750:	48d1                	li	a7,20
 ecall
 752:	00000073          	ecall
 ret
 756:	8082                	ret

0000000000000758 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 758:	48a5                	li	a7,9
 ecall
 75a:	00000073          	ecall
 ret
 75e:	8082                	ret

0000000000000760 <dup>:
.global dup
dup:
 li a7, SYS_dup
 760:	48a9                	li	a7,10
 ecall
 762:	00000073          	ecall
 ret
 766:	8082                	ret

0000000000000768 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 768:	48ad                	li	a7,11
 ecall
 76a:	00000073          	ecall
 ret
 76e:	8082                	ret

0000000000000770 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 770:	48b1                	li	a7,12
 ecall
 772:	00000073          	ecall
 ret
 776:	8082                	ret

0000000000000778 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 778:	48b5                	li	a7,13
 ecall
 77a:	00000073          	ecall
 ret
 77e:	8082                	ret

0000000000000780 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 780:	48b9                	li	a7,14
 ecall
 782:	00000073          	ecall
 ret
 786:	8082                	ret

0000000000000788 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 788:	1101                	addi	sp,sp,-32
 78a:	ec06                	sd	ra,24(sp)
 78c:	e822                	sd	s0,16(sp)
 78e:	1000                	addi	s0,sp,32
 790:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 794:	4605                	li	a2,1
 796:	fef40593          	addi	a1,s0,-17
 79a:	00000097          	auipc	ra,0x0
 79e:	f6e080e7          	jalr	-146(ra) # 708 <write>
}
 7a2:	60e2                	ld	ra,24(sp)
 7a4:	6442                	ld	s0,16(sp)
 7a6:	6105                	addi	sp,sp,32
 7a8:	8082                	ret

00000000000007aa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7aa:	7139                	addi	sp,sp,-64
 7ac:	fc06                	sd	ra,56(sp)
 7ae:	f822                	sd	s0,48(sp)
 7b0:	f426                	sd	s1,40(sp)
 7b2:	f04a                	sd	s2,32(sp)
 7b4:	ec4e                	sd	s3,24(sp)
 7b6:	0080                	addi	s0,sp,64
 7b8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7ba:	c299                	beqz	a3,7c0 <printint+0x16>
 7bc:	0805c863          	bltz	a1,84c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7c0:	2581                	sext.w	a1,a1
  neg = 0;
 7c2:	4881                	li	a7,0
 7c4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7c8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7ca:	2601                	sext.w	a2,a2
 7cc:	00000517          	auipc	a0,0x0
 7d0:	54450513          	addi	a0,a0,1348 # d10 <digits>
 7d4:	883a                	mv	a6,a4
 7d6:	2705                	addiw	a4,a4,1
 7d8:	02c5f7bb          	remuw	a5,a1,a2
 7dc:	1782                	slli	a5,a5,0x20
 7de:	9381                	srli	a5,a5,0x20
 7e0:	97aa                	add	a5,a5,a0
 7e2:	0007c783          	lbu	a5,0(a5)
 7e6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 7ea:	0005879b          	sext.w	a5,a1
 7ee:	02c5d5bb          	divuw	a1,a1,a2
 7f2:	0685                	addi	a3,a3,1
 7f4:	fec7f0e3          	bgeu	a5,a2,7d4 <printint+0x2a>
  if(neg)
 7f8:	00088b63          	beqz	a7,80e <printint+0x64>
    buf[i++] = '-';
 7fc:	fd040793          	addi	a5,s0,-48
 800:	973e                	add	a4,a4,a5
 802:	02d00793          	li	a5,45
 806:	fef70823          	sb	a5,-16(a4)
 80a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 80e:	02e05863          	blez	a4,83e <printint+0x94>
 812:	fc040793          	addi	a5,s0,-64
 816:	00e78933          	add	s2,a5,a4
 81a:	fff78993          	addi	s3,a5,-1
 81e:	99ba                	add	s3,s3,a4
 820:	377d                	addiw	a4,a4,-1
 822:	1702                	slli	a4,a4,0x20
 824:	9301                	srli	a4,a4,0x20
 826:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 82a:	fff94583          	lbu	a1,-1(s2)
 82e:	8526                	mv	a0,s1
 830:	00000097          	auipc	ra,0x0
 834:	f58080e7          	jalr	-168(ra) # 788 <putc>
  while(--i >= 0)
 838:	197d                	addi	s2,s2,-1
 83a:	ff3918e3          	bne	s2,s3,82a <printint+0x80>
}
 83e:	70e2                	ld	ra,56(sp)
 840:	7442                	ld	s0,48(sp)
 842:	74a2                	ld	s1,40(sp)
 844:	7902                	ld	s2,32(sp)
 846:	69e2                	ld	s3,24(sp)
 848:	6121                	addi	sp,sp,64
 84a:	8082                	ret
    x = -xx;
 84c:	40b005bb          	negw	a1,a1
    neg = 1;
 850:	4885                	li	a7,1
    x = -xx;
 852:	bf8d                	j	7c4 <printint+0x1a>

0000000000000854 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 854:	7119                	addi	sp,sp,-128
 856:	fc86                	sd	ra,120(sp)
 858:	f8a2                	sd	s0,112(sp)
 85a:	f4a6                	sd	s1,104(sp)
 85c:	f0ca                	sd	s2,96(sp)
 85e:	ecce                	sd	s3,88(sp)
 860:	e8d2                	sd	s4,80(sp)
 862:	e4d6                	sd	s5,72(sp)
 864:	e0da                	sd	s6,64(sp)
 866:	fc5e                	sd	s7,56(sp)
 868:	f862                	sd	s8,48(sp)
 86a:	f466                	sd	s9,40(sp)
 86c:	f06a                	sd	s10,32(sp)
 86e:	ec6e                	sd	s11,24(sp)
 870:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 872:	0005c903          	lbu	s2,0(a1)
 876:	18090f63          	beqz	s2,a14 <vprintf+0x1c0>
 87a:	8aaa                	mv	s5,a0
 87c:	8b32                	mv	s6,a2
 87e:	00158493          	addi	s1,a1,1
  state = 0;
 882:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 884:	02500a13          	li	s4,37
      if(c == 'd'){
 888:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 88c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 890:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 894:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 898:	00000b97          	auipc	s7,0x0
 89c:	478b8b93          	addi	s7,s7,1144 # d10 <digits>
 8a0:	a839                	j	8be <vprintf+0x6a>
        putc(fd, c);
 8a2:	85ca                	mv	a1,s2
 8a4:	8556                	mv	a0,s5
 8a6:	00000097          	auipc	ra,0x0
 8aa:	ee2080e7          	jalr	-286(ra) # 788 <putc>
 8ae:	a019                	j	8b4 <vprintf+0x60>
    } else if(state == '%'){
 8b0:	01498f63          	beq	s3,s4,8ce <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 8b4:	0485                	addi	s1,s1,1
 8b6:	fff4c903          	lbu	s2,-1(s1)
 8ba:	14090d63          	beqz	s2,a14 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 8be:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8c2:	fe0997e3          	bnez	s3,8b0 <vprintf+0x5c>
      if(c == '%'){
 8c6:	fd479ee3          	bne	a5,s4,8a2 <vprintf+0x4e>
        state = '%';
 8ca:	89be                	mv	s3,a5
 8cc:	b7e5                	j	8b4 <vprintf+0x60>
      if(c == 'd'){
 8ce:	05878063          	beq	a5,s8,90e <vprintf+0xba>
      } else if(c == 'l') {
 8d2:	05978c63          	beq	a5,s9,92a <vprintf+0xd6>
      } else if(c == 'x') {
 8d6:	07a78863          	beq	a5,s10,946 <vprintf+0xf2>
      } else if(c == 'p') {
 8da:	09b78463          	beq	a5,s11,962 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 8de:	07300713          	li	a4,115
 8e2:	0ce78663          	beq	a5,a4,9ae <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8e6:	06300713          	li	a4,99
 8ea:	0ee78e63          	beq	a5,a4,9e6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 8ee:	11478863          	beq	a5,s4,9fe <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8f2:	85d2                	mv	a1,s4
 8f4:	8556                	mv	a0,s5
 8f6:	00000097          	auipc	ra,0x0
 8fa:	e92080e7          	jalr	-366(ra) # 788 <putc>
        putc(fd, c);
 8fe:	85ca                	mv	a1,s2
 900:	8556                	mv	a0,s5
 902:	00000097          	auipc	ra,0x0
 906:	e86080e7          	jalr	-378(ra) # 788 <putc>
      }
      state = 0;
 90a:	4981                	li	s3,0
 90c:	b765                	j	8b4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 90e:	008b0913          	addi	s2,s6,8
 912:	4685                	li	a3,1
 914:	4629                	li	a2,10
 916:	000b2583          	lw	a1,0(s6)
 91a:	8556                	mv	a0,s5
 91c:	00000097          	auipc	ra,0x0
 920:	e8e080e7          	jalr	-370(ra) # 7aa <printint>
 924:	8b4a                	mv	s6,s2
      state = 0;
 926:	4981                	li	s3,0
 928:	b771                	j	8b4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 92a:	008b0913          	addi	s2,s6,8
 92e:	4681                	li	a3,0
 930:	4629                	li	a2,10
 932:	000b2583          	lw	a1,0(s6)
 936:	8556                	mv	a0,s5
 938:	00000097          	auipc	ra,0x0
 93c:	e72080e7          	jalr	-398(ra) # 7aa <printint>
 940:	8b4a                	mv	s6,s2
      state = 0;
 942:	4981                	li	s3,0
 944:	bf85                	j	8b4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 946:	008b0913          	addi	s2,s6,8
 94a:	4681                	li	a3,0
 94c:	4641                	li	a2,16
 94e:	000b2583          	lw	a1,0(s6)
 952:	8556                	mv	a0,s5
 954:	00000097          	auipc	ra,0x0
 958:	e56080e7          	jalr	-426(ra) # 7aa <printint>
 95c:	8b4a                	mv	s6,s2
      state = 0;
 95e:	4981                	li	s3,0
 960:	bf91                	j	8b4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 962:	008b0793          	addi	a5,s6,8
 966:	f8f43423          	sd	a5,-120(s0)
 96a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 96e:	03000593          	li	a1,48
 972:	8556                	mv	a0,s5
 974:	00000097          	auipc	ra,0x0
 978:	e14080e7          	jalr	-492(ra) # 788 <putc>
  putc(fd, 'x');
 97c:	85ea                	mv	a1,s10
 97e:	8556                	mv	a0,s5
 980:	00000097          	auipc	ra,0x0
 984:	e08080e7          	jalr	-504(ra) # 788 <putc>
 988:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 98a:	03c9d793          	srli	a5,s3,0x3c
 98e:	97de                	add	a5,a5,s7
 990:	0007c583          	lbu	a1,0(a5)
 994:	8556                	mv	a0,s5
 996:	00000097          	auipc	ra,0x0
 99a:	df2080e7          	jalr	-526(ra) # 788 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 99e:	0992                	slli	s3,s3,0x4
 9a0:	397d                	addiw	s2,s2,-1
 9a2:	fe0914e3          	bnez	s2,98a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 9a6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 9aa:	4981                	li	s3,0
 9ac:	b721                	j	8b4 <vprintf+0x60>
        s = va_arg(ap, char*);
 9ae:	008b0993          	addi	s3,s6,8
 9b2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 9b6:	02090163          	beqz	s2,9d8 <vprintf+0x184>
        while(*s != 0){
 9ba:	00094583          	lbu	a1,0(s2)
 9be:	c9a1                	beqz	a1,a0e <vprintf+0x1ba>
          putc(fd, *s);
 9c0:	8556                	mv	a0,s5
 9c2:	00000097          	auipc	ra,0x0
 9c6:	dc6080e7          	jalr	-570(ra) # 788 <putc>
          s++;
 9ca:	0905                	addi	s2,s2,1
        while(*s != 0){
 9cc:	00094583          	lbu	a1,0(s2)
 9d0:	f9e5                	bnez	a1,9c0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 9d2:	8b4e                	mv	s6,s3
      state = 0;
 9d4:	4981                	li	s3,0
 9d6:	bdf9                	j	8b4 <vprintf+0x60>
          s = "(null)";
 9d8:	00000917          	auipc	s2,0x0
 9dc:	33090913          	addi	s2,s2,816 # d08 <malloc+0x1ea>
        while(*s != 0){
 9e0:	02800593          	li	a1,40
 9e4:	bff1                	j	9c0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 9e6:	008b0913          	addi	s2,s6,8
 9ea:	000b4583          	lbu	a1,0(s6)
 9ee:	8556                	mv	a0,s5
 9f0:	00000097          	auipc	ra,0x0
 9f4:	d98080e7          	jalr	-616(ra) # 788 <putc>
 9f8:	8b4a                	mv	s6,s2
      state = 0;
 9fa:	4981                	li	s3,0
 9fc:	bd65                	j	8b4 <vprintf+0x60>
        putc(fd, c);
 9fe:	85d2                	mv	a1,s4
 a00:	8556                	mv	a0,s5
 a02:	00000097          	auipc	ra,0x0
 a06:	d86080e7          	jalr	-634(ra) # 788 <putc>
      state = 0;
 a0a:	4981                	li	s3,0
 a0c:	b565                	j	8b4 <vprintf+0x60>
        s = va_arg(ap, char*);
 a0e:	8b4e                	mv	s6,s3
      state = 0;
 a10:	4981                	li	s3,0
 a12:	b54d                	j	8b4 <vprintf+0x60>
    }
  }
}
 a14:	70e6                	ld	ra,120(sp)
 a16:	7446                	ld	s0,112(sp)
 a18:	74a6                	ld	s1,104(sp)
 a1a:	7906                	ld	s2,96(sp)
 a1c:	69e6                	ld	s3,88(sp)
 a1e:	6a46                	ld	s4,80(sp)
 a20:	6aa6                	ld	s5,72(sp)
 a22:	6b06                	ld	s6,64(sp)
 a24:	7be2                	ld	s7,56(sp)
 a26:	7c42                	ld	s8,48(sp)
 a28:	7ca2                	ld	s9,40(sp)
 a2a:	7d02                	ld	s10,32(sp)
 a2c:	6de2                	ld	s11,24(sp)
 a2e:	6109                	addi	sp,sp,128
 a30:	8082                	ret

0000000000000a32 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a32:	715d                	addi	sp,sp,-80
 a34:	ec06                	sd	ra,24(sp)
 a36:	e822                	sd	s0,16(sp)
 a38:	1000                	addi	s0,sp,32
 a3a:	e010                	sd	a2,0(s0)
 a3c:	e414                	sd	a3,8(s0)
 a3e:	e818                	sd	a4,16(s0)
 a40:	ec1c                	sd	a5,24(s0)
 a42:	03043023          	sd	a6,32(s0)
 a46:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a4a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a4e:	8622                	mv	a2,s0
 a50:	00000097          	auipc	ra,0x0
 a54:	e04080e7          	jalr	-508(ra) # 854 <vprintf>
}
 a58:	60e2                	ld	ra,24(sp)
 a5a:	6442                	ld	s0,16(sp)
 a5c:	6161                	addi	sp,sp,80
 a5e:	8082                	ret

0000000000000a60 <printf>:

void
printf(const char *fmt, ...)
{
 a60:	711d                	addi	sp,sp,-96
 a62:	ec06                	sd	ra,24(sp)
 a64:	e822                	sd	s0,16(sp)
 a66:	1000                	addi	s0,sp,32
 a68:	e40c                	sd	a1,8(s0)
 a6a:	e810                	sd	a2,16(s0)
 a6c:	ec14                	sd	a3,24(s0)
 a6e:	f018                	sd	a4,32(s0)
 a70:	f41c                	sd	a5,40(s0)
 a72:	03043823          	sd	a6,48(s0)
 a76:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a7a:	00840613          	addi	a2,s0,8
 a7e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a82:	85aa                	mv	a1,a0
 a84:	4505                	li	a0,1
 a86:	00000097          	auipc	ra,0x0
 a8a:	dce080e7          	jalr	-562(ra) # 854 <vprintf>
}
 a8e:	60e2                	ld	ra,24(sp)
 a90:	6442                	ld	s0,16(sp)
 a92:	6125                	addi	sp,sp,96
 a94:	8082                	ret

0000000000000a96 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a96:	1141                	addi	sp,sp,-16
 a98:	e422                	sd	s0,8(sp)
 a9a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a9c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aa0:	00000797          	auipc	a5,0x0
 aa4:	2a87b783          	ld	a5,680(a5) # d48 <freep>
 aa8:	a805                	j	ad8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 aaa:	4618                	lw	a4,8(a2)
 aac:	9db9                	addw	a1,a1,a4
 aae:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ab2:	6398                	ld	a4,0(a5)
 ab4:	6318                	ld	a4,0(a4)
 ab6:	fee53823          	sd	a4,-16(a0)
 aba:	a091                	j	afe <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 abc:	ff852703          	lw	a4,-8(a0)
 ac0:	9e39                	addw	a2,a2,a4
 ac2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 ac4:	ff053703          	ld	a4,-16(a0)
 ac8:	e398                	sd	a4,0(a5)
 aca:	a099                	j	b10 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 acc:	6398                	ld	a4,0(a5)
 ace:	00e7e463          	bltu	a5,a4,ad6 <free+0x40>
 ad2:	00e6ea63          	bltu	a3,a4,ae6 <free+0x50>
{
 ad6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ad8:	fed7fae3          	bgeu	a5,a3,acc <free+0x36>
 adc:	6398                	ld	a4,0(a5)
 ade:	00e6e463          	bltu	a3,a4,ae6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ae2:	fee7eae3          	bltu	a5,a4,ad6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ae6:	ff852583          	lw	a1,-8(a0)
 aea:	6390                	ld	a2,0(a5)
 aec:	02059713          	slli	a4,a1,0x20
 af0:	9301                	srli	a4,a4,0x20
 af2:	0712                	slli	a4,a4,0x4
 af4:	9736                	add	a4,a4,a3
 af6:	fae60ae3          	beq	a2,a4,aaa <free+0x14>
    bp->s.ptr = p->s.ptr;
 afa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 afe:	4790                	lw	a2,8(a5)
 b00:	02061713          	slli	a4,a2,0x20
 b04:	9301                	srli	a4,a4,0x20
 b06:	0712                	slli	a4,a4,0x4
 b08:	973e                	add	a4,a4,a5
 b0a:	fae689e3          	beq	a3,a4,abc <free+0x26>
  } else
    p->s.ptr = bp;
 b0e:	e394                	sd	a3,0(a5)
  freep = p;
 b10:	00000717          	auipc	a4,0x0
 b14:	22f73c23          	sd	a5,568(a4) # d48 <freep>
}
 b18:	6422                	ld	s0,8(sp)
 b1a:	0141                	addi	sp,sp,16
 b1c:	8082                	ret

0000000000000b1e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b1e:	7139                	addi	sp,sp,-64
 b20:	fc06                	sd	ra,56(sp)
 b22:	f822                	sd	s0,48(sp)
 b24:	f426                	sd	s1,40(sp)
 b26:	f04a                	sd	s2,32(sp)
 b28:	ec4e                	sd	s3,24(sp)
 b2a:	e852                	sd	s4,16(sp)
 b2c:	e456                	sd	s5,8(sp)
 b2e:	e05a                	sd	s6,0(sp)
 b30:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b32:	02051493          	slli	s1,a0,0x20
 b36:	9081                	srli	s1,s1,0x20
 b38:	04bd                	addi	s1,s1,15
 b3a:	8091                	srli	s1,s1,0x4
 b3c:	0014899b          	addiw	s3,s1,1
 b40:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b42:	00000517          	auipc	a0,0x0
 b46:	20653503          	ld	a0,518(a0) # d48 <freep>
 b4a:	c515                	beqz	a0,b76 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b4c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b4e:	4798                	lw	a4,8(a5)
 b50:	02977f63          	bgeu	a4,s1,b8e <malloc+0x70>
 b54:	8a4e                	mv	s4,s3
 b56:	0009871b          	sext.w	a4,s3
 b5a:	6685                	lui	a3,0x1
 b5c:	00d77363          	bgeu	a4,a3,b62 <malloc+0x44>
 b60:	6a05                	lui	s4,0x1
 b62:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b66:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b6a:	00000917          	auipc	s2,0x0
 b6e:	1de90913          	addi	s2,s2,478 # d48 <freep>
  if(p == (char*)-1)
 b72:	5afd                	li	s5,-1
 b74:	a88d                	j	be6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 b76:	00008797          	auipc	a5,0x8
 b7a:	3ba78793          	addi	a5,a5,954 # 8f30 <base>
 b7e:	00000717          	auipc	a4,0x0
 b82:	1cf73523          	sd	a5,458(a4) # d48 <freep>
 b86:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b88:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b8c:	b7e1                	j	b54 <malloc+0x36>
      if(p->s.size == nunits)
 b8e:	02e48b63          	beq	s1,a4,bc4 <malloc+0xa6>
        p->s.size -= nunits;
 b92:	4137073b          	subw	a4,a4,s3
 b96:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b98:	1702                	slli	a4,a4,0x20
 b9a:	9301                	srli	a4,a4,0x20
 b9c:	0712                	slli	a4,a4,0x4
 b9e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ba0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ba4:	00000717          	auipc	a4,0x0
 ba8:	1aa73223          	sd	a0,420(a4) # d48 <freep>
      return (void*)(p + 1);
 bac:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 bb0:	70e2                	ld	ra,56(sp)
 bb2:	7442                	ld	s0,48(sp)
 bb4:	74a2                	ld	s1,40(sp)
 bb6:	7902                	ld	s2,32(sp)
 bb8:	69e2                	ld	s3,24(sp)
 bba:	6a42                	ld	s4,16(sp)
 bbc:	6aa2                	ld	s5,8(sp)
 bbe:	6b02                	ld	s6,0(sp)
 bc0:	6121                	addi	sp,sp,64
 bc2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 bc4:	6398                	ld	a4,0(a5)
 bc6:	e118                	sd	a4,0(a0)
 bc8:	bff1                	j	ba4 <malloc+0x86>
  hp->s.size = nu;
 bca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bce:	0541                	addi	a0,a0,16
 bd0:	00000097          	auipc	ra,0x0
 bd4:	ec6080e7          	jalr	-314(ra) # a96 <free>
  return freep;
 bd8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 bdc:	d971                	beqz	a0,bb0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bde:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 be0:	4798                	lw	a4,8(a5)
 be2:	fa9776e3          	bgeu	a4,s1,b8e <malloc+0x70>
    if(p == freep)
 be6:	00093703          	ld	a4,0(s2)
 bea:	853e                	mv	a0,a5
 bec:	fef719e3          	bne	a4,a5,bde <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 bf0:	8552                	mv	a0,s4
 bf2:	00000097          	auipc	ra,0x0
 bf6:	b7e080e7          	jalr	-1154(ra) # 770 <sbrk>
  if(p == (char*)-1)
 bfa:	fd5518e3          	bne	a0,s5,bca <malloc+0xac>
        return 0;
 bfe:	4501                	li	a0,0
 c00:	bf45                	j	bb0 <malloc+0x92>
