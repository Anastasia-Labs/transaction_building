##  Why Staking Validators?

Consider a scenario as described in the illustration below, with multiple UTXOs at a `Spending Validator`; if your entire protocol logic resides within it, the logic has to run for each UTXO, quickly reaching transaction limits and increasing CPU and memory usage.

```mermaid
graph LR
    TX[ Transaction ]
    subgraph Spending Script
    S1((Input 1))
    S2((Input 2))
    S3((Input 3))
    end
    S1 -->|validates \n Business logic| TX
    S2 -->|validates \n Business logic| TX
    S3 -->|validates \n Business logic| TX
    TX --> A1((Output 1))
    TX --> A2((Output 2))
    TX --> A3((Output 3))
```

The solution involves the `Spending Validator` checking that the `Staking validator` is called in the same transaction, consolidating the logic to run once at the `Staking Validator`. This significantly reduces script size and simplifies business logic.

## What are the component of a Script Address?
Addresses are not only used in wallet, but also in smart contracts, often referred to as scripts.

For the purpose of this article we are going to create an Script Address by hashing the Spending Validator and the Staking Validator. 

#### Constructing the Script address
In the below code we can see that our address is composed of the Spending Validator and Staking Validator
```haskell
scriptAddress = 
  Address 
    (ScriptCredential $ ScriptHash "SpendingValidatorHash") 
    (Just $ StakingHash $ ScriptCredential $ ScriptHash "StakingValidatorHash")
```

```mermaid
graph TD
  SA(Script Address)
  SA -->|Payment Credential| ScriptCredentialSA
  subgraph ScriptCredentialSA[ScriptCredential]
  subgraph ScriptHashSA[ScriptHash]
  end
  end
  SA -->|Staking Credential| StakingHash
  subgraph StakingHash
  subgraph ScriptCredential
  subgraph ScriptHash
  end
  end
  end
```
Once you have the script address and following your business logic, now you can lock assets along with datums into the Script Address, therefore associating the new EUTXO and the Script Address with both components `Payment Credential` and `Staking Credential`

```mermaid
graph TD
  U(UTXO) --> SA
  U(UTXO) --> A(Assets)
  U(UTXO) --> D(Datum)
  SA(Script Address)
  SA -->|Payment Credential| ScriptCredentialSA
  subgraph ScriptCredentialSA[ScriptCredential]
  subgraph ScriptHashSA[ScriptHash]
  end
  end
  SA -->|Staking Credential| StakingHash
  subgraph StakingHash
  subgraph ScriptCredential
  subgraph ScriptHash
  end
  end
  end
```
## Let's dive into the implementation

The strategy involves enforcing the spending validator to require invocation of staking validator, upon each attempted expenditure of the script input.
Following this, the staking validator assumes the responsibility of validating each spending script input to ensure strict adherence to the protocol specifications.

```mermaid
graph LR
    TX[ Transaction ]
    subgraph Spending Script
    S1((Input 1))
    S2((Input 2))
    S3((Input 3))
    end
    S1 --> TX
    S2 --> TX
    S3 --> TX
    ST{{Staking Script}} -.-o TX
    TX --> A1((Output 1))
    TX --> A2((Output 2))
    TX --> A3((Output 3))
```


## Shinkai

Set up Protocol Parameter Datum and Formula Script.

### Protocol Parameter

```mermaid
graph LR
    O0(("Shinkai Admin"))
    TX[ Transaction ]
    subgraph NFT Locker
    O1(("UTxO"))
    O1_v("Value\n
      $Protocol Parameter NFT: 1n")
    O1_d[("Datum\n
      Protocol Parameter")]
    end
    O0 -.-> TX
    MP{Protocol Parameter\nReference NFT\n Minting Policy} -.-o TX
    TX --> O1
```

### Formula Script

```mermaid
graph LR
    O0(("Shinkai Admin"))
    TX[ Transaction ]
    subgraph NFT Locker
    O1(("UTxO"))
    O1_v("Value\n
      $Formula Script NFT: 1n")
    O1_s{"Ref Script\n
      < FormulaScript >"}
    end
    O0 -.-> TX
    MP{Formula\nReference NFT\n Minting Policy} -.-o TX
    TX --> O1
```

## Transactions

### Update Protocol Parameter

```mermaid
graph LR
    O0(("Shinkai Admin"))
    TX[ Transaction ]
    subgraph NFT Locker

    subgraph Input
    I1(("UTxO"))
    I1_v("Value\n
      $Protocol Parameter NFT: 1n")
    I1_d[("Datum\n
      Protocol Parameter")]
    end

    subgraph Ouput
    O1(("UTxO"))
    O1_v("Value\n
      $Protocol Parameter NFT: 1n")
    O1_d[("Datum\n
      * New Protocol Parameter *")]
    end

    end
    I1 --> TX
    TX --> O1
    O0 -.-> TX
```

### Update Formula

