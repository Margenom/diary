#!/usr/bin/env racket
#lang racket
(require racket/date)
(require racket/base)

;; Consts ;;
;(define S_BASE (string-append (getenv "HOME") "/me"))
(define S_BASE "me")
; step's
(define S_STEP_BASE ".more/log.ls")

; time periods
(define t.m 60)
(define t.h (* t.m 60))
(define t.d (* t.h 24))
(define t.w (* t.d 7))

; list's
(define S_LS_PAM_SEP "><")
(define S_LS_SEP "\t")
(define S_LS_EXT "ls")

; file filtres
 (define (_mkrex patern [post? (lambda(K) (not (directory-exists? (s-file K))))])
	(lambda(name) (and (post? name) (regexp-match patern name))))
(define tpr? (_mkrex #px"\\d{10}")) ;records
(define tpf? (_mkrex ".+" (lambda(K) (directory-exists? K)))) ;files (directoryes
(define tpl? (_mkrex (string-append ".+\\." S_LS_EXT))) ;lists
(define tps? (_mkrex ".*\\.[^.]+" (lambda(K) (and (directory-exists? K) (path-has-extension? K))))) ;special
(define tpc? (_mkrex "[^.]+")) ;cats

;; Bases ;;
; time
(define (utime [diff 0]) (+ diff (current-seconds)))
(define (time->utime form) 
	(define (p Match i o) (or (string->number (list-ref Match i))))
	(define (t Date p) (vector-ref Date  p))
	((lambda(M D) (and M (find-seconds 0 (p M 4 0) (p M 3 0) (p M 2 (t D 4)) (p M 1 (t D 5)) (t D 6))))
		(struct->vector (current-date))
		(regexp-match #px"(?:(\\d\\d)(\\d\\d))?(\\d\\d)(\\d\\d)" form)))

(define (utime-hum ut) (define dat (struct->vector (seconds->date ut)))
	(apply format "~a ~a.~a ~a:~a" (vector-ref #("Вс" "Пн" "Вт" "Ср" "Чт" "Пт" "Сб") (vector-ref dat 7)) 
		(map (lambda(i) (vector-ref dat i)) '(4 5 3 2))))

; files
(define (s-file . name) (apply string-append S_BASE "/" name))
(define (s-dir-list . filters) (let rec ((flts filters) (out (path->string (directory-list (s-file)))))
	(if (null? rec) out (rec (cdr flts) (filter (car flts) out)))))

(define (>>file file trunc) (with-output-to-file file 
	(if (string? trunc) (lambda() (display trunc)) trunc) #:exists 'append))

;; diary ;;
(define (self-more [time (utime)]) 
	(system (string-append (getenv "EDITOR") " " (s-file (number->string time)))))
 (define (s-cat-add cat line [term "\n"]) 
	(>>file (s-file cat) (string-append line term)))

(define (self-last cat) (let ((last (apply min (map string->number (s-dir-list tpr?)))))
		(s-cat-add cat (number->string last))))

 (define (realpath path) (path->string (path->complete-path (string->path path))))
(define (self-safe cat file) 
	(define file_name (path->string (file-name-from-path file)))
	(define path_new (s-file file_name))
	(unless (string=? (realpath file) (realpath path_new)) (copy-directory/files file path_new))
	(s-cat-add cat file_name))

;; list's ;;
 (define (appext name ext) (if (path-has-extension? name) name (string-append name "." ext)))
;coder
 (define (s-pams->string pams) 
	(apply string-join (append (map (lambda(p) (string-append (car p) S_LS_PAM_SEP (cdr p))) pams) 
		(list S_LS_SEP))))

 (define (s-ls->string datetime pams some) 
	(string-join (number->string datetime) (s-pams->string) some S_LS_SEP))
;decoder
 (define (string->s-pam str) (let ((t (string-split str S_LS_PAM_SEP))) (and (>= (length t) 2) t)))
 (define (string->s-ls line) 
	(let rec((seplen (string-split line S_LS_SEP)) (datetime #f) (pams '()) (some "")) (cond 
		((null? seplen) (list datetime (reverse pams) some))
		((not datetime) (rec (cdr seplen) (car seplen) pams some))
		(else (let ((pam-parsed (string->s-pam (car seplen))))
			(if pam-parsed (rec (cdr seplen) datetime (cons pam-parsed pams) some)
					(rec (cdr seplen) datetime pams 
						(string-append some (if (string=? "" some) some "\t") (car seplen)))))))))

(define (self-app lst some pams [time (utime)])
	(>>file (s-file (appext lst S_LS_EXT)) (string-append (s-ls->string time pams some) "\n")))
;)
 (define (s-ls-grep reqpams) (lambda(parsed) parsed))
(define (sefl-list lst pams) 
	(map (s-ls-grep pams) (map string->s-ls (file->lines (s-file (appext lst S_LS_EXT))))))

;; Steps ;;
(define (self-step msg pams beg len)
	(define end (+ beg len))
	(define bef (len))
	(self-app S_STEP_BASE msg (cons (cons "-" . (number->string bef)) pams) end))

;(define (self-stats pams [diff (utime (- t.w))] [time #f] [pariod t.d]))
;(define (self-box name len pams [time (utime)] ))

; main
(define (assoc-off lst) (lambda(key) (if key (let ((val (assoc lst))) 
	(and val (begin (set! lst (remove val lst)) (cdr val)))) lst)))

(define (main . args)
	(display args) (newline)
	 (define (pam-parser str) ((lambda (p) (if p (cons (list-ref p 1) (list-ref p 2)) str))
		(regexp-match #px"-([^=]+)=?(.*)" str)))

	(define pams (map pam-parser (cdr args)))
	(display pams) (newline)
	(define -* (assoc-off pams))
	(case (string->symbol (car args))
		((more) (self-more (or (-* 't) (utime))))
		((last) (self-last (or (-* 't) (utime))))
		((safe) (self-safe (or (-* 't) (utime))))

		(else (display args))))

(apply main (vector->list (current-command-line-arguments)))
