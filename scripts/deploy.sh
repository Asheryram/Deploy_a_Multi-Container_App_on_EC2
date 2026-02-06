#!/bin/bash
# Deploy script that logs all output including Docker daemon errors
# Usage: ./deploy.sh [up|down|logs|status]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/logs"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
DEPLOY_LOG="$LOG_DIR/deploy_${TIMESTAMP}.log"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Create logs directory
mkdir -p "$LOG_DIR"

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$DEPLOY_LOG"
}

info() {
    echo -e "${BLUE}$1${NC}"
}

success() {
    echo -e "${GREEN}$1${NC}"
}

error() {
    echo -e "${RED}$1${NC}"
}

cd "$PROJECT_DIR"

case "${1:-up}" in
    up|start)
        log "=========================================="
        log "Starting deployment"
        log "=========================================="
        log "Log file: $DEPLOY_LOG"
        
        # Run docker compose and capture ALL output (stdout + stderr)
        log "Running: docker compose up --build -d"
        echo "" >> "$DEPLOY_LOG"
        
        if docker compose up --build -d 2>&1 | tee -a "$DEPLOY_LOG"; then
            log ""
            log "Deployment successful!"
        else
            log ""
            log "Deployment failed! Check log: $DEPLOY_LOG"
            exit 1
        fi
        
        # Show container status
        log ""
        log "Container status:"
        docker compose ps 2>&1 | tee -a "$DEPLOY_LOG"
        ;;
        
    down|stop)
        log "Stopping containers..."
        docker compose down 2>&1 | tee -a "$DEPLOY_LOG"
        log "✅ Containers stopped"
        ;;
        
    logs)
        # Show application logs (different from deploy logs)
        SERVICE="${2:-}"
        if [ -n "$SERVICE" ]; then
            docker compose logs -f "$SERVICE"
        else
            docker compose logs -f
        fi
        ;;
        
    status)
        info "Container Status:"
        docker compose ps
        info ""
        info "Recent deploy logs:"
        ls -lt "$LOG_DIR"/*.log 2>/dev/null | head -5
        ;;
        
    clean)
        log "Cleaning up..."
        docker compose down --volumes --remove-orphans 2>&1 | tee -a "$DEPLOY_LOG"
        log "✅ Cleanup complete"
        ;;
        
    *)
        info "Usage: $0 {up|down|logs|status|clean}"
        info ""
        info "Commands:"
        info "  up      - Build and start (logs to logs/deploy_*.log)"
        info "  down    - Stop containers"
        info "  logs    - View container logs (live)"
        info "  status  - Show container status and recent deploy logs"
        info "  clean   - Stop and remove volumes"
        exit 1
        ;;
esac