```mermaid
graph LR
    O0(("Shinkai Admin"))
    TX[ Transaction ]
    subgraph NFT Locker

    subgraph Input
    I1(("UTxO"))
    I1_v("Value\n
      $Formula Script NFT: 1n")
    I1_s{"Ref Script\n
      < FormulaScript >"}
    end

    subgraph Ouput
    O1(("UTxO"))
    O1_v("Value\n
      $Formula Script NFT: 1n")
    O1_s{"Ref Script\n
      < * New FormulaScript * >"}
    end

    end
    I1 --> TX
    TX --> O1
    O0 -.-> TX
```

### Init Linked List

```mermaid
graph LR
    I1("Init UTxO")
    TX[ Transaction ]
    subgraph Minted Tokens
    M1("
        $CIP68 Linked List (REF) __: 1n
        ")
    M2("
        $CIP68 Linked List (USER) __: 1n
        ")
    end
    subgraph User
    O2(("Output"))
    O2_v("Value\n
        $CIP68 Linked List (USER) __: 1n")
    end
    subgraph CIP68 Contract
    O1(("Output"))
    O1_v("Value\n
        $CIP68 Linked List (REF) __: 1n")
    O1_d[("Datum\n
        key = empty next = empty
    staked_amount = 0")]
    end
    I1 --> TX
    MP{CIP68 Linked List NFT\nMinting Policy} -.-o|"Init"| TX
    TX --> O1
    TX --> O2
    TX -.-> M1
    TX -.-> M2
```

### Register New Handle

```mermaid
graph LR
    TX[ Transaction ]
    subgraph CIP68 Contract
    subgraph CIP68 Input
    I1(("UTxO"))
    I1_v("Value\n
        $CIP68 Linked List (REF) __: 1n")
    I1_d[("Datum\n
        key = empty next = empty
        staked_amount = 0")]
    end
    subgraph CIP68 Output1
    O1(("Output"))
    O1_v("Value\n
        $CIP68 Linked List (REF) __: 1n")
    O1_d[("Datum\n
        key = empty *next = apple
        staked_amount = 0")]
    end
    subgraph CIP68 Output2
    O2(("Output"))
    O2_v("Value\n
        $CIP68 Linked List (REF) _apple_: 1n
        $KAI: 500n")
    O2_d[("Datum\n
        key = apple next = empty
        handle = apple routing_info = [1.1.1.1]
        staked_amount = 500n delegation_list = []
        encrypted_key = ... signature_key = ...
        ")]
    end
    end

    subgraph Minted Tokens
    M1("
        $CIP68 Linked List (REF) _apple_: 1n
        ")
    M2("
        $CIP68 Linked List (USER) _apple_: 1n
        ")
    end
    subgraph User Output
    O3(("Output"))
    O3_v("Value\n
      $CIP68 Linked List (USER) _apple_: 1n")
    end
    subgraph Project Output
    O4(("Output"))
    O4_v("Value\n
      $lovelace: Minting Fee")
    end

    subgraph Protocol Parameter
    RI1(("Ref Input"))
    RI1_v("Value\n
      $Protocol Parameter NFT: 1n")
    RI1_d[("Datum\n
      ProtocolParameter")]
    end
    subgraph Formula
    RI2(("Ref Script"))
    RI2_v("Value\n
        $Formula NFT: 1n")
    RI2_s{"RefScript\n
      < FormulaScript >"}
    end

    I1 --> TX
    RI1 -.-o TX
    RI2 -.-o|"Must be executed as Withrawal Script"| TX
    TX --> O1
    TX --> O2
    TX --> O3
    TX --> O4
    TX -.-> M1
    TX -.-> M2
    MP{CIP68 Linked List NFT\nMinting Policy} -.-o|"Insert {apple, HEAD}"| TX
```

### Remove Handle

```mermaid
graph LR
    TX[ Transaction ]
    subgraph User

    subgraph User Input
    I3(("UTxO"))
    I3_v("Value\n
      $CIP68 Linked List (USER) _bag_: 1n")
    end
    subgraph User Output
    O2(("Output"))
    O2_v("Value\n
      $KAI: 800n")
    end

    end
    subgraph CIP68 Contract

    subgraph CIP68 Input1
    I1(("UTxO"))
    I1_v("Value\n
        $CIP68 Linked List (REF) _apple_: 1n
        $KAI: 500n")
    I1_d[("Datum\n
        key = apple next = bag
        handle = apple routing_info = [1.1.1.1]
        staked_amount = 500n delegation_list = []
        encrypted_key = ... signature_key = ...
        ")]
    end
    subgraph CIP68 Input2
    I2(("UTxO"))
    I2_v("Value\n
        $CIP68 Linked List (REF) _bag_: 1n
        $KAI: 800n")
    I2_d[("Datum\n
        key = bag next = card
        handle = bag routing_info = [2.2.2.2]
        staked_amount = 800n delegation_list = []
        encrypted_key = ... signature_key = ...
        ")]
    end

    subgraph CIP68 Output
     O1(("Output"))
     O1_v("Value\n
        $CIP68 Linked List (REF) _apple_: 1n
        $KAI: 500n")
    O1_d[("Datum\n
        key = apple *next = card
        handle = apple routing_info = [1.1.1.1]
        staked_amount = 500n delegation_list = []
        encrypted_key = ... signature_key = ...
        ")]
    end

    end
    subgraph Protocol Parameter
      RI1(("Ref Input"))
      RI1_v("Value\n
        $Protocol Parameter NFT: 1n")
      RI1_d[("Datum\n
        ProtocolParameter")]
    end
    subgraph Formula
      RI2(("Ref Script"))
      RI2_v("Value\n
          $Formula NFT: 1n")
      RI2_s{"RefScript\n
          < FormulaScript >"}
    end
    subgraph Burnt Tokens
    B1("
        $CIP68 Linked List (REF) _bag_: -1n
        ")
    B2("
        $CIP68 Linked List (USER) _bag_: -1n
        ")
    end
    I2 --> TX
    I1 --> TX
    I3 --> TX
    RI1 -.-o TX
    RI2 -.-o|"Must be executed as Withrawal Script"| TX
    TX --> O1
    TX --> O2
    TX -.-> B1
    TX -.-> B2
    MP{CIP68 Linked List NFT\nMinting Policy} -.-o|"Remove {bag, Apple}"| TX
```

