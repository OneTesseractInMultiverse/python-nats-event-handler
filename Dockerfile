FROM python:3

# Configure non-privileged user
RUN groupadd -r secengex && useradd -r -g secengex secengex

WORKDIR /usr/src/app

COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src .

# Switch to unprivileged user to run the application
USER secengex

CMD [ "python", "./listener.py" ]
