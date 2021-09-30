{%- if theme.busuanzi_count.enable %}
<div class="busuanzi-count">
  <script async src="https://busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js"></script>
  
  {%- if theme.busuanzi_count.total_visitors %}
    <span class="post-meta-item" id="busuanzi_container_site_uv">
      <span class="post-meta-item-icon">
        <i class="{{ theme.busuanzi_count.total_visitors_icon }}"></i>
      </span>
      <span class="site-uv" title="{{ __('footer.total_visitors') }}">
        <span id="busuanzi_value_site_uv"></span>
      </span>
    </span>
  {%- endif %}

  <span class="site-pv" title="{{ __('footer.total_views') }}">
    经过<span id="busuanzi_value_site_pv"></span>次回眸与你相遇
  </span>
</div>
{%- endif %}
