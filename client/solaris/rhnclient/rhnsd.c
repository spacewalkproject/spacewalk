/*
 * Copright (C) 2000, Red Hat, Inc.
 *
 * Author:
 *	Cristian Gafton <gafton@redhat.com>
 *
 * Distributed under GPL
 * $Id: rhnsd.c,v 1.8 2005/02/09 20:40:29 jmartin Exp $
 */

#ifdef linux
#include <features.h>
#endif
/*
  Sun systems have getopt_long in libiberty but 
  don't provide the proper getopt.h header so use a local version.
*/
#if ( defined (__SVR4) && defined (__sun) )
#include "getopt.h"
#else
#include <getopt.h>
#endif
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <errno.h>
#ifdef linux
#include <error.h>
#endif 
#ifdef _NO_GETTEXT
#define gettext(x) (x)
#else
#include <libintl.h>
#endif
#include <locale.h>
#include <syslog.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <time.h>


/* gettext stuff */
#define N_(msgid)	(msgid)
#define _(msgid)	gettext(msgid)
#define x_strdup(s)	(s ? strdup(s) : NULL)

/* Pid management functions */
static int check_pid (const char *file);
static int write_pid (const char *file);




/* Short description of program.  */
static const char doc[] = N_("Spacewalk Services Daemon");
#define PROGRAM		"rhnsd"
#define VERSION		"1.0.3"

static void print_version (FILE *stream);


/* Other functions */
static void termination_handler (int);
static int rhn_init(void);
static int rhn_do_action(void);

/* Arguments */
#define MIN_INTERVAL  1         /* minimal sane interval; RHN will blacklist
				   if lower, so don't think you can recompile
				   with a lower value than this. */

static int foreground = 0;       /* run in foreground */
static int interval = 240;       /* check RHN every interval minutes */
static int verbose = 0;          /* how verbose should we be */

static void
usage()
{
  char * usagestring;
  usagestring = "Usage: rhnsd [OPTION...] \n\
Spacewalk Services Daemon \n\
 \n\
  -f, --foreground           Run in foreground \n\
  -i, --interval=MINS        Connect to Spacewalk every MINS minutes \n\
  -v, --verbose              Log all actions to syslog \n\
  -h, --help                 Give this help list \n\
  -u, --usage                Give this help list \n\
  -V, --version              Print program version \n\
 \n\
Mandatory or optional arguments to long options are also mandatory or optional \n\
for any corresponding short options.\n";  
  fprintf(stderr, usagestring);
}

