#!/usr/bin/env python3
"""
Generate Secure Secret Key for JWT
==================================
Utility script to generate a secure secret key for JWT tokens
"""

import secrets
import string

def generate_secret_key(length: int = 32) -> str:
    """Generate a secure secret key"""
    # Use a combination of letters, digits, and special characters
    characters = string.ascii_letters + string.digits + "!@#$%^&*()_+-=[]{}|;:,.<>?"
    return ''.join(secrets.choice(characters) for _ in range(length))

def generate_hex_secret_key(length: int = 64) -> str:
    """Generate a secure hex secret key (recommended for JWT)"""
    return secrets.token_hex(length // 2)

if __name__ == "__main__":
    print("🔐 Generating Secure Secret Keys")
    print("=" * 50)
    
    # Generate different types of secret keys
    print("1. Hex Secret Key (Recommended for JWT):")
    hex_key = generate_hex_secret_key(64)
    print(f"   {hex_key}")
    print()
    
    print("2. Mixed Character Secret Key:")
    mixed_key = generate_secret_key(64)
    print(f"   {mixed_key}")
    print()
    
    print("3. Short Hex Key (32 characters):")
    short_hex = generate_hex_secret_key(32)
    print(f"   {short_hex}")
    print()
    
    print("📝 Usage in config.py:")
    print(f"   secret_key: str = \"{hex_key}\"")
    print()
    
    print("⚠️  Security Notes:")
    print("   - Keep your secret key secure and never commit it to version control")
    print("   - Use environment variables in production")
    print("   - The hex key is recommended for JWT tokens")
    print("   - Minimum recommended length is 32 characters") 