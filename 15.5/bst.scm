(define (construct-optimal-bst root)
  (let* ((n (car (array-dimensions root)))
         (parents (make-stack (make-vector n #f) -1))
         (iter
          (rec (iter i j)
               (if (> i j)
                   (let ((parent (peek parents)))
                     (format #t "d~A is the ~A of k~A~%"
                             j
                             (if (< j parent)
                                 "left"
                                 "right")
                             parent))
                   (let ((r (array-ref root i j)))
                     (if (empty? parents)
                         (format #t "k~A is the root~%" r)
                         (let ((parent (peek parents)))
                           (format #t "k~A is the of ~A child of k~A~%"
                                   r
                                   (if (< i parent)
                                       "left"
                                       "right")
                                   parent)))
                     (push! parents r)
                     (iter i (- r 1))
                     (iter (+ r 1) j)
                     (pop! parents))))))
    (iter 0 (- n 1))
    (values)))

(define (make-optimal-bst roots)
  (let* ((n (car (array-dimensions roots)))
         (root #f)
         (parents (make-stack (make-vector n #f) -1))
         (iter
          (rec (iter i j)
               (if (> i j)
                   (let ((node (make-node j (format "d~A" j) #f #f #f)))
                     (let* ((parent (peek parents))
                            (r (node-key parent)))
                       (set-node-parent! node parent)
                       (if (< j r)
                           (set-node-left! parent node)
                           (set-node-right! parent node))))
                   (let* ((r (array-ref roots i j))
                          (node (make-node r (format "k~A" r) #f #f #f)))
                     (if (empty? parents)
                         (set! root node)
                         (let* ((parent (peek parents))
                                (r (node-key parent)))
                           (set-node-parent! node parent)
                           (if (< i r)
                               (set-node-left! parent node)
                               (set-node-right! parent node))))
                     (push! parents node)
                     (iter i (- r 1))
                     (iter (+ r 1) j)
                     (pop! parents))))))
    (iter 0 (- n 1))
    root))

(define (memoized-bst p q)
  (let* ((n (car (array-dimensions p)))
         (dim `(-1 ,n)))
    (let ((e (make-array '#(#f) dim dim))
          (w (make-array '#(#f) dim dim))
          (root (make-array '#(#f) dim dim)))
      (let* ((iter-w
              (rec (iter-w i j)
                   (let ((weight (array-ref w i j)))
                     (if weight
                         weight
                         (let ((p (array-ref p j))
                               (q (array-ref q j)))
                           (if (= (- i 1) j)
                               (array-set! w q i j)
                               (array-set! w (+ (iter-w i (- j 1)) p q) i j))
                           (array-ref w i j))))))
             (iter-e
              (rec (iter-e i j)
                   (let ((cost (array-ref e i j)))
                     (if cost
                         cost
                         (begin
                           (array-set! e +inf i j)
                           (if (= (- i 1) j)
                               (begin
                                 (array-set! e (array-ref q j) i j)
                                 (array-ref q j))
                               (begin
                                 (loop ((for r (up-from i (to (+ j 1)))))
                                       (let ((t (+ (iter-e i (- r 1))
                                                   (iter-e (+ r 1) j)
                                                   (iter-w i j))))
                                         (if (< t (array-ref e i j))
                                             (begin
                                               (array-set! e t i j)
                                               (array-set! root r i j)))))
                                 (array-ref e i j)))))))))
        (iter-e 0 (- n 1 1))
        (values e root)))))

(define (optimal-bst p q n)
  (let ((dim `(-1 ,(+ n 1 1))))
    (let ((e (make-array '#(#f) dim dim))
          (w (make-array '#(#f) dim dim))
          (root (make-array '#(#f) dim dim)))
      (loop ((for i (up-from 0 (to (+ n 1 1)))))
            (array-set! e (array-ref q (- i 1)) i (- i 1))
            (array-set! w (array-ref q (- i 1)) i (- i 1)))
      (loop ((for l (up-from 1 (to (+ n 1 1)))))
            (loop ((for i (up-from 0 (to (+ (- n l) 1 1)))))
                  (let ((j (- (+ i l) 1)))
                    (array-set! e +inf i j)
                    (array-set! w (+ (array-ref w i (- j 1))
                                     (array-ref p j)
                                     (array-ref q j)) i j)
                    (loop ((for r (up-from i (to (+ j 1)))))
                          (let ((t (+ (array-ref e i (- r 1))
                                      (array-ref e (+ r 1) j)
                                      (array-ref w i j))))
                            (if (< t (array-ref e i j))
                                (begin
                                  (array-set! e t i j)
                                  (array-set! root r i j))))))))
      (values e root))))
