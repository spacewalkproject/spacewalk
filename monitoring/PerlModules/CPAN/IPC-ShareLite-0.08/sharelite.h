
/* Default shared memory segment size.  Each segment is the *
 * same size.  Maximum size is system-dependent (SHMMAX).   */
#define SHM_SEGMENT_SIZE 65536

/* Maximum value of a semaphore.  This is system-dependent (SEMVMX). */
#define MAX_SEM 32766

/* Lock constants used internally by us.  They happen to be the same *
 * as for flock(), but that's purely coincidental                    */
#define LOCK_SH 1
#define LOCK_EX 2
#define LOCK_NB 4
#define LOCK_UN 8

/* Structure at the top of every shared memory segment. *
 * next_shmid is used to construct a linked-list of     *
 * segments.  length is unused, except for the first    *
 * segment.                                             */ 
typedef struct {
  key_t        next_shmid;
  int          length;
  unsigned int shm_state;
  unsigned int version;
} Header;

/* Structure for the per-process segment list.  This list    *
 * is similar to the shared memory linked-list, but contains *
 * the actual shared memory addresses returned from the      *
 * shmat() calls.  Since the addresses are mapped into each  *
 * process's data segment, we cannot make them global.       *
 * This linked-list may be shorter than the shared memory    *
 * linked-list -- nodes are added on to this list on an      *
 * as-needed basis                                           */
typedef struct node {
  int         shmid;
  Header      *shmaddr;
  struct node *next;
} Node;

/* The primary structure for this library.  We pass this back *
 * and forth to perl                                          */
typedef struct {
  key_t        key;
  key_t        next_key;
  int          segment_size;
  int          data_size;
  int          flags;
  int          semid;
  short        lock;
  Node         *head;
  Node         *tail;
  unsigned int shm_state;
  unsigned int version;
} Share;                

/* prototypes */

int   write_share(Share *share, char *data, int length);
Share *new_share(key_t key, int segment_size, int flags);
int   read_share(Share *share, char **data);
int   sharelite_lock(Share *share, int flags); 
int   sharelite_unlock(Share *share);
int   destroy_share (Share *share, int rmid);
