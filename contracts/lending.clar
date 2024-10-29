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

;; Function to withdraw collateral
(define-public (withdraw-collateral (amount uint))
    (let ((collateral-amount (map-get? collateral tx-sender)))
        (if collateral-amount
            (if (>= (unwrap-panic collateral-amount) amount)
                (begin
                    (map-insert collateral tx-sender (- (unwrap-panic collateral-amount) amount))
                    (ok amount)
                )
                (err u5) ; Withdrawal amount exceeds deposited collateral
            )
            (err u6) ; No collateral deposited
        )
    )
)

;; Function to liquidate a loan
(define-public (liquidate (borrower principal))
    (let ((borrowed-amount (map-get? borrowers borrower))
          (collateral-amount (map-get? collateral borrower)))
        (if (and borrowed-amount collateral-amount)
            (if (< (* (unwrap-panic collateral-amount) LIQUIDATION_THRESHOLD) (unwrap-panic borrowed-amount))
                (begin
                    (map-delete borrowers borrower)
                    (map-delete collateral borrower)
                    (ok (unwrap-panic borrowed-amount))
                )
                (err u7) ; Collateral value above liquidation threshold
            )
            (err u8) ; Borrower has no active loan
        )
    )
)

;; Function to earn interest as a lender
(define-public (earn-interest)
    (let ((lender-amount (map-get? lenders tx-sender)))
        (if lender-amount
            (begin
                ;; Calculate interest and update lender's balance
                (map-insert lenders tx-sender (+ (unwrap-panic lender-amount) (calculate-interest (unwrap-panic lender-amount))))
                (ok (unwrap-panic lender-amount))
            )
            (err u9) ; Lender has no deposited assets
        )
    )
)
