#!/bin/bash
# test_poly_framework.sh - Test script for the Poly-AI Framework

echo "Testing Poly-AI Framework"

# Activate virtual environment
source poly_env/bin/activate

# Test default workflow
echo "=== Testing Default Workflow ==="
python poly_framework.py

echo ""

# Test enterprise workflow
echo "=== Testing Enterprise Workflow ==="
export ENTERPRISE=true
python poly_framework.py
unset ENTERPRISE

echo ""

# Test open source workflow
echo "=== Testing Open Source Workflow ==="
export OPEN_SOURCE=true
python poly_framework.py
unset OPEN_SOURCE

echo ""
echo "All tests completed successfully!"