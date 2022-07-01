;;; sq.el --- Bindings for Sequoia PGP's cli  -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Justus Winter

;; Author: Justus Winter <justus@sequoia-pgp.org>
;; Created: 23 Jun 2021
;; Keywords: tools
;; URL: https://gitlab.com/sequoia-pgp/sqel

;; This file is not part of GNU Emacs.

;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Provides convenient functions and key bindings to inspect OpenPGP
;; data using sq, Sequoia PGP's command line frontend.  Currently,
;; this is mostly useful for OpenPGP developers.
;;
;; To enable, add this to your .emacs:
;;
;;   (require 'sq)
;;   (sq-global-set-keys) ;; Uses the 'C-c s' chord.
;;
;; You can give an alternative chord prefix to sq-global-set-keys.

;;; Code:

(defun sq--invoke-region (arguments &optional b e)
  "Invokes sq with the given arguments on the region

Displays the result in the *sq output* buffer."
  (let ((buffer (get-buffer-create "*sq output*")))
    (with-current-buffer buffer
      (erase-buffer))
    (apply 'call-process-region b e "sq" nil buffer t arguments)
    (with-current-buffer buffer
      (delete-trailing-whitespace)
      (set-buffer-modified-p nil))
    (display-message-or-buffer buffer)))

(defun sq-invoke-region (arguments &optional b e)
  "Invokes 'sq' with the given arguments on the region

Can be used to invoke arbitrary sq commands."
  (interactive "MInvoke on region: sq \nr")
  (sq--invoke-region (split-string arguments)))

(defun sq-packet-dump-region (&optional b e)
  "Invokes 'sq packet dump' on the region

Creates a human-readable description of the packet sequence.

To print cryptographic artifacts, use
`sq-packet-mpi-dump-region'.  To print the raw octet stream
similar to hexdump(1) annotated specifically which bytes are
parsed into OpenPGP values, use `sq-packet-hex-dump-region'."
  (interactive "r")
  (sq--invoke-region '("packet" "dump") b e))

(defun sq-packet-hex-dump-region (&optional b e)
  "Invokes 'sq packet dump --hex' on the region

Creates a human-readable description of the packet sequence with
the raw octet stream similar to hexdump(1) annotated specifically
which bytes are parsed into OpenPGP values.

To print cryptographic artifacts, use
`sq-packet-mpi-dump-region'.  See also `sq-packet-dump-region'
for a less verbose version."
  (interactive "r")
  (sq--invoke-region '("packet" "dump" "--hex") b e))

(defun sq-packet-mpi-dump-region (&optional b e)
  "Invokes 'sq packet dump --mpi' on the region

Creates a human-readable description of the packet sequence with
cryptographic artifacts.

To print the raw octet stream similar to hexdump(1) annotated
specifically which bytes are parsed into OpenPGP values, use
`sq-packet-hex-dump-region'.  See also `sq-packet-dump-region'
for a less verbose version."
  (interactive "r")
  (sq--invoke-region '("packet" "dump" "--mpis") b e))

(defun sq-inspect-region (&optional b e)
  "Invokes 'sq inspect' on the region

Creates a high-level human-readable description of the OpenPGP
artifact in the region."
  (interactive "r")
  (sq--invoke-region '("inspect") b e))

(defun sq-global-set-keys (&optional prefix)
  "Installs global key bindings for sq

This is a convenience function that installs global key bindings
for all Sequoia-related functions with a common prefix.  The
default prefix is C-c s.  To use a different prefix, pass it as
argument to this function."
  (let ((p (or prefix "C-c s")))
    (global-set-key (kbd (concat p " C-c")) 'sq-invoke-region)
    (global-set-key (kbd (concat p " d")) 'sq-packet-dump-region)
    (global-set-key (kbd (concat p " x")) 'sq-packet-hex-dump-region)
    (global-set-key (kbd (concat p " m")) 'sq-packet-mpi-dump-region)
    (global-set-key (kbd (concat p " i")) 'sq-inspect-region)))

(provide 'sq)

;;; sq.el ends here
