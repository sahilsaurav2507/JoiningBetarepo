#!/usr/bin/env python3
"""
Simple Test Runner for Unified Test Suite
=========================================

A wrapper script to run the unified test suite with better formatting
and easy access to common test scenarios.
"""

import sys
import os
import subprocess
from datetime import datetime

def print_banner():
    """Print test suite banner"""
    print("🚀 LawViksh Backend - Unified Test Suite")
    print("=" * 50)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 50)

def run_test(test_type="all", url="http://localhost:8000"):
    """Run the unified test suite"""
    print_banner()
    
    # Build command
    cmd = [sys.executable, "test_unified.py"]
    
    if test_type == "api":
        cmd.append("--api-only")
    elif test_type == "performance":
        cmd.append("--performance-only")
    elif test_type == "stress":
        cmd.append("--stress-only")
    
    if url != "http://localhost:8000":
        cmd.extend(["--url", url])
    
    print(f"Running: {' '.join(cmd)}")
    print()
    
    # Run the test
    try:
        result = subprocess.run(cmd, check=True)
        print("\n✅ Tests completed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Tests failed with exit code: {e.returncode}")
        return False
    except KeyboardInterrupt:
        print("\n⏹️  Tests interrupted by user")
        return False

def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python run_unified_tests.py [test_type] [url]")
        print()
        print("Test Types:")
        print("  all          - Run all tests (default)")
        print("  api          - API tests only")
        print("  performance  - Performance tests only")
        print("  stress       - Stress tests only")
        print()
        print("Examples:")
        print("  python run_unified_tests.py")
        print("  python run_unified_tests.py api")
        print("  python run_unified_tests.py performance")
        print("  python run_unified_tests.py stress")
        print("  python run_unified_tests.py all http://your-server:8000")
        return
    
    test_type = sys.argv[1] if len(sys.argv) > 1 else "all"
    url = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:8000"
    
    # Validate test type
    valid_types = ["all", "api", "performance", "stress"]
    if test_type not in valid_types:
        print(f"❌ Invalid test type: {test_type}")
        print(f"Valid types: {', '.join(valid_types)}")
        return
    
    # Run the test
    success = run_test(test_type, url)
    
    if success:
        print("\n🎉 All tests passed!")
    else:
        print("\n💥 Some tests failed. Check the output above for details.")
        sys.exit(1)

if __name__ == "__main__":
    main() 