### Update Metadata

```mermaid
graph LR
    TX[ Transaction ]
    subgraph User

    subgraph User Input
    I2(("UTxO"))
    I2_v("Value\n
        $CIP68 Linked List (USER) _apple_: 1n")
    end
    subgraph User Output
    O2(("Output"))
    O2_v("Value\n
        $CIP68 Linked List (USER) _apple_: 1n
        $KAI: 50n")
    end
    end
    subgraph CIP68 Contract

    subgraph CIP68 Input
    I1(("UTxO"))
    I1_v("Value\n
        $CIP68 Linked List (REF) _apple_: 1n
        $KAI: 500n")
    I1_d[("Datum\n
        key = apple next = card
        handle = apple routing_info = [1.1.1.1]
        staked_amount = 500n delegation_list = []
        encrypted_key = ... signature_key = ...
        ")]
    end
    subgraph CIP68 Output
    O1(("Output"))
    O1_v("Value\n
        $CIP68 Linked List (REF) _apple_: 1n
        $KAI: 450n")
    O1_d[("Datum\n
        key = apple next = card
        handle = apple routing_info = [3.3.3.3]
        *staked_amount = 450n delegation_list = []
        encrypted_key = ... signature_key = ...
        ")]
    end
    end
    subgraph Protocol Parameter
      RI1(("Ref Input"))
      RI1_v("Value\n
          $Protocol Parameter NFT: 1n")
      RI1_d[("Datum\n
          ProtocolParameter")]
    end
    subgraph Formula
      RI2(("Ref Script"))
      RI2_v("Value\n
          $Formula NFT: 1n")
      RI2_s{"RefScript\n
          < FormulaScript >"}
    end
    I1 -->|"Update Metadata"| TX
    I2 --> TX
    RI1 -.-o TX
    RI2 -.-o|"Must be executed as Withrawal Script"| TX
    TX --> O1
    TX --> O2
```

## IBC Audit
```mermaid
flowchart TD
    Handler[/Deploy handler/]
    Transfer[/Deploy transfer module/]
    Client[/Create client/]
    Mock[/Mock module/]

    subgraph Connection
      Connection1[/Connection open init/]
      Connection2[/Connection open try/]
      Connection3[/Connection open ack/]
      Connection4[/Connection open confirm/]

      Connection1 --> Connection3
      Connection2 --> Connection4
    end

    subgraph Channel
      Channel1[/Channel open init/]
      Channel3[/Channel open try/]
      Channel4[/Channel open ack/]
      Channel6[/Channel open confirm/]
      Channel7[/Channel close init/]

      Channel1 --> Channel4
      Channel3 --> Channel6
      Channel1 & Channel3 & Channel4 & Channel6 --> Channel7
    end

    subgraph OrderedChannel
      Channel2[/Ordered channel open init/]
      Channel5[/Ordered channel open ack/]
      Channel8[/Channel close init/]

      Channel2 --> Channel5
      Channel2 & Channel5 --> Channel8
    end

    subgraph MessageExchange
      direction LR
      Recv1[/Recv packet unescrow/]
      Recv2[/Recv packet mint/]
      Recv3[/Ack packet succeed/]
      Recv4[/Ack packet unescrow/]
      Recv5[/Ack packet mint/]
      Recv6[/Send packet escrow/]
      Recv7[/Send packet burn/]
      Recv8[/Timeout packet unescrow/]
      Recv9[/Timeout packet mint/]
    end

    subgraph OrderedMessageExchange
      direction LR
      ORecv1[/Recv packet ordered channel mint/]
      ORecv2[/Ack packet succeed for ordered channel/]
      ORecv3[/Send packet escrow for ordered channel/]
    end

    Refresh[/Timeout refresh/]

    Handler                                 --> Transfer
    Handler                                 --> Client
    Handler & Client                        --> Connection
    Handler & Transfer & Connection         --> Channel
    Handler & Mock & Connection             --> OrderedChannel
    Channel & Transfer & Connection         --> MessageExchange
    OrderedChannel & Transfer & Connection  --> OrderedMessageExchange
    Channel & OrderedChannel                --> Refresh
```