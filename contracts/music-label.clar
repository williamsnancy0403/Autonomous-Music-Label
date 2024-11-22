;; Decentralized Autonomous Music Label

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))

;; Data Maps
(define-map artists { artist-id: uint } { name: (string-ascii 50), address: principal, total-investment: uint })
(define-map songs { song-id: uint } { artist-id: uint, title: (string-ascii 100), price: uint })
(define-map investments { investor: principal, artist-id: uint } { amount: uint })
(define-map royalties { song-id: uint } { total: uint })

;; Variables
(define-data-var artist-id-nonce uint u0)
(define-data-var song-id-nonce uint u0)

;; Private Functions
(define-private (is-owner)
  (is-eq tx-sender contract-owner)
)

;; Public Functions
(define-public (register-artist (name (string-ascii 50)))
  (let
    (
      (new-id (+ (var-get artist-id-nonce) u1))
    )
    (asserts! (is-none (map-get? artists { artist-id: new-id })) err-already-exists)
    (map-set artists { artist-id: new-id } { name: name, address: tx-sender, total-investment: u0 })
    (var-set artist-id-nonce new-id)
    (ok new-id)
  )
)

(define-public (release-song (artist-id uint) (title (string-ascii 100)) (price uint))
  (let
    (
      (new-id (+ (var-get song-id-nonce) u1))
    )
    (asserts! (is-some (map-get? artists { artist-id: artist-id })) err-not-found)
    (map-set songs { song-id: new-id } { artist-id: artist-id, title: title, price: price })
    (var-set song-id-nonce new-id)
    (ok new-id)
  )
)

(define-public (invest-in-artist (artist-id uint) (amount uint))
  (let
    (
      (artist (unwrap! (map-get? artists { artist-id: artist-id }) err-not-found))
      (current-investment (default-to u0 (get amount (map-get? investments { investor: tx-sender, artist-id: artist-id }))))
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set investments { investor: tx-sender, artist-id: artist-id } { amount: (+ current-investment amount) })
    (map-set artists { artist-id: artist-id }
      (merge artist { total-investment: (+ (get total-investment artist) amount) })
    )
    (ok true)
  )
)

(define-public (buy-song (song-id uint))
  (let
    (
      (song (unwrap! (map-get? songs { song-id: song-id }) err-not-found))
      (artist (unwrap! (map-get? artists { artist-id: (get artist-id song) }) err-not-found))
      (current-royalties (default-to u0 (get total (map-get? royalties { song-id: song-id }))))
    )
    (try! (stx-transfer? (get price song) tx-sender (as-contract tx-sender)))
    (map-set royalties { song-id: song-id } { total: (+ current-royalties (get price song)) })
    (ok true)
  )
)

(define-read-only (get-artist-investment (artist-id uint) (investor principal))
  (ok (get amount (default-to { amount: u0 } (map-get? investments { investor: investor, artist-id: artist-id }))))
)

(define-read-only (get-song-royalties (song-id uint))
  (ok (get total (default-to { total: u0 } (map-get? royalties { song-id: song-id }))))
)

(define-public (distribute-royalties (song-id uint))
  (let
    (
      (song (unwrap! (map-get? songs { song-id: song-id }) err-not-found))
      (artist (unwrap! (map-get? artists { artist-id: (get artist-id song) }) err-not-found))
      (royalty-amount (unwrap! (get-song-royalties song-id) err-not-found))
    )
    (asserts! (> royalty-amount u0) err-unauthorized)
    (map-set royalties { song-id: song-id } { total: u0 })
    (try! (distribute-to-artist song-id (get artist-id song) (/ royalty-amount u2)))
    (try! (distribute-to-investors song-id (get artist-id song) (/ royalty-amount u2)))
    (ok true)
  )
)

(define-private (distribute-to-artist (song-id uint) (artist-id uint) (amount uint))
  (let
    (
      (artist (unwrap! (map-get? artists { artist-id: artist-id }) err-not-found))
    )
    (as-contract (stx-transfer? amount tx-sender (get address artist)))
  )
)

(define-private (distribute-to-investors (song-id uint) (artist-id uint) (amount uint))
  (let
    (
      (artist (unwrap! (map-get? artists { artist-id: artist-id }) err-not-found))
      (total-investment (get total-investment artist))
    )
    (if (> total-investment u0)
      (distribute-to-investor song-id artist-id amount tx-sender)
      (ok true)
    )
  )
)

(define-public (claim-investor-royalties (song-id uint) (artist-id uint))
  (let
    (
      (song (unwrap! (map-get? songs { song-id: song-id }) err-not-found))
      (artist (unwrap! (map-get? artists { artist-id: artist-id }) err-not-found))
      (investment (unwrap! (map-get? investments { investor: tx-sender, artist-id: artist-id }) err-not-found))
      (royalty-amount (unwrap! (get-song-royalties song-id) err-not-found))
      (investor-share (/ (* (get amount investment) (/ royalty-amount u2)) (get total-investment artist)))
    )
    (asserts! (> investor-share u0) err-unauthorized)
    (try! (as-contract (stx-transfer? investor-share tx-sender tx-sender)))
    (ok true)
  )
)

(define-private (distribute-to-investor (song-id uint) (artist-id uint) (amount uint) (recipient principal))
  (begin
    (print { song-id: song-id, artist-id: artist-id, amount: amount, recipient: recipient })
    (ok true)
  )
)
