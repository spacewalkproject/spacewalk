
ORA2PG    := ../../spacewalk-oracle2postgresql

SQL_FILES  := $(shell ls *.sql)
POSTGRESQL_FILES  := $(addsuffix .postgresql,$(SQL_FILES))
ORACLE_FILES  := $(addsuffix .oracle,$(SQL_FILES))

all : $(POSTGRESQL_FILES) $(ORACLE_FILES)

%.sql.postgresql : %.sql
	$(ORA2PG) $^ > $@

%.sql.oracle : %.sql
	ln $^ $@
