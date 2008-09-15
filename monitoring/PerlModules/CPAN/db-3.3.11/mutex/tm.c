/*
 * Standalone mutex tester for Berkeley DB mutexes.
 */
#include "db_config.h"

#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/wait.h>

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "db_int.h"

void exec_one();
void file_init();
void map_file();
void mutex_destroy();
void mutex_init();
void mutex_stats();
void run_one();
void unmap_file();

int	 align;					/* Mutex alignment in file. */
DB_ENV	 dbenv;					/* Fake out DB. */
char	*file = "mutex.file";			/* Backing file. */
size_t	 len;					/* Backing file size. */
int	 maxlocks = 20;				/* -l: Backing locks. */
int	 nlocks = 10000;			/* -n: Locks per processes. */
int	 nprocs = 20;				/* -p: Processes. */
int	 child;					/* -s: Slave. */
int	 verbose;				/* -v: Verbosity. */

int
main(argc, argv)
	int argc;
	char *argv[];
{
	extern int optind;
	extern char *optarg;
	pid_t pid;
	int ch, i, status;

	while ((ch = getopt(argc, argv, "l:n:p:sv")) != EOF)
		switch(ch) {
		case 'l':
			maxlocks = atoi(optarg);
			break;
		case 'n':
			nlocks = atoi(optarg);
			break;
		case 'p':
			nprocs = atoi(optarg);
			break;
		case 's':
			child = 1;
			break;
		case 'v':
			verbose = 1;
			break;
		case '?':
		default:
			(void)fprintf(stderr,
			    "usage: %s [-l maxlocks] [-n locks] [-p procs]\n",
			    argv[0]);
			return (EXIT_FAILURE);
		}
	argc -= optind;
	argv += optind;

	/*
	 * Needed to figure out the file layout.
	 */
	align = ALIGN(sizeof(MUTEX) * 2, MUTEX_ALIGN);
	len = align * maxlocks + sizeof(u_int32_t) * maxlocks;

	/*
	 * Hack DBENV to work.
	 */
	dbenv.db_mutexlocks = 1;

	if (child) {
		run_one();
		return (EXIT_SUCCESS);
	}

	file_init();
	mutex_init();

	printf("Run: %d processes (%d requests from %d locks):",
	    nprocs, nlocks, maxlocks);
	for (i = 0; i < nprocs; ++i)
		switch (pid = fork()) {
		case -1:
			perror("fork");
			return (EXIT_FAILURE);
		case 0:
			exec_one();
			break;
		default:
			printf(" %lu", (u_long)pid);
			break;
		}
	printf("\n");

	while ((pid = wait(&status)) != (pid_t)-1)
		printf("%d: exited %d\n", pid, WEXITSTATUS(status));
	fflush(stdout);

	printf("Statistics...\n");
	mutex_stats();

	mutex_destroy();

	return (EXIT_SUCCESS);
}

void
exec_one()
{
	char *argv[10], **ap, b_l[10], b_n[10];

	ap = &argv[0];
	*ap++ = "tm";
	sprintf(b_l, "-l%d", maxlocks);
	*ap++ = b_l;
	sprintf(b_n, "-n%d", nlocks);
	*ap++ = b_n;
	*ap++ = "-s";
	if (verbose)
		*ap++ = "-v";
	*ap = NULL;
	execv("./tm", argv);

	fprintf(stderr, "./tm: %s\n", strerror(errno));
	exit(EXIT_FAILURE);
}

void
run_one()
{
	MUTEX *maddr, *mp;
	pid_t pid, *pidlist;
	int fd, i, lock, remap;
	char buf[128];

	__os_sleep(&dbenv, 3, 0);		/* Let everyone catch up. */

	pid = getpid();
	srand((u_int)time(NULL) / pid);

	for (maddr = NULL, pidlist = NULL, remap = 0;;) {
		if (maddr == NULL) {
			map_file(&maddr, &fd);
			pidlist =
			    (pid_t *)((u_int8_t *)maddr + align * maxlocks);
			remap = (rand() % 100) + 35;

			if (verbose)
				printf("%lu: map @ %lx\n",
				    (u_long)pid, (u_long)maddr);
		}

		lock = rand() % maxlocks;
		if (verbose) {
			(void)sprintf(buf,
			    "%lu %lu:\n", (u_long)pid, (u_long)lock);
			write(1, buf, strlen(buf));
		}
		mp = (MUTEX *)((u_int8_t *)maddr + lock * align);
		if (__db_mutex_lock(&dbenv, mp, fd)) {
			fprintf(stderr, "%lu: never got lock\n", (u_long)pid);
			exit(EXIT_FAILURE);
		}
		if (pidlist[lock] != 0) {
			fprintf(stderr,
			    "RACE! (%lu granted lock %d held by %lu)\n",
			    (u_long)pid, lock, (u_long)pidlist[lock]);
			exit(EXIT_FAILURE);
		}
		pidlist[lock] = pid;
		for (i = 0; i < 3; ++i) {
			__os_sleep(&dbenv, 0, rand() % 50);
			if (pidlist[lock] != pid) {
				fprintf(stderr,
				    "RACE! (%lu stole lock %d from %lu)\n",
				    (u_long)pidlist[lock], lock, (u_long)pid);
				exit(EXIT_FAILURE);
			}
		}
		pidlist[lock] = 0;
		if (__db_mutex_unlock(&dbenv, mp)) {
			fprintf(stderr, "%d: wakeup failed\n", pid);
			exit(EXIT_FAILURE);
		}

		if (--remap == 0 || --nlocks == 0) {
			unmap_file(maddr, fd);
			maddr = NULL;
			if (verbose)
				printf("%lu: unmap\n", (u_long)pid);

			__os_sleep(&dbenv, rand() % 3, 0);

			if (nlocks == 0)
				break;
		}

		if (nlocks % 100 == 0)
			write(1, ".", 1);
	}

	exit(EXIT_SUCCESS);
}

