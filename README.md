**Note:** *OraRep* is no longer maintained.

### What is OraRep?
OraRep is an Oracle Report Generator, used to create reports about your
database activity statistics in a nice, human readable format - which in this
case is HTML. The generated report provides you with information on the
physical database design (tablespaces, datafiles, memory), users and their
privileges (such as e.g. quotas and profiles), statistical values on your
databases efficiency and more. It is highly configurable concerning the
report elements you need. Due to its modular design, only the needed code
(depending on the options you chose in the config file) will be build and
executed, to save your database from unnecessary load.

### What does OraRep do?
OraRep reads its data out of several system views, such as the `V$`
and `DBA_` views. These data are either presented as-is in a table
(e.g. to list up all tablespaces together with their data files and sizes), or
set in relation to other values to form indicators (such as "percent disk sorts")
for performance analysis. Together with these data, OraRep gives some descriptions
on their meaning as well as ideas what they may point to or what actions are
required from the DBA in order to bring the instance to a more efficient state.
For some issues, even code pieces for possible required actions are given.

### What does OraRep *NOT* do?
OraRep will take no (write) actions to the database (only things that
OraRep writes are the HTML report pages and some temporary files; the latter
ones are automatically removed when the script finishes). It only does report
what it finds in the database plus some general description on those values. It
gives no "perfect solution" to problems that may exist with your instance, just
hints to what may be helpful. It will not repair or tune your database for you:
in order to have this done, you must draw your own conclusions out of the report
results.

Furthermore, OraRep can just report on the statistical data that are present
within the system views at the time the script is run. This does especially
mean, that e.g. "Objects causing Wait Events" are only accidentally displayed
(if there's a session that waits for them at the time the report is gathering
the data on wait objects), since Oracle does not store these data historically.
To get a more precise report on those things, install Oracle Statspack and do
the reporting with [OSPRep](https://github.com/IzzySoft/OSPRep),
another reporting tool from the author of *OraRep.* If you see a need for
tuning your database, this is what I strongly recommend - besides giving you
more precise information on different issues, with Oracle Statspack and OSPRep
you also have the possibility to generate historical reports, to compare your
current performance e.g. with the performance you've had a month ago.
