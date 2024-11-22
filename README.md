# Decentralized Autonomous Music Label (DAML)

## Overview
A Stacks blockchain-based smart contract that implements a decentralized autonomous music label, enabling direct relationships between artists, fans, and investors. The platform facilitates music releases, fan investments, and automated royalty distributions.

## Key Features
- Artist registration and management
- Song releases with customizable pricing
- Fan investment opportunities
- Automated royalty distribution system
- Transparent investment tracking

## Smart Contract Structure

### Data Storage
- `artists`: Manages artist profiles and total investments
- `songs`: Tracks released songs and their details
- `investments`: Records individual investor contributions
- `royalties`: Maintains royalty accounting per song

## Core Functionality

### For Artists
1. **Registration**
    - Register as an artist with a unique identifier
    - Maintain profile information
    - Release songs with custom pricing

2. **Song Management**
    - Release new songs
    - Set song prices
    - Receive automatic royalty payments

### For Investors/Fans
1. **Investment Options**
    - Invest in favorite artists
    - Track investment amounts
    - Earn proportional royalties

2. **Music Purchases**
    - Buy songs directly through the platform
    - Contribute to artist and investor royalties

### Royalty System
- 50/50 split between artists and investors
- Automatic distribution based on investment proportions
- Transparent tracking of royalty accumulation
- Claimable investor royalties

## Functions

### Public Functions
- `register-artist`: Create new artist profile
- `release-song`: Publish new music
- `invest-in-artist`: Make investments in artists
- `buy-song`: Purchase music
- `distribute-royalties`: Trigger royalty distribution
- `claim-investor-royalties`: Collect earned royalties

### Read-Only Functions
- `get-artist-investment`: Check investment amounts
- `get-song-royalties`: View accumulated royalties

## Error Handling
- Owner-only operations protection
- Non-existent resource checks
- Duplicate entry prevention
- Unauthorized action protection

## Technical Requirements
- Stacks blockchain compatibility
- STX token for transactions
- Clarity smart contract language

## Usage Guide

### For Artists
```clarity
;; Register as an artist
(contract-call? .music-label register-artist "Artist Name")

;; Release a song
(contract-call? .music-label release-song artist-id "Song Title" price)
```

### For Investors
```clarity
;; Invest in an artist
(contract-call? .music-label invest-in-artist artist-id amount)

;; Claim royalties
(contract-call? .music-label claim-investor-royalties song-id artist-id)
```

### For Fans
```clarity
;; Purchase a song
(contract-call? .music-label buy-song song-id)
```

## Security Considerations
- Fund safety through smart contract escrow
- Automated and transparent distributions
- Protected administrative functions
- Investment verification systems

## Future Enhancements
- Artist profile metadata expansion
- Advanced royalty distribution models
- Collaborative song support
- NFT integration possibilities
- Governance token implementation

## Contributing
[Insert contribution guidelines]

## License
[Insert appropriate license]

## Support
[Insert support contact information]
