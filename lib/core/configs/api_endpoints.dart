class ApiEndpoints {
  // Base URL of your Next.js backend (adjust for local/dev/prod)
  static const String baseUrl = "http://localhost:3000"; 

  // Auth endpoints (later when you enable Supabase auth)
  static const String login = "$baseUrl/api/auth/login";
  static const String register = "$baseUrl/api/auth/register";

  // Idea endpoints
  static const String generateIdea = "$baseUrl/api/generate-idea";
  static const String getIdeas = "$baseUrl/api/ideas";
}
