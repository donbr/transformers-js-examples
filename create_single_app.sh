#!/bin/bash
# =================================================================
# Transformers.js Examples Unifier
# =================================================================
#
# This script creates a unified showcase application that combines
# multiple standalone Transformers.js example apps into a single
# React application with shared navigation and consistent UI.
#
# Usage:
#   ./create_single_app.sh [output_dir]
#
# Parameters:
#   output_dir - Optional target directory name (default: transformers-unified)
#
# Requirements:
#   - Bash shell environment
#   - Individual example directories in the current folder
#   - Standard Unix commands (cp, mkdir, find, sed, etc.)
#
# Author: dwb2023 (Hugging Face) / donbr (GitHub)
#
# Kudos to the original authors of https://github.com/huggingface/transformers.js-examples
# =================================================================

set -e # Exit immediately if any command fails

# Configuration
PROJECT_NAME="${1:-transformers-unified}"  # Use first argument or default
SOURCE_DIR="."
TARGET_DIR="./${PROJECT_NAME}"

# =================================================================
# 1. Project Setup
# =================================================================
echo "Creating project: ${PROJECT_NAME}"
mkdir -p ${TARGET_DIR}
mkdir -p ${TARGET_DIR}/src
mkdir -p ${TARGET_DIR}/public

# Create package.json with combined dependencies
echo "Setting up package.json..."
cat > ${TARGET_DIR}/package.json << 'EOF'
{
  "name": "transformers-unified",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint .",
    "preview": "vite preview"
  },
  "dependencies": {
    "@huggingface/transformers": "^3.2.2",
    "dompurify": "^3.1.2",
    "marked": "^12.0.2",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.22.3",
    "motion": "^11.12.0",
    "outetts": "github:xenova/OuteTTS"
  },
  "devDependencies": {
    "@eslint/js": "^9.17.0",
    "@vitejs/plugin-react": "^4.3.4",
    "autoprefixer": "^10.4.20",
    "eslint": "^9.17.0",
    "eslint-plugin-react": "^7.37.2",
    "eslint-plugin-react-hooks": "^5.0.0",
    "eslint-plugin-react-refresh": "^0.4.16",
    "globals": "^15.13.0",
    "postcss": "^8.4.49", 
    "tailwindcss": "^3.4.15",
    "vite": "^6.0.3"
  }
}
EOF

# Copy Vite config but update it for the hub approach
echo "Setting up Vite config..."
cat > ${TARGET_DIR}/vite.config.js << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  worker: {
    format: 'es',
  },
  optimizeDeps: {
    exclude: ['@huggingface/transformers'],
  },
  build: {
    target: 'es2022', // Allow top-level await in workers
  }
});
EOF

# Create tailwind config
echo "Setting up Tailwind..."
cat > ${TARGET_DIR}/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat > ${TARGET_DIR}/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# =================================================================
# 2. Project Common Files
# =================================================================
echo "Setting up common files..."
cat > ${TARGET_DIR}/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/logo.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Transformers.js Examples</title>
    <!-- Add MathJax configuration -->
    <script>
      window.MathJax = {
        tex: { inlineMath: [["$", "$"], ["\\(", "\\)"]] },
        svg: { fontCache: "global" }
      };
    </script>
    <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# Create static-app.json for SPA routing (needed for HF Spaces)
echo "Creating static-app.json for SPA routing..."
cat > ${TARGET_DIR}/static-app.json << 'EOF'
{"route": "/*", "to": "/index.html", "status": 200}
EOF

# Create main entry point
cat > ${TARGET_DIR}/src/main.jsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App.jsx';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
);
EOF

# Create CSS
cat > ${TARGET_DIR}/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;
  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

body {
  margin: 0;
  min-height: 100vh;
}
EOF

# Create main App with router
cat > ${TARGET_DIR}/src/App.jsx << 'EOF'
import React from 'react';
import { Routes, Route, Link } from 'react-router-dom';
import HomePage from './HomePage';

