{% if theme.busuanzi_count.enable %}
<div style="background-color: white" class="busuanzi-count">
  <script async src="https://busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js"></script>

  {% if theme.busuanzi_count.site_uv %}
    <span class="site-uv">
      {{ theme.busuanzi_count.site_uv_header }}
      访客数<span class="busuanzi-value" id="busuanzi_value_site_uv"></span>
      {{ theme.busuanzi_count.site_uv_footer }}
    </span>
  {% endif %}

  {% if theme.busuanzi_count.site_pv %}
    <span class="site-pv">
      {{ theme.busuanzi_count.site_pv_header }}
      访问量<span class="busuanzi-value" id="busuanzi_value_site_pv"></span>次
      {{ theme.busuanzi_count.site_pv_footer }}
    </span>
  {% endif %}
</div>
{% endif %}
