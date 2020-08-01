#lang racket

(require ansi-color)

;; Default wmh dir
(define wmh-dir
  (path-only (path->complete-path (find-system-path 'run-file))))

;; EXAMPLE
;; Hash table of directories
(define directories
  (make-hash '(("/home/user/.config/sxhkd" . "sxhkd")
               ("/home/user/.config/bspwm/bspwmrc" . "bspwm/bspwmrc"))))

;; EXAMPLE
;; Hash table of command outputs that need to be saved
;; Do not include whitespaces in destination files.
(define commands
  (make-hash '(("pacman -Qqe" . "pacman/pacman-Qqe.txt")
               ("pacman -Qqm" . "pacman/pacman-Qqm.txt"))))

;; EXAMPLE
(define repo "https://github.com/name/repo")

(define backup
  (λ ()
     ;; Copy files/directories from original sources to backup
     (with-handlers ([exn:fail? (λ (v)
                                   ((error-display-handler)
                                    (exn-message v)
                                    v)
                                   (with-colors 'red
                                                (λ ()
                                                   (display "Something is most likely wrong with the directory hash table."))))])
                    (hash-for-each directories
                                   (λ (k v)
                                      (let* ([dest (string-append (path->string wmh-dir)
                                                                  v)]
                                             [src k])
                                        (unless (file-exists? dest)
                                          (make-parent-directory* dest))
                                        (when (or (directory-exists? dest)
                                                  (file-exists? dest))
                                          (delete-directory/files dest))
                                        (copy-directory/files src dest))))
                    (hash-for-each commands
                                   (λ (k v)
                                      (let* ([dest (string-append (path->string wmh-dir)
                                                                  v)]
                                             [cmd k])
                                        (unless (file-exists? dest)
                                          (make-parent-directory* dest))
                                        (define out
                                          (open-output-file dest #:exists 'can-update))
                                        (display (with-output-to-string (λ ()
                                                                           (system cmd)))
                                                 out)
                                        (close-output-port out)))))
     ;; Initialize wmh-dir as git repo if it isn't already and add remote

     (unless (directory-exists? (build-path wmh-dir ".git"))
       (current-directory wmh-dir)
       (system (string-append "git init && git remote add origin "
                              repo))
       (with-colors 'green
                    (λ ()
                       (display "Initialized git remote as 'origin'"))))
     ;; Add and commit files to the git repo
     (current-directory wmh-dir)
     (define out
       (open-output-file ".gitignore"))
     (display "wmh.rkt" out)
     (close-output-port out)
     (system "git add . && git commit -m \"bkp\" && git push -f origin master")))

;; Prints out help to the command line
(define help
  (λ ()
     (with-colors 'green
                  (λ ()
                     (display "Available functions:\n--backup - Backs everything up from the configuration and pushes it to the git repo.")))))

;; Command line parsing
(cond
 ((= 0 (vector-length (current-command-line-arguments)))
  (backup))
 ((< 1 (vector-length (current-command-line-arguments)))
  (with-colors 'red
               (λ ()
                  (display "Too many arguments! See --help for all available commands."))))
 (else (match (vector-ref (current-command-line-arguments)
                          0)
              ["--backup"
               (backup)]
              ["--help"
               (help)]
              [default (with-colors 'red
                                    (λ ()
                                       (display "Unknown argument. See --help for all available commands.")))])))
