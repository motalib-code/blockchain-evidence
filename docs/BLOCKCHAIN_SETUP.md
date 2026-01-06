# Blockchain Network Configuration

## Supported Networks

EVID-DGC supports multiple Ethereum networks for wallet connectivity:

### Mainnet (Production)
```javascript
// Network ID: 1
{
  chainId: '0x1',
  chainName: 'Ethereum Mainnet',
  rpcUrls: ['https://mainnet.infura.io/v3/YOUR_INFURA_KEY'],
  nativeCurrency: {
    name: 'Ether',
    symbol: 'ETH',
    decimals: 18
  }
}
```

### Sepolia Testnet (Recommended for Testing)
```javascript
// Network ID: 11155111
{
  chainId: '0xaa36a7',
  chainName: 'Sepolia Testnet',
  rpcUrls: ['https://sepolia.infura.io/v3/YOUR_INFURA_KEY'],
  nativeCurrency: {
    name: 'Sepolia Ether',
    symbol: 'SEP',
    decimals: 18
  }
}
```

### Goerli Testnet
```javascript
// Network ID: 5
{
  chainId: '0x5',
  chainName: 'Goerli Testnet',
  rpcUrls: ['https://goerli.infura.io/v3/YOUR_INFURA_KEY'],
  nativeCurrency: {
    name: 'Goerli Ether',
    symbol: 'GoETH',
    decimals: 18
  }
}
```

## MetaMask Configuration

### Adding Custom Networks

1. **Open MetaMask**
2. **Click Network Dropdown**
3. **Select "Add Network"**
4. **Enter Network Details**

### Sepolia Testnet Setup
```
Network Name: Sepolia Testnet
New RPC URL: https://sepolia.infura.io/v3/YOUR_INFURA_KEY
Chain ID: 11155111
Currency Symbol: SEP
Block Explorer URL: https://sepolia.etherscan.io
```

## Getting Test ETH

### Sepolia Faucets
- [Sepolia Faucet](https://sepoliafaucet.com/)
- [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)
- [Infura Sepolia Faucet](https://www.infura.io/faucet)

### Goerli Faucets
- [Goerli Faucet](https://goerlifaucet.com/)
- [Alchemy Goerli Faucet](https://goerlifaucet.com/)

## Network Detection

The application automatically detects the connected network:

```javascript
// Check current network
const chainId = await window.ethereum.request({ method: 'eth_chainId' });

// Switch network if needed
await window.ethereum.request({
  method: 'wallet_switchEthereumChain',
  params: [{ chainId: '0xaa36a7' }], // Sepolia
});
```

## Production Recommendations

- **Use Mainnet** for production deployments
- **Use Sepolia** for testing and development
- **Configure RPC endpoints** with reliable providers (Infura, Alchemy)
- **Monitor gas prices** for optimal transaction costs