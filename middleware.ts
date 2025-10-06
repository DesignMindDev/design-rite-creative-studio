import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req: request, res })

  // Get session
  const { data: { session } } = await supabase.auth.getSession()

  // Require authentication for all API routes and protected pages
  if (!session) {
    const redirectUrl = request.nextUrl.clone()
    redirectUrl.pathname = '/'
    redirectUrl.searchParams.set('error', 'unauthorized')
    redirectUrl.searchParams.set('message', 'Please sign in to access Creative Studio')
    return NextResponse.redirect(redirectUrl)
  }

  // Check user role - Creative Studio requires manager+ access
  const { data: roleData } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', session.user.id)
    .single()

  const userRole = roleData?.role || 'user'

  // Only super_admin, admin, and manager roles can access Creative Studio
  if (!['super_admin', 'admin', 'manager'].includes(userRole)) {
    return NextResponse.json(
      { error: 'Forbidden', message: 'Creative Studio requires manager or higher role' },
      { status: 403 }
    )
  }

  return res
}

export const config = {
  matcher: ['/api/:path*', '/projects/:path*']
}
