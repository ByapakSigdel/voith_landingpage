#!/bin/bash

# Voith Backend Management Script

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_menu() {
    echo -e "${YELLOW}╔════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   Voith Backend Management Script     ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "1. Start PostgreSQL (Docker)"
    echo "2. Stop PostgreSQL (Docker)"
    echo "3. Run Database Migration"
    echo "4. Start Server (Development)"
    echo "5. Start Server (Production)"
    echo "6. Run API Tests"
    echo "7. View Server Logs"
    echo "8. View Database Tables"
    echo "9. Check System Status"
    echo "10. Reset Database (DANGER)"
    echo "0. Exit"
    echo ""
}

start_postgres() {
    echo -e "${YELLOW}Starting PostgreSQL...${NC}"
    docker-compose up -d
    sleep 3
    if docker ps | grep -q voith_postgres; then
        echo -e "${GREEN}✓ PostgreSQL started successfully${NC}"
    else
        echo -e "${RED}✗ Failed to start PostgreSQL${NC}"
    fi
}

stop_postgres() {
    echo -e "${YELLOW}Stopping PostgreSQL...${NC}"
    docker-compose down
    echo -e "${GREEN}✓ PostgreSQL stopped${NC}"
}

run_migration() {
    echo -e "${YELLOW}Running database migration...${NC}"
    npm run migrate
}

start_dev() {
    echo -e "${YELLOW}Starting server in development mode...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    npm run dev
}

start_prod() {
    echo -e "${YELLOW}Starting server in production mode...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    npm start
}

run_tests() {
    echo -e "${YELLOW}Running API tests...${NC}"
    if [ -f "test-api.sh" ]; then
        ./test-api.sh
    else
        echo -e "${RED}✗ test-api.sh not found${NC}"
    fi
}

view_logs() {
    echo -e "${YELLOW}Recent server logs:${NC}"
    if [ -f "server.log" ]; then
        tail -50 server.log
    else
        echo -e "${RED}✗ server.log not found${NC}"
    fi
}

view_tables() {
    echo -e "${YELLOW}Database Tables:${NC}"
    docker exec voith_postgres psql -U postgres -d voith_db -c "\dt"
    echo ""
    echo -e "${YELLOW}Admins:${NC}"
    docker exec voith_postgres psql -U postgres -d voith_db -c "SELECT id, email, created_at FROM admins;"
    echo ""
    echo -e "${YELLOW}Images:${NC}"
    docker exec voith_postgres psql -U postgres -d voith_db -c "SELECT id, original_name, mime_type, size, created_at FROM images;"
}

check_status() {
    echo -e "${YELLOW}System Status:${NC}"
    echo ""
    
    # Check PostgreSQL
    if docker ps | grep -q voith_postgres; then
        echo -e "${GREEN}✓ PostgreSQL: Running${NC}"
    else
        echo -e "${RED}✗ PostgreSQL: Not Running${NC}"
    fi
    
    # Check Server
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Server: Running on port 5000${NC}"
    else
        echo -e "${RED}✗ Server: Not Running${NC}"
    fi
    
    # Check Database Connection
    if docker exec voith_postgres psql -U postgres -d voith_db -c "SELECT 1;" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Database: Connected${NC}"
    else
        echo -e "${RED}✗ Database: Not Connected${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Database Info:${NC}"
    ADMIN_COUNT=$(docker exec voith_postgres psql -U postgres -d voith_db -t -c "SELECT COUNT(*) FROM admins;" 2>/dev/null | tr -d ' ')
    IMAGE_COUNT=$(docker exec voith_postgres psql -U postgres -d voith_db -t -c "SELECT COUNT(*) FROM images;" 2>/dev/null | tr -d ' ')
    
    echo "Admins: $ADMIN_COUNT"
    echo "Images: $IMAGE_COUNT"
}

reset_database() {
    echo -e "${RED}WARNING: This will delete all data!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        echo -e "${YELLOW}Resetting database...${NC}"
        docker exec voith_postgres psql -U postgres -d voith_db -c "DROP TABLE IF EXISTS images CASCADE;"
        docker exec voith_postgres psql -U postgres -d voith_db -c "DROP TABLE IF EXISTS admins CASCADE;"
        npm run migrate
        echo -e "${GREEN}✓ Database reset complete${NC}"
    else
        echo -e "${YELLOW}Reset cancelled${NC}"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Choose an option: " choice
    echo ""
    
    case $choice in
        1) start_postgres ;;
        2) stop_postgres ;;
        3) run_migration ;;
        4) start_dev ;;
        5) start_prod ;;
        6) run_tests ;;
        7) view_logs ;;
        8) view_tables ;;
        9) check_status ;;
        10) reset_database ;;
        0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    clear
done
