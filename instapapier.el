;;; instapapier.el --- add urls to instapaper with a zing -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Devin Davis
;;
;; Author: Devin Davis <devindavis@pop-os>
;; Maintainer: Devin Davis <devindavis@pop-os>
;; Created: October 25, 2025
;; Modified: October 25, 2025
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/barnacleDevelopments/instapapier
;; Instapaper API Docs: https://www.instapaper.com/api/simple
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;; instapapier.el was made to provide a comprehensive url adding experience
;;; MIT License
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Code:
(require 'url)
(require 'url-auth)

(setq instapapier-api-url "https://www.instapaper.com/api/add")
(setq url-debug t)

(defun instapapier-add-url (url)
  "Add URL to Instapaper account."
  (condition-case err
      (let* ((auth-info (car (auth-source-search :host "www.instapaper.com"
                                                 :require '(:user :secret))))
             (username (plist-get auth-info :user))
             (password (funcall (plist-get auth-info :secret)))
             (url-request-method "GET")
             (url-request-extra-headers
              `(("Authorization" . ,(concat "Basic "
                                            (base64-encode-string
                                             (concat username ":" password)
                                             t)))))
             (api-url (format "https://www.instapaper.com/api/add?url=%s"
                              (url-hexify-string url))))
        (with-current-buffer 
            (url-retrieve-synchronously api-url t)
          (let ((status (match-string 1)))
            (cond
             ((string= status "201")
              (message "✓ Added to Instapaper: %s" url))
             ((string= status "400")
              (message "✗ Bad request - check URL format"))
             ((string= status "403")
              (message "✗ Authentication failed"))
             (t
              (message "✗ Error %s adding URL" status)))
            (current-buffer))))
    (error
     (message "Error adding to Instapaper: %s" err)
     nil)))
(defun instapapier-test-auth ()
  "Test Instapaper authentication."
  (require 'url)
  (require 'auth-source)
  (let* ((auth-info (car (auth-source-search :host "www.instapaper.com"
                                             :require '(:user :secret))))
         (username (plist-get auth-info :user))
         (password (funcall (plist-get auth-info :secret)))
         (url-request-method "GET")
         (url-request-extra-headers
          `(("Authorization" . ,(concat "Basic "
                                        (base64-encode-string
                                         (concat username ":" password)
                                         t))))))
    (with-current-buffer 
        (url-retrieve-synchronously "https://www.instapaper.com/api/authenticate" t)
      (goto-char (point-min))
      (re-search-forward "^HTTP/[0-9.]+ \\([0-9]+\\)")
      (let ((status (match-string 1)))
        (message "Auth status: %s" status)
        (if (string= status "200")
            (message "✓ Authentication successful!")
          (message "✗ Authentication failed with status %s" status))
        (buffer-string)))))

;;;###autoload
(defun instapapier-add-url-at-point()
  "Add the URL at point to Instapaper."
  (interactive)
  (let ((url (thing-at-point 'url)))
    (instapapier-add-url url)))

;;;###autoload
(defun instapapier-add-elfeed-entry-at-point()
  "Add the elfeed entry at point in show buffer."
  (interactive)
  (let ((url (or (elfeed-entry-link (elfeed-search-selected :ignore-region)))))
    (instapapier-add-url url)))

;;;###autoload
(defun instapapier-interactively-add-url(url)
  "Add URL interactively."
  (interactive "sInstapaper URL:")
  (instapapier-add-url url))

(provide 'instapapier)

;;; instapapier.el ends here











