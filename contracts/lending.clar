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

;; Function to borrow assets
(define-public (borrow (amount uint))
    (let ((collateral-amount (map-get? collateral tx-sender)))
        (if collateral-amount
            (if (>= (* (unwrap-panic collateral-amount) COLLATERAL_RATIO) amount)
                (begin
                    (map-insert borrowers tx-sender amount)
                    (ok amount)
                )
                (err u1) ; Insufficient collateral
            )
            (err u2) ; No collateral deposited
        )
    )
)

;; Function to repay a loan
(define-public (repay-loan (amount uint))
    (let ((borrowed-amount (map-get? borrowers tx-sender)))
        (if borrowed-amount
            (if (>= (unwrap-panic borrowed-amount) amount)
                (begin
                    (map-insert borrowers tx-sender (- (unwrap-panic borrowed-amount) amount))
                    (ok amount)
                )
                (err u3) ; Repayment amount exceeds borrowed amount
            )
            (err u4) ; No active loan
        )
    )
)
