#lang racket
(require racket/gui)

(define BLOCKS_WIDTH 20)
(define BLOCKS_HEIGHT 20)
(define BLOCK_SIZE 16)
(define cobra (list (list 2 1) (list 1 1)))
(define direction 'r)
(define pepsi (list 9 8))
(define pontos 0)
(define (move-bloco x y)
  (reverse (append (cdr (reverse cobra)) (list(list x y)))))
(define (pega-cabeca posicao lst)
  (list-ref (list-ref lst 0) posicao))
(define (draw-block screen x y color)
  (send screen set-brush color 'solid)
  (send screen draw-rectangle (* x BLOCK_SIZE) (* y BLOCK_SIZE) BLOCK_SIZE BLOCK_SIZE))
(define (move-cobra posicao)
  (case posicao
    ['l (set! cobra (move-bloco (- (pega-cabeca 0 cobra) 1) (pega-cabeca 1 cobra)))]
    ['r (set! cobra (move-bloco (+ (pega-cabeca 0 cobra) 1) (pega-cabeca 1 cobra)))]
    ['u (set! cobra (move-bloco (pega-cabeca 0 cobra) (- (pega-cabeca 1 cobra) 1)))]
    ['d (set! cobra (move-bloco (pega-cabeca 0 cobra) (+ (pega-cabeca 1 cobra) 1)))]))
(define (encostou-bloco cobra bloco [i 0] [g 666])
  (if (> (length cobra) i)  ; length (cobra) > i
    (if (and (not (= g i)) (and
      (eq? (list-ref (list-ref cobra i) 0) (list-ref bloco 0)) ; verifica pelo x e pelo y
      (eq? (list-ref (list-ref cobra i) 1) (list-ref bloco 1))))
        #t
      (encostou-bloco cobra bloco (+ i 1) g))
    #f))
(define cresce-cobra (lambda ()
  (define x (car (reverse cobra)))
  (set! pepsi (list (inexact->exact (round (* (random) (- BLOCKS_WIDTH 1)))) (inexact->exact (round (* (random) (- BLOCKS_HEIGHT 1)))) ))
  (move-cobra direction)
  (set! pontos (add1 pontos))
  (set! cobra (append cobra (list x)))))
(define restart (lambda()
  (set! direction 'r)
  (set! pepsi (list 9 8))
  (set! cobra (list (list 2 1) (list 1 1)))
  (set! pontos 0)
))
(define frame (new frame%
  [label "Cobra"]
  [width (* BLOCKS_WIDTH BLOCK_SIZE)]
  [height (* BLOCKS_HEIGHT BLOCK_SIZE)]))
(define (canvas-key frame) (class canvas%
  (define/override (on-char key-event)
    (match (send key-event get-key-code)
      ['left  (set! direction 'l)]
      ['right (set! direction 'r)]
      ['up    (set! direction 'u)]
      ['down  (set! direction 'd)]
      ['#\r   (restart)]
      [_ [void]]))
  (super-new [parent frame])))
(define atualiza-cobra (lambda ()
  (draw-block dc (list-ref pepsi 0) (list-ref pepsi 1) "blue") ; desenha a pepsi
  (cond [(encostou-bloco cobra pepsi) (cresce-cobra)] [else (move-cobra direction)]) ; checa por colisão com a pepsi
  (send dc draw-text (number->string pontos) (-(* BLOCKS_WIDTH BLOCK_SIZE) 30) 10)
  (for ([block cobra]) (
    if (eq? block (car cobra))
      (draw-block dc (list-ref block 0) (list-ref block 1) "white")
      (draw-block dc (list-ref block 0) (list-ref block 1) "white")))))
(define lost-the-gaem (lambda ()
  (send dc draw-text "you just lost the game" (- (round (/ (* BLOCKS_WIDTH BLOCK_SIZE) 2)) 110) (- (round (/ (* BLOCKS_HEIGHT BLOCK_SIZE) 2)) 20))
  (send dc draw-text "(press r to restart)" (- (round (/ (* BLOCKS_WIDTH BLOCK_SIZE) 2)) 100) (- (round (/ (* BLOCKS_HEIGHT BLOCK_SIZE) 2)) 0))
))
(define canvas (
  new (canvas-key frame)))
(define dc (send canvas get-dc))
(send dc set-font (make-object font% 12 'modern))
(send dc set-text-foreground "white")
(send frame show #t)
(define timer (new timer%
  [notify-callback (lambda()
    (send dc clear)
    (send dc set-brush "black" 'solid)
    (send dc draw-rectangle 0 0 (* BLOCKS_WIDTH BLOCK_SIZE) (* BLOCKS_HEIGHT BLOCK_SIZE))
    (define colisao #f)
    (for ([block cobra]
         [j (in-naturals 0)])
      (cond
            [(or (> (list-ref block 0) BLOCKS_WIDTH) (> 0 (list-ref block 0))) (set! colisao #t )]
            [(or (> (list-ref block 1) BLOCKS_HEIGHT) (> 0 (list-ref block 1))) (set! colisao #t)]
            [(eq? #f colisao) (set! colisao (eq? #t (encostou-bloco cobra block 0 j)))]))
    (if colisao (lost-the-gaem) (atualiza-cobra)))]
  [interval #f]))
(send timer start 100)
