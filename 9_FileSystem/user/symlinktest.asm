
user/_symlinktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <stat_slink>:
}

// stat a symbolic link using O_NOFOLLOW
static int
stat_slink(char *pn, struct stat *st)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84ae                	mv	s1,a1
  int fd = open(pn, O_RDONLY | O_NOFOLLOW);
   c:	6585                	lui	a1,0x1
   e:	80058593          	addi	a1,a1,-2048 # 800 <gets+0x6e>
  12:	00001097          	auipc	ra,0x1
  16:	97a080e7          	jalr	-1670(ra) # 98c <open>
  if(fd < 0)
  1a:	02054063          	bltz	a0,3a <stat_slink+0x3a>
    return -1;
  if(fstat(fd, st) != 0)
  1e:	85a6                	mv	a1,s1
  20:	00001097          	auipc	ra,0x1
  24:	984080e7          	jalr	-1660(ra) # 9a4 <fstat>
  28:	00a03533          	snez	a0,a0
  2c:	40a00533          	neg	a0,a0
    return -1;
  return 0;
}
  30:	60e2                	ld	ra,24(sp)
  32:	6442                	ld	s0,16(sp)
  34:	64a2                	ld	s1,8(sp)
  36:	6105                	addi	sp,sp,32
  38:	8082                	ret
    return -1;
  3a:	557d                	li	a0,-1
  3c:	bfd5                	j	30 <stat_slink+0x30>

