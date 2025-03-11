#!/bin/bash
# =================================================================
# Transformers.js Examples - HF Spaces Deployment Script
# =================================================================
#
# This script builds the unified Transformers.js examples application
# using Vite's optimized build process and deploys the resulting
# static files to a Hugging Face Space.
#
# Usage:
#   ./build_and_deploy_to_hf.sh
#
# Vite Build Process Advantages:
#   - Creates highly optimized ES modules bundles with code-splitting
#   - Applies tree-shaking to reduce final bundle size
#   - Uses ES2022 target to enable top-level await in workers
#     (critical for WebGPU feature detection and async initialization)
#   - Processes and optimizes assets like images
#
# Hugging Face Spaces Integration:
#   - Uses the "Static" Spaces SDK for optimal performance
#   - Enables SPA routing via static-app.json configuration
#   - Preserves client-side routing for the React application
#
# Requirements:
#   - Transformers-unified project (created with create_single_app.sh)
#   - Git configured with Hugging Face credentials
#   - Node.js and NPM installed
#
# Troubleshooting:
#   - If facing top-level await errors, verify vite.config.js has target: 'es2022'
#   - For SPA routing issues, check that static-app.json is correctly copied
#
# Author: dwb2023 (Hugging Face) / donbr (GitHub)
# =================================================================

# 1. Build the unified Transformers.js project
cd ./transformers-unified
npm install
npm run build

# 2. Clone your HF Space (or initialize if new)
cd ..
git clone https://huggingface.co/spaces/dwb2023/transformers-js-demos
cd transformers-js-demos

# 3. Copy the built files from the transformers-unified project to the HF Space
#    This assumes the build output is in the 'dist' folder of the
#    transformers-unified project.

cp -r ../transformers-unified/dist/* .

git add .
git commit -m "Update with latest build"
git push