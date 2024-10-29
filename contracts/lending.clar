(define-constant COLLATERAL_RATIO 1.5)
(define-constant LIQUIDATION_THRESHOLD 1.2)

;; State variables
(define-data-var borrowers (map principal uint) simple-map)
(define-data-var lenders (map principal uint) simple-map)
(define-data-var collateral (map principal uint) simple-map)

;; Function to deposit collateral
(define-public (deposit-collateral (amount uint))
    (begin
        (map-insert collateral tx-sender amount)
        (ok amount)
    )
)
