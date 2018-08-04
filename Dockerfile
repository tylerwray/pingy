FROM golang:1.10-alpine as base
WORKDIR /go/src/github.com/tylerwray/pingy
COPY . .
RUN go build

FROM alpine:3.7
WORKDIR /bin
COPY --from=base /go/src/github.com/tylerwray/pingy/pingy .
ENTRYPOINT [ "pingy", "--site", "http://renaissancelogan.com", "--webhook", "https://hooks.slack.com/services/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" ]
