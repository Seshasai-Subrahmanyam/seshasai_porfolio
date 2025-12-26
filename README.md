# Seshasai Subrahmanyam Portfolio
Developer: Seshasai nagadevara | 7013869169 | nvsseshasai@gmail.com


A modern Flutter Web portfolio for a Senior Flutter Developer & Generative AI Engineer, featuring RAG-powered chat, project showcases, and an experience journey.

![Portfolio Banner](assets/images/portfolio_banner.png)

## ✨ Features

- **🚀 Splash Screen** - Immersive gradient launch with remote data prefetching
- **🤖 JUNNU AI** - Intelligent RAG assistant that answers questions about my experience, skills, and background using a custom Python fastapi and chromadb for vector search and claude api for completions.
  - **Persona Modes**: Chat as a Recruiter, Tech Lead, Founder, or Peer Developer
  - **Context Aware**: Integrated into Education and Skills pages for contextual Q&A
- **🏠 Landing Page** - Hero section with animated availability status & dynamic text
- **🗺️ Experience Journey** - Interactive timeline with parallax scroll effects
- **📁 Projects** - Netflix-style carousel combining video demos & screenshots
- **🧠 Skills Playground** - Filterable skill chips with detailed drawers
- **📜 Certificates** - Grid display of credentials with CDN images
- **📱 Published Apps** - Shelf view of App Store/Play Store apps

## 🛠️ Architecture

This project demonstrates a production-grade **Flutter Web** architecture integrated with a **Python RAG Backend**.

- **Frontend**: Flutter (Web)
  - State Management: `flutter_bloc`
  - Routing: `go_router`
  - Networking: `Dio`
  - UI: Responsive design, Custom animations, Glassmorphism
- **Backend**: Python (FastAPI)
  - RAG Engine: Retrieval Augmented Generation for chat
  - API: Serve `resume.json` and query endpoints
- **Data**: JSON-based resume schema (fetched remotely with local fallback)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Python 3.9+ (for RAG server)
- Chrome browser

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd seshasai_subrahmanyam_portfolio

# Install Flutter dependencies
flutter pub get
```

### Running the Backend (RAG Server)

The portfolio relies on a Python backend for Chat and Resume data.

```bash
# Navigate to backend directory (if separate) or run your RAG server
# Ensure server is running at http://localhost:8000 or your deployment URL
uvicorn main:app --reload
```

### Running the App

```bash
# Run in Chrome (development)
flutter run -d chrome

# Run with Custom RAG Server URL
flutter run -d chrome \
  --dart-define=RAG_SERVER_URL=http://localhost:8000
```

## ⚙️ Configuration

The app is configurable via compile-time variables (`--dart-define`):

| Variable | Default | Description |
|----------|---------|-------------|
| `RAG_SERVER_URL` | `http://localhost:8000` | Base URL for the RAG backend API |
| `MAKE_AVAILABILITY_URL` | `''` | Optional webhook for availability status |
| `MAKE_PROJECT_STORY_URL` | `''` | Optional webhook for project stories |

### Resume Data (`assets/resume.json`)

The master data source for the portfolio. It includes:
- **Profile**: Name, title, summary, social links
- **Availability**: Status (`OPEN_FOR_WORK`) and `lastUpdated` timestamp
- **Experience**: Timeline data
- **Projects**: Descriptions, tech stack, video URLs, screenshot URLs
- **Skills**: Categorized list (Languages, Frameworks, AI etc.)

## 📂 Project Structure

```
lib/
├── main.dart                 # Entry point
├── app/
│   ├── app.dart              # App wrapper (Splash Screen here)
│   ├── router/               # Navigation config
│   └── widgets/              # Shared UI (AppShell, Footer)
├── core/
│   ├── config/               # Environment vars
│   ├── data/                 # Repositories (Resume, Availability)
│   ├── models/               # Data models (JSON serialization)
│   ├── network/              # API Clients (RagApiClient)
│   └── theme/                # App styling & colors
└── features/
    ├── landing/              # Home & Availability Logic
    ├── projects/             # Project Details & Media Carousel
    ├── chat/                 # AI Chat Interface (Typing indicators, Markdown)
    ├── journey/              # Experience Timeline
    └── [skills, apps...]     # Other sections
```

## 📝 License

MIT License
