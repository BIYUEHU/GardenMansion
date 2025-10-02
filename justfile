set windows-shell := ["powershell.exe"]

dir := justfile_directory()
server := dir + "/server"
client := dir + "/client"
db := dir + "/db"

# List all available tasks
default:
  @just --list

# Start vite server
dev-f:
  @echo "🚀 Starting vite server..."
  cd {{client}}; pnpm vite

# Start backend server
dev-b:
  @echo "🚀 Starting backend server..."
  cd {{server}}; pnpx nodemon --ext ".purs .dhall" --exec "spago run"

# Build
build:
  just build-f; just build-d; just build-b

# Build frontend
build-f:
  @echo "🏗️  Building frontend..."
  cd {{client}}; pnpm exec vite build

# Build backend
build-b:
  @echo "🏗️  Building backend..."
  cd {{server}}; spago build

# Build database
build-d:
  @echo "🏗️  Building database..."
  cd {{db}}; idris2 --cg node --build

# Clean build files
clean:
  @echo "🧹 Cleaning build files..."
  rm -rf {{client}}/dist
  rm -rf {{client}}/elm-stuff
  rm -rf {{server}}/output
  rm -rf {{server}}/.spago

# Run tests
test:
  @echo "🧪 Testing backend..."
  cd {{server}}; spago test

# Renerate types
generate:
  @echo "🤖 Generating types..."
  python scripts/generate.py