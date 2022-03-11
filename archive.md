---
layout: default
permalink: /all
---

<div class="post-archive">
  {%- assign posts_by_year = site.posts | group_by_exp:"post","post.date | date:'%Y' " -%}
  {%- for posts_in_year in posts_by_year -%}
    <h3>{{ posts_in_year.name }}</h3>
    <ul>
    {%- for post in posts_in_year.items -%}
      <li>
        <span><a href="{{ post.url }}">{{ post.title }}</a></span>
        <date>{{ post.date | date:'%B %e, %Y'}}</date>
      </li>
    {% endfor %}
    </ul>
  {% endfor %}
</div>
