# Voith Backend Server

A backend server built with Express.js and PostgreSQL for a company landing page with admin panel functionality for image management.

## Features

- Admin authentication with JWT
- Image upload functionality (admin only)
- Public API to fetch images without authentication
- PostgreSQL database with connection pooling
- Secure password hashing with bcryptjs
- CORS enabled
- Error handling middleware
- File validation (images only, max 5MB)

## Prerequisites

- Node.js (v14 or higher)
- PostgreSQL (v12 or higher)
- npm or yarn

## Installation

1. Clone the repository and install dependencies:

```bash
npm install
```

2. Configure environment variables:

Copy `.env.example` to `.env` and update the values:

```bash
cp .env.example .env
```

Edit `.env` file:

```
PORT=5000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=voith_db
DB_USER=postgres
DB_PASSWORD=your_password

# JWT Secret (change this to a secure random string)
JWT_SECRET=your_jwt_secret_key_change_this_in_production

# Admin Credentials (for initial setup)
ADMIN_EMAIL=admin@voith.com
ADMIN_PASSWORD=Admin@123
```

3. Create the PostgreSQL database:

```bash
psql -U postgres
CREATE DATABASE voith_db;
\q
```

4. Run database migration:

```bash
npm run migrate
```

This will create the required tables and a default admin user.

## Running the Server

### Development mode (with auto-restart):

```bash
npm run dev
```

### Production mode:

```bash
npm start
```

The server will run on `http://localhost:5000` (or the port specified in .env)

## API Endpoints

### Health Check

```
GET /health
```

### Admin Routes (Authentication Required)

#### Login
```
POST /api/admin/login
Content-Type: application/json

{
  "email": "admin@voith.com",
  "password": "Admin@123"
}

Response:
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt_token_here",
    "admin": {
      "id": 1,
      "email": "admin@voith.com"
    }
  }
}
```

#### Get Admin Profile
```
GET /api/admin/profile
Authorization: Bearer <token>
```

#### Upload Image
```
POST /api/admin/images/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

Field name: image
File: [your image file]

Response:
{
  "success": true,
  "message": "Image uploaded successfully",
  "data": {
    "id": 1,
    "filename": "image-1234567890.jpg",
    "original_name": "photo.jpg",
    "mime_type": "image/jpeg",
    "size": 12345,
    "path": "/path/to/uploads/image-1234567890.jpg",
    "uploaded_by": 1,
    "created_at": "2026-01-20T..."
  }
}
```

#### Get All Images (Admin View)
```
GET /api/admin/images/all
Authorization: Bearer <token>
```

#### Delete Image
```
DELETE /api/admin/images/:id
Authorization: Bearer <token>
```

### Public Routes (No Authentication Required)

#### Get All Images
```
GET /api/public/images

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "filename": "image-1234567890.jpg",
      "original_name": "photo.jpg",
      "mime_type": "image/jpeg",
      "size": 12345,
      "created_at": "2026-01-20T..."
    }
  ]
}
```

#### Get Single Image by ID
```
GET /api/public/images/:id
```

#### Get Image File
```
GET /api/public/images/file/:filename
```

## Project Structure

```
voith_backend/
├── database/
│   ├── schema.sql          # Database schema
│   └── migrate.js          # Migration script
├── src/
│   ├── config/
│   │   ├── index.js        # Configuration
│   │   └── database.js     # Database connection
│   ├── controllers/
│   │   ├── adminController.js
│   │   ├── imageController.js
│   │   └── publicController.js
│   ├── middleware/
│   │   ├── auth.js         # JWT authentication
│   │   └── upload.js       # Multer configuration
│   ├── routes/
│   │   ├── admin.js        # Admin auth routes
│   │   ├── adminImages.js  # Admin image routes
│   │   └── public.js       # Public routes
│   └── index.js            # Main server file
├── uploads/
│   └── images/             # Uploaded images storage
├── .env                    # Environment variables
├── .env.example            # Example environment file
├── .gitignore
└── package.json
```

## Security Notes

- Change the `JWT_SECRET` in `.env` to a secure random string in production
- Change the default admin password after first login
- The uploads directory is ignored by git to prevent committing uploaded files
- Images are validated for type and size before upload
- All admin routes require JWT authentication

## Image Upload Specifications

- Allowed formats: JPEG, JPG, PNG, GIF, WEBP, SVG
- Maximum file size: 5MB
- Files are stored in `uploads/images/` directory
- Filenames are automatically generated with timestamps to prevent conflicts

## Development

To add new features or modify the backend:

1. Controllers are in `src/controllers/`
2. Routes are defined in `src/routes/`
3. Middleware is in `src/middleware/`
4. Database queries use the connection pool from `src/config/database.js`

## Troubleshooting

### Database connection issues:
- Ensure PostgreSQL is running
- Check database credentials in `.env`
- Verify the database exists

### Migration fails:
- Make sure the database exists
- Check PostgreSQL user permissions
- Verify the connection settings in `.env`

### File upload issues:
- Check that `uploads/images/` directory exists and has write permissions
- Verify file size is under 5MB
- Ensure file type is an allowed image format
# voith_landingpage
# voith_landingpage
# voith_landingpage
