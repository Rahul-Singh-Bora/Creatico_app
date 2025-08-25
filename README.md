# Creatico – AI Content Generator App  

Creatico is an **AI Content Generator App** that lets users generate responses using their **own API keys**.  
It supports multiple providers (OpenAI, Grok, Anthropic, etc.) and uses **Server-Sent Events (SSE)** for real-time streaming responses.  

The app is built with a **Next.js backend** and a **Flutter frontend**, making it fast, scalable, and mobile-friendly.  

---

## 🚀 Features  
- 🔑 Bring your own API key (BYOK) – no locked provider  
- ⚡ Real-time **streaming responses** using SSE  
- 📱 Mobile app built in **Flutter**  
- 🖥️ Backend in **Next.js** with Prisma + PostgreSQL  
- 📂 Chat history management  
- 🔄 Multi-provider support (OpenAI, Grok, Anthropic)  

---

## 🛠️ Tech Stack  

### Backend  
- [Next.js](https://nextjs.org/) – API routes & deployment  
- [Prisma](https://www.prisma.io/) – ORM for database  
- [PostgreSQL](https://www.postgresql.org/) – Database  
- [SSE](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events) – Live message streaming  
- [Vercel](https://vercel.com/) – Deployment  

### Frontend  
- [Flutter](https://flutter.dev/) – Cross-platform mobile app  
- [Riverpod / Bloc] – State management  
- [Dio / HTTP] – API calls to backend  

---

## 📂 Project Structure  

creatico/
│
├── app/ # Next.js backend routes (API)
│ ├── api/ # API endpoints
│ └── ...
├── lib/ # Prisma setup
├── prisma/ # Database schema
├── flutter_app/ # Flutter frontend
│ ├── lib/ # Main Flutter app code
│ └── ...
└── README.md # Documentation

---

## ⚙️ Setup  

### Backend (Next.js)  

```bash
# Clone repo
git clone https://github.com/your-username/creatico.git
cd creatico

# Install dependencies
npm install

# Setup database (PostgreSQL)
npx prisma migrate dev

# Run backend locally
npm run dev

📡 API Endpoints
POST /api/chat → Create new chat
GET /api/chat → Get all chats
POST /api/chat/[chat_id]/message → Send message
POST /api/generate_message → Generate message with provider (OpenAI/Grok/Anthropic)
POST /api/generate_message_stream → Stream responses (SSE)

📖 Learnings
How to integrate multiple AI providers with custom API keys
Streaming responses using SSE in Next.js
Building a fullstack app with Next.js + Flutter
Handling chat history & persistence with Prisma + PostgreSQL
End-to-end deployment on Vercel

🤝 Contributing
PRs and issues are welcome!

📜 License
MIT License © 2025 Rahul Bora