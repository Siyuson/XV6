
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	646080e7          	jalr	1606(ra) # 5656 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	634080e7          	jalr	1588(ra) # 5656 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	e9a50513          	addi	a0,a0,-358 # 5ed8 <statistics+0x3a8>
      46:	00006097          	auipc	ra,0x6
      4a:	948080e7          	jalr	-1720(ra) # 598e <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	5c6080e7          	jalr	1478(ra) # 5616 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	3e878793          	addi	a5,a5,1000 # 9440 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	af068693          	addi	a3,a3,-1296 # bb50 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	e7850513          	addi	a0,a0,-392 # 5ef8 <statistics+0x3c8>
      88:	00006097          	auipc	ra,0x6
      8c:	906080e7          	jalr	-1786(ra) # 598e <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	584080e7          	jalr	1412(ra) # 5616 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	e6850513          	addi	a0,a0,-408 # 5f10 <statistics+0x3e0>
      b0:	00005097          	auipc	ra,0x5
      b4:	5a6080e7          	jalr	1446(ra) # 5656 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	582080e7          	jalr	1410(ra) # 563e <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	e6a50513          	addi	a0,a0,-406 # 5f30 <statistics+0x400>
      ce:	00005097          	auipc	ra,0x5
      d2:	588080e7          	jalr	1416(ra) # 5656 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	e3250513          	addi	a0,a0,-462 # 5f18 <statistics+0x3e8>
      ee:	00006097          	auipc	ra,0x6
      f2:	8a0080e7          	jalr	-1888(ra) # 598e <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	51e080e7          	jalr	1310(ra) # 5616 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	e3e50513          	addi	a0,a0,-450 # 5f40 <statistics+0x410>
     10a:	00006097          	auipc	ra,0x6
     10e:	884080e7          	jalr	-1916(ra) # 598e <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	502080e7          	jalr	1282(ra) # 5616 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	e3c50513          	addi	a0,a0,-452 # 5f68 <statistics+0x438>
     134:	00005097          	auipc	ra,0x5
     138:	532080e7          	jalr	1330(ra) # 5666 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	e2850513          	addi	a0,a0,-472 # 5f68 <statistics+0x438>
     148:	00005097          	auipc	ra,0x5
     14c:	50e080e7          	jalr	1294(ra) # 5656 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	e2458593          	addi	a1,a1,-476 # 5f78 <statistics+0x448>
     15c:	00005097          	auipc	ra,0x5
     160:	4da080e7          	jalr	1242(ra) # 5636 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	e0050513          	addi	a0,a0,-512 # 5f68 <statistics+0x438>
     170:	00005097          	auipc	ra,0x5
     174:	4e6080e7          	jalr	1254(ra) # 5656 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	e0458593          	addi	a1,a1,-508 # 5f80 <statistics+0x450>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	4b0080e7          	jalr	1200(ra) # 5636 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	dd450513          	addi	a0,a0,-556 # 5f68 <statistics+0x438>
     19c:	00005097          	auipc	ra,0x5
     1a0:	4ca080e7          	jalr	1226(ra) # 5666 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	498080e7          	jalr	1176(ra) # 563e <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	48e080e7          	jalr	1166(ra) # 563e <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	dbe50513          	addi	a0,a0,-578 # 5f88 <statistics+0x458>
     1d2:	00005097          	auipc	ra,0x5
     1d6:	7bc080e7          	jalr	1980(ra) # 598e <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	43a080e7          	jalr	1082(ra) # 5616 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00005097          	auipc	ra,0x5
     214:	446080e7          	jalr	1094(ra) # 5656 <open>
    close(fd);
     218:	00005097          	auipc	ra,0x5
     21c:	426080e7          	jalr	1062(ra) # 563e <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00005097          	auipc	ra,0x5
     24a:	420080e7          	jalr	1056(ra) # 5666 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	b0c50513          	addi	a0,a0,-1268 # 5d88 <statistics+0x258>
     284:	00005097          	auipc	ra,0x5
     288:	3e2080e7          	jalr	994(ra) # 5666 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	af8a8a93          	addi	s5,s5,-1288 # 5d88 <statistics+0x258>
      int cc = write(fd, buf, sz);
     298:	0000ca17          	auipc	s4,0xc
     29c:	8b8a0a13          	addi	s4,s4,-1864 # bb50 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x171>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00005097          	auipc	ra,0x5
     2b0:	3aa080e7          	jalr	938(ra) # 5656 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00005097          	auipc	ra,0x5
     2c2:	378080e7          	jalr	888(ra) # 5636 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	364080e7          	jalr	868(ra) # 5636 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	35e080e7          	jalr	862(ra) # 563e <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00005097          	auipc	ra,0x5
     2ee:	37c080e7          	jalr	892(ra) # 5666 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	c9e50513          	addi	a0,a0,-866 # 5fb0 <statistics+0x480>
     31a:	00005097          	auipc	ra,0x5
     31e:	674080e7          	jalr	1652(ra) # 598e <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	2f2080e7          	jalr	754(ra) # 5616 <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	c9a50513          	addi	a0,a0,-870 # 5fd0 <statistics+0x4a0>
     33e:	00005097          	auipc	ra,0x5
     342:	650080e7          	jalr	1616(ra) # 598e <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	2ce080e7          	jalr	718(ra) # 5616 <exit>

0000000000000350 <copyin>:
{
     350:	715d                	addi	sp,sp,-80
     352:	e486                	sd	ra,72(sp)
     354:	e0a2                	sd	s0,64(sp)
     356:	fc26                	sd	s1,56(sp)
     358:	f84a                	sd	s2,48(sp)
     35a:	f44e                	sd	s3,40(sp)
     35c:	f052                	sd	s4,32(sp)
     35e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     360:	4785                	li	a5,1
     362:	07fe                	slli	a5,a5,0x1f
     364:	fcf43023          	sd	a5,-64(s0)
     368:	57fd                	li	a5,-1
     36a:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     36e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     372:	00006a17          	auipc	s4,0x6
     376:	c76a0a13          	addi	s4,s4,-906 # 5fe8 <statistics+0x4b8>
    uint64 addr = addrs[ai];
     37a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     37e:	20100593          	li	a1,513
     382:	8552                	mv	a0,s4
     384:	00005097          	auipc	ra,0x5
     388:	2d2080e7          	jalr	722(ra) # 5656 <open>
     38c:	84aa                	mv	s1,a0
    if(fd < 0){
     38e:	08054863          	bltz	a0,41e <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     392:	6609                	lui	a2,0x2
     394:	85ce                	mv	a1,s3
     396:	00005097          	auipc	ra,0x5
     39a:	2a0080e7          	jalr	672(ra) # 5636 <write>
    if(n >= 0){
     39e:	08055d63          	bgez	a0,438 <copyin+0xe8>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00005097          	auipc	ra,0x5
     3a8:	29a080e7          	jalr	666(ra) # 563e <close>
    unlink("copyin1");
     3ac:	8552                	mv	a0,s4
     3ae:	00005097          	auipc	ra,0x5
     3b2:	2b8080e7          	jalr	696(ra) # 5666 <unlink>
    n = write(1, (char*)addr, 8192);
     3b6:	6609                	lui	a2,0x2
     3b8:	85ce                	mv	a1,s3
     3ba:	4505                	li	a0,1
     3bc:	00005097          	auipc	ra,0x5
     3c0:	27a080e7          	jalr	634(ra) # 5636 <write>
    if(n > 0){
     3c4:	08a04963          	bgtz	a0,456 <copyin+0x106>
    if(pipe(fds) < 0){
     3c8:	fb840513          	addi	a0,s0,-72
     3cc:	00005097          	auipc	ra,0x5
     3d0:	25a080e7          	jalr	602(ra) # 5626 <pipe>
     3d4:	0a054063          	bltz	a0,474 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3d8:	6609                	lui	a2,0x2
     3da:	85ce                	mv	a1,s3
     3dc:	fbc42503          	lw	a0,-68(s0)
     3e0:	00005097          	auipc	ra,0x5
     3e4:	256080e7          	jalr	598(ra) # 5636 <write>
    if(n > 0){
     3e8:	0aa04363          	bgtz	a0,48e <copyin+0x13e>
    close(fds[0]);
     3ec:	fb842503          	lw	a0,-72(s0)
     3f0:	00005097          	auipc	ra,0x5
     3f4:	24e080e7          	jalr	590(ra) # 563e <close>
    close(fds[1]);
     3f8:	fbc42503          	lw	a0,-68(s0)
     3fc:	00005097          	auipc	ra,0x5
     400:	242080e7          	jalr	578(ra) # 563e <close>
  for(int ai = 0; ai < 2; ai++){
     404:	0921                	addi	s2,s2,8
     406:	fd040793          	addi	a5,s0,-48
     40a:	f6f918e3          	bne	s2,a5,37a <copyin+0x2a>
}
     40e:	60a6                	ld	ra,72(sp)
     410:	6406                	ld	s0,64(sp)
     412:	74e2                	ld	s1,56(sp)
     414:	7942                	ld	s2,48(sp)
     416:	79a2                	ld	s3,40(sp)
     418:	7a02                	ld	s4,32(sp)
     41a:	6161                	addi	sp,sp,80
     41c:	8082                	ret
      printf("open(copyin1) failed\n");
     41e:	00006517          	auipc	a0,0x6
     422:	bd250513          	addi	a0,a0,-1070 # 5ff0 <statistics+0x4c0>
     426:	00005097          	auipc	ra,0x5
     42a:	568080e7          	jalr	1384(ra) # 598e <printf>
      exit(1);
     42e:	4505                	li	a0,1
     430:	00005097          	auipc	ra,0x5
     434:	1e6080e7          	jalr	486(ra) # 5616 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     438:	862a                	mv	a2,a0
     43a:	85ce                	mv	a1,s3
     43c:	00006517          	auipc	a0,0x6
     440:	bcc50513          	addi	a0,a0,-1076 # 6008 <statistics+0x4d8>
     444:	00005097          	auipc	ra,0x5
     448:	54a080e7          	jalr	1354(ra) # 598e <printf>
      exit(1);
     44c:	4505                	li	a0,1
     44e:	00005097          	auipc	ra,0x5
     452:	1c8080e7          	jalr	456(ra) # 5616 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     456:	862a                	mv	a2,a0
     458:	85ce                	mv	a1,s3
     45a:	00006517          	auipc	a0,0x6
     45e:	bde50513          	addi	a0,a0,-1058 # 6038 <statistics+0x508>
     462:	00005097          	auipc	ra,0x5
     466:	52c080e7          	jalr	1324(ra) # 598e <printf>
      exit(1);
     46a:	4505                	li	a0,1
     46c:	00005097          	auipc	ra,0x5
     470:	1aa080e7          	jalr	426(ra) # 5616 <exit>
      printf("pipe() failed\n");
     474:	00006517          	auipc	a0,0x6
     478:	bf450513          	addi	a0,a0,-1036 # 6068 <statistics+0x538>
     47c:	00005097          	auipc	ra,0x5
     480:	512080e7          	jalr	1298(ra) # 598e <printf>
      exit(1);
     484:	4505                	li	a0,1
     486:	00005097          	auipc	ra,0x5
     48a:	190080e7          	jalr	400(ra) # 5616 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     48e:	862a                	mv	a2,a0
     490:	85ce                	mv	a1,s3
     492:	00006517          	auipc	a0,0x6
     496:	be650513          	addi	a0,a0,-1050 # 6078 <statistics+0x548>
     49a:	00005097          	auipc	ra,0x5
     49e:	4f4080e7          	jalr	1268(ra) # 598e <printf>
      exit(1);
     4a2:	4505                	li	a0,1
     4a4:	00005097          	auipc	ra,0x5
     4a8:	172080e7          	jalr	370(ra) # 5616 <exit>

00000000000004ac <copyout>:
{
     4ac:	711d                	addi	sp,sp,-96
     4ae:	ec86                	sd	ra,88(sp)
     4b0:	e8a2                	sd	s0,80(sp)
     4b2:	e4a6                	sd	s1,72(sp)
     4b4:	e0ca                	sd	s2,64(sp)
     4b6:	fc4e                	sd	s3,56(sp)
     4b8:	f852                	sd	s4,48(sp)
     4ba:	f456                	sd	s5,40(sp)
     4bc:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4be:	4785                	li	a5,1
     4c0:	07fe                	slli	a5,a5,0x1f
     4c2:	faf43823          	sd	a5,-80(s0)
     4c6:	57fd                	li	a5,-1
     4c8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4cc:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4d0:	00006a17          	auipc	s4,0x6
     4d4:	bd8a0a13          	addi	s4,s4,-1064 # 60a8 <statistics+0x578>
    n = write(fds[1], "x", 1);
     4d8:	00006a97          	auipc	s5,0x6
     4dc:	aa8a8a93          	addi	s5,s5,-1368 # 5f80 <statistics+0x450>
    uint64 addr = addrs[ai];
     4e0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4e4:	4581                	li	a1,0
     4e6:	8552                	mv	a0,s4
     4e8:	00005097          	auipc	ra,0x5
     4ec:	16e080e7          	jalr	366(ra) # 5656 <open>
     4f0:	84aa                	mv	s1,a0
    if(fd < 0){
     4f2:	08054663          	bltz	a0,57e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     4f6:	6609                	lui	a2,0x2
     4f8:	85ce                	mv	a1,s3
     4fa:	00005097          	auipc	ra,0x5
     4fe:	134080e7          	jalr	308(ra) # 562e <read>
    if(n > 0){
     502:	08a04b63          	bgtz	a0,598 <copyout+0xec>
    close(fd);
     506:	8526                	mv	a0,s1
     508:	00005097          	auipc	ra,0x5
     50c:	136080e7          	jalr	310(ra) # 563e <close>
    if(pipe(fds) < 0){
     510:	fa840513          	addi	a0,s0,-88
     514:	00005097          	auipc	ra,0x5
     518:	112080e7          	jalr	274(ra) # 5626 <pipe>
     51c:	08054d63          	bltz	a0,5b6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     520:	4605                	li	a2,1
     522:	85d6                	mv	a1,s5
     524:	fac42503          	lw	a0,-84(s0)
     528:	00005097          	auipc	ra,0x5
     52c:	10e080e7          	jalr	270(ra) # 5636 <write>
    if(n != 1){
     530:	4785                	li	a5,1
     532:	08f51f63          	bne	a0,a5,5d0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     536:	6609                	lui	a2,0x2
     538:	85ce                	mv	a1,s3
     53a:	fa842503          	lw	a0,-88(s0)
     53e:	00005097          	auipc	ra,0x5
     542:	0f0080e7          	jalr	240(ra) # 562e <read>
    if(n > 0){
     546:	0aa04263          	bgtz	a0,5ea <copyout+0x13e>
    close(fds[0]);
     54a:	fa842503          	lw	a0,-88(s0)
     54e:	00005097          	auipc	ra,0x5
     552:	0f0080e7          	jalr	240(ra) # 563e <close>
    close(fds[1]);
     556:	fac42503          	lw	a0,-84(s0)
     55a:	00005097          	auipc	ra,0x5
     55e:	0e4080e7          	jalr	228(ra) # 563e <close>
  for(int ai = 0; ai < 2; ai++){
     562:	0921                	addi	s2,s2,8
     564:	fc040793          	addi	a5,s0,-64
     568:	f6f91ce3          	bne	s2,a5,4e0 <copyout+0x34>
}
     56c:	60e6                	ld	ra,88(sp)
     56e:	6446                	ld	s0,80(sp)
     570:	64a6                	ld	s1,72(sp)
     572:	6906                	ld	s2,64(sp)
     574:	79e2                	ld	s3,56(sp)
     576:	7a42                	ld	s4,48(sp)
     578:	7aa2                	ld	s5,40(sp)
     57a:	6125                	addi	sp,sp,96
     57c:	8082                	ret
      printf("open(README) failed\n");
     57e:	00006517          	auipc	a0,0x6
     582:	b3250513          	addi	a0,a0,-1230 # 60b0 <statistics+0x580>
     586:	00005097          	auipc	ra,0x5
     58a:	408080e7          	jalr	1032(ra) # 598e <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	00005097          	auipc	ra,0x5
     594:	086080e7          	jalr	134(ra) # 5616 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     598:	862a                	mv	a2,a0
     59a:	85ce                	mv	a1,s3
     59c:	00006517          	auipc	a0,0x6
     5a0:	b2c50513          	addi	a0,a0,-1236 # 60c8 <statistics+0x598>
     5a4:	00005097          	auipc	ra,0x5
     5a8:	3ea080e7          	jalr	1002(ra) # 598e <printf>
      exit(1);
     5ac:	4505                	li	a0,1
     5ae:	00005097          	auipc	ra,0x5
     5b2:	068080e7          	jalr	104(ra) # 5616 <exit>
      printf("pipe() failed\n");
     5b6:	00006517          	auipc	a0,0x6
     5ba:	ab250513          	addi	a0,a0,-1358 # 6068 <statistics+0x538>
     5be:	00005097          	auipc	ra,0x5
     5c2:	3d0080e7          	jalr	976(ra) # 598e <printf>
      exit(1);
     5c6:	4505                	li	a0,1
     5c8:	00005097          	auipc	ra,0x5
     5cc:	04e080e7          	jalr	78(ra) # 5616 <exit>
      printf("pipe write failed\n");
     5d0:	00006517          	auipc	a0,0x6
     5d4:	b2850513          	addi	a0,a0,-1240 # 60f8 <statistics+0x5c8>
     5d8:	00005097          	auipc	ra,0x5
     5dc:	3b6080e7          	jalr	950(ra) # 598e <printf>
      exit(1);
     5e0:	4505                	li	a0,1
     5e2:	00005097          	auipc	ra,0x5
     5e6:	034080e7          	jalr	52(ra) # 5616 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ea:	862a                	mv	a2,a0
     5ec:	85ce                	mv	a1,s3
     5ee:	00006517          	auipc	a0,0x6
     5f2:	b2250513          	addi	a0,a0,-1246 # 6110 <statistics+0x5e0>
     5f6:	00005097          	auipc	ra,0x5
     5fa:	398080e7          	jalr	920(ra) # 598e <printf>
      exit(1);
     5fe:	4505                	li	a0,1
     600:	00005097          	auipc	ra,0x5
     604:	016080e7          	jalr	22(ra) # 5616 <exit>

0000000000000608 <truncate1>:
{
     608:	711d                	addi	sp,sp,-96
     60a:	ec86                	sd	ra,88(sp)
     60c:	e8a2                	sd	s0,80(sp)
     60e:	e4a6                	sd	s1,72(sp)
     610:	e0ca                	sd	s2,64(sp)
     612:	fc4e                	sd	s3,56(sp)
     614:	f852                	sd	s4,48(sp)
     616:	f456                	sd	s5,40(sp)
     618:	1080                	addi	s0,sp,96
     61a:	8aaa                	mv	s5,a0
  unlink("truncfile");
     61c:	00006517          	auipc	a0,0x6
     620:	94c50513          	addi	a0,a0,-1716 # 5f68 <statistics+0x438>
     624:	00005097          	auipc	ra,0x5
     628:	042080e7          	jalr	66(ra) # 5666 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     62c:	60100593          	li	a1,1537
     630:	00006517          	auipc	a0,0x6
     634:	93850513          	addi	a0,a0,-1736 # 5f68 <statistics+0x438>
     638:	00005097          	auipc	ra,0x5
     63c:	01e080e7          	jalr	30(ra) # 5656 <open>
     640:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     642:	4611                	li	a2,4
     644:	00006597          	auipc	a1,0x6
     648:	93458593          	addi	a1,a1,-1740 # 5f78 <statistics+0x448>
     64c:	00005097          	auipc	ra,0x5
     650:	fea080e7          	jalr	-22(ra) # 5636 <write>
  close(fd1);
     654:	8526                	mv	a0,s1
     656:	00005097          	auipc	ra,0x5
     65a:	fe8080e7          	jalr	-24(ra) # 563e <close>
  int fd2 = open("truncfile", O_RDONLY);
     65e:	4581                	li	a1,0
     660:	00006517          	auipc	a0,0x6
     664:	90850513          	addi	a0,a0,-1784 # 5f68 <statistics+0x438>
     668:	00005097          	auipc	ra,0x5
     66c:	fee080e7          	jalr	-18(ra) # 5656 <open>
     670:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     672:	02000613          	li	a2,32
     676:	fa040593          	addi	a1,s0,-96
     67a:	00005097          	auipc	ra,0x5
     67e:	fb4080e7          	jalr	-76(ra) # 562e <read>
  if(n != 4){
     682:	4791                	li	a5,4
     684:	0cf51e63          	bne	a0,a5,760 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     688:	40100593          	li	a1,1025
     68c:	00006517          	auipc	a0,0x6
     690:	8dc50513          	addi	a0,a0,-1828 # 5f68 <statistics+0x438>
     694:	00005097          	auipc	ra,0x5
     698:	fc2080e7          	jalr	-62(ra) # 5656 <open>
     69c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     69e:	4581                	li	a1,0
     6a0:	00006517          	auipc	a0,0x6
     6a4:	8c850513          	addi	a0,a0,-1848 # 5f68 <statistics+0x438>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	fae080e7          	jalr	-82(ra) # 5656 <open>
     6b0:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6b2:	02000613          	li	a2,32
     6b6:	fa040593          	addi	a1,s0,-96
     6ba:	00005097          	auipc	ra,0x5
     6be:	f74080e7          	jalr	-140(ra) # 562e <read>
     6c2:	8a2a                	mv	s4,a0
  if(n != 0){
     6c4:	ed4d                	bnez	a0,77e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	8526                	mv	a0,s1
     6d0:	00005097          	auipc	ra,0x5
     6d4:	f5e080e7          	jalr	-162(ra) # 562e <read>
     6d8:	8a2a                	mv	s4,a0
  if(n != 0){
     6da:	e971                	bnez	a0,7ae <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6dc:	4619                	li	a2,6
     6de:	00006597          	auipc	a1,0x6
     6e2:	ac258593          	addi	a1,a1,-1342 # 61a0 <statistics+0x670>
     6e6:	854e                	mv	a0,s3
     6e8:	00005097          	auipc	ra,0x5
     6ec:	f4e080e7          	jalr	-178(ra) # 5636 <write>
  n = read(fd3, buf, sizeof(buf));
     6f0:	02000613          	li	a2,32
     6f4:	fa040593          	addi	a1,s0,-96
     6f8:	854a                	mv	a0,s2
     6fa:	00005097          	auipc	ra,0x5
     6fe:	f34080e7          	jalr	-204(ra) # 562e <read>
  if(n != 6){
     702:	4799                	li	a5,6
     704:	0cf51d63          	bne	a0,a5,7de <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     708:	02000613          	li	a2,32
     70c:	fa040593          	addi	a1,s0,-96
     710:	8526                	mv	a0,s1
     712:	00005097          	auipc	ra,0x5
     716:	f1c080e7          	jalr	-228(ra) # 562e <read>
  if(n != 2){
     71a:	4789                	li	a5,2
     71c:	0ef51063          	bne	a0,a5,7fc <truncate1+0x1f4>
  unlink("truncfile");
     720:	00006517          	auipc	a0,0x6
     724:	84850513          	addi	a0,a0,-1976 # 5f68 <statistics+0x438>
     728:	00005097          	auipc	ra,0x5
     72c:	f3e080e7          	jalr	-194(ra) # 5666 <unlink>
  close(fd1);
     730:	854e                	mv	a0,s3
     732:	00005097          	auipc	ra,0x5
     736:	f0c080e7          	jalr	-244(ra) # 563e <close>
  close(fd2);
     73a:	8526                	mv	a0,s1
     73c:	00005097          	auipc	ra,0x5
     740:	f02080e7          	jalr	-254(ra) # 563e <close>
  close(fd3);
     744:	854a                	mv	a0,s2
     746:	00005097          	auipc	ra,0x5
     74a:	ef8080e7          	jalr	-264(ra) # 563e <close>
}
     74e:	60e6                	ld	ra,88(sp)
     750:	6446                	ld	s0,80(sp)
     752:	64a6                	ld	s1,72(sp)
     754:	6906                	ld	s2,64(sp)
     756:	79e2                	ld	s3,56(sp)
     758:	7a42                	ld	s4,48(sp)
     75a:	7aa2                	ld	s5,40(sp)
     75c:	6125                	addi	sp,sp,96
     75e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     760:	862a                	mv	a2,a0
     762:	85d6                	mv	a1,s5
     764:	00006517          	auipc	a0,0x6
     768:	9dc50513          	addi	a0,a0,-1572 # 6140 <statistics+0x610>
     76c:	00005097          	auipc	ra,0x5
     770:	222080e7          	jalr	546(ra) # 598e <printf>
    exit(1);
     774:	4505                	li	a0,1
     776:	00005097          	auipc	ra,0x5
     77a:	ea0080e7          	jalr	-352(ra) # 5616 <exit>
    printf("aaa fd3=%d\n", fd3);
     77e:	85ca                	mv	a1,s2
     780:	00006517          	auipc	a0,0x6
     784:	9e050513          	addi	a0,a0,-1568 # 6160 <statistics+0x630>
     788:	00005097          	auipc	ra,0x5
     78c:	206080e7          	jalr	518(ra) # 598e <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     790:	8652                	mv	a2,s4
     792:	85d6                	mv	a1,s5
     794:	00006517          	auipc	a0,0x6
     798:	9dc50513          	addi	a0,a0,-1572 # 6170 <statistics+0x640>
     79c:	00005097          	auipc	ra,0x5
     7a0:	1f2080e7          	jalr	498(ra) # 598e <printf>
    exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	e70080e7          	jalr	-400(ra) # 5616 <exit>
    printf("bbb fd2=%d\n", fd2);
     7ae:	85a6                	mv	a1,s1
     7b0:	00006517          	auipc	a0,0x6
     7b4:	9e050513          	addi	a0,a0,-1568 # 6190 <statistics+0x660>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	1d6080e7          	jalr	470(ra) # 598e <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7c0:	8652                	mv	a2,s4
     7c2:	85d6                	mv	a1,s5
     7c4:	00006517          	auipc	a0,0x6
     7c8:	9ac50513          	addi	a0,a0,-1620 # 6170 <statistics+0x640>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	1c2080e7          	jalr	450(ra) # 598e <printf>
    exit(1);
     7d4:	4505                	li	a0,1
     7d6:	00005097          	auipc	ra,0x5
     7da:	e40080e7          	jalr	-448(ra) # 5616 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7de:	862a                	mv	a2,a0
     7e0:	85d6                	mv	a1,s5
     7e2:	00006517          	auipc	a0,0x6
     7e6:	9c650513          	addi	a0,a0,-1594 # 61a8 <statistics+0x678>
     7ea:	00005097          	auipc	ra,0x5
     7ee:	1a4080e7          	jalr	420(ra) # 598e <printf>
    exit(1);
     7f2:	4505                	li	a0,1
     7f4:	00005097          	auipc	ra,0x5
     7f8:	e22080e7          	jalr	-478(ra) # 5616 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     7fc:	862a                	mv	a2,a0
     7fe:	85d6                	mv	a1,s5
     800:	00006517          	auipc	a0,0x6
     804:	9c850513          	addi	a0,a0,-1592 # 61c8 <statistics+0x698>
     808:	00005097          	auipc	ra,0x5
     80c:	186080e7          	jalr	390(ra) # 598e <printf>
    exit(1);
     810:	4505                	li	a0,1
     812:	00005097          	auipc	ra,0x5
     816:	e04080e7          	jalr	-508(ra) # 5616 <exit>

000000000000081a <writetest>:
{
     81a:	7139                	addi	sp,sp,-64
     81c:	fc06                	sd	ra,56(sp)
     81e:	f822                	sd	s0,48(sp)
     820:	f426                	sd	s1,40(sp)
     822:	f04a                	sd	s2,32(sp)
     824:	ec4e                	sd	s3,24(sp)
     826:	e852                	sd	s4,16(sp)
     828:	e456                	sd	s5,8(sp)
     82a:	e05a                	sd	s6,0(sp)
     82c:	0080                	addi	s0,sp,64
     82e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     830:	20200593          	li	a1,514
     834:	00006517          	auipc	a0,0x6
     838:	9b450513          	addi	a0,a0,-1612 # 61e8 <statistics+0x6b8>
     83c:	00005097          	auipc	ra,0x5
     840:	e1a080e7          	jalr	-486(ra) # 5656 <open>
  if(fd < 0){
     844:	0a054d63          	bltz	a0,8fe <writetest+0xe4>
     848:	892a                	mv	s2,a0
     84a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     84c:	00006997          	auipc	s3,0x6
     850:	9c498993          	addi	s3,s3,-1596 # 6210 <statistics+0x6e0>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     854:	00006a97          	auipc	s5,0x6
     858:	9f4a8a93          	addi	s5,s5,-1548 # 6248 <statistics+0x718>
  for(i = 0; i < N; i++){
     85c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	4629                	li	a2,10
     862:	85ce                	mv	a1,s3
     864:	854a                	mv	a0,s2
     866:	00005097          	auipc	ra,0x5
     86a:	dd0080e7          	jalr	-560(ra) # 5636 <write>
     86e:	47a9                	li	a5,10
     870:	0af51563          	bne	a0,a5,91a <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85d6                	mv	a1,s5
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	dbc080e7          	jalr	-580(ra) # 5636 <write>
     882:	47a9                	li	a5,10
     884:	0af51a63          	bne	a0,a5,938 <writetest+0x11e>
  for(i = 0; i < N; i++){
     888:	2485                	addiw	s1,s1,1
     88a:	fd449be3          	bne	s1,s4,860 <writetest+0x46>
  close(fd);
     88e:	854a                	mv	a0,s2
     890:	00005097          	auipc	ra,0x5
     894:	dae080e7          	jalr	-594(ra) # 563e <close>
  fd = open("small", O_RDONLY);
     898:	4581                	li	a1,0
     89a:	00006517          	auipc	a0,0x6
     89e:	94e50513          	addi	a0,a0,-1714 # 61e8 <statistics+0x6b8>
     8a2:	00005097          	auipc	ra,0x5
     8a6:	db4080e7          	jalr	-588(ra) # 5656 <open>
     8aa:	84aa                	mv	s1,a0
  if(fd < 0){
     8ac:	0a054563          	bltz	a0,956 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8b0:	7d000613          	li	a2,2000
     8b4:	0000b597          	auipc	a1,0xb
     8b8:	29c58593          	addi	a1,a1,668 # bb50 <buf>
     8bc:	00005097          	auipc	ra,0x5
     8c0:	d72080e7          	jalr	-654(ra) # 562e <read>
  if(i != N*SZ*2){
     8c4:	7d000793          	li	a5,2000
     8c8:	0af51563          	bne	a0,a5,972 <writetest+0x158>
  close(fd);
     8cc:	8526                	mv	a0,s1
     8ce:	00005097          	auipc	ra,0x5
     8d2:	d70080e7          	jalr	-656(ra) # 563e <close>
  if(unlink("small") < 0){
     8d6:	00006517          	auipc	a0,0x6
     8da:	91250513          	addi	a0,a0,-1774 # 61e8 <statistics+0x6b8>
     8de:	00005097          	auipc	ra,0x5
     8e2:	d88080e7          	jalr	-632(ra) # 5666 <unlink>
     8e6:	0a054463          	bltz	a0,98e <writetest+0x174>
}
     8ea:	70e2                	ld	ra,56(sp)
     8ec:	7442                	ld	s0,48(sp)
     8ee:	74a2                	ld	s1,40(sp)
     8f0:	7902                	ld	s2,32(sp)
     8f2:	69e2                	ld	s3,24(sp)
     8f4:	6a42                	ld	s4,16(sp)
     8f6:	6aa2                	ld	s5,8(sp)
     8f8:	6b02                	ld	s6,0(sp)
     8fa:	6121                	addi	sp,sp,64
     8fc:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     8fe:	85da                	mv	a1,s6
     900:	00006517          	auipc	a0,0x6
     904:	8f050513          	addi	a0,a0,-1808 # 61f0 <statistics+0x6c0>
     908:	00005097          	auipc	ra,0x5
     90c:	086080e7          	jalr	134(ra) # 598e <printf>
    exit(1);
     910:	4505                	li	a0,1
     912:	00005097          	auipc	ra,0x5
     916:	d04080e7          	jalr	-764(ra) # 5616 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     91a:	8626                	mv	a2,s1
     91c:	85da                	mv	a1,s6
     91e:	00006517          	auipc	a0,0x6
     922:	90250513          	addi	a0,a0,-1790 # 6220 <statistics+0x6f0>
     926:	00005097          	auipc	ra,0x5
     92a:	068080e7          	jalr	104(ra) # 598e <printf>
      exit(1);
     92e:	4505                	li	a0,1
     930:	00005097          	auipc	ra,0x5
     934:	ce6080e7          	jalr	-794(ra) # 5616 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     938:	8626                	mv	a2,s1
     93a:	85da                	mv	a1,s6
     93c:	00006517          	auipc	a0,0x6
     940:	91c50513          	addi	a0,a0,-1764 # 6258 <statistics+0x728>
     944:	00005097          	auipc	ra,0x5
     948:	04a080e7          	jalr	74(ra) # 598e <printf>
      exit(1);
     94c:	4505                	li	a0,1
     94e:	00005097          	auipc	ra,0x5
     952:	cc8080e7          	jalr	-824(ra) # 5616 <exit>
    printf("%s: error: open small failed!\n", s);
     956:	85da                	mv	a1,s6
     958:	00006517          	auipc	a0,0x6
     95c:	92850513          	addi	a0,a0,-1752 # 6280 <statistics+0x750>
     960:	00005097          	auipc	ra,0x5
     964:	02e080e7          	jalr	46(ra) # 598e <printf>
    exit(1);
     968:	4505                	li	a0,1
     96a:	00005097          	auipc	ra,0x5
     96e:	cac080e7          	jalr	-852(ra) # 5616 <exit>
    printf("%s: read failed\n", s);
     972:	85da                	mv	a1,s6
     974:	00006517          	auipc	a0,0x6
     978:	92c50513          	addi	a0,a0,-1748 # 62a0 <statistics+0x770>
     97c:	00005097          	auipc	ra,0x5
     980:	012080e7          	jalr	18(ra) # 598e <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	c90080e7          	jalr	-880(ra) # 5616 <exit>
    printf("%s: unlink small failed\n", s);
     98e:	85da                	mv	a1,s6
     990:	00006517          	auipc	a0,0x6
     994:	92850513          	addi	a0,a0,-1752 # 62b8 <statistics+0x788>
     998:	00005097          	auipc	ra,0x5
     99c:	ff6080e7          	jalr	-10(ra) # 598e <printf>
    exit(1);
     9a0:	4505                	li	a0,1
     9a2:	00005097          	auipc	ra,0x5
     9a6:	c74080e7          	jalr	-908(ra) # 5616 <exit>

00000000000009aa <writebig>:
{
     9aa:	7139                	addi	sp,sp,-64
     9ac:	fc06                	sd	ra,56(sp)
     9ae:	f822                	sd	s0,48(sp)
     9b0:	f426                	sd	s1,40(sp)
     9b2:	f04a                	sd	s2,32(sp)
     9b4:	ec4e                	sd	s3,24(sp)
     9b6:	e852                	sd	s4,16(sp)
     9b8:	e456                	sd	s5,8(sp)
     9ba:	0080                	addi	s0,sp,64
     9bc:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9be:	20200593          	li	a1,514
     9c2:	00006517          	auipc	a0,0x6
     9c6:	91650513          	addi	a0,a0,-1770 # 62d8 <statistics+0x7a8>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	c8c080e7          	jalr	-884(ra) # 5656 <open>
     9d2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9d4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9d6:	0000b917          	auipc	s2,0xb
     9da:	17a90913          	addi	s2,s2,378 # bb50 <buf>
  for(i = 0; i < MAXFILE; i++){
     9de:	10c00a13          	li	s4,268
  if(fd < 0){
     9e2:	06054c63          	bltz	a0,a5a <writebig+0xb0>
    ((int*)buf)[0] = i;
     9e6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9ea:	40000613          	li	a2,1024
     9ee:	85ca                	mv	a1,s2
     9f0:	854e                	mv	a0,s3
     9f2:	00005097          	auipc	ra,0x5
     9f6:	c44080e7          	jalr	-956(ra) # 5636 <write>
     9fa:	40000793          	li	a5,1024
     9fe:	06f51c63          	bne	a0,a5,a76 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a02:	2485                	addiw	s1,s1,1
     a04:	ff4491e3          	bne	s1,s4,9e6 <writebig+0x3c>
  close(fd);
     a08:	854e                	mv	a0,s3
     a0a:	00005097          	auipc	ra,0x5
     a0e:	c34080e7          	jalr	-972(ra) # 563e <close>
  fd = open("big", O_RDONLY);
     a12:	4581                	li	a1,0
     a14:	00006517          	auipc	a0,0x6
     a18:	8c450513          	addi	a0,a0,-1852 # 62d8 <statistics+0x7a8>
     a1c:	00005097          	auipc	ra,0x5
     a20:	c3a080e7          	jalr	-966(ra) # 5656 <open>
     a24:	89aa                	mv	s3,a0
  n = 0;
     a26:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a28:	0000b917          	auipc	s2,0xb
     a2c:	12890913          	addi	s2,s2,296 # bb50 <buf>
  if(fd < 0){
     a30:	06054263          	bltz	a0,a94 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a34:	40000613          	li	a2,1024
     a38:	85ca                	mv	a1,s2
     a3a:	854e                	mv	a0,s3
     a3c:	00005097          	auipc	ra,0x5
     a40:	bf2080e7          	jalr	-1038(ra) # 562e <read>
    if(i == 0){
     a44:	c535                	beqz	a0,ab0 <writebig+0x106>
    } else if(i != BSIZE){
     a46:	40000793          	li	a5,1024
     a4a:	0af51f63          	bne	a0,a5,b08 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0c969a63          	bne	a3,s1,b26 <writebig+0x17c>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	bff1                	j	a34 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00006517          	auipc	a0,0x6
     a60:	88450513          	addi	a0,a0,-1916 # 62e0 <statistics+0x7b0>
     a64:	00005097          	auipc	ra,0x5
     a68:	f2a080e7          	jalr	-214(ra) # 598e <printf>
    exit(1);
     a6c:	4505                	li	a0,1
     a6e:	00005097          	auipc	ra,0x5
     a72:	ba8080e7          	jalr	-1112(ra) # 5616 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a76:	8626                	mv	a2,s1
     a78:	85d6                	mv	a1,s5
     a7a:	00006517          	auipc	a0,0x6
     a7e:	88650513          	addi	a0,a0,-1914 # 6300 <statistics+0x7d0>
     a82:	00005097          	auipc	ra,0x5
     a86:	f0c080e7          	jalr	-244(ra) # 598e <printf>
      exit(1);
     a8a:	4505                	li	a0,1
     a8c:	00005097          	auipc	ra,0x5
     a90:	b8a080e7          	jalr	-1142(ra) # 5616 <exit>
    printf("%s: error: open big failed!\n", s);
     a94:	85d6                	mv	a1,s5
     a96:	00006517          	auipc	a0,0x6
     a9a:	89250513          	addi	a0,a0,-1902 # 6328 <statistics+0x7f8>
     a9e:	00005097          	auipc	ra,0x5
     aa2:	ef0080e7          	jalr	-272(ra) # 598e <printf>
    exit(1);
     aa6:	4505                	li	a0,1
     aa8:	00005097          	auipc	ra,0x5
     aac:	b6e080e7          	jalr	-1170(ra) # 5616 <exit>
      if(n == MAXFILE - 1){
     ab0:	10b00793          	li	a5,267
     ab4:	02f48a63          	beq	s1,a5,ae8 <writebig+0x13e>
  close(fd);
     ab8:	854e                	mv	a0,s3
     aba:	00005097          	auipc	ra,0x5
     abe:	b84080e7          	jalr	-1148(ra) # 563e <close>
  if(unlink("big") < 0){
     ac2:	00006517          	auipc	a0,0x6
     ac6:	81650513          	addi	a0,a0,-2026 # 62d8 <statistics+0x7a8>
     aca:	00005097          	auipc	ra,0x5
     ace:	b9c080e7          	jalr	-1124(ra) # 5666 <unlink>
     ad2:	06054963          	bltz	a0,b44 <writebig+0x19a>
}
     ad6:	70e2                	ld	ra,56(sp)
     ad8:	7442                	ld	s0,48(sp)
     ada:	74a2                	ld	s1,40(sp)
     adc:	7902                	ld	s2,32(sp)
     ade:	69e2                	ld	s3,24(sp)
     ae0:	6a42                	ld	s4,16(sp)
     ae2:	6aa2                	ld	s5,8(sp)
     ae4:	6121                	addi	sp,sp,64
     ae6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ae8:	10b00613          	li	a2,267
     aec:	85d6                	mv	a1,s5
     aee:	00006517          	auipc	a0,0x6
     af2:	85a50513          	addi	a0,a0,-1958 # 6348 <statistics+0x818>
     af6:	00005097          	auipc	ra,0x5
     afa:	e98080e7          	jalr	-360(ra) # 598e <printf>
        exit(1);
     afe:	4505                	li	a0,1
     b00:	00005097          	auipc	ra,0x5
     b04:	b16080e7          	jalr	-1258(ra) # 5616 <exit>
      printf("%s: read failed %d\n", s, i);
     b08:	862a                	mv	a2,a0
     b0a:	85d6                	mv	a1,s5
     b0c:	00006517          	auipc	a0,0x6
     b10:	86450513          	addi	a0,a0,-1948 # 6370 <statistics+0x840>
     b14:	00005097          	auipc	ra,0x5
     b18:	e7a080e7          	jalr	-390(ra) # 598e <printf>
      exit(1);
     b1c:	4505                	li	a0,1
     b1e:	00005097          	auipc	ra,0x5
     b22:	af8080e7          	jalr	-1288(ra) # 5616 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b26:	8626                	mv	a2,s1
     b28:	85d6                	mv	a1,s5
     b2a:	00006517          	auipc	a0,0x6
     b2e:	85e50513          	addi	a0,a0,-1954 # 6388 <statistics+0x858>
     b32:	00005097          	auipc	ra,0x5
     b36:	e5c080e7          	jalr	-420(ra) # 598e <printf>
      exit(1);
     b3a:	4505                	li	a0,1
     b3c:	00005097          	auipc	ra,0x5
     b40:	ada080e7          	jalr	-1318(ra) # 5616 <exit>
    printf("%s: unlink big failed\n", s);
     b44:	85d6                	mv	a1,s5
     b46:	00006517          	auipc	a0,0x6
     b4a:	86a50513          	addi	a0,a0,-1942 # 63b0 <statistics+0x880>
     b4e:	00005097          	auipc	ra,0x5
     b52:	e40080e7          	jalr	-448(ra) # 598e <printf>
    exit(1);
     b56:	4505                	li	a0,1
     b58:	00005097          	auipc	ra,0x5
     b5c:	abe080e7          	jalr	-1346(ra) # 5616 <exit>

0000000000000b60 <unlinkread>:
{
     b60:	7179                	addi	sp,sp,-48
     b62:	f406                	sd	ra,40(sp)
     b64:	f022                	sd	s0,32(sp)
     b66:	ec26                	sd	s1,24(sp)
     b68:	e84a                	sd	s2,16(sp)
     b6a:	e44e                	sd	s3,8(sp)
     b6c:	1800                	addi	s0,sp,48
     b6e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b70:	20200593          	li	a1,514
     b74:	00005517          	auipc	a0,0x5
     b78:	1a450513          	addi	a0,a0,420 # 5d18 <statistics+0x1e8>
     b7c:	00005097          	auipc	ra,0x5
     b80:	ada080e7          	jalr	-1318(ra) # 5656 <open>
  if(fd < 0){
     b84:	0e054563          	bltz	a0,c6e <unlinkread+0x10e>
     b88:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b8a:	4615                	li	a2,5
     b8c:	00006597          	auipc	a1,0x6
     b90:	85c58593          	addi	a1,a1,-1956 # 63e8 <statistics+0x8b8>
     b94:	00005097          	auipc	ra,0x5
     b98:	aa2080e7          	jalr	-1374(ra) # 5636 <write>
  close(fd);
     b9c:	8526                	mv	a0,s1
     b9e:	00005097          	auipc	ra,0x5
     ba2:	aa0080e7          	jalr	-1376(ra) # 563e <close>
  fd = open("unlinkread", O_RDWR);
     ba6:	4589                	li	a1,2
     ba8:	00005517          	auipc	a0,0x5
     bac:	17050513          	addi	a0,a0,368 # 5d18 <statistics+0x1e8>
     bb0:	00005097          	auipc	ra,0x5
     bb4:	aa6080e7          	jalr	-1370(ra) # 5656 <open>
     bb8:	84aa                	mv	s1,a0
  if(fd < 0){
     bba:	0c054863          	bltz	a0,c8a <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bbe:	00005517          	auipc	a0,0x5
     bc2:	15a50513          	addi	a0,a0,346 # 5d18 <statistics+0x1e8>
     bc6:	00005097          	auipc	ra,0x5
     bca:	aa0080e7          	jalr	-1376(ra) # 5666 <unlink>
     bce:	ed61                	bnez	a0,ca6 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd0:	20200593          	li	a1,514
     bd4:	00005517          	auipc	a0,0x5
     bd8:	14450513          	addi	a0,a0,324 # 5d18 <statistics+0x1e8>
     bdc:	00005097          	auipc	ra,0x5
     be0:	a7a080e7          	jalr	-1414(ra) # 5656 <open>
     be4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     be6:	460d                	li	a2,3
     be8:	00006597          	auipc	a1,0x6
     bec:	84858593          	addi	a1,a1,-1976 # 6430 <statistics+0x900>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	a46080e7          	jalr	-1466(ra) # 5636 <write>
  close(fd1);
     bf8:	854a                	mv	a0,s2
     bfa:	00005097          	auipc	ra,0x5
     bfe:	a44080e7          	jalr	-1468(ra) # 563e <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c02:	660d                	lui	a2,0x3
     c04:	0000b597          	auipc	a1,0xb
     c08:	f4c58593          	addi	a1,a1,-180 # bb50 <buf>
     c0c:	8526                	mv	a0,s1
     c0e:	00005097          	auipc	ra,0x5
     c12:	a20080e7          	jalr	-1504(ra) # 562e <read>
     c16:	4795                	li	a5,5
     c18:	0af51563          	bne	a0,a5,cc2 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c1c:	0000b717          	auipc	a4,0xb
     c20:	f3474703          	lbu	a4,-204(a4) # bb50 <buf>
     c24:	06800793          	li	a5,104
     c28:	0af71b63          	bne	a4,a5,cde <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c2c:	4629                	li	a2,10
     c2e:	0000b597          	auipc	a1,0xb
     c32:	f2258593          	addi	a1,a1,-222 # bb50 <buf>
     c36:	8526                	mv	a0,s1
     c38:	00005097          	auipc	ra,0x5
     c3c:	9fe080e7          	jalr	-1538(ra) # 5636 <write>
     c40:	47a9                	li	a5,10
     c42:	0af51c63          	bne	a0,a5,cfa <unlinkread+0x19a>
  close(fd);
     c46:	8526                	mv	a0,s1
     c48:	00005097          	auipc	ra,0x5
     c4c:	9f6080e7          	jalr	-1546(ra) # 563e <close>
  unlink("unlinkread");
     c50:	00005517          	auipc	a0,0x5
     c54:	0c850513          	addi	a0,a0,200 # 5d18 <statistics+0x1e8>
     c58:	00005097          	auipc	ra,0x5
     c5c:	a0e080e7          	jalr	-1522(ra) # 5666 <unlink>
}
     c60:	70a2                	ld	ra,40(sp)
     c62:	7402                	ld	s0,32(sp)
     c64:	64e2                	ld	s1,24(sp)
     c66:	6942                	ld	s2,16(sp)
     c68:	69a2                	ld	s3,8(sp)
     c6a:	6145                	addi	sp,sp,48
     c6c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c6e:	85ce                	mv	a1,s3
     c70:	00005517          	auipc	a0,0x5
     c74:	75850513          	addi	a0,a0,1880 # 63c8 <statistics+0x898>
     c78:	00005097          	auipc	ra,0x5
     c7c:	d16080e7          	jalr	-746(ra) # 598e <printf>
    exit(1);
     c80:	4505                	li	a0,1
     c82:	00005097          	auipc	ra,0x5
     c86:	994080e7          	jalr	-1644(ra) # 5616 <exit>
    printf("%s: open unlinkread failed\n", s);
     c8a:	85ce                	mv	a1,s3
     c8c:	00005517          	auipc	a0,0x5
     c90:	76450513          	addi	a0,a0,1892 # 63f0 <statistics+0x8c0>
     c94:	00005097          	auipc	ra,0x5
     c98:	cfa080e7          	jalr	-774(ra) # 598e <printf>
    exit(1);
     c9c:	4505                	li	a0,1
     c9e:	00005097          	auipc	ra,0x5
     ca2:	978080e7          	jalr	-1672(ra) # 5616 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ca6:	85ce                	mv	a1,s3
     ca8:	00005517          	auipc	a0,0x5
     cac:	76850513          	addi	a0,a0,1896 # 6410 <statistics+0x8e0>
     cb0:	00005097          	auipc	ra,0x5
     cb4:	cde080e7          	jalr	-802(ra) # 598e <printf>
    exit(1);
     cb8:	4505                	li	a0,1
     cba:	00005097          	auipc	ra,0x5
     cbe:	95c080e7          	jalr	-1700(ra) # 5616 <exit>
    printf("%s: unlinkread read failed", s);
     cc2:	85ce                	mv	a1,s3
     cc4:	00005517          	auipc	a0,0x5
     cc8:	77450513          	addi	a0,a0,1908 # 6438 <statistics+0x908>
     ccc:	00005097          	auipc	ra,0x5
     cd0:	cc2080e7          	jalr	-830(ra) # 598e <printf>
    exit(1);
     cd4:	4505                	li	a0,1
     cd6:	00005097          	auipc	ra,0x5
     cda:	940080e7          	jalr	-1728(ra) # 5616 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cde:	85ce                	mv	a1,s3
     ce0:	00005517          	auipc	a0,0x5
     ce4:	77850513          	addi	a0,a0,1912 # 6458 <statistics+0x928>
     ce8:	00005097          	auipc	ra,0x5
     cec:	ca6080e7          	jalr	-858(ra) # 598e <printf>
    exit(1);
     cf0:	4505                	li	a0,1
     cf2:	00005097          	auipc	ra,0x5
     cf6:	924080e7          	jalr	-1756(ra) # 5616 <exit>
    printf("%s: unlinkread write failed\n", s);
     cfa:	85ce                	mv	a1,s3
     cfc:	00005517          	auipc	a0,0x5
     d00:	77c50513          	addi	a0,a0,1916 # 6478 <statistics+0x948>
     d04:	00005097          	auipc	ra,0x5
     d08:	c8a080e7          	jalr	-886(ra) # 598e <printf>
    exit(1);
     d0c:	4505                	li	a0,1
     d0e:	00005097          	auipc	ra,0x5
     d12:	908080e7          	jalr	-1784(ra) # 5616 <exit>

0000000000000d16 <linktest>:
{
     d16:	1101                	addi	sp,sp,-32
     d18:	ec06                	sd	ra,24(sp)
     d1a:	e822                	sd	s0,16(sp)
     d1c:	e426                	sd	s1,8(sp)
     d1e:	e04a                	sd	s2,0(sp)
     d20:	1000                	addi	s0,sp,32
     d22:	892a                	mv	s2,a0
  unlink("lf1");
     d24:	00005517          	auipc	a0,0x5
     d28:	77450513          	addi	a0,a0,1908 # 6498 <statistics+0x968>
     d2c:	00005097          	auipc	ra,0x5
     d30:	93a080e7          	jalr	-1734(ra) # 5666 <unlink>
  unlink("lf2");
     d34:	00005517          	auipc	a0,0x5
     d38:	76c50513          	addi	a0,a0,1900 # 64a0 <statistics+0x970>
     d3c:	00005097          	auipc	ra,0x5
     d40:	92a080e7          	jalr	-1750(ra) # 5666 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d44:	20200593          	li	a1,514
     d48:	00005517          	auipc	a0,0x5
     d4c:	75050513          	addi	a0,a0,1872 # 6498 <statistics+0x968>
     d50:	00005097          	auipc	ra,0x5
     d54:	906080e7          	jalr	-1786(ra) # 5656 <open>
  if(fd < 0){
     d58:	10054763          	bltz	a0,e66 <linktest+0x150>
     d5c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d5e:	4615                	li	a2,5
     d60:	00005597          	auipc	a1,0x5
     d64:	68858593          	addi	a1,a1,1672 # 63e8 <statistics+0x8b8>
     d68:	00005097          	auipc	ra,0x5
     d6c:	8ce080e7          	jalr	-1842(ra) # 5636 <write>
     d70:	4795                	li	a5,5
     d72:	10f51863          	bne	a0,a5,e82 <linktest+0x16c>
  close(fd);
     d76:	8526                	mv	a0,s1
     d78:	00005097          	auipc	ra,0x5
     d7c:	8c6080e7          	jalr	-1850(ra) # 563e <close>
  if(link("lf1", "lf2") < 0){
     d80:	00005597          	auipc	a1,0x5
     d84:	72058593          	addi	a1,a1,1824 # 64a0 <statistics+0x970>
     d88:	00005517          	auipc	a0,0x5
     d8c:	71050513          	addi	a0,a0,1808 # 6498 <statistics+0x968>
     d90:	00005097          	auipc	ra,0x5
     d94:	8e6080e7          	jalr	-1818(ra) # 5676 <link>
     d98:	10054363          	bltz	a0,e9e <linktest+0x188>
  unlink("lf1");
     d9c:	00005517          	auipc	a0,0x5
     da0:	6fc50513          	addi	a0,a0,1788 # 6498 <statistics+0x968>
     da4:	00005097          	auipc	ra,0x5
     da8:	8c2080e7          	jalr	-1854(ra) # 5666 <unlink>
  if(open("lf1", 0) >= 0){
     dac:	4581                	li	a1,0
     dae:	00005517          	auipc	a0,0x5
     db2:	6ea50513          	addi	a0,a0,1770 # 6498 <statistics+0x968>
     db6:	00005097          	auipc	ra,0x5
     dba:	8a0080e7          	jalr	-1888(ra) # 5656 <open>
     dbe:	0e055e63          	bgez	a0,eba <linktest+0x1a4>
  fd = open("lf2", 0);
     dc2:	4581                	li	a1,0
     dc4:	00005517          	auipc	a0,0x5
     dc8:	6dc50513          	addi	a0,a0,1756 # 64a0 <statistics+0x970>
     dcc:	00005097          	auipc	ra,0x5
     dd0:	88a080e7          	jalr	-1910(ra) # 5656 <open>
     dd4:	84aa                	mv	s1,a0
  if(fd < 0){
     dd6:	10054063          	bltz	a0,ed6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dda:	660d                	lui	a2,0x3
     ddc:	0000b597          	auipc	a1,0xb
     de0:	d7458593          	addi	a1,a1,-652 # bb50 <buf>
     de4:	00005097          	auipc	ra,0x5
     de8:	84a080e7          	jalr	-1974(ra) # 562e <read>
     dec:	4795                	li	a5,5
     dee:	10f51263          	bne	a0,a5,ef2 <linktest+0x1dc>
  close(fd);
     df2:	8526                	mv	a0,s1
     df4:	00005097          	auipc	ra,0x5
     df8:	84a080e7          	jalr	-1974(ra) # 563e <close>
  if(link("lf2", "lf2") >= 0){
     dfc:	00005597          	auipc	a1,0x5
     e00:	6a458593          	addi	a1,a1,1700 # 64a0 <statistics+0x970>
     e04:	852e                	mv	a0,a1
     e06:	00005097          	auipc	ra,0x5
     e0a:	870080e7          	jalr	-1936(ra) # 5676 <link>
     e0e:	10055063          	bgez	a0,f0e <linktest+0x1f8>
  unlink("lf2");
     e12:	00005517          	auipc	a0,0x5
     e16:	68e50513          	addi	a0,a0,1678 # 64a0 <statistics+0x970>
     e1a:	00005097          	auipc	ra,0x5
     e1e:	84c080e7          	jalr	-1972(ra) # 5666 <unlink>
  if(link("lf2", "lf1") >= 0){
     e22:	00005597          	auipc	a1,0x5
     e26:	67658593          	addi	a1,a1,1654 # 6498 <statistics+0x968>
     e2a:	00005517          	auipc	a0,0x5
     e2e:	67650513          	addi	a0,a0,1654 # 64a0 <statistics+0x970>
     e32:	00005097          	auipc	ra,0x5
     e36:	844080e7          	jalr	-1980(ra) # 5676 <link>
     e3a:	0e055863          	bgez	a0,f2a <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e3e:	00005597          	auipc	a1,0x5
     e42:	65a58593          	addi	a1,a1,1626 # 6498 <statistics+0x968>
     e46:	00005517          	auipc	a0,0x5
     e4a:	76250513          	addi	a0,a0,1890 # 65a8 <statistics+0xa78>
     e4e:	00005097          	auipc	ra,0x5
     e52:	828080e7          	jalr	-2008(ra) # 5676 <link>
     e56:	0e055863          	bgez	a0,f46 <linktest+0x230>
}
     e5a:	60e2                	ld	ra,24(sp)
     e5c:	6442                	ld	s0,16(sp)
     e5e:	64a2                	ld	s1,8(sp)
     e60:	6902                	ld	s2,0(sp)
     e62:	6105                	addi	sp,sp,32
     e64:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e66:	85ca                	mv	a1,s2
     e68:	00005517          	auipc	a0,0x5
     e6c:	64050513          	addi	a0,a0,1600 # 64a8 <statistics+0x978>
     e70:	00005097          	auipc	ra,0x5
     e74:	b1e080e7          	jalr	-1250(ra) # 598e <printf>
    exit(1);
     e78:	4505                	li	a0,1
     e7a:	00004097          	auipc	ra,0x4
     e7e:	79c080e7          	jalr	1948(ra) # 5616 <exit>
    printf("%s: write lf1 failed\n", s);
     e82:	85ca                	mv	a1,s2
     e84:	00005517          	auipc	a0,0x5
     e88:	63c50513          	addi	a0,a0,1596 # 64c0 <statistics+0x990>
     e8c:	00005097          	auipc	ra,0x5
     e90:	b02080e7          	jalr	-1278(ra) # 598e <printf>
    exit(1);
     e94:	4505                	li	a0,1
     e96:	00004097          	auipc	ra,0x4
     e9a:	780080e7          	jalr	1920(ra) # 5616 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     e9e:	85ca                	mv	a1,s2
     ea0:	00005517          	auipc	a0,0x5
     ea4:	63850513          	addi	a0,a0,1592 # 64d8 <statistics+0x9a8>
     ea8:	00005097          	auipc	ra,0x5
     eac:	ae6080e7          	jalr	-1306(ra) # 598e <printf>
    exit(1);
     eb0:	4505                	li	a0,1
     eb2:	00004097          	auipc	ra,0x4
     eb6:	764080e7          	jalr	1892(ra) # 5616 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     eba:	85ca                	mv	a1,s2
     ebc:	00005517          	auipc	a0,0x5
     ec0:	63c50513          	addi	a0,a0,1596 # 64f8 <statistics+0x9c8>
     ec4:	00005097          	auipc	ra,0x5
     ec8:	aca080e7          	jalr	-1334(ra) # 598e <printf>
    exit(1);
     ecc:	4505                	li	a0,1
     ece:	00004097          	auipc	ra,0x4
     ed2:	748080e7          	jalr	1864(ra) # 5616 <exit>
    printf("%s: open lf2 failed\n", s);
     ed6:	85ca                	mv	a1,s2
     ed8:	00005517          	auipc	a0,0x5
     edc:	65050513          	addi	a0,a0,1616 # 6528 <statistics+0x9f8>
     ee0:	00005097          	auipc	ra,0x5
     ee4:	aae080e7          	jalr	-1362(ra) # 598e <printf>
    exit(1);
     ee8:	4505                	li	a0,1
     eea:	00004097          	auipc	ra,0x4
     eee:	72c080e7          	jalr	1836(ra) # 5616 <exit>
    printf("%s: read lf2 failed\n", s);
     ef2:	85ca                	mv	a1,s2
     ef4:	00005517          	auipc	a0,0x5
     ef8:	64c50513          	addi	a0,a0,1612 # 6540 <statistics+0xa10>
     efc:	00005097          	auipc	ra,0x5
     f00:	a92080e7          	jalr	-1390(ra) # 598e <printf>
    exit(1);
     f04:	4505                	li	a0,1
     f06:	00004097          	auipc	ra,0x4
     f0a:	710080e7          	jalr	1808(ra) # 5616 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f0e:	85ca                	mv	a1,s2
     f10:	00005517          	auipc	a0,0x5
     f14:	64850513          	addi	a0,a0,1608 # 6558 <statistics+0xa28>
     f18:	00005097          	auipc	ra,0x5
     f1c:	a76080e7          	jalr	-1418(ra) # 598e <printf>
    exit(1);
     f20:	4505                	li	a0,1
     f22:	00004097          	auipc	ra,0x4
     f26:	6f4080e7          	jalr	1780(ra) # 5616 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f2a:	85ca                	mv	a1,s2
     f2c:	00005517          	auipc	a0,0x5
     f30:	65450513          	addi	a0,a0,1620 # 6580 <statistics+0xa50>
     f34:	00005097          	auipc	ra,0x5
     f38:	a5a080e7          	jalr	-1446(ra) # 598e <printf>
    exit(1);
     f3c:	4505                	li	a0,1
     f3e:	00004097          	auipc	ra,0x4
     f42:	6d8080e7          	jalr	1752(ra) # 5616 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f46:	85ca                	mv	a1,s2
     f48:	00005517          	auipc	a0,0x5
     f4c:	66850513          	addi	a0,a0,1640 # 65b0 <statistics+0xa80>
     f50:	00005097          	auipc	ra,0x5
     f54:	a3e080e7          	jalr	-1474(ra) # 598e <printf>
    exit(1);
     f58:	4505                	li	a0,1
     f5a:	00004097          	auipc	ra,0x4
     f5e:	6bc080e7          	jalr	1724(ra) # 5616 <exit>

0000000000000f62 <bigdir>:
{
     f62:	715d                	addi	sp,sp,-80
     f64:	e486                	sd	ra,72(sp)
     f66:	e0a2                	sd	s0,64(sp)
     f68:	fc26                	sd	s1,56(sp)
     f6a:	f84a                	sd	s2,48(sp)
     f6c:	f44e                	sd	s3,40(sp)
     f6e:	f052                	sd	s4,32(sp)
     f70:	ec56                	sd	s5,24(sp)
     f72:	e85a                	sd	s6,16(sp)
     f74:	0880                	addi	s0,sp,80
     f76:	89aa                	mv	s3,a0
  unlink("bd");
     f78:	00005517          	auipc	a0,0x5
     f7c:	65850513          	addi	a0,a0,1624 # 65d0 <statistics+0xaa0>
     f80:	00004097          	auipc	ra,0x4
     f84:	6e6080e7          	jalr	1766(ra) # 5666 <unlink>
  fd = open("bd", O_CREATE);
     f88:	20000593          	li	a1,512
     f8c:	00005517          	auipc	a0,0x5
     f90:	64450513          	addi	a0,a0,1604 # 65d0 <statistics+0xaa0>
     f94:	00004097          	auipc	ra,0x4
     f98:	6c2080e7          	jalr	1730(ra) # 5656 <open>
  if(fd < 0){
     f9c:	0c054963          	bltz	a0,106e <bigdir+0x10c>
  close(fd);
     fa0:	00004097          	auipc	ra,0x4
     fa4:	69e080e7          	jalr	1694(ra) # 563e <close>
  for(i = 0; i < N; i++){
     fa8:	4901                	li	s2,0
    name[0] = 'x';
     faa:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fae:	00005a17          	auipc	s4,0x5
     fb2:	622a0a13          	addi	s4,s4,1570 # 65d0 <statistics+0xaa0>
  for(i = 0; i < N; i++){
     fb6:	1f400b13          	li	s6,500
    name[0] = 'x';
     fba:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fbe:	41f9579b          	sraiw	a5,s2,0x1f
     fc2:	01a7d71b          	srliw	a4,a5,0x1a
     fc6:	012707bb          	addw	a5,a4,s2
     fca:	4067d69b          	sraiw	a3,a5,0x6
     fce:	0306869b          	addiw	a3,a3,48
     fd2:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fd6:	03f7f793          	andi	a5,a5,63
     fda:	9f99                	subw	a5,a5,a4
     fdc:	0307879b          	addiw	a5,a5,48
     fe0:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     fe4:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     fe8:	fb040593          	addi	a1,s0,-80
     fec:	8552                	mv	a0,s4
     fee:	00004097          	auipc	ra,0x4
     ff2:	688080e7          	jalr	1672(ra) # 5676 <link>
     ff6:	84aa                	mv	s1,a0
     ff8:	e949                	bnez	a0,108a <bigdir+0x128>
  for(i = 0; i < N; i++){
     ffa:	2905                	addiw	s2,s2,1
     ffc:	fb691fe3          	bne	s2,s6,fba <bigdir+0x58>
  unlink("bd");
    1000:	00005517          	auipc	a0,0x5
    1004:	5d050513          	addi	a0,a0,1488 # 65d0 <statistics+0xaa0>
    1008:	00004097          	auipc	ra,0x4
    100c:	65e080e7          	jalr	1630(ra) # 5666 <unlink>
    name[0] = 'x';
    1010:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1014:	1f400a13          	li	s4,500
    name[0] = 'x';
    1018:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    101c:	41f4d79b          	sraiw	a5,s1,0x1f
    1020:	01a7d71b          	srliw	a4,a5,0x1a
    1024:	009707bb          	addw	a5,a4,s1
    1028:	4067d69b          	sraiw	a3,a5,0x6
    102c:	0306869b          	addiw	a3,a3,48
    1030:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1034:	03f7f793          	andi	a5,a5,63
    1038:	9f99                	subw	a5,a5,a4
    103a:	0307879b          	addiw	a5,a5,48
    103e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1042:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1046:	fb040513          	addi	a0,s0,-80
    104a:	00004097          	auipc	ra,0x4
    104e:	61c080e7          	jalr	1564(ra) # 5666 <unlink>
    1052:	ed21                	bnez	a0,10aa <bigdir+0x148>
  for(i = 0; i < N; i++){
    1054:	2485                	addiw	s1,s1,1
    1056:	fd4491e3          	bne	s1,s4,1018 <bigdir+0xb6>
}
    105a:	60a6                	ld	ra,72(sp)
    105c:	6406                	ld	s0,64(sp)
    105e:	74e2                	ld	s1,56(sp)
    1060:	7942                	ld	s2,48(sp)
    1062:	79a2                	ld	s3,40(sp)
    1064:	7a02                	ld	s4,32(sp)
    1066:	6ae2                	ld	s5,24(sp)
    1068:	6b42                	ld	s6,16(sp)
    106a:	6161                	addi	sp,sp,80
    106c:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    106e:	85ce                	mv	a1,s3
    1070:	00005517          	auipc	a0,0x5
    1074:	56850513          	addi	a0,a0,1384 # 65d8 <statistics+0xaa8>
    1078:	00005097          	auipc	ra,0x5
    107c:	916080e7          	jalr	-1770(ra) # 598e <printf>
    exit(1);
    1080:	4505                	li	a0,1
    1082:	00004097          	auipc	ra,0x4
    1086:	594080e7          	jalr	1428(ra) # 5616 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    108a:	fb040613          	addi	a2,s0,-80
    108e:	85ce                	mv	a1,s3
    1090:	00005517          	auipc	a0,0x5
    1094:	56850513          	addi	a0,a0,1384 # 65f8 <statistics+0xac8>
    1098:	00005097          	auipc	ra,0x5
    109c:	8f6080e7          	jalr	-1802(ra) # 598e <printf>
      exit(1);
    10a0:	4505                	li	a0,1
    10a2:	00004097          	auipc	ra,0x4
    10a6:	574080e7          	jalr	1396(ra) # 5616 <exit>
      printf("%s: bigdir unlink failed", s);
    10aa:	85ce                	mv	a1,s3
    10ac:	00005517          	auipc	a0,0x5
    10b0:	56c50513          	addi	a0,a0,1388 # 6618 <statistics+0xae8>
    10b4:	00005097          	auipc	ra,0x5
    10b8:	8da080e7          	jalr	-1830(ra) # 598e <printf>
      exit(1);
    10bc:	4505                	li	a0,1
    10be:	00004097          	auipc	ra,0x4
    10c2:	558080e7          	jalr	1368(ra) # 5616 <exit>

00000000000010c6 <validatetest>:
{
    10c6:	7139                	addi	sp,sp,-64
    10c8:	fc06                	sd	ra,56(sp)
    10ca:	f822                	sd	s0,48(sp)
    10cc:	f426                	sd	s1,40(sp)
    10ce:	f04a                	sd	s2,32(sp)
    10d0:	ec4e                	sd	s3,24(sp)
    10d2:	e852                	sd	s4,16(sp)
    10d4:	e456                	sd	s5,8(sp)
    10d6:	e05a                	sd	s6,0(sp)
    10d8:	0080                	addi	s0,sp,64
    10da:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10dc:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10de:	00005997          	auipc	s3,0x5
    10e2:	55a98993          	addi	s3,s3,1370 # 6638 <statistics+0xb08>
    10e6:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10e8:	6a85                	lui	s5,0x1
    10ea:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    10ee:	85a6                	mv	a1,s1
    10f0:	854e                	mv	a0,s3
    10f2:	00004097          	auipc	ra,0x4
    10f6:	584080e7          	jalr	1412(ra) # 5676 <link>
    10fa:	01251f63          	bne	a0,s2,1118 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fe:	94d6                	add	s1,s1,s5
    1100:	ff4497e3          	bne	s1,s4,10ee <validatetest+0x28>
}
    1104:	70e2                	ld	ra,56(sp)
    1106:	7442                	ld	s0,48(sp)
    1108:	74a2                	ld	s1,40(sp)
    110a:	7902                	ld	s2,32(sp)
    110c:	69e2                	ld	s3,24(sp)
    110e:	6a42                	ld	s4,16(sp)
    1110:	6aa2                	ld	s5,8(sp)
    1112:	6b02                	ld	s6,0(sp)
    1114:	6121                	addi	sp,sp,64
    1116:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1118:	85da                	mv	a1,s6
    111a:	00005517          	auipc	a0,0x5
    111e:	52e50513          	addi	a0,a0,1326 # 6648 <statistics+0xb18>
    1122:	00005097          	auipc	ra,0x5
    1126:	86c080e7          	jalr	-1940(ra) # 598e <printf>
      exit(1);
    112a:	4505                	li	a0,1
    112c:	00004097          	auipc	ra,0x4
    1130:	4ea080e7          	jalr	1258(ra) # 5616 <exit>

0000000000001134 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1134:	7179                	addi	sp,sp,-48
    1136:	f406                	sd	ra,40(sp)
    1138:	f022                	sd	s0,32(sp)
    113a:	ec26                	sd	s1,24(sp)
    113c:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    113e:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1142:	00007497          	auipc	s1,0x7
    1146:	1de4b483          	ld	s1,478(s1) # 8320 <__SDATA_BEGIN__>
    114a:	fd840593          	addi	a1,s0,-40
    114e:	8526                	mv	a0,s1
    1150:	00004097          	auipc	ra,0x4
    1154:	4fe080e7          	jalr	1278(ra) # 564e <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1158:	8526                	mv	a0,s1
    115a:	00004097          	auipc	ra,0x4
    115e:	4cc080e7          	jalr	1228(ra) # 5626 <pipe>

  exit(0);
    1162:	4501                	li	a0,0
    1164:	00004097          	auipc	ra,0x4
    1168:	4b2080e7          	jalr	1202(ra) # 5616 <exit>

000000000000116c <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    116c:	7139                	addi	sp,sp,-64
    116e:	fc06                	sd	ra,56(sp)
    1170:	f822                	sd	s0,48(sp)
    1172:	f426                	sd	s1,40(sp)
    1174:	f04a                	sd	s2,32(sp)
    1176:	ec4e                	sd	s3,24(sp)
    1178:	0080                	addi	s0,sp,64
    117a:	64b1                	lui	s1,0xc
    117c:	35048493          	addi	s1,s1,848 # c350 <buf+0x800>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1180:	597d                	li	s2,-1
    1182:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1186:	00005997          	auipc	s3,0x5
    118a:	d8a98993          	addi	s3,s3,-630 # 5f10 <statistics+0x3e0>
    argv[0] = (char*)0xffffffff;
    118e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1192:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1196:	fc040593          	addi	a1,s0,-64
    119a:	854e                	mv	a0,s3
    119c:	00004097          	auipc	ra,0x4
    11a0:	4b2080e7          	jalr	1202(ra) # 564e <exec>
  for(int i = 0; i < 50000; i++){
    11a4:	34fd                	addiw	s1,s1,-1
    11a6:	f4e5                	bnez	s1,118e <badarg+0x22>
  }
  
  exit(0);
    11a8:	4501                	li	a0,0
    11aa:	00004097          	auipc	ra,0x4
    11ae:	46c080e7          	jalr	1132(ra) # 5616 <exit>

00000000000011b2 <copyinstr2>:
{
    11b2:	7155                	addi	sp,sp,-208
    11b4:	e586                	sd	ra,200(sp)
    11b6:	e1a2                	sd	s0,192(sp)
    11b8:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ba:	f6840793          	addi	a5,s0,-152
    11be:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11c2:	07800713          	li	a4,120
    11c6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11ca:	0785                	addi	a5,a5,1
    11cc:	fed79de3          	bne	a5,a3,11c6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11d0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11d4:	f6840513          	addi	a0,s0,-152
    11d8:	00004097          	auipc	ra,0x4
    11dc:	48e080e7          	jalr	1166(ra) # 5666 <unlink>
  if(ret != -1){
    11e0:	57fd                	li	a5,-1
    11e2:	0ef51063          	bne	a0,a5,12c2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11e6:	20100593          	li	a1,513
    11ea:	f6840513          	addi	a0,s0,-152
    11ee:	00004097          	auipc	ra,0x4
    11f2:	468080e7          	jalr	1128(ra) # 5656 <open>
  if(fd != -1){
    11f6:	57fd                	li	a5,-1
    11f8:	0ef51563          	bne	a0,a5,12e2 <copyinstr2+0x130>
  ret = link(b, b);
    11fc:	f6840593          	addi	a1,s0,-152
    1200:	852e                	mv	a0,a1
    1202:	00004097          	auipc	ra,0x4
    1206:	474080e7          	jalr	1140(ra) # 5676 <link>
  if(ret != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51b63          	bne	a0,a5,1302 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1210:	00006797          	auipc	a5,0x6
    1214:	60878793          	addi	a5,a5,1544 # 7818 <statistics+0x1ce8>
    1218:	f4f43c23          	sd	a5,-168(s0)
    121c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1220:	f5840593          	addi	a1,s0,-168
    1224:	f6840513          	addi	a0,s0,-152
    1228:	00004097          	auipc	ra,0x4
    122c:	426080e7          	jalr	1062(ra) # 564e <exec>
  if(ret != -1){
    1230:	57fd                	li	a5,-1
    1232:	0ef51963          	bne	a0,a5,1324 <copyinstr2+0x172>
  int pid = fork();
    1236:	00004097          	auipc	ra,0x4
    123a:	3d8080e7          	jalr	984(ra) # 560e <fork>
  if(pid < 0){
    123e:	10054363          	bltz	a0,1344 <copyinstr2+0x192>
  if(pid == 0){
    1242:	12051463          	bnez	a0,136a <copyinstr2+0x1b8>
    1246:	00007797          	auipc	a5,0x7
    124a:	1f278793          	addi	a5,a5,498 # 8438 <big.1268>
    124e:	00008697          	auipc	a3,0x8
    1252:	1ea68693          	addi	a3,a3,490 # 9438 <__global_pointer$+0x918>
      big[i] = 'x';
    1256:	07800713          	li	a4,120
    125a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    125e:	0785                	addi	a5,a5,1
    1260:	fed79de3          	bne	a5,a3,125a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1264:	00008797          	auipc	a5,0x8
    1268:	1c078a23          	sb	zero,468(a5) # 9438 <__global_pointer$+0x918>
    char *args2[] = { big, big, big, 0 };
    126c:	00007797          	auipc	a5,0x7
    1270:	c9c78793          	addi	a5,a5,-868 # 7f08 <statistics+0x23d8>
    1274:	6390                	ld	a2,0(a5)
    1276:	6794                	ld	a3,8(a5)
    1278:	6b98                	ld	a4,16(a5)
    127a:	6f9c                	ld	a5,24(a5)
    127c:	f2c43823          	sd	a2,-208(s0)
    1280:	f2d43c23          	sd	a3,-200(s0)
    1284:	f4e43023          	sd	a4,-192(s0)
    1288:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    128c:	f3040593          	addi	a1,s0,-208
    1290:	00005517          	auipc	a0,0x5
    1294:	c8050513          	addi	a0,a0,-896 # 5f10 <statistics+0x3e0>
    1298:	00004097          	auipc	ra,0x4
    129c:	3b6080e7          	jalr	950(ra) # 564e <exec>
    if(ret != -1){
    12a0:	57fd                	li	a5,-1
    12a2:	0af50e63          	beq	a0,a5,135e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12a6:	55fd                	li	a1,-1
    12a8:	00005517          	auipc	a0,0x5
    12ac:	44850513          	addi	a0,a0,1096 # 66f0 <statistics+0xbc0>
    12b0:	00004097          	auipc	ra,0x4
    12b4:	6de080e7          	jalr	1758(ra) # 598e <printf>
      exit(1);
    12b8:	4505                	li	a0,1
    12ba:	00004097          	auipc	ra,0x4
    12be:	35c080e7          	jalr	860(ra) # 5616 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12c2:	862a                	mv	a2,a0
    12c4:	f6840593          	addi	a1,s0,-152
    12c8:	00005517          	auipc	a0,0x5
    12cc:	3a050513          	addi	a0,a0,928 # 6668 <statistics+0xb38>
    12d0:	00004097          	auipc	ra,0x4
    12d4:	6be080e7          	jalr	1726(ra) # 598e <printf>
    exit(1);
    12d8:	4505                	li	a0,1
    12da:	00004097          	auipc	ra,0x4
    12de:	33c080e7          	jalr	828(ra) # 5616 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12e2:	862a                	mv	a2,a0
    12e4:	f6840593          	addi	a1,s0,-152
    12e8:	00005517          	auipc	a0,0x5
    12ec:	3a050513          	addi	a0,a0,928 # 6688 <statistics+0xb58>
    12f0:	00004097          	auipc	ra,0x4
    12f4:	69e080e7          	jalr	1694(ra) # 598e <printf>
    exit(1);
    12f8:	4505                	li	a0,1
    12fa:	00004097          	auipc	ra,0x4
    12fe:	31c080e7          	jalr	796(ra) # 5616 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1302:	86aa                	mv	a3,a0
    1304:	f6840613          	addi	a2,s0,-152
    1308:	85b2                	mv	a1,a2
    130a:	00005517          	auipc	a0,0x5
    130e:	39e50513          	addi	a0,a0,926 # 66a8 <statistics+0xb78>
    1312:	00004097          	auipc	ra,0x4
    1316:	67c080e7          	jalr	1660(ra) # 598e <printf>
    exit(1);
    131a:	4505                	li	a0,1
    131c:	00004097          	auipc	ra,0x4
    1320:	2fa080e7          	jalr	762(ra) # 5616 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1324:	567d                	li	a2,-1
    1326:	f6840593          	addi	a1,s0,-152
    132a:	00005517          	auipc	a0,0x5
    132e:	3a650513          	addi	a0,a0,934 # 66d0 <statistics+0xba0>
    1332:	00004097          	auipc	ra,0x4
    1336:	65c080e7          	jalr	1628(ra) # 598e <printf>
    exit(1);
    133a:	4505                	li	a0,1
    133c:	00004097          	auipc	ra,0x4
    1340:	2da080e7          	jalr	730(ra) # 5616 <exit>
    printf("fork failed\n");
    1344:	00006517          	auipc	a0,0x6
    1348:	80c50513          	addi	a0,a0,-2036 # 6b50 <statistics+0x1020>
    134c:	00004097          	auipc	ra,0x4
    1350:	642080e7          	jalr	1602(ra) # 598e <printf>
    exit(1);
    1354:	4505                	li	a0,1
    1356:	00004097          	auipc	ra,0x4
    135a:	2c0080e7          	jalr	704(ra) # 5616 <exit>
    exit(747); // OK
    135e:	2eb00513          	li	a0,747
    1362:	00004097          	auipc	ra,0x4
    1366:	2b4080e7          	jalr	692(ra) # 5616 <exit>
  int st = 0;
    136a:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    136e:	f5440513          	addi	a0,s0,-172
    1372:	00004097          	auipc	ra,0x4
    1376:	2ac080e7          	jalr	684(ra) # 561e <wait>
  if(st != 747){
    137a:	f5442703          	lw	a4,-172(s0)
    137e:	2eb00793          	li	a5,747
    1382:	00f71663          	bne	a4,a5,138e <copyinstr2+0x1dc>
}
    1386:	60ae                	ld	ra,200(sp)
    1388:	640e                	ld	s0,192(sp)
    138a:	6169                	addi	sp,sp,208
    138c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    138e:	00005517          	auipc	a0,0x5
    1392:	38a50513          	addi	a0,a0,906 # 6718 <statistics+0xbe8>
    1396:	00004097          	auipc	ra,0x4
    139a:	5f8080e7          	jalr	1528(ra) # 598e <printf>
    exit(1);
    139e:	4505                	li	a0,1
    13a0:	00004097          	auipc	ra,0x4
    13a4:	276080e7          	jalr	630(ra) # 5616 <exit>

00000000000013a8 <truncate3>:
{
    13a8:	7159                	addi	sp,sp,-112
    13aa:	f486                	sd	ra,104(sp)
    13ac:	f0a2                	sd	s0,96(sp)
    13ae:	eca6                	sd	s1,88(sp)
    13b0:	e8ca                	sd	s2,80(sp)
    13b2:	e4ce                	sd	s3,72(sp)
    13b4:	e0d2                	sd	s4,64(sp)
    13b6:	fc56                	sd	s5,56(sp)
    13b8:	1880                	addi	s0,sp,112
    13ba:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13bc:	60100593          	li	a1,1537
    13c0:	00005517          	auipc	a0,0x5
    13c4:	ba850513          	addi	a0,a0,-1112 # 5f68 <statistics+0x438>
    13c8:	00004097          	auipc	ra,0x4
    13cc:	28e080e7          	jalr	654(ra) # 5656 <open>
    13d0:	00004097          	auipc	ra,0x4
    13d4:	26e080e7          	jalr	622(ra) # 563e <close>
  pid = fork();
    13d8:	00004097          	auipc	ra,0x4
    13dc:	236080e7          	jalr	566(ra) # 560e <fork>
  if(pid < 0){
    13e0:	08054063          	bltz	a0,1460 <truncate3+0xb8>
  if(pid == 0){
    13e4:	e969                	bnez	a0,14b6 <truncate3+0x10e>
    13e6:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13ea:	00005a17          	auipc	s4,0x5
    13ee:	b7ea0a13          	addi	s4,s4,-1154 # 5f68 <statistics+0x438>
      int n = write(fd, "1234567890", 10);
    13f2:	00005a97          	auipc	s5,0x5
    13f6:	386a8a93          	addi	s5,s5,902 # 6778 <statistics+0xc48>
      int fd = open("truncfile", O_WRONLY);
    13fa:	4585                	li	a1,1
    13fc:	8552                	mv	a0,s4
    13fe:	00004097          	auipc	ra,0x4
    1402:	258080e7          	jalr	600(ra) # 5656 <open>
    1406:	84aa                	mv	s1,a0
      if(fd < 0){
    1408:	06054a63          	bltz	a0,147c <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    140c:	4629                	li	a2,10
    140e:	85d6                	mv	a1,s5
    1410:	00004097          	auipc	ra,0x4
    1414:	226080e7          	jalr	550(ra) # 5636 <write>
      if(n != 10){
    1418:	47a9                	li	a5,10
    141a:	06f51f63          	bne	a0,a5,1498 <truncate3+0xf0>
      close(fd);
    141e:	8526                	mv	a0,s1
    1420:	00004097          	auipc	ra,0x4
    1424:	21e080e7          	jalr	542(ra) # 563e <close>
      fd = open("truncfile", O_RDONLY);
    1428:	4581                	li	a1,0
    142a:	8552                	mv	a0,s4
    142c:	00004097          	auipc	ra,0x4
    1430:	22a080e7          	jalr	554(ra) # 5656 <open>
    1434:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1436:	02000613          	li	a2,32
    143a:	f9840593          	addi	a1,s0,-104
    143e:	00004097          	auipc	ra,0x4
    1442:	1f0080e7          	jalr	496(ra) # 562e <read>
      close(fd);
    1446:	8526                	mv	a0,s1
    1448:	00004097          	auipc	ra,0x4
    144c:	1f6080e7          	jalr	502(ra) # 563e <close>
    for(int i = 0; i < 100; i++){
    1450:	39fd                	addiw	s3,s3,-1
    1452:	fa0994e3          	bnez	s3,13fa <truncate3+0x52>
    exit(0);
    1456:	4501                	li	a0,0
    1458:	00004097          	auipc	ra,0x4
    145c:	1be080e7          	jalr	446(ra) # 5616 <exit>
    printf("%s: fork failed\n", s);
    1460:	85ca                	mv	a1,s2
    1462:	00005517          	auipc	a0,0x5
    1466:	2e650513          	addi	a0,a0,742 # 6748 <statistics+0xc18>
    146a:	00004097          	auipc	ra,0x4
    146e:	524080e7          	jalr	1316(ra) # 598e <printf>
    exit(1);
    1472:	4505                	li	a0,1
    1474:	00004097          	auipc	ra,0x4
    1478:	1a2080e7          	jalr	418(ra) # 5616 <exit>
        printf("%s: open failed\n", s);
    147c:	85ca                	mv	a1,s2
    147e:	00005517          	auipc	a0,0x5
    1482:	2e250513          	addi	a0,a0,738 # 6760 <statistics+0xc30>
    1486:	00004097          	auipc	ra,0x4
    148a:	508080e7          	jalr	1288(ra) # 598e <printf>
        exit(1);
    148e:	4505                	li	a0,1
    1490:	00004097          	auipc	ra,0x4
    1494:	186080e7          	jalr	390(ra) # 5616 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1498:	862a                	mv	a2,a0
    149a:	85ca                	mv	a1,s2
    149c:	00005517          	auipc	a0,0x5
    14a0:	2ec50513          	addi	a0,a0,748 # 6788 <statistics+0xc58>
    14a4:	00004097          	auipc	ra,0x4
    14a8:	4ea080e7          	jalr	1258(ra) # 598e <printf>
        exit(1);
    14ac:	4505                	li	a0,1
    14ae:	00004097          	auipc	ra,0x4
    14b2:	168080e7          	jalr	360(ra) # 5616 <exit>
    14b6:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ba:	00005a17          	auipc	s4,0x5
    14be:	aaea0a13          	addi	s4,s4,-1362 # 5f68 <statistics+0x438>
    int n = write(fd, "xxx", 3);
    14c2:	00005a97          	auipc	s5,0x5
    14c6:	2e6a8a93          	addi	s5,s5,742 # 67a8 <statistics+0xc78>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ca:	60100593          	li	a1,1537
    14ce:	8552                	mv	a0,s4
    14d0:	00004097          	auipc	ra,0x4
    14d4:	186080e7          	jalr	390(ra) # 5656 <open>
    14d8:	84aa                	mv	s1,a0
    if(fd < 0){
    14da:	04054763          	bltz	a0,1528 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14de:	460d                	li	a2,3
    14e0:	85d6                	mv	a1,s5
    14e2:	00004097          	auipc	ra,0x4
    14e6:	154080e7          	jalr	340(ra) # 5636 <write>
    if(n != 3){
    14ea:	478d                	li	a5,3
    14ec:	04f51c63          	bne	a0,a5,1544 <truncate3+0x19c>
    close(fd);
    14f0:	8526                	mv	a0,s1
    14f2:	00004097          	auipc	ra,0x4
    14f6:	14c080e7          	jalr	332(ra) # 563e <close>
  for(int i = 0; i < 150; i++){
    14fa:	39fd                	addiw	s3,s3,-1
    14fc:	fc0997e3          	bnez	s3,14ca <truncate3+0x122>
  wait(&xstatus);
    1500:	fbc40513          	addi	a0,s0,-68
    1504:	00004097          	auipc	ra,0x4
    1508:	11a080e7          	jalr	282(ra) # 561e <wait>
  unlink("truncfile");
    150c:	00005517          	auipc	a0,0x5
    1510:	a5c50513          	addi	a0,a0,-1444 # 5f68 <statistics+0x438>
    1514:	00004097          	auipc	ra,0x4
    1518:	152080e7          	jalr	338(ra) # 5666 <unlink>
  exit(xstatus);
    151c:	fbc42503          	lw	a0,-68(s0)
    1520:	00004097          	auipc	ra,0x4
    1524:	0f6080e7          	jalr	246(ra) # 5616 <exit>
      printf("%s: open failed\n", s);
    1528:	85ca                	mv	a1,s2
    152a:	00005517          	auipc	a0,0x5
    152e:	23650513          	addi	a0,a0,566 # 6760 <statistics+0xc30>
    1532:	00004097          	auipc	ra,0x4
    1536:	45c080e7          	jalr	1116(ra) # 598e <printf>
      exit(1);
    153a:	4505                	li	a0,1
    153c:	00004097          	auipc	ra,0x4
    1540:	0da080e7          	jalr	218(ra) # 5616 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1544:	862a                	mv	a2,a0
    1546:	85ca                	mv	a1,s2
    1548:	00005517          	auipc	a0,0x5
    154c:	26850513          	addi	a0,a0,616 # 67b0 <statistics+0xc80>
    1550:	00004097          	auipc	ra,0x4
    1554:	43e080e7          	jalr	1086(ra) # 598e <printf>
      exit(1);
    1558:	4505                	li	a0,1
    155a:	00004097          	auipc	ra,0x4
    155e:	0bc080e7          	jalr	188(ra) # 5616 <exit>

0000000000001562 <exectest>:
{
    1562:	715d                	addi	sp,sp,-80
    1564:	e486                	sd	ra,72(sp)
    1566:	e0a2                	sd	s0,64(sp)
    1568:	fc26                	sd	s1,56(sp)
    156a:	f84a                	sd	s2,48(sp)
    156c:	0880                	addi	s0,sp,80
    156e:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1570:	00005797          	auipc	a5,0x5
    1574:	9a078793          	addi	a5,a5,-1632 # 5f10 <statistics+0x3e0>
    1578:	fcf43023          	sd	a5,-64(s0)
    157c:	00005797          	auipc	a5,0x5
    1580:	25478793          	addi	a5,a5,596 # 67d0 <statistics+0xca0>
    1584:	fcf43423          	sd	a5,-56(s0)
    1588:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    158c:	00005517          	auipc	a0,0x5
    1590:	24c50513          	addi	a0,a0,588 # 67d8 <statistics+0xca8>
    1594:	00004097          	auipc	ra,0x4
    1598:	0d2080e7          	jalr	210(ra) # 5666 <unlink>
  pid = fork();
    159c:	00004097          	auipc	ra,0x4
    15a0:	072080e7          	jalr	114(ra) # 560e <fork>
  if(pid < 0) {
    15a4:	04054663          	bltz	a0,15f0 <exectest+0x8e>
    15a8:	84aa                	mv	s1,a0
  if(pid == 0) {
    15aa:	e959                	bnez	a0,1640 <exectest+0xde>
    close(1);
    15ac:	4505                	li	a0,1
    15ae:	00004097          	auipc	ra,0x4
    15b2:	090080e7          	jalr	144(ra) # 563e <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15b6:	20100593          	li	a1,513
    15ba:	00005517          	auipc	a0,0x5
    15be:	21e50513          	addi	a0,a0,542 # 67d8 <statistics+0xca8>
    15c2:	00004097          	auipc	ra,0x4
    15c6:	094080e7          	jalr	148(ra) # 5656 <open>
    if(fd < 0) {
    15ca:	04054163          	bltz	a0,160c <exectest+0xaa>
    if(fd != 1) {
    15ce:	4785                	li	a5,1
    15d0:	04f50c63          	beq	a0,a5,1628 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15d4:	85ca                	mv	a1,s2
    15d6:	00005517          	auipc	a0,0x5
    15da:	22250513          	addi	a0,a0,546 # 67f8 <statistics+0xcc8>
    15de:	00004097          	auipc	ra,0x4
    15e2:	3b0080e7          	jalr	944(ra) # 598e <printf>
      exit(1);
    15e6:	4505                	li	a0,1
    15e8:	00004097          	auipc	ra,0x4
    15ec:	02e080e7          	jalr	46(ra) # 5616 <exit>
     printf("%s: fork failed\n", s);
    15f0:	85ca                	mv	a1,s2
    15f2:	00005517          	auipc	a0,0x5
    15f6:	15650513          	addi	a0,a0,342 # 6748 <statistics+0xc18>
    15fa:	00004097          	auipc	ra,0x4
    15fe:	394080e7          	jalr	916(ra) # 598e <printf>
     exit(1);
    1602:	4505                	li	a0,1
    1604:	00004097          	auipc	ra,0x4
    1608:	012080e7          	jalr	18(ra) # 5616 <exit>
      printf("%s: create failed\n", s);
    160c:	85ca                	mv	a1,s2
    160e:	00005517          	auipc	a0,0x5
    1612:	1d250513          	addi	a0,a0,466 # 67e0 <statistics+0xcb0>
    1616:	00004097          	auipc	ra,0x4
    161a:	378080e7          	jalr	888(ra) # 598e <printf>
      exit(1);
    161e:	4505                	li	a0,1
    1620:	00004097          	auipc	ra,0x4
    1624:	ff6080e7          	jalr	-10(ra) # 5616 <exit>
    if(exec("echo", echoargv) < 0){
    1628:	fc040593          	addi	a1,s0,-64
    162c:	00005517          	auipc	a0,0x5
    1630:	8e450513          	addi	a0,a0,-1820 # 5f10 <statistics+0x3e0>
    1634:	00004097          	auipc	ra,0x4
    1638:	01a080e7          	jalr	26(ra) # 564e <exec>
    163c:	02054163          	bltz	a0,165e <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1640:	fdc40513          	addi	a0,s0,-36
    1644:	00004097          	auipc	ra,0x4
    1648:	fda080e7          	jalr	-38(ra) # 561e <wait>
    164c:	02951763          	bne	a0,s1,167a <exectest+0x118>
  if(xstatus != 0)
    1650:	fdc42503          	lw	a0,-36(s0)
    1654:	cd0d                	beqz	a0,168e <exectest+0x12c>
    exit(xstatus);
    1656:	00004097          	auipc	ra,0x4
    165a:	fc0080e7          	jalr	-64(ra) # 5616 <exit>
      printf("%s: exec echo failed\n", s);
    165e:	85ca                	mv	a1,s2
    1660:	00005517          	auipc	a0,0x5
    1664:	1a850513          	addi	a0,a0,424 # 6808 <statistics+0xcd8>
    1668:	00004097          	auipc	ra,0x4
    166c:	326080e7          	jalr	806(ra) # 598e <printf>
      exit(1);
    1670:	4505                	li	a0,1
    1672:	00004097          	auipc	ra,0x4
    1676:	fa4080e7          	jalr	-92(ra) # 5616 <exit>
    printf("%s: wait failed!\n", s);
    167a:	85ca                	mv	a1,s2
    167c:	00005517          	auipc	a0,0x5
    1680:	1a450513          	addi	a0,a0,420 # 6820 <statistics+0xcf0>
    1684:	00004097          	auipc	ra,0x4
    1688:	30a080e7          	jalr	778(ra) # 598e <printf>
    168c:	b7d1                	j	1650 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    168e:	4581                	li	a1,0
    1690:	00005517          	auipc	a0,0x5
    1694:	14850513          	addi	a0,a0,328 # 67d8 <statistics+0xca8>
    1698:	00004097          	auipc	ra,0x4
    169c:	fbe080e7          	jalr	-66(ra) # 5656 <open>
  if(fd < 0) {
    16a0:	02054a63          	bltz	a0,16d4 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16a4:	4609                	li	a2,2
    16a6:	fb840593          	addi	a1,s0,-72
    16aa:	00004097          	auipc	ra,0x4
    16ae:	f84080e7          	jalr	-124(ra) # 562e <read>
    16b2:	4789                	li	a5,2
    16b4:	02f50e63          	beq	a0,a5,16f0 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16b8:	85ca                	mv	a1,s2
    16ba:	00005517          	auipc	a0,0x5
    16be:	be650513          	addi	a0,a0,-1050 # 62a0 <statistics+0x770>
    16c2:	00004097          	auipc	ra,0x4
    16c6:	2cc080e7          	jalr	716(ra) # 598e <printf>
    exit(1);
    16ca:	4505                	li	a0,1
    16cc:	00004097          	auipc	ra,0x4
    16d0:	f4a080e7          	jalr	-182(ra) # 5616 <exit>
    printf("%s: open failed\n", s);
    16d4:	85ca                	mv	a1,s2
    16d6:	00005517          	auipc	a0,0x5
    16da:	08a50513          	addi	a0,a0,138 # 6760 <statistics+0xc30>
    16de:	00004097          	auipc	ra,0x4
    16e2:	2b0080e7          	jalr	688(ra) # 598e <printf>
    exit(1);
    16e6:	4505                	li	a0,1
    16e8:	00004097          	auipc	ra,0x4
    16ec:	f2e080e7          	jalr	-210(ra) # 5616 <exit>
  unlink("echo-ok");
    16f0:	00005517          	auipc	a0,0x5
    16f4:	0e850513          	addi	a0,a0,232 # 67d8 <statistics+0xca8>
    16f8:	00004097          	auipc	ra,0x4
    16fc:	f6e080e7          	jalr	-146(ra) # 5666 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1700:	fb844703          	lbu	a4,-72(s0)
    1704:	04f00793          	li	a5,79
    1708:	00f71863          	bne	a4,a5,1718 <exectest+0x1b6>
    170c:	fb944703          	lbu	a4,-71(s0)
    1710:	04b00793          	li	a5,75
    1714:	02f70063          	beq	a4,a5,1734 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1718:	85ca                	mv	a1,s2
    171a:	00005517          	auipc	a0,0x5
    171e:	11e50513          	addi	a0,a0,286 # 6838 <statistics+0xd08>
    1722:	00004097          	auipc	ra,0x4
    1726:	26c080e7          	jalr	620(ra) # 598e <printf>
    exit(1);
    172a:	4505                	li	a0,1
    172c:	00004097          	auipc	ra,0x4
    1730:	eea080e7          	jalr	-278(ra) # 5616 <exit>
    exit(0);
    1734:	4501                	li	a0,0
    1736:	00004097          	auipc	ra,0x4
    173a:	ee0080e7          	jalr	-288(ra) # 5616 <exit>

000000000000173e <pipe1>:
{
    173e:	711d                	addi	sp,sp,-96
    1740:	ec86                	sd	ra,88(sp)
    1742:	e8a2                	sd	s0,80(sp)
    1744:	e4a6                	sd	s1,72(sp)
    1746:	e0ca                	sd	s2,64(sp)
    1748:	fc4e                	sd	s3,56(sp)
    174a:	f852                	sd	s4,48(sp)
    174c:	f456                	sd	s5,40(sp)
    174e:	f05a                	sd	s6,32(sp)
    1750:	ec5e                	sd	s7,24(sp)
    1752:	1080                	addi	s0,sp,96
    1754:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1756:	fa840513          	addi	a0,s0,-88
    175a:	00004097          	auipc	ra,0x4
    175e:	ecc080e7          	jalr	-308(ra) # 5626 <pipe>
    1762:	ed25                	bnez	a0,17da <pipe1+0x9c>
    1764:	84aa                	mv	s1,a0
  pid = fork();
    1766:	00004097          	auipc	ra,0x4
    176a:	ea8080e7          	jalr	-344(ra) # 560e <fork>
    176e:	8a2a                	mv	s4,a0
  if(pid == 0){
    1770:	c159                	beqz	a0,17f6 <pipe1+0xb8>
  } else if(pid > 0){
    1772:	16a05e63          	blez	a0,18ee <pipe1+0x1b0>
    close(fds[1]);
    1776:	fac42503          	lw	a0,-84(s0)
    177a:	00004097          	auipc	ra,0x4
    177e:	ec4080e7          	jalr	-316(ra) # 563e <close>
    total = 0;
    1782:	8a26                	mv	s4,s1
    cc = 1;
    1784:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1786:	0000aa97          	auipc	s5,0xa
    178a:	3caa8a93          	addi	s5,s5,970 # bb50 <buf>
      if(cc > sizeof(buf))
    178e:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1790:	864e                	mv	a2,s3
    1792:	85d6                	mv	a1,s5
    1794:	fa842503          	lw	a0,-88(s0)
    1798:	00004097          	auipc	ra,0x4
    179c:	e96080e7          	jalr	-362(ra) # 562e <read>
    17a0:	10a05263          	blez	a0,18a4 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17a4:	0000a717          	auipc	a4,0xa
    17a8:	3ac70713          	addi	a4,a4,940 # bb50 <buf>
    17ac:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b0:	00074683          	lbu	a3,0(a4)
    17b4:	0ff4f793          	andi	a5,s1,255
    17b8:	2485                	addiw	s1,s1,1
    17ba:	0cf69163          	bne	a3,a5,187c <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17be:	0705                	addi	a4,a4,1
    17c0:	fec498e3          	bne	s1,a2,17b0 <pipe1+0x72>
      total += n;
    17c4:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17c8:	0019979b          	slliw	a5,s3,0x1
    17cc:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17d0:	013b7363          	bgeu	s6,s3,17d6 <pipe1+0x98>
        cc = sizeof(buf);
    17d4:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17d6:	84b2                	mv	s1,a2
    17d8:	bf65                	j	1790 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17da:	85ca                	mv	a1,s2
    17dc:	00005517          	auipc	a0,0x5
    17e0:	07450513          	addi	a0,a0,116 # 6850 <statistics+0xd20>
    17e4:	00004097          	auipc	ra,0x4
    17e8:	1aa080e7          	jalr	426(ra) # 598e <printf>
    exit(1);
    17ec:	4505                	li	a0,1
    17ee:	00004097          	auipc	ra,0x4
    17f2:	e28080e7          	jalr	-472(ra) # 5616 <exit>
    close(fds[0]);
    17f6:	fa842503          	lw	a0,-88(s0)
    17fa:	00004097          	auipc	ra,0x4
    17fe:	e44080e7          	jalr	-444(ra) # 563e <close>
    for(n = 0; n < N; n++){
    1802:	0000ab17          	auipc	s6,0xa
    1806:	34eb0b13          	addi	s6,s6,846 # bb50 <buf>
    180a:	416004bb          	negw	s1,s6
    180e:	0ff4f493          	andi	s1,s1,255
    1812:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1816:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1818:	6a85                	lui	s5,0x1
    181a:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x85>
{
    181e:	87da                	mv	a5,s6
        buf[i] = seq++;
    1820:	0097873b          	addw	a4,a5,s1
    1824:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1828:	0785                	addi	a5,a5,1
    182a:	fef99be3          	bne	s3,a5,1820 <pipe1+0xe2>
    182e:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1832:	40900613          	li	a2,1033
    1836:	85de                	mv	a1,s7
    1838:	fac42503          	lw	a0,-84(s0)
    183c:	00004097          	auipc	ra,0x4
    1840:	dfa080e7          	jalr	-518(ra) # 5636 <write>
    1844:	40900793          	li	a5,1033
    1848:	00f51c63          	bne	a0,a5,1860 <pipe1+0x122>
    for(n = 0; n < N; n++){
    184c:	24a5                	addiw	s1,s1,9
    184e:	0ff4f493          	andi	s1,s1,255
    1852:	fd5a16e3          	bne	s4,s5,181e <pipe1+0xe0>
    exit(0);
    1856:	4501                	li	a0,0
    1858:	00004097          	auipc	ra,0x4
    185c:	dbe080e7          	jalr	-578(ra) # 5616 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1860:	85ca                	mv	a1,s2
    1862:	00005517          	auipc	a0,0x5
    1866:	00650513          	addi	a0,a0,6 # 6868 <statistics+0xd38>
    186a:	00004097          	auipc	ra,0x4
    186e:	124080e7          	jalr	292(ra) # 598e <printf>
        exit(1);
    1872:	4505                	li	a0,1
    1874:	00004097          	auipc	ra,0x4
    1878:	da2080e7          	jalr	-606(ra) # 5616 <exit>
          printf("%s: pipe1 oops 2\n", s);
    187c:	85ca                	mv	a1,s2
    187e:	00005517          	auipc	a0,0x5
    1882:	00250513          	addi	a0,a0,2 # 6880 <statistics+0xd50>
    1886:	00004097          	auipc	ra,0x4
    188a:	108080e7          	jalr	264(ra) # 598e <printf>
}
    188e:	60e6                	ld	ra,88(sp)
    1890:	6446                	ld	s0,80(sp)
    1892:	64a6                	ld	s1,72(sp)
    1894:	6906                	ld	s2,64(sp)
    1896:	79e2                	ld	s3,56(sp)
    1898:	7a42                	ld	s4,48(sp)
    189a:	7aa2                	ld	s5,40(sp)
    189c:	7b02                	ld	s6,32(sp)
    189e:	6be2                	ld	s7,24(sp)
    18a0:	6125                	addi	sp,sp,96
    18a2:	8082                	ret
    if(total != N * SZ){
    18a4:	6785                	lui	a5,0x1
    18a6:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x85>
    18aa:	02fa0063          	beq	s4,a5,18ca <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18ae:	85d2                	mv	a1,s4
    18b0:	00005517          	auipc	a0,0x5
    18b4:	fe850513          	addi	a0,a0,-24 # 6898 <statistics+0xd68>
    18b8:	00004097          	auipc	ra,0x4
    18bc:	0d6080e7          	jalr	214(ra) # 598e <printf>
      exit(1);
    18c0:	4505                	li	a0,1
    18c2:	00004097          	auipc	ra,0x4
    18c6:	d54080e7          	jalr	-684(ra) # 5616 <exit>
    close(fds[0]);
    18ca:	fa842503          	lw	a0,-88(s0)
    18ce:	00004097          	auipc	ra,0x4
    18d2:	d70080e7          	jalr	-656(ra) # 563e <close>
    wait(&xstatus);
    18d6:	fa440513          	addi	a0,s0,-92
    18da:	00004097          	auipc	ra,0x4
    18de:	d44080e7          	jalr	-700(ra) # 561e <wait>
    exit(xstatus);
    18e2:	fa442503          	lw	a0,-92(s0)
    18e6:	00004097          	auipc	ra,0x4
    18ea:	d30080e7          	jalr	-720(ra) # 5616 <exit>
    printf("%s: fork() failed\n", s);
    18ee:	85ca                	mv	a1,s2
    18f0:	00005517          	auipc	a0,0x5
    18f4:	fc850513          	addi	a0,a0,-56 # 68b8 <statistics+0xd88>
    18f8:	00004097          	auipc	ra,0x4
    18fc:	096080e7          	jalr	150(ra) # 598e <printf>
    exit(1);
    1900:	4505                	li	a0,1
    1902:	00004097          	auipc	ra,0x4
    1906:	d14080e7          	jalr	-748(ra) # 5616 <exit>

000000000000190a <exitwait>:
{
    190a:	7139                	addi	sp,sp,-64
    190c:	fc06                	sd	ra,56(sp)
    190e:	f822                	sd	s0,48(sp)
    1910:	f426                	sd	s1,40(sp)
    1912:	f04a                	sd	s2,32(sp)
    1914:	ec4e                	sd	s3,24(sp)
    1916:	e852                	sd	s4,16(sp)
    1918:	0080                	addi	s0,sp,64
    191a:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    191c:	4901                	li	s2,0
    191e:	06400993          	li	s3,100
    pid = fork();
    1922:	00004097          	auipc	ra,0x4
    1926:	cec080e7          	jalr	-788(ra) # 560e <fork>
    192a:	84aa                	mv	s1,a0
    if(pid < 0){
    192c:	02054a63          	bltz	a0,1960 <exitwait+0x56>
    if(pid){
    1930:	c151                	beqz	a0,19b4 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1932:	fcc40513          	addi	a0,s0,-52
    1936:	00004097          	auipc	ra,0x4
    193a:	ce8080e7          	jalr	-792(ra) # 561e <wait>
    193e:	02951f63          	bne	a0,s1,197c <exitwait+0x72>
      if(i != xstate) {
    1942:	fcc42783          	lw	a5,-52(s0)
    1946:	05279963          	bne	a5,s2,1998 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    194a:	2905                	addiw	s2,s2,1
    194c:	fd391be3          	bne	s2,s3,1922 <exitwait+0x18>
}
    1950:	70e2                	ld	ra,56(sp)
    1952:	7442                	ld	s0,48(sp)
    1954:	74a2                	ld	s1,40(sp)
    1956:	7902                	ld	s2,32(sp)
    1958:	69e2                	ld	s3,24(sp)
    195a:	6a42                	ld	s4,16(sp)
    195c:	6121                	addi	sp,sp,64
    195e:	8082                	ret
      printf("%s: fork failed\n", s);
    1960:	85d2                	mv	a1,s4
    1962:	00005517          	auipc	a0,0x5
    1966:	de650513          	addi	a0,a0,-538 # 6748 <statistics+0xc18>
    196a:	00004097          	auipc	ra,0x4
    196e:	024080e7          	jalr	36(ra) # 598e <printf>
      exit(1);
    1972:	4505                	li	a0,1
    1974:	00004097          	auipc	ra,0x4
    1978:	ca2080e7          	jalr	-862(ra) # 5616 <exit>
        printf("%s: wait wrong pid\n", s);
    197c:	85d2                	mv	a1,s4
    197e:	00005517          	auipc	a0,0x5
    1982:	f5250513          	addi	a0,a0,-174 # 68d0 <statistics+0xda0>
    1986:	00004097          	auipc	ra,0x4
    198a:	008080e7          	jalr	8(ra) # 598e <printf>
        exit(1);
    198e:	4505                	li	a0,1
    1990:	00004097          	auipc	ra,0x4
    1994:	c86080e7          	jalr	-890(ra) # 5616 <exit>
        printf("%s: wait wrong exit status\n", s);
    1998:	85d2                	mv	a1,s4
    199a:	00005517          	auipc	a0,0x5
    199e:	f4e50513          	addi	a0,a0,-178 # 68e8 <statistics+0xdb8>
    19a2:	00004097          	auipc	ra,0x4
    19a6:	fec080e7          	jalr	-20(ra) # 598e <printf>
        exit(1);
    19aa:	4505                	li	a0,1
    19ac:	00004097          	auipc	ra,0x4
    19b0:	c6a080e7          	jalr	-918(ra) # 5616 <exit>
      exit(i);
    19b4:	854a                	mv	a0,s2
    19b6:	00004097          	auipc	ra,0x4
    19ba:	c60080e7          	jalr	-928(ra) # 5616 <exit>

00000000000019be <twochildren>:
{
    19be:	1101                	addi	sp,sp,-32
    19c0:	ec06                	sd	ra,24(sp)
    19c2:	e822                	sd	s0,16(sp)
    19c4:	e426                	sd	s1,8(sp)
    19c6:	e04a                	sd	s2,0(sp)
    19c8:	1000                	addi	s0,sp,32
    19ca:	892a                	mv	s2,a0
    19cc:	3e800493          	li	s1,1000
    int pid1 = fork();
    19d0:	00004097          	auipc	ra,0x4
    19d4:	c3e080e7          	jalr	-962(ra) # 560e <fork>
    if(pid1 < 0){
    19d8:	02054c63          	bltz	a0,1a10 <twochildren+0x52>
    if(pid1 == 0){
    19dc:	c921                	beqz	a0,1a2c <twochildren+0x6e>
      int pid2 = fork();
    19de:	00004097          	auipc	ra,0x4
    19e2:	c30080e7          	jalr	-976(ra) # 560e <fork>
      if(pid2 < 0){
    19e6:	04054763          	bltz	a0,1a34 <twochildren+0x76>
      if(pid2 == 0){
    19ea:	c13d                	beqz	a0,1a50 <twochildren+0x92>
        wait(0);
    19ec:	4501                	li	a0,0
    19ee:	00004097          	auipc	ra,0x4
    19f2:	c30080e7          	jalr	-976(ra) # 561e <wait>
        wait(0);
    19f6:	4501                	li	a0,0
    19f8:	00004097          	auipc	ra,0x4
    19fc:	c26080e7          	jalr	-986(ra) # 561e <wait>
  for(int i = 0; i < 1000; i++){
    1a00:	34fd                	addiw	s1,s1,-1
    1a02:	f4f9                	bnez	s1,19d0 <twochildren+0x12>
}
    1a04:	60e2                	ld	ra,24(sp)
    1a06:	6442                	ld	s0,16(sp)
    1a08:	64a2                	ld	s1,8(sp)
    1a0a:	6902                	ld	s2,0(sp)
    1a0c:	6105                	addi	sp,sp,32
    1a0e:	8082                	ret
      printf("%s: fork failed\n", s);
    1a10:	85ca                	mv	a1,s2
    1a12:	00005517          	auipc	a0,0x5
    1a16:	d3650513          	addi	a0,a0,-714 # 6748 <statistics+0xc18>
    1a1a:	00004097          	auipc	ra,0x4
    1a1e:	f74080e7          	jalr	-140(ra) # 598e <printf>
      exit(1);
    1a22:	4505                	li	a0,1
    1a24:	00004097          	auipc	ra,0x4
    1a28:	bf2080e7          	jalr	-1038(ra) # 5616 <exit>
      exit(0);
    1a2c:	00004097          	auipc	ra,0x4
    1a30:	bea080e7          	jalr	-1046(ra) # 5616 <exit>
        printf("%s: fork failed\n", s);
    1a34:	85ca                	mv	a1,s2
    1a36:	00005517          	auipc	a0,0x5
    1a3a:	d1250513          	addi	a0,a0,-750 # 6748 <statistics+0xc18>
    1a3e:	00004097          	auipc	ra,0x4
    1a42:	f50080e7          	jalr	-176(ra) # 598e <printf>
        exit(1);
    1a46:	4505                	li	a0,1
    1a48:	00004097          	auipc	ra,0x4
    1a4c:	bce080e7          	jalr	-1074(ra) # 5616 <exit>
        exit(0);
    1a50:	00004097          	auipc	ra,0x4
    1a54:	bc6080e7          	jalr	-1082(ra) # 5616 <exit>

0000000000001a58 <forkfork>:
{
    1a58:	7179                	addi	sp,sp,-48
    1a5a:	f406                	sd	ra,40(sp)
    1a5c:	f022                	sd	s0,32(sp)
    1a5e:	ec26                	sd	s1,24(sp)
    1a60:	1800                	addi	s0,sp,48
    1a62:	84aa                	mv	s1,a0
    int pid = fork();
    1a64:	00004097          	auipc	ra,0x4
    1a68:	baa080e7          	jalr	-1110(ra) # 560e <fork>
    if(pid < 0){
    1a6c:	04054163          	bltz	a0,1aae <forkfork+0x56>
    if(pid == 0){
    1a70:	cd29                	beqz	a0,1aca <forkfork+0x72>
    int pid = fork();
    1a72:	00004097          	auipc	ra,0x4
    1a76:	b9c080e7          	jalr	-1124(ra) # 560e <fork>
    if(pid < 0){
    1a7a:	02054a63          	bltz	a0,1aae <forkfork+0x56>
    if(pid == 0){
    1a7e:	c531                	beqz	a0,1aca <forkfork+0x72>
    wait(&xstatus);
    1a80:	fdc40513          	addi	a0,s0,-36
    1a84:	00004097          	auipc	ra,0x4
    1a88:	b9a080e7          	jalr	-1126(ra) # 561e <wait>
    if(xstatus != 0) {
    1a8c:	fdc42783          	lw	a5,-36(s0)
    1a90:	ebbd                	bnez	a5,1b06 <forkfork+0xae>
    wait(&xstatus);
    1a92:	fdc40513          	addi	a0,s0,-36
    1a96:	00004097          	auipc	ra,0x4
    1a9a:	b88080e7          	jalr	-1144(ra) # 561e <wait>
    if(xstatus != 0) {
    1a9e:	fdc42783          	lw	a5,-36(s0)
    1aa2:	e3b5                	bnez	a5,1b06 <forkfork+0xae>
}
    1aa4:	70a2                	ld	ra,40(sp)
    1aa6:	7402                	ld	s0,32(sp)
    1aa8:	64e2                	ld	s1,24(sp)
    1aaa:	6145                	addi	sp,sp,48
    1aac:	8082                	ret
      printf("%s: fork failed", s);
    1aae:	85a6                	mv	a1,s1
    1ab0:	00005517          	auipc	a0,0x5
    1ab4:	e5850513          	addi	a0,a0,-424 # 6908 <statistics+0xdd8>
    1ab8:	00004097          	auipc	ra,0x4
    1abc:	ed6080e7          	jalr	-298(ra) # 598e <printf>
      exit(1);
    1ac0:	4505                	li	a0,1
    1ac2:	00004097          	auipc	ra,0x4
    1ac6:	b54080e7          	jalr	-1196(ra) # 5616 <exit>
{
    1aca:	0c800493          	li	s1,200
        int pid1 = fork();
    1ace:	00004097          	auipc	ra,0x4
    1ad2:	b40080e7          	jalr	-1216(ra) # 560e <fork>
        if(pid1 < 0){
    1ad6:	00054f63          	bltz	a0,1af4 <forkfork+0x9c>
        if(pid1 == 0){
    1ada:	c115                	beqz	a0,1afe <forkfork+0xa6>
        wait(0);
    1adc:	4501                	li	a0,0
    1ade:	00004097          	auipc	ra,0x4
    1ae2:	b40080e7          	jalr	-1216(ra) # 561e <wait>
      for(int j = 0; j < 200; j++){
    1ae6:	34fd                	addiw	s1,s1,-1
    1ae8:	f0fd                	bnez	s1,1ace <forkfork+0x76>
      exit(0);
    1aea:	4501                	li	a0,0
    1aec:	00004097          	auipc	ra,0x4
    1af0:	b2a080e7          	jalr	-1238(ra) # 5616 <exit>
          exit(1);
    1af4:	4505                	li	a0,1
    1af6:	00004097          	auipc	ra,0x4
    1afa:	b20080e7          	jalr	-1248(ra) # 5616 <exit>
          exit(0);
    1afe:	00004097          	auipc	ra,0x4
    1b02:	b18080e7          	jalr	-1256(ra) # 5616 <exit>
      printf("%s: fork in child failed", s);
    1b06:	85a6                	mv	a1,s1
    1b08:	00005517          	auipc	a0,0x5
    1b0c:	e1050513          	addi	a0,a0,-496 # 6918 <statistics+0xde8>
    1b10:	00004097          	auipc	ra,0x4
    1b14:	e7e080e7          	jalr	-386(ra) # 598e <printf>
      exit(1);
    1b18:	4505                	li	a0,1
    1b1a:	00004097          	auipc	ra,0x4
    1b1e:	afc080e7          	jalr	-1284(ra) # 5616 <exit>

0000000000001b22 <reparent2>:
{
    1b22:	1101                	addi	sp,sp,-32
    1b24:	ec06                	sd	ra,24(sp)
    1b26:	e822                	sd	s0,16(sp)
    1b28:	e426                	sd	s1,8(sp)
    1b2a:	1000                	addi	s0,sp,32
    1b2c:	32000493          	li	s1,800
    int pid1 = fork();
    1b30:	00004097          	auipc	ra,0x4
    1b34:	ade080e7          	jalr	-1314(ra) # 560e <fork>
    if(pid1 < 0){
    1b38:	00054f63          	bltz	a0,1b56 <reparent2+0x34>
    if(pid1 == 0){
    1b3c:	c915                	beqz	a0,1b70 <reparent2+0x4e>
    wait(0);
    1b3e:	4501                	li	a0,0
    1b40:	00004097          	auipc	ra,0x4
    1b44:	ade080e7          	jalr	-1314(ra) # 561e <wait>
  for(int i = 0; i < 800; i++){
    1b48:	34fd                	addiw	s1,s1,-1
    1b4a:	f0fd                	bnez	s1,1b30 <reparent2+0xe>
  exit(0);
    1b4c:	4501                	li	a0,0
    1b4e:	00004097          	auipc	ra,0x4
    1b52:	ac8080e7          	jalr	-1336(ra) # 5616 <exit>
      printf("fork failed\n");
    1b56:	00005517          	auipc	a0,0x5
    1b5a:	ffa50513          	addi	a0,a0,-6 # 6b50 <statistics+0x1020>
    1b5e:	00004097          	auipc	ra,0x4
    1b62:	e30080e7          	jalr	-464(ra) # 598e <printf>
      exit(1);
    1b66:	4505                	li	a0,1
    1b68:	00004097          	auipc	ra,0x4
    1b6c:	aae080e7          	jalr	-1362(ra) # 5616 <exit>
      fork();
    1b70:	00004097          	auipc	ra,0x4
    1b74:	a9e080e7          	jalr	-1378(ra) # 560e <fork>
      fork();
    1b78:	00004097          	auipc	ra,0x4
    1b7c:	a96080e7          	jalr	-1386(ra) # 560e <fork>
      exit(0);
    1b80:	4501                	li	a0,0
    1b82:	00004097          	auipc	ra,0x4
    1b86:	a94080e7          	jalr	-1388(ra) # 5616 <exit>

0000000000001b8a <createdelete>:
{
    1b8a:	7175                	addi	sp,sp,-144
    1b8c:	e506                	sd	ra,136(sp)
    1b8e:	e122                	sd	s0,128(sp)
    1b90:	fca6                	sd	s1,120(sp)
    1b92:	f8ca                	sd	s2,112(sp)
    1b94:	f4ce                	sd	s3,104(sp)
    1b96:	f0d2                	sd	s4,96(sp)
    1b98:	ecd6                	sd	s5,88(sp)
    1b9a:	e8da                	sd	s6,80(sp)
    1b9c:	e4de                	sd	s7,72(sp)
    1b9e:	e0e2                	sd	s8,64(sp)
    1ba0:	fc66                	sd	s9,56(sp)
    1ba2:	0900                	addi	s0,sp,144
    1ba4:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1ba6:	4901                	li	s2,0
    1ba8:	4991                	li	s3,4
    pid = fork();
    1baa:	00004097          	auipc	ra,0x4
    1bae:	a64080e7          	jalr	-1436(ra) # 560e <fork>
    1bb2:	84aa                	mv	s1,a0
    if(pid < 0){
    1bb4:	02054f63          	bltz	a0,1bf2 <createdelete+0x68>
    if(pid == 0){
    1bb8:	c939                	beqz	a0,1c0e <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bba:	2905                	addiw	s2,s2,1
    1bbc:	ff3917e3          	bne	s2,s3,1baa <createdelete+0x20>
    1bc0:	4491                	li	s1,4
    wait(&xstatus);
    1bc2:	f7c40513          	addi	a0,s0,-132
    1bc6:	00004097          	auipc	ra,0x4
    1bca:	a58080e7          	jalr	-1448(ra) # 561e <wait>
    if(xstatus != 0)
    1bce:	f7c42903          	lw	s2,-132(s0)
    1bd2:	0e091263          	bnez	s2,1cb6 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bd6:	34fd                	addiw	s1,s1,-1
    1bd8:	f4ed                	bnez	s1,1bc2 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bda:	f8040123          	sb	zero,-126(s0)
    1bde:	03000993          	li	s3,48
    1be2:	5a7d                	li	s4,-1
    1be4:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1be8:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bea:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1bec:	07400a93          	li	s5,116
    1bf0:	a29d                	j	1d56 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1bf2:	85e6                	mv	a1,s9
    1bf4:	00005517          	auipc	a0,0x5
    1bf8:	f5c50513          	addi	a0,a0,-164 # 6b50 <statistics+0x1020>
    1bfc:	00004097          	auipc	ra,0x4
    1c00:	d92080e7          	jalr	-622(ra) # 598e <printf>
      exit(1);
    1c04:	4505                	li	a0,1
    1c06:	00004097          	auipc	ra,0x4
    1c0a:	a10080e7          	jalr	-1520(ra) # 5616 <exit>
      name[0] = 'p' + pi;
    1c0e:	0709091b          	addiw	s2,s2,112
    1c12:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c16:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c1a:	4951                	li	s2,20
    1c1c:	a015                	j	1c40 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c1e:	85e6                	mv	a1,s9
    1c20:	00005517          	auipc	a0,0x5
    1c24:	bc050513          	addi	a0,a0,-1088 # 67e0 <statistics+0xcb0>
    1c28:	00004097          	auipc	ra,0x4
    1c2c:	d66080e7          	jalr	-666(ra) # 598e <printf>
          exit(1);
    1c30:	4505                	li	a0,1
    1c32:	00004097          	auipc	ra,0x4
    1c36:	9e4080e7          	jalr	-1564(ra) # 5616 <exit>
      for(i = 0; i < N; i++){
    1c3a:	2485                	addiw	s1,s1,1
    1c3c:	07248863          	beq	s1,s2,1cac <createdelete+0x122>
        name[1] = '0' + i;
    1c40:	0304879b          	addiw	a5,s1,48
    1c44:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c48:	20200593          	li	a1,514
    1c4c:	f8040513          	addi	a0,s0,-128
    1c50:	00004097          	auipc	ra,0x4
    1c54:	a06080e7          	jalr	-1530(ra) # 5656 <open>
        if(fd < 0){
    1c58:	fc0543e3          	bltz	a0,1c1e <createdelete+0x94>
        close(fd);
    1c5c:	00004097          	auipc	ra,0x4
    1c60:	9e2080e7          	jalr	-1566(ra) # 563e <close>
        if(i > 0 && (i % 2 ) == 0){
    1c64:	fc905be3          	blez	s1,1c3a <createdelete+0xb0>
    1c68:	0014f793          	andi	a5,s1,1
    1c6c:	f7f9                	bnez	a5,1c3a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c6e:	01f4d79b          	srliw	a5,s1,0x1f
    1c72:	9fa5                	addw	a5,a5,s1
    1c74:	4017d79b          	sraiw	a5,a5,0x1
    1c78:	0307879b          	addiw	a5,a5,48
    1c7c:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c80:	f8040513          	addi	a0,s0,-128
    1c84:	00004097          	auipc	ra,0x4
    1c88:	9e2080e7          	jalr	-1566(ra) # 5666 <unlink>
    1c8c:	fa0557e3          	bgez	a0,1c3a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1c90:	85e6                	mv	a1,s9
    1c92:	00005517          	auipc	a0,0x5
    1c96:	ca650513          	addi	a0,a0,-858 # 6938 <statistics+0xe08>
    1c9a:	00004097          	auipc	ra,0x4
    1c9e:	cf4080e7          	jalr	-780(ra) # 598e <printf>
            exit(1);
    1ca2:	4505                	li	a0,1
    1ca4:	00004097          	auipc	ra,0x4
    1ca8:	972080e7          	jalr	-1678(ra) # 5616 <exit>
      exit(0);
    1cac:	4501                	li	a0,0
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	968080e7          	jalr	-1688(ra) # 5616 <exit>
      exit(1);
    1cb6:	4505                	li	a0,1
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	95e080e7          	jalr	-1698(ra) # 5616 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cc0:	f8040613          	addi	a2,s0,-128
    1cc4:	85e6                	mv	a1,s9
    1cc6:	00005517          	auipc	a0,0x5
    1cca:	c8a50513          	addi	a0,a0,-886 # 6950 <statistics+0xe20>
    1cce:	00004097          	auipc	ra,0x4
    1cd2:	cc0080e7          	jalr	-832(ra) # 598e <printf>
        exit(1);
    1cd6:	4505                	li	a0,1
    1cd8:	00004097          	auipc	ra,0x4
    1cdc:	93e080e7          	jalr	-1730(ra) # 5616 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ce0:	054b7163          	bgeu	s6,s4,1d22 <createdelete+0x198>
      if(fd >= 0)
    1ce4:	02055a63          	bgez	a0,1d18 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1ce8:	2485                	addiw	s1,s1,1
    1cea:	0ff4f493          	andi	s1,s1,255
    1cee:	05548c63          	beq	s1,s5,1d46 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1cf2:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1cf6:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1cfa:	4581                	li	a1,0
    1cfc:	f8040513          	addi	a0,s0,-128
    1d00:	00004097          	auipc	ra,0x4
    1d04:	956080e7          	jalr	-1706(ra) # 5656 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d08:	00090463          	beqz	s2,1d10 <createdelete+0x186>
    1d0c:	fd2bdae3          	bge	s7,s2,1ce0 <createdelete+0x156>
    1d10:	fa0548e3          	bltz	a0,1cc0 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d14:	014b7963          	bgeu	s6,s4,1d26 <createdelete+0x19c>
        close(fd);
    1d18:	00004097          	auipc	ra,0x4
    1d1c:	926080e7          	jalr	-1754(ra) # 563e <close>
    1d20:	b7e1                	j	1ce8 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d22:	fc0543e3          	bltz	a0,1ce8 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d26:	f8040613          	addi	a2,s0,-128
    1d2a:	85e6                	mv	a1,s9
    1d2c:	00005517          	auipc	a0,0x5
    1d30:	c4c50513          	addi	a0,a0,-948 # 6978 <statistics+0xe48>
    1d34:	00004097          	auipc	ra,0x4
    1d38:	c5a080e7          	jalr	-934(ra) # 598e <printf>
        exit(1);
    1d3c:	4505                	li	a0,1
    1d3e:	00004097          	auipc	ra,0x4
    1d42:	8d8080e7          	jalr	-1832(ra) # 5616 <exit>
  for(i = 0; i < N; i++){
    1d46:	2905                	addiw	s2,s2,1
    1d48:	2a05                	addiw	s4,s4,1
    1d4a:	2985                	addiw	s3,s3,1
    1d4c:	0ff9f993          	andi	s3,s3,255
    1d50:	47d1                	li	a5,20
    1d52:	02f90a63          	beq	s2,a5,1d86 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d56:	84e2                	mv	s1,s8
    1d58:	bf69                	j	1cf2 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d5a:	2905                	addiw	s2,s2,1
    1d5c:	0ff97913          	andi	s2,s2,255
    1d60:	2985                	addiw	s3,s3,1
    1d62:	0ff9f993          	andi	s3,s3,255
    1d66:	03490863          	beq	s2,s4,1d96 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d6a:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d6c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d70:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d74:	f8040513          	addi	a0,s0,-128
    1d78:	00004097          	auipc	ra,0x4
    1d7c:	8ee080e7          	jalr	-1810(ra) # 5666 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d80:	34fd                	addiw	s1,s1,-1
    1d82:	f4ed                	bnez	s1,1d6c <createdelete+0x1e2>
    1d84:	bfd9                	j	1d5a <createdelete+0x1d0>
    1d86:	03000993          	li	s3,48
    1d8a:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1d8e:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1d90:	08400a13          	li	s4,132
    1d94:	bfd9                	j	1d6a <createdelete+0x1e0>
}
    1d96:	60aa                	ld	ra,136(sp)
    1d98:	640a                	ld	s0,128(sp)
    1d9a:	74e6                	ld	s1,120(sp)
    1d9c:	7946                	ld	s2,112(sp)
    1d9e:	79a6                	ld	s3,104(sp)
    1da0:	7a06                	ld	s4,96(sp)
    1da2:	6ae6                	ld	s5,88(sp)
    1da4:	6b46                	ld	s6,80(sp)
    1da6:	6ba6                	ld	s7,72(sp)
    1da8:	6c06                	ld	s8,64(sp)
    1daa:	7ce2                	ld	s9,56(sp)
    1dac:	6149                	addi	sp,sp,144
    1dae:	8082                	ret

0000000000001db0 <linkunlink>:
{
    1db0:	711d                	addi	sp,sp,-96
    1db2:	ec86                	sd	ra,88(sp)
    1db4:	e8a2                	sd	s0,80(sp)
    1db6:	e4a6                	sd	s1,72(sp)
    1db8:	e0ca                	sd	s2,64(sp)
    1dba:	fc4e                	sd	s3,56(sp)
    1dbc:	f852                	sd	s4,48(sp)
    1dbe:	f456                	sd	s5,40(sp)
    1dc0:	f05a                	sd	s6,32(sp)
    1dc2:	ec5e                	sd	s7,24(sp)
    1dc4:	e862                	sd	s8,16(sp)
    1dc6:	e466                	sd	s9,8(sp)
    1dc8:	1080                	addi	s0,sp,96
    1dca:	84aa                	mv	s1,a0
  unlink("x");
    1dcc:	00004517          	auipc	a0,0x4
    1dd0:	1b450513          	addi	a0,a0,436 # 5f80 <statistics+0x450>
    1dd4:	00004097          	auipc	ra,0x4
    1dd8:	892080e7          	jalr	-1902(ra) # 5666 <unlink>
  pid = fork();
    1ddc:	00004097          	auipc	ra,0x4
    1de0:	832080e7          	jalr	-1998(ra) # 560e <fork>
  if(pid < 0){
    1de4:	02054b63          	bltz	a0,1e1a <linkunlink+0x6a>
    1de8:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dea:	4c85                	li	s9,1
    1dec:	e119                	bnez	a0,1df2 <linkunlink+0x42>
    1dee:	06100c93          	li	s9,97
    1df2:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1df6:	41c659b7          	lui	s3,0x41c65
    1dfa:	e6d9899b          	addiw	s3,s3,-403
    1dfe:	690d                	lui	s2,0x3
    1e00:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e04:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e06:	4b05                	li	s6,1
      unlink("x");
    1e08:	00004a97          	auipc	s5,0x4
    1e0c:	178a8a93          	addi	s5,s5,376 # 5f80 <statistics+0x450>
      link("cat", "x");
    1e10:	00005b97          	auipc	s7,0x5
    1e14:	b90b8b93          	addi	s7,s7,-1136 # 69a0 <statistics+0xe70>
    1e18:	a091                	j	1e5c <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e1a:	85a6                	mv	a1,s1
    1e1c:	00005517          	auipc	a0,0x5
    1e20:	92c50513          	addi	a0,a0,-1748 # 6748 <statistics+0xc18>
    1e24:	00004097          	auipc	ra,0x4
    1e28:	b6a080e7          	jalr	-1174(ra) # 598e <printf>
    exit(1);
    1e2c:	4505                	li	a0,1
    1e2e:	00003097          	auipc	ra,0x3
    1e32:	7e8080e7          	jalr	2024(ra) # 5616 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e36:	20200593          	li	a1,514
    1e3a:	8556                	mv	a0,s5
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	81a080e7          	jalr	-2022(ra) # 5656 <open>
    1e44:	00003097          	auipc	ra,0x3
    1e48:	7fa080e7          	jalr	2042(ra) # 563e <close>
    1e4c:	a031                	j	1e58 <linkunlink+0xa8>
      unlink("x");
    1e4e:	8556                	mv	a0,s5
    1e50:	00004097          	auipc	ra,0x4
    1e54:	816080e7          	jalr	-2026(ra) # 5666 <unlink>
  for(i = 0; i < 100; i++){
    1e58:	34fd                	addiw	s1,s1,-1
    1e5a:	c09d                	beqz	s1,1e80 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e5c:	033c87bb          	mulw	a5,s9,s3
    1e60:	012787bb          	addw	a5,a5,s2
    1e64:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e68:	0347f7bb          	remuw	a5,a5,s4
    1e6c:	d7e9                	beqz	a5,1e36 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e6e:	ff6790e3          	bne	a5,s6,1e4e <linkunlink+0x9e>
      link("cat", "x");
    1e72:	85d6                	mv	a1,s5
    1e74:	855e                	mv	a0,s7
    1e76:	00004097          	auipc	ra,0x4
    1e7a:	800080e7          	jalr	-2048(ra) # 5676 <link>
    1e7e:	bfe9                	j	1e58 <linkunlink+0xa8>
  if(pid)
    1e80:	020c0463          	beqz	s8,1ea8 <linkunlink+0xf8>
    wait(0);
    1e84:	4501                	li	a0,0
    1e86:	00003097          	auipc	ra,0x3
    1e8a:	798080e7          	jalr	1944(ra) # 561e <wait>
}
    1e8e:	60e6                	ld	ra,88(sp)
    1e90:	6446                	ld	s0,80(sp)
    1e92:	64a6                	ld	s1,72(sp)
    1e94:	6906                	ld	s2,64(sp)
    1e96:	79e2                	ld	s3,56(sp)
    1e98:	7a42                	ld	s4,48(sp)
    1e9a:	7aa2                	ld	s5,40(sp)
    1e9c:	7b02                	ld	s6,32(sp)
    1e9e:	6be2                	ld	s7,24(sp)
    1ea0:	6c42                	ld	s8,16(sp)
    1ea2:	6ca2                	ld	s9,8(sp)
    1ea4:	6125                	addi	sp,sp,96
    1ea6:	8082                	ret
    exit(0);
    1ea8:	4501                	li	a0,0
    1eaa:	00003097          	auipc	ra,0x3
    1eae:	76c080e7          	jalr	1900(ra) # 5616 <exit>

0000000000001eb2 <manywrites>:
{
    1eb2:	711d                	addi	sp,sp,-96
    1eb4:	ec86                	sd	ra,88(sp)
    1eb6:	e8a2                	sd	s0,80(sp)
    1eb8:	e4a6                	sd	s1,72(sp)
    1eba:	e0ca                	sd	s2,64(sp)
    1ebc:	fc4e                	sd	s3,56(sp)
    1ebe:	f852                	sd	s4,48(sp)
    1ec0:	f456                	sd	s5,40(sp)
    1ec2:	f05a                	sd	s6,32(sp)
    1ec4:	ec5e                	sd	s7,24(sp)
    1ec6:	1080                	addi	s0,sp,96
    1ec8:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1eca:	4901                	li	s2,0
    1ecc:	4991                	li	s3,4
    int pid = fork();
    1ece:	00003097          	auipc	ra,0x3
    1ed2:	740080e7          	jalr	1856(ra) # 560e <fork>
    1ed6:	84aa                	mv	s1,a0
    if(pid < 0){
    1ed8:	02054963          	bltz	a0,1f0a <manywrites+0x58>
    if(pid == 0){
    1edc:	c521                	beqz	a0,1f24 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    1ede:	2905                	addiw	s2,s2,1
    1ee0:	ff3917e3          	bne	s2,s3,1ece <manywrites+0x1c>
    1ee4:	4491                	li	s1,4
    int st = 0;
    1ee6:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1eea:	fa840513          	addi	a0,s0,-88
    1eee:	00003097          	auipc	ra,0x3
    1ef2:	730080e7          	jalr	1840(ra) # 561e <wait>
    if(st != 0)
    1ef6:	fa842503          	lw	a0,-88(s0)
    1efa:	ed6d                	bnez	a0,1ff4 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    1efc:	34fd                	addiw	s1,s1,-1
    1efe:	f4e5                	bnez	s1,1ee6 <manywrites+0x34>
  exit(0);
    1f00:	4501                	li	a0,0
    1f02:	00003097          	auipc	ra,0x3
    1f06:	714080e7          	jalr	1812(ra) # 5616 <exit>
      printf("fork failed\n");
    1f0a:	00005517          	auipc	a0,0x5
    1f0e:	c4650513          	addi	a0,a0,-954 # 6b50 <statistics+0x1020>
    1f12:	00004097          	auipc	ra,0x4
    1f16:	a7c080e7          	jalr	-1412(ra) # 598e <printf>
      exit(1);
    1f1a:	4505                	li	a0,1
    1f1c:	00003097          	auipc	ra,0x3
    1f20:	6fa080e7          	jalr	1786(ra) # 5616 <exit>
      name[0] = 'b';
    1f24:	06200793          	li	a5,98
    1f28:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1f2c:	0619079b          	addiw	a5,s2,97
    1f30:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1f34:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1f38:	fa840513          	addi	a0,s0,-88
    1f3c:	00003097          	auipc	ra,0x3
    1f40:	72a080e7          	jalr	1834(ra) # 5666 <unlink>
    1f44:	4b79                	li	s6,30
          int cc = write(fd, buf, sz);
    1f46:	0000ab97          	auipc	s7,0xa
    1f4a:	c0ab8b93          	addi	s7,s7,-1014 # bb50 <buf>
        for(int i = 0; i < ci+1; i++){
    1f4e:	8a26                	mv	s4,s1
    1f50:	02094e63          	bltz	s2,1f8c <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    1f54:	20200593          	li	a1,514
    1f58:	fa840513          	addi	a0,s0,-88
    1f5c:	00003097          	auipc	ra,0x3
    1f60:	6fa080e7          	jalr	1786(ra) # 5656 <open>
    1f64:	89aa                	mv	s3,a0
          if(fd < 0){
    1f66:	04054763          	bltz	a0,1fb4 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    1f6a:	660d                	lui	a2,0x3
    1f6c:	85de                	mv	a1,s7
    1f6e:	00003097          	auipc	ra,0x3
    1f72:	6c8080e7          	jalr	1736(ra) # 5636 <write>
          if(cc != sz){
    1f76:	678d                	lui	a5,0x3
    1f78:	04f51e63          	bne	a0,a5,1fd4 <manywrites+0x122>
          close(fd);
    1f7c:	854e                	mv	a0,s3
    1f7e:	00003097          	auipc	ra,0x3
    1f82:	6c0080e7          	jalr	1728(ra) # 563e <close>
        for(int i = 0; i < ci+1; i++){
    1f86:	2a05                	addiw	s4,s4,1
    1f88:	fd4956e3          	bge	s2,s4,1f54 <manywrites+0xa2>
        unlink(name);
    1f8c:	fa840513          	addi	a0,s0,-88
    1f90:	00003097          	auipc	ra,0x3
    1f94:	6d6080e7          	jalr	1750(ra) # 5666 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1f98:	3b7d                	addiw	s6,s6,-1
    1f9a:	fa0b1ae3          	bnez	s6,1f4e <manywrites+0x9c>
      unlink(name);
    1f9e:	fa840513          	addi	a0,s0,-88
    1fa2:	00003097          	auipc	ra,0x3
    1fa6:	6c4080e7          	jalr	1732(ra) # 5666 <unlink>
      exit(0);
    1faa:	4501                	li	a0,0
    1fac:	00003097          	auipc	ra,0x3
    1fb0:	66a080e7          	jalr	1642(ra) # 5616 <exit>
            printf("%s: cannot create %s\n", s, name);
    1fb4:	fa840613          	addi	a2,s0,-88
    1fb8:	85d6                	mv	a1,s5
    1fba:	00005517          	auipc	a0,0x5
    1fbe:	9ee50513          	addi	a0,a0,-1554 # 69a8 <statistics+0xe78>
    1fc2:	00004097          	auipc	ra,0x4
    1fc6:	9cc080e7          	jalr	-1588(ra) # 598e <printf>
            exit(1);
    1fca:	4505                	li	a0,1
    1fcc:	00003097          	auipc	ra,0x3
    1fd0:	64a080e7          	jalr	1610(ra) # 5616 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1fd4:	86aa                	mv	a3,a0
    1fd6:	660d                	lui	a2,0x3
    1fd8:	85d6                	mv	a1,s5
    1fda:	00004517          	auipc	a0,0x4
    1fde:	ff650513          	addi	a0,a0,-10 # 5fd0 <statistics+0x4a0>
    1fe2:	00004097          	auipc	ra,0x4
    1fe6:	9ac080e7          	jalr	-1620(ra) # 598e <printf>
            exit(1);
    1fea:	4505                	li	a0,1
    1fec:	00003097          	auipc	ra,0x3
    1ff0:	62a080e7          	jalr	1578(ra) # 5616 <exit>
      exit(st);
    1ff4:	00003097          	auipc	ra,0x3
    1ff8:	622080e7          	jalr	1570(ra) # 5616 <exit>

0000000000001ffc <forktest>:
{
    1ffc:	7179                	addi	sp,sp,-48
    1ffe:	f406                	sd	ra,40(sp)
    2000:	f022                	sd	s0,32(sp)
    2002:	ec26                	sd	s1,24(sp)
    2004:	e84a                	sd	s2,16(sp)
    2006:	e44e                	sd	s3,8(sp)
    2008:	1800                	addi	s0,sp,48
    200a:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    200c:	4481                	li	s1,0
    200e:	3e800913          	li	s2,1000
    pid = fork();
    2012:	00003097          	auipc	ra,0x3
    2016:	5fc080e7          	jalr	1532(ra) # 560e <fork>
    if(pid < 0)
    201a:	02054863          	bltz	a0,204a <forktest+0x4e>
    if(pid == 0)
    201e:	c115                	beqz	a0,2042 <forktest+0x46>
  for(n=0; n<N; n++){
    2020:	2485                	addiw	s1,s1,1
    2022:	ff2498e3          	bne	s1,s2,2012 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    2026:	85ce                	mv	a1,s3
    2028:	00005517          	auipc	a0,0x5
    202c:	9b050513          	addi	a0,a0,-1616 # 69d8 <statistics+0xea8>
    2030:	00004097          	auipc	ra,0x4
    2034:	95e080e7          	jalr	-1698(ra) # 598e <printf>
    exit(1);
    2038:	4505                	li	a0,1
    203a:	00003097          	auipc	ra,0x3
    203e:	5dc080e7          	jalr	1500(ra) # 5616 <exit>
      exit(0);
    2042:	00003097          	auipc	ra,0x3
    2046:	5d4080e7          	jalr	1492(ra) # 5616 <exit>
  if (n == 0) {
    204a:	cc9d                	beqz	s1,2088 <forktest+0x8c>
  if(n == N){
    204c:	3e800793          	li	a5,1000
    2050:	fcf48be3          	beq	s1,a5,2026 <forktest+0x2a>
  for(; n > 0; n--){
    2054:	00905b63          	blez	s1,206a <forktest+0x6e>
    if(wait(0) < 0){
    2058:	4501                	li	a0,0
    205a:	00003097          	auipc	ra,0x3
    205e:	5c4080e7          	jalr	1476(ra) # 561e <wait>
    2062:	04054163          	bltz	a0,20a4 <forktest+0xa8>
  for(; n > 0; n--){
    2066:	34fd                	addiw	s1,s1,-1
    2068:	f8e5                	bnez	s1,2058 <forktest+0x5c>
  if(wait(0) != -1){
    206a:	4501                	li	a0,0
    206c:	00003097          	auipc	ra,0x3
    2070:	5b2080e7          	jalr	1458(ra) # 561e <wait>
    2074:	57fd                	li	a5,-1
    2076:	04f51563          	bne	a0,a5,20c0 <forktest+0xc4>
}
    207a:	70a2                	ld	ra,40(sp)
    207c:	7402                	ld	s0,32(sp)
    207e:	64e2                	ld	s1,24(sp)
    2080:	6942                	ld	s2,16(sp)
    2082:	69a2                	ld	s3,8(sp)
    2084:	6145                	addi	sp,sp,48
    2086:	8082                	ret
    printf("%s: no fork at all!\n", s);
    2088:	85ce                	mv	a1,s3
    208a:	00005517          	auipc	a0,0x5
    208e:	93650513          	addi	a0,a0,-1738 # 69c0 <statistics+0xe90>
    2092:	00004097          	auipc	ra,0x4
    2096:	8fc080e7          	jalr	-1796(ra) # 598e <printf>
    exit(1);
    209a:	4505                	li	a0,1
    209c:	00003097          	auipc	ra,0x3
    20a0:	57a080e7          	jalr	1402(ra) # 5616 <exit>
      printf("%s: wait stopped early\n", s);
    20a4:	85ce                	mv	a1,s3
    20a6:	00005517          	auipc	a0,0x5
    20aa:	95a50513          	addi	a0,a0,-1702 # 6a00 <statistics+0xed0>
    20ae:	00004097          	auipc	ra,0x4
    20b2:	8e0080e7          	jalr	-1824(ra) # 598e <printf>
      exit(1);
    20b6:	4505                	li	a0,1
    20b8:	00003097          	auipc	ra,0x3
    20bc:	55e080e7          	jalr	1374(ra) # 5616 <exit>
    printf("%s: wait got too many\n", s);
    20c0:	85ce                	mv	a1,s3
    20c2:	00005517          	auipc	a0,0x5
    20c6:	95650513          	addi	a0,a0,-1706 # 6a18 <statistics+0xee8>
    20ca:	00004097          	auipc	ra,0x4
    20ce:	8c4080e7          	jalr	-1852(ra) # 598e <printf>
    exit(1);
    20d2:	4505                	li	a0,1
    20d4:	00003097          	auipc	ra,0x3
    20d8:	542080e7          	jalr	1346(ra) # 5616 <exit>

00000000000020dc <kernmem>:
{
    20dc:	715d                	addi	sp,sp,-80
    20de:	e486                	sd	ra,72(sp)
    20e0:	e0a2                	sd	s0,64(sp)
    20e2:	fc26                	sd	s1,56(sp)
    20e4:	f84a                	sd	s2,48(sp)
    20e6:	f44e                	sd	s3,40(sp)
    20e8:	f052                	sd	s4,32(sp)
    20ea:	ec56                	sd	s5,24(sp)
    20ec:	0880                	addi	s0,sp,80
    20ee:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f0:	4485                	li	s1,1
    20f2:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    20f4:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f6:	69b1                	lui	s3,0xc
    20f8:	35098993          	addi	s3,s3,848 # c350 <buf+0x800>
    20fc:	1003d937          	lui	s2,0x1003d
    2100:	090e                	slli	s2,s2,0x3
    2102:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e920>
    pid = fork();
    2106:	00003097          	auipc	ra,0x3
    210a:	508080e7          	jalr	1288(ra) # 560e <fork>
    if(pid < 0){
    210e:	02054963          	bltz	a0,2140 <kernmem+0x64>
    if(pid == 0){
    2112:	c529                	beqz	a0,215c <kernmem+0x80>
    wait(&xstatus);
    2114:	fbc40513          	addi	a0,s0,-68
    2118:	00003097          	auipc	ra,0x3
    211c:	506080e7          	jalr	1286(ra) # 561e <wait>
    if(xstatus != -1)  // did kernel kill child?
    2120:	fbc42783          	lw	a5,-68(s0)
    2124:	05579d63          	bne	a5,s5,217e <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2128:	94ce                	add	s1,s1,s3
    212a:	fd249ee3          	bne	s1,s2,2106 <kernmem+0x2a>
}
    212e:	60a6                	ld	ra,72(sp)
    2130:	6406                	ld	s0,64(sp)
    2132:	74e2                	ld	s1,56(sp)
    2134:	7942                	ld	s2,48(sp)
    2136:	79a2                	ld	s3,40(sp)
    2138:	7a02                	ld	s4,32(sp)
    213a:	6ae2                	ld	s5,24(sp)
    213c:	6161                	addi	sp,sp,80
    213e:	8082                	ret
      printf("%s: fork failed\n", s);
    2140:	85d2                	mv	a1,s4
    2142:	00004517          	auipc	a0,0x4
    2146:	60650513          	addi	a0,a0,1542 # 6748 <statistics+0xc18>
    214a:	00004097          	auipc	ra,0x4
    214e:	844080e7          	jalr	-1980(ra) # 598e <printf>
      exit(1);
    2152:	4505                	li	a0,1
    2154:	00003097          	auipc	ra,0x3
    2158:	4c2080e7          	jalr	1218(ra) # 5616 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    215c:	0004c683          	lbu	a3,0(s1)
    2160:	8626                	mv	a2,s1
    2162:	85d2                	mv	a1,s4
    2164:	00005517          	auipc	a0,0x5
    2168:	8cc50513          	addi	a0,a0,-1844 # 6a30 <statistics+0xf00>
    216c:	00004097          	auipc	ra,0x4
    2170:	822080e7          	jalr	-2014(ra) # 598e <printf>
      exit(1);
    2174:	4505                	li	a0,1
    2176:	00003097          	auipc	ra,0x3
    217a:	4a0080e7          	jalr	1184(ra) # 5616 <exit>
      exit(1);
    217e:	4505                	li	a0,1
    2180:	00003097          	auipc	ra,0x3
    2184:	496080e7          	jalr	1174(ra) # 5616 <exit>

0000000000002188 <bigargtest>:
{
    2188:	7179                	addi	sp,sp,-48
    218a:	f406                	sd	ra,40(sp)
    218c:	f022                	sd	s0,32(sp)
    218e:	ec26                	sd	s1,24(sp)
    2190:	1800                	addi	s0,sp,48
    2192:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2194:	00005517          	auipc	a0,0x5
    2198:	8bc50513          	addi	a0,a0,-1860 # 6a50 <statistics+0xf20>
    219c:	00003097          	auipc	ra,0x3
    21a0:	4ca080e7          	jalr	1226(ra) # 5666 <unlink>
  pid = fork();
    21a4:	00003097          	auipc	ra,0x3
    21a8:	46a080e7          	jalr	1130(ra) # 560e <fork>
  if(pid == 0){
    21ac:	c121                	beqz	a0,21ec <bigargtest+0x64>
  } else if(pid < 0){
    21ae:	0a054063          	bltz	a0,224e <bigargtest+0xc6>
  wait(&xstatus);
    21b2:	fdc40513          	addi	a0,s0,-36
    21b6:	00003097          	auipc	ra,0x3
    21ba:	468080e7          	jalr	1128(ra) # 561e <wait>
  if(xstatus != 0)
    21be:	fdc42503          	lw	a0,-36(s0)
    21c2:	e545                	bnez	a0,226a <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    21c4:	4581                	li	a1,0
    21c6:	00005517          	auipc	a0,0x5
    21ca:	88a50513          	addi	a0,a0,-1910 # 6a50 <statistics+0xf20>
    21ce:	00003097          	auipc	ra,0x3
    21d2:	488080e7          	jalr	1160(ra) # 5656 <open>
  if(fd < 0){
    21d6:	08054e63          	bltz	a0,2272 <bigargtest+0xea>
  close(fd);
    21da:	00003097          	auipc	ra,0x3
    21de:	464080e7          	jalr	1124(ra) # 563e <close>
}
    21e2:	70a2                	ld	ra,40(sp)
    21e4:	7402                	ld	s0,32(sp)
    21e6:	64e2                	ld	s1,24(sp)
    21e8:	6145                	addi	sp,sp,48
    21ea:	8082                	ret
    21ec:	00006797          	auipc	a5,0x6
    21f0:	14c78793          	addi	a5,a5,332 # 8338 <args.1838>
    21f4:	00006697          	auipc	a3,0x6
    21f8:	23c68693          	addi	a3,a3,572 # 8430 <args.1838+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    21fc:	00005717          	auipc	a4,0x5
    2200:	86470713          	addi	a4,a4,-1948 # 6a60 <statistics+0xf30>
    2204:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    2206:	07a1                	addi	a5,a5,8
    2208:	fed79ee3          	bne	a5,a3,2204 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    220c:	00006597          	auipc	a1,0x6
    2210:	12c58593          	addi	a1,a1,300 # 8338 <args.1838>
    2214:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2218:	00004517          	auipc	a0,0x4
    221c:	cf850513          	addi	a0,a0,-776 # 5f10 <statistics+0x3e0>
    2220:	00003097          	auipc	ra,0x3
    2224:	42e080e7          	jalr	1070(ra) # 564e <exec>
    fd = open("bigarg-ok", O_CREATE);
    2228:	20000593          	li	a1,512
    222c:	00005517          	auipc	a0,0x5
    2230:	82450513          	addi	a0,a0,-2012 # 6a50 <statistics+0xf20>
    2234:	00003097          	auipc	ra,0x3
    2238:	422080e7          	jalr	1058(ra) # 5656 <open>
    close(fd);
    223c:	00003097          	auipc	ra,0x3
    2240:	402080e7          	jalr	1026(ra) # 563e <close>
    exit(0);
    2244:	4501                	li	a0,0
    2246:	00003097          	auipc	ra,0x3
    224a:	3d0080e7          	jalr	976(ra) # 5616 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    224e:	85a6                	mv	a1,s1
    2250:	00005517          	auipc	a0,0x5
    2254:	8f050513          	addi	a0,a0,-1808 # 6b40 <statistics+0x1010>
    2258:	00003097          	auipc	ra,0x3
    225c:	736080e7          	jalr	1846(ra) # 598e <printf>
    exit(1);
    2260:	4505                	li	a0,1
    2262:	00003097          	auipc	ra,0x3
    2266:	3b4080e7          	jalr	948(ra) # 5616 <exit>
    exit(xstatus);
    226a:	00003097          	auipc	ra,0x3
    226e:	3ac080e7          	jalr	940(ra) # 5616 <exit>
    printf("%s: bigarg test failed!\n", s);
    2272:	85a6                	mv	a1,s1
    2274:	00005517          	auipc	a0,0x5
    2278:	8ec50513          	addi	a0,a0,-1812 # 6b60 <statistics+0x1030>
    227c:	00003097          	auipc	ra,0x3
    2280:	712080e7          	jalr	1810(ra) # 598e <printf>
    exit(1);
    2284:	4505                	li	a0,1
    2286:	00003097          	auipc	ra,0x3
    228a:	390080e7          	jalr	912(ra) # 5616 <exit>

000000000000228e <stacktest>:
{
    228e:	7179                	addi	sp,sp,-48
    2290:	f406                	sd	ra,40(sp)
    2292:	f022                	sd	s0,32(sp)
    2294:	ec26                	sd	s1,24(sp)
    2296:	1800                	addi	s0,sp,48
    2298:	84aa                	mv	s1,a0
  pid = fork();
    229a:	00003097          	auipc	ra,0x3
    229e:	374080e7          	jalr	884(ra) # 560e <fork>
  if(pid == 0) {
    22a2:	c115                	beqz	a0,22c6 <stacktest+0x38>
  } else if(pid < 0){
    22a4:	04054463          	bltz	a0,22ec <stacktest+0x5e>
  wait(&xstatus);
    22a8:	fdc40513          	addi	a0,s0,-36
    22ac:	00003097          	auipc	ra,0x3
    22b0:	372080e7          	jalr	882(ra) # 561e <wait>
  if(xstatus == -1)  // kernel killed child?
    22b4:	fdc42503          	lw	a0,-36(s0)
    22b8:	57fd                	li	a5,-1
    22ba:	04f50763          	beq	a0,a5,2308 <stacktest+0x7a>
    exit(xstatus);
    22be:	00003097          	auipc	ra,0x3
    22c2:	358080e7          	jalr	856(ra) # 5616 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    22c6:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    22c8:	77fd                	lui	a5,0xfffff
    22ca:	97ba                	add	a5,a5,a4
    22cc:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff04a0>
    22d0:	85a6                	mv	a1,s1
    22d2:	00005517          	auipc	a0,0x5
    22d6:	8ae50513          	addi	a0,a0,-1874 # 6b80 <statistics+0x1050>
    22da:	00003097          	auipc	ra,0x3
    22de:	6b4080e7          	jalr	1716(ra) # 598e <printf>
    exit(1);
    22e2:	4505                	li	a0,1
    22e4:	00003097          	auipc	ra,0x3
    22e8:	332080e7          	jalr	818(ra) # 5616 <exit>
    printf("%s: fork failed\n", s);
    22ec:	85a6                	mv	a1,s1
    22ee:	00004517          	auipc	a0,0x4
    22f2:	45a50513          	addi	a0,a0,1114 # 6748 <statistics+0xc18>
    22f6:	00003097          	auipc	ra,0x3
    22fa:	698080e7          	jalr	1688(ra) # 598e <printf>
    exit(1);
    22fe:	4505                	li	a0,1
    2300:	00003097          	auipc	ra,0x3
    2304:	316080e7          	jalr	790(ra) # 5616 <exit>
    exit(0);
    2308:	4501                	li	a0,0
    230a:	00003097          	auipc	ra,0x3
    230e:	30c080e7          	jalr	780(ra) # 5616 <exit>

0000000000002312 <copyinstr3>:
{
    2312:	7179                	addi	sp,sp,-48
    2314:	f406                	sd	ra,40(sp)
    2316:	f022                	sd	s0,32(sp)
    2318:	ec26                	sd	s1,24(sp)
    231a:	1800                	addi	s0,sp,48
  sbrk(8192);
    231c:	6509                	lui	a0,0x2
    231e:	00003097          	auipc	ra,0x3
    2322:	380080e7          	jalr	896(ra) # 569e <sbrk>
  uint64 top = (uint64) sbrk(0);
    2326:	4501                	li	a0,0
    2328:	00003097          	auipc	ra,0x3
    232c:	376080e7          	jalr	886(ra) # 569e <sbrk>
  if((top % PGSIZE) != 0){
    2330:	03451793          	slli	a5,a0,0x34
    2334:	e3c9                	bnez	a5,23b6 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2336:	4501                	li	a0,0
    2338:	00003097          	auipc	ra,0x3
    233c:	366080e7          	jalr	870(ra) # 569e <sbrk>
  if(top % PGSIZE){
    2340:	03451793          	slli	a5,a0,0x34
    2344:	e3d9                	bnez	a5,23ca <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2346:	fff50493          	addi	s1,a0,-1 # 1fff <forktest+0x3>
  *b = 'x';
    234a:	07800793          	li	a5,120
    234e:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2352:	8526                	mv	a0,s1
    2354:	00003097          	auipc	ra,0x3
    2358:	312080e7          	jalr	786(ra) # 5666 <unlink>
  if(ret != -1){
    235c:	57fd                	li	a5,-1
    235e:	08f51363          	bne	a0,a5,23e4 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2362:	20100593          	li	a1,513
    2366:	8526                	mv	a0,s1
    2368:	00003097          	auipc	ra,0x3
    236c:	2ee080e7          	jalr	750(ra) # 5656 <open>
  if(fd != -1){
    2370:	57fd                	li	a5,-1
    2372:	08f51863          	bne	a0,a5,2402 <copyinstr3+0xf0>
  ret = link(b, b);
    2376:	85a6                	mv	a1,s1
    2378:	8526                	mv	a0,s1
    237a:	00003097          	auipc	ra,0x3
    237e:	2fc080e7          	jalr	764(ra) # 5676 <link>
  if(ret != -1){
    2382:	57fd                	li	a5,-1
    2384:	08f51e63          	bne	a0,a5,2420 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2388:	00005797          	auipc	a5,0x5
    238c:	49078793          	addi	a5,a5,1168 # 7818 <statistics+0x1ce8>
    2390:	fcf43823          	sd	a5,-48(s0)
    2394:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2398:	fd040593          	addi	a1,s0,-48
    239c:	8526                	mv	a0,s1
    239e:	00003097          	auipc	ra,0x3
    23a2:	2b0080e7          	jalr	688(ra) # 564e <exec>
  if(ret != -1){
    23a6:	57fd                	li	a5,-1
    23a8:	08f51c63          	bne	a0,a5,2440 <copyinstr3+0x12e>
}
    23ac:	70a2                	ld	ra,40(sp)
    23ae:	7402                	ld	s0,32(sp)
    23b0:	64e2                	ld	s1,24(sp)
    23b2:	6145                	addi	sp,sp,48
    23b4:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    23b6:	0347d513          	srli	a0,a5,0x34
    23ba:	6785                	lui	a5,0x1
    23bc:	40a7853b          	subw	a0,a5,a0
    23c0:	00003097          	auipc	ra,0x3
    23c4:	2de080e7          	jalr	734(ra) # 569e <sbrk>
    23c8:	b7bd                	j	2336 <copyinstr3+0x24>
    printf("oops\n");
    23ca:	00004517          	auipc	a0,0x4
    23ce:	7de50513          	addi	a0,a0,2014 # 6ba8 <statistics+0x1078>
    23d2:	00003097          	auipc	ra,0x3
    23d6:	5bc080e7          	jalr	1468(ra) # 598e <printf>
    exit(1);
    23da:	4505                	li	a0,1
    23dc:	00003097          	auipc	ra,0x3
    23e0:	23a080e7          	jalr	570(ra) # 5616 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    23e4:	862a                	mv	a2,a0
    23e6:	85a6                	mv	a1,s1
    23e8:	00004517          	auipc	a0,0x4
    23ec:	28050513          	addi	a0,a0,640 # 6668 <statistics+0xb38>
    23f0:	00003097          	auipc	ra,0x3
    23f4:	59e080e7          	jalr	1438(ra) # 598e <printf>
    exit(1);
    23f8:	4505                	li	a0,1
    23fa:	00003097          	auipc	ra,0x3
    23fe:	21c080e7          	jalr	540(ra) # 5616 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2402:	862a                	mv	a2,a0
    2404:	85a6                	mv	a1,s1
    2406:	00004517          	auipc	a0,0x4
    240a:	28250513          	addi	a0,a0,642 # 6688 <statistics+0xb58>
    240e:	00003097          	auipc	ra,0x3
    2412:	580080e7          	jalr	1408(ra) # 598e <printf>
    exit(1);
    2416:	4505                	li	a0,1
    2418:	00003097          	auipc	ra,0x3
    241c:	1fe080e7          	jalr	510(ra) # 5616 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2420:	86aa                	mv	a3,a0
    2422:	8626                	mv	a2,s1
    2424:	85a6                	mv	a1,s1
    2426:	00004517          	auipc	a0,0x4
    242a:	28250513          	addi	a0,a0,642 # 66a8 <statistics+0xb78>
    242e:	00003097          	auipc	ra,0x3
    2432:	560080e7          	jalr	1376(ra) # 598e <printf>
    exit(1);
    2436:	4505                	li	a0,1
    2438:	00003097          	auipc	ra,0x3
    243c:	1de080e7          	jalr	478(ra) # 5616 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2440:	567d                	li	a2,-1
    2442:	85a6                	mv	a1,s1
    2444:	00004517          	auipc	a0,0x4
    2448:	28c50513          	addi	a0,a0,652 # 66d0 <statistics+0xba0>
    244c:	00003097          	auipc	ra,0x3
    2450:	542080e7          	jalr	1346(ra) # 598e <printf>
    exit(1);
    2454:	4505                	li	a0,1
    2456:	00003097          	auipc	ra,0x3
    245a:	1c0080e7          	jalr	448(ra) # 5616 <exit>

000000000000245e <rwsbrk>:
{
    245e:	1101                	addi	sp,sp,-32
    2460:	ec06                	sd	ra,24(sp)
    2462:	e822                	sd	s0,16(sp)
    2464:	e426                	sd	s1,8(sp)
    2466:	e04a                	sd	s2,0(sp)
    2468:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    246a:	6509                	lui	a0,0x2
    246c:	00003097          	auipc	ra,0x3
    2470:	232080e7          	jalr	562(ra) # 569e <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2474:	57fd                	li	a5,-1
    2476:	06f50363          	beq	a0,a5,24dc <rwsbrk+0x7e>
    247a:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    247c:	7579                	lui	a0,0xffffe
    247e:	00003097          	auipc	ra,0x3
    2482:	220080e7          	jalr	544(ra) # 569e <sbrk>
    2486:	57fd                	li	a5,-1
    2488:	06f50763          	beq	a0,a5,24f6 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    248c:	20100593          	li	a1,513
    2490:	00003517          	auipc	a0,0x3
    2494:	7a050513          	addi	a0,a0,1952 # 5c30 <statistics+0x100>
    2498:	00003097          	auipc	ra,0x3
    249c:	1be080e7          	jalr	446(ra) # 5656 <open>
    24a0:	892a                	mv	s2,a0
  if(fd < 0){
    24a2:	06054763          	bltz	a0,2510 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    24a6:	6505                	lui	a0,0x1
    24a8:	94aa                	add	s1,s1,a0
    24aa:	40000613          	li	a2,1024
    24ae:	85a6                	mv	a1,s1
    24b0:	854a                	mv	a0,s2
    24b2:	00003097          	auipc	ra,0x3
    24b6:	184080e7          	jalr	388(ra) # 5636 <write>
    24ba:	862a                	mv	a2,a0
  if(n >= 0){
    24bc:	06054763          	bltz	a0,252a <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    24c0:	85a6                	mv	a1,s1
    24c2:	00004517          	auipc	a0,0x4
    24c6:	73e50513          	addi	a0,a0,1854 # 6c00 <statistics+0x10d0>
    24ca:	00003097          	auipc	ra,0x3
    24ce:	4c4080e7          	jalr	1220(ra) # 598e <printf>
    exit(1);
    24d2:	4505                	li	a0,1
    24d4:	00003097          	auipc	ra,0x3
    24d8:	142080e7          	jalr	322(ra) # 5616 <exit>
    printf("sbrk(rwsbrk) failed\n");
    24dc:	00004517          	auipc	a0,0x4
    24e0:	6d450513          	addi	a0,a0,1748 # 6bb0 <statistics+0x1080>
    24e4:	00003097          	auipc	ra,0x3
    24e8:	4aa080e7          	jalr	1194(ra) # 598e <printf>
    exit(1);
    24ec:	4505                	li	a0,1
    24ee:	00003097          	auipc	ra,0x3
    24f2:	128080e7          	jalr	296(ra) # 5616 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    24f6:	00004517          	auipc	a0,0x4
    24fa:	6d250513          	addi	a0,a0,1746 # 6bc8 <statistics+0x1098>
    24fe:	00003097          	auipc	ra,0x3
    2502:	490080e7          	jalr	1168(ra) # 598e <printf>
    exit(1);
    2506:	4505                	li	a0,1
    2508:	00003097          	auipc	ra,0x3
    250c:	10e080e7          	jalr	270(ra) # 5616 <exit>
    printf("open(rwsbrk) failed\n");
    2510:	00004517          	auipc	a0,0x4
    2514:	6d850513          	addi	a0,a0,1752 # 6be8 <statistics+0x10b8>
    2518:	00003097          	auipc	ra,0x3
    251c:	476080e7          	jalr	1142(ra) # 598e <printf>
    exit(1);
    2520:	4505                	li	a0,1
    2522:	00003097          	auipc	ra,0x3
    2526:	0f4080e7          	jalr	244(ra) # 5616 <exit>
  close(fd);
    252a:	854a                	mv	a0,s2
    252c:	00003097          	auipc	ra,0x3
    2530:	112080e7          	jalr	274(ra) # 563e <close>
  unlink("rwsbrk");
    2534:	00003517          	auipc	a0,0x3
    2538:	6fc50513          	addi	a0,a0,1788 # 5c30 <statistics+0x100>
    253c:	00003097          	auipc	ra,0x3
    2540:	12a080e7          	jalr	298(ra) # 5666 <unlink>
  fd = open("README", O_RDONLY);
    2544:	4581                	li	a1,0
    2546:	00004517          	auipc	a0,0x4
    254a:	b6250513          	addi	a0,a0,-1182 # 60a8 <statistics+0x578>
    254e:	00003097          	auipc	ra,0x3
    2552:	108080e7          	jalr	264(ra) # 5656 <open>
    2556:	892a                	mv	s2,a0
  if(fd < 0){
    2558:	02054963          	bltz	a0,258a <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    255c:	4629                	li	a2,10
    255e:	85a6                	mv	a1,s1
    2560:	00003097          	auipc	ra,0x3
    2564:	0ce080e7          	jalr	206(ra) # 562e <read>
    2568:	862a                	mv	a2,a0
  if(n >= 0){
    256a:	02054d63          	bltz	a0,25a4 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    256e:	85a6                	mv	a1,s1
    2570:	00004517          	auipc	a0,0x4
    2574:	6c050513          	addi	a0,a0,1728 # 6c30 <statistics+0x1100>
    2578:	00003097          	auipc	ra,0x3
    257c:	416080e7          	jalr	1046(ra) # 598e <printf>
    exit(1);
    2580:	4505                	li	a0,1
    2582:	00003097          	auipc	ra,0x3
    2586:	094080e7          	jalr	148(ra) # 5616 <exit>
    printf("open(rwsbrk) failed\n");
    258a:	00004517          	auipc	a0,0x4
    258e:	65e50513          	addi	a0,a0,1630 # 6be8 <statistics+0x10b8>
    2592:	00003097          	auipc	ra,0x3
    2596:	3fc080e7          	jalr	1020(ra) # 598e <printf>
    exit(1);
    259a:	4505                	li	a0,1
    259c:	00003097          	auipc	ra,0x3
    25a0:	07a080e7          	jalr	122(ra) # 5616 <exit>
  close(fd);
    25a4:	854a                	mv	a0,s2
    25a6:	00003097          	auipc	ra,0x3
    25aa:	098080e7          	jalr	152(ra) # 563e <close>
  exit(0);
    25ae:	4501                	li	a0,0
    25b0:	00003097          	auipc	ra,0x3
    25b4:	066080e7          	jalr	102(ra) # 5616 <exit>

00000000000025b8 <sbrkbasic>:
{
    25b8:	715d                	addi	sp,sp,-80
    25ba:	e486                	sd	ra,72(sp)
    25bc:	e0a2                	sd	s0,64(sp)
    25be:	fc26                	sd	s1,56(sp)
    25c0:	f84a                	sd	s2,48(sp)
    25c2:	f44e                	sd	s3,40(sp)
    25c4:	f052                	sd	s4,32(sp)
    25c6:	ec56                	sd	s5,24(sp)
    25c8:	0880                	addi	s0,sp,80
    25ca:	8a2a                	mv	s4,a0
  pid = fork();
    25cc:	00003097          	auipc	ra,0x3
    25d0:	042080e7          	jalr	66(ra) # 560e <fork>
  if(pid < 0){
    25d4:	02054c63          	bltz	a0,260c <sbrkbasic+0x54>
  if(pid == 0){
    25d8:	ed21                	bnez	a0,2630 <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    25da:	40000537          	lui	a0,0x40000
    25de:	00003097          	auipc	ra,0x3
    25e2:	0c0080e7          	jalr	192(ra) # 569e <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    25e6:	57fd                	li	a5,-1
    25e8:	02f50f63          	beq	a0,a5,2626 <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25ec:	400007b7          	lui	a5,0x40000
    25f0:	97aa                	add	a5,a5,a0
      *b = 99;
    25f2:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    25f6:	6705                	lui	a4,0x1
      *b = 99;
    25f8:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff14a0>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25fc:	953a                	add	a0,a0,a4
    25fe:	fef51de3          	bne	a0,a5,25f8 <sbrkbasic+0x40>
    exit(1);
    2602:	4505                	li	a0,1
    2604:	00003097          	auipc	ra,0x3
    2608:	012080e7          	jalr	18(ra) # 5616 <exit>
    printf("fork failed in sbrkbasic\n");
    260c:	00004517          	auipc	a0,0x4
    2610:	64c50513          	addi	a0,a0,1612 # 6c58 <statistics+0x1128>
    2614:	00003097          	auipc	ra,0x3
    2618:	37a080e7          	jalr	890(ra) # 598e <printf>
    exit(1);
    261c:	4505                	li	a0,1
    261e:	00003097          	auipc	ra,0x3
    2622:	ff8080e7          	jalr	-8(ra) # 5616 <exit>
      exit(0);
    2626:	4501                	li	a0,0
    2628:	00003097          	auipc	ra,0x3
    262c:	fee080e7          	jalr	-18(ra) # 5616 <exit>
  wait(&xstatus);
    2630:	fbc40513          	addi	a0,s0,-68
    2634:	00003097          	auipc	ra,0x3
    2638:	fea080e7          	jalr	-22(ra) # 561e <wait>
  if(xstatus == 1){
    263c:	fbc42703          	lw	a4,-68(s0)
    2640:	4785                	li	a5,1
    2642:	00f70e63          	beq	a4,a5,265e <sbrkbasic+0xa6>
  a = sbrk(0);
    2646:	4501                	li	a0,0
    2648:	00003097          	auipc	ra,0x3
    264c:	056080e7          	jalr	86(ra) # 569e <sbrk>
    2650:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2652:	4901                	li	s2,0
    *b = 1;
    2654:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    2656:	6985                	lui	s3,0x1
    2658:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1d6>
    265c:	a005                	j	267c <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    265e:	85d2                	mv	a1,s4
    2660:	00004517          	auipc	a0,0x4
    2664:	61850513          	addi	a0,a0,1560 # 6c78 <statistics+0x1148>
    2668:	00003097          	auipc	ra,0x3
    266c:	326080e7          	jalr	806(ra) # 598e <printf>
    exit(1);
    2670:	4505                	li	a0,1
    2672:	00003097          	auipc	ra,0x3
    2676:	fa4080e7          	jalr	-92(ra) # 5616 <exit>
    a = b + 1;
    267a:	84be                	mv	s1,a5
    b = sbrk(1);
    267c:	4505                	li	a0,1
    267e:	00003097          	auipc	ra,0x3
    2682:	020080e7          	jalr	32(ra) # 569e <sbrk>
    if(b != a){
    2686:	04951b63          	bne	a0,s1,26dc <sbrkbasic+0x124>
    *b = 1;
    268a:	01548023          	sb	s5,0(s1)
    a = b + 1;
    268e:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2692:	2905                	addiw	s2,s2,1
    2694:	ff3913e3          	bne	s2,s3,267a <sbrkbasic+0xc2>
  pid = fork();
    2698:	00003097          	auipc	ra,0x3
    269c:	f76080e7          	jalr	-138(ra) # 560e <fork>
    26a0:	892a                	mv	s2,a0
  if(pid < 0){
    26a2:	04054d63          	bltz	a0,26fc <sbrkbasic+0x144>
  c = sbrk(1);
    26a6:	4505                	li	a0,1
    26a8:	00003097          	auipc	ra,0x3
    26ac:	ff6080e7          	jalr	-10(ra) # 569e <sbrk>
  c = sbrk(1);
    26b0:	4505                	li	a0,1
    26b2:	00003097          	auipc	ra,0x3
    26b6:	fec080e7          	jalr	-20(ra) # 569e <sbrk>
  if(c != a + 1){
    26ba:	0489                	addi	s1,s1,2
    26bc:	04a48e63          	beq	s1,a0,2718 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    26c0:	85d2                	mv	a1,s4
    26c2:	00004517          	auipc	a0,0x4
    26c6:	61650513          	addi	a0,a0,1558 # 6cd8 <statistics+0x11a8>
    26ca:	00003097          	auipc	ra,0x3
    26ce:	2c4080e7          	jalr	708(ra) # 598e <printf>
    exit(1);
    26d2:	4505                	li	a0,1
    26d4:	00003097          	auipc	ra,0x3
    26d8:	f42080e7          	jalr	-190(ra) # 5616 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    26dc:	86aa                	mv	a3,a0
    26de:	8626                	mv	a2,s1
    26e0:	85ca                	mv	a1,s2
    26e2:	00004517          	auipc	a0,0x4
    26e6:	5b650513          	addi	a0,a0,1462 # 6c98 <statistics+0x1168>
    26ea:	00003097          	auipc	ra,0x3
    26ee:	2a4080e7          	jalr	676(ra) # 598e <printf>
      exit(1);
    26f2:	4505                	li	a0,1
    26f4:	00003097          	auipc	ra,0x3
    26f8:	f22080e7          	jalr	-222(ra) # 5616 <exit>
    printf("%s: sbrk test fork failed\n", s);
    26fc:	85d2                	mv	a1,s4
    26fe:	00004517          	auipc	a0,0x4
    2702:	5ba50513          	addi	a0,a0,1466 # 6cb8 <statistics+0x1188>
    2706:	00003097          	auipc	ra,0x3
    270a:	288080e7          	jalr	648(ra) # 598e <printf>
    exit(1);
    270e:	4505                	li	a0,1
    2710:	00003097          	auipc	ra,0x3
    2714:	f06080e7          	jalr	-250(ra) # 5616 <exit>
  if(pid == 0)
    2718:	00091763          	bnez	s2,2726 <sbrkbasic+0x16e>
    exit(0);
    271c:	4501                	li	a0,0
    271e:	00003097          	auipc	ra,0x3
    2722:	ef8080e7          	jalr	-264(ra) # 5616 <exit>
  wait(&xstatus);
    2726:	fbc40513          	addi	a0,s0,-68
    272a:	00003097          	auipc	ra,0x3
    272e:	ef4080e7          	jalr	-268(ra) # 561e <wait>
  exit(xstatus);
    2732:	fbc42503          	lw	a0,-68(s0)
    2736:	00003097          	auipc	ra,0x3
    273a:	ee0080e7          	jalr	-288(ra) # 5616 <exit>

000000000000273e <sbrkmuch>:
{
    273e:	7179                	addi	sp,sp,-48
    2740:	f406                	sd	ra,40(sp)
    2742:	f022                	sd	s0,32(sp)
    2744:	ec26                	sd	s1,24(sp)
    2746:	e84a                	sd	s2,16(sp)
    2748:	e44e                	sd	s3,8(sp)
    274a:	e052                	sd	s4,0(sp)
    274c:	1800                	addi	s0,sp,48
    274e:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2750:	4501                	li	a0,0
    2752:	00003097          	auipc	ra,0x3
    2756:	f4c080e7          	jalr	-180(ra) # 569e <sbrk>
    275a:	892a                	mv	s2,a0
  a = sbrk(0);
    275c:	4501                	li	a0,0
    275e:	00003097          	auipc	ra,0x3
    2762:	f40080e7          	jalr	-192(ra) # 569e <sbrk>
    2766:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2768:	06400537          	lui	a0,0x6400
    276c:	9d05                	subw	a0,a0,s1
    276e:	00003097          	auipc	ra,0x3
    2772:	f30080e7          	jalr	-208(ra) # 569e <sbrk>
  if (p != a) {
    2776:	0ca49863          	bne	s1,a0,2846 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    277a:	4501                	li	a0,0
    277c:	00003097          	auipc	ra,0x3
    2780:	f22080e7          	jalr	-222(ra) # 569e <sbrk>
    2784:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2786:	00a4f963          	bgeu	s1,a0,2798 <sbrkmuch+0x5a>
    *pp = 1;
    278a:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    278c:	6705                	lui	a4,0x1
    *pp = 1;
    278e:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2792:	94ba                	add	s1,s1,a4
    2794:	fef4ede3          	bltu	s1,a5,278e <sbrkmuch+0x50>
  *lastaddr = 99;
    2798:	064007b7          	lui	a5,0x6400
    279c:	06300713          	li	a4,99
    27a0:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f149f>
  a = sbrk(0);
    27a4:	4501                	li	a0,0
    27a6:	00003097          	auipc	ra,0x3
    27aa:	ef8080e7          	jalr	-264(ra) # 569e <sbrk>
    27ae:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    27b0:	757d                	lui	a0,0xfffff
    27b2:	00003097          	auipc	ra,0x3
    27b6:	eec080e7          	jalr	-276(ra) # 569e <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    27ba:	57fd                	li	a5,-1
    27bc:	0af50363          	beq	a0,a5,2862 <sbrkmuch+0x124>
  c = sbrk(0);
    27c0:	4501                	li	a0,0
    27c2:	00003097          	auipc	ra,0x3
    27c6:	edc080e7          	jalr	-292(ra) # 569e <sbrk>
  if(c != a - PGSIZE){
    27ca:	77fd                	lui	a5,0xfffff
    27cc:	97a6                	add	a5,a5,s1
    27ce:	0af51863          	bne	a0,a5,287e <sbrkmuch+0x140>
  a = sbrk(0);
    27d2:	4501                	li	a0,0
    27d4:	00003097          	auipc	ra,0x3
    27d8:	eca080e7          	jalr	-310(ra) # 569e <sbrk>
    27dc:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    27de:	6505                	lui	a0,0x1
    27e0:	00003097          	auipc	ra,0x3
    27e4:	ebe080e7          	jalr	-322(ra) # 569e <sbrk>
    27e8:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    27ea:	0aa49a63          	bne	s1,a0,289e <sbrkmuch+0x160>
    27ee:	4501                	li	a0,0
    27f0:	00003097          	auipc	ra,0x3
    27f4:	eae080e7          	jalr	-338(ra) # 569e <sbrk>
    27f8:	6785                	lui	a5,0x1
    27fa:	97a6                	add	a5,a5,s1
    27fc:	0af51163          	bne	a0,a5,289e <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2800:	064007b7          	lui	a5,0x6400
    2804:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f149f>
    2808:	06300793          	li	a5,99
    280c:	0af70963          	beq	a4,a5,28be <sbrkmuch+0x180>
  a = sbrk(0);
    2810:	4501                	li	a0,0
    2812:	00003097          	auipc	ra,0x3
    2816:	e8c080e7          	jalr	-372(ra) # 569e <sbrk>
    281a:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    281c:	4501                	li	a0,0
    281e:	00003097          	auipc	ra,0x3
    2822:	e80080e7          	jalr	-384(ra) # 569e <sbrk>
    2826:	40a9053b          	subw	a0,s2,a0
    282a:	00003097          	auipc	ra,0x3
    282e:	e74080e7          	jalr	-396(ra) # 569e <sbrk>
  if(c != a){
    2832:	0aa49463          	bne	s1,a0,28da <sbrkmuch+0x19c>
}
    2836:	70a2                	ld	ra,40(sp)
    2838:	7402                	ld	s0,32(sp)
    283a:	64e2                	ld	s1,24(sp)
    283c:	6942                	ld	s2,16(sp)
    283e:	69a2                	ld	s3,8(sp)
    2840:	6a02                	ld	s4,0(sp)
    2842:	6145                	addi	sp,sp,48
    2844:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2846:	85ce                	mv	a1,s3
    2848:	00004517          	auipc	a0,0x4
    284c:	4b050513          	addi	a0,a0,1200 # 6cf8 <statistics+0x11c8>
    2850:	00003097          	auipc	ra,0x3
    2854:	13e080e7          	jalr	318(ra) # 598e <printf>
    exit(1);
    2858:	4505                	li	a0,1
    285a:	00003097          	auipc	ra,0x3
    285e:	dbc080e7          	jalr	-580(ra) # 5616 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2862:	85ce                	mv	a1,s3
    2864:	00004517          	auipc	a0,0x4
    2868:	4dc50513          	addi	a0,a0,1244 # 6d40 <statistics+0x1210>
    286c:	00003097          	auipc	ra,0x3
    2870:	122080e7          	jalr	290(ra) # 598e <printf>
    exit(1);
    2874:	4505                	li	a0,1
    2876:	00003097          	auipc	ra,0x3
    287a:	da0080e7          	jalr	-608(ra) # 5616 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    287e:	86aa                	mv	a3,a0
    2880:	8626                	mv	a2,s1
    2882:	85ce                	mv	a1,s3
    2884:	00004517          	auipc	a0,0x4
    2888:	4dc50513          	addi	a0,a0,1244 # 6d60 <statistics+0x1230>
    288c:	00003097          	auipc	ra,0x3
    2890:	102080e7          	jalr	258(ra) # 598e <printf>
    exit(1);
    2894:	4505                	li	a0,1
    2896:	00003097          	auipc	ra,0x3
    289a:	d80080e7          	jalr	-640(ra) # 5616 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    289e:	86d2                	mv	a3,s4
    28a0:	8626                	mv	a2,s1
    28a2:	85ce                	mv	a1,s3
    28a4:	00004517          	auipc	a0,0x4
    28a8:	4fc50513          	addi	a0,a0,1276 # 6da0 <statistics+0x1270>
    28ac:	00003097          	auipc	ra,0x3
    28b0:	0e2080e7          	jalr	226(ra) # 598e <printf>
    exit(1);
    28b4:	4505                	li	a0,1
    28b6:	00003097          	auipc	ra,0x3
    28ba:	d60080e7          	jalr	-672(ra) # 5616 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    28be:	85ce                	mv	a1,s3
    28c0:	00004517          	auipc	a0,0x4
    28c4:	51050513          	addi	a0,a0,1296 # 6dd0 <statistics+0x12a0>
    28c8:	00003097          	auipc	ra,0x3
    28cc:	0c6080e7          	jalr	198(ra) # 598e <printf>
    exit(1);
    28d0:	4505                	li	a0,1
    28d2:	00003097          	auipc	ra,0x3
    28d6:	d44080e7          	jalr	-700(ra) # 5616 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    28da:	86aa                	mv	a3,a0
    28dc:	8626                	mv	a2,s1
    28de:	85ce                	mv	a1,s3
    28e0:	00004517          	auipc	a0,0x4
    28e4:	52850513          	addi	a0,a0,1320 # 6e08 <statistics+0x12d8>
    28e8:	00003097          	auipc	ra,0x3
    28ec:	0a6080e7          	jalr	166(ra) # 598e <printf>
    exit(1);
    28f0:	4505                	li	a0,1
    28f2:	00003097          	auipc	ra,0x3
    28f6:	d24080e7          	jalr	-732(ra) # 5616 <exit>

00000000000028fa <sbrkarg>:
{
    28fa:	7179                	addi	sp,sp,-48
    28fc:	f406                	sd	ra,40(sp)
    28fe:	f022                	sd	s0,32(sp)
    2900:	ec26                	sd	s1,24(sp)
    2902:	e84a                	sd	s2,16(sp)
    2904:	e44e                	sd	s3,8(sp)
    2906:	1800                	addi	s0,sp,48
    2908:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    290a:	6505                	lui	a0,0x1
    290c:	00003097          	auipc	ra,0x3
    2910:	d92080e7          	jalr	-622(ra) # 569e <sbrk>
    2914:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2916:	20100593          	li	a1,513
    291a:	00004517          	auipc	a0,0x4
    291e:	51650513          	addi	a0,a0,1302 # 6e30 <statistics+0x1300>
    2922:	00003097          	auipc	ra,0x3
    2926:	d34080e7          	jalr	-716(ra) # 5656 <open>
    292a:	84aa                	mv	s1,a0
  unlink("sbrk");
    292c:	00004517          	auipc	a0,0x4
    2930:	50450513          	addi	a0,a0,1284 # 6e30 <statistics+0x1300>
    2934:	00003097          	auipc	ra,0x3
    2938:	d32080e7          	jalr	-718(ra) # 5666 <unlink>
  if(fd < 0)  {
    293c:	0404c163          	bltz	s1,297e <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2940:	6605                	lui	a2,0x1
    2942:	85ca                	mv	a1,s2
    2944:	8526                	mv	a0,s1
    2946:	00003097          	auipc	ra,0x3
    294a:	cf0080e7          	jalr	-784(ra) # 5636 <write>
    294e:	04054663          	bltz	a0,299a <sbrkarg+0xa0>
  close(fd);
    2952:	8526                	mv	a0,s1
    2954:	00003097          	auipc	ra,0x3
    2958:	cea080e7          	jalr	-790(ra) # 563e <close>
  a = sbrk(PGSIZE);
    295c:	6505                	lui	a0,0x1
    295e:	00003097          	auipc	ra,0x3
    2962:	d40080e7          	jalr	-704(ra) # 569e <sbrk>
  if(pipe((int *) a) != 0){
    2966:	00003097          	auipc	ra,0x3
    296a:	cc0080e7          	jalr	-832(ra) # 5626 <pipe>
    296e:	e521                	bnez	a0,29b6 <sbrkarg+0xbc>
}
    2970:	70a2                	ld	ra,40(sp)
    2972:	7402                	ld	s0,32(sp)
    2974:	64e2                	ld	s1,24(sp)
    2976:	6942                	ld	s2,16(sp)
    2978:	69a2                	ld	s3,8(sp)
    297a:	6145                	addi	sp,sp,48
    297c:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    297e:	85ce                	mv	a1,s3
    2980:	00004517          	auipc	a0,0x4
    2984:	4b850513          	addi	a0,a0,1208 # 6e38 <statistics+0x1308>
    2988:	00003097          	auipc	ra,0x3
    298c:	006080e7          	jalr	6(ra) # 598e <printf>
    exit(1);
    2990:	4505                	li	a0,1
    2992:	00003097          	auipc	ra,0x3
    2996:	c84080e7          	jalr	-892(ra) # 5616 <exit>
    printf("%s: write sbrk failed\n", s);
    299a:	85ce                	mv	a1,s3
    299c:	00004517          	auipc	a0,0x4
    29a0:	4b450513          	addi	a0,a0,1204 # 6e50 <statistics+0x1320>
    29a4:	00003097          	auipc	ra,0x3
    29a8:	fea080e7          	jalr	-22(ra) # 598e <printf>
    exit(1);
    29ac:	4505                	li	a0,1
    29ae:	00003097          	auipc	ra,0x3
    29b2:	c68080e7          	jalr	-920(ra) # 5616 <exit>
    printf("%s: pipe() failed\n", s);
    29b6:	85ce                	mv	a1,s3
    29b8:	00004517          	auipc	a0,0x4
    29bc:	e9850513          	addi	a0,a0,-360 # 6850 <statistics+0xd20>
    29c0:	00003097          	auipc	ra,0x3
    29c4:	fce080e7          	jalr	-50(ra) # 598e <printf>
    exit(1);
    29c8:	4505                	li	a0,1
    29ca:	00003097          	auipc	ra,0x3
    29ce:	c4c080e7          	jalr	-948(ra) # 5616 <exit>

00000000000029d2 <argptest>:
{
    29d2:	1101                	addi	sp,sp,-32
    29d4:	ec06                	sd	ra,24(sp)
    29d6:	e822                	sd	s0,16(sp)
    29d8:	e426                	sd	s1,8(sp)
    29da:	e04a                	sd	s2,0(sp)
    29dc:	1000                	addi	s0,sp,32
    29de:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    29e0:	4581                	li	a1,0
    29e2:	00004517          	auipc	a0,0x4
    29e6:	48650513          	addi	a0,a0,1158 # 6e68 <statistics+0x1338>
    29ea:	00003097          	auipc	ra,0x3
    29ee:	c6c080e7          	jalr	-916(ra) # 5656 <open>
  if (fd < 0) {
    29f2:	02054b63          	bltz	a0,2a28 <argptest+0x56>
    29f6:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    29f8:	4501                	li	a0,0
    29fa:	00003097          	auipc	ra,0x3
    29fe:	ca4080e7          	jalr	-860(ra) # 569e <sbrk>
    2a02:	567d                	li	a2,-1
    2a04:	fff50593          	addi	a1,a0,-1
    2a08:	8526                	mv	a0,s1
    2a0a:	00003097          	auipc	ra,0x3
    2a0e:	c24080e7          	jalr	-988(ra) # 562e <read>
  close(fd);
    2a12:	8526                	mv	a0,s1
    2a14:	00003097          	auipc	ra,0x3
    2a18:	c2a080e7          	jalr	-982(ra) # 563e <close>
}
    2a1c:	60e2                	ld	ra,24(sp)
    2a1e:	6442                	ld	s0,16(sp)
    2a20:	64a2                	ld	s1,8(sp)
    2a22:	6902                	ld	s2,0(sp)
    2a24:	6105                	addi	sp,sp,32
    2a26:	8082                	ret
    printf("%s: open failed\n", s);
    2a28:	85ca                	mv	a1,s2
    2a2a:	00004517          	auipc	a0,0x4
    2a2e:	d3650513          	addi	a0,a0,-714 # 6760 <statistics+0xc30>
    2a32:	00003097          	auipc	ra,0x3
    2a36:	f5c080e7          	jalr	-164(ra) # 598e <printf>
    exit(1);
    2a3a:	4505                	li	a0,1
    2a3c:	00003097          	auipc	ra,0x3
    2a40:	bda080e7          	jalr	-1062(ra) # 5616 <exit>

0000000000002a44 <sbrkbugs>:
{
    2a44:	1141                	addi	sp,sp,-16
    2a46:	e406                	sd	ra,8(sp)
    2a48:	e022                	sd	s0,0(sp)
    2a4a:	0800                	addi	s0,sp,16
  int pid = fork();
    2a4c:	00003097          	auipc	ra,0x3
    2a50:	bc2080e7          	jalr	-1086(ra) # 560e <fork>
  if(pid < 0){
    2a54:	02054263          	bltz	a0,2a78 <sbrkbugs+0x34>
  if(pid == 0){
    2a58:	ed0d                	bnez	a0,2a92 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2a5a:	00003097          	auipc	ra,0x3
    2a5e:	c44080e7          	jalr	-956(ra) # 569e <sbrk>
    sbrk(-sz);
    2a62:	40a0053b          	negw	a0,a0
    2a66:	00003097          	auipc	ra,0x3
    2a6a:	c38080e7          	jalr	-968(ra) # 569e <sbrk>
    exit(0);
    2a6e:	4501                	li	a0,0
    2a70:	00003097          	auipc	ra,0x3
    2a74:	ba6080e7          	jalr	-1114(ra) # 5616 <exit>
    printf("fork failed\n");
    2a78:	00004517          	auipc	a0,0x4
    2a7c:	0d850513          	addi	a0,a0,216 # 6b50 <statistics+0x1020>
    2a80:	00003097          	auipc	ra,0x3
    2a84:	f0e080e7          	jalr	-242(ra) # 598e <printf>
    exit(1);
    2a88:	4505                	li	a0,1
    2a8a:	00003097          	auipc	ra,0x3
    2a8e:	b8c080e7          	jalr	-1140(ra) # 5616 <exit>
  wait(0);
    2a92:	4501                	li	a0,0
    2a94:	00003097          	auipc	ra,0x3
    2a98:	b8a080e7          	jalr	-1142(ra) # 561e <wait>
  pid = fork();
    2a9c:	00003097          	auipc	ra,0x3
    2aa0:	b72080e7          	jalr	-1166(ra) # 560e <fork>
  if(pid < 0){
    2aa4:	02054563          	bltz	a0,2ace <sbrkbugs+0x8a>
  if(pid == 0){
    2aa8:	e121                	bnez	a0,2ae8 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2aaa:	00003097          	auipc	ra,0x3
    2aae:	bf4080e7          	jalr	-1036(ra) # 569e <sbrk>
    sbrk(-(sz - 3500));
    2ab2:	6785                	lui	a5,0x1
    2ab4:	dac7879b          	addiw	a5,a5,-596
    2ab8:	40a7853b          	subw	a0,a5,a0
    2abc:	00003097          	auipc	ra,0x3
    2ac0:	be2080e7          	jalr	-1054(ra) # 569e <sbrk>
    exit(0);
    2ac4:	4501                	li	a0,0
    2ac6:	00003097          	auipc	ra,0x3
    2aca:	b50080e7          	jalr	-1200(ra) # 5616 <exit>
    printf("fork failed\n");
    2ace:	00004517          	auipc	a0,0x4
    2ad2:	08250513          	addi	a0,a0,130 # 6b50 <statistics+0x1020>
    2ad6:	00003097          	auipc	ra,0x3
    2ada:	eb8080e7          	jalr	-328(ra) # 598e <printf>
    exit(1);
    2ade:	4505                	li	a0,1
    2ae0:	00003097          	auipc	ra,0x3
    2ae4:	b36080e7          	jalr	-1226(ra) # 5616 <exit>
  wait(0);
    2ae8:	4501                	li	a0,0
    2aea:	00003097          	auipc	ra,0x3
    2aee:	b34080e7          	jalr	-1228(ra) # 561e <wait>
  pid = fork();
    2af2:	00003097          	auipc	ra,0x3
    2af6:	b1c080e7          	jalr	-1252(ra) # 560e <fork>
  if(pid < 0){
    2afa:	02054a63          	bltz	a0,2b2e <sbrkbugs+0xea>
  if(pid == 0){
    2afe:	e529                	bnez	a0,2b48 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2b00:	00003097          	auipc	ra,0x3
    2b04:	b9e080e7          	jalr	-1122(ra) # 569e <sbrk>
    2b08:	67ad                	lui	a5,0xb
    2b0a:	8007879b          	addiw	a5,a5,-2048
    2b0e:	40a7853b          	subw	a0,a5,a0
    2b12:	00003097          	auipc	ra,0x3
    2b16:	b8c080e7          	jalr	-1140(ra) # 569e <sbrk>
    sbrk(-10);
    2b1a:	5559                	li	a0,-10
    2b1c:	00003097          	auipc	ra,0x3
    2b20:	b82080e7          	jalr	-1150(ra) # 569e <sbrk>
    exit(0);
    2b24:	4501                	li	a0,0
    2b26:	00003097          	auipc	ra,0x3
    2b2a:	af0080e7          	jalr	-1296(ra) # 5616 <exit>
    printf("fork failed\n");
    2b2e:	00004517          	auipc	a0,0x4
    2b32:	02250513          	addi	a0,a0,34 # 6b50 <statistics+0x1020>
    2b36:	00003097          	auipc	ra,0x3
    2b3a:	e58080e7          	jalr	-424(ra) # 598e <printf>
    exit(1);
    2b3e:	4505                	li	a0,1
    2b40:	00003097          	auipc	ra,0x3
    2b44:	ad6080e7          	jalr	-1322(ra) # 5616 <exit>
  wait(0);
    2b48:	4501                	li	a0,0
    2b4a:	00003097          	auipc	ra,0x3
    2b4e:	ad4080e7          	jalr	-1324(ra) # 561e <wait>
  exit(0);
    2b52:	4501                	li	a0,0
    2b54:	00003097          	auipc	ra,0x3
    2b58:	ac2080e7          	jalr	-1342(ra) # 5616 <exit>

0000000000002b5c <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2b5c:	715d                	addi	sp,sp,-80
    2b5e:	e486                	sd	ra,72(sp)
    2b60:	e0a2                	sd	s0,64(sp)
    2b62:	fc26                	sd	s1,56(sp)
    2b64:	f84a                	sd	s2,48(sp)
    2b66:	f44e                	sd	s3,40(sp)
    2b68:	f052                	sd	s4,32(sp)
    2b6a:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2b6c:	4901                	li	s2,0
    2b6e:	49bd                	li	s3,15
    int pid = fork();
    2b70:	00003097          	auipc	ra,0x3
    2b74:	a9e080e7          	jalr	-1378(ra) # 560e <fork>
    2b78:	84aa                	mv	s1,a0
    if(pid < 0){
    2b7a:	02054063          	bltz	a0,2b9a <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2b7e:	c91d                	beqz	a0,2bb4 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2b80:	4501                	li	a0,0
    2b82:	00003097          	auipc	ra,0x3
    2b86:	a9c080e7          	jalr	-1380(ra) # 561e <wait>
  for(int avail = 0; avail < 15; avail++){
    2b8a:	2905                	addiw	s2,s2,1
    2b8c:	ff3912e3          	bne	s2,s3,2b70 <execout+0x14>
    }
  }

  exit(0);
    2b90:	4501                	li	a0,0
    2b92:	00003097          	auipc	ra,0x3
    2b96:	a84080e7          	jalr	-1404(ra) # 5616 <exit>
      printf("fork failed\n");
    2b9a:	00004517          	auipc	a0,0x4
    2b9e:	fb650513          	addi	a0,a0,-74 # 6b50 <statistics+0x1020>
    2ba2:	00003097          	auipc	ra,0x3
    2ba6:	dec080e7          	jalr	-532(ra) # 598e <printf>
      exit(1);
    2baa:	4505                	li	a0,1
    2bac:	00003097          	auipc	ra,0x3
    2bb0:	a6a080e7          	jalr	-1430(ra) # 5616 <exit>
        if(a == 0xffffffffffffffffLL)
    2bb4:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2bb6:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2bb8:	6505                	lui	a0,0x1
    2bba:	00003097          	auipc	ra,0x3
    2bbe:	ae4080e7          	jalr	-1308(ra) # 569e <sbrk>
        if(a == 0xffffffffffffffffLL)
    2bc2:	01350763          	beq	a0,s3,2bd0 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2bc6:	6785                	lui	a5,0x1
    2bc8:	953e                	add	a0,a0,a5
    2bca:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x9d>
      while(1){
    2bce:	b7ed                	j	2bb8 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2bd0:	01205a63          	blez	s2,2be4 <execout+0x88>
        sbrk(-4096);
    2bd4:	757d                	lui	a0,0xfffff
    2bd6:	00003097          	auipc	ra,0x3
    2bda:	ac8080e7          	jalr	-1336(ra) # 569e <sbrk>
      for(int i = 0; i < avail; i++)
    2bde:	2485                	addiw	s1,s1,1
    2be0:	ff249ae3          	bne	s1,s2,2bd4 <execout+0x78>
      close(1);
    2be4:	4505                	li	a0,1
    2be6:	00003097          	auipc	ra,0x3
    2bea:	a58080e7          	jalr	-1448(ra) # 563e <close>
      char *args[] = { "echo", "x", 0 };
    2bee:	00003517          	auipc	a0,0x3
    2bf2:	32250513          	addi	a0,a0,802 # 5f10 <statistics+0x3e0>
    2bf6:	faa43c23          	sd	a0,-72(s0)
    2bfa:	00003797          	auipc	a5,0x3
    2bfe:	38678793          	addi	a5,a5,902 # 5f80 <statistics+0x450>
    2c02:	fcf43023          	sd	a5,-64(s0)
    2c06:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2c0a:	fb840593          	addi	a1,s0,-72
    2c0e:	00003097          	auipc	ra,0x3
    2c12:	a40080e7          	jalr	-1472(ra) # 564e <exec>
      exit(0);
    2c16:	4501                	li	a0,0
    2c18:	00003097          	auipc	ra,0x3
    2c1c:	9fe080e7          	jalr	-1538(ra) # 5616 <exit>

0000000000002c20 <fourteen>:
{
    2c20:	1101                	addi	sp,sp,-32
    2c22:	ec06                	sd	ra,24(sp)
    2c24:	e822                	sd	s0,16(sp)
    2c26:	e426                	sd	s1,8(sp)
    2c28:	1000                	addi	s0,sp,32
    2c2a:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2c2c:	00004517          	auipc	a0,0x4
    2c30:	41450513          	addi	a0,a0,1044 # 7040 <statistics+0x1510>
    2c34:	00003097          	auipc	ra,0x3
    2c38:	a4a080e7          	jalr	-1462(ra) # 567e <mkdir>
    2c3c:	e165                	bnez	a0,2d1c <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2c3e:	00004517          	auipc	a0,0x4
    2c42:	25a50513          	addi	a0,a0,602 # 6e98 <statistics+0x1368>
    2c46:	00003097          	auipc	ra,0x3
    2c4a:	a38080e7          	jalr	-1480(ra) # 567e <mkdir>
    2c4e:	e56d                	bnez	a0,2d38 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2c50:	20000593          	li	a1,512
    2c54:	00004517          	auipc	a0,0x4
    2c58:	29c50513          	addi	a0,a0,668 # 6ef0 <statistics+0x13c0>
    2c5c:	00003097          	auipc	ra,0x3
    2c60:	9fa080e7          	jalr	-1542(ra) # 5656 <open>
  if(fd < 0){
    2c64:	0e054863          	bltz	a0,2d54 <fourteen+0x134>
  close(fd);
    2c68:	00003097          	auipc	ra,0x3
    2c6c:	9d6080e7          	jalr	-1578(ra) # 563e <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2c70:	4581                	li	a1,0
    2c72:	00004517          	auipc	a0,0x4
    2c76:	2f650513          	addi	a0,a0,758 # 6f68 <statistics+0x1438>
    2c7a:	00003097          	auipc	ra,0x3
    2c7e:	9dc080e7          	jalr	-1572(ra) # 5656 <open>
  if(fd < 0){
    2c82:	0e054763          	bltz	a0,2d70 <fourteen+0x150>
  close(fd);
    2c86:	00003097          	auipc	ra,0x3
    2c8a:	9b8080e7          	jalr	-1608(ra) # 563e <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2c8e:	00004517          	auipc	a0,0x4
    2c92:	34a50513          	addi	a0,a0,842 # 6fd8 <statistics+0x14a8>
    2c96:	00003097          	auipc	ra,0x3
    2c9a:	9e8080e7          	jalr	-1560(ra) # 567e <mkdir>
    2c9e:	c57d                	beqz	a0,2d8c <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2ca0:	00004517          	auipc	a0,0x4
    2ca4:	39050513          	addi	a0,a0,912 # 7030 <statistics+0x1500>
    2ca8:	00003097          	auipc	ra,0x3
    2cac:	9d6080e7          	jalr	-1578(ra) # 567e <mkdir>
    2cb0:	cd65                	beqz	a0,2da8 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2cb2:	00004517          	auipc	a0,0x4
    2cb6:	37e50513          	addi	a0,a0,894 # 7030 <statistics+0x1500>
    2cba:	00003097          	auipc	ra,0x3
    2cbe:	9ac080e7          	jalr	-1620(ra) # 5666 <unlink>
  unlink("12345678901234/12345678901234");
    2cc2:	00004517          	auipc	a0,0x4
    2cc6:	31650513          	addi	a0,a0,790 # 6fd8 <statistics+0x14a8>
    2cca:	00003097          	auipc	ra,0x3
    2cce:	99c080e7          	jalr	-1636(ra) # 5666 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2cd2:	00004517          	auipc	a0,0x4
    2cd6:	29650513          	addi	a0,a0,662 # 6f68 <statistics+0x1438>
    2cda:	00003097          	auipc	ra,0x3
    2cde:	98c080e7          	jalr	-1652(ra) # 5666 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2ce2:	00004517          	auipc	a0,0x4
    2ce6:	20e50513          	addi	a0,a0,526 # 6ef0 <statistics+0x13c0>
    2cea:	00003097          	auipc	ra,0x3
    2cee:	97c080e7          	jalr	-1668(ra) # 5666 <unlink>
  unlink("12345678901234/123456789012345");
    2cf2:	00004517          	auipc	a0,0x4
    2cf6:	1a650513          	addi	a0,a0,422 # 6e98 <statistics+0x1368>
    2cfa:	00003097          	auipc	ra,0x3
    2cfe:	96c080e7          	jalr	-1684(ra) # 5666 <unlink>
  unlink("12345678901234");
    2d02:	00004517          	auipc	a0,0x4
    2d06:	33e50513          	addi	a0,a0,830 # 7040 <statistics+0x1510>
    2d0a:	00003097          	auipc	ra,0x3
    2d0e:	95c080e7          	jalr	-1700(ra) # 5666 <unlink>
}
    2d12:	60e2                	ld	ra,24(sp)
    2d14:	6442                	ld	s0,16(sp)
    2d16:	64a2                	ld	s1,8(sp)
    2d18:	6105                	addi	sp,sp,32
    2d1a:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2d1c:	85a6                	mv	a1,s1
    2d1e:	00004517          	auipc	a0,0x4
    2d22:	15250513          	addi	a0,a0,338 # 6e70 <statistics+0x1340>
    2d26:	00003097          	auipc	ra,0x3
    2d2a:	c68080e7          	jalr	-920(ra) # 598e <printf>
    exit(1);
    2d2e:	4505                	li	a0,1
    2d30:	00003097          	auipc	ra,0x3
    2d34:	8e6080e7          	jalr	-1818(ra) # 5616 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2d38:	85a6                	mv	a1,s1
    2d3a:	00004517          	auipc	a0,0x4
    2d3e:	17e50513          	addi	a0,a0,382 # 6eb8 <statistics+0x1388>
    2d42:	00003097          	auipc	ra,0x3
    2d46:	c4c080e7          	jalr	-948(ra) # 598e <printf>
    exit(1);
    2d4a:	4505                	li	a0,1
    2d4c:	00003097          	auipc	ra,0x3
    2d50:	8ca080e7          	jalr	-1846(ra) # 5616 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2d54:	85a6                	mv	a1,s1
    2d56:	00004517          	auipc	a0,0x4
    2d5a:	1ca50513          	addi	a0,a0,458 # 6f20 <statistics+0x13f0>
    2d5e:	00003097          	auipc	ra,0x3
    2d62:	c30080e7          	jalr	-976(ra) # 598e <printf>
    exit(1);
    2d66:	4505                	li	a0,1
    2d68:	00003097          	auipc	ra,0x3
    2d6c:	8ae080e7          	jalr	-1874(ra) # 5616 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2d70:	85a6                	mv	a1,s1
    2d72:	00004517          	auipc	a0,0x4
    2d76:	22650513          	addi	a0,a0,550 # 6f98 <statistics+0x1468>
    2d7a:	00003097          	auipc	ra,0x3
    2d7e:	c14080e7          	jalr	-1004(ra) # 598e <printf>
    exit(1);
    2d82:	4505                	li	a0,1
    2d84:	00003097          	auipc	ra,0x3
    2d88:	892080e7          	jalr	-1902(ra) # 5616 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2d8c:	85a6                	mv	a1,s1
    2d8e:	00004517          	auipc	a0,0x4
    2d92:	26a50513          	addi	a0,a0,618 # 6ff8 <statistics+0x14c8>
    2d96:	00003097          	auipc	ra,0x3
    2d9a:	bf8080e7          	jalr	-1032(ra) # 598e <printf>
    exit(1);
    2d9e:	4505                	li	a0,1
    2da0:	00003097          	auipc	ra,0x3
    2da4:	876080e7          	jalr	-1930(ra) # 5616 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2da8:	85a6                	mv	a1,s1
    2daa:	00004517          	auipc	a0,0x4
    2dae:	2a650513          	addi	a0,a0,678 # 7050 <statistics+0x1520>
    2db2:	00003097          	auipc	ra,0x3
    2db6:	bdc080e7          	jalr	-1060(ra) # 598e <printf>
    exit(1);
    2dba:	4505                	li	a0,1
    2dbc:	00003097          	auipc	ra,0x3
    2dc0:	85a080e7          	jalr	-1958(ra) # 5616 <exit>

0000000000002dc4 <iputtest>:
{
    2dc4:	1101                	addi	sp,sp,-32
    2dc6:	ec06                	sd	ra,24(sp)
    2dc8:	e822                	sd	s0,16(sp)
    2dca:	e426                	sd	s1,8(sp)
    2dcc:	1000                	addi	s0,sp,32
    2dce:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2dd0:	00004517          	auipc	a0,0x4
    2dd4:	2b850513          	addi	a0,a0,696 # 7088 <statistics+0x1558>
    2dd8:	00003097          	auipc	ra,0x3
    2ddc:	8a6080e7          	jalr	-1882(ra) # 567e <mkdir>
    2de0:	04054563          	bltz	a0,2e2a <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2de4:	00004517          	auipc	a0,0x4
    2de8:	2a450513          	addi	a0,a0,676 # 7088 <statistics+0x1558>
    2dec:	00003097          	auipc	ra,0x3
    2df0:	89a080e7          	jalr	-1894(ra) # 5686 <chdir>
    2df4:	04054963          	bltz	a0,2e46 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2df8:	00004517          	auipc	a0,0x4
    2dfc:	2d050513          	addi	a0,a0,720 # 70c8 <statistics+0x1598>
    2e00:	00003097          	auipc	ra,0x3
    2e04:	866080e7          	jalr	-1946(ra) # 5666 <unlink>
    2e08:	04054d63          	bltz	a0,2e62 <iputtest+0x9e>
  if(chdir("/") < 0){
    2e0c:	00004517          	auipc	a0,0x4
    2e10:	2ec50513          	addi	a0,a0,748 # 70f8 <statistics+0x15c8>
    2e14:	00003097          	auipc	ra,0x3
    2e18:	872080e7          	jalr	-1934(ra) # 5686 <chdir>
    2e1c:	06054163          	bltz	a0,2e7e <iputtest+0xba>
}
    2e20:	60e2                	ld	ra,24(sp)
    2e22:	6442                	ld	s0,16(sp)
    2e24:	64a2                	ld	s1,8(sp)
    2e26:	6105                	addi	sp,sp,32
    2e28:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2e2a:	85a6                	mv	a1,s1
    2e2c:	00004517          	auipc	a0,0x4
    2e30:	26450513          	addi	a0,a0,612 # 7090 <statistics+0x1560>
    2e34:	00003097          	auipc	ra,0x3
    2e38:	b5a080e7          	jalr	-1190(ra) # 598e <printf>
    exit(1);
    2e3c:	4505                	li	a0,1
    2e3e:	00002097          	auipc	ra,0x2
    2e42:	7d8080e7          	jalr	2008(ra) # 5616 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2e46:	85a6                	mv	a1,s1
    2e48:	00004517          	auipc	a0,0x4
    2e4c:	26050513          	addi	a0,a0,608 # 70a8 <statistics+0x1578>
    2e50:	00003097          	auipc	ra,0x3
    2e54:	b3e080e7          	jalr	-1218(ra) # 598e <printf>
    exit(1);
    2e58:	4505                	li	a0,1
    2e5a:	00002097          	auipc	ra,0x2
    2e5e:	7bc080e7          	jalr	1980(ra) # 5616 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2e62:	85a6                	mv	a1,s1
    2e64:	00004517          	auipc	a0,0x4
    2e68:	27450513          	addi	a0,a0,628 # 70d8 <statistics+0x15a8>
    2e6c:	00003097          	auipc	ra,0x3
    2e70:	b22080e7          	jalr	-1246(ra) # 598e <printf>
    exit(1);
    2e74:	4505                	li	a0,1
    2e76:	00002097          	auipc	ra,0x2
    2e7a:	7a0080e7          	jalr	1952(ra) # 5616 <exit>
    printf("%s: chdir / failed\n", s);
    2e7e:	85a6                	mv	a1,s1
    2e80:	00004517          	auipc	a0,0x4
    2e84:	28050513          	addi	a0,a0,640 # 7100 <statistics+0x15d0>
    2e88:	00003097          	auipc	ra,0x3
    2e8c:	b06080e7          	jalr	-1274(ra) # 598e <printf>
    exit(1);
    2e90:	4505                	li	a0,1
    2e92:	00002097          	auipc	ra,0x2
    2e96:	784080e7          	jalr	1924(ra) # 5616 <exit>

0000000000002e9a <exitiputtest>:
{
    2e9a:	7179                	addi	sp,sp,-48
    2e9c:	f406                	sd	ra,40(sp)
    2e9e:	f022                	sd	s0,32(sp)
    2ea0:	ec26                	sd	s1,24(sp)
    2ea2:	1800                	addi	s0,sp,48
    2ea4:	84aa                	mv	s1,a0
  pid = fork();
    2ea6:	00002097          	auipc	ra,0x2
    2eaa:	768080e7          	jalr	1896(ra) # 560e <fork>
  if(pid < 0){
    2eae:	04054663          	bltz	a0,2efa <exitiputtest+0x60>
  if(pid == 0){
    2eb2:	ed45                	bnez	a0,2f6a <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2eb4:	00004517          	auipc	a0,0x4
    2eb8:	1d450513          	addi	a0,a0,468 # 7088 <statistics+0x1558>
    2ebc:	00002097          	auipc	ra,0x2
    2ec0:	7c2080e7          	jalr	1986(ra) # 567e <mkdir>
    2ec4:	04054963          	bltz	a0,2f16 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2ec8:	00004517          	auipc	a0,0x4
    2ecc:	1c050513          	addi	a0,a0,448 # 7088 <statistics+0x1558>
    2ed0:	00002097          	auipc	ra,0x2
    2ed4:	7b6080e7          	jalr	1974(ra) # 5686 <chdir>
    2ed8:	04054d63          	bltz	a0,2f32 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2edc:	00004517          	auipc	a0,0x4
    2ee0:	1ec50513          	addi	a0,a0,492 # 70c8 <statistics+0x1598>
    2ee4:	00002097          	auipc	ra,0x2
    2ee8:	782080e7          	jalr	1922(ra) # 5666 <unlink>
    2eec:	06054163          	bltz	a0,2f4e <exitiputtest+0xb4>
    exit(0);
    2ef0:	4501                	li	a0,0
    2ef2:	00002097          	auipc	ra,0x2
    2ef6:	724080e7          	jalr	1828(ra) # 5616 <exit>
    printf("%s: fork failed\n", s);
    2efa:	85a6                	mv	a1,s1
    2efc:	00004517          	auipc	a0,0x4
    2f00:	84c50513          	addi	a0,a0,-1972 # 6748 <statistics+0xc18>
    2f04:	00003097          	auipc	ra,0x3
    2f08:	a8a080e7          	jalr	-1398(ra) # 598e <printf>
    exit(1);
    2f0c:	4505                	li	a0,1
    2f0e:	00002097          	auipc	ra,0x2
    2f12:	708080e7          	jalr	1800(ra) # 5616 <exit>
      printf("%s: mkdir failed\n", s);
    2f16:	85a6                	mv	a1,s1
    2f18:	00004517          	auipc	a0,0x4
    2f1c:	17850513          	addi	a0,a0,376 # 7090 <statistics+0x1560>
    2f20:	00003097          	auipc	ra,0x3
    2f24:	a6e080e7          	jalr	-1426(ra) # 598e <printf>
      exit(1);
    2f28:	4505                	li	a0,1
    2f2a:	00002097          	auipc	ra,0x2
    2f2e:	6ec080e7          	jalr	1772(ra) # 5616 <exit>
      printf("%s: child chdir failed\n", s);
    2f32:	85a6                	mv	a1,s1
    2f34:	00004517          	auipc	a0,0x4
    2f38:	1e450513          	addi	a0,a0,484 # 7118 <statistics+0x15e8>
    2f3c:	00003097          	auipc	ra,0x3
    2f40:	a52080e7          	jalr	-1454(ra) # 598e <printf>
      exit(1);
    2f44:	4505                	li	a0,1
    2f46:	00002097          	auipc	ra,0x2
    2f4a:	6d0080e7          	jalr	1744(ra) # 5616 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2f4e:	85a6                	mv	a1,s1
    2f50:	00004517          	auipc	a0,0x4
    2f54:	18850513          	addi	a0,a0,392 # 70d8 <statistics+0x15a8>
    2f58:	00003097          	auipc	ra,0x3
    2f5c:	a36080e7          	jalr	-1482(ra) # 598e <printf>
      exit(1);
    2f60:	4505                	li	a0,1
    2f62:	00002097          	auipc	ra,0x2
    2f66:	6b4080e7          	jalr	1716(ra) # 5616 <exit>
  wait(&xstatus);
    2f6a:	fdc40513          	addi	a0,s0,-36
    2f6e:	00002097          	auipc	ra,0x2
    2f72:	6b0080e7          	jalr	1712(ra) # 561e <wait>
  exit(xstatus);
    2f76:	fdc42503          	lw	a0,-36(s0)
    2f7a:	00002097          	auipc	ra,0x2
    2f7e:	69c080e7          	jalr	1692(ra) # 5616 <exit>

0000000000002f82 <dirtest>:
{
    2f82:	1101                	addi	sp,sp,-32
    2f84:	ec06                	sd	ra,24(sp)
    2f86:	e822                	sd	s0,16(sp)
    2f88:	e426                	sd	s1,8(sp)
    2f8a:	1000                	addi	s0,sp,32
    2f8c:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2f8e:	00004517          	auipc	a0,0x4
    2f92:	1a250513          	addi	a0,a0,418 # 7130 <statistics+0x1600>
    2f96:	00002097          	auipc	ra,0x2
    2f9a:	6e8080e7          	jalr	1768(ra) # 567e <mkdir>
    2f9e:	04054563          	bltz	a0,2fe8 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2fa2:	00004517          	auipc	a0,0x4
    2fa6:	18e50513          	addi	a0,a0,398 # 7130 <statistics+0x1600>
    2faa:	00002097          	auipc	ra,0x2
    2fae:	6dc080e7          	jalr	1756(ra) # 5686 <chdir>
    2fb2:	04054963          	bltz	a0,3004 <dirtest+0x82>
  if(chdir("..") < 0){
    2fb6:	00004517          	auipc	a0,0x4
    2fba:	19a50513          	addi	a0,a0,410 # 7150 <statistics+0x1620>
    2fbe:	00002097          	auipc	ra,0x2
    2fc2:	6c8080e7          	jalr	1736(ra) # 5686 <chdir>
    2fc6:	04054d63          	bltz	a0,3020 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2fca:	00004517          	auipc	a0,0x4
    2fce:	16650513          	addi	a0,a0,358 # 7130 <statistics+0x1600>
    2fd2:	00002097          	auipc	ra,0x2
    2fd6:	694080e7          	jalr	1684(ra) # 5666 <unlink>
    2fda:	06054163          	bltz	a0,303c <dirtest+0xba>
}
    2fde:	60e2                	ld	ra,24(sp)
    2fe0:	6442                	ld	s0,16(sp)
    2fe2:	64a2                	ld	s1,8(sp)
    2fe4:	6105                	addi	sp,sp,32
    2fe6:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2fe8:	85a6                	mv	a1,s1
    2fea:	00004517          	auipc	a0,0x4
    2fee:	0a650513          	addi	a0,a0,166 # 7090 <statistics+0x1560>
    2ff2:	00003097          	auipc	ra,0x3
    2ff6:	99c080e7          	jalr	-1636(ra) # 598e <printf>
    exit(1);
    2ffa:	4505                	li	a0,1
    2ffc:	00002097          	auipc	ra,0x2
    3000:	61a080e7          	jalr	1562(ra) # 5616 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3004:	85a6                	mv	a1,s1
    3006:	00004517          	auipc	a0,0x4
    300a:	13250513          	addi	a0,a0,306 # 7138 <statistics+0x1608>
    300e:	00003097          	auipc	ra,0x3
    3012:	980080e7          	jalr	-1664(ra) # 598e <printf>
    exit(1);
    3016:	4505                	li	a0,1
    3018:	00002097          	auipc	ra,0x2
    301c:	5fe080e7          	jalr	1534(ra) # 5616 <exit>
    printf("%s: chdir .. failed\n", s);
    3020:	85a6                	mv	a1,s1
    3022:	00004517          	auipc	a0,0x4
    3026:	13650513          	addi	a0,a0,310 # 7158 <statistics+0x1628>
    302a:	00003097          	auipc	ra,0x3
    302e:	964080e7          	jalr	-1692(ra) # 598e <printf>
    exit(1);
    3032:	4505                	li	a0,1
    3034:	00002097          	auipc	ra,0x2
    3038:	5e2080e7          	jalr	1506(ra) # 5616 <exit>
    printf("%s: unlink dir0 failed\n", s);
    303c:	85a6                	mv	a1,s1
    303e:	00004517          	auipc	a0,0x4
    3042:	13250513          	addi	a0,a0,306 # 7170 <statistics+0x1640>
    3046:	00003097          	auipc	ra,0x3
    304a:	948080e7          	jalr	-1720(ra) # 598e <printf>
    exit(1);
    304e:	4505                	li	a0,1
    3050:	00002097          	auipc	ra,0x2
    3054:	5c6080e7          	jalr	1478(ra) # 5616 <exit>

0000000000003058 <subdir>:
{
    3058:	1101                	addi	sp,sp,-32
    305a:	ec06                	sd	ra,24(sp)
    305c:	e822                	sd	s0,16(sp)
    305e:	e426                	sd	s1,8(sp)
    3060:	e04a                	sd	s2,0(sp)
    3062:	1000                	addi	s0,sp,32
    3064:	892a                	mv	s2,a0
  unlink("ff");
    3066:	00004517          	auipc	a0,0x4
    306a:	25250513          	addi	a0,a0,594 # 72b8 <statistics+0x1788>
    306e:	00002097          	auipc	ra,0x2
    3072:	5f8080e7          	jalr	1528(ra) # 5666 <unlink>
  if(mkdir("dd") != 0){
    3076:	00004517          	auipc	a0,0x4
    307a:	11250513          	addi	a0,a0,274 # 7188 <statistics+0x1658>
    307e:	00002097          	auipc	ra,0x2
    3082:	600080e7          	jalr	1536(ra) # 567e <mkdir>
    3086:	38051663          	bnez	a0,3412 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    308a:	20200593          	li	a1,514
    308e:	00004517          	auipc	a0,0x4
    3092:	11a50513          	addi	a0,a0,282 # 71a8 <statistics+0x1678>
    3096:	00002097          	auipc	ra,0x2
    309a:	5c0080e7          	jalr	1472(ra) # 5656 <open>
    309e:	84aa                	mv	s1,a0
  if(fd < 0){
    30a0:	38054763          	bltz	a0,342e <subdir+0x3d6>
  write(fd, "ff", 2);
    30a4:	4609                	li	a2,2
    30a6:	00004597          	auipc	a1,0x4
    30aa:	21258593          	addi	a1,a1,530 # 72b8 <statistics+0x1788>
    30ae:	00002097          	auipc	ra,0x2
    30b2:	588080e7          	jalr	1416(ra) # 5636 <write>
  close(fd);
    30b6:	8526                	mv	a0,s1
    30b8:	00002097          	auipc	ra,0x2
    30bc:	586080e7          	jalr	1414(ra) # 563e <close>
  if(unlink("dd") >= 0){
    30c0:	00004517          	auipc	a0,0x4
    30c4:	0c850513          	addi	a0,a0,200 # 7188 <statistics+0x1658>
    30c8:	00002097          	auipc	ra,0x2
    30cc:	59e080e7          	jalr	1438(ra) # 5666 <unlink>
    30d0:	36055d63          	bgez	a0,344a <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    30d4:	00004517          	auipc	a0,0x4
    30d8:	12c50513          	addi	a0,a0,300 # 7200 <statistics+0x16d0>
    30dc:	00002097          	auipc	ra,0x2
    30e0:	5a2080e7          	jalr	1442(ra) # 567e <mkdir>
    30e4:	38051163          	bnez	a0,3466 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    30e8:	20200593          	li	a1,514
    30ec:	00004517          	auipc	a0,0x4
    30f0:	13c50513          	addi	a0,a0,316 # 7228 <statistics+0x16f8>
    30f4:	00002097          	auipc	ra,0x2
    30f8:	562080e7          	jalr	1378(ra) # 5656 <open>
    30fc:	84aa                	mv	s1,a0
  if(fd < 0){
    30fe:	38054263          	bltz	a0,3482 <subdir+0x42a>
  write(fd, "FF", 2);
    3102:	4609                	li	a2,2
    3104:	00004597          	auipc	a1,0x4
    3108:	15458593          	addi	a1,a1,340 # 7258 <statistics+0x1728>
    310c:	00002097          	auipc	ra,0x2
    3110:	52a080e7          	jalr	1322(ra) # 5636 <write>
  close(fd);
    3114:	8526                	mv	a0,s1
    3116:	00002097          	auipc	ra,0x2
    311a:	528080e7          	jalr	1320(ra) # 563e <close>
  fd = open("dd/dd/../ff", 0);
    311e:	4581                	li	a1,0
    3120:	00004517          	auipc	a0,0x4
    3124:	14050513          	addi	a0,a0,320 # 7260 <statistics+0x1730>
    3128:	00002097          	auipc	ra,0x2
    312c:	52e080e7          	jalr	1326(ra) # 5656 <open>
    3130:	84aa                	mv	s1,a0
  if(fd < 0){
    3132:	36054663          	bltz	a0,349e <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3136:	660d                	lui	a2,0x3
    3138:	00009597          	auipc	a1,0x9
    313c:	a1858593          	addi	a1,a1,-1512 # bb50 <buf>
    3140:	00002097          	auipc	ra,0x2
    3144:	4ee080e7          	jalr	1262(ra) # 562e <read>
  if(cc != 2 || buf[0] != 'f'){
    3148:	4789                	li	a5,2
    314a:	36f51863          	bne	a0,a5,34ba <subdir+0x462>
    314e:	00009717          	auipc	a4,0x9
    3152:	a0274703          	lbu	a4,-1534(a4) # bb50 <buf>
    3156:	06600793          	li	a5,102
    315a:	36f71063          	bne	a4,a5,34ba <subdir+0x462>
  close(fd);
    315e:	8526                	mv	a0,s1
    3160:	00002097          	auipc	ra,0x2
    3164:	4de080e7          	jalr	1246(ra) # 563e <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3168:	00004597          	auipc	a1,0x4
    316c:	14858593          	addi	a1,a1,328 # 72b0 <statistics+0x1780>
    3170:	00004517          	auipc	a0,0x4
    3174:	0b850513          	addi	a0,a0,184 # 7228 <statistics+0x16f8>
    3178:	00002097          	auipc	ra,0x2
    317c:	4fe080e7          	jalr	1278(ra) # 5676 <link>
    3180:	34051b63          	bnez	a0,34d6 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3184:	00004517          	auipc	a0,0x4
    3188:	0a450513          	addi	a0,a0,164 # 7228 <statistics+0x16f8>
    318c:	00002097          	auipc	ra,0x2
    3190:	4da080e7          	jalr	1242(ra) # 5666 <unlink>
    3194:	34051f63          	bnez	a0,34f2 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3198:	4581                	li	a1,0
    319a:	00004517          	auipc	a0,0x4
    319e:	08e50513          	addi	a0,a0,142 # 7228 <statistics+0x16f8>
    31a2:	00002097          	auipc	ra,0x2
    31a6:	4b4080e7          	jalr	1204(ra) # 5656 <open>
    31aa:	36055263          	bgez	a0,350e <subdir+0x4b6>
  if(chdir("dd") != 0){
    31ae:	00004517          	auipc	a0,0x4
    31b2:	fda50513          	addi	a0,a0,-38 # 7188 <statistics+0x1658>
    31b6:	00002097          	auipc	ra,0x2
    31ba:	4d0080e7          	jalr	1232(ra) # 5686 <chdir>
    31be:	36051663          	bnez	a0,352a <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    31c2:	00004517          	auipc	a0,0x4
    31c6:	18650513          	addi	a0,a0,390 # 7348 <statistics+0x1818>
    31ca:	00002097          	auipc	ra,0x2
    31ce:	4bc080e7          	jalr	1212(ra) # 5686 <chdir>
    31d2:	36051a63          	bnez	a0,3546 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    31d6:	00004517          	auipc	a0,0x4
    31da:	1a250513          	addi	a0,a0,418 # 7378 <statistics+0x1848>
    31de:	00002097          	auipc	ra,0x2
    31e2:	4a8080e7          	jalr	1192(ra) # 5686 <chdir>
    31e6:	36051e63          	bnez	a0,3562 <subdir+0x50a>
  if(chdir("./..") != 0){
    31ea:	00004517          	auipc	a0,0x4
    31ee:	1be50513          	addi	a0,a0,446 # 73a8 <statistics+0x1878>
    31f2:	00002097          	auipc	ra,0x2
    31f6:	494080e7          	jalr	1172(ra) # 5686 <chdir>
    31fa:	38051263          	bnez	a0,357e <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    31fe:	4581                	li	a1,0
    3200:	00004517          	auipc	a0,0x4
    3204:	0b050513          	addi	a0,a0,176 # 72b0 <statistics+0x1780>
    3208:	00002097          	auipc	ra,0x2
    320c:	44e080e7          	jalr	1102(ra) # 5656 <open>
    3210:	84aa                	mv	s1,a0
  if(fd < 0){
    3212:	38054463          	bltz	a0,359a <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3216:	660d                	lui	a2,0x3
    3218:	00009597          	auipc	a1,0x9
    321c:	93858593          	addi	a1,a1,-1736 # bb50 <buf>
    3220:	00002097          	auipc	ra,0x2
    3224:	40e080e7          	jalr	1038(ra) # 562e <read>
    3228:	4789                	li	a5,2
    322a:	38f51663          	bne	a0,a5,35b6 <subdir+0x55e>
  close(fd);
    322e:	8526                	mv	a0,s1
    3230:	00002097          	auipc	ra,0x2
    3234:	40e080e7          	jalr	1038(ra) # 563e <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3238:	4581                	li	a1,0
    323a:	00004517          	auipc	a0,0x4
    323e:	fee50513          	addi	a0,a0,-18 # 7228 <statistics+0x16f8>
    3242:	00002097          	auipc	ra,0x2
    3246:	414080e7          	jalr	1044(ra) # 5656 <open>
    324a:	38055463          	bgez	a0,35d2 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    324e:	20200593          	li	a1,514
    3252:	00004517          	auipc	a0,0x4
    3256:	1e650513          	addi	a0,a0,486 # 7438 <statistics+0x1908>
    325a:	00002097          	auipc	ra,0x2
    325e:	3fc080e7          	jalr	1020(ra) # 5656 <open>
    3262:	38055663          	bgez	a0,35ee <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3266:	20200593          	li	a1,514
    326a:	00004517          	auipc	a0,0x4
    326e:	1fe50513          	addi	a0,a0,510 # 7468 <statistics+0x1938>
    3272:	00002097          	auipc	ra,0x2
    3276:	3e4080e7          	jalr	996(ra) # 5656 <open>
    327a:	38055863          	bgez	a0,360a <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    327e:	20000593          	li	a1,512
    3282:	00004517          	auipc	a0,0x4
    3286:	f0650513          	addi	a0,a0,-250 # 7188 <statistics+0x1658>
    328a:	00002097          	auipc	ra,0x2
    328e:	3cc080e7          	jalr	972(ra) # 5656 <open>
    3292:	38055a63          	bgez	a0,3626 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3296:	4589                	li	a1,2
    3298:	00004517          	auipc	a0,0x4
    329c:	ef050513          	addi	a0,a0,-272 # 7188 <statistics+0x1658>
    32a0:	00002097          	auipc	ra,0x2
    32a4:	3b6080e7          	jalr	950(ra) # 5656 <open>
    32a8:	38055d63          	bgez	a0,3642 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    32ac:	4585                	li	a1,1
    32ae:	00004517          	auipc	a0,0x4
    32b2:	eda50513          	addi	a0,a0,-294 # 7188 <statistics+0x1658>
    32b6:	00002097          	auipc	ra,0x2
    32ba:	3a0080e7          	jalr	928(ra) # 5656 <open>
    32be:	3a055063          	bgez	a0,365e <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    32c2:	00004597          	auipc	a1,0x4
    32c6:	23658593          	addi	a1,a1,566 # 74f8 <statistics+0x19c8>
    32ca:	00004517          	auipc	a0,0x4
    32ce:	16e50513          	addi	a0,a0,366 # 7438 <statistics+0x1908>
    32d2:	00002097          	auipc	ra,0x2
    32d6:	3a4080e7          	jalr	932(ra) # 5676 <link>
    32da:	3a050063          	beqz	a0,367a <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    32de:	00004597          	auipc	a1,0x4
    32e2:	21a58593          	addi	a1,a1,538 # 74f8 <statistics+0x19c8>
    32e6:	00004517          	auipc	a0,0x4
    32ea:	18250513          	addi	a0,a0,386 # 7468 <statistics+0x1938>
    32ee:	00002097          	auipc	ra,0x2
    32f2:	388080e7          	jalr	904(ra) # 5676 <link>
    32f6:	3a050063          	beqz	a0,3696 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    32fa:	00004597          	auipc	a1,0x4
    32fe:	fb658593          	addi	a1,a1,-74 # 72b0 <statistics+0x1780>
    3302:	00004517          	auipc	a0,0x4
    3306:	ea650513          	addi	a0,a0,-346 # 71a8 <statistics+0x1678>
    330a:	00002097          	auipc	ra,0x2
    330e:	36c080e7          	jalr	876(ra) # 5676 <link>
    3312:	3a050063          	beqz	a0,36b2 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3316:	00004517          	auipc	a0,0x4
    331a:	12250513          	addi	a0,a0,290 # 7438 <statistics+0x1908>
    331e:	00002097          	auipc	ra,0x2
    3322:	360080e7          	jalr	864(ra) # 567e <mkdir>
    3326:	3a050463          	beqz	a0,36ce <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    332a:	00004517          	auipc	a0,0x4
    332e:	13e50513          	addi	a0,a0,318 # 7468 <statistics+0x1938>
    3332:	00002097          	auipc	ra,0x2
    3336:	34c080e7          	jalr	844(ra) # 567e <mkdir>
    333a:	3a050863          	beqz	a0,36ea <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    333e:	00004517          	auipc	a0,0x4
    3342:	f7250513          	addi	a0,a0,-142 # 72b0 <statistics+0x1780>
    3346:	00002097          	auipc	ra,0x2
    334a:	338080e7          	jalr	824(ra) # 567e <mkdir>
    334e:	3a050c63          	beqz	a0,3706 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3352:	00004517          	auipc	a0,0x4
    3356:	11650513          	addi	a0,a0,278 # 7468 <statistics+0x1938>
    335a:	00002097          	auipc	ra,0x2
    335e:	30c080e7          	jalr	780(ra) # 5666 <unlink>
    3362:	3c050063          	beqz	a0,3722 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3366:	00004517          	auipc	a0,0x4
    336a:	0d250513          	addi	a0,a0,210 # 7438 <statistics+0x1908>
    336e:	00002097          	auipc	ra,0x2
    3372:	2f8080e7          	jalr	760(ra) # 5666 <unlink>
    3376:	3c050463          	beqz	a0,373e <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    337a:	00004517          	auipc	a0,0x4
    337e:	e2e50513          	addi	a0,a0,-466 # 71a8 <statistics+0x1678>
    3382:	00002097          	auipc	ra,0x2
    3386:	304080e7          	jalr	772(ra) # 5686 <chdir>
    338a:	3c050863          	beqz	a0,375a <subdir+0x702>
  if(chdir("dd/xx") == 0){
    338e:	00004517          	auipc	a0,0x4
    3392:	2ba50513          	addi	a0,a0,698 # 7648 <statistics+0x1b18>
    3396:	00002097          	auipc	ra,0x2
    339a:	2f0080e7          	jalr	752(ra) # 5686 <chdir>
    339e:	3c050c63          	beqz	a0,3776 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    33a2:	00004517          	auipc	a0,0x4
    33a6:	f0e50513          	addi	a0,a0,-242 # 72b0 <statistics+0x1780>
    33aa:	00002097          	auipc	ra,0x2
    33ae:	2bc080e7          	jalr	700(ra) # 5666 <unlink>
    33b2:	3e051063          	bnez	a0,3792 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    33b6:	00004517          	auipc	a0,0x4
    33ba:	df250513          	addi	a0,a0,-526 # 71a8 <statistics+0x1678>
    33be:	00002097          	auipc	ra,0x2
    33c2:	2a8080e7          	jalr	680(ra) # 5666 <unlink>
    33c6:	3e051463          	bnez	a0,37ae <subdir+0x756>
  if(unlink("dd") == 0){
    33ca:	00004517          	auipc	a0,0x4
    33ce:	dbe50513          	addi	a0,a0,-578 # 7188 <statistics+0x1658>
    33d2:	00002097          	auipc	ra,0x2
    33d6:	294080e7          	jalr	660(ra) # 5666 <unlink>
    33da:	3e050863          	beqz	a0,37ca <subdir+0x772>
  if(unlink("dd/dd") < 0){
    33de:	00004517          	auipc	a0,0x4
    33e2:	2da50513          	addi	a0,a0,730 # 76b8 <statistics+0x1b88>
    33e6:	00002097          	auipc	ra,0x2
    33ea:	280080e7          	jalr	640(ra) # 5666 <unlink>
    33ee:	3e054c63          	bltz	a0,37e6 <subdir+0x78e>
  if(unlink("dd") < 0){
    33f2:	00004517          	auipc	a0,0x4
    33f6:	d9650513          	addi	a0,a0,-618 # 7188 <statistics+0x1658>
    33fa:	00002097          	auipc	ra,0x2
    33fe:	26c080e7          	jalr	620(ra) # 5666 <unlink>
    3402:	40054063          	bltz	a0,3802 <subdir+0x7aa>
}
    3406:	60e2                	ld	ra,24(sp)
    3408:	6442                	ld	s0,16(sp)
    340a:	64a2                	ld	s1,8(sp)
    340c:	6902                	ld	s2,0(sp)
    340e:	6105                	addi	sp,sp,32
    3410:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3412:	85ca                	mv	a1,s2
    3414:	00004517          	auipc	a0,0x4
    3418:	d7c50513          	addi	a0,a0,-644 # 7190 <statistics+0x1660>
    341c:	00002097          	auipc	ra,0x2
    3420:	572080e7          	jalr	1394(ra) # 598e <printf>
    exit(1);
    3424:	4505                	li	a0,1
    3426:	00002097          	auipc	ra,0x2
    342a:	1f0080e7          	jalr	496(ra) # 5616 <exit>
    printf("%s: create dd/ff failed\n", s);
    342e:	85ca                	mv	a1,s2
    3430:	00004517          	auipc	a0,0x4
    3434:	d8050513          	addi	a0,a0,-640 # 71b0 <statistics+0x1680>
    3438:	00002097          	auipc	ra,0x2
    343c:	556080e7          	jalr	1366(ra) # 598e <printf>
    exit(1);
    3440:	4505                	li	a0,1
    3442:	00002097          	auipc	ra,0x2
    3446:	1d4080e7          	jalr	468(ra) # 5616 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    344a:	85ca                	mv	a1,s2
    344c:	00004517          	auipc	a0,0x4
    3450:	d8450513          	addi	a0,a0,-636 # 71d0 <statistics+0x16a0>
    3454:	00002097          	auipc	ra,0x2
    3458:	53a080e7          	jalr	1338(ra) # 598e <printf>
    exit(1);
    345c:	4505                	li	a0,1
    345e:	00002097          	auipc	ra,0x2
    3462:	1b8080e7          	jalr	440(ra) # 5616 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3466:	85ca                	mv	a1,s2
    3468:	00004517          	auipc	a0,0x4
    346c:	da050513          	addi	a0,a0,-608 # 7208 <statistics+0x16d8>
    3470:	00002097          	auipc	ra,0x2
    3474:	51e080e7          	jalr	1310(ra) # 598e <printf>
    exit(1);
    3478:	4505                	li	a0,1
    347a:	00002097          	auipc	ra,0x2
    347e:	19c080e7          	jalr	412(ra) # 5616 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3482:	85ca                	mv	a1,s2
    3484:	00004517          	auipc	a0,0x4
    3488:	db450513          	addi	a0,a0,-588 # 7238 <statistics+0x1708>
    348c:	00002097          	auipc	ra,0x2
    3490:	502080e7          	jalr	1282(ra) # 598e <printf>
    exit(1);
    3494:	4505                	li	a0,1
    3496:	00002097          	auipc	ra,0x2
    349a:	180080e7          	jalr	384(ra) # 5616 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    349e:	85ca                	mv	a1,s2
    34a0:	00004517          	auipc	a0,0x4
    34a4:	dd050513          	addi	a0,a0,-560 # 7270 <statistics+0x1740>
    34a8:	00002097          	auipc	ra,0x2
    34ac:	4e6080e7          	jalr	1254(ra) # 598e <printf>
    exit(1);
    34b0:	4505                	li	a0,1
    34b2:	00002097          	auipc	ra,0x2
    34b6:	164080e7          	jalr	356(ra) # 5616 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    34ba:	85ca                	mv	a1,s2
    34bc:	00004517          	auipc	a0,0x4
    34c0:	dd450513          	addi	a0,a0,-556 # 7290 <statistics+0x1760>
    34c4:	00002097          	auipc	ra,0x2
    34c8:	4ca080e7          	jalr	1226(ra) # 598e <printf>
    exit(1);
    34cc:	4505                	li	a0,1
    34ce:	00002097          	auipc	ra,0x2
    34d2:	148080e7          	jalr	328(ra) # 5616 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    34d6:	85ca                	mv	a1,s2
    34d8:	00004517          	auipc	a0,0x4
    34dc:	de850513          	addi	a0,a0,-536 # 72c0 <statistics+0x1790>
    34e0:	00002097          	auipc	ra,0x2
    34e4:	4ae080e7          	jalr	1198(ra) # 598e <printf>
    exit(1);
    34e8:	4505                	li	a0,1
    34ea:	00002097          	auipc	ra,0x2
    34ee:	12c080e7          	jalr	300(ra) # 5616 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    34f2:	85ca                	mv	a1,s2
    34f4:	00004517          	auipc	a0,0x4
    34f8:	df450513          	addi	a0,a0,-524 # 72e8 <statistics+0x17b8>
    34fc:	00002097          	auipc	ra,0x2
    3500:	492080e7          	jalr	1170(ra) # 598e <printf>
    exit(1);
    3504:	4505                	li	a0,1
    3506:	00002097          	auipc	ra,0x2
    350a:	110080e7          	jalr	272(ra) # 5616 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    350e:	85ca                	mv	a1,s2
    3510:	00004517          	auipc	a0,0x4
    3514:	df850513          	addi	a0,a0,-520 # 7308 <statistics+0x17d8>
    3518:	00002097          	auipc	ra,0x2
    351c:	476080e7          	jalr	1142(ra) # 598e <printf>
    exit(1);
    3520:	4505                	li	a0,1
    3522:	00002097          	auipc	ra,0x2
    3526:	0f4080e7          	jalr	244(ra) # 5616 <exit>
    printf("%s: chdir dd failed\n", s);
    352a:	85ca                	mv	a1,s2
    352c:	00004517          	auipc	a0,0x4
    3530:	e0450513          	addi	a0,a0,-508 # 7330 <statistics+0x1800>
    3534:	00002097          	auipc	ra,0x2
    3538:	45a080e7          	jalr	1114(ra) # 598e <printf>
    exit(1);
    353c:	4505                	li	a0,1
    353e:	00002097          	auipc	ra,0x2
    3542:	0d8080e7          	jalr	216(ra) # 5616 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3546:	85ca                	mv	a1,s2
    3548:	00004517          	auipc	a0,0x4
    354c:	e1050513          	addi	a0,a0,-496 # 7358 <statistics+0x1828>
    3550:	00002097          	auipc	ra,0x2
    3554:	43e080e7          	jalr	1086(ra) # 598e <printf>
    exit(1);
    3558:	4505                	li	a0,1
    355a:	00002097          	auipc	ra,0x2
    355e:	0bc080e7          	jalr	188(ra) # 5616 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3562:	85ca                	mv	a1,s2
    3564:	00004517          	auipc	a0,0x4
    3568:	e2450513          	addi	a0,a0,-476 # 7388 <statistics+0x1858>
    356c:	00002097          	auipc	ra,0x2
    3570:	422080e7          	jalr	1058(ra) # 598e <printf>
    exit(1);
    3574:	4505                	li	a0,1
    3576:	00002097          	auipc	ra,0x2
    357a:	0a0080e7          	jalr	160(ra) # 5616 <exit>
    printf("%s: chdir ./.. failed\n", s);
    357e:	85ca                	mv	a1,s2
    3580:	00004517          	auipc	a0,0x4
    3584:	e3050513          	addi	a0,a0,-464 # 73b0 <statistics+0x1880>
    3588:	00002097          	auipc	ra,0x2
    358c:	406080e7          	jalr	1030(ra) # 598e <printf>
    exit(1);
    3590:	4505                	li	a0,1
    3592:	00002097          	auipc	ra,0x2
    3596:	084080e7          	jalr	132(ra) # 5616 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    359a:	85ca                	mv	a1,s2
    359c:	00004517          	auipc	a0,0x4
    35a0:	e2c50513          	addi	a0,a0,-468 # 73c8 <statistics+0x1898>
    35a4:	00002097          	auipc	ra,0x2
    35a8:	3ea080e7          	jalr	1002(ra) # 598e <printf>
    exit(1);
    35ac:	4505                	li	a0,1
    35ae:	00002097          	auipc	ra,0x2
    35b2:	068080e7          	jalr	104(ra) # 5616 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    35b6:	85ca                	mv	a1,s2
    35b8:	00004517          	auipc	a0,0x4
    35bc:	e3050513          	addi	a0,a0,-464 # 73e8 <statistics+0x18b8>
    35c0:	00002097          	auipc	ra,0x2
    35c4:	3ce080e7          	jalr	974(ra) # 598e <printf>
    exit(1);
    35c8:	4505                	li	a0,1
    35ca:	00002097          	auipc	ra,0x2
    35ce:	04c080e7          	jalr	76(ra) # 5616 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    35d2:	85ca                	mv	a1,s2
    35d4:	00004517          	auipc	a0,0x4
    35d8:	e3450513          	addi	a0,a0,-460 # 7408 <statistics+0x18d8>
    35dc:	00002097          	auipc	ra,0x2
    35e0:	3b2080e7          	jalr	946(ra) # 598e <printf>
    exit(1);
    35e4:	4505                	li	a0,1
    35e6:	00002097          	auipc	ra,0x2
    35ea:	030080e7          	jalr	48(ra) # 5616 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    35ee:	85ca                	mv	a1,s2
    35f0:	00004517          	auipc	a0,0x4
    35f4:	e5850513          	addi	a0,a0,-424 # 7448 <statistics+0x1918>
    35f8:	00002097          	auipc	ra,0x2
    35fc:	396080e7          	jalr	918(ra) # 598e <printf>
    exit(1);
    3600:	4505                	li	a0,1
    3602:	00002097          	auipc	ra,0x2
    3606:	014080e7          	jalr	20(ra) # 5616 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    360a:	85ca                	mv	a1,s2
    360c:	00004517          	auipc	a0,0x4
    3610:	e6c50513          	addi	a0,a0,-404 # 7478 <statistics+0x1948>
    3614:	00002097          	auipc	ra,0x2
    3618:	37a080e7          	jalr	890(ra) # 598e <printf>
    exit(1);
    361c:	4505                	li	a0,1
    361e:	00002097          	auipc	ra,0x2
    3622:	ff8080e7          	jalr	-8(ra) # 5616 <exit>
    printf("%s: create dd succeeded!\n", s);
    3626:	85ca                	mv	a1,s2
    3628:	00004517          	auipc	a0,0x4
    362c:	e7050513          	addi	a0,a0,-400 # 7498 <statistics+0x1968>
    3630:	00002097          	auipc	ra,0x2
    3634:	35e080e7          	jalr	862(ra) # 598e <printf>
    exit(1);
    3638:	4505                	li	a0,1
    363a:	00002097          	auipc	ra,0x2
    363e:	fdc080e7          	jalr	-36(ra) # 5616 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3642:	85ca                	mv	a1,s2
    3644:	00004517          	auipc	a0,0x4
    3648:	e7450513          	addi	a0,a0,-396 # 74b8 <statistics+0x1988>
    364c:	00002097          	auipc	ra,0x2
    3650:	342080e7          	jalr	834(ra) # 598e <printf>
    exit(1);
    3654:	4505                	li	a0,1
    3656:	00002097          	auipc	ra,0x2
    365a:	fc0080e7          	jalr	-64(ra) # 5616 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    365e:	85ca                	mv	a1,s2
    3660:	00004517          	auipc	a0,0x4
    3664:	e7850513          	addi	a0,a0,-392 # 74d8 <statistics+0x19a8>
    3668:	00002097          	auipc	ra,0x2
    366c:	326080e7          	jalr	806(ra) # 598e <printf>
    exit(1);
    3670:	4505                	li	a0,1
    3672:	00002097          	auipc	ra,0x2
    3676:	fa4080e7          	jalr	-92(ra) # 5616 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    367a:	85ca                	mv	a1,s2
    367c:	00004517          	auipc	a0,0x4
    3680:	e8c50513          	addi	a0,a0,-372 # 7508 <statistics+0x19d8>
    3684:	00002097          	auipc	ra,0x2
    3688:	30a080e7          	jalr	778(ra) # 598e <printf>
    exit(1);
    368c:	4505                	li	a0,1
    368e:	00002097          	auipc	ra,0x2
    3692:	f88080e7          	jalr	-120(ra) # 5616 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3696:	85ca                	mv	a1,s2
    3698:	00004517          	auipc	a0,0x4
    369c:	e9850513          	addi	a0,a0,-360 # 7530 <statistics+0x1a00>
    36a0:	00002097          	auipc	ra,0x2
    36a4:	2ee080e7          	jalr	750(ra) # 598e <printf>
    exit(1);
    36a8:	4505                	li	a0,1
    36aa:	00002097          	auipc	ra,0x2
    36ae:	f6c080e7          	jalr	-148(ra) # 5616 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    36b2:	85ca                	mv	a1,s2
    36b4:	00004517          	auipc	a0,0x4
    36b8:	ea450513          	addi	a0,a0,-348 # 7558 <statistics+0x1a28>
    36bc:	00002097          	auipc	ra,0x2
    36c0:	2d2080e7          	jalr	722(ra) # 598e <printf>
    exit(1);
    36c4:	4505                	li	a0,1
    36c6:	00002097          	auipc	ra,0x2
    36ca:	f50080e7          	jalr	-176(ra) # 5616 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    36ce:	85ca                	mv	a1,s2
    36d0:	00004517          	auipc	a0,0x4
    36d4:	eb050513          	addi	a0,a0,-336 # 7580 <statistics+0x1a50>
    36d8:	00002097          	auipc	ra,0x2
    36dc:	2b6080e7          	jalr	694(ra) # 598e <printf>
    exit(1);
    36e0:	4505                	li	a0,1
    36e2:	00002097          	auipc	ra,0x2
    36e6:	f34080e7          	jalr	-204(ra) # 5616 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    36ea:	85ca                	mv	a1,s2
    36ec:	00004517          	auipc	a0,0x4
    36f0:	eb450513          	addi	a0,a0,-332 # 75a0 <statistics+0x1a70>
    36f4:	00002097          	auipc	ra,0x2
    36f8:	29a080e7          	jalr	666(ra) # 598e <printf>
    exit(1);
    36fc:	4505                	li	a0,1
    36fe:	00002097          	auipc	ra,0x2
    3702:	f18080e7          	jalr	-232(ra) # 5616 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3706:	85ca                	mv	a1,s2
    3708:	00004517          	auipc	a0,0x4
    370c:	eb850513          	addi	a0,a0,-328 # 75c0 <statistics+0x1a90>
    3710:	00002097          	auipc	ra,0x2
    3714:	27e080e7          	jalr	638(ra) # 598e <printf>
    exit(1);
    3718:	4505                	li	a0,1
    371a:	00002097          	auipc	ra,0x2
    371e:	efc080e7          	jalr	-260(ra) # 5616 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3722:	85ca                	mv	a1,s2
    3724:	00004517          	auipc	a0,0x4
    3728:	ec450513          	addi	a0,a0,-316 # 75e8 <statistics+0x1ab8>
    372c:	00002097          	auipc	ra,0x2
    3730:	262080e7          	jalr	610(ra) # 598e <printf>
    exit(1);
    3734:	4505                	li	a0,1
    3736:	00002097          	auipc	ra,0x2
    373a:	ee0080e7          	jalr	-288(ra) # 5616 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    373e:	85ca                	mv	a1,s2
    3740:	00004517          	auipc	a0,0x4
    3744:	ec850513          	addi	a0,a0,-312 # 7608 <statistics+0x1ad8>
    3748:	00002097          	auipc	ra,0x2
    374c:	246080e7          	jalr	582(ra) # 598e <printf>
    exit(1);
    3750:	4505                	li	a0,1
    3752:	00002097          	auipc	ra,0x2
    3756:	ec4080e7          	jalr	-316(ra) # 5616 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    375a:	85ca                	mv	a1,s2
    375c:	00004517          	auipc	a0,0x4
    3760:	ecc50513          	addi	a0,a0,-308 # 7628 <statistics+0x1af8>
    3764:	00002097          	auipc	ra,0x2
    3768:	22a080e7          	jalr	554(ra) # 598e <printf>
    exit(1);
    376c:	4505                	li	a0,1
    376e:	00002097          	auipc	ra,0x2
    3772:	ea8080e7          	jalr	-344(ra) # 5616 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3776:	85ca                	mv	a1,s2
    3778:	00004517          	auipc	a0,0x4
    377c:	ed850513          	addi	a0,a0,-296 # 7650 <statistics+0x1b20>
    3780:	00002097          	auipc	ra,0x2
    3784:	20e080e7          	jalr	526(ra) # 598e <printf>
    exit(1);
    3788:	4505                	li	a0,1
    378a:	00002097          	auipc	ra,0x2
    378e:	e8c080e7          	jalr	-372(ra) # 5616 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3792:	85ca                	mv	a1,s2
    3794:	00004517          	auipc	a0,0x4
    3798:	b5450513          	addi	a0,a0,-1196 # 72e8 <statistics+0x17b8>
    379c:	00002097          	auipc	ra,0x2
    37a0:	1f2080e7          	jalr	498(ra) # 598e <printf>
    exit(1);
    37a4:	4505                	li	a0,1
    37a6:	00002097          	auipc	ra,0x2
    37aa:	e70080e7          	jalr	-400(ra) # 5616 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    37ae:	85ca                	mv	a1,s2
    37b0:	00004517          	auipc	a0,0x4
    37b4:	ec050513          	addi	a0,a0,-320 # 7670 <statistics+0x1b40>
    37b8:	00002097          	auipc	ra,0x2
    37bc:	1d6080e7          	jalr	470(ra) # 598e <printf>
    exit(1);
    37c0:	4505                	li	a0,1
    37c2:	00002097          	auipc	ra,0x2
    37c6:	e54080e7          	jalr	-428(ra) # 5616 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    37ca:	85ca                	mv	a1,s2
    37cc:	00004517          	auipc	a0,0x4
    37d0:	ec450513          	addi	a0,a0,-316 # 7690 <statistics+0x1b60>
    37d4:	00002097          	auipc	ra,0x2
    37d8:	1ba080e7          	jalr	442(ra) # 598e <printf>
    exit(1);
    37dc:	4505                	li	a0,1
    37de:	00002097          	auipc	ra,0x2
    37e2:	e38080e7          	jalr	-456(ra) # 5616 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    37e6:	85ca                	mv	a1,s2
    37e8:	00004517          	auipc	a0,0x4
    37ec:	ed850513          	addi	a0,a0,-296 # 76c0 <statistics+0x1b90>
    37f0:	00002097          	auipc	ra,0x2
    37f4:	19e080e7          	jalr	414(ra) # 598e <printf>
    exit(1);
    37f8:	4505                	li	a0,1
    37fa:	00002097          	auipc	ra,0x2
    37fe:	e1c080e7          	jalr	-484(ra) # 5616 <exit>
    printf("%s: unlink dd failed\n", s);
    3802:	85ca                	mv	a1,s2
    3804:	00004517          	auipc	a0,0x4
    3808:	edc50513          	addi	a0,a0,-292 # 76e0 <statistics+0x1bb0>
    380c:	00002097          	auipc	ra,0x2
    3810:	182080e7          	jalr	386(ra) # 598e <printf>
    exit(1);
    3814:	4505                	li	a0,1
    3816:	00002097          	auipc	ra,0x2
    381a:	e00080e7          	jalr	-512(ra) # 5616 <exit>

000000000000381e <rmdot>:
{
    381e:	1101                	addi	sp,sp,-32
    3820:	ec06                	sd	ra,24(sp)
    3822:	e822                	sd	s0,16(sp)
    3824:	e426                	sd	s1,8(sp)
    3826:	1000                	addi	s0,sp,32
    3828:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    382a:	00004517          	auipc	a0,0x4
    382e:	ece50513          	addi	a0,a0,-306 # 76f8 <statistics+0x1bc8>
    3832:	00002097          	auipc	ra,0x2
    3836:	e4c080e7          	jalr	-436(ra) # 567e <mkdir>
    383a:	e549                	bnez	a0,38c4 <rmdot+0xa6>
  if(chdir("dots") != 0){
    383c:	00004517          	auipc	a0,0x4
    3840:	ebc50513          	addi	a0,a0,-324 # 76f8 <statistics+0x1bc8>
    3844:	00002097          	auipc	ra,0x2
    3848:	e42080e7          	jalr	-446(ra) # 5686 <chdir>
    384c:	e951                	bnez	a0,38e0 <rmdot+0xc2>
  if(unlink(".") == 0){
    384e:	00003517          	auipc	a0,0x3
    3852:	d5a50513          	addi	a0,a0,-678 # 65a8 <statistics+0xa78>
    3856:	00002097          	auipc	ra,0x2
    385a:	e10080e7          	jalr	-496(ra) # 5666 <unlink>
    385e:	cd59                	beqz	a0,38fc <rmdot+0xde>
  if(unlink("..") == 0){
    3860:	00004517          	auipc	a0,0x4
    3864:	8f050513          	addi	a0,a0,-1808 # 7150 <statistics+0x1620>
    3868:	00002097          	auipc	ra,0x2
    386c:	dfe080e7          	jalr	-514(ra) # 5666 <unlink>
    3870:	c545                	beqz	a0,3918 <rmdot+0xfa>
  if(chdir("/") != 0){
    3872:	00004517          	auipc	a0,0x4
    3876:	88650513          	addi	a0,a0,-1914 # 70f8 <statistics+0x15c8>
    387a:	00002097          	auipc	ra,0x2
    387e:	e0c080e7          	jalr	-500(ra) # 5686 <chdir>
    3882:	e94d                	bnez	a0,3934 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3884:	00004517          	auipc	a0,0x4
    3888:	edc50513          	addi	a0,a0,-292 # 7760 <statistics+0x1c30>
    388c:	00002097          	auipc	ra,0x2
    3890:	dda080e7          	jalr	-550(ra) # 5666 <unlink>
    3894:	cd55                	beqz	a0,3950 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3896:	00004517          	auipc	a0,0x4
    389a:	ef250513          	addi	a0,a0,-270 # 7788 <statistics+0x1c58>
    389e:	00002097          	auipc	ra,0x2
    38a2:	dc8080e7          	jalr	-568(ra) # 5666 <unlink>
    38a6:	c179                	beqz	a0,396c <rmdot+0x14e>
  if(unlink("dots") != 0){
    38a8:	00004517          	auipc	a0,0x4
    38ac:	e5050513          	addi	a0,a0,-432 # 76f8 <statistics+0x1bc8>
    38b0:	00002097          	auipc	ra,0x2
    38b4:	db6080e7          	jalr	-586(ra) # 5666 <unlink>
    38b8:	e961                	bnez	a0,3988 <rmdot+0x16a>
}
    38ba:	60e2                	ld	ra,24(sp)
    38bc:	6442                	ld	s0,16(sp)
    38be:	64a2                	ld	s1,8(sp)
    38c0:	6105                	addi	sp,sp,32
    38c2:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    38c4:	85a6                	mv	a1,s1
    38c6:	00004517          	auipc	a0,0x4
    38ca:	e3a50513          	addi	a0,a0,-454 # 7700 <statistics+0x1bd0>
    38ce:	00002097          	auipc	ra,0x2
    38d2:	0c0080e7          	jalr	192(ra) # 598e <printf>
    exit(1);
    38d6:	4505                	li	a0,1
    38d8:	00002097          	auipc	ra,0x2
    38dc:	d3e080e7          	jalr	-706(ra) # 5616 <exit>
    printf("%s: chdir dots failed\n", s);
    38e0:	85a6                	mv	a1,s1
    38e2:	00004517          	auipc	a0,0x4
    38e6:	e3650513          	addi	a0,a0,-458 # 7718 <statistics+0x1be8>
    38ea:	00002097          	auipc	ra,0x2
    38ee:	0a4080e7          	jalr	164(ra) # 598e <printf>
    exit(1);
    38f2:	4505                	li	a0,1
    38f4:	00002097          	auipc	ra,0x2
    38f8:	d22080e7          	jalr	-734(ra) # 5616 <exit>
    printf("%s: rm . worked!\n", s);
    38fc:	85a6                	mv	a1,s1
    38fe:	00004517          	auipc	a0,0x4
    3902:	e3250513          	addi	a0,a0,-462 # 7730 <statistics+0x1c00>
    3906:	00002097          	auipc	ra,0x2
    390a:	088080e7          	jalr	136(ra) # 598e <printf>
    exit(1);
    390e:	4505                	li	a0,1
    3910:	00002097          	auipc	ra,0x2
    3914:	d06080e7          	jalr	-762(ra) # 5616 <exit>
    printf("%s: rm .. worked!\n", s);
    3918:	85a6                	mv	a1,s1
    391a:	00004517          	auipc	a0,0x4
    391e:	e2e50513          	addi	a0,a0,-466 # 7748 <statistics+0x1c18>
    3922:	00002097          	auipc	ra,0x2
    3926:	06c080e7          	jalr	108(ra) # 598e <printf>
    exit(1);
    392a:	4505                	li	a0,1
    392c:	00002097          	auipc	ra,0x2
    3930:	cea080e7          	jalr	-790(ra) # 5616 <exit>
    printf("%s: chdir / failed\n", s);
    3934:	85a6                	mv	a1,s1
    3936:	00003517          	auipc	a0,0x3
    393a:	7ca50513          	addi	a0,a0,1994 # 7100 <statistics+0x15d0>
    393e:	00002097          	auipc	ra,0x2
    3942:	050080e7          	jalr	80(ra) # 598e <printf>
    exit(1);
    3946:	4505                	li	a0,1
    3948:	00002097          	auipc	ra,0x2
    394c:	cce080e7          	jalr	-818(ra) # 5616 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3950:	85a6                	mv	a1,s1
    3952:	00004517          	auipc	a0,0x4
    3956:	e1650513          	addi	a0,a0,-490 # 7768 <statistics+0x1c38>
    395a:	00002097          	auipc	ra,0x2
    395e:	034080e7          	jalr	52(ra) # 598e <printf>
    exit(1);
    3962:	4505                	li	a0,1
    3964:	00002097          	auipc	ra,0x2
    3968:	cb2080e7          	jalr	-846(ra) # 5616 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    396c:	85a6                	mv	a1,s1
    396e:	00004517          	auipc	a0,0x4
    3972:	e2250513          	addi	a0,a0,-478 # 7790 <statistics+0x1c60>
    3976:	00002097          	auipc	ra,0x2
    397a:	018080e7          	jalr	24(ra) # 598e <printf>
    exit(1);
    397e:	4505                	li	a0,1
    3980:	00002097          	auipc	ra,0x2
    3984:	c96080e7          	jalr	-874(ra) # 5616 <exit>
    printf("%s: unlink dots failed!\n", s);
    3988:	85a6                	mv	a1,s1
    398a:	00004517          	auipc	a0,0x4
    398e:	e2650513          	addi	a0,a0,-474 # 77b0 <statistics+0x1c80>
    3992:	00002097          	auipc	ra,0x2
    3996:	ffc080e7          	jalr	-4(ra) # 598e <printf>
    exit(1);
    399a:	4505                	li	a0,1
    399c:	00002097          	auipc	ra,0x2
    39a0:	c7a080e7          	jalr	-902(ra) # 5616 <exit>

00000000000039a4 <dirfile>:
{
    39a4:	1101                	addi	sp,sp,-32
    39a6:	ec06                	sd	ra,24(sp)
    39a8:	e822                	sd	s0,16(sp)
    39aa:	e426                	sd	s1,8(sp)
    39ac:	e04a                	sd	s2,0(sp)
    39ae:	1000                	addi	s0,sp,32
    39b0:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    39b2:	20000593          	li	a1,512
    39b6:	00002517          	auipc	a0,0x2
    39ba:	4fa50513          	addi	a0,a0,1274 # 5eb0 <statistics+0x380>
    39be:	00002097          	auipc	ra,0x2
    39c2:	c98080e7          	jalr	-872(ra) # 5656 <open>
  if(fd < 0){
    39c6:	0e054d63          	bltz	a0,3ac0 <dirfile+0x11c>
  close(fd);
    39ca:	00002097          	auipc	ra,0x2
    39ce:	c74080e7          	jalr	-908(ra) # 563e <close>
  if(chdir("dirfile") == 0){
    39d2:	00002517          	auipc	a0,0x2
    39d6:	4de50513          	addi	a0,a0,1246 # 5eb0 <statistics+0x380>
    39da:	00002097          	auipc	ra,0x2
    39de:	cac080e7          	jalr	-852(ra) # 5686 <chdir>
    39e2:	cd6d                	beqz	a0,3adc <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    39e4:	4581                	li	a1,0
    39e6:	00004517          	auipc	a0,0x4
    39ea:	e2a50513          	addi	a0,a0,-470 # 7810 <statistics+0x1ce0>
    39ee:	00002097          	auipc	ra,0x2
    39f2:	c68080e7          	jalr	-920(ra) # 5656 <open>
  if(fd >= 0){
    39f6:	10055163          	bgez	a0,3af8 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    39fa:	20000593          	li	a1,512
    39fe:	00004517          	auipc	a0,0x4
    3a02:	e1250513          	addi	a0,a0,-494 # 7810 <statistics+0x1ce0>
    3a06:	00002097          	auipc	ra,0x2
    3a0a:	c50080e7          	jalr	-944(ra) # 5656 <open>
  if(fd >= 0){
    3a0e:	10055363          	bgez	a0,3b14 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3a12:	00004517          	auipc	a0,0x4
    3a16:	dfe50513          	addi	a0,a0,-514 # 7810 <statistics+0x1ce0>
    3a1a:	00002097          	auipc	ra,0x2
    3a1e:	c64080e7          	jalr	-924(ra) # 567e <mkdir>
    3a22:	10050763          	beqz	a0,3b30 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3a26:	00004517          	auipc	a0,0x4
    3a2a:	dea50513          	addi	a0,a0,-534 # 7810 <statistics+0x1ce0>
    3a2e:	00002097          	auipc	ra,0x2
    3a32:	c38080e7          	jalr	-968(ra) # 5666 <unlink>
    3a36:	10050b63          	beqz	a0,3b4c <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3a3a:	00004597          	auipc	a1,0x4
    3a3e:	dd658593          	addi	a1,a1,-554 # 7810 <statistics+0x1ce0>
    3a42:	00002517          	auipc	a0,0x2
    3a46:	66650513          	addi	a0,a0,1638 # 60a8 <statistics+0x578>
    3a4a:	00002097          	auipc	ra,0x2
    3a4e:	c2c080e7          	jalr	-980(ra) # 5676 <link>
    3a52:	10050b63          	beqz	a0,3b68 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3a56:	00002517          	auipc	a0,0x2
    3a5a:	45a50513          	addi	a0,a0,1114 # 5eb0 <statistics+0x380>
    3a5e:	00002097          	auipc	ra,0x2
    3a62:	c08080e7          	jalr	-1016(ra) # 5666 <unlink>
    3a66:	10051f63          	bnez	a0,3b84 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3a6a:	4589                	li	a1,2
    3a6c:	00003517          	auipc	a0,0x3
    3a70:	b3c50513          	addi	a0,a0,-1220 # 65a8 <statistics+0xa78>
    3a74:	00002097          	auipc	ra,0x2
    3a78:	be2080e7          	jalr	-1054(ra) # 5656 <open>
  if(fd >= 0){
    3a7c:	12055263          	bgez	a0,3ba0 <dirfile+0x1fc>
  fd = open(".", 0);
    3a80:	4581                	li	a1,0
    3a82:	00003517          	auipc	a0,0x3
    3a86:	b2650513          	addi	a0,a0,-1242 # 65a8 <statistics+0xa78>
    3a8a:	00002097          	auipc	ra,0x2
    3a8e:	bcc080e7          	jalr	-1076(ra) # 5656 <open>
    3a92:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3a94:	4605                	li	a2,1
    3a96:	00002597          	auipc	a1,0x2
    3a9a:	4ea58593          	addi	a1,a1,1258 # 5f80 <statistics+0x450>
    3a9e:	00002097          	auipc	ra,0x2
    3aa2:	b98080e7          	jalr	-1128(ra) # 5636 <write>
    3aa6:	10a04b63          	bgtz	a0,3bbc <dirfile+0x218>
  close(fd);
    3aaa:	8526                	mv	a0,s1
    3aac:	00002097          	auipc	ra,0x2
    3ab0:	b92080e7          	jalr	-1134(ra) # 563e <close>
}
    3ab4:	60e2                	ld	ra,24(sp)
    3ab6:	6442                	ld	s0,16(sp)
    3ab8:	64a2                	ld	s1,8(sp)
    3aba:	6902                	ld	s2,0(sp)
    3abc:	6105                	addi	sp,sp,32
    3abe:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3ac0:	85ca                	mv	a1,s2
    3ac2:	00004517          	auipc	a0,0x4
    3ac6:	d0e50513          	addi	a0,a0,-754 # 77d0 <statistics+0x1ca0>
    3aca:	00002097          	auipc	ra,0x2
    3ace:	ec4080e7          	jalr	-316(ra) # 598e <printf>
    exit(1);
    3ad2:	4505                	li	a0,1
    3ad4:	00002097          	auipc	ra,0x2
    3ad8:	b42080e7          	jalr	-1214(ra) # 5616 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3adc:	85ca                	mv	a1,s2
    3ade:	00004517          	auipc	a0,0x4
    3ae2:	d1250513          	addi	a0,a0,-750 # 77f0 <statistics+0x1cc0>
    3ae6:	00002097          	auipc	ra,0x2
    3aea:	ea8080e7          	jalr	-344(ra) # 598e <printf>
    exit(1);
    3aee:	4505                	li	a0,1
    3af0:	00002097          	auipc	ra,0x2
    3af4:	b26080e7          	jalr	-1242(ra) # 5616 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3af8:	85ca                	mv	a1,s2
    3afa:	00004517          	auipc	a0,0x4
    3afe:	d2650513          	addi	a0,a0,-730 # 7820 <statistics+0x1cf0>
    3b02:	00002097          	auipc	ra,0x2
    3b06:	e8c080e7          	jalr	-372(ra) # 598e <printf>
    exit(1);
    3b0a:	4505                	li	a0,1
    3b0c:	00002097          	auipc	ra,0x2
    3b10:	b0a080e7          	jalr	-1270(ra) # 5616 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b14:	85ca                	mv	a1,s2
    3b16:	00004517          	auipc	a0,0x4
    3b1a:	d0a50513          	addi	a0,a0,-758 # 7820 <statistics+0x1cf0>
    3b1e:	00002097          	auipc	ra,0x2
    3b22:	e70080e7          	jalr	-400(ra) # 598e <printf>
    exit(1);
    3b26:	4505                	li	a0,1
    3b28:	00002097          	auipc	ra,0x2
    3b2c:	aee080e7          	jalr	-1298(ra) # 5616 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3b30:	85ca                	mv	a1,s2
    3b32:	00004517          	auipc	a0,0x4
    3b36:	d1650513          	addi	a0,a0,-746 # 7848 <statistics+0x1d18>
    3b3a:	00002097          	auipc	ra,0x2
    3b3e:	e54080e7          	jalr	-428(ra) # 598e <printf>
    exit(1);
    3b42:	4505                	li	a0,1
    3b44:	00002097          	auipc	ra,0x2
    3b48:	ad2080e7          	jalr	-1326(ra) # 5616 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3b4c:	85ca                	mv	a1,s2
    3b4e:	00004517          	auipc	a0,0x4
    3b52:	d2250513          	addi	a0,a0,-734 # 7870 <statistics+0x1d40>
    3b56:	00002097          	auipc	ra,0x2
    3b5a:	e38080e7          	jalr	-456(ra) # 598e <printf>
    exit(1);
    3b5e:	4505                	li	a0,1
    3b60:	00002097          	auipc	ra,0x2
    3b64:	ab6080e7          	jalr	-1354(ra) # 5616 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3b68:	85ca                	mv	a1,s2
    3b6a:	00004517          	auipc	a0,0x4
    3b6e:	d2e50513          	addi	a0,a0,-722 # 7898 <statistics+0x1d68>
    3b72:	00002097          	auipc	ra,0x2
    3b76:	e1c080e7          	jalr	-484(ra) # 598e <printf>
    exit(1);
    3b7a:	4505                	li	a0,1
    3b7c:	00002097          	auipc	ra,0x2
    3b80:	a9a080e7          	jalr	-1382(ra) # 5616 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3b84:	85ca                	mv	a1,s2
    3b86:	00004517          	auipc	a0,0x4
    3b8a:	d3a50513          	addi	a0,a0,-710 # 78c0 <statistics+0x1d90>
    3b8e:	00002097          	auipc	ra,0x2
    3b92:	e00080e7          	jalr	-512(ra) # 598e <printf>
    exit(1);
    3b96:	4505                	li	a0,1
    3b98:	00002097          	auipc	ra,0x2
    3b9c:	a7e080e7          	jalr	-1410(ra) # 5616 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3ba0:	85ca                	mv	a1,s2
    3ba2:	00004517          	auipc	a0,0x4
    3ba6:	d3e50513          	addi	a0,a0,-706 # 78e0 <statistics+0x1db0>
    3baa:	00002097          	auipc	ra,0x2
    3bae:	de4080e7          	jalr	-540(ra) # 598e <printf>
    exit(1);
    3bb2:	4505                	li	a0,1
    3bb4:	00002097          	auipc	ra,0x2
    3bb8:	a62080e7          	jalr	-1438(ra) # 5616 <exit>
    printf("%s: write . succeeded!\n", s);
    3bbc:	85ca                	mv	a1,s2
    3bbe:	00004517          	auipc	a0,0x4
    3bc2:	d4a50513          	addi	a0,a0,-694 # 7908 <statistics+0x1dd8>
    3bc6:	00002097          	auipc	ra,0x2
    3bca:	dc8080e7          	jalr	-568(ra) # 598e <printf>
    exit(1);
    3bce:	4505                	li	a0,1
    3bd0:	00002097          	auipc	ra,0x2
    3bd4:	a46080e7          	jalr	-1466(ra) # 5616 <exit>

0000000000003bd8 <iref>:
{
    3bd8:	7139                	addi	sp,sp,-64
    3bda:	fc06                	sd	ra,56(sp)
    3bdc:	f822                	sd	s0,48(sp)
    3bde:	f426                	sd	s1,40(sp)
    3be0:	f04a                	sd	s2,32(sp)
    3be2:	ec4e                	sd	s3,24(sp)
    3be4:	e852                	sd	s4,16(sp)
    3be6:	e456                	sd	s5,8(sp)
    3be8:	e05a                	sd	s6,0(sp)
    3bea:	0080                	addi	s0,sp,64
    3bec:	8b2a                	mv	s6,a0
    3bee:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3bf2:	00004a17          	auipc	s4,0x4
    3bf6:	d2ea0a13          	addi	s4,s4,-722 # 7920 <statistics+0x1df0>
    mkdir("");
    3bfa:	00004497          	auipc	s1,0x4
    3bfe:	83648493          	addi	s1,s1,-1994 # 7430 <statistics+0x1900>
    link("README", "");
    3c02:	00002a97          	auipc	s5,0x2
    3c06:	4a6a8a93          	addi	s5,s5,1190 # 60a8 <statistics+0x578>
    fd = open("xx", O_CREATE);
    3c0a:	00004997          	auipc	s3,0x4
    3c0e:	c0e98993          	addi	s3,s3,-1010 # 7818 <statistics+0x1ce8>
    3c12:	a891                	j	3c66 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3c14:	85da                	mv	a1,s6
    3c16:	00004517          	auipc	a0,0x4
    3c1a:	d1250513          	addi	a0,a0,-750 # 7928 <statistics+0x1df8>
    3c1e:	00002097          	auipc	ra,0x2
    3c22:	d70080e7          	jalr	-656(ra) # 598e <printf>
      exit(1);
    3c26:	4505                	li	a0,1
    3c28:	00002097          	auipc	ra,0x2
    3c2c:	9ee080e7          	jalr	-1554(ra) # 5616 <exit>
      printf("%s: chdir irefd failed\n", s);
    3c30:	85da                	mv	a1,s6
    3c32:	00004517          	auipc	a0,0x4
    3c36:	d0e50513          	addi	a0,a0,-754 # 7940 <statistics+0x1e10>
    3c3a:	00002097          	auipc	ra,0x2
    3c3e:	d54080e7          	jalr	-684(ra) # 598e <printf>
      exit(1);
    3c42:	4505                	li	a0,1
    3c44:	00002097          	auipc	ra,0x2
    3c48:	9d2080e7          	jalr	-1582(ra) # 5616 <exit>
      close(fd);
    3c4c:	00002097          	auipc	ra,0x2
    3c50:	9f2080e7          	jalr	-1550(ra) # 563e <close>
    3c54:	a889                	j	3ca6 <iref+0xce>
    unlink("xx");
    3c56:	854e                	mv	a0,s3
    3c58:	00002097          	auipc	ra,0x2
    3c5c:	a0e080e7          	jalr	-1522(ra) # 5666 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3c60:	397d                	addiw	s2,s2,-1
    3c62:	06090063          	beqz	s2,3cc2 <iref+0xea>
    if(mkdir("irefd") != 0){
    3c66:	8552                	mv	a0,s4
    3c68:	00002097          	auipc	ra,0x2
    3c6c:	a16080e7          	jalr	-1514(ra) # 567e <mkdir>
    3c70:	f155                	bnez	a0,3c14 <iref+0x3c>
    if(chdir("irefd") != 0){
    3c72:	8552                	mv	a0,s4
    3c74:	00002097          	auipc	ra,0x2
    3c78:	a12080e7          	jalr	-1518(ra) # 5686 <chdir>
    3c7c:	f955                	bnez	a0,3c30 <iref+0x58>
    mkdir("");
    3c7e:	8526                	mv	a0,s1
    3c80:	00002097          	auipc	ra,0x2
    3c84:	9fe080e7          	jalr	-1538(ra) # 567e <mkdir>
    link("README", "");
    3c88:	85a6                	mv	a1,s1
    3c8a:	8556                	mv	a0,s5
    3c8c:	00002097          	auipc	ra,0x2
    3c90:	9ea080e7          	jalr	-1558(ra) # 5676 <link>
    fd = open("", O_CREATE);
    3c94:	20000593          	li	a1,512
    3c98:	8526                	mv	a0,s1
    3c9a:	00002097          	auipc	ra,0x2
    3c9e:	9bc080e7          	jalr	-1604(ra) # 5656 <open>
    if(fd >= 0)
    3ca2:	fa0555e3          	bgez	a0,3c4c <iref+0x74>
    fd = open("xx", O_CREATE);
    3ca6:	20000593          	li	a1,512
    3caa:	854e                	mv	a0,s3
    3cac:	00002097          	auipc	ra,0x2
    3cb0:	9aa080e7          	jalr	-1622(ra) # 5656 <open>
    if(fd >= 0)
    3cb4:	fa0541e3          	bltz	a0,3c56 <iref+0x7e>
      close(fd);
    3cb8:	00002097          	auipc	ra,0x2
    3cbc:	986080e7          	jalr	-1658(ra) # 563e <close>
    3cc0:	bf59                	j	3c56 <iref+0x7e>
    3cc2:	03300493          	li	s1,51
    chdir("..");
    3cc6:	00003997          	auipc	s3,0x3
    3cca:	48a98993          	addi	s3,s3,1162 # 7150 <statistics+0x1620>
    unlink("irefd");
    3cce:	00004917          	auipc	s2,0x4
    3cd2:	c5290913          	addi	s2,s2,-942 # 7920 <statistics+0x1df0>
    chdir("..");
    3cd6:	854e                	mv	a0,s3
    3cd8:	00002097          	auipc	ra,0x2
    3cdc:	9ae080e7          	jalr	-1618(ra) # 5686 <chdir>
    unlink("irefd");
    3ce0:	854a                	mv	a0,s2
    3ce2:	00002097          	auipc	ra,0x2
    3ce6:	984080e7          	jalr	-1660(ra) # 5666 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3cea:	34fd                	addiw	s1,s1,-1
    3cec:	f4ed                	bnez	s1,3cd6 <iref+0xfe>
  chdir("/");
    3cee:	00003517          	auipc	a0,0x3
    3cf2:	40a50513          	addi	a0,a0,1034 # 70f8 <statistics+0x15c8>
    3cf6:	00002097          	auipc	ra,0x2
    3cfa:	990080e7          	jalr	-1648(ra) # 5686 <chdir>
}
    3cfe:	70e2                	ld	ra,56(sp)
    3d00:	7442                	ld	s0,48(sp)
    3d02:	74a2                	ld	s1,40(sp)
    3d04:	7902                	ld	s2,32(sp)
    3d06:	69e2                	ld	s3,24(sp)
    3d08:	6a42                	ld	s4,16(sp)
    3d0a:	6aa2                	ld	s5,8(sp)
    3d0c:	6b02                	ld	s6,0(sp)
    3d0e:	6121                	addi	sp,sp,64
    3d10:	8082                	ret

0000000000003d12 <openiputtest>:
{
    3d12:	7179                	addi	sp,sp,-48
    3d14:	f406                	sd	ra,40(sp)
    3d16:	f022                	sd	s0,32(sp)
    3d18:	ec26                	sd	s1,24(sp)
    3d1a:	1800                	addi	s0,sp,48
    3d1c:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3d1e:	00004517          	auipc	a0,0x4
    3d22:	c3a50513          	addi	a0,a0,-966 # 7958 <statistics+0x1e28>
    3d26:	00002097          	auipc	ra,0x2
    3d2a:	958080e7          	jalr	-1704(ra) # 567e <mkdir>
    3d2e:	04054263          	bltz	a0,3d72 <openiputtest+0x60>
  pid = fork();
    3d32:	00002097          	auipc	ra,0x2
    3d36:	8dc080e7          	jalr	-1828(ra) # 560e <fork>
  if(pid < 0){
    3d3a:	04054a63          	bltz	a0,3d8e <openiputtest+0x7c>
  if(pid == 0){
    3d3e:	e93d                	bnez	a0,3db4 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3d40:	4589                	li	a1,2
    3d42:	00004517          	auipc	a0,0x4
    3d46:	c1650513          	addi	a0,a0,-1002 # 7958 <statistics+0x1e28>
    3d4a:	00002097          	auipc	ra,0x2
    3d4e:	90c080e7          	jalr	-1780(ra) # 5656 <open>
    if(fd >= 0){
    3d52:	04054c63          	bltz	a0,3daa <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3d56:	85a6                	mv	a1,s1
    3d58:	00004517          	auipc	a0,0x4
    3d5c:	c2050513          	addi	a0,a0,-992 # 7978 <statistics+0x1e48>
    3d60:	00002097          	auipc	ra,0x2
    3d64:	c2e080e7          	jalr	-978(ra) # 598e <printf>
      exit(1);
    3d68:	4505                	li	a0,1
    3d6a:	00002097          	auipc	ra,0x2
    3d6e:	8ac080e7          	jalr	-1876(ra) # 5616 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3d72:	85a6                	mv	a1,s1
    3d74:	00004517          	auipc	a0,0x4
    3d78:	bec50513          	addi	a0,a0,-1044 # 7960 <statistics+0x1e30>
    3d7c:	00002097          	auipc	ra,0x2
    3d80:	c12080e7          	jalr	-1006(ra) # 598e <printf>
    exit(1);
    3d84:	4505                	li	a0,1
    3d86:	00002097          	auipc	ra,0x2
    3d8a:	890080e7          	jalr	-1904(ra) # 5616 <exit>
    printf("%s: fork failed\n", s);
    3d8e:	85a6                	mv	a1,s1
    3d90:	00003517          	auipc	a0,0x3
    3d94:	9b850513          	addi	a0,a0,-1608 # 6748 <statistics+0xc18>
    3d98:	00002097          	auipc	ra,0x2
    3d9c:	bf6080e7          	jalr	-1034(ra) # 598e <printf>
    exit(1);
    3da0:	4505                	li	a0,1
    3da2:	00002097          	auipc	ra,0x2
    3da6:	874080e7          	jalr	-1932(ra) # 5616 <exit>
    exit(0);
    3daa:	4501                	li	a0,0
    3dac:	00002097          	auipc	ra,0x2
    3db0:	86a080e7          	jalr	-1942(ra) # 5616 <exit>
  sleep(1);
    3db4:	4505                	li	a0,1
    3db6:	00002097          	auipc	ra,0x2
    3dba:	8f0080e7          	jalr	-1808(ra) # 56a6 <sleep>
  if(unlink("oidir") != 0){
    3dbe:	00004517          	auipc	a0,0x4
    3dc2:	b9a50513          	addi	a0,a0,-1126 # 7958 <statistics+0x1e28>
    3dc6:	00002097          	auipc	ra,0x2
    3dca:	8a0080e7          	jalr	-1888(ra) # 5666 <unlink>
    3dce:	cd19                	beqz	a0,3dec <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3dd0:	85a6                	mv	a1,s1
    3dd2:	00003517          	auipc	a0,0x3
    3dd6:	b6650513          	addi	a0,a0,-1178 # 6938 <statistics+0xe08>
    3dda:	00002097          	auipc	ra,0x2
    3dde:	bb4080e7          	jalr	-1100(ra) # 598e <printf>
    exit(1);
    3de2:	4505                	li	a0,1
    3de4:	00002097          	auipc	ra,0x2
    3de8:	832080e7          	jalr	-1998(ra) # 5616 <exit>
  wait(&xstatus);
    3dec:	fdc40513          	addi	a0,s0,-36
    3df0:	00002097          	auipc	ra,0x2
    3df4:	82e080e7          	jalr	-2002(ra) # 561e <wait>
  exit(xstatus);
    3df8:	fdc42503          	lw	a0,-36(s0)
    3dfc:	00002097          	auipc	ra,0x2
    3e00:	81a080e7          	jalr	-2022(ra) # 5616 <exit>

0000000000003e04 <forkforkfork>:
{
    3e04:	1101                	addi	sp,sp,-32
    3e06:	ec06                	sd	ra,24(sp)
    3e08:	e822                	sd	s0,16(sp)
    3e0a:	e426                	sd	s1,8(sp)
    3e0c:	1000                	addi	s0,sp,32
    3e0e:	84aa                	mv	s1,a0
  unlink("stopforking");
    3e10:	00004517          	auipc	a0,0x4
    3e14:	b9050513          	addi	a0,a0,-1136 # 79a0 <statistics+0x1e70>
    3e18:	00002097          	auipc	ra,0x2
    3e1c:	84e080e7          	jalr	-1970(ra) # 5666 <unlink>
  int pid = fork();
    3e20:	00001097          	auipc	ra,0x1
    3e24:	7ee080e7          	jalr	2030(ra) # 560e <fork>
  if(pid < 0){
    3e28:	04054563          	bltz	a0,3e72 <forkforkfork+0x6e>
  if(pid == 0){
    3e2c:	c12d                	beqz	a0,3e8e <forkforkfork+0x8a>
  sleep(20); // two seconds
    3e2e:	4551                	li	a0,20
    3e30:	00002097          	auipc	ra,0x2
    3e34:	876080e7          	jalr	-1930(ra) # 56a6 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3e38:	20200593          	li	a1,514
    3e3c:	00004517          	auipc	a0,0x4
    3e40:	b6450513          	addi	a0,a0,-1180 # 79a0 <statistics+0x1e70>
    3e44:	00002097          	auipc	ra,0x2
    3e48:	812080e7          	jalr	-2030(ra) # 5656 <open>
    3e4c:	00001097          	auipc	ra,0x1
    3e50:	7f2080e7          	jalr	2034(ra) # 563e <close>
  wait(0);
    3e54:	4501                	li	a0,0
    3e56:	00001097          	auipc	ra,0x1
    3e5a:	7c8080e7          	jalr	1992(ra) # 561e <wait>
  sleep(10); // one second
    3e5e:	4529                	li	a0,10
    3e60:	00002097          	auipc	ra,0x2
    3e64:	846080e7          	jalr	-1978(ra) # 56a6 <sleep>
}
    3e68:	60e2                	ld	ra,24(sp)
    3e6a:	6442                	ld	s0,16(sp)
    3e6c:	64a2                	ld	s1,8(sp)
    3e6e:	6105                	addi	sp,sp,32
    3e70:	8082                	ret
    printf("%s: fork failed", s);
    3e72:	85a6                	mv	a1,s1
    3e74:	00003517          	auipc	a0,0x3
    3e78:	a9450513          	addi	a0,a0,-1388 # 6908 <statistics+0xdd8>
    3e7c:	00002097          	auipc	ra,0x2
    3e80:	b12080e7          	jalr	-1262(ra) # 598e <printf>
    exit(1);
    3e84:	4505                	li	a0,1
    3e86:	00001097          	auipc	ra,0x1
    3e8a:	790080e7          	jalr	1936(ra) # 5616 <exit>
      int fd = open("stopforking", 0);
    3e8e:	00004497          	auipc	s1,0x4
    3e92:	b1248493          	addi	s1,s1,-1262 # 79a0 <statistics+0x1e70>
    3e96:	4581                	li	a1,0
    3e98:	8526                	mv	a0,s1
    3e9a:	00001097          	auipc	ra,0x1
    3e9e:	7bc080e7          	jalr	1980(ra) # 5656 <open>
      if(fd >= 0){
    3ea2:	02055463          	bgez	a0,3eca <forkforkfork+0xc6>
      if(fork() < 0){
    3ea6:	00001097          	auipc	ra,0x1
    3eaa:	768080e7          	jalr	1896(ra) # 560e <fork>
    3eae:	fe0554e3          	bgez	a0,3e96 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3eb2:	20200593          	li	a1,514
    3eb6:	8526                	mv	a0,s1
    3eb8:	00001097          	auipc	ra,0x1
    3ebc:	79e080e7          	jalr	1950(ra) # 5656 <open>
    3ec0:	00001097          	auipc	ra,0x1
    3ec4:	77e080e7          	jalr	1918(ra) # 563e <close>
    3ec8:	b7f9                	j	3e96 <forkforkfork+0x92>
        exit(0);
    3eca:	4501                	li	a0,0
    3ecc:	00001097          	auipc	ra,0x1
    3ed0:	74a080e7          	jalr	1866(ra) # 5616 <exit>

0000000000003ed4 <preempt>:
{
    3ed4:	7139                	addi	sp,sp,-64
    3ed6:	fc06                	sd	ra,56(sp)
    3ed8:	f822                	sd	s0,48(sp)
    3eda:	f426                	sd	s1,40(sp)
    3edc:	f04a                	sd	s2,32(sp)
    3ede:	ec4e                	sd	s3,24(sp)
    3ee0:	e852                	sd	s4,16(sp)
    3ee2:	0080                	addi	s0,sp,64
    3ee4:	84aa                	mv	s1,a0
  pid1 = fork();
    3ee6:	00001097          	auipc	ra,0x1
    3eea:	728080e7          	jalr	1832(ra) # 560e <fork>
  if(pid1 < 0) {
    3eee:	00054563          	bltz	a0,3ef8 <preempt+0x24>
    3ef2:	8a2a                	mv	s4,a0
  if(pid1 == 0)
    3ef4:	e105                	bnez	a0,3f14 <preempt+0x40>
    for(;;)
    3ef6:	a001                	j	3ef6 <preempt+0x22>
    printf("%s: fork failed", s);
    3ef8:	85a6                	mv	a1,s1
    3efa:	00003517          	auipc	a0,0x3
    3efe:	a0e50513          	addi	a0,a0,-1522 # 6908 <statistics+0xdd8>
    3f02:	00002097          	auipc	ra,0x2
    3f06:	a8c080e7          	jalr	-1396(ra) # 598e <printf>
    exit(1);
    3f0a:	4505                	li	a0,1
    3f0c:	00001097          	auipc	ra,0x1
    3f10:	70a080e7          	jalr	1802(ra) # 5616 <exit>
  pid2 = fork();
    3f14:	00001097          	auipc	ra,0x1
    3f18:	6fa080e7          	jalr	1786(ra) # 560e <fork>
    3f1c:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3f1e:	00054463          	bltz	a0,3f26 <preempt+0x52>
  if(pid2 == 0)
    3f22:	e105                	bnez	a0,3f42 <preempt+0x6e>
    for(;;)
    3f24:	a001                	j	3f24 <preempt+0x50>
    printf("%s: fork failed\n", s);
    3f26:	85a6                	mv	a1,s1
    3f28:	00003517          	auipc	a0,0x3
    3f2c:	82050513          	addi	a0,a0,-2016 # 6748 <statistics+0xc18>
    3f30:	00002097          	auipc	ra,0x2
    3f34:	a5e080e7          	jalr	-1442(ra) # 598e <printf>
    exit(1);
    3f38:	4505                	li	a0,1
    3f3a:	00001097          	auipc	ra,0x1
    3f3e:	6dc080e7          	jalr	1756(ra) # 5616 <exit>
  pipe(pfds);
    3f42:	fc840513          	addi	a0,s0,-56
    3f46:	00001097          	auipc	ra,0x1
    3f4a:	6e0080e7          	jalr	1760(ra) # 5626 <pipe>
  pid3 = fork();
    3f4e:	00001097          	auipc	ra,0x1
    3f52:	6c0080e7          	jalr	1728(ra) # 560e <fork>
    3f56:	892a                	mv	s2,a0
  if(pid3 < 0) {
    3f58:	02054e63          	bltz	a0,3f94 <preempt+0xc0>
  if(pid3 == 0){
    3f5c:	e525                	bnez	a0,3fc4 <preempt+0xf0>
    close(pfds[0]);
    3f5e:	fc842503          	lw	a0,-56(s0)
    3f62:	00001097          	auipc	ra,0x1
    3f66:	6dc080e7          	jalr	1756(ra) # 563e <close>
    if(write(pfds[1], "x", 1) != 1)
    3f6a:	4605                	li	a2,1
    3f6c:	00002597          	auipc	a1,0x2
    3f70:	01458593          	addi	a1,a1,20 # 5f80 <statistics+0x450>
    3f74:	fcc42503          	lw	a0,-52(s0)
    3f78:	00001097          	auipc	ra,0x1
    3f7c:	6be080e7          	jalr	1726(ra) # 5636 <write>
    3f80:	4785                	li	a5,1
    3f82:	02f51763          	bne	a0,a5,3fb0 <preempt+0xdc>
    close(pfds[1]);
    3f86:	fcc42503          	lw	a0,-52(s0)
    3f8a:	00001097          	auipc	ra,0x1
    3f8e:	6b4080e7          	jalr	1716(ra) # 563e <close>
    for(;;)
    3f92:	a001                	j	3f92 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3f94:	85a6                	mv	a1,s1
    3f96:	00002517          	auipc	a0,0x2
    3f9a:	7b250513          	addi	a0,a0,1970 # 6748 <statistics+0xc18>
    3f9e:	00002097          	auipc	ra,0x2
    3fa2:	9f0080e7          	jalr	-1552(ra) # 598e <printf>
     exit(1);
    3fa6:	4505                	li	a0,1
    3fa8:	00001097          	auipc	ra,0x1
    3fac:	66e080e7          	jalr	1646(ra) # 5616 <exit>
      printf("%s: preempt write error", s);
    3fb0:	85a6                	mv	a1,s1
    3fb2:	00004517          	auipc	a0,0x4
    3fb6:	9fe50513          	addi	a0,a0,-1538 # 79b0 <statistics+0x1e80>
    3fba:	00002097          	auipc	ra,0x2
    3fbe:	9d4080e7          	jalr	-1580(ra) # 598e <printf>
    3fc2:	b7d1                	j	3f86 <preempt+0xb2>
  close(pfds[1]);
    3fc4:	fcc42503          	lw	a0,-52(s0)
    3fc8:	00001097          	auipc	ra,0x1
    3fcc:	676080e7          	jalr	1654(ra) # 563e <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3fd0:	660d                	lui	a2,0x3
    3fd2:	00008597          	auipc	a1,0x8
    3fd6:	b7e58593          	addi	a1,a1,-1154 # bb50 <buf>
    3fda:	fc842503          	lw	a0,-56(s0)
    3fde:	00001097          	auipc	ra,0x1
    3fe2:	650080e7          	jalr	1616(ra) # 562e <read>
    3fe6:	4785                	li	a5,1
    3fe8:	02f50363          	beq	a0,a5,400e <preempt+0x13a>
    printf("%s: preempt read error", s);
    3fec:	85a6                	mv	a1,s1
    3fee:	00004517          	auipc	a0,0x4
    3ff2:	9da50513          	addi	a0,a0,-1574 # 79c8 <statistics+0x1e98>
    3ff6:	00002097          	auipc	ra,0x2
    3ffa:	998080e7          	jalr	-1640(ra) # 598e <printf>
}
    3ffe:	70e2                	ld	ra,56(sp)
    4000:	7442                	ld	s0,48(sp)
    4002:	74a2                	ld	s1,40(sp)
    4004:	7902                	ld	s2,32(sp)
    4006:	69e2                	ld	s3,24(sp)
    4008:	6a42                	ld	s4,16(sp)
    400a:	6121                	addi	sp,sp,64
    400c:	8082                	ret
  close(pfds[0]);
    400e:	fc842503          	lw	a0,-56(s0)
    4012:	00001097          	auipc	ra,0x1
    4016:	62c080e7          	jalr	1580(ra) # 563e <close>
  printf("kill... ");
    401a:	00004517          	auipc	a0,0x4
    401e:	9c650513          	addi	a0,a0,-1594 # 79e0 <statistics+0x1eb0>
    4022:	00002097          	auipc	ra,0x2
    4026:	96c080e7          	jalr	-1684(ra) # 598e <printf>
  kill(pid1);
    402a:	8552                	mv	a0,s4
    402c:	00001097          	auipc	ra,0x1
    4030:	61a080e7          	jalr	1562(ra) # 5646 <kill>
  kill(pid2);
    4034:	854e                	mv	a0,s3
    4036:	00001097          	auipc	ra,0x1
    403a:	610080e7          	jalr	1552(ra) # 5646 <kill>
  kill(pid3);
    403e:	854a                	mv	a0,s2
    4040:	00001097          	auipc	ra,0x1
    4044:	606080e7          	jalr	1542(ra) # 5646 <kill>
  printf("wait... ");
    4048:	00004517          	auipc	a0,0x4
    404c:	9a850513          	addi	a0,a0,-1624 # 79f0 <statistics+0x1ec0>
    4050:	00002097          	auipc	ra,0x2
    4054:	93e080e7          	jalr	-1730(ra) # 598e <printf>
  wait(0);
    4058:	4501                	li	a0,0
    405a:	00001097          	auipc	ra,0x1
    405e:	5c4080e7          	jalr	1476(ra) # 561e <wait>
  wait(0);
    4062:	4501                	li	a0,0
    4064:	00001097          	auipc	ra,0x1
    4068:	5ba080e7          	jalr	1466(ra) # 561e <wait>
  wait(0);
    406c:	4501                	li	a0,0
    406e:	00001097          	auipc	ra,0x1
    4072:	5b0080e7          	jalr	1456(ra) # 561e <wait>
    4076:	b761                	j	3ffe <preempt+0x12a>

0000000000004078 <sbrkfail>:
{
    4078:	7119                	addi	sp,sp,-128
    407a:	fc86                	sd	ra,120(sp)
    407c:	f8a2                	sd	s0,112(sp)
    407e:	f4a6                	sd	s1,104(sp)
    4080:	f0ca                	sd	s2,96(sp)
    4082:	ecce                	sd	s3,88(sp)
    4084:	e8d2                	sd	s4,80(sp)
    4086:	e4d6                	sd	s5,72(sp)
    4088:	0100                	addi	s0,sp,128
    408a:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    408c:	fb040513          	addi	a0,s0,-80
    4090:	00001097          	auipc	ra,0x1
    4094:	596080e7          	jalr	1430(ra) # 5626 <pipe>
    4098:	e901                	bnez	a0,40a8 <sbrkfail+0x30>
    409a:	f8040493          	addi	s1,s0,-128
    409e:	fa840a13          	addi	s4,s0,-88
    40a2:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    40a4:	5afd                	li	s5,-1
    40a6:	a08d                	j	4108 <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    40a8:	85ca                	mv	a1,s2
    40aa:	00002517          	auipc	a0,0x2
    40ae:	7a650513          	addi	a0,a0,1958 # 6850 <statistics+0xd20>
    40b2:	00002097          	auipc	ra,0x2
    40b6:	8dc080e7          	jalr	-1828(ra) # 598e <printf>
    exit(1);
    40ba:	4505                	li	a0,1
    40bc:	00001097          	auipc	ra,0x1
    40c0:	55a080e7          	jalr	1370(ra) # 5616 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    40c4:	4501                	li	a0,0
    40c6:	00001097          	auipc	ra,0x1
    40ca:	5d8080e7          	jalr	1496(ra) # 569e <sbrk>
    40ce:	064007b7          	lui	a5,0x6400
    40d2:	40a7853b          	subw	a0,a5,a0
    40d6:	00001097          	auipc	ra,0x1
    40da:	5c8080e7          	jalr	1480(ra) # 569e <sbrk>
      write(fds[1], "x", 1);
    40de:	4605                	li	a2,1
    40e0:	00002597          	auipc	a1,0x2
    40e4:	ea058593          	addi	a1,a1,-352 # 5f80 <statistics+0x450>
    40e8:	fb442503          	lw	a0,-76(s0)
    40ec:	00001097          	auipc	ra,0x1
    40f0:	54a080e7          	jalr	1354(ra) # 5636 <write>
      for(;;) sleep(1000);
    40f4:	3e800513          	li	a0,1000
    40f8:	00001097          	auipc	ra,0x1
    40fc:	5ae080e7          	jalr	1454(ra) # 56a6 <sleep>
    4100:	bfd5                	j	40f4 <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4102:	0991                	addi	s3,s3,4
    4104:	03498563          	beq	s3,s4,412e <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    4108:	00001097          	auipc	ra,0x1
    410c:	506080e7          	jalr	1286(ra) # 560e <fork>
    4110:	00a9a023          	sw	a0,0(s3)
    4114:	d945                	beqz	a0,40c4 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4116:	ff5506e3          	beq	a0,s5,4102 <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    411a:	4605                	li	a2,1
    411c:	faf40593          	addi	a1,s0,-81
    4120:	fb042503          	lw	a0,-80(s0)
    4124:	00001097          	auipc	ra,0x1
    4128:	50a080e7          	jalr	1290(ra) # 562e <read>
    412c:	bfd9                	j	4102 <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    412e:	6505                	lui	a0,0x1
    4130:	00001097          	auipc	ra,0x1
    4134:	56e080e7          	jalr	1390(ra) # 569e <sbrk>
    4138:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    413a:	5afd                	li	s5,-1
    413c:	a021                	j	4144 <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    413e:	0491                	addi	s1,s1,4
    4140:	01448f63          	beq	s1,s4,415e <sbrkfail+0xe6>
    if(pids[i] == -1)
    4144:	4088                	lw	a0,0(s1)
    4146:	ff550ce3          	beq	a0,s5,413e <sbrkfail+0xc6>
    kill(pids[i]);
    414a:	00001097          	auipc	ra,0x1
    414e:	4fc080e7          	jalr	1276(ra) # 5646 <kill>
    wait(0);
    4152:	4501                	li	a0,0
    4154:	00001097          	auipc	ra,0x1
    4158:	4ca080e7          	jalr	1226(ra) # 561e <wait>
    415c:	b7cd                	j	413e <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    415e:	57fd                	li	a5,-1
    4160:	04f98163          	beq	s3,a5,41a2 <sbrkfail+0x12a>
  pid = fork();
    4164:	00001097          	auipc	ra,0x1
    4168:	4aa080e7          	jalr	1194(ra) # 560e <fork>
    416c:	84aa                	mv	s1,a0
  if(pid < 0){
    416e:	04054863          	bltz	a0,41be <sbrkfail+0x146>
  if(pid == 0){
    4172:	c525                	beqz	a0,41da <sbrkfail+0x162>
  wait(&xstatus);
    4174:	fbc40513          	addi	a0,s0,-68
    4178:	00001097          	auipc	ra,0x1
    417c:	4a6080e7          	jalr	1190(ra) # 561e <wait>
  if(xstatus != -1 && xstatus != 2)
    4180:	fbc42783          	lw	a5,-68(s0)
    4184:	577d                	li	a4,-1
    4186:	00e78563          	beq	a5,a4,4190 <sbrkfail+0x118>
    418a:	4709                	li	a4,2
    418c:	08e79d63          	bne	a5,a4,4226 <sbrkfail+0x1ae>
}
    4190:	70e6                	ld	ra,120(sp)
    4192:	7446                	ld	s0,112(sp)
    4194:	74a6                	ld	s1,104(sp)
    4196:	7906                	ld	s2,96(sp)
    4198:	69e6                	ld	s3,88(sp)
    419a:	6a46                	ld	s4,80(sp)
    419c:	6aa6                	ld	s5,72(sp)
    419e:	6109                	addi	sp,sp,128
    41a0:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    41a2:	85ca                	mv	a1,s2
    41a4:	00004517          	auipc	a0,0x4
    41a8:	85c50513          	addi	a0,a0,-1956 # 7a00 <statistics+0x1ed0>
    41ac:	00001097          	auipc	ra,0x1
    41b0:	7e2080e7          	jalr	2018(ra) # 598e <printf>
    exit(1);
    41b4:	4505                	li	a0,1
    41b6:	00001097          	auipc	ra,0x1
    41ba:	460080e7          	jalr	1120(ra) # 5616 <exit>
    printf("%s: fork failed\n", s);
    41be:	85ca                	mv	a1,s2
    41c0:	00002517          	auipc	a0,0x2
    41c4:	58850513          	addi	a0,a0,1416 # 6748 <statistics+0xc18>
    41c8:	00001097          	auipc	ra,0x1
    41cc:	7c6080e7          	jalr	1990(ra) # 598e <printf>
    exit(1);
    41d0:	4505                	li	a0,1
    41d2:	00001097          	auipc	ra,0x1
    41d6:	444080e7          	jalr	1092(ra) # 5616 <exit>
    a = sbrk(0);
    41da:	4501                	li	a0,0
    41dc:	00001097          	auipc	ra,0x1
    41e0:	4c2080e7          	jalr	1218(ra) # 569e <sbrk>
    41e4:	89aa                	mv	s3,a0
    sbrk(10*BIG);
    41e6:	3e800537          	lui	a0,0x3e800
    41ea:	00001097          	auipc	ra,0x1
    41ee:	4b4080e7          	jalr	1204(ra) # 569e <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    41f2:	874e                	mv	a4,s3
    41f4:	3e8007b7          	lui	a5,0x3e800
    41f8:	97ce                	add	a5,a5,s3
    41fa:	6685                	lui	a3,0x1
      n += *(a+i);
    41fc:	00074603          	lbu	a2,0(a4)
    4200:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4202:	9736                	add	a4,a4,a3
    4204:	fef71ce3          	bne	a4,a5,41fc <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4208:	8626                	mv	a2,s1
    420a:	85ca                	mv	a1,s2
    420c:	00004517          	auipc	a0,0x4
    4210:	81450513          	addi	a0,a0,-2028 # 7a20 <statistics+0x1ef0>
    4214:	00001097          	auipc	ra,0x1
    4218:	77a080e7          	jalr	1914(ra) # 598e <printf>
    exit(1);
    421c:	4505                	li	a0,1
    421e:	00001097          	auipc	ra,0x1
    4222:	3f8080e7          	jalr	1016(ra) # 5616 <exit>
    exit(1);
    4226:	4505                	li	a0,1
    4228:	00001097          	auipc	ra,0x1
    422c:	3ee080e7          	jalr	1006(ra) # 5616 <exit>

0000000000004230 <reparent>:
{
    4230:	7179                	addi	sp,sp,-48
    4232:	f406                	sd	ra,40(sp)
    4234:	f022                	sd	s0,32(sp)
    4236:	ec26                	sd	s1,24(sp)
    4238:	e84a                	sd	s2,16(sp)
    423a:	e44e                	sd	s3,8(sp)
    423c:	e052                	sd	s4,0(sp)
    423e:	1800                	addi	s0,sp,48
    4240:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4242:	00001097          	auipc	ra,0x1
    4246:	454080e7          	jalr	1108(ra) # 5696 <getpid>
    424a:	8a2a                	mv	s4,a0
    424c:	0c800913          	li	s2,200
    int pid = fork();
    4250:	00001097          	auipc	ra,0x1
    4254:	3be080e7          	jalr	958(ra) # 560e <fork>
    4258:	84aa                	mv	s1,a0
    if(pid < 0){
    425a:	02054263          	bltz	a0,427e <reparent+0x4e>
    if(pid){
    425e:	cd21                	beqz	a0,42b6 <reparent+0x86>
      if(wait(0) != pid){
    4260:	4501                	li	a0,0
    4262:	00001097          	auipc	ra,0x1
    4266:	3bc080e7          	jalr	956(ra) # 561e <wait>
    426a:	02951863          	bne	a0,s1,429a <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    426e:	397d                	addiw	s2,s2,-1
    4270:	fe0910e3          	bnez	s2,4250 <reparent+0x20>
  exit(0);
    4274:	4501                	li	a0,0
    4276:	00001097          	auipc	ra,0x1
    427a:	3a0080e7          	jalr	928(ra) # 5616 <exit>
      printf("%s: fork failed\n", s);
    427e:	85ce                	mv	a1,s3
    4280:	00002517          	auipc	a0,0x2
    4284:	4c850513          	addi	a0,a0,1224 # 6748 <statistics+0xc18>
    4288:	00001097          	auipc	ra,0x1
    428c:	706080e7          	jalr	1798(ra) # 598e <printf>
      exit(1);
    4290:	4505                	li	a0,1
    4292:	00001097          	auipc	ra,0x1
    4296:	384080e7          	jalr	900(ra) # 5616 <exit>
        printf("%s: wait wrong pid\n", s);
    429a:	85ce                	mv	a1,s3
    429c:	00002517          	auipc	a0,0x2
    42a0:	63450513          	addi	a0,a0,1588 # 68d0 <statistics+0xda0>
    42a4:	00001097          	auipc	ra,0x1
    42a8:	6ea080e7          	jalr	1770(ra) # 598e <printf>
        exit(1);
    42ac:	4505                	li	a0,1
    42ae:	00001097          	auipc	ra,0x1
    42b2:	368080e7          	jalr	872(ra) # 5616 <exit>
      int pid2 = fork();
    42b6:	00001097          	auipc	ra,0x1
    42ba:	358080e7          	jalr	856(ra) # 560e <fork>
      if(pid2 < 0){
    42be:	00054763          	bltz	a0,42cc <reparent+0x9c>
      exit(0);
    42c2:	4501                	li	a0,0
    42c4:	00001097          	auipc	ra,0x1
    42c8:	352080e7          	jalr	850(ra) # 5616 <exit>
        kill(master_pid);
    42cc:	8552                	mv	a0,s4
    42ce:	00001097          	auipc	ra,0x1
    42d2:	378080e7          	jalr	888(ra) # 5646 <kill>
        exit(1);
    42d6:	4505                	li	a0,1
    42d8:	00001097          	auipc	ra,0x1
    42dc:	33e080e7          	jalr	830(ra) # 5616 <exit>

00000000000042e0 <mem>:
{
    42e0:	7139                	addi	sp,sp,-64
    42e2:	fc06                	sd	ra,56(sp)
    42e4:	f822                	sd	s0,48(sp)
    42e6:	f426                	sd	s1,40(sp)
    42e8:	f04a                	sd	s2,32(sp)
    42ea:	ec4e                	sd	s3,24(sp)
    42ec:	0080                	addi	s0,sp,64
    42ee:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    42f0:	00001097          	auipc	ra,0x1
    42f4:	31e080e7          	jalr	798(ra) # 560e <fork>
    m1 = 0;
    42f8:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    42fa:	6909                	lui	s2,0x2
    42fc:	71190913          	addi	s2,s2,1809 # 2711 <sbrkbasic+0x159>
  if((pid = fork()) == 0){
    4300:	ed39                	bnez	a0,435e <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    4302:	854a                	mv	a0,s2
    4304:	00001097          	auipc	ra,0x1
    4308:	748080e7          	jalr	1864(ra) # 5a4c <malloc>
    430c:	c501                	beqz	a0,4314 <mem+0x34>
      *(char**)m2 = m1;
    430e:	e104                	sd	s1,0(a0)
      m1 = m2;
    4310:	84aa                	mv	s1,a0
    4312:	bfc5                	j	4302 <mem+0x22>
    while(m1){
    4314:	c881                	beqz	s1,4324 <mem+0x44>
      m2 = *(char**)m1;
    4316:	8526                	mv	a0,s1
    4318:	6084                	ld	s1,0(s1)
      free(m1);
    431a:	00001097          	auipc	ra,0x1
    431e:	6aa080e7          	jalr	1706(ra) # 59c4 <free>
    while(m1){
    4322:	f8f5                	bnez	s1,4316 <mem+0x36>
    m1 = malloc(1024*20);
    4324:	6515                	lui	a0,0x5
    4326:	00001097          	auipc	ra,0x1
    432a:	726080e7          	jalr	1830(ra) # 5a4c <malloc>
    if(m1 == 0){
    432e:	c911                	beqz	a0,4342 <mem+0x62>
    free(m1);
    4330:	00001097          	auipc	ra,0x1
    4334:	694080e7          	jalr	1684(ra) # 59c4 <free>
    exit(0);
    4338:	4501                	li	a0,0
    433a:	00001097          	auipc	ra,0x1
    433e:	2dc080e7          	jalr	732(ra) # 5616 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4342:	85ce                	mv	a1,s3
    4344:	00003517          	auipc	a0,0x3
    4348:	70c50513          	addi	a0,a0,1804 # 7a50 <statistics+0x1f20>
    434c:	00001097          	auipc	ra,0x1
    4350:	642080e7          	jalr	1602(ra) # 598e <printf>
      exit(1);
    4354:	4505                	li	a0,1
    4356:	00001097          	auipc	ra,0x1
    435a:	2c0080e7          	jalr	704(ra) # 5616 <exit>
    wait(&xstatus);
    435e:	fcc40513          	addi	a0,s0,-52
    4362:	00001097          	auipc	ra,0x1
    4366:	2bc080e7          	jalr	700(ra) # 561e <wait>
    if(xstatus == -1){
    436a:	fcc42503          	lw	a0,-52(s0)
    436e:	57fd                	li	a5,-1
    4370:	00f50663          	beq	a0,a5,437c <mem+0x9c>
    exit(xstatus);
    4374:	00001097          	auipc	ra,0x1
    4378:	2a2080e7          	jalr	674(ra) # 5616 <exit>
      exit(0);
    437c:	4501                	li	a0,0
    437e:	00001097          	auipc	ra,0x1
    4382:	298080e7          	jalr	664(ra) # 5616 <exit>

0000000000004386 <sharedfd>:
{
    4386:	7159                	addi	sp,sp,-112
    4388:	f486                	sd	ra,104(sp)
    438a:	f0a2                	sd	s0,96(sp)
    438c:	eca6                	sd	s1,88(sp)
    438e:	e8ca                	sd	s2,80(sp)
    4390:	e4ce                	sd	s3,72(sp)
    4392:	e0d2                	sd	s4,64(sp)
    4394:	fc56                	sd	s5,56(sp)
    4396:	f85a                	sd	s6,48(sp)
    4398:	f45e                	sd	s7,40(sp)
    439a:	1880                	addi	s0,sp,112
    439c:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    439e:	00002517          	auipc	a0,0x2
    43a2:	9b250513          	addi	a0,a0,-1614 # 5d50 <statistics+0x220>
    43a6:	00001097          	auipc	ra,0x1
    43aa:	2c0080e7          	jalr	704(ra) # 5666 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    43ae:	20200593          	li	a1,514
    43b2:	00002517          	auipc	a0,0x2
    43b6:	99e50513          	addi	a0,a0,-1634 # 5d50 <statistics+0x220>
    43ba:	00001097          	auipc	ra,0x1
    43be:	29c080e7          	jalr	668(ra) # 5656 <open>
  if(fd < 0){
    43c2:	04054a63          	bltz	a0,4416 <sharedfd+0x90>
    43c6:	892a                	mv	s2,a0
  pid = fork();
    43c8:	00001097          	auipc	ra,0x1
    43cc:	246080e7          	jalr	582(ra) # 560e <fork>
    43d0:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    43d2:	06300593          	li	a1,99
    43d6:	c119                	beqz	a0,43dc <sharedfd+0x56>
    43d8:	07000593          	li	a1,112
    43dc:	4629                	li	a2,10
    43de:	fa040513          	addi	a0,s0,-96
    43e2:	00001097          	auipc	ra,0x1
    43e6:	030080e7          	jalr	48(ra) # 5412 <memset>
    43ea:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    43ee:	4629                	li	a2,10
    43f0:	fa040593          	addi	a1,s0,-96
    43f4:	854a                	mv	a0,s2
    43f6:	00001097          	auipc	ra,0x1
    43fa:	240080e7          	jalr	576(ra) # 5636 <write>
    43fe:	47a9                	li	a5,10
    4400:	02f51963          	bne	a0,a5,4432 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4404:	34fd                	addiw	s1,s1,-1
    4406:	f4e5                	bnez	s1,43ee <sharedfd+0x68>
  if(pid == 0) {
    4408:	04099363          	bnez	s3,444e <sharedfd+0xc8>
    exit(0);
    440c:	4501                	li	a0,0
    440e:	00001097          	auipc	ra,0x1
    4412:	208080e7          	jalr	520(ra) # 5616 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4416:	85d2                	mv	a1,s4
    4418:	00003517          	auipc	a0,0x3
    441c:	65850513          	addi	a0,a0,1624 # 7a70 <statistics+0x1f40>
    4420:	00001097          	auipc	ra,0x1
    4424:	56e080e7          	jalr	1390(ra) # 598e <printf>
    exit(1);
    4428:	4505                	li	a0,1
    442a:	00001097          	auipc	ra,0x1
    442e:	1ec080e7          	jalr	492(ra) # 5616 <exit>
      printf("%s: write sharedfd failed\n", s);
    4432:	85d2                	mv	a1,s4
    4434:	00003517          	auipc	a0,0x3
    4438:	66450513          	addi	a0,a0,1636 # 7a98 <statistics+0x1f68>
    443c:	00001097          	auipc	ra,0x1
    4440:	552080e7          	jalr	1362(ra) # 598e <printf>
      exit(1);
    4444:	4505                	li	a0,1
    4446:	00001097          	auipc	ra,0x1
    444a:	1d0080e7          	jalr	464(ra) # 5616 <exit>
    wait(&xstatus);
    444e:	f9c40513          	addi	a0,s0,-100
    4452:	00001097          	auipc	ra,0x1
    4456:	1cc080e7          	jalr	460(ra) # 561e <wait>
    if(xstatus != 0)
    445a:	f9c42983          	lw	s3,-100(s0)
    445e:	00098763          	beqz	s3,446c <sharedfd+0xe6>
      exit(xstatus);
    4462:	854e                	mv	a0,s3
    4464:	00001097          	auipc	ra,0x1
    4468:	1b2080e7          	jalr	434(ra) # 5616 <exit>
  close(fd);
    446c:	854a                	mv	a0,s2
    446e:	00001097          	auipc	ra,0x1
    4472:	1d0080e7          	jalr	464(ra) # 563e <close>
  fd = open("sharedfd", 0);
    4476:	4581                	li	a1,0
    4478:	00002517          	auipc	a0,0x2
    447c:	8d850513          	addi	a0,a0,-1832 # 5d50 <statistics+0x220>
    4480:	00001097          	auipc	ra,0x1
    4484:	1d6080e7          	jalr	470(ra) # 5656 <open>
    4488:	8baa                	mv	s7,a0
  nc = np = 0;
    448a:	8ace                	mv	s5,s3
  if(fd < 0){
    448c:	02054563          	bltz	a0,44b6 <sharedfd+0x130>
    4490:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4494:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4498:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    449c:	4629                	li	a2,10
    449e:	fa040593          	addi	a1,s0,-96
    44a2:	855e                	mv	a0,s7
    44a4:	00001097          	auipc	ra,0x1
    44a8:	18a080e7          	jalr	394(ra) # 562e <read>
    44ac:	02a05f63          	blez	a0,44ea <sharedfd+0x164>
    44b0:	fa040793          	addi	a5,s0,-96
    44b4:	a01d                	j	44da <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    44b6:	85d2                	mv	a1,s4
    44b8:	00003517          	auipc	a0,0x3
    44bc:	60050513          	addi	a0,a0,1536 # 7ab8 <statistics+0x1f88>
    44c0:	00001097          	auipc	ra,0x1
    44c4:	4ce080e7          	jalr	1230(ra) # 598e <printf>
    exit(1);
    44c8:	4505                	li	a0,1
    44ca:	00001097          	auipc	ra,0x1
    44ce:	14c080e7          	jalr	332(ra) # 5616 <exit>
        nc++;
    44d2:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    44d4:	0785                	addi	a5,a5,1
    44d6:	fd2783e3          	beq	a5,s2,449c <sharedfd+0x116>
      if(buf[i] == 'c')
    44da:	0007c703          	lbu	a4,0(a5) # 3e800000 <__BSS_END__+0x3e7f14a0>
    44de:	fe970ae3          	beq	a4,s1,44d2 <sharedfd+0x14c>
      if(buf[i] == 'p')
    44e2:	ff6719e3          	bne	a4,s6,44d4 <sharedfd+0x14e>
        np++;
    44e6:	2a85                	addiw	s5,s5,1
    44e8:	b7f5                	j	44d4 <sharedfd+0x14e>
  close(fd);
    44ea:	855e                	mv	a0,s7
    44ec:	00001097          	auipc	ra,0x1
    44f0:	152080e7          	jalr	338(ra) # 563e <close>
  unlink("sharedfd");
    44f4:	00002517          	auipc	a0,0x2
    44f8:	85c50513          	addi	a0,a0,-1956 # 5d50 <statistics+0x220>
    44fc:	00001097          	auipc	ra,0x1
    4500:	16a080e7          	jalr	362(ra) # 5666 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4504:	6789                	lui	a5,0x2
    4506:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x158>
    450a:	00f99763          	bne	s3,a5,4518 <sharedfd+0x192>
    450e:	6789                	lui	a5,0x2
    4510:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x158>
    4514:	02fa8063          	beq	s5,a5,4534 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4518:	85d2                	mv	a1,s4
    451a:	00003517          	auipc	a0,0x3
    451e:	5c650513          	addi	a0,a0,1478 # 7ae0 <statistics+0x1fb0>
    4522:	00001097          	auipc	ra,0x1
    4526:	46c080e7          	jalr	1132(ra) # 598e <printf>
    exit(1);
    452a:	4505                	li	a0,1
    452c:	00001097          	auipc	ra,0x1
    4530:	0ea080e7          	jalr	234(ra) # 5616 <exit>
    exit(0);
    4534:	4501                	li	a0,0
    4536:	00001097          	auipc	ra,0x1
    453a:	0e0080e7          	jalr	224(ra) # 5616 <exit>

000000000000453e <fourfiles>:
{
    453e:	7171                	addi	sp,sp,-176
    4540:	f506                	sd	ra,168(sp)
    4542:	f122                	sd	s0,160(sp)
    4544:	ed26                	sd	s1,152(sp)
    4546:	e94a                	sd	s2,144(sp)
    4548:	e54e                	sd	s3,136(sp)
    454a:	e152                	sd	s4,128(sp)
    454c:	fcd6                	sd	s5,120(sp)
    454e:	f8da                	sd	s6,112(sp)
    4550:	f4de                	sd	s7,104(sp)
    4552:	f0e2                	sd	s8,96(sp)
    4554:	ece6                	sd	s9,88(sp)
    4556:	e8ea                	sd	s10,80(sp)
    4558:	e4ee                	sd	s11,72(sp)
    455a:	1900                	addi	s0,sp,176
    455c:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    455e:	00001797          	auipc	a5,0x1
    4562:	65a78793          	addi	a5,a5,1626 # 5bb8 <statistics+0x88>
    4566:	f6f43823          	sd	a5,-144(s0)
    456a:	00001797          	auipc	a5,0x1
    456e:	65678793          	addi	a5,a5,1622 # 5bc0 <statistics+0x90>
    4572:	f6f43c23          	sd	a5,-136(s0)
    4576:	00001797          	auipc	a5,0x1
    457a:	65278793          	addi	a5,a5,1618 # 5bc8 <statistics+0x98>
    457e:	f8f43023          	sd	a5,-128(s0)
    4582:	00001797          	auipc	a5,0x1
    4586:	64e78793          	addi	a5,a5,1614 # 5bd0 <statistics+0xa0>
    458a:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    458e:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4592:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4594:	4481                	li	s1,0
    4596:	4a11                	li	s4,4
    fname = names[pi];
    4598:	00093983          	ld	s3,0(s2)
    unlink(fname);
    459c:	854e                	mv	a0,s3
    459e:	00001097          	auipc	ra,0x1
    45a2:	0c8080e7          	jalr	200(ra) # 5666 <unlink>
    pid = fork();
    45a6:	00001097          	auipc	ra,0x1
    45aa:	068080e7          	jalr	104(ra) # 560e <fork>
    if(pid < 0){
    45ae:	04054563          	bltz	a0,45f8 <fourfiles+0xba>
    if(pid == 0){
    45b2:	c12d                	beqz	a0,4614 <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    45b4:	2485                	addiw	s1,s1,1
    45b6:	0921                	addi	s2,s2,8
    45b8:	ff4490e3          	bne	s1,s4,4598 <fourfiles+0x5a>
    45bc:	4491                	li	s1,4
    wait(&xstatus);
    45be:	f6c40513          	addi	a0,s0,-148
    45c2:	00001097          	auipc	ra,0x1
    45c6:	05c080e7          	jalr	92(ra) # 561e <wait>
    if(xstatus != 0)
    45ca:	f6c42503          	lw	a0,-148(s0)
    45ce:	ed69                	bnez	a0,46a8 <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    45d0:	34fd                	addiw	s1,s1,-1
    45d2:	f4f5                	bnez	s1,45be <fourfiles+0x80>
    45d4:	03000b13          	li	s6,48
    total = 0;
    45d8:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    45dc:	00007a17          	auipc	s4,0x7
    45e0:	574a0a13          	addi	s4,s4,1396 # bb50 <buf>
    45e4:	00007a97          	auipc	s5,0x7
    45e8:	56da8a93          	addi	s5,s5,1389 # bb51 <buf+0x1>
    if(total != N*SZ){
    45ec:	6d05                	lui	s10,0x1
    45ee:	770d0d13          	addi	s10,s10,1904 # 1770 <pipe1+0x32>
  for(i = 0; i < NCHILD; i++){
    45f2:	03400d93          	li	s11,52
    45f6:	a23d                	j	4724 <fourfiles+0x1e6>
      printf("fork failed\n", s);
    45f8:	85e6                	mv	a1,s9
    45fa:	00002517          	auipc	a0,0x2
    45fe:	55650513          	addi	a0,a0,1366 # 6b50 <statistics+0x1020>
    4602:	00001097          	auipc	ra,0x1
    4606:	38c080e7          	jalr	908(ra) # 598e <printf>
      exit(1);
    460a:	4505                	li	a0,1
    460c:	00001097          	auipc	ra,0x1
    4610:	00a080e7          	jalr	10(ra) # 5616 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4614:	20200593          	li	a1,514
    4618:	854e                	mv	a0,s3
    461a:	00001097          	auipc	ra,0x1
    461e:	03c080e7          	jalr	60(ra) # 5656 <open>
    4622:	892a                	mv	s2,a0
      if(fd < 0){
    4624:	04054763          	bltz	a0,4672 <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    4628:	1f400613          	li	a2,500
    462c:	0304859b          	addiw	a1,s1,48
    4630:	00007517          	auipc	a0,0x7
    4634:	52050513          	addi	a0,a0,1312 # bb50 <buf>
    4638:	00001097          	auipc	ra,0x1
    463c:	dda080e7          	jalr	-550(ra) # 5412 <memset>
    4640:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4642:	00007997          	auipc	s3,0x7
    4646:	50e98993          	addi	s3,s3,1294 # bb50 <buf>
    464a:	1f400613          	li	a2,500
    464e:	85ce                	mv	a1,s3
    4650:	854a                	mv	a0,s2
    4652:	00001097          	auipc	ra,0x1
    4656:	fe4080e7          	jalr	-28(ra) # 5636 <write>
    465a:	85aa                	mv	a1,a0
    465c:	1f400793          	li	a5,500
    4660:	02f51763          	bne	a0,a5,468e <fourfiles+0x150>
      for(i = 0; i < N; i++){
    4664:	34fd                	addiw	s1,s1,-1
    4666:	f0f5                	bnez	s1,464a <fourfiles+0x10c>
      exit(0);
    4668:	4501                	li	a0,0
    466a:	00001097          	auipc	ra,0x1
    466e:	fac080e7          	jalr	-84(ra) # 5616 <exit>
        printf("create failed\n", s);
    4672:	85e6                	mv	a1,s9
    4674:	00003517          	auipc	a0,0x3
    4678:	48450513          	addi	a0,a0,1156 # 7af8 <statistics+0x1fc8>
    467c:	00001097          	auipc	ra,0x1
    4680:	312080e7          	jalr	786(ra) # 598e <printf>
        exit(1);
    4684:	4505                	li	a0,1
    4686:	00001097          	auipc	ra,0x1
    468a:	f90080e7          	jalr	-112(ra) # 5616 <exit>
          printf("write failed %d\n", n);
    468e:	00003517          	auipc	a0,0x3
    4692:	47a50513          	addi	a0,a0,1146 # 7b08 <statistics+0x1fd8>
    4696:	00001097          	auipc	ra,0x1
    469a:	2f8080e7          	jalr	760(ra) # 598e <printf>
          exit(1);
    469e:	4505                	li	a0,1
    46a0:	00001097          	auipc	ra,0x1
    46a4:	f76080e7          	jalr	-138(ra) # 5616 <exit>
      exit(xstatus);
    46a8:	00001097          	auipc	ra,0x1
    46ac:	f6e080e7          	jalr	-146(ra) # 5616 <exit>
          printf("wrong char\n", s);
    46b0:	85e6                	mv	a1,s9
    46b2:	00003517          	auipc	a0,0x3
    46b6:	46e50513          	addi	a0,a0,1134 # 7b20 <statistics+0x1ff0>
    46ba:	00001097          	auipc	ra,0x1
    46be:	2d4080e7          	jalr	724(ra) # 598e <printf>
          exit(1);
    46c2:	4505                	li	a0,1
    46c4:	00001097          	auipc	ra,0x1
    46c8:	f52080e7          	jalr	-174(ra) # 5616 <exit>
      total += n;
    46cc:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    46d0:	660d                	lui	a2,0x3
    46d2:	85d2                	mv	a1,s4
    46d4:	854e                	mv	a0,s3
    46d6:	00001097          	auipc	ra,0x1
    46da:	f58080e7          	jalr	-168(ra) # 562e <read>
    46de:	02a05363          	blez	a0,4704 <fourfiles+0x1c6>
    46e2:	00007797          	auipc	a5,0x7
    46e6:	46e78793          	addi	a5,a5,1134 # bb50 <buf>
    46ea:	fff5069b          	addiw	a3,a0,-1
    46ee:	1682                	slli	a3,a3,0x20
    46f0:	9281                	srli	a3,a3,0x20
    46f2:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    46f4:	0007c703          	lbu	a4,0(a5)
    46f8:	fa971ce3          	bne	a4,s1,46b0 <fourfiles+0x172>
      for(j = 0; j < n; j++){
    46fc:	0785                	addi	a5,a5,1
    46fe:	fed79be3          	bne	a5,a3,46f4 <fourfiles+0x1b6>
    4702:	b7e9                	j	46cc <fourfiles+0x18e>
    close(fd);
    4704:	854e                	mv	a0,s3
    4706:	00001097          	auipc	ra,0x1
    470a:	f38080e7          	jalr	-200(ra) # 563e <close>
    if(total != N*SZ){
    470e:	03a91963          	bne	s2,s10,4740 <fourfiles+0x202>
    unlink(fname);
    4712:	8562                	mv	a0,s8
    4714:	00001097          	auipc	ra,0x1
    4718:	f52080e7          	jalr	-174(ra) # 5666 <unlink>
  for(i = 0; i < NCHILD; i++){
    471c:	0ba1                	addi	s7,s7,8
    471e:	2b05                	addiw	s6,s6,1
    4720:	03bb0e63          	beq	s6,s11,475c <fourfiles+0x21e>
    fname = names[i];
    4724:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    4728:	4581                	li	a1,0
    472a:	8562                	mv	a0,s8
    472c:	00001097          	auipc	ra,0x1
    4730:	f2a080e7          	jalr	-214(ra) # 5656 <open>
    4734:	89aa                	mv	s3,a0
    total = 0;
    4736:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    473a:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    473e:	bf49                	j	46d0 <fourfiles+0x192>
      printf("wrong length %d\n", total);
    4740:	85ca                	mv	a1,s2
    4742:	00003517          	auipc	a0,0x3
    4746:	3ee50513          	addi	a0,a0,1006 # 7b30 <statistics+0x2000>
    474a:	00001097          	auipc	ra,0x1
    474e:	244080e7          	jalr	580(ra) # 598e <printf>
      exit(1);
    4752:	4505                	li	a0,1
    4754:	00001097          	auipc	ra,0x1
    4758:	ec2080e7          	jalr	-318(ra) # 5616 <exit>
}
    475c:	70aa                	ld	ra,168(sp)
    475e:	740a                	ld	s0,160(sp)
    4760:	64ea                	ld	s1,152(sp)
    4762:	694a                	ld	s2,144(sp)
    4764:	69aa                	ld	s3,136(sp)
    4766:	6a0a                	ld	s4,128(sp)
    4768:	7ae6                	ld	s5,120(sp)
    476a:	7b46                	ld	s6,112(sp)
    476c:	7ba6                	ld	s7,104(sp)
    476e:	7c06                	ld	s8,96(sp)
    4770:	6ce6                	ld	s9,88(sp)
    4772:	6d46                	ld	s10,80(sp)
    4774:	6da6                	ld	s11,72(sp)
    4776:	614d                	addi	sp,sp,176
    4778:	8082                	ret

000000000000477a <concreate>:
{
    477a:	7135                	addi	sp,sp,-160
    477c:	ed06                	sd	ra,152(sp)
    477e:	e922                	sd	s0,144(sp)
    4780:	e526                	sd	s1,136(sp)
    4782:	e14a                	sd	s2,128(sp)
    4784:	fcce                	sd	s3,120(sp)
    4786:	f8d2                	sd	s4,112(sp)
    4788:	f4d6                	sd	s5,104(sp)
    478a:	f0da                	sd	s6,96(sp)
    478c:	ecde                	sd	s7,88(sp)
    478e:	1100                	addi	s0,sp,160
    4790:	89aa                	mv	s3,a0
  file[0] = 'C';
    4792:	04300793          	li	a5,67
    4796:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    479a:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    479e:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    47a0:	4b0d                	li	s6,3
    47a2:	4a85                	li	s5,1
      link("C0", file);
    47a4:	00003b97          	auipc	s7,0x3
    47a8:	3a4b8b93          	addi	s7,s7,932 # 7b48 <statistics+0x2018>
  for(i = 0; i < N; i++){
    47ac:	02800a13          	li	s4,40
    47b0:	acc1                	j	4a80 <concreate+0x306>
      link("C0", file);
    47b2:	fa840593          	addi	a1,s0,-88
    47b6:	855e                	mv	a0,s7
    47b8:	00001097          	auipc	ra,0x1
    47bc:	ebe080e7          	jalr	-322(ra) # 5676 <link>
    if(pid == 0) {
    47c0:	a45d                	j	4a66 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    47c2:	4795                	li	a5,5
    47c4:	02f9693b          	remw	s2,s2,a5
    47c8:	4785                	li	a5,1
    47ca:	02f90b63          	beq	s2,a5,4800 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    47ce:	20200593          	li	a1,514
    47d2:	fa840513          	addi	a0,s0,-88
    47d6:	00001097          	auipc	ra,0x1
    47da:	e80080e7          	jalr	-384(ra) # 5656 <open>
      if(fd < 0){
    47de:	26055b63          	bgez	a0,4a54 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    47e2:	fa840593          	addi	a1,s0,-88
    47e6:	00003517          	auipc	a0,0x3
    47ea:	36a50513          	addi	a0,a0,874 # 7b50 <statistics+0x2020>
    47ee:	00001097          	auipc	ra,0x1
    47f2:	1a0080e7          	jalr	416(ra) # 598e <printf>
        exit(1);
    47f6:	4505                	li	a0,1
    47f8:	00001097          	auipc	ra,0x1
    47fc:	e1e080e7          	jalr	-482(ra) # 5616 <exit>
      link("C0", file);
    4800:	fa840593          	addi	a1,s0,-88
    4804:	00003517          	auipc	a0,0x3
    4808:	34450513          	addi	a0,a0,836 # 7b48 <statistics+0x2018>
    480c:	00001097          	auipc	ra,0x1
    4810:	e6a080e7          	jalr	-406(ra) # 5676 <link>
      exit(0);
    4814:	4501                	li	a0,0
    4816:	00001097          	auipc	ra,0x1
    481a:	e00080e7          	jalr	-512(ra) # 5616 <exit>
        exit(1);
    481e:	4505                	li	a0,1
    4820:	00001097          	auipc	ra,0x1
    4824:	df6080e7          	jalr	-522(ra) # 5616 <exit>
  memset(fa, 0, sizeof(fa));
    4828:	02800613          	li	a2,40
    482c:	4581                	li	a1,0
    482e:	f8040513          	addi	a0,s0,-128
    4832:	00001097          	auipc	ra,0x1
    4836:	be0080e7          	jalr	-1056(ra) # 5412 <memset>
  fd = open(".", 0);
    483a:	4581                	li	a1,0
    483c:	00002517          	auipc	a0,0x2
    4840:	d6c50513          	addi	a0,a0,-660 # 65a8 <statistics+0xa78>
    4844:	00001097          	auipc	ra,0x1
    4848:	e12080e7          	jalr	-494(ra) # 5656 <open>
    484c:	892a                	mv	s2,a0
  n = 0;
    484e:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4850:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4854:	02700b13          	li	s6,39
      fa[i] = 1;
    4858:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    485a:	a03d                	j	4888 <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    485c:	f7240613          	addi	a2,s0,-142
    4860:	85ce                	mv	a1,s3
    4862:	00003517          	auipc	a0,0x3
    4866:	30e50513          	addi	a0,a0,782 # 7b70 <statistics+0x2040>
    486a:	00001097          	auipc	ra,0x1
    486e:	124080e7          	jalr	292(ra) # 598e <printf>
        exit(1);
    4872:	4505                	li	a0,1
    4874:	00001097          	auipc	ra,0x1
    4878:	da2080e7          	jalr	-606(ra) # 5616 <exit>
      fa[i] = 1;
    487c:	fb040793          	addi	a5,s0,-80
    4880:	973e                	add	a4,a4,a5
    4882:	fd770823          	sb	s7,-48(a4)
      n++;
    4886:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    4888:	4641                	li	a2,16
    488a:	f7040593          	addi	a1,s0,-144
    488e:	854a                	mv	a0,s2
    4890:	00001097          	auipc	ra,0x1
    4894:	d9e080e7          	jalr	-610(ra) # 562e <read>
    4898:	04a05a63          	blez	a0,48ec <concreate+0x172>
    if(de.inum == 0)
    489c:	f7045783          	lhu	a5,-144(s0)
    48a0:	d7e5                	beqz	a5,4888 <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    48a2:	f7244783          	lbu	a5,-142(s0)
    48a6:	ff4791e3          	bne	a5,s4,4888 <concreate+0x10e>
    48aa:	f7444783          	lbu	a5,-140(s0)
    48ae:	ffe9                	bnez	a5,4888 <concreate+0x10e>
      i = de.name[1] - '0';
    48b0:	f7344783          	lbu	a5,-141(s0)
    48b4:	fd07879b          	addiw	a5,a5,-48
    48b8:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    48bc:	faeb60e3          	bltu	s6,a4,485c <concreate+0xe2>
      if(fa[i]){
    48c0:	fb040793          	addi	a5,s0,-80
    48c4:	97ba                	add	a5,a5,a4
    48c6:	fd07c783          	lbu	a5,-48(a5)
    48ca:	dbcd                	beqz	a5,487c <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    48cc:	f7240613          	addi	a2,s0,-142
    48d0:	85ce                	mv	a1,s3
    48d2:	00003517          	auipc	a0,0x3
    48d6:	2be50513          	addi	a0,a0,702 # 7b90 <statistics+0x2060>
    48da:	00001097          	auipc	ra,0x1
    48de:	0b4080e7          	jalr	180(ra) # 598e <printf>
        exit(1);
    48e2:	4505                	li	a0,1
    48e4:	00001097          	auipc	ra,0x1
    48e8:	d32080e7          	jalr	-718(ra) # 5616 <exit>
  close(fd);
    48ec:	854a                	mv	a0,s2
    48ee:	00001097          	auipc	ra,0x1
    48f2:	d50080e7          	jalr	-688(ra) # 563e <close>
  if(n != N){
    48f6:	02800793          	li	a5,40
    48fa:	00fa9763          	bne	s5,a5,4908 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    48fe:	4a8d                	li	s5,3
    4900:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4902:	02800a13          	li	s4,40
    4906:	a8c9                	j	49d8 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4908:	85ce                	mv	a1,s3
    490a:	00003517          	auipc	a0,0x3
    490e:	2ae50513          	addi	a0,a0,686 # 7bb8 <statistics+0x2088>
    4912:	00001097          	auipc	ra,0x1
    4916:	07c080e7          	jalr	124(ra) # 598e <printf>
    exit(1);
    491a:	4505                	li	a0,1
    491c:	00001097          	auipc	ra,0x1
    4920:	cfa080e7          	jalr	-774(ra) # 5616 <exit>
      printf("%s: fork failed\n", s);
    4924:	85ce                	mv	a1,s3
    4926:	00002517          	auipc	a0,0x2
    492a:	e2250513          	addi	a0,a0,-478 # 6748 <statistics+0xc18>
    492e:	00001097          	auipc	ra,0x1
    4932:	060080e7          	jalr	96(ra) # 598e <printf>
      exit(1);
    4936:	4505                	li	a0,1
    4938:	00001097          	auipc	ra,0x1
    493c:	cde080e7          	jalr	-802(ra) # 5616 <exit>
      close(open(file, 0));
    4940:	4581                	li	a1,0
    4942:	fa840513          	addi	a0,s0,-88
    4946:	00001097          	auipc	ra,0x1
    494a:	d10080e7          	jalr	-752(ra) # 5656 <open>
    494e:	00001097          	auipc	ra,0x1
    4952:	cf0080e7          	jalr	-784(ra) # 563e <close>
      close(open(file, 0));
    4956:	4581                	li	a1,0
    4958:	fa840513          	addi	a0,s0,-88
    495c:	00001097          	auipc	ra,0x1
    4960:	cfa080e7          	jalr	-774(ra) # 5656 <open>
    4964:	00001097          	auipc	ra,0x1
    4968:	cda080e7          	jalr	-806(ra) # 563e <close>
      close(open(file, 0));
    496c:	4581                	li	a1,0
    496e:	fa840513          	addi	a0,s0,-88
    4972:	00001097          	auipc	ra,0x1
    4976:	ce4080e7          	jalr	-796(ra) # 5656 <open>
    497a:	00001097          	auipc	ra,0x1
    497e:	cc4080e7          	jalr	-828(ra) # 563e <close>
      close(open(file, 0));
    4982:	4581                	li	a1,0
    4984:	fa840513          	addi	a0,s0,-88
    4988:	00001097          	auipc	ra,0x1
    498c:	cce080e7          	jalr	-818(ra) # 5656 <open>
    4990:	00001097          	auipc	ra,0x1
    4994:	cae080e7          	jalr	-850(ra) # 563e <close>
      close(open(file, 0));
    4998:	4581                	li	a1,0
    499a:	fa840513          	addi	a0,s0,-88
    499e:	00001097          	auipc	ra,0x1
    49a2:	cb8080e7          	jalr	-840(ra) # 5656 <open>
    49a6:	00001097          	auipc	ra,0x1
    49aa:	c98080e7          	jalr	-872(ra) # 563e <close>
      close(open(file, 0));
    49ae:	4581                	li	a1,0
    49b0:	fa840513          	addi	a0,s0,-88
    49b4:	00001097          	auipc	ra,0x1
    49b8:	ca2080e7          	jalr	-862(ra) # 5656 <open>
    49bc:	00001097          	auipc	ra,0x1
    49c0:	c82080e7          	jalr	-894(ra) # 563e <close>
    if(pid == 0)
    49c4:	08090363          	beqz	s2,4a4a <concreate+0x2d0>
      wait(0);
    49c8:	4501                	li	a0,0
    49ca:	00001097          	auipc	ra,0x1
    49ce:	c54080e7          	jalr	-940(ra) # 561e <wait>
  for(i = 0; i < N; i++){
    49d2:	2485                	addiw	s1,s1,1
    49d4:	0f448563          	beq	s1,s4,4abe <concreate+0x344>
    file[1] = '0' + i;
    49d8:	0304879b          	addiw	a5,s1,48
    49dc:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    49e0:	00001097          	auipc	ra,0x1
    49e4:	c2e080e7          	jalr	-978(ra) # 560e <fork>
    49e8:	892a                	mv	s2,a0
    if(pid < 0){
    49ea:	f2054de3          	bltz	a0,4924 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    49ee:	0354e73b          	remw	a4,s1,s5
    49f2:	00a767b3          	or	a5,a4,a0
    49f6:	2781                	sext.w	a5,a5
    49f8:	d7a1                	beqz	a5,4940 <concreate+0x1c6>
    49fa:	01671363          	bne	a4,s6,4a00 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    49fe:	f129                	bnez	a0,4940 <concreate+0x1c6>
      unlink(file);
    4a00:	fa840513          	addi	a0,s0,-88
    4a04:	00001097          	auipc	ra,0x1
    4a08:	c62080e7          	jalr	-926(ra) # 5666 <unlink>
      unlink(file);
    4a0c:	fa840513          	addi	a0,s0,-88
    4a10:	00001097          	auipc	ra,0x1
    4a14:	c56080e7          	jalr	-938(ra) # 5666 <unlink>
      unlink(file);
    4a18:	fa840513          	addi	a0,s0,-88
    4a1c:	00001097          	auipc	ra,0x1
    4a20:	c4a080e7          	jalr	-950(ra) # 5666 <unlink>
      unlink(file);
    4a24:	fa840513          	addi	a0,s0,-88
    4a28:	00001097          	auipc	ra,0x1
    4a2c:	c3e080e7          	jalr	-962(ra) # 5666 <unlink>
      unlink(file);
    4a30:	fa840513          	addi	a0,s0,-88
    4a34:	00001097          	auipc	ra,0x1
    4a38:	c32080e7          	jalr	-974(ra) # 5666 <unlink>
      unlink(file);
    4a3c:	fa840513          	addi	a0,s0,-88
    4a40:	00001097          	auipc	ra,0x1
    4a44:	c26080e7          	jalr	-986(ra) # 5666 <unlink>
    4a48:	bfb5                	j	49c4 <concreate+0x24a>
      exit(0);
    4a4a:	4501                	li	a0,0
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	bca080e7          	jalr	-1078(ra) # 5616 <exit>
      close(fd);
    4a54:	00001097          	auipc	ra,0x1
    4a58:	bea080e7          	jalr	-1046(ra) # 563e <close>
    if(pid == 0) {
    4a5c:	bb65                	j	4814 <concreate+0x9a>
      close(fd);
    4a5e:	00001097          	auipc	ra,0x1
    4a62:	be0080e7          	jalr	-1056(ra) # 563e <close>
      wait(&xstatus);
    4a66:	f6c40513          	addi	a0,s0,-148
    4a6a:	00001097          	auipc	ra,0x1
    4a6e:	bb4080e7          	jalr	-1100(ra) # 561e <wait>
      if(xstatus != 0)
    4a72:	f6c42483          	lw	s1,-148(s0)
    4a76:	da0494e3          	bnez	s1,481e <concreate+0xa4>
  for(i = 0; i < N; i++){
    4a7a:	2905                	addiw	s2,s2,1
    4a7c:	db4906e3          	beq	s2,s4,4828 <concreate+0xae>
    file[1] = '0' + i;
    4a80:	0309079b          	addiw	a5,s2,48
    4a84:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4a88:	fa840513          	addi	a0,s0,-88
    4a8c:	00001097          	auipc	ra,0x1
    4a90:	bda080e7          	jalr	-1062(ra) # 5666 <unlink>
    pid = fork();
    4a94:	00001097          	auipc	ra,0x1
    4a98:	b7a080e7          	jalr	-1158(ra) # 560e <fork>
    if(pid && (i % 3) == 1){
    4a9c:	d20503e3          	beqz	a0,47c2 <concreate+0x48>
    4aa0:	036967bb          	remw	a5,s2,s6
    4aa4:	d15787e3          	beq	a5,s5,47b2 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4aa8:	20200593          	li	a1,514
    4aac:	fa840513          	addi	a0,s0,-88
    4ab0:	00001097          	auipc	ra,0x1
    4ab4:	ba6080e7          	jalr	-1114(ra) # 5656 <open>
      if(fd < 0){
    4ab8:	fa0553e3          	bgez	a0,4a5e <concreate+0x2e4>
    4abc:	b31d                	j	47e2 <concreate+0x68>
}
    4abe:	60ea                	ld	ra,152(sp)
    4ac0:	644a                	ld	s0,144(sp)
    4ac2:	64aa                	ld	s1,136(sp)
    4ac4:	690a                	ld	s2,128(sp)
    4ac6:	79e6                	ld	s3,120(sp)
    4ac8:	7a46                	ld	s4,112(sp)
    4aca:	7aa6                	ld	s5,104(sp)
    4acc:	7b06                	ld	s6,96(sp)
    4ace:	6be6                	ld	s7,88(sp)
    4ad0:	610d                	addi	sp,sp,160
    4ad2:	8082                	ret

0000000000004ad4 <bigfile>:
{
    4ad4:	7139                	addi	sp,sp,-64
    4ad6:	fc06                	sd	ra,56(sp)
    4ad8:	f822                	sd	s0,48(sp)
    4ada:	f426                	sd	s1,40(sp)
    4adc:	f04a                	sd	s2,32(sp)
    4ade:	ec4e                	sd	s3,24(sp)
    4ae0:	e852                	sd	s4,16(sp)
    4ae2:	e456                	sd	s5,8(sp)
    4ae4:	0080                	addi	s0,sp,64
    4ae6:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4ae8:	00003517          	auipc	a0,0x3
    4aec:	10850513          	addi	a0,a0,264 # 7bf0 <statistics+0x20c0>
    4af0:	00001097          	auipc	ra,0x1
    4af4:	b76080e7          	jalr	-1162(ra) # 5666 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4af8:	20200593          	li	a1,514
    4afc:	00003517          	auipc	a0,0x3
    4b00:	0f450513          	addi	a0,a0,244 # 7bf0 <statistics+0x20c0>
    4b04:	00001097          	auipc	ra,0x1
    4b08:	b52080e7          	jalr	-1198(ra) # 5656 <open>
    4b0c:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4b0e:	4481                	li	s1,0
    memset(buf, i, SZ);
    4b10:	00007917          	auipc	s2,0x7
    4b14:	04090913          	addi	s2,s2,64 # bb50 <buf>
  for(i = 0; i < N; i++){
    4b18:	4a51                	li	s4,20
  if(fd < 0){
    4b1a:	0a054063          	bltz	a0,4bba <bigfile+0xe6>
    memset(buf, i, SZ);
    4b1e:	25800613          	li	a2,600
    4b22:	85a6                	mv	a1,s1
    4b24:	854a                	mv	a0,s2
    4b26:	00001097          	auipc	ra,0x1
    4b2a:	8ec080e7          	jalr	-1812(ra) # 5412 <memset>
    if(write(fd, buf, SZ) != SZ){
    4b2e:	25800613          	li	a2,600
    4b32:	85ca                	mv	a1,s2
    4b34:	854e                	mv	a0,s3
    4b36:	00001097          	auipc	ra,0x1
    4b3a:	b00080e7          	jalr	-1280(ra) # 5636 <write>
    4b3e:	25800793          	li	a5,600
    4b42:	08f51a63          	bne	a0,a5,4bd6 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4b46:	2485                	addiw	s1,s1,1
    4b48:	fd449be3          	bne	s1,s4,4b1e <bigfile+0x4a>
  close(fd);
    4b4c:	854e                	mv	a0,s3
    4b4e:	00001097          	auipc	ra,0x1
    4b52:	af0080e7          	jalr	-1296(ra) # 563e <close>
  fd = open("bigfile.dat", 0);
    4b56:	4581                	li	a1,0
    4b58:	00003517          	auipc	a0,0x3
    4b5c:	09850513          	addi	a0,a0,152 # 7bf0 <statistics+0x20c0>
    4b60:	00001097          	auipc	ra,0x1
    4b64:	af6080e7          	jalr	-1290(ra) # 5656 <open>
    4b68:	8a2a                	mv	s4,a0
  total = 0;
    4b6a:	4981                	li	s3,0
  for(i = 0; ; i++){
    4b6c:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4b6e:	00007917          	auipc	s2,0x7
    4b72:	fe290913          	addi	s2,s2,-30 # bb50 <buf>
  if(fd < 0){
    4b76:	06054e63          	bltz	a0,4bf2 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4b7a:	12c00613          	li	a2,300
    4b7e:	85ca                	mv	a1,s2
    4b80:	8552                	mv	a0,s4
    4b82:	00001097          	auipc	ra,0x1
    4b86:	aac080e7          	jalr	-1364(ra) # 562e <read>
    if(cc < 0){
    4b8a:	08054263          	bltz	a0,4c0e <bigfile+0x13a>
    if(cc == 0)
    4b8e:	c971                	beqz	a0,4c62 <bigfile+0x18e>
    if(cc != SZ/2){
    4b90:	12c00793          	li	a5,300
    4b94:	08f51b63          	bne	a0,a5,4c2a <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4b98:	01f4d79b          	srliw	a5,s1,0x1f
    4b9c:	9fa5                	addw	a5,a5,s1
    4b9e:	4017d79b          	sraiw	a5,a5,0x1
    4ba2:	00094703          	lbu	a4,0(s2)
    4ba6:	0af71063          	bne	a4,a5,4c46 <bigfile+0x172>
    4baa:	12b94703          	lbu	a4,299(s2)
    4bae:	08f71c63          	bne	a4,a5,4c46 <bigfile+0x172>
    total += cc;
    4bb2:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4bb6:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4bb8:	b7c9                	j	4b7a <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4bba:	85d6                	mv	a1,s5
    4bbc:	00003517          	auipc	a0,0x3
    4bc0:	04450513          	addi	a0,a0,68 # 7c00 <statistics+0x20d0>
    4bc4:	00001097          	auipc	ra,0x1
    4bc8:	dca080e7          	jalr	-566(ra) # 598e <printf>
    exit(1);
    4bcc:	4505                	li	a0,1
    4bce:	00001097          	auipc	ra,0x1
    4bd2:	a48080e7          	jalr	-1464(ra) # 5616 <exit>
      printf("%s: write bigfile failed\n", s);
    4bd6:	85d6                	mv	a1,s5
    4bd8:	00003517          	auipc	a0,0x3
    4bdc:	04850513          	addi	a0,a0,72 # 7c20 <statistics+0x20f0>
    4be0:	00001097          	auipc	ra,0x1
    4be4:	dae080e7          	jalr	-594(ra) # 598e <printf>
      exit(1);
    4be8:	4505                	li	a0,1
    4bea:	00001097          	auipc	ra,0x1
    4bee:	a2c080e7          	jalr	-1492(ra) # 5616 <exit>
    printf("%s: cannot open bigfile\n", s);
    4bf2:	85d6                	mv	a1,s5
    4bf4:	00003517          	auipc	a0,0x3
    4bf8:	04c50513          	addi	a0,a0,76 # 7c40 <statistics+0x2110>
    4bfc:	00001097          	auipc	ra,0x1
    4c00:	d92080e7          	jalr	-622(ra) # 598e <printf>
    exit(1);
    4c04:	4505                	li	a0,1
    4c06:	00001097          	auipc	ra,0x1
    4c0a:	a10080e7          	jalr	-1520(ra) # 5616 <exit>
      printf("%s: read bigfile failed\n", s);
    4c0e:	85d6                	mv	a1,s5
    4c10:	00003517          	auipc	a0,0x3
    4c14:	05050513          	addi	a0,a0,80 # 7c60 <statistics+0x2130>
    4c18:	00001097          	auipc	ra,0x1
    4c1c:	d76080e7          	jalr	-650(ra) # 598e <printf>
      exit(1);
    4c20:	4505                	li	a0,1
    4c22:	00001097          	auipc	ra,0x1
    4c26:	9f4080e7          	jalr	-1548(ra) # 5616 <exit>
      printf("%s: short read bigfile\n", s);
    4c2a:	85d6                	mv	a1,s5
    4c2c:	00003517          	auipc	a0,0x3
    4c30:	05450513          	addi	a0,a0,84 # 7c80 <statistics+0x2150>
    4c34:	00001097          	auipc	ra,0x1
    4c38:	d5a080e7          	jalr	-678(ra) # 598e <printf>
      exit(1);
    4c3c:	4505                	li	a0,1
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	9d8080e7          	jalr	-1576(ra) # 5616 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4c46:	85d6                	mv	a1,s5
    4c48:	00003517          	auipc	a0,0x3
    4c4c:	05050513          	addi	a0,a0,80 # 7c98 <statistics+0x2168>
    4c50:	00001097          	auipc	ra,0x1
    4c54:	d3e080e7          	jalr	-706(ra) # 598e <printf>
      exit(1);
    4c58:	4505                	li	a0,1
    4c5a:	00001097          	auipc	ra,0x1
    4c5e:	9bc080e7          	jalr	-1604(ra) # 5616 <exit>
  close(fd);
    4c62:	8552                	mv	a0,s4
    4c64:	00001097          	auipc	ra,0x1
    4c68:	9da080e7          	jalr	-1574(ra) # 563e <close>
  if(total != N*SZ){
    4c6c:	678d                	lui	a5,0x3
    4c6e:	ee078793          	addi	a5,a5,-288 # 2ee0 <exitiputtest+0x46>
    4c72:	02f99363          	bne	s3,a5,4c98 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4c76:	00003517          	auipc	a0,0x3
    4c7a:	f7a50513          	addi	a0,a0,-134 # 7bf0 <statistics+0x20c0>
    4c7e:	00001097          	auipc	ra,0x1
    4c82:	9e8080e7          	jalr	-1560(ra) # 5666 <unlink>
}
    4c86:	70e2                	ld	ra,56(sp)
    4c88:	7442                	ld	s0,48(sp)
    4c8a:	74a2                	ld	s1,40(sp)
    4c8c:	7902                	ld	s2,32(sp)
    4c8e:	69e2                	ld	s3,24(sp)
    4c90:	6a42                	ld	s4,16(sp)
    4c92:	6aa2                	ld	s5,8(sp)
    4c94:	6121                	addi	sp,sp,64
    4c96:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4c98:	85d6                	mv	a1,s5
    4c9a:	00003517          	auipc	a0,0x3
    4c9e:	01e50513          	addi	a0,a0,30 # 7cb8 <statistics+0x2188>
    4ca2:	00001097          	auipc	ra,0x1
    4ca6:	cec080e7          	jalr	-788(ra) # 598e <printf>
    exit(1);
    4caa:	4505                	li	a0,1
    4cac:	00001097          	auipc	ra,0x1
    4cb0:	96a080e7          	jalr	-1686(ra) # 5616 <exit>

0000000000004cb4 <fsfull>:
{
    4cb4:	7171                	addi	sp,sp,-176
    4cb6:	f506                	sd	ra,168(sp)
    4cb8:	f122                	sd	s0,160(sp)
    4cba:	ed26                	sd	s1,152(sp)
    4cbc:	e94a                	sd	s2,144(sp)
    4cbe:	e54e                	sd	s3,136(sp)
    4cc0:	e152                	sd	s4,128(sp)
    4cc2:	fcd6                	sd	s5,120(sp)
    4cc4:	f8da                	sd	s6,112(sp)
    4cc6:	f4de                	sd	s7,104(sp)
    4cc8:	f0e2                	sd	s8,96(sp)
    4cca:	ece6                	sd	s9,88(sp)
    4ccc:	e8ea                	sd	s10,80(sp)
    4cce:	e4ee                	sd	s11,72(sp)
    4cd0:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4cd2:	00003517          	auipc	a0,0x3
    4cd6:	00650513          	addi	a0,a0,6 # 7cd8 <statistics+0x21a8>
    4cda:	00001097          	auipc	ra,0x1
    4cde:	cb4080e7          	jalr	-844(ra) # 598e <printf>
  for(nfiles = 0; ; nfiles++){
    4ce2:	4481                	li	s1,0
    name[0] = 'f';
    4ce4:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4ce8:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4cec:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4cf0:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4cf2:	00003c97          	auipc	s9,0x3
    4cf6:	ff6c8c93          	addi	s9,s9,-10 # 7ce8 <statistics+0x21b8>
    int total = 0;
    4cfa:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4cfc:	00007a17          	auipc	s4,0x7
    4d00:	e54a0a13          	addi	s4,s4,-428 # bb50 <buf>
    name[0] = 'f';
    4d04:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d08:	0384c7bb          	divw	a5,s1,s8
    4d0c:	0307879b          	addiw	a5,a5,48
    4d10:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4d14:	0384e7bb          	remw	a5,s1,s8
    4d18:	0377c7bb          	divw	a5,a5,s7
    4d1c:	0307879b          	addiw	a5,a5,48
    4d20:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4d24:	0374e7bb          	remw	a5,s1,s7
    4d28:	0367c7bb          	divw	a5,a5,s6
    4d2c:	0307879b          	addiw	a5,a5,48
    4d30:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4d34:	0364e7bb          	remw	a5,s1,s6
    4d38:	0307879b          	addiw	a5,a5,48
    4d3c:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4d40:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4d44:	f5040593          	addi	a1,s0,-176
    4d48:	8566                	mv	a0,s9
    4d4a:	00001097          	auipc	ra,0x1
    4d4e:	c44080e7          	jalr	-956(ra) # 598e <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4d52:	20200593          	li	a1,514
    4d56:	f5040513          	addi	a0,s0,-176
    4d5a:	00001097          	auipc	ra,0x1
    4d5e:	8fc080e7          	jalr	-1796(ra) # 5656 <open>
    4d62:	892a                	mv	s2,a0
    if(fd < 0){
    4d64:	0a055663          	bgez	a0,4e10 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4d68:	f5040593          	addi	a1,s0,-176
    4d6c:	00003517          	auipc	a0,0x3
    4d70:	f8c50513          	addi	a0,a0,-116 # 7cf8 <statistics+0x21c8>
    4d74:	00001097          	auipc	ra,0x1
    4d78:	c1a080e7          	jalr	-998(ra) # 598e <printf>
  while(nfiles >= 0){
    4d7c:	0604c363          	bltz	s1,4de2 <fsfull+0x12e>
    name[0] = 'f';
    4d80:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4d84:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d88:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d8c:	4929                	li	s2,10
  while(nfiles >= 0){
    4d8e:	5afd                	li	s5,-1
    name[0] = 'f';
    4d90:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d94:	0344c7bb          	divw	a5,s1,s4
    4d98:	0307879b          	addiw	a5,a5,48
    4d9c:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4da0:	0344e7bb          	remw	a5,s1,s4
    4da4:	0337c7bb          	divw	a5,a5,s3
    4da8:	0307879b          	addiw	a5,a5,48
    4dac:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4db0:	0334e7bb          	remw	a5,s1,s3
    4db4:	0327c7bb          	divw	a5,a5,s2
    4db8:	0307879b          	addiw	a5,a5,48
    4dbc:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4dc0:	0324e7bb          	remw	a5,s1,s2
    4dc4:	0307879b          	addiw	a5,a5,48
    4dc8:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4dcc:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4dd0:	f5040513          	addi	a0,s0,-176
    4dd4:	00001097          	auipc	ra,0x1
    4dd8:	892080e7          	jalr	-1902(ra) # 5666 <unlink>
    nfiles--;
    4ddc:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4dde:	fb5499e3          	bne	s1,s5,4d90 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4de2:	00003517          	auipc	a0,0x3
    4de6:	f3650513          	addi	a0,a0,-202 # 7d18 <statistics+0x21e8>
    4dea:	00001097          	auipc	ra,0x1
    4dee:	ba4080e7          	jalr	-1116(ra) # 598e <printf>
}
    4df2:	70aa                	ld	ra,168(sp)
    4df4:	740a                	ld	s0,160(sp)
    4df6:	64ea                	ld	s1,152(sp)
    4df8:	694a                	ld	s2,144(sp)
    4dfa:	69aa                	ld	s3,136(sp)
    4dfc:	6a0a                	ld	s4,128(sp)
    4dfe:	7ae6                	ld	s5,120(sp)
    4e00:	7b46                	ld	s6,112(sp)
    4e02:	7ba6                	ld	s7,104(sp)
    4e04:	7c06                	ld	s8,96(sp)
    4e06:	6ce6                	ld	s9,88(sp)
    4e08:	6d46                	ld	s10,80(sp)
    4e0a:	6da6                	ld	s11,72(sp)
    4e0c:	614d                	addi	sp,sp,176
    4e0e:	8082                	ret
    int total = 0;
    4e10:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4e12:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4e16:	40000613          	li	a2,1024
    4e1a:	85d2                	mv	a1,s4
    4e1c:	854a                	mv	a0,s2
    4e1e:	00001097          	auipc	ra,0x1
    4e22:	818080e7          	jalr	-2024(ra) # 5636 <write>
      if(cc < BSIZE)
    4e26:	00aad563          	bge	s5,a0,4e30 <fsfull+0x17c>
      total += cc;
    4e2a:	00a989bb          	addw	s3,s3,a0
    while(1){
    4e2e:	b7e5                	j	4e16 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4e30:	85ce                	mv	a1,s3
    4e32:	00003517          	auipc	a0,0x3
    4e36:	ed650513          	addi	a0,a0,-298 # 7d08 <statistics+0x21d8>
    4e3a:	00001097          	auipc	ra,0x1
    4e3e:	b54080e7          	jalr	-1196(ra) # 598e <printf>
    close(fd);
    4e42:	854a                	mv	a0,s2
    4e44:	00000097          	auipc	ra,0x0
    4e48:	7fa080e7          	jalr	2042(ra) # 563e <close>
    if(total == 0)
    4e4c:	f20988e3          	beqz	s3,4d7c <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4e50:	2485                	addiw	s1,s1,1
    4e52:	bd4d                	j	4d04 <fsfull+0x50>

0000000000004e54 <rand>:
{
    4e54:	1141                	addi	sp,sp,-16
    4e56:	e422                	sd	s0,8(sp)
    4e58:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4e5a:	00003717          	auipc	a4,0x3
    4e5e:	4ce70713          	addi	a4,a4,1230 # 8328 <randstate>
    4e62:	6308                	ld	a0,0(a4)
    4e64:	001967b7          	lui	a5,0x196
    4e68:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187aad>
    4e6c:	02f50533          	mul	a0,a0,a5
    4e70:	3c6ef7b7          	lui	a5,0x3c6ef
    4e74:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e07ff>
    4e78:	953e                	add	a0,a0,a5
    4e7a:	e308                	sd	a0,0(a4)
}
    4e7c:	2501                	sext.w	a0,a0
    4e7e:	6422                	ld	s0,8(sp)
    4e80:	0141                	addi	sp,sp,16
    4e82:	8082                	ret

0000000000004e84 <badwrite>:
{
    4e84:	7179                	addi	sp,sp,-48
    4e86:	f406                	sd	ra,40(sp)
    4e88:	f022                	sd	s0,32(sp)
    4e8a:	ec26                	sd	s1,24(sp)
    4e8c:	e84a                	sd	s2,16(sp)
    4e8e:	e44e                	sd	s3,8(sp)
    4e90:	e052                	sd	s4,0(sp)
    4e92:	1800                	addi	s0,sp,48
  unlink("junk");
    4e94:	00003517          	auipc	a0,0x3
    4e98:	e9c50513          	addi	a0,a0,-356 # 7d30 <statistics+0x2200>
    4e9c:	00000097          	auipc	ra,0x0
    4ea0:	7ca080e7          	jalr	1994(ra) # 5666 <unlink>
    4ea4:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4ea8:	00003997          	auipc	s3,0x3
    4eac:	e8898993          	addi	s3,s3,-376 # 7d30 <statistics+0x2200>
    write(fd, (char*)0xffffffffffL, 1);
    4eb0:	5a7d                	li	s4,-1
    4eb2:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4eb6:	20100593          	li	a1,513
    4eba:	854e                	mv	a0,s3
    4ebc:	00000097          	auipc	ra,0x0
    4ec0:	79a080e7          	jalr	1946(ra) # 5656 <open>
    4ec4:	84aa                	mv	s1,a0
    if(fd < 0){
    4ec6:	06054b63          	bltz	a0,4f3c <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4eca:	4605                	li	a2,1
    4ecc:	85d2                	mv	a1,s4
    4ece:	00000097          	auipc	ra,0x0
    4ed2:	768080e7          	jalr	1896(ra) # 5636 <write>
    close(fd);
    4ed6:	8526                	mv	a0,s1
    4ed8:	00000097          	auipc	ra,0x0
    4edc:	766080e7          	jalr	1894(ra) # 563e <close>
    unlink("junk");
    4ee0:	854e                	mv	a0,s3
    4ee2:	00000097          	auipc	ra,0x0
    4ee6:	784080e7          	jalr	1924(ra) # 5666 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4eea:	397d                	addiw	s2,s2,-1
    4eec:	fc0915e3          	bnez	s2,4eb6 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4ef0:	20100593          	li	a1,513
    4ef4:	00003517          	auipc	a0,0x3
    4ef8:	e3c50513          	addi	a0,a0,-452 # 7d30 <statistics+0x2200>
    4efc:	00000097          	auipc	ra,0x0
    4f00:	75a080e7          	jalr	1882(ra) # 5656 <open>
    4f04:	84aa                	mv	s1,a0
  if(fd < 0){
    4f06:	04054863          	bltz	a0,4f56 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4f0a:	4605                	li	a2,1
    4f0c:	00001597          	auipc	a1,0x1
    4f10:	07458593          	addi	a1,a1,116 # 5f80 <statistics+0x450>
    4f14:	00000097          	auipc	ra,0x0
    4f18:	722080e7          	jalr	1826(ra) # 5636 <write>
    4f1c:	4785                	li	a5,1
    4f1e:	04f50963          	beq	a0,a5,4f70 <badwrite+0xec>
    printf("write failed\n");
    4f22:	00003517          	auipc	a0,0x3
    4f26:	e2e50513          	addi	a0,a0,-466 # 7d50 <statistics+0x2220>
    4f2a:	00001097          	auipc	ra,0x1
    4f2e:	a64080e7          	jalr	-1436(ra) # 598e <printf>
    exit(1);
    4f32:	4505                	li	a0,1
    4f34:	00000097          	auipc	ra,0x0
    4f38:	6e2080e7          	jalr	1762(ra) # 5616 <exit>
      printf("open junk failed\n");
    4f3c:	00003517          	auipc	a0,0x3
    4f40:	dfc50513          	addi	a0,a0,-516 # 7d38 <statistics+0x2208>
    4f44:	00001097          	auipc	ra,0x1
    4f48:	a4a080e7          	jalr	-1462(ra) # 598e <printf>
      exit(1);
    4f4c:	4505                	li	a0,1
    4f4e:	00000097          	auipc	ra,0x0
    4f52:	6c8080e7          	jalr	1736(ra) # 5616 <exit>
    printf("open junk failed\n");
    4f56:	00003517          	auipc	a0,0x3
    4f5a:	de250513          	addi	a0,a0,-542 # 7d38 <statistics+0x2208>
    4f5e:	00001097          	auipc	ra,0x1
    4f62:	a30080e7          	jalr	-1488(ra) # 598e <printf>
    exit(1);
    4f66:	4505                	li	a0,1
    4f68:	00000097          	auipc	ra,0x0
    4f6c:	6ae080e7          	jalr	1710(ra) # 5616 <exit>
  close(fd);
    4f70:	8526                	mv	a0,s1
    4f72:	00000097          	auipc	ra,0x0
    4f76:	6cc080e7          	jalr	1740(ra) # 563e <close>
  unlink("junk");
    4f7a:	00003517          	auipc	a0,0x3
    4f7e:	db650513          	addi	a0,a0,-586 # 7d30 <statistics+0x2200>
    4f82:	00000097          	auipc	ra,0x0
    4f86:	6e4080e7          	jalr	1764(ra) # 5666 <unlink>
  exit(0);
    4f8a:	4501                	li	a0,0
    4f8c:	00000097          	auipc	ra,0x0
    4f90:	68a080e7          	jalr	1674(ra) # 5616 <exit>

0000000000004f94 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4f94:	7139                	addi	sp,sp,-64
    4f96:	fc06                	sd	ra,56(sp)
    4f98:	f822                	sd	s0,48(sp)
    4f9a:	f426                	sd	s1,40(sp)
    4f9c:	f04a                	sd	s2,32(sp)
    4f9e:	ec4e                	sd	s3,24(sp)
    4fa0:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4fa2:	fc840513          	addi	a0,s0,-56
    4fa6:	00000097          	auipc	ra,0x0
    4faa:	680080e7          	jalr	1664(ra) # 5626 <pipe>
    4fae:	06054863          	bltz	a0,501e <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4fb2:	00000097          	auipc	ra,0x0
    4fb6:	65c080e7          	jalr	1628(ra) # 560e <fork>

  if(pid < 0){
    4fba:	06054f63          	bltz	a0,5038 <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4fbe:	ed59                	bnez	a0,505c <countfree+0xc8>
    close(fds[0]);
    4fc0:	fc842503          	lw	a0,-56(s0)
    4fc4:	00000097          	auipc	ra,0x0
    4fc8:	67a080e7          	jalr	1658(ra) # 563e <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4fcc:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4fce:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4fd0:	00001917          	auipc	s2,0x1
    4fd4:	fb090913          	addi	s2,s2,-80 # 5f80 <statistics+0x450>
      uint64 a = (uint64) sbrk(4096);
    4fd8:	6505                	lui	a0,0x1
    4fda:	00000097          	auipc	ra,0x0
    4fde:	6c4080e7          	jalr	1732(ra) # 569e <sbrk>
      if(a == 0xffffffffffffffff){
    4fe2:	06950863          	beq	a0,s1,5052 <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    4fe6:	6785                	lui	a5,0x1
    4fe8:	953e                	add	a0,a0,a5
    4fea:	ff350fa3          	sb	s3,-1(a0) # fff <bigdir+0x9d>
      if(write(fds[1], "x", 1) != 1){
    4fee:	4605                	li	a2,1
    4ff0:	85ca                	mv	a1,s2
    4ff2:	fcc42503          	lw	a0,-52(s0)
    4ff6:	00000097          	auipc	ra,0x0
    4ffa:	640080e7          	jalr	1600(ra) # 5636 <write>
    4ffe:	4785                	li	a5,1
    5000:	fcf50ce3          	beq	a0,a5,4fd8 <countfree+0x44>
        printf("write() failed in countfree()\n");
    5004:	00003517          	auipc	a0,0x3
    5008:	d9c50513          	addi	a0,a0,-612 # 7da0 <statistics+0x2270>
    500c:	00001097          	auipc	ra,0x1
    5010:	982080e7          	jalr	-1662(ra) # 598e <printf>
        exit(1);
    5014:	4505                	li	a0,1
    5016:	00000097          	auipc	ra,0x0
    501a:	600080e7          	jalr	1536(ra) # 5616 <exit>
    printf("pipe() failed in countfree()\n");
    501e:	00003517          	auipc	a0,0x3
    5022:	d4250513          	addi	a0,a0,-702 # 7d60 <statistics+0x2230>
    5026:	00001097          	auipc	ra,0x1
    502a:	968080e7          	jalr	-1688(ra) # 598e <printf>
    exit(1);
    502e:	4505                	li	a0,1
    5030:	00000097          	auipc	ra,0x0
    5034:	5e6080e7          	jalr	1510(ra) # 5616 <exit>
    printf("fork failed in countfree()\n");
    5038:	00003517          	auipc	a0,0x3
    503c:	d4850513          	addi	a0,a0,-696 # 7d80 <statistics+0x2250>
    5040:	00001097          	auipc	ra,0x1
    5044:	94e080e7          	jalr	-1714(ra) # 598e <printf>
    exit(1);
    5048:	4505                	li	a0,1
    504a:	00000097          	auipc	ra,0x0
    504e:	5cc080e7          	jalr	1484(ra) # 5616 <exit>
      }
    }

    exit(0);
    5052:	4501                	li	a0,0
    5054:	00000097          	auipc	ra,0x0
    5058:	5c2080e7          	jalr	1474(ra) # 5616 <exit>
  }

  close(fds[1]);
    505c:	fcc42503          	lw	a0,-52(s0)
    5060:	00000097          	auipc	ra,0x0
    5064:	5de080e7          	jalr	1502(ra) # 563e <close>

  int n = 0;
    5068:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    506a:	4605                	li	a2,1
    506c:	fc740593          	addi	a1,s0,-57
    5070:	fc842503          	lw	a0,-56(s0)
    5074:	00000097          	auipc	ra,0x0
    5078:	5ba080e7          	jalr	1466(ra) # 562e <read>
    if(cc < 0){
    507c:	00054563          	bltz	a0,5086 <countfree+0xf2>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5080:	c105                	beqz	a0,50a0 <countfree+0x10c>
      break;
    n += 1;
    5082:	2485                	addiw	s1,s1,1
  while(1){
    5084:	b7dd                	j	506a <countfree+0xd6>
      printf("read() failed in countfree()\n");
    5086:	00003517          	auipc	a0,0x3
    508a:	d3a50513          	addi	a0,a0,-710 # 7dc0 <statistics+0x2290>
    508e:	00001097          	auipc	ra,0x1
    5092:	900080e7          	jalr	-1792(ra) # 598e <printf>
      exit(1);
    5096:	4505                	li	a0,1
    5098:	00000097          	auipc	ra,0x0
    509c:	57e080e7          	jalr	1406(ra) # 5616 <exit>
  }

  close(fds[0]);
    50a0:	fc842503          	lw	a0,-56(s0)
    50a4:	00000097          	auipc	ra,0x0
    50a8:	59a080e7          	jalr	1434(ra) # 563e <close>
  wait((int*)0);
    50ac:	4501                	li	a0,0
    50ae:	00000097          	auipc	ra,0x0
    50b2:	570080e7          	jalr	1392(ra) # 561e <wait>
  
  return n;
}
    50b6:	8526                	mv	a0,s1
    50b8:	70e2                	ld	ra,56(sp)
    50ba:	7442                	ld	s0,48(sp)
    50bc:	74a2                	ld	s1,40(sp)
    50be:	7902                	ld	s2,32(sp)
    50c0:	69e2                	ld	s3,24(sp)
    50c2:	6121                	addi	sp,sp,64
    50c4:	8082                	ret

00000000000050c6 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    50c6:	7179                	addi	sp,sp,-48
    50c8:	f406                	sd	ra,40(sp)
    50ca:	f022                	sd	s0,32(sp)
    50cc:	ec26                	sd	s1,24(sp)
    50ce:	e84a                	sd	s2,16(sp)
    50d0:	1800                	addi	s0,sp,48
    50d2:	84aa                	mv	s1,a0
    50d4:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    50d6:	00003517          	auipc	a0,0x3
    50da:	d0a50513          	addi	a0,a0,-758 # 7de0 <statistics+0x22b0>
    50de:	00001097          	auipc	ra,0x1
    50e2:	8b0080e7          	jalr	-1872(ra) # 598e <printf>
  if((pid = fork()) < 0) {
    50e6:	00000097          	auipc	ra,0x0
    50ea:	528080e7          	jalr	1320(ra) # 560e <fork>
    50ee:	02054e63          	bltz	a0,512a <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    50f2:	c929                	beqz	a0,5144 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    50f4:	fdc40513          	addi	a0,s0,-36
    50f8:	00000097          	auipc	ra,0x0
    50fc:	526080e7          	jalr	1318(ra) # 561e <wait>
    if(xstatus != 0) 
    5100:	fdc42783          	lw	a5,-36(s0)
    5104:	c7b9                	beqz	a5,5152 <run+0x8c>
      printf("FAILED\n");
    5106:	00003517          	auipc	a0,0x3
    510a:	d0250513          	addi	a0,a0,-766 # 7e08 <statistics+0x22d8>
    510e:	00001097          	auipc	ra,0x1
    5112:	880080e7          	jalr	-1920(ra) # 598e <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5116:	fdc42503          	lw	a0,-36(s0)
  }
}
    511a:	00153513          	seqz	a0,a0
    511e:	70a2                	ld	ra,40(sp)
    5120:	7402                	ld	s0,32(sp)
    5122:	64e2                	ld	s1,24(sp)
    5124:	6942                	ld	s2,16(sp)
    5126:	6145                	addi	sp,sp,48
    5128:	8082                	ret
    printf("runtest: fork error\n");
    512a:	00003517          	auipc	a0,0x3
    512e:	cc650513          	addi	a0,a0,-826 # 7df0 <statistics+0x22c0>
    5132:	00001097          	auipc	ra,0x1
    5136:	85c080e7          	jalr	-1956(ra) # 598e <printf>
    exit(1);
    513a:	4505                	li	a0,1
    513c:	00000097          	auipc	ra,0x0
    5140:	4da080e7          	jalr	1242(ra) # 5616 <exit>
    f(s);
    5144:	854a                	mv	a0,s2
    5146:	9482                	jalr	s1
    exit(0);
    5148:	4501                	li	a0,0
    514a:	00000097          	auipc	ra,0x0
    514e:	4cc080e7          	jalr	1228(ra) # 5616 <exit>
      printf("OK\n");
    5152:	00003517          	auipc	a0,0x3
    5156:	cbe50513          	addi	a0,a0,-834 # 7e10 <statistics+0x22e0>
    515a:	00001097          	auipc	ra,0x1
    515e:	834080e7          	jalr	-1996(ra) # 598e <printf>
    5162:	bf55                	j	5116 <run+0x50>

0000000000005164 <main>:

int
main(int argc, char *argv[])
{
    5164:	c1010113          	addi	sp,sp,-1008
    5168:	3e113423          	sd	ra,1000(sp)
    516c:	3e813023          	sd	s0,992(sp)
    5170:	3c913c23          	sd	s1,984(sp)
    5174:	3d213823          	sd	s2,976(sp)
    5178:	3d313423          	sd	s3,968(sp)
    517c:	3d413023          	sd	s4,960(sp)
    5180:	3b513c23          	sd	s5,952(sp)
    5184:	3b613823          	sd	s6,944(sp)
    5188:	1f80                	addi	s0,sp,1008
    518a:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    518c:	4789                	li	a5,2
    518e:	08f50b63          	beq	a0,a5,5224 <main+0xc0>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5192:	4785                	li	a5,1
  char *justone = 0;
    5194:	4901                	li	s2,0
  } else if(argc > 1){
    5196:	0ca7c563          	blt	a5,a0,5260 <main+0xfc>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    519a:	00003797          	auipc	a5,0x3
    519e:	d8e78793          	addi	a5,a5,-626 # 7f28 <statistics+0x23f8>
    51a2:	c1040713          	addi	a4,s0,-1008
    51a6:	00003817          	auipc	a6,0x3
    51aa:	12280813          	addi	a6,a6,290 # 82c8 <statistics+0x2798>
    51ae:	6388                	ld	a0,0(a5)
    51b0:	678c                	ld	a1,8(a5)
    51b2:	6b90                	ld	a2,16(a5)
    51b4:	6f94                	ld	a3,24(a5)
    51b6:	e308                	sd	a0,0(a4)
    51b8:	e70c                	sd	a1,8(a4)
    51ba:	eb10                	sd	a2,16(a4)
    51bc:	ef14                	sd	a3,24(a4)
    51be:	02078793          	addi	a5,a5,32
    51c2:	02070713          	addi	a4,a4,32
    51c6:	ff0794e3          	bne	a5,a6,51ae <main+0x4a>
    51ca:	6394                	ld	a3,0(a5)
    51cc:	679c                	ld	a5,8(a5)
    51ce:	e314                	sd	a3,0(a4)
    51d0:	e71c                	sd	a5,8(a4)
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    51d2:	00003517          	auipc	a0,0x3
    51d6:	cf650513          	addi	a0,a0,-778 # 7ec8 <statistics+0x2398>
    51da:	00000097          	auipc	ra,0x0
    51de:	7b4080e7          	jalr	1972(ra) # 598e <printf>
  int free0 = countfree();
    51e2:	00000097          	auipc	ra,0x0
    51e6:	db2080e7          	jalr	-590(ra) # 4f94 <countfree>
    51ea:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    51ec:	c1843503          	ld	a0,-1000(s0)
    51f0:	c1040493          	addi	s1,s0,-1008
  int fail = 0;
    51f4:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    51f6:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    51f8:	e55d                	bnez	a0,52a6 <main+0x142>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    51fa:	00000097          	auipc	ra,0x0
    51fe:	d9a080e7          	jalr	-614(ra) # 4f94 <countfree>
    5202:	85aa                	mv	a1,a0
    5204:	0f455163          	bge	a0,s4,52e6 <main+0x182>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5208:	8652                	mv	a2,s4
    520a:	00003517          	auipc	a0,0x3
    520e:	c7650513          	addi	a0,a0,-906 # 7e80 <statistics+0x2350>
    5212:	00000097          	auipc	ra,0x0
    5216:	77c080e7          	jalr	1916(ra) # 598e <printf>
    exit(1);
    521a:	4505                	li	a0,1
    521c:	00000097          	auipc	ra,0x0
    5220:	3fa080e7          	jalr	1018(ra) # 5616 <exit>
    5224:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5226:	00003597          	auipc	a1,0x3
    522a:	bf258593          	addi	a1,a1,-1038 # 7e18 <statistics+0x22e8>
    522e:	6488                	ld	a0,8(s1)
    5230:	00000097          	auipc	ra,0x0
    5234:	18c080e7          	jalr	396(ra) # 53bc <strcmp>
    5238:	10050563          	beqz	a0,5342 <main+0x1de>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    523c:	00003597          	auipc	a1,0x3
    5240:	cc458593          	addi	a1,a1,-828 # 7f00 <statistics+0x23d0>
    5244:	6488                	ld	a0,8(s1)
    5246:	00000097          	auipc	ra,0x0
    524a:	176080e7          	jalr	374(ra) # 53bc <strcmp>
    524e:	c97d                	beqz	a0,5344 <main+0x1e0>
  } else if(argc == 2 && argv[1][0] != '-'){
    5250:	0084b903          	ld	s2,8(s1)
    5254:	00094703          	lbu	a4,0(s2)
    5258:	02d00793          	li	a5,45
    525c:	f2f71fe3          	bne	a4,a5,519a <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    5260:	00003517          	auipc	a0,0x3
    5264:	bc050513          	addi	a0,a0,-1088 # 7e20 <statistics+0x22f0>
    5268:	00000097          	auipc	ra,0x0
    526c:	726080e7          	jalr	1830(ra) # 598e <printf>
    exit(1);
    5270:	4505                	li	a0,1
    5272:	00000097          	auipc	ra,0x0
    5276:	3a4080e7          	jalr	932(ra) # 5616 <exit>
          exit(1);
    527a:	4505                	li	a0,1
    527c:	00000097          	auipc	ra,0x0
    5280:	39a080e7          	jalr	922(ra) # 5616 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5284:	40a905bb          	subw	a1,s2,a0
    5288:	855a                	mv	a0,s6
    528a:	00000097          	auipc	ra,0x0
    528e:	704080e7          	jalr	1796(ra) # 598e <printf>
        if(continuous != 2)
    5292:	09498463          	beq	s3,s4,531a <main+0x1b6>
          exit(1);
    5296:	4505                	li	a0,1
    5298:	00000097          	auipc	ra,0x0
    529c:	37e080e7          	jalr	894(ra) # 5616 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    52a0:	04c1                	addi	s1,s1,16
    52a2:	6488                	ld	a0,8(s1)
    52a4:	c115                	beqz	a0,52c8 <main+0x164>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    52a6:	00090863          	beqz	s2,52b6 <main+0x152>
    52aa:	85ca                	mv	a1,s2
    52ac:	00000097          	auipc	ra,0x0
    52b0:	110080e7          	jalr	272(ra) # 53bc <strcmp>
    52b4:	f575                	bnez	a0,52a0 <main+0x13c>
      if(!run(t->f, t->s))
    52b6:	648c                	ld	a1,8(s1)
    52b8:	6088                	ld	a0,0(s1)
    52ba:	00000097          	auipc	ra,0x0
    52be:	e0c080e7          	jalr	-500(ra) # 50c6 <run>
    52c2:	fd79                	bnez	a0,52a0 <main+0x13c>
        fail = 1;
    52c4:	89d6                	mv	s3,s5
    52c6:	bfe9                	j	52a0 <main+0x13c>
  if(fail){
    52c8:	f20989e3          	beqz	s3,51fa <main+0x96>
    printf("SOME TESTS FAILED\n");
    52cc:	00003517          	auipc	a0,0x3
    52d0:	b9c50513          	addi	a0,a0,-1124 # 7e68 <statistics+0x2338>
    52d4:	00000097          	auipc	ra,0x0
    52d8:	6ba080e7          	jalr	1722(ra) # 598e <printf>
    exit(1);
    52dc:	4505                	li	a0,1
    52de:	00000097          	auipc	ra,0x0
    52e2:	338080e7          	jalr	824(ra) # 5616 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    52e6:	00003517          	auipc	a0,0x3
    52ea:	bca50513          	addi	a0,a0,-1078 # 7eb0 <statistics+0x2380>
    52ee:	00000097          	auipc	ra,0x0
    52f2:	6a0080e7          	jalr	1696(ra) # 598e <printf>
    exit(0);
    52f6:	4501                	li	a0,0
    52f8:	00000097          	auipc	ra,0x0
    52fc:	31e080e7          	jalr	798(ra) # 5616 <exit>
        printf("SOME TESTS FAILED\n");
    5300:	8556                	mv	a0,s5
    5302:	00000097          	auipc	ra,0x0
    5306:	68c080e7          	jalr	1676(ra) # 598e <printf>
        if(continuous != 2)
    530a:	f74998e3          	bne	s3,s4,527a <main+0x116>
      int free1 = countfree();
    530e:	00000097          	auipc	ra,0x0
    5312:	c86080e7          	jalr	-890(ra) # 4f94 <countfree>
      if(free1 < free0){
    5316:	f72547e3          	blt	a0,s2,5284 <main+0x120>
      int free0 = countfree();
    531a:	00000097          	auipc	ra,0x0
    531e:	c7a080e7          	jalr	-902(ra) # 4f94 <countfree>
    5322:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5324:	c1843583          	ld	a1,-1000(s0)
    5328:	d1fd                	beqz	a1,530e <main+0x1aa>
    532a:	c1040493          	addi	s1,s0,-1008
        if(!run(t->f, t->s)){
    532e:	6088                	ld	a0,0(s1)
    5330:	00000097          	auipc	ra,0x0
    5334:	d96080e7          	jalr	-618(ra) # 50c6 <run>
    5338:	d561                	beqz	a0,5300 <main+0x19c>
      for (struct test *t = tests; t->s != 0; t++) {
    533a:	04c1                	addi	s1,s1,16
    533c:	648c                	ld	a1,8(s1)
    533e:	f9e5                	bnez	a1,532e <main+0x1ca>
    5340:	b7f9                	j	530e <main+0x1aa>
    continuous = 1;
    5342:	4985                	li	s3,1
  } tests[] = {
    5344:	00003797          	auipc	a5,0x3
    5348:	be478793          	addi	a5,a5,-1052 # 7f28 <statistics+0x23f8>
    534c:	c1040713          	addi	a4,s0,-1008
    5350:	00003817          	auipc	a6,0x3
    5354:	f7880813          	addi	a6,a6,-136 # 82c8 <statistics+0x2798>
    5358:	6388                	ld	a0,0(a5)
    535a:	678c                	ld	a1,8(a5)
    535c:	6b90                	ld	a2,16(a5)
    535e:	6f94                	ld	a3,24(a5)
    5360:	e308                	sd	a0,0(a4)
    5362:	e70c                	sd	a1,8(a4)
    5364:	eb10                	sd	a2,16(a4)
    5366:	ef14                	sd	a3,24(a4)
    5368:	02078793          	addi	a5,a5,32
    536c:	02070713          	addi	a4,a4,32
    5370:	ff0794e3          	bne	a5,a6,5358 <main+0x1f4>
    5374:	6394                	ld	a3,0(a5)
    5376:	679c                	ld	a5,8(a5)
    5378:	e314                	sd	a3,0(a4)
    537a:	e71c                	sd	a5,8(a4)
    printf("continuous usertests starting\n");
    537c:	00003517          	auipc	a0,0x3
    5380:	b6450513          	addi	a0,a0,-1180 # 7ee0 <statistics+0x23b0>
    5384:	00000097          	auipc	ra,0x0
    5388:	60a080e7          	jalr	1546(ra) # 598e <printf>
        printf("SOME TESTS FAILED\n");
    538c:	00003a97          	auipc	s5,0x3
    5390:	adca8a93          	addi	s5,s5,-1316 # 7e68 <statistics+0x2338>
        if(continuous != 2)
    5394:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5396:	00003b17          	auipc	s6,0x3
    539a:	ab2b0b13          	addi	s6,s6,-1358 # 7e48 <statistics+0x2318>
    539e:	bfb5                	j	531a <main+0x1b6>

00000000000053a0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    53a0:	1141                	addi	sp,sp,-16
    53a2:	e422                	sd	s0,8(sp)
    53a4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    53a6:	87aa                	mv	a5,a0
    53a8:	0585                	addi	a1,a1,1
    53aa:	0785                	addi	a5,a5,1
    53ac:	fff5c703          	lbu	a4,-1(a1)
    53b0:	fee78fa3          	sb	a4,-1(a5)
    53b4:	fb75                	bnez	a4,53a8 <strcpy+0x8>
    ;
  return os;
}
    53b6:	6422                	ld	s0,8(sp)
    53b8:	0141                	addi	sp,sp,16
    53ba:	8082                	ret

00000000000053bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
    53bc:	1141                	addi	sp,sp,-16
    53be:	e422                	sd	s0,8(sp)
    53c0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    53c2:	00054783          	lbu	a5,0(a0)
    53c6:	cb91                	beqz	a5,53da <strcmp+0x1e>
    53c8:	0005c703          	lbu	a4,0(a1)
    53cc:	00f71763          	bne	a4,a5,53da <strcmp+0x1e>
    p++, q++;
    53d0:	0505                	addi	a0,a0,1
    53d2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    53d4:	00054783          	lbu	a5,0(a0)
    53d8:	fbe5                	bnez	a5,53c8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    53da:	0005c503          	lbu	a0,0(a1)
}
    53de:	40a7853b          	subw	a0,a5,a0
    53e2:	6422                	ld	s0,8(sp)
    53e4:	0141                	addi	sp,sp,16
    53e6:	8082                	ret

00000000000053e8 <strlen>:

uint
strlen(const char *s)
{
    53e8:	1141                	addi	sp,sp,-16
    53ea:	e422                	sd	s0,8(sp)
    53ec:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    53ee:	00054783          	lbu	a5,0(a0)
    53f2:	cf91                	beqz	a5,540e <strlen+0x26>
    53f4:	0505                	addi	a0,a0,1
    53f6:	87aa                	mv	a5,a0
    53f8:	4685                	li	a3,1
    53fa:	9e89                	subw	a3,a3,a0
    53fc:	00f6853b          	addw	a0,a3,a5
    5400:	0785                	addi	a5,a5,1
    5402:	fff7c703          	lbu	a4,-1(a5)
    5406:	fb7d                	bnez	a4,53fc <strlen+0x14>
    ;
  return n;
}
    5408:	6422                	ld	s0,8(sp)
    540a:	0141                	addi	sp,sp,16
    540c:	8082                	ret
  for(n = 0; s[n]; n++)
    540e:	4501                	li	a0,0
    5410:	bfe5                	j	5408 <strlen+0x20>

0000000000005412 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5412:	1141                	addi	sp,sp,-16
    5414:	e422                	sd	s0,8(sp)
    5416:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5418:	ce09                	beqz	a2,5432 <memset+0x20>
    541a:	87aa                	mv	a5,a0
    541c:	fff6071b          	addiw	a4,a2,-1
    5420:	1702                	slli	a4,a4,0x20
    5422:	9301                	srli	a4,a4,0x20
    5424:	0705                	addi	a4,a4,1
    5426:	972a                	add	a4,a4,a0
    cdst[i] = c;
    5428:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    542c:	0785                	addi	a5,a5,1
    542e:	fee79de3          	bne	a5,a4,5428 <memset+0x16>
  }
  return dst;
}
    5432:	6422                	ld	s0,8(sp)
    5434:	0141                	addi	sp,sp,16
    5436:	8082                	ret

0000000000005438 <strchr>:

char*
strchr(const char *s, char c)
{
    5438:	1141                	addi	sp,sp,-16
    543a:	e422                	sd	s0,8(sp)
    543c:	0800                	addi	s0,sp,16
  for(; *s; s++)
    543e:	00054783          	lbu	a5,0(a0)
    5442:	cb99                	beqz	a5,5458 <strchr+0x20>
    if(*s == c)
    5444:	00f58763          	beq	a1,a5,5452 <strchr+0x1a>
  for(; *s; s++)
    5448:	0505                	addi	a0,a0,1
    544a:	00054783          	lbu	a5,0(a0)
    544e:	fbfd                	bnez	a5,5444 <strchr+0xc>
      return (char*)s;
  return 0;
    5450:	4501                	li	a0,0
}
    5452:	6422                	ld	s0,8(sp)
    5454:	0141                	addi	sp,sp,16
    5456:	8082                	ret
  return 0;
    5458:	4501                	li	a0,0
    545a:	bfe5                	j	5452 <strchr+0x1a>

000000000000545c <gets>:

char*
gets(char *buf, int max)
{
    545c:	711d                	addi	sp,sp,-96
    545e:	ec86                	sd	ra,88(sp)
    5460:	e8a2                	sd	s0,80(sp)
    5462:	e4a6                	sd	s1,72(sp)
    5464:	e0ca                	sd	s2,64(sp)
    5466:	fc4e                	sd	s3,56(sp)
    5468:	f852                	sd	s4,48(sp)
    546a:	f456                	sd	s5,40(sp)
    546c:	f05a                	sd	s6,32(sp)
    546e:	ec5e                	sd	s7,24(sp)
    5470:	1080                	addi	s0,sp,96
    5472:	8baa                	mv	s7,a0
    5474:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5476:	892a                	mv	s2,a0
    5478:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    547a:	4aa9                	li	s5,10
    547c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    547e:	89a6                	mv	s3,s1
    5480:	2485                	addiw	s1,s1,1
    5482:	0344d863          	bge	s1,s4,54b2 <gets+0x56>
    cc = read(0, &c, 1);
    5486:	4605                	li	a2,1
    5488:	faf40593          	addi	a1,s0,-81
    548c:	4501                	li	a0,0
    548e:	00000097          	auipc	ra,0x0
    5492:	1a0080e7          	jalr	416(ra) # 562e <read>
    if(cc < 1)
    5496:	00a05e63          	blez	a0,54b2 <gets+0x56>
    buf[i++] = c;
    549a:	faf44783          	lbu	a5,-81(s0)
    549e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    54a2:	01578763          	beq	a5,s5,54b0 <gets+0x54>
    54a6:	0905                	addi	s2,s2,1
    54a8:	fd679be3          	bne	a5,s6,547e <gets+0x22>
  for(i=0; i+1 < max; ){
    54ac:	89a6                	mv	s3,s1
    54ae:	a011                	j	54b2 <gets+0x56>
    54b0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    54b2:	99de                	add	s3,s3,s7
    54b4:	00098023          	sb	zero,0(s3)
  return buf;
}
    54b8:	855e                	mv	a0,s7
    54ba:	60e6                	ld	ra,88(sp)
    54bc:	6446                	ld	s0,80(sp)
    54be:	64a6                	ld	s1,72(sp)
    54c0:	6906                	ld	s2,64(sp)
    54c2:	79e2                	ld	s3,56(sp)
    54c4:	7a42                	ld	s4,48(sp)
    54c6:	7aa2                	ld	s5,40(sp)
    54c8:	7b02                	ld	s6,32(sp)
    54ca:	6be2                	ld	s7,24(sp)
    54cc:	6125                	addi	sp,sp,96
    54ce:	8082                	ret

00000000000054d0 <stat>:

int
stat(const char *n, struct stat *st)
{
    54d0:	1101                	addi	sp,sp,-32
    54d2:	ec06                	sd	ra,24(sp)
    54d4:	e822                	sd	s0,16(sp)
    54d6:	e426                	sd	s1,8(sp)
    54d8:	e04a                	sd	s2,0(sp)
    54da:	1000                	addi	s0,sp,32
    54dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    54de:	4581                	li	a1,0
    54e0:	00000097          	auipc	ra,0x0
    54e4:	176080e7          	jalr	374(ra) # 5656 <open>
  if(fd < 0)
    54e8:	02054563          	bltz	a0,5512 <stat+0x42>
    54ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    54ee:	85ca                	mv	a1,s2
    54f0:	00000097          	auipc	ra,0x0
    54f4:	17e080e7          	jalr	382(ra) # 566e <fstat>
    54f8:	892a                	mv	s2,a0
  close(fd);
    54fa:	8526                	mv	a0,s1
    54fc:	00000097          	auipc	ra,0x0
    5500:	142080e7          	jalr	322(ra) # 563e <close>
  return r;
}
    5504:	854a                	mv	a0,s2
    5506:	60e2                	ld	ra,24(sp)
    5508:	6442                	ld	s0,16(sp)
    550a:	64a2                	ld	s1,8(sp)
    550c:	6902                	ld	s2,0(sp)
    550e:	6105                	addi	sp,sp,32
    5510:	8082                	ret
    return -1;
    5512:	597d                	li	s2,-1
    5514:	bfc5                	j	5504 <stat+0x34>

0000000000005516 <atoi>:

int
atoi(const char *s)
{
    5516:	1141                	addi	sp,sp,-16
    5518:	e422                	sd	s0,8(sp)
    551a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    551c:	00054603          	lbu	a2,0(a0)
    5520:	fd06079b          	addiw	a5,a2,-48
    5524:	0ff7f793          	andi	a5,a5,255
    5528:	4725                	li	a4,9
    552a:	02f76963          	bltu	a4,a5,555c <atoi+0x46>
    552e:	86aa                	mv	a3,a0
  n = 0;
    5530:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5532:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5534:	0685                	addi	a3,a3,1
    5536:	0025179b          	slliw	a5,a0,0x2
    553a:	9fa9                	addw	a5,a5,a0
    553c:	0017979b          	slliw	a5,a5,0x1
    5540:	9fb1                	addw	a5,a5,a2
    5542:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5546:	0006c603          	lbu	a2,0(a3) # 1000 <bigdir+0x9e>
    554a:	fd06071b          	addiw	a4,a2,-48
    554e:	0ff77713          	andi	a4,a4,255
    5552:	fee5f1e3          	bgeu	a1,a4,5534 <atoi+0x1e>
  return n;
}
    5556:	6422                	ld	s0,8(sp)
    5558:	0141                	addi	sp,sp,16
    555a:	8082                	ret
  n = 0;
    555c:	4501                	li	a0,0
    555e:	bfe5                	j	5556 <atoi+0x40>

0000000000005560 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5560:	1141                	addi	sp,sp,-16
    5562:	e422                	sd	s0,8(sp)
    5564:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5566:	02b57663          	bgeu	a0,a1,5592 <memmove+0x32>
    while(n-- > 0)
    556a:	02c05163          	blez	a2,558c <memmove+0x2c>
    556e:	fff6079b          	addiw	a5,a2,-1
    5572:	1782                	slli	a5,a5,0x20
    5574:	9381                	srli	a5,a5,0x20
    5576:	0785                	addi	a5,a5,1
    5578:	97aa                	add	a5,a5,a0
  dst = vdst;
    557a:	872a                	mv	a4,a0
      *dst++ = *src++;
    557c:	0585                	addi	a1,a1,1
    557e:	0705                	addi	a4,a4,1
    5580:	fff5c683          	lbu	a3,-1(a1)
    5584:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5588:	fee79ae3          	bne	a5,a4,557c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    558c:	6422                	ld	s0,8(sp)
    558e:	0141                	addi	sp,sp,16
    5590:	8082                	ret
    dst += n;
    5592:	00c50733          	add	a4,a0,a2
    src += n;
    5596:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5598:	fec05ae3          	blez	a2,558c <memmove+0x2c>
    559c:	fff6079b          	addiw	a5,a2,-1
    55a0:	1782                	slli	a5,a5,0x20
    55a2:	9381                	srli	a5,a5,0x20
    55a4:	fff7c793          	not	a5,a5
    55a8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    55aa:	15fd                	addi	a1,a1,-1
    55ac:	177d                	addi	a4,a4,-1
    55ae:	0005c683          	lbu	a3,0(a1)
    55b2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    55b6:	fee79ae3          	bne	a5,a4,55aa <memmove+0x4a>
    55ba:	bfc9                	j	558c <memmove+0x2c>

00000000000055bc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    55bc:	1141                	addi	sp,sp,-16
    55be:	e422                	sd	s0,8(sp)
    55c0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    55c2:	ca05                	beqz	a2,55f2 <memcmp+0x36>
    55c4:	fff6069b          	addiw	a3,a2,-1
    55c8:	1682                	slli	a3,a3,0x20
    55ca:	9281                	srli	a3,a3,0x20
    55cc:	0685                	addi	a3,a3,1
    55ce:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    55d0:	00054783          	lbu	a5,0(a0)
    55d4:	0005c703          	lbu	a4,0(a1)
    55d8:	00e79863          	bne	a5,a4,55e8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    55dc:	0505                	addi	a0,a0,1
    p2++;
    55de:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    55e0:	fed518e3          	bne	a0,a3,55d0 <memcmp+0x14>
  }
  return 0;
    55e4:	4501                	li	a0,0
    55e6:	a019                	j	55ec <memcmp+0x30>
      return *p1 - *p2;
    55e8:	40e7853b          	subw	a0,a5,a4
}
    55ec:	6422                	ld	s0,8(sp)
    55ee:	0141                	addi	sp,sp,16
    55f0:	8082                	ret
  return 0;
    55f2:	4501                	li	a0,0
    55f4:	bfe5                	j	55ec <memcmp+0x30>

00000000000055f6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    55f6:	1141                	addi	sp,sp,-16
    55f8:	e406                	sd	ra,8(sp)
    55fa:	e022                	sd	s0,0(sp)
    55fc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    55fe:	00000097          	auipc	ra,0x0
    5602:	f62080e7          	jalr	-158(ra) # 5560 <memmove>
}
    5606:	60a2                	ld	ra,8(sp)
    5608:	6402                	ld	s0,0(sp)
    560a:	0141                	addi	sp,sp,16
    560c:	8082                	ret

000000000000560e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    560e:	4885                	li	a7,1
 ecall
    5610:	00000073          	ecall
 ret
    5614:	8082                	ret

0000000000005616 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5616:	4889                	li	a7,2
 ecall
    5618:	00000073          	ecall
 ret
    561c:	8082                	ret

000000000000561e <wait>:
.global wait
wait:
 li a7, SYS_wait
    561e:	488d                	li	a7,3
 ecall
    5620:	00000073          	ecall
 ret
    5624:	8082                	ret

0000000000005626 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5626:	4891                	li	a7,4
 ecall
    5628:	00000073          	ecall
 ret
    562c:	8082                	ret

000000000000562e <read>:
.global read
read:
 li a7, SYS_read
    562e:	4895                	li	a7,5
 ecall
    5630:	00000073          	ecall
 ret
    5634:	8082                	ret

0000000000005636 <write>:
.global write
write:
 li a7, SYS_write
    5636:	48c1                	li	a7,16
 ecall
    5638:	00000073          	ecall
 ret
    563c:	8082                	ret

000000000000563e <close>:
.global close
close:
 li a7, SYS_close
    563e:	48d5                	li	a7,21
 ecall
    5640:	00000073          	ecall
 ret
    5644:	8082                	ret

0000000000005646 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5646:	4899                	li	a7,6
 ecall
    5648:	00000073          	ecall
 ret
    564c:	8082                	ret

000000000000564e <exec>:
.global exec
exec:
 li a7, SYS_exec
    564e:	489d                	li	a7,7
 ecall
    5650:	00000073          	ecall
 ret
    5654:	8082                	ret

0000000000005656 <open>:
.global open
open:
 li a7, SYS_open
    5656:	48bd                	li	a7,15
 ecall
    5658:	00000073          	ecall
 ret
    565c:	8082                	ret

000000000000565e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    565e:	48c5                	li	a7,17
 ecall
    5660:	00000073          	ecall
 ret
    5664:	8082                	ret

0000000000005666 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5666:	48c9                	li	a7,18
 ecall
    5668:	00000073          	ecall
 ret
    566c:	8082                	ret

000000000000566e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    566e:	48a1                	li	a7,8
 ecall
    5670:	00000073          	ecall
 ret
    5674:	8082                	ret

0000000000005676 <link>:
.global link
link:
 li a7, SYS_link
    5676:	48cd                	li	a7,19
 ecall
    5678:	00000073          	ecall
 ret
    567c:	8082                	ret

000000000000567e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    567e:	48d1                	li	a7,20
 ecall
    5680:	00000073          	ecall
 ret
    5684:	8082                	ret

0000000000005686 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5686:	48a5                	li	a7,9
 ecall
    5688:	00000073          	ecall
 ret
    568c:	8082                	ret

000000000000568e <dup>:
.global dup
dup:
 li a7, SYS_dup
    568e:	48a9                	li	a7,10
 ecall
    5690:	00000073          	ecall
 ret
    5694:	8082                	ret

0000000000005696 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5696:	48ad                	li	a7,11
 ecall
    5698:	00000073          	ecall
 ret
    569c:	8082                	ret

000000000000569e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    569e:	48b1                	li	a7,12
 ecall
    56a0:	00000073          	ecall
 ret
    56a4:	8082                	ret

00000000000056a6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    56a6:	48b5                	li	a7,13
 ecall
    56a8:	00000073          	ecall
 ret
    56ac:	8082                	ret

00000000000056ae <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    56ae:	48b9                	li	a7,14
 ecall
    56b0:	00000073          	ecall
 ret
    56b4:	8082                	ret

00000000000056b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    56b6:	1101                	addi	sp,sp,-32
    56b8:	ec06                	sd	ra,24(sp)
    56ba:	e822                	sd	s0,16(sp)
    56bc:	1000                	addi	s0,sp,32
    56be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    56c2:	4605                	li	a2,1
    56c4:	fef40593          	addi	a1,s0,-17
    56c8:	00000097          	auipc	ra,0x0
    56cc:	f6e080e7          	jalr	-146(ra) # 5636 <write>
}
    56d0:	60e2                	ld	ra,24(sp)
    56d2:	6442                	ld	s0,16(sp)
    56d4:	6105                	addi	sp,sp,32
    56d6:	8082                	ret

00000000000056d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    56d8:	7139                	addi	sp,sp,-64
    56da:	fc06                	sd	ra,56(sp)
    56dc:	f822                	sd	s0,48(sp)
    56de:	f426                	sd	s1,40(sp)
    56e0:	f04a                	sd	s2,32(sp)
    56e2:	ec4e                	sd	s3,24(sp)
    56e4:	0080                	addi	s0,sp,64
    56e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    56e8:	c299                	beqz	a3,56ee <printint+0x16>
    56ea:	0805c863          	bltz	a1,577a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    56ee:	2581                	sext.w	a1,a1
  neg = 0;
    56f0:	4881                	li	a7,0
    56f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    56f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    56f8:	2601                	sext.w	a2,a2
    56fa:	00003517          	auipc	a0,0x3
    56fe:	be650513          	addi	a0,a0,-1050 # 82e0 <digits>
    5702:	883a                	mv	a6,a4
    5704:	2705                	addiw	a4,a4,1
    5706:	02c5f7bb          	remuw	a5,a1,a2
    570a:	1782                	slli	a5,a5,0x20
    570c:	9381                	srli	a5,a5,0x20
    570e:	97aa                	add	a5,a5,a0
    5710:	0007c783          	lbu	a5,0(a5)
    5714:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5718:	0005879b          	sext.w	a5,a1
    571c:	02c5d5bb          	divuw	a1,a1,a2
    5720:	0685                	addi	a3,a3,1
    5722:	fec7f0e3          	bgeu	a5,a2,5702 <printint+0x2a>
  if(neg)
    5726:	00088b63          	beqz	a7,573c <printint+0x64>
    buf[i++] = '-';
    572a:	fd040793          	addi	a5,s0,-48
    572e:	973e                	add	a4,a4,a5
    5730:	02d00793          	li	a5,45
    5734:	fef70823          	sb	a5,-16(a4)
    5738:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    573c:	02e05863          	blez	a4,576c <printint+0x94>
    5740:	fc040793          	addi	a5,s0,-64
    5744:	00e78933          	add	s2,a5,a4
    5748:	fff78993          	addi	s3,a5,-1
    574c:	99ba                	add	s3,s3,a4
    574e:	377d                	addiw	a4,a4,-1
    5750:	1702                	slli	a4,a4,0x20
    5752:	9301                	srli	a4,a4,0x20
    5754:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5758:	fff94583          	lbu	a1,-1(s2)
    575c:	8526                	mv	a0,s1
    575e:	00000097          	auipc	ra,0x0
    5762:	f58080e7          	jalr	-168(ra) # 56b6 <putc>
  while(--i >= 0)
    5766:	197d                	addi	s2,s2,-1
    5768:	ff3918e3          	bne	s2,s3,5758 <printint+0x80>
}
    576c:	70e2                	ld	ra,56(sp)
    576e:	7442                	ld	s0,48(sp)
    5770:	74a2                	ld	s1,40(sp)
    5772:	7902                	ld	s2,32(sp)
    5774:	69e2                	ld	s3,24(sp)
    5776:	6121                	addi	sp,sp,64
    5778:	8082                	ret
    x = -xx;
    577a:	40b005bb          	negw	a1,a1
    neg = 1;
    577e:	4885                	li	a7,1
    x = -xx;
    5780:	bf8d                	j	56f2 <printint+0x1a>

0000000000005782 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5782:	7119                	addi	sp,sp,-128
    5784:	fc86                	sd	ra,120(sp)
    5786:	f8a2                	sd	s0,112(sp)
    5788:	f4a6                	sd	s1,104(sp)
    578a:	f0ca                	sd	s2,96(sp)
    578c:	ecce                	sd	s3,88(sp)
    578e:	e8d2                	sd	s4,80(sp)
    5790:	e4d6                	sd	s5,72(sp)
    5792:	e0da                	sd	s6,64(sp)
    5794:	fc5e                	sd	s7,56(sp)
    5796:	f862                	sd	s8,48(sp)
    5798:	f466                	sd	s9,40(sp)
    579a:	f06a                	sd	s10,32(sp)
    579c:	ec6e                	sd	s11,24(sp)
    579e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    57a0:	0005c903          	lbu	s2,0(a1)
    57a4:	18090f63          	beqz	s2,5942 <vprintf+0x1c0>
    57a8:	8aaa                	mv	s5,a0
    57aa:	8b32                	mv	s6,a2
    57ac:	00158493          	addi	s1,a1,1
  state = 0;
    57b0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    57b2:	02500a13          	li	s4,37
      if(c == 'd'){
    57b6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    57ba:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    57be:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    57c2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    57c6:	00003b97          	auipc	s7,0x3
    57ca:	b1ab8b93          	addi	s7,s7,-1254 # 82e0 <digits>
    57ce:	a839                	j	57ec <vprintf+0x6a>
        putc(fd, c);
    57d0:	85ca                	mv	a1,s2
    57d2:	8556                	mv	a0,s5
    57d4:	00000097          	auipc	ra,0x0
    57d8:	ee2080e7          	jalr	-286(ra) # 56b6 <putc>
    57dc:	a019                	j	57e2 <vprintf+0x60>
    } else if(state == '%'){
    57de:	01498f63          	beq	s3,s4,57fc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    57e2:	0485                	addi	s1,s1,1
    57e4:	fff4c903          	lbu	s2,-1(s1)
    57e8:	14090d63          	beqz	s2,5942 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    57ec:	0009079b          	sext.w	a5,s2
    if(state == 0){
    57f0:	fe0997e3          	bnez	s3,57de <vprintf+0x5c>
      if(c == '%'){
    57f4:	fd479ee3          	bne	a5,s4,57d0 <vprintf+0x4e>
        state = '%';
    57f8:	89be                	mv	s3,a5
    57fa:	b7e5                	j	57e2 <vprintf+0x60>
      if(c == 'd'){
    57fc:	05878063          	beq	a5,s8,583c <vprintf+0xba>
      } else if(c == 'l') {
    5800:	05978c63          	beq	a5,s9,5858 <vprintf+0xd6>
      } else if(c == 'x') {
    5804:	07a78863          	beq	a5,s10,5874 <vprintf+0xf2>
      } else if(c == 'p') {
    5808:	09b78463          	beq	a5,s11,5890 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    580c:	07300713          	li	a4,115
    5810:	0ce78663          	beq	a5,a4,58dc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5814:	06300713          	li	a4,99
    5818:	0ee78e63          	beq	a5,a4,5914 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    581c:	11478863          	beq	a5,s4,592c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5820:	85d2                	mv	a1,s4
    5822:	8556                	mv	a0,s5
    5824:	00000097          	auipc	ra,0x0
    5828:	e92080e7          	jalr	-366(ra) # 56b6 <putc>
        putc(fd, c);
    582c:	85ca                	mv	a1,s2
    582e:	8556                	mv	a0,s5
    5830:	00000097          	auipc	ra,0x0
    5834:	e86080e7          	jalr	-378(ra) # 56b6 <putc>
      }
      state = 0;
    5838:	4981                	li	s3,0
    583a:	b765                	j	57e2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    583c:	008b0913          	addi	s2,s6,8
    5840:	4685                	li	a3,1
    5842:	4629                	li	a2,10
    5844:	000b2583          	lw	a1,0(s6)
    5848:	8556                	mv	a0,s5
    584a:	00000097          	auipc	ra,0x0
    584e:	e8e080e7          	jalr	-370(ra) # 56d8 <printint>
    5852:	8b4a                	mv	s6,s2
      state = 0;
    5854:	4981                	li	s3,0
    5856:	b771                	j	57e2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5858:	008b0913          	addi	s2,s6,8
    585c:	4681                	li	a3,0
    585e:	4629                	li	a2,10
    5860:	000b2583          	lw	a1,0(s6)
    5864:	8556                	mv	a0,s5
    5866:	00000097          	auipc	ra,0x0
    586a:	e72080e7          	jalr	-398(ra) # 56d8 <printint>
    586e:	8b4a                	mv	s6,s2
      state = 0;
    5870:	4981                	li	s3,0
    5872:	bf85                	j	57e2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5874:	008b0913          	addi	s2,s6,8
    5878:	4681                	li	a3,0
    587a:	4641                	li	a2,16
    587c:	000b2583          	lw	a1,0(s6)
    5880:	8556                	mv	a0,s5
    5882:	00000097          	auipc	ra,0x0
    5886:	e56080e7          	jalr	-426(ra) # 56d8 <printint>
    588a:	8b4a                	mv	s6,s2
      state = 0;
    588c:	4981                	li	s3,0
    588e:	bf91                	j	57e2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5890:	008b0793          	addi	a5,s6,8
    5894:	f8f43423          	sd	a5,-120(s0)
    5898:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    589c:	03000593          	li	a1,48
    58a0:	8556                	mv	a0,s5
    58a2:	00000097          	auipc	ra,0x0
    58a6:	e14080e7          	jalr	-492(ra) # 56b6 <putc>
  putc(fd, 'x');
    58aa:	85ea                	mv	a1,s10
    58ac:	8556                	mv	a0,s5
    58ae:	00000097          	auipc	ra,0x0
    58b2:	e08080e7          	jalr	-504(ra) # 56b6 <putc>
    58b6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    58b8:	03c9d793          	srli	a5,s3,0x3c
    58bc:	97de                	add	a5,a5,s7
    58be:	0007c583          	lbu	a1,0(a5)
    58c2:	8556                	mv	a0,s5
    58c4:	00000097          	auipc	ra,0x0
    58c8:	df2080e7          	jalr	-526(ra) # 56b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    58cc:	0992                	slli	s3,s3,0x4
    58ce:	397d                	addiw	s2,s2,-1
    58d0:	fe0914e3          	bnez	s2,58b8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    58d4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    58d8:	4981                	li	s3,0
    58da:	b721                	j	57e2 <vprintf+0x60>
        s = va_arg(ap, char*);
    58dc:	008b0993          	addi	s3,s6,8
    58e0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    58e4:	02090163          	beqz	s2,5906 <vprintf+0x184>
        while(*s != 0){
    58e8:	00094583          	lbu	a1,0(s2)
    58ec:	c9a1                	beqz	a1,593c <vprintf+0x1ba>
          putc(fd, *s);
    58ee:	8556                	mv	a0,s5
    58f0:	00000097          	auipc	ra,0x0
    58f4:	dc6080e7          	jalr	-570(ra) # 56b6 <putc>
          s++;
    58f8:	0905                	addi	s2,s2,1
        while(*s != 0){
    58fa:	00094583          	lbu	a1,0(s2)
    58fe:	f9e5                	bnez	a1,58ee <vprintf+0x16c>
        s = va_arg(ap, char*);
    5900:	8b4e                	mv	s6,s3
      state = 0;
    5902:	4981                	li	s3,0
    5904:	bdf9                	j	57e2 <vprintf+0x60>
          s = "(null)";
    5906:	00003917          	auipc	s2,0x3
    590a:	9d290913          	addi	s2,s2,-1582 # 82d8 <statistics+0x27a8>
        while(*s != 0){
    590e:	02800593          	li	a1,40
    5912:	bff1                	j	58ee <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5914:	008b0913          	addi	s2,s6,8
    5918:	000b4583          	lbu	a1,0(s6)
    591c:	8556                	mv	a0,s5
    591e:	00000097          	auipc	ra,0x0
    5922:	d98080e7          	jalr	-616(ra) # 56b6 <putc>
    5926:	8b4a                	mv	s6,s2
      state = 0;
    5928:	4981                	li	s3,0
    592a:	bd65                	j	57e2 <vprintf+0x60>
        putc(fd, c);
    592c:	85d2                	mv	a1,s4
    592e:	8556                	mv	a0,s5
    5930:	00000097          	auipc	ra,0x0
    5934:	d86080e7          	jalr	-634(ra) # 56b6 <putc>
      state = 0;
    5938:	4981                	li	s3,0
    593a:	b565                	j	57e2 <vprintf+0x60>
        s = va_arg(ap, char*);
    593c:	8b4e                	mv	s6,s3
      state = 0;
    593e:	4981                	li	s3,0
    5940:	b54d                	j	57e2 <vprintf+0x60>
    }
  }
}
    5942:	70e6                	ld	ra,120(sp)
    5944:	7446                	ld	s0,112(sp)
    5946:	74a6                	ld	s1,104(sp)
    5948:	7906                	ld	s2,96(sp)
    594a:	69e6                	ld	s3,88(sp)
    594c:	6a46                	ld	s4,80(sp)
    594e:	6aa6                	ld	s5,72(sp)
    5950:	6b06                	ld	s6,64(sp)
    5952:	7be2                	ld	s7,56(sp)
    5954:	7c42                	ld	s8,48(sp)
    5956:	7ca2                	ld	s9,40(sp)
    5958:	7d02                	ld	s10,32(sp)
    595a:	6de2                	ld	s11,24(sp)
    595c:	6109                	addi	sp,sp,128
    595e:	8082                	ret

0000000000005960 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5960:	715d                	addi	sp,sp,-80
    5962:	ec06                	sd	ra,24(sp)
    5964:	e822                	sd	s0,16(sp)
    5966:	1000                	addi	s0,sp,32
    5968:	e010                	sd	a2,0(s0)
    596a:	e414                	sd	a3,8(s0)
    596c:	e818                	sd	a4,16(s0)
    596e:	ec1c                	sd	a5,24(s0)
    5970:	03043023          	sd	a6,32(s0)
    5974:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5978:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    597c:	8622                	mv	a2,s0
    597e:	00000097          	auipc	ra,0x0
    5982:	e04080e7          	jalr	-508(ra) # 5782 <vprintf>
}
    5986:	60e2                	ld	ra,24(sp)
    5988:	6442                	ld	s0,16(sp)
    598a:	6161                	addi	sp,sp,80
    598c:	8082                	ret

000000000000598e <printf>:

void
printf(const char *fmt, ...)
{
    598e:	711d                	addi	sp,sp,-96
    5990:	ec06                	sd	ra,24(sp)
    5992:	e822                	sd	s0,16(sp)
    5994:	1000                	addi	s0,sp,32
    5996:	e40c                	sd	a1,8(s0)
    5998:	e810                	sd	a2,16(s0)
    599a:	ec14                	sd	a3,24(s0)
    599c:	f018                	sd	a4,32(s0)
    599e:	f41c                	sd	a5,40(s0)
    59a0:	03043823          	sd	a6,48(s0)
    59a4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    59a8:	00840613          	addi	a2,s0,8
    59ac:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    59b0:	85aa                	mv	a1,a0
    59b2:	4505                	li	a0,1
    59b4:	00000097          	auipc	ra,0x0
    59b8:	dce080e7          	jalr	-562(ra) # 5782 <vprintf>
}
    59bc:	60e2                	ld	ra,24(sp)
    59be:	6442                	ld	s0,16(sp)
    59c0:	6125                	addi	sp,sp,96
    59c2:	8082                	ret

00000000000059c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    59c4:	1141                	addi	sp,sp,-16
    59c6:	e422                	sd	s0,8(sp)
    59c8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    59ca:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    59ce:	00003797          	auipc	a5,0x3
    59d2:	9627b783          	ld	a5,-1694(a5) # 8330 <freep>
    59d6:	a805                	j	5a06 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    59d8:	4618                	lw	a4,8(a2)
    59da:	9db9                	addw	a1,a1,a4
    59dc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    59e0:	6398                	ld	a4,0(a5)
    59e2:	6318                	ld	a4,0(a4)
    59e4:	fee53823          	sd	a4,-16(a0)
    59e8:	a091                	j	5a2c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    59ea:	ff852703          	lw	a4,-8(a0)
    59ee:	9e39                	addw	a2,a2,a4
    59f0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    59f2:	ff053703          	ld	a4,-16(a0)
    59f6:	e398                	sd	a4,0(a5)
    59f8:	a099                	j	5a3e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    59fa:	6398                	ld	a4,0(a5)
    59fc:	00e7e463          	bltu	a5,a4,5a04 <free+0x40>
    5a00:	00e6ea63          	bltu	a3,a4,5a14 <free+0x50>
{
    5a04:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a06:	fed7fae3          	bgeu	a5,a3,59fa <free+0x36>
    5a0a:	6398                	ld	a4,0(a5)
    5a0c:	00e6e463          	bltu	a3,a4,5a14 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a10:	fee7eae3          	bltu	a5,a4,5a04 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5a14:	ff852583          	lw	a1,-8(a0)
    5a18:	6390                	ld	a2,0(a5)
    5a1a:	02059713          	slli	a4,a1,0x20
    5a1e:	9301                	srli	a4,a4,0x20
    5a20:	0712                	slli	a4,a4,0x4
    5a22:	9736                	add	a4,a4,a3
    5a24:	fae60ae3          	beq	a2,a4,59d8 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5a28:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5a2c:	4790                	lw	a2,8(a5)
    5a2e:	02061713          	slli	a4,a2,0x20
    5a32:	9301                	srli	a4,a4,0x20
    5a34:	0712                	slli	a4,a4,0x4
    5a36:	973e                	add	a4,a4,a5
    5a38:	fae689e3          	beq	a3,a4,59ea <free+0x26>
  } else
    p->s.ptr = bp;
    5a3c:	e394                	sd	a3,0(a5)
  freep = p;
    5a3e:	00003717          	auipc	a4,0x3
    5a42:	8ef73923          	sd	a5,-1806(a4) # 8330 <freep>
}
    5a46:	6422                	ld	s0,8(sp)
    5a48:	0141                	addi	sp,sp,16
    5a4a:	8082                	ret

0000000000005a4c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5a4c:	7139                	addi	sp,sp,-64
    5a4e:	fc06                	sd	ra,56(sp)
    5a50:	f822                	sd	s0,48(sp)
    5a52:	f426                	sd	s1,40(sp)
    5a54:	f04a                	sd	s2,32(sp)
    5a56:	ec4e                	sd	s3,24(sp)
    5a58:	e852                	sd	s4,16(sp)
    5a5a:	e456                	sd	s5,8(sp)
    5a5c:	e05a                	sd	s6,0(sp)
    5a5e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5a60:	02051493          	slli	s1,a0,0x20
    5a64:	9081                	srli	s1,s1,0x20
    5a66:	04bd                	addi	s1,s1,15
    5a68:	8091                	srli	s1,s1,0x4
    5a6a:	0014899b          	addiw	s3,s1,1
    5a6e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5a70:	00003517          	auipc	a0,0x3
    5a74:	8c053503          	ld	a0,-1856(a0) # 8330 <freep>
    5a78:	c515                	beqz	a0,5aa4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5a7a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5a7c:	4798                	lw	a4,8(a5)
    5a7e:	02977f63          	bgeu	a4,s1,5abc <malloc+0x70>
    5a82:	8a4e                	mv	s4,s3
    5a84:	0009871b          	sext.w	a4,s3
    5a88:	6685                	lui	a3,0x1
    5a8a:	00d77363          	bgeu	a4,a3,5a90 <malloc+0x44>
    5a8e:	6a05                	lui	s4,0x1
    5a90:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5a94:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5a98:	00003917          	auipc	s2,0x3
    5a9c:	89890913          	addi	s2,s2,-1896 # 8330 <freep>
  if(p == (char*)-1)
    5aa0:	5afd                	li	s5,-1
    5aa2:	a88d                	j	5b14 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5aa4:	00009797          	auipc	a5,0x9
    5aa8:	0ac78793          	addi	a5,a5,172 # eb50 <base>
    5aac:	00003717          	auipc	a4,0x3
    5ab0:	88f73223          	sd	a5,-1916(a4) # 8330 <freep>
    5ab4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5ab6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5aba:	b7e1                	j	5a82 <malloc+0x36>
      if(p->s.size == nunits)
    5abc:	02e48b63          	beq	s1,a4,5af2 <malloc+0xa6>
        p->s.size -= nunits;
    5ac0:	4137073b          	subw	a4,a4,s3
    5ac4:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5ac6:	1702                	slli	a4,a4,0x20
    5ac8:	9301                	srli	a4,a4,0x20
    5aca:	0712                	slli	a4,a4,0x4
    5acc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5ace:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5ad2:	00003717          	auipc	a4,0x3
    5ad6:	84a73f23          	sd	a0,-1954(a4) # 8330 <freep>
      return (void*)(p + 1);
    5ada:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5ade:	70e2                	ld	ra,56(sp)
    5ae0:	7442                	ld	s0,48(sp)
    5ae2:	74a2                	ld	s1,40(sp)
    5ae4:	7902                	ld	s2,32(sp)
    5ae6:	69e2                	ld	s3,24(sp)
    5ae8:	6a42                	ld	s4,16(sp)
    5aea:	6aa2                	ld	s5,8(sp)
    5aec:	6b02                	ld	s6,0(sp)
    5aee:	6121                	addi	sp,sp,64
    5af0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5af2:	6398                	ld	a4,0(a5)
    5af4:	e118                	sd	a4,0(a0)
    5af6:	bff1                	j	5ad2 <malloc+0x86>
  hp->s.size = nu;
    5af8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5afc:	0541                	addi	a0,a0,16
    5afe:	00000097          	auipc	ra,0x0
    5b02:	ec6080e7          	jalr	-314(ra) # 59c4 <free>
  return freep;
    5b06:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5b0a:	d971                	beqz	a0,5ade <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5b0c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5b0e:	4798                	lw	a4,8(a5)
    5b10:	fa9776e3          	bgeu	a4,s1,5abc <malloc+0x70>
    if(p == freep)
    5b14:	00093703          	ld	a4,0(s2)
    5b18:	853e                	mv	a0,a5
    5b1a:	fef719e3          	bne	a4,a5,5b0c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    5b1e:	8552                	mv	a0,s4
    5b20:	00000097          	auipc	ra,0x0
    5b24:	b7e080e7          	jalr	-1154(ra) # 569e <sbrk>
  if(p == (char*)-1)
    5b28:	fd5518e3          	bne	a0,s5,5af8 <malloc+0xac>
        return 0;
    5b2c:	4501                	li	a0,0
    5b2e:	bf45                	j	5ade <malloc+0x92>

0000000000005b30 <statistics>:
#include "kernel/fcntl.h"
#include "user/user.h"

int
statistics(void *buf, int sz)
{
    5b30:	7179                	addi	sp,sp,-48
    5b32:	f406                	sd	ra,40(sp)
    5b34:	f022                	sd	s0,32(sp)
    5b36:	ec26                	sd	s1,24(sp)
    5b38:	e84a                	sd	s2,16(sp)
    5b3a:	e44e                	sd	s3,8(sp)
    5b3c:	e052                	sd	s4,0(sp)
    5b3e:	1800                	addi	s0,sp,48
    5b40:	8a2a                	mv	s4,a0
    5b42:	892e                	mv	s2,a1
  int fd, i, n;
  
  fd = open("statistics", O_RDONLY);
    5b44:	4581                	li	a1,0
    5b46:	00002517          	auipc	a0,0x2
    5b4a:	7b250513          	addi	a0,a0,1970 # 82f8 <digits+0x18>
    5b4e:	00000097          	auipc	ra,0x0
    5b52:	b08080e7          	jalr	-1272(ra) # 5656 <open>
  if(fd < 0) {
    5b56:	04054263          	bltz	a0,5b9a <statistics+0x6a>
    5b5a:	89aa                	mv	s3,a0
      fprintf(2, "stats: open failed\n");
      exit(1);
  }
  for (i = 0; i < sz; ) {
    5b5c:	4481                	li	s1,0
    5b5e:	03205063          	blez	s2,5b7e <statistics+0x4e>
    if ((n = read(fd, buf+i, sz-i)) < 0) {
    5b62:	4099063b          	subw	a2,s2,s1
    5b66:	009a05b3          	add	a1,s4,s1
    5b6a:	854e                	mv	a0,s3
    5b6c:	00000097          	auipc	ra,0x0
    5b70:	ac2080e7          	jalr	-1342(ra) # 562e <read>
    5b74:	00054563          	bltz	a0,5b7e <statistics+0x4e>
      break;
    }
    i += n;
    5b78:	9ca9                	addw	s1,s1,a0
  for (i = 0; i < sz; ) {
    5b7a:	ff24c4e3          	blt	s1,s2,5b62 <statistics+0x32>
  }
  close(fd);
    5b7e:	854e                	mv	a0,s3
    5b80:	00000097          	auipc	ra,0x0
    5b84:	abe080e7          	jalr	-1346(ra) # 563e <close>
  return i;
}
    5b88:	8526                	mv	a0,s1
    5b8a:	70a2                	ld	ra,40(sp)
    5b8c:	7402                	ld	s0,32(sp)
    5b8e:	64e2                	ld	s1,24(sp)
    5b90:	6942                	ld	s2,16(sp)
    5b92:	69a2                	ld	s3,8(sp)
    5b94:	6a02                	ld	s4,0(sp)
    5b96:	6145                	addi	sp,sp,48
    5b98:	8082                	ret
      fprintf(2, "stats: open failed\n");
    5b9a:	00002597          	auipc	a1,0x2
    5b9e:	76e58593          	addi	a1,a1,1902 # 8308 <digits+0x28>
    5ba2:	4509                	li	a0,2
    5ba4:	00000097          	auipc	ra,0x0
    5ba8:	dbc080e7          	jalr	-580(ra) # 5960 <fprintf>
      exit(1);
    5bac:	4505                	li	a0,1
    5bae:	00000097          	auipc	ra,0x0
    5bb2:	a68080e7          	jalr	-1432(ra) # 5616 <exit>
