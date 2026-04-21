---
name: tailwind-design
description: >
  Tailwind CSS utility patterns for taw-kit UI: hero sections, product grids,
  responsive layouts, color theming, and common Vietnamese e-commerce UI blocks.
  Reference for fullstack-dev agent during component generation.
argument-hint: "[ui-block-name hoac 'list']"
---

# tailwind-design — UI Styling Patterns

## Core Layout Patterns

### Hero Section
```tsx
<section className="relative flex flex-col items-center justify-center min-h-[70vh] px-4 text-center bg-gradient-to-br from-slate-900 to-slate-700">
  <h1 className="text-4xl md:text-6xl font-bold text-white mb-4">
    Tieu de chinh
  </h1>
  <p className="text-lg text-slate-300 max-w-xl mb-8">Mo ta ngan gon</p>
  <button className="px-8 py-3 bg-orange-500 hover:bg-orange-600 text-white rounded-full font-semibold transition-colors">
    Mua ngay
  </button>
</section>
```

### Product Grid
```tsx
<div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 p-4">
  {products.map(p => (
    <div key={p.id} className="rounded-xl border border-slate-200 overflow-hidden hover:shadow-lg transition-shadow">
      <img src={p.image_url} alt={p.name} className="w-full aspect-square object-cover" />
      <div className="p-3">
        <h3 className="font-medium text-sm truncate">{p.name}</h3>
        <p className="text-orange-600 font-bold">{p.price_vnd.toLocaleString('vi-VN')}đ</p>
      </div>
    </div>
  ))}
</div>
```

### Sticky Navigation
```tsx
<nav className="sticky top-0 z-50 bg-white/80 backdrop-blur border-b border-slate-100 px-4 py-3 flex items-center justify-between">
  <span className="font-bold text-lg">Ten cua hang</span>
  <div className="flex gap-3">
    <a href="/shop" className="text-sm text-slate-600 hover:text-slate-900">Cua hang</a>
    <a href="/cart" className="text-sm font-medium text-orange-600">Gio hang (2)</a>
  </div>
</nav>
```

### Responsive Two-Column
```tsx
<div className="max-w-6xl mx-auto px-4 py-12 grid md:grid-cols-2 gap-12 items-center">
  <div>...</div>
  <div>...</div>
</div>
```

### Alert / Notice Box
```tsx
<div className="rounded-lg bg-orange-50 border border-orange-200 p-4 text-sm text-orange-800">
  Mien phi van chuyen don hang tren 500.000đ
</div>
```

## Common Utility Classes

| Purpose | Classes |
|---------|---------|
| VN price text | `text-orange-600 font-bold` |
| Badge / tag | `px-2 py-0.5 rounded-full text-xs bg-green-100 text-green-700` |
| Section padding | `py-16 px-4 max-w-6xl mx-auto` |
| Card | `rounded-xl border border-slate-200 p-4 shadow-sm` |
| CTA button | `px-6 py-2.5 bg-orange-500 hover:bg-orange-600 text-white rounded-lg font-medium transition-colors` |
| Form input | `w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-orange-400` |
| Skeleton loader | `animate-pulse bg-slate-200 rounded` |

## Dark Mode

Add `dark:` prefix variants. Root config in `tailwind.config.ts`:
```ts
darkMode: "class"  // toggle via <html class="dark">
```

## Responsive Breakpoints

- `sm:` — 640px+
- `md:` — 768px+
- `lg:` — 1024px+
- Always design mobile-first (no prefix = mobile).