void
file_init()
{
	int fd;

	printf("Initialize the backing file...\n");

	/*
	 * Initialize the backing file.
	 *
	 * Find out how much space we need to correctly align maxlocks locks
	 * plus maxlocks check words and create the file.
	 */
	(void)unlink(file);
	if ((fd = open(file, O_CREAT | O_RDWR | O_TRUNC,
	    S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH)) == -1) {
		(void)fprintf(stderr, "%s: %s\n", file, strerror(errno));
		exit(EXIT_FAILURE);
	}
	if (lseek(fd, (off_t)len, SEEK_SET) != len || write(fd, &fd, 1) != 1) {
		(void)fprintf(stderr,
		    "%s: seek/write: %s\n", file, strerror(errno));
		exit(EXIT_FAILURE);
	}
	(void)close(fd);
}

void
mutex_init()
{
	MUTEX *maddr, *mp;
	int fd, i;

	printf("Initialize the mutexes...\n");
	map_file(&maddr, &fd);
	for (i = 0, mp = maddr;
	    i < maxlocks; ++i, mp = (MUTEX *)((u_int8_t *)mp + align))
		if (__db_mutex_init(&dbenv, mp, 0, 0)) {
			fprintf(stderr, "__db_mutex_init (%d): %s\n",
			    i + 1, strerror(errno));
			exit(EXIT_FAILURE);
		}
	unmap_file(maddr, fd);
}

void
mutex_destroy()
{
	MUTEX *maddr, *mp;
	int fd, i;

	map_file(&maddr, &fd);
	for (i = 0, mp = maddr;
	    i < maxlocks; ++i, mp = (MUTEX *)((u_int8_t *)mp + align))
		if (__db_mutex_destroy(mp)) {
			fprintf(stderr, "__db_mutex_destroy (%d): %s\n",
			    i + 1, strerror(errno));
			exit(EXIT_FAILURE);
		}
	unmap_file(maddr, fd);
}

void
mutex_stats()
{
	MUTEX *maddr, *mp;
	int fd, i;

	map_file(&maddr, &fd);
	for (i = 0, mp = maddr;
	    i < maxlocks; ++i, mp = (MUTEX *)((u_int8_t *)mp + align))
		printf("mutex %2d: wait: %2lu; no wait %2lu\n", i,
		    (u_long)mp->mutex_set_wait, (u_long)mp->mutex_set_nowait);
	unmap_file(maddr, fd);
}

void
map_file(maddrp, fdp)
	MUTEX **maddrp;
	int *fdp;
{
	MUTEX *maddr;
	int fd;

#ifndef MAP_FAILED
#define	MAP_FAILED	(MUTEX *)-1
#endif
#ifndef MAP_FILE
#define	MAP_FILE	0
#endif
	if ((fd = open(file, O_RDWR, 0)) == -1) {
		fprintf(stderr, "%s: open %s\n", file, strerror(errno));
		exit(EXIT_FAILURE);
	}

	maddr = (MUTEX *)mmap(NULL, len,
	    PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, fd, (off_t)0);
	if (maddr == MAP_FAILED) {
		fprintf(stderr, "%s: mmap: %s\n", file, strerror(errno));
		exit(EXIT_FAILURE);
	}

	*maddrp = maddr;
	*fdp = fd;
}

void
unmap_file(maddr, fd)
	MUTEX *maddr;
	int fd;
{
	if (munmap(maddr, len) != 0) {
		fprintf(stderr, "munmap: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
	if (close(fd) != 0) {
		fprintf(stderr, "close: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}
}