int main (int argc, char **argv)
{
    int pass_count = 0;
    int last_run_duration = 0;

    int c;
    /* Only root can run us */
    if (getuid() != 0) {
	fprintf(stderr, _("Only root can run this program\n"));
	exit(-1);
    }
    
    /* PORTME: I bet solaris has this, but I wouldnt hold my breath for
       old aix or hpux. */
    /* Set locale via LC_ALL.  */
    setlocale(LC_ALL, "");

#ifndef _NO_GETTEXT
    /* Set the text message domain.  */
    bindtextdomain(PROGRAM, "/usr/share/locale");
    textdomain(PROGRAM);
#endif

    while ( 1 )
      {
	int option_index = 0;
	static struct option long_options[] = {
	  {"verbose", 0, NULL, 'v'},
	  {"interval", 1, NULL, 'i'},
	  {"usage", 0, NULL, 'u'},
	  {"help", 0, NULL, 'h'},
	  {"foreground", 0, NULL, 'f'},
	  {"version", 0, NULL, 'V'},
	  {0, 0, 0, 0}
	};

	c = getopt_long (argc, argv, "Vvuhfi:",
			 long_options, &option_index);

	if (c == -1)
	  break;
	
	switch (c) {
	case 'v':
	  verbose++;
	  break;
	case 'u':
	case 'h':
	  usage();
	  exit (EXIT_SUCCESS);
	  break;
	case 'f':
	  foreground++;
	  break;
	case 'i':
	  interval = atoi(optarg);
	  if (interval < MIN_INTERVAL) {
	    interval = MIN_INTERVAL;
	    syslog(LOG_WARNING, "you cannot specify a minimum interval less than %d, interval adjusted.", MIN_INTERVAL);
	  }	    
	  break;
	case 'V':
	  print_version(stderr);
	  exit (EXIT_SUCCESS);
	  break;
	default:
	  exit (EXIT_FAILURE);
	  break;
	}
      }
	  
    /* Check if we are already running. */
    if (check_pid (PATH_RHNDPID)) {
#ifndef linux
       fprintf(stderr, "%s\n", _("already running"));
       exit (EXIT_FAILURE);
#else
        error (EXIT_FAILURE, 0, _("already running"));
#endif
    }

    if (!foreground) {
	int i;

	if (fork ())
	    exit (0);

	for (i = 0; i < getdtablesize(); i++)
	    close (i);

	if (fork ())
	    exit (0);

	setsid();

	chdir ("/");

	openlog ("rhnsd", LOG_CONS | LOG_ODELAY | LOG_PID, LOG_DAEMON);

	if (write_pid(PATH_RHNDPID) < 0)
	    syslog(LOG_ERR, "unable to write %s: %m", PATH_RHNDPID);

	/* Ignore job control signals.  */
	signal (SIGTTOU, SIG_IGN);
	signal (SIGTTIN, SIG_IGN);
	signal (SIGTSTP, SIG_IGN);
    }

    signal (SIGINT, termination_handler);
    signal (SIGQUIT, termination_handler);
    signal (SIGTERM, termination_handler);
    signal (SIGPIPE, SIG_IGN);

    /* Init databases.  */
    rhn_init();
    
    while(1) {
	time_t rhn_check_start_time;
	time_t sleep_until = interval * 60 + time(NULL) - last_run_duration;
	/* every 12 passes (24 hours with default interval), perturb the
	 * checkin counter slightly so as to break up cyclical
	 * patterns */
	if (pass_count % 12 == 0) {
	    /* end up with the next sleep being +/- 1/2 interval from last
	     * sleep time */
	    sleep_until += 1.0 * (rand() - RAND_MAX/2.0) * interval * 60.0 / (RAND_MAX * 1.0);
	}

	/* sleep_until could be within one minute of now, thanks to
	 * last_run_duration; so, let's skip one full interval past it
	 * in that case */
	if (sleep_until < time(NULL) + 60)
	    sleep_until += interval * 60;

	/* in case sleep is interrupted by a signal of some kind, keep
	 * trying til we hit our mark */
	while (time(NULL) < sleep_until) {
	    sleep(sleep_until - time(NULL));
	}

	rhn_check_start_time = time(NULL);
	rhn_do_action();

	/* however long it too, reduce that modulo our interval, so
	 * that we know how much to subtract from the next sleep.
	 * this ensures our checkins are aligned properly, even if the
	 * action took many hours to complete.  */

	last_run_duration = (time(NULL) - rhn_check_start_time) % (interval * 60);
	pass_count++;
    }
}

/* Print the version information.  */
static void
print_version (FILE *stream)
{
  fprintf (stream, "rhnsd (%s) %s\n", doc, VERSION);
  fprintf (stream, gettext("\
Copyright (C) %s Red Hat, Inc.\n\
"), "2000");
  fprintf (stream, gettext("\
Written by %s.\n\
"), "Cristian Gafton <gafton@redhat.com>");
}

/* Cleanup.  */
static void termination_handler (int signum)
{
    syslog(LOG_NOTICE, "Exiting");
    
    /* Clean up pid file.  */
    unlink (PATH_RHNDPID);

    exit (EXIT_SUCCESS);
}

/* Returns 1 if the process in pid file FILE is running, 0 if not.  */
static int check_pid (const char *file)
{
    FILE *fp;

    fp = fopen (file, "r");
    if (fp) {
	pid_t pid;
	int n;

#ifdef linux
	n = fscanf (fp, "%d", &pid);
#else
	n = fscanf (fp, "%ld", &pid);
#endif
	fclose (fp);

	if (n != 1 || kill (pid, 0) == 0)
	    return 1;
    }

    return 0;
}

/* Write the current process id to the file FILE.
   Returns 0 if successful, -1 if not.  */
static int write_pid (const char *file)
{
    FILE *fp;
    
    fp = fopen (file, "w");
    if (fp == NULL)
	return -1;

#ifdef linux
    fprintf (fp, "%d\n", getpid ());
#else
    fprintf (fp, "%ld\n", getpid ());
#endif
    if (fflush (fp) || ferror (fp)) {
	fclose(fp);
	return -1;
    }

    fclose (fp);
    return 0;
}

