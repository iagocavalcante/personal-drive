# Personal Drive

Personal file storage with Phoenix API + Cloudflare R2.

## Tech Stack

- **Backend**: Phoenix Framework (Elixir)
- **Database**: SQLite
- **Storage**: Cloudflare R2
- **Auth**: Pow (Email/Password + Magic Link)
- **Email**: Resend
- **Frontend**: Vanilla JS + Vite

## Development Setup

### Prerequisites

- Node.js 18+
- Elixir 1.16+
- Phoenix

### Frontend

```bash
# Install dependencies
npm install

# Copy environment config
cp .env.example .env

# Run development server
npm run dev
```

### Backend

```bash
cd personal_drive_api

# Install dependencies
mix deps.get

# Create database
mix ecto.create

# Run migrations
mix ecto.migrate

# Start Phoenix server
mix phx.server
```

## Environment Variables

### Frontend (.env)
```
VITE_API_URL=http://localhost:4000/api/v1
```

### Backend
```
SECRET_KEY_BASE= 生成: mix phx.gen.secret
DATABASE_PATH=priv/personal_drive_api.db
R2_ACCESS_KEY_ID=your_r2_key
R2_SECRET_ACCESS_KEY=your_r2_secret
R2_REGION=auto
R2_HOST=your-account.r2.cloudflarestorage.com
R2_BUCKET=personal-drive
R2_PUBLIC_URL=https://your-domain.r2.dev
RESEND_API_KEY=re_xxx
```

## Docker Deployment

```bash
# Copy and configure environment
cp .env.production.example .env
# Edit .env with your values

# Deploy with Dokploy
dokploy deploy
```

## Security

⚠️ **Important**: Never commit secrets to version control!

- `.env` files are gitignored
- Use environment variables for all secrets
- Rotate API keys regularly
- Review `SECRET_KEY_BASE` in production

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/v1/auth/register | Register new user |
| POST | /api/v1/auth/login | Login |
| GET | /api/v1/files | List files |
| POST | /api/v1/files/folder | Create folder |
| POST | /api/v1/files/upload | Upload file |
| GET | /api/v1/files/:id/download | Get download URL |
| DELETE | /api/v1/files/:id | Delete file |
| POST | /api/v1/files/:id/share | Share file |
| GET | /api/v1/shared | Files shared with me |
| GET | /api/v1/usage | Storage usage |

## License

MIT
