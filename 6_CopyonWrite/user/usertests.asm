
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
      14:	500080e7          	jalr	1280(ra) # 5510 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	4ee080e7          	jalr	1262(ra) # 5510 <open>
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
      42:	cc250513          	addi	a0,a0,-830 # 5d00 <malloc+0x3fa>
      46:	00006097          	auipc	ra,0x6
      4a:	802080e7          	jalr	-2046(ra) # 5848 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	480080e7          	jalr	1152(ra) # 54d0 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	1c878793          	addi	a5,a5,456 # 9220 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	8d068693          	addi	a3,a3,-1840 # b930 <buf>
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
      84:	ca050513          	addi	a0,a0,-864 # 5d20 <malloc+0x41a>
      88:	00005097          	auipc	ra,0x5
      8c:	7c0080e7          	jalr	1984(ra) # 5848 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	43e080e7          	jalr	1086(ra) # 54d0 <exit>

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
      ac:	c9050513          	addi	a0,a0,-880 # 5d38 <malloc+0x432>
      b0:	00005097          	auipc	ra,0x5
      b4:	460080e7          	jalr	1120(ra) # 5510 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	43c080e7          	jalr	1084(ra) # 54f8 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	c9250513          	addi	a0,a0,-878 # 5d58 <malloc+0x452>
      ce:	00005097          	auipc	ra,0x5
      d2:	442080e7          	jalr	1090(ra) # 5510 <open>
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
      ea:	c5a50513          	addi	a0,a0,-934 # 5d40 <malloc+0x43a>
      ee:	00005097          	auipc	ra,0x5
      f2:	75a080e7          	jalr	1882(ra) # 5848 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	3d8080e7          	jalr	984(ra) # 54d0 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	c6650513          	addi	a0,a0,-922 # 5d68 <malloc+0x462>
     10a:	00005097          	auipc	ra,0x5
     10e:	73e080e7          	jalr	1854(ra) # 5848 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	3bc080e7          	jalr	956(ra) # 54d0 <exit>

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
     130:	c6450513          	addi	a0,a0,-924 # 5d90 <malloc+0x48a>
     134:	00005097          	auipc	ra,0x5
     138:	3ec080e7          	jalr	1004(ra) # 5520 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	c5050513          	addi	a0,a0,-944 # 5d90 <malloc+0x48a>
     148:	00005097          	auipc	ra,0x5
     14c:	3c8080e7          	jalr	968(ra) # 5510 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	c4c58593          	addi	a1,a1,-948 # 5da0 <malloc+0x49a>
     15c:	00005097          	auipc	ra,0x5
     160:	394080e7          	jalr	916(ra) # 54f0 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	c2850513          	addi	a0,a0,-984 # 5d90 <malloc+0x48a>
     170:	00005097          	auipc	ra,0x5
     174:	3a0080e7          	jalr	928(ra) # 5510 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	c2c58593          	addi	a1,a1,-980 # 5da8 <malloc+0x4a2>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	36a080e7          	jalr	874(ra) # 54f0 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	bfc50513          	addi	a0,a0,-1028 # 5d90 <malloc+0x48a>
     19c:	00005097          	auipc	ra,0x5
     1a0:	384080e7          	jalr	900(ra) # 5520 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	352080e7          	jalr	850(ra) # 54f8 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	348080e7          	jalr	840(ra) # 54f8 <close>
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
     1ce:	be650513          	addi	a0,a0,-1050 # 5db0 <malloc+0x4aa>
     1d2:	00005097          	auipc	ra,0x5
     1d6:	676080e7          	jalr	1654(ra) # 5848 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	2f4080e7          	jalr	756(ra) # 54d0 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	e44e                	sd	s3,8(sp)
     1f0:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f2:	00008797          	auipc	a5,0x8
     1f6:	f1678793          	addi	a5,a5,-234 # 8108 <name>
     1fa:	06100713          	li	a4,97
     1fe:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     202:	00078123          	sb	zero,2(a5)
     206:	03000493          	li	s1,48
    name[1] = '0' + i;
     20a:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     20c:	06400993          	li	s3,100
    name[1] = '0' + i;
     210:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
     214:	20200593          	li	a1,514
     218:	854a                	mv	a0,s2
     21a:	00005097          	auipc	ra,0x5
     21e:	2f6080e7          	jalr	758(ra) # 5510 <open>
    close(fd);
     222:	00005097          	auipc	ra,0x5
     226:	2d6080e7          	jalr	726(ra) # 54f8 <close>
  for(i = 0; i < N; i++){
     22a:	2485                	addiw	s1,s1,1
     22c:	0ff4f493          	andi	s1,s1,255
     230:	ff3490e3          	bne	s1,s3,210 <createtest+0x2c>
  name[0] = 'a';
     234:	00008797          	auipc	a5,0x8
     238:	ed478793          	addi	a5,a5,-300 # 8108 <name>
     23c:	06100713          	li	a4,97
     240:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     244:	00078123          	sb	zero,2(a5)
     248:	03000493          	li	s1,48
    name[1] = '0' + i;
     24c:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     24e:	06400993          	li	s3,100
    name[1] = '0' + i;
     252:	009900a3          	sb	s1,1(s2)
    unlink(name);
     256:	854a                	mv	a0,s2
     258:	00005097          	auipc	ra,0x5
     25c:	2c8080e7          	jalr	712(ra) # 5520 <unlink>
  for(i = 0; i < N; i++){
     260:	2485                	addiw	s1,s1,1
     262:	0ff4f493          	andi	s1,s1,255
     266:	ff3496e3          	bne	s1,s3,252 <createtest+0x6e>
}
     26a:	70a2                	ld	ra,40(sp)
     26c:	7402                	ld	s0,32(sp)
     26e:	64e2                	ld	s1,24(sp)
     270:	6942                	ld	s2,16(sp)
     272:	69a2                	ld	s3,8(sp)
     274:	6145                	addi	sp,sp,48
     276:	8082                	ret

0000000000000278 <bigwrite>:
{
     278:	715d                	addi	sp,sp,-80
     27a:	e486                	sd	ra,72(sp)
     27c:	e0a2                	sd	s0,64(sp)
     27e:	fc26                	sd	s1,56(sp)
     280:	f84a                	sd	s2,48(sp)
     282:	f44e                	sd	s3,40(sp)
     284:	f052                	sd	s4,32(sp)
     286:	ec56                	sd	s5,24(sp)
     288:	e85a                	sd	s6,16(sp)
     28a:	e45e                	sd	s7,8(sp)
     28c:	0880                	addi	s0,sp,80
     28e:	8baa                	mv	s7,a0
  unlink("bigwrite");
     290:	00006517          	auipc	a0,0x6
     294:	92050513          	addi	a0,a0,-1760 # 5bb0 <malloc+0x2aa>
     298:	00005097          	auipc	ra,0x5
     29c:	288080e7          	jalr	648(ra) # 5520 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a4:	00006a97          	auipc	s5,0x6
     2a8:	90ca8a93          	addi	s5,s5,-1780 # 5bb0 <malloc+0x2aa>
      int cc = write(fd, buf, sz);
     2ac:	0000ba17          	auipc	s4,0xb
     2b0:	684a0a13          	addi	s4,s4,1668 # b930 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2b4:	6b0d                	lui	s6,0x3
     2b6:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x2a7>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ba:	20200593          	li	a1,514
     2be:	8556                	mv	a0,s5
     2c0:	00005097          	auipc	ra,0x5
     2c4:	250080e7          	jalr	592(ra) # 5510 <open>
     2c8:	892a                	mv	s2,a0
    if(fd < 0){
     2ca:	04054d63          	bltz	a0,324 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ce:	8626                	mv	a2,s1
     2d0:	85d2                	mv	a1,s4
     2d2:	00005097          	auipc	ra,0x5
     2d6:	21e080e7          	jalr	542(ra) # 54f0 <write>
     2da:	89aa                	mv	s3,a0
      if(cc != sz){
     2dc:	06a49463          	bne	s1,a0,344 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2e0:	8626                	mv	a2,s1
     2e2:	85d2                	mv	a1,s4
     2e4:	854a                	mv	a0,s2
     2e6:	00005097          	auipc	ra,0x5
     2ea:	20a080e7          	jalr	522(ra) # 54f0 <write>
      if(cc != sz){
     2ee:	04951963          	bne	a0,s1,340 <bigwrite+0xc8>
    close(fd);
     2f2:	854a                	mv	a0,s2
     2f4:	00005097          	auipc	ra,0x5
     2f8:	204080e7          	jalr	516(ra) # 54f8 <close>
    unlink("bigwrite");
     2fc:	8556                	mv	a0,s5
     2fe:	00005097          	auipc	ra,0x5
     302:	222080e7          	jalr	546(ra) # 5520 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     306:	1d74849b          	addiw	s1,s1,471
     30a:	fb6498e3          	bne	s1,s6,2ba <bigwrite+0x42>
}
     30e:	60a6                	ld	ra,72(sp)
     310:	6406                	ld	s0,64(sp)
     312:	74e2                	ld	s1,56(sp)
     314:	7942                	ld	s2,48(sp)
     316:	79a2                	ld	s3,40(sp)
     318:	7a02                	ld	s4,32(sp)
     31a:	6ae2                	ld	s5,24(sp)
     31c:	6b42                	ld	s6,16(sp)
     31e:	6ba2                	ld	s7,8(sp)
     320:	6161                	addi	sp,sp,80
     322:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     324:	85de                	mv	a1,s7
     326:	00006517          	auipc	a0,0x6
     32a:	ab250513          	addi	a0,a0,-1358 # 5dd8 <malloc+0x4d2>
     32e:	00005097          	auipc	ra,0x5
     332:	51a080e7          	jalr	1306(ra) # 5848 <printf>
      exit(1);
     336:	4505                	li	a0,1
     338:	00005097          	auipc	ra,0x5
     33c:	198080e7          	jalr	408(ra) # 54d0 <exit>
     340:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     342:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     344:	86ce                	mv	a3,s3
     346:	8626                	mv	a2,s1
     348:	85de                	mv	a1,s7
     34a:	00006517          	auipc	a0,0x6
     34e:	aae50513          	addi	a0,a0,-1362 # 5df8 <malloc+0x4f2>
     352:	00005097          	auipc	ra,0x5
     356:	4f6080e7          	jalr	1270(ra) # 5848 <printf>
        exit(1);
     35a:	4505                	li	a0,1
     35c:	00005097          	auipc	ra,0x5
     360:	174080e7          	jalr	372(ra) # 54d0 <exit>

0000000000000364 <copyin>:
{
     364:	715d                	addi	sp,sp,-80
     366:	e486                	sd	ra,72(sp)
     368:	e0a2                	sd	s0,64(sp)
     36a:	fc26                	sd	s1,56(sp)
     36c:	f84a                	sd	s2,48(sp)
     36e:	f44e                	sd	s3,40(sp)
     370:	f052                	sd	s4,32(sp)
     372:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     374:	4785                	li	a5,1
     376:	07fe                	slli	a5,a5,0x1f
     378:	fcf43023          	sd	a5,-64(s0)
     37c:	57fd                	li	a5,-1
     37e:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     382:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     386:	00006a17          	auipc	s4,0x6
     38a:	a8aa0a13          	addi	s4,s4,-1398 # 5e10 <malloc+0x50a>
    uint64 addr = addrs[ai];
     38e:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     392:	20100593          	li	a1,513
     396:	8552                	mv	a0,s4
     398:	00005097          	auipc	ra,0x5
     39c:	178080e7          	jalr	376(ra) # 5510 <open>
     3a0:	84aa                	mv	s1,a0
    if(fd < 0){
     3a2:	08054863          	bltz	a0,432 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     3a6:	6609                	lui	a2,0x2
     3a8:	85ce                	mv	a1,s3
     3aa:	00005097          	auipc	ra,0x5
     3ae:	146080e7          	jalr	326(ra) # 54f0 <write>
    if(n >= 0){
     3b2:	08055d63          	bgez	a0,44c <copyin+0xe8>
    close(fd);
     3b6:	8526                	mv	a0,s1
     3b8:	00005097          	auipc	ra,0x5
     3bc:	140080e7          	jalr	320(ra) # 54f8 <close>
    unlink("copyin1");
     3c0:	8552                	mv	a0,s4
     3c2:	00005097          	auipc	ra,0x5
     3c6:	15e080e7          	jalr	350(ra) # 5520 <unlink>
    n = write(1, (char*)addr, 8192);
     3ca:	6609                	lui	a2,0x2
     3cc:	85ce                	mv	a1,s3
     3ce:	4505                	li	a0,1
     3d0:	00005097          	auipc	ra,0x5
     3d4:	120080e7          	jalr	288(ra) # 54f0 <write>
    if(n > 0){
     3d8:	08a04963          	bgtz	a0,46a <copyin+0x106>
    if(pipe(fds) < 0){
     3dc:	fb840513          	addi	a0,s0,-72
     3e0:	00005097          	auipc	ra,0x5
     3e4:	100080e7          	jalr	256(ra) # 54e0 <pipe>
     3e8:	0a054063          	bltz	a0,488 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3ec:	6609                	lui	a2,0x2
     3ee:	85ce                	mv	a1,s3
     3f0:	fbc42503          	lw	a0,-68(s0)
     3f4:	00005097          	auipc	ra,0x5
     3f8:	0fc080e7          	jalr	252(ra) # 54f0 <write>
    if(n > 0){
     3fc:	0aa04363          	bgtz	a0,4a2 <copyin+0x13e>
    close(fds[0]);
     400:	fb842503          	lw	a0,-72(s0)
     404:	00005097          	auipc	ra,0x5
     408:	0f4080e7          	jalr	244(ra) # 54f8 <close>
    close(fds[1]);
     40c:	fbc42503          	lw	a0,-68(s0)
     410:	00005097          	auipc	ra,0x5
     414:	0e8080e7          	jalr	232(ra) # 54f8 <close>
  for(int ai = 0; ai < 2; ai++){
     418:	0921                	addi	s2,s2,8
     41a:	fd040793          	addi	a5,s0,-48
     41e:	f6f918e3          	bne	s2,a5,38e <copyin+0x2a>
}
     422:	60a6                	ld	ra,72(sp)
     424:	6406                	ld	s0,64(sp)
     426:	74e2                	ld	s1,56(sp)
     428:	7942                	ld	s2,48(sp)
     42a:	79a2                	ld	s3,40(sp)
     42c:	7a02                	ld	s4,32(sp)
     42e:	6161                	addi	sp,sp,80
     430:	8082                	ret
      printf("open(copyin1) failed\n");
     432:	00006517          	auipc	a0,0x6
     436:	9e650513          	addi	a0,a0,-1562 # 5e18 <malloc+0x512>
     43a:	00005097          	auipc	ra,0x5
     43e:	40e080e7          	jalr	1038(ra) # 5848 <printf>
      exit(1);
     442:	4505                	li	a0,1
     444:	00005097          	auipc	ra,0x5
     448:	08c080e7          	jalr	140(ra) # 54d0 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     44c:	862a                	mv	a2,a0
     44e:	85ce                	mv	a1,s3
     450:	00006517          	auipc	a0,0x6
     454:	9e050513          	addi	a0,a0,-1568 # 5e30 <malloc+0x52a>
     458:	00005097          	auipc	ra,0x5
     45c:	3f0080e7          	jalr	1008(ra) # 5848 <printf>
      exit(1);
     460:	4505                	li	a0,1
     462:	00005097          	auipc	ra,0x5
     466:	06e080e7          	jalr	110(ra) # 54d0 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     46a:	862a                	mv	a2,a0
     46c:	85ce                	mv	a1,s3
     46e:	00006517          	auipc	a0,0x6
     472:	9f250513          	addi	a0,a0,-1550 # 5e60 <malloc+0x55a>
     476:	00005097          	auipc	ra,0x5
     47a:	3d2080e7          	jalr	978(ra) # 5848 <printf>
      exit(1);
     47e:	4505                	li	a0,1
     480:	00005097          	auipc	ra,0x5
     484:	050080e7          	jalr	80(ra) # 54d0 <exit>
      printf("pipe() failed\n");
     488:	00006517          	auipc	a0,0x6
     48c:	a0850513          	addi	a0,a0,-1528 # 5e90 <malloc+0x58a>
     490:	00005097          	auipc	ra,0x5
     494:	3b8080e7          	jalr	952(ra) # 5848 <printf>
      exit(1);
     498:	4505                	li	a0,1
     49a:	00005097          	auipc	ra,0x5
     49e:	036080e7          	jalr	54(ra) # 54d0 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     4a2:	862a                	mv	a2,a0
     4a4:	85ce                	mv	a1,s3
     4a6:	00006517          	auipc	a0,0x6
     4aa:	9fa50513          	addi	a0,a0,-1542 # 5ea0 <malloc+0x59a>
     4ae:	00005097          	auipc	ra,0x5
     4b2:	39a080e7          	jalr	922(ra) # 5848 <printf>
      exit(1);
     4b6:	4505                	li	a0,1
     4b8:	00005097          	auipc	ra,0x5
     4bc:	018080e7          	jalr	24(ra) # 54d0 <exit>

00000000000004c0 <copyout>:
{
     4c0:	711d                	addi	sp,sp,-96
     4c2:	ec86                	sd	ra,88(sp)
     4c4:	e8a2                	sd	s0,80(sp)
     4c6:	e4a6                	sd	s1,72(sp)
     4c8:	e0ca                	sd	s2,64(sp)
     4ca:	fc4e                	sd	s3,56(sp)
     4cc:	f852                	sd	s4,48(sp)
     4ce:	f456                	sd	s5,40(sp)
     4d0:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4d2:	4785                	li	a5,1
     4d4:	07fe                	slli	a5,a5,0x1f
     4d6:	faf43823          	sd	a5,-80(s0)
     4da:	57fd                	li	a5,-1
     4dc:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4e0:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4e4:	00006a17          	auipc	s4,0x6
     4e8:	9eca0a13          	addi	s4,s4,-1556 # 5ed0 <malloc+0x5ca>
    n = write(fds[1], "x", 1);
     4ec:	00006a97          	auipc	s5,0x6
     4f0:	8bca8a93          	addi	s5,s5,-1860 # 5da8 <malloc+0x4a2>
    uint64 addr = addrs[ai];
     4f4:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4f8:	4581                	li	a1,0
     4fa:	8552                	mv	a0,s4
     4fc:	00005097          	auipc	ra,0x5
     500:	014080e7          	jalr	20(ra) # 5510 <open>
     504:	84aa                	mv	s1,a0
    if(fd < 0){
     506:	08054663          	bltz	a0,592 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     50a:	6609                	lui	a2,0x2
     50c:	85ce                	mv	a1,s3
     50e:	00005097          	auipc	ra,0x5
     512:	fda080e7          	jalr	-38(ra) # 54e8 <read>
    if(n > 0){
     516:	08a04b63          	bgtz	a0,5ac <copyout+0xec>
    close(fd);
     51a:	8526                	mv	a0,s1
     51c:	00005097          	auipc	ra,0x5
     520:	fdc080e7          	jalr	-36(ra) # 54f8 <close>
    if(pipe(fds) < 0){
     524:	fa840513          	addi	a0,s0,-88
     528:	00005097          	auipc	ra,0x5
     52c:	fb8080e7          	jalr	-72(ra) # 54e0 <pipe>
     530:	08054d63          	bltz	a0,5ca <copyout+0x10a>
    n = write(fds[1], "x", 1);
     534:	4605                	li	a2,1
     536:	85d6                	mv	a1,s5
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00005097          	auipc	ra,0x5
     540:	fb4080e7          	jalr	-76(ra) # 54f0 <write>
    if(n != 1){
     544:	4785                	li	a5,1
     546:	08f51f63          	bne	a0,a5,5e4 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     54a:	6609                	lui	a2,0x2
     54c:	85ce                	mv	a1,s3
     54e:	fa842503          	lw	a0,-88(s0)
     552:	00005097          	auipc	ra,0x5
     556:	f96080e7          	jalr	-106(ra) # 54e8 <read>
    if(n > 0){
     55a:	0aa04263          	bgtz	a0,5fe <copyout+0x13e>
    close(fds[0]);
     55e:	fa842503          	lw	a0,-88(s0)
     562:	00005097          	auipc	ra,0x5
     566:	f96080e7          	jalr	-106(ra) # 54f8 <close>
    close(fds[1]);
     56a:	fac42503          	lw	a0,-84(s0)
     56e:	00005097          	auipc	ra,0x5
     572:	f8a080e7          	jalr	-118(ra) # 54f8 <close>
  for(int ai = 0; ai < 2; ai++){
     576:	0921                	addi	s2,s2,8
     578:	fc040793          	addi	a5,s0,-64
     57c:	f6f91ce3          	bne	s2,a5,4f4 <copyout+0x34>
}
     580:	60e6                	ld	ra,88(sp)
     582:	6446                	ld	s0,80(sp)
     584:	64a6                	ld	s1,72(sp)
     586:	6906                	ld	s2,64(sp)
     588:	79e2                	ld	s3,56(sp)
     58a:	7a42                	ld	s4,48(sp)
     58c:	7aa2                	ld	s5,40(sp)
     58e:	6125                	addi	sp,sp,96
     590:	8082                	ret
      printf("open(README) failed\n");
     592:	00006517          	auipc	a0,0x6
     596:	94650513          	addi	a0,a0,-1722 # 5ed8 <malloc+0x5d2>
     59a:	00005097          	auipc	ra,0x5
     59e:	2ae080e7          	jalr	686(ra) # 5848 <printf>
      exit(1);
     5a2:	4505                	li	a0,1
     5a4:	00005097          	auipc	ra,0x5
     5a8:	f2c080e7          	jalr	-212(ra) # 54d0 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ac:	862a                	mv	a2,a0
     5ae:	85ce                	mv	a1,s3
     5b0:	00006517          	auipc	a0,0x6
     5b4:	94050513          	addi	a0,a0,-1728 # 5ef0 <malloc+0x5ea>
     5b8:	00005097          	auipc	ra,0x5
     5bc:	290080e7          	jalr	656(ra) # 5848 <printf>
      exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00005097          	auipc	ra,0x5
     5c6:	f0e080e7          	jalr	-242(ra) # 54d0 <exit>
      printf("pipe() failed\n");
     5ca:	00006517          	auipc	a0,0x6
     5ce:	8c650513          	addi	a0,a0,-1850 # 5e90 <malloc+0x58a>
     5d2:	00005097          	auipc	ra,0x5
     5d6:	276080e7          	jalr	630(ra) # 5848 <printf>
      exit(1);
     5da:	4505                	li	a0,1
     5dc:	00005097          	auipc	ra,0x5
     5e0:	ef4080e7          	jalr	-268(ra) # 54d0 <exit>
      printf("pipe write failed\n");
     5e4:	00006517          	auipc	a0,0x6
     5e8:	93c50513          	addi	a0,a0,-1732 # 5f20 <malloc+0x61a>
     5ec:	00005097          	auipc	ra,0x5
     5f0:	25c080e7          	jalr	604(ra) # 5848 <printf>
      exit(1);
     5f4:	4505                	li	a0,1
     5f6:	00005097          	auipc	ra,0x5
     5fa:	eda080e7          	jalr	-294(ra) # 54d0 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5fe:	862a                	mv	a2,a0
     600:	85ce                	mv	a1,s3
     602:	00006517          	auipc	a0,0x6
     606:	93650513          	addi	a0,a0,-1738 # 5f38 <malloc+0x632>
     60a:	00005097          	auipc	ra,0x5
     60e:	23e080e7          	jalr	574(ra) # 5848 <printf>
      exit(1);
     612:	4505                	li	a0,1
     614:	00005097          	auipc	ra,0x5
     618:	ebc080e7          	jalr	-324(ra) # 54d0 <exit>

000000000000061c <truncate1>:
{
     61c:	711d                	addi	sp,sp,-96
     61e:	ec86                	sd	ra,88(sp)
     620:	e8a2                	sd	s0,80(sp)
     622:	e4a6                	sd	s1,72(sp)
     624:	e0ca                	sd	s2,64(sp)
     626:	fc4e                	sd	s3,56(sp)
     628:	f852                	sd	s4,48(sp)
     62a:	f456                	sd	s5,40(sp)
     62c:	1080                	addi	s0,sp,96
     62e:	8aaa                	mv	s5,a0
  unlink("truncfile");
     630:	00005517          	auipc	a0,0x5
     634:	76050513          	addi	a0,a0,1888 # 5d90 <malloc+0x48a>
     638:	00005097          	auipc	ra,0x5
     63c:	ee8080e7          	jalr	-280(ra) # 5520 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     640:	60100593          	li	a1,1537
     644:	00005517          	auipc	a0,0x5
     648:	74c50513          	addi	a0,a0,1868 # 5d90 <malloc+0x48a>
     64c:	00005097          	auipc	ra,0x5
     650:	ec4080e7          	jalr	-316(ra) # 5510 <open>
     654:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     656:	4611                	li	a2,4
     658:	00005597          	auipc	a1,0x5
     65c:	74858593          	addi	a1,a1,1864 # 5da0 <malloc+0x49a>
     660:	00005097          	auipc	ra,0x5
     664:	e90080e7          	jalr	-368(ra) # 54f0 <write>
  close(fd1);
     668:	8526                	mv	a0,s1
     66a:	00005097          	auipc	ra,0x5
     66e:	e8e080e7          	jalr	-370(ra) # 54f8 <close>
  int fd2 = open("truncfile", O_RDONLY);
     672:	4581                	li	a1,0
     674:	00005517          	auipc	a0,0x5
     678:	71c50513          	addi	a0,a0,1820 # 5d90 <malloc+0x48a>
     67c:	00005097          	auipc	ra,0x5
     680:	e94080e7          	jalr	-364(ra) # 5510 <open>
     684:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     686:	02000613          	li	a2,32
     68a:	fa040593          	addi	a1,s0,-96
     68e:	00005097          	auipc	ra,0x5
     692:	e5a080e7          	jalr	-422(ra) # 54e8 <read>
  if(n != 4){
     696:	4791                	li	a5,4
     698:	0cf51e63          	bne	a0,a5,774 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     69c:	40100593          	li	a1,1025
     6a0:	00005517          	auipc	a0,0x5
     6a4:	6f050513          	addi	a0,a0,1776 # 5d90 <malloc+0x48a>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	e68080e7          	jalr	-408(ra) # 5510 <open>
     6b0:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6b2:	4581                	li	a1,0
     6b4:	00005517          	auipc	a0,0x5
     6b8:	6dc50513          	addi	a0,a0,1756 # 5d90 <malloc+0x48a>
     6bc:	00005097          	auipc	ra,0x5
     6c0:	e54080e7          	jalr	-428(ra) # 5510 <open>
     6c4:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	00005097          	auipc	ra,0x5
     6d2:	e1a080e7          	jalr	-486(ra) # 54e8 <read>
     6d6:	8a2a                	mv	s4,a0
  if(n != 0){
     6d8:	ed4d                	bnez	a0,792 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6da:	02000613          	li	a2,32
     6de:	fa040593          	addi	a1,s0,-96
     6e2:	8526                	mv	a0,s1
     6e4:	00005097          	auipc	ra,0x5
     6e8:	e04080e7          	jalr	-508(ra) # 54e8 <read>
     6ec:	8a2a                	mv	s4,a0
  if(n != 0){
     6ee:	e971                	bnez	a0,7c2 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6f0:	4619                	li	a2,6
     6f2:	00006597          	auipc	a1,0x6
     6f6:	8d658593          	addi	a1,a1,-1834 # 5fc8 <malloc+0x6c2>
     6fa:	854e                	mv	a0,s3
     6fc:	00005097          	auipc	ra,0x5
     700:	df4080e7          	jalr	-524(ra) # 54f0 <write>
  n = read(fd3, buf, sizeof(buf));
     704:	02000613          	li	a2,32
     708:	fa040593          	addi	a1,s0,-96
     70c:	854a                	mv	a0,s2
     70e:	00005097          	auipc	ra,0x5
     712:	dda080e7          	jalr	-550(ra) # 54e8 <read>
  if(n != 6){
     716:	4799                	li	a5,6
     718:	0cf51d63          	bne	a0,a5,7f2 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     71c:	02000613          	li	a2,32
     720:	fa040593          	addi	a1,s0,-96
     724:	8526                	mv	a0,s1
     726:	00005097          	auipc	ra,0x5
     72a:	dc2080e7          	jalr	-574(ra) # 54e8 <read>
  if(n != 2){
     72e:	4789                	li	a5,2
     730:	0ef51063          	bne	a0,a5,810 <truncate1+0x1f4>
  unlink("truncfile");
     734:	00005517          	auipc	a0,0x5
     738:	65c50513          	addi	a0,a0,1628 # 5d90 <malloc+0x48a>
     73c:	00005097          	auipc	ra,0x5
     740:	de4080e7          	jalr	-540(ra) # 5520 <unlink>
  close(fd1);
     744:	854e                	mv	a0,s3
     746:	00005097          	auipc	ra,0x5
     74a:	db2080e7          	jalr	-590(ra) # 54f8 <close>
  close(fd2);
     74e:	8526                	mv	a0,s1
     750:	00005097          	auipc	ra,0x5
     754:	da8080e7          	jalr	-600(ra) # 54f8 <close>
  close(fd3);
     758:	854a                	mv	a0,s2
     75a:	00005097          	auipc	ra,0x5
     75e:	d9e080e7          	jalr	-610(ra) # 54f8 <close>
}
     762:	60e6                	ld	ra,88(sp)
     764:	6446                	ld	s0,80(sp)
     766:	64a6                	ld	s1,72(sp)
     768:	6906                	ld	s2,64(sp)
     76a:	79e2                	ld	s3,56(sp)
     76c:	7a42                	ld	s4,48(sp)
     76e:	7aa2                	ld	s5,40(sp)
     770:	6125                	addi	sp,sp,96
     772:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     774:	862a                	mv	a2,a0
     776:	85d6                	mv	a1,s5
     778:	00005517          	auipc	a0,0x5
     77c:	7f050513          	addi	a0,a0,2032 # 5f68 <malloc+0x662>
     780:	00005097          	auipc	ra,0x5
     784:	0c8080e7          	jalr	200(ra) # 5848 <printf>
    exit(1);
     788:	4505                	li	a0,1
     78a:	00005097          	auipc	ra,0x5
     78e:	d46080e7          	jalr	-698(ra) # 54d0 <exit>
    printf("aaa fd3=%d\n", fd3);
     792:	85ca                	mv	a1,s2
     794:	00005517          	auipc	a0,0x5
     798:	7f450513          	addi	a0,a0,2036 # 5f88 <malloc+0x682>
     79c:	00005097          	auipc	ra,0x5
     7a0:	0ac080e7          	jalr	172(ra) # 5848 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7a4:	8652                	mv	a2,s4
     7a6:	85d6                	mv	a1,s5
     7a8:	00005517          	auipc	a0,0x5
     7ac:	7f050513          	addi	a0,a0,2032 # 5f98 <malloc+0x692>
     7b0:	00005097          	auipc	ra,0x5
     7b4:	098080e7          	jalr	152(ra) # 5848 <printf>
    exit(1);
     7b8:	4505                	li	a0,1
     7ba:	00005097          	auipc	ra,0x5
     7be:	d16080e7          	jalr	-746(ra) # 54d0 <exit>
    printf("bbb fd2=%d\n", fd2);
     7c2:	85a6                	mv	a1,s1
     7c4:	00005517          	auipc	a0,0x5
     7c8:	7f450513          	addi	a0,a0,2036 # 5fb8 <malloc+0x6b2>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	07c080e7          	jalr	124(ra) # 5848 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7d4:	8652                	mv	a2,s4
     7d6:	85d6                	mv	a1,s5
     7d8:	00005517          	auipc	a0,0x5
     7dc:	7c050513          	addi	a0,a0,1984 # 5f98 <malloc+0x692>
     7e0:	00005097          	auipc	ra,0x5
     7e4:	068080e7          	jalr	104(ra) # 5848 <printf>
    exit(1);
     7e8:	4505                	li	a0,1
     7ea:	00005097          	auipc	ra,0x5
     7ee:	ce6080e7          	jalr	-794(ra) # 54d0 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7f2:	862a                	mv	a2,a0
     7f4:	85d6                	mv	a1,s5
     7f6:	00005517          	auipc	a0,0x5
     7fa:	7da50513          	addi	a0,a0,2010 # 5fd0 <malloc+0x6ca>
     7fe:	00005097          	auipc	ra,0x5
     802:	04a080e7          	jalr	74(ra) # 5848 <printf>
    exit(1);
     806:	4505                	li	a0,1
     808:	00005097          	auipc	ra,0x5
     80c:	cc8080e7          	jalr	-824(ra) # 54d0 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     810:	862a                	mv	a2,a0
     812:	85d6                	mv	a1,s5
     814:	00005517          	auipc	a0,0x5
     818:	7dc50513          	addi	a0,a0,2012 # 5ff0 <malloc+0x6ea>
     81c:	00005097          	auipc	ra,0x5
     820:	02c080e7          	jalr	44(ra) # 5848 <printf>
    exit(1);
     824:	4505                	li	a0,1
     826:	00005097          	auipc	ra,0x5
     82a:	caa080e7          	jalr	-854(ra) # 54d0 <exit>

000000000000082e <writetest>:
{
     82e:	7139                	addi	sp,sp,-64
     830:	fc06                	sd	ra,56(sp)
     832:	f822                	sd	s0,48(sp)
     834:	f426                	sd	s1,40(sp)
     836:	f04a                	sd	s2,32(sp)
     838:	ec4e                	sd	s3,24(sp)
     83a:	e852                	sd	s4,16(sp)
     83c:	e456                	sd	s5,8(sp)
     83e:	e05a                	sd	s6,0(sp)
     840:	0080                	addi	s0,sp,64
     842:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     844:	20200593          	li	a1,514
     848:	00005517          	auipc	a0,0x5
     84c:	7c850513          	addi	a0,a0,1992 # 6010 <malloc+0x70a>
     850:	00005097          	auipc	ra,0x5
     854:	cc0080e7          	jalr	-832(ra) # 5510 <open>
  if(fd < 0){
     858:	0a054d63          	bltz	a0,912 <writetest+0xe4>
     85c:	892a                	mv	s2,a0
     85e:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	00005997          	auipc	s3,0x5
     864:	7d898993          	addi	s3,s3,2008 # 6038 <malloc+0x732>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     868:	00006a97          	auipc	s5,0x6
     86c:	808a8a93          	addi	s5,s5,-2040 # 6070 <malloc+0x76a>
  for(i = 0; i < N; i++){
     870:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85ce                	mv	a1,s3
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	c76080e7          	jalr	-906(ra) # 54f0 <write>
     882:	47a9                	li	a5,10
     884:	0af51563          	bne	a0,a5,92e <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     888:	4629                	li	a2,10
     88a:	85d6                	mv	a1,s5
     88c:	854a                	mv	a0,s2
     88e:	00005097          	auipc	ra,0x5
     892:	c62080e7          	jalr	-926(ra) # 54f0 <write>
     896:	47a9                	li	a5,10
     898:	0af51a63          	bne	a0,a5,94c <writetest+0x11e>
  for(i = 0; i < N; i++){
     89c:	2485                	addiw	s1,s1,1
     89e:	fd449be3          	bne	s1,s4,874 <writetest+0x46>
  close(fd);
     8a2:	854a                	mv	a0,s2
     8a4:	00005097          	auipc	ra,0x5
     8a8:	c54080e7          	jalr	-940(ra) # 54f8 <close>
  fd = open("small", O_RDONLY);
     8ac:	4581                	li	a1,0
     8ae:	00005517          	auipc	a0,0x5
     8b2:	76250513          	addi	a0,a0,1890 # 6010 <malloc+0x70a>
     8b6:	00005097          	auipc	ra,0x5
     8ba:	c5a080e7          	jalr	-934(ra) # 5510 <open>
     8be:	84aa                	mv	s1,a0
  if(fd < 0){
     8c0:	0a054563          	bltz	a0,96a <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8c4:	7d000613          	li	a2,2000
     8c8:	0000b597          	auipc	a1,0xb
     8cc:	06858593          	addi	a1,a1,104 # b930 <buf>
     8d0:	00005097          	auipc	ra,0x5
     8d4:	c18080e7          	jalr	-1000(ra) # 54e8 <read>
  if(i != N*SZ*2){
     8d8:	7d000793          	li	a5,2000
     8dc:	0af51563          	bne	a0,a5,986 <writetest+0x158>
  close(fd);
     8e0:	8526                	mv	a0,s1
     8e2:	00005097          	auipc	ra,0x5
     8e6:	c16080e7          	jalr	-1002(ra) # 54f8 <close>
  if(unlink("small") < 0){
     8ea:	00005517          	auipc	a0,0x5
     8ee:	72650513          	addi	a0,a0,1830 # 6010 <malloc+0x70a>
     8f2:	00005097          	auipc	ra,0x5
     8f6:	c2e080e7          	jalr	-978(ra) # 5520 <unlink>
     8fa:	0a054463          	bltz	a0,9a2 <writetest+0x174>
}
     8fe:	70e2                	ld	ra,56(sp)
     900:	7442                	ld	s0,48(sp)
     902:	74a2                	ld	s1,40(sp)
     904:	7902                	ld	s2,32(sp)
     906:	69e2                	ld	s3,24(sp)
     908:	6a42                	ld	s4,16(sp)
     90a:	6aa2                	ld	s5,8(sp)
     90c:	6b02                	ld	s6,0(sp)
     90e:	6121                	addi	sp,sp,64
     910:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     912:	85da                	mv	a1,s6
     914:	00005517          	auipc	a0,0x5
     918:	70450513          	addi	a0,a0,1796 # 6018 <malloc+0x712>
     91c:	00005097          	auipc	ra,0x5
     920:	f2c080e7          	jalr	-212(ra) # 5848 <printf>
    exit(1);
     924:	4505                	li	a0,1
     926:	00005097          	auipc	ra,0x5
     92a:	baa080e7          	jalr	-1110(ra) # 54d0 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     92e:	8626                	mv	a2,s1
     930:	85da                	mv	a1,s6
     932:	00005517          	auipc	a0,0x5
     936:	71650513          	addi	a0,a0,1814 # 6048 <malloc+0x742>
     93a:	00005097          	auipc	ra,0x5
     93e:	f0e080e7          	jalr	-242(ra) # 5848 <printf>
      exit(1);
     942:	4505                	li	a0,1
     944:	00005097          	auipc	ra,0x5
     948:	b8c080e7          	jalr	-1140(ra) # 54d0 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     94c:	8626                	mv	a2,s1
     94e:	85da                	mv	a1,s6
     950:	00005517          	auipc	a0,0x5
     954:	73050513          	addi	a0,a0,1840 # 6080 <malloc+0x77a>
     958:	00005097          	auipc	ra,0x5
     95c:	ef0080e7          	jalr	-272(ra) # 5848 <printf>
      exit(1);
     960:	4505                	li	a0,1
     962:	00005097          	auipc	ra,0x5
     966:	b6e080e7          	jalr	-1170(ra) # 54d0 <exit>
    printf("%s: error: open small failed!\n", s);
     96a:	85da                	mv	a1,s6
     96c:	00005517          	auipc	a0,0x5
     970:	73c50513          	addi	a0,a0,1852 # 60a8 <malloc+0x7a2>
     974:	00005097          	auipc	ra,0x5
     978:	ed4080e7          	jalr	-300(ra) # 5848 <printf>
    exit(1);
     97c:	4505                	li	a0,1
     97e:	00005097          	auipc	ra,0x5
     982:	b52080e7          	jalr	-1198(ra) # 54d0 <exit>
    printf("%s: read failed\n", s);
     986:	85da                	mv	a1,s6
     988:	00005517          	auipc	a0,0x5
     98c:	74050513          	addi	a0,a0,1856 # 60c8 <malloc+0x7c2>
     990:	00005097          	auipc	ra,0x5
     994:	eb8080e7          	jalr	-328(ra) # 5848 <printf>
    exit(1);
     998:	4505                	li	a0,1
     99a:	00005097          	auipc	ra,0x5
     99e:	b36080e7          	jalr	-1226(ra) # 54d0 <exit>
    printf("%s: unlink small failed\n", s);
     9a2:	85da                	mv	a1,s6
     9a4:	00005517          	auipc	a0,0x5
     9a8:	73c50513          	addi	a0,a0,1852 # 60e0 <malloc+0x7da>
     9ac:	00005097          	auipc	ra,0x5
     9b0:	e9c080e7          	jalr	-356(ra) # 5848 <printf>
    exit(1);
     9b4:	4505                	li	a0,1
     9b6:	00005097          	auipc	ra,0x5
     9ba:	b1a080e7          	jalr	-1254(ra) # 54d0 <exit>

00000000000009be <writebig>:
{
     9be:	7139                	addi	sp,sp,-64
     9c0:	fc06                	sd	ra,56(sp)
     9c2:	f822                	sd	s0,48(sp)
     9c4:	f426                	sd	s1,40(sp)
     9c6:	f04a                	sd	s2,32(sp)
     9c8:	ec4e                	sd	s3,24(sp)
     9ca:	e852                	sd	s4,16(sp)
     9cc:	e456                	sd	s5,8(sp)
     9ce:	0080                	addi	s0,sp,64
     9d0:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d2:	20200593          	li	a1,514
     9d6:	00005517          	auipc	a0,0x5
     9da:	72a50513          	addi	a0,a0,1834 # 6100 <malloc+0x7fa>
     9de:	00005097          	auipc	ra,0x5
     9e2:	b32080e7          	jalr	-1230(ra) # 5510 <open>
     9e6:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e8:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9ea:	0000b917          	auipc	s2,0xb
     9ee:	f4690913          	addi	s2,s2,-186 # b930 <buf>
  for(i = 0; i < MAXFILE; i++){
     9f2:	10c00a13          	li	s4,268
  if(fd < 0){
     9f6:	06054c63          	bltz	a0,a6e <writebig+0xb0>
    ((int*)buf)[0] = i;
     9fa:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fe:	40000613          	li	a2,1024
     a02:	85ca                	mv	a1,s2
     a04:	854e                	mv	a0,s3
     a06:	00005097          	auipc	ra,0x5
     a0a:	aea080e7          	jalr	-1302(ra) # 54f0 <write>
     a0e:	40000793          	li	a5,1024
     a12:	06f51c63          	bne	a0,a5,a8a <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a16:	2485                	addiw	s1,s1,1
     a18:	ff4491e3          	bne	s1,s4,9fa <writebig+0x3c>
  close(fd);
     a1c:	854e                	mv	a0,s3
     a1e:	00005097          	auipc	ra,0x5
     a22:	ada080e7          	jalr	-1318(ra) # 54f8 <close>
  fd = open("big", O_RDONLY);
     a26:	4581                	li	a1,0
     a28:	00005517          	auipc	a0,0x5
     a2c:	6d850513          	addi	a0,a0,1752 # 6100 <malloc+0x7fa>
     a30:	00005097          	auipc	ra,0x5
     a34:	ae0080e7          	jalr	-1312(ra) # 5510 <open>
     a38:	89aa                	mv	s3,a0
  n = 0;
     a3a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a3c:	0000b917          	auipc	s2,0xb
     a40:	ef490913          	addi	s2,s2,-268 # b930 <buf>
  if(fd < 0){
     a44:	06054263          	bltz	a0,aa8 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a48:	40000613          	li	a2,1024
     a4c:	85ca                	mv	a1,s2
     a4e:	854e                	mv	a0,s3
     a50:	00005097          	auipc	ra,0x5
     a54:	a98080e7          	jalr	-1384(ra) # 54e8 <read>
    if(i == 0){
     a58:	c535                	beqz	a0,ac4 <writebig+0x106>
    } else if(i != BSIZE){
     a5a:	40000793          	li	a5,1024
     a5e:	0af51f63          	bne	a0,a5,b1c <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a62:	00092683          	lw	a3,0(s2)
     a66:	0c969a63          	bne	a3,s1,b3a <writebig+0x17c>
    n++;
     a6a:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a6c:	bff1                	j	a48 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a6e:	85d6                	mv	a1,s5
     a70:	00005517          	auipc	a0,0x5
     a74:	69850513          	addi	a0,a0,1688 # 6108 <malloc+0x802>
     a78:	00005097          	auipc	ra,0x5
     a7c:	dd0080e7          	jalr	-560(ra) # 5848 <printf>
    exit(1);
     a80:	4505                	li	a0,1
     a82:	00005097          	auipc	ra,0x5
     a86:	a4e080e7          	jalr	-1458(ra) # 54d0 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a8a:	8626                	mv	a2,s1
     a8c:	85d6                	mv	a1,s5
     a8e:	00005517          	auipc	a0,0x5
     a92:	69a50513          	addi	a0,a0,1690 # 6128 <malloc+0x822>
     a96:	00005097          	auipc	ra,0x5
     a9a:	db2080e7          	jalr	-590(ra) # 5848 <printf>
      exit(1);
     a9e:	4505                	li	a0,1
     aa0:	00005097          	auipc	ra,0x5
     aa4:	a30080e7          	jalr	-1488(ra) # 54d0 <exit>
    printf("%s: error: open big failed!\n", s);
     aa8:	85d6                	mv	a1,s5
     aaa:	00005517          	auipc	a0,0x5
     aae:	6a650513          	addi	a0,a0,1702 # 6150 <malloc+0x84a>
     ab2:	00005097          	auipc	ra,0x5
     ab6:	d96080e7          	jalr	-618(ra) # 5848 <printf>
    exit(1);
     aba:	4505                	li	a0,1
     abc:	00005097          	auipc	ra,0x5
     ac0:	a14080e7          	jalr	-1516(ra) # 54d0 <exit>
      if(n == MAXFILE - 1){
     ac4:	10b00793          	li	a5,267
     ac8:	02f48a63          	beq	s1,a5,afc <writebig+0x13e>
  close(fd);
     acc:	854e                	mv	a0,s3
     ace:	00005097          	auipc	ra,0x5
     ad2:	a2a080e7          	jalr	-1494(ra) # 54f8 <close>
  if(unlink("big") < 0){
     ad6:	00005517          	auipc	a0,0x5
     ada:	62a50513          	addi	a0,a0,1578 # 6100 <malloc+0x7fa>
     ade:	00005097          	auipc	ra,0x5
     ae2:	a42080e7          	jalr	-1470(ra) # 5520 <unlink>
     ae6:	06054963          	bltz	a0,b58 <writebig+0x19a>
}
     aea:	70e2                	ld	ra,56(sp)
     aec:	7442                	ld	s0,48(sp)
     aee:	74a2                	ld	s1,40(sp)
     af0:	7902                	ld	s2,32(sp)
     af2:	69e2                	ld	s3,24(sp)
     af4:	6a42                	ld	s4,16(sp)
     af6:	6aa2                	ld	s5,8(sp)
     af8:	6121                	addi	sp,sp,64
     afa:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     afc:	10b00613          	li	a2,267
     b00:	85d6                	mv	a1,s5
     b02:	00005517          	auipc	a0,0x5
     b06:	66e50513          	addi	a0,a0,1646 # 6170 <malloc+0x86a>
     b0a:	00005097          	auipc	ra,0x5
     b0e:	d3e080e7          	jalr	-706(ra) # 5848 <printf>
        exit(1);
     b12:	4505                	li	a0,1
     b14:	00005097          	auipc	ra,0x5
     b18:	9bc080e7          	jalr	-1604(ra) # 54d0 <exit>
      printf("%s: read failed %d\n", s, i);
     b1c:	862a                	mv	a2,a0
     b1e:	85d6                	mv	a1,s5
     b20:	00005517          	auipc	a0,0x5
     b24:	67850513          	addi	a0,a0,1656 # 6198 <malloc+0x892>
     b28:	00005097          	auipc	ra,0x5
     b2c:	d20080e7          	jalr	-736(ra) # 5848 <printf>
      exit(1);
     b30:	4505                	li	a0,1
     b32:	00005097          	auipc	ra,0x5
     b36:	99e080e7          	jalr	-1634(ra) # 54d0 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b3a:	8626                	mv	a2,s1
     b3c:	85d6                	mv	a1,s5
     b3e:	00005517          	auipc	a0,0x5
     b42:	67250513          	addi	a0,a0,1650 # 61b0 <malloc+0x8aa>
     b46:	00005097          	auipc	ra,0x5
     b4a:	d02080e7          	jalr	-766(ra) # 5848 <printf>
      exit(1);
     b4e:	4505                	li	a0,1
     b50:	00005097          	auipc	ra,0x5
     b54:	980080e7          	jalr	-1664(ra) # 54d0 <exit>
    printf("%s: unlink big failed\n", s);
     b58:	85d6                	mv	a1,s5
     b5a:	00005517          	auipc	a0,0x5
     b5e:	67e50513          	addi	a0,a0,1662 # 61d8 <malloc+0x8d2>
     b62:	00005097          	auipc	ra,0x5
     b66:	ce6080e7          	jalr	-794(ra) # 5848 <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00005097          	auipc	ra,0x5
     b70:	964080e7          	jalr	-1692(ra) # 54d0 <exit>

0000000000000b74 <unlinkread>:
{
     b74:	7179                	addi	sp,sp,-48
     b76:	f406                	sd	ra,40(sp)
     b78:	f022                	sd	s0,32(sp)
     b7a:	ec26                	sd	s1,24(sp)
     b7c:	e84a                	sd	s2,16(sp)
     b7e:	e44e                	sd	s3,8(sp)
     b80:	1800                	addi	s0,sp,48
     b82:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b84:	20200593          	li	a1,514
     b88:	00005517          	auipc	a0,0x5
     b8c:	fb850513          	addi	a0,a0,-72 # 5b40 <malloc+0x23a>
     b90:	00005097          	auipc	ra,0x5
     b94:	980080e7          	jalr	-1664(ra) # 5510 <open>
  if(fd < 0){
     b98:	0e054563          	bltz	a0,c82 <unlinkread+0x10e>
     b9c:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b9e:	4615                	li	a2,5
     ba0:	00005597          	auipc	a1,0x5
     ba4:	67058593          	addi	a1,a1,1648 # 6210 <malloc+0x90a>
     ba8:	00005097          	auipc	ra,0x5
     bac:	948080e7          	jalr	-1720(ra) # 54f0 <write>
  close(fd);
     bb0:	8526                	mv	a0,s1
     bb2:	00005097          	auipc	ra,0x5
     bb6:	946080e7          	jalr	-1722(ra) # 54f8 <close>
  fd = open("unlinkread", O_RDWR);
     bba:	4589                	li	a1,2
     bbc:	00005517          	auipc	a0,0x5
     bc0:	f8450513          	addi	a0,a0,-124 # 5b40 <malloc+0x23a>
     bc4:	00005097          	auipc	ra,0x5
     bc8:	94c080e7          	jalr	-1716(ra) # 5510 <open>
     bcc:	84aa                	mv	s1,a0
  if(fd < 0){
     bce:	0c054863          	bltz	a0,c9e <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bd2:	00005517          	auipc	a0,0x5
     bd6:	f6e50513          	addi	a0,a0,-146 # 5b40 <malloc+0x23a>
     bda:	00005097          	auipc	ra,0x5
     bde:	946080e7          	jalr	-1722(ra) # 5520 <unlink>
     be2:	ed61                	bnez	a0,cba <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     be4:	20200593          	li	a1,514
     be8:	00005517          	auipc	a0,0x5
     bec:	f5850513          	addi	a0,a0,-168 # 5b40 <malloc+0x23a>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	920080e7          	jalr	-1760(ra) # 5510 <open>
     bf8:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     bfa:	460d                	li	a2,3
     bfc:	00005597          	auipc	a1,0x5
     c00:	65c58593          	addi	a1,a1,1628 # 6258 <malloc+0x952>
     c04:	00005097          	auipc	ra,0x5
     c08:	8ec080e7          	jalr	-1812(ra) # 54f0 <write>
  close(fd1);
     c0c:	854a                	mv	a0,s2
     c0e:	00005097          	auipc	ra,0x5
     c12:	8ea080e7          	jalr	-1814(ra) # 54f8 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c16:	660d                	lui	a2,0x3
     c18:	0000b597          	auipc	a1,0xb
     c1c:	d1858593          	addi	a1,a1,-744 # b930 <buf>
     c20:	8526                	mv	a0,s1
     c22:	00005097          	auipc	ra,0x5
     c26:	8c6080e7          	jalr	-1850(ra) # 54e8 <read>
     c2a:	4795                	li	a5,5
     c2c:	0af51563          	bne	a0,a5,cd6 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c30:	0000b717          	auipc	a4,0xb
     c34:	d0074703          	lbu	a4,-768(a4) # b930 <buf>
     c38:	06800793          	li	a5,104
     c3c:	0af71b63          	bne	a4,a5,cf2 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c40:	4629                	li	a2,10
     c42:	0000b597          	auipc	a1,0xb
     c46:	cee58593          	addi	a1,a1,-786 # b930 <buf>
     c4a:	8526                	mv	a0,s1
     c4c:	00005097          	auipc	ra,0x5
     c50:	8a4080e7          	jalr	-1884(ra) # 54f0 <write>
     c54:	47a9                	li	a5,10
     c56:	0af51c63          	bne	a0,a5,d0e <unlinkread+0x19a>
  close(fd);
     c5a:	8526                	mv	a0,s1
     c5c:	00005097          	auipc	ra,0x5
     c60:	89c080e7          	jalr	-1892(ra) # 54f8 <close>
  unlink("unlinkread");
     c64:	00005517          	auipc	a0,0x5
     c68:	edc50513          	addi	a0,a0,-292 # 5b40 <malloc+0x23a>
     c6c:	00005097          	auipc	ra,0x5
     c70:	8b4080e7          	jalr	-1868(ra) # 5520 <unlink>
}
     c74:	70a2                	ld	ra,40(sp)
     c76:	7402                	ld	s0,32(sp)
     c78:	64e2                	ld	s1,24(sp)
     c7a:	6942                	ld	s2,16(sp)
     c7c:	69a2                	ld	s3,8(sp)
     c7e:	6145                	addi	sp,sp,48
     c80:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c82:	85ce                	mv	a1,s3
     c84:	00005517          	auipc	a0,0x5
     c88:	56c50513          	addi	a0,a0,1388 # 61f0 <malloc+0x8ea>
     c8c:	00005097          	auipc	ra,0x5
     c90:	bbc080e7          	jalr	-1092(ra) # 5848 <printf>
    exit(1);
     c94:	4505                	li	a0,1
     c96:	00005097          	auipc	ra,0x5
     c9a:	83a080e7          	jalr	-1990(ra) # 54d0 <exit>
    printf("%s: open unlinkread failed\n", s);
     c9e:	85ce                	mv	a1,s3
     ca0:	00005517          	auipc	a0,0x5
     ca4:	57850513          	addi	a0,a0,1400 # 6218 <malloc+0x912>
     ca8:	00005097          	auipc	ra,0x5
     cac:	ba0080e7          	jalr	-1120(ra) # 5848 <printf>
    exit(1);
     cb0:	4505                	li	a0,1
     cb2:	00005097          	auipc	ra,0x5
     cb6:	81e080e7          	jalr	-2018(ra) # 54d0 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cba:	85ce                	mv	a1,s3
     cbc:	00005517          	auipc	a0,0x5
     cc0:	57c50513          	addi	a0,a0,1404 # 6238 <malloc+0x932>
     cc4:	00005097          	auipc	ra,0x5
     cc8:	b84080e7          	jalr	-1148(ra) # 5848 <printf>
    exit(1);
     ccc:	4505                	li	a0,1
     cce:	00005097          	auipc	ra,0x5
     cd2:	802080e7          	jalr	-2046(ra) # 54d0 <exit>
    printf("%s: unlinkread read failed", s);
     cd6:	85ce                	mv	a1,s3
     cd8:	00005517          	auipc	a0,0x5
     cdc:	58850513          	addi	a0,a0,1416 # 6260 <malloc+0x95a>
     ce0:	00005097          	auipc	ra,0x5
     ce4:	b68080e7          	jalr	-1176(ra) # 5848 <printf>
    exit(1);
     ce8:	4505                	li	a0,1
     cea:	00004097          	auipc	ra,0x4
     cee:	7e6080e7          	jalr	2022(ra) # 54d0 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cf2:	85ce                	mv	a1,s3
     cf4:	00005517          	auipc	a0,0x5
     cf8:	58c50513          	addi	a0,a0,1420 # 6280 <malloc+0x97a>
     cfc:	00005097          	auipc	ra,0x5
     d00:	b4c080e7          	jalr	-1204(ra) # 5848 <printf>
    exit(1);
     d04:	4505                	li	a0,1
     d06:	00004097          	auipc	ra,0x4
     d0a:	7ca080e7          	jalr	1994(ra) # 54d0 <exit>
    printf("%s: unlinkread write failed\n", s);
     d0e:	85ce                	mv	a1,s3
     d10:	00005517          	auipc	a0,0x5
     d14:	59050513          	addi	a0,a0,1424 # 62a0 <malloc+0x99a>
     d18:	00005097          	auipc	ra,0x5
     d1c:	b30080e7          	jalr	-1232(ra) # 5848 <printf>
    exit(1);
     d20:	4505                	li	a0,1
     d22:	00004097          	auipc	ra,0x4
     d26:	7ae080e7          	jalr	1966(ra) # 54d0 <exit>

0000000000000d2a <linktest>:
{
     d2a:	1101                	addi	sp,sp,-32
     d2c:	ec06                	sd	ra,24(sp)
     d2e:	e822                	sd	s0,16(sp)
     d30:	e426                	sd	s1,8(sp)
     d32:	e04a                	sd	s2,0(sp)
     d34:	1000                	addi	s0,sp,32
     d36:	892a                	mv	s2,a0
  unlink("lf1");
     d38:	00005517          	auipc	a0,0x5
     d3c:	58850513          	addi	a0,a0,1416 # 62c0 <malloc+0x9ba>
     d40:	00004097          	auipc	ra,0x4
     d44:	7e0080e7          	jalr	2016(ra) # 5520 <unlink>
  unlink("lf2");
     d48:	00005517          	auipc	a0,0x5
     d4c:	58050513          	addi	a0,a0,1408 # 62c8 <malloc+0x9c2>
     d50:	00004097          	auipc	ra,0x4
     d54:	7d0080e7          	jalr	2000(ra) # 5520 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d58:	20200593          	li	a1,514
     d5c:	00005517          	auipc	a0,0x5
     d60:	56450513          	addi	a0,a0,1380 # 62c0 <malloc+0x9ba>
     d64:	00004097          	auipc	ra,0x4
     d68:	7ac080e7          	jalr	1964(ra) # 5510 <open>
  if(fd < 0){
     d6c:	10054763          	bltz	a0,e7a <linktest+0x150>
     d70:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d72:	4615                	li	a2,5
     d74:	00005597          	auipc	a1,0x5
     d78:	49c58593          	addi	a1,a1,1180 # 6210 <malloc+0x90a>
     d7c:	00004097          	auipc	ra,0x4
     d80:	774080e7          	jalr	1908(ra) # 54f0 <write>
     d84:	4795                	li	a5,5
     d86:	10f51863          	bne	a0,a5,e96 <linktest+0x16c>
  close(fd);
     d8a:	8526                	mv	a0,s1
     d8c:	00004097          	auipc	ra,0x4
     d90:	76c080e7          	jalr	1900(ra) # 54f8 <close>
  if(link("lf1", "lf2") < 0){
     d94:	00005597          	auipc	a1,0x5
     d98:	53458593          	addi	a1,a1,1332 # 62c8 <malloc+0x9c2>
     d9c:	00005517          	auipc	a0,0x5
     da0:	52450513          	addi	a0,a0,1316 # 62c0 <malloc+0x9ba>
     da4:	00004097          	auipc	ra,0x4
     da8:	78c080e7          	jalr	1932(ra) # 5530 <link>
     dac:	10054363          	bltz	a0,eb2 <linktest+0x188>
  unlink("lf1");
     db0:	00005517          	auipc	a0,0x5
     db4:	51050513          	addi	a0,a0,1296 # 62c0 <malloc+0x9ba>
     db8:	00004097          	auipc	ra,0x4
     dbc:	768080e7          	jalr	1896(ra) # 5520 <unlink>
  if(open("lf1", 0) >= 0){
     dc0:	4581                	li	a1,0
     dc2:	00005517          	auipc	a0,0x5
     dc6:	4fe50513          	addi	a0,a0,1278 # 62c0 <malloc+0x9ba>
     dca:	00004097          	auipc	ra,0x4
     dce:	746080e7          	jalr	1862(ra) # 5510 <open>
     dd2:	0e055e63          	bgez	a0,ece <linktest+0x1a4>
  fd = open("lf2", 0);
     dd6:	4581                	li	a1,0
     dd8:	00005517          	auipc	a0,0x5
     ddc:	4f050513          	addi	a0,a0,1264 # 62c8 <malloc+0x9c2>
     de0:	00004097          	auipc	ra,0x4
     de4:	730080e7          	jalr	1840(ra) # 5510 <open>
     de8:	84aa                	mv	s1,a0
  if(fd < 0){
     dea:	10054063          	bltz	a0,eea <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dee:	660d                	lui	a2,0x3
     df0:	0000b597          	auipc	a1,0xb
     df4:	b4058593          	addi	a1,a1,-1216 # b930 <buf>
     df8:	00004097          	auipc	ra,0x4
     dfc:	6f0080e7          	jalr	1776(ra) # 54e8 <read>
     e00:	4795                	li	a5,5
     e02:	10f51263          	bne	a0,a5,f06 <linktest+0x1dc>
  close(fd);
     e06:	8526                	mv	a0,s1
     e08:	00004097          	auipc	ra,0x4
     e0c:	6f0080e7          	jalr	1776(ra) # 54f8 <close>
  if(link("lf2", "lf2") >= 0){
     e10:	00005597          	auipc	a1,0x5
     e14:	4b858593          	addi	a1,a1,1208 # 62c8 <malloc+0x9c2>
     e18:	852e                	mv	a0,a1
     e1a:	00004097          	auipc	ra,0x4
     e1e:	716080e7          	jalr	1814(ra) # 5530 <link>
     e22:	10055063          	bgez	a0,f22 <linktest+0x1f8>
  unlink("lf2");
     e26:	00005517          	auipc	a0,0x5
     e2a:	4a250513          	addi	a0,a0,1186 # 62c8 <malloc+0x9c2>
     e2e:	00004097          	auipc	ra,0x4
     e32:	6f2080e7          	jalr	1778(ra) # 5520 <unlink>
  if(link("lf2", "lf1") >= 0){
     e36:	00005597          	auipc	a1,0x5
     e3a:	48a58593          	addi	a1,a1,1162 # 62c0 <malloc+0x9ba>
     e3e:	00005517          	auipc	a0,0x5
     e42:	48a50513          	addi	a0,a0,1162 # 62c8 <malloc+0x9c2>
     e46:	00004097          	auipc	ra,0x4
     e4a:	6ea080e7          	jalr	1770(ra) # 5530 <link>
     e4e:	0e055863          	bgez	a0,f3e <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e52:	00005597          	auipc	a1,0x5
     e56:	46e58593          	addi	a1,a1,1134 # 62c0 <malloc+0x9ba>
     e5a:	00005517          	auipc	a0,0x5
     e5e:	57650513          	addi	a0,a0,1398 # 63d0 <malloc+0xaca>
     e62:	00004097          	auipc	ra,0x4
     e66:	6ce080e7          	jalr	1742(ra) # 5530 <link>
     e6a:	0e055863          	bgez	a0,f5a <linktest+0x230>
}
     e6e:	60e2                	ld	ra,24(sp)
     e70:	6442                	ld	s0,16(sp)
     e72:	64a2                	ld	s1,8(sp)
     e74:	6902                	ld	s2,0(sp)
     e76:	6105                	addi	sp,sp,32
     e78:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e7a:	85ca                	mv	a1,s2
     e7c:	00005517          	auipc	a0,0x5
     e80:	45450513          	addi	a0,a0,1108 # 62d0 <malloc+0x9ca>
     e84:	00005097          	auipc	ra,0x5
     e88:	9c4080e7          	jalr	-1596(ra) # 5848 <printf>
    exit(1);
     e8c:	4505                	li	a0,1
     e8e:	00004097          	auipc	ra,0x4
     e92:	642080e7          	jalr	1602(ra) # 54d0 <exit>
    printf("%s: write lf1 failed\n", s);
     e96:	85ca                	mv	a1,s2
     e98:	00005517          	auipc	a0,0x5
     e9c:	45050513          	addi	a0,a0,1104 # 62e8 <malloc+0x9e2>
     ea0:	00005097          	auipc	ra,0x5
     ea4:	9a8080e7          	jalr	-1624(ra) # 5848 <printf>
    exit(1);
     ea8:	4505                	li	a0,1
     eaa:	00004097          	auipc	ra,0x4
     eae:	626080e7          	jalr	1574(ra) # 54d0 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     eb2:	85ca                	mv	a1,s2
     eb4:	00005517          	auipc	a0,0x5
     eb8:	44c50513          	addi	a0,a0,1100 # 6300 <malloc+0x9fa>
     ebc:	00005097          	auipc	ra,0x5
     ec0:	98c080e7          	jalr	-1652(ra) # 5848 <printf>
    exit(1);
     ec4:	4505                	li	a0,1
     ec6:	00004097          	auipc	ra,0x4
     eca:	60a080e7          	jalr	1546(ra) # 54d0 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ece:	85ca                	mv	a1,s2
     ed0:	00005517          	auipc	a0,0x5
     ed4:	45050513          	addi	a0,a0,1104 # 6320 <malloc+0xa1a>
     ed8:	00005097          	auipc	ra,0x5
     edc:	970080e7          	jalr	-1680(ra) # 5848 <printf>
    exit(1);
     ee0:	4505                	li	a0,1
     ee2:	00004097          	auipc	ra,0x4
     ee6:	5ee080e7          	jalr	1518(ra) # 54d0 <exit>
    printf("%s: open lf2 failed\n", s);
     eea:	85ca                	mv	a1,s2
     eec:	00005517          	auipc	a0,0x5
     ef0:	46450513          	addi	a0,a0,1124 # 6350 <malloc+0xa4a>
     ef4:	00005097          	auipc	ra,0x5
     ef8:	954080e7          	jalr	-1708(ra) # 5848 <printf>
    exit(1);
     efc:	4505                	li	a0,1
     efe:	00004097          	auipc	ra,0x4
     f02:	5d2080e7          	jalr	1490(ra) # 54d0 <exit>
    printf("%s: read lf2 failed\n", s);
     f06:	85ca                	mv	a1,s2
     f08:	00005517          	auipc	a0,0x5
     f0c:	46050513          	addi	a0,a0,1120 # 6368 <malloc+0xa62>
     f10:	00005097          	auipc	ra,0x5
     f14:	938080e7          	jalr	-1736(ra) # 5848 <printf>
    exit(1);
     f18:	4505                	li	a0,1
     f1a:	00004097          	auipc	ra,0x4
     f1e:	5b6080e7          	jalr	1462(ra) # 54d0 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f22:	85ca                	mv	a1,s2
     f24:	00005517          	auipc	a0,0x5
     f28:	45c50513          	addi	a0,a0,1116 # 6380 <malloc+0xa7a>
     f2c:	00005097          	auipc	ra,0x5
     f30:	91c080e7          	jalr	-1764(ra) # 5848 <printf>
    exit(1);
     f34:	4505                	li	a0,1
     f36:	00004097          	auipc	ra,0x4
     f3a:	59a080e7          	jalr	1434(ra) # 54d0 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f3e:	85ca                	mv	a1,s2
     f40:	00005517          	auipc	a0,0x5
     f44:	46850513          	addi	a0,a0,1128 # 63a8 <malloc+0xaa2>
     f48:	00005097          	auipc	ra,0x5
     f4c:	900080e7          	jalr	-1792(ra) # 5848 <printf>
    exit(1);
     f50:	4505                	li	a0,1
     f52:	00004097          	auipc	ra,0x4
     f56:	57e080e7          	jalr	1406(ra) # 54d0 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f5a:	85ca                	mv	a1,s2
     f5c:	00005517          	auipc	a0,0x5
     f60:	47c50513          	addi	a0,a0,1148 # 63d8 <malloc+0xad2>
     f64:	00005097          	auipc	ra,0x5
     f68:	8e4080e7          	jalr	-1820(ra) # 5848 <printf>
    exit(1);
     f6c:	4505                	li	a0,1
     f6e:	00004097          	auipc	ra,0x4
     f72:	562080e7          	jalr	1378(ra) # 54d0 <exit>

0000000000000f76 <bigdir>:
{
     f76:	715d                	addi	sp,sp,-80
     f78:	e486                	sd	ra,72(sp)
     f7a:	e0a2                	sd	s0,64(sp)
     f7c:	fc26                	sd	s1,56(sp)
     f7e:	f84a                	sd	s2,48(sp)
     f80:	f44e                	sd	s3,40(sp)
     f82:	f052                	sd	s4,32(sp)
     f84:	ec56                	sd	s5,24(sp)
     f86:	e85a                	sd	s6,16(sp)
     f88:	0880                	addi	s0,sp,80
     f8a:	89aa                	mv	s3,a0
  unlink("bd");
     f8c:	00005517          	auipc	a0,0x5
     f90:	46c50513          	addi	a0,a0,1132 # 63f8 <malloc+0xaf2>
     f94:	00004097          	auipc	ra,0x4
     f98:	58c080e7          	jalr	1420(ra) # 5520 <unlink>
  fd = open("bd", O_CREATE);
     f9c:	20000593          	li	a1,512
     fa0:	00005517          	auipc	a0,0x5
     fa4:	45850513          	addi	a0,a0,1112 # 63f8 <malloc+0xaf2>
     fa8:	00004097          	auipc	ra,0x4
     fac:	568080e7          	jalr	1384(ra) # 5510 <open>
  if(fd < 0){
     fb0:	0c054963          	bltz	a0,1082 <bigdir+0x10c>
  close(fd);
     fb4:	00004097          	auipc	ra,0x4
     fb8:	544080e7          	jalr	1348(ra) # 54f8 <close>
  for(i = 0; i < N; i++){
     fbc:	4901                	li	s2,0
    name[0] = 'x';
     fbe:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fc2:	00005a17          	auipc	s4,0x5
     fc6:	436a0a13          	addi	s4,s4,1078 # 63f8 <malloc+0xaf2>
  for(i = 0; i < N; i++){
     fca:	1f400b13          	li	s6,500
    name[0] = 'x';
     fce:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fd2:	41f9579b          	sraiw	a5,s2,0x1f
     fd6:	01a7d71b          	srliw	a4,a5,0x1a
     fda:	012707bb          	addw	a5,a4,s2
     fde:	4067d69b          	sraiw	a3,a5,0x6
     fe2:	0306869b          	addiw	a3,a3,48
     fe6:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fea:	03f7f793          	andi	a5,a5,63
     fee:	9f99                	subw	a5,a5,a4
     ff0:	0307879b          	addiw	a5,a5,48
     ff4:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     ff8:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     ffc:	fb040593          	addi	a1,s0,-80
    1000:	8552                	mv	a0,s4
    1002:	00004097          	auipc	ra,0x4
    1006:	52e080e7          	jalr	1326(ra) # 5530 <link>
    100a:	84aa                	mv	s1,a0
    100c:	e949                	bnez	a0,109e <bigdir+0x128>
  for(i = 0; i < N; i++){
    100e:	2905                	addiw	s2,s2,1
    1010:	fb691fe3          	bne	s2,s6,fce <bigdir+0x58>
  unlink("bd");
    1014:	00005517          	auipc	a0,0x5
    1018:	3e450513          	addi	a0,a0,996 # 63f8 <malloc+0xaf2>
    101c:	00004097          	auipc	ra,0x4
    1020:	504080e7          	jalr	1284(ra) # 5520 <unlink>
    name[0] = 'x';
    1024:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1028:	1f400a13          	li	s4,500
    name[0] = 'x';
    102c:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1030:	41f4d79b          	sraiw	a5,s1,0x1f
    1034:	01a7d71b          	srliw	a4,a5,0x1a
    1038:	009707bb          	addw	a5,a4,s1
    103c:	4067d69b          	sraiw	a3,a5,0x6
    1040:	0306869b          	addiw	a3,a3,48
    1044:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1048:	03f7f793          	andi	a5,a5,63
    104c:	9f99                	subw	a5,a5,a4
    104e:	0307879b          	addiw	a5,a5,48
    1052:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1056:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    105a:	fb040513          	addi	a0,s0,-80
    105e:	00004097          	auipc	ra,0x4
    1062:	4c2080e7          	jalr	1218(ra) # 5520 <unlink>
    1066:	ed21                	bnez	a0,10be <bigdir+0x148>
  for(i = 0; i < N; i++){
    1068:	2485                	addiw	s1,s1,1
    106a:	fd4491e3          	bne	s1,s4,102c <bigdir+0xb6>
}
    106e:	60a6                	ld	ra,72(sp)
    1070:	6406                	ld	s0,64(sp)
    1072:	74e2                	ld	s1,56(sp)
    1074:	7942                	ld	s2,48(sp)
    1076:	79a2                	ld	s3,40(sp)
    1078:	7a02                	ld	s4,32(sp)
    107a:	6ae2                	ld	s5,24(sp)
    107c:	6b42                	ld	s6,16(sp)
    107e:	6161                	addi	sp,sp,80
    1080:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1082:	85ce                	mv	a1,s3
    1084:	00005517          	auipc	a0,0x5
    1088:	37c50513          	addi	a0,a0,892 # 6400 <malloc+0xafa>
    108c:	00004097          	auipc	ra,0x4
    1090:	7bc080e7          	jalr	1980(ra) # 5848 <printf>
    exit(1);
    1094:	4505                	li	a0,1
    1096:	00004097          	auipc	ra,0x4
    109a:	43a080e7          	jalr	1082(ra) # 54d0 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    109e:	fb040613          	addi	a2,s0,-80
    10a2:	85ce                	mv	a1,s3
    10a4:	00005517          	auipc	a0,0x5
    10a8:	37c50513          	addi	a0,a0,892 # 6420 <malloc+0xb1a>
    10ac:	00004097          	auipc	ra,0x4
    10b0:	79c080e7          	jalr	1948(ra) # 5848 <printf>
      exit(1);
    10b4:	4505                	li	a0,1
    10b6:	00004097          	auipc	ra,0x4
    10ba:	41a080e7          	jalr	1050(ra) # 54d0 <exit>
      printf("%s: bigdir unlink failed", s);
    10be:	85ce                	mv	a1,s3
    10c0:	00005517          	auipc	a0,0x5
    10c4:	38050513          	addi	a0,a0,896 # 6440 <malloc+0xb3a>
    10c8:	00004097          	auipc	ra,0x4
    10cc:	780080e7          	jalr	1920(ra) # 5848 <printf>
      exit(1);
    10d0:	4505                	li	a0,1
    10d2:	00004097          	auipc	ra,0x4
    10d6:	3fe080e7          	jalr	1022(ra) # 54d0 <exit>

00000000000010da <validatetest>:
{
    10da:	7139                	addi	sp,sp,-64
    10dc:	fc06                	sd	ra,56(sp)
    10de:	f822                	sd	s0,48(sp)
    10e0:	f426                	sd	s1,40(sp)
    10e2:	f04a                	sd	s2,32(sp)
    10e4:	ec4e                	sd	s3,24(sp)
    10e6:	e852                	sd	s4,16(sp)
    10e8:	e456                	sd	s5,8(sp)
    10ea:	e05a                	sd	s6,0(sp)
    10ec:	0080                	addi	s0,sp,64
    10ee:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10f0:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10f2:	00005997          	auipc	s3,0x5
    10f6:	36e98993          	addi	s3,s3,878 # 6460 <malloc+0xb5a>
    10fa:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fc:	6a85                	lui	s5,0x1
    10fe:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1102:	85a6                	mv	a1,s1
    1104:	854e                	mv	a0,s3
    1106:	00004097          	auipc	ra,0x4
    110a:	42a080e7          	jalr	1066(ra) # 5530 <link>
    110e:	01251f63          	bne	a0,s2,112c <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1112:	94d6                	add	s1,s1,s5
    1114:	ff4497e3          	bne	s1,s4,1102 <validatetest+0x28>
}
    1118:	70e2                	ld	ra,56(sp)
    111a:	7442                	ld	s0,48(sp)
    111c:	74a2                	ld	s1,40(sp)
    111e:	7902                	ld	s2,32(sp)
    1120:	69e2                	ld	s3,24(sp)
    1122:	6a42                	ld	s4,16(sp)
    1124:	6aa2                	ld	s5,8(sp)
    1126:	6b02                	ld	s6,0(sp)
    1128:	6121                	addi	sp,sp,64
    112a:	8082                	ret
      printf("%s: link should not succeed\n", s);
    112c:	85da                	mv	a1,s6
    112e:	00005517          	auipc	a0,0x5
    1132:	34250513          	addi	a0,a0,834 # 6470 <malloc+0xb6a>
    1136:	00004097          	auipc	ra,0x4
    113a:	712080e7          	jalr	1810(ra) # 5848 <printf>
      exit(1);
    113e:	4505                	li	a0,1
    1140:	00004097          	auipc	ra,0x4
    1144:	390080e7          	jalr	912(ra) # 54d0 <exit>

0000000000001148 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1148:	7179                	addi	sp,sp,-48
    114a:	f406                	sd	ra,40(sp)
    114c:	f022                	sd	s0,32(sp)
    114e:	ec26                	sd	s1,24(sp)
    1150:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1152:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1156:	00007497          	auipc	s1,0x7
    115a:	fa24b483          	ld	s1,-94(s1) # 80f8 <__SDATA_BEGIN__>
    115e:	fd840593          	addi	a1,s0,-40
    1162:	8526                	mv	a0,s1
    1164:	00004097          	auipc	ra,0x4
    1168:	3a4080e7          	jalr	932(ra) # 5508 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    116c:	8526                	mv	a0,s1
    116e:	00004097          	auipc	ra,0x4
    1172:	372080e7          	jalr	882(ra) # 54e0 <pipe>

  exit(0);
    1176:	4501                	li	a0,0
    1178:	00004097          	auipc	ra,0x4
    117c:	358080e7          	jalr	856(ra) # 54d0 <exit>

0000000000001180 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1180:	7139                	addi	sp,sp,-64
    1182:	fc06                	sd	ra,56(sp)
    1184:	f822                	sd	s0,48(sp)
    1186:	f426                	sd	s1,40(sp)
    1188:	f04a                	sd	s2,32(sp)
    118a:	ec4e                	sd	s3,24(sp)
    118c:	0080                	addi	s0,sp,64
    118e:	64b1                	lui	s1,0xc
    1190:	35048493          	addi	s1,s1,848 # c350 <buf+0xa20>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1194:	597d                	li	s2,-1
    1196:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    119a:	00005997          	auipc	s3,0x5
    119e:	b9e98993          	addi	s3,s3,-1122 # 5d38 <malloc+0x432>
    argv[0] = (char*)0xffffffff;
    11a2:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    11a6:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    11aa:	fc040593          	addi	a1,s0,-64
    11ae:	854e                	mv	a0,s3
    11b0:	00004097          	auipc	ra,0x4
    11b4:	358080e7          	jalr	856(ra) # 5508 <exec>
  for(int i = 0; i < 50000; i++){
    11b8:	34fd                	addiw	s1,s1,-1
    11ba:	f4e5                	bnez	s1,11a2 <badarg+0x22>
  }
  
  exit(0);
    11bc:	4501                	li	a0,0
    11be:	00004097          	auipc	ra,0x4
    11c2:	312080e7          	jalr	786(ra) # 54d0 <exit>

00000000000011c6 <copyinstr2>:
{
    11c6:	7155                	addi	sp,sp,-208
    11c8:	e586                	sd	ra,200(sp)
    11ca:	e1a2                	sd	s0,192(sp)
    11cc:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ce:	f6840793          	addi	a5,s0,-152
    11d2:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11d6:	07800713          	li	a4,120
    11da:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11de:	0785                	addi	a5,a5,1
    11e0:	fed79de3          	bne	a5,a3,11da <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11e4:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11e8:	f6840513          	addi	a0,s0,-152
    11ec:	00004097          	auipc	ra,0x4
    11f0:	334080e7          	jalr	820(ra) # 5520 <unlink>
  if(ret != -1){
    11f4:	57fd                	li	a5,-1
    11f6:	0ef51063          	bne	a0,a5,12d6 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11fa:	20100593          	li	a1,513
    11fe:	f6840513          	addi	a0,s0,-152
    1202:	00004097          	auipc	ra,0x4
    1206:	30e080e7          	jalr	782(ra) # 5510 <open>
  if(fd != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51563          	bne	a0,a5,12f6 <copyinstr2+0x130>
  ret = link(b, b);
    1210:	f6840593          	addi	a1,s0,-152
    1214:	852e                	mv	a0,a1
    1216:	00004097          	auipc	ra,0x4
    121a:	31a080e7          	jalr	794(ra) # 5530 <link>
  if(ret != -1){
    121e:	57fd                	li	a5,-1
    1220:	0ef51b63          	bne	a0,a5,1316 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1224:	00006797          	auipc	a5,0x6
    1228:	40478793          	addi	a5,a5,1028 # 7628 <malloc+0x1d22>
    122c:	f4f43c23          	sd	a5,-168(s0)
    1230:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1234:	f5840593          	addi	a1,s0,-168
    1238:	f6840513          	addi	a0,s0,-152
    123c:	00004097          	auipc	ra,0x4
    1240:	2cc080e7          	jalr	716(ra) # 5508 <exec>
  if(ret != -1){
    1244:	57fd                	li	a5,-1
    1246:	0ef51963          	bne	a0,a5,1338 <copyinstr2+0x172>
  int pid = fork();
    124a:	00004097          	auipc	ra,0x4
    124e:	27e080e7          	jalr	638(ra) # 54c8 <fork>
  if(pid < 0){
    1252:	10054363          	bltz	a0,1358 <copyinstr2+0x192>
  if(pid == 0){
    1256:	12051463          	bnez	a0,137e <copyinstr2+0x1b8>
    125a:	00007797          	auipc	a5,0x7
    125e:	fbe78793          	addi	a5,a5,-66 # 8218 <big.1265>
    1262:	00008697          	auipc	a3,0x8
    1266:	fb668693          	addi	a3,a3,-74 # 9218 <__global_pointer$+0x920>
      big[i] = 'x';
    126a:	07800713          	li	a4,120
    126e:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1272:	0785                	addi	a5,a5,1
    1274:	fed79de3          	bne	a5,a3,126e <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1278:	00008797          	auipc	a5,0x8
    127c:	fa078023          	sb	zero,-96(a5) # 9218 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1280:	00007797          	auipc	a5,0x7
    1284:	a9878793          	addi	a5,a5,-1384 # 7d18 <malloc+0x2412>
    1288:	6390                	ld	a2,0(a5)
    128a:	6794                	ld	a3,8(a5)
    128c:	6b98                	ld	a4,16(a5)
    128e:	6f9c                	ld	a5,24(a5)
    1290:	f2c43823          	sd	a2,-208(s0)
    1294:	f2d43c23          	sd	a3,-200(s0)
    1298:	f4e43023          	sd	a4,-192(s0)
    129c:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    12a0:	f3040593          	addi	a1,s0,-208
    12a4:	00005517          	auipc	a0,0x5
    12a8:	a9450513          	addi	a0,a0,-1388 # 5d38 <malloc+0x432>
    12ac:	00004097          	auipc	ra,0x4
    12b0:	25c080e7          	jalr	604(ra) # 5508 <exec>
    if(ret != -1){
    12b4:	57fd                	li	a5,-1
    12b6:	0af50e63          	beq	a0,a5,1372 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12ba:	55fd                	li	a1,-1
    12bc:	00005517          	auipc	a0,0x5
    12c0:	25c50513          	addi	a0,a0,604 # 6518 <malloc+0xc12>
    12c4:	00004097          	auipc	ra,0x4
    12c8:	584080e7          	jalr	1412(ra) # 5848 <printf>
      exit(1);
    12cc:	4505                	li	a0,1
    12ce:	00004097          	auipc	ra,0x4
    12d2:	202080e7          	jalr	514(ra) # 54d0 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12d6:	862a                	mv	a2,a0
    12d8:	f6840593          	addi	a1,s0,-152
    12dc:	00005517          	auipc	a0,0x5
    12e0:	1b450513          	addi	a0,a0,436 # 6490 <malloc+0xb8a>
    12e4:	00004097          	auipc	ra,0x4
    12e8:	564080e7          	jalr	1380(ra) # 5848 <printf>
    exit(1);
    12ec:	4505                	li	a0,1
    12ee:	00004097          	auipc	ra,0x4
    12f2:	1e2080e7          	jalr	482(ra) # 54d0 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12f6:	862a                	mv	a2,a0
    12f8:	f6840593          	addi	a1,s0,-152
    12fc:	00005517          	auipc	a0,0x5
    1300:	1b450513          	addi	a0,a0,436 # 64b0 <malloc+0xbaa>
    1304:	00004097          	auipc	ra,0x4
    1308:	544080e7          	jalr	1348(ra) # 5848 <printf>
    exit(1);
    130c:	4505                	li	a0,1
    130e:	00004097          	auipc	ra,0x4
    1312:	1c2080e7          	jalr	450(ra) # 54d0 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1316:	86aa                	mv	a3,a0
    1318:	f6840613          	addi	a2,s0,-152
    131c:	85b2                	mv	a1,a2
    131e:	00005517          	auipc	a0,0x5
    1322:	1b250513          	addi	a0,a0,434 # 64d0 <malloc+0xbca>
    1326:	00004097          	auipc	ra,0x4
    132a:	522080e7          	jalr	1314(ra) # 5848 <printf>
    exit(1);
    132e:	4505                	li	a0,1
    1330:	00004097          	auipc	ra,0x4
    1334:	1a0080e7          	jalr	416(ra) # 54d0 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1338:	567d                	li	a2,-1
    133a:	f6840593          	addi	a1,s0,-152
    133e:	00005517          	auipc	a0,0x5
    1342:	1ba50513          	addi	a0,a0,442 # 64f8 <malloc+0xbf2>
    1346:	00004097          	auipc	ra,0x4
    134a:	502080e7          	jalr	1282(ra) # 5848 <printf>
    exit(1);
    134e:	4505                	li	a0,1
    1350:	00004097          	auipc	ra,0x4
    1354:	180080e7          	jalr	384(ra) # 54d0 <exit>
    printf("fork failed\n");
    1358:	00005517          	auipc	a0,0x5
    135c:	60850513          	addi	a0,a0,1544 # 6960 <malloc+0x105a>
    1360:	00004097          	auipc	ra,0x4
    1364:	4e8080e7          	jalr	1256(ra) # 5848 <printf>
    exit(1);
    1368:	4505                	li	a0,1
    136a:	00004097          	auipc	ra,0x4
    136e:	166080e7          	jalr	358(ra) # 54d0 <exit>
    exit(747); // OK
    1372:	2eb00513          	li	a0,747
    1376:	00004097          	auipc	ra,0x4
    137a:	15a080e7          	jalr	346(ra) # 54d0 <exit>
  int st = 0;
    137e:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1382:	f5440513          	addi	a0,s0,-172
    1386:	00004097          	auipc	ra,0x4
    138a:	152080e7          	jalr	338(ra) # 54d8 <wait>
  if(st != 747){
    138e:	f5442703          	lw	a4,-172(s0)
    1392:	2eb00793          	li	a5,747
    1396:	00f71663          	bne	a4,a5,13a2 <copyinstr2+0x1dc>
}
    139a:	60ae                	ld	ra,200(sp)
    139c:	640e                	ld	s0,192(sp)
    139e:	6169                	addi	sp,sp,208
    13a0:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    13a2:	00005517          	auipc	a0,0x5
    13a6:	19e50513          	addi	a0,a0,414 # 6540 <malloc+0xc3a>
    13aa:	00004097          	auipc	ra,0x4
    13ae:	49e080e7          	jalr	1182(ra) # 5848 <printf>
    exit(1);
    13b2:	4505                	li	a0,1
    13b4:	00004097          	auipc	ra,0x4
    13b8:	11c080e7          	jalr	284(ra) # 54d0 <exit>

00000000000013bc <truncate3>:
{
    13bc:	7159                	addi	sp,sp,-112
    13be:	f486                	sd	ra,104(sp)
    13c0:	f0a2                	sd	s0,96(sp)
    13c2:	eca6                	sd	s1,88(sp)
    13c4:	e8ca                	sd	s2,80(sp)
    13c6:	e4ce                	sd	s3,72(sp)
    13c8:	e0d2                	sd	s4,64(sp)
    13ca:	fc56                	sd	s5,56(sp)
    13cc:	1880                	addi	s0,sp,112
    13ce:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13d0:	60100593          	li	a1,1537
    13d4:	00005517          	auipc	a0,0x5
    13d8:	9bc50513          	addi	a0,a0,-1604 # 5d90 <malloc+0x48a>
    13dc:	00004097          	auipc	ra,0x4
    13e0:	134080e7          	jalr	308(ra) # 5510 <open>
    13e4:	00004097          	auipc	ra,0x4
    13e8:	114080e7          	jalr	276(ra) # 54f8 <close>
  pid = fork();
    13ec:	00004097          	auipc	ra,0x4
    13f0:	0dc080e7          	jalr	220(ra) # 54c8 <fork>
  if(pid < 0){
    13f4:	08054063          	bltz	a0,1474 <truncate3+0xb8>
  if(pid == 0){
    13f8:	e969                	bnez	a0,14ca <truncate3+0x10e>
    13fa:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13fe:	00005a17          	auipc	s4,0x5
    1402:	992a0a13          	addi	s4,s4,-1646 # 5d90 <malloc+0x48a>
      int n = write(fd, "1234567890", 10);
    1406:	00005a97          	auipc	s5,0x5
    140a:	19aa8a93          	addi	s5,s5,410 # 65a0 <malloc+0xc9a>
      int fd = open("truncfile", O_WRONLY);
    140e:	4585                	li	a1,1
    1410:	8552                	mv	a0,s4
    1412:	00004097          	auipc	ra,0x4
    1416:	0fe080e7          	jalr	254(ra) # 5510 <open>
    141a:	84aa                	mv	s1,a0
      if(fd < 0){
    141c:	06054a63          	bltz	a0,1490 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1420:	4629                	li	a2,10
    1422:	85d6                	mv	a1,s5
    1424:	00004097          	auipc	ra,0x4
    1428:	0cc080e7          	jalr	204(ra) # 54f0 <write>
      if(n != 10){
    142c:	47a9                	li	a5,10
    142e:	06f51f63          	bne	a0,a5,14ac <truncate3+0xf0>
      close(fd);
    1432:	8526                	mv	a0,s1
    1434:	00004097          	auipc	ra,0x4
    1438:	0c4080e7          	jalr	196(ra) # 54f8 <close>
      fd = open("truncfile", O_RDONLY);
    143c:	4581                	li	a1,0
    143e:	8552                	mv	a0,s4
    1440:	00004097          	auipc	ra,0x4
    1444:	0d0080e7          	jalr	208(ra) # 5510 <open>
    1448:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    144a:	02000613          	li	a2,32
    144e:	f9840593          	addi	a1,s0,-104
    1452:	00004097          	auipc	ra,0x4
    1456:	096080e7          	jalr	150(ra) # 54e8 <read>
      close(fd);
    145a:	8526                	mv	a0,s1
    145c:	00004097          	auipc	ra,0x4
    1460:	09c080e7          	jalr	156(ra) # 54f8 <close>
    for(int i = 0; i < 100; i++){
    1464:	39fd                	addiw	s3,s3,-1
    1466:	fa0994e3          	bnez	s3,140e <truncate3+0x52>
    exit(0);
    146a:	4501                	li	a0,0
    146c:	00004097          	auipc	ra,0x4
    1470:	064080e7          	jalr	100(ra) # 54d0 <exit>
    printf("%s: fork failed\n", s);
    1474:	85ca                	mv	a1,s2
    1476:	00005517          	auipc	a0,0x5
    147a:	0fa50513          	addi	a0,a0,250 # 6570 <malloc+0xc6a>
    147e:	00004097          	auipc	ra,0x4
    1482:	3ca080e7          	jalr	970(ra) # 5848 <printf>
    exit(1);
    1486:	4505                	li	a0,1
    1488:	00004097          	auipc	ra,0x4
    148c:	048080e7          	jalr	72(ra) # 54d0 <exit>
        printf("%s: open failed\n", s);
    1490:	85ca                	mv	a1,s2
    1492:	00005517          	auipc	a0,0x5
    1496:	0f650513          	addi	a0,a0,246 # 6588 <malloc+0xc82>
    149a:	00004097          	auipc	ra,0x4
    149e:	3ae080e7          	jalr	942(ra) # 5848 <printf>
        exit(1);
    14a2:	4505                	li	a0,1
    14a4:	00004097          	auipc	ra,0x4
    14a8:	02c080e7          	jalr	44(ra) # 54d0 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14ac:	862a                	mv	a2,a0
    14ae:	85ca                	mv	a1,s2
    14b0:	00005517          	auipc	a0,0x5
    14b4:	10050513          	addi	a0,a0,256 # 65b0 <malloc+0xcaa>
    14b8:	00004097          	auipc	ra,0x4
    14bc:	390080e7          	jalr	912(ra) # 5848 <printf>
        exit(1);
    14c0:	4505                	li	a0,1
    14c2:	00004097          	auipc	ra,0x4
    14c6:	00e080e7          	jalr	14(ra) # 54d0 <exit>
    14ca:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ce:	00005a17          	auipc	s4,0x5
    14d2:	8c2a0a13          	addi	s4,s4,-1854 # 5d90 <malloc+0x48a>
    int n = write(fd, "xxx", 3);
    14d6:	00005a97          	auipc	s5,0x5
    14da:	0faa8a93          	addi	s5,s5,250 # 65d0 <malloc+0xcca>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14de:	60100593          	li	a1,1537
    14e2:	8552                	mv	a0,s4
    14e4:	00004097          	auipc	ra,0x4
    14e8:	02c080e7          	jalr	44(ra) # 5510 <open>
    14ec:	84aa                	mv	s1,a0
    if(fd < 0){
    14ee:	04054763          	bltz	a0,153c <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14f2:	460d                	li	a2,3
    14f4:	85d6                	mv	a1,s5
    14f6:	00004097          	auipc	ra,0x4
    14fa:	ffa080e7          	jalr	-6(ra) # 54f0 <write>
    if(n != 3){
    14fe:	478d                	li	a5,3
    1500:	04f51c63          	bne	a0,a5,1558 <truncate3+0x19c>
    close(fd);
    1504:	8526                	mv	a0,s1
    1506:	00004097          	auipc	ra,0x4
    150a:	ff2080e7          	jalr	-14(ra) # 54f8 <close>
  for(int i = 0; i < 150; i++){
    150e:	39fd                	addiw	s3,s3,-1
    1510:	fc0997e3          	bnez	s3,14de <truncate3+0x122>
  wait(&xstatus);
    1514:	fbc40513          	addi	a0,s0,-68
    1518:	00004097          	auipc	ra,0x4
    151c:	fc0080e7          	jalr	-64(ra) # 54d8 <wait>
  unlink("truncfile");
    1520:	00005517          	auipc	a0,0x5
    1524:	87050513          	addi	a0,a0,-1936 # 5d90 <malloc+0x48a>
    1528:	00004097          	auipc	ra,0x4
    152c:	ff8080e7          	jalr	-8(ra) # 5520 <unlink>
  exit(xstatus);
    1530:	fbc42503          	lw	a0,-68(s0)
    1534:	00004097          	auipc	ra,0x4
    1538:	f9c080e7          	jalr	-100(ra) # 54d0 <exit>
      printf("%s: open failed\n", s);
    153c:	85ca                	mv	a1,s2
    153e:	00005517          	auipc	a0,0x5
    1542:	04a50513          	addi	a0,a0,74 # 6588 <malloc+0xc82>
    1546:	00004097          	auipc	ra,0x4
    154a:	302080e7          	jalr	770(ra) # 5848 <printf>
      exit(1);
    154e:	4505                	li	a0,1
    1550:	00004097          	auipc	ra,0x4
    1554:	f80080e7          	jalr	-128(ra) # 54d0 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1558:	862a                	mv	a2,a0
    155a:	85ca                	mv	a1,s2
    155c:	00005517          	auipc	a0,0x5
    1560:	07c50513          	addi	a0,a0,124 # 65d8 <malloc+0xcd2>
    1564:	00004097          	auipc	ra,0x4
    1568:	2e4080e7          	jalr	740(ra) # 5848 <printf>
      exit(1);
    156c:	4505                	li	a0,1
    156e:	00004097          	auipc	ra,0x4
    1572:	f62080e7          	jalr	-158(ra) # 54d0 <exit>

0000000000001576 <exectest>:
{
    1576:	715d                	addi	sp,sp,-80
    1578:	e486                	sd	ra,72(sp)
    157a:	e0a2                	sd	s0,64(sp)
    157c:	fc26                	sd	s1,56(sp)
    157e:	f84a                	sd	s2,48(sp)
    1580:	0880                	addi	s0,sp,80
    1582:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1584:	00004797          	auipc	a5,0x4
    1588:	7b478793          	addi	a5,a5,1972 # 5d38 <malloc+0x432>
    158c:	fcf43023          	sd	a5,-64(s0)
    1590:	00005797          	auipc	a5,0x5
    1594:	06878793          	addi	a5,a5,104 # 65f8 <malloc+0xcf2>
    1598:	fcf43423          	sd	a5,-56(s0)
    159c:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    15a0:	00005517          	auipc	a0,0x5
    15a4:	06050513          	addi	a0,a0,96 # 6600 <malloc+0xcfa>
    15a8:	00004097          	auipc	ra,0x4
    15ac:	f78080e7          	jalr	-136(ra) # 5520 <unlink>
  pid = fork();
    15b0:	00004097          	auipc	ra,0x4
    15b4:	f18080e7          	jalr	-232(ra) # 54c8 <fork>
  if(pid < 0) {
    15b8:	04054663          	bltz	a0,1604 <exectest+0x8e>
    15bc:	84aa                	mv	s1,a0
  if(pid == 0) {
    15be:	e959                	bnez	a0,1654 <exectest+0xde>
    close(1);
    15c0:	4505                	li	a0,1
    15c2:	00004097          	auipc	ra,0x4
    15c6:	f36080e7          	jalr	-202(ra) # 54f8 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15ca:	20100593          	li	a1,513
    15ce:	00005517          	auipc	a0,0x5
    15d2:	03250513          	addi	a0,a0,50 # 6600 <malloc+0xcfa>
    15d6:	00004097          	auipc	ra,0x4
    15da:	f3a080e7          	jalr	-198(ra) # 5510 <open>
    if(fd < 0) {
    15de:	04054163          	bltz	a0,1620 <exectest+0xaa>
    if(fd != 1) {
    15e2:	4785                	li	a5,1
    15e4:	04f50c63          	beq	a0,a5,163c <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15e8:	85ca                	mv	a1,s2
    15ea:	00005517          	auipc	a0,0x5
    15ee:	03650513          	addi	a0,a0,54 # 6620 <malloc+0xd1a>
    15f2:	00004097          	auipc	ra,0x4
    15f6:	256080e7          	jalr	598(ra) # 5848 <printf>
      exit(1);
    15fa:	4505                	li	a0,1
    15fc:	00004097          	auipc	ra,0x4
    1600:	ed4080e7          	jalr	-300(ra) # 54d0 <exit>
     printf("%s: fork failed\n", s);
    1604:	85ca                	mv	a1,s2
    1606:	00005517          	auipc	a0,0x5
    160a:	f6a50513          	addi	a0,a0,-150 # 6570 <malloc+0xc6a>
    160e:	00004097          	auipc	ra,0x4
    1612:	23a080e7          	jalr	570(ra) # 5848 <printf>
     exit(1);
    1616:	4505                	li	a0,1
    1618:	00004097          	auipc	ra,0x4
    161c:	eb8080e7          	jalr	-328(ra) # 54d0 <exit>
      printf("%s: create failed\n", s);
    1620:	85ca                	mv	a1,s2
    1622:	00005517          	auipc	a0,0x5
    1626:	fe650513          	addi	a0,a0,-26 # 6608 <malloc+0xd02>
    162a:	00004097          	auipc	ra,0x4
    162e:	21e080e7          	jalr	542(ra) # 5848 <printf>
      exit(1);
    1632:	4505                	li	a0,1
    1634:	00004097          	auipc	ra,0x4
    1638:	e9c080e7          	jalr	-356(ra) # 54d0 <exit>
    if(exec("echo", echoargv) < 0){
    163c:	fc040593          	addi	a1,s0,-64
    1640:	00004517          	auipc	a0,0x4
    1644:	6f850513          	addi	a0,a0,1784 # 5d38 <malloc+0x432>
    1648:	00004097          	auipc	ra,0x4
    164c:	ec0080e7          	jalr	-320(ra) # 5508 <exec>
    1650:	02054163          	bltz	a0,1672 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1654:	fdc40513          	addi	a0,s0,-36
    1658:	00004097          	auipc	ra,0x4
    165c:	e80080e7          	jalr	-384(ra) # 54d8 <wait>
    1660:	02951763          	bne	a0,s1,168e <exectest+0x118>
  if(xstatus != 0)
    1664:	fdc42503          	lw	a0,-36(s0)
    1668:	cd0d                	beqz	a0,16a2 <exectest+0x12c>
    exit(xstatus);
    166a:	00004097          	auipc	ra,0x4
    166e:	e66080e7          	jalr	-410(ra) # 54d0 <exit>
      printf("%s: exec echo failed\n", s);
    1672:	85ca                	mv	a1,s2
    1674:	00005517          	auipc	a0,0x5
    1678:	fbc50513          	addi	a0,a0,-68 # 6630 <malloc+0xd2a>
    167c:	00004097          	auipc	ra,0x4
    1680:	1cc080e7          	jalr	460(ra) # 5848 <printf>
      exit(1);
    1684:	4505                	li	a0,1
    1686:	00004097          	auipc	ra,0x4
    168a:	e4a080e7          	jalr	-438(ra) # 54d0 <exit>
    printf("%s: wait failed!\n", s);
    168e:	85ca                	mv	a1,s2
    1690:	00005517          	auipc	a0,0x5
    1694:	fb850513          	addi	a0,a0,-72 # 6648 <malloc+0xd42>
    1698:	00004097          	auipc	ra,0x4
    169c:	1b0080e7          	jalr	432(ra) # 5848 <printf>
    16a0:	b7d1                	j	1664 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    16a2:	4581                	li	a1,0
    16a4:	00005517          	auipc	a0,0x5
    16a8:	f5c50513          	addi	a0,a0,-164 # 6600 <malloc+0xcfa>
    16ac:	00004097          	auipc	ra,0x4
    16b0:	e64080e7          	jalr	-412(ra) # 5510 <open>
  if(fd < 0) {
    16b4:	02054a63          	bltz	a0,16e8 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16b8:	4609                	li	a2,2
    16ba:	fb840593          	addi	a1,s0,-72
    16be:	00004097          	auipc	ra,0x4
    16c2:	e2a080e7          	jalr	-470(ra) # 54e8 <read>
    16c6:	4789                	li	a5,2
    16c8:	02f50e63          	beq	a0,a5,1704 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16cc:	85ca                	mv	a1,s2
    16ce:	00005517          	auipc	a0,0x5
    16d2:	9fa50513          	addi	a0,a0,-1542 # 60c8 <malloc+0x7c2>
    16d6:	00004097          	auipc	ra,0x4
    16da:	172080e7          	jalr	370(ra) # 5848 <printf>
    exit(1);
    16de:	4505                	li	a0,1
    16e0:	00004097          	auipc	ra,0x4
    16e4:	df0080e7          	jalr	-528(ra) # 54d0 <exit>
    printf("%s: open failed\n", s);
    16e8:	85ca                	mv	a1,s2
    16ea:	00005517          	auipc	a0,0x5
    16ee:	e9e50513          	addi	a0,a0,-354 # 6588 <malloc+0xc82>
    16f2:	00004097          	auipc	ra,0x4
    16f6:	156080e7          	jalr	342(ra) # 5848 <printf>
    exit(1);
    16fa:	4505                	li	a0,1
    16fc:	00004097          	auipc	ra,0x4
    1700:	dd4080e7          	jalr	-556(ra) # 54d0 <exit>
  unlink("echo-ok");
    1704:	00005517          	auipc	a0,0x5
    1708:	efc50513          	addi	a0,a0,-260 # 6600 <malloc+0xcfa>
    170c:	00004097          	auipc	ra,0x4
    1710:	e14080e7          	jalr	-492(ra) # 5520 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1714:	fb844703          	lbu	a4,-72(s0)
    1718:	04f00793          	li	a5,79
    171c:	00f71863          	bne	a4,a5,172c <exectest+0x1b6>
    1720:	fb944703          	lbu	a4,-71(s0)
    1724:	04b00793          	li	a5,75
    1728:	02f70063          	beq	a4,a5,1748 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    172c:	85ca                	mv	a1,s2
    172e:	00005517          	auipc	a0,0x5
    1732:	f3250513          	addi	a0,a0,-206 # 6660 <malloc+0xd5a>
    1736:	00004097          	auipc	ra,0x4
    173a:	112080e7          	jalr	274(ra) # 5848 <printf>
    exit(1);
    173e:	4505                	li	a0,1
    1740:	00004097          	auipc	ra,0x4
    1744:	d90080e7          	jalr	-624(ra) # 54d0 <exit>
    exit(0);
    1748:	4501                	li	a0,0
    174a:	00004097          	auipc	ra,0x4
    174e:	d86080e7          	jalr	-634(ra) # 54d0 <exit>

0000000000001752 <pipe1>:
{
    1752:	711d                	addi	sp,sp,-96
    1754:	ec86                	sd	ra,88(sp)
    1756:	e8a2                	sd	s0,80(sp)
    1758:	e4a6                	sd	s1,72(sp)
    175a:	e0ca                	sd	s2,64(sp)
    175c:	fc4e                	sd	s3,56(sp)
    175e:	f852                	sd	s4,48(sp)
    1760:	f456                	sd	s5,40(sp)
    1762:	f05a                	sd	s6,32(sp)
    1764:	ec5e                	sd	s7,24(sp)
    1766:	1080                	addi	s0,sp,96
    1768:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    176a:	fa840513          	addi	a0,s0,-88
    176e:	00004097          	auipc	ra,0x4
    1772:	d72080e7          	jalr	-654(ra) # 54e0 <pipe>
    1776:	ed25                	bnez	a0,17ee <pipe1+0x9c>
    1778:	84aa                	mv	s1,a0
  pid = fork();
    177a:	00004097          	auipc	ra,0x4
    177e:	d4e080e7          	jalr	-690(ra) # 54c8 <fork>
    1782:	8a2a                	mv	s4,a0
  if(pid == 0){
    1784:	c159                	beqz	a0,180a <pipe1+0xb8>
  } else if(pid > 0){
    1786:	16a05e63          	blez	a0,1902 <pipe1+0x1b0>
    close(fds[1]);
    178a:	fac42503          	lw	a0,-84(s0)
    178e:	00004097          	auipc	ra,0x4
    1792:	d6a080e7          	jalr	-662(ra) # 54f8 <close>
    total = 0;
    1796:	8a26                	mv	s4,s1
    cc = 1;
    1798:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    179a:	0000aa97          	auipc	s5,0xa
    179e:	196a8a93          	addi	s5,s5,406 # b930 <buf>
      if(cc > sizeof(buf))
    17a2:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17a4:	864e                	mv	a2,s3
    17a6:	85d6                	mv	a1,s5
    17a8:	fa842503          	lw	a0,-88(s0)
    17ac:	00004097          	auipc	ra,0x4
    17b0:	d3c080e7          	jalr	-708(ra) # 54e8 <read>
    17b4:	10a05263          	blez	a0,18b8 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17b8:	0000a717          	auipc	a4,0xa
    17bc:	17870713          	addi	a4,a4,376 # b930 <buf>
    17c0:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17c4:	00074683          	lbu	a3,0(a4)
    17c8:	0ff4f793          	andi	a5,s1,255
    17cc:	2485                	addiw	s1,s1,1
    17ce:	0cf69163          	bne	a3,a5,1890 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17d2:	0705                	addi	a4,a4,1
    17d4:	fec498e3          	bne	s1,a2,17c4 <pipe1+0x72>
      total += n;
    17d8:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17dc:	0019979b          	slliw	a5,s3,0x1
    17e0:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17e4:	013b7363          	bgeu	s6,s3,17ea <pipe1+0x98>
        cc = sizeof(buf);
    17e8:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17ea:	84b2                	mv	s1,a2
    17ec:	bf65                	j	17a4 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17ee:	85ca                	mv	a1,s2
    17f0:	00005517          	auipc	a0,0x5
    17f4:	e8850513          	addi	a0,a0,-376 # 6678 <malloc+0xd72>
    17f8:	00004097          	auipc	ra,0x4
    17fc:	050080e7          	jalr	80(ra) # 5848 <printf>
    exit(1);
    1800:	4505                	li	a0,1
    1802:	00004097          	auipc	ra,0x4
    1806:	cce080e7          	jalr	-818(ra) # 54d0 <exit>
    close(fds[0]);
    180a:	fa842503          	lw	a0,-88(s0)
    180e:	00004097          	auipc	ra,0x4
    1812:	cea080e7          	jalr	-790(ra) # 54f8 <close>
    for(n = 0; n < N; n++){
    1816:	0000ab17          	auipc	s6,0xa
    181a:	11ab0b13          	addi	s6,s6,282 # b930 <buf>
    181e:	416004bb          	negw	s1,s6
    1822:	0ff4f493          	andi	s1,s1,255
    1826:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    182a:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    182c:	6a85                	lui	s5,0x1
    182e:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x71>
{
    1832:	87da                	mv	a5,s6
        buf[i] = seq++;
    1834:	0097873b          	addw	a4,a5,s1
    1838:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    183c:	0785                	addi	a5,a5,1
    183e:	fef99be3          	bne	s3,a5,1834 <pipe1+0xe2>
    1842:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1846:	40900613          	li	a2,1033
    184a:	85de                	mv	a1,s7
    184c:	fac42503          	lw	a0,-84(s0)
    1850:	00004097          	auipc	ra,0x4
    1854:	ca0080e7          	jalr	-864(ra) # 54f0 <write>
    1858:	40900793          	li	a5,1033
    185c:	00f51c63          	bne	a0,a5,1874 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1860:	24a5                	addiw	s1,s1,9
    1862:	0ff4f493          	andi	s1,s1,255
    1866:	fd5a16e3          	bne	s4,s5,1832 <pipe1+0xe0>
    exit(0);
    186a:	4501                	li	a0,0
    186c:	00004097          	auipc	ra,0x4
    1870:	c64080e7          	jalr	-924(ra) # 54d0 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1874:	85ca                	mv	a1,s2
    1876:	00005517          	auipc	a0,0x5
    187a:	e1a50513          	addi	a0,a0,-486 # 6690 <malloc+0xd8a>
    187e:	00004097          	auipc	ra,0x4
    1882:	fca080e7          	jalr	-54(ra) # 5848 <printf>
        exit(1);
    1886:	4505                	li	a0,1
    1888:	00004097          	auipc	ra,0x4
    188c:	c48080e7          	jalr	-952(ra) # 54d0 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1890:	85ca                	mv	a1,s2
    1892:	00005517          	auipc	a0,0x5
    1896:	e1650513          	addi	a0,a0,-490 # 66a8 <malloc+0xda2>
    189a:	00004097          	auipc	ra,0x4
    189e:	fae080e7          	jalr	-82(ra) # 5848 <printf>
}
    18a2:	60e6                	ld	ra,88(sp)
    18a4:	6446                	ld	s0,80(sp)
    18a6:	64a6                	ld	s1,72(sp)
    18a8:	6906                	ld	s2,64(sp)
    18aa:	79e2                	ld	s3,56(sp)
    18ac:	7a42                	ld	s4,48(sp)
    18ae:	7aa2                	ld	s5,40(sp)
    18b0:	7b02                	ld	s6,32(sp)
    18b2:	6be2                	ld	s7,24(sp)
    18b4:	6125                	addi	sp,sp,96
    18b6:	8082                	ret
    if(total != N * SZ){
    18b8:	6785                	lui	a5,0x1
    18ba:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x71>
    18be:	02fa0063          	beq	s4,a5,18de <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18c2:	85d2                	mv	a1,s4
    18c4:	00005517          	auipc	a0,0x5
    18c8:	dfc50513          	addi	a0,a0,-516 # 66c0 <malloc+0xdba>
    18cc:	00004097          	auipc	ra,0x4
    18d0:	f7c080e7          	jalr	-132(ra) # 5848 <printf>
      exit(1);
    18d4:	4505                	li	a0,1
    18d6:	00004097          	auipc	ra,0x4
    18da:	bfa080e7          	jalr	-1030(ra) # 54d0 <exit>
    close(fds[0]);
    18de:	fa842503          	lw	a0,-88(s0)
    18e2:	00004097          	auipc	ra,0x4
    18e6:	c16080e7          	jalr	-1002(ra) # 54f8 <close>
    wait(&xstatus);
    18ea:	fa440513          	addi	a0,s0,-92
    18ee:	00004097          	auipc	ra,0x4
    18f2:	bea080e7          	jalr	-1046(ra) # 54d8 <wait>
    exit(xstatus);
    18f6:	fa442503          	lw	a0,-92(s0)
    18fa:	00004097          	auipc	ra,0x4
    18fe:	bd6080e7          	jalr	-1066(ra) # 54d0 <exit>
    printf("%s: fork() failed\n", s);
    1902:	85ca                	mv	a1,s2
    1904:	00005517          	auipc	a0,0x5
    1908:	ddc50513          	addi	a0,a0,-548 # 66e0 <malloc+0xdda>
    190c:	00004097          	auipc	ra,0x4
    1910:	f3c080e7          	jalr	-196(ra) # 5848 <printf>
    exit(1);
    1914:	4505                	li	a0,1
    1916:	00004097          	auipc	ra,0x4
    191a:	bba080e7          	jalr	-1094(ra) # 54d0 <exit>

000000000000191e <exitwait>:
{
    191e:	7139                	addi	sp,sp,-64
    1920:	fc06                	sd	ra,56(sp)
    1922:	f822                	sd	s0,48(sp)
    1924:	f426                	sd	s1,40(sp)
    1926:	f04a                	sd	s2,32(sp)
    1928:	ec4e                	sd	s3,24(sp)
    192a:	e852                	sd	s4,16(sp)
    192c:	0080                	addi	s0,sp,64
    192e:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1930:	4901                	li	s2,0
    1932:	06400993          	li	s3,100
    pid = fork();
    1936:	00004097          	auipc	ra,0x4
    193a:	b92080e7          	jalr	-1134(ra) # 54c8 <fork>
    193e:	84aa                	mv	s1,a0
    if(pid < 0){
    1940:	02054a63          	bltz	a0,1974 <exitwait+0x56>
    if(pid){
    1944:	c151                	beqz	a0,19c8 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1946:	fcc40513          	addi	a0,s0,-52
    194a:	00004097          	auipc	ra,0x4
    194e:	b8e080e7          	jalr	-1138(ra) # 54d8 <wait>
    1952:	02951f63          	bne	a0,s1,1990 <exitwait+0x72>
      if(i != xstate) {
    1956:	fcc42783          	lw	a5,-52(s0)
    195a:	05279963          	bne	a5,s2,19ac <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    195e:	2905                	addiw	s2,s2,1
    1960:	fd391be3          	bne	s2,s3,1936 <exitwait+0x18>
}
    1964:	70e2                	ld	ra,56(sp)
    1966:	7442                	ld	s0,48(sp)
    1968:	74a2                	ld	s1,40(sp)
    196a:	7902                	ld	s2,32(sp)
    196c:	69e2                	ld	s3,24(sp)
    196e:	6a42                	ld	s4,16(sp)
    1970:	6121                	addi	sp,sp,64
    1972:	8082                	ret
      printf("%s: fork failed\n", s);
    1974:	85d2                	mv	a1,s4
    1976:	00005517          	auipc	a0,0x5
    197a:	bfa50513          	addi	a0,a0,-1030 # 6570 <malloc+0xc6a>
    197e:	00004097          	auipc	ra,0x4
    1982:	eca080e7          	jalr	-310(ra) # 5848 <printf>
      exit(1);
    1986:	4505                	li	a0,1
    1988:	00004097          	auipc	ra,0x4
    198c:	b48080e7          	jalr	-1208(ra) # 54d0 <exit>
        printf("%s: wait wrong pid\n", s);
    1990:	85d2                	mv	a1,s4
    1992:	00005517          	auipc	a0,0x5
    1996:	d6650513          	addi	a0,a0,-666 # 66f8 <malloc+0xdf2>
    199a:	00004097          	auipc	ra,0x4
    199e:	eae080e7          	jalr	-338(ra) # 5848 <printf>
        exit(1);
    19a2:	4505                	li	a0,1
    19a4:	00004097          	auipc	ra,0x4
    19a8:	b2c080e7          	jalr	-1236(ra) # 54d0 <exit>
        printf("%s: wait wrong exit status\n", s);
    19ac:	85d2                	mv	a1,s4
    19ae:	00005517          	auipc	a0,0x5
    19b2:	d6250513          	addi	a0,a0,-670 # 6710 <malloc+0xe0a>
    19b6:	00004097          	auipc	ra,0x4
    19ba:	e92080e7          	jalr	-366(ra) # 5848 <printf>
        exit(1);
    19be:	4505                	li	a0,1
    19c0:	00004097          	auipc	ra,0x4
    19c4:	b10080e7          	jalr	-1264(ra) # 54d0 <exit>
      exit(i);
    19c8:	854a                	mv	a0,s2
    19ca:	00004097          	auipc	ra,0x4
    19ce:	b06080e7          	jalr	-1274(ra) # 54d0 <exit>

00000000000019d2 <twochildren>:
{
    19d2:	1101                	addi	sp,sp,-32
    19d4:	ec06                	sd	ra,24(sp)
    19d6:	e822                	sd	s0,16(sp)
    19d8:	e426                	sd	s1,8(sp)
    19da:	e04a                	sd	s2,0(sp)
    19dc:	1000                	addi	s0,sp,32
    19de:	892a                	mv	s2,a0
    19e0:	3e800493          	li	s1,1000
    int pid1 = fork();
    19e4:	00004097          	auipc	ra,0x4
    19e8:	ae4080e7          	jalr	-1308(ra) # 54c8 <fork>
    if(pid1 < 0){
    19ec:	02054c63          	bltz	a0,1a24 <twochildren+0x52>
    if(pid1 == 0){
    19f0:	c921                	beqz	a0,1a40 <twochildren+0x6e>
      int pid2 = fork();
    19f2:	00004097          	auipc	ra,0x4
    19f6:	ad6080e7          	jalr	-1322(ra) # 54c8 <fork>
      if(pid2 < 0){
    19fa:	04054763          	bltz	a0,1a48 <twochildren+0x76>
      if(pid2 == 0){
    19fe:	c13d                	beqz	a0,1a64 <twochildren+0x92>
        wait(0);
    1a00:	4501                	li	a0,0
    1a02:	00004097          	auipc	ra,0x4
    1a06:	ad6080e7          	jalr	-1322(ra) # 54d8 <wait>
        wait(0);
    1a0a:	4501                	li	a0,0
    1a0c:	00004097          	auipc	ra,0x4
    1a10:	acc080e7          	jalr	-1332(ra) # 54d8 <wait>
  for(int i = 0; i < 1000; i++){
    1a14:	34fd                	addiw	s1,s1,-1
    1a16:	f4f9                	bnez	s1,19e4 <twochildren+0x12>
}
    1a18:	60e2                	ld	ra,24(sp)
    1a1a:	6442                	ld	s0,16(sp)
    1a1c:	64a2                	ld	s1,8(sp)
    1a1e:	6902                	ld	s2,0(sp)
    1a20:	6105                	addi	sp,sp,32
    1a22:	8082                	ret
      printf("%s: fork failed\n", s);
    1a24:	85ca                	mv	a1,s2
    1a26:	00005517          	auipc	a0,0x5
    1a2a:	b4a50513          	addi	a0,a0,-1206 # 6570 <malloc+0xc6a>
    1a2e:	00004097          	auipc	ra,0x4
    1a32:	e1a080e7          	jalr	-486(ra) # 5848 <printf>
      exit(1);
    1a36:	4505                	li	a0,1
    1a38:	00004097          	auipc	ra,0x4
    1a3c:	a98080e7          	jalr	-1384(ra) # 54d0 <exit>
      exit(0);
    1a40:	00004097          	auipc	ra,0x4
    1a44:	a90080e7          	jalr	-1392(ra) # 54d0 <exit>
        printf("%s: fork failed\n", s);
    1a48:	85ca                	mv	a1,s2
    1a4a:	00005517          	auipc	a0,0x5
    1a4e:	b2650513          	addi	a0,a0,-1242 # 6570 <malloc+0xc6a>
    1a52:	00004097          	auipc	ra,0x4
    1a56:	df6080e7          	jalr	-522(ra) # 5848 <printf>
        exit(1);
    1a5a:	4505                	li	a0,1
    1a5c:	00004097          	auipc	ra,0x4
    1a60:	a74080e7          	jalr	-1420(ra) # 54d0 <exit>
        exit(0);
    1a64:	00004097          	auipc	ra,0x4
    1a68:	a6c080e7          	jalr	-1428(ra) # 54d0 <exit>

0000000000001a6c <forkfork>:
{
    1a6c:	7179                	addi	sp,sp,-48
    1a6e:	f406                	sd	ra,40(sp)
    1a70:	f022                	sd	s0,32(sp)
    1a72:	ec26                	sd	s1,24(sp)
    1a74:	1800                	addi	s0,sp,48
    1a76:	84aa                	mv	s1,a0
    int pid = fork();
    1a78:	00004097          	auipc	ra,0x4
    1a7c:	a50080e7          	jalr	-1456(ra) # 54c8 <fork>
    if(pid < 0){
    1a80:	04054163          	bltz	a0,1ac2 <forkfork+0x56>
    if(pid == 0){
    1a84:	cd29                	beqz	a0,1ade <forkfork+0x72>
    int pid = fork();
    1a86:	00004097          	auipc	ra,0x4
    1a8a:	a42080e7          	jalr	-1470(ra) # 54c8 <fork>
    if(pid < 0){
    1a8e:	02054a63          	bltz	a0,1ac2 <forkfork+0x56>
    if(pid == 0){
    1a92:	c531                	beqz	a0,1ade <forkfork+0x72>
    wait(&xstatus);
    1a94:	fdc40513          	addi	a0,s0,-36
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	a40080e7          	jalr	-1472(ra) # 54d8 <wait>
    if(xstatus != 0) {
    1aa0:	fdc42783          	lw	a5,-36(s0)
    1aa4:	ebbd                	bnez	a5,1b1a <forkfork+0xae>
    wait(&xstatus);
    1aa6:	fdc40513          	addi	a0,s0,-36
    1aaa:	00004097          	auipc	ra,0x4
    1aae:	a2e080e7          	jalr	-1490(ra) # 54d8 <wait>
    if(xstatus != 0) {
    1ab2:	fdc42783          	lw	a5,-36(s0)
    1ab6:	e3b5                	bnez	a5,1b1a <forkfork+0xae>
}
    1ab8:	70a2                	ld	ra,40(sp)
    1aba:	7402                	ld	s0,32(sp)
    1abc:	64e2                	ld	s1,24(sp)
    1abe:	6145                	addi	sp,sp,48
    1ac0:	8082                	ret
      printf("%s: fork failed", s);
    1ac2:	85a6                	mv	a1,s1
    1ac4:	00005517          	auipc	a0,0x5
    1ac8:	c6c50513          	addi	a0,a0,-916 # 6730 <malloc+0xe2a>
    1acc:	00004097          	auipc	ra,0x4
    1ad0:	d7c080e7          	jalr	-644(ra) # 5848 <printf>
      exit(1);
    1ad4:	4505                	li	a0,1
    1ad6:	00004097          	auipc	ra,0x4
    1ada:	9fa080e7          	jalr	-1542(ra) # 54d0 <exit>
{
    1ade:	0c800493          	li	s1,200
        int pid1 = fork();
    1ae2:	00004097          	auipc	ra,0x4
    1ae6:	9e6080e7          	jalr	-1562(ra) # 54c8 <fork>
        if(pid1 < 0){
    1aea:	00054f63          	bltz	a0,1b08 <forkfork+0x9c>
        if(pid1 == 0){
    1aee:	c115                	beqz	a0,1b12 <forkfork+0xa6>
        wait(0);
    1af0:	4501                	li	a0,0
    1af2:	00004097          	auipc	ra,0x4
    1af6:	9e6080e7          	jalr	-1562(ra) # 54d8 <wait>
      for(int j = 0; j < 200; j++){
    1afa:	34fd                	addiw	s1,s1,-1
    1afc:	f0fd                	bnez	s1,1ae2 <forkfork+0x76>
      exit(0);
    1afe:	4501                	li	a0,0
    1b00:	00004097          	auipc	ra,0x4
    1b04:	9d0080e7          	jalr	-1584(ra) # 54d0 <exit>
          exit(1);
    1b08:	4505                	li	a0,1
    1b0a:	00004097          	auipc	ra,0x4
    1b0e:	9c6080e7          	jalr	-1594(ra) # 54d0 <exit>
          exit(0);
    1b12:	00004097          	auipc	ra,0x4
    1b16:	9be080e7          	jalr	-1602(ra) # 54d0 <exit>
      printf("%s: fork in child failed", s);
    1b1a:	85a6                	mv	a1,s1
    1b1c:	00005517          	auipc	a0,0x5
    1b20:	c2450513          	addi	a0,a0,-988 # 6740 <malloc+0xe3a>
    1b24:	00004097          	auipc	ra,0x4
    1b28:	d24080e7          	jalr	-732(ra) # 5848 <printf>
      exit(1);
    1b2c:	4505                	li	a0,1
    1b2e:	00004097          	auipc	ra,0x4
    1b32:	9a2080e7          	jalr	-1630(ra) # 54d0 <exit>

0000000000001b36 <reparent2>:
{
    1b36:	1101                	addi	sp,sp,-32
    1b38:	ec06                	sd	ra,24(sp)
    1b3a:	e822                	sd	s0,16(sp)
    1b3c:	e426                	sd	s1,8(sp)
    1b3e:	1000                	addi	s0,sp,32
    1b40:	32000493          	li	s1,800
    int pid1 = fork();
    1b44:	00004097          	auipc	ra,0x4
    1b48:	984080e7          	jalr	-1660(ra) # 54c8 <fork>
    if(pid1 < 0){
    1b4c:	00054f63          	bltz	a0,1b6a <reparent2+0x34>
    if(pid1 == 0){
    1b50:	c915                	beqz	a0,1b84 <reparent2+0x4e>
    wait(0);
    1b52:	4501                	li	a0,0
    1b54:	00004097          	auipc	ra,0x4
    1b58:	984080e7          	jalr	-1660(ra) # 54d8 <wait>
  for(int i = 0; i < 800; i++){
    1b5c:	34fd                	addiw	s1,s1,-1
    1b5e:	f0fd                	bnez	s1,1b44 <reparent2+0xe>
  exit(0);
    1b60:	4501                	li	a0,0
    1b62:	00004097          	auipc	ra,0x4
    1b66:	96e080e7          	jalr	-1682(ra) # 54d0 <exit>
      printf("fork failed\n");
    1b6a:	00005517          	auipc	a0,0x5
    1b6e:	df650513          	addi	a0,a0,-522 # 6960 <malloc+0x105a>
    1b72:	00004097          	auipc	ra,0x4
    1b76:	cd6080e7          	jalr	-810(ra) # 5848 <printf>
      exit(1);
    1b7a:	4505                	li	a0,1
    1b7c:	00004097          	auipc	ra,0x4
    1b80:	954080e7          	jalr	-1708(ra) # 54d0 <exit>
      fork();
    1b84:	00004097          	auipc	ra,0x4
    1b88:	944080e7          	jalr	-1724(ra) # 54c8 <fork>
      fork();
    1b8c:	00004097          	auipc	ra,0x4
    1b90:	93c080e7          	jalr	-1732(ra) # 54c8 <fork>
      exit(0);
    1b94:	4501                	li	a0,0
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	93a080e7          	jalr	-1734(ra) # 54d0 <exit>

0000000000001b9e <createdelete>:
{
    1b9e:	7175                	addi	sp,sp,-144
    1ba0:	e506                	sd	ra,136(sp)
    1ba2:	e122                	sd	s0,128(sp)
    1ba4:	fca6                	sd	s1,120(sp)
    1ba6:	f8ca                	sd	s2,112(sp)
    1ba8:	f4ce                	sd	s3,104(sp)
    1baa:	f0d2                	sd	s4,96(sp)
    1bac:	ecd6                	sd	s5,88(sp)
    1bae:	e8da                	sd	s6,80(sp)
    1bb0:	e4de                	sd	s7,72(sp)
    1bb2:	e0e2                	sd	s8,64(sp)
    1bb4:	fc66                	sd	s9,56(sp)
    1bb6:	0900                	addi	s0,sp,144
    1bb8:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bba:	4901                	li	s2,0
    1bbc:	4991                	li	s3,4
    pid = fork();
    1bbe:	00004097          	auipc	ra,0x4
    1bc2:	90a080e7          	jalr	-1782(ra) # 54c8 <fork>
    1bc6:	84aa                	mv	s1,a0
    if(pid < 0){
    1bc8:	02054f63          	bltz	a0,1c06 <createdelete+0x68>
    if(pid == 0){
    1bcc:	c939                	beqz	a0,1c22 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bce:	2905                	addiw	s2,s2,1
    1bd0:	ff3917e3          	bne	s2,s3,1bbe <createdelete+0x20>
    1bd4:	4491                	li	s1,4
    wait(&xstatus);
    1bd6:	f7c40513          	addi	a0,s0,-132
    1bda:	00004097          	auipc	ra,0x4
    1bde:	8fe080e7          	jalr	-1794(ra) # 54d8 <wait>
    if(xstatus != 0)
    1be2:	f7c42903          	lw	s2,-132(s0)
    1be6:	0e091263          	bnez	s2,1cca <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bea:	34fd                	addiw	s1,s1,-1
    1bec:	f4ed                	bnez	s1,1bd6 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bee:	f8040123          	sb	zero,-126(s0)
    1bf2:	03000993          	li	s3,48
    1bf6:	5a7d                	li	s4,-1
    1bf8:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bfc:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bfe:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1c00:	07400a93          	li	s5,116
    1c04:	a29d                	j	1d6a <createdelete+0x1cc>
      printf("fork failed\n", s);
    1c06:	85e6                	mv	a1,s9
    1c08:	00005517          	auipc	a0,0x5
    1c0c:	d5850513          	addi	a0,a0,-680 # 6960 <malloc+0x105a>
    1c10:	00004097          	auipc	ra,0x4
    1c14:	c38080e7          	jalr	-968(ra) # 5848 <printf>
      exit(1);
    1c18:	4505                	li	a0,1
    1c1a:	00004097          	auipc	ra,0x4
    1c1e:	8b6080e7          	jalr	-1866(ra) # 54d0 <exit>
      name[0] = 'p' + pi;
    1c22:	0709091b          	addiw	s2,s2,112
    1c26:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c2a:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c2e:	4951                	li	s2,20
    1c30:	a015                	j	1c54 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c32:	85e6                	mv	a1,s9
    1c34:	00005517          	auipc	a0,0x5
    1c38:	9d450513          	addi	a0,a0,-1580 # 6608 <malloc+0xd02>
    1c3c:	00004097          	auipc	ra,0x4
    1c40:	c0c080e7          	jalr	-1012(ra) # 5848 <printf>
          exit(1);
    1c44:	4505                	li	a0,1
    1c46:	00004097          	auipc	ra,0x4
    1c4a:	88a080e7          	jalr	-1910(ra) # 54d0 <exit>
      for(i = 0; i < N; i++){
    1c4e:	2485                	addiw	s1,s1,1
    1c50:	07248863          	beq	s1,s2,1cc0 <createdelete+0x122>
        name[1] = '0' + i;
    1c54:	0304879b          	addiw	a5,s1,48
    1c58:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c5c:	20200593          	li	a1,514
    1c60:	f8040513          	addi	a0,s0,-128
    1c64:	00004097          	auipc	ra,0x4
    1c68:	8ac080e7          	jalr	-1876(ra) # 5510 <open>
        if(fd < 0){
    1c6c:	fc0543e3          	bltz	a0,1c32 <createdelete+0x94>
        close(fd);
    1c70:	00004097          	auipc	ra,0x4
    1c74:	888080e7          	jalr	-1912(ra) # 54f8 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c78:	fc905be3          	blez	s1,1c4e <createdelete+0xb0>
    1c7c:	0014f793          	andi	a5,s1,1
    1c80:	f7f9                	bnez	a5,1c4e <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c82:	01f4d79b          	srliw	a5,s1,0x1f
    1c86:	9fa5                	addw	a5,a5,s1
    1c88:	4017d79b          	sraiw	a5,a5,0x1
    1c8c:	0307879b          	addiw	a5,a5,48
    1c90:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c94:	f8040513          	addi	a0,s0,-128
    1c98:	00004097          	auipc	ra,0x4
    1c9c:	888080e7          	jalr	-1912(ra) # 5520 <unlink>
    1ca0:	fa0557e3          	bgez	a0,1c4e <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1ca4:	85e6                	mv	a1,s9
    1ca6:	00005517          	auipc	a0,0x5
    1caa:	aba50513          	addi	a0,a0,-1350 # 6760 <malloc+0xe5a>
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	b9a080e7          	jalr	-1126(ra) # 5848 <printf>
            exit(1);
    1cb6:	4505                	li	a0,1
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	818080e7          	jalr	-2024(ra) # 54d0 <exit>
      exit(0);
    1cc0:	4501                	li	a0,0
    1cc2:	00004097          	auipc	ra,0x4
    1cc6:	80e080e7          	jalr	-2034(ra) # 54d0 <exit>
      exit(1);
    1cca:	4505                	li	a0,1
    1ccc:	00004097          	auipc	ra,0x4
    1cd0:	804080e7          	jalr	-2044(ra) # 54d0 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cd4:	f8040613          	addi	a2,s0,-128
    1cd8:	85e6                	mv	a1,s9
    1cda:	00005517          	auipc	a0,0x5
    1cde:	a9e50513          	addi	a0,a0,-1378 # 6778 <malloc+0xe72>
    1ce2:	00004097          	auipc	ra,0x4
    1ce6:	b66080e7          	jalr	-1178(ra) # 5848 <printf>
        exit(1);
    1cea:	4505                	li	a0,1
    1cec:	00003097          	auipc	ra,0x3
    1cf0:	7e4080e7          	jalr	2020(ra) # 54d0 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1cf4:	054b7163          	bgeu	s6,s4,1d36 <createdelete+0x198>
      if(fd >= 0)
    1cf8:	02055a63          	bgez	a0,1d2c <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1cfc:	2485                	addiw	s1,s1,1
    1cfe:	0ff4f493          	andi	s1,s1,255
    1d02:	05548c63          	beq	s1,s5,1d5a <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1d06:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1d0a:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d0e:	4581                	li	a1,0
    1d10:	f8040513          	addi	a0,s0,-128
    1d14:	00003097          	auipc	ra,0x3
    1d18:	7fc080e7          	jalr	2044(ra) # 5510 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d1c:	00090463          	beqz	s2,1d24 <createdelete+0x186>
    1d20:	fd2bdae3          	bge	s7,s2,1cf4 <createdelete+0x156>
    1d24:	fa0548e3          	bltz	a0,1cd4 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d28:	014b7963          	bgeu	s6,s4,1d3a <createdelete+0x19c>
        close(fd);
    1d2c:	00003097          	auipc	ra,0x3
    1d30:	7cc080e7          	jalr	1996(ra) # 54f8 <close>
    1d34:	b7e1                	j	1cfc <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d36:	fc0543e3          	bltz	a0,1cfc <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d3a:	f8040613          	addi	a2,s0,-128
    1d3e:	85e6                	mv	a1,s9
    1d40:	00005517          	auipc	a0,0x5
    1d44:	a6050513          	addi	a0,a0,-1440 # 67a0 <malloc+0xe9a>
    1d48:	00004097          	auipc	ra,0x4
    1d4c:	b00080e7          	jalr	-1280(ra) # 5848 <printf>
        exit(1);
    1d50:	4505                	li	a0,1
    1d52:	00003097          	auipc	ra,0x3
    1d56:	77e080e7          	jalr	1918(ra) # 54d0 <exit>
  for(i = 0; i < N; i++){
    1d5a:	2905                	addiw	s2,s2,1
    1d5c:	2a05                	addiw	s4,s4,1
    1d5e:	2985                	addiw	s3,s3,1
    1d60:	0ff9f993          	andi	s3,s3,255
    1d64:	47d1                	li	a5,20
    1d66:	02f90a63          	beq	s2,a5,1d9a <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d6a:	84e2                	mv	s1,s8
    1d6c:	bf69                	j	1d06 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d6e:	2905                	addiw	s2,s2,1
    1d70:	0ff97913          	andi	s2,s2,255
    1d74:	2985                	addiw	s3,s3,1
    1d76:	0ff9f993          	andi	s3,s3,255
    1d7a:	03490863          	beq	s2,s4,1daa <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d7e:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d80:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d84:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d88:	f8040513          	addi	a0,s0,-128
    1d8c:	00003097          	auipc	ra,0x3
    1d90:	794080e7          	jalr	1940(ra) # 5520 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d94:	34fd                	addiw	s1,s1,-1
    1d96:	f4ed                	bnez	s1,1d80 <createdelete+0x1e2>
    1d98:	bfd9                	j	1d6e <createdelete+0x1d0>
    1d9a:	03000993          	li	s3,48
    1d9e:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1da2:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1da4:	08400a13          	li	s4,132
    1da8:	bfd9                	j	1d7e <createdelete+0x1e0>
}
    1daa:	60aa                	ld	ra,136(sp)
    1dac:	640a                	ld	s0,128(sp)
    1dae:	74e6                	ld	s1,120(sp)
    1db0:	7946                	ld	s2,112(sp)
    1db2:	79a6                	ld	s3,104(sp)
    1db4:	7a06                	ld	s4,96(sp)
    1db6:	6ae6                	ld	s5,88(sp)
    1db8:	6b46                	ld	s6,80(sp)
    1dba:	6ba6                	ld	s7,72(sp)
    1dbc:	6c06                	ld	s8,64(sp)
    1dbe:	7ce2                	ld	s9,56(sp)
    1dc0:	6149                	addi	sp,sp,144
    1dc2:	8082                	ret

0000000000001dc4 <linkunlink>:
{
    1dc4:	711d                	addi	sp,sp,-96
    1dc6:	ec86                	sd	ra,88(sp)
    1dc8:	e8a2                	sd	s0,80(sp)
    1dca:	e4a6                	sd	s1,72(sp)
    1dcc:	e0ca                	sd	s2,64(sp)
    1dce:	fc4e                	sd	s3,56(sp)
    1dd0:	f852                	sd	s4,48(sp)
    1dd2:	f456                	sd	s5,40(sp)
    1dd4:	f05a                	sd	s6,32(sp)
    1dd6:	ec5e                	sd	s7,24(sp)
    1dd8:	e862                	sd	s8,16(sp)
    1dda:	e466                	sd	s9,8(sp)
    1ddc:	1080                	addi	s0,sp,96
    1dde:	84aa                	mv	s1,a0
  unlink("x");
    1de0:	00004517          	auipc	a0,0x4
    1de4:	fc850513          	addi	a0,a0,-56 # 5da8 <malloc+0x4a2>
    1de8:	00003097          	auipc	ra,0x3
    1dec:	738080e7          	jalr	1848(ra) # 5520 <unlink>
  pid = fork();
    1df0:	00003097          	auipc	ra,0x3
    1df4:	6d8080e7          	jalr	1752(ra) # 54c8 <fork>
  if(pid < 0){
    1df8:	02054b63          	bltz	a0,1e2e <linkunlink+0x6a>
    1dfc:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dfe:	4c85                	li	s9,1
    1e00:	e119                	bnez	a0,1e06 <linkunlink+0x42>
    1e02:	06100c93          	li	s9,97
    1e06:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1e0a:	41c659b7          	lui	s3,0x41c65
    1e0e:	e6d9899b          	addiw	s3,s3,-403
    1e12:	690d                	lui	s2,0x3
    1e14:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e18:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e1a:	4b05                	li	s6,1
      unlink("x");
    1e1c:	00004a97          	auipc	s5,0x4
    1e20:	f8ca8a93          	addi	s5,s5,-116 # 5da8 <malloc+0x4a2>
      link("cat", "x");
    1e24:	00005b97          	auipc	s7,0x5
    1e28:	9a4b8b93          	addi	s7,s7,-1628 # 67c8 <malloc+0xec2>
    1e2c:	a091                	j	1e70 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e2e:	85a6                	mv	a1,s1
    1e30:	00004517          	auipc	a0,0x4
    1e34:	74050513          	addi	a0,a0,1856 # 6570 <malloc+0xc6a>
    1e38:	00004097          	auipc	ra,0x4
    1e3c:	a10080e7          	jalr	-1520(ra) # 5848 <printf>
    exit(1);
    1e40:	4505                	li	a0,1
    1e42:	00003097          	auipc	ra,0x3
    1e46:	68e080e7          	jalr	1678(ra) # 54d0 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e4a:	20200593          	li	a1,514
    1e4e:	8556                	mv	a0,s5
    1e50:	00003097          	auipc	ra,0x3
    1e54:	6c0080e7          	jalr	1728(ra) # 5510 <open>
    1e58:	00003097          	auipc	ra,0x3
    1e5c:	6a0080e7          	jalr	1696(ra) # 54f8 <close>
    1e60:	a031                	j	1e6c <linkunlink+0xa8>
      unlink("x");
    1e62:	8556                	mv	a0,s5
    1e64:	00003097          	auipc	ra,0x3
    1e68:	6bc080e7          	jalr	1724(ra) # 5520 <unlink>
  for(i = 0; i < 100; i++){
    1e6c:	34fd                	addiw	s1,s1,-1
    1e6e:	c09d                	beqz	s1,1e94 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e70:	033c87bb          	mulw	a5,s9,s3
    1e74:	012787bb          	addw	a5,a5,s2
    1e78:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e7c:	0347f7bb          	remuw	a5,a5,s4
    1e80:	d7e9                	beqz	a5,1e4a <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e82:	ff6790e3          	bne	a5,s6,1e62 <linkunlink+0x9e>
      link("cat", "x");
    1e86:	85d6                	mv	a1,s5
    1e88:	855e                	mv	a0,s7
    1e8a:	00003097          	auipc	ra,0x3
    1e8e:	6a6080e7          	jalr	1702(ra) # 5530 <link>
    1e92:	bfe9                	j	1e6c <linkunlink+0xa8>
  if(pid)
    1e94:	020c0463          	beqz	s8,1ebc <linkunlink+0xf8>
    wait(0);
    1e98:	4501                	li	a0,0
    1e9a:	00003097          	auipc	ra,0x3
    1e9e:	63e080e7          	jalr	1598(ra) # 54d8 <wait>
}
    1ea2:	60e6                	ld	ra,88(sp)
    1ea4:	6446                	ld	s0,80(sp)
    1ea6:	64a6                	ld	s1,72(sp)
    1ea8:	6906                	ld	s2,64(sp)
    1eaa:	79e2                	ld	s3,56(sp)
    1eac:	7a42                	ld	s4,48(sp)
    1eae:	7aa2                	ld	s5,40(sp)
    1eb0:	7b02                	ld	s6,32(sp)
    1eb2:	6be2                	ld	s7,24(sp)
    1eb4:	6c42                	ld	s8,16(sp)
    1eb6:	6ca2                	ld	s9,8(sp)
    1eb8:	6125                	addi	sp,sp,96
    1eba:	8082                	ret
    exit(0);
    1ebc:	4501                	li	a0,0
    1ebe:	00003097          	auipc	ra,0x3
    1ec2:	612080e7          	jalr	1554(ra) # 54d0 <exit>

0000000000001ec6 <forktest>:
{
    1ec6:	7179                	addi	sp,sp,-48
    1ec8:	f406                	sd	ra,40(sp)
    1eca:	f022                	sd	s0,32(sp)
    1ecc:	ec26                	sd	s1,24(sp)
    1ece:	e84a                	sd	s2,16(sp)
    1ed0:	e44e                	sd	s3,8(sp)
    1ed2:	1800                	addi	s0,sp,48
    1ed4:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1ed6:	4481                	li	s1,0
    1ed8:	3e800913          	li	s2,1000
    pid = fork();
    1edc:	00003097          	auipc	ra,0x3
    1ee0:	5ec080e7          	jalr	1516(ra) # 54c8 <fork>
    if(pid < 0)
    1ee4:	02054863          	bltz	a0,1f14 <forktest+0x4e>
    if(pid == 0)
    1ee8:	c115                	beqz	a0,1f0c <forktest+0x46>
  for(n=0; n<N; n++){
    1eea:	2485                	addiw	s1,s1,1
    1eec:	ff2498e3          	bne	s1,s2,1edc <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1ef0:	85ce                	mv	a1,s3
    1ef2:	00005517          	auipc	a0,0x5
    1ef6:	8f650513          	addi	a0,a0,-1802 # 67e8 <malloc+0xee2>
    1efa:	00004097          	auipc	ra,0x4
    1efe:	94e080e7          	jalr	-1714(ra) # 5848 <printf>
    exit(1);
    1f02:	4505                	li	a0,1
    1f04:	00003097          	auipc	ra,0x3
    1f08:	5cc080e7          	jalr	1484(ra) # 54d0 <exit>
      exit(0);
    1f0c:	00003097          	auipc	ra,0x3
    1f10:	5c4080e7          	jalr	1476(ra) # 54d0 <exit>
  if (n == 0) {
    1f14:	cc9d                	beqz	s1,1f52 <forktest+0x8c>
  if(n == N){
    1f16:	3e800793          	li	a5,1000
    1f1a:	fcf48be3          	beq	s1,a5,1ef0 <forktest+0x2a>
  for(; n > 0; n--){
    1f1e:	00905b63          	blez	s1,1f34 <forktest+0x6e>
    if(wait(0) < 0){
    1f22:	4501                	li	a0,0
    1f24:	00003097          	auipc	ra,0x3
    1f28:	5b4080e7          	jalr	1460(ra) # 54d8 <wait>
    1f2c:	04054163          	bltz	a0,1f6e <forktest+0xa8>
  for(; n > 0; n--){
    1f30:	34fd                	addiw	s1,s1,-1
    1f32:	f8e5                	bnez	s1,1f22 <forktest+0x5c>
  if(wait(0) != -1){
    1f34:	4501                	li	a0,0
    1f36:	00003097          	auipc	ra,0x3
    1f3a:	5a2080e7          	jalr	1442(ra) # 54d8 <wait>
    1f3e:	57fd                	li	a5,-1
    1f40:	04f51563          	bne	a0,a5,1f8a <forktest+0xc4>
}
    1f44:	70a2                	ld	ra,40(sp)
    1f46:	7402                	ld	s0,32(sp)
    1f48:	64e2                	ld	s1,24(sp)
    1f4a:	6942                	ld	s2,16(sp)
    1f4c:	69a2                	ld	s3,8(sp)
    1f4e:	6145                	addi	sp,sp,48
    1f50:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1f52:	85ce                	mv	a1,s3
    1f54:	00005517          	auipc	a0,0x5
    1f58:	87c50513          	addi	a0,a0,-1924 # 67d0 <malloc+0xeca>
    1f5c:	00004097          	auipc	ra,0x4
    1f60:	8ec080e7          	jalr	-1812(ra) # 5848 <printf>
    exit(1);
    1f64:	4505                	li	a0,1
    1f66:	00003097          	auipc	ra,0x3
    1f6a:	56a080e7          	jalr	1386(ra) # 54d0 <exit>
      printf("%s: wait stopped early\n", s);
    1f6e:	85ce                	mv	a1,s3
    1f70:	00005517          	auipc	a0,0x5
    1f74:	8a050513          	addi	a0,a0,-1888 # 6810 <malloc+0xf0a>
    1f78:	00004097          	auipc	ra,0x4
    1f7c:	8d0080e7          	jalr	-1840(ra) # 5848 <printf>
      exit(1);
    1f80:	4505                	li	a0,1
    1f82:	00003097          	auipc	ra,0x3
    1f86:	54e080e7          	jalr	1358(ra) # 54d0 <exit>
    printf("%s: wait got too many\n", s);
    1f8a:	85ce                	mv	a1,s3
    1f8c:	00005517          	auipc	a0,0x5
    1f90:	89c50513          	addi	a0,a0,-1892 # 6828 <malloc+0xf22>
    1f94:	00004097          	auipc	ra,0x4
    1f98:	8b4080e7          	jalr	-1868(ra) # 5848 <printf>
    exit(1);
    1f9c:	4505                	li	a0,1
    1f9e:	00003097          	auipc	ra,0x3
    1fa2:	532080e7          	jalr	1330(ra) # 54d0 <exit>

0000000000001fa6 <kernmem>:
{
    1fa6:	715d                	addi	sp,sp,-80
    1fa8:	e486                	sd	ra,72(sp)
    1faa:	e0a2                	sd	s0,64(sp)
    1fac:	fc26                	sd	s1,56(sp)
    1fae:	f84a                	sd	s2,48(sp)
    1fb0:	f44e                	sd	s3,40(sp)
    1fb2:	f052                	sd	s4,32(sp)
    1fb4:	ec56                	sd	s5,24(sp)
    1fb6:	0880                	addi	s0,sp,80
    1fb8:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fba:	4485                	li	s1,1
    1fbc:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1fbe:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fc0:	69b1                	lui	s3,0xc
    1fc2:	35098993          	addi	s3,s3,848 # c350 <buf+0xa20>
    1fc6:	1003d937          	lui	s2,0x1003d
    1fca:	090e                	slli	s2,s2,0x3
    1fcc:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002eb40>
    pid = fork();
    1fd0:	00003097          	auipc	ra,0x3
    1fd4:	4f8080e7          	jalr	1272(ra) # 54c8 <fork>
    if(pid < 0){
    1fd8:	02054963          	bltz	a0,200a <kernmem+0x64>
    if(pid == 0){
    1fdc:	c529                	beqz	a0,2026 <kernmem+0x80>
    wait(&xstatus);
    1fde:	fbc40513          	addi	a0,s0,-68
    1fe2:	00003097          	auipc	ra,0x3
    1fe6:	4f6080e7          	jalr	1270(ra) # 54d8 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1fea:	fbc42783          	lw	a5,-68(s0)
    1fee:	05579d63          	bne	a5,s5,2048 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1ff2:	94ce                	add	s1,s1,s3
    1ff4:	fd249ee3          	bne	s1,s2,1fd0 <kernmem+0x2a>
}
    1ff8:	60a6                	ld	ra,72(sp)
    1ffa:	6406                	ld	s0,64(sp)
    1ffc:	74e2                	ld	s1,56(sp)
    1ffe:	7942                	ld	s2,48(sp)
    2000:	79a2                	ld	s3,40(sp)
    2002:	7a02                	ld	s4,32(sp)
    2004:	6ae2                	ld	s5,24(sp)
    2006:	6161                	addi	sp,sp,80
    2008:	8082                	ret
      printf("%s: fork failed\n", s);
    200a:	85d2                	mv	a1,s4
    200c:	00004517          	auipc	a0,0x4
    2010:	56450513          	addi	a0,a0,1380 # 6570 <malloc+0xc6a>
    2014:	00004097          	auipc	ra,0x4
    2018:	834080e7          	jalr	-1996(ra) # 5848 <printf>
      exit(1);
    201c:	4505                	li	a0,1
    201e:	00003097          	auipc	ra,0x3
    2022:	4b2080e7          	jalr	1202(ra) # 54d0 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2026:	0004c683          	lbu	a3,0(s1)
    202a:	8626                	mv	a2,s1
    202c:	85d2                	mv	a1,s4
    202e:	00005517          	auipc	a0,0x5
    2032:	81250513          	addi	a0,a0,-2030 # 6840 <malloc+0xf3a>
    2036:	00004097          	auipc	ra,0x4
    203a:	812080e7          	jalr	-2030(ra) # 5848 <printf>
      exit(1);
    203e:	4505                	li	a0,1
    2040:	00003097          	auipc	ra,0x3
    2044:	490080e7          	jalr	1168(ra) # 54d0 <exit>
      exit(1);
    2048:	4505                	li	a0,1
    204a:	00003097          	auipc	ra,0x3
    204e:	486080e7          	jalr	1158(ra) # 54d0 <exit>

0000000000002052 <bigargtest>:
{
    2052:	7179                	addi	sp,sp,-48
    2054:	f406                	sd	ra,40(sp)
    2056:	f022                	sd	s0,32(sp)
    2058:	ec26                	sd	s1,24(sp)
    205a:	1800                	addi	s0,sp,48
    205c:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    205e:	00005517          	auipc	a0,0x5
    2062:	80250513          	addi	a0,a0,-2046 # 6860 <malloc+0xf5a>
    2066:	00003097          	auipc	ra,0x3
    206a:	4ba080e7          	jalr	1210(ra) # 5520 <unlink>
  pid = fork();
    206e:	00003097          	auipc	ra,0x3
    2072:	45a080e7          	jalr	1114(ra) # 54c8 <fork>
  if(pid == 0){
    2076:	c121                	beqz	a0,20b6 <bigargtest+0x64>
  } else if(pid < 0){
    2078:	0a054063          	bltz	a0,2118 <bigargtest+0xc6>
  wait(&xstatus);
    207c:	fdc40513          	addi	a0,s0,-36
    2080:	00003097          	auipc	ra,0x3
    2084:	458080e7          	jalr	1112(ra) # 54d8 <wait>
  if(xstatus != 0)
    2088:	fdc42503          	lw	a0,-36(s0)
    208c:	e545                	bnez	a0,2134 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    208e:	4581                	li	a1,0
    2090:	00004517          	auipc	a0,0x4
    2094:	7d050513          	addi	a0,a0,2000 # 6860 <malloc+0xf5a>
    2098:	00003097          	auipc	ra,0x3
    209c:	478080e7          	jalr	1144(ra) # 5510 <open>
  if(fd < 0){
    20a0:	08054e63          	bltz	a0,213c <bigargtest+0xea>
  close(fd);
    20a4:	00003097          	auipc	ra,0x3
    20a8:	454080e7          	jalr	1108(ra) # 54f8 <close>
}
    20ac:	70a2                	ld	ra,40(sp)
    20ae:	7402                	ld	s0,32(sp)
    20b0:	64e2                	ld	s1,24(sp)
    20b2:	6145                	addi	sp,sp,48
    20b4:	8082                	ret
    20b6:	00006797          	auipc	a5,0x6
    20ba:	06278793          	addi	a5,a5,98 # 8118 <args.1807>
    20be:	00006697          	auipc	a3,0x6
    20c2:	15268693          	addi	a3,a3,338 # 8210 <args.1807+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    20c6:	00004717          	auipc	a4,0x4
    20ca:	7aa70713          	addi	a4,a4,1962 # 6870 <malloc+0xf6a>
    20ce:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    20d0:	07a1                	addi	a5,a5,8
    20d2:	fed79ee3          	bne	a5,a3,20ce <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    20d6:	00006597          	auipc	a1,0x6
    20da:	04258593          	addi	a1,a1,66 # 8118 <args.1807>
    20de:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    20e2:	00004517          	auipc	a0,0x4
    20e6:	c5650513          	addi	a0,a0,-938 # 5d38 <malloc+0x432>
    20ea:	00003097          	auipc	ra,0x3
    20ee:	41e080e7          	jalr	1054(ra) # 5508 <exec>
    fd = open("bigarg-ok", O_CREATE);
    20f2:	20000593          	li	a1,512
    20f6:	00004517          	auipc	a0,0x4
    20fa:	76a50513          	addi	a0,a0,1898 # 6860 <malloc+0xf5a>
    20fe:	00003097          	auipc	ra,0x3
    2102:	412080e7          	jalr	1042(ra) # 5510 <open>
    close(fd);
    2106:	00003097          	auipc	ra,0x3
    210a:	3f2080e7          	jalr	1010(ra) # 54f8 <close>
    exit(0);
    210e:	4501                	li	a0,0
    2110:	00003097          	auipc	ra,0x3
    2114:	3c0080e7          	jalr	960(ra) # 54d0 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2118:	85a6                	mv	a1,s1
    211a:	00005517          	auipc	a0,0x5
    211e:	83650513          	addi	a0,a0,-1994 # 6950 <malloc+0x104a>
    2122:	00003097          	auipc	ra,0x3
    2126:	726080e7          	jalr	1830(ra) # 5848 <printf>
    exit(1);
    212a:	4505                	li	a0,1
    212c:	00003097          	auipc	ra,0x3
    2130:	3a4080e7          	jalr	932(ra) # 54d0 <exit>
    exit(xstatus);
    2134:	00003097          	auipc	ra,0x3
    2138:	39c080e7          	jalr	924(ra) # 54d0 <exit>
    printf("%s: bigarg test failed!\n", s);
    213c:	85a6                	mv	a1,s1
    213e:	00005517          	auipc	a0,0x5
    2142:	83250513          	addi	a0,a0,-1998 # 6970 <malloc+0x106a>
    2146:	00003097          	auipc	ra,0x3
    214a:	702080e7          	jalr	1794(ra) # 5848 <printf>
    exit(1);
    214e:	4505                	li	a0,1
    2150:	00003097          	auipc	ra,0x3
    2154:	380080e7          	jalr	896(ra) # 54d0 <exit>

0000000000002158 <stacktest>:
{
    2158:	7179                	addi	sp,sp,-48
    215a:	f406                	sd	ra,40(sp)
    215c:	f022                	sd	s0,32(sp)
    215e:	ec26                	sd	s1,24(sp)
    2160:	1800                	addi	s0,sp,48
    2162:	84aa                	mv	s1,a0
  pid = fork();
    2164:	00003097          	auipc	ra,0x3
    2168:	364080e7          	jalr	868(ra) # 54c8 <fork>
  if(pid == 0) {
    216c:	c115                	beqz	a0,2190 <stacktest+0x38>
  } else if(pid < 0){
    216e:	04054463          	bltz	a0,21b6 <stacktest+0x5e>
  wait(&xstatus);
    2172:	fdc40513          	addi	a0,s0,-36
    2176:	00003097          	auipc	ra,0x3
    217a:	362080e7          	jalr	866(ra) # 54d8 <wait>
  if(xstatus == -1)  // kernel killed child?
    217e:	fdc42503          	lw	a0,-36(s0)
    2182:	57fd                	li	a5,-1
    2184:	04f50763          	beq	a0,a5,21d2 <stacktest+0x7a>
    exit(xstatus);
    2188:	00003097          	auipc	ra,0x3
    218c:	348080e7          	jalr	840(ra) # 54d0 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    2190:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    2192:	77fd                	lui	a5,0xfffff
    2194:	97ba                	add	a5,a5,a4
    2196:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff06c0>
    219a:	85a6                	mv	a1,s1
    219c:	00004517          	auipc	a0,0x4
    21a0:	7f450513          	addi	a0,a0,2036 # 6990 <malloc+0x108a>
    21a4:	00003097          	auipc	ra,0x3
    21a8:	6a4080e7          	jalr	1700(ra) # 5848 <printf>
    exit(1);
    21ac:	4505                	li	a0,1
    21ae:	00003097          	auipc	ra,0x3
    21b2:	322080e7          	jalr	802(ra) # 54d0 <exit>
    printf("%s: fork failed\n", s);
    21b6:	85a6                	mv	a1,s1
    21b8:	00004517          	auipc	a0,0x4
    21bc:	3b850513          	addi	a0,a0,952 # 6570 <malloc+0xc6a>
    21c0:	00003097          	auipc	ra,0x3
    21c4:	688080e7          	jalr	1672(ra) # 5848 <printf>
    exit(1);
    21c8:	4505                	li	a0,1
    21ca:	00003097          	auipc	ra,0x3
    21ce:	306080e7          	jalr	774(ra) # 54d0 <exit>
    exit(0);
    21d2:	4501                	li	a0,0
    21d4:	00003097          	auipc	ra,0x3
    21d8:	2fc080e7          	jalr	764(ra) # 54d0 <exit>

00000000000021dc <copyinstr3>:
{
    21dc:	7179                	addi	sp,sp,-48
    21de:	f406                	sd	ra,40(sp)
    21e0:	f022                	sd	s0,32(sp)
    21e2:	ec26                	sd	s1,24(sp)
    21e4:	1800                	addi	s0,sp,48
  sbrk(8192);
    21e6:	6509                	lui	a0,0x2
    21e8:	00003097          	auipc	ra,0x3
    21ec:	370080e7          	jalr	880(ra) # 5558 <sbrk>
  uint64 top = (uint64) sbrk(0);
    21f0:	4501                	li	a0,0
    21f2:	00003097          	auipc	ra,0x3
    21f6:	366080e7          	jalr	870(ra) # 5558 <sbrk>
  if((top % PGSIZE) != 0){
    21fa:	03451793          	slli	a5,a0,0x34
    21fe:	e3c9                	bnez	a5,2280 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2200:	4501                	li	a0,0
    2202:	00003097          	auipc	ra,0x3
    2206:	356080e7          	jalr	854(ra) # 5558 <sbrk>
  if(top % PGSIZE){
    220a:	03451793          	slli	a5,a0,0x34
    220e:	e3d9                	bnez	a5,2294 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2210:	fff50493          	addi	s1,a0,-1 # 1fff <kernmem+0x59>
  *b = 'x';
    2214:	07800793          	li	a5,120
    2218:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    221c:	8526                	mv	a0,s1
    221e:	00003097          	auipc	ra,0x3
    2222:	302080e7          	jalr	770(ra) # 5520 <unlink>
  if(ret != -1){
    2226:	57fd                	li	a5,-1
    2228:	08f51363          	bne	a0,a5,22ae <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    222c:	20100593          	li	a1,513
    2230:	8526                	mv	a0,s1
    2232:	00003097          	auipc	ra,0x3
    2236:	2de080e7          	jalr	734(ra) # 5510 <open>
  if(fd != -1){
    223a:	57fd                	li	a5,-1
    223c:	08f51863          	bne	a0,a5,22cc <copyinstr3+0xf0>
  ret = link(b, b);
    2240:	85a6                	mv	a1,s1
    2242:	8526                	mv	a0,s1
    2244:	00003097          	auipc	ra,0x3
    2248:	2ec080e7          	jalr	748(ra) # 5530 <link>
  if(ret != -1){
    224c:	57fd                	li	a5,-1
    224e:	08f51e63          	bne	a0,a5,22ea <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2252:	00005797          	auipc	a5,0x5
    2256:	3d678793          	addi	a5,a5,982 # 7628 <malloc+0x1d22>
    225a:	fcf43823          	sd	a5,-48(s0)
    225e:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2262:	fd040593          	addi	a1,s0,-48
    2266:	8526                	mv	a0,s1
    2268:	00003097          	auipc	ra,0x3
    226c:	2a0080e7          	jalr	672(ra) # 5508 <exec>
  if(ret != -1){
    2270:	57fd                	li	a5,-1
    2272:	08f51c63          	bne	a0,a5,230a <copyinstr3+0x12e>
}
    2276:	70a2                	ld	ra,40(sp)
    2278:	7402                	ld	s0,32(sp)
    227a:	64e2                	ld	s1,24(sp)
    227c:	6145                	addi	sp,sp,48
    227e:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2280:	0347d513          	srli	a0,a5,0x34
    2284:	6785                	lui	a5,0x1
    2286:	40a7853b          	subw	a0,a5,a0
    228a:	00003097          	auipc	ra,0x3
    228e:	2ce080e7          	jalr	718(ra) # 5558 <sbrk>
    2292:	b7bd                	j	2200 <copyinstr3+0x24>
    printf("oops\n");
    2294:	00004517          	auipc	a0,0x4
    2298:	72450513          	addi	a0,a0,1828 # 69b8 <malloc+0x10b2>
    229c:	00003097          	auipc	ra,0x3
    22a0:	5ac080e7          	jalr	1452(ra) # 5848 <printf>
    exit(1);
    22a4:	4505                	li	a0,1
    22a6:	00003097          	auipc	ra,0x3
    22aa:	22a080e7          	jalr	554(ra) # 54d0 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    22ae:	862a                	mv	a2,a0
    22b0:	85a6                	mv	a1,s1
    22b2:	00004517          	auipc	a0,0x4
    22b6:	1de50513          	addi	a0,a0,478 # 6490 <malloc+0xb8a>
    22ba:	00003097          	auipc	ra,0x3
    22be:	58e080e7          	jalr	1422(ra) # 5848 <printf>
    exit(1);
    22c2:	4505                	li	a0,1
    22c4:	00003097          	auipc	ra,0x3
    22c8:	20c080e7          	jalr	524(ra) # 54d0 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    22cc:	862a                	mv	a2,a0
    22ce:	85a6                	mv	a1,s1
    22d0:	00004517          	auipc	a0,0x4
    22d4:	1e050513          	addi	a0,a0,480 # 64b0 <malloc+0xbaa>
    22d8:	00003097          	auipc	ra,0x3
    22dc:	570080e7          	jalr	1392(ra) # 5848 <printf>
    exit(1);
    22e0:	4505                	li	a0,1
    22e2:	00003097          	auipc	ra,0x3
    22e6:	1ee080e7          	jalr	494(ra) # 54d0 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    22ea:	86aa                	mv	a3,a0
    22ec:	8626                	mv	a2,s1
    22ee:	85a6                	mv	a1,s1
    22f0:	00004517          	auipc	a0,0x4
    22f4:	1e050513          	addi	a0,a0,480 # 64d0 <malloc+0xbca>
    22f8:	00003097          	auipc	ra,0x3
    22fc:	550080e7          	jalr	1360(ra) # 5848 <printf>
    exit(1);
    2300:	4505                	li	a0,1
    2302:	00003097          	auipc	ra,0x3
    2306:	1ce080e7          	jalr	462(ra) # 54d0 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    230a:	567d                	li	a2,-1
    230c:	85a6                	mv	a1,s1
    230e:	00004517          	auipc	a0,0x4
    2312:	1ea50513          	addi	a0,a0,490 # 64f8 <malloc+0xbf2>
    2316:	00003097          	auipc	ra,0x3
    231a:	532080e7          	jalr	1330(ra) # 5848 <printf>
    exit(1);
    231e:	4505                	li	a0,1
    2320:	00003097          	auipc	ra,0x3
    2324:	1b0080e7          	jalr	432(ra) # 54d0 <exit>

0000000000002328 <rwsbrk>:
{
    2328:	1101                	addi	sp,sp,-32
    232a:	ec06                	sd	ra,24(sp)
    232c:	e822                	sd	s0,16(sp)
    232e:	e426                	sd	s1,8(sp)
    2330:	e04a                	sd	s2,0(sp)
    2332:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2334:	6509                	lui	a0,0x2
    2336:	00003097          	auipc	ra,0x3
    233a:	222080e7          	jalr	546(ra) # 5558 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    233e:	57fd                	li	a5,-1
    2340:	06f50363          	beq	a0,a5,23a6 <rwsbrk+0x7e>
    2344:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2346:	7579                	lui	a0,0xffffe
    2348:	00003097          	auipc	ra,0x3
    234c:	210080e7          	jalr	528(ra) # 5558 <sbrk>
    2350:	57fd                	li	a5,-1
    2352:	06f50763          	beq	a0,a5,23c0 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2356:	20100593          	li	a1,513
    235a:	00003517          	auipc	a0,0x3
    235e:	6fe50513          	addi	a0,a0,1790 # 5a58 <malloc+0x152>
    2362:	00003097          	auipc	ra,0x3
    2366:	1ae080e7          	jalr	430(ra) # 5510 <open>
    236a:	892a                	mv	s2,a0
  if(fd < 0){
    236c:	06054763          	bltz	a0,23da <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    2370:	6505                	lui	a0,0x1
    2372:	94aa                	add	s1,s1,a0
    2374:	40000613          	li	a2,1024
    2378:	85a6                	mv	a1,s1
    237a:	854a                	mv	a0,s2
    237c:	00003097          	auipc	ra,0x3
    2380:	174080e7          	jalr	372(ra) # 54f0 <write>
    2384:	862a                	mv	a2,a0
  if(n >= 0){
    2386:	06054763          	bltz	a0,23f4 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    238a:	85a6                	mv	a1,s1
    238c:	00004517          	auipc	a0,0x4
    2390:	68450513          	addi	a0,a0,1668 # 6a10 <malloc+0x110a>
    2394:	00003097          	auipc	ra,0x3
    2398:	4b4080e7          	jalr	1204(ra) # 5848 <printf>
    exit(1);
    239c:	4505                	li	a0,1
    239e:	00003097          	auipc	ra,0x3
    23a2:	132080e7          	jalr	306(ra) # 54d0 <exit>
    printf("sbrk(rwsbrk) failed\n");
    23a6:	00004517          	auipc	a0,0x4
    23aa:	61a50513          	addi	a0,a0,1562 # 69c0 <malloc+0x10ba>
    23ae:	00003097          	auipc	ra,0x3
    23b2:	49a080e7          	jalr	1178(ra) # 5848 <printf>
    exit(1);
    23b6:	4505                	li	a0,1
    23b8:	00003097          	auipc	ra,0x3
    23bc:	118080e7          	jalr	280(ra) # 54d0 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    23c0:	00004517          	auipc	a0,0x4
    23c4:	61850513          	addi	a0,a0,1560 # 69d8 <malloc+0x10d2>
    23c8:	00003097          	auipc	ra,0x3
    23cc:	480080e7          	jalr	1152(ra) # 5848 <printf>
    exit(1);
    23d0:	4505                	li	a0,1
    23d2:	00003097          	auipc	ra,0x3
    23d6:	0fe080e7          	jalr	254(ra) # 54d0 <exit>
    printf("open(rwsbrk) failed\n");
    23da:	00004517          	auipc	a0,0x4
    23de:	61e50513          	addi	a0,a0,1566 # 69f8 <malloc+0x10f2>
    23e2:	00003097          	auipc	ra,0x3
    23e6:	466080e7          	jalr	1126(ra) # 5848 <printf>
    exit(1);
    23ea:	4505                	li	a0,1
    23ec:	00003097          	auipc	ra,0x3
    23f0:	0e4080e7          	jalr	228(ra) # 54d0 <exit>
  close(fd);
    23f4:	854a                	mv	a0,s2
    23f6:	00003097          	auipc	ra,0x3
    23fa:	102080e7          	jalr	258(ra) # 54f8 <close>
  unlink("rwsbrk");
    23fe:	00003517          	auipc	a0,0x3
    2402:	65a50513          	addi	a0,a0,1626 # 5a58 <malloc+0x152>
    2406:	00003097          	auipc	ra,0x3
    240a:	11a080e7          	jalr	282(ra) # 5520 <unlink>
  fd = open("README", O_RDONLY);
    240e:	4581                	li	a1,0
    2410:	00004517          	auipc	a0,0x4
    2414:	ac050513          	addi	a0,a0,-1344 # 5ed0 <malloc+0x5ca>
    2418:	00003097          	auipc	ra,0x3
    241c:	0f8080e7          	jalr	248(ra) # 5510 <open>
    2420:	892a                	mv	s2,a0
  if(fd < 0){
    2422:	02054963          	bltz	a0,2454 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    2426:	4629                	li	a2,10
    2428:	85a6                	mv	a1,s1
    242a:	00003097          	auipc	ra,0x3
    242e:	0be080e7          	jalr	190(ra) # 54e8 <read>
    2432:	862a                	mv	a2,a0
  if(n >= 0){
    2434:	02054d63          	bltz	a0,246e <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2438:	85a6                	mv	a1,s1
    243a:	00004517          	auipc	a0,0x4
    243e:	60650513          	addi	a0,a0,1542 # 6a40 <malloc+0x113a>
    2442:	00003097          	auipc	ra,0x3
    2446:	406080e7          	jalr	1030(ra) # 5848 <printf>
    exit(1);
    244a:	4505                	li	a0,1
    244c:	00003097          	auipc	ra,0x3
    2450:	084080e7          	jalr	132(ra) # 54d0 <exit>
    printf("open(rwsbrk) failed\n");
    2454:	00004517          	auipc	a0,0x4
    2458:	5a450513          	addi	a0,a0,1444 # 69f8 <malloc+0x10f2>
    245c:	00003097          	auipc	ra,0x3
    2460:	3ec080e7          	jalr	1004(ra) # 5848 <printf>
    exit(1);
    2464:	4505                	li	a0,1
    2466:	00003097          	auipc	ra,0x3
    246a:	06a080e7          	jalr	106(ra) # 54d0 <exit>
  close(fd);
    246e:	854a                	mv	a0,s2
    2470:	00003097          	auipc	ra,0x3
    2474:	088080e7          	jalr	136(ra) # 54f8 <close>
  exit(0);
    2478:	4501                	li	a0,0
    247a:	00003097          	auipc	ra,0x3
    247e:	056080e7          	jalr	86(ra) # 54d0 <exit>

0000000000002482 <sbrkbasic>:
{
    2482:	715d                	addi	sp,sp,-80
    2484:	e486                	sd	ra,72(sp)
    2486:	e0a2                	sd	s0,64(sp)
    2488:	fc26                	sd	s1,56(sp)
    248a:	f84a                	sd	s2,48(sp)
    248c:	f44e                	sd	s3,40(sp)
    248e:	f052                	sd	s4,32(sp)
    2490:	ec56                	sd	s5,24(sp)
    2492:	0880                	addi	s0,sp,80
    2494:	8a2a                	mv	s4,a0
  pid = fork();
    2496:	00003097          	auipc	ra,0x3
    249a:	032080e7          	jalr	50(ra) # 54c8 <fork>
  if(pid < 0){
    249e:	02054c63          	bltz	a0,24d6 <sbrkbasic+0x54>
  if(pid == 0){
    24a2:	ed21                	bnez	a0,24fa <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    24a4:	40000537          	lui	a0,0x40000
    24a8:	00003097          	auipc	ra,0x3
    24ac:	0b0080e7          	jalr	176(ra) # 5558 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    24b0:	57fd                	li	a5,-1
    24b2:	02f50f63          	beq	a0,a5,24f0 <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24b6:	400007b7          	lui	a5,0x40000
    24ba:	97aa                	add	a5,a5,a0
      *b = 99;
    24bc:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    24c0:	6705                	lui	a4,0x1
      *b = 99;
    24c2:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff16c0>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24c6:	953a                	add	a0,a0,a4
    24c8:	fef51de3          	bne	a0,a5,24c2 <sbrkbasic+0x40>
    exit(1);
    24cc:	4505                	li	a0,1
    24ce:	00003097          	auipc	ra,0x3
    24d2:	002080e7          	jalr	2(ra) # 54d0 <exit>
    printf("fork failed in sbrkbasic\n");
    24d6:	00004517          	auipc	a0,0x4
    24da:	59250513          	addi	a0,a0,1426 # 6a68 <malloc+0x1162>
    24de:	00003097          	auipc	ra,0x3
    24e2:	36a080e7          	jalr	874(ra) # 5848 <printf>
    exit(1);
    24e6:	4505                	li	a0,1
    24e8:	00003097          	auipc	ra,0x3
    24ec:	fe8080e7          	jalr	-24(ra) # 54d0 <exit>
      exit(0);
    24f0:	4501                	li	a0,0
    24f2:	00003097          	auipc	ra,0x3
    24f6:	fde080e7          	jalr	-34(ra) # 54d0 <exit>
  wait(&xstatus);
    24fa:	fbc40513          	addi	a0,s0,-68
    24fe:	00003097          	auipc	ra,0x3
    2502:	fda080e7          	jalr	-38(ra) # 54d8 <wait>
  if(xstatus == 1){
    2506:	fbc42703          	lw	a4,-68(s0)
    250a:	4785                	li	a5,1
    250c:	00f70e63          	beq	a4,a5,2528 <sbrkbasic+0xa6>
  a = sbrk(0);
    2510:	4501                	li	a0,0
    2512:	00003097          	auipc	ra,0x3
    2516:	046080e7          	jalr	70(ra) # 5558 <sbrk>
    251a:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    251c:	4901                	li	s2,0
    *b = 1;
    251e:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    2520:	6985                	lui	s3,0x1
    2522:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1c2>
    2526:	a005                	j	2546 <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    2528:	85d2                	mv	a1,s4
    252a:	00004517          	auipc	a0,0x4
    252e:	55e50513          	addi	a0,a0,1374 # 6a88 <malloc+0x1182>
    2532:	00003097          	auipc	ra,0x3
    2536:	316080e7          	jalr	790(ra) # 5848 <printf>
    exit(1);
    253a:	4505                	li	a0,1
    253c:	00003097          	auipc	ra,0x3
    2540:	f94080e7          	jalr	-108(ra) # 54d0 <exit>
    a = b + 1;
    2544:	84be                	mv	s1,a5
    b = sbrk(1);
    2546:	4505                	li	a0,1
    2548:	00003097          	auipc	ra,0x3
    254c:	010080e7          	jalr	16(ra) # 5558 <sbrk>
    if(b != a){
    2550:	04951b63          	bne	a0,s1,25a6 <sbrkbasic+0x124>
    *b = 1;
    2554:	01548023          	sb	s5,0(s1)
    a = b + 1;
    2558:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    255c:	2905                	addiw	s2,s2,1
    255e:	ff3913e3          	bne	s2,s3,2544 <sbrkbasic+0xc2>
  pid = fork();
    2562:	00003097          	auipc	ra,0x3
    2566:	f66080e7          	jalr	-154(ra) # 54c8 <fork>
    256a:	892a                	mv	s2,a0
  if(pid < 0){
    256c:	04054d63          	bltz	a0,25c6 <sbrkbasic+0x144>
  c = sbrk(1);
    2570:	4505                	li	a0,1
    2572:	00003097          	auipc	ra,0x3
    2576:	fe6080e7          	jalr	-26(ra) # 5558 <sbrk>
  c = sbrk(1);
    257a:	4505                	li	a0,1
    257c:	00003097          	auipc	ra,0x3
    2580:	fdc080e7          	jalr	-36(ra) # 5558 <sbrk>
  if(c != a + 1){
    2584:	0489                	addi	s1,s1,2
    2586:	04a48e63          	beq	s1,a0,25e2 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    258a:	85d2                	mv	a1,s4
    258c:	00004517          	auipc	a0,0x4
    2590:	55c50513          	addi	a0,a0,1372 # 6ae8 <malloc+0x11e2>
    2594:	00003097          	auipc	ra,0x3
    2598:	2b4080e7          	jalr	692(ra) # 5848 <printf>
    exit(1);
    259c:	4505                	li	a0,1
    259e:	00003097          	auipc	ra,0x3
    25a2:	f32080e7          	jalr	-206(ra) # 54d0 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    25a6:	86aa                	mv	a3,a0
    25a8:	8626                	mv	a2,s1
    25aa:	85ca                	mv	a1,s2
    25ac:	00004517          	auipc	a0,0x4
    25b0:	4fc50513          	addi	a0,a0,1276 # 6aa8 <malloc+0x11a2>
    25b4:	00003097          	auipc	ra,0x3
    25b8:	294080e7          	jalr	660(ra) # 5848 <printf>
      exit(1);
    25bc:	4505                	li	a0,1
    25be:	00003097          	auipc	ra,0x3
    25c2:	f12080e7          	jalr	-238(ra) # 54d0 <exit>
    printf("%s: sbrk test fork failed\n", s);
    25c6:	85d2                	mv	a1,s4
    25c8:	00004517          	auipc	a0,0x4
    25cc:	50050513          	addi	a0,a0,1280 # 6ac8 <malloc+0x11c2>
    25d0:	00003097          	auipc	ra,0x3
    25d4:	278080e7          	jalr	632(ra) # 5848 <printf>
    exit(1);
    25d8:	4505                	li	a0,1
    25da:	00003097          	auipc	ra,0x3
    25de:	ef6080e7          	jalr	-266(ra) # 54d0 <exit>
  if(pid == 0)
    25e2:	00091763          	bnez	s2,25f0 <sbrkbasic+0x16e>
    exit(0);
    25e6:	4501                	li	a0,0
    25e8:	00003097          	auipc	ra,0x3
    25ec:	ee8080e7          	jalr	-280(ra) # 54d0 <exit>
  wait(&xstatus);
    25f0:	fbc40513          	addi	a0,s0,-68
    25f4:	00003097          	auipc	ra,0x3
    25f8:	ee4080e7          	jalr	-284(ra) # 54d8 <wait>
  exit(xstatus);
    25fc:	fbc42503          	lw	a0,-68(s0)
    2600:	00003097          	auipc	ra,0x3
    2604:	ed0080e7          	jalr	-304(ra) # 54d0 <exit>

0000000000002608 <sbrkmuch>:
{
    2608:	7179                	addi	sp,sp,-48
    260a:	f406                	sd	ra,40(sp)
    260c:	f022                	sd	s0,32(sp)
    260e:	ec26                	sd	s1,24(sp)
    2610:	e84a                	sd	s2,16(sp)
    2612:	e44e                	sd	s3,8(sp)
    2614:	e052                	sd	s4,0(sp)
    2616:	1800                	addi	s0,sp,48
    2618:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    261a:	4501                	li	a0,0
    261c:	00003097          	auipc	ra,0x3
    2620:	f3c080e7          	jalr	-196(ra) # 5558 <sbrk>
    2624:	892a                	mv	s2,a0
  a = sbrk(0);
    2626:	4501                	li	a0,0
    2628:	00003097          	auipc	ra,0x3
    262c:	f30080e7          	jalr	-208(ra) # 5558 <sbrk>
    2630:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2632:	06400537          	lui	a0,0x6400
    2636:	9d05                	subw	a0,a0,s1
    2638:	00003097          	auipc	ra,0x3
    263c:	f20080e7          	jalr	-224(ra) # 5558 <sbrk>
  if (p != a) {
    2640:	0ca49863          	bne	s1,a0,2710 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2644:	4501                	li	a0,0
    2646:	00003097          	auipc	ra,0x3
    264a:	f12080e7          	jalr	-238(ra) # 5558 <sbrk>
    264e:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2650:	00a4f963          	bgeu	s1,a0,2662 <sbrkmuch+0x5a>
    *pp = 1;
    2654:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2656:	6705                	lui	a4,0x1
    *pp = 1;
    2658:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    265c:	94ba                	add	s1,s1,a4
    265e:	fef4ede3          	bltu	s1,a5,2658 <sbrkmuch+0x50>
  *lastaddr = 99;
    2662:	064007b7          	lui	a5,0x6400
    2666:	06300713          	li	a4,99
    266a:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f16bf>
  a = sbrk(0);
    266e:	4501                	li	a0,0
    2670:	00003097          	auipc	ra,0x3
    2674:	ee8080e7          	jalr	-280(ra) # 5558 <sbrk>
    2678:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    267a:	757d                	lui	a0,0xfffff
    267c:	00003097          	auipc	ra,0x3
    2680:	edc080e7          	jalr	-292(ra) # 5558 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2684:	57fd                	li	a5,-1
    2686:	0af50363          	beq	a0,a5,272c <sbrkmuch+0x124>
  c = sbrk(0);
    268a:	4501                	li	a0,0
    268c:	00003097          	auipc	ra,0x3
    2690:	ecc080e7          	jalr	-308(ra) # 5558 <sbrk>
  if(c != a - PGSIZE){
    2694:	77fd                	lui	a5,0xfffff
    2696:	97a6                	add	a5,a5,s1
    2698:	0af51863          	bne	a0,a5,2748 <sbrkmuch+0x140>
  a = sbrk(0);
    269c:	4501                	li	a0,0
    269e:	00003097          	auipc	ra,0x3
    26a2:	eba080e7          	jalr	-326(ra) # 5558 <sbrk>
    26a6:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    26a8:	6505                	lui	a0,0x1
    26aa:	00003097          	auipc	ra,0x3
    26ae:	eae080e7          	jalr	-338(ra) # 5558 <sbrk>
    26b2:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    26b4:	0aa49a63          	bne	s1,a0,2768 <sbrkmuch+0x160>
    26b8:	4501                	li	a0,0
    26ba:	00003097          	auipc	ra,0x3
    26be:	e9e080e7          	jalr	-354(ra) # 5558 <sbrk>
    26c2:	6785                	lui	a5,0x1
    26c4:	97a6                	add	a5,a5,s1
    26c6:	0af51163          	bne	a0,a5,2768 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    26ca:	064007b7          	lui	a5,0x6400
    26ce:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f16bf>
    26d2:	06300793          	li	a5,99
    26d6:	0af70963          	beq	a4,a5,2788 <sbrkmuch+0x180>
  a = sbrk(0);
    26da:	4501                	li	a0,0
    26dc:	00003097          	auipc	ra,0x3
    26e0:	e7c080e7          	jalr	-388(ra) # 5558 <sbrk>
    26e4:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    26e6:	4501                	li	a0,0
    26e8:	00003097          	auipc	ra,0x3
    26ec:	e70080e7          	jalr	-400(ra) # 5558 <sbrk>
    26f0:	40a9053b          	subw	a0,s2,a0
    26f4:	00003097          	auipc	ra,0x3
    26f8:	e64080e7          	jalr	-412(ra) # 5558 <sbrk>
  if(c != a){
    26fc:	0aa49463          	bne	s1,a0,27a4 <sbrkmuch+0x19c>
}
    2700:	70a2                	ld	ra,40(sp)
    2702:	7402                	ld	s0,32(sp)
    2704:	64e2                	ld	s1,24(sp)
    2706:	6942                	ld	s2,16(sp)
    2708:	69a2                	ld	s3,8(sp)
    270a:	6a02                	ld	s4,0(sp)
    270c:	6145                	addi	sp,sp,48
    270e:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2710:	85ce                	mv	a1,s3
    2712:	00004517          	auipc	a0,0x4
    2716:	3f650513          	addi	a0,a0,1014 # 6b08 <malloc+0x1202>
    271a:	00003097          	auipc	ra,0x3
    271e:	12e080e7          	jalr	302(ra) # 5848 <printf>
    exit(1);
    2722:	4505                	li	a0,1
    2724:	00003097          	auipc	ra,0x3
    2728:	dac080e7          	jalr	-596(ra) # 54d0 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    272c:	85ce                	mv	a1,s3
    272e:	00004517          	auipc	a0,0x4
    2732:	42250513          	addi	a0,a0,1058 # 6b50 <malloc+0x124a>
    2736:	00003097          	auipc	ra,0x3
    273a:	112080e7          	jalr	274(ra) # 5848 <printf>
    exit(1);
    273e:	4505                	li	a0,1
    2740:	00003097          	auipc	ra,0x3
    2744:	d90080e7          	jalr	-624(ra) # 54d0 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2748:	86aa                	mv	a3,a0
    274a:	8626                	mv	a2,s1
    274c:	85ce                	mv	a1,s3
    274e:	00004517          	auipc	a0,0x4
    2752:	42250513          	addi	a0,a0,1058 # 6b70 <malloc+0x126a>
    2756:	00003097          	auipc	ra,0x3
    275a:	0f2080e7          	jalr	242(ra) # 5848 <printf>
    exit(1);
    275e:	4505                	li	a0,1
    2760:	00003097          	auipc	ra,0x3
    2764:	d70080e7          	jalr	-656(ra) # 54d0 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2768:	86d2                	mv	a3,s4
    276a:	8626                	mv	a2,s1
    276c:	85ce                	mv	a1,s3
    276e:	00004517          	auipc	a0,0x4
    2772:	44250513          	addi	a0,a0,1090 # 6bb0 <malloc+0x12aa>
    2776:	00003097          	auipc	ra,0x3
    277a:	0d2080e7          	jalr	210(ra) # 5848 <printf>
    exit(1);
    277e:	4505                	li	a0,1
    2780:	00003097          	auipc	ra,0x3
    2784:	d50080e7          	jalr	-688(ra) # 54d0 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2788:	85ce                	mv	a1,s3
    278a:	00004517          	auipc	a0,0x4
    278e:	45650513          	addi	a0,a0,1110 # 6be0 <malloc+0x12da>
    2792:	00003097          	auipc	ra,0x3
    2796:	0b6080e7          	jalr	182(ra) # 5848 <printf>
    exit(1);
    279a:	4505                	li	a0,1
    279c:	00003097          	auipc	ra,0x3
    27a0:	d34080e7          	jalr	-716(ra) # 54d0 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    27a4:	86aa                	mv	a3,a0
    27a6:	8626                	mv	a2,s1
    27a8:	85ce                	mv	a1,s3
    27aa:	00004517          	auipc	a0,0x4
    27ae:	46e50513          	addi	a0,a0,1134 # 6c18 <malloc+0x1312>
    27b2:	00003097          	auipc	ra,0x3
    27b6:	096080e7          	jalr	150(ra) # 5848 <printf>
    exit(1);
    27ba:	4505                	li	a0,1
    27bc:	00003097          	auipc	ra,0x3
    27c0:	d14080e7          	jalr	-748(ra) # 54d0 <exit>

00000000000027c4 <sbrkarg>:
{
    27c4:	7179                	addi	sp,sp,-48
    27c6:	f406                	sd	ra,40(sp)
    27c8:	f022                	sd	s0,32(sp)
    27ca:	ec26                	sd	s1,24(sp)
    27cc:	e84a                	sd	s2,16(sp)
    27ce:	e44e                	sd	s3,8(sp)
    27d0:	1800                	addi	s0,sp,48
    27d2:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    27d4:	6505                	lui	a0,0x1
    27d6:	00003097          	auipc	ra,0x3
    27da:	d82080e7          	jalr	-638(ra) # 5558 <sbrk>
    27de:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    27e0:	20100593          	li	a1,513
    27e4:	00004517          	auipc	a0,0x4
    27e8:	45c50513          	addi	a0,a0,1116 # 6c40 <malloc+0x133a>
    27ec:	00003097          	auipc	ra,0x3
    27f0:	d24080e7          	jalr	-732(ra) # 5510 <open>
    27f4:	84aa                	mv	s1,a0
  unlink("sbrk");
    27f6:	00004517          	auipc	a0,0x4
    27fa:	44a50513          	addi	a0,a0,1098 # 6c40 <malloc+0x133a>
    27fe:	00003097          	auipc	ra,0x3
    2802:	d22080e7          	jalr	-734(ra) # 5520 <unlink>
  if(fd < 0)  {
    2806:	0404c163          	bltz	s1,2848 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    280a:	6605                	lui	a2,0x1
    280c:	85ca                	mv	a1,s2
    280e:	8526                	mv	a0,s1
    2810:	00003097          	auipc	ra,0x3
    2814:	ce0080e7          	jalr	-800(ra) # 54f0 <write>
    2818:	04054663          	bltz	a0,2864 <sbrkarg+0xa0>
  close(fd);
    281c:	8526                	mv	a0,s1
    281e:	00003097          	auipc	ra,0x3
    2822:	cda080e7          	jalr	-806(ra) # 54f8 <close>
  a = sbrk(PGSIZE);
    2826:	6505                	lui	a0,0x1
    2828:	00003097          	auipc	ra,0x3
    282c:	d30080e7          	jalr	-720(ra) # 5558 <sbrk>
  if(pipe((int *) a) != 0){
    2830:	00003097          	auipc	ra,0x3
    2834:	cb0080e7          	jalr	-848(ra) # 54e0 <pipe>
    2838:	e521                	bnez	a0,2880 <sbrkarg+0xbc>
}
    283a:	70a2                	ld	ra,40(sp)
    283c:	7402                	ld	s0,32(sp)
    283e:	64e2                	ld	s1,24(sp)
    2840:	6942                	ld	s2,16(sp)
    2842:	69a2                	ld	s3,8(sp)
    2844:	6145                	addi	sp,sp,48
    2846:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2848:	85ce                	mv	a1,s3
    284a:	00004517          	auipc	a0,0x4
    284e:	3fe50513          	addi	a0,a0,1022 # 6c48 <malloc+0x1342>
    2852:	00003097          	auipc	ra,0x3
    2856:	ff6080e7          	jalr	-10(ra) # 5848 <printf>
    exit(1);
    285a:	4505                	li	a0,1
    285c:	00003097          	auipc	ra,0x3
    2860:	c74080e7          	jalr	-908(ra) # 54d0 <exit>
    printf("%s: write sbrk failed\n", s);
    2864:	85ce                	mv	a1,s3
    2866:	00004517          	auipc	a0,0x4
    286a:	3fa50513          	addi	a0,a0,1018 # 6c60 <malloc+0x135a>
    286e:	00003097          	auipc	ra,0x3
    2872:	fda080e7          	jalr	-38(ra) # 5848 <printf>
    exit(1);
    2876:	4505                	li	a0,1
    2878:	00003097          	auipc	ra,0x3
    287c:	c58080e7          	jalr	-936(ra) # 54d0 <exit>
    printf("%s: pipe() failed\n", s);
    2880:	85ce                	mv	a1,s3
    2882:	00004517          	auipc	a0,0x4
    2886:	df650513          	addi	a0,a0,-522 # 6678 <malloc+0xd72>
    288a:	00003097          	auipc	ra,0x3
    288e:	fbe080e7          	jalr	-66(ra) # 5848 <printf>
    exit(1);
    2892:	4505                	li	a0,1
    2894:	00003097          	auipc	ra,0x3
    2898:	c3c080e7          	jalr	-964(ra) # 54d0 <exit>

000000000000289c <argptest>:
{
    289c:	1101                	addi	sp,sp,-32
    289e:	ec06                	sd	ra,24(sp)
    28a0:	e822                	sd	s0,16(sp)
    28a2:	e426                	sd	s1,8(sp)
    28a4:	e04a                	sd	s2,0(sp)
    28a6:	1000                	addi	s0,sp,32
    28a8:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    28aa:	4581                	li	a1,0
    28ac:	00004517          	auipc	a0,0x4
    28b0:	3cc50513          	addi	a0,a0,972 # 6c78 <malloc+0x1372>
    28b4:	00003097          	auipc	ra,0x3
    28b8:	c5c080e7          	jalr	-932(ra) # 5510 <open>
  if (fd < 0) {
    28bc:	02054b63          	bltz	a0,28f2 <argptest+0x56>
    28c0:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    28c2:	4501                	li	a0,0
    28c4:	00003097          	auipc	ra,0x3
    28c8:	c94080e7          	jalr	-876(ra) # 5558 <sbrk>
    28cc:	567d                	li	a2,-1
    28ce:	fff50593          	addi	a1,a0,-1
    28d2:	8526                	mv	a0,s1
    28d4:	00003097          	auipc	ra,0x3
    28d8:	c14080e7          	jalr	-1004(ra) # 54e8 <read>
  close(fd);
    28dc:	8526                	mv	a0,s1
    28de:	00003097          	auipc	ra,0x3
    28e2:	c1a080e7          	jalr	-998(ra) # 54f8 <close>
}
    28e6:	60e2                	ld	ra,24(sp)
    28e8:	6442                	ld	s0,16(sp)
    28ea:	64a2                	ld	s1,8(sp)
    28ec:	6902                	ld	s2,0(sp)
    28ee:	6105                	addi	sp,sp,32
    28f0:	8082                	ret
    printf("%s: open failed\n", s);
    28f2:	85ca                	mv	a1,s2
    28f4:	00004517          	auipc	a0,0x4
    28f8:	c9450513          	addi	a0,a0,-876 # 6588 <malloc+0xc82>
    28fc:	00003097          	auipc	ra,0x3
    2900:	f4c080e7          	jalr	-180(ra) # 5848 <printf>
    exit(1);
    2904:	4505                	li	a0,1
    2906:	00003097          	auipc	ra,0x3
    290a:	bca080e7          	jalr	-1078(ra) # 54d0 <exit>

000000000000290e <sbrkbugs>:
{
    290e:	1141                	addi	sp,sp,-16
    2910:	e406                	sd	ra,8(sp)
    2912:	e022                	sd	s0,0(sp)
    2914:	0800                	addi	s0,sp,16
  int pid = fork();
    2916:	00003097          	auipc	ra,0x3
    291a:	bb2080e7          	jalr	-1102(ra) # 54c8 <fork>
  if(pid < 0){
    291e:	02054263          	bltz	a0,2942 <sbrkbugs+0x34>
  if(pid == 0){
    2922:	ed0d                	bnez	a0,295c <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2924:	00003097          	auipc	ra,0x3
    2928:	c34080e7          	jalr	-972(ra) # 5558 <sbrk>
    sbrk(-sz);
    292c:	40a0053b          	negw	a0,a0
    2930:	00003097          	auipc	ra,0x3
    2934:	c28080e7          	jalr	-984(ra) # 5558 <sbrk>
    exit(0);
    2938:	4501                	li	a0,0
    293a:	00003097          	auipc	ra,0x3
    293e:	b96080e7          	jalr	-1130(ra) # 54d0 <exit>
    printf("fork failed\n");
    2942:	00004517          	auipc	a0,0x4
    2946:	01e50513          	addi	a0,a0,30 # 6960 <malloc+0x105a>
    294a:	00003097          	auipc	ra,0x3
    294e:	efe080e7          	jalr	-258(ra) # 5848 <printf>
    exit(1);
    2952:	4505                	li	a0,1
    2954:	00003097          	auipc	ra,0x3
    2958:	b7c080e7          	jalr	-1156(ra) # 54d0 <exit>
  wait(0);
    295c:	4501                	li	a0,0
    295e:	00003097          	auipc	ra,0x3
    2962:	b7a080e7          	jalr	-1158(ra) # 54d8 <wait>
  pid = fork();
    2966:	00003097          	auipc	ra,0x3
    296a:	b62080e7          	jalr	-1182(ra) # 54c8 <fork>
  if(pid < 0){
    296e:	02054563          	bltz	a0,2998 <sbrkbugs+0x8a>
  if(pid == 0){
    2972:	e121                	bnez	a0,29b2 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2974:	00003097          	auipc	ra,0x3
    2978:	be4080e7          	jalr	-1052(ra) # 5558 <sbrk>
    sbrk(-(sz - 3500));
    297c:	6785                	lui	a5,0x1
    297e:	dac7879b          	addiw	a5,a5,-596
    2982:	40a7853b          	subw	a0,a5,a0
    2986:	00003097          	auipc	ra,0x3
    298a:	bd2080e7          	jalr	-1070(ra) # 5558 <sbrk>
    exit(0);
    298e:	4501                	li	a0,0
    2990:	00003097          	auipc	ra,0x3
    2994:	b40080e7          	jalr	-1216(ra) # 54d0 <exit>
    printf("fork failed\n");
    2998:	00004517          	auipc	a0,0x4
    299c:	fc850513          	addi	a0,a0,-56 # 6960 <malloc+0x105a>
    29a0:	00003097          	auipc	ra,0x3
    29a4:	ea8080e7          	jalr	-344(ra) # 5848 <printf>
    exit(1);
    29a8:	4505                	li	a0,1
    29aa:	00003097          	auipc	ra,0x3
    29ae:	b26080e7          	jalr	-1242(ra) # 54d0 <exit>
  wait(0);
    29b2:	4501                	li	a0,0
    29b4:	00003097          	auipc	ra,0x3
    29b8:	b24080e7          	jalr	-1244(ra) # 54d8 <wait>
  pid = fork();
    29bc:	00003097          	auipc	ra,0x3
    29c0:	b0c080e7          	jalr	-1268(ra) # 54c8 <fork>
  if(pid < 0){
    29c4:	02054a63          	bltz	a0,29f8 <sbrkbugs+0xea>
  if(pid == 0){
    29c8:	e529                	bnez	a0,2a12 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    29ca:	00003097          	auipc	ra,0x3
    29ce:	b8e080e7          	jalr	-1138(ra) # 5558 <sbrk>
    29d2:	67ad                	lui	a5,0xb
    29d4:	8007879b          	addiw	a5,a5,-2048
    29d8:	40a7853b          	subw	a0,a5,a0
    29dc:	00003097          	auipc	ra,0x3
    29e0:	b7c080e7          	jalr	-1156(ra) # 5558 <sbrk>
    sbrk(-10);
    29e4:	5559                	li	a0,-10
    29e6:	00003097          	auipc	ra,0x3
    29ea:	b72080e7          	jalr	-1166(ra) # 5558 <sbrk>
    exit(0);
    29ee:	4501                	li	a0,0
    29f0:	00003097          	auipc	ra,0x3
    29f4:	ae0080e7          	jalr	-1312(ra) # 54d0 <exit>
    printf("fork failed\n");
    29f8:	00004517          	auipc	a0,0x4
    29fc:	f6850513          	addi	a0,a0,-152 # 6960 <malloc+0x105a>
    2a00:	00003097          	auipc	ra,0x3
    2a04:	e48080e7          	jalr	-440(ra) # 5848 <printf>
    exit(1);
    2a08:	4505                	li	a0,1
    2a0a:	00003097          	auipc	ra,0x3
    2a0e:	ac6080e7          	jalr	-1338(ra) # 54d0 <exit>
  wait(0);
    2a12:	4501                	li	a0,0
    2a14:	00003097          	auipc	ra,0x3
    2a18:	ac4080e7          	jalr	-1340(ra) # 54d8 <wait>
  exit(0);
    2a1c:	4501                	li	a0,0
    2a1e:	00003097          	auipc	ra,0x3
    2a22:	ab2080e7          	jalr	-1358(ra) # 54d0 <exit>

0000000000002a26 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2a26:	715d                	addi	sp,sp,-80
    2a28:	e486                	sd	ra,72(sp)
    2a2a:	e0a2                	sd	s0,64(sp)
    2a2c:	fc26                	sd	s1,56(sp)
    2a2e:	f84a                	sd	s2,48(sp)
    2a30:	f44e                	sd	s3,40(sp)
    2a32:	f052                	sd	s4,32(sp)
    2a34:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2a36:	4901                	li	s2,0
    2a38:	49bd                	li	s3,15
    int pid = fork();
    2a3a:	00003097          	auipc	ra,0x3
    2a3e:	a8e080e7          	jalr	-1394(ra) # 54c8 <fork>
    2a42:	84aa                	mv	s1,a0
    if(pid < 0){
    2a44:	02054063          	bltz	a0,2a64 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2a48:	c91d                	beqz	a0,2a7e <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2a4a:	4501                	li	a0,0
    2a4c:	00003097          	auipc	ra,0x3
    2a50:	a8c080e7          	jalr	-1396(ra) # 54d8 <wait>
  for(int avail = 0; avail < 15; avail++){
    2a54:	2905                	addiw	s2,s2,1
    2a56:	ff3912e3          	bne	s2,s3,2a3a <execout+0x14>
    }
  }

  exit(0);
    2a5a:	4501                	li	a0,0
    2a5c:	00003097          	auipc	ra,0x3
    2a60:	a74080e7          	jalr	-1420(ra) # 54d0 <exit>
      printf("fork failed\n");
    2a64:	00004517          	auipc	a0,0x4
    2a68:	efc50513          	addi	a0,a0,-260 # 6960 <malloc+0x105a>
    2a6c:	00003097          	auipc	ra,0x3
    2a70:	ddc080e7          	jalr	-548(ra) # 5848 <printf>
      exit(1);
    2a74:	4505                	li	a0,1
    2a76:	00003097          	auipc	ra,0x3
    2a7a:	a5a080e7          	jalr	-1446(ra) # 54d0 <exit>
        if(a == 0xffffffffffffffffLL)
    2a7e:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2a80:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2a82:	6505                	lui	a0,0x1
    2a84:	00003097          	auipc	ra,0x3
    2a88:	ad4080e7          	jalr	-1324(ra) # 5558 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2a8c:	01350763          	beq	a0,s3,2a9a <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2a90:	6785                	lui	a5,0x1
    2a92:	953e                	add	a0,a0,a5
    2a94:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x89>
      while(1){
    2a98:	b7ed                	j	2a82 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2a9a:	01205a63          	blez	s2,2aae <execout+0x88>
        sbrk(-4096);
    2a9e:	757d                	lui	a0,0xfffff
    2aa0:	00003097          	auipc	ra,0x3
    2aa4:	ab8080e7          	jalr	-1352(ra) # 5558 <sbrk>
      for(int i = 0; i < avail; i++)
    2aa8:	2485                	addiw	s1,s1,1
    2aaa:	ff249ae3          	bne	s1,s2,2a9e <execout+0x78>
      close(1);
    2aae:	4505                	li	a0,1
    2ab0:	00003097          	auipc	ra,0x3
    2ab4:	a48080e7          	jalr	-1464(ra) # 54f8 <close>
      char *args[] = { "echo", "x", 0 };
    2ab8:	00003517          	auipc	a0,0x3
    2abc:	28050513          	addi	a0,a0,640 # 5d38 <malloc+0x432>
    2ac0:	faa43c23          	sd	a0,-72(s0)
    2ac4:	00003797          	auipc	a5,0x3
    2ac8:	2e478793          	addi	a5,a5,740 # 5da8 <malloc+0x4a2>
    2acc:	fcf43023          	sd	a5,-64(s0)
    2ad0:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2ad4:	fb840593          	addi	a1,s0,-72
    2ad8:	00003097          	auipc	ra,0x3
    2adc:	a30080e7          	jalr	-1488(ra) # 5508 <exec>
      exit(0);
    2ae0:	4501                	li	a0,0
    2ae2:	00003097          	auipc	ra,0x3
    2ae6:	9ee080e7          	jalr	-1554(ra) # 54d0 <exit>

0000000000002aea <fourteen>:
{
    2aea:	1101                	addi	sp,sp,-32
    2aec:	ec06                	sd	ra,24(sp)
    2aee:	e822                	sd	s0,16(sp)
    2af0:	e426                	sd	s1,8(sp)
    2af2:	1000                	addi	s0,sp,32
    2af4:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2af6:	00004517          	auipc	a0,0x4
    2afa:	35a50513          	addi	a0,a0,858 # 6e50 <malloc+0x154a>
    2afe:	00003097          	auipc	ra,0x3
    2b02:	a3a080e7          	jalr	-1478(ra) # 5538 <mkdir>
    2b06:	e165                	bnez	a0,2be6 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2b08:	00004517          	auipc	a0,0x4
    2b0c:	1a050513          	addi	a0,a0,416 # 6ca8 <malloc+0x13a2>
    2b10:	00003097          	auipc	ra,0x3
    2b14:	a28080e7          	jalr	-1496(ra) # 5538 <mkdir>
    2b18:	e56d                	bnez	a0,2c02 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2b1a:	20000593          	li	a1,512
    2b1e:	00004517          	auipc	a0,0x4
    2b22:	1e250513          	addi	a0,a0,482 # 6d00 <malloc+0x13fa>
    2b26:	00003097          	auipc	ra,0x3
    2b2a:	9ea080e7          	jalr	-1558(ra) # 5510 <open>
  if(fd < 0){
    2b2e:	0e054863          	bltz	a0,2c1e <fourteen+0x134>
  close(fd);
    2b32:	00003097          	auipc	ra,0x3
    2b36:	9c6080e7          	jalr	-1594(ra) # 54f8 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2b3a:	4581                	li	a1,0
    2b3c:	00004517          	auipc	a0,0x4
    2b40:	23c50513          	addi	a0,a0,572 # 6d78 <malloc+0x1472>
    2b44:	00003097          	auipc	ra,0x3
    2b48:	9cc080e7          	jalr	-1588(ra) # 5510 <open>
  if(fd < 0){
    2b4c:	0e054763          	bltz	a0,2c3a <fourteen+0x150>
  close(fd);
    2b50:	00003097          	auipc	ra,0x3
    2b54:	9a8080e7          	jalr	-1624(ra) # 54f8 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2b58:	00004517          	auipc	a0,0x4
    2b5c:	29050513          	addi	a0,a0,656 # 6de8 <malloc+0x14e2>
    2b60:	00003097          	auipc	ra,0x3
    2b64:	9d8080e7          	jalr	-1576(ra) # 5538 <mkdir>
    2b68:	c57d                	beqz	a0,2c56 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2b6a:	00004517          	auipc	a0,0x4
    2b6e:	2d650513          	addi	a0,a0,726 # 6e40 <malloc+0x153a>
    2b72:	00003097          	auipc	ra,0x3
    2b76:	9c6080e7          	jalr	-1594(ra) # 5538 <mkdir>
    2b7a:	cd65                	beqz	a0,2c72 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2b7c:	00004517          	auipc	a0,0x4
    2b80:	2c450513          	addi	a0,a0,708 # 6e40 <malloc+0x153a>
    2b84:	00003097          	auipc	ra,0x3
    2b88:	99c080e7          	jalr	-1636(ra) # 5520 <unlink>
  unlink("12345678901234/12345678901234");
    2b8c:	00004517          	auipc	a0,0x4
    2b90:	25c50513          	addi	a0,a0,604 # 6de8 <malloc+0x14e2>
    2b94:	00003097          	auipc	ra,0x3
    2b98:	98c080e7          	jalr	-1652(ra) # 5520 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2b9c:	00004517          	auipc	a0,0x4
    2ba0:	1dc50513          	addi	a0,a0,476 # 6d78 <malloc+0x1472>
    2ba4:	00003097          	auipc	ra,0x3
    2ba8:	97c080e7          	jalr	-1668(ra) # 5520 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2bac:	00004517          	auipc	a0,0x4
    2bb0:	15450513          	addi	a0,a0,340 # 6d00 <malloc+0x13fa>
    2bb4:	00003097          	auipc	ra,0x3
    2bb8:	96c080e7          	jalr	-1684(ra) # 5520 <unlink>
  unlink("12345678901234/123456789012345");
    2bbc:	00004517          	auipc	a0,0x4
    2bc0:	0ec50513          	addi	a0,a0,236 # 6ca8 <malloc+0x13a2>
    2bc4:	00003097          	auipc	ra,0x3
    2bc8:	95c080e7          	jalr	-1700(ra) # 5520 <unlink>
  unlink("12345678901234");
    2bcc:	00004517          	auipc	a0,0x4
    2bd0:	28450513          	addi	a0,a0,644 # 6e50 <malloc+0x154a>
    2bd4:	00003097          	auipc	ra,0x3
    2bd8:	94c080e7          	jalr	-1716(ra) # 5520 <unlink>
}
    2bdc:	60e2                	ld	ra,24(sp)
    2bde:	6442                	ld	s0,16(sp)
    2be0:	64a2                	ld	s1,8(sp)
    2be2:	6105                	addi	sp,sp,32
    2be4:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2be6:	85a6                	mv	a1,s1
    2be8:	00004517          	auipc	a0,0x4
    2bec:	09850513          	addi	a0,a0,152 # 6c80 <malloc+0x137a>
    2bf0:	00003097          	auipc	ra,0x3
    2bf4:	c58080e7          	jalr	-936(ra) # 5848 <printf>
    exit(1);
    2bf8:	4505                	li	a0,1
    2bfa:	00003097          	auipc	ra,0x3
    2bfe:	8d6080e7          	jalr	-1834(ra) # 54d0 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2c02:	85a6                	mv	a1,s1
    2c04:	00004517          	auipc	a0,0x4
    2c08:	0c450513          	addi	a0,a0,196 # 6cc8 <malloc+0x13c2>
    2c0c:	00003097          	auipc	ra,0x3
    2c10:	c3c080e7          	jalr	-964(ra) # 5848 <printf>
    exit(1);
    2c14:	4505                	li	a0,1
    2c16:	00003097          	auipc	ra,0x3
    2c1a:	8ba080e7          	jalr	-1862(ra) # 54d0 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2c1e:	85a6                	mv	a1,s1
    2c20:	00004517          	auipc	a0,0x4
    2c24:	11050513          	addi	a0,a0,272 # 6d30 <malloc+0x142a>
    2c28:	00003097          	auipc	ra,0x3
    2c2c:	c20080e7          	jalr	-992(ra) # 5848 <printf>
    exit(1);
    2c30:	4505                	li	a0,1
    2c32:	00003097          	auipc	ra,0x3
    2c36:	89e080e7          	jalr	-1890(ra) # 54d0 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2c3a:	85a6                	mv	a1,s1
    2c3c:	00004517          	auipc	a0,0x4
    2c40:	16c50513          	addi	a0,a0,364 # 6da8 <malloc+0x14a2>
    2c44:	00003097          	auipc	ra,0x3
    2c48:	c04080e7          	jalr	-1020(ra) # 5848 <printf>
    exit(1);
    2c4c:	4505                	li	a0,1
    2c4e:	00003097          	auipc	ra,0x3
    2c52:	882080e7          	jalr	-1918(ra) # 54d0 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2c56:	85a6                	mv	a1,s1
    2c58:	00004517          	auipc	a0,0x4
    2c5c:	1b050513          	addi	a0,a0,432 # 6e08 <malloc+0x1502>
    2c60:	00003097          	auipc	ra,0x3
    2c64:	be8080e7          	jalr	-1048(ra) # 5848 <printf>
    exit(1);
    2c68:	4505                	li	a0,1
    2c6a:	00003097          	auipc	ra,0x3
    2c6e:	866080e7          	jalr	-1946(ra) # 54d0 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2c72:	85a6                	mv	a1,s1
    2c74:	00004517          	auipc	a0,0x4
    2c78:	1ec50513          	addi	a0,a0,492 # 6e60 <malloc+0x155a>
    2c7c:	00003097          	auipc	ra,0x3
    2c80:	bcc080e7          	jalr	-1076(ra) # 5848 <printf>
    exit(1);
    2c84:	4505                	li	a0,1
    2c86:	00003097          	auipc	ra,0x3
    2c8a:	84a080e7          	jalr	-1974(ra) # 54d0 <exit>

0000000000002c8e <iputtest>:
{
    2c8e:	1101                	addi	sp,sp,-32
    2c90:	ec06                	sd	ra,24(sp)
    2c92:	e822                	sd	s0,16(sp)
    2c94:	e426                	sd	s1,8(sp)
    2c96:	1000                	addi	s0,sp,32
    2c98:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2c9a:	00004517          	auipc	a0,0x4
    2c9e:	1fe50513          	addi	a0,a0,510 # 6e98 <malloc+0x1592>
    2ca2:	00003097          	auipc	ra,0x3
    2ca6:	896080e7          	jalr	-1898(ra) # 5538 <mkdir>
    2caa:	04054563          	bltz	a0,2cf4 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2cae:	00004517          	auipc	a0,0x4
    2cb2:	1ea50513          	addi	a0,a0,490 # 6e98 <malloc+0x1592>
    2cb6:	00003097          	auipc	ra,0x3
    2cba:	88a080e7          	jalr	-1910(ra) # 5540 <chdir>
    2cbe:	04054963          	bltz	a0,2d10 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2cc2:	00004517          	auipc	a0,0x4
    2cc6:	21650513          	addi	a0,a0,534 # 6ed8 <malloc+0x15d2>
    2cca:	00003097          	auipc	ra,0x3
    2cce:	856080e7          	jalr	-1962(ra) # 5520 <unlink>
    2cd2:	04054d63          	bltz	a0,2d2c <iputtest+0x9e>
  if(chdir("/") < 0){
    2cd6:	00004517          	auipc	a0,0x4
    2cda:	23250513          	addi	a0,a0,562 # 6f08 <malloc+0x1602>
    2cde:	00003097          	auipc	ra,0x3
    2ce2:	862080e7          	jalr	-1950(ra) # 5540 <chdir>
    2ce6:	06054163          	bltz	a0,2d48 <iputtest+0xba>
}
    2cea:	60e2                	ld	ra,24(sp)
    2cec:	6442                	ld	s0,16(sp)
    2cee:	64a2                	ld	s1,8(sp)
    2cf0:	6105                	addi	sp,sp,32
    2cf2:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2cf4:	85a6                	mv	a1,s1
    2cf6:	00004517          	auipc	a0,0x4
    2cfa:	1aa50513          	addi	a0,a0,426 # 6ea0 <malloc+0x159a>
    2cfe:	00003097          	auipc	ra,0x3
    2d02:	b4a080e7          	jalr	-1206(ra) # 5848 <printf>
    exit(1);
    2d06:	4505                	li	a0,1
    2d08:	00002097          	auipc	ra,0x2
    2d0c:	7c8080e7          	jalr	1992(ra) # 54d0 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2d10:	85a6                	mv	a1,s1
    2d12:	00004517          	auipc	a0,0x4
    2d16:	1a650513          	addi	a0,a0,422 # 6eb8 <malloc+0x15b2>
    2d1a:	00003097          	auipc	ra,0x3
    2d1e:	b2e080e7          	jalr	-1234(ra) # 5848 <printf>
    exit(1);
    2d22:	4505                	li	a0,1
    2d24:	00002097          	auipc	ra,0x2
    2d28:	7ac080e7          	jalr	1964(ra) # 54d0 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2d2c:	85a6                	mv	a1,s1
    2d2e:	00004517          	auipc	a0,0x4
    2d32:	1ba50513          	addi	a0,a0,442 # 6ee8 <malloc+0x15e2>
    2d36:	00003097          	auipc	ra,0x3
    2d3a:	b12080e7          	jalr	-1262(ra) # 5848 <printf>
    exit(1);
    2d3e:	4505                	li	a0,1
    2d40:	00002097          	auipc	ra,0x2
    2d44:	790080e7          	jalr	1936(ra) # 54d0 <exit>
    printf("%s: chdir / failed\n", s);
    2d48:	85a6                	mv	a1,s1
    2d4a:	00004517          	auipc	a0,0x4
    2d4e:	1c650513          	addi	a0,a0,454 # 6f10 <malloc+0x160a>
    2d52:	00003097          	auipc	ra,0x3
    2d56:	af6080e7          	jalr	-1290(ra) # 5848 <printf>
    exit(1);
    2d5a:	4505                	li	a0,1
    2d5c:	00002097          	auipc	ra,0x2
    2d60:	774080e7          	jalr	1908(ra) # 54d0 <exit>

0000000000002d64 <exitiputtest>:
{
    2d64:	7179                	addi	sp,sp,-48
    2d66:	f406                	sd	ra,40(sp)
    2d68:	f022                	sd	s0,32(sp)
    2d6a:	ec26                	sd	s1,24(sp)
    2d6c:	1800                	addi	s0,sp,48
    2d6e:	84aa                	mv	s1,a0
  pid = fork();
    2d70:	00002097          	auipc	ra,0x2
    2d74:	758080e7          	jalr	1880(ra) # 54c8 <fork>
  if(pid < 0){
    2d78:	04054663          	bltz	a0,2dc4 <exitiputtest+0x60>
  if(pid == 0){
    2d7c:	ed45                	bnez	a0,2e34 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2d7e:	00004517          	auipc	a0,0x4
    2d82:	11a50513          	addi	a0,a0,282 # 6e98 <malloc+0x1592>
    2d86:	00002097          	auipc	ra,0x2
    2d8a:	7b2080e7          	jalr	1970(ra) # 5538 <mkdir>
    2d8e:	04054963          	bltz	a0,2de0 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2d92:	00004517          	auipc	a0,0x4
    2d96:	10650513          	addi	a0,a0,262 # 6e98 <malloc+0x1592>
    2d9a:	00002097          	auipc	ra,0x2
    2d9e:	7a6080e7          	jalr	1958(ra) # 5540 <chdir>
    2da2:	04054d63          	bltz	a0,2dfc <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2da6:	00004517          	auipc	a0,0x4
    2daa:	13250513          	addi	a0,a0,306 # 6ed8 <malloc+0x15d2>
    2dae:	00002097          	auipc	ra,0x2
    2db2:	772080e7          	jalr	1906(ra) # 5520 <unlink>
    2db6:	06054163          	bltz	a0,2e18 <exitiputtest+0xb4>
    exit(0);
    2dba:	4501                	li	a0,0
    2dbc:	00002097          	auipc	ra,0x2
    2dc0:	714080e7          	jalr	1812(ra) # 54d0 <exit>
    printf("%s: fork failed\n", s);
    2dc4:	85a6                	mv	a1,s1
    2dc6:	00003517          	auipc	a0,0x3
    2dca:	7aa50513          	addi	a0,a0,1962 # 6570 <malloc+0xc6a>
    2dce:	00003097          	auipc	ra,0x3
    2dd2:	a7a080e7          	jalr	-1414(ra) # 5848 <printf>
    exit(1);
    2dd6:	4505                	li	a0,1
    2dd8:	00002097          	auipc	ra,0x2
    2ddc:	6f8080e7          	jalr	1784(ra) # 54d0 <exit>
      printf("%s: mkdir failed\n", s);
    2de0:	85a6                	mv	a1,s1
    2de2:	00004517          	auipc	a0,0x4
    2de6:	0be50513          	addi	a0,a0,190 # 6ea0 <malloc+0x159a>
    2dea:	00003097          	auipc	ra,0x3
    2dee:	a5e080e7          	jalr	-1442(ra) # 5848 <printf>
      exit(1);
    2df2:	4505                	li	a0,1
    2df4:	00002097          	auipc	ra,0x2
    2df8:	6dc080e7          	jalr	1756(ra) # 54d0 <exit>
      printf("%s: child chdir failed\n", s);
    2dfc:	85a6                	mv	a1,s1
    2dfe:	00004517          	auipc	a0,0x4
    2e02:	12a50513          	addi	a0,a0,298 # 6f28 <malloc+0x1622>
    2e06:	00003097          	auipc	ra,0x3
    2e0a:	a42080e7          	jalr	-1470(ra) # 5848 <printf>
      exit(1);
    2e0e:	4505                	li	a0,1
    2e10:	00002097          	auipc	ra,0x2
    2e14:	6c0080e7          	jalr	1728(ra) # 54d0 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2e18:	85a6                	mv	a1,s1
    2e1a:	00004517          	auipc	a0,0x4
    2e1e:	0ce50513          	addi	a0,a0,206 # 6ee8 <malloc+0x15e2>
    2e22:	00003097          	auipc	ra,0x3
    2e26:	a26080e7          	jalr	-1498(ra) # 5848 <printf>
      exit(1);
    2e2a:	4505                	li	a0,1
    2e2c:	00002097          	auipc	ra,0x2
    2e30:	6a4080e7          	jalr	1700(ra) # 54d0 <exit>
  wait(&xstatus);
    2e34:	fdc40513          	addi	a0,s0,-36
    2e38:	00002097          	auipc	ra,0x2
    2e3c:	6a0080e7          	jalr	1696(ra) # 54d8 <wait>
  exit(xstatus);
    2e40:	fdc42503          	lw	a0,-36(s0)
    2e44:	00002097          	auipc	ra,0x2
    2e48:	68c080e7          	jalr	1676(ra) # 54d0 <exit>

0000000000002e4c <dirtest>:
{
    2e4c:	1101                	addi	sp,sp,-32
    2e4e:	ec06                	sd	ra,24(sp)
    2e50:	e822                	sd	s0,16(sp)
    2e52:	e426                	sd	s1,8(sp)
    2e54:	1000                	addi	s0,sp,32
    2e56:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2e58:	00004517          	auipc	a0,0x4
    2e5c:	0e850513          	addi	a0,a0,232 # 6f40 <malloc+0x163a>
    2e60:	00002097          	auipc	ra,0x2
    2e64:	6d8080e7          	jalr	1752(ra) # 5538 <mkdir>
    2e68:	04054563          	bltz	a0,2eb2 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2e6c:	00004517          	auipc	a0,0x4
    2e70:	0d450513          	addi	a0,a0,212 # 6f40 <malloc+0x163a>
    2e74:	00002097          	auipc	ra,0x2
    2e78:	6cc080e7          	jalr	1740(ra) # 5540 <chdir>
    2e7c:	04054963          	bltz	a0,2ece <dirtest+0x82>
  if(chdir("..") < 0){
    2e80:	00004517          	auipc	a0,0x4
    2e84:	0e050513          	addi	a0,a0,224 # 6f60 <malloc+0x165a>
    2e88:	00002097          	auipc	ra,0x2
    2e8c:	6b8080e7          	jalr	1720(ra) # 5540 <chdir>
    2e90:	04054d63          	bltz	a0,2eea <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2e94:	00004517          	auipc	a0,0x4
    2e98:	0ac50513          	addi	a0,a0,172 # 6f40 <malloc+0x163a>
    2e9c:	00002097          	auipc	ra,0x2
    2ea0:	684080e7          	jalr	1668(ra) # 5520 <unlink>
    2ea4:	06054163          	bltz	a0,2f06 <dirtest+0xba>
}
    2ea8:	60e2                	ld	ra,24(sp)
    2eaa:	6442                	ld	s0,16(sp)
    2eac:	64a2                	ld	s1,8(sp)
    2eae:	6105                	addi	sp,sp,32
    2eb0:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2eb2:	85a6                	mv	a1,s1
    2eb4:	00004517          	auipc	a0,0x4
    2eb8:	fec50513          	addi	a0,a0,-20 # 6ea0 <malloc+0x159a>
    2ebc:	00003097          	auipc	ra,0x3
    2ec0:	98c080e7          	jalr	-1652(ra) # 5848 <printf>
    exit(1);
    2ec4:	4505                	li	a0,1
    2ec6:	00002097          	auipc	ra,0x2
    2eca:	60a080e7          	jalr	1546(ra) # 54d0 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2ece:	85a6                	mv	a1,s1
    2ed0:	00004517          	auipc	a0,0x4
    2ed4:	07850513          	addi	a0,a0,120 # 6f48 <malloc+0x1642>
    2ed8:	00003097          	auipc	ra,0x3
    2edc:	970080e7          	jalr	-1680(ra) # 5848 <printf>
    exit(1);
    2ee0:	4505                	li	a0,1
    2ee2:	00002097          	auipc	ra,0x2
    2ee6:	5ee080e7          	jalr	1518(ra) # 54d0 <exit>
    printf("%s: chdir .. failed\n", s);
    2eea:	85a6                	mv	a1,s1
    2eec:	00004517          	auipc	a0,0x4
    2ef0:	07c50513          	addi	a0,a0,124 # 6f68 <malloc+0x1662>
    2ef4:	00003097          	auipc	ra,0x3
    2ef8:	954080e7          	jalr	-1708(ra) # 5848 <printf>
    exit(1);
    2efc:	4505                	li	a0,1
    2efe:	00002097          	auipc	ra,0x2
    2f02:	5d2080e7          	jalr	1490(ra) # 54d0 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2f06:	85a6                	mv	a1,s1
    2f08:	00004517          	auipc	a0,0x4
    2f0c:	07850513          	addi	a0,a0,120 # 6f80 <malloc+0x167a>
    2f10:	00003097          	auipc	ra,0x3
    2f14:	938080e7          	jalr	-1736(ra) # 5848 <printf>
    exit(1);
    2f18:	4505                	li	a0,1
    2f1a:	00002097          	auipc	ra,0x2
    2f1e:	5b6080e7          	jalr	1462(ra) # 54d0 <exit>

0000000000002f22 <subdir>:
{
    2f22:	1101                	addi	sp,sp,-32
    2f24:	ec06                	sd	ra,24(sp)
    2f26:	e822                	sd	s0,16(sp)
    2f28:	e426                	sd	s1,8(sp)
    2f2a:	e04a                	sd	s2,0(sp)
    2f2c:	1000                	addi	s0,sp,32
    2f2e:	892a                	mv	s2,a0
  unlink("ff");
    2f30:	00004517          	auipc	a0,0x4
    2f34:	19850513          	addi	a0,a0,408 # 70c8 <malloc+0x17c2>
    2f38:	00002097          	auipc	ra,0x2
    2f3c:	5e8080e7          	jalr	1512(ra) # 5520 <unlink>
  if(mkdir("dd") != 0){
    2f40:	00004517          	auipc	a0,0x4
    2f44:	05850513          	addi	a0,a0,88 # 6f98 <malloc+0x1692>
    2f48:	00002097          	auipc	ra,0x2
    2f4c:	5f0080e7          	jalr	1520(ra) # 5538 <mkdir>
    2f50:	38051663          	bnez	a0,32dc <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2f54:	20200593          	li	a1,514
    2f58:	00004517          	auipc	a0,0x4
    2f5c:	06050513          	addi	a0,a0,96 # 6fb8 <malloc+0x16b2>
    2f60:	00002097          	auipc	ra,0x2
    2f64:	5b0080e7          	jalr	1456(ra) # 5510 <open>
    2f68:	84aa                	mv	s1,a0
  if(fd < 0){
    2f6a:	38054763          	bltz	a0,32f8 <subdir+0x3d6>
  write(fd, "ff", 2);
    2f6e:	4609                	li	a2,2
    2f70:	00004597          	auipc	a1,0x4
    2f74:	15858593          	addi	a1,a1,344 # 70c8 <malloc+0x17c2>
    2f78:	00002097          	auipc	ra,0x2
    2f7c:	578080e7          	jalr	1400(ra) # 54f0 <write>
  close(fd);
    2f80:	8526                	mv	a0,s1
    2f82:	00002097          	auipc	ra,0x2
    2f86:	576080e7          	jalr	1398(ra) # 54f8 <close>
  if(unlink("dd") >= 0){
    2f8a:	00004517          	auipc	a0,0x4
    2f8e:	00e50513          	addi	a0,a0,14 # 6f98 <malloc+0x1692>
    2f92:	00002097          	auipc	ra,0x2
    2f96:	58e080e7          	jalr	1422(ra) # 5520 <unlink>
    2f9a:	36055d63          	bgez	a0,3314 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2f9e:	00004517          	auipc	a0,0x4
    2fa2:	07250513          	addi	a0,a0,114 # 7010 <malloc+0x170a>
    2fa6:	00002097          	auipc	ra,0x2
    2faa:	592080e7          	jalr	1426(ra) # 5538 <mkdir>
    2fae:	38051163          	bnez	a0,3330 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2fb2:	20200593          	li	a1,514
    2fb6:	00004517          	auipc	a0,0x4
    2fba:	08250513          	addi	a0,a0,130 # 7038 <malloc+0x1732>
    2fbe:	00002097          	auipc	ra,0x2
    2fc2:	552080e7          	jalr	1362(ra) # 5510 <open>
    2fc6:	84aa                	mv	s1,a0
  if(fd < 0){
    2fc8:	38054263          	bltz	a0,334c <subdir+0x42a>
  write(fd, "FF", 2);
    2fcc:	4609                	li	a2,2
    2fce:	00004597          	auipc	a1,0x4
    2fd2:	09a58593          	addi	a1,a1,154 # 7068 <malloc+0x1762>
    2fd6:	00002097          	auipc	ra,0x2
    2fda:	51a080e7          	jalr	1306(ra) # 54f0 <write>
  close(fd);
    2fde:	8526                	mv	a0,s1
    2fe0:	00002097          	auipc	ra,0x2
    2fe4:	518080e7          	jalr	1304(ra) # 54f8 <close>
  fd = open("dd/dd/../ff", 0);
    2fe8:	4581                	li	a1,0
    2fea:	00004517          	auipc	a0,0x4
    2fee:	08650513          	addi	a0,a0,134 # 7070 <malloc+0x176a>
    2ff2:	00002097          	auipc	ra,0x2
    2ff6:	51e080e7          	jalr	1310(ra) # 5510 <open>
    2ffa:	84aa                	mv	s1,a0
  if(fd < 0){
    2ffc:	36054663          	bltz	a0,3368 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3000:	660d                	lui	a2,0x3
    3002:	00009597          	auipc	a1,0x9
    3006:	92e58593          	addi	a1,a1,-1746 # b930 <buf>
    300a:	00002097          	auipc	ra,0x2
    300e:	4de080e7          	jalr	1246(ra) # 54e8 <read>
  if(cc != 2 || buf[0] != 'f'){
    3012:	4789                	li	a5,2
    3014:	36f51863          	bne	a0,a5,3384 <subdir+0x462>
    3018:	00009717          	auipc	a4,0x9
    301c:	91874703          	lbu	a4,-1768(a4) # b930 <buf>
    3020:	06600793          	li	a5,102
    3024:	36f71063          	bne	a4,a5,3384 <subdir+0x462>
  close(fd);
    3028:	8526                	mv	a0,s1
    302a:	00002097          	auipc	ra,0x2
    302e:	4ce080e7          	jalr	1230(ra) # 54f8 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3032:	00004597          	auipc	a1,0x4
    3036:	08e58593          	addi	a1,a1,142 # 70c0 <malloc+0x17ba>
    303a:	00004517          	auipc	a0,0x4
    303e:	ffe50513          	addi	a0,a0,-2 # 7038 <malloc+0x1732>
    3042:	00002097          	auipc	ra,0x2
    3046:	4ee080e7          	jalr	1262(ra) # 5530 <link>
    304a:	34051b63          	bnez	a0,33a0 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    304e:	00004517          	auipc	a0,0x4
    3052:	fea50513          	addi	a0,a0,-22 # 7038 <malloc+0x1732>
    3056:	00002097          	auipc	ra,0x2
    305a:	4ca080e7          	jalr	1226(ra) # 5520 <unlink>
    305e:	34051f63          	bnez	a0,33bc <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3062:	4581                	li	a1,0
    3064:	00004517          	auipc	a0,0x4
    3068:	fd450513          	addi	a0,a0,-44 # 7038 <malloc+0x1732>
    306c:	00002097          	auipc	ra,0x2
    3070:	4a4080e7          	jalr	1188(ra) # 5510 <open>
    3074:	36055263          	bgez	a0,33d8 <subdir+0x4b6>
  if(chdir("dd") != 0){
    3078:	00004517          	auipc	a0,0x4
    307c:	f2050513          	addi	a0,a0,-224 # 6f98 <malloc+0x1692>
    3080:	00002097          	auipc	ra,0x2
    3084:	4c0080e7          	jalr	1216(ra) # 5540 <chdir>
    3088:	36051663          	bnez	a0,33f4 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    308c:	00004517          	auipc	a0,0x4
    3090:	0cc50513          	addi	a0,a0,204 # 7158 <malloc+0x1852>
    3094:	00002097          	auipc	ra,0x2
    3098:	4ac080e7          	jalr	1196(ra) # 5540 <chdir>
    309c:	36051a63          	bnez	a0,3410 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    30a0:	00004517          	auipc	a0,0x4
    30a4:	0e850513          	addi	a0,a0,232 # 7188 <malloc+0x1882>
    30a8:	00002097          	auipc	ra,0x2
    30ac:	498080e7          	jalr	1176(ra) # 5540 <chdir>
    30b0:	36051e63          	bnez	a0,342c <subdir+0x50a>
  if(chdir("./..") != 0){
    30b4:	00004517          	auipc	a0,0x4
    30b8:	10450513          	addi	a0,a0,260 # 71b8 <malloc+0x18b2>
    30bc:	00002097          	auipc	ra,0x2
    30c0:	484080e7          	jalr	1156(ra) # 5540 <chdir>
    30c4:	38051263          	bnez	a0,3448 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    30c8:	4581                	li	a1,0
    30ca:	00004517          	auipc	a0,0x4
    30ce:	ff650513          	addi	a0,a0,-10 # 70c0 <malloc+0x17ba>
    30d2:	00002097          	auipc	ra,0x2
    30d6:	43e080e7          	jalr	1086(ra) # 5510 <open>
    30da:	84aa                	mv	s1,a0
  if(fd < 0){
    30dc:	38054463          	bltz	a0,3464 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    30e0:	660d                	lui	a2,0x3
    30e2:	00009597          	auipc	a1,0x9
    30e6:	84e58593          	addi	a1,a1,-1970 # b930 <buf>
    30ea:	00002097          	auipc	ra,0x2
    30ee:	3fe080e7          	jalr	1022(ra) # 54e8 <read>
    30f2:	4789                	li	a5,2
    30f4:	38f51663          	bne	a0,a5,3480 <subdir+0x55e>
  close(fd);
    30f8:	8526                	mv	a0,s1
    30fa:	00002097          	auipc	ra,0x2
    30fe:	3fe080e7          	jalr	1022(ra) # 54f8 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3102:	4581                	li	a1,0
    3104:	00004517          	auipc	a0,0x4
    3108:	f3450513          	addi	a0,a0,-204 # 7038 <malloc+0x1732>
    310c:	00002097          	auipc	ra,0x2
    3110:	404080e7          	jalr	1028(ra) # 5510 <open>
    3114:	38055463          	bgez	a0,349c <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3118:	20200593          	li	a1,514
    311c:	00004517          	auipc	a0,0x4
    3120:	12c50513          	addi	a0,a0,300 # 7248 <malloc+0x1942>
    3124:	00002097          	auipc	ra,0x2
    3128:	3ec080e7          	jalr	1004(ra) # 5510 <open>
    312c:	38055663          	bgez	a0,34b8 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3130:	20200593          	li	a1,514
    3134:	00004517          	auipc	a0,0x4
    3138:	14450513          	addi	a0,a0,324 # 7278 <malloc+0x1972>
    313c:	00002097          	auipc	ra,0x2
    3140:	3d4080e7          	jalr	980(ra) # 5510 <open>
    3144:	38055863          	bgez	a0,34d4 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3148:	20000593          	li	a1,512
    314c:	00004517          	auipc	a0,0x4
    3150:	e4c50513          	addi	a0,a0,-436 # 6f98 <malloc+0x1692>
    3154:	00002097          	auipc	ra,0x2
    3158:	3bc080e7          	jalr	956(ra) # 5510 <open>
    315c:	38055a63          	bgez	a0,34f0 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3160:	4589                	li	a1,2
    3162:	00004517          	auipc	a0,0x4
    3166:	e3650513          	addi	a0,a0,-458 # 6f98 <malloc+0x1692>
    316a:	00002097          	auipc	ra,0x2
    316e:	3a6080e7          	jalr	934(ra) # 5510 <open>
    3172:	38055d63          	bgez	a0,350c <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3176:	4585                	li	a1,1
    3178:	00004517          	auipc	a0,0x4
    317c:	e2050513          	addi	a0,a0,-480 # 6f98 <malloc+0x1692>
    3180:	00002097          	auipc	ra,0x2
    3184:	390080e7          	jalr	912(ra) # 5510 <open>
    3188:	3a055063          	bgez	a0,3528 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    318c:	00004597          	auipc	a1,0x4
    3190:	17c58593          	addi	a1,a1,380 # 7308 <malloc+0x1a02>
    3194:	00004517          	auipc	a0,0x4
    3198:	0b450513          	addi	a0,a0,180 # 7248 <malloc+0x1942>
    319c:	00002097          	auipc	ra,0x2
    31a0:	394080e7          	jalr	916(ra) # 5530 <link>
    31a4:	3a050063          	beqz	a0,3544 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    31a8:	00004597          	auipc	a1,0x4
    31ac:	16058593          	addi	a1,a1,352 # 7308 <malloc+0x1a02>
    31b0:	00004517          	auipc	a0,0x4
    31b4:	0c850513          	addi	a0,a0,200 # 7278 <malloc+0x1972>
    31b8:	00002097          	auipc	ra,0x2
    31bc:	378080e7          	jalr	888(ra) # 5530 <link>
    31c0:	3a050063          	beqz	a0,3560 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    31c4:	00004597          	auipc	a1,0x4
    31c8:	efc58593          	addi	a1,a1,-260 # 70c0 <malloc+0x17ba>
    31cc:	00004517          	auipc	a0,0x4
    31d0:	dec50513          	addi	a0,a0,-532 # 6fb8 <malloc+0x16b2>
    31d4:	00002097          	auipc	ra,0x2
    31d8:	35c080e7          	jalr	860(ra) # 5530 <link>
    31dc:	3a050063          	beqz	a0,357c <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    31e0:	00004517          	auipc	a0,0x4
    31e4:	06850513          	addi	a0,a0,104 # 7248 <malloc+0x1942>
    31e8:	00002097          	auipc	ra,0x2
    31ec:	350080e7          	jalr	848(ra) # 5538 <mkdir>
    31f0:	3a050463          	beqz	a0,3598 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    31f4:	00004517          	auipc	a0,0x4
    31f8:	08450513          	addi	a0,a0,132 # 7278 <malloc+0x1972>
    31fc:	00002097          	auipc	ra,0x2
    3200:	33c080e7          	jalr	828(ra) # 5538 <mkdir>
    3204:	3a050863          	beqz	a0,35b4 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3208:	00004517          	auipc	a0,0x4
    320c:	eb850513          	addi	a0,a0,-328 # 70c0 <malloc+0x17ba>
    3210:	00002097          	auipc	ra,0x2
    3214:	328080e7          	jalr	808(ra) # 5538 <mkdir>
    3218:	3a050c63          	beqz	a0,35d0 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    321c:	00004517          	auipc	a0,0x4
    3220:	05c50513          	addi	a0,a0,92 # 7278 <malloc+0x1972>
    3224:	00002097          	auipc	ra,0x2
    3228:	2fc080e7          	jalr	764(ra) # 5520 <unlink>
    322c:	3c050063          	beqz	a0,35ec <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3230:	00004517          	auipc	a0,0x4
    3234:	01850513          	addi	a0,a0,24 # 7248 <malloc+0x1942>
    3238:	00002097          	auipc	ra,0x2
    323c:	2e8080e7          	jalr	744(ra) # 5520 <unlink>
    3240:	3c050463          	beqz	a0,3608 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3244:	00004517          	auipc	a0,0x4
    3248:	d7450513          	addi	a0,a0,-652 # 6fb8 <malloc+0x16b2>
    324c:	00002097          	auipc	ra,0x2
    3250:	2f4080e7          	jalr	756(ra) # 5540 <chdir>
    3254:	3c050863          	beqz	a0,3624 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3258:	00004517          	auipc	a0,0x4
    325c:	20050513          	addi	a0,a0,512 # 7458 <malloc+0x1b52>
    3260:	00002097          	auipc	ra,0x2
    3264:	2e0080e7          	jalr	736(ra) # 5540 <chdir>
    3268:	3c050c63          	beqz	a0,3640 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    326c:	00004517          	auipc	a0,0x4
    3270:	e5450513          	addi	a0,a0,-428 # 70c0 <malloc+0x17ba>
    3274:	00002097          	auipc	ra,0x2
    3278:	2ac080e7          	jalr	684(ra) # 5520 <unlink>
    327c:	3e051063          	bnez	a0,365c <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3280:	00004517          	auipc	a0,0x4
    3284:	d3850513          	addi	a0,a0,-712 # 6fb8 <malloc+0x16b2>
    3288:	00002097          	auipc	ra,0x2
    328c:	298080e7          	jalr	664(ra) # 5520 <unlink>
    3290:	3e051463          	bnez	a0,3678 <subdir+0x756>
  if(unlink("dd") == 0){
    3294:	00004517          	auipc	a0,0x4
    3298:	d0450513          	addi	a0,a0,-764 # 6f98 <malloc+0x1692>
    329c:	00002097          	auipc	ra,0x2
    32a0:	284080e7          	jalr	644(ra) # 5520 <unlink>
    32a4:	3e050863          	beqz	a0,3694 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    32a8:	00004517          	auipc	a0,0x4
    32ac:	22050513          	addi	a0,a0,544 # 74c8 <malloc+0x1bc2>
    32b0:	00002097          	auipc	ra,0x2
    32b4:	270080e7          	jalr	624(ra) # 5520 <unlink>
    32b8:	3e054c63          	bltz	a0,36b0 <subdir+0x78e>
  if(unlink("dd") < 0){
    32bc:	00004517          	auipc	a0,0x4
    32c0:	cdc50513          	addi	a0,a0,-804 # 6f98 <malloc+0x1692>
    32c4:	00002097          	auipc	ra,0x2
    32c8:	25c080e7          	jalr	604(ra) # 5520 <unlink>
    32cc:	40054063          	bltz	a0,36cc <subdir+0x7aa>
}
    32d0:	60e2                	ld	ra,24(sp)
    32d2:	6442                	ld	s0,16(sp)
    32d4:	64a2                	ld	s1,8(sp)
    32d6:	6902                	ld	s2,0(sp)
    32d8:	6105                	addi	sp,sp,32
    32da:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    32dc:	85ca                	mv	a1,s2
    32de:	00004517          	auipc	a0,0x4
    32e2:	cc250513          	addi	a0,a0,-830 # 6fa0 <malloc+0x169a>
    32e6:	00002097          	auipc	ra,0x2
    32ea:	562080e7          	jalr	1378(ra) # 5848 <printf>
    exit(1);
    32ee:	4505                	li	a0,1
    32f0:	00002097          	auipc	ra,0x2
    32f4:	1e0080e7          	jalr	480(ra) # 54d0 <exit>
    printf("%s: create dd/ff failed\n", s);
    32f8:	85ca                	mv	a1,s2
    32fa:	00004517          	auipc	a0,0x4
    32fe:	cc650513          	addi	a0,a0,-826 # 6fc0 <malloc+0x16ba>
    3302:	00002097          	auipc	ra,0x2
    3306:	546080e7          	jalr	1350(ra) # 5848 <printf>
    exit(1);
    330a:	4505                	li	a0,1
    330c:	00002097          	auipc	ra,0x2
    3310:	1c4080e7          	jalr	452(ra) # 54d0 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3314:	85ca                	mv	a1,s2
    3316:	00004517          	auipc	a0,0x4
    331a:	cca50513          	addi	a0,a0,-822 # 6fe0 <malloc+0x16da>
    331e:	00002097          	auipc	ra,0x2
    3322:	52a080e7          	jalr	1322(ra) # 5848 <printf>
    exit(1);
    3326:	4505                	li	a0,1
    3328:	00002097          	auipc	ra,0x2
    332c:	1a8080e7          	jalr	424(ra) # 54d0 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3330:	85ca                	mv	a1,s2
    3332:	00004517          	auipc	a0,0x4
    3336:	ce650513          	addi	a0,a0,-794 # 7018 <malloc+0x1712>
    333a:	00002097          	auipc	ra,0x2
    333e:	50e080e7          	jalr	1294(ra) # 5848 <printf>
    exit(1);
    3342:	4505                	li	a0,1
    3344:	00002097          	auipc	ra,0x2
    3348:	18c080e7          	jalr	396(ra) # 54d0 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    334c:	85ca                	mv	a1,s2
    334e:	00004517          	auipc	a0,0x4
    3352:	cfa50513          	addi	a0,a0,-774 # 7048 <malloc+0x1742>
    3356:	00002097          	auipc	ra,0x2
    335a:	4f2080e7          	jalr	1266(ra) # 5848 <printf>
    exit(1);
    335e:	4505                	li	a0,1
    3360:	00002097          	auipc	ra,0x2
    3364:	170080e7          	jalr	368(ra) # 54d0 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3368:	85ca                	mv	a1,s2
    336a:	00004517          	auipc	a0,0x4
    336e:	d1650513          	addi	a0,a0,-746 # 7080 <malloc+0x177a>
    3372:	00002097          	auipc	ra,0x2
    3376:	4d6080e7          	jalr	1238(ra) # 5848 <printf>
    exit(1);
    337a:	4505                	li	a0,1
    337c:	00002097          	auipc	ra,0x2
    3380:	154080e7          	jalr	340(ra) # 54d0 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3384:	85ca                	mv	a1,s2
    3386:	00004517          	auipc	a0,0x4
    338a:	d1a50513          	addi	a0,a0,-742 # 70a0 <malloc+0x179a>
    338e:	00002097          	auipc	ra,0x2
    3392:	4ba080e7          	jalr	1210(ra) # 5848 <printf>
    exit(1);
    3396:	4505                	li	a0,1
    3398:	00002097          	auipc	ra,0x2
    339c:	138080e7          	jalr	312(ra) # 54d0 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    33a0:	85ca                	mv	a1,s2
    33a2:	00004517          	auipc	a0,0x4
    33a6:	d2e50513          	addi	a0,a0,-722 # 70d0 <malloc+0x17ca>
    33aa:	00002097          	auipc	ra,0x2
    33ae:	49e080e7          	jalr	1182(ra) # 5848 <printf>
    exit(1);
    33b2:	4505                	li	a0,1
    33b4:	00002097          	auipc	ra,0x2
    33b8:	11c080e7          	jalr	284(ra) # 54d0 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    33bc:	85ca                	mv	a1,s2
    33be:	00004517          	auipc	a0,0x4
    33c2:	d3a50513          	addi	a0,a0,-710 # 70f8 <malloc+0x17f2>
    33c6:	00002097          	auipc	ra,0x2
    33ca:	482080e7          	jalr	1154(ra) # 5848 <printf>
    exit(1);
    33ce:	4505                	li	a0,1
    33d0:	00002097          	auipc	ra,0x2
    33d4:	100080e7          	jalr	256(ra) # 54d0 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    33d8:	85ca                	mv	a1,s2
    33da:	00004517          	auipc	a0,0x4
    33de:	d3e50513          	addi	a0,a0,-706 # 7118 <malloc+0x1812>
    33e2:	00002097          	auipc	ra,0x2
    33e6:	466080e7          	jalr	1126(ra) # 5848 <printf>
    exit(1);
    33ea:	4505                	li	a0,1
    33ec:	00002097          	auipc	ra,0x2
    33f0:	0e4080e7          	jalr	228(ra) # 54d0 <exit>
    printf("%s: chdir dd failed\n", s);
    33f4:	85ca                	mv	a1,s2
    33f6:	00004517          	auipc	a0,0x4
    33fa:	d4a50513          	addi	a0,a0,-694 # 7140 <malloc+0x183a>
    33fe:	00002097          	auipc	ra,0x2
    3402:	44a080e7          	jalr	1098(ra) # 5848 <printf>
    exit(1);
    3406:	4505                	li	a0,1
    3408:	00002097          	auipc	ra,0x2
    340c:	0c8080e7          	jalr	200(ra) # 54d0 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3410:	85ca                	mv	a1,s2
    3412:	00004517          	auipc	a0,0x4
    3416:	d5650513          	addi	a0,a0,-682 # 7168 <malloc+0x1862>
    341a:	00002097          	auipc	ra,0x2
    341e:	42e080e7          	jalr	1070(ra) # 5848 <printf>
    exit(1);
    3422:	4505                	li	a0,1
    3424:	00002097          	auipc	ra,0x2
    3428:	0ac080e7          	jalr	172(ra) # 54d0 <exit>
    printf("chdir dd/../../dd failed\n", s);
    342c:	85ca                	mv	a1,s2
    342e:	00004517          	auipc	a0,0x4
    3432:	d6a50513          	addi	a0,a0,-662 # 7198 <malloc+0x1892>
    3436:	00002097          	auipc	ra,0x2
    343a:	412080e7          	jalr	1042(ra) # 5848 <printf>
    exit(1);
    343e:	4505                	li	a0,1
    3440:	00002097          	auipc	ra,0x2
    3444:	090080e7          	jalr	144(ra) # 54d0 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3448:	85ca                	mv	a1,s2
    344a:	00004517          	auipc	a0,0x4
    344e:	d7650513          	addi	a0,a0,-650 # 71c0 <malloc+0x18ba>
    3452:	00002097          	auipc	ra,0x2
    3456:	3f6080e7          	jalr	1014(ra) # 5848 <printf>
    exit(1);
    345a:	4505                	li	a0,1
    345c:	00002097          	auipc	ra,0x2
    3460:	074080e7          	jalr	116(ra) # 54d0 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3464:	85ca                	mv	a1,s2
    3466:	00004517          	auipc	a0,0x4
    346a:	d7250513          	addi	a0,a0,-654 # 71d8 <malloc+0x18d2>
    346e:	00002097          	auipc	ra,0x2
    3472:	3da080e7          	jalr	986(ra) # 5848 <printf>
    exit(1);
    3476:	4505                	li	a0,1
    3478:	00002097          	auipc	ra,0x2
    347c:	058080e7          	jalr	88(ra) # 54d0 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3480:	85ca                	mv	a1,s2
    3482:	00004517          	auipc	a0,0x4
    3486:	d7650513          	addi	a0,a0,-650 # 71f8 <malloc+0x18f2>
    348a:	00002097          	auipc	ra,0x2
    348e:	3be080e7          	jalr	958(ra) # 5848 <printf>
    exit(1);
    3492:	4505                	li	a0,1
    3494:	00002097          	auipc	ra,0x2
    3498:	03c080e7          	jalr	60(ra) # 54d0 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    349c:	85ca                	mv	a1,s2
    349e:	00004517          	auipc	a0,0x4
    34a2:	d7a50513          	addi	a0,a0,-646 # 7218 <malloc+0x1912>
    34a6:	00002097          	auipc	ra,0x2
    34aa:	3a2080e7          	jalr	930(ra) # 5848 <printf>
    exit(1);
    34ae:	4505                	li	a0,1
    34b0:	00002097          	auipc	ra,0x2
    34b4:	020080e7          	jalr	32(ra) # 54d0 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    34b8:	85ca                	mv	a1,s2
    34ba:	00004517          	auipc	a0,0x4
    34be:	d9e50513          	addi	a0,a0,-610 # 7258 <malloc+0x1952>
    34c2:	00002097          	auipc	ra,0x2
    34c6:	386080e7          	jalr	902(ra) # 5848 <printf>
    exit(1);
    34ca:	4505                	li	a0,1
    34cc:	00002097          	auipc	ra,0x2
    34d0:	004080e7          	jalr	4(ra) # 54d0 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    34d4:	85ca                	mv	a1,s2
    34d6:	00004517          	auipc	a0,0x4
    34da:	db250513          	addi	a0,a0,-590 # 7288 <malloc+0x1982>
    34de:	00002097          	auipc	ra,0x2
    34e2:	36a080e7          	jalr	874(ra) # 5848 <printf>
    exit(1);
    34e6:	4505                	li	a0,1
    34e8:	00002097          	auipc	ra,0x2
    34ec:	fe8080e7          	jalr	-24(ra) # 54d0 <exit>
    printf("%s: create dd succeeded!\n", s);
    34f0:	85ca                	mv	a1,s2
    34f2:	00004517          	auipc	a0,0x4
    34f6:	db650513          	addi	a0,a0,-586 # 72a8 <malloc+0x19a2>
    34fa:	00002097          	auipc	ra,0x2
    34fe:	34e080e7          	jalr	846(ra) # 5848 <printf>
    exit(1);
    3502:	4505                	li	a0,1
    3504:	00002097          	auipc	ra,0x2
    3508:	fcc080e7          	jalr	-52(ra) # 54d0 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    350c:	85ca                	mv	a1,s2
    350e:	00004517          	auipc	a0,0x4
    3512:	dba50513          	addi	a0,a0,-582 # 72c8 <malloc+0x19c2>
    3516:	00002097          	auipc	ra,0x2
    351a:	332080e7          	jalr	818(ra) # 5848 <printf>
    exit(1);
    351e:	4505                	li	a0,1
    3520:	00002097          	auipc	ra,0x2
    3524:	fb0080e7          	jalr	-80(ra) # 54d0 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3528:	85ca                	mv	a1,s2
    352a:	00004517          	auipc	a0,0x4
    352e:	dbe50513          	addi	a0,a0,-578 # 72e8 <malloc+0x19e2>
    3532:	00002097          	auipc	ra,0x2
    3536:	316080e7          	jalr	790(ra) # 5848 <printf>
    exit(1);
    353a:	4505                	li	a0,1
    353c:	00002097          	auipc	ra,0x2
    3540:	f94080e7          	jalr	-108(ra) # 54d0 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3544:	85ca                	mv	a1,s2
    3546:	00004517          	auipc	a0,0x4
    354a:	dd250513          	addi	a0,a0,-558 # 7318 <malloc+0x1a12>
    354e:	00002097          	auipc	ra,0x2
    3552:	2fa080e7          	jalr	762(ra) # 5848 <printf>
    exit(1);
    3556:	4505                	li	a0,1
    3558:	00002097          	auipc	ra,0x2
    355c:	f78080e7          	jalr	-136(ra) # 54d0 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3560:	85ca                	mv	a1,s2
    3562:	00004517          	auipc	a0,0x4
    3566:	dde50513          	addi	a0,a0,-546 # 7340 <malloc+0x1a3a>
    356a:	00002097          	auipc	ra,0x2
    356e:	2de080e7          	jalr	734(ra) # 5848 <printf>
    exit(1);
    3572:	4505                	li	a0,1
    3574:	00002097          	auipc	ra,0x2
    3578:	f5c080e7          	jalr	-164(ra) # 54d0 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    357c:	85ca                	mv	a1,s2
    357e:	00004517          	auipc	a0,0x4
    3582:	dea50513          	addi	a0,a0,-534 # 7368 <malloc+0x1a62>
    3586:	00002097          	auipc	ra,0x2
    358a:	2c2080e7          	jalr	706(ra) # 5848 <printf>
    exit(1);
    358e:	4505                	li	a0,1
    3590:	00002097          	auipc	ra,0x2
    3594:	f40080e7          	jalr	-192(ra) # 54d0 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3598:	85ca                	mv	a1,s2
    359a:	00004517          	auipc	a0,0x4
    359e:	df650513          	addi	a0,a0,-522 # 7390 <malloc+0x1a8a>
    35a2:	00002097          	auipc	ra,0x2
    35a6:	2a6080e7          	jalr	678(ra) # 5848 <printf>
    exit(1);
    35aa:	4505                	li	a0,1
    35ac:	00002097          	auipc	ra,0x2
    35b0:	f24080e7          	jalr	-220(ra) # 54d0 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    35b4:	85ca                	mv	a1,s2
    35b6:	00004517          	auipc	a0,0x4
    35ba:	dfa50513          	addi	a0,a0,-518 # 73b0 <malloc+0x1aaa>
    35be:	00002097          	auipc	ra,0x2
    35c2:	28a080e7          	jalr	650(ra) # 5848 <printf>
    exit(1);
    35c6:	4505                	li	a0,1
    35c8:	00002097          	auipc	ra,0x2
    35cc:	f08080e7          	jalr	-248(ra) # 54d0 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    35d0:	85ca                	mv	a1,s2
    35d2:	00004517          	auipc	a0,0x4
    35d6:	dfe50513          	addi	a0,a0,-514 # 73d0 <malloc+0x1aca>
    35da:	00002097          	auipc	ra,0x2
    35de:	26e080e7          	jalr	622(ra) # 5848 <printf>
    exit(1);
    35e2:	4505                	li	a0,1
    35e4:	00002097          	auipc	ra,0x2
    35e8:	eec080e7          	jalr	-276(ra) # 54d0 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    35ec:	85ca                	mv	a1,s2
    35ee:	00004517          	auipc	a0,0x4
    35f2:	e0a50513          	addi	a0,a0,-502 # 73f8 <malloc+0x1af2>
    35f6:	00002097          	auipc	ra,0x2
    35fa:	252080e7          	jalr	594(ra) # 5848 <printf>
    exit(1);
    35fe:	4505                	li	a0,1
    3600:	00002097          	auipc	ra,0x2
    3604:	ed0080e7          	jalr	-304(ra) # 54d0 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3608:	85ca                	mv	a1,s2
    360a:	00004517          	auipc	a0,0x4
    360e:	e0e50513          	addi	a0,a0,-498 # 7418 <malloc+0x1b12>
    3612:	00002097          	auipc	ra,0x2
    3616:	236080e7          	jalr	566(ra) # 5848 <printf>
    exit(1);
    361a:	4505                	li	a0,1
    361c:	00002097          	auipc	ra,0x2
    3620:	eb4080e7          	jalr	-332(ra) # 54d0 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3624:	85ca                	mv	a1,s2
    3626:	00004517          	auipc	a0,0x4
    362a:	e1250513          	addi	a0,a0,-494 # 7438 <malloc+0x1b32>
    362e:	00002097          	auipc	ra,0x2
    3632:	21a080e7          	jalr	538(ra) # 5848 <printf>
    exit(1);
    3636:	4505                	li	a0,1
    3638:	00002097          	auipc	ra,0x2
    363c:	e98080e7          	jalr	-360(ra) # 54d0 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3640:	85ca                	mv	a1,s2
    3642:	00004517          	auipc	a0,0x4
    3646:	e1e50513          	addi	a0,a0,-482 # 7460 <malloc+0x1b5a>
    364a:	00002097          	auipc	ra,0x2
    364e:	1fe080e7          	jalr	510(ra) # 5848 <printf>
    exit(1);
    3652:	4505                	li	a0,1
    3654:	00002097          	auipc	ra,0x2
    3658:	e7c080e7          	jalr	-388(ra) # 54d0 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    365c:	85ca                	mv	a1,s2
    365e:	00004517          	auipc	a0,0x4
    3662:	a9a50513          	addi	a0,a0,-1382 # 70f8 <malloc+0x17f2>
    3666:	00002097          	auipc	ra,0x2
    366a:	1e2080e7          	jalr	482(ra) # 5848 <printf>
    exit(1);
    366e:	4505                	li	a0,1
    3670:	00002097          	auipc	ra,0x2
    3674:	e60080e7          	jalr	-416(ra) # 54d0 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3678:	85ca                	mv	a1,s2
    367a:	00004517          	auipc	a0,0x4
    367e:	e0650513          	addi	a0,a0,-506 # 7480 <malloc+0x1b7a>
    3682:	00002097          	auipc	ra,0x2
    3686:	1c6080e7          	jalr	454(ra) # 5848 <printf>
    exit(1);
    368a:	4505                	li	a0,1
    368c:	00002097          	auipc	ra,0x2
    3690:	e44080e7          	jalr	-444(ra) # 54d0 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3694:	85ca                	mv	a1,s2
    3696:	00004517          	auipc	a0,0x4
    369a:	e0a50513          	addi	a0,a0,-502 # 74a0 <malloc+0x1b9a>
    369e:	00002097          	auipc	ra,0x2
    36a2:	1aa080e7          	jalr	426(ra) # 5848 <printf>
    exit(1);
    36a6:	4505                	li	a0,1
    36a8:	00002097          	auipc	ra,0x2
    36ac:	e28080e7          	jalr	-472(ra) # 54d0 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    36b0:	85ca                	mv	a1,s2
    36b2:	00004517          	auipc	a0,0x4
    36b6:	e1e50513          	addi	a0,a0,-482 # 74d0 <malloc+0x1bca>
    36ba:	00002097          	auipc	ra,0x2
    36be:	18e080e7          	jalr	398(ra) # 5848 <printf>
    exit(1);
    36c2:	4505                	li	a0,1
    36c4:	00002097          	auipc	ra,0x2
    36c8:	e0c080e7          	jalr	-500(ra) # 54d0 <exit>
    printf("%s: unlink dd failed\n", s);
    36cc:	85ca                	mv	a1,s2
    36ce:	00004517          	auipc	a0,0x4
    36d2:	e2250513          	addi	a0,a0,-478 # 74f0 <malloc+0x1bea>
    36d6:	00002097          	auipc	ra,0x2
    36da:	172080e7          	jalr	370(ra) # 5848 <printf>
    exit(1);
    36de:	4505                	li	a0,1
    36e0:	00002097          	auipc	ra,0x2
    36e4:	df0080e7          	jalr	-528(ra) # 54d0 <exit>

00000000000036e8 <rmdot>:
{
    36e8:	1101                	addi	sp,sp,-32
    36ea:	ec06                	sd	ra,24(sp)
    36ec:	e822                	sd	s0,16(sp)
    36ee:	e426                	sd	s1,8(sp)
    36f0:	1000                	addi	s0,sp,32
    36f2:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    36f4:	00004517          	auipc	a0,0x4
    36f8:	e1450513          	addi	a0,a0,-492 # 7508 <malloc+0x1c02>
    36fc:	00002097          	auipc	ra,0x2
    3700:	e3c080e7          	jalr	-452(ra) # 5538 <mkdir>
    3704:	e549                	bnez	a0,378e <rmdot+0xa6>
  if(chdir("dots") != 0){
    3706:	00004517          	auipc	a0,0x4
    370a:	e0250513          	addi	a0,a0,-510 # 7508 <malloc+0x1c02>
    370e:	00002097          	auipc	ra,0x2
    3712:	e32080e7          	jalr	-462(ra) # 5540 <chdir>
    3716:	e951                	bnez	a0,37aa <rmdot+0xc2>
  if(unlink(".") == 0){
    3718:	00003517          	auipc	a0,0x3
    371c:	cb850513          	addi	a0,a0,-840 # 63d0 <malloc+0xaca>
    3720:	00002097          	auipc	ra,0x2
    3724:	e00080e7          	jalr	-512(ra) # 5520 <unlink>
    3728:	cd59                	beqz	a0,37c6 <rmdot+0xde>
  if(unlink("..") == 0){
    372a:	00004517          	auipc	a0,0x4
    372e:	83650513          	addi	a0,a0,-1994 # 6f60 <malloc+0x165a>
    3732:	00002097          	auipc	ra,0x2
    3736:	dee080e7          	jalr	-530(ra) # 5520 <unlink>
    373a:	c545                	beqz	a0,37e2 <rmdot+0xfa>
  if(chdir("/") != 0){
    373c:	00003517          	auipc	a0,0x3
    3740:	7cc50513          	addi	a0,a0,1996 # 6f08 <malloc+0x1602>
    3744:	00002097          	auipc	ra,0x2
    3748:	dfc080e7          	jalr	-516(ra) # 5540 <chdir>
    374c:	e94d                	bnez	a0,37fe <rmdot+0x116>
  if(unlink("dots/.") == 0){
    374e:	00004517          	auipc	a0,0x4
    3752:	e2250513          	addi	a0,a0,-478 # 7570 <malloc+0x1c6a>
    3756:	00002097          	auipc	ra,0x2
    375a:	dca080e7          	jalr	-566(ra) # 5520 <unlink>
    375e:	cd55                	beqz	a0,381a <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3760:	00004517          	auipc	a0,0x4
    3764:	e3850513          	addi	a0,a0,-456 # 7598 <malloc+0x1c92>
    3768:	00002097          	auipc	ra,0x2
    376c:	db8080e7          	jalr	-584(ra) # 5520 <unlink>
    3770:	c179                	beqz	a0,3836 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3772:	00004517          	auipc	a0,0x4
    3776:	d9650513          	addi	a0,a0,-618 # 7508 <malloc+0x1c02>
    377a:	00002097          	auipc	ra,0x2
    377e:	da6080e7          	jalr	-602(ra) # 5520 <unlink>
    3782:	e961                	bnez	a0,3852 <rmdot+0x16a>
}
    3784:	60e2                	ld	ra,24(sp)
    3786:	6442                	ld	s0,16(sp)
    3788:	64a2                	ld	s1,8(sp)
    378a:	6105                	addi	sp,sp,32
    378c:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    378e:	85a6                	mv	a1,s1
    3790:	00004517          	auipc	a0,0x4
    3794:	d8050513          	addi	a0,a0,-640 # 7510 <malloc+0x1c0a>
    3798:	00002097          	auipc	ra,0x2
    379c:	0b0080e7          	jalr	176(ra) # 5848 <printf>
    exit(1);
    37a0:	4505                	li	a0,1
    37a2:	00002097          	auipc	ra,0x2
    37a6:	d2e080e7          	jalr	-722(ra) # 54d0 <exit>
    printf("%s: chdir dots failed\n", s);
    37aa:	85a6                	mv	a1,s1
    37ac:	00004517          	auipc	a0,0x4
    37b0:	d7c50513          	addi	a0,a0,-644 # 7528 <malloc+0x1c22>
    37b4:	00002097          	auipc	ra,0x2
    37b8:	094080e7          	jalr	148(ra) # 5848 <printf>
    exit(1);
    37bc:	4505                	li	a0,1
    37be:	00002097          	auipc	ra,0x2
    37c2:	d12080e7          	jalr	-750(ra) # 54d0 <exit>
    printf("%s: rm . worked!\n", s);
    37c6:	85a6                	mv	a1,s1
    37c8:	00004517          	auipc	a0,0x4
    37cc:	d7850513          	addi	a0,a0,-648 # 7540 <malloc+0x1c3a>
    37d0:	00002097          	auipc	ra,0x2
    37d4:	078080e7          	jalr	120(ra) # 5848 <printf>
    exit(1);
    37d8:	4505                	li	a0,1
    37da:	00002097          	auipc	ra,0x2
    37de:	cf6080e7          	jalr	-778(ra) # 54d0 <exit>
    printf("%s: rm .. worked!\n", s);
    37e2:	85a6                	mv	a1,s1
    37e4:	00004517          	auipc	a0,0x4
    37e8:	d7450513          	addi	a0,a0,-652 # 7558 <malloc+0x1c52>
    37ec:	00002097          	auipc	ra,0x2
    37f0:	05c080e7          	jalr	92(ra) # 5848 <printf>
    exit(1);
    37f4:	4505                	li	a0,1
    37f6:	00002097          	auipc	ra,0x2
    37fa:	cda080e7          	jalr	-806(ra) # 54d0 <exit>
    printf("%s: chdir / failed\n", s);
    37fe:	85a6                	mv	a1,s1
    3800:	00003517          	auipc	a0,0x3
    3804:	71050513          	addi	a0,a0,1808 # 6f10 <malloc+0x160a>
    3808:	00002097          	auipc	ra,0x2
    380c:	040080e7          	jalr	64(ra) # 5848 <printf>
    exit(1);
    3810:	4505                	li	a0,1
    3812:	00002097          	auipc	ra,0x2
    3816:	cbe080e7          	jalr	-834(ra) # 54d0 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    381a:	85a6                	mv	a1,s1
    381c:	00004517          	auipc	a0,0x4
    3820:	d5c50513          	addi	a0,a0,-676 # 7578 <malloc+0x1c72>
    3824:	00002097          	auipc	ra,0x2
    3828:	024080e7          	jalr	36(ra) # 5848 <printf>
    exit(1);
    382c:	4505                	li	a0,1
    382e:	00002097          	auipc	ra,0x2
    3832:	ca2080e7          	jalr	-862(ra) # 54d0 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3836:	85a6                	mv	a1,s1
    3838:	00004517          	auipc	a0,0x4
    383c:	d6850513          	addi	a0,a0,-664 # 75a0 <malloc+0x1c9a>
    3840:	00002097          	auipc	ra,0x2
    3844:	008080e7          	jalr	8(ra) # 5848 <printf>
    exit(1);
    3848:	4505                	li	a0,1
    384a:	00002097          	auipc	ra,0x2
    384e:	c86080e7          	jalr	-890(ra) # 54d0 <exit>
    printf("%s: unlink dots failed!\n", s);
    3852:	85a6                	mv	a1,s1
    3854:	00004517          	auipc	a0,0x4
    3858:	d6c50513          	addi	a0,a0,-660 # 75c0 <malloc+0x1cba>
    385c:	00002097          	auipc	ra,0x2
    3860:	fec080e7          	jalr	-20(ra) # 5848 <printf>
    exit(1);
    3864:	4505                	li	a0,1
    3866:	00002097          	auipc	ra,0x2
    386a:	c6a080e7          	jalr	-918(ra) # 54d0 <exit>

000000000000386e <dirfile>:
{
    386e:	1101                	addi	sp,sp,-32
    3870:	ec06                	sd	ra,24(sp)
    3872:	e822                	sd	s0,16(sp)
    3874:	e426                	sd	s1,8(sp)
    3876:	e04a                	sd	s2,0(sp)
    3878:	1000                	addi	s0,sp,32
    387a:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    387c:	20000593          	li	a1,512
    3880:	00002517          	auipc	a0,0x2
    3884:	45850513          	addi	a0,a0,1112 # 5cd8 <malloc+0x3d2>
    3888:	00002097          	auipc	ra,0x2
    388c:	c88080e7          	jalr	-888(ra) # 5510 <open>
  if(fd < 0){
    3890:	0e054d63          	bltz	a0,398a <dirfile+0x11c>
  close(fd);
    3894:	00002097          	auipc	ra,0x2
    3898:	c64080e7          	jalr	-924(ra) # 54f8 <close>
  if(chdir("dirfile") == 0){
    389c:	00002517          	auipc	a0,0x2
    38a0:	43c50513          	addi	a0,a0,1084 # 5cd8 <malloc+0x3d2>
    38a4:	00002097          	auipc	ra,0x2
    38a8:	c9c080e7          	jalr	-868(ra) # 5540 <chdir>
    38ac:	cd6d                	beqz	a0,39a6 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    38ae:	4581                	li	a1,0
    38b0:	00004517          	auipc	a0,0x4
    38b4:	d7050513          	addi	a0,a0,-656 # 7620 <malloc+0x1d1a>
    38b8:	00002097          	auipc	ra,0x2
    38bc:	c58080e7          	jalr	-936(ra) # 5510 <open>
  if(fd >= 0){
    38c0:	10055163          	bgez	a0,39c2 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    38c4:	20000593          	li	a1,512
    38c8:	00004517          	auipc	a0,0x4
    38cc:	d5850513          	addi	a0,a0,-680 # 7620 <malloc+0x1d1a>
    38d0:	00002097          	auipc	ra,0x2
    38d4:	c40080e7          	jalr	-960(ra) # 5510 <open>
  if(fd >= 0){
    38d8:	10055363          	bgez	a0,39de <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    38dc:	00004517          	auipc	a0,0x4
    38e0:	d4450513          	addi	a0,a0,-700 # 7620 <malloc+0x1d1a>
    38e4:	00002097          	auipc	ra,0x2
    38e8:	c54080e7          	jalr	-940(ra) # 5538 <mkdir>
    38ec:	10050763          	beqz	a0,39fa <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    38f0:	00004517          	auipc	a0,0x4
    38f4:	d3050513          	addi	a0,a0,-720 # 7620 <malloc+0x1d1a>
    38f8:	00002097          	auipc	ra,0x2
    38fc:	c28080e7          	jalr	-984(ra) # 5520 <unlink>
    3900:	10050b63          	beqz	a0,3a16 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3904:	00004597          	auipc	a1,0x4
    3908:	d1c58593          	addi	a1,a1,-740 # 7620 <malloc+0x1d1a>
    390c:	00002517          	auipc	a0,0x2
    3910:	5c450513          	addi	a0,a0,1476 # 5ed0 <malloc+0x5ca>
    3914:	00002097          	auipc	ra,0x2
    3918:	c1c080e7          	jalr	-996(ra) # 5530 <link>
    391c:	10050b63          	beqz	a0,3a32 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3920:	00002517          	auipc	a0,0x2
    3924:	3b850513          	addi	a0,a0,952 # 5cd8 <malloc+0x3d2>
    3928:	00002097          	auipc	ra,0x2
    392c:	bf8080e7          	jalr	-1032(ra) # 5520 <unlink>
    3930:	10051f63          	bnez	a0,3a4e <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3934:	4589                	li	a1,2
    3936:	00003517          	auipc	a0,0x3
    393a:	a9a50513          	addi	a0,a0,-1382 # 63d0 <malloc+0xaca>
    393e:	00002097          	auipc	ra,0x2
    3942:	bd2080e7          	jalr	-1070(ra) # 5510 <open>
  if(fd >= 0){
    3946:	12055263          	bgez	a0,3a6a <dirfile+0x1fc>
  fd = open(".", 0);
    394a:	4581                	li	a1,0
    394c:	00003517          	auipc	a0,0x3
    3950:	a8450513          	addi	a0,a0,-1404 # 63d0 <malloc+0xaca>
    3954:	00002097          	auipc	ra,0x2
    3958:	bbc080e7          	jalr	-1092(ra) # 5510 <open>
    395c:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    395e:	4605                	li	a2,1
    3960:	00002597          	auipc	a1,0x2
    3964:	44858593          	addi	a1,a1,1096 # 5da8 <malloc+0x4a2>
    3968:	00002097          	auipc	ra,0x2
    396c:	b88080e7          	jalr	-1144(ra) # 54f0 <write>
    3970:	10a04b63          	bgtz	a0,3a86 <dirfile+0x218>
  close(fd);
    3974:	8526                	mv	a0,s1
    3976:	00002097          	auipc	ra,0x2
    397a:	b82080e7          	jalr	-1150(ra) # 54f8 <close>
}
    397e:	60e2                	ld	ra,24(sp)
    3980:	6442                	ld	s0,16(sp)
    3982:	64a2                	ld	s1,8(sp)
    3984:	6902                	ld	s2,0(sp)
    3986:	6105                	addi	sp,sp,32
    3988:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    398a:	85ca                	mv	a1,s2
    398c:	00004517          	auipc	a0,0x4
    3990:	c5450513          	addi	a0,a0,-940 # 75e0 <malloc+0x1cda>
    3994:	00002097          	auipc	ra,0x2
    3998:	eb4080e7          	jalr	-332(ra) # 5848 <printf>
    exit(1);
    399c:	4505                	li	a0,1
    399e:	00002097          	auipc	ra,0x2
    39a2:	b32080e7          	jalr	-1230(ra) # 54d0 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    39a6:	85ca                	mv	a1,s2
    39a8:	00004517          	auipc	a0,0x4
    39ac:	c5850513          	addi	a0,a0,-936 # 7600 <malloc+0x1cfa>
    39b0:	00002097          	auipc	ra,0x2
    39b4:	e98080e7          	jalr	-360(ra) # 5848 <printf>
    exit(1);
    39b8:	4505                	li	a0,1
    39ba:	00002097          	auipc	ra,0x2
    39be:	b16080e7          	jalr	-1258(ra) # 54d0 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    39c2:	85ca                	mv	a1,s2
    39c4:	00004517          	auipc	a0,0x4
    39c8:	c6c50513          	addi	a0,a0,-916 # 7630 <malloc+0x1d2a>
    39cc:	00002097          	auipc	ra,0x2
    39d0:	e7c080e7          	jalr	-388(ra) # 5848 <printf>
    exit(1);
    39d4:	4505                	li	a0,1
    39d6:	00002097          	auipc	ra,0x2
    39da:	afa080e7          	jalr	-1286(ra) # 54d0 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    39de:	85ca                	mv	a1,s2
    39e0:	00004517          	auipc	a0,0x4
    39e4:	c5050513          	addi	a0,a0,-944 # 7630 <malloc+0x1d2a>
    39e8:	00002097          	auipc	ra,0x2
    39ec:	e60080e7          	jalr	-416(ra) # 5848 <printf>
    exit(1);
    39f0:	4505                	li	a0,1
    39f2:	00002097          	auipc	ra,0x2
    39f6:	ade080e7          	jalr	-1314(ra) # 54d0 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    39fa:	85ca                	mv	a1,s2
    39fc:	00004517          	auipc	a0,0x4
    3a00:	c5c50513          	addi	a0,a0,-932 # 7658 <malloc+0x1d52>
    3a04:	00002097          	auipc	ra,0x2
    3a08:	e44080e7          	jalr	-444(ra) # 5848 <printf>
    exit(1);
    3a0c:	4505                	li	a0,1
    3a0e:	00002097          	auipc	ra,0x2
    3a12:	ac2080e7          	jalr	-1342(ra) # 54d0 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3a16:	85ca                	mv	a1,s2
    3a18:	00004517          	auipc	a0,0x4
    3a1c:	c6850513          	addi	a0,a0,-920 # 7680 <malloc+0x1d7a>
    3a20:	00002097          	auipc	ra,0x2
    3a24:	e28080e7          	jalr	-472(ra) # 5848 <printf>
    exit(1);
    3a28:	4505                	li	a0,1
    3a2a:	00002097          	auipc	ra,0x2
    3a2e:	aa6080e7          	jalr	-1370(ra) # 54d0 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3a32:	85ca                	mv	a1,s2
    3a34:	00004517          	auipc	a0,0x4
    3a38:	c7450513          	addi	a0,a0,-908 # 76a8 <malloc+0x1da2>
    3a3c:	00002097          	auipc	ra,0x2
    3a40:	e0c080e7          	jalr	-500(ra) # 5848 <printf>
    exit(1);
    3a44:	4505                	li	a0,1
    3a46:	00002097          	auipc	ra,0x2
    3a4a:	a8a080e7          	jalr	-1398(ra) # 54d0 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3a4e:	85ca                	mv	a1,s2
    3a50:	00004517          	auipc	a0,0x4
    3a54:	c8050513          	addi	a0,a0,-896 # 76d0 <malloc+0x1dca>
    3a58:	00002097          	auipc	ra,0x2
    3a5c:	df0080e7          	jalr	-528(ra) # 5848 <printf>
    exit(1);
    3a60:	4505                	li	a0,1
    3a62:	00002097          	auipc	ra,0x2
    3a66:	a6e080e7          	jalr	-1426(ra) # 54d0 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3a6a:	85ca                	mv	a1,s2
    3a6c:	00004517          	auipc	a0,0x4
    3a70:	c8450513          	addi	a0,a0,-892 # 76f0 <malloc+0x1dea>
    3a74:	00002097          	auipc	ra,0x2
    3a78:	dd4080e7          	jalr	-556(ra) # 5848 <printf>
    exit(1);
    3a7c:	4505                	li	a0,1
    3a7e:	00002097          	auipc	ra,0x2
    3a82:	a52080e7          	jalr	-1454(ra) # 54d0 <exit>
    printf("%s: write . succeeded!\n", s);
    3a86:	85ca                	mv	a1,s2
    3a88:	00004517          	auipc	a0,0x4
    3a8c:	c9050513          	addi	a0,a0,-880 # 7718 <malloc+0x1e12>
    3a90:	00002097          	auipc	ra,0x2
    3a94:	db8080e7          	jalr	-584(ra) # 5848 <printf>
    exit(1);
    3a98:	4505                	li	a0,1
    3a9a:	00002097          	auipc	ra,0x2
    3a9e:	a36080e7          	jalr	-1482(ra) # 54d0 <exit>

0000000000003aa2 <iref>:
{
    3aa2:	7139                	addi	sp,sp,-64
    3aa4:	fc06                	sd	ra,56(sp)
    3aa6:	f822                	sd	s0,48(sp)
    3aa8:	f426                	sd	s1,40(sp)
    3aaa:	f04a                	sd	s2,32(sp)
    3aac:	ec4e                	sd	s3,24(sp)
    3aae:	e852                	sd	s4,16(sp)
    3ab0:	e456                	sd	s5,8(sp)
    3ab2:	e05a                	sd	s6,0(sp)
    3ab4:	0080                	addi	s0,sp,64
    3ab6:	8b2a                	mv	s6,a0
    3ab8:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3abc:	00004a17          	auipc	s4,0x4
    3ac0:	c74a0a13          	addi	s4,s4,-908 # 7730 <malloc+0x1e2a>
    mkdir("");
    3ac4:	00003497          	auipc	s1,0x3
    3ac8:	77c48493          	addi	s1,s1,1916 # 7240 <malloc+0x193a>
    link("README", "");
    3acc:	00002a97          	auipc	s5,0x2
    3ad0:	404a8a93          	addi	s5,s5,1028 # 5ed0 <malloc+0x5ca>
    fd = open("xx", O_CREATE);
    3ad4:	00004997          	auipc	s3,0x4
    3ad8:	b5498993          	addi	s3,s3,-1196 # 7628 <malloc+0x1d22>
    3adc:	a891                	j	3b30 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3ade:	85da                	mv	a1,s6
    3ae0:	00004517          	auipc	a0,0x4
    3ae4:	c5850513          	addi	a0,a0,-936 # 7738 <malloc+0x1e32>
    3ae8:	00002097          	auipc	ra,0x2
    3aec:	d60080e7          	jalr	-672(ra) # 5848 <printf>
      exit(1);
    3af0:	4505                	li	a0,1
    3af2:	00002097          	auipc	ra,0x2
    3af6:	9de080e7          	jalr	-1570(ra) # 54d0 <exit>
      printf("%s: chdir irefd failed\n", s);
    3afa:	85da                	mv	a1,s6
    3afc:	00004517          	auipc	a0,0x4
    3b00:	c5450513          	addi	a0,a0,-940 # 7750 <malloc+0x1e4a>
    3b04:	00002097          	auipc	ra,0x2
    3b08:	d44080e7          	jalr	-700(ra) # 5848 <printf>
      exit(1);
    3b0c:	4505                	li	a0,1
    3b0e:	00002097          	auipc	ra,0x2
    3b12:	9c2080e7          	jalr	-1598(ra) # 54d0 <exit>
      close(fd);
    3b16:	00002097          	auipc	ra,0x2
    3b1a:	9e2080e7          	jalr	-1566(ra) # 54f8 <close>
    3b1e:	a889                	j	3b70 <iref+0xce>
    unlink("xx");
    3b20:	854e                	mv	a0,s3
    3b22:	00002097          	auipc	ra,0x2
    3b26:	9fe080e7          	jalr	-1538(ra) # 5520 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3b2a:	397d                	addiw	s2,s2,-1
    3b2c:	06090063          	beqz	s2,3b8c <iref+0xea>
    if(mkdir("irefd") != 0){
    3b30:	8552                	mv	a0,s4
    3b32:	00002097          	auipc	ra,0x2
    3b36:	a06080e7          	jalr	-1530(ra) # 5538 <mkdir>
    3b3a:	f155                	bnez	a0,3ade <iref+0x3c>
    if(chdir("irefd") != 0){
    3b3c:	8552                	mv	a0,s4
    3b3e:	00002097          	auipc	ra,0x2
    3b42:	a02080e7          	jalr	-1534(ra) # 5540 <chdir>
    3b46:	f955                	bnez	a0,3afa <iref+0x58>
    mkdir("");
    3b48:	8526                	mv	a0,s1
    3b4a:	00002097          	auipc	ra,0x2
    3b4e:	9ee080e7          	jalr	-1554(ra) # 5538 <mkdir>
    link("README", "");
    3b52:	85a6                	mv	a1,s1
    3b54:	8556                	mv	a0,s5
    3b56:	00002097          	auipc	ra,0x2
    3b5a:	9da080e7          	jalr	-1574(ra) # 5530 <link>
    fd = open("", O_CREATE);
    3b5e:	20000593          	li	a1,512
    3b62:	8526                	mv	a0,s1
    3b64:	00002097          	auipc	ra,0x2
    3b68:	9ac080e7          	jalr	-1620(ra) # 5510 <open>
    if(fd >= 0)
    3b6c:	fa0555e3          	bgez	a0,3b16 <iref+0x74>
    fd = open("xx", O_CREATE);
    3b70:	20000593          	li	a1,512
    3b74:	854e                	mv	a0,s3
    3b76:	00002097          	auipc	ra,0x2
    3b7a:	99a080e7          	jalr	-1638(ra) # 5510 <open>
    if(fd >= 0)
    3b7e:	fa0541e3          	bltz	a0,3b20 <iref+0x7e>
      close(fd);
    3b82:	00002097          	auipc	ra,0x2
    3b86:	976080e7          	jalr	-1674(ra) # 54f8 <close>
    3b8a:	bf59                	j	3b20 <iref+0x7e>
    3b8c:	03300493          	li	s1,51
    chdir("..");
    3b90:	00003997          	auipc	s3,0x3
    3b94:	3d098993          	addi	s3,s3,976 # 6f60 <malloc+0x165a>
    unlink("irefd");
    3b98:	00004917          	auipc	s2,0x4
    3b9c:	b9890913          	addi	s2,s2,-1128 # 7730 <malloc+0x1e2a>
    chdir("..");
    3ba0:	854e                	mv	a0,s3
    3ba2:	00002097          	auipc	ra,0x2
    3ba6:	99e080e7          	jalr	-1634(ra) # 5540 <chdir>
    unlink("irefd");
    3baa:	854a                	mv	a0,s2
    3bac:	00002097          	auipc	ra,0x2
    3bb0:	974080e7          	jalr	-1676(ra) # 5520 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3bb4:	34fd                	addiw	s1,s1,-1
    3bb6:	f4ed                	bnez	s1,3ba0 <iref+0xfe>
  chdir("/");
    3bb8:	00003517          	auipc	a0,0x3
    3bbc:	35050513          	addi	a0,a0,848 # 6f08 <malloc+0x1602>
    3bc0:	00002097          	auipc	ra,0x2
    3bc4:	980080e7          	jalr	-1664(ra) # 5540 <chdir>
}
    3bc8:	70e2                	ld	ra,56(sp)
    3bca:	7442                	ld	s0,48(sp)
    3bcc:	74a2                	ld	s1,40(sp)
    3bce:	7902                	ld	s2,32(sp)
    3bd0:	69e2                	ld	s3,24(sp)
    3bd2:	6a42                	ld	s4,16(sp)
    3bd4:	6aa2                	ld	s5,8(sp)
    3bd6:	6b02                	ld	s6,0(sp)
    3bd8:	6121                	addi	sp,sp,64
    3bda:	8082                	ret

0000000000003bdc <openiputtest>:
{
    3bdc:	7179                	addi	sp,sp,-48
    3bde:	f406                	sd	ra,40(sp)
    3be0:	f022                	sd	s0,32(sp)
    3be2:	ec26                	sd	s1,24(sp)
    3be4:	1800                	addi	s0,sp,48
    3be6:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3be8:	00004517          	auipc	a0,0x4
    3bec:	b8050513          	addi	a0,a0,-1152 # 7768 <malloc+0x1e62>
    3bf0:	00002097          	auipc	ra,0x2
    3bf4:	948080e7          	jalr	-1720(ra) # 5538 <mkdir>
    3bf8:	04054263          	bltz	a0,3c3c <openiputtest+0x60>
  pid = fork();
    3bfc:	00002097          	auipc	ra,0x2
    3c00:	8cc080e7          	jalr	-1844(ra) # 54c8 <fork>
  if(pid < 0){
    3c04:	04054a63          	bltz	a0,3c58 <openiputtest+0x7c>
  if(pid == 0){
    3c08:	e93d                	bnez	a0,3c7e <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3c0a:	4589                	li	a1,2
    3c0c:	00004517          	auipc	a0,0x4
    3c10:	b5c50513          	addi	a0,a0,-1188 # 7768 <malloc+0x1e62>
    3c14:	00002097          	auipc	ra,0x2
    3c18:	8fc080e7          	jalr	-1796(ra) # 5510 <open>
    if(fd >= 0){
    3c1c:	04054c63          	bltz	a0,3c74 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3c20:	85a6                	mv	a1,s1
    3c22:	00004517          	auipc	a0,0x4
    3c26:	b6650513          	addi	a0,a0,-1178 # 7788 <malloc+0x1e82>
    3c2a:	00002097          	auipc	ra,0x2
    3c2e:	c1e080e7          	jalr	-994(ra) # 5848 <printf>
      exit(1);
    3c32:	4505                	li	a0,1
    3c34:	00002097          	auipc	ra,0x2
    3c38:	89c080e7          	jalr	-1892(ra) # 54d0 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3c3c:	85a6                	mv	a1,s1
    3c3e:	00004517          	auipc	a0,0x4
    3c42:	b3250513          	addi	a0,a0,-1230 # 7770 <malloc+0x1e6a>
    3c46:	00002097          	auipc	ra,0x2
    3c4a:	c02080e7          	jalr	-1022(ra) # 5848 <printf>
    exit(1);
    3c4e:	4505                	li	a0,1
    3c50:	00002097          	auipc	ra,0x2
    3c54:	880080e7          	jalr	-1920(ra) # 54d0 <exit>
    printf("%s: fork failed\n", s);
    3c58:	85a6                	mv	a1,s1
    3c5a:	00003517          	auipc	a0,0x3
    3c5e:	91650513          	addi	a0,a0,-1770 # 6570 <malloc+0xc6a>
    3c62:	00002097          	auipc	ra,0x2
    3c66:	be6080e7          	jalr	-1050(ra) # 5848 <printf>
    exit(1);
    3c6a:	4505                	li	a0,1
    3c6c:	00002097          	auipc	ra,0x2
    3c70:	864080e7          	jalr	-1948(ra) # 54d0 <exit>
    exit(0);
    3c74:	4501                	li	a0,0
    3c76:	00002097          	auipc	ra,0x2
    3c7a:	85a080e7          	jalr	-1958(ra) # 54d0 <exit>
  sleep(1);
    3c7e:	4505                	li	a0,1
    3c80:	00002097          	auipc	ra,0x2
    3c84:	8e0080e7          	jalr	-1824(ra) # 5560 <sleep>
  if(unlink("oidir") != 0){
    3c88:	00004517          	auipc	a0,0x4
    3c8c:	ae050513          	addi	a0,a0,-1312 # 7768 <malloc+0x1e62>
    3c90:	00002097          	auipc	ra,0x2
    3c94:	890080e7          	jalr	-1904(ra) # 5520 <unlink>
    3c98:	cd19                	beqz	a0,3cb6 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3c9a:	85a6                	mv	a1,s1
    3c9c:	00003517          	auipc	a0,0x3
    3ca0:	ac450513          	addi	a0,a0,-1340 # 6760 <malloc+0xe5a>
    3ca4:	00002097          	auipc	ra,0x2
    3ca8:	ba4080e7          	jalr	-1116(ra) # 5848 <printf>
    exit(1);
    3cac:	4505                	li	a0,1
    3cae:	00002097          	auipc	ra,0x2
    3cb2:	822080e7          	jalr	-2014(ra) # 54d0 <exit>
  wait(&xstatus);
    3cb6:	fdc40513          	addi	a0,s0,-36
    3cba:	00002097          	auipc	ra,0x2
    3cbe:	81e080e7          	jalr	-2018(ra) # 54d8 <wait>
  exit(xstatus);
    3cc2:	fdc42503          	lw	a0,-36(s0)
    3cc6:	00002097          	auipc	ra,0x2
    3cca:	80a080e7          	jalr	-2038(ra) # 54d0 <exit>

0000000000003cce <forkforkfork>:
{
    3cce:	1101                	addi	sp,sp,-32
    3cd0:	ec06                	sd	ra,24(sp)
    3cd2:	e822                	sd	s0,16(sp)
    3cd4:	e426                	sd	s1,8(sp)
    3cd6:	1000                	addi	s0,sp,32
    3cd8:	84aa                	mv	s1,a0
  unlink("stopforking");
    3cda:	00004517          	auipc	a0,0x4
    3cde:	ad650513          	addi	a0,a0,-1322 # 77b0 <malloc+0x1eaa>
    3ce2:	00002097          	auipc	ra,0x2
    3ce6:	83e080e7          	jalr	-1986(ra) # 5520 <unlink>
  int pid = fork();
    3cea:	00001097          	auipc	ra,0x1
    3cee:	7de080e7          	jalr	2014(ra) # 54c8 <fork>
  if(pid < 0){
    3cf2:	04054563          	bltz	a0,3d3c <forkforkfork+0x6e>
  if(pid == 0){
    3cf6:	c12d                	beqz	a0,3d58 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3cf8:	4551                	li	a0,20
    3cfa:	00002097          	auipc	ra,0x2
    3cfe:	866080e7          	jalr	-1946(ra) # 5560 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3d02:	20200593          	li	a1,514
    3d06:	00004517          	auipc	a0,0x4
    3d0a:	aaa50513          	addi	a0,a0,-1366 # 77b0 <malloc+0x1eaa>
    3d0e:	00002097          	auipc	ra,0x2
    3d12:	802080e7          	jalr	-2046(ra) # 5510 <open>
    3d16:	00001097          	auipc	ra,0x1
    3d1a:	7e2080e7          	jalr	2018(ra) # 54f8 <close>
  wait(0);
    3d1e:	4501                	li	a0,0
    3d20:	00001097          	auipc	ra,0x1
    3d24:	7b8080e7          	jalr	1976(ra) # 54d8 <wait>
  sleep(10); // one second
    3d28:	4529                	li	a0,10
    3d2a:	00002097          	auipc	ra,0x2
    3d2e:	836080e7          	jalr	-1994(ra) # 5560 <sleep>
}
    3d32:	60e2                	ld	ra,24(sp)
    3d34:	6442                	ld	s0,16(sp)
    3d36:	64a2                	ld	s1,8(sp)
    3d38:	6105                	addi	sp,sp,32
    3d3a:	8082                	ret
    printf("%s: fork failed", s);
    3d3c:	85a6                	mv	a1,s1
    3d3e:	00003517          	auipc	a0,0x3
    3d42:	9f250513          	addi	a0,a0,-1550 # 6730 <malloc+0xe2a>
    3d46:	00002097          	auipc	ra,0x2
    3d4a:	b02080e7          	jalr	-1278(ra) # 5848 <printf>
    exit(1);
    3d4e:	4505                	li	a0,1
    3d50:	00001097          	auipc	ra,0x1
    3d54:	780080e7          	jalr	1920(ra) # 54d0 <exit>
      int fd = open("stopforking", 0);
    3d58:	00004497          	auipc	s1,0x4
    3d5c:	a5848493          	addi	s1,s1,-1448 # 77b0 <malloc+0x1eaa>
    3d60:	4581                	li	a1,0
    3d62:	8526                	mv	a0,s1
    3d64:	00001097          	auipc	ra,0x1
    3d68:	7ac080e7          	jalr	1964(ra) # 5510 <open>
      if(fd >= 0){
    3d6c:	02055463          	bgez	a0,3d94 <forkforkfork+0xc6>
      if(fork() < 0){
    3d70:	00001097          	auipc	ra,0x1
    3d74:	758080e7          	jalr	1880(ra) # 54c8 <fork>
    3d78:	fe0554e3          	bgez	a0,3d60 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3d7c:	20200593          	li	a1,514
    3d80:	8526                	mv	a0,s1
    3d82:	00001097          	auipc	ra,0x1
    3d86:	78e080e7          	jalr	1934(ra) # 5510 <open>
    3d8a:	00001097          	auipc	ra,0x1
    3d8e:	76e080e7          	jalr	1902(ra) # 54f8 <close>
    3d92:	b7f9                	j	3d60 <forkforkfork+0x92>
        exit(0);
    3d94:	4501                	li	a0,0
    3d96:	00001097          	auipc	ra,0x1
    3d9a:	73a080e7          	jalr	1850(ra) # 54d0 <exit>

0000000000003d9e <preempt>:
{
    3d9e:	7139                	addi	sp,sp,-64
    3da0:	fc06                	sd	ra,56(sp)
    3da2:	f822                	sd	s0,48(sp)
    3da4:	f426                	sd	s1,40(sp)
    3da6:	f04a                	sd	s2,32(sp)
    3da8:	ec4e                	sd	s3,24(sp)
    3daa:	e852                	sd	s4,16(sp)
    3dac:	0080                	addi	s0,sp,64
    3dae:	84aa                	mv	s1,a0
  pid1 = fork();
    3db0:	00001097          	auipc	ra,0x1
    3db4:	718080e7          	jalr	1816(ra) # 54c8 <fork>
  if(pid1 < 0) {
    3db8:	00054563          	bltz	a0,3dc2 <preempt+0x24>
    3dbc:	8a2a                	mv	s4,a0
  if(pid1 == 0)
    3dbe:	e105                	bnez	a0,3dde <preempt+0x40>
    for(;;)
    3dc0:	a001                	j	3dc0 <preempt+0x22>
    printf("%s: fork failed", s);
    3dc2:	85a6                	mv	a1,s1
    3dc4:	00003517          	auipc	a0,0x3
    3dc8:	96c50513          	addi	a0,a0,-1684 # 6730 <malloc+0xe2a>
    3dcc:	00002097          	auipc	ra,0x2
    3dd0:	a7c080e7          	jalr	-1412(ra) # 5848 <printf>
    exit(1);
    3dd4:	4505                	li	a0,1
    3dd6:	00001097          	auipc	ra,0x1
    3dda:	6fa080e7          	jalr	1786(ra) # 54d0 <exit>
  pid2 = fork();
    3dde:	00001097          	auipc	ra,0x1
    3de2:	6ea080e7          	jalr	1770(ra) # 54c8 <fork>
    3de6:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3de8:	00054463          	bltz	a0,3df0 <preempt+0x52>
  if(pid2 == 0)
    3dec:	e105                	bnez	a0,3e0c <preempt+0x6e>
    for(;;)
    3dee:	a001                	j	3dee <preempt+0x50>
    printf("%s: fork failed\n", s);
    3df0:	85a6                	mv	a1,s1
    3df2:	00002517          	auipc	a0,0x2
    3df6:	77e50513          	addi	a0,a0,1918 # 6570 <malloc+0xc6a>
    3dfa:	00002097          	auipc	ra,0x2
    3dfe:	a4e080e7          	jalr	-1458(ra) # 5848 <printf>
    exit(1);
    3e02:	4505                	li	a0,1
    3e04:	00001097          	auipc	ra,0x1
    3e08:	6cc080e7          	jalr	1740(ra) # 54d0 <exit>
  pipe(pfds);
    3e0c:	fc840513          	addi	a0,s0,-56
    3e10:	00001097          	auipc	ra,0x1
    3e14:	6d0080e7          	jalr	1744(ra) # 54e0 <pipe>
  pid3 = fork();
    3e18:	00001097          	auipc	ra,0x1
    3e1c:	6b0080e7          	jalr	1712(ra) # 54c8 <fork>
    3e20:	892a                	mv	s2,a0
  if(pid3 < 0) {
    3e22:	02054e63          	bltz	a0,3e5e <preempt+0xc0>
  if(pid3 == 0){
    3e26:	e525                	bnez	a0,3e8e <preempt+0xf0>
    close(pfds[0]);
    3e28:	fc842503          	lw	a0,-56(s0)
    3e2c:	00001097          	auipc	ra,0x1
    3e30:	6cc080e7          	jalr	1740(ra) # 54f8 <close>
    if(write(pfds[1], "x", 1) != 1)
    3e34:	4605                	li	a2,1
    3e36:	00002597          	auipc	a1,0x2
    3e3a:	f7258593          	addi	a1,a1,-142 # 5da8 <malloc+0x4a2>
    3e3e:	fcc42503          	lw	a0,-52(s0)
    3e42:	00001097          	auipc	ra,0x1
    3e46:	6ae080e7          	jalr	1710(ra) # 54f0 <write>
    3e4a:	4785                	li	a5,1
    3e4c:	02f51763          	bne	a0,a5,3e7a <preempt+0xdc>
    close(pfds[1]);
    3e50:	fcc42503          	lw	a0,-52(s0)
    3e54:	00001097          	auipc	ra,0x1
    3e58:	6a4080e7          	jalr	1700(ra) # 54f8 <close>
    for(;;)
    3e5c:	a001                	j	3e5c <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3e5e:	85a6                	mv	a1,s1
    3e60:	00002517          	auipc	a0,0x2
    3e64:	71050513          	addi	a0,a0,1808 # 6570 <malloc+0xc6a>
    3e68:	00002097          	auipc	ra,0x2
    3e6c:	9e0080e7          	jalr	-1568(ra) # 5848 <printf>
     exit(1);
    3e70:	4505                	li	a0,1
    3e72:	00001097          	auipc	ra,0x1
    3e76:	65e080e7          	jalr	1630(ra) # 54d0 <exit>
      printf("%s: preempt write error", s);
    3e7a:	85a6                	mv	a1,s1
    3e7c:	00004517          	auipc	a0,0x4
    3e80:	94450513          	addi	a0,a0,-1724 # 77c0 <malloc+0x1eba>
    3e84:	00002097          	auipc	ra,0x2
    3e88:	9c4080e7          	jalr	-1596(ra) # 5848 <printf>
    3e8c:	b7d1                	j	3e50 <preempt+0xb2>
  close(pfds[1]);
    3e8e:	fcc42503          	lw	a0,-52(s0)
    3e92:	00001097          	auipc	ra,0x1
    3e96:	666080e7          	jalr	1638(ra) # 54f8 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3e9a:	660d                	lui	a2,0x3
    3e9c:	00008597          	auipc	a1,0x8
    3ea0:	a9458593          	addi	a1,a1,-1388 # b930 <buf>
    3ea4:	fc842503          	lw	a0,-56(s0)
    3ea8:	00001097          	auipc	ra,0x1
    3eac:	640080e7          	jalr	1600(ra) # 54e8 <read>
    3eb0:	4785                	li	a5,1
    3eb2:	02f50363          	beq	a0,a5,3ed8 <preempt+0x13a>
    printf("%s: preempt read error", s);
    3eb6:	85a6                	mv	a1,s1
    3eb8:	00004517          	auipc	a0,0x4
    3ebc:	92050513          	addi	a0,a0,-1760 # 77d8 <malloc+0x1ed2>
    3ec0:	00002097          	auipc	ra,0x2
    3ec4:	988080e7          	jalr	-1656(ra) # 5848 <printf>
}
    3ec8:	70e2                	ld	ra,56(sp)
    3eca:	7442                	ld	s0,48(sp)
    3ecc:	74a2                	ld	s1,40(sp)
    3ece:	7902                	ld	s2,32(sp)
    3ed0:	69e2                	ld	s3,24(sp)
    3ed2:	6a42                	ld	s4,16(sp)
    3ed4:	6121                	addi	sp,sp,64
    3ed6:	8082                	ret
  close(pfds[0]);
    3ed8:	fc842503          	lw	a0,-56(s0)
    3edc:	00001097          	auipc	ra,0x1
    3ee0:	61c080e7          	jalr	1564(ra) # 54f8 <close>
  printf("kill... ");
    3ee4:	00004517          	auipc	a0,0x4
    3ee8:	90c50513          	addi	a0,a0,-1780 # 77f0 <malloc+0x1eea>
    3eec:	00002097          	auipc	ra,0x2
    3ef0:	95c080e7          	jalr	-1700(ra) # 5848 <printf>
  kill(pid1);
    3ef4:	8552                	mv	a0,s4
    3ef6:	00001097          	auipc	ra,0x1
    3efa:	60a080e7          	jalr	1546(ra) # 5500 <kill>
  kill(pid2);
    3efe:	854e                	mv	a0,s3
    3f00:	00001097          	auipc	ra,0x1
    3f04:	600080e7          	jalr	1536(ra) # 5500 <kill>
  kill(pid3);
    3f08:	854a                	mv	a0,s2
    3f0a:	00001097          	auipc	ra,0x1
    3f0e:	5f6080e7          	jalr	1526(ra) # 5500 <kill>
  printf("wait... ");
    3f12:	00004517          	auipc	a0,0x4
    3f16:	8ee50513          	addi	a0,a0,-1810 # 7800 <malloc+0x1efa>
    3f1a:	00002097          	auipc	ra,0x2
    3f1e:	92e080e7          	jalr	-1746(ra) # 5848 <printf>
  wait(0);
    3f22:	4501                	li	a0,0
    3f24:	00001097          	auipc	ra,0x1
    3f28:	5b4080e7          	jalr	1460(ra) # 54d8 <wait>
  wait(0);
    3f2c:	4501                	li	a0,0
    3f2e:	00001097          	auipc	ra,0x1
    3f32:	5aa080e7          	jalr	1450(ra) # 54d8 <wait>
  wait(0);
    3f36:	4501                	li	a0,0
    3f38:	00001097          	auipc	ra,0x1
    3f3c:	5a0080e7          	jalr	1440(ra) # 54d8 <wait>
    3f40:	b761                	j	3ec8 <preempt+0x12a>

0000000000003f42 <sbrkfail>:
{
    3f42:	7119                	addi	sp,sp,-128
    3f44:	fc86                	sd	ra,120(sp)
    3f46:	f8a2                	sd	s0,112(sp)
    3f48:	f4a6                	sd	s1,104(sp)
    3f4a:	f0ca                	sd	s2,96(sp)
    3f4c:	ecce                	sd	s3,88(sp)
    3f4e:	e8d2                	sd	s4,80(sp)
    3f50:	e4d6                	sd	s5,72(sp)
    3f52:	0100                	addi	s0,sp,128
    3f54:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    3f56:	fb040513          	addi	a0,s0,-80
    3f5a:	00001097          	auipc	ra,0x1
    3f5e:	586080e7          	jalr	1414(ra) # 54e0 <pipe>
    3f62:	e901                	bnez	a0,3f72 <sbrkfail+0x30>
    3f64:	f8040493          	addi	s1,s0,-128
    3f68:	fa840a13          	addi	s4,s0,-88
    3f6c:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    3f6e:	5afd                	li	s5,-1
    3f70:	a08d                	j	3fd2 <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    3f72:	85ca                	mv	a1,s2
    3f74:	00002517          	auipc	a0,0x2
    3f78:	70450513          	addi	a0,a0,1796 # 6678 <malloc+0xd72>
    3f7c:	00002097          	auipc	ra,0x2
    3f80:	8cc080e7          	jalr	-1844(ra) # 5848 <printf>
    exit(1);
    3f84:	4505                	li	a0,1
    3f86:	00001097          	auipc	ra,0x1
    3f8a:	54a080e7          	jalr	1354(ra) # 54d0 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3f8e:	4501                	li	a0,0
    3f90:	00001097          	auipc	ra,0x1
    3f94:	5c8080e7          	jalr	1480(ra) # 5558 <sbrk>
    3f98:	064007b7          	lui	a5,0x6400
    3f9c:	40a7853b          	subw	a0,a5,a0
    3fa0:	00001097          	auipc	ra,0x1
    3fa4:	5b8080e7          	jalr	1464(ra) # 5558 <sbrk>
      write(fds[1], "x", 1);
    3fa8:	4605                	li	a2,1
    3faa:	00002597          	auipc	a1,0x2
    3fae:	dfe58593          	addi	a1,a1,-514 # 5da8 <malloc+0x4a2>
    3fb2:	fb442503          	lw	a0,-76(s0)
    3fb6:	00001097          	auipc	ra,0x1
    3fba:	53a080e7          	jalr	1338(ra) # 54f0 <write>
      for(;;) sleep(1000);
    3fbe:	3e800513          	li	a0,1000
    3fc2:	00001097          	auipc	ra,0x1
    3fc6:	59e080e7          	jalr	1438(ra) # 5560 <sleep>
    3fca:	bfd5                	j	3fbe <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3fcc:	0991                	addi	s3,s3,4
    3fce:	03498563          	beq	s3,s4,3ff8 <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    3fd2:	00001097          	auipc	ra,0x1
    3fd6:	4f6080e7          	jalr	1270(ra) # 54c8 <fork>
    3fda:	00a9a023          	sw	a0,0(s3)
    3fde:	d945                	beqz	a0,3f8e <sbrkfail+0x4c>
    if(pids[i] != -1)
    3fe0:	ff5506e3          	beq	a0,s5,3fcc <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    3fe4:	4605                	li	a2,1
    3fe6:	faf40593          	addi	a1,s0,-81
    3fea:	fb042503          	lw	a0,-80(s0)
    3fee:	00001097          	auipc	ra,0x1
    3ff2:	4fa080e7          	jalr	1274(ra) # 54e8 <read>
    3ff6:	bfd9                	j	3fcc <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    3ff8:	6505                	lui	a0,0x1
    3ffa:	00001097          	auipc	ra,0x1
    3ffe:	55e080e7          	jalr	1374(ra) # 5558 <sbrk>
    4002:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    4004:	5afd                	li	s5,-1
    4006:	a021                	j	400e <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4008:	0491                	addi	s1,s1,4
    400a:	01448f63          	beq	s1,s4,4028 <sbrkfail+0xe6>
    if(pids[i] == -1)
    400e:	4088                	lw	a0,0(s1)
    4010:	ff550ce3          	beq	a0,s5,4008 <sbrkfail+0xc6>
    kill(pids[i]);
    4014:	00001097          	auipc	ra,0x1
    4018:	4ec080e7          	jalr	1260(ra) # 5500 <kill>
    wait(0);
    401c:	4501                	li	a0,0
    401e:	00001097          	auipc	ra,0x1
    4022:	4ba080e7          	jalr	1210(ra) # 54d8 <wait>
    4026:	b7cd                	j	4008 <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    4028:	57fd                	li	a5,-1
    402a:	04f98163          	beq	s3,a5,406c <sbrkfail+0x12a>
  pid = fork();
    402e:	00001097          	auipc	ra,0x1
    4032:	49a080e7          	jalr	1178(ra) # 54c8 <fork>
    4036:	84aa                	mv	s1,a0
  if(pid < 0){
    4038:	04054863          	bltz	a0,4088 <sbrkfail+0x146>
  if(pid == 0){
    403c:	c525                	beqz	a0,40a4 <sbrkfail+0x162>
  wait(&xstatus);
    403e:	fbc40513          	addi	a0,s0,-68
    4042:	00001097          	auipc	ra,0x1
    4046:	496080e7          	jalr	1174(ra) # 54d8 <wait>
  if(xstatus != -1 && xstatus != 2)
    404a:	fbc42783          	lw	a5,-68(s0)
    404e:	577d                	li	a4,-1
    4050:	00e78563          	beq	a5,a4,405a <sbrkfail+0x118>
    4054:	4709                	li	a4,2
    4056:	08e79d63          	bne	a5,a4,40f0 <sbrkfail+0x1ae>
}
    405a:	70e6                	ld	ra,120(sp)
    405c:	7446                	ld	s0,112(sp)
    405e:	74a6                	ld	s1,104(sp)
    4060:	7906                	ld	s2,96(sp)
    4062:	69e6                	ld	s3,88(sp)
    4064:	6a46                	ld	s4,80(sp)
    4066:	6aa6                	ld	s5,72(sp)
    4068:	6109                	addi	sp,sp,128
    406a:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    406c:	85ca                	mv	a1,s2
    406e:	00003517          	auipc	a0,0x3
    4072:	7a250513          	addi	a0,a0,1954 # 7810 <malloc+0x1f0a>
    4076:	00001097          	auipc	ra,0x1
    407a:	7d2080e7          	jalr	2002(ra) # 5848 <printf>
    exit(1);
    407e:	4505                	li	a0,1
    4080:	00001097          	auipc	ra,0x1
    4084:	450080e7          	jalr	1104(ra) # 54d0 <exit>
    printf("%s: fork failed\n", s);
    4088:	85ca                	mv	a1,s2
    408a:	00002517          	auipc	a0,0x2
    408e:	4e650513          	addi	a0,a0,1254 # 6570 <malloc+0xc6a>
    4092:	00001097          	auipc	ra,0x1
    4096:	7b6080e7          	jalr	1974(ra) # 5848 <printf>
    exit(1);
    409a:	4505                	li	a0,1
    409c:	00001097          	auipc	ra,0x1
    40a0:	434080e7          	jalr	1076(ra) # 54d0 <exit>
    a = sbrk(0);
    40a4:	4501                	li	a0,0
    40a6:	00001097          	auipc	ra,0x1
    40aa:	4b2080e7          	jalr	1202(ra) # 5558 <sbrk>
    40ae:	89aa                	mv	s3,a0
    sbrk(10*BIG);
    40b0:	3e800537          	lui	a0,0x3e800
    40b4:	00001097          	auipc	ra,0x1
    40b8:	4a4080e7          	jalr	1188(ra) # 5558 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    40bc:	874e                	mv	a4,s3
    40be:	3e8007b7          	lui	a5,0x3e800
    40c2:	97ce                	add	a5,a5,s3
    40c4:	6685                	lui	a3,0x1
      n += *(a+i);
    40c6:	00074603          	lbu	a2,0(a4)
    40ca:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    40cc:	9736                	add	a4,a4,a3
    40ce:	fef71ce3          	bne	a4,a5,40c6 <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    40d2:	8626                	mv	a2,s1
    40d4:	85ca                	mv	a1,s2
    40d6:	00003517          	auipc	a0,0x3
    40da:	75a50513          	addi	a0,a0,1882 # 7830 <malloc+0x1f2a>
    40de:	00001097          	auipc	ra,0x1
    40e2:	76a080e7          	jalr	1898(ra) # 5848 <printf>
    exit(1);
    40e6:	4505                	li	a0,1
    40e8:	00001097          	auipc	ra,0x1
    40ec:	3e8080e7          	jalr	1000(ra) # 54d0 <exit>
    exit(1);
    40f0:	4505                	li	a0,1
    40f2:	00001097          	auipc	ra,0x1
    40f6:	3de080e7          	jalr	990(ra) # 54d0 <exit>

00000000000040fa <reparent>:
{
    40fa:	7179                	addi	sp,sp,-48
    40fc:	f406                	sd	ra,40(sp)
    40fe:	f022                	sd	s0,32(sp)
    4100:	ec26                	sd	s1,24(sp)
    4102:	e84a                	sd	s2,16(sp)
    4104:	e44e                	sd	s3,8(sp)
    4106:	e052                	sd	s4,0(sp)
    4108:	1800                	addi	s0,sp,48
    410a:	89aa                	mv	s3,a0
  int master_pid = getpid();
    410c:	00001097          	auipc	ra,0x1
    4110:	444080e7          	jalr	1092(ra) # 5550 <getpid>
    4114:	8a2a                	mv	s4,a0
    4116:	0c800913          	li	s2,200
    int pid = fork();
    411a:	00001097          	auipc	ra,0x1
    411e:	3ae080e7          	jalr	942(ra) # 54c8 <fork>
    4122:	84aa                	mv	s1,a0
    if(pid < 0){
    4124:	02054263          	bltz	a0,4148 <reparent+0x4e>
    if(pid){
    4128:	cd21                	beqz	a0,4180 <reparent+0x86>
      if(wait(0) != pid){
    412a:	4501                	li	a0,0
    412c:	00001097          	auipc	ra,0x1
    4130:	3ac080e7          	jalr	940(ra) # 54d8 <wait>
    4134:	02951863          	bne	a0,s1,4164 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4138:	397d                	addiw	s2,s2,-1
    413a:	fe0910e3          	bnez	s2,411a <reparent+0x20>
  exit(0);
    413e:	4501                	li	a0,0
    4140:	00001097          	auipc	ra,0x1
    4144:	390080e7          	jalr	912(ra) # 54d0 <exit>
      printf("%s: fork failed\n", s);
    4148:	85ce                	mv	a1,s3
    414a:	00002517          	auipc	a0,0x2
    414e:	42650513          	addi	a0,a0,1062 # 6570 <malloc+0xc6a>
    4152:	00001097          	auipc	ra,0x1
    4156:	6f6080e7          	jalr	1782(ra) # 5848 <printf>
      exit(1);
    415a:	4505                	li	a0,1
    415c:	00001097          	auipc	ra,0x1
    4160:	374080e7          	jalr	884(ra) # 54d0 <exit>
        printf("%s: wait wrong pid\n", s);
    4164:	85ce                	mv	a1,s3
    4166:	00002517          	auipc	a0,0x2
    416a:	59250513          	addi	a0,a0,1426 # 66f8 <malloc+0xdf2>
    416e:	00001097          	auipc	ra,0x1
    4172:	6da080e7          	jalr	1754(ra) # 5848 <printf>
        exit(1);
    4176:	4505                	li	a0,1
    4178:	00001097          	auipc	ra,0x1
    417c:	358080e7          	jalr	856(ra) # 54d0 <exit>
      int pid2 = fork();
    4180:	00001097          	auipc	ra,0x1
    4184:	348080e7          	jalr	840(ra) # 54c8 <fork>
      if(pid2 < 0){
    4188:	00054763          	bltz	a0,4196 <reparent+0x9c>
      exit(0);
    418c:	4501                	li	a0,0
    418e:	00001097          	auipc	ra,0x1
    4192:	342080e7          	jalr	834(ra) # 54d0 <exit>
        kill(master_pid);
    4196:	8552                	mv	a0,s4
    4198:	00001097          	auipc	ra,0x1
    419c:	368080e7          	jalr	872(ra) # 5500 <kill>
        exit(1);
    41a0:	4505                	li	a0,1
    41a2:	00001097          	auipc	ra,0x1
    41a6:	32e080e7          	jalr	814(ra) # 54d0 <exit>

00000000000041aa <mem>:
{
    41aa:	7139                	addi	sp,sp,-64
    41ac:	fc06                	sd	ra,56(sp)
    41ae:	f822                	sd	s0,48(sp)
    41b0:	f426                	sd	s1,40(sp)
    41b2:	f04a                	sd	s2,32(sp)
    41b4:	ec4e                	sd	s3,24(sp)
    41b6:	0080                	addi	s0,sp,64
    41b8:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    41ba:	00001097          	auipc	ra,0x1
    41be:	30e080e7          	jalr	782(ra) # 54c8 <fork>
    m1 = 0;
    41c2:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    41c4:	6909                	lui	s2,0x2
    41c6:	71190913          	addi	s2,s2,1809 # 2711 <sbrkmuch+0x109>
  if((pid = fork()) == 0){
    41ca:	ed39                	bnez	a0,4228 <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    41cc:	854a                	mv	a0,s2
    41ce:	00001097          	auipc	ra,0x1
    41d2:	738080e7          	jalr	1848(ra) # 5906 <malloc>
    41d6:	c501                	beqz	a0,41de <mem+0x34>
      *(char**)m2 = m1;
    41d8:	e104                	sd	s1,0(a0)
      m1 = m2;
    41da:	84aa                	mv	s1,a0
    41dc:	bfc5                	j	41cc <mem+0x22>
    while(m1){
    41de:	c881                	beqz	s1,41ee <mem+0x44>
      m2 = *(char**)m1;
    41e0:	8526                	mv	a0,s1
    41e2:	6084                	ld	s1,0(s1)
      free(m1);
    41e4:	00001097          	auipc	ra,0x1
    41e8:	69a080e7          	jalr	1690(ra) # 587e <free>
    while(m1){
    41ec:	f8f5                	bnez	s1,41e0 <mem+0x36>
    m1 = malloc(1024*20);
    41ee:	6515                	lui	a0,0x5
    41f0:	00001097          	auipc	ra,0x1
    41f4:	716080e7          	jalr	1814(ra) # 5906 <malloc>
    if(m1 == 0){
    41f8:	c911                	beqz	a0,420c <mem+0x62>
    free(m1);
    41fa:	00001097          	auipc	ra,0x1
    41fe:	684080e7          	jalr	1668(ra) # 587e <free>
    exit(0);
    4202:	4501                	li	a0,0
    4204:	00001097          	auipc	ra,0x1
    4208:	2cc080e7          	jalr	716(ra) # 54d0 <exit>
      printf("couldn't allocate mem?!!\n", s);
    420c:	85ce                	mv	a1,s3
    420e:	00003517          	auipc	a0,0x3
    4212:	65250513          	addi	a0,a0,1618 # 7860 <malloc+0x1f5a>
    4216:	00001097          	auipc	ra,0x1
    421a:	632080e7          	jalr	1586(ra) # 5848 <printf>
      exit(1);
    421e:	4505                	li	a0,1
    4220:	00001097          	auipc	ra,0x1
    4224:	2b0080e7          	jalr	688(ra) # 54d0 <exit>
    wait(&xstatus);
    4228:	fcc40513          	addi	a0,s0,-52
    422c:	00001097          	auipc	ra,0x1
    4230:	2ac080e7          	jalr	684(ra) # 54d8 <wait>
    if(xstatus == -1){
    4234:	fcc42503          	lw	a0,-52(s0)
    4238:	57fd                	li	a5,-1
    423a:	00f50663          	beq	a0,a5,4246 <mem+0x9c>
    exit(xstatus);
    423e:	00001097          	auipc	ra,0x1
    4242:	292080e7          	jalr	658(ra) # 54d0 <exit>
      exit(0);
    4246:	4501                	li	a0,0
    4248:	00001097          	auipc	ra,0x1
    424c:	288080e7          	jalr	648(ra) # 54d0 <exit>

0000000000004250 <sharedfd>:
{
    4250:	7159                	addi	sp,sp,-112
    4252:	f486                	sd	ra,104(sp)
    4254:	f0a2                	sd	s0,96(sp)
    4256:	eca6                	sd	s1,88(sp)
    4258:	e8ca                	sd	s2,80(sp)
    425a:	e4ce                	sd	s3,72(sp)
    425c:	e0d2                	sd	s4,64(sp)
    425e:	fc56                	sd	s5,56(sp)
    4260:	f85a                	sd	s6,48(sp)
    4262:	f45e                	sd	s7,40(sp)
    4264:	1880                	addi	s0,sp,112
    4266:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4268:	00002517          	auipc	a0,0x2
    426c:	91050513          	addi	a0,a0,-1776 # 5b78 <malloc+0x272>
    4270:	00001097          	auipc	ra,0x1
    4274:	2b0080e7          	jalr	688(ra) # 5520 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4278:	20200593          	li	a1,514
    427c:	00002517          	auipc	a0,0x2
    4280:	8fc50513          	addi	a0,a0,-1796 # 5b78 <malloc+0x272>
    4284:	00001097          	auipc	ra,0x1
    4288:	28c080e7          	jalr	652(ra) # 5510 <open>
  if(fd < 0){
    428c:	04054a63          	bltz	a0,42e0 <sharedfd+0x90>
    4290:	892a                	mv	s2,a0
  pid = fork();
    4292:	00001097          	auipc	ra,0x1
    4296:	236080e7          	jalr	566(ra) # 54c8 <fork>
    429a:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    429c:	06300593          	li	a1,99
    42a0:	c119                	beqz	a0,42a6 <sharedfd+0x56>
    42a2:	07000593          	li	a1,112
    42a6:	4629                	li	a2,10
    42a8:	fa040513          	addi	a0,s0,-96
    42ac:	00001097          	auipc	ra,0x1
    42b0:	020080e7          	jalr	32(ra) # 52cc <memset>
    42b4:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    42b8:	4629                	li	a2,10
    42ba:	fa040593          	addi	a1,s0,-96
    42be:	854a                	mv	a0,s2
    42c0:	00001097          	auipc	ra,0x1
    42c4:	230080e7          	jalr	560(ra) # 54f0 <write>
    42c8:	47a9                	li	a5,10
    42ca:	02f51963          	bne	a0,a5,42fc <sharedfd+0xac>
  for(i = 0; i < N; i++){
    42ce:	34fd                	addiw	s1,s1,-1
    42d0:	f4e5                	bnez	s1,42b8 <sharedfd+0x68>
  if(pid == 0) {
    42d2:	04099363          	bnez	s3,4318 <sharedfd+0xc8>
    exit(0);
    42d6:	4501                	li	a0,0
    42d8:	00001097          	auipc	ra,0x1
    42dc:	1f8080e7          	jalr	504(ra) # 54d0 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    42e0:	85d2                	mv	a1,s4
    42e2:	00003517          	auipc	a0,0x3
    42e6:	59e50513          	addi	a0,a0,1438 # 7880 <malloc+0x1f7a>
    42ea:	00001097          	auipc	ra,0x1
    42ee:	55e080e7          	jalr	1374(ra) # 5848 <printf>
    exit(1);
    42f2:	4505                	li	a0,1
    42f4:	00001097          	auipc	ra,0x1
    42f8:	1dc080e7          	jalr	476(ra) # 54d0 <exit>
      printf("%s: write sharedfd failed\n", s);
    42fc:	85d2                	mv	a1,s4
    42fe:	00003517          	auipc	a0,0x3
    4302:	5aa50513          	addi	a0,a0,1450 # 78a8 <malloc+0x1fa2>
    4306:	00001097          	auipc	ra,0x1
    430a:	542080e7          	jalr	1346(ra) # 5848 <printf>
      exit(1);
    430e:	4505                	li	a0,1
    4310:	00001097          	auipc	ra,0x1
    4314:	1c0080e7          	jalr	448(ra) # 54d0 <exit>
    wait(&xstatus);
    4318:	f9c40513          	addi	a0,s0,-100
    431c:	00001097          	auipc	ra,0x1
    4320:	1bc080e7          	jalr	444(ra) # 54d8 <wait>
    if(xstatus != 0)
    4324:	f9c42983          	lw	s3,-100(s0)
    4328:	00098763          	beqz	s3,4336 <sharedfd+0xe6>
      exit(xstatus);
    432c:	854e                	mv	a0,s3
    432e:	00001097          	auipc	ra,0x1
    4332:	1a2080e7          	jalr	418(ra) # 54d0 <exit>
  close(fd);
    4336:	854a                	mv	a0,s2
    4338:	00001097          	auipc	ra,0x1
    433c:	1c0080e7          	jalr	448(ra) # 54f8 <close>
  fd = open("sharedfd", 0);
    4340:	4581                	li	a1,0
    4342:	00002517          	auipc	a0,0x2
    4346:	83650513          	addi	a0,a0,-1994 # 5b78 <malloc+0x272>
    434a:	00001097          	auipc	ra,0x1
    434e:	1c6080e7          	jalr	454(ra) # 5510 <open>
    4352:	8baa                	mv	s7,a0
  nc = np = 0;
    4354:	8ace                	mv	s5,s3
  if(fd < 0){
    4356:	02054563          	bltz	a0,4380 <sharedfd+0x130>
    435a:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    435e:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4362:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4366:	4629                	li	a2,10
    4368:	fa040593          	addi	a1,s0,-96
    436c:	855e                	mv	a0,s7
    436e:	00001097          	auipc	ra,0x1
    4372:	17a080e7          	jalr	378(ra) # 54e8 <read>
    4376:	02a05f63          	blez	a0,43b4 <sharedfd+0x164>
    437a:	fa040793          	addi	a5,s0,-96
    437e:	a01d                	j	43a4 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4380:	85d2                	mv	a1,s4
    4382:	00003517          	auipc	a0,0x3
    4386:	54650513          	addi	a0,a0,1350 # 78c8 <malloc+0x1fc2>
    438a:	00001097          	auipc	ra,0x1
    438e:	4be080e7          	jalr	1214(ra) # 5848 <printf>
    exit(1);
    4392:	4505                	li	a0,1
    4394:	00001097          	auipc	ra,0x1
    4398:	13c080e7          	jalr	316(ra) # 54d0 <exit>
        nc++;
    439c:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    439e:	0785                	addi	a5,a5,1
    43a0:	fd2783e3          	beq	a5,s2,4366 <sharedfd+0x116>
      if(buf[i] == 'c')
    43a4:	0007c703          	lbu	a4,0(a5) # 3e800000 <__BSS_END__+0x3e7f16c0>
    43a8:	fe970ae3          	beq	a4,s1,439c <sharedfd+0x14c>
      if(buf[i] == 'p')
    43ac:	ff6719e3          	bne	a4,s6,439e <sharedfd+0x14e>
        np++;
    43b0:	2a85                	addiw	s5,s5,1
    43b2:	b7f5                	j	439e <sharedfd+0x14e>
  close(fd);
    43b4:	855e                	mv	a0,s7
    43b6:	00001097          	auipc	ra,0x1
    43ba:	142080e7          	jalr	322(ra) # 54f8 <close>
  unlink("sharedfd");
    43be:	00001517          	auipc	a0,0x1
    43c2:	7ba50513          	addi	a0,a0,1978 # 5b78 <malloc+0x272>
    43c6:	00001097          	auipc	ra,0x1
    43ca:	15a080e7          	jalr	346(ra) # 5520 <unlink>
  if(nc == N*SZ && np == N*SZ){
    43ce:	6789                	lui	a5,0x2
    43d0:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0x108>
    43d4:	00f99763          	bne	s3,a5,43e2 <sharedfd+0x192>
    43d8:	6789                	lui	a5,0x2
    43da:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0x108>
    43de:	02fa8063          	beq	s5,a5,43fe <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    43e2:	85d2                	mv	a1,s4
    43e4:	00003517          	auipc	a0,0x3
    43e8:	50c50513          	addi	a0,a0,1292 # 78f0 <malloc+0x1fea>
    43ec:	00001097          	auipc	ra,0x1
    43f0:	45c080e7          	jalr	1116(ra) # 5848 <printf>
    exit(1);
    43f4:	4505                	li	a0,1
    43f6:	00001097          	auipc	ra,0x1
    43fa:	0da080e7          	jalr	218(ra) # 54d0 <exit>
    exit(0);
    43fe:	4501                	li	a0,0
    4400:	00001097          	auipc	ra,0x1
    4404:	0d0080e7          	jalr	208(ra) # 54d0 <exit>

0000000000004408 <fourfiles>:
{
    4408:	7171                	addi	sp,sp,-176
    440a:	f506                	sd	ra,168(sp)
    440c:	f122                	sd	s0,160(sp)
    440e:	ed26                	sd	s1,152(sp)
    4410:	e94a                	sd	s2,144(sp)
    4412:	e54e                	sd	s3,136(sp)
    4414:	e152                	sd	s4,128(sp)
    4416:	fcd6                	sd	s5,120(sp)
    4418:	f8da                	sd	s6,112(sp)
    441a:	f4de                	sd	s7,104(sp)
    441c:	f0e2                	sd	s8,96(sp)
    441e:	ece6                	sd	s9,88(sp)
    4420:	e8ea                	sd	s10,80(sp)
    4422:	e4ee                	sd	s11,72(sp)
    4424:	1900                	addi	s0,sp,176
    4426:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4428:	00001797          	auipc	a5,0x1
    442c:	5c878793          	addi	a5,a5,1480 # 59f0 <malloc+0xea>
    4430:	f6f43823          	sd	a5,-144(s0)
    4434:	00001797          	auipc	a5,0x1
    4438:	5c478793          	addi	a5,a5,1476 # 59f8 <malloc+0xf2>
    443c:	f6f43c23          	sd	a5,-136(s0)
    4440:	00001797          	auipc	a5,0x1
    4444:	5c078793          	addi	a5,a5,1472 # 5a00 <malloc+0xfa>
    4448:	f8f43023          	sd	a5,-128(s0)
    444c:	00001797          	auipc	a5,0x1
    4450:	5bc78793          	addi	a5,a5,1468 # 5a08 <malloc+0x102>
    4454:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4458:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    445c:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    445e:	4481                	li	s1,0
    4460:	4a11                	li	s4,4
    fname = names[pi];
    4462:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4466:	854e                	mv	a0,s3
    4468:	00001097          	auipc	ra,0x1
    446c:	0b8080e7          	jalr	184(ra) # 5520 <unlink>
    pid = fork();
    4470:	00001097          	auipc	ra,0x1
    4474:	058080e7          	jalr	88(ra) # 54c8 <fork>
    if(pid < 0){
    4478:	04054563          	bltz	a0,44c2 <fourfiles+0xba>
    if(pid == 0){
    447c:	c12d                	beqz	a0,44de <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    447e:	2485                	addiw	s1,s1,1
    4480:	0921                	addi	s2,s2,8
    4482:	ff4490e3          	bne	s1,s4,4462 <fourfiles+0x5a>
    4486:	4491                	li	s1,4
    wait(&xstatus);
    4488:	f6c40513          	addi	a0,s0,-148
    448c:	00001097          	auipc	ra,0x1
    4490:	04c080e7          	jalr	76(ra) # 54d8 <wait>
    if(xstatus != 0)
    4494:	f6c42503          	lw	a0,-148(s0)
    4498:	ed69                	bnez	a0,4572 <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    449a:	34fd                	addiw	s1,s1,-1
    449c:	f4f5                	bnez	s1,4488 <fourfiles+0x80>
    449e:	03000b13          	li	s6,48
    total = 0;
    44a2:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    44a6:	00007a17          	auipc	s4,0x7
    44aa:	48aa0a13          	addi	s4,s4,1162 # b930 <buf>
    44ae:	00007a97          	auipc	s5,0x7
    44b2:	483a8a93          	addi	s5,s5,1155 # b931 <buf+0x1>
    if(total != N*SZ){
    44b6:	6d05                	lui	s10,0x1
    44b8:	770d0d13          	addi	s10,s10,1904 # 1770 <pipe1+0x1e>
  for(i = 0; i < NCHILD; i++){
    44bc:	03400d93          	li	s11,52
    44c0:	a23d                	j	45ee <fourfiles+0x1e6>
      printf("fork failed\n", s);
    44c2:	85e6                	mv	a1,s9
    44c4:	00002517          	auipc	a0,0x2
    44c8:	49c50513          	addi	a0,a0,1180 # 6960 <malloc+0x105a>
    44cc:	00001097          	auipc	ra,0x1
    44d0:	37c080e7          	jalr	892(ra) # 5848 <printf>
      exit(1);
    44d4:	4505                	li	a0,1
    44d6:	00001097          	auipc	ra,0x1
    44da:	ffa080e7          	jalr	-6(ra) # 54d0 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    44de:	20200593          	li	a1,514
    44e2:	854e                	mv	a0,s3
    44e4:	00001097          	auipc	ra,0x1
    44e8:	02c080e7          	jalr	44(ra) # 5510 <open>
    44ec:	892a                	mv	s2,a0
      if(fd < 0){
    44ee:	04054763          	bltz	a0,453c <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    44f2:	1f400613          	li	a2,500
    44f6:	0304859b          	addiw	a1,s1,48
    44fa:	00007517          	auipc	a0,0x7
    44fe:	43650513          	addi	a0,a0,1078 # b930 <buf>
    4502:	00001097          	auipc	ra,0x1
    4506:	dca080e7          	jalr	-566(ra) # 52cc <memset>
    450a:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    450c:	00007997          	auipc	s3,0x7
    4510:	42498993          	addi	s3,s3,1060 # b930 <buf>
    4514:	1f400613          	li	a2,500
    4518:	85ce                	mv	a1,s3
    451a:	854a                	mv	a0,s2
    451c:	00001097          	auipc	ra,0x1
    4520:	fd4080e7          	jalr	-44(ra) # 54f0 <write>
    4524:	85aa                	mv	a1,a0
    4526:	1f400793          	li	a5,500
    452a:	02f51763          	bne	a0,a5,4558 <fourfiles+0x150>
      for(i = 0; i < N; i++){
    452e:	34fd                	addiw	s1,s1,-1
    4530:	f0f5                	bnez	s1,4514 <fourfiles+0x10c>
      exit(0);
    4532:	4501                	li	a0,0
    4534:	00001097          	auipc	ra,0x1
    4538:	f9c080e7          	jalr	-100(ra) # 54d0 <exit>
        printf("create failed\n", s);
    453c:	85e6                	mv	a1,s9
    453e:	00003517          	auipc	a0,0x3
    4542:	3ca50513          	addi	a0,a0,970 # 7908 <malloc+0x2002>
    4546:	00001097          	auipc	ra,0x1
    454a:	302080e7          	jalr	770(ra) # 5848 <printf>
        exit(1);
    454e:	4505                	li	a0,1
    4550:	00001097          	auipc	ra,0x1
    4554:	f80080e7          	jalr	-128(ra) # 54d0 <exit>
          printf("write failed %d\n", n);
    4558:	00003517          	auipc	a0,0x3
    455c:	3c050513          	addi	a0,a0,960 # 7918 <malloc+0x2012>
    4560:	00001097          	auipc	ra,0x1
    4564:	2e8080e7          	jalr	744(ra) # 5848 <printf>
          exit(1);
    4568:	4505                	li	a0,1
    456a:	00001097          	auipc	ra,0x1
    456e:	f66080e7          	jalr	-154(ra) # 54d0 <exit>
      exit(xstatus);
    4572:	00001097          	auipc	ra,0x1
    4576:	f5e080e7          	jalr	-162(ra) # 54d0 <exit>
          printf("wrong char\n", s);
    457a:	85e6                	mv	a1,s9
    457c:	00003517          	auipc	a0,0x3
    4580:	3b450513          	addi	a0,a0,948 # 7930 <malloc+0x202a>
    4584:	00001097          	auipc	ra,0x1
    4588:	2c4080e7          	jalr	708(ra) # 5848 <printf>
          exit(1);
    458c:	4505                	li	a0,1
    458e:	00001097          	auipc	ra,0x1
    4592:	f42080e7          	jalr	-190(ra) # 54d0 <exit>
      total += n;
    4596:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    459a:	660d                	lui	a2,0x3
    459c:	85d2                	mv	a1,s4
    459e:	854e                	mv	a0,s3
    45a0:	00001097          	auipc	ra,0x1
    45a4:	f48080e7          	jalr	-184(ra) # 54e8 <read>
    45a8:	02a05363          	blez	a0,45ce <fourfiles+0x1c6>
    45ac:	00007797          	auipc	a5,0x7
    45b0:	38478793          	addi	a5,a5,900 # b930 <buf>
    45b4:	fff5069b          	addiw	a3,a0,-1
    45b8:	1682                	slli	a3,a3,0x20
    45ba:	9281                	srli	a3,a3,0x20
    45bc:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    45be:	0007c703          	lbu	a4,0(a5)
    45c2:	fa971ce3          	bne	a4,s1,457a <fourfiles+0x172>
      for(j = 0; j < n; j++){
    45c6:	0785                	addi	a5,a5,1
    45c8:	fed79be3          	bne	a5,a3,45be <fourfiles+0x1b6>
    45cc:	b7e9                	j	4596 <fourfiles+0x18e>
    close(fd);
    45ce:	854e                	mv	a0,s3
    45d0:	00001097          	auipc	ra,0x1
    45d4:	f28080e7          	jalr	-216(ra) # 54f8 <close>
    if(total != N*SZ){
    45d8:	03a91963          	bne	s2,s10,460a <fourfiles+0x202>
    unlink(fname);
    45dc:	8562                	mv	a0,s8
    45de:	00001097          	auipc	ra,0x1
    45e2:	f42080e7          	jalr	-190(ra) # 5520 <unlink>
  for(i = 0; i < NCHILD; i++){
    45e6:	0ba1                	addi	s7,s7,8
    45e8:	2b05                	addiw	s6,s6,1
    45ea:	03bb0e63          	beq	s6,s11,4626 <fourfiles+0x21e>
    fname = names[i];
    45ee:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    45f2:	4581                	li	a1,0
    45f4:	8562                	mv	a0,s8
    45f6:	00001097          	auipc	ra,0x1
    45fa:	f1a080e7          	jalr	-230(ra) # 5510 <open>
    45fe:	89aa                	mv	s3,a0
    total = 0;
    4600:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    4604:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4608:	bf49                	j	459a <fourfiles+0x192>
      printf("wrong length %d\n", total);
    460a:	85ca                	mv	a1,s2
    460c:	00003517          	auipc	a0,0x3
    4610:	33450513          	addi	a0,a0,820 # 7940 <malloc+0x203a>
    4614:	00001097          	auipc	ra,0x1
    4618:	234080e7          	jalr	564(ra) # 5848 <printf>
      exit(1);
    461c:	4505                	li	a0,1
    461e:	00001097          	auipc	ra,0x1
    4622:	eb2080e7          	jalr	-334(ra) # 54d0 <exit>
}
    4626:	70aa                	ld	ra,168(sp)
    4628:	740a                	ld	s0,160(sp)
    462a:	64ea                	ld	s1,152(sp)
    462c:	694a                	ld	s2,144(sp)
    462e:	69aa                	ld	s3,136(sp)
    4630:	6a0a                	ld	s4,128(sp)
    4632:	7ae6                	ld	s5,120(sp)
    4634:	7b46                	ld	s6,112(sp)
    4636:	7ba6                	ld	s7,104(sp)
    4638:	7c06                	ld	s8,96(sp)
    463a:	6ce6                	ld	s9,88(sp)
    463c:	6d46                	ld	s10,80(sp)
    463e:	6da6                	ld	s11,72(sp)
    4640:	614d                	addi	sp,sp,176
    4642:	8082                	ret

0000000000004644 <concreate>:
{
    4644:	7135                	addi	sp,sp,-160
    4646:	ed06                	sd	ra,152(sp)
    4648:	e922                	sd	s0,144(sp)
    464a:	e526                	sd	s1,136(sp)
    464c:	e14a                	sd	s2,128(sp)
    464e:	fcce                	sd	s3,120(sp)
    4650:	f8d2                	sd	s4,112(sp)
    4652:	f4d6                	sd	s5,104(sp)
    4654:	f0da                	sd	s6,96(sp)
    4656:	ecde                	sd	s7,88(sp)
    4658:	1100                	addi	s0,sp,160
    465a:	89aa                	mv	s3,a0
  file[0] = 'C';
    465c:	04300793          	li	a5,67
    4660:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4664:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4668:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    466a:	4b0d                	li	s6,3
    466c:	4a85                	li	s5,1
      link("C0", file);
    466e:	00003b97          	auipc	s7,0x3
    4672:	2eab8b93          	addi	s7,s7,746 # 7958 <malloc+0x2052>
  for(i = 0; i < N; i++){
    4676:	02800a13          	li	s4,40
    467a:	acc1                	j	494a <concreate+0x306>
      link("C0", file);
    467c:	fa840593          	addi	a1,s0,-88
    4680:	855e                	mv	a0,s7
    4682:	00001097          	auipc	ra,0x1
    4686:	eae080e7          	jalr	-338(ra) # 5530 <link>
    if(pid == 0) {
    468a:	a45d                	j	4930 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    468c:	4795                	li	a5,5
    468e:	02f9693b          	remw	s2,s2,a5
    4692:	4785                	li	a5,1
    4694:	02f90b63          	beq	s2,a5,46ca <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4698:	20200593          	li	a1,514
    469c:	fa840513          	addi	a0,s0,-88
    46a0:	00001097          	auipc	ra,0x1
    46a4:	e70080e7          	jalr	-400(ra) # 5510 <open>
      if(fd < 0){
    46a8:	26055b63          	bgez	a0,491e <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    46ac:	fa840593          	addi	a1,s0,-88
    46b0:	00003517          	auipc	a0,0x3
    46b4:	2b050513          	addi	a0,a0,688 # 7960 <malloc+0x205a>
    46b8:	00001097          	auipc	ra,0x1
    46bc:	190080e7          	jalr	400(ra) # 5848 <printf>
        exit(1);
    46c0:	4505                	li	a0,1
    46c2:	00001097          	auipc	ra,0x1
    46c6:	e0e080e7          	jalr	-498(ra) # 54d0 <exit>
      link("C0", file);
    46ca:	fa840593          	addi	a1,s0,-88
    46ce:	00003517          	auipc	a0,0x3
    46d2:	28a50513          	addi	a0,a0,650 # 7958 <malloc+0x2052>
    46d6:	00001097          	auipc	ra,0x1
    46da:	e5a080e7          	jalr	-422(ra) # 5530 <link>
      exit(0);
    46de:	4501                	li	a0,0
    46e0:	00001097          	auipc	ra,0x1
    46e4:	df0080e7          	jalr	-528(ra) # 54d0 <exit>
        exit(1);
    46e8:	4505                	li	a0,1
    46ea:	00001097          	auipc	ra,0x1
    46ee:	de6080e7          	jalr	-538(ra) # 54d0 <exit>
  memset(fa, 0, sizeof(fa));
    46f2:	02800613          	li	a2,40
    46f6:	4581                	li	a1,0
    46f8:	f8040513          	addi	a0,s0,-128
    46fc:	00001097          	auipc	ra,0x1
    4700:	bd0080e7          	jalr	-1072(ra) # 52cc <memset>
  fd = open(".", 0);
    4704:	4581                	li	a1,0
    4706:	00002517          	auipc	a0,0x2
    470a:	cca50513          	addi	a0,a0,-822 # 63d0 <malloc+0xaca>
    470e:	00001097          	auipc	ra,0x1
    4712:	e02080e7          	jalr	-510(ra) # 5510 <open>
    4716:	892a                	mv	s2,a0
  n = 0;
    4718:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    471a:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    471e:	02700b13          	li	s6,39
      fa[i] = 1;
    4722:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4724:	a03d                	j	4752 <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    4726:	f7240613          	addi	a2,s0,-142
    472a:	85ce                	mv	a1,s3
    472c:	00003517          	auipc	a0,0x3
    4730:	25450513          	addi	a0,a0,596 # 7980 <malloc+0x207a>
    4734:	00001097          	auipc	ra,0x1
    4738:	114080e7          	jalr	276(ra) # 5848 <printf>
        exit(1);
    473c:	4505                	li	a0,1
    473e:	00001097          	auipc	ra,0x1
    4742:	d92080e7          	jalr	-622(ra) # 54d0 <exit>
      fa[i] = 1;
    4746:	fb040793          	addi	a5,s0,-80
    474a:	973e                	add	a4,a4,a5
    474c:	fd770823          	sb	s7,-48(a4)
      n++;
    4750:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    4752:	4641                	li	a2,16
    4754:	f7040593          	addi	a1,s0,-144
    4758:	854a                	mv	a0,s2
    475a:	00001097          	auipc	ra,0x1
    475e:	d8e080e7          	jalr	-626(ra) # 54e8 <read>
    4762:	04a05a63          	blez	a0,47b6 <concreate+0x172>
    if(de.inum == 0)
    4766:	f7045783          	lhu	a5,-144(s0)
    476a:	d7e5                	beqz	a5,4752 <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    476c:	f7244783          	lbu	a5,-142(s0)
    4770:	ff4791e3          	bne	a5,s4,4752 <concreate+0x10e>
    4774:	f7444783          	lbu	a5,-140(s0)
    4778:	ffe9                	bnez	a5,4752 <concreate+0x10e>
      i = de.name[1] - '0';
    477a:	f7344783          	lbu	a5,-141(s0)
    477e:	fd07879b          	addiw	a5,a5,-48
    4782:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4786:	faeb60e3          	bltu	s6,a4,4726 <concreate+0xe2>
      if(fa[i]){
    478a:	fb040793          	addi	a5,s0,-80
    478e:	97ba                	add	a5,a5,a4
    4790:	fd07c783          	lbu	a5,-48(a5)
    4794:	dbcd                	beqz	a5,4746 <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4796:	f7240613          	addi	a2,s0,-142
    479a:	85ce                	mv	a1,s3
    479c:	00003517          	auipc	a0,0x3
    47a0:	20450513          	addi	a0,a0,516 # 79a0 <malloc+0x209a>
    47a4:	00001097          	auipc	ra,0x1
    47a8:	0a4080e7          	jalr	164(ra) # 5848 <printf>
        exit(1);
    47ac:	4505                	li	a0,1
    47ae:	00001097          	auipc	ra,0x1
    47b2:	d22080e7          	jalr	-734(ra) # 54d0 <exit>
  close(fd);
    47b6:	854a                	mv	a0,s2
    47b8:	00001097          	auipc	ra,0x1
    47bc:	d40080e7          	jalr	-704(ra) # 54f8 <close>
  if(n != N){
    47c0:	02800793          	li	a5,40
    47c4:	00fa9763          	bne	s5,a5,47d2 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    47c8:	4a8d                	li	s5,3
    47ca:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    47cc:	02800a13          	li	s4,40
    47d0:	a8c9                	j	48a2 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    47d2:	85ce                	mv	a1,s3
    47d4:	00003517          	auipc	a0,0x3
    47d8:	1f450513          	addi	a0,a0,500 # 79c8 <malloc+0x20c2>
    47dc:	00001097          	auipc	ra,0x1
    47e0:	06c080e7          	jalr	108(ra) # 5848 <printf>
    exit(1);
    47e4:	4505                	li	a0,1
    47e6:	00001097          	auipc	ra,0x1
    47ea:	cea080e7          	jalr	-790(ra) # 54d0 <exit>
      printf("%s: fork failed\n", s);
    47ee:	85ce                	mv	a1,s3
    47f0:	00002517          	auipc	a0,0x2
    47f4:	d8050513          	addi	a0,a0,-640 # 6570 <malloc+0xc6a>
    47f8:	00001097          	auipc	ra,0x1
    47fc:	050080e7          	jalr	80(ra) # 5848 <printf>
      exit(1);
    4800:	4505                	li	a0,1
    4802:	00001097          	auipc	ra,0x1
    4806:	cce080e7          	jalr	-818(ra) # 54d0 <exit>
      close(open(file, 0));
    480a:	4581                	li	a1,0
    480c:	fa840513          	addi	a0,s0,-88
    4810:	00001097          	auipc	ra,0x1
    4814:	d00080e7          	jalr	-768(ra) # 5510 <open>
    4818:	00001097          	auipc	ra,0x1
    481c:	ce0080e7          	jalr	-800(ra) # 54f8 <close>
      close(open(file, 0));
    4820:	4581                	li	a1,0
    4822:	fa840513          	addi	a0,s0,-88
    4826:	00001097          	auipc	ra,0x1
    482a:	cea080e7          	jalr	-790(ra) # 5510 <open>
    482e:	00001097          	auipc	ra,0x1
    4832:	cca080e7          	jalr	-822(ra) # 54f8 <close>
      close(open(file, 0));
    4836:	4581                	li	a1,0
    4838:	fa840513          	addi	a0,s0,-88
    483c:	00001097          	auipc	ra,0x1
    4840:	cd4080e7          	jalr	-812(ra) # 5510 <open>
    4844:	00001097          	auipc	ra,0x1
    4848:	cb4080e7          	jalr	-844(ra) # 54f8 <close>
      close(open(file, 0));
    484c:	4581                	li	a1,0
    484e:	fa840513          	addi	a0,s0,-88
    4852:	00001097          	auipc	ra,0x1
    4856:	cbe080e7          	jalr	-834(ra) # 5510 <open>
    485a:	00001097          	auipc	ra,0x1
    485e:	c9e080e7          	jalr	-866(ra) # 54f8 <close>
      close(open(file, 0));
    4862:	4581                	li	a1,0
    4864:	fa840513          	addi	a0,s0,-88
    4868:	00001097          	auipc	ra,0x1
    486c:	ca8080e7          	jalr	-856(ra) # 5510 <open>
    4870:	00001097          	auipc	ra,0x1
    4874:	c88080e7          	jalr	-888(ra) # 54f8 <close>
      close(open(file, 0));
    4878:	4581                	li	a1,0
    487a:	fa840513          	addi	a0,s0,-88
    487e:	00001097          	auipc	ra,0x1
    4882:	c92080e7          	jalr	-878(ra) # 5510 <open>
    4886:	00001097          	auipc	ra,0x1
    488a:	c72080e7          	jalr	-910(ra) # 54f8 <close>
    if(pid == 0)
    488e:	08090363          	beqz	s2,4914 <concreate+0x2d0>
      wait(0);
    4892:	4501                	li	a0,0
    4894:	00001097          	auipc	ra,0x1
    4898:	c44080e7          	jalr	-956(ra) # 54d8 <wait>
  for(i = 0; i < N; i++){
    489c:	2485                	addiw	s1,s1,1
    489e:	0f448563          	beq	s1,s4,4988 <concreate+0x344>
    file[1] = '0' + i;
    48a2:	0304879b          	addiw	a5,s1,48
    48a6:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    48aa:	00001097          	auipc	ra,0x1
    48ae:	c1e080e7          	jalr	-994(ra) # 54c8 <fork>
    48b2:	892a                	mv	s2,a0
    if(pid < 0){
    48b4:	f2054de3          	bltz	a0,47ee <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    48b8:	0354e73b          	remw	a4,s1,s5
    48bc:	00a767b3          	or	a5,a4,a0
    48c0:	2781                	sext.w	a5,a5
    48c2:	d7a1                	beqz	a5,480a <concreate+0x1c6>
    48c4:	01671363          	bne	a4,s6,48ca <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    48c8:	f129                	bnez	a0,480a <concreate+0x1c6>
      unlink(file);
    48ca:	fa840513          	addi	a0,s0,-88
    48ce:	00001097          	auipc	ra,0x1
    48d2:	c52080e7          	jalr	-942(ra) # 5520 <unlink>
      unlink(file);
    48d6:	fa840513          	addi	a0,s0,-88
    48da:	00001097          	auipc	ra,0x1
    48de:	c46080e7          	jalr	-954(ra) # 5520 <unlink>
      unlink(file);
    48e2:	fa840513          	addi	a0,s0,-88
    48e6:	00001097          	auipc	ra,0x1
    48ea:	c3a080e7          	jalr	-966(ra) # 5520 <unlink>
      unlink(file);
    48ee:	fa840513          	addi	a0,s0,-88
    48f2:	00001097          	auipc	ra,0x1
    48f6:	c2e080e7          	jalr	-978(ra) # 5520 <unlink>
      unlink(file);
    48fa:	fa840513          	addi	a0,s0,-88
    48fe:	00001097          	auipc	ra,0x1
    4902:	c22080e7          	jalr	-990(ra) # 5520 <unlink>
      unlink(file);
    4906:	fa840513          	addi	a0,s0,-88
    490a:	00001097          	auipc	ra,0x1
    490e:	c16080e7          	jalr	-1002(ra) # 5520 <unlink>
    4912:	bfb5                	j	488e <concreate+0x24a>
      exit(0);
    4914:	4501                	li	a0,0
    4916:	00001097          	auipc	ra,0x1
    491a:	bba080e7          	jalr	-1094(ra) # 54d0 <exit>
      close(fd);
    491e:	00001097          	auipc	ra,0x1
    4922:	bda080e7          	jalr	-1062(ra) # 54f8 <close>
    if(pid == 0) {
    4926:	bb65                	j	46de <concreate+0x9a>
      close(fd);
    4928:	00001097          	auipc	ra,0x1
    492c:	bd0080e7          	jalr	-1072(ra) # 54f8 <close>
      wait(&xstatus);
    4930:	f6c40513          	addi	a0,s0,-148
    4934:	00001097          	auipc	ra,0x1
    4938:	ba4080e7          	jalr	-1116(ra) # 54d8 <wait>
      if(xstatus != 0)
    493c:	f6c42483          	lw	s1,-148(s0)
    4940:	da0494e3          	bnez	s1,46e8 <concreate+0xa4>
  for(i = 0; i < N; i++){
    4944:	2905                	addiw	s2,s2,1
    4946:	db4906e3          	beq	s2,s4,46f2 <concreate+0xae>
    file[1] = '0' + i;
    494a:	0309079b          	addiw	a5,s2,48
    494e:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4952:	fa840513          	addi	a0,s0,-88
    4956:	00001097          	auipc	ra,0x1
    495a:	bca080e7          	jalr	-1078(ra) # 5520 <unlink>
    pid = fork();
    495e:	00001097          	auipc	ra,0x1
    4962:	b6a080e7          	jalr	-1174(ra) # 54c8 <fork>
    if(pid && (i % 3) == 1){
    4966:	d20503e3          	beqz	a0,468c <concreate+0x48>
    496a:	036967bb          	remw	a5,s2,s6
    496e:	d15787e3          	beq	a5,s5,467c <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4972:	20200593          	li	a1,514
    4976:	fa840513          	addi	a0,s0,-88
    497a:	00001097          	auipc	ra,0x1
    497e:	b96080e7          	jalr	-1130(ra) # 5510 <open>
      if(fd < 0){
    4982:	fa0553e3          	bgez	a0,4928 <concreate+0x2e4>
    4986:	b31d                	j	46ac <concreate+0x68>
}
    4988:	60ea                	ld	ra,152(sp)
    498a:	644a                	ld	s0,144(sp)
    498c:	64aa                	ld	s1,136(sp)
    498e:	690a                	ld	s2,128(sp)
    4990:	79e6                	ld	s3,120(sp)
    4992:	7a46                	ld	s4,112(sp)
    4994:	7aa6                	ld	s5,104(sp)
    4996:	7b06                	ld	s6,96(sp)
    4998:	6be6                	ld	s7,88(sp)
    499a:	610d                	addi	sp,sp,160
    499c:	8082                	ret

000000000000499e <bigfile>:
{
    499e:	7139                	addi	sp,sp,-64
    49a0:	fc06                	sd	ra,56(sp)
    49a2:	f822                	sd	s0,48(sp)
    49a4:	f426                	sd	s1,40(sp)
    49a6:	f04a                	sd	s2,32(sp)
    49a8:	ec4e                	sd	s3,24(sp)
    49aa:	e852                	sd	s4,16(sp)
    49ac:	e456                	sd	s5,8(sp)
    49ae:	0080                	addi	s0,sp,64
    49b0:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    49b2:	00003517          	auipc	a0,0x3
    49b6:	04e50513          	addi	a0,a0,78 # 7a00 <malloc+0x20fa>
    49ba:	00001097          	auipc	ra,0x1
    49be:	b66080e7          	jalr	-1178(ra) # 5520 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    49c2:	20200593          	li	a1,514
    49c6:	00003517          	auipc	a0,0x3
    49ca:	03a50513          	addi	a0,a0,58 # 7a00 <malloc+0x20fa>
    49ce:	00001097          	auipc	ra,0x1
    49d2:	b42080e7          	jalr	-1214(ra) # 5510 <open>
    49d6:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    49d8:	4481                	li	s1,0
    memset(buf, i, SZ);
    49da:	00007917          	auipc	s2,0x7
    49de:	f5690913          	addi	s2,s2,-170 # b930 <buf>
  for(i = 0; i < N; i++){
    49e2:	4a51                	li	s4,20
  if(fd < 0){
    49e4:	0a054063          	bltz	a0,4a84 <bigfile+0xe6>
    memset(buf, i, SZ);
    49e8:	25800613          	li	a2,600
    49ec:	85a6                	mv	a1,s1
    49ee:	854a                	mv	a0,s2
    49f0:	00001097          	auipc	ra,0x1
    49f4:	8dc080e7          	jalr	-1828(ra) # 52cc <memset>
    if(write(fd, buf, SZ) != SZ){
    49f8:	25800613          	li	a2,600
    49fc:	85ca                	mv	a1,s2
    49fe:	854e                	mv	a0,s3
    4a00:	00001097          	auipc	ra,0x1
    4a04:	af0080e7          	jalr	-1296(ra) # 54f0 <write>
    4a08:	25800793          	li	a5,600
    4a0c:	08f51a63          	bne	a0,a5,4aa0 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4a10:	2485                	addiw	s1,s1,1
    4a12:	fd449be3          	bne	s1,s4,49e8 <bigfile+0x4a>
  close(fd);
    4a16:	854e                	mv	a0,s3
    4a18:	00001097          	auipc	ra,0x1
    4a1c:	ae0080e7          	jalr	-1312(ra) # 54f8 <close>
  fd = open("bigfile.dat", 0);
    4a20:	4581                	li	a1,0
    4a22:	00003517          	auipc	a0,0x3
    4a26:	fde50513          	addi	a0,a0,-34 # 7a00 <malloc+0x20fa>
    4a2a:	00001097          	auipc	ra,0x1
    4a2e:	ae6080e7          	jalr	-1306(ra) # 5510 <open>
    4a32:	8a2a                	mv	s4,a0
  total = 0;
    4a34:	4981                	li	s3,0
  for(i = 0; ; i++){
    4a36:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4a38:	00007917          	auipc	s2,0x7
    4a3c:	ef890913          	addi	s2,s2,-264 # b930 <buf>
  if(fd < 0){
    4a40:	06054e63          	bltz	a0,4abc <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4a44:	12c00613          	li	a2,300
    4a48:	85ca                	mv	a1,s2
    4a4a:	8552                	mv	a0,s4
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	a9c080e7          	jalr	-1380(ra) # 54e8 <read>
    if(cc < 0){
    4a54:	08054263          	bltz	a0,4ad8 <bigfile+0x13a>
    if(cc == 0)
    4a58:	c971                	beqz	a0,4b2c <bigfile+0x18e>
    if(cc != SZ/2){
    4a5a:	12c00793          	li	a5,300
    4a5e:	08f51b63          	bne	a0,a5,4af4 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4a62:	01f4d79b          	srliw	a5,s1,0x1f
    4a66:	9fa5                	addw	a5,a5,s1
    4a68:	4017d79b          	sraiw	a5,a5,0x1
    4a6c:	00094703          	lbu	a4,0(s2)
    4a70:	0af71063          	bne	a4,a5,4b10 <bigfile+0x172>
    4a74:	12b94703          	lbu	a4,299(s2)
    4a78:	08f71c63          	bne	a4,a5,4b10 <bigfile+0x172>
    total += cc;
    4a7c:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4a80:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4a82:	b7c9                	j	4a44 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4a84:	85d6                	mv	a1,s5
    4a86:	00003517          	auipc	a0,0x3
    4a8a:	f8a50513          	addi	a0,a0,-118 # 7a10 <malloc+0x210a>
    4a8e:	00001097          	auipc	ra,0x1
    4a92:	dba080e7          	jalr	-582(ra) # 5848 <printf>
    exit(1);
    4a96:	4505                	li	a0,1
    4a98:	00001097          	auipc	ra,0x1
    4a9c:	a38080e7          	jalr	-1480(ra) # 54d0 <exit>
      printf("%s: write bigfile failed\n", s);
    4aa0:	85d6                	mv	a1,s5
    4aa2:	00003517          	auipc	a0,0x3
    4aa6:	f8e50513          	addi	a0,a0,-114 # 7a30 <malloc+0x212a>
    4aaa:	00001097          	auipc	ra,0x1
    4aae:	d9e080e7          	jalr	-610(ra) # 5848 <printf>
      exit(1);
    4ab2:	4505                	li	a0,1
    4ab4:	00001097          	auipc	ra,0x1
    4ab8:	a1c080e7          	jalr	-1508(ra) # 54d0 <exit>
    printf("%s: cannot open bigfile\n", s);
    4abc:	85d6                	mv	a1,s5
    4abe:	00003517          	auipc	a0,0x3
    4ac2:	f9250513          	addi	a0,a0,-110 # 7a50 <malloc+0x214a>
    4ac6:	00001097          	auipc	ra,0x1
    4aca:	d82080e7          	jalr	-638(ra) # 5848 <printf>
    exit(1);
    4ace:	4505                	li	a0,1
    4ad0:	00001097          	auipc	ra,0x1
    4ad4:	a00080e7          	jalr	-1536(ra) # 54d0 <exit>
      printf("%s: read bigfile failed\n", s);
    4ad8:	85d6                	mv	a1,s5
    4ada:	00003517          	auipc	a0,0x3
    4ade:	f9650513          	addi	a0,a0,-106 # 7a70 <malloc+0x216a>
    4ae2:	00001097          	auipc	ra,0x1
    4ae6:	d66080e7          	jalr	-666(ra) # 5848 <printf>
      exit(1);
    4aea:	4505                	li	a0,1
    4aec:	00001097          	auipc	ra,0x1
    4af0:	9e4080e7          	jalr	-1564(ra) # 54d0 <exit>
      printf("%s: short read bigfile\n", s);
    4af4:	85d6                	mv	a1,s5
    4af6:	00003517          	auipc	a0,0x3
    4afa:	f9a50513          	addi	a0,a0,-102 # 7a90 <malloc+0x218a>
    4afe:	00001097          	auipc	ra,0x1
    4b02:	d4a080e7          	jalr	-694(ra) # 5848 <printf>
      exit(1);
    4b06:	4505                	li	a0,1
    4b08:	00001097          	auipc	ra,0x1
    4b0c:	9c8080e7          	jalr	-1592(ra) # 54d0 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4b10:	85d6                	mv	a1,s5
    4b12:	00003517          	auipc	a0,0x3
    4b16:	f9650513          	addi	a0,a0,-106 # 7aa8 <malloc+0x21a2>
    4b1a:	00001097          	auipc	ra,0x1
    4b1e:	d2e080e7          	jalr	-722(ra) # 5848 <printf>
      exit(1);
    4b22:	4505                	li	a0,1
    4b24:	00001097          	auipc	ra,0x1
    4b28:	9ac080e7          	jalr	-1620(ra) # 54d0 <exit>
  close(fd);
    4b2c:	8552                	mv	a0,s4
    4b2e:	00001097          	auipc	ra,0x1
    4b32:	9ca080e7          	jalr	-1590(ra) # 54f8 <close>
  if(total != N*SZ){
    4b36:	678d                	lui	a5,0x3
    4b38:	ee078793          	addi	a5,a5,-288 # 2ee0 <dirtest+0x94>
    4b3c:	02f99363          	bne	s3,a5,4b62 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4b40:	00003517          	auipc	a0,0x3
    4b44:	ec050513          	addi	a0,a0,-320 # 7a00 <malloc+0x20fa>
    4b48:	00001097          	auipc	ra,0x1
    4b4c:	9d8080e7          	jalr	-1576(ra) # 5520 <unlink>
}
    4b50:	70e2                	ld	ra,56(sp)
    4b52:	7442                	ld	s0,48(sp)
    4b54:	74a2                	ld	s1,40(sp)
    4b56:	7902                	ld	s2,32(sp)
    4b58:	69e2                	ld	s3,24(sp)
    4b5a:	6a42                	ld	s4,16(sp)
    4b5c:	6aa2                	ld	s5,8(sp)
    4b5e:	6121                	addi	sp,sp,64
    4b60:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4b62:	85d6                	mv	a1,s5
    4b64:	00003517          	auipc	a0,0x3
    4b68:	f6450513          	addi	a0,a0,-156 # 7ac8 <malloc+0x21c2>
    4b6c:	00001097          	auipc	ra,0x1
    4b70:	cdc080e7          	jalr	-804(ra) # 5848 <printf>
    exit(1);
    4b74:	4505                	li	a0,1
    4b76:	00001097          	auipc	ra,0x1
    4b7a:	95a080e7          	jalr	-1702(ra) # 54d0 <exit>

0000000000004b7e <fsfull>:
{
    4b7e:	7171                	addi	sp,sp,-176
    4b80:	f506                	sd	ra,168(sp)
    4b82:	f122                	sd	s0,160(sp)
    4b84:	ed26                	sd	s1,152(sp)
    4b86:	e94a                	sd	s2,144(sp)
    4b88:	e54e                	sd	s3,136(sp)
    4b8a:	e152                	sd	s4,128(sp)
    4b8c:	fcd6                	sd	s5,120(sp)
    4b8e:	f8da                	sd	s6,112(sp)
    4b90:	f4de                	sd	s7,104(sp)
    4b92:	f0e2                	sd	s8,96(sp)
    4b94:	ece6                	sd	s9,88(sp)
    4b96:	e8ea                	sd	s10,80(sp)
    4b98:	e4ee                	sd	s11,72(sp)
    4b9a:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4b9c:	00003517          	auipc	a0,0x3
    4ba0:	f4c50513          	addi	a0,a0,-180 # 7ae8 <malloc+0x21e2>
    4ba4:	00001097          	auipc	ra,0x1
    4ba8:	ca4080e7          	jalr	-860(ra) # 5848 <printf>
  for(nfiles = 0; ; nfiles++){
    4bac:	4481                	li	s1,0
    name[0] = 'f';
    4bae:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4bb2:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4bb6:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4bba:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4bbc:	00003c97          	auipc	s9,0x3
    4bc0:	f3cc8c93          	addi	s9,s9,-196 # 7af8 <malloc+0x21f2>
    int total = 0;
    4bc4:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4bc6:	00007a17          	auipc	s4,0x7
    4bca:	d6aa0a13          	addi	s4,s4,-662 # b930 <buf>
    name[0] = 'f';
    4bce:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4bd2:	0384c7bb          	divw	a5,s1,s8
    4bd6:	0307879b          	addiw	a5,a5,48
    4bda:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4bde:	0384e7bb          	remw	a5,s1,s8
    4be2:	0377c7bb          	divw	a5,a5,s7
    4be6:	0307879b          	addiw	a5,a5,48
    4bea:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4bee:	0374e7bb          	remw	a5,s1,s7
    4bf2:	0367c7bb          	divw	a5,a5,s6
    4bf6:	0307879b          	addiw	a5,a5,48
    4bfa:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4bfe:	0364e7bb          	remw	a5,s1,s6
    4c02:	0307879b          	addiw	a5,a5,48
    4c06:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c0a:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4c0e:	f5040593          	addi	a1,s0,-176
    4c12:	8566                	mv	a0,s9
    4c14:	00001097          	auipc	ra,0x1
    4c18:	c34080e7          	jalr	-972(ra) # 5848 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4c1c:	20200593          	li	a1,514
    4c20:	f5040513          	addi	a0,s0,-176
    4c24:	00001097          	auipc	ra,0x1
    4c28:	8ec080e7          	jalr	-1812(ra) # 5510 <open>
    4c2c:	892a                	mv	s2,a0
    if(fd < 0){
    4c2e:	0a055663          	bgez	a0,4cda <fsfull+0x15c>
      printf("open %s failed\n", name);
    4c32:	f5040593          	addi	a1,s0,-176
    4c36:	00003517          	auipc	a0,0x3
    4c3a:	ed250513          	addi	a0,a0,-302 # 7b08 <malloc+0x2202>
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	c0a080e7          	jalr	-1014(ra) # 5848 <printf>
  while(nfiles >= 0){
    4c46:	0604c363          	bltz	s1,4cac <fsfull+0x12e>
    name[0] = 'f';
    4c4a:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4c4e:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4c52:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4c56:	4929                	li	s2,10
  while(nfiles >= 0){
    4c58:	5afd                	li	s5,-1
    name[0] = 'f';
    4c5a:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c5e:	0344c7bb          	divw	a5,s1,s4
    4c62:	0307879b          	addiw	a5,a5,48
    4c66:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c6a:	0344e7bb          	remw	a5,s1,s4
    4c6e:	0337c7bb          	divw	a5,a5,s3
    4c72:	0307879b          	addiw	a5,a5,48
    4c76:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c7a:	0334e7bb          	remw	a5,s1,s3
    4c7e:	0327c7bb          	divw	a5,a5,s2
    4c82:	0307879b          	addiw	a5,a5,48
    4c86:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c8a:	0324e7bb          	remw	a5,s1,s2
    4c8e:	0307879b          	addiw	a5,a5,48
    4c92:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c96:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4c9a:	f5040513          	addi	a0,s0,-176
    4c9e:	00001097          	auipc	ra,0x1
    4ca2:	882080e7          	jalr	-1918(ra) # 5520 <unlink>
    nfiles--;
    4ca6:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4ca8:	fb5499e3          	bne	s1,s5,4c5a <fsfull+0xdc>
  printf("fsfull test finished\n");
    4cac:	00003517          	auipc	a0,0x3
    4cb0:	e7c50513          	addi	a0,a0,-388 # 7b28 <malloc+0x2222>
    4cb4:	00001097          	auipc	ra,0x1
    4cb8:	b94080e7          	jalr	-1132(ra) # 5848 <printf>
}
    4cbc:	70aa                	ld	ra,168(sp)
    4cbe:	740a                	ld	s0,160(sp)
    4cc0:	64ea                	ld	s1,152(sp)
    4cc2:	694a                	ld	s2,144(sp)
    4cc4:	69aa                	ld	s3,136(sp)
    4cc6:	6a0a                	ld	s4,128(sp)
    4cc8:	7ae6                	ld	s5,120(sp)
    4cca:	7b46                	ld	s6,112(sp)
    4ccc:	7ba6                	ld	s7,104(sp)
    4cce:	7c06                	ld	s8,96(sp)
    4cd0:	6ce6                	ld	s9,88(sp)
    4cd2:	6d46                	ld	s10,80(sp)
    4cd4:	6da6                	ld	s11,72(sp)
    4cd6:	614d                	addi	sp,sp,176
    4cd8:	8082                	ret
    int total = 0;
    4cda:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4cdc:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4ce0:	40000613          	li	a2,1024
    4ce4:	85d2                	mv	a1,s4
    4ce6:	854a                	mv	a0,s2
    4ce8:	00001097          	auipc	ra,0x1
    4cec:	808080e7          	jalr	-2040(ra) # 54f0 <write>
      if(cc < BSIZE)
    4cf0:	00aad563          	bge	s5,a0,4cfa <fsfull+0x17c>
      total += cc;
    4cf4:	00a989bb          	addw	s3,s3,a0
    while(1){
    4cf8:	b7e5                	j	4ce0 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4cfa:	85ce                	mv	a1,s3
    4cfc:	00003517          	auipc	a0,0x3
    4d00:	e1c50513          	addi	a0,a0,-484 # 7b18 <malloc+0x2212>
    4d04:	00001097          	auipc	ra,0x1
    4d08:	b44080e7          	jalr	-1212(ra) # 5848 <printf>
    close(fd);
    4d0c:	854a                	mv	a0,s2
    4d0e:	00000097          	auipc	ra,0x0
    4d12:	7ea080e7          	jalr	2026(ra) # 54f8 <close>
    if(total == 0)
    4d16:	f20988e3          	beqz	s3,4c46 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4d1a:	2485                	addiw	s1,s1,1
    4d1c:	bd4d                	j	4bce <fsfull+0x50>

0000000000004d1e <rand>:
{
    4d1e:	1141                	addi	sp,sp,-16
    4d20:	e422                	sd	s0,8(sp)
    4d22:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4d24:	00003717          	auipc	a4,0x3
    4d28:	3dc70713          	addi	a4,a4,988 # 8100 <randstate>
    4d2c:	6308                	ld	a0,0(a4)
    4d2e:	001967b7          	lui	a5,0x196
    4d32:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187ccd>
    4d36:	02f50533          	mul	a0,a0,a5
    4d3a:	3c6ef7b7          	lui	a5,0x3c6ef
    4d3e:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e0a1f>
    4d42:	953e                	add	a0,a0,a5
    4d44:	e308                	sd	a0,0(a4)
}
    4d46:	2501                	sext.w	a0,a0
    4d48:	6422                	ld	s0,8(sp)
    4d4a:	0141                	addi	sp,sp,16
    4d4c:	8082                	ret

0000000000004d4e <badwrite>:
{
    4d4e:	7179                	addi	sp,sp,-48
    4d50:	f406                	sd	ra,40(sp)
    4d52:	f022                	sd	s0,32(sp)
    4d54:	ec26                	sd	s1,24(sp)
    4d56:	e84a                	sd	s2,16(sp)
    4d58:	e44e                	sd	s3,8(sp)
    4d5a:	e052                	sd	s4,0(sp)
    4d5c:	1800                	addi	s0,sp,48
  unlink("junk");
    4d5e:	00003517          	auipc	a0,0x3
    4d62:	de250513          	addi	a0,a0,-542 # 7b40 <malloc+0x223a>
    4d66:	00000097          	auipc	ra,0x0
    4d6a:	7ba080e7          	jalr	1978(ra) # 5520 <unlink>
    4d6e:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d72:	00003997          	auipc	s3,0x3
    4d76:	dce98993          	addi	s3,s3,-562 # 7b40 <malloc+0x223a>
    write(fd, (char*)0xffffffffffL, 1);
    4d7a:	5a7d                	li	s4,-1
    4d7c:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d80:	20100593          	li	a1,513
    4d84:	854e                	mv	a0,s3
    4d86:	00000097          	auipc	ra,0x0
    4d8a:	78a080e7          	jalr	1930(ra) # 5510 <open>
    4d8e:	84aa                	mv	s1,a0
    if(fd < 0){
    4d90:	06054b63          	bltz	a0,4e06 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4d94:	4605                	li	a2,1
    4d96:	85d2                	mv	a1,s4
    4d98:	00000097          	auipc	ra,0x0
    4d9c:	758080e7          	jalr	1880(ra) # 54f0 <write>
    close(fd);
    4da0:	8526                	mv	a0,s1
    4da2:	00000097          	auipc	ra,0x0
    4da6:	756080e7          	jalr	1878(ra) # 54f8 <close>
    unlink("junk");
    4daa:	854e                	mv	a0,s3
    4dac:	00000097          	auipc	ra,0x0
    4db0:	774080e7          	jalr	1908(ra) # 5520 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4db4:	397d                	addiw	s2,s2,-1
    4db6:	fc0915e3          	bnez	s2,4d80 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4dba:	20100593          	li	a1,513
    4dbe:	00003517          	auipc	a0,0x3
    4dc2:	d8250513          	addi	a0,a0,-638 # 7b40 <malloc+0x223a>
    4dc6:	00000097          	auipc	ra,0x0
    4dca:	74a080e7          	jalr	1866(ra) # 5510 <open>
    4dce:	84aa                	mv	s1,a0
  if(fd < 0){
    4dd0:	04054863          	bltz	a0,4e20 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4dd4:	4605                	li	a2,1
    4dd6:	00001597          	auipc	a1,0x1
    4dda:	fd258593          	addi	a1,a1,-46 # 5da8 <malloc+0x4a2>
    4dde:	00000097          	auipc	ra,0x0
    4de2:	712080e7          	jalr	1810(ra) # 54f0 <write>
    4de6:	4785                	li	a5,1
    4de8:	04f50963          	beq	a0,a5,4e3a <badwrite+0xec>
    printf("write failed\n");
    4dec:	00003517          	auipc	a0,0x3
    4df0:	d7450513          	addi	a0,a0,-652 # 7b60 <malloc+0x225a>
    4df4:	00001097          	auipc	ra,0x1
    4df8:	a54080e7          	jalr	-1452(ra) # 5848 <printf>
    exit(1);
    4dfc:	4505                	li	a0,1
    4dfe:	00000097          	auipc	ra,0x0
    4e02:	6d2080e7          	jalr	1746(ra) # 54d0 <exit>
      printf("open junk failed\n");
    4e06:	00003517          	auipc	a0,0x3
    4e0a:	d4250513          	addi	a0,a0,-702 # 7b48 <malloc+0x2242>
    4e0e:	00001097          	auipc	ra,0x1
    4e12:	a3a080e7          	jalr	-1478(ra) # 5848 <printf>
      exit(1);
    4e16:	4505                	li	a0,1
    4e18:	00000097          	auipc	ra,0x0
    4e1c:	6b8080e7          	jalr	1720(ra) # 54d0 <exit>
    printf("open junk failed\n");
    4e20:	00003517          	auipc	a0,0x3
    4e24:	d2850513          	addi	a0,a0,-728 # 7b48 <malloc+0x2242>
    4e28:	00001097          	auipc	ra,0x1
    4e2c:	a20080e7          	jalr	-1504(ra) # 5848 <printf>
    exit(1);
    4e30:	4505                	li	a0,1
    4e32:	00000097          	auipc	ra,0x0
    4e36:	69e080e7          	jalr	1694(ra) # 54d0 <exit>
  close(fd);
    4e3a:	8526                	mv	a0,s1
    4e3c:	00000097          	auipc	ra,0x0
    4e40:	6bc080e7          	jalr	1724(ra) # 54f8 <close>
  unlink("junk");
    4e44:	00003517          	auipc	a0,0x3
    4e48:	cfc50513          	addi	a0,a0,-772 # 7b40 <malloc+0x223a>
    4e4c:	00000097          	auipc	ra,0x0
    4e50:	6d4080e7          	jalr	1748(ra) # 5520 <unlink>
  exit(0);
    4e54:	4501                	li	a0,0
    4e56:	00000097          	auipc	ra,0x0
    4e5a:	67a080e7          	jalr	1658(ra) # 54d0 <exit>

0000000000004e5e <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4e5e:	7139                	addi	sp,sp,-64
    4e60:	fc06                	sd	ra,56(sp)
    4e62:	f822                	sd	s0,48(sp)
    4e64:	f426                	sd	s1,40(sp)
    4e66:	f04a                	sd	s2,32(sp)
    4e68:	ec4e                	sd	s3,24(sp)
    4e6a:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4e6c:	fc840513          	addi	a0,s0,-56
    4e70:	00000097          	auipc	ra,0x0
    4e74:	670080e7          	jalr	1648(ra) # 54e0 <pipe>
    4e78:	06054863          	bltz	a0,4ee8 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4e7c:	00000097          	auipc	ra,0x0
    4e80:	64c080e7          	jalr	1612(ra) # 54c8 <fork>

  if(pid < 0){
    4e84:	06054f63          	bltz	a0,4f02 <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4e88:	ed59                	bnez	a0,4f26 <countfree+0xc8>
    close(fds[0]);
    4e8a:	fc842503          	lw	a0,-56(s0)
    4e8e:	00000097          	auipc	ra,0x0
    4e92:	66a080e7          	jalr	1642(ra) # 54f8 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4e96:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4e98:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4e9a:	00001917          	auipc	s2,0x1
    4e9e:	f0e90913          	addi	s2,s2,-242 # 5da8 <malloc+0x4a2>
      uint64 a = (uint64) sbrk(4096);
    4ea2:	6505                	lui	a0,0x1
    4ea4:	00000097          	auipc	ra,0x0
    4ea8:	6b4080e7          	jalr	1716(ra) # 5558 <sbrk>
      if(a == 0xffffffffffffffff){
    4eac:	06950863          	beq	a0,s1,4f1c <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    4eb0:	6785                	lui	a5,0x1
    4eb2:	953e                	add	a0,a0,a5
    4eb4:	ff350fa3          	sb	s3,-1(a0) # fff <bigdir+0x89>
      if(write(fds[1], "x", 1) != 1){
    4eb8:	4605                	li	a2,1
    4eba:	85ca                	mv	a1,s2
    4ebc:	fcc42503          	lw	a0,-52(s0)
    4ec0:	00000097          	auipc	ra,0x0
    4ec4:	630080e7          	jalr	1584(ra) # 54f0 <write>
    4ec8:	4785                	li	a5,1
    4eca:	fcf50ce3          	beq	a0,a5,4ea2 <countfree+0x44>
        printf("write() failed in countfree()\n");
    4ece:	00003517          	auipc	a0,0x3
    4ed2:	ce250513          	addi	a0,a0,-798 # 7bb0 <malloc+0x22aa>
    4ed6:	00001097          	auipc	ra,0x1
    4eda:	972080e7          	jalr	-1678(ra) # 5848 <printf>
        exit(1);
    4ede:	4505                	li	a0,1
    4ee0:	00000097          	auipc	ra,0x0
    4ee4:	5f0080e7          	jalr	1520(ra) # 54d0 <exit>
    printf("pipe() failed in countfree()\n");
    4ee8:	00003517          	auipc	a0,0x3
    4eec:	c8850513          	addi	a0,a0,-888 # 7b70 <malloc+0x226a>
    4ef0:	00001097          	auipc	ra,0x1
    4ef4:	958080e7          	jalr	-1704(ra) # 5848 <printf>
    exit(1);
    4ef8:	4505                	li	a0,1
    4efa:	00000097          	auipc	ra,0x0
    4efe:	5d6080e7          	jalr	1494(ra) # 54d0 <exit>
    printf("fork failed in countfree()\n");
    4f02:	00003517          	auipc	a0,0x3
    4f06:	c8e50513          	addi	a0,a0,-882 # 7b90 <malloc+0x228a>
    4f0a:	00001097          	auipc	ra,0x1
    4f0e:	93e080e7          	jalr	-1730(ra) # 5848 <printf>
    exit(1);
    4f12:	4505                	li	a0,1
    4f14:	00000097          	auipc	ra,0x0
    4f18:	5bc080e7          	jalr	1468(ra) # 54d0 <exit>
      }
    }

    exit(0);
    4f1c:	4501                	li	a0,0
    4f1e:	00000097          	auipc	ra,0x0
    4f22:	5b2080e7          	jalr	1458(ra) # 54d0 <exit>
  }

  close(fds[1]);
    4f26:	fcc42503          	lw	a0,-52(s0)
    4f2a:	00000097          	auipc	ra,0x0
    4f2e:	5ce080e7          	jalr	1486(ra) # 54f8 <close>

  int n = 0;
    4f32:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    4f34:	4605                	li	a2,1
    4f36:	fc740593          	addi	a1,s0,-57
    4f3a:	fc842503          	lw	a0,-56(s0)
    4f3e:	00000097          	auipc	ra,0x0
    4f42:	5aa080e7          	jalr	1450(ra) # 54e8 <read>
    if(cc < 0){
    4f46:	00054563          	bltz	a0,4f50 <countfree+0xf2>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    4f4a:	c105                	beqz	a0,4f6a <countfree+0x10c>
      break;
    n += 1;
    4f4c:	2485                	addiw	s1,s1,1
  while(1){
    4f4e:	b7dd                	j	4f34 <countfree+0xd6>
      printf("read() failed in countfree()\n");
    4f50:	00003517          	auipc	a0,0x3
    4f54:	c8050513          	addi	a0,a0,-896 # 7bd0 <malloc+0x22ca>
    4f58:	00001097          	auipc	ra,0x1
    4f5c:	8f0080e7          	jalr	-1808(ra) # 5848 <printf>
      exit(1);
    4f60:	4505                	li	a0,1
    4f62:	00000097          	auipc	ra,0x0
    4f66:	56e080e7          	jalr	1390(ra) # 54d0 <exit>
  }

  close(fds[0]);
    4f6a:	fc842503          	lw	a0,-56(s0)
    4f6e:	00000097          	auipc	ra,0x0
    4f72:	58a080e7          	jalr	1418(ra) # 54f8 <close>
  wait((int*)0);
    4f76:	4501                	li	a0,0
    4f78:	00000097          	auipc	ra,0x0
    4f7c:	560080e7          	jalr	1376(ra) # 54d8 <wait>
  
  return n;
}
    4f80:	8526                	mv	a0,s1
    4f82:	70e2                	ld	ra,56(sp)
    4f84:	7442                	ld	s0,48(sp)
    4f86:	74a2                	ld	s1,40(sp)
    4f88:	7902                	ld	s2,32(sp)
    4f8a:	69e2                	ld	s3,24(sp)
    4f8c:	6121                	addi	sp,sp,64
    4f8e:	8082                	ret

0000000000004f90 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4f90:	7179                	addi	sp,sp,-48
    4f92:	f406                	sd	ra,40(sp)
    4f94:	f022                	sd	s0,32(sp)
    4f96:	ec26                	sd	s1,24(sp)
    4f98:	e84a                	sd	s2,16(sp)
    4f9a:	1800                	addi	s0,sp,48
    4f9c:	84aa                	mv	s1,a0
    4f9e:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4fa0:	00003517          	auipc	a0,0x3
    4fa4:	c5050513          	addi	a0,a0,-944 # 7bf0 <malloc+0x22ea>
    4fa8:	00001097          	auipc	ra,0x1
    4fac:	8a0080e7          	jalr	-1888(ra) # 5848 <printf>
  if((pid = fork()) < 0) {
    4fb0:	00000097          	auipc	ra,0x0
    4fb4:	518080e7          	jalr	1304(ra) # 54c8 <fork>
    4fb8:	02054e63          	bltz	a0,4ff4 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4fbc:	c929                	beqz	a0,500e <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4fbe:	fdc40513          	addi	a0,s0,-36
    4fc2:	00000097          	auipc	ra,0x0
    4fc6:	516080e7          	jalr	1302(ra) # 54d8 <wait>
    if(xstatus != 0) 
    4fca:	fdc42783          	lw	a5,-36(s0)
    4fce:	c7b9                	beqz	a5,501c <run+0x8c>
      printf("FAILED\n");
    4fd0:	00003517          	auipc	a0,0x3
    4fd4:	c4850513          	addi	a0,a0,-952 # 7c18 <malloc+0x2312>
    4fd8:	00001097          	auipc	ra,0x1
    4fdc:	870080e7          	jalr	-1936(ra) # 5848 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    4fe0:	fdc42503          	lw	a0,-36(s0)
  }
}
    4fe4:	00153513          	seqz	a0,a0
    4fe8:	70a2                	ld	ra,40(sp)
    4fea:	7402                	ld	s0,32(sp)
    4fec:	64e2                	ld	s1,24(sp)
    4fee:	6942                	ld	s2,16(sp)
    4ff0:	6145                	addi	sp,sp,48
    4ff2:	8082                	ret
    printf("runtest: fork error\n");
    4ff4:	00003517          	auipc	a0,0x3
    4ff8:	c0c50513          	addi	a0,a0,-1012 # 7c00 <malloc+0x22fa>
    4ffc:	00001097          	auipc	ra,0x1
    5000:	84c080e7          	jalr	-1972(ra) # 5848 <printf>
    exit(1);
    5004:	4505                	li	a0,1
    5006:	00000097          	auipc	ra,0x0
    500a:	4ca080e7          	jalr	1226(ra) # 54d0 <exit>
    f(s);
    500e:	854a                	mv	a0,s2
    5010:	9482                	jalr	s1
    exit(0);
    5012:	4501                	li	a0,0
    5014:	00000097          	auipc	ra,0x0
    5018:	4bc080e7          	jalr	1212(ra) # 54d0 <exit>
      printf("OK\n");
    501c:	00003517          	auipc	a0,0x3
    5020:	c0450513          	addi	a0,a0,-1020 # 7c20 <malloc+0x231a>
    5024:	00001097          	auipc	ra,0x1
    5028:	824080e7          	jalr	-2012(ra) # 5848 <printf>
    502c:	bf55                	j	4fe0 <run+0x50>

000000000000502e <main>:

int
main(int argc, char *argv[])
{
    502e:	c2010113          	addi	sp,sp,-992
    5032:	3c113c23          	sd	ra,984(sp)
    5036:	3c813823          	sd	s0,976(sp)
    503a:	3c913423          	sd	s1,968(sp)
    503e:	3d213023          	sd	s2,960(sp)
    5042:	3b313c23          	sd	s3,952(sp)
    5046:	3b413823          	sd	s4,944(sp)
    504a:	3b513423          	sd	s5,936(sp)
    504e:	3b613023          	sd	s6,928(sp)
    5052:	1780                	addi	s0,sp,992
    5054:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5056:	4789                	li	a5,2
    5058:	08f50763          	beq	a0,a5,50e6 <main+0xb8>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    505c:	4785                	li	a5,1
  char *justone = 0;
    505e:	4901                	li	s2,0
  } else if(argc > 1){
    5060:	0ca7c163          	blt	a5,a0,5122 <main+0xf4>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    5064:	00003797          	auipc	a5,0x3
    5068:	cd478793          	addi	a5,a5,-812 # 7d38 <malloc+0x2432>
    506c:	c2040713          	addi	a4,s0,-992
    5070:	00003817          	auipc	a6,0x3
    5074:	06880813          	addi	a6,a6,104 # 80d8 <malloc+0x27d2>
    5078:	6388                	ld	a0,0(a5)
    507a:	678c                	ld	a1,8(a5)
    507c:	6b90                	ld	a2,16(a5)
    507e:	6f94                	ld	a3,24(a5)
    5080:	e308                	sd	a0,0(a4)
    5082:	e70c                	sd	a1,8(a4)
    5084:	eb10                	sd	a2,16(a4)
    5086:	ef14                	sd	a3,24(a4)
    5088:	02078793          	addi	a5,a5,32
    508c:	02070713          	addi	a4,a4,32
    5090:	ff0794e3          	bne	a5,a6,5078 <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    5094:	00003517          	auipc	a0,0x3
    5098:	c4450513          	addi	a0,a0,-956 # 7cd8 <malloc+0x23d2>
    509c:	00000097          	auipc	ra,0x0
    50a0:	7ac080e7          	jalr	1964(ra) # 5848 <printf>
  int free0 = countfree();
    50a4:	00000097          	auipc	ra,0x0
    50a8:	dba080e7          	jalr	-582(ra) # 4e5e <countfree>
    50ac:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    50ae:	c2843503          	ld	a0,-984(s0)
    50b2:	c2040493          	addi	s1,s0,-992
  int fail = 0;
    50b6:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    50b8:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    50ba:	e55d                	bnez	a0,5168 <main+0x13a>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    50bc:	00000097          	auipc	ra,0x0
    50c0:	da2080e7          	jalr	-606(ra) # 4e5e <countfree>
    50c4:	85aa                	mv	a1,a0
    50c6:	0f455163          	bge	a0,s4,51a8 <main+0x17a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    50ca:	8652                	mv	a2,s4
    50cc:	00003517          	auipc	a0,0x3
    50d0:	bc450513          	addi	a0,a0,-1084 # 7c90 <malloc+0x238a>
    50d4:	00000097          	auipc	ra,0x0
    50d8:	774080e7          	jalr	1908(ra) # 5848 <printf>
    exit(1);
    50dc:	4505                	li	a0,1
    50de:	00000097          	auipc	ra,0x0
    50e2:	3f2080e7          	jalr	1010(ra) # 54d0 <exit>
    50e6:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    50e8:	00003597          	auipc	a1,0x3
    50ec:	b4058593          	addi	a1,a1,-1216 # 7c28 <malloc+0x2322>
    50f0:	6488                	ld	a0,8(s1)
    50f2:	00000097          	auipc	ra,0x0
    50f6:	184080e7          	jalr	388(ra) # 5276 <strcmp>
    50fa:	10050563          	beqz	a0,5204 <main+0x1d6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    50fe:	00003597          	auipc	a1,0x3
    5102:	c1258593          	addi	a1,a1,-1006 # 7d10 <malloc+0x240a>
    5106:	6488                	ld	a0,8(s1)
    5108:	00000097          	auipc	ra,0x0
    510c:	16e080e7          	jalr	366(ra) # 5276 <strcmp>
    5110:	c97d                	beqz	a0,5206 <main+0x1d8>
  } else if(argc == 2 && argv[1][0] != '-'){
    5112:	0084b903          	ld	s2,8(s1)
    5116:	00094703          	lbu	a4,0(s2)
    511a:	02d00793          	li	a5,45
    511e:	f4f713e3          	bne	a4,a5,5064 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    5122:	00003517          	auipc	a0,0x3
    5126:	b0e50513          	addi	a0,a0,-1266 # 7c30 <malloc+0x232a>
    512a:	00000097          	auipc	ra,0x0
    512e:	71e080e7          	jalr	1822(ra) # 5848 <printf>
    exit(1);
    5132:	4505                	li	a0,1
    5134:	00000097          	auipc	ra,0x0
    5138:	39c080e7          	jalr	924(ra) # 54d0 <exit>
          exit(1);
    513c:	4505                	li	a0,1
    513e:	00000097          	auipc	ra,0x0
    5142:	392080e7          	jalr	914(ra) # 54d0 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5146:	40a905bb          	subw	a1,s2,a0
    514a:	855a                	mv	a0,s6
    514c:	00000097          	auipc	ra,0x0
    5150:	6fc080e7          	jalr	1788(ra) # 5848 <printf>
        if(continuous != 2)
    5154:	09498463          	beq	s3,s4,51dc <main+0x1ae>
          exit(1);
    5158:	4505                	li	a0,1
    515a:	00000097          	auipc	ra,0x0
    515e:	376080e7          	jalr	886(ra) # 54d0 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    5162:	04c1                	addi	s1,s1,16
    5164:	6488                	ld	a0,8(s1)
    5166:	c115                	beqz	a0,518a <main+0x15c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5168:	00090863          	beqz	s2,5178 <main+0x14a>
    516c:	85ca                	mv	a1,s2
    516e:	00000097          	auipc	ra,0x0
    5172:	108080e7          	jalr	264(ra) # 5276 <strcmp>
    5176:	f575                	bnez	a0,5162 <main+0x134>
      if(!run(t->f, t->s))
    5178:	648c                	ld	a1,8(s1)
    517a:	6088                	ld	a0,0(s1)
    517c:	00000097          	auipc	ra,0x0
    5180:	e14080e7          	jalr	-492(ra) # 4f90 <run>
    5184:	fd79                	bnez	a0,5162 <main+0x134>
        fail = 1;
    5186:	89d6                	mv	s3,s5
    5188:	bfe9                	j	5162 <main+0x134>
  if(fail){
    518a:	f20989e3          	beqz	s3,50bc <main+0x8e>
    printf("SOME TESTS FAILED\n");
    518e:	00003517          	auipc	a0,0x3
    5192:	aea50513          	addi	a0,a0,-1302 # 7c78 <malloc+0x2372>
    5196:	00000097          	auipc	ra,0x0
    519a:	6b2080e7          	jalr	1714(ra) # 5848 <printf>
    exit(1);
    519e:	4505                	li	a0,1
    51a0:	00000097          	auipc	ra,0x0
    51a4:	330080e7          	jalr	816(ra) # 54d0 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    51a8:	00003517          	auipc	a0,0x3
    51ac:	b1850513          	addi	a0,a0,-1256 # 7cc0 <malloc+0x23ba>
    51b0:	00000097          	auipc	ra,0x0
    51b4:	698080e7          	jalr	1688(ra) # 5848 <printf>
    exit(0);
    51b8:	4501                	li	a0,0
    51ba:	00000097          	auipc	ra,0x0
    51be:	316080e7          	jalr	790(ra) # 54d0 <exit>
        printf("SOME TESTS FAILED\n");
    51c2:	8556                	mv	a0,s5
    51c4:	00000097          	auipc	ra,0x0
    51c8:	684080e7          	jalr	1668(ra) # 5848 <printf>
        if(continuous != 2)
    51cc:	f74998e3          	bne	s3,s4,513c <main+0x10e>
      int free1 = countfree();
    51d0:	00000097          	auipc	ra,0x0
    51d4:	c8e080e7          	jalr	-882(ra) # 4e5e <countfree>
      if(free1 < free0){
    51d8:	f72547e3          	blt	a0,s2,5146 <main+0x118>
      int free0 = countfree();
    51dc:	00000097          	auipc	ra,0x0
    51e0:	c82080e7          	jalr	-894(ra) # 4e5e <countfree>
    51e4:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    51e6:	c2843583          	ld	a1,-984(s0)
    51ea:	d1fd                	beqz	a1,51d0 <main+0x1a2>
    51ec:	c2040493          	addi	s1,s0,-992
        if(!run(t->f, t->s)){
    51f0:	6088                	ld	a0,0(s1)
    51f2:	00000097          	auipc	ra,0x0
    51f6:	d9e080e7          	jalr	-610(ra) # 4f90 <run>
    51fa:	d561                	beqz	a0,51c2 <main+0x194>
      for (struct test *t = tests; t->s != 0; t++) {
    51fc:	04c1                	addi	s1,s1,16
    51fe:	648c                	ld	a1,8(s1)
    5200:	f9e5                	bnez	a1,51f0 <main+0x1c2>
    5202:	b7f9                	j	51d0 <main+0x1a2>
    continuous = 1;
    5204:	4985                	li	s3,1
  } tests[] = {
    5206:	00003797          	auipc	a5,0x3
    520a:	b3278793          	addi	a5,a5,-1230 # 7d38 <malloc+0x2432>
    520e:	c2040713          	addi	a4,s0,-992
    5212:	00003817          	auipc	a6,0x3
    5216:	ec680813          	addi	a6,a6,-314 # 80d8 <malloc+0x27d2>
    521a:	6388                	ld	a0,0(a5)
    521c:	678c                	ld	a1,8(a5)
    521e:	6b90                	ld	a2,16(a5)
    5220:	6f94                	ld	a3,24(a5)
    5222:	e308                	sd	a0,0(a4)
    5224:	e70c                	sd	a1,8(a4)
    5226:	eb10                	sd	a2,16(a4)
    5228:	ef14                	sd	a3,24(a4)
    522a:	02078793          	addi	a5,a5,32
    522e:	02070713          	addi	a4,a4,32
    5232:	ff0794e3          	bne	a5,a6,521a <main+0x1ec>
    printf("continuous usertests starting\n");
    5236:	00003517          	auipc	a0,0x3
    523a:	aba50513          	addi	a0,a0,-1350 # 7cf0 <malloc+0x23ea>
    523e:	00000097          	auipc	ra,0x0
    5242:	60a080e7          	jalr	1546(ra) # 5848 <printf>
        printf("SOME TESTS FAILED\n");
    5246:	00003a97          	auipc	s5,0x3
    524a:	a32a8a93          	addi	s5,s5,-1486 # 7c78 <malloc+0x2372>
        if(continuous != 2)
    524e:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5250:	00003b17          	auipc	s6,0x3
    5254:	a08b0b13          	addi	s6,s6,-1528 # 7c58 <malloc+0x2352>
    5258:	b751                	j	51dc <main+0x1ae>

000000000000525a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    525a:	1141                	addi	sp,sp,-16
    525c:	e422                	sd	s0,8(sp)
    525e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5260:	87aa                	mv	a5,a0
    5262:	0585                	addi	a1,a1,1
    5264:	0785                	addi	a5,a5,1
    5266:	fff5c703          	lbu	a4,-1(a1)
    526a:	fee78fa3          	sb	a4,-1(a5)
    526e:	fb75                	bnez	a4,5262 <strcpy+0x8>
    ;
  return os;
}
    5270:	6422                	ld	s0,8(sp)
    5272:	0141                	addi	sp,sp,16
    5274:	8082                	ret

0000000000005276 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5276:	1141                	addi	sp,sp,-16
    5278:	e422                	sd	s0,8(sp)
    527a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    527c:	00054783          	lbu	a5,0(a0)
    5280:	cb91                	beqz	a5,5294 <strcmp+0x1e>
    5282:	0005c703          	lbu	a4,0(a1)
    5286:	00f71763          	bne	a4,a5,5294 <strcmp+0x1e>
    p++, q++;
    528a:	0505                	addi	a0,a0,1
    528c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    528e:	00054783          	lbu	a5,0(a0)
    5292:	fbe5                	bnez	a5,5282 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5294:	0005c503          	lbu	a0,0(a1)
}
    5298:	40a7853b          	subw	a0,a5,a0
    529c:	6422                	ld	s0,8(sp)
    529e:	0141                	addi	sp,sp,16
    52a0:	8082                	ret

00000000000052a2 <strlen>:

uint
strlen(const char *s)
{
    52a2:	1141                	addi	sp,sp,-16
    52a4:	e422                	sd	s0,8(sp)
    52a6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    52a8:	00054783          	lbu	a5,0(a0)
    52ac:	cf91                	beqz	a5,52c8 <strlen+0x26>
    52ae:	0505                	addi	a0,a0,1
    52b0:	87aa                	mv	a5,a0
    52b2:	4685                	li	a3,1
    52b4:	9e89                	subw	a3,a3,a0
    52b6:	00f6853b          	addw	a0,a3,a5
    52ba:	0785                	addi	a5,a5,1
    52bc:	fff7c703          	lbu	a4,-1(a5)
    52c0:	fb7d                	bnez	a4,52b6 <strlen+0x14>
    ;
  return n;
}
    52c2:	6422                	ld	s0,8(sp)
    52c4:	0141                	addi	sp,sp,16
    52c6:	8082                	ret
  for(n = 0; s[n]; n++)
    52c8:	4501                	li	a0,0
    52ca:	bfe5                	j	52c2 <strlen+0x20>

00000000000052cc <memset>:

void*
memset(void *dst, int c, uint n)
{
    52cc:	1141                	addi	sp,sp,-16
    52ce:	e422                	sd	s0,8(sp)
    52d0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    52d2:	ce09                	beqz	a2,52ec <memset+0x20>
    52d4:	87aa                	mv	a5,a0
    52d6:	fff6071b          	addiw	a4,a2,-1
    52da:	1702                	slli	a4,a4,0x20
    52dc:	9301                	srli	a4,a4,0x20
    52de:	0705                	addi	a4,a4,1
    52e0:	972a                	add	a4,a4,a0
    cdst[i] = c;
    52e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    52e6:	0785                	addi	a5,a5,1
    52e8:	fee79de3          	bne	a5,a4,52e2 <memset+0x16>
  }
  return dst;
}
    52ec:	6422                	ld	s0,8(sp)
    52ee:	0141                	addi	sp,sp,16
    52f0:	8082                	ret

00000000000052f2 <strchr>:

char*
strchr(const char *s, char c)
{
    52f2:	1141                	addi	sp,sp,-16
    52f4:	e422                	sd	s0,8(sp)
    52f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
    52f8:	00054783          	lbu	a5,0(a0)
    52fc:	cb99                	beqz	a5,5312 <strchr+0x20>
    if(*s == c)
    52fe:	00f58763          	beq	a1,a5,530c <strchr+0x1a>
  for(; *s; s++)
    5302:	0505                	addi	a0,a0,1
    5304:	00054783          	lbu	a5,0(a0)
    5308:	fbfd                	bnez	a5,52fe <strchr+0xc>
      return (char*)s;
  return 0;
    530a:	4501                	li	a0,0
}
    530c:	6422                	ld	s0,8(sp)
    530e:	0141                	addi	sp,sp,16
    5310:	8082                	ret
  return 0;
    5312:	4501                	li	a0,0
    5314:	bfe5                	j	530c <strchr+0x1a>

0000000000005316 <gets>:

char*
gets(char *buf, int max)
{
    5316:	711d                	addi	sp,sp,-96
    5318:	ec86                	sd	ra,88(sp)
    531a:	e8a2                	sd	s0,80(sp)
    531c:	e4a6                	sd	s1,72(sp)
    531e:	e0ca                	sd	s2,64(sp)
    5320:	fc4e                	sd	s3,56(sp)
    5322:	f852                	sd	s4,48(sp)
    5324:	f456                	sd	s5,40(sp)
    5326:	f05a                	sd	s6,32(sp)
    5328:	ec5e                	sd	s7,24(sp)
    532a:	1080                	addi	s0,sp,96
    532c:	8baa                	mv	s7,a0
    532e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5330:	892a                	mv	s2,a0
    5332:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5334:	4aa9                	li	s5,10
    5336:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5338:	89a6                	mv	s3,s1
    533a:	2485                	addiw	s1,s1,1
    533c:	0344d863          	bge	s1,s4,536c <gets+0x56>
    cc = read(0, &c, 1);
    5340:	4605                	li	a2,1
    5342:	faf40593          	addi	a1,s0,-81
    5346:	4501                	li	a0,0
    5348:	00000097          	auipc	ra,0x0
    534c:	1a0080e7          	jalr	416(ra) # 54e8 <read>
    if(cc < 1)
    5350:	00a05e63          	blez	a0,536c <gets+0x56>
    buf[i++] = c;
    5354:	faf44783          	lbu	a5,-81(s0)
    5358:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    535c:	01578763          	beq	a5,s5,536a <gets+0x54>
    5360:	0905                	addi	s2,s2,1
    5362:	fd679be3          	bne	a5,s6,5338 <gets+0x22>
  for(i=0; i+1 < max; ){
    5366:	89a6                	mv	s3,s1
    5368:	a011                	j	536c <gets+0x56>
    536a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    536c:	99de                	add	s3,s3,s7
    536e:	00098023          	sb	zero,0(s3)
  return buf;
}
    5372:	855e                	mv	a0,s7
    5374:	60e6                	ld	ra,88(sp)
    5376:	6446                	ld	s0,80(sp)
    5378:	64a6                	ld	s1,72(sp)
    537a:	6906                	ld	s2,64(sp)
    537c:	79e2                	ld	s3,56(sp)
    537e:	7a42                	ld	s4,48(sp)
    5380:	7aa2                	ld	s5,40(sp)
    5382:	7b02                	ld	s6,32(sp)
    5384:	6be2                	ld	s7,24(sp)
    5386:	6125                	addi	sp,sp,96
    5388:	8082                	ret

000000000000538a <stat>:

int
stat(const char *n, struct stat *st)
{
    538a:	1101                	addi	sp,sp,-32
    538c:	ec06                	sd	ra,24(sp)
    538e:	e822                	sd	s0,16(sp)
    5390:	e426                	sd	s1,8(sp)
    5392:	e04a                	sd	s2,0(sp)
    5394:	1000                	addi	s0,sp,32
    5396:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5398:	4581                	li	a1,0
    539a:	00000097          	auipc	ra,0x0
    539e:	176080e7          	jalr	374(ra) # 5510 <open>
  if(fd < 0)
    53a2:	02054563          	bltz	a0,53cc <stat+0x42>
    53a6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    53a8:	85ca                	mv	a1,s2
    53aa:	00000097          	auipc	ra,0x0
    53ae:	17e080e7          	jalr	382(ra) # 5528 <fstat>
    53b2:	892a                	mv	s2,a0
  close(fd);
    53b4:	8526                	mv	a0,s1
    53b6:	00000097          	auipc	ra,0x0
    53ba:	142080e7          	jalr	322(ra) # 54f8 <close>
  return r;
}
    53be:	854a                	mv	a0,s2
    53c0:	60e2                	ld	ra,24(sp)
    53c2:	6442                	ld	s0,16(sp)
    53c4:	64a2                	ld	s1,8(sp)
    53c6:	6902                	ld	s2,0(sp)
    53c8:	6105                	addi	sp,sp,32
    53ca:	8082                	ret
    return -1;
    53cc:	597d                	li	s2,-1
    53ce:	bfc5                	j	53be <stat+0x34>

00000000000053d0 <atoi>:

int
atoi(const char *s)
{
    53d0:	1141                	addi	sp,sp,-16
    53d2:	e422                	sd	s0,8(sp)
    53d4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    53d6:	00054603          	lbu	a2,0(a0)
    53da:	fd06079b          	addiw	a5,a2,-48
    53de:	0ff7f793          	andi	a5,a5,255
    53e2:	4725                	li	a4,9
    53e4:	02f76963          	bltu	a4,a5,5416 <atoi+0x46>
    53e8:	86aa                	mv	a3,a0
  n = 0;
    53ea:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    53ec:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    53ee:	0685                	addi	a3,a3,1
    53f0:	0025179b          	slliw	a5,a0,0x2
    53f4:	9fa9                	addw	a5,a5,a0
    53f6:	0017979b          	slliw	a5,a5,0x1
    53fa:	9fb1                	addw	a5,a5,a2
    53fc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5400:	0006c603          	lbu	a2,0(a3) # 1000 <bigdir+0x8a>
    5404:	fd06071b          	addiw	a4,a2,-48
    5408:	0ff77713          	andi	a4,a4,255
    540c:	fee5f1e3          	bgeu	a1,a4,53ee <atoi+0x1e>
  return n;
}
    5410:	6422                	ld	s0,8(sp)
    5412:	0141                	addi	sp,sp,16
    5414:	8082                	ret
  n = 0;
    5416:	4501                	li	a0,0
    5418:	bfe5                	j	5410 <atoi+0x40>

000000000000541a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    541a:	1141                	addi	sp,sp,-16
    541c:	e422                	sd	s0,8(sp)
    541e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5420:	02b57663          	bgeu	a0,a1,544c <memmove+0x32>
    while(n-- > 0)
    5424:	02c05163          	blez	a2,5446 <memmove+0x2c>
    5428:	fff6079b          	addiw	a5,a2,-1
    542c:	1782                	slli	a5,a5,0x20
    542e:	9381                	srli	a5,a5,0x20
    5430:	0785                	addi	a5,a5,1
    5432:	97aa                	add	a5,a5,a0
  dst = vdst;
    5434:	872a                	mv	a4,a0
      *dst++ = *src++;
    5436:	0585                	addi	a1,a1,1
    5438:	0705                	addi	a4,a4,1
    543a:	fff5c683          	lbu	a3,-1(a1)
    543e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5442:	fee79ae3          	bne	a5,a4,5436 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5446:	6422                	ld	s0,8(sp)
    5448:	0141                	addi	sp,sp,16
    544a:	8082                	ret
    dst += n;
    544c:	00c50733          	add	a4,a0,a2
    src += n;
    5450:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5452:	fec05ae3          	blez	a2,5446 <memmove+0x2c>
    5456:	fff6079b          	addiw	a5,a2,-1
    545a:	1782                	slli	a5,a5,0x20
    545c:	9381                	srli	a5,a5,0x20
    545e:	fff7c793          	not	a5,a5
    5462:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5464:	15fd                	addi	a1,a1,-1
    5466:	177d                	addi	a4,a4,-1
    5468:	0005c683          	lbu	a3,0(a1)
    546c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5470:	fee79ae3          	bne	a5,a4,5464 <memmove+0x4a>
    5474:	bfc9                	j	5446 <memmove+0x2c>

0000000000005476 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5476:	1141                	addi	sp,sp,-16
    5478:	e422                	sd	s0,8(sp)
    547a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    547c:	ca05                	beqz	a2,54ac <memcmp+0x36>
    547e:	fff6069b          	addiw	a3,a2,-1
    5482:	1682                	slli	a3,a3,0x20
    5484:	9281                	srli	a3,a3,0x20
    5486:	0685                	addi	a3,a3,1
    5488:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    548a:	00054783          	lbu	a5,0(a0)
    548e:	0005c703          	lbu	a4,0(a1)
    5492:	00e79863          	bne	a5,a4,54a2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5496:	0505                	addi	a0,a0,1
    p2++;
    5498:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    549a:	fed518e3          	bne	a0,a3,548a <memcmp+0x14>
  }
  return 0;
    549e:	4501                	li	a0,0
    54a0:	a019                	j	54a6 <memcmp+0x30>
      return *p1 - *p2;
    54a2:	40e7853b          	subw	a0,a5,a4
}
    54a6:	6422                	ld	s0,8(sp)
    54a8:	0141                	addi	sp,sp,16
    54aa:	8082                	ret
  return 0;
    54ac:	4501                	li	a0,0
    54ae:	bfe5                	j	54a6 <memcmp+0x30>

00000000000054b0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    54b0:	1141                	addi	sp,sp,-16
    54b2:	e406                	sd	ra,8(sp)
    54b4:	e022                	sd	s0,0(sp)
    54b6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    54b8:	00000097          	auipc	ra,0x0
    54bc:	f62080e7          	jalr	-158(ra) # 541a <memmove>
}
    54c0:	60a2                	ld	ra,8(sp)
    54c2:	6402                	ld	s0,0(sp)
    54c4:	0141                	addi	sp,sp,16
    54c6:	8082                	ret

00000000000054c8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    54c8:	4885                	li	a7,1
 ecall
    54ca:	00000073          	ecall
 ret
    54ce:	8082                	ret

00000000000054d0 <exit>:
.global exit
exit:
 li a7, SYS_exit
    54d0:	4889                	li	a7,2
 ecall
    54d2:	00000073          	ecall
 ret
    54d6:	8082                	ret

00000000000054d8 <wait>:
.global wait
wait:
 li a7, SYS_wait
    54d8:	488d                	li	a7,3
 ecall
    54da:	00000073          	ecall
 ret
    54de:	8082                	ret

00000000000054e0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    54e0:	4891                	li	a7,4
 ecall
    54e2:	00000073          	ecall
 ret
    54e6:	8082                	ret

00000000000054e8 <read>:
.global read
read:
 li a7, SYS_read
    54e8:	4895                	li	a7,5
 ecall
    54ea:	00000073          	ecall
 ret
    54ee:	8082                	ret

00000000000054f0 <write>:
.global write
write:
 li a7, SYS_write
    54f0:	48c1                	li	a7,16
 ecall
    54f2:	00000073          	ecall
 ret
    54f6:	8082                	ret

00000000000054f8 <close>:
.global close
close:
 li a7, SYS_close
    54f8:	48d5                	li	a7,21
 ecall
    54fa:	00000073          	ecall
 ret
    54fe:	8082                	ret

0000000000005500 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5500:	4899                	li	a7,6
 ecall
    5502:	00000073          	ecall
 ret
    5506:	8082                	ret

0000000000005508 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5508:	489d                	li	a7,7
 ecall
    550a:	00000073          	ecall
 ret
    550e:	8082                	ret

0000000000005510 <open>:
.global open
open:
 li a7, SYS_open
    5510:	48bd                	li	a7,15
 ecall
    5512:	00000073          	ecall
 ret
    5516:	8082                	ret

0000000000005518 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5518:	48c5                	li	a7,17
 ecall
    551a:	00000073          	ecall
 ret
    551e:	8082                	ret

0000000000005520 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5520:	48c9                	li	a7,18
 ecall
    5522:	00000073          	ecall
 ret
    5526:	8082                	ret

0000000000005528 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5528:	48a1                	li	a7,8
 ecall
    552a:	00000073          	ecall
 ret
    552e:	8082                	ret

0000000000005530 <link>:
.global link
link:
 li a7, SYS_link
    5530:	48cd                	li	a7,19
 ecall
    5532:	00000073          	ecall
 ret
    5536:	8082                	ret

0000000000005538 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5538:	48d1                	li	a7,20
 ecall
    553a:	00000073          	ecall
 ret
    553e:	8082                	ret

0000000000005540 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5540:	48a5                	li	a7,9
 ecall
    5542:	00000073          	ecall
 ret
    5546:	8082                	ret

0000000000005548 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5548:	48a9                	li	a7,10
 ecall
    554a:	00000073          	ecall
 ret
    554e:	8082                	ret

0000000000005550 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5550:	48ad                	li	a7,11
 ecall
    5552:	00000073          	ecall
 ret
    5556:	8082                	ret

0000000000005558 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5558:	48b1                	li	a7,12
 ecall
    555a:	00000073          	ecall
 ret
    555e:	8082                	ret

0000000000005560 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5560:	48b5                	li	a7,13
 ecall
    5562:	00000073          	ecall
 ret
    5566:	8082                	ret

0000000000005568 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5568:	48b9                	li	a7,14
 ecall
    556a:	00000073          	ecall
 ret
    556e:	8082                	ret

0000000000005570 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5570:	1101                	addi	sp,sp,-32
    5572:	ec06                	sd	ra,24(sp)
    5574:	e822                	sd	s0,16(sp)
    5576:	1000                	addi	s0,sp,32
    5578:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    557c:	4605                	li	a2,1
    557e:	fef40593          	addi	a1,s0,-17
    5582:	00000097          	auipc	ra,0x0
    5586:	f6e080e7          	jalr	-146(ra) # 54f0 <write>
}
    558a:	60e2                	ld	ra,24(sp)
    558c:	6442                	ld	s0,16(sp)
    558e:	6105                	addi	sp,sp,32
    5590:	8082                	ret

0000000000005592 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5592:	7139                	addi	sp,sp,-64
    5594:	fc06                	sd	ra,56(sp)
    5596:	f822                	sd	s0,48(sp)
    5598:	f426                	sd	s1,40(sp)
    559a:	f04a                	sd	s2,32(sp)
    559c:	ec4e                	sd	s3,24(sp)
    559e:	0080                	addi	s0,sp,64
    55a0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    55a2:	c299                	beqz	a3,55a8 <printint+0x16>
    55a4:	0805c863          	bltz	a1,5634 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    55a8:	2581                	sext.w	a1,a1
  neg = 0;
    55aa:	4881                	li	a7,0
    55ac:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    55b0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    55b2:	2601                	sext.w	a2,a2
    55b4:	00003517          	auipc	a0,0x3
    55b8:	b2c50513          	addi	a0,a0,-1236 # 80e0 <digits>
    55bc:	883a                	mv	a6,a4
    55be:	2705                	addiw	a4,a4,1
    55c0:	02c5f7bb          	remuw	a5,a1,a2
    55c4:	1782                	slli	a5,a5,0x20
    55c6:	9381                	srli	a5,a5,0x20
    55c8:	97aa                	add	a5,a5,a0
    55ca:	0007c783          	lbu	a5,0(a5)
    55ce:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    55d2:	0005879b          	sext.w	a5,a1
    55d6:	02c5d5bb          	divuw	a1,a1,a2
    55da:	0685                	addi	a3,a3,1
    55dc:	fec7f0e3          	bgeu	a5,a2,55bc <printint+0x2a>
  if(neg)
    55e0:	00088b63          	beqz	a7,55f6 <printint+0x64>
    buf[i++] = '-';
    55e4:	fd040793          	addi	a5,s0,-48
    55e8:	973e                	add	a4,a4,a5
    55ea:	02d00793          	li	a5,45
    55ee:	fef70823          	sb	a5,-16(a4)
    55f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    55f6:	02e05863          	blez	a4,5626 <printint+0x94>
    55fa:	fc040793          	addi	a5,s0,-64
    55fe:	00e78933          	add	s2,a5,a4
    5602:	fff78993          	addi	s3,a5,-1
    5606:	99ba                	add	s3,s3,a4
    5608:	377d                	addiw	a4,a4,-1
    560a:	1702                	slli	a4,a4,0x20
    560c:	9301                	srli	a4,a4,0x20
    560e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5612:	fff94583          	lbu	a1,-1(s2)
    5616:	8526                	mv	a0,s1
    5618:	00000097          	auipc	ra,0x0
    561c:	f58080e7          	jalr	-168(ra) # 5570 <putc>
  while(--i >= 0)
    5620:	197d                	addi	s2,s2,-1
    5622:	ff3918e3          	bne	s2,s3,5612 <printint+0x80>
}
    5626:	70e2                	ld	ra,56(sp)
    5628:	7442                	ld	s0,48(sp)
    562a:	74a2                	ld	s1,40(sp)
    562c:	7902                	ld	s2,32(sp)
    562e:	69e2                	ld	s3,24(sp)
    5630:	6121                	addi	sp,sp,64
    5632:	8082                	ret
    x = -xx;
    5634:	40b005bb          	negw	a1,a1
    neg = 1;
    5638:	4885                	li	a7,1
    x = -xx;
    563a:	bf8d                	j	55ac <printint+0x1a>

000000000000563c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    563c:	7119                	addi	sp,sp,-128
    563e:	fc86                	sd	ra,120(sp)
    5640:	f8a2                	sd	s0,112(sp)
    5642:	f4a6                	sd	s1,104(sp)
    5644:	f0ca                	sd	s2,96(sp)
    5646:	ecce                	sd	s3,88(sp)
    5648:	e8d2                	sd	s4,80(sp)
    564a:	e4d6                	sd	s5,72(sp)
    564c:	e0da                	sd	s6,64(sp)
    564e:	fc5e                	sd	s7,56(sp)
    5650:	f862                	sd	s8,48(sp)
    5652:	f466                	sd	s9,40(sp)
    5654:	f06a                	sd	s10,32(sp)
    5656:	ec6e                	sd	s11,24(sp)
    5658:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    565a:	0005c903          	lbu	s2,0(a1)
    565e:	18090f63          	beqz	s2,57fc <vprintf+0x1c0>
    5662:	8aaa                	mv	s5,a0
    5664:	8b32                	mv	s6,a2
    5666:	00158493          	addi	s1,a1,1
  state = 0;
    566a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    566c:	02500a13          	li	s4,37
      if(c == 'd'){
    5670:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5674:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5678:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    567c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5680:	00003b97          	auipc	s7,0x3
    5684:	a60b8b93          	addi	s7,s7,-1440 # 80e0 <digits>
    5688:	a839                	j	56a6 <vprintf+0x6a>
        putc(fd, c);
    568a:	85ca                	mv	a1,s2
    568c:	8556                	mv	a0,s5
    568e:	00000097          	auipc	ra,0x0
    5692:	ee2080e7          	jalr	-286(ra) # 5570 <putc>
    5696:	a019                	j	569c <vprintf+0x60>
    } else if(state == '%'){
    5698:	01498f63          	beq	s3,s4,56b6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    569c:	0485                	addi	s1,s1,1
    569e:	fff4c903          	lbu	s2,-1(s1)
    56a2:	14090d63          	beqz	s2,57fc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    56a6:	0009079b          	sext.w	a5,s2
    if(state == 0){
    56aa:	fe0997e3          	bnez	s3,5698 <vprintf+0x5c>
      if(c == '%'){
    56ae:	fd479ee3          	bne	a5,s4,568a <vprintf+0x4e>
        state = '%';
    56b2:	89be                	mv	s3,a5
    56b4:	b7e5                	j	569c <vprintf+0x60>
      if(c == 'd'){
    56b6:	05878063          	beq	a5,s8,56f6 <vprintf+0xba>
      } else if(c == 'l') {
    56ba:	05978c63          	beq	a5,s9,5712 <vprintf+0xd6>
      } else if(c == 'x') {
    56be:	07a78863          	beq	a5,s10,572e <vprintf+0xf2>
      } else if(c == 'p') {
    56c2:	09b78463          	beq	a5,s11,574a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    56c6:	07300713          	li	a4,115
    56ca:	0ce78663          	beq	a5,a4,5796 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    56ce:	06300713          	li	a4,99
    56d2:	0ee78e63          	beq	a5,a4,57ce <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    56d6:	11478863          	beq	a5,s4,57e6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    56da:	85d2                	mv	a1,s4
    56dc:	8556                	mv	a0,s5
    56de:	00000097          	auipc	ra,0x0
    56e2:	e92080e7          	jalr	-366(ra) # 5570 <putc>
        putc(fd, c);
    56e6:	85ca                	mv	a1,s2
    56e8:	8556                	mv	a0,s5
    56ea:	00000097          	auipc	ra,0x0
    56ee:	e86080e7          	jalr	-378(ra) # 5570 <putc>
      }
      state = 0;
    56f2:	4981                	li	s3,0
    56f4:	b765                	j	569c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    56f6:	008b0913          	addi	s2,s6,8
    56fa:	4685                	li	a3,1
    56fc:	4629                	li	a2,10
    56fe:	000b2583          	lw	a1,0(s6)
    5702:	8556                	mv	a0,s5
    5704:	00000097          	auipc	ra,0x0
    5708:	e8e080e7          	jalr	-370(ra) # 5592 <printint>
    570c:	8b4a                	mv	s6,s2
      state = 0;
    570e:	4981                	li	s3,0
    5710:	b771                	j	569c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5712:	008b0913          	addi	s2,s6,8
    5716:	4681                	li	a3,0
    5718:	4629                	li	a2,10
    571a:	000b2583          	lw	a1,0(s6)
    571e:	8556                	mv	a0,s5
    5720:	00000097          	auipc	ra,0x0
    5724:	e72080e7          	jalr	-398(ra) # 5592 <printint>
    5728:	8b4a                	mv	s6,s2
      state = 0;
    572a:	4981                	li	s3,0
    572c:	bf85                	j	569c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    572e:	008b0913          	addi	s2,s6,8
    5732:	4681                	li	a3,0
    5734:	4641                	li	a2,16
    5736:	000b2583          	lw	a1,0(s6)
    573a:	8556                	mv	a0,s5
    573c:	00000097          	auipc	ra,0x0
    5740:	e56080e7          	jalr	-426(ra) # 5592 <printint>
    5744:	8b4a                	mv	s6,s2
      state = 0;
    5746:	4981                	li	s3,0
    5748:	bf91                	j	569c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    574a:	008b0793          	addi	a5,s6,8
    574e:	f8f43423          	sd	a5,-120(s0)
    5752:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5756:	03000593          	li	a1,48
    575a:	8556                	mv	a0,s5
    575c:	00000097          	auipc	ra,0x0
    5760:	e14080e7          	jalr	-492(ra) # 5570 <putc>
  putc(fd, 'x');
    5764:	85ea                	mv	a1,s10
    5766:	8556                	mv	a0,s5
    5768:	00000097          	auipc	ra,0x0
    576c:	e08080e7          	jalr	-504(ra) # 5570 <putc>
    5770:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5772:	03c9d793          	srli	a5,s3,0x3c
    5776:	97de                	add	a5,a5,s7
    5778:	0007c583          	lbu	a1,0(a5)
    577c:	8556                	mv	a0,s5
    577e:	00000097          	auipc	ra,0x0
    5782:	df2080e7          	jalr	-526(ra) # 5570 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5786:	0992                	slli	s3,s3,0x4
    5788:	397d                	addiw	s2,s2,-1
    578a:	fe0914e3          	bnez	s2,5772 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    578e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5792:	4981                	li	s3,0
    5794:	b721                	j	569c <vprintf+0x60>
        s = va_arg(ap, char*);
    5796:	008b0993          	addi	s3,s6,8
    579a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    579e:	02090163          	beqz	s2,57c0 <vprintf+0x184>
        while(*s != 0){
    57a2:	00094583          	lbu	a1,0(s2)
    57a6:	c9a1                	beqz	a1,57f6 <vprintf+0x1ba>
          putc(fd, *s);
    57a8:	8556                	mv	a0,s5
    57aa:	00000097          	auipc	ra,0x0
    57ae:	dc6080e7          	jalr	-570(ra) # 5570 <putc>
          s++;
    57b2:	0905                	addi	s2,s2,1
        while(*s != 0){
    57b4:	00094583          	lbu	a1,0(s2)
    57b8:	f9e5                	bnez	a1,57a8 <vprintf+0x16c>
        s = va_arg(ap, char*);
    57ba:	8b4e                	mv	s6,s3
      state = 0;
    57bc:	4981                	li	s3,0
    57be:	bdf9                	j	569c <vprintf+0x60>
          s = "(null)";
    57c0:	00003917          	auipc	s2,0x3
    57c4:	91890913          	addi	s2,s2,-1768 # 80d8 <malloc+0x27d2>
        while(*s != 0){
    57c8:	02800593          	li	a1,40
    57cc:	bff1                	j	57a8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    57ce:	008b0913          	addi	s2,s6,8
    57d2:	000b4583          	lbu	a1,0(s6)
    57d6:	8556                	mv	a0,s5
    57d8:	00000097          	auipc	ra,0x0
    57dc:	d98080e7          	jalr	-616(ra) # 5570 <putc>
    57e0:	8b4a                	mv	s6,s2
      state = 0;
    57e2:	4981                	li	s3,0
    57e4:	bd65                	j	569c <vprintf+0x60>
        putc(fd, c);
    57e6:	85d2                	mv	a1,s4
    57e8:	8556                	mv	a0,s5
    57ea:	00000097          	auipc	ra,0x0
    57ee:	d86080e7          	jalr	-634(ra) # 5570 <putc>
      state = 0;
    57f2:	4981                	li	s3,0
    57f4:	b565                	j	569c <vprintf+0x60>
        s = va_arg(ap, char*);
    57f6:	8b4e                	mv	s6,s3
      state = 0;
    57f8:	4981                	li	s3,0
    57fa:	b54d                	j	569c <vprintf+0x60>
    }
  }
}
    57fc:	70e6                	ld	ra,120(sp)
    57fe:	7446                	ld	s0,112(sp)
    5800:	74a6                	ld	s1,104(sp)
    5802:	7906                	ld	s2,96(sp)
    5804:	69e6                	ld	s3,88(sp)
    5806:	6a46                	ld	s4,80(sp)
    5808:	6aa6                	ld	s5,72(sp)
    580a:	6b06                	ld	s6,64(sp)
    580c:	7be2                	ld	s7,56(sp)
    580e:	7c42                	ld	s8,48(sp)
    5810:	7ca2                	ld	s9,40(sp)
    5812:	7d02                	ld	s10,32(sp)
    5814:	6de2                	ld	s11,24(sp)
    5816:	6109                	addi	sp,sp,128
    5818:	8082                	ret

000000000000581a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    581a:	715d                	addi	sp,sp,-80
    581c:	ec06                	sd	ra,24(sp)
    581e:	e822                	sd	s0,16(sp)
    5820:	1000                	addi	s0,sp,32
    5822:	e010                	sd	a2,0(s0)
    5824:	e414                	sd	a3,8(s0)
    5826:	e818                	sd	a4,16(s0)
    5828:	ec1c                	sd	a5,24(s0)
    582a:	03043023          	sd	a6,32(s0)
    582e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5832:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5836:	8622                	mv	a2,s0
    5838:	00000097          	auipc	ra,0x0
    583c:	e04080e7          	jalr	-508(ra) # 563c <vprintf>
}
    5840:	60e2                	ld	ra,24(sp)
    5842:	6442                	ld	s0,16(sp)
    5844:	6161                	addi	sp,sp,80
    5846:	8082                	ret

0000000000005848 <printf>:

void
printf(const char *fmt, ...)
{
    5848:	711d                	addi	sp,sp,-96
    584a:	ec06                	sd	ra,24(sp)
    584c:	e822                	sd	s0,16(sp)
    584e:	1000                	addi	s0,sp,32
    5850:	e40c                	sd	a1,8(s0)
    5852:	e810                	sd	a2,16(s0)
    5854:	ec14                	sd	a3,24(s0)
    5856:	f018                	sd	a4,32(s0)
    5858:	f41c                	sd	a5,40(s0)
    585a:	03043823          	sd	a6,48(s0)
    585e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5862:	00840613          	addi	a2,s0,8
    5866:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    586a:	85aa                	mv	a1,a0
    586c:	4505                	li	a0,1
    586e:	00000097          	auipc	ra,0x0
    5872:	dce080e7          	jalr	-562(ra) # 563c <vprintf>
}
    5876:	60e2                	ld	ra,24(sp)
    5878:	6442                	ld	s0,16(sp)
    587a:	6125                	addi	sp,sp,96
    587c:	8082                	ret

000000000000587e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    587e:	1141                	addi	sp,sp,-16
    5880:	e422                	sd	s0,8(sp)
    5882:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5884:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5888:	00003797          	auipc	a5,0x3
    588c:	8887b783          	ld	a5,-1912(a5) # 8110 <freep>
    5890:	a805                	j	58c0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5892:	4618                	lw	a4,8(a2)
    5894:	9db9                	addw	a1,a1,a4
    5896:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    589a:	6398                	ld	a4,0(a5)
    589c:	6318                	ld	a4,0(a4)
    589e:	fee53823          	sd	a4,-16(a0)
    58a2:	a091                	j	58e6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    58a4:	ff852703          	lw	a4,-8(a0)
    58a8:	9e39                	addw	a2,a2,a4
    58aa:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    58ac:	ff053703          	ld	a4,-16(a0)
    58b0:	e398                	sd	a4,0(a5)
    58b2:	a099                	j	58f8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    58b4:	6398                	ld	a4,0(a5)
    58b6:	00e7e463          	bltu	a5,a4,58be <free+0x40>
    58ba:	00e6ea63          	bltu	a3,a4,58ce <free+0x50>
{
    58be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    58c0:	fed7fae3          	bgeu	a5,a3,58b4 <free+0x36>
    58c4:	6398                	ld	a4,0(a5)
    58c6:	00e6e463          	bltu	a3,a4,58ce <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    58ca:	fee7eae3          	bltu	a5,a4,58be <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    58ce:	ff852583          	lw	a1,-8(a0)
    58d2:	6390                	ld	a2,0(a5)
    58d4:	02059713          	slli	a4,a1,0x20
    58d8:	9301                	srli	a4,a4,0x20
    58da:	0712                	slli	a4,a4,0x4
    58dc:	9736                	add	a4,a4,a3
    58de:	fae60ae3          	beq	a2,a4,5892 <free+0x14>
    bp->s.ptr = p->s.ptr;
    58e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    58e6:	4790                	lw	a2,8(a5)
    58e8:	02061713          	slli	a4,a2,0x20
    58ec:	9301                	srli	a4,a4,0x20
    58ee:	0712                	slli	a4,a4,0x4
    58f0:	973e                	add	a4,a4,a5
    58f2:	fae689e3          	beq	a3,a4,58a4 <free+0x26>
  } else
    p->s.ptr = bp;
    58f6:	e394                	sd	a3,0(a5)
  freep = p;
    58f8:	00003717          	auipc	a4,0x3
    58fc:	80f73c23          	sd	a5,-2024(a4) # 8110 <freep>
}
    5900:	6422                	ld	s0,8(sp)
    5902:	0141                	addi	sp,sp,16
    5904:	8082                	ret

0000000000005906 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5906:	7139                	addi	sp,sp,-64
    5908:	fc06                	sd	ra,56(sp)
    590a:	f822                	sd	s0,48(sp)
    590c:	f426                	sd	s1,40(sp)
    590e:	f04a                	sd	s2,32(sp)
    5910:	ec4e                	sd	s3,24(sp)
    5912:	e852                	sd	s4,16(sp)
    5914:	e456                	sd	s5,8(sp)
    5916:	e05a                	sd	s6,0(sp)
    5918:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    591a:	02051493          	slli	s1,a0,0x20
    591e:	9081                	srli	s1,s1,0x20
    5920:	04bd                	addi	s1,s1,15
    5922:	8091                	srli	s1,s1,0x4
    5924:	0014899b          	addiw	s3,s1,1
    5928:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    592a:	00002517          	auipc	a0,0x2
    592e:	7e653503          	ld	a0,2022(a0) # 8110 <freep>
    5932:	c515                	beqz	a0,595e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5934:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5936:	4798                	lw	a4,8(a5)
    5938:	02977f63          	bgeu	a4,s1,5976 <malloc+0x70>
    593c:	8a4e                	mv	s4,s3
    593e:	0009871b          	sext.w	a4,s3
    5942:	6685                	lui	a3,0x1
    5944:	00d77363          	bgeu	a4,a3,594a <malloc+0x44>
    5948:	6a05                	lui	s4,0x1
    594a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    594e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5952:	00002917          	auipc	s2,0x2
    5956:	7be90913          	addi	s2,s2,1982 # 8110 <freep>
  if(p == (char*)-1)
    595a:	5afd                	li	s5,-1
    595c:	a88d                	j	59ce <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    595e:	00009797          	auipc	a5,0x9
    5962:	fd278793          	addi	a5,a5,-46 # e930 <base>
    5966:	00002717          	auipc	a4,0x2
    596a:	7af73523          	sd	a5,1962(a4) # 8110 <freep>
    596e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5970:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5974:	b7e1                	j	593c <malloc+0x36>
      if(p->s.size == nunits)
    5976:	02e48b63          	beq	s1,a4,59ac <malloc+0xa6>
        p->s.size -= nunits;
    597a:	4137073b          	subw	a4,a4,s3
    597e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5980:	1702                	slli	a4,a4,0x20
    5982:	9301                	srli	a4,a4,0x20
    5984:	0712                	slli	a4,a4,0x4
    5986:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5988:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    598c:	00002717          	auipc	a4,0x2
    5990:	78a73223          	sd	a0,1924(a4) # 8110 <freep>
      return (void*)(p + 1);
    5994:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5998:	70e2                	ld	ra,56(sp)
    599a:	7442                	ld	s0,48(sp)
    599c:	74a2                	ld	s1,40(sp)
    599e:	7902                	ld	s2,32(sp)
    59a0:	69e2                	ld	s3,24(sp)
    59a2:	6a42                	ld	s4,16(sp)
    59a4:	6aa2                	ld	s5,8(sp)
    59a6:	6b02                	ld	s6,0(sp)
    59a8:	6121                	addi	sp,sp,64
    59aa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    59ac:	6398                	ld	a4,0(a5)
    59ae:	e118                	sd	a4,0(a0)
    59b0:	bff1                	j	598c <malloc+0x86>
  hp->s.size = nu;
    59b2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    59b6:	0541                	addi	a0,a0,16
    59b8:	00000097          	auipc	ra,0x0
    59bc:	ec6080e7          	jalr	-314(ra) # 587e <free>
  return freep;
    59c0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    59c4:	d971                	beqz	a0,5998 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    59c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    59c8:	4798                	lw	a4,8(a5)
    59ca:	fa9776e3          	bgeu	a4,s1,5976 <malloc+0x70>
    if(p == freep)
    59ce:	00093703          	ld	a4,0(s2)
    59d2:	853e                	mv	a0,a5
    59d4:	fef719e3          	bne	a4,a5,59c6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    59d8:	8552                	mv	a0,s4
    59da:	00000097          	auipc	ra,0x0
    59de:	b7e080e7          	jalr	-1154(ra) # 5558 <sbrk>
  if(p == (char*)-1)
    59e2:	fd5518e3          	bne	a0,s5,59b2 <malloc+0xac>
        return 0;
    59e6:	4501                	li	a0,0
    59e8:	bf45                	j	5998 <malloc+0x92>
