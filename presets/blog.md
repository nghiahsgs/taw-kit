---
name: blog
description: Markdown blog, single author, stored in the repo, with tags, RSS, and SEO.
---

## Pre-filled intent

I want a personal blog to share posts. Posts are written in Markdown stored in the
repo (no CMS or database), support tag filtering, expose an RSS feed, have proper
SEO meta tags per post, and render well on both desktop and mobile. Single author,
no login.

## Pre-filled clarifications

```yaml
author_name: "Author"
post_storage: filesystem
post_format: markdown
features:
  - tag-filter
  - rss-feed
  - seo-meta
  - reading-time
  - code-highlight
auth_needed: false
comments_needed: false
newsletter_needed: false
language: en
posts_per_page: 10
```

## Stack overrides

```yaml
skip_supabase: true
skip_polar: true
content_dir: content/posts
markdown_lib: next-mdx-remote
syntax_highlight: rehype-pretty-code
rss_path: /feed.xml
sitemap: true
```

## Expected phases

- Set up `content/posts/` with 2 sample posts
- Post list page: card + date + tags + reading time
- Post page: render Markdown with code highlighting + images
- Tag filter: URL pattern `/tag/<tag-name>`
- RSS feed at `/feed.xml` + sitemap.xml + full SEO meta

## Success criteria

- Sample posts render correctly with code highlighting
- `/feed.xml` validates with the W3C Feed Validator
- Lighthouse SEO score ≥ 95 on the post page
- New posts only require creating a `.md` file in `content/posts/`
- `npm run build` exits 0 cleanly
