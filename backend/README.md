# Ikiraha Backend API

A secure Node.js backend API for the Ikiraha Food Ordering App with authentication, built with Express, MySQL, bcrypt, and JWT.

## Features

### 🔐 Authentication & Security
- **JWT Authentication** with access and refresh tokens
- **bcrypt Password Hashing** with configurable salt rounds
- **Password Reset** functionality with secure tokens
- **Rate Limiting** to prevent abuse
- **CORS Protection** with configurable origins
- **Helmet Security** headers
- **Input Validation** with express-validator

### 📊 Database
- **MySQL Integration** with mysql2
- **Connection Pooling** for performance
- **Automatic Database Creation** and table setup
- **Secure Password Storage** with bcrypt
- **Token Management** with refresh token storage

### 🛡️ Security Features
- Password strength validation
- Email format validation
- SQL injection prevention
- XSS protection
- Rate limiting per IP
- Secure token generation
- Environment-based configuration

## Prerequisites

- **Node.js** (v16 or higher)
- **MySQL** (XAMPP recommended for development)
- **npm** or **yarn**

## Installation

1. **Clone and navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   - Copy `.env` file and update values:
   ```bash
   # Database Configuration (MySQL with XAMPP)
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=ikiraha_db

   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   JWT_EXPIRES_IN=7d
   JWT_REFRESH_EXPIRES_IN=30d

   # Server Configuration
   PORT=3000
   NODE_ENV=development
   ```

4. **Start XAMPP MySQL**
   - Start Apache and MySQL in XAMPP Control Panel
   - Database will be created automatically

5. **Start the server**
   ```bash
   # Development mode with nodemon
   npm run dev

   # Production mode
   npm start
   ```

## API Endpoints

### Authentication Routes (`/api/auth`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/register` | Register new user | No |
| POST | `/login` | Login user | No |
| POST | `/refresh-token` | Refresh access token | No |
| POST | `/logout` | Logout user | Yes |
| GET | `/profile` | Get user profile | Yes |
| PUT | `/profile` | Update user profile | Yes |
| POST | `/forgot-password` | Request password reset | No |
| POST | `/reset-password` | Reset password with token | No |
| PUT | `/change-password` | Change password | Yes |

### Health Check
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Server and database status |

## Request/Response Examples

### Register User
```bash
POST /api/auth/register
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "Password123",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "email": "john.doe@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone_number": "+1234567890",
      "is_email_verified": false,
      "created_at": "2024-01-01T00:00:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Login User
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "Password123"
}
```

### Get Profile (Protected Route)
```bash
GET /api/auth/profile
Authorization: Bearer YOUR_ACCESS_TOKEN
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone_number VARCHAR(20),
  profile_image_url TEXT,
  is_email_verified BOOLEAN DEFAULT FALSE,
  email_verification_token VARCHAR(255),
  password_reset_token VARCHAR(255),
  password_reset_expires DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP NULL
);
```

### Refresh Tokens Table
```sql
CREATE TABLE refresh_tokens (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  token VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

## Testing with Postman

1. **Import Collection**
   - Import `postman/Ikiraha_API.postman_collection.json` into Postman

2. **Set Environment Variables**
   - `baseUrl`: `http://localhost:3000`
   - `accessToken`: (automatically set after login)
   - `refreshToken`: (automatically set after login)

3. **Test Flow**
   1. Health Check
   2. Register User
   3. Login User (tokens auto-saved)
   4. Get Profile
   5. Update Profile
   6. Change Password
   7. Logout

## Security Best Practices

### Password Requirements
- Minimum 6 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number

### Token Security
- Access tokens expire in 7 days (configurable)
- Refresh tokens expire in 30 days (configurable)
- Tokens are stored securely in database
- Automatic cleanup of expired tokens

### Rate Limiting
- 100 requests per 15 minutes per IP
- Configurable via environment variables

## Error Handling

All API responses follow this format:

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email address",
      "value": "invalid-email"
    }
  ]
}
```

## Development

### Project Structure
```
backend/
├── config/
│   └── database.js          # Database configuration
├── middleware/
│   ├── auth.js              # JWT authentication
│   └── validation.js        # Input validation
├── routes/
│   └── auth.js              # Authentication routes
├── postman/
│   └── Ikiraha_API.postman_collection.json
├── .env                     # Environment variables
├── server.js                # Main server file
├── package.json
└── README.md
```

### Adding New Routes
1. Create route file in `routes/` directory
2. Add validation middleware if needed
3. Import and use in `server.js`
4. Update Postman collection
5. Update this README

## Deployment

### Environment Variables for Production
```bash
NODE_ENV=production
JWT_SECRET=your-production-secret-key
DB_PASSWORD=your-production-db-password
CORS_ORIGIN=https://your-frontend-domain.com
```

### Security Checklist for Production
- [ ] Change default JWT secret
- [ ] Set strong database password
- [ ] Configure proper CORS origins
- [ ] Enable HTTPS
- [ ] Set up proper logging
- [ ] Configure firewall rules
- [ ] Regular security updates

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## License

This project is licensed under the MIT License.
