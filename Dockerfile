FROM golang:1-alpine AS builder
RUN apk --no-cache add ca-certificates git
WORKDIR /go/src/smtpw/
COPY . .
RUN go get
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -installsuffix cgo -ldflags '-extldflags "-static"' -o smtpw

FROM scratch
LABEL MAINTAINER Jethro van Ginkel <info@itshosted.nl>
WORKDIR /app
COPY --from=builder /go/src/smtpw/smtpw /app/
ENTRYPOINT ["./smtpw"]
