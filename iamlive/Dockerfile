FROM golang:1.22

RUN git clone https://github.com/rulio/iamlive.git /var/local/iamlive

WORKDIR /var/local/iamlive

RUN go install 

WORKDIR /var/app

ENTRYPOINT [ "iamlive", "--mode", "proxy", "--bind-addr","0.0.0.0:10080", "--provider", "aws"]

