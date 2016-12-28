#lang racket

[require web-server/servlet web-server/servlet-env]

[define (start req)
  [displayln req]
  [response/xexpr
    `(html (head (title "Hello world"))
           (body (h1 "Wow guys it's amazing!")))]]

[serve/servlet start #:port 8081 #:servlet-path "/main"]

[for/list ([i [for/stream ([i [range 0 1 1/5]]) [sleep i] i]])
  i]

[stream-nth [stream [sleep 1] [begin [sleep 2] [displayln "HEY"]]] 1]

[define (stream-nth stream index)
  [cond
    [(stream-empty? stream) empty]
    [(= index 0) [stream-first stream]]
    [else [stream-nth [stream-rest stream] [sub1 index]]]]]
[stream-nth [stream-map [lambda (x) [expt x 3]] [in-naturals]] 3]
