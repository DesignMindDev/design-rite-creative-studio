/**
 * AI Session Logger
 * Logs AI conversations and interactions to Supabase for analytics and debugging
 */

import { createHash } from 'crypto'

/**
 * Generate a hash for user identification (IP-based or user ID)
 * Used for privacy-preserving analytics
 */
export function generateUserHash(identifier: string): string {
  return createHash('sha256').update(identifier).digest('hex').substring(0, 16)
}

/**
 * Generate a unique session ID for tracking conversation threads
 */
export function generateSessionId(): string {
  return `session_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`
}

/**
 * Log an AI conversation to Supabase for analytics
 *
 * @param supabase - Supabase client instance
 * @param data - Conversation data to log
 */
export async function logAIConversation(
  supabase: any,
  data: {
    userId?: string
    userHash: string
    sessionId: string
    provider: string
    assistantId?: string
    messageCount: number
    promptTokens?: number
    completionTokens?: number
    totalTokens?: number
    model?: string
    conversationContext?: any
  }
) {
  try {
    const { error } = await supabase
      .from('ai_sessions')
      .insert({
        user_id: data.userId || null,
        user_hash: data.userHash,
        session_id: data.sessionId,
        provider: data.provider,
        assistant_id: data.assistantId || null,
        message_count: data.messageCount,
        prompt_tokens: data.promptTokens || null,
        completion_tokens: data.completionTokens || null,
        total_tokens: data.totalTokens || null,
        model: data.model || null,
        conversation_context: data.conversationContext || null,
        created_at: new Date().toISOString()
      })

    if (error) {
      console.error('[AI Session Logger] Error logging conversation:', error)
      // Don't throw - logging errors shouldn't break the API
    }
  } catch (error) {
    console.error('[AI Session Logger] Unexpected error:', error)
    // Don't throw - logging errors shouldn't break the API
  }
}
