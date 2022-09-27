
FROM golang:1.14.0-stretch

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY . .

RUN go build ./
VOLUME ./:./

EXPOSE 5000
CMD [ "/shab" ]
