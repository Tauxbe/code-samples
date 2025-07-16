;;; line_reader_emacs.el --- Pipe-delimited, quoted file line checker for Emacs Lisp
;; Usage: M-x eval-buffer, then M-x line-reader-check-file

(defun line-reader--split-pipe-quoted (line)
  "Split LINE on pipes, respecting quoted fields. Returns a list of strings."
  (let ((tokens '())
        (current "")
        (in-quote nil)
        (i 0)
        (len (length line)))
    (while (< i len)
      (let ((c (aref line i)))
        (cond
         ((eq c ?\") (setq in-quote (not in-quote)) (setq current (concat current (string c))))
         ((and (eq c ?|) (not in-quote)) (push (string-trim current "\"") tokens) (setq current ""))
         (t (setq current (concat current (string c))))))
      (setq i (1+ i)))
    (push (string-trim current "\"") tokens)
    (nreverse tokens)))

(defun line-reader-check-file (filename)
  "Check that each line in FILENAME has the same number of tokens as the header."
  (interactive "fFlatfile: ")
  (with-temp-buffer
    (insert-file-contents filename)
    (let* ((lines (split-string (buffer-string) "\n" t))
           (header (line-reader--split-pipe-quoted (car lines)))
           (num-cols (length header)))
      (message "expecting: %d tokens" num-cols)
      (cl-loop for line in (cdr lines)
               for i from 2
               for row = (line-reader--split-pipe-quoted line)
               do (if (/= (length row) num-cols)
                      (message "Warning: Line %d has %d tokens, expected %d." i (length row) num-cols)
                    (message "Line %d is valid with %d tokens." i (length row)))))))

(provide 'line_reader_emacs)
;;; line_reader_emacs.el ends here
