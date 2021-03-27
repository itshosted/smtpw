FROM golang:1.16 AS builder
WORKDIR /go/src/smtpw/
COPY . .
RUN go get
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-extldflags '-static' -X main.version=$(git describe --always --long --dirty --all)-$(date +%Y-%m-%d-%H:%M)" -o smtpw

FROM scratch
LABEL MAINTAINER Jethro van Ginkel <info@itshosted.nl>
WORKDIR /app
COPY --from=builder /go/src/smtpw/smtpw /app/
CMD ["./smtpw"]
