# SnapVault Development Guidelines

## Build/Configuration Instructions

### Ruby Version
- **Ruby 3.4.2** is required (specified in `.ruby-version` and `Gemfile`)
- Use a Ruby version manager (rbenv, rvm, etc.) to ensure correct version

### Rails Version
- **Rails 8.0.2** with modern features including Hotwire (Turbo + Stimulus)

### Database Setup
```bash
# Initial setup
bundle install
rails db:migrate

# For new migrations
rails db:migrate
rails db:migrate RAILS_ENV=test  # For test environment
```

### Docker Configuration
- Multi-stage Dockerfile optimized for production deployment
- Uses Ruby 3.4.2 slim base image
- Includes security best practices (non-root user)
- SQLite3 database in container
- Asset precompilation and bootsnap optimization included

```bash
# Build Docker image
docker build -t snapvault .

# Run container
docker run -p 3000:3000 snapvault
```

### Key Dependencies
- **Database**: SQLite3 (development/test), easily configurable for production
- **Web Server**: Puma
- **Frontend**: Importmap-rails, Turbo-rails, Stimulus-rails
- **Asset Pipeline**: Sprockets-rails
- **System Testing**: Capybara + Selenium WebDriver with Chrome

## Testing Information

### Test Framework
- **Minitest** (Rails default) with parallel test execution enabled
- Test files organized by type: `test/models/`, `test/controllers/`, `test/system/`, etc.
- Fixtures available in `test/fixtures/` for test data

### Running Tests
```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/photo_test.rb

# Run specific test method
rails test test/models/photo_test.rb -n test_should_require_title

# Run tests by type
rails test:models
rails test:controllers
rails test:system
```

### System Testing Configuration
- Uses Selenium WebDriver with Chrome
- Screen size: 1400x1400 pixels
- Configuration in `test/application_system_test_case.rb`

### Test Example
The Photo model demonstrates proper testing patterns:

```ruby
# Model with validations (app/models/photo.rb)
class Photo < ApplicationRecord
  validates :title, presence: true, length: { minimum: 1, maximum: 100 }
  validates :description, length: { maximum: 500 }
end

# Corresponding tests (test/models/photo_test.rb)
class PhotoTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    photo = Photo.new(title: "Beautiful Sunset", description: "A stunning sunset over the mountains")
    assert photo.valid?
  end

  test "should require title" do
    photo = Photo.new(description: "A photo without title")
    assert_not photo.valid?
    assert_includes photo.errors[:title], "can't be blank"
  end
  # ... additional validation tests
end
```

### Adding New Tests
1. Generate model/controller with tests: `rails generate model ModelName`
2. Tests are automatically created in appropriate directories
3. Follow naming convention: `test_should_describe_behavior`
4. Use descriptive test names and clear assertions
5. Test both positive and negative cases for validations

## Additional Development Information

### Known Issues
- Ruby 3.4.2 with Rails 8.0.2 may show warnings about constant redefinition in net-protocol gem
- These warnings don't affect functionality but are visible during test runs

### Code Style Guidelines
- Follow standard Rails conventions
- Use meaningful validation error messages
- Keep model validations simple and focused
- Write comprehensive tests for all validations and business logic

### Development Workflow
1. Generate models/controllers using Rails generators
2. Add appropriate validations and business logic
3. Write comprehensive tests covering all scenarios
4. Run tests frequently during development
5. Use `rails console` for interactive debugging

### Performance Considerations
- Bootsnap is configured for faster boot times
- Parallel testing enabled (uses number of processors)
- Asset precompilation optimized in Docker build

### Security Notes
- Docker container runs as non-root user
- Standard Rails security features enabled
- Consider adding authentication gems (devise, etc.) for production use
