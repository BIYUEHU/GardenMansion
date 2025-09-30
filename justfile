set windows-shell := ["powershell.exe"]

dir := justfile_directory()
server := dir + "/server"
client := dir + "/client"

elm-build := "elm make src/Main.elm --output=public/main.js"

# List all available tasks
default:
  @just --list

# Start frontend development server
dev-f:
  @echo "🚀 Starting frontend development server..."
  cd {{client}}; pnpx nodemon --ext ".elm" --exec "{{elm-build}} && pnpx vite"

# Start backend development server
dev-b:
  @echo "🚀 Starting backend development server working {{server}}..."
  cd {{server}}; pnpx nodemon --ext ".purs .dhall" --exec "spago run"

# Build frontend
build-f:
  @echo "🏗️  Building frontend..."
  cd {{client}}; {{elm-build}}

# Build backend
build-b:
  @echo "🏗️  Building backend..."
  cd {{server}}; spago build

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
  cd {{server}} && spago test

# Release project
release:
  @echo "📦 Packing project for production..."
  cd {{client}}; "{{elm-build}} --optimize";
  cd {{server}}; spago build
