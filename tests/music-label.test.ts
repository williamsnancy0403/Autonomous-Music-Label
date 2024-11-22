import { describe, it, expect, beforeEach } from 'vitest';

// Mock Clarity contract state
let artists = new Map();
let songs = new Map();
let investments = new Map();
let royalties = new Map();
let artistIdNonce = 0;
let songIdNonce = 0;

// Mock Clarity functions
function registerArtist(name: string): { type: string; value: number } {
  const newId = ++artistIdNonce;
  if (artists.has(newId)) {
    return { type: 'err', value: 102 }; // err-already-exists
  }
  artists.set(newId, { name, address: 'artist_address', total_investment: 0 });
  return { type: 'ok', value: newId };
}

function releaseSong(artistId: number, title: string, price: number): { type: string; value: number } {
  if (!artists.has(artistId)) {
    return { type: 'err', value: 101 }; // err-not-found
  }
  const newId = ++songIdNonce;
  songs.set(newId, { artist_id: artistId, title, price });
  return { type: 'ok', value: newId };
}

function investInArtist(caller: string, artistId: number, amount: number): { type: string; value: boolean } {
  const artist = artists.get(artistId);
  if (!artist) {
    return { type: 'err', value: 101 }; // err-not-found
  }
  const currentInvestment = investments.get(`${caller}-${artistId}`) || 0;
  investments.set(`${caller}-${artistId}`, currentInvestment + amount);
  artist.total_investment += amount;
  return { type: 'ok', value: true };
}

function buySong(caller: string, songId: number): { type: string; value: boolean } {
  const song = songs.get(songId);
  if (!song) {
    return { type: 'err', value: 101 }; // err-not-found
  }
  const currentRoyalties = royalties.get(songId) || 0;
  royalties.set(songId, currentRoyalties + song.price);
  return { type: 'ok', value: true };
}

function distributeRoyalties(songId: number): { type: string; value: boolean } {
  const royaltyAmount = royalties.get(songId);
  if (!royaltyAmount || royaltyAmount <= 0) {
    return { type: 'err', value: 103 }; // err-unauthorized
  }
  royalties.set(songId, 0);
  // In a real implementation, we would distribute royalties here
  return { type: 'ok', value: true };
}

describe('Decentralized Autonomous Music Label', () => {
  beforeEach(() => {
    artists.clear();
    songs.clear();
    investments.clear();
    royalties.clear();
    artistIdNonce = 0;
    songIdNonce = 0;
  });
  
  it('should allow artists to register', () => {
    const result = registerArtist('Test Artist');
    expect(result.type).toBe('ok');
    expect(result.value).toBe(1);
    expect(artists.size).toBe(1);
    expect(artists.get(1)?.name).toBe('Test Artist');
  });
  
  it('should allow registered artists to release songs', () => {
    registerArtist('Test Artist');
    const result = releaseSong(1, 'Test Song', 100);
    expect(result.type).toBe('ok');
    expect(result.value).toBe(1);
    expect(songs.size).toBe(1);
    expect(songs.get(1)?.title).toBe('Test Song');
  });
  
  it('should allow fans to invest in artists', () => {
    registerArtist('Test Artist');
    const result = investInArtist('fan1', 1, 1000);
    expect(result.type).toBe('ok');
    expect(result.value).toBe(true);
    expect(investments.get('fan1-1')).toBe(1000);
    expect(artists.get(1)?.total_investment).toBe(1000);
  });
  
  it('should allow users to buy songs', () => {
    registerArtist('Test Artist');
    releaseSong(1, 'Test Song', 100);
    const result = buySong('user1', 1);
    expect(result.type).toBe('ok');
    expect(result.value).toBe(true);
    expect(royalties.get(1)).toBe(100);
  });
  
  it('should allow royalty distribution', () => {
    registerArtist('Test Artist');
    releaseSong(1, 'Test Song', 100);
    buySong('user1', 1);
    const result = distributeRoyalties(1);
    expect(result.type).toBe('ok');
    expect(result.value).toBe(true);
    expect(royalties.get(1)).toBe(0);
  });
  
  it('should not allow unregistered artists to release songs', () => {
    const result = releaseSong(1, 'Test Song', 100);
    expect(result.type).toBe('err');
    expect(result.value).toBe(101); // err-not-found
  });
  
  it('should not allow royalty distribution for songs with no royalties', () => {
    registerArtist('Test Artist');
    releaseSong(1, 'Test Song', 100);
    const result = distributeRoyalties(1);
    expect(result.type).toBe('err');
    expect(result.value).toBe(103); // err-unauthorized
  });
});

