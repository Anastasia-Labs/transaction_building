
# Flowchart
- nodes (geometric shapes) and edges (arrows or lines)

## Default Node:

```mermaid
flowchart
    A
```

## Node with Text:

```mermaid
flowchart
    A[A node with text]
```

## A node with rounded edges

```mermaid
flowchart
    A(A node with rounded edges)
```

## Cylindrical shaped node 
```mermaid
flowchart
    A[(A cylindrical node)]
```

## Circular shaped node 

```mermaid
flowchart
    A((A cylindrical node))
```


## Direction = LR | RL | TB | BT | TD

```mermaid
    flowchart LR 
        subgraph A
            B
            C
            D
        end
        subgraph E
            F
        end

        B --> F
        C --> F
        D --> F

```

## Subgraph 

```mermaid
flowchart LR 
    subgraph Spending Script
       A
       B
       C
    end
    subgraph Spending Script
       D
       E
       F
    end

    A --> E
    B --> E
    C --> E
```

<!-- Multisig Update -->
###  Inputs

```mermaid
    graph LR
        subgraph Spending
            Input
        end
        subgraph Spending2
        subgraph Spending3
        end
        end
```

```mermaid
flowchart LR 
    subgraph Spending Script
        Input[Datum, Value]
    end
    subgraph Transaction
    subgraph Signatures
    subgraph Signer A B C D 
    end
    end
    end
    Input --UTxO-->Transaction
    
```

## Outputs

```mermaid
flowchart LR 
    subgraph Transaction
        S((Signer A))
        S1((Signer B))
        S2((Signer C))
    end
    Transaction --> A1[(Output 1)]
    Transaction --> A2((Output 2))
    Transaction --> A3((Output 3))
```

## Transaction Diagram

```mermaid
flowchart LR 
    TX[(Transaction)]
    style TX fill:red,stroke:black,stroke-width:4px,shadow:shadow

    subgraph Spending Script
        S((Input 1))
        S1((Input 2))
        S2((Input 3))
        S3((Input 4))
    end
    S -->|validates \n Business logic| TX
    S1 -->|validates \n Business logic| TX
    S2 -->|validates \n Business logic| TX
    S3 -.->|validates \n Business logic| TX
    TX --> O1{{Output 1}}
    TX --> O2(Output 2)
    TX --> O3(Output 3)
```



# Sequence Diagram

## Service-Account-Payment Workflow -->

 ```mermaid

sequenceDiagram
    participant Merchant
    participant ServiceValidator
    participant AccountValidator
    participant PaymentValidator
    
    Merchant->>ServiceValidator: CreateService
    ServiceValidator->>Merchant: ServiceNFT
    User->>AccountValidator: CreateAccount
    AccountValidator->>User: AccountNFT
    User->>PaymentValidator: InitiateSubscription
    PaymentValidator->>ServiceValidator: VerifyService
    PaymentValidator->>AccountValidator: VerifyAccount
    PaymentValidator->>User: PaymentNFT

```
<!-- PlantUML : https://plantuml.com/ -->

<!-- https://github.com/blushft/go-diagrams -->

<!-- ASCII Diagrams

- https://asciiflow.com/

- https://monodraw.helftone.com/ -->









