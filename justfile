
# 默认任务
default: help

# 显示帮助信息
help:
    @echo "Available tasks:"
    @echo "  setup     - 初始化开发环境"
    @echo "  dev       - 启动开发服务器"
    @echo "  build     - 构建项目"
    @echo "  clean     - 清理构建文件"
    @echo "  db-init   - 初始化数据库"
    @echo "  test      - 运行测试"

# 环境初始化
setup:
    @echo "🔧 Setting up development environment..."
    npm install -g elm elm-format
    npm install -g purescript spago
    cd client && elm make src/Main.elm --output=dist/elm.js
    cd server && spago install
    createdb roommate_manager || true
    @echo "✅ Setup complete!"

# 启动开发服务器
dev:
    @echo "🚀 Starting development servers..."
    @# 并行启动前后端开发服务器
    @(cd server && spago build && node dist/Main.js) &
    @(cd client && elm reactor --port=8000) &
    @echo "Frontend: http://localhost:8000"
    @echo "Backend: http://localhost:3000"

# 构建项目
build: build-frontend build-backend

build-frontend:
    @echo "🏗️  Building frontend..."
    cd client && elm make src/Main.elm --optimize --output=dist/elm.js

build-backend:
    @echo "🏗️  Building backend..."
    cd server && spago build

# 清理构建文件
clean:
    @echo "🧹 Cleaning build files..."
    rm -rf frontend/dist/*
    rm -rf backend/dist/*
    rm -rf backend/.spago
    rm -rf frontend/elm-stuff

# 数据库初始化
db-init:
    @echo "🗄️  Initializing database..."
    psql -d roommate_manager -f database/init.sql
    @for migration in database/migrations/*.sql; do \
        echo "Running migration: $$migration"; \
        psql -d roommate_manager -f "$$migration"; \
    done
    @echo "✅ Database initialized!"

# 数据库重置
db-reset:
    @echo "⚠️  Resetting database..."
    dropdb roommate_manager || true
    createdb roommate_manager
    just db-init

# 运行测试
test: test-frontend test-backend

test-frontend:
    @echo "🧪 Testing frontend..."
    cd client && elm-test

test-backend:
    @echo "🧪 Testing backend..."
    cd server && spago test

# 格式化代码
format:
    @echo "💅 Formatting code..."
    cd client && elm-format --yes src/
    cd server && purescript-tidy format-in-place src/

# 生产环境构建
prod-build: clean build
    @echo "📦 Production build complete!"

# 部署
deploy: prod-build
    @echo "🚀 Deploying..."
    ./scripts/deploy.sh