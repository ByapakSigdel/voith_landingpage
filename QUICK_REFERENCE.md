# Voith Backend - Quick Reference

## Current Status: ✓ Running & Tested

### Server Info
- **URL**: http://localhost:5000
- **Status**: Running (PID: check with `ps aux | grep node`)
- **Database**: PostgreSQL (Docker container: voith_postgres)

### Quick Commands

#### Using Management Script (Recommended)
```bash
./manage.sh
```
Interactive menu with all options

#### Manual Commands

**Start Everything:**
```bash
docker-compose up -d        # Start PostgreSQL
npm run dev                 # Start server
```

**Stop Everything:**
```bash
# Stop server: Ctrl+C
docker-compose down         # Stop PostgreSQL
```

**Test API:**
```bash
./test-api.sh
```

**Check Status:**
```bash
docker ps | grep voith_postgres    # PostgreSQL status
curl http://localhost:5000/health  # Server health
```

## API Quick Reference

### Public Endpoints (No Auth)

**Get all images:**
```bash
curl http://localhost:5000/api/public/images
```

**Get single image:**
```bash
curl http://localhost:5000/api/public/images/1
```

**Get image file:**
```bash
curl http://localhost:5000/api/public/images/file/[filename]
```

### Admin Endpoints (Auth Required)

**Login:**
```bash
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@voith.com","password":"Admin@123"}'
```

**Upload Image:**
```bash
curl -X POST http://localhost:5000/api/admin/images/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@path/to/image.jpg"
```

**Get all images (with admin details):**
```bash
curl http://localhost:5000/api/admin/images/all \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Delete image:**
```bash
curl -X DELETE http://localhost:5000/api/admin/images/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Get profile:**
```bash
curl http://localhost:5000/api/admin/profile \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Default Credentials
- **Email**: admin@voith.com
- **Password**: Admin@123

## Project Structure
```
voith_backend/
├── database/
│   ├── schema.sql              # Database schema
│   └── migrate.js              # Migration script
├── src/
│   ├── config/
│   │   ├── index.js            # Config loader
│   │   └── database.js         # DB connection pool
│   ├── controllers/
│   │   ├── adminController.js  # Admin auth logic
│   │   ├── imageController.js  # Admin image operations
│   │   └── publicController.js # Public image endpoints
│   ├── middleware/
│   │   ├── auth.js             # JWT verification
│   │   └── upload.js           # Multer config
│   ├── routes/
│   │   ├── admin.js            # Admin routes
│   │   ├── adminImages.js      # Admin image routes
│   │   └── public.js           # Public routes
│   └── index.js                # Main server
├── uploads/images/             # Uploaded images
├── .env                        # Environment variables
├── docker-compose.yml          # PostgreSQL setup
├── manage.sh                   # Management script
├── test-api.sh                 # Test suite
├── README.md                   # Full documentation
└── TESTING_SUMMARY.md          # Test results

```

## Environment Variables (.env)
```
PORT=5000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=voith_db
DB_USER=postgres
DB_PASSWORD=postgres123
JWT_SECRET=your_jwt_secret_key_change_this_in_production
ADMIN_EMAIL=admin@voith.com
ADMIN_PASSWORD=Admin@123
```

## Database Access

**Via Docker:**
```bash
docker exec -it voith_postgres psql -U postgres -d voith_db
```

**Common SQL Commands:**
```sql
\dt                    -- List tables
\d admins             -- Describe admins table
\d images             -- Describe images table
SELECT * FROM admins; -- View admins
SELECT * FROM images; -- View images
```

## Troubleshooting

**Server won't start:**
```bash
# Check if port 5000 is in use
lsof -i :5000
# Kill process if needed
kill -9 PID
```

**Database connection error:**
```bash
# Check PostgreSQL is running
docker ps | grep voith_postgres
# Restart if needed
docker-compose restart
```

**Reset everything:**
```bash
docker-compose down -v  # Remove containers and volumes
docker-compose up -d    # Start fresh
npm run migrate         # Run migration
```

## File Upload Specs
- **Max size**: 5MB
- **Allowed types**: JPEG, JPG, PNG, GIF, WEBP, SVG
- **Storage**: `uploads/images/`
- **Naming**: `image-[timestamp]-[random].ext`

## Security Features
- ✓ JWT authentication
- ✓ Password hashing (bcrypt)
- ✓ CORS enabled
- ✓ File type validation
- ✓ File size limits
- ✓ SQL injection protection (parameterized queries)

## Next Steps
1. Change JWT_SECRET in production
2. Change admin password
3. Set up SSL/TLS for HTTPS
4. Configure production database
5. Set up file storage (S3, etc.)
6. Add rate limiting
7. Add logging service

## Useful Links
- Health Check: http://localhost:5000/health
- API Base: http://localhost:5000/api
- Admin Login: http://localhost:5000/api/admin/login
- Public Images: http://localhost:5000/api/public/images

## Getting Help
- Check server logs: `tail -f server.log`
- Check PostgreSQL logs: `docker logs voith_postgres`
- Run test suite: `./test-api.sh`
- Use management script: `./manage.sh`
