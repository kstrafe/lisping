#lang racket

[require web-server/servlet web-server/servlet-env]

[define (start req)
  [response/xexpr
    `(html (head (title "Hello world"))
           (body (h1 "Wow guys it's amazing!")))]]

[serve/servlet start #:port 8081 #:servlet-path "/main"]
