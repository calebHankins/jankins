#!/bin/bash

# Build script that uses Docker BuildKit for caching Maven dependencies
# This significantly speeds up subsequent builds

set -e

echo "Building jankins Docker image with BuildKit caching..."
echo "This will cache Maven dependencies between builds"

DOCKER_BUILDKIT=1 docker build --progress=plain -t jankins:latest .

echo ""
echo "Build complete! Future builds will use cached Maven dependencies."
echo ""
echo "To run the image:"
echo "  docker run --rm -it jankins:latest bash"
echo ""
echo "To run Jenkins on port 8081:"
echo "  docker run --rm -p 8081:8080 -it jankins:latest"
