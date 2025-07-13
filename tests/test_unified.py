#!/usr/bin/env python3
"""
Unified Test Suite for LawViksh Backend API
============================================

This single test file covers:
- All API endpoints testing
- Performance testing
- Stress testing
- Database connectivity
- Error handling
- Response validation

Usage:
    python test_unified.py                    # Run all tests
    python test_unified.py --api-only         # API tests only
    python test_unified.py --performance-only # Performance tests only
    python test_unified.py --stress-only      # Stress tests only
    python test_unified.py --url http://localhost:8000  # Custom URL
"""

import asyncio
import aiohttp
import time
import json
import statistics
import argparse
import sys
import os
from datetime import datetime
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor
import threading

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

@dataclass
class TestResult:
    """Test result data structure"""
    test_name: str
    status: str  # 'PASS', 'FAIL', 'ERROR'
    response_time: float
    status_code: int
    error_message: Optional[str] = None
    response_data: Optional[Dict] = None

@dataclass
class PerformanceMetrics:
    """Performance metrics data structure"""
    total_requests: int
    successful_requests: int
    failed_requests: int
    avg_response_time: float
    min_response_time: float
    max_response_time: float
    median_response_time: float
    requests_per_second: float
    total_time: float

class UnifiedAPITester:
    """Comprehensive API and Performance Testing Suite"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url.rstrip('/')
        self.session = None
        self.admin_token = None
        self.test_results = []
        self.performance_metrics = []
        
    async def __aenter__(self):
        """Async context manager entry"""
        self.session = aiohttp.ClientSession(
            timeout=aiohttp.ClientTimeout(total=30),
            headers={'Content-Type': 'application/json'}
        )
        return self
        
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit"""
        if self.session:
            await self.session.close()
    
    async def make_request(self, method: str, endpoint: str, data: Dict = None, 
                          headers: Dict = None, expected_status: int = 200) -> TestResult:
        """Make HTTP request and return test result"""
        url = f"{self.base_url}{endpoint}"
        start_time = time.time()
        
        try:
            if method.upper() == 'GET':
                async with self.session.get(url, headers=headers) as response:
                    response_time = time.time() - start_time
                    response_data = await response.json() if response.headers.get('content-type', '').startswith('application/json') else None
                    
                    return TestResult(
                        test_name=f"{method} {endpoint}",
                        status='PASS' if response.status == expected_status else 'FAIL',
                        response_time=response_time,
                        status_code=response.status,
                        error_message=None if response.status == expected_status else f"Expected {expected_status}, got {response.status}",
                        response_data=response_data
                    )
            else:
                async with self.session.post(url, json=data, headers=headers) as response:
                    response_time = time.time() - start_time
                    response_data = await response.json() if response.headers.get('content-type', '').startswith('application/json') else None
                    
                    return TestResult(
                        test_name=f"{method} {endpoint}",
                        status='PASS' if response.status == expected_status else 'FAIL',
                        response_time=response_time,
                        status_code=response.status,
                        error_message=None if response.status == expected_status else f"Expected {expected_status}, got {response.status}",
                        response_data=response_data
                    )
        except Exception as e:
            response_time = time.time() - start_time
            return TestResult(
                test_name=f"{method} {endpoint}",
                status='ERROR',
                response_time=response_time,
                status_code=0,
                error_message=str(e)
            )
    
    async def test_health_check(self) -> TestResult:
        """Test health check endpoint"""
        return await self.make_request('GET', '/health')
    
    async def test_admin_login(self) -> TestResult:
        """Test admin login and get token"""
        login_data = {
            "username": "admin",
            "password": "admin123"
        }
        result = await self.make_request('POST', '/api/auth/adminlogin', login_data)
        
        if result.status == 'PASS' and result.response_data and result.response_data.get('data'):
            self.admin_token = result.response_data['data'].get('access_token')
        
        return result
    
    async def test_admin_verify(self) -> TestResult:
        """Test admin token verification"""
        if not self.admin_token:
            return TestResult(
                test_name="GET /api/auth/verify",
                status='FAIL',
                response_time=0,
                status_code=0,
                error_message="No admin token available"
            )
        
        headers = {'Authorization': f'Bearer {self.admin_token}'}
        return await self.make_request('GET', '/api/auth/verify', headers=headers)
    
    async def test_user_registration(self) -> TestResult:
        """Test user registration"""
        user_data = {
            "name": "Test User",
            "email": f"testuser{int(time.time())}@example.com",
            "phone_number": "1234567890",
            "gender": "Male",
            "profession": "Lawyer",
            "interest_reason": "Interested in legal blogging"
        }
        return await self.make_request('POST', '/api/users/userdata', user_data)
    
    async def test_creator_registration(self) -> TestResult:
        """Test creator registration"""
        creator_data = {
            "name": "Test Creator",
            "email": f"testcreator{int(time.time())}@example.com",
            "phone_number": "9876543210",
            "gender": "Other",
            "profession": "Other",
            "interest_reason": "Interested in creating legal content"
        }
        return await self.make_request('POST', '/api/users/creatordata', creator_data)
    
    async def test_not_interested(self) -> TestResult:
        """Test not interested form submission"""
        not_interested_data = {
            "name": "Not Interested User",
            "email": f"notinterested{int(time.time())}@example.com",
            "phone_number": "5555555555",
            "gender": "Prefer not to say",
            "profession": "Other",
            "not_interested_reason": "Not relevant",
            "improvement_suggestions": "Platform looks good but not for me",
            "interest_reason": "Not interested in legal blogging"
        }
        return await self.make_request('POST', '/api/users/notinteresteddata', not_interested_data)
    
    async def test_feedback_submission(self) -> TestResult:
        """Test feedback submission with all fields"""
        feedback_data = {
            "name": "Feedback User",
            "email": f"feedback{int(time.time())}@example.com",
            "phone": "1111111111",
            "digital_showcase_rating": 4,
            "online_recognition": "yes",
            "sharing_difficulty": 3,
            "regular_blogging": "yes",
            "ai_tools_frequency": "sometimes",
            "tools_familiarity": 4,
            "core_features": "Easy publishing and analytics",
            "ai_research_opinion": "Very helpful for research",
            "reading_features": "Mobile-friendly interface",
            "portfolio_preference": "Professional layout"
        }
        return await self.make_request('POST', '/api/feedback/submit', feedback_data)
    
    async def test_admin_endpoints(self) -> List[TestResult]:
        """Test all admin-only endpoints"""
        if not self.admin_token:
            return [TestResult(
                test_name="Admin Endpoints",
                status='FAIL',
                response_time=0,
                status_code=0,
                error_message="No admin token available"
            )]
        
        headers = {'Authorization': f'Bearer {self.admin_token}'}
        results = []
        
        # Admin data endpoints
        admin_endpoints = [
            ('GET', '/api/users/registereduserdata'),
            ('GET', '/api/users/registeredcreatordata'),
            ('GET', '/api/users/analytics'),
            ('GET', '/api/feedback/all'),
            ('GET', '/api/feedback/analytics'),
            ('GET', '/api/feedback/summary'),
            ('GET', '/api/data/stats'),
            ('GET', '/api/data/export/json'),
            ('GET', '/api/data/export/userdata'),
            ('GET', '/api/data/export/creatordata'),
            ('GET', '/api/data/export/feedbackdata')
        ]
        
        for method, endpoint in admin_endpoints:
            result = await self.make_request(method, endpoint, headers=headers)
            results.append(result)
        
        return results
    
    async def run_api_tests(self) -> List[TestResult]:
        """Run all API tests"""
        print("🔍 Running API Tests...")
        
        results = []
        
        # Run health check first
        results.append(await self.test_health_check())
        
        # Run admin login first to set the token
        results.append(await self.test_admin_login())
        
        # Now run verify and other tests that depend on the token
        results.append(await self.test_admin_verify())
        results.append(await self.test_user_registration())
        results.append(await self.test_creator_registration())
        results.append(await self.test_not_interested())
        results.append(await self.test_feedback_submission())
        
        # Run admin endpoints (they need the token)
        admin_results = await self.test_admin_endpoints()
        results.extend(admin_results)
        
        return results
    
    async def run_performance_test(self, endpoint: str, method: str = 'GET', 
                                  data: Dict = None, num_requests: int = 100) -> PerformanceMetrics:
        """Run performance test for a specific endpoint"""
        print(f"⚡ Performance Testing: {method} {endpoint}")
        
        response_times = []
        successful_requests = 0
        failed_requests = 0
        
        start_time = time.time()
        
        # Create tasks for concurrent requests
        tasks = []
        for i in range(num_requests):
            task = self.make_request(method, endpoint, data)
            tasks.append(task)
        
        # Execute all requests concurrently
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        end_time = time.time()
        total_time = end_time - start_time
        
        # Process results
        for result in results:
            if isinstance(result, TestResult):
                response_times.append(result.response_time)
                if result.status == 'PASS':
                    successful_requests += 1
                else:
                    failed_requests += 1
            else:
                failed_requests += 1
        
        if response_times:
            return PerformanceMetrics(
                total_requests=num_requests,
                successful_requests=successful_requests,
                failed_requests=failed_requests,
                avg_response_time=statistics.mean(response_times),
                min_response_time=min(response_times),
                max_response_time=max(response_times),
                median_response_time=statistics.median(response_times),
                requests_per_second=successful_requests / total_time if total_time > 0 else 0,
                total_time=total_time
            )
        else:
            return PerformanceMetrics(
                total_requests=num_requests,
                successful_requests=0,
                failed_requests=num_requests,
                avg_response_time=0,
                min_response_time=0,
                max_response_time=0,
                median_response_time=0,
                requests_per_second=0,
                total_time=total_time
            )
    
    async def run_stress_test(self, endpoint: str, method: str = 'GET', 
                             data: Dict = None, num_requests: int = 1000) -> PerformanceMetrics:
        """Run stress test with high load"""
        print(f"🔥 Stress Testing: {method} {endpoint} with {num_requests} requests")
        
        response_times = []
        successful_requests = 0
        failed_requests = 0
        
        start_time = time.time()
        
        # Use semaphore to limit concurrent connections
        semaphore = asyncio.Semaphore(50)  # Max 50 concurrent requests
        
        async def make_request_with_semaphore():
            async with semaphore:
                return await self.make_request(method, endpoint, data)
        
        # Create tasks for concurrent requests
        tasks = [make_request_with_semaphore() for _ in range(num_requests)]
        
        # Execute all requests concurrently
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        end_time = time.time()
        total_time = end_time - start_time
        
        # Process results
        for result in results:
            if isinstance(result, TestResult):
                response_times.append(result.response_time)
                if result.status == 'PASS':
                    successful_requests += 1
                else:
                    failed_requests += 1
            else:
                failed_requests += 1
        
        if response_times:
            return PerformanceMetrics(
                total_requests=num_requests,
                successful_requests=successful_requests,
                failed_requests=failed_requests,
                avg_response_time=statistics.mean(response_times),
                min_response_time=min(response_times),
                max_response_time=max(response_times),
                median_response_time=statistics.median(response_times),
                requests_per_second=successful_requests / total_time if total_time > 0 else 0,
                total_time=total_time
            )
        else:
            return PerformanceMetrics(
                total_requests=num_requests,
                successful_requests=0,
                failed_requests=num_requests,
                avg_response_time=0,
                min_response_time=0,
                max_response_time=0,
                median_response_time=0,
                requests_per_second=0,
                total_time=total_time
            )
    
    async def run_all_performance_tests(self) -> List[PerformanceMetrics]:
        """Run performance tests on key endpoints"""
        print("🚀 Running Performance Tests...")
        
        performance_endpoints = [
            ('GET', '/health'),
            ('GET', '/api/users/analytics'),
            ('GET', '/api/feedback/analytics'),
            ('GET', '/api/data/stats'),
            ('GET', '/api/data/export/json')
        ]
        
        metrics = []
        for method, endpoint in performance_endpoints:
            metric = await self.run_performance_test(endpoint, method, num_requests=50)
            metrics.append(metric)
        
        return metrics
    
    async def run_all_stress_tests(self) -> List[PerformanceMetrics]:
        """Run stress tests on key endpoints"""
        print("💥 Running Stress Tests...")
        
        stress_endpoints = [
            ('GET', '/health'),
            ('GET', '/api/data/stats'),
            ('POST', '/api/users/userdata', {
                "name": "Stress Test User",
                "email": "stresstest@example.com",
                "phone_number": "9999999999",
                "gender": "Male",
                "profession": "Lawyer",
                "interest_reason": "Stress testing"
            })
        ]
        
        metrics = []
        for endpoint_data in stress_endpoints:
            if len(endpoint_data) == 2:
                method, endpoint = endpoint_data
                data = None
            else:
                method, endpoint, data = endpoint_data
            
            metric = await self.run_stress_test(endpoint, method, data, num_requests=200)
            metrics.append(metric)
        
        return metrics
    
    def print_results(self, results: List[TestResult], title: str):
        """Print test results in a formatted way"""
        print(f"\n{'='*60}")
        print(f"📊 {title}")
        print(f"{'='*60}")
        
        passed = sum(1 for r in results if r.status == 'PASS')
        failed = sum(1 for r in results if r.status == 'FAIL')
        errors = sum(1 for r in results if r.status == 'ERROR')
        total = len(results)
        
        print(f"Total Tests: {total}")
        print(f"✅ Passed: {passed}")
        print(f"❌ Failed: {failed}")
        print(f"💥 Errors: {errors}")
        print(f"Success Rate: {(passed/total)*100:.1f}%")
        
        print(f"\n{'='*60}")
        print("📋 Detailed Results:")
        print(f"{'='*60}")
        
        for result in results:
            status_icon = "✅" if result.status == 'PASS' else "❌" if result.status == 'FAIL' else "💥"
            print(f"{status_icon} {result.test_name}")
            print(f"   Status: {result.status} ({result.status_code})")
            print(f"   Response Time: {result.response_time:.3f}s")
            if result.error_message:
                print(f"   Error: {result.error_message}")
            print()
    
    def print_performance_metrics(self, metrics: List[PerformanceMetrics], title: str):
        """Print performance metrics in a formatted way"""
        print(f"\n{'='*60}")
        print(f"📈 {title}")
        print(f"{'='*60}")
        
        for i, metric in enumerate(metrics):
            print(f"\n🔍 Test {i+1}:")
            print(f"   Total Requests: {metric.total_requests}")
            print(f"   Successful: {metric.successful_requests}")
            print(f"   Failed: {metric.failed_requests}")
            print(f"   Success Rate: {(metric.successful_requests/metric.total_requests)*100:.1f}%")
            print(f"   Avg Response Time: {metric.avg_response_time:.3f}s")
            print(f"   Min Response Time: {metric.min_response_time:.3f}s")
            print(f"   Max Response Time: {metric.max_response_time:.3f}s")
            print(f"   Median Response Time: {metric.median_response_time:.3f}s")
            print(f"   Requests/Second: {metric.requests_per_second:.2f}")
            print(f"   Total Time: {metric.total_time:.2f}s")
    
    def save_report(self, api_results: List[TestResult], 
                   performance_metrics: List[PerformanceMetrics],
                   stress_metrics: List[PerformanceMetrics]):
        """Save test report to JSON file"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"unified_test_report_{timestamp}.json"
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "base_url": self.base_url,
            "api_tests": {
                "total": len(api_results),
                "passed": sum(1 for r in api_results if r.status == 'PASS'),
                "failed": sum(1 for r in api_results if r.status == 'FAIL'),
                "errors": sum(1 for r in api_results if r.status == 'ERROR'),
                "success_rate": (sum(1 for r in api_results if r.status == 'PASS') / len(api_results)) * 100 if api_results else 0,
                "results": [
                    {
                        "test_name": r.test_name,
                        "status": r.status,
                        "status_code": r.status_code,
                        "response_time": r.response_time,
                        "error_message": r.error_message
                    } for r in api_results
                ]
            },
            "performance_tests": {
                "total_endpoints": len(performance_metrics),
                "metrics": [
                    {
                        "total_requests": m.total_requests,
                        "successful_requests": m.successful_requests,
                        "failed_requests": m.failed_requests,
                        "avg_response_time": m.avg_response_time,
                        "min_response_time": m.min_response_time,
                        "max_response_time": m.max_response_time,
                        "median_response_time": m.median_response_time,
                        "requests_per_second": m.requests_per_second,
                        "total_time": m.total_time
                    } for m in performance_metrics
                ]
            },
            "stress_tests": {
                "total_endpoints": len(stress_metrics),
                "metrics": [
                    {
                        "total_requests": m.total_requests,
                        "successful_requests": m.successful_requests,
                        "failed_requests": m.failed_requests,
                        "avg_response_time": m.avg_response_time,
                        "min_response_time": m.min_response_time,
                        "max_response_time": m.max_response_time,
                        "median_response_time": m.median_response_time,
                        "requests_per_second": m.requests_per_second,
                        "total_time": m.total_time
                    } for m in stress_metrics
                ]
            }
        }
        
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📄 Test report saved to: {filename}")

async def main():
    """Main test runner"""
    parser = argparse.ArgumentParser(description='Unified API and Performance Testing Suite')
    parser.add_argument('--url', default='http://localhost:8000', help='Base URL for testing')
    parser.add_argument('--api-only', action='store_true', help='Run API tests only')
    parser.add_argument('--performance-only', action='store_true', help='Run performance tests only')
    parser.add_argument('--stress-only', action='store_true', help='Run stress tests only')
    parser.add_argument('--no-check', action='store_true', help='Skip server availability check')
    
    args = parser.parse_args()
    
    print("🚀 LawViksh Backend - Unified Test Suite")
    print("=" * 50)
    print(f"Target URL: {args.url}")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 50)
    
    async with UnifiedAPITester(args.url) as tester:
        # Check server availability
        if not args.no_check:
            print("🔍 Checking server availability...")
            health_result = await tester.test_health_check()
            if health_result.status != 'PASS':
                print(f"❌ Server not available: {health_result.error_message}")
                return
            print("✅ Server is available")
        
        api_results = []
        performance_metrics = []
        stress_metrics = []
        
        # Run API tests
        if not args.performance_only and not args.stress_only:
            api_results = await tester.run_api_tests()
            tester.print_results(api_results, "API Test Results")
        
        # Run performance tests
        if not args.api_only and not args.stress_only:
            performance_metrics = await tester.run_all_performance_tests()
            tester.print_performance_metrics(performance_metrics, "Performance Test Results")
        
        # Run stress tests
        if not args.api_only and not args.performance_only:
            stress_metrics = await tester.run_all_stress_tests()
            tester.print_performance_metrics(stress_metrics, "Stress Test Results")
        
        # Save comprehensive report
        if api_results or performance_metrics or stress_metrics:
            tester.save_report(api_results, performance_metrics, stress_metrics)
        
        print("\n🎉 Testing completed!")

if __name__ == "__main__":
    asyncio.run(main()) 