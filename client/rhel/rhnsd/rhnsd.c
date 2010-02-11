/*
 * Copright (C) 2000--2010 Red Hat, Inc.
 *
 * Author:
 *	Cristian Gafton <gafton@redhat.com>
 *
 * Distributed under GPLv2
 * $Id$
 */

#include <features.h>
#include <argp.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <errno.h>
#include <error.h>
#include <libintl.h>
#include <locale.h>
#include <syslog.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <time.h>
#include <limits.h>
#include <regex.h>

#define RHN_CHECK "/usr/sbin/rhn_check" /* XXX: fix me */
#define RHN_UP2DATE "/etc/sysconfig/rhn/up2date"
#define RHNSD_CONFIG_FILE "/etc/sysconfig/rhn/rhnsd"

#define MAX_PATH_SIZE   512

/* gettext stuff */
#define N_(msgid)	(msgid)
#define _(msgid)	gettext(msgid)
#define x_strdup(s)	(s ? strdup(s) : NULL)

/* Pid management functions */
#define _PATH_RHNDPID		"/var/run/rhnsd.pid"
static int check_pid (const char *file);
static int write_pid (const char *file);

/* Name and version of program.  */
static void print_version (FILE *stream, struct argp_state *state);
void (*argp_program_version_hook) (FILE *, struct argp_state *) = print_version;

/* Definitions of arguments for argp functions.  */
static const struct argp_option options[] =
{
    { "interval", 'i', N_("MINS"), 0,
      N_("Connect to Red Hat Network every MINS minutes") },
    { "foreground", 'f', NULL, 0,
      N_("Run in foreground") },
    { NULL, 0, NULL, 0, NULL }
};

/* Short description of program.  */
static const char doc[] = N_("Red Hat Network Services Daemon");
#define PROGRAM		"rhnsd"
#ifndef VERSION
#define VERSION		"unknown"
#endif

/* Configuration parameters */
static const char* param_name_interval = "interval";

typedef struct _config_param
{
    char *key;
    char *data;
} config_param;


/* Prototype for option handler.  */
static error_t parse_opt __P ((int key, char *arg, struct argp_state *state));

/* Data structure to communicate with argp functions.  */
static struct argp argp = {
    options, parse_opt, NULL, doc,
};

/* Other functions */
static void termination_handler (int);
static int rhn_init(void);
static int rhn_do_action(void);
static void read_configuration();
static void setInterval(char *arg);

static int parse_systemid_path(char* systemid_path, int systemid_path_length);

static void set_signal_handlers (void);
static void unset_signal_handlers (void);
static void SIGHUP_handler(int);

/* Arguments */
#define MIN_INTERVAL  60         /* minimal sane interval; RHN will blacklist
				   if lower, so don't think you can recompile
				   with a lower value than this. */

static int foreground = 0;       /* run in foreground */
static int interval = 240;       /* check RHN every interval minutes */

