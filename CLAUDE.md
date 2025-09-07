# Furomeguri - Hot Spring Tourism Application

## Project Overview

**Furomeguri** (風呂巡り) is a specialized Rails 7.2.1 travel planning application focused on Japanese hot spring (onsen) tourism. The application combines interactive mapping, multi-API search, and itinerary management to help users discover and plan hot spring tours across Japan.

### Core Features
- **Interactive Map Search**: Google Maps integration with hot spring location discovery
- **Multi-API Integration**: Google Places API and Rakuten Travel API for comprehensive data
- **Drag & Drop Itineraries**: Real-time itinerary building with sortable items
- **Social Authentication**: Email/password and Google OAuth2 login options
- **Responsive Design**: Mobile-first approach with TailwindCSS + DaisyUI

## Technology Stack

### Backend
- **Rails 7.2.1** with PostgreSQL database
- **Devise** for authentication with Google OAuth2
- **Turbo Rails & Stimulus** (Hotwire stack)
- **RankedModel** for drag-and-drop ordering

### Frontend
- **TailwindCSS 4.0** + **DaisyUI 5.0** for styling
- **JavaScript ES6+** with esbuild bundling
- **SortableJS** for drag-and-drop functionality
- **Turbo Streams** for real-time UI updates

### External APIs
- **Google Maps API** - Map rendering and markers
- **Google Places API** - Location search and data
- **Rakuten Travel API** - Hotel/accommodation data (in development)
- **Google OAuth2** - Social authentication

## Architecture Overview

### Key Models
```ruby
User (Devise) -> has_many -> Itinerary -> has_many -> ItineraryBlock -> belongs_to -> Place
                                                                    \
DefaultLocation (seed data for hot spring locations)               -> Google Places API
```

### Controllers Structure
- **MapsController**: Homepage, search interface, API integrations
- **ItinerariesController**: CRUD operations for travel plans
- **ItineraryBlocksController**: Individual itinerary item management
- **API::DefaultLocationsController**: Provides seed location data to frontend

### Frontend Architecture
- **application.js**: Google Maps integration, search handling, marker management
- **Sortable Controller** (Stimulus): Drag-and-drop itinerary reordering
- **Turbo Streams**: Real-time updates when adding/removing places

## Current Implementation Status

### ✅ Completed Features
- User authentication (email/password + Google OAuth2)
- Interactive Google Maps with custom markers
- Google Places API search with filtering
- Itinerary creation and management
- Drag-and-drop itinerary reordering
- Real-time UI updates via Turbo Streams
- Responsive design for mobile/desktop

### 🚧 In Development
- **Rakuten Travel API integration** (MapsController:87-95, application.js:162-174)
- Enhanced search filtering and sorting options
- User profile and preference management

### 🔜 Planned Features
- Jalan API integration (third search option)
- Social features and itinerary sharing
- Advanced recommendation system
- Offline map support (PWA)

## Development Commands

### Testing
```bash
bundle exec rspec                    # Run test suite
bundle exec rubocop                  # Code style checking
```

### Database
```bash
rails db:create db:migrate db:seed   # Initial setup
rails db:reset                      # Reset with seed data
```

### Development Server
```bash
rails server                        # Start Rails server
./bin/dev                           # Start with CSS/JS watching
```

## File Ownership Management

When Claude Code edits files, it runs as root and changes file ownership. To maintain proper ownership for the development user (uid=1000):

### Auto-restore file ownership after ALL edits
**IMPORTANT**: After ANY file modification, ALWAYS run:
```bash
find /myapp -user root -not -path "*/node_modules/*" -exec chown 1000:1000 {} \;
```

This command:
- Finds all root-owned files in the project
- Excludes node_modules directory
- Restores ownership to uid=1000 (development user)
- Ensures the user doesn't need `sudo` for subsequent operations

**Must be executed after every file change to prevent permission issues.**

## Claude Code Communication Settings

**IMPORTANT**: Claude Code must ALWAYS respond in Japanese (日本語) for all communications with the user. This includes:
- All explanations and responses
- Error messages and debugging information  
- Code comments and documentation
- Progress updates and status messages

This is a Japanese hot spring tourism application (風呂巡り), and Japanese communication is essential for proper user interaction.