// Dynamic imports for each example
const LlamaDemo = React.lazy(() => import('./demos/llama/App'));
const PhiDemo = React.lazy(() => import('./demos/phi/App'));
const JanusDemo = React.lazy(() => import('./demos/janus/App'));
const FlorenceDemo = React.lazy(() => import('./demos/florence/App'));
const CrossEncoderDemo = React.lazy(() => import('./demos/cross-encoder/App'));
const ZeroShotDemo = React.lazy(() => import('./demos/zero-shot/App'));
const SpeechT5Demo = React.lazy(() => import('./demos/speecht5/App'));
const TTSDemo = React.lazy(() => import('./demos/tts/App'));

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow p-4">
        <div className="container mx-auto">
          <Link to="/" className="text-blue-600 hover:text-blue-800">
            ← Back to Examples
          </Link>
        </div>
      </header>

      <main className="container mx-auto p-4">
        <React.Suspense fallback={<div className="flex justify-center py-20">Loading example...</div>}>
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/llama" element={<LlamaDemo />} />
            <Route path="/phi" element={<PhiDemo />} />
            <Route path="/janus" element={<JanusDemo />} />
            <Route path="/florence" element={<FlorenceDemo />} />
            <Route path="/cross-encoder" element={<CrossEncoderDemo />} />
            <Route path="/zero-shot" element={<ZeroShotDemo />} />
            <Route path="/speecht5" element={<SpeechT5Demo />} />
            <Route path="/tts" element={<TTSDemo />} />
          </Routes>
        </React.Suspense>
      </main>
    </div>
  );
}

export default App;
EOF

# Create HomePage component
cat > ${TARGET_DIR}/src/HomePage.jsx << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const demoList = [
  {
    id: 'llama',
    name: 'Llama 3.2',
    description: 'Text generation with Llama 3.2 using WebGPU acceleration',
    category: 'text-generation',
    requiresWebGPU: true
  },
  {
    id: 'phi',
    name: 'Phi 3.5',
    description: 'Text generation with Phi 3.5 using WebGPU acceleration',
    category: 'text-generation',
    requiresWebGPU: true
  },
  {
    id: 'janus',
    name: 'Janus',
    description: 'Multimodal text generation with image creation capabilities',
    category: 'multimodal',
    requiresWebGPU: true
  },
  {
    id: 'florence',
    name: 'Florence 2',
    description: 'Vision model for image understanding and captioning',
    category: 'vision',
    requiresWebGPU: true
  },
  {
    id: 'cross-encoder',
    name: 'Cross Encoder',
    description: 'Text similarity and relevance scoring',
    category: 'classification',
    requiresWebGPU: false
  },
  {
    id: 'zero-shot',
    name: 'Zero-Shot Classification',
    description: 'Classify text without specific training',
    category: 'classification',
    requiresWebGPU: false
  },
  {
    id: 'speecht5',
    name: 'SpeechT5',
    description: 'Convert text to speech',
    category: 'audio',
    requiresWebGPU: false
  },
  {
    id: 'tts',
    name: 'Text-to-Speech WebGPU',
    description: 'Generate speech from text with WebGPU acceleration',
    category: 'audio',
    requiresWebGPU: true
  }
];

// Group demos by category
const groupedDemos = demoList.reduce((acc, demo) => {
  if (!acc[demo.category]) {
    acc[demo.category] = [];
  }
  acc[demo.category].push(demo);
  return acc;
}, {});

// Map category to friendly names
const categoryNames = {
  'text-generation': 'Text Generation',
  'classification': 'Text Classification',
  'vision': 'Computer Vision',
  'audio': 'Audio Processing',
  'multimodal': 'Multimodal'
};