000000000000003e <main>:
{
  3e:	7119                	addi	sp,sp,-128
  40:	fc86                	sd	ra,120(sp)
  42:	f8a2                	sd	s0,112(sp)
  44:	f4a6                	sd	s1,104(sp)
  46:	f0ca                	sd	s2,96(sp)
  48:	ecce                	sd	s3,88(sp)
  4a:	e8d2                	sd	s4,80(sp)
  4c:	e4d6                	sd	s5,72(sp)
  4e:	e0da                	sd	s6,64(sp)
  50:	fc5e                	sd	s7,56(sp)
  52:	f862                	sd	s8,48(sp)
  54:	0100                	addi	s0,sp,128
  unlink("/testsymlink/a");
  56:	00001517          	auipc	a0,0x1
  5a:	e1a50513          	addi	a0,a0,-486 # e70 <malloc+0xe6>
  5e:	00001097          	auipc	ra,0x1
  62:	93e080e7          	jalr	-1730(ra) # 99c <unlink>
  unlink("/testsymlink/b");
  66:	00001517          	auipc	a0,0x1
  6a:	e1a50513          	addi	a0,a0,-486 # e80 <malloc+0xf6>
  6e:	00001097          	auipc	ra,0x1
  72:	92e080e7          	jalr	-1746(ra) # 99c <unlink>
  unlink("/testsymlink/c");
  76:	00001517          	auipc	a0,0x1
  7a:	e1a50513          	addi	a0,a0,-486 # e90 <malloc+0x106>
  7e:	00001097          	auipc	ra,0x1
  82:	91e080e7          	jalr	-1762(ra) # 99c <unlink>
  unlink("/testsymlink/1");
  86:	00001517          	auipc	a0,0x1
  8a:	e1a50513          	addi	a0,a0,-486 # ea0 <malloc+0x116>
  8e:	00001097          	auipc	ra,0x1
  92:	90e080e7          	jalr	-1778(ra) # 99c <unlink>
  unlink("/testsymlink/2");
  96:	00001517          	auipc	a0,0x1
  9a:	e1a50513          	addi	a0,a0,-486 # eb0 <malloc+0x126>
  9e:	00001097          	auipc	ra,0x1
  a2:	8fe080e7          	jalr	-1794(ra) # 99c <unlink>
  unlink("/testsymlink/3");
  a6:	00001517          	auipc	a0,0x1
  aa:	e1a50513          	addi	a0,a0,-486 # ec0 <malloc+0x136>
  ae:	00001097          	auipc	ra,0x1
  b2:	8ee080e7          	jalr	-1810(ra) # 99c <unlink>
  unlink("/testsymlink/4");
  b6:	00001517          	auipc	a0,0x1
  ba:	e1a50513          	addi	a0,a0,-486 # ed0 <malloc+0x146>
  be:	00001097          	auipc	ra,0x1
  c2:	8de080e7          	jalr	-1826(ra) # 99c <unlink>
  unlink("/testsymlink/z");
  c6:	00001517          	auipc	a0,0x1
  ca:	e1a50513          	addi	a0,a0,-486 # ee0 <malloc+0x156>
  ce:	00001097          	auipc	ra,0x1
  d2:	8ce080e7          	jalr	-1842(ra) # 99c <unlink>
  unlink("/testsymlink/y");
  d6:	00001517          	auipc	a0,0x1
  da:	e1a50513          	addi	a0,a0,-486 # ef0 <malloc+0x166>
  de:	00001097          	auipc	ra,0x1
  e2:	8be080e7          	jalr	-1858(ra) # 99c <unlink>
  unlink("/testsymlink");
  e6:	00001517          	auipc	a0,0x1
  ea:	e1a50513          	addi	a0,a0,-486 # f00 <malloc+0x176>
  ee:	00001097          	auipc	ra,0x1
  f2:	8ae080e7          	jalr	-1874(ra) # 99c <unlink>

static void
testsymlink(void)
{
  int r, fd1 = -1, fd2 = -1;
  char buf[4] = {'a', 'b', 'c', 'd'};
  f6:	646367b7          	lui	a5,0x64636
  fa:	2617879b          	addiw	a5,a5,609
  fe:	f8f42823          	sw	a5,-112(s0)
  char c = 0, c2 = 0;
 102:	f8040723          	sb	zero,-114(s0)
 106:	f80407a3          	sb	zero,-113(s0)
  struct stat st;
    
  printf("Start: test symlinks\n");
 10a:	00001517          	auipc	a0,0x1
 10e:	e0650513          	addi	a0,a0,-506 # f10 <malloc+0x186>
 112:	00001097          	auipc	ra,0x1
 116:	bba080e7          	jalr	-1094(ra) # ccc <printf>

  mkdir("/testsymlink");
 11a:	00001517          	auipc	a0,0x1
 11e:	de650513          	addi	a0,a0,-538 # f00 <malloc+0x176>
 122:	00001097          	auipc	ra,0x1
 126:	892080e7          	jalr	-1902(ra) # 9b4 <mkdir>

  fd1 = open("/testsymlink/a", O_CREATE | O_RDWR);
 12a:	20200593          	li	a1,514
 12e:	00001517          	auipc	a0,0x1
 132:	d4250513          	addi	a0,a0,-702 # e70 <malloc+0xe6>
 136:	00001097          	auipc	ra,0x1
 13a:	856080e7          	jalr	-1962(ra) # 98c <open>
 13e:	84aa                	mv	s1,a0
  if(fd1 < 0) fail("failed to open a");
 140:	0e054f63          	bltz	a0,23e <main+0x200>

  r = symlink("/testsymlink/a", "/testsymlink/b");
 144:	00001597          	auipc	a1,0x1
 148:	d3c58593          	addi	a1,a1,-708 # e80 <malloc+0xf6>
 14c:	00001517          	auipc	a0,0x1
 150:	d2450513          	addi	a0,a0,-732 # e70 <malloc+0xe6>
 154:	00001097          	auipc	ra,0x1
 158:	898080e7          	jalr	-1896(ra) # 9ec <symlink>
  if(r < 0)
 15c:	10054063          	bltz	a0,25c <main+0x21e>
    fail("symlink b -> a failed");

  if(write(fd1, buf, sizeof(buf)) != 4)
 160:	4611                	li	a2,4
 162:	f9040593          	addi	a1,s0,-112
 166:	8526                	mv	a0,s1
 168:	00001097          	auipc	ra,0x1
 16c:	804080e7          	jalr	-2044(ra) # 96c <write>
 170:	4791                	li	a5,4
 172:	10f50463          	beq	a0,a5,27a <main+0x23c>
    fail("failed to write to a");
 176:	00001517          	auipc	a0,0x1
 17a:	df250513          	addi	a0,a0,-526 # f68 <malloc+0x1de>
 17e:	00001097          	auipc	ra,0x1
 182:	b4e080e7          	jalr	-1202(ra) # ccc <printf>
 186:	4785                	li	a5,1
 188:	00001717          	auipc	a4,0x1
 18c:	1af72023          	sw	a5,416(a4) # 1328 <failed>
  int r, fd1 = -1, fd2 = -1;
 190:	597d                	li	s2,-1
  if(c!=c2)
    fail("Value read from 4 differed from value written to 1\n");

  printf("test symlinks: ok\n");
done:
  close(fd1);
 192:	8526                	mv	a0,s1
 194:	00000097          	auipc	ra,0x0
 198:	7e0080e7          	jalr	2016(ra) # 974 <close>
  close(fd2);
 19c:	854a                	mv	a0,s2
 19e:	00000097          	auipc	ra,0x0
 1a2:	7d6080e7          	jalr	2006(ra) # 974 <close>
  int pid, i;
  int fd;
  struct stat st;
  int nchild = 2;

  printf("Start: test concurrent symlinks\n");
 1a6:	00001517          	auipc	a0,0x1
 1aa:	0a250513          	addi	a0,a0,162 # 1248 <malloc+0x4be>
 1ae:	00001097          	auipc	ra,0x1
 1b2:	b1e080e7          	jalr	-1250(ra) # ccc <printf>
    
  fd = open("/testsymlink/z", O_CREATE | O_RDWR);
 1b6:	20200593          	li	a1,514
 1ba:	00001517          	auipc	a0,0x1
 1be:	d2650513          	addi	a0,a0,-730 # ee0 <malloc+0x156>
 1c2:	00000097          	auipc	ra,0x0
 1c6:	7ca080e7          	jalr	1994(ra) # 98c <open>
  if(fd < 0) {
 1ca:	42054263          	bltz	a0,5ee <main+0x5b0>
    printf("FAILED: open failed");
    exit(1);
  }
  close(fd);
 1ce:	00000097          	auipc	ra,0x0
 1d2:	7a6080e7          	jalr	1958(ra) # 974 <close>

  for(int j = 0; j < nchild; j++) {
    pid = fork();
 1d6:	00000097          	auipc	ra,0x0
 1da:	76e080e7          	jalr	1902(ra) # 944 <fork>
    if(pid < 0){
 1de:	42054563          	bltz	a0,608 <main+0x5ca>
      printf("FAILED: fork failed\n");
      exit(1);
    }
    if(pid == 0) {
 1e2:	44050063          	beqz	a0,622 <main+0x5e4>
    pid = fork();
 1e6:	00000097          	auipc	ra,0x0
 1ea:	75e080e7          	jalr	1886(ra) # 944 <fork>
    if(pid < 0){
 1ee:	40054d63          	bltz	a0,608 <main+0x5ca>
    if(pid == 0) {
 1f2:	42050863          	beqz	a0,622 <main+0x5e4>
    }
  }

  int r;
  for(int j = 0; j < nchild; j++) {
    wait(&r);
 1f6:	f9840513          	addi	a0,s0,-104
 1fa:	00000097          	auipc	ra,0x0
 1fe:	75a080e7          	jalr	1882(ra) # 954 <wait>
    if(r != 0) {
 202:	f9842783          	lw	a5,-104(s0)
 206:	4a079b63          	bnez	a5,6bc <main+0x67e>
    wait(&r);
 20a:	f9840513          	addi	a0,s0,-104
 20e:	00000097          	auipc	ra,0x0
 212:	746080e7          	jalr	1862(ra) # 954 <wait>
    if(r != 0) {
 216:	f9842783          	lw	a5,-104(s0)
 21a:	4a079163          	bnez	a5,6bc <main+0x67e>
      printf("test concurrent symlinks: failed\n");
      exit(1);
    }
  }
  printf("test concurrent symlinks: ok\n");
 21e:	00001517          	auipc	a0,0x1
 222:	0ca50513          	addi	a0,a0,202 # 12e8 <malloc+0x55e>
 226:	00001097          	auipc	ra,0x1
 22a:	aa6080e7          	jalr	-1370(ra) # ccc <printf>
  exit(failed);
 22e:	00001517          	auipc	a0,0x1
 232:	0fa52503          	lw	a0,250(a0) # 1328 <failed>
 236:	00000097          	auipc	ra,0x0
 23a:	716080e7          	jalr	1814(ra) # 94c <exit>
  if(fd1 < 0) fail("failed to open a");
 23e:	00001517          	auipc	a0,0x1
 242:	cea50513          	addi	a0,a0,-790 # f28 <malloc+0x19e>
 246:	00001097          	auipc	ra,0x1
 24a:	a86080e7          	jalr	-1402(ra) # ccc <printf>
 24e:	4785                	li	a5,1
 250:	00001717          	auipc	a4,0x1
 254:	0cf72c23          	sw	a5,216(a4) # 1328 <failed>
  int r, fd1 = -1, fd2 = -1;
 258:	597d                	li	s2,-1
  if(fd1 < 0) fail("failed to open a");
 25a:	bf25                	j	192 <main+0x154>
    fail("symlink b -> a failed");
 25c:	00001517          	auipc	a0,0x1
 260:	cec50513          	addi	a0,a0,-788 # f48 <malloc+0x1be>
 264:	00001097          	auipc	ra,0x1
 268:	a68080e7          	jalr	-1432(ra) # ccc <printf>
 26c:	4785                	li	a5,1
 26e:	00001717          	auipc	a4,0x1
 272:	0af72d23          	sw	a5,186(a4) # 1328 <failed>
  int r, fd1 = -1, fd2 = -1;
 276:	597d                	li	s2,-1
    fail("symlink b -> a failed");
 278:	bf29                	j	192 <main+0x154>
  if (stat_slink("/testsymlink/b", &st) != 0)
 27a:	f9840593          	addi	a1,s0,-104
 27e:	00001517          	auipc	a0,0x1
 282:	c0250513          	addi	a0,a0,-1022 # e80 <malloc+0xf6>
 286:	00000097          	auipc	ra,0x0
 28a:	d7a080e7          	jalr	-646(ra) # 0 <stat_slink>
 28e:	e50d                	bnez	a0,2b8 <main+0x27a>
  if(st.type != T_SYMLINK)
 290:	fa041703          	lh	a4,-96(s0)
 294:	4791                	li	a5,4
 296:	04f70063          	beq	a4,a5,2d6 <main+0x298>
    fail("b isn't a symlink");
 29a:	00001517          	auipc	a0,0x1
 29e:	d0e50513          	addi	a0,a0,-754 # fa8 <malloc+0x21e>
 2a2:	00001097          	auipc	ra,0x1
 2a6:	a2a080e7          	jalr	-1494(ra) # ccc <printf>
 2aa:	4785                	li	a5,1
 2ac:	00001717          	auipc	a4,0x1
 2b0:	06f72e23          	sw	a5,124(a4) # 1328 <failed>
  int r, fd1 = -1, fd2 = -1;
 2b4:	597d                	li	s2,-1
    fail("b isn't a symlink");
 2b6:	bdf1                	j	192 <main+0x154>
    fail("failed to stat b");
 2b8:	00001517          	auipc	a0,0x1
 2bc:	cd050513          	addi	a0,a0,-816 # f88 <malloc+0x1fe>
 2c0:	00001097          	auipc	ra,0x1
 2c4:	a0c080e7          	jalr	-1524(ra) # ccc <printf>
 2c8:	4785                	li	a5,1
 2ca:	00001717          	auipc	a4,0x1
 2ce:	04f72f23          	sw	a5,94(a4) # 1328 <failed>
  int r, fd1 = -1, fd2 = -1;
 2d2:	597d                	li	s2,-1
    fail("failed to stat b");
 2d4:	bd7d                	j	192 <main+0x154>
  fd2 = open("/testsymlink/b", O_RDWR);
 2d6:	4589                	li	a1,2
 2d8:	00001517          	auipc	a0,0x1
 2dc:	ba850513          	addi	a0,a0,-1112 # e80 <malloc+0xf6>
 2e0:	00000097          	auipc	ra,0x0
 2e4:	6ac080e7          	jalr	1708(ra) # 98c <open>
 2e8:	892a                	mv	s2,a0
  if(fd2 < 0)
 2ea:	02054d63          	bltz	a0,324 <main+0x2e6>
  read(fd2, &c, 1);
 2ee:	4605                	li	a2,1
 2f0:	f8e40593          	addi	a1,s0,-114
 2f4:	00000097          	auipc	ra,0x0
 2f8:	670080e7          	jalr	1648(ra) # 964 <read>
  if (c != 'a')
 2fc:	f8e44703          	lbu	a4,-114(s0)
 300:	06100793          	li	a5,97
 304:	02f70e63          	beq	a4,a5,340 <main+0x302>
    fail("failed to read bytes from b");
 308:	00001517          	auipc	a0,0x1
 30c:	ce050513          	addi	a0,a0,-800 # fe8 <malloc+0x25e>
 310:	00001097          	auipc	ra,0x1
 314:	9bc080e7          	jalr	-1604(ra) # ccc <printf>
 318:	4785                	li	a5,1
 31a:	00001717          	auipc	a4,0x1
 31e:	00f72723          	sw	a5,14(a4) # 1328 <failed>
 322:	bd85                	j	192 <main+0x154>
    fail("failed to open b");
 324:	00001517          	auipc	a0,0x1
 328:	ca450513          	addi	a0,a0,-860 # fc8 <malloc+0x23e>
 32c:	00001097          	auipc	ra,0x1
 330:	9a0080e7          	jalr	-1632(ra) # ccc <printf>
 334:	4785                	li	a5,1
 336:	00001717          	auipc	a4,0x1
 33a:	fef72923          	sw	a5,-14(a4) # 1328 <failed>
 33e:	bd91                	j	192 <main+0x154>
  unlink("/testsymlink/a");
 340:	00001517          	auipc	a0,0x1
 344:	b3050513          	addi	a0,a0,-1232 # e70 <malloc+0xe6>
 348:	00000097          	auipc	ra,0x0
 34c:	654080e7          	jalr	1620(ra) # 99c <unlink>
  if(open("/testsymlink/b", O_RDWR) >= 0)
 350:	4589                	li	a1,2
 352:	00001517          	auipc	a0,0x1
 356:	b2e50513          	addi	a0,a0,-1234 # e80 <malloc+0xf6>
 35a:	00000097          	auipc	ra,0x0
 35e:	632080e7          	jalr	1586(ra) # 98c <open>
 362:	12055263          	bgez	a0,486 <main+0x448>
  r = symlink("/testsymlink/b", "/testsymlink/a");
 366:	00001597          	auipc	a1,0x1
 36a:	b0a58593          	addi	a1,a1,-1270 # e70 <malloc+0xe6>
 36e:	00001517          	auipc	a0,0x1
 372:	b1250513          	addi	a0,a0,-1262 # e80 <malloc+0xf6>
 376:	00000097          	auipc	ra,0x0
 37a:	676080e7          	jalr	1654(ra) # 9ec <symlink>
  if(r < 0)
 37e:	12054263          	bltz	a0,4a2 <main+0x464>
  r = open("/testsymlink/b", O_RDWR);
 382:	4589                	li	a1,2
 384:	00001517          	auipc	a0,0x1
 388:	afc50513          	addi	a0,a0,-1284 # e80 <malloc+0xf6>
 38c:	00000097          	auipc	ra,0x0
 390:	600080e7          	jalr	1536(ra) # 98c <open>
  if(r >= 0)
 394:	12055563          	bgez	a0,4be <main+0x480>
  r = symlink("/testsymlink/nonexistent", "/testsymlink/c");
 398:	00001597          	auipc	a1,0x1
 39c:	af858593          	addi	a1,a1,-1288 # e90 <malloc+0x106>
 3a0:	00001517          	auipc	a0,0x1
 3a4:	d0850513          	addi	a0,a0,-760 # 10a8 <malloc+0x31e>
 3a8:	00000097          	auipc	ra,0x0
 3ac:	644080e7          	jalr	1604(ra) # 9ec <symlink>
  if(r != 0)
 3b0:	12051563          	bnez	a0,4da <main+0x49c>
  r = symlink("/testsymlink/2", "/testsymlink/1");
 3b4:	00001597          	auipc	a1,0x1
 3b8:	aec58593          	addi	a1,a1,-1300 # ea0 <malloc+0x116>
 3bc:	00001517          	auipc	a0,0x1
 3c0:	af450513          	addi	a0,a0,-1292 # eb0 <malloc+0x126>
 3c4:	00000097          	auipc	ra,0x0
 3c8:	628080e7          	jalr	1576(ra) # 9ec <symlink>
  if(r) fail("Failed to link 1->2");
 3cc:	12051563          	bnez	a0,4f6 <main+0x4b8>
  r = symlink("/testsymlink/3", "/testsymlink/2");
 3d0:	00001597          	auipc	a1,0x1
 3d4:	ae058593          	addi	a1,a1,-1312 # eb0 <malloc+0x126>
 3d8:	00001517          	auipc	a0,0x1
 3dc:	ae850513          	addi	a0,a0,-1304 # ec0 <malloc+0x136>
 3e0:	00000097          	auipc	ra,0x0
 3e4:	60c080e7          	jalr	1548(ra) # 9ec <symlink>
  if(r) fail("Failed to link 2->3");
 3e8:	12051563          	bnez	a0,512 <main+0x4d4>
  r = symlink("/testsymlink/4", "/testsymlink/3");
 3ec:	00001597          	auipc	a1,0x1
 3f0:	ad458593          	addi	a1,a1,-1324 # ec0 <malloc+0x136>
 3f4:	00001517          	auipc	a0,0x1
 3f8:	adc50513          	addi	a0,a0,-1316 # ed0 <malloc+0x146>
 3fc:	00000097          	auipc	ra,0x0
 400:	5f0080e7          	jalr	1520(ra) # 9ec <symlink>
  if(r) fail("Failed to link 3->4");
 404:	12051563          	bnez	a0,52e <main+0x4f0>
  close(fd1);
 408:	8526                	mv	a0,s1
 40a:	00000097          	auipc	ra,0x0
 40e:	56a080e7          	jalr	1386(ra) # 974 <close>
  close(fd2);
 412:	854a                	mv	a0,s2
 414:	00000097          	auipc	ra,0x0
 418:	560080e7          	jalr	1376(ra) # 974 <close>
  fd1 = open("/testsymlink/4", O_CREATE | O_RDWR);
 41c:	20200593          	li	a1,514
 420:	00001517          	auipc	a0,0x1
 424:	ab050513          	addi	a0,a0,-1360 # ed0 <malloc+0x146>
 428:	00000097          	auipc	ra,0x0
 42c:	564080e7          	jalr	1380(ra) # 98c <open>
 430:	84aa                	mv	s1,a0
  if(fd1<0) fail("Failed to create 4\n");
 432:	10054c63          	bltz	a0,54a <main+0x50c>
  fd2 = open("/testsymlink/1", O_RDWR);
 436:	4589                	li	a1,2
 438:	00001517          	auipc	a0,0x1
 43c:	a6850513          	addi	a0,a0,-1432 # ea0 <malloc+0x116>
 440:	00000097          	auipc	ra,0x0
 444:	54c080e7          	jalr	1356(ra) # 98c <open>
 448:	892a                	mv	s2,a0
  if(fd2<0) fail("Failed to open 1\n");
 44a:	10054e63          	bltz	a0,566 <main+0x528>
  c = '#';
 44e:	02300793          	li	a5,35
 452:	f8f40723          	sb	a5,-114(s0)
  r = write(fd2, &c, 1);
 456:	4605                	li	a2,1
 458:	f8e40593          	addi	a1,s0,-114
 45c:	00000097          	auipc	ra,0x0
 460:	510080e7          	jalr	1296(ra) # 96c <write>
  if(r!=1) fail("Failed to write to 1\n");
 464:	4785                	li	a5,1
 466:	10f50e63          	beq	a0,a5,582 <main+0x544>
 46a:	00001517          	auipc	a0,0x1
 46e:	d3e50513          	addi	a0,a0,-706 # 11a8 <malloc+0x41e>
 472:	00001097          	auipc	ra,0x1
 476:	85a080e7          	jalr	-1958(ra) # ccc <printf>
 47a:	4785                	li	a5,1
 47c:	00001717          	auipc	a4,0x1
 480:	eaf72623          	sw	a5,-340(a4) # 1328 <failed>
 484:	b339                	j	192 <main+0x154>
    fail("Should not be able to open b after deleting a");
 486:	00001517          	auipc	a0,0x1
 48a:	b8a50513          	addi	a0,a0,-1142 # 1010 <malloc+0x286>
 48e:	00001097          	auipc	ra,0x1
 492:	83e080e7          	jalr	-1986(ra) # ccc <printf>
 496:	4785                	li	a5,1
 498:	00001717          	auipc	a4,0x1
 49c:	e8f72823          	sw	a5,-368(a4) # 1328 <failed>
 4a0:	b9cd                	j	192 <main+0x154>
    fail("symlink a -> b failed");
 4a2:	00001517          	auipc	a0,0x1
 4a6:	ba650513          	addi	a0,a0,-1114 # 1048 <malloc+0x2be>
 4aa:	00001097          	auipc	ra,0x1
 4ae:	822080e7          	jalr	-2014(ra) # ccc <printf>
 4b2:	4785                	li	a5,1
 4b4:	00001717          	auipc	a4,0x1
 4b8:	e6f72a23          	sw	a5,-396(a4) # 1328 <failed>
 4bc:	b9d9                	j	192 <main+0x154>
    fail("Should not be able to open b (cycle b->a->b->..)\n");
 4be:	00001517          	auipc	a0,0x1
 4c2:	baa50513          	addi	a0,a0,-1110 # 1068 <malloc+0x2de>
 4c6:	00001097          	auipc	ra,0x1
 4ca:	806080e7          	jalr	-2042(ra) # ccc <printf>
 4ce:	4785                	li	a5,1
 4d0:	00001717          	auipc	a4,0x1
 4d4:	e4f72c23          	sw	a5,-424(a4) # 1328 <failed>
 4d8:	b96d                	j	192 <main+0x154>
    fail("Symlinking to nonexistent file should succeed\n");
 4da:	00001517          	auipc	a0,0x1
 4de:	bee50513          	addi	a0,a0,-1042 # 10c8 <malloc+0x33e>
 4e2:	00000097          	auipc	ra,0x0
 4e6:	7ea080e7          	jalr	2026(ra) # ccc <printf>
 4ea:	4785                	li	a5,1
 4ec:	00001717          	auipc	a4,0x1
 4f0:	e2f72e23          	sw	a5,-452(a4) # 1328 <failed>
 4f4:	b979                	j	192 <main+0x154>
  if(r) fail("Failed to link 1->2");
 4f6:	00001517          	auipc	a0,0x1
 4fa:	c1250513          	addi	a0,a0,-1006 # 1108 <malloc+0x37e>
 4fe:	00000097          	auipc	ra,0x0
 502:	7ce080e7          	jalr	1998(ra) # ccc <printf>
 506:	4785                	li	a5,1
 508:	00001717          	auipc	a4,0x1
 50c:	e2f72023          	sw	a5,-480(a4) # 1328 <failed>
 510:	b149                	j	192 <main+0x154>
  if(r) fail("Failed to link 2->3");
 512:	00001517          	auipc	a0,0x1
 516:	c1650513          	addi	a0,a0,-1002 # 1128 <malloc+0x39e>
 51a:	00000097          	auipc	ra,0x0
 51e:	7b2080e7          	jalr	1970(ra) # ccc <printf>
 522:	4785                	li	a5,1
 524:	00001717          	auipc	a4,0x1
 528:	e0f72223          	sw	a5,-508(a4) # 1328 <failed>
 52c:	b19d                	j	192 <main+0x154>
  if(r) fail("Failed to link 3->4");
 52e:	00001517          	auipc	a0,0x1
 532:	c1a50513          	addi	a0,a0,-998 # 1148 <malloc+0x3be>
 536:	00000097          	auipc	ra,0x0
 53a:	796080e7          	jalr	1942(ra) # ccc <printf>
 53e:	4785                	li	a5,1
 540:	00001717          	auipc	a4,0x1
 544:	def72423          	sw	a5,-536(a4) # 1328 <failed>
 548:	b1a9                	j	192 <main+0x154>
  if(fd1<0) fail("Failed to create 4\n");
 54a:	00001517          	auipc	a0,0x1
 54e:	c1e50513          	addi	a0,a0,-994 # 1168 <malloc+0x3de>
 552:	00000097          	auipc	ra,0x0
 556:	77a080e7          	jalr	1914(ra) # ccc <printf>
 55a:	4785                	li	a5,1
 55c:	00001717          	auipc	a4,0x1
 560:	dcf72623          	sw	a5,-564(a4) # 1328 <failed>
 564:	b13d                	j	192 <main+0x154>
  if(fd2<0) fail("Failed to open 1\n");
 566:	00001517          	auipc	a0,0x1
 56a:	c2250513          	addi	a0,a0,-990 # 1188 <malloc+0x3fe>
 56e:	00000097          	auipc	ra,0x0
 572:	75e080e7          	jalr	1886(ra) # ccc <printf>
 576:	4785                	li	a5,1
 578:	00001717          	auipc	a4,0x1
 57c:	daf72823          	sw	a5,-592(a4) # 1328 <failed>
 580:	b909                	j	192 <main+0x154>
  r = read(fd1, &c2, 1);
 582:	4605                	li	a2,1
 584:	f8f40593          	addi	a1,s0,-113
 588:	8526                	mv	a0,s1
 58a:	00000097          	auipc	ra,0x0
 58e:	3da080e7          	jalr	986(ra) # 964 <read>
  if(r!=1) fail("Failed to read from 4\n");
 592:	4785                	li	a5,1
 594:	02f51663          	bne	a0,a5,5c0 <main+0x582>
  if(c!=c2)
 598:	f8e44703          	lbu	a4,-114(s0)
 59c:	f8f44783          	lbu	a5,-113(s0)
 5a0:	02f70e63          	beq	a4,a5,5dc <main+0x59e>
    fail("Value read from 4 differed from value written to 1\n");
 5a4:	00001517          	auipc	a0,0x1
 5a8:	c4c50513          	addi	a0,a0,-948 # 11f0 <malloc+0x466>
 5ac:	00000097          	auipc	ra,0x0
 5b0:	720080e7          	jalr	1824(ra) # ccc <printf>
 5b4:	4785                	li	a5,1
 5b6:	00001717          	auipc	a4,0x1
 5ba:	d6f72923          	sw	a5,-654(a4) # 1328 <failed>
 5be:	bed1                	j	192 <main+0x154>
  if(r!=1) fail("Failed to read from 4\n");
 5c0:	00001517          	auipc	a0,0x1
 5c4:	c0850513          	addi	a0,a0,-1016 # 11c8 <malloc+0x43e>
 5c8:	00000097          	auipc	ra,0x0
 5cc:	704080e7          	jalr	1796(ra) # ccc <printf>
 5d0:	4785                	li	a5,1
 5d2:	00001717          	auipc	a4,0x1
 5d6:	d4f72b23          	sw	a5,-682(a4) # 1328 <failed>
 5da:	be65                	j	192 <main+0x154>
  printf("test symlinks: ok\n");
 5dc:	00001517          	auipc	a0,0x1
 5e0:	c5450513          	addi	a0,a0,-940 # 1230 <malloc+0x4a6>
 5e4:	00000097          	auipc	ra,0x0
 5e8:	6e8080e7          	jalr	1768(ra) # ccc <printf>
 5ec:	b65d                	j	192 <main+0x154>
    printf("FAILED: open failed");
 5ee:	00001517          	auipc	a0,0x1
 5f2:	c8250513          	addi	a0,a0,-894 # 1270 <malloc+0x4e6>
 5f6:	00000097          	auipc	ra,0x0
 5fa:	6d6080e7          	jalr	1750(ra) # ccc <printf>
    exit(1);
 5fe:	4505                	li	a0,1
 600:	00000097          	auipc	ra,0x0
 604:	34c080e7          	jalr	844(ra) # 94c <exit>
      printf("FAILED: fork failed\n");
 608:	00001517          	auipc	a0,0x1
 60c:	c8050513          	addi	a0,a0,-896 # 1288 <malloc+0x4fe>
 610:	00000097          	auipc	ra,0x0
 614:	6bc080e7          	jalr	1724(ra) # ccc <printf>
      exit(1);
 618:	4505                	li	a0,1
 61a:	00000097          	auipc	ra,0x0
 61e:	332080e7          	jalr	818(ra) # 94c <exit>
  int r, fd1 = -1, fd2 = -1;
 622:	06400913          	li	s2,100
      unsigned int x = (pid ? 1 : 97);
 626:	06100c13          	li	s8,97
        x = x * 1103515245 + 12345;
 62a:	41c65a37          	lui	s4,0x41c65
 62e:	e6da0a1b          	addiw	s4,s4,-403
 632:	698d                	lui	s3,0x3
 634:	0399899b          	addiw	s3,s3,57
        if((x % 3) == 0) {
 638:	4b8d                	li	s7,3
          unlink("/testsymlink/y");
 63a:	00001497          	auipc	s1,0x1
 63e:	8b648493          	addi	s1,s1,-1866 # ef0 <malloc+0x166>
          symlink("/testsymlink/z", "/testsymlink/y");
 642:	00001b17          	auipc	s6,0x1
 646:	89eb0b13          	addi	s6,s6,-1890 # ee0 <malloc+0x156>
            if(st.type != T_SYMLINK) {
 64a:	4a91                	li	s5,4
 64c:	a809                	j	65e <main+0x620>
          unlink("/testsymlink/y");
 64e:	8526                	mv	a0,s1
 650:	00000097          	auipc	ra,0x0
 654:	34c080e7          	jalr	844(ra) # 99c <unlink>
      for(i = 0; i < 100; i++){
 658:	397d                	addiw	s2,s2,-1
 65a:	04090c63          	beqz	s2,6b2 <main+0x674>
        x = x * 1103515245 + 12345;
 65e:	034c07bb          	mulw	a5,s8,s4
 662:	013787bb          	addw	a5,a5,s3
 666:	00078c1b          	sext.w	s8,a5
        if((x % 3) == 0) {
 66a:	0377f7bb          	remuw	a5,a5,s7
 66e:	f3e5                	bnez	a5,64e <main+0x610>
          symlink("/testsymlink/z", "/testsymlink/y");
 670:	85a6                	mv	a1,s1
 672:	855a                	mv	a0,s6
 674:	00000097          	auipc	ra,0x0
 678:	378080e7          	jalr	888(ra) # 9ec <symlink>
          if (stat_slink("/testsymlink/y", &st) == 0) {
 67c:	f9840593          	addi	a1,s0,-104
 680:	8526                	mv	a0,s1
 682:	00000097          	auipc	ra,0x0
 686:	97e080e7          	jalr	-1666(ra) # 0 <stat_slink>
 68a:	f579                	bnez	a0,658 <main+0x61a>
            if(st.type != T_SYMLINK) {
 68c:	fa041583          	lh	a1,-96(s0)
 690:	0005879b          	sext.w	a5,a1
 694:	fd5782e3          	beq	a5,s5,658 <main+0x61a>
              printf("FAILED: not a symbolic link\n", st.type);
 698:	00001517          	auipc	a0,0x1
 69c:	c0850513          	addi	a0,a0,-1016 # 12a0 <malloc+0x516>
 6a0:	00000097          	auipc	ra,0x0
 6a4:	62c080e7          	jalr	1580(ra) # ccc <printf>
              exit(1);
 6a8:	4505                	li	a0,1
 6aa:	00000097          	auipc	ra,0x0
 6ae:	2a2080e7          	jalr	674(ra) # 94c <exit>
      exit(0);
 6b2:	4501                	li	a0,0
 6b4:	00000097          	auipc	ra,0x0
 6b8:	298080e7          	jalr	664(ra) # 94c <exit>
      printf("test concurrent symlinks: failed\n");
 6bc:	00001517          	auipc	a0,0x1
 6c0:	c0450513          	addi	a0,a0,-1020 # 12c0 <malloc+0x536>
 6c4:	00000097          	auipc	ra,0x0
 6c8:	608080e7          	jalr	1544(ra) # ccc <printf>
      exit(1);
 6cc:	4505                	li	a0,1
 6ce:	00000097          	auipc	ra,0x0
 6d2:	27e080e7          	jalr	638(ra) # 94c <exit>

00000000000006d6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 6d6:	1141                	addi	sp,sp,-16
 6d8:	e422                	sd	s0,8(sp)
 6da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6dc:	87aa                	mv	a5,a0
 6de:	0585                	addi	a1,a1,1
 6e0:	0785                	addi	a5,a5,1
 6e2:	fff5c703          	lbu	a4,-1(a1)
 6e6:	fee78fa3          	sb	a4,-1(a5) # 64635fff <__global_pointer$+0x646344de>
 6ea:	fb75                	bnez	a4,6de <strcpy+0x8>
    ;
  return os;
}
 6ec:	6422                	ld	s0,8(sp)
 6ee:	0141                	addi	sp,sp,16
 6f0:	8082                	ret

00000000000006f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6f2:	1141                	addi	sp,sp,-16
 6f4:	e422                	sd	s0,8(sp)
 6f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6f8:	00054783          	lbu	a5,0(a0)
 6fc:	cb91                	beqz	a5,710 <strcmp+0x1e>
 6fe:	0005c703          	lbu	a4,0(a1)
 702:	00f71763          	bne	a4,a5,710 <strcmp+0x1e>
    p++, q++;
 706:	0505                	addi	a0,a0,1
 708:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 70a:	00054783          	lbu	a5,0(a0)
 70e:	fbe5                	bnez	a5,6fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 710:	0005c503          	lbu	a0,0(a1)
}
 714:	40a7853b          	subw	a0,a5,a0
 718:	6422                	ld	s0,8(sp)
 71a:	0141                	addi	sp,sp,16
 71c:	8082                	ret

000000000000071e <strlen>:

uint
strlen(const char *s)
{
 71e:	1141                	addi	sp,sp,-16
 720:	e422                	sd	s0,8(sp)
 722:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 724:	00054783          	lbu	a5,0(a0)
 728:	cf91                	beqz	a5,744 <strlen+0x26>
 72a:	0505                	addi	a0,a0,1
 72c:	87aa                	mv	a5,a0
 72e:	4685                	li	a3,1
 730:	9e89                	subw	a3,a3,a0
 732:	00f6853b          	addw	a0,a3,a5
 736:	0785                	addi	a5,a5,1
 738:	fff7c703          	lbu	a4,-1(a5)
 73c:	fb7d                	bnez	a4,732 <strlen+0x14>
    ;
  return n;
}
 73e:	6422                	ld	s0,8(sp)
 740:	0141                	addi	sp,sp,16
 742:	8082                	ret
  for(n = 0; s[n]; n++)
 744:	4501                	li	a0,0
 746:	bfe5                	j	73e <strlen+0x20>

0000000000000748 <memset>:

void*
memset(void *dst, int c, uint n)
{
 748:	1141                	addi	sp,sp,-16
 74a:	e422                	sd	s0,8(sp)
 74c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 74e:	ce09                	beqz	a2,768 <memset+0x20>
 750:	87aa                	mv	a5,a0
 752:	fff6071b          	addiw	a4,a2,-1
 756:	1702                	slli	a4,a4,0x20
 758:	9301                	srli	a4,a4,0x20
 75a:	0705                	addi	a4,a4,1
 75c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 75e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 762:	0785                	addi	a5,a5,1
 764:	fee79de3          	bne	a5,a4,75e <memset+0x16>
  }
  return dst;
}
 768:	6422                	ld	s0,8(sp)
 76a:	0141                	addi	sp,sp,16
 76c:	8082                	ret

000000000000076e <strchr>:

char*
strchr(const char *s, char c)
{
 76e:	1141                	addi	sp,sp,-16
 770:	e422                	sd	s0,8(sp)
 772:	0800                	addi	s0,sp,16
  for(; *s; s++)
 774:	00054783          	lbu	a5,0(a0)
 778:	cb99                	beqz	a5,78e <strchr+0x20>
    if(*s == c)
 77a:	00f58763          	beq	a1,a5,788 <strchr+0x1a>
  for(; *s; s++)
 77e:	0505                	addi	a0,a0,1
 780:	00054783          	lbu	a5,0(a0)
 784:	fbfd                	bnez	a5,77a <strchr+0xc>
      return (char*)s;
  return 0;
 786:	4501                	li	a0,0
}
 788:	6422                	ld	s0,8(sp)
 78a:	0141                	addi	sp,sp,16
 78c:	8082                	ret
  return 0;
 78e:	4501                	li	a0,0
 790:	bfe5                	j	788 <strchr+0x1a>

0000000000000792 <gets>:

char*
gets(char *buf, int max)
{
 792:	711d                	addi	sp,sp,-96
 794:	ec86                	sd	ra,88(sp)
 796:	e8a2                	sd	s0,80(sp)
 798:	e4a6                	sd	s1,72(sp)
 79a:	e0ca                	sd	s2,64(sp)
 79c:	fc4e                	sd	s3,56(sp)
 79e:	f852                	sd	s4,48(sp)
 7a0:	f456                	sd	s5,40(sp)
 7a2:	f05a                	sd	s6,32(sp)
 7a4:	ec5e                	sd	s7,24(sp)
 7a6:	1080                	addi	s0,sp,96
 7a8:	8baa                	mv	s7,a0
 7aa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 7ac:	892a                	mv	s2,a0
 7ae:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 7b0:	4aa9                	li	s5,10
 7b2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 7b4:	89a6                	mv	s3,s1
 7b6:	2485                	addiw	s1,s1,1
 7b8:	0344d863          	bge	s1,s4,7e8 <gets+0x56>
    cc = read(0, &c, 1);
 7bc:	4605                	li	a2,1
 7be:	faf40593          	addi	a1,s0,-81
 7c2:	4501                	li	a0,0
 7c4:	00000097          	auipc	ra,0x0
 7c8:	1a0080e7          	jalr	416(ra) # 964 <read>
    if(cc < 1)
 7cc:	00a05e63          	blez	a0,7e8 <gets+0x56>
    buf[i++] = c;
 7d0:	faf44783          	lbu	a5,-81(s0)
 7d4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 7d8:	01578763          	beq	a5,s5,7e6 <gets+0x54>
 7dc:	0905                	addi	s2,s2,1
 7de:	fd679be3          	bne	a5,s6,7b4 <gets+0x22>
  for(i=0; i+1 < max; ){
 7e2:	89a6                	mv	s3,s1
 7e4:	a011                	j	7e8 <gets+0x56>
 7e6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7e8:	99de                	add	s3,s3,s7
 7ea:	00098023          	sb	zero,0(s3) # 3000 <__global_pointer$+0x14df>
  return buf;
}
 7ee:	855e                	mv	a0,s7
 7f0:	60e6                	ld	ra,88(sp)
 7f2:	6446                	ld	s0,80(sp)
 7f4:	64a6                	ld	s1,72(sp)
 7f6:	6906                	ld	s2,64(sp)
 7f8:	79e2                	ld	s3,56(sp)
 7fa:	7a42                	ld	s4,48(sp)
 7fc:	7aa2                	ld	s5,40(sp)
 7fe:	7b02                	ld	s6,32(sp)
 800:	6be2                	ld	s7,24(sp)
 802:	6125                	addi	sp,sp,96
 804:	8082                	ret

0000000000000806 <stat>:

int
stat(const char *n, struct stat *st)
{
 806:	1101                	addi	sp,sp,-32
 808:	ec06                	sd	ra,24(sp)
 80a:	e822                	sd	s0,16(sp)
 80c:	e426                	sd	s1,8(sp)
 80e:	e04a                	sd	s2,0(sp)
 810:	1000                	addi	s0,sp,32
 812:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 814:	4581                	li	a1,0
 816:	00000097          	auipc	ra,0x0
 81a:	176080e7          	jalr	374(ra) # 98c <open>
  if(fd < 0)
 81e:	02054563          	bltz	a0,848 <stat+0x42>
 822:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 824:	85ca                	mv	a1,s2
 826:	00000097          	auipc	ra,0x0
 82a:	17e080e7          	jalr	382(ra) # 9a4 <fstat>
 82e:	892a                	mv	s2,a0
  close(fd);
 830:	8526                	mv	a0,s1
 832:	00000097          	auipc	ra,0x0
 836:	142080e7          	jalr	322(ra) # 974 <close>
  return r;
}
 83a:	854a                	mv	a0,s2
 83c:	60e2                	ld	ra,24(sp)
 83e:	6442                	ld	s0,16(sp)
 840:	64a2                	ld	s1,8(sp)
 842:	6902                	ld	s2,0(sp)
 844:	6105                	addi	sp,sp,32
 846:	8082                	ret
    return -1;
 848:	597d                	li	s2,-1
 84a:	bfc5                	j	83a <stat+0x34>

000000000000084c <atoi>:

int
atoi(const char *s)
{
 84c:	1141                	addi	sp,sp,-16
 84e:	e422                	sd	s0,8(sp)
 850:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 852:	00054603          	lbu	a2,0(a0)
 856:	fd06079b          	addiw	a5,a2,-48
 85a:	0ff7f793          	andi	a5,a5,255
 85e:	4725                	li	a4,9
 860:	02f76963          	bltu	a4,a5,892 <atoi+0x46>
 864:	86aa                	mv	a3,a0
  n = 0;
 866:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 868:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 86a:	0685                	addi	a3,a3,1
 86c:	0025179b          	slliw	a5,a0,0x2
 870:	9fa9                	addw	a5,a5,a0
 872:	0017979b          	slliw	a5,a5,0x1
 876:	9fb1                	addw	a5,a5,a2
 878:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 87c:	0006c603          	lbu	a2,0(a3)
 880:	fd06071b          	addiw	a4,a2,-48
 884:	0ff77713          	andi	a4,a4,255
 888:	fee5f1e3          	bgeu	a1,a4,86a <atoi+0x1e>
  return n;
}
 88c:	6422                	ld	s0,8(sp)
 88e:	0141                	addi	sp,sp,16
 890:	8082                	ret
  n = 0;
 892:	4501                	li	a0,0
 894:	bfe5                	j	88c <atoi+0x40>

0000000000000896 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 896:	1141                	addi	sp,sp,-16
 898:	e422                	sd	s0,8(sp)
 89a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 89c:	02b57663          	bgeu	a0,a1,8c8 <memmove+0x32>
    while(n-- > 0)
 8a0:	02c05163          	blez	a2,8c2 <memmove+0x2c>
 8a4:	fff6079b          	addiw	a5,a2,-1
 8a8:	1782                	slli	a5,a5,0x20
 8aa:	9381                	srli	a5,a5,0x20
 8ac:	0785                	addi	a5,a5,1
 8ae:	97aa                	add	a5,a5,a0
  dst = vdst;
 8b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 8b2:	0585                	addi	a1,a1,1
 8b4:	0705                	addi	a4,a4,1
 8b6:	fff5c683          	lbu	a3,-1(a1)
 8ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 8be:	fee79ae3          	bne	a5,a4,8b2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 8c2:	6422                	ld	s0,8(sp)
 8c4:	0141                	addi	sp,sp,16
 8c6:	8082                	ret
    dst += n;
 8c8:	00c50733          	add	a4,a0,a2
    src += n;
 8cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 8ce:	fec05ae3          	blez	a2,8c2 <memmove+0x2c>
 8d2:	fff6079b          	addiw	a5,a2,-1
 8d6:	1782                	slli	a5,a5,0x20
 8d8:	9381                	srli	a5,a5,0x20
 8da:	fff7c793          	not	a5,a5
 8de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 8e0:	15fd                	addi	a1,a1,-1
 8e2:	177d                	addi	a4,a4,-1
 8e4:	0005c683          	lbu	a3,0(a1)
 8e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8ec:	fee79ae3          	bne	a5,a4,8e0 <memmove+0x4a>
 8f0:	bfc9                	j	8c2 <memmove+0x2c>

00000000000008f2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8f2:	1141                	addi	sp,sp,-16
 8f4:	e422                	sd	s0,8(sp)
 8f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8f8:	ca05                	beqz	a2,928 <memcmp+0x36>
 8fa:	fff6069b          	addiw	a3,a2,-1
 8fe:	1682                	slli	a3,a3,0x20
 900:	9281                	srli	a3,a3,0x20
 902:	0685                	addi	a3,a3,1
 904:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 906:	00054783          	lbu	a5,0(a0)
 90a:	0005c703          	lbu	a4,0(a1)
 90e:	00e79863          	bne	a5,a4,91e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 912:	0505                	addi	a0,a0,1
    p2++;
 914:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 916:	fed518e3          	bne	a0,a3,906 <memcmp+0x14>
  }
  return 0;
 91a:	4501                	li	a0,0
 91c:	a019                	j	922 <memcmp+0x30>
      return *p1 - *p2;
 91e:	40e7853b          	subw	a0,a5,a4
}
 922:	6422                	ld	s0,8(sp)
 924:	0141                	addi	sp,sp,16
 926:	8082                	ret
  return 0;
 928:	4501                	li	a0,0
 92a:	bfe5                	j	922 <memcmp+0x30>

000000000000092c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 92c:	1141                	addi	sp,sp,-16
 92e:	e406                	sd	ra,8(sp)
 930:	e022                	sd	s0,0(sp)
 932:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 934:	00000097          	auipc	ra,0x0
 938:	f62080e7          	jalr	-158(ra) # 896 <memmove>
}
 93c:	60a2                	ld	ra,8(sp)
 93e:	6402                	ld	s0,0(sp)
 940:	0141                	addi	sp,sp,16
 942:	8082                	ret

0000000000000944 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 944:	4885                	li	a7,1
 ecall
 946:	00000073          	ecall
 ret
 94a:	8082                	ret

000000000000094c <exit>:
.global exit
exit:
 li a7, SYS_exit
 94c:	4889                	li	a7,2
 ecall
 94e:	00000073          	ecall
 ret
 952:	8082                	ret

0000000000000954 <wait>:
.global wait
wait:
 li a7, SYS_wait
 954:	488d                	li	a7,3
 ecall
 956:	00000073          	ecall
 ret
 95a:	8082                	ret

000000000000095c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 95c:	4891                	li	a7,4
 ecall
 95e:	00000073          	ecall
 ret
 962:	8082                	ret

0000000000000964 <read>:
.global read
read:
 li a7, SYS_read
 964:	4895                	li	a7,5
 ecall
 966:	00000073          	ecall
 ret
 96a:	8082                	ret

000000000000096c <write>:
.global write
write:
 li a7, SYS_write
 96c:	48c1                	li	a7,16
 ecall
 96e:	00000073          	ecall
 ret
 972:	8082                	ret

0000000000000974 <close>:
.global close
close:
 li a7, SYS_close
 974:	48d5                	li	a7,21
 ecall
 976:	00000073          	ecall
 ret
 97a:	8082                	ret

000000000000097c <kill>:
.global kill
kill:
 li a7, SYS_kill
 97c:	4899                	li	a7,6
 ecall
 97e:	00000073          	ecall
 ret
 982:	8082                	ret

0000000000000984 <exec>:
.global exec
exec:
 li a7, SYS_exec
 984:	489d                	li	a7,7
 ecall
 986:	00000073          	ecall
 ret
 98a:	8082                	ret

000000000000098c <open>:
.global open
open:
 li a7, SYS_open
 98c:	48bd                	li	a7,15
 ecall
 98e:	00000073          	ecall
 ret
 992:	8082                	ret

0000000000000994 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 994:	48c5                	li	a7,17
 ecall
 996:	00000073          	ecall
 ret
 99a:	8082                	ret

000000000000099c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 99c:	48c9                	li	a7,18
 ecall
 99e:	00000073          	ecall
 ret
 9a2:	8082                	ret

00000000000009a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 9a4:	48a1                	li	a7,8
 ecall
 9a6:	00000073          	ecall
 ret
 9aa:	8082                	ret

00000000000009ac <link>:
.global link
link:
 li a7, SYS_link
 9ac:	48cd                	li	a7,19
 ecall
 9ae:	00000073          	ecall
 ret
 9b2:	8082                	ret

00000000000009b4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 9b4:	48d1                	li	a7,20
 ecall
 9b6:	00000073          	ecall
 ret
 9ba:	8082                	ret

00000000000009bc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 9bc:	48a5                	li	a7,9
 ecall
 9be:	00000073          	ecall
 ret
 9c2:	8082                	ret

00000000000009c4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 9c4:	48a9                	li	a7,10
 ecall
 9c6:	00000073          	ecall
 ret
 9ca:	8082                	ret

00000000000009cc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 9cc:	48ad                	li	a7,11
 ecall
 9ce:	00000073          	ecall
 ret
 9d2:	8082                	ret

00000000000009d4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 9d4:	48b1                	li	a7,12
 ecall
 9d6:	00000073          	ecall
 ret
 9da:	8082                	ret

00000000000009dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 9dc:	48b5                	li	a7,13
 ecall
 9de:	00000073          	ecall
 ret
 9e2:	8082                	ret

00000000000009e4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 9e4:	48b9                	li	a7,14
 ecall
 9e6:	00000073          	ecall
 ret
 9ea:	8082                	ret

00000000000009ec <symlink>:
.global symlink
symlink:
 li a7, SYS_symlink
 9ec:	48d9                	li	a7,22
 ecall
 9ee:	00000073          	ecall
 ret
 9f2:	8082                	ret

00000000000009f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9f4:	1101                	addi	sp,sp,-32
 9f6:	ec06                	sd	ra,24(sp)
 9f8:	e822                	sd	s0,16(sp)
 9fa:	1000                	addi	s0,sp,32
 9fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 a00:	4605                	li	a2,1
 a02:	fef40593          	addi	a1,s0,-17
 a06:	00000097          	auipc	ra,0x0
 a0a:	f66080e7          	jalr	-154(ra) # 96c <write>
}
 a0e:	60e2                	ld	ra,24(sp)
 a10:	6442                	ld	s0,16(sp)
 a12:	6105                	addi	sp,sp,32
 a14:	8082                	ret

0000000000000a16 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a16:	7139                	addi	sp,sp,-64
 a18:	fc06                	sd	ra,56(sp)
 a1a:	f822                	sd	s0,48(sp)
 a1c:	f426                	sd	s1,40(sp)
 a1e:	f04a                	sd	s2,32(sp)
 a20:	ec4e                	sd	s3,24(sp)
 a22:	0080                	addi	s0,sp,64
 a24:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 a26:	c299                	beqz	a3,a2c <printint+0x16>
 a28:	0805c863          	bltz	a1,ab8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a2c:	2581                	sext.w	a1,a1
  neg = 0;
 a2e:	4881                	li	a7,0
 a30:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a34:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a36:	2601                	sext.w	a2,a2
 a38:	00001517          	auipc	a0,0x1
 a3c:	8d850513          	addi	a0,a0,-1832 # 1310 <digits>
 a40:	883a                	mv	a6,a4
 a42:	2705                	addiw	a4,a4,1
 a44:	02c5f7bb          	remuw	a5,a1,a2
 a48:	1782                	slli	a5,a5,0x20
 a4a:	9381                	srli	a5,a5,0x20
 a4c:	97aa                	add	a5,a5,a0
 a4e:	0007c783          	lbu	a5,0(a5)
 a52:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a56:	0005879b          	sext.w	a5,a1
 a5a:	02c5d5bb          	divuw	a1,a1,a2
 a5e:	0685                	addi	a3,a3,1
 a60:	fec7f0e3          	bgeu	a5,a2,a40 <printint+0x2a>
  if(neg)
 a64:	00088b63          	beqz	a7,a7a <printint+0x64>
    buf[i++] = '-';
 a68:	fd040793          	addi	a5,s0,-48
 a6c:	973e                	add	a4,a4,a5
 a6e:	02d00793          	li	a5,45
 a72:	fef70823          	sb	a5,-16(a4)
 a76:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a7a:	02e05863          	blez	a4,aaa <printint+0x94>
 a7e:	fc040793          	addi	a5,s0,-64
 a82:	00e78933          	add	s2,a5,a4
 a86:	fff78993          	addi	s3,a5,-1
 a8a:	99ba                	add	s3,s3,a4
 a8c:	377d                	addiw	a4,a4,-1
 a8e:	1702                	slli	a4,a4,0x20
 a90:	9301                	srli	a4,a4,0x20
 a92:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a96:	fff94583          	lbu	a1,-1(s2)
 a9a:	8526                	mv	a0,s1
 a9c:	00000097          	auipc	ra,0x0
 aa0:	f58080e7          	jalr	-168(ra) # 9f4 <putc>
  while(--i >= 0)
 aa4:	197d                	addi	s2,s2,-1
 aa6:	ff3918e3          	bne	s2,s3,a96 <printint+0x80>
}
 aaa:	70e2                	ld	ra,56(sp)
 aac:	7442                	ld	s0,48(sp)
 aae:	74a2                	ld	s1,40(sp)
 ab0:	7902                	ld	s2,32(sp)
 ab2:	69e2                	ld	s3,24(sp)
 ab4:	6121                	addi	sp,sp,64
 ab6:	8082                	ret
    x = -xx;
 ab8:	40b005bb          	negw	a1,a1
    neg = 1;
 abc:	4885                	li	a7,1
    x = -xx;
 abe:	bf8d                	j	a30 <printint+0x1a>

0000000000000ac0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 ac0:	7119                	addi	sp,sp,-128
 ac2:	fc86                	sd	ra,120(sp)
 ac4:	f8a2                	sd	s0,112(sp)
 ac6:	f4a6                	sd	s1,104(sp)
 ac8:	f0ca                	sd	s2,96(sp)
 aca:	ecce                	sd	s3,88(sp)
 acc:	e8d2                	sd	s4,80(sp)
 ace:	e4d6                	sd	s5,72(sp)
 ad0:	e0da                	sd	s6,64(sp)
 ad2:	fc5e                	sd	s7,56(sp)
 ad4:	f862                	sd	s8,48(sp)
 ad6:	f466                	sd	s9,40(sp)
 ad8:	f06a                	sd	s10,32(sp)
 ada:	ec6e                	sd	s11,24(sp)
 adc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 ade:	0005c903          	lbu	s2,0(a1)
 ae2:	18090f63          	beqz	s2,c80 <vprintf+0x1c0>
 ae6:	8aaa                	mv	s5,a0
 ae8:	8b32                	mv	s6,a2
 aea:	00158493          	addi	s1,a1,1
  state = 0;
 aee:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 af0:	02500a13          	li	s4,37
      if(c == 'd'){
 af4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 af8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 afc:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 b00:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b04:	00001b97          	auipc	s7,0x1
 b08:	80cb8b93          	addi	s7,s7,-2036 # 1310 <digits>
 b0c:	a839                	j	b2a <vprintf+0x6a>
        putc(fd, c);
 b0e:	85ca                	mv	a1,s2
 b10:	8556                	mv	a0,s5
 b12:	00000097          	auipc	ra,0x0
 b16:	ee2080e7          	jalr	-286(ra) # 9f4 <putc>
 b1a:	a019                	j	b20 <vprintf+0x60>
    } else if(state == '%'){
 b1c:	01498f63          	beq	s3,s4,b3a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 b20:	0485                	addi	s1,s1,1
 b22:	fff4c903          	lbu	s2,-1(s1)
 b26:	14090d63          	beqz	s2,c80 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 b2a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 b2e:	fe0997e3          	bnez	s3,b1c <vprintf+0x5c>
      if(c == '%'){
 b32:	fd479ee3          	bne	a5,s4,b0e <vprintf+0x4e>
        state = '%';
 b36:	89be                	mv	s3,a5
 b38:	b7e5                	j	b20 <vprintf+0x60>
      if(c == 'd'){
 b3a:	05878063          	beq	a5,s8,b7a <vprintf+0xba>
      } else if(c == 'l') {
 b3e:	05978c63          	beq	a5,s9,b96 <vprintf+0xd6>
      } else if(c == 'x') {
 b42:	07a78863          	beq	a5,s10,bb2 <vprintf+0xf2>
      } else if(c == 'p') {
 b46:	09b78463          	beq	a5,s11,bce <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 b4a:	07300713          	li	a4,115
 b4e:	0ce78663          	beq	a5,a4,c1a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b52:	06300713          	li	a4,99
 b56:	0ee78e63          	beq	a5,a4,c52 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 b5a:	11478863          	beq	a5,s4,c6a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b5e:	85d2                	mv	a1,s4
 b60:	8556                	mv	a0,s5
 b62:	00000097          	auipc	ra,0x0
 b66:	e92080e7          	jalr	-366(ra) # 9f4 <putc>
        putc(fd, c);
 b6a:	85ca                	mv	a1,s2
 b6c:	8556                	mv	a0,s5
 b6e:	00000097          	auipc	ra,0x0
 b72:	e86080e7          	jalr	-378(ra) # 9f4 <putc>
      }
      state = 0;
 b76:	4981                	li	s3,0
 b78:	b765                	j	b20 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 b7a:	008b0913          	addi	s2,s6,8
 b7e:	4685                	li	a3,1
 b80:	4629                	li	a2,10
 b82:	000b2583          	lw	a1,0(s6)
 b86:	8556                	mv	a0,s5
 b88:	00000097          	auipc	ra,0x0
 b8c:	e8e080e7          	jalr	-370(ra) # a16 <printint>
 b90:	8b4a                	mv	s6,s2
      state = 0;
 b92:	4981                	li	s3,0
 b94:	b771                	j	b20 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b96:	008b0913          	addi	s2,s6,8
 b9a:	4681                	li	a3,0
 b9c:	4629                	li	a2,10
 b9e:	000b2583          	lw	a1,0(s6)
 ba2:	8556                	mv	a0,s5
 ba4:	00000097          	auipc	ra,0x0
 ba8:	e72080e7          	jalr	-398(ra) # a16 <printint>
 bac:	8b4a                	mv	s6,s2
      state = 0;
 bae:	4981                	li	s3,0
 bb0:	bf85                	j	b20 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 bb2:	008b0913          	addi	s2,s6,8
 bb6:	4681                	li	a3,0
 bb8:	4641                	li	a2,16
 bba:	000b2583          	lw	a1,0(s6)
 bbe:	8556                	mv	a0,s5
 bc0:	00000097          	auipc	ra,0x0
 bc4:	e56080e7          	jalr	-426(ra) # a16 <printint>
 bc8:	8b4a                	mv	s6,s2
      state = 0;
 bca:	4981                	li	s3,0
 bcc:	bf91                	j	b20 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 bce:	008b0793          	addi	a5,s6,8
 bd2:	f8f43423          	sd	a5,-120(s0)
 bd6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 bda:	03000593          	li	a1,48
 bde:	8556                	mv	a0,s5
 be0:	00000097          	auipc	ra,0x0
 be4:	e14080e7          	jalr	-492(ra) # 9f4 <putc>
  putc(fd, 'x');
 be8:	85ea                	mv	a1,s10
 bea:	8556                	mv	a0,s5
 bec:	00000097          	auipc	ra,0x0
 bf0:	e08080e7          	jalr	-504(ra) # 9f4 <putc>
 bf4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bf6:	03c9d793          	srli	a5,s3,0x3c
 bfa:	97de                	add	a5,a5,s7
 bfc:	0007c583          	lbu	a1,0(a5)
 c00:	8556                	mv	a0,s5
 c02:	00000097          	auipc	ra,0x0
 c06:	df2080e7          	jalr	-526(ra) # 9f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 c0a:	0992                	slli	s3,s3,0x4
 c0c:	397d                	addiw	s2,s2,-1
 c0e:	fe0914e3          	bnez	s2,bf6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 c12:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 c16:	4981                	li	s3,0
 c18:	b721                	j	b20 <vprintf+0x60>
        s = va_arg(ap, char*);
 c1a:	008b0993          	addi	s3,s6,8
 c1e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 c22:	02090163          	beqz	s2,c44 <vprintf+0x184>
        while(*s != 0){
 c26:	00094583          	lbu	a1,0(s2)
 c2a:	c9a1                	beqz	a1,c7a <vprintf+0x1ba>
          putc(fd, *s);
 c2c:	8556                	mv	a0,s5
 c2e:	00000097          	auipc	ra,0x0
 c32:	dc6080e7          	jalr	-570(ra) # 9f4 <putc>
          s++;
 c36:	0905                	addi	s2,s2,1
        while(*s != 0){
 c38:	00094583          	lbu	a1,0(s2)
 c3c:	f9e5                	bnez	a1,c2c <vprintf+0x16c>
        s = va_arg(ap, char*);
 c3e:	8b4e                	mv	s6,s3
      state = 0;
 c40:	4981                	li	s3,0
 c42:	bdf9                	j	b20 <vprintf+0x60>
          s = "(null)";
 c44:	00000917          	auipc	s2,0x0
 c48:	6c490913          	addi	s2,s2,1732 # 1308 <malloc+0x57e>
        while(*s != 0){
 c4c:	02800593          	li	a1,40
 c50:	bff1                	j	c2c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 c52:	008b0913          	addi	s2,s6,8
 c56:	000b4583          	lbu	a1,0(s6)
 c5a:	8556                	mv	a0,s5
 c5c:	00000097          	auipc	ra,0x0
 c60:	d98080e7          	jalr	-616(ra) # 9f4 <putc>
 c64:	8b4a                	mv	s6,s2
      state = 0;
 c66:	4981                	li	s3,0
 c68:	bd65                	j	b20 <vprintf+0x60>
        putc(fd, c);
 c6a:	85d2                	mv	a1,s4
 c6c:	8556                	mv	a0,s5
 c6e:	00000097          	auipc	ra,0x0
 c72:	d86080e7          	jalr	-634(ra) # 9f4 <putc>
      state = 0;
 c76:	4981                	li	s3,0
 c78:	b565                	j	b20 <vprintf+0x60>
        s = va_arg(ap, char*);
 c7a:	8b4e                	mv	s6,s3
      state = 0;
 c7c:	4981                	li	s3,0
 c7e:	b54d                	j	b20 <vprintf+0x60>
    }
  }
}
 c80:	70e6                	ld	ra,120(sp)
 c82:	7446                	ld	s0,112(sp)
 c84:	74a6                	ld	s1,104(sp)
 c86:	7906                	ld	s2,96(sp)
 c88:	69e6                	ld	s3,88(sp)
 c8a:	6a46                	ld	s4,80(sp)
 c8c:	6aa6                	ld	s5,72(sp)
 c8e:	6b06                	ld	s6,64(sp)
 c90:	7be2                	ld	s7,56(sp)
 c92:	7c42                	ld	s8,48(sp)
 c94:	7ca2                	ld	s9,40(sp)
 c96:	7d02                	ld	s10,32(sp)
 c98:	6de2                	ld	s11,24(sp)
 c9a:	6109                	addi	sp,sp,128
 c9c:	8082                	ret

0000000000000c9e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c9e:	715d                	addi	sp,sp,-80
 ca0:	ec06                	sd	ra,24(sp)
 ca2:	e822                	sd	s0,16(sp)
 ca4:	1000                	addi	s0,sp,32
 ca6:	e010                	sd	a2,0(s0)
 ca8:	e414                	sd	a3,8(s0)
 caa:	e818                	sd	a4,16(s0)
 cac:	ec1c                	sd	a5,24(s0)
 cae:	03043023          	sd	a6,32(s0)
 cb2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 cb6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 cba:	8622                	mv	a2,s0
 cbc:	00000097          	auipc	ra,0x0
 cc0:	e04080e7          	jalr	-508(ra) # ac0 <vprintf>
}
 cc4:	60e2                	ld	ra,24(sp)
 cc6:	6442                	ld	s0,16(sp)
 cc8:	6161                	addi	sp,sp,80
 cca:	8082                	ret

0000000000000ccc <printf>:

void
printf(const char *fmt, ...)
{
 ccc:	711d                	addi	sp,sp,-96
 cce:	ec06                	sd	ra,24(sp)
 cd0:	e822                	sd	s0,16(sp)
 cd2:	1000                	addi	s0,sp,32
 cd4:	e40c                	sd	a1,8(s0)
 cd6:	e810                	sd	a2,16(s0)
 cd8:	ec14                	sd	a3,24(s0)
 cda:	f018                	sd	a4,32(s0)
 cdc:	f41c                	sd	a5,40(s0)
 cde:	03043823          	sd	a6,48(s0)
 ce2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ce6:	00840613          	addi	a2,s0,8
 cea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cee:	85aa                	mv	a1,a0
 cf0:	4505                	li	a0,1
 cf2:	00000097          	auipc	ra,0x0
 cf6:	dce080e7          	jalr	-562(ra) # ac0 <vprintf>
}
 cfa:	60e2                	ld	ra,24(sp)
 cfc:	6442                	ld	s0,16(sp)
 cfe:	6125                	addi	sp,sp,96
 d00:	8082                	ret

0000000000000d02 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d02:	1141                	addi	sp,sp,-16
 d04:	e422                	sd	s0,8(sp)
 d06:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d08:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d0c:	00000797          	auipc	a5,0x0
 d10:	6247b783          	ld	a5,1572(a5) # 1330 <freep>
 d14:	a805                	j	d44 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 d16:	4618                	lw	a4,8(a2)
 d18:	9db9                	addw	a1,a1,a4
 d1a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 d1e:	6398                	ld	a4,0(a5)
 d20:	6318                	ld	a4,0(a4)
 d22:	fee53823          	sd	a4,-16(a0)
 d26:	a091                	j	d6a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 d28:	ff852703          	lw	a4,-8(a0)
 d2c:	9e39                	addw	a2,a2,a4
 d2e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 d30:	ff053703          	ld	a4,-16(a0)
 d34:	e398                	sd	a4,0(a5)
 d36:	a099                	j	d7c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d38:	6398                	ld	a4,0(a5)
 d3a:	00e7e463          	bltu	a5,a4,d42 <free+0x40>
 d3e:	00e6ea63          	bltu	a3,a4,d52 <free+0x50>
{
 d42:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d44:	fed7fae3          	bgeu	a5,a3,d38 <free+0x36>
 d48:	6398                	ld	a4,0(a5)
 d4a:	00e6e463          	bltu	a3,a4,d52 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d4e:	fee7eae3          	bltu	a5,a4,d42 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 d52:	ff852583          	lw	a1,-8(a0)
 d56:	6390                	ld	a2,0(a5)
 d58:	02059713          	slli	a4,a1,0x20
 d5c:	9301                	srli	a4,a4,0x20
 d5e:	0712                	slli	a4,a4,0x4
 d60:	9736                	add	a4,a4,a3
 d62:	fae60ae3          	beq	a2,a4,d16 <free+0x14>
    bp->s.ptr = p->s.ptr;
 d66:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d6a:	4790                	lw	a2,8(a5)
 d6c:	02061713          	slli	a4,a2,0x20
 d70:	9301                	srli	a4,a4,0x20
 d72:	0712                	slli	a4,a4,0x4
 d74:	973e                	add	a4,a4,a5
 d76:	fae689e3          	beq	a3,a4,d28 <free+0x26>
  } else
    p->s.ptr = bp;
 d7a:	e394                	sd	a3,0(a5)
  freep = p;
 d7c:	00000717          	auipc	a4,0x0
 d80:	5af73a23          	sd	a5,1460(a4) # 1330 <freep>
}
 d84:	6422                	ld	s0,8(sp)
 d86:	0141                	addi	sp,sp,16
 d88:	8082                	ret

0000000000000d8a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d8a:	7139                	addi	sp,sp,-64
 d8c:	fc06                	sd	ra,56(sp)
 d8e:	f822                	sd	s0,48(sp)
 d90:	f426                	sd	s1,40(sp)
 d92:	f04a                	sd	s2,32(sp)
 d94:	ec4e                	sd	s3,24(sp)
 d96:	e852                	sd	s4,16(sp)
 d98:	e456                	sd	s5,8(sp)
 d9a:	e05a                	sd	s6,0(sp)
 d9c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d9e:	02051493          	slli	s1,a0,0x20
 da2:	9081                	srli	s1,s1,0x20
 da4:	04bd                	addi	s1,s1,15
 da6:	8091                	srli	s1,s1,0x4
 da8:	0014899b          	addiw	s3,s1,1
 dac:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 dae:	00000517          	auipc	a0,0x0
 db2:	58253503          	ld	a0,1410(a0) # 1330 <freep>
 db6:	c515                	beqz	a0,de2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 db8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 dba:	4798                	lw	a4,8(a5)
 dbc:	02977f63          	bgeu	a4,s1,dfa <malloc+0x70>
 dc0:	8a4e                	mv	s4,s3
 dc2:	0009871b          	sext.w	a4,s3
 dc6:	6685                	lui	a3,0x1
 dc8:	00d77363          	bgeu	a4,a3,dce <malloc+0x44>
 dcc:	6a05                	lui	s4,0x1
 dce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 dd2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 dd6:	00000917          	auipc	s2,0x0
 dda:	55a90913          	addi	s2,s2,1370 # 1330 <freep>
  if(p == (char*)-1)
 dde:	5afd                	li	s5,-1
 de0:	a88d                	j	e52 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 de2:	00000797          	auipc	a5,0x0
 de6:	55678793          	addi	a5,a5,1366 # 1338 <base>
 dea:	00000717          	auipc	a4,0x0
 dee:	54f73323          	sd	a5,1350(a4) # 1330 <freep>
 df2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 df4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 df8:	b7e1                	j	dc0 <malloc+0x36>
      if(p->s.size == nunits)
 dfa:	02e48b63          	beq	s1,a4,e30 <malloc+0xa6>
        p->s.size -= nunits;
 dfe:	4137073b          	subw	a4,a4,s3
 e02:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e04:	1702                	slli	a4,a4,0x20
 e06:	9301                	srli	a4,a4,0x20
 e08:	0712                	slli	a4,a4,0x4
 e0a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e0c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e10:	00000717          	auipc	a4,0x0
 e14:	52a73023          	sd	a0,1312(a4) # 1330 <freep>
      return (void*)(p + 1);
 e18:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 e1c:	70e2                	ld	ra,56(sp)
 e1e:	7442                	ld	s0,48(sp)
 e20:	74a2                	ld	s1,40(sp)
 e22:	7902                	ld	s2,32(sp)
 e24:	69e2                	ld	s3,24(sp)
 e26:	6a42                	ld	s4,16(sp)
 e28:	6aa2                	ld	s5,8(sp)
 e2a:	6b02                	ld	s6,0(sp)
 e2c:	6121                	addi	sp,sp,64
 e2e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 e30:	6398                	ld	a4,0(a5)
 e32:	e118                	sd	a4,0(a0)
 e34:	bff1                	j	e10 <malloc+0x86>
  hp->s.size = nu;
 e36:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 e3a:	0541                	addi	a0,a0,16
 e3c:	00000097          	auipc	ra,0x0
 e40:	ec6080e7          	jalr	-314(ra) # d02 <free>
  return freep;
 e44:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e48:	d971                	beqz	a0,e1c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e4a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e4c:	4798                	lw	a4,8(a5)
 e4e:	fa9776e3          	bgeu	a4,s1,dfa <malloc+0x70>
    if(p == freep)
 e52:	00093703          	ld	a4,0(s2)
 e56:	853e                	mv	a0,a5
 e58:	fef719e3          	bne	a4,a5,e4a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 e5c:	8552                	mv	a0,s4
 e5e:	00000097          	auipc	ra,0x0
 e62:	b76080e7          	jalr	-1162(ra) # 9d4 <sbrk>
  if(p == (char*)-1)
 e66:	fd5518e3          	bne	a0,s5,e36 <malloc+0xac>
        return 0;
 e6a:	4501                	li	a0,0
 e6c:	bf45                	j	e1c <malloc+0x92>
