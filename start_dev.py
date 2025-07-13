#!/usr/bin/env python3
"""
Development startup script for LawViksh Backend
This script sets up the development environment and starts the server
"""

import os
import sys
import subprocess

def install_dependencies():
    """Install required dependencies"""
    print("📦 Installing dependencies...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Dependencies installed successfully")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error installing dependencies: {e}")
        return False
    return True

def start_server():
    """Start the development server"""
    print("🚀 Starting LawViksh Backend Server...")
    print("📝 Using SQLite database for development")
    print("🔗 Server will be available at: http://localhost:8000")
    print("📚 API Documentation: http://localhost:8000/docs")
    print("🏥 Health Check: http://localhost:8000/health")
    print("\n" + "="*50)
    
    try:
        # Start the server
        subprocess.run([sys.executable, "appmain.py"])
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Error starting server: {e}")

def main():
    """Main function"""
    print("🎯 LawViksh Backend - Development Setup")
    print("="*50)
    
    # Check if we're in the right directory
    if not os.path.exists("appmain.py"):
        print("❌ Error: Please run this script from the project root directory")
        return
    
    # Install dependencies
    if not install_dependencies():
        return
    
    # Start server
    start_server()

if __name__ == "__main__":
    main() 