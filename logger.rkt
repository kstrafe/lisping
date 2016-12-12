#lang racket

[provide trce-enabled dbug-enabled info-enabled warn-enabled erro-enabled crit-enabled
         trce         dbug         info         warn         erro         crit]

[require racket/date]
[require [for-syntax racket/syntax]]

[date-display-format 'iso-8601]

[define-syntax-rule (log-create name parameter)
  [... [define-syntax-rule (name elements ...)
    [when [parameter]
      [begin [let ([curr [current-date]])
        [write [list [string->symbol
          [format "~a.~a"
            [date->string curr #t]
            [~a [number->string [exact-round [/ [date*-nanosecond curr] 1000]]] #:min-width 6 #:align 'right #:left-pad-string "0"]]]
        'name elements ...] [current-error-port]]
      [displayln "" [current-error-port]]]]]]]]

[define-syntax (create-loggers names)
  [datum->syntax names
    [cons 'begin [for/list ([logger-name [cdr [syntax->datum names]]])
      [let ([qname [format-symbol "~a-enabled" logger-name]])
        `[begin [log-create ,logger-name ,qname] [define ,qname [make-parameter #t]]]]]] #'srcloc]]

[create-loggers trce dbug info warn erro crit]
