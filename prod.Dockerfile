
FROM golang:1.14.0-stretch

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY . .

RUN go build -o /docker-shab


EXPOSE 5000
CMD [ "/docker-shab" ]
