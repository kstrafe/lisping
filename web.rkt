#lang racket/base


(for/list ([f (in-directory "./posts")]) ; #:when (regexp-match? "\\.rkt$" f))
     [path->string [file-name-from-path f]])

(require (prefix-in dispatch: web-server/dispatch)
         (prefix-in dispatch-log: web-server/dispatchers/dispatch-log)
         (prefix-in xexpr: web-server/http/xexpr)
         (prefix-in servlet: web-server/servlet-env))
(define-values (route-dispatch route-url)
  (dispatch:dispatch-rules
    [("") home-route]
    [("info") info-route]
    [else not-found-route]))
(define (not-found-route request)
  (xexpr:response/xexpr
    `(html (body (h2 "Uh-oh! Page not found.")))))
(define (home-route request)
  (xexpr:response/xexpr
    `(html (body
      (h2 "Why state is harmful")
      (h2 "Look ma, no state!!!!!!!!!")
      (h2 "Another big guy (for u)")
      ))))
(define (info-route request)
  (xexpr:response/xexpr
    `(html
      (body
        (h2 "This is an information page")
        (hr)
        (p "Information will be added here periodically")
        (a ((href ,(route-url home-route))) "Home")
        (p "There are currently no individuals who would like to engage in armed conflicts")
        ))))
(define (route-dispatch/log-middleware req)
  (display (dispatch-log:apache-default-format req))
  (flush-output)
  (route-dispatch req))
(servlet:serve/servlet
  route-dispatch/log-middleware
  #:servlet-path "/"
  #:servlet-regexp #rx""
  #:stateless? #t)