int main (int argc, char **argv)
{
    int remaining;
    int pass_count = 0;
    int last_run_duration = 0;

    /* Only root can run us */
    if (getuid() != 0) {
	fprintf(stderr, _("Only root can run this program\n"));
	exit(-1);
    }

    /* Set locale via LC_ALL.  */
    setlocale(LC_ALL, "");

    /* Set the text message domain.  */
    bindtextdomain(PROGRAM, "/usr/share/locale");
    textdomain(PROGRAM);

    /* Read default configuration file and allow command line
     * options to override initial configuration file entries
     **/
    read_configuration();

    /* Parse and process arguments.  */
    argp_parse(&argp, argc, argv, 0, &remaining, NULL);

    if (remaining != argc) {
	error(0, 0, gettext("wrong number of arguments"));
	argp_help(&argp, stdout, ARGP_HELP_SEE, PROGRAM);
	exit (EXIT_FAILURE);
    }

    /* Check if we are already running. */
    if (check_pid (_PATH_RHNDPID))
	error (EXIT_FAILURE, 0, _("already running"));

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

	if (write_pid(_PATH_RHNDPID) < 0)
	    syslog(LOG_ERR, "unable to write %s: %m", _PATH_RHNDPID);

	/* Ignore job control signals.  */
	signal (SIGTTOU, SIG_IGN);
	signal (SIGTTIN, SIG_IGN);
	signal (SIGTSTP, SIG_IGN);
    }

    set_signal_handlers ();

    /* Init databases.  */
    rhn_init();

    while(1) {
	time_t rhn_check_start_time;
	time_t sleep_until = interval * 60 + time(NULL) - last_run_duration;
	/* every 12 passes (48 hours with default interval), perturb the
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



/* Handle program arguments.  */
static error_t
parse_opt (int key, char *arg, struct argp_state *state)
{
    switch (key) {
	case 'f':
	    /* --foreground */
	    foreground++;
	    break;

	case 'i':
	    /* --interval */
	    setInterval(arg);
	    break;

	default:
	    return ARGP_ERR_UNKNOWN;
    }

    return 0;
}

/* Print the version information.  */
static void
print_version (FILE *stream, struct argp_state *state)
{
  fprintf (stream, "rhnsd (%s) %s\n", doc, VERSION);
  fprintf (stream, gettext("\
Copyright (C) %s Red Hat, Inc.\n\
"), "2000--2010");
  fprintf (stream, gettext("\
Written by %s.\n\
"), "Cristian Gafton <gafton@redhat.com>");
}

/* Cleanup.  */
static void termination_handler (int signum)
{
    syslog(LOG_NOTICE, "Exiting");

    /* Clean up pid file.  */
    unlink (_PATH_RHNDPID);

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

	n = fscanf (fp, "%d", &pid);
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

    fprintf (fp, "%d\n", getpid ());
    if (fflush (fp) || ferror (fp)) {
	fclose(fp);
	return -1;
    }

    fclose (fp);
    return 0;
}

static void
set_signal_handlers (void)
{
    signal (SIGINT, termination_handler);
    signal (SIGQUIT, termination_handler);
    signal (SIGTERM, termination_handler);
    signal (SIGPIPE, SIG_IGN);
    signal (SIGHUP, SIGHUP_handler);
}

static void
unset_signal_handlers (void)
{
    signal (SIGINT, SIG_DFL);
    signal (SIGQUIT, SIG_DFL);
    signal (SIGTERM, SIG_DFL);
    signal (SIGPIPE, SIG_DFL);
    signal (SIGHUP, SIG_DFL);
}

/* XXX: fix me up */
/* perform the initialization for the enless loop */
static int rhn_init(void)
{
    syslog(LOG_NOTICE, "%s starting up, check in interval %d minutes.", doc, interval);
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
    char systemid_path[MAX_PATH_SIZE] = {0};

    /*
     * before we do anything, check if a systemid has been created.
     * if not, we aren't gonna even go through with this.
     */

    if (access(RHN_UP2DATE, R_OK))
    {
         syslog(LOG_DEBUG, "%s does not exist or is unreadable", RHN_UP2DATE);
         return -1;
    }

    /* parse the systemid location from the up2date file */
    if (parse_systemid_path(systemid_path, sizeof(systemid_path)))
    {
         syslog(LOG_DEBUG, "%s does not contain valid systemIdPath entry", RHN_UP2DATE);
         return -1;
    }

    if (access(systemid_path, R_OK))
    {
         syslog(LOG_DEBUG, "%s does not exist or is unreadable", systemid_path);
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

        unset_signal_handlers ();
        /* exec binary helper */
        args[0] = RHN_CHECK;
        execv(RHN_CHECK, args);

        /* should not get here: exit with error */
        set_signal_handlers ();
        syslog(LOG_ERR, "could not execute %s : %s", RHN_CHECK,
               strerror(errno));
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



static void setInterval(char *arg)
{
    interval = atoi(arg);
    if (interval < MIN_INTERVAL) {
        interval = MIN_INTERVAL;
        syslog(LOG_WARNING, "you cannot specify a minimum interval less than %d, interval adjusted.", MIN_INTERVAL);
    }
}

static int skipLine(char *line)
{
    if (line == NULL) {
        return 1;
    }
    // Detect a Comment
    if (line[0] == '#') {
        return 1;
    }
    return 0;
}

/*
 * Returns a key/value pair of a configuration item, or NULL.
 * Expected format of config entries is:
 * KEY=VALUE
 */
static config_param *parseLine(char *line)
{
    if (skipLine(line)) {
        return NULL;
    }

    config_param *cp = malloc(sizeof(config_param));
    char delim[] = "=";
    char *dup = strdup(line);
    cp->key = strsep(&dup, delim);
    if (cp->key == NULL) {
        free(dup);
        return NULL;
    }
    int index;
    // Cast all keys to lowercase
    for (index = 0; index < strlen(cp->key); index++) {
        cp->key[index] = tolower(cp->key[index]);
    }

    cp->data = strsep(&dup, delim);
    if (cp->data == NULL) {
        free(dup);
        return NULL;
    }
    free(dup);
    return cp;
}

static void read_configuration()
{
    FILE *config = fopen(RHNSD_CONFIG_FILE, "r");
    if (config == NULL) {
        syslog(LOG_ERR, "Error reading configuraton file, %s", RHNSD_CONFIG_FILE);
        syslog(LOG_ERR, "%s", strerror(errno));
        return;
    }
    char line[LINE_MAX];
    while (fgets(line, LINE_MAX, config) != NULL) {
        config_param *cp = parseLine(line);
        if (cp == NULL) {
            continue;
        }
        if (strncmp(param_name_interval, cp->key, strlen(param_name_interval)) == 0) {
            setInterval(cp->data);
        }
        free(cp);
    }
    fclose(config);
}

static void SIGHUP_handler(int signum)
{
    read_configuration();
    syslog(LOG_NOTICE, "%s reloading, check in interval %d minutes.", doc, interval);
}



#define MAX_CONFIG_LINE_SIZE    (2*MAX_PATH_SIZE)
#define SYSTEMID_NMATCH         2
/* parse systemIdPath from the up2date configuration file */
static int parse_systemid_path(char* systemid_path, int systemid_path_length)
{
    int ret = 1; /* 1 indicates file not found */
    FILE* config_file;
    regex_t re_systemIdPath;
    regmatch_t submatch[SYSTEMID_NMATCH];

    regcomp(&re_systemIdPath,"^[[:space:]]*systemIdPath[[:space:]]*=[[:space:]]*([[:print:]]+)", REG_EXTENDED);
    if (NULL != (config_file = fopen(RHN_UP2DATE, "r") ))
    {
        char line[MAX_CONFIG_LINE_SIZE];
        while (NULL != fgets(line, MAX_CONFIG_LINE_SIZE, config_file))
        {
            if (regexec(&re_systemIdPath, line, SYSTEMID_NMATCH, submatch, 0) != REG_NOMATCH)
            {
                int match_length = submatch[1].rm_eo - submatch[1].rm_so;
                if (systemid_path_length < match_length)
                     match_length = systemid_path_length - 1;

                strncpy(systemid_path, &line[submatch[1].rm_so], match_length);
                systemid_path[match_length] = '\0';
                ret = 0;
                break;
            }
        }
        fclose(config_file);
    }
    return ret;
}

