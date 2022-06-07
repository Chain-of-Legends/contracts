# Setup guide
    npm install
    npm install truffle
    npm install ganache
# How to run

    truffle compile
    ganache-cli  --port 7545  --db="./data/save/" -i="5777" -d --mnemonic="culture arch dinner charge holiday hamster dentist speak start frame update kitchen"
    // to change time add this: --time 2022-03-31T15:53:00+00:00

    truffle deploy


# How to Test
This command will run tests under `test` folder 
    truffle test


# How to verify contract

    truffle run verify tokenName@addressOnBlockChain --network networkName

Example:

    truffle run verify ColToken@0x4027d91eCD3140e53AE743d657549adfeEbB27AB --network bsc