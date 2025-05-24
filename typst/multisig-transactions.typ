#import "@preview/cetz:0.2.2"
#import "./transaction.typ": *

#let image-background = image("./images/background-1.jpg", height: 100%, fit: "cover")
#let image-foreground = image("./images/Logo-Anastasia-Labs-V-Color02.png", width: 100%, fit: "contain")
#let image-header = image("./images/Logo-Anastasia-Labs-V-Color01.png", height: 75%, fit: "contain")

#set page(
  background: image-background,
  paper :"a4",
  margin: (left : 20mm,right : 20mm,top : 40mm,bottom : 30mm)
)


// Set default text style
#set text(15pt, font: "Montserrat")

#v(3cm) // Add vertical space

#align(center)[
  #box(
    width: 60%,
    stroke: none,
    image-foreground,
  )
]

#v(1cm) // Add vertical space

// Set text style for the report title
#set text(20pt, fill: white)

// Center-align the report title

#v(5cm)

// Set text style for project details
#set text(13pt, fill: white)


// Reset text style to default
#set text(fill: luma(0%))

// Display project details
#show link: underline
#set terms(separator:[: ],hanging-indent: 18mm)

#set par(justify: true)
#set page(
  paper: "a4",
  margin: (left: 20mm, right: 20mm, top: 40mm, bottom: 35mm),
  background: none,
  header: [
    #align(right)[
      #image("./images/Logo-Anastasia-Labs-V-Color01.png", width: 25%, fit: "contain")
    ]
    #v(-0.5cm)
    #line(length: 100%, stroke: 0.5pt)
  ],
)

#v(20mm)
#show link: underline

#outline(depth:3, indent: 1em)
#set text(size: 11pt)  // Reset text size to 10pt
#set page(
   footer: [
    #line(length: 100%, stroke: 0.5pt)
    #v(-3mm)
    #align(center)[ 
      #set text(size: 11pt, fill: black)
      *Anastasia Labs – *
      #set text(size: 11pt, fill: gray)
      *Upgradable Multi-Signature Contract*
      #v(-3mm)
      Project Design Specification
      #v(-3mm)
    ]
    #v(-6mm)
    #align(right)[
      #context counter(page).display( "1/1",both: true)]
  ] 
)

// Initialize page counter
#counter(page).update(1)

#set heading(numbering: "1.")
#show heading: set text(rgb("#c41112"))

\
= Transactions
\
This section outlines the various transactions involved in the Upgradable Multi-Signature Contract on the Cardano blockchain.

\
== Mint :: InitMultiSig
\
This transaction initializes the multi-sig contract by minting the Multisig NFT and setting up the initial configuration.

\
#transaction(
  "InitMultiSig",
  inputs: (
    (
      name: "Initiator UTxO",
      address: "initiator_wallet",
      value: (
        ada: 1000000,
      ),
    ),
    (
      name: "Initiator2 UTxO",
      address: "initiator_wallet",
      value: (
        ada: 1000000,
      ),
    ),
  ),
  outputs: (
    (
      name: "Multisig Validator UTxO",
      address: "multisig_validator",
      value: (
        ada: 1000000,
        Multisig_NFT: 1,
      ),
      datum: (
        signers: (`Signer A`, `Signer B`, `Signer C`, `Signer D`),
        threshold: 2,
        spending_limit: `500000`,
        transaction_limit_value: (ada: `1000000`),
      ),
    ),
    (
      name: "Initiator Change UTxO",
      address: "initiator_wallet",
      value: (
        ada: 0, // Remaining ADA after fees (for illustration)
      ),
    ),
  ),
  signatures: (
    "Initiator",
  ),
  show_mints: true,
  notes: [Initiate MultiSig Transaction],
)

\
=== Inputs
\
+ *Initiator Wallet UTxO*

  - Address: Initiator's wallet address

  - Value:

    - Minimum ADA required

    - Any additional ADA required for the transaction
\
=== Mints
\
+ *Multi-Sig Validator*

  - Redeemer: InitMultiSig

  - Value:

    - +1 Multisig NFT Asset
\
=== Outputs
\
+ *Multi-Sig Validator UTxO*

  - Address: Multi-Sig Validator script address

  - Datum:

    - signers: 4.

    - threshold: 2.
    - spending_limit: 500,000 ADA.
    - transaction_limit_value: Asset class and quantity defining the limit for transactions.

  - Value:

    - Minimum ADA required

    - 1 Multisig NFT Asset
\
+ *Initiator Change UTxO* (optional)

  - Address: Initiator's wallet address
  - Value:
    - Remaining ADA after transaction fees

#pagebreak()
#v(50pt)
\
== Mint :: EndMultiSig

\
This transaction terminates the multi-sig contract by burning the Multisig NFT and distributing the remaining funds.