function HomePage() {
  const [hasWebGPU, setHasWebGPU] = useState(false);
  
  useEffect(() => {
    // Check for WebGPU support
    setHasWebGPU(typeof navigator !== 'undefined' && navigator.gpu !== undefined);
  }, []);

  return (
    <div className="max-w-5xl mx-auto">
      <h1 className="text-3xl font-bold mb-2">Transformers.js Examples</h1>
      <p className="mb-8 text-gray-600">
        Run machine learning models directly in your browser
      </p>
      
      {!hasWebGPU && (
        <div className="mb-6 p-4 bg-yellow-50 border-l-4 border-yellow-400 text-yellow-800">
          <p><strong>Note:</strong> WebGPU is not detected in your browser. Examples marked with ⚡ require WebGPU support and may not work properly.</p>
        </div>
      )}
      
      {Object.entries(groupedDemos).map(([category, demos]) => (
        <section key={category} className="mb-8">
          <h2 className="text-xl font-semibold mb-4 pb-2 border-b">
            {categoryNames[category] || category}
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {demos.map(demo => {
              const isDisabled = demo.requiresWebGPU && !hasWebGPU;
              
              return (
                <Link
                  key={demo.id}
                  to={isDisabled ? '#' : `/${demo.id}`}
                  className={`block p-4 border rounded-lg hover:bg-gray-50 transition ${
                    isDisabled ? 'opacity-60 cursor-not-allowed' : ''
                  }`}
                  onClick={e => isDisabled && e.preventDefault()}
                >
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-medium text-lg">{demo.name}</h3>
                    {demo.requiresWebGPU && <span title="Requires WebGPU">⚡</span>}
                  </div>
                  <p className="text-gray-600 text-sm">{demo.description}</p>
                </Link>
              );
            })}
          </div>
        </section>
      ))}
    </div>
  );
}

export default HomePage;
EOF

# =================================================================
# 3. Demo Integration
# =================================================================
# Setup demo dirs
mkdir -p ${TARGET_DIR}/src/demos

# Function to copy and adapt an example to the unified structure
copy_example() {
  local EXAMPLE_NAME=$1
  local DEST_NAME=$2
  
  echo "Copying ${EXAMPLE_NAME} to demos/${DEST_NAME}..."

  # Create demo directory
  mkdir -p ${TARGET_DIR}/src/demos/${DEST_NAME}

  # Copy source files
  cp -r ${SOURCE_DIR}/${EXAMPLE_NAME}/src/* ${TARGET_DIR}/src/demos/${DEST_NAME}/
  
  # Fix relative imports
  find ${TARGET_DIR}/src/demos/${DEST_NAME} -type f \( -name "*.js" -o -name "*.jsx" \) \
    -exec sed -i 's,from "./,from ".\/,g' {} \;
  find ${TARGET_DIR}/src/demos/${DEST_NAME} -type f \( -name "*.js" -o -name "*.jsx" \) \
    -exec sed -i 's,from "../,from "..\/,g' {} \;
  
  # Fix logo and asset paths - make these resilient to no matches
  LOGO_FILES=$(find ${TARGET_DIR}/src/demos/${DEST_NAME} -type f \( -name "*.js" -o -name "*.jsx" \) | xargs grep -l "logo" 2>/dev/null || echo "")
  if [ -n "$LOGO_FILES" ]; then
    echo "$LOGO_FILES" | xargs sed -i 's,/logo,/demos/'${DEST_NAME}'/logo,g'
  fi
  
  ASSET_FILES=$(find ${TARGET_DIR}/src/demos/${DEST_NAME} -type f \( -name "*.js" -o -name "*.jsx" \) | xargs grep -l "assets" 2>/dev/null || echo "")
  if [ -n "$ASSET_FILES" ]; then
    echo "$ASSET_FILES" | xargs sed -i 's,/assets,/demos/'${DEST_NAME}'/assets,g'
  fi
}

# =================================================================
# 4. Copy Individual Examples
# =================================================================
echo "Copying example apps..."
copy_example "llama-3.2-webgpu" "llama"
copy_example "phi-3.5-webgpu" "phi"
copy_example "janus-webgpu" "janus"
copy_example "florence2-webgpu" "florence"
copy_example "cross-encoder" "cross-encoder"
copy_example "zero-shot-classification" "zero-shot"
copy_example "speecht5-web" "speecht5"
copy_example "text-to-speech-webgpu" "tts"

# =================================================================
# 5. Completion
# =================================================================
echo "Done! Project created at ${TARGET_DIR}"
echo "To start the app, run:"
echo "  cd ${TARGET_DIR}"
echo "  npm install"
echo "  npm run dev"