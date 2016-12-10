[date-display-format 'iso-8601]
[define-syntax (make-global-parameters names)
  [syntax-case names ()
    [(_ first) #'[define first [make-parameter #t]]]
    [(_ first rest ...) #'[begin [make-global-parameters first] [make-global-parameters rest ...]]]]]

[define-namespace-anchor anchor]
[define namespace [namespace-anchor->namespace anchor]]

[define (pad6left str)
  [if [< [string-length str] 6]
    [pad6left [string-append "0" str]]
    str]]

[define-syntax-rule (log-create name)
  [... [define-syntax-rule (name elements ...)
    [when [eval [read [open-input-string [string-append "[*" [symbol->string 'name] "*]"]]] namespace]
      [begin
        [let ([curr [current-date]])
          [write [list
            [string->symbol
              [format "~a.~a" [date->string curr #t]
                [pad6left [format "~a" [exact-round [/ [date*-nanosecond curr] 1000]]]]]]
            'name elements ...] [current-error-port]]]
        [displayln ""]]]]]]

[define-syntax (create-loggers stx)
  [syntax-case stx ()
    [(_ first) #'[log-create first]]
    [(_ first rest ...) #'[begin [log-create first] [create-loggers rest ...]]]]]

[make-global-parameters *trce* *dbug* *info* *warn* *erro* *crit*]
[create-loggers crit erro warn info dbug trce]
