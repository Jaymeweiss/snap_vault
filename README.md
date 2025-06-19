# SnapVault

SnapVault is a secure file storage application built with Rails 8 and React. It provides user authentication and file upload capabilities with a modern, responsive interface.

## Ruby version

- **Ruby 3.4.2** is required (specified in `.ruby-version` and `Gemfile`)
- Use a Ruby version manager (rbenv, rvm, etc.) to ensure correct version

## System dependencies

### Core Dependencies
- **Rails 8.0.2** with modern features including Hotwire (Turbo + Stimulus)
- **React** for frontend components and user interface
- **SQLite3** for database (development/test), easily configurable for production
- **Puma** web server
- **BCrypt** for secure password hashing

### Frontend Dependencies
- Importmap-rails for JavaScript module management
- Turbo-rails and Stimulus-rails for enhanced interactivity
- React-rails for React integration

### Development & Testing
- **Capybara** + **Selenium WebDriver** with Chrome for system testing
- **Minitest** for testing framework
- **Debug** gem for debugging

## Configuration

### Initial Setup
1. Clone the repository
2. Ensure Ruby 3.4.2 is installed
3. Install dependencies:
   ```bash
   bundle install
   ```

### Environment Setup
The application uses standard Rails configuration files:
- `config/database.yml` for database configuration
- `config/routes.rb` for routing
- `config/importmap.rb` for JavaScript modules

## Database creation

```bash
# Create and setup the database
rails db:create
rails db:migrate
```

## Database initialization

### Development Data
The application includes user fixtures for testing. To create a test user for development:

```bash
rails console
```

Then in the console:
```ruby
User.create!(email: "test@example.com", password: "password123")
```

### Database Schema
The application includes:
- **Users** table with email and password authentication
- **Uploaded Files** table for file storage metadata
- Active Storage for file attachments

## How to run the test suite

### Running All Tests
```bash
rails test
```

### Running Specific Test Types
```bash
# Run model tests
rails test:models

# Run controller tests  
rails test:controllers

# Run system tests (browser-based)
rails test:system

# Run specific test file
rails test test/models/user_test.rb
```

### Test Configuration
- Tests use **Minitest** with parallel execution enabled
- System tests use Chrome WebDriver with 1400x1400 screen size
- Test fixtures available in `test/fixtures/` for test data
- Comprehensive test coverage for authentication and file operations

## Services (job queues, cache servers, search engines, etc.)

### File Storage
- Uses **Active Storage** for file attachments
- Supports multiple file types: images (jpg, jpeg, png, gif, svg) and documents (txt, md, csv)
- 2MB file size limit enforced
- Files stored locally in development, configurable for cloud storage in production

### Authentication System
- **Session-based authentication** with secure password hashing
- **JSON API endpoints** for React frontend communication
- **Token-based API authentication** for file operations
- Automatic redirect to login for unauthenticated users

### Frontend Architecture
- **React components** for all user interfaces:
    - `Login.jsx` - User authentication
    - `Upload.jsx` - File upload interface
    - `FileList.jsx` - Display uploaded files
    - `App.jsx` - Main application with routing
- **Client-side routing** with React Router
- **JSON API communication** between React and Rails

## Deployment instructions

### Local Development
```bash
# Start the Rails server
rails server

# Visit the application
open http://localhost:3000
```

### Docker Deployment
The application includes a multi-stage Dockerfile optimized for production:

```bash
# Build Docker image
docker build -t snapvault .

# Run container
docker run -p 3000:3000 snapvault
```

### Docker Features
- Uses Ruby 3.4.2 slim base image
- Non-root user for security
- Asset precompilation and bootsnap optimization
- SQLite3 database in container

### Production Considerations
- Configure database for production (PostgreSQL recommended)
- Set up cloud storage for Active Storage (AWS S3, etc.)
- Configure environment variables for secrets
- Set up SSL/TLS certificates
- Consider using a reverse proxy (nginx)

## Application Navigation

### User Authentication
1. **Login**: Visit the root URL - unauthenticated users are automatically redirected to login
2. **Credentials**: Use the test user created during setup or create new users via Rails console
3. **Session Management**: Login persists across browser sessions

### File Management
1. **Upload Files**: Navigate to `/upload` after login
    - Drag and drop or click to select files
    - Supported formats: JPG, PNG, GIF, SVG, TXT, MD, CSV
    - Maximum file size: 2MB
2. **View Files**: Navigate to `/files` to see all uploaded files
    - View file details (name, size, upload date)
    - Download files directly
    - Preview supported file types

### API Endpoints
- `POST /sessions` - User login
- `DELETE /sessions` - User logout
- `GET /sessions` - Current user info
- `GET /api/files` - List user's files
- `POST /api/files` - Upload new file

### Development Tools
- **Rails Console**: `rails console` for database operations
- **Rails Routes**: `rails routes` to see all available routes
- **Logs**: Check `log/development.log` for debugging
- **Tests**: Run `rails test` before making changes

## Troubleshooting

### Common Issues
- **Ruby Version**: Ensure Ruby 3.4.2 is active (`ruby -v`)
- **Bundle Issues**: Run `bundle install` if gems are missing
- **Database Issues**: Run `rails db:migrate` if database is out of sync
- **JavaScript Issues**: Check browser console for React errors
- **File Upload Issues**: Verify file size (<2MB) and allowed extensions

### Getting Help
- Check the Rails logs in `log/development.log`
- Run tests to verify system functionality
- Use Rails console to debug data issues
- Check browser developer tools for frontend issues