/* XXX: fix me up */
/* perform the initialization for the enless loop */
static int rhn_init(void)
{
    syslog(LOG_NOTICE, "%s starting up.", doc);
    srand(time(NULL) ^ getpid());
    return 0;
}

/* XXX: fill me up */
/* Do all actions we need to do when the timer hits us */
static int rhn_do_action(void)
{
    int child;
    int retval;
    int fds[2];

    /*
     * before we do anything, check if a systemid has been created.
     * if not, we aren't gonna even go through with this.
     */
    if (access(RHN_SYSID, R_OK)) {
	syslog(LOG_DEBUG, "%s does not exist or is unreadable", RHN_SYSID);
	return -1;
    }
    
    /* first, the child will have the stdout redirected */
    if (pipe(fds) != 0) {
	syslog(LOG_ERR, "Could not create pipe for forking process; %m");
	return -1;
    }
    
    if ((child = fork()) == 0) {
	/* Okay, maybe we're too paranoid... */
	char *args[] = { NULL, NULL };
	char *envp[] = { NULL  };

	/* close the read end of the pipe */
	close(fds[0]);
	/* redirect stdout */
	if (fds[1] != STDOUT_FILENO) {
	    dup2(fds[1], STDOUT_FILENO);
	    close(fds[1]);
	}

	/* make sure this child has a stderr */
	dup2(STDOUT_FILENO, STDERR_FILENO);
	
	/* syslog for safekeeping */
	syslog(LOG_DEBUG, "running program %s", RHN_CHECK);
    
	/* exec binary helper */
	args[0] = RHN_CHECK;
	execve(RHN_CHECK, args, envp);
	
	/* should not get here: exit with error */
	syslog(LOG_ERR, "could not execute %s : %s",
	       RHN_CHECK, strerror(errno));
	exit(errno);
    } else if (child > 0) {
	int ret = 1;
	char *buf, buffer[10];
	int bufsize = 0;
	
	buf = malloc(sizeof(buffer));
	if (buf == NULL) {
	    syslog(LOG_ERR, "out of memory");
	    return -1;
	} else {
	    bufsize = sizeof(buffer);
	}
	memset(buf, '\0', bufsize);
	
	close(fds[1]); /* we don't need it */
	
	while (ret > 0) {	    
	    struct timeval tv;
	    fd_set rset;
	        
	    memset(buffer, '\0', sizeof(buffer));
	    tv.tv_sec = 2; /* 2 sec should be fine enough */
	    tv.tv_usec = 0;
	    FD_ZERO(&rset);
	    FD_SET(fds[0], &rset);
	    
	    ret = select(fds[0] + 1, &rset, NULL, NULL, &tv);

	    if (ret < 0) {
		/* error */
		syslog(LOG_ERR, "error in select(): %m");
		printf("returning -1\n");
		free(buf);
		close(fds[0]);
		return -1;
	    } else if (ret > 0) {
		int chars;
		/* now we can read */
		chars = read(fds[0], buffer, sizeof(buffer)-1);
		
		if (chars > 0) {
		    bufsize += chars;
		    buf = realloc(buf, bufsize);
		    strcat(buf, buffer);		
		} else {
		    /* chars is 0, so the remote end of the socket was closed, we
		       can handle this just like a timeout */
		    ret = 0;
		}
	    }

	    if (ret == 0) {
		/* timeout, give the child a chance to finish up */

		ret = waitpid(child, &retval, WNOHANG);
		if (ret == child) {
		    /* huh, status changed, we're done */
		    if (strlen(buffer) > 0)
			syslog(LOG_INFO, "%s returned: %s", RHN_CHECK, buf);
		    free(buf);
		    close(fds[0]); /* plug in fd leak */
		    if (WIFEXITED(retval))
			return WEXITSTATUS(retval);
		    /* should not reach here */
		    return -1;
		} else if (ret == 0) {
		    /* no status, repeat select */
		    ret = 1;
		    continue;
		}
	    } 
	}
		    
	syslog(LOG_WARNING, "caught exceptional exit status from child program");
	/* NOT REACHED */
	/* wait for the kid to finish */
	(void) waitpid(child, &retval, 0);
	free(buf);
	close(fds[0]);
	return -2;
    } else {
	syslog(LOG_ERR, "Could not fork process %s: %m", RHN_CHECK);
	close(fds[0]); 
	close(fds[1]);
	return -1;
    }
    /* notreached */
    close(fds[0]); 
    close(fds[1]);
    return 0;
}
