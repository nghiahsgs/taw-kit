---
name: blog
description: Blog markdown một tác giả lưu trong repo, có tag, RSS, và SEO tối ưu.
---

## Pre-filled intent

Tôi muốn tạo một blog cá nhân để chia sẻ bài viết. Bài viết viết bằng Markdown lưu
thẳng trong repo (không cần CMS hay database), hỗ trợ lọc theo tag, có feed RSS,
SEO meta tags cho từng bài, và hiển thị đẹp trên cả desktop lẫn mobile. Một tác giả,
không cần đăng nhập.

## Pre-filled clarifications

```yaml
author_name: "Tác giả"
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
language: vi
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

- Thiết lập cấu trúc thư mục `content/posts/` với 2 bài mẫu
- Trang danh sách bài viết: card + ngày + tags + thời gian đọc
- Trang bài viết: render Markdown với highlight code + ảnh
- Lọc theo tag: URL dạng `/tag/ten-tag`
- RSS feed tại `/feed.xml` + sitemap.xml + SEO meta đầy đủ

## Success criteria

- 2 bài mẫu hiển thị đúng với code highlight
- `/feed.xml` validate bằng W3C Feed Validator
- Lighthouse SEO score ≥ 95 trên trang bài viết
- Thêm bài mới chỉ cần tạo file `.md` trong `content/posts/`
- `npm run build` xanh không lỗi
