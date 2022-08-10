
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
      14:	648080e7          	jalr	1608(ra) # 5658 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	636080e7          	jalr	1590(ra) # 5658 <open>
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
      42:	e2250513          	addi	a0,a0,-478 # 5e60 <malloc+0x40a>
      46:	00006097          	auipc	ra,0x6
      4a:	952080e7          	jalr	-1710(ra) # 5998 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	5c8080e7          	jalr	1480(ra) # 5618 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	34878793          	addi	a5,a5,840 # 93a0 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	a5068693          	addi	a3,a3,-1456 # bab0 <buf>
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
      84:	e0050513          	addi	a0,a0,-512 # 5e80 <malloc+0x42a>
      88:	00006097          	auipc	ra,0x6
      8c:	910080e7          	jalr	-1776(ra) # 5998 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	586080e7          	jalr	1414(ra) # 5618 <exit>

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
      ac:	df050513          	addi	a0,a0,-528 # 5e98 <malloc+0x442>
      b0:	00005097          	auipc	ra,0x5
      b4:	5a8080e7          	jalr	1448(ra) # 5658 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	584080e7          	jalr	1412(ra) # 5640 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	df250513          	addi	a0,a0,-526 # 5eb8 <malloc+0x462>
      ce:	00005097          	auipc	ra,0x5
      d2:	58a080e7          	jalr	1418(ra) # 5658 <open>
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
      ea:	dba50513          	addi	a0,a0,-582 # 5ea0 <malloc+0x44a>
      ee:	00006097          	auipc	ra,0x6
      f2:	8aa080e7          	jalr	-1878(ra) # 5998 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	520080e7          	jalr	1312(ra) # 5618 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	dc650513          	addi	a0,a0,-570 # 5ec8 <malloc+0x472>
     10a:	00006097          	auipc	ra,0x6
     10e:	88e080e7          	jalr	-1906(ra) # 5998 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	504080e7          	jalr	1284(ra) # 5618 <exit>

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
     130:	dc450513          	addi	a0,a0,-572 # 5ef0 <malloc+0x49a>
     134:	00005097          	auipc	ra,0x5
     138:	534080e7          	jalr	1332(ra) # 5668 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	db050513          	addi	a0,a0,-592 # 5ef0 <malloc+0x49a>
     148:	00005097          	auipc	ra,0x5
     14c:	510080e7          	jalr	1296(ra) # 5658 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	dac58593          	addi	a1,a1,-596 # 5f00 <malloc+0x4aa>
     15c:	00005097          	auipc	ra,0x5
     160:	4dc080e7          	jalr	1244(ra) # 5638 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	d8850513          	addi	a0,a0,-632 # 5ef0 <malloc+0x49a>
     170:	00005097          	auipc	ra,0x5
     174:	4e8080e7          	jalr	1256(ra) # 5658 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	d8c58593          	addi	a1,a1,-628 # 5f08 <malloc+0x4b2>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	4b2080e7          	jalr	1202(ra) # 5638 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	d5c50513          	addi	a0,a0,-676 # 5ef0 <malloc+0x49a>
     19c:	00005097          	auipc	ra,0x5
     1a0:	4cc080e7          	jalr	1228(ra) # 5668 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	49a080e7          	jalr	1178(ra) # 5640 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	490080e7          	jalr	1168(ra) # 5640 <close>
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
     1ce:	d4650513          	addi	a0,a0,-698 # 5f10 <malloc+0x4ba>
     1d2:	00005097          	auipc	ra,0x5
     1d6:	7c6080e7          	jalr	1990(ra) # 5998 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	43c080e7          	jalr	1084(ra) # 5618 <exit>

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
     214:	448080e7          	jalr	1096(ra) # 5658 <open>
    close(fd);
     218:	00005097          	auipc	ra,0x5
     21c:	428080e7          	jalr	1064(ra) # 5640 <close>
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
     24a:	422080e7          	jalr	1058(ra) # 5668 <unlink>
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
     280:	a9450513          	addi	a0,a0,-1388 # 5d10 <malloc+0x2ba>
     284:	00005097          	auipc	ra,0x5
     288:	3e4080e7          	jalr	996(ra) # 5668 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	a80a8a93          	addi	s5,s5,-1408 # 5d10 <malloc+0x2ba>
      int cc = write(fd, buf, sz);
     298:	0000ca17          	auipc	s4,0xc
     29c:	818a0a13          	addi	s4,s4,-2024 # bab0 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x16f>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00005097          	auipc	ra,0x5
     2b0:	3ac080e7          	jalr	940(ra) # 5658 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00005097          	auipc	ra,0x5
     2c2:	37a080e7          	jalr	890(ra) # 5638 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	366080e7          	jalr	870(ra) # 5638 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	360080e7          	jalr	864(ra) # 5640 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00005097          	auipc	ra,0x5
     2ee:	37e080e7          	jalr	894(ra) # 5668 <unlink>
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
     316:	c2650513          	addi	a0,a0,-986 # 5f38 <malloc+0x4e2>
     31a:	00005097          	auipc	ra,0x5
     31e:	67e080e7          	jalr	1662(ra) # 5998 <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	2f4080e7          	jalr	756(ra) # 5618 <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	c2250513          	addi	a0,a0,-990 # 5f58 <malloc+0x502>
     33e:	00005097          	auipc	ra,0x5
     342:	65a080e7          	jalr	1626(ra) # 5998 <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	2d0080e7          	jalr	720(ra) # 5618 <exit>

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
     376:	bfea0a13          	addi	s4,s4,-1026 # 5f70 <malloc+0x51a>
    uint64 addr = addrs[ai];
     37a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     37e:	20100593          	li	a1,513
     382:	8552                	mv	a0,s4
     384:	00005097          	auipc	ra,0x5
     388:	2d4080e7          	jalr	724(ra) # 5658 <open>
     38c:	84aa                	mv	s1,a0
    if(fd < 0){
     38e:	08054863          	bltz	a0,41e <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     392:	6609                	lui	a2,0x2
     394:	85ce                	mv	a1,s3
     396:	00005097          	auipc	ra,0x5
     39a:	2a2080e7          	jalr	674(ra) # 5638 <write>
    if(n >= 0){
     39e:	08055d63          	bgez	a0,438 <copyin+0xe8>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00005097          	auipc	ra,0x5
     3a8:	29c080e7          	jalr	668(ra) # 5640 <close>
    unlink("copyin1");
     3ac:	8552                	mv	a0,s4
     3ae:	00005097          	auipc	ra,0x5
     3b2:	2ba080e7          	jalr	698(ra) # 5668 <unlink>
    n = write(1, (char*)addr, 8192);
     3b6:	6609                	lui	a2,0x2
     3b8:	85ce                	mv	a1,s3
     3ba:	4505                	li	a0,1
     3bc:	00005097          	auipc	ra,0x5
     3c0:	27c080e7          	jalr	636(ra) # 5638 <write>
    if(n > 0){
     3c4:	08a04963          	bgtz	a0,456 <copyin+0x106>
    if(pipe(fds) < 0){
     3c8:	fb840513          	addi	a0,s0,-72
     3cc:	00005097          	auipc	ra,0x5
     3d0:	25c080e7          	jalr	604(ra) # 5628 <pipe>
     3d4:	0a054063          	bltz	a0,474 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3d8:	6609                	lui	a2,0x2
     3da:	85ce                	mv	a1,s3
     3dc:	fbc42503          	lw	a0,-68(s0)
     3e0:	00005097          	auipc	ra,0x5
     3e4:	258080e7          	jalr	600(ra) # 5638 <write>
    if(n > 0){
     3e8:	0aa04363          	bgtz	a0,48e <copyin+0x13e>
    close(fds[0]);
     3ec:	fb842503          	lw	a0,-72(s0)
     3f0:	00005097          	auipc	ra,0x5
     3f4:	250080e7          	jalr	592(ra) # 5640 <close>
    close(fds[1]);
     3f8:	fbc42503          	lw	a0,-68(s0)
     3fc:	00005097          	auipc	ra,0x5
     400:	244080e7          	jalr	580(ra) # 5640 <close>
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
     422:	b5a50513          	addi	a0,a0,-1190 # 5f78 <malloc+0x522>
     426:	00005097          	auipc	ra,0x5
     42a:	572080e7          	jalr	1394(ra) # 5998 <printf>
      exit(1);
     42e:	4505                	li	a0,1
     430:	00005097          	auipc	ra,0x5
     434:	1e8080e7          	jalr	488(ra) # 5618 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     438:	862a                	mv	a2,a0
     43a:	85ce                	mv	a1,s3
     43c:	00006517          	auipc	a0,0x6
     440:	b5450513          	addi	a0,a0,-1196 # 5f90 <malloc+0x53a>
     444:	00005097          	auipc	ra,0x5
     448:	554080e7          	jalr	1364(ra) # 5998 <printf>
      exit(1);
     44c:	4505                	li	a0,1
     44e:	00005097          	auipc	ra,0x5
     452:	1ca080e7          	jalr	458(ra) # 5618 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     456:	862a                	mv	a2,a0
     458:	85ce                	mv	a1,s3
     45a:	00006517          	auipc	a0,0x6
     45e:	b6650513          	addi	a0,a0,-1178 # 5fc0 <malloc+0x56a>
     462:	00005097          	auipc	ra,0x5
     466:	536080e7          	jalr	1334(ra) # 5998 <printf>
      exit(1);
     46a:	4505                	li	a0,1
     46c:	00005097          	auipc	ra,0x5
     470:	1ac080e7          	jalr	428(ra) # 5618 <exit>
      printf("pipe() failed\n");
     474:	00006517          	auipc	a0,0x6
     478:	b7c50513          	addi	a0,a0,-1156 # 5ff0 <malloc+0x59a>
     47c:	00005097          	auipc	ra,0x5
     480:	51c080e7          	jalr	1308(ra) # 5998 <printf>
      exit(1);
     484:	4505                	li	a0,1
     486:	00005097          	auipc	ra,0x5
     48a:	192080e7          	jalr	402(ra) # 5618 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     48e:	862a                	mv	a2,a0
     490:	85ce                	mv	a1,s3
     492:	00006517          	auipc	a0,0x6
     496:	b6e50513          	addi	a0,a0,-1170 # 6000 <malloc+0x5aa>
     49a:	00005097          	auipc	ra,0x5
     49e:	4fe080e7          	jalr	1278(ra) # 5998 <printf>
      exit(1);
     4a2:	4505                	li	a0,1
     4a4:	00005097          	auipc	ra,0x5
     4a8:	174080e7          	jalr	372(ra) # 5618 <exit>

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
     4d4:	b60a0a13          	addi	s4,s4,-1184 # 6030 <malloc+0x5da>
    n = write(fds[1], "x", 1);
     4d8:	00006a97          	auipc	s5,0x6
     4dc:	a30a8a93          	addi	s5,s5,-1488 # 5f08 <malloc+0x4b2>
    uint64 addr = addrs[ai];
     4e0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4e4:	4581                	li	a1,0
     4e6:	8552                	mv	a0,s4
     4e8:	00005097          	auipc	ra,0x5
     4ec:	170080e7          	jalr	368(ra) # 5658 <open>
     4f0:	84aa                	mv	s1,a0
    if(fd < 0){
     4f2:	08054663          	bltz	a0,57e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     4f6:	6609                	lui	a2,0x2
     4f8:	85ce                	mv	a1,s3
     4fa:	00005097          	auipc	ra,0x5
     4fe:	136080e7          	jalr	310(ra) # 5630 <read>
    if(n > 0){
     502:	08a04b63          	bgtz	a0,598 <copyout+0xec>
    close(fd);
     506:	8526                	mv	a0,s1
     508:	00005097          	auipc	ra,0x5
     50c:	138080e7          	jalr	312(ra) # 5640 <close>
    if(pipe(fds) < 0){
     510:	fa840513          	addi	a0,s0,-88
     514:	00005097          	auipc	ra,0x5
     518:	114080e7          	jalr	276(ra) # 5628 <pipe>
     51c:	08054d63          	bltz	a0,5b6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     520:	4605                	li	a2,1
     522:	85d6                	mv	a1,s5
     524:	fac42503          	lw	a0,-84(s0)
     528:	00005097          	auipc	ra,0x5
     52c:	110080e7          	jalr	272(ra) # 5638 <write>
    if(n != 1){
     530:	4785                	li	a5,1
     532:	08f51f63          	bne	a0,a5,5d0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     536:	6609                	lui	a2,0x2
     538:	85ce                	mv	a1,s3
     53a:	fa842503          	lw	a0,-88(s0)
     53e:	00005097          	auipc	ra,0x5
     542:	0f2080e7          	jalr	242(ra) # 5630 <read>
    if(n > 0){
     546:	0aa04263          	bgtz	a0,5ea <copyout+0x13e>
    close(fds[0]);
     54a:	fa842503          	lw	a0,-88(s0)
     54e:	00005097          	auipc	ra,0x5
     552:	0f2080e7          	jalr	242(ra) # 5640 <close>
    close(fds[1]);
     556:	fac42503          	lw	a0,-84(s0)
     55a:	00005097          	auipc	ra,0x5
     55e:	0e6080e7          	jalr	230(ra) # 5640 <close>
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
     582:	aba50513          	addi	a0,a0,-1350 # 6038 <malloc+0x5e2>
     586:	00005097          	auipc	ra,0x5
     58a:	412080e7          	jalr	1042(ra) # 5998 <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	00005097          	auipc	ra,0x5
     594:	088080e7          	jalr	136(ra) # 5618 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     598:	862a                	mv	a2,a0
     59a:	85ce                	mv	a1,s3
     59c:	00006517          	auipc	a0,0x6
     5a0:	ab450513          	addi	a0,a0,-1356 # 6050 <malloc+0x5fa>
     5a4:	00005097          	auipc	ra,0x5
     5a8:	3f4080e7          	jalr	1012(ra) # 5998 <printf>
      exit(1);
     5ac:	4505                	li	a0,1
     5ae:	00005097          	auipc	ra,0x5
     5b2:	06a080e7          	jalr	106(ra) # 5618 <exit>
      printf("pipe() failed\n");
     5b6:	00006517          	auipc	a0,0x6
     5ba:	a3a50513          	addi	a0,a0,-1478 # 5ff0 <malloc+0x59a>
     5be:	00005097          	auipc	ra,0x5
     5c2:	3da080e7          	jalr	986(ra) # 5998 <printf>
      exit(1);
     5c6:	4505                	li	a0,1
     5c8:	00005097          	auipc	ra,0x5
     5cc:	050080e7          	jalr	80(ra) # 5618 <exit>
      printf("pipe write failed\n");
     5d0:	00006517          	auipc	a0,0x6
     5d4:	ab050513          	addi	a0,a0,-1360 # 6080 <malloc+0x62a>
     5d8:	00005097          	auipc	ra,0x5
     5dc:	3c0080e7          	jalr	960(ra) # 5998 <printf>
      exit(1);
     5e0:	4505                	li	a0,1
     5e2:	00005097          	auipc	ra,0x5
     5e6:	036080e7          	jalr	54(ra) # 5618 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ea:	862a                	mv	a2,a0
     5ec:	85ce                	mv	a1,s3
     5ee:	00006517          	auipc	a0,0x6
     5f2:	aaa50513          	addi	a0,a0,-1366 # 6098 <malloc+0x642>
     5f6:	00005097          	auipc	ra,0x5
     5fa:	3a2080e7          	jalr	930(ra) # 5998 <printf>
      exit(1);
     5fe:	4505                	li	a0,1
     600:	00005097          	auipc	ra,0x5
     604:	018080e7          	jalr	24(ra) # 5618 <exit>

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
     620:	8d450513          	addi	a0,a0,-1836 # 5ef0 <malloc+0x49a>
     624:	00005097          	auipc	ra,0x5
     628:	044080e7          	jalr	68(ra) # 5668 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     62c:	60100593          	li	a1,1537
     630:	00006517          	auipc	a0,0x6
     634:	8c050513          	addi	a0,a0,-1856 # 5ef0 <malloc+0x49a>
     638:	00005097          	auipc	ra,0x5
     63c:	020080e7          	jalr	32(ra) # 5658 <open>
     640:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     642:	4611                	li	a2,4
     644:	00006597          	auipc	a1,0x6
     648:	8bc58593          	addi	a1,a1,-1860 # 5f00 <malloc+0x4aa>
     64c:	00005097          	auipc	ra,0x5
     650:	fec080e7          	jalr	-20(ra) # 5638 <write>
  close(fd1);
     654:	8526                	mv	a0,s1
     656:	00005097          	auipc	ra,0x5
     65a:	fea080e7          	jalr	-22(ra) # 5640 <close>
  int fd2 = open("truncfile", O_RDONLY);
     65e:	4581                	li	a1,0
     660:	00006517          	auipc	a0,0x6
     664:	89050513          	addi	a0,a0,-1904 # 5ef0 <malloc+0x49a>
     668:	00005097          	auipc	ra,0x5
     66c:	ff0080e7          	jalr	-16(ra) # 5658 <open>
     670:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     672:	02000613          	li	a2,32
     676:	fa040593          	addi	a1,s0,-96
     67a:	00005097          	auipc	ra,0x5
     67e:	fb6080e7          	jalr	-74(ra) # 5630 <read>
  if(n != 4){
     682:	4791                	li	a5,4
     684:	0cf51e63          	bne	a0,a5,760 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     688:	40100593          	li	a1,1025
     68c:	00006517          	auipc	a0,0x6
     690:	86450513          	addi	a0,a0,-1948 # 5ef0 <malloc+0x49a>
     694:	00005097          	auipc	ra,0x5
     698:	fc4080e7          	jalr	-60(ra) # 5658 <open>
     69c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     69e:	4581                	li	a1,0
     6a0:	00006517          	auipc	a0,0x6
     6a4:	85050513          	addi	a0,a0,-1968 # 5ef0 <malloc+0x49a>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	fb0080e7          	jalr	-80(ra) # 5658 <open>
     6b0:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6b2:	02000613          	li	a2,32
     6b6:	fa040593          	addi	a1,s0,-96
     6ba:	00005097          	auipc	ra,0x5
     6be:	f76080e7          	jalr	-138(ra) # 5630 <read>
     6c2:	8a2a                	mv	s4,a0
  if(n != 0){
     6c4:	ed4d                	bnez	a0,77e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	8526                	mv	a0,s1
     6d0:	00005097          	auipc	ra,0x5
     6d4:	f60080e7          	jalr	-160(ra) # 5630 <read>
     6d8:	8a2a                	mv	s4,a0
  if(n != 0){
     6da:	e971                	bnez	a0,7ae <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6dc:	4619                	li	a2,6
     6de:	00006597          	auipc	a1,0x6
     6e2:	a4a58593          	addi	a1,a1,-1462 # 6128 <malloc+0x6d2>
     6e6:	854e                	mv	a0,s3
     6e8:	00005097          	auipc	ra,0x5
     6ec:	f50080e7          	jalr	-176(ra) # 5638 <write>
  n = read(fd3, buf, sizeof(buf));
     6f0:	02000613          	li	a2,32
     6f4:	fa040593          	addi	a1,s0,-96
     6f8:	854a                	mv	a0,s2
     6fa:	00005097          	auipc	ra,0x5
     6fe:	f36080e7          	jalr	-202(ra) # 5630 <read>
  if(n != 6){
     702:	4799                	li	a5,6
     704:	0cf51d63          	bne	a0,a5,7de <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     708:	02000613          	li	a2,32
     70c:	fa040593          	addi	a1,s0,-96
     710:	8526                	mv	a0,s1
     712:	00005097          	auipc	ra,0x5
     716:	f1e080e7          	jalr	-226(ra) # 5630 <read>
  if(n != 2){
     71a:	4789                	li	a5,2
     71c:	0ef51063          	bne	a0,a5,7fc <truncate1+0x1f4>
  unlink("truncfile");
     720:	00005517          	auipc	a0,0x5
     724:	7d050513          	addi	a0,a0,2000 # 5ef0 <malloc+0x49a>
     728:	00005097          	auipc	ra,0x5
     72c:	f40080e7          	jalr	-192(ra) # 5668 <unlink>
  close(fd1);
     730:	854e                	mv	a0,s3
     732:	00005097          	auipc	ra,0x5
     736:	f0e080e7          	jalr	-242(ra) # 5640 <close>
  close(fd2);
     73a:	8526                	mv	a0,s1
     73c:	00005097          	auipc	ra,0x5
     740:	f04080e7          	jalr	-252(ra) # 5640 <close>
  close(fd3);
     744:	854a                	mv	a0,s2
     746:	00005097          	auipc	ra,0x5
     74a:	efa080e7          	jalr	-262(ra) # 5640 <close>
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
     768:	96450513          	addi	a0,a0,-1692 # 60c8 <malloc+0x672>
     76c:	00005097          	auipc	ra,0x5
     770:	22c080e7          	jalr	556(ra) # 5998 <printf>
    exit(1);
     774:	4505                	li	a0,1
     776:	00005097          	auipc	ra,0x5
     77a:	ea2080e7          	jalr	-350(ra) # 5618 <exit>
    printf("aaa fd3=%d\n", fd3);
     77e:	85ca                	mv	a1,s2
     780:	00006517          	auipc	a0,0x6
     784:	96850513          	addi	a0,a0,-1688 # 60e8 <malloc+0x692>
     788:	00005097          	auipc	ra,0x5
     78c:	210080e7          	jalr	528(ra) # 5998 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     790:	8652                	mv	a2,s4
     792:	85d6                	mv	a1,s5
     794:	00006517          	auipc	a0,0x6
     798:	96450513          	addi	a0,a0,-1692 # 60f8 <malloc+0x6a2>
     79c:	00005097          	auipc	ra,0x5
     7a0:	1fc080e7          	jalr	508(ra) # 5998 <printf>
    exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	e72080e7          	jalr	-398(ra) # 5618 <exit>
    printf("bbb fd2=%d\n", fd2);
     7ae:	85a6                	mv	a1,s1
     7b0:	00006517          	auipc	a0,0x6
     7b4:	96850513          	addi	a0,a0,-1688 # 6118 <malloc+0x6c2>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	1e0080e7          	jalr	480(ra) # 5998 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7c0:	8652                	mv	a2,s4
     7c2:	85d6                	mv	a1,s5
     7c4:	00006517          	auipc	a0,0x6
     7c8:	93450513          	addi	a0,a0,-1740 # 60f8 <malloc+0x6a2>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	1cc080e7          	jalr	460(ra) # 5998 <printf>
    exit(1);
     7d4:	4505                	li	a0,1
     7d6:	00005097          	auipc	ra,0x5
     7da:	e42080e7          	jalr	-446(ra) # 5618 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7de:	862a                	mv	a2,a0
     7e0:	85d6                	mv	a1,s5
     7e2:	00006517          	auipc	a0,0x6
     7e6:	94e50513          	addi	a0,a0,-1714 # 6130 <malloc+0x6da>
     7ea:	00005097          	auipc	ra,0x5
     7ee:	1ae080e7          	jalr	430(ra) # 5998 <printf>
    exit(1);
     7f2:	4505                	li	a0,1
     7f4:	00005097          	auipc	ra,0x5
     7f8:	e24080e7          	jalr	-476(ra) # 5618 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     7fc:	862a                	mv	a2,a0
     7fe:	85d6                	mv	a1,s5
     800:	00006517          	auipc	a0,0x6
     804:	95050513          	addi	a0,a0,-1712 # 6150 <malloc+0x6fa>
     808:	00005097          	auipc	ra,0x5
     80c:	190080e7          	jalr	400(ra) # 5998 <printf>
    exit(1);
     810:	4505                	li	a0,1
     812:	00005097          	auipc	ra,0x5
     816:	e06080e7          	jalr	-506(ra) # 5618 <exit>

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
     838:	93c50513          	addi	a0,a0,-1732 # 6170 <malloc+0x71a>
     83c:	00005097          	auipc	ra,0x5
     840:	e1c080e7          	jalr	-484(ra) # 5658 <open>
  if(fd < 0){
     844:	0a054d63          	bltz	a0,8fe <writetest+0xe4>
     848:	892a                	mv	s2,a0
     84a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     84c:	00006997          	auipc	s3,0x6
     850:	94c98993          	addi	s3,s3,-1716 # 6198 <malloc+0x742>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     854:	00006a97          	auipc	s5,0x6
     858:	97ca8a93          	addi	s5,s5,-1668 # 61d0 <malloc+0x77a>
  for(i = 0; i < N; i++){
     85c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	4629                	li	a2,10
     862:	85ce                	mv	a1,s3
     864:	854a                	mv	a0,s2
     866:	00005097          	auipc	ra,0x5
     86a:	dd2080e7          	jalr	-558(ra) # 5638 <write>
     86e:	47a9                	li	a5,10
     870:	0af51563          	bne	a0,a5,91a <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85d6                	mv	a1,s5
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	dbe080e7          	jalr	-578(ra) # 5638 <write>
     882:	47a9                	li	a5,10
     884:	0af51a63          	bne	a0,a5,938 <writetest+0x11e>
  for(i = 0; i < N; i++){
     888:	2485                	addiw	s1,s1,1
     88a:	fd449be3          	bne	s1,s4,860 <writetest+0x46>
  close(fd);
     88e:	854a                	mv	a0,s2
     890:	00005097          	auipc	ra,0x5
     894:	db0080e7          	jalr	-592(ra) # 5640 <close>
  fd = open("small", O_RDONLY);
     898:	4581                	li	a1,0
     89a:	00006517          	auipc	a0,0x6
     89e:	8d650513          	addi	a0,a0,-1834 # 6170 <malloc+0x71a>
     8a2:	00005097          	auipc	ra,0x5
     8a6:	db6080e7          	jalr	-586(ra) # 5658 <open>
     8aa:	84aa                	mv	s1,a0
  if(fd < 0){
     8ac:	0a054563          	bltz	a0,956 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8b0:	7d000613          	li	a2,2000
     8b4:	0000b597          	auipc	a1,0xb
     8b8:	1fc58593          	addi	a1,a1,508 # bab0 <buf>
     8bc:	00005097          	auipc	ra,0x5
     8c0:	d74080e7          	jalr	-652(ra) # 5630 <read>
  if(i != N*SZ*2){
     8c4:	7d000793          	li	a5,2000
     8c8:	0af51563          	bne	a0,a5,972 <writetest+0x158>
  close(fd);
     8cc:	8526                	mv	a0,s1
     8ce:	00005097          	auipc	ra,0x5
     8d2:	d72080e7          	jalr	-654(ra) # 5640 <close>
  if(unlink("small") < 0){
     8d6:	00006517          	auipc	a0,0x6
     8da:	89a50513          	addi	a0,a0,-1894 # 6170 <malloc+0x71a>
     8de:	00005097          	auipc	ra,0x5
     8e2:	d8a080e7          	jalr	-630(ra) # 5668 <unlink>
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
     904:	87850513          	addi	a0,a0,-1928 # 6178 <malloc+0x722>
     908:	00005097          	auipc	ra,0x5
     90c:	090080e7          	jalr	144(ra) # 5998 <printf>
    exit(1);
     910:	4505                	li	a0,1
     912:	00005097          	auipc	ra,0x5
     916:	d06080e7          	jalr	-762(ra) # 5618 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     91a:	8626                	mv	a2,s1
     91c:	85da                	mv	a1,s6
     91e:	00006517          	auipc	a0,0x6
     922:	88a50513          	addi	a0,a0,-1910 # 61a8 <malloc+0x752>
     926:	00005097          	auipc	ra,0x5
     92a:	072080e7          	jalr	114(ra) # 5998 <printf>
      exit(1);
     92e:	4505                	li	a0,1
     930:	00005097          	auipc	ra,0x5
     934:	ce8080e7          	jalr	-792(ra) # 5618 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     938:	8626                	mv	a2,s1
     93a:	85da                	mv	a1,s6
     93c:	00006517          	auipc	a0,0x6
     940:	8a450513          	addi	a0,a0,-1884 # 61e0 <malloc+0x78a>
     944:	00005097          	auipc	ra,0x5
     948:	054080e7          	jalr	84(ra) # 5998 <printf>
      exit(1);
     94c:	4505                	li	a0,1
     94e:	00005097          	auipc	ra,0x5
     952:	cca080e7          	jalr	-822(ra) # 5618 <exit>
    printf("%s: error: open small failed!\n", s);
     956:	85da                	mv	a1,s6
     958:	00006517          	auipc	a0,0x6
     95c:	8b050513          	addi	a0,a0,-1872 # 6208 <malloc+0x7b2>
     960:	00005097          	auipc	ra,0x5
     964:	038080e7          	jalr	56(ra) # 5998 <printf>
    exit(1);
     968:	4505                	li	a0,1
     96a:	00005097          	auipc	ra,0x5
     96e:	cae080e7          	jalr	-850(ra) # 5618 <exit>
    printf("%s: read failed\n", s);
     972:	85da                	mv	a1,s6
     974:	00006517          	auipc	a0,0x6
     978:	8b450513          	addi	a0,a0,-1868 # 6228 <malloc+0x7d2>
     97c:	00005097          	auipc	ra,0x5
     980:	01c080e7          	jalr	28(ra) # 5998 <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	c92080e7          	jalr	-878(ra) # 5618 <exit>
    printf("%s: unlink small failed\n", s);
     98e:	85da                	mv	a1,s6
     990:	00006517          	auipc	a0,0x6
     994:	8b050513          	addi	a0,a0,-1872 # 6240 <malloc+0x7ea>
     998:	00005097          	auipc	ra,0x5
     99c:	000080e7          	jalr	ra # 5998 <printf>
    exit(1);
     9a0:	4505                	li	a0,1
     9a2:	00005097          	auipc	ra,0x5
     9a6:	c76080e7          	jalr	-906(ra) # 5618 <exit>

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
     9c6:	89e50513          	addi	a0,a0,-1890 # 6260 <malloc+0x80a>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	c8e080e7          	jalr	-882(ra) # 5658 <open>
  if(fd < 0){
     9d2:	08054563          	bltz	a0,a5c <writebig+0xb2>
     9d6:	89aa                	mv	s3,a0
     9d8:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9da:	0000b917          	auipc	s2,0xb
     9de:	0d690913          	addi	s2,s2,214 # bab0 <buf>
  for(i = 0; i < MAXFILE; i++){
     9e2:	6a41                	lui	s4,0x10
     9e4:	10ba0a13          	addi	s4,s4,267 # 1010b <__BSS_END__+0x164b>
    ((int*)buf)[0] = i;
     9e8:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9ec:	40000613          	li	a2,1024
     9f0:	85ca                	mv	a1,s2
     9f2:	854e                	mv	a0,s3
     9f4:	00005097          	auipc	ra,0x5
     9f8:	c44080e7          	jalr	-956(ra) # 5638 <write>
     9fc:	40000793          	li	a5,1024
     a00:	06f51c63          	bne	a0,a5,a78 <writebig+0xce>
  for(i = 0; i < MAXFILE; i++){
     a04:	2485                	addiw	s1,s1,1
     a06:	ff4491e3          	bne	s1,s4,9e8 <writebig+0x3e>
  close(fd);
     a0a:	854e                	mv	a0,s3
     a0c:	00005097          	auipc	ra,0x5
     a10:	c34080e7          	jalr	-972(ra) # 5640 <close>
  fd = open("big", O_RDONLY);
     a14:	4581                	li	a1,0
     a16:	00006517          	auipc	a0,0x6
     a1a:	84a50513          	addi	a0,a0,-1974 # 6260 <malloc+0x80a>
     a1e:	00005097          	auipc	ra,0x5
     a22:	c3a080e7          	jalr	-966(ra) # 5658 <open>
     a26:	89aa                	mv	s3,a0
  n = 0;
     a28:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a2a:	0000b917          	auipc	s2,0xb
     a2e:	08690913          	addi	s2,s2,134 # bab0 <buf>
  if(fd < 0){
     a32:	06054263          	bltz	a0,a96 <writebig+0xec>
    i = read(fd, buf, BSIZE);
     a36:	40000613          	li	a2,1024
     a3a:	85ca                	mv	a1,s2
     a3c:	854e                	mv	a0,s3
     a3e:	00005097          	auipc	ra,0x5
     a42:	bf2080e7          	jalr	-1038(ra) # 5630 <read>
    if(i == 0){
     a46:	c535                	beqz	a0,ab2 <writebig+0x108>
    } else if(i != BSIZE){
     a48:	40000793          	li	a5,1024
     a4c:	0af51f63          	bne	a0,a5,b0a <writebig+0x160>
    if(((int*)buf)[0] != n){
     a50:	00092683          	lw	a3,0(s2)
     a54:	0c969a63          	bne	a3,s1,b28 <writebig+0x17e>
    n++;
     a58:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a5a:	bff1                	j	a36 <writebig+0x8c>
    printf("%s: error: creat big failed!\n", s);
     a5c:	85d6                	mv	a1,s5
     a5e:	00006517          	auipc	a0,0x6
     a62:	80a50513          	addi	a0,a0,-2038 # 6268 <malloc+0x812>
     a66:	00005097          	auipc	ra,0x5
     a6a:	f32080e7          	jalr	-206(ra) # 5998 <printf>
    exit(1);
     a6e:	4505                	li	a0,1
     a70:	00005097          	auipc	ra,0x5
     a74:	ba8080e7          	jalr	-1112(ra) # 5618 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a78:	8626                	mv	a2,s1
     a7a:	85d6                	mv	a1,s5
     a7c:	00006517          	auipc	a0,0x6
     a80:	80c50513          	addi	a0,a0,-2036 # 6288 <malloc+0x832>
     a84:	00005097          	auipc	ra,0x5
     a88:	f14080e7          	jalr	-236(ra) # 5998 <printf>
      exit(1);
     a8c:	4505                	li	a0,1
     a8e:	00005097          	auipc	ra,0x5
     a92:	b8a080e7          	jalr	-1142(ra) # 5618 <exit>
    printf("%s: error: open big failed!\n", s);
     a96:	85d6                	mv	a1,s5
     a98:	00006517          	auipc	a0,0x6
     a9c:	81850513          	addi	a0,a0,-2024 # 62b0 <malloc+0x85a>
     aa0:	00005097          	auipc	ra,0x5
     aa4:	ef8080e7          	jalr	-264(ra) # 5998 <printf>
    exit(1);
     aa8:	4505                	li	a0,1
     aaa:	00005097          	auipc	ra,0x5
     aae:	b6e080e7          	jalr	-1170(ra) # 5618 <exit>
      if(n == MAXFILE - 1){
     ab2:	67c1                	lui	a5,0x10
     ab4:	10a78793          	addi	a5,a5,266 # 1010a <__BSS_END__+0x164a>
     ab8:	02f48a63          	beq	s1,a5,aec <writebig+0x142>
  close(fd);
     abc:	854e                	mv	a0,s3
     abe:	00005097          	auipc	ra,0x5
     ac2:	b82080e7          	jalr	-1150(ra) # 5640 <close>
  if(unlink("big") < 0){
     ac6:	00005517          	auipc	a0,0x5
     aca:	79a50513          	addi	a0,a0,1946 # 6260 <malloc+0x80a>
     ace:	00005097          	auipc	ra,0x5
     ad2:	b9a080e7          	jalr	-1126(ra) # 5668 <unlink>
     ad6:	06054863          	bltz	a0,b46 <writebig+0x19c>
}
     ada:	70e2                	ld	ra,56(sp)
     adc:	7442                	ld	s0,48(sp)
     ade:	74a2                	ld	s1,40(sp)
     ae0:	7902                	ld	s2,32(sp)
     ae2:	69e2                	ld	s3,24(sp)
     ae4:	6a42                	ld	s4,16(sp)
     ae6:	6aa2                	ld	s5,8(sp)
     ae8:	6121                	addi	sp,sp,64
     aea:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     aec:	863e                	mv	a2,a5
     aee:	85d6                	mv	a1,s5
     af0:	00005517          	auipc	a0,0x5
     af4:	7e050513          	addi	a0,a0,2016 # 62d0 <malloc+0x87a>
     af8:	00005097          	auipc	ra,0x5
     afc:	ea0080e7          	jalr	-352(ra) # 5998 <printf>
        exit(1);
     b00:	4505                	li	a0,1
     b02:	00005097          	auipc	ra,0x5
     b06:	b16080e7          	jalr	-1258(ra) # 5618 <exit>
      printf("%s: read failed %d\n", s, i);
     b0a:	862a                	mv	a2,a0
     b0c:	85d6                	mv	a1,s5
     b0e:	00005517          	auipc	a0,0x5
     b12:	7ea50513          	addi	a0,a0,2026 # 62f8 <malloc+0x8a2>
     b16:	00005097          	auipc	ra,0x5
     b1a:	e82080e7          	jalr	-382(ra) # 5998 <printf>
      exit(1);
     b1e:	4505                	li	a0,1
     b20:	00005097          	auipc	ra,0x5
     b24:	af8080e7          	jalr	-1288(ra) # 5618 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b28:	8626                	mv	a2,s1
     b2a:	85d6                	mv	a1,s5
     b2c:	00005517          	auipc	a0,0x5
     b30:	7e450513          	addi	a0,a0,2020 # 6310 <malloc+0x8ba>
     b34:	00005097          	auipc	ra,0x5
     b38:	e64080e7          	jalr	-412(ra) # 5998 <printf>
      exit(1);
     b3c:	4505                	li	a0,1
     b3e:	00005097          	auipc	ra,0x5
     b42:	ada080e7          	jalr	-1318(ra) # 5618 <exit>
    printf("%s: unlink big failed\n", s);
     b46:	85d6                	mv	a1,s5
     b48:	00005517          	auipc	a0,0x5
     b4c:	7f050513          	addi	a0,a0,2032 # 6338 <malloc+0x8e2>
     b50:	00005097          	auipc	ra,0x5
     b54:	e48080e7          	jalr	-440(ra) # 5998 <printf>
    exit(1);
     b58:	4505                	li	a0,1
     b5a:	00005097          	auipc	ra,0x5
     b5e:	abe080e7          	jalr	-1346(ra) # 5618 <exit>

0000000000000b62 <unlinkread>:
{
     b62:	7179                	addi	sp,sp,-48
     b64:	f406                	sd	ra,40(sp)
     b66:	f022                	sd	s0,32(sp)
     b68:	ec26                	sd	s1,24(sp)
     b6a:	e84a                	sd	s2,16(sp)
     b6c:	e44e                	sd	s3,8(sp)
     b6e:	1800                	addi	s0,sp,48
     b70:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b72:	20200593          	li	a1,514
     b76:	00005517          	auipc	a0,0x5
     b7a:	12a50513          	addi	a0,a0,298 # 5ca0 <malloc+0x24a>
     b7e:	00005097          	auipc	ra,0x5
     b82:	ada080e7          	jalr	-1318(ra) # 5658 <open>
  if(fd < 0){
     b86:	0e054563          	bltz	a0,c70 <unlinkread+0x10e>
     b8a:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b8c:	4615                	li	a2,5
     b8e:	00005597          	auipc	a1,0x5
     b92:	7e258593          	addi	a1,a1,2018 # 6370 <malloc+0x91a>
     b96:	00005097          	auipc	ra,0x5
     b9a:	aa2080e7          	jalr	-1374(ra) # 5638 <write>
  close(fd);
     b9e:	8526                	mv	a0,s1
     ba0:	00005097          	auipc	ra,0x5
     ba4:	aa0080e7          	jalr	-1376(ra) # 5640 <close>
  fd = open("unlinkread", O_RDWR);
     ba8:	4589                	li	a1,2
     baa:	00005517          	auipc	a0,0x5
     bae:	0f650513          	addi	a0,a0,246 # 5ca0 <malloc+0x24a>
     bb2:	00005097          	auipc	ra,0x5
     bb6:	aa6080e7          	jalr	-1370(ra) # 5658 <open>
     bba:	84aa                	mv	s1,a0
  if(fd < 0){
     bbc:	0c054863          	bltz	a0,c8c <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bc0:	00005517          	auipc	a0,0x5
     bc4:	0e050513          	addi	a0,a0,224 # 5ca0 <malloc+0x24a>
     bc8:	00005097          	auipc	ra,0x5
     bcc:	aa0080e7          	jalr	-1376(ra) # 5668 <unlink>
     bd0:	ed61                	bnez	a0,ca8 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd2:	20200593          	li	a1,514
     bd6:	00005517          	auipc	a0,0x5
     bda:	0ca50513          	addi	a0,a0,202 # 5ca0 <malloc+0x24a>
     bde:	00005097          	auipc	ra,0x5
     be2:	a7a080e7          	jalr	-1414(ra) # 5658 <open>
     be6:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     be8:	460d                	li	a2,3
     bea:	00005597          	auipc	a1,0x5
     bee:	7ce58593          	addi	a1,a1,1998 # 63b8 <malloc+0x962>
     bf2:	00005097          	auipc	ra,0x5
     bf6:	a46080e7          	jalr	-1466(ra) # 5638 <write>
  close(fd1);
     bfa:	854a                	mv	a0,s2
     bfc:	00005097          	auipc	ra,0x5
     c00:	a44080e7          	jalr	-1468(ra) # 5640 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c04:	660d                	lui	a2,0x3
     c06:	0000b597          	auipc	a1,0xb
     c0a:	eaa58593          	addi	a1,a1,-342 # bab0 <buf>
     c0e:	8526                	mv	a0,s1
     c10:	00005097          	auipc	ra,0x5
     c14:	a20080e7          	jalr	-1504(ra) # 5630 <read>
     c18:	4795                	li	a5,5
     c1a:	0af51563          	bne	a0,a5,cc4 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c1e:	0000b717          	auipc	a4,0xb
     c22:	e9274703          	lbu	a4,-366(a4) # bab0 <buf>
     c26:	06800793          	li	a5,104
     c2a:	0af71b63          	bne	a4,a5,ce0 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c2e:	4629                	li	a2,10
     c30:	0000b597          	auipc	a1,0xb
     c34:	e8058593          	addi	a1,a1,-384 # bab0 <buf>
     c38:	8526                	mv	a0,s1
     c3a:	00005097          	auipc	ra,0x5
     c3e:	9fe080e7          	jalr	-1538(ra) # 5638 <write>
     c42:	47a9                	li	a5,10
     c44:	0af51c63          	bne	a0,a5,cfc <unlinkread+0x19a>
  close(fd);
     c48:	8526                	mv	a0,s1
     c4a:	00005097          	auipc	ra,0x5
     c4e:	9f6080e7          	jalr	-1546(ra) # 5640 <close>
  unlink("unlinkread");
     c52:	00005517          	auipc	a0,0x5
     c56:	04e50513          	addi	a0,a0,78 # 5ca0 <malloc+0x24a>
     c5a:	00005097          	auipc	ra,0x5
     c5e:	a0e080e7          	jalr	-1522(ra) # 5668 <unlink>
}
     c62:	70a2                	ld	ra,40(sp)
     c64:	7402                	ld	s0,32(sp)
     c66:	64e2                	ld	s1,24(sp)
     c68:	6942                	ld	s2,16(sp)
     c6a:	69a2                	ld	s3,8(sp)
     c6c:	6145                	addi	sp,sp,48
     c6e:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c70:	85ce                	mv	a1,s3
     c72:	00005517          	auipc	a0,0x5
     c76:	6de50513          	addi	a0,a0,1758 # 6350 <malloc+0x8fa>
     c7a:	00005097          	auipc	ra,0x5
     c7e:	d1e080e7          	jalr	-738(ra) # 5998 <printf>
    exit(1);
     c82:	4505                	li	a0,1
     c84:	00005097          	auipc	ra,0x5
     c88:	994080e7          	jalr	-1644(ra) # 5618 <exit>
    printf("%s: open unlinkread failed\n", s);
     c8c:	85ce                	mv	a1,s3
     c8e:	00005517          	auipc	a0,0x5
     c92:	6ea50513          	addi	a0,a0,1770 # 6378 <malloc+0x922>
     c96:	00005097          	auipc	ra,0x5
     c9a:	d02080e7          	jalr	-766(ra) # 5998 <printf>
    exit(1);
     c9e:	4505                	li	a0,1
     ca0:	00005097          	auipc	ra,0x5
     ca4:	978080e7          	jalr	-1672(ra) # 5618 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ca8:	85ce                	mv	a1,s3
     caa:	00005517          	auipc	a0,0x5
     cae:	6ee50513          	addi	a0,a0,1774 # 6398 <malloc+0x942>
     cb2:	00005097          	auipc	ra,0x5
     cb6:	ce6080e7          	jalr	-794(ra) # 5998 <printf>
    exit(1);
     cba:	4505                	li	a0,1
     cbc:	00005097          	auipc	ra,0x5
     cc0:	95c080e7          	jalr	-1700(ra) # 5618 <exit>
    printf("%s: unlinkread read failed", s);
     cc4:	85ce                	mv	a1,s3
     cc6:	00005517          	auipc	a0,0x5
     cca:	6fa50513          	addi	a0,a0,1786 # 63c0 <malloc+0x96a>
     cce:	00005097          	auipc	ra,0x5
     cd2:	cca080e7          	jalr	-822(ra) # 5998 <printf>
    exit(1);
     cd6:	4505                	li	a0,1
     cd8:	00005097          	auipc	ra,0x5
     cdc:	940080e7          	jalr	-1728(ra) # 5618 <exit>
    printf("%s: unlinkread wrong data\n", s);
     ce0:	85ce                	mv	a1,s3
     ce2:	00005517          	auipc	a0,0x5
     ce6:	6fe50513          	addi	a0,a0,1790 # 63e0 <malloc+0x98a>
     cea:	00005097          	auipc	ra,0x5
     cee:	cae080e7          	jalr	-850(ra) # 5998 <printf>
    exit(1);
     cf2:	4505                	li	a0,1
     cf4:	00005097          	auipc	ra,0x5
     cf8:	924080e7          	jalr	-1756(ra) # 5618 <exit>
    printf("%s: unlinkread write failed\n", s);
     cfc:	85ce                	mv	a1,s3
     cfe:	00005517          	auipc	a0,0x5
     d02:	70250513          	addi	a0,a0,1794 # 6400 <malloc+0x9aa>
     d06:	00005097          	auipc	ra,0x5
     d0a:	c92080e7          	jalr	-878(ra) # 5998 <printf>
    exit(1);
     d0e:	4505                	li	a0,1
     d10:	00005097          	auipc	ra,0x5
     d14:	908080e7          	jalr	-1784(ra) # 5618 <exit>

0000000000000d18 <linktest>:
{
     d18:	1101                	addi	sp,sp,-32
     d1a:	ec06                	sd	ra,24(sp)
     d1c:	e822                	sd	s0,16(sp)
     d1e:	e426                	sd	s1,8(sp)
     d20:	e04a                	sd	s2,0(sp)
     d22:	1000                	addi	s0,sp,32
     d24:	892a                	mv	s2,a0
  unlink("lf1");
     d26:	00005517          	auipc	a0,0x5
     d2a:	6fa50513          	addi	a0,a0,1786 # 6420 <malloc+0x9ca>
     d2e:	00005097          	auipc	ra,0x5
     d32:	93a080e7          	jalr	-1734(ra) # 5668 <unlink>
  unlink("lf2");
     d36:	00005517          	auipc	a0,0x5
     d3a:	6f250513          	addi	a0,a0,1778 # 6428 <malloc+0x9d2>
     d3e:	00005097          	auipc	ra,0x5
     d42:	92a080e7          	jalr	-1750(ra) # 5668 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d46:	20200593          	li	a1,514
     d4a:	00005517          	auipc	a0,0x5
     d4e:	6d650513          	addi	a0,a0,1750 # 6420 <malloc+0x9ca>
     d52:	00005097          	auipc	ra,0x5
     d56:	906080e7          	jalr	-1786(ra) # 5658 <open>
  if(fd < 0){
     d5a:	10054763          	bltz	a0,e68 <linktest+0x150>
     d5e:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d60:	4615                	li	a2,5
     d62:	00005597          	auipc	a1,0x5
     d66:	60e58593          	addi	a1,a1,1550 # 6370 <malloc+0x91a>
     d6a:	00005097          	auipc	ra,0x5
     d6e:	8ce080e7          	jalr	-1842(ra) # 5638 <write>
     d72:	4795                	li	a5,5
     d74:	10f51863          	bne	a0,a5,e84 <linktest+0x16c>
  close(fd);
     d78:	8526                	mv	a0,s1
     d7a:	00005097          	auipc	ra,0x5
     d7e:	8c6080e7          	jalr	-1850(ra) # 5640 <close>
  if(link("lf1", "lf2") < 0){
     d82:	00005597          	auipc	a1,0x5
     d86:	6a658593          	addi	a1,a1,1702 # 6428 <malloc+0x9d2>
     d8a:	00005517          	auipc	a0,0x5
     d8e:	69650513          	addi	a0,a0,1686 # 6420 <malloc+0x9ca>
     d92:	00005097          	auipc	ra,0x5
     d96:	8e6080e7          	jalr	-1818(ra) # 5678 <link>
     d9a:	10054363          	bltz	a0,ea0 <linktest+0x188>
  unlink("lf1");
     d9e:	00005517          	auipc	a0,0x5
     da2:	68250513          	addi	a0,a0,1666 # 6420 <malloc+0x9ca>
     da6:	00005097          	auipc	ra,0x5
     daa:	8c2080e7          	jalr	-1854(ra) # 5668 <unlink>
  if(open("lf1", 0) >= 0){
     dae:	4581                	li	a1,0
     db0:	00005517          	auipc	a0,0x5
     db4:	67050513          	addi	a0,a0,1648 # 6420 <malloc+0x9ca>
     db8:	00005097          	auipc	ra,0x5
     dbc:	8a0080e7          	jalr	-1888(ra) # 5658 <open>
     dc0:	0e055e63          	bgez	a0,ebc <linktest+0x1a4>
  fd = open("lf2", 0);
     dc4:	4581                	li	a1,0
     dc6:	00005517          	auipc	a0,0x5
     dca:	66250513          	addi	a0,a0,1634 # 6428 <malloc+0x9d2>
     dce:	00005097          	auipc	ra,0x5
     dd2:	88a080e7          	jalr	-1910(ra) # 5658 <open>
     dd6:	84aa                	mv	s1,a0
  if(fd < 0){
     dd8:	10054063          	bltz	a0,ed8 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     ddc:	660d                	lui	a2,0x3
     dde:	0000b597          	auipc	a1,0xb
     de2:	cd258593          	addi	a1,a1,-814 # bab0 <buf>
     de6:	00005097          	auipc	ra,0x5
     dea:	84a080e7          	jalr	-1974(ra) # 5630 <read>
     dee:	4795                	li	a5,5
     df0:	10f51263          	bne	a0,a5,ef4 <linktest+0x1dc>
  close(fd);
     df4:	8526                	mv	a0,s1
     df6:	00005097          	auipc	ra,0x5
     dfa:	84a080e7          	jalr	-1974(ra) # 5640 <close>
  if(link("lf2", "lf2") >= 0){
     dfe:	00005597          	auipc	a1,0x5
     e02:	62a58593          	addi	a1,a1,1578 # 6428 <malloc+0x9d2>
     e06:	852e                	mv	a0,a1
     e08:	00005097          	auipc	ra,0x5
     e0c:	870080e7          	jalr	-1936(ra) # 5678 <link>
     e10:	10055063          	bgez	a0,f10 <linktest+0x1f8>
  unlink("lf2");
     e14:	00005517          	auipc	a0,0x5
     e18:	61450513          	addi	a0,a0,1556 # 6428 <malloc+0x9d2>
     e1c:	00005097          	auipc	ra,0x5
     e20:	84c080e7          	jalr	-1972(ra) # 5668 <unlink>
  if(link("lf2", "lf1") >= 0){
     e24:	00005597          	auipc	a1,0x5
     e28:	5fc58593          	addi	a1,a1,1532 # 6420 <malloc+0x9ca>
     e2c:	00005517          	auipc	a0,0x5
     e30:	5fc50513          	addi	a0,a0,1532 # 6428 <malloc+0x9d2>
     e34:	00005097          	auipc	ra,0x5
     e38:	844080e7          	jalr	-1980(ra) # 5678 <link>
     e3c:	0e055863          	bgez	a0,f2c <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e40:	00005597          	auipc	a1,0x5
     e44:	5e058593          	addi	a1,a1,1504 # 6420 <malloc+0x9ca>
     e48:	00005517          	auipc	a0,0x5
     e4c:	6e850513          	addi	a0,a0,1768 # 6530 <malloc+0xada>
     e50:	00005097          	auipc	ra,0x5
     e54:	828080e7          	jalr	-2008(ra) # 5678 <link>
     e58:	0e055863          	bgez	a0,f48 <linktest+0x230>
}
     e5c:	60e2                	ld	ra,24(sp)
     e5e:	6442                	ld	s0,16(sp)
     e60:	64a2                	ld	s1,8(sp)
     e62:	6902                	ld	s2,0(sp)
     e64:	6105                	addi	sp,sp,32
     e66:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e68:	85ca                	mv	a1,s2
     e6a:	00005517          	auipc	a0,0x5
     e6e:	5c650513          	addi	a0,a0,1478 # 6430 <malloc+0x9da>
     e72:	00005097          	auipc	ra,0x5
     e76:	b26080e7          	jalr	-1242(ra) # 5998 <printf>
    exit(1);
     e7a:	4505                	li	a0,1
     e7c:	00004097          	auipc	ra,0x4
     e80:	79c080e7          	jalr	1948(ra) # 5618 <exit>
    printf("%s: write lf1 failed\n", s);
     e84:	85ca                	mv	a1,s2
     e86:	00005517          	auipc	a0,0x5
     e8a:	5c250513          	addi	a0,a0,1474 # 6448 <malloc+0x9f2>
     e8e:	00005097          	auipc	ra,0x5
     e92:	b0a080e7          	jalr	-1270(ra) # 5998 <printf>
    exit(1);
     e96:	4505                	li	a0,1
     e98:	00004097          	auipc	ra,0x4
     e9c:	780080e7          	jalr	1920(ra) # 5618 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     ea0:	85ca                	mv	a1,s2
     ea2:	00005517          	auipc	a0,0x5
     ea6:	5be50513          	addi	a0,a0,1470 # 6460 <malloc+0xa0a>
     eaa:	00005097          	auipc	ra,0x5
     eae:	aee080e7          	jalr	-1298(ra) # 5998 <printf>
    exit(1);
     eb2:	4505                	li	a0,1
     eb4:	00004097          	auipc	ra,0x4
     eb8:	764080e7          	jalr	1892(ra) # 5618 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ebc:	85ca                	mv	a1,s2
     ebe:	00005517          	auipc	a0,0x5
     ec2:	5c250513          	addi	a0,a0,1474 # 6480 <malloc+0xa2a>
     ec6:	00005097          	auipc	ra,0x5
     eca:	ad2080e7          	jalr	-1326(ra) # 5998 <printf>
    exit(1);
     ece:	4505                	li	a0,1
     ed0:	00004097          	auipc	ra,0x4
     ed4:	748080e7          	jalr	1864(ra) # 5618 <exit>
    printf("%s: open lf2 failed\n", s);
     ed8:	85ca                	mv	a1,s2
     eda:	00005517          	auipc	a0,0x5
     ede:	5d650513          	addi	a0,a0,1494 # 64b0 <malloc+0xa5a>
     ee2:	00005097          	auipc	ra,0x5
     ee6:	ab6080e7          	jalr	-1354(ra) # 5998 <printf>
    exit(1);
     eea:	4505                	li	a0,1
     eec:	00004097          	auipc	ra,0x4
     ef0:	72c080e7          	jalr	1836(ra) # 5618 <exit>
    printf("%s: read lf2 failed\n", s);
     ef4:	85ca                	mv	a1,s2
     ef6:	00005517          	auipc	a0,0x5
     efa:	5d250513          	addi	a0,a0,1490 # 64c8 <malloc+0xa72>
     efe:	00005097          	auipc	ra,0x5
     f02:	a9a080e7          	jalr	-1382(ra) # 5998 <printf>
    exit(1);
     f06:	4505                	li	a0,1
     f08:	00004097          	auipc	ra,0x4
     f0c:	710080e7          	jalr	1808(ra) # 5618 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f10:	85ca                	mv	a1,s2
     f12:	00005517          	auipc	a0,0x5
     f16:	5ce50513          	addi	a0,a0,1486 # 64e0 <malloc+0xa8a>
     f1a:	00005097          	auipc	ra,0x5
     f1e:	a7e080e7          	jalr	-1410(ra) # 5998 <printf>
    exit(1);
     f22:	4505                	li	a0,1
     f24:	00004097          	auipc	ra,0x4
     f28:	6f4080e7          	jalr	1780(ra) # 5618 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f2c:	85ca                	mv	a1,s2
     f2e:	00005517          	auipc	a0,0x5
     f32:	5da50513          	addi	a0,a0,1498 # 6508 <malloc+0xab2>
     f36:	00005097          	auipc	ra,0x5
     f3a:	a62080e7          	jalr	-1438(ra) # 5998 <printf>
    exit(1);
     f3e:	4505                	li	a0,1
     f40:	00004097          	auipc	ra,0x4
     f44:	6d8080e7          	jalr	1752(ra) # 5618 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f48:	85ca                	mv	a1,s2
     f4a:	00005517          	auipc	a0,0x5
     f4e:	5ee50513          	addi	a0,a0,1518 # 6538 <malloc+0xae2>
     f52:	00005097          	auipc	ra,0x5
     f56:	a46080e7          	jalr	-1466(ra) # 5998 <printf>
    exit(1);
     f5a:	4505                	li	a0,1
     f5c:	00004097          	auipc	ra,0x4
     f60:	6bc080e7          	jalr	1724(ra) # 5618 <exit>

0000000000000f64 <bigdir>:
{
     f64:	715d                	addi	sp,sp,-80
     f66:	e486                	sd	ra,72(sp)
     f68:	e0a2                	sd	s0,64(sp)
     f6a:	fc26                	sd	s1,56(sp)
     f6c:	f84a                	sd	s2,48(sp)
     f6e:	f44e                	sd	s3,40(sp)
     f70:	f052                	sd	s4,32(sp)
     f72:	ec56                	sd	s5,24(sp)
     f74:	e85a                	sd	s6,16(sp)
     f76:	0880                	addi	s0,sp,80
     f78:	89aa                	mv	s3,a0
  unlink("bd");
     f7a:	00005517          	auipc	a0,0x5
     f7e:	5de50513          	addi	a0,a0,1502 # 6558 <malloc+0xb02>
     f82:	00004097          	auipc	ra,0x4
     f86:	6e6080e7          	jalr	1766(ra) # 5668 <unlink>
  fd = open("bd", O_CREATE);
     f8a:	20000593          	li	a1,512
     f8e:	00005517          	auipc	a0,0x5
     f92:	5ca50513          	addi	a0,a0,1482 # 6558 <malloc+0xb02>
     f96:	00004097          	auipc	ra,0x4
     f9a:	6c2080e7          	jalr	1730(ra) # 5658 <open>
  if(fd < 0){
     f9e:	0c054963          	bltz	a0,1070 <bigdir+0x10c>
  close(fd);
     fa2:	00004097          	auipc	ra,0x4
     fa6:	69e080e7          	jalr	1694(ra) # 5640 <close>
  for(i = 0; i < N; i++){
     faa:	4901                	li	s2,0
    name[0] = 'x';
     fac:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fb0:	00005a17          	auipc	s4,0x5
     fb4:	5a8a0a13          	addi	s4,s4,1448 # 6558 <malloc+0xb02>
  for(i = 0; i < N; i++){
     fb8:	1f400b13          	li	s6,500
    name[0] = 'x';
     fbc:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fc0:	41f9579b          	sraiw	a5,s2,0x1f
     fc4:	01a7d71b          	srliw	a4,a5,0x1a
     fc8:	012707bb          	addw	a5,a4,s2
     fcc:	4067d69b          	sraiw	a3,a5,0x6
     fd0:	0306869b          	addiw	a3,a3,48
     fd4:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fd8:	03f7f793          	andi	a5,a5,63
     fdc:	9f99                	subw	a5,a5,a4
     fde:	0307879b          	addiw	a5,a5,48
     fe2:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     fe6:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     fea:	fb040593          	addi	a1,s0,-80
     fee:	8552                	mv	a0,s4
     ff0:	00004097          	auipc	ra,0x4
     ff4:	688080e7          	jalr	1672(ra) # 5678 <link>
     ff8:	84aa                	mv	s1,a0
     ffa:	e949                	bnez	a0,108c <bigdir+0x128>
  for(i = 0; i < N; i++){
     ffc:	2905                	addiw	s2,s2,1
     ffe:	fb691fe3          	bne	s2,s6,fbc <bigdir+0x58>
  unlink("bd");
    1002:	00005517          	auipc	a0,0x5
    1006:	55650513          	addi	a0,a0,1366 # 6558 <malloc+0xb02>
    100a:	00004097          	auipc	ra,0x4
    100e:	65e080e7          	jalr	1630(ra) # 5668 <unlink>
    name[0] = 'x';
    1012:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1016:	1f400a13          	li	s4,500
    name[0] = 'x';
    101a:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    101e:	41f4d79b          	sraiw	a5,s1,0x1f
    1022:	01a7d71b          	srliw	a4,a5,0x1a
    1026:	009707bb          	addw	a5,a4,s1
    102a:	4067d69b          	sraiw	a3,a5,0x6
    102e:	0306869b          	addiw	a3,a3,48
    1032:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1036:	03f7f793          	andi	a5,a5,63
    103a:	9f99                	subw	a5,a5,a4
    103c:	0307879b          	addiw	a5,a5,48
    1040:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1044:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1048:	fb040513          	addi	a0,s0,-80
    104c:	00004097          	auipc	ra,0x4
    1050:	61c080e7          	jalr	1564(ra) # 5668 <unlink>
    1054:	ed21                	bnez	a0,10ac <bigdir+0x148>
  for(i = 0; i < N; i++){
    1056:	2485                	addiw	s1,s1,1
    1058:	fd4491e3          	bne	s1,s4,101a <bigdir+0xb6>
}
    105c:	60a6                	ld	ra,72(sp)
    105e:	6406                	ld	s0,64(sp)
    1060:	74e2                	ld	s1,56(sp)
    1062:	7942                	ld	s2,48(sp)
    1064:	79a2                	ld	s3,40(sp)
    1066:	7a02                	ld	s4,32(sp)
    1068:	6ae2                	ld	s5,24(sp)
    106a:	6b42                	ld	s6,16(sp)
    106c:	6161                	addi	sp,sp,80
    106e:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1070:	85ce                	mv	a1,s3
    1072:	00005517          	auipc	a0,0x5
    1076:	4ee50513          	addi	a0,a0,1262 # 6560 <malloc+0xb0a>
    107a:	00005097          	auipc	ra,0x5
    107e:	91e080e7          	jalr	-1762(ra) # 5998 <printf>
    exit(1);
    1082:	4505                	li	a0,1
    1084:	00004097          	auipc	ra,0x4
    1088:	594080e7          	jalr	1428(ra) # 5618 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    108c:	fb040613          	addi	a2,s0,-80
    1090:	85ce                	mv	a1,s3
    1092:	00005517          	auipc	a0,0x5
    1096:	4ee50513          	addi	a0,a0,1262 # 6580 <malloc+0xb2a>
    109a:	00005097          	auipc	ra,0x5
    109e:	8fe080e7          	jalr	-1794(ra) # 5998 <printf>
      exit(1);
    10a2:	4505                	li	a0,1
    10a4:	00004097          	auipc	ra,0x4
    10a8:	574080e7          	jalr	1396(ra) # 5618 <exit>
      printf("%s: bigdir unlink failed", s);
    10ac:	85ce                	mv	a1,s3
    10ae:	00005517          	auipc	a0,0x5
    10b2:	4f250513          	addi	a0,a0,1266 # 65a0 <malloc+0xb4a>
    10b6:	00005097          	auipc	ra,0x5
    10ba:	8e2080e7          	jalr	-1822(ra) # 5998 <printf>
      exit(1);
    10be:	4505                	li	a0,1
    10c0:	00004097          	auipc	ra,0x4
    10c4:	558080e7          	jalr	1368(ra) # 5618 <exit>

00000000000010c8 <validatetest>:
{
    10c8:	7139                	addi	sp,sp,-64
    10ca:	fc06                	sd	ra,56(sp)
    10cc:	f822                	sd	s0,48(sp)
    10ce:	f426                	sd	s1,40(sp)
    10d0:	f04a                	sd	s2,32(sp)
    10d2:	ec4e                	sd	s3,24(sp)
    10d4:	e852                	sd	s4,16(sp)
    10d6:	e456                	sd	s5,8(sp)
    10d8:	e05a                	sd	s6,0(sp)
    10da:	0080                	addi	s0,sp,64
    10dc:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10de:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10e0:	00005997          	auipc	s3,0x5
    10e4:	4e098993          	addi	s3,s3,1248 # 65c0 <malloc+0xb6a>
    10e8:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10ea:	6a85                	lui	s5,0x1
    10ec:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    10f0:	85a6                	mv	a1,s1
    10f2:	854e                	mv	a0,s3
    10f4:	00004097          	auipc	ra,0x4
    10f8:	584080e7          	jalr	1412(ra) # 5678 <link>
    10fc:	01251f63          	bne	a0,s2,111a <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1100:	94d6                	add	s1,s1,s5
    1102:	ff4497e3          	bne	s1,s4,10f0 <validatetest+0x28>
}
    1106:	70e2                	ld	ra,56(sp)
    1108:	7442                	ld	s0,48(sp)
    110a:	74a2                	ld	s1,40(sp)
    110c:	7902                	ld	s2,32(sp)
    110e:	69e2                	ld	s3,24(sp)
    1110:	6a42                	ld	s4,16(sp)
    1112:	6aa2                	ld	s5,8(sp)
    1114:	6b02                	ld	s6,0(sp)
    1116:	6121                	addi	sp,sp,64
    1118:	8082                	ret
      printf("%s: link should not succeed\n", s);
    111a:	85da                	mv	a1,s6
    111c:	00005517          	auipc	a0,0x5
    1120:	4b450513          	addi	a0,a0,1204 # 65d0 <malloc+0xb7a>
    1124:	00005097          	auipc	ra,0x5
    1128:	874080e7          	jalr	-1932(ra) # 5998 <printf>
      exit(1);
    112c:	4505                	li	a0,1
    112e:	00004097          	auipc	ra,0x4
    1132:	4ea080e7          	jalr	1258(ra) # 5618 <exit>

0000000000001136 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1136:	7179                	addi	sp,sp,-48
    1138:	f406                	sd	ra,40(sp)
    113a:	f022                	sd	s0,32(sp)
    113c:	ec26                	sd	s1,24(sp)
    113e:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1140:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1144:	00007497          	auipc	s1,0x7
    1148:	13c4b483          	ld	s1,316(s1) # 8280 <__SDATA_BEGIN__>
    114c:	fd840593          	addi	a1,s0,-40
    1150:	8526                	mv	a0,s1
    1152:	00004097          	auipc	ra,0x4
    1156:	4fe080e7          	jalr	1278(ra) # 5650 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    115a:	8526                	mv	a0,s1
    115c:	00004097          	auipc	ra,0x4
    1160:	4cc080e7          	jalr	1228(ra) # 5628 <pipe>

  exit(0);
    1164:	4501                	li	a0,0
    1166:	00004097          	auipc	ra,0x4
    116a:	4b2080e7          	jalr	1202(ra) # 5618 <exit>

000000000000116e <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    116e:	7139                	addi	sp,sp,-64
    1170:	fc06                	sd	ra,56(sp)
    1172:	f822                	sd	s0,48(sp)
    1174:	f426                	sd	s1,40(sp)
    1176:	f04a                	sd	s2,32(sp)
    1178:	ec4e                	sd	s3,24(sp)
    117a:	0080                	addi	s0,sp,64
    117c:	64b1                	lui	s1,0xc
    117e:	35048493          	addi	s1,s1,848 # c350 <buf+0x8a0>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1182:	597d                	li	s2,-1
    1184:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1188:	00005997          	auipc	s3,0x5
    118c:	d1098993          	addi	s3,s3,-752 # 5e98 <malloc+0x442>
    argv[0] = (char*)0xffffffff;
    1190:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1194:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1198:	fc040593          	addi	a1,s0,-64
    119c:	854e                	mv	a0,s3
    119e:	00004097          	auipc	ra,0x4
    11a2:	4b2080e7          	jalr	1202(ra) # 5650 <exec>
  for(int i = 0; i < 50000; i++){
    11a6:	34fd                	addiw	s1,s1,-1
    11a8:	f4e5                	bnez	s1,1190 <badarg+0x22>
  }
  
  exit(0);
    11aa:	4501                	li	a0,0
    11ac:	00004097          	auipc	ra,0x4
    11b0:	46c080e7          	jalr	1132(ra) # 5618 <exit>

00000000000011b4 <copyinstr2>:
{
    11b4:	7155                	addi	sp,sp,-208
    11b6:	e586                	sd	ra,200(sp)
    11b8:	e1a2                	sd	s0,192(sp)
    11ba:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11bc:	f6840793          	addi	a5,s0,-152
    11c0:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11c4:	07800713          	li	a4,120
    11c8:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11cc:	0785                	addi	a5,a5,1
    11ce:	fed79de3          	bne	a5,a3,11c8 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11d2:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11d6:	f6840513          	addi	a0,s0,-152
    11da:	00004097          	auipc	ra,0x4
    11de:	48e080e7          	jalr	1166(ra) # 5668 <unlink>
  if(ret != -1){
    11e2:	57fd                	li	a5,-1
    11e4:	0ef51063          	bne	a0,a5,12c4 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11e8:	20100593          	li	a1,513
    11ec:	f6840513          	addi	a0,s0,-152
    11f0:	00004097          	auipc	ra,0x4
    11f4:	468080e7          	jalr	1128(ra) # 5658 <open>
  if(fd != -1){
    11f8:	57fd                	li	a5,-1
    11fa:	0ef51563          	bne	a0,a5,12e4 <copyinstr2+0x130>
  ret = link(b, b);
    11fe:	f6840593          	addi	a1,s0,-152
    1202:	852e                	mv	a0,a1
    1204:	00004097          	auipc	ra,0x4
    1208:	474080e7          	jalr	1140(ra) # 5678 <link>
  if(ret != -1){
    120c:	57fd                	li	a5,-1
    120e:	0ef51b63          	bne	a0,a5,1304 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1212:	00006797          	auipc	a5,0x6
    1216:	58e78793          	addi	a5,a5,1422 # 77a0 <malloc+0x1d4a>
    121a:	f4f43c23          	sd	a5,-168(s0)
    121e:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1222:	f5840593          	addi	a1,s0,-168
    1226:	f6840513          	addi	a0,s0,-152
    122a:	00004097          	auipc	ra,0x4
    122e:	426080e7          	jalr	1062(ra) # 5650 <exec>
  if(ret != -1){
    1232:	57fd                	li	a5,-1
    1234:	0ef51963          	bne	a0,a5,1326 <copyinstr2+0x172>
  int pid = fork();
    1238:	00004097          	auipc	ra,0x4
    123c:	3d8080e7          	jalr	984(ra) # 5610 <fork>
  if(pid < 0){
    1240:	10054363          	bltz	a0,1346 <copyinstr2+0x192>
  if(pid == 0){
    1244:	12051463          	bnez	a0,136c <copyinstr2+0x1b8>
    1248:	00007797          	auipc	a5,0x7
    124c:	15078793          	addi	a5,a5,336 # 8398 <big.1267>
    1250:	00008697          	auipc	a3,0x8
    1254:	14868693          	addi	a3,a3,328 # 9398 <__global_pointer$+0x918>
      big[i] = 'x';
    1258:	07800713          	li	a4,120
    125c:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1260:	0785                	addi	a5,a5,1
    1262:	fed79de3          	bne	a5,a3,125c <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1266:	00008797          	auipc	a5,0x8
    126a:	12078923          	sb	zero,306(a5) # 9398 <__global_pointer$+0x918>
    char *args2[] = { big, big, big, 0 };
    126e:	00007797          	auipc	a5,0x7
    1272:	c2278793          	addi	a5,a5,-990 # 7e90 <malloc+0x243a>
    1276:	6390                	ld	a2,0(a5)
    1278:	6794                	ld	a3,8(a5)
    127a:	6b98                	ld	a4,16(a5)
    127c:	6f9c                	ld	a5,24(a5)
    127e:	f2c43823          	sd	a2,-208(s0)
    1282:	f2d43c23          	sd	a3,-200(s0)
    1286:	f4e43023          	sd	a4,-192(s0)
    128a:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    128e:	f3040593          	addi	a1,s0,-208
    1292:	00005517          	auipc	a0,0x5
    1296:	c0650513          	addi	a0,a0,-1018 # 5e98 <malloc+0x442>
    129a:	00004097          	auipc	ra,0x4
    129e:	3b6080e7          	jalr	950(ra) # 5650 <exec>
    if(ret != -1){
    12a2:	57fd                	li	a5,-1
    12a4:	0af50e63          	beq	a0,a5,1360 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12a8:	55fd                	li	a1,-1
    12aa:	00005517          	auipc	a0,0x5
    12ae:	3ce50513          	addi	a0,a0,974 # 6678 <malloc+0xc22>
    12b2:	00004097          	auipc	ra,0x4
    12b6:	6e6080e7          	jalr	1766(ra) # 5998 <printf>
      exit(1);
    12ba:	4505                	li	a0,1
    12bc:	00004097          	auipc	ra,0x4
    12c0:	35c080e7          	jalr	860(ra) # 5618 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12c4:	862a                	mv	a2,a0
    12c6:	f6840593          	addi	a1,s0,-152
    12ca:	00005517          	auipc	a0,0x5
    12ce:	32650513          	addi	a0,a0,806 # 65f0 <malloc+0xb9a>
    12d2:	00004097          	auipc	ra,0x4
    12d6:	6c6080e7          	jalr	1734(ra) # 5998 <printf>
    exit(1);
    12da:	4505                	li	a0,1
    12dc:	00004097          	auipc	ra,0x4
    12e0:	33c080e7          	jalr	828(ra) # 5618 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12e4:	862a                	mv	a2,a0
    12e6:	f6840593          	addi	a1,s0,-152
    12ea:	00005517          	auipc	a0,0x5
    12ee:	32650513          	addi	a0,a0,806 # 6610 <malloc+0xbba>
    12f2:	00004097          	auipc	ra,0x4
    12f6:	6a6080e7          	jalr	1702(ra) # 5998 <printf>
    exit(1);
    12fa:	4505                	li	a0,1
    12fc:	00004097          	auipc	ra,0x4
    1300:	31c080e7          	jalr	796(ra) # 5618 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1304:	86aa                	mv	a3,a0
    1306:	f6840613          	addi	a2,s0,-152
    130a:	85b2                	mv	a1,a2
    130c:	00005517          	auipc	a0,0x5
    1310:	32450513          	addi	a0,a0,804 # 6630 <malloc+0xbda>
    1314:	00004097          	auipc	ra,0x4
    1318:	684080e7          	jalr	1668(ra) # 5998 <printf>
    exit(1);
    131c:	4505                	li	a0,1
    131e:	00004097          	auipc	ra,0x4
    1322:	2fa080e7          	jalr	762(ra) # 5618 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1326:	567d                	li	a2,-1
    1328:	f6840593          	addi	a1,s0,-152
    132c:	00005517          	auipc	a0,0x5
    1330:	32c50513          	addi	a0,a0,812 # 6658 <malloc+0xc02>
    1334:	00004097          	auipc	ra,0x4
    1338:	664080e7          	jalr	1636(ra) # 5998 <printf>
    exit(1);
    133c:	4505                	li	a0,1
    133e:	00004097          	auipc	ra,0x4
    1342:	2da080e7          	jalr	730(ra) # 5618 <exit>
    printf("fork failed\n");
    1346:	00005517          	auipc	a0,0x5
    134a:	79250513          	addi	a0,a0,1938 # 6ad8 <malloc+0x1082>
    134e:	00004097          	auipc	ra,0x4
    1352:	64a080e7          	jalr	1610(ra) # 5998 <printf>
    exit(1);
    1356:	4505                	li	a0,1
    1358:	00004097          	auipc	ra,0x4
    135c:	2c0080e7          	jalr	704(ra) # 5618 <exit>
    exit(747); // OK
    1360:	2eb00513          	li	a0,747
    1364:	00004097          	auipc	ra,0x4
    1368:	2b4080e7          	jalr	692(ra) # 5618 <exit>
  int st = 0;
    136c:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1370:	f5440513          	addi	a0,s0,-172
    1374:	00004097          	auipc	ra,0x4
    1378:	2ac080e7          	jalr	684(ra) # 5620 <wait>
  if(st != 747){
    137c:	f5442703          	lw	a4,-172(s0)
    1380:	2eb00793          	li	a5,747
    1384:	00f71663          	bne	a4,a5,1390 <copyinstr2+0x1dc>
}
    1388:	60ae                	ld	ra,200(sp)
    138a:	640e                	ld	s0,192(sp)
    138c:	6169                	addi	sp,sp,208
    138e:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    1390:	00005517          	auipc	a0,0x5
    1394:	31050513          	addi	a0,a0,784 # 66a0 <malloc+0xc4a>
    1398:	00004097          	auipc	ra,0x4
    139c:	600080e7          	jalr	1536(ra) # 5998 <printf>
    exit(1);
    13a0:	4505                	li	a0,1
    13a2:	00004097          	auipc	ra,0x4
    13a6:	276080e7          	jalr	630(ra) # 5618 <exit>

00000000000013aa <truncate3>:
{
    13aa:	7159                	addi	sp,sp,-112
    13ac:	f486                	sd	ra,104(sp)
    13ae:	f0a2                	sd	s0,96(sp)
    13b0:	eca6                	sd	s1,88(sp)
    13b2:	e8ca                	sd	s2,80(sp)
    13b4:	e4ce                	sd	s3,72(sp)
    13b6:	e0d2                	sd	s4,64(sp)
    13b8:	fc56                	sd	s5,56(sp)
    13ba:	1880                	addi	s0,sp,112
    13bc:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13be:	60100593          	li	a1,1537
    13c2:	00005517          	auipc	a0,0x5
    13c6:	b2e50513          	addi	a0,a0,-1234 # 5ef0 <malloc+0x49a>
    13ca:	00004097          	auipc	ra,0x4
    13ce:	28e080e7          	jalr	654(ra) # 5658 <open>
    13d2:	00004097          	auipc	ra,0x4
    13d6:	26e080e7          	jalr	622(ra) # 5640 <close>
  pid = fork();
    13da:	00004097          	auipc	ra,0x4
    13de:	236080e7          	jalr	566(ra) # 5610 <fork>
  if(pid < 0){
    13e2:	08054063          	bltz	a0,1462 <truncate3+0xb8>
  if(pid == 0){
    13e6:	e969                	bnez	a0,14b8 <truncate3+0x10e>
    13e8:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13ec:	00005a17          	auipc	s4,0x5
    13f0:	b04a0a13          	addi	s4,s4,-1276 # 5ef0 <malloc+0x49a>
      int n = write(fd, "1234567890", 10);
    13f4:	00005a97          	auipc	s5,0x5
    13f8:	30ca8a93          	addi	s5,s5,780 # 6700 <malloc+0xcaa>
      int fd = open("truncfile", O_WRONLY);
    13fc:	4585                	li	a1,1
    13fe:	8552                	mv	a0,s4
    1400:	00004097          	auipc	ra,0x4
    1404:	258080e7          	jalr	600(ra) # 5658 <open>
    1408:	84aa                	mv	s1,a0
      if(fd < 0){
    140a:	06054a63          	bltz	a0,147e <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    140e:	4629                	li	a2,10
    1410:	85d6                	mv	a1,s5
    1412:	00004097          	auipc	ra,0x4
    1416:	226080e7          	jalr	550(ra) # 5638 <write>
      if(n != 10){
    141a:	47a9                	li	a5,10
    141c:	06f51f63          	bne	a0,a5,149a <truncate3+0xf0>
      close(fd);
    1420:	8526                	mv	a0,s1
    1422:	00004097          	auipc	ra,0x4
    1426:	21e080e7          	jalr	542(ra) # 5640 <close>
      fd = open("truncfile", O_RDONLY);
    142a:	4581                	li	a1,0
    142c:	8552                	mv	a0,s4
    142e:	00004097          	auipc	ra,0x4
    1432:	22a080e7          	jalr	554(ra) # 5658 <open>
    1436:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1438:	02000613          	li	a2,32
    143c:	f9840593          	addi	a1,s0,-104
    1440:	00004097          	auipc	ra,0x4
    1444:	1f0080e7          	jalr	496(ra) # 5630 <read>
      close(fd);
    1448:	8526                	mv	a0,s1
    144a:	00004097          	auipc	ra,0x4
    144e:	1f6080e7          	jalr	502(ra) # 5640 <close>
    for(int i = 0; i < 100; i++){
    1452:	39fd                	addiw	s3,s3,-1
    1454:	fa0994e3          	bnez	s3,13fc <truncate3+0x52>
    exit(0);
    1458:	4501                	li	a0,0
    145a:	00004097          	auipc	ra,0x4
    145e:	1be080e7          	jalr	446(ra) # 5618 <exit>
    printf("%s: fork failed\n", s);
    1462:	85ca                	mv	a1,s2
    1464:	00005517          	auipc	a0,0x5
    1468:	26c50513          	addi	a0,a0,620 # 66d0 <malloc+0xc7a>
    146c:	00004097          	auipc	ra,0x4
    1470:	52c080e7          	jalr	1324(ra) # 5998 <printf>
    exit(1);
    1474:	4505                	li	a0,1
    1476:	00004097          	auipc	ra,0x4
    147a:	1a2080e7          	jalr	418(ra) # 5618 <exit>
        printf("%s: open failed\n", s);
    147e:	85ca                	mv	a1,s2
    1480:	00005517          	auipc	a0,0x5
    1484:	26850513          	addi	a0,a0,616 # 66e8 <malloc+0xc92>
    1488:	00004097          	auipc	ra,0x4
    148c:	510080e7          	jalr	1296(ra) # 5998 <printf>
        exit(1);
    1490:	4505                	li	a0,1
    1492:	00004097          	auipc	ra,0x4
    1496:	186080e7          	jalr	390(ra) # 5618 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    149a:	862a                	mv	a2,a0
    149c:	85ca                	mv	a1,s2
    149e:	00005517          	auipc	a0,0x5
    14a2:	27250513          	addi	a0,a0,626 # 6710 <malloc+0xcba>
    14a6:	00004097          	auipc	ra,0x4
    14aa:	4f2080e7          	jalr	1266(ra) # 5998 <printf>
        exit(1);
    14ae:	4505                	li	a0,1
    14b0:	00004097          	auipc	ra,0x4
    14b4:	168080e7          	jalr	360(ra) # 5618 <exit>
    14b8:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14bc:	00005a17          	auipc	s4,0x5
    14c0:	a34a0a13          	addi	s4,s4,-1484 # 5ef0 <malloc+0x49a>
    int n = write(fd, "xxx", 3);
    14c4:	00005a97          	auipc	s5,0x5
    14c8:	26ca8a93          	addi	s5,s5,620 # 6730 <malloc+0xcda>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14cc:	60100593          	li	a1,1537
    14d0:	8552                	mv	a0,s4
    14d2:	00004097          	auipc	ra,0x4
    14d6:	186080e7          	jalr	390(ra) # 5658 <open>
    14da:	84aa                	mv	s1,a0
    if(fd < 0){
    14dc:	04054763          	bltz	a0,152a <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14e0:	460d                	li	a2,3
    14e2:	85d6                	mv	a1,s5
    14e4:	00004097          	auipc	ra,0x4
    14e8:	154080e7          	jalr	340(ra) # 5638 <write>
    if(n != 3){
    14ec:	478d                	li	a5,3
    14ee:	04f51c63          	bne	a0,a5,1546 <truncate3+0x19c>
    close(fd);
    14f2:	8526                	mv	a0,s1
    14f4:	00004097          	auipc	ra,0x4
    14f8:	14c080e7          	jalr	332(ra) # 5640 <close>
  for(int i = 0; i < 150; i++){
    14fc:	39fd                	addiw	s3,s3,-1
    14fe:	fc0997e3          	bnez	s3,14cc <truncate3+0x122>
  wait(&xstatus);
    1502:	fbc40513          	addi	a0,s0,-68
    1506:	00004097          	auipc	ra,0x4
    150a:	11a080e7          	jalr	282(ra) # 5620 <wait>
  unlink("truncfile");
    150e:	00005517          	auipc	a0,0x5
    1512:	9e250513          	addi	a0,a0,-1566 # 5ef0 <malloc+0x49a>
    1516:	00004097          	auipc	ra,0x4
    151a:	152080e7          	jalr	338(ra) # 5668 <unlink>
  exit(xstatus);
    151e:	fbc42503          	lw	a0,-68(s0)
    1522:	00004097          	auipc	ra,0x4
    1526:	0f6080e7          	jalr	246(ra) # 5618 <exit>
      printf("%s: open failed\n", s);
    152a:	85ca                	mv	a1,s2
    152c:	00005517          	auipc	a0,0x5
    1530:	1bc50513          	addi	a0,a0,444 # 66e8 <malloc+0xc92>
    1534:	00004097          	auipc	ra,0x4
    1538:	464080e7          	jalr	1124(ra) # 5998 <printf>
      exit(1);
    153c:	4505                	li	a0,1
    153e:	00004097          	auipc	ra,0x4
    1542:	0da080e7          	jalr	218(ra) # 5618 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1546:	862a                	mv	a2,a0
    1548:	85ca                	mv	a1,s2
    154a:	00005517          	auipc	a0,0x5
    154e:	1ee50513          	addi	a0,a0,494 # 6738 <malloc+0xce2>
    1552:	00004097          	auipc	ra,0x4
    1556:	446080e7          	jalr	1094(ra) # 5998 <printf>
      exit(1);
    155a:	4505                	li	a0,1
    155c:	00004097          	auipc	ra,0x4
    1560:	0bc080e7          	jalr	188(ra) # 5618 <exit>

0000000000001564 <exectest>:
{
    1564:	715d                	addi	sp,sp,-80
    1566:	e486                	sd	ra,72(sp)
    1568:	e0a2                	sd	s0,64(sp)
    156a:	fc26                	sd	s1,56(sp)
    156c:	f84a                	sd	s2,48(sp)
    156e:	0880                	addi	s0,sp,80
    1570:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1572:	00005797          	auipc	a5,0x5
    1576:	92678793          	addi	a5,a5,-1754 # 5e98 <malloc+0x442>
    157a:	fcf43023          	sd	a5,-64(s0)
    157e:	00005797          	auipc	a5,0x5
    1582:	1da78793          	addi	a5,a5,474 # 6758 <malloc+0xd02>
    1586:	fcf43423          	sd	a5,-56(s0)
    158a:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    158e:	00005517          	auipc	a0,0x5
    1592:	1d250513          	addi	a0,a0,466 # 6760 <malloc+0xd0a>
    1596:	00004097          	auipc	ra,0x4
    159a:	0d2080e7          	jalr	210(ra) # 5668 <unlink>
  pid = fork();
    159e:	00004097          	auipc	ra,0x4
    15a2:	072080e7          	jalr	114(ra) # 5610 <fork>
  if(pid < 0) {
    15a6:	04054663          	bltz	a0,15f2 <exectest+0x8e>
    15aa:	84aa                	mv	s1,a0
  if(pid == 0) {
    15ac:	e959                	bnez	a0,1642 <exectest+0xde>
    close(1);
    15ae:	4505                	li	a0,1
    15b0:	00004097          	auipc	ra,0x4
    15b4:	090080e7          	jalr	144(ra) # 5640 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15b8:	20100593          	li	a1,513
    15bc:	00005517          	auipc	a0,0x5
    15c0:	1a450513          	addi	a0,a0,420 # 6760 <malloc+0xd0a>
    15c4:	00004097          	auipc	ra,0x4
    15c8:	094080e7          	jalr	148(ra) # 5658 <open>
    if(fd < 0) {
    15cc:	04054163          	bltz	a0,160e <exectest+0xaa>
    if(fd != 1) {
    15d0:	4785                	li	a5,1
    15d2:	04f50c63          	beq	a0,a5,162a <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15d6:	85ca                	mv	a1,s2
    15d8:	00005517          	auipc	a0,0x5
    15dc:	1a850513          	addi	a0,a0,424 # 6780 <malloc+0xd2a>
    15e0:	00004097          	auipc	ra,0x4
    15e4:	3b8080e7          	jalr	952(ra) # 5998 <printf>
      exit(1);
    15e8:	4505                	li	a0,1
    15ea:	00004097          	auipc	ra,0x4
    15ee:	02e080e7          	jalr	46(ra) # 5618 <exit>
     printf("%s: fork failed\n", s);
    15f2:	85ca                	mv	a1,s2
    15f4:	00005517          	auipc	a0,0x5
    15f8:	0dc50513          	addi	a0,a0,220 # 66d0 <malloc+0xc7a>
    15fc:	00004097          	auipc	ra,0x4
    1600:	39c080e7          	jalr	924(ra) # 5998 <printf>
     exit(1);
    1604:	4505                	li	a0,1
    1606:	00004097          	auipc	ra,0x4
    160a:	012080e7          	jalr	18(ra) # 5618 <exit>
      printf("%s: create failed\n", s);
    160e:	85ca                	mv	a1,s2
    1610:	00005517          	auipc	a0,0x5
    1614:	15850513          	addi	a0,a0,344 # 6768 <malloc+0xd12>
    1618:	00004097          	auipc	ra,0x4
    161c:	380080e7          	jalr	896(ra) # 5998 <printf>
      exit(1);
    1620:	4505                	li	a0,1
    1622:	00004097          	auipc	ra,0x4
    1626:	ff6080e7          	jalr	-10(ra) # 5618 <exit>
    if(exec("echo", echoargv) < 0){
    162a:	fc040593          	addi	a1,s0,-64
    162e:	00005517          	auipc	a0,0x5
    1632:	86a50513          	addi	a0,a0,-1942 # 5e98 <malloc+0x442>
    1636:	00004097          	auipc	ra,0x4
    163a:	01a080e7          	jalr	26(ra) # 5650 <exec>
    163e:	02054163          	bltz	a0,1660 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1642:	fdc40513          	addi	a0,s0,-36
    1646:	00004097          	auipc	ra,0x4
    164a:	fda080e7          	jalr	-38(ra) # 5620 <wait>
    164e:	02951763          	bne	a0,s1,167c <exectest+0x118>
  if(xstatus != 0)
    1652:	fdc42503          	lw	a0,-36(s0)
    1656:	cd0d                	beqz	a0,1690 <exectest+0x12c>
    exit(xstatus);
    1658:	00004097          	auipc	ra,0x4
    165c:	fc0080e7          	jalr	-64(ra) # 5618 <exit>
      printf("%s: exec echo failed\n", s);
    1660:	85ca                	mv	a1,s2
    1662:	00005517          	auipc	a0,0x5
    1666:	12e50513          	addi	a0,a0,302 # 6790 <malloc+0xd3a>
    166a:	00004097          	auipc	ra,0x4
    166e:	32e080e7          	jalr	814(ra) # 5998 <printf>
      exit(1);
    1672:	4505                	li	a0,1
    1674:	00004097          	auipc	ra,0x4
    1678:	fa4080e7          	jalr	-92(ra) # 5618 <exit>
    printf("%s: wait failed!\n", s);
    167c:	85ca                	mv	a1,s2
    167e:	00005517          	auipc	a0,0x5
    1682:	12a50513          	addi	a0,a0,298 # 67a8 <malloc+0xd52>
    1686:	00004097          	auipc	ra,0x4
    168a:	312080e7          	jalr	786(ra) # 5998 <printf>
    168e:	b7d1                	j	1652 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    1690:	4581                	li	a1,0
    1692:	00005517          	auipc	a0,0x5
    1696:	0ce50513          	addi	a0,a0,206 # 6760 <malloc+0xd0a>
    169a:	00004097          	auipc	ra,0x4
    169e:	fbe080e7          	jalr	-66(ra) # 5658 <open>
  if(fd < 0) {
    16a2:	02054a63          	bltz	a0,16d6 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16a6:	4609                	li	a2,2
    16a8:	fb840593          	addi	a1,s0,-72
    16ac:	00004097          	auipc	ra,0x4
    16b0:	f84080e7          	jalr	-124(ra) # 5630 <read>
    16b4:	4789                	li	a5,2
    16b6:	02f50e63          	beq	a0,a5,16f2 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16ba:	85ca                	mv	a1,s2
    16bc:	00005517          	auipc	a0,0x5
    16c0:	b6c50513          	addi	a0,a0,-1172 # 6228 <malloc+0x7d2>
    16c4:	00004097          	auipc	ra,0x4
    16c8:	2d4080e7          	jalr	724(ra) # 5998 <printf>
    exit(1);
    16cc:	4505                	li	a0,1
    16ce:	00004097          	auipc	ra,0x4
    16d2:	f4a080e7          	jalr	-182(ra) # 5618 <exit>
    printf("%s: open failed\n", s);
    16d6:	85ca                	mv	a1,s2
    16d8:	00005517          	auipc	a0,0x5
    16dc:	01050513          	addi	a0,a0,16 # 66e8 <malloc+0xc92>
    16e0:	00004097          	auipc	ra,0x4
    16e4:	2b8080e7          	jalr	696(ra) # 5998 <printf>
    exit(1);
    16e8:	4505                	li	a0,1
    16ea:	00004097          	auipc	ra,0x4
    16ee:	f2e080e7          	jalr	-210(ra) # 5618 <exit>
  unlink("echo-ok");
    16f2:	00005517          	auipc	a0,0x5
    16f6:	06e50513          	addi	a0,a0,110 # 6760 <malloc+0xd0a>
    16fa:	00004097          	auipc	ra,0x4
    16fe:	f6e080e7          	jalr	-146(ra) # 5668 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1702:	fb844703          	lbu	a4,-72(s0)
    1706:	04f00793          	li	a5,79
    170a:	00f71863          	bne	a4,a5,171a <exectest+0x1b6>
    170e:	fb944703          	lbu	a4,-71(s0)
    1712:	04b00793          	li	a5,75
    1716:	02f70063          	beq	a4,a5,1736 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    171a:	85ca                	mv	a1,s2
    171c:	00005517          	auipc	a0,0x5
    1720:	0a450513          	addi	a0,a0,164 # 67c0 <malloc+0xd6a>
    1724:	00004097          	auipc	ra,0x4
    1728:	274080e7          	jalr	628(ra) # 5998 <printf>
    exit(1);
    172c:	4505                	li	a0,1
    172e:	00004097          	auipc	ra,0x4
    1732:	eea080e7          	jalr	-278(ra) # 5618 <exit>
    exit(0);
    1736:	4501                	li	a0,0
    1738:	00004097          	auipc	ra,0x4
    173c:	ee0080e7          	jalr	-288(ra) # 5618 <exit>

0000000000001740 <pipe1>:
{
    1740:	711d                	addi	sp,sp,-96
    1742:	ec86                	sd	ra,88(sp)
    1744:	e8a2                	sd	s0,80(sp)
    1746:	e4a6                	sd	s1,72(sp)
    1748:	e0ca                	sd	s2,64(sp)
    174a:	fc4e                	sd	s3,56(sp)
    174c:	f852                	sd	s4,48(sp)
    174e:	f456                	sd	s5,40(sp)
    1750:	f05a                	sd	s6,32(sp)
    1752:	ec5e                	sd	s7,24(sp)
    1754:	1080                	addi	s0,sp,96
    1756:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1758:	fa840513          	addi	a0,s0,-88
    175c:	00004097          	auipc	ra,0x4
    1760:	ecc080e7          	jalr	-308(ra) # 5628 <pipe>
    1764:	ed25                	bnez	a0,17dc <pipe1+0x9c>
    1766:	84aa                	mv	s1,a0
  pid = fork();
    1768:	00004097          	auipc	ra,0x4
    176c:	ea8080e7          	jalr	-344(ra) # 5610 <fork>
    1770:	8a2a                	mv	s4,a0
  if(pid == 0){
    1772:	c159                	beqz	a0,17f8 <pipe1+0xb8>
  } else if(pid > 0){
    1774:	16a05e63          	blez	a0,18f0 <pipe1+0x1b0>
    close(fds[1]);
    1778:	fac42503          	lw	a0,-84(s0)
    177c:	00004097          	auipc	ra,0x4
    1780:	ec4080e7          	jalr	-316(ra) # 5640 <close>
    total = 0;
    1784:	8a26                	mv	s4,s1
    cc = 1;
    1786:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1788:	0000aa97          	auipc	s5,0xa
    178c:	328a8a93          	addi	s5,s5,808 # bab0 <buf>
      if(cc > sizeof(buf))
    1790:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1792:	864e                	mv	a2,s3
    1794:	85d6                	mv	a1,s5
    1796:	fa842503          	lw	a0,-88(s0)
    179a:	00004097          	auipc	ra,0x4
    179e:	e96080e7          	jalr	-362(ra) # 5630 <read>
    17a2:	10a05263          	blez	a0,18a6 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17a6:	0000a717          	auipc	a4,0xa
    17aa:	30a70713          	addi	a4,a4,778 # bab0 <buf>
    17ae:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b2:	00074683          	lbu	a3,0(a4)
    17b6:	0ff4f793          	andi	a5,s1,255
    17ba:	2485                	addiw	s1,s1,1
    17bc:	0cf69163          	bne	a3,a5,187e <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17c0:	0705                	addi	a4,a4,1
    17c2:	fec498e3          	bne	s1,a2,17b2 <pipe1+0x72>
      total += n;
    17c6:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17ca:	0019979b          	slliw	a5,s3,0x1
    17ce:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17d2:	013b7363          	bgeu	s6,s3,17d8 <pipe1+0x98>
        cc = sizeof(buf);
    17d6:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17d8:	84b2                	mv	s1,a2
    17da:	bf65                	j	1792 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17dc:	85ca                	mv	a1,s2
    17de:	00005517          	auipc	a0,0x5
    17e2:	ffa50513          	addi	a0,a0,-6 # 67d8 <malloc+0xd82>
    17e6:	00004097          	auipc	ra,0x4
    17ea:	1b2080e7          	jalr	434(ra) # 5998 <printf>
    exit(1);
    17ee:	4505                	li	a0,1
    17f0:	00004097          	auipc	ra,0x4
    17f4:	e28080e7          	jalr	-472(ra) # 5618 <exit>
    close(fds[0]);
    17f8:	fa842503          	lw	a0,-88(s0)
    17fc:	00004097          	auipc	ra,0x4
    1800:	e44080e7          	jalr	-444(ra) # 5640 <close>
    for(n = 0; n < N; n++){
    1804:	0000ab17          	auipc	s6,0xa
    1808:	2acb0b13          	addi	s6,s6,684 # bab0 <buf>
    180c:	416004bb          	negw	s1,s6
    1810:	0ff4f493          	andi	s1,s1,255
    1814:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1818:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    181a:	6a85                	lui	s5,0x1
    181c:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x83>
{
    1820:	87da                	mv	a5,s6
        buf[i] = seq++;
    1822:	0097873b          	addw	a4,a5,s1
    1826:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    182a:	0785                	addi	a5,a5,1
    182c:	fef99be3          	bne	s3,a5,1822 <pipe1+0xe2>
    1830:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1834:	40900613          	li	a2,1033
    1838:	85de                	mv	a1,s7
    183a:	fac42503          	lw	a0,-84(s0)
    183e:	00004097          	auipc	ra,0x4
    1842:	dfa080e7          	jalr	-518(ra) # 5638 <write>
    1846:	40900793          	li	a5,1033
    184a:	00f51c63          	bne	a0,a5,1862 <pipe1+0x122>
    for(n = 0; n < N; n++){
    184e:	24a5                	addiw	s1,s1,9
    1850:	0ff4f493          	andi	s1,s1,255
    1854:	fd5a16e3          	bne	s4,s5,1820 <pipe1+0xe0>
    exit(0);
    1858:	4501                	li	a0,0
    185a:	00004097          	auipc	ra,0x4
    185e:	dbe080e7          	jalr	-578(ra) # 5618 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1862:	85ca                	mv	a1,s2
    1864:	00005517          	auipc	a0,0x5
    1868:	f8c50513          	addi	a0,a0,-116 # 67f0 <malloc+0xd9a>
    186c:	00004097          	auipc	ra,0x4
    1870:	12c080e7          	jalr	300(ra) # 5998 <printf>
        exit(1);
    1874:	4505                	li	a0,1
    1876:	00004097          	auipc	ra,0x4
    187a:	da2080e7          	jalr	-606(ra) # 5618 <exit>
          printf("%s: pipe1 oops 2\n", s);
    187e:	85ca                	mv	a1,s2
    1880:	00005517          	auipc	a0,0x5
    1884:	f8850513          	addi	a0,a0,-120 # 6808 <malloc+0xdb2>
    1888:	00004097          	auipc	ra,0x4
    188c:	110080e7          	jalr	272(ra) # 5998 <printf>
}
    1890:	60e6                	ld	ra,88(sp)
    1892:	6446                	ld	s0,80(sp)
    1894:	64a6                	ld	s1,72(sp)
    1896:	6906                	ld	s2,64(sp)
    1898:	79e2                	ld	s3,56(sp)
    189a:	7a42                	ld	s4,48(sp)
    189c:	7aa2                	ld	s5,40(sp)
    189e:	7b02                	ld	s6,32(sp)
    18a0:	6be2                	ld	s7,24(sp)
    18a2:	6125                	addi	sp,sp,96
    18a4:	8082                	ret
    if(total != N * SZ){
    18a6:	6785                	lui	a5,0x1
    18a8:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x83>
    18ac:	02fa0063          	beq	s4,a5,18cc <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18b0:	85d2                	mv	a1,s4
    18b2:	00005517          	auipc	a0,0x5
    18b6:	f6e50513          	addi	a0,a0,-146 # 6820 <malloc+0xdca>
    18ba:	00004097          	auipc	ra,0x4
    18be:	0de080e7          	jalr	222(ra) # 5998 <printf>
      exit(1);
    18c2:	4505                	li	a0,1
    18c4:	00004097          	auipc	ra,0x4
    18c8:	d54080e7          	jalr	-684(ra) # 5618 <exit>
    close(fds[0]);
    18cc:	fa842503          	lw	a0,-88(s0)
    18d0:	00004097          	auipc	ra,0x4
    18d4:	d70080e7          	jalr	-656(ra) # 5640 <close>
    wait(&xstatus);
    18d8:	fa440513          	addi	a0,s0,-92
    18dc:	00004097          	auipc	ra,0x4
    18e0:	d44080e7          	jalr	-700(ra) # 5620 <wait>
    exit(xstatus);
    18e4:	fa442503          	lw	a0,-92(s0)
    18e8:	00004097          	auipc	ra,0x4
    18ec:	d30080e7          	jalr	-720(ra) # 5618 <exit>
    printf("%s: fork() failed\n", s);
    18f0:	85ca                	mv	a1,s2
    18f2:	00005517          	auipc	a0,0x5
    18f6:	f4e50513          	addi	a0,a0,-178 # 6840 <malloc+0xdea>
    18fa:	00004097          	auipc	ra,0x4
    18fe:	09e080e7          	jalr	158(ra) # 5998 <printf>
    exit(1);
    1902:	4505                	li	a0,1
    1904:	00004097          	auipc	ra,0x4
    1908:	d14080e7          	jalr	-748(ra) # 5618 <exit>

000000000000190c <exitwait>:
{
    190c:	7139                	addi	sp,sp,-64
    190e:	fc06                	sd	ra,56(sp)
    1910:	f822                	sd	s0,48(sp)
    1912:	f426                	sd	s1,40(sp)
    1914:	f04a                	sd	s2,32(sp)
    1916:	ec4e                	sd	s3,24(sp)
    1918:	e852                	sd	s4,16(sp)
    191a:	0080                	addi	s0,sp,64
    191c:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    191e:	4901                	li	s2,0
    1920:	06400993          	li	s3,100
    pid = fork();
    1924:	00004097          	auipc	ra,0x4
    1928:	cec080e7          	jalr	-788(ra) # 5610 <fork>
    192c:	84aa                	mv	s1,a0
    if(pid < 0){
    192e:	02054a63          	bltz	a0,1962 <exitwait+0x56>
    if(pid){
    1932:	c151                	beqz	a0,19b6 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1934:	fcc40513          	addi	a0,s0,-52
    1938:	00004097          	auipc	ra,0x4
    193c:	ce8080e7          	jalr	-792(ra) # 5620 <wait>
    1940:	02951f63          	bne	a0,s1,197e <exitwait+0x72>
      if(i != xstate) {
    1944:	fcc42783          	lw	a5,-52(s0)
    1948:	05279963          	bne	a5,s2,199a <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    194c:	2905                	addiw	s2,s2,1
    194e:	fd391be3          	bne	s2,s3,1924 <exitwait+0x18>
}
    1952:	70e2                	ld	ra,56(sp)
    1954:	7442                	ld	s0,48(sp)
    1956:	74a2                	ld	s1,40(sp)
    1958:	7902                	ld	s2,32(sp)
    195a:	69e2                	ld	s3,24(sp)
    195c:	6a42                	ld	s4,16(sp)
    195e:	6121                	addi	sp,sp,64
    1960:	8082                	ret
      printf("%s: fork failed\n", s);
    1962:	85d2                	mv	a1,s4
    1964:	00005517          	auipc	a0,0x5
    1968:	d6c50513          	addi	a0,a0,-660 # 66d0 <malloc+0xc7a>
    196c:	00004097          	auipc	ra,0x4
    1970:	02c080e7          	jalr	44(ra) # 5998 <printf>
      exit(1);
    1974:	4505                	li	a0,1
    1976:	00004097          	auipc	ra,0x4
    197a:	ca2080e7          	jalr	-862(ra) # 5618 <exit>
        printf("%s: wait wrong pid\n", s);
    197e:	85d2                	mv	a1,s4
    1980:	00005517          	auipc	a0,0x5
    1984:	ed850513          	addi	a0,a0,-296 # 6858 <malloc+0xe02>
    1988:	00004097          	auipc	ra,0x4
    198c:	010080e7          	jalr	16(ra) # 5998 <printf>
        exit(1);
    1990:	4505                	li	a0,1
    1992:	00004097          	auipc	ra,0x4
    1996:	c86080e7          	jalr	-890(ra) # 5618 <exit>
        printf("%s: wait wrong exit status\n", s);
    199a:	85d2                	mv	a1,s4
    199c:	00005517          	auipc	a0,0x5
    19a0:	ed450513          	addi	a0,a0,-300 # 6870 <malloc+0xe1a>
    19a4:	00004097          	auipc	ra,0x4
    19a8:	ff4080e7          	jalr	-12(ra) # 5998 <printf>
        exit(1);
    19ac:	4505                	li	a0,1
    19ae:	00004097          	auipc	ra,0x4
    19b2:	c6a080e7          	jalr	-918(ra) # 5618 <exit>
      exit(i);
    19b6:	854a                	mv	a0,s2
    19b8:	00004097          	auipc	ra,0x4
    19bc:	c60080e7          	jalr	-928(ra) # 5618 <exit>

00000000000019c0 <twochildren>:
{
    19c0:	1101                	addi	sp,sp,-32
    19c2:	ec06                	sd	ra,24(sp)
    19c4:	e822                	sd	s0,16(sp)
    19c6:	e426                	sd	s1,8(sp)
    19c8:	e04a                	sd	s2,0(sp)
    19ca:	1000                	addi	s0,sp,32
    19cc:	892a                	mv	s2,a0
    19ce:	3e800493          	li	s1,1000
    int pid1 = fork();
    19d2:	00004097          	auipc	ra,0x4
    19d6:	c3e080e7          	jalr	-962(ra) # 5610 <fork>
    if(pid1 < 0){
    19da:	02054c63          	bltz	a0,1a12 <twochildren+0x52>
    if(pid1 == 0){
    19de:	c921                	beqz	a0,1a2e <twochildren+0x6e>
      int pid2 = fork();
    19e0:	00004097          	auipc	ra,0x4
    19e4:	c30080e7          	jalr	-976(ra) # 5610 <fork>
      if(pid2 < 0){
    19e8:	04054763          	bltz	a0,1a36 <twochildren+0x76>
      if(pid2 == 0){
    19ec:	c13d                	beqz	a0,1a52 <twochildren+0x92>
        wait(0);
    19ee:	4501                	li	a0,0
    19f0:	00004097          	auipc	ra,0x4
    19f4:	c30080e7          	jalr	-976(ra) # 5620 <wait>
        wait(0);
    19f8:	4501                	li	a0,0
    19fa:	00004097          	auipc	ra,0x4
    19fe:	c26080e7          	jalr	-986(ra) # 5620 <wait>
  for(int i = 0; i < 1000; i++){
    1a02:	34fd                	addiw	s1,s1,-1
    1a04:	f4f9                	bnez	s1,19d2 <twochildren+0x12>
}
    1a06:	60e2                	ld	ra,24(sp)
    1a08:	6442                	ld	s0,16(sp)
    1a0a:	64a2                	ld	s1,8(sp)
    1a0c:	6902                	ld	s2,0(sp)
    1a0e:	6105                	addi	sp,sp,32
    1a10:	8082                	ret
      printf("%s: fork failed\n", s);
    1a12:	85ca                	mv	a1,s2
    1a14:	00005517          	auipc	a0,0x5
    1a18:	cbc50513          	addi	a0,a0,-836 # 66d0 <malloc+0xc7a>
    1a1c:	00004097          	auipc	ra,0x4
    1a20:	f7c080e7          	jalr	-132(ra) # 5998 <printf>
      exit(1);
    1a24:	4505                	li	a0,1
    1a26:	00004097          	auipc	ra,0x4
    1a2a:	bf2080e7          	jalr	-1038(ra) # 5618 <exit>
      exit(0);
    1a2e:	00004097          	auipc	ra,0x4
    1a32:	bea080e7          	jalr	-1046(ra) # 5618 <exit>
        printf("%s: fork failed\n", s);
    1a36:	85ca                	mv	a1,s2
    1a38:	00005517          	auipc	a0,0x5
    1a3c:	c9850513          	addi	a0,a0,-872 # 66d0 <malloc+0xc7a>
    1a40:	00004097          	auipc	ra,0x4
    1a44:	f58080e7          	jalr	-168(ra) # 5998 <printf>
        exit(1);
    1a48:	4505                	li	a0,1
    1a4a:	00004097          	auipc	ra,0x4
    1a4e:	bce080e7          	jalr	-1074(ra) # 5618 <exit>
        exit(0);
    1a52:	00004097          	auipc	ra,0x4
    1a56:	bc6080e7          	jalr	-1082(ra) # 5618 <exit>

0000000000001a5a <forkfork>:
{
    1a5a:	7179                	addi	sp,sp,-48
    1a5c:	f406                	sd	ra,40(sp)
    1a5e:	f022                	sd	s0,32(sp)
    1a60:	ec26                	sd	s1,24(sp)
    1a62:	1800                	addi	s0,sp,48
    1a64:	84aa                	mv	s1,a0
    int pid = fork();
    1a66:	00004097          	auipc	ra,0x4
    1a6a:	baa080e7          	jalr	-1110(ra) # 5610 <fork>
    if(pid < 0){
    1a6e:	04054163          	bltz	a0,1ab0 <forkfork+0x56>
    if(pid == 0){
    1a72:	cd29                	beqz	a0,1acc <forkfork+0x72>
    int pid = fork();
    1a74:	00004097          	auipc	ra,0x4
    1a78:	b9c080e7          	jalr	-1124(ra) # 5610 <fork>
    if(pid < 0){
    1a7c:	02054a63          	bltz	a0,1ab0 <forkfork+0x56>
    if(pid == 0){
    1a80:	c531                	beqz	a0,1acc <forkfork+0x72>
    wait(&xstatus);
    1a82:	fdc40513          	addi	a0,s0,-36
    1a86:	00004097          	auipc	ra,0x4
    1a8a:	b9a080e7          	jalr	-1126(ra) # 5620 <wait>
    if(xstatus != 0) {
    1a8e:	fdc42783          	lw	a5,-36(s0)
    1a92:	ebbd                	bnez	a5,1b08 <forkfork+0xae>
    wait(&xstatus);
    1a94:	fdc40513          	addi	a0,s0,-36
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	b88080e7          	jalr	-1144(ra) # 5620 <wait>
    if(xstatus != 0) {
    1aa0:	fdc42783          	lw	a5,-36(s0)
    1aa4:	e3b5                	bnez	a5,1b08 <forkfork+0xae>
}
    1aa6:	70a2                	ld	ra,40(sp)
    1aa8:	7402                	ld	s0,32(sp)
    1aaa:	64e2                	ld	s1,24(sp)
    1aac:	6145                	addi	sp,sp,48
    1aae:	8082                	ret
      printf("%s: fork failed", s);
    1ab0:	85a6                	mv	a1,s1
    1ab2:	00005517          	auipc	a0,0x5
    1ab6:	dde50513          	addi	a0,a0,-546 # 6890 <malloc+0xe3a>
    1aba:	00004097          	auipc	ra,0x4
    1abe:	ede080e7          	jalr	-290(ra) # 5998 <printf>
      exit(1);
    1ac2:	4505                	li	a0,1
    1ac4:	00004097          	auipc	ra,0x4
    1ac8:	b54080e7          	jalr	-1196(ra) # 5618 <exit>
{
    1acc:	0c800493          	li	s1,200
        int pid1 = fork();
    1ad0:	00004097          	auipc	ra,0x4
    1ad4:	b40080e7          	jalr	-1216(ra) # 5610 <fork>
        if(pid1 < 0){
    1ad8:	00054f63          	bltz	a0,1af6 <forkfork+0x9c>
        if(pid1 == 0){
    1adc:	c115                	beqz	a0,1b00 <forkfork+0xa6>
        wait(0);
    1ade:	4501                	li	a0,0
    1ae0:	00004097          	auipc	ra,0x4
    1ae4:	b40080e7          	jalr	-1216(ra) # 5620 <wait>
      for(int j = 0; j < 200; j++){
    1ae8:	34fd                	addiw	s1,s1,-1
    1aea:	f0fd                	bnez	s1,1ad0 <forkfork+0x76>
      exit(0);
    1aec:	4501                	li	a0,0
    1aee:	00004097          	auipc	ra,0x4
    1af2:	b2a080e7          	jalr	-1238(ra) # 5618 <exit>
          exit(1);
    1af6:	4505                	li	a0,1
    1af8:	00004097          	auipc	ra,0x4
    1afc:	b20080e7          	jalr	-1248(ra) # 5618 <exit>
          exit(0);
    1b00:	00004097          	auipc	ra,0x4
    1b04:	b18080e7          	jalr	-1256(ra) # 5618 <exit>
      printf("%s: fork in child failed", s);
    1b08:	85a6                	mv	a1,s1
    1b0a:	00005517          	auipc	a0,0x5
    1b0e:	d9650513          	addi	a0,a0,-618 # 68a0 <malloc+0xe4a>
    1b12:	00004097          	auipc	ra,0x4
    1b16:	e86080e7          	jalr	-378(ra) # 5998 <printf>
      exit(1);
    1b1a:	4505                	li	a0,1
    1b1c:	00004097          	auipc	ra,0x4
    1b20:	afc080e7          	jalr	-1284(ra) # 5618 <exit>

0000000000001b24 <reparent2>:
{
    1b24:	1101                	addi	sp,sp,-32
    1b26:	ec06                	sd	ra,24(sp)
    1b28:	e822                	sd	s0,16(sp)
    1b2a:	e426                	sd	s1,8(sp)
    1b2c:	1000                	addi	s0,sp,32
    1b2e:	32000493          	li	s1,800
    int pid1 = fork();
    1b32:	00004097          	auipc	ra,0x4
    1b36:	ade080e7          	jalr	-1314(ra) # 5610 <fork>
    if(pid1 < 0){
    1b3a:	00054f63          	bltz	a0,1b58 <reparent2+0x34>
    if(pid1 == 0){
    1b3e:	c915                	beqz	a0,1b72 <reparent2+0x4e>
    wait(0);
    1b40:	4501                	li	a0,0
    1b42:	00004097          	auipc	ra,0x4
    1b46:	ade080e7          	jalr	-1314(ra) # 5620 <wait>
  for(int i = 0; i < 800; i++){
    1b4a:	34fd                	addiw	s1,s1,-1
    1b4c:	f0fd                	bnez	s1,1b32 <reparent2+0xe>
  exit(0);
    1b4e:	4501                	li	a0,0
    1b50:	00004097          	auipc	ra,0x4
    1b54:	ac8080e7          	jalr	-1336(ra) # 5618 <exit>
      printf("fork failed\n");
    1b58:	00005517          	auipc	a0,0x5
    1b5c:	f8050513          	addi	a0,a0,-128 # 6ad8 <malloc+0x1082>
    1b60:	00004097          	auipc	ra,0x4
    1b64:	e38080e7          	jalr	-456(ra) # 5998 <printf>
      exit(1);
    1b68:	4505                	li	a0,1
    1b6a:	00004097          	auipc	ra,0x4
    1b6e:	aae080e7          	jalr	-1362(ra) # 5618 <exit>
      fork();
    1b72:	00004097          	auipc	ra,0x4
    1b76:	a9e080e7          	jalr	-1378(ra) # 5610 <fork>
      fork();
    1b7a:	00004097          	auipc	ra,0x4
    1b7e:	a96080e7          	jalr	-1386(ra) # 5610 <fork>
      exit(0);
    1b82:	4501                	li	a0,0
    1b84:	00004097          	auipc	ra,0x4
    1b88:	a94080e7          	jalr	-1388(ra) # 5618 <exit>

0000000000001b8c <createdelete>:
{
    1b8c:	7175                	addi	sp,sp,-144
    1b8e:	e506                	sd	ra,136(sp)
    1b90:	e122                	sd	s0,128(sp)
    1b92:	fca6                	sd	s1,120(sp)
    1b94:	f8ca                	sd	s2,112(sp)
    1b96:	f4ce                	sd	s3,104(sp)
    1b98:	f0d2                	sd	s4,96(sp)
    1b9a:	ecd6                	sd	s5,88(sp)
    1b9c:	e8da                	sd	s6,80(sp)
    1b9e:	e4de                	sd	s7,72(sp)
    1ba0:	e0e2                	sd	s8,64(sp)
    1ba2:	fc66                	sd	s9,56(sp)
    1ba4:	0900                	addi	s0,sp,144
    1ba6:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1ba8:	4901                	li	s2,0
    1baa:	4991                	li	s3,4
    pid = fork();
    1bac:	00004097          	auipc	ra,0x4
    1bb0:	a64080e7          	jalr	-1436(ra) # 5610 <fork>
    1bb4:	84aa                	mv	s1,a0
    if(pid < 0){
    1bb6:	02054f63          	bltz	a0,1bf4 <createdelete+0x68>
    if(pid == 0){
    1bba:	c939                	beqz	a0,1c10 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bbc:	2905                	addiw	s2,s2,1
    1bbe:	ff3917e3          	bne	s2,s3,1bac <createdelete+0x20>
    1bc2:	4491                	li	s1,4
    wait(&xstatus);
    1bc4:	f7c40513          	addi	a0,s0,-132
    1bc8:	00004097          	auipc	ra,0x4
    1bcc:	a58080e7          	jalr	-1448(ra) # 5620 <wait>
    if(xstatus != 0)
    1bd0:	f7c42903          	lw	s2,-132(s0)
    1bd4:	0e091263          	bnez	s2,1cb8 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bd8:	34fd                	addiw	s1,s1,-1
    1bda:	f4ed                	bnez	s1,1bc4 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bdc:	f8040123          	sb	zero,-126(s0)
    1be0:	03000993          	li	s3,48
    1be4:	5a7d                	li	s4,-1
    1be6:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bea:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bec:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1bee:	07400a93          	li	s5,116
    1bf2:	a29d                	j	1d58 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1bf4:	85e6                	mv	a1,s9
    1bf6:	00005517          	auipc	a0,0x5
    1bfa:	ee250513          	addi	a0,a0,-286 # 6ad8 <malloc+0x1082>
    1bfe:	00004097          	auipc	ra,0x4
    1c02:	d9a080e7          	jalr	-614(ra) # 5998 <printf>
      exit(1);
    1c06:	4505                	li	a0,1
    1c08:	00004097          	auipc	ra,0x4
    1c0c:	a10080e7          	jalr	-1520(ra) # 5618 <exit>
      name[0] = 'p' + pi;
    1c10:	0709091b          	addiw	s2,s2,112
    1c14:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c18:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c1c:	4951                	li	s2,20
    1c1e:	a015                	j	1c42 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c20:	85e6                	mv	a1,s9
    1c22:	00005517          	auipc	a0,0x5
    1c26:	b4650513          	addi	a0,a0,-1210 # 6768 <malloc+0xd12>
    1c2a:	00004097          	auipc	ra,0x4
    1c2e:	d6e080e7          	jalr	-658(ra) # 5998 <printf>
          exit(1);
    1c32:	4505                	li	a0,1
    1c34:	00004097          	auipc	ra,0x4
    1c38:	9e4080e7          	jalr	-1564(ra) # 5618 <exit>
      for(i = 0; i < N; i++){
    1c3c:	2485                	addiw	s1,s1,1
    1c3e:	07248863          	beq	s1,s2,1cae <createdelete+0x122>
        name[1] = '0' + i;
    1c42:	0304879b          	addiw	a5,s1,48
    1c46:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c4a:	20200593          	li	a1,514
    1c4e:	f8040513          	addi	a0,s0,-128
    1c52:	00004097          	auipc	ra,0x4
    1c56:	a06080e7          	jalr	-1530(ra) # 5658 <open>
        if(fd < 0){
    1c5a:	fc0543e3          	bltz	a0,1c20 <createdelete+0x94>
        close(fd);
    1c5e:	00004097          	auipc	ra,0x4
    1c62:	9e2080e7          	jalr	-1566(ra) # 5640 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c66:	fc905be3          	blez	s1,1c3c <createdelete+0xb0>
    1c6a:	0014f793          	andi	a5,s1,1
    1c6e:	f7f9                	bnez	a5,1c3c <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c70:	01f4d79b          	srliw	a5,s1,0x1f
    1c74:	9fa5                	addw	a5,a5,s1
    1c76:	4017d79b          	sraiw	a5,a5,0x1
    1c7a:	0307879b          	addiw	a5,a5,48
    1c7e:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c82:	f8040513          	addi	a0,s0,-128
    1c86:	00004097          	auipc	ra,0x4
    1c8a:	9e2080e7          	jalr	-1566(ra) # 5668 <unlink>
    1c8e:	fa0557e3          	bgez	a0,1c3c <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1c92:	85e6                	mv	a1,s9
    1c94:	00005517          	auipc	a0,0x5
    1c98:	c2c50513          	addi	a0,a0,-980 # 68c0 <malloc+0xe6a>
    1c9c:	00004097          	auipc	ra,0x4
    1ca0:	cfc080e7          	jalr	-772(ra) # 5998 <printf>
            exit(1);
    1ca4:	4505                	li	a0,1
    1ca6:	00004097          	auipc	ra,0x4
    1caa:	972080e7          	jalr	-1678(ra) # 5618 <exit>
      exit(0);
    1cae:	4501                	li	a0,0
    1cb0:	00004097          	auipc	ra,0x4
    1cb4:	968080e7          	jalr	-1688(ra) # 5618 <exit>
      exit(1);
    1cb8:	4505                	li	a0,1
    1cba:	00004097          	auipc	ra,0x4
    1cbe:	95e080e7          	jalr	-1698(ra) # 5618 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cc2:	f8040613          	addi	a2,s0,-128
    1cc6:	85e6                	mv	a1,s9
    1cc8:	00005517          	auipc	a0,0x5
    1ccc:	c1050513          	addi	a0,a0,-1008 # 68d8 <malloc+0xe82>
    1cd0:	00004097          	auipc	ra,0x4
    1cd4:	cc8080e7          	jalr	-824(ra) # 5998 <printf>
        exit(1);
    1cd8:	4505                	li	a0,1
    1cda:	00004097          	auipc	ra,0x4
    1cde:	93e080e7          	jalr	-1730(ra) # 5618 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ce2:	054b7163          	bgeu	s6,s4,1d24 <createdelete+0x198>
      if(fd >= 0)
    1ce6:	02055a63          	bgez	a0,1d1a <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1cea:	2485                	addiw	s1,s1,1
    1cec:	0ff4f493          	andi	s1,s1,255
    1cf0:	05548c63          	beq	s1,s5,1d48 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1cf4:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1cf8:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1cfc:	4581                	li	a1,0
    1cfe:	f8040513          	addi	a0,s0,-128
    1d02:	00004097          	auipc	ra,0x4
    1d06:	956080e7          	jalr	-1706(ra) # 5658 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d0a:	00090463          	beqz	s2,1d12 <createdelete+0x186>
    1d0e:	fd2bdae3          	bge	s7,s2,1ce2 <createdelete+0x156>
    1d12:	fa0548e3          	bltz	a0,1cc2 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d16:	014b7963          	bgeu	s6,s4,1d28 <createdelete+0x19c>
        close(fd);
    1d1a:	00004097          	auipc	ra,0x4
    1d1e:	926080e7          	jalr	-1754(ra) # 5640 <close>
    1d22:	b7e1                	j	1cea <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d24:	fc0543e3          	bltz	a0,1cea <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d28:	f8040613          	addi	a2,s0,-128
    1d2c:	85e6                	mv	a1,s9
    1d2e:	00005517          	auipc	a0,0x5
    1d32:	bd250513          	addi	a0,a0,-1070 # 6900 <malloc+0xeaa>
    1d36:	00004097          	auipc	ra,0x4
    1d3a:	c62080e7          	jalr	-926(ra) # 5998 <printf>
        exit(1);
    1d3e:	4505                	li	a0,1
    1d40:	00004097          	auipc	ra,0x4
    1d44:	8d8080e7          	jalr	-1832(ra) # 5618 <exit>
  for(i = 0; i < N; i++){
    1d48:	2905                	addiw	s2,s2,1
    1d4a:	2a05                	addiw	s4,s4,1
    1d4c:	2985                	addiw	s3,s3,1
    1d4e:	0ff9f993          	andi	s3,s3,255
    1d52:	47d1                	li	a5,20
    1d54:	02f90a63          	beq	s2,a5,1d88 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d58:	84e2                	mv	s1,s8
    1d5a:	bf69                	j	1cf4 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d5c:	2905                	addiw	s2,s2,1
    1d5e:	0ff97913          	andi	s2,s2,255
    1d62:	2985                	addiw	s3,s3,1
    1d64:	0ff9f993          	andi	s3,s3,255
    1d68:	03490863          	beq	s2,s4,1d98 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d6c:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d6e:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d72:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d76:	f8040513          	addi	a0,s0,-128
    1d7a:	00004097          	auipc	ra,0x4
    1d7e:	8ee080e7          	jalr	-1810(ra) # 5668 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d82:	34fd                	addiw	s1,s1,-1
    1d84:	f4ed                	bnez	s1,1d6e <createdelete+0x1e2>
    1d86:	bfd9                	j	1d5c <createdelete+0x1d0>
    1d88:	03000993          	li	s3,48
    1d8c:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1d90:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1d92:	08400a13          	li	s4,132
    1d96:	bfd9                	j	1d6c <createdelete+0x1e0>
}
    1d98:	60aa                	ld	ra,136(sp)
    1d9a:	640a                	ld	s0,128(sp)
    1d9c:	74e6                	ld	s1,120(sp)
    1d9e:	7946                	ld	s2,112(sp)
    1da0:	79a6                	ld	s3,104(sp)
    1da2:	7a06                	ld	s4,96(sp)
    1da4:	6ae6                	ld	s5,88(sp)
    1da6:	6b46                	ld	s6,80(sp)
    1da8:	6ba6                	ld	s7,72(sp)
    1daa:	6c06                	ld	s8,64(sp)
    1dac:	7ce2                	ld	s9,56(sp)
    1dae:	6149                	addi	sp,sp,144
    1db0:	8082                	ret

0000000000001db2 <linkunlink>:
{
    1db2:	711d                	addi	sp,sp,-96
    1db4:	ec86                	sd	ra,88(sp)
    1db6:	e8a2                	sd	s0,80(sp)
    1db8:	e4a6                	sd	s1,72(sp)
    1dba:	e0ca                	sd	s2,64(sp)
    1dbc:	fc4e                	sd	s3,56(sp)
    1dbe:	f852                	sd	s4,48(sp)
    1dc0:	f456                	sd	s5,40(sp)
    1dc2:	f05a                	sd	s6,32(sp)
    1dc4:	ec5e                	sd	s7,24(sp)
    1dc6:	e862                	sd	s8,16(sp)
    1dc8:	e466                	sd	s9,8(sp)
    1dca:	1080                	addi	s0,sp,96
    1dcc:	84aa                	mv	s1,a0
  unlink("x");
    1dce:	00004517          	auipc	a0,0x4
    1dd2:	13a50513          	addi	a0,a0,314 # 5f08 <malloc+0x4b2>
    1dd6:	00004097          	auipc	ra,0x4
    1dda:	892080e7          	jalr	-1902(ra) # 5668 <unlink>
  pid = fork();
    1dde:	00004097          	auipc	ra,0x4
    1de2:	832080e7          	jalr	-1998(ra) # 5610 <fork>
  if(pid < 0){
    1de6:	02054b63          	bltz	a0,1e1c <linkunlink+0x6a>
    1dea:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dec:	4c85                	li	s9,1
    1dee:	e119                	bnez	a0,1df4 <linkunlink+0x42>
    1df0:	06100c93          	li	s9,97
    1df4:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1df8:	41c659b7          	lui	s3,0x41c65
    1dfc:	e6d9899b          	addiw	s3,s3,-403
    1e00:	690d                	lui	s2,0x3
    1e02:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e06:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e08:	4b05                	li	s6,1
      unlink("x");
    1e0a:	00004a97          	auipc	s5,0x4
    1e0e:	0fea8a93          	addi	s5,s5,254 # 5f08 <malloc+0x4b2>
      link("cat", "x");
    1e12:	00005b97          	auipc	s7,0x5
    1e16:	b16b8b93          	addi	s7,s7,-1258 # 6928 <malloc+0xed2>
    1e1a:	a091                	j	1e5e <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e1c:	85a6                	mv	a1,s1
    1e1e:	00005517          	auipc	a0,0x5
    1e22:	8b250513          	addi	a0,a0,-1870 # 66d0 <malloc+0xc7a>
    1e26:	00004097          	auipc	ra,0x4
    1e2a:	b72080e7          	jalr	-1166(ra) # 5998 <printf>
    exit(1);
    1e2e:	4505                	li	a0,1
    1e30:	00003097          	auipc	ra,0x3
    1e34:	7e8080e7          	jalr	2024(ra) # 5618 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e38:	20200593          	li	a1,514
    1e3c:	8556                	mv	a0,s5
    1e3e:	00004097          	auipc	ra,0x4
    1e42:	81a080e7          	jalr	-2022(ra) # 5658 <open>
    1e46:	00003097          	auipc	ra,0x3
    1e4a:	7fa080e7          	jalr	2042(ra) # 5640 <close>
    1e4e:	a031                	j	1e5a <linkunlink+0xa8>
      unlink("x");
    1e50:	8556                	mv	a0,s5
    1e52:	00004097          	auipc	ra,0x4
    1e56:	816080e7          	jalr	-2026(ra) # 5668 <unlink>
  for(i = 0; i < 100; i++){
    1e5a:	34fd                	addiw	s1,s1,-1
    1e5c:	c09d                	beqz	s1,1e82 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e5e:	033c87bb          	mulw	a5,s9,s3
    1e62:	012787bb          	addw	a5,a5,s2
    1e66:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e6a:	0347f7bb          	remuw	a5,a5,s4
    1e6e:	d7e9                	beqz	a5,1e38 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e70:	ff6790e3          	bne	a5,s6,1e50 <linkunlink+0x9e>
      link("cat", "x");
    1e74:	85d6                	mv	a1,s5
    1e76:	855e                	mv	a0,s7
    1e78:	00004097          	auipc	ra,0x4
    1e7c:	800080e7          	jalr	-2048(ra) # 5678 <link>
    1e80:	bfe9                	j	1e5a <linkunlink+0xa8>
  if(pid)
    1e82:	020c0463          	beqz	s8,1eaa <linkunlink+0xf8>
    wait(0);
    1e86:	4501                	li	a0,0
    1e88:	00003097          	auipc	ra,0x3
    1e8c:	798080e7          	jalr	1944(ra) # 5620 <wait>
}
    1e90:	60e6                	ld	ra,88(sp)
    1e92:	6446                	ld	s0,80(sp)
    1e94:	64a6                	ld	s1,72(sp)
    1e96:	6906                	ld	s2,64(sp)
    1e98:	79e2                	ld	s3,56(sp)
    1e9a:	7a42                	ld	s4,48(sp)
    1e9c:	7aa2                	ld	s5,40(sp)
    1e9e:	7b02                	ld	s6,32(sp)
    1ea0:	6be2                	ld	s7,24(sp)
    1ea2:	6c42                	ld	s8,16(sp)
    1ea4:	6ca2                	ld	s9,8(sp)
    1ea6:	6125                	addi	sp,sp,96
    1ea8:	8082                	ret
    exit(0);
    1eaa:	4501                	li	a0,0
    1eac:	00003097          	auipc	ra,0x3
    1eb0:	76c080e7          	jalr	1900(ra) # 5618 <exit>

0000000000001eb4 <manywrites>:
{
    1eb4:	711d                	addi	sp,sp,-96
    1eb6:	ec86                	sd	ra,88(sp)
    1eb8:	e8a2                	sd	s0,80(sp)
    1eba:	e4a6                	sd	s1,72(sp)
    1ebc:	e0ca                	sd	s2,64(sp)
    1ebe:	fc4e                	sd	s3,56(sp)
    1ec0:	f852                	sd	s4,48(sp)
    1ec2:	f456                	sd	s5,40(sp)
    1ec4:	f05a                	sd	s6,32(sp)
    1ec6:	ec5e                	sd	s7,24(sp)
    1ec8:	1080                	addi	s0,sp,96
    1eca:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1ecc:	4901                	li	s2,0
    1ece:	4991                	li	s3,4
    int pid = fork();
    1ed0:	00003097          	auipc	ra,0x3
    1ed4:	740080e7          	jalr	1856(ra) # 5610 <fork>
    1ed8:	84aa                	mv	s1,a0
    if(pid < 0){
    1eda:	02054963          	bltz	a0,1f0c <manywrites+0x58>
    if(pid == 0){
    1ede:	c521                	beqz	a0,1f26 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    1ee0:	2905                	addiw	s2,s2,1
    1ee2:	ff3917e3          	bne	s2,s3,1ed0 <manywrites+0x1c>
    1ee6:	4491                	li	s1,4
    int st = 0;
    1ee8:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1eec:	fa840513          	addi	a0,s0,-88
    1ef0:	00003097          	auipc	ra,0x3
    1ef4:	730080e7          	jalr	1840(ra) # 5620 <wait>
    if(st != 0)
    1ef8:	fa842503          	lw	a0,-88(s0)
    1efc:	ed6d                	bnez	a0,1ff6 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    1efe:	34fd                	addiw	s1,s1,-1
    1f00:	f4e5                	bnez	s1,1ee8 <manywrites+0x34>
  exit(0);
    1f02:	4501                	li	a0,0
    1f04:	00003097          	auipc	ra,0x3
    1f08:	714080e7          	jalr	1812(ra) # 5618 <exit>
      printf("fork failed\n");
    1f0c:	00005517          	auipc	a0,0x5
    1f10:	bcc50513          	addi	a0,a0,-1076 # 6ad8 <malloc+0x1082>
    1f14:	00004097          	auipc	ra,0x4
    1f18:	a84080e7          	jalr	-1404(ra) # 5998 <printf>
      exit(1);
    1f1c:	4505                	li	a0,1
    1f1e:	00003097          	auipc	ra,0x3
    1f22:	6fa080e7          	jalr	1786(ra) # 5618 <exit>
      name[0] = 'b';
    1f26:	06200793          	li	a5,98
    1f2a:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1f2e:	0619079b          	addiw	a5,s2,97
    1f32:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1f36:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1f3a:	fa840513          	addi	a0,s0,-88
    1f3e:	00003097          	auipc	ra,0x3
    1f42:	72a080e7          	jalr	1834(ra) # 5668 <unlink>
    1f46:	4b79                	li	s6,30
          int cc = write(fd, buf, sz);
    1f48:	0000ab97          	auipc	s7,0xa
    1f4c:	b68b8b93          	addi	s7,s7,-1176 # bab0 <buf>
        for(int i = 0; i < ci+1; i++){
    1f50:	8a26                	mv	s4,s1
    1f52:	02094e63          	bltz	s2,1f8e <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    1f56:	20200593          	li	a1,514
    1f5a:	fa840513          	addi	a0,s0,-88
    1f5e:	00003097          	auipc	ra,0x3
    1f62:	6fa080e7          	jalr	1786(ra) # 5658 <open>
    1f66:	89aa                	mv	s3,a0
          if(fd < 0){
    1f68:	04054763          	bltz	a0,1fb6 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    1f6c:	660d                	lui	a2,0x3
    1f6e:	85de                	mv	a1,s7
    1f70:	00003097          	auipc	ra,0x3
    1f74:	6c8080e7          	jalr	1736(ra) # 5638 <write>
          if(cc != sz){
    1f78:	678d                	lui	a5,0x3
    1f7a:	04f51e63          	bne	a0,a5,1fd6 <manywrites+0x122>
          close(fd);
    1f7e:	854e                	mv	a0,s3
    1f80:	00003097          	auipc	ra,0x3
    1f84:	6c0080e7          	jalr	1728(ra) # 5640 <close>
        for(int i = 0; i < ci+1; i++){
    1f88:	2a05                	addiw	s4,s4,1
    1f8a:	fd4956e3          	bge	s2,s4,1f56 <manywrites+0xa2>
        unlink(name);
    1f8e:	fa840513          	addi	a0,s0,-88
    1f92:	00003097          	auipc	ra,0x3
    1f96:	6d6080e7          	jalr	1750(ra) # 5668 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1f9a:	3b7d                	addiw	s6,s6,-1
    1f9c:	fa0b1ae3          	bnez	s6,1f50 <manywrites+0x9c>
      unlink(name);
    1fa0:	fa840513          	addi	a0,s0,-88
    1fa4:	00003097          	auipc	ra,0x3
    1fa8:	6c4080e7          	jalr	1732(ra) # 5668 <unlink>
      exit(0);
    1fac:	4501                	li	a0,0
    1fae:	00003097          	auipc	ra,0x3
    1fb2:	66a080e7          	jalr	1642(ra) # 5618 <exit>
            printf("%s: cannot create %s\n", s, name);
    1fb6:	fa840613          	addi	a2,s0,-88
    1fba:	85d6                	mv	a1,s5
    1fbc:	00005517          	auipc	a0,0x5
    1fc0:	97450513          	addi	a0,a0,-1676 # 6930 <malloc+0xeda>
    1fc4:	00004097          	auipc	ra,0x4
    1fc8:	9d4080e7          	jalr	-1580(ra) # 5998 <printf>
            exit(1);
    1fcc:	4505                	li	a0,1
    1fce:	00003097          	auipc	ra,0x3
    1fd2:	64a080e7          	jalr	1610(ra) # 5618 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1fd6:	86aa                	mv	a3,a0
    1fd8:	660d                	lui	a2,0x3
    1fda:	85d6                	mv	a1,s5
    1fdc:	00004517          	auipc	a0,0x4
    1fe0:	f7c50513          	addi	a0,a0,-132 # 5f58 <malloc+0x502>
    1fe4:	00004097          	auipc	ra,0x4
    1fe8:	9b4080e7          	jalr	-1612(ra) # 5998 <printf>
            exit(1);
    1fec:	4505                	li	a0,1
    1fee:	00003097          	auipc	ra,0x3
    1ff2:	62a080e7          	jalr	1578(ra) # 5618 <exit>
      exit(st);
    1ff6:	00003097          	auipc	ra,0x3
    1ffa:	622080e7          	jalr	1570(ra) # 5618 <exit>

0000000000001ffe <forktest>:
{
    1ffe:	7179                	addi	sp,sp,-48
    2000:	f406                	sd	ra,40(sp)
    2002:	f022                	sd	s0,32(sp)
    2004:	ec26                	sd	s1,24(sp)
    2006:	e84a                	sd	s2,16(sp)
    2008:	e44e                	sd	s3,8(sp)
    200a:	1800                	addi	s0,sp,48
    200c:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    200e:	4481                	li	s1,0
    2010:	3e800913          	li	s2,1000
    pid = fork();
    2014:	00003097          	auipc	ra,0x3
    2018:	5fc080e7          	jalr	1532(ra) # 5610 <fork>
    if(pid < 0)
    201c:	02054863          	bltz	a0,204c <forktest+0x4e>
    if(pid == 0)
    2020:	c115                	beqz	a0,2044 <forktest+0x46>
  for(n=0; n<N; n++){
    2022:	2485                	addiw	s1,s1,1
    2024:	ff2498e3          	bne	s1,s2,2014 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    2028:	85ce                	mv	a1,s3
    202a:	00005517          	auipc	a0,0x5
    202e:	93650513          	addi	a0,a0,-1738 # 6960 <malloc+0xf0a>
    2032:	00004097          	auipc	ra,0x4
    2036:	966080e7          	jalr	-1690(ra) # 5998 <printf>
    exit(1);
    203a:	4505                	li	a0,1
    203c:	00003097          	auipc	ra,0x3
    2040:	5dc080e7          	jalr	1500(ra) # 5618 <exit>
      exit(0);
    2044:	00003097          	auipc	ra,0x3
    2048:	5d4080e7          	jalr	1492(ra) # 5618 <exit>
  if (n == 0) {
    204c:	cc9d                	beqz	s1,208a <forktest+0x8c>
  if(n == N){
    204e:	3e800793          	li	a5,1000
    2052:	fcf48be3          	beq	s1,a5,2028 <forktest+0x2a>
  for(; n > 0; n--){
    2056:	00905b63          	blez	s1,206c <forktest+0x6e>
    if(wait(0) < 0){
    205a:	4501                	li	a0,0
    205c:	00003097          	auipc	ra,0x3
    2060:	5c4080e7          	jalr	1476(ra) # 5620 <wait>
    2064:	04054163          	bltz	a0,20a6 <forktest+0xa8>
  for(; n > 0; n--){
    2068:	34fd                	addiw	s1,s1,-1
    206a:	f8e5                	bnez	s1,205a <forktest+0x5c>
  if(wait(0) != -1){
    206c:	4501                	li	a0,0
    206e:	00003097          	auipc	ra,0x3
    2072:	5b2080e7          	jalr	1458(ra) # 5620 <wait>
    2076:	57fd                	li	a5,-1
    2078:	04f51563          	bne	a0,a5,20c2 <forktest+0xc4>
}
    207c:	70a2                	ld	ra,40(sp)
    207e:	7402                	ld	s0,32(sp)
    2080:	64e2                	ld	s1,24(sp)
    2082:	6942                	ld	s2,16(sp)
    2084:	69a2                	ld	s3,8(sp)
    2086:	6145                	addi	sp,sp,48
    2088:	8082                	ret
    printf("%s: no fork at all!\n", s);
    208a:	85ce                	mv	a1,s3
    208c:	00005517          	auipc	a0,0x5
    2090:	8bc50513          	addi	a0,a0,-1860 # 6948 <malloc+0xef2>
    2094:	00004097          	auipc	ra,0x4
    2098:	904080e7          	jalr	-1788(ra) # 5998 <printf>
    exit(1);
    209c:	4505                	li	a0,1
    209e:	00003097          	auipc	ra,0x3
    20a2:	57a080e7          	jalr	1402(ra) # 5618 <exit>
      printf("%s: wait stopped early\n", s);
    20a6:	85ce                	mv	a1,s3
    20a8:	00005517          	auipc	a0,0x5
    20ac:	8e050513          	addi	a0,a0,-1824 # 6988 <malloc+0xf32>
    20b0:	00004097          	auipc	ra,0x4
    20b4:	8e8080e7          	jalr	-1816(ra) # 5998 <printf>
      exit(1);
    20b8:	4505                	li	a0,1
    20ba:	00003097          	auipc	ra,0x3
    20be:	55e080e7          	jalr	1374(ra) # 5618 <exit>
    printf("%s: wait got too many\n", s);
    20c2:	85ce                	mv	a1,s3
    20c4:	00005517          	auipc	a0,0x5
    20c8:	8dc50513          	addi	a0,a0,-1828 # 69a0 <malloc+0xf4a>
    20cc:	00004097          	auipc	ra,0x4
    20d0:	8cc080e7          	jalr	-1844(ra) # 5998 <printf>
    exit(1);
    20d4:	4505                	li	a0,1
    20d6:	00003097          	auipc	ra,0x3
    20da:	542080e7          	jalr	1346(ra) # 5618 <exit>

00000000000020de <kernmem>:
{
    20de:	715d                	addi	sp,sp,-80
    20e0:	e486                	sd	ra,72(sp)
    20e2:	e0a2                	sd	s0,64(sp)
    20e4:	fc26                	sd	s1,56(sp)
    20e6:	f84a                	sd	s2,48(sp)
    20e8:	f44e                	sd	s3,40(sp)
    20ea:	f052                	sd	s4,32(sp)
    20ec:	ec56                	sd	s5,24(sp)
    20ee:	0880                	addi	s0,sp,80
    20f0:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f2:	4485                	li	s1,1
    20f4:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    20f6:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f8:	69b1                	lui	s3,0xc
    20fa:	35098993          	addi	s3,s3,848 # c350 <buf+0x8a0>
    20fe:	1003d937          	lui	s2,0x1003d
    2102:	090e                	slli	s2,s2,0x3
    2104:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e9c0>
    pid = fork();
    2108:	00003097          	auipc	ra,0x3
    210c:	508080e7          	jalr	1288(ra) # 5610 <fork>
    if(pid < 0){
    2110:	02054963          	bltz	a0,2142 <kernmem+0x64>
    if(pid == 0){
    2114:	c529                	beqz	a0,215e <kernmem+0x80>
    wait(&xstatus);
    2116:	fbc40513          	addi	a0,s0,-68
    211a:	00003097          	auipc	ra,0x3
    211e:	506080e7          	jalr	1286(ra) # 5620 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2122:	fbc42783          	lw	a5,-68(s0)
    2126:	05579d63          	bne	a5,s5,2180 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    212a:	94ce                	add	s1,s1,s3
    212c:	fd249ee3          	bne	s1,s2,2108 <kernmem+0x2a>
}
    2130:	60a6                	ld	ra,72(sp)
    2132:	6406                	ld	s0,64(sp)
    2134:	74e2                	ld	s1,56(sp)
    2136:	7942                	ld	s2,48(sp)
    2138:	79a2                	ld	s3,40(sp)
    213a:	7a02                	ld	s4,32(sp)
    213c:	6ae2                	ld	s5,24(sp)
    213e:	6161                	addi	sp,sp,80
    2140:	8082                	ret
      printf("%s: fork failed\n", s);
    2142:	85d2                	mv	a1,s4
    2144:	00004517          	auipc	a0,0x4
    2148:	58c50513          	addi	a0,a0,1420 # 66d0 <malloc+0xc7a>
    214c:	00004097          	auipc	ra,0x4
    2150:	84c080e7          	jalr	-1972(ra) # 5998 <printf>
      exit(1);
    2154:	4505                	li	a0,1
    2156:	00003097          	auipc	ra,0x3
    215a:	4c2080e7          	jalr	1218(ra) # 5618 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    215e:	0004c683          	lbu	a3,0(s1)
    2162:	8626                	mv	a2,s1
    2164:	85d2                	mv	a1,s4
    2166:	00005517          	auipc	a0,0x5
    216a:	85250513          	addi	a0,a0,-1966 # 69b8 <malloc+0xf62>
    216e:	00004097          	auipc	ra,0x4
    2172:	82a080e7          	jalr	-2006(ra) # 5998 <printf>
      exit(1);
    2176:	4505                	li	a0,1
    2178:	00003097          	auipc	ra,0x3
    217c:	4a0080e7          	jalr	1184(ra) # 5618 <exit>
      exit(1);
    2180:	4505                	li	a0,1
    2182:	00003097          	auipc	ra,0x3
    2186:	496080e7          	jalr	1174(ra) # 5618 <exit>

000000000000218a <bigargtest>:
{
    218a:	7179                	addi	sp,sp,-48
    218c:	f406                	sd	ra,40(sp)
    218e:	f022                	sd	s0,32(sp)
    2190:	ec26                	sd	s1,24(sp)
    2192:	1800                	addi	s0,sp,48
    2194:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2196:	00005517          	auipc	a0,0x5
    219a:	84250513          	addi	a0,a0,-1982 # 69d8 <malloc+0xf82>
    219e:	00003097          	auipc	ra,0x3
    21a2:	4ca080e7          	jalr	1226(ra) # 5668 <unlink>
  pid = fork();
    21a6:	00003097          	auipc	ra,0x3
    21aa:	46a080e7          	jalr	1130(ra) # 5610 <fork>
  if(pid == 0){
    21ae:	c121                	beqz	a0,21ee <bigargtest+0x64>
  } else if(pid < 0){
    21b0:	0a054063          	bltz	a0,2250 <bigargtest+0xc6>
  wait(&xstatus);
    21b4:	fdc40513          	addi	a0,s0,-36
    21b8:	00003097          	auipc	ra,0x3
    21bc:	468080e7          	jalr	1128(ra) # 5620 <wait>
  if(xstatus != 0)
    21c0:	fdc42503          	lw	a0,-36(s0)
    21c4:	e545                	bnez	a0,226c <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    21c6:	4581                	li	a1,0
    21c8:	00005517          	auipc	a0,0x5
    21cc:	81050513          	addi	a0,a0,-2032 # 69d8 <malloc+0xf82>
    21d0:	00003097          	auipc	ra,0x3
    21d4:	488080e7          	jalr	1160(ra) # 5658 <open>
  if(fd < 0){
    21d8:	08054e63          	bltz	a0,2274 <bigargtest+0xea>
  close(fd);
    21dc:	00003097          	auipc	ra,0x3
    21e0:	464080e7          	jalr	1124(ra) # 5640 <close>
}
    21e4:	70a2                	ld	ra,40(sp)
    21e6:	7402                	ld	s0,32(sp)
    21e8:	64e2                	ld	s1,24(sp)
    21ea:	6145                	addi	sp,sp,48
    21ec:	8082                	ret
    21ee:	00006797          	auipc	a5,0x6
    21f2:	0aa78793          	addi	a5,a5,170 # 8298 <args.1837>
    21f6:	00006697          	auipc	a3,0x6
    21fa:	19a68693          	addi	a3,a3,410 # 8390 <args.1837+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    21fe:	00004717          	auipc	a4,0x4
    2202:	7ea70713          	addi	a4,a4,2026 # 69e8 <malloc+0xf92>
    2206:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    2208:	07a1                	addi	a5,a5,8
    220a:	fed79ee3          	bne	a5,a3,2206 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    220e:	00006597          	auipc	a1,0x6
    2212:	08a58593          	addi	a1,a1,138 # 8298 <args.1837>
    2216:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    221a:	00004517          	auipc	a0,0x4
    221e:	c7e50513          	addi	a0,a0,-898 # 5e98 <malloc+0x442>
    2222:	00003097          	auipc	ra,0x3
    2226:	42e080e7          	jalr	1070(ra) # 5650 <exec>
    fd = open("bigarg-ok", O_CREATE);
    222a:	20000593          	li	a1,512
    222e:	00004517          	auipc	a0,0x4
    2232:	7aa50513          	addi	a0,a0,1962 # 69d8 <malloc+0xf82>
    2236:	00003097          	auipc	ra,0x3
    223a:	422080e7          	jalr	1058(ra) # 5658 <open>
    close(fd);
    223e:	00003097          	auipc	ra,0x3
    2242:	402080e7          	jalr	1026(ra) # 5640 <close>
    exit(0);
    2246:	4501                	li	a0,0
    2248:	00003097          	auipc	ra,0x3
    224c:	3d0080e7          	jalr	976(ra) # 5618 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2250:	85a6                	mv	a1,s1
    2252:	00005517          	auipc	a0,0x5
    2256:	87650513          	addi	a0,a0,-1930 # 6ac8 <malloc+0x1072>
    225a:	00003097          	auipc	ra,0x3
    225e:	73e080e7          	jalr	1854(ra) # 5998 <printf>
    exit(1);
    2262:	4505                	li	a0,1
    2264:	00003097          	auipc	ra,0x3
    2268:	3b4080e7          	jalr	948(ra) # 5618 <exit>
    exit(xstatus);
    226c:	00003097          	auipc	ra,0x3
    2270:	3ac080e7          	jalr	940(ra) # 5618 <exit>
    printf("%s: bigarg test failed!\n", s);
    2274:	85a6                	mv	a1,s1
    2276:	00005517          	auipc	a0,0x5
    227a:	87250513          	addi	a0,a0,-1934 # 6ae8 <malloc+0x1092>
    227e:	00003097          	auipc	ra,0x3
    2282:	71a080e7          	jalr	1818(ra) # 5998 <printf>
    exit(1);
    2286:	4505                	li	a0,1
    2288:	00003097          	auipc	ra,0x3
    228c:	390080e7          	jalr	912(ra) # 5618 <exit>

0000000000002290 <stacktest>:
{
    2290:	7179                	addi	sp,sp,-48
    2292:	f406                	sd	ra,40(sp)
    2294:	f022                	sd	s0,32(sp)
    2296:	ec26                	sd	s1,24(sp)
    2298:	1800                	addi	s0,sp,48
    229a:	84aa                	mv	s1,a0
  pid = fork();
    229c:	00003097          	auipc	ra,0x3
    22a0:	374080e7          	jalr	884(ra) # 5610 <fork>
  if(pid == 0) {
    22a4:	c115                	beqz	a0,22c8 <stacktest+0x38>
  } else if(pid < 0){
    22a6:	04054463          	bltz	a0,22ee <stacktest+0x5e>
  wait(&xstatus);
    22aa:	fdc40513          	addi	a0,s0,-36
    22ae:	00003097          	auipc	ra,0x3
    22b2:	372080e7          	jalr	882(ra) # 5620 <wait>
  if(xstatus == -1)  // kernel killed child?
    22b6:	fdc42503          	lw	a0,-36(s0)
    22ba:	57fd                	li	a5,-1
    22bc:	04f50763          	beq	a0,a5,230a <stacktest+0x7a>
    exit(xstatus);
    22c0:	00003097          	auipc	ra,0x3
    22c4:	358080e7          	jalr	856(ra) # 5618 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    22c8:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    22ca:	77fd                	lui	a5,0xfffff
    22cc:	97ba                	add	a5,a5,a4
    22ce:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0540>
    22d2:	85a6                	mv	a1,s1
    22d4:	00005517          	auipc	a0,0x5
    22d8:	83450513          	addi	a0,a0,-1996 # 6b08 <malloc+0x10b2>
    22dc:	00003097          	auipc	ra,0x3
    22e0:	6bc080e7          	jalr	1724(ra) # 5998 <printf>
    exit(1);
    22e4:	4505                	li	a0,1
    22e6:	00003097          	auipc	ra,0x3
    22ea:	332080e7          	jalr	818(ra) # 5618 <exit>
    printf("%s: fork failed\n", s);
    22ee:	85a6                	mv	a1,s1
    22f0:	00004517          	auipc	a0,0x4
    22f4:	3e050513          	addi	a0,a0,992 # 66d0 <malloc+0xc7a>
    22f8:	00003097          	auipc	ra,0x3
    22fc:	6a0080e7          	jalr	1696(ra) # 5998 <printf>
    exit(1);
    2300:	4505                	li	a0,1
    2302:	00003097          	auipc	ra,0x3
    2306:	316080e7          	jalr	790(ra) # 5618 <exit>
    exit(0);
    230a:	4501                	li	a0,0
    230c:	00003097          	auipc	ra,0x3
    2310:	30c080e7          	jalr	780(ra) # 5618 <exit>

0000000000002314 <copyinstr3>:
{
    2314:	7179                	addi	sp,sp,-48
    2316:	f406                	sd	ra,40(sp)
    2318:	f022                	sd	s0,32(sp)
    231a:	ec26                	sd	s1,24(sp)
    231c:	1800                	addi	s0,sp,48
  sbrk(8192);
    231e:	6509                	lui	a0,0x2
    2320:	00003097          	auipc	ra,0x3
    2324:	380080e7          	jalr	896(ra) # 56a0 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2328:	4501                	li	a0,0
    232a:	00003097          	auipc	ra,0x3
    232e:	376080e7          	jalr	886(ra) # 56a0 <sbrk>
  if((top % PGSIZE) != 0){
    2332:	03451793          	slli	a5,a0,0x34
    2336:	e3c9                	bnez	a5,23b8 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2338:	4501                	li	a0,0
    233a:	00003097          	auipc	ra,0x3
    233e:	366080e7          	jalr	870(ra) # 56a0 <sbrk>
  if(top % PGSIZE){
    2342:	03451793          	slli	a5,a0,0x34
    2346:	e3d9                	bnez	a5,23cc <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2348:	fff50493          	addi	s1,a0,-1 # 1fff <forktest+0x1>
  *b = 'x';
    234c:	07800793          	li	a5,120
    2350:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2354:	8526                	mv	a0,s1
    2356:	00003097          	auipc	ra,0x3
    235a:	312080e7          	jalr	786(ra) # 5668 <unlink>
  if(ret != -1){
    235e:	57fd                	li	a5,-1
    2360:	08f51363          	bne	a0,a5,23e6 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2364:	20100593          	li	a1,513
    2368:	8526                	mv	a0,s1
    236a:	00003097          	auipc	ra,0x3
    236e:	2ee080e7          	jalr	750(ra) # 5658 <open>
  if(fd != -1){
    2372:	57fd                	li	a5,-1
    2374:	08f51863          	bne	a0,a5,2404 <copyinstr3+0xf0>
  ret = link(b, b);
    2378:	85a6                	mv	a1,s1
    237a:	8526                	mv	a0,s1
    237c:	00003097          	auipc	ra,0x3
    2380:	2fc080e7          	jalr	764(ra) # 5678 <link>
  if(ret != -1){
    2384:	57fd                	li	a5,-1
    2386:	08f51e63          	bne	a0,a5,2422 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    238a:	00005797          	auipc	a5,0x5
    238e:	41678793          	addi	a5,a5,1046 # 77a0 <malloc+0x1d4a>
    2392:	fcf43823          	sd	a5,-48(s0)
    2396:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    239a:	fd040593          	addi	a1,s0,-48
    239e:	8526                	mv	a0,s1
    23a0:	00003097          	auipc	ra,0x3
    23a4:	2b0080e7          	jalr	688(ra) # 5650 <exec>
  if(ret != -1){
    23a8:	57fd                	li	a5,-1
    23aa:	08f51c63          	bne	a0,a5,2442 <copyinstr3+0x12e>
}
    23ae:	70a2                	ld	ra,40(sp)
    23b0:	7402                	ld	s0,32(sp)
    23b2:	64e2                	ld	s1,24(sp)
    23b4:	6145                	addi	sp,sp,48
    23b6:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    23b8:	0347d513          	srli	a0,a5,0x34
    23bc:	6785                	lui	a5,0x1
    23be:	40a7853b          	subw	a0,a5,a0
    23c2:	00003097          	auipc	ra,0x3
    23c6:	2de080e7          	jalr	734(ra) # 56a0 <sbrk>
    23ca:	b7bd                	j	2338 <copyinstr3+0x24>
    printf("oops\n");
    23cc:	00004517          	auipc	a0,0x4
    23d0:	76450513          	addi	a0,a0,1892 # 6b30 <malloc+0x10da>
    23d4:	00003097          	auipc	ra,0x3
    23d8:	5c4080e7          	jalr	1476(ra) # 5998 <printf>
    exit(1);
    23dc:	4505                	li	a0,1
    23de:	00003097          	auipc	ra,0x3
    23e2:	23a080e7          	jalr	570(ra) # 5618 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    23e6:	862a                	mv	a2,a0
    23e8:	85a6                	mv	a1,s1
    23ea:	00004517          	auipc	a0,0x4
    23ee:	20650513          	addi	a0,a0,518 # 65f0 <malloc+0xb9a>
    23f2:	00003097          	auipc	ra,0x3
    23f6:	5a6080e7          	jalr	1446(ra) # 5998 <printf>
    exit(1);
    23fa:	4505                	li	a0,1
    23fc:	00003097          	auipc	ra,0x3
    2400:	21c080e7          	jalr	540(ra) # 5618 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2404:	862a                	mv	a2,a0
    2406:	85a6                	mv	a1,s1
    2408:	00004517          	auipc	a0,0x4
    240c:	20850513          	addi	a0,a0,520 # 6610 <malloc+0xbba>
    2410:	00003097          	auipc	ra,0x3
    2414:	588080e7          	jalr	1416(ra) # 5998 <printf>
    exit(1);
    2418:	4505                	li	a0,1
    241a:	00003097          	auipc	ra,0x3
    241e:	1fe080e7          	jalr	510(ra) # 5618 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2422:	86aa                	mv	a3,a0
    2424:	8626                	mv	a2,s1
    2426:	85a6                	mv	a1,s1
    2428:	00004517          	auipc	a0,0x4
    242c:	20850513          	addi	a0,a0,520 # 6630 <malloc+0xbda>
    2430:	00003097          	auipc	ra,0x3
    2434:	568080e7          	jalr	1384(ra) # 5998 <printf>
    exit(1);
    2438:	4505                	li	a0,1
    243a:	00003097          	auipc	ra,0x3
    243e:	1de080e7          	jalr	478(ra) # 5618 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2442:	567d                	li	a2,-1
    2444:	85a6                	mv	a1,s1
    2446:	00004517          	auipc	a0,0x4
    244a:	21250513          	addi	a0,a0,530 # 6658 <malloc+0xc02>
    244e:	00003097          	auipc	ra,0x3
    2452:	54a080e7          	jalr	1354(ra) # 5998 <printf>
    exit(1);
    2456:	4505                	li	a0,1
    2458:	00003097          	auipc	ra,0x3
    245c:	1c0080e7          	jalr	448(ra) # 5618 <exit>

0000000000002460 <rwsbrk>:
{
    2460:	1101                	addi	sp,sp,-32
    2462:	ec06                	sd	ra,24(sp)
    2464:	e822                	sd	s0,16(sp)
    2466:	e426                	sd	s1,8(sp)
    2468:	e04a                	sd	s2,0(sp)
    246a:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    246c:	6509                	lui	a0,0x2
    246e:	00003097          	auipc	ra,0x3
    2472:	232080e7          	jalr	562(ra) # 56a0 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2476:	57fd                	li	a5,-1
    2478:	06f50363          	beq	a0,a5,24de <rwsbrk+0x7e>
    247c:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    247e:	7579                	lui	a0,0xffffe
    2480:	00003097          	auipc	ra,0x3
    2484:	220080e7          	jalr	544(ra) # 56a0 <sbrk>
    2488:	57fd                	li	a5,-1
    248a:	06f50763          	beq	a0,a5,24f8 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    248e:	20100593          	li	a1,513
    2492:	00003517          	auipc	a0,0x3
    2496:	72650513          	addi	a0,a0,1830 # 5bb8 <malloc+0x162>
    249a:	00003097          	auipc	ra,0x3
    249e:	1be080e7          	jalr	446(ra) # 5658 <open>
    24a2:	892a                	mv	s2,a0
  if(fd < 0){
    24a4:	06054763          	bltz	a0,2512 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    24a8:	6505                	lui	a0,0x1
    24aa:	94aa                	add	s1,s1,a0
    24ac:	40000613          	li	a2,1024
    24b0:	85a6                	mv	a1,s1
    24b2:	854a                	mv	a0,s2
    24b4:	00003097          	auipc	ra,0x3
    24b8:	184080e7          	jalr	388(ra) # 5638 <write>
    24bc:	862a                	mv	a2,a0
  if(n >= 0){
    24be:	06054763          	bltz	a0,252c <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    24c2:	85a6                	mv	a1,s1
    24c4:	00004517          	auipc	a0,0x4
    24c8:	6c450513          	addi	a0,a0,1732 # 6b88 <malloc+0x1132>
    24cc:	00003097          	auipc	ra,0x3
    24d0:	4cc080e7          	jalr	1228(ra) # 5998 <printf>
    exit(1);
    24d4:	4505                	li	a0,1
    24d6:	00003097          	auipc	ra,0x3
    24da:	142080e7          	jalr	322(ra) # 5618 <exit>
    printf("sbrk(rwsbrk) failed\n");
    24de:	00004517          	auipc	a0,0x4
    24e2:	65a50513          	addi	a0,a0,1626 # 6b38 <malloc+0x10e2>
    24e6:	00003097          	auipc	ra,0x3
    24ea:	4b2080e7          	jalr	1202(ra) # 5998 <printf>
    exit(1);
    24ee:	4505                	li	a0,1
    24f0:	00003097          	auipc	ra,0x3
    24f4:	128080e7          	jalr	296(ra) # 5618 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    24f8:	00004517          	auipc	a0,0x4
    24fc:	65850513          	addi	a0,a0,1624 # 6b50 <malloc+0x10fa>
    2500:	00003097          	auipc	ra,0x3
    2504:	498080e7          	jalr	1176(ra) # 5998 <printf>
    exit(1);
    2508:	4505                	li	a0,1
    250a:	00003097          	auipc	ra,0x3
    250e:	10e080e7          	jalr	270(ra) # 5618 <exit>
    printf("open(rwsbrk) failed\n");
    2512:	00004517          	auipc	a0,0x4
    2516:	65e50513          	addi	a0,a0,1630 # 6b70 <malloc+0x111a>
    251a:	00003097          	auipc	ra,0x3
    251e:	47e080e7          	jalr	1150(ra) # 5998 <printf>
    exit(1);
    2522:	4505                	li	a0,1
    2524:	00003097          	auipc	ra,0x3
    2528:	0f4080e7          	jalr	244(ra) # 5618 <exit>
  close(fd);
    252c:	854a                	mv	a0,s2
    252e:	00003097          	auipc	ra,0x3
    2532:	112080e7          	jalr	274(ra) # 5640 <close>
  unlink("rwsbrk");
    2536:	00003517          	auipc	a0,0x3
    253a:	68250513          	addi	a0,a0,1666 # 5bb8 <malloc+0x162>
    253e:	00003097          	auipc	ra,0x3
    2542:	12a080e7          	jalr	298(ra) # 5668 <unlink>
  fd = open("README", O_RDONLY);
    2546:	4581                	li	a1,0
    2548:	00004517          	auipc	a0,0x4
    254c:	ae850513          	addi	a0,a0,-1304 # 6030 <malloc+0x5da>
    2550:	00003097          	auipc	ra,0x3
    2554:	108080e7          	jalr	264(ra) # 5658 <open>
    2558:	892a                	mv	s2,a0
  if(fd < 0){
    255a:	02054963          	bltz	a0,258c <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    255e:	4629                	li	a2,10
    2560:	85a6                	mv	a1,s1
    2562:	00003097          	auipc	ra,0x3
    2566:	0ce080e7          	jalr	206(ra) # 5630 <read>
    256a:	862a                	mv	a2,a0
  if(n >= 0){
    256c:	02054d63          	bltz	a0,25a6 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2570:	85a6                	mv	a1,s1
    2572:	00004517          	auipc	a0,0x4
    2576:	64650513          	addi	a0,a0,1606 # 6bb8 <malloc+0x1162>
    257a:	00003097          	auipc	ra,0x3
    257e:	41e080e7          	jalr	1054(ra) # 5998 <printf>
    exit(1);
    2582:	4505                	li	a0,1
    2584:	00003097          	auipc	ra,0x3
    2588:	094080e7          	jalr	148(ra) # 5618 <exit>
    printf("open(rwsbrk) failed\n");
    258c:	00004517          	auipc	a0,0x4
    2590:	5e450513          	addi	a0,a0,1508 # 6b70 <malloc+0x111a>
    2594:	00003097          	auipc	ra,0x3
    2598:	404080e7          	jalr	1028(ra) # 5998 <printf>
    exit(1);
    259c:	4505                	li	a0,1
    259e:	00003097          	auipc	ra,0x3
    25a2:	07a080e7          	jalr	122(ra) # 5618 <exit>
  close(fd);
    25a6:	854a                	mv	a0,s2
    25a8:	00003097          	auipc	ra,0x3
    25ac:	098080e7          	jalr	152(ra) # 5640 <close>
  exit(0);
    25b0:	4501                	li	a0,0
    25b2:	00003097          	auipc	ra,0x3
    25b6:	066080e7          	jalr	102(ra) # 5618 <exit>

00000000000025ba <sbrkbasic>:
{
    25ba:	715d                	addi	sp,sp,-80
    25bc:	e486                	sd	ra,72(sp)
    25be:	e0a2                	sd	s0,64(sp)
    25c0:	fc26                	sd	s1,56(sp)
    25c2:	f84a                	sd	s2,48(sp)
    25c4:	f44e                	sd	s3,40(sp)
    25c6:	f052                	sd	s4,32(sp)
    25c8:	ec56                	sd	s5,24(sp)
    25ca:	0880                	addi	s0,sp,80
    25cc:	8a2a                	mv	s4,a0
  pid = fork();
    25ce:	00003097          	auipc	ra,0x3
    25d2:	042080e7          	jalr	66(ra) # 5610 <fork>
  if(pid < 0){
    25d6:	02054c63          	bltz	a0,260e <sbrkbasic+0x54>
  if(pid == 0){
    25da:	ed21                	bnez	a0,2632 <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    25dc:	40000537          	lui	a0,0x40000
    25e0:	00003097          	auipc	ra,0x3
    25e4:	0c0080e7          	jalr	192(ra) # 56a0 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    25e8:	57fd                	li	a5,-1
    25ea:	02f50f63          	beq	a0,a5,2628 <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25ee:	400007b7          	lui	a5,0x40000
    25f2:	97aa                	add	a5,a5,a0
      *b = 99;
    25f4:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    25f8:	6705                	lui	a4,0x1
      *b = 99;
    25fa:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1540>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25fe:	953a                	add	a0,a0,a4
    2600:	fef51de3          	bne	a0,a5,25fa <sbrkbasic+0x40>
    exit(1);
    2604:	4505                	li	a0,1
    2606:	00003097          	auipc	ra,0x3
    260a:	012080e7          	jalr	18(ra) # 5618 <exit>
    printf("fork failed in sbrkbasic\n");
    260e:	00004517          	auipc	a0,0x4
    2612:	5d250513          	addi	a0,a0,1490 # 6be0 <malloc+0x118a>
    2616:	00003097          	auipc	ra,0x3
    261a:	382080e7          	jalr	898(ra) # 5998 <printf>
    exit(1);
    261e:	4505                	li	a0,1
    2620:	00003097          	auipc	ra,0x3
    2624:	ff8080e7          	jalr	-8(ra) # 5618 <exit>
      exit(0);
    2628:	4501                	li	a0,0
    262a:	00003097          	auipc	ra,0x3
    262e:	fee080e7          	jalr	-18(ra) # 5618 <exit>
  wait(&xstatus);
    2632:	fbc40513          	addi	a0,s0,-68
    2636:	00003097          	auipc	ra,0x3
    263a:	fea080e7          	jalr	-22(ra) # 5620 <wait>
  if(xstatus == 1){
    263e:	fbc42703          	lw	a4,-68(s0)
    2642:	4785                	li	a5,1
    2644:	00f70e63          	beq	a4,a5,2660 <sbrkbasic+0xa6>
  a = sbrk(0);
    2648:	4501                	li	a0,0
    264a:	00003097          	auipc	ra,0x3
    264e:	056080e7          	jalr	86(ra) # 56a0 <sbrk>
    2652:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2654:	4901                	li	s2,0
    *b = 1;
    2656:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    2658:	6985                	lui	s3,0x1
    265a:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1d4>
    265e:	a005                	j	267e <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    2660:	85d2                	mv	a1,s4
    2662:	00004517          	auipc	a0,0x4
    2666:	59e50513          	addi	a0,a0,1438 # 6c00 <malloc+0x11aa>
    266a:	00003097          	auipc	ra,0x3
    266e:	32e080e7          	jalr	814(ra) # 5998 <printf>
    exit(1);
    2672:	4505                	li	a0,1
    2674:	00003097          	auipc	ra,0x3
    2678:	fa4080e7          	jalr	-92(ra) # 5618 <exit>
    a = b + 1;
    267c:	84be                	mv	s1,a5
    b = sbrk(1);
    267e:	4505                	li	a0,1
    2680:	00003097          	auipc	ra,0x3
    2684:	020080e7          	jalr	32(ra) # 56a0 <sbrk>
    if(b != a){
    2688:	04951b63          	bne	a0,s1,26de <sbrkbasic+0x124>
    *b = 1;
    268c:	01548023          	sb	s5,0(s1)
    a = b + 1;
    2690:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2694:	2905                	addiw	s2,s2,1
    2696:	ff3913e3          	bne	s2,s3,267c <sbrkbasic+0xc2>
  pid = fork();
    269a:	00003097          	auipc	ra,0x3
    269e:	f76080e7          	jalr	-138(ra) # 5610 <fork>
    26a2:	892a                	mv	s2,a0
  if(pid < 0){
    26a4:	04054d63          	bltz	a0,26fe <sbrkbasic+0x144>
  c = sbrk(1);
    26a8:	4505                	li	a0,1
    26aa:	00003097          	auipc	ra,0x3
    26ae:	ff6080e7          	jalr	-10(ra) # 56a0 <sbrk>
  c = sbrk(1);
    26b2:	4505                	li	a0,1
    26b4:	00003097          	auipc	ra,0x3
    26b8:	fec080e7          	jalr	-20(ra) # 56a0 <sbrk>
  if(c != a + 1){
    26bc:	0489                	addi	s1,s1,2
    26be:	04a48e63          	beq	s1,a0,271a <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    26c2:	85d2                	mv	a1,s4
    26c4:	00004517          	auipc	a0,0x4
    26c8:	59c50513          	addi	a0,a0,1436 # 6c60 <malloc+0x120a>
    26cc:	00003097          	auipc	ra,0x3
    26d0:	2cc080e7          	jalr	716(ra) # 5998 <printf>
    exit(1);
    26d4:	4505                	li	a0,1
    26d6:	00003097          	auipc	ra,0x3
    26da:	f42080e7          	jalr	-190(ra) # 5618 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    26de:	86aa                	mv	a3,a0
    26e0:	8626                	mv	a2,s1
    26e2:	85ca                	mv	a1,s2
    26e4:	00004517          	auipc	a0,0x4
    26e8:	53c50513          	addi	a0,a0,1340 # 6c20 <malloc+0x11ca>
    26ec:	00003097          	auipc	ra,0x3
    26f0:	2ac080e7          	jalr	684(ra) # 5998 <printf>
      exit(1);
    26f4:	4505                	li	a0,1
    26f6:	00003097          	auipc	ra,0x3
    26fa:	f22080e7          	jalr	-222(ra) # 5618 <exit>
    printf("%s: sbrk test fork failed\n", s);
    26fe:	85d2                	mv	a1,s4
    2700:	00004517          	auipc	a0,0x4
    2704:	54050513          	addi	a0,a0,1344 # 6c40 <malloc+0x11ea>
    2708:	00003097          	auipc	ra,0x3
    270c:	290080e7          	jalr	656(ra) # 5998 <printf>
    exit(1);
    2710:	4505                	li	a0,1
    2712:	00003097          	auipc	ra,0x3
    2716:	f06080e7          	jalr	-250(ra) # 5618 <exit>
  if(pid == 0)
    271a:	00091763          	bnez	s2,2728 <sbrkbasic+0x16e>
    exit(0);
    271e:	4501                	li	a0,0
    2720:	00003097          	auipc	ra,0x3
    2724:	ef8080e7          	jalr	-264(ra) # 5618 <exit>
  wait(&xstatus);
    2728:	fbc40513          	addi	a0,s0,-68
    272c:	00003097          	auipc	ra,0x3
    2730:	ef4080e7          	jalr	-268(ra) # 5620 <wait>
  exit(xstatus);
    2734:	fbc42503          	lw	a0,-68(s0)
    2738:	00003097          	auipc	ra,0x3
    273c:	ee0080e7          	jalr	-288(ra) # 5618 <exit>

0000000000002740 <sbrkmuch>:
{
    2740:	7179                	addi	sp,sp,-48
    2742:	f406                	sd	ra,40(sp)
    2744:	f022                	sd	s0,32(sp)
    2746:	ec26                	sd	s1,24(sp)
    2748:	e84a                	sd	s2,16(sp)
    274a:	e44e                	sd	s3,8(sp)
    274c:	e052                	sd	s4,0(sp)
    274e:	1800                	addi	s0,sp,48
    2750:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2752:	4501                	li	a0,0
    2754:	00003097          	auipc	ra,0x3
    2758:	f4c080e7          	jalr	-180(ra) # 56a0 <sbrk>
    275c:	892a                	mv	s2,a0
  a = sbrk(0);
    275e:	4501                	li	a0,0
    2760:	00003097          	auipc	ra,0x3
    2764:	f40080e7          	jalr	-192(ra) # 56a0 <sbrk>
    2768:	84aa                	mv	s1,a0
  p = sbrk(amt);
    276a:	06400537          	lui	a0,0x6400
    276e:	9d05                	subw	a0,a0,s1
    2770:	00003097          	auipc	ra,0x3
    2774:	f30080e7          	jalr	-208(ra) # 56a0 <sbrk>
  if (p != a) {
    2778:	0ca49863          	bne	s1,a0,2848 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    277c:	4501                	li	a0,0
    277e:	00003097          	auipc	ra,0x3
    2782:	f22080e7          	jalr	-222(ra) # 56a0 <sbrk>
    2786:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2788:	00a4f963          	bgeu	s1,a0,279a <sbrkmuch+0x5a>
    *pp = 1;
    278c:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    278e:	6705                	lui	a4,0x1
    *pp = 1;
    2790:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2794:	94ba                	add	s1,s1,a4
    2796:	fef4ede3          	bltu	s1,a5,2790 <sbrkmuch+0x50>
  *lastaddr = 99;
    279a:	064007b7          	lui	a5,0x6400
    279e:	06300713          	li	a4,99
    27a2:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f153f>
  a = sbrk(0);
    27a6:	4501                	li	a0,0
    27a8:	00003097          	auipc	ra,0x3
    27ac:	ef8080e7          	jalr	-264(ra) # 56a0 <sbrk>
    27b0:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    27b2:	757d                	lui	a0,0xfffff
    27b4:	00003097          	auipc	ra,0x3
    27b8:	eec080e7          	jalr	-276(ra) # 56a0 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    27bc:	57fd                	li	a5,-1
    27be:	0af50363          	beq	a0,a5,2864 <sbrkmuch+0x124>
  c = sbrk(0);
    27c2:	4501                	li	a0,0
    27c4:	00003097          	auipc	ra,0x3
    27c8:	edc080e7          	jalr	-292(ra) # 56a0 <sbrk>
  if(c != a - PGSIZE){
    27cc:	77fd                	lui	a5,0xfffff
    27ce:	97a6                	add	a5,a5,s1
    27d0:	0af51863          	bne	a0,a5,2880 <sbrkmuch+0x140>
  a = sbrk(0);
    27d4:	4501                	li	a0,0
    27d6:	00003097          	auipc	ra,0x3
    27da:	eca080e7          	jalr	-310(ra) # 56a0 <sbrk>
    27de:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    27e0:	6505                	lui	a0,0x1
    27e2:	00003097          	auipc	ra,0x3
    27e6:	ebe080e7          	jalr	-322(ra) # 56a0 <sbrk>
    27ea:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    27ec:	0aa49a63          	bne	s1,a0,28a0 <sbrkmuch+0x160>
    27f0:	4501                	li	a0,0
    27f2:	00003097          	auipc	ra,0x3
    27f6:	eae080e7          	jalr	-338(ra) # 56a0 <sbrk>
    27fa:	6785                	lui	a5,0x1
    27fc:	97a6                	add	a5,a5,s1
    27fe:	0af51163          	bne	a0,a5,28a0 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2802:	064007b7          	lui	a5,0x6400
    2806:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f153f>
    280a:	06300793          	li	a5,99
    280e:	0af70963          	beq	a4,a5,28c0 <sbrkmuch+0x180>
  a = sbrk(0);
    2812:	4501                	li	a0,0
    2814:	00003097          	auipc	ra,0x3
    2818:	e8c080e7          	jalr	-372(ra) # 56a0 <sbrk>
    281c:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    281e:	4501                	li	a0,0
    2820:	00003097          	auipc	ra,0x3
    2824:	e80080e7          	jalr	-384(ra) # 56a0 <sbrk>
    2828:	40a9053b          	subw	a0,s2,a0
    282c:	00003097          	auipc	ra,0x3
    2830:	e74080e7          	jalr	-396(ra) # 56a0 <sbrk>
  if(c != a){
    2834:	0aa49463          	bne	s1,a0,28dc <sbrkmuch+0x19c>
}
    2838:	70a2                	ld	ra,40(sp)
    283a:	7402                	ld	s0,32(sp)
    283c:	64e2                	ld	s1,24(sp)
    283e:	6942                	ld	s2,16(sp)
    2840:	69a2                	ld	s3,8(sp)
    2842:	6a02                	ld	s4,0(sp)
    2844:	6145                	addi	sp,sp,48
    2846:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2848:	85ce                	mv	a1,s3
    284a:	00004517          	auipc	a0,0x4
    284e:	43650513          	addi	a0,a0,1078 # 6c80 <malloc+0x122a>
    2852:	00003097          	auipc	ra,0x3
    2856:	146080e7          	jalr	326(ra) # 5998 <printf>
    exit(1);
    285a:	4505                	li	a0,1
    285c:	00003097          	auipc	ra,0x3
    2860:	dbc080e7          	jalr	-580(ra) # 5618 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2864:	85ce                	mv	a1,s3
    2866:	00004517          	auipc	a0,0x4
    286a:	46250513          	addi	a0,a0,1122 # 6cc8 <malloc+0x1272>
    286e:	00003097          	auipc	ra,0x3
    2872:	12a080e7          	jalr	298(ra) # 5998 <printf>
    exit(1);
    2876:	4505                	li	a0,1
    2878:	00003097          	auipc	ra,0x3
    287c:	da0080e7          	jalr	-608(ra) # 5618 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2880:	86aa                	mv	a3,a0
    2882:	8626                	mv	a2,s1
    2884:	85ce                	mv	a1,s3
    2886:	00004517          	auipc	a0,0x4
    288a:	46250513          	addi	a0,a0,1122 # 6ce8 <malloc+0x1292>
    288e:	00003097          	auipc	ra,0x3
    2892:	10a080e7          	jalr	266(ra) # 5998 <printf>
    exit(1);
    2896:	4505                	li	a0,1
    2898:	00003097          	auipc	ra,0x3
    289c:	d80080e7          	jalr	-640(ra) # 5618 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    28a0:	86d2                	mv	a3,s4
    28a2:	8626                	mv	a2,s1
    28a4:	85ce                	mv	a1,s3
    28a6:	00004517          	auipc	a0,0x4
    28aa:	48250513          	addi	a0,a0,1154 # 6d28 <malloc+0x12d2>
    28ae:	00003097          	auipc	ra,0x3
    28b2:	0ea080e7          	jalr	234(ra) # 5998 <printf>
    exit(1);
    28b6:	4505                	li	a0,1
    28b8:	00003097          	auipc	ra,0x3
    28bc:	d60080e7          	jalr	-672(ra) # 5618 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    28c0:	85ce                	mv	a1,s3
    28c2:	00004517          	auipc	a0,0x4
    28c6:	49650513          	addi	a0,a0,1174 # 6d58 <malloc+0x1302>
    28ca:	00003097          	auipc	ra,0x3
    28ce:	0ce080e7          	jalr	206(ra) # 5998 <printf>
    exit(1);
    28d2:	4505                	li	a0,1
    28d4:	00003097          	auipc	ra,0x3
    28d8:	d44080e7          	jalr	-700(ra) # 5618 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    28dc:	86aa                	mv	a3,a0
    28de:	8626                	mv	a2,s1
    28e0:	85ce                	mv	a1,s3
    28e2:	00004517          	auipc	a0,0x4
    28e6:	4ae50513          	addi	a0,a0,1198 # 6d90 <malloc+0x133a>
    28ea:	00003097          	auipc	ra,0x3
    28ee:	0ae080e7          	jalr	174(ra) # 5998 <printf>
    exit(1);
    28f2:	4505                	li	a0,1
    28f4:	00003097          	auipc	ra,0x3
    28f8:	d24080e7          	jalr	-732(ra) # 5618 <exit>

00000000000028fc <sbrkarg>:
{
    28fc:	7179                	addi	sp,sp,-48
    28fe:	f406                	sd	ra,40(sp)
    2900:	f022                	sd	s0,32(sp)
    2902:	ec26                	sd	s1,24(sp)
    2904:	e84a                	sd	s2,16(sp)
    2906:	e44e                	sd	s3,8(sp)
    2908:	1800                	addi	s0,sp,48
    290a:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    290c:	6505                	lui	a0,0x1
    290e:	00003097          	auipc	ra,0x3
    2912:	d92080e7          	jalr	-622(ra) # 56a0 <sbrk>
    2916:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2918:	20100593          	li	a1,513
    291c:	00004517          	auipc	a0,0x4
    2920:	49c50513          	addi	a0,a0,1180 # 6db8 <malloc+0x1362>
    2924:	00003097          	auipc	ra,0x3
    2928:	d34080e7          	jalr	-716(ra) # 5658 <open>
    292c:	84aa                	mv	s1,a0
  unlink("sbrk");
    292e:	00004517          	auipc	a0,0x4
    2932:	48a50513          	addi	a0,a0,1162 # 6db8 <malloc+0x1362>
    2936:	00003097          	auipc	ra,0x3
    293a:	d32080e7          	jalr	-718(ra) # 5668 <unlink>
  if(fd < 0)  {
    293e:	0404c163          	bltz	s1,2980 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2942:	6605                	lui	a2,0x1
    2944:	85ca                	mv	a1,s2
    2946:	8526                	mv	a0,s1
    2948:	00003097          	auipc	ra,0x3
    294c:	cf0080e7          	jalr	-784(ra) # 5638 <write>
    2950:	04054663          	bltz	a0,299c <sbrkarg+0xa0>
  close(fd);
    2954:	8526                	mv	a0,s1
    2956:	00003097          	auipc	ra,0x3
    295a:	cea080e7          	jalr	-790(ra) # 5640 <close>
  a = sbrk(PGSIZE);
    295e:	6505                	lui	a0,0x1
    2960:	00003097          	auipc	ra,0x3
    2964:	d40080e7          	jalr	-704(ra) # 56a0 <sbrk>
  if(pipe((int *) a) != 0){
    2968:	00003097          	auipc	ra,0x3
    296c:	cc0080e7          	jalr	-832(ra) # 5628 <pipe>
    2970:	e521                	bnez	a0,29b8 <sbrkarg+0xbc>
}
    2972:	70a2                	ld	ra,40(sp)
    2974:	7402                	ld	s0,32(sp)
    2976:	64e2                	ld	s1,24(sp)
    2978:	6942                	ld	s2,16(sp)
    297a:	69a2                	ld	s3,8(sp)
    297c:	6145                	addi	sp,sp,48
    297e:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2980:	85ce                	mv	a1,s3
    2982:	00004517          	auipc	a0,0x4
    2986:	43e50513          	addi	a0,a0,1086 # 6dc0 <malloc+0x136a>
    298a:	00003097          	auipc	ra,0x3
    298e:	00e080e7          	jalr	14(ra) # 5998 <printf>
    exit(1);
    2992:	4505                	li	a0,1
    2994:	00003097          	auipc	ra,0x3
    2998:	c84080e7          	jalr	-892(ra) # 5618 <exit>
    printf("%s: write sbrk failed\n", s);
    299c:	85ce                	mv	a1,s3
    299e:	00004517          	auipc	a0,0x4
    29a2:	43a50513          	addi	a0,a0,1082 # 6dd8 <malloc+0x1382>
    29a6:	00003097          	auipc	ra,0x3
    29aa:	ff2080e7          	jalr	-14(ra) # 5998 <printf>
    exit(1);
    29ae:	4505                	li	a0,1
    29b0:	00003097          	auipc	ra,0x3
    29b4:	c68080e7          	jalr	-920(ra) # 5618 <exit>
    printf("%s: pipe() failed\n", s);
    29b8:	85ce                	mv	a1,s3
    29ba:	00004517          	auipc	a0,0x4
    29be:	e1e50513          	addi	a0,a0,-482 # 67d8 <malloc+0xd82>
    29c2:	00003097          	auipc	ra,0x3
    29c6:	fd6080e7          	jalr	-42(ra) # 5998 <printf>
    exit(1);
    29ca:	4505                	li	a0,1
    29cc:	00003097          	auipc	ra,0x3
    29d0:	c4c080e7          	jalr	-948(ra) # 5618 <exit>

00000000000029d4 <argptest>:
{
    29d4:	1101                	addi	sp,sp,-32
    29d6:	ec06                	sd	ra,24(sp)
    29d8:	e822                	sd	s0,16(sp)
    29da:	e426                	sd	s1,8(sp)
    29dc:	e04a                	sd	s2,0(sp)
    29de:	1000                	addi	s0,sp,32
    29e0:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    29e2:	4581                	li	a1,0
    29e4:	00004517          	auipc	a0,0x4
    29e8:	40c50513          	addi	a0,a0,1036 # 6df0 <malloc+0x139a>
    29ec:	00003097          	auipc	ra,0x3
    29f0:	c6c080e7          	jalr	-916(ra) # 5658 <open>
  if (fd < 0) {
    29f4:	02054b63          	bltz	a0,2a2a <argptest+0x56>
    29f8:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    29fa:	4501                	li	a0,0
    29fc:	00003097          	auipc	ra,0x3
    2a00:	ca4080e7          	jalr	-860(ra) # 56a0 <sbrk>
    2a04:	567d                	li	a2,-1
    2a06:	fff50593          	addi	a1,a0,-1
    2a0a:	8526                	mv	a0,s1
    2a0c:	00003097          	auipc	ra,0x3
    2a10:	c24080e7          	jalr	-988(ra) # 5630 <read>
  close(fd);
    2a14:	8526                	mv	a0,s1
    2a16:	00003097          	auipc	ra,0x3
    2a1a:	c2a080e7          	jalr	-982(ra) # 5640 <close>
}
    2a1e:	60e2                	ld	ra,24(sp)
    2a20:	6442                	ld	s0,16(sp)
    2a22:	64a2                	ld	s1,8(sp)
    2a24:	6902                	ld	s2,0(sp)
    2a26:	6105                	addi	sp,sp,32
    2a28:	8082                	ret
    printf("%s: open failed\n", s);
    2a2a:	85ca                	mv	a1,s2
    2a2c:	00004517          	auipc	a0,0x4
    2a30:	cbc50513          	addi	a0,a0,-836 # 66e8 <malloc+0xc92>
    2a34:	00003097          	auipc	ra,0x3
    2a38:	f64080e7          	jalr	-156(ra) # 5998 <printf>
    exit(1);
    2a3c:	4505                	li	a0,1
    2a3e:	00003097          	auipc	ra,0x3
    2a42:	bda080e7          	jalr	-1062(ra) # 5618 <exit>

0000000000002a46 <sbrkbugs>:
{
    2a46:	1141                	addi	sp,sp,-16
    2a48:	e406                	sd	ra,8(sp)
    2a4a:	e022                	sd	s0,0(sp)
    2a4c:	0800                	addi	s0,sp,16
  int pid = fork();
    2a4e:	00003097          	auipc	ra,0x3
    2a52:	bc2080e7          	jalr	-1086(ra) # 5610 <fork>
  if(pid < 0){
    2a56:	02054263          	bltz	a0,2a7a <sbrkbugs+0x34>
  if(pid == 0){
    2a5a:	ed0d                	bnez	a0,2a94 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2a5c:	00003097          	auipc	ra,0x3
    2a60:	c44080e7          	jalr	-956(ra) # 56a0 <sbrk>
    sbrk(-sz);
    2a64:	40a0053b          	negw	a0,a0
    2a68:	00003097          	auipc	ra,0x3
    2a6c:	c38080e7          	jalr	-968(ra) # 56a0 <sbrk>
    exit(0);
    2a70:	4501                	li	a0,0
    2a72:	00003097          	auipc	ra,0x3
    2a76:	ba6080e7          	jalr	-1114(ra) # 5618 <exit>
    printf("fork failed\n");
    2a7a:	00004517          	auipc	a0,0x4
    2a7e:	05e50513          	addi	a0,a0,94 # 6ad8 <malloc+0x1082>
    2a82:	00003097          	auipc	ra,0x3
    2a86:	f16080e7          	jalr	-234(ra) # 5998 <printf>
    exit(1);
    2a8a:	4505                	li	a0,1
    2a8c:	00003097          	auipc	ra,0x3
    2a90:	b8c080e7          	jalr	-1140(ra) # 5618 <exit>
  wait(0);
    2a94:	4501                	li	a0,0
    2a96:	00003097          	auipc	ra,0x3
    2a9a:	b8a080e7          	jalr	-1142(ra) # 5620 <wait>
  pid = fork();
    2a9e:	00003097          	auipc	ra,0x3
    2aa2:	b72080e7          	jalr	-1166(ra) # 5610 <fork>
  if(pid < 0){
    2aa6:	02054563          	bltz	a0,2ad0 <sbrkbugs+0x8a>
  if(pid == 0){
    2aaa:	e121                	bnez	a0,2aea <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2aac:	00003097          	auipc	ra,0x3
    2ab0:	bf4080e7          	jalr	-1036(ra) # 56a0 <sbrk>
    sbrk(-(sz - 3500));
    2ab4:	6785                	lui	a5,0x1
    2ab6:	dac7879b          	addiw	a5,a5,-596
    2aba:	40a7853b          	subw	a0,a5,a0
    2abe:	00003097          	auipc	ra,0x3
    2ac2:	be2080e7          	jalr	-1054(ra) # 56a0 <sbrk>
    exit(0);
    2ac6:	4501                	li	a0,0
    2ac8:	00003097          	auipc	ra,0x3
    2acc:	b50080e7          	jalr	-1200(ra) # 5618 <exit>
    printf("fork failed\n");
    2ad0:	00004517          	auipc	a0,0x4
    2ad4:	00850513          	addi	a0,a0,8 # 6ad8 <malloc+0x1082>
    2ad8:	00003097          	auipc	ra,0x3
    2adc:	ec0080e7          	jalr	-320(ra) # 5998 <printf>
    exit(1);
    2ae0:	4505                	li	a0,1
    2ae2:	00003097          	auipc	ra,0x3
    2ae6:	b36080e7          	jalr	-1226(ra) # 5618 <exit>
  wait(0);
    2aea:	4501                	li	a0,0
    2aec:	00003097          	auipc	ra,0x3
    2af0:	b34080e7          	jalr	-1228(ra) # 5620 <wait>
  pid = fork();
    2af4:	00003097          	auipc	ra,0x3
    2af8:	b1c080e7          	jalr	-1252(ra) # 5610 <fork>
  if(pid < 0){
    2afc:	02054a63          	bltz	a0,2b30 <sbrkbugs+0xea>
  if(pid == 0){
    2b00:	e529                	bnez	a0,2b4a <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2b02:	00003097          	auipc	ra,0x3
    2b06:	b9e080e7          	jalr	-1122(ra) # 56a0 <sbrk>
    2b0a:	67ad                	lui	a5,0xb
    2b0c:	8007879b          	addiw	a5,a5,-2048
    2b10:	40a7853b          	subw	a0,a5,a0
    2b14:	00003097          	auipc	ra,0x3
    2b18:	b8c080e7          	jalr	-1140(ra) # 56a0 <sbrk>
    sbrk(-10);
    2b1c:	5559                	li	a0,-10
    2b1e:	00003097          	auipc	ra,0x3
    2b22:	b82080e7          	jalr	-1150(ra) # 56a0 <sbrk>
    exit(0);
    2b26:	4501                	li	a0,0
    2b28:	00003097          	auipc	ra,0x3
    2b2c:	af0080e7          	jalr	-1296(ra) # 5618 <exit>
    printf("fork failed\n");
    2b30:	00004517          	auipc	a0,0x4
    2b34:	fa850513          	addi	a0,a0,-88 # 6ad8 <malloc+0x1082>
    2b38:	00003097          	auipc	ra,0x3
    2b3c:	e60080e7          	jalr	-416(ra) # 5998 <printf>
    exit(1);
    2b40:	4505                	li	a0,1
    2b42:	00003097          	auipc	ra,0x3
    2b46:	ad6080e7          	jalr	-1322(ra) # 5618 <exit>
  wait(0);
    2b4a:	4501                	li	a0,0
    2b4c:	00003097          	auipc	ra,0x3
    2b50:	ad4080e7          	jalr	-1324(ra) # 5620 <wait>
  exit(0);
    2b54:	4501                	li	a0,0
    2b56:	00003097          	auipc	ra,0x3
    2b5a:	ac2080e7          	jalr	-1342(ra) # 5618 <exit>

0000000000002b5e <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2b5e:	715d                	addi	sp,sp,-80
    2b60:	e486                	sd	ra,72(sp)
    2b62:	e0a2                	sd	s0,64(sp)
    2b64:	fc26                	sd	s1,56(sp)
    2b66:	f84a                	sd	s2,48(sp)
    2b68:	f44e                	sd	s3,40(sp)
    2b6a:	f052                	sd	s4,32(sp)
    2b6c:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2b6e:	4901                	li	s2,0
    2b70:	49bd                	li	s3,15
    int pid = fork();
    2b72:	00003097          	auipc	ra,0x3
    2b76:	a9e080e7          	jalr	-1378(ra) # 5610 <fork>
    2b7a:	84aa                	mv	s1,a0
    if(pid < 0){
    2b7c:	02054063          	bltz	a0,2b9c <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2b80:	c91d                	beqz	a0,2bb6 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2b82:	4501                	li	a0,0
    2b84:	00003097          	auipc	ra,0x3
    2b88:	a9c080e7          	jalr	-1380(ra) # 5620 <wait>
  for(int avail = 0; avail < 15; avail++){
    2b8c:	2905                	addiw	s2,s2,1
    2b8e:	ff3912e3          	bne	s2,s3,2b72 <execout+0x14>
    }
  }

  exit(0);
    2b92:	4501                	li	a0,0
    2b94:	00003097          	auipc	ra,0x3
    2b98:	a84080e7          	jalr	-1404(ra) # 5618 <exit>
      printf("fork failed\n");
    2b9c:	00004517          	auipc	a0,0x4
    2ba0:	f3c50513          	addi	a0,a0,-196 # 6ad8 <malloc+0x1082>
    2ba4:	00003097          	auipc	ra,0x3
    2ba8:	df4080e7          	jalr	-524(ra) # 5998 <printf>
      exit(1);
    2bac:	4505                	li	a0,1
    2bae:	00003097          	auipc	ra,0x3
    2bb2:	a6a080e7          	jalr	-1430(ra) # 5618 <exit>
        if(a == 0xffffffffffffffffLL)
    2bb6:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2bb8:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2bba:	6505                	lui	a0,0x1
    2bbc:	00003097          	auipc	ra,0x3
    2bc0:	ae4080e7          	jalr	-1308(ra) # 56a0 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2bc4:	01350763          	beq	a0,s3,2bd2 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2bc8:	6785                	lui	a5,0x1
    2bca:	953e                	add	a0,a0,a5
    2bcc:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x9b>
      while(1){
    2bd0:	b7ed                	j	2bba <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2bd2:	01205a63          	blez	s2,2be6 <execout+0x88>
        sbrk(-4096);
    2bd6:	757d                	lui	a0,0xfffff
    2bd8:	00003097          	auipc	ra,0x3
    2bdc:	ac8080e7          	jalr	-1336(ra) # 56a0 <sbrk>
      for(int i = 0; i < avail; i++)
    2be0:	2485                	addiw	s1,s1,1
    2be2:	ff249ae3          	bne	s1,s2,2bd6 <execout+0x78>
      close(1);
    2be6:	4505                	li	a0,1
    2be8:	00003097          	auipc	ra,0x3
    2bec:	a58080e7          	jalr	-1448(ra) # 5640 <close>
      char *args[] = { "echo", "x", 0 };
    2bf0:	00003517          	auipc	a0,0x3
    2bf4:	2a850513          	addi	a0,a0,680 # 5e98 <malloc+0x442>
    2bf8:	faa43c23          	sd	a0,-72(s0)
    2bfc:	00003797          	auipc	a5,0x3
    2c00:	30c78793          	addi	a5,a5,780 # 5f08 <malloc+0x4b2>
    2c04:	fcf43023          	sd	a5,-64(s0)
    2c08:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2c0c:	fb840593          	addi	a1,s0,-72
    2c10:	00003097          	auipc	ra,0x3
    2c14:	a40080e7          	jalr	-1472(ra) # 5650 <exec>
      exit(0);
    2c18:	4501                	li	a0,0
    2c1a:	00003097          	auipc	ra,0x3
    2c1e:	9fe080e7          	jalr	-1538(ra) # 5618 <exit>

0000000000002c22 <fourteen>:
{
    2c22:	1101                	addi	sp,sp,-32
    2c24:	ec06                	sd	ra,24(sp)
    2c26:	e822                	sd	s0,16(sp)
    2c28:	e426                	sd	s1,8(sp)
    2c2a:	1000                	addi	s0,sp,32
    2c2c:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2c2e:	00004517          	auipc	a0,0x4
    2c32:	39a50513          	addi	a0,a0,922 # 6fc8 <malloc+0x1572>
    2c36:	00003097          	auipc	ra,0x3
    2c3a:	a4a080e7          	jalr	-1462(ra) # 5680 <mkdir>
    2c3e:	e165                	bnez	a0,2d1e <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2c40:	00004517          	auipc	a0,0x4
    2c44:	1e050513          	addi	a0,a0,480 # 6e20 <malloc+0x13ca>
    2c48:	00003097          	auipc	ra,0x3
    2c4c:	a38080e7          	jalr	-1480(ra) # 5680 <mkdir>
    2c50:	e56d                	bnez	a0,2d3a <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2c52:	20000593          	li	a1,512
    2c56:	00004517          	auipc	a0,0x4
    2c5a:	22250513          	addi	a0,a0,546 # 6e78 <malloc+0x1422>
    2c5e:	00003097          	auipc	ra,0x3
    2c62:	9fa080e7          	jalr	-1542(ra) # 5658 <open>
  if(fd < 0){
    2c66:	0e054863          	bltz	a0,2d56 <fourteen+0x134>
  close(fd);
    2c6a:	00003097          	auipc	ra,0x3
    2c6e:	9d6080e7          	jalr	-1578(ra) # 5640 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2c72:	4581                	li	a1,0
    2c74:	00004517          	auipc	a0,0x4
    2c78:	27c50513          	addi	a0,a0,636 # 6ef0 <malloc+0x149a>
    2c7c:	00003097          	auipc	ra,0x3
    2c80:	9dc080e7          	jalr	-1572(ra) # 5658 <open>
  if(fd < 0){
    2c84:	0e054763          	bltz	a0,2d72 <fourteen+0x150>
  close(fd);
    2c88:	00003097          	auipc	ra,0x3
    2c8c:	9b8080e7          	jalr	-1608(ra) # 5640 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2c90:	00004517          	auipc	a0,0x4
    2c94:	2d050513          	addi	a0,a0,720 # 6f60 <malloc+0x150a>
    2c98:	00003097          	auipc	ra,0x3
    2c9c:	9e8080e7          	jalr	-1560(ra) # 5680 <mkdir>
    2ca0:	c57d                	beqz	a0,2d8e <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2ca2:	00004517          	auipc	a0,0x4
    2ca6:	31650513          	addi	a0,a0,790 # 6fb8 <malloc+0x1562>
    2caa:	00003097          	auipc	ra,0x3
    2cae:	9d6080e7          	jalr	-1578(ra) # 5680 <mkdir>
    2cb2:	cd65                	beqz	a0,2daa <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2cb4:	00004517          	auipc	a0,0x4
    2cb8:	30450513          	addi	a0,a0,772 # 6fb8 <malloc+0x1562>
    2cbc:	00003097          	auipc	ra,0x3
    2cc0:	9ac080e7          	jalr	-1620(ra) # 5668 <unlink>
  unlink("12345678901234/12345678901234");
    2cc4:	00004517          	auipc	a0,0x4
    2cc8:	29c50513          	addi	a0,a0,668 # 6f60 <malloc+0x150a>
    2ccc:	00003097          	auipc	ra,0x3
    2cd0:	99c080e7          	jalr	-1636(ra) # 5668 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2cd4:	00004517          	auipc	a0,0x4
    2cd8:	21c50513          	addi	a0,a0,540 # 6ef0 <malloc+0x149a>
    2cdc:	00003097          	auipc	ra,0x3
    2ce0:	98c080e7          	jalr	-1652(ra) # 5668 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2ce4:	00004517          	auipc	a0,0x4
    2ce8:	19450513          	addi	a0,a0,404 # 6e78 <malloc+0x1422>
    2cec:	00003097          	auipc	ra,0x3
    2cf0:	97c080e7          	jalr	-1668(ra) # 5668 <unlink>
  unlink("12345678901234/123456789012345");
    2cf4:	00004517          	auipc	a0,0x4
    2cf8:	12c50513          	addi	a0,a0,300 # 6e20 <malloc+0x13ca>
    2cfc:	00003097          	auipc	ra,0x3
    2d00:	96c080e7          	jalr	-1684(ra) # 5668 <unlink>
  unlink("12345678901234");
    2d04:	00004517          	auipc	a0,0x4
    2d08:	2c450513          	addi	a0,a0,708 # 6fc8 <malloc+0x1572>
    2d0c:	00003097          	auipc	ra,0x3
    2d10:	95c080e7          	jalr	-1700(ra) # 5668 <unlink>
}
    2d14:	60e2                	ld	ra,24(sp)
    2d16:	6442                	ld	s0,16(sp)
    2d18:	64a2                	ld	s1,8(sp)
    2d1a:	6105                	addi	sp,sp,32
    2d1c:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2d1e:	85a6                	mv	a1,s1
    2d20:	00004517          	auipc	a0,0x4
    2d24:	0d850513          	addi	a0,a0,216 # 6df8 <malloc+0x13a2>
    2d28:	00003097          	auipc	ra,0x3
    2d2c:	c70080e7          	jalr	-912(ra) # 5998 <printf>
    exit(1);
    2d30:	4505                	li	a0,1
    2d32:	00003097          	auipc	ra,0x3
    2d36:	8e6080e7          	jalr	-1818(ra) # 5618 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2d3a:	85a6                	mv	a1,s1
    2d3c:	00004517          	auipc	a0,0x4
    2d40:	10450513          	addi	a0,a0,260 # 6e40 <malloc+0x13ea>
    2d44:	00003097          	auipc	ra,0x3
    2d48:	c54080e7          	jalr	-940(ra) # 5998 <printf>
    exit(1);
    2d4c:	4505                	li	a0,1
    2d4e:	00003097          	auipc	ra,0x3
    2d52:	8ca080e7          	jalr	-1846(ra) # 5618 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2d56:	85a6                	mv	a1,s1
    2d58:	00004517          	auipc	a0,0x4
    2d5c:	15050513          	addi	a0,a0,336 # 6ea8 <malloc+0x1452>
    2d60:	00003097          	auipc	ra,0x3
    2d64:	c38080e7          	jalr	-968(ra) # 5998 <printf>
    exit(1);
    2d68:	4505                	li	a0,1
    2d6a:	00003097          	auipc	ra,0x3
    2d6e:	8ae080e7          	jalr	-1874(ra) # 5618 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2d72:	85a6                	mv	a1,s1
    2d74:	00004517          	auipc	a0,0x4
    2d78:	1ac50513          	addi	a0,a0,428 # 6f20 <malloc+0x14ca>
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	c1c080e7          	jalr	-996(ra) # 5998 <printf>
    exit(1);
    2d84:	4505                	li	a0,1
    2d86:	00003097          	auipc	ra,0x3
    2d8a:	892080e7          	jalr	-1902(ra) # 5618 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2d8e:	85a6                	mv	a1,s1
    2d90:	00004517          	auipc	a0,0x4
    2d94:	1f050513          	addi	a0,a0,496 # 6f80 <malloc+0x152a>
    2d98:	00003097          	auipc	ra,0x3
    2d9c:	c00080e7          	jalr	-1024(ra) # 5998 <printf>
    exit(1);
    2da0:	4505                	li	a0,1
    2da2:	00003097          	auipc	ra,0x3
    2da6:	876080e7          	jalr	-1930(ra) # 5618 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2daa:	85a6                	mv	a1,s1
    2dac:	00004517          	auipc	a0,0x4
    2db0:	22c50513          	addi	a0,a0,556 # 6fd8 <malloc+0x1582>
    2db4:	00003097          	auipc	ra,0x3
    2db8:	be4080e7          	jalr	-1052(ra) # 5998 <printf>
    exit(1);
    2dbc:	4505                	li	a0,1
    2dbe:	00003097          	auipc	ra,0x3
    2dc2:	85a080e7          	jalr	-1958(ra) # 5618 <exit>

0000000000002dc6 <iputtest>:
{
    2dc6:	1101                	addi	sp,sp,-32
    2dc8:	ec06                	sd	ra,24(sp)
    2dca:	e822                	sd	s0,16(sp)
    2dcc:	e426                	sd	s1,8(sp)
    2dce:	1000                	addi	s0,sp,32
    2dd0:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2dd2:	00004517          	auipc	a0,0x4
    2dd6:	23e50513          	addi	a0,a0,574 # 7010 <malloc+0x15ba>
    2dda:	00003097          	auipc	ra,0x3
    2dde:	8a6080e7          	jalr	-1882(ra) # 5680 <mkdir>
    2de2:	04054563          	bltz	a0,2e2c <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2de6:	00004517          	auipc	a0,0x4
    2dea:	22a50513          	addi	a0,a0,554 # 7010 <malloc+0x15ba>
    2dee:	00003097          	auipc	ra,0x3
    2df2:	89a080e7          	jalr	-1894(ra) # 5688 <chdir>
    2df6:	04054963          	bltz	a0,2e48 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2dfa:	00004517          	auipc	a0,0x4
    2dfe:	25650513          	addi	a0,a0,598 # 7050 <malloc+0x15fa>
    2e02:	00003097          	auipc	ra,0x3
    2e06:	866080e7          	jalr	-1946(ra) # 5668 <unlink>
    2e0a:	04054d63          	bltz	a0,2e64 <iputtest+0x9e>
  if(chdir("/") < 0){
    2e0e:	00004517          	auipc	a0,0x4
    2e12:	27250513          	addi	a0,a0,626 # 7080 <malloc+0x162a>
    2e16:	00003097          	auipc	ra,0x3
    2e1a:	872080e7          	jalr	-1934(ra) # 5688 <chdir>
    2e1e:	06054163          	bltz	a0,2e80 <iputtest+0xba>
}
    2e22:	60e2                	ld	ra,24(sp)
    2e24:	6442                	ld	s0,16(sp)
    2e26:	64a2                	ld	s1,8(sp)
    2e28:	6105                	addi	sp,sp,32
    2e2a:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2e2c:	85a6                	mv	a1,s1
    2e2e:	00004517          	auipc	a0,0x4
    2e32:	1ea50513          	addi	a0,a0,490 # 7018 <malloc+0x15c2>
    2e36:	00003097          	auipc	ra,0x3
    2e3a:	b62080e7          	jalr	-1182(ra) # 5998 <printf>
    exit(1);
    2e3e:	4505                	li	a0,1
    2e40:	00002097          	auipc	ra,0x2
    2e44:	7d8080e7          	jalr	2008(ra) # 5618 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2e48:	85a6                	mv	a1,s1
    2e4a:	00004517          	auipc	a0,0x4
    2e4e:	1e650513          	addi	a0,a0,486 # 7030 <malloc+0x15da>
    2e52:	00003097          	auipc	ra,0x3
    2e56:	b46080e7          	jalr	-1210(ra) # 5998 <printf>
    exit(1);
    2e5a:	4505                	li	a0,1
    2e5c:	00002097          	auipc	ra,0x2
    2e60:	7bc080e7          	jalr	1980(ra) # 5618 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2e64:	85a6                	mv	a1,s1
    2e66:	00004517          	auipc	a0,0x4
    2e6a:	1fa50513          	addi	a0,a0,506 # 7060 <malloc+0x160a>
    2e6e:	00003097          	auipc	ra,0x3
    2e72:	b2a080e7          	jalr	-1238(ra) # 5998 <printf>
    exit(1);
    2e76:	4505                	li	a0,1
    2e78:	00002097          	auipc	ra,0x2
    2e7c:	7a0080e7          	jalr	1952(ra) # 5618 <exit>
    printf("%s: chdir / failed\n", s);
    2e80:	85a6                	mv	a1,s1
    2e82:	00004517          	auipc	a0,0x4
    2e86:	20650513          	addi	a0,a0,518 # 7088 <malloc+0x1632>
    2e8a:	00003097          	auipc	ra,0x3
    2e8e:	b0e080e7          	jalr	-1266(ra) # 5998 <printf>
    exit(1);
    2e92:	4505                	li	a0,1
    2e94:	00002097          	auipc	ra,0x2
    2e98:	784080e7          	jalr	1924(ra) # 5618 <exit>

0000000000002e9c <exitiputtest>:
{
    2e9c:	7179                	addi	sp,sp,-48
    2e9e:	f406                	sd	ra,40(sp)
    2ea0:	f022                	sd	s0,32(sp)
    2ea2:	ec26                	sd	s1,24(sp)
    2ea4:	1800                	addi	s0,sp,48
    2ea6:	84aa                	mv	s1,a0
  pid = fork();
    2ea8:	00002097          	auipc	ra,0x2
    2eac:	768080e7          	jalr	1896(ra) # 5610 <fork>
  if(pid < 0){
    2eb0:	04054663          	bltz	a0,2efc <exitiputtest+0x60>
  if(pid == 0){
    2eb4:	ed45                	bnez	a0,2f6c <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2eb6:	00004517          	auipc	a0,0x4
    2eba:	15a50513          	addi	a0,a0,346 # 7010 <malloc+0x15ba>
    2ebe:	00002097          	auipc	ra,0x2
    2ec2:	7c2080e7          	jalr	1986(ra) # 5680 <mkdir>
    2ec6:	04054963          	bltz	a0,2f18 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2eca:	00004517          	auipc	a0,0x4
    2ece:	14650513          	addi	a0,a0,326 # 7010 <malloc+0x15ba>
    2ed2:	00002097          	auipc	ra,0x2
    2ed6:	7b6080e7          	jalr	1974(ra) # 5688 <chdir>
    2eda:	04054d63          	bltz	a0,2f34 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2ede:	00004517          	auipc	a0,0x4
    2ee2:	17250513          	addi	a0,a0,370 # 7050 <malloc+0x15fa>
    2ee6:	00002097          	auipc	ra,0x2
    2eea:	782080e7          	jalr	1922(ra) # 5668 <unlink>
    2eee:	06054163          	bltz	a0,2f50 <exitiputtest+0xb4>
    exit(0);
    2ef2:	4501                	li	a0,0
    2ef4:	00002097          	auipc	ra,0x2
    2ef8:	724080e7          	jalr	1828(ra) # 5618 <exit>
    printf("%s: fork failed\n", s);
    2efc:	85a6                	mv	a1,s1
    2efe:	00003517          	auipc	a0,0x3
    2f02:	7d250513          	addi	a0,a0,2002 # 66d0 <malloc+0xc7a>
    2f06:	00003097          	auipc	ra,0x3
    2f0a:	a92080e7          	jalr	-1390(ra) # 5998 <printf>
    exit(1);
    2f0e:	4505                	li	a0,1
    2f10:	00002097          	auipc	ra,0x2
    2f14:	708080e7          	jalr	1800(ra) # 5618 <exit>
      printf("%s: mkdir failed\n", s);
    2f18:	85a6                	mv	a1,s1
    2f1a:	00004517          	auipc	a0,0x4
    2f1e:	0fe50513          	addi	a0,a0,254 # 7018 <malloc+0x15c2>
    2f22:	00003097          	auipc	ra,0x3
    2f26:	a76080e7          	jalr	-1418(ra) # 5998 <printf>
      exit(1);
    2f2a:	4505                	li	a0,1
    2f2c:	00002097          	auipc	ra,0x2
    2f30:	6ec080e7          	jalr	1772(ra) # 5618 <exit>
      printf("%s: child chdir failed\n", s);
    2f34:	85a6                	mv	a1,s1
    2f36:	00004517          	auipc	a0,0x4
    2f3a:	16a50513          	addi	a0,a0,362 # 70a0 <malloc+0x164a>
    2f3e:	00003097          	auipc	ra,0x3
    2f42:	a5a080e7          	jalr	-1446(ra) # 5998 <printf>
      exit(1);
    2f46:	4505                	li	a0,1
    2f48:	00002097          	auipc	ra,0x2
    2f4c:	6d0080e7          	jalr	1744(ra) # 5618 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2f50:	85a6                	mv	a1,s1
    2f52:	00004517          	auipc	a0,0x4
    2f56:	10e50513          	addi	a0,a0,270 # 7060 <malloc+0x160a>
    2f5a:	00003097          	auipc	ra,0x3
    2f5e:	a3e080e7          	jalr	-1474(ra) # 5998 <printf>
      exit(1);
    2f62:	4505                	li	a0,1
    2f64:	00002097          	auipc	ra,0x2
    2f68:	6b4080e7          	jalr	1716(ra) # 5618 <exit>
  wait(&xstatus);
    2f6c:	fdc40513          	addi	a0,s0,-36
    2f70:	00002097          	auipc	ra,0x2
    2f74:	6b0080e7          	jalr	1712(ra) # 5620 <wait>
  exit(xstatus);
    2f78:	fdc42503          	lw	a0,-36(s0)
    2f7c:	00002097          	auipc	ra,0x2
    2f80:	69c080e7          	jalr	1692(ra) # 5618 <exit>

0000000000002f84 <dirtest>:
{
    2f84:	1101                	addi	sp,sp,-32
    2f86:	ec06                	sd	ra,24(sp)
    2f88:	e822                	sd	s0,16(sp)
    2f8a:	e426                	sd	s1,8(sp)
    2f8c:	1000                	addi	s0,sp,32
    2f8e:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2f90:	00004517          	auipc	a0,0x4
    2f94:	12850513          	addi	a0,a0,296 # 70b8 <malloc+0x1662>
    2f98:	00002097          	auipc	ra,0x2
    2f9c:	6e8080e7          	jalr	1768(ra) # 5680 <mkdir>
    2fa0:	04054563          	bltz	a0,2fea <dirtest+0x66>
  if(chdir("dir0") < 0){
    2fa4:	00004517          	auipc	a0,0x4
    2fa8:	11450513          	addi	a0,a0,276 # 70b8 <malloc+0x1662>
    2fac:	00002097          	auipc	ra,0x2
    2fb0:	6dc080e7          	jalr	1756(ra) # 5688 <chdir>
    2fb4:	04054963          	bltz	a0,3006 <dirtest+0x82>
  if(chdir("..") < 0){
    2fb8:	00004517          	auipc	a0,0x4
    2fbc:	12050513          	addi	a0,a0,288 # 70d8 <malloc+0x1682>
    2fc0:	00002097          	auipc	ra,0x2
    2fc4:	6c8080e7          	jalr	1736(ra) # 5688 <chdir>
    2fc8:	04054d63          	bltz	a0,3022 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2fcc:	00004517          	auipc	a0,0x4
    2fd0:	0ec50513          	addi	a0,a0,236 # 70b8 <malloc+0x1662>
    2fd4:	00002097          	auipc	ra,0x2
    2fd8:	694080e7          	jalr	1684(ra) # 5668 <unlink>
    2fdc:	06054163          	bltz	a0,303e <dirtest+0xba>
}
    2fe0:	60e2                	ld	ra,24(sp)
    2fe2:	6442                	ld	s0,16(sp)
    2fe4:	64a2                	ld	s1,8(sp)
    2fe6:	6105                	addi	sp,sp,32
    2fe8:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2fea:	85a6                	mv	a1,s1
    2fec:	00004517          	auipc	a0,0x4
    2ff0:	02c50513          	addi	a0,a0,44 # 7018 <malloc+0x15c2>
    2ff4:	00003097          	auipc	ra,0x3
    2ff8:	9a4080e7          	jalr	-1628(ra) # 5998 <printf>
    exit(1);
    2ffc:	4505                	li	a0,1
    2ffe:	00002097          	auipc	ra,0x2
    3002:	61a080e7          	jalr	1562(ra) # 5618 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3006:	85a6                	mv	a1,s1
    3008:	00004517          	auipc	a0,0x4
    300c:	0b850513          	addi	a0,a0,184 # 70c0 <malloc+0x166a>
    3010:	00003097          	auipc	ra,0x3
    3014:	988080e7          	jalr	-1656(ra) # 5998 <printf>
    exit(1);
    3018:	4505                	li	a0,1
    301a:	00002097          	auipc	ra,0x2
    301e:	5fe080e7          	jalr	1534(ra) # 5618 <exit>
    printf("%s: chdir .. failed\n", s);
    3022:	85a6                	mv	a1,s1
    3024:	00004517          	auipc	a0,0x4
    3028:	0bc50513          	addi	a0,a0,188 # 70e0 <malloc+0x168a>
    302c:	00003097          	auipc	ra,0x3
    3030:	96c080e7          	jalr	-1684(ra) # 5998 <printf>
    exit(1);
    3034:	4505                	li	a0,1
    3036:	00002097          	auipc	ra,0x2
    303a:	5e2080e7          	jalr	1506(ra) # 5618 <exit>
    printf("%s: unlink dir0 failed\n", s);
    303e:	85a6                	mv	a1,s1
    3040:	00004517          	auipc	a0,0x4
    3044:	0b850513          	addi	a0,a0,184 # 70f8 <malloc+0x16a2>
    3048:	00003097          	auipc	ra,0x3
    304c:	950080e7          	jalr	-1712(ra) # 5998 <printf>
    exit(1);
    3050:	4505                	li	a0,1
    3052:	00002097          	auipc	ra,0x2
    3056:	5c6080e7          	jalr	1478(ra) # 5618 <exit>

000000000000305a <subdir>:
{
    305a:	1101                	addi	sp,sp,-32
    305c:	ec06                	sd	ra,24(sp)
    305e:	e822                	sd	s0,16(sp)
    3060:	e426                	sd	s1,8(sp)
    3062:	e04a                	sd	s2,0(sp)
    3064:	1000                	addi	s0,sp,32
    3066:	892a                	mv	s2,a0
  unlink("ff");
    3068:	00004517          	auipc	a0,0x4
    306c:	1d850513          	addi	a0,a0,472 # 7240 <malloc+0x17ea>
    3070:	00002097          	auipc	ra,0x2
    3074:	5f8080e7          	jalr	1528(ra) # 5668 <unlink>
  if(mkdir("dd") != 0){
    3078:	00004517          	auipc	a0,0x4
    307c:	09850513          	addi	a0,a0,152 # 7110 <malloc+0x16ba>
    3080:	00002097          	auipc	ra,0x2
    3084:	600080e7          	jalr	1536(ra) # 5680 <mkdir>
    3088:	38051663          	bnez	a0,3414 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    308c:	20200593          	li	a1,514
    3090:	00004517          	auipc	a0,0x4
    3094:	0a050513          	addi	a0,a0,160 # 7130 <malloc+0x16da>
    3098:	00002097          	auipc	ra,0x2
    309c:	5c0080e7          	jalr	1472(ra) # 5658 <open>
    30a0:	84aa                	mv	s1,a0
  if(fd < 0){
    30a2:	38054763          	bltz	a0,3430 <subdir+0x3d6>
  write(fd, "ff", 2);
    30a6:	4609                	li	a2,2
    30a8:	00004597          	auipc	a1,0x4
    30ac:	19858593          	addi	a1,a1,408 # 7240 <malloc+0x17ea>
    30b0:	00002097          	auipc	ra,0x2
    30b4:	588080e7          	jalr	1416(ra) # 5638 <write>
  close(fd);
    30b8:	8526                	mv	a0,s1
    30ba:	00002097          	auipc	ra,0x2
    30be:	586080e7          	jalr	1414(ra) # 5640 <close>
  if(unlink("dd") >= 0){
    30c2:	00004517          	auipc	a0,0x4
    30c6:	04e50513          	addi	a0,a0,78 # 7110 <malloc+0x16ba>
    30ca:	00002097          	auipc	ra,0x2
    30ce:	59e080e7          	jalr	1438(ra) # 5668 <unlink>
    30d2:	36055d63          	bgez	a0,344c <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    30d6:	00004517          	auipc	a0,0x4
    30da:	0b250513          	addi	a0,a0,178 # 7188 <malloc+0x1732>
    30de:	00002097          	auipc	ra,0x2
    30e2:	5a2080e7          	jalr	1442(ra) # 5680 <mkdir>
    30e6:	38051163          	bnez	a0,3468 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    30ea:	20200593          	li	a1,514
    30ee:	00004517          	auipc	a0,0x4
    30f2:	0c250513          	addi	a0,a0,194 # 71b0 <malloc+0x175a>
    30f6:	00002097          	auipc	ra,0x2
    30fa:	562080e7          	jalr	1378(ra) # 5658 <open>
    30fe:	84aa                	mv	s1,a0
  if(fd < 0){
    3100:	38054263          	bltz	a0,3484 <subdir+0x42a>
  write(fd, "FF", 2);
    3104:	4609                	li	a2,2
    3106:	00004597          	auipc	a1,0x4
    310a:	0da58593          	addi	a1,a1,218 # 71e0 <malloc+0x178a>
    310e:	00002097          	auipc	ra,0x2
    3112:	52a080e7          	jalr	1322(ra) # 5638 <write>
  close(fd);
    3116:	8526                	mv	a0,s1
    3118:	00002097          	auipc	ra,0x2
    311c:	528080e7          	jalr	1320(ra) # 5640 <close>
  fd = open("dd/dd/../ff", 0);
    3120:	4581                	li	a1,0
    3122:	00004517          	auipc	a0,0x4
    3126:	0c650513          	addi	a0,a0,198 # 71e8 <malloc+0x1792>
    312a:	00002097          	auipc	ra,0x2
    312e:	52e080e7          	jalr	1326(ra) # 5658 <open>
    3132:	84aa                	mv	s1,a0
  if(fd < 0){
    3134:	36054663          	bltz	a0,34a0 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3138:	660d                	lui	a2,0x3
    313a:	00009597          	auipc	a1,0x9
    313e:	97658593          	addi	a1,a1,-1674 # bab0 <buf>
    3142:	00002097          	auipc	ra,0x2
    3146:	4ee080e7          	jalr	1262(ra) # 5630 <read>
  if(cc != 2 || buf[0] != 'f'){
    314a:	4789                	li	a5,2
    314c:	36f51863          	bne	a0,a5,34bc <subdir+0x462>
    3150:	00009717          	auipc	a4,0x9
    3154:	96074703          	lbu	a4,-1696(a4) # bab0 <buf>
    3158:	06600793          	li	a5,102
    315c:	36f71063          	bne	a4,a5,34bc <subdir+0x462>
  close(fd);
    3160:	8526                	mv	a0,s1
    3162:	00002097          	auipc	ra,0x2
    3166:	4de080e7          	jalr	1246(ra) # 5640 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    316a:	00004597          	auipc	a1,0x4
    316e:	0ce58593          	addi	a1,a1,206 # 7238 <malloc+0x17e2>
    3172:	00004517          	auipc	a0,0x4
    3176:	03e50513          	addi	a0,a0,62 # 71b0 <malloc+0x175a>
    317a:	00002097          	auipc	ra,0x2
    317e:	4fe080e7          	jalr	1278(ra) # 5678 <link>
    3182:	34051b63          	bnez	a0,34d8 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3186:	00004517          	auipc	a0,0x4
    318a:	02a50513          	addi	a0,a0,42 # 71b0 <malloc+0x175a>
    318e:	00002097          	auipc	ra,0x2
    3192:	4da080e7          	jalr	1242(ra) # 5668 <unlink>
    3196:	34051f63          	bnez	a0,34f4 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    319a:	4581                	li	a1,0
    319c:	00004517          	auipc	a0,0x4
    31a0:	01450513          	addi	a0,a0,20 # 71b0 <malloc+0x175a>
    31a4:	00002097          	auipc	ra,0x2
    31a8:	4b4080e7          	jalr	1204(ra) # 5658 <open>
    31ac:	36055263          	bgez	a0,3510 <subdir+0x4b6>
  if(chdir("dd") != 0){
    31b0:	00004517          	auipc	a0,0x4
    31b4:	f6050513          	addi	a0,a0,-160 # 7110 <malloc+0x16ba>
    31b8:	00002097          	auipc	ra,0x2
    31bc:	4d0080e7          	jalr	1232(ra) # 5688 <chdir>
    31c0:	36051663          	bnez	a0,352c <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    31c4:	00004517          	auipc	a0,0x4
    31c8:	10c50513          	addi	a0,a0,268 # 72d0 <malloc+0x187a>
    31cc:	00002097          	auipc	ra,0x2
    31d0:	4bc080e7          	jalr	1212(ra) # 5688 <chdir>
    31d4:	36051a63          	bnez	a0,3548 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    31d8:	00004517          	auipc	a0,0x4
    31dc:	12850513          	addi	a0,a0,296 # 7300 <malloc+0x18aa>
    31e0:	00002097          	auipc	ra,0x2
    31e4:	4a8080e7          	jalr	1192(ra) # 5688 <chdir>
    31e8:	36051e63          	bnez	a0,3564 <subdir+0x50a>
  if(chdir("./..") != 0){
    31ec:	00004517          	auipc	a0,0x4
    31f0:	14450513          	addi	a0,a0,324 # 7330 <malloc+0x18da>
    31f4:	00002097          	auipc	ra,0x2
    31f8:	494080e7          	jalr	1172(ra) # 5688 <chdir>
    31fc:	38051263          	bnez	a0,3580 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3200:	4581                	li	a1,0
    3202:	00004517          	auipc	a0,0x4
    3206:	03650513          	addi	a0,a0,54 # 7238 <malloc+0x17e2>
    320a:	00002097          	auipc	ra,0x2
    320e:	44e080e7          	jalr	1102(ra) # 5658 <open>
    3212:	84aa                	mv	s1,a0
  if(fd < 0){
    3214:	38054463          	bltz	a0,359c <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3218:	660d                	lui	a2,0x3
    321a:	00009597          	auipc	a1,0x9
    321e:	89658593          	addi	a1,a1,-1898 # bab0 <buf>
    3222:	00002097          	auipc	ra,0x2
    3226:	40e080e7          	jalr	1038(ra) # 5630 <read>
    322a:	4789                	li	a5,2
    322c:	38f51663          	bne	a0,a5,35b8 <subdir+0x55e>
  close(fd);
    3230:	8526                	mv	a0,s1
    3232:	00002097          	auipc	ra,0x2
    3236:	40e080e7          	jalr	1038(ra) # 5640 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    323a:	4581                	li	a1,0
    323c:	00004517          	auipc	a0,0x4
    3240:	f7450513          	addi	a0,a0,-140 # 71b0 <malloc+0x175a>
    3244:	00002097          	auipc	ra,0x2
    3248:	414080e7          	jalr	1044(ra) # 5658 <open>
    324c:	38055463          	bgez	a0,35d4 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3250:	20200593          	li	a1,514
    3254:	00004517          	auipc	a0,0x4
    3258:	16c50513          	addi	a0,a0,364 # 73c0 <malloc+0x196a>
    325c:	00002097          	auipc	ra,0x2
    3260:	3fc080e7          	jalr	1020(ra) # 5658 <open>
    3264:	38055663          	bgez	a0,35f0 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3268:	20200593          	li	a1,514
    326c:	00004517          	auipc	a0,0x4
    3270:	18450513          	addi	a0,a0,388 # 73f0 <malloc+0x199a>
    3274:	00002097          	auipc	ra,0x2
    3278:	3e4080e7          	jalr	996(ra) # 5658 <open>
    327c:	38055863          	bgez	a0,360c <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3280:	20000593          	li	a1,512
    3284:	00004517          	auipc	a0,0x4
    3288:	e8c50513          	addi	a0,a0,-372 # 7110 <malloc+0x16ba>
    328c:	00002097          	auipc	ra,0x2
    3290:	3cc080e7          	jalr	972(ra) # 5658 <open>
    3294:	38055a63          	bgez	a0,3628 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3298:	4589                	li	a1,2
    329a:	00004517          	auipc	a0,0x4
    329e:	e7650513          	addi	a0,a0,-394 # 7110 <malloc+0x16ba>
    32a2:	00002097          	auipc	ra,0x2
    32a6:	3b6080e7          	jalr	950(ra) # 5658 <open>
    32aa:	38055d63          	bgez	a0,3644 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    32ae:	4585                	li	a1,1
    32b0:	00004517          	auipc	a0,0x4
    32b4:	e6050513          	addi	a0,a0,-416 # 7110 <malloc+0x16ba>
    32b8:	00002097          	auipc	ra,0x2
    32bc:	3a0080e7          	jalr	928(ra) # 5658 <open>
    32c0:	3a055063          	bgez	a0,3660 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    32c4:	00004597          	auipc	a1,0x4
    32c8:	1bc58593          	addi	a1,a1,444 # 7480 <malloc+0x1a2a>
    32cc:	00004517          	auipc	a0,0x4
    32d0:	0f450513          	addi	a0,a0,244 # 73c0 <malloc+0x196a>
    32d4:	00002097          	auipc	ra,0x2
    32d8:	3a4080e7          	jalr	932(ra) # 5678 <link>
    32dc:	3a050063          	beqz	a0,367c <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    32e0:	00004597          	auipc	a1,0x4
    32e4:	1a058593          	addi	a1,a1,416 # 7480 <malloc+0x1a2a>
    32e8:	00004517          	auipc	a0,0x4
    32ec:	10850513          	addi	a0,a0,264 # 73f0 <malloc+0x199a>
    32f0:	00002097          	auipc	ra,0x2
    32f4:	388080e7          	jalr	904(ra) # 5678 <link>
    32f8:	3a050063          	beqz	a0,3698 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    32fc:	00004597          	auipc	a1,0x4
    3300:	f3c58593          	addi	a1,a1,-196 # 7238 <malloc+0x17e2>
    3304:	00004517          	auipc	a0,0x4
    3308:	e2c50513          	addi	a0,a0,-468 # 7130 <malloc+0x16da>
    330c:	00002097          	auipc	ra,0x2
    3310:	36c080e7          	jalr	876(ra) # 5678 <link>
    3314:	3a050063          	beqz	a0,36b4 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3318:	00004517          	auipc	a0,0x4
    331c:	0a850513          	addi	a0,a0,168 # 73c0 <malloc+0x196a>
    3320:	00002097          	auipc	ra,0x2
    3324:	360080e7          	jalr	864(ra) # 5680 <mkdir>
    3328:	3a050463          	beqz	a0,36d0 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    332c:	00004517          	auipc	a0,0x4
    3330:	0c450513          	addi	a0,a0,196 # 73f0 <malloc+0x199a>
    3334:	00002097          	auipc	ra,0x2
    3338:	34c080e7          	jalr	844(ra) # 5680 <mkdir>
    333c:	3a050863          	beqz	a0,36ec <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3340:	00004517          	auipc	a0,0x4
    3344:	ef850513          	addi	a0,a0,-264 # 7238 <malloc+0x17e2>
    3348:	00002097          	auipc	ra,0x2
    334c:	338080e7          	jalr	824(ra) # 5680 <mkdir>
    3350:	3a050c63          	beqz	a0,3708 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3354:	00004517          	auipc	a0,0x4
    3358:	09c50513          	addi	a0,a0,156 # 73f0 <malloc+0x199a>
    335c:	00002097          	auipc	ra,0x2
    3360:	30c080e7          	jalr	780(ra) # 5668 <unlink>
    3364:	3c050063          	beqz	a0,3724 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3368:	00004517          	auipc	a0,0x4
    336c:	05850513          	addi	a0,a0,88 # 73c0 <malloc+0x196a>
    3370:	00002097          	auipc	ra,0x2
    3374:	2f8080e7          	jalr	760(ra) # 5668 <unlink>
    3378:	3c050463          	beqz	a0,3740 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    337c:	00004517          	auipc	a0,0x4
    3380:	db450513          	addi	a0,a0,-588 # 7130 <malloc+0x16da>
    3384:	00002097          	auipc	ra,0x2
    3388:	304080e7          	jalr	772(ra) # 5688 <chdir>
    338c:	3c050863          	beqz	a0,375c <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3390:	00004517          	auipc	a0,0x4
    3394:	24050513          	addi	a0,a0,576 # 75d0 <malloc+0x1b7a>
    3398:	00002097          	auipc	ra,0x2
    339c:	2f0080e7          	jalr	752(ra) # 5688 <chdir>
    33a0:	3c050c63          	beqz	a0,3778 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    33a4:	00004517          	auipc	a0,0x4
    33a8:	e9450513          	addi	a0,a0,-364 # 7238 <malloc+0x17e2>
    33ac:	00002097          	auipc	ra,0x2
    33b0:	2bc080e7          	jalr	700(ra) # 5668 <unlink>
    33b4:	3e051063          	bnez	a0,3794 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    33b8:	00004517          	auipc	a0,0x4
    33bc:	d7850513          	addi	a0,a0,-648 # 7130 <malloc+0x16da>
    33c0:	00002097          	auipc	ra,0x2
    33c4:	2a8080e7          	jalr	680(ra) # 5668 <unlink>
    33c8:	3e051463          	bnez	a0,37b0 <subdir+0x756>
  if(unlink("dd") == 0){
    33cc:	00004517          	auipc	a0,0x4
    33d0:	d4450513          	addi	a0,a0,-700 # 7110 <malloc+0x16ba>
    33d4:	00002097          	auipc	ra,0x2
    33d8:	294080e7          	jalr	660(ra) # 5668 <unlink>
    33dc:	3e050863          	beqz	a0,37cc <subdir+0x772>
  if(unlink("dd/dd") < 0){
    33e0:	00004517          	auipc	a0,0x4
    33e4:	26050513          	addi	a0,a0,608 # 7640 <malloc+0x1bea>
    33e8:	00002097          	auipc	ra,0x2
    33ec:	280080e7          	jalr	640(ra) # 5668 <unlink>
    33f0:	3e054c63          	bltz	a0,37e8 <subdir+0x78e>
  if(unlink("dd") < 0){
    33f4:	00004517          	auipc	a0,0x4
    33f8:	d1c50513          	addi	a0,a0,-740 # 7110 <malloc+0x16ba>
    33fc:	00002097          	auipc	ra,0x2
    3400:	26c080e7          	jalr	620(ra) # 5668 <unlink>
    3404:	40054063          	bltz	a0,3804 <subdir+0x7aa>
}
    3408:	60e2                	ld	ra,24(sp)
    340a:	6442                	ld	s0,16(sp)
    340c:	64a2                	ld	s1,8(sp)
    340e:	6902                	ld	s2,0(sp)
    3410:	6105                	addi	sp,sp,32
    3412:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3414:	85ca                	mv	a1,s2
    3416:	00004517          	auipc	a0,0x4
    341a:	d0250513          	addi	a0,a0,-766 # 7118 <malloc+0x16c2>
    341e:	00002097          	auipc	ra,0x2
    3422:	57a080e7          	jalr	1402(ra) # 5998 <printf>
    exit(1);
    3426:	4505                	li	a0,1
    3428:	00002097          	auipc	ra,0x2
    342c:	1f0080e7          	jalr	496(ra) # 5618 <exit>
    printf("%s: create dd/ff failed\n", s);
    3430:	85ca                	mv	a1,s2
    3432:	00004517          	auipc	a0,0x4
    3436:	d0650513          	addi	a0,a0,-762 # 7138 <malloc+0x16e2>
    343a:	00002097          	auipc	ra,0x2
    343e:	55e080e7          	jalr	1374(ra) # 5998 <printf>
    exit(1);
    3442:	4505                	li	a0,1
    3444:	00002097          	auipc	ra,0x2
    3448:	1d4080e7          	jalr	468(ra) # 5618 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    344c:	85ca                	mv	a1,s2
    344e:	00004517          	auipc	a0,0x4
    3452:	d0a50513          	addi	a0,a0,-758 # 7158 <malloc+0x1702>
    3456:	00002097          	auipc	ra,0x2
    345a:	542080e7          	jalr	1346(ra) # 5998 <printf>
    exit(1);
    345e:	4505                	li	a0,1
    3460:	00002097          	auipc	ra,0x2
    3464:	1b8080e7          	jalr	440(ra) # 5618 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3468:	85ca                	mv	a1,s2
    346a:	00004517          	auipc	a0,0x4
    346e:	d2650513          	addi	a0,a0,-730 # 7190 <malloc+0x173a>
    3472:	00002097          	auipc	ra,0x2
    3476:	526080e7          	jalr	1318(ra) # 5998 <printf>
    exit(1);
    347a:	4505                	li	a0,1
    347c:	00002097          	auipc	ra,0x2
    3480:	19c080e7          	jalr	412(ra) # 5618 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3484:	85ca                	mv	a1,s2
    3486:	00004517          	auipc	a0,0x4
    348a:	d3a50513          	addi	a0,a0,-710 # 71c0 <malloc+0x176a>
    348e:	00002097          	auipc	ra,0x2
    3492:	50a080e7          	jalr	1290(ra) # 5998 <printf>
    exit(1);
    3496:	4505                	li	a0,1
    3498:	00002097          	auipc	ra,0x2
    349c:	180080e7          	jalr	384(ra) # 5618 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    34a0:	85ca                	mv	a1,s2
    34a2:	00004517          	auipc	a0,0x4
    34a6:	d5650513          	addi	a0,a0,-682 # 71f8 <malloc+0x17a2>
    34aa:	00002097          	auipc	ra,0x2
    34ae:	4ee080e7          	jalr	1262(ra) # 5998 <printf>
    exit(1);
    34b2:	4505                	li	a0,1
    34b4:	00002097          	auipc	ra,0x2
    34b8:	164080e7          	jalr	356(ra) # 5618 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    34bc:	85ca                	mv	a1,s2
    34be:	00004517          	auipc	a0,0x4
    34c2:	d5a50513          	addi	a0,a0,-678 # 7218 <malloc+0x17c2>
    34c6:	00002097          	auipc	ra,0x2
    34ca:	4d2080e7          	jalr	1234(ra) # 5998 <printf>
    exit(1);
    34ce:	4505                	li	a0,1
    34d0:	00002097          	auipc	ra,0x2
    34d4:	148080e7          	jalr	328(ra) # 5618 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    34d8:	85ca                	mv	a1,s2
    34da:	00004517          	auipc	a0,0x4
    34de:	d6e50513          	addi	a0,a0,-658 # 7248 <malloc+0x17f2>
    34e2:	00002097          	auipc	ra,0x2
    34e6:	4b6080e7          	jalr	1206(ra) # 5998 <printf>
    exit(1);
    34ea:	4505                	li	a0,1
    34ec:	00002097          	auipc	ra,0x2
    34f0:	12c080e7          	jalr	300(ra) # 5618 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    34f4:	85ca                	mv	a1,s2
    34f6:	00004517          	auipc	a0,0x4
    34fa:	d7a50513          	addi	a0,a0,-646 # 7270 <malloc+0x181a>
    34fe:	00002097          	auipc	ra,0x2
    3502:	49a080e7          	jalr	1178(ra) # 5998 <printf>
    exit(1);
    3506:	4505                	li	a0,1
    3508:	00002097          	auipc	ra,0x2
    350c:	110080e7          	jalr	272(ra) # 5618 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3510:	85ca                	mv	a1,s2
    3512:	00004517          	auipc	a0,0x4
    3516:	d7e50513          	addi	a0,a0,-642 # 7290 <malloc+0x183a>
    351a:	00002097          	auipc	ra,0x2
    351e:	47e080e7          	jalr	1150(ra) # 5998 <printf>
    exit(1);
    3522:	4505                	li	a0,1
    3524:	00002097          	auipc	ra,0x2
    3528:	0f4080e7          	jalr	244(ra) # 5618 <exit>
    printf("%s: chdir dd failed\n", s);
    352c:	85ca                	mv	a1,s2
    352e:	00004517          	auipc	a0,0x4
    3532:	d8a50513          	addi	a0,a0,-630 # 72b8 <malloc+0x1862>
    3536:	00002097          	auipc	ra,0x2
    353a:	462080e7          	jalr	1122(ra) # 5998 <printf>
    exit(1);
    353e:	4505                	li	a0,1
    3540:	00002097          	auipc	ra,0x2
    3544:	0d8080e7          	jalr	216(ra) # 5618 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3548:	85ca                	mv	a1,s2
    354a:	00004517          	auipc	a0,0x4
    354e:	d9650513          	addi	a0,a0,-618 # 72e0 <malloc+0x188a>
    3552:	00002097          	auipc	ra,0x2
    3556:	446080e7          	jalr	1094(ra) # 5998 <printf>
    exit(1);
    355a:	4505                	li	a0,1
    355c:	00002097          	auipc	ra,0x2
    3560:	0bc080e7          	jalr	188(ra) # 5618 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3564:	85ca                	mv	a1,s2
    3566:	00004517          	auipc	a0,0x4
    356a:	daa50513          	addi	a0,a0,-598 # 7310 <malloc+0x18ba>
    356e:	00002097          	auipc	ra,0x2
    3572:	42a080e7          	jalr	1066(ra) # 5998 <printf>
    exit(1);
    3576:	4505                	li	a0,1
    3578:	00002097          	auipc	ra,0x2
    357c:	0a0080e7          	jalr	160(ra) # 5618 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3580:	85ca                	mv	a1,s2
    3582:	00004517          	auipc	a0,0x4
    3586:	db650513          	addi	a0,a0,-586 # 7338 <malloc+0x18e2>
    358a:	00002097          	auipc	ra,0x2
    358e:	40e080e7          	jalr	1038(ra) # 5998 <printf>
    exit(1);
    3592:	4505                	li	a0,1
    3594:	00002097          	auipc	ra,0x2
    3598:	084080e7          	jalr	132(ra) # 5618 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    359c:	85ca                	mv	a1,s2
    359e:	00004517          	auipc	a0,0x4
    35a2:	db250513          	addi	a0,a0,-590 # 7350 <malloc+0x18fa>
    35a6:	00002097          	auipc	ra,0x2
    35aa:	3f2080e7          	jalr	1010(ra) # 5998 <printf>
    exit(1);
    35ae:	4505                	li	a0,1
    35b0:	00002097          	auipc	ra,0x2
    35b4:	068080e7          	jalr	104(ra) # 5618 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    35b8:	85ca                	mv	a1,s2
    35ba:	00004517          	auipc	a0,0x4
    35be:	db650513          	addi	a0,a0,-586 # 7370 <malloc+0x191a>
    35c2:	00002097          	auipc	ra,0x2
    35c6:	3d6080e7          	jalr	982(ra) # 5998 <printf>
    exit(1);
    35ca:	4505                	li	a0,1
    35cc:	00002097          	auipc	ra,0x2
    35d0:	04c080e7          	jalr	76(ra) # 5618 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    35d4:	85ca                	mv	a1,s2
    35d6:	00004517          	auipc	a0,0x4
    35da:	dba50513          	addi	a0,a0,-582 # 7390 <malloc+0x193a>
    35de:	00002097          	auipc	ra,0x2
    35e2:	3ba080e7          	jalr	954(ra) # 5998 <printf>
    exit(1);
    35e6:	4505                	li	a0,1
    35e8:	00002097          	auipc	ra,0x2
    35ec:	030080e7          	jalr	48(ra) # 5618 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    35f0:	85ca                	mv	a1,s2
    35f2:	00004517          	auipc	a0,0x4
    35f6:	dde50513          	addi	a0,a0,-546 # 73d0 <malloc+0x197a>
    35fa:	00002097          	auipc	ra,0x2
    35fe:	39e080e7          	jalr	926(ra) # 5998 <printf>
    exit(1);
    3602:	4505                	li	a0,1
    3604:	00002097          	auipc	ra,0x2
    3608:	014080e7          	jalr	20(ra) # 5618 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    360c:	85ca                	mv	a1,s2
    360e:	00004517          	auipc	a0,0x4
    3612:	df250513          	addi	a0,a0,-526 # 7400 <malloc+0x19aa>
    3616:	00002097          	auipc	ra,0x2
    361a:	382080e7          	jalr	898(ra) # 5998 <printf>
    exit(1);
    361e:	4505                	li	a0,1
    3620:	00002097          	auipc	ra,0x2
    3624:	ff8080e7          	jalr	-8(ra) # 5618 <exit>
    printf("%s: create dd succeeded!\n", s);
    3628:	85ca                	mv	a1,s2
    362a:	00004517          	auipc	a0,0x4
    362e:	df650513          	addi	a0,a0,-522 # 7420 <malloc+0x19ca>
    3632:	00002097          	auipc	ra,0x2
    3636:	366080e7          	jalr	870(ra) # 5998 <printf>
    exit(1);
    363a:	4505                	li	a0,1
    363c:	00002097          	auipc	ra,0x2
    3640:	fdc080e7          	jalr	-36(ra) # 5618 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3644:	85ca                	mv	a1,s2
    3646:	00004517          	auipc	a0,0x4
    364a:	dfa50513          	addi	a0,a0,-518 # 7440 <malloc+0x19ea>
    364e:	00002097          	auipc	ra,0x2
    3652:	34a080e7          	jalr	842(ra) # 5998 <printf>
    exit(1);
    3656:	4505                	li	a0,1
    3658:	00002097          	auipc	ra,0x2
    365c:	fc0080e7          	jalr	-64(ra) # 5618 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3660:	85ca                	mv	a1,s2
    3662:	00004517          	auipc	a0,0x4
    3666:	dfe50513          	addi	a0,a0,-514 # 7460 <malloc+0x1a0a>
    366a:	00002097          	auipc	ra,0x2
    366e:	32e080e7          	jalr	814(ra) # 5998 <printf>
    exit(1);
    3672:	4505                	li	a0,1
    3674:	00002097          	auipc	ra,0x2
    3678:	fa4080e7          	jalr	-92(ra) # 5618 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    367c:	85ca                	mv	a1,s2
    367e:	00004517          	auipc	a0,0x4
    3682:	e1250513          	addi	a0,a0,-494 # 7490 <malloc+0x1a3a>
    3686:	00002097          	auipc	ra,0x2
    368a:	312080e7          	jalr	786(ra) # 5998 <printf>
    exit(1);
    368e:	4505                	li	a0,1
    3690:	00002097          	auipc	ra,0x2
    3694:	f88080e7          	jalr	-120(ra) # 5618 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3698:	85ca                	mv	a1,s2
    369a:	00004517          	auipc	a0,0x4
    369e:	e1e50513          	addi	a0,a0,-482 # 74b8 <malloc+0x1a62>
    36a2:	00002097          	auipc	ra,0x2
    36a6:	2f6080e7          	jalr	758(ra) # 5998 <printf>
    exit(1);
    36aa:	4505                	li	a0,1
    36ac:	00002097          	auipc	ra,0x2
    36b0:	f6c080e7          	jalr	-148(ra) # 5618 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    36b4:	85ca                	mv	a1,s2
    36b6:	00004517          	auipc	a0,0x4
    36ba:	e2a50513          	addi	a0,a0,-470 # 74e0 <malloc+0x1a8a>
    36be:	00002097          	auipc	ra,0x2
    36c2:	2da080e7          	jalr	730(ra) # 5998 <printf>
    exit(1);
    36c6:	4505                	li	a0,1
    36c8:	00002097          	auipc	ra,0x2
    36cc:	f50080e7          	jalr	-176(ra) # 5618 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    36d0:	85ca                	mv	a1,s2
    36d2:	00004517          	auipc	a0,0x4
    36d6:	e3650513          	addi	a0,a0,-458 # 7508 <malloc+0x1ab2>
    36da:	00002097          	auipc	ra,0x2
    36de:	2be080e7          	jalr	702(ra) # 5998 <printf>
    exit(1);
    36e2:	4505                	li	a0,1
    36e4:	00002097          	auipc	ra,0x2
    36e8:	f34080e7          	jalr	-204(ra) # 5618 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    36ec:	85ca                	mv	a1,s2
    36ee:	00004517          	auipc	a0,0x4
    36f2:	e3a50513          	addi	a0,a0,-454 # 7528 <malloc+0x1ad2>
    36f6:	00002097          	auipc	ra,0x2
    36fa:	2a2080e7          	jalr	674(ra) # 5998 <printf>
    exit(1);
    36fe:	4505                	li	a0,1
    3700:	00002097          	auipc	ra,0x2
    3704:	f18080e7          	jalr	-232(ra) # 5618 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3708:	85ca                	mv	a1,s2
    370a:	00004517          	auipc	a0,0x4
    370e:	e3e50513          	addi	a0,a0,-450 # 7548 <malloc+0x1af2>
    3712:	00002097          	auipc	ra,0x2
    3716:	286080e7          	jalr	646(ra) # 5998 <printf>
    exit(1);
    371a:	4505                	li	a0,1
    371c:	00002097          	auipc	ra,0x2
    3720:	efc080e7          	jalr	-260(ra) # 5618 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3724:	85ca                	mv	a1,s2
    3726:	00004517          	auipc	a0,0x4
    372a:	e4a50513          	addi	a0,a0,-438 # 7570 <malloc+0x1b1a>
    372e:	00002097          	auipc	ra,0x2
    3732:	26a080e7          	jalr	618(ra) # 5998 <printf>
    exit(1);
    3736:	4505                	li	a0,1
    3738:	00002097          	auipc	ra,0x2
    373c:	ee0080e7          	jalr	-288(ra) # 5618 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3740:	85ca                	mv	a1,s2
    3742:	00004517          	auipc	a0,0x4
    3746:	e4e50513          	addi	a0,a0,-434 # 7590 <malloc+0x1b3a>
    374a:	00002097          	auipc	ra,0x2
    374e:	24e080e7          	jalr	590(ra) # 5998 <printf>
    exit(1);
    3752:	4505                	li	a0,1
    3754:	00002097          	auipc	ra,0x2
    3758:	ec4080e7          	jalr	-316(ra) # 5618 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    375c:	85ca                	mv	a1,s2
    375e:	00004517          	auipc	a0,0x4
    3762:	e5250513          	addi	a0,a0,-430 # 75b0 <malloc+0x1b5a>
    3766:	00002097          	auipc	ra,0x2
    376a:	232080e7          	jalr	562(ra) # 5998 <printf>
    exit(1);
    376e:	4505                	li	a0,1
    3770:	00002097          	auipc	ra,0x2
    3774:	ea8080e7          	jalr	-344(ra) # 5618 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3778:	85ca                	mv	a1,s2
    377a:	00004517          	auipc	a0,0x4
    377e:	e5e50513          	addi	a0,a0,-418 # 75d8 <malloc+0x1b82>
    3782:	00002097          	auipc	ra,0x2
    3786:	216080e7          	jalr	534(ra) # 5998 <printf>
    exit(1);
    378a:	4505                	li	a0,1
    378c:	00002097          	auipc	ra,0x2
    3790:	e8c080e7          	jalr	-372(ra) # 5618 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3794:	85ca                	mv	a1,s2
    3796:	00004517          	auipc	a0,0x4
    379a:	ada50513          	addi	a0,a0,-1318 # 7270 <malloc+0x181a>
    379e:	00002097          	auipc	ra,0x2
    37a2:	1fa080e7          	jalr	506(ra) # 5998 <printf>
    exit(1);
    37a6:	4505                	li	a0,1
    37a8:	00002097          	auipc	ra,0x2
    37ac:	e70080e7          	jalr	-400(ra) # 5618 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    37b0:	85ca                	mv	a1,s2
    37b2:	00004517          	auipc	a0,0x4
    37b6:	e4650513          	addi	a0,a0,-442 # 75f8 <malloc+0x1ba2>
    37ba:	00002097          	auipc	ra,0x2
    37be:	1de080e7          	jalr	478(ra) # 5998 <printf>
    exit(1);
    37c2:	4505                	li	a0,1
    37c4:	00002097          	auipc	ra,0x2
    37c8:	e54080e7          	jalr	-428(ra) # 5618 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    37cc:	85ca                	mv	a1,s2
    37ce:	00004517          	auipc	a0,0x4
    37d2:	e4a50513          	addi	a0,a0,-438 # 7618 <malloc+0x1bc2>
    37d6:	00002097          	auipc	ra,0x2
    37da:	1c2080e7          	jalr	450(ra) # 5998 <printf>
    exit(1);
    37de:	4505                	li	a0,1
    37e0:	00002097          	auipc	ra,0x2
    37e4:	e38080e7          	jalr	-456(ra) # 5618 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    37e8:	85ca                	mv	a1,s2
    37ea:	00004517          	auipc	a0,0x4
    37ee:	e5e50513          	addi	a0,a0,-418 # 7648 <malloc+0x1bf2>
    37f2:	00002097          	auipc	ra,0x2
    37f6:	1a6080e7          	jalr	422(ra) # 5998 <printf>
    exit(1);
    37fa:	4505                	li	a0,1
    37fc:	00002097          	auipc	ra,0x2
    3800:	e1c080e7          	jalr	-484(ra) # 5618 <exit>
    printf("%s: unlink dd failed\n", s);
    3804:	85ca                	mv	a1,s2
    3806:	00004517          	auipc	a0,0x4
    380a:	e6250513          	addi	a0,a0,-414 # 7668 <malloc+0x1c12>
    380e:	00002097          	auipc	ra,0x2
    3812:	18a080e7          	jalr	394(ra) # 5998 <printf>
    exit(1);
    3816:	4505                	li	a0,1
    3818:	00002097          	auipc	ra,0x2
    381c:	e00080e7          	jalr	-512(ra) # 5618 <exit>

0000000000003820 <rmdot>:
{
    3820:	1101                	addi	sp,sp,-32
    3822:	ec06                	sd	ra,24(sp)
    3824:	e822                	sd	s0,16(sp)
    3826:	e426                	sd	s1,8(sp)
    3828:	1000                	addi	s0,sp,32
    382a:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    382c:	00004517          	auipc	a0,0x4
    3830:	e5450513          	addi	a0,a0,-428 # 7680 <malloc+0x1c2a>
    3834:	00002097          	auipc	ra,0x2
    3838:	e4c080e7          	jalr	-436(ra) # 5680 <mkdir>
    383c:	e549                	bnez	a0,38c6 <rmdot+0xa6>
  if(chdir("dots") != 0){
    383e:	00004517          	auipc	a0,0x4
    3842:	e4250513          	addi	a0,a0,-446 # 7680 <malloc+0x1c2a>
    3846:	00002097          	auipc	ra,0x2
    384a:	e42080e7          	jalr	-446(ra) # 5688 <chdir>
    384e:	e951                	bnez	a0,38e2 <rmdot+0xc2>
  if(unlink(".") == 0){
    3850:	00003517          	auipc	a0,0x3
    3854:	ce050513          	addi	a0,a0,-800 # 6530 <malloc+0xada>
    3858:	00002097          	auipc	ra,0x2
    385c:	e10080e7          	jalr	-496(ra) # 5668 <unlink>
    3860:	cd59                	beqz	a0,38fe <rmdot+0xde>
  if(unlink("..") == 0){
    3862:	00004517          	auipc	a0,0x4
    3866:	87650513          	addi	a0,a0,-1930 # 70d8 <malloc+0x1682>
    386a:	00002097          	auipc	ra,0x2
    386e:	dfe080e7          	jalr	-514(ra) # 5668 <unlink>
    3872:	c545                	beqz	a0,391a <rmdot+0xfa>
  if(chdir("/") != 0){
    3874:	00004517          	auipc	a0,0x4
    3878:	80c50513          	addi	a0,a0,-2036 # 7080 <malloc+0x162a>
    387c:	00002097          	auipc	ra,0x2
    3880:	e0c080e7          	jalr	-500(ra) # 5688 <chdir>
    3884:	e94d                	bnez	a0,3936 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3886:	00004517          	auipc	a0,0x4
    388a:	e6250513          	addi	a0,a0,-414 # 76e8 <malloc+0x1c92>
    388e:	00002097          	auipc	ra,0x2
    3892:	dda080e7          	jalr	-550(ra) # 5668 <unlink>
    3896:	cd55                	beqz	a0,3952 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3898:	00004517          	auipc	a0,0x4
    389c:	e7850513          	addi	a0,a0,-392 # 7710 <malloc+0x1cba>
    38a0:	00002097          	auipc	ra,0x2
    38a4:	dc8080e7          	jalr	-568(ra) # 5668 <unlink>
    38a8:	c179                	beqz	a0,396e <rmdot+0x14e>
  if(unlink("dots") != 0){
    38aa:	00004517          	auipc	a0,0x4
    38ae:	dd650513          	addi	a0,a0,-554 # 7680 <malloc+0x1c2a>
    38b2:	00002097          	auipc	ra,0x2
    38b6:	db6080e7          	jalr	-586(ra) # 5668 <unlink>
    38ba:	e961                	bnez	a0,398a <rmdot+0x16a>
}
    38bc:	60e2                	ld	ra,24(sp)
    38be:	6442                	ld	s0,16(sp)
    38c0:	64a2                	ld	s1,8(sp)
    38c2:	6105                	addi	sp,sp,32
    38c4:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    38c6:	85a6                	mv	a1,s1
    38c8:	00004517          	auipc	a0,0x4
    38cc:	dc050513          	addi	a0,a0,-576 # 7688 <malloc+0x1c32>
    38d0:	00002097          	auipc	ra,0x2
    38d4:	0c8080e7          	jalr	200(ra) # 5998 <printf>
    exit(1);
    38d8:	4505                	li	a0,1
    38da:	00002097          	auipc	ra,0x2
    38de:	d3e080e7          	jalr	-706(ra) # 5618 <exit>
    printf("%s: chdir dots failed\n", s);
    38e2:	85a6                	mv	a1,s1
    38e4:	00004517          	auipc	a0,0x4
    38e8:	dbc50513          	addi	a0,a0,-580 # 76a0 <malloc+0x1c4a>
    38ec:	00002097          	auipc	ra,0x2
    38f0:	0ac080e7          	jalr	172(ra) # 5998 <printf>
    exit(1);
    38f4:	4505                	li	a0,1
    38f6:	00002097          	auipc	ra,0x2
    38fa:	d22080e7          	jalr	-734(ra) # 5618 <exit>
    printf("%s: rm . worked!\n", s);
    38fe:	85a6                	mv	a1,s1
    3900:	00004517          	auipc	a0,0x4
    3904:	db850513          	addi	a0,a0,-584 # 76b8 <malloc+0x1c62>
    3908:	00002097          	auipc	ra,0x2
    390c:	090080e7          	jalr	144(ra) # 5998 <printf>
    exit(1);
    3910:	4505                	li	a0,1
    3912:	00002097          	auipc	ra,0x2
    3916:	d06080e7          	jalr	-762(ra) # 5618 <exit>
    printf("%s: rm .. worked!\n", s);
    391a:	85a6                	mv	a1,s1
    391c:	00004517          	auipc	a0,0x4
    3920:	db450513          	addi	a0,a0,-588 # 76d0 <malloc+0x1c7a>
    3924:	00002097          	auipc	ra,0x2
    3928:	074080e7          	jalr	116(ra) # 5998 <printf>
    exit(1);
    392c:	4505                	li	a0,1
    392e:	00002097          	auipc	ra,0x2
    3932:	cea080e7          	jalr	-790(ra) # 5618 <exit>
    printf("%s: chdir / failed\n", s);
    3936:	85a6                	mv	a1,s1
    3938:	00003517          	auipc	a0,0x3
    393c:	75050513          	addi	a0,a0,1872 # 7088 <malloc+0x1632>
    3940:	00002097          	auipc	ra,0x2
    3944:	058080e7          	jalr	88(ra) # 5998 <printf>
    exit(1);
    3948:	4505                	li	a0,1
    394a:	00002097          	auipc	ra,0x2
    394e:	cce080e7          	jalr	-818(ra) # 5618 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3952:	85a6                	mv	a1,s1
    3954:	00004517          	auipc	a0,0x4
    3958:	d9c50513          	addi	a0,a0,-612 # 76f0 <malloc+0x1c9a>
    395c:	00002097          	auipc	ra,0x2
    3960:	03c080e7          	jalr	60(ra) # 5998 <printf>
    exit(1);
    3964:	4505                	li	a0,1
    3966:	00002097          	auipc	ra,0x2
    396a:	cb2080e7          	jalr	-846(ra) # 5618 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    396e:	85a6                	mv	a1,s1
    3970:	00004517          	auipc	a0,0x4
    3974:	da850513          	addi	a0,a0,-600 # 7718 <malloc+0x1cc2>
    3978:	00002097          	auipc	ra,0x2
    397c:	020080e7          	jalr	32(ra) # 5998 <printf>
    exit(1);
    3980:	4505                	li	a0,1
    3982:	00002097          	auipc	ra,0x2
    3986:	c96080e7          	jalr	-874(ra) # 5618 <exit>
    printf("%s: unlink dots failed!\n", s);
    398a:	85a6                	mv	a1,s1
    398c:	00004517          	auipc	a0,0x4
    3990:	dac50513          	addi	a0,a0,-596 # 7738 <malloc+0x1ce2>
    3994:	00002097          	auipc	ra,0x2
    3998:	004080e7          	jalr	4(ra) # 5998 <printf>
    exit(1);
    399c:	4505                	li	a0,1
    399e:	00002097          	auipc	ra,0x2
    39a2:	c7a080e7          	jalr	-902(ra) # 5618 <exit>

00000000000039a6 <dirfile>:
{
    39a6:	1101                	addi	sp,sp,-32
    39a8:	ec06                	sd	ra,24(sp)
    39aa:	e822                	sd	s0,16(sp)
    39ac:	e426                	sd	s1,8(sp)
    39ae:	e04a                	sd	s2,0(sp)
    39b0:	1000                	addi	s0,sp,32
    39b2:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    39b4:	20000593          	li	a1,512
    39b8:	00002517          	auipc	a0,0x2
    39bc:	48050513          	addi	a0,a0,1152 # 5e38 <malloc+0x3e2>
    39c0:	00002097          	auipc	ra,0x2
    39c4:	c98080e7          	jalr	-872(ra) # 5658 <open>
  if(fd < 0){
    39c8:	0e054d63          	bltz	a0,3ac2 <dirfile+0x11c>
  close(fd);
    39cc:	00002097          	auipc	ra,0x2
    39d0:	c74080e7          	jalr	-908(ra) # 5640 <close>
  if(chdir("dirfile") == 0){
    39d4:	00002517          	auipc	a0,0x2
    39d8:	46450513          	addi	a0,a0,1124 # 5e38 <malloc+0x3e2>
    39dc:	00002097          	auipc	ra,0x2
    39e0:	cac080e7          	jalr	-852(ra) # 5688 <chdir>
    39e4:	cd6d                	beqz	a0,3ade <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    39e6:	4581                	li	a1,0
    39e8:	00004517          	auipc	a0,0x4
    39ec:	db050513          	addi	a0,a0,-592 # 7798 <malloc+0x1d42>
    39f0:	00002097          	auipc	ra,0x2
    39f4:	c68080e7          	jalr	-920(ra) # 5658 <open>
  if(fd >= 0){
    39f8:	10055163          	bgez	a0,3afa <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    39fc:	20000593          	li	a1,512
    3a00:	00004517          	auipc	a0,0x4
    3a04:	d9850513          	addi	a0,a0,-616 # 7798 <malloc+0x1d42>
    3a08:	00002097          	auipc	ra,0x2
    3a0c:	c50080e7          	jalr	-944(ra) # 5658 <open>
  if(fd >= 0){
    3a10:	10055363          	bgez	a0,3b16 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3a14:	00004517          	auipc	a0,0x4
    3a18:	d8450513          	addi	a0,a0,-636 # 7798 <malloc+0x1d42>
    3a1c:	00002097          	auipc	ra,0x2
    3a20:	c64080e7          	jalr	-924(ra) # 5680 <mkdir>
    3a24:	10050763          	beqz	a0,3b32 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3a28:	00004517          	auipc	a0,0x4
    3a2c:	d7050513          	addi	a0,a0,-656 # 7798 <malloc+0x1d42>
    3a30:	00002097          	auipc	ra,0x2
    3a34:	c38080e7          	jalr	-968(ra) # 5668 <unlink>
    3a38:	10050b63          	beqz	a0,3b4e <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3a3c:	00004597          	auipc	a1,0x4
    3a40:	d5c58593          	addi	a1,a1,-676 # 7798 <malloc+0x1d42>
    3a44:	00002517          	auipc	a0,0x2
    3a48:	5ec50513          	addi	a0,a0,1516 # 6030 <malloc+0x5da>
    3a4c:	00002097          	auipc	ra,0x2
    3a50:	c2c080e7          	jalr	-980(ra) # 5678 <link>
    3a54:	10050b63          	beqz	a0,3b6a <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3a58:	00002517          	auipc	a0,0x2
    3a5c:	3e050513          	addi	a0,a0,992 # 5e38 <malloc+0x3e2>
    3a60:	00002097          	auipc	ra,0x2
    3a64:	c08080e7          	jalr	-1016(ra) # 5668 <unlink>
    3a68:	10051f63          	bnez	a0,3b86 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3a6c:	4589                	li	a1,2
    3a6e:	00003517          	auipc	a0,0x3
    3a72:	ac250513          	addi	a0,a0,-1342 # 6530 <malloc+0xada>
    3a76:	00002097          	auipc	ra,0x2
    3a7a:	be2080e7          	jalr	-1054(ra) # 5658 <open>
  if(fd >= 0){
    3a7e:	12055263          	bgez	a0,3ba2 <dirfile+0x1fc>
  fd = open(".", 0);
    3a82:	4581                	li	a1,0
    3a84:	00003517          	auipc	a0,0x3
    3a88:	aac50513          	addi	a0,a0,-1364 # 6530 <malloc+0xada>
    3a8c:	00002097          	auipc	ra,0x2
    3a90:	bcc080e7          	jalr	-1076(ra) # 5658 <open>
    3a94:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3a96:	4605                	li	a2,1
    3a98:	00002597          	auipc	a1,0x2
    3a9c:	47058593          	addi	a1,a1,1136 # 5f08 <malloc+0x4b2>
    3aa0:	00002097          	auipc	ra,0x2
    3aa4:	b98080e7          	jalr	-1128(ra) # 5638 <write>
    3aa8:	10a04b63          	bgtz	a0,3bbe <dirfile+0x218>
  close(fd);
    3aac:	8526                	mv	a0,s1
    3aae:	00002097          	auipc	ra,0x2
    3ab2:	b92080e7          	jalr	-1134(ra) # 5640 <close>
}
    3ab6:	60e2                	ld	ra,24(sp)
    3ab8:	6442                	ld	s0,16(sp)
    3aba:	64a2                	ld	s1,8(sp)
    3abc:	6902                	ld	s2,0(sp)
    3abe:	6105                	addi	sp,sp,32
    3ac0:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3ac2:	85ca                	mv	a1,s2
    3ac4:	00004517          	auipc	a0,0x4
    3ac8:	c9450513          	addi	a0,a0,-876 # 7758 <malloc+0x1d02>
    3acc:	00002097          	auipc	ra,0x2
    3ad0:	ecc080e7          	jalr	-308(ra) # 5998 <printf>
    exit(1);
    3ad4:	4505                	li	a0,1
    3ad6:	00002097          	auipc	ra,0x2
    3ada:	b42080e7          	jalr	-1214(ra) # 5618 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3ade:	85ca                	mv	a1,s2
    3ae0:	00004517          	auipc	a0,0x4
    3ae4:	c9850513          	addi	a0,a0,-872 # 7778 <malloc+0x1d22>
    3ae8:	00002097          	auipc	ra,0x2
    3aec:	eb0080e7          	jalr	-336(ra) # 5998 <printf>
    exit(1);
    3af0:	4505                	li	a0,1
    3af2:	00002097          	auipc	ra,0x2
    3af6:	b26080e7          	jalr	-1242(ra) # 5618 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3afa:	85ca                	mv	a1,s2
    3afc:	00004517          	auipc	a0,0x4
    3b00:	cac50513          	addi	a0,a0,-852 # 77a8 <malloc+0x1d52>
    3b04:	00002097          	auipc	ra,0x2
    3b08:	e94080e7          	jalr	-364(ra) # 5998 <printf>
    exit(1);
    3b0c:	4505                	li	a0,1
    3b0e:	00002097          	auipc	ra,0x2
    3b12:	b0a080e7          	jalr	-1270(ra) # 5618 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b16:	85ca                	mv	a1,s2
    3b18:	00004517          	auipc	a0,0x4
    3b1c:	c9050513          	addi	a0,a0,-880 # 77a8 <malloc+0x1d52>
    3b20:	00002097          	auipc	ra,0x2
    3b24:	e78080e7          	jalr	-392(ra) # 5998 <printf>
    exit(1);
    3b28:	4505                	li	a0,1
    3b2a:	00002097          	auipc	ra,0x2
    3b2e:	aee080e7          	jalr	-1298(ra) # 5618 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3b32:	85ca                	mv	a1,s2
    3b34:	00004517          	auipc	a0,0x4
    3b38:	c9c50513          	addi	a0,a0,-868 # 77d0 <malloc+0x1d7a>
    3b3c:	00002097          	auipc	ra,0x2
    3b40:	e5c080e7          	jalr	-420(ra) # 5998 <printf>
    exit(1);
    3b44:	4505                	li	a0,1
    3b46:	00002097          	auipc	ra,0x2
    3b4a:	ad2080e7          	jalr	-1326(ra) # 5618 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3b4e:	85ca                	mv	a1,s2
    3b50:	00004517          	auipc	a0,0x4
    3b54:	ca850513          	addi	a0,a0,-856 # 77f8 <malloc+0x1da2>
    3b58:	00002097          	auipc	ra,0x2
    3b5c:	e40080e7          	jalr	-448(ra) # 5998 <printf>
    exit(1);
    3b60:	4505                	li	a0,1
    3b62:	00002097          	auipc	ra,0x2
    3b66:	ab6080e7          	jalr	-1354(ra) # 5618 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3b6a:	85ca                	mv	a1,s2
    3b6c:	00004517          	auipc	a0,0x4
    3b70:	cb450513          	addi	a0,a0,-844 # 7820 <malloc+0x1dca>
    3b74:	00002097          	auipc	ra,0x2
    3b78:	e24080e7          	jalr	-476(ra) # 5998 <printf>
    exit(1);
    3b7c:	4505                	li	a0,1
    3b7e:	00002097          	auipc	ra,0x2
    3b82:	a9a080e7          	jalr	-1382(ra) # 5618 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3b86:	85ca                	mv	a1,s2
    3b88:	00004517          	auipc	a0,0x4
    3b8c:	cc050513          	addi	a0,a0,-832 # 7848 <malloc+0x1df2>
    3b90:	00002097          	auipc	ra,0x2
    3b94:	e08080e7          	jalr	-504(ra) # 5998 <printf>
    exit(1);
    3b98:	4505                	li	a0,1
    3b9a:	00002097          	auipc	ra,0x2
    3b9e:	a7e080e7          	jalr	-1410(ra) # 5618 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3ba2:	85ca                	mv	a1,s2
    3ba4:	00004517          	auipc	a0,0x4
    3ba8:	cc450513          	addi	a0,a0,-828 # 7868 <malloc+0x1e12>
    3bac:	00002097          	auipc	ra,0x2
    3bb0:	dec080e7          	jalr	-532(ra) # 5998 <printf>
    exit(1);
    3bb4:	4505                	li	a0,1
    3bb6:	00002097          	auipc	ra,0x2
    3bba:	a62080e7          	jalr	-1438(ra) # 5618 <exit>
    printf("%s: write . succeeded!\n", s);
    3bbe:	85ca                	mv	a1,s2
    3bc0:	00004517          	auipc	a0,0x4
    3bc4:	cd050513          	addi	a0,a0,-816 # 7890 <malloc+0x1e3a>
    3bc8:	00002097          	auipc	ra,0x2
    3bcc:	dd0080e7          	jalr	-560(ra) # 5998 <printf>
    exit(1);
    3bd0:	4505                	li	a0,1
    3bd2:	00002097          	auipc	ra,0x2
    3bd6:	a46080e7          	jalr	-1466(ra) # 5618 <exit>

0000000000003bda <iref>:
{
    3bda:	7139                	addi	sp,sp,-64
    3bdc:	fc06                	sd	ra,56(sp)
    3bde:	f822                	sd	s0,48(sp)
    3be0:	f426                	sd	s1,40(sp)
    3be2:	f04a                	sd	s2,32(sp)
    3be4:	ec4e                	sd	s3,24(sp)
    3be6:	e852                	sd	s4,16(sp)
    3be8:	e456                	sd	s5,8(sp)
    3bea:	e05a                	sd	s6,0(sp)
    3bec:	0080                	addi	s0,sp,64
    3bee:	8b2a                	mv	s6,a0
    3bf0:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3bf4:	00004a17          	auipc	s4,0x4
    3bf8:	cb4a0a13          	addi	s4,s4,-844 # 78a8 <malloc+0x1e52>
    mkdir("");
    3bfc:	00003497          	auipc	s1,0x3
    3c00:	7bc48493          	addi	s1,s1,1980 # 73b8 <malloc+0x1962>
    link("README", "");
    3c04:	00002a97          	auipc	s5,0x2
    3c08:	42ca8a93          	addi	s5,s5,1068 # 6030 <malloc+0x5da>
    fd = open("xx", O_CREATE);
    3c0c:	00004997          	auipc	s3,0x4
    3c10:	b9498993          	addi	s3,s3,-1132 # 77a0 <malloc+0x1d4a>
    3c14:	a891                	j	3c68 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3c16:	85da                	mv	a1,s6
    3c18:	00004517          	auipc	a0,0x4
    3c1c:	c9850513          	addi	a0,a0,-872 # 78b0 <malloc+0x1e5a>
    3c20:	00002097          	auipc	ra,0x2
    3c24:	d78080e7          	jalr	-648(ra) # 5998 <printf>
      exit(1);
    3c28:	4505                	li	a0,1
    3c2a:	00002097          	auipc	ra,0x2
    3c2e:	9ee080e7          	jalr	-1554(ra) # 5618 <exit>
      printf("%s: chdir irefd failed\n", s);
    3c32:	85da                	mv	a1,s6
    3c34:	00004517          	auipc	a0,0x4
    3c38:	c9450513          	addi	a0,a0,-876 # 78c8 <malloc+0x1e72>
    3c3c:	00002097          	auipc	ra,0x2
    3c40:	d5c080e7          	jalr	-676(ra) # 5998 <printf>
      exit(1);
    3c44:	4505                	li	a0,1
    3c46:	00002097          	auipc	ra,0x2
    3c4a:	9d2080e7          	jalr	-1582(ra) # 5618 <exit>
      close(fd);
    3c4e:	00002097          	auipc	ra,0x2
    3c52:	9f2080e7          	jalr	-1550(ra) # 5640 <close>
    3c56:	a889                	j	3ca8 <iref+0xce>
    unlink("xx");
    3c58:	854e                	mv	a0,s3
    3c5a:	00002097          	auipc	ra,0x2
    3c5e:	a0e080e7          	jalr	-1522(ra) # 5668 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3c62:	397d                	addiw	s2,s2,-1
    3c64:	06090063          	beqz	s2,3cc4 <iref+0xea>
    if(mkdir("irefd") != 0){
    3c68:	8552                	mv	a0,s4
    3c6a:	00002097          	auipc	ra,0x2
    3c6e:	a16080e7          	jalr	-1514(ra) # 5680 <mkdir>
    3c72:	f155                	bnez	a0,3c16 <iref+0x3c>
    if(chdir("irefd") != 0){
    3c74:	8552                	mv	a0,s4
    3c76:	00002097          	auipc	ra,0x2
    3c7a:	a12080e7          	jalr	-1518(ra) # 5688 <chdir>
    3c7e:	f955                	bnez	a0,3c32 <iref+0x58>
    mkdir("");
    3c80:	8526                	mv	a0,s1
    3c82:	00002097          	auipc	ra,0x2
    3c86:	9fe080e7          	jalr	-1538(ra) # 5680 <mkdir>
    link("README", "");
    3c8a:	85a6                	mv	a1,s1
    3c8c:	8556                	mv	a0,s5
    3c8e:	00002097          	auipc	ra,0x2
    3c92:	9ea080e7          	jalr	-1558(ra) # 5678 <link>
    fd = open("", O_CREATE);
    3c96:	20000593          	li	a1,512
    3c9a:	8526                	mv	a0,s1
    3c9c:	00002097          	auipc	ra,0x2
    3ca0:	9bc080e7          	jalr	-1604(ra) # 5658 <open>
    if(fd >= 0)
    3ca4:	fa0555e3          	bgez	a0,3c4e <iref+0x74>
    fd = open("xx", O_CREATE);
    3ca8:	20000593          	li	a1,512
    3cac:	854e                	mv	a0,s3
    3cae:	00002097          	auipc	ra,0x2
    3cb2:	9aa080e7          	jalr	-1622(ra) # 5658 <open>
    if(fd >= 0)
    3cb6:	fa0541e3          	bltz	a0,3c58 <iref+0x7e>
      close(fd);
    3cba:	00002097          	auipc	ra,0x2
    3cbe:	986080e7          	jalr	-1658(ra) # 5640 <close>
    3cc2:	bf59                	j	3c58 <iref+0x7e>
    3cc4:	03300493          	li	s1,51
    chdir("..");
    3cc8:	00003997          	auipc	s3,0x3
    3ccc:	41098993          	addi	s3,s3,1040 # 70d8 <malloc+0x1682>
    unlink("irefd");
    3cd0:	00004917          	auipc	s2,0x4
    3cd4:	bd890913          	addi	s2,s2,-1064 # 78a8 <malloc+0x1e52>
    chdir("..");
    3cd8:	854e                	mv	a0,s3
    3cda:	00002097          	auipc	ra,0x2
    3cde:	9ae080e7          	jalr	-1618(ra) # 5688 <chdir>
    unlink("irefd");
    3ce2:	854a                	mv	a0,s2
    3ce4:	00002097          	auipc	ra,0x2
    3ce8:	984080e7          	jalr	-1660(ra) # 5668 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3cec:	34fd                	addiw	s1,s1,-1
    3cee:	f4ed                	bnez	s1,3cd8 <iref+0xfe>
  chdir("/");
    3cf0:	00003517          	auipc	a0,0x3
    3cf4:	39050513          	addi	a0,a0,912 # 7080 <malloc+0x162a>
    3cf8:	00002097          	auipc	ra,0x2
    3cfc:	990080e7          	jalr	-1648(ra) # 5688 <chdir>
}
    3d00:	70e2                	ld	ra,56(sp)
    3d02:	7442                	ld	s0,48(sp)
    3d04:	74a2                	ld	s1,40(sp)
    3d06:	7902                	ld	s2,32(sp)
    3d08:	69e2                	ld	s3,24(sp)
    3d0a:	6a42                	ld	s4,16(sp)
    3d0c:	6aa2                	ld	s5,8(sp)
    3d0e:	6b02                	ld	s6,0(sp)
    3d10:	6121                	addi	sp,sp,64
    3d12:	8082                	ret

0000000000003d14 <openiputtest>:
{
    3d14:	7179                	addi	sp,sp,-48
    3d16:	f406                	sd	ra,40(sp)
    3d18:	f022                	sd	s0,32(sp)
    3d1a:	ec26                	sd	s1,24(sp)
    3d1c:	1800                	addi	s0,sp,48
    3d1e:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3d20:	00004517          	auipc	a0,0x4
    3d24:	bc050513          	addi	a0,a0,-1088 # 78e0 <malloc+0x1e8a>
    3d28:	00002097          	auipc	ra,0x2
    3d2c:	958080e7          	jalr	-1704(ra) # 5680 <mkdir>
    3d30:	04054263          	bltz	a0,3d74 <openiputtest+0x60>
  pid = fork();
    3d34:	00002097          	auipc	ra,0x2
    3d38:	8dc080e7          	jalr	-1828(ra) # 5610 <fork>
  if(pid < 0){
    3d3c:	04054a63          	bltz	a0,3d90 <openiputtest+0x7c>
  if(pid == 0){
    3d40:	e93d                	bnez	a0,3db6 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3d42:	4589                	li	a1,2
    3d44:	00004517          	auipc	a0,0x4
    3d48:	b9c50513          	addi	a0,a0,-1124 # 78e0 <malloc+0x1e8a>
    3d4c:	00002097          	auipc	ra,0x2
    3d50:	90c080e7          	jalr	-1780(ra) # 5658 <open>
    if(fd >= 0){
    3d54:	04054c63          	bltz	a0,3dac <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3d58:	85a6                	mv	a1,s1
    3d5a:	00004517          	auipc	a0,0x4
    3d5e:	ba650513          	addi	a0,a0,-1114 # 7900 <malloc+0x1eaa>
    3d62:	00002097          	auipc	ra,0x2
    3d66:	c36080e7          	jalr	-970(ra) # 5998 <printf>
      exit(1);
    3d6a:	4505                	li	a0,1
    3d6c:	00002097          	auipc	ra,0x2
    3d70:	8ac080e7          	jalr	-1876(ra) # 5618 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3d74:	85a6                	mv	a1,s1
    3d76:	00004517          	auipc	a0,0x4
    3d7a:	b7250513          	addi	a0,a0,-1166 # 78e8 <malloc+0x1e92>
    3d7e:	00002097          	auipc	ra,0x2
    3d82:	c1a080e7          	jalr	-998(ra) # 5998 <printf>
    exit(1);
    3d86:	4505                	li	a0,1
    3d88:	00002097          	auipc	ra,0x2
    3d8c:	890080e7          	jalr	-1904(ra) # 5618 <exit>
    printf("%s: fork failed\n", s);
    3d90:	85a6                	mv	a1,s1
    3d92:	00003517          	auipc	a0,0x3
    3d96:	93e50513          	addi	a0,a0,-1730 # 66d0 <malloc+0xc7a>
    3d9a:	00002097          	auipc	ra,0x2
    3d9e:	bfe080e7          	jalr	-1026(ra) # 5998 <printf>
    exit(1);
    3da2:	4505                	li	a0,1
    3da4:	00002097          	auipc	ra,0x2
    3da8:	874080e7          	jalr	-1932(ra) # 5618 <exit>
    exit(0);
    3dac:	4501                	li	a0,0
    3dae:	00002097          	auipc	ra,0x2
    3db2:	86a080e7          	jalr	-1942(ra) # 5618 <exit>
  sleep(1);
    3db6:	4505                	li	a0,1
    3db8:	00002097          	auipc	ra,0x2
    3dbc:	8f0080e7          	jalr	-1808(ra) # 56a8 <sleep>
  if(unlink("oidir") != 0){
    3dc0:	00004517          	auipc	a0,0x4
    3dc4:	b2050513          	addi	a0,a0,-1248 # 78e0 <malloc+0x1e8a>
    3dc8:	00002097          	auipc	ra,0x2
    3dcc:	8a0080e7          	jalr	-1888(ra) # 5668 <unlink>
    3dd0:	cd19                	beqz	a0,3dee <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3dd2:	85a6                	mv	a1,s1
    3dd4:	00003517          	auipc	a0,0x3
    3dd8:	aec50513          	addi	a0,a0,-1300 # 68c0 <malloc+0xe6a>
    3ddc:	00002097          	auipc	ra,0x2
    3de0:	bbc080e7          	jalr	-1092(ra) # 5998 <printf>
    exit(1);
    3de4:	4505                	li	a0,1
    3de6:	00002097          	auipc	ra,0x2
    3dea:	832080e7          	jalr	-1998(ra) # 5618 <exit>
  wait(&xstatus);
    3dee:	fdc40513          	addi	a0,s0,-36
    3df2:	00002097          	auipc	ra,0x2
    3df6:	82e080e7          	jalr	-2002(ra) # 5620 <wait>
  exit(xstatus);
    3dfa:	fdc42503          	lw	a0,-36(s0)
    3dfe:	00002097          	auipc	ra,0x2
    3e02:	81a080e7          	jalr	-2022(ra) # 5618 <exit>

0000000000003e06 <forkforkfork>:
{
    3e06:	1101                	addi	sp,sp,-32
    3e08:	ec06                	sd	ra,24(sp)
    3e0a:	e822                	sd	s0,16(sp)
    3e0c:	e426                	sd	s1,8(sp)
    3e0e:	1000                	addi	s0,sp,32
    3e10:	84aa                	mv	s1,a0
  unlink("stopforking");
    3e12:	00004517          	auipc	a0,0x4
    3e16:	b1650513          	addi	a0,a0,-1258 # 7928 <malloc+0x1ed2>
    3e1a:	00002097          	auipc	ra,0x2
    3e1e:	84e080e7          	jalr	-1970(ra) # 5668 <unlink>
  int pid = fork();
    3e22:	00001097          	auipc	ra,0x1
    3e26:	7ee080e7          	jalr	2030(ra) # 5610 <fork>
  if(pid < 0){
    3e2a:	04054563          	bltz	a0,3e74 <forkforkfork+0x6e>
  if(pid == 0){
    3e2e:	c12d                	beqz	a0,3e90 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3e30:	4551                	li	a0,20
    3e32:	00002097          	auipc	ra,0x2
    3e36:	876080e7          	jalr	-1930(ra) # 56a8 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3e3a:	20200593          	li	a1,514
    3e3e:	00004517          	auipc	a0,0x4
    3e42:	aea50513          	addi	a0,a0,-1302 # 7928 <malloc+0x1ed2>
    3e46:	00002097          	auipc	ra,0x2
    3e4a:	812080e7          	jalr	-2030(ra) # 5658 <open>
    3e4e:	00001097          	auipc	ra,0x1
    3e52:	7f2080e7          	jalr	2034(ra) # 5640 <close>
  wait(0);
    3e56:	4501                	li	a0,0
    3e58:	00001097          	auipc	ra,0x1
    3e5c:	7c8080e7          	jalr	1992(ra) # 5620 <wait>
  sleep(10); // one second
    3e60:	4529                	li	a0,10
    3e62:	00002097          	auipc	ra,0x2
    3e66:	846080e7          	jalr	-1978(ra) # 56a8 <sleep>
}
    3e6a:	60e2                	ld	ra,24(sp)
    3e6c:	6442                	ld	s0,16(sp)
    3e6e:	64a2                	ld	s1,8(sp)
    3e70:	6105                	addi	sp,sp,32
    3e72:	8082                	ret
    printf("%s: fork failed", s);
    3e74:	85a6                	mv	a1,s1
    3e76:	00003517          	auipc	a0,0x3
    3e7a:	a1a50513          	addi	a0,a0,-1510 # 6890 <malloc+0xe3a>
    3e7e:	00002097          	auipc	ra,0x2
    3e82:	b1a080e7          	jalr	-1254(ra) # 5998 <printf>
    exit(1);
    3e86:	4505                	li	a0,1
    3e88:	00001097          	auipc	ra,0x1
    3e8c:	790080e7          	jalr	1936(ra) # 5618 <exit>
      int fd = open("stopforking", 0);
    3e90:	00004497          	auipc	s1,0x4
    3e94:	a9848493          	addi	s1,s1,-1384 # 7928 <malloc+0x1ed2>
    3e98:	4581                	li	a1,0
    3e9a:	8526                	mv	a0,s1
    3e9c:	00001097          	auipc	ra,0x1
    3ea0:	7bc080e7          	jalr	1980(ra) # 5658 <open>
      if(fd >= 0){
    3ea4:	02055463          	bgez	a0,3ecc <forkforkfork+0xc6>
      if(fork() < 0){
    3ea8:	00001097          	auipc	ra,0x1
    3eac:	768080e7          	jalr	1896(ra) # 5610 <fork>
    3eb0:	fe0554e3          	bgez	a0,3e98 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3eb4:	20200593          	li	a1,514
    3eb8:	8526                	mv	a0,s1
    3eba:	00001097          	auipc	ra,0x1
    3ebe:	79e080e7          	jalr	1950(ra) # 5658 <open>
    3ec2:	00001097          	auipc	ra,0x1
    3ec6:	77e080e7          	jalr	1918(ra) # 5640 <close>
    3eca:	b7f9                	j	3e98 <forkforkfork+0x92>
        exit(0);
    3ecc:	4501                	li	a0,0
    3ece:	00001097          	auipc	ra,0x1
    3ed2:	74a080e7          	jalr	1866(ra) # 5618 <exit>

0000000000003ed6 <preempt>:
{
    3ed6:	7139                	addi	sp,sp,-64
    3ed8:	fc06                	sd	ra,56(sp)
    3eda:	f822                	sd	s0,48(sp)
    3edc:	f426                	sd	s1,40(sp)
    3ede:	f04a                	sd	s2,32(sp)
    3ee0:	ec4e                	sd	s3,24(sp)
    3ee2:	e852                	sd	s4,16(sp)
    3ee4:	0080                	addi	s0,sp,64
    3ee6:	84aa                	mv	s1,a0
  pid1 = fork();
    3ee8:	00001097          	auipc	ra,0x1
    3eec:	728080e7          	jalr	1832(ra) # 5610 <fork>
  if(pid1 < 0) {
    3ef0:	00054563          	bltz	a0,3efa <preempt+0x24>
    3ef4:	8a2a                	mv	s4,a0
  if(pid1 == 0)
    3ef6:	e105                	bnez	a0,3f16 <preempt+0x40>
    for(;;)
    3ef8:	a001                	j	3ef8 <preempt+0x22>
    printf("%s: fork failed", s);
    3efa:	85a6                	mv	a1,s1
    3efc:	00003517          	auipc	a0,0x3
    3f00:	99450513          	addi	a0,a0,-1644 # 6890 <malloc+0xe3a>
    3f04:	00002097          	auipc	ra,0x2
    3f08:	a94080e7          	jalr	-1388(ra) # 5998 <printf>
    exit(1);
    3f0c:	4505                	li	a0,1
    3f0e:	00001097          	auipc	ra,0x1
    3f12:	70a080e7          	jalr	1802(ra) # 5618 <exit>
  pid2 = fork();
    3f16:	00001097          	auipc	ra,0x1
    3f1a:	6fa080e7          	jalr	1786(ra) # 5610 <fork>
    3f1e:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3f20:	00054463          	bltz	a0,3f28 <preempt+0x52>
  if(pid2 == 0)
    3f24:	e105                	bnez	a0,3f44 <preempt+0x6e>
    for(;;)
    3f26:	a001                	j	3f26 <preempt+0x50>
    printf("%s: fork failed\n", s);
    3f28:	85a6                	mv	a1,s1
    3f2a:	00002517          	auipc	a0,0x2
    3f2e:	7a650513          	addi	a0,a0,1958 # 66d0 <malloc+0xc7a>
    3f32:	00002097          	auipc	ra,0x2
    3f36:	a66080e7          	jalr	-1434(ra) # 5998 <printf>
    exit(1);
    3f3a:	4505                	li	a0,1
    3f3c:	00001097          	auipc	ra,0x1
    3f40:	6dc080e7          	jalr	1756(ra) # 5618 <exit>
  pipe(pfds);
    3f44:	fc840513          	addi	a0,s0,-56
    3f48:	00001097          	auipc	ra,0x1
    3f4c:	6e0080e7          	jalr	1760(ra) # 5628 <pipe>
  pid3 = fork();
    3f50:	00001097          	auipc	ra,0x1
    3f54:	6c0080e7          	jalr	1728(ra) # 5610 <fork>
    3f58:	892a                	mv	s2,a0
  if(pid3 < 0) {
    3f5a:	02054e63          	bltz	a0,3f96 <preempt+0xc0>
  if(pid3 == 0){
    3f5e:	e525                	bnez	a0,3fc6 <preempt+0xf0>
    close(pfds[0]);
    3f60:	fc842503          	lw	a0,-56(s0)
    3f64:	00001097          	auipc	ra,0x1
    3f68:	6dc080e7          	jalr	1756(ra) # 5640 <close>
    if(write(pfds[1], "x", 1) != 1)
    3f6c:	4605                	li	a2,1
    3f6e:	00002597          	auipc	a1,0x2
    3f72:	f9a58593          	addi	a1,a1,-102 # 5f08 <malloc+0x4b2>
    3f76:	fcc42503          	lw	a0,-52(s0)
    3f7a:	00001097          	auipc	ra,0x1
    3f7e:	6be080e7          	jalr	1726(ra) # 5638 <write>
    3f82:	4785                	li	a5,1
    3f84:	02f51763          	bne	a0,a5,3fb2 <preempt+0xdc>
    close(pfds[1]);
    3f88:	fcc42503          	lw	a0,-52(s0)
    3f8c:	00001097          	auipc	ra,0x1
    3f90:	6b4080e7          	jalr	1716(ra) # 5640 <close>
    for(;;)
    3f94:	a001                	j	3f94 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3f96:	85a6                	mv	a1,s1
    3f98:	00002517          	auipc	a0,0x2
    3f9c:	73850513          	addi	a0,a0,1848 # 66d0 <malloc+0xc7a>
    3fa0:	00002097          	auipc	ra,0x2
    3fa4:	9f8080e7          	jalr	-1544(ra) # 5998 <printf>
     exit(1);
    3fa8:	4505                	li	a0,1
    3faa:	00001097          	auipc	ra,0x1
    3fae:	66e080e7          	jalr	1646(ra) # 5618 <exit>
      printf("%s: preempt write error", s);
    3fb2:	85a6                	mv	a1,s1
    3fb4:	00004517          	auipc	a0,0x4
    3fb8:	98450513          	addi	a0,a0,-1660 # 7938 <malloc+0x1ee2>
    3fbc:	00002097          	auipc	ra,0x2
    3fc0:	9dc080e7          	jalr	-1572(ra) # 5998 <printf>
    3fc4:	b7d1                	j	3f88 <preempt+0xb2>
  close(pfds[1]);
    3fc6:	fcc42503          	lw	a0,-52(s0)
    3fca:	00001097          	auipc	ra,0x1
    3fce:	676080e7          	jalr	1654(ra) # 5640 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3fd2:	660d                	lui	a2,0x3
    3fd4:	00008597          	auipc	a1,0x8
    3fd8:	adc58593          	addi	a1,a1,-1316 # bab0 <buf>
    3fdc:	fc842503          	lw	a0,-56(s0)
    3fe0:	00001097          	auipc	ra,0x1
    3fe4:	650080e7          	jalr	1616(ra) # 5630 <read>
    3fe8:	4785                	li	a5,1
    3fea:	02f50363          	beq	a0,a5,4010 <preempt+0x13a>
    printf("%s: preempt read error", s);
    3fee:	85a6                	mv	a1,s1
    3ff0:	00004517          	auipc	a0,0x4
    3ff4:	96050513          	addi	a0,a0,-1696 # 7950 <malloc+0x1efa>
    3ff8:	00002097          	auipc	ra,0x2
    3ffc:	9a0080e7          	jalr	-1632(ra) # 5998 <printf>
}
    4000:	70e2                	ld	ra,56(sp)
    4002:	7442                	ld	s0,48(sp)
    4004:	74a2                	ld	s1,40(sp)
    4006:	7902                	ld	s2,32(sp)
    4008:	69e2                	ld	s3,24(sp)
    400a:	6a42                	ld	s4,16(sp)
    400c:	6121                	addi	sp,sp,64
    400e:	8082                	ret
  close(pfds[0]);
    4010:	fc842503          	lw	a0,-56(s0)
    4014:	00001097          	auipc	ra,0x1
    4018:	62c080e7          	jalr	1580(ra) # 5640 <close>
  printf("kill... ");
    401c:	00004517          	auipc	a0,0x4
    4020:	94c50513          	addi	a0,a0,-1716 # 7968 <malloc+0x1f12>
    4024:	00002097          	auipc	ra,0x2
    4028:	974080e7          	jalr	-1676(ra) # 5998 <printf>
  kill(pid1);
    402c:	8552                	mv	a0,s4
    402e:	00001097          	auipc	ra,0x1
    4032:	61a080e7          	jalr	1562(ra) # 5648 <kill>
  kill(pid2);
    4036:	854e                	mv	a0,s3
    4038:	00001097          	auipc	ra,0x1
    403c:	610080e7          	jalr	1552(ra) # 5648 <kill>
  kill(pid3);
    4040:	854a                	mv	a0,s2
    4042:	00001097          	auipc	ra,0x1
    4046:	606080e7          	jalr	1542(ra) # 5648 <kill>
  printf("wait... ");
    404a:	00004517          	auipc	a0,0x4
    404e:	92e50513          	addi	a0,a0,-1746 # 7978 <malloc+0x1f22>
    4052:	00002097          	auipc	ra,0x2
    4056:	946080e7          	jalr	-1722(ra) # 5998 <printf>
  wait(0);
    405a:	4501                	li	a0,0
    405c:	00001097          	auipc	ra,0x1
    4060:	5c4080e7          	jalr	1476(ra) # 5620 <wait>
  wait(0);
    4064:	4501                	li	a0,0
    4066:	00001097          	auipc	ra,0x1
    406a:	5ba080e7          	jalr	1466(ra) # 5620 <wait>
  wait(0);
    406e:	4501                	li	a0,0
    4070:	00001097          	auipc	ra,0x1
    4074:	5b0080e7          	jalr	1456(ra) # 5620 <wait>
    4078:	b761                	j	4000 <preempt+0x12a>

000000000000407a <sbrkfail>:
{
    407a:	7119                	addi	sp,sp,-128
    407c:	fc86                	sd	ra,120(sp)
    407e:	f8a2                	sd	s0,112(sp)
    4080:	f4a6                	sd	s1,104(sp)
    4082:	f0ca                	sd	s2,96(sp)
    4084:	ecce                	sd	s3,88(sp)
    4086:	e8d2                	sd	s4,80(sp)
    4088:	e4d6                	sd	s5,72(sp)
    408a:	0100                	addi	s0,sp,128
    408c:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    408e:	fb040513          	addi	a0,s0,-80
    4092:	00001097          	auipc	ra,0x1
    4096:	596080e7          	jalr	1430(ra) # 5628 <pipe>
    409a:	e901                	bnez	a0,40aa <sbrkfail+0x30>
    409c:	f8040493          	addi	s1,s0,-128
    40a0:	fa840a13          	addi	s4,s0,-88
    40a4:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    40a6:	5afd                	li	s5,-1
    40a8:	a08d                	j	410a <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    40aa:	85ca                	mv	a1,s2
    40ac:	00002517          	auipc	a0,0x2
    40b0:	72c50513          	addi	a0,a0,1836 # 67d8 <malloc+0xd82>
    40b4:	00002097          	auipc	ra,0x2
    40b8:	8e4080e7          	jalr	-1820(ra) # 5998 <printf>
    exit(1);
    40bc:	4505                	li	a0,1
    40be:	00001097          	auipc	ra,0x1
    40c2:	55a080e7          	jalr	1370(ra) # 5618 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    40c6:	4501                	li	a0,0
    40c8:	00001097          	auipc	ra,0x1
    40cc:	5d8080e7          	jalr	1496(ra) # 56a0 <sbrk>
    40d0:	064007b7          	lui	a5,0x6400
    40d4:	40a7853b          	subw	a0,a5,a0
    40d8:	00001097          	auipc	ra,0x1
    40dc:	5c8080e7          	jalr	1480(ra) # 56a0 <sbrk>
      write(fds[1], "x", 1);
    40e0:	4605                	li	a2,1
    40e2:	00002597          	auipc	a1,0x2
    40e6:	e2658593          	addi	a1,a1,-474 # 5f08 <malloc+0x4b2>
    40ea:	fb442503          	lw	a0,-76(s0)
    40ee:	00001097          	auipc	ra,0x1
    40f2:	54a080e7          	jalr	1354(ra) # 5638 <write>
      for(;;) sleep(1000);
    40f6:	3e800513          	li	a0,1000
    40fa:	00001097          	auipc	ra,0x1
    40fe:	5ae080e7          	jalr	1454(ra) # 56a8 <sleep>
    4102:	bfd5                	j	40f6 <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4104:	0991                	addi	s3,s3,4
    4106:	03498563          	beq	s3,s4,4130 <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    410a:	00001097          	auipc	ra,0x1
    410e:	506080e7          	jalr	1286(ra) # 5610 <fork>
    4112:	00a9a023          	sw	a0,0(s3)
    4116:	d945                	beqz	a0,40c6 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4118:	ff5506e3          	beq	a0,s5,4104 <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    411c:	4605                	li	a2,1
    411e:	faf40593          	addi	a1,s0,-81
    4122:	fb042503          	lw	a0,-80(s0)
    4126:	00001097          	auipc	ra,0x1
    412a:	50a080e7          	jalr	1290(ra) # 5630 <read>
    412e:	bfd9                	j	4104 <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    4130:	6505                	lui	a0,0x1
    4132:	00001097          	auipc	ra,0x1
    4136:	56e080e7          	jalr	1390(ra) # 56a0 <sbrk>
    413a:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    413c:	5afd                	li	s5,-1
    413e:	a021                	j	4146 <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4140:	0491                	addi	s1,s1,4
    4142:	01448f63          	beq	s1,s4,4160 <sbrkfail+0xe6>
    if(pids[i] == -1)
    4146:	4088                	lw	a0,0(s1)
    4148:	ff550ce3          	beq	a0,s5,4140 <sbrkfail+0xc6>
    kill(pids[i]);
    414c:	00001097          	auipc	ra,0x1
    4150:	4fc080e7          	jalr	1276(ra) # 5648 <kill>
    wait(0);
    4154:	4501                	li	a0,0
    4156:	00001097          	auipc	ra,0x1
    415a:	4ca080e7          	jalr	1226(ra) # 5620 <wait>
    415e:	b7cd                	j	4140 <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    4160:	57fd                	li	a5,-1
    4162:	04f98163          	beq	s3,a5,41a4 <sbrkfail+0x12a>
  pid = fork();
    4166:	00001097          	auipc	ra,0x1
    416a:	4aa080e7          	jalr	1194(ra) # 5610 <fork>
    416e:	84aa                	mv	s1,a0
  if(pid < 0){
    4170:	04054863          	bltz	a0,41c0 <sbrkfail+0x146>
  if(pid == 0){
    4174:	c525                	beqz	a0,41dc <sbrkfail+0x162>
  wait(&xstatus);
    4176:	fbc40513          	addi	a0,s0,-68
    417a:	00001097          	auipc	ra,0x1
    417e:	4a6080e7          	jalr	1190(ra) # 5620 <wait>
  if(xstatus != -1 && xstatus != 2)
    4182:	fbc42783          	lw	a5,-68(s0)
    4186:	577d                	li	a4,-1
    4188:	00e78563          	beq	a5,a4,4192 <sbrkfail+0x118>
    418c:	4709                	li	a4,2
    418e:	08e79d63          	bne	a5,a4,4228 <sbrkfail+0x1ae>
}
    4192:	70e6                	ld	ra,120(sp)
    4194:	7446                	ld	s0,112(sp)
    4196:	74a6                	ld	s1,104(sp)
    4198:	7906                	ld	s2,96(sp)
    419a:	69e6                	ld	s3,88(sp)
    419c:	6a46                	ld	s4,80(sp)
    419e:	6aa6                	ld	s5,72(sp)
    41a0:	6109                	addi	sp,sp,128
    41a2:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    41a4:	85ca                	mv	a1,s2
    41a6:	00003517          	auipc	a0,0x3
    41aa:	7e250513          	addi	a0,a0,2018 # 7988 <malloc+0x1f32>
    41ae:	00001097          	auipc	ra,0x1
    41b2:	7ea080e7          	jalr	2026(ra) # 5998 <printf>
    exit(1);
    41b6:	4505                	li	a0,1
    41b8:	00001097          	auipc	ra,0x1
    41bc:	460080e7          	jalr	1120(ra) # 5618 <exit>
    printf("%s: fork failed\n", s);
    41c0:	85ca                	mv	a1,s2
    41c2:	00002517          	auipc	a0,0x2
    41c6:	50e50513          	addi	a0,a0,1294 # 66d0 <malloc+0xc7a>
    41ca:	00001097          	auipc	ra,0x1
    41ce:	7ce080e7          	jalr	1998(ra) # 5998 <printf>
    exit(1);
    41d2:	4505                	li	a0,1
    41d4:	00001097          	auipc	ra,0x1
    41d8:	444080e7          	jalr	1092(ra) # 5618 <exit>
    a = sbrk(0);
    41dc:	4501                	li	a0,0
    41de:	00001097          	auipc	ra,0x1
    41e2:	4c2080e7          	jalr	1218(ra) # 56a0 <sbrk>
    41e6:	89aa                	mv	s3,a0
    sbrk(10*BIG);
    41e8:	3e800537          	lui	a0,0x3e800
    41ec:	00001097          	auipc	ra,0x1
    41f0:	4b4080e7          	jalr	1204(ra) # 56a0 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    41f4:	874e                	mv	a4,s3
    41f6:	3e8007b7          	lui	a5,0x3e800
    41fa:	97ce                	add	a5,a5,s3
    41fc:	6685                	lui	a3,0x1
      n += *(a+i);
    41fe:	00074603          	lbu	a2,0(a4)
    4202:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4204:	9736                	add	a4,a4,a3
    4206:	fef71ce3          	bne	a4,a5,41fe <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    420a:	8626                	mv	a2,s1
    420c:	85ca                	mv	a1,s2
    420e:	00003517          	auipc	a0,0x3
    4212:	79a50513          	addi	a0,a0,1946 # 79a8 <malloc+0x1f52>
    4216:	00001097          	auipc	ra,0x1
    421a:	782080e7          	jalr	1922(ra) # 5998 <printf>
    exit(1);
    421e:	4505                	li	a0,1
    4220:	00001097          	auipc	ra,0x1
    4224:	3f8080e7          	jalr	1016(ra) # 5618 <exit>
    exit(1);
    4228:	4505                	li	a0,1
    422a:	00001097          	auipc	ra,0x1
    422e:	3ee080e7          	jalr	1006(ra) # 5618 <exit>

0000000000004232 <reparent>:
{
    4232:	7179                	addi	sp,sp,-48
    4234:	f406                	sd	ra,40(sp)
    4236:	f022                	sd	s0,32(sp)
    4238:	ec26                	sd	s1,24(sp)
    423a:	e84a                	sd	s2,16(sp)
    423c:	e44e                	sd	s3,8(sp)
    423e:	e052                	sd	s4,0(sp)
    4240:	1800                	addi	s0,sp,48
    4242:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4244:	00001097          	auipc	ra,0x1
    4248:	454080e7          	jalr	1108(ra) # 5698 <getpid>
    424c:	8a2a                	mv	s4,a0
    424e:	0c800913          	li	s2,200
    int pid = fork();
    4252:	00001097          	auipc	ra,0x1
    4256:	3be080e7          	jalr	958(ra) # 5610 <fork>
    425a:	84aa                	mv	s1,a0
    if(pid < 0){
    425c:	02054263          	bltz	a0,4280 <reparent+0x4e>
    if(pid){
    4260:	cd21                	beqz	a0,42b8 <reparent+0x86>
      if(wait(0) != pid){
    4262:	4501                	li	a0,0
    4264:	00001097          	auipc	ra,0x1
    4268:	3bc080e7          	jalr	956(ra) # 5620 <wait>
    426c:	02951863          	bne	a0,s1,429c <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4270:	397d                	addiw	s2,s2,-1
    4272:	fe0910e3          	bnez	s2,4252 <reparent+0x20>
  exit(0);
    4276:	4501                	li	a0,0
    4278:	00001097          	auipc	ra,0x1
    427c:	3a0080e7          	jalr	928(ra) # 5618 <exit>
      printf("%s: fork failed\n", s);
    4280:	85ce                	mv	a1,s3
    4282:	00002517          	auipc	a0,0x2
    4286:	44e50513          	addi	a0,a0,1102 # 66d0 <malloc+0xc7a>
    428a:	00001097          	auipc	ra,0x1
    428e:	70e080e7          	jalr	1806(ra) # 5998 <printf>
      exit(1);
    4292:	4505                	li	a0,1
    4294:	00001097          	auipc	ra,0x1
    4298:	384080e7          	jalr	900(ra) # 5618 <exit>
        printf("%s: wait wrong pid\n", s);
    429c:	85ce                	mv	a1,s3
    429e:	00002517          	auipc	a0,0x2
    42a2:	5ba50513          	addi	a0,a0,1466 # 6858 <malloc+0xe02>
    42a6:	00001097          	auipc	ra,0x1
    42aa:	6f2080e7          	jalr	1778(ra) # 5998 <printf>
        exit(1);
    42ae:	4505                	li	a0,1
    42b0:	00001097          	auipc	ra,0x1
    42b4:	368080e7          	jalr	872(ra) # 5618 <exit>
      int pid2 = fork();
    42b8:	00001097          	auipc	ra,0x1
    42bc:	358080e7          	jalr	856(ra) # 5610 <fork>
      if(pid2 < 0){
    42c0:	00054763          	bltz	a0,42ce <reparent+0x9c>
      exit(0);
    42c4:	4501                	li	a0,0
    42c6:	00001097          	auipc	ra,0x1
    42ca:	352080e7          	jalr	850(ra) # 5618 <exit>
        kill(master_pid);
    42ce:	8552                	mv	a0,s4
    42d0:	00001097          	auipc	ra,0x1
    42d4:	378080e7          	jalr	888(ra) # 5648 <kill>
        exit(1);
    42d8:	4505                	li	a0,1
    42da:	00001097          	auipc	ra,0x1
    42de:	33e080e7          	jalr	830(ra) # 5618 <exit>

00000000000042e2 <mem>:
{
    42e2:	7139                	addi	sp,sp,-64
    42e4:	fc06                	sd	ra,56(sp)
    42e6:	f822                	sd	s0,48(sp)
    42e8:	f426                	sd	s1,40(sp)
    42ea:	f04a                	sd	s2,32(sp)
    42ec:	ec4e                	sd	s3,24(sp)
    42ee:	0080                	addi	s0,sp,64
    42f0:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    42f2:	00001097          	auipc	ra,0x1
    42f6:	31e080e7          	jalr	798(ra) # 5610 <fork>
    m1 = 0;
    42fa:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    42fc:	6909                	lui	s2,0x2
    42fe:	71190913          	addi	s2,s2,1809 # 2711 <sbrkbasic+0x157>
  if((pid = fork()) == 0){
    4302:	ed39                	bnez	a0,4360 <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    4304:	854a                	mv	a0,s2
    4306:	00001097          	auipc	ra,0x1
    430a:	750080e7          	jalr	1872(ra) # 5a56 <malloc>
    430e:	c501                	beqz	a0,4316 <mem+0x34>
      *(char**)m2 = m1;
    4310:	e104                	sd	s1,0(a0)
      m1 = m2;
    4312:	84aa                	mv	s1,a0
    4314:	bfc5                	j	4304 <mem+0x22>
    while(m1){
    4316:	c881                	beqz	s1,4326 <mem+0x44>
      m2 = *(char**)m1;
    4318:	8526                	mv	a0,s1
    431a:	6084                	ld	s1,0(s1)
      free(m1);
    431c:	00001097          	auipc	ra,0x1
    4320:	6b2080e7          	jalr	1714(ra) # 59ce <free>
    while(m1){
    4324:	f8f5                	bnez	s1,4318 <mem+0x36>
    m1 = malloc(1024*20);
    4326:	6515                	lui	a0,0x5
    4328:	00001097          	auipc	ra,0x1
    432c:	72e080e7          	jalr	1838(ra) # 5a56 <malloc>
    if(m1 == 0){
    4330:	c911                	beqz	a0,4344 <mem+0x62>
    free(m1);
    4332:	00001097          	auipc	ra,0x1
    4336:	69c080e7          	jalr	1692(ra) # 59ce <free>
    exit(0);
    433a:	4501                	li	a0,0
    433c:	00001097          	auipc	ra,0x1
    4340:	2dc080e7          	jalr	732(ra) # 5618 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4344:	85ce                	mv	a1,s3
    4346:	00003517          	auipc	a0,0x3
    434a:	69250513          	addi	a0,a0,1682 # 79d8 <malloc+0x1f82>
    434e:	00001097          	auipc	ra,0x1
    4352:	64a080e7          	jalr	1610(ra) # 5998 <printf>
      exit(1);
    4356:	4505                	li	a0,1
    4358:	00001097          	auipc	ra,0x1
    435c:	2c0080e7          	jalr	704(ra) # 5618 <exit>
    wait(&xstatus);
    4360:	fcc40513          	addi	a0,s0,-52
    4364:	00001097          	auipc	ra,0x1
    4368:	2bc080e7          	jalr	700(ra) # 5620 <wait>
    if(xstatus == -1){
    436c:	fcc42503          	lw	a0,-52(s0)
    4370:	57fd                	li	a5,-1
    4372:	00f50663          	beq	a0,a5,437e <mem+0x9c>
    exit(xstatus);
    4376:	00001097          	auipc	ra,0x1
    437a:	2a2080e7          	jalr	674(ra) # 5618 <exit>
      exit(0);
    437e:	4501                	li	a0,0
    4380:	00001097          	auipc	ra,0x1
    4384:	298080e7          	jalr	664(ra) # 5618 <exit>

0000000000004388 <sharedfd>:
{
    4388:	7159                	addi	sp,sp,-112
    438a:	f486                	sd	ra,104(sp)
    438c:	f0a2                	sd	s0,96(sp)
    438e:	eca6                	sd	s1,88(sp)
    4390:	e8ca                	sd	s2,80(sp)
    4392:	e4ce                	sd	s3,72(sp)
    4394:	e0d2                	sd	s4,64(sp)
    4396:	fc56                	sd	s5,56(sp)
    4398:	f85a                	sd	s6,48(sp)
    439a:	f45e                	sd	s7,40(sp)
    439c:	1880                	addi	s0,sp,112
    439e:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    43a0:	00002517          	auipc	a0,0x2
    43a4:	93850513          	addi	a0,a0,-1736 # 5cd8 <malloc+0x282>
    43a8:	00001097          	auipc	ra,0x1
    43ac:	2c0080e7          	jalr	704(ra) # 5668 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    43b0:	20200593          	li	a1,514
    43b4:	00002517          	auipc	a0,0x2
    43b8:	92450513          	addi	a0,a0,-1756 # 5cd8 <malloc+0x282>
    43bc:	00001097          	auipc	ra,0x1
    43c0:	29c080e7          	jalr	668(ra) # 5658 <open>
  if(fd < 0){
    43c4:	04054a63          	bltz	a0,4418 <sharedfd+0x90>
    43c8:	892a                	mv	s2,a0
  pid = fork();
    43ca:	00001097          	auipc	ra,0x1
    43ce:	246080e7          	jalr	582(ra) # 5610 <fork>
    43d2:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    43d4:	06300593          	li	a1,99
    43d8:	c119                	beqz	a0,43de <sharedfd+0x56>
    43da:	07000593          	li	a1,112
    43de:	4629                	li	a2,10
    43e0:	fa040513          	addi	a0,s0,-96
    43e4:	00001097          	auipc	ra,0x1
    43e8:	030080e7          	jalr	48(ra) # 5414 <memset>
    43ec:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    43f0:	4629                	li	a2,10
    43f2:	fa040593          	addi	a1,s0,-96
    43f6:	854a                	mv	a0,s2
    43f8:	00001097          	auipc	ra,0x1
    43fc:	240080e7          	jalr	576(ra) # 5638 <write>
    4400:	47a9                	li	a5,10
    4402:	02f51963          	bne	a0,a5,4434 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4406:	34fd                	addiw	s1,s1,-1
    4408:	f4e5                	bnez	s1,43f0 <sharedfd+0x68>
  if(pid == 0) {
    440a:	04099363          	bnez	s3,4450 <sharedfd+0xc8>
    exit(0);
    440e:	4501                	li	a0,0
    4410:	00001097          	auipc	ra,0x1
    4414:	208080e7          	jalr	520(ra) # 5618 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4418:	85d2                	mv	a1,s4
    441a:	00003517          	auipc	a0,0x3
    441e:	5de50513          	addi	a0,a0,1502 # 79f8 <malloc+0x1fa2>
    4422:	00001097          	auipc	ra,0x1
    4426:	576080e7          	jalr	1398(ra) # 5998 <printf>
    exit(1);
    442a:	4505                	li	a0,1
    442c:	00001097          	auipc	ra,0x1
    4430:	1ec080e7          	jalr	492(ra) # 5618 <exit>
      printf("%s: write sharedfd failed\n", s);
    4434:	85d2                	mv	a1,s4
    4436:	00003517          	auipc	a0,0x3
    443a:	5ea50513          	addi	a0,a0,1514 # 7a20 <malloc+0x1fca>
    443e:	00001097          	auipc	ra,0x1
    4442:	55a080e7          	jalr	1370(ra) # 5998 <printf>
      exit(1);
    4446:	4505                	li	a0,1
    4448:	00001097          	auipc	ra,0x1
    444c:	1d0080e7          	jalr	464(ra) # 5618 <exit>
    wait(&xstatus);
    4450:	f9c40513          	addi	a0,s0,-100
    4454:	00001097          	auipc	ra,0x1
    4458:	1cc080e7          	jalr	460(ra) # 5620 <wait>
    if(xstatus != 0)
    445c:	f9c42983          	lw	s3,-100(s0)
    4460:	00098763          	beqz	s3,446e <sharedfd+0xe6>
      exit(xstatus);
    4464:	854e                	mv	a0,s3
    4466:	00001097          	auipc	ra,0x1
    446a:	1b2080e7          	jalr	434(ra) # 5618 <exit>
  close(fd);
    446e:	854a                	mv	a0,s2
    4470:	00001097          	auipc	ra,0x1
    4474:	1d0080e7          	jalr	464(ra) # 5640 <close>
  fd = open("sharedfd", 0);
    4478:	4581                	li	a1,0
    447a:	00002517          	auipc	a0,0x2
    447e:	85e50513          	addi	a0,a0,-1954 # 5cd8 <malloc+0x282>
    4482:	00001097          	auipc	ra,0x1
    4486:	1d6080e7          	jalr	470(ra) # 5658 <open>
    448a:	8baa                	mv	s7,a0
  nc = np = 0;
    448c:	8ace                	mv	s5,s3
  if(fd < 0){
    448e:	02054563          	bltz	a0,44b8 <sharedfd+0x130>
    4492:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4496:	06300493          	li	s1,99
      if(buf[i] == 'p')
    449a:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    449e:	4629                	li	a2,10
    44a0:	fa040593          	addi	a1,s0,-96
    44a4:	855e                	mv	a0,s7
    44a6:	00001097          	auipc	ra,0x1
    44aa:	18a080e7          	jalr	394(ra) # 5630 <read>
    44ae:	02a05f63          	blez	a0,44ec <sharedfd+0x164>
    44b2:	fa040793          	addi	a5,s0,-96
    44b6:	a01d                	j	44dc <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    44b8:	85d2                	mv	a1,s4
    44ba:	00003517          	auipc	a0,0x3
    44be:	58650513          	addi	a0,a0,1414 # 7a40 <malloc+0x1fea>
    44c2:	00001097          	auipc	ra,0x1
    44c6:	4d6080e7          	jalr	1238(ra) # 5998 <printf>
    exit(1);
    44ca:	4505                	li	a0,1
    44cc:	00001097          	auipc	ra,0x1
    44d0:	14c080e7          	jalr	332(ra) # 5618 <exit>
        nc++;
    44d4:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    44d6:	0785                	addi	a5,a5,1
    44d8:	fd2783e3          	beq	a5,s2,449e <sharedfd+0x116>
      if(buf[i] == 'c')
    44dc:	0007c703          	lbu	a4,0(a5) # 3e800000 <__BSS_END__+0x3e7f1540>
    44e0:	fe970ae3          	beq	a4,s1,44d4 <sharedfd+0x14c>
      if(buf[i] == 'p')
    44e4:	ff6719e3          	bne	a4,s6,44d6 <sharedfd+0x14e>
        np++;
    44e8:	2a85                	addiw	s5,s5,1
    44ea:	b7f5                	j	44d6 <sharedfd+0x14e>
  close(fd);
    44ec:	855e                	mv	a0,s7
    44ee:	00001097          	auipc	ra,0x1
    44f2:	152080e7          	jalr	338(ra) # 5640 <close>
  unlink("sharedfd");
    44f6:	00001517          	auipc	a0,0x1
    44fa:	7e250513          	addi	a0,a0,2018 # 5cd8 <malloc+0x282>
    44fe:	00001097          	auipc	ra,0x1
    4502:	16a080e7          	jalr	362(ra) # 5668 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4506:	6789                	lui	a5,0x2
    4508:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x156>
    450c:	00f99763          	bne	s3,a5,451a <sharedfd+0x192>
    4510:	6789                	lui	a5,0x2
    4512:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x156>
    4516:	02fa8063          	beq	s5,a5,4536 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    451a:	85d2                	mv	a1,s4
    451c:	00003517          	auipc	a0,0x3
    4520:	54c50513          	addi	a0,a0,1356 # 7a68 <malloc+0x2012>
    4524:	00001097          	auipc	ra,0x1
    4528:	474080e7          	jalr	1140(ra) # 5998 <printf>
    exit(1);
    452c:	4505                	li	a0,1
    452e:	00001097          	auipc	ra,0x1
    4532:	0ea080e7          	jalr	234(ra) # 5618 <exit>
    exit(0);
    4536:	4501                	li	a0,0
    4538:	00001097          	auipc	ra,0x1
    453c:	0e0080e7          	jalr	224(ra) # 5618 <exit>

0000000000004540 <fourfiles>:
{
    4540:	7171                	addi	sp,sp,-176
    4542:	f506                	sd	ra,168(sp)
    4544:	f122                	sd	s0,160(sp)
    4546:	ed26                	sd	s1,152(sp)
    4548:	e94a                	sd	s2,144(sp)
    454a:	e54e                	sd	s3,136(sp)
    454c:	e152                	sd	s4,128(sp)
    454e:	fcd6                	sd	s5,120(sp)
    4550:	f8da                	sd	s6,112(sp)
    4552:	f4de                	sd	s7,104(sp)
    4554:	f0e2                	sd	s8,96(sp)
    4556:	ece6                	sd	s9,88(sp)
    4558:	e8ea                	sd	s10,80(sp)
    455a:	e4ee                	sd	s11,72(sp)
    455c:	1900                	addi	s0,sp,176
    455e:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4560:	00001797          	auipc	a5,0x1
    4564:	5e078793          	addi	a5,a5,1504 # 5b40 <malloc+0xea>
    4568:	f6f43823          	sd	a5,-144(s0)
    456c:	00001797          	auipc	a5,0x1
    4570:	5dc78793          	addi	a5,a5,1500 # 5b48 <malloc+0xf2>
    4574:	f6f43c23          	sd	a5,-136(s0)
    4578:	00001797          	auipc	a5,0x1
    457c:	5d878793          	addi	a5,a5,1496 # 5b50 <malloc+0xfa>
    4580:	f8f43023          	sd	a5,-128(s0)
    4584:	00001797          	auipc	a5,0x1
    4588:	5d478793          	addi	a5,a5,1492 # 5b58 <malloc+0x102>
    458c:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4590:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4594:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4596:	4481                	li	s1,0
    4598:	4a11                	li	s4,4
    fname = names[pi];
    459a:	00093983          	ld	s3,0(s2)
    unlink(fname);
    459e:	854e                	mv	a0,s3
    45a0:	00001097          	auipc	ra,0x1
    45a4:	0c8080e7          	jalr	200(ra) # 5668 <unlink>
    pid = fork();
    45a8:	00001097          	auipc	ra,0x1
    45ac:	068080e7          	jalr	104(ra) # 5610 <fork>
    if(pid < 0){
    45b0:	04054563          	bltz	a0,45fa <fourfiles+0xba>
    if(pid == 0){
    45b4:	c12d                	beqz	a0,4616 <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    45b6:	2485                	addiw	s1,s1,1
    45b8:	0921                	addi	s2,s2,8
    45ba:	ff4490e3          	bne	s1,s4,459a <fourfiles+0x5a>
    45be:	4491                	li	s1,4
    wait(&xstatus);
    45c0:	f6c40513          	addi	a0,s0,-148
    45c4:	00001097          	auipc	ra,0x1
    45c8:	05c080e7          	jalr	92(ra) # 5620 <wait>
    if(xstatus != 0)
    45cc:	f6c42503          	lw	a0,-148(s0)
    45d0:	ed69                	bnez	a0,46aa <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    45d2:	34fd                	addiw	s1,s1,-1
    45d4:	f4f5                	bnez	s1,45c0 <fourfiles+0x80>
    45d6:	03000b13          	li	s6,48
    total = 0;
    45da:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    45de:	00007a17          	auipc	s4,0x7
    45e2:	4d2a0a13          	addi	s4,s4,1234 # bab0 <buf>
    45e6:	00007a97          	auipc	s5,0x7
    45ea:	4cba8a93          	addi	s5,s5,1227 # bab1 <buf+0x1>
    if(total != N*SZ){
    45ee:	6d05                	lui	s10,0x1
    45f0:	770d0d13          	addi	s10,s10,1904 # 1770 <pipe1+0x30>
  for(i = 0; i < NCHILD; i++){
    45f4:	03400d93          	li	s11,52
    45f8:	a23d                	j	4726 <fourfiles+0x1e6>
      printf("fork failed\n", s);
    45fa:	85e6                	mv	a1,s9
    45fc:	00002517          	auipc	a0,0x2
    4600:	4dc50513          	addi	a0,a0,1244 # 6ad8 <malloc+0x1082>
    4604:	00001097          	auipc	ra,0x1
    4608:	394080e7          	jalr	916(ra) # 5998 <printf>
      exit(1);
    460c:	4505                	li	a0,1
    460e:	00001097          	auipc	ra,0x1
    4612:	00a080e7          	jalr	10(ra) # 5618 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4616:	20200593          	li	a1,514
    461a:	854e                	mv	a0,s3
    461c:	00001097          	auipc	ra,0x1
    4620:	03c080e7          	jalr	60(ra) # 5658 <open>
    4624:	892a                	mv	s2,a0
      if(fd < 0){
    4626:	04054763          	bltz	a0,4674 <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    462a:	1f400613          	li	a2,500
    462e:	0304859b          	addiw	a1,s1,48
    4632:	00007517          	auipc	a0,0x7
    4636:	47e50513          	addi	a0,a0,1150 # bab0 <buf>
    463a:	00001097          	auipc	ra,0x1
    463e:	dda080e7          	jalr	-550(ra) # 5414 <memset>
    4642:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4644:	00007997          	auipc	s3,0x7
    4648:	46c98993          	addi	s3,s3,1132 # bab0 <buf>
    464c:	1f400613          	li	a2,500
    4650:	85ce                	mv	a1,s3
    4652:	854a                	mv	a0,s2
    4654:	00001097          	auipc	ra,0x1
    4658:	fe4080e7          	jalr	-28(ra) # 5638 <write>
    465c:	85aa                	mv	a1,a0
    465e:	1f400793          	li	a5,500
    4662:	02f51763          	bne	a0,a5,4690 <fourfiles+0x150>
      for(i = 0; i < N; i++){
    4666:	34fd                	addiw	s1,s1,-1
    4668:	f0f5                	bnez	s1,464c <fourfiles+0x10c>
      exit(0);
    466a:	4501                	li	a0,0
    466c:	00001097          	auipc	ra,0x1
    4670:	fac080e7          	jalr	-84(ra) # 5618 <exit>
        printf("create failed\n", s);
    4674:	85e6                	mv	a1,s9
    4676:	00003517          	auipc	a0,0x3
    467a:	40a50513          	addi	a0,a0,1034 # 7a80 <malloc+0x202a>
    467e:	00001097          	auipc	ra,0x1
    4682:	31a080e7          	jalr	794(ra) # 5998 <printf>
        exit(1);
    4686:	4505                	li	a0,1
    4688:	00001097          	auipc	ra,0x1
    468c:	f90080e7          	jalr	-112(ra) # 5618 <exit>
          printf("write failed %d\n", n);
    4690:	00003517          	auipc	a0,0x3
    4694:	40050513          	addi	a0,a0,1024 # 7a90 <malloc+0x203a>
    4698:	00001097          	auipc	ra,0x1
    469c:	300080e7          	jalr	768(ra) # 5998 <printf>
          exit(1);
    46a0:	4505                	li	a0,1
    46a2:	00001097          	auipc	ra,0x1
    46a6:	f76080e7          	jalr	-138(ra) # 5618 <exit>
      exit(xstatus);
    46aa:	00001097          	auipc	ra,0x1
    46ae:	f6e080e7          	jalr	-146(ra) # 5618 <exit>
          printf("wrong char\n", s);
    46b2:	85e6                	mv	a1,s9
    46b4:	00003517          	auipc	a0,0x3
    46b8:	3f450513          	addi	a0,a0,1012 # 7aa8 <malloc+0x2052>
    46bc:	00001097          	auipc	ra,0x1
    46c0:	2dc080e7          	jalr	732(ra) # 5998 <printf>
          exit(1);
    46c4:	4505                	li	a0,1
    46c6:	00001097          	auipc	ra,0x1
    46ca:	f52080e7          	jalr	-174(ra) # 5618 <exit>
      total += n;
    46ce:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    46d2:	660d                	lui	a2,0x3
    46d4:	85d2                	mv	a1,s4
    46d6:	854e                	mv	a0,s3
    46d8:	00001097          	auipc	ra,0x1
    46dc:	f58080e7          	jalr	-168(ra) # 5630 <read>
    46e0:	02a05363          	blez	a0,4706 <fourfiles+0x1c6>
    46e4:	00007797          	auipc	a5,0x7
    46e8:	3cc78793          	addi	a5,a5,972 # bab0 <buf>
    46ec:	fff5069b          	addiw	a3,a0,-1
    46f0:	1682                	slli	a3,a3,0x20
    46f2:	9281                	srli	a3,a3,0x20
    46f4:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    46f6:	0007c703          	lbu	a4,0(a5)
    46fa:	fa971ce3          	bne	a4,s1,46b2 <fourfiles+0x172>
      for(j = 0; j < n; j++){
    46fe:	0785                	addi	a5,a5,1
    4700:	fed79be3          	bne	a5,a3,46f6 <fourfiles+0x1b6>
    4704:	b7e9                	j	46ce <fourfiles+0x18e>
    close(fd);
    4706:	854e                	mv	a0,s3
    4708:	00001097          	auipc	ra,0x1
    470c:	f38080e7          	jalr	-200(ra) # 5640 <close>
    if(total != N*SZ){
    4710:	03a91963          	bne	s2,s10,4742 <fourfiles+0x202>
    unlink(fname);
    4714:	8562                	mv	a0,s8
    4716:	00001097          	auipc	ra,0x1
    471a:	f52080e7          	jalr	-174(ra) # 5668 <unlink>
  for(i = 0; i < NCHILD; i++){
    471e:	0ba1                	addi	s7,s7,8
    4720:	2b05                	addiw	s6,s6,1
    4722:	03bb0e63          	beq	s6,s11,475e <fourfiles+0x21e>
    fname = names[i];
    4726:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    472a:	4581                	li	a1,0
    472c:	8562                	mv	a0,s8
    472e:	00001097          	auipc	ra,0x1
    4732:	f2a080e7          	jalr	-214(ra) # 5658 <open>
    4736:	89aa                	mv	s3,a0
    total = 0;
    4738:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    473c:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4740:	bf49                	j	46d2 <fourfiles+0x192>
      printf("wrong length %d\n", total);
    4742:	85ca                	mv	a1,s2
    4744:	00003517          	auipc	a0,0x3
    4748:	37450513          	addi	a0,a0,884 # 7ab8 <malloc+0x2062>
    474c:	00001097          	auipc	ra,0x1
    4750:	24c080e7          	jalr	588(ra) # 5998 <printf>
      exit(1);
    4754:	4505                	li	a0,1
    4756:	00001097          	auipc	ra,0x1
    475a:	ec2080e7          	jalr	-318(ra) # 5618 <exit>
}
    475e:	70aa                	ld	ra,168(sp)
    4760:	740a                	ld	s0,160(sp)
    4762:	64ea                	ld	s1,152(sp)
    4764:	694a                	ld	s2,144(sp)
    4766:	69aa                	ld	s3,136(sp)
    4768:	6a0a                	ld	s4,128(sp)
    476a:	7ae6                	ld	s5,120(sp)
    476c:	7b46                	ld	s6,112(sp)
    476e:	7ba6                	ld	s7,104(sp)
    4770:	7c06                	ld	s8,96(sp)
    4772:	6ce6                	ld	s9,88(sp)
    4774:	6d46                	ld	s10,80(sp)
    4776:	6da6                	ld	s11,72(sp)
    4778:	614d                	addi	sp,sp,176
    477a:	8082                	ret

000000000000477c <concreate>:
{
    477c:	7135                	addi	sp,sp,-160
    477e:	ed06                	sd	ra,152(sp)
    4780:	e922                	sd	s0,144(sp)
    4782:	e526                	sd	s1,136(sp)
    4784:	e14a                	sd	s2,128(sp)
    4786:	fcce                	sd	s3,120(sp)
    4788:	f8d2                	sd	s4,112(sp)
    478a:	f4d6                	sd	s5,104(sp)
    478c:	f0da                	sd	s6,96(sp)
    478e:	ecde                	sd	s7,88(sp)
    4790:	1100                	addi	s0,sp,160
    4792:	89aa                	mv	s3,a0
  file[0] = 'C';
    4794:	04300793          	li	a5,67
    4798:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    479c:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    47a0:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    47a2:	4b0d                	li	s6,3
    47a4:	4a85                	li	s5,1
      link("C0", file);
    47a6:	00003b97          	auipc	s7,0x3
    47aa:	32ab8b93          	addi	s7,s7,810 # 7ad0 <malloc+0x207a>
  for(i = 0; i < N; i++){
    47ae:	02800a13          	li	s4,40
    47b2:	acc1                	j	4a82 <concreate+0x306>
      link("C0", file);
    47b4:	fa840593          	addi	a1,s0,-88
    47b8:	855e                	mv	a0,s7
    47ba:	00001097          	auipc	ra,0x1
    47be:	ebe080e7          	jalr	-322(ra) # 5678 <link>
    if(pid == 0) {
    47c2:	a45d                	j	4a68 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    47c4:	4795                	li	a5,5
    47c6:	02f9693b          	remw	s2,s2,a5
    47ca:	4785                	li	a5,1
    47cc:	02f90b63          	beq	s2,a5,4802 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    47d0:	20200593          	li	a1,514
    47d4:	fa840513          	addi	a0,s0,-88
    47d8:	00001097          	auipc	ra,0x1
    47dc:	e80080e7          	jalr	-384(ra) # 5658 <open>
      if(fd < 0){
    47e0:	26055b63          	bgez	a0,4a56 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    47e4:	fa840593          	addi	a1,s0,-88
    47e8:	00003517          	auipc	a0,0x3
    47ec:	2f050513          	addi	a0,a0,752 # 7ad8 <malloc+0x2082>
    47f0:	00001097          	auipc	ra,0x1
    47f4:	1a8080e7          	jalr	424(ra) # 5998 <printf>
        exit(1);
    47f8:	4505                	li	a0,1
    47fa:	00001097          	auipc	ra,0x1
    47fe:	e1e080e7          	jalr	-482(ra) # 5618 <exit>
      link("C0", file);
    4802:	fa840593          	addi	a1,s0,-88
    4806:	00003517          	auipc	a0,0x3
    480a:	2ca50513          	addi	a0,a0,714 # 7ad0 <malloc+0x207a>
    480e:	00001097          	auipc	ra,0x1
    4812:	e6a080e7          	jalr	-406(ra) # 5678 <link>
      exit(0);
    4816:	4501                	li	a0,0
    4818:	00001097          	auipc	ra,0x1
    481c:	e00080e7          	jalr	-512(ra) # 5618 <exit>
        exit(1);
    4820:	4505                	li	a0,1
    4822:	00001097          	auipc	ra,0x1
    4826:	df6080e7          	jalr	-522(ra) # 5618 <exit>
  memset(fa, 0, sizeof(fa));
    482a:	02800613          	li	a2,40
    482e:	4581                	li	a1,0
    4830:	f8040513          	addi	a0,s0,-128
    4834:	00001097          	auipc	ra,0x1
    4838:	be0080e7          	jalr	-1056(ra) # 5414 <memset>
  fd = open(".", 0);
    483c:	4581                	li	a1,0
    483e:	00002517          	auipc	a0,0x2
    4842:	cf250513          	addi	a0,a0,-782 # 6530 <malloc+0xada>
    4846:	00001097          	auipc	ra,0x1
    484a:	e12080e7          	jalr	-494(ra) # 5658 <open>
    484e:	892a                	mv	s2,a0
  n = 0;
    4850:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4852:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4856:	02700b13          	li	s6,39
      fa[i] = 1;
    485a:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    485c:	a03d                	j	488a <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    485e:	f7240613          	addi	a2,s0,-142
    4862:	85ce                	mv	a1,s3
    4864:	00003517          	auipc	a0,0x3
    4868:	29450513          	addi	a0,a0,660 # 7af8 <malloc+0x20a2>
    486c:	00001097          	auipc	ra,0x1
    4870:	12c080e7          	jalr	300(ra) # 5998 <printf>
        exit(1);
    4874:	4505                	li	a0,1
    4876:	00001097          	auipc	ra,0x1
    487a:	da2080e7          	jalr	-606(ra) # 5618 <exit>
      fa[i] = 1;
    487e:	fb040793          	addi	a5,s0,-80
    4882:	973e                	add	a4,a4,a5
    4884:	fd770823          	sb	s7,-48(a4)
      n++;
    4888:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    488a:	4641                	li	a2,16
    488c:	f7040593          	addi	a1,s0,-144
    4890:	854a                	mv	a0,s2
    4892:	00001097          	auipc	ra,0x1
    4896:	d9e080e7          	jalr	-610(ra) # 5630 <read>
    489a:	04a05a63          	blez	a0,48ee <concreate+0x172>
    if(de.inum == 0)
    489e:	f7045783          	lhu	a5,-144(s0)
    48a2:	d7e5                	beqz	a5,488a <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    48a4:	f7244783          	lbu	a5,-142(s0)
    48a8:	ff4791e3          	bne	a5,s4,488a <concreate+0x10e>
    48ac:	f7444783          	lbu	a5,-140(s0)
    48b0:	ffe9                	bnez	a5,488a <concreate+0x10e>
      i = de.name[1] - '0';
    48b2:	f7344783          	lbu	a5,-141(s0)
    48b6:	fd07879b          	addiw	a5,a5,-48
    48ba:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    48be:	faeb60e3          	bltu	s6,a4,485e <concreate+0xe2>
      if(fa[i]){
    48c2:	fb040793          	addi	a5,s0,-80
    48c6:	97ba                	add	a5,a5,a4
    48c8:	fd07c783          	lbu	a5,-48(a5)
    48cc:	dbcd                	beqz	a5,487e <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    48ce:	f7240613          	addi	a2,s0,-142
    48d2:	85ce                	mv	a1,s3
    48d4:	00003517          	auipc	a0,0x3
    48d8:	24450513          	addi	a0,a0,580 # 7b18 <malloc+0x20c2>
    48dc:	00001097          	auipc	ra,0x1
    48e0:	0bc080e7          	jalr	188(ra) # 5998 <printf>
        exit(1);
    48e4:	4505                	li	a0,1
    48e6:	00001097          	auipc	ra,0x1
    48ea:	d32080e7          	jalr	-718(ra) # 5618 <exit>
  close(fd);
    48ee:	854a                	mv	a0,s2
    48f0:	00001097          	auipc	ra,0x1
    48f4:	d50080e7          	jalr	-688(ra) # 5640 <close>
  if(n != N){
    48f8:	02800793          	li	a5,40
    48fc:	00fa9763          	bne	s5,a5,490a <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    4900:	4a8d                	li	s5,3
    4902:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4904:	02800a13          	li	s4,40
    4908:	a8c9                	j	49da <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    490a:	85ce                	mv	a1,s3
    490c:	00003517          	auipc	a0,0x3
    4910:	23450513          	addi	a0,a0,564 # 7b40 <malloc+0x20ea>
    4914:	00001097          	auipc	ra,0x1
    4918:	084080e7          	jalr	132(ra) # 5998 <printf>
    exit(1);
    491c:	4505                	li	a0,1
    491e:	00001097          	auipc	ra,0x1
    4922:	cfa080e7          	jalr	-774(ra) # 5618 <exit>
      printf("%s: fork failed\n", s);
    4926:	85ce                	mv	a1,s3
    4928:	00002517          	auipc	a0,0x2
    492c:	da850513          	addi	a0,a0,-600 # 66d0 <malloc+0xc7a>
    4930:	00001097          	auipc	ra,0x1
    4934:	068080e7          	jalr	104(ra) # 5998 <printf>
      exit(1);
    4938:	4505                	li	a0,1
    493a:	00001097          	auipc	ra,0x1
    493e:	cde080e7          	jalr	-802(ra) # 5618 <exit>
      close(open(file, 0));
    4942:	4581                	li	a1,0
    4944:	fa840513          	addi	a0,s0,-88
    4948:	00001097          	auipc	ra,0x1
    494c:	d10080e7          	jalr	-752(ra) # 5658 <open>
    4950:	00001097          	auipc	ra,0x1
    4954:	cf0080e7          	jalr	-784(ra) # 5640 <close>
      close(open(file, 0));
    4958:	4581                	li	a1,0
    495a:	fa840513          	addi	a0,s0,-88
    495e:	00001097          	auipc	ra,0x1
    4962:	cfa080e7          	jalr	-774(ra) # 5658 <open>
    4966:	00001097          	auipc	ra,0x1
    496a:	cda080e7          	jalr	-806(ra) # 5640 <close>
      close(open(file, 0));
    496e:	4581                	li	a1,0
    4970:	fa840513          	addi	a0,s0,-88
    4974:	00001097          	auipc	ra,0x1
    4978:	ce4080e7          	jalr	-796(ra) # 5658 <open>
    497c:	00001097          	auipc	ra,0x1
    4980:	cc4080e7          	jalr	-828(ra) # 5640 <close>
      close(open(file, 0));
    4984:	4581                	li	a1,0
    4986:	fa840513          	addi	a0,s0,-88
    498a:	00001097          	auipc	ra,0x1
    498e:	cce080e7          	jalr	-818(ra) # 5658 <open>
    4992:	00001097          	auipc	ra,0x1
    4996:	cae080e7          	jalr	-850(ra) # 5640 <close>
      close(open(file, 0));
    499a:	4581                	li	a1,0
    499c:	fa840513          	addi	a0,s0,-88
    49a0:	00001097          	auipc	ra,0x1
    49a4:	cb8080e7          	jalr	-840(ra) # 5658 <open>
    49a8:	00001097          	auipc	ra,0x1
    49ac:	c98080e7          	jalr	-872(ra) # 5640 <close>
      close(open(file, 0));
    49b0:	4581                	li	a1,0
    49b2:	fa840513          	addi	a0,s0,-88
    49b6:	00001097          	auipc	ra,0x1
    49ba:	ca2080e7          	jalr	-862(ra) # 5658 <open>
    49be:	00001097          	auipc	ra,0x1
    49c2:	c82080e7          	jalr	-894(ra) # 5640 <close>
    if(pid == 0)
    49c6:	08090363          	beqz	s2,4a4c <concreate+0x2d0>
      wait(0);
    49ca:	4501                	li	a0,0
    49cc:	00001097          	auipc	ra,0x1
    49d0:	c54080e7          	jalr	-940(ra) # 5620 <wait>
  for(i = 0; i < N; i++){
    49d4:	2485                	addiw	s1,s1,1
    49d6:	0f448563          	beq	s1,s4,4ac0 <concreate+0x344>
    file[1] = '0' + i;
    49da:	0304879b          	addiw	a5,s1,48
    49de:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    49e2:	00001097          	auipc	ra,0x1
    49e6:	c2e080e7          	jalr	-978(ra) # 5610 <fork>
    49ea:	892a                	mv	s2,a0
    if(pid < 0){
    49ec:	f2054de3          	bltz	a0,4926 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    49f0:	0354e73b          	remw	a4,s1,s5
    49f4:	00a767b3          	or	a5,a4,a0
    49f8:	2781                	sext.w	a5,a5
    49fa:	d7a1                	beqz	a5,4942 <concreate+0x1c6>
    49fc:	01671363          	bne	a4,s6,4a02 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    4a00:	f129                	bnez	a0,4942 <concreate+0x1c6>
      unlink(file);
    4a02:	fa840513          	addi	a0,s0,-88
    4a06:	00001097          	auipc	ra,0x1
    4a0a:	c62080e7          	jalr	-926(ra) # 5668 <unlink>
      unlink(file);
    4a0e:	fa840513          	addi	a0,s0,-88
    4a12:	00001097          	auipc	ra,0x1
    4a16:	c56080e7          	jalr	-938(ra) # 5668 <unlink>
      unlink(file);
    4a1a:	fa840513          	addi	a0,s0,-88
    4a1e:	00001097          	auipc	ra,0x1
    4a22:	c4a080e7          	jalr	-950(ra) # 5668 <unlink>
      unlink(file);
    4a26:	fa840513          	addi	a0,s0,-88
    4a2a:	00001097          	auipc	ra,0x1
    4a2e:	c3e080e7          	jalr	-962(ra) # 5668 <unlink>
      unlink(file);
    4a32:	fa840513          	addi	a0,s0,-88
    4a36:	00001097          	auipc	ra,0x1
    4a3a:	c32080e7          	jalr	-974(ra) # 5668 <unlink>
      unlink(file);
    4a3e:	fa840513          	addi	a0,s0,-88
    4a42:	00001097          	auipc	ra,0x1
    4a46:	c26080e7          	jalr	-986(ra) # 5668 <unlink>
    4a4a:	bfb5                	j	49c6 <concreate+0x24a>
      exit(0);
    4a4c:	4501                	li	a0,0
    4a4e:	00001097          	auipc	ra,0x1
    4a52:	bca080e7          	jalr	-1078(ra) # 5618 <exit>
      close(fd);
    4a56:	00001097          	auipc	ra,0x1
    4a5a:	bea080e7          	jalr	-1046(ra) # 5640 <close>
    if(pid == 0) {
    4a5e:	bb65                	j	4816 <concreate+0x9a>
      close(fd);
    4a60:	00001097          	auipc	ra,0x1
    4a64:	be0080e7          	jalr	-1056(ra) # 5640 <close>
      wait(&xstatus);
    4a68:	f6c40513          	addi	a0,s0,-148
    4a6c:	00001097          	auipc	ra,0x1
    4a70:	bb4080e7          	jalr	-1100(ra) # 5620 <wait>
      if(xstatus != 0)
    4a74:	f6c42483          	lw	s1,-148(s0)
    4a78:	da0494e3          	bnez	s1,4820 <concreate+0xa4>
  for(i = 0; i < N; i++){
    4a7c:	2905                	addiw	s2,s2,1
    4a7e:	db4906e3          	beq	s2,s4,482a <concreate+0xae>
    file[1] = '0' + i;
    4a82:	0309079b          	addiw	a5,s2,48
    4a86:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4a8a:	fa840513          	addi	a0,s0,-88
    4a8e:	00001097          	auipc	ra,0x1
    4a92:	bda080e7          	jalr	-1062(ra) # 5668 <unlink>
    pid = fork();
    4a96:	00001097          	auipc	ra,0x1
    4a9a:	b7a080e7          	jalr	-1158(ra) # 5610 <fork>
    if(pid && (i % 3) == 1){
    4a9e:	d20503e3          	beqz	a0,47c4 <concreate+0x48>
    4aa2:	036967bb          	remw	a5,s2,s6
    4aa6:	d15787e3          	beq	a5,s5,47b4 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4aaa:	20200593          	li	a1,514
    4aae:	fa840513          	addi	a0,s0,-88
    4ab2:	00001097          	auipc	ra,0x1
    4ab6:	ba6080e7          	jalr	-1114(ra) # 5658 <open>
      if(fd < 0){
    4aba:	fa0553e3          	bgez	a0,4a60 <concreate+0x2e4>
    4abe:	b31d                	j	47e4 <concreate+0x68>
}
    4ac0:	60ea                	ld	ra,152(sp)
    4ac2:	644a                	ld	s0,144(sp)
    4ac4:	64aa                	ld	s1,136(sp)
    4ac6:	690a                	ld	s2,128(sp)
    4ac8:	79e6                	ld	s3,120(sp)
    4aca:	7a46                	ld	s4,112(sp)
    4acc:	7aa6                	ld	s5,104(sp)
    4ace:	7b06                	ld	s6,96(sp)
    4ad0:	6be6                	ld	s7,88(sp)
    4ad2:	610d                	addi	sp,sp,160
    4ad4:	8082                	ret

0000000000004ad6 <bigfile>:
{
    4ad6:	7139                	addi	sp,sp,-64
    4ad8:	fc06                	sd	ra,56(sp)
    4ada:	f822                	sd	s0,48(sp)
    4adc:	f426                	sd	s1,40(sp)
    4ade:	f04a                	sd	s2,32(sp)
    4ae0:	ec4e                	sd	s3,24(sp)
    4ae2:	e852                	sd	s4,16(sp)
    4ae4:	e456                	sd	s5,8(sp)
    4ae6:	0080                	addi	s0,sp,64
    4ae8:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4aea:	00003517          	auipc	a0,0x3
    4aee:	08e50513          	addi	a0,a0,142 # 7b78 <malloc+0x2122>
    4af2:	00001097          	auipc	ra,0x1
    4af6:	b76080e7          	jalr	-1162(ra) # 5668 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4afa:	20200593          	li	a1,514
    4afe:	00003517          	auipc	a0,0x3
    4b02:	07a50513          	addi	a0,a0,122 # 7b78 <malloc+0x2122>
    4b06:	00001097          	auipc	ra,0x1
    4b0a:	b52080e7          	jalr	-1198(ra) # 5658 <open>
    4b0e:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4b10:	4481                	li	s1,0
    memset(buf, i, SZ);
    4b12:	00007917          	auipc	s2,0x7
    4b16:	f9e90913          	addi	s2,s2,-98 # bab0 <buf>
  for(i = 0; i < N; i++){
    4b1a:	4a51                	li	s4,20
  if(fd < 0){
    4b1c:	0a054063          	bltz	a0,4bbc <bigfile+0xe6>
    memset(buf, i, SZ);
    4b20:	25800613          	li	a2,600
    4b24:	85a6                	mv	a1,s1
    4b26:	854a                	mv	a0,s2
    4b28:	00001097          	auipc	ra,0x1
    4b2c:	8ec080e7          	jalr	-1812(ra) # 5414 <memset>
    if(write(fd, buf, SZ) != SZ){
    4b30:	25800613          	li	a2,600
    4b34:	85ca                	mv	a1,s2
    4b36:	854e                	mv	a0,s3
    4b38:	00001097          	auipc	ra,0x1
    4b3c:	b00080e7          	jalr	-1280(ra) # 5638 <write>
    4b40:	25800793          	li	a5,600
    4b44:	08f51a63          	bne	a0,a5,4bd8 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4b48:	2485                	addiw	s1,s1,1
    4b4a:	fd449be3          	bne	s1,s4,4b20 <bigfile+0x4a>
  close(fd);
    4b4e:	854e                	mv	a0,s3
    4b50:	00001097          	auipc	ra,0x1
    4b54:	af0080e7          	jalr	-1296(ra) # 5640 <close>
  fd = open("bigfile.dat", 0);
    4b58:	4581                	li	a1,0
    4b5a:	00003517          	auipc	a0,0x3
    4b5e:	01e50513          	addi	a0,a0,30 # 7b78 <malloc+0x2122>
    4b62:	00001097          	auipc	ra,0x1
    4b66:	af6080e7          	jalr	-1290(ra) # 5658 <open>
    4b6a:	8a2a                	mv	s4,a0
  total = 0;
    4b6c:	4981                	li	s3,0
  for(i = 0; ; i++){
    4b6e:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4b70:	00007917          	auipc	s2,0x7
    4b74:	f4090913          	addi	s2,s2,-192 # bab0 <buf>
  if(fd < 0){
    4b78:	06054e63          	bltz	a0,4bf4 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4b7c:	12c00613          	li	a2,300
    4b80:	85ca                	mv	a1,s2
    4b82:	8552                	mv	a0,s4
    4b84:	00001097          	auipc	ra,0x1
    4b88:	aac080e7          	jalr	-1364(ra) # 5630 <read>
    if(cc < 0){
    4b8c:	08054263          	bltz	a0,4c10 <bigfile+0x13a>
    if(cc == 0)
    4b90:	c971                	beqz	a0,4c64 <bigfile+0x18e>
    if(cc != SZ/2){
    4b92:	12c00793          	li	a5,300
    4b96:	08f51b63          	bne	a0,a5,4c2c <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4b9a:	01f4d79b          	srliw	a5,s1,0x1f
    4b9e:	9fa5                	addw	a5,a5,s1
    4ba0:	4017d79b          	sraiw	a5,a5,0x1
    4ba4:	00094703          	lbu	a4,0(s2)
    4ba8:	0af71063          	bne	a4,a5,4c48 <bigfile+0x172>
    4bac:	12b94703          	lbu	a4,299(s2)
    4bb0:	08f71c63          	bne	a4,a5,4c48 <bigfile+0x172>
    total += cc;
    4bb4:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4bb8:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4bba:	b7c9                	j	4b7c <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4bbc:	85d6                	mv	a1,s5
    4bbe:	00003517          	auipc	a0,0x3
    4bc2:	fca50513          	addi	a0,a0,-54 # 7b88 <malloc+0x2132>
    4bc6:	00001097          	auipc	ra,0x1
    4bca:	dd2080e7          	jalr	-558(ra) # 5998 <printf>
    exit(1);
    4bce:	4505                	li	a0,1
    4bd0:	00001097          	auipc	ra,0x1
    4bd4:	a48080e7          	jalr	-1464(ra) # 5618 <exit>
      printf("%s: write bigfile failed\n", s);
    4bd8:	85d6                	mv	a1,s5
    4bda:	00003517          	auipc	a0,0x3
    4bde:	fce50513          	addi	a0,a0,-50 # 7ba8 <malloc+0x2152>
    4be2:	00001097          	auipc	ra,0x1
    4be6:	db6080e7          	jalr	-586(ra) # 5998 <printf>
      exit(1);
    4bea:	4505                	li	a0,1
    4bec:	00001097          	auipc	ra,0x1
    4bf0:	a2c080e7          	jalr	-1492(ra) # 5618 <exit>
    printf("%s: cannot open bigfile\n", s);
    4bf4:	85d6                	mv	a1,s5
    4bf6:	00003517          	auipc	a0,0x3
    4bfa:	fd250513          	addi	a0,a0,-46 # 7bc8 <malloc+0x2172>
    4bfe:	00001097          	auipc	ra,0x1
    4c02:	d9a080e7          	jalr	-614(ra) # 5998 <printf>
    exit(1);
    4c06:	4505                	li	a0,1
    4c08:	00001097          	auipc	ra,0x1
    4c0c:	a10080e7          	jalr	-1520(ra) # 5618 <exit>
      printf("%s: read bigfile failed\n", s);
    4c10:	85d6                	mv	a1,s5
    4c12:	00003517          	auipc	a0,0x3
    4c16:	fd650513          	addi	a0,a0,-42 # 7be8 <malloc+0x2192>
    4c1a:	00001097          	auipc	ra,0x1
    4c1e:	d7e080e7          	jalr	-642(ra) # 5998 <printf>
      exit(1);
    4c22:	4505                	li	a0,1
    4c24:	00001097          	auipc	ra,0x1
    4c28:	9f4080e7          	jalr	-1548(ra) # 5618 <exit>
      printf("%s: short read bigfile\n", s);
    4c2c:	85d6                	mv	a1,s5
    4c2e:	00003517          	auipc	a0,0x3
    4c32:	fda50513          	addi	a0,a0,-38 # 7c08 <malloc+0x21b2>
    4c36:	00001097          	auipc	ra,0x1
    4c3a:	d62080e7          	jalr	-670(ra) # 5998 <printf>
      exit(1);
    4c3e:	4505                	li	a0,1
    4c40:	00001097          	auipc	ra,0x1
    4c44:	9d8080e7          	jalr	-1576(ra) # 5618 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4c48:	85d6                	mv	a1,s5
    4c4a:	00003517          	auipc	a0,0x3
    4c4e:	fd650513          	addi	a0,a0,-42 # 7c20 <malloc+0x21ca>
    4c52:	00001097          	auipc	ra,0x1
    4c56:	d46080e7          	jalr	-698(ra) # 5998 <printf>
      exit(1);
    4c5a:	4505                	li	a0,1
    4c5c:	00001097          	auipc	ra,0x1
    4c60:	9bc080e7          	jalr	-1604(ra) # 5618 <exit>
  close(fd);
    4c64:	8552                	mv	a0,s4
    4c66:	00001097          	auipc	ra,0x1
    4c6a:	9da080e7          	jalr	-1574(ra) # 5640 <close>
  if(total != N*SZ){
    4c6e:	678d                	lui	a5,0x3
    4c70:	ee078793          	addi	a5,a5,-288 # 2ee0 <exitiputtest+0x44>
    4c74:	02f99363          	bne	s3,a5,4c9a <bigfile+0x1c4>
  unlink("bigfile.dat");
    4c78:	00003517          	auipc	a0,0x3
    4c7c:	f0050513          	addi	a0,a0,-256 # 7b78 <malloc+0x2122>
    4c80:	00001097          	auipc	ra,0x1
    4c84:	9e8080e7          	jalr	-1560(ra) # 5668 <unlink>
}
    4c88:	70e2                	ld	ra,56(sp)
    4c8a:	7442                	ld	s0,48(sp)
    4c8c:	74a2                	ld	s1,40(sp)
    4c8e:	7902                	ld	s2,32(sp)
    4c90:	69e2                	ld	s3,24(sp)
    4c92:	6a42                	ld	s4,16(sp)
    4c94:	6aa2                	ld	s5,8(sp)
    4c96:	6121                	addi	sp,sp,64
    4c98:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4c9a:	85d6                	mv	a1,s5
    4c9c:	00003517          	auipc	a0,0x3
    4ca0:	fa450513          	addi	a0,a0,-92 # 7c40 <malloc+0x21ea>
    4ca4:	00001097          	auipc	ra,0x1
    4ca8:	cf4080e7          	jalr	-780(ra) # 5998 <printf>
    exit(1);
    4cac:	4505                	li	a0,1
    4cae:	00001097          	auipc	ra,0x1
    4cb2:	96a080e7          	jalr	-1686(ra) # 5618 <exit>

0000000000004cb6 <fsfull>:
{
    4cb6:	7171                	addi	sp,sp,-176
    4cb8:	f506                	sd	ra,168(sp)
    4cba:	f122                	sd	s0,160(sp)
    4cbc:	ed26                	sd	s1,152(sp)
    4cbe:	e94a                	sd	s2,144(sp)
    4cc0:	e54e                	sd	s3,136(sp)
    4cc2:	e152                	sd	s4,128(sp)
    4cc4:	fcd6                	sd	s5,120(sp)
    4cc6:	f8da                	sd	s6,112(sp)
    4cc8:	f4de                	sd	s7,104(sp)
    4cca:	f0e2                	sd	s8,96(sp)
    4ccc:	ece6                	sd	s9,88(sp)
    4cce:	e8ea                	sd	s10,80(sp)
    4cd0:	e4ee                	sd	s11,72(sp)
    4cd2:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4cd4:	00003517          	auipc	a0,0x3
    4cd8:	f8c50513          	addi	a0,a0,-116 # 7c60 <malloc+0x220a>
    4cdc:	00001097          	auipc	ra,0x1
    4ce0:	cbc080e7          	jalr	-836(ra) # 5998 <printf>
  for(nfiles = 0; ; nfiles++){
    4ce4:	4481                	li	s1,0
    name[0] = 'f';
    4ce6:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4cea:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4cee:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4cf2:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4cf4:	00003c97          	auipc	s9,0x3
    4cf8:	f7cc8c93          	addi	s9,s9,-132 # 7c70 <malloc+0x221a>
    int total = 0;
    4cfc:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4cfe:	00007a17          	auipc	s4,0x7
    4d02:	db2a0a13          	addi	s4,s4,-590 # bab0 <buf>
    name[0] = 'f';
    4d06:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d0a:	0384c7bb          	divw	a5,s1,s8
    4d0e:	0307879b          	addiw	a5,a5,48
    4d12:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4d16:	0384e7bb          	remw	a5,s1,s8
    4d1a:	0377c7bb          	divw	a5,a5,s7
    4d1e:	0307879b          	addiw	a5,a5,48
    4d22:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4d26:	0374e7bb          	remw	a5,s1,s7
    4d2a:	0367c7bb          	divw	a5,a5,s6
    4d2e:	0307879b          	addiw	a5,a5,48
    4d32:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4d36:	0364e7bb          	remw	a5,s1,s6
    4d3a:	0307879b          	addiw	a5,a5,48
    4d3e:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4d42:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4d46:	f5040593          	addi	a1,s0,-176
    4d4a:	8566                	mv	a0,s9
    4d4c:	00001097          	auipc	ra,0x1
    4d50:	c4c080e7          	jalr	-948(ra) # 5998 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4d54:	20200593          	li	a1,514
    4d58:	f5040513          	addi	a0,s0,-176
    4d5c:	00001097          	auipc	ra,0x1
    4d60:	8fc080e7          	jalr	-1796(ra) # 5658 <open>
    4d64:	892a                	mv	s2,a0
    if(fd < 0){
    4d66:	0a055663          	bgez	a0,4e12 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4d6a:	f5040593          	addi	a1,s0,-176
    4d6e:	00003517          	auipc	a0,0x3
    4d72:	f1250513          	addi	a0,a0,-238 # 7c80 <malloc+0x222a>
    4d76:	00001097          	auipc	ra,0x1
    4d7a:	c22080e7          	jalr	-990(ra) # 5998 <printf>
  while(nfiles >= 0){
    4d7e:	0604c363          	bltz	s1,4de4 <fsfull+0x12e>
    name[0] = 'f';
    4d82:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4d86:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d8a:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d8e:	4929                	li	s2,10
  while(nfiles >= 0){
    4d90:	5afd                	li	s5,-1
    name[0] = 'f';
    4d92:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d96:	0344c7bb          	divw	a5,s1,s4
    4d9a:	0307879b          	addiw	a5,a5,48
    4d9e:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4da2:	0344e7bb          	remw	a5,s1,s4
    4da6:	0337c7bb          	divw	a5,a5,s3
    4daa:	0307879b          	addiw	a5,a5,48
    4dae:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4db2:	0334e7bb          	remw	a5,s1,s3
    4db6:	0327c7bb          	divw	a5,a5,s2
    4dba:	0307879b          	addiw	a5,a5,48
    4dbe:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4dc2:	0324e7bb          	remw	a5,s1,s2
    4dc6:	0307879b          	addiw	a5,a5,48
    4dca:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4dce:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4dd2:	f5040513          	addi	a0,s0,-176
    4dd6:	00001097          	auipc	ra,0x1
    4dda:	892080e7          	jalr	-1902(ra) # 5668 <unlink>
    nfiles--;
    4dde:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4de0:	fb5499e3          	bne	s1,s5,4d92 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4de4:	00003517          	auipc	a0,0x3
    4de8:	ebc50513          	addi	a0,a0,-324 # 7ca0 <malloc+0x224a>
    4dec:	00001097          	auipc	ra,0x1
    4df0:	bac080e7          	jalr	-1108(ra) # 5998 <printf>
}
    4df4:	70aa                	ld	ra,168(sp)
    4df6:	740a                	ld	s0,160(sp)
    4df8:	64ea                	ld	s1,152(sp)
    4dfa:	694a                	ld	s2,144(sp)
    4dfc:	69aa                	ld	s3,136(sp)
    4dfe:	6a0a                	ld	s4,128(sp)
    4e00:	7ae6                	ld	s5,120(sp)
    4e02:	7b46                	ld	s6,112(sp)
    4e04:	7ba6                	ld	s7,104(sp)
    4e06:	7c06                	ld	s8,96(sp)
    4e08:	6ce6                	ld	s9,88(sp)
    4e0a:	6d46                	ld	s10,80(sp)
    4e0c:	6da6                	ld	s11,72(sp)
    4e0e:	614d                	addi	sp,sp,176
    4e10:	8082                	ret
    int total = 0;
    4e12:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4e14:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4e18:	40000613          	li	a2,1024
    4e1c:	85d2                	mv	a1,s4
    4e1e:	854a                	mv	a0,s2
    4e20:	00001097          	auipc	ra,0x1
    4e24:	818080e7          	jalr	-2024(ra) # 5638 <write>
      if(cc < BSIZE)
    4e28:	00aad563          	bge	s5,a0,4e32 <fsfull+0x17c>
      total += cc;
    4e2c:	00a989bb          	addw	s3,s3,a0
    while(1){
    4e30:	b7e5                	j	4e18 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4e32:	85ce                	mv	a1,s3
    4e34:	00003517          	auipc	a0,0x3
    4e38:	e5c50513          	addi	a0,a0,-420 # 7c90 <malloc+0x223a>
    4e3c:	00001097          	auipc	ra,0x1
    4e40:	b5c080e7          	jalr	-1188(ra) # 5998 <printf>
    close(fd);
    4e44:	854a                	mv	a0,s2
    4e46:	00000097          	auipc	ra,0x0
    4e4a:	7fa080e7          	jalr	2042(ra) # 5640 <close>
    if(total == 0)
    4e4e:	f20988e3          	beqz	s3,4d7e <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4e52:	2485                	addiw	s1,s1,1
    4e54:	bd4d                	j	4d06 <fsfull+0x50>

0000000000004e56 <rand>:
{
    4e56:	1141                	addi	sp,sp,-16
    4e58:	e422                	sd	s0,8(sp)
    4e5a:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4e5c:	00003717          	auipc	a4,0x3
    4e60:	42c70713          	addi	a4,a4,1068 # 8288 <randstate>
    4e64:	6308                	ld	a0,0(a4)
    4e66:	001967b7          	lui	a5,0x196
    4e6a:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187b4d>
    4e6e:	02f50533          	mul	a0,a0,a5
    4e72:	3c6ef7b7          	lui	a5,0x3c6ef
    4e76:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e089f>
    4e7a:	953e                	add	a0,a0,a5
    4e7c:	e308                	sd	a0,0(a4)
}
    4e7e:	2501                	sext.w	a0,a0
    4e80:	6422                	ld	s0,8(sp)
    4e82:	0141                	addi	sp,sp,16
    4e84:	8082                	ret

0000000000004e86 <badwrite>:
{
    4e86:	7179                	addi	sp,sp,-48
    4e88:	f406                	sd	ra,40(sp)
    4e8a:	f022                	sd	s0,32(sp)
    4e8c:	ec26                	sd	s1,24(sp)
    4e8e:	e84a                	sd	s2,16(sp)
    4e90:	e44e                	sd	s3,8(sp)
    4e92:	e052                	sd	s4,0(sp)
    4e94:	1800                	addi	s0,sp,48
  unlink("junk");
    4e96:	00003517          	auipc	a0,0x3
    4e9a:	e2250513          	addi	a0,a0,-478 # 7cb8 <malloc+0x2262>
    4e9e:	00000097          	auipc	ra,0x0
    4ea2:	7ca080e7          	jalr	1994(ra) # 5668 <unlink>
    4ea6:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4eaa:	00003997          	auipc	s3,0x3
    4eae:	e0e98993          	addi	s3,s3,-498 # 7cb8 <malloc+0x2262>
    write(fd, (char*)0xffffffffffL, 1);
    4eb2:	5a7d                	li	s4,-1
    4eb4:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4eb8:	20100593          	li	a1,513
    4ebc:	854e                	mv	a0,s3
    4ebe:	00000097          	auipc	ra,0x0
    4ec2:	79a080e7          	jalr	1946(ra) # 5658 <open>
    4ec6:	84aa                	mv	s1,a0
    if(fd < 0){
    4ec8:	06054b63          	bltz	a0,4f3e <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4ecc:	4605                	li	a2,1
    4ece:	85d2                	mv	a1,s4
    4ed0:	00000097          	auipc	ra,0x0
    4ed4:	768080e7          	jalr	1896(ra) # 5638 <write>
    close(fd);
    4ed8:	8526                	mv	a0,s1
    4eda:	00000097          	auipc	ra,0x0
    4ede:	766080e7          	jalr	1894(ra) # 5640 <close>
    unlink("junk");
    4ee2:	854e                	mv	a0,s3
    4ee4:	00000097          	auipc	ra,0x0
    4ee8:	784080e7          	jalr	1924(ra) # 5668 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4eec:	397d                	addiw	s2,s2,-1
    4eee:	fc0915e3          	bnez	s2,4eb8 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4ef2:	20100593          	li	a1,513
    4ef6:	00003517          	auipc	a0,0x3
    4efa:	dc250513          	addi	a0,a0,-574 # 7cb8 <malloc+0x2262>
    4efe:	00000097          	auipc	ra,0x0
    4f02:	75a080e7          	jalr	1882(ra) # 5658 <open>
    4f06:	84aa                	mv	s1,a0
  if(fd < 0){
    4f08:	04054863          	bltz	a0,4f58 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4f0c:	4605                	li	a2,1
    4f0e:	00001597          	auipc	a1,0x1
    4f12:	ffa58593          	addi	a1,a1,-6 # 5f08 <malloc+0x4b2>
    4f16:	00000097          	auipc	ra,0x0
    4f1a:	722080e7          	jalr	1826(ra) # 5638 <write>
    4f1e:	4785                	li	a5,1
    4f20:	04f50963          	beq	a0,a5,4f72 <badwrite+0xec>
    printf("write failed\n");
    4f24:	00003517          	auipc	a0,0x3
    4f28:	db450513          	addi	a0,a0,-588 # 7cd8 <malloc+0x2282>
    4f2c:	00001097          	auipc	ra,0x1
    4f30:	a6c080e7          	jalr	-1428(ra) # 5998 <printf>
    exit(1);
    4f34:	4505                	li	a0,1
    4f36:	00000097          	auipc	ra,0x0
    4f3a:	6e2080e7          	jalr	1762(ra) # 5618 <exit>
      printf("open junk failed\n");
    4f3e:	00003517          	auipc	a0,0x3
    4f42:	d8250513          	addi	a0,a0,-638 # 7cc0 <malloc+0x226a>
    4f46:	00001097          	auipc	ra,0x1
    4f4a:	a52080e7          	jalr	-1454(ra) # 5998 <printf>
      exit(1);
    4f4e:	4505                	li	a0,1
    4f50:	00000097          	auipc	ra,0x0
    4f54:	6c8080e7          	jalr	1736(ra) # 5618 <exit>
    printf("open junk failed\n");
    4f58:	00003517          	auipc	a0,0x3
    4f5c:	d6850513          	addi	a0,a0,-664 # 7cc0 <malloc+0x226a>
    4f60:	00001097          	auipc	ra,0x1
    4f64:	a38080e7          	jalr	-1480(ra) # 5998 <printf>
    exit(1);
    4f68:	4505                	li	a0,1
    4f6a:	00000097          	auipc	ra,0x0
    4f6e:	6ae080e7          	jalr	1710(ra) # 5618 <exit>
  close(fd);
    4f72:	8526                	mv	a0,s1
    4f74:	00000097          	auipc	ra,0x0
    4f78:	6cc080e7          	jalr	1740(ra) # 5640 <close>
  unlink("junk");
    4f7c:	00003517          	auipc	a0,0x3
    4f80:	d3c50513          	addi	a0,a0,-708 # 7cb8 <malloc+0x2262>
    4f84:	00000097          	auipc	ra,0x0
    4f88:	6e4080e7          	jalr	1764(ra) # 5668 <unlink>
  exit(0);
    4f8c:	4501                	li	a0,0
    4f8e:	00000097          	auipc	ra,0x0
    4f92:	68a080e7          	jalr	1674(ra) # 5618 <exit>

0000000000004f96 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4f96:	7139                	addi	sp,sp,-64
    4f98:	fc06                	sd	ra,56(sp)
    4f9a:	f822                	sd	s0,48(sp)
    4f9c:	f426                	sd	s1,40(sp)
    4f9e:	f04a                	sd	s2,32(sp)
    4fa0:	ec4e                	sd	s3,24(sp)
    4fa2:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4fa4:	fc840513          	addi	a0,s0,-56
    4fa8:	00000097          	auipc	ra,0x0
    4fac:	680080e7          	jalr	1664(ra) # 5628 <pipe>
    4fb0:	06054863          	bltz	a0,5020 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4fb4:	00000097          	auipc	ra,0x0
    4fb8:	65c080e7          	jalr	1628(ra) # 5610 <fork>

  if(pid < 0){
    4fbc:	06054f63          	bltz	a0,503a <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4fc0:	ed59                	bnez	a0,505e <countfree+0xc8>
    close(fds[0]);
    4fc2:	fc842503          	lw	a0,-56(s0)
    4fc6:	00000097          	auipc	ra,0x0
    4fca:	67a080e7          	jalr	1658(ra) # 5640 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4fce:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4fd0:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4fd2:	00001917          	auipc	s2,0x1
    4fd6:	f3690913          	addi	s2,s2,-202 # 5f08 <malloc+0x4b2>
      uint64 a = (uint64) sbrk(4096);
    4fda:	6505                	lui	a0,0x1
    4fdc:	00000097          	auipc	ra,0x0
    4fe0:	6c4080e7          	jalr	1732(ra) # 56a0 <sbrk>
      if(a == 0xffffffffffffffff){
    4fe4:	06950863          	beq	a0,s1,5054 <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    4fe8:	6785                	lui	a5,0x1
    4fea:	953e                	add	a0,a0,a5
    4fec:	ff350fa3          	sb	s3,-1(a0) # fff <bigdir+0x9b>
      if(write(fds[1], "x", 1) != 1){
    4ff0:	4605                	li	a2,1
    4ff2:	85ca                	mv	a1,s2
    4ff4:	fcc42503          	lw	a0,-52(s0)
    4ff8:	00000097          	auipc	ra,0x0
    4ffc:	640080e7          	jalr	1600(ra) # 5638 <write>
    5000:	4785                	li	a5,1
    5002:	fcf50ce3          	beq	a0,a5,4fda <countfree+0x44>
        printf("write() failed in countfree()\n");
    5006:	00003517          	auipc	a0,0x3
    500a:	d2250513          	addi	a0,a0,-734 # 7d28 <malloc+0x22d2>
    500e:	00001097          	auipc	ra,0x1
    5012:	98a080e7          	jalr	-1654(ra) # 5998 <printf>
        exit(1);
    5016:	4505                	li	a0,1
    5018:	00000097          	auipc	ra,0x0
    501c:	600080e7          	jalr	1536(ra) # 5618 <exit>
    printf("pipe() failed in countfree()\n");
    5020:	00003517          	auipc	a0,0x3
    5024:	cc850513          	addi	a0,a0,-824 # 7ce8 <malloc+0x2292>
    5028:	00001097          	auipc	ra,0x1
    502c:	970080e7          	jalr	-1680(ra) # 5998 <printf>
    exit(1);
    5030:	4505                	li	a0,1
    5032:	00000097          	auipc	ra,0x0
    5036:	5e6080e7          	jalr	1510(ra) # 5618 <exit>
    printf("fork failed in countfree()\n");
    503a:	00003517          	auipc	a0,0x3
    503e:	cce50513          	addi	a0,a0,-818 # 7d08 <malloc+0x22b2>
    5042:	00001097          	auipc	ra,0x1
    5046:	956080e7          	jalr	-1706(ra) # 5998 <printf>
    exit(1);
    504a:	4505                	li	a0,1
    504c:	00000097          	auipc	ra,0x0
    5050:	5cc080e7          	jalr	1484(ra) # 5618 <exit>
      }
    }

    exit(0);
    5054:	4501                	li	a0,0
    5056:	00000097          	auipc	ra,0x0
    505a:	5c2080e7          	jalr	1474(ra) # 5618 <exit>
  }

  close(fds[1]);
    505e:	fcc42503          	lw	a0,-52(s0)
    5062:	00000097          	auipc	ra,0x0
    5066:	5de080e7          	jalr	1502(ra) # 5640 <close>

  int n = 0;
    506a:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    506c:	4605                	li	a2,1
    506e:	fc740593          	addi	a1,s0,-57
    5072:	fc842503          	lw	a0,-56(s0)
    5076:	00000097          	auipc	ra,0x0
    507a:	5ba080e7          	jalr	1466(ra) # 5630 <read>
    if(cc < 0){
    507e:	00054563          	bltz	a0,5088 <countfree+0xf2>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5082:	c105                	beqz	a0,50a2 <countfree+0x10c>
      break;
    n += 1;
    5084:	2485                	addiw	s1,s1,1
  while(1){
    5086:	b7dd                	j	506c <countfree+0xd6>
      printf("read() failed in countfree()\n");
    5088:	00003517          	auipc	a0,0x3
    508c:	cc050513          	addi	a0,a0,-832 # 7d48 <malloc+0x22f2>
    5090:	00001097          	auipc	ra,0x1
    5094:	908080e7          	jalr	-1784(ra) # 5998 <printf>
      exit(1);
    5098:	4505                	li	a0,1
    509a:	00000097          	auipc	ra,0x0
    509e:	57e080e7          	jalr	1406(ra) # 5618 <exit>
  }

  close(fds[0]);
    50a2:	fc842503          	lw	a0,-56(s0)
    50a6:	00000097          	auipc	ra,0x0
    50aa:	59a080e7          	jalr	1434(ra) # 5640 <close>
  wait((int*)0);
    50ae:	4501                	li	a0,0
    50b0:	00000097          	auipc	ra,0x0
    50b4:	570080e7          	jalr	1392(ra) # 5620 <wait>
  
  return n;
}
    50b8:	8526                	mv	a0,s1
    50ba:	70e2                	ld	ra,56(sp)
    50bc:	7442                	ld	s0,48(sp)
    50be:	74a2                	ld	s1,40(sp)
    50c0:	7902                	ld	s2,32(sp)
    50c2:	69e2                	ld	s3,24(sp)
    50c4:	6121                	addi	sp,sp,64
    50c6:	8082                	ret

00000000000050c8 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    50c8:	7179                	addi	sp,sp,-48
    50ca:	f406                	sd	ra,40(sp)
    50cc:	f022                	sd	s0,32(sp)
    50ce:	ec26                	sd	s1,24(sp)
    50d0:	e84a                	sd	s2,16(sp)
    50d2:	1800                	addi	s0,sp,48
    50d4:	84aa                	mv	s1,a0
    50d6:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    50d8:	00003517          	auipc	a0,0x3
    50dc:	c9050513          	addi	a0,a0,-880 # 7d68 <malloc+0x2312>
    50e0:	00001097          	auipc	ra,0x1
    50e4:	8b8080e7          	jalr	-1864(ra) # 5998 <printf>
  if((pid = fork()) < 0) {
    50e8:	00000097          	auipc	ra,0x0
    50ec:	528080e7          	jalr	1320(ra) # 5610 <fork>
    50f0:	02054e63          	bltz	a0,512c <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    50f4:	c929                	beqz	a0,5146 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    50f6:	fdc40513          	addi	a0,s0,-36
    50fa:	00000097          	auipc	ra,0x0
    50fe:	526080e7          	jalr	1318(ra) # 5620 <wait>
    if(xstatus != 0) 
    5102:	fdc42783          	lw	a5,-36(s0)
    5106:	c7b9                	beqz	a5,5154 <run+0x8c>
      printf("FAILED\n");
    5108:	00003517          	auipc	a0,0x3
    510c:	c8850513          	addi	a0,a0,-888 # 7d90 <malloc+0x233a>
    5110:	00001097          	auipc	ra,0x1
    5114:	888080e7          	jalr	-1912(ra) # 5998 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5118:	fdc42503          	lw	a0,-36(s0)
  }
}
    511c:	00153513          	seqz	a0,a0
    5120:	70a2                	ld	ra,40(sp)
    5122:	7402                	ld	s0,32(sp)
    5124:	64e2                	ld	s1,24(sp)
    5126:	6942                	ld	s2,16(sp)
    5128:	6145                	addi	sp,sp,48
    512a:	8082                	ret
    printf("runtest: fork error\n");
    512c:	00003517          	auipc	a0,0x3
    5130:	c4c50513          	addi	a0,a0,-948 # 7d78 <malloc+0x2322>
    5134:	00001097          	auipc	ra,0x1
    5138:	864080e7          	jalr	-1948(ra) # 5998 <printf>
    exit(1);
    513c:	4505                	li	a0,1
    513e:	00000097          	auipc	ra,0x0
    5142:	4da080e7          	jalr	1242(ra) # 5618 <exit>
    f(s);
    5146:	854a                	mv	a0,s2
    5148:	9482                	jalr	s1
    exit(0);
    514a:	4501                	li	a0,0
    514c:	00000097          	auipc	ra,0x0
    5150:	4cc080e7          	jalr	1228(ra) # 5618 <exit>
      printf("OK\n");
    5154:	00003517          	auipc	a0,0x3
    5158:	c4450513          	addi	a0,a0,-956 # 7d98 <malloc+0x2342>
    515c:	00001097          	auipc	ra,0x1
    5160:	83c080e7          	jalr	-1988(ra) # 5998 <printf>
    5164:	bf55                	j	5118 <run+0x50>

0000000000005166 <main>:

int
main(int argc, char *argv[])
{
    5166:	c1010113          	addi	sp,sp,-1008
    516a:	3e113423          	sd	ra,1000(sp)
    516e:	3e813023          	sd	s0,992(sp)
    5172:	3c913c23          	sd	s1,984(sp)
    5176:	3d213823          	sd	s2,976(sp)
    517a:	3d313423          	sd	s3,968(sp)
    517e:	3d413023          	sd	s4,960(sp)
    5182:	3b513c23          	sd	s5,952(sp)
    5186:	3b613823          	sd	s6,944(sp)
    518a:	1f80                	addi	s0,sp,1008
    518c:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    518e:	4789                	li	a5,2
    5190:	08f50b63          	beq	a0,a5,5226 <main+0xc0>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5194:	4785                	li	a5,1
  char *justone = 0;
    5196:	4901                	li	s2,0
  } else if(argc > 1){
    5198:	0ca7c563          	blt	a5,a0,5262 <main+0xfc>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    519c:	00003797          	auipc	a5,0x3
    51a0:	d1478793          	addi	a5,a5,-748 # 7eb0 <malloc+0x245a>
    51a4:	c1040713          	addi	a4,s0,-1008
    51a8:	00003817          	auipc	a6,0x3
    51ac:	0a880813          	addi	a6,a6,168 # 8250 <malloc+0x27fa>
    51b0:	6388                	ld	a0,0(a5)
    51b2:	678c                	ld	a1,8(a5)
    51b4:	6b90                	ld	a2,16(a5)
    51b6:	6f94                	ld	a3,24(a5)
    51b8:	e308                	sd	a0,0(a4)
    51ba:	e70c                	sd	a1,8(a4)
    51bc:	eb10                	sd	a2,16(a4)
    51be:	ef14                	sd	a3,24(a4)
    51c0:	02078793          	addi	a5,a5,32
    51c4:	02070713          	addi	a4,a4,32
    51c8:	ff0794e3          	bne	a5,a6,51b0 <main+0x4a>
    51cc:	6394                	ld	a3,0(a5)
    51ce:	679c                	ld	a5,8(a5)
    51d0:	e314                	sd	a3,0(a4)
    51d2:	e71c                	sd	a5,8(a4)
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    51d4:	00003517          	auipc	a0,0x3
    51d8:	c7c50513          	addi	a0,a0,-900 # 7e50 <malloc+0x23fa>
    51dc:	00000097          	auipc	ra,0x0
    51e0:	7bc080e7          	jalr	1980(ra) # 5998 <printf>
  int free0 = countfree();
    51e4:	00000097          	auipc	ra,0x0
    51e8:	db2080e7          	jalr	-590(ra) # 4f96 <countfree>
    51ec:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    51ee:	c1843503          	ld	a0,-1000(s0)
    51f2:	c1040493          	addi	s1,s0,-1008
  int fail = 0;
    51f6:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    51f8:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    51fa:	e55d                	bnez	a0,52a8 <main+0x142>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    51fc:	00000097          	auipc	ra,0x0
    5200:	d9a080e7          	jalr	-614(ra) # 4f96 <countfree>
    5204:	85aa                	mv	a1,a0
    5206:	0f455163          	bge	a0,s4,52e8 <main+0x182>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    520a:	8652                	mv	a2,s4
    520c:	00003517          	auipc	a0,0x3
    5210:	bfc50513          	addi	a0,a0,-1028 # 7e08 <malloc+0x23b2>
    5214:	00000097          	auipc	ra,0x0
    5218:	784080e7          	jalr	1924(ra) # 5998 <printf>
    exit(1);
    521c:	4505                	li	a0,1
    521e:	00000097          	auipc	ra,0x0
    5222:	3fa080e7          	jalr	1018(ra) # 5618 <exit>
    5226:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5228:	00003597          	auipc	a1,0x3
    522c:	b7858593          	addi	a1,a1,-1160 # 7da0 <malloc+0x234a>
    5230:	6488                	ld	a0,8(s1)
    5232:	00000097          	auipc	ra,0x0
    5236:	18c080e7          	jalr	396(ra) # 53be <strcmp>
    523a:	10050563          	beqz	a0,5344 <main+0x1de>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    523e:	00003597          	auipc	a1,0x3
    5242:	c4a58593          	addi	a1,a1,-950 # 7e88 <malloc+0x2432>
    5246:	6488                	ld	a0,8(s1)
    5248:	00000097          	auipc	ra,0x0
    524c:	176080e7          	jalr	374(ra) # 53be <strcmp>
    5250:	c97d                	beqz	a0,5346 <main+0x1e0>
  } else if(argc == 2 && argv[1][0] != '-'){
    5252:	0084b903          	ld	s2,8(s1)
    5256:	00094703          	lbu	a4,0(s2)
    525a:	02d00793          	li	a5,45
    525e:	f2f71fe3          	bne	a4,a5,519c <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    5262:	00003517          	auipc	a0,0x3
    5266:	b4650513          	addi	a0,a0,-1210 # 7da8 <malloc+0x2352>
    526a:	00000097          	auipc	ra,0x0
    526e:	72e080e7          	jalr	1838(ra) # 5998 <printf>
    exit(1);
    5272:	4505                	li	a0,1
    5274:	00000097          	auipc	ra,0x0
    5278:	3a4080e7          	jalr	932(ra) # 5618 <exit>
          exit(1);
    527c:	4505                	li	a0,1
    527e:	00000097          	auipc	ra,0x0
    5282:	39a080e7          	jalr	922(ra) # 5618 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5286:	40a905bb          	subw	a1,s2,a0
    528a:	855a                	mv	a0,s6
    528c:	00000097          	auipc	ra,0x0
    5290:	70c080e7          	jalr	1804(ra) # 5998 <printf>
        if(continuous != 2)
    5294:	09498463          	beq	s3,s4,531c <main+0x1b6>
          exit(1);
    5298:	4505                	li	a0,1
    529a:	00000097          	auipc	ra,0x0
    529e:	37e080e7          	jalr	894(ra) # 5618 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    52a2:	04c1                	addi	s1,s1,16
    52a4:	6488                	ld	a0,8(s1)
    52a6:	c115                	beqz	a0,52ca <main+0x164>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    52a8:	00090863          	beqz	s2,52b8 <main+0x152>
    52ac:	85ca                	mv	a1,s2
    52ae:	00000097          	auipc	ra,0x0
    52b2:	110080e7          	jalr	272(ra) # 53be <strcmp>
    52b6:	f575                	bnez	a0,52a2 <main+0x13c>
      if(!run(t->f, t->s))
    52b8:	648c                	ld	a1,8(s1)
    52ba:	6088                	ld	a0,0(s1)
    52bc:	00000097          	auipc	ra,0x0
    52c0:	e0c080e7          	jalr	-500(ra) # 50c8 <run>
    52c4:	fd79                	bnez	a0,52a2 <main+0x13c>
        fail = 1;
    52c6:	89d6                	mv	s3,s5
    52c8:	bfe9                	j	52a2 <main+0x13c>
  if(fail){
    52ca:	f20989e3          	beqz	s3,51fc <main+0x96>
    printf("SOME TESTS FAILED\n");
    52ce:	00003517          	auipc	a0,0x3
    52d2:	b2250513          	addi	a0,a0,-1246 # 7df0 <malloc+0x239a>
    52d6:	00000097          	auipc	ra,0x0
    52da:	6c2080e7          	jalr	1730(ra) # 5998 <printf>
    exit(1);
    52de:	4505                	li	a0,1
    52e0:	00000097          	auipc	ra,0x0
    52e4:	338080e7          	jalr	824(ra) # 5618 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    52e8:	00003517          	auipc	a0,0x3
    52ec:	b5050513          	addi	a0,a0,-1200 # 7e38 <malloc+0x23e2>
    52f0:	00000097          	auipc	ra,0x0
    52f4:	6a8080e7          	jalr	1704(ra) # 5998 <printf>
    exit(0);
    52f8:	4501                	li	a0,0
    52fa:	00000097          	auipc	ra,0x0
    52fe:	31e080e7          	jalr	798(ra) # 5618 <exit>
        printf("SOME TESTS FAILED\n");
    5302:	8556                	mv	a0,s5
    5304:	00000097          	auipc	ra,0x0
    5308:	694080e7          	jalr	1684(ra) # 5998 <printf>
        if(continuous != 2)
    530c:	f74998e3          	bne	s3,s4,527c <main+0x116>
      int free1 = countfree();
    5310:	00000097          	auipc	ra,0x0
    5314:	c86080e7          	jalr	-890(ra) # 4f96 <countfree>
      if(free1 < free0){
    5318:	f72547e3          	blt	a0,s2,5286 <main+0x120>
      int free0 = countfree();
    531c:	00000097          	auipc	ra,0x0
    5320:	c7a080e7          	jalr	-902(ra) # 4f96 <countfree>
    5324:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5326:	c1843583          	ld	a1,-1000(s0)
    532a:	d1fd                	beqz	a1,5310 <main+0x1aa>
    532c:	c1040493          	addi	s1,s0,-1008
        if(!run(t->f, t->s)){
    5330:	6088                	ld	a0,0(s1)
    5332:	00000097          	auipc	ra,0x0
    5336:	d96080e7          	jalr	-618(ra) # 50c8 <run>
    533a:	d561                	beqz	a0,5302 <main+0x19c>
      for (struct test *t = tests; t->s != 0; t++) {
    533c:	04c1                	addi	s1,s1,16
    533e:	648c                	ld	a1,8(s1)
    5340:	f9e5                	bnez	a1,5330 <main+0x1ca>
    5342:	b7f9                	j	5310 <main+0x1aa>
    continuous = 1;
    5344:	4985                	li	s3,1
  } tests[] = {
    5346:	00003797          	auipc	a5,0x3
    534a:	b6a78793          	addi	a5,a5,-1174 # 7eb0 <malloc+0x245a>
    534e:	c1040713          	addi	a4,s0,-1008
    5352:	00003817          	auipc	a6,0x3
    5356:	efe80813          	addi	a6,a6,-258 # 8250 <malloc+0x27fa>
    535a:	6388                	ld	a0,0(a5)
    535c:	678c                	ld	a1,8(a5)
    535e:	6b90                	ld	a2,16(a5)
    5360:	6f94                	ld	a3,24(a5)
    5362:	e308                	sd	a0,0(a4)
    5364:	e70c                	sd	a1,8(a4)
    5366:	eb10                	sd	a2,16(a4)
    5368:	ef14                	sd	a3,24(a4)
    536a:	02078793          	addi	a5,a5,32
    536e:	02070713          	addi	a4,a4,32
    5372:	ff0794e3          	bne	a5,a6,535a <main+0x1f4>
    5376:	6394                	ld	a3,0(a5)
    5378:	679c                	ld	a5,8(a5)
    537a:	e314                	sd	a3,0(a4)
    537c:	e71c                	sd	a5,8(a4)
    printf("continuous usertests starting\n");
    537e:	00003517          	auipc	a0,0x3
    5382:	aea50513          	addi	a0,a0,-1302 # 7e68 <malloc+0x2412>
    5386:	00000097          	auipc	ra,0x0
    538a:	612080e7          	jalr	1554(ra) # 5998 <printf>
        printf("SOME TESTS FAILED\n");
    538e:	00003a97          	auipc	s5,0x3
    5392:	a62a8a93          	addi	s5,s5,-1438 # 7df0 <malloc+0x239a>
        if(continuous != 2)
    5396:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5398:	00003b17          	auipc	s6,0x3
    539c:	a38b0b13          	addi	s6,s6,-1480 # 7dd0 <malloc+0x237a>
    53a0:	bfb5                	j	531c <main+0x1b6>

00000000000053a2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    53a2:	1141                	addi	sp,sp,-16
    53a4:	e422                	sd	s0,8(sp)
    53a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    53a8:	87aa                	mv	a5,a0
    53aa:	0585                	addi	a1,a1,1
    53ac:	0785                	addi	a5,a5,1
    53ae:	fff5c703          	lbu	a4,-1(a1)
    53b2:	fee78fa3          	sb	a4,-1(a5)
    53b6:	fb75                	bnez	a4,53aa <strcpy+0x8>
    ;
  return os;
}
    53b8:	6422                	ld	s0,8(sp)
    53ba:	0141                	addi	sp,sp,16
    53bc:	8082                	ret

00000000000053be <strcmp>:

int
strcmp(const char *p, const char *q)
{
    53be:	1141                	addi	sp,sp,-16
    53c0:	e422                	sd	s0,8(sp)
    53c2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    53c4:	00054783          	lbu	a5,0(a0)
    53c8:	cb91                	beqz	a5,53dc <strcmp+0x1e>
    53ca:	0005c703          	lbu	a4,0(a1)
    53ce:	00f71763          	bne	a4,a5,53dc <strcmp+0x1e>
    p++, q++;
    53d2:	0505                	addi	a0,a0,1
    53d4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    53d6:	00054783          	lbu	a5,0(a0)
    53da:	fbe5                	bnez	a5,53ca <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    53dc:	0005c503          	lbu	a0,0(a1)
}
    53e0:	40a7853b          	subw	a0,a5,a0
    53e4:	6422                	ld	s0,8(sp)
    53e6:	0141                	addi	sp,sp,16
    53e8:	8082                	ret

00000000000053ea <strlen>:

uint
strlen(const char *s)
{
    53ea:	1141                	addi	sp,sp,-16
    53ec:	e422                	sd	s0,8(sp)
    53ee:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    53f0:	00054783          	lbu	a5,0(a0)
    53f4:	cf91                	beqz	a5,5410 <strlen+0x26>
    53f6:	0505                	addi	a0,a0,1
    53f8:	87aa                	mv	a5,a0
    53fa:	4685                	li	a3,1
    53fc:	9e89                	subw	a3,a3,a0
    53fe:	00f6853b          	addw	a0,a3,a5
    5402:	0785                	addi	a5,a5,1
    5404:	fff7c703          	lbu	a4,-1(a5)
    5408:	fb7d                	bnez	a4,53fe <strlen+0x14>
    ;
  return n;
}
    540a:	6422                	ld	s0,8(sp)
    540c:	0141                	addi	sp,sp,16
    540e:	8082                	ret
  for(n = 0; s[n]; n++)
    5410:	4501                	li	a0,0
    5412:	bfe5                	j	540a <strlen+0x20>

0000000000005414 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5414:	1141                	addi	sp,sp,-16
    5416:	e422                	sd	s0,8(sp)
    5418:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    541a:	ce09                	beqz	a2,5434 <memset+0x20>
    541c:	87aa                	mv	a5,a0
    541e:	fff6071b          	addiw	a4,a2,-1
    5422:	1702                	slli	a4,a4,0x20
    5424:	9301                	srli	a4,a4,0x20
    5426:	0705                	addi	a4,a4,1
    5428:	972a                	add	a4,a4,a0
    cdst[i] = c;
    542a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    542e:	0785                	addi	a5,a5,1
    5430:	fee79de3          	bne	a5,a4,542a <memset+0x16>
  }
  return dst;
}
    5434:	6422                	ld	s0,8(sp)
    5436:	0141                	addi	sp,sp,16
    5438:	8082                	ret

000000000000543a <strchr>:

char*
strchr(const char *s, char c)
{
    543a:	1141                	addi	sp,sp,-16
    543c:	e422                	sd	s0,8(sp)
    543e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5440:	00054783          	lbu	a5,0(a0)
    5444:	cb99                	beqz	a5,545a <strchr+0x20>
    if(*s == c)
    5446:	00f58763          	beq	a1,a5,5454 <strchr+0x1a>
  for(; *s; s++)
    544a:	0505                	addi	a0,a0,1
    544c:	00054783          	lbu	a5,0(a0)
    5450:	fbfd                	bnez	a5,5446 <strchr+0xc>
      return (char*)s;
  return 0;
    5452:	4501                	li	a0,0
}
    5454:	6422                	ld	s0,8(sp)
    5456:	0141                	addi	sp,sp,16
    5458:	8082                	ret
  return 0;
    545a:	4501                	li	a0,0
    545c:	bfe5                	j	5454 <strchr+0x1a>

000000000000545e <gets>:

char*
gets(char *buf, int max)
{
    545e:	711d                	addi	sp,sp,-96
    5460:	ec86                	sd	ra,88(sp)
    5462:	e8a2                	sd	s0,80(sp)
    5464:	e4a6                	sd	s1,72(sp)
    5466:	e0ca                	sd	s2,64(sp)
    5468:	fc4e                	sd	s3,56(sp)
    546a:	f852                	sd	s4,48(sp)
    546c:	f456                	sd	s5,40(sp)
    546e:	f05a                	sd	s6,32(sp)
    5470:	ec5e                	sd	s7,24(sp)
    5472:	1080                	addi	s0,sp,96
    5474:	8baa                	mv	s7,a0
    5476:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5478:	892a                	mv	s2,a0
    547a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    547c:	4aa9                	li	s5,10
    547e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5480:	89a6                	mv	s3,s1
    5482:	2485                	addiw	s1,s1,1
    5484:	0344d863          	bge	s1,s4,54b4 <gets+0x56>
    cc = read(0, &c, 1);
    5488:	4605                	li	a2,1
    548a:	faf40593          	addi	a1,s0,-81
    548e:	4501                	li	a0,0
    5490:	00000097          	auipc	ra,0x0
    5494:	1a0080e7          	jalr	416(ra) # 5630 <read>
    if(cc < 1)
    5498:	00a05e63          	blez	a0,54b4 <gets+0x56>
    buf[i++] = c;
    549c:	faf44783          	lbu	a5,-81(s0)
    54a0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    54a4:	01578763          	beq	a5,s5,54b2 <gets+0x54>
    54a8:	0905                	addi	s2,s2,1
    54aa:	fd679be3          	bne	a5,s6,5480 <gets+0x22>
  for(i=0; i+1 < max; ){
    54ae:	89a6                	mv	s3,s1
    54b0:	a011                	j	54b4 <gets+0x56>
    54b2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    54b4:	99de                	add	s3,s3,s7
    54b6:	00098023          	sb	zero,0(s3)
  return buf;
}
    54ba:	855e                	mv	a0,s7
    54bc:	60e6                	ld	ra,88(sp)
    54be:	6446                	ld	s0,80(sp)
    54c0:	64a6                	ld	s1,72(sp)
    54c2:	6906                	ld	s2,64(sp)
    54c4:	79e2                	ld	s3,56(sp)
    54c6:	7a42                	ld	s4,48(sp)
    54c8:	7aa2                	ld	s5,40(sp)
    54ca:	7b02                	ld	s6,32(sp)
    54cc:	6be2                	ld	s7,24(sp)
    54ce:	6125                	addi	sp,sp,96
    54d0:	8082                	ret

00000000000054d2 <stat>:

int
stat(const char *n, struct stat *st)
{
    54d2:	1101                	addi	sp,sp,-32
    54d4:	ec06                	sd	ra,24(sp)
    54d6:	e822                	sd	s0,16(sp)
    54d8:	e426                	sd	s1,8(sp)
    54da:	e04a                	sd	s2,0(sp)
    54dc:	1000                	addi	s0,sp,32
    54de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    54e0:	4581                	li	a1,0
    54e2:	00000097          	auipc	ra,0x0
    54e6:	176080e7          	jalr	374(ra) # 5658 <open>
  if(fd < 0)
    54ea:	02054563          	bltz	a0,5514 <stat+0x42>
    54ee:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    54f0:	85ca                	mv	a1,s2
    54f2:	00000097          	auipc	ra,0x0
    54f6:	17e080e7          	jalr	382(ra) # 5670 <fstat>
    54fa:	892a                	mv	s2,a0
  close(fd);
    54fc:	8526                	mv	a0,s1
    54fe:	00000097          	auipc	ra,0x0
    5502:	142080e7          	jalr	322(ra) # 5640 <close>
  return r;
}
    5506:	854a                	mv	a0,s2
    5508:	60e2                	ld	ra,24(sp)
    550a:	6442                	ld	s0,16(sp)
    550c:	64a2                	ld	s1,8(sp)
    550e:	6902                	ld	s2,0(sp)
    5510:	6105                	addi	sp,sp,32
    5512:	8082                	ret
    return -1;
    5514:	597d                	li	s2,-1
    5516:	bfc5                	j	5506 <stat+0x34>

0000000000005518 <atoi>:

int
atoi(const char *s)
{
    5518:	1141                	addi	sp,sp,-16
    551a:	e422                	sd	s0,8(sp)
    551c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    551e:	00054603          	lbu	a2,0(a0)
    5522:	fd06079b          	addiw	a5,a2,-48
    5526:	0ff7f793          	andi	a5,a5,255
    552a:	4725                	li	a4,9
    552c:	02f76963          	bltu	a4,a5,555e <atoi+0x46>
    5530:	86aa                	mv	a3,a0
  n = 0;
    5532:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5534:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5536:	0685                	addi	a3,a3,1
    5538:	0025179b          	slliw	a5,a0,0x2
    553c:	9fa9                	addw	a5,a5,a0
    553e:	0017979b          	slliw	a5,a5,0x1
    5542:	9fb1                	addw	a5,a5,a2
    5544:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5548:	0006c603          	lbu	a2,0(a3) # 1000 <bigdir+0x9c>
    554c:	fd06071b          	addiw	a4,a2,-48
    5550:	0ff77713          	andi	a4,a4,255
    5554:	fee5f1e3          	bgeu	a1,a4,5536 <atoi+0x1e>
  return n;
}
    5558:	6422                	ld	s0,8(sp)
    555a:	0141                	addi	sp,sp,16
    555c:	8082                	ret
  n = 0;
    555e:	4501                	li	a0,0
    5560:	bfe5                	j	5558 <atoi+0x40>

0000000000005562 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5562:	1141                	addi	sp,sp,-16
    5564:	e422                	sd	s0,8(sp)
    5566:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5568:	02b57663          	bgeu	a0,a1,5594 <memmove+0x32>
    while(n-- > 0)
    556c:	02c05163          	blez	a2,558e <memmove+0x2c>
    5570:	fff6079b          	addiw	a5,a2,-1
    5574:	1782                	slli	a5,a5,0x20
    5576:	9381                	srli	a5,a5,0x20
    5578:	0785                	addi	a5,a5,1
    557a:	97aa                	add	a5,a5,a0
  dst = vdst;
    557c:	872a                	mv	a4,a0
      *dst++ = *src++;
    557e:	0585                	addi	a1,a1,1
    5580:	0705                	addi	a4,a4,1
    5582:	fff5c683          	lbu	a3,-1(a1)
    5586:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    558a:	fee79ae3          	bne	a5,a4,557e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    558e:	6422                	ld	s0,8(sp)
    5590:	0141                	addi	sp,sp,16
    5592:	8082                	ret
    dst += n;
    5594:	00c50733          	add	a4,a0,a2
    src += n;
    5598:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    559a:	fec05ae3          	blez	a2,558e <memmove+0x2c>
    559e:	fff6079b          	addiw	a5,a2,-1
    55a2:	1782                	slli	a5,a5,0x20
    55a4:	9381                	srli	a5,a5,0x20
    55a6:	fff7c793          	not	a5,a5
    55aa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    55ac:	15fd                	addi	a1,a1,-1
    55ae:	177d                	addi	a4,a4,-1
    55b0:	0005c683          	lbu	a3,0(a1)
    55b4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    55b8:	fee79ae3          	bne	a5,a4,55ac <memmove+0x4a>
    55bc:	bfc9                	j	558e <memmove+0x2c>

00000000000055be <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    55be:	1141                	addi	sp,sp,-16
    55c0:	e422                	sd	s0,8(sp)
    55c2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    55c4:	ca05                	beqz	a2,55f4 <memcmp+0x36>
    55c6:	fff6069b          	addiw	a3,a2,-1
    55ca:	1682                	slli	a3,a3,0x20
    55cc:	9281                	srli	a3,a3,0x20
    55ce:	0685                	addi	a3,a3,1
    55d0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    55d2:	00054783          	lbu	a5,0(a0)
    55d6:	0005c703          	lbu	a4,0(a1)
    55da:	00e79863          	bne	a5,a4,55ea <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    55de:	0505                	addi	a0,a0,1
    p2++;
    55e0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    55e2:	fed518e3          	bne	a0,a3,55d2 <memcmp+0x14>
  }
  return 0;
    55e6:	4501                	li	a0,0
    55e8:	a019                	j	55ee <memcmp+0x30>
      return *p1 - *p2;
    55ea:	40e7853b          	subw	a0,a5,a4
}
    55ee:	6422                	ld	s0,8(sp)
    55f0:	0141                	addi	sp,sp,16
    55f2:	8082                	ret
  return 0;
    55f4:	4501                	li	a0,0
    55f6:	bfe5                	j	55ee <memcmp+0x30>

00000000000055f8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    55f8:	1141                	addi	sp,sp,-16
    55fa:	e406                	sd	ra,8(sp)
    55fc:	e022                	sd	s0,0(sp)
    55fe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5600:	00000097          	auipc	ra,0x0
    5604:	f62080e7          	jalr	-158(ra) # 5562 <memmove>
}
    5608:	60a2                	ld	ra,8(sp)
    560a:	6402                	ld	s0,0(sp)
    560c:	0141                	addi	sp,sp,16
    560e:	8082                	ret

0000000000005610 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5610:	4885                	li	a7,1
 ecall
    5612:	00000073          	ecall
 ret
    5616:	8082                	ret

0000000000005618 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5618:	4889                	li	a7,2
 ecall
    561a:	00000073          	ecall
 ret
    561e:	8082                	ret

0000000000005620 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5620:	488d                	li	a7,3
 ecall
    5622:	00000073          	ecall
 ret
    5626:	8082                	ret

0000000000005628 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5628:	4891                	li	a7,4
 ecall
    562a:	00000073          	ecall
 ret
    562e:	8082                	ret

0000000000005630 <read>:
.global read
read:
 li a7, SYS_read
    5630:	4895                	li	a7,5
 ecall
    5632:	00000073          	ecall
 ret
    5636:	8082                	ret

0000000000005638 <write>:
.global write
write:
 li a7, SYS_write
    5638:	48c1                	li	a7,16
 ecall
    563a:	00000073          	ecall
 ret
    563e:	8082                	ret

0000000000005640 <close>:
.global close
close:
 li a7, SYS_close
    5640:	48d5                	li	a7,21
 ecall
    5642:	00000073          	ecall
 ret
    5646:	8082                	ret

0000000000005648 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5648:	4899                	li	a7,6
 ecall
    564a:	00000073          	ecall
 ret
    564e:	8082                	ret

0000000000005650 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5650:	489d                	li	a7,7
 ecall
    5652:	00000073          	ecall
 ret
    5656:	8082                	ret

0000000000005658 <open>:
.global open
open:
 li a7, SYS_open
    5658:	48bd                	li	a7,15
 ecall
    565a:	00000073          	ecall
 ret
    565e:	8082                	ret

0000000000005660 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5660:	48c5                	li	a7,17
 ecall
    5662:	00000073          	ecall
 ret
    5666:	8082                	ret

0000000000005668 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5668:	48c9                	li	a7,18
 ecall
    566a:	00000073          	ecall
 ret
    566e:	8082                	ret

0000000000005670 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5670:	48a1                	li	a7,8
 ecall
    5672:	00000073          	ecall
 ret
    5676:	8082                	ret

0000000000005678 <link>:
.global link
link:
 li a7, SYS_link
    5678:	48cd                	li	a7,19
 ecall
    567a:	00000073          	ecall
 ret
    567e:	8082                	ret

0000000000005680 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5680:	48d1                	li	a7,20
 ecall
    5682:	00000073          	ecall
 ret
    5686:	8082                	ret

0000000000005688 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5688:	48a5                	li	a7,9
 ecall
    568a:	00000073          	ecall
 ret
    568e:	8082                	ret

0000000000005690 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5690:	48a9                	li	a7,10
 ecall
    5692:	00000073          	ecall
 ret
    5696:	8082                	ret

0000000000005698 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5698:	48ad                	li	a7,11
 ecall
    569a:	00000073          	ecall
 ret
    569e:	8082                	ret

00000000000056a0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    56a0:	48b1                	li	a7,12
 ecall
    56a2:	00000073          	ecall
 ret
    56a6:	8082                	ret

00000000000056a8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    56a8:	48b5                	li	a7,13
 ecall
    56aa:	00000073          	ecall
 ret
    56ae:	8082                	ret

00000000000056b0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    56b0:	48b9                	li	a7,14
 ecall
    56b2:	00000073          	ecall
 ret
    56b6:	8082                	ret

00000000000056b8 <symlink>:
.global symlink
symlink:
 li a7, SYS_symlink
    56b8:	48d9                	li	a7,22
 ecall
    56ba:	00000073          	ecall
 ret
    56be:	8082                	ret

00000000000056c0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    56c0:	1101                	addi	sp,sp,-32
    56c2:	ec06                	sd	ra,24(sp)
    56c4:	e822                	sd	s0,16(sp)
    56c6:	1000                	addi	s0,sp,32
    56c8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    56cc:	4605                	li	a2,1
    56ce:	fef40593          	addi	a1,s0,-17
    56d2:	00000097          	auipc	ra,0x0
    56d6:	f66080e7          	jalr	-154(ra) # 5638 <write>
}
    56da:	60e2                	ld	ra,24(sp)
    56dc:	6442                	ld	s0,16(sp)
    56de:	6105                	addi	sp,sp,32
    56e0:	8082                	ret

00000000000056e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    56e2:	7139                	addi	sp,sp,-64
    56e4:	fc06                	sd	ra,56(sp)
    56e6:	f822                	sd	s0,48(sp)
    56e8:	f426                	sd	s1,40(sp)
    56ea:	f04a                	sd	s2,32(sp)
    56ec:	ec4e                	sd	s3,24(sp)
    56ee:	0080                	addi	s0,sp,64
    56f0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    56f2:	c299                	beqz	a3,56f8 <printint+0x16>
    56f4:	0805c863          	bltz	a1,5784 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    56f8:	2581                	sext.w	a1,a1
  neg = 0;
    56fa:	4881                	li	a7,0
    56fc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5700:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5702:	2601                	sext.w	a2,a2
    5704:	00003517          	auipc	a0,0x3
    5708:	b6450513          	addi	a0,a0,-1180 # 8268 <digits>
    570c:	883a                	mv	a6,a4
    570e:	2705                	addiw	a4,a4,1
    5710:	02c5f7bb          	remuw	a5,a1,a2
    5714:	1782                	slli	a5,a5,0x20
    5716:	9381                	srli	a5,a5,0x20
    5718:	97aa                	add	a5,a5,a0
    571a:	0007c783          	lbu	a5,0(a5)
    571e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5722:	0005879b          	sext.w	a5,a1
    5726:	02c5d5bb          	divuw	a1,a1,a2
    572a:	0685                	addi	a3,a3,1
    572c:	fec7f0e3          	bgeu	a5,a2,570c <printint+0x2a>
  if(neg)
    5730:	00088b63          	beqz	a7,5746 <printint+0x64>
    buf[i++] = '-';
    5734:	fd040793          	addi	a5,s0,-48
    5738:	973e                	add	a4,a4,a5
    573a:	02d00793          	li	a5,45
    573e:	fef70823          	sb	a5,-16(a4)
    5742:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5746:	02e05863          	blez	a4,5776 <printint+0x94>
    574a:	fc040793          	addi	a5,s0,-64
    574e:	00e78933          	add	s2,a5,a4
    5752:	fff78993          	addi	s3,a5,-1
    5756:	99ba                	add	s3,s3,a4
    5758:	377d                	addiw	a4,a4,-1
    575a:	1702                	slli	a4,a4,0x20
    575c:	9301                	srli	a4,a4,0x20
    575e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5762:	fff94583          	lbu	a1,-1(s2)
    5766:	8526                	mv	a0,s1
    5768:	00000097          	auipc	ra,0x0
    576c:	f58080e7          	jalr	-168(ra) # 56c0 <putc>
  while(--i >= 0)
    5770:	197d                	addi	s2,s2,-1
    5772:	ff3918e3          	bne	s2,s3,5762 <printint+0x80>
}
    5776:	70e2                	ld	ra,56(sp)
    5778:	7442                	ld	s0,48(sp)
    577a:	74a2                	ld	s1,40(sp)
    577c:	7902                	ld	s2,32(sp)
    577e:	69e2                	ld	s3,24(sp)
    5780:	6121                	addi	sp,sp,64
    5782:	8082                	ret
    x = -xx;
    5784:	40b005bb          	negw	a1,a1
    neg = 1;
    5788:	4885                	li	a7,1
    x = -xx;
    578a:	bf8d                	j	56fc <printint+0x1a>

000000000000578c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    578c:	7119                	addi	sp,sp,-128
    578e:	fc86                	sd	ra,120(sp)
    5790:	f8a2                	sd	s0,112(sp)
    5792:	f4a6                	sd	s1,104(sp)
    5794:	f0ca                	sd	s2,96(sp)
    5796:	ecce                	sd	s3,88(sp)
    5798:	e8d2                	sd	s4,80(sp)
    579a:	e4d6                	sd	s5,72(sp)
    579c:	e0da                	sd	s6,64(sp)
    579e:	fc5e                	sd	s7,56(sp)
    57a0:	f862                	sd	s8,48(sp)
    57a2:	f466                	sd	s9,40(sp)
    57a4:	f06a                	sd	s10,32(sp)
    57a6:	ec6e                	sd	s11,24(sp)
    57a8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    57aa:	0005c903          	lbu	s2,0(a1)
    57ae:	18090f63          	beqz	s2,594c <vprintf+0x1c0>
    57b2:	8aaa                	mv	s5,a0
    57b4:	8b32                	mv	s6,a2
    57b6:	00158493          	addi	s1,a1,1
  state = 0;
    57ba:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    57bc:	02500a13          	li	s4,37
      if(c == 'd'){
    57c0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    57c4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    57c8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    57cc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    57d0:	00003b97          	auipc	s7,0x3
    57d4:	a98b8b93          	addi	s7,s7,-1384 # 8268 <digits>
    57d8:	a839                	j	57f6 <vprintf+0x6a>
        putc(fd, c);
    57da:	85ca                	mv	a1,s2
    57dc:	8556                	mv	a0,s5
    57de:	00000097          	auipc	ra,0x0
    57e2:	ee2080e7          	jalr	-286(ra) # 56c0 <putc>
    57e6:	a019                	j	57ec <vprintf+0x60>
    } else if(state == '%'){
    57e8:	01498f63          	beq	s3,s4,5806 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    57ec:	0485                	addi	s1,s1,1
    57ee:	fff4c903          	lbu	s2,-1(s1)
    57f2:	14090d63          	beqz	s2,594c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    57f6:	0009079b          	sext.w	a5,s2
    if(state == 0){
    57fa:	fe0997e3          	bnez	s3,57e8 <vprintf+0x5c>
      if(c == '%'){
    57fe:	fd479ee3          	bne	a5,s4,57da <vprintf+0x4e>
        state = '%';
    5802:	89be                	mv	s3,a5
    5804:	b7e5                	j	57ec <vprintf+0x60>
      if(c == 'd'){
    5806:	05878063          	beq	a5,s8,5846 <vprintf+0xba>
      } else if(c == 'l') {
    580a:	05978c63          	beq	a5,s9,5862 <vprintf+0xd6>
      } else if(c == 'x') {
    580e:	07a78863          	beq	a5,s10,587e <vprintf+0xf2>
      } else if(c == 'p') {
    5812:	09b78463          	beq	a5,s11,589a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5816:	07300713          	li	a4,115
    581a:	0ce78663          	beq	a5,a4,58e6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    581e:	06300713          	li	a4,99
    5822:	0ee78e63          	beq	a5,a4,591e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5826:	11478863          	beq	a5,s4,5936 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    582a:	85d2                	mv	a1,s4
    582c:	8556                	mv	a0,s5
    582e:	00000097          	auipc	ra,0x0
    5832:	e92080e7          	jalr	-366(ra) # 56c0 <putc>
        putc(fd, c);
    5836:	85ca                	mv	a1,s2
    5838:	8556                	mv	a0,s5
    583a:	00000097          	auipc	ra,0x0
    583e:	e86080e7          	jalr	-378(ra) # 56c0 <putc>
      }
      state = 0;
    5842:	4981                	li	s3,0
    5844:	b765                	j	57ec <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5846:	008b0913          	addi	s2,s6,8
    584a:	4685                	li	a3,1
    584c:	4629                	li	a2,10
    584e:	000b2583          	lw	a1,0(s6)
    5852:	8556                	mv	a0,s5
    5854:	00000097          	auipc	ra,0x0
    5858:	e8e080e7          	jalr	-370(ra) # 56e2 <printint>
    585c:	8b4a                	mv	s6,s2
      state = 0;
    585e:	4981                	li	s3,0
    5860:	b771                	j	57ec <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5862:	008b0913          	addi	s2,s6,8
    5866:	4681                	li	a3,0
    5868:	4629                	li	a2,10
    586a:	000b2583          	lw	a1,0(s6)
    586e:	8556                	mv	a0,s5
    5870:	00000097          	auipc	ra,0x0
    5874:	e72080e7          	jalr	-398(ra) # 56e2 <printint>
    5878:	8b4a                	mv	s6,s2
      state = 0;
    587a:	4981                	li	s3,0
    587c:	bf85                	j	57ec <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    587e:	008b0913          	addi	s2,s6,8
    5882:	4681                	li	a3,0
    5884:	4641                	li	a2,16
    5886:	000b2583          	lw	a1,0(s6)
    588a:	8556                	mv	a0,s5
    588c:	00000097          	auipc	ra,0x0
    5890:	e56080e7          	jalr	-426(ra) # 56e2 <printint>
    5894:	8b4a                	mv	s6,s2
      state = 0;
    5896:	4981                	li	s3,0
    5898:	bf91                	j	57ec <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    589a:	008b0793          	addi	a5,s6,8
    589e:	f8f43423          	sd	a5,-120(s0)
    58a2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    58a6:	03000593          	li	a1,48
    58aa:	8556                	mv	a0,s5
    58ac:	00000097          	auipc	ra,0x0
    58b0:	e14080e7          	jalr	-492(ra) # 56c0 <putc>
  putc(fd, 'x');
    58b4:	85ea                	mv	a1,s10
    58b6:	8556                	mv	a0,s5
    58b8:	00000097          	auipc	ra,0x0
    58bc:	e08080e7          	jalr	-504(ra) # 56c0 <putc>
    58c0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    58c2:	03c9d793          	srli	a5,s3,0x3c
    58c6:	97de                	add	a5,a5,s7
    58c8:	0007c583          	lbu	a1,0(a5)
    58cc:	8556                	mv	a0,s5
    58ce:	00000097          	auipc	ra,0x0
    58d2:	df2080e7          	jalr	-526(ra) # 56c0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    58d6:	0992                	slli	s3,s3,0x4
    58d8:	397d                	addiw	s2,s2,-1
    58da:	fe0914e3          	bnez	s2,58c2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    58de:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    58e2:	4981                	li	s3,0
    58e4:	b721                	j	57ec <vprintf+0x60>
        s = va_arg(ap, char*);
    58e6:	008b0993          	addi	s3,s6,8
    58ea:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    58ee:	02090163          	beqz	s2,5910 <vprintf+0x184>
        while(*s != 0){
    58f2:	00094583          	lbu	a1,0(s2)
    58f6:	c9a1                	beqz	a1,5946 <vprintf+0x1ba>
          putc(fd, *s);
    58f8:	8556                	mv	a0,s5
    58fa:	00000097          	auipc	ra,0x0
    58fe:	dc6080e7          	jalr	-570(ra) # 56c0 <putc>
          s++;
    5902:	0905                	addi	s2,s2,1
        while(*s != 0){
    5904:	00094583          	lbu	a1,0(s2)
    5908:	f9e5                	bnez	a1,58f8 <vprintf+0x16c>
        s = va_arg(ap, char*);
    590a:	8b4e                	mv	s6,s3
      state = 0;
    590c:	4981                	li	s3,0
    590e:	bdf9                	j	57ec <vprintf+0x60>
          s = "(null)";
    5910:	00003917          	auipc	s2,0x3
    5914:	95090913          	addi	s2,s2,-1712 # 8260 <malloc+0x280a>
        while(*s != 0){
    5918:	02800593          	li	a1,40
    591c:	bff1                	j	58f8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    591e:	008b0913          	addi	s2,s6,8
    5922:	000b4583          	lbu	a1,0(s6)
    5926:	8556                	mv	a0,s5
    5928:	00000097          	auipc	ra,0x0
    592c:	d98080e7          	jalr	-616(ra) # 56c0 <putc>
    5930:	8b4a                	mv	s6,s2
      state = 0;
    5932:	4981                	li	s3,0
    5934:	bd65                	j	57ec <vprintf+0x60>
        putc(fd, c);
    5936:	85d2                	mv	a1,s4
    5938:	8556                	mv	a0,s5
    593a:	00000097          	auipc	ra,0x0
    593e:	d86080e7          	jalr	-634(ra) # 56c0 <putc>
      state = 0;
    5942:	4981                	li	s3,0
    5944:	b565                	j	57ec <vprintf+0x60>
        s = va_arg(ap, char*);
    5946:	8b4e                	mv	s6,s3
      state = 0;
    5948:	4981                	li	s3,0
    594a:	b54d                	j	57ec <vprintf+0x60>
    }
  }
}
    594c:	70e6                	ld	ra,120(sp)
    594e:	7446                	ld	s0,112(sp)
    5950:	74a6                	ld	s1,104(sp)
    5952:	7906                	ld	s2,96(sp)
    5954:	69e6                	ld	s3,88(sp)
    5956:	6a46                	ld	s4,80(sp)
    5958:	6aa6                	ld	s5,72(sp)
    595a:	6b06                	ld	s6,64(sp)
    595c:	7be2                	ld	s7,56(sp)
    595e:	7c42                	ld	s8,48(sp)
    5960:	7ca2                	ld	s9,40(sp)
    5962:	7d02                	ld	s10,32(sp)
    5964:	6de2                	ld	s11,24(sp)
    5966:	6109                	addi	sp,sp,128
    5968:	8082                	ret

000000000000596a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    596a:	715d                	addi	sp,sp,-80
    596c:	ec06                	sd	ra,24(sp)
    596e:	e822                	sd	s0,16(sp)
    5970:	1000                	addi	s0,sp,32
    5972:	e010                	sd	a2,0(s0)
    5974:	e414                	sd	a3,8(s0)
    5976:	e818                	sd	a4,16(s0)
    5978:	ec1c                	sd	a5,24(s0)
    597a:	03043023          	sd	a6,32(s0)
    597e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5982:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5986:	8622                	mv	a2,s0
    5988:	00000097          	auipc	ra,0x0
    598c:	e04080e7          	jalr	-508(ra) # 578c <vprintf>
}
    5990:	60e2                	ld	ra,24(sp)
    5992:	6442                	ld	s0,16(sp)
    5994:	6161                	addi	sp,sp,80
    5996:	8082                	ret

0000000000005998 <printf>:

void
printf(const char *fmt, ...)
{
    5998:	711d                	addi	sp,sp,-96
    599a:	ec06                	sd	ra,24(sp)
    599c:	e822                	sd	s0,16(sp)
    599e:	1000                	addi	s0,sp,32
    59a0:	e40c                	sd	a1,8(s0)
    59a2:	e810                	sd	a2,16(s0)
    59a4:	ec14                	sd	a3,24(s0)
    59a6:	f018                	sd	a4,32(s0)
    59a8:	f41c                	sd	a5,40(s0)
    59aa:	03043823          	sd	a6,48(s0)
    59ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    59b2:	00840613          	addi	a2,s0,8
    59b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    59ba:	85aa                	mv	a1,a0
    59bc:	4505                	li	a0,1
    59be:	00000097          	auipc	ra,0x0
    59c2:	dce080e7          	jalr	-562(ra) # 578c <vprintf>
}
    59c6:	60e2                	ld	ra,24(sp)
    59c8:	6442                	ld	s0,16(sp)
    59ca:	6125                	addi	sp,sp,96
    59cc:	8082                	ret

00000000000059ce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    59ce:	1141                	addi	sp,sp,-16
    59d0:	e422                	sd	s0,8(sp)
    59d2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    59d4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    59d8:	00003797          	auipc	a5,0x3
    59dc:	8b87b783          	ld	a5,-1864(a5) # 8290 <freep>
    59e0:	a805                	j	5a10 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    59e2:	4618                	lw	a4,8(a2)
    59e4:	9db9                	addw	a1,a1,a4
    59e6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    59ea:	6398                	ld	a4,0(a5)
    59ec:	6318                	ld	a4,0(a4)
    59ee:	fee53823          	sd	a4,-16(a0)
    59f2:	a091                	j	5a36 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    59f4:	ff852703          	lw	a4,-8(a0)
    59f8:	9e39                	addw	a2,a2,a4
    59fa:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    59fc:	ff053703          	ld	a4,-16(a0)
    5a00:	e398                	sd	a4,0(a5)
    5a02:	a099                	j	5a48 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a04:	6398                	ld	a4,0(a5)
    5a06:	00e7e463          	bltu	a5,a4,5a0e <free+0x40>
    5a0a:	00e6ea63          	bltu	a3,a4,5a1e <free+0x50>
{
    5a0e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a10:	fed7fae3          	bgeu	a5,a3,5a04 <free+0x36>
    5a14:	6398                	ld	a4,0(a5)
    5a16:	00e6e463          	bltu	a3,a4,5a1e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a1a:	fee7eae3          	bltu	a5,a4,5a0e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5a1e:	ff852583          	lw	a1,-8(a0)
    5a22:	6390                	ld	a2,0(a5)
    5a24:	02059713          	slli	a4,a1,0x20
    5a28:	9301                	srli	a4,a4,0x20
    5a2a:	0712                	slli	a4,a4,0x4
    5a2c:	9736                	add	a4,a4,a3
    5a2e:	fae60ae3          	beq	a2,a4,59e2 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5a32:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5a36:	4790                	lw	a2,8(a5)
    5a38:	02061713          	slli	a4,a2,0x20
    5a3c:	9301                	srli	a4,a4,0x20
    5a3e:	0712                	slli	a4,a4,0x4
    5a40:	973e                	add	a4,a4,a5
    5a42:	fae689e3          	beq	a3,a4,59f4 <free+0x26>
  } else
    p->s.ptr = bp;
    5a46:	e394                	sd	a3,0(a5)
  freep = p;
    5a48:	00003717          	auipc	a4,0x3
    5a4c:	84f73423          	sd	a5,-1976(a4) # 8290 <freep>
}
    5a50:	6422                	ld	s0,8(sp)
    5a52:	0141                	addi	sp,sp,16
    5a54:	8082                	ret

0000000000005a56 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5a56:	7139                	addi	sp,sp,-64
    5a58:	fc06                	sd	ra,56(sp)
    5a5a:	f822                	sd	s0,48(sp)
    5a5c:	f426                	sd	s1,40(sp)
    5a5e:	f04a                	sd	s2,32(sp)
    5a60:	ec4e                	sd	s3,24(sp)
    5a62:	e852                	sd	s4,16(sp)
    5a64:	e456                	sd	s5,8(sp)
    5a66:	e05a                	sd	s6,0(sp)
    5a68:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5a6a:	02051493          	slli	s1,a0,0x20
    5a6e:	9081                	srli	s1,s1,0x20
    5a70:	04bd                	addi	s1,s1,15
    5a72:	8091                	srli	s1,s1,0x4
    5a74:	0014899b          	addiw	s3,s1,1
    5a78:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5a7a:	00003517          	auipc	a0,0x3
    5a7e:	81653503          	ld	a0,-2026(a0) # 8290 <freep>
    5a82:	c515                	beqz	a0,5aae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5a84:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5a86:	4798                	lw	a4,8(a5)
    5a88:	02977f63          	bgeu	a4,s1,5ac6 <malloc+0x70>
    5a8c:	8a4e                	mv	s4,s3
    5a8e:	0009871b          	sext.w	a4,s3
    5a92:	6685                	lui	a3,0x1
    5a94:	00d77363          	bgeu	a4,a3,5a9a <malloc+0x44>
    5a98:	6a05                	lui	s4,0x1
    5a9a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5a9e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5aa2:	00002917          	auipc	s2,0x2
    5aa6:	7ee90913          	addi	s2,s2,2030 # 8290 <freep>
  if(p == (char*)-1)
    5aaa:	5afd                	li	s5,-1
    5aac:	a88d                	j	5b1e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5aae:	00009797          	auipc	a5,0x9
    5ab2:	00278793          	addi	a5,a5,2 # eab0 <base>
    5ab6:	00002717          	auipc	a4,0x2
    5aba:	7cf73d23          	sd	a5,2010(a4) # 8290 <freep>
    5abe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5ac0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5ac4:	b7e1                	j	5a8c <malloc+0x36>
      if(p->s.size == nunits)
    5ac6:	02e48b63          	beq	s1,a4,5afc <malloc+0xa6>
        p->s.size -= nunits;
    5aca:	4137073b          	subw	a4,a4,s3
    5ace:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5ad0:	1702                	slli	a4,a4,0x20
    5ad2:	9301                	srli	a4,a4,0x20
    5ad4:	0712                	slli	a4,a4,0x4
    5ad6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5ad8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5adc:	00002717          	auipc	a4,0x2
    5ae0:	7aa73a23          	sd	a0,1972(a4) # 8290 <freep>
      return (void*)(p + 1);
    5ae4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5ae8:	70e2                	ld	ra,56(sp)
    5aea:	7442                	ld	s0,48(sp)
    5aec:	74a2                	ld	s1,40(sp)
    5aee:	7902                	ld	s2,32(sp)
    5af0:	69e2                	ld	s3,24(sp)
    5af2:	6a42                	ld	s4,16(sp)
    5af4:	6aa2                	ld	s5,8(sp)
    5af6:	6b02                	ld	s6,0(sp)
    5af8:	6121                	addi	sp,sp,64
    5afa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5afc:	6398                	ld	a4,0(a5)
    5afe:	e118                	sd	a4,0(a0)
    5b00:	bff1                	j	5adc <malloc+0x86>
  hp->s.size = nu;
    5b02:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5b06:	0541                	addi	a0,a0,16
    5b08:	00000097          	auipc	ra,0x0
    5b0c:	ec6080e7          	jalr	-314(ra) # 59ce <free>
  return freep;
    5b10:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5b14:	d971                	beqz	a0,5ae8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5b16:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5b18:	4798                	lw	a4,8(a5)
    5b1a:	fa9776e3          	bgeu	a4,s1,5ac6 <malloc+0x70>
    if(p == freep)
    5b1e:	00093703          	ld	a4,0(s2)
    5b22:	853e                	mv	a0,a5
    5b24:	fef719e3          	bne	a4,a5,5b16 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    5b28:	8552                	mv	a0,s4
    5b2a:	00000097          	auipc	ra,0x0
    5b2e:	b76080e7          	jalr	-1162(ra) # 56a0 <sbrk>
  if(p == (char*)-1)
    5b32:	fd5518e3          	bne	a0,s5,5b02 <malloc+0xac>
        return 0;
    5b36:	4501                	li	a0,0
    5b38:	bf45                	j	5ae8 <malloc+0x92>
