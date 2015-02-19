TracDataExtraction
==================

Requirements:
- curl
- MIME/Lite.pm (libmime-lite-perl)
- AppConfig module (libappconfig-perl)

Scripts (shell and perl) that will:
- 1 download data from trac
- 2. analyse it
- 3. generate clean csv ready for data import 
- 4. Generate e-mails to keep track of changes

Short term improvements:
- DONE 1. generalization
- DONE 2. add script arguments
- 3. move working directory to /tmp 
- 3. auto trac login to fetch data
- 4. add trac user and password encrypted repository 
- 5. sort direction option

Plausible long term improvements:
- Automatic generation of diagrams and reports, instead of manually importing the data and generating the report.
