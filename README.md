# NATS Event Handler Microservice Template

[![OS Compatibility][platform-badge]](#prerequisites)
 [![Python Compatibility][python-badge]][python] 
 [![Build Status][travis-status]][travis]


This templates provides the initial structure of
a Python-based microservice that allows subscribing
to a subject in NATS and it implements handling the 
matching events that have been published in NATS 
without coupling to the originator of the message. 
This microservice allows high decoupling between 
microservices that expose service interfaces and 
microservices that implement business logic. Since
this microservice also uses message queues by default
it support distributing workloads across multiple 
instances of this microservice.

## Maintainers
- Pedro Guzmán (pedro@subvertic.com)

## Getting Started

Provide an implementation of a class that Extends **AbstractNATSSubscriber**:

```python

from log_management.interfaces import MicroserviceLogger
from messaging import AbstractNATSSubscriber
import asyncio
import json


# -----------------------------------------------------------------------------
# CLASS SAMPLE HANDLER
# -----------------------------------------------------------------------------
class SampleHandler(AbstractNATSSubscriber):

    # -------------------------------------------------------------------------
    # CLASS CONSTRUCTOR
    # -------------------------------------------------------------------------
    def __init__(self,
                 event_loop: asyncio.AbstractEventLoop,
                 logger: MicroserviceLogger,
                 subject: str,
                 queue: str
                 ):
        super().__init__(
            event_loop,
            logger,
            subject,
            queue
        )

    # -------------------------------------------------------------------------
    # METHOD MESSAGE HANDLER
    # -------------------------------------------------------------------------
    async def message_handler(self, message):
        self._logger.info(
            message.data.decode()
        )
        print(message.reply)
        await self.send_reply(
            json.dumps({"message": "This is a message response"}),
            message.reply
        )
```

Now set the environment variables:

```bash
   % export NATS_SERVER='nats://localhost:4222'
   % export NATS_SUBJECT='test'
   % export NATS_QUEUE='workers'
```

Creat an entry point for the listener:

```python

from log_management.syslog_impl import SimpleLogger
import asyncio
import settings

if __name__ == '__main__':

    loop = asyncio.get_event_loop()
    client = SampleHandler(
        event_loop=loop,
        logger=SimpleLogger(),
        subject=settings.NATS_SUBJECT,
        queue=settings.NATS_QUEUE
    )
    loop.run_until_complete(client.start())
    try:
        loop.run_forever()
    finally:
        loop.close()
```

Now run the subscriber locally:

```bash
    % virtualenv -p python3 venv
    % source venv/bin/activate
    % pip install -r requirements.txt
    % python listener.py
```

## Governance

Any updates to existing code will be
reviewed by the Governance team to ensure that there are no compliance or security issues.

## Project Structure

Code must follow the structure described below:

```
NATS-EventListener-Template-Python
  |
  +- src     
       |
       +- log_management
            |
             __init__.py
             interfaces.py 
             syslog_impl.py
            
       +- messaging
            |
             __init__.py
       listener.py
       settings.py
         
    readme.md
    run.sh
```


## Contribution Guidelines

### Prerequisites

- Supported for execution on OSX and LINUX.
- Supported for execution with Python 3.8 and above. [Download.](https://www.python.org/downloads/mac-osx/)
- PyCharm Community or Pro. [Instructions.](https://www.jetbrains.com/toolbox-app/)
- Git. [Instructions.](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- Artifactory token. [Instructions.](https://na.artifactory.swg-devops.com/artifactory/webapp/#/login)  


### Development

If you plan on contributing to NATS-EventListener-Template-Python or simply want to execute it locally you need to set up your development
environment.  Steps are below:

- Download this NATS-EventListener-Template-Python repo via git locally.
```
   > git clone git@github.ibm.com:SoftLayer-SecEng/NATS-EventListener-Template-Python.git
   ```
- Setup `pip` to point to the Artifactory pypi server.
   - The `pip` python package needs to already be installed.
   - You will need a valid artifactory token.
   - Add the following to your `~/.pip/pip.conf` file.

   ```
   [global]
   extra-index-url = https://<w3id>:<artifactory-token>@na.artifactory.swg-devops.com/artifactory/api/pypi/wcp-auditree-pypi-virtual/simple
   ```

- Create a virtual environment (venv) in your FastApi-NATS-Template  repo root folder.
   - The `virtualenv` python package needs to already be installed.
   - Issue the following command:

   ```
   > virtualenv -p python3 venv
   ```

- Activate the virtual environment.
   - Issue the following command:

   ```
   > . ./venv/bin/activate
   ```

- Setup your virtual environment with the appropriate dependencies.
   - Issue the following command:

   ```
   > pip install -r requirements.txt
   ```

- Add env variables: 
 
 ```
   > export NATS_SERVER=nats://localhost:4222
   > export NATS_SUBJECT=subject
   > export NATS_QUEUE=queue

   ```

Once the above steps have been successfully executed, you should be ready to run the listener locally.

### Development tips

- You only need to activate the virtual environment `. ./venv/bin/activate` going
forward to develop/execute locally unless you want to refresh or recycle your virtual
environment.  Details on that are below.
- To deactivate your virtual environment execute `deactivate`.
- At any point you can recycle your virtual environment by executing `rm -rf venv`
and then recreating it as described above.
- This repo is configured to require signed commits for audit/compliance purposes.
Follow the
[signing commits](https://docs.github.com/en/github/authenticating-to-github/signing-commits)
steps outlined to get things setup.

### Creating a Pull Request.
- Before creating a new file or modify an existing one you need to create a new branch for the issue you are working on, 
the name of the branch must represent the new feature or fix you will implement.
```
   > git checkout -b NEW_METHOD_GITHUB

   ```

* Set version
    * Version is broken into 3 parts: MAJOR.MINOR.PATCH: 
    * If fixing a bug then increase the PATCH (i.e. 0.39.4 to 0.39.5).  
    * If adding new functionality then increase the MINOR (i.e. 0.39.4 to 0.40.0).
    * Provide a concise (also itemized) list of changes/additions/improvements.
    * Specify version in the following files:
        * <NATS-EventListener-Template-Python>/CHANGES.md
    * Get examples from the current CHANGES.md to know which tag to use:
        * [NEW]  
        * [FIX] 
        * [IMPROVE]     
        
- Modify or create the *.py file, avoid [code smells.](https://en.wikipedia.org/wiki/Code_smell)
- Run [flake8](https://flake8.pycqa.org/en/latest/)  in order to keep your code clean and free of errors. (Flake8 is also integrated in Travis CI/CD)
```
   > flake8 src


   ```
- Add the new files or new modifications:
```
   > git status
   > git add file_name1
   > git add file_name2

   ```

* Create commit, it  must contain:
    * <NATS-EventListener-Template-Python>/CHANGES.md
    * <NATS-EventListener-Template-Python>/src/[any_folder]/your_new-file.py

```
   > git commit -m "New feature or fix"
  
   ```

- [Rebase](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History) your branch at the end of the code development and resolve conflicts, 
do not merge master branch into yours because it messes up commits order.
- [Squash](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History) commits when several commits have been done during the review.

- Push the changes:

```
   > git push origin branch_name
  
   ```
- Create the [PR](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request) in IBM GitHUB and request for code reviewers.

- Travis will run Flake8 commands to analyze the code, if everything goes as expected you will see a build passed notification in [#seceng-alm-notifications](https://ibm-cloudplatform.slack.com/archives/G01Q97N16LD) slack channel.

- Please request the code owner to merge the code into master branch.

- Travis will also run static code analysis using [sonar scanner](https://sonarqube-seceng.wdc1a.ciocloud.nonprod.intranet.ibm.com) during deployment phase, if you do not have user credentials please request that to project owners.

- You can fix code smells, bugs and vulnerabilities in one new branch and new commit.

## Coding guidelines

We intend to keep the repository contents Pythonic so unless otherwise noted below follow the PEP 8 coding style guide, the Zen of Python
which lives in [PEP 20](https://www.python.org/dev/peps/pep-0020) and [The Hitchhiker's Guide to Python.](https://docs.python-guide.org/writing/style/)

### Amendments to the above:

- Avoid [code smells](https://rules.sonarsource.com/python/type/Code%20Smell).
- Use clear variable names when defining variables.
- Run the linter often: ```> flake8 src```
- Avoid using third party libraries. Use of third party libraries will need to be justified and approved.
- All classes should be named using CamelCase.
- All methods, functions should be named using snake_case.
- All classes should have a descriptive docstring.
- Use single quotes whenever possible when dealing with strings in Python.
- Use double quotes for JSON configuration files.
- Avoid using line continuations (/). If you find that you must use a line continuation then look for a smarter/better way to write that statement of code.
- Use Python [f-Strings](https://realpython.com/python-f-strings/) for string formatting.


[travis]: https://travis.ibm.com/SoftLayer-SecEng/NATS-EventListener-Template-Python
[python-badge]: https://img.shields.io/badge/python-v3.8+-blue.svg
[python]: https://www.python.org/downloads/
[platform-badge]: https://img.shields.io/badge/platform-osx%20|%20linux-orange.svg
[travis-status]: https://travis.ibm.com/SoftLayer-SecEng/NATS-EventListener-Template-Python.svg?token=x1ic6HPpNu2MANxqzqHE&branch=master
[lines-code]: https://sonarqube-seceng.wdc1a.ciocloud.nonprod.intranet.ibm.com/api/project_badges/measure?project=NATS-EventListener-Template-Python&metric=ncloc
[smells]: https://sonarqube-seceng.wdc1a.ciocloud.nonprod.intranet.ibm.com/api/project_badges/measure?project=NATS-EventListener-Template-Python&metric=code_smells
[maintainability]: https://sonarqube-seceng.wdc1a.ciocloud.nonprod.intranet.ibm.com/api/project_badges/measure?project=NATS-EventListener-Template-Python&metric=sqale_rating

