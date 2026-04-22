---
name: taw-rn-supabase
description: >
  Wire Supabase JS client into a React Native (Expo) taw-kit project: session
  persistence via AsyncStorage, magic-link OAuth callback via expo-linking deep
  links, Realtime subscriptions on RN, and shared TypeScript types with the
  Next.js webapp twin (taw-kit's typical web<->mobile pair pattern). This is the
  mobile counterpart of `auth-magic-link` (web). User-visible strings match the
  user's input language (Vietnamese by default for VN users). Trigger phrases
  (EN + VN): "supabase react native", "supabase mobile", "auth mobile expo",
  "magic link mobile", "tich hop supabase vao app", "supabase deep link".
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Skill
---

# taw-rn-supabase

Bridge a React Native (Expo) app to a Supabase backend the way taw-kit's Next.js webapp does it — same project, same RLS policies, shared types — but with mobile-specific glue (AsyncStorage, deep links, no `next/headers`).

**Language rule:** Detect the user's input language. Reply 100% Vietnamese for VN users (Southern, friendly), English for EN. Default Vietnamese for ambiguous input. Code/CLI commands stay English.

## When to invoke

- New Expo project that needs Supabase auth or DB access
- Porting an existing taw-kit web feature (chat, profile, orders, etc.) to mobile and needing the same Supabase backend
- Adding magic-link sign-in to a mobile app
- Adding Supabase Realtime subscriptions (e.g. live chat) to mobile

## Stack assumptions

- Expo SDK 51+ (Expo Router, file-based routing)
- TypeScript
- `@supabase/supabase-js` v2.45+
- `@react-native-async-storage/async-storage` for session persistence
- `expo-linking` + `expo-web-browser` for OAuth/magic-link callbacks
- NativeWind v5 (if styling needed — pair with `expo-tailwind-setup` skill)
- Already-running Supabase project (URL + anon key in env)

If user is missing any of the above, invoke `expo-tailwind-setup` or instruct them to run `supabase-setup` skill first to provision the backend.

## Step 1 — Install dependencies

```bash
npx expo install @supabase/supabase-js @react-native-async-storage/async-storage expo-linking expo-web-browser
```

Why each:
- `@supabase/supabase-js` — universal client (works in RN with adapter)
- `@react-native-async-storage/async-storage` — persists JWT session across app restarts
- `expo-linking` — handles `myapp://` deep-link callbacks from Supabase auth emails
- `expo-web-browser` — opens magic-link / OAuth in in-app browser, returns to app via deep link

## Step 2 — Configure app scheme (required for deep links)

Edit `app.json` (or `app.config.ts`):

```json
{
  "expo": {
    "scheme": "tawkitapp",
    "ios": { "bundleIdentifier": "com.tawkit.<project-slug>" },
    "android": { "package": "com.tawkit.<projectslug>" }
  }
}
```

Replace `tawkitapp` with the project's slug from `.taw/intent.json`. The scheme MUST be unique per app — collisions cause silent deep-link failures.

## Step 3 — Create Supabase client (`lib/supabase.ts`)

```ts
import 'react-native-url-polyfill/auto'
import AsyncStorage from '@react-native-async-storage/async-storage'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false, // RN does NOT use URLs for callbacks — deep links instead
  },
})
```

Then `npx expo install react-native-url-polyfill` (Supabase needs URL APIs missing in RN's Hermes runtime).

**`.env` keys** (note `EXPO_PUBLIC_*` prefix — Expo equivalent of `NEXT_PUBLIC_*`):
```
EXPO_PUBLIC_SUPABASE_URL=https://<ref>.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...
```

**HARD RULE:** NEVER add `SUPABASE_SERVICE_ROLE_KEY` to a mobile app. Mobile bundles ship to user devices = anyone can extract. Service-role calls go through your Next.js backend, which the mobile app calls via authenticated API.

## Step 4 — Magic-link sign-in screen

`app/(auth)/sign-in.tsx`:

```tsx
import { useState } from 'react'
import { View, Text, TextInput, Pressable, Alert } from 'react-native'
import * as Linking from 'expo-linking'
import { supabase } from '@/lib/supabase'

export default function SignIn() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)

  const sendMagicLink = async () => {
    setLoading(true)
    const redirectTo = Linking.createURL('/auth/callback')
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: redirectTo },
    })
    setLoading(false)
    if (error) Alert.alert('Lỗi', error.message)
    else Alert.alert('Đã gửi', 'Mở email để bấm vào link đăng nhập.')
  }

  return (
    <View className="flex-1 justify-center px-6 bg-white dark:bg-black">
      <Text className="text-2xl font-bold mb-4 text-black dark:text-white">Đăng nhập</Text>
      <TextInput
        className="border border-gray-300 dark:border-gray-700 rounded-lg p-3 mb-4 text-black dark:text-white"
        placeholder="email@cua-ban.com"
        autoCapitalize="none"
        autoComplete="email"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
      />
      <Pressable
        className="bg-blue-600 rounded-lg p-3 items-center"
        onPress={sendMagicLink}
        disabled={loading || !email}
      >
        <Text className="text-white font-semibold">
          {loading ? 'Đang gửi...' : 'Gửi link đăng nhập'}
        </Text>
      </Pressable>
    </View>
  )
}
```

(VN labels by default; switch to English when project is EN.)

## Step 5 — Deep-link callback handler

`app/auth/callback.tsx`:

```tsx
import { useEffect } from 'react'
import { useLocalSearchParams, router } from 'expo-router'
import { supabase } from '@/lib/supabase'

export default function AuthCallback() {
  const params = useLocalSearchParams<{ access_token?: string; refresh_token?: string }>()

  useEffect(() => {
    if (params.access_token && params.refresh_token) {
      supabase.auth.setSession({
        access_token: params.access_token,
        refresh_token: params.refresh_token,
      }).then(() => router.replace('/(tabs)'))
    }
  }, [params])

  return null
}
```

In Supabase dashboard → Authentication → URL Configuration, add the redirect URL pattern: `tawkitapp://auth/callback` (replace `tawkitapp` with your scheme).

## Step 6 — Session hook (use in any screen)

`hooks/useSession.ts`:

```ts
import { useEffect, useState } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

export function useSession() {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session)
      setLoading(false)
    })
    const { data: sub } = supabase.auth.onAuthStateChange((_event, sess) => {
      setSession(sess)
    })
    return () => sub.subscription.unsubscribe()
  }, [])

  return { session, loading, user: session?.user ?? null }
}
```

Use in protected screens: `const { session, loading } = useSession(); if (!session) return <Redirect href="/(auth)/sign-in" />;`

## Step 7 — Realtime subscriptions (for chat / live data)

```ts
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'

export function useRealtimeMessages(chatId: string) {
  const [messages, setMessages] = useState<Message[]>([])

  useEffect(() => {
    const channel = supabase
      .channel(`chat:${chatId}`)
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'messages',
        filter: `chat_id=eq.${chatId}`,
      }, (payload) => setMessages(prev => [...prev, payload.new as Message]))
      .subscribe()

    return () => { supabase.removeChannel(channel) }
  }, [chatId])

  return messages
}
```

Identical API to web — mobile RN client speaks same Realtime protocol. RLS policies apply automatically (user can only subscribe to channels their JWT permits).

## Step 8 — Sharing types with the Next.js twin

If user has both web (`farm-management-saas-fe`) and mobile (`farm-management-saas-mobile`) repos:

1. Run `supabase gen types typescript --project-id <ref> > lib/supabase/types.ts` in ONE repo (web), commit.
2. In mobile repo, **copy** `lib/supabase/types.ts` from web (do NOT symlink — Metro bundler hates symlinks crossing repos).
3. Add a sync note in `README.md`: "When DB schema changes, regen on web first, then copy types to mobile."

For shared business logic (validators, helpers), recommend extracting to a separate npm package later. For an MVP port, copy-paste is fine.

## Common pitfalls (avoid these)

| Pitfall | Why it fails | Fix |
|---|---|---|
| Forgetting `react-native-url-polyfill/auto` import | Hermes runtime lacks URL constructor | Import at top of `lib/supabase.ts` |
| Using `localStorage` (web pattern) | Doesn't exist in RN | Use AsyncStorage adapter |
| `detectSessionInUrl: true` | RN has no URL bar; never fires | Set to `false` |
| Service role key in mobile env | Anyone can extract from APK/IPA bundle | NEVER include; route through web backend |
| Same scheme as another app on device | Deep-link goes to wrong app | Use unique scheme like `tawkitapp-<slug>` |
| Forgot to register redirect URL in Supabase dashboard | Magic link returns 400 | Add `myscheme://auth/callback` to allowed redirect URLs |

## Output

After running this skill, fullstack-dev should have:
- `lib/supabase.ts` — client
- `app/(auth)/sign-in.tsx` — magic-link screen
- `app/auth/callback.tsx` — deep-link handler
- `hooks/useSession.ts` — auth state hook
- (Optional) `hooks/useRealtimeMessages.ts` if Realtime needed
- `app.json` — `scheme` field set
- `.env.example` — `EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`

Status line for orchestrator: `"Supabase RN wired. Auth + Realtime ready. Scheme: tawkitapp."`