\
#transaction(
  "EndMultiSig",
  inputs: (
    (
      name: "Multisig Validator UTxO",
      address: "multisig_validator",
      value: (
        ada: 1000000,
        Multisig_NFT: 1,
      ),
      datum: (
        signers: (`Signer A`, `Signer B`, `Signer C`),
        threshold: 2,
        spending_limit: `500000`,
        transaction_limit_value: (ada: `1000000`),
      ),
      // redeemer: "EndMultiSig",
    ),
  ),
  outputs: (
    (
      name: "Signer A UTxO",
      address: "signer_A_wallet",
      value: (
        ada: 250000,
      ),
    ),
    (
      name: "Signer B UTxO",
      address: "signer_B_wallet",
      value: (
        ada: 250000,
      ),
    ),
    (
      name: "Signer C UTxO",
      address: "signer_C_wallet",
      value: (
        ada: 250000,
      ),
    ),
     (
      name: "Signer D UTxO",
      address: "signer_D_wallet",
      value: (
        ada: 250000,
      ),
    ),
  ),
  signatures: (
    "Signer A",
    "Signer B",
  ),
  show_mints: true,
  notes: [End MultiSig Transaction],
)
\

\
=== Inputs
\
+ *Multi-Sig Validator UTxO*

  - Address: Multi-Sig Validator script address
  - Datum:
    - Current multi-sig configuration

  - Value:
    - Minimum ADA

    - 1 Multisig NFT Asset
    - Any remaining funds managed by the contract
  \
+ *Signers' Signatures*

  Required number of signers (as per threshold) must sign the transaction.

=== Mints
\
+ *Multi-Sig Validator*

  - Redeemer: EndMultiSig

  - Value:
  - −1 Multisig NFT Asset (burning the NFT)
\
=== Outputs
\
+ Distribution UTxOs

  - Funds are distributed to the appropriate addresses as per the termination plan.

  - Value:
  
    - ADA and other assets as needed

#pagebreak()
#v(50pt)
\
== Spend :: Sign
\

This transaction ensures that the number of signers meets or exceeds the specified threshold and The datum of the Multisig remains the same.

\
#transaction(
  "Sign",
  inputs: (
    (
      name: "Multisig Validator UTxO",
      address: "multisig_validator",
      value: (
        ada: 1000000,
        Multisig_NFT: 1,
      ),
      datum: (
        signers: (`Signer A`, `Signer B`, `Signer C`),
        threshold: 2,
        spending_limit: `500000`,
        transaction_limit_value: (ada: `1000000`),
      ),
      // redeemer: "Sign",
    ),
  ),
  outputs: (
    (
      name: "Recipient UTxO",
      address: "recipient_wallet",
      value: (
        ada: 500000, // Transfer amount
      ),
    ),
    (
      name: "Multisig Validator UTxO",
      address: "multisig_validator",
      value: (
        ada: 500000, // Remaining funds
        Multisig_NFT: 1,
      ),
      datum: (
        signers: (`Signer A`, `Signer B`, `Signer C`),
        threshold: 2,
        spending_limit: `500000`,
        transaction_limit_value: (ada: `1000000`),
      ),
    ),
  ),
  signatures: (
    "Signer A",
    "Signer B",
  ),
  show_mints: false,
  notes: [Sign Transaction],
)

\

==== Inputs
\

  + *Multisig Validator UTxO*

    - Address: Multisig validator script address

    - Datum:

      - `signers`
      - `threshold`
      - `funds`
      - `spending_limit`
.
    - Value:

      - ADA + Any tokens
      - Locked Value

\
==== Outputs
\
  + *Recipient Wallet UTxO*
    - Address: Recipient wallet address

      - Transferred ADA/tokens

  + *Multisig Validator UTxO:*
    - Address: Multisig validator script address

    - Datum:

      - `signers`
      - `threshold`
      - `funds`  
      - `spending_limit`  
      
    - Value:

      - Remaining ADA + Remaining tokens

#pagebreak()
#v(50pt)
\
=== Spend :: Update
  \

Allows for the addition or removal of members from the Multisig arrangement, and
updates the required signers threshold.

  \
  #transaction(
  "Update",
  inputs: (
    (
      name: "Multisig Validator UTxO",
      address: "multisig_validator",
      value: (
        ada: 1000000,
        Multisig_NFT: 1,
      ),
      datum: (
        signers: (`Signer A`, `Signer B`, `Signer C`),
        threshold: 2,
        spending_limit: `500000`,
        transaction_limit_value: (ada: `1000000`),
      ),
      // redeemer: "Update",
    ),
  ),
  outputs: (
    (
      name: "Multisig Validator UTxO",
      address: "multisig_validator",
      value: (
        ada: 1000000,
        Multisig_NFT: 1,
      ),
      datum: (
        signers: (`Signer A`, `Signer B`, `Signer D`), // Updated signers list
        threshold: 3,
        spending_limit: `500000`,
        transaction_limit_value: (ada: `1000000`),
      ),
    ),
  ),
  signatures: (
    "Signer A",
    "Signer B",
  ),
  show_mints: false,
  notes: [Update Multisig Configuration],
)

\

==== Inputs
\

  + *Multisig Validator UTxO*

    - Address: Multisig validator script address

    - Datum:

      - `old_signers`
      - `old_threshold`
      - `funds`
      - `old_spending_limit`

    - Value:

      - X ADA + Any tokens

\
==== Outputs
\
  + *Multisig Wallet UTxO*

    - Address: Merchant wallet address
    - Datum:

      - `new_signers`
      - `new_threshold`
      - `funds`
      - `new_spending_limit`

    - Value: 

      - X ADA + Any tokens (unchanged)

